defmodule HomeworkWeb.Resolvers.CompaniesResolver do
  alias Homework.Companies

  @doc """
  Get a list of companies
  """
  def companies(_root, args, _info) do
    {:ok, Companies.list_companies(args)}
  end

  @doc """
  Create a new company
  """
  def create_company(_root, args, _info) do
    case Companies.create_company(args) do
      {:ok, company} ->
        {:ok, company}

      error ->
        {:error, "could not create company: #{inspect(error)}"}
    end
  end

  @doc """
  Updates a company for an id with args specified.
  """
  def update_company(_root, %{id: id} = args, _info) do
    company = Companies.get_company!(id)

    case Companies.update_company(company, args) do
      {:ok, company} ->
        {:ok, company}

      error ->
        {:error, "could not update company: #{inspect(error)}"}
    end
  end

  @doc """
  Deletes a company for an id
  """
  def delete_company(_root, %{id: id}, _info) do
    company = Companies.get_company!(id)

    case Companies.delete_company(company) do
      {:ok, company} ->
        {:ok, company}

      error ->
        {:error, "could not update company: #{inspect(error)}"}
    end
  end

  @doc """
  Updates a company's available credit for a transaction's company_id.
  """
  def update_company_available_credit(id, amount) when is_integer(amount) do
    with old_company when not is_nil(old_company) <- Companies.get_company(id),
         available_credit <- old_company.available_credit + amount,
         {:ok, company} <-
           Companies.update_company(old_company, %{available_credit: available_credit}) do
      {:ok, company}
    else
      error ->
        {:error, "could not update the company's available_credit: #{inspect(error)}"}

      nil ->
        {:error, "Company with id #{id} does not exist"}
    end
  end

  def update_company_available_credit(_, _) do
    {:error, "amount must be an number"}
  end
end
