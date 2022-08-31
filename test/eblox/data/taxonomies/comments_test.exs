defmodule Eblox.Data.Taxonomies.CommentsTest do
  use Eblox.ContentCase

  @provider Eblox.Data.Providers.FileSystem
  @taxonomy Eblox.Data.Taxonomies.Comments
  @content_dir "test/fixtures/comments_content"

  @moduletag providers: [
               {Eblox.Data.Provider, impl: @provider, content_dir: @content_dir, interval: 10}
             ],
             taxonomies: [
               {Eblox.Data.Taxonomy, impl: @taxonomy}
             ]

  alias Eblox.Data.Taxonomy

  def post_id(id), do: "#{@content_dir}/#{id}"

  test "taxonomy with comments" do
    # TODO: Wait until parsing is completed.
    Process.sleep(100)

    Enum.each(~w|post-1 post-2 comment-1-1 comment-1-2 comment-1-2-1|, fn name ->
      Taxonomy.add(@taxonomy, post_id(name))
    end)

    assert [post_id("post-1")] == Taxonomy.lookup(@taxonomy, post_id("post-1"))

    Taxonomy.remove(@taxonomy, post_id("comment-1-1"))

    assert [] == Taxonomy.lookup(@taxonomy, post_id("comment-1-1"))
  end
end
