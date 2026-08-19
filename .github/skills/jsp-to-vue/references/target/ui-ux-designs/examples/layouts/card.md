# 卡片元件範例

```vue
<template>
    <q-card flat bordered>
        <!-- 卡片標題 -->
        <q-card-section>
            <div>卡片標題</div>
        </q-card-section>

        <!-- 卡片內容 -->
        <q-card-section>
            <div>卡片內容</div>
        </q-card-section>

        <!-- 按鈕列  -->
        <q-card-actions align="right">
            <q-btn label="取消" dense filled unelevated />
            <q-btn label="確認" color="primary" dense filled unelevated />
        </q-card-actions>
    </q-card>
</template>
```