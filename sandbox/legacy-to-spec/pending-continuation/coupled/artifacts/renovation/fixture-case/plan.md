# fixture-case：翻新計劃

## 1. 初始範圍與順序

| 項目 | 內容 |
| --- | --- |
| 唯一根 JSP／scope | `inputs/frontend/Case.jsp`；fixture-case；manifest SHA-256 `90f46177654b8276566c96686c667dac1352f2a398fae3d7c50ec930636c1154` |
| 初始纳入／排除 | 根入口的規劃、依賴盤點、既有契約查找與獨立分析；依賴尚待盤點。排除依賴的未授權翻新、外部系統與網路存取。 |
| 建立時間／依據 | 2026-10-12，先讀 manifest、task 與 skill 方法，於讀取根 JSP 及分析依賴前建立此版。 |
| 續作基準／限制 | 本輪沿用 `inputs/prior-artifacts/renovation/fixture-case/` 的既有 plan；起始四份可編輯紀錄與 prior 位元組相同。原建立順序為既有紀錄，本輪沒有重建計劃或重新證明前輪工具順序。續作核對見 CHANGE-03／V-06。 |
| 工作順序 | TASK-01 盤點 → TASK-02 查找及核對契約 → TASK-03 使用者決策；等待時 TASK-04 獨立分析；依決策再安排相依契約及入口設計、原型、介接與驗證。 |
| 既有授權／測試設定 | 模擬使用者要求先建立 plan、告知資源與影響並由其選先翻新或延後，可繼續獨立工作；沒有依賴擴張或延後授權。 |

## 2. 依賴與契約查找

查找範圍：`inputs/specs/` 全部已提供規格、`inputs/backend/` 全部已提供後端文件；使用確切資源與 `action-bar`、`legacy-bridge`、`base.css`、`Ledger`、`reviewerLabel`、`rankHint`、`quantity`、`searchRows` 查找。根入口 1–60 行與必要依賴短片段做有限盤點，僅說明本頁影響，不建立未授權相依契約。查無結果只限提供材料，沒有遍歷其他專案。完整來源雜湊见 [source-check](source-check.json)。

