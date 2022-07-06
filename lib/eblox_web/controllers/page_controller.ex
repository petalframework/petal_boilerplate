defmodule EbloxWeb.PageController do
  use EbloxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
