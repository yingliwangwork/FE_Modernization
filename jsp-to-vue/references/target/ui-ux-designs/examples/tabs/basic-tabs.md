# 一般分頁標籤

```vue
<template>
    <q-tabs v-model="tab" dense>
        <q-tab name="tab1" label="分頁一" />
        <q-tab name="tab2" label="分頁二" />
    </q-tabs>

    <q-tab-panels v-model="tab">
        <q-tab-panel name="basic">
            <!-- 分頁一內容 -->
            <div>分頁一</div>
        </q-tab-panel>
        <q-tab-panel name="history">
            <!-- 分頁二內容 -->
            <div>分頁二</div>
        </q-tab-panel>
    </q-tab-panels>
</template>

<script setup>
    import { ref } from 'vue'
    const tab = ref('tab1')
</script>
```