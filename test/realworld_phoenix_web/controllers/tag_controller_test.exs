defmodule RealworldPhoenixWeb.TagControllerTest do
  use RealworldPhoenixWeb.ConnCase

  alias RealworldPhoenix.Repo
  alias RealworldPhoenix.Articles.Tag

  def fixture(:tag, name) do
    Repo.insert!(%Tag{name: name})
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_tags]

    test "lists all tags", %{conn: conn} do
      conn = get(conn, Routes.tag_path(conn, :index))
      expected = for i <- 1..10, do: "tag_name_#{i}"
      assert ^expected = json_response(conn, 200)["tags"]
    end
  end

  def create_tags(p) do
    for i <- 1..10 do
      fixture(:tag, "tag_name_#{i}")
    end

    p
  end
end
