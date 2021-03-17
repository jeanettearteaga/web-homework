import React, { useState } from 'react'
import styled from 'styled-components'
import { TxTable } from './TxTable'
import { TransactionFormModal } from './TransactionFormModal'
import { arrayOf, string, bool, number, shape, map, func } from 'prop-types'

const AddTransactionButton = styled.button`
  border-radius: 4px;
  background-color: #6699cc;
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
  width: 200px;
  margin-right: 20px;
`

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  padding: 25px;
  margin-left: 20px;
  margin-right: 20px;
`

const TableWrapper = styled.div`
  display: flex;
  align-self: center;
  margin-left: 20px;
  margin-right: 20px;
`

export function TxPage ({ companyData, data, getNumberFunction, merchantData, modalIsOpen, setModalIsOpen, userData }) {
  const [createTransaction, setCreateTransaction] = useState(false)

  const openModal = () => {
    setModalIsOpen(true)
    setCreateTransaction(true)
  }

  const closeModal = () => {
    setModalIsOpen(false)
    setCreateTransaction(false)
  }

  return (
    <Wrapper>
      <TableWrapper>
        <TxTable
          companyData={companyData}
          data={data}
          getNumberFunction={getNumberFunction}
          merchantData={merchantData}
          modalIsOpen={modalIsOpen}
          setModalIsOpen={setModalIsOpen}
          userData={userData}
        />
      </TableWrapper>
      <AddTransactionButton onClick={openModal}>Add Transaction</AddTransactionButton>
      <TransactionFormModal
        closeModal={closeModal}
        companyData={companyData}
        merchantData={merchantData}
        modalIsOpen={modalIsOpen && createTransaction}
        userData={userData}
      />
    </Wrapper>
  )
}
TxPage.propTypes = {
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
  modalIsOpen: bool,
  setModalIsOpen: func
}
