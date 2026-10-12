from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, re

base=Path('artifacts/renovation/AF-AFY10400')
source_path=Path('inputs/frontend/sourceCode/AF/AFY10400.jsp')
source_bytes=source_path.read_bytes()
source=source_bytes.decode('cp950',errors='strict')
lines=source.splitlines()
sha=hashlib.sha256(source_bytes).hexdigest()
now=datetime.now(timezone.utc).isoformat()
initial='2026-10-12T12:43:01.157003+00:00'
selection=json.loads((base/'template-selection.json').read_text())

def cell(s):
    return str(s).replace('|','&#124;').replace('\n','<br>')

def table(headers,rows):
    return '\n'.join(['| '+' | '.join(headers)+' |','| '+' | '.join(['---']*len(headers))+' |']+['| '+' | '.join(cell(c) for c in row)+' |' for row in rows])

# Inventory only: dependency sources are unavailable and are not reconstructed.
deps=[
('DEP-01','`/html/CM/header.jsp` → manifest `sourceCode/CM/header.jsp`','L2；入口靜態引入','頁面共用初始化、cssBase/htmlBase/imageBase 等實際來源與值、受信任入口情境未確認；不得由名稱推定 include 輸出','初始化與資源定位；相關後端責任待拆解','DEC-02','TASK-09','E-05'),
('DEP-02','`<%=cssBase%>/cm.css` → manifest `sourceCode/CM/css/cm.css`','L8；全頁載入','subTitle/tbBox/tbBox2/tbYellow/tbYellow2/tbBlue/button/textBox2 等適用規則、權重、繼承與狀態','標题／面板／說明／下拉／動態列／按鈕，最終呈現值','DEC-03','TASK-10','E-07'),
('DEP-03','`<%=htmlBase%>/CM/js/ajax/prototype.js`','L9；全頁載入；L69–70、97 使用 $F、Form.serialize','欄位讀取、表單序列化、全域副作用及與 CSRUtil 的依存','匯出傳遞值與重複欄位序列；例外或失敗結果','DEC-04','TASK-11','E-06/E-10'),
('DEP-04','`<%=htmlBase%>/CM/js/ajax/CSRUtil.js`','L10；L95、97–113 建立請求、post 及兩個回呼','請求實際 protocol、callback 分流、共通 envelope、訊息、例外、完成／阻斷／順序','匯出啟動、回應回填、下載觸發、共用錯誤與訊息生命週期','DEC-04','TASK-11','E-06/E-10/E-11'),
('DEP-05','`<%=htmlBase%>/CM/js/ui/PageUI.js`','L11；全頁載入；根 JSP 無直接具名呼叫','相關初始化、監聽、全域副作用或本頁不使用的依據未取得','頁面生命週期、布局或互動受影響範圍待確認；不能當作不適用','DEC-04','TASK-11','E-06'),
('DEP-06','`<%=htmlBase%>/CM/js/HotKey.js`','L12；全頁載入；根 JSP 無直接具名呼叫','相關鍵盤註冊對象、阻斷、解除、全域副作用待確認','全頁鍵盤與焦點；現有來源不足以指定快捷鍵','DEC-04','TASK-11','E-06'),
('DEP-07','`<%=htmlBase%>/CM/js/Validator.js`','L13；全頁載入；本頁已知空值/重複判斷是 inline','共用驗證是否介入、載入副作用及相關分支待確認','不能把檔名當作新增欄位規則；其作用範圍待確認','DEC-04','TASK-11','E-06/E-09'),
('DEP-08','`<%=htmlBase%>/CM/js/RPTUtil.js`','L14；L106 呼叫 downloadFile，第三參數 false','下載工具對傳遞資料、視窗、導覽、focus、生命週期與失敗的語意','下載交接與使用者可見結果；不能把工具呼叫當作下載完成','DEC-04','TASK-11','E-06/E-11'),
('DEP-09','`<%=htmlBase%>/CM/js/calendar.js`','L15；全頁載入；根 JSP 無直接具名呼叫','本頁相關監聽／初始化與載入副作用，或不適用依據','影響待確認；根 JSP 沒有日期欄位不能證明腳本無作用','DEC-04','TASK-11','E-06'),
('DEP-10','`<%=htmlBase%>/CM/js/date.js`','L16；全頁載入；根 JSP 無直接具名呼叫','本頁相關全域定義／副作用與必要間接依賴','影響待確認；不得以無具名呼叫抹除依賴','DEC-04','TASK-11','E-06'),
('DEP-11','`/html/CM/msgDisplayer.jsp` → manifest `sourceCode/CM/msgDisplayer.jsp`','L18 靜態 include；L30 初始化呼叫 displayMessage()','初始化訊息、入口資料、顯示條件、正文、累積/清除、焦點及可見副作用','初始化回饋與共用訊息呈現；inline alert 的已知文案另列','DEC-02','TASK-09','E-05/E-08'),
('DEP-12','`<%=imageBase%>/CM/border_01.gif`','L132–133、168–169；背景與圖片','圖片內容／版本、與邊框呈現之關係；實體路徑未取得','標題與主內容左側邊框','DEC-03','TASK-10','E-07'),
('DEP-13','`<%=imageBase%>/CM/border_02.gif`','L151–152；背景與圖片','圖片內容／版本；實體路徑未取得','標題右側邊框','DEC-03','TASK-10','E-07'),
('DEP-14','`<%=imageBase%>/CM/border_03.gif`','L136、138；背景與圖片','圖片內容／版本；實體路徑未取得','標題頂部邊框','DEC-03','TASK-10','E-07'),
('DEP-15','`<%=imageBase%>/CM/ecblank.gif`','L155；圖片 width=5 height=1','圖片內容／透明度；實體路徑未取得','標題末端留白／佈局','DEC-03','TASK-10','E-07'),
('DEP-16','`<%=imageBase%>/CM/icon_dot11.gif`','L179；圖片 width=18 height=16','圖像內容／版本；實體路徑未取得','公會補通報作業面板標示','DEC-03','TASK-10','E-07'),
('DEP-17','`${dispatcher}/AFY1_0400/`；legacy 動作 `export`','L95、97；本頁參數檢查後交接','目標 operation/path/method、wire schema/envelope、業務、資料與授權；dispatcher 合法來源','匯出服務與 rtnMap/fileName 消費映射、回填；後端承接未確認','DEC-05','TASK-03/TASK-08','E-10/E-11'),
('DEP-18','`${dispatcher}/AFY1_0400/download`','L106；第一回呼先回填再呼叫下載工具，傳 fileName','目標下載契約、檔案格式、內容、可用性、授權、錯誤及資料副作用','下載交接後的可見結果與服務驗證','DEC-05','TASK-03/TASK-08','E-11'),
('DEP-19','`org.apache.commons.collections.map.ListOrderedMap`','L3；page import；根 JSP 無其他文字引用','提供快照無 library 或 include 內容；實際使用／入口編譯情境未確認','僅登錄入口編譯/間接資料工具的待查線索，不推导業務行為','DEC-02','TASK-09','E-13'),
]

