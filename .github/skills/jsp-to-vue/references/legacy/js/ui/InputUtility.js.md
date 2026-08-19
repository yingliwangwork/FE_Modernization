# InputUtility.js 公開契約

## 使用語法清單

**方法**:
- [InputUtility.lengthLimit.add()](#inpututilitylengthlimitadd)
- [InputUtility.lengthLimit.doLengthLimit()](#inpututilitylengthlimitdolengthlimit)
- [InputUtility.autoSizingTextarea.add()](#inpututilityautosizingtextareaadd)
- [InputUtility.autoSizingTextarea.doAutoSize()](#inpututilityautosizingtextareadoautosize)

---

## InputUtility.lengthLimit.add()
**使用範例**: `InputUtility.lengthLimit.add('REV_DESC', 500, true);`
**輸入**:
- elem: 字串 | 元素 - 目標元素之識別碼，或元素本身
- maxLength: 數值 - 允許輸入之最大長度
- countByByte: 布林值 = true - 是否以位元組計算全形字元長度；傳入 `false` 時改以字元數計算
- customMsg: 字串 | 布林值 = undefined - 自訂提示文字樣板，可包含 `{enter}`(已輸入)、`{limit}`(上限)、`{left}`(剩餘) 佔位符；**傳入 `false` 時**不顯示提示文字區塊
- input_size: 數值 = maxLength+2 - 元素之顯示寬度（字元數）；**僅於元素未設定寬度時**套用
**輸出**:
- **當驗證成功時**: 外框元素: 元素 - 包覆目標元素與提示文字之外框物件
- **當驗證失敗時**: 外框元素: undefined - 無；包含找不到元素、元素型態不符、maxLength 未設定為有效數值或該元素已設定過
**功能**:
- 將目標元素（限文字輸入框或多行文字框）包覆一層外框，並於其下方顯示已輸入/上限字數之提示文字
- 找不到指定元素、元素型態不符、或 maxLength 非有效數值時，跳出提示對話框並中止設定
- **當同一元素已設定過本功能時**: 略過重複設定並記錄除錯訊息
- 於輸入(keyup)與失焦(blur)時即時更新提示文字
- **當元素失焦且輸入內容超出上限時**: 顯示確認對話框，詢問是否將內容擷取至長度上限；同意時覆寫欄位內容，不同意時將焦點移回該元素

---

## InputUtility.lengthLimit.doLengthLimit()
**使用範例**: `InputUtility.lengthLimit.doLengthLimit('MEMO');`
**輸入**:
- elem: 字串 | 元素 - 目標元素之識別碼，或元素本身；**須為先前已透過 `add()` 設定過提示文字之元素**
**輸出**: 無
**功能**:
- 重新計算並更新指定元素之已輸入/上限字數提示文字
- **當輸入內容超出上限時**: 顯示確認對話框，詢問是否將內容擷取至長度上限，行為同 `add()` 之失焦處理

---

## InputUtility.autoSizingTextarea.add()
**使用範例**: `InputUtility.autoSizingTextarea.add(e);`
**輸入**:
- elem: 字串 | 元素 - 目標多行文字輸入元素之識別碼，或元素本身
- config: 物件 = undefined - 設定選項
  - rows: 數值 = 2 - 初始最小顯示列數；**元素本身已設定 rows 屬性時**，優先套用該既有值
**輸出**: 無
**功能**:
- 設定元素之顯示列數為最小列數，並於輸入(keyup)與失焦(blur)時依內容自動增減顯示列數
- 貼上內容或按下 Enter 時增加列數；刪除字元時減少列數（不低於最小列數）

---

## InputUtility.autoSizingTextarea.doAutoSize()
**使用範例**: `InputUtility.autoSizingTextarea.doAutoSize(e);`
**輸入**:
- elem: 字串 | 元素 - 目標多行文字輸入元素之識別碼，或元素本身
**輸出**: 無
**功能**:
- 依目前內容重新計算並套用最小顯示列數
