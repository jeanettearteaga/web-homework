# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Homework.Repo.insert!(%Homework.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Homework.Merchants
alias Homework.Companies
alias Homework.Users
alias Homework.Transactions

merchant_data = [
    %{
        name: "Starbucks123",
        description: "PSL!"
    },
    %{
        name: "Starbucks88",
        description: "Frappuccino"
    },
    %{
        name: "Merchant0",
        description: "Furniture"
    },
    %{
        name: "Merchant1",
        description: "Jewelry"
    },
    %{
        name: "Merchant2",
        description: "Clothing"
    }
]

company_data = [
    %{name: "Dunder", credit_line: 300},
    %{name: "Sabre", credit_line: 500},
    %{name: "Strata", credit_line: 700},
    %{name: "Janes", credit_line: 150}
]

user_data = [
    %{
        first_name: "Michelle",
        last_name: "Star",
        dob: "02109190"
    },
    %{
        first_name: "Luke",
        last_name: "Skywalker",
        dob: "02123191"
    },
    %{
        first_name: "Jane",
        last_name: "Do",
        dob: "12109190"
    },
    %{
        first_name: "Lisa",
        last_name: "Jenkin",
        dob: "02109191"
    },
    %{
        first_name: "Jose",
        last_name: "Abado",
        dob: "03309190"
    },
    %{
        first_name: "Alexis",
        last_name: "Rose",
        dob: "02109194"
    },
    %{
        first_name: "Kevin",
        last_name: "Grass",
        dob: "02119190"
    }
]

merchants = Enum.map(merchant_data, fn(data) -> 
    {:ok, merchant} = Merchants.create_merchant(data)
    merchant
end)

companies = Enum.map(company_data, fn(data) -> 
    {:ok, company} = Companies.create_company(data)
    company
end)

users = user_data
|> Enum.with_index
|> Enum.map(fn({data, i}) ->
    selected_company = Enum.at(companies, rem(i, Enum.count(companies)))
    {:ok, user} = data 
    |> Map.put(:company_id, selected_company.id)
    |> Users.create_user()
    user
end)

Enum.map(1..10, fn(i) -> 
    selected_company = Enum.at(companies, rem(i, Enum.count(companies)))
    selected_merchant = Enum.at(merchants, rem(i, Enum.count(merchants)))
    selected_user = Enum.at(users, rem(i, Enum.count(users)))

    %{
        amount: i * 10,
        company_id: selected_company.id,
        credit: true,
        debit: true,
        description: "description #{i}",
        merchant_id: selected_merchant.id,
        user_id: selected_user.id
    } |> Transactions.create_transaction()
end)
