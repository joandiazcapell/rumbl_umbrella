defmodule Rumbl.Repo.Migrations.ModifyCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      modify :name, :string, null: false
    end

    create unique_index(:categories, [:name])
  end
end
