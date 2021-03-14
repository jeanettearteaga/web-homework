defmodule HomeworkWeb.Schema.CompaniesTest do
  use HomeworkWeb.ConnCase, async: true

  alias Homework.Companies

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
