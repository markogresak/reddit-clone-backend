defmodule RedditClone.ApiAuthErrorHandlerController do
  use RedditClone.Web, :controller

  def unauthenticated(conn, _params) do
    render(conn, RedditClone.ApiAuthErrorHandlerView, "show.json", error: "unauthenticated")
  end
end
