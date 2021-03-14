defmodule Homework.Companies.Company do
  use Ecto.Schema
  import Ecto.Changeset

  alias Homework.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "companies" do
    field(:name, :string)
    field(:credit_line, :integer)
    field(:available_credit, :integer)

    has_many(:users, User)

    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :credit_line, :available_credit])
    |> validate_required([:name, :credit_line])
  end
end
