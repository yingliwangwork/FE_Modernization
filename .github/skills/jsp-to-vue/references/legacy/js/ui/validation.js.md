# validation.js 公開契約

## 使用語法清單
**變數**:
- [Validation.mode](#Validation.mode)
- [Validator.methods](#Validator.methods)

**方法**:
- [Validation](#Validation)
    - [constructor(form, options)](#constructor(form,-options))
    - [validate()](#validate())
    - [validate(info)](#validate(info))
    - [reset()](#reset())
    - [reset(isOnlyForm)](#reset(isOnlyForm))
    - [define(method_name, inputs)](#define(method_name,-inputs))
    - [clear()](#clear())
- [Validation.add(className, error, test)](#Validation.add(className,-error,-test))
- [Validation.addAllThese(validators)](#Validation.addAllThese(validators))
- [Validation.get(name)](#Validation.get(name))
- [Validation.test(name, elm)](#Validation.test(name,-elm))
- [Validation.test(name, elm, useTitle, info)](#Validation.test(name,-elm,-useTitle,-info))
- [Validation.reset(elm)](#Validation.reset(elm))

---

## 共用模式
- 檢核規則以「規則名稱」字串識別（例如 `required`、`validate-number`），對應之檢核邏輯須先透過 `Validation.add`／`Validation.addAllThese` 註冊。規則名稱亦可作為目標欄位之樣式名稱使用：欄位若標記該樣式名稱，於表單整體檢核（`Validation` 執行個體之 `validate()`）時即會套用對應規則。
- 本檔案載入時即預先註冊下列具名檢核規則（依規則名稱可透過 `Validation.get(name)` 取得，或以樣式名稱套用於欄位）：
  - `IsEmpty`：內容是否為空值
  - `required`：內容不可為空
  - `validate-number`：是否為有效數字格式
  - `validate-positive-number`：是否為有效正數
  - `validate-integer`：是否為有效整數
  - `validate-digits`：是否為有效正整數
  - `validate-positive`：是否為大於零之有效正整數
  - `validate-date`：是否為可解析之日期
  - `validate-email`：是否為有效電子郵件地址格式
  - `validate-date-db`：是否為 `YYYY-MM-DD` 格式之有效日期
  - `validate-selection`：下拉選單是否已選取（非預設之第一個選項）
  - `validate-one-required`：同群組選項中是否至少已選取一項
  - `validate-positive-integer`：是否為大於零之有效整數
  - `validate-Date-Interval`：兩西元日期欄位（迄 − 起）是否不為負值
  - `validate-ROCDate`：是否為正確之民國日期格式
  - `validate-ROCDate-Interval`：兩民國日期欄位（迄 − 起）是否不為負值
  - `validate-ROCDateYM`：是否為正確之民國年月格式
  - `checkInputLength`：輸入值是否超出欄位長度限制
  - `checkUniSN`：是否為正確之統一編號格式
  - `hasFullType`／`hasHalfType`：是否含半形／全形文字
  - `checkROCID`：是否為正確之身分證字號格式
  - `checkID`：是否為正確之證件格式
  - 呼叫端亦可透過 `Validation.add`／`Validation.addAllThese` 註冊額外之自訂規則名稱。
- 建構 `Validation` 執行個體時之 `options` 設定物件，除下列各方法段落所載之常用欄位外，另包含 `onSubmit`（表單送出時是否自動觸發整體檢核）、`stopOnFirst`（是否於第一個檢核失敗欄位即停止）、`checkReadOnly`（是否略過唯讀欄位，預設為略過）、`toNextError`（即時檢核失敗後是否自動跳至下一個錯誤欄位）、`notIgnoreHidden`（是否仍檢核隱藏欄位）、`onFormValidate`／`onElementValidate`（整體／單一欄位檢核完成後之回呼）等欄位。

---

## Validation

### constructor(form, options)
**使用範例**: `new Validation('form1', {useTitles:true, mode : 'validate'})`
**輸入**:
- form: 字串 - 目標表單之識別碼
- options: 物件 - 檢核設定
  - options.mode: 字串 - 採用之檢核模式，`'validate'` 或 `'validator'`；省略時採系統預設模式
  - options.useTitles: 布林值 = false - 欄位檢核失敗時，是否優先以欄位之提示標題文字取代規則預設之錯誤訊息
  - options.focusOnError: 布林值 = true - 整體檢核失敗時，是否自動將焦點移至第一個失敗欄位
  - options.immediate: 布林值 = false - 是否於欄位內容變更時即時進行單一欄位檢核
  - options.checkDisabled: 布林值 = false - 是否仍檢核已停用（disabled）之欄位
**輸出**:
- 執行個體: Validation - 已綁定目標表單之檢核控制物件
**功能**:
- 依 options 建立表單檢核設定
- **當 options.onSubmit 為真時**: 額外綁定表單送出事件以自動觸發整體檢核
- **當 options.immediate 為真時**: 為表單內所有欄位綁定內容變更事件，變更時即時進行該欄位之單一檢核，檢核失敗時可依 options.toNextError 設定自動跳至下一個錯誤欄位

---

### validate()
**使用範例**: `valid.validate()`
**輸入**: 無
**輸出**:
- 布林值 - 表單內所有欄位（含已透過 `define` 定義之多欄位聯合檢核）是否皆通過檢核
**功能**:
- 依建構時之 options 設定，逐一檢核表單內各欄位所標記之規則名稱，以及已透過 `define` 定義之多欄位聯合規則
- **當任一檢核失敗時**: 於欄位旁顯示對應規則之錯誤提示文字，並標記欄位之失敗樣式
- **當任一檢核失敗且 options.focusOnError 為真時**: 將焦點移至第一個可視之失敗欄位
- 檢核完成後觸發建構時設定之整體檢核完成回呼

---

### validate(info)
**使用範例**: `valid1.validate(rec)`
**輸入**:
- info: 物件 - 傳遞至各欄位檢核函式之附加內容（例如即時檢核情境下之 `{showAlert:true}`）
**輸出**:
- 布林值 - 表單內所有欄位是否皆通過檢核
**功能**:
- 行為同無參數之 `validate()`，另將 info 轉發至每個欄位對應規則之檢核函式，供規則內部依 info 之內容調整檢核行為（例如是否即時跳出提示）

---

### reset()
**使用範例**: `valid.reset()`
**輸入**: 無
**輸出**: 無
**功能**:
- 清除表單內所有欄位之檢核結果標記與錯誤提示顯示
- 同時清除已透過 `define` 定義之多欄位聯合檢核所留下之標記

---

### reset(isOnlyForm)
**使用範例**: `valid.reset(true)`
**輸入**:
- isOnlyForm: 布林值 - 是否僅清除表單欄位本身之檢核標記；**傳入非 `true` 之值時**，一併清除已透過 `define` 定義之多欄位聯合檢核標記
**輸出**: 無
**功能**:
- 依 isOnlyForm 決定清除範圍

---

### define(method_name, inputs)
**使用範例**: `valid.define('required', [{id:'SEPERATE_ACNTCODE_IN'}])`
**輸入**:
- method_name: 字串 - 欲套用之檢核規則名稱
- inputs: 物件 | 物件[] - 參與此聯合檢核之欄位描述，每筆至少含 `id`（欄位識別碼），可另含 `errMsg`（自訂錯誤訊息）等資訊
**輸出**: 無
**功能**:
- 註冊一組跨欄位（或單一欄位）之聯合檢核規則，於整體 `validate()` 執行時一併套用
- 同一 method_name 可重複呼叫以累加多組聯合檢核定義

---

### clear()
**使用範例**: `valid.clear()`
**輸入**: 無
**輸出**: 無
**功能**:
- 清空所有已透過 `define` 註冊之聯合檢核定義

---

## Validation.add(className, error, test)
**使用範例**: `Validation.add( "validate-isATMLOGTXT" , "匯入檔案必須為Atmlog.TXT!" , isATMLOGTXT )`
**輸入**:
- className: 字串 - 欲註冊之檢核規則名稱
- error: 字串 - 檢核失敗時預設顯示之錯誤訊息
- test: 函式 - 檢核邏輯函式，傳入欄位值（及欄位、附加內容等）並回傳布林值表示是否通過
- options: 物件 = {} - 附加檢核選項（未於查驗範圍內觀察到實際帶入非預設值之呼叫）
**輸出**: 無
**功能**:
- 註冊一筆具名檢核規則，供後續以樣式名稱套用於欄位，或以 `Validation.get(className)` 取得後手動呼叫

---

## Validation.addAllThese(validators)
**使用範例**:
```
Validation.addAllThese([
    ['validate-digits-with-gt-lt', '', function(v, elem) {
        return Validation.get('validate-digits').test(v) && actions.validExtendMethod(v, elem);
    }]
]);
```
**輸入**:
- validators: 陣列[] - 多筆檢核規則定義，每筆為 `[className, error, test, options]` 型式之陣列，各元素意義同 `Validation.add`
**輸出**: 無
**功能**:
- 一次註冊多筆具名檢核規則，逐一等同呼叫 `Validation.add`

---

## Validation.get(name)
**使用範例**: `Validation.get('IsEmpty').test(v)`
**輸入**:
- name: 字串 - 檢核規則名稱
**輸出**:
- **當查得對應名稱之規則時**: 回傳值: 物件 - 對應之檢核規則，可再呼叫其 `test(value, elm, info)` 執行單一檢核並取得布林結果
- **當查無對應名稱之規則時**: 回傳值: 物件 - 一律通過的預設規則
**功能**:
- 依名稱查找已註冊之檢核規則物件

---

## Validation.test(name, elm)
**使用範例**: `Validation.test('required', $(MIN_PRICE_id))`
**輸入**:
- name: 字串 - 檢核規則名稱
- elm: 元素 - 欲檢核之目標欄位
**輸出**:
- 布林值 - 該欄位是否通過指定規則之檢核；通過或未通過時，皆會同步更新該欄位之檢核結果標記與錯誤提示顯示
**功能**:
- 針對單一欄位執行單一具名規則之檢核，並同步反映檢核結果之視覺標記

---

## Validation.test(name, elm, useTitle, info)
**使用範例**: `Validation.test('required', $('APPLY_ID'), {useTitle:true}, {showAlert:true})`
**輸入**:
- name: 字串 - 檢核規則名稱
- elm: 元素 - 欲檢核之目標欄位
- useTitle: 布林值 - 是否優先以欄位之提示標題文字取代規則預設之錯誤訊息
- info: 物件 - 傳遞至檢核函式之附加內容
**輸出**:
- 布林值 - 該欄位是否通過指定規則之檢核
**功能**:
- 行為同二參數用法，另將 useTitle 與 info 轉發至檢核流程，可用於控制錯誤訊息來源與即時提示行為

---

## Validation.reset(elm)
**使用範例**: `Validation.reset(targetName)`
**輸入**:
- elm: 元素 | 字串 - 欲清除檢核標記之目標欄位或其識別碼
**輸出**: 無
**功能**:
- 清除指定欄位於所有檢核模式下之檢核結果標記與錯誤提示顯示

---

## Validation.mode
**使用範例**: `Validation.mode.fail_css`
**輸入**: 無
**輸出**:
- 物件 - 目前生效中之檢核模式定義物件，其中 `fail_css` 屬性為該模式下標記檢核失敗欄位所使用之樣式名稱
**功能**:
- 提供目前生效檢核模式（`'validate'` 或 `'validator'`）之相關樣式名稱等資訊，供外部程式碼判斷或操作欄位之檢核失敗樣式

---

## Validator.methods
**使用範例**: `Validator.methods[p](v,elm,limit)`
**輸入**:
- p: 字串 - 內建比較檢核之名稱鍵值，可用鍵值包含 `pattern`、`minLength`、`maxLength`、`min`、`max`、`gt`、`lt`、`notOneOf`、`oneOf`、`is`、`isNot`、`equalToField`、`notEqualToField`、`include`
**輸出**:
- 函式 - 對應鍵值之比較檢核函式，呼叫時傳入（欄位值、欄位、比較基準）並回傳布林值表示是否通過
**功能**:
- 提供一組可依鍵值取用之通用欄位值比較檢核函式集合（例如數值大於／小於、是否落於指定清單內、是否與另一欄位相等等）
