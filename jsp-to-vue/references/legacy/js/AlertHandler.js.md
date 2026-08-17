# AlertHandler.js 公開契約

> 原始資源：`/CM/js/AlertHandler.js`

## **`new AlertHandler()`**

### 用途

- 建立可收集驗證訊息、標記錯誤欄位、清除狀態及顯示彙總提示的錯誤管理物件。

### 輸入

- 無

### 輸出

- `return`: [AlertHandler] - 新錯誤管理物件。
  - `return.msg`: [Array<String>] - 已收集的錯誤訊息，初始為空陣列。
  - `return.markList`: [Array<Element>] - 已標記欄位，初始為空陣列。
  - `return.handle(obj)`: [Function] - 收集並標記一筆驗證失敗資料。
  - `return.display()`: [Function] - 顯示彙總提示。
  - `return.mark(element)`: [Function] - 標記錯誤欄位。
  - `return.clear()`: [Function] - 清除本輪狀態。
  - `return.focus`: [undefined] - 建構式立即執行 `Alert_focus()` 並保存其無回傳結果，因此不是可呼叫方法。
  - `return.executeDisplayMessage`: [Boolean = true] - 本輪是否仍可顯示彙總提示。

### 對外功能

- 提供驗證流程所需的訊息集合、欄位標記及一次性提示控制。

### 副作用

- 建構期間以未綁定實例的普通函式呼叫執行一次 `Alert_focus()`；在原始非嚴格模式腳本中，函式會檢查全域物件的 `markList`，通常不會移動焦點。

---

## **`errHandler.display()`**

### 用途

- 將 `errHandler.msg` 依收集順序組成彙總提示。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 以固定標題 `檢核錯誤如下:\n` 加上每筆訊息與換行建立提示內容。

### 副作用

- `executeDisplayMessage` 為真時顯示提示視窗，並在顯示前將該旗標設為 `false`。
- 未呼叫 `clear()` 前最多顯示一次；即使訊息集合為空，第一次直接呼叫仍顯示固定標題。

---

## **`errHandler.clear()`**

### 用途

- 清除已收集的訊息與欄位標記，並重新允許顯示提示。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 將 `msg` 與 `markList` 重設為新空陣列、將 `focusElement` 設為 `null`，並將 `executeDisplayMessage` 設為 `true`。

### 副作用

- 將每個已標記欄位的 `style.backgroundColor` 設為空字串；不保存或還原標記前的既有背景色。

---

## **`errHandler.handle(obj)`**

### 用途

- 收集一筆驗證失敗訊息並標記其欄位。

### 輸入

- `obj`: [Object] - 驗證失敗資料。
  - `obj.desc`: [String] - 欄位業務名稱。
  - `obj.errMsg`: [String] - 規則失敗訊息。
  - `obj.element`: [Element] - 要標記的欄位。

### 輸出

- 無

### 對外功能

- 將 `obj.desc + "[" + obj.errMsg + "]"` 加入訊息集合，並呼叫 `mark(obj.element)`。

### 副作用

- 在 `msg` 與 `markList` 末端各新增一筆資料，並將欄位背景色改為 `#FF8888`。
- `obj.element` 無效或沒有預期的 `style` 結構時會發生執行錯誤；訊息在錯誤發生前已加入集合。

---

## **`errHandler.mark(e)`**

### 用途

- 將指定欄位加入本輪錯誤標記集合。

### 輸入

- `e`: [Element] - 要標記的欄位。

### 輸出

- 無

### 對外功能

- 保存欄位參照，供清除流程逐筆還原背景色。

### 副作用

- 在 `markList` 末端加入欄位，並將 `e.style.backgroundColor` 設為 `#FF8888`。
- 同一欄位可重複加入；`clear()` 會依紀錄次數重複將背景色設為空字串。

---

## **`errHandler.focus()`**

### 用途

- 表達原始 `Alert_focus()` 將焦點移到 `markList` 第一個欄位的設計意圖。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 實際公開屬性 `errHandler.focus` 為 `undefined`，不具可呼叫功能。

### 副作用

- 呼叫 `errHandler.focus()` 會發生「非函式」型別錯誤；焦點不會由此公開語法移動。
