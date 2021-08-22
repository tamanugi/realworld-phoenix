defmodule RealworldPhoenixWeb.UserControllerTest do
  use RealworldPhoenixWeb.ConnCase

  alias RealworldPhoenix.Accounts

  @create_attrs %{
    email: "some email",
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

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert %{
               "user" => %{
                 "bio" => nil,
                 "email" => "some email",
                 "image" => nil,
                 "username" => "some username"
               }
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: user} do
      conn =
        put_authorization(conn, user)
        |> put(Routes.user_path(conn, :update), user: @update_attrs)

      assert response(conn, 200)

      conn = get(conn, Routes.user_path(conn, :show))

      assert %{
               "user" => %{
                 "bio" => "some updated bio",
                 "email" => "some updated email",
                 "image" => "some updated image",
                 "username" => "some updated username",
                 "token" => token
               }
             } = json_response(conn, 200)

      assert is_binary(token)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        put_authorization(conn, user)
        |> put(Routes.user_path(conn, :update), user: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "login" do
    setup [:create_user]

    test "login success valid password", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_path(conn, :login),
          user: %{email: user.email, password: "hogehogehoge"}
        )

      assert response(conn, 200)

      %{"user" => %{"token" => token}} = json_response(conn, 200)

      conn =
        conn
        |> recycle()
        |> put_req_header("authorization", "Token " <> token)
        |> get(Routes.user_path(conn, :show))

      assert %{
               "user" => %{
                 "bio" => nil,
                 "email" => "some email",
                 "image" => nil,
                 "username" => "some username",
                 "token" => token
               }
             } = json_response(conn, 200)

      assert is_binary(token)
    end

    test "login failed invalid password", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_path(conn, :login),
          user: %{email: user.email, password: "hogehoge"}
        )

      assert response(conn, 401)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
