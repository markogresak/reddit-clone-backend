defmodule RedditClone.PostControllerTest do
  use RedditClone.ConnCase

  alias RedditClone.Post
  @valid_attrs %{title: "some title", text: "some content"}
  @invalid_attrs %{title: ""}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, post_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows post with text", %{conn: conn} do
    user = insert(:user)
    post = insert(:post_with_text, user: user)
    conn = get conn, post_path(conn, :show, post)
    assert json_response(conn, 200)["data"] == %{
      "id" => post.id,
      "title" => post.title,
      "text" => post.text,
      "url" => nil,
      "user_id" => post.user_id,
      "comments" => []
    }
  end

  test "shows post with url", %{conn: conn} do
    user = insert(:user)
    post = insert(:post_with_url, user: user)
    conn = get conn, post_path(conn, :show, post)
    assert json_response(conn, 200)["data"] == %{
      "id" => post.id,
      "title" => post.title,
      "text" => nil,
      "url" => post.url,
      "user_id" => post.user_id,
      "comments" => []
    }
  end

  test "shows post with a comment", %{conn: conn} do
    post_user = insert(:user)
    comment_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    comment = insert(:comment, user: comment_user, post: post)
    conn = get conn, post_path(conn, :show, post)
    assert json_response(conn, 200)["data"] == %{
      "id" => post.id,
      "title" => post.title,
      "text" => nil,
      "url" => post.url,
      "user_id" => post.user_id,
      "comments" => [
        %{
          "id" => comment.id,
          "text" => comment.text,
          "user_id" => comment.user_id,
          "post_id" => comment.post_id,
        }
      ]
    }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Post, title: @valid_attrs.title)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = insert(:user)
    post = insert(:post_with_url, user: user)
    conn = put conn, post_path(conn, :update, post), post: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Post, title: @valid_attrs.title)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = insert(:user)
    post = insert(:post_with_url, user: user)
    conn = put conn, post_path(conn, :update, post), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    user = insert(:user)
    post = insert(:post_with_url, user: user)
    conn = delete conn, post_path(conn, :delete, post)
    assert response(conn, 204)
    refute Repo.get(Post, post.id)
  end
end
