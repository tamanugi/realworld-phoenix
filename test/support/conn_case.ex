defmodule RealworldPhoenixWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use RealworldPhoenixWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias RealworldPhoenix.Accounts

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import RealworldPhoenixWeb.ConnCase

      alias RealworldPhoenixWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint RealworldPhoenixWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RealworldPhoenix.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(RealworldPhoenix.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def put_authorization(%Plug.Conn{} = conn, user \\ nil) do
    user =
      case user do
        %RealworldPhoenix.Accounts.User{} ->
          user

        _ ->
          {:ok, user} = Accounts.create_user(%{username: "hoge", email: "hoge", password: "hoge"})
          user
      end

    {:ok, token, _} = RealworldPhoenix.Guardian.encode_and_sign(user, %{})

    conn
    |> Plug.Conn.put_req_header("authorization", "Token " <> token)
  end
end
