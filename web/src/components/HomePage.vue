<template>
  <div>
    <el-row>
      <el-col :span="4">
        <el-menu default-active="2" class="el-menu-vertical-demo">
          <el-menu-item index="2">
            <el-icon><box /></el-icon>
            <template #title>
              <router-link to="/">游戏战斗</router-link>
            </template>
          </el-menu-item>
          <el-menu-item index="3">
            <el-icon><setting /></el-icon>
            <template #title>
              <router-link to="/compound">武器合成 </router-link>
            </template>
          </el-menu-item>
          <el-menu-item index="4">
            <el-icon><shop /></el-icon>
            <template #title>
              <router-link to="/market">商城 </router-link>
            </template>
          </el-menu-item>

          <el-menu-item index="5">
            <el-icon><user /></el-icon>
            <template #title>
              <router-link to="/user">我的 </router-link>
            </template>
          </el-menu-item>
        </el-menu>
      </el-col>
      <el-col :span="20">
        <router-view></router-view>
      </el-col>
    </el-row>
  </div>
</template>

<script lang="js" setup>
import {
  Location,
  Document,
  Menu as IconMenu,
  Setting,
  User,
  Shop,
  Box
} from '@element-plus/icons-vue'


export default {
    components: {
        Location,
        Document,
        IconMenu,
        Setting,
        User,
        Shop,
        Box
    },
  data() {
    return {
      isCollapse: true
    }
  }
}
</script>

<style>
.el-menu-vertical-demo:not(.el-menu--collapse) {
  width: 200px;
  min-height: 400px;
}
</style>
