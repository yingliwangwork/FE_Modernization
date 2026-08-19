# 複選按鈕元件範例

```vue
<template>
    <!-- 單選按鈕 -->
    <q-field :error="!!errors.selectedOption" :error-message="errors.selectedOption" dense borderless>
        <template #control>
            <div class="q-gutter-sm">
                <q-option-group v-model="selectedOption" :options="options" dense inline />
            </div>
        </template>
    </q-field>
    <!-- 複選按鈕 -->
    <q-field :error="!!errors.selectedOptions" :error-message="errors.selectedOptions" dense borderless>
        <template #control>
            <div class="q-gutter-sm">
                <q-option-group v-model="selectedOptions" :options="options" type="checkbox" dense inline />
            </div>
        </template>
    </q-field>
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
            selectedOptions: [],
        },
        validateOnMount: false,
    })

    const { value: selectedOption } = useField('selectedOption')
    const { value: selectedOptions } = useField('selectedOptions')
</script>
```