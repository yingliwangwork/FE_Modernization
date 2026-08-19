# LocaleDisplay.js 公開契約

## 使用語法清單
**方法**:
- [LocaleDisplay(options)](#LocaleDisplay(options))
    - [constructor()](#constructor())
    - [formatNumber(v, scale, isInput)](#formatNumber(v,-scale,-isInput))
    - [formatDate(v)](#formatDate(v))
    - [formatTimestamp(v, showMillisecond)](#formatTimestamp(v,-showMillisecond))
    - [formatDateym(v)](#formatDateym(v))
    - [registerToDate(id)](#registerToDate(id))
    - [registerToAmount(id)](#registerToAmount(id))

---

## LocaleDisplay(options)

### constructor()
**使用範例**:
```
window.localeDisplay = new LocaleDisplay({
    locale:'Y2K'
});
```
**輸入**:
- options: Object - 建構設定
- options.locale: String - 地區代碼；設為 `ROC` 採用民國制日期格式與驗證規則，設為 `VN` 採用越南日期格式，其餘值（含未設定）採用西元制預設格式
- options.dateFields: String[] - 需套用日期格式之欄位識別碼清單，建構時逐一套用
- options.dateyFields: String[] - 需套用年欄位格式之欄位識別碼清單，建構時逐一套用
- options.dateymFields: String[] - 需套用年月欄位格式之欄位識別碼清單，建構時逐一套用
- options.numberFields: String[] - 需套用金額格式之欄位識別碼清單，建構時逐一套用
**輸出**:
- 回傳值: Object - 具數值/日期格式化與欄位註冊等公開方法之實體
**功能**:
- 依地區代碼決定日期、年、年月、金額欄位之顯示樣式、驗證樣式與欄位長度限制
- 建構時依 dateFields、dateyFields、dateymFields、numberFields 清單，自動為對應欄位設定資料型別、格式樣式與長度限制
- 首次建構時，全域改寫表單欄位之輸入/輸出序列化行為，使日期與金額型別欄位自動套用地區格式轉換

---

### formatNumber(v, scale, isInput)
**使用範例**: `localeDisplay.formatNumber(rec.AGREE_AMT, 0, false)`
**輸入**:
- v: String | Number - 欲格式化之數值
- scale: Number = 25 - 小數位數
- isInput: Boolean - 是否為輸入用途之格式化
**輸出**:
- **當 v 為有效值或為 0 時**: 回傳值: String - 依千分位樣式與指定小數位數格式化後之文字
- **當 v 為空值且不為 0 時**: 回傳值: String = `''` - 空字串
**功能**:
- 依千分位樣式與指定小數位數，將數值格式化為顯示用文字

---

### formatDate(v)
**使用範例**: `$("LOAN_DATE").update(localeDisplay.formatDate(map.LOAN_DATE));`
**輸入**:
- v: String - 欲格式化之日期字串，可含以空白分隔之時間部分
**輸出**:
- **當輸入為合法西元日期時**: 回傳值: String - 依建構時所設定地區轉換後之日期文字
- **當輸入為空或非合法西元日期時**: 回傳值: String = `''` - 空字串
**功能**:
- 將西元日期字串轉換為建構時所設定地區之日期顯示格式

---

### formatTimestamp(v, showMillisecond)
**使用範例**: `localeDisplay.formatTimestamp(creditInfo['INPUT_TIME'],false)`
**輸入**:
- v: String - 欲格式化之日期時間字串，日期與時間以空白分隔
- showMillisecond: Boolean - 時間部分是否顯示毫秒，省略時不顯示
**輸出**:
- **當輸入非空時**: 回傳值: String - 日期部分依地區格式轉換、時間部分原樣接續後之文字
- **當輸入為空時**: 回傳值: String = `''` - 空字串
**功能**:
- 將日期時間字串之日期部分依地區格式轉換，時間部分原樣接續於後

---

### formatDateym(v)
**使用範例**: `var date = localeDisplay.formatDateym(value);`
**輸入**:
- v: String | Number - 欲格式化之年月數值
**輸出**:
- 回傳值: String - 依地區格式轉換後之年月文字
**功能**:
- 將年月數值（西元或民國）轉換為建構時所設定地區慣用之年月顯示格式

---

### registerToDate(id)
**使用範例**: `localeDisplay.registerToDate(ele.id);`
**輸入**:
- id: String | Object - 欲註冊為日期欄位之欄位識別碼或欄位物件
**輸出**: 無
**功能**:
- 為指定欄位套用日期輸入之資料型別、樣式與驗證設定

---

### registerToAmount(id)
**使用範例**: `localeDisplay.registerToAmount(input1);`
**輸入**:
- id: String | Object - 欲註冊為金額欄位之欄位識別碼或欄位物件
**輸出**: 無
**功能**:
- 為指定欄位套用金額之資料型別、千分位樣式，並限制僅能輸入數字