tasks=[
('TASK-01','required；首次啟動計劃盤點','0','唯一入口 metadata、有限依賴盤點與既有契約查找','初始計劃；啟動授權','本 plan、tracking、source-inventory.json、contract-search.json','入口/行號/解碼可核對；19筆依賴及查找、待決影響可追蹤；V-01～V-04','已完成；啟動授權，DEC-01'),
('TASK-02','required；根入口行為契約','1（可先選）','僅根 JSP 已有證據：標題、說明、選項、初始表格、列增刪、色彩重算、空值/重複分支、回應消費；不詳解缺失依賴','TASK-01；只執行已知部分，未取得依賴的段落保留 TODO，無延後決策','預期 artifacts/design/AF-AFY10400/specification.md；資料/狀態/流程/案例','逐來源定位，已知分支不抹除，需求与進度分離；未知局部標記；來源覆蓋及引用核對','可執行（僅明示本地範圍）；未選，DEC-06'),
('TASK-03','required；本頁有匯出/下載交換','1（取得基準後）；映射在 TASK-02/TASK-08 後','取得并鎖定後端基準，形成已確認 API 消費映射；不由 JSP 推導目標端點/schema','DEP-17/18、DEC-05；後端根/契約/版本/性質未提供；映射需 TASK-02、TASK-08','預期 artifacts/integration/AF-AFY10400/api-spec.md；匯出與下載邊界','operation/wire/envelope/結果碼及資料合法來源有兩端 E；基準一致性核對；環境缺少時如實記錄未驗證','阻塞；未提供基準，DEC-05 待決；未選'),
('TASK-04','required；畫面與已知互動交付','2；TASK-02 後','離線原型，對照已知狀態/操作/訊息/下載交接；展示止於已知邊界','TASK-02；DEP-01～16/19 相關部位待決；與 TASK-05 共用樣式；所選未知部分不得捏造','預期 artifacts/design/AF-AFY10400/prototypes/SCR-ID.html','UI/互動與文字雙向映射；中間狀態/分支及缺口呈現核對；展示資料不成需求','待決；前置 TASK-02 未選，依賴內容未取得'),
('TASK-05','required；本頁有 inline/class 樣式','2；可在 TASK-02 後與原型協作','有樣式元件的 DESIGN.md 與實際 CSS；保留根來源可證值，缺 CSS/圖片的最終效果待查','TASK-02；DEP-02、12～16、DEC-03；共用呈現需 DEP-01/11 決策','預期 artifacts/design/AF-AFY10400/components/CMP-ID/DESIGN.md、styles/CMP-ID.css','inline/class/引入順序/繼承/權重映射；DESIGN 与載入CSS逐值一致；必要 computed style 核對','待決；必要樣式資料未取得，未選'),
('TASK-06','required；所選交付驗證','3；各所選產物完成後','來源覆蓋、文件引用、分支、視覺、互動与適用 API/移交檢查；更新下一批選項','對應所選 TASK 完成；後端/原型環境限制獨立記錄','tracking 的 V、缺口位置表、交付判定','实际檢查及結果有可重現紀錄；局部 TODO 回讀包含 DATA/ST 等；必要缺口未解不得完整宣告','待決；尚無所選契約/原型，未選'),
('TASK-07','optional；額外 DTCG tokens，非完整樣式替代','3；TASK-05 後','將已確認的樣式值交付 DTCG tokens','TASK-05；明确選擇此額外產物','預期 artifacts/design/AF-AFY10400/styles/tokens.json','tokens 格式、值與 DESIGN/CSS 映射核對；未知值不得補造','待決；前置 TASK-05 未完成，未選'),
('TASK-08','required；跨邊界責任与未確認承接','1（可先選）','僅入口 legacy 交換、資料/檢查/回填/下載順序與混合責任盤點；登錄未承接需求','TASK-01；不需要目標 API 既有能力假設；缺失工具、入口情境局部 TODO','tracking LOGIC/BOUND 映射；有證據需求預期 artifacts/integration/AF-AFY10400/backend-handoff.md','各責任有來源、前後端歸屬及承接/未知去向；保留原順序；不可把 param 物件當作已送 payload','可執行（legacy 已知範圍）；未選，DEC-06'),
('TASK-09','required；入口/訊息完整性；library 適用性待查','1（選先翻新且材料取得後）','DEP-01/11 的本頁所需共用契約及 DEP-19 的適用性核對；完整共用契約不擴为另一 JSP 根入口','DEC-02 選擇与缺失來源/既有適用契約；沙盒目前不可取得','初始化、資源基底、入口情境、訊息的生命週期；取得後回查 TASK-02/04/05/08','鎖版本；本頁使用條件、訊息分支/文案/累積/清除/焦點可證；必要間接依賴追查；受影響案例重驗','待決；材料也缺少；不自動先翻新或延後'),
('TASK-10','required；既有完整樣式/圖片','1（選先翻新且材料取得後）','DEP-02/12～16 適用契約查證或所需部分翻新','DEC-03 選擇；CSS/5圖片或適用契約未提供','資訊層級、元件樣式/狀態、邊框与圖像；回查 TASK-02/04/05','來源版本与相關 selector/權重/繼承/圖片可定位；DESIGN/CSS/browser 檢查及受影響位置再驗','待決；材料也缺少；完整樣式工作仍 required'),
('TASK-11','required；prototype/CSRUtil/RPTUtil 已直接使用；其餘載入副作用適用性待查','1（選先翻新且材料取得後）','DEP-03～10 只查本頁使用鏈、相關回呼/例外/監聽/全域副作用与必要間接資源','DEC-04 選擇；8腳本或適用版本契約未提供','序列化/請求/分流/訊息/下載與頁面生命週期；回查 TASK-02/03/04/08','直接调用語意、所有相關分支与事件作用範圍可證；不從函式名推條件；不適用有依據；受影響案例重驗','待決；材料也缺少；不自動翻新外部資源'),
]

