defmodule RealworldPhoenixWeb.ProfileControllerTest do
  use RealworldPhoenixWeb.ConnCase

  alias RealworldPhoenix.Profiles
  alias RealworldPhoenix.Accounts

  @create_attrs %{
    bio: "some bio",
    image: "some image",
    email: "some email",
    username: "some username",
    password: "hogehogehoge"
  }

  def fixture(:profile) do
    {:ok, profile} = Accounts.create_user(@create_attrs)
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
               "image" => profile.image
             } == json_response(conn, 200)["profile"]
    end
  end

  defp create_profile(_) do
    profile = fixture(:profile)
    %{profile: profile}
  end
end
