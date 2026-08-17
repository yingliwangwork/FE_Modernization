# 靜態表格範例

```vue
<template>
    <q-markup-table separator="cell" dense flat bordered>
        <!-- 表格內容-->
        <tbody>
            <tr>
                <td colspan="4">
                    _模式_
                </td>
                <td rowspan="2" class="text-center">
                    <q-btn label="查詢" color="primary" dense filled unelevated />
                </td>
            </tr>
            <tr>
                <td>訂單編號</td>
                <td>_訂單編號_</td>
                <td>訂單名稱</td>
                <td>_訂單名稱_</td>
            </tr>
        </tbody>
    </q-markup-table>
</template>
```