choices=[
('DEC-01','TASK-01','首次啟動建立計劃與有限盤點，唯一根入口保持不變','依啟動授權完成計劃/盤點','task.txt 使用者啟動輸入；不含執行或擴充授權','已完成；不代表其他 TASK 選中'),
('DEC-02','DEP-01/11/19；TASK-09；TODO-01/11/19','header.jsp、msgDisplayer.jsp 与 ListOrderedMap 宣告來源未取得；影響入口情境、資源值與初始化訊息，library 是否影響待確認；根 inline 盤點可先做','待決：先翻新所需部分／本輪延後','沙盒未提供回答；資源缺失仍需證據，不能以選先翻新填猜測','选择先翻新需先補來源/契約，再 TASK-09；選延後需局部 TODO 連結与重新驗證'),
('DEC-03','DEP-02/12～16；TASK-10；TODO-02/12～16','cm.css 與 border_01/02/03.gif、ecblank.gif、icon_dot11.gif 未取得；影響全頁生效樣式、邊框/留白/標示；根 inline 顏色/尺寸可先記錄','待決：先翻新所需部分／本輪延後','未提供回答，未授權改用其他視覺風格','先補材料再 TASK-10，或經明确延後後保留局部 TODO；TASK-05 不改 optional'),
('DEC-04','DEP-03～10；TASK-11；TODO-03～10','8個 script 未取得；prototype/CSRUtil/RPTUtil 直接影響欄位序列化、回呼、訊息/例外与下載；PageUI/HotKey/Validator/calendar/date 的載入副作用待查；本地增刪/已知警示可先做','待決：先翻新本頁所需使用鏈／本輪延後','未提供回答；未用檔名/無直接呼叫代替行為證據','先補材料再 TASK-11，或確認延後後各受影響 FLOW/DATA/ST/BOUND 等局部標記'),
('DEC-05','DEP-17/18；TASK-03/08；TODO-17/18','未提供 backend_root/baseline；export/download 的 target wire/業務/授權/檔案與承接未知；可先盤點 legacy 觸發与移交','待決：提供並先核對後端基準／本輪延後 target API 工作','未提供回答；不查外部後端，不执行後端程式；部署狀態未確認','提供基準後 TASK-03；TASK-08 可先選；延後需明确紀錄与局部 TODO'),
('DEC-06','TASK-02～11','本輪任務選單已列分類、順位、前置、影響、狀態；TASK-02 与 TASK-08 可先執行；TASK-07 選用','待選：可回 TASK-02、TASK-08 或明確一組','截至本輪結束沒有任何執行任務選擇','維持待選；只继续啟動授權的計劃與檢查'),
]

