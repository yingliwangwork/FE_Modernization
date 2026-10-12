from pathlib import Path
import json, hashlib
S='AF-AFY10400'
D=Path('artifacts/design')/S; I=Path('artifacts/integration')/S; R=Path('artifacts/renovation')/S
for p in [D/'prototypes',D/'styles',I,R]:p.mkdir(parents=True,exist_ok=True)
def write(p,t):p.write_text(t.strip()+'\n')
def todo(n,detail=''):return f'[{n}](../../renovation/{S}/tracking.md#{n.lower()})'+('：'+detail if detail else '')
def E(n):return f'[E-{n:02}](../../renovation/{S}/tracking.md#e-{n:02})'

deps=[
('DEP-01','CM/header.jsp','首次載入；設定、可信情境、政策與浮水印','無 inputs/specs；本頁必要片段先轉換','CMP-POLICY、FLOW-08、DATA-07、BOUND-03/04、ST-06','TASK-03；TODO-01/04','E-06/07/08'),
('DEP-02','CM/msgDisplayer.jsp','首次訊息及全文件按鈕點擊清底部訊息','無 inputs/specs；必要片段先轉換','CMP-ENTRY、FLOW-01/07、DATA-06、ST-05','TASK-03；TODO-01/03','E-09'),
('DEP-03','CM/js/ajax/prototype.js','實際序列化、請求／回應生命週期','無既有前端契約；必要片段先轉換','FLOW-04/05/06、DATA-03、BOUND-01','TASK-03','E-10'),
('DEP-04','CM/js/ajax/CSRUtil.js','請求遮罩、判定、各訊息分支、例外與拖曳','無既有前端契約；必要片段先轉換','CMP-COVER/MESSAGE、FLOW-05/06/09/10、ST-03/05','TASK-03；TODO-01/03','E-11/12/13'),
('DEP-05','CM/js/ui/PageUI.js','載入註冊及 resize；根頁無 createPage 呼叫','無既有契約；核對本頁必要生命週期','FLOW-01；根頁自行排版','TASK-03','E-14'),
('DEP-06','CM/js/HotKey.js','全文件 keydown 註冊；根頁未綁定快捷鍵','核對註冊，不增加功能鍵','FLOW-01、CMP-POLICY','TASK-03','E-15'),
('DEP-07','CM/js/Validator.js','只載入定義；根頁不調用 Validator','核對初始化，不生成證號格式檢核','BR-01/02','TASK-03','E-16'),
('DEP-08','CM/js/RPTUtil.js','成功回填後同步取得下載參數並隱藏表單交接','無既有契約；先转換必要下載鏈','FLOW-05、BOUND-02、DATA-05','TASK-03/05；TODO-02/04','E-17'),
('DEP-09','CM/js/calendar.js、CM/css/ui/calendar.css','載入時條件插入 calendar CSS；無根頁日曆欄位','JS 可取得必要片段先轉換；CSS 未提供，延後','CMP-PAGE、UI-01..10；繼承／cascade','TASK-03/08；TODO-05','E-18'),
('DEP-10','CM/js/date.js','被載入；具體行為未建立','兩候選嚴格解碼失敗，延後分析','FLOW-01、CMP-PAGE、所有 UI；未知載入副作用','TASK-08；TODO-06','E-19'),
('DEP-11','CM/css/cm.css','全域字型、button 最終 :root padding、表格與欄位','無既有契約；先轉換所有本頁可匹配規則','CMP-PAGE/FORM/MESSAGE、STYLE','TASK-03/06；TODO-05','E-20'),
('DEP-12','CM 圖片、cover png/gif、EUDC fonts、watermark-js-plus.js','標題邊框／小圖、遮罩、難字及條件浮水印','inputs 未提供，依 DEC-01 延後','CMP-PAGE/COVER、UI-01/02/09、ST-03/06、DATA-07、BOUND-04','TASK-08；TODO-04/05','E-02/08/11'),
('DEP-13','CXL:csCommon、功能資訊／session／utility、底部 frame、WIUtil/jQuery','間接設定、可信身分、條件訊息、清除／顯示、計時','inputs 未提供；只轉換呼叫端已知契約，缺內部延後','CMP-ENTRY/POLICY/MESSAGE、FLOW-01/06/07/08、DATA-06/07/08、BOUND-03/04','TASK-08；TODO-01/03/04','E-06/07/09/11'),
('DEP-14','inputs/backend/docs/OPENAPI.md §1/2/6/10','目標 export/download；prompt 只有歷史入口初始化線索','指定基準重用，0.0.1-SNAPSHOT，2026-08-12；stub header 已標明','API-01/02；API-03 未消費；BOUND-01/02','TASK-05；TODO-02/03/04','E-21/22'),
('DEP-15','inputs/backend/docs/specs/AFY1_0400/*.md','舊業務語意、檔案、逐列結果與安全日誌','重用為 legacy 語意依據，不將之升格目標 HTTP','HANDOFF-01/02/03/04、BOUND','TASK-05；TODO-02/04','E-23/24/25')]
p=R/'plan.md';t=p.read_text();t=t.replace('尚未讀取來源；TASK-01 執行後補確切 DEP、搜尋範圍、適用性、影響及決策。','''搜尋僅使用 `inputs/` 檔案清單與確切資源位置；`inputs/specs/` 不存在，沒有可重用前端共用契約。所附 backend docs 是選定後端傳輸基準／legacy 方法語意，逐項核對後引用。這個查找結論只適用於本快照。版本逐檔見 [source-inventory.json](source-inventory.json)；原始 bytes 行號基準，前端 CP950（date.js 未確認）、後端 UTF-8。

| DEP／資源 | 引入條件與所需行為 | 查找／適用性 | 影響 | 處理及後續 | 證據 |
| --- | --- | --- | --- | --- | --- |
'''+''.join('| '+' | '.join(row)+' |\n' for row in deps))
t=t.replace('實際 DEP 影響待 TASK-01 盤點；不得讀其他案例、既有產物或外部系統。','''實際適用 DEP-01 至 DEP-15；已於工作訊息告知 date 編碼、訊息／下載介接差距與缺少 header 依賴，並在本表展開每筆影響；不得讀其他案例、既有產物或外部系統。

DEC-02：重用 DEP-14 的目標傳輸基準及 DEP-15 的 legacy 語意；二者版本／用途不同，差異保留 TODO-02/04。DEC-03：DEP-01..09/11 的必要可取得片段先建立 [本頁共用契約](../../design/AF-AFY10400/common-contracts.md)，不翻新其其他入口或整套函式庫。DEC-04：DEP-09 的缺 CSS、DEP-10、DEP-12/13 的未提供部分依 task 模擬決策延後；逐項 TODO-01..06 不作正式範圍扩充。''')
t+= '''\nCHANGE-02：2026-10-12，TASK-01 來源盤點後補 DEP、決策；共用契約在根頁規格前生成。後續 TASK-08 依序取得功能情境／訊息 frame／下載承接契約（TODO-01..04）、缺少樣式與可解碼 date（TODO-05/06），最後以實際瀏覽器核對（TODO-07）。每筆條件及受影響 AC 見 tracking。\n'''
write(p,t)

