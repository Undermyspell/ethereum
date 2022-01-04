import express from 'express'
import Provider from '@truffle/hdwallet-provider'
import Web3 from 'web3'
import cors from 'cors'
import { readFileSync } from 'fs'
import { join } from 'path'
import dotenv from 'dotenv'

const app = express()
app.use(cors())
dotenv.config()
const port = 9000

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.get('/vote/:candidateId', async (req, res) => {
  const { candidateId } = req.params
  try {
    const payerProvider = new Provider({
      privateKeys: [process.env.ACCOUNT_PRIVATE_KEY],
      providerOrUrl: process.env.PROVIDER_URL
    })

    const web3Payer = new Web3(payerProvider)
    const jsonPath = join('..', 'build', 'contracts', 'Election.json')
    const contractJson = JSON.parse(readFileSync(jsonPath, 'utf8'))
    const networkId = await web3Payer.eth.net.getId()
    //@ts-ignore
    const electionPayer = new web3Payer.eth.Contract(contractJson.abi, contractJson.networks[networkId].address)
    const accs = await web3Payer.eth.getAccounts()

    /**
     * The vote method must have a parameter for the voter instead of using the msg.sender
     * Only the owner of the smart contract should be able to call the vote function.
     * The owner aka the account which deployed the contract has to be the account used in this route
     */
    await electionPayer.methods.vote(candidateId).send({
      from: accs[0]
    })
  } catch (error) {
    console.error(error)
  }
  res.send(candidateId)
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
