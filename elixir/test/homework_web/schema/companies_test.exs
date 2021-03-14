defmodule HomeworkWeb.Schema.CompaniesTest do
  use HomeworkWeb.ConnCase, async: true

  alias Homework.Companies
  alias Homework.Transactions
  alias Homework.Users
  alias Homework.Merchants

  describe "company" do
    test "returns a company", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})

      query = """
          query Company{        
              companies{
                  id
                  name
                  creditLine
                  availableCredit
              }
          }
      """

      variables = %{name: "Dunder Mifflin", creditLine: 30000}

      body =
        conn
        |> post("/graphiql", %{query: query, variables: variables})
        |> json_response(200)

      expected_company = %{
        "name" => "Dunder Mifflin",
        "creditLine" => 30000,
        "availableCredit" => 30000,
        "id" => company.id
      }

      refute body["errors"]
      assert body["data"]["companies"] == [expected_company]
    end
  end

  describe "create company" do
    test "creates a company", %{conn: conn} do
      mutation = """
          mutation CompanyMutations($name: String!, $creditLine: Int!){
              createCompany(name: $name, creditLine: $creditLine
              ){
                  name
                  creditLine
                  availableCredit
              }
          }
      """

      variables = %{name: "Dunder", creditLine: 500}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_company = %{
        "creditLine" => 500,
        "name" => "Dunder",
        "availableCredit" => 500
      }

      refute body["errors"]
      assert body["data"]["createCompany"] == expected_company
    end

    test "error when attempting to create company with invalid args", %{conn: conn} do
      mutation = """
          mutation CompanyMutations($name: String!, $creditLine: Int!){
              createCompany(name: $name, creditLine: $creditLine
              ){
                  name
                  creditLine
                  availableCredit
              }
          }
      """

      variables = %{name: "Dunder", creditLine: "500"}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      error_message =
        body["errors"]
        |> Enum.at(0)
        |> Map.get("message")

      assert error_message == "Argument \"creditLine\" has invalid value $creditLine."
    end
  end

  describe "update company" do
    test "updated a company", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})

      mutation = """
          mutation CompanyMutations($id: ID!, $name: String!, $creditLine: Int!){
              updateCompany(id: $id, name: $name, creditLine: $creditLine
              ){
                  id
                  name
                  creditLine
                  availableCredit
              }
          }
      """

      variables = %{id: company.id, name: "Dunder", creditLine: 30000}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_company = %{
        "availableCredit" => 30000,
        "creditLine" => 30000,
        "id" => company.id,
        "name" => "Dunder"
      }

      refute body["errors"]
      assert body["data"]["updateCompany"] == expected_company
    end

    test "error when attempting to update company with invalid args", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})

      mutation = """
          mutation CompanyMutations($id: ID!, $name: String!, $creditLine: Int!){
              updateCompany(id: $id, name: $name, creditLine: $creditLine
              ){
                  id
                  name
                  creditLine
                  availableCredit
              }
          }
      """

      variables = %{id: company.id, name: 100, creditLine: 30000}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      error_message =
        body["errors"]
        |> Enum.at(0)
        |> Map.get("message")

      assert error_message == "Argument \"name\" has invalid value $name."
    end

    test "updated the avilable credit when credit_line is changed", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 300})

      {:ok, user} =
        Users.create_user(%{
          company_id: company.id,
          dob: "some dob",
          first_name: "Stacy",
          last_name: "Perez"
        })

      {:ok, merchant} = Merchants.create_merchant(%{description: "Merch", name: "Swag"})

      create_transaction_mutation = """
          mutation transactionMutations($amount: Int!, $companyId: ID!, $merchantId: ID!, $userId: ID!, $credit: Boolean!, $debit: Boolean!, $description: String!){
              createTransaction(amount: $amount, companyId: $companyId, merchantId: $merchantId, userId: $userId, credit: $credit, debit: $debit, description: $description
              ){
                amount
                companyId
                merchantId
                userId
                credit
                debit
                description
              }
          }
      """

      mutation = """
          mutation CompanyMutations($id: ID!, $name: String!, $creditLine: Int!){
              updateCompany(id: $id, name: $name, creditLine: $creditLine
              ){
                  id
                  name
                  creditLine
                  availableCredit
              }
          }
      """

      variables = %{id: company.id, name: "Dunder", creditLine: 500}

      transaction_variables = %{
        amount: 100,
        companyId: company.id,
        merchantId: merchant.id,
        userId: user.id,
        credit: true,
        debit: true,
        description: "some description"
      }

      conn
      |> post("/graphiql", %{query: create_transaction_mutation, variables: transaction_variables})
      |> json_response(200)

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_company = %{
        "availableCredit" => 400,
        "creditLine" => 500,
        "id" => company.id,
        "name" => "Dunder"
      }

      refute body["errors"]
      assert body["data"]["updateCompany"] == expected_company
    end
  end

  describe "delete company" do
    test "delete a company", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder Mifflin", credit_line: 30000})

      mutation = """
          mutation CompanyMutations($id: ID!){
              deleteCompany(id: $id
              ){
                  id
                  name
                  creditLine
                  availableCredit
              }
          }
      """

      variables = %{id: company.id}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_company = %{
        "availableCredit" => 30000,
        "creditLine" => 30000,
        "id" => company.id,
        "name" => "Dunder Mifflin"
      }

      refute body["errors"]
      assert body["data"]["deleteCompany"] == expected_company
    end

    test "error when attemptimg to delete company without id", %{conn: conn} do
      mutation = """
          mutation CompanyMutations($id: ID!){
              deleteCompany(id: $id
              ){
                  id
                  name
                  creditLine
                  availableCredit
              }
          }
      """

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: %{}})
        |> json_response(200)

      error_message =
        body["errors"]
        |> Enum.at(0)
        |> Map.get("message")

      assert error_message == "In argument \"id\": Expected type \"ID!\", found null."
    end
  end
end
