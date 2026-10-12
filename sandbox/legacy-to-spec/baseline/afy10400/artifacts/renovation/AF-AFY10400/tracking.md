# AF-AFY10400：翻新追蹤

[設計規格](../../design/AF-AFY10400/specification.md)／[原型](../../design/AF-AFY10400/prototypes/SCR-01.html)／[API spec](../../integration/AF-AFY10400/api-spec.md)／[後端移交](../../integration/AF-AFY10400/backend-handoff.md)

## 1. 來源與邊界

| 項目 | 記錄 |
| --- | --- |
| 唯一根入口 | `inputs/frontend/sourceCode/AF/AFY10400.jsp`，scope `AF-AFY10400` |
| 根 SHA-256 | `fbf8f94aee2f03f830f5092ba280dca6f6707ce45d54a929e6ec7cecd4284b1a` |
| 編碼／行號 | 宣告 BIG5，嚴格 Big5 解碼成功，CRLF；原件 246 行。終端以記憶體解碼、splitlines 編號，無轉码副本；原行號不變 |
| 分析日期／版本 | 2026-10-12，Codex；1.0，首次 CHANGE-01 |
| 納入 | 單頁標題、提示、選項、零列初始化、增刪、非空／重複 guard、序列化、兩回應分支與下載、共用訊息、條件資訊保護与可信情境 |
| 排除 | 其他入口内部行為、其他 OPENAPI 操作、後端實作／資料表／54欄檔案內部生成；其語意只作交接背景；未讀 parent／其他 sandbox／外部 repository |
| 後端基準 | backend_root `inputs/backend`，`docs/OPENAPI.md`，2026-08-12，文件記 `0.0.1-SNAPSHOT`，SHA-256 `13307ed1144946124179d6e02148999e64783e031d440aacc8ff54e03c32f1ef` |
| 基準選定 | task.txt／manifest.json 明確指定；其交換定義不受方法規格取代 |
| 性質／環境 | 現行程式盤點文件，Markdown 非 parser 可讀 OpenAPI；預設 stub；部署環境未知，没有真實服務請求 |
| 交付判定 | 部分交付：TODO-01～07 未解、瀏覽器與 legacy 运行未執行；產出文件不等於完整翻新 |

所有供應檔案版本詳見 [input-inventory.json](checks/input-inventory.json)（逐檔 hash、manifest 相符與解碼結果）。不改原件。開始時 artifacts/ 為空，沒有既有同 scope 識別衝突。

### 依賴邊界

| 依賴 | 讀取目的／停止點 | 處理與限制 |
| --- | --- | --- |
| `CM/header.jsp` | 整份 413 行，追本頁必要可信資訊、保護／copy／浮水印／離開事件 | E-07；自訂 tag、ConfigManager、ZZ_Z0Z001、UserObject 等供應機制未供；HANDOFF-01 |
| `CM/msgDisplayer.jsp` | 整份188行，入口訊息、外層框架與清訊息 | E-06；外層 bottomFrame、WIUtil/jQuery 實際來源未供；HANDOFF-03 |
| `CM/css/cm.css` | 本頁 BODY、文字欄、button、tbBox2、subTitle、tbYellow／2、tbBlue | E-13；未分析全系統CSS；缺圖檔 |
| `CM/js/ajax/prototype.js` | Form.serialize／serializeElements、请求附加情境与 Ajax default options | E-15；保留 array 順序與 LF→CRLF；傳輸 timing／eBAF情境沒有目標承接 |
| `CM/js/ajax/CSRUtil.js` | isSuccess、AjaxHandler.request/post、全域 responders、cover、getMsgBoard／msgWin 相关引用 | E-08；root 供 prototype 所以分析 prototype 分支；已讀內建MsgWin與UICore部署選用，其他系统分支只記條件契約，不納为本頁所有可見功能 |
| `CM/js/RPTUtil.js` | ajaxRequest、downloadFile、download/getForm | E-09；舊加密參數與第二下載交接；此供應版本沒有直接 binary handler，不替後端推導舊 wire |
| `CM/js/HotKey.js` | 整份107行，本頁是否登錄動作 | E-14；庫註冊 document.onkeydown，但 root 無 addHotKey；不推導 F 鍵功能 |
| `CM/js/ui/PageUI.js`、`CM/js/Validator.js`、`CM/js/calendar.js` | 掃描事件／自動登錄，閱讀相關定義；root 沒有調用 PageUI／Validator／calendar | 本頁沒有日期UI與自動校驗呼叫，不把庫所有功能轉為本頁需求；calendar 可 cp950 解碼 |
| `CM/js/date.js` | 檢查原件編碼，ASCII timing 關聯 | Big5／CP950／Big5HKSCS／UTF-8 嚴格解碼均失敗；不猜文字，TODO-06；保留原 bytes |
| `CM/border_01/02/03.gif`、`ecblank.gif`、`icon_dot11.gif`、button／cover／loading 圖檔 | 根及CSS／CSR引用 | 不在快照，未取得；不生成品牌／新圖示，原型保留已知位置／無透明載入圖像，TODO-04 |
| `watermark-js-plus.js`、`hanlinks/eudc`字型、站台字型設定、外層utility／外部訊息介面 | header／CSR indirect依賴 | 未供應；不可從命名聲稱實際呈現；TODO-03／04 |
| backend `docs/specs/AFY1_0400/AFY1_0400_doPrompt.md` | 工作日期與 flags 語意 | E-16；本頁沒消費其值，不增加prompt呼叫 |
| backend `...doExport.md` | 相关方法完整語意，與 wire差距 | E-11；錯誤结果、CRLF、多保單、稽核與生成只服務背景，不以其 schema替代OPENAPI |
| backend `...doDownload.md` | 加密參數舊方法語意 | E-12；沒有正式binary實作，TODO-02 |

