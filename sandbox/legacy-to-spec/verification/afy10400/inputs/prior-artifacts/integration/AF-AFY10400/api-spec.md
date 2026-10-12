# AF-AFY10400：前端 API 消費規格

投影v1；權威是 `inputs/backend/docs/OPENAPI.md`，2026-08-12，0.0.1-SNAPSHOT，SHA-256 `13307ed1144946124179d6e02148999e64783e031d440aacc8ff54e03c32f1ef`，backend_root=`inputs/backend`；E-12。文件宣告依目前Controller/DTO/例外盤點，含預設stub profile；部署狀態未確認，本案例未提供可呼叫環境且禁止真實呼叫。方法語意文件E-13/14/15不能取代指定wire權威。[前端規格](../../design/AF-AFY10400/specification.md)；[追蹤](../../renovation/AF-AFY10400/tracking.md)；[移交](backend-handoff.md)。本投影不是已完成相容實作。

## 共通契約（E-12 §1–3、§10）

- 全部已列操作POST；一般Content-Type/response `application/json`、UTF-8 Unicode文字。開發預設server `http://localhost:8080`、context `/`；正式server/gateway未知 [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)，不呼叫此地址。
- 程式未宣告Security Scheme；部署Gateway/容器認證需補充，不能宣告無認證或自行發明token。預設stub回應header `X-AF-Stub: true`；不證明正式adapter同樣輸出。
- 除檔案成功，完整envelope：`code` integer 必填，成功固定200；`msg` string 必填，操作預設`success`；`data` 任意型別/null，必填，成功各操作payload。
- GlobalExceptionHandler輸入錯誤、查無資料、資料重複、模組及未預期錯誤（Bean Validation亦落入此handler）：HTTP `200 OK`，`code:500`、`msg:錯誤原因`、`data:null`。HTTP200不代表業務成功；不能沿用legacy ErrMsg.returnCode=0。HTTP非200/body異常的產品呈現未知，不添加常見預設錯誤。
- 未被DTO註解限制即非必填；不是所有null/空字串都被承認業務合法，缺省與null/空集合完整差異未明定。[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)。重送、冪等、逾時、取消、交易原子性、檔案保留期限均未宣告。
- 大小寫/底線精確保留；只知object<string,string>的任意key，不補固定ID欄位。API規則文字節點呈現不使用未消毒innerHTML；原頁結果以HTML解釋（可含`<br>`）有差距 [TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)。

## 操作索引

| 前端 | 消費操作 | 依據 |
|---|---|---|
| FLOW-04/BOUND-01 | API-01 `afy10400DoExport` | E-03→E-12 §3/6.2 |
| FLOW-05/BOUND-02 | API-02 `afy10400DoDownload` | E-03/11→E-12 §3/6.3 |
| FLOW-01 | 已存在prompt能力，根入口未讀取回應欄位，未形成新增UI消費流程 | E-01/04/12/15；見下方未消費能力 |

## API-01：afy10400DoExport

POST `/afy10400/export`；Request JSON object必須存在，`application/json`；response `application/json` ReturnMsg<AFY10400DoExportResponse>。沒有本操作相容路徑證據。必要header為媒體型別；其餘身分來源尚未確認（TODO-05）。契約性質同共通規則；檔案產生副作用由服務負責，原型不重製。E-12 §6.2。

| body精確欄位 | 型別／必填 | 來源與轉換 | 接受條件／缺口 |
|---|---|---|---|
| `insrType` | string／否 | DATA-01/UI-04的目前代碼 | UI已知L/R不擴張成完整service enum，原件說依業務判定；E-04+12 |
| `prodType` | string／否 | DATA-02/UI-05的目前代碼 | UIAT/BG/CB；完整後端enum/長度/pattern未知；E-04+12 |
| `I_ID` | array<string>／否 | DATA-03順序取每列DATA-04，不以临时table1_I_ID名稱傳輸 | 與POLICY_NO平行索引；前端BR-01保留，服務端合法空值/陣列一致性處理仍須確認；E-03+12 |
| `POLICY_NO` | array<string>／否 | 同列DATA-05整段多行文字；每個元素对应同索引I_ID；不把每行保單展平成全陣列 | legacy serialize把LF變CRLF（E-09），方法語意按CRLF分割（E-13），選定wire未定義換行；需要確認JSON映射接受CRLF，TODO-05；不宣稱純LF已支持 |

上述值合法來源全部来自可見欄位。0列時原form傳輸只有分類、無I_ID/POLICY_NO；目標要省略或空集合未裁決，不擅自湊預設。單列legacy重名序列化與JSONarray需明確對映，不能直接原helper到新端點。

