# SHARED-CM-includes — 共用引入檔（header / msgDisplayer）

> 來源：`sourceCode/CM/header.jsp`（413 行，BIG5）
> 　　　`sourceCode/CM/msgDisplayer.jsp`（188 行，BIG5）
> 複雜度層級：高
> SoT 版本：v3　生成日期：2026-09-15
> 行數計數口徑：**實際行數（計入無結尾換行的末行）**。
> 兩檔末行皆無結尾換行（`tail -c 1` 為 `>`），故 `wc -l` 各為 412 / 187，比本文件所用口徑少 1。
> 本文件引用的所有行號，皆以此口徑為準（即 `iconv -f BIG5 -t UTF-8 <檔> | cat -n` 的編號）。

> **▶ 各畫面 SoT 引用本文件時，主要參照 §19（對引入端的輸出契約）與 §20（引入端需自行決定的條件值）。**
> 依規則 L1，這兩個檔案的行為與缺陷只寫在本文件；各畫面 SoT 只寫三件事：引用了什麼、本畫面的實際條件值、本畫面受影響的具體行為。

標記約定：`[UNKNOWN]` 未知、`[DEFECT]` 現況缺陷、`[DEAD-CODE]` 死碼、`[ASSUMPTION]` 推論（附推論依據與成立條件）。

---

## 0. 檔頭資訊

| 項目 | header.jsp | msgDisplayer.jsp |
|---|---|---|
| 程式名稱 | 檔內無檔頭註解 | 檔內無檔頭註解 |
| 原始作者 | 檔內無記載 | 檔內無記載 |
| 完成日期 | 檔內無記載 | 檔內無記載 |
| 功能說明（原文） | 檔內無整體功能說明；僅有片段註解，見 §16 | 檔內無整體功能說明；僅有片段註解，見 §16 |

備註：兩檔皆無 §0 所要求的檔頭註解區塊。此事實影響 §16 變更軌跡的可得性（見 §16）。

## 1. 用途

`header.jsp` 是全站畫面的共同前置片段：它一次性建立畫面取用靜態資源與後端派送器所需的路徑變數、宣告全站共用的標籤庫與 Java 匯入，並依「功能代號」向後端查出該功能的資安管制設定，據以在畫面上加掛列印／複製／剪下／全選／存檔的管制與使用者浮水印。使用者不會直接感知這個檔案，但會感知它產生的管制提示與浮水印。

`msgDisplayer.jsp` 把後端這一次交易回傳的訊息集合搬到瀏覽器端，並提供全站統一的訊息呈現入口：畫面在動作完成後呼叫它提供的函式，由它決定把訊息送到框架下方的訊息欄、或以對話框彈出。作業人員看到的錯誤說明與錯誤編號來自這個檔案。

兩者都以 `<%@ include file %>` 靜態引入。全庫 603 個 JSP 中，520 個引入 `header.jsp`、486 個引入 `msgDisplayer.jsp`（計數指令見 §18.3）。

## 2. 頁面識別與進入點

**不適用（本檔非畫面）。** 兩檔都不是可單獨開啟的畫面，而是被引入的片段。以下改記引入契約：

| 項目 | header.jsp | msgDisplayer.jsp |
|---|---|---|
| 引入路徑 | `/html/CM/header.jsp` | `/html/CM/msgDisplayer.jsp` |
| 引入指令 | `<%@ include file="/html/CM/header.jsp"%>` | `<%@ include file="/html/CM/msgDisplayer.jsp"%>` |
| 引入方式 | 靜態引入（編譯期合併，與引入端共用同一個 `pageContext`／`out`／隱含物件） | 同左 |
| 慣用位置 | 引入端檔案開頭（範例：`sourceCode/AF/AFY10100.jsp` 第 3 行） | 引入端 `<body>` 內（範例：`sourceCode/AF/AFY10100.jsp` 第 32 行） |
| 引入端家數 | 520 個 JSP | 486 個 JSP |
| 呼叫端契約 | 引入端不需提供回呼；但引入端／後端提供的請求範圍屬性決定本檔輸出，見 §20 | 引入端須自行呼叫 `displayMessage()` 才會呈現訊息，見 §19.2 |

`/html/` 對應本 repo 的 `sourceCode/`。

## 3. 渲染契約（伺服器端求值）

### 3.1 header.jsp — 產生輸出的求值點（共 18 處：16 個 EL、2 個 `<%= %>`）

| 來源運算式 | 行號 | 落點 | 前端可變更 | 正常值輸出 | 空值/null 輸出 | 不可解析值輸出 | 備註 |
|---|---|---|---|---|---|---|---|
| `<%=ConfigManager.getProperty("ebaf.JSP_CHAR_LENGTH","2")%>` | 34 | JS 單引號字串字面量（指派給 `window.charCountsByte`） | 否（可於載入後以腳本改寫該全域變數） | 設定檔中的字串值 | 查無該設定時輸出第二引數 `2`；設定值為空字串時輸出空字串，第 35 行的正規表示式比對失敗，回退為數字 `2` | 非數字字串（如 `abc`）照樣輸出，第 35 行比對失敗後回退為 `2` | `ConfigManager` 不在可讀範圍 → §14 U-01。值若含 `'` 或換行，會破壞此 JS 字面量 → §15 D-01 |
| `${requestTimeHandleUUID}` | 46 | JS 單引號字串字面量（`utility.keepResponseTimeEndParameters()` 的引數） | 否 | 原值，未經任何轉義 | 由第 43 行 `<c:if test="${not empty requestTimeHandleUUID}">` 包住，空值時整段（43–54 行）不輸出 | 不適用（EL 直接輸出字串值） | 值含 `'` 會破壞字面量 → §15 D-01 |
| `<c:out value="${eBAF_loginPlatformInfo}"/>` | 58 | JS 單引號字串字面量（`opt['eBAF_loginPlatformInfo']` 的值） | 否 | `c:out` 未指定 `escapeXml`，採預設值 → 輸出 HTML 實體轉義後的字串 `[ASSUMPTION]`（依據：JSTL 標準規格 `escapeXml` 預設為 `true`；成立條件：容器所用的 JSTL 實作遵循該預設 → §14 U-02） | 由同列 `<c:if test="${not empty ...}">` 包住，空值時該列不輸出 | 不適用 | 轉義後的 `&amp;` `&#039;` 等實體，在 JS 字串情境不會被還原 → §15 D-02 |
| `<c:out value="${eBAF_loginSystemInfo}"/>` | 59 | 同上 | 否 | 同上 | 同上 | 不適用 | 同上 |
| `<c:out value="${eBAF_UserObject_Flag}"/>` | 60 | 同上 | 否 | 同上 | 同上 | 不適用 | 同上 |
| `<c:out value="${platformDispatcher}"/>` | 61 | 同上 | 否 | 同上 | 同上 | 不適用 | 同上 |
| `${htmlBase}` | 303 | HTML 屬性 `<script src='…'>` | 否 | CXL 標籤設定的靜態資源基底路徑 | 輸出空字串，`src` 成為 `/CM/js/ui/watermark-js-plus.js`（相對於站台根） | 不適用 | 值格式（是否帶結尾斜線、是否為絕對路徑）→ §14 U-03 |
| `${internetFontUrl}` | 308 | CSS `url('…eudc.woff2')` 內 | 否 | 與 `eudc.woff2` 直接字串串接 | 由第 307 行 `<c:if test="${not empty internetFontUrl}">` 包住，空值時 308–309 行不輸出 | 不適用 | 值若不以 `/` 結尾，串接結果為錯誤路徑 → §14 U-04 |
| `${internetFontUrl}` | 309 | CSS `url('…eudc.ttf')` 內 | 否 | 同上 | 同上 | 不適用 | 同上 |
| `${pageContext.request.contextPath}` | 311 | CSS `url('…/hanlinks/eudc.woff2')` 內 | 否 | 應用程式 context path | 部署於根 context 時 EL 求值為空字串，路徑成為 `/hanlinks/eudc.woff2` | 不適用 | 此為 JSP 隱含物件，值由容器決定 |
| `${pageContext.request.contextPath}` | 312 | CSS `url('…/hanlinks/eudc.ttf')` 內 | 否 | 同上 | 同上 | 不適用 | 同上 |
| `${htmlBase}` | 344 | JS 單引號字串字面量（`_script.setAttribute('src', …)`） | 否 | 同第 303 行 | 同第 303 行 | 不適用 | 與第 303 行載入同一支腳本 → §15 D-03 |
| `<c:out value="${headerRequestFuncId}"/>` | 354 | JS 單引號字串字面量（`watermark_funcIds.push()` 的引數） | 否 | HTML 實體轉義後的功能代號 `[ASSUMPTION]`（同 U-02） | 第 94 行未設定此屬性時輸出空字串，push 進去的是空字串 | 不適用 | 值由 §8.2 推導 |
| `${watermark_escapeHtml_txt}` | 358 | JS 單引號字串字面量（`DOMParser().parseFromString()` 的第一引數） | 否 | 第 284 行 `StringEscapeUtils.escapeHtml()` 的輸出 | 第 284 行對空字串輸出空字串 | 不適用 | `escapeHtml` 不轉義單引號 `[ASSUMPTION]`（依據：commons-lang `escapeHtml` 的轉義集；成立條件：所用版本行為與此一致 → §14 U-05）→ §15 D-04 |
| `${watermark_txt}` | 360 | JS 單引號字串字面量 | 否 | 未經任何轉義的原值 | 空字串 | 不適用 | 走此分支的前提是瀏覽器無 `DOMParser`（第 357 行）→ §15 D-04 |
| `${watermark_datetime}` | 365 | JS 雙引號字串字面量（`"content"` 的串接項） | 否 | `yyyy-MM-dd HH:mm:ss`（第 283 行的 `SimpleDateFormat` 樣式），值為**伺服器產生本頁的時刻**，不隨瀏覽時間更新 | 第 283 行以 `new Date()` 產生，無空值路徑 | 不適用 | 格式固定，不含引號字元 |
| `<c:out value="${headerRequestFuncId}"/>` | 392 | JS 單引號字串字面量（`watermark_funcIds.indexOf()` 的引數） | 否 | 同第 354 行 | 同第 354 行 | 不適用 | 與 354 行成對，供移除用 |
| `<%=headerRequestFuncId%>` | 180 | JS 單引號字串字面量，隨後串進查詢字串 `&FUNC_ID=` | 否 | §8.2 推導出的功能代號 | 空字串（此時整段 101–256 行不會輸出，見 §3.3） | 不適用 | 未經 URL 編碼與 JS 轉義 → §15 D-01 |

### 3.2 msgDisplayer.jsp — 產生輸出的求值點（共 9 處 `<%= %>`，無 EL）

