# 項目查閱服務契約

版本：fixture-v1。性質：沙盒中用於測試的後端交付契約，非正式服務。沒有可呼叫環境。

## 操作

- operationId：`searchItems`
- Method / Path：`POST /v2/items/search`
- Request / Response：`application/json`
- Request body 為 object，`queryText` 是 string、選填、最大長度 12，省略或空字串表示不指定關鍵字。`null` 不合法。
- 業務執行所需單位識別由服務端情境提供，不接受 client 傳入 `unitId`。
- 認證傳輸機制尚未定義。

## 回應

HTTP 200 的 body 是 object，含必有的 `outcome` string 及 `rows` array。
`outcome`：`OK` 表示成功；`EMPTY` 表示無項目；`DENIED` 表示不允許查阅。
`rows` 每項為 object，只定義必有的 `rowId` string 和 `label` string。
`EMPTY`／`DENIED` 時 `rows=[]`。未定義其他結果碼或非 200 回應。

## Legacy 對應

此操作承接 legacy action `searchRows`。
輸入 `search_word` 對應目標 `queryText`；原有前端 trim 操作仍適用。
回應 `businessResult=DONE/NONE/BLOCK` 分別對應 `outcome=OK/EMPTY/DENIED`。
`itemList` 對應 `rows`；`itemKey` 對應 `rowId`；`itemText` 對應 `label`。
本契約未承接 `rankHint`、JSP 首次載入的審閱者名稱或數量送出行為。
