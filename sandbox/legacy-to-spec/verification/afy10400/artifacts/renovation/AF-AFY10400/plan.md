# AF-AFY10400：翻新計劃

## 初始邊界與順序

- 唯一入口：`inputs/frontend/sourceCode/AF/AFY10400.jsp`；manifest SHA-256 `fbf8f94aee2f03f830f5092ba280dca6f6707ce45d54a929e6ec7cecd4284b1a`。
- 建立於 2026-10-12，已讀 task、manifest 與工作方法，尚未讀根入口或分析來源依賴。這是實際事前建立紀錄。
- 初始納入：根入口可觀察畫面、互動、生命週期、交換與必要共用呈現。依賴待盤點。
- 排除：其他入口完整翻新、backend 修改、legacy 執行、網路／外部查詢、正式範圍擴張。
- 唯一後端基準：`inputs/backend/docs/OPENAPI.md`，backend_root=`inputs/backend`，只消費快照。
- 順序：TASK-01 依賴盤點及契約查找 → TASK-02 必要可用依賴契約 → TASK-03 入口規格／視覺 → TASK-04 API／移交 → TASK-05 驗證／追蹤。

## 初始任務

| ID | 範圍 | 依賴 | 影響 | 完成條件／驗證 | 狀態 |
|---|---|---|---|---|---|
| TASK-01 | 根入口依賴盤點；查 inputs/specs 及提供的既有契約 | manifest、根來源 | 根畫面與交換 | 每项依賴有查找結果、停止邊界、決策 | 待辦 |
| TASK-02 | 先轉必要且可取得依賴；未知依賴延後 | TASK-01、DEC-01 | 共用呈現、初始化、驗證與回饋 | 有來源支持的共用契約及位置 TODO | 待盤點 |
| TASK-03 | 系統中立規格與離線 HTML 原型 | TASK-02 | 根入口 UI／FLOW／BR／ST | 可見元素及分支覆蓋；文字原型一致 | 待辦 |
| TASK-04 | 消費基準與未承接責任移交 | TASK-01、後端快照 | 邊界與 API | 精確投影、衝突未擅自裁決 | 待辦 |
| TASK-05 | 靜態與可行互動驗證、追蹤 | TASK-03、TASK-04 | 成果全部 | 記錄實際結果與限制，不把產檔當完整 | 待辦 |

## 決策

| ID | 來源 | 選擇及授權 | 後續 |
|---|---|---|---|
| DEC-01 | task.txt 明示 sandbox-only simulated user decision | 重用適用契約；先轉必要可用依賴；不可取得依賴延後 TODO。僅本 sandbox，未授權正式 scope expansion | TASK-01 後逐項套用 |

依賴與計劃變更将在分析後增補。[執行追蹤](tracking.md)；[系統規格](../../design/AF-AFY10400/specification.md)。

## 依賴盤點與決策增補（CHANGE-01）

查找範圍為本案例 `inputs/specs/`（目錄未提供）、manifest、提供的 backend 文件；未找到前端共用契約。這不代表全系統沒有規格。後端 OPENAPI §1–3、§6 適用其已明定操作；方法規格只作 legacy 業務語意證據，不能覆蓋 wire 契約。

