defmodule Eblox.Data do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(directory),
    do: Supervisor.start_link(__MODULE__, directory, name: __MODULE__)

  @impl Supervisor
  def init(directory) do
    children = [
      Siblings,
      {Eblox.Data.Monitor, content: directory}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