plan='''# AF-AFY10400：翻新計劃

> 首次啟動的計劃交付；執行任務與依賴處理均待選。證據與實際檢查見 [tracking](tracking.md)。行為規格預期位置：`artifacts/design/AF-AFY10400/specification.md`（待建立）。

## 1. 初始範圍與順序

'''+table(['項目','內容'],[
('唯一根 JSP／scope','`inputs/frontend/sourceCode/AF/AFY10400.jsp`／AF-AFY10400；來源起點與 scope 由 manifest 指定'),
('版本','SHA-256 `'+sha+'`；只有快照版本，未讀案例外 Git'),
('建立時間與順序',initial+'；先檢查存在及 hash，建立 plan 后才讀 JSP 作有限盤點；[初始快照](plan.initial.md)、[實際順序](run-log.json)'),
('納入','根入口來源 metadata；直接資源、服務交接及必要間接未知的有限盤點；提供材料中的既有契約查找；任務選單与待決紀錄'),
('排除','未選擇的行為/API/移交/原型/CSS/tokens 生成；完整共用依賴翻新、另一入口內部行為；外部系統、案例外資料与既有產物；後端程式執行'),
('啟動与目前階段','`/legacy-to-spec jsp=inputs/frontend/sourceCode/AF/AFY10400.jsp`；首次啟動計劃与盤點完成，等待任務選擇'),
('工作順序','先建立計劃 → 盤點与查找 → required/optional 選單与依賴選擇 → 執行所選範圍 → 必要驗證 → 更新下一批選項'),
('既有授權','只有首次計劃/盤點授權；無執行任務、外部依賴扩充、延後或行為/樣式改良授權'),
('實際資料范围','task.txt、manifest.json、skill 及 inputs 的提供快照；inputs 只有根 JSP，无 inputs/specs 或提供 config；本 scope 不讀案例外索引/產物'),
('後端基準','backend_root、backend_contract 均 null；未選定版本、來源性質/適用環境，部署狀態未確認。只阻塞相應 API/業務主張'),
])+'\n\n### 範本与撰寫規則選用\n\n'
role_rows=[]
for role in ['plan','tracking']:
    r=selection['templates'][role]
    role_rows.append((role,'`'+str(Path(r['path']).relative_to(Path.cwd()))+'`；SHA-256 `'+r['sha256']+'`','builtin；保留必要欄位，初始 scope/搜尋/依賴/任務/決策/證據/檢查完整；无用户客製','skill 的 workflow/customization/dependencies/evidence/acceptance；來源解析與 api authority/backend-profile','TASK-01'))
role_rows.append(('design-md 与後續角色','[選用清單](template-selection.json) 中九角色含实际絕對路徑與 SHA-256','本輪只使用 plan/tracking；元件必須 DESIGN.md 与實際 CSS 雙份；tokens optional，未建立空產物','無補充 API/UI/domain reference；內建範本不授權改變樣式或互動','TASK-02～11'))
plan+=table(['角色/profile','選用檔案/雜湊','客製及必要資訊核對','規則与權威','影響/TASK'],role_rows)
plan+='''

## 2. 依賴與契約查找

<a id="dependencies"></a>

實際查找：`rg --files inputs` 只列出根 JSP；核對 `inputs/specs` 未提供，inputs 中無 Markdown/JSON/YAML 契約候選，也沒有本輪 config。以資源確切路徑/名稱与 scope 所需能力對照提供材料；詳見 [查找紀錄](contract-search.json)。未查案例外 artifacts、後端或其他工作區，因此結論僅是「提供範圍內沒有適用契約可核對」，不能宣告整個系統沒有規格。

manifest 列 `backend/docs/OPENAPI.md` 与 `backend/docs/specs/AFY1_0400/AFY1_0400_doExport.md`、`AFY1_0400_doDownload.md` 不可取得。`AFY1_0400_doPrompt.md` 亦不可取得；本 JSP 未找到 prompt 呼叫，故它只保留為未取得候選，未將其能力當作本頁契約或自動納入翻新。後端基準不存在於提供材料，沒有可用雜湊。

'''
dep_rows=[]
for i,d in enumerate(deps,1):
    ident,res,loc,need,impact,dec,task,e=d
    todo=f'TODO-{i:02d}'
    dep_rows.append((f'<a id="{ident.lower()}"></a>{ident}；{res}；版本/雜湊未取得',loc+'；E='+e,'inputs 全部提供快照；無候選文件/版本；[實際查找](contract-search.json)','不可取得；無可核對權威/版本/適用情境；相關間接依賴尚未盤點',need+'；'+impact,'待決，'+dec+'；停止於本 JSP 引入/调用；未先翻新，未延後',task+'；['+todo+'](tracking.md#'+todo.lower()+')'))
plan+=table(['DEP/資源与版本','引入條件/本頁關係','搜尋范围与候選','適用性/查找結果','本輪所需/影響','處理/停止邊界','TASK/TODO'],dep_rows)
plan+='\n\n## 3. Required／Optional 任務與影響\n\n<a id="tasks"></a>\n\n'
plan+=table(['TASK ID','分類/適用依據','建議順位','工作与明確範圍','前置依賴','影響/預期交付','完成條件与驗證','狀態/選擇'],[(f'<a id="{t[0].lower()}"></a>'+t[0],)+t[1:] for t in tasks])
plan+='''

required 与執行狀態分開；即使使用者之後延後必要工作，仍保留 required，完整交付前必須解決或如實部分交付。元件樣式双份与必要驗證不能轉为 optional。未分析的間接依賴與載入副作用不得先宣告不適用。

### 目前可選工作

建議先選 TASK-02（根 JSP 本地可證行为）與/或 TASK-08（legacy 邊界責任与移交）；二者在明示范围可獨立执行，未知依賴位置仍標 TODO、決策維持待決。這不是先同意延後共用依賴。TASK-04/05 待 TASK-02 与相關依賴前置條件；TASK-03 缺後端基準；TASK-09/10/11 需選先翻新並取得材料；TASK-06 隨所選產物驗證；TASK-07 為可另選的 DTCG 額外成果。

可回 `TASK-02`、`TASK-08` 或明確一組任務，並对 DEC-02～05 分組選「先翻新/取得基準」或「延後」。沙盒沒有後續回答，本輪只提供選單，維持待選與待決。

## 4. 任務選擇、依賴決策與對話紀錄

<a id="decisions"></a>

'''+table(['DEC/日期','DEP/TASK/TODO','告知内容与影響','選擇','決策來源/授權','下一步'],[(f'<a id="{d[0].lower()}"></a>'+d[0]+'；'+now,)+d[1:] for d in choices])
plan+='''

DEC-02～06 的实际選單內容另存 [本輪使用者回應](user-response.md)；未收到答案。不以等待時間、缺失材料或首次啟動當作延期/扩充/執行同意。

## 5. 計劃變更

'''+table(['日期/CHANGE','依據','依賴与影響變動','任務/順序','tracking'],[
(initial+'／CHANGE-01','task/manifest，入口存在/hash','分析前確立唯一入口和初始邊界','TASK-01 为啟動授權；其餘待盤點','[初始紀錄](tracking.md#changes)'),
(now+'／CHANGE-02','E-03～E-14；提供快照有限盤點','19 DEP；11項 manifest 共用前端資源、5圖片、2服務交接、1匯入線索；間接資源未取得','TASK-02/08 可先選；TASK-09～11 需决策/材料；TASK-03 缺後端基準','[增量紀錄](tracking.md#changes)'),
])+'\n'

