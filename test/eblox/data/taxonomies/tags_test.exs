defmodule Eblox.Data.Taxonomies.TagsTest do
  use Eblox.ContentCase

  @provider Eblox.Data.Providers.FileSystem
  @taxonomy Eblox.Data.Taxonomies.Tags
  @content_dir "test/fixtures/tags_content"

  @moduletag providers: [
               {Eblox.Data.Provider, impl: @provider, content_dir: @content_dir, interval: 10}
             ],
             taxonomies: [
               {Eblox.Data.Taxonomy, impl: @taxonomy}
             ]

  alias Eblox.Data.Taxonomy

  def post_id(id), do: "#{@content_dir}/#{id}"

  test "taxonomy with tags" do
    # TODO: Wait until parsing is completed.
    Process.sleep(100)

    Enum.each(~w|post-1 post-2 post-3 post-4 post-5|, fn name ->
      Taxonomy.add(@taxonomy, post_id(name))
    end)

    assert [post_id("post-1"), post_id("post-3"), post_id("post-4")] ==
             @taxonomy |> Taxonomy.lookup("fox") |> Enum.sort()

    assert [post_id("post-1"), post_id("post-3")] ==
             @taxonomy |> Taxonomy.lookup("dog") |> Enum.sort()

    assert [post_id("post-2"), post_id("post-3")] ==
             @taxonomy |> Taxonomy.lookup("βδελυγμία") |> Enum.sort()

    assert ["dog", "fox", "βδελυγμία"] ==
             @taxonomy |> Taxonomy.keys() |> Enum.sort()
  end
end
