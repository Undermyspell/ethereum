<script setup lang="ts">
import { Ref, ref } from 'vue';
import Web3 from 'web3';

//@ts-ignore
const web3 = new Web3(window.ethereum)
const accounts: Ref<string[]> = ref([]);
const trump: Ref<any> = ref(null)
const biden: Ref<any> = ref(null)
const election: Ref<any> = ref(null)
const account: Ref<string> = ref('')
const balanceInEth: Ref<string> = ref('')

const init = async () => {
  const contractJson = await import('../build/contracts/Election.json')
  election.value = new web3.eth.Contract(contractJson.abi as any, '0xfb3bdBf46814A962b3248493368Cd3fE931E63D6')
  accounts.value = await web3.eth.getAccounts();
  trump.value = await election.value.methods.candidates(1).call();
  biden.value = await election.value.methods.candidates(2).call();

  election.value.events.votedEvent(null, (error: any, event: any) => console.log("Voted Event: ", event))
  election.value.events.resetEvent(null, async (error: any, event: any) => {
    trump.value = await election.value.methods.candidates(1).call();
    biden.value = await election.value.methods.candidates(2).call();
    console.log("Reset Event: ", event)
  })

  account.value = accounts.value[0]

  getBalance();

  console.log("Accounts: ", accounts.value)
}

const vote = async (candidateId: number) => {
  await election.value.methods.vote(candidateId).send({
    from: account.value,
  })

  const candidate = await election.value.methods.candidates(candidateId).call();

  if (candidateId === 1) {
    trump.value = candidate
  }

  if (candidateId === 2) {
    biden.value = candidate
  }

  getBalance();
}

const loginWithMetamask = async () => {
  //@ts-ignore
  const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
  account.value = accounts[0];

  getBalance()
}

const getBalance = async () => {
  if (!account.value) {
    return
  }

  const balanceInWei = await web3.eth.getBalance(account.value)

  balanceInEth.value = web3.utils.fromWei(balanceInWei, 'ether')
}

const resetVotes = async () => {
  await election.value.methods.resetVotes().send({
    from: account.value,
  })
}

init();

</script>

<template>
  <div class="flex flex-col items-center">
    <img alt="Vue logo" class="max-h-25 max-w-25" src="./assets/logo.png" />

    <button
      @click="loginWithMetamask()"
      class="bg-[#F8AE6B] hover:opacity-70 text-white font-bold py-2 px-4 mt-4"
    >Login with Metamask</button>

    <div
      v-if="!!account"
      class="flex flex-col rounded overflow-hidden shadow-lg p-5 h-50 w-120 my-4"
    >
      <div>Logged in as:</div>
      <div class="font-bold text-lg mb-2">{{ account }}</div>
      <div class="flex flex-col flex-1 items-center justify-center">
        <span>Your balance:</span>
        <span class="text-gray-700 text-2xl font-bold text-base">{{ balanceInEth }} ETH</span>
      </div>
    </div>

    <div class="flex gap-10">
      <div class="flex flex-col rounded overflow-hidden shadow-lg p-5 h-60 w-60">
        <div class="font-bold text-xl mb-2">{{ trump?.name }}</div>
        <div class="flex flex-1 items-center justify-center">
          <span class="text-gray-700 text-5xl text-base">{{ trump?.voteCount }}</span>
        </div>
        <div class="px-6">
          <button
            @click="vote(1)"
            class="bg-[#41B883] hover:opacity-70 text-white font-bold py-2 px-4 rounded-full"
          >Vote!</button>
        </div>
      </div>

      <div class="flex flex-col rounded overflow-hidden shadow-lg p-5 h-60 w-60">
        <div class="font-bold text-xl mb-2">{{ biden?.name }}</div>
        <div class="flex flex-1 items-center justify-center">
          <span class="text-gray-700 text-5xl text-base">{{ biden?.voteCount }}</span>
        </div>
        <div class="px-6">
          <button
            @click="vote(2)"
            class="bg-[#41B883] hover:opacity-70 text-white font-bold py-2 px-4 rounded-full"
          >Vote!</button>
        </div>
      </div>
    </div>

    <button
      @click="resetVotes()"
      class="bg-red-400 hover:opacity-70 text-white font-bold py-2 px-4 mt-4"
    >Reset votes</button>
  </div>
</template>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
