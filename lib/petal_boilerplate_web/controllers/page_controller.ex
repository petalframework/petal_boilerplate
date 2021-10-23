defmodule PetalBoilerplateWeb.PageController do
  use PetalBoilerplateWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
