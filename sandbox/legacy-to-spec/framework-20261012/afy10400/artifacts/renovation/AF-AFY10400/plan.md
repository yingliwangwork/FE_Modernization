# AF-AFY10400：翻新計劃

## 1. 初始範圍與順序

| 項目 | 內容 |
| --- | --- |
| 唯一根入口 | inputs/frontend/sourceCode/AF/AFY10400.jsp |
| 根入口版本 | manifest SHA-256 fbf8f94aee2f03f830f5092ba280dca6f6707ce45d54a929e6ec7cecd4284b1a；尚未讀取核對 |
| 建立時間 | 2026-10-12T11:11:15.113914+00:00；本計劃在根 JSP 及依賴內容分析前建立 |
| 初始納入 | 根入口畫面、已知事件、資料、必要可取得依賴的本頁使用契約、指定後端消費投影、原型及樣式 |
| 初始排除 | 另一入口內部流程、正式部署、來源修改、外部服務與其他案例；缺少依賴不補造 |
| 分析邊界 | 僅 case 的 skill/、inputs/、manifest.json、task.txt；產物僅 artifacts/ |
| 工作順序 | 盤點 → 契約查找及適用性 → 依 task 決策重用／先轉換／延後 → 依賴契約 → 根入口規格、原型、介接 → 檢查 |
| 授權 | task.txt 的 sandbox-only simulated user decision：reuse suitable contracts; first convert necessary available dependencies; defer unavailable dependencies with TODOs；不是正式擴充 scope 授權 |

### 範本選用

採用 skill 內建範本的必要資訊，實際選用與 SHA-256 見 [template-selection.json](template-selection.json)。profile 為 design-md；不另啟用 DTCG tokens。中文契約表格可合併章節，保留行為、證據、狀態、映射及驗證資訊。選用角色：plan、tracking、specification、prototype、component-design、component-css、api-spec；是否 backend-handoff 待責任盤點決定。無補充規則或設計改動核准。

## 2. 依賴與契約查找

搜尋僅使用 `inputs/` 檔案清單與確切資源位置；`inputs/specs/` 不存在，沒有可重用前端共用契約。所附 backend docs 是選定後端傳輸基準／legacy 方法語意，逐項核對後引用。這個查找結論只適用於本快照。版本逐檔見 [source-inventory.json](source-inventory.json)；原始 bytes 行號基準，前端 CP950（date.js 未確認）、後端 UTF-8。

