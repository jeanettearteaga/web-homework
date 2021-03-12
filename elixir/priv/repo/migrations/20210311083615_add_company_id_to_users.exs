defmodule Homework.Repo.Migrations.AddCompanyIdToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:company_id, references(:companies, type: :uuid, on_delete: :delete_all))
    end
  end
end
