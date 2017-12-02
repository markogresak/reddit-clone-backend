defmodule RedditClone.ApiAuthErrorHandlerController do
  use RedditClone.Web, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> render(RedditClone.ApiAuthErrorHandlerView, "show.json", error: "unauthenticated")
  end
end
