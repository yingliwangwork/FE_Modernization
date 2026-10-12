# fixture-case：前端 API 消費規格

> v1 的消費投影，以指定後端快照為權威。只確認 searchItems；未部署、無可呼叫環境。精確傳輸限定於本文件。

| 項目 | 內容 |
| --- | --- |
| Scope／投影版本 | fixture-case／v1 |
| 前端契約 | [specification](../../design/fixture-case/specification.md) |
| 權威後端基準 | backend_root＝inputs/backend；api-contract.md fixture-v1，SHA-256 04215f381bc195b357b184c89d90e6f4fba521580feb7147c141a25cdb1ca802；business-rules.md fixture-v1，SHA-256 35e4253d281cacc662c065ed690337ae8a71f04233df8289c065828aba7614b7 |
| 來源性質／環境 | 沙盒測試的後端交付契約，非正式服務，沒有可呼叫環境（E-10）；不是已驗證 stub |
| 共通契約 | E-10～E-11 定義此操作的媒體、envelope；認證、非 200 例外未定義（TODO-04、TODO-05） |
| 追蹤與證據 | [tracking](../../renovation/fixture-case/tracking.md)；[移交](backend-handoff.md) |

## 1. 本輪需求與操作索引

| FLOW／BOUND | 所需能力 | API／缺口 | 原件識別 | 各端證據 |
| --- | --- | --- | --- | --- |
| FLOW-02／03、BOUND-02 | 修剪關鍵字查閱，依單位授權，資料或無項目／拒絕結果 | API-01 | fixture-v1 searchItems；原件 L7–26 | E-03、E-04、E-10～E-13 |
| FLOW-03／BOUND-02 | 每筆排序提示 | HANDOFF-03、TODO-02 | 原件 L27 明列未承接 | E-04、E-12 |
| FLOW-01／BOUND-01 | 審閱者初始化 | HANDOFF-01、TODO-01 | 原件 L27 明列未承接 | E-01、E-06、E-12 |
| FLOW-04／BOUND-03 | 數量解析、門檻計算、保存 | HANDOFF-02、TODO-03 | 原件 L27、業務責任 L6 未承接 | E-02、E-05、E-07、E-12、E-13 |

## 2. 已取得的 API 契約

### API-01：searchItems

#### 操作與傳輸

| 項目 | 原件定義 | 證據／缺口 |
| --- | --- | --- |
| operationId | `searchItems` | E-10 |
| Method／Path | `POST /v2/items/search`；相容路徑未定義，不能把 legacy URL 宣告為目標別名 | E-10、E-14 |
| Request／Response 媒體 | `application/json` | E-10 |
| Headers | 媒體型別已定義；其他必要 header 與認證傳輸尚未定義；不得假設 Bearer、cookie 或匿名 | E-10；TODO-04 |
| 受信任情境 | 業務單位由服務端情境提供；不接受 client `unitId` | E-10、E-13 |
| 性質／環境 | fixture-v1 沙盒測試交付契約，非正式且無可呼叫環境 | E-10 |
| 其他性質 | 排序、分頁、重送、取消、交易未定義；冪等、逾時亦未取得；前端多次按鈕不證明服務端重送保證 | E-03、E-13；TODO-05 |

#### 請求契約與前端來源映射

| 位置／wire 路徑 | 型別／格式 | 必填／空值 | 接受條件 | 前端來源 | 轉換與時機 | 兩端依據 |
| --- | --- | --- | --- | --- | --- | --- |
| body（整體） | object | 必須為契約所述 object；整體 body 缺省行為未定義 | 其他附加欄位的規則未定義；`unitId` 明確不接受 | FLOW-02 的查閱請求 | 在清空 UI-05 後組裝；無 client 單位資料 | E-03、E-10 |
| body.queryText | string，最大長度 12 | 選填；省略或 `""` 表示未指定關鍵字；`null` 不合法 | 最大長度檢核已定義；違反時 wire 錯誤回應未知 | DATA-03／UI-03，初始空字串；有合法來源 | 原有 `trim` 保留，未做其他正規化；空輸入可傳 `""`；沒有省略值的前端事件證據 | E-03、E-06、E-10、E-12 |
| 服務端情境（非 request 欄位） | 單位識別格式未知 | 查閱授權需要；不能 client 傳入 `unitId` | 依服務端情境判斷 | DATA-02，不是使用者輸入也不是舊 hidden 複製 | 取得機制未知；不填假 unitId 或 token | E-02、E-10、E-13；TODO-04 |

前端 `maxlength=12` 與後端最大長度各有證據；前端限制不代表服務端依此信任輸入。數量檢核不屬 API-01。

#### 回應契約與前端消費映射

| wire 路徑 | 型別／空值 | 原件語意 | 消費位置 | 轉換／反應 | 兩端依據 |
| --- | --- | --- | --- | --- | --- |
| HTTP 200 body | object | envelope 直接含 `outcome`、`rows`，無另定 `data` 包裝 | FLOW-03 | 接收已確認結果；不可新增 envelope | E-04、E-11、E-12 |
| body.outcome | 必有 string；允許 `OK`／`EMPTY`／`DENIED`；其他未定義 | 成功／無項目／不允許查閱 | TR-03／04／05 | 分別對應 legacy `DONE`／`NONE`／`BLOCK` 的原可見反應 | E-04、E-11、E-12 |
| body.rows | 必有 array | 項目集合；`EMPTY`／`DENIED` 時 `[]`；`OK` 列數下限未明定，不自創限制 | DATA-04／UI-09 | 先清空舊列，依集合列順序展示；不能當作服務端排序保證 | E-04、E-11、E-13 |
| body.rows[] | object | 每筆項目；只確認下列兩個必要欄位 | UI-09 | 顯示欄頭仍為三欄；第三欄缺口不能被補造 | E-04、E-11、E-12 |
| body.rows[].rowId | 必有 string；格式、空字串條件未知 | 項目代碼 | DATA-04／UI-06 | 原 `itemKey` 對應；直接純文字呈現，不改代碼 | E-04、E-11、E-12 |
| body.rows[].label | 必有 string；格式、空字串條件未知 | 名稱 | DATA-04／UI-07 | 原 `itemText` 對應；直接純文字呈現 | E-04、E-11、E-12 |

