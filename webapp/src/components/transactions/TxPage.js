import React, {useState} from 'react'

// import { arrayOf, string, bool, number, shape } from 'prop-types'
import styled from 'styled-components';
import { TxTable } from './TxTable'
import { NewTransactionModal } from './NewTransactionModal'

export const AddTransactionButton = styled.button`
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
`;

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  padding: 25px;
  margin-left: 20px;
  margin-right: 20px;
`;

const TableWrapper = styled.div`
  margin-left: 20px;
  margin-right: 20px;
`;

export function TxPage ({ data }) {

  const [modalIsOpen,setIsOpen] = useState(false);
  const openModal = () => {
    setIsOpen(true);
  }

  const closeModal = () => {

    setIsOpen(false);
  }

  return (
    <Wrapper>
    <TableWrapper>
        <TxTable data={data} />
    </TableWrapper>
      <AddTransactionButton onClick={openModal}>Add Transaction</AddTransactionButton>
      <NewTransactionModal modalIsOpen={modalIsOpen} closeModal={closeModal} />
    </Wrapper>
  );
};

