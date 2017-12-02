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

    doc(conn)
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
      "user" => %{
        "id" => user.id,
        "username" => user.username,
      },
      "submitted_at" => NaiveDateTime.to_iso8601(post.inserted_at),
      "comments" => [],
      "comment_count" => RedditClone.Post.comment_count(post),
      "rating" => RedditClone.Post.total_rating(post),
      "user_post_rating" => nil,
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
      "user" => %{
        "id" => user.id,
        "username" => user.username,
      },
      "submitted_at" => NaiveDateTime.to_iso8601(post.inserted_at),
      "comments" => [],
      "comment_count" => RedditClone.Post.comment_count(post),
      "rating" => RedditClone.Post.total_rating(post),
      "user_post_rating" => nil,
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
      "user" => %{
        "id" => post_user.id,
        "username" => post_user.username,
      },
      "submitted_at" => NaiveDateTime.to_iso8601(post.inserted_at),
      "comments" => [
        %{
          "id" => comment.id,
          "text" => comment.text,
          "rating" => 0,
          "user" => %{
            "id" => comment_user.id,
            "username" => comment_user.username,
          },
          "post_id" => post.id,
          "parent_comment_id" => nil,
          "submitted_at" => NaiveDateTime.to_iso8601(comment.inserted_at),
        }
      ],
      "comment_count" => RedditClone.Post.comment_count(post),
      "rating" => RedditClone.Post.total_rating(post),
      "user_post_rating" => nil,
    }

    doc(conn)
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

    doc(conn)
  end

  test "does not create resource and renders errors when data is invalid", %{auth_conn: conn} do
    conn = post conn, post_path(conn, :create), post: @invalid_attrs

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{auth_conn: conn} do
    user = insert(:user)
    post = insert(:post_with_url, user: user)
    post_user_conn = Guardian.Plug.api_sign_in(conn, user)
    |> put(post_path(conn, :update, post), post: @valid_attrs)

    assert json_response(post_user_conn, 200)["data"]["id"]
    assert Repo.get_by(Post, title: @valid_attrs.title)

    doc(conn)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{auth_conn: conn} do
    user = insert(:user)
    post = insert(:post_with_url, user: user)
    post_user_conn = Guardian.Plug.api_sign_in(conn, user)
    |> put(post_path(conn, :update, post), post: @invalid_attrs)

    assert json_response(post_user_conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{auth_conn: conn} do
    user = insert(:user)
    post = insert(:post_with_url, user: user)
    conn = delete conn, post_path(conn, :delete, post)

    assert response(conn, 204)
    refute Repo.get(Post, post.id)

    doc(conn)
  end

  test "rate post", %{auth_conn: conn} do
    post_user = insert(:user)
    rating_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    _rating = insert(:post_rating_up, user: rating_user, post: post)
    rating_user_conn = Guardian.Plug.api_sign_in(conn, rating_user)
    |> get(post_path(conn, :show, post))

    assert json_response(rating_user_conn, 200)["data"] == %{
      "id" => post.id,
      "title" => post.title,
      "text" => nil,
      "url" => post.url,
      "user" => %{
        "id" => post_user.id,
        "username" => post_user.username,
      },
      "submitted_at" => NaiveDateTime.to_iso8601(post.inserted_at),
      "comments" => [],
      "comment_count" => 0,
      "rating" => 1,
      "user_post_rating" => 1,
    }

    doc(conn)
  end

  test "rate nonexistent post", %{auth_conn: conn} do
    rate_conn = put conn, post_rate_path(conn, :rate_post, 0, %{post_rating: %{rating: 1}})

    assert json_response(rate_conn, 404)["errors"] != %{}

    doc(rate_conn)
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
    rating_user_conn = Guardian.Plug.api_sign_in(conn, rating_user)
    rate_conn = put rating_user_conn, post_rate_path(conn, :rate_post, rated_post.id, %{post_rating: %{rating: rating_value}})
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
      "rating" => expected_rating,
      "post_id" => post.id,
      "post_rating" => RedditClone.Post.total_rating(post),
    }
    post_conn = get conn, post_path(conn, :show, post)

    assert json_response(post_conn, 200)["data"]["rating"] == expected_total
  end
end
