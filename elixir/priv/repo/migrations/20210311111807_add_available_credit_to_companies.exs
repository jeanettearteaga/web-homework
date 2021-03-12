defmodule Homework.Repo.Migrations.AddAvailableCreditToCompanies do
  use Ecto.Migration

  def change do
    alter table("companies") do
      add(:available_credit, :integer)
    end
  end
end
