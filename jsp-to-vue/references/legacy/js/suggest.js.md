# suggest.js 公開契約

> 原始資源：`/CM/js/ui/suggest.js`
>
> `Suggest.add` 會依 `suggest_type` 進入不同資料取得流程；為避免混淆，以下分開記錄遠端即時、本地清單與遠端快取三種用法。

## **`Suggest.URL`**

### 用途

- 指定 `Suggest.add` 使用遠端即時查詢模式。

### 輸入

- 本契約為唯讀常數，不接受輸入參數。

### 輸出

- `Suggest.URL`: [Number = 2] - 遠端即時查詢模式代碼；完整模式見[代碼對照表](#代碼對照表)。

### 對外功能

- 作為 `Suggest.add(elem, Suggest.URL, url, config)` 的模式識別。

### 副作用

- 讀取常數不改變頁面狀態；外部仍可覆寫該屬性，但既有 `switch` 判定固定接受數值或字串 `2`。

---

## **`Suggest.LIST`**

### 用途

- 指定 `Suggest.add` 使用呼叫端提供的固定候選清單。

### 輸入

- 本契約為唯讀常數，不接受輸入參數。

### 輸出

- `Suggest.LIST`: [Number = 3] - 本地清單模式代碼；完整模式見[代碼對照表](#代碼對照表)。

### 對外功能

- 作為 `Suggest.add(elem, Suggest.LIST, list, config)` 的模式識別。

### 副作用

- 讀取常數不改變頁面狀態；外部仍可覆寫該屬性，未符合 `1`、`2`、`4` 的模式值實際也會落入本地清單分支。

---

## **`Suggest.AJAX_LIST`**

### 用途

- 指定 `Suggest.add` 先從遠端取得候選清單，再於後續輸入中優先重用該清單。

### 輸入

- 本契約為唯讀常數，不接受輸入參數。

### 輸出

- `Suggest.AJAX_LIST`: [Number = 4] - 遠端快取清單模式代碼；完整模式見[代碼對照表](#代碼對照表)。

### 對外功能

- 作為 `Suggest.add(elem, Suggest.AJAX_LIST, url, config)` 的模式識別。

### 副作用

- 讀取常數不改變頁面狀態；外部仍可覆寫該屬性，但既有 `switch` 判定固定接受數值或字串 `4`。

---

## **`Suggest.add(elem, suggest_type, suggest_data, config)`** — 遠端即時查詢用法

### 用途

- 依使用者輸入向指定網址查詢候選資料，並提供鍵盤與滑鼠選取介面。

### 輸入

- `elem`: [String|Element] - 目標輸入欄位識別或 DOM 元素；沒有 `id` 時會依 `name` 或 `suggest_` 前綴建立唯一識別。
- `suggest_type`: [Number|String] - 必須為 `Suggest.URL`、數值 `2` 或字串 `"2"`，才進入遠端即時查詢模式。
- `suggest_data`: [String|Number|Boolean] - 遠端查詢位置；原始實作只要求基本型別，實際應提供可由 `Ajax.Request` 使用的網址字串。
- `config`: [Object = {}] - 查詢與呈現設定；原始物件會先做一層淺複製。
  - `config.params`: [Object|Function|Any = {}] - 固定查詢參數、每次查詢前回傳額外參數物件的無參數函式，或其他會被替換為空物件的值；三種分流的實際資料流如下。
    - `Function`：函式保存為 `config.paramsFunction`，`config.params` 改為新空物件；`suggestId`、`prefix`、`ignoreCase` 寫入此物件。每次請求建立淺複本，再以函式回傳物件覆蓋同名欄位，最後加入 `suggestValue`。
    - 非物件且非函式：`config.params` 改為新空物件；內部欄位與 `suggestValue` 直接寫入該物件。
    - `Object`：原始物件先被淺複製到區域變數，但複本沒有回寫 `config.params`。初始化加入複本的 `suggestId`、`prefix`、`ignoreCase` 因而被丟棄；請求階段重新讀取呼叫端原物件，且直接寫入或覆寫其 `suggestValue`。
  - `config.prefix`: [Boolean = false] - 僅嚴格等於 `true` 時只接受以前綴符合的候選；否則接受任意位置包含。
  - `config.ignoreCase`: [Boolean = 預設忽略大小寫] - 原始旗標語意反向：僅傳入 `true` 時改為區分大小寫，其他值均忽略大小寫。
  - `config.noCookies`: [Boolean = false] - 僅嚴格等於 `true` 時停用歷史輸入 Cookie。
  - `config.startLength`: [Number|NumericString = 4] - 開始遠端查詢的最小「原始位元組長度」。
  - `config.searchGap`: [Number|NumericString = 2] - 查詢前從輸入尾端回退的長度，用於擴大可重用結果範圍。
  - `config.dispMax`: [Number|NumericString = 10] - 最多建立的候選項目數；資訊列仍顯示全部符合筆數。
  - `config.option_key`: [String = undefined] - 遠端結果為物件陣列時，用作候選值及精確比對的屬性名稱。
  - `config.remark_key`: [String = undefined] - 遠端結果為物件陣列時，附加顯示說明的屬性名稱。
  - `config.callBackFunc`: [Function = undefined] - 欄位失焦或完成選取時呼叫。
    - `config.callBackFunc(element, selectedObject)`: [Function(Element, Object): Any] - 精確符合物件候選時傳入欄位與完整候選物件。
    - `config.callBackFunc(element)`: [Function(Element): Any] - 未精確符合候選或使用基本值清單時，只傳入欄位。

### 輸出

- `return`: [undefined] - 此操作不回傳登錄控制器。

### 對外功能

- 輸入長度達門檻時，以 `POST` 傳送 `suggestValue` 與自訂參數；`config.params` 為函式或非物件時另包含 `suggestId`、`prefix`、`ignoreCase`，直接傳入物件時則因既有錯誤缺少這三欄。
- 期待成功回應可由 `CSRUtil.isSuccess(response.responseJSON)` 判定，且 `responseJSON.suggestResult` 為候選陣列。
- 依輸入位置、大小寫及顯示上限篩選候選；Enter、上下方向鍵、Esc、Tab、滑鼠點擊均會參與選取流程。

### 副作用

- 為欄位建立識別並登錄 `focus`、`click`、`keydown`、`keyup`、`blur` 事件，且以 `Object.extend` 覆寫或加入元素的 `setValue(value)`。
- `config.params` 為物件時，原始碼雖建立淺複本卻未保存，導致內部 `suggestId`、`prefix`、`ignoreCase` 不會送出，並會在每次請求直接改寫呼叫端原物件的 `suggestValue`；函式與非物件模式才會保留這些內部參數。
- 遠端查詢期間會暫時解除再重新登錄 `CSRUtil.defaultAjaxHandler`；同步例外可能使重新登錄無法執行。
- 使用一個全域於 `Suggest` 執行個體內的查詢鎖；不同欄位同時查詢時可能延後或改派後續查詢。
- 欄位不存在、重複登錄或網址型別無效時顯示警示；部分驗證發生在事件已登錄及設定已保存之後，失敗可能留下不完整登錄。

---

## **`Suggest.add(elem, suggest_type, suggest_data, config)`** — 本地清單用法

### 用途

- 以呼叫端提供的固定清單，在瀏覽器內即時篩選候選資料。

### 輸入

- `elem`: [String|Element] - 目標輸入欄位識別或 DOM 元素；識別建立規則與遠端用法相同。
- `suggest_type`: [Any] - `Suggest.LIST`、數值／字串 `3` 以及未被 `1`、`2`、`4` 分支識別的其他值，皆進入本地清單分支；若同名 DOM 元素存在，會先移除該元素。
- `suggest_data`: [Array<String|Number|Boolean|Object>] - 固定候選集合。
  - 基本值元素：直接作為候選值與顯示文字。
  - 物件元素：必須由 `config.option_key` 指定候選值；可由 `config.remark_key` 指定附加顯示內容。
- `config`: [Object = {}] - 本地篩選與呈現設定。
  - `config.params`: [Object|Function|Any = {}] - 此模式不提出一般查詢，但仍經與遠端用法相同的三種正規化分流；物件模式加入淺複本的內部欄位會被丟棄，且因不送出請求，通常不會改寫原物件的 `suggestValue`。
  - `config.prefix`, `config.ignoreCase`, `config.noCookies`, `config.startLength`, `config.dispMax`, `config.option_key`, `config.remark_key`, `config.callBackFunc`: 型別與語意同遠端即時用法。
  - `config.searchGap`: [Number|NumericString = 2] - 被保存但本地清單篩選不使用。

### 輸出

- `return`: [undefined] - 此操作不回傳登錄控制器。

### 對外功能

- 輸入長度達 `startLength` 時直接篩選 `list`；未達門檻時呈現符合輸入的歷史 Cookie。
- 選取後將候選值寫入欄位，記錄歷史並依精確比對結果呼叫 `config.callBackFunc`。

### 副作用

- 欄位識別、事件、`setValue`、Cookie 與警示等副作用同遠端即時用法。
- 不會因一般篩選提出網路請求；若 `callBackFunc` 不存在，失焦或選取時只關閉候選清單。
- 物件候選的 `remark_key` 內容以 HTML 字串插入候選項目，原始實作未轉義。

---

## **`Suggest.add(elem, suggest_type, suggest_data, config)`** — 遠端快取清單用法

### 用途

- 首次需要時從遠端取得候選陣列，後續優先在已取得的陣列中篩選。

### 輸入

- `elem`: [String|Element] - 目標輸入欄位識別或 DOM 元素。
- `suggest_type`: [Number|String] - 必須為 `Suggest.AJAX_LIST`、數值 `4` 或字串 `"4"`，才進入遠端快取清單模式。
- `suggest_data`: [String|Number|Boolean] - 遠端查詢位置；實際應提供網址字串。
- `config`: [Object = {}] - 完整欄位結構與遠端即時用法相同。
  - `config.params`, `prefix`, `ignoreCase`, `noCookies`, `startLength`, `searchGap`, `dispMax`, `option_key`, `remark_key`, `callBackFunc`: 型別、預設值、`params` 三種分流與回呼簽章均同遠端即時查詢用法。

### 輸出

- `return`: [undefined] - 此操作不回傳登錄控制器。

### 對外功能

- 尚無 `suggest_result` 時執行遠端查詢；已有結果時直接以目前輸入篩選快取陣列。
- 回呼執行前若目前值沒有可用結果，會再次要求遠端資料。

### 副作用

- 結合遠端即時用法的網路、查詢鎖與全域回應處理副作用，以及本地清單用法的篩選、HTML 顯示與 Cookie 副作用。

---

## **`Suggest.clear(elem)`**

### 用途

- 清除指定欄位的搜尋狀態與快取候選，使下一次互動重新取得或重建結果。

### 輸入

- `elem`: [String|Element] - 已登錄欄位的 `id` 或欄位元素；元素用法從其 `id` 取回設定。

### 輸出

- `return`: [undefined] - 此操作不回傳是否成功清除。

### 對外功能

- 將該欄位設定中的 `prevSearch`、`suggest_result` 清為 `null`，並將 `ajaxSearch` 設為 `-1`。

### 副作用

- 關閉目前共用候選清單，即使目前作用中的清單屬於另一個已登錄欄位。
- 不移除事件、欄位識別、登錄設定或歷史 Cookie。
- 找不到登錄設定時顯示警示後停止。

## 代碼對照表

### 建議資料來源模式

| 代碼 | 公開識別 | 行為 |
| --- | --- | --- |
| `2`／`"2"` | `Suggest.URL` | 依輸入執行遠端即時查詢。 |
| `3`／`"3"` | `Suggest.LIST` | 使用呼叫端提供的本地清單；其他未識別值也落入此模式。 |
| `4`／`"4"` | `Suggest.AJAX_LIST` | 遠端取得後優先重用候選清單。 |
| `1`／`"1"` | 無對應公開常數 | 舊式 class 查詢相容分支，使用內部空白預設網址。 |
