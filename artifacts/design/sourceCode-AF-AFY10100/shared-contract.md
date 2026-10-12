# 公會通報查詢所消費的共用契約

版本0.1；只描述本入口用法与相关分支，不推廣為全系統標準。[根頁規格](specification.md)；[追蹤](../../renovation/sourceCode-AF-AFY10100/tracking.md)。外部授權 DEC-02 为先翻新支援本頁的依賴，明細內部延後；已確認的條件反應與未取得的適用情境分開。

<a id="cmp-02"></a>

## CMP-02：共用頁面呈現（候選版本）

已取得共用CSS候選，保留其完整選擇器優先序与本頁匹配規則；原型載入後由根頁明示style（原來源inline較高權重）覆蓋。包括字型繼承、10pt表格、12px輸入、表格底色、按鈕線性漸層及:root左右padding10px。實际cssBase映射仍未由tag／執行觀察確認：[TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02)。不能稱此候選為已驗證現行全頁樣式。E-23。

<a id="cmp-03"></a>

## CMP-03：請求遮罩、自訂訊息視窗与底部訊息

<a id="flow-12"></a>

### FLOW-12：請求建立／完成／例外

ACT-03 請求建立時，先包裝成功回呼使消費者收到解析後回應資料，再註冊作用中項目、取得共用遮罩，顯示並按內容高度調整。遮罩初次建立或取得既有時都會先依show參數顯示或隱藏，再由呼叫端顯示；若活動控制是按鈕，嘗試聚焦視窗。遮罩預設層級150、100%寬高、fixed（可支援環境）或absolute，後者高度只能增長。圖片與loading資源未取得，但幾何與生命週期已知。E-18/E-19/E-21；[TODO-02](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02)。

完成時先執行根頁成功／傳輸失敗回呼，再處理完成階段；完成階段讀取回應訊息、解除一個作用中項目、重算遮罩，若本次設定timeout则清除計時。無訊息且無作用中請求与無訊息活動才隱藏遮罩。沒有根頁timeout設定，因此不能套用一個固定timeout。若設定timeout，在等待指定秒數後仍進行中則移除回應監聽、abort；自訂回呼存在時dispatch後執行，否則原生警示「在等待 {秒數} 秒後伺服器仍未回應，請稍後再確認交易執行的結果。」；其後派送完成。E-18/E-19。

有訊息時拆分字面換行、組回實際換行並trim；先嘗試底部訊息顯示。非零返回碼視為錯誤。系統分類符合 L.、R.、J.、DS、DZ、QB、AN、EP、ZU 時走自訂訊息分支：錯誤會顯示訊息窗，非空成功讯息在允許顯示時也顯示，但EP成功会在無活動時僅解除遮罩。錯誤編號非空且長於17字時加「錯誤編號：\n」与「訊息說明：\n」。其他分類先依活動解除遮罩，再以原生alert顯示錯誤；錯誤編號長度規則相同，其後「訊息說明：\n」+訊息；成功非空且無底部訊息區、允許顯示時也以「訊息說明：\n」警示。實际分類為何仍需環境依據，原型的subsystem查詢參數只選合成情境。E-19；[TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)。

傳輸回應若非解析資料但有文字，從字面&lt;body&gt;至&lt;/body&gt;擷取（存在時），把字面&lt;br&gt;换行並作为返回碼−1的訊息；不使用一般成功替代。例外分支原生alert以「Error :\nurl : 」+URL+「\nparams: 」+參數+「\nException: \n」起頭，逐個可列舉例外屬性追加「名稱=值\n」。回應空值／解析失敗可能先觸發診斷再完成，不能只列成功／失敗。E-18/E-19。

<a id="flow-13"></a>

### FLOW-13：入口訊息与任意按鈕清除

初始化從外部取得訊息序列，缺少物件或型別不合時建立預設訊息物件，實際序列長度依未取得的ReturnMessage物件契約；原型初始空序列僅為合成前置情境；描述／編號／例外换行先標準化，缺值为空。尋找底部框架依序為top左框底部、parent左框底部、top底部、parent底部；有回滾旗標時清除旗標並整個流程返回，不顯示底部或警示。可呼叫底部顯示時先顯示第一筆返回碼與描述，然後組合全部警示。E-17。

無例外且返回碼不為0/99，追加「訊息說明:\n」+描述+換行；錯誤編號非空時再加「\n錯誤編號：\n」+編號。有例外则加「異常原因:」+例外+「\n\n程式ID:」+程式代碼+「\n\n」。組合非空時若同时具有自訂顯示工具与相應DOM工具則交自訂工具，否則原生alert。兩個工具实际提供方式未取得，不用本頁自訂訊息視窗冒充它。document層任何target.type被'button,submit'字串匹配的click會嘗試清空底部訊息，例外吞掉；作用範圍涵蓋頁面，審閱回應注入會隔離傳播以免製造額外產品反應。E-17；[TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)。

