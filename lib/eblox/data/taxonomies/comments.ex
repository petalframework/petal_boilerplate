defmodule Eblox.Data.Taxonomies.Comments do
  @moduledoc """
  Data taxonomy implementation for post's comments tree.
  """

  alias Eblox.Data.Taxonomy

  @behaviour Taxonomy

  @impl Taxonomy
  def registry_options(opts \\ []) do
    Keyword.merge([keys: :duplicate, name: __MODULE__], opts)
  end

  @impl Taxonomy
  def on_add(registry, post_id) do
    # TODO: Get parent ID from the payload when it's available.
    %{file: parent_id} = Siblings.payload(Eblox.Data.Content, post_id)

    registry
    |> Registry.register(parent_id, post_id)
    |> elem(0)
  end

  @impl Taxonomy
  def on_remove(registry, post_id) do
    # TODO: Get parent ID from the payload when it's available.
    %{file: parent_id} = Siblings.payload(Eblox.Data.Content, post_id)

    Registry.unregister_match(registry, parent_id, post_id)
  end
end
