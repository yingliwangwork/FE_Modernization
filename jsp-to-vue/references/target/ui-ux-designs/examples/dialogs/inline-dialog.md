# 頁面內嵌對話框範例

```vue
<template>
    <q-btn label="開啟彈窗" color="primary" dense filled unelevated @click="onOpenDialog" />
    <q-dialog full-width v-model="show">
        <q-card>
            <q-card-section class="scroll">
                <!-- 彈窗內容 -->
                <div>彈窗內容</div>
            </q-card-section>

            <q-card-actions align="right">
                <q-btn label="關閉" dense filled unelevated v-close-popup />
            </q-card-actions>
        </q-card>
    </q-dialog>
</template>

<script setup>
    import { ref } from 'vue'

    const show = ref(false)

    const onOpenDialog = () => {
        show.value = true
    }
</script>
```