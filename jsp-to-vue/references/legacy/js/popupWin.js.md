# popupWin.js 公開契約

> 原始資源：`/CM/js/ui/popupWin.js`
>
> 本文件只描述原始程式碼實際對外暴露的行為。`popupWin` 為頁面載入此資源後建立的單一 `PopupWinUI` 執行個體。

## **`popupWin.popup(inConfig, inWidth, inHeight, inLeft, inTop, inScrolling, inParameters)`** — 設定物件用法

### 用途

- 在目前頁面上建立遮罩式內嵌視窗，並以 `POST` 載入指定業務頁面。

### 輸入

- `inConfig`: [Object] - 內嵌視窗設定；下列欄位以 `config` 表示此物件。
  - `config.src`: [String] - 必填。目標網址；網址中的查詢字串會轉為送出的表單欄位。
  - `config.width`: [Number|String = 0.9] - 內容寬度；可傳比例、百分比或像素值。
  - `config.height`: [Number|String = 0.8] - 內容高度；可傳比例、百分比或像素值。
  - `config.left`: [Number|String = 0.5] - 視窗左側位置；可傳比例、百分比或像素值。
  - `config.top`: [Number|String = 0.4] - 視窗頂端位置；可傳比例、百分比或像素值。
  - `config.scrolling`: [Boolean|String|Function = "Y"] - 是否允許內容捲動；實際判定規則見[代碼對照表](#代碼對照表)。若為函式，呼叫結果作為判定值；字串 `"N"` 不會停用捲動。
  - `config.parameters`: [Object|Array|String|Number|Boolean = undefined] - 送往目標頁面的資料。物件以屬性名稱展開；陣列以索引後綴展開；單一基本值使用欄位名稱 `parameters`。
  - `config.title`: [String = undefined] - 標題列文字。
  - `config.resizable`: [Boolean|String|Function = true] - 是否允許使用者調整內嵌視窗大小。
  - `config.movable`: [Boolean|String|Function = true] - 是否允許使用者拖曳內嵌視窗。
  - `config.closeBtn`: [Boolean|String|Function = true] - 是否顯示標題列關閉按鈕；完整畫面模式仍會顯示。
  - `config.isFullPopup`: [Boolean|String|Function = false] - 是否以完整可用顯示範圍呈現。
  - `config.cb`: [Function = undefined] - 完成回呼；優先於 `config.onBack`。接收子頁面回傳的最多十筆資料，無固定回傳用途。
  - `config.onBack`: [Function = undefined] - `config.cb` 未提供時使用的完成回呼；參數與 `config.cb` 相同。
  - `config.onClose`: [Function = undefined] - 關閉後回呼；無參數，回傳值不使用。優先於相容欄位 `config.onclose`。
  - `config.onclose`: [Function = undefined] - `config.onClose` 未提供時使用的關閉後回呼。
  - `config.closeConfirm`: [Object = undefined] - 使用標題列關閉按鈕時的確認設定。
    - `config.closeConfirm.msg`: [String] - 確認訊息；未提供字串時不顯示確認對話框。
  - `config.closeConfirm.assignConfirmType`: [Boolean = true] - `confirm` 結果必須等於此值才執行關閉。
- `inWidth`, `inHeight`, `inLeft`, `inTop`, `inScrolling`, `inParameters`: [Any = undefined] - `inConfig` 為物件時全部忽略，不會覆蓋物件內的同名設定。

### 輸出

- `return`: [undefined] - 此操作不回傳視窗或內容元素。

### 對外功能

- 將 `config.parameters` 與 `config.src` 查詢字串合併後，以隱藏表單送入新建的 `iframe`。
- 將子頁面的 `close`、`popupWinclose`、`popupWinBack`、`callbackHandler` 與 `callbackProxy` 接到父頁面的關閉及完成處理流程。
- 依設定控制標題、尺寸、位置、捲動、拖曳、調整大小與關閉按鈕。

### 副作用

- 建立或重用頁面層級的遮罩、標題列、`iframe` 與暫存表單，並為 `body` 加上 `popupWinActive` 類別。
- 將最上層頁面的 `eBAF_loginSystemInfo`、`eBAF_UserObject_Flag` 一併送往目標頁面；來源不存在時略過。
- 同一頁已有作用中的內嵌視窗時，記錄訊息後忽略本次呼叫。
- `config` 或 `config.src` 無效時，僅記錄訊息並停止，不擲出例外。
- 舊版瀏覽器環境可能停用背景頁面捲動；絕對定位環境會定期強制維持原捲動位置。

---

## **`popupWin.popup(inConfig, inWidth, inHeight, inLeft, inTop, inScrolling, inParameters)`** — 位置參數用法

### 用途

- 以位置參數快速開啟一般尺寸的遮罩式內嵌視窗。

### 輸入

- `inConfig`: [String] - 必填。此模式下作為目標網址 `src`。
- `inWidth`: [Number|String = 0.9] - 內容寬度；可傳比例、百分比或像素值。
- `inHeight`: [Number|String = 0.8] - 內容高度；可傳比例、百分比或像素值。
- `inLeft`: [Number|String = 0.5] - 左側位置；可傳比例、百分比或像素值。
- `inTop`: [Number|String = 0.4] - 頂端位置；可傳比例、百分比或像素值。
- `inScrolling`: [Boolean|String|Function = "Y"] - 是否允許內容捲動；接受值見[代碼對照表](#代碼對照表)。
- `inParameters`: [Object|Array|String|Number|Boolean = undefined] - 送往目標頁面的資料；展開規則與設定物件用法相同。

### 輸出

- `return`: [undefined] - 此操作不回傳視窗或內容元素。

### 對外功能

- 先將位置參數轉成設定物件，再執行 `popupWin.popup(config)` 的載入流程。

### 副作用

- 與 `popupWin.popup(config)` 相同。
- 此用法無法直接指定標題、回呼、關閉確認及互動能力；需要這些能力時應改用設定物件。

---

## **`popupWin.fullPopup(inConfig, inParameters)`** — 設定物件用法

### 用途

- 以完整可用顯示範圍開啟遮罩式內嵌視窗。

### 輸入

- `inConfig`: [Object] - 設定結構與 `popupWin.popup` 設定物件用法相同；`inConfig.src` 必填。
- `inParameters`: [Any = undefined] - `inConfig` 為物件時忽略。

### 輸出

- `return`: [undefined] - 此操作不回傳視窗或內容元素。

### 對外功能

- 強制設定完整畫面模式並轉交 `popupWin.popup(config)` 開啟。

### 副作用

- 直接將傳入物件的 `config.isFullPopup` 改為 `true`，並將 `config.closeConfirm` 改為 `null`。
- 完整畫面模式停用拖曳與尺寸調整，且不執行關閉確認。
- 其餘副作用與 `popupWin.popup(config)` 相同。

---

## **`popupWin.fullPopup(inConfig, inParameters)`** — 網址用法

### 用途

- 只提供目標網址與資料，開啟完整畫面的遮罩式內嵌視窗。

### 輸入

- `inConfig`: [String] - 必填。此模式下作為目標網址 `src`。
- `inParameters`: [Object|Array|String|Number|Boolean = undefined] - 送往目標頁面的資料。

### 輸出

- `return`: [undefined] - 此操作不回傳視窗或內容元素。

### 對外功能

- 建立僅含 `src`、`parameters` 的設定物件，再以完整畫面模式開啟。

### 副作用

- 與 `popupWin.fullPopup(config)` 相同，但不會修改呼叫端傳入的物件。

---

## **`popupWin.back(obj1, obj2, obj3, obj4, obj5, obj6, obj7, obj8, obj9, obj0)`**

### 用途

- 從子頁面回傳處理結果，完成後關閉目前的內嵌視窗。

### 輸入

- `obj1` 至 `obj0`: [Any = undefined] - 依此固定次序交給完成回呼的最多十筆資料；非基本型別會先嘗試經 JSON 序列化與重建，以解除父子頁面的物件關聯。

### 輸出

- `return`: [undefined] - 完成回呼的回傳值不向外傳遞。

### 對外功能

- 依序呼叫目前登錄的完成回呼，再執行 `popupWin.close()`。

### 副作用

- 可能執行 `config.cb`、`config.onBack` 或外部覆寫的 `popupWin.callbackHandler`。
- 無論是否存在完成回呼，接著都會關閉目前內嵌視窗。

---

## **`popupWin.callbackHandler(obj1, obj2, obj3, obj4, obj5, obj6, obj7, obj8, obj9, obj0)`**

### 用途

- 將子頁面的處理結果交給開啟端，但保留目前內嵌視窗。

### 輸入

- `obj1` 至 `obj0`: [Any = undefined] - 依固定次序交給完成回呼的最多十筆資料；非基本型別會先嘗試經 JSON 序列化與重建。

### 輸出

- `return`: [undefined] - 完成回呼的回傳值不向外傳遞。

### 對外功能

- 以目前呼叫情境作為 `this`，執行登錄的完成回呼。
- `popupWin.callbackProxy` 為同一函式的別名，具有相同簽章與行為。

### 副作用

- 完成回呼拋出例外時，以警示對話框顯示例外文字並攔截該例外。
- 不會自動關閉內嵌視窗。

---

## **`popupWin.close()`**

### 用途

- 關閉目前的遮罩式內嵌視窗，或在沒有作用中內嵌視窗時關閉目前瀏覽器視窗。

### 輸入

- 無

### 輸出

- `return`: [undefined] - 此操作不回傳關閉結果。

### 對外功能

- 作用中內嵌視窗存在時，執行關閉後回呼、清空內容並恢復背景頁面。
- 作用中內嵌視窗不存在時，直接呼叫瀏覽器的 `window.close()`。

### 副作用

- 可能執行 `config.onClose` 或 `config.onclose`。
- 清除標題、`iframe` 內容、完成回呼與關閉回呼，隱藏視窗並移除 `body.popupWinActive`。
- 直接呼叫本方法不檢查 `config.closeConfirm`；該確認只在使用者點擊標題列關閉按鈕時執行。

---

## **`popupWin.createPopupLink(text, inConfig, inWidth, inHeight, inLeft, inTop, inScrolling, inParameters)`** — 設定物件用法

### 用途

- 建立一個點擊後呼叫 `popupWin.popup(config)` 的超連結元素。

### 輸入

- `text`: [String] - 直接寫入連結 `innerHTML` 的顯示內容。
- `inConfig`: [Object] - 設定結構與 `popupWin.popup` 設定物件用法相同。
- `inWidth`, `inHeight`, `inLeft`, `inTop`, `inScrolling`, `inParameters`: [Any = undefined] - `inConfig` 為物件時全部忽略。

### 輸出

- `return`: [HTMLAnchorElement|undefined] - 建立的 `<a href="#">`；`config` 無效時為 `undefined`。

### 對外功能

- 將設定物件封裝在元素的點擊處理函式中，供呼叫端自行插入頁面。

### 副作用

- 建立尚未插入文件的元素並設定 `onclick`；函式本身不開啟視窗。
- `text` 未經轉義即寫入 `innerHTML`。

---

## **`popupWin.createPopupLink(text, inConfig, inWidth, inHeight, inLeft, inTop, inScrolling, inParameters)`** — 位置參數用法

### 用途

- 以位置參數建立一般內嵌視窗的啟動連結。

### 輸入

- `text`: [String] - 直接寫入連結 `innerHTML` 的顯示內容。
- `inConfig`: [String] - 此模式下作為目標網址 `src`。
- `inWidth`, `inHeight`: [Number|String = undefined] - 內容尺寸。
- `inLeft`, `inTop`: [Number|String = undefined] - 顯示位置。
- `inScrolling`: [Boolean|String|Function = undefined] - 是否允許內容捲動。
- `inParameters`: [Object|Array|String|Number|Boolean = undefined] - 送往目標頁面的資料。

### 輸出

- `return`: [HTMLAnchorElement] - 建立的啟動連結。

### 對外功能

- 先保存位置參數形成的設定物件，點擊時以該物件呼叫 `popupWin.popup(config)`。

### 副作用

- 與 `popupWin.createPopupLink(text, config)` 相同。

---

## **`popupWin.createPopupButton(text, inConfig, inWidth, inHeight, inLeft, inTop, inScrolling, inParameters)`** — 設定物件用法

### 用途

- 建立一個點擊後呼叫 `popupWin.popup(config)` 的按鈕元素。

### 輸入

- `text`: [String] - 直接寫入按鈕 `innerHTML` 的顯示內容。
- `inConfig`: [Object] - 設定結構與 `popupWin.popup` 設定物件用法相同。
- `inWidth`, `inHeight`, `inLeft`, `inTop`, `inScrolling`, `inParameters`: [Any = undefined] - `inConfig` 為物件時全部忽略。

### 輸出

- `return`: [HTMLButtonElement|undefined] - `type="button"` 且套用 `button` 類別的按鈕；`config` 無效時為 `undefined`。

### 對外功能

- 將設定物件封裝在按鈕的點擊處理函式中，供呼叫端自行插入頁面。

### 副作用

- 建立尚未插入文件的元素並設定 `onclick`；函式本身不開啟視窗。
- `text` 未經轉義即寫入 `innerHTML`。

---

## **`popupWin.createPopupButton(text, inConfig, inWidth, inHeight, inLeft, inTop, inScrolling, inParameters)`** — 位置參數用法

### 用途

- 以位置參數建立一般內嵌視窗的啟動按鈕。

### 輸入

- `text`: [String] - 直接寫入按鈕 `innerHTML` 的顯示內容。
- `inConfig`: [String] - 此模式下作為目標網址 `src`。
- `inWidth`, `inHeight`: [Number|String = undefined] - 內容尺寸。
- `inLeft`, `inTop`: [Number|String = undefined] - 顯示位置。
- `inScrolling`: [Boolean|String|Function = undefined] - 是否允許內容捲動。
- `inParameters`: [Object|Array|String|Number|Boolean = undefined] - 送往目標頁面的資料。

### 輸出

- `return`: [HTMLButtonElement] - 建立的啟動按鈕。

### 對外功能

- 先保存位置參數形成的設定物件，點擊時以該物件呼叫 `popupWin.popup(config)`。

### 副作用

- 與 `popupWin.createPopupButton(text, config)` 相同。

---

## **`popupWin.createFullPopupLink(text, inConfig, inScrolling, inParameters)`** — 設定物件用法

### 用途

- 建立一個點擊後以完整畫面開啟設定內容的超連結元素。

### 輸入

- `text`: [String] - 直接寫入連結 `innerHTML` 的顯示內容。
- `inConfig`: [Object] - 設定結構與 `popupWin.fullPopup` 設定物件用法相同。
- `inScrolling`, `inParameters`: [Any = undefined] - `inConfig` 為物件時忽略。

### 輸出

- `return`: [HTMLAnchorElement|undefined] - 建立的 `<a href="#">`；`config` 無效時為 `undefined`。

### 對外功能

- 點擊時將原始 `config` 傳給 `popupWin.fullPopup(config)`。

### 副作用

- 建立尚未插入文件的元素並設定 `onclick`；函式本身不開啟視窗。
- 點擊後 `popupWin.fullPopup(config)` 會改寫該設定物件的完整畫面與關閉確認欄位。

---

## **`popupWin.createFullPopupLink(text, inConfig, inScrolling, inParameters)`** — 位置參數相容用法

### 用途

- 建立完整畫面的啟動連結；此相容簽章只可靠地保留 `src`。

### 輸入

- `text`: [String] - 直接寫入連結 `innerHTML` 的顯示內容。
- `inConfig`: [String] - 此模式下作為目標網址 `src`。
- `inScrolling`: [Boolean|String|Function = undefined] - 原始簽章接受此參數，但建立後不會傳入完整畫面開啟流程。
- `inParameters`: [Object|Array|String|Number|Boolean = undefined] - 原始簽章接受此參數，但建立後不會傳入完整畫面開啟流程。

### 輸出

- `return`: [HTMLAnchorElement] - 建立的啟動連結。

### 對外功能

- 點擊時只呼叫 `popupWin.fullPopup(src)`。

### 副作用

- `scrolling` 與 `parameters` 雖先被組成區域設定物件，點擊處理函式卻未使用該物件；因此兩者實際遭忽略。

---

## **`popupWin.createFullPopupButton(text, inConfig, inScrolling, inParameters)`** — 設定物件用法

### 用途

- 建立一個點擊後以完整畫面開啟設定內容的按鈕元素。

### 輸入

- `text`: [String] - 直接寫入按鈕 `innerHTML` 的顯示內容。
- `inConfig`: [Object] - 設定結構與 `popupWin.fullPopup` 設定物件用法相同。
- `inScrolling`, `inParameters`: [Any = undefined] - `inConfig` 為物件時忽略。

### 輸出

- `return`: [HTMLButtonElement|undefined] - 建立的 `type="button"` 按鈕；`config` 無效時為 `undefined`。

### 對外功能

- 點擊時將原始 `config` 傳給 `popupWin.fullPopup(config)`。

### 副作用

- 建立尚未插入文件的元素並設定 `onclick`；函式本身不開啟視窗。
- 點擊後 `popupWin.fullPopup(config)` 會改寫該設定物件的完整畫面與關閉確認欄位。

---

## **`popupWin.createFullPopupButton(text, inConfig, inScrolling, inParameters)`** — 位置參數相容用法

### 用途

- 建立完整畫面的啟動按鈕；此相容簽章只可靠地保留 `src`。

### 輸入

- `text`: [String] - 直接寫入按鈕 `innerHTML` 的顯示內容。
- `inConfig`: [String] - 此模式下作為目標網址 `src`。
- `inScrolling`: [Boolean|String|Function = undefined] - 原始簽章接受此參數，但建立後不會傳入完整畫面開啟流程。
- `inParameters`: [Object|Array|String|Number|Boolean = undefined] - 原始簽章接受此參數，但建立後不會傳入完整畫面開啟流程。

### 輸出

- `return`: [HTMLButtonElement] - 建立的啟動按鈕。

### 對外功能

- 點擊時只呼叫 `popupWin.fullPopup(src)`。

### 副作用

- `scrolling` 與 `parameters` 雖先被組成區域設定物件，點擊處理函式卻未使用該物件；因此兩者實際遭忽略。

---

## **`popupWin.windowOpen(url, opts)`**

### 用途

- 以獨立瀏覽器視窗開啟目標頁面，並透過 `POST` 傳遞業務資料。

### 輸入

- `url`: [String] - 目標網址，設定為暫存表單的 `action`。
- `opts`: [Object = {}] - 獨立視窗設定。
  - `opts.parameters`: [Object = {}] - 送往目標頁面的欄位名稱與值。
  - `opts.attributes`: [Object = {}] - 傳給 `window.open` 的視窗特徵。預設值見[代碼對照表](#代碼對照表)；同名欄位覆蓋預設值。
  - `opts.windowName`: [String = "popupWinWindowOpen"] - 視窗名稱；相同名稱通常會重用既有視窗。
  - `opts.fullScreen`: [Boolean = false] - 僅嚴格等於 `true` 時啟用完整畫面；此時強制覆蓋寬、高、上、左等特徵。

### 輸出

- `return`: [undefined] - 原始實作未回傳 `window.open` 建立的視窗參照。

### 對外功能

- 開啟或重用具名視窗，再以隱藏表單將 `opts.parameters` 送往該視窗。

### 副作用

- 建立或重用識別為 `_popupWin_windowOpen_form` 的隱藏表單，並於每次呼叫時清空及重建欄位。
- 將最上層頁面的 `eBAF_loginSystemInfo`、`eBAF_UserObject_Flag` 一併送出；來源不存在時略過。
- 呼叫 `window.open` 及原生表單 `submit()`；瀏覽器可能依安全設定阻擋新視窗。

## 代碼對照表

### 布林相容值

| 欄位預設值 | 明確反轉值 | 其他值的結果 |
| --- | --- | --- |
| `true` | 僅嚴格等於 `false` 時回傳 `false` | 回傳 `true` |
| `false` | 僅嚴格等於 `true` 時回傳 `true` | 回傳 `false` |
| `"Y"`（`scrolling`） | 僅嚴格等於 `false` 時回傳 `false` | 回傳字串 `"Y"`，後續作為啟用 |
| `Function` | 先以無參數方式呼叫函式 | 再依該欄位預設值套用上述嚴格比較 |

> 原始 `getBoolean` 並非一般的 JavaScript truthy／falsy 或 `Y`／`N` 轉換。尤其 `scrolling: "N"` 仍會啟用捲動；外部使用者應傳入明確的 `true` 或 `false`。

### `windowOpen` 預設視窗特徵

| 特徵 | 一般模式 | `fullScreen: true` |
| --- | --- | --- |
| `status` | `no` | `no` |
| `toolbar` | `no` | `no` |
| `menubar` | `no` | `no` |
| `resizable` | `yes` | `no`；仍可由 `opts.attributes.resizable` 先覆蓋，但完整畫面分支不再改寫此欄位 |
| `scrollbars` | `yes` | `yes` |
| `width` / `height` | 未預設 | 強制為 `screen.availWidth` / `screen.availHeight` |
| `top` / `left` | 未預設 | 強制為 `0` / `0` |
