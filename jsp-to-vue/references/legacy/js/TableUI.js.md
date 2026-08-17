# TableUI.js 公開契約

> 原始資源：`/CM/js/ui/TableUI.js`

## **`setValidRecord(node, dataObjs, validResult, msg)`**

### 用途

- 由表格內節點手動設定所屬紀錄的驗證狀態。

### 輸入

- `node`: [Element] - 位於目標表格資料列內的節點，用來識別所屬表格與資料紀錄。
- `dataObjs`: [Any = undefined] - 相容性保留參數；原始實作不讀取此值。
- `validResult`: [Boolean|Function|Any = undefined] - 要寫入的有效狀態；函式會以無參數方式先求值，僅結果嚴格等於 `false` 時視為無效，其餘值均視為有效。
- `msg`: [Any = undefined] - 相容性保留參數；原始實作不讀取此值。

### 輸出

- `return`: [Boolean] - 無法識別所屬表格時為 `false`；其餘情況為實例方法 `grid.setValidRecord(node, validResult)` 回傳值的邏輯反相。正常手動設定時，紀錄設為無效會回傳 `true`，設為有效會回傳 `false`。

### 對外功能

- 透過指定節點識別所屬資料紀錄；一般載入模式會嘗試更新該紀錄的驗證狀態。`dataObjs` 與 `msg` 僅存在於全域簽章，不會傳入實例方法。

### 副作用

- 修改表格內對應資料紀錄的驗證狀態。
- 一般載入模式若已設定 `config.validateRecord`，底層操作會顯示提示訊息並拒絕修改；此時實例方法回傳 `undefined`，全域包裝函式仍會回傳 `true`，不得將該回傳值解讀為修改成功。
- 遠端分批載入模式沒有發布實際設定驗證狀態的函式，建構式改綁定空函式；此全域包裝仍回傳 `true`，但不修改紀錄。

---

## **`getValueByElement(elem, valueTemplate)`**

### 用途

- 由表格內節點取得其代表的資料紀錄集合。

### 輸入

- `elem`: [Element] - 位於目標表格資料列內的節點。
- `valueTemplate`: [Any = undefined] - 名稱雖稱為模板，實際會原樣傳入 `grid.getRecordsByCell(elem, dataExpireAlert)` 的 `dataExpireAlert`；僅嚴格等於 `false` 時抑制遠端分批載入模式的逾期資料提示。

### 輸出

- `return`: [Array<Object>] - 節點所對應的一筆或多筆資料紀錄；無法識別所屬表格時為空陣列。

### 對外功能

- 依畫面節點的資料列識別資訊，取得該節點所代表的原始資料紀錄集合。

### 副作用

- 遠端分批載入模式下，若要求的資料已不在目前載入範圍，可能顯示提示訊息。

---

## **`getCellByTagName(node, tagName, allowFragment)`**

### 用途

- 沿節點祖先鏈取得最近的指定標籤元素。

### 輸入

- `node`: [Node] - 搜尋起點，可為元素或文字節點。
- `tagName`: [String] - 要尋找的祖先元素名稱，不區分大小寫。
- `allowFragment`: [Boolean = false] - 是否允許文件片段作為有效搜尋起點。

### 輸出

- `return`: [Element|null|undefined] - 起點本身或最近的同名祖先元素；到達頁面主體仍未找到時為 `null`，起點無效時無回傳值。

### 對外功能

- 從指定節點向上尋找特定種類的最近容器，搜尋邊界為頁面主體。

### 副作用

- 無

---

## **`getValidRecord(node)`**

### 用途

- 取得指定表格目前驗證失敗的紀錄。

### 輸入

- `node`: [Element] - 位於目標表格內的節點，用來識別所屬表格。

### 輸出

- `return`: [Array<Object>|Boolean] - 所屬表格內驗證失敗的資料紀錄；沒有錯誤紀錄或無法識別表格時為 `false`。

### 對外功能

- 取得指定節點所屬表格中目前被標記為無效的資料紀錄；一般載入模式涵蓋全部資料，遠端分批載入模式最多涵蓋目前快取批次。

### 副作用

- 遠端分批載入模式若全域 `window.tableUI_getFatchRecords` 未啟用，底層全量資料查詢會顯示不支援提示訊息。

---

## **`new TableUI(config)`**

### 用途

- 將既有表格元素初始化為具備資料、分頁、選取、驗證、排序與輸入控制的表格元件。

### 輸入