## 2. 工作狀態

| 工作 | 完成條件 | 狀態 |
| --- | --- | --- |
| W-01 來源盤點 | 一根入口／依賴／hash／evidence定位 | 完成於快照可讀範圍；date編碼未解 |
| W-02 行為契約 | 事件與分支、UI、資料、CMP、AC、未知 | 已交付部分契約 |
| W-03 介接與拆責任 | 精確基準／array/envelope/binary／handoff | 已交付部分映射，格式與拒絕差距未解 |
| W-04 原型 | 零列布局、增刪、guard、review注入 | 已生成；瀏覽器视觉与互動未驗證 |
| W-05 驗證 | 靜態リンク／ID／placeholder／離線／JS語法／來源鎖定 | 實際結果見 §7；不代替browser與服務驗證 |

## 3. 證據登錄

以下 E 來源版本均由 input-inventory.json 對應路徑／hash固定，行號為原件 splitlines；前端 E 為原始碼，後端 E 為文件，不是執行觀察。

| E | 定位 | 最小來源事實 | 支撐／限制 |
| --- | --- | --- | --- |
| E-01 | root 128～246 | `L/承保,R/收件`、`AT/個險,BG/團險,CB/意外險`；只有三列固定表格，無初始輸入列 | SCR-01、INT-01、UI-01～06／11、DATA-01／02；無运行視覺 |
| E-02 | root 22～31、128 | 初始化 `unique_num=0`、`tb1`、`displayMessage()` | FLOW-01；沒有prompt操作、沒有自動新增 |
| E-03 | root 33～65、116～123 | 新增四欄／刪指定列／依 `rows` 位置奇偶著色 | FLOW-02／03、DATA-03～06、BR-04、UI-07～10；沒有焦點與confirm |
| E-04 | root 67～97 | `==""`；內層掃後續ID；MSG原文；實送 `Form.serialize('frm')` | FLOW-04、BR-01～03／06；`param`物件只是本地組裝，未作post資料 |
| E-05 | root 98～113 | success 先 `rtnMap.get(I_ID)`填第四欄再`downloadFile(...false)`；failure同樣填結果但不下載 | FLOW-05／06、BOUND-01／02；不證target錯誤有map |
| E-06 | `CM/msgDisplayer.jsp`1～59、61～188 | 無訊息fallback、七欄訊息、rollback early return、alertMessages、document.onclick清外層 | CMP-01、FLOW-01／08、DATA-08、MSG-03／04；外層實作／rollback來源缺 |
| E-07 | `CM/header.jsp`26～66、67～264、266～413 | CXL resource路徑、可信功能資訊、`PD_CTRL`／`IS_WATERMARK`、copy audit、session身分、服務時間、字型、load／離開掛載 | CMP-02、FLOW-09、DATA-09、MSG-05～08／HANDOFF-01；設定實值与依賴缺，非固定啟用 |
| E-08 | `CM/js/ajax/CSRUtil.js`15～29、371～515、516～697、2617～2638 | `ErrMsg.returnCode==0`、async post、cover、callbacks与completion；全域responder有异常訊息 | ST-04、CMP-01、API差距；不是目標code=200 |
| E-09 | `CM/js/RPTUtil.js`67～189、204～245、656～688 | 同步取legacy JSON、成功取`downloadFileName/FullPath`、再hidden form提交第二下載服務；false不新窗 | CMP-03、FLOW-06；不能與binary目標直接相容 |
| E-10 | `inputs/backend/docs/OPENAPI.md`1～67、§3 AFY10400三行、500～567、§10 | 指定版交換；export JSON parallel arrays；ReturnMsg code200/500；error data=null；downloadbinary；prompt rtype | API-01／02、雙向映射及差距；無部署證據 |
| E-11 | backend `...doExport.md`1～128、132～167、169～267、378～512 | CRLF拆保單、結果map、partial缺件與已匯出、查無／格式／生成錯誤、服務稽核與Excel内容 | 服務語意背景、HANDOFF-02；非wire權威，不增enum／payload |
| E-12 | backend `...doDownload.md`1～42 | 檔名組路徑、加密下載參數、例外訊息 | 舊服務語意背景、TODO-02；非targetbinary實作 |
| E-13 | `CM/css/cm.css`1～15、63～71、108～126、166～200、260～284 | 已知字型鏈、12px textBox2、21px綠色button、表格10pt、原色值 | CMP-04／SCR-01；未取得gif/字型/截圖 |
| E-14 | `CM/js/HotKey.js`58～107＋root22～124 | 庫提供keydown，根無快捷鍵動作登錄 | 無F鍵產品功能；conditional header Ctrl限制獨立 |
| E-15 | `CM/js/ajax/prototype.js`1731～1748、1759～1844、6468～6525 | 表單重複key依序序列化，文字 LF→CRLF，URL encoding；附加時間／外層eBAF資訊 | request合法來源、array與多行映射；附加情境target未定义 |
| E-16 | backend `...doPrompt.md`全部 | 今日民國日期與showEdit/showQuery/isRType旧語意 | 解釋未消費；target wire名稱只E-10 `rtype` |
| E-17 | `CM/js/ajax/CSRUtil.js`702～746、1409～1696、2509～2594，结合626～681 | 內建網頁訊息／確定、180～600寬、105內容高、聚焦與第一次keypress關閉、拖曳、活躍記錄；外層訊息色藍／紅；部署系統由location正則匹配 | CMP-05、ST-07、FLOW-10、AC-15；部署path未取得，不能從來源存在推導本頁必啟用 |

