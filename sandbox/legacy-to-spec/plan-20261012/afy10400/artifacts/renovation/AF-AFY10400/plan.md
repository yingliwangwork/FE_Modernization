# AF-AFY10400：翻新計劃

> 首次啟動的計劃交付；執行任務與依賴處理均待選。證據與實際檢查見 [tracking](tracking.md)。行為規格預期位置：`artifacts/design/AF-AFY10400/specification.md`（待建立）。

## 1. 初始範圍與順序

| 項目 | 內容 |
| --- | --- |
| 唯一根 JSP／scope | `inputs/frontend/sourceCode/AF/AFY10400.jsp`／AF-AFY10400；來源起點與 scope 由 manifest 指定 |
| 版本 | SHA-256 `fbf8f94aee2f03f830f5092ba280dca6f6707ce45d54a929e6ec7cecd4284b1a`；只有快照版本，未讀案例外 Git |
| 建立時間與順序 | 2026-10-12T12:43:01.157003+00:00；先檢查存在及 hash，建立 plan 后才讀 JSP 作有限盤點；[初始快照](plan.initial.md)、[實際順序](run-log.json) |
| 納入 | 根入口來源 metadata；直接資源、服務交接及必要間接未知的有限盤點；提供材料中的既有契約查找；任務選單与待決紀錄 |
| 排除 | 未選擇的行為/API/移交/原型/CSS/tokens 生成；完整共用依賴翻新、另一入口內部行為；外部系統、案例外資料与既有產物；後端程式執行 |
| 啟動与目前階段 | `/legacy-to-spec jsp=inputs/frontend/sourceCode/AF/AFY10400.jsp`；首次啟動計劃与盤點完成，等待任務選擇 |
| 工作順序 | 先建立計劃 → 盤點与查找 → required/optional 選單与依賴選擇 → 執行所選範圍 → 必要驗證 → 更新下一批選項 |
| 既有授權 | 只有首次計劃/盤點授權；無執行任務、外部依賴扩充、延後或行為/樣式改良授權 |
| 實際資料范围 | task.txt、manifest.json、skill 及 inputs 的提供快照；inputs 只有根 JSP，无 inputs/specs 或提供 config；本 scope 不讀案例外索引/產物 |
| 後端基準 | backend_root、backend_contract 均 null；未選定版本、來源性質/適用環境，部署狀態未確認。只阻塞相應 API/業務主張 |

### 範本与撰寫規則選用

| 角色/profile | 選用檔案/雜湊 | 客製及必要資訊核對 | 規則与權威 | 影響/TASK |
| --- | --- | --- | --- | --- |
| plan | `skill/templates/renovation/plan.md`；SHA-256 `cca01b5a90fe3d38c1ca7280e9d76c62c3514d5910cf424d578c647b72830d55` | builtin；保留必要欄位，初始 scope/搜尋/依賴/任務/決策/證據/檢查完整；无用户客製 | skill 的 workflow/customization/dependencies/evidence/acceptance；來源解析與 api authority/backend-profile | TASK-01 |
| tracking | `skill/templates/renovation/tracking.md`；SHA-256 `772d0a61ca71c3413126433315e15dd1729907b5db7c574d3cd2a8e5c20b5f0a` | builtin；保留必要欄位，初始 scope/搜尋/依賴/任務/決策/證據/檢查完整；无用户客製 | skill 的 workflow/customization/dependencies/evidence/acceptance；來源解析與 api authority/backend-profile | TASK-01 |
| design-md 与後續角色 | [選用清單](template-selection.json) 中九角色含实际絕對路徑與 SHA-256 | 本輪只使用 plan/tracking；元件必須 DESIGN.md 与實際 CSS 雙份；tokens optional，未建立空產物 | 無補充 API/UI/domain reference；內建範本不授權改變樣式或互動 | TASK-02～11 |

## 2. 依賴與契約查找

<a id="dependencies"></a>

實際查找：`rg --files inputs` 只列出根 JSP；核對 `inputs/specs` 未提供，inputs 中無 Markdown/JSON/YAML 契約候選，也沒有本輪 config。以資源確切路徑/名稱与 scope 所需能力對照提供材料；詳見 [查找紀錄](contract-search.json)。未查案例外 artifacts、後端或其他工作區，因此結論僅是「提供範圍內沒有適用契約可核對」，不能宣告整個系統沒有規格。

