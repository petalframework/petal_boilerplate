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
    for {action, list} <- changes, elem <- list, do: action(action, elem)
  end

  def action(:created, file) do
    with {:ok, _server} <-
           Siblings.start_child(
             Eblox.Data.PostFSM,
             file,
             %{file: Path.join([Eblox.Application.content_dir(), file])},
             interval: random_interval()
           ),
         do: :ok
  end

  def action(:deleted, file) do
    Siblings.transition(file, :delete, nil)
  end

  def action(:changed, file) do
    Siblings.transition(file, :parse, nil)
  end
end
