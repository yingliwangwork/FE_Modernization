# header.jsp 公開契約

**原始資源**: `/CM/header.jsp`

## header.jsp
**使用情境**: 功能頁面共用頁首
**使用方式**: `<%@ include file="/html/CM/header.jsp"%>`
**主要功能**:
- 載入 [CXL:csCommon](../taglib/CXL-csCommon.md) 建立頁面既有路徑變數，並使用其中 `htmlBase` 組出本頁引用之靜態資源路徑
- 提供中文字元計算基準
- 依後端提供之識別碼保存作業回應時間
- 依後端提供之登入資訊保存平台跳轉狀態
- 依後端政策限制頁面列印與剪下，並監控、回報複製內容
- 依後端政策顯示個人化浮水印，並於最上層視窗登記浮水印狀態管理者與啟用清單
- 提供 EUDC 字型資源
**輸入**: 無
**輸出**: 無
**輸出條件**: 預設輸出

## charCountsByte
**使用情境**: 中文字元位元計算基準
**使用方式**: `window.charCountsByte`
**主要功能**:
- 提供中文字元位元計算基準，供頁面判斷字元佔用位元數時使用
**輸入**: 無
**輸出**:
- `window.charCountsByte` [Number] - 中文字元位元計算基準值
**輸出條件**:
- 後端提供之基準值為正整數字串（不含前導零）時，輸出該數值
- 其餘情形（含未提供、空值或非數字格式）輸出預設值 `2`