# Evidence: source excerpts with byte-line basis; no claims of observed execution.
evidence=[
('E-01','文件','task.txt；manifest root_entry','首次輸入 `/legacy-to-spec jsp=inputs/frontend/sourceCode/AF/AFY10400.jsp`；無任務選擇或依賴決策','啟動計劃/盤點 scope、DEC-01/06','不支撐其他任務已授权'),
('E-02','文件','manifest.json：stage/ backend/ files/unavailable_inputs','stage=plan；backend_root/backend_contract=null；files 只有根 JSP 與 skill；11共用前端與4後端候選不可取得','提供範圍、停止邊界與資料缺失','不可推導實際部署或能力不存在'),
('E-03','metadata','[source-inventory.json](source-inventory.json)；原始 bytes SHA-256 `'+sha+'`','8966 bytes、246物理行、246 CRLF；utf-8 invalid@1152、cp950 strict valid','唯一來源版本/物理行號/严格解碼结果','成功解碼不單独證明精確原始編碼variant；不代表 runtime 成功'),
('E-04','原始碼','root L1、L7；同 E-03 hash','contentType charset=BIG5；meta charset=big5','宣告与 cp950 可讀中文相容；使用 strict cp950 在記憶體读取，無替換或修改','只支撐來源解析方式，不執行 JSP'),
('E-05','原始碼','root L2、L18、L27–31','include header.jsp / msgDisplayer.jsp；initApp 呼叫 displayMessage()','DEP-01/11；入口訊息调用關係','不能確認 include 輸出/訊息/受信任情境'),
('E-06','原始碼','root L9–16','8個 src：prototype、CSRUtil、PageUI、HotKey、Validator、RPTUtil、calendar、date','DEP-03～10 的載入与未確認副作用','只有三工具見明确本頁使用鏈；其餘未判定不適用'),
('E-07','原始碼','root L8、L116–124、L128–179、L188–228','cm.css 引入；五圖像引用；inline body/row 顏色与 class/尺寸存在','DEP-02/12～16；完整樣式任務必要','缺 CSS/圖像及 runtime，不代表最後 computed style 已確認'),
('E-08','原始碼','root L21–65、L116–124、L128','onLoad initApp；counter=0；增列四格；刪除指定列後 RowColor；初始化调用訊息','本地增刪与初始化的來源事实、TASK-02 可證邊界','未觀察浏览器；不能推導共用訊息内容'),
('E-09','原始碼','root L75–94','空字符串拒絕：第N列的被保人ID或保單號碼不得為空值，若不需要請刪除該列；相同ID拒絕：被保人ID：ID有重覆出現，請合併在同一列處理','inline 空值/重複分支、文案与 return 順序；TASK-02','不加入 trim、固定最少列或新增 Validator 規則；未執行'),
('E-10','原始碼','root L67–97、L187、L199–211','param 物件被建立；实际呼叫 post(export, Form.serialize(frm),...); 表單含 insrType/prodType、動態 I_ID/POLICY_NO','DEP-03/04/17 的 legacy 傳遞、TASK-08 責任/移交待分析','param 不等於已送payload；HTTP/wire/schema 与工具語意未取得'),
('E-11','原始碼','root L98–113','两回呼均从 resp.rtnMap 按當前 I_ID 回填第4格；第一回呼先回填，再 RPTUtil.downloadFile(...download,{fileName},false)','DEP-04/08/17/18；已知条件式回應消費与交接順序','回呼何時被觸發、服務结果、空值/例外及下載完成未知'),
('E-12','原始碼','root L146–147、L179、L191–220、L227','兩标题文字、畫面編號；承保/收件、個險/團險/意外險；Google Chrome/多组合分次匯出/Enter 分格說明；新增与匯出按鈕','根 JSP 可見静態内容与選項/預設、TASK-02','說明文字不单独證明後端約束；未呈現最終畫面'),
('E-13','原始碼','root L3；全根文字核對','ListOrderedMap 仅见 import，没有其他文字引用','DEP-19 的待查線索','不能判定 include 不使用，也不執行編譯'),
('E-14','原始碼','root L51、L187–246；文字結構掃描','動態 textarea 字串未见 closing textarea；根有 form 开标签而无 closing form','需后续核對 HTML parser/序列化實際結果，TASK-02/04/11 验证限制','仅來源结构異常，不宣告已觀測缺陷或擅自修正'),
]