| 來源運算式 | 行號 | 落點 | 前端可變更 | 正常值輸出 | 空值/null 輸出 | 不可解析值輸出 | 備註 |
|---|---|---|---|---|---|---|---|
| `<%=msg.getLength()%>` | 18 | JS 數值字面量（`new Array(n)` 的引數） | 否 | 訊息筆數 | 無訊息時由第 11–13 行以 `new ReturnMessage(0,"","","","","")` 取代，其 `getLength()` 回傳值 → §14 U-06 | 不適用 | `ReturnMessage` 不在可讀範圍 |
| `<%=msgidx%>` | 54 | JS 陣列索引字面量 `msgs[n]` | 否 | 0 起算的序號 | 迴圈零次時本行不輸出 | 不適用 | 見 §8.7 |
| `<%=showmsg[msgidx][0]%>` | 54 | JS 雙引號字串字面量（訊息說明） | 否 | 已於第 29 行把 `\r\n`／`\n`／`\r` 換成 `<br>`，JS 端第 54 行再 `.replace(/<br>/gi,"\n")` 換回換行 | 來源為 null 時第 31 行改為空字串 | 不適用 | 未做 JS 字串轉義；值含 `"` 或 `\` 會破壞字面量 → §15 D-05 |
| `<%=showmsg[msgidx][1]%>` | 54 | JS 雙引號字串字面量（錯誤編號 msgid） | 否 | 同上（第 35 行換行處理，JS 端還原） | 來源為 null 時第 37 行改為空字串 | 不適用 | 同上 |
| `<%=showmsg[msgidx][2]%>` | 54 | JS 雙引號字串字面量（sysid／程式 ID） | 否 | 原值 | 來源為 null 時第 47 行以三元運算取空字串 | 不適用 | 同上 |
| `<%=showmsg[msgidx][3]%>` | 54 | JS 雙引號字串字面量（type） | 否 | 原值 | 第 48 行取空字串 | 不適用 | 本檔內無任何位置讀取索引 3 → §15 D-06 |
| `<%=showmsg[msgidx][4]%>` | 54 | JS 雙引號字串字面量（url） | 否 | 原值 | 第 49 行取空字串 | 不適用 | 本檔內無任何位置讀取索引 4 → §15 D-06 |
| `<%=showmsg[msgidx][5]%>` | 54 | JS 雙引號字串字面量（returnCode） | 否 | 第 50 行以 `getReturnCode()+""` 轉字串，輸出為十進位整數字樣 | `int` 無 null 路徑 | 不適用 | 比較值見 §11.1 |
| `<%=showmsg[msgidx][6]%>` | 54 | JS 雙引號字串字面量（displayException） | 否 | 已於第 41 行把換行換成 `<br>`，但 JS 端**未**做 `.replace(/<br>/gi,"\n")` 還原 | 來源為 null 時第 43 行改為空字串 | 不適用 | 換行以字面 `<br>` 呈現於對話框 → §15 D-07 |

### 3.3 條件渲染（伺服器端決定元素是否輸出）

| 條件運算式 | 行號 | 控制的元素 | 判定規則 |
|---|---|---|---|
| `StringUtils.isNotBlank(headerRequestFuncId)` | 88（閉合於 260） | 整個列印／複製管制區塊（101–256 行）與 `headerRequestFuncId`／`isWaterMark` 兩個屬性的設定 | 功能代號推導結果非空白，推導規則見 §8.2 |
| `headerFindList != null && !headerFindList.isEmpty()` | 92（閉合於 259） | 同上 | `new ZZ_Z0Z001().getFuncInfo(funcId)` 至少回傳一筆；該類別不在可讀範圍 → §14 U-07 |
| `"Y".equals(headerPdCtrl)`，`headerPdCtrl = ObjectUtils.toString(headerfMap.get("PD_CTRL"))` | 98（閉合於 258） | `<style>`（101–112 行，列印遮蔽）與 `<script>`（114–256 行，複製/剪下/全選/存檔管制與複製稽核） | 後端 `PD_CTRL` 欄位值等於字串 `Y` |
| `<c:if test="${not empty requestTimeHandleUUID}">` | 43–54 | 回應時間量測參數的註冊程式碼 | 請求範圍中 `requestTimeHandleUUID` 非空 |
| `<c:if test="${not empty eBAF_loginPlatformInfo \|\| not empty eBAF_loginSystemInfo \|\| not empty eBAF_UserObject_Flag \|\| not empty platformDispatcher}">` | 55–64 | `utility.keep_eBAF_parameter(opt)` 呼叫整段 | 四個屬性至少一個非空 |
| `<c:if test="${not empty eBAF_loginPlatformInfo}">` | 58 | `opt['eBAF_loginPlatformInfo']=…` 單列 | 該屬性非空 |
| `<c:if test="${not empty eBAF_loginSystemInfo}">` | 59 | `opt['eBAF_loginSystemInfo']=…` 單列 | 該屬性非空 |
| `<c:if test="${not empty eBAF_UserObject_Flag}">` | 60 | `opt['eBAF_UserObject_Flag']=…` 單列 | 該屬性非空 |
| `<c:if test="${not empty platformDispatcher}">` | 61 | `opt['platformDispatcher']=…` 單列 | 該屬性非空 |
| `StringUtils.isNotBlank(clientheaderhost) && clientheaderhost.contains("w3.cathaylife.com.tw")` | 293 | 是否設定 `internetFontUrl` 屬性（間接控制 308–309 行） | 請求標頭 `clientheaderhost` 含該網域字樣 |
| `<c:if  test="${not empty internetFontUrl}">` | 307–310 | `@font-face` 中兩列外部字型 `url()`（308–309 行） | 上一列條件成立且 `FieldOptionList.getName("PT","STATIC_FILE_URL","INTERNET_FONT")` 回傳非空 → §14 U-08 |
| `<c:if test="${isWaterMark}">` | 328–412 | 整個浮水印啟動區塊（330–411 行） | 第 95 行以 `"Y".equals(headerfMap.get("IS_WATERMARK"))` 設定的 `Boolean` 為真 |
| `msg == null` | 11（msgDisplayer） | 決定改用 `new ReturnMessage(0,"","","","","")` 作為訊息來源 | 第 7 行取不到資料或第 8 行捕捉到 `ClassCastException` |

`<c:if>` 開啟標籤共 8 個（含第 307 行 `<c:if` 與 `test` 之間有兩個空白的寫法）；`<c:out>` 共 6 個。計數指令見 §18.3。

### 3.4 迴圈渲染

| 集合來源 | 行號 | 產出元素 | 每列攜帶的資料 |
|---|---|---|---|
| `msg.hasNext()` / `msg.next()`（`ReturnMessage` 迭代器介面） | msgDisplayer 25–58 | 每筆訊息輸出一列 `msgs[i] = new Array(…7 個元素…);`（第 54 行） | 依序為：訊息說明、錯誤編號、程式 ID(sysid)、type、url、returnCode、異常說明 |

header.jsp 內無迴圈渲染（第 80 行的 `for` 迴圈只在伺服器端推導字串，不產生輸出）。

## 4. 版面規格

### 4.1 區塊結構

**header.jsp**（皆為非可視或全域覆蓋層，無版面區塊）：

1. `<CXL:csCommon>` 標籤（26–29 行）— 無輸出元素，設定四個變數
2. `<script>`（32–66 行）— 字元計數設定與 eBAF 參數保存
3. `<style>`（101–112 行，條件輸出）— 列印遮蔽樣式
4. `<script>`（114–256 行，條件輸出）— 複製／剪下／全選／存檔管制
5. `<script src>`（303 行）— 浮水印函式庫載入
6. `<style>`（304–316 行）— `@font-face` 難字字型 `EUDC`
7. `<script>`（317–413 行）— 同源判定與浮水印啟動（330–411 行為條件輸出）

**msgDisplayer.jsp**：單一 `<script>`（16–188 行），無任何可視元素。

### 4.2 語意樣式對映

| 樣式名稱／選擇器 | 語意 | 位置 |
|---|---|---|
| `@media print { body>* { display:none !important } }` | 列印時遮蔽頁面全部直接子元素 | header 102–105 |
| `@media print { body::after { content:'…'; display:block !important } }` | 列印時改以固定告示文字取代版面內容 | header 106–110 |
| `@font-face { font-family:'EUDC' }` | 難字（造字）字型，供畫面以 `font-family: EUDC` 引用 | header 305–315 |

告示文字內容見 §11.2。

### 4.3 版面細節

**不適用（本檔非畫面）。** 兩檔皆不輸出表格或表單版面。浮水印覆蓋層的幾何參數由 §11.1 的浮水印設定常數決定（190×85、行高 20、旋轉 17 度、透明度 0.07、2×2 網格、間距 `[-18,-8]`、矩陣 `[[1,0],[0,1]]`），該覆蓋層由外部函式庫繪製，實際版面表現 → §14 U-09。

## 5. 欄位規格

**不適用（本檔非畫面）。** 機械檢查確認兩檔皆無 `<input>`／`<select>`／`<textarea>` 元素，亦無 `id=` 屬性（計數皆為 0，指令見 §18.3）。

### 5.1 顯示欄位與送出欄位不一致者

**不適用（本檔無欄位）。** 但有一組類似性質的不一致，登記於 §15 D-08：複製稽核送出的 `COPY_CONTENT` 為截斷並自訂編碼後的文字，`COPY_LENGTH` 則是截斷前、空白正規化後的長度（header 165–180 行）。

## 6. 服務契約

### 6.1 複製內容稽核紀錄（header.jsp）

| 項目 | 內容 |
|---|---|
| 位址 | `/ZZWeb/servlet/HttpDispatcher/ZZM0_0105/ctrlMsavelog`（header 179 行，硬編碼絕對路徑，未使用 `${dispatcher}` 或 context path） |
| 方式 | 以 `document.createElement("img")` 建立影像元素並設定 `src` 觸發 GET 請求（177–181 行）；該元素未加入 DOM |
| 觸發 | `document.body` 的 `copy` 事件（132 行註冊 `validateCopy`）；前提為該功能的 `PD_CTRL` 為 `Y` |
| 請求參數 | `COPY_CONTENT`＝選取文字，來源為 `fpcsGetSelectionText()`（185–210 行），經第 153 行空白正規化、第 165–167 行超過 5000 字截斷為前 4997 字加 `...`、第 169–175 行七項自訂字元替換；<br>`FUNC_ID`＝`<%=headerRequestFuncId%>`（180 行，伺服器端推導，見 §8.2）；<br>`COPY_LENGTH`＝`fpcsSelectedText.length`（180 行，截斷**前**的長度）；<br>`TS`＝`new Date().getTime()`（180 行，毫秒時戳，作用為避開快取） |
| 成功回應 | 不讀取。以影像載入方式發出，回應內容與狀態碼皆未被程式取用 |
| 失敗處理 | **無** `[DEFECT]` → §15 D-09。未註冊 `onerror`／`onload`，請求失敗時畫面無任何提示，複製動作照常完成 |

### 6.2 浮水印函式庫載入（header.jsp）

| 項目 | 內容 |
|---|---|
| 位址 | `${htmlBase}/CM/js/ui/watermark-js-plus.js` |
| 方式 | 兩條路徑：(a) 第 303 行的靜態 `<script src>`，無條件輸出；(b) 第 342–345 行動態建立 `<script>` 並附加到 `root_wm.document.head` |
| 觸發 | (a) 頁面解析時；(b) `${isWaterMark}` 為真且 `root_wm.watermark` 為假值時（341 行） |
| 請求參數 | 無 |
| 成功回應 | 提供全域 `WatermarkPlus`（第 363 行使用 `new WatermarkPlus.Watermark({...})`）；檔案本身不在本輪可讀範圍 → §14 U-09 |
| 失敗處理 | **無** `[DEFECT]` → §15 D-10。腳本載入失敗時，第 363 行拋出例外，由第 382 行的 `catch` 捕捉並僅寫 console，畫面無浮水印且無提示 |

### 6.3 跨框架訊息派送（msgDisplayer.jsp）

這不是後端呼叫，但具有同等的「對外契約」性質，故比照登記。

| 項目 | 內容 |
|---|---|
| 目標 | 下方訊息框架視窗（取得方式見 §8.10） |
| 方式 | 直接呼叫該視窗的全域函式 |
| 觸發 | 引入端呼叫 `displayMessage()`（137 行）或 `msgDisplayer.clearBottomMsg()`（73 行）；`clearBottomMsg` 另由第 174 行的 `document.onclick` 觸發 |
| 請求參數 | `showNotifyMsg({'returnCode': msgs[0][5], 'returnMessage': msgs[0][0]})`（160–163 行）；`clearNotifyMsg()` 無參數（84 行） |
| 成功回應 | 兩者的回傳值皆未被讀取；`showNotifyMsg`／`clearNotifyMsg`／`cathay_common_msgBoard`／`txHasRollbackPage` 的定義不在本輪可讀範圍 → §14 U-10 |
| 失敗處理 | 以空的 `catch(err){}` 吞掉（166–167 行、87–88 行）`[DEFECT]` → §15 D-11 |

## 7. 狀態模型

### 7.1 模組級（全域）狀態變數

| 變數 | 檔／行 | 初值 | 意義 | 由誰改變 | 生命週期 |
|---|---|---|---|---|---|
| `window.charCountsByte` | header 34–39 | 設定檔值；比對失敗時為數字 `2`，成功時為 `parseInt` 後的整數 | 中文字計算位元組數時，一個中文字折算幾個位元組 | 本檔第 34/36/38 行；其後由外部腳本讀取 | 頁面存續期間 |
| `fpcsAlertMsgs` | header 119–126 | 六個鍵的物件字面量（`print`/`beforeprint`/`copy`/`cut`/`selectAll`/`save`） | 各管制動作的提示訊息文字 | 僅本檔初始化；第 115 行以 `typeof … !== 'object'` 防止重複定義 | 頁面存續期間 |
| `lastfpcsRecordText` | header 117 | `''` | 上一次已送出稽核的複製文字，供去重 | 第 160 行（60 秒後歸零）、第 163 行（設為本次文字） | 頁面存續期間 |
| `is_same_origin` | header 318–323 | `false`；成功取得 `window.top.document.domain` 且與本視窗相同時為 `true` | 是否與最上層視窗同源 | 僅第 320 行 | 頁面存續期間 |
| `window.top.watermark_funcIds` | header 325、350–352、396 | `[]` | 目前已套用浮水印的功能代號清單 | 第 325 行（`window.name == 'mainFrame'` 時重設）、第 354 行 push、第 396 行 splice | 最上層視窗存續期間（跨頁面切換保留） |
| `window.top.watermark_root` | header 326、337 | 設為本視窗或 `window.top` | 浮水印掛載的根視窗 | 第 326 行、第 337 行 | 最上層視窗存續期間 |
| `root_wm` | header 332–340 | `window`；同源且已有 `watermark_root` 時改為之 | 本次浮水印作業的目標視窗 | 僅初始化 | 該 IIFE 存續期間 |
| `msgs` | msgDisplayer 18、54 | `new Array(<%=msg.getLength()%>)`，逐列以第 54 行填入 | 本次交易的訊息集合，每筆 7 個元素 | 僅伺服器端輸出時決定 | 頁面存續期間 |
| `msgDisplayer` | msgDisplayer 61–90 | 含 `getBottomFrame`、`clearBottomMsg` 兩個方法的物件字面量 | 訊息呈現的命名空間 | 僅初始化 | 頁面存續期間 |
| `document.onclick` | msgDisplayer 174–185 | 指派為匿名函式 | 全域點擊攔截，用於清除下方訊息 | 以**指派**（非 `addEventListener`）設定 → §15 D-12 | 頁面存續期間或直到被覆寫 |

`msgs`（第 18 行）以無宣告關鍵字的指派建立，成為隱含全域變數 → §15 D-13。

### 7.2 狀態轉換

| 事件 | 前置條件 | 狀態變化 | 畫面變化 |
|---|---|---|---|
| 頁面載入完成（`load`） | `PD_CTRL = Y` | 於 `document.body` 與 `window` 註冊 6 組監聽（129–136 行） | 無立即可見變化 |
| 頁面載入完成（`load`） | `IS_WATERMARK = Y` | `root_wm.watermark_funcIds` 推入本功能代號（354 行） | 建立浮水印覆蓋層（380 行 `watermarkPlus.create()`） |
| 使用者按右鍵 | `PD_CTRL = Y` | 無狀態變化 | `contextmenu` 被 `fpcsStopEventActions` 阻止（129 行）；`fpcsAlertMsgs['contextmenu']` 未定義，因此不彈出提示 |
| 使用者按 Ctrl+A / X / S / P | `PD_CTRL = Y` | 無狀態變化 | 阻止預設行為並彈出對應提示（136–147 行，見 §8.5） |
| 使用者複製（`copy` 事件） | `PD_CTRL = Y` | `lastfpcsRecordText` 更新為本次文字；60 秒後歸零 | **不阻止複製**；靜默送出稽核請求（見 §8.4 與 §15 D-14） |
| 使用者剪下（`cut` 事件） | `PD_CTRL = Y` | 無 | 阻止剪下並彈出 `cut` 提示（133 行） |
| 列印 | `PD_CTRL = Y` | 無 | 由 `@media print` 樣式遮蔽版面並顯示告示文字（101–112 行） |
| 引入端呼叫 `displayMessage()` | 取得下方訊息框架且其 `txHasRollbackPage` 為假值 | 無 | 呼叫 `showNotifyMsg` 顯示第一筆訊息，接著執行 `alertMessages()` |
| 引入端呼叫 `displayMessage()` | 下方訊息框架的 `txHasRollbackPage` 為真值 | 該旗標被設為 `null`（146/152 行） | **提早 return**，不呼叫 `showNotifyMsg`；但第 169 行的 `alertMessages()` 在 `try` 之外，故仍會執行 |
| 使用者點擊 `type` 含 `button` 或 `submit` 的元素 | 取得下方訊息框架 | 無 | 呼叫 `clearNotifyMsg()` 清除下方訊息（174–185 行） |

## 8. 演算法規格

### 8.1 字元位元組數設定正規化（header 34–39）

**目的**：把設定檔字串轉成可供字數驗證使用的正整數。
**輸入**：`ebaf.JSP_CHAR_LENGTH` 設定值（字串），查無時為 `"2"`。
**輸出**：`window.charCountsByte`（數字）。
**虛擬碼**：
```
charCountsByte ← 設定值字串
IF 不符合正規表示式 /^[1-9][0-9]*$/ THEN
    charCountsByte ← 2            // 數字
ELSE
    charCountsByte ← parseInt(charCountsByte, 10)
