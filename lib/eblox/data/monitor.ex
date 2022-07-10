defmodule Eblox.Data.Monitor do
  use GenServer
  use Estructura, access: true

  alias Eblox.Data.Monitor, as: State

  @default_interval 60_000

  @type md5 :: binary()
  @type message :: %{created: [Path.t()], deleted: [Path.t()], changed: [Path.t()]}

  @type t :: %{
          __struct__: __MODULE__,
          directory: Path.t(),
          files: %{Path.t() => md5()},
          interval: non_neg_integer(),
          listener: (message() -> :ok | {:error, any()}),
          schedule: nil | reference()
        }

  @callback on_content_change(message()) :: :ok | {:error, any()}

  defstruct directory: "",
            files: %{},
            interval: @default_interval,
            schedule: nil,
            listener: &Eblox.Data.Listener.on_content_change/1

  def start_link(opts \\ []) do
    {directory, opts} = Keyword.pop!(opts, :content)

    {interval, opts} = Keyword.pop(opts, :interval)
    interval = if is_integer(interval) and interval >= 0, do: interval, else: @default_interval

    {listener, opts} = Keyword.pop(opts, :listener, Eblox.Data.Listener)

    listener =
      case listener do
        l when is_function(l, 1) -> l
        m when is_atom(m) -> Function.capture(m, :on_content_change, 1)
      end

    GenServer.start_link(
      __MODULE__,
      %State{directory: directory, listener: listener, interval: interval},
      opts
    )
  end

  # Callbacks

  @impl GenServer
  def init(%State{} = state) do
    {:noreply, state} = handle_info(:work, state)
    {:ok, state}
  end

  @doc false
  @impl GenServer
  def handle_info(:work, %State{} = state) do
    files = state.directory |> file_list() |> list_to_state(state.directory)

    files
    |> diff(state.files)
    |> state.listener.()

    if is_reference(state.schedule), do: Process.cancel_timer(state.schedule)
    {:noreply, %State{state | files: files, schedule: schedule_work(state.interval)}}
  end

  @spec file_list(Path.t()) :: %{Path.t() => md5()}
  defp file_list(directory) do
    dig = fn
      {:ok, files}, path -> Enum.flat_map(files, &file_list("#{path}/#{&1}"))
      {:error, _}, path -> [path]
    end

    if String.contains?(directory, ".git"), do: [], else: dig.(File.ls(directory), directory)
  end

  @spec list_to_state([Path.t()], binary()) :: %{Path.t() => md5()}
  defp list_to_state(files, root) do
    for file <- files,
        {:ok, content} <- [File.read(file)],
        into: %{},
        do: {String.trim_leading(file, root), md5(content)}
  end

  @spec diff(%{Path.t() => md5()}, %{Path.t() => md5()}) :: message()
  defp diff(map, map), do: %{created: [], deleted: [], changed: []}

  defp diff(new, old) do
    keys = MapSet.new(Map.keys(new) ++ Map.keys(old))

    Enum.reduce(keys, diff(%{}, %{}), fn key, acc ->
      case {Map.fetch(new, key), Map.fetch(old, key)} do
        {{:ok, value}, {:ok, value}} -> acc
        {:error, {:ok, _}} -> %{acc | deleted: [key | acc.deleted]}
        {{:ok, _}, :error} -> %{acc | created: [key | acc.created]}
        {{:ok, _}, {:ok, _}} -> %{acc | changed: [key | acc.changed]}
      end
    end)
  end

  @spec md5(binary()) :: <<_::256>>
  def md5(content) do
    :md5
    |> :crypto.hash(content)
    |> Base.encode16(case: :lower)
  end

  @doc false
  @spec schedule_work(interval :: non_neg_integer()) :: :error | reference()
  defp schedule_work(interval) when is_integer(interval) and interval > 0,
    do: Process.send_after(self(), :work, interval)

  defp schedule_work(_interval), do: :error
end
