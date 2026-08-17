# 客戶端分頁表格範例

```vue
<template>
    <q-table :columns="columns" :rows="rows" row-key="orderNo" separator="cell" dense flat bordered />
</template>

<script setup>
    import { ref } from 'vue'

    const columns = [
        { name: 'orderNo', label: '訂單編號', field: 'orderNo', align: 'left', sortable: true },
        { name: 'orderDate', label: '訂單日期', field: 'orderDate', align: 'left' }
    ]

    const rows = ref([])
</script>
```