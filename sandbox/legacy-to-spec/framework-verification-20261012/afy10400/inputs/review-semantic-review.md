# AF-AFY10400 語意審查

本 case 是**部分交付，仍有確證偏差**。主要 UI 流程、後端權威分工、拒絕結果及下載差距、可信情境責任和局部 TODO 已建立；不能以本地模型或 metadata 檢查通過，宣稱來源到原型已完整還原。當次瀏覽器結果另確認三項原型問題。

審查日期：2026-10-12。唯一根入口：`inputs/frontend/sourceCode/AF/AFY10400.jsp`。本審查只寫入本檔，未修改 skill、inputs、manifest、task 或 artifacts，未啟動其他代理。

## 審查基準與方法

先讀本 case 的 `task.txt`、`manifest.json`、`skill/SKILL.md` 及相關 guides/references，再讀 inputs 原件。收到「開始審查」後才讀已生成的設計／原型；收到「生成完成」後才核對完整 API、handoff、DESIGN 和 tracking。沒有讀取其他 case 或過往報告。

依本 case skill R1–R9，以來源支持、責任權威、已知分支／順序／副作用、技術中立、局部缺口、樣式雙份交付與實際驗證範圍作判定。後端投影只對照指定 `inputs/backend/docs/OPENAPI.md`；方法文件作為 legacy 業務語意，沒有把它們當成目標 HTTP、部署或正式服務證據。

独立重算 manifest 所列 **43 個檔案 SHA-256，無不符**。inputs 共 16 份，各自核對原始 bytes 行數和 UTF-8／CP950 嚴格解碼：根 JSP 246 行、CP950；其他可讀前端資源採 CP950；後端文件採 UTF-8；`date.js` 兩候選均失敗，1089 行，不使用替代字元猜測其載入效果。根雜湊為 `fbf8f94aee2f03f830f5092ba280dca6f6707ce45d54a929e6ec7cecd4284b1a`，後端基準為 `13307ed1144946124179d6e02148999e64783e031d440aacc8ff54e03c32f1ef`。

閱讀 libs 僅沿本頁實際使用鏈及必要載入副作用，沒有宣稱已分析完整共用函式庫。生成方的當次 [behavior-check](../artifacts/renovation/AF-AFY10400/behavior-check.json) 和 [metadata-check](../artifacts/renovation/AF-AFY10400/design-metadata-check.json) 只採用其明載的檢查範圍。父代理的當次 [browser.json](browser.json) 作為實際瀏覽器證據；審查者本身沒有執行瀏覽器、legacy JSP 或後端。

**方法限制：**父代理允許讀取當次驗證結果後，本審查誤將 `reports/browser-scenarios.json` 一併讀取；該檔是操作定義，超出原先不讀測試 scenario 的限制。因此不能宣稱完全盲審。以下來源判定以 inputs 與 artifacts 為依據，執行判定只採 `browser.json` 的實際結果；沒有讀取 checks 程式或其他 scenario。

## 來源與責任覆蓋核對

