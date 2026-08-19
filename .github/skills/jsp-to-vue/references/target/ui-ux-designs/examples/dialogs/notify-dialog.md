# 通知對話框範例

```vue
<template>
    <q-btn label="開啟通知" color="primary" dense filled unelevated @click="onNotify" />
</template>

<script setup>
    import { useQuasar } from 'quasar';

    const $q = useQuasar()

    const onNotify = () => {
        $q.notify("通知訊息")
    }
</script>
```