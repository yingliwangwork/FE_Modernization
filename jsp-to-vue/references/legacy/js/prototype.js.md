# prototype.js 公開契約

> 原始資源：`/CM/js/prototype.js`、`/CM/js/ajax/prototype.js`（兩份原始碼內容相同）

## **`$(element)`**

### 用途

- 取得一個或多個可使用 Prototype 共通方法的操作對象。

### 輸入

- `element`: [String|Element|Window|Document] - 單一參數為元素識別值或既有操作對象。原始函數雖只宣告一個參數，實際可接收多個位置參數，並逐一套用相同解析規則。

### 輸出

- `return`: [Element|Window|Document|null|Array<Element|Window|Document|null>] - 單一參數回傳解析及擴充後的對象；傳入多個參數時依原順序回傳陣列；識別值不存在時對應項目為 `null`。

### 對外功能

- 字串參數會以元素識別值查詢文件；既有對象則直接沿用。每個文件元素在回傳前都會完成 Prototype 方法擴充。

### 副作用

- 對尚未具備共通方法的元素，可能將元素所屬標籤的方法註冊到全域元素方法集合，並擴充該元素本身。

---

## **`$F(element)`**

### 用途

- 以一致入口讀取不同類型表單欄位的目前值。

### 輸入

- `element`: [String|HTMLInputElement|HTMLSelectElement|HTMLTextAreaElement|HTMLButtonElement] - 欄位識別值或欄位元素。

### 輸出

- `return`: [String|Array<String>|null] - 文字、隱藏、按鈕及多行欄位回傳目前值；未勾選的單選或複選欄位回傳 `null`；單選下拉欄位回傳選取值或 `null`；複選下拉欄位回傳選取值陣列，沒有選項時回傳 `null`。

### 對外功能

- 依欄位類型套用對應序列化規則；下拉選項沒有 `value` 屬性時，以選項顯示文字作為值。

### 副作用

- 會先透過 `$()` 擴充欄位元素；不會修改欄位值或選取狀態。

---

## **`Event.observe(element, eventName, handler)`**

### 用途

- 為指定對象登錄標準或自訂事件的處理函數。

### 輸入

- `element`: [String|Element|Window|Document] - 要建立事件監聽的對象識別值或對象。
- `eventName`: [String] - 標準瀏覽器事件名稱或包含冒號的自訂事件名稱。
- `handler`: [Function] - 事件處理函數，呼叫形式為 `handler(event)`；執行時的 `this` 綁定為被監聽對象。

### 輸出

- `return`: [Element|Window|Document] - 已解析並完成監聽登錄的對象；相同對象、事件名稱及處理函數已登錄時仍回傳該對象。

### 對外功能

- 自訂事件透過內部通用事件通道傳遞；標準事件依執行環境使用原生事件介面。相同登錄組合只保留一筆。

### 副作用

- 會建立或更新全域事件登錄資料，並在對象上註冊原生事件監聽器。
- 相同對象、事件名稱及同一函數參照不會重複登錄。
- 事件發生時會執行 `handler`；若不再需要監聽，呼叫端須另行解除登錄。

---

## **`element.observe(eventName, handler)`**

### 用途

- 以元素實例方法為目前元素登錄事件處理函數。

### 輸入

- `eventName`: [String] - 標準瀏覽器事件名稱或包含冒號的自訂事件名稱。
- `handler`: [Function] - 事件處理函數，呼叫形式為 `handler(event)`；執行時的 `this` 綁定為目前元素。

### 輸出

- `return`: [Element] - 已建立事件監聽的目前元素。

### 對外功能

- 將目前元素補為 `Event.observe` 的第一個參數，其餘登錄規則與 `Event.observe(element, eventName, handler)` 相同。

### 副作用

- 會建立或更新全域事件登錄資料，並在元素上註冊原生事件監聽器。
- 相同元素、事件名稱及同一函數參照不會重複登錄；事件發生時會執行 `handler`。

---

## **`Form.serialize(form, options)`** — 查詢字串用法

### 用途

- 將表單的可提交欄位序列化為網址查詢字串。

### 輸入

- `form`: [String|HTMLFormElement] - 表單識別值或表單元素。
- `options`: [Boolean|Object = undefined] - 不傳入、傳入 `false`，或傳入下列 `hash` 為 `false` 的物件時使用本模式。
  - `options.hash`: [Boolean = false] - 固定為 `false`，要求回傳查詢字串。
  - `options.submit`: [String|Boolean = undefined] - 未指定時納入第一個送出欄位；指定名稱時只納入第一個同名送出欄位；設為 `false` 時排除所有送出欄位。

