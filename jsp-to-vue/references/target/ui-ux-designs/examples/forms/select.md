# 下拉選單元件範例

```vue
<template>
    <q-select v-model="selectedOption" :options="options" option-label="label" option-value="value"
        :error="!!errors.selectedOption" :error-message="errors.selectedOption" dense outlined />
</template>
<script setup>
    import { ref } from 'vue'
    import { useForm, useField } from 'vee-validate'
    import { object } from 'yup'

    const options = ref([
        { label: '選項1', value: 'option1' },
        { label: '選項2', value: 'option2' },
    ])

    const validationSchema = object({
        // 驗證規則
    })

    const { errors } = useForm({
        validationSchema,
        initialValues: {
            selectedOption: null,
        },
        validateOnMount: false,
    })

    const { value: selectedOption } = useField('selectedOption')
</script>
```