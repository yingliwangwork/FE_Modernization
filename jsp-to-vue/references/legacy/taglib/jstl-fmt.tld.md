# jstl-fmt.tld 公開契約

- 原始專案未保存實體 `jstl-fmt.tld`；下列契約以專案內的實際標籤語法，交叉核對專案 `pom.xml` 指定之 Apache Standard Taglib 1.2.5 的 `META-INF/fmt.tld`、Java 實作與 JSTL 標準行為。
- 專案沒有覆寫此標籤的實作；實際使用僅傳入 `value`、`type` 與 `pattern`，其餘標準屬性仍列入公開簽章以避免移植時縮減既有契約。

## **`<fmt:formatNumber value="${value}" type="number|currency|percent" pattern="pattern" currencyCode="code" currencySymbol="symbol" groupingUsed="true|false" maxIntegerDigits="n" minIntegerDigits="n" maxFractionDigits="n" minFractionDigits="n">value body</fmt:formatNumber>` — 直接輸出**

### 用途

- 依目前格式化語系與指定規則將數值轉成文字，並直接寫入 JSP 回應。

### 輸入

- `value`: [Number | String, 選填, 支援執行期運算式] - 待格式化的數值；未指定時由標籤本體提供文字值。
- `type`: [String = `number`, 選填, 支援執行期運算式] - 標準數值格式類型；代碼意義請參閱[代碼對照表](#代碼對照表)。
- `pattern`: [String, 選填, 支援執行期運算式] - `DecimalFormat` 相容的自訂格式樣式，例如專案使用的 `#,###`、`###,###,###.##` 與 `#,#00`。
- `currencyCode`: [String, 選填, 支援執行期運算式] - ISO 4217 貨幣代碼；標準契約只在 `type="currency"` 時適用，若執行環境不支援指定代碼，標籤處理可能失敗；與 `currencySymbol` 同時指定時，在專案使用的 Java 執行環境由 `currencyCode` 優先。
- `currencySymbol`: [String, 選填, 支援執行期運算式] - 覆寫格式化結果所用的貨幣符號；標準契約只在 `type="currency"` 時適用。
- `groupingUsed`: [Boolean, 選填, 支援執行期運算式] - 是否使用千分位等數字群組分隔。
- `maxIntegerDigits`: [Integer, 選填, 支援執行期運算式] - 輸出整數部分允許的最大位數。
- `minIntegerDigits`: [Integer, 選填, 支援執行期運算式] - 輸出整數部分保留的最小位數，不足時補零。
- `maxFractionDigits`: [Integer, 選填, 支援執行期運算式] - 輸出小數部分允許的最大位數；超出部分依格式器規則捨入。
- `minFractionDigits`: [Integer, 選填, 支援執行期運算式] - 輸出小數部分保留的最小位數，不足時補零。
- `body`: [JSP Content, 選填] - 未指定 `value` 時，提供待解析與格式化的數值文字。

### 輸出

- `renderedText`: [String = `""`] - 依目前格式化語系、格式類型及屬性限制產生的數值文字；輸入為 `null` 或空字串時不輸出。

### 對外功能

- 使用目前 JSTL 格式化語系決定數字分隔符號、貨幣呈現方式及百分比格式。
- 可使用 `type` 選擇一般數值、貨幣或百分比格式；指定非空 `pattern` 時，Apache 實作以樣式建立 `DecimalFormat` 並忽略 `type` 的格式器選擇。
- 依整數與小數位數限制補零、截限顯示位數並進行必要的捨入。
- 無法取得適用的格式化語系時，Apache 實作改用輸入值的 `toString()`，不套用其他數值格式設定。

### 副作用

- 直接將格式化結果寫入 JSP 回應輸出串流。
- 無法解析 `value` 或本體文字、未指定非空 `pattern` 時的 `type` 非法，或貨幣設定失敗時，會以 `JspException` 中止標籤處理；`pattern` 無效或位數屬性不符合格式器要求時，可能以未攔截的 `IllegalArgumentException` 中止處理。

## **`<fmt:formatNumber value="${value}" type="number|currency|percent" pattern="pattern" currencyCode="code" currencySymbol="symbol" groupingUsed="true|false" maxIntegerDigits="n" minIntegerDigits="n" maxFractionDigits="n" minFractionDigits="n" var="resultName" scope="page|request|session|application">value body</fmt:formatNumber>` — 保存結果**

### 用途

- 格式化數值後將結果保存至指定範圍，供後續 JSP 邏輯使用，而不直接寫入回應。

### 輸入

- `value`: [Number | String, 選填, 支援執行期運算式] - 待格式化的數值。
- `type`: [String = `number`, 選填, 支援執行期運算式] - 標準數值格式類型；代碼意義請參閱[代碼對照表](#代碼對照表)。
- `pattern`: [String, 選填, 支援執行期運算式] - `DecimalFormat` 相容的自訂格式樣式。
- `currencyCode`: [String, 選填, 支援執行期運算式] - ISO 4217 貨幣代碼；標準契約只在 `type="currency"` 時適用，並在同時指定 `currencySymbol` 時優先。
- `currencySymbol`: [String, 選填, 支援執行期運算式] - 覆寫格式化結果所用的貨幣符號；主要用於 `type="currency"`。
- `groupingUsed`: [Boolean, 選填, 支援執行期運算式] - 是否使用數字群組分隔。
- `maxIntegerDigits`: [Integer, 選填, 支援執行期運算式] - 輸出整數部分允許的最大位數。
- `minIntegerDigits`: [Integer, 選填, 支援執行期運算式] - 輸出整數部分保留的最小位數。
- `maxFractionDigits`: [Integer, 選填, 支援執行期運算式] - 輸出小數部分允許的最大位數。
- `minFractionDigits`: [Integer, 選填, 支援執行期運算式] - 輸出小數部分保留的最小位數。
- `var`: [String, 必填於此模式, 不支援執行期運算式] - 保存格式化結果的屬性名稱。
- `scope`: [String = `page`, 選填, 不支援執行期運算式] - `var` 的保存範圍；代碼意義請參閱[代碼對照表](#代碼對照表)。
- `body`: [JSP Content, 選填] - 未指定 `value` 時，提供待解析與格式化的數值文字；處理器會去除本體前後空白。

### 輸出

- `result`: [String, 選擇性] - 非空輸入時保存至指定 `scope` 的格式化文字；輸入為 `null` 或空字串時不建立結果。
- `renderedText`: [String = `""`] - 不直接寫入回應。

### 對外功能

- 套用與直接輸出模式相同的語系、格式類型、自訂樣式、貨幣及位數規則。
- 指定非空 `pattern` 時，Apache 實作忽略 `type` 的格式器選擇；無法取得格式化語系時則直接採用輸入值的 `toString()`。
- 將格式化結果提供給後續條件判斷、屬性組合或其他標籤使用。
- 輸入為 `null` 或空字串時，不執行數值格式化。

### 副作用

- 在指定 `scope` 建立或覆寫 `var` 指定的同名屬性。
- 輸入為 `null` 或空字串時，會移除指定 `scope` 中 `var` 的既有同名屬性。
- 無法解析 `value`、未指定非空 `pattern` 時的 `type` 非法，或貨幣設定失敗時，會以 `JspException` 中止標籤處理；`pattern` 無效或位數屬性不符合格式器要求時，可能以未攔截的 `IllegalArgumentException` 中止處理。

## 代碼對照表

- `type`
  - `number`: 依目前格式化語系輸出一般數值；為預設值。
  - `currency`: 依目前格式化語系與指定貨幣資訊輸出貨幣文字。
  - `percent`: 將數值乘以百分比倍率後，依目前格式化語系輸出百分比文字。
- `scope`
  - `page`: 僅目前 JSP 頁面與其處理期間可見；為 JSTL 的預設範圍。
  - `request`: 同一 HTTP 請求的後續轉送或包含資源可見。
  - `session`: 同一使用者工作階段內可見。
  - `application`: 同一 Web 應用程式內所有請求共享。