## 4. 來源覆蓋表

| 盤點項目／定位 | 規格去向 | 原型／案例 | 結論 |
| --- | --- | --- | --- |
| root1～18 directives/import/resources | 範圍／CMP-01～04；LOGIC-01～04 | 非直接可見／TODO-03～06 | 已映射依賴，未供實作保留缺口；ListOrderedMap未用，不增加邏輯 |
| root22～31計數初始化與入口訊息 | FLOW-01、ST-01、DATA-08 | SCR-01初態／AC-01／11 | 零列展示，入口訊息邊界未展示 |
| root33～59新增四欄 | FLOW-02、TR-02、UI-07～10 | SCR-01／AC-02 | 已映射 |
| root61～65刪除 | FLOW-03、TR-03 | SCR-01／AC-02 | 已映射 |
| root67～81本地組裝／取值 | FLOW-04、DATA-01～05 | AC-06／07 | 已映射；未送param不當wire |
| root82～86空值分支 | BR-01、TR-04、MSG-01 | SCR-01／AC-03／04 | 已映射 |
| root87～93重複分支／優先 | BR-02、TR-05、MSG-02 | SCR-01／AC-05 | 已映射 |
| root94～97送出／零列 | BR-03、TR-06、BOUND-01、API-01 | SCR-01邊界／AC-06／07 | 不假成功；TODO-01 |
| root98～106接受回應 | FLOW-05／06、TR-07、UI-10、DATA-06／07、API-02 | review注入／AC-08 | 合成已知形狀；下載未执行 |
| root107～113拒絕回應 | FLOW-05、TR-08、HANDOFF-02 | review注入／AC-09 | 目標data=null未承接；TODO-01 |
| root116～123交錯色 | BR-04、CMP-04 | SCR-01／AC-02 | 已映射 |
| root128～179外框／標題／圖檔 | SCR-01、UI-01／02 | SCR-01／AC-01 | 結構／色值已映射，圖片缺TODO-04 |
| root187～194提示／form | UI-03、INT-01、BR-06 | SCR-01／AC-01／07 | 已映射，原型禁止任何form提交仅为離線安全 |
| root196～213選項／初值 | UI-04／05、FLOW-07、DATA-01／02 | SCR-01／AC-01／10 | 已映射 |
| root214～230表頭／增列／匯出 | UI-06／11、FLOW-02／04 | SCR-01／AC-01～07 | 已映射 |
| root其餘巢狀layout／closing | SCR-01／CMP-04 | AC-01 | 無額外事件、hidden、session或条件业务元素；不是未取得依賴不存在的證據 |
| msgDisplayer載入、外層／rollback／提示／按鈕清訊息 | CMP-01、FLOW-01／08、HANDOFF-03 | AC-11；原型未展示 | TODO-04 |
| header功能資訊／保護／複製／水印／字型／load與離開 | CMP-02、FLOW-09、HANDOFF-01 | AC-12／13；原型未展示 | TODO-03／04／07 |
| CSRutil内建MsgWin／UICore条件／外層訊息顏色 | CMP-05、ST-07、FLOW-10、AC-15 | 主原型未假定選用 | E-17已映射，實際部署條件TODO-04 |
| CSRutil分類／cover／completion／异常／未定義resp | CMP-01、ST-04、FLOW-05 | AC-08／09；透明cover不補缺圖 | TODO-01／04／07 |
| RPTutil JSON取得與第二下載 | CMP-03、BOUND-02 | AC-14；review停邊界 | TODO-02 |
| prototype序列化／情境參數 | DATA-03～05、API-01 | AC-07 | 精確合法來源映射；system context未承接 |
| PageUI／Validator／calendar／HotKey使用點 | 操作體驗不適用與E-14 | 無新產品控制 | root沒有用日曆／validator／shortcut，不把庫功能變需求 |
| date共用文字 | TODO-06、與timing情境關聯 | 無產品日期UI | 編碼未知；不以亂碼推導文案 |
| backend prompt存在但前端無消費 | §10/API §1 | 無prompt原型操作 | 有依据排除 |
| backend export／download共通schema/results | API-01／02、HANDOFF-02 | AC-07～09／14 | 文件核對；非端點驗證 |