END IF
```
**邊界條件**：空字串、`0`、`01`、負數、含空白、非數字字樣皆不符合該正規表示式，回退為 `2`。第 35 行以裸名 `charCountsByte` 讀取（依賴其為 `window` 屬性），第 36/38 行則寫 `window.charCountsByte`。第 33 行註解寫「1 letter counts 3 bytes」，與程式的預設值 `2` 不一致 → §15 D-15。

### 8.2 功能代號推導（header 70–86）

**目的**：得出本次請求對應的功能代號，作為查詢資安管制設定與稽核紀錄的鍵。
**輸入**：`HttpResponseContext(request).getBeanName()`、`request.getRequestURL()`。
**輸出**：`headerRequestFuncId`（字串，可能為空字串）。
**虛擬碼**：
```
beanName ← new HttpResponseContext(request).getBeanName()
funcId   ← ""
IF beanName 非空白 THEN
    funcId ← 移除 beanName 中所有 "_" 字元
END IF
IF funcId 為空白 THEN
    urls ← request 的完整 URL 以 "/" 切開
    FOR EACH seg IN urls
        IF seg 含有 ".jsp" THEN
            funcId ← 移除 seg 中的 ".jsp"
            BREAK                      // 取第一個符合者
        END IF
    END FOR
END IF
```
**邊界條件**：兩條路徑都取不到時 `funcId` 為空字串，第 88 行的 `isNotBlank` 為假，整個管制區塊與 `headerRequestFuncId`／`isWaterMark` 屬性都不產生。URL 路徑中含多個 `.jsp` 片段時取最靠前者。`StringUtils.remove(seg, ".jsp")` 移除的是**所有**出現位置，不限結尾。`HttpResponseContext` 與 `getBeanName()` 的語意 → §14 U-11。

### 8.3 浮水印使用者文字取得（header 267–288）

**目的**：取得浮水印上要顯示的人員識別文字。
**輸入**：session 屬性 `$Data.$coreSys$UserObject`。
**輸出**：`watermark_txt`（原值）、`watermark_escapeHtml_txt`（HTML 轉義後）、`watermark_datetime`。
**虛擬碼**：
```
str_wm ← null
IF session 不為 null THEN
    userObj ← session.getAttribute("$Data.$coreSys$UserObject")
    IF userObj 不為 null THEN
        str_wm ← userObj.getCATHAY_NO()
        IF str_wm 為 null THEN str_wm ← userObj.getEmpName()
    END IF
END IF
IF str_wm 為 null THEN str_wm ← ""
watermark_datetime        ← 現在時刻，格式 "yyyy-MM-dd HH:mm:ss"
watermark_escapeHtml_txt  ← StringEscapeUtils.escapeHtml(str_wm)
watermark_txt             ← str_wm
```
**邊界條件**：`getCATHAY_NO()` 回傳空字串（非 null）時不會退到 `getEmpName()`，浮水印文字為空字串。整段包在 `try/catch(Exception)` 中，例外只寫 `printStackTrace()`，三個屬性可能都未設定，此時 §3.1 第 358/360/365 行的 EL 求值為空字串 → §15 D-16。`UserObject` 不在可讀範圍 → §14 U-12。

### 8.4 複製稽核（header 149–183）

**目的**：在不阻擋複製的前提下，把使用者複製的內容送回後端留存軌跡。
**輸入**：`copy` 事件。
**輸出**：一筆 GET 請求（見 §6.1）。
**虛擬碼**：
```
selected ← fpcsGetSelectionText()                    // 見 8.4.1
selected ← selected 中連續空白字元（/\s+/g）全部換成單一空白
record   ← selected
IF record.length > 0 AND lastfpcsRecordText ≠ record THEN
    設定 60000 毫秒後的計時器：lastfpcsRecordText ← ""
    lastfpcsRecordText ← record
    IF record.length > 5000 THEN
        record ← record 前 4997 字 + "..."
    END IF
    依序替換：% → %25、# → %23、& → %26、空白 → %20、+ → %2B、? → %3F、= → %3D
    img ← document.createElement("img")
    img.src ← ".../ctrlMsavelog?COPY_CONTENT=" + record
              + "&FUNC_ID=" + <funcId>
              + "&COPY_LENGTH=" + selected.length
              + "&TS=" + 現在毫秒
END IF
```
**邊界條件**：
- 去重只比對**緊接的前一次**複製；複製 A→B→A（60 秒內）時 A 會被送出兩次。
- 計時器在每次符合條件時都新建一個，多次複製會排入多個 60 秒後的歸零動作。
- 替換順序把 `%` 放第一位，避免後續替換產生的 `%xx` 被二次編碼；但替換清單不含 `"`、`<`、`>`、`;` 與非 ASCII 字元。非 ASCII 字元（中文）交由瀏覽器在設定 `src` 時自行編碼，伺服器端的解碼字集 → §14 U-13。
- `COPY_LENGTH` 用截斷前的長度，`COPY_CONTENT` 是截斷後的內容 → §15 D-08。
- 第 132 行以 `validateCopy` 註冊，該函式內**沒有**任何阻止預設行為的呼叫，複製動作照常完成 → §15 D-14。

#### 8.4.1 取得選取文字（header 185–210）

```
IF window.getSelection 存在 THEN
    IF document.activeElement 存在 AND 其標籤名為 "textarea" THEN
        取 activeElement.value 的 [selectionStart, selectionEnd) 子字串
    ELSE
        取 window.getSelection().toString()
    END IF
ELSE
    取 document.selection.createRange().text          // 舊版 IE 路徑
END IF
```
**邊界條件**：`<input type="text">` 內的選取不走 textarea 分支（第 192 行只比對 `textarea`），改走 `window.getSelection()`，其對表單控制項的回傳值 → §14 U-14。

### 8.5 熱鍵攔截（header 136–147）

**目的**：阻擋全選、剪下、存檔、列印四組熱鍵並提示。
**輸入**：`window` 的 `keydown` 事件（以 capture 模式註冊，見 §8.6）。
**虛擬碼**：
```
IF e.ctrlKey THEN
    IF e.keyCode ∈ {65, 88, 83, 80} THEN
        stopEventActions(e)                        // 見下
        IF e.keyCode = 88 AND fpcsAlertMsgs['cut']       THEN alert(cut 訊息)
        IF e.keyCode = 65 AND fpcsAlertMsgs['selectAll'] THEN alert(selectAll 訊息)
        IF e.keyCode = 83 AND fpcsAlertMsgs['save']      THEN alert(save 訊息)
        IF e.keyCode = 80 AND fpcsAlertMsgs['print']     THEN alert(print 訊息)
        RETURN false
    END IF
END IF

stopEventActions(e):                               // 212–216 行
    forceStopEvent(e)                              // 218–226 行
    showStopAlertMessage(e)                        // 228–230 行
    RETURN false

forceStopEvent(e):
    IF e 且 e.stopPropagation 存在 THEN e.stopPropagation(); e.preventDefault()
    ELSE IF e 且 (e.cancelBubble ≠ undefined 或 e.cancelBubble ≠ null) THEN
        e.cancelBubble ← true; e.returnValue ← false
    END IF

showStopAlertMessage(e):
    IF e.type 存在 AND fpcsAlertMsgs[e.type] 存在 THEN alert(fpcsAlertMsgs[e.type])
```
**邊界條件**：
- `showStopAlertMessage` 以 `e.type` 查表，`keydown` 不是 `fpcsAlertMsgs` 的鍵，因此這條路徑不彈出提示；提示由 136–147 行的四條顯式判斷負責，每次按鍵彈出一個對話框。
- Ctrl+C（keyCode 67）不在攔截清單中；複製由 `copy` 事件的 `validateCopy` 處理，不阻擋。
- 第 122 行的提示文字要求「複製請改用 Ctrl+Q」，但本檔未攔截或處理 Ctrl+Q（keyCode 81）→ §14 U-15、§15 D-17。
- `forceStopEvent` 的 `else if` 條件 `e.cancelBubble !== undefined || e.cancelBubble !== null`：兩個條件以 `||` 相接，對任一值至少有一邊成立 → 該分支的判斷結果與 `e` 是否為真值相同。此判斷落在 `e.stopPropagation` 不存在的分支，屬舊瀏覽器路徑 → §15 D-18。

### 8.6 事件註冊相容層（header 245–254）

```
fpcsDoAddEventListener(element, eventName, func):
    IF element 為假值 OR (element ≠ window AND element ≠ document AND element.tagName 為假值) THEN
        RETURN                                     // 靜默略過
    IF element.addEventListener 存在 THEN
        element.addEventListener(eventName, func, true)     // capture 模式
    ELSE IF element.attachEvent 存在 THEN
        element.attachEvent('on' + eventName.toLowerCase(), func)
    ELSE
        element['on' + eventName.toLowerCase()] = func
    END IF
```
**邊界條件**：第三分支以指派方式設定，會覆寫該元素上同名的既有處理常式。第 130–131 行把 `print` 與 `beforeprint` 註冊在 `document.body` 上 → §15 D-19。

### 8.7 訊息陣列組裝（msgDisplayer 18–59，伺服器端）

**目的**：把後端 `ReturnMessage` 集合轉成瀏覽器端的二維陣列。
**虛擬碼**：
```
msgs ← new Array(msg.getLength())                  // 輸出到 JS，第 18 行
msglen ← msg.getLength()
showmsg ← new String[msglen][7]
msgidx ← 0
WHILE msg.hasNext():
    tmp ← msg.next()
    對 getDisplayMsgDescs()、getMsgid()、getDisplayException() 三者：
        為 null → 空字串
        非 null → 把 "\r\n"、"\n"、"\r" 依序換成 "<br>"
    showmsg[msgidx][0..6] ← 訊息說明, 錯誤編號, sysid, type, url, returnCode 字串化, 異常說明
    輸出一列：msgs[msgidx] = new Array( 七個字串字面量 )
              其中索引 0 與 1 在 JS 端再 .replace(/<br>/gi, "\n")
    msgidx ← msgidx + 1
```
**邊界條件**：
- `showmsg` 的長度取自 `getLength()`，迴圈次數取自 `hasNext()`。兩者若不一致（迴圈次數大於 `msglen`），第 45 行會拋出陣列索引越界；這段 scriptlet **不在** try/catch 內（本檔的 try 只涵蓋 6–10 行），例外會往上拋出 → §15 D-20。兩者是否可能不一致 → §14 U-06。
- 零筆訊息時第 54 行不輸出，`msgs` 長度為 0，影響 §8.9。
- 索引 6（異常說明）在 JS 端未還原 `<br>` → §15 D-07。
- 第 54 行的字串字面量未做 JS 轉義 → §15 D-05。

### 8.8 訊息彙整與呈現（msgDisplayer 103–135）

**目的**：把訊息集合彙整成單一字串並呈現。
**輸入**：全域 `msgs`。
**輸出**：對話框或 `WIUtil.displayMessage`。
**虛擬碼**：
```
alertMsg ← ""
FOR varindex 從 0 到 msgs.length - 1:
    IF msgs[i][6] = "" THEN                              // 無異常說明
        IF msgs[i][5] ≠ "0" AND msgs[i][5] ≠ "99" THEN   // 非成功、非 99
            alertMsg ← alertMsg + "訊息說明:\n" + msgs[i][0] + "\n"
            IF msgs[i][1] 為真值 THEN
                alertMsg ← alertMsg + "\n錯誤編號：\n" + msgs[i][1]
            END IF
        END IF
    ELSE                                                  // 有異常說明
        IF msgs[i][6] ≠ "" OR msgs[i][2] ≠ "" THEN
            alertMsg ← alertMsg + "異常原因:" + msgs[i][6] + "\n"
            alertMsg ← alertMsg + "\n程式ID:" + msgs[i][2] + "\n\n"
        END IF
    END IF
END FOR
IF alertMsg ≠ "" THEN
    IF window['WIUtil'] 與 window['jQuery'] 皆已定義 THEN
        WIUtil.displayMessage({msg: alertMsg})
    ELSE
        alert(alertMsg)
    END IF
END IF
```
**邊界條件**：
- returnCode `"99"` 的訊息不進對話框（第 108 行註解說明：保留給頁面下方訊息欄）。returnCode `"0"` 同樣不進對話框。
- 第 120 行的條件位於「`msgs[i][6] = ""` 為假」的分支內，其左半 `msgs[i][6] != ""` 與進入分支的條件相同，故 `|| msgs[i][2] != ""` 不改變判斷結果 → §15 D-21。
- 多筆訊息時字串連續累加，無筆數上限，無截斷。
- 第 112 行使用半形冒號「訊息說明:」，第 115 行使用全形冒號「錯誤編號：」，第 122/123 行使用半形冒號 → §15 D-22。
- `WIUtil` 的 `displayMessage` 契約 → §14 U-16。

### 8.9 下方訊息欄派送（msgDisplayer 137–171）

**目的**：把本次交易的第一筆訊息送到下方訊息欄，再彙整彈出其餘訊息。
**虛擬碼**：
```
TRY:
    bottomFrame ← msgDisplayer.getBottomFrame()
    IF bottomFrame 為真值 THEN
        target ← bottomFrame.contentWindow 若存在，否則 bottomFrame
        IF target.txHasRollbackPage 為真值 THEN
            target.txHasRollbackPage ← null
            RETURN                                    // 不呼叫 showNotifyMsg
        END IF
        showNotifyMsgFunc ← target.showNotifyMsg
        IF typeof showNotifyMsgFunc = 'function' THEN
            msgindex ← 0
            showNotifyMsgFunc({ returnCode: msgs[0][5], returnMessage: msgs[0][0] })
        END IF
    END IF
CATCH err:
    （空，不做任何事）
END TRY
alertMessages()                                       // 在 try 之外
```
**邊界條件**：
- `msgindex` 固定為 0：僅第一筆訊息送到下方訊息欄，其餘只能經由 §8.8 呈現 → §15 D-23。
- `msgs.length = 0` 時 `msgs[0]` 為 `undefined`，讀取 `[5]` 拋出型別錯誤，被空的 `catch` 吞掉；第 169 行的 `alertMessages()` 位於 try 之外，仍會執行（此時迴圈零次，不彈出任何對話框）。
- `txHasRollbackPage` 為真值時走早退路徑，但 `return` 只跳出 try 內的流程——因為 `return` 直接結束 `displayMessage`，第 169 行的 `alertMessages()` **不會**執行。

### 8.10 下方訊息框架搜尋（msgDisplayer 62–72）

```
IF top.frames['leftFrame'] 且 top.frames['leftFrame'].frames['bottomFrame'] 存在
    RETURN top.frames['leftFrame'].frames['bottomFrame']
ELSE IF parent.frames['leftFrame'] 且 parent.frames['leftFrame'].frames['bottomFrame'] 存在
    RETURN parent.frames['leftFrame'] && parent.frames['leftFrame'].frames['bottomFrame']
ELSE IF top.frames['bottomFrame'] 存在
    RETURN top.frames['bottomFrame']
ELSE IF parent.frames['bottomFrame'] 存在
    RETURN parent.frames['bottomFrame']
END IF
                                                      // 無 else：回傳 undefined
```
**邊界條件**：四個分支皆不成立時回傳 `undefined`，呼叫端以 `if(bottomFrame)` 處理。跨來源框架存取會拋出例外，由呼叫端的 try/catch 吞掉。第 66 行回傳 `&&` 運算式而非直接回傳框架物件，與第 64 行的寫法不一致 → §16.1。

