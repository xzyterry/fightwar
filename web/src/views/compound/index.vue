<template>
  <div>
    <el-card style="width: 30%">
      <template #header>
        <div class="card-header">
          <span>武器合成</span>
        </div>
      </template>

      <el-row>
        <el-col :span="4"> 金币: </el-col>
        <el-col :span="10">
          <el-input-number v-model="coin" :min="100" @change="handleChange" />
        </el-col>
        <el-col :span="2">
          <el-button type="primary" @click="handleCompound">合成</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-card style="width: 70%; margin: 10px 0">
      <el-col>
        <el-row style="margin: 10px 0"> 地址: {{ tokenId }} </el-row>
        <el-row style="margin: 10px 0"> 名称: {{ name }} </el-row>
        <el-row style="margin: 10px 0"> 图片: {{ image }} </el-row>
        <el-row style="margin: 10px 0"> 等级: {{ level }} </el-row>
        <el-row style="margin: 10px 0"> 伤害: {{ damage }} </el-row>
      </el-col>
    </el-card>
  </div>
</template>

<script>
import Web3 from 'web3'
import contract from 'truffle-contract'
import weaponCore from '../../../../contract/build/contracts/WeaponCore.json'

export default {
  data() {
    return {
      coin: 1,
      tokenId: 0x0,
      name: '',
      image: '',
      level: 0,
      damage: 0
    }
  },

  async created() {
    await this.initWeb3Account()
    await this.initContract()
    await this.getTokens()
  },
  methods: {
    handleCompound() {
      // todo 校验金币是否足够
      this.wc
        .compound(this.account, this.coin, { from: this.account })
        .then(() => {
          this.getTokens()
        })
    },
    handleChange() {
      console.log(this.num)
    },
    async initWeb3Account() {
      if (window.ethereum) {
        this.provider = window.ethereum
        try {
          await window.ethereum.enable()
        } catch (e) {
          console.log('User denied account access')
        }
      } else if (window.web3) {
        this.provider = window.web3.currentProvider
      } else {
        this.provider = new Web3.providers.HttpProvider('http://127.0.0.1:7545')
      }

      this.web3 = new Web3(this.provider)
      this.web3.eth.getAccounts().then((acs) => {
        this.account = acs[0]
      })
    },
    async initContract() {
      const ct = contract(weaponCore)
      ct.setProvider(this.provider)
      this.wc = await ct.deployed()
    },
    async getTokens() {
      var wc = this.wc
      wc.getWeaponCount(this.account).then((r) => {
        wc.tokenOfOwnerByIndex(this.account, r - 1).then((r2) => {
          wc.getWeapon(r2).then((res) => {
            this.tokenId = res.seq
            this.level = res.level
            this.damage = res.level
            this.name = res.level + '级枪'
            this.image =
              'https://cube.elemecdn.com/6/94/4d3ea53c084bad6931a56d5158a48jpeg.jpeg'
          })
        })
      })
    }
  }
}
</script>
<style>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.text {
  font-size: 14px;
}

.item {
  margin-bottom: 18px;
}

.box-card {
  width: 480px;
}
</style>