| 來源／必要內容 | 產物去向與核對結果 | 判定／限制 |
| --- | --- | --- |
| 根 JSP L27–31、L189–230：初始化、選项與零列 | FLOW-01、DATA-01/02/03/09、ST-01；L/AT 與零列保留，沒有自增一列或加入日期控件 | 相符；外部入口訊息／date 載入保持 TODO-01/06 |
| 根 L33–65、L116–124：新增、刪除、識別與重排色 | FLOW-02/03、UI-05/06/07/08、BR-04；無刪除確認、無新增聚焦、計數不復用 | 行為相符；結果格對齊見 F-03 |
| 根 L67–94：逐列精確空值與向後重複 ID | FLOW-04、BR-01/02/03、MSG-01/02；先本列空值，再與後方 ID 比對，第一命中停止；空白字串與零列未新增攔截 | 相符；前端檢核未提升成後端保障 |
| 根 L95–97、Prototype L6475–6532：真正送出資料 | BOUND-01、API-01；認出未使用的 param，保留真正 I_ID／POLICY_NO 有序對應及 LF→CRLF | 相符；零列省略與目標空陣列不冒充等價，TODO-02 |
| 根 L98–114：兩種回應與下載先後 | FLOW-05、TR-07/08、DATA-04/05、BOUND-02；回應時讀現有列與當時 ID，成功先回填再下載，拒絕回填且不下載；不添加 stale guard | 相符；目標錯誤 data=null 不捏造逐列 map，HANDOFF-01／TODO-02 |
| msgDisplayer L1–188：入口、底部、回復旗標、點擊 | CMP-ENTRY、FLOW-01/07、DATA-06、MSG-03；換行、0/99、異常文案、首筆通知、旗標清除後停止、按鈕反應後清底部及確認停止冒泡分開保留 | 呼叫端契約相符；底部／WIUtil 內部未提供，TODO-01/03 |
| CSR L371–745、Prototype L1934–1997：請求鏈 | CMP-REQUEST、FLOW-06、TR-09；成功回呼先於完成、不同共用模式、EP、長編號、無 JSON／文字回應、onException 都有去向 | 大部分已盤點；遮罩焦點嘗試遺漏見 F-04；原型未展示全部模式 |
| CSR L1409–1696：訊息生命週期 | CMP-MESSAGE、FLOW-09/10、AC-12/13/14；空值、去重、順序、寬度、首任意鍵自除、關閉重開、拖曳中間狀態均寫入契約 | 正常路徑有實測；確認遮擋／樣式見 F-01/02；拖曳中鍵盤 guard 見 F-08 |
| header L70–264：政策與复制紀錄 | CMP-POLICY、FLOW-08、DATA-07/08、BOUND-03；全 body／window 捕獲、各提示、非阻斷 copy、獨立 60 秒到期、裁切、原長及編碼順序保留 | 相符；不宣稱外部紀錄已寫入，HANDOFF-03／TODO-04 |
| header L1–66、L266–413：可信設定與浮水印 | LOGIC-04/06、DATA-06/07、BOUND-04、HANDOFF-03；沒有將可信識別／時間變成產品任填欄位，庫缺失與 unload 原缺陷留痕 | 合理部分契約；實際庫輸出／合法提供機制未知 |
| PageUI／HotKey／Validator／calendar／date | 必要載入行為與本頁使用邊界在 common-contracts／DEP；不增加功能鍵、證號驗證或日曆；缺 calendar CSS 與不可解碼 date 沒被當成無影響 | 有明確停止邊界；完整 cascade／載入副作用未完成 |
| cm.css／根版面／CSR 動態樣式 | 四 CMP 各有 DESIGN、實載 CSS，root button padding 與訊息动态公式有紀錄 | 雙份檔案齊，但 F-02/03/06 證明文字同值／shape PASS 不代表來源一致 |
| OPENAPI §1/2/6、三份方法文件 | API-01 export／API-02 download；精確 wire、選定 envelope、stub 性質、兩端資料映射與四 HANDOFF | 投影未見確證 wire 錯誤；API/業務/正式部署仍部分 |

API 核對保留：POST、JSON object、非必填與未知 null／空集合邊界、平行 `I_ID`／`POLICY_NO`、動態 `data.rtnMap`、`data.fileName`、HTTP 200＋body code 500 的错误、stub header、下載 JSON／UTF-8 form、binary／Content-Disposition 與部分寫入後異常限制。prompt 及 `/promp` 相容路徑、`rtype` 名稱被精確記錄為未消費，沒有因後端存在該操作就強加本頁初始化事件。JSP 的呈現、可信情境、檔案／稽核副作用均有不同責任去向，未創造新 endpoint 或前端業務運算。

## 確證問題

### F-01／高：審閱區攔截自訂訊息確認點擊

位置：[review.css](../artifacts/design/AF-AFY10400/styles/review.css) L2、[CMP-MESSAGE.css](../artifacts/design/AF-AFY10400/styles/CMP-MESSAGE.css) L2、[prototype.js](../artifacts/design/AF-AFY10400/prototypes/prototype.js) L16。

審閱區 z-index=2000，高於訊息999；訊息位置又按包含審閱區的 body 高度計算。在 1280×900 的當次瀏覽器，`reopen-key-listener-identity` 正常 click 超時，報告明確顯示 `<aside class="review">` 攔截 `#message-ok` 的 pointer events。這不是鍵盤 listener 身分已證明錯誤，而是正常確認及後續重開案例被工具區擋住。違反 R8 與 UI 規則要求工具與產品控制均可操作。

修正方向：調整審閱區位置／幾何或工具層疊，使等待回應注入和訊息確認均可正常點擊；保留來源訊息 z-index 與定位契約，不能靠強制 click 或直接關閉函式繞過。重新跑確認、重開與拖曳，才可完成受阻的 AC-13。

### F-02／中：全域輸入樣式被縮到 product，遺漏訊息確認控制

位置：[CMP-FORM.css](../artifacts/design/AF-AFY10400/styles/CMP-FORM.css) L2、L16；[SCR-01.html](../artifacts/design/AF-AFY10400/prototypes/SCR-01.html) L5、L15；FORM STYLE-01/36/37。