| response精確wire路徑 | 型別／值 | 消費位置／反應 | 各端證據 |
|---|---|---|---|
| `code` | integer必填，200成功/500錯誤 | 接替legacy業務成功判定；與HTTP一起判斷，須已確認相容策略 | E-08+12，TODO-03 |
| `msg` | string必填，成功`success`，錯誤原文 | MSG-05需要共用訊息分支映射；原ErrMsg前綴及code不同，不能自行套用 | E-08+12，TODO-02/03 |
| `data` | payload成功／null錯誤，必填 | 成功需先解包才能消费，不再把rtnMap/fileName当頂層 | E-03+12 |
| `data.rtnMap` | object<string,string> | DATA-06，依當前ID更新UI-09，先所有列再下载 | E-03+12；missing key、null/HTML文字差距TODO-03 |
| `data.fileName` | string | DATA-07传API-02；無已知固定pattern於此wire原件 | E-03+12 |

成功：envelope code200/msg`success`，按FLOW-04回填然后API-02。例外：HTTP200/code500/data null；原來源failureAction依赖rtnMap，選定wire沒有該欄位，不能執行原逐列回填，也不能假造全部错误/清空。E-03+12，[HANDOFF-03](backend-handoff.md#handoff-03)、[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)。可能業務錯誤類型：空白列、查無資料、收承方式錯誤、商品屬性錯誤、Excel產生失敗；原件未给所有精確原文及觸發規則，不合成通用文案。方法規格給legacy「已匯出」等語意不能证明选定版本每個文字與副作用承接。

順序：BR-01→export→全列回填→download→共用complete訊息（E-03/08/09）。輸入前端上限10字与不得空是UI檢核，不能改此API非必填声明。服务端查詢、檔案與稽核责任见E-13，但其實作覆盖／日誌原子性未由OPENAPI保證。

核對案例：AC-05必須驗證array顺序/大小寫/CRLF/解包/回填先下載；AC-06驗證data=null差距；AC-13驗證零列與短ID的前端行为，不假定服务成功。實測結果见tracking。

## API-02：afy10400DoDownload

POST `/afy10400/download`；`AFY10400DoDownloadRequest`。request接受 `application/json` 或 `application/x-www-form-urlencoded`（含`charset=UTF-8`）。E-12 §6.3。

| 位置／欄位 | 型別／必填／空值 | 来源／傳入時機 | 證據 |
|---|---|---|---|
| JSON body `fileName` 或form同名`fileName` | string／否；DTO尚無null/空白驗證 | API-01.data.fileName→DATA-07；成功回填後交付，不由前端編造路徑 | E-03+12 |

成功HTTP200；Content-Type `application/octet-stream`；Content-Disposition `attachment; filename="{fileName}"` **仅stub adapter确认**；body binary string (`format:binary`)，Excel；成功沒有ReturnMsg JSON。回應落地與所有正式headers未知。預先發生例外嘗試由全域handler 回ReturnMsg（共通HTTP200/code500/msg/data:null）；部分binary已寫時实际回應由容器/正式adapter而異，不能一律當完整JSON或重試。E-12。

前端結果映射：檔案内容交给下载接收者、不得给CSRUtil evalJSON；保留不開新視窗意圖，但原helper期望同步JSON `downloadFileName`/`downloadFileFullPath`，再FileDownload提交；目標binary無这些欄位，不能把helper原封不動复用，也不添加它们進schema。[HANDOFF-04](backend-handoff.md#handoff-04)、[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)。標準下載方式需相容承接決策，文件投影非已完成前端改写。身分/正式环境、保留/冪等/重送/取消保证未知，TODO-05。

核對案例AC-12：两種媒體、fileName大小寫、octet-stream/附件、無JSON成功、例外前/部分輸出各自確認；根流程AC-05只能在API-01成功後觸發。实际未進行服務呼叫。

## 已存在但未消費的初始化能力

E-12 §3/6.1：operationId `afy10400DoPrompt`，POST `/afy10400/prompt`；相容POST `/afy10400/promp`回應相同、新程式優先標準path。request必须JSON `{}`。success ReturnMsg code200/msg`success`，data `AFY10400DoPromptResponse`完整已知欄位：`insrDate` string，今日民國`yyyMMdd`；`showEdit` string固定`N`；`showQuery` boolean固定false；`rtype` boolean固定false（全小寫，非`isRType`）。错误同共通規則。四欄在本根入口都未消费；不新增日期、查詢區、編輯鈕或依rtype更動收承方式。E-01/04+12/15；此记录揭露基準能力，非本頁新API觸發需求。

## 未形成可用映射的需求

| 需求 | 差距／承接 | TODO |
|---|---|---|
| BOUND-04可信環境/政策／浮水印 | OPENAPI本scope未定義這些；HANDOFF-01，不能从prompt四字段猜測 | TODO-01/04 |
| BOUND-03 copy稽核 | 未取得對應目標承接；HANDOFF-02，不發明operation | TODO-01 |
| BOUND-01错误回填/訊息格式 | data=null及text node与原markup差異；HANDOFF-03 | TODO-03 |
| BOUND-02 JSON下載資訊→檔案 | target binary与legacy helper差異；HANDOFF-04 | TODO-03 |
| UI到JSON换行、0列、部署/授权 | 原件不足，无自造headers/defaults，先取得契約再验证 | TODO-05 |
