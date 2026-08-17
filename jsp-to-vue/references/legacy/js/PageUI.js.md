# PageUI.js 公開契約

> 原始資源：`/CM/js/ui/PageUI.js`

## **`PageUI.createPageWithAllBodySubElement(pageNO, title, subTitleText, fixedNum, noPageFrame)`**

### 用途

- 收集頁面主體中可見且具內容的既有區塊，建立標準頁面結構，將收集到的區塊移入內容區，並依指定數量劃分固定與可捲動區域。

### 輸入

- `pageNO`: [String] - 頁面識別編號。
- `title`: [String] - 頁面主標題。
- `subTitleText`: [String] - 頁面副標題。
- `fixedNum`: [Number|NumericString = undefined] - 保持在固定區域的前段內容區塊數量；數字 `0` 或未提供時不建立捲動區。字串 `"0"` 的原始行為不同，詳見 `PageUI.fixedContent`。
- `noPageFrame`: [Boolean = false] - 是否省略標準頁面外框。

### 輸出

- 無

### 對外功能

- 收集頁面主體中可見且具內容的既有區塊，建立標準頁面結構，將收集到的區塊移入內容區，並依指定數量劃分固定與可捲動區域。

### 副作用

- 重設所有表單的外距、頁面標題及頁面主體結構。
- 搬移既有內容節點，排除指令、樣式、資源連結、隱藏及空白節點。
- 建立頁面框架、內容容器與可能的可捲動區域，並立即重新計算版面尺寸。

---

## **`PageUI.resize(uncheckDocumentResize)`**

### 用途

- 依目前可用顯示高度調整主頁面及可捲動內容區的尺寸。

### 輸入

- `uncheckDocumentResize`: [Boolean = false] - 是否略過既有高度比對並強制重新計算。

### 輸出

- 無

### 對外功能

- 依目前可用顯示高度調整主頁面及可捲動內容區的尺寸。

### 副作用

- 改變頁面框架及可捲動內容區的顯示高度，並盡量保留原捲動位置。
- 未要求強制重算時，將本次頁面高度保存於頁面主體供後續比對。

---

## **`PageUI.createPage(pageNO, title, subTitleText, noPageFrame)`**

### 用途

- 建立供後續內容載入使用的標準頁面框架、標題區與內容區；可選擇只建立無外框的內容承載結構。

### 輸入

- `pageNO`: [String] - 頁面識別編號。
- `title`: [String] - 頁面主標題。
- `subTitleText`: [String] - 頁面副標題內容。
- `noPageFrame`: [Boolean = false] - 僅嚴格等於 `true` 時省略外層標準框線與頁面主標題列；內容區的副標題列仍會建立。

### 輸出

- 無

### 對外功能

- 建立供後續內容載入使用的標準頁面框架、標題區與內容區；可選擇只建立無外框的內容承載結構。

### 副作用

- 將所有既有表單的外距設為零，並將 `document.title` 改為 `{title} - {subTitleText} ({pageNO})`。
- 將新頁面框架插入頁面主體最前方，保存框架、內容區與副標題參照。
- 以副標題內容直接更新標題區，並立即調整頁面高度。

---

## **`PageUI.loadin(loadinConfigs, fixedNum)`**

### 用途

- 將指定既有內容包裝成一致的區塊結構，加入目前頁面的內容區，並依指定數量劃分固定與可捲動區域。

### 輸入

- `loadinConfigs`: [Object|String|HTMLElement|Array<Object|String|HTMLElement>] - 一個或多個待載入區塊。字串與元素會正規化為 `{ elem: value }`；物件結構如下：
  - `elem`: [String|HTMLElement] - 必要。來源元素或其 `id`／`name`；名稱符合多個元素時取第一個。
  - `id`: [Any = undefined] - 寫入區塊容器 `contentId` 屬性的值；原始實作未限制型別。
  - `title`: [String|Number|Boolean = `elem` 的 `blockTitle` 屬性] - 區塊標題。雖然原始註解宣稱可傳入元素，但實作只在此值為基本型別時建立標題列，元素不會生效。
  - `position`: [Number = undefined] - 區塊在內容片段中的插入索引；未提供時附加於末端。原始插入分支存在已知錯誤，詳見「副作用」。
- `fixedNum`: [Number|NumericString = undefined] - 前段固定顯示的區塊數；數字 `0` 表示不建立捲動區。未提供或不符合十進位數值格式時不重新分區；字串 `"0"` 的原始行為詳見 `PageUI.fixedContent`。

### 輸出

- 無

### 對外功能

- 將指定既有內容包裝成一致的區塊結構，加入目前頁面的內容區，並依指定數量劃分固定與可捲動區域。

### 副作用

- 整體設定型別無效時會顯示錯誤訊息；個別設定無效或找不到 `elem` 時會略過。
- 搬移來源節點並建立區塊容器、標題與識別屬性。
- 目前項目會寫入未宣告的全域變數 `config`，可能覆蓋頁面上既有同名狀態。
- 重新組織內容區並觸發版面尺寸重算。
- `position` 為數值時會進入 `JsUtils.createDOMElement` 的索引插入分支；該分支引用未定義的 `parentChild`，因此會拋出錯誤，而不是完成指定位置插入。

---

## **`JsUtils.isNumeric(node)`**

### 用途

- 判定輸入是否可視為不含指數、千分位或前置正號的十進位整數或小數。

### 輸入

- `node`: [Any] - 待判定的值。

### 輸出

- `return`: [Boolean] - 值屬於基本型別且完整符合十進位數字格式時為 `true`，否則為 `false`。

### 對外功能

- 判定輸入是否可視為不含指數、千分位或前置正號的十進位整數或小數。

### 副作用

- 無

---

## **`JsUtils.getSimpleDateFormat(pattern, isROCtype)`**

### 用途

- 取得可重複使用的日期格式化能力；相同樣式與紀年規則會共用既有實例。

### 輸入

- `pattern`: [String] - 日期輸出樣式。
- `isROCtype`: [Boolean = false] - 是否採用民國紀年規則。

### 輸出

- `return`: [Object|Boolean = false] - 對應樣式與紀年規則的日期格式化能力；輸入無效或格式化能力不存在時為 `false`。

### 對外功能

- 取得可重複使用的日期格式化能力；相同樣式與紀年規則會共用既有實例。

### 副作用

- 首次取得特定組合時會建立實例並保存於內部快取。

---

## **`JsUtils.cloneObject(orgObject)`**

### 用途

- 依資料種類建立獨立複本；容器內容會逐層複製，介面節點會連同其後代一併複製。

### 輸入

- `orgObject`: [Any] - 待複製的值。

### 輸出

- `return`: [Any] - 陣列、一般資料物件及介面節點的遞迴複本；其他值原樣回傳。

### 對外功能

- 依資料種類建立獨立複本；容器內容會逐層複製，介面節點會連同其後代一併複製。

### 副作用

- 無

---

## **`PageUI.createContent(config, loadinValues, showType)`**

### 用途

- 依宣告式設定建立具標題、欄位、跨欄列、輸入與唯讀顯示能力的內容區，並初始化欄位資料與顯示模式。

### 輸入

