import React, { useState } from 'react'
import { arrayOf, string, bool, number, shape, map, func } from 'prop-types'
import styled from 'styled-components'
import { TransactionFormModal } from './TransactionFormModal'

const Table = styled.table`
  border-collapse: collapse;
  font-family: Arial, Helvetica, sans-serif;


 .header {
   font-weight: bold;
   padding-top: 12px;
   padding-bottom: 12px;
   text-align: left;
   background-color: #6699cc;
   color: white;
 }

 .body {   
   
  display: flex;
    overflow-y: scroll;
    overflow-x: hidden;
     display: block;  
     max-height: 500px;
  }

 .header td{
  padding 25px;
 }

 .transactions td{
  flex: display;
  align-self: stretch;
  border: 1px solid #ddd;
  padding 25px;
 }

 .transactions:nth-child(even) {
   background-color: #f2f2f2;
 }

 .transactions:hover {
  background-color: #ddd;
}
`

export const EditTransactionButton = styled.button`
  border-radius: 4px;
  background-color: #8c8c8c;
  border: none;
  color: white;
  font-size: 8px;
  padding: 8px 8px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  margin-top: 12px;
  cursor: pointer;
  height: 40px;
  width: 100px;
`

const makeDataTestId = (transactionId, fieldName) => `transaction-${transactionId}-${fieldName}`

export function TxTable ({ data, userData, merchantData, companyData, getNumberFunction, setModalIsOpen, modalIsOpen }) {
  const [transactionVals, setTransactionVals] = useState({})
  const [editTransaction, setEditTransaction] = useState(false)

  const handleOpen = (tx, setVal) => {
    setVal(tx)
    setEditTransaction(true)
    setModalIsOpen(true)
  }

  const closeModal = () => {
    setEditTransaction(false)
    setModalIsOpen(false)
  }

  return (
    <Table>
      <tbody className='body'>
        <tr className='header'>
          <td>Transaction ID</td>
          <td>User</td>
          <td>Company</td>
          <td>Description</td>
          <td>Merchant</td>
          <td>Amount</td>
          <td />
          <td />
        </tr>
        {data.map(tx => {
          const { id, user, company, description, merchant, debit, amount } = tx
          return (
            <tr className='transactions' data-testid={`transaction-${id}`} key={`transaction-${id}`}>
              <td data-testid={makeDataTestId(id, 'id')}>{id}</td>
              <td data-testid={makeDataTestId(id, 'userId')}>{user.firstName + ' ' + user.lastName}</td>
              <td data-testid={makeDataTestId(id, 'companyId')}>{company.name}</td>
              <td data-testid={makeDataTestId(id, 'description')}>{description}</td>
              <td data-testid={makeDataTestId(id, 'merchant')}>{merchant.name}</td>
              <td data-testid={makeDataTestId(id, 'amount')}>{getNumberFunction(amount)}</td>
              <td data-testid={makeDataTestId(id, 'debit')}>{debit ? 'debit' : 'credit'}</td>
              <td data-testid={makeDataTestId(id, 'editButton')}>
                <EditTransactionButton onClick={() => handleOpen(tx, setTransactionVals)}>Edit</EditTransactionButton>
                <TransactionFormModal
                  closeModal={closeModal}
                  companyData={companyData}
                  merchantData={merchantData}
                  modalIsOpen={modalIsOpen && editTransaction}
                  transaction={transactionVals}
                  userData={userData}
                />
              </td>
            </tr>
          )
        })}
      </tbody>
    </Table>
  )
}

TxTable.propTypes = {
  data: arrayOf(
    shape({
      id: string,
      user_id: string,
      company_id: string,
      description: string,
      merchant_id: string,
      debit: bool,
      amount: number
    })
  ),
  userData: arrayOf(
    shape({
      id: string,
      first_name: string,
      last_name: string
    })
  ),
  merchantData: arrayOf(
    shape({
      id: string,
      name: string
    })
  ),
  companyData: arrayOf(
    shape({
      id: string,
      name: string,
      transactions: map
    })
  ),
  getNumberFunction: func,
  setModalIsOpen: func,
  modalIsOpen: bool
}
