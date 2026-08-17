# tabs.js 公開契約

> 原始資源：`/CM/js/ui/tabs.js`

## **`new Tabs(id, config)`** — 容器識別用法

### 用途

- 將指定容器及其既有內容重組為一層或兩層頁籤介面。

### 輸入

- `id`: [String|Number|Boolean] - 由 CSS 識別選擇器 `#{id}` 尋找的原容器識別；實際應提供合法且唯一的字串 `id`。
- `config`: [Object = {}] - 頁籤來源、預選項目與切換行為。
  - `config.tabs`: [Array<TabConfig> = undefined] - 明確頁籤設定；未提供陣列時，改從原容器的 `find` 屬性或直接子節點推導。
    - `config.tabs[].id`: [String] - 必填。既有內容元素識別；找不到元素時略過該設定。
    - `config.tabs[].title`: [Any = undefined] - 寫入內容元素 `blockTitle` 的頁籤標題；最終標題依序採 `blockTitle`、元素 `id` 或 `TAB {index}`。
    - `config.tabs[].defaultSelect`: [Any = false] - truthy 時將該頁籤標記為初始選取。
    - `config.tabs[].onClickAction`: [Function = undefined] - 使用者點擊該頁籤時的專屬處理。
      - `onClickAction(mappingId, menuElement)`: [Function(String, HTMLLIElement): Any] - `this` 為頁籤選單元素；回傳值不使用。
    - `config.tabs[].subTabs`: [Array<TabConfig> = undefined] - 子頁籤設定；每個元素遞迴使用相同結構並被搬入父內容元素。
  - `config.selected`: [String|Number = 0] - 初始內容識別或零起算索引；可用 `主索引+子索引` 選擇子頁籤。
  - `config.onClickAction`: [Function|Object = {}] - 使用者點擊處理。函式用法套用到所有頁籤；物件用法以內容識別為鍵。
    - `config.onClickAction(mappingId, menuElement)`: [Function(String, HTMLLIElement): Any] - 全域函式的呼叫簽章，`this` 為選單元素。
    - `config.onClickAction[id]`: [Function(String, HTMLLIElement): Any] - 指定內容的專屬函式；優先於全域函式。
  - `config.beforeSwitch`: [Function = undefined] - 顯示目標內容之前呼叫。
    - `config.beforeSwitch(info)`: [Function(TabSwitchInfo): Any] - 回傳值不使用；可透過同步呼叫其他選取操作改變作用中頁籤，以嘗試中止原切換。
  - `config.afterSwitch`: [Function = undefined] - 顯示目標內容之後呼叫。
    - `config.afterSwitch(info)`: [Function(TabSwitchInfo): Any] - 回傳值不使用。
  - `info`: [TabSwitchInfo] - 切換回呼的資料。
    - `info.from`: [String|null] - 原內容的 `mappingId`；「全部顯示」分支使用原作用中內容的 `id`。
    - `info.from_elem`: [Element|null] - 原內容元素。
    - `info.to`: [String] - 目標 `mappingId`；「全部顯示」時為 `"all"`。
    - `info.to_elem`: [Element|null] - 目標內容元素；「全部顯示」時為 `null`。
  - `config.beforeSwitchShowCover`: [Boolean = false] - 僅嚴格等於 `true` 時，在切換到新 `iframe.src` 前顯示等待遮罩。
  - `config.all`: [Boolean|Object = undefined] - `true` 或物件時建立「全部顯示」頁籤。
    - `config.all.title`: [String = "全部"] - 全部顯示頁籤文字。
    - `config.all.position`: [String = undefined] - 等於 `"left"` 時置於最左側，否則置於末端。
    - `config.all.selected`: [Boolean = false] - 僅嚴格等於 `true` 時將全部顯示設為初始模式。
  - `config.debug`: [Boolean = false] - 僅嚴格等於 `true` 且主控台存在時輸出偵錯訊息。

### 輸出

- `return`: [Tabs] - 頁籤管理執行個體，對外包含 `select`、`removeAll`，另含 `show`、`hide`、`resize`、`getDisplayId`、`getSelectedIndex` 等方法。

### 對外功能

- 從設定陣列或既有 DOM 推導主頁籤與子頁籤，建立選單、內容容器及初始選取狀態。
- 切換時組成 `TabSwitchInfo`，依序呼叫前置回呼、更新內容顯示，再呼叫後置回呼。
- 自動調整選單寬度、作用中 `iframe` 高度及父層彈出視窗的捲動範圍。

### 副作用