- `config`: [Object] - 內容表格設定；完整結構如下：
  - `elem`: [String|HTMLElement] - 必要。承載內容的元素或其 `id`／`name`。若為 `TABLE`，直接附加新的 `TBODY`；否則建立 `TABLE` 後附加至該元素。
  - `contents`: [Array<ContentSetting>] - 必要。依序配置的業務欄位群組：
    - `ContentSetting.header`: [String|HTMLElement = undefined] - 標題儲存格內容；字串建立文字節點，元素會被搬移至標題儲存格。
    - `ContentSetting.colSpan`: [Number|NumericString = 1] - 此群組占用的資料欄數；超過當列剩餘欄數時會被截短。
    - `ContentSetting.rowSpan`: [Number|NumericString = 1] - 此群組占用的資料列數。
    - `ContentSetting.values`: [Array<String|Number|Boolean|HTMLElement|FieldSetting>] - 依序置入內容儲存格的靜態值、既有元素或欄位設定。基本值建立文字節點；元素會被搬移；`FieldSetting` 結構如下：
      - `id`: [String|Number|Boolean] - 欄位介面識別值。原始有效性判斷另要求真值；空字串、數字 `0`、`false` 不會單獨成立。若省略，須能由 `key` 與 `config.KeyToId` 推導。
      - `key`: [String|Number|Boolean] - 欄位在資料物件中的業務鍵。原始有效性判斷另要求真值。若省略，須能由 `id` 與 `config.IdToKey` 推導；轉換結果不是基本型別時回退為原 `id`。
      - `type`: [String = `""`] - 欄位種類，詳見[代碼對照表](#代碼對照表)。未知或空白種類建立靜態文字欄位。
      - `attrs`: [Object = `{}`] - 套用至主要輸入元素的屬性。實作會直接補寫 `id`、`name`、`inputTag`、`spanDistance`、`fieldName` 及種類專屬屬性。
      - `events`: [Object<String, Function> = `{}`] - 事件名稱至處理函式的對照；處理函式接收 `(event.srcElement, event)`。日期欄位未提供 `change` 時會補上日期正規化處理。
      - `getFunc`: [Function = undefined] - 自訂取值函式。一般欄位呼叫 `(element, currentValue, resultMap, isForDisplay)`；`dom` 呼叫 `(element, resultMap, isForDisplay)`。回傳值會成為該欄位結果。
      - `setFunc`: [Function = undefined] - 自訂設值函式。一般欄位呼叫 `(element, normalizedValue, sourceValue)`；`dom` 亦以相同三參數呼叫，但不使用回傳值。
      - `preOpts`: [Object|Array<Object> = undefined] - `select` 的前置選項資料；建立時先清除既有選項。
      - `opts`: [Object|Array<Object> = undefined] - `select` 的一般選項資料；附加於 `preOpts` 之後。
      - `optKey`: [String = undefined] - `preOpts`／`opts` 為陣列時，項目中作為選項值的鍵。
      - `optValueKey`: [String|Function = undefined] - `preOpts`／`opts` 的顯示值鍵，或 `(item, isArraySource)` 顯示值產生函式。
      - `attrs_s`、`attrs_e`: [Object = `attrs`] - `datebetween` 起日與迄日輸入的屬性；實作會補寫 `id`、`name`、`key`、`spanDistance`、`fieldName` 與預設 `datatype`。
      - `events_s`、`events_e`: [Object = `events`] - `datebetween` 起日與迄日輸入的事件對照。
      - `items`: [Object|Array<Object> = undefined] - `radio`／`checkbox` 選項資料。
      - `itemKey`: [String = undefined] - `items` 為陣列時，項目中作為選項值的鍵。
      - `itemValueKey`: [String|Function = undefined] - 選項顯示值鍵，或 `(item, isArraySource)` 顯示值產生函式。
      - `elem`: [String|HTMLElement|Function = undefined] - `dom` 欄位使用的既有元素、元素識別值，或回傳元素的無參數函式；元素會被搬移。
      - `text`: [String = `""`] - 未知或空白 `type` 使用的靜態文字。
  - `clearChildElements`: [Boolean = false] - 建立前是否清除承載元素的全部子節點。
  - `noHeader`: [Boolean = false] - 是否不建立標題儲存格。
  - `noContent`: [Boolean = false] - 是否不建立內容儲存格；與 `noHeader` 同為 `true` 時不建立任何內容。
  - `headerInTop`: [Boolean = false] - 是否將標題列置於內容列上方；否則標題與內容左右排列。
  - `dataColumns`: [Number|NumericString = 2] - 每列的業務資料欄數。
  - `columnProps`: [Array<Number|String> = 自動百分比] - 實際表格欄位寬度。數值加上 `%`；字串原樣設定。左右排列時每一業務欄預設拆為 `30%` 標題與 `70%` 內容。
  - `attrs`: [Object = `{}`] - 內容 `TABLE` 的屬性；實作會直接補寫 `cellPadding=0` 與 `cellSpacing=0`。
  - `className`: [String = undefined] - 額外加入內容 `TABLE` 的 CSS class。
  - `id`: [String = 自動產生的 `contentArea{n}`] - 新 `TBODY` 的識別值，也是讀寫與提交資料時的第一層鍵。
  - `IdToKey`: [Function = undefined] - `FieldSetting.key` 缺少時以 `(id)` 推導業務鍵。
  - `KeyToId`: [Function = undefined] - `FieldSetting.id` 缺少時以 `(key)` 推導介面識別值。
- `loadinValues`: [Object = undefined] - 建立後載入的初始欄位資料；其鍵需對應 `FieldSetting.key`，載入時會立即提交並清空缺值欄位。
- `showType`: [Number|NumericString = 1] - 初始顯示模式，詳見[代碼對照表](#代碼對照表)。只有符合數值格式時才採用輸入值，否則使用 `1`。

### 輸出

- `return`: [HTMLTableSectionElement|Undefined] - 建立完成且具有 `contentBody=true` 的 `TBODY`；設定無效、找不到 `elem`，或 `noHeader` 與 `noContent` 同為 `true` 時無回傳值。

### 對外功能

- 依宣告式設定建立具標題、欄位、跨欄列、輸入與唯讀顯示能力的內容區，並初始化欄位資料與顯示模式。

### 副作用

- 設定無效或找不到目標時顯示錯誤訊息。
- 可能清除目標既有子內容，建立或擴充內容表格；若原表格末列是按鈕列，會將該列搬至新內容主體之後。
- 直接改寫 `config.attrs`、各 `FieldSetting` 及其 `attrs`／`events`／起迄設定；保存 `getFunc`、`setFunc` 後會將原設定上的兩個屬性改為 `null`。
- 註冊內容與自訂取值／設值能力、保存初始紀錄，並可能觸發日期及數值的共通格式化流程。
- 呼叫顯示模式設定時會重新計算頁面尺寸。

---

## **`PageUI.createButtonArea(content, buttonConfig)`**

### 用途

- 依按鈕定義建立操作區，並依目標種類放置於欄位內、內容列右側、內容底部或一般容器中。

### 輸入

- `content`: [String|HTMLElement] - 按鈕區要附加至的內容欄位、內容主體或一般容器。
- `buttonConfig`: [Object] - 按鈕區設定；原始實作會在讀取前直接存取此參數，因此 `null`／`undefined` 會拋出錯誤。結構如下：
  - `buttons`: [Object<String, ButtonSetting>] - 必要。物件鍵為按鈕的業務代碼；各 `ButtonSetting` 包含：
    - `id`: [String = 按鈕業務代碼] - 按鈕元素識別值。
    - `header`: [Any = 按鈕業務代碼] - 寫入按鈕 `value` 的顯示內容；原始實作未限制型別。
    - `ignoreAuth`: [Any = false] - 真值表示不將此按鈕加入全域授權對照。
    - `attrs`: [Object = `{}`] - 按鈕元素屬性；實作會直接覆寫 `type="button"`、`value` 與 `id`。
    - `events`: [Object<String, Function> = undefined] - 事件名稱至處理函式的對照；處理函式接收 `(event.srcElement, event)`。
  - `changeForOneButton`: [Boolean = false] - 每個按鈕後是否加入換行元素。
  - `buttonOnRight`: [Boolean = false] - `content` 為內容主體時，是否將按鈕置於跨越全部內容列的右側儲存格；此時亦會強制逐鈕換行。
  - `clearChildElements`: [Boolean = false] - `content` 為一般容器時，加入按鈕區前是否清除既有子節點。

### 輸出

- `return`: [HTMLElement|Undefined] - 建立完成的按鈕區容器；設定或目標無效時無回傳值。

### 對外功能

- 依按鈕定義建立操作區；內容主體可將按鈕置於右側或底部，一般容器則直接附加按鈕區。欄位容器分支的原始實作存在名稱解析錯誤，詳見「副作用」。

### 副作用

- 建立按鈕、事件及配置結構，並以「按鈕業務代碼 → 元素 `id`」將非免授權按鈕登錄至 `window.authButtons`。
- 可能清除一般目標容器的既有內容，或改變內容表格的列與儲存格結構。
- 直接補寫按鈕設定中的屬性集合。
- `content` 為單一欄位容器時，實作呼叫未定義於 `PageUI` 作用域的 `getParentByTagName`，通常會在按鈕已建立且授權對照已更新後拋出錯誤，無法完成掛載。

---

## **`PageUI.getContentValues(content, isAutoCommit, alwaysKeepTwoLayerMap)`** — 單一內容主體的單層回傳用法

### 用途

- 取得單一內容主體的欄位資料，省略以內容主體識別值為鍵的外層物件。

### 輸入

- `content`: [String|HTMLElement] - 單一 `TBODY[contentBody]`，或只包含一個內容主體的 `TABLE.contentTable`。
- `isAutoCommit`: [Boolean = true] - 讀取前是否先將目前輸入提交到顯示值與已保存紀錄。
- `alwaysKeepTwoLayerMap`: [Boolean = false] - 此用法須為假值，才會省略外層物件。

### 輸出

- `return`: [Object|Undefined] - 單一內容主體的內部保存紀錄物件；無有效內容主體或主體缺少 `id` 時無回傳值。

### 對外功能

- 視 `isAutoCommit` 先提交全部欄位，再回傳唯一內容主體的欄位資料。

### 副作用

- 預設會提交欄位，更新唯讀顯示內容與內部保存紀錄。
- 回傳的是內部紀錄物件參照，呼叫端後續修改可能影響已保存狀態。

---

## **`PageUI.getContentValues(content, isAutoCommit, alwaysKeepTwoLayerMap)`** — 多內容主體或雙層回傳用法

### 用途

- 取得一個或多個內容主體的欄位資料，並保留以內容主體識別值分組的外層物件。

### 輸入

- `content`: [String|HTMLElement] - `TABLE.contentTable` 或單一 `TBODY[contentBody]`。
- `isAutoCommit`: [Boolean = true] - 讀取前是否先提交全部欄位。
- `alwaysKeepTwoLayerMap`: [Boolean = false] - 多個內容主體時不論此值皆回傳雙層物件；單一內容主體時須設為真值才能保留外層物件。

### 輸出

- `return`: [Object|Undefined] - `{ [contentBodyId]: { [fieldKey]: fieldValue } }`。輸入可解析但沒有可加入結果的主體時，多主體路徑回傳空物件；輸入無法解析為內容主體時無回傳值。

### 對外功能

- 視 `isAutoCommit` 先提交全部欄位，再依每個內容主體 `id` 組成雙層資料。

### 副作用

- 預設提交全部欄位，更新唯讀顯示內容與各內容主體的保存紀錄。
- 第二層值是內部保存紀錄物件的參照；呼叫端修改巢狀內容會影響後續提交與還原基準。

---

## **`JsUtils.createDOMElement(elementTagName, elemantAttributes, elementActions, parentElement, insertPosition)`**

### 用途

- 建立元素、套用屬性與事件，並可將其附加至指定容器。

### 輸入

- `elementTagName`: [String] - 要建立的元素種類。
- `elemantAttributes`: [Object = undefined] - 要套用的屬性對照；只寫入字串、數字或布林值，`className` 透過元素屬性直接指定，其餘使用 `setAttribute`。
- `elementActions`: [Object<String, Function> = undefined] - 事件名稱至處理函式的對照；包裝後的處理函式呼叫 `(event.srcElement, event)`。
- `parentElement`: [HTMLElement|DocumentFragment = undefined] - 新元素要加入的父容器。
- `insertPosition`: [Number|NumericString = undefined] - 預定插入的子節點索引；符合十進位數值格式時進入索引插入分支。

### 輸出

- `return`: [HTMLElement] - 新建立的元素。

### 對外功能

- 建立元素、套用屬性與事件，並可將其附加至指定容器。

### 副作用

- 註冊事件處理並把新元素加入父容器。由於迴圈以函式範圍的 `key` 建立閉包，多個事件全部可能在觸發時呼叫最後一個鍵所指向的處理函式。
- 提供數值插入位置時，原始實作引用未定義的 `parentChild`，因此會拋出錯誤；未提供時才會正常附加至父容器末端。

---

## **`JsUtils.isArray(node)`**

### 用途

- 判定輸入是否為陣列資料。

### 輸入

- `node`: [Any] - 待判定的值。

### 輸出

- `return`: [Boolean] - 值為陣列且其長度符合數值格式時為 `true`，否則為 `false`。

### 對外功能

- 判定輸入是否為陣列資料。

### 副作用

- 無

---

## **`JsUtils.isDOMObject(node)`**

### 用途

- 判定輸入是否為可操作的介面元素節點。

### 輸入

- `node`: [Any] - 待判定的值。

### 輸出

- `return`: [Boolean] - 值具有元素名稱且節點類型為元素時為 `true`，否則為 `false`。

### 對外功能

- 判定輸入是否為可操作的介面元素節點。

### 副作用

- 無

---

## **`PageUI.setContentValues(content, values, isAutoCommit, clearValueWhenNotInValues)`** — 單一內容主體用法

### 用途

- 將單層業務資料寫入單一內容主體的全部欄位。

### 輸入

- `content`: [String|HTMLElement] - 單一 `TBODY[contentBody]`，或只包含一個內容主體的 `TABLE.contentTable`。
- `values`: [Object<String, Any>] - 以欄位 `key` 為鍵的單層資料；至少一個第一層值必須不是一般物件，否則實作會將其判定為雙層資料。各欄位值結構詳見 `PageUI.setContentValue`。
- `isAutoCommit`: [Boolean = true] - 每個欄位寫入後是否立即提交。
- `clearValueWhenNotInValues`: [Boolean = false] - 欄位缺值或值不合預期時是否清空。

### 輸出

- 無

### 對外功能

- 將 `values` 直接設為內容主體的保存紀錄，逐欄依 `key` 取值並寫入控制項。

### 副作用

- 以輸入資料或空物件取代各內容主體的內部保存紀錄。
- 更新欄位控制項；預設也更新顯示內容及保存後的值。
- 寫入過程可能執行欄位自訂設值行為及共通格式化。

---

## **`PageUI.setContentValues(content, values, isAutoCommit, clearValueWhenNotInValues)`** — 多內容主體用法

### 用途

- 將依內容主體分組的雙層業務資料寫入一個或多個內容主體。

### 輸入

- `content`: [String|HTMLElement] - `TABLE.contentTable` 或單一 `TBODY[contentBody]`。
- `values`: [Object<String, Object>] - 第一層鍵為內容主體 `id`，第一層每個值均須為一般物件；第二層鍵為欄位 `key`。結構為 `{ [contentBodyId]: { [fieldKey]: fieldValue } }`。
- `isAutoCommit`: [Boolean = true] - 每個欄位寫入後是否立即提交。
- `clearValueWhenNotInValues`: [Boolean = false] - 欄位缺值或值不合預期時是否清空。

### 輸出

- 無

### 對外功能

- 逐一依內容主體 `id` 選取對應第二層資料，並將資料寫入該主體的全部欄位。

### 副作用

- 每個內容主體的保存紀錄會先被對應物件或新空物件取代，再更新欄位控制項。
- `values` 為空物件時仍被判定為雙層資料，所有內容主體的保存紀錄都會改為空物件；欄位是否清空取決於欄位種類與 `clearValueWhenNotInValues`。
- 如果第一層存在非物件值且 `content` 含多個內容主體，兩個執行分支都不成立，不會寫入任何欄位。
- 寫入與預設提交可能執行欄位 `setFunc`、`getFunc`、日期或數值格式化，並更新唯讀顯示內容。

---

## **`JsUtils.isObject(node)`**

### 用途

- 判定輸入是否為一般鍵值資料物件。

### 輸入

- `node`: [Any] - 待判定的值。

### 輸出

- `return`: [Boolean] - 值為非空的一般資料物件，且不是陣列或函式時為 `true`。

### 對外功能

- 判定輸入是否為一般鍵值資料物件。

### 副作用

- 無

---

## **`JsUtils.isString(node)`**

### 用途

- 判定輸入是否為字串。

### 輸入

- `node`: [Any] - 待判定的值。

### 輸出

- `return`: [Boolean] - 值為字串基本型別時為 `true`，否則為 `false`。

### 對外功能

- 判定輸入是否為字串。

### 副作用

- 無

---

## **`PageUI.setButtonsEnable(buttonContent, enableArray, skipCheck)`**

### 用途

- 依允許清單統一設定按鈕區內各按鈕的啟用狀態，並可讓指定按鈕保留原狀態。

### 輸入

- `buttonContent`: [String|HTMLElement] - 按鈕區容器。
- `enableArray`: [String|Array] - 要保持啟用的按鈕識別值；字串以逗號分隔。
- `skipCheck`: [String|Array = undefined] - 不重新判定、而是保留原停用狀態的按鈕識別值。

### 輸出

- 無

### 對外功能

- 依允許清單統一設定按鈕區內各按鈕的啟用狀態，並可讓指定按鈕保留原狀態。

### 副作用

- 直接改變按鈕的停用狀態；未列入允許清單且未要求保留者會被停用。

---

## **`PageUI.setContentsDisplay(content, displayType)`**

### 用途

- 將指定顯示模式套用到一個或多個內容主體中的所有欄位。

### 輸入

- `content`: [String|HTMLElement] - 內容主體或其所屬內容表格。
- `displayType`: [Any] - 顯示模式，採嚴格相等比較；代碼詳見[代碼對照表](#代碼對照表)。

### 輸出

- 無

### 對外功能

- 將指定顯示模式套用到一個或多個內容主體中的所有欄位。

### 副作用

- 改變欄位輸入控制與唯讀顯示內容的可見性。
- 完成後強制重新計算頁面尺寸。

---

## **`PageUI.commitContentValues(content)`**

### 用途

- 提交指定內容範圍內所有欄位的目前值。

### 輸入

- `content`: [String|HTMLElement] - 內容主體或其所屬內容表格。

### 輸出

- 無

### 對外功能

- 提交指定內容範圍內所有欄位的目前值。

### 副作用

- 逐欄更新唯讀顯示內容及內部保存紀錄。
- 讀值過程可能執行欄位自訂取值行為，並可能調整空白下拉選項的選取狀態。

---

## **`PageUI.rollbackContentValues(content)`**

### 用途

- 將指定內容範圍內所有欄位恢復為最近一次提交所保存的值。

### 輸入

- `content`: [String|HTMLElement] - 內容主體或其所屬內容表格。

### 輸出

- 無

### 對外功能

- 將指定內容範圍內所有欄位恢復為最近一次提交所保存的值。

### 副作用

- 改寫所有欄位控制項，但不重新提交顯示內容或保存紀錄。
- 還原過程可能執行欄位自訂設值行為及共通格式化。

---

## **`JsUtils.getParentByTagName(node, TagName)`**

### 用途

- 由指定節點向上尋找最近的特定種類元素。

### 輸入

- `node`: [HTMLElement] - 尋找起點；起點本身也會納入比對。
- `TagName`: [String] - 要尋找的元素種類名稱，不區分大小寫。

### 輸出

- `return`: [HTMLElement|Boolean = false] - 第一個符合種類的起點或上層元素；找不到或輸入無效時為 `false`。

### 對外功能

- 由指定節點向上尋找最近的特定種類元素。

### 副作用

- 無

---

## **`JsUtils.addOptions(node, optionValues, key, valueKey, removeOldOptions, keepFirst)`**

### 用途

- 將鍵值資料或資料陣列轉為選擇控制項的選項集合。

### 輸入

- `node`: [String|HTMLElement] - 要加入選項的選擇控制項。
- `optionValues`: [Object<String, Any>|Array<Object>] - 選項資料：
  - 物件來源: 第一層鍵作為選項值；第一層值直接作為顯示值，或交由 `valueKey(mappedValue, false)` 轉換。
  - 陣列來源: 每個項目必須是一般物件；以 `item[key]` 作為選項值，以 `item[valueKey]` 或 `valueKey(item, true)` 作為顯示值。
  - 兩種來源都只建立選項值與顯示值為字串、數字或布林值的項目。
- `key`: [String = undefined] - 陣列來源的必要欄位名稱；物件來源不使用。
- `valueKey`: [String|Function = undefined] - 陣列來源的必要顯示欄位名稱，或顯示值產生函式；物件來源可省略，或提供函式轉換第一層值。
- `removeOldOptions`: [Boolean = true] - 加入前是否移除既有選項。
- `keepFirst`: [Boolean = false] - 移除既有選項時是否保留第一項。

### 輸出

- 無

### 對外功能

- 將鍵值資料或資料陣列轉為選擇控制項的選項集合。

### 副作用

- 預設先移除既有選項，再建立並加入新選項。
- 完成後將第一個子項設為已選取。

---

## **`JsUtils.setOption(node, setValue, selectFirstWhenNull)`**

### 用途

- 依選項值更新單一或多重選擇控制項的選取狀態。

### 輸入

- `node`: [String|HTMLElement] - 要設定的選擇控制項。
- `setValue`: [Any] - 要比對的選項值，採寬鬆相等比對。
- `selectFirstWhenNull`: [Boolean = false] - 命中指定值後是否立即停止掃描。原始實作雖先嘗試選取第一項，但第一項不相符時隨即取消，因此找不到值時並不會保留第一項。

### 輸出

- 無

### 對外功能

- 依選項值更新單一或多重選擇控制項的選取狀態。

### 副作用

- 逐一改變選項的選取狀態；`selectFirstWhenNull=true` 命中後不再清除後續選項的既有狀態，可能留下多個 `selected` 屬性。
- 原始實作假設至少存在一個選項；空選項集合可能導致錯誤。

---

## **`JsUtils.setDateInput(node, value)`**

### 用途

- 清空日期文字欄位，依 `datatype`、`pattern`、`beforeROC20` 與 `beforeROC` 驗證及轉換輸入日期，再將結果寫回。日期種類詳見[代碼對照表](#代碼對照表)。

### 輸入

- `node`: [String|HTMLInputElement] - 日期文字輸入控制項或其 `id`／`name`。
- `value`: [String|Number] - 要寫入的西元或民國日期值。

### 輸出

- 無

### 對外功能

- 清空日期文字欄位，依 `datatype`、`pattern`、`beforeROC20` 與 `beforeROC` 驗證及轉換輸入日期，再將結果寫回。日期種類詳見[代碼對照表](#代碼對照表)。

### 副作用

- 先清空控制項，再依有效性決定是否寫入新值；解析不到元素時，原始實作會在讀取 `tagName` 時拋出錯誤。
- 缺少 `pattern` 時，原始實作在讀取已宣告的 `dateSplit` 後誤用未宣告的 `dateSplite`；一般情況會立即拋出 `ReferenceError`，無法進入原本預定的預設樣式流程。只有執行環境碰巧存在同名全域變數時，才可能保存 `yyyy/MM/dd`、`yyyMMdd` 或該全域分隔字元組成的樣式。
- 只有環境提供全域 `isDate` 時才進行日期驗證及紀年轉換；否則原值直接寫回。
- `datatype="date"` 的格式化結果誤寫至 `valeu`，因此不會套用 `pattern`，但民國輸入仍可能先轉為西元；其他 `datatype` 值則進入民國格式分支。

---

## **`PageUI.commitContentValue(node)`**

### 用途

- 讀取單一欄位的目前值，轉成顯示資料，並將同一值保存為後續還原基準。

### 輸入

- `node`: [HTMLElement] - 由內容建構流程產生且具有 `autoInput`、`autoInputValueKey`、`autoInputType` 的欄位 `SPAN`。雖然內部取值可由子控制項反查欄位，但此函式其餘步驟直接從原參數讀取屬性，因此傳入子控制項不具完整效果；字串也不會先解析。

### 輸出

- 無

### 對外功能

- 讀取單一欄位的目前值，轉成顯示資料，並將同一值保存為後續還原基準。

### 副作用

- 清除並重建欄位的唯讀顯示內容。
- 更新欄位所屬內容主體的內部保存紀錄。
- 可能執行欄位自訂取值行為、日期格式化，或調整下拉選項狀態。
- 顯示值以 `values[key] || ""` 取得，因此有效的數字 `0` 與布林值 `false` 會顯示為空字串；後續保存紀錄仍由非顯示取值流程重讀。

---

## **`PageUI.rollbackContentValue(node)`**

### 用途

- 將單一欄位控制項恢復為最近一次提交所保存的資料值。

### 輸入

- `node`: [String|HTMLElement] - 內容欄位容器、其內部控制項，或元素 `id`／`name`；會先正規化為具有 `autoInput` 的欄位 `SPAN`。

### 輸出

- 無

### 對外功能

- 依欄位所屬內容主體的保存紀錄，呼叫 `PageUI.setContentValue(node, recordMap, false)` 還原單一欄位，且不重新提交。

### 副作用

- 改寫欄位控制項或選取狀態，並可能執行該欄位的 `setFunc`。
- 不更新唯讀顯示內容，也不改寫保存紀錄；若顯示區原本與保存值不同，還原後仍可能顯示舊文字，直到再次提交。

---

## **`JsUtils.getDOM(node)`**

### 用途

- 將元素參照或文字識別值解析為單一介面元素，並依是否啟用 Prototype 採用不同的查詢後備規則。

### 輸入

- `node`: [String|HTMLElement] - 元素本身，或其識別值／名稱。

### 輸出

- `return`: [HTMLElement|Boolean|Null] - 找到的元素；未啟用 Prototype 時，找不到或輸入不是元素會回傳 `false`。啟用 Prototype 時直接回傳 `$()` 的結果，找不到時通常為 `null`。

### 對外功能

- 將元素參照或文字識別值解析為單一介面元素。未啟用 Prototype 時先依 `id`、再依 `name` 查詢且名稱重複時取第一個；啟用 Prototype 時只呼叫 `$()`，不執行 `name` 後備查詢。

### 副作用

- 無

---

## **`JsUtils.isBasicType(node)`**

### 用途

- 判定輸入是否屬於此元件接受的基本資料種類。

### 輸入

- `node`: [Any] - 待判定的值。

### 輸出

- `return`: [Boolean] - 值為字串、數字或布林基本型別時為 `true`。

### 對外功能

- 判定輸入是否屬於此元件接受的基本資料種類。

### 副作用

- 無

---

## **`JsUtils.getDateInput(node, isFormatToY2K)`**

### 用途

- 依欄位的 `datatype`、`pattern`、`beforeROC20` 與 `beforeROC` 讀取日期；`rocdate` 可轉為西元交換值或民國顯示值，`date` 可依樣式格式化。日期種類詳見[代碼對照表](#代碼對照表)。

### 輸入

- `node`: [String|HTMLInputElement] - 日期文字輸入控制項或其 `id`／`name`。
- `isFormatToY2K`: [Boolean = true] - 民國日期是否轉為西元標準值；設為 `false` 時保留欄位指定的顯示紀年與樣式。

### 輸出

- `return`: [String] - 驗證及格式化後的日期值；控制項或日期無效時為空字串。

### 對外功能

- 依欄位的 `datatype`、`pattern`、`beforeROC20` 與 `beforeROC` 讀取日期；`rocdate` 可轉為西元交換值或民國顯示值，`date` 可依樣式格式化。日期種類詳見[代碼對照表](#代碼對照表)。

### 副作用

- 解析不到元素時，原始實作會在讀取 `tagName` 時拋出錯誤。
- 只有環境提供全域 `isDate` 時才驗證及格式化；否則回傳欄位原值。除 `date`、`rocdate` 外的其他 `datatype` 亦會直接回傳原值，因原始型別防衛條件的運算子優先序有誤。

---

## **`PageUI.setContentValue(inputElem, value, isAutoCommit, clearValueWhenNotInValues)`**

### 用途

- 依欄位種類將資料寫入控制項；欄位種類及其資料語意詳見[代碼對照表](#代碼對照表)。

### 輸入

- `inputElem`: [String|HTMLElement] - 內容欄位容器或其內部控制項。
- `value`: [Any|Object] - 欄位值，或包含該欄位 `key` 的資料物件。各種類的契約如下：
  - `text`、`number`、`money`、`select`、`date`、`textarea`: 接受基本型別，或 `{ [key]: 基本型別 }`。
  - `checkbox`: 接受基本型別、值陣列，或 `{ [key]: 基本型別|Array }`；實作以逗號分隔字串後逐項選取。
  - `radio`: 接受基本型別或 `{ [key]: 基本型別 }`。
  - `datebetween`: 預期 `{ [startKey]: value, [endKey]: value }`；起迄鍵來自欄位的 `attrs_s.key`、`attrs_e.key`。直接傳基本型別會進入引用未定義 `nodekey` 的分支並拋出錯誤。
  - `link`: 接受基本型別顯示文字，或 `{ href: String, text: 基本型別 }`。物件分支在設定文字時呼叫了錯誤的 `setAttribute` 簽章，會拋出錯誤。
  - `dom`: 只有設定 `setFunc` 時才處理，並呼叫 `(element, normalizedValue, value)`。
- `isAutoCommit`: [Boolean = true] - 寫入後是否立即提交為顯示值與還原基準。
- `clearValueWhenNotInValues`: [Boolean = false] - 值缺少或不合欄位預期時是否清空。

### 輸出

- 無

### 對外功能

- 依欄位種類將資料寫入控制項；欄位種類及其資料語意詳見[代碼對照表](#代碼對照表)。

### 副作用

- 改寫欄位控制項、選取狀態、文字內容或連結資訊，並可能執行自訂設值行為及共通格式化。
- 正規化後的欄位容器會寫入未宣告的全域變數 `node`，可能覆蓋頁面上既有同名狀態。
- 預設立即提交，進一步更新唯讀顯示內容與內部保存紀錄。
- 原始日期區間與物件型連結分支含未定義名稱或不正確屬性呼叫，特定輸入可能中止並拋出錯誤。

---

## **`UI_Manager.addUIConfig(UI_Name, UI)`**

### 用途

- 將介面元件加入共用事件與查詢所使用的內部登錄表。

### 輸入

- `UI_Name`: [String] - 介面元件的登錄名稱；非字串時自動產生名稱。
- `UI`: [Object] - 要登錄的介面元件。

### 輸出

- 無

### 對外功能

- 將介面元件加入共用事件與查詢所使用的內部登錄表。

### 副作用

- 新增或覆寫同名登錄，並遞增內部登錄計數；非一般物件不處理。

---

## **`JsUtils.compareClass(node, compare)`**

### 用途

- 以不區分大小寫方式比對元素的類別名稱集合。

### 輸入

- `node`: [HTMLElement] - 要檢查的元素。
- `compare`: [String] - 要比對的單一類別名稱。

### 輸出

- `return`: [Boolean] - 元素包含該類別名稱時為 `true`，否則為 `false`。

### 對外功能

- 以不區分大小寫方式比對元素的類別名稱集合。

### 副作用

- 無

---

## **`JsUtils.removeOptions(node, keepFirst)`**

### 用途

- 移除選擇控制項中的全部選項，或僅保留第一項。

### 輸入

- `node`: [String|HTMLElement] - 要清理的選擇控制項。
- `keepFirst`: [Boolean = false] - 是否保留第一個選項。

### 輸出

- 無

### 對外功能

- 移除選擇控制項中的全部選項，或僅保留第一項。

### 副作用

- 從控制項移除既有子節點。

---

## **`JsUtils.getSelectName(node, selectedValue)`**

### 用途

- 取得指定值或目前選取選項的顯示名稱。

### 輸入

- `node`: [String|HTMLElement] - 選擇控制項。
- `selectedValue`: [Any = undefined] - 指定要查詢的選項值；未提供基本型別時查詢目前選取項目。

### 輸出

- `return`: [String] - 符合選項的顯示文字；找不到、輸入無效或空值不允許顯示名稱時為空字串。

### 對外功能

- 取得指定值或目前選取選項的顯示名稱。

### 副作用

- 無

---

## **`JsUtils.stringToArray(stringValue, splitChar)`**

### 用途

- 將分隔文字正規化為陣列，並保留既有陣列結構。

### 輸入

- `stringValue`: [Any] - 待轉換的值；陣列會直接回傳。
- `splitChar`: [String] - 字串分隔符號。

### 輸出

- `return`: [Array] - 分割並去除各項前後空白後的陣列；非基本型別包成單一項陣列。

### 對外功能

- 將分隔文字正規化為陣列，並保留既有陣列結構。

### 副作用

- 無

---

## **`JsUtils.arrayToString(arrayValue)`**

### 用途

- 將陣列中的基本值合併為可顯示文字，忽略複合資料項目。

### 輸入

- `arrayValue`: [Array] - 待合併的資料陣列。

### 輸出

- `return`: [String] - 以逗號及空白連接所有基本型別項目的文字；輸入不是陣列時為空字串。

### 對外功能

- 將陣列中的基本值合併為可顯示文字，忽略複合資料項目。

### 副作用

- 無

---

## **`JsUtils.trim(value)`**

### 用途

- 移除文字前後的空白字元。

### 輸入

- `value`: [Any] - 待處理的值。

### 輸出

- `return`: [Any] - 字串移除前後空白後的結果；非字串原樣回傳。

### 對外功能

- 移除文字前後的空白字元。

### 副作用

- 無

---

## **`PageUI.fixedContent(fixedNum, inputFragment, parentNodeList)`**

### 用途

- 將內容區塊分為固定前段與可捲動後段，並在可能時保留區塊原有的共同父容器。

### 輸入

- `fixedNum`: [Number|NumericString = undefined] - 保留於固定區域的前段內容數量。只有數字 `0` 會命中「不建立捲動區」的快速路徑；字串 `"0"` 雖通過數值檢查，仍會把所有區塊放入捲動容器。
- `inputFragment`: [DocumentFragment = undefined] - 待重新分區的內容片段；未提供時取用目前頁面內容區塊。
- `parentNodeList`: [Array<HTMLElement> = undefined] - 各內容區塊原父容器，用於維持共同父層結構。

### 輸出

- `return`: [DocumentFragment|Undefined] - 提供內容片段時回傳重組後片段；直接操作目前頁面時通常無回傳值；固定數量無效時原樣回傳輸入片段。

### 對外功能

- 將內容區塊分為固定前段與可捲動後段，並在可能時保留區塊原有的共同父容器。

### 副作用

- 搬移內容節點、建立可捲動容器並更新內部版面狀態。
- 原始上限判斷使用不存在的 `contentDiv.length`，因此 `fixedNum` 大於區塊數時不會命中快速路徑；結果不一定建立已掛載的捲動容器，但內部仍會標記為捲動區運作中。
- 未提供片段時直接改寫目前頁面內容區並重新計算尺寸。

---

## **`PageUI.createInput(type, id, setting, defaultFieldName)`**

### 用途

- 這是 `PageUI.createContent` 使用的內部建構函式，依欄位種類建立輸入控制、唯讀顯示位置、識別資訊、選項與事件設定。語法清單雖列為 `PageUI.createInput(...)`，原始碼並未公開此成員。

### 輸入

- `type`: [String|Number|Boolean] - 欄位種類；實作接著呼叫 `toLowerCase()`，實際上只有字串可安全使用。支援代碼詳見[代碼對照表](#代碼對照表)。
- `id`: [String|Number|Boolean] - 欄位識別值。
- `setting`: [Object|String] - 欄位設定。此函式先讀取 `setting.key`，因此 `null`／`undefined` 會在型別分支前拋出錯誤；物件結構與各種類專屬欄位完整定義於 `PageUI.createContent` 的 `FieldSetting`。
- `defaultFieldName`: [String = undefined] - 未另行指定時使用的欄位顯示名稱。

### 輸出

- `return`: [HTMLElement|Undefined] - 包含輸入與唯讀顯示位置的欄位容器；識別值或種類無效時無回傳值。

### 對外功能

- 這是 `PageUI.createContent` 使用的內部建構函式，依欄位種類建立輸入控制、唯讀顯示位置、識別資訊、選項與事件設定。語法清單雖列為 `PageUI.createInput(...)`，原始碼並未公開此成員。

### 副作用

- 建立並組合多個介面節點；`dom` 類型會搬移既有元素並改寫其屬性。
- 直接補寫設定物件內的 `attrs`、`events`、`attrs_s`、`attrs_e`、`events_s` 與 `events_e`；共用同一物件作為起迄設定時，後寫入的迄日屬性會覆蓋起日屬性。
- `link` 分支檢查的是拼錯的 `attrs.herf`，因此即使已有 `href` 仍會執行預設處理；實際寫入的仍是 `href="#"`。
- 原始檔僅宣告此內部函式，未將其掛載為 `PageUI` 成員；直接呼叫 `PageUI.createInput` 會得到「不是函式」的執行期錯誤。

---

## **`PageUI.setContentDisplay(node, displayType)`**

### 用途

- 切換單一內容欄位的輸入控制與唯讀顯示位置。

### 輸入

- `node`: [String|HTMLElement] - 內容欄位容器或其內部控制項。
- `displayType`: [Any] - 顯示模式，採嚴格相等比較；代碼詳見[代碼對照表](#代碼對照表)。

### 輸出

- 無

### 對外功能

- 切換單一內容欄位的輸入控制與唯讀顯示位置。

### 副作用

- 直接改變欄位子元素的可見性。

---

## **`PageUI.getContentValue(node, isForDisplay)`**

### 用途

- 依欄位種類讀取並正規化單一欄位值，支援顯示文字與資料交換兩種結果形式；種類語意詳見[代碼對照表](#代碼對照表)。

### 輸入

- `node`: [String|HTMLElement] - 內容欄位容器或其內部控制項。
- `isForDisplay`: [Boolean = false] - 是否以唯讀顯示用途取值；顯示用途會輸出顯示名稱或格式化日期。

### 輸出

- `return`: [Object] - 以欄位資料鍵為主的值集合；無效欄位回傳空物件。結果依種類為：
  - `text`、`number`、`money`、`date`、`textarea`、`link` 與靜態欄位：`{ [key]: value }`；非顯示用途的數值會移除逗號。
  - `select`: 非顯示用途為 `{ [key]: code, [key + "_NM"]: name }`；顯示用途為 `{ [key]: name, [key + "_CODE"]: code }`。
  - `datebetween`: `{ [startKey]: value, [endKey]: value }`。
  - `radio`: 非顯示用途取第一個選取值，顯示用途取選項名稱文字。
  - `checkbox`: 非顯示用途回傳選取值陣列，顯示用途回傳以 `, ` 連接的選項名稱。
  - `dom`: 僅在設定 `getFunc` 時寫入 `{ [key]: callbackResult }`。

### 對外功能

- 依欄位種類讀取並正規化單一欄位值，支援顯示文字與資料交換兩種結果形式；種類語意詳見[代碼對照表](#代碼對照表)。

### 副作用

- 非顯示用途會直接更新並回傳欄位所屬內容主體的內部保存紀錄。
- 可能執行欄位自訂取值行為；空白下拉值會將第一個選項設為已選取。

---

## **`PageUI.setSubTitle(subTitleText)`**

### 用途

- 更新已建立頁面框架的副標題。

### 輸入

- `subTitleText`: [Any] - 要設定的副標題內容。

### 輸出

- 無

### 對外功能

- 更新已建立頁面框架的副標題。

### 副作用

- 以可解析為標記內容的方式直接取代副標題；尚未建立頁面時不處理。

---

## **`UI_Manager.getUI(UI_Name)`**

### 用途

- 依名稱取得共用管理器中的介面元件。

### 輸入

- `UI_Name`: [String] - 介面元件登錄名稱。

### 輸出

- `return`: [Object|Undefined] - 已登錄的介面元件；名稱不存在時為 `undefined`。

### 對外功能

- 依名稱取得共用管理器中的介面元件。

### 副作用

- 無

---

## **`UI_Manager.callShareingObserve(DOM2Event)`**

### 用途

- 先執行指定事件的額外處理，再依事件對照規則呼叫所有已登錄介面元件上的對應能力；原始對照包含將尺寸事件分派至各元件的尺寸調整能力。

### 輸入

- `DOM2Event`: [String] - 要分派的共用事件名稱；現有代碼詳見[代碼對照表](#代碼對照表)。

### 輸出

- 無

### 對外功能

- 先執行指定事件的額外處理，再依事件對照規則呼叫所有已登錄介面元件上的對應能力；原始對照包含將尺寸事件分派至各元件的尺寸調整能力。

### 副作用

- 依登錄順序同步執行多個外部函式與介面元件函式，其各自副作用會直接發生。
- 任一處理函式拋出錯誤時，後續分派可能中止。

---

## **`UI_Manager.stopEventObserving(action)`**

### 用途

- 解除管理器針對指定共用事件所登錄的全域監聽；原始事件清單僅包含尺寸事件。

### 輸入

- `action`: [String] - 要停止監聽的共用事件名稱；現有代碼詳見[代碼對照表](#代碼對照表)。

### 輸出

- 無

### 對外功能

- 解除管理器針對指定共用事件所登錄的全域監聽；原始事件清單僅包含尺寸事件。

### 副作用

- 從全域視窗移除符合名稱的事件監聽，後續事件不再自動分派。

---

## **`JsUtils.setEventObserve(elem, eventName, func)`**

### 用途

- 依執行環境可用能力，為指定目標登錄事件處理函式。

### 輸入

- `elem`: [HTMLElement|Window|Document] - 要監聽事件的目標。
- `eventName`: [String] - 標準事件名稱，不含事件處理屬性前綴。
- `func`: [Function] - 事件發生時執行的處理函式。

### 輸出

- 無

### 對外功能

- 依執行環境可用能力，為指定目標登錄事件處理函式。

### 副作用

- 新增事件監聽；舊式環境可能改寫目標的單一事件處理屬性。
- 輸入型別不符時不處理。

---

## **`JsUtils.stopEventObserving(elem, eventName, func)`**

### 用途

- 依執行環境可用能力解除指定事件監聽。

### 輸入

- `elem`: [HTMLElement|Window|Document] - 要解除監聽的目標。
- `eventName`: [String] - 標準事件名稱，不含事件處理屬性前綴。
- `func`: [Function = undefined] - 要解除的原處理函式；部分舊式路徑不使用此參數。

### 輸出

- 無

### 對外功能

- 依執行環境可用能力解除指定事件監聽。

### 副作用

- 移除事件處理；舊式環境可能移除該目標與事件名稱下的所有監聽，或清空單一事件處理屬性。
- 目標或事件名稱無效時不處理。

---

## **`JsUtils.getSpan(setting, span)`**

### 用途

- 取得內容設定中的跨欄列數值，並提供一格的預設值。

### 輸入

- `setting`: [Object] - 包含 `attrs` 屬性集合的設定物件。
- `span`: [String] - 要取得的跨欄或跨列屬性名稱。

### 輸出

- `return`: [Any = 1] - 指定屬性值；屬性集合不存在或該值為假值時回傳 `1`。

### 對外功能

- 取得內容設定中的跨欄列數值，並提供一格的預設值。

### 副作用

- 無

---

## **`JsUtils.setSpan(setting, span, span_num)`**

### 用途

- 將跨欄列屬性寫入內容設定。

### 輸入

- `setting`: [Object] - 要更新的設定物件。
- `span`: [String] - 要設定的跨欄或跨列屬性名稱。
- `span_num`: [Any] - 要保存的屬性值。

### 輸出

- 無

### 對外功能

- 將跨欄列屬性寫入內容設定。

### 副作用

- 必要時建立 `attrs` 集合，並直接改寫輸入設定物件。

---

## **`JsUtils.isNotEmptyArray(node)`**

### 用途

- 判定輸入是否為非空陣列。

### 輸入

- `node`: [Any] - 待判定的值。

### 輸出

- `return`: [Boolean] - 值為至少包含一項的陣列時為 `true`。

### 對外功能

- 判定輸入是否為非空陣列。

### 副作用

- 無

---

## **`JsUtils.isFunction(node)`**

### 用途

- 判定輸入是否為可呼叫函式。

### 輸入

- `node`: [Any] - 待判定的值。

### 輸出

- `return`: [Boolean] - 值為函式時為 `true`，否則為 `false`。

### 對外功能

- 判定輸入是否為可呼叫函式。

### 副作用

- 無

---

## **`JsUtils.isFragmentObject(node)`**

### 用途

- 判定輸入是否為可承載一組未掛載節點的文件片段。

### 輸入

- `node`: [Any] - 待判定的值。

### 輸出

- `return`: [Boolean] - 值沒有元素名稱且節點類型為文件片段時為 `true`。

### 對外功能

- 判定輸入是否為可承載一組未掛載節點的文件片段。

### 副作用

- 無

---

## **`JsUtils.getType(node)`**

### 用途

- 取得不受一般型別簡化影響的內建資料種類描述。

### 輸入

- `node`: [Any] - 待辨識的值。

### 輸出

- `return`: [String] - 值的內建種類標記；未定義值特別回傳 `undefined` 文字。

### 對外功能

- 取得不受一般型別簡化影響的內建資料種類描述。

### 副作用

- 無

---

## **`JsUtils.setClass(node, className)`**

### 用途

- 在元素尚未具有指定類別時加入該類別，既有比對不區分大小寫。

### 輸入

- `node`: [HTMLElement] - 要更新的元素。
- `className`: [String] - 要加入的單一類別名稱。

### 輸出

- 無

### 對外功能

- 在元素尚未具有指定類別時加入該類別，既有比對不區分大小寫。

### 副作用

- 必要時改寫元素的類別名稱文字，並整理前後空白。

---

## **`JsUtils.getClass(node)`**

### 用途

- 取得元素的類別名稱集合。

### 輸入

- `node`: [HTMLElement] - 要讀取的元素。

### 輸出

- `return`: [Array<String>] - 以空格拆分並去除前後空白的類別名稱陣列；類別值不是基本型別時為空陣列。

### 對外功能

- 取得元素的類別名稱集合。

### 副作用

- 無

---

## **`JsUtils.getOffsetTop(element)`**

### 用途

- 沿定位父層累加元素的垂直位置。

### 輸入

- `element`: [HTMLElement] - 要計算位置的元素。

### 輸出

- `return`: [Number] - 元素至其最外層定位容器的累計垂直偏移量。

### 對外功能

- 沿定位父層累加元素的垂直位置。

### 副作用

- 無

---

## **`JsUtils.removeAllChildren(node)`**

### 用途

- 移除指定元素的所有直接子節點。

### 輸入

- `node`: [String|HTMLElement] - 要清空的元素或其識別值。

### 輸出

- 無

### 對外功能

- 移除指定元素的所有直接子節點。

### 副作用

- 逐一從元素中移除既有內容；找不到元素時不處理。

---

## **`JsUtils.addChecks(checkType, node, items, itemKey, itemValueKey, attrs, events, removeOldOptions)`**

### 用途

- 依資料集合建立一組帶顯示文字的單選或複選控制項。

### 輸入

- `checkType`: [String] - 選取控制種類，代碼詳見[代碼對照表](#代碼對照表)。
- `node`: [String|HTMLElement] - 新控制項要加入的容器。
- `items`: [Object|Array<Object>] - 選項資料。
- `itemKey`: [String = undefined] - 陣列項目中作為選項值的欄位名稱。
- `itemValueKey`: [String|Function = undefined] - 顯示欄位名稱，或顯示值產生函式；陣列來源呼叫 `(item, true)`，物件來源呼叫 `(mappedValue, false)`。
- `attrs`: [Object] - 必要。套用到各輸入控制項的屬性集合；若未提供，實作在寫入 `inputValue` 時會拋出錯誤。
- `events`: [Object<String, Function> = undefined] - 套用到各輸入控制項的事件對照；處理函式接收 `(event.srcElement, event)`。
- `removeOldOptions`: [Boolean = true] - 建立前是否清除容器既有內容。

### 輸出

- 無

### 對外功能

- 依資料集合建立一組帶顯示文字的單選或複選控制項。

### 副作用

- 預設清除容器既有內容，再新增包裝元素、輸入控制及文字。
- 反覆改寫共用 `attrs` 物件的值、種類與顯示文字，並在建立後統一設定名稱。
- 為新控制項登錄指定事件。

---

## **`JsUtils.setCheck(checkType, name, node, setValue, clearOldChecked)`**

### 用途

- 依控制種類、群組名稱與資料值選取一個或多個控制項。

### 輸入

- `checkType`: [String] - 選取控制種類，代碼詳見[代碼對照表](#代碼對照表)。
- `name`: [String] - 要處理的控制項群組名稱。
- `node`: [String|HTMLElement] - 群組所在容器。
- `setValue`: [String|Array] - 要選取的值；字串以逗號分隔。
- `clearOldChecked`: [Boolean = false] - 設定前是否清除群組既有選取狀態。

### 輸出

- 無

### 對外功能

- 依控制種類、群組名稱與資料值選取一個或多個控制項。

### 副作用

- 視設定先清除既有選取，再將符合值的控制項設為已選取。
- 未要求清除時，不會取消未列入輸入值的既有選取項。

---

## **`JsUtils.getChecks(checkType, name, node)`**

### 用途

- 取得指定單選或複選群組的已選取值集合。

### 輸入

- `checkType`: [String] - 選取控制種類，代碼詳見[代碼對照表](#代碼對照表)。
- `name`: [String] - 控制項群組名稱。
- `node`: [HTMLElement] - 群組所在容器。

### 輸出

- `return`: [Array<String>] - 所有已選取控制項的資料值，依介面中的出現順序排列。

### 對外功能

- 取得指定單選或複選群組的已選取值集合。

### 副作用

- 無

---

## **`JsUtils.getChecksNameByValues(checkType, name, node, values)`**

### 用途

- 將單選或複選群組的一組資料值轉為對應的顯示名稱。

### 輸入

- `checkType`: [String] - 選取控制種類，代碼詳見[代碼對照表](#代碼對照表)。
- `name`: [String] - 控制項群組名稱。
- `node`: [HTMLElement] - 群組所在容器。
- `values`: [String|Array] - 要查詢顯示名稱的資料值；字串以逗號分隔。

### 輸出

- `return`: [String] - 符合值的顯示名稱，以逗號及空白連接；資料無效或沒有符合項目時為空字串。

### 對外功能

- 將單選或複選群組的一組資料值轉為對應的顯示名稱。

### 副作用

- 無

---

## **`JsUtils.clearChecked(checkType, name, node)`**

### 用途

- 清除指定單選或複選群組的全部選取狀態。

### 輸入

- `checkType`: [String] - 選取控制種類，代碼詳見[代碼對照表](#代碼對照表)。
- `name`: [String] - 控制項群組名稱。
- `node`: [String|HTMLElement] - 群組所在容器。

### 輸出

- 無

### 對外功能

- 清除指定單選或複選群組的全部選取狀態。

### 副作用

- 將所有符合種類與群組名稱的控制項設為未選取。

---

## **`JsUtils.lTrim(value)`**

### 用途

- 移除文字開頭的空白字元。

### 輸入

- `value`: [Any] - 待處理的值。

### 輸出

- `return`: [Any] - 字串移除開頭空白後的結果；非字串原樣回傳。

### 對外功能

- 移除文字開頭的空白字元。

### 副作用

- 無

---

## **`JsUtils.rTrim(value)`**

### 用途

- 移除文字結尾的空白字元。

### 輸入

- `value`: [Any] - 待處理的值。

### 輸出

- `return`: [Any] - 字串移除結尾空白後的結果；非字串原樣回傳。

### 對外功能

- 移除文字結尾的空白字元。

### 副作用

- 無

---

## 代碼對照表

- 顯示模式（`showType`／`displayType`）
  - `0`: 顯示輸入控制，隱藏唯讀顯示內容。
  - `1`: 隱藏輸入控制，顯示唯讀顯示內容；`PageUI.createContent` 的預設值。
  - `-1`: 同時隱藏輸入控制與唯讀顯示內容。
  - 其他值: 同時顯示輸入控制與唯讀顯示內容。比較採嚴格相等，因此字串 `"0"`、`"1"`、`"-1"` 均屬於「其他值」；但 `PageUI.createContent` 會先以數值格式判定接受這些字串，再原樣傳入，最終仍會落入「其他值」。
- 欄位種類（`FieldSetting.type`／內部 `createInput(type, ...)`）
  - `text`: 單行文字；資料值為基本型別。
  - `number`: 數值文字欄位；預設格式 `#`，交換值會移除逗號。
  - `money`: 金額文字欄位；預設格式 `#,##0`，交換值會移除逗號。
  - `select`: 單一或多重選擇控制；交換資料同時產生代碼與顯示名稱衍生鍵。
  - `date`: 單一日期欄位；預設 `datatype="date"`，變更事件會正規化目前輸入。
  - `datebetween`: 起迄日期欄位；建立 `{id}S` 與 `{id}E` 兩個輸入，資料鍵預設衍生為 `{key}S`、`{key}E`。
  - `textarea`: 多行文字欄位；原始取值使用 `textContent || innerText`，不直接讀取 `value` 屬性。
  - `radio`: 單選群組；交換值取第一個選取項目。
  - `checkbox`: 複選群組；交換值為選取值陣列。
  - `dom`: 搬入既有元素；資料讀寫完全依賴 `getFunc`／`setFunc`。
  - `link`: 超連結；基本型別表示顯示文字，物件形式預期包含 `href` 與 `text`。
  - 其他值或空字串: 靜態文字欄位；文字取自字串型 `setting` 或 `setting.text`。
- 選取控制種類（`checkType`）
  - `radio`: 單選控制。函式本身不強制單選語意，實際互斥行為由相同 `name` 的瀏覽器控制項提供。
  - `checkbox`: 複選控制。
  - 其他字串: 原始函式仍會依該字串建立或查詢 `type` 屬性，但不保證瀏覽器提供可選取控制行為。
- 日期資料種類（日期輸入元素的 `datatype`）
  - `date`: 西元日期。預設 `pattern` 為 `yyyy/MM/dd`。
  - `rocdate`: 民國日期。預設 `pattern` 為 `yyyMMdd`；讀取交換值時預設轉為西元。
  - 其他值或空字串: 原始型別防衛條件因運算子優先序錯誤而未拒絕；`setDateInput` 會按民國分支處理，`getDateInput` 則在啟用日期函式庫時直接回傳原值。
- 共用事件（`UI_Manager.callShareingObserve`／`UI_Manager.stopEventObserving`）
  - `resize`: 唯一預先登錄的共用事件。瀏覽器視窗發生 `resize` 時，管理器分派至每個已登錄介面物件的 `resize()`；`PageUI` 載入時會以名稱 `PageUI` 登錄，因此會連動重新計算版面。
  - 其他字串: 目前沒有事件至介面函式的對照；除非外部程式直接改寫非區域變數 `eventMappingList` 或 `outerEventAdding`，否則呼叫不執行任何處理。
