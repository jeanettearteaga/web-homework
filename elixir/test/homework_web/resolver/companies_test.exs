defmodule HomeworkWeb.Resolver.CompaniesTest do
  use Homework.DataCase

  alias HomeworkWeb.Resolvers.CompaniesResolver
  alias Homework.Companies

  describe "update_company_available_credit" do
    test "available_credit should be decremented" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})
      expected_available_credit = 20000

      {:ok, %{available_credit: available_credit}} =
        CompaniesResolver.update_company_available_credit(company.id, -10000)

      assert available_credit == expected_available_credit
    end

    test "available_credit should be incremented" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})
      expected_available_credit = 40000

      {:ok, %{available_credit: available_credit}} =
        CompaniesResolver.update_company_available_credit(company.id, 10000)

      assert available_credit == expected_available_credit
    end

    test "update_company_available_credit should fail when no company is found" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})
      assert {:error, _} = CompaniesResolver.update_company_available_credit(company.id, "10000")
    end

    test "update_company_available_credit should fail when company doesn't exist" do
      assert {:error, _} =
               CompaniesResolver.update_company_available_credit(
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
               CompaniesResolver.update_company_available_credit_by_credit_line(
                 %{credit_line: 40000},
                 company
               ).available_credit
    end

    test "available_credit should be decremented" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})
      expected_available_credit = 20000

      assert expected_available_credit ==
               CompaniesResolver.update_company_available_credit_by_credit_line(
                 %{credit_line: 20000},
                 company
               ).available_credit
    end

    test "available_credit should be unchanged" do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})

      assert %{} ==
               CompaniesResolver.update_company_available_credit_by_credit_line(
                 %{},
                 company
               )
    end
  end
end
