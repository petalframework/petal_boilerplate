defmodule EbloxWeb.PostController do
  use EbloxWeb, :controller

  def show(conn, %{"id" => [<<year::binary-size(4), _::binary>> = id]}) do
    html =
      case Siblings.payload(Eblox.Siblings, Path.join(year, id)) do
        %{html: html} -> html
        other -> "<b font-color='white'>#{inspect(other)}</b>"
      end

    render(conn, "show.html", content: html)
  end
end
