# RPTUtil.js 公開契約

> 原始資源：`/CM/js/RPTUtil.js`

## **`RPTUtil.downloadFile(requestURL, params, isOpenNewBrowse)`**

### 用途

- 先以同步業務請求取得受保護的檔名與完整位置，再委派檔案下載契約完成交付。

### 輸入

- `requestURL`: [String] - 準備下載檔案的業務服務位置。
- `params`: [Object = {}] - 準備檔案所需的業務條件。
- `isOpenNewBrowse`: [Boolean = true] - 是否在新操作空間交付檔案；只有明確傳入 `false` 時沿用目前操作空間。

### 輸出

- `return`: [String|undefined] - 檔案準備請求的錯誤訊息；成功或無訊息時為未定義。最終成果透過另一次交付流程提供。

### 對外功能

- 成功回應必須提供下列欄位，再由 `RPTUtil.download` 送往檔案交付服務。
  - `response.downloadFileName`: [String] - 受保護的下載檔名。
  - `response.downloadFileFullPath`: [String] - 受保護的檔案完整位置。

### 副作用

- 會產生檔案準備與檔案交付的網路通訊，且第一階段會阻塞當前作業直到回應。
- 成功時建立或重用隱藏表單並送出，可能開啟新操作空間。
- 失敗時可透過現有共通訊息機制或提示視窗呈現結果。

---

## **`RPTUtil.executeCreateXlsFile(requestURL, params, isOpenNewBrowse)`**

### 用途

- 先以同步請求產生試算表檔案，再將回應的檔案位置與輸出檔名送往匯出服務。

### 輸入

- `requestURL`: [String] - 產生試算表檔案的業務服務位置。
- `params`: [Object = {}] - 產檔條件。
- `isOpenNewBrowse`: [Boolean = true] - 是否在新操作空間下載；只有明確傳入 `false` 時沿用目前空間。

### 輸出

- `return`: [String|undefined] - 產檔請求的錯誤訊息；成功或無訊息時為未定義。檔案由後續下載流程交付。

### 對外功能

- 成功回應必須提供下列欄位；函數會將其轉成隱藏表單參數並送往試算表交付服務。
  - `response.xlsFileFullPath`: [String] - 已產生試算表的完整位置。
  - `response.outputFileName`: [String] - 對外下載檔名。

### 副作用

- 會產生產檔與下載通訊，且第一階段會阻塞當前作業直到回應。
- 會建立或重用隱藏表單、重建其參數內容並送出，可能開啟新操作空間。
- 失敗時可能顯示共通錯誤訊息。

---

## **`RPTUtil.executePrintByResponse(resp, isOpenNewBrowse)`**

### 用途

- 將已準備的加密暫存檔資訊轉為標準列印契約，交由列印服務處理。

### 輸入

