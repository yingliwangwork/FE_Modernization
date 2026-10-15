# 範例使用與語意對照

將 order.jsp 及 order-api.md 複製到暫存專案的 source/，在該暫存專案 `.agents/jsp-to-spec.yaml` 設 source_roots 為 `["source"]`、sot_roots 為 `["source"]`、output_root 為 `.agents/docs`。交由獨立 agent 僅呼叫 `jsp="source/order.jsp"`，應自行發現並讀取相關契約 order-api.md，產物放 `.agents/docs/order/`。不要建立 fragments/header.jsp：範例刻意保留一個介面缺口。

| 來源事實 | 技術中立表達 | 常見誤轉換 |
| --- | --- | --- |
| choose 中 error 分支優先 | 錯誤文字非空時只顯示錯誤區，既有資料列不顯示 | 錯誤和清單同時出現 |
| 檢查輸入 trim 結果，但不回寫 | 全空白阻止查詢，通過時仍送出原輸入 | 自動把送出值 trim |
| 有序 orders 集合 | 依供應順序逐筆顯示編號及客戶名稱 | 新增頁面端排序 |
| 缺少 header.jsp | 頁首供應能力與 SP，保留頁首的未確認區塊 | 猜測導覽列與使用者名稱 |
| 以 render model 返回 | 記錄 request scope 原始資料與提交契約 | 發明 REST JSON 回應 |

可見狀態包括首次／空結果、資料列、服務錯誤及在各個既有畫面上觸發的本地空白驗證提示。最後一類保留原來的結果區，只加入固定的提示示意；不能把不同背景畫面合併成一張通用錯誤頁。

單一與多筆正常資料可在等價分類中選代表值；錯誤時 orders 有無不影響輸出，可歸為同一可見狀態。header 缺件應在所有受影響 HTML 中明示 SP，且規格不得宣稱已完整等價。