### 8.11 浮水印掛載與功能代號維護（header 318–411）

**目的**：在最上層視窗建立使用者浮水印，並記錄目前套用浮水印的功能代號。
**虛擬碼**：
```
// 318–327 行，無條件執行
is_same_origin ← false
TRY: is_same_origin ← (window.top.document.domain = window.document.domain)
CATCH err: console.log(...)
IF is_same_origin AND window.name = 'mainFrame' THEN
    window.top.watermark_funcIds ← []               // 重設清單
    window.top.watermark_root    ← window
END IF

// 330–411 行，僅在 ${isWaterMark} 為真時輸出
root_wm ← window
IF is_same_origin THEN
    root_wm ← window.top.watermark_root 若存在
    否則 window.top.watermark_root ← window.top; root_wm ← window.top
END IF
IF root_wm.watermark 為假值 THEN
    動態建立 <script src='${htmlBase}/CM/js/ui/watermark-js-plus.js'>
    附加到 root_wm.document.head
END IF

onload 處理：
    root_wm.watermark_funcIds 不存在則建為 []
    root_wm.watermark_funcIds.push(<funcId>)
    IF typeof DOMParser = "function" THEN
        txt ← DOMParser().parseFromString('${watermark_escapeHtml_txt}', "text/html")
                  .documentElement.textContent
    ELSE
        txt ← '${watermark_txt}'
    END IF
    new WatermarkPlus.Watermark({ ...設定見 §11.1... }).create()

onberforeunload 處理：
    IF root_wm.watermark_funcIds 不存在 THEN RETURN
    idx ← root_wm.watermark_funcIds.indexOf(<funcId>)
    IF idx = -1 THEN RETURN
    root_wm.watermark_funcIds ← root_wm.watermark_funcIds.splice(idx, 1)

註冊（403–409 行）：
    IF window.addEventListener 已定義 THEN
        addEventListener('load',          headerWatermarkOnloadFunction)
        addEventListener('berforeunload', headerWatermarkOnloadFunction)     // ← 事件名與函式皆有問題
    ELSE
        attachEvent('onload',          headerWatermarkOnberforeunloadFunction)  // ← 函式有問題
        attachEvent('onberforeunload', headerWatermarkOnberforeunloadFunction)
    END IF
```
**邊界條件**：
- 第 396 行以 `splice` 的**回傳值**覆寫清單。`splice(idx,1)` 回傳被移除的元素陣列，因此清單被替換成只含剛移除的那一個代號 → §15 D-24。
- 第 325 行在 `window.name == 'mainFrame'` 的頁面每次載入都把清單清空，與 354/396 行的維護相衝突。
- 第 405 行的事件名為 `berforeunload`（拼寫與 `beforeunload` 不同），且註冊的是 `headerWatermarkOnloadFunction` → §15 D-25。
- 第 407 行把 `onload` 註冊為 `headerWatermarkOnberforeunloadFunction`（解除登記用的函式），此分支下不會建立浮水印 → §15 D-26。
- 第 341 行以 `root_wm.watermark` 判斷是否需要載入函式庫，第 363 行實際使用的全域名是 `WatermarkPlus`；兩者是否為同一物件不在本輪可讀範圍 → §14 U-09、§15 D-03。
- 第 358 行的內容經 `escapeHtml` → JS 字面量 → `DOMParser` 反解三道轉換；`escapeHtml` 不轉義單引號 → §15 D-04。
- 浮水印內容包含伺服器產生頁面的時刻（§3.1 第 365 行），停留期間不更新。

## 9. 驗證規則

**不適用（本檔非畫面、無使用者輸入欄位）。**

唯一具驗證性質的邏輯是設定值正規化（`/^[1-9][0-9]*$/`），已完整記於 §8.1，不在此重複。

## 10. 事件與生命週期

| 事件 | 目標 | 處理 | 阻止預設行為 | 可觀察後果 |
|---|---|---|---|---|
| `load` | `window`（header 128，capture） | 註冊 129–147 行的 5 組子監聽 | — | — |
| `load` | `window`（header 49 / 51） | `utility.keepResponseTimeEndParameters('${requestTimeHandleUUID}')` | — | 由外部 `utility` 物件決定 → §14 U-17 |
| `load` | `window`（header 404） | `headerWatermarkOnloadFunction` | — | 建立浮水印覆蓋層 |
| `berforeunload` | `window`（header 405） | `headerWatermarkOnloadFunction`（見 §15 D-25） | — | 此事件名無對應的標準事件 |
| `onload`／`onberforeunload` | `window`（header 407–408，`attachEvent` 分支） | `headerWatermarkOnberforeunloadFunction` | — | 見 §15 D-26 |
| `contextmenu` | `document.body`（header 129） | `fpcsStopEventActions` | `stopPropagation()` + `preventDefault()`，函式回傳 `false` | 右鍵選單不出現；`fpcsAlertMsgs` 無 `contextmenu` 鍵，不彈提示 |
| `print` | `document.body`（header 130） | `fpcsStopEventActions` | 同上 | 見 §15 D-19 |
| `beforeprint` | `document.body`（header 131） | `fpcsStopEventActions` | 同上 | 見 §15 D-19 |
| `copy` | `document.body`（header 132） | `validateCopy` | **兩者皆無** | 複製照常完成，同時送出稽核請求 → §15 D-14 |
| `cut` | `document.body`（header 133） | `fpcsStopEventActions` | `stopPropagation()` + `preventDefault()` | 剪下被阻止並彈出提示 |
| `keydown` | `window`（header 136，capture） | 見 §8.5 | `preventDefault()`（經 `forceStopEvent`），處理常式回傳 `false` | 僅對 Ctrl+A/X/S/P 生效，各彈出一個對話框 |
| `click` | `document`（msgDisplayer 174，**指派**而非監聽器） | 目標元素 `type` 字串出現在 `'button,submit'` 之中時呼叫 `clearBottomMsg()` | 無 | 下方訊息欄被清空 |
| 媒體查詢 `print` | `body`（header 102–110，CSS） | 隱藏 `body` 全部直接子元素、以 `body::after` 顯示告示文字 | — | 列印輸出只有告示文字 |

本節所列事件皆以 `addEventListener`／`attachEvent`／屬性指派註冊，兩檔內**沒有** HTML 屬性上的內嵌事件處理（`onclick=` 等），故規則 D7 的 `return false`／`preventDefault` 檢查不適用於 HTML 屬性層級；腳本層級的阻止行為已逐列記於上表。

## 11. 常數與代碼表

### 11.1 硬編碼常數

| 常數值 | 出現位置 | 意義 |
|---|---|---|
| `ebaf.JSP_CHAR_LENGTH` | header 34 | 設定項名稱：中文字位元組折算數 |
| `2` | header 34（預設引數）、36 | 該設定的預設值與回退值 |
| `/^[1-9][0-9]*$/` | header 35 | 設定值格式（正整數，不含前導 0） |
| `requestTimeHandleUUID` | header 43, 46 | 請求範圍屬性名：回應時間量測代號 |
| `eBAF_loginPlatformInfo` | header 55, 58 | 請求範圍屬性名與 `opt` 的鍵 |
| `eBAF_loginSystemInfo` | header 55, 59 | 同上 |
| `eBAF_UserObject_Flag` | header 55, 60 | 同上 |
| `platformDispatcher` | header 55, 61 | 同上 |
| `IS_WATERMARK` | header 95 | 後端功能設定欄位名：是否套用浮水印 |
| `PD_CTRL` | header 96 | 後端功能設定欄位名：是否啟用列印／複製管制 |
| `Y` | header 95, 98 | 上述兩個欄位的啟用值 |
| `65` / `88` / `83` / `80` | header 138 | 攔截的鍵碼：A / X / S / P（搭配 Ctrl） |
| `5000` / `4997` / `'...'` | header 165–166 | 複製稽核內容的長度上限、截斷長度與省略記號 |
| `60000` | header 161 | 複製去重記憶的存續毫秒數 |
| `%25` `%23` `%26` `%20` `%2B` `%3F` `%3D` | header 169–175 | 自訂編碼對照：`%` `#` `&` 空白 `+` `?` `=` |
| `/ZZWeb/servlet/HttpDispatcher/ZZM0_0105/ctrlMsavelog` | header 179 | 複製稽核服務位址（硬編碼絕對路徑） |
| `COPY_CONTENT` / `FUNC_ID` / `COPY_LENGTH` / `TS` | header 179–180 | 複製稽核服務的請求參數名 |
| `$Data.$coreSys$UserObject` | header 270 | session 屬性名：登入使用者物件 |
| `yyyy-MM-dd HH:mm:ss` | header 283 | 浮水印時戳格式 |
| `clientheaderhost` | header 292 | 請求標頭名：用戶端來源網域 |
| `w3.cathaylife.com.tw` | header 293 | 判定為外網站台的網域字樣 |
| `PT` / `STATIC_FILE_URL` / `INTERNET_FONT` | header 294 | 取得外網字型位址的代碼表鍵值三元組 |
| `${htmlBase}/CM/js/ui/watermark-js-plus.js` | header 303, 344 | 浮水印函式庫路徑 |
| `EUDC` | header 306 | 難字字型名稱 |
| `${contextPath}/hanlinks/eudc.woff2`、`…/eudc.ttf` | header 311–312 | 站內難字字型檔位址 |
| `${internetFontUrl}eudc.woff2`、`…eudc.ttf` | header 308–309 | 外網難字字型檔位址 |
| `mainFrame` | header 324 | 視窗名稱：主框架 |
| `watermark_funcIds` / `watermark_root` | header 325–326 等 | 跨視窗共用的全域變數名 |
| 浮水印設定：`"multi-line-text"`、`width 190`、`height 85`、`lineHeight 20`、`fontColor "#000"`、`fontWeight "normal"`、`fontSize "16px"`、`fontFamily "Microsoft JhengHei"`、`rotate 17`、`globalAlpha 0.07`、`mutationObserve true`、`monitorProtection true`、`layout "grid"`、`rows 2`、`cols 2`、`gap [-18,-8]`、`matrix [[1,0],[0,1]]` | header 364–378 | 浮水印外觀與防移除設定 |
| `leftFrame` / `bottomFrame` | msgDisplayer 63–70 | 框架名稱 |
| `showNotifyMsg` / `clearNotifyMsg` / `cathay_common_msgBoard` / `txHasRollbackPage` | msgDisplayer 79, 81, 97, 99, 145, 149, 155 | 下方訊息框架視窗上的約定成員名 |
| `"0"` | msgDisplayer 109 | returnCode：不需彈出對話框（正常） |
| `"99"` | msgDisplayer 109 | returnCode：保留給下方訊息欄，不彈出對話框 |
| `'button,submit'` | msgDisplayer 180 | 觸發清除下方訊息的元素 `type` 比對字串 |
| `WIUtil` / `jQuery` | msgDisplayer 129–130 | 判定是否改用共用對話框元件的全域名稱 |

### 11.2 代碼對照表與畫面靜態文字（完整抄錄）

**列印遮蔽告示（header 106–110，CSS `content`，原始碼以 CSS 十六進位轉義書寫）**

| 原始寫法 | 實際文字 |
|---|---|
| `'\4f9d\64da\8cc7\5b89\653f\7b56\ff0c\4e0d\958b\653e\5217\5370\529f\80fd'` | 依據資安政策，不開放列印功能 |

**管制提示訊息表 `fpcsAlertMsgs`（header 119–126，原始碼以 `\uXXXX` 書寫）**

| 鍵 | 行號 | 實際文字 |
|---|---|---|
| `print` | 120 | 依據資安政策，不開放列印功能 |
| `beforeprint` | 121 | 依據資安政策，不開放列印功能 |
| `copy` | 122 | 依據資安政策，需留存複製軌跡，複製請改用Ctrl+Q |
| `cut` | 123 | 依據資安政策，不開放剪下功能 |
| `selectAll` | 124 | 依據資安政策，不開放全選功能 |
| `save` | 125 | 依據資安政策，不開放頁面儲存功能 |

**訊息對話框的標籤文字（msgDisplayer，BIG5 原文）**

| 行號 | 原文 | 使用時機 |
|---|---|---|
| 112 | `訊息說明:\n` | 無異常說明且 returnCode 非 0／99 |
| 115 | `\n錯誤編號：\n` | 上一列成立且 `msgs[i][1]` 為真值 |
| 122 | `異常原因:` | 有異常說明 |
| 123 | `\n程式ID:` | 同上 |

**returnCode 代碼**

| 代碼 | 來源 | 用途 | 現況處置 |
|---|---|---|---|
| `0` | 後端 `ReturnMessage.getReturnCode()` | 正常 | 不彈出對話框（msgDisplayer 109） |
| `99` | 同上 | 保留給頁面下方訊息欄 | 不彈出對話框（msgDisplayer 108–109 行含原文註解） |
| 其他 | 同上 | 錯誤 | 彙整後彈出（msgDisplayer 112–117） |

`PD_CTRL` 與 `IS_WATERMARK` 的完整值域（除 `Y` 外還有哪些值）→ §14 U-07。

## 12. 對外連結

**不適用（本檔不產生畫面間導覽連結）。** 對外請求與資源位址已記於 §6.1、§6.2 與 §11.1，不在此重複。

## 13. 相依清單

