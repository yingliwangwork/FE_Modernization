# ui/Validator.js 公開契約

## 使用語法清單
**方法**:
- [Validator](#Validator)
    - [constructor()](#Validator.constructor())
    - [define()](#Validator.define())
    - [validate()](#Validator.validate())
    - [clear()](#Validator.clear())

---

## Validator.constructor()
**使用範例**: `validator = new Validator();`
**輸入**: 無
**輸出**:
- validator: Validator - 欄位檢核器實體
**功能**:
- 建立一個交易頁面欄位檢核用之檢核器物件
- 初始化內部待檢核清單為空

## Validator.define()
**使用範例**: `validator.define('APPLY_ID','受理編號','請輸入正確受理編號', returnFalse);`
**輸入**:
- n: String - 欲檢核之欄位名稱
- desc: String - 欄位說明文字
- errMsg: String - 檢核失敗時之錯誤訊息
- type: Function - 自訂檢核函式，接受欄位值作為參數，回傳布林值（true 表示通過）
**輸出**: 無
**功能**:
- 將指定欄位加入待檢核清單，供後續呼叫 validate() 時檢核

## Validator.validate()
**使用範例**: `return validator.validate();`
**輸入**: 無
**輸出**:
- result: Boolean - 是否所有已定義欄位皆檢核通過
**功能**:
- 依序執行待檢核清單中每一欄位之檢核
- **當任一欄位檢核失敗時**: 標記該欄位並顯示錯誤訊息

## Validator.clear()
**使用範例**: `validator.clear();`
**輸入**: 無
**輸出**: 無
**功能**:
- 清除已定義之待檢核清單，以利重新定義
