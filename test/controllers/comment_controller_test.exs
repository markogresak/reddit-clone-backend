defmodule RedditClone.CommentControllerTest do
  use RedditClone.ConnCase

  alias RedditClone.Comment
  @valid_attrs %{text: "some content"}
  @invalid_attrs %{text: ""}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "shows chosen resource", %{conn: conn} do
    post_user = insert(:user)
    comment_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    comment = insert(:comment, user: comment_user, post: post)
    conn = get conn, comment_path(conn, :show, comment)
    assert json_response(conn, 200)["data"] == %{"id" => comment.id,
      "text" => comment.text,
      "user_id" => comment.user_id,
      "post_id" => comment.post_id}
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, comment_path(conn, :create), comment: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Comment, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, comment_path(conn, :create), comment: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    post_user = insert(:user)
    comment_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    comment = insert(:comment, user: comment_user, post: post)
    conn = put conn, comment_path(conn, :update, comment), comment: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Comment, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    post_user = insert(:user)
    comment_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    comment = insert(:comment, user: comment_user, post: post)
    conn = put conn, comment_path(conn, :update, comment), comment: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    post_user = insert(:user)
    comment_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    comment = insert(:comment, user: comment_user, post: post)
    conn = delete conn, comment_path(conn, :delete, comment)
    assert response(conn, 204)
    refute Repo.get(Comment, comment.id)
  end
end
