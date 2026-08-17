# utility.js 公開契約

> 原始資源：`/CM/js/utility.js`

## **`submitOnce(button, openWindow, coverOnly)`** — 一次性送出用法

### 用途

- 找出操作元素所屬表單，建立防止重複操作的狀態後送出表單。

### 輸入

- `button`: [Element] - 表單本身或位於表單內的操作元素；原始碼沿父節點向上尋找第一個 `<form>`。
- `openWindow`: [Boolean = false] - truthy 時表示由新視窗承接結果，不建立等待遮罩，也不監聽具名 frame／iframe 載入完成。
- `coverOnly`: [Boolean = undefined] - 未傳入或不嚴格等於 `true` 時，完成準備後觸發表單送出。

### 輸出

- `return`: [undefined] - 此操作不回傳送出結果；輸入或重複狀態無效時亦為 `undefined`。

### 對外功能

- 以 `{form.action}-{form.target}` 組成送出識別並寫入 `already-submit`；原始重複判斷存在型別錯誤，無法可靠攔截相同送出。
- 先呼叫 `utility.overrideSubmitByForm(form)`，再以 `submit` 事件或原生 `form.submit()` 觸發統一送出流程。
- `button` 為 `<button>` 或 `type="button"` 的 `<input>` 時，建立同名隱藏欄位保留操作值。

### 副作用

- 一般同頁送出建立全頁等待遮罩，設定表單 `already-submit`，並停用實際按鈕；具名 frame／iframe 目標可能在載入完成後解除遮罩與按鈕。
- 有 `name` 的按鈕會被移除 `name`；缺少 `id` 時以原 `name` 補上 `id`。隱藏操作欄位不會在此函式中移除。
- `openWindow` 為 truthy 或表單 `target="_blank"` 時不建立遮罩，但實際按鈕仍會停用，且沒有本函式提供的自動恢復流程。
- 多數執行例外只寫入主控台；即使準備階段例外，函式仍會繼續嘗試送出表單。
- 表單祖先搜尋位於 `try` 區塊之外；`button` 已脫離 DOM，或祖先鏈未經 `<body>`／`<form>` 時，可能因存取 `null.tagName` 而直接擲出例外。
- 重複判斷實際為 `!!form.getAttribute('already-submit') == action_target`：左側先轉為布林值，通常不會等於右側字串，因此即使標記內容相同仍可能再次送出。

---

## **`submitOnce(button, openWindow, coverOnly)`** — 僅鎖定用法

### 用途

- 建立與一次性送出相同的等待及防重複狀態，但不觸發表單送出。

### 輸入

- `button`: [Element] - 表單本身或位於表單內的操作元素。
- `openWindow`: [Boolean = false] - 遮罩與 frame 監聽判定同一次性送出用法。
- `coverOnly`: [Boolean = undefined] - 必須嚴格等於 `true`，才在準備完成後直接結束；其他值進入一次性送出用法。

### 輸出

- `return`: [undefined] - 此操作不回傳鎖定控制器。

### 對外功能

- 執行表單解析、等待遮罩、統一送出包裝、重複送出標記及按鈕停用，但略過最終送出。

### 副作用

- 表單可能永久保留 `already-submit`、隱藏操作欄位及送出包裝；按鈕與遮罩也可能持續作用，直到其他流程自行解除。
- 其餘準備階段副作用與一次性送出用法相同。
- 此模式亦受表單祖先搜尋可能直接擲錯，以及 `already-submit` 比較型別錯誤影響。

---

## **`submitToUpper(element)`**

### 用途

- 將內容範圍內可自動轉換的文字輸入值改為大寫。

### 輸入

- `element`: [Element|DocumentFragment] - DOM 元素或文件片段；其他型別直接判定失敗。

### 輸出

- `return`: [Boolean] - 輸入為節點型別 `1` 或 `11` 且完成巡覽時為 `true`，否則為 `false`。

### 對外功能

- 巡覽所有後代 `<input type="text">`，略過名稱或識別以 `EMAIL` 開頭，以及 `autoToUppercase="false"` 的欄位。

### 副作用

- 直接以 JavaScript `toUpperCase()` 改寫符合條件的欄位值。
- 只處理後代元素，不處理 `element` 本身；不觸發欄位的 `change` 或 `input` 事件。

---

## **`trimSpace(frm)`**

### 用途

- 移除指定內容範圍內文字及隱藏輸入欄位的尾端空白。

### 輸入

- `frm`: [Element] - 任一 DOM 元素；不是元素時直接停止。

### 輸出

- `return`: [undefined] - 此操作不回傳處理欄位數。

### 對外功能

- 巡覽後代 `<input>`，只對 `type="text"` 或 `type="hidden"` 套用尾端空白移除規則。

### 副作用

- 直接改寫符合條件的欄位值；保留前導空白及文字中間空白。
- 不處理 `textarea`、`select` 或 `frm` 本身，且不觸發欄位事件。

---

## **`disableButton(theform)`**

### 用途

- 透過 `submitOnce(..., false, true)` 建立表單防重複與等待狀態，但不送出表單。

### 輸入

- `theform`: [Element] - 表單本身，或位於表單內的操作元素；參數名稱雖為 `theform`，實際接受範圍與 `submitOnce` 的 `button` 相同。

### 輸出

- `return`: [undefined] - 不傳遞內部 `submitOnce` 的結果。

### 對外功能

- 等同呼叫 `submitOnce(theform, false, true)`。

### 副作用

- 與 `submitOnce(button, openWindow, coverOnly)` 的僅鎖定用法相同，包括遮罩、表單標記、送出包裝及可能的按鈕停用。

