# AF-AFY10400：前端 API 消費規格

| 項目 | 內容 |
| --- | --- |
| Scope／投影版本 | AF-AFY10400／1.0，部分投影；不得當作已完成介接 |
| 連結 | [前端規格](../../design/AF-AFY10400/specification.md)、[tracking](../../renovation/AF-AFY10400/tracking.md)、[handoff](backend-handoff.md) |
| backend_root／唯一選定基準 | `inputs/backend`；`docs/OPENAPI.md`，2026-08-12、OpenAPI 3.1.0、暫記 API 版本 `0.0.1-SNAPSHOT` |
| 基準 SHA-256 | `13307ed1144946124179d6e02148999e64783e031d440aacc8ff54e03c32f1ef`（E-010B、E-011） |
| 性質／環境 | 文件自述為目前 Controller／DTO／例外盤點；非本次執行觀察。預設 Server `http://localhost:8080`，Context Path `/`；stub 預設啟用並附 `X-AF-Stub: true`。沒有本輪可呼叫環境，部署狀態未確認 |
| 認證與 headers | 應用碼未宣告 Security Scheme，不能推論無認證。Gateway／容器認證、正式 Server、base path、授權 header 未確認（TODO-001） |

## 1. 需求與操作索引

| 前端需求 | API | 原 operationId／順序 | 各端證據 |
| --- | --- | --- | --- |
| 初始化能力比對 | API-001 | `afy10400DoPrompt`；本 JSP 未呼叫且不消費四個輸出，僅記錄與初始化移交的覆蓋差距 | E-001、005、011、012P |
| FLOW-004／BOUND-001 匯出 | API-002 | `afy10400DoExport`，檢查後呼叫 | E-003、011 |
| FLOW-005／BOUND-002 下載 | API-003 | `afy10400DoDownload`，成功回填后，使用 API-002 的 fileName | E-003、008、011 |

API-001 有已確認的服務能力，但不是由本頁名稱推導出的必需新增呼叫。原入口底部訊息、可信設定等不因 prompt 存在而視為已承接。

## 2. 共通傳輸與結果（適用下述全部操作）

一般請求及回應為 `application/json`、JSON/UTF-8；完整必填封套：`code: integer`、`msg: string`、`data: any|null`。成功 `code=200`、本 scope 三個一般成功訊息為 `success`；匯出／prompt 的 data 為下列 schema。除下載外不得把 payload 誤當頂層資料。（E-010B、E-011）

已列輸入錯誤、查無資料、資料重複、模組錯誤、未預期錯誤及 Bean Validation 錯誤：HTTP `200 OK`，`code=500`、`msg` 為錯誤原文、`data=null`。必須同時判斷 HTTP 狀態與業務碼；不得沿用舊 `ErrMsg.returnCode=0` 或只看 HTTP200。其他傳輸狀態未列具體 UI 效果，不編造通用成功／失敗需求。（E-010B；TODO-002、006）

重送、冪等、業務取消、逾時、回滾及跨呼叫原子性均未由基準給保證。舊遮罩是 UI 操作限制，不能代表上述服務保證。JSON 的 `null`、省略、空字串、空陣列的全面差異未定義，不以 DTO “非必填”表示每種輸入皆會業務成功。（E-003、007、010B、011；TODO-006）

### API-001：已取得的初始化能力（本頁未消費）

- 操作：`afy10400DoPrompt`，`POST /afy10400/prompt`；相容 `POST /afy10400/promp` 同契約，新呼叫優先 `/prompt`。
- 請求 body 必須 `{}`，schema 名 `AFY10400DoPromptRequest`，媒體／認證依共通規則。
- 成功 data schema `AFY10400DoPromptResponse`：`insrDate:string` 今日民國年 `yyyMMdd`；`showEdit:string` 固定 `N`；`showQuery:boolean` 固定 `false`；`rtype:boolean` 固定 `false`，精確全小寫，不能写 `isRType`。
- 全部四輸出在本 JSP 無讀取處，故不新增 DATA／UI，不映射日期欄、顯示查詢區或編輯按鈕。存在操作不能證明承接 CMP-001 或 CMP-004。
- 結果：HTTP／封套依共通；本頁無既有結果消費流程，後续初始化接入順序及拒絕反應 TODO-001、004。
- 性質：盤點契約與預設 stub，未執行、部署未確認；欄位級 null 規則未知。

