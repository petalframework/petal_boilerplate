defmodule PetalBoilerplateWeb.PageControllerTest do
  use PetalBoilerplateWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Petal"
  end
end
