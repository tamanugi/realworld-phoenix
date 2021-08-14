defmodule RealworldPhoenixWeb.ProfileControllerTest do
  use RealworldPhoenixWeb.ConnCase

  alias RealworldPhoenix.Accounts

  @create_attrs %{
    bio: "some bio",
    image: "some image",
    email: "some email",
    username: "some username",
    password: "hogehogehoge"
  }

  def fixture(:profile) do
    {:ok, profile} =
      @create_attrs
      |> Map.update!(:username, fn name ->
        "#{name}#{:rand.uniform(10000)}"
      end)
      |> Accounts.create_user()

    profile
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "show" do
    setup [:create_profile]

    test "show user profile", %{conn: conn, profile: profile} do
      conn = get(conn, Routes.profile_path(conn, :show, profile.username))

      assert %{
               "bio" => profile.bio,
               "username" => profile.username,
               "image" => profile.image,
               "following" => false
             } == json_response(conn, 200)["profile"]
    end
  end

  describe "follow" do
    setup [:create_profile, :login]

    test "create follow", %{conn: conn, profile: profile} do
      conn = post(conn, Routes.profile_path(conn, :follow, profile.username))

      assert %{
               "bio" => profile.bio,
               "username" => profile.username,
               "image" => profile.image,
               "following" => true
             } == json_response(conn, 200)["profile"]

      conn = get(conn, Routes.profile_path(conn, :show, profile.username))

      assert %{
               "bio" => profile.bio,
               "username" => profile.username,
               "image" => profile.image,
               "following" => true
             } == json_response(conn, 200)["profile"]
    end

    test "delete follow", %{conn: conn, profile: profile} do
      conn = post(conn, Routes.profile_path(conn, :follow, profile.username))
      conn = delete(conn, Routes.profile_path(conn, :unfollow, profile.username))

      assert %{
               "bio" => profile.bio,
               "username" => profile.username,
               "image" => profile.image,
               "following" => false
             } == json_response(conn, 200)["profile"]

      conn = get(conn, Routes.profile_path(conn, :show, profile.username))

      assert %{
               "bio" => profile.bio,
               "username" => profile.username,
               "image" => profile.image,
               "following" => false
             } == json_response(conn, 200)["profile"]
    end
  end

  defp create_profile(_) do
    profile = fixture(:profile)
    %{profile: profile}
  end

  defp login(%{conn: conn}) do
    user = fixture(:profile) |> Map.put(:username, "login user")
    %{conn: put_authorization(conn, user)}
  end
end