證據：E-001、005、010B、011、012P。案例 AC-001 與初始化差距核對；不將呼叫 API-001 當作 AC-001 成功條件。

### API-002：匯出

| 項目 | 基準定義 | 證據 |
| --- | --- | --- |
| operationId／Method／Path | `afy10400DoExport`／`POST`／`/afy10400/export` | E-011 |
| Request／Response schema | `AFY10400DoExportRequest`／`AFY10400DoExportResponse` | E-011 |
| 請求／回應／環境 | JSON object 必須存在；一般 JSON 封套；認證、預設 stub 依共通 | E-010B、011 |
| 相依及副作用 | 前端確認資料後交由服务產生 Excel，取得 fileName 才能下載；實際稽核／查詢／檔案副作用的承接完整性未由 HTTP 文件證實 | E-003、011、012；TODO-004 |

| body wire | 型別／必填 | 前端合法來源／轉換 | 已知限制／未知 | 各端證據 |
| --- | --- | --- | --- | --- |
| `insrType` | string／否 | DATA-001，UI-004 当前值 L／R，匯出時傳送 | UI 值不是目標 wire 的完整 enum；服務按業務流程判定，長度／nullable 未定義 | E-005、011 |
| `prodType` | string／否 | DATA-002，UI-005 当前值 AT／BG／CB | 同上，不擴張成 API 完整 enum | E-005、011 |
| `I_ID` | array<string>／否 | DATA-003 每列 DATA-004，由 DOM 列順序收集，不 trim／大小寫轉換 | 與 POLICY_NO 必須索引相對應；空／null／省略及零列受理未知 | E-003、011、013 |
| `POLICY_NO` | array<string>／否 | 每列 DATA-005 一整段多行文字，不把單一 ID 拆成多列 | 舊傳送將 LF／CRLF 一律正規化為 CRLF，目標 JSON 的等價傳入轉換需保持 CRLF 才能重現已知舊服務分割；目標服務是否採相同語意仍 TODO-008 | E-003、011、012、013 |

原本建立的 `table1_I_ID`、`table1_POLICY_NOs` 暫存參數沒有傳出，真正送出的是 `Form.serialize('frm')` 產生的 `insrType`、`prodType`、重複名稱 `I_ID`／`POLICY_NO`。目標不接受暫存參數名，不把各 ID 映射成新自訂 wire 欄位。零列時舊表單只有兩個選單，目標應省略陣列或給空陣列尚未裁決；不能默默宣稱空陣列等價。（E-003、013；TODO-006）

| response wire | 型別／值 | 前端消费与转换 | 证据／缺口 |
| --- | --- | --- | --- |
| `code` | integer，200／500，必填 | 成功／拒绝判定来源为此碼，非旧0码 | E-010B、011 |
| `msg` | string，必填；成功 `success`，錯誤原文 | DATA-008 所需描述；旧编号／程式ID／异常／底部回退等缺独立资料，完整 CMP 映射未知 | E-006、007、010B；TODO-001、002 |
| `data` | success object／error null，必填 | 成功读取下列字段；错误無可回填 data | E-010B、011；TODO-002 |
| `data.rtnMap` | object<string,string> | DATA-006，按当前 ID key→UI-011，先全部回填再下载；字段级必填／缺键／null 行为未定義 | E-003、011；TODO-006 |
| `data.fileName` | string | DATA-007→API-003 body.fileName，原样带入，非用户输入、非日期算法 | E-003、011 |

結果與前端分支：

