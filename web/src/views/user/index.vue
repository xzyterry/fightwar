<template>
  <div>
    <el-row style="width: 80em; height: 60em; margin: 5em 2em">
      <div style="width: 80%; height: 80%">
        <el-tabs
          v-model="activeName"
          class="demo-tabs"
          type="border-card"
          @tab-click="handleClick"
        >
          <el-tab-pane label="基本信息" name="first">
            <el-descriptions class="margin-top" :column="1" :size="size" border>
              <el-descriptions-item>
                <template #label>
                  <div class="cell-item">昵称</div>
                </template>
                xzy
              </el-descriptions-item>
              <el-descriptions-item>
                <template #label>
                  <div class="cell-item">账户地址</div>
                </template>
                0x0
              </el-descriptions-item>
              <el-descriptions-item>
                <template #label>
                  <div class="cell-item">头像</div>
                </template>
                ''
              </el-descriptions-item>
              <el-descriptions-item>
                <template #label>
                  <div class="cell-item">余额</div>
                </template>
                <el-tag size="small">0</el-tag>
              </el-descriptions-item>
            </el-descriptions>
          </el-tab-pane>
          <el-tab-pane label="武器" name="second">
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
                      <el-button @click="handleSale(dt.id)"> 出售 </el-button>
                    </el-col>
                  </el-row>
                </el-card>
              </el-col>
            </el-row>
          </el-tab-pane>
        </el-tabs>
      </div>
    </el-row>

    <el-dialog v-model="dialogFormVisible" title="出售">
      <el-form :model="form">
        <el-form-item label="出售价格" :label-width="formLabelWidth">
          <el-input-number v-model="form.price" :min="1" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogFormVisible = false">取消</el-button>
          <el-button type="primary" @click="confirmSale"> 确认 </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.el-descriptions {
  margin-top: 20px;
}
.cell-item {
  display: flex;
  align-items: center;
}
.margin-top {
  margin-top: 20px;
}
</style>

<style>
.demo-tabs > .el-tabs__content {
  padding: 32px;
  background-color: #f4f5f7;
  color: #6b778c;
  font-size: 32px;
  font-weight: 600;
}
</style>

<script>
import Web3 from 'web3'
import contract from 'truffle-contract'
import weaponCore from '../../../../contract/build/contracts/WeaponCore.json'
import tradeMarket from '../../../../contract/build/contracts/TradeMarket.json'

export default {
  async created() {
    await this.initWeb3Account()
    await this.initContract()
    await this.getTokens()
  },
  data() {
    return {
      activeName: 'first',
      tableData: [],
      dialogFormVisible: false,
      form: {
        tokenId: 0,
        price: 0
      }
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
      const ct = contract(weaponCore)
      ct.setProvider(this.provider)
      this.wc = await ct.deployed()

      const ct2 = contract(tradeMarket)
      ct2.setProvider(this.provider)
      this.tm = await ct2.deployed()
    },
    async getTokens() {
      var wc = this.wc
      wc.getWeapons(this.account).then((r) => {
        this.tableData = []
        if (r === null || r.length <= 0) {
          return
        }

        var weapons = []
        r.forEach((tokenId) => {
          wc.getWeapon(tokenId).then((res) => {
            var w = {
              id: tokenId,
              src: 'https://cube.elemecdn.com/6/94/4d3ea53c084bad6931a56d5158a48jpeg.jpeg',
              name: res.level + '级枪',
              level: res.level,
              damage: res.damage
            }
            weapons.push(w)
          })
        })

        this.tableData = weapons
      })
    },
    handleSale(tokenId) {
      this.dialogFormVisible = true
      this.form.tokenId = tokenId
    },
    async confirmSale() {
      // todo 表单校验
      this.dialogFormVisible = false
      await this.wc
        .approve(this.tm.address, this.form.tokenId, { from: this.account })
        .then(() => {
          this.wc.getApproved(this.form.tokenId).then(() => {
            this.tm
              .createCommodity(this.form.tokenId, this.form.price, {
                from: this.account
              })
              .then(() => {
                this.$message.success('上架成功')
                this.getTokens()
              })
              .catch((e) => {
                console.log(e)
              })
          })
        })
        .catch((e) => {
          console.log(e)
        })
    }
  }
}
</script>