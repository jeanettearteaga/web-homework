defmodule Homework.Repo.Migrations.AddCompanyIdToTransactions do
  use Ecto.Migration

  def change do
    alter table("transactions") do
      add(:company_id, :uuid)
    end
  end
end