---

## **`utility.overrideSubmitByForm(theForm)`**

### 用途

- 將指定表單的程式送出與送出事件接到共通環境參數及回應時間追蹤流程。

### 輸入

- `theForm`: [HTMLFormElement] - 要包裝的表單；必須具有可呼叫且未被同名欄位遮蔽的 `submit` 方法。

### 輸出

- `return`: [undefined] - 不回傳原始送出方法或是否完成包裝。

### 對外功能

- 保存原 `theForm.submit` 至 `_originalSubmit`，以共通 `overrideSubmit` 取代，並在支援 `addEventListener` 時同時登錄 `submit` 事件。
- 一般表單送出前補入最上層頁面的登入資訊、使用者旗標、目前請求時間，以及 `keepResponseTimeEndParameters` 保存的追蹤資料。
- `multipart/form-data` 表單改將登入資訊與使用者旗標附加至 `action` 查詢字串。

### 副作用

- 設定 `_originalSubmit`、覆寫 `submit`、登錄事件並寫入 `submit_rewrited="Y"`；相同表單只包裝一次。
- 共用登入及時間欄位在 `utility` 閉包中重用，包裝多個表單送出時元素會被移至最後送出的表單。
- 追蹤資料每筆建立兩個新隱藏欄位，送出後只清空最上層暫存陣列，不移除表單中已建立的欄位，後續可能重複送出舊值。
- multipart 查詢參數未在此函式中 URI 編碼；包裝內例外只寫入主控台，之後仍呼叫原始送出方法。

---

## **`utility.keypressNumberOnly(isDot, isNegative)`**

### 用途

- 判定目前全域鍵盤事件是否為允許的 ASCII 數字、小數點或負號。

### 輸入

- `isDot`: [Any = false] - truthy 時允許鍵碼 `46` 的小數點。
- `isNegative`: [Any = false] - truthy 時允許鍵碼 `45` 的負號。

### 輸出

- `return`: [Boolean] - `event.keyCode` 為 `48` 至 `57`，或為已啟用的小數點／負號時為 `true`。

### 對外功能

- 提供 `keypress` 處理器使用的單一按鍵白名單判定，不檢查欄位既有內容或游標位置。

### 副作用

- 讀取隱含的全域 `event`，未提供該全域的瀏覽器或非事件情境可能拋出例外。
- 導覽鍵、刪除鍵與其他控制鍵不在白名單；呼叫端若直接以回傳值阻止事件，可能連控制操作一併阻止。

---

## **`utility.keypressNumberValue(obj, isDot, isNegative)`**

### 用途

- 依欄位現值判定目前按鍵能否加入數字，並代為處理負號及小數點起始值。

### 輸入

- `obj`: [Object] - 具有可讀寫字串 `value` 的輸入欄位。
- `isDot`: [Any = false] - truthy 時允許一個小數點。
- `isNegative`: [Any = false] - truthy 時允許負號。

### 輸出

- `return`: [Boolean] - 允許瀏覽器繼續輸入目前字元時為 `true`；不允許或已由函式代為處理時為 `false`。

### 對外功能

- 只允許 ASCII 數字及啟用的符號；阻止第二個小數點及值已為 `"0"` 時再輸入 `0`。
- 負號尚不存在時直接加在欄位最前方；空欄位輸入小數點時先補上 `0`，再允許瀏覽器插入小數點。

### 副作用

- 讀取隱含的全域 `event`，並可能直接改寫 `obj.value`。
- 不依游標位置插入負號，也不提供移除負號的切換行為；不驗證完整結果是否符合一般數值格式。

---

## **`utility.keepResponseTimeEndParameters(uuid)`**

### 用途

- 在最上層瀏覽環境保存一筆作業識別與目前時間，供下一次一般表單送出回報前一作業的完成時間。

### 輸入

- `uuid`: [Any] - truthy 的作業追蹤識別；原樣保存為 `UUID`。

### 輸出

- `return`: [undefined] - 不回傳保存結果。

### 對外功能

- 於全局狀態（`top.responseTimeEndParameters`）末端加入 `{ UUID: uuid, requestTimeField: dateJs.getCurrentTimeStamp() }`。

### 副作用

- 建立或改寫全局狀態（`top` 視窗）之 `responseTimeEndParameters` 陣列；後續經 [`utility.overrideSubmitByForm`](#utilityoverridesubmitbyformtheform) 包裝的一般表單送出會讀取並清空該集合。
- `uuid` 為 falsy、`dateJs.getCurrentTimeStamp` 不存在或存取跨視窗狀態失敗時靜默略過。

---

## **`utility.keep_eBAF_parameter(opt)`**

### 用途

- 將登入平台/系統資訊等鍵值寫入全局狀態（`top` 視窗），供後續表單送出與視窗開啟流程沿用。

### 輸入

- `opt`: [Object, 選填] - 以鍵值對表示的待寫入資料；未提供時不執行任何動作。
  - `opt.{key}`: [Any] - 待寫入 `top` 之鍵值；空字串會略過，不寫入。

### 輸出

- `return`: [undefined] - 不回傳寫入結果。

### 對外功能

- 逐一檢查全局狀態（`top`）是否已有同名鍵值，僅在不存在（falsy）時才寫入該鍵，不覆寫既有值；空字串值一律略過。

### 副作用

- 直接於全局狀態（`top` 視窗）建立或補上對應鍵值；寫入結果會被 [`utility.overrideSubmitByForm`](#utilityoverridesubmitbyformtheform) 等既有送出流程讀取沿用。
- `opt` 未提供或存取跨視窗狀態（`top`）失敗時靜默略過。
