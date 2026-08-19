# suggest.js 公開契約

## 使用語法清單
**變數**:
- [Suggest.URL](#Suggest.URL)
- [Suggest.LIST](#Suggest.LIST)

**方法**:
- [Suggest.add(elem, Suggest.URL, suggestUrl, config)](#Suggest.add(elem,-Suggest.URL,-suggestUrl,-config))
- [Suggest.add(elem, Suggest.LIST, suggestList, config)](#Suggest.add(elem,-Suggest.LIST,-suggestList,-config))
- [Suggest.clear(elem)](#Suggest.clear(elem))

---

## 共用模式
`Suggest.add()` 之兩種呼叫語法（依網址查詢 / 依固定清單）共用下列慣例：

- elem：可傳入元素參照，或該元素之識別代號文字；若傳入代號字串但找不到對應元素，顯示提示訊息並中止設定
- config 設定物件，可包含下列可選欄位：
  - params: 物件 = {} - **可選**，查詢建議清單時額外攜帶之參數
  - paramsFunction: 函式 - **可選**，若 config.params 傳入函式而非物件，視為動態參數產生器，於每次查詢前呼叫取得最新參數
  - prefix: 布林值 = false - **可選**，是否僅比對輸入內容為建議項目之字首
  - ignoreCase: 布林值 = true - **可選**，是否忽略英文大小寫比對
  - noCookies: 布林值 = false - **可選**，是否停用本地端歷史建議紀錄功能
  - startLength: 數值 = 4 - **可選**，觸發查詢或比對所需之最小輸入長度
  - searchGap: 數值 = 2 - **可選**，輸入長度變動未達此差異前沿用前次查詢結果 **(僅於依網址查詢之語法生效)**
  - option_key: 文字 - **可選**，建議清單為物件陣列時，用於取出比對用字串之鍵名；未提供時建議清單須為字串或數值之簡單陣列
  - remark_key: 文字 - **可選**，建議清單為物件陣列時，用於取出附加備註顯示內容之鍵名
  - dispMax: 數值 = 10 - **可選**，建議清單最多顯示筆數
  - callBackFunc: 函式(目標元素, 選定項目) - **可選**，使用者選定建議項目或離開輸入欄位時呼叫之回呼函式；無相符選定項目時，呼叫時省略第二參數
- 註冊成功後，目標欄位元素將被賦予 `setValue(value)` 方法：程式呼叫 `elem.setValue(value)` 可設定欄位值，並自動觸發建議查詢流程與 callBackFunc 回呼

---

## Suggest.URL
**使用範例**: `Suggest.add("SUBMKT_NAME", Suggest.URL, "${dispatcher}/DSA3_3500/getSUBMKT", {...})`
**輸入**: 無
**輸出**:
- Suggest.URL: 數值 = 2 - 建議資料來源類型代碼，用於 `Suggest.add()` 第二參數，代表「以非同步查詢方式取得建議清單」
**功能**:
- 提供固定常數值，供呼叫 `Suggest.add()` 時指定建議資料來源類型

---

## Suggest.LIST
**使用範例**: `Suggest.add( 'COUNTRY_NM', Suggest.LIST, COUNTRY_List, {...})`
**輸入**: 無
**輸出**:
- Suggest.LIST: 數值 = 3 - 建議資料來源類型代碼，用於 `Suggest.add()` 第二參數，代表「使用呼叫端提供之固定清單」
**功能**:
- 提供固定常數值，供呼叫 `Suggest.add()` 時指定建議資料來源類型

---

## Suggest.add(elem, Suggest.URL, suggestUrl, config)
**使用範例**:
```
Suggest.add( 
    'CASE_NAME_VIEW', 			  
    Suggest.URL,
    '${dispatcher}/DSA3_0500/suggestCaseName',
    {						
        ignoreCase:true,
        startLength:2,
        option_key:"CASE_NAME",
        remark_key:"COMMUNITY_NO",	
        noCookies:true,
        "callBackFunc" : function(node,rec){}
    }
);
```
**輸入**:
- elem: 元素參照或文字(識別代號) - 欲套用建議輸入功能之目標欄位
- suggest_type: 數值 = Suggest.URL - 指定建議資料來源類型為非同步查詢
- suggestUrl: 文字 - 查詢建議清單之服務位址
- config: 物件 - 設定物件，欄位定義見「共用模式」
**輸出**: 無
**功能**:
- 將目標欄位註冊為具備自動建議功能之輸入欄位
- 依輸入內容，於長度達 startLength 後向 suggestUrl 送出查詢取得建議清單並顯示；查詢進行中另顯示查詢中之提示訊息
- **當輸入長度未達 startLength 或欄位為空，且 config.noCookies 未設為 true 時**: 顯示本地端歷史建議紀錄
- 同一元素重複註冊時，顯示提示訊息並中止設定

---

## Suggest.add(elem, Suggest.LIST, suggestList, config)
**使用範例**:
```
Suggest.add( 'COUNTRY_NM',        
      Suggest.LIST,   
      COUNTRY_List,    
    {	"option_key" : "COUNTRY_NM",
        "remark" : "COUNTRY",
         "startLength" : 1,
         "noCookies" : true,
         "ignoreCase" : true,
         "callBackFunc" : function(node,rec){
            $('COUNTRY').setValue(rec ? rec['COUNTRY'] : '');
        }
    }
);
```
**輸入**:
- elem: 元素參照或文字(識別代號) - 欲套用建議輸入功能之目標欄位
- suggest_type: 數值 = Suggest.LIST - 指定建議資料來源類型為固定清單
- suggestList: 陣列 - 建議清單資料，可為字串/數值之簡單陣列，或物件陣列（需搭配 config.option_key 取值）
- config: 物件 - 設定物件，欄位定義見「共用模式」
**輸出**: 無
**功能**:
- 將目標欄位註冊為具備自動建議功能之輸入欄位
- 依輸入內容於 suggestList 中即時比對並顯示相符項目，不涉及任何查詢動作
- **當輸入內容為空且 config.noCookies 未設為 true 時**: 顯示本地端歷史建議紀錄
- 同一元素重複註冊時，顯示提示訊息並中止設定

---

## Suggest.clear(elem)
**使用範例**: `Suggest.clear(elem);`
**輸入**:
- elem: 元素參照或文字(識別代號) - 先前已透過 `Suggest.add()` 註冊之目標欄位
**輸出**: 無
**功能**:
- 清除指定欄位先前之查詢紀錄與已快取之建議清單
- 關閉目前顯示中之建議清單視窗
**當指定欄位尚未透過 `Suggest.add()` 註冊時**:
- 顯示提示訊息並不執行清除