| 相依項目 | 種類 | 本 SoT 是否已知其行為 |
|---|---|---|
| `com.igsapp.wibc.dataobj.html.HttpResponseContext` | Java 類別（header 70、msgDisplayer 2） | `[UNKNOWN]` → U-11 |
| `com.cathay.common.service.ConfigManager` | Java 類別（header 34） | `[UNKNOWN]` → U-01 |
| `com.cathay.zz.z0.module.ZZ_Z0Z001` | Java 類別（header 90，`getFuncInfo`） | `[UNKNOWN]` → U-07 |
| `com.cathay.common.util.FieldOptionList` | Java 類別（header 294） | `[UNKNOWN]` → U-08 |
| `com.cathay.common.service.authenticate.UserObject` | Java 類別（header 270–274） | `[UNKNOWN]` → U-12 |
| `com.cathay.common.bo.ReturnMessage` | Java 類別（msgDisplayer 4–12, 20, 25–26） | `[UNKNOWN]` → U-06 |
| `com.cathay.common.util.IConstantMap.ErrMsg` | Java 常數（msgDisplayer 7） | `[UNKNOWN]` → U-18 |
| `org.apache.commons.lang.StringUtils` / `ObjectUtils` / `StringEscapeUtils` | 第三方函式庫（header 14–16） | 轉義集合 `[ASSUMPTION]` → U-05 |
| `/WEB-INF/tlds/cathay.tld`（前綴 `cathay`） | 自訂標籤庫（header 22 宣告） | 本檔未使用任何 `cathay:` 標籤；供引入端使用 `[UNKNOWN]` → U-19 |
| `/WEB-INF/tlds/taglibs-input.tld`（前綴 `input`） | 自訂標籤庫（header 23 宣告） | 本檔未使用任何 `input:` 標籤；供引入端使用 `[UNKNOWN]` → U-19 |
| `/CXL`（前綴 `CXL`） | 自訂標籤庫（header 24 宣告，26–29 行使用 `CXL:csCommon`） | 標籤實作不在可讀範圍 `[UNKNOWN]` → U-03 |
| JSTL core（前綴 `c`）／fmt（前綴 `fmt`） | 標準標籤庫（header 20–21） | `c:if`／`c:out` 行為 `[ASSUMPTION]` → U-02；本檔未使用 `fmt:` 標籤 |
| `sourceCode/CM/js/ui/watermark-js-plus.js` | 外部腳本（header 303, 344；檔案存在，60,538 位元組） | `[UNKNOWN]`（本輪明確排除，見 §18.2）→ U-09 |
| 全域 `utility` 物件（`keepResponseTimeEndParameters`、`keep_eBAF_parameter`） | 外部腳本提供（header 42–63） | `[UNKNOWN]` → U-17。本檔不載入定義它的腳本 |
| 全域 `WIUtil` 物件（`displayMessage`） | 外部腳本提供（msgDisplayer 129–130） | `[UNKNOWN]` → U-16 |
| `jQuery` | 外部腳本（msgDisplayer 129） | 僅作存在性判斷，不呼叫 |
| 下方訊息框架視窗（`showNotifyMsg`／`clearNotifyMsg`／`cathay_common_msgBoard`／`txHasRollbackPage`） | 其他 JSP 提供（`sourceCode/CM/msgBoard.jsp` 存在但本輪未展開） | `[UNKNOWN]` → U-10 |
| `${contextPath}/hanlinks/eudc.woff2`、`eudc.ttf` | 靜態資源（header 311–312） | 本 repo 中查無 `hanlinks` 路徑（指令見 §18.3）→ U-20 |

**兩檔皆未以 `<%@ include %>` 引入其他檔案**（指令見 §18.3），故無遞迴展開的需要。

## 14. 未知清單

| # | 未知項目 | 為何未知 | 影響範圍 | 建議澄清方式 |
|---|---|---|---|---|
| U-01 | `ConfigManager.getProperty` 的查找來源、設定值的值域與字元限制 | 類別不在可讀範圍 | §3.1 第 34 行的輸出、§8.1、§15 D-01 | 取得設定檔並列出 `ebaf.JSP_CHAR_LENGTH` 的實際值與允許值 |
| U-02 | `c:out` 的 `escapeXml` 預設值與實際轉義字元集合 | JSTL 實作不在可讀範圍 | §3.1 第 58–61、354、392 行；§15 D-02 | 確認容器所用的 JSTL 實作與版本，或在測試環境輸入含 `&<>"'` 的值觀察輸出 |
| U-03 | `CXL:csCommon` 標籤設定 `htmlBase`／`cssBase`／`imageBase`／`dispatcher` 的**作用域**（page／request／session／application）與**值格式**（是否帶結尾斜線、絕對或相對） | `/CXL` 標籤庫實作不在可讀範圍 | §19.1 全部；§3.1 第 303、344 行 | 取得 `CXL` 標籤庫原始碼或 tld，或在執行環境輸出這四個變數的實際值 |
| U-04 | `internetFontUrl` 的值格式（是否以 `/` 結尾） | `FieldOptionList` 不在可讀範圍 | §3.1 第 308–309 行的字串串接結果 | 查代碼表 `PT` / `STATIC_FILE_URL` / `INTERNET_FONT` 的實際值 |
| U-05 | `StringEscapeUtils.escapeHtml` 轉義的字元集合（是否含單引號）與所用版本 | commons-lang 不在可讀範圍 | §3.1 第 358 行；§8.3；§15 D-04 | 確認 `commons-lang` 版本並比對其轉義表 |
| U-06 | `ReturnMessage` 的 `getLength()`／`hasNext()`／`next()` 語意；特別是 `new ReturnMessage(0,"","","","","")` 的 `getLength()` 回傳 0 還是 1；以及 `getLength()` 與 `hasNext()` 迭代次數是否可能不一致 | 類別不在可讀範圍 | §3.2 第 18 行；§8.7；§8.9 的零筆路徑；§15 D-20 | 取得 `ReturnMessage` 原始碼，或在無訊息的交易上觀察 `msgs.length` |
| U-07 | `ZZ_Z0Z001.getFuncInfo(funcId)` 的查詢對象、回傳 Map 的鍵集合；`PD_CTRL` 與 `IS_WATERMARK` 除 `Y` 外的值域 | 類別與資料表不在可讀範圍 | §3.3 的三層條件；§20 全部 | 取得該模組原始碼與對應資料表的欄位定義 |
| U-08 | `FieldOptionList.getName("PT","STATIC_FILE_URL","INTERNET_FONT")` 查無資料時的回傳值（null 或空字串） | 類別不在可讀範圍 | §3.3 第 307 行的 `not empty` 判定 | 取得該類別原始碼或代碼表資料 |
| U-09 | `watermark-js-plus.js` 定義的全域名稱（是否同時定義 `watermark` 與 `WatermarkPlus`）、`Watermark` 設定項的語意、`create()` 的實際版面表現、`monitorProtection` 的防護方式 | 本輪明確排除 `sourceCode/CM/js/**`（§18.2） | §4.3；§6.2；§8.11；§15 D-03 | 下一輪納入該檔，或在瀏覽器主控台檢視載入後的全域物件 |
| U-10 | 下方訊息框架的 `showNotifyMsg` 參數契約與呈現方式、`clearNotifyMsg` 的清除範圍、`cathay_common_msgBoard` 的介面、`txHasRollbackPage` 由誰設定 | 定義在其他 JSP（`sourceCode/CM/msgBoard.jsp` 等），本輪未展開 | §6.3；§8.9；§19.2 | 下一輪為框架版面與 `msgBoard.jsp` 另立 SoT |
| U-11 | `HttpResponseContext.getBeanName()` 與 `getOutputData()` 的語意、`getBeanName()` 與功能代號的對應規則 | 類別不在可讀範圍 | §8.2；§3.2 第 18 行 | 取得該類別原始碼 |
| U-12 | `UserObject.getCATHAY_NO()` 與 `getEmpName()` 的值域；session 屬性 `$Data.$coreSys$UserObject` 由誰放入 | 類別與登入流程不在可讀範圍 | §8.3；浮水印顯示內容 | 取得該類別原始碼與登入流程 |
| U-13 | 複製稽核請求中非 ASCII 字元的送出編碼與伺服器端解碼字集 | 伺服器端設定與 `ctrlMsavelog` 服務不在可讀範圍 | §6.1；§8.4 | 在測試環境複製中文並檢視後端紀錄內容 |
| U-14 | `window.getSelection()` 對 `<input>` 內選取文字的回傳值 | 取決於瀏覽器實作，不在可讀範圍 | §8.4.1；`<input>` 內的複製是否被稽核 | 於目標瀏覽器清單逐一實測 |
| U-15 | Ctrl+Q 的複製替代機制由誰實作 | 本檔未實作，定義位置不明 | §8.5；§15 D-17；提示文字與實際可用功能是否相符 | 全庫搜尋 keyCode 81／`ctrlKey` 的其他處理，或詢問資安管制的原始需求 |
| U-16 | `WIUtil.displayMessage({msg})` 的呈現形式與是否為非同步 | 外部腳本，本輪排除 | §8.8 的訊息呈現路徑 | 下一輪納入定義 `WIUtil` 的腳本 |
| U-17 | 全域 `utility` 物件的來源腳本、`keepResponseTimeEndParameters(uuid)` 與 `keep_eBAF_parameter(opt)` 的行為 | 外部腳本，本輪排除 | §3.1 第 46、58–61 行的用途；§10 | 下一輪納入定義 `utility` 的腳本 |
| U-18 | `IConstantMap.ErrMsg` 的實際鍵值 | 類別不在可讀範圍 | §3.2 第 18 行的資料來源 | 取得該類別原始碼 |
| U-19 | `cathay.tld` 與 `taglibs-input.tld` 提供的標籤集合 | tld 檔不在 repo 中（指令見 §18.3） | §19.3；引入端可使用哪些標籤 | 從部署包取得兩個 tld 檔 |
| U-20 | `hanlinks/eudc.woff2`、`hanlinks/eudc.ttf` 的實際部署位置 | 本 repo 查無該路徑 | §4.2 的 `EUDC` 字型是否可載入 | 於部署環境確認該路徑存在 |
| U-21 | `<%@ include %>` 靜態引入下，多次引入或與引入端變數名衝突的實際情形 | 取決於各引入端，本輪未逐一清查 520／486 個引入端 | §19 所有輸出名稱；§15 D-27 | 以 §18.3 的指令對引入端做名稱衝突掃描 |

## 15. 現況缺陷登記

