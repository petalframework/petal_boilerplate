defmodule Eblox.Data.Listener do
  @moduledoc false

  require Logger

  @behaviour Eblox.Data.Monitor

  @interval Application.compile_env(:eblox, :interval, 60_000)

  def random_interval, do: Enum.random(div(@interval, 2)..@interval//1_000)

  @impl Eblox.Data.Monitor
  def on_content_change(message) do
    message
    |> tap(fn m -> m |> inspect() |> Logger.info() end)
    |> handle_changes()
  end

  @spec handle_changes(Eblox.Monitor.message()) :: [:ok]
  def handle_changes(%{created: _, deleted: _, changed: _} = changes) do
    changes
    |> Flow.from_enumerable()
    |> Flow.flat_map(fn {action, list} -> Enum.map(list, &{action, &1}) end)
    |> Flow.partition()
    |> Flow.reduce(fn -> [] end, fn {action, elem}, acc -> [action(action, elem) | acc] end)
    |> Enum.to_list()
  end

  @spec action(:created | :deleted | :changed, binary()) :: :ok
  defp action(:created, file) do
    with {:ok, _server} <-
           Siblings.start_child(
             Eblox.Data.PostFSM,
             file,
             %{file: Path.join([Eblox.Application.content_dir(), file])},
             interval: random_interval()
           ),
         do: :ok
  end

  defp action(:deleted, file) do
    Siblings.transition(file, :delete, nil)
  end

  defp action(:changed, file) do
    Siblings.transition(file, :parse, nil)
  end
end