原 `cm.css` L12–15 的 input／textarea 字型及 L542–545 的 input:read-only／textarea:read-only 是全域規則。原訊息確認 input 由 CSR L1449–1474 加入 body，仍受這些規則影響。生成 CSS 改為 `.product input...`，但 `#message-ok` 在 `main.product` 外，失去已知字型規則和 readonly cascade。當次 `message-button-global-readonly-cascade` 實測 border-top-style 為 solid，來源預期為 none；字型的具體 fallback 尚未另量測。

修正方向：產品樣式範圍涵蓋本頁及外置產品元件，同時保持審閱工具獨立；同步更正 DESIGN 映射並核對訊息確認的字型、border、padding。TODO-05 的未知後載 CSS 不能替代對已取得規則作用範圍的保留。

### F-03／中：匯出結果欄被新增置中對齊

位置：[CMP-FORM.css](../artifacts/design/AF-AFY10400/styles/CMP-FORM.css) L8、FORM STYLE-13；[prototype.js](../artifacts/design/AF-AFY10400/prototypes/prototype.js) L10。

根 JSP L40–58 只把刪除、ID、保單三格設為 center，結果格沒有該設定；本頁可匹配的已提供 cm.css 沒有結果置中規則。生成 `.data-table td {text-align:center}` 連結果格一併置中，且 STYLE-FORM-13 引用 E-01/03/20 當作來源支持。當次 `result-alignment-preserved` 實測 center，而來源結構預期 start。這是已取得來源的樣式偏差，不是缺圖或像素等價未驗證。

修正方向：按標題／資料格／結果格的实际適用位置保留對齊，再同步核對 STYLE-FORM-13 與 UI-08。

### F-04／中：遮罩的條件式視窗聚焦嘗試沒有契約／驗證去向

位置：來源 CSRUtil L321–326；[common-contracts.md](../artifacts/design/AF-AFY10400/common-contracts.md) CMP-REQUEST；[prototype.js](../artifacts/design/AF-AFY10400/prototypes/prototype.js) L7。

每次建立／取得遮罩，若 activeElement 有 type 且匹配 button，來源嘗試聚焦所屬視窗；失敗有診斷紀錄。E-11 的範圍包含該片段，但規格、common、來源覆蓋表與原型只寫活動數、顯示／隱藏，沒有這個條件副作用或局部未知。不能由實際聚焦效果未測，推成來源不存在此反應。

修正方向：補上觸發條件、聚焦嘗試及無法確認的瀏覽器效果，連到 FLOW-06／CMP-COVER 與驗證；不需新增後端移交。此項為靜態來源確證，未宣稱瀏覽器一定切換可見焦點。

### F-05／中：正式前端契約仍依賴 legacy 實作符號

位置：[specification.md](../artifacts/design/AF-AFY10400/specification.md) L26、L104、L109；[common-contracts.md](../artifacts/design/AF-AFY10400/common-contracts.md) L17、L21、L34、L47、L63。

正式 DATA／FLOW 和被它引用的共用定義仍使用 `data=null`、Prototype／jQuery／WIUtil、PageUI 的 init／table／overDiv、document keypress、type 與 `button,submit` 的實作搜尋規則組織契約。這些不全是使用者可辨識的代碼／文案／格式；閱讀者仍需理解既有函式庫和來源語法才能判定條件。tracking L49及交付判定卻稱其為技術中立。

修正方向：正式契約用可觀察事件、外部呈現能力是否可用、回應是否帶列結果、條件式訊息模式描述；程式符號及模式辨識來源留 tracking；精確 wire 留 API 文件。保留所有已知分支，不能為中立化而合併兩種不同反應順序。

### F-06／中：部分 STYLE 的 E 引用不支持該主張

