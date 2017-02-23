defmodule RedditClone.PostControllerTest do
  use RedditClone.ConnCase

  alias RedditClone.Post
  @valid_attrs %{title: "some title", text: "some content"}
  @invalid_attrs %{title: ""}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
    user = insert(:user_login)
    auth_conn = Guardian.Plug.api_sign_in(conn, user)
    jwt = Guardian.Plug.current_token(auth_conn)
    {:ok, %{conn: conn, auth_conn: auth_conn, jwt: jwt, user: user}}
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
      "user_id" => user.id,
      "comments" => [],
      "comment_count" => RedditClone.Post.comment_count(post),
      "rating" => RedditClone.Post.total_rating(post),
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
      "user_id" => user.id,
      "comments" => [],
      "comment_count" => RedditClone.Post.comment_count(post),
      "rating" => RedditClone.Post.total_rating(post),
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
      "user_id" => post_user.id,
      "comments" => [
        %{
          "id" => comment.id,
          "text" => comment.text,
          "user_id" => comment_user.id,
          "post_id" => post.id,
        }
      ],
      "comment_count" => RedditClone.Post.comment_count(post),
      "rating" => RedditClone.Post.total_rating(post),
    }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{auth_conn: conn} do
    conn = post conn, post_path(conn, :create), post: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Post, title: @valid_attrs.title)
  end

  test "does not create resource and renders errors when data is invalid", %{auth_conn: conn} do
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{auth_conn: conn} do
    user = insert(:user)
    post = insert(:post_with_url, user: user)
    conn = put conn, post_path(conn, :update, post), post: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Post, title: @valid_attrs.title)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{auth_conn: conn} do
    user = insert(:user)
    post = insert(:post_with_url, user: user)
    conn = put conn, post_path(conn, :update, post), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{auth_conn: conn} do
    user = insert(:user)
    post = insert(:post_with_url, user: user)
    conn = delete conn, post_path(conn, :delete, post)
    assert response(conn, 204)
    refute Repo.get(Post, post.id)
  end

  test "rate post", %{auth_conn: conn} do
    post_user = insert(:user)
    rating_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    _rating = insert(:post_rating_up, user: rating_user, post: post)
    conn = get conn, post_path(conn, :show, post)
    assert json_response(conn, 200)["data"] == %{
      "id" => post.id,
      "title" => post.title,
      "text" => nil,
      "url" => post.url,
      "user_id" => post_user.id,
      "comments" => [],
      "comment_count" => 0,
      "rating" => 1,
    }
  end

  test "rate nonexistent post", %{auth_conn: conn} do
    rate_conn = put conn, post_rate_path(conn, :rate_post, 0, %{post_rating: %{rating: 1}})
    assert json_response(rate_conn, 404)["errors"] != %{}
  end

  test "add positive post rating", %{auth_conn: conn} do
    rating_user = insert(:user)
    add_post_rating(conn, rating_user, 1)
    |> assert_post_rating(conn, %{expected_rating: 1, expected_total: 1})
  end

  test "add negative post rating", %{auth_conn: conn} do
    rating_user = insert(:user)
    add_post_rating(conn, rating_user, -1)
    |> assert_post_rating(conn, %{expected_rating: -1, expected_total: -1})
  end

  test "add invalid post rating", %{auth_conn: conn} do
    rating_user = insert(:user)
    %{rate_conn: rate_conn} = add_post_rating(conn, rating_user, 5)
    assert json_response(rate_conn, 422)["errors"] != %{}
  end

  test "add positive rating twice with the same user", %{auth_conn: conn} do
    rating_user = insert(:user)
    add_post_rating(conn, rating_user, 1)
    |> assert_post_rating(conn, %{expected_rating: 1, expected_total: 1})

    add_post_rating(conn, rating_user, 1)
    |> assert_post_rating(conn, %{expected_rating: 1, expected_total: 1})
  end

  test "add negative rating twice with the same user", %{auth_conn: conn} do
    rating_user = insert(:user)
    add_post_rating(conn, rating_user, -1)
    |> assert_post_rating(conn, %{expected_rating: -1, expected_total: -1})

    add_post_rating(conn, rating_user, -1)
    |> assert_post_rating(conn, %{expected_rating: -1, expected_total: -1})
  end

  test "add positive rating twice with different users", %{auth_conn: conn} do
    rating1_user = insert(:user)
    rating1_result = add_post_rating(conn, rating1_user, 1)
    assert_post_rating(rating1_result, conn, %{expected_rating: 1, expected_total: 1})

    rating2_user = insert(:user2)
    add_post_rating(conn, rating2_user, 1, rating1_result.post)
    |> assert_post_rating(conn, %{expected_rating: 1, expected_total: 2})
  end

  test "add negative rating twice with different users", %{auth_conn: conn} do
    rating1_user = insert(:user)
    rating1_result = add_post_rating(conn, rating1_user, -1)
    assert_post_rating(rating1_result, conn, %{expected_rating: -1, expected_total: -1})

    rating2_user = insert(:user2)
    add_post_rating(conn, rating2_user, -1, rating1_result.post)
    |> assert_post_rating(conn, %{expected_rating: -1, expected_total: -2})
  end

  defp add_post_rating(conn, rating_user, rating_value, post \\ nil) do
    rated_post = if post == nil, do: insert(:post_with_url, user: rating_user), else: post
    rate_conn = put conn, post_rate_path(conn, :rate_post, rated_post.id, %{post_rating: %{rating: rating_value}})
    %{
      rate_conn: rate_conn,
      post: rated_post,
    }
  end

  defp assert_post_rating(
    %{rate_conn: rate_conn, post: post},
    conn,
    %{expected_rating: expected_rating, expected_total: expected_total},
    response_code \\ 200
  ) do
    assert json_response(rate_conn, response_code)["data"] == %{
      "rating" => expected_rating
    }
    post_conn = get conn, post_path(conn, :show, post)
    assert json_response(post_conn, 200)["data"]["rating"] == expected_total
  end
end
