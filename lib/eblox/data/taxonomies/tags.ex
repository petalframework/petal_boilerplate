defmodule Eblox.Data.Taxonomies.Tags do
  @moduledoc """
  Data taxonomy implementation for post lists by tags.
  """

  alias Eblox.Data.Taxonomy

  @behaviour Taxonomy

  @impl Taxonomy
  def registry_options(opts \\ []) do
    Keyword.merge([keys: :duplicate, name: __MODULE__], opts)
  end

  @impl Taxonomy
  def on_add(registry, post_id) do
    %{properties: %{tags: tags}} = Siblings.payload(Eblox.Data.Content, post_id)

    Enum.each(tags, &Registry.register(registry, &1, post_id))
  end

  @impl Taxonomy
  def on_remove(registry, post_id) do
    %{properties: %{tags: tags}} = Siblings.payload(Eblox.Data.Content, post_id)

    Enum.each(tags, &Registry.unregister_match(registry, &1, post_id))
  end
end