位置：PAGE [DESIGN.md](../artifacts/design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L72–75，STYLE-PAGE-26..29。

STYLE-PAGE-27..29 的列印隱藏／提示引用 E-02/08/20；这些 E 的已登錄行範圍是根版面、header 的 session／字型／浮水印與一般 cm.css，沒有政策列印規則。正確來源是 header L101–112，E-07。STYLE-PAGE-26 的 Chrome／Enter 紅字在根 L191/193，應引用 E-03；現引用 E-02/08/20 亦不能定位該原文呈現。CSS 值本身有原始來源，但交付的追溯鏈錯位，metadata shape PASS 不會發現。

修正方向：逐 STYLE 按適用原始位置更正 E，不沿用同一组章級證據；同時把「正文規則；部分值对应frontmatter」改為可判讀的實際 token 路徑或明確正文規則，便於之後逐值維護。後者是映射清晰度不足，沒有宣稱不選 DTCG 本身是缺陷。

### F-07／中：DEP 表每列比表頭多一欄

位置：[plan.md](../artifacts/renovation/AF-AFY10400/plan.md) L24–40。

表頭與分隔列均為6欄，DEP-01..15 全部是7欄：DEP ID 與資源分成兩格，表頭卻合成「DEP／資源」。條件、查找、影響、後續欄因此錯位，最末 E 證據沒有對應表頭。独立逐行欄位檢查重現15列不符。這削弱依賴／授權／證據表的可審阅性；現有結構檢查 PASS 未涵蓋此問題。

修正方向：將 DEP 與資源各設一欄或合併每列前兩格；重新核對所有依賴行的欄位數與 GFM 呈現。

### F-08／中：訊息拖曳移出文件時，鍵盤事件被額外阻斷

位置：來源 CSR L1613–1625、L1545–1555；[prototype.js](../artifacts/design/AF-AFY10400/prototypes/prototype.js) L14、L16、L21。

來源的首鍵 listener 先解除自己；若是关闭鍵但視窗已無 parentNode，直接 return，不按確認也不停止該鍵事件。拖曳移動會把真視窗移出文件。原型只檢查 `!message.hidden`；拖曳移出後 hidden 仍為 false，故仍呼叫 `ok.click()`，即使 closeMessage 因沒有 parentNode 退出，外層仍 preventDefault／stopPropagation。這改變了拖曳中間狀態的已知鍵盤作用範圍。

修正方向：在停止事件及確認之前保留「視窗仍在文件」guard；驗證顯示→按下／移動→首個關閉鍵→放開的順序。本項為源碼邏輯比較，當次瀏覽器 `message-drag` PASS 只覆蓋一般拖曳，沒有證明這個交錯分支已正確。

## 局部 TODO、檢查結果與判定限制

TODO-01..07 不是只放總索引：DATA-03..08、相關 BOUND/UI、狀態定義及 FLOW 有實際引用，tracking 詳情包含後續資料、TASK-08、決策和完成條件；樣式／date 的未知也由共用 CMP-PAGE 傳播。後端未承接問題保留在 HANDOFF，沒有因文件生成或模型通過而關閉。

局部位置表可證明列出的 TODO 連結存在，不能單憑掃描同一行出現的全部 ID 證明每一個 ID 的影響關係／完整閉包。樣式文件多用共同段落宣告未知，STYLE 表逐列的 token 路徑、適用 UI／ST 和缺口仍可更明確。F-04 是未被這類位置掃描辨識出的已知副作用遺漏。

當次 browser.json 已更新為18項檢查：15 PASS、3 FAIL；三項 FAIL 對應 F-01/02/03。累積訊息案例先前的斷言失敗在當次報告更新後已 PASS，本審查不將它列成產品換行缺陷。受遮擋的重開案例不能判定 listener 身分邏輯失敗或已通過。讀取時 browser 報告所列9份 CSS／DESIGN hash 均與實際檔案相同。

Node 的12項 PASS 覆蓋部分根腳本／模型；不是原共用依賴的完整執行，不能證明 focus、DOM、原生警示、層疊、計時交錯或 wire 介接。四份 metadata PASS 僅检查群組形狀與 typography 欄位，不验证來源樣式或完整官方格式。沒有 real HTTP、檔案、授權、稽核或业务計算執行；deployment 仍未確認。

父代理當次 `structure.json` 與生成方 structural-check 結果不同。其部分 BROKEN_LINK 訊息來自 tracking 位置表把帶 Markdown 的「回讀」片段截斷後留下未閉合括號，再由 regex 跨表格抽出路徑。應先修正片段的引用／轉義並用適用 Markdown parser 核對，不能將這些跨行 regex 結果全數當成真實可點擊連結，也不能以另一份靜態 PASS 宣稱呈現完全有效。確證的 DEP 欄數問題已獨立列為 F-07。

先行計劃有建立時間、初始邊界與決策留痕；本審查沒有生成程序的完整讀取時間線，故不以文件自述獨立證明「所有來源讀取都晚於 plan」。未取得 legacy 執行畫面，不能判定像素等價。來源缺件与禁止外部查詢是實際限制，無法由本輪自行補齊。

交付可作為後續修正與承接的部分基礎；在 F-01..08 修正、受影響契約／樣式同步、必要實際驗證與既有 TODO 完成條件成立之前，維持部分交付。