common='''# AF-AFY10400：本頁必要共用契約

契約 v1，僅支撐唯一根入口；本頁使用定義先於根頁規格生成。來源 hash、原始行號與 E 定義見 [tracking](../../renovation/AF-AFY10400/tracking.md)。不是全系統元件標準；未提供的間接依賴仍保留局部缺口。

## CMP-ENTRY：入口訊息與底部交接

首次顯示時依序尋找上層的左側內嵌底部、父層左側內嵌底部、上層底部、父層底部。若找到回復頁面旗標，清旗標後停止，連警示也不顯示；否則若接收者可顯示通知，僅傳第一筆訊息的代碼及描述，接著逐筆組裝入口警示。描述、編號、異常中的各種換行正規化後顯示；空值成空文字。代碼不是 0/99 且無異常時組成「訊息說明:\n描述\n」，非空編號再接「\n錯誤編號：\n編號」；有異常時組成「異常原因:異常\n\n程式ID:系統\n\n」。若 WIUtil 和 jQuery 均已載入，交给 WIUtil；否則使用原生警示。E-09。

全文件點擊的實際目標，其 type 在 `button,submit` 中匹配時，嘗試清除底部通知；包含新增、刪除、匯出，發生在按鈕本身反應後的冒泡階段；清除介接異常被吞下。自訂訊息確認按鈕停止冒泡，不清底部訊息。底部視覺與旗標合法來源為 [TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)；WIUtil 內部為 [TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)。不得把底部替身當產品區塊。

## CMP-REQUEST：請求、回應與共用訊息

有 Prototype 時使用其分支：送出前增加活動記錄、顯示頁面遮罩；本入口未設定逾時，因此不自行追加時間限制。收到 HTTP 成功的已解析回應先以舊訊息代碼 0 選擇成功回呼，其他／沒有舊訊息選拒絕回呼，已解析內容未定義則直接停止回呼。回呼結束才執行完成處理；回呼例外先觸發診斷警示，完成處理仍可能繼續。HTTP 失敗未配置本頁拒絕回呼，但完成處理仍可顯示文字內容。E-10/11。

完成處理先讀回應；沒有解析物件且有文字時從精確 `<body>` 區段取文字，僅 `<br>` 轉換為換行，沒有 body 開頭則用整段；這是代碼 -1 的錯誤訊息。接著活動記錄減一、調整遮罩、清除本請求已存在的逾時計時器；未有訊息時僅在活動請求數 0 且無訊息活動記錄時隱藏。描述以字面反斜線+n 分割、累積再去頭尾空白；通知送底部，整數代碼 0 為藍色，其餘整數紅色，非整數代碼使用藍色。底部內部未知 [TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)。E-11。

位置符合 L.、R.、J.、DS、DZ、QB、AN、EP、ZU 的 Web 系統模式時：錯誤使用自訂訊息；錯誤編號非空且長度 >17 加「錯誤編號：\n編號\n訊息說明：\n」，再接描述；成功非空描述通常也用自訂訊息，EP 只隱藏無活動遮罩；空描述／關閉成功訊息則在無訊息活動時隱藏。其他系統模式：無訊息活動時先隱藏遮罩；錯誤永遠原生警示，長編號加「錯誤編號：\n編號\n」，再加「訊息說明：\n描述」；成功描述非空、沒有底部接收者且成功訊息開啟時原生警示「訊息說明：\n描述」。選用情境未知 [TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)，已知分支不可省略。E-11/13。

沒有 Prototype 而有 jQuery 的分支先共用／替代遮罩；HTTP 成功但沒有舊訊息時不呼叫本頁回呼；錯誤先顯示 WIUtil／原生訊息（長編號 >17 前綴沒有「訊息說明：」），再成功／拒絕回呼；完成時依條件收遮罩。相對於 Prototype 的順序不同，不能合併成一條。根入口明確載入 Prototype，但其載入是否成功及外部程式強制切換的情境未知；保留條件式反應。E-11；[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)。

診斷警示原文開頭「Error :\n」，後接「url : 請求位址\nparams: 請求參數\nException: \n」，逐項追加例外屬性「屬性=值\n」。不將異常偽裝為匯出成功。E-11。

## CMP-MESSAGE：自訂訊息生命週期

null／未定義／空字串正規化為灰色「(無訊息內容)」；其他值轉成文字，把字面反斜線+n 與換行轉為換行顯示。依正規化後完整內容去重，保留首次加入順序；連續新訊息以換行串接，重複訊息仍重定位與聚焦。首次寬度為正規化訊息（含呈現標記）長度×15，限 180–600px；後續以同公式僅增長不縮小，內容寬小於 588px 才可能增長。每次顯示位置為 body 高四分之一加捲動距離、水平居中加捲動距離。遮罩顯示、確定按鈕聚焦。E-12。

首次顯示註冊一個 document keypress 監聽，每個註冊實例在第一次任何鍵時先解除自己；若該首鍵是 Enter/Esc/空白且訊息仍在文件中則按確定並阻断；其他首鍵不關閉，此後第二鍵不再使用該監聽。按確定：停止冒泡、移除視窗、減少活動、無活動時隱藏遮罩、清除累積內容、最後執行已設定的確認回呼。按鈕關閉本身不解除此前 keypress 監聽，因此關閉重開可能留多個實例，不能改成共用變數解除新監聽。E-12。

標題按下時暫停新的按下監聽，保存指標相對视窗偏移、建立同寬高位置的拖曳框並註冊 document 移動／放開；移動阻斷事件、框隨偏移移動、真視窗移出；放開時解除兩監聽、取框位置移動真視窗、移除框、重新註冊按下。E-12。相關視覺檢查未執行 [TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07)。

## CMP-POLICY：條件式全頁政策與可信情境

功能資訊查詢可帶出 print/download 政策及浮水印開關；本頁是否啟用不能從名稱推論。[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)，E-06/07/08。啟用政策時在 load 註冊 body contextmenu、print、beforeprint、copy、cut 及 window keydown，捕获階段作用於全頁；右鍵阻断但無固定警示。Ctrl+A/X/S/P 阻斷并分别警示不开放全選／剪下／頁面儲存／列印；body cut／print／beforeprint 同樣阻断警示；列印樣式隱藏全部 body 子元素、顯示「依據資安政策，不開放列印功能」。copy 不阻斷：取選取內容，textarea 用其選取區間，其餘用文件選取；所有連續空白壓成一個空格。非空且與上次正規化內容不同時，建立獨立 60000ms 計時器清除上次內容、立即保存正規化全文，超過 5000 字截成 4997 加 ...，按 `% # & 空格 + ? =` 順序編碼，交接內容、功能識別、原正規化長度、時間；同內容不送。舊計時器不取消：t0 複製 A、t30 複製 B、t60 的 A 計時器會清除 B 的去重記錄。外部記錄承接为 [TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)。E-07。

浮水印已知傳入可信員工識別（為空則名稱、再空文字）、服務端時間；同源 mainFrame 重設功能清單；條件啟用時選擇 root、記錄功能 ID、設置多行、190×85、20 行高、黑色、16px、Microsoft JhengHei、17°、alpha .07、grid 2×2 矩陣及保護旗標。具體庫輸出未知 [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)。來源的 berforeunload 拼字與回呼登錄不一致保留在 tracking 缺陷，不自行改生命週期。E-08。

## CMP-DOWNLOAD：舊下載交接

成功回填之後，同步送出檔名取得下載資訊；收到舊成功訊息時，將加密下載檔名及完整路徑交給隱藏的 POST 表單，false 表示不建立新視窗；接收者責任到表單送出為止。若取得失敗，本頁沒有另加逐列或通用成功提示。依瀏覽器 Safari 非 Chrome 才延到同步請求返回後送出；根頁說明指定 Chrome。正式下載接收者及目標 binary 介接差距 [TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)、[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)。E-17。

## 載入但本頁未使用的能力與樣式邊界

E-14：PageUI load 只在存在外部 init 時調用，注册 resize；本頁沒有建立它的 table 或 overDiv，故這兩種 resize 會直接停止，不生成另一個畫面殼。未知外部 init 仍 [TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)。E-15：快捷鍵表初始為空，本頁沒有綁定，不新增 F 鍵功能。E-16：驗證庫只提供函式，未在本頁呼叫，不將證號驗證當要求。E-18：日曆載入可寫入 CSS，根頁無日曆调用／日期欄位，內部日曆不翻新；缺失 CSS 仍可能影響全域 cascade，[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)。date.js 無可確認解碼及載入副作用，[TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06)。
'''
write(D/'common-contracts.md',common)