- `config`: [Object] - 表格設定物件。下列欄位均為原始實作直接讀取的公開輸入：
  - `config.table`: [Element|String] - 必填。既有 `<table>` 元素或其 `id`；無法取得元素時顯示提示並停止初始化。
  - `config.column`: [Array<Object>|Array<Array<Object>>] - 必填。資料欄設定；一維陣列代表單列，一維陣列搭配 `split` 可切成多列，二維陣列直接代表多列矩陣。空值、首項不存在或列中含非物件項目會顯示提示，解析失敗時可能拋出初始化錯誤。
  - `config.headerColumn`: [Array<Object>|Array<Array<Object>> = config.column] - 選用的獨立標題欄矩陣；未提供陣列時沿用 `column`。
  - `config.split`: [Array<String> = undefined] - 當 `column` 為一維陣列時，列出每一新列起始欄位的 `key`；遇到相符鍵值即在該欄之前切列。
  - `config.needHeader`: [Boolean|Function = true] - 是否顯示標題區；函式以無參數方式求值。
  - `config.allSortable`: [Boolean|Function = true] - 非遠端分批載入模式下，未個別設定 `sortable` 的欄位是否可排序。
  - `config.allRenderInCount`: [Boolean = false] - 未個別設定 `renderInCount` 時，合計與小計是否執行欄位 `render`。
  - `config.pageSize`: [Number|String = 10] - 每頁筆數；可解析為整數，值小於或等於 `0` 時停用分頁。列印模式會將此欄位直接改為 `0`。
  - `config.pageInfo`: [Boolean|Function = !!pageSize] - 是否建立頁次資訊；停用分頁時仍可獨立顯示筆數資訊。
  - `config.recordInfoPattern`: [String = 模式內建字串] - 頁次資訊模板，可使用 `{nowPage}`、`{totalPage}`、`{totalRecord}` 與一般模式群組資料的 `{totalGroup}`。請參照[代碼對照表](#代碼對照表)。
  - `config.isLoadByFatch`: [Boolean|Number|String = false] - 設為 `true` 或可解析為數字的值即啟用遠端分批載入模式；原始名稱為 `Fatch`，不是 `Fetch`。數值大於或等於每頁筆數時同時指定每批筆數，否則每批預設為每頁筆數的五倍；每批上限為 `200`，並會調整為每頁筆數的整數倍。
  - `config.printMode`: [Boolean|Function = false] - 是否採列印模式；啟用時停用遠端分批載入、分頁、固定欄與自動輸入控制。
  - `config.overDiv`: [Object|Boolean = true] - 嚴格等於 `false` 時停用捲動容器相關固定欄能力；物件會作為尺寸覆蓋設定，其他值正規化為 `true`。
    - `config.overDiv.maxHeight`: [Number|String = undefined] - 資料區最大高度；僅可解析為數字時採用。
    - `config.overDiv.minHeight`: [Number|String = 200] - 資料區最小高度；可解析為數字時取整數，否則為 `200`。
  - `config.title`: [String|Number|Element|DocumentFragment|Function|Object = undefined] - 表格標題內容；物件形式的欄位如下：
    - `config.title.text`: [Any|Function] - 標題內容；函式以無參數方式求值，可回傳節點或基本型別。
    - `config.title.className`: [String = ""] - 標題容器附加的類別名稱；`config.headClass` 存在時優先使用後者。
    - `config.title.styles`: [Object = {}] - 套用至標題容器的樣式；實作會強制寫入 `whiteSpace: "nowrap"`。
    - `config.title.attrs`: [Object = {}] - 套用至標題容器的屬性；實作會強制寫入 `name: "tableTitle"`。
  - `config.headClass`: [String = ""] - 標題容器附加類別，優先於 `config.title.className`。
  - `config.whenDataNull`: [String|Number|Boolean = 全形空白] - 全表空值的替代顯示；欄位 `whenDataNull` 可覆蓋此值。
  - `config.default_total_header`: [Any = undefined] - 合計列沒有 `text`、`header`、`tableui_headerKey` 或資料 `header` 時使用的標題內容。
  - `config.default_subTotal_header`: [Any = undefined] - 小計列沒有自帶標題時使用的標題內容。
  - `config.beforeLoad`: [Function = undefined] - 載入並建立頁面前呼叫為 `beforeLoad.call(tableContainer, tableContainer, tableId, internalThis)`；回傳值不影響流程。`internalThis` 是內部函式當次的 `this`，一般非嚴格模式呼叫通常為 `window`，不是公開 `grid` 實例。
  - `config.afterLoad`: [Function = undefined] - 載入並建立頁面後呼叫；一般模式使用 `afterLoad.call(tableContainer, tableContainer, tableId, internalThis)`，遠端模式則直接呼叫 `afterLoad(tableContainer, tableContainer, tableId, internalThis)`。最後一參數通常為 `window`。
  - `config.beforePageChange`: [Function = undefined] - 換頁前呼叫為 `beforePageChange.call(tableContainer, currentPage, targetPage, totalPage, tableContainer, tableId, internalThis)`；嚴格回傳 `false` 可取消換頁。最後一參數通常為 `window`。
  - `config.pageChange`: [Function = undefined] - 頁面資訊更新後呼叫為 `pageChange.call(tableContainer, currentPage, totalPage, tableContainer, tableId, internalThis)`；回傳值不影響流程。最後一參數通常為 `window`。
  - `config.rowClick`: [Function = undefined] - 資料列點擊後呼叫為 `rowClick(clickedElement, firstRecord, bodySerialNo)`；點擊表單控制或互動元素時，具備 Prototype 或 jQuery 的環境會略過此回呼。
  - `config.setRecordBackground`: [Function = undefined] - 每一畫面資料群組建立後呼叫為 `setRecordBackground(records)`；回傳非空字串時設為群組 `<tbody>` 的背景色。
  - `config.setRecordClass`: [Function = undefined] - 每一畫面資料群組建立後呼叫為 `setRecordClass(records)`；回傳非空字串時加入群組 `<tbody>` 的類別。
  - `config.validateRecord`: [Boolean|Function = undefined] - 紀錄驗證規則；函式簽章為 `validateRecord(record, serialNo)`。僅設定值或函式結果嚴格等於 `false` 時判為無效，其他值均判為有效；完整轉換規則請參照[代碼對照表](#代碼對照表)。
  - `config.validateRecordCheckedOnly`: [Boolean|Function = false] - 初次載入後是否只為已勾選紀錄顯示驗證錯誤；不會限制 `validateRecord` 的執行範圍。
  - `config.autoCheckBox`: [Boolean|Object = false] - 建立自動選取欄；必須存在 Prototype 或 jQuery，且列印模式會停用。物件欄位如下：
    - `config.autoCheckBox.type`: [String = "CHECKBOX"] - 僅不區分大小寫的 `RADIO` 建立單選控制，其餘值建立核取方塊。
    - `config.autoCheckBox.valueKey`: [String = ""] - 選取控制的資料鍵，也是 `preCheckedValues` 與 `setAnotherCheckBox` 的比對來源。
    - `config.autoCheckBox.returnValue`: [String|Array<String> = undefined] - `getCheckedRecord(s)` 未傳有效模板時採用的預設投影模板。
    - `config.autoCheckBox.action`: [Function = undefined] - 單筆選取狀態變更後呼叫為 `action.call(input, input, checked, records)`；單選切換會先對前一筆以 `checked=false` 呼叫。
    - `config.autoCheckBox.isSelectAll`: [Boolean|Function = false] - 是否建立全選控制；遠端分批載入及單選模式不支援。若為函式，使用者點擊後呼叫為 `isSelectAll.call(input, input, checked, allRecords)`。
    - `config.autoCheckBox.text`: [Any = 內建文字] - 選取欄標題。
    - `config.autoCheckBox.noBreakLine`: [Boolean|Function = false] - 是否將全選控制與標題置於同一行。
    - `config.autoCheckBox.insertPosition`: [Number|String = 0] - 選取欄插入位置；負值或非數值歸零。原始上限計算誤將資料欄陣列傳入 `Math.max`，通常得到 `NaN` 而不會在此階段限縮；實際插入時再分別以標題列及資料列長度限制於末端。
    - `config.autoCheckBox.doNotRowSpan`: [Boolean|Function = false] - 是否停用自動跨越所有標題列與資料列。
    - `config.autoCheckBox.rowSpan`: [Number|String = 1] - `doNotRowSpan` 啟用時的列跨距，最大值限制為矩陣列數。
    - `config.autoCheckBox.colSpan`: [Number|String = 1] - `doNotRowSpan` 啟用時的欄跨距。
    - `config.autoCheckBox.withoutGroup`: [Boolean|Function = false] - 未指定 `groupLevel` 或陣列 `groupKey` 時，使選取欄不參與群組合併。
    - `config.autoCheckBox.groupLevel`: [Number|String = undefined] - 選取欄參與的群組層級，優先於 `withoutGroup` 與 `groupKey`；三者皆未指定時有效層級為 `1`。
    - `config.autoCheckBox.groupKey`: [Array<String> = undefined] - 選取欄的群組依據欄位。
    - `config.autoCheckBox.attrs`: [Object = {}] - 套用至選取欄資料儲存格的 HTML 屬性；實作會覆寫 `rowSpan` 與 `colSpan`。
    - `config.autoCheckBox.displayRule`: [Boolean|Function = true] - 是否顯示各筆選取控制；函式簽章為 `displayRule(record, value, serialNo)`。
    - `config.autoCheckBox.genRule`: [Boolean|Function = true] - 是否為各筆紀錄建立選取控制；函式簽章為 `genRule(record, serialNo)`。判定為 `false` 時寫入狀態 `-99`。
    - `config.autoCheckBox.checkRule`: [Function = undefined] - 初始選取規則，簽章為 `checkRule(record, serialNo, currentChecked)`；第三參數依既有狀態為 `true`、`false` 或 `null`，回傳值依共通布林規則轉為狀態 `1` 或 `-1`。
    - `config.autoCheckBox.disableRule`: [Boolean|Function = false] - 是否停用各筆選取控制；函式簽章為 `disableRule(record, serialNo)`。
    - `config.autoCheckBox.highlight`: [Boolean|Function = false] - 選取時是否為對應資料列加入選取樣式。
  - `config.fixedColumns`: [Any = undefined] - 原始實作會接受此正確拼字，且在 `overDiv === false` 時改寫為 `false`，但不會用它建立初始固定欄。
  - `config.fixedColmuns`: [Any = undefined] - 舊拼字相容欄位；僅在 `fixedColumns === undefined` 時複製至 `fixedColumns`，本版仍不會用於初始固定欄。
  - `config.hiddenColumns`: [Any = undefined] - 原始實作會接受此正確拼字，但不會用它建立初始隱藏欄。
  - `config.hiddenColmuns`: [Any = undefined] - 舊拼字相容欄位；僅在 `hiddenColumns === undefined` 時複製至 `hiddenColumns`，本版仍不會用於初始隱藏欄。

- `config.column[]`／`config.headerColumn[]`: [Object] - 欄位定義。標題與資料矩陣共用同一來源，但不同階段讀取的欄位如下：
  - `key`: [String|Number = undefined] - 資料欄位鍵、儲存格 `name`、輸入控制鍵及預設排序鍵。
  - `header`: [Any|Function|Element = undefined] - 標題內容。
  - `attrs`: [Object] - 實際必填的 HTML 屬性物件。標題設定會先複製此值，再立即寫入 `name`；缺少、為 `null` 或不是可複製型別時會因對空值寫入屬性而拋出例外。`rowSpan`、`colSpan` 與 `pattern` 另有結構語意，`name` 會被覆寫為 `key`，標題的 `width`、`height` 與資料的 `height` 會被清除。
  - `styles`: [Object = {}] - 套用至資料儲存格的樣式；`attrs.align` 會轉存至 `styles.textAlign`。推導固定寬度後，寬度及空白處理屬性會自此物件移除。
  - `classes`／`className`: [Array<String>|String = []] - 資料儲存格類別；字串以空白切分，實作另加入 `type_<sortRule>`。
  - `sortable`: [Boolean|Function = config.allSortable] - 欄位是否提供排序；`empty` 已定義或遠端分批載入時一律停用。
  - `sortKey`: [String|Number = key] - 實際排序資料鍵。
  - `sortRule`: [String = "string"] - 同時作為比較規則及資料顯示型別；支援值請參照[代碼對照表](#代碼對照表)。
  - `fixedColumn`: [Boolean|Function = true] - 是否在欄位選單提供固定／解除固定功能；`overDiv === false` 時一律停用。
  - `hiddenColumn`: [Boolean|Function = true] - 是否在欄位選單提供隱藏功能。
  - `colGroup`: [Any = undefined] - 輸入值不作為最終群組編號；矩陣正規化時會依欄位置重新指定。
  - `rowSpan`／`colSpan`: [Number|String = attrs.rowSpan|attrs.colSpan|1] - 矩陣跨列與跨欄設定，會寫回 `attrs` 並建立對應的空白佔位。
  - `empty`: [Any = undefined] - 一旦定義即停用該標題的排序；資料矩陣正規化也會用於標示合併後的空白節點。
  - `groupKey`: [Number|String|Array<String>|Boolean = false] - 資料群組與儲存格合併規則；僅第一列且跨越完整資料矩陣高度的欄位可參與。數字表示群組層級，陣列表示群組鍵集合。
  - `ignoreGroup`: [Boolean|Function = false] - 將目前欄位鍵排除於群組比對集合。
  - `whenDataNull`: [String|Number|Boolean = config.whenDataNull] - 此欄位空值的替代顯示。
  - `defaultValue`: [String|Number|Boolean = null] - 僅當紀錄原值為 falsy 且不等於數字 `0` 或空字串，並且本設定本身為 truthy 時採用，結果會寫回紀錄；因此 `false`、`0` 與空字串不能作為有效預設值。原始條件誤檢查 `matrix_node` 本身是否為函式，因此傳入函式型 `defaultValue` 不會保留或執行。
  - `render`: [Function = undefined] - 自訂輸出函式，完整簽章為 `render(record, value, serialNo, key)`；回傳值作為儲存格內容。合計與小計是否呼叫由 `renderInCount` 控制。
  - `renderInCount`: [Boolean = config.allRenderInCount|false] - 合計與小計是否執行 `render`；設為 `false` 時仍依 `sortRule` 格式化。
  - `pattern`: [String = undefined] - 格式樣式；`attrs.pattern` 優先，此值其次，並可能傳遞至 `input.attrs.pattern`。
  - `format`: [Object = undefined] - `sortRule="number"` 的業務格式設定：`type` 支援 `IM`、`RC`、`RZ`，`kind` 預設 `AMT`，`code` 可直接給代碼，或以 `key` 指定從紀錄讀取代碼的欄位。
  - `staticWidth`／`width`: [Number|String|Boolean = false] - 固定像素寬度；優先採 `staticWidth`，其次 `width`、`attrs.width`、`styles.width` 或 `styles.maxWidth` 中可解析的非百分比數字。
  - `input`: [Object|null = null] - 自動輸入設定；缺少非空 `type` 時設為 `null`。完整欄位如下：
    - `input.type`: [String] - 控制種類，支援值與行為請參照[代碼對照表](#代碼對照表)。
    - `input.attrs`: [Object = {}] - HTML 屬性；`type`、`name` 與 `key` 由元件保留，`pattern` 可控制日期或數值格式。
    - `input.pattern`: [String = undefined] - 舊式格式樣式；`input.attrs.pattern` 不存在時轉存至該屬性，並將本欄位設為 `null`。若兩者皆未提供，會再沿用欄位的 `pattern`。
    - `input.styles`: [Object = {}] - 輸入控制的行內樣式。
    - `input.className`: [String|Array<String> = undefined] - 輸入控制類別；字串於初始化時以空白切分。
    - `input.events`: [Object<String, Function> = {}] - 原生事件處理函式。元件會直接註冊非保留事件；`text`、`date`、`rocdate`、`textarea`、`select` 的 `change`、`number` 的 `blur`，以及 `checkbox`、`radio`、`button` 的 `click` 會被內建同步處理保留。原始內建處理器誤讀不存在的 `col_setting.events`，因此同名使用者事件既不另行註冊，也不會於同步後執行。
    - `input.keyPress`: [Function = undefined] - 舊式 `keypress` 設定；若為函式會移入 `events.keypress`，之後將本欄位設為 `null`。
    - `input.maxlength`: [Number|String = undefined] - 舊式長度設定；正數時轉存至 `attrs.maxlength`。若未提供有效 `size`，另將 `attrs.size` 設為 `maxlength + 2`。
    - `input.size`: [Number|String = undefined] - 舊式顯示寬度；正數時轉存至 `attrs.size`。正規化後本欄位設為 `null`。
    - `input.disableRule`: [Boolean|Function = false] - 是否停用控制；函式簽章為 `disableRule(record, value, serialNo, key)`。
    - `input.readOnlyRule`: [Boolean|Function = false] - 是否唯讀；函式簽章同 `disableRule`。對 `select`、`checkbox`、`radio` 與 `button` 以 `disabled` 實作。
    - `input.genRule`: [Boolean|Function = true] - 是否在初始狀態顯示輸入區；函式簽章為 `genRule(record, value, serialNo)`。`easyEdit` 啟用時初始仍顯示文字區。
    - `input.easyEdit`: [Boolean|Function = false] - 是否以點擊文字進入編輯、確認後關閉輸入；函式簽章為 `easyEdit(record, value, serialNo, key)`。
    - `input.action`: [Function = undefined] - 值同步後的業務回呼。文字、數值、日期、文字區、下拉選單與按鈕呼叫為 `action.call(control, control, records, displayNode, previousValue, true)`；核取方塊與目前點擊的單選控制固定以第五、六參數皆為 `true` 呼叫，前一個被取消的單選控制則以第五參數 `false`、第六參數 `true` 呼叫。
    - `input.startAction`: [Function = undefined] - 控制建立後呼叫為 `startAction(control, [record], displayNode, value, false)`。
    - `input.actionWhenStart`: [Boolean|Function = false] - 未提供 `startAction` 時，是否以 `action` 作為建立後回呼；函式簽章為 `actionWhenStart(record, value, serialNo, key)`。
    - `input.followText`／`input.text`: [Any|Function = undefined] - 控制後方文字；函式簽章為 `followText(record, value, serialNo, key)`，`followText` 優先。
    - `input.opts_before`／`input.opts`／`input.opts_after`: [Object|Array<Object> = undefined] - `select` 的選項來源，依此前、中、後順序建立。`checkbox` 與 `radio` 只讀取 `opts`，並以其可列舉屬性名稱作為選項值、屬性值作為顯示內容。
    - `input.optionKey`: [String|Boolean = "key"] - 選項值欄位；選項來源為物件時設為 `true` 可交換鍵和值。
    - `input.optionValue`: [String|Function = "value"] - 選項顯示欄位或轉換函式。初始化 `input.opts` 陣列時先以 `optionValue(optionKeyValue, optionRecord)` 呼叫並改寫選項；實際建立 `select` 選項時，函式又以 `optionValue(optionRecord, optionKeyValue)` 呼叫。`opts_before` 與 `opts_after` 不經前一階段。
    - `input.isChangeAll`: [Boolean|Function = false] - 無選項來源的 `checkbox`／`radio` 是否讓同欄控制共用名稱；函式簽章為 `isChangeAll(record, value, serialNo)`。
    - `input.button_display_text`／`input.button_text`: [Any = undefined] - 按鈕標籤，依此前後順序取值，再退回欄位轉譯結果與跟隨文字。
    - `input.cols`／`input.rows`: [Number|String = undefined] - `textarea` 的欄數與列數。
    - `input.shortTextLength`: [Number|String = undefined] - `textarea` 與 `show` 類型摘要的位元組近似長度；非 ASCII 字元以兩個單位計算。
    - `input.clickText`: [String|Number|Boolean = undefined] - `textarea` 的 `easyEdit` 模式在內容為空時顯示的提示文字。
    - `input.lengthLimit`: [Object = undefined] - `textarea` 與外部 `InputUtility.lengthLimit` 整合；包含 `length`、`countByByte` 與 `customMsg`。

### 輸出

- `return`: [TableUI] - 由 `new` 運算子建立的實例。即使設定無效而建構函式提前 `return`，JavaScript 仍回傳部分初始化的物件；此物件不保證具有 `grid.*` 公開方法。
  - `return.isNew`: [Boolean = true] - 完成核心控制器建立後設定的版本識別旗標。
  - `return.getElement`: [Element] - 新建的表格最外層容器；名稱雖以 `get` 開頭，實際是元素屬性，不是函式。
  - `return.pageCtrl`: [Object] - 內部分頁控制器，包含 `loadPage`、`clearData` 等未全部直接映射至 `grid` 的方法。
  - `return.load`／`return.loadin`: [Function] - 依載入模式指向一般批次載入或遠端查詢函式。
  - `return.reload`／`return.reloadin`: [Function] - 依載入模式指向一般重建或遠端重新查詢函式。
  - `return.clear`: [Function] - 指向分頁控制器的 `clearData`。

### 對外功能

- 把既有表格轉換為可管理資料狀態與互動行為的表格元件，並依設定建立欄位、分頁、固定區域、隱藏欄位及選取控制。

### 副作用

- 以新建的表格容器取代原始表格，建立相關畫面節點、事件處理與全域尺寸偵測節點。
- 將 `config.table` 改寫為新建的表格容器，並把完成初始化的實例登錄至模組的全域表格對照表。
- 直接正規化或改寫部分輸入設定，包括相容拼字、`pageSize`、欄位 `attrs`／`styles`／`classes`、`input.attrs`、`input.events` 與舊式輸入欄位；呼叫端不可假設 `config` 維持原狀。
- 可能執行設定中的載入、換頁、渲染或驗證回呼，並依環境整合共通遮罩及上層視窗尺寸通知。
- 設定無效時可能顯示提示訊息、提前停止初始化或拋出初始化錯誤。
- 遠端分批載入每批筆數超過 `200` 時會降為 `200` 並顯示提示訊息。
- `autoCheckBox.type` 建立控制時不區分大小寫，但初始資料僅在值嚴格等於小寫 `"radio"` 時限制最多一筆狀態為已選取；使用 `"RADIO"` 可能建立單選控制卻保留多筆初始選取狀態。

---

## **`grid.load(input_records, total_count, subtotal_count, preCheckedValues)`** — 一般載入模式

### 用途

- 在一般載入模式一次載入完整資料集合與合計資訊。

### 輸入

- `input_records`: [Object|Array<Object>] - 要載入的一筆或多筆業務紀錄；每筆可包含 `config.column[].key` 對應的任意欄位。單一物件會轉為單元素陣列；空陣列或非支援型別會清空表格。
  - `input_records[]._tableuiSerialNumber`: [Number] - 保留欄位；載入時由元件依一為起點的資料順序覆寫。
  - `input_records[]._tableuiValidateStatus`: [Boolean] - 保留欄位；載入時依 `validateRecord` 覆寫，未設定規則時設為 `true`。
  - `input_records[]._tableuiAutoCheckBoxResult`: [Number] - 保留欄位；載入時依 `preCheckedValues` 重建或刪除。代碼請參照[代碼對照表](#代碼對照表)。
  - `input_records[].tRows`: [Array<Element>] - 保留欄位；呈現主表資料列時加入目前紀錄所建立的 `<tr>` 元素。
- `total_count`: [Object|Array<Object> = undefined] - 合計資料。一般物件會包裝為 `{ value: total_count }`；具有物件型 `value` 的物件或物件陣列則保留外層描述。
  - `total_count[].value`: [Object] - 以欄位鍵對應合計值；未提供時以外層物件本身為合計紀錄。
  - `total_count[].text`／`total_count[].header`: [Any = undefined] - 合計標題，`text` 優先。
  - `total_count[].value.tableui_headerKey`: [String = undefined] - 指定從合計紀錄的哪一欄取得標題；其次使用 `value.header`，再退回 `config.default_total_header`。
- `subtotal_count`: [Array<Object|Array<Object>> = undefined] - 小計資料；巢狀陣列會攤平，僅保留具有 truthy `key` 與物件型 `value` 的項目。
  - `subtotal_count[].key`: [String|Number|Boolean|Object] - 群組比對條件；單一群組鍵時可直接給比對值，多鍵群組時以物件提供各群組欄位及值。
  - `subtotal_count[].value`: [Object] - 以欄位鍵對應小計值。
  - `subtotal_count[].text`／`subtotal_count[].header`: [Any = undefined] - 小計標題；未提供時依合計相同規則退回 `config.default_subTotal_header`。
- `preCheckedValues`: [Array<Any> = undefined] - 依 `config.autoCheckBox.valueKey` 預先選取的值集合；使用字串化後的相等比較。

### 輸出

- 無

### 對外功能

- 清除既有內容後載入一批資料，建立合計、小計、驗證與預先勾選狀態，再依分頁及群組設定呈現資料。此名稱與 `grid.loadin(...)` 指向同一能力。

### 副作用

- 重設既有資料、刪除紀錄、分頁、排序、驗證與勾選狀態，並重建表格內容及頁面資訊。
- 輸入資料會先被複製；後續狀態變更作用於內部副本。
- 可能執行載入、換頁、格式化與渲染回呼。

---

## **`grid.load(ajax_url, input_rules, successFunc, failFunc, fetchSuccessFunc, fetchFailFunc)`** — 遠端分批載入模式

### 用途

- 建立遠端查詢條件並載入第一批資料。

### 輸入

- `ajax_url`: [String] - 遠端查詢端點；非字串會使實際請求程序停止。
- `input_rules`: [Object] - 必填的查詢條件物件；會序列化為字串並放入請求欄位 `param`。缺少或不是純物件時清空表格且不發出請求。
- `successFunc`: [Function = undefined] - 第一次查詢成功時呼叫為 `successFunc(response)`。
- `failFunc`: [Function = undefined] - 第一次查詢失敗或缺少必要回應資料時呼叫為 `failFunc(response)`。
- `fetchSuccessFunc`: [Function = undefined] - 後續分批查詢成功時呼叫為 `fetchSuccessFunc(response)`。
- `fetchFailFunc`: [Function = undefined] - 後續分批查詢失敗時呼叫為 `fetchFailFunc(response)`。
- `response`: [Object] - 遠端服務回應契約。
  - `response.totalOfRecords`: [Number|String] - 第一次查詢必填的總筆數；無法解析為數字時視為失敗。
  - `response.records`: [Array<Object>] - 必填且不得為空的本批紀錄。
  - `response.totalCountOfRecords`: [Array<Object>|Object = undefined] - 選用的合計資料，交由合計列呈現程序處理。
  - `response.ErrMsg.returnCode`: [Number|String] - 未提供 `CSRUtil.isSuccess` 時的成功判斷碼；可解析為大於或等於零的數字表示成功。

### 輸出

- `return`: [undefined] - 原始函式沒有明確回傳值；查詢結果透過畫面狀態與回呼提供。

### 對外功能

- 將查詢條件序列化，依 `config.isLoadByFatch` 決定的批次大小送出 POST 請求，並以回應的總筆數、紀錄與合計資料建立分頁內容。

### 副作用

- 清除既有資料、前後批次快取、分頁與查詢狀態，再更新遠端查詢端點與條件。
- 依環境使用 Prototype `Ajax.Request`、jQuery `ajax` 或原生 `XMLHttpRequest` 發出 POST 請求；請求欄位包含 `param`、拼字固定為 `loadStrat` 的起始位置、`loadEnd` 與 `isFirstQuery`。
- 可能顯示回應缺少總筆數、紀錄或 AJAX 處理失敗的提示訊息，並執行載入、換頁、驗證與成功／失敗回呼。

---

## **`grid.getCheckedRecord(template, includeDisabled)`** — 一般載入模式

### 用途

- 取得符合選取條件的紀錄或欄位投影。

### 輸入

- `template`: [String|Array<String> = undefined] - 要回傳的單一欄位名稱或欄位名稱集合；未提供時回傳完整紀錄，亦可能採用表格預設選取模板。
- `includeDisabled`: [Boolean = false] - 是否納入已勾選但不可操作的紀錄。

### 輸出

- `return`: [Array] - 符合勾選條件的紀錄、欄位值或欄位投影物件。

### 對外功能

- 取得目前已勾選的資料，並可依模板縮減回傳欄位。此名稱是 `grid.getCheckedRecords(...)` 的別名。

### 副作用

- 無

---

## **`grid.getCheckedRecord(template, includeDisabled)`** — 遠端分批載入模式

### 用途

- 表示遠端分批載入模式不提供已選取資料查詢。

### 輸入

- `template`: [Any = undefined] - 不讀取。
- `includeDisabled`: [Any = undefined] - 不讀取。

### 輸出

- `return`: [Array] - 固定為空陣列。

### 對外功能

- 此別名綁定遠端分頁控制器的空陣列函式，不檢查目前批次的選取狀態。

### 副作用

- 無

---

## **`grid.getAllRecords(template)`** — 一般載入模式

### 用途

- 取得表格持有的全部可用紀錄或欄位投影。

### 輸入

- `template`: [String|Array<String> = undefined] - 要回傳的單一欄位名稱或欄位名稱集合。

### 輸出

- `return`: [Array] - 全部紀錄、欄位值或欄位投影物件；尚未載入資料時為空陣列。

### 對外功能

- 取得表格目前持有的全部資料，並可依模板只回傳指定欄位。

### 副作用

- 一般模式回傳的完整紀錄是內部資料參照，呼叫端後續修改可能改變表格狀態。

---

## **`grid.getAllRecords(template)`** — 遠端分批載入模式

### 用途

- 取得目前遠端批次快取中的紀錄；此能力不代表取得遠端全量資料。

### 輸入

- `template`: [String|Array<String> = undefined] - 目前批次的欄位投影模板，規則請參照[代碼對照表](#代碼對照表)。

### 輸出

- `return`: [Array] - `window.tableUI_getFatchRecords === true` 時回傳目前批次紀錄或其投影，否則回傳空陣列。

### 對外功能

- 僅在全域旗標 `window.tableUI_getFatchRecords` 為 `true` 時開放目前快取批次；建立任何啟用自動選取欄的遠端表格會將此全域旗標設為 `true`。

### 副作用

- 全域旗標未啟用時顯示「分次查詢無法取得所有資料」提示訊息。

---

## **`grid.getXlsSettingJSON(sheetName)`**

### 用途

- 產生試算表匯出所需的欄位結構設定。

### 輸入

- `sheetName`: [String = undefined] - 匯出工作表名稱。

### 輸出

- `return`: [String] - 成功時為匯出設定的 JSON 字串；沒有可用序列化器或序列化失敗時為空字串。序列化前物件結構如下：
  - `return.sheetName`: [String|undefined] - 原樣保留的工作表名稱。
  - `return.titleSetting`: [Array<Array<Object>>] - 標題矩陣；自動選取欄會排除。
  - `return.recordSetting`: [Array<Array<Object>>] - 資料欄矩陣；自動選取欄會排除。
  - `return.titleSetting[][]`／`return.recordSetting[][]`: [Object] - 欄位匯出描述。
    - `key`: [String|Number] - 欄位鍵；矩陣佔位使用 `"N/A"`。
    - `header`: [Any = undefined] - 欄位標題；資料欄設定通常未保留此值。
    - `sortRule`: [String] - 標題採排序規則，資料欄採資料顯示型別；矩陣佔位使用 `"copy"`。
    - `groupKey`: [Array<String>] - 群組鍵集合；未形成群組時為空陣列。
    - `attrs`: [Object] - 正規化後的儲存格屬性。
  - `return.groupKeys`: [Array<String>|null] - 攤平所有群組層級後的欄位鍵，未設定群組時為 `null`。

### 對外功能

- 將表格目前的欄位結構整理為試算表匯出所需的設定描述；自動勾選欄不列入匯出欄位。

### 副作用

- 沒有 JSON 序列化器或序列化發生例外時顯示提示訊息。

---

## **`grid.getRecordsBySerialNo(getTemplate, recordTemplate)`** — 一般載入模式

### 用途

- 依表格配置的資料序號取得紀錄或欄位投影。

### 輸入

- `getTemplate`: [Number|String|Array<Number|String>] - 一個、逗號分隔或多個以一為起點的資料序號。
- `recordTemplate`: [String|Array<String> = undefined] - 要回傳的單一欄位名稱或欄位名稱集合。

### 輸出

- `return`: [Array] - 序號有效且存在的紀錄、欄位值或欄位投影物件。

### 對外功能

- 依表格資料序號取得對應紀錄，忽略格式錯誤或超出範圍的序號，並可投影指定欄位。

### 副作用

- 無

---

## **`grid.getRecordsBySerialNo(getTemplate, recordTemplate)`** — 遠端分批載入模式

### 用途

- 嘗試依序號取得目前遠端批次快取中的紀錄。

### 輸入

- `getTemplate`: [Number|String|Array<Number|String>] - 一個、逗號分隔或多個以一為起點的資料序號。
- `recordTemplate`: [String|Array<String> = undefined] - 欄位投影模板。

### 輸出

- `return`: [Array] - 位於目前批次範圍內且成功迭代的紀錄投影。

### 對外功能

- 只允許讀取目前批次快取。原始迴圈條件誤寫為 `i < getTemplate` 而非 `i < getTemplate.length`：單一元素陣列可因型別轉換而迭代，多元素陣列通常轉為 `NaN` 並直接回傳空陣列。

### 副作用

- 對成功迭代但超出目前快取範圍的序號，預設顯示資料已不在暫存範圍的提示訊息；此公開簽章沒有第三個 `dataExpireAlert` 參數可抑制提示。

---

## **`grid.addRecords(input_records, autoCheckStatus)`** — 一般載入模式

### 用途

- 在一般且無群組的載入模式附加一筆或多筆紀錄。

### 輸入

- `input_records`: [Object|Array<Object>] - 要加入的一筆或多筆資料紀錄。
- `autoCheckStatus`: [Boolean = false] - 在啟用自動勾選時，是否將新增紀錄預設為已勾選。

### 輸出

- 無

### 對外功能

- 將資料副本附加至現有資料集合，重新計算頁面並將檢視移至資料末端；群組模式不支援此操作。

### 副作用

- 改變表格資料、序號、頁數、勾選狀態與畫面內容。
- 可能執行載入、換頁與版面捲動相關行為。

---

## **`grid.addRecords()`** — 遠端分批載入模式

### 用途

- 明確拒絕直接新增遠端分批資料。

### 輸入

- 無

### 輸出

- `return`: [undefined] - 原始函式沒有明確回傳值。

### 對外功能

- 不修改資料；即使呼叫端傳入參數，函式亦不讀取。

### 副作用

- 顯示分次查詢無法自行新增資料的提示訊息。

---

## **`grid.resetDivHeight(resizeReason)`**

### 用途

- 重新計算表格的顯示尺寸與捲動配置。

### 輸入

- `resizeReason`: [Any = undefined] - 呼叫來源或調整原因，僅供調整流程識別。

### 輸出

- 無

### 對外功能

- 依目前容器、資料內容、固定欄與高度限制重新計算表格顯示區域。此名稱與 `grid.resize(...)` 指向同一能力。

### 副作用

- 修改表格區域的寬度、高度、捲動方式、欄位位置與列高。
- 可能通知上層容器整體內容高度已變更。

---

## **`grid.getCheckedRecords(template, includeDisabled)`** — 一般載入模式

### 用途

- 取得符合選取條件的紀錄或欄位投影。

### 輸入

- `template`: [String|Array<String> = undefined] - 要回傳的單一欄位名稱或欄位名稱集合；亦可能採用表格預設選取模板。
- `includeDisabled`: [Boolean = false] - 是否納入已勾選但不可操作的紀錄。

### 輸出

- `return`: [Array] - 符合勾選條件的紀錄、欄位值或欄位投影物件。

### 對外功能

- 取得表格中目前已勾選的資料，並可依模板縮減回傳內容。

### 副作用

- 無

---

## **`grid.getCheckedRecords(template, includeDisabled)`** — 遠端分批載入模式

### 用途

- 表示遠端分批載入模式不提供已選取資料查詢。

### 輸入

- `template`: [Any = undefined] - 不讀取。
- `includeDisabled`: [Any = undefined] - 不讀取。

### 輸出

- `return`: [Array] - 固定為空陣列。

### 對外功能

- 遠端分頁控制器將此名稱直接綁定空陣列函式。

### 副作用

- 無

---

## **`grid.deleteRecords(del_records)`** — 一般載入模式

### 用途

- 從一般載入模式移除指定紀錄。

### 輸入

- `del_records`: [Object|Array<Object>] - 要刪除的紀錄參照；須與表格內部持有的紀錄相同。

### 輸出

- 無

### 對外功能

- 從目前資料集合移除指定紀錄並保留於已刪除集合，之後重新建立群組、分頁及畫面。

### 副作用

- `del_records` 為陣列時直接消耗呼叫端陣列，逐筆移除其中已匹配的項目；單一物件會先包裝為新的陣列。
- 改變表格資料、已刪除集合、分頁與畫面內容。
- 若傳入紀錄不存在於表格中，原始迴圈不會結束。

---

## **`grid.deleteRecords()`** — 遠端分批載入模式

### 用途

- 明確拒絕直接刪除遠端分批資料。

### 輸入

- 無

### 輸出

- `return`: [undefined] - 原始函式沒有明確回傳值。

### 對外功能

- 不修改資料；即使呼叫端傳入參數，函式亦不讀取。

### 副作用

- 顯示分次查詢無法自行刪除資料的提示訊息。

---

## **`grid.show()`**

### 用途

- 顯示表格元件並更新版面。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 顯示表格元件並立即依可用空間重新調整版面。

### 副作用

- 修改表格容器的顯示狀態、尺寸與捲動配置。

---

## **`grid.setValueToTD(TR, target_name, value)`**

### 用途

- 更新指定畫面列的資料欄位與儲存格內容。

### 輸入

- `TR`: [Element] - 目標資料列或其內部節點；同一畫面列可能對應多筆群組資料。
- `target_name`: [String] - 要更新的欄位名稱。
- `value`: [Any] - 新欄位值。

### 輸出

- 無

### 對外功能

- 更新指定資料列對應紀錄的欄位值，並依欄位渲染規則重新產生對應儲存格內容。

### 副作用

- 修改一筆或多筆內部資料紀錄。
- 取代對應儲存格的顯示內容，可能執行欄位渲染回呼。
- 原始迴圈將 `target` 指派為未宣告變數；非嚴格模式下會覆寫同名全域變數。

---

## **`grid.hide()`**

### 用途

- 隱藏整個表格元件。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 隱藏整個表格元件。

### 副作用

- 修改表格容器的顯示狀態。

---

## **`grid.getDataObj(td, dataExpireAlert)`**

### 用途

- 由表格內節點取得第一筆對應資料紀錄。

### 輸入

- `td`: [Element] - 位於目標資料列內的節點。
- `dataExpireAlert`: [Boolean = true] - 遠端分批載入模式下，資料不在目前範圍時是否提示。

### 輸出

- `return`: [Object|null] - 節點所對應的第一筆資料紀錄；無對應資料時為 `null`。

### 對外功能

- 依畫面節點的資料序號定位並取得第一筆原始資料紀錄。

### 副作用

- 遠端分批載入模式下，要求的資料不在目前載入範圍時可能顯示提示訊息。

---

## **`grid.getTableInfo(setPage, setSort)`**

### 用途

- 擷取可供後續還原的分頁、欄位與排序狀態。

### 輸入

- `setPage`: [Boolean = true] - 是否包含目前分頁資訊。
- `setSort`: [Boolean = true] - 是否在一般載入模式下包含目前排序規則。

### 輸出

- `return`: [Object] - 可供 `setTableInfo` 還原的狀態描述。
  - `return.pageNo`: [Number = undefined] - 一般模式且 `setPage !== false` 時的目前頁碼。
  - `return.thisAjaxRecordFrom`: [Number = undefined] - 遠端分批載入模式且 `setPage !== false` 時，目前頁對應的零起點資料位置。
  - `return.queryUrl`: [String|null = undefined] - 遠端分批載入模式且 `setPage !== false` 時的查詢端點。
  - `return.queryRules`: [String|null = undefined] - 遠端分批載入模式且 `setPage !== false` 時已序列化的查詢條件。
  - `return.fixedColumns`: [Array<Number>] - 目前固定的欄群組編號；即使 `setPage === false` 仍會提供。
  - `return.hiddenColumns`: [Array<Number>] - 目前隱藏的欄群組編號；即使 `setPage === false` 仍會提供。
  - `return.sortRecords`: [Array<Object> = undefined] - 一般模式且 `setSort !== false` 時的排序規則。
    - `return.sortRecords[].key`: [String|Number] - 排序資料鍵。
    - `return.sortRecords[].direction`: [Boolean] - `true` 為升冪，`false` 為降冪。
    - `return.sortRecords[].sortRule`: [String|undefined] - 比較規則，代碼請參照[代碼對照表](#代碼對照表)。

### 對外功能

- 擷取可用來還原表格操作狀態的資訊。

### 副作用

- `fixedColumns`、`hiddenColumns` 與一般模式的 `sortRecords` 直接引用內部陣列；呼叫端修改回傳陣列會改變內部狀態，但不會自動重繪畫面。

---

## **`grid.setTableInfo(info)`**

### 用途

- 套用先前擷取的分頁、欄位與排序狀態。

### 輸入

- `info`: [Object] - 先前取得或相容格式的狀態描述。
  - `info.pageNo`: [Number|String = undefined] - 一般模式的目標頁碼。
  - `info.thisAjaxRecordFrom`: [Number|String = 0] - 遠端分批載入模式的零起點資料位置。
  - `info.queryUrl`: [String] - 遠端分批載入模式必填的查詢端點；`queryRules` 亦為字串時才套用遠端狀態。
  - `info.queryRules`: [String] - 遠端分批載入模式必填的已序列化查詢條件。
  - `info.fixedColumns`: [Array<Number> = undefined] - 要套用的固定欄群組；僅非空陣列會取代現況，無法藉空陣列清除。
  - `info.hiddenColumns`: [Array<Number> = undefined] - 要套用的隱藏欄群組；僅非空陣列會取代現況，無法藉空陣列清除。
  - `info.sortRecords`: [Array<Object> = undefined] - 一般模式依陣列順序套用的排序規則。
    - `info.sortRecords[].key`: [String|Number] - 排序資料鍵。
    - `info.sortRecords[].direction`: [Boolean] - 排序方向。
    - `info.sortRecords[].sortRule`: [String = undefined] - 比較規則。

### 輸出

- 無

### 對外功能

- 將指定操作狀態套用至表格，恢復欄位顯示、排序與所在頁面。

### 副作用

- 可能重建欄位結構、重新排序全部資料、切換頁面並重繪表格。
- 套用多筆排序規則時會依序重載資料。
- 非空 `fixedColumns` 與 `hiddenColumns` 會直接成為內部陣列；呼叫端後續修改同一陣列可能改變內部狀態。

---

## **`grid.hasRecords()`**

### 用途

- 判定表格目前是否持有至少一筆紀錄。

### 輸入

- 無

### 輸出

- `return`: [Boolean|null] - 目前持有至少一筆資料時為 `true`；資料陣列存在但為空時為 `false`，尚未建立資料陣列時為 `null`。

### 對外功能

- 判定表格目前是否持有可用資料。

### 副作用

- 無

---

## **`grid.getThisRecordTD(TR, template)`**

### 用途

- 取得指定畫面列依欄位名稱整理的儲存格元素。

### 輸入

- `TR`: [Element] - 目標資料列或其內部節點。
- `template`: [String|Array<String> = undefined] - 要取得的單一欄位名稱或欄位名稱集合；未提供時取得全部欄位。

### 輸出

- `return`: [Array<Object<String, Element|Array<Element>>>] - 各對應紀錄的欄位名稱至儲存格元素對照；沒有資料序號時為空陣列，資料列結構異常時可能無回傳值。

### 對外功能

- 取得指定畫面列對應的儲存格元素，並依欄位名稱分組；同名欄位出現多次時以元素陣列表示。

### 副作用

- 無

---

## **`grid.validCheckedOnTable(includeDisabled)`** — 一般載入模式

### 用途

- 重新驗證資料並統計已選取紀錄的錯誤數。

### 輸入

- `includeDisabled`: [Boolean = false] - 是否納入已勾選但不可操作的紀錄。

### 輸出

- `return`: [Number|undefined] - 已勾選且驗證失敗的紀錄數；尚未載入資料時無回傳值。

### 對外功能

- 重新執行資料驗證，統計已勾選資料中的錯誤數量，並只對該範圍呈現錯誤狀態。

### 副作用

- 更新全部紀錄的驗證狀態及目前畫面上的錯誤樣式。
- 可能執行設定的驗證規則。

---

## **`grid.validCheckedOnTable(includeDisabled)`** — 遠端分批載入模式

### 用途

- 表示遠端分批載入模式未提供已選取資料的整表驗證。

### 輸入

- `includeDisabled`: [Any = undefined] - 不讀取。

### 輸出

- `return`: [undefined] - 建構式以空函式補上此成員。

### 對外功能

- 不執行驗證、不統計錯誤，亦不更新畫面樣式。

### 副作用

- 無

---

## **`grid.clear()`**

### 用途

- 清除表格的資料與載入狀態。

### 輸入

- 無

### 輸出

- 無

### 對外功能

- 清除表格目前的資料與分頁狀態。此名稱綁定內部分頁控制器的 `clearData()` 能力。

### 副作用

- 清除資料、刪除紀錄、合計、小計、分頁、選取與畫面列，並重設頁面資訊及全選控制。
- 遠端分批載入模式亦會清除查詢位置與查詢條件。

---

## **`grid.exchangeAutoInput(TR, template, isCloseInput)`**

### 用途

- 切換指定欄位的文字顯示區與自動輸入區。

### 輸入

- `TR`: [Element] - 目標資料列或其內部節點。
- `template`: [String|Array<String> = undefined] - 要切換的單一輸入欄位名稱或欄位名稱集合；未提供時處理全部自動輸入欄位。
- `isCloseInput`: [Boolean|null = null] - `true` 顯示文字並關閉輸入，`false` 顯示輸入；未明確指定時切換現況。

### 輸出

- 無

### 對外功能

- 切換指定資料列的自動輸入欄位與其文字呈現區塊。

### 副作用

- 修改輸入與文字區塊的顯示狀態。
- 完成後重新計算表格版面。

---

## **`grid.reload(preCheckedValues)`** — 一般載入模式

### 用途

- 以目前資料或既有遠端查詢重新建立表格內容。

### 輸入

- `preCheckedValues`: [Array = undefined] - 依自動勾選鍵重新指定已勾選資料的值集合。

### 輸出

- 無

### 對外功能

- 保留現有資料並重新建立目前頁面，同時重算預先勾選與驗證狀態。此名稱與 `grid.reloadin(...)` 指向同一能力。

### 副作用

- 重設資料的勾選及驗證狀態，重新編號、分頁並重繪表格。
- 可能執行載入、換頁、格式化與渲染回呼。

---

## **`grid.reload()`** — 遠端分批載入模式

### 用途

- 重新執行目前遠端頁面的既有查詢。

### 輸入

- 無

### 輸出

- `return`: [undefined] - 原始函式沒有明確回傳值。

### 對外功能

- 以 `(currentPage - 1) * pageSize` 作為起始位置重新查詢；此名稱與遠端模式的 `grid.reloadin()` 指向同一函式。

### 副作用

- 發出遠端 POST 請求，並可能重建目前頁面、合計、驗證狀態與執行後續分批成功／失敗回呼。

---

## **`grid.getAutoInput(TR, template)`**

### 用途

- 取得指定畫面列依欄位名稱整理的自動輸入元素。

### 輸入

- `TR`: [Element] - 目標資料列或其內部節點。
- `template`: [String|Array<String> = undefined] - 要取得的單一輸入欄位名稱或欄位名稱集合；未提供時取得全部自動輸入欄位。

### 輸出

- `return`: [Array<Object<String, Element|Array<Element>>>] - 各對應紀錄的欄位名稱至輸入元素對照；沒有資料序號時為空陣列，資料列結構異常時可能無回傳值。

### 對外功能

- 取得指定畫面列內由表格建立或管理的輸入控制，並依欄位名稱分組。

### 副作用

- 無

---

## **`grid.validTable()`** — 一般載入模式

### 用途

- 重新驗證全部資料並回報錯誤筆數。

### 輸入

- 無

### 輸出

- `return`: [Number|undefined] - 全部資料中驗證失敗的紀錄數；尚未載入資料時無回傳值。

### 對外功能

- 重新執行資料驗證，統計全表錯誤數量並在目前畫面呈現錯誤狀態。

### 副作用

- 更新全部紀錄的驗證狀態及目前畫面上的錯誤樣式。
- 可能執行設定的驗證規則。

---

## **`grid.validTable()`** — 遠端分批載入模式

### 用途

- 表示遠端分批載入模式未提供完整資料集驗證。

### 輸入

- 無

### 輸出

- `return`: [undefined] - 建構式以空函式補上此成員。

### 對外功能

- 不執行驗證、不統計錯誤，亦不更新畫面樣式。

### 副作用

- 無

---

## **`grid.setThisAutoCheckBox(td, checkStatus)`**

### 用途

- 設定指定畫面列的自動選取控制狀態。

### 輸入

- `td`: [Element] - 位於目標資料列內的節點。
- `checkStatus`: [Any] - 期望的勾選狀態，依寬鬆相等規則與目前狀態比較。

### 輸出

- 無

### 對外功能

- 定位指定資料列的自動選取控制，並在狀態不同時套用新狀態。

### 副作用

- 修改選取控制與對應資料紀錄的勾選狀態。
- 執行單筆勾選的樣式、全選狀態及相關回呼處理。

---

## **`grid.sort(key, isIncrease, sortRule)`** — 一般載入模式

### 用途

- 依指定欄位、方向與規則排序全部資料。

### 輸入

- `key`: [String|Number] - 排序欄位鍵值。
- `isIncrease`: [Boolean|String] - 明確布林值指定升冪或降冪；其他值依是否等於內部降冪標記推導方向。
- `sortRule`: [String = "string"] - 比較規則；支援值與退回行為請參照[代碼對照表](#代碼對照表)。

### 輸出

- 無

### 對外功能

- 依指定欄位、方向與比較規則排序全部資料，並保留排序狀態供後續還原。

### 副作用

- 原地重排資料集合，重新載入目前表格並更新欄位排序樣式。
- 可能執行載入、換頁、格式化與渲染回呼。

---

## **`grid.sort(key, isIncrease, sortRule)`** — 遠端分批載入模式

### 用途

- 說明對遠端分批資料呼叫用戶端排序時的受限行為。

### 輸入

- `key`: [String|Number] - 排序資料鍵。
- `isIncrease`: [Boolean|String] - 排序方向，解析規則同一般載入模式。
- `sortRule`: [String = "string"] - 比較規則，請參照[代碼對照表](#代碼對照表)。

### 輸出

- `return`: [undefined] - 原始函式沒有明確回傳值。

### 對外功能

- 此入口仍會呼叫用戶端排序程序，但無法取得或排序遠端完整資料集；全域旗標允許時最多排序目前快取批次，且遠端 `reLoadin` 實際只會重新查詢目前頁。

### 副作用

- 可能顯示無法取得全量資料的提示、改寫目前批次順序與排序狀態，並重新發出目前頁的遠端請求。
- 不得將此操作視為遠端資料集的正式排序契約。

---

## **`grid.getCheckedErrorRecords(template, includeDisabled)`** — 一般載入模式

### 用途

- 取得同時符合已選取與驗證失敗條件的紀錄。

### 輸入

- `template`: [String|Array<String> = undefined] - 要回傳的單一欄位名稱或欄位名稱集合；亦可能採用表格預設選取模板。
- `includeDisabled`: [Boolean = false] - 是否納入已勾選但不可操作的紀錄。

### 輸出

- `return`: [Array] - 同時為已勾選及驗證失敗的紀錄、欄位值或欄位投影物件。

### 對外功能

- 取得目前已勾選且驗證狀態為失敗的資料，並可依模板縮減回傳內容。

### 副作用

- 無

---

## **`grid.getCheckedErrorRecords(template, includeDisabled)`** — 遠端分批載入模式

### 用途

- 表示遠端分批載入模式不提供已選取且驗證失敗的資料查詢。

### 輸入

- `template`: [Any = undefined] - 不讀取。
- `includeDisabled`: [Any = undefined] - 不讀取。

### 輸出

- `return`: [Array] - 固定為空陣列。

### 對外功能

- 遠端分頁控制器將此名稱直接綁定空陣列函式。

### 副作用

- 無

---

## **`grid.setValueToAutoInput(TR, target_name, value)`**

### 用途

- 透過自動輸入控制更新指定資料欄位。

### 輸入

- `TR`: [Element] - 目標資料列或其內部節點。
- `target_name`: [String] - 要更新的自動輸入欄位名稱。
- `value`: [Any] - 要套用的值或選取狀態。

### 輸出

- 無

### 對外功能

- 依控制種類將值套用至指定自動輸入欄位；若該欄位沒有自動輸入控制，改為更新一般儲存格及資料紀錄。

### 副作用

- 修改輸入值、勾選狀態或文字內容；按鈕型控制會直接執行其動作。
- 可能觸發點擊、變更、焦點取得與焦點離開事件，進而執行資料同步及業務回呼。
- 隱藏中的輸入控制不會被更新。
- 原始外層迴圈將 `t` 作為未宣告變數；非嚴格模式下會覆寫同名全域變數。

---

## **`grid.setAnotherCheckBox(findValue, check_status)`**

### 用途

- 依自動選取鍵值設定目前畫面中的選取控制。

### 輸入

- `findValue`: [String] - 要比對的自動勾選鍵值。
- `check_status`: [Any] - 期望的勾選狀態，依共通布林轉換規則判定。

### 輸出

- 無

### 對外功能

- 依設定的自動勾選鍵，在目前呈現的資料列中尋找指定值並更新其勾選狀態。此名稱是依值設定自動勾選能力的別名。

### 副作用

- 修改符合項目的選取控制與資料紀錄狀態。
- 執行單筆勾選的樣式、全選狀態及相關回呼處理。

---

## **`grid.checkAll(isChecked)`**

### 用途

- 統一設定所有可操作紀錄的選取狀態。

### 輸入

- `isChecked`: [Boolean = 全選控制目前狀態] - 全部可操作紀錄的目標狀態；僅明確的 `true` 或 `false` 直接採用，其他值會讀取全選控制的 `checked`。

### 輸出

- 無

### 對外功能

- 統一設定所有可操作資料的勾選狀態；不可操作或未建立選取控制的紀錄不變。

### 副作用

- 修改全部可操作紀錄的選取狀態、目前畫面上的選取控制及資料列樣式。
- 重新計算全選控制的顯示狀態。
- 未建立全選控制且 `isChecked` 不是明確布林值時，讀取空值的 `checked` 會拋出例外。
- 遠端分批載入模式只處理目前快取批次與目前畫面上的控制，不代表選取遠端完整資料集。

---

## **`grid.isAutoCheckBoxSelected(td)`**

### 用途

- 判定指定畫面列是否處於已選取狀態。

### 輸入

- `td`: [Element] - 位於目標資料列內的節點。

### 輸出

- `return`: [Boolean] - 第一筆對應紀錄的自動選取狀態碼大於或等於零時為 `true`；無對應資料時為 `false`。狀態碼請參照[代碼對照表](#代碼對照表)。

### 對外功能

- 判定指定資料列的第一筆紀錄是否處於原始實作定義的「已選取」狀態；其中不可操作但已選取的狀態亦視為已選取。

### 副作用

- 無

---

## **`grid.loadin(input_records, total_count, subtotal_count, preCheckedValues)`** — 一般載入模式

### 用途

- 在一般載入模式一次載入完整資料集合與合計資訊。

### 輸入

- `input_records`: [Object|Array<Object>] - 一筆或多筆業務紀錄；物件欄位、保留欄位與正規化行為同 `grid.load(input_records, total_count, subtotal_count, preCheckedValues)` 的一般載入模式。
- `total_count`: [Object|Array<Object> = undefined] - 合計描述；支援 `{ value, text, header }`，其中 `value` 為欄位鍵至合計值的物件。
- `subtotal_count`: [Array<Object|Array<Object>> = undefined] - 小計描述；每項須有 `key` 群組條件與物件型 `value`，可另提供 `text` 或 `header`。
- `preCheckedValues`: [Array<Any> = undefined] - 依 `config.autoCheckBox.valueKey` 預先選取的值集合。

### 輸出

- 無

### 對外功能

- 清除既有內容後載入一批資料，建立合計、小計、驗證與預先勾選狀態，再依分頁及群組設定呈現資料。此名稱與 `grid.load(...)` 指向同一能力。

### 副作用

- 重設既有資料、刪除紀錄、分頁、排序、驗證與勾選狀態，並重建表格內容及頁面資訊。
- 輸入資料會先被複製；後續狀態變更作用於內部副本。

---

## **`grid.loadin(ajax_url, input_rules, successFunc, failFunc, fetchSuccessFunc, fetchFailFunc)`** — 遠端分批載入模式

### 用途

- 以 `grid.load` 的別名建立遠端查詢並載入第一批資料。

### 輸入

- `ajax_url`: [String] - 遠端查詢端點。
- `input_rules`: [Object] - 必填的查詢條件；序列化後放入請求欄位 `param`。
- `successFunc`: [Function = undefined] - 第一次查詢成功回呼 `successFunc(response)`。
- `failFunc`: [Function = undefined] - 第一次查詢失敗回呼 `failFunc(response)`。
- `fetchSuccessFunc`: [Function = undefined] - 後續分批查詢成功回呼 `fetchSuccessFunc(response)`。
- `fetchFailFunc`: [Function = undefined] - 後續分批查詢失敗回呼 `fetchFailFunc(response)`。
- `response`: [Object] - 回應須以 `totalOfRecords` 提供總筆數、以非空 `records` 陣列提供資料；可用 `totalCountOfRecords` 提供合計，未整合 `CSRUtil` 時以 `ErrMsg.returnCode >= 0` 判定成功。

### 輸出

- `return`: [undefined] - 原始函式沒有明確回傳值。

### 對外功能

- 此名稱與遠端模式的 `grid.load(ajax_url, input_rules, successFunc, failFunc, fetchSuccessFunc, fetchFailFunc)` 指向同一函式。

### 副作用

- 清除既有資料與查詢快取，儲存新查詢條件並發出 POST 請求。
- 可能更新分頁、合計、驗證與畫面內容，顯示錯誤提示並執行載入及查詢結果回呼。

---

## **`grid.loadPage(pageNO)`**

### 用途

- 記錄清單中未直接公開的換頁呼叫及其實際替代入口。

### 輸入

- `pageNO`: [Number|String] - 目標頁碼；可解析為數字，低於範圍時導向第一頁，高於範圍時導向最後一頁。

### 輸出

- `return`: [undefined] - 原始建構式未將此名稱直接發布於 `grid` 實例。

### 對外功能

- 使用清單中的直接呼叫名稱在原始實例上不可用；實際頁面切換能力的原始簽章為 `grid.pageCtrl.loadPage(pageNO)`。

### 副作用

- 直接執行 `grid.loadPage(...)` 會因成員不存在而失敗。
- 改由 `grid.pageCtrl.loadPage(...)` 執行時，會切換目標頁、重建資料列、更新頁面資訊與選取控制，且換頁前回呼可取消操作。

---

## **`grid.resize(resizeReason)`**

### 用途

- 重新計算表格的顯示尺寸與捲動配置。

### 輸入

- `resizeReason`: [Any = undefined] - 呼叫來源或調整原因，僅供調整流程識別。

### 輸出

- 無

### 對外功能

- 依目前容器、資料內容、固定欄與高度限制重新計算表格顯示區域。此名稱與 `grid.resetDivHeight(...)` 指向同一能力。

### 副作用

- 修改表格區域的寬度、高度、捲動方式、欄位位置與列高。
- 可能通知上層容器整體內容高度已變更。

---

## **`grid.clearData()`**

### 用途

- 記錄清單中未直接公開的清除呼叫及其實際替代入口。

### 輸入

- 無

### 輸出

- `return`: [undefined] - 原始建構式未將此名稱直接發布於 `grid` 實例。

### 對外功能

- 使用清單中的直接呼叫名稱在原始實例上不可用；實際清除能力的原始簽章為 `grid.pageCtrl.clearData()`，且建構式另以 `grid.clear()` 公開同一函式。

### 副作用

- 直接執行 `grid.clearData()` 會因成員不存在而失敗。
- 改由 `grid.clear()` 或 `grid.pageCtrl.clearData()` 執行時，會清除資料、分頁、合計、選取與畫面內容；遠端分批載入模式亦會清除查詢狀態。

---

## 代碼對照表

### 共通布林轉換

- 設定值可為布林或函式；函式會先以該設定指定的參數執行，再轉換其結果。
- 預設值為 `false` 時，僅嚴格等於 `true` 的結果會轉為 `true`，其他結果均為 `false`。
- 預設值為 `true` 時，僅嚴格等於 `false` 的結果會轉為 `false`，其他結果均為 `true`。
- 因此字串 `"true"`、`"false"`、數字 `1`、`0` 與一般 truthy／falsy 判斷不同，不應視為等價布林值。

### 紀錄投影模板

- `template` 為字串時，每筆只取該欄位的值；值為空字串、`null`、`undefined` 或其他 falsy 且不等於數字 `0` 時，該筆不加入回傳陣列。
- `template` 為字串陣列時，會直接由原陣列移除非字串項目，再為每筆建立只含指定欄位的新物件。
- `template` 不是字串或陣列時，回傳原紀錄物件參照；已選取資料的查詢若設定 `config.autoCheckBox.returnValue`，會改採該預設模板。

### 排序與顯示型別

- `string`: 預設型別。排序時以 JavaScript 字串關係比較；相等值仍回傳正排序值，排序穩定性取決於執行環境。
- `number`: 排序時將可解析數值轉為浮點數，其他值視為 `0`；顯示時使用 `localeDisplay.formatNumber`、業務格式器或 `CSRUtil.$fmt`。
- `date`: 排序時依 `isADdate` 與 `diffDay` 比較，無效日期以 `1900-01-01` 取代；顯示預設格式為 `yyyy-MM-dd`。
- `rocdate`: 排序行為與 `date` 相同；顯示預設採民國年格式 `yyyMMdd`。存在 `localeDisplay` 且沒有 `pattern` 時，原始程式不執行內建民國日期格式化。
- `datetime`: 不提供專用排序，會退回字串比較；顯示時有 `localeDisplay` 則呼叫 `formatTimestamp`，否則截取前十九個字元。
- `dateym`: 不提供專用排序；僅在有 `localeDisplay` 且沒有 `pattern` 時呼叫 `formatDateym`。
- `datey`: 不提供專用排序；僅在有 `localeDisplay` 且沒有 `pattern` 時呼叫 `formatDatey`。
- 其他值: 排序退回字串比較；顯示不套用專用格式。
- 排序方向的內部標記為 `◆`（未排序）、`▲`（升冪）與 `▼`（降冪）；`grid.sort` 的第二參數不是布林時，只有嚴格不等於 `▼` 才推導為升冪。

### 自動輸入類型

- `text`: 建立單行文字輸入；`change` 後同步紀錄與顯示值。
- `number`: 建立 `datatype="number"` 的文字輸入；`blur` 時將可解析值轉為浮點數，值確實變更後才同步。
- `date`: 建立 `datatype="date"` 的文字輸入；`change` 後同步紀錄，預設樣式為 `yyyy-MM-dd`。
- `rocdate`: 建立 `datatype="rocdate"` 的文字輸入；`change` 時若存在全域 `toY2K`，先轉為西元資料值再同步，預設顯示樣式為 `yyyMMdd`。
- `textarea`: 建立多行輸入，支援摘要、快速編輯與外部字數限制；`change` 後同步紀錄與摘要。
- `select`: 依 `opts_before`、`opts`、`opts_after` 建立選項；`change` 後同步選項值與顯示文字。
- `checkbox`: 有選項來源時可建立多個核取方塊並將選取值以逗號連接；無選項來源時以 `Y`／`N` 同步單一布林式欄位。
- `radio`: 有選項來源時建立單選集合；無選項來源時同樣以 `Y`／`N` 同步欄位，並依控制名稱維護前一個選項。
- `button`: 建立按鈕；點擊時不改寫紀錄，只執行 `input.action` 與使用者 `click` 事件。
- `show`: 不建立表單控制，而建立可互相切換的摘要與完整內容區。
- 其他值: 不建立自動輸入控制，直接以欄位轉譯結果呈現儲存格。

### 自動選取狀態

- `1`: 已選取且可操作。
- `0`: 已選取但不可操作；`includeDisabled === true` 時才納入已選取資料查詢。
- `-1`: 未選取且可操作。
- `-2`: 未選取且不可操作。
- `-99`: 此紀錄不建立選取控制。
- `grid.isAutoCheckBoxSelected` 以狀態是否大於或等於 `0` 判定，因此 `1` 與 `0` 均回傳 `true`。

### 頁次資訊模板

- `{nowPage}`: 目前頁碼。
- `{totalPage}`: 總頁數。
- `{totalRecord}`: 原始資料總筆數；群組模式不是群組數。
- `{totalGroup}`: 一般載入且啟用群組時的群組數；遠端分批載入模式不替換此標記。

### 數值業務格式

- `format.type="IM"`: 若存在 `ImFormat.doFormat`，呼叫 `ImFormat.doFormat(kind, code, value, true)`。
- `format.type="RC"`: 若存在 `rcFormat.doFormat`，呼叫 `rcFormat.doFormat(kind, code, value, true)`。
- `format.type="RZ"`: 若存在 `rzFormat.doFormat`，呼叫 `rzFormat.doFormat(code, value, true)`。
- `format.kind`: `IM` 與 `RC` 的格式種類，預設為 `AMT`。
- `format.code`: 直接指定業務格式代碼；空值時可由 `format.key` 指定的紀錄欄位取得。
