defmodule HomeworkWeb.Schema.UsersTest do
  use HomeworkWeb.ConnCase, async: true

  alias Homework.Users
  alias Homework.Companies

  describe "user" do
    test "returns a user", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      {:ok, user} =
        Users.create_user(%{
          first_name: "Stacy",
          last_name: "Gomez",
          dob: "02109190",
          company_id: company.id
        })

      query = """
          query User{        
              users{
                  id
                  firstName
                  lastName
                  dob
                  companyId
              }
          }
      """

      variables = %{firstName: "Stacy", lastName: "Gomez", dob: "02109190", companyId: company.id}

      body =
        conn
        |> post("/graphiql", %{query: query, variables: variables})
        |> json_response(200)

      expected_user = %{
        "firstName" => "Stacy",
        "lastName" => "Gomez",
        "dob" => "02109190",
        "id" => user.id,
        "companyId" => company.id
      }

      refute body["errors"]
      assert body["data"]["users"] == [expected_user]
    end
  end

  describe "create user" do
    test "creates a user", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      mutation = """
          mutation UserMutations($firstName: String!, $lastName: String!, $dob: String!, $companyId: ID!){
              createUser(firstName: $firstName, lastName: $lastName, dob: $dob, companyId: $companyId
              ){
                  firstName
                  lastName
                  dob
                  companyId
              }
          }
      """

      variables = %{firstName: "Stacy", lastName: "Gomez", dob: "02109190", companyId: company.id}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_user = %{
        "companyId" => company.id,
        "dob" => "02109190",
        "firstName" => "Stacy",
        "lastName" => "Gomez"
      }

      refute body["errors"]
      assert body["data"]["createUser"] == expected_user
    end

    test "error when attempting to create a user with invalid args", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      mutation = """
          mutation UserMutations($firstName: String!, $lastName: String!, $dob: String!, $companyId: ID!){
              createUser(firstName: $firstName, lastName: $lastName, dob: $dob, companyId: $companyId
              ){
                  firstName
                  lastName
                  dob
                  companyId
              }
          }
      """

      variables = %{firstName: 89, lastName: "last", dob: "02109190", companyId: company.id}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      error_message =
        body["errors"]
        |> Enum.at(0)
        |> Map.get("message")

      assert error_message == "Argument \"firstName\" has invalid value $firstName."
    end
  end

  describe "update user" do
    test "updated a user", %{conn: conn} do
      {:ok, company1} = Companies.create_company(%{name: "Dunder", credit_line: 9000})
      {:ok, company2} = Companies.create_company(%{name: "Coopers", credit_line: 10000})

      {:ok, user} =
        Users.create_user(%{
          first_name: "Stacy",
          last_name: "Gomez",
          dob: "02109190",
          company_id: company1.id
        })

      mutation = """
          mutation UserMutations($id: ID!, $firstName: String!, $lastName: String!, $dob: String!, $companyId: ID!){
              updateUser(id: $id, firstName: $firstName, lastName: $lastName, dob: $dob, companyId: $companyId
              ){
                  id
                  firstName
                  lastName
                  dob
                  companyId
              }
          }
      """

      variables = %{
        id: user.id,
        firstName: "Stacy",
        lastName: "Perez",
        dob: "02109190",
        companyId: company2.id
      }

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_user = %{
        "companyId" => company2.id,
        "dob" => "02109190",
        "firstName" => "Stacy",
        "lastName" => "Perez",
        "id" => user.id
      }

      refute body["errors"]
      assert body["data"]["updateUser"] == expected_user
    end

    test "error when attempting to update user with invalid args", %{conn: conn} do
      {:ok, company1} = Companies.create_company(%{name: "Dunder", credit_line: 9000})
      {:ok, company2} = Companies.create_company(%{name: "Coopers", credit_line: 10000})

      {:ok, user} =
        Users.create_user(%{
          first_name: "Stacy",
          last_name: "Gomez",
          dob: "02109190",
          company_id: company1.id
        })

      mutation = """
          mutation UserMutations($id: ID!, $firstName: String!, $lastName: String!, $dob: String!, $companyId: ID!){
              updateUser(id: $id, firstName: $firstName, lastName: $lastName, dob: $dob, companyId: $companyId
              ){
                  id
                  firstName
                  lastName
                  dob
                  companyId
              }
          }
      """

      variables = %{
        id: user.id,
        firstName: "Stacy",
        lastName: "Perez",
        dob: 02_109_190,
        companyId: company2.id
      }

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      error_message =
        body["errors"]
        |> Enum.at(0)
        |> Map.get("message")

      assert error_message == "Argument \"dob\" has invalid value $dob."
    end
  end

  describe "delete user" do
    test "delete a user", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      {:ok, user} =
        Users.create_user(%{
          first_name: "Stacy",
          last_name: "Gomez",
          dob: "02109190",
          company_id: company.id
        })

      mutation = """
          mutation UserMutations($id: ID!){
              deleteUser(id: $id
              ){
                  id
                  firstName
                  lastName
                  dob
                  companyId
              }
          }
      """

      variables = %{id: user.id}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_user = %{
        "id" => user.id,
        "companyId" => company.id,
        "dob" => "02109190",
        "firstName" => "Stacy",
        "lastName" => "Gomez"
      }

      refute body["errors"]
      assert body["data"]["deleteUser"] == expected_user
    end

    test "error when attempting to delete user without id", %{conn: conn} do
      mutation = """
          mutation UserMutations($id: ID!){
              deleteUser(id: $id
              ){
                  id
                  firstName
                  lastName
                  dob
                  companyId
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
