# fixture-case：翻新計劃

## 樣式格式續作先行計劃（CHANGE-03／2026-10-12）

此段在本輪任何契約編輯前建立；原計劃以下保留為 prior-artifacts 的歷史紀錄。本輪是審查引導維護，不是盲測生成。只修已重現的格式／定位問題，來源與產品樣式不變，未知外部缺口不關閉。

| TASK | 工作與依賴 | 影響 | 完成條件／驗證 |
| --- | --- | --- | --- |
| TASK-07 | 依 inputs/prior-format-review.md 修正 typography token object；回查原始 bytes／source inventory 的引用範圍 | CMP-PAGE DESIGN.md、dependency contract、E-04/09 與 plan 範圍 | metadata 形狀檢查通過；引用不超過原始實際行数，補充清楚的 DESIGN／DTCG 路徑區分 |
| TASK-08 | TASK-07；本輪 skill 與客製設定、原瀏覽器報告 | 選用清單、tracking、驗證報告與 artifact hashes | 重新記錄範本版本；三份 CSS、prototype HTML/JS、tokens 與 prior artifact byte-identical 才沿用 browser 證據；保留 shape／source／runtime 限制 |

核對所需依賴已由上一輪 DEC-01 明確處理；這次沒有新增依賴決策或正式授權。後端 API、HANDOFF 與 TODO-01–04 保持其既有權威與開啟狀態。

## 1. 初始範圍與順序

- 唯一入口：`inputs/frontend/Case.jsp`，SHA-256 `90f46177654b8276566c96686c667dac1352f2a398fae3d7c50ec930636c1154`。
- 建立時間：2026-10-12T08:47:08.887541+00:00。此文件在入口及依賴內容分析前建立；此時尚未讀取入口內容。
- 初始邊界：僅改造單一入口的已證實行為及必要可用共用依賴；其他入口內部、外部系統、後端執行均排除。
- 工作順序：範本選用 → 本計劃建立 → 依賴盤點及適用契約查找 → 必要依賴契約 → 入口規格／原型／介接與移交 → 本地驗證。
- 沙盒模擬決策 DEC-01：task.txt 明確授權重用適用契約、先轉換必要可用依賴、以 TODO 延後 unavailable 依賴；不代表正式 scope 擴張。
- 範本選用：[清單](template-selection.json)。profile 為 design-md+dtcg；component-design 使用 project template root，api-spec 使用 explicit override，其他使用內建 fallback；稍後核對必要資訊。

## 2. 依賴與契約查找

尚未分析，TASK-01 將逐筆登錄搜尋、版本、停止边界與決策。

## 3. 任務與影響

| TASK | 工作 | 依賴 | 影響 | 完成及驗證條件 | 初始狀態 |
|---|---|---|---|---|---|
| TASK-01 | 入口依賴盤點、適用契約查找及版本登錄 | 無 | 單一入口及必要共用資源 | 每項依賴記錄可取得性、使用範圍、DEC/TODO | 待辦 |
| TASK-02 | 先轉換必要可用依賴或引用現有契約 | TASK-01、DEC-01 | 本頁使用的共用呈現／互動 | 技術中立契約及來源映射 | 待辦 |
| TASK-03 | 入口規格、prototype、API 投影、必要移交 | TASK-02、指定 backend baseline | SCR/FLOW/UI/API/HANDOFF | 雙向映射及未知分支定位 | 待辦 |
| TASK-04 | DESIGN.md、實際載入 CSS、DTCG tokens | TASK-01、來源樣式、profile | 有样式 CMP | 文件/CSS/token 逐項映射，來源值一致 | 待辦 |
| TASK-05 | 靜態及可用本地互動驗證、tracking | TASK-03、TASK-04 | artifacts | 記錄實際結果及 browser/runtime 限制 | 待辦 |

## 4. 決策與變更

DEC-01 來自 task.txt 的沙盒預先決策；依賴清單與計劃變更將在實際分析後追加。系統契約見 [規格](../../design/fixture-case/specification.md)，執行記錄見 [tracking](tracking.md)。


## 5. 實際依賴盤點後追加（CHANGE-01）

計劃建立後才讀取下列內容；所有提供輸入逐檔版本及編碼見 [inventory](source-inventory.json)。查找範圍為 inputs/specs/ 及提供快照，不對外查找。

| DEP | 來源／所需行為及停止邊界 | 契約查找與適用結果 | 決策／影響／任務 |
|---|---|---|---|
| DEP-01 | frontend/components/action-bar.jspf；唯一查閱按鈕 | specs/action-bar.md fixture-component-v1，來源雜湊相符，僅動作契約適用 | DEC-01 重用 CMP-SEARCH-ACTION；FLOW-02/UI-04，TASK-02 |
| DEP-02 | frontend/legacy-bridge.js；本頁單一查閱交換 | inputs/specs 無 bridge 契約；可用完整 8 行來源 | DEC-01 先轉換本頁呼叫邊界；先產 dependency-contracts.md，TASK-02 |
| DEP-03 | frontend/styles/base.css；本頁全部 4 行樣式 | inputs/specs 無樣式契約，僅一份 stylesheet，沒有其他來源 cascade | DEC-01 先轉換必要樣式，不創新；CMP-PAGE/CMP-TABLE/CMP-SEARCH-ACTION，TASK-04 |
| DEP-04 | backend/api-contract.md fixture-v1；選定查閱 API 基準 | inputs/backend 唯一明確操作契約；查閱部分適用 | API-01；認證未知 TODO-04，排序提示未承接 TODO-02；TASK-03 |
| DEP-05 | backend/business-rules.md fixture-v1；單位查阅授權 | 可用，僅權限及結果決策適用 | API-01/FLOW-02；不擴成數量業務承接 |
| DEP-06 | session 審閱者／單位情境、Ledger 儲存模組 | 快照中無其實作或適用契約；停止於 root 中已知使用 | DEC-01 延後不可用依賴；HANDOFF-01/02，TODO-01/03；TASK-06 |

### 後續任務 TASK-06（延後）

依賴：取得服務端審閱者與單位情境及 Ledger 行為／目標承接契約、認證與排序資料契約。影響：DATA-01/04/05/06/07、UI-02/06、FLOW-01/02/03、ST-INIT/ST-ROWS/ST-SUBMIT、BOUND-01/02/03。順序：先確認依賴來源與基準 → 更新 HANDOFF/API/規格與局部 TODO → 重驗 AC-01/03/07/08/09 及 API-AC-01/02。完成條件為可定位承接證據及必要實測；本輪開啟。

TASK-01 已完成；TASK-02 現在先建立必要 dependency 契約，再生成入口。TASK-03/04 在其後；TASK-05 的 browser 核對由 parent 另行執行，本輪不宣稱完成。範本必要資訊核對：project DESIGN.md 的 Adoption Scope 和 API override 的 Consumer Impact 保留；補充 API 規則要求「相依消費端」節；兩者僅文件格式，不授權產品設計變更。


## 6. 本輪任務結束狀態（CHANGE-02）

TASK-01/02 完成可取得來源及適用契約盤點；TASK-03/04 已交付有證據的規格／介接／移交及 source-only 樣式與離線原型，但仍為部分契約。TASK-05 已執行 source integrity、JS syntax、7 minimal DOM 互動組與 static links/CSS/tokens/TODO 定義位置核對；詳細結果見 tracking V-01/03 與 checks/*.json。native browser 核對由 parent 另行執行，本子任務不以替身檢查代替。TASK-06 尚未完成，依 DEC-01 延後，不宣稱後端承接或完整翻新。
