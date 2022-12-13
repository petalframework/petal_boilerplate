defmodule PetalBoilerplateWeb.PageController do
  use PetalBoilerplateWeb, :controller

  def home(conn, _params) do
    render(conn, :home, active_tab: :home)
  end
end
