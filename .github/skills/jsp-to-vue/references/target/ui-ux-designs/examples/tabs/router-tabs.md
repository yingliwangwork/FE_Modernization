# 路由分頁標籤範例

```vue
<template>
  <q-tabs dense>
    <q-route-tab to="/order/basic" label="基本資料" exact />
    <q-route-tab to="/order/history" label="異動紀錄" exact />
  </q-tabs>

  <router-view />
</template>
```
