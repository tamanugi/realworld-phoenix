defmodule RealworldPhoenixWeb.UserController do
  use RealworldPhoenixWeb, :controller

  alias RealworldPhoenix.Accounts
  alias RealworldPhoenix.Accounts.User

  action_fallback RealworldPhoenixWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    user = Accounts.get_user_by_email(email)

    case Bcrypt.check_pass(user, password, hash_key: :password) do
      {:error, msg} -> send_resp(conn, :unauthorized, msg)
      _ -> render(conn, "show.json", user: user)
    end
  end
end