無覆蓋百分比：未知工具／資料／外層元件無法盤點其所有行為，不能缩小分母宣稱完整。

### 4.1 混合責任與承接

| LOGIC | 來源／觸發／原順序 | 分責／去向 | 承接與未解 |
| --- | --- | --- | --- |
| LOGIC-01 | E-07 header26～264，render前取resource／功能、設定旗標，之後注入保護 | 受信任設定／存取→HANDOFF-01；攔截／提示→CMP-02/FLOW-09 | API無旗標來源，TODO-03；函式存取例外打印後繼續 |
| LOGIC-02 | E-07 header266～316，session代號／姓名fallback、服務時間、站台字型 | 可信情境→HANDOFF-01；字型／顯示→CMP-02 | 不硬編身分／工作時間；TODO-03／04 |
| LOGIC-03 | E-07 header128～254、317～413，load保護，copy原文正規化／去重／60秒／截長→稽核，水印load與離開 | 前端限制→FLOW-09；audit副作用→BOUND-03/HANDOFF-01 | 不在原型實作真實日誌；timer與离开疑點TODO-07 |
| LOGIC-04 | E-06 server message讀取/fallback→七欄输出→FLOW-01通知／alert→點擊清除 | 可信消息/rollback→HANDOFF-03；格式/提示→CMP-01 | E-10无等價輸出，TODO-04 |
| LOGIC-05 | E-02初始化→E-03增刪與識別→重著色 | 前端呈現/操作→FLOW-01～03/BR-04 | 不需服務endpoint，非業務identity生成 |
| LOGIC-06 | E-04讀取→精確空字串→掃後續重複→序列化 | 前端已存guard→BR-01～03；服務獨立保障不被取代 | API-01非必填差異／形式轉換TODO-01；不增加10碼前端校验 |
| LOGIC-07 | E-04/15序列化／附加時間與外層eBAF | 交換呈現轉換→API-01；可信情境附加→HANDOFF-01 | 新JSON格式与旧额外情境未確認，TODO-01／03 |
| LOGIC-08 | E-05/08分类→接受讀map/name→填map→下载，拒绝填map无download | 分類／結果呈現→FLOW-05；後端結果可用性→HANDOFF-02 | E-10成功承接；錯誤map未承接，TODO-01 |
| LOGIC-09 | E-05/09/12檔名→JSON加密參數→第二檔案傳輸 | 服務檔案交付→BOUND-02/API-02；前端下載UX→FLOW-06 | 目標binary能力已定義，消費適配／正式headers未確認TODO-02 |
| LOGIC-10 | E-17訊息框建立→去重／換行→開啟／確定焦點→首keypress／拖曳／關閉→減活躍與解除覆蓋 | 條件式前端呈現與鍵盤→CMP-05/FLOW-10 | 未新增服務API；部署是否選用TODO-04 |

