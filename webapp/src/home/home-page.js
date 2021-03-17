import React, { Fragment, useEffect, useState } from 'react'
import { useQuery, gql } from '@apollo/client'
import GetTransactions from '../gql/transactions.gql'
import { TxPage } from '../components/transactions/TxPage'
import styled from 'styled-components'

const labelStyles = {
  marginLeft: '8px',
  fontSize: '12px'
}

const Filter = styled.div`
  display: flex;
  flex-direction: column;
  padding-right: 10px;
`

const FiltersWrapper = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: flex-end;
  padding-right: 70px;
`

const GET_USERS_MUTATION = gql`
  query GetUsers {
    users {
      id
      firstName
      lastName
    }
  }
`
const GET_MERCHANTS_MUTATION = gql`
  query GetMerchant {
    merchants {
      id
      name
    }
  }
`

const GET_TRANSACTIONS_BY_COMPANY = gql`
  query GetTransactionByCompanyId {
    companies {
      id
      name
      transactions {
        id
        userId
        user {
          id
          firstName
          lastName
        }
        companyId
        company {
          id
          name
        }
        description
        merchantId
        merchant {
          id
          name
        }
        debit
        credit
        amount
      }
    }
  }
`

function calculateRomanNumeral (dec) {
  const romanNumeralconversions = {
    1: 'I',
    4: 'IV',
    5: 'V',
    9: 'IX',
    10: 'X',
    40: 'XL',
    50: 'L',
    90: 'XC',
    100: 'C',
    400: 'CD',
    500: 'D',
    900: 'CM',
    1000: 'M'
  }
  const decArray = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
  let romanNumeral = ''
  if (dec > 3999) {
    return dec
  }
  for (let index = 0; index < decArray.length; index++) {
    if (dec === 0) {
      return romanNumeral
    }
    const quotient = Math.floor(dec / decArray[index])
    if (quotient !== 0) {
      for (let j = 0; j < quotient; j++) {
        romanNumeral += romanNumeralconversions[decArray[index]]
      }
    }
    dec = dec % decArray[index]
  }
  return romanNumeral
}

export function Home () {
  const [modalIsOpen, setModalIsOpen] = useState(false)
  const [companyId, setCompanyId] = useState('')
  const [numberFormat, setNumberFormat] = useState('decimal')
  const { loading, error, data: allTransactionData = {}, refetch: refetchTransactions } = useQuery(GetTransactions)
  const { loading: userLoading, error: userError, data: userData = {} } = useQuery(GET_USERS_MUTATION)
  const { loading: merchantLoading, error: merchantError, data: merchantData = {} } = useQuery(GET_MERCHANTS_MUTATION)

  const {
    loading: companyLoading,
    error: companyError,
    data: companyData = {},
    refetch: refetchTransactionsByCompany
  } = useQuery(GET_TRANSACTIONS_BY_COMPANY)

  useEffect(() => {
    refetchTransactionsByCompany()
    refetchTransactions()
  }, [modalIsOpen])

  if (companyLoading || loading || userLoading || merchantLoading) {
    return <Fragment>Loading...</Fragment>
  }

  if (error || userError || merchantError || companyError) {
    return <Fragment>¯\_(ツ)_/¯</Fragment>
  }

  function handleBlur (e, setVal) {
    setVal(e.target.value)
  }

  function getNumber (number) {
    if (numberFormat === 'roman') {
      return calculateRomanNumeral(number)
    }
    return number
  }

  function getTransactions (companyId) {
    const selected = companyData.companies.find(company => {
      return company.id === companyId
    })
    return selected ? selected.transactions : allTransactionData?.transactions
  }

  return (
    <Fragment>
      <FiltersWrapper>
        <Filter>
          <label htmlFor='Company' style={labelStyles}>Company</label>
          <select id='companyId' onBlur={e => handleBlur(e, setCompanyId)} onChange={e => handleBlur(e, setCompanyId)} value={companyId}>
            <option value=''>All</option>
            {companyData.companies.map(company => {
              const { id, name } = company
              return <option key={id} value={id}>{name}</option>
            })}
          </select>
        </Filter>

        <Filter>
          <label htmlFor='numberFormat' style={labelStyles}>Number Format</label>
          <select id='numberFormat' onBlur={e => handleBlur(e, setNumberFormat)} onChange={e => handleBlur(e, setNumberFormat)} value={numberFormat}>
            <option value='decimal'>Decimal</option>
            <option value='roman'>Roman Numeral</option>
          </select>
        </Filter>
      </FiltersWrapper>
      {
        <TxPage
          companyData={companyData.companies}
          data={getTransactions(companyId)}
          getNumberFunction={getNumber}
          merchantData={merchantData.merchants}
          modalIsOpen={modalIsOpen}
          setModalIsOpen={setModalIsOpen}
          userData={userData.users}
        />
      }
    </Fragment>
  )
}
