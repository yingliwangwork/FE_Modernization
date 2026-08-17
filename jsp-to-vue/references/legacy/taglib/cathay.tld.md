# cathay.tld 公開契約

- 專案以 `uri="/WEB-INF/tlds/cathay.tld"`、`prefix="cathay"` 載入此標籤庫。
- 本文件涵蓋共用資源語法清單使用的 `conver` 與 `converSelect`，並以 `ConverTag.java`、`ConverSelectTag.java` 的全部公開 setter 為屬性邊界。
- 專案來源未包含 `cathay.tld` 實體檔；屬性是否在部署階段標為 `required` 或允許 request-time expression 無法由專案檔案直接證實。下列行為以 Java Tag 實作及專案實際用法為準。

## **`<cathay:conver sys="..." field="..." value="..." defaultValue="..."/>`**

### 用途

- 將業務代碼轉成集中代碼資料定義的顯示名稱。

### 輸入

- `sys`: [String] - 系統別，直接傳入 `ParsingCodeHelper.getFieldName(...)`；Java setter 為 `setSys(String)`。
- `field`: [String] - 欄位或代碼種類名稱，直接傳入代碼查詢；Java setter 為 `setField(String)`。
- `value`: [String | EL, 選填] - 待轉譯代碼；Java setter 為 `setValue(String)`，標籤結束時透過 `ExpressionUtil.evalNotNull(..., String.class, ...)` 求值。
- `defaultValue`: [String | EL = `""`, 選填] - 查無對應資料時交由代碼查詢器處理的替代值；Java setter 為 `setDefaultValue(String)`，並與 `value` 一起求值為 `String`。
- `body`: [不接受] - `doStartTag()` 回傳 `SKIP_BODY`，標籤內容不會執行。

### 輸出

- `renderedText`: [String = `""`] - 代碼查詢器回傳非空白值時直接輸出該物件；回傳空白字串時輸出求值後的原始 `value`；回傳 `null` 或 `value` 被判定為無效時不輸出。
- `return`: [Tag lifecycle = EVAL_PAGE] - 標籤處理後繼續評估 JSP 後續內容。

### 對外功能

- 先求值 `value` 與 `defaultValue`，再呼叫 `ParsingCodeHelper.getInstance().getFieldName(sys, field, objValue, defaultObjValue)`。
- `value` 為 `null`、去除前後空白後為空字串、不是 `String`，或去除前後空白後不分大小寫等於 `"null"` 時，直接略過輸出。
- 專案實際用法均提供 `sys`、`field`、`value`，未發現 `defaultValue` 的現有呼叫；`defaultValue` 仍是 Java 實作明確公開的 setter 屬性。

### 副作用

- 讀取 `ParsingCodeHelper` 管理的集中代碼資料，並直接寫入目前 JSP 輸出串流，不進行 HTML escaping。
- 查詢結果為空白時以 `CalendarTag` 類別的 logger 寫入警告，並輸出原代碼；此 logger 類別名稱與實際 tag 類別不一致。
- `ParsingCodeHelper` 查詢及 `JspWriter` 寫入區塊的 `IOException` 或其他例外只記錄為 debug，標籤不向呼叫頁重拋，且可能產生空輸出。
- `ExpressionUtil` 拋出的 `NullAttributeException` 會把 `value` 與 `defaultValue` 的求值結果一併設為 `null`；其他 `JspException` 發生在內部 catch 區塊之前，會傳給 JSP 容器。

---

## **`<cathay:converSelect sys="..." field="..." value="..." name="..." attributesText="..." pattern="..." optionsValue="..." addOptionName="..." addOptionValue="..."/>`**

### 用途

- 依集中代碼資料產生 HTML 下拉選單，並套用預選值、選項篩選、顯示樣式及額外選項。

### 輸入

