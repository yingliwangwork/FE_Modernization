# 日期選擇器範例

```vue
<template>
    <q-input v-model="selectedDate" :error="!!errors.selectedDate" :error-message="errors.selectedDate" dense outlined>
        <template #append>
            <q-icon name="event" class="cursor-pointer">
                <q-popup-proxy>
                    <q-date v-model="selectedDate" />
                </q-popup-proxy>
            </q-icon>
        </template>
    </q-input>
</template>
<script setup>
    import { ref } from 'vue'
    import { useForm, useField } from 'vee-validate'
    import { object } from 'yup'

    const validationSchema = object({
        // 驗證規則
    })

    const { errors } = useForm({
        validationSchema,
        initialValues: {
            selectedDate: '',
        },
        validateOnMount: false,
    })

    const { value: selectedDate } = useField('selectedDate')
</script>
```