<a id="flow-14"></a>

### FLOW-14：自訂訊息視窗生命週期

顯示輸入為null、undefined、空字串時內容為灰色「(無訊息內容)」，其餘字面\n与實際換行轉行分隔。先按正規化後全文去重與累積，建立／取遮罩並顯示。若目前可見文字为空，附加視窗、註冊活動、填內容、註冊一次性keypress；首個keypress無論何鍵都先解除該監聽，僅Enter/Esc/空白在視窗掛載時觸發確定並阻止事件。不是每次Enter都能關閉。來源每次註冊閉包有自己的身分，關閉按鈕本身沒有額外移除尚未用到的keypress；重開時旧、新監聽的交錯需保留。E-21。

首筆寬度依正規化字串長度×15px，限制180–600px；后续若内容寬小於588px且小於新訊息長度×15px才增加寬度，不縮小；内容高105px並可捲動。每次顯示按body clientHeight/4加垂直offset、(body clientWidth−視窗寬)/2加水平offset重定位，移除再附加，聚焦確定。確定停止click傳播、移除視窗、解除一項活動；無活動时取得遮罩並隱藏，清除累積內容與文本，若有回呼再呼叫。E-21；ST-07顯示、ST-06無訊息／遮罩已隐藏。同為空值之後重複顯示不增加重複內容，已有寬度不縮回。

<a id="flow-15"></a>

### FLOW-15：訊息視窗拖曳

標題mousedown解除本標題按下監聽，計算指標相對offset，建立相同尺寸的拖曳框并掛document移動／放開監聽；移動阻止預設與傳播，改拖曳框位置並移除訊息視窗。放開先解除兩個document監聽、阻止事件，再採整數框座標定位訊息、移除框、重新附加訊息並重建標題按下監聽。拖曳移動中實際訊息窗不在DOM，不能改為持續顯示原窗。E-21；ST-08拖曳中，完成回ST-07。

<a id="cmp-04"></a>

## CMP-04：全頁條件事件政策、水印与字型

<a id="flow-16"></a>

### FLOW-16：條件政策

由受信任功能資料的PD_CTRL=Y決定是否注入。Y时load在body以capture註冊contextmenu、print、beforeprint、copy、cut，window capture keydown阻止Ctrl+A/X/S/P。剪下、全選、儲存、列印分别原生警示「依據資安政策，不開放剪下功能／全選功能／頁面儲存功能／列印功能」；contextmenu無對應警示字串，仍阻止。print媒体隐藏body所有直接子元素并顯示「依據資安政策，不開放列印功能」。複製的提示詞為「依據資安政策，需留存複製軌跡，複製請改用Ctrl+Q」，但已取得validateCopy分支不呼叫此詞，不擅自補Ctrl+Q操作。E-16；[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)。

複製讀textarea選區或window selection（舊環境document selection），空白正規化為單一空格；非空且與最後全文不同才記錄，建立独立60秒清空最後全文的計時，更新最後全文後，長於5000字截前4997字加...，依序编码%/#/&/空格/+/?/=，交接內容、原正規化長度、功能代碼与時間戳。計時不取消，A在t0、B在t30秒时t60秒A計時会提前清空B去重值；不得改成debounce。實際記錄服務契約未取得，原型止於審閱紀錄。BOUND-08／HANDOFF-06；E-16；[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)。

水印受另一受信任旗標控制，來源提供登入者職編（無則姓名）、服務端時間yyyy-MM-dd HH:mm:ss；同源mainFrame重設頂層功能列表及根視窗。启用时优先同源水印根，必要时嘗試加载水印工具；load將功能代碼推入列表，按两行文本建立190×85、行高20、黑色normal16px Microsoft JhengHei、旋轉17、alpha0.07、grid2×2與指定gap/matrix的水印。字型来源按條件CDN候選與本機woff2/ttf；字型實體未取得。工具來源已取得但本輪不以任填值冒充登入情境；視覺與監控/MutationObserver完整生命週期尚未驗證，[TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)。原來源berforeunload拼字與handler掛載差異保留於tracking，不修正成已批准需求。E-16。

<a id="flow-17"></a>

## FLOW-17：必要檢核與快捷鍵

空值规则為null或長度0；純空白不算空，不加trim。多重必要检核在可見欄位後執行，預設不自動submit/change校驗、忽略disabled与hidden；根頁沒有數字檢核class/datatype。DS分類使用聚合alert模式，以「檢核錯誤如下:\n [身份證字號/統一編號：不得為空值]\n」警示，其後的焦點順序依來源；其他分類使用欄位後advice原文，不通过時加多重失敗class，focusOnError在多重校验前掃單一失敗class，所以本頁必要失敗不自行宣稱移焦到輸入。通过時隱藏advice并逐次移除錯誤class計數，不自行重置所有累積驗證狀態。E-20。

