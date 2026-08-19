# PageControllerObj.js 公開契約

## 使用語法清單
**方法**:
- [page()](#page())
- [gotoFirstPage()](#gotoFirstPage())
- [gotoLastPage()](#gotoLastPage())
- [gotoNextPage()](#gotoNextPage())
- [gotoPrevPage()](#gotoPrevPage())

---

## 共用模式
下列方法皆須傳入同一個由外部建立之空物件（分頁狀態物件），各方法會於此物件上掛載並維護分頁所需之狀態（列資料、目前頁碼、總頁數等）。多個分頁區塊可各自建立獨立的分頁狀態物件以互不干擾。

---

## page()
**使用範例**: `page(grid1_pageObj, document.form1, 20, "ROWID1", "pageControlerBoard1", 1);`
**輸入**:
- obj: Object - 分頁狀態物件，由外部建立空物件（例如 `{}`）並傳入，供本方法掛載分頁狀態
- form: Object - 欲進行分頁之表單物件
- size: Number - 每頁顯示筆數
- rowid: String - 欲納入分頁作用之列（或儲存格）識別碼
- infoid: String - 顯示分頁訊息欄位之識別碼
- fetchTR: Number = undefined - 每幾個列元素視為一筆資料（用於含跨列合併儲存格顯示之情境），可省略
**輸出**: 無
**功能**:
- 依指定表單、識別碼與每頁筆數，蒐集符合識別碼之列（或儲存格）並計算總筆數、總頁數，寫入 obj
- 建立完成後自動切換顯示至第一頁

## gotoFirstPage()
**使用範例**: `gotoFirstPage(grid1_pageObj);`
**輸入**:
- obj: Object - 分頁狀態物件
**輸出**: 無
**功能**:
- 切換顯示至第一頁

## gotoLastPage()
**使用範例**: `gotoLastPage(grid1_pageObj);`
**輸入**:
- obj: Object - 分頁狀態物件
**輸出**: 無
**功能**:
- 切換顯示至最後一頁

## gotoNextPage()
**使用範例**: `gotoNextPage(grid1_pageObj);`
**輸入**:
- obj: Object - 分頁狀態物件
**輸出**: 無
**功能**:
- 切換顯示至下一頁

## gotoPrevPage()
**使用範例**: `gotoPrevPage(grid1_pageObj);`
**輸入**:
- obj: Object - 分頁狀態物件
**輸出**: 無
**功能**:
- 切換顯示至上一頁
