# jstl-core.tld 公開契約

- 原始專案未保存實體 `jstl-core.tld`；下列契約以專案內的實際標籤語法，交叉核對專案 `pom.xml` 指定之 Apache Standard Taglib 1.2.5 的 `META-INF/c.tld`、Java 實作與 JSTL 標準行為。
- 專案沒有覆寫這些標籤的實作；不得將下列標準行為解讀為專案自訂功能。

## **`<c:if test="${condition}" var="resultName" scope="page|request|session|application">...</c:if>`**

### 用途

- 依條件決定是否處理標籤本體，並可選擇將判斷結果保存至指定範圍。

### 輸入

- `test`: [Boolean, 必填, 支援執行期運算式] - 決定是否處理標籤本體的條件；JSP 容器依 EL 與標籤屬性規則將來源值轉成 `boolean` 後傳給處理器。
- `var`: [String, 選填, 不支援執行期運算式] - 保存條件判斷結果的屬性名稱；專案現有用法未使用此屬性。
- `scope`: [String = `page`, 選填, 不支援執行期運算式] - `var` 的保存範圍；代碼意義請參閱[代碼對照表](#代碼對照表)。只有指定 `var` 時才有實際作用。
- `body`: [JSP Content, 選填] - `test` 成立時才處理的 JSP 本體。

### 輸出

- `renderedContent`: [String] - `test` 成立時，由標籤本體寫入回應的內容；條件不成立時不輸出本體內容。
- `result`: [Boolean, 選擇性] - 指定 `var` 時，將條件轉換後的布林結果保存至指定 `scope`。

### 對外功能

- 以 JSTL 的布林轉換規則評估 `test`。
- 僅在條件成立時處理標籤本體；專案用此行為控制欄位、選項、訊息及操作區塊是否呈現。

### 副作用

- 指定 `var` 時，會在指定 `scope` 建立或覆寫同名屬性。
- 條件成立時會執行標籤本體內的其他 JSP 標籤、指令碼與輸出行為；條件不成立時不會執行。

## **`<c:forEach items="${items}" begin="begin" end="end" step="step" var="item" varStatus="status">...</c:forEach>` — 集合反覆運算**

### 用途

- 逐項處理集合、陣列、`Map` 或其他 JSTL 支援的可反覆運算資料，並可限制處理區間與步進值。

### 輸入

- `items`: [Object, 選填, 支援執行期運算式] - 待反覆運算的資料來源；Apache 實作接受 `Collection`、陣列、`Iterator`、`Enumeration`、`Map`，以及以逗號切分的 `String`。
- `begin`: [Integer = `0`, 選填, 支援執行期運算式] - 起始索引，含該索引；必須大於或等於 `0`。
- `end`: [Integer, 選填, 支援執行期運算式] - 結束索引，含該索引；未指定時處理至資料來源結尾。
- `step`: [Integer = `1`, 選填, 支援執行期運算式] - 每次前進的索引間距；必須大於或等於 `1`。
- `var`: [String, 選填, 不支援執行期運算式] - 每次處理時，保存目前項目的頁面範圍屬性名稱。
- `varStatus`: [String, 選填, 不支援執行期運算式] - 每次處理時，保存 `LoopTagStatus` 狀態物件的頁面範圍屬性名稱；可用欄位請參閱[代碼對照表](#代碼對照表)。
- `body`: [JSP Content, 選填] - 每次反覆運算時處理的 JSP 本體。

### 輸出

- `renderedContent`: [String] - 各次標籤本體寫入回應的內容，依處理順序串接；沒有可處理項目時不輸出本體內容。
- `item`: [Object, 選擇性] - 指定 `var` 時，在每次處理期間提供目前項目。
- `status`: [LoopTagStatus, 選擇性] - 指定 `varStatus` 時，在每次處理期間提供目前筆次、首末筆與區間資訊。

### 對外功能

- 依 `items` 的自然順序處理資料，並套用 `begin`、`end` 與 `step` 限制。
- `Map` 資料來源的目前項目是鍵值項目，而不是只提供鍵或值。
- `items` 求值為 `null` 時會切換成整數區間模式，而不是把它視為含一個空項目的集合。
- 專案用此模式產生選項、表格列、清單及重複表單欄位。

### 副作用

- 每次處理期間，會在頁面範圍設定 `var` 與 `varStatus` 對應屬性，標籤結束後恢復先前同名屬性狀態。
- 使用 `Iterator` 或 `Enumeration` 作為 `items` 時會消耗其目前反覆運算位置。
- 每次處理均會執行標籤本體內的其他 JSP 標籤、指令碼與輸出行為。

## **`<c:forEach begin="begin" end="end" step="step" var="index" varStatus="status">...</c:forEach>` — 整數區間反覆運算**

### 用途

- 在未提供 `items` 時，依含首含尾的整數區間重複處理標籤本體。

### 輸入

- `begin`: [Integer = `0`, 選填, 支援執行期運算式] - 起始整數，含該值；必須大於或等於 `0`。
- `end`: [Integer, 選填, 支援執行期運算式] - 結束整數，含該值；TLD 未標為必填，但在此模式未指定時實作內部的結束值為 `-1`，因此不處理標籤本體。
- `step`: [Integer = `1`, 選填, 支援執行期運算式] - 每次遞增量；必須大於或等於 `1`。
- `var`: [String, 選填, 不支援執行期運算式] - 每次處理時，保存目前整數值的頁面範圍屬性名稱。
- `varStatus`: [String, 選填, 不支援執行期運算式] - 每次處理時，保存 `LoopTagStatus` 狀態物件的頁面範圍屬性名稱；可用欄位請參閱[代碼對照表](#代碼對照表)。
- `body`: [JSP Content, 選填] - 每個整數值對應的 JSP 本體。

### 輸出

- `renderedContent`: [String] - 各次標籤本體寫入回應的內容，依整數遞增順序串接。
- `index`: [Integer, 選擇性] - 指定 `var` 時，在每次處理期間提供目前整數值。
- `status`: [LoopTagStatus, 選擇性] - 指定 `varStatus` 時，在每次處理期間提供目前筆次、首末筆與區間資訊。

### 對外功能

- 產生 `begin` 至 `end` 的含首含尾遞增序列，並依 `step` 跳號。
- 當 `begin` 大於 `end` 時不處理標籤本體。

### 副作用

- 每次處理期間，會在頁面範圍設定 `var` 與 `varStatus` 對應屬性，標籤結束後恢復先前同名屬性狀態。
- 每次處理均會執行標籤本體內的其他 JSP 標籤、指令碼與輸出行為。

## **`<c:out value="${value}" default="fallback" escapeXml="true|false">fallback body</c:out>`**

### 用途

- 將值轉成文字寫入回應，並預設將 XML 特殊字元編碼；值不存在時可使用 `default` 或標籤本體作為替代內容。

### 輸入

- `value`: [Object, 必填, 支援執行期運算式] - 待輸出的值；`null` 時改用替代內容。
- `default`: [String, 選填, 支援執行期運算式] - `value` 為 `null` 時使用的替代值；空字串不是 `null`，因此不會觸發替代值。標準 TagLibraryValidator 要求 `default` 與非空標籤本體擇一使用。
- `escapeXml`: [Boolean = `true`, 選填, 支援執行期運算式] - 是否編碼 XML 特殊字元；代碼意義請參閱[代碼對照表](#代碼對照表)。
- `body`: [JSP Content, 選填] - `value` 為 `null` 且未指定 `default` 時使用的替代內容；處理器會去除本體前後空白。標準 TagLibraryValidator 要求非空本體與 `default` 擇一使用。

### 輸出

- `renderedText`: [String] - `value`、`default` 或標籤本體中第一個可用來源的字串表示；所有來源均無內容時不輸出文字。

### 對外功能

- `value` 非 `null` 時輸出該值；否則輸出 `default` 或標籤本體所提供的單一替代來源。
- `escapeXml="true"` 時編碼 `<`、`>`、`&`、單引號及雙引號等 XML 特殊字元。
- 專案在輸出一般畫面資料時採用預設編碼，也明確使用 `escapeXml="false"` 輸出預先序列化的 JSON 或標記內容。

### 副作用

- 直接將結果寫入 JSP 回應輸出串流。
- `escapeXml="false"` 會原樣輸出來源文字；若內容未經可信任的編碼或清理，可能改變頁面結構或形成指令碼注入風險。

## 代碼對照表

- `scope`
  - `page`: 僅目前 JSP 頁面與其處理期間可見；為 JSTL 的預設範圍。
  - `request`: 同一 HTTP 請求的後續轉送或包含資源可見。
  - `session`: 同一使用者工作階段內可見。
  - `application`: 同一 Web 應用程式內所有請求共享。
- `LoopTagStatus`
  - `current`: 目前處理的資料項目或整數值。
  - `index`: 目前項目在原始反覆運算範圍內的零起算索引；受 `begin` 與 `step` 影響。
  - `count`: 已處理次數，從 `1` 起算。
  - `first`: 目前是否為實際處理的第一筆。
  - `last`: 目前是否為實際處理的最後一筆。
  - `begin`: 本次反覆運算採用的起始索引或起始值。
  - `end`: 本次反覆運算採用的結束索引或結束值；未指定時可能為 `null`。
  - `step`: 明確指定的步進值；未指定時為 `null`，即使處理器實際以預設步進值 `1` 執行。
- `escapeXml`
  - `true`: 編碼 XML 特殊字元；預設值。
  - `false`: 不編碼，原樣輸出文字。