manifest 列 `backend/docs/OPENAPI.md` 与 `backend/docs/specs/AFY1_0400/AFY1_0400_doExport.md`、`AFY1_0400_doDownload.md` 不可取得。`AFY1_0400_doPrompt.md` 亦不可取得；本 JSP 未找到 prompt 呼叫，故它只保留為未取得候選，未將其能力當作本頁契約或自動納入翻新。後端基準不存在於提供材料，沒有可用雜湊。

| DEP/資源与版本 | 引入條件/本頁關係 | 搜尋范围与候選 | 適用性/查找結果 | 本輪所需/影響 | 處理/停止邊界 | TASK/TODO |
| --- | --- | --- | --- | --- | --- | --- |
| <a id="dep-01"></a>DEP-01；`/html/CM/header.jsp` → manifest `sourceCode/CM/header.jsp`；版本/雜湊未取得 | L2；入口靜態引入；E=E-05 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 頁面共用初始化、cssBase/htmlBase/imageBase 等實際來源與值、受信任入口情境未確認；不得由名稱推定 include 輸出；初始化與資源定位；相關後端責任待拆解 | 待決，DEC-02；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-09；[TODO-01](tracking.md#todo-01) |
| <a id="dep-02"></a>DEP-02；`<%=cssBase%>/cm.css` → manifest `sourceCode/CM/css/cm.css`；版本/雜湊未取得 | L8；全頁載入；E=E-07 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | subTitle/tbBox/tbBox2/tbYellow/tbYellow2/tbBlue/button/textBox2 等適用規則、權重、繼承與狀態；標题／面板／說明／下拉／動態列／按鈕，最終呈現值 | 待決，DEC-03；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-10；[TODO-02](tracking.md#todo-02) |
| <a id="dep-03"></a>DEP-03；`<%=htmlBase%>/CM/js/ajax/prototype.js`；版本/雜湊未取得 | L9；全頁載入；L69–70、97 使用 $F、Form.serialize；E=E-06/E-10 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 欄位讀取、表單序列化、全域副作用及與 CSRUtil 的依存；匯出傳遞值與重複欄位序列；例外或失敗結果 | 待決，DEC-04；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-11；[TODO-03](tracking.md#todo-03) |
| <a id="dep-04"></a>DEP-04；`<%=htmlBase%>/CM/js/ajax/CSRUtil.js`；版本/雜湊未取得 | L10；L95、97–113 建立請求、post 及兩個回呼；E=E-06/E-10/E-11 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 請求實際 protocol、callback 分流、共通 envelope、訊息、例外、完成／阻斷／順序；匯出啟動、回應回填、下載觸發、共用錯誤與訊息生命週期 | 待決，DEC-04；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-11；[TODO-04](tracking.md#todo-04) |
| <a id="dep-05"></a>DEP-05；`<%=htmlBase%>/CM/js/ui/PageUI.js`；版本/雜湊未取得 | L11；全頁載入；根 JSP 無直接具名呼叫；E=E-06 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 相關初始化、監聽、全域副作用或本頁不使用的依據未取得；頁面生命週期、布局或互動受影響範圍待確認；不能當作不適用 | 待決，DEC-04；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-11；[TODO-05](tracking.md#todo-05) |
| <a id="dep-06"></a>DEP-06；`<%=htmlBase%>/CM/js/HotKey.js`；版本/雜湊未取得 | L12；全頁載入；根 JSP 無直接具名呼叫；E=E-06 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 相關鍵盤註冊對象、阻斷、解除、全域副作用待確認；全頁鍵盤與焦點；現有來源不足以指定快捷鍵 | 待決，DEC-04；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-11；[TODO-06](tracking.md#todo-06) |
| <a id="dep-07"></a>DEP-07；`<%=htmlBase%>/CM/js/Validator.js`；版本/雜湊未取得 | L13；全頁載入；本頁已知空值/重複判斷是 inline；E=E-06/E-09 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 共用驗證是否介入、載入副作用及相關分支待確認；不能把檔名當作新增欄位規則；其作用範圍待確認 | 待決，DEC-04；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-11；[TODO-07](tracking.md#todo-07) |
| <a id="dep-08"></a>DEP-08；`<%=htmlBase%>/CM/js/RPTUtil.js`；版本/雜湊未取得 | L14；L106 呼叫 downloadFile，第三參數 false；E=E-06/E-11 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 下載工具對傳遞資料、視窗、導覽、focus、生命週期與失敗的語意；下載交接與使用者可見結果；不能把工具呼叫當作下載完成 | 待決，DEC-04；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-11；[TODO-08](tracking.md#todo-08) |
| <a id="dep-09"></a>DEP-09；`<%=htmlBase%>/CM/js/calendar.js`；版本/雜湊未取得 | L15；全頁載入；根 JSP 無直接具名呼叫；E=E-06 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 本頁相關監聽／初始化與載入副作用，或不適用依據；影響待確認；根 JSP 沒有日期欄位不能證明腳本無作用 | 待決，DEC-04；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-11；[TODO-09](tracking.md#todo-09) |
| <a id="dep-10"></a>DEP-10；`<%=htmlBase%>/CM/js/date.js`；版本/雜湊未取得 | L16；全頁載入；根 JSP 無直接具名呼叫；E=E-06 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 本頁相關全域定義／副作用與必要間接依賴；影響待確認；不得以無具名呼叫抹除依賴 | 待決，DEC-04；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-11；[TODO-10](tracking.md#todo-10) |
| <a id="dep-11"></a>DEP-11；`/html/CM/msgDisplayer.jsp` → manifest `sourceCode/CM/msgDisplayer.jsp`；版本/雜湊未取得 | L18 靜態 include；L30 初始化呼叫 displayMessage()；E=E-05/E-08 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 初始化訊息、入口資料、顯示條件、正文、累積/清除、焦點及可見副作用；初始化回饋與共用訊息呈現；inline alert 的已知文案另列 | 待決，DEC-02；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-09；[TODO-11](tracking.md#todo-11) |
| <a id="dep-12"></a>DEP-12；`<%=imageBase%>/CM/border_01.gif`；版本/雜湊未取得 | L132–133、168–169；背景與圖片；E=E-07 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 圖片內容／版本、與邊框呈現之關係；實體路徑未取得；標題與主內容左側邊框 | 待決，DEC-03；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-10；[TODO-12](tracking.md#todo-12) |
| <a id="dep-13"></a>DEP-13；`<%=imageBase%>/CM/border_02.gif`；版本/雜湊未取得 | L151–152；背景與圖片；E=E-07 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 圖片內容／版本；實體路徑未取得；標題右側邊框 | 待決，DEC-03；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-10；[TODO-13](tracking.md#todo-13) |
| <a id="dep-14"></a>DEP-14；`<%=imageBase%>/CM/border_03.gif`；版本/雜湊未取得 | L136、138；背景與圖片；E=E-07 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 圖片內容／版本；實體路徑未取得；標題頂部邊框 | 待決，DEC-03；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-10；[TODO-14](tracking.md#todo-14) |
| <a id="dep-15"></a>DEP-15；`<%=imageBase%>/CM/ecblank.gif`；版本/雜湊未取得 | L155；圖片 width=5 height=1；E=E-07 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 圖片內容／透明度；實體路徑未取得；標題末端留白／佈局 | 待決，DEC-03；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-10；[TODO-15](tracking.md#todo-15) |
| <a id="dep-16"></a>DEP-16；`<%=imageBase%>/CM/icon_dot11.gif`；版本/雜湊未取得 | L179；圖片 width=18 height=16；E=E-07 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 圖像內容／版本；實體路徑未取得；公會補通報作業面板標示 | 待決，DEC-03；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-10；[TODO-16](tracking.md#todo-16) |
| <a id="dep-17"></a>DEP-17；`${dispatcher}/AFY1_0400/`；legacy 動作 `export`；版本/雜湊未取得 | L95、97；本頁參數檢查後交接；E=E-10/E-11 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 目標 operation/path/method、wire schema/envelope、業務、資料與授權；dispatcher 合法來源；匯出服務與 rtnMap/fileName 消費映射、回填；後端承接未確認 | 待決，DEC-05；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-03/TASK-08；[TODO-17](tracking.md#todo-17) |
| <a id="dep-18"></a>DEP-18；`${dispatcher}/AFY1_0400/download`；版本/雜湊未取得 | L106；第一回呼先回填再呼叫下載工具，傳 fileName；E=E-11 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 目標下載契約、檔案格式、內容、可用性、授權、錯誤及資料副作用；下載交接後的可見結果與服務驗證 | 待決，DEC-05；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-03/TASK-08；[TODO-18](tracking.md#todo-18) |
| <a id="dep-19"></a>DEP-19；`org.apache.commons.collections.map.ListOrderedMap`；版本/雜湊未取得 | L3；page import；根 JSP 無其他文字引用；E=E-13 | inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json) | 不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點 | 提供快照無 library 或 include 內容；實際使用／入口編譯情境未確認；僅登錄入口編譯/間接資料工具的待查線索，不推导業務行為 | 待決，DEC-02；停止於本 JSP 引入/调用；未先翻新，未延後 | TASK-09；[TODO-19](tracking.md#todo-19) |

## 3. Required／Optional 任務與影響

<a id="tasks"></a>

| TASK ID | 分類/適用依據 | 建議順位 | 工作与明確範圍 | 前置依賴 | 影響/預期交付 | 完成條件与驗證 | 狀態/選擇 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| <a id="task-01"></a>TASK-01 | required；首次啟動計劃盤點 | 0 | 唯一入口 metadata、有限依賴盤點與既有契約查找 | 初始計劃；啟動授權 | 本 plan、tracking、source-inventory.json、contract-search.json | 入口/行號/解碼可核對；19筆依賴及查找、待決影響可追蹤；V-01～V-04 | 已完成；啟動授權，DEC-01 |
| <a id="task-02"></a>TASK-02 | required；根入口行為契約 | 1（可先選） | 僅根 JSP 已有證據：標題、說明、選項、初始表格、列增刪、色彩重算、空值/重複分支、回應消費；不詳解缺失依賴 | TASK-01；只執行已知部分，未取得依賴的段落保留 TODO，無延後決策 | 預期 artifacts/design/AF-AFY10400/specification.md；資料/狀態/流程/案例 | 逐來源定位，已知分支不抹除，需求与進度分離；未知局部標記；來源覆蓋及引用核對 | 可執行（僅明示本地範圍）；未選，DEC-06 |
| <a id="task-03"></a>TASK-03 | required；本頁有匯出/下載交換 | 1（取得基準後）；映射在 TASK-02/TASK-08 後 | 取得并鎖定後端基準，形成已確認 API 消費映射；不由 JSP 推導目標端點/schema | DEP-17/18、DEC-05；後端根/契約/版本/性質未提供；映射需 TASK-02、TASK-08 | 預期 artifacts/integration/AF-AFY10400/api-spec.md；匯出與下載邊界 | operation/wire/envelope/結果碼及資料合法來源有兩端 E；基準一致性核對；環境缺少時如實記錄未驗證 | 阻塞；未提供基準，DEC-05 待決；未選 |
| <a id="task-04"></a>TASK-04 | required；畫面與已知互動交付 | 2；TASK-02 後 | 離線原型，對照已知狀態/操作/訊息/下載交接；展示止於已知邊界 | TASK-02；DEP-01～16/19 相關部位待決；與 TASK-05 共用樣式；所選未知部分不得捏造 | 預期 artifacts/design/AF-AFY10400/prototypes/SCR-ID.html | UI/互動與文字雙向映射；中間狀態/分支及缺口呈現核對；展示資料不成需求 | 待決；前置 TASK-02 未選，依賴內容未取得 |
| <a id="task-05"></a>TASK-05 | required；本頁有 inline/class 樣式 | 2；可在 TASK-02 後與原型協作 | 有樣式元件的 DESIGN.md 與實際 CSS；保留根來源可證值，缺 CSS/圖片的最終效果待查 | TASK-02；DEP-02、12～16、DEC-03；共用呈現需 DEP-01/11 決策 | 預期 artifacts/design/AF-AFY10400/components/CMP-ID/DESIGN.md、styles/CMP-ID.css | inline/class/引入順序/繼承/權重映射；DESIGN 与載入CSS逐值一致；必要 computed style 核對 | 待決；必要樣式資料未取得，未選 |
| <a id="task-06"></a>TASK-06 | required；所選交付驗證 | 3；各所選產物完成後 | 來源覆蓋、文件引用、分支、視覺、互動与適用 API/移交檢查；更新下一批選項 | 對應所選 TASK 完成；後端/原型環境限制獨立記錄 | tracking 的 V、缺口位置表、交付判定 | 实际檢查及結果有可重現紀錄；局部 TODO 回讀包含 DATA/ST 等；必要缺口未解不得完整宣告 | 待決；尚無所選契約/原型，未選 |
| <a id="task-07"></a>TASK-07 | optional；額外 DTCG tokens，非完整樣式替代 | 3；TASK-05 後 | 將已確認的樣式值交付 DTCG tokens | TASK-05；明确選擇此額外產物 | 預期 artifacts/design/AF-AFY10400/styles/tokens.json | tokens 格式、值與 DESIGN/CSS 映射核對；未知值不得補造 | 待決；前置 TASK-05 未完成，未選 |
| <a id="task-08"></a>TASK-08 | required；跨邊界責任与未確認承接 | 1（可先選） | 僅入口 legacy 交換、資料/檢查/回填/下載順序與混合責任盤點；登錄未承接需求 | TASK-01；不需要目標 API 既有能力假設；缺失工具、入口情境局部 TODO | tracking LOGIC/BOUND 映射；有證據需求預期 artifacts/integration/AF-AFY10400/backend-handoff.md | 各責任有來源、前後端歸屬及承接/未知去向；保留原順序；不可把 param 物件當作已送 payload | 可執行（legacy 已知範圍）；未選，DEC-06 |
| <a id="task-09"></a>TASK-09 | required；入口/訊息完整性；library 適用性待查 | 1（選先翻新且材料取得後） | DEP-01/11 的本頁所需共用契約及 DEP-19 的適用性核對；完整共用契約不擴为另一 JSP 根入口 | DEC-02 選擇与缺失來源/既有適用契約；沙盒目前不可取得 | 初始化、資源基底、入口情境、訊息的生命週期；取得後回查 TASK-02/04/05/08 | 鎖版本；本頁使用條件、訊息分支/文案/累積/清除/焦點可證；必要間接依賴追查；受影響案例重驗 | 待決；材料也缺少；不自動先翻新或延後 |
| <a id="task-10"></a>TASK-10 | required；既有完整樣式/圖片 | 1（選先翻新且材料取得後） | DEP-02/12～16 適用契約查證或所需部分翻新 | DEC-03 選擇；CSS/5圖片或適用契約未提供 | 資訊層級、元件樣式/狀態、邊框与圖像；回查 TASK-02/04/05 | 來源版本与相關 selector/權重/繼承/圖片可定位；DESIGN/CSS/browser 檢查及受影響位置再驗 | 待決；材料也缺少；完整樣式工作仍 required |
| <a id="task-11"></a>TASK-11 | required；prototype/CSRUtil/RPTUtil 已直接使用；其餘載入副作用適用性待查 | 1（選先翻新且材料取得後） | DEP-03～10 只查本頁使用鏈、相關回呼/例外/監聽/全域副作用与必要間接資源 | DEC-04 選擇；8腳本或適用版本契約未提供 | 序列化/請求/分流/訊息/下載與頁面生命週期；回查 TASK-02/03/04/08 | 直接调用語意、所有相關分支与事件作用範圍可證；不從函式名推條件；不適用有依據；受影響案例重驗 | 待決；材料也缺少；不自動翻新外部資源 |

required 与執行狀態分開；即使使用者之後延後必要工作，仍保留 required，完整交付前必須解決或如實部分交付。元件樣式双份与必要驗證不能轉为 optional。未分析的間接依賴與載入副作用不得先宣告不適用。

### 目前可選工作

建議先選 TASK-02（根 JSP 本地可證行为）與/或 TASK-08（legacy 邊界責任与移交）；二者在明示范围可獨立执行，未知依賴位置仍標 TODO、決策維持待決。這不是先同意延後共用依賴。TASK-04/05 待 TASK-02 与相關依賴前置條件；TASK-03 缺後端基準；TASK-09/10/11 需選先翻新並取得材料；TASK-06 隨所選產物驗證；TASK-07 為可另選的 DTCG 額外成果。

可回 `TASK-02`、`TASK-08` 或明確一組任務，並对 DEC-02～05 分組選「先翻新/取得基準」或「延後」。沙盒沒有後續回答，本輪只提供選單，維持待選與待決。

## 4. 任務選擇、依賴決策與對話紀錄

<a id="decisions"></a>

| DEC/日期 | DEP/TASK/TODO | 告知内容与影響 | 選擇 | 決策來源/授權 | 下一步 |
| --- | --- | --- | --- | --- | --- |
| <a id="dec-01"></a>DEC-01；2026-10-12T12:51:39.680260+00:00 | TASK-01 | 首次啟動建立計劃與有限盤點，唯一根入口保持不變 | 依啟動授權完成計劃/盤點 | task.txt 使用者啟動輸入；不含執行或擴充授權 | 已完成；不代表其他 TASK 選中 |
| <a id="dec-02"></a>DEC-02；2026-10-12T12:51:39.680260+00:00 | DEP-01/11/19；TASK-09；TODO-01/11/19 | header.jsp、msgDisplayer.jsp 与 ListOrderedMap 宣告來源未取得；影響入口情境、資源值與初始化訊息，library 是否影響待確認；根 inline 盤點可先做 | 待決：先翻新所需部分／本輪延後 | 沙盒未提供回答；資源缺失仍需證據，不能以選先翻新填猜測 | 选择先翻新需先補來源/契約，再 TASK-09；選延後需局部 TODO 連結与重新驗證 |
| <a id="dec-03"></a>DEC-03；2026-10-12T12:51:39.680260+00:00 | DEP-02/12～16；TASK-10；TODO-02/12～16 | cm.css 與 border_01/02/03.gif、ecblank.gif、icon_dot11.gif 未取得；影響全頁生效樣式、邊框/留白/標示；根 inline 顏色/尺寸可先記錄 | 待決：先翻新所需部分／本輪延後 | 未提供回答，未授權改用其他視覺風格 | 先補材料再 TASK-10，或經明确延後後保留局部 TODO；TASK-05 不改 optional |
| <a id="dec-04"></a>DEC-04；2026-10-12T12:51:39.680260+00:00 | DEP-03～10；TASK-11；TODO-03～10 | 8個 script 未取得；prototype/CSRUtil/RPTUtil 直接影響欄位序列化、回呼、訊息/例外与下載；PageUI/HotKey/Validator/calendar/date 的載入副作用待查；本地增刪/已知警示可先做 | 待決：先翻新本頁所需使用鏈／本輪延後 | 未提供回答；未用檔名/無直接呼叫代替行為證據 | 先補材料再 TASK-11，或確認延後後各受影響 FLOW/DATA/ST/BOUND 等局部標記 |
| <a id="dec-05"></a>DEC-05；2026-10-12T12:51:39.680260+00:00 | DEP-17/18；TASK-03/08；TODO-17/18 | 未提供 backend_root/baseline；export/download 的 target wire/業務/授權/檔案與承接未知；可先盤點 legacy 觸發与移交 | 待決：提供並先核對後端基準／本輪延後 target API 工作 | 未提供回答；不查外部後端，不执行後端程式；部署狀態未確認 | 提供基準後 TASK-03；TASK-08 可先選；延後需明确紀錄与局部 TODO |
| <a id="dec-06"></a>DEC-06；2026-10-12T12:51:39.680260+00:00 | TASK-02～11 | 本輪任務選單已列分類、順位、前置、影響、狀態；TASK-02 与 TASK-08 可先執行；TASK-07 選用 | 待選：可回 TASK-02、TASK-08 或明確一組 | 截至本輪結束沒有任何執行任務選擇 | 維持待選；只继续啟動授權的計劃與檢查 |

DEC-02～06 的实际選單內容另存 [本輪使用者回應](user-response.md)；未收到答案。不以等待時間、缺失材料或首次啟動當作延期/扩充/執行同意。

## 5. 計劃變更

| 日期/CHANGE | 依據 | 依賴与影響變動 | 任務/順序 | tracking |
| --- | --- | --- | --- | --- |
| 2026-10-12T12:43:01.157003+00:00／CHANGE-01 | task/manifest，入口存在/hash | 分析前確立唯一入口和初始邊界 | TASK-01 为啟動授權；其餘待盤點 | [初始紀錄](tracking.md#changes) |
| 2026-10-12T12:51:39.680260+00:00／CHANGE-02 | E-03～E-14；提供快照有限盤點 | 19 DEP；11項 manifest 共用前端資源、5圖片、2服務交接、1匯入線索；間接資源未取得 | TASK-02/08 可先選；TASK-09～11 需决策/材料；TASK-03 缺後端基準 | [增量紀錄](tracking.md#changes) |
