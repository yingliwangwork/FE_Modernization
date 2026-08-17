# Validator.js 公開契約

> 原始資源：`/CM/js/Validator.js`
>
> 公開狀態：傳統腳本載入後會宣告全域 `Validator` 及其內建 `AlertHandler`；後者可能依載入順序替換 `/CM/js/AlertHandler.js` 的同名建構式，且此版本另有單選按鈕（radio）群組標記行為。

## **`validateStringBytes(v, min, max)`**

### 用途

- 依單位元組與非單位元組字元的換算長度檢核必填文字及選用界限。

### 輸入

- `v`: [String] - 待檢核文字；必須支援 `replace()`。
- `min`: [Number = undefined] - 換算長度下限；假值表示不設下限。
- `max`: [Number = undefined] - 換算長度上限；假值表示不設上限。

### 輸出

- `return`: [Boolean] - 換算長度符合已啟用界限時為 `true`；兩個界限皆未啟用時，長度大於零才為 `true`。

### 對外功能

- `\x00` 至 `\xff` 範圍內的字元計一個單位；其他字元各計 `window.charCountsByte || 2` 個單位。
- 輸入不支援 `replace()` 時會發生執行錯誤。

### 副作用

- 無

---

## **`validateNum(v, min, max)`**

### 用途

- 檢核必填數值及選用的數值上下界限。

### 輸入

- `v`: [String|Number] - 待檢核值；字串長度小於等於零或 `isNaN(v)` 為真時失敗。數值型別沒有 `length`，不會觸發空字串判定。
- `min`: [Number|String = undefined] - 數值下限；`parseInt(min)` 可解析時啟用，實際比較仍使用原值並由 JavaScript 執行型別轉換。
- `max`: [Number|String = undefined] - 數值上限；`parseInt(max)` 可解析時啟用，實際比較仍使用原值並由 JavaScript 執行型別轉換。

### 輸出

- `return`: [Boolean] - 值可視為數值、不是空字串，且位於已啟用的閉區間內時為 `true`。

### 對外功能

- 以 `parseInt` 判斷界限是否啟用，再以寬鬆數值比較執行範圍檢核。

### 副作用

- 無

---

## **`validateString(v, min, max)`**

### 用途

- 依 JavaScript 字串長度檢核必填文字及選用界限。

### 輸入

- `v`: [String|Array|Object|null|undefined] - 待檢核值；非空值直接讀取 `length`，空值按長度零處理。
- `min`: [Number = undefined] - 長度下限；假值表示不設下限。
- `max`: [Number = undefined] - 長度上限；假值表示不設上限。

### 輸出

- `return`: [Boolean] - 長度符合已啟用界限時為 `true`；兩個界限皆未啟用時，長度大於零才為 `true`。

### 對外功能

- 以輸入值的 `length` 屬性執行閉區間長度判定。
- 非空輸入沒有數值型 `length` 時，部分比較會因 `undefined` 轉換為 `NaN` 而通過。

### 副作用

- 無

---

## **`validateDateInput(v)`**

### 用途

- 檢核八位西元年月日，並兼容斜線或連字號分隔格式。

### 輸入

- `v`: [String] - 待檢核值；必須支援 `replace()`。

### 輸出

- `return`: [Boolean] - 移除分隔符號後符合 `YYYYMMDD`，且可構成真實年月日時為 `true`。

### 對外功能

- 依序各執行兩次非全域的斜線與連字號移除，再以正規表示式擷取年、月、日並交叉核對 `Date` 結果。
- 僅在載入時 `window.validateDateInput` 不存在的情況下建立此實作；既有同名函式會保留。

### 副作用

- 載入原始資源時可能新增 `window.validateDateInput`。
- 呼叫本身不改寫輸入字串；輸入不支援 `replace()` 時會發生執行錯誤。

---

## **`new Validator()`**

### 用途

- 建立可登錄欄位規則、逐項判定、收集欄位標記並彙總錯誤的驗證管理物件。

### 輸入

- 無

### 輸出