# Technical neutral root specification.
spec='''# 公會通報下傳作業：前端系統行為規格

| 項目 | 內容 |
| --- | --- |
| Scope／版本 | AF-AFY10400／v1，部分契約 |
| 功能邊界 | 單頁選擇收承方式與商品屬性、維護被保人及多筆保單、逐列檢查、接收逐列匯出結果、交接下載 |
| 連結 | [證據與追蹤](../../renovation/AF-AFY10400/tracking.md)、[本頁共用契約](common-contracts.md)、[原型](prototypes/SCR-01.html)、[API 消費](../../integration/AF-AFY10400/api-spec.md) |

## 1. 意圖、邊界與觸發者

INT-01：使用者對同一組收承方式與商品屬性，把同一被保人的多筆保單集中一列，分組匯出供下載；多種組合需分次匯出。畫面说明要求 Google Chrome，多筆保單以 Enter 分隔。E-02/03；匯出 Excel 意圖有 E-23 文件依據。

ACT-01 為頁面使用者，可新增、刪除及匯出；ACT-02 為入口生命週期；ACT-03 為服務回應；ACT-04 為外層通知／政策情境。來源沒有證明本頁可取代服務端授權。[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)：可信情境与目标承接未確認，E-06/07/08。

BOUND-01 匯出、BOUND-02 下載、BOUND-03 複製軌跡、BOUND-04 可信情境／浮水印為已知交接。其他入口內部、業務查詢与檔案生成由接收者負責，不在前端重製。

缺口索引：TODO-01 入口／底部／外部初始化；TODO-02 回應與下載契約差距；TODO-03 共用訊息分支情境與 WIUtil；TODO-04 可信功能政策與外部後端責任；TODO-05 未提供樣式、圖片、字型及浮水印庫；TODO-06 date 載入副作用；TODO-07 瀏覽器與正式服務未驗證。詳細均在 [tracking 缺口](../../renovation/AF-AFY10400/tracking.md#todo-01)；以下受影響位置各自引用。

## 2. 資料語意

| ID | 語意與概念型別 | 允許值、必填、初始與生命週期 | 證據／局部缺口 |
| --- | --- | --- | --- |
| DATA-01 | 收承方式，文字代碼 | 依序 L=承保、R=收件；初始 L；單次匯出共用一值 | E-03 |
| DATA-02 | 商品屬性，文字代碼 | 依序 AT=個險、BG=團險、CB=意外險；初始 AT | E-03 |
| DATA-03 | 有序被保人列集合 | 初始 0 列；每列 ID 文字最多 10 字、保單多行文字無來源最大長度；新增空列、刪除只移除指定列；匯出有列時兩者皆不得精確空字串；前端不 trim、不驗證合法證號，空集合可走交接 | E-01/04；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)：目標空集合／換行业务規則未完整確認 |
| DATA-04 | 每個被保人的結果文字映射 | 回應後以當時現有列的當時 ID 找結果；成功與拒絕均填；新增列結果為空，既有結果不因修改輸入、重新送出、增刪其他列自動清除 | E-04/05；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)：目標拒絕 data=null 无逐列结果 |
| DATA-05 | 匯出檔名與下載交接資訊 | 成功回應帶檔名，先回填列再立即交接下載；前端不自產檔名、日期或加密路徑 | E-05/17；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)：旧参数链与目标 binary 不同；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)：接收者承接 |
| DATA-06 | 入口／非同步訊息、底部旗標 | 入口描述、編號、系統、類型、URL、回傳碼、異常为有序集合；含換行与空值正規化；底部回復旗標消费後清空 | E-09/11；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)：来源机制与底部；[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)：分支选择／WIUtil |
| DATA-07 | 可信功能政策、員工識別、服務端時間 | 決定列印／複製政策及浮水印；不得成為可任填產品欄位 | E-06/07/08；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)：合法來源与目标承接；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)：庫與字型 |
| DATA-08 | 複製去重記錄與獨立到期事件 | 去除連續空白后的上次全文；不同非空复制建立獨立 60 秒到期，舊到期不取消 | E-07；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)：外部記錄承接 |
| DATA-09 | 列識別計數，非可見整數 | 首次載入 0，每次新增先加一；刪除不倒退、不復用；与画面順序分離 | E-01 |

## 3. 邊界互動

| ID | 觸發、輸入與責任 | 接收結果、可見反應与停止邊界 | 證據／缺口 |
| --- | --- | --- | --- |
| BOUND-01 | FLOW-04 檢查通过，向匯出責任者交付 DATA-01/02 及 DATA-03 两个有序並行集合；換行保持每列多筆語意 | FLOW-05 逐列回填；檔案查詢／生成責任属接收者 | E-04/05/10/22；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) 回應差距；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) 稽核承接 |
| BOUND-02 | FLOW-05 成功回填後立即交付 DATA-05 | 舊交接取得加密資訊後交同頁檔案接收者、不新開視窗；目标已确认直接檔案回應，转换选择未確認 | E-05/17/22；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)、[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) |
| BOUND-03 | FLOW-08 啟用政策下复制與上次不同非空内容；传送 DATA-08 内容、功能、原長度、時間 | 紀錄接收後的結果未知；不能宣稱稽核已寫入 | E-07；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) |
| BOUND-04 | 首次載入接收 DATA-07，依政策條件顯示浮水印與全頁限制 | 功能設定与浮水印實際輸出未知，條件分支的已知反應保留 | E-06/08；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)、[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) |

## 4. 畫面、元件與元素

SCR-01：頂部「公會通報下傳作業」、右側「畫面編號：AFY10400」，下方「公會補通報作業」，依序三行操作說明、組合選項、資料表標題及匯出按鈕。原画面宽 97% 主框、标题 30 高；資料列欄位依序刪除、被保人 ID、保單號碼、匯出結果；初始沒有資料列。E-02/03。

| UI | 標籤／順序與操作 | 已知條件与尺寸 | 證據／局部缺口 |
| --- | --- | --- | --- |
| UI-01 | 畫面標題、編號 | 無操作；頂部全寬 | E-02；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 圖片／難字及後載 CSS |
| UI-02 | 公會補通報作業及三條說明 | Chrome、組合分次、Enter分隔的原文；红字 Chrome/Enter | E-03；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 圖示與後載 CSS |
| UI-03 | 收承方式選項 | DATA-01；標籤／值区各 20% | E-03；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 繼承 cascade |
| UI-04 | 商品屬性選項 | DATA-02；標籤20%、值40% | E-03；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 繼承 cascade |
| UI-05 | 被保人 ID 標題内「新增一列」 | FLOW-02；沒有自動聚焦依據 | E-01/03；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) cascade |
| UI-06 | 每列「刪除此列」 | FLOW-03；無確認提示；其他列保持 | E-01；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) cascade |
| UI-07 | ID 输入、保單多行输入 | ID size12、max10；保單 rows3 cols30；不默认修剪 | E-01/04；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 字型/cascade |
| UI-08 | 每列匯出結果 | DATA-04；按回應時現有 ID；原呈現容許换行標記 | E-05；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) 拒絕结果／目標文字呈現差距；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) cascade |
| UI-09 | 「匯出檔案」与等待遮罩 | FLOW-04；等待遮罩阻隔指標，未禁用控制／未增加取消操作 | E-03/11；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 遮罩圖像/cascade |
| UI-10 | 原生提示、条件自訂「網頁訊息／確定」 | FLOW-06/09/10；底部為外部元件，不自創本頁區塊 | E-09/11/12；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01) 底部；[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03) 選用/WIUtil；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 繼承；[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07) 實測 |

所有 UI 的載入副作用亦受 [TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06) 未解碼依賴影响，此為共用 CMP-PAGE 定義的缺口；未知來源不改寫为不存在。CMP-PAGE 全頁排版／字型与条件列印样式；CMP-FORM 表格、按钮、字段；CMP-COVER 全頁遮罩；CMP-MESSAGE 自訂訊息樣式。入口訊息與政策行為重用 [common-contracts](common-contracts.md) CMP-ENTRY/REQUEST/POLICY/DOWNLOAD，版本v1。CMP-PAGE [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)/[TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06)；CMP-COVER [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)；CMP-MESSAGE [TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)/[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07)。

| 元件 | 樣式規格 | 原型實際載入 CSS | 畫面與證據 |
| --- | --- | --- | --- |
| CMP-PAGE | [DESIGN](components/CMP-PAGE/DESIGN.md) | [CSS](styles/CMP-PAGE.css) | SCR-01、所有 ST；E-02/08/20 |
| CMP-FORM | [DESIGN](components/CMP-FORM/DESIGN.md) | [CSS](styles/CMP-FORM.css) | SCR-01、ST-01/02/04；E-01/03/20 |
| CMP-COVER | [DESIGN](components/CMP-COVER/DESIGN.md) | [CSS](styles/CMP-COVER.css) | ST-03/05；E-11 |
| CMP-MESSAGE | [DESIGN](components/CMP-MESSAGE/DESIGN.md) | [CSS](styles/CMP-MESSAGE.css) | ST-05；E-12/20 |

## 5. 狀態与轉移

狀態為可组合描述，不假定每次只有一个。ST-01 無列；ST-02 至少一列可编辑；ST-03 活動請求／遮罩顯示；ST-04 列结果已回填；ST-05 原生／自訂／外部訊息；ST-06 政策／浮水印條件上下文。任一輸入修改不自動清除 ST-04。ST-03 缺圖片 [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)、需瀏覽器 [TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07)；ST-04 目標拒絕資料 [TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)；ST-05 入口与底部 [TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)、選用 [TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)、樣式 [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)；ST-06 可信来源 [TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)、庫 [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)。所有狀態的載入副作用由 CMP-PAGE 引用 TODO-06。E-01/05/07/09/11/12。

| TR | 起始／条件 | 反應及終態 | FLOW／證據 |
| --- | --- | --- | --- |
| TR-01 | 入口載入 | 初始选项与 0 列 ST-01；入口讯息可叠 ST-05 | FLOW-01、E-01/03/09 |
| TR-02 | ST-01/02 新增 | 空列、计数+1、重新交錯色；ST-02 | FLOW-02、E-01 |
| TR-03 | ST-02 删除 | 删除指定列、重新交错色；最后一列删除则 ST-01 | FLOW-03、E-01 |
| TR-04 | 匯出逐列判定，任一精確空值 | MSG-01、停止交接；列資料及结果保留 | FLOW-04、E-04 |
| TR-05 | 當前列非空、後方有相同精確 ID | MSG-02、停止；先于後方列的空值檢查 | FLOW-04、E-04 |
| TR-06 | 全部通過或 0 列 | BOUND-01、ST-03 | FLOW-04、E-04/11 |
| TR-07 | 舊成功回應 | 回填 → BOUND-02 → 共用完成訊息；ST-04 可叠 ST-05 | FLOW-05/06、E-05/10/11；TODO-02 见 DATA-04/05 |
| TR-08 | 舊拒絕回應 | 回填、无下載 → 共用完成訊息；ST-04 可叠 ST-05 | FLOW-05/06、E-05/11；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) |
| TR-09 | 已解析回應缺失／HTTP失败／回呼例外 | 无已知正常回填保证，进入共用完成或診斷分支；未知結果不命名成功 | FLOW-06、E-10/11；[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03) |
| TR-10 | 入口回復旗標 | 清旗標后停止，無入口警示 | FLOW-01、E-09；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01) |
| TR-11 | 自訂訊息首键／确认／拖曳 | CMP-MESSAGE 的完整順序，关闭或保持 ST-05 | FLOW-09/10、E-12 |
| TR-12 | 啟用政策下全頁事件／copy 到期 | 阻断或轨迹交接、独立清去重；ST-06 | FLOW-08、E-07；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) |

## 6. 規則與訊息

BR-01：逐列按順序，先检查本列任一值精確等於空字串；成立就原生提示并停止；不将全空白當前端空字串。BR-02：當前列非空後立即与其后各列 ID 精確比对；相同就提示并停止，因此首列 A、第二列 A 且保單空，会先重覆提示。BR-03：有零列时沒有可檢查列，直接交接；不能添加「至少一列」。BR-04：列颜色按显示位置重新计算，第一列 #EEF1A7、第二列 #FAFBE1 交錯；刪除重新排列。E-01/04。BR-05 舊成功＝訊息代碼0，不是 HTTP成功；目標判定见API，差距 [TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)。BR-06 共用分支、首键、自訂去重、尺寸、copy独立計時，引用 common-contracts v1；E-07/09/11/12。

| MSG | 原文、出現與关闭 | 證據 |
| --- | --- | --- |
| MSG-01 | 「第{目前可見列號}列的被保人ID或保單號碼不得為空值，若不需要請刪除該列」；BR-01 原生阻断警示；确认后保持输入，无自動聚焦 | E-04 |
| MSG-02 | 「被保人ID：{ID}有重覆出現，請合併在同一列處理」；BR-02 原生警示；確認後不送出 | E-04 |
| MSG-03 | 入口／異步动态訊息原文及前缀，逐條见共用契約；不以「成功／失敗」替代 | E-09/11；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)、[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03) |
| MSG-04 | 自訂視窗「網頁訊息」「確定」，空值「(無訊息內容)」 | E-12 |
| MSG-05 | 「依據資安政策，不開放列印功能」「依據資安政策，不開放剪下功能」「依據資安政策，不開放全選功能」「依據資安政策，不開放頁面儲存功能」；copy 的 Ctrl+Q 說明在來源字典中，实际 copy未呼叫此提示，不当作已触發文案 | E-07；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04) |
| MSG-06 | 診斷 Error、url、params、Exception及逐屬性，見共用契約 | E-11 |

## 7. 觸發流程

| FLOW | 觸發者／事件、起始及輸入 | 條件、系統反應順序 | 可見結果／後置与責任界線 | 證據／缺口 |
| --- | --- | --- | --- | --- |
| FLOW-01 | ACT-02 首次進入；尚未接受使用者事件 | 初始化列計數及表格參照 → CMP-ENTRY；PageUI 条件外部初始化与resize注册；同頁没有绑定快捷键 | ST-01、L/AT、无列；按条件入口消息；外部可信資料不由前端生成 | E-01/03/09/14/15；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)、[TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06) |
| FLOW-02 | ACT-01 UI-05，ST-01/02 | 計數加一 → 末尾空列 → 刪除、ID、保單、空結果 → 重排色 → 文档冒泡清底部 | ST-02；现有列不變，不加入聚焦 | E-01/09；FLOW-07 |
| FLOW-03 | ACT-01 UI-06，指定列存在 | 刪除指定列 → 重排色 → 冒泡清底部 | ST-01或02；不更改计数或其他值；无確認对話 | E-01/09；FLOW-07 |
| FLOW-04 | ACT-01 UI-09，ST-01/02，可包含旧结果 | BR-01 → 当前列 BR-02 → 下一列；第一命中停止；全部或0列通過则 BOUND-01，遮罩与活动記錄；冒泡清底部 | MSG-01/02 或 ST-03；不清結果、不trim、无新增取消；业务检核仍属接收方 | E-04/10/11；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)、FLOW-07 |
| FLOW-05 | ACT-03 BOUND-01 旧响应，ST-03；捕捉到的列集合仍反映当前画面 | success／拒絕均依當時 ID 填當時列结果；success填完才 BOUND-02；拒絕不下載；完成處理在回呼之後 | ST-04；不能改成请求时快照結果、不能丟棄較早請求回應；後到回應覆蓋现有结果；目標差距未确认 | E-05/10/11/17；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) |
| FLOW-06 | ACT-03 请求创建、完成、傳輸／回呼异常 | 完整 Prototype/jQuery、底部、系统模式、原生／自訂、EP、空描述、长編號、文字响应、诊断顺序引用 CMP-REQUEST v1；与FLOW-05先后不同不可合併 | ST-03/05 保留活動生命周期；未確認者停在已知分支；没有本页timeout设置 | E-10/11/13；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)、[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03) |
| FLOW-07 | 全文檔冒泡按鈕／submit點擊 | 本按钮反應後清底部；自訂確定停止冒泡所以不清；清除錯誤吞下 | 本页資料不變；底部受接收者负责 | E-09/12；[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01) |
| FLOW-08 | ACT-02/01，政策启用时載入、全页键盘/剪贴/右键/列印與到期 | CMP-POLICY；full body/window 捕获，copy独立计时與原序编码 | 阻断MSG-05或BOUND-03；copy非阻断；可信來源與记录结果未知 | E-06/07/08；[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)、[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) |
| FLOW-09 | ACT-03 自訂訊息顯示／ACT-01 首key或確定，ST-05 | CMP-MESSAGE 正規化、去重、增長、重定位、聚焦；每个keypress先自除、首键是否关闭；確定順序 | 保持或關閉ST-05；不暗加持续Esc监听；停止确认冒泡 | E-12；[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07) |
| FLOW-10 | ACT-01 自訂标题按下→document移动→放開 | 保存偏移、拖曳框、隐藏真視窗、放開复位与解除／重建监听 | 視窗移動；不改訊息累積或資料 | E-12；[TODO-07](../../renovation/AF-AFY10400/tracking.md#todo-07) |

## 8. 驗收案例定義

均為合成資料，无真实個資；V 實際結果在 tracking。未解案例不宣稱可通過。

| AC | 前置／事件 | 明確預期與關聯 | 證據／缺口 |
| --- | --- | --- | --- |
| AC-01 | 初次開啟 | L/AT、0列、三条說明与四欄；FLOW-01 | E-01/03；TODO-01/06 |
| AC-02 | 新增2列、刪第一、再新增 | 第一色#EEF1A7，第二#FAFBE1；保留其他值；识别不復用；FLOW-02/03 | E-01 |
| AC-03 | 第一列 ID空，保單X → 匯出 | 精確MSG-01第1列；沒有pending交接 | E-04 |
| AC-04 | 第一列DEMO000001/P1、第二同ID且保單空 | 先MSG-02，再終止；不得先第2列空警示 | E-04 |
| AC-05 | ID/保單均單一空格、及另一次0列 | 前端空字串檢核不攔；後端结果未知；不得新增至少一列 | E-04；TODO-02 |
| AC-06 | 有效兩列 P1 LF P2，選R/CB → 匯出 | 輸出有序平行集合；保單换行轉CRLF；ST-03、不清舊结果 | E-04/10 |
| AC-07 | R1请求ID=A后把現有ID改B；返回map A:a,B:b及檔名 | 回填b；回填後下载交接；与请求A映射不同；FLOW-05 | E-05 |
| AC-08 | 请求R1→R2；R2 map A:second先返回，R1 map A:first后返回 | 結果先second后first；各自成功均依各自檔名交接，没有stale guard；活動依實際交付减 | E-05/10/11 |
| AC-09 | 舊拒絕map A:原因 | 回填原因、沒有下載、共用錯誤訊息；目標data=null不能模拟旧map | E-05/22；TODO-02 |
| AC-10 | 入口有／無底部、回復旗標、代碼0/99/5、異常 | 依 CMP-ENTRY 逐分支前缀、首笔通知、回復清旗标并停止；WIUtil分支未知 | E-09；TODO-01/03 |
| AC-11 | Prototype完成：各系统模式、EP、空描述、>17编号、非JSON、HTTP失败、callback异常 | CMP-REQUEST所有已知分支／順序；diagnostic原文；没有正常回填保障的情況不当成功 | E-10/11；TODO-01/03 |
| AC-12 | 自訂訊息空值、同内容重複、短→長→短 | 空占位、按規則去重与累積，宽只增、每次居中、聚焦確定 | E-12；TODO-07 |
| AC-13 | 初次訊息，首鍵a，再Enter；另次重開首Esc；按钮关→重開首鍵组合 | a先自除监听，后Enter不close；首Escclose；旧listener身份分别自除，不能移除新实例 | E-12；TODO-07 |
| AC-14 | 自訂訊息标题按下、移動(+50,+30)、放开、再拖 | 框按偏移移动，真视窗移出；放开復位／解除move/up／重建down | E-12；TODO-07 |
| AC-15 | 启用政策，在body之外的审阅区域发Ctrl+A/X/S/P與右键 | window/body全页捕获并阻断；右键无固定訊息；print內容符合MSG-05 | E-07；TODO-04/07 |
| AC-16 | t0复制A，t30复制B，t60 A到期，t61再复制B | A/B各送一次；t60清B记录，t61再送B；空选择不送，同文本未到期不送；>5000截4997+...，长度送原始值 | E-07；TODO-04 |
| AC-17 | 新增/删除/空值匯出點擊；自訂確定 | 前三者按动作后尝试清底部；確定不冒泡清底部 | E-09/12；TODO-01 |
| AC-18 | 打开原型並实测所有已知状态的style | 核對四CMP DESIGN/CSS selector，特别root padding10px及讯息增長／拖曳；沒有legacy画面不宣稱像素等價 | E-20/12；TODO-05/07 |

## 9. 原型与前後端索引

[SCR-01.html](prototypes/SCR-01.html) 起始 ST-01；新增／刪除／匯出为產品控制；单一离线原型可到ST-02/03/04/05。独立「審閱工具」只注入旧契约合成响应、自訂訊息及条件政策；沒有真实业务算法、下載檔案或稽核写入。正式產品不会有注入控制。默认请求停在已知边界；选定目标的 code500/data=null 仅揭露TODO-02，不補出map；不会调用網路。審閱底部紀錄是工具，不是外部通知UI。浮水印、缺圖、原生alert浏览器外观、外部WIUtil以及date载入无法展示；TODO-01/03/04/05/06/07。

BOUND-01/02 → [API-01/02](../../integration/AF-AFY10400/api-spec.md)；BOUND-03/04與拒絕回填→[HANDOFF-01..04](../../integration/AF-AFY10400/backend-handoff.md)。prompt已取得但沒有根頁前端事件或讀取其字段，不强加初始化API呼叫或日期／编辑控件；仅列介接未消费解释。
'''
write(D/'specification.md',spec)
print('Plan dependency updates and shared/root behavior contracts generated.')
