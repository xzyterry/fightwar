<template>
  <div>
    <!-- 玩家信息 -->
    <el-row :gutter="20">
      <el-col :span="12">
        <el-card>
          <el-row :span="8"> 昵称: {{ role.nickname }} </el-row>
          <el-row :span="8">
            等级: {{ role.levelInfo.level }}级 {{ role.levelInfo.exp }}经验
          </el-row>

          <el-row :span="8"> 金币: {{ role.backpack.coin }} </el-row>
          <el-row :span="8"> 剩余子弹: {{ role.backpack.gun.bullet }} </el-row>
          <el-row :span="8"> CD: {{ role.backpack.gun.cd }} </el-row>
          <el-row :span="8"> 伤害: {{ role.backpack.gun.damage }} </el-row>
        </el-card>
      </el-col>

      <!-- boss信息 -->
      <el-col :span="12">
        <el-card>
          <el-row :span="8"> 当前关卡: {{ part.no }} </el-row>
          <el-row :span="8"> boss血量: {{ part.bossHp }} </el-row>
          <el-row :span="8"> boss奖励: {{ part.award }} </el-row>
        </el-card>
      </el-col>
    </el-row>

    <!-- 菜单 -->
    <el-row>
      <el-button @click="handleCreateRole">创建角色</el-button>
      <el-button @click="handleChoosePart">选择关卡</el-button>
      <el-button @click="handleShot">射击</el-button>
    </el-row>
    <!-- 游戏信息 -->
  </div>
</template>

<script>
import Web3 from 'web3'
import contract from 'truffle-contract'
import fightWar from '../../../../contract/build/contracts/FightWar.json'

export default {
  data() {
    return {
      role: {
        nickname: '',
        hp: 0,
        body: {
          height: 0,
          hairType: 0
        },
        levelInfo: {
          level: 0,
          exp: 0
        },
        backpack: {
          gun: {
            level: 0,
            star: 0,
            bullet: 0,
            lcbts: 0,
            damage: 0,
            cd: 0,
            ts: 0
          },
          coin: 0
        }
      },
      part: {
        no: 0,
        bossHp: 0,
        award: 0
      }
    }
  },

  async created() {
    //  初始化 web3及账号
    await this.initWeb3Account()
    //  初始化合约实例
    await this.initContract()
    //  获取合约的状态信息
    await this.getGameData()
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
      const ct = contract(fightWar)
      ct.setProvider(this.provider)
      this.fw = await ct.deployed()
    },
    async getGameData() {
      this.getBackpack()
      this.getLevelInfo()
      this.getRole()
      this.getPart()
      this.getCoin()
    },

    async getPart() {
      this.fw.getPart(this.account).then((r) => {
        this.part = r
      })
    },
    async getBackpack() {
      this.fw.getBackpack(this.account).then((r) => {
        console.log(r)
        this.role.backpack = r
      })
    },
    async getLevelInfo() {
      this.fw.getLevelInfo(this.account).then((r) => {
        this.role.levelInfo = r
      })
    },

    async getRole() {
      this.fw.getRole(this.account).then((r) => {
        if (r == null) {
          return
        }

        this.role.nickname = r.nickname
        this.role.hp = r.hp
        this.role.body = r.body
      })
    },
    async getCoin() {
      this.fw.getCoin(this.account).then((r) => {
        if (r == null) {
          return
        }

        this.role.backpack.coin = r
      })
    },
    async handleCreateRole() {
      this.fw
        .createRole(this.account, 'test', { from: this.account })
        .then(() => {
          this.getGameData()
        })
    },
    async handleChoosePart() {
      this.fw.choosePart(this.account, 1, { from: this.account }).then(() => {
        this.getGameData()
      })
    },
    async handleShot() {
      this.fw.fight(this.account, { from: this.account }).then(() => {
        this.getGameData()
      })
    }
  }
}
</script>