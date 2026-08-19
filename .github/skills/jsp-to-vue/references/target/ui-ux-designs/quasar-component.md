# 元件使用規範

## 按鈕元件
**使用情境**: 按鈕(例如: 送出、取消、刪除)
**使用方式**: `<q-btn>`
**預設使用樣式**:
- **主要按鈕**: `color="primary" dense filled unelevated`
- **次要按鈕**: `color="primary" dense outlined unelevated`

**使用範例**:
```html
<q-btn label="按鈕" color="primary" dense filled unelevated />
```

---

## 表單元件

### 文字輸入框
**使用情境**: 文字輸入框(例如: 帳號、姓名、電話)
**使用方式**: `<q-input>`
**預設使用樣式**: `dense outlined`
**使用範例**:
```html
<q-input v-model="model" :error="!!errors.fieldName" :error-message="errors.fieldName" dense outlined />
```

### 檔案選擇元件
**使用情境**: 檔案選擇(例如: 上傳圖片、文件)
**使用方式**: `<q-file>`
**預設使用樣式**: `dense outlined`
**使用範例**:
```html
<q-file v-model="model" :error="!!errors.fieldName" :error-message="errors.fieldName" dense outlined />
```

### 單選/複選按鈕元件
**使用情境**: 單選按鈕(例如: 性別、是否同意)/複選按鈕(例如: 興趣、技能)
**使用方式**: `<q-field>` + `<q-option-group>`
**預設使用樣式**: `dense inline`
**使用範例**: [單選/複選按鈕元件範例](./examples/forms/radio-checkbox.md)

### 下拉選單元件
**使用情境**: 單選下拉選單(例如: 性別、國家、城市)
**使用方式**: `<q-select>`
**預設使用樣式**: `dense outlined`
**使用範例**: [下拉選單元件範例](./examples/forms/select.md)

### 日期選擇元件
**使用情境**: 日期選擇(例如: 出生日期、預約日期)
**使用方式**: `<q-input>` + `<q-icon>` + `<q-popup-proxy>` + `<q-date>`
**預設使用樣式**: `dense outlined`
**使用範例**: [日期選擇元件範例](./examples/forms/date.md)

---

## 對話框元件
### 通知對話框
**使用情境**: 單向通知訊息(例如: 操作成功、操作失敗)
**使用方式**: `$q.notify`
**使用範例**: [通知對話框範例](./examples/dialogs/notify-dialog.md)

### 頁面內嵌對話框
**使用情境**: (例如: 表格單列明細資料查看/編輯、確認是否刪除)
**使用方式**: `<q-dialog>` + `<q-card>` + `<q-card-section>` + `<q-card-actions>`
**使用範例**: [頁面內嵌對話框範例](./examples/dialogs/inline-dialog.md)

---

## 佈局元件

### 卡片元件
**使用情境**: 區塊容器(例如: 查詢區塊、明細資料區塊、圖表區塊)
**使用方式**: `<q-card>` + `<q-card-section>` + `<q-card-actions>`
**使用範例**: [卡片元件範例](./examples/layouts/card.md)

### 靜態表格
**使用情境**: 固定欄位、固定資料量的表格 (例如: 查詢結果、明細資料)
**使用方式**: `<q-markup-table>`
**預設使用樣式**: `separator="cell" dense flat bordered`
**使用範例**: [靜態表格範例](./examples/tables/static-table.md)

### 客戶端分頁表格
**使用情境**: 資料數量不固定、且資料量不大
**使用方式**: `<q-table>`
**預設使用樣式**: `separator="cell" dense flat bordered`
**使用範例**: [客戶端分頁表格範例](./examples/tables/client-pagination-table.md)

### 伺服器端分頁表格
**使用情境**: 資料數量不固定、且資料量較大
**使用方式**: `<q-table>` + `@pagination` + `@request`
**預設使用樣式**: `separator="cell" dense flat bordered`
**使用範例**: [伺服器端分頁表格範例](./examples/tables/server-pagination-table.md)

---

## 分頁標籤元件
### 一般分頁標籤
**使用情境**:
**使用方式**: `<q-tabs>` + `<q-tab>` + `<q-tab-panels>` + `<q-tab-panel>`
**預設使用樣式**: `dense`
**使用範例**: [一般分頁標籤](./examples/tabs/basic-tabs.md)

### 路由分頁標籤
**使用情境**:
**使用方式**: `<q-tabs>` + `<q-route-tab>` + `<router-view>`
**預設使用樣式**: `dense`
**使用範例**: [路由分頁標籤範例](./examples/tabs/router-tabs.md)