### 輸出

- `return`: [String] - 以 `&` 串接且經網址編碼的查詢字串；同名欄位保留為重複鍵，換行統一為 CRLF。

### 對外功能

- 依文件順序彙整已命名、未停用且具有可提交值的欄位；排除未勾選欄位、檔案欄位及不符合 `submit` 規則的送出欄位。

### 副作用

- 會透過 `$()` 解析及擴充表單與其中欄位；不會修改表單資料。

---

## **`Form.serialize(form, options)`** — 鍵值物件用法

### 用途

- 將表單的可提交欄位彙整為鍵值物件。

### 輸入

- `form`: [String|HTMLFormElement] - 表單識別值或表單元素。
- `options`: [Boolean|Object] - 傳入 `true`，或傳入下列未指定 `hash` 或 `hash` 為 `true` 的物件時使用本模式。
  - `options.hash`: [Boolean = true] - 未指定時預設為 `true`，要求回傳鍵值物件。
  - `options.submit`: [String|Boolean = undefined] - 未指定時納入第一個送出欄位；指定名稱時只納入第一個同名送出欄位；設為 `false` 時排除所有送出欄位。

### 輸出

- `return`: [Object] - 以欄位名稱為鍵的值物件；同名欄位有多個可提交值時合併為陣列。

### 對外功能

- 依文件順序彙整已命名、未停用且具有可提交值的欄位；排除未勾選欄位、檔案欄位及不符合 `submit` 規則的送出欄位。

### 副作用

- 會透過 `$()` 解析及擴充表單與其中欄位；不會修改表單資料。
- `options` 為物件且未指定 `hash` 時，原始實作會就地寫入 `options.hash = true`。

---

## **`new Ajax.Request(url, options)`**

### 用途

- 立即向指定位置送出可設定生命週期回呼的 HTTP 請求。

### 輸入

