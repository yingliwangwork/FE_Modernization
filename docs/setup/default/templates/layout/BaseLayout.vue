<template>
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
  import { ref, onMounted } from 'vue'
  import { setWatermark } from './modules/water-maker'
  import AppHeader from './layout/AppHeader.vue'
  import AppDrawer from './layout/AppDrawer.vue'

  const drawer = ref(false)

  /** 切換側邊欄開關 */
  const toggleDrawer = () => {
    drawer.value = !drawer.value
  }

  onMounted(() => {
    setWatermark()
  })
</script>
