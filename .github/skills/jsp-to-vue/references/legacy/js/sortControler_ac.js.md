# sortControler_ac.js 公開契約

## 使用語法清單
**變數**:
- [sortCol](#sortCol)

**方法**:
- [sortTable()](#sortTable())

---

## 共用模式
sortCol 用於記錄最近一次排序之欄位索引，供 sortTable() 內部清除前次排序欄位背景色使用。外部程式於重新排序前，可先將其重設為 -1。

---

## sortTable()
**使用範例**: `sortTable(col, tableToSort, rowToSort, dataType, sort_type, false, '#F0F8FF', '#FAFBE1');`
**輸入**:
- col: Number - 欲排序之欄位索引
- tableToSort: Object - 欲排序之表格物件
- rowToSort: String - 欲納入排序之列識別碼
- dataType: Number - 排序內容型態（0: 字串；1: 數字；2: 日期）
- sortType: Number - 排序方式（0: 升冪；其他: 降冪）
- reSortIndex: Boolean - 是否重新編排第 0 欄之索引號
- oddBgColor: String - 排序後單數列背景色
- evenBgColor: String - 排序後偶數列背景色
- colBgColor: String = undefined - 排序後被排序欄位背景色，可省略
**輸出**: 無
**功能**:
- 依指定欄位與資料型態，對表格中符合列識別碼之列重新排序
- 排序後依單/偶數列套用對應背景色，並記錄目前排序欄位至 sortCol
- **當符合條件之列數少於 2 時**: 不進行排序

## sortCol
**使用範例**: `sortCol = -1;`
**輸入**: 無
**輸出**:
- sortCol: Number = undefined - 最近一次排序之欄位索引
**功能**:
- 可由外部程式直接指定，於重新排序前重設狀態
