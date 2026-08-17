# CSRUtil.js 公開契約

> 原始資源：`/CM/js/ajax/CSRUtil.js`

## **`CSRUtil.isSuccess(resp)`**

### 用途

- 依共通回應契約的結果碼，判定業務作業是否成功。

### 輸入

- `resp`: [Object] - 待判定的業務回應。
  - `resp.ErrMsg`: [Object = undefined] - 共通結果訊息；欄位定義詳見[代碼對照表](#代碼對照表)。
    - `resp.ErrMsg.returnCode`: [Any] - 以寬鬆相等比較判定是否等於數值 `0`。

### 輸出

- `return`: [Boolean = false] - 結果碼為零時回傳 `true`；回應、結果資訊缺失或結果碼非零時回傳 `false`。

### 對外功能

- 先透過 `CSRUtil.getReturnMessage` 取得 `resp.ErrMsg`；存在且 `returnCode == 0` 時回傳 `true`，其餘情況回傳 `false`。

### 副作用

- 無

---

## **`CSRUtil.linkBack(backAction, cbFuncOptions)`**

### 用途

- 從導航紀錄解析先前來源，必要時依作業名稱往前搜尋，再送出返回要求。

### 輸入

- `backAction`: [Any = undefined] - 未指定時使用最近一筆紀錄的 `RQ_SENDER`；恰為九個字元的字串時視為作業名稱並向前搜尋；其他真值直接指派為返回位置，送出表單時再轉成屬性文字。
- `cbFuncOptions`: [Object = {}] - 錯誤處理與參數送回選項。
  - `cbFuncOptions.mappingOnError`: [Function = undefined] - 九字元作業名稱找不到對應紀錄時呼叫，形式為 `mappingOnError()`；回傳值不使用。
  - `cbFuncOptions.backOnError`: [Function = undefined] - 最終沒有返回位置時呼叫，形式為 `backOnError()`；回傳值不使用。
  - `cbFuncOptions.isSubmitParameters`: [Boolean = false] - 僅嚴格等於 `true` 時，才將找到紀錄的 `BQ_ARG` 各屬性轉為隱藏欄位送回。

### 輸出

- 無

### 對外功能

- 九字元作業名稱模式會從最後一筆紀錄向前移除不符合項目，直到 `RQ_SENDER` 包含該名稱；其他模式直接解析返回位置。找到位置後以 `POST` 隱藏表單送出。

### 副作用

- 九字元作業名稱模式會永久移除搜尋途中不符合的較新紀錄，但保留符合紀錄本身。
- 會建立隱藏表單、送出請求並導航離開當前畫面。
- 找不到返回目標時會執行指定回呼，否則顯示錯誤訊息。

---

## **`CSRUtil.linkTo(linkParams, formID)`**

### 用途

- 將目標、來源與查詢狀態組成可返回的導航紀錄，並前往指定畫面。

### 輸入

- `linkParams`: [Object] - 導航契約；欄位名稱亦整理於[代碼對照表](#代碼對照表)。
  - `linkParams.action`: [String] - 必要的前往位置，同時作為隱藏表單的 `action`。
  - `linkParams.BQ_ARG`: [Object = {}] - 返回時要復原的查詢條件。既有值先複製，再由表單同名值覆寫。
    - `linkParams.BQ_ARG.{key}`: [Any] - 以業務欄位名稱為鍵的保留值。
  - `linkParams.RQ_SENDER`: [String] - 呼叫時由函數覆寫為目前 `window.location.pathname`，不採用呼叫端原值。
  - `linkParams.{key}`: [Any] - 其他業務欄位會保存在 `LP_JSON` 中；函數不會另外建立同名送出欄位。
- `formID`: [String|HTMLFormElement = undefined] - 要序列化並保留的表單。

### 輸出

- 無

### 對外功能

- 將完整 `linkParams` 序列化成單一 `LP_JSON` 隱藏欄位，追加至導航堆疊，再透過 `submitOnce` 送出表單。

### 副作用

- 會將表單值合併回 `linkParams.BQ_ARG`，並在 `linkParams` 寫入來源位置。
- 會將導航紀錄寫入共用視窗或會話儲存區。
- 會建立隱藏表單、送出請求並導航離開當前畫面；缺少目標時顯示訊息。

---

## **`CSRUtil.AjaxHandler.request(requestTxBean)`**

### 用途

- 建立以指定服務位置為基準的標準業務請求物件。

### 輸入

- `requestTxBean`: [String] - 後續業務操作共用的服務基準位置。

### 輸出

- `return`: [Object] - 請求物件。原始實作是回傳物件的工廠函數；即使舊程式以 `new` 呼叫，JavaScript 仍採用此明確回傳物件。
  - `return.post`: [Function] - 本文件另列的 `request.post(action, params, successAction, failureAction)`。
  - `return.setSynchronous`: [Function] - `setSynchronous(isSync)`；將內部 `asynchronous` 設為 `!isSync`，未回傳值。
    - `isSync`: [Boolean] - 真值表示後續請求採同步模式。
  - `return.setShowCoverPage`: [Function] - `setShowCoverPage(isShow)`；設定後續請求是否顯示作業遮罩，未回傳值。
    - `isShow`: [Boolean] - 是否顯示作業遮罩。
  - `return.closeSuccMsg`: [Function] - `closeSuccMsg()`；抑制下一次由共通 Prototype 回應器顯示的成功訊息，未回傳值。
  - `return.enforceUse_jQuery`: [Function] - `enforceUse_jQuery(isUse)`；強制選擇或停用 jQuery 傳輸路徑，未回傳值。
    - `isUse`: [Boolean] - 是否使用 jQuery 傳輸路徑。

### 對外功能

- 每次呼叫建立獨立的同步設定；遮罩、成功訊息及傳輸實作設定則由 `CSRUtil.AjaxHandler` 共用。

### 副作用

- 無

---

## **`CSRUtil.AjaxHandler.request(requestTxBean).post(action, params, successAction, failureAction)`**

### 用途

- 向組合後的服務位置送出標準業務請求，並依結果碼分派成功或失敗行為。

### 輸入

- `requestTxBean`: [String] - 建立請求物件時指定的服務基準位置。
- `action`: [String] - 相對於服務基準位置的業務操作名稱。
- `params`: [Object|String = undefined] - 請求參數。
- `successAction`: [Function = undefined] - `CSRUtil.isSuccess(resp)` 為真時呼叫，形式為 `successAction(resp)`；回傳值不使用。
- `failureAction`: [Function = undefined] - 共通結果存在但業務結果非成功時呼叫，形式為 `failureAction(resp)`；回傳值不使用。

### 輸出

- 無

### 對外功能

- 將 `requestTxBean + action` 作為要求位置並以 `POST` 送出。jQuery 路徑直接接收回應物件；Prototype 路徑讀取 `transport.responseJSON`，再依 `ErrMsg.returnCode` 分派回呼。

### 副作用

- 會產生網路通訊。
- 作業期間可能顯示處理中狀態並暫時限制其他操作，完成後恢復。
- 可能顯示共通結果訊息、記錄回應時間，並執行其中一個回呼；回應缺少結果資訊時可能不執行任何回呼。

---

## **`CSRUtil.isBackLink(formID, backFunc)`**

### 用途

- 判定當前畫面是否由先前導航紀錄返回，並選擇性復原查詢狀態。

### 輸入

- `formID`: [String|HTMLElement = undefined] - 要復原保留參數的容器。
- `backFunc`: [Function = undefined] - 復原完成後呼叫，形式為 `backFunc(BQ_ARG)`；回傳值不使用。

### 輸出

- `return`: [Object|Boolean = false] - 從上一畫面返回時為已消費的導航紀錄，否則為 `false`。

### 對外功能

- 最近紀錄的 `RQ_SENDER` 必須嚴格等於目前 `window.location.pathname` 才視為返回；符合時取出 `BQ_ARG`、選擇性寫入畫面並執行回呼。

### 副作用

- 成功配對時會從儲存區移除該筆導航紀錄。
- 可能改寫畫面欄位，並執行 `backFunc`。

---

## **`CSRUtil.keepParamsManager.put(inParams, overWrite)`**

### 用途

- 將一組參數合併進現有的跨畫面保留參數。

### 輸入

- `inParams`: [Object] - 要合併保留的鍵值集合。
- `overWrite`: [Boolean = true] - 是否覆寫既有同名值；只有明確傳入 `false` 時，才保留所有不等於 `undefined` 或 `null` 的既有值，包括空字串、`false` 與 `0`。

### 輸出

- 無

### 對外功能

- 將一組參數合併進現有的跨畫面保留參數。

### 副作用

- 會寫入共用視窗或會話儲存區。

---

## **`CSRUtil.keepParamsManager.get(key)`**

### 用途

- 取得單一跨畫面保留參數。

### 輸入

- `key`: [String] - 參數名稱。

### 輸出

- `return`: [Any|String = ""] - 對應值；參數集合或值不存在時回傳空字串。

### 對外功能

- 取得單一跨畫面保留參數。

### 副作用

- 無

---

## **`autoFormatToDate()`**

### 用途

- 為尚未初始化的日期輸入欄位加入數字限制、分隔符自動補入與完整日期校驗行為。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 僅處理尚未具有 `hasAutoFormatToDateEvent` 類別且符合 `input[datatype="date"]` 的欄位；輸入至第 4、7 碼時自動補 `-`，到第 10 碼時驗證實際年月日，無效則復原 `__lastValue` 或空字串。

### 副作用

- 會設定符合 `datatype="date"` 欄位的顯示寬度、長度上限與初始化標記。
- 未指定 `size` 時設為 `11`，並一律將 `maxLength` 設為 `10`。
- 會註冊輸入法完成、按鍵按下與放開事件；阻止負號及未列入允許或略過集合的按鍵，並將輸入法產生的結尾雙連字號縮減為一個。

---

## **`CSRUtil.createCoverPage(inputOpts)`**

### 用途

- 依選項取得或建立作業中遮罩，可顯示進度圖像與提示訊息。

### 輸入

- `inputOpts`: [String|Object = {}] - 字串直接作為 `id`；物件模式支援下列欄位。
  - `inputOpts.id`: [String = undefined] - 遮罩元素識別值；用於重用既有元素，原始實作未提供有效預設值。
  - `inputOpts.transparent`: [Boolean = false] - 嚴格等於 `true` 時使用透明背景且不建立載入圖示。
  - `inputOpts.cursor`: [String = "progress"] - 遮罩顯示時的游標樣式。
  - `inputOpts.show`: [Boolean = false] - 嚴格等於 `true` 時完成後顯示遮罩；其餘值會隱藏遮罩，包括重用的既有元素。
  - `inputOpts.tipsMsg`: [String = ""] - 非空時以 HTML 內容建立置中的提示區塊。
  - `inputOpts.zIndex`: [Number = 150] - 疊放順序；任何假值都會改用 `150`。

### 輸出

- `return`: [HTMLElement] - 現有或新建的全畫面遮罩元素。
  - `return.show`: [Function] - `show()`；顯示遮罩並回傳遮罩本身。
  - `return.hide`: [Function] - `hide()`；隱藏遮罩並回傳遮罩本身。
  - `return.resizeCoverPage`: [Function] - `resizeCoverPage()`；固定定位不可用時將高度擴張至完整文件高度，未回傳值。

### 對外功能

- 依選項取得或建立作業中遮罩，可顯示進度圖像與提示訊息。

### 副作用

- 首次建立時會在畫面主體附加元素與視覺樣式。
- 每次呼叫都會調整尺寸，並依 `show` 顯示或隱藏元素；可能把焦點從按鈕移回視窗。
- 會寫入未局部宣告的全域名稱 `inputId`；`tipsMsg` 直接指定為 `innerHTML`。
- 若文件中已存在同識別值但不是由本函數建立的元素，該元素缺少 `resizeCoverPage`、`show` 與 `hide` 方法，呼叫期間可能拋出例外。

---

## **`CSRUtil.maskHandler.getMaskName(str, inSign)`**

### 用途

- 以姓名專用規則隱藏部分個人識別資訊。

### 輸入

- `str`: [String] - 待遮罩的姓名。
- `inSign`: [String = "＊"] - 替代符號；假值改用全形星號。

### 輸出

- `return`: [String] - 保留第一個字、遮罩第二個字後的結果；空值照原值回傳。

### 對外功能

- 呼叫一般遮罩函數，固定由索引 `1` 起遮蔽一個字元；實作是遮蔽第二個字元，不是原始註解所稱「由右向左第二個字」。

### 副作用

- 無

---

## **`CSRUtil.maskHandler.getMaskID(str, maskLength)`**

### 用途

- 保留識別碼前後部分字元，隱藏中間區段。

### 輸入

- `str`: [String] - 待遮罩的識別碼。
- `maskLength`: [Number|String = 3] - 中間要遮罩的字元數；`isNaN(maskLength)` 為真時改用 `3`，可轉數值的字串則由後續運算隱式轉型。

### 輸出

- `return`: [String] - 遮罩指定長度中間區段後的字串；原值太短或空時回傳全遮罩符號。

### 對外功能

- 保留識別碼前後部分字元，隱藏中間區段。

### 副作用

- 無

---

## **`CSRUtil.getLP_JSON(remove)`**

### 用途

- 從共用視窗或會話儲存區取得最近的跨畫面導航契約。

### 輸入

- `remove`: [Boolean = false] - 真值會啟用取出後回寫；預期用途是於最近紀錄來源等於目前位置時移除該筆。

### 輸出

- `return`: [Object = {}] - 最近一筆導航紀錄；欄位結構見[代碼對照表](#代碼對照表)。無紀錄、格式無法解析或發生例外時回傳空物件。

### 對外功能

- 讀取並解析單一紀錄或紀錄陣列；陣列回傳最後一筆，單一物件直接回傳。

### 副作用

- `remove` 為真時一定進行回寫。來源相符的陣列會移除最後一筆並保留其餘紀錄；來源不相符或單一物件模式沒有建立剩餘值時，原始實作仍會清除全部儲存紀錄。
- 解析或存取失敗時可能寫入主控台診斷訊息。

---

## **`CSRUtil.voToInputs(panel_id, vo)`**

### 用途

- 將資料物件映射至容器內的文字、隱藏、多行、選擇、單選、複選與指定顯示元素。

### 輸入

- `panel_id`: [String|HTMLElement] - 要寫入的畫面容器。
- `vo`: [Object] - 以欄位名稱或顯示元素識別名稱為鍵的值集合。

### 輸出

- 無

### 對外功能

- 文字、隱藏與多行欄位依 `name` 取值；單選與複選欄位僅在資料值嚴格等於欄位值時勾選；下拉欄位另同步其 `ref` 指定欄位或 `{name}_NAME` 欄位；識別值以 `_TXT` 結尾的顯示元素依去除尾碼後的鍵取值。

### 副作用

- 會改寫欄位值、勾選狀態與顯示內容。
- 選擇欄位具有關聯名稱欄位時，會一併更新該欄位。

---

## **`CSRUtil.defaultPattern`**

### 用途

- 提供數值千分位與最多四位小數的共用預設格式契約。

### 輸入

- 無

### 輸出

- `value`: [String = "#,###.####"] - 預設數值顯示格式；格式代碼詳見[代碼對照表](#代碼對照表)。

### 對外功能

- 提供數值千分位與最多四位小數的共用預設格式契約。

### 副作用

- 無

---

## **`CSRUtil.inputsToVo(panel_id, includeDisabled)`**

### 用途

- 將容器內可傳遞的輸入狀態收集為業務資料物件。

### 輸入

- `panel_id`: [String|HTMLElement] - 要讀取的畫面容器。
- `includeDisabled`: [Boolean = false] - 是否納入已停用的文字、選擇、隱藏與多行欄位。

### 輸出

- `return`: [Object] - 以欄位名稱為鍵的畫面值集合；單選與複選欄位只納入已勾選項目。

### 對外功能

- 文字、下拉、隱藏及多行欄位依 `includeDisabled` 決定是否納入；已勾選的單選與複選欄位不檢查停用狀態。多個同名欄位會由後讀取值覆寫先讀取值。

### 副作用

- 無

---

## **`CSRUtil.getNumber(val)`**

### 用途

- 將共用數值輸入正規化為可運算數值。

### 輸入

- `val`: [Any] - 待轉換的數值或數值文字，可含千分位符號。

### 輸出

- `return`: [Number = 0] - 轉換後數值；空字串、`null`、未定義值或無法轉換的文字回傳 `0`。已是 Number 型別的值會直接回傳，因此 Number 型別的 `NaN` 不會改成 `0`。

### 對外功能

- 將共用數值輸入正規化為可運算數值。

### 副作用

- 無

---

## **`CSRUtil.round(val, scale)`**

### 用途

- 對數值執行指定精度的一般四捨五入。

### 輸入

- `val`: [Number] - 待取捨數值。
- `scale`: [Number = 4] - 保留的小數位數。

### 輸出

- `return`: [Number] - 依指定小數位數四捨五入後的值。

### 對外功能

- 以 `Math.round(val × 10^scale) ÷ 10^scale` 計算結果；負數恰逢半值時沿用 JavaScript `Math.round` 向正無限方向取整的規則。

### 副作用

- 無

---

## **`CSRUtil.pressNumber(code)`**

### 用途

- 判定按鍵是否屬於共通數值輸入所允許的字元集合。

### 輸入

- `code`: [Number] - 按鍵字碼。

### 輸出

- `return`: [Boolean] - 按鍵字碼符合[代碼對照表](#代碼對照表)時為 `true`，否則為 `false`。

### 對外功能

- 判定按鍵是否屬於共通數值輸入所允許的字元集合。

### 副作用

- 無

---

## **`CSRUtil.getReturnMessage(resp)`**

### 用途

- 從共通回應契約取出結果訊息。

### 輸入

- `resp`: [Object = undefined] - 標準業務回應。
  - `resp.ErrMsg`: [Object = undefined] - 要取出的共通結果訊息；欄位定義詳見[代碼對照表](#代碼對照表)。

### 輸出

- `return`: [Object|undefined] - 回應的 `ErrMsg` 結果資訊；無回應時為未定義。

### 對外功能

- 從共通回應契約取出結果訊息。

### 副作用

- 無

---

## **`CSRUtil.defaultAjaxHandler`**

### 用途

- 提供可登錄到共用通訊機制的預設作業週期契約，統一處理進度、逾時與結果訊息。

### 輸入

- 無

### 輸出

- `value`: [Object] - 已建立的共通回應器；頁面載入本檔且同時存在 Prototype 時，才會登錄至 `Ajax.Responders`。
  - `value.onCreate`: [Function] - `onCreate(request)`；登錄進行中狀態、顯示遮罩，並依 `request.options.timeout` 建立逾時計時器。
  - `value.onComplete`: [Function] - `onComplete(request, transport)`；清除逾時計時器、解析 `transport.responseJSON` 或文字錯誤頁、更新回應時間追蹤並呈現結果訊息。
  - `value.onException`: [Function] - `onException(XHR, ex)`；組合要求位置、參數及例外屬性後顯示診斷訊息。

### 對外功能

- 提供可登錄到共用通訊機制的預設作業週期契約，統一處理進度、逾時與結果訊息。

### 副作用

- 取得屬性本身不會產生副作用；當其回呼被通訊機制執行時，會顯示或隱藏遮罩與訊息、管理逾時計時、中止逾時請求，並可能顯示例外診斷資訊。

---

## **`CSRUtil.maskHandler.getMaskAddress2(str, inSign)`**

### 用途

- 依地址長度動態決定可顯示前綴，隱藏其餘內容。

### 輸入

- `str`: [String] - 待遮罩的地址。
- `inSign`: [String = "＊"] - 替代符號；假值改用全形星號。

### 輸出

- `return`: [String] - 長度超過二十時保留前二十個字元，長度超過十時保留前十個字元，其餘字元遮罩；十個字元以下照原值回傳。

### 對外功能

- 依地址長度動態決定可顯示前綴，隱藏其餘內容。

### 副作用

- 無

---

## **`CSRUtil.maskHandler.getMaskAddress(str, inSign)`**

### 用途

- 以固定前綴規則隱藏地址的詳細位置資訊。

### 輸入

- `str`: [String] - 待遮罩的地址。
- `inSign`: [String = "＊"] - 替代符號；假值改用全形星號。

### 輸出

- `return`: [String] - 保留前三個字元、遮罩後續內容的字串；空值照原值回傳。

### 對外功能

- 以固定前綴規則隱藏地址的詳細位置資訊。

### 副作用

- 無

---

## **`CSRUtil.exportXls(fileName, grids, sheetNames)`**

### 用途

- 將一個或多個表格的欄位、資料型態、紀錄與合併欄資訊組成試算表匯出契約，交由匯出服務產生檔案。

### 輸入

- `fileName`: [String] - 下載檔名。
- `grids`: [Array<Object>] - 要匯出的表格物件集合。
  - `grids[].getColumns`: [Function] - `getColumns()`；回傳欄定義陣列。
    - `columns[].dataIndex`: [String] - 資料欄鍵；`_grid_selected_row` 與 `_grid_onRowClick` 會排除。
    - `columns[].header`: [String] - 欄標題。
  - `grids[].getRecords`: [Function] - `getRecords()`；回傳資料物件陣列。第一筆資料決定各欄輸出型別為 `number` 或 `string`。
    - `records[].{dataIndex}`: [Any] - 對應欄位的資料值。
  - `grids[].getEmptyColumns`: [Function] - `getEmptyColumns()`；回傳空白或合併標題欄陣列，亦可回傳空值。
    - `emptyColumns[].header`: [String = ""] - 空白欄標題。
    - `emptyColumns[].attrs.colSpan`: [Number = 1] - 合併欄數；假值採 `1`。
- `sheetNames`: [Array<String> = []] - 各表格對應的工作表名稱。

### 輸出

- 無

### 對外功能

- 依 `grids` 順序建立 `sheets`，將 `fileName`、工作表名稱、欄位型別、資料與空白欄序列化為 `xlsData`，以 `POST` 送往固定位置 `/ZRWeb/xls`。

### 副作用

- 會在畫面主體暫時建立隱藏表單、送出含完整表格資料的請求至新操作空間，然後移除表單。

---

## **`CSRUtil.maskHandler.getMaskStr(str, beginIndex, maskLength, inSign)`**

### 用途

- 依起始位置、長度與替代符號執行一般字串遮罩。

### 輸入

- `str`: [String|Number] - 待遮罩的值；建議傳入字串。數值會嘗試轉成十進位字串，但原始實作未同步重算長度，部分分支可能產生非預期結果。
- `beginIndex`: [Number] - 從零開始計算的遮罩起始位置。
- `maskLength`: [Number|Boolean = undefined] - 遮罩長度；為空或 `false` 時遮罩至字串結尾，為 `0` 時不遮罩。
- `inSign`: [String = "*"] - 替代符號。

### 輸出

- `return`: [String|Any] - 指定區段被替代後的結果；空值或起始位置超界時照原值回傳。

### 對外功能

- 保留起始位置前的內容，以指定符號取代固定長度或直到字串結尾的內容，再保留遮罩區段後的尾碼。

### 副作用

- 無

---

## **`CSRUtil.keepParamsManager.setPageValue(formId, setKeys)`**

### 用途

- 將跨畫面保留參數套用到同名畫面欄位；欄位不存在時以隱藏欄位補入表單。

### 輸入

- `formId`: [String|HTMLFormElement] - 必要時用來附加隱藏欄位的表單。
- `setKeys`: [String|Array<String> = undefined] - 要寫入的參數鍵；未指定時處理全部保留參數。

### 輸出

- 無

### 對外功能

- 字串鍵只處理該鍵；陣列逐項處理；未指定時先逐項處理全部鍵，但因原始 `if` 結構仍會再以未定義鍵執行一次。

### 副作用

- 會改寫現有畫面欄位，或在表單中建立隱藏欄位。
- `setKeys` 未指定時，原始條件分支在全量處理後還會再嘗試處理一個未定義鍵，因而可能額外建立無有效名稱的隱藏欄位。

---

## **`CSRUtil.keepParamsManager.getAll()`**

### 用途

- 從共用視窗或會話儲存區取得完整保留參數集合。

### 輸入

- 無

### 輸出

- `return`: [Object|undefined] - 全部跨畫面保留參數；未初始化時為未定義。

### 對外功能

- 從共用視窗或會話儲存區取得完整保留參數集合。

### 副作用

- 無

---

## **`CSRUtil.keepParamsManager.initial(inParams)`**

### 用途

- 以指定參數集合初始化或取代跨畫面保留狀態。

### 輸入

- `inParams`: [Object] - 要作為完整保留狀態的參數集合。

### 輸出

- 無

### 對外功能

- 共用視窗模式直接保存同一物件參照；會話儲存模式先以 `JSON.stringify` 轉成文字後保存，後續讀取時產生新的物件。

### 副作用

- 會寫入共用視窗或會話儲存區。

---

## **`CSRUtil.keepParamsManager.clear()`**

### 用途

- 清除全部跨畫面保留參數。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 清除全部跨畫面保留參數。

### 副作用

- 會移除共用視窗或會話儲存區內的對應資料。

---

## **`CSRUtil.clearLP_JSON()`**

### 用途

- 清除所有跨畫面導航紀錄。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 清除所有跨畫面導航紀錄。

### 副作用

- 會同時嘗試清除共用視窗與會話儲存區的紀錄；無法存取時可能記錄診斷訊息。

---

## **`CSRUtil.UICore.isOnTheSys(sysId)`**

### 用途

- 依當前畫面位置的系統路徑，判定功能是否運行於指定子系統。

### 輸入

- `sysId`: [String|Array<String>] - 要比對的子系統識別模式；陣列時任一項符合即成立。

### 輸出

- `return`: [Boolean] - 當前畫面位置符合指定子系統模式時為 `true`。

### 對外功能

- 將每個 `sysId` 不經跳脫直接組成正規表示式 `/{sysId}Web*`，對完整 `window.location` 執行比對；因此 `.`、`*` 等字元保留正規表示式語意。陣列任一模式符合即停止並回傳 `true`。

### 副作用

- 無

## 代碼對照表

### 共通業務回應 `ErrMsg`

| 欄位 | 用途 |
| --- | --- |
| `returnCode` | 業務結果碼；`0` 代表成功，其他值代表非成功。 |
| `displayMsgDescs` | 顯示訊息文字；請求處理器以字面 `\\n` 分割後呈現。 |
| `msgid` | 訊息或錯誤識別值；部分子系統在長度大於 17 時一併顯示。 |

### 導航紀錄 `LP_JSON`

| 欄位 | 用途 |
| --- | --- |
| `action` | `linkTo` 要前往的位置。 |
| `RQ_SENDER` | 建立紀錄時的來源路徑，也是 `linkBack` 的返回位置。 |
| `BQ_ARG` | 返回來源頁時要復原或選擇性送出的查詢條件。 |
| 其他欄位 | 隨完整導航紀錄保存，不會由 `linkTo` 個別展開成送出欄位。 |

### 數值與按鍵代碼

| 代碼 | 用途 |
| --- | --- |
| `#,###.####` | `CSRUtil.defaultPattern`；逗號表示每三位整數分組，四個 `#` 表示最多保留四位小數。 |
| `8` | 退格鍵。 |
| `45` | 負號字元。 |
| `46` | 小數點字元；在按鍵事件情境也可能代表 Delete，函數不區分事件種類。 |
| `48`–`57` | 主鍵盤數字 `0`–`9`。 |

### 地址與姓名遮罩符號

| 契約 | 預設符號 |
| --- | --- |
| `getMaskStr`、`getMaskID` | 半形星號 `*`。 |
| `getMaskName`、`getMaskAddress`、`getMaskAddress2` | 全形星號 `＊`。 |
