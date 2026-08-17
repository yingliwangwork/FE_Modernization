# msgDisplayer.jsp 公開契約

**原始資源**: `/CM/msgDisplayer.jsp`
**使用情境**: 功能頁面共用作業結果訊息顯示
**使用方式**: `<%@ include file="/html/CM/msgDisplayer.jsp" %>`
**主要功能**:
- 將本次回應之訊息轉換為前端可讀取之訊息清單
- 彙整需提示之錯誤與例外訊息
- 呈現彙整後之訊息內容
- 同步首筆訊息至共用通知區
- 提供通知清除方法
- 送出或按鈕操作時自動清除既有通知

## 全局狀態

**訊息資料**:
- **msgs**: 本次回應之訊息陣列，每筆七欄

| 索引 | 欄位 | 說明 |
|---|---|---|
| 0 | displayMsgDescs | 顯示訊息 |
| 1 | msgid | 錯誤編號 |
| 2 | sysid | 系統別 |
| 3 | type | 訊息類型 |
| 4 | url | 關聯位置 |
| 5 | returnCode | 回傳碼（`0`=成功，`99`=保留於通知區，其餘=須提示之錯誤） |
| 6 | displayException | 例外原因 |

**通知區介面**:
- **msgDisplayer.getBottomFrame()**: 於最上層或父層視窗中，尋找名為 `bottomFrame`（可能巢狀於 `leftFrame`）之視窗
- **msgDisplayer.clearBottomMsg()**: 清除 `bottomFrame` 視窗目前顯示的訊息
- **getMsgBoard()**: 取得 `bottomFrame` 視窗之 `cathay_common_msgBoard` 物件

**訊息顯示方法**:
- **alertMessages()**: 顯示具例外原因之訊息，以及 `returnCode` 非 `0`/`99` 之一般訊息
- **displayMessage()**: 略過 `bottomFrame` 標記交易已回復（`txHasRollbackPage`）之情形；否則將首筆訊息之回傳碼與顯示內容同步至 `bottomFrame`，並呼叫 `alertMessages()`


## {原始簽章ex: msgDisplayer.jsp}
**使用情境**: 共用訊息顯示區
**使用方式**: `<%@ include file="/html/CM/msgDisplayer.jsp" %>`
**主要功能**:
- 顯示後端回應訊息