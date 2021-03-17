import React, { useEffect, useState } from 'react'
import Modal from 'react-modal'
import { arrayOf, string, bool, func, shape, map, any } from 'prop-types'
import styled from 'styled-components'
import { useMutation, gql } from '@apollo/client'

const ExitButtonStyles = styled.button`
  border-radius: 4px;
  background-color: #626262;
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
  margin-right: 10px;
`

const DeleteButtonStyles = styled.button`
  border-radius: 4px;
  background-color: #c0392b;
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
  margin-right: 10px;
`

const CreateButtonStyles = styled.button`
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
  width: 100px;
`

const ButtonWrapper = styled.div`
  displaly: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
`

const Form = styled.div`
  display: flex;
  flex-direction: column;
`

const Input = styled.input`
  font-size: 12px;
  height: 20px;
`

const Label = styled.label`
  margin-left: 3px;
  padding-bottom: 2px;
  padding-top: 8px;
`

const customStyles = {
  content: {
    top: '50%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translate(-50%, -50%)'
  }
}

const CREATE_TRANSACTION_MUTATION = gql`
  mutation CreateTransaction(
    $amount: Int!
    $companyId: ID!
    $merchantId: ID!
    $userId: ID!
    $credit: Boolean!
    $debit: Boolean!
    $description: String!
  ) {
    createTransaction(
      amount: $amount
      companyId: $companyId
      merchantId: $merchantId
      userId: $userId
      credit: $credit
      debit: $debit
      description: $description
    ) {
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
`

const UPDATE_TRANSACTION_MUTATION = gql`
  mutation TransactionMutations(
    $id: ID!
    $amount: Int!
    $companyId: ID!
    $merchantId: ID!
    $userId: ID!
    $credit: Boolean!
    $debit: Boolean!
    $description: String!
  ) {
    updateTransaction(
      id: $id
      amount: $amount
      companyId: $companyId
      merchantId: $merchantId
      userId: $userId
      credit: $credit
      debit: $debit
      description: $description
    ) {
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
`
const DELETE_TRANSACTION_MUTATION = gql`
  mutation transactionMutations($id: ID!) {
    deleteTransaction(id: $id) {
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
`

export function TransactionFormModal ({
  closeModal,
  companyData,
  merchantData,
  modalIsOpen,
  transaction,
  userData
}) {
  var subtitle

  const [id, setId] = useState('')
  const [userId, setUserId] = useState('')
  const [description, setDescription] = useState('')
  const [merchantId, setMerchantId] = useState('')
  const [companyId, setCompanyId] = useState('')
  const [amount, setAmount] = useState(0)
  const [debit, setDebit] = useState(true)
  const [credit, setCredit] = useState(false)

  useEffect(() => {
    if (transaction) {
      setId(transaction.id)
      setUserId(transaction.userId)
      setDescription(transaction.description)
      setMerchantId(transaction.merchantId)
      setCompanyId(transaction.companyId)
      setAmount(transaction.amount)
      setDebit(transaction.debit)
      setCredit(transaction.credit)
    }
  }, [transaction])

  const [createMutation] = useMutation(CREATE_TRANSACTION_MUTATION, {
    variables: {
      userId,
      description,
      merchantId,
      debit,
      credit,
      companyId,
      amount: parseInt(amount)
    }
  })

  const [updateMutation] = useMutation(UPDATE_TRANSACTION_MUTATION, {
    variables: {
      id,
      userId,
      description,
      merchantId,
      debit,
      credit,
      companyId,
      amount: parseInt(amount)
    }
  })

  const [deleteMutation] = useMutation(DELETE_TRANSACTION_MUTATION, {
    variables: {
      id
    }
  })

  const clearTransaction = () => {
    setId('')
    setUserId()
    setDescription()
    setMerchantId()
    setCompanyId()
    setAmount(0)
    setDebit(true)
    setCredit(false)
  }

  const createTransaction = () => {
    createMutation()
    closeModal()
    clearTransaction()
  }

  const updateTransaction = () => {
    updateMutation()
    clearTransaction()
    closeModal()
  }

  const deleteTransaction = () => {
    deleteMutation()
    clearTransaction()
    closeModal()
  }
  const handleBlur = (e, setVal) => {
    setVal(e.target.value)
  }

  const handleFopBlur = (e) => {
    if (e.target.id === 'debit') {
      setDebit(true)
      setCredit(false)
    } else {
      setCredit(true)
      setDebit(false)
    }
  }

  function afterOpenModal () {
    subtitle.style.color = '#222222'
  }

  return (
    <div>
      <Modal
        ariaHideApp={false}
        contentLabel='Example Modal'
        isOpen={modalIsOpen}
        onAfterOpen={afterOpenModal}
        onRequestClose={closeModal}
        style={customStyles}
      >
        <h2 ref={(_subtitle) => (subtitle = _subtitle)}>{transaction ? 'Edit' : 'Create'} Transaction</h2>
        <Form>
          <Label>User</Label>
          <select id='userId' onBlur={(e) => handleBlur(e, setUserId)} onChange={(e) => handleBlur(e, setUserId)} value={userId}>
            <option defaultValue disabled hidden value=''>
              Select User
            </option>
            {userData.map((user) => {
              const { id, firstName, lastName } = user
              return <option key={`user-${id}`} value={id}>{firstName + ' ' + lastName}</option>
            })}
          </select>
          <Label>Merchant</Label>
          <select id='merchantId' onBlur={(e) => handleBlur(e, setUserId)} onChange={(e) => handleBlur(e, setMerchantId)} value={merchantId}>
            <option defaultValue disabled hidden value=''>
              Select Merchant
            </option>
            {merchantData.map((merchant) => {
              const { id, name } = merchant
              return <option key={`merchant-${id}`} value={id}>{name}</option>
            })}
          </select>

          <Label>Company</Label>
          <select id='companyId' onBlur={(e) => handleBlur(e, setUserId)} onChange={(e) => handleBlur(e, setCompanyId)} value={companyId} >
            <option defaultValue disabled hidden value=''>
              Select Company
            </option>
            {companyData.map((company) => {
              const { id, name } = company
              return <option key={`company-${id}`} value={id}>{name}</option>
            })}
          </select>

          <Label>Description</Label>
          <Input id='description' onChange={(e) => handleBlur(e, setDescription)} value={description} />
          <Label>Amount</Label>
          <Input id='amount' onChange={(e) => handleBlur(e, setAmount)} type='number' value={amount} />

          <Label>Form of payment</Label>
          <Input checked={debit} id='debit' name='fop' onChange={(e) => handleFopBlur(e)} type='radio' />
          <label htmlFor='debit'>Debit</label>
          <Input checked={credit} id='credit' name='fop' onChange={(e) => handleFopBlur(e)} type='radio' />
          <label htmlFor='credit'>Credit</label>
        </Form>
        <ButtonWrapper>
          <ExitButtonStyles onClick={closeModal}>Close</ExitButtonStyles>
          {transaction && (
            <DeleteButtonStyles onClick={deleteTransaction}>
              Delete
            </DeleteButtonStyles>
          )}
          {transaction ? (
            <CreateButtonStyles onClick={updateTransaction}>Update</CreateButtonStyles>
          ) : (
            <CreateButtonStyles onClick={createTransaction}>Create</CreateButtonStyles>
          )}
        </ButtonWrapper>
      </Modal>
    </div>
  )
}

TransactionFormModal.propTypes = {
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
  modalIsOpen: bool,
  closeModal: func,
  transaction: any
}
