import React, {useState} from 'react'
import Modal from 'react-modal'
import styled from 'styled-components';
import { useQuery, useMutation, gql } from '@apollo/client';

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
`;

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
`;

const Form = styled.div`
    display: flex;
    flex-direction: column;
`;

const Input = styled.input`
    font-size: 12px;
    height: 20px;
`;

const Label = styled.label`
    margin-left: 3px;
    padding-bottom: 2px;
    padding-top: 8px;
`;

const customStyles = {
  content : {
    top                   : '50%',
    left                  : '50%',
    right                 : 'auto',
    bottom                : 'auto',
    marginRight           : '-50%',
    transform             : 'translate(-50%, -50%)'
  }
};


const CREATE_TRANSACTION_MUTATION = gql`
mutation CreateTransaction($amount: Int!, $companyId: ID!, $merchantId: ID!, $userId: ID!, $credit: Boolean!, $debit: Boolean!, $description: String!){
    createTransaction(amount: $amount, companyId: $companyId, merchantId: $merchantId, userId: $userId, credit: $credit, debit: $debit, description: $description
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
`

export function NewTransactionModal({ modalIsOpen, openModal, closeModal }){
  var subtitle;

const [userId,setUserId] = useState("");
const [description,setDescription] = useState("");
const [merchantId,setMerchantId] = useState("");
const [companyId,setCompanyId] = useState("");
const [amount,setAmount] = useState(0);
const [debit,setDebit] = useState(true);
const [credit,setCredit] = useState(false);


const [createMutation]  = useMutation(CREATE_TRANSACTION_MUTATION, {
    variables: {
        userId,
        description,
        merchantId,
        debit,
        credit,
        companyId,
        amount
    }
})

    const handleBlur = (e, setVal) => {
        setVal(e.target.value)
    }

    const handleNumberBlur = (e, setVal) => {
        setVal(parseInt(e.target.value))
    }

    const handleFopBlur = (e) => {
        console.log(e.target.id)
        if(e.target.id == "debit"){
            setDebit(true);
            setCredit(false);
        }
        else{
            setCredit(true);
            setDebit(false);
        }
    }

  function afterOpenModal() {
    // references are now sync'd and can be accessed.
    subtitle.style.color = '#222222';
  }

    return (
      <div>
        <Modal
          isOpen={modalIsOpen}
          onAfterOpen={afterOpenModal}
          onRequestClose={closeModal}
          style={customStyles}
          contentLabel="Example Modal"
        >
 
          <h2 ref={_subtitle => (subtitle = _subtitle)}>Add Transaction</h2>
          <Form>
            <Label>User ID</Label>
            <Input id='userId' onBlur={(e) => handleBlur(e, setUserId)} />
            <Label>Description</Label>
            <Input id='description' onBlur={(e) => handleBlur(e, setDescription)}/>
            <Label>Merchant ID</Label>
            <Input id='merchantId' onBlur={(e) => handleBlur(e, setMerchantId)}/>
            <Label>Company ID</Label>
            <Input id='companyId' onBlur={(e) => handleBlur(e, setCompanyId)}/>
            <Label>Amount</Label>
            <Input id='amount' onBlur={(e) => handleNumberBlur(e, setAmount)}/>

            <Label>Form of payment</Label>
            <Input type='radio' id='debit' name="fop" checked={debit} onChange={(e) => handleFopBlur(e)}/>
            <label for="debit">Debit</label>
            <Input type='radio' id='credit' name="fop" checked={credit} onChange={(e) => handleFopBlur(e)}/>
            <label for="credit">Credit</label>
          </Form>
          <ExitButtonStyles onClick={closeModal}>Close</ExitButtonStyles>
          <CreateButtonStyles onClick={createMutation}>Create</CreateButtonStyles>
        </Modal>
      </div>
    );
}
 