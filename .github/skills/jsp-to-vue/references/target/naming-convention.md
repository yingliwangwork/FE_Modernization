# 命名規範

## 檔案命名

| 對象 | 規則 | 範例 |
|---|---|---|
| Vue 元件檔 | PascalCase | `OrderDetail.vue` |
| 資料夾與非 Vue 檔案 | kebab-case | `order-detail/`、`format-utils.js` |

---

## 程式碼命名

| 對象 | 規則 | 範例 |
|---|---|---|
| 變數、方法、Props | camelCase | `orderDate`、`fetchOrderList` |
| Emits 事件 | kebab-case | `emit('update-status')` |
| 常數 | UPPER_SNAKE_CASE | `const MAX_RETRY = 3` |
| 類別、介面、模板 | PascalCase | `class OrderDetail`、`interface OrderDetailProps`、`<OrderDetailTemplate />` |
| API Endpoint | flatcase | `exa10001/showdetail` |

---

## 樣式命名

| 對象 | 規則 | 範例 |
|---|---|---|
| CSS 自訂類別 | kebab-case (BEM) | `order-detail__field` |