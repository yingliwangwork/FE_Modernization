# AF-AFY10400：前端 API 消費規格

| 項目 | 內容 |
| --- | --- |
| 投影版本 | 1.0，部分映射；不宣稱可直接介接 |
| 前端契約／追蹤 | [specification](../../design/AF-AFY10400/specification.md)、[tracking](../../renovation/AF-AFY10400/tracking.md) |
| 唯一交換權威 | backend_root=`inputs/backend`；`docs/OPENAPI.md`，更新日 2026-08-12；文件暂記 `0.0.1-SNAPSHOT`，OpenAPI 3.1.0；SHA-256 `13307ed1144946124179d6e02148999e64783e031d440aacc8ff54e03c32f1ef`；E-10 |
| 性質／環境 | 依現行 Controller／DTO／例外盤點的 Markdown 契約；預設 localhost:8080、Context Path `/`；Stub profile 預設啟用並帶 `X-AF-Stub: true`。未取得部署／正式驗證，不呼叫 server |
| 認證／headers | 未宣告 Security Scheme；Gateway／容器的認證授權及正式 server/base path/header 未定義（TODO-03）；不能宣告免認證 |

方法規格 E-11／12 僅輔助理解 legacy 處理與差距，不替換選定交換基準。不產生假的 OpenAPI YAML／JSON：本次原件僅 Markdown。

## 1. 消費範圍

| FLOW／BOUND | 能力 | 操作 | 前端／後端證據 |
| --- | --- | --- | --- |
| FLOW-04／05、BOUND-01 | 按 ID 與保單文字列產生匯出結果與檔名 | API-01 `afy10400DoExport` | E-04、05／E-10 §6.2 |
| FLOW-06、BOUND-02 | 下載上述檔案 | API-02 `afy10400DoDownload` | E-05、09／E-10 §6.3 |
| FLOW-01 | 顯示靜態選項、零列、入口訊息 | 沒有新增 prompt 消費；基準存在 `afy10400DoPrompt`，但根頁沒有呼叫或讀取其欄位 | E-01、02、06／E-10 §6.1 |

`POST /afy10400/prompt` 必須 `{}`，相容 `/afy10400/promp`，回 `insrDate` string 今日民國 `yyyMMdd`、`showEdit` string `N`、`showQuery` boolean false、`rtype` boolean false。這四欄於本頁未消費，不以 `rtype` 控制 L／R 選項；此列為排除理由，不是新增 API 投影。

## 2. 共通契約

E-10 §1～2：一般請求與回應 `application/json`；字串 JSON／UTF-8 Unicode。未被 DTO 驗證註解限制的欄位非必填；非必填不等於服務一定接受 null／空值。各欄未說明缺省值、null 與空集合業務結果時保留未知。

| wire 路徑 | 型別／必填 | 成功 | 已處理錯誤 | 本頁消費與限制 |
| --- | --- | --- | --- | --- |
| `code` | integer／是 | 固定 200 | 500 | 須同時判 HTTP 與業務碼；舊 helper 看 `ErrMsg.returnCode==0`，不可直接沿用（E-08，TODO-01） |
| `msg` | string／是 | export 為 `success` | 例外原因原文 | 語意資料已知，但新 envelope 對應原訊息區／阻斷提示與格式尚未確認（TODO-01／04）；不造固定錯誤句 |
| `data` | any 或 null／是 | API-01 payload | null | 舊 callback 取最外層 `rtnMap/fileName`；目標須對 `data` 解包，作為適配設計需求，未稱已實作 |

錯誤（輸入、查無、重複、模組、未預期及 Bean Validation）目前均 HTTP `200 OK`、body `code=500`、`msg` 原因、`data=null`。HTTP 200 不能證明成功。一般成功 envelope 使用 HTTP 成功回應；未列的傳輸失敗碼、重試策略、冪等、逾時、取消、交易原子性、排序、分頁不補預設；本頁沒有需求可推導其保證。下載成功例外於 envelope，見 API-02。

## 3. API-01：匯出

