### AFY1_0400.doPrompt(RequestContext) - 查詢畫面初始化 (Prompt)

#### 1. 功能描述
- 初始化公會通報下傳查詢頁面，設定畫面預設控制參數(含今日民國年日期)後回傳給前端渲染。

#### 2. 輸入 / 輸出參數
**輸入參數：**
- `req`：`RequestContext` — 前端請求物件，本方法內未讀取其任何內容。

**輸出參數：**
- 回傳值：`ResponseContext`（即類別成員變數 `resp`），包含以下 output data：
  - `resp.insrDate`：`String` — 今日民國年日期，格式如 `"1121209"`，由 `DATE.getROCDate()` 取得
  - `resp.showEdit`：`String` — 固定值 `"N"`，控制畫面是否顯示編輯按鈕
  - `resp.showQuery`：`boolean` — 固定值 `false`，控制畫面查詢結果區塊的顯示狀態
  - `resp.isRType`：`boolean` — 固定值 `false`，控制畫面是否為 R 類型模式

#### 3. 業務流程與商業邏輯
1. 呼叫 `DATE.getROCDate()` 取得今日民國年日期字串(格式如 `"1121209"`)，以鍵值 `"insrDate"` 寫入 `resp`。
2. 以鍵值 `"showEdit"` 寫入固定字串 `"N"` 至 `resp`，表示初始畫面不顯示編輯按鈕。
3. 以鍵值 `"showQuery"` 寫入固定值 `false` 至 `resp`，表示初始畫面不顯示查詢結果區塊。
4. 以鍵值 `"isRType"` 寫入固定值 `false` 至 `resp`，表示初始畫面非 R 類型模式。
5. 回傳 `resp`。

#### 4. 例外與訊息處理
- 本方法無例外處理邏輯，不捕捉任何例外。

#### 5. 內部方法呼叫
- 本方法無呼叫同類別的 private / protected 方法。

#### 6. 外部模組 / 方法呼叫
- 本方法無需列出的業務邏輯外部模組呼叫。


---

