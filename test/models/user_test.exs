defmodule Karma.UserTest do
  use Karma.ModelCase

  alias Karma.User

  @invalid_attrs %{}
  @valid_account_creation %{email: "test@test.com", first_name: "Joe", last_name: "Blogs", password: "123456"}
  @invalid_account_creation %{email: "testtest.com", first_name: "Joe", last_name: "Blogs", password: "12345"}

  # Generic user changeset tests
  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_account_creation)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end


  # Account creation tests
  test "registration changeset with valid password" do
    changeset = User.registration_changeset(%User{}, @valid_account_creation)

    %{changes: changes} = changeset

    # ensure password_hash has been added
    assert Map.has_key?(changes, :password_hash)

    # ensure password has been hashed
    refute changes.password_hash == "123456"
    assert changeset.valid?
  end

  test "changeset is invalid if email is used already" do
    changeset = User.registration_changeset(%User{}, @valid_account_creation)
    # insert a user
    Karma.Repo.insert!(changeset)
    # attempt to insert a user with same email
    assert {:error, changeset} = Repo.insert(changeset)
    assert {"has already been taken", _} = changeset.errors[:email]
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
