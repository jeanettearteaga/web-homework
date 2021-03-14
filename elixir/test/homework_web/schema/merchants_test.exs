defmodule HomeworkWeb.Schema.MerchantsTest do
  use HomeworkWeb.ConnCase, async: true

  alias Homework.Merchants

  describe "merchant" do
    test "returns a merchant", %{conn: conn} do
      {:ok, merchant} =
        Merchants.create_merchant(%{name: "Merrilee", description: "Handmade jewelry"})

      query = """
          query Merchant{        
              merchants{
                  id
                  name
                  description
              }
          }
      """

      variables = %{name: "Merrilee", description: "Handmade jewelry"}

      body =
        conn
        |> post("/graphiql", %{query: query, variables: variables})
        |> json_response(200)

      expected_merchant = %{
        "description" => "Handmade jewelry",
        "id" => merchant.id,
        "name" => "Merrilee"
      }

      refute body["errors"]
      assert body["data"]["merchants"] == [expected_merchant]
    end
  end

  describe "create merchant" do
    test "creates a merchant", %{conn: conn} do
      mutation = """
          mutation MerchantMutations($name: String!, $description: String!){
              createMerchant(name: $name, description: $description
              ){
                  name
                  description
              }
          }
      """

      variables = %{name: "Chucks", description: "Handmade quality craftsmanship"}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_merchant = %{
        "name" => "Chucks",
        "description" => "Handmade quality craftsmanship"
      }

      refute body["errors"]
      assert body["data"]["createMerchant"] == expected_merchant
    end

    test "error when attempting to create a merchant with invalid args", %{conn: conn} do
      mutation = """
          mutation MerchantMutations($name: String!, $description: String!){
              createMerchant(name: $name, description: $description
              ){
                  name
                  description
              }
          }
      """

      variables = %{name: "Chucks", description: 3000}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      error_message =
        body["errors"]
        |> Enum.at(0)
        |> Map.get("message")

      assert error_message == "Argument \"description\" has invalid value $description."
    end
  end

  describe "update merchant" do
    test "updated a merchant", %{conn: conn} do
      {:ok, merchant} =
        Merchants.create_merchant(%{name: "Merrilee", description: "Handmade jewelry"})

      mutation = """
          mutation MerchantMutations($id: ID!, $name: String!, $description: String!){
              updateMerchant(id: $id, name: $name, description: $description
              ){
                  id
                  name
                  description
              }
          }
      """

      variables = %{
        id: merchant.id,
        name: "Chucks",
        description: "Handmade quality craftsmanship"
      }

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_merchant = %{
        "name" => "Chucks",
        "description" => "Handmade quality craftsmanship",
        "id" => merchant.id
      }

      refute body["errors"]
      assert body["data"]["updateMerchant"] == expected_merchant
    end

    test "error when attempting to update merchant with invalid args", %{conn: conn} do
      {:ok, merchant} =
        Merchants.create_merchant(%{name: "Merrilee", description: "Handmade jewelry"})

      mutation = """
          mutation MerchantMutations($id: ID!, $name: String!, $description: String!){
              updateMerchant(id: $id, name: $name, description: $description
              ){
                  id
                  name
                  description
              }
          }
      """

      variables = %{
        id: merchant.id,
        name: 100,
        description: "Handmade quality craftsmanship"
      }

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

  describe "delete merchant" do
    test "delete a merchant", %{conn: conn} do
      {:ok, merchant} =
        Merchants.create_merchant(%{name: "Merrilee", description: "Handmade jewelry"})

      mutation = """
          mutation MerchantMutations($id: ID!){
              deleteMerchant(id: $id
              ){
                  id
                  name
                  description
              }
          }
      """

      variables = %{id: merchant.id}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_merchant = %{
        "description" => "Handmade jewelry",
        "id" => merchant.id,
        "name" => "Merrilee"
      }

      refute body["errors"]
      assert body["data"]["deleteMerchant"] == expected_merchant
    end

    test "error when attempting to delete merchant without id", %{conn: conn} do
      mutation = """
          mutation MerchantMutations($id: ID!){
              deleteMerchant(id: $id
              ){
                  id
                  name
                  description
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
