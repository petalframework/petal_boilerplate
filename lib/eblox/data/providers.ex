defmodule Eblox.Data.Providers do
  @moduledoc """
  Supervisor for all data providers.
  """

  use Supervisor

  def start_link(providers),
    do: Supervisor.start_link(__MODULE__, providers)

  @impl Supervisor
  def init(providers) do
    children = [
      Siblings.child_spec(name: Eblox.Data.Providers, workers: providers),
      Siblings.child_spec(name: Eblox.Data.Content)
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
