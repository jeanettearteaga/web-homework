defmodule Homework.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Transactions.Transaction
  alias Homework.Companies

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions([])
      [%Transaction{}, ...]

  """
  def list_transactions(_args) do
    Repo.all(Transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Gets transaction by company_id

  ## Examples

      iex> get_transactions_by_company_id(123)
      [%Transaction{}, ...]
  """
  def get_transactions_by_company_id(company_id) do
    transactions_query = from(t in Transaction, where: t.company_id == ^company_id)
    Repo.all(transactions_query)
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    case %Transaction{}
         |> Transaction.changeset(attrs)
         |> Repo.insert() do
      {:ok, transaction} ->
        Companies.update_company_available_credit(
          transaction.company_id,
          transaction.amount * -1
        )

        {:ok, transaction}

      error ->
        error
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    outdated_transaction_amount = transaction.amount

    case transaction
         |> Transaction.changeset(attrs)
         |> Repo.update() do
      {:ok, transaction} ->
        Companies.update_company_available_credit(
          transaction.company_id,
          outdated_transaction_amount - transaction.amount
        )

        {:ok, transaction}

      error ->
        error
    end
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    case Repo.delete(transaction) do
      {:ok, transaction} ->
        Companies.update_company_available_credit(
          transaction.company_id,
          transaction.amount
        )

        {:ok, transaction}

      error ->
        error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