- `url`: [String] - 請求目標位置；`GET` 參數會附加到此位置。
- `options`: [Object = {}] - 請求方法、參數、標頭、回應處理與執行方式。
  - `options.method`: [String = "post"] - HTTP 方法，不分大小寫。不是 `get` 或 `post` 時，實際改以 `POST` 傳送，並附加 `_method` 參數保留原方法。
  - `options.asynchronous`: [Boolean = true] - 是否以非同步方式執行請求。
  - `options.parameters`: [String|Object|Hash = ""] - 查詢或表單參數。物件與 `Hash` 會序列化為查詢字串；原始實作亦會嘗試加入作業追蹤與登入狀態欄位，詳見[代碼對照表](#代碼對照表)。
  - `options.postBody`: [String = undefined] - `POST` 要求主體；未指定時使用序列化後的 `parameters`。
  - `options.contentType`: [String = "application/x-www-form-urlencoded"] - `POST` 要求的內容類型。
  - `options.encoding`: [String = "UTF-8"] - 附加於 `Content-type` 的字元編碼；空值時不附加字元編碼。
  - `options.requestHeaders`: [Object|Array = undefined] - 額外要求標頭。陣列以相鄰的名稱和值為一組；物件以屬性和值為一組。
  - `options.evalJSON`: [Boolean|String = true] - 是否解析回應本文或 `X-JSON` 標頭中的 JSON；實際判斷亦受回應內容類型及同源條件影響。
  - `options.evalJS`: [Boolean|String = true] - 是否執行同源 JavaScript 回應；設為 `"force"` 時不受同源與內容類型條件限制。
  - `options.sanitizeJSON`: [Boolean = false] - 解析非同源 JSON 時是否先執行安全格式檢查。
  - `options.onCreate`: [Function = undefined] - 建立請求後、開啟連線前呼叫，形式為 `onCreate(response)`。
  - `options.onUninitialized`: [Function = undefined] - 進入未初始化狀態時呼叫，形式為 `onUninitialized(response, headerJSON)`。
  - `options.onLoading`: [Function = undefined] - 進入載入狀態時呼叫，形式為 `onLoading(response, headerJSON)`。
  - `options.onLoaded`: [Function = undefined] - 進入已載入狀態時呼叫，形式為 `onLoaded(response, headerJSON)`。
  - `options.onInteractive`: [Function = undefined] - 進入互動狀態時呼叫，形式為 `onInteractive(response, headerJSON)`。
  - `options.onComplete`: [Function = undefined] - 請求完成時呼叫，形式為 `onComplete(response, headerJSON)`。
  - `options.onSuccess`: [Function = undefined] - HTTP 狀態為成功、`304` 或無可用狀態碼時呼叫，形式為 `onSuccess(response, headerJSON)`。
  - `options.onFailure`: [Function = undefined] - 未符合成功條件且沒有對應狀態碼處理函數時呼叫，形式為 `onFailure(response, headerJSON)`。
  - `options.on{status}`: [Function = undefined] - 特定 HTTP 狀態碼的優先處理函數，例如 `on404(response, headerJSON)`；存在時優先於 `onSuccess` 或 `onFailure`。
  - `options.onException`: [Function = undefined] - 內部處理或其他回呼拋出例外時呼叫，形式為 `onException(request, exception)`。

### 輸出

- `return`: [Ajax.Request] - 已建立並立即開始執行的請求控制物件；可由其 `transport`、`options`、`parameters`、`body` 與回應週期狀態檢視本次請求。

### 對外功能

- 正規化方法與參數、設定要求標頭，並依 HTTP 狀態及生命週期分派個別回呼與全域回應器。

### 副作用

- 建構期間即送出網路請求；同步模式會阻塞目前執行流程直到請求結束。
- 可能就地修改 `options.parameters` 所指向的物件，加入[代碼對照表](#代碼對照表)所列追蹤與登入狀態欄位，並清空 `top.responseTimeEndParameters`。
- 會觸發已登錄的 `Ajax.Responders`；符合條件的回應內容可能被解析為 JSON 或當作 JavaScript 執行。
- 例外會交由 `onException` 及全域 `onException` 回應器處理；若附加共通欄位失敗，可能寫入主控台診斷訊息。

---

## **`Ajax.Responders.register(responder)`**

### 用途

- 登錄適用於所有後續 Ajax 請求的共通生命週期處理器。

### 輸入

- `responder`: [Object] - 全域請求生命週期處理器；可提供下列任一函數。
  - `responder.onCreate`: [Function = undefined] - 每次請求建立時呼叫，形式為 `onCreate(request, response, json)`。
  - `responder.onUninitialized`: [Function = undefined] - 請求進入未初始化狀態時呼叫，形式為 `onUninitialized(request, response, json)`。
  - `responder.onLoading`: [Function = undefined] - 請求進入載入狀態時呼叫，形式為 `onLoading(request, response, json)`。
  - `responder.onLoaded`: [Function = undefined] - 請求進入已載入狀態時呼叫，形式為 `onLoaded(request, response, json)`。
  - `responder.onInteractive`: [Function = undefined] - 請求進入互動狀態時呼叫，形式為 `onInteractive(request, response, json)`。
  - `responder.onComplete`: [Function = undefined] - 請求完成時呼叫，形式為 `onComplete(request, response, json)`。
  - `responder.onException`: [Function = undefined] - 請求處理發生例外時呼叫；實際參數為 `onException(request, exception, undefined)`。
  - `responder.onTimeout`: [Function = undefined] - 非 Prototype 核心事件；`CSRUtil` 逾時處理實際以 `onTimeout(request, undefined, undefined)` 分派。

### 輸出

- `return`: [undefined] - 原始函數未回傳值。

### 對外功能

- 將同一處理器物件加入全域集合；分派器在事件發生時按登錄順序呼叫對應的同名函數。

### 副作用

- 會持續影響後續所有 `Ajax.Request`；同一物件參照已存在時不重複加入。
- 單一回應器拋出的例外會被分派器攔截，不會阻止其他回應器執行。

## 代碼對照表

### `Ajax.Request` 自動附加參數

| 參數 | 來源 | 用途 |
| --- | --- | --- |
| `requestTimeField` | `dateJs.getCurrentTimeStamp()` | 記錄本次要求開始時間。 |
| `requestTimeEndUUID` | `top.responseTimeEndParameters[*].UUID` | 傳遞先前回應的追蹤識別值。 |
| `requestTimeEndField` | `top.responseTimeEndParameters[*].requestTimeField` | 傳遞先前回應對應的開始時間。 |
| `eBAF_loginSystemInfo` | `top.eBAF_loginSystemInfo` | 傳遞登入系統資訊。 |
| `eBAF_UserObject_Flag` | `top.eBAF_UserObject_Flag` | 傳遞使用者物件狀態旗標。 |
