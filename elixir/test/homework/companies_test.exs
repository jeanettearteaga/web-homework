defmodule Homework.CompaniesTest do
  use Homework.DataCase

  alias Homework.Companies
  alias Homework.Users

  describe "companies" do
    alias Homework.Companies.Company

    @valid_attrs %{name: "Dunder Mifflin", credit_line: 900}
    @valid_user_attrs %{
      dob: "some dob",
      first_name: "some first_name",
      last_name: "some last_name"
    }
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
      company_fixture()
      assert [head | _] = Companies.list_companies([])
      assert %Company{} = head
    end

    test "get_company!/1 returns the company with given id" do
      company = company_fixture()
      assert Companies.get_company!(company.id) == company
    end

    test "create_company/1 with valid data creates a company" do
      assert {:ok, %Company{} = company} = Companies.create_company(@valid_attrs)
      assert company.name == "Dunder Mifflin"
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

  describe "update_company_available_credit" do
    test "available_credit should be decremented" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})
      expected_available_credit = 20000

      {:ok, %{available_credit: available_credit}} =
        Companies.update_company_available_credit(company.id, -10000)

      assert available_credit == expected_available_credit
    end

    test "available_credit should be incremented" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})
      expected_available_credit = 40000

      {:ok, %{available_credit: available_credit}} =
        Companies.update_company_available_credit(company.id, 10000)

      assert available_credit == expected_available_credit
    end

    test "update_company_available_credit should fail when no company is found" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})
      assert {:error, _} = Companies.update_company_available_credit(company.id, "10000")
    end

    test "update_company_available_credit should fail when company doesn't exist" do
      assert {:error, _} =
               Companies.update_company_available_credit(
                 "355ca15e-3ea0-4cc4-8b43-d1a0194f57b3",
                 10000
               )
    end
  end

  describe "update_company_available_credit_by_credit_line" do
    test "available_credit should be incremented" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})
      expected_available_credit = 40000

      assert expected_available_credit ==
               Companies.update_company_available_credit_by_credit_line(
                 %{credit_line: 40000},
                 company
               ).available_credit
    end

    test "available_credit should be decremented" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})
      expected_available_credit = 20000

      assert expected_available_credit ==
               Companies.update_company_available_credit_by_credit_line(
                 %{credit_line: 20000},
                 company
               ).available_credit
    end

    test "available_credit should be unchanged" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})

      assert %{} ==
               Companies.update_company_available_credit_by_credit_line(
                 %{},
                 company
               )
    end
  end
end
