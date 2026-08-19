# pageController.js 公開契約

## 使用語法清單
**變數**:
- [rowElements](#rowElements)
- [totalrecord](#totalrecord)
- [totalpages](#totalpages)
- [pagesize](#pagesize)
- [fetchRows](#fetchRows)
- [pageinfo](#pageinfo)

**方法**:
- [page()](#page())
- [gotoFirstPage()](#gotoFirstPage())
- [gotoLastPage()](#gotoLastPage())
- [gotoNextPage()](#gotoNextPage())
- [gotoPrevPage()](#gotoPrevPage())
- [gotoPage()](#gotoPage())

---

## 共用模式
分頁狀態由一組全域變數（rowElements、totalrecord、totalpages、pagesize、fetchRows、pageinfo）共同維護：
- 呼叫 page() 可自動依表單內容建立並初始化上述狀態。
- 亦可不呼叫 page()，改由外部程式直接指定上述變數以自行建立分頁狀態，再呼叫 gotoPage()／gotoFirstPage()／gotoLastPage()／gotoNextPage()／gotoPrevPage() 進行換頁。

---

## page()
**使用範例**: `page(document.form,30,"ROWID","pageControlerBoard");`
**輸入**:
- form: Object - 欲進行分頁之表單物件
- size: Number - 每頁顯示筆數
- rowid: String - 欲納入分頁作用之列（或儲存格）識別碼
- infoid: String - 顯示分頁訊息欄位之識別碼
- fetchTR: Number = undefined - 每幾個列元素視為一筆資料（用於含跨列合併儲存格顯示之情境），可省略
**輸出**: 無
**功能**:
- 依指定表單、識別碼與每頁筆數，蒐集符合識別碼之列（或儲存格）並計算總筆數、總頁數
- 建立完成後自動切換顯示至第一頁

## gotoFirstPage()
**使用範例**: `gotoFirstPage();`
**輸入**: 無
**輸出**: 無
**功能**:
- 切換顯示至第一頁

## gotoLastPage()
**使用範例**: `gotoLastPage();`
**輸入**: 無
**輸出**: 無
**功能**:
- 切換顯示至最後一頁

## gotoNextPage()
**使用範例**: `gotoNextPage();`
**輸入**: 無
**輸出**: 無
**功能**:
- 切換顯示至下一頁

## gotoPrevPage()
**使用範例**: `gotoPrevPage();`
**輸入**: 無
**輸出**: 無
**功能**:
- 切換顯示至上一頁

## gotoPage()
**使用範例**: `gotoPage(0);`
**輸入**:
- n: Number - 欲切換之頁碼索引（由 0 起算）
**輸出**: 無
**功能**:
- 切換顯示至指定頁碼，並更新分頁訊息顯示內容
- **當指定頁碼小於 0 或大於等於總頁數時**: 不作任何切換

## rowElements
**使用範例**: `rowElements = CSS_Selectors.getElementByAttr(form, {'name':rowid});`
**輸入**: 無
**輸出**:
- rowElements: Array = undefined - 目前分頁作用中的列（或儲存格）元素陣列
**功能**:
- 可由外部程式直接指定，取代 page() 內部之列蒐集邏輯，作為後續換頁行為之資料來源

## totalrecord
**使用範例**: `totalrecord = rowElements.length;`
**輸入**: 無
**輸出**:
- totalrecord: Number = 0 - 目前資料總筆數
**功能**:
- 可由外部程式直接指定，供換頁時計算頁碼範圍使用

## totalpages
**使用範例**: `totalpages = parseInt(totalrecord/pagesize);`
**輸入**: 無
**輸出**:
- totalpages: Number = 0 - 總頁數
**功能**:
- 可由外部程式直接指定，供 gotoPage() 邊界檢查使用

## pagesize
**使用範例**: `pagesize = size;`
**輸入**: 無
**輸出**:
- pagesize: Number = 10 - 每頁顯示筆數
**功能**:
- 可由外部程式直接指定，供換頁時計算頁碼範圍使用

## fetchRows
**使用範例**: `fetchRows = fetchTR;`
**輸入**: 無
**輸出**:
- fetchRows: Number = null - 每幾個列元素視為一筆資料
**功能**:
- 可由外部程式直接指定，供換頁時決定顯示/隱藏之列元素範圍

## pageinfo
**使用範例**: `pageinfo = document.getElementById(infoid);`
**輸入**: 無
**輸出**:
- pageinfo: Object = undefined - 顯示分頁訊息之元件
**功能**:
- 可由外部程式直接指定，換頁時會更新其顯示內容為目前分頁訊息
