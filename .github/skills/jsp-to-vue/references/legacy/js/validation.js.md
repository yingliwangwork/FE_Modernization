# validation.js 公開契約

## 使用語法清單
**方法**:
- [validation.checkUniSN(str)](#validation.checkUniSN(str))
- [validation.hasFullType(str)](#validation.hasFullType(str))
- [validation.hasHalfType(str)](#validation.hasHalfType(str))
- [validation.checkInputLength(str,-len)](#validation.checkInputLength(str,-len))
- [validation.checkInputLength(str,-len,-fullLen,-halfLen)](#validation.checkInputLength(str,-len,-fullLen,-halfLen))
- [validation.checkROCID(str)](#validation.checkROCID(str))
- [validation.checkID(str)](#validation.checkID(str))
- [idCheck1(id)](#idCheck1(id))
- [iscmpid(id)](#iscmpid(id))

---

## 共用模式
- 各方法之輸入為 undefined、null、空字串，或長度不符合各自規定碼數時，一律回傳 false，不拋出例外
- 檢核類方法之回傳值皆為布林值，僅代表格式是否合法，不修改輸入內容、不觸發畫面上之任何顯示行為

---

## validation.checkUniSN(str)
**使用範例**: `if(OWNER_ID.length==8 && !validation.checkUniSN(OWNER_ID)){`
**輸入**:
- str: String - 欲檢核之營業人統一編號，須為 8 碼
**輸出**:
- result: Boolean - 統一編號是否合法
**功能**:
- 依各碼固定乘數加權後，計算是否可被 5 整除以判斷統一編號是否合法
- **當第 7 碼為數字 7 且加權和不能被 5 整除時**: 額外加 1 後重新判斷是否可被 5 整除，以相容特定編號規則

---

## validation.hasFullType(str)
**使用範例**: `if(validation.hasFullType(QUERY_VALUE)) {`
**輸入**:
- str: String - 欲檢核之文字
**輸出**:
- result: Boolean - 是否含有全形（雙位元組）文字
**功能**:
- 逐字判斷輸入字串是否含有至少一個全形文字

---

## validation.hasHalfType(str)
**使用範例**: `if(validation.hasHalfType(value)){`
**輸入**:
- str: String - 欲檢核之文字
**輸出**:
- result: Boolean - 是否含有半形（單位元組）文字
**功能**:
- 逐字判斷輸入字串是否含有至少一個半形文字

---

## validation.checkInputLength(str, len)
**使用範例**: `if(!validation.checkInputLength(value, maxLength)){`
**輸入**:
- str: String - 欲檢核之文字
- len: Number - 總長度上限
**輸出**:
- result: Boolean - 總長度是否未超過上限
**功能**:
- 計算輸入文字之總長度，全形文字換算為 2 個單位長度、半形文字換算為 1 個單位長度後加總，判斷是否未超過 len
- **當 len 非數值時**: 不進行長度限制，直接回傳合法

---

## validation.checkInputLength(str, len, fullLen, halfLen)
**使用範例**: `if(!validation.checkInputLength(value, maxLength, fullLength, halfLength)){`
**輸入**:
- str: String - 欲檢核之文字
- len: Number - 總長度上限（全形文字以 2 個單位計算）
- fullLen: Number = 不限制 - 全形文字字數上限，可省略
- halfLen: Number = 不限制 - 半形文字字數上限，可省略
**輸出**:
- result: Boolean - 是否同時符合總長度、全形字數上限與半形字數上限
**功能**:
- 除總長度檢核外，另分別計算全形文字字數與半形文字字數，個別與 fullLen、halfLen 比較
- **當 fullLen 或 halfLen 省略或非正數時**: 不對該項目個別限制字數

---

## validation.checkROCID(str)
**使用範例**: `if(!validation.checkROCID($F('QRY_COND1')) && !validation.checkUniSN($F('QRY_COND1'))){`
**輸入**:
- str: String - 欲檢核之身分證統一編號，須為 10 碼
**輸出**:
- result: Boolean - 身分證統一編號是否合法
**功能**:
- 依首碼英文字母對應之數值與各碼固定乘數，計算檢查碼是否相符，藉以判斷中華民國身分證統一編號格式是否合法
- **當第 2 碼為新式規則使用之數字（8 或 9）時**: 視為不符合本方法之格式，回傳不合法

---

## validation.checkID(str)
**使用範例**: `return validation.checkID(value);`
**輸入**:
- str: String - 欲檢核之證件號碼，須為 10 碼
**輸出**:
- result: Boolean - 證件號碼是否合法
**功能**:
- **當第 2 碼為特定英文字母或新式規則數字（8、9）時**: 執行居留證檢核
- **其餘情況**: 執行身分證檢核

---

## idCheck1(id)
**使用範例**: `return dataMainMap ? (v.length==10 ? idCheck1(v):iscmpid(v) ): true;`
**輸入**:
- id: String - 欲檢核之身分證統一編號，須為 10 碼
**輸出**:
- result: Boolean - 身分證統一編號是否合法
**功能**:
- 檢核中華民國身分證統一編號格式是否合法，判斷邏輯與 validation.checkROCID 相同

---

## iscmpid(id)
**使用範例**: `if(iscmpid($F('ID')) == false) {`
**輸入**:
- id: String - 欲檢核之營業人統一編號，須為 8 碼
**輸出**:
- result: Boolean - 統一編號是否合法
**功能**:
- 依各碼固定乘數加權後，計算是否可被 5 整除以判斷統一編號是否合法
- **當第 7 碼為數字 7 且加權和除以 5 之餘數為 4 時**: 仍視為合法
