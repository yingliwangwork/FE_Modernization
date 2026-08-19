# 表單驗證規範

## 全局共用驗證規則
**使用情境**: 全局共用的驗證規則
**使用方式**: yup 原生規則、專案擴充規則
**可用規則**:
- yup 原生規則(例如: `string().required()`、`number().min(0)`、`date().max(new Date())`)
- 專案擴充規則(`@/assets/libs/CathayValidateRules.js`):
    - `mobile` (string): 驗證行動電話
    - `isChar` (string): 驗證是否為Char
    - `dateformatvalid` (string): 驗證日期格式(YYYYMMDD)
    - `validateNumber` (string): 檢核有效數字格式
    - `validateAlpha` (string): 檢核英文字母
    - `validateDate` (string): 檢核有效日期格式
    - `validateDateDb` (string): 檢核有效日期格式 YYYY-MM-DD
    - `validateROCDate` (string): 檢核正確的民國日期格式
    - `validateDateYM` (string): 檢核正確之西元年月格式
    - `validateROCDateYM` (string): 檢核正確之民國年月格式
    - `validateHHMM` (string): 檢核時分格式(HH:MM) (24小時制)
    - `validateHHMMMax` (string): 檢核開始時間不得大於結束時間 (HH:MM)
    - `validateHHMMMin` (string): 檢核結束時間不得小於開始時間 (HH:MM)
    - `validateROCDateMax` (string): 檢核民國起日不得大於迄日
    - `validateROCDateMin` (string): 檢核民國迄日不得小於起日
    - `validatorROCID` (string): 身分證檢核
    - `validatorResidentID` (string): 居留證檢核
    - `skipEmptyStr`(number, date): 當欄位為空字串時，跳過驗證規則
**使用範例**:
```js
import { string, date, object, ref as yupRef } from 'yup'
const validationSchema = object({
    // 驗證行動電話(專案擴充規則)(單欄驗證)
    mobile: string().mobile(),
    // 驗證起迄日範圍(yup 原生規則)(跨欄位驗證)
    startDate: date().max(yupRef('endDate'), "起日不得大於迄日"),
    endDate: date().min(yupRef('startDate'), "迄日不得小於起日"),
})
```

---

## 頁面自訂驗證規則
**使用情境**: 頁面自訂的驗證規則
**使用方式**: 頁面自訂規則 + `test()`
**必須**: 跨欄位驗證使用 `context.parent` 取得同表單其他欄位值
**禁止** 使用 `addMethod()` 方式新增驗證規則(避免全局污染)
**使用範例**: [頁面自訂驗證規則使用範例](./form-validation/examples/page-custom-validation-rules.md)

---

## 表單驗證群組
**使用情境**: 送出表單時，驗證表單是否符合規則
**使用方式**: VeeValidate(composition API) + Yup
**必須**: 使用 `object` 方式建立驗證群組，並以 `validationSchema` 綁定至對應表單
**必須**: 以 `useForm` 宣告虛擬表單; **禁止**: 保留 `<form>` 標籤包覆欄位
**必須**: 使用 `initialValues` 設定所有驗證欄位初始值，並設定 `validateOnMount: false`; **禁止**: 省略上述設定(將導致進入頁面即顯示錯誤)
**必須**: 需驗證的欄位使用 `useField` 宣告，並直接綁定 `v-model`; **禁止**: 使用 `ref`/`reactive` 宣告(VeeValidate 無法追蹤)
**必須**: `useField` 宣告欄位名稱需與 `validationSchema` 欄位名稱一致
**必須**: 無需驗證的欄位使用一般 `ref`/`reactive` 宣告; **禁止**: 使用 `useField` 宣告欄位
**必須**: 錯誤訊息取自 `useForm` 之 `errors`；**禁止**: 取自 `useField` 之回傳值
**必須**: 使用 `setValues` 賦值進行資料回填; **禁止**: 直接指派欄位值(不會觸發追蹤)
**必須**: 使用 `validate()` 觸發表單驗證
**必須**: 使用 `resetForm` 進行全表單重置，使用 `resetField` 進行單一欄位重置; **禁止**: 直接指派欄位值進行重置

**使用範例**:
- [表單驗證群組範例](./form-validation/examples/validation-group.md)