- `resp`: [Object] - 列印準備回應。
  - `resp.encryptTempFileFullPath`: [String] - 加密暫存報表的完整位置；若為字串且非空，列印處理器使用此檔案而不再展開報表定義。
  - `resp.IS_TIFF`: [Any = undefined] - TIFF 輸出旗標；僅真值會送出，代碼意義詳見[代碼對照表](#代碼對照表)。
- `isOpenNewBrowse`: [Boolean = true] - 是否在新操作空間執行列印交付。

### 輸出

- 無

### 對外功能

- 將 `resp` 的加密暫存檔位置與 TIFF 旗標轉交 `RPTUtil.executePrintHandler`；不傳遞回應中的其他欄位。

### 副作用

- 會建立或重用隱藏表單、填入受保護檔案參數並送出，可能開啟新操作空間。

---

## **`RPTUtil.executePrintByLink(requestURL, params, isOpenNewBrowse)`**

### 用途

- 以同步請求取得列印準備結果，成功後直接啟動列印交付。

### 輸入

- `requestURL`: [String] - 查詢或準備列印資料的業務服務位置。
- `params`: [Object = {}] - 列印查詢條件。
- `isOpenNewBrowse`: [Boolean = true] - 是否在新操作空間交付列印結果。

### 輸出

- `return`: [String|undefined] - 前置請求的錯誤訊息；成功或無訊息時為未定義。

### 對外功能

- 以同步請求取得列印準備結果，成功後直接啟動列印交付。

### 副作用

- 會產生前置查詢與列印交付通訊，前置請求會阻塞當前作業直到回應。
- 成功時會送出隱藏表單，可能開啟新操作空間；失敗時可能顯示訊息。

---

## **`RPTUtil.download(options)`**

### 用途

- 將已準備的受保護檔案識別資訊送往檔案交付服務。

### 輸入

- `options`: [Object] - 檔案交付契約。
  - `options.downloadFileName`: [String] - 受保護的下載檔名。
  - `options.downloadFileFullPath`: [String] - 受保護的檔案完整位置。
  - `options.isOpenNewBrowse`: [Boolean = true] - 是否在新操作空間交付檔案；明確為 `false` 時沿用目前空間。

### 輸出

- 無

### 對外功能

- 將 `downloadFileName` 與 `downloadFileFullPath` 轉為[代碼對照表](#代碼對照表)所列隱藏欄位，送往檔案交付服務。

### 副作用

- 會建立或重用隱藏表單、清除舊參數、填入檔案資訊並送出，可能開啟新操作空間。

---

## **`RPTUtil.executeCreateCsvFile(requestURL, params)`**

### 用途

- 透過試算表產檔與下載契約處理分隔文字檔；交付方式使用預設的新操作空間。

### 輸入

- `requestURL`: [String] - 產生分隔文字檔的業務服務位置。
- `params`: [Object = {}] - 產檔條件。

### 輸出

- 無

### 對外功能

- 透過試算表產檔與下載契約處理分隔文字檔；交付方式使用預設的新操作空間。

### 副作用

- 與 `executeCreateXlsFile(requestURL, params)` 相同：產生同步產檔請求，並透過隱藏表單啟動下載；原始簽章不轉傳被呼叫函數的回傳值。

---

## **`RPTUtil.executeSecurityPrintHandler(resp, isOpenNewBrowse, beforeActions, isIndependent)`**

### 用途

- 將安全列印回應、水印交付資訊、前置操作與額外參數組成安全交付請求。

### 輸入

- `resp`: [Object] - 安全列印回應。
  - `resp.encryptTempFileFullPath`: [String] - 加密暫存報表的完整位置。
  - `resp.encryptMarkedFileFullPath`: [String = undefined] - 已加密水印檔的完整位置；真值才送出。
  - `resp.encryptMarkedFileName`: [String = undefined] - 已加密水印檔的檔名；真值才送出。
  - `resp.downloadFileName`: [String = undefined] - 下載檔名；必須是非空字串才送出。
  - `resp.submitParam`: [Object = undefined] - 直接附加到送出表單的額外參數。
    - `resp.submitParam.{key}`: [Any] - 以屬性名稱作為隱藏欄位名稱、屬性值作為欄位值。
- `isOpenNewBrowse`: [Boolean = true] - 是否在新操作空間執行。
- `beforeActions`: [Array<Object>|Boolean = false] - 檔案交付前由服務端依序執行的操作；只有陣列會被處理。
  - `beforeActions[].url`: [String] - 前置操作位置。
  - `beforeActions[].parameters`: [String = "{}"] - 前置操作參數；空值會改送字串 `"{}"`，非空物件不會自動序列化而由隱藏欄位執行字串轉換。
- `isIndependent`: [Boolean = false] - 重用現有表單時，是否每次都建立獨立新操作空間。

### 輸出

- 無

### 對外功能

- 以 `AppletServlet` 為交付端點，將加密暫存檔、水印檔、下載檔名、前置操作與額外參數展開為隱藏欄位後送出。

### 副作用

- 會建立或重用隱藏表單，加入回應與前置操作參數後送出，可能開啟一個或獨立的新操作空間。
- `submitParam` 欄位附加在可清空的參數容器之外；重複使用既有表單時，先前欄位不會移除，可能累積同名參數。

---

## **`RPTUtil.fileWatchDog(requestURL, params)`**

### 用途

- 以同步請求取得一個或多個加密暫存檔識別值，並為每個檔案啟動獨立的檢視或監看流程。

### 輸入

- `requestURL`: [String] - 查詢可監看檔案的業務服務位置。
- `params`: [Object = {}] - 查詢參數。
  - `params.enableWaterMark`: [Any = "false"] - 傳給檔案檢視服務的水印旗標；只有 `params` 整體未提供時才明確使用字串 `"false"`，提供空物件時該值為未定義。

### 輸出

- `return`: [String|undefined] - 前置請求的錯誤訊息；成功或無訊息時為未定義。

### 對外功能

- 優先讀取回應的 `encryptTempFileFullPaths` 陣列並逐筆開啟；陣列不存在時改讀單一 `encryptTempFileFullPath`。單一檔案模式另送出目前報表服務的 `webName`。

### 副作用

- 前置請求會阻塞當前作業直到回應，失敗時可能顯示訊息。
- 每個回傳檔案都會建立隱藏表單參數、開啟不共用的新操作空間並送出請求。

---

## **`RPTUtil.executePrint(pageIds, rptParams, rptDetails, isOpenNewBrowse, isTiff)`**

### 用途

- 將單一或批次報表的識別值、主參數與明細資料組成列印請求，並選擇性指定 TIFF 輸出。

### 輸入

- `pageIds`: [String|Array<String>] - 報表或頁面識別值。
- `rptParams`: [Any|Array<Any>] - 報表主參數。陣列模式的展開規則詳見[代碼對照表](#代碼對照表)。
- `rptDetails`: [Any|Array<Any>] - 報表明細資料；陣列時每一項都產生一個明細欄位，未檢查是否與 `rptParams` 等長。
- `isOpenNewBrowse`: [Boolean = true] - 是否在新操作空間交付。
- `isTiff`: [Boolean = false] - 是否要求 TIFF 格式。

### 輸出

- 無

### 對外功能

- 將參數轉交 `RPTUtil.executePrintHandler`；`isTiff` 為真值時寫入 `IS_TIFF = "Y"`，否則不寫入此欄位。

### 副作用

- 會建立或重用隱藏表單，依陣列長度展開報表參數後送往列印服務，可能開啟新操作空間。

---

## **`RPTUtil.genBarcode(options, node)`**

### 用途

- 將條碼值與尺寸、旋轉選項組成圖像資源位置，並建立可由呼叫端放入畫面的圖像。

### 輸入

- `options`: [Object] - 條碼產生選項。
  - `options.value`: [String] - 條碼內容，直接串接到 `inputStr` 查詢參數，原始實作不執行網址編碼。
  - `options.width`: [Number = undefined] - 條碼寬度；只有真值才附加到資源位置。原始註解宣稱預設為 `1`，但實作未將該預設值送出。
  - `options.height`: [Number = undefined] - 條碼高度；只有真值才附加到資源位置。原始註解宣稱預設為 `22`，但實作未將該預設值送出。
  - `options.rotate`: [Boolean = undefined] - 是否旋轉九十度；只有真值才附加，因此 `false` 與未指定均不會出現在資源位置。
- `node`: [Any = undefined] - 原始簽章保留的參數；實作未讀取也不會自動附加結果。

### 輸出

- `return`: [HTMLImageElement] - 來源指向條碼產生服務的圖像元素。

### 對外功能

- 建立 `<img>` 元素，將條碼服務位置設為 `src`；服務端未收到的尺寸與旋轉選項由服務端自行決定預設行為。

### 副作用

- 建立圖像元素並設定其資源位置；當呼叫端將元素置入畫面時，會向條碼服務載入圖像。

---

## **`RPTUtil.executeSecurityPrintByResponse(resp, isOpenNewBrowse, isIndependent)`**

### 用途

- 以不含前置操作的預設方式，將安全列印回應委派給完整安全交付契約。

### 輸入

- `resp`: [Object] - 安全列印回應；欄位結構與 `RPTUtil.executeSecurityPrintHandler` 的 `resp` 完全相同。
- `isOpenNewBrowse`: [Boolean = true] - 是否在新操作空間執行。
- `isIndependent`: [Boolean = false] - 重用現有表單時，是否每次使用獨立新操作空間。

### 輸出

- 無

### 對外功能

- 以不含前置操作的預設方式，將安全列印回應委派給完整安全交付契約。

### 副作用

- 與 `executeSecurityPrintHandler(resp, isOpenNewBrowse, false, isIndependent)` 相同：建立或重用隱藏表單並送出，可能開啟新操作空間。

---

## **`RPTUtil.executePrintHandler(options)`** — 報表定義用法

### 用途

- 將單一或批次報表定義送往標準列印服務。

### 輸入

- `options`: [Object] - 報表定義列印契約。
  - `options.pageIds`: [String|Array<String>] - 報表或頁面識別值。
  - `options.rptParams`: [Any|Array<Any>] - 報表主參數；陣列模式展開規則詳見[代碼對照表](#代碼對照表)。
  - `options.rptDetails`: [Any|Array<Any>] - 報表明細；陣列時逐項送出。
  - `options.isOpenNewBrowse`: [Boolean = true] - 是否在新操作空間送出；只有明確 `false` 表示沿用目前空間。
  - `options.isIndependent`: [Boolean = false] - 重用既有表單時是否重新建立獨立目標空間。
  - `options.downloadFileName`: [String = undefined] - 不含副檔名的下載檔名；非空字串才送出。
  - `options.beforeActions`: [Array<Object>|Boolean = false] - 送出前的服務端操作，結構與 `RPTUtil.executeSecurityPrintHandler` 的 `beforeActions` 相同。
  - `options.submitParam`: [Object = undefined] - 額外送出參數，結構與 `RPTUtil.executeSecurityPrintHandler` 的 `resp.submitParam` 相同。
  - `options.IS_TIFF`: [Any = undefined] - 真值才送出的 TIFF 旗標。

### 輸出

- 無

### 對外功能

- 將報表識別值、主參數與明細依[代碼對照表](#代碼對照表)展開為隱藏欄位，並送往 `RptServlet`。

### 副作用

- 會在 `options` 寫入標準列印服務名稱。
- 會建立或重用隱藏表單，清除舊列印參數、展開新參數並送出，可能開啟新操作空間。
- 重用表單時，`isOpenNewBrowse === false` 不會清除既有 `target`；若先前表單已指向新操作空間，後續送出仍可能沿用該目標。

---

## **`RPTUtil.executePrintHandler(options)`** — 加密暫存檔用法

### 用途

- 將已產生的加密暫存報表檔送往標準列印服務。

### 輸入

- `options`: [Object] - 加密暫存檔列印契約。
  - `options.encryptTempFileFullPath`: [String] - 加密暫存報表的完整位置；必須是非空字串，本模式才會取代報表定義模式。
  - `options.encryptMarkedFileFullPath`: [String = undefined] - 加密水印檔完整位置；真值才送出。
  - `options.encryptMarkedFileName`: [String = undefined] - 加密水印檔名稱；真值才送出。
  - `options.isOpenNewBrowse`: [Boolean = true] - 是否在新操作空間送出。
  - `options.isIndependent`: [Boolean = false] - 重用既有表單時是否重新建立獨立目標空間。
  - `options.downloadFileName`: [String = undefined] - 下載檔名；非空字串才送出。
  - `options.beforeActions`: [Array<Object>|Boolean = false] - 送出前的服務端操作，結構與 `RPTUtil.executeSecurityPrintHandler` 的 `beforeActions` 相同。
  - `options.submitParam`: [Object = undefined] - 額外送出參數，結構與 `RPTUtil.executeSecurityPrintHandler` 的 `resp.submitParam` 相同。
  - `options.IS_TIFF`: [Any = undefined] - 真值才送出的 TIFF 旗標。

### 輸出

- 無

### 對外功能

- 加密暫存檔位置有效時只送出檔案相關欄位，不讀取 `pageIds`、`rptParams` 或 `rptDetails`，並將資料送往 `RptServlet`。

### 副作用

- 會在 `options` 寫入 `servletName = "RptServlet"`。
- 會建立或重用隱藏表單，展開檔案、前置操作及額外參數後送出；`submitParam` 可能在重用表單時累積。
- 重用表單時，既有 `target` 可能使 `isOpenNewBrowse === false` 的送出仍沿用先前新操作空間。

---

## **`RPTUtil.downloadPrintData(pageIds, rptParams, rptDetails, downloadFileName, isTiff)`**

### 用途

- 將單一或批次報表定義組成下載用列印資料，並指定下載檔名與選擇性 TIFF 輸出。

### 輸入

- `pageIds`: [String|Array<String>] - 報表或頁面識別值。
- `rptParams`: [Any|Array<Any>] - 報表主參數。
- `rptDetails`: [Any|Array<Any>] - 報表明細資料。
- `downloadFileName`: [String] - 下載時使用的檔名，不含副檔名。
- `isTiff`: [Boolean = false] - 是否要求 TIFF 格式。

### 輸出

- 無

### 對外功能

- 將參數轉交 `RPTUtil.executePrintHandler`；`isTiff` 為真值時寫入 `IS_TIFF = "Y"`。函數未指定 `isOpenNewBrowse`，因此建立表單時採新操作空間預設值。

### 副作用

- 會建立或重用隱藏表單，展開報表與下載參數後送往列印服務；未指定開啟方式時使用新操作空間。

---

## **`RPTUtil.createHiddenElementByPrintParameter(n, v)`**

### 用途

- 建立列印、下載或檔案交付表單所需的單一隱藏參數元素。

### 輸入

- `n`: [String] - 送出參數名稱。
- `v`: [Any] - 送出參數值，由欄位契約轉為文字。

### 輸出

- `return`: [HTMLInputElement] - 名稱與值已設定的隱藏輸入元素，尚未自動附加到畫面。

### 對外功能

- 建立 `type = "hidden"` 的 `<input>`，將 `n` 指派給 `name`、將 `v` 指派給 `value` 後回傳。

### 副作用

- 僅在記憶體中建立元素；除非呼叫端另行附加，否則不改變畫面。

## 代碼對照表

### 列印與檔案交付參數

| 參數代碼 | 用途 |
| --- | --- |
| `RPT_URL` | 報表或頁面識別值。 |
| `RPT_PARAM` | 報表主參數。 |
| `RPT_DETAIL` | 報表明細資料。 |
| `IS_TIFF` | TIFF 輸出旗標；便捷函數在 `isTiff` 為真值時送出字串 `"Y"`。 |
| `encryptTempFileFullPath` | 加密暫存報表完整位置。 |
| `encryptMarkedFileFullPath` | 加密水印檔完整位置。 |
| `encryptMarkedFileName` | 加密水印檔名稱。 |
| `downloadFileName` | 對外下載檔名。 |
| `downloadFileFullPath` | 下載來源檔案的完整位置。 |
| `xlsFileFullPath` | 已產生試算表的完整位置。 |
| `outputFileName` | 試算表對外下載檔名。 |
| `url` | 檔案交付前要執行的操作位置；可重複出現。 |
| `parameters` | 與同位置 `url` 對應的前置操作參數；可重複出現。 |

### 批次報表展開規則

| `rptParams` | `pageIds` | 實際送出規則 |
| --- | --- | --- |
| 非陣列 | 任意型別 | 各送出一個 `RPT_URL` 與 `RPT_PARAM`。 |
| 陣列 | 非陣列 | 每一筆主參數都重複送出同一個 `RPT_URL`。 |
| 陣列 | 等長陣列 | 先依序送出所有 `RPT_URL`，再依序送出所有 `RPT_PARAM`；以位置對應。 |
| 陣列 | 不等長陣列 | 每一筆主參數都使用 `pageIds[0]` 作為 `RPT_URL`；其餘頁面識別值不使用。 |
