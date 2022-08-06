defmodule Eblox.Data.Provider do
  @moduledoc """
  The behaviour sdpecifying the data provider to be plugged into `Eblox`.

  Data providers define how the data is collected from different data sources
    and mix the content into the whole content pool available to `Eblox`.
  """

  alias Eblox.Data.Provider

  @typedoc """
  URI of the resource, e. g. path to the file for file system
  """
  @type uri :: Path.t() | any()

  @typedoc """
  This struct contains information about changes found upon the consecutive scan
  """
  @type t :: %{__struct__: Provider, created: [uri()], deleted: [uri()], changed: [uri()]}

  use Estructura, enumerable: true

  defstruct created: [], deleted: [], changed: []

  @doc """
  The providers must implement this callback returning the changes found
  """
  @callback scan(options :: map()) :: {map(), t()}

  @fsm """
  idle --> |scan| ready
  ready --> |scan| ready
  ready --> |stop| died
  """

  use Finitomata, fsm: @fsm, impl_for: [:on_transition]

  @doc false
  def on_transition(_, :scan, _, payload) do
    # TODO Checks and proper error messages
    {impl, options} = Map.pop(payload, :impl)
    {options, %Provider{} = result} = impl.scan(options)

    handle_changes(result)

    {:ok, :ready, Map.put(options, :impl, impl)}
  end

  @behaviour Siblings.Worker

  @impl Siblings.Worker
  @doc false
  def perform(:died, _id, payload), do: {:transition, :*, payload}
  def perform(_state, _id, payload), do: {:transition, :scan, payload}

  @spec handle_changes(t()) :: [:ok]
  def handle_changes(%Provider{created: _, deleted: _, changed: _} = changes) do
    changes
    |> Flow.from_enumerable()
    |> Flow.flat_map(fn {action, list} -> Enum.map(list, &{action, &1}) end)
    |> Flow.partition()
    |> Flow.reduce(fn -> [] end, fn {action, elem}, acc -> [action(action, elem) | acc] end)
    |> Enum.to_list()
  end

  @interval Application.compile_env(:eblox, :interval, 60_000)
  defp random_interval, do: Enum.random(div(@interval, 2)..@interval//1_000)

  @spec action(:created | :deleted | :changed, binary()) :: :ok
  defp action(:created, file) do
    with {:ok, _server} <-
           Siblings.start_child(Eblox.Data.PostFSM, file, %{file: file},
             name: Eblox.Data.Content,
             interval: random_interval()
           ),
         do: :ok
  end

  defp action(:deleted, file) do
    Siblings.transition(Eblox.Data.Content, file, :delete, nil)
  end

  defp action(:changed, file) do
    Siblings.transition(Eblox.Data.Content, file, :parse, nil)
  end
end
