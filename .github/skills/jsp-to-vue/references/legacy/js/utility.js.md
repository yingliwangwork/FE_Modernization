# utility.js 公開契約

## 使用語法清單
**方法**:
- [addPrefix(str, len, prestr)](#addPrefix(str,-len,-prestr))
- [MoneyFormat(inputString)](#MoneyFormat(inputString))
- [jump(current_element, next_element, len)](#jump(current_element,-next_element,-len))
- [submitOnce(button)](#submitOnce(button))
- [enableElements(elems)](#enableElements(elems))
- [fix()](#fix())
- [CSS_Selectors.getElementByAttr(source, filterParams)](#CSS_Selectors.getElementByAttr(source,-filterParams))
- [CSS_Selectors.doActionWhenGetElement(source, filterParams, action)](#CSS_Selectors.doActionWhenGetElement(source,-filterParams,-action))

---

## addPrefix(str, len, prestr)
**使用範例**: `frm.YEAR_MONTH.value = addPrefix(frm.YEAR_MONTH.value, 5, '0');`
**輸入**:
- str: 文字或數值 - 原始內容，將轉換為文字處理
- len: 數值 - 補齊後之目標長度
- prestr: 文字 - 長度不足時，重複補於前方之字串
**輸出**:
- **當 str 原始長度小於 len 時**: 結果: 文字 - 補齊至長度 len 的字串
- **當 str 原始長度大於或等於 len 時**: 結果: 文字 - 原樣轉為文字型態後傳回
**功能**:
- 於字串前方重複補上指定字串，直到達到指定長度為止

---

## MoneyFormat(inputString)
**使用範例**: `target.update(MoneyFormat(tempValue)  + lastAppend);`
**輸入**:
- inputString: 數值或文字(數字格式) - 欲格式化之金額數值
**輸出**:
- 結果: 文字 - 千分位分隔之金額字串（如 123,456,789）；含小數時保留小數部分；輸入為負值時保留負號
**當 inputString 非數值型態、且非符合數字格式之文字時**:
- 原樣傳回不做轉換

**當 inputString 為數值 0 時**:
- 傳回字串 '0'
**功能**:
- 將數值或數字格式文字轉換為千分位分隔之金額顯示格式

---

## jump(current_element, next_element, len)
**使用範例**: `jump(this,document.getElementById('LAND_NO'+v),4);`
**輸入**:
- current_element: 元素 - 目前輸入欄位
- next_element: 元素 - 輸入長度達到指定值時，欲移動焦點之下一個欄位
- len: 數值 - 觸發跳格之輸入長度
**輸出**: 無
**功能**:
- **當目前輸入欄位的內容長度達到指定長度時**: 自動將輸入焦點移至下一個指定欄位

---

## submitOnce(button)
**使用範例**: `submitOnce($('form1'));`
**輸入**:
- button: 元素 - 表單內任意元素或表單元素本身，函式將自動往上尋找其所屬表單
- openWindow: 布林值 = false - **可選**，是否為開新視窗之送出動作；為 true 時不顯示送出中之遮罩
- coverOnly: 布林值 = false - **可選**，為 true 時僅執行送出前之防重複設定（顯示遮罩、停用按鈕等），不實際觸發送出
**輸出**: 無
**當 button 非有效元素、或其上層找不到所屬表單時**:
- 不執行送出並記錄除錯訊息

**當同一表單於同一動作目標已送出過且尚未逾時（非開新視窗時）時**:
- 不重複送出
**功能**:
- 防止表單重複送出：顯示送出中之遮罩（開新視窗時除外）、停用觸發送出之按鈕，並標記本次送出動作
- **當本次送出結果將載入於現有視窗區塊時**: 於該區塊載入完成後自動還原遮罩與按鈕狀態
- 執行完成後（coverOnly 為 true 時除外），觸發該表單之送出動作

---

## enableElements(elems)
**使用範例**: `enableElements('<%=status%>');`
**輸入**:
- elems: 文字 - 以逗號分隔之元素識別代號清單
**輸出**: 無
**功能**:
- 將指定之多個元素還原為可輸入/可用狀態：文字輸入類型元素移除唯讀限制，其餘類型元素移除停用狀態

---

## fix()
**使用範例**: `fix();`
**輸入**: 無
**輸出**: 無
**當頁面上不存在識別代號為 bar1 之區塊時**:
- 不執行任何動作
**功能**:
- 依目前頁面捲動位置，重新計算並固定識別代號為 bar1 之區塊於可視範圍內之對應位置

---

## CSS_Selectors.getElementByAttr(source, filterParams)
**使用範例**: `CSS_Selectors.getElementByAttr($$('#grid_body input:checked'), {'name':'radioGroup'});`
**輸入**:
- source: 元素或元素陣列 - 欲篩選之來源元素或元素集合
- filterParams: 物件 - 篩選條件，鍵為欲比對之屬性名稱，值為比對用文字；值文字開頭為 "ne:" 時代表反向比對（不等於該值）；值亦可為文字陣列，代表須同時符合陣列中所有比對條件
**輸出**:
- 結果: 元素或元素陣列 - source 為單一元素時，傳回符合條件之該元素或 undefined；source 為元素陣列時，傳回符合條件之元素所組成之陣列（可能為空陣列）
**功能**:
- 依指定之屬性條件，從來源元素或元素集合中篩選出符合條件之元素

---

## CSS_Selectors.doActionWhenGetElement(source, filterParams, action)
**使用範例**:
```
CSS_Selectors.doActionWhenGetElement(datas[i*3].up('tr').select('input:checked'), {'name':'IS_FIX_'+i},
    function(ele){
        map['IS_FIX']=ele.value;
    }
);
```
**輸入**:
- source: 元素或元素陣列 - 欲篩選之來源元素或元素集合
- filterParams: 物件 - 篩選條件，定義同 CSS_Selectors.getElementByAttr()
- action: 函式(符合條件之元素) - 對每個篩選結果分別執行之動作函式
**輸出**: 無
**功能**:
- 依指定之屬性條件篩選來源元素或元素集合，並對每一個符合條件之結果分別執行 action 函式
