# jquery.orgchart.js 公開契約

> 原始資源：`/DS/skeletons/orgChart/js/jquery.orgchart.js`

## **`$(selector).orgchart({ data: data, nodeContent: "title", direction: "b2t" })`**

### 用途

- 在選取的容器中，建立由下往上排列且顯示節點 `title` 內容的組織階層圖。

### 輸入

- `selector`: [String|Element|jQuery] - 傳給 jQuery 的目標容器選擇條件；集合中的容器共同由同一個 `OrgChart` 執行個體管理。
- `data`: [Object|jQuery|String] - 組織階層資料。
  - `data.name`: [Any] - 本簽章未覆寫 `nodeTitle`，因此預設作為節點標題。
  - `data.title`: [Any = ""] - 由 `nodeContent: "title"` 指定為節點內容。
  - `data.id`: [String|Number = undefined] - 本簽章未覆寫 `nodeId`，因此預設作為節點元素識別；父節點有識別時也會寫入子節點的 `parentId`。
  - `data.children`: [Array<Object> = undefined] - 遞迴的子節點集合；每個元素沿用相同結構。
  - `data.className`: [String = ""] - 附加至節點元素的樣式類別。
  - `data.collapsed`: [Boolean = false] - 是否在初始化時隱藏子階層。
  - `data.relationship`: [String = 自動推導] - 三位關係旗標，依序表示父層、同層與子層是否存在；代碼見[代碼對照表](#代碼對照表)。
  - `data.level`: [Number = 自動推導] - 節點層級，影響可見層級判定。
- `data` 為 `[jQuery]` 時：內容須為階層式 `<ul><li>`，外掛會將其轉成上述物件結構。
- `data` 為 `[String]` 時：視為 JSON 資料網址，以非同步 `GET` 取得階層物件。
- `nodeContent`: [String = "title"] - 固定指定要顯示在節點內容區的資料欄位名稱。
- `direction`: [String = "b2t"] - 固定指定由下往上的排列方向；其他方向代碼見[代碼對照表](#代碼對照表)。

### 輸出

- `return`: [OrgChart] - 已初始化的組織圖管理執行個體，不是原 jQuery 集合。

### 對外功能

- 將階層資料轉成組織圖節點、關係線與展開／收合控制，並把圖表附加至目標容器。
- 既有執行個體重新初始化時先移除舊圖表；本簽章每次呼叫均建立新的執行個體。

### 副作用

- 在目標容器加入 `.orgchart` 結構、節點識別、資料副本、樣式類別與互動事件。
- `data` 為網址時執行非同步請求；等待期間顯示載入圖示，失敗時僅將錯誤寫入主控台。
- 為節點資料補入 `relationship`、`level`、`parentId` 等欄位，因而可能改寫呼叫端提供的物件。

## 代碼對照表

### `direction` 排列方向

| 代碼 | 方向 |
| --- | --- |
| `t2b` | 由上往下 |
| `b2t` | 由下往上 |
| `l2r` | 由左往右 |
| `r2l` | 由右往左 |

### `relationship` 三位旗標

| 位置 | `1` | `0` |
| --- | --- | --- |
| 第一位 | 存在父層 | 不存在父層 |
| 第二位 | 存在同層節點 | 不存在同層節點 |
| 第三位 | 存在子層 | 不存在子層 |
