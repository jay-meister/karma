defmodule Karma.TestHelpers do
  alias Karma.{Repo, User}

  @user_id 1

  def id() do
    %{user: @user_id}
  end

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(
      %{first_name: "Joe",
        last_name: "Blogs",
        email: "test@test.com",
        password: "123456"},
        attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!
  end

  def login_user(conn, user) do
      conn
      |> Plug.Conn.assign(:current_user, user)
  end
end