### 4.2 介接追蹤

API-01／BOUND-01 已核對 E-10 的四個輸入、兩個 payload 子欄與 envelope；JSON轉換与错误呈現尚未実作或確認。API-02／BOUND-02 已核對兩 request media、fileName、binary與stub headers；不能沿用 E-09 JSON helper。HANDOFF-01～03 未取得正式承接／變更證據，因此全數開啟；沒有用方法規格關閉任何gap。

## 5. TODO

每項目前均開啟，尚未解決；以下下一步是後續需求，不在本輪突破快照边界取得。

### TODO-01

類型：前後端差距／交換適配。E-04/15 form serialize與本地未送param vs E-10 export JSON；單列仍需array，零列省略／null／empty业务行为未定義；E-05拒绝預期rtnMap vs E-10 data=null；E-11 `<br>` vs E-10文字呈現。影響 API-01、FLOW-04／05、UI-10、AC-06～09。下一步：取得經確認JSON適配與錯誤保留／呈現承接記錄，含 CRLF、空集合、null、缺键与格式標記案例。关闭需后端可定位契約或明確變更、更新API/HANDOFF-02/spec/prototype并跑必要驗證；不可自行改backend。

### TODO-02

類型：下載差距／環境未知。E-09/12舊JSON加密参数与第二服務 vs E-10 binary。影響 API-02、FLOW-06、CMP-03、AC-14。下一步：確認直接binary消費、JSON錯誤與部分binary失敗、正式headers／授權／可見下載方式；保留false不新窗体验。關閉需可定位適配／正式環境證據及檔案驗證，不能用stub表頭推廣正式。

### TODO-03

類型：可信情境／未承接。E-07功能設定、resource路徑、PD_CTRL/IS_WATERMARK、session身分/時間、copy稽核，E-15附加eBAF沒有target機制。影響 HANDOFF-01、DATA-09、CMP-02、FLOW-09。下一步取得相應工具与deployment情境契約、正式承接資料與audit保証。關閉需已證實合法來源、條件旗標与記錄能力，更新API/handoff与AC-12／13；不得由前端任填。

### TODO-04

類型：缺供應依賴／可見回饋未知。E-06外層訊息區/rollback/WIUtil，E-08 cover圖檔與訊息視窗部署選用，E-07 watermark/font，E-01/13圖檔未供應。影響 CMP-01／02／05、FLOW-01／08／09／10、ST-04／07、MSG-03／04、HANDOFF-03。下一步取得对应元件、入口訊息內容和功能情境观察；關閉需版本鎖定与本入口重現，不能把本頁加一個通用通知區當等價。

### TODO-05

類型：未驗證。沒有legacy運行截圖、JSP容器、瀏覽器会話；本輪沒有browser自动化可用的供應依賴。影響全部SCR／FLOW／AC。下一步在可用且授權的離線browser開HTML，依AC执行／截圖／console／network检查；另取得legacy狀態截圖才能比較視覺。關閉不能由静態檢查宣稱像素等價。

