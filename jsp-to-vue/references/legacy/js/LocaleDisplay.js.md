# LocaleDisplay.js 公開契約

> 原始資源：`/CM/js/ui/LocaleDisplay.js`

## **`new LocaleDisplay(options)`**

### 用途

- 建立指定地區的日期、年份、年月與金額顯示規則，並立即套用到初始欄位集合。

### 輸入

- `options`: [Object] - 地區與初始欄位設定；原始實作未提供空值保護。
  - `options.locale`: [String] - 地區代碼；僅 `"ROC"`、`"VN"` 有專屬處理，其餘值使用預設西元模式。各模式見[代碼對照表](#代碼對照表)。
  - `options.dateFields`: [Array<String|Element> = undefined] - 完整日期欄位集合。
  - `options.dateyFields`: [Array<String|Element> = undefined] - 年份欄位集合。
  - `options.dateymFields`: [Array<String|Element> = undefined] - 年月欄位集合。
  - `options.numberFields`: [Array<String|Element> = undefined] - 金額欄位集合。

### 輸出

- `return`: [Object] - 地區化格式與登錄操作的物件；建構式明確回傳物件常值，因此不保證通過 `instanceof LocaleDisplay`。
  - `return.getLocale()`: [Function(): String] - 取得原始 `options.locale`。
  - `return.getPatternByDate()`: [Function(): String|undefined] - 取得該地區的日期格式；ROC 模式未設定此欄位。
  - `return.getPatternByAmount(scale)`: [Function(Number=25): String] - 取得金額格式；`scale <= 0` 時不含小數位。
  - `return.formatNumber(v, scale, isInput)`: [Function(Any, Number=25, Any=undefined): String] - 依金額格式轉換數值。
  - `return.formatDate(v)`: [Function(String): String] - 驗證西元日期後轉為地區顯示格式；無效值回傳空字串。
  - `return.formatDatey(v)`: [Function(String|Number): String|Number] - 轉換年份；ROC 模式以輸入年份減 `1911`。
  - `return.formatDateym(v)`: [Function(String|Number): String] - 轉換年月。
  - `return.formatTimestamp(v, showMillisecond)`: [Function(String, Boolean=undefined): String] - 轉換日期部分並保留時間；未啟用毫秒時移除小數點後內容。
  - `return.registerToDate(id)`, `registerToDatey(id)`, `registerToDateym(id)`, `registerToAmount(id)`: [Function] - 後續欄位登錄入口，詳見各契約。

### 對外功能

- 依地區模式決定欄位的 `datatype`、`pattern`、驗證類別、長度及格式化方式。
- 首次建立時包裝 Prototype 的 `Form.Element.Serializers.input`，使表單寫入與讀出自動執行民國年、越南日期及金額轉換。
- 依輸入集合呼叫對應的日期或金額欄位登錄流程。

### 副作用

- 全域表單序列化函式只包裝一次；第一個 `LocaleDisplay` 執行個體的地區與日期格式會被閉包保存，後續執行個體不會替換該轉換邏輯。
- 立即改寫初始欄位的屬性、樣式類別、顯示值及事件監聽，日期欄位亦可能由 `autoCreateDate` 建立日曆操作。
- 原始初始化條件誤以 `dateymFields` 判斷是否巡覽 `dateyFields`：未提供 `dateymFields` 時不會處理初始年份欄位；提供 `dateymFields` 但未提供 `dateyFields` 時可能拋出例外。
- 依賴 Prototype、`SimpleDateFormat`、`CSRUtil`、日期驗證及 `autoCreateDate` 等全域能力；缺少必要依賴時可能拋出例外。

---

## **`localeDisplay.registerToDate(id)`**

### 用途

- 將單一欄位登錄為目前地區的完整日期欄位。

### 輸入

- `id`: [String|Element] - 欄位識別或元素。字串用法會先加入建構時傳入的 `options.dateFields`。

### 輸出

- `return`: [undefined] - 此操作不回傳欄位元素。

### 對外功能

- 設定地區對應的 `datatype`、日期格式、驗證類別、`size` 與 `maxLength`，並要求日曆工具處理該欄位。

### 副作用

- 直接改寫欄位屬性與樣式類別，且可能在頁面建立日曆觸發元素。
- `id` 為字串但 `options.dateFields` 未提供時，呼叫 `.push` 會拋出例外；元素用法不會寫入集合。
- 找不到欄位時停止屬性處理，但字串仍已加入集合。

---

## **`localeDisplay.registerToDatey(id)`**

### 用途

- 將單一欄位登錄為目前地區的年份欄位。

### 輸入

- `id`: [String|Element] - 欄位識別或元素。字串用法會先加入建構時傳入的 `options.dateyFields`。

### 輸出

- `return`: [undefined] - 此操作不回傳欄位元素。

### 對外功能

- 設定地區對應的 `datatype`、`size` 與 `maxLength`，並限制鍵盤輸入為數字鍵。

### 副作用

- 直接改寫欄位屬性並登錄 `keypress` 事件；非數字鍵會被停止。
- `id` 為字串但 `options.dateyFields` 未提供時，呼叫 `.push` 會拋出例外；元素用法不會寫入集合。

---

## **`localeDisplay.registerToDateym(id)`**

### 用途

- 將單一欄位登錄為目前地區的年月欄位。

### 輸入

- `id`: [String|Element] - 欄位識別或元素。字串用法會先加入建構時傳入的 `options.dateymFields`。

### 輸出

- `return`: [undefined] - 此操作不回傳欄位元素。

### 對外功能

- 設定地區對應的 `datatype`、驗證類別、`size` 與 `maxLength`，並限制鍵盤輸入為數字鍵。

### 副作用

- 直接改寫欄位屬性與樣式類別，並登錄 `keypress` 事件。
- `id` 為字串但 `options.dateymFields` 未提供時，呼叫 `.push` 會拋出例外；元素用法不會寫入集合。

---

## **`localeDisplay.registerToAmount(id)`**

### 用途

- 將單一欄位登錄為具千分位顯示與數字輸入限制的金額欄位。

### 輸入

- `id`: [String|Element] - 欄位識別或元素。字串用法會先加入建構時傳入的 `options.numberFields`。

### 輸出

- `return`: [undefined] - 此操作不回傳欄位元素。

### 對外功能

- 設定 `datatype="number"`、預設金額格式及靠右樣式；在按鍵放開後重新格式化內容並校正游標位置。

### 副作用

- 直接改寫欄位屬性與行內樣式，並登錄 `keypress`、`keyup` 事件。
- `id` 為字串但 `options.numberFields` 未提供時，呼叫 `.push` 會拋出例外；元素用法不會寫入集合。

## 代碼對照表

### 地區模式與欄位契約

| `options.locale` | 完整日期 `datatype`／格式 | 年份 `datatype`／長度 | 年月 `datatype`／長度 | 完整日期驗證類別 | 年月驗證類別 |
| --- | --- | --- | --- | --- | --- |
| `ROC` | `ROCDATE`／`yyy/MM/dd`／7 | `ROCDATEY`／3 | `ROCDATEYM`／5 | `validate-ROCDate` | `validate-ROCDateYM` |
| `VN` | `vndate`／`dd/MM/yyyy`／10 | `vndatey`／4 | `vndateym`／6 | 未設定 | 未設定 |
| 其他值 | `date`／`yyyy-MM-dd`／10 | `datey`／4 | `dateym`／6 | `validate-date-db` | `validate-DateYM` |

> 欄位 `size` 均為上表長度再加 `2`。`datatype` 大小寫保留原始實作；表單序列化時會先轉為小寫再判定。
