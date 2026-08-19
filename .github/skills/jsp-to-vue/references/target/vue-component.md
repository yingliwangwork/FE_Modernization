# Vue 元件規範

**必須**: Composition API(`<script setup>`); **禁止**: Options API
**必須**: 元件按照 `<template>` > `<script setup>` > `<style scoped>` 順序撰寫
**必須**: `v-for` 綁定唯一鍵值(`:key`); **禁止**: 以 `index` 作為鍵值
**必須**: 具名匯入; **禁止**: 預設或星號匯入(ex: `import Vue from 'vue'`、`import * as Vue from 'vue'`)
**必須**: 箭頭函式(Arrow Function)定義(`const func = () => {}`); **禁止**: Function Declaration 定義(`function func() {}`); **例外**: 函式依賴呼叫時 `this` 綁定以取得父層 context 者，得採 Function Declaration 定義
**必須**: 文字插值(`{{ }}`)或屬性綁定(`v-bind`)輸出內容; **禁止**: 使用 `v-html`，以避免 XSS 攻擊
**使用範例**:
```vue
<template>
<!-- 頁面佈局 -->
</template>
<script setup>
// 頁面邏輯
</script>
<style scoped>
/* 頁面樣式 */
</style>
```