| # | 標記 | 位置 | 現況行為 | 行為後果等級 | 影響 | 再工程處置建議 |
|---|---|---|---|---|---|---|
| D-01 | `[DEFECT]` | header 34, 46, 180 | 伺服器端值直接寫入 JS 單引號字串字面量，未做 JS 轉義。值若含 `'`、反斜線或換行，會使該 `<script>` 區塊解析失敗 | 影響使用者可見行為 | 整個 `<script>` 區塊失效；第 180 行另有查詢字串注入的風險 | 修正（需業務確認）：改由結構化資料傳遞並在前端讀取，見 §17 決策 1 |
| D-02 | `[DEFECT]` | header 58–61 | `<c:out>` 以 HTML 實體轉義後的字串放進 JS 字串字面量。值含 `& < > " '` 時，JS 端取得的是 `&amp;` `&#039;` 等實體字樣，而非原字元 `[ASSUMPTION]`（前提 U-02 在可讀範圍外） | 影響資料正確性 | `keep_eBAF_parameter` 收到的參數值與原值不同 | 修正（需業務確認）：改用適用於 JS 情境的轉義 |
| D-03 | `[DEFECT]` | header 303 與 341–346 | 第 303 行無條件載入 `watermark-js-plus.js`（60,538 位元組）；第 341 行另以 `root_wm.watermark` 為條件再載入同一支腳本，而第 363 行使用的全域名為 `WatermarkPlus` | 僅影響維護 | 未啟用浮水印的畫面仍載入該腳本；啟用時可能重複載入 `[ASSUMPTION]`（前提 U-09 在可讀範圍外） | 修正（需業務確認）：把載入條件與實際全域名對齊 |
| D-04 | `[DEFECT]` | header 284, 358, 360 | 浮水印文字經 `escapeHtml` → JS 字面量 → `DOMParser` 三道轉換；`escapeHtml` 不轉義單引號 `[ASSUMPTION]`（前提 U-05 在可讀範圍外）。第 360 行的備援分支則使用未經任何轉義函式處理的 `${watermark_txt}` | 影響使用者可見行為 | 人員姓名含單引號時 `<script>` 區塊解析失敗，浮水印與其後的腳本都不執行 | 修正（需業務確認） |
| D-05 | `[DEFECT]` | msgDisplayer 54 | 七個 `<%= %>` 直接寫入 JS 雙引號字串字面量，未做 JS 轉義。訊息文字含 `"` 或 `\` 時該行解析失敗 | 影響使用者可見行為 | 整個 msgDisplayer 腳本區塊失效，`displayMessage`、`msgDisplayer` 等全域名不存在，引入端呼叫時拋出錯誤 | 修正（需業務確認）：見 §17 決策 1 |
| D-06 | `[DEAD-CODE]` | msgDisplayer 48–49, 54 | `msgs[i][3]`（type）與 `msgs[i][4]`（url）被組進陣列，但本檔內無任何位置讀取這兩個索引（指令見 §18.3）。引入端是否讀取 → §14 U-21 | 僅影響維護 | 每筆訊息多送兩個未使用欄位；url 若含路徑資訊另有揭露疑慮 | 保留現況：先以指令確認 520／486 個引入端無人讀取，再決定移除 |
| D-07 | `[DEFECT]` | msgDisplayer 41 與 54 | `displayException`（索引 6）在伺服器端把換行換成 `<br>`，但 JS 端只對索引 0 與 1 做 `.replace(/<br>/gi,"\n")` 還原，索引 6 未還原 | 影響使用者可見行為 | 異常原因在對話框中以字面 `<br>` 顯示，而非換行 | 修正（需業務確認） |
| D-08 | `[DEFECT]` | header 165–166 與 180 | `COPY_CONTENT` 送出的是截斷後內容，`COPY_LENGTH` 送出的是截斷前、空白正規化後的長度 | 影響資料正確性 | 稽核紀錄的內容與長度不對應；長度也不等於使用者實際選取的原始長度（已先做空白正規化） | 修正（需業務確認）：確認稽核需要的是哪一個長度 |
| D-09 | `[DEFECT]` | header 177–181 | 複製稽核請求以影像載入方式發出，未註冊 `onerror`／`onload`，失敗處理為**無** | 影響資料正確性 | 稽核紀錄遺漏時無人知悉，管制形同未生效 | 修正（需業務確認）：屬資安機制，見 §17 決策 4 |
| D-10 | `[DEFECT]` | header 303, 342–345, 363, 382 | 浮水印函式庫載入失敗時，第 363 行拋出的例外被第 382 行的 `catch` 捕捉並僅寫 console | 影響使用者可見行為 | 浮水印未出現且無提示，使用者與管理者都無從察覺管制失效 | 修正（需業務確認）：屬資安機制，見 §17 決策 4 |
| D-11 | `[DEFECT]` | msgDisplayer 87–88, 166–167, 183–184 | 三處 `catch(err){}` 的區塊內無任何敘述（開括號的下一行即為閉括號），不記錄也不提示 | 影響使用者可見行為 | 跨框架存取失敗時訊息靜默消失，使用者以為交易無異常 | 修正（需業務確認） |
| D-12 | `[DEFECT]` | msgDisplayer 174 | 以 `document.onclick = function(){}` **指派**設定全域點擊處理，而非 `addEventListener` | 影響使用者可見行為 | 覆寫引入端在此之前設定的 `document.onclick`；引入端在此之後設定者則覆寫本處理，下方訊息清除失效 | 修正（需業務確認）：改用事件監聽器註冊 |
| D-13 | `[DEFECT]` | msgDisplayer 18 | `msgs = new Array(...)` 未使用宣告關鍵字，建立隱含全域變數 | 僅影響維護 | 名稱易與引入端衝突；在嚴格模式下拋出錯誤 | 修正（需業務確認）：加上宣告關鍵字 |
| D-14 | `[DEFECT]` | header 132, 149–183 | `copy` 事件的處理常式 `validateCopy` 只做稽核紀錄，未呼叫 `preventDefault()` 或回傳 `false` | 影響使用者可見行為 | 與同組的 `cut`／`selectAll` 管制不一致：複製可正常完成。此差異與第 122 行「需留存複製軌跡」的提示文字相符，可能是刻意設計 | 保留現況：需業務確認是否為預期行為 |
| D-15 | `[DEFECT]` | header 33 與 34 | 註解寫「1 letter counts 3 bytes」，同一行的設定預設值為 `2` | 僅影響維護 | 後續維護者依註解判讀會得到錯誤結論 | 修正（需業務確認）：確認正確折算數後同步更正 |
| D-16 | `[DEFECT]` | header 68/261, 267/286, 291/297 | 三個 `try{...}catch(Exception e){ e.printStackTrace(); }` 只把堆疊寫到伺服器輸出，不中止也不提示 | 影響使用者可見行為 | 查功能設定失敗時，列印管制與浮水印都不產生，畫面看起來與「未設定管制」相同，無法區分「未啟用」與「啟用失敗」 | 修正（需業務確認）：屬資安機制，見 §17 決策 4 |
| D-17 | `[DEFECT]` | header 122 | 提示文字指示「複製請改用 Ctrl+Q」，本檔未處理 Ctrl+Q（keyCode 81 不在第 138 行的攔截清單中，且全檔無其他鍵碼處理） | 影響使用者可見行為 | 若無其他元件實作 Ctrl+Q（→ U-15），使用者依提示操作會無反應 | 修正（需業務確認）：確認 Ctrl+Q 的實作位置，或更正提示文字 |
| D-18 | `[DEFECT]` | header 222, 237 | `e.cancelBubble !== undefined \|\| e.cancelBubble !== null`：兩個條件以 `\|\|` 相接，對任何值至少一邊成立，該判斷結果與 `e` 是否為真值相同 | 僅影響維護 | 條件寫法與意圖（檢查屬性是否存在）不符；此分支只在無 `stopPropagation` 的舊瀏覽器路徑執行 | 修正（需業務確認） |
| D-19 | `[DEFECT]` | header 130–131 | 把 `print` 與 `beforeprint` 註冊在 `document.body` 上 `[ASSUMPTION]`（依據：這兩個事件依規格在 `window` 觸發；前提為瀏覽器實作遵循該規格，不在可讀範圍 → U-09 同類） | 僅影響維護 | 這兩個註冊可能不會被觸發；列印管制實際由第 101–112 行的 `@media print` 樣式達成 | 修正（需業務確認）：確認後移除或改註冊到 `window` |
| D-20 | `[DEFECT]` | msgDisplayer 20–22, 45–51 | `showmsg` 陣列長度取自 `getLength()`，填入迴圈次數取自 `hasNext()`；這段 scriptlet 不在 try/catch 內（本檔的 try 僅涵蓋 6–10 行） | 影響使用者可見行為 | 兩者若不一致（→ U-06），拋出陣列索引越界，整頁渲染失敗 | 修正（需業務確認）：改以單一來源決定筆數 |
| D-21 | `[DEAD-CODE]` | msgDisplayer 120 | `if ((msgs[i][6] != "") \|\| (msgs[i][2] != ""))` 位於「`msgs[i][6] == ""` 為假」的 `else` 分支內，其左半與進入分支的條件相同，`\|\| msgs[i][2] != ""` 不改變判斷結果 | 僅影響維護 | 讀者會誤以為 sysid 為空時有不同分支 | 修正（需業務確認）：確認原意後改寫或移除 |
| D-22 | `[DEFECT]` | msgDisplayer 112, 115, 122, 123 | 同一個對話框內混用半形冒號（`訊息說明:`、`異常原因:`、`程式ID:`）與全形冒號（`錯誤編號：`） | 影響使用者可見行為 | 對話框標籤樣式不一致 | 修正（需業務確認）：統一標點 |
| D-23 | `[DEFECT]` | msgDisplayer 159–163 | `var msgindex = 0;` 為固定值，只有第一筆訊息送到下方訊息欄 | 影響使用者可見行為 | 多筆訊息時，第 2 筆以後不出現在下方訊息欄；若其 returnCode 為 `0` 或 `99`，第 8.8 節的彙整也略過它，該訊息不會出現在任何地方 | 修正（需業務確認）：確認多筆訊息的預期呈現方式 |
| D-24 | `[DEFECT]` | header 396 | `root_wm.watermark_funcIds = root_wm.watermark_funcIds.splice(wmfuncIndex, 1);` 以 `splice` 的回傳值（被移除的元素陣列）覆寫整個清單 | 影響資料正確性 | 卸載一個功能後，清單被替換成只含剛移除的那一個代號，其餘代號遺失 | 修正（需業務確認）：改為只呼叫 `splice` 不做指派 |
| D-25 | `[DEFECT]` | header 405 | `window.addEventListener('berforeunload', headerWatermarkOnloadFunction)`：事件名拼寫與 `beforeunload` 不同，且註冊的是建立浮水印的函式而非解除登記的函式 | 僅影響維護 | 在 `addEventListener` 可用的瀏覽器上，解除登記函式 `headerWatermarkOnberforeunloadFunction`（387–401 行）未被註冊到任何事件 | 修正（需業務確認）：屬資安機制的一部分，見 §17 決策 4 |
| D-26 | `[DEFECT]` | header 407 | `window.attachEvent('onload', headerWatermarkOnberforeunloadFunction)`：`load` 註冊的是解除登記函式 | 影響使用者可見行為 | 在只支援 `attachEvent` 的瀏覽器上不建立浮水印 | 修正（需業務確認）：見 §17 決策 4 |
| D-27 | `[DEFECT]` | header 全域名稱、msgDisplayer 全域名稱 | 兩檔以 `<%@ include %>` 靜態引入，引入端與本檔共用同一個 JSP 頁面類別與同一個 JS 全域命名空間。本檔在引入端命名空間中放入 §19 所列的全部名稱，以及 `headerRequestFuncId`、`beanName`、`str_wm`、`msgResp`、`msg`、`msglen`、`msgidx`、`showmsg`、`tmp` 等 Java 區域變數 | 僅影響維護 | 引入端若宣告同名變數，JSP 編譯失敗；名稱多以 `header`／`fpcs`／`msg` 前綴降低碰撞，但 `msg`、`tmp`、`msgs` 無前綴。實際碰撞情形 → U-21 | 保留現況：再工程時以模組邊界取代全域命名空間，見 §17 決策 2 |
| D-28 | `[DEFECT]` | header 32/303/317（`text/javascript`）與 343（`text/javaScript`）、msgDisplayer 16（`text/javaScript`） | 同一屬性值存在大小寫變體（計數指令見 §18.3） | 僅影響維護 | 不影響執行（媒體型別比對不分大小寫），但屬用字不一致 | 修正（需業務確認）：統一寫法 |
| D-29 | `[DEFECT]` | header 179 | 稽核服務位址硬編碼為 `/ZZWeb/...` 絕對路徑，未使用同檔第 26–29 行已備妥的 `${dispatcher}` 或 `${pageContext.request.contextPath}` | 僅影響維護 | context path 變更時該請求失效，且與同檔其他資源路徑的取得方式不一致 | 修正（需業務確認） |

機械列舉結果（指令見 §18.3）：兩檔的 `id=` 屬性數為 0、`<input>`／`<select>`／`<textarea>` 數為 0，故「重複 DOM 識別碼」與「無 `name` 的表單元素」兩類缺陷**經查後無**。`<script src>` 只有一支（header 303），其提供的全域名在第 363 行被使用，但使用位置受 `${isWaterMark}` 條件包住，已登記為 D-03。

## 16. 變更軌跡

| 日期 | 異動人 | 單號 | 內容 | 對應程式位置 |
|---|---|---|---|---|
| — | — | — | 兩檔皆無檔頭註解，亦無帶日期或單號的變更註記（指令見 §18.3） | — |

### 16.1 來源歷史觀察（不構成缺陷）

| 觀察 | 位置 | 說明 |
|---|---|---|
| 註解式功能保留說明 | msgDisplayer 92 | 原文：「保留此方法，提供早期所開發之 JSP 利用該方法，取得下方訊息欄位進行訊息設定」——指 `getMsgBoard()`。全庫除本檔外有 1 個 JSP 呼叫它（指令見 §18.3） |
| 以 `//new` 標記的改寫痕跡 | msgDisplayer 109–111 | 第 109 行行尾 `//new`；第 110–111 行為兩行被註解掉的舊版訊息組法（含「回傳碼:」與雙換行版的「訊息說明:」） |
| 保留的英文設計註解 | msgDisplayer 108 | 「when msgs[msgindex][5]==99 … then keep the return message to the message board under the web」——`99` 代碼的設計意圖 |
| 舊式腳本包裹 | msgDisplayer 17 與 187 | `<!--` … `//-->` 的 HTML 註解包裹，屬早期瀏覽器相容寫法 |
| 分支寫法不一致 | msgDisplayer 64 與 66 | 第 64 行直接回傳框架物件，第 66 行回傳 `a && b` 運算式；兩者結果相同 |
| 標籤屬性間距不一致 | header 307 | `<c:if  test=` 有兩個空白，其餘 7 處為單一空白 |
| 宣告的標籤庫未在本檔使用 | header 21, 22, 23 | `fmt`、`cathay`、`input` 三個前綴在本檔內無任何使用（指令見 §18.3），宣告的目的是供引入端使用，見 §19.3 |
| 匯入的類別未在本檔使用 | header 1–18 | 16 個 `<%@ page import %>` 中，本檔實際使用的是 `ConfigManager`、`StringUtils`、`ObjectUtils`、`StringEscapeUtils`、`FieldOptionList`、`ZZ_Z0Z001`、`List`、`Map`、`HttpResponseContext`、`UserObject`；`java.util.*`、`Logger`、`Context.*`、`DataSet`、`DynamicDataSet`、`VOTool` 未在本檔使用，同屬供引入端使用的性質 |
| 變數命名前綴 | header 全檔 | 一致採用 `header`／`fpcs`／`_wm` 前綴以避開與引入端的命名碰撞，屬刻意設計 |
| 尾隨逗號 | header 125 行尾 | `fpcsAlertMsgs` 物件字面量最後一個成員後有逗號 |

## 17. 落地決策點

| # | 決策點 | 現況 | 選項 | 影響 |
|---|---|---|---|---|
| 1 | 伺服器渲染值的承載方式 | 伺服器值直接寫入 JS 字串字面量（header 34/46/58–61/180/354/358/360/365/392；msgDisplayer 18/54），共 25 處 | (a) 維持字面量內插並補上情境正確的轉義；(b) 改以資料屬性或結構化資料區塊承載，前端讀取後使用 | 決定 D-01／D-02／D-04／D-05 的修正方式；影響所有引入端 |
| 2 | 共用片段的組織方式 | 靜態引入，與引入端共用 Java 與 JS 命名空間（D-27） | (a) 維持單一全域命名空間；(b) 拆為具明確輸入輸出的模組 | 決定 §19 輸出契約的落地形式；影響 520／486 個引入端的改寫範圍 |
| 3 | 訊息呈現通道 | 下方訊息欄（跨框架呼叫）＋對話框，二選一由 returnCode 與 `WIUtil`／`jQuery` 的存在與否決定（§8.8、§8.9） | (a) 保留框架式下方訊息欄；(b) 改為單一頁內訊息區 | 取決於框架版面（`leftFrame`／`bottomFrame`）是否保留；牽動 U-10 的釐清 |
| 4 | **資安管制機制（列印管制、防拷、複製稽核、浮水印）——不可逕行移除** | `PD_CTRL`／`IS_WATERMARK` 兩個後端旗標驅動；現況存在 D-09／D-10／D-16／D-25／D-26 等失效路徑 | (a) 原樣移植含現有缺陷；(b) 修正後移植；(c) 改用平台層機制 | 依規則 J3 列為決策點。任一選項都需資安單位確認；修正 D-25／D-26 會讓浮水印在現況未生效的路徑上開始生效，屬行為變更 |
| 5 | 管制失效時的處置 | 查設定失敗、腳本載入失敗、稽核送出失敗皆靜默略過（D-09／D-10／D-16） | (a) 維持靜默；(b) 阻擋畫面呈現；(c) 記錄並告警 | 資安政策層級的決定，需資安單位確認 |
| 6 | Ctrl+Q 複製替代機制 | 提示文字指向 Ctrl+Q，本檔未實作（D-17、U-15） | (a) 找出並保留既有實作；(b) 重新實作；(c) 更正提示文字 | 影響管制啟用畫面的使用者實際可用操作 |
| 7 | 難字字型 `EUDC` 的來源切換 | 依請求標頭 `clientheaderhost` 是否含 `w3.cathaylife.com.tw` 決定外網或站內位址（header 291–299, 305–315） | (a) 保留標頭判斷；(b) 改由組態決定；(c) 統一單一來源 | 影響外網使用者的難字顯示；牽動 U-04、U-20 |
| 8 | 浮水印跨視窗狀態的維護 | 以 `window.top` 上的 `watermark_funcIds`／`watermark_root` 維護，現況存在 D-24 與第 325 行的清空衝突 | (a) 維持跨視窗共享；(b) 改為每頁獨立 | 取決於決策 3 的框架結構是否保留 |
| 9 | 未使用的訊息欄位 | `msgs[i][3]`（type）與 `msgs[i][4]`（url）本檔未使用（D-06） | (a) 保留以維持引入端相容；(b) 清查引入端後移除 | 需先完成 U-21 的引入端掃描 |
| 10 | 字元位元組折算設定 | 由 `ebaf.JSP_CHAR_LENGTH` 設定，預設 `2`，註解寫 `3`（D-15） | (a) 沿用現值；(b) 依實際字集重新定義 | 影響所有引用 `charCountsByte` 的欄位長度驗證（10 個檔案引用，見 §19.1） |

## 18. 查證範圍

### 18.1 已完整讀取

| 檔案 | 行數 | 用途 |
|---|---|---|
| `sourceCode/CM/header.jsp` | 413（實際行數口徑） | 本 SoT 的主要對象 |
| `sourceCode/CM/msgDisplayer.jsp` | 188（實際行數口徑） | 本 SoT 的主要對象 |
| `docs/v3/template.md` | 253 | SoT 結構 |
| `docs/v3/rules.md` | 268 | 撰寫規則 |

另以指令檢視（未完整閱讀，僅取用機械列舉結果）：`sourceCode/AF/AFY10100.jsp` 的第 3 行與第 32 行，用於確認引入指令的實際寫法（§2）。