## headerRequestFuncId
**使用情境**: 功能識別碼，由後端依目前頁面推導提供
**使用方式**: pageContext 屬性 EL `${headerRequestFuncId}`
**主要功能**:
- 提供代表目前頁面／功能之識別碼，供 [ctrlMsavelog](#ctrlmsavelog) 端點與 [watermark_funcIds](#watermark_funcids) 標記使用
**輸入**: 無（推導方式屬後端邏輯，不記錄）
**輸出**:
- `headerRequestFuncId` [String] - 功能識別碼
**輸出條件**:
- 後端成功推導出非空白識別碼，且查得對應功能資訊時，才建立此屬性；其餘情形不建立（EL 讀取為空值）

## isWaterMark
**使用情境**: 浮水印顯示政策旗標，由後端依目前功能查得提供
**使用方式**: pageContext 屬性 EL `${isWaterMark}`
**主要功能**:
- 決定是否執行個人化浮水印顯示流程（見 [watermark-js-plus.js 動態注入](#watermark-js-plusjs-動態注入)、[watermark_funcIds](#watermark_funcids)、[WatermarkPlus.Watermark 呼叫](#watermarkpluswatermark-呼叫)）
**輸入**: 無（查得方式屬後端邏輯，不記錄）
**輸出**:
- `isWaterMark` [Boolean] - 是否啟用個人化浮水印
**輸出條件**:
- 僅於 [headerRequestFuncId](#headerrequestfuncid) 成功推導且查得對應功能資訊時建立此屬性；其餘情形不建立（EL 讀取為空值，視同不啟用）

## requestTimeHandleUUID
**使用情境**: 作業回應時間追蹤識別碼，由後端提供
**使用方式**: EL `${requestTimeHandleUUID}`
**主要功能**:
- 有值時，保存作業回應時間（見 [utility.js](../js/utility.js.md#utilitykeepresponsetimeendparametersuuid)）
**輸入**:
- `requestTimeHandleUUID` [String，由後端提供] - 作業追蹤識別碼
**輸出**: 無
**輸出條件**:
- 值非空時，於頁面載入完成後呼叫 utility.js 之 `keepResponseTimeEndParameters`，傳入此識別碼
- 值為空時不執行任何動作

## eBAF_loginPlatformInfo
**使用情境**: 登入平台資訊，由後端提供
**使用方式**: EL `${eBAF_loginPlatformInfo}`
**主要功能**:
- 有值時，隨 [eBAF_loginSystemInfo](#ebaf_loginsysteminfo)、[eBAF_UserObject_Flag](#ebaf_userobject_flag)、[platformDispatcher](#platformdispatcher) 一併保存（見 [utility.js](../js/utility.js.md#utilitykeep_ebaf_parameteropt)）
**輸入**:
- `eBAF_loginPlatformInfo` [String，由後端提供] - 登入平台資訊
**輸出**: 無
**輸出條件**:
- 此值或另三項任一非空時，呼叫 utility.js 之 `keep_eBAF_parameter`，並僅將非空者納入傳入物件

## eBAF_loginSystemInfo
**使用情境**: 登入系統資訊，由後端提供
**使用方式**: EL `${eBAF_loginSystemInfo}`
**主要功能**:
- 有值時，隨 [eBAF_loginPlatformInfo](#ebaf_loginplatforminfo)、[eBAF_UserObject_Flag](#ebaf_userobject_flag)、[platformDispatcher](#platformdispatcher) 一併保存（見 [utility.js](../js/utility.js.md#utilitykeep_ebaf_parameteropt)）
**輸入**:
- `eBAF_loginSystemInfo` [String，由後端提供] - 登入系統資訊
**輸出**: 無
**輸出條件**:
- 此值或另三項任一非空時，呼叫 utility.js 之 `keep_eBAF_parameter`，並僅將非空者納入傳入物件

## eBAF_UserObject_Flag
**使用情境**: 使用者物件旗標，由後端提供
**使用方式**: EL `${eBAF_UserObject_Flag}`
**主要功能**:
- 有值時，隨 [eBAF_loginPlatformInfo](#ebaf_loginplatforminfo)、[eBAF_loginSystemInfo](#ebaf_loginsysteminfo)、[platformDispatcher](#platformdispatcher) 一併保存（見 [utility.js](../js/utility.js.md#utilitykeep_ebaf_parameteropt)）
**輸入**:
- `eBAF_UserObject_Flag` [String，由後端提供] - 使用者物件旗標
**輸出**: 無
**輸出條件**:
- 此值或另三項任一非空時，呼叫 utility.js 之 `keep_eBAF_parameter`，並僅將非空者納入傳入物件

## platformDispatcher
**使用情境**: 平台跳轉端點，由後端提供
**使用方式**: EL `${platformDispatcher}`
**主要功能**:
- 有值時，隨 [eBAF_loginPlatformInfo](#ebaf_loginplatforminfo)、[eBAF_loginSystemInfo](#ebaf_loginsysteminfo)、[eBAF_UserObject_Flag](#ebaf_userobject_flag) 一併保存（見 [utility.js](../js/utility.js.md#utilitykeep_ebaf_parameteropt)）
**輸入**:
- `platformDispatcher` [String，由後端提供] - 平台跳轉端點
**輸出**: 無
**輸出條件**:
- 此值或另三項任一非空時，呼叫 utility.js 之 `keep_eBAF_parameter`，並僅將非空者納入傳入物件

## watermark_datetime
**使用情境**: 浮水印時間戳記，於頁面渲染時建立
**使用方式**: pageContext 屬性 EL `${watermark_datetime}`
**主要功能**:
- 提供浮水印顯示用之目前時間戳記，供 [WatermarkPlus.Watermark 呼叫](#watermarkpluswatermark-呼叫)組成顯示內容
**輸入**: 無
**輸出**:
- `watermark_datetime` [String] - 格式為 `yyyy-MM-dd HH:mm:ss` 之目前時間文字
**輸出條件**: 預設輸出（頁面每次渲染時皆建立）

## watermark_txt watermark_escapeHtml_txt
**使用情境**: 浮水印使用者識別文字，由後端提供之使用者識別文字換算而成
**使用方式**: pageContext 屬性 EL `${watermark_txt}`、`${watermark_escapeHtml_txt}`
**主要功能**:
- 提供浮水印顯示用之使用者識別文字，供 [WatermarkPlus.Watermark 呼叫](#watermarkpluswatermark-呼叫)組成顯示內容
- `watermark_escapeHtml_txt` 為 `watermark_txt` 之 HTML 逸出版本，兩者互為顯示時之替代來源
**輸入**: 無（來源為由後端提供之使用者識別文字；查無時視為空字串，不記錄後端如何查得）
**輸出**:
- `watermark_txt` [String] - 使用者識別文字原文，查無時為空字串
- `watermark_escapeHtml_txt` [String] - 使用者識別文字之 HTML 逸出版本
**輸出條件**:
- 瀏覽器支援對應文字解析能力時，優先還原並使用 `watermark_escapeHtml_txt` 之內容
- 不支援時，改直接使用 `watermark_txt` 之內容

## internetFontUrl
**使用情境**: 字型 CDN 網址前綴，由後端依請求來源提供
**使用方式**: pageContext 屬性 EL `${internetFontUrl}`
**主要功能**:
- 有值時，做為 [EUDC 字型資源請求](#eudc-字型資源請求)之其中一個來源網址前綴
**輸入**: 無（觸發條件屬後端邏輯，不記錄）
**輸出**:
- `internetFontUrl` [String] - 字型資源網址前綴
**輸出條件**:
- 僅於後端判定符合特定來源條件時建立此屬性；其餘情形不建立（EL 讀取為空值），此時字型資源改僅使用站內路徑來源

## fpcsAlertMsgs
**使用情境**: 依政策限制頁面列印與剪下，監控並回報複製內容
**使用方式**: header.jsp 內嵌邏輯，無對外呼叫語法；全域訊息字典 `fpcsAlertMsgs`
**主要功能**:
- 頁面列印時，以政策提示文字取代原頁面畫面內容
- 頁面載入後，右鍵選單操作會被攔截，但不顯示提示訊息
- 頁面載入後，列印與剪下操作會被攔截並提示對應政策訊息
- 複製操作不受攔截：擷取目前選取內容（文字輸入區塊以游標選取範圍為準，其餘以畫面選取範圍為準），監控並回報複製內容（見 [ctrlMsavelog](#ctrlmsavelog)），不顯示提示訊息
- 同一段選取內容於 60 秒內重複複製，不會重複回報
- Ctrl+A（全選）、Ctrl+X（剪下）、Ctrl+S（儲存）、Ctrl+P（列印）按鍵組合會被攔截並提示對應政策訊息
**輸入**: 無
**輸出**: 無
**輸出條件**:
- 僅於後端提供之列印／複製防護政策旗標為啟用時，套用上述限制；旗標未啟用時頁面不受影響
- 全域訊息字典 `fpcsAlertMsgs` 尚未存在時才建立並套用一次；已存在時略過，不重複套用

## ctrlMsavelog
**使用情境**: 複製內容回報端點，由後端提供；於使用者複製頁面內容時觸發（見 [fpcsAlertMsgs](#fpcsalertmsgs)）
**使用方式**: `GET /ZZWeb/servlet/HttpDispatcher/ZZM0_0105/ctrlMsavelog?COPY_CONTENT={內容}&FUNC_ID={功能識別碼}&COPY_LENGTH={長度}&TS={時間戳記}`（以載入影像資源之方式送出）
**主要功能**:
- 回報使用者複製之內容、功能識別碼、複製長度與觸發時間
**輸入**:
- `COPY_CONTENT` [String] - 複製內容，其中空白已正規化為單一空格；超過 5000 字元時先截斷為前 4997 字元並加上省略符號，再將 `%`、`#`、`&`、空白、`+`、`?`、`=` 等符號以百分比編碼取代
- `FUNC_ID` [String] - [headerRequestFuncId](#headerrequestfuncid)
- `COPY_LENGTH` [Number] - 複製內容原始長度（空白已正規化為單一空格，但未經 5000 字元截斷前之長度）
- `TS` [Number] - 觸發當下時間戳記（毫秒）
**輸出**: 無（前端未處理回應內容）
**輸出條件**:
- 每次複製操作，選取內容非空且與前次已回報內容不同時觸發；相同內容於 60 秒內視為重複，不再觸發

## watermark_root
**使用情境**: 浮水印狀態管理者視窗參照，供同源環境下彙整浮水印啟用清單使用
**使用方式**: `window.top.watermark_root`
**主要功能**:
- 提供負責彙整 [watermark_funcIds](#watermark_funcids) 清單之視窗參照
**輸入**: 無
**輸出**:
- `window.top.watermark_root` [Window] - 負責彙整浮水印啟用清單之視窗參照
**輸出條件**:
- 目前視窗與最上層視窗同源，且目前視窗名稱為 `mainFrame` 時，指定自身視窗為管理者（伴隨將 [watermark_funcIds](#watermark_funcids) 重設為空清單）
- 目前頁面啟用個人化浮水印（[isWaterMark](#iswatermark) 為真）、目前視窗與最上層視窗同源、且尚未有管理者登記時，改指定最上層視窗自身為管理者
- 目前視窗與最上層視窗非同源時不寫入；此時浮水印顯示流程改以目前視窗自身做為區域性管理者，不影響其他視窗

## watermark_funcIds
**使用情境**: 目前啟用個人化浮水印之功能識別碼清單，於同源環境彙整跨頁面之啟用狀態
**使用方式**: `window.top.watermark_funcIds`（實際掛載視窗為 [watermark_root](#watermark_root) 所指視窗）
**主要功能**:
- 提供目前啟用個人化浮水印之功能識別碼集合
**輸入**: 無
**輸出**:
- `watermark_funcIds` [Array&lt;String&gt;] - 目前啟用個人化浮水印之功能識別碼清單
**輸出條件**:
- 目前視窗與最上層視窗同源，且目前視窗名稱為 `mainFrame` 時，重設為空清單
- 目前頁面啟用個人化浮水印（[isWaterMark](#iswatermark) 為真）時，於頁面載入完成後，將 [headerRequestFuncId](#headerrequestfuncid) 加入清單（清單不存在時先建立為空清單）
- 既有邏輯原意在頁面卸載前，將自身之 [headerRequestFuncId](#headerrequestfuncid) 自清單移除，但登錄此移除時機所用的名稱誤植為 `berforeunload`（正確拼寫應為 `beforeunload`）：在支援新式載入完成／卸載通知註冊方式的瀏覽器下，`load` 時機正確對應到「加入清單」之處理程序，但誤植拼寫的卸載時機也對應到「加入清單」之處理程序，而非「移除」之處理程序；在改用舊式通知註冊方式的瀏覽器下，`load` 與誤植拼寫的卸載時機則兩者皆對應到「移除」之處理程序，而非「加入清單」之處理程序。實際可觀察結果為：清單成員只會持續累加，不會在頁面卸載時被移除

## watermark-js-plus.js 靜態載入
**使用情境**: 頁面靜態載入浮水印套件
**使用方式**: `<script type='text/javascript' src='${htmlBase}/CM/js/ui/watermark-js-plus.js'></script>`
**主要功能**:
- 無條件載入 [watermark-js-plus.js](../js/watermark-js-plus.js.md) 至目前頁面
**輸入**: 無（`htmlBase` 見 [CXL:csCommon](../taglib/CXL-csCommon.md#htmlbase)）
**輸出**: 無
**輸出條件**: 預設輸出（頁面渲染時一律載入）

## watermark-js-plus.js 動態注入
**使用情境**: 於浮水印狀態管理者所在視窗補充載入浮水印套件
**使用方式**: 於 JavaScript 中動態建立並插入 `<script type='text/javaScript' src='${htmlBase}/CM/js/ui/watermark-js-plus.js'>` 至該視窗
**主要功能**:
- 於 [watermark_root](#watermark_root) 所指視窗尚未載入 [watermark-js-plus.js](../js/watermark-js-plus.js.md) 時，補充載入一次
**輸入**: 無（`htmlBase` 見 [CXL:csCommon](../taglib/CXL-csCommon.md#htmlbase)）
**輸出**: 無
**輸出條件**:
- 目前頁面啟用個人化浮水印（[isWaterMark](#iswatermark) 為真），且 [watermark_root](#watermark_root) 所指視窗尚無已載入之浮水印套件時觸發；已載入時略過

## WatermarkPlus.Watermark 呼叫
**使用情境**: 顯示個人化浮水印
**使用方式**:
```js
new WatermarkPlus.Watermark({
    "contentType" : "multi-line-text",
    "content" : watermark_personal_info_txt + "\n${watermark_datetime}",
    "width" : 190,
    "height" : 85,
    "lineHeight": 20,
    "fontColor" : "#000",
    "fontWeight" : "normal",
    "fontSize" : "16px",
    "fontFamily" : "Microsoft JhengHei",
    "rotate" : 17,
    "globalAlpha" : 0.07,
    "mutationObserve" : true,
    "monitorProtection" : true,
    "layout" : "grid",
    "gridLayoutOptions" : { rows: 2, cols: 2, gap: [-18, -8], matrix: [[1, 0], [0, 1]] }
}).create()
```
**主要功能**:
- 以 [watermark_txt / watermark_escapeHtml_txt](#watermark_txt-watermark_escapehtml_txt) 及 [watermark_datetime](#watermark_datetime) 組成之兩行文字，建立並顯示個人化浮水印（呼叫方式與選項意義見 [watermark-js-plus.js](../js/watermark-js-plus.js.md#watermarkpluswatermarkoptions)）
**輸入**: 詳見 [watermark-js-plus.js](../js/watermark-js-plus.js.md#watermarkpluswatermarkoptions) 各選項說明
**輸出**: 無
**輸出條件**:
- 目前頁面啟用個人化浮水印（[isWaterMark](#iswatermark) 為真），且頁面載入完成時觸發一次

## EUDC 字型資源請求
**使用情境**: 提供頁面所需之 EUDC 造字字型
**使用方式**:
```css
@font-face{
    font-family: 'EUDC';
    src:  <c:if test="${not empty internetFontUrl}">
          url('${internetFontUrl}eudc.woff2') format("woff2"),
          url('${internetFontUrl}eudc.ttf') format("truetype"),
          </c:if>
          url('${pageContext.request.contextPath}/hanlinks/eudc.woff2') format("woff2"),
          url('${pageContext.request.contextPath}/hanlinks/eudc.ttf') format("truetype");
    font-weight:normal;
    font-style:normal;
}
```
**主要功能**:
- 依 [internetFontUrl](#internetfonturl) 是否有值，決定 EUDC 字型資源之來源組合
**輸入**: 無（`internetFontUrl` 見上）
**輸出**: 無
**輸出條件**:
- `internetFontUrl` 有值時，優先加入以該值為前綴之 CDN 字型來源（`woff2`、`truetype` 各一）
- 另固定加入以目前應用程式根路徑下 `/hanlinks/` 為前綴之字型來源（`woff2`、`truetype` 各一），做為額外或唯一來源
