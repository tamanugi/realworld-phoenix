defmodule RealworldPhoenix.AccountsTest do
  use RealworldPhoenix.DataCase

  alias RealworldPhoenix.Accounts

  describe "users" do
    alias RealworldPhoenix.Accounts.User

    @valid_attrs %{
      bio: "some bio",
      email: "some email",
      image: "some image",
      username: "some username",
      password: "hogehoge"
    }
    @update_attrs %{
      bio: "some updated bio",
      email: "some updated email",
      image: "some updated image",
      username: "some updated username",
      password: "updatehogehoge"
    }
    @invalid_attrs %{bio: nil, email: nil, image: nil, username: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.bio == "some bio"
      assert user.email == "some email"
      assert user.image == "some image"
      assert user.username == "some username"
    end

    test "get_user_by_email/1 returns a user" do
      user = user_fixture()
      assert user == Accounts.get_user_by_email(user.email)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.bio == "some updated bio"
      assert user.email == "some updated email"
      assert user.image == "some updated image"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
