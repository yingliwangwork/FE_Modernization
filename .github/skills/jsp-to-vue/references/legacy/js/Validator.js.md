# Validator.js 公開契約

## 使用語法清單
**方法**:
- [validateDateInput()](#validateDateInput())
- [validateString()](#validateString())
- [validateNum()](#validateNum())
- [validateStringBytes()](#validateStringBytes())
- [Validator](#Validator)
    - [constructor()](#Validator.constructor())
    - [define()](#Validator.define())
    - [validate()](#Validator.validate())
    - [clear()](#Validator.clear())
    - [errHandler](#Validator.errHandler)
- [AlertHandler](#AlertHandler)
    - [constructor()](#AlertHandler.constructor())
    - [display()](#AlertHandler.display())
    - [clear()](#AlertHandler.clear())

---

## validateDateInput()
**使用範例**: `validateDateInput(node.value)`
**輸入**:
- v: String - 欲檢核之日期字串，格式須為 YYYYMMDD、YYYY-MM-DD 或 YYYY/MM/DD
**輸出**:
- result: Boolean - 是否為合法日期格式
**功能**:
- 檢核輸入值是否為合法的西元日期格式

## validateString()
**使用範例**: `validateString(temp)`
**輸入**:
- v: String - 欲檢核之字串
- min: Number = undefined - 字串長度下限，可省略
- max: Number = undefined - 字串長度上限，可省略
**輸出**:
- result: Boolean - 字串長度是否符合限制（未指定上下限時，僅檢核長度是否大於 0）
**功能**:
- 檢核字串長度是否符合指定範圍

## validateNum()
**使用範例**: `validateNum(node.value)`
**輸入**:
- v: String - 欲檢核之數值字串
- min: Number = undefined - 數值下限，可省略
- max: Number = undefined - 數值上限，可省略
**輸出**:
- result: Boolean - 是否為合法數值且符合範圍限制
**功能**:
- 檢核輸入值是否為合法數值且符合指定範圍

## validateStringBytes()
**使用範例**: `validateStringBytes(value, 0, maxLength)`
**輸入**:
- v: String - 欲檢核之字串
- min: Number = undefined - 位元組長度下限，可省略
- max: Number = undefined - 位元組長度上限，可省略
**輸出**:
- result: Boolean - 字串以位元組（byte）為單位計算之長度是否符合限制
**功能**:
- 以位元組為單位檢核字串長度是否符合指定範圍

## Validator.constructor()
**使用範例**: `validator = new Validator();`
**輸入**: 無
**輸出**:
- validator: Validator - 欄位檢核器實體
**功能**:
- 建立一個交易頁面欄位檢核用之檢核器物件
- 初始化內部待檢核清單為空
- 依目前所在子系統，自動決定 validate() 執行時是否直接顯示錯誤訊息

## Validator.define()
**使用範例**: `validator.define('ASSIGN_DATEE','派件期間(迄)日','需大於等於派件期間(起)日', 'STRING','-1','-1');`
**輸入**:
- n: String - 欲檢核之欄位名稱
- desc: String - 欄位說明文字
- errMsg: String - 檢核失敗時之錯誤訊息
- type: String | Function - 檢核型態，可為下列字串（不分大小寫）：STRING、NUM、SELECT、DATE、STRING_BYTES、CHECKED、DATE_INPUT、AMT；亦可為任一已定義之全域函式名稱字串，或直接傳入檢核函式
- min: String | Number = undefined - 檢核之最小值（字串型態為長度下限，數值型態為數值下限），可省略
- max: String | Number = undefined - 檢核之最大值（字串型態為長度上限，數值型態為數值上限），可省略
**輸出**: 無
**功能**:
- 將指定欄位加入待檢核清單，供後續呼叫 validate() 時檢核

## Validator.validate()
**使用範例**: `if(!validator.validate()){`
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

## Validator.errHandler
**使用範例**: `validator.errHandler = new AlertHandler();`
**輸入**: 無
**輸出**:
- errHandler: Object = AlertHandler 實體 - 檢核失敗時負責標記欄位與顯示錯誤訊息之處理器
**功能**:
- 可由外部程式直接替換為新建立之錯誤處理器實體

## AlertHandler.constructor()
**使用範例**: `validator.errHandler = new AlertHandler();`
**輸入**: 無
**輸出**:
- handler: AlertHandler - 錯誤訊息處理器實體
**功能**:
- 建立一個預設之錯誤訊息處理器，用於收集檢核失敗訊息並標記對應欄位

## AlertHandler.display()
**使用範例**: `validator.errHandler.display();`
**輸入**: 無
**輸出**: 無
**功能**:
- 顯示目前累積之所有錯誤訊息

## AlertHandler.clear()
**使用範例**: `validator.errHandler.clear();`
**輸入**: 無
**輸出**: 無
**功能**:
- 清除已累積之錯誤訊息，並還原已標記欄位之顯示樣式
