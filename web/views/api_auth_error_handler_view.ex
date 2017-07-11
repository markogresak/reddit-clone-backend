defmodule RedditClone.ApiAuthErrorHandlerView do
  use RedditClone.Web, :view

  def render("show.json", %{error: error}) do
    %{
      error: %{message: error}
    }
  end
end