鍵盤在document.onkeydown，修飾鍵優先Alt→Ctrl→Shift，没有對應修飾註冊时不觸發。F2/8/9/10對應原按鈕.click；不存在按鈕不建立execute，disabled原生click不觸發。命中動作设returnValue=false，不能猜某鍵因註解說不支援而省略根頁註冊。E-22。

<a id="flow-18"></a>

## FLOW-18：排序與日期引入

五欄全部用字串型：取cell.innerHTML轉大寫、字串排序，方向0升序，其餘降序；重複值按原出現配對，少於2列不重排；複製列插到原位置後刪舊列、保留行單選與行資料，根頁不重排顯示序號；奇偶列色設定但cell原底色可遮蓋。即使日期欄也是字串型，不能改日期比較器。E-24。

日曆來源顶层定義若干全域，根頁未見日期觸發控制；不新增日曆按鈕。date.js兩候選編碼嚴格失敗，不能判定全部引入副作用无影响：[TODO-03](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-03)。E-25。

## 驗收案例

| AC | 前置／事件 | 具體預期 |
| --- | --- | --- |
| <a id="ac-17"></a>AC-17 | F8空字串／純空白；默认AF與?subsystem=DS | 空字串停止；AF欄位advice，DS聚合alert；純空白通過並建立合成請求 |
| <a id="ac-18"></a>AC-18 | 建立兩個合成請求，先完成2再1（每個完成先回呼再派送完成） | 遮罩在仍有請求時保持；全部完成且無訊息才隱藏，活動数与請求綁定 |
| <a id="ac-19"></a>AC-19 | 自訂訊息先短、重複、再長；null/undefined/空字串 | 正規化、去重、累積、寬度只增加、600上限，空值灰字 |
| <a id="ac-20"></a>AC-20 | 顯示→首鍵a→Enter；重新顯示→首鍵Enter；按鈕關閉後重開 | 先將焦點移至審閱文字欄，首鍵a解除keypress，后Enter不因該監聽關閉（若焦點仍在確定按鈕，瀏覽器原生Enter點擊仍可能關閉；實際原型已觀察此結果）；新一次首Enter關閉；每個註冊自身移除 |
| <a id="ac-21"></a>AC-21 | 訊息標題拖曳并放開，重複拖曳 | 移动中只有框、訊息移除，放開按偏移定位並重掛監聽 |
| <a id="ac-22"></a>AC-22 | ?policy=Y下在產品區与審閱区Ctrl+A/P、右鍵；?policy=N | Y作用範圍body/window含審閱区；N不注入此政策，不能外推實際部署旗標 |
| <a id="ac-23"></a>AC-23 | 复制A於t0、B於t30秒、同B於t59與t61 | t59去重、t60旧timer清空，t61B重新记录；truncate与順序编码可核对 |
| <a id="ac-24"></a>AC-24 | 入口碼0/99/非0、例外／回滾；自訂工具存在／不存在；底部框架有／無 | 按FLOW-13各分支原文与顺序；未提供真实框架／工具实现时只能契約核对 |
| <a id="ac-25"></a>AC-25 | 傳輸完成ErrMsg／无JSON但文字／解析例外，分類AF與自訂／EP | 成功回呼先发生再完成訊息、遮罩解除及onException诊断，未知業務结果不伪造 |


後置補充：根頁識別值成功回呼只讀識別旗標，未先依業務返回碼決定能否取回；共用完成階段其後才處理業務訊息。E-04/18/19。所有服務結果仍是[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)。

<a id="cmp-05"></a>

## CMP-05：條件水印的離線示例

來源E-16/26。原型URL?watermark=Y載入本地同版本工具與原header已知組態；ST-09／UI-207表示已建立水印，合成文字與時間只屬審閱前置。工具根模式外層relative、內層fixed且pointer-events:none、zIndex2147483647；畫布背景344×154px重複。MutationObserver監控自己的節點屬性與父節點子元素，被移除或父節點尾端改動會remove/create；remove先解除observer與檢查事件。來源monitorProtection=true也保護此頁內的MutationObserver與requestAnimationFrame。字型實體与服務端情境仍是[TODO-01](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)與[TODO-04](../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)，不宣告水印身份可信。

AC-26：以合成watermark=Y載入，檢查grid背景尺寸、pointer-events與根模式fixed；實際操作查詢按鈕仍可點；移除水印節點後工具重新建立，審閱示例不得改變任何後端資料。圖片輸出只為來源畫布的本機顯示。