### 18.2 明確排除（本輪不可讀）

| 檔案/範圍 | 排除原因 | 影響的章節 |
|---|---|---|
| `docs/v1/**`、`docs/v2/**` | 本輪任務明令禁止讀取（前幾輪產物，讀取會使實驗失效） | 無（本文件未參照任何前輪結論） |
| `sourceCode/CM/js/**`（含 `watermark-js-plus.js`、`ui/Validator.js`、`ui/InputUtility.js` 等） | 本輪任務指定：外部共用 JavaScript 不在範圍內，行為依規則 §E 標未知 | §4.3、§6.2、§8.11、§13、§14 U-09／U-16／U-17 |
| `sourceCode/CM/msgBoard.jsp` 及其他框架版面 JSP | 兩檔未以 `<%@ include %>` 引入它們；依任務指示不遞迴展開 | §6.3、§8.9、§14 U-10 |
| 全部 Java 類別原始碼（`com.cathay.*`、`com.igsapp.*`）、tld 檔、設定檔 | 不在 repo 中（`find` 查無 `*.tld`） | §13、§14 U-01／U-02／U-05／U-06／U-07／U-08／U-11／U-12／U-18／U-19 |
| 520／486 個引入端 JSP 的逐檔內容 | 超出本輪單位；僅以指令做計數與存在性比對 | §14 U-21、§15 D-06／D-27 |

### 18.3 核對指令

以下指令可由覆核者重跑。**注意**：`zsh` 的內建 `echo` 會解譯反斜線轉義（本文件初稿曾因此得到偏移 2–14 行的錯誤行號），故所有帶行號的檢查都以管線直接串接，不經 `echo "$var"` 中轉。

```bash
cd "<repo 根目錄>"

# --- 行數與計數口徑（§0 標頭） ---
wc -l -c sourceCode/CM/header.jsp sourceCode/CM/msgDisplayer.jsp
tail -c 1 sourceCode/CM/header.jsp      | xxd     # 末位元組為 '>'，無結尾換行
tail -c 1 sourceCode/CM/msgDisplayer.jsp | xxd
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp       | awk 'END{print NR}'   # 413
iconv -f BIG5 -t UTF-8 sourceCode/CM/msgDisplayer.jsp | awk 'END{print NR}'   # 188

# --- §3 渲染契約：求值點機械列舉 ---
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | grep -n -o '\${[^}]*}'      # 24 處
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | grep -o  '\${[^}]*}' | wc -l
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | grep -n  '<%='              # 2 處
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | grep -c  '<c:if'            # 8
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | grep -c -o 'c:out value='   # 6
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | grep -n -E '<c:if|</c:if>'  # 開閉配對
iconv -f BIG5 -t UTF-8 sourceCode/CM/msgDisplayer.jsp | grep -o '<%=' | wc -l # 9
iconv -f BIG5 -t UTF-8 sourceCode/CM/msgDisplayer.jsp | awk '/<%=/{print NR": "gsub(/<%=/,"&")" 處"}'
iconv -f BIG5 -t UTF-8 sourceCode/CM/msgDisplayer.jsp | grep -c -o '\${[^}]*}'  # 0

# --- §15 機械列舉（規則 G2） ---
# 重複 DOM 識別碼：兩檔皆為 0 個 id 屬性
for f in sourceCode/CM/header.jsp sourceCode/CM/msgDisplayer.jsp; do
  iconv -f BIG5 -t UTF-8 "$f" | grep -o 'id="[^"]*"' | sort | uniq -d
  iconv -f BIG5 -t UTF-8 "$f" | grep -c -o 'id="[^"]*"'
done
# 無 name 的表單元素：兩檔皆為 0 個表單元素
for f in sourceCode/CM/header.jsp sourceCode/CM/msgDisplayer.jsp; do
  iconv -f BIG5 -t UTF-8 "$f" | grep -c -o -iE '<(input|select|textarea)\b'
done
# 未使用的載入項：<script src> 與全域使用點比對
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | grep -n 'script.*src='
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | grep -n 'WatermarkPlus\|root_wm.watermark'
# 同一屬性的大小寫變體
for f in sourceCode/CM/header.jsp sourceCode/CM/msgDisplayer.jsp; do
  iconv -f BIG5 -t UTF-8 "$f" | grep -o -iE "text/java[sS]cript" | sort | uniq -c
done
# 未處理的錯誤路徑：列舉所有 catch 區塊
for f in sourceCode/CM/header.jsp sourceCode/CM/msgDisplayer.jsp; do
  iconv -f BIG5 -t UTF-8 "$f" | grep -n -A1 -E 'catch[[:space:]]*\('
done
# msgs 索引 3 / 4 是否被讀取（D-06）
iconv -f BIG5 -t UTF-8 sourceCode/CM/msgDisplayer.jsp | grep -n 'msgs\[[a-z]*\]\[[0-9]\]'
# 函式宣告清單（§7.1、§8）
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp       | grep -n 'function '
iconv -f BIG5 -t UTF-8 sourceCode/CM/msgDisplayer.jsp | grep -n -E '^(var |function )|: function'

# --- §13 / §16.1：宣告但未使用的標籤庫前綴 ---
for p in 'fmt:' 'cathay:' 'input:' 'CXL:'; do
  printf '%-10s %s\n' "$p" "$(iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | grep -c -F "<$p")"
done
# 兩檔是否再引入其他檔案（預期皆為 0）
for f in sourceCode/CM/header.jsp sourceCode/CM/msgDisplayer.jsp; do
  iconv -f BIG5 -t UTF-8 "$f" | grep -c -F '<%@ include'
done
# tld 檔是否在 repo 中（預期查無）
find sourceCode -iname '*.tld'
find sourceCode -ipath '*hanlinks*'
ls -la sourceCode/CM/js/ui/watermark-js-plus.js

# --- §2 / §19：引入端與消費端統計 ---
find sourceCode -name '*.jsp' | wc -l                                   # 603
find sourceCode -name '*.jsp' -print0 | xargs -0 grep -al '/html/CM/header.jsp'       | wc -l   # 520
find sourceCode -name '*.jsp' -print0 | xargs -0 grep -al '/html/CM/msgDisplayer.jsp' | wc -l   # 486
for v in htmlBase cssBase imageBase dispatcher; do
  printf '%-12s %s\n' "$v" "$(find sourceCode -name '*.jsp' -print0 | xargs -0 grep -al "\${$v}" 2>/dev/null | wc -l)"
done                                                                    # 128 / 83 / 8 / 161
for f in 'displayMessage()' 'alertMessages()' 'getMsgBoard()' 'charCountsByte'; do
  printf '%-18s %s\n' "$f" "$(find sourceCode -name '*.jsp' ! -name 'header.jsp' ! -name 'msgDisplayer.jsp' -print0 \
    | xargs -0 grep -alF "$f" 2>/dev/null | wc -l)"
done                                                                    # 479 / 6 / 1 / 10
grep -an 'include' sourceCode/AF/AFY10100.jsp                           # 引入指令實際寫法

# --- §11.2：解碼 CSS/JS 轉義的中文告示文字 ---
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | sed -n '106,126p'
python3 -c "print(''.join(chr(int(x,16)) for x in '4f9d 64da 8cc7 5b89 653f 7b56 ff0c 4e0d 958b 653e 5217 5370 529f 80fd'.split()))"

# --- §K.2：逐一回查行號區間 ---
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | sed -n '<N>,<M>p'
iconv -f BIG5 -t UTF-8 sourceCode/CM/header.jsp | cat -n            # 全檔對照

# --- §K.3：絕對語氣關鍵字掃描 ---
grep -n -E '恆|必定|永不|完全|實際上|一律|不可能' docs/v3/sot/SHARED-CM-includes.md
```

---

## 19. 對引入端的輸出契約

本節是各畫面 SoT 引用本文件的主要依據。引入端不需宣告、不需載入，即可取用以下名稱。

### 19.1 定義的伺服器端變數（可由引入端以 EL 取用）

| 名稱 | 定義位置 | 定義方式 | 型別 | 值 | 引入端可見性 | 全庫使用家數 |
|---|---|---|---|---|---|---|
| `htmlBase` | header 26 | `<CXL:csCommon htmlBaseName="htmlBase">` | 字串 | 靜態網頁資源基底路徑 | 作用域 `[UNKNOWN]` → U-03 | 128 個 JSP |
| `cssBase` | header 27 | `<CXL:csCommon cssBaseName="cssBase">` | 字串 | 樣式表基底路徑 | 同上 | 83 個 JSP |
| `imageBase` | header 28 | `<CXL:csCommon imageBaseName="imageBase">` | 字串 | 圖檔基底路徑 | 同上 | 8 個 JSP |
| `dispatcher` | header 29 | `<CXL:csCommon dispatcherName="dispatcher">` | 字串 | 後端派送器位址前綴 | 同上 | 161 個 JSP |
| `headerRequestFuncId` | header 94 | `pageContext.setAttribute` | 字串 | 本次請求的功能代號（推導規則見 §8.2） | page 範圍；**僅在 §3.3 前兩層條件成立時存在**，否則 EL 求值為空字串 | — |
| `isWaterMark` | header 95 | `pageContext.setAttribute` | `Boolean` | 後端 `IS_WATERMARK` 是否為 `Y` | 同上 | — |
| `watermark_datetime` | header 283 | `pageContext.setAttribute` | 字串 | 伺服器產生本頁的時刻，`yyyy-MM-dd HH:mm:ss` | page 範圍；第 267–288 行的 try 若拋出例外則不存在 | — |
| `watermark_escapeHtml_txt` | header 284 | `pageContext.setAttribute` | 字串 | HTML 轉義後的人員識別文字 | 同上 | — |
| `watermark_txt` | header 285 | `pageContext.setAttribute` | 字串 | 未轉義的人員識別文字 | 同上 | — |
| `internetFontUrl` | header 295 | `pageContext.setAttribute` | 字串 | 外網難字字型的基底位址 | page 範圍；**僅在請求標頭 `clientheaderhost` 含 `w3.cathaylife.com.tw` 時存在** | — |

`trace="false"` 是 `CXL:csCommon` 的第五個屬性（header 26），其作用 → U-03。

同一頁面另有 Java 區域變數 `headerRequestFuncId`、`beanName`、`headerPdCtrl`、`headerFindList`、`headerfMap`、`headeritStr`、`headerUrls`、`headerRequestUrl`、`str_wm`、`userObj_wm`、`clientheaderhost`（header）與 `msgResp`、`msg`、`msglen`、`msgidx`、`showmsg`、`tmp`（msgDisplayer）進入引入端的編譯單元，構成名稱佔用，見 §15 D-27。

### 19.2 注入的瀏覽器端全域名稱

**msgDisplayer.jsp 提供（引入端的主要呼叫入口）**

| 名稱 | 種類 | 定義位置 | 契約 | 全庫呼叫家數 |
|---|---|---|---|---|
| `displayMessage()` | 全域函式 | 61–171（第 137 行宣告） | 無參數、無回傳值。把 `msgs[0]` 送到下方訊息欄，再執行 `alertMessages()`。行為見 §8.9。**引入端必須自行呼叫，本檔不自動執行** | 479 個 JSP |
| `alertMessages()` | 全域函式 | 103–135 | 無參數、無回傳值。彙整 `msgs` 後以對話框或 `WIUtil.displayMessage` 呈現。行為見 §8.8 | 6 個 JSP（另由 `displayMessage()` 內部呼叫） |
| `getMsgBoard()` | 全域函式 | 93–101 | 無參數。回傳下方訊息框架的 `cathay_common_msgBoard` 物件，取不到框架時回傳 `undefined`。第 92 行註解說明此為相容早期 JSP 而保留 | 1 個 JSP |
| `msgDisplayer` | 全域物件 | 61–90 | 兩個方法：`getBottomFrame()`（§8.10，回傳框架視窗或 `undefined`）、`clearBottomMsg()`（§6.3，呼叫框架的 `clearNotifyMsg()`，不回傳值） | 本檔內部使用；引入端呼叫家數 0 |
| `msgs` | 全域陣列（隱含全域，見 D-13） | 18、54 | 二維陣列，每列 7 個字串：`[0]` 訊息說明、`[1]` 錯誤編號、`[2]` 程式 ID(sysid)、`[3]` type、`[4]` url、`[5]` returnCode、`[6]` 異常說明。`[0]` 與 `[1]` 的換行已在瀏覽器端還原，`[6]` 未還原（D-07） | — |
| `document.onclick` | 事件處理常式（**指派**，見 D-12） | 174–185 | 點擊 `type` 出現在 `'button,submit'` 之中的元素時呼叫 `msgDisplayer.clearBottomMsg()` | — |

**header.jsp 提供**

| 名稱 | 種類 | 定義位置 | 契約 | 條件 |
|---|---|---|---|---|
| `window.charCountsByte` | 全域數字 | 34–39 | 中文字位元組折算數，見 §8.1。10 個檔案引用（含 `js/**` 中的 5 支驗證腳本與 4 個 DS 畫面） | 無條件輸出 |
| `is_same_origin` | 全域布林 | 318–323 | 是否與最上層視窗同源 | 無條件輸出 |
| `window.top.watermark_funcIds` | 跨視窗全域陣列 | 325, 350–352 | 已套用浮水印的功能代號清單（維護方式有 D-24） | `is_same_origin && window.name=='mainFrame'` 時建立空陣列；`${isWaterMark}` 為真時 push |
| `window.top.watermark_root` | 跨視窗全域視窗參考 | 326, 337 | 浮水印掛載的根視窗 | 同上 |
| `fpcsAlertMsgs` | 全域物件 | 119–126 | 六個管制提示文字（內容見 §11.2）。第 115 行的 `typeof … !== 'object'` 防護表示同一頁面二次引入時不覆寫 | `PD_CTRL = Y` |
| `lastfpcsRecordText` | 全域字串 | 117 | 複製去重記憶 | `PD_CTRL = Y` |
| `fpcsStopEventActions(e)` | 全域函式 | 232–243 | 阻止事件預設行為並依 `e.type` 彈出提示，回傳 `false` | `PD_CTRL = Y` |
| `fpcsDoAddEventListener(element, eventName, func)` | 全域函式 | 245–254 | 跨瀏覽器事件註冊（capture 模式），見 §8.6 | `PD_CTRL = Y` |
| `WatermarkPlus` | 外部函式庫提供的全域名 | 經 303 / 344 行載入 | 本檔不定義，僅載入並於 363 行使用 → U-09 | 第 303 行無條件載入 |

`validateCopy`、`fpcsGetSelectionText`、`stopEventActions`、`forceStopEvent`、`showStopAlertMessage`（header 149–230）宣告在 `load` 處理常式內部，不是全域名稱。`headerRegisterOnloadFunction`（45）、`headerWatermarkOnloadFunction`（347）、`headerWatermarkOnberforeunloadFunction`（387）宣告在各自的區塊／IIFE 內。

