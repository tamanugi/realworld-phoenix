defmodule RealworldPhoenix.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :slug, :string
      add :title, :string
      add :description, :string
      add :body, :string
      add :tagList, {:array, :string}
      add :favoritesCount, :integer
      add :author_id, references(:users)

      timestamps()
    end
  end
end
