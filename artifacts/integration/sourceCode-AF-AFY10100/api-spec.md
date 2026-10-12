# sourceCode-AF-AFY10100：API 消費缺口索引

版本0.1；[前端規格](../../design/sourceCode-AF-AFY10100/specification.md)；[tracking](../../renovation/sourceCode-AF-AFY10100/tracking.md)。搜尋本工作區來源檔及後端候選檔名，未取得指定 backend_root、OpenAPI、Controller/Service 設計、方法規格或可呼叫環境。部署狀態未確認。沒有可雙端確認的 API 操作，因此不分配 API-ID、不新增端點／認證／envelope／schema／HTTP 結果碼；legacy 送出位置留在 tracking，不能當作目標 API 權威。

## 本輪消費需求與缺口

| FLOW／BOUND | 前端已知需求 | 目標後端基準 | 移交／局部缺口 |
| --- | --- | --- | --- |
| FLOW-02／BOUND-01 | 查詢當前表單；DATA-01–04／09–10 及當前具名稱欄位 | 未取得 | [HANDOFF-03](backend-handoff.md)；[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| FLOW-03／BOUND-02 | 識別值檢核；本次擷取 DATA-01→消費 DATA-11 | 未取得 | [HANDOFF-02](backend-handoff.md)；[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| FLOW-03／BOUND-03 | 取回公會資料；當前整份表單；與檢核識別值時間分離 | 未取得 | [HANDOFF-03](backend-handoff.md)；[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| FLOW-06／BOUND-04 | 修改選列資料；當前表單的選列識別、只讀值與編輯值 | 未取得 | [HANDOFF-04](backend-handoff.md)；[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| FLOW-07／BOUND-05 | 刪除選列資料；當前整份表單，後端如何解讀未確認 | 未取得 | [HANDOFF-04](backend-handoff.md)；[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| FLOW-08／BOUND-06 | 新視窗明細；點擊列的識別、保單、保障、人物及原始來源／通路代碼；不取編輯值 | 未取得 | [HANDOFF-05](backend-handoff.md)；[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |
| FLOW-01／BOUND-07 | 入口資料及情境；DATA-02–10 的外部提供資料与旗標 | 未取得 | [HANDOFF-01](backend-handoff.md)；[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04) |

## 共通與逐欄缺口

必要 header、媒體型別、認證與受信任旗標合法來源、傳輸位置／型別、缺省／null／空字串／空集合、共同 envelope、錯誤、結果碼、逾時、重送、交易原子性与授權全部未由目標權威提供。前端知道消費識別值檢核旗標 Y 分支；不能反向補造 wire schema。[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)

## 契約核對案例

AC-API-01：取得選定且同版本後端契約後，對照每個 BOUND 的所有輸入合法來源、初始化輸出、檢核旗標及異常、提交結果與前端 FLOW。未知結果以 TODO 保留，此案例尚無可驗收的完整後端預期。[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)

## BOUND-08 追加需求

条件政策下复制稽核与受信任功能/水印/字型情境数据需求来自E-16，详见[HANDOFF-06](backend-handoff.md#handoff-06)。尚無目標權威；[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)。legacy AJAX default method由前端库E-18可確認，但不能升格为目标后端传输契约。