| DEP | 資源 | 引入／停止邊界 | 結果／影響 | 決策／引用／後續 |
|---|---|---|---|---|
| DEP-01 | CM/header.jsp | include；只分析本頁情境、PD 控制、copy 與浮水印 | 可取得，未找到既有契約；FLOW-01/06/07、CMP-01 | DEC-01 先轉必要片段；[support §CMP-01](../../design/AF-AFY10400-support/contract.md#cmp-01)；底層情境 TODO-01 |
| DEP-02 | CM/msgDisplayer.jsp | include；入口訊息、rollback、按鈕清底欄 | 可取得，未找到既有契約；FLOW-01/08、CMP-02 | DEC-01 先轉；[support §CMP-02](../../design/AF-AFY10400-support/contract.md#cmp-02)；缺底欄／WIUtil TODO-02 |
| DEP-03 | CM/js/ajax/CSRUtil.js | post、success、responder、MsgWin、底欄；不轉其他工具 | 可取得，未找到既有契約；FLOW-04/05/09、CMP-03/04 | 先轉；[support §CMP-03](../../design/AF-AFY10400-support/contract.md#cmp-03)；系統選用條件 TODO-02 |
| DEP-04 | CM/js/ajax/prototype.js | 1.7.3；值取得、form serialize、response 順序 | 可取得；字串 CRLF 正規化與 callback 先於 complete | 先轉必要交換支援；[support §CMP-05](../../design/AF-AFY10400-support/contract.md#cmp-05) |
| DEP-05 | CM/js/RPTUtil.js | downloadFile → ajaxRequest → download → getForm；停止於 FileDownload | 可取得；FLOW-05/BOUND-02 | 先轉 [support §CMP-06](../../design/AF-AFY10400-support/contract.md#cmp-06)；不具下載 adapter，TODO-03 |
| DEP-06 | CM/css/cm.css | 本頁用到的字體、class；不轉整個樣式庫 | 可取得；SCR-01/UI-01–10 | 先轉 [support §CMP-07](../../design/AF-AFY10400-support/contract.md#cmp-07)；缺圖 TODO-04 |
| DEP-07 | HotKey.js、PageUI.js、Validator.js、calendar.js、date.js | 引入盤點；本頁無 addHotKey／validation／calendar/date 的直接呼叫 | 可取得；未確認的通用能力不變成本頁功能 | HotKey 空綁定，無專用快捷鍵；其餘排除未呼叫功能；版本見 tracking source-inventory.json |
| DEP-08 | CXL tag、utility、ConfigManager、ZZ_Z0Z001、UserObject、FieldOptionList | header 間接依賴；追查受信任資料及外部副作用 | 快照未提供實作；FLOW-01/06/07、HANDOFF-01/02 | DEC-01 延後 TODO-01；TASK-06 |
| DEP-09 | watermark-js-plus.js、EUDC 字體、CM 圖像、WIUtil/jQuery、bottomFrame | 可見樣式、訊息與親頁；停止於未取得資源 | 不可取得；CMP-01/02/03、UI-01/02/10 | DEC-01 延後 TODO-02/04；TASK-07 |
| DEP-10 | inputs/backend/docs/OPENAPI.md 0.0.1-SNAPSHOT / 2026-08-12 | §1–3/6/10；消費本頁相關操作 | 適用契約；API-01/02；prompt 僅列未消費能力 | 直接引用 E-12，wire 不被方法規格取代；TODO-03/05 |
| DEP-11 | backend/docs/specs/AFY1_0400 的三份方法規格 | legacy export/prompt/download 语意；只採本頁相關責任 | 部分適用，並非目標 HTTP 權威 | 重用 E-13/14/15 支持意圖及差距；HANDOFF-03/04 |

所有版本以 tracking 的 [source inventory](source-inventory.json) SHA-256 鎖定。必要可用依賴契約先於根 specification 產生，版本 support-v1；不是另一 JSP 全入口翻新。

## 後續任務

| ID | 範圍／所需資料 | 依賴 | 影響 | 完成條件與重新驗證 | 狀態 |
|---|---|---|---|---|---|
| TASK-06 | 取得功能政策與受信任環境／copy 稽核承接資料，先對照再更新 HANDOFF | DEP-08、DEC-01 | FLOW-01/06/07、BOUND-03/04 | 合法情境來源、copy 日誌承接證據；重驗 AC-08/09 | 延後 TODO-01 |
| TASK-07 | 取得訊息 host/底欄/WIUtil 與浮水印／圖片字體 | DEP-09、DEC-01 | CMP/UI/FLOW-08/09 | 定义缺失部分，再補原型與 AC-07/10/11 | 延後 TODO-02/04 |
| TASK-08 | 核准錯誤回填與 binary 下載對映；確認 CRLF | E-12/13/14、DEC-01 | API-01/02、FLOW-04/05 | 兩端相容承接與整合案例 AC-05/06/12 | 延後 TODO-03/05 |
| TASK-09 | 瀏覽器原型與已提供情境驗證；取得 legacy 畫面後才比較 | TASK-03/04、可用本機瀏覽器 | 視覺/keyboard/drag/timer | 截圖、console、事件範圍與中間態證據 | TODO-06 |

TASK-01 完成快照內盤點；TASK-02 完成可用片段，未知延後；TASK-03/04 完成部分契約；TASK-05 執行靜態檢查，結果見 tracking。DEC-01 套用 sandbox 模擬決策，未另請正式授權。

## Review 續作計劃（CHANGE-02／2026-10-12）

此段先於本輪原始來源核對／修補寫入；續用既有 ID、E 與 task.txt 的 DEC-01，不將舊交付的歷史順序宣告視為本輪獨立證明。只編輯 artifacts；immutable prior delivery 與 review 為核對輸入，未知依賴維持延後。

| ID | 範圍／依賴 | 影響 | 完成條件／重新驗證 | 狀態 |
|---|---|---|---|---|
| TASK-10 | AF-SR-01–06 review；原始快照及 prior delivery | inventory、CMP-03/04/07、FLOW-04/09、TR/MSG/AC、API、原型 | 逐項 strict bytes／原始行核對，確認缺陷才修補；保留既有行为與開啟 TODO | Complete; confirmed defects repaired |
| TASK-11 | TASK-10；本機靜態與 prototype harness | 全部本輪修補 | hash/encoding/byte-line、local gap links、語法、訊息邊界及診斷生命週期檢查；記錄實際限制 | Static/mock complete; external checks remain open |

TASK-06–09 與 TODO-01–06 不因本輪修補關閉；不執行 legacy/backend/network，不讀評估套件。

## Browser 回饋續作計劃（CHANGE-03）

TASK-12：以本案例 reports/browser-before-event-fix.json 的Chromium 151.0.7922.34實測失敗為依據，修補審閱回應注入的事件順序。影響SCR-01/AC-07/10及原型harness；先保留原失敗報告，再改合成回應的交付任務邊界、重跑本機檢查，交主代理重跑瀏覽器。原根事件契約及全部TODO不變；只寫artifacts。Status: fix and local checks complete; awaiting actual Chromium rerun.

## 訊息窗按鍵續作（CHANGE-04）

TASK-13：CSRUtil:1609–1632原始嚴格解碼確認每次show有local handler並移除自身；修正SCR-01使用外層可變handler的閉包缺陷。影響CMP-04/TR-10/AC-10；新增滑鼠確認→重開→字母→Esc的handler及可見狀態回歸，保留next-task回應修補。只寫artifacts；完成条件為本機回歸／語法／連結通過，真實瀏覽器另交主代理。Status: local fix/checks complete; actual Chromium sequence pending.

## 審閱層遮擋續作（CHANGE-05）

TASK-14：主代理reports/browser-before-review-layer-fix.json確認19/20原生Chromium情境PASS，訊息窗滑鼠確認被review-content攔截。源CSRUtil:210/221遮罩150、1441訊息窗999已嚴格解碼核對；僅降低人工review層至其間，保留產品layers及next-task回應。影響SCR-01審閱CSS/AC-10可操作性，靜態檢查層級關係，主代理重跑原生點按；不force-click、不呼叫close替代測試。只寫artifacts；Status: local layering fix/checks complete; native Chromium confirmation pending.

## 主代理驗證更新（CHANGE-06）

TASK-12–14 取得 tracking V-16／reports/browser.json：20/20 本地 Chromium 情境通過，原生滑鼠確認可操作，底欄新回應保留，重開 listener 身分回歸通過。所有先前 pending 敘述為階段歷史。TASK-09 的已列 prototype 檢查完成；來源畫面、宿主／正式服務驗證與 TODO-01–06 外部缺口仍未完成，維持部分交付。