- `sys`: [String] - 系統別；Java setter 為 `setSys(String)`。
- `field`: [String] - 欄位或代碼種類名稱；Java setter 為 `setField(String)`。
- `value`: [String | EL, 選填] - 預選代碼；Java setter 為 `setValue(String)`，標籤結束時求值為 `String`。
- `name`: [String | EL, 選填] - 產生 `<select>` 的 `name`；Java setter 為 `setName(String)`，標籤結束時求值為 `String`。Java 註解宣稱未設定時沿用 `field`，但 Tag 本身沒有實作此回退，而是把 `null` 傳給 `ParsingCodeHelper`。
- `attributesText`: [String, 選填] - 原樣交給產生器附加至 `<select>` 的屬性文字，可包含事件、樣式或其他 HTML 屬性；Java setter 為 `setAttributesText(String)`。
- `pattern`: [String, 選填] - 選項顯示樣式；Java setter 為 `setPattern(String)`。代碼請參照[代碼對照表](#代碼對照表)。
- `optionsValue`: [String | EL, 選填] - 以逗號分隔的自訂選項集合；Java setter 為 `setOptionsValue(String)`，標籤結束時求值為 `String`。
- `addOptionName`: [String, 選填] - 額外加入的一個選項顯示名稱；Java setter 為 `setAddOptionName(String)`。
- `addOptionValue`: [String, 選填] - 額外選項的值；Java setter 為 `setAddOptionValue(String)`。
- `body`: [不接受] - `doStartTag()` 回傳 `SKIP_BODY`，標籤內容不會執行。

### 輸出

- `renderedControl`: [HTMLString = ""] - 正常時為 `ParsingCodeHelper.getSelectString(...)` 回傳的完整下拉選單 HTML；回傳 `null` 時不輸出。
- `fallbackControl`: [HTMLString] - 代碼產生器、結果組合或輸出發生例外時，依原始未求值的 `name` 與 `attributesText` 串成 `<select name="{name}"{attributesText} >`，內含一個值為 `addOptionValue`、文字為「查無對應之中文」的 `<option>`；任何 `null` 值會因 `StringBuffer.append(...)` 成為字面上的 `null`。
- `return`: [Tag lifecycle = EVAL_PAGE] - 標籤處理後繼續評估 JSP 後續內容。

### 對外功能

- 依序把 `sys`、`field`、求值後 `value`、`attributesText`、`pattern`、求值後 `optionsValue`、求值後 `name`、`addOptionName`、`addOptionValue` 傳入 `ParsingCodeHelper.getSelectString(...)`；原始 `name` 為 `null` 時，固定傳入 `null` 而不讀取求值結果。
- 專案現有五處使用均只提供 `sys`、`field`、`name`、`value`；其餘 setter 屬性雖未在目前 JSP 使用，仍屬原始 Java Tag 的公開輸入。
- `ExpressionUtil` 依序求值 `value`、`name`、`optionsValue`；任何一步發生 `NullAttributeException` 時立即停止後續求值，catch 區塊只將 `objValue` 設為 `null`，不會重設 `objName` 與 `objOptionsValue`。Tag 實例若由容器重複使用，未重設欄位可能保留前次處理值。

### 副作用

- 讀取集中代碼資料並直接把產生器回傳字串寫入 JSP 輸出，不進行 HTML escaping。
- `attributesText`、`name` 與額外選項值在 fallback HTML 中直接串接；呼叫端若提供未轉義內容，可能形成無效標記或注入額外屬性。
- 代碼產生器、結果組合或輸出處理例外會記錄 fatal 訊息並改輸出 fallback；fallback 本身寫入失敗時再記錄 fatal，不向呼叫頁重拋。
- `ExpressionUtil` 的非 `NullAttributeException` 型 `JspException` 發生在 fallback catch 區塊之前，會傳給 JSP 容器。

## 代碼對照表

### `converSelect.pattern`

- `#`: 顯示選項序號。
- `N`: 顯示代碼中文名稱。
- `V`: 顯示代碼值。
- 組合方式與未指定時的預設排列由 `ParsingCodeHelper` 決定；該類別實作不在目前專案來源內，因此本文件不推定其他代碼或排列規則。