- `return`: [Validator] - 新驗證管理物件。
  - `return.checkObjectList`: [Array<CheckObject>] - 已登錄欄位規則，初始為空陣列。
  - `return.define(n, desc, errMsg, type, min, max)`: [Function] - 登錄欄位規則。
  - `return.validate()`: [Function] - 依所在子系統選用標準流程或 `validateOld`。
  - `return.validateOld()`: [Function] - 執行規則但不主動清除或顯示錯誤。
  - `return.clear()`: [Function] - 清除規則與錯誤狀態。
  - `return.errHandler`: [AlertHandler] - 內建錯誤收集器。
    - `return.errHandler.msg`: [Array<String>] - 已收集訊息。
    - `return.errHandler.markList`: [Array<Element>] - 已標記欄位。
    - `return.errHandler.executeDisplayMessage`: [Boolean = true] - 本輪是否仍可顯示彙總提示。
    - `return.errHandler.focus`: [undefined] - 建構式保存 `Alert_focus()` 的無回傳結果，不是可呼叫方法。

### 對外功能

- DD、DF、DJ、AK 子系統將 `validate` 直接指向 `validateOld`；其他子系統使用會先清除並在失敗時顯示彙總訊息的標準流程。

### 副作用

- 建立一個內建 `AlertHandler`；建構期間以未綁定實例的普通函式呼叫執行一次 `Alert_focus()`，原始非嚴格模式腳本通常不會因而移動焦點。
- 子系統判定會讀取目前頁面的 `window.location`。

---

## **`validator.define(n, desc, errMsg, type, min, max)`**

### 用途

- 將欄位、業務說明、失敗訊息、判定函式與限制組成一筆欄位規則。

### 輸入

- `n`: [String|Element] - 欄位識別或欄位本身。
  - [String] - 存在 Prototype 時以 `$()` 解析，否則以 `document.getElementById()` 解析；執行時除 `datatype="rocdate"` 外，Prototype 環境以 `$F()` 取值。
  - [Element] - 直接保存該物件與其 `name`；不設定 `hasIncludePrototype`，執行時直接讀取 `element.value`。
