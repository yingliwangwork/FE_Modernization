# fixture-case：前端 API 消費規格 v1

[前端規格](../../design/fixture-case/specification.md) · [tracking](../../renovation/fixture-case/tracking.md) · [backend handoff](backend-handoff.md)

權威 backend_root：inputs/backend，指定 api-contract.md fixture-v1（E-06）與 business-rules.md fixture-v1（E-07）；精確 SHA-256 見 [inventory](../../renovation/fixture-case/source-inventory.json)。性質為沙盒後端交付契約、非正式服務，沒有可呼叫環境；部署狀態未確認。此投影不是新後端權威。採 explicit override 並保留 Consumer Impact，補充 api-writing.md 的「相依消費端」規則僅決定格式。

## 1. 本輪需求及操作索引

| FLOW／BOUND | 需求 | 操作或缺口 | 兩端證據 |
|---|---|---|---|
| FLOW-02/BOUND-01 | 關鍵字查閱、結果與資料列 | API-01 searchItems；DATA-04 排序提示缺口 TODO-02 | E-02/04 + E-06/07 |
| FLOW-01/BOUND-02 | 初次呈現審閱者名稱 | HANDOFF-01，TODO-01；無已取得操作 | E-01/03 + E-06 明確未承接 |
| FLOW-03/BOUND-03 | 數量計費與儲存 | HANDOFF-02，TODO-03；無已取得操作 | E-01/02/03 + E-06 明確未承接 |

## API-01

### 操作與傳輸

operationId `searchItems`；`POST /v2/items/search`；請求及回應 `application/json`。HTTP 200 body 是 object，沒有另套 envelope；必有 `outcome` string 及 `rows` array。認證傳輸機制尚未定義，[TODO-04](../../renovation/fixture-case/tracking.md#todo-04)。單位識別由服務端情境提供，不接受 client `unitId`。重送、冪等、取消、逾時、排序、分頁、交易未知，不能自行添加。（E-06/07）

### 請求契約與來源

| wire 路徑 | 型別／限制 | 空值及必填 | 前端映射／時機 | 證據 |
|---|---|---|---|---|
| body.queryText | string，最大長度 12 | 選填；省略或 `""` 不指定關鍵字；null 不合法 | DATA-02/UI-03；FLOW-02 啟動時 trim 後傳入；UI 12 字元限制和後端接受條件分開 | E-02/03 + E-06 |
| 服務端單位情境 | 未定義 wire 型別；不是 client 參數 | 由服務端提供 | DATA-06；前端不得新增 unitId 欄位或假設認證 header | E-06/07；TODO-04 |

### 回應完整已知契約與消費

| wire 路徑 | 必有型別／值 | 前端語意及轉換 | 證據／缺口 |
|---|---|---|---|
| body.outcome | string，`OK` / `EMPTY` / `DENIED` | DATA-08；分別對應 legacy DONE/NONE/BLOCK；TR-03/04/05 | E-02 + E-06 |
| body.rows | array；EMPTY/DENIED 時 `[]` | DATA-03；成功依回傳集合順序呈現，回應前先清舊列 | E-02 + E-06 |
| body.rows[].rowId | 必有 string | DATA-03 項目代碼→UI-06 第一欄；對應 itemKey | E-02 + E-06 |
| body.rows[].label | 必有 string | DATA-03 名稱→UI-06 第二欄；對應 itemText | E-02 + E-06 |

目標未定義 rankHint，不能補進 schema。UI-06 第三欄與 DATA-04 仍是已確認前端需求，[TODO-02](../../renovation/fixture-case/tracking.md#todo-02)；本機 legacy 形狀合成展示不證明目標提供該欄位。沒有其他已知未消費輸出。（E-02/06）

### 結果與 UI 反應

| HTTP／條件 | outcome／rows | 前端結果 | 證據／缺口 |
|---|---|---|---|
| 200，允許且有資料 | OK / 資料列 | TR-03/ST-ROWS，填資料，不再次清訊息 | E-02/06/07；TODO-02 |
| 200，允許且無符合資料 | EMPTY / [] | TR-04/ST-EMPTY，清列；MSG-01「沒有項目」 | E-02/06/07 |
| 200，不允許 | DENIED / [] | TR-05/ST-DENIED，清列；MSG-02「不允許查閱」 | E-02/06/07 |
| 未定義其他碼、非 200、transport／解析失敗 | 未定義 | 不創造錯誤訊息或 fallback；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) | E-04/06 |

前端原來對未知但可讀結果有「先清列、沒有其他更新」分支；它不是目標後端新結果碼。查閱前清狀態→傳遞 DATA-02→服務端以單位情境判定權限及結果→前端回應時清列及顯示；數量儲存與審閱者初始化未由此操作承接。（E-02/06/07）

## 2. 契約核對案例

本節是案例定義，沒有可呼叫環境，不表示已執行。

| 案例 | 前置／事件 | 權威預期 |
|---|---|---|
| API-AC-01 | fixture-v1 請求；依序省略 queryText、空字串、null、13 字元及 client unitId | 省略／空字串不指定關鍵字；null 不合法；最大 12；client unitId 不接受；拒絕的 HTTP／body 未定義，不能補造（E-06） |
| API-AC-02 | 服务端情境不允許、允許無項目、允許有兩列 | 分別 DENIED/[]、EMPTY/[]、OK/必有 rowId/label 的集合；outcome/rows 必有；排序提示不由此契約保證（E-06/07） |
| API-AC-03 | 前端輸入兩端空白及回傳已知 outcome | trim 及各 wire/semantic 映射如上；前端案例 AC-02/03/04/05/10 實際涵蓋呈現與時序，不代替 API wire 空值案例（E-02/06） |

## 3. 尚未形成可用契約

| 需求 | 缺口 | 移交／TODO |
|---|---|---|
| DATA-01/UI-02/FLOW-01 | 首次載入審閱者來源與合法承接 | [HANDOFF-01](backend-handoff.md#handoff-01)／[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) |
| DATA-04/UI-06/ST-ROWS/FLOW-02 | 排序提示尚未承接，型別亦未知 | 資料覆蓋差距，非新業務算法；[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) |
| DATA-05/06/07/FLOW-03/BOUND-03 | 數量提交、計費、受信任單位與儲存 | [HANDOFF-02](backend-handoff.md#handoff-02)／[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) |
| BOUND-01/DATA-08 | 認證、其他結果及傳輸失敗 | [TODO-04](../../renovation/fixture-case/tracking.md#todo-04) |

## Consumer Impact

唯一已確認消費端為 fixture-case。FLOW-02/BOUND-01 消費 DATA-02/03/08；排序提示 DATA-04 未覆蓋。FLOW-01/BOUND-02 及 FLOW-03/BOUND-03 尚無已取得操作；不新增端點。

## 相依消費端

本頁查閱動作 CMP-SEARCH-ACTION 觸發 FLOW-02；UI-06 消費代碼／名稱及仍缺少的排序提示，UI-05 消費結果語意。UI-02 消費審閱者初始化缺口；UI-07 觸發數量提交缺口。沒有提供其他頁消費證據。（E-01/02/03/08/09）
