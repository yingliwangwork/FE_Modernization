# jsonUtil.js 公開契約

## 使用語法清單
**方法**:
- [JSONUtil.addOptions2(ele, obj)](#JSONUtil.addOptions2(ele,-obj))
- [JSONUtil.sampleJSON2Form2(formId, obj)](#JSONUtil.sampleJSON2Form2(formId,-obj))
- [JSONUtil.sampleJSON2Form3(formId, obj, tagNames, keys, alias)](#JSONUtil.sampleJSON2Form3(formId,-obj,-tagNames,-keys,-alias))

---

## JSONUtil.addOptions2(ele, obj)
**使用範例**: `JSONUtil.addOptions2( $('ADCD') , resp.ADCD_LIST );`
**輸入**:
- ele: String | Object - 下拉選單欄位識別碼或欄位物件
- obj: Object - 選項資料，鍵為選項值、值為選項顯示文字
**輸出**: 無
**功能**:
- 清空指定下拉選單既有選項後，依 obj 各鍵值對逐一新增選項

---

## JSONUtil.sampleJSON2Form2(formId, obj)
**使用範例**: `JSONUtil.sampleJSON2Form2( 'form2', rtnMap );`
**輸入**:
- formId: String - 表單識別碼
- obj: Object - 欲同步至表單之資料，鍵對應欄位之名稱、送出用名稱或識別碼
**輸出**: 無
**功能**:
- 依 obj 鍵值，找出表單內對應之欄位或顯示元素並同步其值或顯示內容
- 文字容器類元素更新顯示內容；核取方塊、選項按鈕依值比對勾選狀態；其餘輸入類元素設定其值

---

## JSONUtil.sampleJSON2Form3(formId, obj, tagNames, keys, alias)
**使用範例**: `JSONUtil.sampleJSON2Form3( "form1", dataMap );`
**輸入**:
- formId: String - 表單識別碼
- obj: Object - 欲同步至表單之資料
- tagNames: String[] = ['td','span'] - 允許同步顯示內容之標籤名稱清單
- keys: String[] = Object.keys(obj) - 欲處理之資料鍵清單
- alias: String - 附加於每個鍵名稱後之字尾，用以對應實際欄位名稱
**輸出**: 無
**功能**:
- 依 keys 逐一將 obj 對應值同步至表單內同名或同識別碼之欄位（含選項按鈕、核取方塊）
- **當 tagNames 非空陣列時**: 同步符合 tagNames 標籤類型且識別碼相符之顯示元素內容
- **當 tagNames 為空陣列時**: 僅同步表單控制項數值，不同步顯示元素內容