- `desc`: [String = undefined] - 欄位業務名稱；預設處理器會放在錯誤訊息前。
- `errMsg`: [String = undefined] - 規則失敗時的預設錯誤訊息。
- `type`: [String|Function] - 內建規則代碼、全域自訂函式名稱或自訂判定函式；內建代碼請參閱[代碼對照表](#代碼對照表)。
  - `type(value, min, max, checkObject)`: [Function] - 自訂判定函式簽章。
    - `value`: [Any] - 欄位值。
    - `min`: [Any] - 第一個限制值。
    - `max`: [Any] - 第二個限制值。
    - `checkObject`: [CheckObject] - 本筆完整規則，可供群組型判定讀取 `name`、`element` 等資訊。
      - `checkObject.name`: [String] - 欄位名稱或傳入識別。
      - `checkObject.element`: [Element] - 經解析後的欄位。
      - `checkObject.desc`: [String] - 欄位業務名稱。
      - `checkObject.errMsg`: [String] - 目前錯誤訊息；判定函式也可回傳新訊息覆寫此值。
      - `checkObject.type`: [String|Function] - 原始規則類型。
      - `checkObject.min`: [Any] - 第一個限制值。
      - `checkObject.max`: [Any] - 第二個限制值。
      - `checkObject.validate`: [Function] - 解析完成後的實際判定函式。
      - `checkObject.hasIncludePrototype`: [Boolean|undefined] - 僅以字串欄位識別建立時記錄 Prototype 是否存在。
    - `return`: [Boolean|String|Object] - 布林判定；字串或具有真值 `errMsg` 的物件表示失敗並覆寫訊息。
- `min`: [Any = undefined] - 第一個限制值；內建規則通常解讀為長度或數值下限。
- `max`: [Any = undefined] - 第二個限制值；內建規則通常解讀為長度或數值上限。

### 輸出

- 無

### 對外功能

- 解析內建代碼或 `window[type]` 自訂函式，建立 `CheckObject` 並加入目前驗證集合。

### 副作用

- 成功時在 `validator.checkObjectList` 末端新增規則。
- 找不到欄位、規則函式或 `type` 不支援 `toUpperCase()` 時會拋出錯誤；先前規則維持不變。

---

## **`validator.validate()`** — 一般子系統

### 用途

- 清除上一輪狀態、執行目前全部適用規則，並在失敗時顯示本輪彙總錯誤。

### 輸入

- 無

### 輸出

- `return`: [Boolean] - 全部適用規則通過時為 `true`，任一規則失敗時為 `false`。

### 對外功能

- 建構時所在頁面未匹配 DD、DF、DJ、AK 子系統時，此入口指向標準流程。
- 先呼叫錯誤處理器的 `clear()`，再執行 `validateOld()`；失敗時呼叫 `display()`。

### 副作用

- 還原上一輪標記欄位的背景色，再收集與標記本輪失敗欄位。
- 驗證失敗時顯示一次彙總提示視窗。

---

## **`validator.validate()`** — DD／DF／DJ／AK 子系統

### 用途

- 執行目前全部適用規則，但不自動清除既有錯誤或顯示彙總訊息。

### 輸入

- 無

### 輸出

- `return`: [Boolean] - 全部適用規則通過時為 `true`，任一規則失敗時為 `false`。

### 對外功能

- 建構時所在頁面匹配 DD、DF、DJ 或 AK 子系統時，此入口直接指向與 `validateOld()` 相同的函式。

### 副作用

- 失敗資料會交由目前錯誤處理器收集與標記，但不顯示彙總提示。
- 不會先清除既有錯誤，重複呼叫可能累積相同訊息與欄位紀錄。

---

## **`validator.clear()`**

### 用途

- 清除全部已登錄欄位規則與內建錯誤處理器狀態。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 將規則集合重設為新的空陣列，並呼叫 `errHandler.clear()`。

### 副作用

- 捨棄所有 `checkObjectList` 項目、清空訊息與標記、重新允許顯示提示，並將先前標記欄位的背景色設為空字串。

---

## **`validator.validateOld()`**

### 用途

- 執行目前全部適用規則，但不主動清除狀態或顯示彙總訊息。

### 輸入

- 無

### 輸出

- `return`: [Boolean] - 全部適用規則通過時為 `true`，任一規則失敗時為 `false`。

### 對外功能

- 略過欄位不存在或 `disabled` 為真的規則。
- 欄位 `datatype` 轉成小寫後不等於 `rocdate`，且規則由字串欄位識別在 Prototype 環境建立時，以 `$F()` 取值；其他情況直接讀取 `element.value`。
- 依序呼叫 `checkObject.validate(value, min, max, checkObject)`，不因單一失敗停止後續規則。

### 副作用

- 判定函式回傳字串或具有真值 `errMsg` 的物件時，會把內容寫回 `checkObject.errMsg` 並視為失敗。
- 失敗時若 `errHandler` 是函式，直接以規則物件呼叫；若是物件，呼叫其 `handle()`。
- 內建處理器會收集 `desc[errMsg]` 並將失敗欄位背景色設為 `#FF8888`；單選按鈕（radio）欄位會依 `name` 標記同名群組的每個欄位。
- 此入口不會先清除舊狀態，重複呼叫可能累積相同訊息與欄位紀錄。

---

## **`validator.errHandler.clear()`**

### 用途

- 清除內建錯誤處理器已收集的訊息與欄位標記。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 重設訊息、焦點占位值、標記集合與提示顯示資格。

### 副作用

- 將每個已標記欄位的 `style.backgroundColor` 設為空字串；不保存或還原標記前的既有背景色。

---

## **`validator.errHandler.display()`**

### 用途

- 將內建錯誤處理器目前收集的訊息組成彙總提示。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 以固定標題 `檢核錯誤如下:\n` 加上每筆訊息與換行建立提示內容。

### 副作用

- `executeDisplayMessage` 為真時顯示一次提示視窗並改為 `false`；即使訊息集合為空仍顯示固定標題。
- 未呼叫 `clear()` 前的後續呼叫不再顯示提示。

## 代碼對照表

### `validator.define` 內建規則

| `type` | 規則意圖 | `min`／`max` 語意 |
|---|---|---|
| `STRING` | 必填值與 `length` 限制。 | 最小／最大長度。 |
| `NUM` | 必填數值與閉區間限制。 | 數值下限／上限。 |
| `SELECT` | 值不得為 `undefined`、`null` 或空字串。 | 不使用。 |
| `DATE`、`DATE_INPUT` | 八位西元年月日格式與日曆有效性。 | 不使用。 |
| `STRING_BYTES` | 依單位元組與非單位元組字元換算長度。 | 最小／最大換算長度。 |
| `CHECKED` | 以規則的 `name` 尋找同名欄位，至少一項必須勾選。 | 不使用。 |
| `AMT` | 移除全部逗號後檢核必填金額與閉區間。 | 數值下限／上限。 |
| 其他字串 | 以原始大小寫從 `window[type]` 解析全域自訂判定函式。 | 原樣傳給自訂函式。 |