tracking='''# AF-AFY10400：翻新執行與持續追蹤

> 本輪僅計劃與有限盤點；系統行為規格、API、移交、視覺原型、CSS 与 tokens 尚未建立。任務与選擇見 [plan](plan.md)。

## 1. 本輪來源与邊界

'''+table(['項目','內容'],[
('Scope ID','AF-AFY10400'),('唯一根入口','`inputs/frontend/sourceCode/AF/AFY10400.jsp`'),('根入口版本','SHA-256 `'+sha+'`'),
('編碼与行號基準','宣告 BIG5（L1/7）；CP950 strict 成功、中文可讀；UTF-8 strict 失败@1152；精確原始編碼variant未獨立證明。原始bytes splitlines=246、CRLF=246、8966 bytes；結尾換行不額外計數。只在記憶體解碼，行號一對一，無轉碼檔或原件修改；[metadata](source-inventory.json)'),
('分析日期与執行者',now+'；Codex 隔離試用'),('納入','根 JSP 全246行有限盤點；依赖引入/调用及材料查找；不詳細翻新缺失依赖'),('排除','外部/案例外來源、其他入口內部、後端執行；未選契約与视觉任务'),('本輪状态','計劃待選；計劃階段可驗收；不宣告系統契約完整'),('契約版本/上一輪','尚未建立；首次；沒有讀取先前產物'),('後端根/基準','未提供；候選 OPENAPI、doExport、doDownload、doPrompt 均無文件可核對；未指定 source nature/environment；部署狀態未確認'),('介接文件','預期 artifacts/integration/AF-AFY10400/api-spec.md 与 backend-handoff.md；依任務选择後才建立，無失效链接'),
])+'\n\n### 依賴分析邊界\n\n'
tracking+=table(['DEP/相依来源','版本/hash','任務/查證目的','实际讀取与停止邊界','分析結果','證據/TODO'],[(f'[{d[0]}](plan.md#{d[0].lower()})；'+d[1],'未取得；只能定位根入口 hash',d[6]+'；'+d[3],d[2]+'；只讀根引入/调用，不讀缺失資源','不可取得；間接依賴未盤點',d[7]+f'；[TODO-{i:02d}](#todo-{i:02d})') for i,d in enumerate(deps,1)])
tracking+='\n\n## 2. 計劃執行索引\n\n'+table(['任務/决策','实际操作与證據','交付/驗證','偏差/TODO'],[
('[TASK-01](plan.md#task-01)／DEC-01','先写 plan/初始快照，再 strict inventory、根246行有限盤點、inputs 查找；E-01～14','plan/tracking、template-selection、source-inventory、contract-search、run-log；V-01～04','無超出启动授权；缺失来源待决'),
('TASK-02～11／[DEC-06](plan.md#dec-06)','尚未執行；沒有選擇，不自動代選','沒有 specification/API/handoff/prototype/CSS/tokens 產物','必要任務仍必要；材料缺口见各TODO'),
('DEC-02～05','缺口分组与影響已於本輪 [使用者回應](user-response.md) 提供選擇','先翻新/延後/提供後端基準均待決','沒有把沉默當作延後；无缺口已解決'),
])+'\n\n## 3. 證據登錄\n\nroot = `inputs/frontend/sourceCode/AF/AFY10400.jsp`；所有 root 證據均採 E-03 的 SHA-256 与原始246物理行基準。E-05～14 為靜態來源觀察，並非瀏覽器或後端執行結果。\n\n'+table(['E-ID','類型','可定位來源/版本','最小事实摘錄','支撐主張/範圍','限制'],evidence)
tracking+='\n\n## 4. 來源到契約覆蓋\n\n'+table(['來源位置','事實類型','E','規格/原型去向','案例/處理'],[
('root L1–18','來源环境/include/import/style/script','E-04～07/E-13','尚未分配契約 ID；待 TASK-02/09～11','TODO-01～16/19；共用内容未取得'),
('root L21–65、116–128','初始化/新增/删除/逐列色彩重算','E-08','待 TASK-02/04/05；未生成規格或原型','本地源可分析；displayMessage 与最終樣式各有TODO'),
('root L67–97','驗證分支、欄位收集、表單序列化与請求','E-09/10','待 TASK-02/08/03/11','TODO-03/04/17；保留已知拒絕與順序'),
('root L98–113','回填/條件式下載交接','E-11','待 TASK-02/08/03/11','TODO-04/08/17/18；未知结果不裝作成功'),
('root L129–246','標題/說明/選項/初始表格/按鈕/版面圖像','E-07/12/14','待 TASK-02/04/05','TODO-02/12～16；結構異常需实际解析驗證'),
])+'\n\n這是計劃階段來源区段索引，不是全行為來源到契約完成率。提供源中的已知項目可定位；未知共用内容與其間接依赖沒有進入已確認覆蓋分母，不報完整覆蓋率。\n\n### 4.1 混合責任\n\n未執行详细 LOGIC 拆責任，待 TASK-08。已知交換/檢查/回填与受信任入口情境線索见 E-05/10/11；JSP 不支撑目標 API 已承接。\n\n### 4.2 API 与後端移交\n\n未生成 API/HANDOFF 契約 ID；DEP-17/18 缺基準。TASK-08 可先盘点 legacy 所需能力与責任，TASK-03 须基準才能核對目標交換。\n\n### 4.3 樣式与範本\n\n本輪实际採用 plan/tracking 两個內建角色；hash 見 [template-selection.json](template-selection.json)。style_profile=design-md；後續有樣式元件必須 DESIGN.md 与實際CSS 雙份。無元件/CSS/prototype，故沒有 computed style 的實测結果；TASK-05/06 未執行。\n\n## 5. TODO 与契約缺口\n\n各缺口為「未知/缺少依賴、待決」，不是已延後。ID 按首次盘点固定。尚無設計契約，受影響位置先指根源位置；產生契約後才補 FLOW/CMP/UI/BOUND/DATA/ST 等实际局部 TODO 錨点，不捏造空 ID 或預期链接。\n'
for i,d in enumerate(deps,1):
    ident,res,loc,need,impact,dec,task,e=d
    todo=f'TODO-{i:02d}'
    tracking+=f'\n### {todo}\n\n<a id="{todo.lower()}"></a>\n\n'+table(['欄位','內容'],[
('類型/狀態','未知/缺少依賴；開啟、待決；沒有先翻新/延後回答'),
('具體問題',need),('已知事实/證據',ident+'；'+res+'；'+loc+'；'+e),('影響',impact+'；尚未建立契約 ID'),
('下一個動作','提供該資源的適用來源版本或已有契約；按 '+dec+' 選先翻新/延後，再於 '+task+' 核對本頁所需部分；本次沙盒不能取得額外材料'),
('解決條件','可定位適用版本/權威提供所需内容，更新所有受影響契約位置与映射，完成對應來源/互動/樣式/跨邊界必要驗證；無回答不閉合'),
('依赖/後續','[依賴 '+ident+'](plan.md#'+ident.lower()+')；必要間接依賴待查；若另有 JSP 入口需另 scope，不擴本 scope'),
('任務/決策/後續順序','['+task+'](plan.md#'+task.split('/')[0].lower()+')／['+dec+'](plan.md#'+dec.lower()+')；取得資料→適用性/所需契約→引用到根入口→重驗影響範圍'),
('解決紀錄','尚未解決'),
])+'\n'
tracking+='\n### 5.1 缺口位置与計劃核對\n\n'+table(['TODO/DEP','受影響实际位置','局部TODO锚点','TASK/DEC','回讀结果'],[(f'TODO-{i:02d}/'+d[0],d[2]+'；'+d[4],f'[本次實際TODO](#todo-{i:02d})；設計/原型待建立，無可驗局部契約錨点',d[6]+'／'+d[5],'tracking/plan 已回讀核對，V-04；設計位置尚未建立/未執行，不能宣告完成') for i,d in enumerate(deps,1)])
tracking+='\n\n## 6. 原有缺陷与改良提案\n\n'+table(['項目','来源觀察','提議變更','決定','影响'],[
('HTML 結構待驗證','E-14：動態 textarea/根 form 未见閉合','沒有提出或實施修正；先核對 legacy browser 解析与序列化','未確認為运行缺陷；沒有行為改良授權','TASK-02/04/11/06；若需改良另建決策，保留原觀察'),
('傳遞資料來源待拆解','E-10：构造 param，post 实际使用 Form.serialize(frm)','不改为 param 或自行正規化；先取得工具契約','沒有修改傳遞行為','TASK-08/11/03；TODO-03/04/17'),
])+'\n\n## 7. 驗證執行与交付判定\n\n'+table(['V-ID','依據檢查','環境/操作','预期','实际結果','結果','TODO'],[
('V-01','入口/source metadata','隔离案例；strict inventory 读取原始bytes，核对hash、246原始行；查看L1/7与可讀中文','唯一 root 与 manifest hash一致；引用行號在1～246','8966 bytes、246 CRLF；hash匹配；UTF-8无效@1152、CP950严格成功；宣告BIG5','通過（encoding exact variant仍有限制）','精確variant未獨立證明，不影響可讀盤點'),
('V-02','先計劃後分析','先写 plan 与 plan.initial 再取得inventory/讀246行；actual run-log','有事前计划与先后纪錄','initial='+initial+'；初始快照寫尚未分析；后续盘点更新并保留快照','通過','無'),
('V-03','依賴/查找边界','rg --files inputs；输入契約类型与目录核對；root引入与调用扫描','全部可定位依賴、查找范围与未取得事实可追踪','2 includes、1 CSS、8 scripts、5 images、2 service交接、1 import線索，共19 DEP；無提供契約候選','通過（有限盤點）','TODO-01～19；間接內容未取得'),
('V-04','計劃交付靜態检查','只回讀本次產物；检查表格列宽、19 DEP/TODO、11 TASK、6 DEC、hash、引用range/anchors/local文件及无placeholder；见 checks.json','必需列与状态/锚点有效，无虚构已選/已延後，无生成未选产物','本次实际检查报告 [checks.json](checks.json)；结果以報告为准','见报告；通过后維持計劃待選','设计/原型局部TODO查验未执行'),
('V-05','所選契約/原型/API/服務驗證','未執行：沒有任务选择；没有已生成契約/原型/目标后端基準；不运行JSP/後端','后续按选项与适用环境执行','無浏览器截图、computed style、真实导出下载或目標端介接结果','未執行（计划阶段预期）','TASK-02～11；TODO-01～19'),
])+'\n\n### 本輪結論\n\n- 已确认与驗证：唯一快照、source metadata、计划先行、有限依赖/契約查找、選單字段及文件静態引用；V-01～04。\n- 待選/待決：TASK-02～11 无执行选择；DEC-02～05 共用依賴/后端處理无回答；19 TODO未解。\n- 本轮属于計劃交付，不是系統契約完整或正式後端介接交付。沒有規格/原型是首次阶段预期，后续必要缺口未解或驗證不足只可部分交付。\n- 來源服務能力、部署與共用元件内部行为未確認，不能由缺快照否定其存在。\n\n## 8. 增量与變更紀錄\n\n<a id="changes"></a>\n\n'+table(['CHANGE/日期','來源差異','證據','契约/原型','TODO','验证'],[
('CHANGE-01／'+initial,'首次入口hash锁定','E-01/02；事前计划','未建立','未盘点','V-02'),('CHANGE-02／'+now,'來源hash未变；严格解碼盘点','E-03～14','仅plan/tracking更新；无行为契約/原型','TODO-01～19 开启待決','V-01/03/04；V-05未执行')
])+'\n'

