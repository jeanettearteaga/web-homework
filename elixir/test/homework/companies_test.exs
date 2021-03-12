defmodule Homework.CompaniesTest do
    use Homework.DataCase
  
    alias Homework.Companies
    alias Homework.Users
  
    describe "companies" do
      alias Homework.Companies.Company
  
      @valid_attrs %{name: "Dunder Mifflen", credit_line: 900}
      @valid_user_attrs %{dob: "some dob", first_name: "some first_name", last_name: "some last_name"}
      @update_attrs %{
        name: "some updated name",
        credit_line: 1800
      }
      @invalid_attrs %{name: nil, credit_line: nil}
  
      def company_fixture(attrs \\ %{}) do
        {:ok, company} =
          attrs
          |> Enum.into(@valid_attrs)
          |> Companies.create_company()
  
        company
      end

      def user_fixture(valid_attrs, attrs \\ %{}) do
        {:ok, user} =
          attrs
          |> Enum.into(valid_attrs)
          |> Users.create_user()
    
        user
      end
  
      test "list_companies/1 returns all companies" do
        company = company_fixture()
        assert Companies.list_companies([]) == [company]
      end
  
      test "get_company!/1 returns the company with given id" do
        company = company_fixture()
        assert Companies.get_company!(company.id) == company
      end
  
      test "create_company/1 with valid data creates a company" do
        assert {:ok, %Company{} = company} = Companies.create_company(@valid_attrs)
        assert company.name == "Dunder Mifflen"
        assert company.credit_line == 900
      end
  
      test "create_company/1 with invalid data returns error changeset" do
        assert {:error, %Ecto.Changeset{}} = Companies.create_company(@invalid_attrs)
      end
  
      test "update_company/2 with valid data updates the company" do
        company = company_fixture()
        assert {:ok, %Company{} = company} = Companies.update_company(company, @update_attrs)
        assert company.name == "some updated name"
        assert company.credit_line == 1800
      end
  
      test "update_company/2 with invalid data returns error changeset" do
        company = company_fixture()
        assert {:error, %Ecto.Changeset{}} = Companies.update_company(company, @invalid_attrs)
        assert company == Companies.get_company!(company.id)
      end
  
      test "delete_company/1 deletes the company" do
        company = company_fixture()
        assert {:ok, %Company{}} = Companies.delete_company(company)
        assert_raise Ecto.NoResultsError, fn -> Companies.get_company!(company.id) end
      end
  
      test "change_company/1 returns a company changeset" do
        company = company_fixture()
        assert %Ecto.Changeset{} = Companies.change_company(company)
      end

      test "delete_company/1 deletes the company and the users under the company.id" do
        company = company_fixture(@valid_attrs)
        user = user_fixture(Map.put(@valid_user_attrs, :company_id, company.id))
  
        assert {:ok, %Company{}} = Companies.delete_company(company) 
        assert_raise Ecto.NoResultsError, fn -> Companies.get_company!(company.id) end
        assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
      end
    end
  end
  