- 將原容器替換成同 `id` 的新 `.tabs` 容器，並移動原內容元素；無法保持原 DOM 階層與節點順序。
- 設定每個內容及 `iframe` 的樣式與屬性，建立全域尺寸偵測元素、登錄表、事件及每 `200ms` 執行的永久計時器。
- 空白 `iframe.src` 可能被替換成共用 `dummy.jsp`，後續載入時可能向子頁面注入 `tabs.js` 並呼叫尺寸同步函式。
- `beforeSwitch`、`afterSwitch` 的例外只記錄後繼續；使用者點擊回呼未包在例外處理內。
- `id` 無效、找不到容器或沒有有效頁籤時顯示警示後提早結束；以 `new` 呼叫仍會得到未完整初始化的 `Tabs` 物件。

---

## **`new Tabs(id, config)`** — 單一設定物件用法

### 用途

- 將容器識別與完整頁籤設定集中於同一物件建立頁籤介面。

### 輸入

- `id`: [Object] - 此模式下第一參數即完整設定物件；建構式會將它同時指定給內部 `config`，再以 `id.id` 作為容器識別。
  - `id.id`: [String|Number|Boolean] - 必填。作為目標容器識別。
  - `id.tabs`, `selected`, `onClickAction`, `beforeSwitch`, `afterSwitch`, `beforeSwitchShowCover`, `all`, `debug`: 型別、巢狀結構與回呼簽章均同容器識別用法的 `config`。
- `config`: [Any = undefined] - 此模式下會被第一參數取代，因此呼叫端即使傳入第二參數也不使用。

### 輸出

- `return`: [Tabs] - 與容器識別用法相同的頁籤管理執行個體。

### 對外功能

- 先從 `config.id` 取得容器識別，再執行 `new Tabs(id, config)` 的同一初始化流程。

### 副作用

- 與 `new Tabs(id, config)` 相同；建構式會將函式型態的 `config.onClickAction` 改寫為含 `all_clickAction` 的物件。

---

## **`tabs.select(oEvent)`** — 程式選取用法

### 用途

- 以內容識別或索引切換主頁籤／子頁籤，不視為使用者點擊。

### 輸入

- `oEvent`: [String|Number|Boolean] - 此模式下為目標內容識別或索引。
  - 識別用法：先在頁面全部 `.tabs LI` 中尋找 `mappingId` 相符的第一項。
  - 索引用法：格式為零起算主索引，或 `主索引+子索引`；主索引越界時改選第一項，無法解析為數字時停止。

### 輸出

- `return`: [undefined] - 此操作不回傳選取成功狀態。

### 對外功能

- 更新主選單、子選單及對應內容顯示，並執行 `beforeSwitch`、`afterSwitch`。

### 副作用

- 程式選取不執行 `config.onClickAction` 或頁籤專屬 `onClickAction`；這些處理只在事件型態的使用者選取流程執行。
- 內容為 `iframe` 且目標網址改變時，可能顯示等待遮罩並啟動尺寸同步。
- 全域搜尋 `mappingId` 未限制在本 `Tabs` 執行個體，頁面有重複識別時可能切換到其他頁籤集合的選單元素。

---

## **`tabs.select(oEvent)`** — 使用者事件相容用法

### 用途

- 以頁籤選單元素或其點擊事件執行使用者選取流程。

### 輸入

- `oEvent`: [Event|HTMLLIElement] - 頁籤 `<li>` 本身，或可由 `target`／`srcElement` 取得該元素的事件；目標不是 `<li>` 時停止。

### 輸出

- `return`: [undefined] - 此操作不回傳選取成功狀態。

### 對外功能

- 除一般內容切換外，會在切換前執行目標識別的專屬 `onClickAction`，找不到時執行全域 `all_clickAction`。

### 副作用

- 回呼、內容顯示、等待遮罩與尺寸同步副作用同程式選取用法。
- 直接傳入 `<li>` 會被原始碼視為非使用者呼叫，因此不執行 `onClickAction`；要觸發點擊回呼必須傳入事件或由實際點擊進入。

---

## **`tabs.removeAll()`**

### 用途

- 拆除產生的頁籤選單與內容包裝，將受管理內容重新放回頁籤根容器。

### 輸入

- 無

### 輸出

- `return`: [undefined] - 此操作不回傳還原後的容器。

### 對外功能

- 隱藏頁籤根容器，移除主選單、子選單及內容容器，再依內部頁籤集合把內容節點附加回根容器。

### 副作用

- 子頁籤結構會被逐項攤平後附加，無法完整恢復建構前的父子 DOM 與原始位置。
- 將全域 `_tab_setting_map[id]` 設為 `null`，但不清除建構時建立的永久計時器、全域尺寸偵測元素或所有事件監聽。
- 根容器維持 `display: none`；呼叫端需另行決定是否顯示及是否繼續使用此物件。