| 項目 | 原件定義／證據 |
| --- | --- |
| operationId | `afy10400DoExport`，E-10 §3 |
| Method／Path | `POST /afy10400/export`，無本操作相容路徑宣告，E-10 §6.2 |
| 媒體型別 | 必須 JSON object body，`application/json`；回 `application/json` envelope，E-10 §1、6.2 |
| headers／情境 | 共通認證限制；stub `X-AF-Stub: true`，不是正式能力證據 |
| schema | `AFY10400DoExportRequest`／`AFY10400DoExportResponse`；未列定長或 enum 限制，不以 legacy 方法驗證冒充 DTO 約束 |

### 請求與前端映射

| body 路徑 | 型別／必填 | 原件要求與未定義部分 | DATA／UI 來源與轉換 | 證據 |
| --- | --- | --- | --- | --- |
| `insrType` | string／否 | 收承方式，支援值依業務流程；缺省／null 行為未逐欄定義 | DATA-01／UI-04 選取值 L 或 R，直接傳值；不得擴成新選項 | E-01、04、E-10 |
| `prodType` | string／否 | 商品類型；未宣告 enum | DATA-02／UI-05 值 AT／BG／CB，直接傳值 | E-01、04、E-10 |
| `I_ID` | array<string>／否 | 與 POLICY_NO 平行、索引對應；空集合／null／元素 null 未定義為可成功 | DATA-03 列序中 DATA-04 原文。即使只有一列也須 array；無大小寫轉換、trim 或前端業務驗證 | E-03、04、15、E-10 |
| `POLICY_NO` | array<string>／否 | 同一索引對應同一 ID；每元素為原保單多行文字 | 依相同列序取得 DATA-05，保留各列與多行；legacy serialize 將 LF 正規化 CRLF（E-15），JSON 適配需保留此已證實交換語意，不展平成每張保單一列 | E-01、03、04、15、E-10 |

前端必填／重複阻擋 BR-01／02 與 DTO 非必填分開。零列 BR-03 不被前端阻擋；legacy 表單零列沒有 `I_ID/POLICY_NO` keys，目標採省略、null 或空陣列尚無等價確認，記 TODO-01，原型只停在已知邊界。原頁建立 `table1_I_ID/table1_POLICY_NOs` 本地陣列但未送出该物件；不能把它們變成目標 request keys（E-04、E-15）。

### 回應與映射

| wire 路徑 | 型別／語意 | 本頁消費／限制 | 證據 |
| --- | --- | --- | --- |
| `code`、`msg`、`data` | 完整共通 envelope | 見 §2；不是舊 `ErrMsg` | E-10／E-08 |
| `data.rtnMap` | object<string,string>；各被保險人匯出結果 | DATA-06／UI-10，按當前列 ID 取值；無固定鍵清單，未列缺鍵／null 規則，不補 schema。legacy 方法可能 `<br>` 串接訊息，舊頁解讀標記；目標原件要求文字節點，換行等價仍 TODO-01 | E-05、10、11 |
| `data.fileName` | string，生成 Excel 檔名 | DATA-07，接受分支供 API-02 使用；不自行重算檔名；不得在缺值时造檔名 | E-05、10 |

基準沒宣告 response payload 子欄的必填／null 條件，不將「頁面需要」改成後端必填保證。所有已知輸出均已列；此操作沒有未消費 payload 欄位。

| 情境 | HTTP／業務結果 | 回應 | 前端結果與差距 |
| --- | --- | --- | --- |
| 匯出成功 | HTTP 成功；`code=200`、`msg=success` | `data.rtnMap/fileName` | 可映射 TR-07：先更新每列結果後下載。沒有必要以每列 `已匯出` 全數判斷下載；舊頁接受分支就下載（E-05） |
| 業務／輸入錯誤 | HTTP 200、`code=500` | `msg` 原因、`data=null` | 舊 TR-08 預期 rtnMap；不能執行同一結果填入流程。HANDOFF-02／TODO-01；不模擬成功、空 map 或各列同一錯誤 |
| 檔案生成失敗、查無資料、類型錯誤、空白列 | 原件列為可能錯誤，採共通處理 | 精確逐種文案／保留部分結果未在所選契約列出 | 依已知碼核對，未知本頁結果保留 TODO；不以方法規格自造新 payload |
| 傳輸／未解析 JSON／未列碼 | 未定義結果 | 未知 | E-08 可證 legacy 無有效回應時的有限程序，但目標呈現無承接證據；TODO-07 |

