defmodule RedditClone.UserControllerTest do
  use RedditClone.ConnCase

  alias RedditClone.User
  @valid_attrs %{username: "some_user", password: "pass123"}
  @invalid_attrs %{username: "", password: ""}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
    user = insert(:user_login)
    auth_conn = Guardian.Plug.api_sign_in(conn, user)
    jwt = Guardian.Plug.current_token(auth_conn)
    {:ok, %{conn: conn, auth_conn: auth_conn, jwt: jwt}}
  end

  test "login", %{conn: conn} do
    user = insert(:user)
    # password copied from factory for testing simplicity
    conn = post conn, user_path(conn, :login, %{username: user.username, password: "pass1234"})
    assert json_response(conn, 200)["data"]["user"] == %{
      "id" => user.id,
      "username" => user.username,
    }

    assert json_response(conn, 200)["data"]["jwt"]
    assert json_response(conn, 200)["data"]["exp"]

    doc(conn)
  end

  test "login with wrong password", %{conn: conn} do
    user = insert(:user)
    conn = post conn, user_path(conn, :login, %{username: user.username, password: "wrong_pass"})

    assert json_response(conn, 401)["error"]
  end

  test "shows chosen user", %{auth_conn: conn} do
    user = insert(:user)
    conn = get conn, user_path(conn, :show, user)

    assert json_response(conn, 200)["data"] == %{
      "id" => user.id,
      "username" => user.username,
      "posts" => [],
      "comments" => []
    }
  end

  test "shows chosen user who has added a post", %{auth_conn: conn} do
    user = insert(:user)
    post = insert(:post_with_text, user: user)
    conn = get conn, user_path(conn, :show, user)

    assert json_response(conn, 200)["data"] == %{
      "id" => user.id,
      "username" => user.username,
      "posts" => [
        %{
          "id" => post.id,
          "title" => post.title,
          "url" => post.url,
          "user" => %{
            "id" => user.id,
            "username" => user.username,
          },
          "submitted_at" => NaiveDateTime.to_iso8601(post.inserted_at),
          "comment_count" => RedditClone.Post.comment_count(post),
          "rating" => RedditClone.Post.total_rating(post),
        }
      ],
      "comments" => []
    }
  end

  test "shows chosen user who has added a post and commented", %{conn: conn} do
    user = insert(:user)
    post = insert(:post_with_text, user: user)
    comment = insert(:comment, user: user, post: post)
    conn = get conn, user_path(conn, :show, user)

    assert json_response(conn, 200)["data"] == %{
      "id" => user.id,
      "username" => user.username,
      "posts" => [
        %{
          "id" => post.id,
          "title" => post.title,
          "url" => post.url,
          "user" => %{
            "id" => user.id,
            "username" => user.username,
          },
          "submitted_at" => NaiveDateTime.to_iso8601(post.inserted_at),
          "comment_count" => RedditClone.Post.comment_count(post),
          "rating" => RedditClone.Post.total_rating(post),
        }
      ],
      "comments" => [
        %{
          "id" => comment.id,
          "text" => comment.text,
          "rating" => 0,
          "user" => %{
            "id" => user.id,
            "username" => user.username,
          },
          "post_id" => post.id,
          "parent_comment_id" => nil,
          "submitted_at" => NaiveDateTime.to_iso8601(comment.inserted_at),
        }
      ]
    }

    doc(conn)
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{auth_conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, username: @valid_attrs.username)

    doc(conn)
  end

  test "does not create resource and renders errors when data is invalid", %{auth_conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{auth_conn: conn} do
    user = insert(:user)
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(User, username: @valid_attrs.username)

    doc(conn)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{auth_conn: conn} do
    user = insert(:user)
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{auth_conn: conn} do
    user = insert(:user)
    conn = delete conn, user_path(conn, :delete, user)

    assert response(conn, 204)
    refute Repo.get(User, user.id)

    doc(conn)
  end
end