### TODO-06

類型：來源編碼缺口。date.js bytes 在offset40等位置无法严格Big5/CP950/Big5HKSCS/UTF-8讀取；未更改、未用替換符猜文字。根未调用date UI，但prototype.js的getCurrentTimeStamp有間接相依。下一步取得供應日期檔正確編碼/原版，与系统计时工具契約；关闭需可讀版本hash与受影響時間情境追查。

### TODO-07

類型：原始疑點／运行分支未驗证。E-05用live ID集合與i+3定位结果，缺map key、pending期间改值/增刪结果不明；E-07 addEventListener('berforeunload', headerWatermarkOnloadFunction)与另分支掛載不同handler／拼字，不能默改；E-08 callback异常／無resp／外部全域依赖與已供應的内建訊息視窗条件未有runtime确认。影響 FLOW-05／06／09及離開情境。下一步定点复现相关输入与生命周期；關閉需实际觀察或確認变更记录，不由现代重寫順便修复。

## 6. 原有疑點与提案

| 原行為與E | 提案（未確認） | 決定 |
| --- | --- | --- |
| E-04零列能送出；前端不检查10碼长度／空白 | 可考虑最少一列／格式檢核 | 未確認；prototype保留精確原guard |
| E-05 old innerHTML可解讀服務字串標記 | 文字節點或安全換行呈現 | E-10明确要求文字节点，记录目標差距；展示仅用无标記合成字串，不声称格式等價 |
| E-07離開掛載拼字/handler疑點 | 正確cleanup | 未確認，TODO-07；不 silently 修旧契約 |
| E-11正常格式loop重設sb後再判長度；错误map输出與bodynull差異 | 可修服務驗證與結果保留 | 背景疑點，非本頁任務，不改後端 |
| E-04 unused param組裝 | 改用配對JSON | API投影明列映射需求，未聲稱已实作／直连 |

## 7. 驗證执行

本節只記實際完成的檢查。原件／產物檢查見 [static-report.json](checks/static-report.json)，互動替身結果見 [interaction-report.json](checks/interaction-report.json)；重現指令與能力限制見 [checks README](checks/README.md)。

| V | 檢查 | 實際條件／結果 | 判定 |
| --- | --- | --- | --- |
| V-01 | 單入口／hash／編碼 | 32個manifest檔案全部hash相符，根嚴格Big5可读且246行；date嚴格解碼失败已留TODO | hash／單入口通過；date可讀性未完成 |
| V-02 | 連結／ID／模板／離線檢查 | 四份Markdown連結／TODO anchor、prototype靜態／動態UI與FLOW/CMP對應、無模板佔位符／外連／network APIs；報告errors=[] | 通過；不驗證CSS布局 |
| V-03 | JS語法 | 提取prototype inline script，用本機node --check，exit 0 | 語法通過；不是browser运行 |
| V-04 | 可展示guard與回應流程 | 本地最小DOM替身共10個檢查：空值原文、重複優先、零列、保留結果、多行、review拒絕／接受／未送出不注入等，10通過／0失敗 | 替身互動通過；不驗證native鍵盤／maxlength／layout |
| V-05 | browser視覺／鍵盤／console／network／截圖 | 未执行；沒有供應browser harness，command查chromium/playwright皆未发现；沒有載入外部工具依賴 | 未執行，TODO-05 |
| V-06 | legacy JSP／正式API／binary下載 | 未执行；只提供來源和文件，禁止對真实endpoint；沒有容器/服務运行 | 未執行，TODO-01～05／07 |

判定：部分交付。静态或DOM替身通過不能关闭必要的可見／服務／可信情境缺口，不能聲稱prototype視覺等價或已與正式後端介接。

## 8. 增量

| CHANGE | 日期 | 變動／证据 | TODO／驗證 |
| --- | --- | --- | --- |
| CHANGE-01 | 2026-10-12 | 首次由凍結single root與指定OPENAPI產出契約、原型、API投影、移交、追蹤；ID固定E-01～17，未改輸入 | TODO-01～07開啟；V-01～06分別记录能力限制 |