呼叫順序：BR-01／02 → BOUND-01 → 接受分支更新 UI-10 → API-02。業務查詢與 Excel 生成均服务責任，原型不查詢、不計算、不寫檔。API 成功不是每張保單均查到的證據，方法規格 E-11 有部分保單未命中而仍生成檔案的語意；不新增「有任一缺件則不得下載」條件。

核對案例：AC-03～07 查前端限制與 request 來源／配對／換行；AC-08 查 envelope 解包、map 對照與順序；AC-09 查拒絕失配；實際結果見 tracking。

## 4. API-02：下載

| 項目 | 原件定義／證據 |
| --- | --- |
| operationId | `afy10400DoDownload`，E-10 §3 |
| Method／Path | `POST /afy10400/download`，E-10 §6.3 |
| Request media | `application/json` 或 `application/x-www-form-urlencoded`（含 `charset=UTF-8` 亦支援） |
| Response media | 成功 `application/octet-stream`；例外可能 JSON ReturnMsg，已寫部分 binary 的结果取決於容器／正式 adapter |
| Request schema | `AFY10400DoDownloadRequest` |
| headers／來源 | 共通認證限制；`Content-Disposition` 以下僅 stub adapter 已確認 |

| 精確輸入路徑 | 型別／必填／空值 | 前端合法來源 | 轉換與時機 |
| --- | --- | --- | --- |
| JSON body `fileName` 或 form 欄位 `fileName` | string／否；DTO 無 null／空白驗證，服務 null 行為未確認 | DATA-07，API-01 接受回應帶入，不可要求使用者任填檔案路徑 | 原文帶回；FLOW-05 結果先填入後 FLOW-06；E-05、10 |

| 成功輸出 | 原件值 | 消費／限制 |
| --- | --- | --- |
| HTTP status | 200 | 仍需識別檔案媒體，不因任何 200 都保存檔案 |
| `Content-Type` | `application/octet-stream` | binary string，`format: binary`，Excel 檔案，無 ReturnMsg；DATA-07 对應檔案（E-10） |
| `Content-Disposition` | `attachment; filename="{fileName}"` | stub adapter 的檔名；正式 adapter 全部 headers 尚未確認，TODO-02 |
| body | binary | 不能 JSON 解包；不期望 `downloadFileName/downloadFileFullPath` 欄位 |
| `X-AF-Stub` | true，預設 stub 情境 | 僅環境識別，非產品成功訊息 |

下載前例外嘗試全域 handler：HTTP 200、`code=500`、`msg` 原因、`data=null`；已寫部分 binary 例外無固定結果，不自造 JSON 或重試／回滾保證。舊 E-09 helper 先把 download 回應視為 legacy JSON，再取加密參數送到另一檔案服務；與目標直接 binary 不相容（TODO-02）。適配應保持可見下載交接且不另開業務視窗，具體实现與錯誤呈現仍未确认；本文件不變更後端到加密參數回應。

核對案例 AC-08、AC-14：檔名源自匯出、結果更新先於下載、兩種 request media、binary 與 JSON 錯誤分開；實際檔案、正式 headers、安全授權未驗證。

## 5. 需求缺口

| 前端需求 | 所選基準差距 | 移交／追蹤 |
| --- | --- | --- |
| 匯出配對陣列，零列與多行文字 | form → JSON 適配未確認，缺省／空值不明 | TODO-01（交換適配，不提新端點） |
| 拒絕逐列結果、原文換行與訊息位置 | `data=null`；文字節點與舊格式標記 | HANDOFF-02、TODO-01／04 |
| 檔案交接且不另開視窗 | legacy 加密 JSON → 第二服務，目標 binary | TODO-02；保留現有 API，未要求重建舊端點 |
| 功能保護旗標、身分、浮水印、複製稽核 | 不在兩操作與 prompt 共通契約中 | HANDOFF-01、TODO-03 |
| 入口訊息／外層訊息板／回滾標記 | 目標 msg 无舊七欄訊息集合或外層提供機制 | HANDOFF-03、TODO-04 |
