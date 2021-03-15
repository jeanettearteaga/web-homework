import React from 'react'
import { arrayOf, string, bool, number, shape } from 'prop-types'
import styled from 'styled-components';

const Table = styled.table`
  width: 100%;
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
    overflow-y: scroll;
     display: block;  
     height: 500px;
  }

 .header td{
  padding 18px;
 }

 .transactions td{
  border: 1px solid #ddd;
  padding 18px;
 }

 .transactions:nth-child(even) {
   background-color: #f2f2f2;
 }

 .transactions:hover {
  background-color: #ddd;
}

`

const makeDataTestId = (transactionId, fieldName) => `transaction-${transactionId}-${fieldName}`

export function TxTable ({ data }) {
  return (
      <Table>
        <colgroup>
        <col style={{ width: `20%`}} />
        <col style={{ width: `20%`}} />
        <col style={{ width: `20%`}} />
        <col style={{ width: `10%`}} />
        <col style={{ width: `20%`}} />
        <col style={{ width: `5%`}} />
        <col style={{ width: `5%`}} />
        </colgroup>
        <tbody className = 'body'>
          <tr className='header'>
            <td >ID</td>
            <td >User ID</td>
            <td >Company ID</td>
            <td >Description</td>
            <td >Merchant ID</td>
            <td >Debit</td>
            <td >Amount</td>
          </tr>
          {
            data.map(tx => {
              const { id, userId, companyId, description, merchantId, debit, amount } = tx
              return (
                <tr className='transactions' data-testid={`transaction-${id}`} key={`transaction-${id}`}>
                  <td data-testid={makeDataTestId(id, 'id')}>{id}</td>
                  <td data-testid={makeDataTestId(id, 'userId')}>{userId}</td>
                  <td data-testid={makeDataTestId(id, 'companyId')}>{companyId}</td>
                  <td data-testid={makeDataTestId(id, 'description')}>{description}</td>
                  <td data-testid={makeDataTestId(id, 'merchant')}>{merchantId}</td>
                  <td data-testid={makeDataTestId(id, 'debit')}>{debit ? "debit" : "credit"}</td>
                  <td data-testid={makeDataTestId(id, 'amount')}>{amount}</td>
                </tr>
              )
            })
          }
        </tbody>
      </Table>
  )
}

TxTable.propTypes = {
  data: arrayOf(shape({
    id: string,
    user_id: string,
    company_id: string,
    description: string,
    merchant_id: string,
    debit: bool,
    amount: number
  }))
}
