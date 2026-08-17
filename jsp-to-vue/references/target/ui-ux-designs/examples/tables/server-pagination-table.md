<template>
    <q-table v-model:pagination="pagination" :columns="columns" :rows="rows" ref="tableRef"
        row-key="orderNo" dense bordered @request="onRequest" />
</template>

<script setup>
    import { inject, onMounted, ref, useTemplateRef } from 'vue'

    const $cathayAxios = inject('$cathayAxios')

    const pagination = ref({ page: 1, rowsPerPage: 10, rowsNumber: 0 })\
    const columns = [
        { name: 'orderNo', label: '訂單編號', field: 'orderNo', align: 'left', sortable: true },
        { name: 'orderDate', label: '訂單日期', field: 'orderDate', align: 'left' }
    ]
    const rows = ref([])
    const tableRef = useTemplateRef('tableRef')

    const onRequest = async ({ pagination: newPagination }) => {
        // 透過 API 取得資料
        const resp = await $cathayAxios.post('exa10001/query', {
            page: newPagination.page,
            rowsPerPage: newPagination.rowsPerPage
        })

        // 取得資料失敗則不更新表格資料
        if (resp.data.returnCode !== 0) return

        // 更新表格資料
        rows.value = resp.data.rowData
        pagination.value.page = newPagination.page
        pagination.value.rowsPerPage = newPagination.rowsPerPage
        pagination.value.rowsNumber = resp.data.rowData.total
    }

    onMounted(() => {
        // 取得第一筆資料
        tableRef.value.requestServerInteraction()
    })
</script>