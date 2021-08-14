defmodule RealworldPhoenix.Repo.Migrations.CreateFollowRelated do
  use Ecto.Migration

  def change do
    create table(:follow_related, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :target_id, references(:users, on_delete: :delete_all), primary_key: true

      timestamps()
    end

    create index(:follow_related, [:user_id])
    create index(:follow_related, [:target_id])
  end
end
