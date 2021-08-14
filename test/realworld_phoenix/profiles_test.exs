defmodule RealworldPhoenix.ProfilesTest do
  use RealworldPhoenix.DataCase

  alias RealworldPhoenix.Profiles

  describe "users" do
    alias RealworldPhoenix.Profiles.Profile

    @valid_attrs %{bio: "some bio", image: "some image", username: "some username"}
    @update_attrs %{bio: "some updated bio", image: "some updated image", username: "some updated username"}
    @invalid_attrs %{bio: nil, image: nil, username: nil}

    def profile_fixture(attrs \\ %{}) do
      {:ok, profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Profiles.create_profile()

      profile
    end

    test "list_users/0 returns all users" do
      profile = profile_fixture()
      assert Profiles.list_users() == [profile]
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Profiles.get_profile!(profile.id) == profile
    end

    test "create_profile/1 with valid data creates a profile" do
      assert {:ok, %Profile{} = profile} = Profiles.create_profile(@valid_attrs)
      assert profile.bio == "some bio"
      assert profile.image == "some image"
      assert profile.username == "some username"
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profiles.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{} = profile} = Profiles.update_profile(profile, @update_attrs)
      assert profile.bio == "some updated bio"
      assert profile.image == "some updated image"
      assert profile.username == "some updated username"
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_profile(profile, @invalid_attrs)
      assert profile == Profiles.get_profile!(profile.id)
    end

    test "delete_profile/1 deletes the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{}} = Profiles.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_profile!(profile.id) end
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Profiles.change_profile(profile)
    end
  end
end
