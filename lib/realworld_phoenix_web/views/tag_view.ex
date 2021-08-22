defmodule RealworldPhoenixWeb.TagView do
  use RealworldPhoenixWeb, :view
  alias RealworldPhoenixWeb.TagView

  def render("index.json", %{tags: tags}) do
    %{
      tags: render_many(tags, TagView, "tag.json")
    }
  end

  def render("tag.json", %{tag: tag}) do
    tag.name
  end
end
