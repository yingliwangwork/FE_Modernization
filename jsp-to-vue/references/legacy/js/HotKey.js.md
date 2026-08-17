# HotKey.js 公開契約

> 原始資源：`/CM/js/HotKey.js`

## **`HotKeys.addHotKey(Keys.Enter, new ButtonAction(button))`**

### 用途

- 建立 Enter 鍵與指定操作元素之間的快捷操作關係。

### 輸入

- `Keys.Enter`: [String = "13"] - Enter 鍵識別；其他代碼請參閱[代碼對照表](#代碼對照表)。
- `button`: [Element] - 快捷鍵觸發時要呼叫 `click()` 的操作元素。

### 輸出

- 無

### 對外功能

- 將 Enter 鍵碼 `13` 對應至一個按鈕點擊動作。
- `new ButtonAction(button)` 產生的物件會直接保存到快捷鍵集合。

### 副作用

- 將 `HotKeys.count` 加一，並新增或覆蓋 `HotKeys.actions["13"]`。
- 後續文件層級 `keydown` 事件符合 Enter 時會呼叫 `button.click()`，再將舊式事件物件的 `returnValue` 設為 `false`。
- 同一按鍵已有動作時仍會覆寫且累加 `count`，因此 `count` 不代表目前唯一映射數量。

---

## **`new ButtonAction(button)`**

### 用途

- 將既有操作元素包裝成快捷鍵管理器可執行的動作物件。

### 輸入

- `button`: [Element|null|undefined] - 快捷鍵觸發時要呼叫 `click()` 的元素。

### 輸出

- `return`: [ButtonAction] - 新動作物件。
  - `return.button`: [Element] - 僅在 `button != null` 時建立，值為傳入元素。
  - `return.execute()`: [Function] - 僅在 `button != null` 時建立；呼叫 `return.button.click()`，沒有回傳值。

### 對外功能

- 提供符合 `HotKeys` 所需 `execute()` 介面的按鈕點擊動作。
- `button` 為 `null` 或 `undefined` 時仍建立物件，但不具有 `button` 與 `execute` 成員。
- 後續呼叫 `execute()` 會觸發元素的 `click()` 行為及其事件處理流程。

### 副作用

- 無

---

## **`HotKeys.addHotKey(hotKey, action)`**

### 用途

- 以按鍵識別登錄一個可執行動作，供文件層級鍵盤處理器查找。

### 輸入

- `hotKey`: [String|Number] - 單一按鍵碼，或修飾鍵前綴與按鍵碼串接的識別；代碼及組合方式請參閱[代碼對照表](#代碼對照表)。
- `action`: [Any] - 按鍵符合時要執行的動作；登錄時不驗證型別。
  - `action.execute()`: [Function = undefined] - 實際快捷操作；缺少此函式時仍可登錄，但事件符合時不執行動作，也不修改 `event.returnValue`。
    - `return`: [Any] - 回傳值不使用。

### 輸出

- 無

### 對外功能

- 將 `action` 保存於 `HotKeys.actions[hotKey]`；物件屬性鍵會依 JavaScript 規則轉成字串。
- 鍵盤處理器取 `event.keyCode || event.which`，再依修飾鍵優先序組成查找鍵；詳見[代碼對照表](#代碼對照表)。

### 副作用

- 每次呼叫均將 `HotKeys.count` 加一，即使覆寫既有映射亦然。
- 載入原始資源時已建立全域 `HotKeys` 與 `Keys`，並以 `document.onkeydown = HotKeys.perform` 覆寫該屬性先前的鍵盤處理器。
- 找到具有 `execute()` 的動作時會執行它，並將 `event.returnValue` 設為 `false`；原始實作不呼叫 `preventDefault()`，也不從處理器回傳 `false`。

## 代碼對照表

### `Keys` 按鍵識別

| 分類 | 常數與值 |
|---|---|
| 功能鍵 | `F1="112"`、`F2="113"`、`F3="114"`、`F4="115"`、`F5="116"`、`F6="117"`、`F7="118"`、`F8="119"`、`F9="120"`、`F10="121"`、`F11="122"`、`F12="123"` |
| 編輯與確認 | `Backspace="8"`、`Tab="9"`、`Enter="13"`、`Esc="27"`、`Space="32"`、`Insert="45"`、`Delete="46"` |
| 導覽鍵 | `PageUp="33"`、`PageDown="34"`、`End="35"`、`Home="36"`、`Left="37"`、`Up="38"`、`Right="39"`、`Down="40"` |
| 修飾鍵前綴 | `Alt="Alt"`、`Ctrl="Ctrl"`、`Shift="Shift"` |

### 複合鍵組成

- 複合鍵以字串直接串接，例如 `Keys.Ctrl + Keys.F3` 形成 `Ctrl114`。
- 事件同時含多個修飾鍵時，原始處理器以互斥分支依 `Alt`、`Ctrl`、`Shift` 順序只採用第一個符合者。
- 沒有修飾鍵時僅使用數值鍵碼查找；物件屬性存取會將它轉成對應字串。