| DEP／資源 | 引入條件與所需行為 | 查找／適用性 | 影響 | 處理及後續 | 證據 |
| --- | --- | --- | --- | --- | --- |
| DEP-01 | CM/header.jsp | 首次載入；設定、可信情境、政策與浮水印 | 無 inputs/specs；本頁必要片段先轉換 | CMP-POLICY、FLOW-08、DATA-07、BOUND-03/04、ST-06 | TASK-03；TODO-01/04 | E-06/07/08 |
| DEP-02 | CM/msgDisplayer.jsp | 首次訊息及全文件按鈕點擊清底部訊息 | 無 inputs/specs；必要片段先轉換 | CMP-ENTRY、FLOW-01/07、DATA-06、ST-05 | TASK-03；TODO-01/03 | E-09 |
| DEP-03 | CM/js/ajax/prototype.js | 實際序列化、請求／回應生命週期 | 無既有前端契約；必要片段先轉換 | FLOW-04/05/06、DATA-03、BOUND-01 | TASK-03 | E-10 |
| DEP-04 | CM/js/ajax/CSRUtil.js | 請求遮罩、判定、各訊息分支、例外與拖曳 | 無既有前端契約；必要片段先轉換 | CMP-COVER/MESSAGE、FLOW-05/06/09/10、ST-03/05 | TASK-03；TODO-01/03 | E-11/12/13 |
| DEP-05 | CM/js/ui/PageUI.js | 載入註冊及 resize；根頁無 createPage 呼叫 | 無既有契約；核對本頁必要生命週期 | FLOW-01；根頁自行排版 | TASK-03 | E-14 |
| DEP-06 | CM/js/HotKey.js | 全文件 keydown 註冊；根頁未綁定快捷鍵 | 核對註冊，不增加功能鍵 | FLOW-01、CMP-POLICY | TASK-03 | E-15 |
| DEP-07 | CM/js/Validator.js | 只載入定義；根頁不調用 Validator | 核對初始化，不生成證號格式檢核 | BR-01/02 | TASK-03 | E-16 |
| DEP-08 | CM/js/RPTUtil.js | 成功回填後同步取得下載參數並隱藏表單交接 | 無既有契約；先转換必要下載鏈 | FLOW-05、BOUND-02、DATA-05 | TASK-03/05；TODO-02/04 | E-17 |
| DEP-09 | CM/js/calendar.js、CM/css/ui/calendar.css | 載入時條件插入 calendar CSS；無根頁日曆欄位 | JS 可取得必要片段先轉換；CSS 未提供，延後 | CMP-PAGE、UI-01..10；繼承／cascade | TASK-03/08；TODO-05 | E-18 |
| DEP-10 | CM/js/date.js | 被載入；具體行為未建立 | 兩候選嚴格解碼失敗，延後分析 | FLOW-01、CMP-PAGE、所有 UI；未知載入副作用 | TASK-08；TODO-06 | E-19 |
| DEP-11 | CM/css/cm.css | 全域字型、button 最終 :root padding、表格與欄位 | 無既有契約；先轉換所有本頁可匹配規則 | CMP-PAGE/FORM/MESSAGE、STYLE | TASK-03/06；TODO-05 | E-20 |
| DEP-12 | CM 圖片、cover png/gif、EUDC fonts、watermark-js-plus.js | 標題邊框／小圖、遮罩、難字及條件浮水印 | inputs 未提供，依 DEC-01 延後 | CMP-PAGE/COVER、UI-01/02/09、ST-03/06、DATA-07、BOUND-04 | TASK-08；TODO-04/05 | E-02/08/11 |
| DEP-13 | CXL:csCommon、功能資訊／session／utility、底部 frame、WIUtil/jQuery | 間接設定、可信身分、條件訊息、清除／顯示、計時 | inputs 未提供；只轉換呼叫端已知契約，缺內部延後 | CMP-ENTRY/POLICY/MESSAGE、FLOW-01/06/07/08、DATA-06/07/08、BOUND-03/04 | TASK-08；TODO-01/03/04 | E-06/07/09/11 |
| DEP-14 | inputs/backend/docs/OPENAPI.md §1/2/6/10 | 目標 export/download；prompt 只有歷史入口初始化線索 | 指定基準重用，0.0.1-SNAPSHOT，2026-08-12；stub header 已標明 | API-01/02；API-03 未消費；BOUND-01/02 | TASK-05；TODO-02/03/04 | E-21/22 |
| DEP-15 | inputs/backend/docs/specs/AFY1_0400/*.md | 舊業務語意、檔案、逐列結果與安全日誌 | 重用為 legacy 語意依據，不將之升格目標 HTTP | HANDOFF-01/02/03/04、BOUND | TASK-05；TODO-02/04 | E-23/24/25 |


## 3. 任務與影響

| TASK | 工作與範圍 | 依賴 | 影響 | 完成條件／驗證 | 狀態 |
| --- | --- | --- | --- | --- | --- |
| TASK-01 | 原始入口編碼、行號、事件及直接／必要間接依賴盤點 | 初始 plan、manifest | 根入口全部已知來源、DEP | hash 核對；逐項列出行為與未取得項目 | 已執行；見 tracking，契約仍部分 |
| TASK-02 | 僅 inputs 內查找依賴契約、核對版本；按模擬決策處理 | TASK-01、task.txt | DEP、CMP、FLOW | 記錄查找結果、DEC；缺少依賴有 TODO | 已執行；見 tracking，契約仍部分 |
| TASK-03 | 先轉換必要可取得共用依賴的本頁使用契約 | TASK-02、DEC | 共用契約及根入口引用 | 分支有來源；只分析本頁需要部分 | 已執行；見 tracking，契約仍部分 |
| TASK-04 | 根入口技術中立規格及責任拆解 | TASK-03 | design、LOGIC、HANDOFF | 每個已盤點來源有 ID、證據、AC 或 TODO | 已執行；見 tracking，契約仍部分 |
| TASK-05 | 指定 backend 消費投影與必要移交 | TASK-01、TASK-04、OPENAPI 基準 | API、BOUND、DATA、TR | 操作／envelope／字段有兩端依據；差距局部 TODO | 已執行；見 tracking，契約仍部分 |
| TASK-06 | 離線 HTML、元件 DESIGN 與實際 CSS | TASK-04 | SCR、CMP、STYLE | 原型同一行為；不創造業務能力；CSS 映射可查 | 已執行；見 tracking，契約仍部分 |
| TASK-07 | 可執行的來源、metadata、連結、行為及樣式檢查 | TASK-05、TASK-06 | tracking、檢查報告 | 保存實際執行結果；無瀏覽器或正式服務如實記未驗證 | 已執行；見 tracking，契約仍部分 |
| TASK-08 | 延後缺口後續順序 | TASK-02 及缺失資料 | 各 TODO 受影響契約 | 取得確切依賴／承接契約後更新局部位置並重跑 AC | 依 DEC-04 延後，見 TODO-01..07 |

## 4. 依賴決策

DEC-01：task.txt 提供沙盒模擬決策，適用於本頁必要依賴：合適契約重用、可取得者先轉換、無法取得者延後 TODO。實際適用 DEP-01 至 DEP-15；已於工作訊息告知 date 編碼、訊息／下載介接差距與缺少 header 依賴，並在本表展開每筆影響；不得讀其他案例、既有產物或外部系統。

DEC-02：重用 DEP-14 的目標傳輸基準及 DEP-15 的 legacy 語意；二者版本／用途不同，差異保留 TODO-02/04。DEC-03：DEP-01..09/11 的必要可取得片段先建立 [本頁共用契約](../../design/AF-AFY10400/common-contracts.md)，不翻新其其他入口或整套函式庫。DEC-04：DEP-09 的缺 CSS、DEP-10、DEP-12/13 的未提供部分依 task 模擬決策延後；逐項 TODO-01..06 不作正式範圍扩充。

## 5. 計劃變更

CHANGE-01：首次建立。尚未執行來源分析。

CHANGE-02：2026-10-12，TASK-01 來源盤點後補 DEP、決策；共用契約在根頁規格前生成。後續 TASK-08 依序取得功能情境／訊息 frame／下載承接契約（TODO-01..04）、缺少樣式與可解碼 date（TODO-05/06），最後以實際瀏覽器核對（TODO-07）。每筆條件及受影響 AC 見 tracking。

TASK-07 已執行所附helper、Node與靜態檢查；實際瀏覽器／正式介接未完成，不將部分交付標為完整。
