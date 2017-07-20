defmodule RedditClone.CommentControllerTest do
  use RedditClone.ConnCase

  alias RedditClone.Comment
  @valid_attrs %{text: "some content"}
  @invalid_attrs %{text: ""}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
    user = insert(:user_login)
    auth_conn = Guardian.Plug.api_sign_in(conn, user)
    jwt = Guardian.Plug.current_token(auth_conn)
    {:ok, %{conn: conn, auth_conn: auth_conn, jwt: jwt}}
  end

  test "shows chosen resource", %{conn: conn} do
    post_user = insert(:user)
    comment_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    comment = insert(:comment, user: comment_user, post: post)
    conn = get conn, comment_path(conn, :show, comment)

    assert json_response(conn, 200)["data"] == %{
      "id" => comment.id,
      "text" => comment.text,
      "rating" => 0,
      "user" => %{
        "id" => comment_user.id,
        "username" => comment_user.username,
      },
      "post_id" => post.id,
    }

    doc(conn)
  end

  test "creates and renders resource when data is valid", %{auth_conn: conn} do
    conn = post conn, comment_path(conn, :create), comment: @valid_attrs

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Comment, @valid_attrs)

    doc(conn)
  end

  test "does not create resource and renders errors when data is invalid", %{auth_conn: conn} do
    conn = post conn, comment_path(conn, :create), comment: @invalid_attrs

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{auth_conn: conn} do
    post_user = insert(:user)
    comment_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    comment = insert(:comment, user: comment_user, post: post)
    conn = put conn, comment_path(conn, :update, comment), comment: @valid_attrs

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Comment, @valid_attrs)

    doc(conn)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{auth_conn: conn} do
    post_user = insert(:user)
    comment_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    comment = insert(:comment, user: comment_user, post: post)
    conn = put conn, comment_path(conn, :update, comment), comment: @invalid_attrs

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{auth_conn: conn} do
    post_user = insert(:user)
    comment_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    comment = insert(:comment, user: comment_user, post: post)
    conn = delete conn, comment_path(conn, :delete, comment)

    assert response(conn, 204)
    refute Repo.get(Comment, comment.id)

    doc(conn)
  end

  test "rate comment", %{auth_conn: conn} do
    comment_user = insert(:user)
    rating_user = insert(:user2)
    post = insert(:post_with_url, user: comment_user)
    comment = insert(:comment, user: comment_user, post: post)
    _rating = insert(:comment_rating_up, user: rating_user, comment: comment)
    conn = get conn, comment_path(conn, :show, comment)

    assert json_response(conn, 200)["data"] == %{
      "id" => comment.id,
      "text" => comment.text,
      "rating" => 1,
      "post_id" => post.id,
      "user" => %{
        "id" => comment_user.id,
        "username" => comment_user.username,
      },
    }

    doc(conn)
  end

  test "rate nonexistent comment", %{auth_conn: conn} do
    rate_conn = put conn, comment_rate_path(conn, :rate_comment, 0, %{comment_rating: %{rating: 1}})

    assert json_response(rate_conn, 404)["errors"] != %{}

    doc(rate_conn)
  end

  test "add positive comment rating", %{auth_conn: conn} do
    rating_user = insert(:user)
    add_comment_rating(conn, rating_user, 1)
    |> assert_comment_rating(conn, %{expected_rating: 1, expected_total: 1})
  end

  test "add negative comment rating", %{auth_conn: conn} do
    rating_user = insert(:user)
    add_comment_rating(conn, rating_user, -1)
    |> assert_comment_rating(conn, %{expected_rating: -1, expected_total: -1})
  end

  test "add invalid comment rating", %{auth_conn: conn} do
    rating_user = insert(:user)
    %{rate_conn: rate_conn} = add_comment_rating(conn, rating_user, 5)

    assert json_response(rate_conn, 422)["errors"] != %{}
  end

  test "add positive rating twice with the same user", %{auth_conn: conn} do
    rating_user = insert(:user)
    add_comment_rating(conn, rating_user, 1)
    |> assert_comment_rating(conn, %{expected_rating: 1, expected_total: 1})

    add_comment_rating(conn, rating_user, 1)
    |> assert_comment_rating(conn, %{expected_rating: 1, expected_total: 1})
  end

  test "add negative rating twice with the same user", %{auth_conn: conn} do
    rating_user = insert(:user)
    add_comment_rating(conn, rating_user, -1)
    |> assert_comment_rating(conn, %{expected_rating: -1, expected_total: -1})

    add_comment_rating(conn, rating_user, -1)
    |> assert_comment_rating(conn, %{expected_rating: -1, expected_total: -1})
  end

  test "add positive rating twice with different users", %{auth_conn: conn} do
    rating1_user = insert(:user)
    rating1_result = add_comment_rating(conn, rating1_user, 1)
    assert_comment_rating(rating1_result, conn, %{expected_rating: 1, expected_total: 1})

    rating2_user = insert(:user2)
    add_comment_rating(conn, rating2_user, 1, rating1_result.comment)
    |> assert_comment_rating(conn, %{expected_rating: 1, expected_total: 2})
  end

  test "add negative rating twice with different users", %{auth_conn: conn} do
    rating1_user = insert(:user)
    rating1_result = add_comment_rating(conn, rating1_user, -1)
    assert_comment_rating(rating1_result, conn, %{expected_rating: -1, expected_total: -1})

    rating2_user = insert(:user2)
    add_comment_rating(conn, rating2_user, -1, rating1_result.comment)
    |> assert_comment_rating(conn, %{expected_rating: -1, expected_total: -2})
  end

  defp add_comment_rating(conn, rating_user, rating_value, comment \\ nil) do
    post_user = insert(:user2)
    post = insert(:post_with_url, user: post_user)
    rated_comment = if comment == nil, do: insert(:comment, user: rating_user, post: post), else: comment
    rate_conn = put conn, comment_rate_path(conn, :rate_comment, rated_comment.id, %{comment_rating: %{rating: rating_value}})
    %{
      rate_conn: rate_conn,
      comment: rated_comment,
    }
  end

  defp assert_comment_rating(
    %{rate_conn: rate_conn, comment: comment},
    conn,
    %{expected_rating: expected_rating, expected_total: expected_total},
    response_code \\ 200
  ) do
    assert json_response(rate_conn, response_code)["data"] == %{
      "rating" => expected_rating
    }
    comment_conn = get conn, comment_path(conn, :show, comment)

    assert json_response(comment_conn, 200)["data"]["rating"] == expected_total
  end
end