response='''已為唯一入口 `inputs/frontend/sourceCode/AF/AFY10400.jsp`（AF-AFY10400）完成首次計劃与有限依賴盤點，先建立計劃再讀取來源。入口共246行；提供材料只有這份JSP，沒有可重用依賴契約或後端基準。现在停在 skill 的首次任務選擇關卡。

計劃見 [plan](plan.md)，來源/缺口/檢查見 [tracking](tracking.md)。以下所有後續任務都尚未選中：

'''+table(['TASK','分類','順位与工作','前置/狀態','影響'],[
('TASK-02','required','1：根 JSP 已知畫面、列增刪、檢查/回填與流程規格','可先執行；缺共用内容留局部TODO，依賴决策保持待決','specification 与 DATA/ST/FLOW/案例'),
('TASK-08','required','1：legacy 匯出/下載邊界与責任/移交','可先執行；不聲稱目標API已承接','legacy 傳遞、顺序、HANDOFF/缺口'),
('TASK-09','required（library適用性待查）','1：入口/共用訊息本頁所需契約','待 DEC-02 與缺失來源','初始化/資源基底/受信任情境/訊息'),
('TASK-10','required','1：共用 CSS 与5圖片所需契約','待 DEC-03 與缺失來源','全頁生效樣式/邊框/圖像'),
('TASK-11','required（未直接使用腳本的作用待查）','1：8腳本的本頁使用鏈与相關副作用','待 DEC-04 與缺失來源','欄位序列化/回呼/錯誤訊息/下載/鍵盤生命週期'),
('TASK-03','required','1取得基準；TASK-02/08後完成API映射','阻塞：後端基準未提供；DEC-05待決','匯出/下載 wire、業務、授權与两端映射'),
('TASK-04','required','2：已知畫面/互動離線原型','TASK-02後；相關共用呈現/腳本内容待決','視覺/互動/中間狀態'),
('TASK-05','required','2：元件DESIGN.md与實際CSS雙份','TASK-02後；CSS/圖片等決策与材料未取得','樣式值/狀態/原型載入一致'),
('TASK-06','required','3：所選产物覆盖/引用/互動與適用介接驗證','所選產物完成後；尚無契約/原型','tracking、實際驗證、部分/完整判定'),
('TASK-07','optional','3：DTCG tokens','TASK-05後；可额外选择','額外可攜樣式值，不取代必要CSS'),
]) + '''

TASK-01（required，順位0，首次計劃/盤點）已依啟動授權完成。每項完成條件与驗證方法详见plan。

未取得的依賴请分别選「先翻新所需部分」或「延後」；先翻新仍需提供材料，不能填猜測：

- DEC-02：DEP-01/11/19，`/html/CM/header.jsp`、`/html/CM/msgDisplayer.jsp`、`ListOrderedMap` 匯入线索。入口情境/資源值、初始化訊息与library适用性未确认。
- DEC-03：DEP-02/12～16，`cm.css`、`border_01.gif`、`border_02.gif`、`border_03.gif`、`ecblank.gif`、`icon_dot11.gif`。影響全頁最終生效樣式、邊框、留白与面板圖像。
- DEC-04：DEP-03～10，`prototype.js`、`CSRUtil.js`、`PageUI.js`、`HotKey.js`、`Validator.js`、`RPTUtil.js`、`calendar.js`、`date.js`。欄位序列化、回呼分流、共用錯誤訊息/例外与下載語意未知，部分脚本載入副作用待查。
- DEC-05：DEP-17/18，legacy `AFY1_0400` 匯出与下載。後端 path/method/schema、業務/授權/檔案、承接与部署未確認；可選「提供基準後先核對」或「本輪延後目標API」。

可先回 `TASK-02`、`TASK-08` 或明確一組任务，另附 DEC-02～05 的選擇。建議先做 TASK-02 与 TASK-08 的本地已知部分；這不表示同意延後依賴。沒有答案時保持待選/待決。

本次只執行來源 metadata、靜態盤點与文件/链接检查；没有执行JSP或後端，也未生成行為規格、API、移交、原型或CSS。尚未確認的共用/後端行为维持未知。
'''
(base/'plan.md').write_text(plan)
(base/'tracking.md').write_text(tracking)
(base/'user-response.md').write_text(response)
(base/'dependency-inventory.json').write_text(json.dumps({'schema_version':1,'scope_id':'AF-AFY10400','root_sha256':sha,'dependencies':[{'id':d[0],'resource':d[1],'root_location':d[2],'required_knowledge':d[3],'impact':d[4],'decision':d[5],'tasks':d[6],'evidence':d[7],'todo':f'TODO-{i:02d}','availability':'not supplied','contract_applicability':'not assessable; no candidate supplied','decision_status':'pending','stop_boundary':'root references only'} for i,d in enumerate(deps,1)],'limits':['Indirect dependency content unavailable.','No dependency expansion or deferral authorized.']},ensure_ascii=False,indent=2)+'\n')
(base/'run-log.json').write_text(json.dumps({'scope_id':'AF-AFY10400','events':[{'event':'initial-plan-created','at':initial,'dependency_analysis_started':False,'source':str(source_path),'sha256':sha},{'event':'dependency-analysis-and-input-contract-search','after':initial,'source_lines':246,'root_only':True,'unavailable_dependency_count':19},{'event':'plan-and-choice-menu-completed','at':now,'selected_execution_tasks':[],'dependency_decisions':'pending','generated_contracts':[]} ]},ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'written':['plan.md','tracking.md','user-response.md','dependency-inventory.json','run-log.json'],'dependency_count':len(deps),'task_count':len(tasks),'decision_count':len(choices),'completed_at':now},ensure_ascii=False))
