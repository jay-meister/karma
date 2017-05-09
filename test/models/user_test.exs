defmodule Karma.UserTest do
  use Karma.ModelCase

  alias Karma.User

  @valid_attrs %{email: "test@test.com", first_name: "Joe", last_name: "Blogs", password: "123456"}
  @invalid_attrs %{}
  @valid_account_creation %{email: "test@test.com", first_name: "Joe", last_name: "Blogs", password: "123456"}
  @invalid_account_creation %{email: "testtest.com", first_name: "Joe", last_name: "Blogs", password: "12345"}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "registration changeset with valid password" do
    changeset = User.registration_changeset(%User{}, @valid_account_creation)
    assert changeset.valid?
  end

  test "registration changeset with invalid password and email" do
    changeset = User.registration_changeset(%User{}, @invalid_account_creation)
    refute changeset.valid?

    # ensure email and password have failed
    %{errors: errors} = changeset
    Keyword.has_key?(errors, :password)
    Keyword.has_key?(errors, :email)
  end
end
