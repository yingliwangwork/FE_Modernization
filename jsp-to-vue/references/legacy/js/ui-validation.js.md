# ui/validation.js 公開契約

> 原始資源：`/CM/js/ui/validation.js`
>
> 公開狀態：傳統腳本載入後會在全域範圍宣告 `Validator` 規則類別與 `Validation` 表單類別；其中 `Validator` 名稱與 `/CM/js/Validator.js` 的管理類別相同，最終值取決於載入順序。

## **`String.prototype.Blength()`**

### 用途

- 計算舊式欄位規則使用的字串長度。

### 輸入

- 無

### 輸出

- `return`: [Number] - 原始演算法計算的長度；字串本身的 `length` 加上符合正規表示式 `[^u4e00-u9fa5]` 的字元數。

### 對外功能

- 提供 `minLength` 與 `maxLength` 附加條件所使用的相容長度計算。
- 此方法沿用原始正規表示式，結果不等同 Unicode 字元數或實際儲存位元組數。

### 副作用

- 無

---

## **`Validation.add(className, error, test, options)`**

### 用途

- 登錄一項可由欄位樣式名稱或 `Validation.test` 引用的驗證規則。

### 輸入

- `className`: [String] - 規則識別。
- `error`: [String = "輸入檢核錯誤."] - 規則失敗時的預設錯誤訊息；空值會套用預設字串。
- `test`: [Function|Object] - 基礎判定函式，或省略基礎判定函式時使用的附加條件物件。
  - `test(value, element, info)`: [Function] - 一般欄位判定簽章。
    - `value`: [Any] - 欄位值。
    - `element`: [Element] - 受驗欄位。
    - `info`: [Object = undefined] - 呼叫端傳入的驗證控制資訊。
    - `return`: [Boolean] - 通過時為 `true`。
  - `test(...values)`: [Function] - `info.multiTest === true` 時的呼叫形態；原始實作以 `Function.apply` 將第一個參數中的陣列內容展開為位置參數，並直接回傳基礎判定結果，不執行 `options` 附加條件。