- HTTP200＋code200＋已知成功 payload：TR-007／ST-005，先回填再下載。訊息 `success` 是後端原文，不译为自行创建的「匯出成功」。完整共用消息模式需要 TODO-001 裁决。
- HTTP200＋code500＋data null：TR-010／ST-007 说明与旧 TR-008 的差距，HANDOFF-001。不能存取 null.rtnMap，不能以成功 map 或空 map 假装旧逐列拒绝已承接。本文沒有指定新的错误清空／保留／重试產品规则。
- HTTP 状态失败、缺 map／缺键等：TODO-006。旧共用 raw response 路径仅支持提示提取，不证明本页能完成回填。

核对 AC-003～010、017；实际结果见 tracking。產檔、安全日誌、資料查詢由后端承担，不在 prototype 运算。（E-003、007、011、012）

### API-003：下載

| 項目 | 基準定義 | 映射／證據 |
| --- | --- | --- |
| operationId／method／path | `afy10400DoDownload`／POST／`/afy10400/download` | E-011 |
| Request schema／body field | `AFY10400DoDownloadRequest`；`fileName:string` 非必填，DTO 無 null／空白驗證 | 成功 API-002 回應 DATA-007 唯一合法來源；E-003、011 |
| Request Content-Type | `application/json` 或 `application/x-www-form-urlencoded`，後者含 `charset=UTF-8` 亦支援 | JSON `{"fileName":"DEMO.xlsx"}` 或 form `fileName=DEMO.xlsx`（合成值，非檔名規則） |
| 成功 | HTTP200；`Content-Type: application/octet-stream`；body binary string（format binary）；不使用 ReturnMsg | BOUND-002 下載交接；不作 JSON 解讀 |
| Content-Disposition | `attachment; filename="{fileName}"`，此 header 的證據僅為 stub adapter | 正式 adapter headers TODO-003 |
| 寫入前例外 | 嘗試交共通全域 handler 回傳 ReturnMsg（code500、msg 原文、data null、HTTP200） | 不把 JSON 錯誤存成 XLSX；可见 UI 映射待确认 |
| 已寫部分 binary 後例外 | 取決於 Servlet 容器及正式 adapter，未定義確定結果 | TODO-003、006 |

以上媒体／錯誤／header 來源 E-010B、E-011。相依順序為 API-002 成功→UI-011 回填→API-003；舊傳遞 `isOpenNewBrowse=false`，禁止原型新增新視窗。舊下載先取加密的 `downloadFileName`／`downloadFileFullPath` 再轉 FileDownload，目標直接回二進位；不能要求目標提供不存在於基準的舊 fields。相容 adapter 或等價下載体验需要 HANDOFF-002，不另发明服务端点。（E-003、008、011）

核对 AC-008、018；无本轮真实下載或文件检验。下载取消／重送／冪等未知；UI 的遮罩不代表服务端回滚。（TODO-003、006）

## 3. 尚未形成可用契約的需求

| 前端需求 | 已知差距 | 移交／TODO |
| --- | --- | --- |
| DATA-006／TR-008 拒绝逐列反馈 | 目标 data=null；旧回调仍读取 rtnMap；不能以旧方法文件覆写选定 HTTP 基准 | HANDOFF-001／TODO-002 |
| BOUND-002 同视窗檔案交接 | 旧加密信息链与目标 binary 不同，正式 adapter 不完整 | HANDOFF-002／TODO-003 |
| BOUND-003 入口與宿主訊息 | prompt 不带完整消息集合、异常／编号／回退 flag | HANDOFF-003／TODO-001、004、005 |
| BOUND-004 受信任配置与稽核 | 无本 scope HTTP 承接證据，不表示服务不存在 | HANDOFF-003／TODO-004 |
| DATA-005 多行输入、DATA-003 零列 | 保持原条件、停止边界核对，不新增产品验证 | TODO-006、008 |

本文件仅转写 Markdown 基准，没有生成伪 OpenAPI YAML，也没有调用任何接口。
