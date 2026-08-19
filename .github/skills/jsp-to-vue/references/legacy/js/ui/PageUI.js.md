# PageUI.js 公開契約

## 使用語法清單
**方法**:
- [JsUtils.getDOM(node)](#JsUtils.getDOM(node))
- [JsUtils.cloneObject(orgObject)](#JsUtils.cloneObject(orgObject))
- [JsUtils.isArray(node)](#JsUtils.isArray(node))
- [JsUtils.isFunction(node)](#JsUtils.isFunction(node))
- [JsUtils.isDOMObject(node)](#JsUtils.isDOMObject(node))
- [JsUtils.isObject(node)](#JsUtils.isObject(node))
- [JsUtils.isString(node)](#JsUtils.isString(node))
- [JsUtils.isNumeric(node)](#JsUtils.isNumeric(node))
- [JsUtils.isBasicType(node)](#JsUtils.isBasicType(node))
- [JsUtils.compareClass(node, compare)](#JsUtils.compareClass(node,-compare))
- [JsUtils.getParentByTagName(node, TagName)](#JsUtils.getParentByTagName(node,-TagName))
- [JsUtils.createDOMElement(elementTagName, elemantAttributes, elementActions, parentElement, insertPosition)](#JsUtils.createDOMElement(elementTagName,-elemantAttributes,-elementActions,-parentElement,-insertPosition))
- [JsUtils.removeAllChildren(node)](#JsUtils.removeAllChildren(node))
- [JsUtils.addOptions(node, optionValues, key, valueKey, removeOldOptions, keepFirst)](#JsUtils.addOptions(node,-optionValues,-key,-valueKey,-removeOldOptions,-keepFirst))
- [JsUtils.setOption(node, setValue, selectFirstWhenNull)](#JsUtils.setOption(node,-setValue,-selectFirstWhenNull))
- [JsUtils.removeOptions(node, keepFirst)](#JsUtils.removeOptions(node,-keepFirst))
- [JsUtils.getSelectName(node, selectedValue)](#JsUtils.getSelectName(node,-selectedValue))
- [JsUtils.stringToArray(stringValue, splitChar)](#JsUtils.stringToArray(stringValue,-splitChar))
- [JsUtils.arrayToString(arrayValue)](#JsUtils.arrayToString(arrayValue))
- [JsUtils.setDateInput(node, value)](#JsUtils.setDateInput(node,-value))
- [JsUtils.getDateInput(node, isFormatToY2K)](#JsUtils.getDateInput(node,-isFormatToY2K))
- [JsUtils.getSimpleDateFormat(pattern, isROCtype)](#JsUtils.getSimpleDateFormat(pattern,-isROCtype))
- [JsUtils.trim(value)](#JsUtils.trim(value))
- [UI_Manager.addUIConfig(UI_Name, UI)](#UI_Manager.addUIConfig(UI_Name,-UI))
- [UI_Manager.getUI(UI_Name)](#UI_Manager.getUI(UI_Name))
- [PageUI.createPage(pageNO, title, subTitleText, noPageFrame)](#PageUI.createPage(pageNO,-title,-subTitleText,-noPageFrame))
- [PageUI.createPageWithAllBodySubElement(pageNO, title, subTitleText, fixedNum, noPageFrame)](#PageUI.createPageWithAllBodySubElement(pageNO,-title,-subTitleText,-fixedNum,-noPageFrame))
- [PageUI.loadin(loadinConfigs, fixedNum)](#PageUI.loadin(loadinConfigs,-fixedNum))
- [PageUI.resize(uncheckDocumentResize)](#PageUI.resize(uncheckDocumentResize))
- [PageUI.createContent(config, loadinValues, showType)](#PageUI.createContent(config,-loadinValues,-showType))
- [PageUI.setContentsDisplay(content, displayType)](#PageUI.setContentsDisplay(content,-displayType))
- [PageUI.setContentValue(inputElem, value, isAutoCommit, clearValueWhenNotInValues)](#PageUI.setContentValue(inputElem,-value,-isAutoCommit,-clearValueWhenNotInValues))
- [PageUI.commitContentValue(node)](#PageUI.commitContentValue(node))
- [PageUI.getContentValues(content, isAutoCommit, alwaysKeepTwoLayerMap)](#PageUI.getContentValues(content,-isAutoCommit,-alwaysKeepTwoLayerMap))
- [PageUI.setContentValues(content, values, isAutoCommit, clearValueWhenNotInValues)](#PageUI.setContentValues(content,-values,-isAutoCommit,-clearValueWhenNotInValues))
- [PageUI.commitContentValues(content)](#PageUI.commitContentValues(content))
- [PageUI.rollbackContentValues(content)](#PageUI.rollbackContentValues(content))
- [PageUI.createButtonArea(content, buttonConfig)](#PageUI.createButtonArea(content,-buttonConfig))
- [PageUI.setButtonsEnable(buttonContent, enableArray, skipCheck)](#PageUI.setButtonsEnable(buttonContent,-enableArray,-skipCheck))

---

## 共用慣例

**型別判斷函式**（JsUtils.isArray、JsUtils.isFunction、JsUtils.isDOMObject、JsUtils.isObject、JsUtils.isString、JsUtils.isNumeric、JsUtils.isBasicType 共用）：
- 輸入任意型別的值，回傳布林值，表示該值是否符合對應型別
- 皆不修改輸入值，也無其他副作用

**內容欄位模型**（PageUI.createContent 與其後各 ContentValue(s) 系列方法共用）：
- 由 PageUI.createContent 產生的畫面區塊稱為「內容容器」，其下依設定產生的各筆欄位稱為「內容欄位」
- 內容容器與內容欄位皆可用建立時取得的元素參照本身，或其識別碼字串，做為後續操作方法的輸入
- 內容欄位資料寫入後，預設會同步「提交」至顯示區並存入內容容器的暫存資料；尚未提交的變更可透過「還原」操作放棄，回復為暫存資料中的值

---

## JsUtils.getDOM(node)
**使用範例**: `node = JsUtils.getDOM(node);`
**輸入**:
- node: string | 元素參照 - 欲取得的元素本身，或該元素的識別碼(id)/名稱(name)
**輸出**:
- **當取得元素時**: 回傳值: 元素參照 - 對應元素
- **當查無元素或輸入型態不符時**: 回傳值: boolean = false - 否
**功能**:
- **當輸入為字串時**: 依序以識別碼(id)、名稱(name)查找對應元素，取第一個相符結果
- **當輸入本身即為元素時**: 直接回傳
- **當查無對應元素或輸入型態不符時**: 回傳 false

---

## JsUtils.cloneObject(orgObject)
**使用範例**: `var copySetting = JsUtils.cloneObject(setting);`
**輸入**:
- orgObject: object | array | 元素參照 | string | number | boolean - 欲複製的來源資料
**輸出**:
- 回傳值: 同輸入型別 - 複製後的新資料
**功能**:
- 支援陣列、物件、元素及基本型別資料的遞迴深層複製
- 複製結果與來源資料互相獨立，修改複製結果不影響原資料

---

## JsUtils.isArray(node)
**使用範例**: `if(JsUtils.isArray(records)){`
**輸入**:
- node: 任意型別 - 需檢查的值
**輸出**:
- 回傳值: boolean - 該值是否為陣列
**功能**:
- 檢查輸入值是否為陣列

---

## JsUtils.isFunction(node)
**使用範例**: `if(JsUtils.isFunction(window.afterGridsLoad)){ afterGridsLoad(); }`
**輸入**:
- node: 任意型別 - 需檢查的值
**輸出**:
- 回傳值: boolean - 該值是否為函式
**功能**:
- 檢查輸入值是否為函式

---

## JsUtils.isDOMObject(node)
**使用範例**: `if(JsUtils.isDOMObject(testNode))`
**輸入**:
- node: 任意型別 - 需檢查的值
**輸出**:
- 回傳值: boolean - 該值是否為單一元素節點
**功能**:
- 檢查輸入值是否為單一元素節點

---

## JsUtils.isObject(node)
**使用範例**: `if(JsUtils.isObject(valuesMap)){`
**輸入**:
- node: 任意型別 - 需檢查的值
**輸出**:
- 回傳值: boolean - 該值是否為一般物件（不含陣列與函式）
**功能**:
- 檢查輸入值是否為一般物件（陣列、函式不視為物件）

---

## JsUtils.isString(node)
**使用範例**: `if(JsUtils.isString(value)){`
**輸入**:
- node: 任意型別 - 需檢查的值
**輸出**:
- 回傳值: boolean - 該值是否為字串
**功能**:
- 檢查輸入值是否為字串

---

## JsUtils.isNumeric(node)
**使用範例**: `if(JsUtils.isNumeric(val)){`
**輸入**:
- node: 任意型別 - 需檢查的值
**輸出**:
- 回傳值: boolean - 該值是否為數值格式（含可轉換為數值的字串）
**功能**:
- 檢查輸入值是否符合數值格式

---

## JsUtils.isBasicType(node)
**使用範例**: `chkTRADE_AMT = JsUtils.isBasicType(rtnMap.TRADE_AMT) ? rtnMap.TRADE_AMT:0;`
**輸入**:
- node: 任意型別 - 需檢查的值
**輸出**:
- 回傳值: boolean - 該值是否為字串、數值或布林值
**功能**:
- 檢查輸入值是否為字串、數值或布林值其中之一

---

## JsUtils.compareClass(node, compare)
**使用範例**: `if(JsUtils.compareClass( block, "contentDivTable") ){ break; }`
**輸入**:
- node: 元素參照 - 欲比對的元素
- compare: string - 欲比對的樣式類別名稱
**輸出**:
- 回傳值: boolean - 該元素是否具有指定樣式類別（不分大小寫）
**功能**:
- 檢查指定元素是否具有輸入的樣式類別名稱

---

## JsUtils.getParentByTagName(node, TagName)
**使用範例**: `var tbody = JsUtils.getParentByTagName(deleElem , "TBODY");`
**輸入**:
- node: 元素參照 - 起始查找的元素
- TagName: string - 欲比對的元素標籤名稱
**輸出**:
- **當查得相符元素時**: 回傳值: 元素參照 - 符合標籤名稱的最近上層元素
- **當查無相符元素時**: 回傳值: boolean = false - 否
**功能**:
- 沿上層結構往上查找，回傳第一個標籤名稱相符（不分大小寫）的上層元素
- 查找至最上層仍無相符結果時，回傳false

---

## JsUtils.createDOMElement(elementTagName, elemantAttributes, elementActions, parentElement, insertPosition)
**使用範例**: `var td = JsUtils.createDOMElement( "TD" , {className:"tbYellow2" , colSpan:columnNum} , null, tr );`
**輸入**:
- elementTagName: string - 欲建立元素的標籤名稱
- elemantAttributes: object = 無 - 欲設定於元素上的屬性鍵值集合（值須為字串/數值/布林值）；鍵名為"className"時設定樣式類別
- elementActions: object = 無 - 欲綁定於元素上的事件集合，格式為{事件名稱: 處理函式}
- parentElement: 元素參照 = 無 - 欲插入的上層容器；未提供時不插入任何容器
- insertPosition: number = 無 - 插入於上層容器中第幾個子節點之前；未提供或超出範圍時附加於最後
**輸出**:
- 回傳值: 元素參照 - 建立完成的元素
**功能**:
- 依標籤名稱建立新元素，並設定基本型別屬性
- 依elementActions綁定事件處理函式，觸發時傳入來源元素與事件資訊
- **當提供 parentElement 時**: 依 insertPosition 決定插入至上層容器中的位置或附加於最後

---

## JsUtils.removeAllChildren(node)
**使用範例**: `JsUtils.removeAllChildren(parentNode);`
**輸入**:
- node: string | 元素參照 - 欲清空子節點的元素或其識別碼
**輸出**: 無
**功能**:
- 移除輸入元素下所有子節點

---

## JsUtils.addOptions(node, optionValues, key, valueKey, removeOldOptions, keepFirst)
**使用範例**: `JsUtils.addOptions( $('CRED_ID') , resp.CRED_ID_List ,"ID", "NAME" , true, true );`
**輸入**:
- node: string | 元素參照 - 欲增加選項的下拉選單元素或其識別碼
- optionValues: array | object - 欲轉換為選項的資料來源
- key: string = 無 - optionValues為陣列時，用以取得各筆資料選項值(value)的鍵名
- valueKey: string | function = 無 - optionValues為陣列時，用以取得各筆資料選項顯示文字的鍵名；若為函式，不論optionValues型態皆改以該函式取得顯示文字
- removeOldOptions: boolean = true - 是否於加入前清除既有選項
- keepFirst: boolean = false - removeOldOptions為true時，清除既有選項時是否保留第一個既有選項
**輸出**: 無
**當 optionValues 為陣列時**:
- 須同時提供 key 與 valueKey，否則不進行任何處理
**功能**:
- 依optionValues建立下拉選單選項：為陣列時，依key/valueKey取得各筆資料的選項值與顯示文字；為鍵值物件時，直接以鍵/值做為選項值/顯示文字
- 建立完成後，預設選取第一個選項

---

## JsUtils.setOption(node, setValue, selectFirstWhenNull)
**使用範例**: `JsUtils.setOption( instEle , value , true );`
**輸入**:
- node: string | 元素參照 - 欲設定值的下拉選單元素或其識別碼
- setValue: string - 欲設定選取的選項值
- selectFirstWhenNull: boolean = false - 找不到對應選項時，是否改為選取第一個選項
**輸出**: 無
**功能**:
- 依輸入值於下拉選單元素中設定對應選項為選取狀態，其餘選項取消選取

---

## JsUtils.removeOptions(node, keepFirst)
**使用範例**: `JsUtils.removeOptions($('CRED_ID2'), true);`
**輸入**:
- node: string | 元素參照 - 欲刪除選項的下拉選單元素或其識別碼
- keepFirst: boolean = false - 是否保留第一個選項
**輸出**: 無
**功能**:
- 移除下拉選單元素下所有選項；keepFirst為true時保留第一個選項

---

## JsUtils.getSelectName(node, selectedValue)
**使用範例**: `rtn[key+"_NM"] = JsUtils.getSelectName( instEle );`
**輸入**:
- node: string | 元素參照 - 欲取得值的下拉選單元素或其識別碼
- selectedValue: string = 無 - 欲取得顯示文字的選項值
**輸出**:
- **當查得有效對應選項時**: 回傳值: string - 選項的畫面顯示文字
- **當查無對應選項，或選項值為空白且未標記保留空白顯示名稱時**: 回傳值: string = `''` - 空字串
**功能**:
- **當 selectedValue 未提供時**: 取得目前被選取之選項的畫面顯示文字
- **當 selectedValue 有提供時**: 取得該選項值對應之選項的畫面顯示文字

---

## JsUtils.stringToArray(stringValue, splitChar)
**使用範例**: `allowValues = JsUtils.stringToArray(allowValues,',');`
**輸入**:
- stringValue: string | array - 以特殊符號分隔的字串
- splitChar: string - 分隔用符號
**輸出**:
- 回傳值: array - 輸入為陣列時原樣回傳；為字串時依splitChar切割並去除各項前後空白；其他型態時回傳單一元素陣列（該值去除前後空白後）
**功能**:
- 將以特殊符號分隔的字串轉換為陣列，並去除各項前後空白

---

## JsUtils.arrayToString(arrayValue)
**使用範例**: `DSA020_VO['DOCS'] = JsUtils.arrayToString(DSA020_VO['DOCS']);`
**輸入**:
- arrayValue: array - 欲轉換的陣列
**輸出**:
- 回傳值: string - 以逗號加空白分隔各基本型別項目組成的字串；輸入非陣列時回傳空字串
**功能**:
- 將陣列中的基本型別項目，組合為以逗號加空白分隔的字串

---

## JsUtils.setDateInput(node, value)
**使用範例**: `JsUtils.setDateInput( instEle , value );`
**輸入**:
- node: string | 元素參照 - 欲放入日期資料的輸入欄位元素或其識別碼
- value: string - 欲放入的日期值
**輸出**: 無
**當該輸入欄位為文字型輸入，且標記日期類資料型態(date/rocdate)時**:
- 才會設定資料
**功能**:
- 將日期資料放入指定輸入欄位
- **當已具備日期判斷能力時**: 依欄位設定的日期格式樣式與民國／西元年類型，先驗證資料為有效日期後再進行轉換與格式化

---

## JsUtils.getDateInput(node, isFormatToY2K)
**使用範例**: `var displayValue = JsUtils.getDateInput( target , false );`
**輸入**:
- node: string | 元素參照 - 欲取出日期資料的輸入欄位元素或其識別碼
- isFormatToY2K: boolean = true - 是否強制將資料轉換為西元年格式
**輸出**:
- **當欄位為日期類資料型態且資料符合日期格式時**: 回傳值: string - 取得並格式化後的日期值
- **當欄位非日期類資料型態或資料不符合日期格式時**: 回傳值: string = `''` - 空字串
**功能**:
- 自輸入欄位取出日期資料
- **當已具備日期判斷能力時**: 依欄位標記的日期資料型態(date/rocdate)驗證資料，並依 isFormatToY2K 與欄位設定的格式樣式進行西元／民國年轉換與格式化

---

## JsUtils.getSimpleDateFormat(pattern, isROCtype)
**使用範例**: `df = JsUtils.getSimpleDateFormat("yyyMM" , true );`
**輸入**:
- pattern: string - 日期格式樣式
- isROCtype: boolean = false - 是否為民國年格式
**輸出**:
- **當具備日期格式化能力時**: 回傳值: object - 日期格式化物件，可重複用於格式化日期資料
- **當尚未具備日期格式化能力時**: 回傳值: boolean = false - 否
**功能**:
- 依格式樣式與年份類型，取得（並快取）對應的日期格式化物件，供重複使用

---

## JsUtils.trim(value)
**使用範例**: `val = JsUtils.trim(val);`
**輸入**:
- value: string - 欲修正的值
**輸出**:
- 回傳值: string - 去除前後空白後的字串；輸入非字串時原樣回傳
**功能**:
- 去除字串前後空白

---

## UI_Manager.addUIConfig(UI_Name, UI)
**使用範例**: `UI_Manager.addUIConfig("iframeResize",iframeResize);`
**輸入**:
- UI_Name: string - 註冊名稱
- UI: object - 欲註冊的UI物件
**輸出**: 無
**當 UI 非物件型態時**:
- 不進行註冊
**功能**:
- 將UI物件以指定名稱註冊至共用管理清單，供其後以UI_Manager.getUI()取得
- 已註冊的UI物件，於觸發共用事件（如可視範圍尺寸變化）時，會被統一呼叫其對應方法

---

## UI_Manager.getUI(UI_Name)
**使用範例**: `UI_Manager.getUI("UNIT_DSZ01300").resize(true);`
**輸入**:
- UI_Name: string - 註冊名稱
**輸出**:
- **當查得對應註冊時**: 回傳值: object - 已註冊的 UI 物件
- **當查無對應註冊時**: 回傳值: undefined - 無
**功能**:
- 依註冊名稱取得先前以UI_Manager.addUIConfig註冊的UI物件

---

## PageUI.createPage(pageNO, title, subTitleText, noPageFrame)
**使用範例**: `PageUI.createPage("DSA30800" , "鑑價作業" , "特殊屋況查詢作業", false);`
**輸入**:
- pageNO: string - 頁面編號
- title: string - 頁面主標題
- subTitleText: string - 頁面副標題
- noPageFrame: boolean = false - 是否不產生頁面外框（標題列與邊框），僅產生基本內容容器
**輸出**: 無
**功能**:
- 設定視窗標題為「主標題 - 副標題 (頁面編號)」
- 於頁面最前方插入頁面基本外框結構，包含標題列（顯示主標題、副標題與頁面編號）及內容容器
- **當 pageNO 為空字串時**: 標題列不顯示頁面編號文字
- **當 noPageFrame 為 true 時**: 不產生標題列與邊框，僅產生基本內容容器
- 建立完成後，重新調整頁面版面大小

---

## PageUI.createPageWithAllBodySubElement(pageNO, title, subTitleText, fixedNum, noPageFrame)
**使用範例**: `PageUI.createPageWithAllBodySubElement("DSA40202" , "經手人專區" , "檔案產製作業");`
**輸入**:
- pageNO: string - 頁面編號
- title: string - 頁面主標題
- subTitleText: string - 頁面副標題
- fixedNum: number = 0 - 固定顯示的區塊數目，0代表不將任何區塊移入可捲動子區域
- noPageFrame: boolean = false - 是否不產生頁面外框
**輸出**: 無
**功能**:
- 收集頁面中既有、非隱藏且具內容（或標記為表格/分頁區塊）的元素
- 依pageNO/title/subTitleText/noPageFrame產生頁面基本外框
- 將收集到的元素依序納入頁面內容容器，並依fixedNum決定固定顯示或移入可捲動子區域
- 建立完成後，重新調整頁面版面大小

---

## PageUI.loadin(loadinConfigs, fixedNum)
**使用範例**: `PageUI.loadin(["tableA","grid","tableB"] ,1);`
**輸入**:
- loadinConfigs: array | object | string | 元素參照 - 欲納入內容容器的區塊設定，可為單一設定或設定陣列
- loadinConfigs[].elem: string | 元素參照 - 欲納入的既有元素或其識別碼
- loadinConfigs[].id: string = 無 - 欲賦予容器的識別碼
- loadinConfigs[].title: string | 元素參照 = 無 - 區塊標題文字或標題元素；未提供時取來源元素之blockTitle屬性設定值
- loadinConfigs[].position: number = 無 - 插入位置
- fixedNum: number = 0 - 固定顯示的區塊數目，0代表不將任何區塊移入可捲動子區域
**輸出**: 無
**當設定中找不到對應來源元素時**:
- 該項目會被略過不處理
**功能**:
- 將指定的既有元素各自包裝為帶標題的區塊，依序納入頁面內容容器
- 依fixedNum決定哪些區塊固定顯示、哪些區塊移入可捲動子區域
- 完成後重新調整頁面版面大小

---

## PageUI.resize(uncheckDocumentResize)
**使用範例**: `PageUI.resize();`
**輸入**:
- uncheckDocumentResize: boolean = false - 是否略過可視範圍尺寸變化檢查，強制重新計算版面大小
**輸出**: 無
**功能**:
- 重新計算並調整可捲動子區域與主要頁面容器的高度，使其符合目前可視範圍高度
- **當 uncheckDocumentResize 為 false 時**: 僅在偵測到可視範圍尺寸變化時進行調整，並記錄最新尺寸

---

## PageUI.createContent(config, loadinValues, showType)
**使用範例**: `var tbody = PageUI.createContent( copySetting , null , showType  );`
**輸入**:
- config: object - 內容容器設定
- config.contents: array - 各欄位配置，每筆元素可含header(標題文字或標題元素)、colSpan/rowSpan(佔用欄/列數，預設1)、values(該欄位包含的內容項目陣列，項目可為文字、元素參照，或欄位設定物件)
- config.contents[].values[].id: string = 無 - 欄位識別碼，與key至少擇一提供
- config.contents[].values[].key: string = 無 - 欄位資料鍵名，與id至少擇一提供
- config.contents[].values[].type: string = 無 - 欄位輸入型態，可為text/number/money/select/date/datebetween/textarea/radio/checkbox/dom/link，未提供或不符上述類型時顯示為純文字
- config.contents[].values[].getFunc: function = 無 - 取值時的客製化轉換函式
- config.contents[].values[].setFunc: function = 無 - 寫值時的客製化轉換函式
- config.elem: string | 元素參照 = 無 - 欲附加內容的目標容器；未指定或非表格元素時，於新建的表格中產生內容
- config.clearChildElements: boolean = false - 是否於處理前清除目標容器下所有子元素
- config.noHeader: boolean = false - 是否不產生標題欄
- config.noContent: boolean = false - 是否不產生內容欄
- config.headerInTop: boolean = false - 標題與內容欄是否改為上下排列，預設為左右排列
- config.dataColumns: number = 2 - 每列配置的欄位組數
- config.columnProps: array = 無 - 各欄位寬度比例設定，未提供時依dataColumns平均分配
- config.attrs: object = 無 - 設定於產生表格上的屬性
- config.className: string = 無 - 設定於產生表格上的樣式類別
- config.id: string = 無 - 內容容器識別碼，未提供時自動編號產生
- config.IdToKey: function = 無 - 由id轉換為key的客製化函式
- config.KeyToId: function = 無 - 由key轉換為id的客製化函式
- loadinValues: object = 無 - 建立完成後欲載入的初始資料，鍵值需對應各欄位的key
- showType: number = 1 - 初始顯示模式，0=輸入模式，1=顯示模式
**輸出**:
- 回傳值: 元素參照 - 建立完成的內容容器
**當 config 非物件、或 config.contents 非陣列時**:
- 不進行任何處理

**當有提供 config.elem 但無法取得對應目標元素時**:
- 不進行任何處理
**功能**:
- 依config.contents定義的欄位配置，依序產生標題欄與內容欄位，並依dataColumns與各欄位colSpan/rowSpan自動換行排列
- 內容欄位依type產生對應的輸入元素（文字、數值、金額、下拉選單、日期、日期區間、多行文字、選項按鈕/核取方塊、任意元素、連結或純文字）
- **當提供 loadinValues 時**: 建立完成後載入初始資料
- 依showType設定初始顯示/輸入模式
- 回傳建立完成的內容容器，可供PageUI內容欄位模型下其餘方法操作使用

---

## PageUI.setContentsDisplay(content, displayType)
**使用範例**: `PageUI.setContentsDisplay( contentTable , 0 );`
**輸入**:
- content: string | 元素參照 - 內容容器，或其上層容器
- displayType: number - 顯示模式，0=輸入模式，1=顯示模式，其餘數值=輸入與顯示同時呈現
**輸出**: 無
**當 content 無法辨識出至少一個內容容器時**:
- 不進行任何動作
**功能**:
- 將內容容器下所有內容欄位切換為指定的顯示/輸入模式
- 完成後重新調整頁面版面大小

---

## PageUI.setContentValue(inputElem, value, isAutoCommit, clearValueWhenNotInValues)
**使用範例**: `PageUI.setContentValue("C_AGE" , resp , true , true );`
**輸入**:
- inputElem: string | 元素參照 - 內容欄位，或其下屬輸入元素
- value: string | number | boolean | object - 欲寫入的值；為物件時，依欄位對應鍵名取值寫入
- isAutoCommit: boolean = true - 寫入後是否同步提交至顯示區
- clearValueWhenNotInValues: boolean = false - 找不到對應寫入值時，是否以空白覆蓋原資料；為false時保留原資料且不繼續處理該欄位
**輸出**: 無
**當 inputElem 無法辨識出有效的內容欄位、或該欄位未隸屬於任一內容容器時**:
- 不進行任何動作
**功能**:
- 將指定值寫入內容欄位對應的輸入元素
- **當 isAutoCommit 為 true 時**: 同步將該欄位目前輸入值提交至顯示區，並存入所屬內容容器的暫存資料

---

## PageUI.commitContentValue(node)
**使用範例**: `PageUI.commitContentValue( testNode );`
**輸入**:
- node: string | 元素參照 - 內容欄位，或其下屬輸入元素
**輸出**: 無
**當 node 無法辨識出有效的內容欄位、或該欄位未隸屬於任一內容容器時**:
- 不進行任何動作
**功能**:
- 取出該內容欄位目前輸入值，更新至其顯示區，並同步寫入所屬內容容器的暫存資料

---

## PageUI.getContentValues(content, isAutoCommit, alwaysKeepTwoLayerMap)
**使用範例**: `var queryData = PageUI.getContentValues(query);`
**輸入**:
- content: string | 元素參照 - 內容容器，或其上層容器
- isAutoCommit: boolean = true - 取值前是否先將目前各欄位輸入值提交至顯示區與暫存資料
- alwaysKeepTwoLayerMap: boolean = false - 僅有單一內容容器時，是否仍以「容器識別碼: 資料」的兩層結構回傳
**輸出**:
- 回傳值: object - content可辨識出內容容器時，回傳其目前暫存資料；辨識不出任何內容容器時回傳undefined
**功能**:
- 取得內容容器（或其下所有內容容器）目前的暫存資料
- **當僅有單一內容容器且 alwaysKeepTwoLayerMap 非 true 時**: 直接回傳該容器的資料
- **其餘情況**: 以「容器識別碼: 資料」的兩層結構回傳

---

## PageUI.setContentValues(content, values, isAutoCommit, clearValueWhenNotInValues)
**使用範例**: `PageUI.setContentValues( tbody , value , true , true );`
**輸入**:
- content: string | 元素參照 - 內容容器，或其上層容器
- values: object = 無 - 欲寫入的資料
- isAutoCommit: boolean = true - 寫入後是否同步提交至顯示區
- clearValueWhenNotInValues: boolean = false - 找不到對應寫入值時，是否以空白覆蓋原資料
**輸出**: 無
**當 content 無法辨識出至少一個內容容器時**:
- 不進行任何動作
**功能**:
- **當僅有單一內容容器且 values 各鍵值皆非物件時**: 直接以 values 作為該容器的資料寫入
- **其餘情況**: 以「容器識別碼: 資料」的兩層結構，分別將對應資料寫入各內容容器
- 將資料寫入內容容器下所有內容欄位，並更新其暫存資料

---

## PageUI.commitContentValues(content)
**使用範例**: `PageUI.commitContentValues(ContentSaves["B"]);`
**輸入**:
- content: string | 元素參照 - 內容容器，或其上層容器
**輸出**: 無
**當 content 無法辨識出至少一個內容容器時**:
- 不進行任何動作
**功能**:
- 將內容容器（或其下所有內容容器）下所有內容欄位目前輸入值，更新至其顯示區並同步寫入暫存資料

---

## PageUI.rollbackContentValues(content)
**使用範例**: `PageUI.rollbackContentValues( contentTable );`
**輸入**:
- content: string | 元素參照 - 內容容器，或其上層容器
**輸出**: 無
**當 content 無法辨識出至少一個內容容器時**:
- 不進行任何動作
**功能**:
- 將內容容器（或其下所有內容容器）下所有內容欄位，還原為暫存資料中的值，放棄尚未提交的輸入內容

---

## PageUI.createButtonArea(content, buttonConfig)
**使用範例**: `PageUI.createButtonArea( query , { changeForOneButton:false, buttonOnRight:true, buttons:bottons } );`
**輸入**:
- content: string | 元素參照 - 欲附加按鈕區域的對象，可為內容欄位、內容容器，或一般容器元素
- buttonConfig: object - 按鈕區域設定
- buttonConfig.buttons: object - 欲建立的按鈕集合，格式為{按鈕鍵名: 按鈕設定}
- buttonConfig.buttons[key].id: string = 按鈕鍵名 - 按鈕識別碼
- buttonConfig.buttons[key].header: string = 按鈕鍵名 - 按鈕顯示文字
- buttonConfig.buttons[key].attrs: object = 無 - 設定於按鈕上的屬性
- buttonConfig.buttons[key].events: object = 無 - 設定於按鈕上的事件
- buttonConfig.buttons[key].ignoreAuth: boolean = false - 是否不將此按鈕納入全域按鈕權限清單
- buttonConfig.changeForOneButton: boolean = false - 每個按鈕是否各自獨立一行
- buttonConfig.buttonOnRight: boolean = false - content為內容容器時，按鈕區是否置於容器右側獨立欄位
- buttonConfig.clearChildElements: boolean = false - content為一般容器時，是否於加入前清除其下所有子元素
**輸出**:
- 回傳值: 元素參照 - 建立完成的按鈕區域容器
**當 buttonConfig.buttons 非物件時**:
- 不進行任何處理
**功能**:
- 依buttonConfig.buttons建立一組按鈕，並依content的型態（內容欄位/內容容器/一般容器）決定放置方式
- 建立的按鈕識別碼會登記於全域按鈕權限清單，供PageUI.setButtonsEnable統一控管啟用/停用狀態

---

## PageUI.setButtonsEnable(buttonContent, enableArray, skipCheck)
**使用範例**: `PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_MOD" , area+"_DEL"] );`
**輸入**:
- buttonContent: string | 元素參照 - 由PageUI.createButtonArea建立的按鈕區域容器
- enableArray: array | string - 欲啟用的按鈕識別碼清單，字串時以逗號分隔
- skipCheck: array | string = 無 - 欲略過本次調整、維持原啟用狀態的按鈕識別碼清單，字串時以逗號分隔
**輸出**: 無
**當 buttonContent 非由 PageUI.createButtonArea 建立的按鈕區域容器時**:
- 不進行任何動作
**功能**:
- 依enableArray調整按鈕區域中各按鈕的啟用/停用狀態，未列於enableArray者停用
- **當按鈕識別碼列於 skipCheck 時**: 該按鈕維持原啟用狀態，不受本次調整影響
