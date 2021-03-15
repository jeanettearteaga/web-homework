defmodule Homework.Companies do
  @moduledoc """
  The Companies context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Companies.Company

  @doc """
  Returns the list of companies.

  ## Examples

      iex> list_companies([])
      [%Company{}, ...]

  """
  def list_companies(_args) do
    Repo.all(Company)
  end

  @doc """
  Gets a single company.

  Raises `Ecto.NoResultsError` if the Company does not exist.

  ## Examples

      iex> get_company!(123)
      %Company{}

      iex> get_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company!(id), do: Repo.get!(Company, id)

  @doc """
  Gets a single company.

  ## Examples

      iex> get_company(123)
      %Company{}

      iex> get_company(456)
      nil

  """
  def get_company(id), do: Repo.get(Company, id)

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(%{credit_line: credit_line} = attrs) when not is_nil(credit_line) do
    %Company{available_credit: credit_line}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  def create_company(attrs) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a company.

  ## Examples

      iex> update_company(company, %{field: new_value})
      {:ok, %Company{}}

      iex> update_company(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company(%Company{} = company, attrs) do
    updated_attrs = update_company_available_credit_by_credit_line(attrs, company)

    company
    |> Company.changeset(updated_attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a company.

  ## Examples

      iex> delete_company(company)
      {:ok, %Company{}}

      iex> delete_company(company)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company changes.

  ## Examples

      iex> change_company(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company(%Company{} = company, attrs \\ %{}) do
    Company.changeset(company, attrs)
  end

  @doc """
  Updates a company's available credit by a changed amount for a transaction's company_id.
  """
  def update_company_available_credit(id, amount) when is_integer(amount) do
    with old_company when not is_nil(old_company) <- get_company(id),
         available_credit <- old_company.available_credit + amount,
         {:ok, company} <-
           update_company(old_company, %{available_credit: available_credit}) do
      {:ok, company}
    else
      error ->
        {:error, "could not update the company's available_credit: #{inspect(error)}"}

      nil ->
        {:error, "Company with id #{id} does not exist"}
    end
  end

  def update_company_available_credit(_, _), do: {:error, "amount must be an number"}

  @doc """
  Updates a company's available credit by a changed credit line for a company
  """
  def update_company_available_credit_by_credit_line(
        %{credit_line: new_credit_line} = attrs,
        company
      )
      when not is_nil(new_credit_line) do
    available_credit = company.available_credit
    credit_line = company.credit_line

    spent = credit_line - available_credit
    new_available_credit = new_credit_line - spent
    Map.put(attrs, :available_credit, new_available_credit)
  end

  def update_company_available_credit_by_credit_line(attrs, _), do: attrs
end
