defmodule RealworldPhoenixWeb.UserControllerTest do
  use RealworldPhoenixWeb.ConnCase

  alias RealworldPhoenix.Accounts
  alias RealworldPhoenix.Accounts.User

  @create_attrs %{
    bio: "some bio",
    email: "some email",
    image: "some image",
    username: "some username",
    password: "hogehogehoge"
  }
  @update_attrs %{
    bio: "some updated bio",
    email: "some updated email",
    image: "some updated image",
    username: "some updated username"
  }
  @invalid_attrs %{bio: nil, email: nil, image: nil, username: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "bio" => "some bio",
               "email" => "some email",
               "image" => "some image",
               "username" => "some username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "bio" => "some updated bio",
               "email" => "some updated email",
               "image" => "some updated image",
               "username" => "some updated username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  describe "login" do
    setup [:create_user]

    test "login success valid password", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_path(conn, :login), email: user.email, password: "hogehogehoge")

      assert response(conn, 200)
    end

    test "login failed invalid password", %{conn: conn, user: user} do
      conn = post(conn, Routes.user_path(conn, :login), email: user.email, password: "hogehoge")

      assert response(conn, 401)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
