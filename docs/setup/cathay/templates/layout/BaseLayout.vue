<template>
  <!-- 浮水印 -->
  <WaterMaker :show="displayWaterMark" :default-display="true" :input-text="inputText" />

  <q-layout view="hHh Lpr lff" container class="window-height">
    <!-- 標題列 -->
    <AppHeader @toggle-drawer="toggleDrawer" />

    <!-- 側邊欄 -->
    <AppDrawer v-model="drawer" />

    <!-- 頁面內容 -->
    <q-page-container>
      <q-page padding>
        <RouterView />
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script setup>
  import { ref } from "vue";
  import WaterMaker from "./common/WaterMaker.vue";
  import AppHeader from "./layout/AppHeader.vue";
  import AppDrawer from "./layout/AppDrawer.vue";

  const displayWaterMark = ref(true)
  const inputText = ref('浮水印範例文字')
  const drawer = ref(false)

  /** 切換側邊欄開關 */
  const toggleDrawer = () => {
    drawer.value = !drawer.value
  }
</script>
