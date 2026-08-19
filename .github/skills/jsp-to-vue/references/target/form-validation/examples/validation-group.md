# 表單驗證群組範例

```vue
<template>
    <div class="q-gutter-sm">
        <!-- 訂單查詢區 -->
        <q-card flat bordered>
            <q-card-section>
                <div>訂單查詢</div>
            </q-card-section>

            <q-card-section>
                <q-markup-table separator="cell" dense flat bordered>
                    <tbody>
                        <tr>
                            <td>客戶ID</td>
                            <td>
                                <q-input v-model="customerId" :error="!!orderErrors.customerId"
                                    :error-message="orderErrors.customerId" dense outlined />
                            </td>
                            <td>訂單ID</td>
                            <td>
                                <q-input v-model="orderId" :error="!!orderErrors.orderId"
                                    :error-message="orderErrors.orderId" dense outlined />
                            </td>
                            <td>
                                <div class="column text-center q-gutter-sm">
                                    <q-btn label="訂單查詢" color="primary" dense filled unelevated @click="onQueryOrder" />
                                    <q-btn label="歷史訂單查詢" color="primary" dense filled unelevated
                                        @click="onQueryHistoryOrder" />
                                    <q-btn label="清空表單" color="primary" dense outline unelevated
                                        @click="onResetOrderForm" />
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </q-markup-table>
            </q-card-section>
        </q-card>

        <!-- 產品查詢區 -->
        <q-card flat bordered>
            <q-card-section>
                <div>產品查詢</div>
            </q-card-section>

            <q-card-section>
                <q-markup-table separator="cell" dense flat bordered>
                    <tbody>
                        <tr>
                            <td>產品ID</td>
                            <td>
                                <q-input v-model="productId" :error="!!productErrors.productId"
                                    :error-message="productErrors.productId" dense outlined />
                            </td>
                            <td>
                                <div class="column text-center q-gutter-sm">
                                    <q-btn label="產品查詢" color="primary" dense filled unelevated
                                        @click="onQueryProduct" />
                                    <q-btn label="清空表單" color="primary" dense outline unelevated
                                        @click="onResetProductForm" />
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </q-markup-table>
            </q-card-section>
        </q-card>
    </div>
</template>

<script setup>
    import { ref } from 'vue'
    import { useForm, useField } from 'vee-validate'
    import { string, object } from 'yup'

    // ---------- 訂單查詢 ----------
    // 共用規則
    const orderCommonSchema = {
        customerId: string().label("客戶ID").required(),
    }

    // 訂單查詢表單驗證規則
    const orderSchema = object({
        ...orderCommonSchema,
    })

    // 歷史訂單查詢表單驗證規則
    const orderHistorySchema = object({
        ...orderCommonSchema,
        orderId: string().label("訂單ID").required(),
    })

    // 訂單查詢表單驗證群組
    const orderValidationSchema = ref(orderSchema)
    const orderForm = useForm({
        validationSchema: orderValidationSchema,
        initialValues: {
            customerId: '',
            orderId: '',
        },
        validateOnMount: false,
    })
    const { errors: orderErrors, validate: validateOrder, resetForm: onResetOrderForm } = orderForm
    const { value: customerId } = useField('customerId', undefined, { form: orderForm })
    const { value: orderId } = useField('orderId', undefined, { form: orderForm })

    // 送出訂單查詢
    const onQueryOrder = async () => {
        orderValidationSchema.value = orderSchema
        const { valid } = await validateOrder()
        if (!valid) return
        // 驗證通過
    }

    // 送出歷史訂單查詢
    const onQueryHistoryOrder = async () => {
        orderValidationSchema.value = orderHistorySchema
        const { valid } = await validateOrder()
        if (!valid) return
        // 驗證通過
    }

    // ---------- 產品查詢 ----------
    // 產品查詢表單驗證規則
    const productValidationSchema = object({
        productId: string().label("產品ID").required(),
    })

    // 產品查詢表單驗證群組
    const productForm = useForm({
        validationSchema: productValidationSchema,
        initialValues: {
            productId: '',
        },
        validateOnMount: false,
    })
    const { errors: productErrors, validate: validateProduct, resetForm: onResetProductForm } = productForm
    const { value: productId } = useField('productId', undefined, { form: productForm })

    // 送出產品查詢
    const onQueryProduct = async () => {
        const { valid } = await validateProduct()
        if (!valid) return
        // 驗證通過
    }
</script>
```