全部已知輸出皆有消費位置，沒有刻意省略的必要輸出。`rankHint` 不在目標 schema；既有 UI-08 的資料需求記在 HANDOFF-03，不能自行加入 `rows[].rankHint` 或改成「未消費」掩蓋缺口。未知缺省／null 不補默認值。

#### 結果判定與 UI 反應

| 情境／業務條件 | HTTP／業務碼 | 回傳資料／文案 | 前端反應 | 證據／缺口 |
| --- | --- | --- | --- | --- |
| 允許且有符合資料 | 200，`outcome="OK"` | `rows` 包含已定義兩欄；沒有契約訊息文字 | TR-03／ST-03；三欄 legacy呈現仍缺 DATA-05；不新增成功提示 | E-04、E-11～E-13；TODO-02 |
| 允許但無項目 | 200，`outcome="EMPTY"` | `rows=[]`；無後端訊息欄 | TR-04／ST-04；UI-05＝MSG-01「沒有項目」 | E-04、E-11～E-13 |
| 不允許查閱 | 200，`outcome="DENIED"` | `rows=[]`；無後端訊息欄 | TR-05／ST-05；UI-05＝MSG-02「不允許查閱」 | E-04、E-11～E-13 |
| 非 200、未知結果、無效／缺失欄位、連線／解析錯誤 | 未定義 | 不發明業務碼、envelope 或 fallback 文案 | 完整目標處理未知；legacy 其他碼的先清空列且無分支僅作已知片段 TR-06，不是目標新結果 | E-04、E-11、E-14；TODO-05 |

原件拒絕說明使用「查阅」，畫面固定訊息使用「查閱」；沒有後端訊息欄或直接文案顯示映射，故保留前端 MSG-02 原文。

#### 呼叫順序與責任界線

| FLOW／BOUND | 送出前 | 後端已承接 | 回應後 | 相依／中止 | 證據／缺口 |
| --- | --- | --- | --- | --- | --- |
| FLOW-02／BOUND-02 | 清空狀態→讀取並修剪關鍵字→交接；舊列仍保留 | 依服務端單位判斷权限；再決定有無項目，回傳已定義碼與兩欄列 | FLOW-03 清空舊列→依結果呈現 | 非成功結果仍可能 HTTP 200；必須判斷 outcome；身份取得、並發回應及失敗未知 | E-03、E-04、E-10～E-13；TODO-04、TODO-05 |

API-01 不承接 DATA-01、DATA-05、數量路徑或保存原子性。不能把多個未確認操作在前端串接成原有業務交易。

#### 契約核對案例索引

| 案例 | 需核對內容 | 前端預期 | 定義位置 | 證據 |
| --- | --- | --- | --- | --- |
| AC-02、AC-10 | `queryText` 名稱、trim、長度、選填、null、不接受 `unitId` | FLOW-02、DATA-03；畫面輸入保留 | 規格第 8 節 | E-03、E-10、E-12 |
| AC-03、AC-11 | 200 envelope、OK、rows 及兩欄必有 string | TR-03／ST-03；排序差距仍未完成 | 規格第 8 節 | E-04、E-11、E-12 |
| AC-04、AC-05、AC-11 | EMPTY／DENIED 與空集合 | MSG-01／MSG-02、ST-04／ST-05 | 規格第 8 節 | E-04、E-11～E-13 |
| AC-06、AC-12 | 其他結果及重複觸發未定義 | 不造新目標分支 | 規格第 8 節 | E-03、E-04、E-11、E-13 |

## 3. 尚未形成可用契約的需求

| BOUND／DATA | 已確認需求 | 缺少／差距 | 移交 | TODO |
| --- | --- | --- | --- | --- |
| BOUND-01／DATA-01 | 初始審閱者名稱 | 沒有目標操作或取得情境；缺失處理未知 | HANDOFF-01 | TODO-01 |
| BOUND-02／DATA-05 | 成功列第三欄排序提示 | 原件明確未承接；不補 wire 欄位 | HANDOFF-03 | TODO-02 |
| BOUND-03／DATA-06～DATA-09 | 整數解析、門檻計算、受信任單位保存 | 目標無數量操作；有效性、例外、交易等未取得 | HANDOFF-02 | TODO-03 |
| BOUND-02／DATA-02 | 服務端單位／認證 | 所需責任已定義，取得與傳輸未定義 | 情境來源 gap，非新增業務端點；與 HANDOFF-02 情境相依 | TODO-04 |
| BOUND-02 | 傳輸／解析／未知結果完整處理 | 沒有已確認錯誤 schema 或 fallback，不能發明 | 無證據的額外業務能力不生成 HANDOFF | TODO-05 |

只有 Markdown 原件；本輪不建立 OpenAPI、server、security scheme 或空 paths。此投影文件核對不代表可介接或已完成整體翻新。