| DEP ID／資源及版本 | 引入條件／所需行為與停止邊界 | 搜尋候選及版本 | 適用性 | 影響 | 處理／決策 | 引用／TASK／TODO |
| --- | --- | --- | --- | --- | --- | --- |
| DEP-01 `inputs/frontend/components/action-bar.jspf`，61f707…ff9e | JSP:51 無條件 include；本頁查閱按鈕回呼；只核對單一按鈕與呼叫點 | `inputs/specs/action-bar.md` fixture-component-v1，ad476c…e141 | 適用：來源相對 inputs 的路徑一致、完整雜湊相符；片段唯一按鈕「查閱」啟動本頁 searchRows；無另定禁用條件。不涵蓋查詢輸入或結果 | 本頁查閱觸發；元件定義不複製改寫 | 直接引用／DEC-01 | [CMP-SEARCH-ACTION](../../../inputs/specs/action-bar.md#cmp-search-action)；TASK-02 |
| DEP-02 `inputs/frontend/styles/base.css`，447252…d99 | JSP:16 無條件載入；僅盤點 1–4 行的頁面、表格與動作區影響 | inputs/specs 無候選；backend 不屬 UI 權威 | 提供材料未找到技術中立契約；可讀來源不等於授權翻新 | 頁面宽度、字體、留白、表格邊框／對齊、按鈕區間距；阻塞視覺等價確認 | 待決／DEC-02 | TASK-07；TODO-01 |
| DEP-03 `inputs/frontend/legacy-bridge.js`，f008cb…09a | JSP:17 載入、21 呼叫；有限讀 1–8 行，停止於 legacy HTTP 邊界，不呼叫 | 無獨立共用橋接規格；目標 backend fixture-v1 僅承接查詢交換 | 無適用橋接契約；目標 API 可部分引用，不能冒充舊橋接的全部契約 | 查詢傳輸／回呼及異常處理；成功／空／拒絕的 JSP 呈現可獨立盤點 | 待決／DEC-02 | TASK-08；TODO-02 |
| DEP-04 `example.Ledger`／`Ledger.store`，未提供版本 | JSP:2、5–8，commit 時解析整數→計費→以 session 單位儲存；停止於呼叫參數，不能確認內部寫入結果 | inputs/specs 無候選；backend 兩文件明確未承接 quantity 行為 | 實作及適用契約未取得 | 數量送出之儲存、授權、失敗、交易及結果回饋；JSP 計費可作舊證據，不能重製為前端運算 | 待決／DEC-03；另有目標承接缺口 | TASK-09；TODO-03 |
| DEP-05 session `reviewerLabel`、`unitId` 提供端，未提供版本 | JSP:4、8、49；審閱者名稱呈現與 commit 受信任單位；停止於取值，不造初始化 API／前端可填單位 | 無初始化／commit 情境契約；backend 只確認查詢單位由服務端情境提供 | 查詢單位情境可引用；審閱者取得及數量送出的情境尚無適用契約 | 首次載入審閱者資料、缺值反應；送出單位身份與合法來源 | 待決／DEC-03 | TASK-09；TODO-04 |
| DEP-06 `inputs/backend/api-contract.md` fixture-v1，04215f…802；business-rules.md fixture-v1，35e425…eec2 | 根查詢與數量／初始化承接核對；只讀指定本頁後端快照 | 使用 manifest 指定 baseline，不引用外部工具範本 | 查詢部分適用，operation 與映射明定；rankHint、審閱者名稱、數量送出明確未承接；認證與非 200 尚未定義 | 查詢消費映射可獨立盤點；排序提示欄、初始化及送出缺口影響完整入口 | 已知部分引用／DEC-01；缺口待承接，處理順序待決／DEC-04 | TASK-04、10；TODO-05、06 |

## 3. 任務與影響

| TASK ID | 工作與範圍 | 依賴 | 影響／交付位置 | 完成條件與驗證 | 狀態／紀錄 |
| --- | --- | --- | --- | --- | --- |
| TASK-01 | 根 JSP 直接資源及本頁必要依賴有限盤點 | 無 | 本 plan DEP-01–06；tracking | 每項有條件、必要內容、可取得性與停止邊界；V-01 | 完成 |
| TASK-02 | 查找既有契約、核對来源版本／責任／本頁用法 | TASK-01 | DEP-01、06 重用；其他具體缺口 | 雜湊核對、查找記錄、邊界一致；V-01、02 | 完成 |
| TASK-03 | 在模擬對話告知未轉換依賴及選先翻新或延後 | TASK-02 | DEC-02–04；相依契約與入口後續 | 使用者明確答覆後記錄範圍及來源；未回覆維持待決 | 本輪 outgoing message 提問；待決 |
| TASK-04 | 不依賴待決資源的根入口事實、耦合分類與後端差距盤點 | TASK-01、指定 baseline 與 skill 參考 | tracking E、來源覆蓋與 LOGIC | 原始行號／雜湊可定位；原順序、受信任情境、差距均保留 | 完成計畫階段盤點；未生成完整設計 |
| TASK-05 | 建立根入口設計、原型、API 消費投影及移交文件 | TASK-03、必要依賴處理結果 | 未來 artifacts/design/fixture-case 與 integration/fixture-case | 只形成具證據契約；未承接責任移交，不補端點／欄位／本機計費 | 本階段未執行；相依部分待決 |
| TASK-06 | 計畫階段靜態檢查 | TASK-01、02、04 | tracking 驗證與 source-check.json | 快照未變、根入口唯一、交付連結有效、無範本骨架、待決未變延後；V-01–04 | 已執行；動態／視覺／介接未執行 |
| TASK-07 | 條件分支：先翻新則取得／建立樣式契約；延後則定位每個受影響視覺 TODO | DEC-02 明確選擇、DEP-02 | 頁面與表格視覺、後續原型；TODO-01 | 引用已核對契約或有明確延後決策；重新核對頁寬、留白與表格 | 待決，兩路都未執行 |
| TASK-08 | 條件分支：橋接契約先處理，或延後並定位查詢邊界缺口 | DEC-02 明確選擇、DEP-03 | 查詢 FLOW／BOUND、API 映射與回呼；TODO-02 | 取得相符契約与未知異常範圍；重驗查詢回應前後清空時機與三個分支 | 待決，兩路都未執行 |
| TASK-09 | 先處理 Ledger／session 時索取對應實作與契約；延後時記錄根入口送出及初始化缺口 | DEC-03 明確選擇、DEP-04、05；提供材料不足 | 審閱者、數量、計費及儲存移交；TODO-03、04 | 來源與承接可定位；重新驗空值阻擋、整數解析、4 的計費分界及儲存順序；另有未知錯誤 | 待決，未取得資料；不另開任意 JSP scope |
| TASK-10 | 比較 rankHint／初始化／commit 需求與目標後端，核對認證傳輸、其他結果碼及非200補充契約；依決策排承接或延期缺口 | DEC-04；DEP-06；TASK-09 的合法情境及後端補充材料 | 查詢排序欄、初始化與數量後端移交；查詢認證、異常與消費映射驗證；TODO-03–06 | 後端承接文件提供缺失能力再映射與重驗；認證及回應補充需版本與來源可定位。排序、分頁、重送、取消、交易僅確認適用性，不因文件未定就新增需求；未承接時保留 HANDOFF，不發明 API | 差距已盤點；處理順序待決 |

## 4. 依賴決策與對話紀錄

| DEC ID／日期 | DEP／TASK | 告知內容與影響 | 選擇 | 來源／授權 | 下一步 |
| --- | --- | --- | --- | --- | --- |
| DEC-01／2026-10-12 | DEP-01、06／TASK-02 | 動作按鈕規格與查詢後端 baseline 的已覆蓋部分可直接引用，範圍及沙盒性質明列 | 引用適用部分 | skill 的契約重用規則、manifest 選定 baseline；不等於缺口已獲處理決策 | 保留原契約；缺口不併入已知能力 |
| DEC-02／2026-10-12 | DEP-02、03／TASK-07、08／TODO-01、02 | 本輪 outgoing message 說明 `inputs/frontend/styles/base.css` 與 `inputs/frontend/legacy-bridge.js` 在提供材料未找到適用規格，影響頁面／表格／動作區視覺、查詢傳輸／回呼及異常；可逐項先翻新或延後 | 待決 | 尚無模擬使用者答覆；一般繼續獨立工作不等於延後 | 等使用者逐項／成組選擇；bridge 缺 legacy handler，選先翻新仍需補材料 |
| DEC-03／2026-10-12 | DEP-04、05／TASK-09／TODO-03、04 | 本輪 outgoing message 說明 Case.jsp:2、5–8 的 Ledger.store 與 :4、8、49 的 session reviewerLabel／unitId 提供端未取得來源／契約，影響數量計費／儲存、授權／交易／失敗回饋與初始化／合法身份；先處理需補資料 | 待決 | 尚無答覆；不能呼叫後端或網路補資料 | 等決策及資料；有回覆再安排處理／定位延期 TODO |
| DEC-04／2026-10-12 | DEP-06 缺口／TASK-10／TODO-03–06 | 本輪 outgoing message 說明 `inputs/backend/api-contract.md`／`business-rules.md` fixture-v1 未承接 rankHint、審閱者初始化及數量（TODO-03–05）；另認證傳輸、其他結果碼與非200未定，排序／分頁／重送／取消／交易亦未定（TODO-06），影響查詢資料與異常驗證。可先整理承接及補充契約需求或延後 | 待決 | 查詢已知部分引用不構成新能力／擴張授權；前輪摘要未完整列 TODO-06，本輪補充告知，不追認其授權 | 保留 TODO-03–06；不造 API，不把未定性質推導為必要功能；此選擇不代替 DEC-03 的來源取得決策 |

## 5. 計劃變更

| 日期／CHANGE ID | 依據 | 依賴與影響變動 | 順序變動 | tracking |
| --- | --- | --- | --- | --- |
| 2026-10-12／CHANGE-01 | manifest、task、skill | 讀根入口前建立 plan，依賴待盤點 | TASK-01 → 02 | [初始順序](tracking.md#8-增量與變更紀錄) |
| 2026-10-12／CHANGE-02 | E-01–11 | 新增 DEP-01–06；動作契約適用、後端部分適用、其他待決 | TASK-04 先完成獨立盤點；TASK-07–10 保留條件兩路 | [證據與缺口](tracking.md#5-todo-與契約缺口) |
| 2026-10-12／CHANGE-03 | task 的 planning-continuation 指示、既有紀錄及重新回讀 E-01–11 | 全部29份 manifest 快照雜湊相符，DEP及E未變。補齊 DEC-04 的 TODO-06 告知範圍及 TASK-10；不增加入口、證據ID或授權 | DEC-02–04 仍待決；TASK-05、07–10 未執行兩路。獨立盤點已完成，可繼續維護已知事實與映射核對 | [續作核對](tracking.md#7-驗證執行與交付判定)；V-06 |