- `options`: [Object = undefined] - 基礎判定通過後依序套用的附加條件；`test` 不是函式時，改由 `test` 參數充當此物件，第四個參數不會使用。支援鍵值請參閱[代碼對照表](#代碼對照表)。
  - `options.pattern`: [RegExp = undefined] - 非空值必須符合的格式。
  - `options.minLength`: [Number = undefined] - `Blength()` 結果的下限。
  - `options.maxLength`: [Number = undefined] - `Blength()` 結果的上限。
  - `options.min`: [Number = undefined] - 含界限值的數值下限。
  - `options.max`: [Number = undefined] - 含界限值的數值上限。
  - `options.gt`: [Number = undefined] - 不含界限值的數值下限。
  - `options.lt`: [Number = undefined] - 不含界限值的數值上限。
  - `options.notOneOf`: [Array<Any> = undefined] - 禁止值集合；以寬鬆不等判定。
  - `options.oneOf`: [Array<Any> = undefined] - 允許值集合；以寬鬆相等判定。
  - `options.is`: [Any = undefined] - 必須寬鬆相等的固定值。
  - `options.isNot`: [Any = undefined] - 不得寬鬆相等的固定值。
  - `options.equalToField`: [String|Element = undefined] - 值必須寬鬆相等的另一欄位。
  - `options.notEqualToField`: [String|Element = undefined] - 值不得寬鬆相等的另一欄位。
  - `options.include`: [Array<String> = undefined] - 同一值還必須全部通過的其他規則識別。

### 輸出

- 無

### 對外功能

- 建立包含規則識別、錯誤訊息、基礎判定與附加條件的規則物件。
- 一般欄位判定中，未辨識的附加條件鍵值會被忽略，不會使驗證失敗；多欄位判定則略過全部附加條件。

### 副作用

- 新增或覆蓋 `Validation.methods[className]`；後續驗證立即使用新定義。

---

## **`Validation.addAllThese(validators)`**

### 用途

- 依固定位置契約批次登錄多項驗證規則。

### 輸入

- `validators`: [Array<Array>] - 規則定義集合。
  - `validators[][0]`: [String] - 規則識別。
  - `validators[][1]`: [String] - 規則失敗時的預設錯誤訊息。
  - `validators[][2]`: [Function|Object] - 基礎判定函式，或省略基礎判定函式時使用的附加條件物件；函式簽章與 `Validation.add` 的 `test` 相同。
  - `validators[][3]`: [Object = {}] - 基礎判定函式存在時使用的附加條件；鍵值請參閱[代碼對照表](#代碼對照表)。

### 輸出

- 無

### 對外功能

- 將每個位置式定義轉成與 `Validation.add` 相同的規則物件。

### 副作用

- 逐項新增或覆蓋 `Validation.methods` 中的同名規則。

---

## **`Validation.get(name)`**

### 用途

- 依規則識別取得已登錄的規則物件。

### 輸入

- `name`: [String] - 規則識別。

### 輸出

- `return`: [ValidatorRule] - 同名規則；找不到時為識別 `_LikeNoIDIEverSaw_` 的永遠通過替代規則。
  - `return.className`: [String] - 規則識別。
  - `return.error`: [String] - 預設錯誤訊息。
  - `return.options`: [Hash] - 附加條件集合。
  - `return.test(value, element, info)`: [Function] - 執行基礎判定與附加條件。

### 對外功能

- 解析規則識別，並以替代規則維持未知識別不阻斷驗證的相容行為。

### 副作用

- 無

---

## **`Validation.test(name, elm, useTitle, info)`** — `validate` 逐欄提示模式

### 用途

- 執行單一欄位規則，並以欄位旁提示內容呈現結果。

### 輸入

- `name`: [String] - 要執行的規則識別。
- `elm`: [Element] - 待驗證欄位；模式實作會直接讀取其值、屬性及樣式方法。
- `useTitle`: [Boolean = false] - 失敗時是否優先使用欄位 `title` 作為錯誤訊息。
- `info`: [Object = undefined] - 本次驗證控制資訊。
  - `info.mode`: [String = undefined] - 必須省略且使全域 `Validation.mode` 為 `validate`，或明確指定 `validate`；代碼請參閱[代碼對照表](#代碼對照表)。
  - `info.multiTest`: [Boolean = false] - 為 `true` 時，規則物件會將值集合展開成基礎判定函式的位置參數。

### 輸出

- `return`: [Boolean] - 規則通過、欄位因不可見而略過，或規則識別不存在時為 `true`；規則失敗時為 `false`。

### 對外功能

- `info.mode` 存在時使用 `Validation.manner[info.mode]`，否則使用全域 `Validation.mode`。
- 以 `$F(elm)` 取值；欄位不可見時略過規則判定並按通過路徑清理既有錯誤。

### 副作用

- 失敗時可能建立或更新欄位旁錯誤提示、顯示提示，並寫入失敗樣式與錯誤追蹤屬性。
- 通過或略過時會隱藏既有提示、移除對應錯誤紀錄，並依剩餘錯誤狀態更新通過／失敗樣式。
- `info.mode` 不是有效代碼時，存取其模式方法會發生執行錯誤。

---

## **`Validation.test(name, elm, useTitle, info)`** — `validator` 彙總提示模式

### 用途

- 執行單一欄位規則，並將失敗結果納入彙總提示模式的錯誤狀態。

### 輸入

- `name`: [String] - 要執行的規則識別。
- `elm`: [Element] - 待驗證欄位；模式實作會直接讀取其值、屬性及樣式方法。
- `useTitle`: [Boolean = false] - 失敗時是否優先使用欄位 `title` 作為錯誤訊息。
- `info`: [Object = undefined] - 本次驗證控制資訊。
  - `info.mode`: [String = undefined] - 必須省略且使全域 `Validation.mode` 為 `validator`，或明確指定 `validator`；代碼請參閱[代碼對照表](#代碼對照表)。
  - `info.multiTest`: [Boolean = false] - 為 `true` 時，規則物件會將值集合展開成基礎判定函式的位置參數。
  - `info.showAlert`: [Boolean = false] - 失敗時是否立即顯示本欄錯誤訊息。

### 輸出

- `return`: [Boolean] - 規則通過、欄位因不可見而略過，或規則識別不存在時為 `true`；規則失敗時為 `false`。

### 對外功能

- `info.mode` 存在時使用 `Validation.manner[info.mode]`，否則使用全域 `Validation.mode`。
- 欄位 `datatype` 嚴格等於大寫 `ROCDATE` 時讀取原始 `value`；其他情況以 `$F(elm)` 取值。
- 欄位不可見時略過規則判定並按通過路徑清理既有錯誤。

### 副作用

- 失敗時將 `fieldName + " [" + errorMessage + "]\n"` 累加至模式的 `errMsg`，並寫入失敗樣式與錯誤追蹤屬性。
- `info.showAlert === true` 時另顯示本欄錯誤提示視窗；靜態 `Validation.test` 本身不會顯示整批彙總訊息。
- 通過或略過時會移除對應錯誤紀錄，並依剩餘錯誤狀態更新通過／失敗樣式。
- `info.mode` 不是有效代碼時，存取其模式方法會發生執行錯誤。

---

## **`Validation.reset(elm)`**

### 用途

- 清除指定欄位在所有已知呈現模式中的驗證狀態。

### 輸入

- `elm`: [String|Element] - 要重設的欄位識別或欄位本身；各模式會以 Prototype 的 `$()` 解析。

### 輸出

- 無

### 對外功能

- 依序呼叫 `validate` 與 `validator` 模式的欄位重設流程。

### 副作用

- 隱藏並停用既有欄位旁錯誤提示。
- 移除通過、單欄失敗與跨欄失敗樣式，以及原始碼建立的錯誤追蹤屬性。
- `validator` 模式同時清空其全域彙總錯誤訊息。

---

## **`Validation.mode`**

### 用途

- 保存未明確指定模式之驗證共用的目前呈現策略。

### 輸入

- 無

### 輸出

- `Validation.mode`: [ValidationMode] - `Validation.manner` 中目前選定的模式物件；代碼請參閱[代碼對照表](#代碼對照表)。
  - `Validation.mode.validate(element, options, info)`: [Function] - 驗證欄位所有樣式規則。
  - `Validation.mode.test(name, element, useTitle, info, notIgnoreHidden)`: [Function] - 執行單項規則並呈現結果。
  - `Validation.mode.reset(element)`: [Function] - 清除欄位狀態。
  - `Validation.mode.multiValidate(validationName, elements, options)`: [Function] - 執行跨欄位規則。

### 對外功能

- 載入時若 `CSRUtil.UICore.isOnTheSys(['DS'])` 為真，初始值為 `validator`；其他情況為 `validate`。

### 副作用

- 外部改寫此屬性後，所有未透過 `info.mode` 或 `options.mode` 指定策略的驗證會共用新值。

---

## **`new Validation(form, options)`**

### 用途

- 建立表單層級驗證管理物件，整合欄位規則、跨欄位規則、錯誤呈現與回呼。

### 輸入

- `form`: [String|Element] - 要管理的表單識別或表單本身。
- `options`: [Object = {}] - 表單驗證設定。
  - `options.onSubmit`: [Boolean = false] - 是否於表單送出時自動執行驗證，並阻止未通過的送出。
  - `options.stopOnFirst`: [Boolean = false] - 是否在第一個欄位失敗後停止一般欄位驗證；跨欄位規則仍於其後執行。
  - `options.immediate`: [Boolean = false] - 是否在每個欄位的 `change` 事件立即驗證該欄位。
  - `options.focusOnError`: [Boolean = true] - 整體驗證失敗時，是否將焦點移到第一個可見且未停用的失敗欄位。
  - `options.useTitles`: [Boolean = false] - 是否使用欄位 `title` 作為錯誤訊息。
  - `options.checkReadOnly`: [Boolean = true] - 是否驗證唯讀欄位。
  - `options.checkDisabled`: [Boolean = false] - 是否驗證停用欄位。
  - `options.onFormValidate(result, form)`: [Function = function(result, form) {}] - 整體與跨欄位驗證完成後的回呼。
    - `result`: [Boolean] - 整體結果。
    - `form`: [Element] - 受驗表單。
    - `return`: [Any] - 回傳值不使用。
  - `options.onElementValidate(result, element)`: [Function = function(result, elm) {}] - 每個欄位樣式規則完成後的回呼。
    - `result`: [Boolean] - 單項規則結果。
    - `element`: [Element] - 受驗欄位。
    - `return`: [Any] - 回傳值不使用。
  - `options.toNextError`: [Boolean = true] - 即時驗證通過後，是否將焦點移到下一個既有錯誤欄位。
  - `options.notIgnoreHidden`: [Boolean = false] - 是否連不可見欄位也納入驗證。
  - `options.mode`: [String = Validation.defaultManner] - 呈現模式；代碼請參閱[代碼對照表](#代碼對照表)。
  - `options.alertTitle`: [String = ""] - `validator` 模式顯示整批彙總提示時，置於固定標題之前的自訂前綴；此鍵不在預設物件中，但會由模式結束流程讀取。

### 輸出

- `return`: [Validation] - 綁定指定表單的驗證管理物件。
  - `return.options`: [Object] - 合併預設值後的設定。
  - `return.form`: [Element] - 經 `$()` 解析的表單。
  - `return.verifyList`: [Object<String, Array>] - 由實例方法 `define` 登錄的跨欄位規則集合。
  - `return.validate(info)`: [Function] - 執行表單驗證並回傳布林結果。
  - `return.reset(isOnlyForm)`: [Function] - 清除表單欄位驗證狀態。

### 對外功能

- 解析表單並保存合併預設值後的驗證設定。
- 將 `Validation.mode` 設為 `Validation.manner[options.mode]`，供本實例與其他未指定模式的呼叫共用。

### 副作用

- `options.onSubmit` 為真時，登錄表單 `submit` 事件；驗證失敗會停止該事件。
- `options.immediate` 為真時，為表單目前的每個欄位登錄 `change` 事件；通過時可能依 `toNextError` 移動焦點。
- 建立其他 `Validation` 實例或外部改寫 `Validation.mode`，會改變本實例後續使用的共用策略。
- 無效的 `options.mode` 會把 `Validation.mode` 設為 `undefined`，後續驗證或事件處理會發生執行錯誤。

## 代碼對照表

### 驗證呈現模式

| 代碼 | 專業語意 | 主要行為 |
|---|---|---|
| `validate` | 逐欄提示模式 | 使用欄位旁提示內容、通過樣式與失敗樣式呈現結果。 |
| `validator` | 彙總提示模式 | 累積失敗訊息與欄位標記；表單驗證完成後以提示視窗彙總呈現。 |

### 規則附加條件

| 鍵值 | 判定語意 |
|---|---|
| `pattern` | 空值直接通過；非空值必須通過指定正規表示式的 `test`。 |
| `minLength`、`maxLength` | 以 `Blength()` 結果限制長度。 |
| `min`、`max` | 設定含界限值的數值範圍。 |
| `gt`、`lt` | 設定不含界限值的數值範圍。 |
| `oneOf`、`notOneOf` | 以寬鬆相等限制允許或禁止的值集合。 |
| `is`、`isNot` | 以寬鬆相等限制固定值。 |
| `equalToField`、`notEqualToField` | 以寬鬆相等和另一欄位的 `$F()` 值比較。 |
| `include` | 對同一值連帶執行且要求全部通過的其他規則識別。 |
