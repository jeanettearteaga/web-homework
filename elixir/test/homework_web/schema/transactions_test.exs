defmodule HomeworkWeb.Schema.TransactionsTest do
  use HomeworkWeb.ConnCase, async: true

  alias Homework.Transactions
  alias Homework.Companies
  alias Homework.Users
  alias Homework.Merchants

  describe "transaction" do
    test "returns a transaction", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      {:ok, user} =
        Users.create_user(%{
          company_id: company.id,
          dob: "some dob",
          first_name: "some first_name",
          last_name: "some last_name"
        })

      {:ok, merchant} =
        Merchants.create_merchant(%{description: "some description", name: "some name"})

      {:ok, transaction} =
        Transactions.create_transaction(%{
          amount: 42,
          company_id: company.id,
          merchant_id: merchant.id,
          user_id: user.id,
          credit: true,
          debit: true,
          description: "some description"
        })

      query = """
          query Transaction{        
              transactions{
                id
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

      variables = %{
        amount: 42,
        companyId: company.id,
        merchantId: merchant.id,
        userId: user.id,
        credit: true,
        debit: true,
        description: "some description"
      }

      body =
        conn
        |> post("/graphiql", %{query: query, variables: variables})
        |> json_response(200)

      expected_transaction = %{
        "id" => transaction.id,
        "amount" => 42,
        "companyId" => company.id,
        "merchantId" => merchant.id,
        "userId" => user.id,
        "credit" => true,
        "debit" => true,
        "description" => "some description"
      }

      refute body["errors"]
      assert body["data"]["transactions"] == [expected_transaction]
    end
  end

  describe "create transaction" do
    test "creates a transaction", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      {:ok, user} =
        Users.create_user(%{
          company_id: company.id,
          dob: "some dob",
          first_name: "some first_name",
          last_name: "some last_name"
        })

      {:ok, merchant} =
        Merchants.create_merchant(%{description: "some description", name: "some name"})

      mutation = """
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

      variables = %{
        amount: 42,
        companyId: company.id,
        merchantId: merchant.id,
        userId: user.id,
        credit: true,
        debit: true,
        description: "some description"
      }

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_transaction = %{
        "companyId" => company.id,
        "amount" => 42,
        "credit" => true,
        "debit" => true,
        "description" => "some description",
        "merchantId" => merchant.id,
        "userId" => user.id
      }

      refute body["errors"]
      assert body["data"]["createTransaction"] == expected_transaction
    end

    test "creates a transaction and updated companies available credit", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      {:ok, user} =
        Users.create_user(%{
          company_id: company.id,
          dob: "some dob",
          first_name: "some first_name",
          last_name: "some last_name"
        })

      {:ok, merchant} =
        Merchants.create_merchant(%{description: "some description", name: "some name"})

      transaction_mutation = """
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

      get_company_query = """
          query Company{        
              companies{
                  availableCredit
              }
          }
      """

      company_variables = %{name: "Dunder", creditLine: 9000, availableCredit: 9000}

      transaction_variables = %{
        amount: 42,
        companyId: company.id,
        merchantId: merchant.id,
        userId: user.id,
        credit: true,
        debit: true,
        description: "some description"
      }

      conn
      |> post("/graphiql", %{query: transaction_mutation, variables: transaction_variables})
      |> json_response(200)

      body =
        conn
        |> post("/graphiql", %{query: get_company_query, variables: company_variables})
        |> json_response(200)

      expected_company = %{
        "availableCredit" => 8958
      }

      refute body["errors"]
      assert body["data"]["companies"] == [expected_company]
    end

    test "error when attempting to create transaction with invalid args", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      {:ok, user} =
        Users.create_user(%{
          company_id: company.id,
          dob: "some dob",
          first_name: "some first_name",
          last_name: "some last_name"
        })

      {:ok, merchant} =
        Merchants.create_merchant(%{description: "some description", name: "some name"})

      mutation = """
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

      variables = %{
        amount: 42,
        companyId: company.id,
        merchantId: merchant.id,
        userId: user.id,
        credit: true,
        debit: true,
        description: 1000
      }

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

  describe "update transaction" do
    test "updated a transaction", %{conn: conn} do
      {:ok, company1} = Companies.create_company(%{name: "Dunder", credit_line: 9000})
      {:ok, company2} = Companies.create_company(%{name: "Sanders", credit_line: 400})

      {:ok, user1} =
        Users.create_user(%{
          company_id: company1.id,
          dob: "some dob",
          first_name: "Stacy",
          last_name: "Perez"
        })

      {:ok, user2} =
        Users.create_user(%{
          company_id: company2.id,
          dob: "some dob",
          first_name: "Jane",
          last_name: "Smith"
        })

      {:ok, merchant1} = Merchants.create_merchant(%{description: "Merch", name: "Swag"})
      {:ok, merchant2} = Merchants.create_merchant(%{description: "Jemies", name: "Clothing"})

      {:ok, transaction} =
        Transactions.create_transaction(%{
          amount: 42,
          company_id: company1.id,
          merchant_id: merchant1.id,
          user_id: user1.id,
          credit: true,
          debit: true,
          description: "tee"
        })

      mutation = """
          mutation TransactionMutations($id: ID!, $amount: Int!, $companyId: ID!, $merchantId: ID!, $userId: ID!, $credit: Boolean!, $debit: Boolean!, $description: String!){
              updateTransaction(id: $id, amount: $amount, companyId: $companyId, merchantId: $merchantId, userId: $userId, credit: $credit, debit: $debit, description: $description
              ){
                id
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

      variables = %{
        id: transaction.id,
        amount: 42,
        companyId: company2.id,
        merchantId: merchant2.id,
        userId: user2.id,
        credit: true,
        debit: true,
        description: "tee"
      }

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_transaction = %{
        "companyId" => company2.id,
        "id" => transaction.id,
        "amount" => 42,
        "credit" => true,
        "debit" => true,
        "description" => "tee",
        "merchantId" => merchant2.id,
        "userId" => user2.id
      }

      refute body["errors"]
      assert body["data"]["updateTransaction"] == expected_transaction
    end

    test "updated a transaction and companies available credit ", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      {:ok, user} =
        Users.create_user(%{
          company_id: company.id,
          dob: "some dob",
          first_name: "Stacy",
          last_name: "Perez"
        })

      {:ok, merchant} = Merchants.create_merchant(%{description: "Merch", name: "Swag"})

      {:ok, transaction} =
        Transactions.create_transaction(%{
          amount: 42,
          company_id: company.id,
          merchant_id: merchant.id,
          user_id: user.id,
          credit: true,
          debit: true,
          description: "tee"
        })

      assert Companies.get_company(company.id).available_credit == 8958

      transaction_mutation = """
          mutation TransactionMutations($id: ID!, $amount: Int!, $companyId: ID!, $merchantId: ID!, $userId: ID!, $credit: Boolean!, $debit: Boolean!, $description: String!){
              updateTransaction(id: $id, amount: $amount, companyId: $companyId, merchantId: $merchantId, userId: $userId, credit: $credit, debit: $debit, description: $description
              ){
                id
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

      get_company_query = """
          query Company{        
              companies{
                  availableCredit
              }
          }
      """

      company_variables = %{name: "Dunder", creditLine: 9000}

      transaction_variables = %{
        id: transaction.id,
        amount: 50,
        companyId: company.id,
        merchantId: merchant.id,
        userId: user.id,
        credit: true,
        debit: true,
        description: "tee"
      }

      conn
      |> post("/graphiql", %{query: transaction_mutation, variables: transaction_variables})
      |> json_response(200)

      body =
        conn
        |> post("/graphiql", %{query: get_company_query, variables: company_variables})
        |> json_response(200)

      expected_company = %{
        "availableCredit" => 8950
      }

      refute body["errors"]
      assert body["data"]["companies"] == [expected_company]
    end

    test "error when attempting to update transaction with invalid args", %{conn: conn} do
      {:ok, company1} = Companies.create_company(%{name: "Dunder", credit_line: 9000})
      {:ok, company2} = Companies.create_company(%{name: "Sanders", credit_line: 400})

      {:ok, user1} =
        Users.create_user(%{
          company_id: company1.id,
          dob: "some dob",
          first_name: "Stacy",
          last_name: "Perez"
        })

      {:ok, user2} =
        Users.create_user(%{
          company_id: company2.id,
          dob: "some dob",
          first_name: "Jane",
          last_name: "Smith"
        })

      {:ok, merchant1} = Merchants.create_merchant(%{description: "Merch", name: "Swag"})
      {:ok, merchant2} = Merchants.create_merchant(%{description: "Jemies", name: "Clothing"})

      {:ok, transaction} =
        Transactions.create_transaction(%{
          amount: 42,
          company_id: company1.id,
          merchant_id: merchant1.id,
          user_id: user1.id,
          credit: true,
          debit: true,
          description: "tee"
        })

      mutation = """
          mutation TransactionMutations($id: ID!, $amount: Int!, $companyId: ID!, $merchantId: ID!, $userId: ID!, $credit: Boolean!, $debit: Boolean!, $description: String!){
              updateTransaction(id: $id, amount: $amount, companyId: $companyId, merchantId: $merchantId, userId: $userId, credit: $credit, debit: $debit, description: $description
              ){
                id
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

      variables = %{
        id: transaction.id,
        amount: 42,
        companyId: company2.id,
        merchantId: merchant2.id,
        userId: user2.id,
        credit: "true",
        debit: true,
        description: "tee"
      }

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      error_message =
        body["errors"]
        |> Enum.at(0)
        |> Map.get("message")

      assert error_message == "Argument \"credit\" has invalid value $credit."
    end
  end

  describe "delete transaction" do
    test "delete a transaction", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      {:ok, user} =
        Users.create_user(%{
          company_id: company.id,
          dob: "some dob",
          first_name: "Stacy",
          last_name: "Perez"
        })

      {:ok, merchant} = Merchants.create_merchant(%{description: "Merch", name: "Swag"})

      {:ok, transaction} =
        Transactions.create_transaction(%{
          amount: 42,
          company_id: company.id,
          merchant_id: merchant.id,
          user_id: user.id,
          credit: true,
          debit: true,
          description: "some description"
        })

      mutation = """
          mutation transactionMutations($id: ID!){
              deleteTransaction(id: $id
              ){
                id
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

      variables = %{id: transaction.id}

      body =
        conn
        |> post("/graphiql", %{query: mutation, variables: variables})
        |> json_response(200)

      expected_transaction = %{
        "companyId" => company.id,
        "id" => transaction.id,
        "amount" => 42,
        "credit" => true,
        "debit" => true,
        "description" => "some description",
        "merchantId" => merchant.id,
        "userId" => user.id
      }

      refute body["errors"]
      assert body["data"]["deleteTransaction"] == expected_transaction
    end

    test "delete a transaction and update the companies available credit", %{conn: conn} do
      {:ok, company} = Companies.create_company(%{name: "Dunder", credit_line: 9000})

      {:ok, user} =
        Users.create_user(%{
          company_id: company.id,
          dob: "some dob",
          first_name: "Stacy",
          last_name: "Perez"
        })

      {:ok, merchant} = Merchants.create_merchant(%{description: "Merch", name: "Swag"})

      {:ok, transaction} =
        Transactions.create_transaction(%{
          amount: 42,
          company_id: company.id,
          merchant_id: merchant.id,
          user_id: user.id,
          credit: true,
          debit: true,
          description: "some description"
        })

      assert Companies.get_company(company.id).available_credit == 8958

      delete_transaction_mutation = """
          mutation transactionMutations($id: ID!){
              deleteTransaction(id: $id
              ){
                id
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

      get_company_query = """
          query Company{        
              companies{
                  availableCredit
              }
          }
      """

      company_variables = %{name: "Dunder", creditLine: 9000}

      transaction_variables = %{id: transaction.id}

      conn
      |> post("/graphiql", %{query: delete_transaction_mutation, variables: transaction_variables})
      |> json_response(200)

      body =
        conn
        |> post("/graphiql", %{query: get_company_query, variables: company_variables})
        |> json_response(200)

      expected_company = %{
        "availableCredit" => 9000
      }

      refute body["errors"]
      assert body["data"]["companies"] == [expected_company]
    end

    test "error when attempting to delete transaction with no id", %{conn: conn} do
      mutation = """
          mutation transactionMutations($id: ID!){
              deleteTransaction(id: $id
              ){
                id
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
