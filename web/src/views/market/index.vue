<template>
  <div style="margin: 2em 0em">
    <el-row :gutter="20">
      <el-col :span="6" v-for="dt in tableData" v-bind:key="dt.id">
        <el-card style="margin-top: 20px">
          <el-row>
            <el-image :src="dt.src"></el-image>
          </el-row>
          <el-row style="margin-top: 20px">
            <el-descriptions :column="1">
              <el-descriptions-item label="名称">
                {{ dt.name }}
              </el-descriptions-item>
              <el-descriptions-item label="卖价">
                {{ dt.price }}
              </el-descriptions-item>
              <el-descriptions-item label="等级">
                {{ dt.level }}
              </el-descriptions-item>
              <el-descriptions-item label="伤害">
                {{ dt.damage }}
              </el-descriptions-item>
            </el-descriptions>
          </el-row>
          <el-row>
            <el-col :offset="18">
              <!-- todo 添加确认对话框 -->
              <el-button v-if="isMine(dt.id)" @click="handleBuy(dt.id)">
                购买
              </el-button>
              <el-button v-else @click="handleCancelSale(dt.id)">
                下架
              </el-button>
            </el-col>
          </el-row>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import Web3 from 'web3'
import contract from 'truffle-contract'
import tradeMarket from '../../../../contract/build/contracts/TradeMarket.json'
import weaponCore from '../../../../contract/build/contracts/WeaponCore.json'

export default {
  async created() {
    await this.initWeb3Account()
    await this.initContract()
    await this.findAllCommodities()
  },
  data() {
    return {
      tableData: [],
      myWeapons: []
    }
  },
  methods: {
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
      const ct = contract(tradeMarket)
      ct.setProvider(this.provider)
      this.tm = await ct.deployed()

      const ct2 = contract(weaponCore)
      ct2.setProvider(this.provider)
      this.wc = await ct2.deployed()
    },
    async findAllCommodities() {
      var BN = this.web3.utils.BN

      this.tableData = []
      var tokenIds = await this.tm.pageCommodities(1, 10).then((res) => {
        return res
      })

      await tokenIds.forEach((tokenId) => {
        var id = new BN(tokenId).toString()
        if (id === '0') {
          return
        }

        this.tm.getCommodity(tokenId).then((commodity) => {
          this.wc.getWeapon(tokenId).then((weapon) => {
            var obj = {
              id: id,
              src: 'https://cube.elemecdn.com/6/94/4d3ea53c084bad6931a56d5158a48jpeg.jpeg',
              name: weapon.level + '级枪',
              price: commodity.price,
              level: weapon.level,
              damage: weapon.damage
            }

            this.tableData.push(obj)
          })
        })
      })
    },
    async handleBuy(tokenId) {
      this.tm.purchase(tokenId, { from: this.account }).then(() => {
        this.$message.success('购买成功')
        // todo 跳转到详情页
      })
    },
    async handleCancelSale(tokenId) {
      this.tm.cancelSale(tokenId, { from: this.account }).then(() => {
        this.$message.success('下架成功')
        this.findAllCommodities()
      })
    },
    isMine(tokenId) {
      return this.myWeapons.indexOf(tokenId) > -1
    }
  }
}
</script>
<style>
.el-col {
  border-radius: 4px;
}
.bg-purple-dark {
  background: #99a9bf;
}
.bg-purple {
  background: #d3dce6;
}
.bg-purple-light {
  background: #e5e9f2;
}
.grid-content {
  border-radius: 4px;
  min-height: 36px;
}
.row-bg {
  padding: 10px 0;
  background-color: #f9fafc;
}
</style>