defmodule RedditClone.CommentRatingTest do
  use RedditClone.ModelCase

  alias RedditClone.CommentRating

  @valid_attrs [%{rating: 1}, %{rating: -1}]
  @invalid_attrs [%{rating: 0}, %{rating: 5}, %{rating: -3}]

  test "changeset with valid attributes" do
    Enum.each(@valid_attrs, fn(attr) ->
      changeset = CommentRating.changeset(%CommentRating{}, attr)
      assert changeset.valid?
    end)
  end

  test "changeset with invalid attributes" do
    Enum.each(@invalid_attrs, fn(attr) ->
      changeset = CommentRating.changeset(%CommentRating{}, attr)
      refute changeset.valid?
    end)
  end
end
