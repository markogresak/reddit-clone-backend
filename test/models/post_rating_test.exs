defmodule RedditClone.PostRatingTest do
  use RedditClone.ModelCase

  alias RedditClone.PostRating

  @valid_attrs [%{rating: 1}, %{rating: -1}]
  @invalid_attrs [%{rating: 0}, %{rating: 5}, %{rating: -3}]

  test "changeset with valid attributes" do
    Enum.each(@valid_attrs, fn(attr) ->
      changeset = PostRating.changeset(%PostRating{}, attr)
      assert changeset.valid?
    end)
  end

  test "changeset with invalid attributes" do
    Enum.each(@invalid_attrs, fn(attr) ->
      changeset = PostRating.changeset(%PostRating{}, attr)
      refute changeset.valid?
    end)
  end
end
