# TableUI_Beta.js 公開契約

## 使用語法清單
**方法**:
- [TableUI](#TableUI)
    - [constructor(config)](#constructor(config))
    - [load(records)](#load(records))
    - [load(records,-totalRecords,-subTotalRecords)](#load(records,-totalRecords,-subTotalRecords))
    - [load(ajaxUrl,-params)](#load(ajaxUrl,-params))
    - [getXlsSettingJSON(sheetName)](#getXlsSettingJSON(sheetName))

---

## 共用模式
**欄位定義物件**: `TableUI` 建構時 `config.column` 陣列中每個元素之通用結構，其 `header`、`key`、`sortRule`、`attrs` 亦會反映於 `getXlsSettingJSON()` 輸出結果之對應欄位設定中：
- header: 文字 - 欄位標題顯示內容
- key: 文字 - 對應資料物件之欄位名稱
- render: 函式(record, value, serialNo, key) - **可選**，自訂儲存格顯示內容之算繪函式；record 為該筆資料物件、value 為對應欄位原始值、serialNo 為該筆資料於目前頁面之序號、key 為欄位名稱；回傳值作為儲存格顯示內容
- sortRule: 文字("string" | "number" | "date" | "rocdate") = "string" - **可選**，欄位排序規則；**僅於非批次載入模式且該表格已啟用排序時**生效
- attrs: 物件 - **可選**，對應輸出儲存格之屬性設定，可透過 `attrs.style` 設定樣式

---

## TableUI
表格元件建構子，透過 `new TableUI(config)` 將指定表格節點轉換為具備分頁、排序、合計/小計、資料匯出等能力之表格元件執行個體。

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
- config: 物件 - 表格元件設定物件
    - table: 元素參照或文字(識別代號) - 欲轉換為表格元件之目標表格節點，或其識別代號
    - column: 陣列(欄位定義物件) - 欄位定義清單，決定表格標題與各筆資料呈現方式，見「欄位定義物件」說明
    - pageSize: 數字 = 10 - 每頁顯示筆數；設為 0 或負數時停用分頁，改為單頁顯示全部資料
    - allSortable: 布林值 = true - **可選**，是否讓具備排序索引鍵之欄位預設可排序；**僅於非批次載入模式生效**，批次載入模式下排序功能停用
    - isLoadByFatch: 數字或布林值 = false - **可選**，設為 true 或數字時啟用批次(分頁)載入模式，改由呼叫端提供查詢位址與參數進行資料載入；為數字時代表每次批次讀取上限，超過 200 時限制為 200，未達 pageSize 時改以 pageSize 之 5 倍計算
    - afterLoad: 函式(mainElement, tableId, instance) - **可選**，資料載入完成後呼叫之回呼函式
    - pageChange: 函式(nowPage, totalPage, mainElement, tableId, instance) - **可選**，換頁或批次資料更新完成後呼叫之回呼函式
**輸出**:
- 執行個體: TableUI - 表格元件控制物件，提供 load()、getXlsSettingJSON() 等方法
**當缺少 config、config 非物件、或 config.table 無法對應至有效表格節點時**:
- 顯示錯誤提示並中止建立
**功能**:
- 依欄位定義清單解析並產生表格標頭、資料顯示區塊
- 依 pageSize 及 isLoadByFatch 設定，決定採一般分頁模式或批次(分頁)載入模式
- 建立完成後之執行個體可供後續呼叫 load() 載入資料、getXlsSettingJSON() 取得匯出設定

---

### load(records)
**使用範例**: `grid.load(rtnList);`
**輸入**:
- records: 物件陣列 - **可選**，欲顯示之資料物件陣列，每筆物件之欄位對應「欄位定義物件」之 key
**輸出**: 無
**當表格元件建構時未設定 config.isLoadByFatch（非批次載入模式）時**:
- 本方法適用
- 省略 records 或傳入空陣列時：清空目前顯示之資料
**功能**:
- 將傳入之資料物件陣列載入並顯示於表格中，並依 pageSize 進行分頁
- 依欄位定義中之群組設定，合併顯示相鄰且群組欄位值相同之資料列

---

### load(records, totalRecords, subTotalRecords)
**使用範例**: `grid[0].load(gridResult,gridResultTotal,gridResultSubTotal);`
**輸入**:
- records: 物件陣列 - **可選**，欲顯示之資料物件陣列，同 load(records)
- totalRecords: 物件或物件陣列 - **可選**，合計列資料；可為單一物件（其 value 屬性為合計資料物件，text 或 header 屬性可設定合計列標題文字）或前述物件之陣列
- subTotalRecords: 陣列 - **可選**，各群組小計資料；陣列元素為物件 {key, value}（或前述物件之陣列，用於巢狀群組），key 對應群組欄位值、value 為小計資料物件；**僅於欄位定義具備群組(groupKey)設定時套用**
**輸出**: 無
**當表格元件建構時未設定 config.isLoadByFatch（非批次載入模式）時**:
- 本方法適用
**功能**:
- 載入資料列、合計列與各群組小計列並顯示於表格中

---

### load(ajaxUrl, params)
**使用範例**: `grid.load( '${dispatcher}/DSE1_1900/query', params );`
**輸入**:
- ajaxUrl: 文字 - 查詢資料之服務位址
- params: 物件 - 查詢條件參數
**輸出**: 無
**當表格元件建構時已設定 config.isLoadByFatch（批次載入模式）時**:
- 本方法適用
- **當 params 未提供或非物件時**: 清空目前顯示的資料，不送出查詢
**功能**:
- 以背景查詢方式向指定服務位址送出查詢條件，依批次筆數上限分批取回並顯示第一批資料，供後續換頁時自動查詢下一批

---

### getXlsSettingJSON(sheetName)
**使用範例**: `grid.getXlsSettingJSON('異常案件報表_' + $('REPORT_TYPE1').options[$('REPORT_TYPE1').selectedIndex].innerText.trim() + '_' + '${todayROC}')`
**輸入**:
- sheetName: 文字 - 匯出資料之工作表名稱
**輸出**:
- 結果: 文字(JSON字串) - 內容包含 sheetName（工作表名稱）、titleSetting（標頭欄位設定）、recordSetting（資料欄位設定）、groupKeys（群組索引鍵清單），供匯出 Excel/XLS 服務使用
**功能**:
- 將目前表格之標頭與資料欄位設定（含 header、key、sortRule、groupKey、attrs 等，見「欄位定義物件」）序列化為 JSON 字串，供匯出作業使用
