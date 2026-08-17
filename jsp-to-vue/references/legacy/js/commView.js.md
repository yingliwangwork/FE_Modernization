# commView.js 公開契約

> 原始資源：`/CM/js/ui/commView.js`

## **`viewBizEvent(FLOW_NO, openAtNewPopupWin)`**

### 用途

- 開啟指定流程的作業歷程檢視頁面，並將視窗配置在目前可視範圍的右下方。

### 輸入

- `FLOW_NO`: [Any] - 流程識別；未經編碼即串接至目標網址的 `FLOW_NO` 查詢參數。
- `openAtNewPopupWin`: [Boolean = false] - 僅嚴格等於 `true` 時使用專屬 `PopupWinUI` 執行個體；其他值使用全域 `popupWin`。

### 輸出

- `return`: [undefined] - 此操作不回傳視窗參照。

### 對外功能

- 依目前網址中的系統前綴選擇 `JZ`、`DZ` 或預設 `RZ` 系統，組成 `/{系統}Web/servlet/HttpDispatcher/{系統}N0_0200/prompt?FLOW_NO={FLOW_NO}`。
- 以最大 `600 × 350` 的尺寸開啟內嵌視窗；可視範圍較小時縮至頁面寬高各減十像素。

### 副作用

- 呼叫全域或專屬 `popupWin.popup(...)`，載入作業歷程內容並改變頁面覆蓋層狀態。
- 專屬模式首次使用時建立並快取全域 `eventViewWin`，後續呼叫重用該執行個體。
- 未載入 `ui/popupWin.js` 時顯示警示對話框後停止。
- `FLOW_NO` 未經 URI 編碼；含保留字元時可能改變查詢字串結構。
