defmodule Eblox.Data.Taxonomies.Comments do
  @moduledoc """
  Data taxonomy implementation for post's comments tree.
  """

  alias Eblox.Data.Taxonomy

  @behaviour Taxonomy

  @root_id "root"

  @impl Taxonomy
  def registry_options(opts \\ []) do
    Keyword.merge([keys: :duplicate, name: __MODULE__], opts)
  end

  @impl Taxonomy
  def on_add(registry, post_id) do
    parent_id = post_parent_id(post_id)

    registry
    |> Registry.register(parent_id, post_id)
    |> elem(0)
  end

  @impl Taxonomy
  def on_remove(registry, post_id) do
    parent_id = post_parent_id(post_id)

    Registry.unregister_match(registry, parent_id, post_id)
  end

  defp post_parent_id(post_id) do
    case Siblings.payload(Eblox.Data.Content, post_id) do
      %{properties: %{links: [parent_id]}} -> parent_id
      _ -> @root_id
    end
  end
end
