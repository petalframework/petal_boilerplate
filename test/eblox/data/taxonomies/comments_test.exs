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

    root_id = "root"
    post_1_id = post_id("post-1")
    post_2_id = post_id("post-2")
    comment_1_1_id = post_id("post-1-children/comment-1-1")
    comment_1_2_id = post_id("post-1-children/comment-1-2")
    comment_1_2_1_id = post_id("post-1-children/comment-1-2-children/comment-1-2-1")

    Enum.each([post_1_id, post_2_id, comment_1_1_id, comment_1_2_id, comment_1_2_1_id], fn name ->
      Taxonomy.add(@taxonomy, name)
    end)

    assert [post_1_id, post_2_id] == Taxonomy.lookup(@taxonomy, root_id) |> Enum.sort()

    assert [comment_1_1_id, comment_1_2_id] ==
             Taxonomy.lookup(@taxonomy, post_1_id) |> Enum.sort()

    assert [] == Taxonomy.lookup(@taxonomy, post_2_id)
    assert [] == Taxonomy.lookup(@taxonomy, comment_1_1_id)
    assert [comment_1_2_1_id] == Taxonomy.lookup(@taxonomy, comment_1_2_id)
  end
end
