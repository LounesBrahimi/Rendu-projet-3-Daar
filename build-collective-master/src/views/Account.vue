<template lang="html">
  <div class="home" v-if="!account">
    <form @submit.prevent="signUp">
      <card
        title="Enter your username here to signUp"
        subtitle="Type directly in the input and hit enter. All spaces will be converted to _"
      >
        <input
          type="text"
          class="input-username"
          v-model="username"
          placeholder="Type your username here"
        />
      </card>
    </form>
      <div class="optional">
        <form @submit.prevent="connect">
      <card
        title="Connect to another account"
        subtitle="Type directly in the input and hit enter"
      >
        <input
          type="text"
          class="input-addressConnect"
          v-model="addressConnect"
          placeholder="Type your address here"
        />
        <input
          type="password"
          class="input-password"
          v-model="password"
          placeholder="password"
        />
      </card>
    </form>
  </div>
  </div>
  <div class="home" v-if="account">
    <div class="card-home-wrapper">
      <card  title="My Account">
        <div class="AccountInformations">
         <p>User Name : {{ account.username }}</p>
         <p>Balance : {{ account.balance }} Tokens</p>
         <p>Address : {{ address }}</p>
        </div>
        </card>
        <div>
          <div class="explanations">
              <form @submit.prevent="addTokens">
                <card
                  title="Enter amountTokens to add to your balance"
                  subtitle="Type directly in the input and hit enter"
                   >
                  <input
                    type="number"
                    class="input-amountTokens"
                    v-model="amountTokens"
                    placeholder="Type your amountTokens here"
                  />
                </card>
             </form>
          </div>
        </div>
        <div class ="creation of enterprise">
          <form @submit.prevent="createEntreprise">
                <card
                  title="Enter a name and a siren to your new enterprise"
                  subtitle="Type directly in the input and hit enter"
                   >
                 <input
                  type="text"
                  class="input-nameEnterprise"
                  v-model="nameEnterprise"
                  placeholder="Name of your enterprise here"
                  />
                  <input
                    type="number"
                    class="input-siren"
                    v-model="siren"
                    placeholder="Type the siren number here"
                  />
                </card>
             </form>
          </div>

    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
export default defineComponent({
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const account = null
    const username = ''
    const amountTokens = 0
    const addressConnect = ''
    const password = ''
    return { account, username, amountTokens, addressConnect, password }
  },
  methods: {
    async updateAccount() {
      const { address, contract } = this
      this.account = await contract.methods.user(address).call()
    },
    async signUp() {
      const { contract, username } = this
      const name = username.trim().replace(/ /g, '_')
      await contract.methods.signUp(name).send()
      await this.updateAccount()
      this.username = ''
    },
    async addTokens() {
      const { contract, amountTokens } = this
      await contract.methods.addBalance(amountTokens).send()
      await this.updateAccount()
    },
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    if (account.registered) this.account = account
  },
    async connect() {
    const { addressConnect, contract, password } = this
    this.account = await contract.methods.user(contract.methods.convertStrToAddress(addressConnect)).call()
  }
})
</script>

<style lang="css" scoped>
.home {
  padding: 24px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  max-width: 500px;
  margin: auto;
}
.explanations {
  padding: 12px;
}
.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}
.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}
</style>