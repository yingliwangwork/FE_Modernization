# ui.js 公開契約

## 使用語法清單

**方法**:
- [msgWin.show()](#msgwinshow)
- [msgWin.setCallback()](#msgwinsetcallback)
- [msgWin.clearCallback()](#msgwinclearcallback)
- [cleanMsgBoard()](#cleanmsgboard)

---

## 共用模式
`msgWin` 為本檔案載入時建立之全域訊息視窗單例（**僅當網頁尚未定義過此物件時才會建立**），下列方法皆為該單例之操作介面。

---

## msgWin.show()
**使用範例**: `msgWin.show(Msg);`
**輸入**:
- msg: 字串 - 欲顯示之訊息內容，支援換行符號
**輸出**: 無
**功能**:
- 開啟置中顯示之訊息視窗，並暫時停用頁面捲動
- **當視窗尚未開啟時**: 建立新視窗顯示訊息
- **當視窗已開啟時**: 將新訊息附加於既有內容之後
- 依訊息長度自動調整視窗寬度（有最小/最大寬度限制）
- 監聽鍵盤 Enter、Esc、空白鍵，觸發等同按下確定按鈕之關閉行為
- **當點擊視窗的確定按鈕時**: 關閉視窗、清除已顯示之訊息紀錄、還原頁面捲動狀態，並執行透過 `setCallback()` 設定的回呼函式（如有設定）

---

## msgWin.setCallback()
**使用範例**: `msgWin.setCallback(function(){actions.doReject();});`
**輸入**:
- callback: 函式 - 訊息視窗經由確定按鈕關閉時執行之回呼函式；**傳入非函式之值（如空字串）時**，視同不執行回呼
**輸出**: 無
**功能**:
- 設定訊息視窗透過確定按鈕關閉時所執行之回呼函式

---

## msgWin.clearCallback()
**使用範例**: `msgWin.clearCallback();`
**輸入**: 無
**輸出**: 無
**功能**:
- 清除已透過 `setCallback()` 設定之回呼函式

---

## cleanMsgBoard()
**使用範例**: `cleanMsgBoard();`
**輸入**: 無
**輸出**: 無
**功能**:
- 清空目前頁面可存取之訊息看板區域內容
- **當找不到訊息看板區域時**: 不執行任何動作
- 執行過程中發生例外時，攔截並記錄除錯訊息，不中斷程式執行