### 19.3 宣告的標籤庫（引入端可直接使用，無須重複宣告）

| 前綴 | URI | 宣告位置 | 本檔是否使用 |
|---|---|---|---|
| `c` | `http://java.sun.com/jsp/jstl/core` | header 20 | 是（`c:if` 8 處、`c:out` 6 處） |
| `fmt` | `http://java.sun.com/jsp/jstl/fmt` | header 21 | 否 |
| `cathay` | `/WEB-INF/tlds/cathay.tld` | header 22 | 否 → U-19 |
| `input` | `/WEB-INF/tlds/taglibs-input.tld` | header 23 | 否 → U-19 |
| `CXL` | `/CXL` | header 24 | 是（`CXL:csCommon`，26–29 行） |

msgDisplayer.jsp 未宣告任何標籤庫，亦未使用任何標籤。

### 19.4 匯入的 Java 類別（引入端的 scriptlet 可直接使用，無須重複匯入）

header.jsp 共 16 個 `<%@ page import %>`（1–18 行）：

| 行號 | 匯入項 | 本檔是否使用 |
|---|---|---|
| 1 | `java.util.*` | 否（第 283–284 行改用完整限定名 `java.text.SimpleDateFormat`、`java.util.Date`） |
| 2 | `org.apache.log4j.Logger` | 否 |
| 3 | `com.igsapp.wibc.dataobj.Context.*` | 否 |
| 4 | `com.igsapp.wibc.dataobj.html.*` | 是（`HttpResponseContext`，第 70 行） |
| 5 | `com.cathay.common.service.ConfigManager` | 是（第 34 行） |
| 6 | `com.cathay.common.service.authenticate.*` | 是（`UserObject`，第 270 行） |
| 7 | `com.cathay.common.util.FieldOptionList` | 是（第 294 行） |
| 9 | `com.igsapp.db.DataSet` | 否 |
| 10 | `com.cathay.db.impl.DynamicDataSet` | 否 |
| 11 | `com.cathay.common.im.util.VOTool` | 否 |
| 12 | `com.cathay.zz.z0.module.ZZ_Z0Z001` | 是（第 90 行） |
| 14 | `org.apache.commons.lang.ObjectUtils` | 是（第 95、96 行） |
| 15 | `org.apache.commons.lang.StringUtils` | 是（第 73、74、77、81、82、88、293 行） |
| 16 | `org.apache.commons.lang.StringEscapeUtils` | 是（第 284 行） |
| 17 | `java.util.List` | 是（第 90 行） |
| 18 | `java.util.Map` | 是（第 90、93 行） |

msgDisplayer.jsp 無 `<%@ page import %>`，全部以完整限定名書寫（`com.igsapp.wibc.dataobj.html.HttpResponseContext`、`com.cathay.common.bo.ReturnMessage`、`com.cathay.common.util.IConstantMap`）。

### 19.5 注入的樣式

| 選擇器 | 位置 | 對引入端的影響 |
|---|---|---|
| `@media print { body>* }`、`@media print { body::after }` | header 101–112 | 影響引入端的整份列印輸出。條件：`PD_CTRL = Y` |
| `@font-face { font-family:'EUDC' }` | header 304–316 | 引入端可在任何元素上使用 `font-family: EUDC` 顯示難字。無條件輸出 |

### 19.6 引入端需自行負責的事項

| 事項 | 說明 |
|---|---|
| 呼叫 `displayMessage()` | 本檔不自動呈現訊息；引入端須在適當時機呼叫（479 個 JSP 有此呼叫） |
| 載入 `utility` 物件 | header 42–63 行使用 `window.utility` 但不載入其定義；未載入時該段整體略過（第 42 行的 `if(window.utility)` 保護） → U-17 |
| 載入 `WIUtil` 與 `jQuery` | msgDisplayer 129–130 行只做存在性判斷；未載入時回退為 `alert()` |
| 提供框架結構 | `getBottomFrame()` 依賴 `leftFrame`／`bottomFrame` 的存在；不存在時訊息只走對話框路徑 |
| 避免名稱衝突 | 見 §15 D-27 與 §19.1 的名稱清單 |

## 20. 引入端需自行決定的條件值

各畫面 SoT 的 §13 相依清單須填寫下表的「本畫面實際值」欄，並據以敘明本畫面受影響的具體行為。

| # | 條件欄位 | 決定者 | 取得方式 | 影響的輸出 | 各畫面 SoT 須填寫 |
|---|---|---|---|---|---|
| C-1 | `PD_CTRL` | 後端功能設定（`ZZ_Z0Z001.getFuncInfo(funcId)` 回傳的 Map） | header 96；值為 `Y` 時啟用 | header 101–256 行整段：列印遮蔽樣式、右鍵／剪下／全選／存檔管制、複製稽核 | 本畫面的 `PD_CTRL` 實際值；若為 `Y`，須敘明本畫面的列印輸出與右鍵／熱鍵行為 |
| C-2 | `IS_WATERMARK` | 同上 | header 95；值為 `Y` 時 `isWaterMark` 為 `true` | header 330–411 行：浮水印覆蓋層的建立與 `watermark_funcIds` 維護 | 本畫面的 `IS_WATERMARK` 實際值；若為 `Y`，須敘明浮水印覆蓋對本畫面版面與列印的影響 |
| C-3 | `headerRequestFuncId` 的推導結果 | 本次請求的 bean 名稱或 URL（§8.2） | header 70–86 | C-1／C-2 的查詢鍵；稽核請求的 `FUNC_ID`；`watermark_funcIds` 的元素值 | 本畫面推導出的功能代號實際值（bean 名稱去底線，或 JSP 檔名去副檔名） |
| C-4 | `requestTimeHandleUUID` | 後端（請求範圍屬性） | header 43、46 | 是否輸出回應時間量測的註冊程式碼 | 本畫面是否由後端設定此屬性 |
| C-5 | `eBAF_loginPlatformInfo`、`eBAF_loginSystemInfo`、`eBAF_UserObject_Flag`、`platformDispatcher` | 後端（請求範圍屬性） | header 55–61 | 是否呼叫 `utility.keep_eBAF_parameter(opt)`，以及 `opt` 內含哪幾個鍵 | 本畫面實際具備哪幾個屬性 |
| C-6 | 請求標頭 `clientheaderhost` 是否含 `w3.cathaylife.com.tw` | 前端閘道／部署環境 | header 292–293 | `EUDC` 字型改由外網 CDN 或站內路徑取得 | 本畫面預期的部署站台（內網／外網） |
| C-7 | `ebaf.JSP_CHAR_LENGTH` 設定值 | 應用程式設定檔 | header 34 | `window.charCountsByte` 的值，影響引用它的長度驗證 | 若本畫面有欄位長度驗證，須敘明所採用的折算數 |
| C-8 | `htmlBase`／`cssBase`／`imageBase`／`dispatcher` 的實際值 | `CXL:csCommon` 標籤（→ U-03） | header 26–29 | 本畫面所有以這些變數組成的資源與服務位址 | 本畫面實際引用了哪幾個，以及組出的完整位址 |
| C-9 | `window.name` 是否為 `mainFrame` | 引入端所在的框架結構 | header 324 | 是否在最上層視窗重設 `watermark_funcIds` 並設定 `watermark_root` | 本畫面被載入的框架名稱 |
| C-10 | 是否存在 `leftFrame`／`bottomFrame` 框架 | 引入端所在的框架結構 | msgDisplayer 62–72 | 訊息走下方訊息欄或走對話框 | 本畫面的框架環境，以及訊息實際呈現在哪裡 |
| C-11 | 是否載入 `WIUtil` 與 `jQuery` | 引入端自行載入 | msgDisplayer 129–130 | 對話框以 `WIUtil.displayMessage` 或原生 `alert()` 呈現 | 本畫面是否載入這兩者 |
| C-12 | 是否載入定義 `utility` 的腳本 | 引入端自行載入 | header 42 | C-4／C-5 的程式碼是否實際執行 | 本畫面是否載入該腳本 |
| C-13 | 本次交易的 `ReturnMessage` 內容（筆數、各筆的 returnCode 與 sysid） | 後端服務回應 | msgDisplayer 7、25–58 | `msgs` 的長度與內容，進而決定對話框與下方訊息欄的呈現 | 本畫面各動作的預期 returnCode 集合，以及對應的訊息呈現 |
| C-14 | 下方訊息框架的 `txHasRollbackPage` 是否為真值 | 交易流程（設定者 → U-10） | msgDisplayer 145、151 | `displayMessage()` 是否提早 return（此時 `alertMessages()` 也不執行） | 本畫面是否有回捲（rollback）流程 |
| C-15 | 引入端是否在本檔之後重新指派 `document.onclick` | 引入端程式碼 | msgDisplayer 174 | 點擊按鈕時是否清除下方訊息（D-12） | 本畫面是否有 `document.onclick` 的指派 |

---

## 附：產出檢查清單執行結果

### K.1 存在性檢查

| 項目 | 結果 |
|---|---|
| §3：每一個 `${...}` / `<%= %>` 都有對應列 | 通過。header 24 個 EL（16 輸出 + 8 條件）、2 個 `<%= %>`；msgDisplayer 9 個 `<%= %>`、0 個 EL。逐一列於 §3.1／§3.2／§3.3 |
| §3.1（本文件為 §3.3）：每個條件輸出的元素都有列 | 通過，13 列 |
| §5：每個輸入/顯示元素都有列 | 不適用，機械確認為 0 個表單元素 |
| §5.1：顯示與送出不一致者 | 不適用（無欄位）；同性質項目登記於 D-08 |
| §6：每個後端呼叫都有「失敗處理」列 | 通過，3 節皆有，皆為「無」或「空 catch」並標 `[DEFECT]` |
| §7.1：每個模組級變數都有列 | 通過，10 項 |
| §8：每個含分支或迴圈的邏輯都有虛擬碼與邊界條件 | 通過，11 節（8.1–8.11，含 8.4.1） |
| §9：每條驗證規則都有觸發時機 | 不適用（無欄位驗證），已交叉引用 §8.1 |
| §10：每個熱鍵都註明目標元素的存在條件 | 通過，Ctrl+A/X/S/P 的存在條件為 `PD_CTRL = Y` |
| §11.1：承載業務或設定語意的字面值都有列 | 通過。純版面屬性值（浮水印幾何）以單列彙整並在 §4.3 交叉引用，未逐格重複 |
| §11.2：代碼說明文字已完整抄錄 | 通過，含 CSS／JS 轉義序列的解碼結果 |
| §13：每個外部腳本都有列並標明行為是否已知 | 通過，18 列 |
| §14：未知清單非空 | 通過，21 項 |
| §15：缺陷登記非空，每列都有「行為後果等級」 | 通過，29 項 |
| §16：檔頭註解與變更註記已搬入 | 通過（兩檔皆無檔頭註解，此事實已記；片段註解移入 §16.1） |
| §17：決策點已列出 | 通過，10 項 |
| §18：查證範圍已列出 | 通過 |

### K.2 正確性驗證

| 項目 | 結果 |
|---|---|
| 每一個引用的行號區間都回原始碼確認過 | 通過。以 `sed -n 'N,Mp'` 逐段回查，並以 `cat -n` 全檔對照。**初稿曾有兩處偏差已更正**：(a) header 的 catch 行號原記為 383／399，實為 382／398；(b) 曾誤以 `wc -l` 的 412／187 為行數，實際行數為 413／188 |
| 每一個計數都以指令數過 | 通過。24／16／8／2／9／6／8／0／0／520／486／603／128／83／8／161／479／6／1／10／16 等計數皆出自 §18.3 的指令 |
| §18 附上所用核對指令 | 通過，見 §18.3 |

### K.3 過度與失準掃描

| 項目 | 結果 |
|---|---|
| 絕對語氣關鍵字掃描（恆／必定／永不／完全／實際上／一律／不可能） | 通過。全文以 `grep -n -E '恆\|必定\|永不\|完全\|實際上\|一律\|不可能'` 掃描。初稿命中 2 處（D-04 的「完全未轉義」、D-11 的「完全空的區塊」），兩者雖為描述原始碼字面形態、前提在可讀範圍內，仍已改寫為不帶絕對語氣的敘述（「未經任何轉義函式處理」「區塊內無任何敘述」）。重跑後本文正文命中 0 處，僅餘 §18.3 的掃描指令與本列的規則名稱。所有執行期行為主張已改用範圍限定句（如「此分支的判斷結果與…相同」「在只支援 `attachEvent` 的瀏覽器上」），或降為 `[ASSUMPTION]` |
| §14 反查（E6） | 通過。21 個未知項逐一反查全文：U-02（`c:out` 轉義）、U-05（`escapeHtml` 轉義集）、U-09（浮水印函式庫全域名）三項原本會支撐肯定句，已在 §3.1、§8.11、§13、§15 D-02／D-03／D-04／D-19 降為 `[ASSUMPTION]` 並附成立條件。正文中的 `[ASSUMPTION]` 標記共 9 處：§3.1 三處（第 58–61 行的 `c:out` 列、第 354 行列、第 358 行列）、§13 兩處（commons-lang 列、JSTL core 列）、§15 四處（D-02、D-03、D-04、D-19）。不含第 14 行的標記約定與本檢查表。§8.11 的對應推論以「→ §14 U-09」「→ §15 D-04」交叉引用，不重複標記（A6） |
| 去重（A6） | 通過。§4.3 的浮水印幾何、§6 的服務位址、§8.1 的正規表示式、§11.1 的常數皆只在一處完整記錄，其餘以「見 §X」帶過。§5.1、§9、§12 以「不適用」＋交叉引用處理，未複述 |
| §15 門檻（G5） | 通過。純寫作風格觀察（`//new` 註解、`<!-- -->` 包裹、第 66 行的 `&&` 寫法、`<c:if  test=` 的兩個空白、尾隨逗號、未使用的匯入與標籤庫宣告）皆移入 §16.1，未進 §15 |
| 一致性（L3） | 本文件為本輪第一份 SoT，尚無其他 SoT 可比對。判準已寫明於本文件供後續引用：同一命題只在本文件裁定強度，各畫面 SoT 引用時沿用（規則 L1／L3） |

### K.4 技術中立

| 項目 | 結果 |
|---|---|
| 全文無模糊措辭 | 通過（「特定條件」「某些情況」「相關處理」皆未出現） |
| 全文無目標框架名稱 | 通過 |
| 原始技術名稱只出現在 §13 與 §15 定位 | 部分通過。JSP／EL／scriptlet／JSTL 等詞另出現在 §2（引入契約）、§3（渲染契約的落點描述）、§19（輸出契約的宣告形式）。此為本文件對象本身即為引入機制所致——「以哪種語法被引入、把值放進哪一種字面量」是行為規格的一部分，不是把實作當規格 |
