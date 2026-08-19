# TableUI.js 公開契約

## 使用語法清單
**變數**:
- [SORT_NONE](#SORT_NONE)
- [SORT_INCREASE](#SORT_INCREASE)

**方法**:
- [divResize(isResize)](#divResize(isResize))
- [getValueByElement(elem,-valueTemplate)](#getValueByElement(elem,-valueTemplate))
- [setValidRecord(node,-dataObjs,-validResult,-msg)](#setValidRecord(node,-dataObjs,-validResult,-msg))
- [getValidRecord(node)](#getValidRecord(node))
- [getCellByTagName(node,-tagName,-allowFragment)](#getCellByTagName(node,-tagName,-allowFragment))
- [TableUI](#TableUI)
    - [constructor(config)](#constructor(config))
    - [isNew](#isNew)
    - [pageCtrl](#pageCtrl)
    - [pageCtrl.loadPage(pageNO)](#pageCtrl.loadPage(pageNO))
    - [load(records,-totalRecords,-subTotalRecords,-preCheckedValues)](#load(records,-totalRecords,-subTotalRecords,-preCheckedValues))
    - [load(ajaxUrl,-params,-successFunc,-failFunc)](#load(ajaxUrl,-params,-successFunc,-failFunc))
    - [reload(preCheckedValues)](#reload(preCheckedValues))
    - [clear()](#clear())
    - [getTableInfo(setPage,-setSort)](#getTableInfo(setPage,-setSort))
    - [setTableInfo(info)](#setTableInfo(info))
    - [sort(key,-isIncrease,-sortRule)](#sort(key,-isIncrease,-sortRule))
    - [getRecordsBySerialNo(serialNo,-recordTemplate)](#getRecordsBySerialNo(serialNo,-recordTemplate))
    - [getDataObj(td)](#getDataObj(td))
    - [hasRecords()](#hasRecords())
    - [getAllRecords(template)](#getAllRecords(template))
    - [getCheckedRecord()](#getCheckedRecord())
    - [getCheckedRecords(template,-includeDisabled)](#getCheckedRecords(template,-includeDisabled))
    - [getCheckedErrorRecords(template,-includeDisabled)](#getCheckedErrorRecords(template,-includeDisabled))
    - [addRecords(records,-autoCheckStatus)](#addRecords(records,-autoCheckStatus))
    - [deleteRecords(records)](#deleteRecords(records))
    - [validTable()](#validTable())
    - [validCheckedOnTable(includeDisabled)](#validCheckedOnTable(includeDisabled))
    - [checkAll(isChecked)](#checkAll(isChecked))
    - [isAutoCheckBoxSelected(td)](#isAutoCheckBoxSelected(td))
    - [setThisAutoCheckBox(td,-checkStatus)](#setThisAutoCheckBox(td,-checkStatus))
    - [setAnotherCheckBox(findValue,-checkStatus)](#setAnotherCheckBox(findValue,-checkStatus))
    - [getThisRecordTD(tr,-template)](#getThisRecordTD(tr,-template))
    - [setValueToTD(tr,-key,-value)](#setValueToTD(tr,-key,-value))
    - [getAutoInput(tr,-template)](#getAutoInput(tr,-template))
    - [exchangeAutoInput(tr,-template,-isCloseInput)](#exchangeAutoInput(tr,-template,-isCloseInput))
    - [setValueToAutoInput(tr,-key,-value)](#setValueToAutoInput(tr,-key,-value))
    - [getXlsSettingJSON(sheetName)](#getXlsSettingJSON(sheetName))
    - [resetDivHeight()](#resetDivHeight())
    - [hide()](#hide())
    - [show()](#show())

---

## 共用模式

**資料列物件（Record）**: `TableUI` 內部以物件陣列表示表格資料，每個物件之屬性對應「欄位定義物件」之 key。載入資料時（`load()`／`addRecords()`），系統會自動於每筆物件加入下列內部欄位，並會反映於後續各方法回傳之資料物件中：
- _tableuiSerialNumber: 數字 - 該筆資料於目前已載入資料集中之序號（自 1 起算）

**記錄篩選 template 參數**（`getAllRecords()`、`getCheckedRecords()`、`getCheckedErrorRecords()` 之 template 參數，以及 `getRecordsBySerialNo()` 之 recordTemplate 參數共用）：
- 省略、null 或 false：回傳完整之資料列物件
- 文字：回傳指定 key 之欄位值所組成的陣列（每筆資料僅取該欄位值）
- 陣列(文字)：回傳僅包含所列 key 之新物件陣列（欄位投影，未列出之欄位不會出現於回傳物件中）

**欄位定義物件**: `TableUI` 建構時 `config.column`（或 `config.headerColumn`）二維陣列中每個元素之通用結構，其部份屬性亦會反映於 `getXlsSettingJSON()` 輸出結果之對應欄位設定中：
- key: 文字 - 對應資料列物件之欄位名稱
- header: 文字、元素參照或函式 - 標頭儲存格顯示內容
- sortable: 布林值 - **可選**，該欄位是否可排序；未設定時依 config.allSortable 決定，**僅於非批次載入模式生效**
- sortRule: 文字("string" | "number" | "date" | "rocdate") = "string" - **可選**，排序／匯出時所採用之資料型別規則
- render / format: 函式(record, value, serialNo) - **可選**，自訂儲存格顯示內容之算繪函式
- input: 物件 - **可選**，設定後該儲存格改以可編輯欄位（autoInput）方式呈現，主要子屬性：type(文字，如 text/number/date/rocdate/select/checkbox/radio)、attrs(物件)、pattern(文字)、maxlength／size(數字)、opts(陣列，下拉選單/選項清單)、optionKey／optionValue(文字或函式)
- staticWidth: 數字 - **可選**，鎖定欄位為固定像素寬度
- fixedColumn: 布林值 - **可選**，是否可被固定於捲動區域左側（需 config.overDiv 未設為 false）
- hiddenColumn: 布林值 - **可選**，是否允許使用者將該欄位隱藏
- groupKey: 陣列或數字 - **可選**，同一群組值相鄰時合併儲存格顯示（rowSpan）
- whenDataNull: 文字 - **可選**，該欄位資料為 null／undefined 時之預設顯示內容
- defaultValue: 基本型別或函式 - **可選**，新增資料未提供該欄位值時之預設值
- attrs / classes / styles: 物件、陣列、物件 - **可選**，輸出儲存格之屬性、CSS class、行內樣式

---

## divResize(isResize)
**使用範例**: `divResize(true);`
**輸入**:
- isResize: 任意 - **可選**，目前實作不使用此參數
**輸出**: 無
**功能**:
- 保留供舊版頁面相容呼叫之空函式，呼叫後不執行任何動作

---

## getValueByElement(elem, valueTemplate)
**使用範例**: `var record = getValueByElement(elm);`
**輸入**:
- elem: 元素參照 - 表格內任一節點（通常為儲存格內之核取方塊、選項按鈕或其他子元素）
- valueTemplate: 任意 - **可選**，**目前實作不影響回傳內容**
**輸出**:
- **當 elem 位於 `TableUI` 元件內時**: 結果: 陣列(資料列物件) - 該節點所屬資料列的完整資料物件陣列，見「資料列物件」
- **當 elem 不在任何 `TableUI` 元件內時**: 結果: 陣列 = `[]` - 空陣列
**功能**:
- 依傳入節點往上尋找其所屬之 `TableUI` 執行個體，並取得該節點對應資料列之資料物件

---

## setValidRecord(node, dataObjs, validResult, msg)
**使用範例**: `var result = setValidRecord(elem , dataObjs , false );`
**輸入**:
- node: 元素參照 - 表格內任一節點，用以定位所屬之 `TableUI` 執行個體
- dataObjs: 資料列物件或其陣列 - 欲設定檢核狀態之資料物件（可傳入單一物件或物件陣列）
- validResult: 布林值 = true - 欲設定之檢核結果（true 表示檢核通過）
- msg: 文字 - **可選**，目前實作未使用此參數
**輸出**:
- **當找不到所屬 `TableUI` 執行個體時**: 結果: false - 否
- **當找到所屬 `TableUI` 執行個體時**: 結果: 布林值 - 設定後經 true／false 正規化的 validResult 值
**功能**:
- 依傳入節點定位所屬 `TableUI` 執行個體，將 dataObjs 逐筆設定 `_tableuiValidateStatus` 檢核狀態欄位

---

## getValidRecord(node)
**使用範例**: `var valid = getValidRecord(tr);`
**輸入**:
- node: 元素參照 - 表格內任一節點，用以定位所屬之 `TableUI` 執行個體與所屬資料列
**輸出**:
- **當找不到所屬 `TableUI` 執行個體，或該節點所屬資料列目前無檢核錯誤時**: 結果: false - 否
- **當該節點所屬資料列具有檢核錯誤時**: 結果: 陣列(資料列物件) - 檢核狀態為錯誤（`_tableuiValidateStatus === false`）的資料物件陣列
**功能**:
- 依傳入節點定位所屬 `TableUI` 執行個體，取得該節點所屬資料列中目前檢核失敗之資料物件

---

## getCellByTagName(node, tagName, allowFragment)
**使用範例**: `var td = getCellByTagName(node,"TD");`
**輸入**:
- node: 元素參照 - 起始節點
- tagName: 文字 - 欲往上尋找之標籤名稱（不分大小寫）
- allowFragment: 布林值 - **可選**，是否允許節點型別為文件片段
**輸出**:
- 結果: 元素參照或 null - 由 node 起沿父節點往上尋找，第一個標籤名稱符合 tagName 之節點；找不到（含遇到 BODY 節點仍未符合）時回傳 null
**功能**:
- 由指定節點向上尋找最接近之指定標籤祖先節點

---

## TableUI
表格元件建構子，透過 `new TableUI(config)` 將指定表格節點轉換為具備分頁（或批次載入）、排序、群組小計/合計、資料勾選、資料檢核、Excel 匯出等能力之表格元件執行個體。

### constructor(config)
**使用範例**:
```
grid = new TableUI({
    table: $('grid'), pageSize: 10, allSortable: false,
    afterLoad: function() {
        if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    },
    pageChange: function() {
        if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    },
    column:grigColumn
});
```
**輸入**:
- config: 物件 - 表格元件設定物件，主要屬性如下：
    - table: 元素參照或文字(識別代號)（必填） - 欲轉換為表格元件之目標 table 節點，或其識別代號
    - column: 陣列(欄位定義物件) 或 陣列(陣列(欄位定義物件))（必填） - 欄位定義清單，決定每筆資料列之呈現方式，見「欄位定義物件」
    - headerColumn: 陣列(欄位定義物件) - **可選**，另行指定標頭欄位定義；省略時沿用 column 之定義
    - split: 陣列(文字) - **可選**，當 column 為未分行之物件陣列時，依此陣列所列之 key 進行斷行分組
    - pageSize: 數字 = 10 - **可選**，每頁顯示筆數；設為 0 或負數時停用分頁，改為單頁顯示全部資料
    - isLoadByFatch: 布林值或數字 = false - **可選**，設為 true 或數字時啟用批次載入模式，改由呼叫端提供查詢位址與參數載入資料（見 `load(ajaxUrl, params, ...)`）；為數字時代表每批最多查詢筆數（上限 200，未達 pageSize 之 5 倍時以 pageSize*5 計算）
    - allSortable: 布林值 = true - **可選**，未於欄位定義個別指定 sortable 時之預設可排序狀態，**僅於非批次載入模式生效**
    - overDiv: 布林值或物件 = true - **可選**，是否讓資料內容區域可獨立捲動並支援固定欄位；為物件時可設定 { maxHeight, minHeight } 控制可視高度；設為 false 時不產生固定欄位，改依內容自動延伸高度
    - fixedColumns / hiddenColumns: 陣列(數字) - **可選**，初始已固定／已隱藏之欄位群組編號（欄位群組編號由系統依欄位定義順序自動編定）
    - needHeader: 布林值 = true - **可選**，是否產生標頭列
    - title: 文字或物件 - **可選**，表格上方標題列內容；為物件時可設定 {text, className, styles, attrs}
    - autoCheckBox: 物件 - **可選**，設定後於資料列插入核取方塊（或選項按鈕）欄位；主要子屬性：valueKey(文字，對應勾選值欄位)、type(文字，預設核取方塊、設為 "RADIO" 改為單選)、text(文字，標頭顯示文字)、isSelectAll(布林值或函式，是否顯示全選)、insertPosition(數字，插入欄位位置)、returnValue(文字或陣列，搭配 getCheckedRecords 之預設 template)、displayRule(布林值或函式，控制個別列是否顯示)
    - printMode: 布林值 = false - **可選**，設為 true 時進入列印模式，強制停用批次載入與分頁
    - recordInfoPattern: 文字 - **可選**，分頁資訊顯示樣板，可用 {nowPage}、{totalPage}、{totalRecord}、{totalGroup} 佔位字串
    - pageInfo: 布林值 - **可選**，是否顯示分頁資訊文字；未設定時依是否啟用分頁而定
    - beforeLoad / afterLoad: 函式(mainElement, tableId, instance) - **可選**，資料載入前／完成後呼叫之回呼函式
    - beforePageChange: 函式(nowPage, targetPage, totalPage, mainElement, tableId, instance) - **可選**，換頁前呼叫之回呼函式；回傳 false 可中止本次換頁
    - pageChange: 函式(nowPage, totalPage, mainElement, tableId, instance) - **可選**，換頁或批次資料更新完成後呼叫之回呼函式
    - rowClick: 函式(trElement, record, serialNo) - **可選**，點擊資料列儲存格時呼叫之回呼函式
    - validateRecord: 布林值或函式(record, serialNo) - **可選**，資料列檢核規則，設定後可搭配 `validTable()` / `validCheckedOnTable()` 使用
    - validateRecordCheckedOnly: 布林值 = false - **可選**，是否僅需已勾選之資料列通過檢核
    - whenDataNull: 文字 = "　" - **可選**，欄位資料為 null 時之預設顯示內容（可被欄位定義個別覆寫）
    - setRecordBackground: 函式(records) - **可選**，回傳整批資料列（依畫面區塊為單位）之背景色
    - setRecordClass: 函式(records) - **可選**，回傳整批資料列（依畫面區塊為單位）之 CSS class 名稱
**輸出**:
- 執行個體: TableUI - 表格元件控制物件，提供 `load()`、`getAllRecords()`、`getXlsSettingJSON()` 等方法
**當 config 非物件、或依 config.table 找不到有效 table 節點時**:
- 顯示錯誤提示並中止建立

**當 config.printMode 為 true 且同時設定 isLoadByFatch 時**:
- 顯示提示訊息並強制改回一般（非批次）模式
**功能**:
- 依欄位定義清單解析並產生表格標頭、資料顯示區塊，取代原始 table 節點
- 依 pageSize 及 isLoadByFatch 設定，決定採一般分頁模式（資料整批載入後於前端分頁）或批次載入模式（換頁時向伺服器查詢）
- 依 config.autoCheckBox 設定於指定位置插入核取方塊／選項按鈕欄位
- 建立完成後之執行個體提供本文件所列各方法供後續操作

---

### isNew
**使用範例**: `if(grid.isNew){`
**輸入**: 無
**輸出**:
- 值: 布林值 = true - 固定為 true，標示此物件為 `TableUI` 執行個體
**功能**:
- 供呼叫端判斷該物件是否為有效之 `TableUI` 執行個體

---

### pageCtrl
**使用範例**: `grid0.pageCtrl.loadPage(page);`
**輸入**: 無
**輸出**:
- 值: 物件 - 內部分頁控制物件，可透過其上之方法（如 loadPage()）操作分頁狀態
**功能**:
- 對外提供內部分頁控制物件之參照，供進一步呼叫其分頁相關方法

---

### pageCtrl.loadPage(pageNO)
**使用範例**: `grid0.pageCtrl.loadPage(page);`
**輸入**:
- pageNO: 數字 - 欲切換至之頁碼（自 1 起算）
**輸出**: 無
**功能**:
- 切換表格顯示內容至指定頁碼；pageNO 小於 1 時切換至第一頁，超過總頁數時切換至最後一頁

---

### load(records, totalRecords, subTotalRecords, preCheckedValues)
**使用範例**: `grid.load(rtnList,null,null,[record.DATA_STR_DATE]);`
**輸入**:
- records: 資料列物件或其陣列 - **可選**，欲顯示之資料，省略或傳入空陣列時清空目前顯示內容
- totalRecords: 物件或物件陣列 - **可選**，合計列資料；可為單一物件（其 value 屬性為合計資料物件）或前述物件之陣列
- subTotalRecords: 陣列 - **可選**，各群組小計資料，元素為物件 {key, value}；**僅於欄位定義具備群組(groupKey)設定時套用**
- preCheckedValues: 陣列 - **可選**，需搭配 config.autoCheckBox.valueKey 設定；資料列之 valueKey 欄位值存在於此陣列中者，載入後預設為已勾選狀態
**輸出**: 無
**當表格元件建構時未設定 config.isLoadByFatch（一般模式）時**:
- 本方法適用
**功能**:
- 清空目前顯示內容後，載入並顯示傳入之資料列（含分組、排序狀態重置、資料檢核狀態重新套用），並依 pageSize 分頁

---

### load(ajaxUrl, params, successFunc, failFunc)
**使用範例**: `grid.load( "<%=dispatcher%>/DSA3_0100/query", params);`
**輸入**:
- ajaxUrl: 文字 - 查詢資料之服務位址
- params: 物件 - 查詢條件參數；未提供或非物件時僅清空目前顯示資料，不送出查詢
- successFunc: 函式(response) - **可選**，首次查詢成功時呼叫之回呼函式
- failFunc: 函式(response) - **可選**，首次查詢失敗時呼叫之回呼函式
**輸出**: 無
**當表格元件建構時 config.isLoadByFatch 為 true 或數字（批次載入模式）時**:
- 本方法適用
**功能**:
- 以背景查詢方式（POST）向指定服務位址送出查詢條件，取得後端分批回應資料並顯示第一批；換頁時依需要自動查詢後續批次資料

---

### reload(preCheckedValues)
**使用範例**: `grid.reload();`
**輸入**:
- preCheckedValues: 陣列 - **可選**，需搭配 config.autoCheckBox.valueKey 設定，用以重新指定各列勾選狀態
**輸出**: 無
**功能**:
- **當處於一般模式時**: 依目前已載入資料重新整理顯示內容，不重新查詢後端；如有提供 preCheckedValues，依其內容重設各列勾選狀態
- 批次載入模式：忽略 preCheckedValues 參數，改為對目前頁碼重新發送查詢請求

---

### clear()
**使用範例**: `grid.clear();`
**輸入**: 無
**輸出**: 無
**功能**:
- 清除目前所有已載入資料，並重設表格為初始（無資料）狀態，含分頁控制項、合計/小計區塊與勾選狀態

---

### getTableInfo(setPage, setSort)
**使用範例**: `LP_JSON.TABLE_INFO = grid.getTableInfo();`
**輸入**:
- setPage: 布林值 = true - **可選**，是否於回傳結果中包含目前頁碼資訊
- setSort: 布林值 = true - **可選**，是否於回傳結果中包含目前排序狀態（**僅於一般模式生效**）
**輸出**:
- 結果: 物件 - 表格目前操作狀態快照，包含固定/隱藏欄位設定，及依模式而定之分頁資訊：一般模式為 { pageNo }，批次載入模式為 { thisAjaxRecordFrom, queryUrl, queryRules }；一般模式下另包含 sortRecords（排序規則陣列）
**功能**:
- 擷取表格目前之分頁位置、欄位固定/隱藏設定與排序狀態，供後續以 `setTableInfo()` 還原

---

### setTableInfo(info)
**使用範例**: `grid.setTableInfo(tableInfo);`
**輸入**:
- info: 物件 - 由 `getTableInfo()` 取得之狀態快照物件
**輸出**: 無
**功能**:
- 還原欄位固定／隱藏設定
- **當處於一般模式時**: 依 info.sortRecords 重新套用排序
- **當處於批次載入模式，且 info 包含有效 queryUrl／queryRules 時**: 依該查詢條件重新發送查詢
- 依 info 內容還原分頁位置（一般模式切換至指定頁碼；批次載入模式自指定筆數位置重新查詢）

---

### sort(key, isIncrease, sortRule)
**使用範例**: `grid.sort( 'SEQ_NO', SORT_INCREASE , "number", null , false );`
**輸入**:
- key: 文字 - 欲排序之欄位 key
- isIncrease: 布林值或排序方向常數 - true 為遞增排序、false 為遞減排序；傳入非 true/false 之值（如 SORT_NONE、SORT_INCREASE）時，除特定內部遞減標記值外一律視為遞增排序
- sortRule: 文字("string" | "number" | "date" | "rocdate") = "string" - **可選**，排序時採用之資料型別規則
**輸出**: 無
**功能**:
- 依指定欄位與規則對目前已載入之全部資料排序，並更新顯示內容與標頭排序圖示
- 呼叫時可額外傳入其他參數（如上方範例之第 4、5 個參數），惟目前實作僅使用前 3 個參數

---

### getRecordsBySerialNo(serialNo, recordTemplate)
**使用範例**: `grid.getRecordsBySerialNo(tr.getAttribute("sn"));`
**輸入**:
- serialNo: 數字、文字（可為逗號分隔多值）或其陣列 - 欲取得資料列之序號（對應 `_tableuiSerialNumber`）
- recordTemplate: 文字或陣列(文字) - **可選**，見「記錄篩選 template 參數」
**輸出**:
- 結果: 陣列(資料列物件) - 對應序號之資料列物件（依 recordTemplate 篩選）；serialNo 為空或找不到對應資料時回傳空陣列
**功能**:
- 依序號取得對應之資料列物件

---

### getDataObj(td)
**使用範例**: `grid.getDataObj(node);`
**輸入**:
- td: 元素參照 - 資料列內任一節點（儲存格或其子節點）
**輸出**:
- 結果: 資料列物件或 null - 該節點所屬資料列之第一筆資料物件（固定回傳完整資料物件）；找不到時回傳 null
**功能**:
- 依傳入節點定位所屬資料列，取得該列之資料物件

---

### hasRecords()
**使用範例**: `grid.hasRecords();`
**輸入**: 無
**輸出**:
- 結果: 布林值 - 目前是否已載入至少一筆資料
**功能**:
- 判斷表格目前是否有已載入之資料

---

### getAllRecords(template)
**使用範例**: `grid.getAllRecords();`
**輸入**:
- template: 文字或陣列(文字) - **可選**，見「記錄篩選 template 參數」
**輸出**:
- 結果: 陣列(資料列物件) - 目前已載入之全部資料（不限頁碼），依 template 篩選；無資料時回傳空陣列
**功能**:
- 取得目前已載入之全部資料列

---

### getCheckedRecord()
**使用範例**: `grid.getCheckedRecord();`
**輸入**: 無
**輸出**:
- 結果: 陣列(資料列物件) - 目前已勾選之資料列
- **當已設定 config.autoCheckBox.returnValue 時**: 依該設定進行預設欄位篩選
**當建構時 config.isLoadByFatch 為 true 或數字（批次載入模式）時**:
- 固定回傳空陣列
**功能**:
- 取得目前已勾選之資料列（等同 `getCheckedRecords()`，為其別名）

---

### getCheckedRecords(template, includeDisabled)
**使用範例**: `grid1.getCheckedRecords(['LOAN_ID']);`
**輸入**:
- template: 文字或陣列(文字) - **可選**，見「記錄篩選 template 參數」；未提供且 config.autoCheckBox.returnValue 有設定時，改採該設定值
- includeDisabled: 布林值 = false - **可選**，是否將已停用但標記為勾選狀態之資料列一併納入
**輸出**:
- 結果: 陣列(資料列物件) - 已勾選之資料列，依 template 篩選
**當建構時 config.isLoadByFatch 為 true 或數字（批次載入模式）時**:
- 固定回傳空陣列
**功能**:
- 取得目前已勾選之資料列

---

### getCheckedErrorRecords(template, includeDisabled)
**使用範例**: `gridC.getCheckedErrorRecords(['STATUS', 'PHONE', 'DUE_DATE', 'CALL_DATE']);`
**輸入**:
- template: 文字或陣列(文字) - **可選**，見「記錄篩選 template 參數」
- includeDisabled: 布林值 = false - **可選**，是否將已停用但標記為勾選狀態之資料列一併納入
**輸出**:
- 結果: 陣列(資料列物件) - 同時符合「已勾選」且「檢核未通過」之資料列，依 template 篩選
**當建構時 config.isLoadByFatch 為 true 或數字（批次載入模式）時**:
- 固定回傳空陣列

**當尚未執行過 `validTable()` 或 `validCheckedOnTable()`（或未設定 config.validateRecord）時**:
- 各列尚不具備檢核結果，本方法之回傳結果不具意義
**功能**:
- 取得已勾選且檢核未通過之資料列

---

### addRecords(records, autoCheckStatus)
**使用範例**: `grid.addRecords( addRows );`
**輸入**:
- records: 資料列物件或其陣列 - 欲新增之資料
- autoCheckStatus: 布林值 - **可選**，為 true 且已設定 config.autoCheckBox 時，新增之資料列預設為已勾選狀態
**輸出**: 無
**當欄位定義具備群組(groupKey)設定時**:
- 不執行新增（直接返回，不影響現有資料）
**功能**:
- 將傳入之資料列附加於目前已載入資料之後，並重新計算分頁後顯示

---

### deleteRecords(records)
**使用範例**: `gridB.deleteRecords(record);`
**輸入**:
- records: 資料列物件或其陣列 - 欲刪除之資料（須為本元件先前回傳之資料物件參照，以物件參照比對）
**輸出**: 無
**功能**:
- 將符合傳入物件參照之資料列自目前顯示內容中移除；移除後之資料列另存於內部「已刪除清單」中
- **當移除後已無任何資料時**: 將表格重置為與 `clear()` 相同的顯示狀態，但保留已刪除清單

---

### validTable()
**使用範例**: `grid1.validTable();`
**輸入**: 無
**輸出**:
- 結果: 數字或 undefined - 目前檢核未通過之資料列筆數
**當建構時 config.isLoadByFatch 為 true 或數字（批次載入模式）時**:
- 本方法為空操作，不執行任何檢核，回傳 undefined
**功能**:
- **當已設定 config.validateRecord 時**: 依該規則重新檢核全部已載入資料列，並更新各列的錯誤樣式
- **當未設定 config.validateRecord 時**: 將全部資料列視為通過檢核

---

### validCheckedOnTable(includeDisabled)
**使用範例**: `grid.validCheckedOnTable();`
**輸入**:
- includeDisabled: 布林值 = false - **可選**，統計時是否將已停用但標記為勾選狀態之資料列一併納入
**輸出**:
- 結果: 數字或 undefined - 已勾選資料列中，檢核未通過之筆數
**當建構時 config.isLoadByFatch 為 true 或數字（批次載入模式）時**:
- 本方法為空操作，不執行任何檢核，回傳 undefined
**功能**:
- 依 config.validateRecord 規則重新檢核全部已載入資料列，僅統計並標示「已勾選」資料列中檢核未通過者

---

### checkAll(isChecked)
**使用範例**: `gridB.checkAll(true);`
**輸入**:
- isChecked: 布林值 - **可選**，true 為全選、false 為全部取消；省略時依目前「全選」控制項之勾選狀態決定
**輸出**: 無
**功能**:
- 將目前已載入資料中，可勾選狀態之資料列（不含已停用或不產生勾選欄位者）全部設定為選取或取消選取

---

### isAutoCheckBoxSelected(td)
**使用範例**: `grid.isAutoCheckBoxSelected(thechk);`
**輸入**:
- td: 元素參照 - 資料列內任一節點
**輸出**:
- 結果: 布林值 - 該節點所屬資料列目前是否為已勾選（含已停用但勾選）狀態；找不到對應資料列時回傳 false
**功能**:
- 判斷指定資料列目前之勾選狀態

---

### setThisAutoCheckBox(td, checkStatus)
**使用範例**: `grid.setThisAutoCheckBox(input, true);`
**輸入**:
- td: 元素參照 - 資料列內任一節點，用以定位該列之勾選欄位
- checkStatus: 布林值 - 欲設定之勾選狀態
**輸出**: 無
**功能**:
- 設定指定資料列之勾選欄位為指定狀態（與使用者手動點擊該勾選欄位效果相同，會連動觸發資料勾選狀態更新）

---

### setAnotherCheckBox(findValue, checkStatus)
**使用範例**: `grid.setAnotherCheckBox(node.value, node.checked);`
**輸入**:
- findValue: 文字 - 欲比對之 config.autoCheckBox.valueKey 欄位值
- checkStatus: 布林值 - 欲設定之勾選狀態
**輸出**: 無
**當未設定 config.autoCheckBox.valueKey 時**:
- 不執行任何動作
**功能**:
- 於目前已顯示之勾選欄位中，尋找 valueKey 欄位值等於 findValue 之資料列，並設定其勾選狀態（效果同使用者手動點擊）

---

### getThisRecordTD(tr, template)
**使用範例**: `grid.getThisRecordTD(node,['EXTRACT_DATE','DEDUCT_DATE']);`
**輸入**:
- tr: 元素參照 - 資料列內任一節點（可為單列節點，或群組合併儲存格所對應之多筆資料節點）
- template: 文字或陣列(文字) - **可選**，欲取得之欄位 key 清單；省略時取得該列所有具名稱之儲存格
**輸出**:
- 結果: 陣列(物件) - 每筆對應一列資料，物件內容為 { 欄位key: 對應儲存格元素（同名有多個時為陣列） }
**功能**:
- 依傳入節點定位所屬資料列，取得該列（或該群組合併儲存格所涵蓋之多列）中指定欄位之儲存格元素

---

### setValueToTD(tr, key, value)
**使用範例**: `grid.setValueToTD( checkbox , 'DEDUCT_DATE' , dataObj.initDEDUCT_DATE );`
**輸入**:
- tr: 元素參照 - 資料列內任一節點
- key: 文字 - 欲設定之欄位 key
- value: 任意 - 欲設定之新值
**輸出**: 無
**功能**:
- 更新該資料列對應之資料物件中 key 欄位之值，並依欄位定義之顯示規則（render/format）重新算繪對應儲存格內容

---

### getAutoInput(tr, template)
**使用範例**: `grid.getAutoInput(checkbox,['BANK','PAID_TIMES']);`
**輸入**:
- tr: 元素參照 - 資料列內任一節點
- template: 文字或陣列(文字) - **可選**，欲取得之欄位 key 清單；省略時取得該列所有可編輯（autoInput）欄位
**輸出**:
- 結果: 陣列(物件) - 每筆對應一列資料，物件內容為 { 欄位key: 對應可編輯欄位控制項元素（同名有多個時為陣列） }
**功能**:
- 依傳入節點定位所屬資料列，取得該列中指定欄位之可編輯欄位（autoInput）控制項元素

---

### exchangeAutoInput(tr, template, isCloseInput)
**使用範例**: `grid1.exchangeAutoInput( node, ['PAID_RATIO_GOAL'] );`
**輸入**:
- tr: 元素參照 - 資料列內任一節點
- template: 文字或陣列(文字) - **可選**，欲切換之欄位 key 清單；省略時切換該列所有可編輯欄位
- isCloseInput: 布林值 - **可選**，true 強制顯示為文字（關閉輸入）、false 強制顯示為輸入控制項；省略時依目前狀態切換
**輸出**: 無
**功能**:
- 切換指定欄位在「文字顯示」與「輸入控制項」兩種呈現方式之間的顯示狀態，並重新計算表格版面尺寸

---

### setValueToAutoInput(tr, key, value)
**使用範例**: `gridD.setValueToAutoInput(this,'ADDR', addr);`
**輸入**:
- tr: 元素參照 - 資料列內任一節點
- key: 文字 - 欲設定之欄位 key
- value: 任意 - 欲設定之新值
**輸出**: 無
**功能**:
- **當該列具有對應的可編輯欄位控制項時**: 更新指定欄位的可編輯欄位（autoInput）控制項顯示值
- **當該列無對應的可編輯欄位控制項時**: 呼叫 `setValueToTD()` 更新一般儲存格
- 對核取方塊／選項按鈕型控制項，value 為 true/'Y' 時勾選、false/'N' 時取消勾選，其餘值則依同名選項之 value 屬性比對後設定勾選狀態，並觸發對應變更事件

---

### getXlsSettingJSON(sheetName)
**使用範例**: `grid.getXlsSettingJSON(titleName);`
**輸入**:
- sheetName: 文字 - 匯出資料之工作表名稱
**輸出**:
- 結果: 文字(JSON字串) - 內容包含 sheetName（工作表名稱）、titleSetting（標頭欄位設定）、recordSetting（資料欄位設定）、groupKeys（群組索引鍵清單），供匯出 Excel/XLS 服務使用
**功能**:
- 將目前表格之標頭與資料欄位設定（含 header、key、sortRule、groupKey、attrs 等，見「欄位定義物件」）序列化為 JSON 字串，供匯出作業使用

---

### resetDivHeight()
**使用範例**: `grid.resetDivHeight();`
**輸入**: 無
**輸出**: 無
**功能**:
- 依目前內容大小與版面限制（config.overDiv 設定）重新計算並套用表格內容區域之寬高，同步固定欄位區域捲動位置並重新定位懸浮標頭

---

### hide()
**使用範例**: `grid.hide();`
**輸入**: 無
**輸出**: 無
**功能**:
- 隱藏整個表格元件（不影響已載入之資料）

---

### show()
**使用範例**: `grid.show();`
**輸入**: 無
**輸出**: 無
**功能**:
- 顯示整個表格元件，並重新計算版面尺寸
