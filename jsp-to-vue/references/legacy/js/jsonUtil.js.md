# jsonUtil.js 公開契約

> 原始資源：`/CM/js/jsonUtil.js`

## **`JSONUtil.sampleJSON2Form3(formId, obj, tagNames, keys, alias)`**

### 用途

- 依欄位鍵值，將一個平面物件填入表單控制項及具識別的文字顯示元素。

### 輸入

- `formId`: [String|Element] - 由 Prototype `$()` 解析的目標元素。
  - 目標為 `<form>` 時，才會以 `form.getElements()` 取得表單控制項。
  - 無論是否為 `<form>`，都會搜尋其內具有 `id` 且不在上述控制項集合中的顯示元素。
- `obj`: [Object] - 平面來源物件；每個屬性值會轉成字串並移除首尾空白，`undefined` 轉成空字串。
- `tagNames`: [Array<String> = ["td", "span"]] - 允許直接更新內容的顯示元素標籤名稱；比對時會將實際標籤轉為小寫，但不轉換此陣列內容。
- `keys`: [Array<String> = Object.keys(obj)] - 本次要填入的來源鍵集合與處理順序。
- `alias`: [String = undefined] - truthy 時附加在每個來源鍵尾端，形成目標欄位名稱或識別。

### 輸出

- `return`: [undefined] - 此操作不回傳已處理欄位數或表單。

### 對外功能

- 對一般控制項呼叫 `setValue(value)`；對同名 radio／checkbox 集合，勾選值相等的項目。
- 對識別相符且標籤列於 `tagNames` 的非控制項呼叫 `update(value)`。

### 副作用

- 直接改寫控制項的值、radio／checkbox 勾選狀態與顯示元素內容。
- 不會主動取消其他 radio／checkbox 的既有勾選；只有值相符的項目被設為 `checked = true`。
- 單一鍵的解析或寫入例外會被攔截並忽略，後續鍵仍繼續處理。
- `formId` 無法解析或 `obj` 無效時，例外可能在逐鍵處理前發生且不會被攔截。

---

## **`JSONUtil.sampleJSON2Form2(formId, obj)`**

### 用途

- 在指定容器的所有後代元素中，依 `name`、`submitName` 或 `id` 對應平面物件資料。

### 輸入

- `formId`: [String|Element] - 由 Prototype `$()` 解析的表單或內容容器。
- `obj`: [Object] - 平面來源物件。
  - 字串值會移除首尾空白。
  - `undefined`、`null` 會轉成空字串。
  - 其他型別原樣交給目標元素。

### 輸出

- `return`: [undefined] - 此操作不回傳已處理欄位數。

### 對外功能

- 優先尋找 `name` 或 `submitName` 等於來源鍵的後代元素；完全找不到時，再以 `#id` 選取。
- `DIV`、`SPAN`、`TD`、`TEXTAREA` 以 `update(value)` 或 `innerHTML` 更新；一般輸入與選擇欄位以 `setValue` 或 `value` 屬性更新。
- checkbox／radio 只有在元素值等於來源值時設為勾選。

### 副作用

- 直接改寫所有符合相同鍵值的後代元素，可能同時影響多個目標。
- 顯示元素與 `TEXTAREA` 的內容未經轉義即交給 HTML 更新流程。
- 不會取消值不相符之 checkbox／radio 的原勾選狀態。
- 每個來源鍵的處理例外均被攔截並忽略；容器或資料無效時直接停止。

---

## **`JSONUtil.addOptions2(ele, obj)`**

### 用途

- 以物件的屬性名稱與值，重建選擇欄位的全部選項。

### 輸入

- `ele`: [String|Element] - 由 Prototype `$()` 解析且支援 `update()`、`insert()` 的選擇元素。
- `obj`: [Object] - 選項對照物件。
  - `Object.keys(obj)[]`: [String] - 選項的 `value` 與插入順序。
  - `obj[key]`: [Any] - 選項顯示內容，交給 Prototype `Element.update()`。

### 輸出

- `return`: [undefined] - 此操作不回傳選項元素或選擇欄位。

### 對外功能

- 先清空目標內容，再依 `Object.keys(obj)` 的順序建立 `<option value="{key}">`。

### 副作用

- 即使 `obj` 為 `undefined` 或 `null`，只要 `ele` 有效仍會先清除全部既有選項。
- 選項顯示內容未經本函式轉義即交給 `update()`。
- `ele` 為不存在的字串識別時，原始碼在解析後直接呼叫 `.update()`，可能拋出例外。
