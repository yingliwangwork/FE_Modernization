# CSRUtil.js 公開契約

## 使用語法清單
**變數**:
- [CSRUtil.defaultPattern](#CSRUtil.defaultPattern)
- [CSRUtil.defaultAjaxHandler](#CSRUtil.defaultAjaxHandler)

**方法**:
- [CSRUtil.getReturnMessage(resp)](#CSRUtil.getReturnMessage(resp))
- [CSRUtil.isSuccess(resp)](#CSRUtil.isSuccess(resp))
- [CSRUtil.voToInputs(panel_id,-vo)](#CSRUtil.voToInputs(panel_id,-vo))
- [CSRUtil.inputsToVo(panel_id,-includeDisabled)](#CSRUtil.inputsToVo(panel_id,-includeDisabled))
- [CSRUtil.createCoverPage(id)](#CSRUtil.createCoverPage(id))
- [CSRUtil.createCoverPage(opts)](#CSRUtil.createCoverPage(opts))
- [CSRUtil.AjaxHandler](#CSRUtil.AjaxHandler)
    - [constructor(requestTxBean)](#CSRUtil.AjaxHandler.constructor(requestTxBean))
    - [post(action,-params,-successAction,-failureAction)](#CSRUtil.AjaxHandler.post(action,-params,-successAction,-failureAction))
    - [setSynchronous(isSync)](#CSRUtil.AjaxHandler.setSynchronous(isSync))
    - [closeSuccMsg()](#CSRUtil.AjaxHandler.closeSuccMsg())
- [CSRUtil.$fmt(v,-pattern)](#CSRUtil.$fmt(v,-pattern))
- [CSRUtil.$fmt(v,-pattern,-isInput)](#CSRUtil.$fmt(v,-pattern,-isInput))
- [Date.toROC(d)](#Date.toROC(d))
- [Date.toInputROC(d,-delimiter)](#Date.toInputROC(d,-delimiter))
- [CSRUtil.round(val,-scale)](#CSRUtil.round(val,-scale))
- [String.emptyIf(str,-replaceStr)](#String.emptyIf(str,-replaceStr))
- [String.prototype.trim()](#String.prototype.trim())
- [CSRUtil.pressNumber(code)](#CSRUtil.pressNumber(code))
- [CSRUtil.getNumber(val)](#CSRUtil.getNumber(val))
- [autoFormatToDate()](#autoFormatToDate())
- [autoFormatToNumber(elemID)](#autoFormatToNumber(elemID))
- [msgWin.show(msg)](#msgWin.show(msg))
- [msgWin.setCallback(theCB)](#msgWin.setCallback(theCB))
- [msgWin.clearCallback()](#msgWin.clearCallback())
- [BigNumber](#BigNumber)
    - [constructor(n,-p)](#BigNumber.constructor(n,-p))
    - [toString()](#BigNumber.toString())
- [CSRUtil.linkTo(linkParams,-formID)](#CSRUtil.linkTo(linkParams,-formID))
- [CSRUtil.linkBack(backAction,-cbFuncOptions)](#CSRUtil.linkBack(backAction,-cbFuncOptions))
- [CSRUtil.getLP_JSON()](#CSRUtil.getLP_JSON())
- [CSRUtil.isBackLink(formID,-backFunc)](#CSRUtil.isBackLink(formID,-backFunc))
- [CSRUtil.keepParamsManager.put(inParams)](#CSRUtil.keepParamsManager.put(inParams))
- [CSRUtil.keepParamsManager.get(key)](#CSRUtil.keepParamsManager.get(key))
- [CSRUtil.maskHandler.getMaskID(str)](#CSRUtil.maskHandler.getMaskID(str))
- [CSRUtil.maskHandler.getMaskName(str)](#CSRUtil.maskHandler.getMaskName(str))
- [CSRUtil.maskHandler.getMaskAddress(str)](#CSRUtil.maskHandler.getMaskAddress(str))
- [CSRUtil.maskHandler.getMaskAddress2(str)](#CSRUtil.maskHandler.getMaskAddress2(str))

---

## 共用模式
- 本檔案掛載一個全域命名空間 CSRUtil，並擴充原生字串、日期之靜態或原型方法，供全站頁面共用
- 字串、數值處理類方法於輸入為空值或未定義時，多回傳空字串或安全預設值，不拋出例外
- 涉及頁面導覽與參數保留之方法（linkTo、linkBack、getLP_JSON、isBackLink、keepParamsManager 各方法），彼此共用同一組跨頁面保留之全域狀態；該狀態優先保存於上層視窗之全域狀態，於無法使用時退回本地資料儲存
- 遮蔽類方法（maskHandler 各方法）之遮蔽符號如未指定，預設採用全形「＊」或半形「*」

---

## CSRUtil.defaultPattern
**使用範例**: `CSRUtil.$fmt('${BUILD_MEASURE}', CSRUtil.defaultPattern)`
**輸入**: 無
**輸出**:
- value: String = `'#,###.####'` - 預設之數值顯示格式樣板
**功能**:
- 提供 CSRUtil.\$fmt 使用之預設格式樣板字串，供未特別指定樣板時取用

---

## CSRUtil.defaultAjaxHandler
**使用範例**: `Ajax.Responders.register(CSRUtil.defaultAjaxHandler);`
**輸入**: 無
**輸出**:
- value: Object - 預先建立完成之非同步請求預設回應處理器，內含請求建立、完成、例外發生時之對應處理函式
**功能**:
- 提供可直接註冊至非同步請求回應監聽機制之預設處理器物件
- 內含統一之畫面遮罩顯示與隱藏、逾時中斷提示、回應訊息顯示、及依所在子系統決定訊息顯示方式等邏輯

---

## CSRUtil.getReturnMessage(resp)
**使用範例**: `var msg = CSRUtil.getReturnMessage(resp);`
**輸入**:
- resp: Object - 請求之回應資料
**輸出**:
- msgObj: Object - 回應資料中所含之訊息物件；resp 為空值時無回傳值
**功能**:
- 由回應資料中取出用於顯示訊息與判斷交易結果之訊息物件

---

## CSRUtil.isSuccess(resp)
**使用範例**: `if(CSRUtil.isSuccess(resp)){`
**輸入**:
- resp: Object - 請求之回應資料
**輸出**:
- result: Boolean - 回應是否成功
**功能**:
- **當回應資料包含訊息物件時**: 依其回傳碼是否為 0 判斷該次請求是否成功
- **當回應資料不含訊息物件時**: 判定請求不成功

---

## CSRUtil.voToInputs(panel_id, vo)
**使用範例**: `CSRUtil.voToInputs('form2' , rtnMap);`
**輸入**:
- panel_id: String - 目標容器之識別碼，於此容器範圍內尋找欲設定之欄位
- vo: Object - 資料物件，鍵對應欄位名稱
**輸出**: 無
**功能**:
- 依 vo 之鍵值，將對應資料設定至容器內文字類、隱藏類、多行文字輸入欄位；資料值為空值或空字串時清空欄位
- 核取方塊、選項按鈕依資料值與欄位本身之值是否相符，設定其勾選狀態
- 下拉選單依資料值設定選取項目
- **當選單具有對應的顯示用欄位時**: 同步該欄位所選項目的顯示文字
- 識別碼尾碼為 `_TXT`（不分大小寫）之顯示元素，依對應鍵值同步顯示內容

---

## CSRUtil.inputsToVo(panel_id, includeDisabled)
**使用範例**: `var reqMap = CSRUtil.inputsToVo('form', true);`
**輸入**:
- panel_id: String - 目標容器之識別碼，於此容器範圍內取出欄位值
- includeDisabled: Boolean = false - 是否一併取出已停用欄位之值，可省略
**輸出**:
- vo: Object - 由容器內文字、隱藏、多行文字、下拉選單欄位，及已勾選核取方塊、已勾選選項按鈕組成之資料物件，鍵為欄位名稱
**功能**:
- 讀取容器內各輸入欄位現有值，組成資料物件回傳
- **當 includeDisabled 為否或省略時**: 略過已停用之欄位

---

## CSRUtil.createCoverPage(id)
**使用範例**: `CSRUtil.createCoverPage('_frontCover')`
**輸入**:
- id: String - 遮罩識別碼
**輸出**:
- cover: Object - 遮罩控制物件，具 show()、hide() 方法可顯示或隱藏該遮罩
**功能**:
- 依識別碼建立（或取得已存在之同識別碼）覆蓋於目前畫面之遮罩，用以防止請求處理期間之重複操作
- 遮罩內容含載入圖示，尺寸依目前畫面內容自動調整
- 建立完成後之遮罩預設為隱藏狀態

---

## CSRUtil.createCoverPage(opts)
**使用範例**: `CSRUtil.createCoverPage({'id':'DSA30200_coverpage', 'transparent':false, 'cursor':'auto', 'show': true})`
**輸入**:
- opts: Object - 遮罩設定
- opts.id: String - 遮罩識別碼
- opts.transparent: Boolean = false - 是否為透明遮罩（透明時不顯示載入圖示）
- opts.cursor: String = `'progress'` - 遮罩顯示時之游標樣式
- opts.show: Boolean = false - 建立完成後是否立即顯示
- opts.tipsMsg: String = `''` - 遮罩上另行顯示之提示文字
- opts.zIndex: Number = 150 - 遮罩堆疊順序
**輸出**:
- cover: Object - 遮罩控制物件，具 show()、hide() 方法可顯示或隱藏該遮罩
**功能**:
- 與單一識別碼字串之呼叫方式相同，另支援以物件形式指定透明與否、游標樣式、提示文字、堆疊順序等細節
- **當 opts.show 為真時**: 建立完成後立即顯示
- **當 opts.show 為假或省略時**: 建立後維持隱藏狀態

---

## CSRUtil.AjaxHandler
非同步請求控制物件建構子，透過 `new CSRUtil.AjaxHandler.request(requestTxBean)` 建立，用以送出請求並統一處理畫面遮罩、逾時與回應訊息顯示。

### CSRUtil.AjaxHandler.constructor(requestTxBean)
**使用範例**: `var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSZ3_0200/');`
**輸入**:
- requestTxBean: String - 目的交易之請求路徑前綴
**輸出**:
- 執行個體: Object - 請求控制物件，提供 post()、setSynchronous()、closeSuccMsg() 等方法
**功能**:
- 建立一個可送出非同步請求之控制物件，預設以非同步方式送出、預設顯示遮罩

### CSRUtil.AjaxHandler.post(action, params, successAction, failureAction)
**使用範例**:
```
ajaxRequest.post('insert', {'reqMap': Object.toJSON(reqMap)},
    function(resp){
        gridB.load(resp.rtnList || []);
    }
);
```
**輸入**:
- action: String - 附加於請求路徑前綴後之交易動作名稱
- params: Object - 請求參數
- successAction: Function - 請求成功時呼叫之回呼函式，接收回應資料
- failureAction: Function - 請求失敗時呼叫之回呼函式，接收回應資料，可省略
**輸出**: 無
**功能**:
- 依 requestTxBean 與 action 組成之路徑送出請求；送出前依設定顯示畫面遮罩，回應完成後隱藏遮罩
- **當回應訊息物件的回傳碼表示成功時**: 呼叫 successAction，並視需要顯示回應訊息
- **當回應訊息物件的回傳碼表示失敗時**: 顯示錯誤訊息，並呼叫 failureAction（如有指定）

### CSRUtil.AjaxHandler.setSynchronous(isSync)
**使用範例**: `ajaxRequest.setSynchronous(true)`
**輸入**:
- isSync: Boolean - 後續請求是否採同步方式送出
**輸出**: 無
**功能**:
- 設定該請求控制物件後續呼叫 post() 時之請求送出方式

### CSRUtil.AjaxHandler.closeSuccMsg()
**使用範例**: `ajaxRequest.closeSuccMsg();`
**輸入**: 無
**輸出**: 無
**功能**:
- **當下一次請求成功時**: 不顯示成功訊息

---

## CSRUtil.$fmt(v, pattern)
**使用範例**: `CSRUtil.$fmt( value , "#,###.00" )`
**輸入**:
- v: String | Number - 欲格式化之數值
- pattern: String - 格式樣板，以 `#`／`0` 表示數字位、以逗點表示千分位分隔位置、小數點後之字元數決定顯示之小數位數
**輸出**:
- result: String - 格式化後之字串；v 為空值或未定義時回傳空字串；v 非數值字串時原樣回傳
**功能**:
- 依 pattern 所定義之千分位分隔規則與小數位數，將數值格式化為顯示用字串
- 支援以科學記號表示之數值輸入
- 依系統預設精準度（40 位）四捨五入後再依 pattern 之小數位數格式化

---

## CSRUtil.$fmt(v, pattern, isInput)
**使用範例**: `CSRUtil.$fmt(node.value, CSRUtil.defaultPattern, true)`
**輸入**:
- v: String | Number - 欲格式化之數值
- pattern: String - 格式樣板，規則同二參數版本
- isInput: Boolean - 是否為輸入過程中之即時格式化模式
**輸出**:
- result: String - 格式化後之字串；v 為空值或未定義時回傳空字串；v 非數值字串時原樣回傳
**功能**:
- 與二參數版本相同，另支援輸入過程中之即時格式化模式
- **當 isInput 為真時**: 小數部分僅截斷位數，不進行四捨五入；pattern 未指定小數位數時，精準度視為 0，不保留小數部分

---

## Date.toROC(d)
**使用範例**: `Date.toROC('${ACNT_DATE}')`
**輸入**:
- d: String - 西元日期字串，格式須為 `YYYY-MM-DD`、`YYYYMMDD` 或 `YYYY/MM/DD`（可含日期後之時間部分）
**輸出**:
- result: String - 轉換為民國年、以 `/` 分隔年月日之日期字串；d 為空值或不符合日期格式時回傳空字串
**功能**:
- 將西元年份減 1911 換算為民國年，並以 `/` 重組年月日；輸入含時間部分時，時間部分保留於結果末端

---

## Date.toInputROC(d, delimiter)
**使用範例**: `Date.toInputROC( DataMap['ACCEPT_DATE'] || "" ,"/")`
**輸入**:
- d: String - 西元日期字串，格式須為 `YYYY-MM-DD`、`YYYYMMDD` 或 `YYYY/MM/DD`
- delimiter: String - 民國年月日間之分隔符號；省略時年月日間不加分隔符號
**輸出**:
- result: String - 轉換為民國年之日期字串；d 為空值或不符合日期格式時回傳空字串
**功能**:
- 將西元年份減 1911 換算為民國年，並依 delimiter 重組年月日；輸入含時間部分時，時間部分保留於結果末端

---

## CSRUtil.round(val, scale)
**使用範例**: `CSRUtil.round(AdjList[i]['IR_RT'])`
**輸入**:
- val: Number - 欲四捨五入之數值
- scale: Number = 4 - 欲保留之小數位數，可省略
**輸出**:
- result: Number - 四捨五入後之數值
**功能**:
- 依指定小數位數四捨五入數值；未指定時預設保留 4 位小數

---

## String.emptyIf(str, replaceStr)
**使用範例**: `String.emptyIf(v, '');`
**輸入**:
- str: 任意 - 欲檢查之值
- replaceStr: 任意 - str 為空值時之替代內容
**輸出**:
- **當 str 有值（含數值 0）時**: result: 任意 - 原樣回傳 str
- **當 str 無值時**: result: 任意 - 回傳 replaceStr
**功能**:
- 為可能為空值之內容提供替代顯示值

---

## String.prototype.trim()
**使用範例**: `$F('QUERY_COND').trim()`
**輸入**: 無（作用於呼叫之字串本身）
**輸出**:
- result: String - 去除頭尾空白字元後之字串
**功能**:
- 去除字串開頭與結尾之空白字元

---

## CSRUtil.pressNumber(code)
**使用範例**: `CSRUtil.pressNumber(event.keyCode)`
**輸入**:
- code: Number - 按鍵代碼
**輸出**:
- result: Boolean - 是否為數字、小數點、負號或退格鍵之按鍵代碼
**功能**:
- 判斷按鍵代碼是否屬於數字輸入允許之按鍵範圍，供輸入過濾使用

---

## CSRUtil.getNumber(val)
**使用範例**: `CSRUtil.getNumber($F('GOAL_AMT'))`
**輸入**:
- val: String | Number - 欲轉換之數值（字串型態可含千分位逗點）
**輸出**:
- result: Number - 轉換後之數值；輸入為空值、未定義或非數值字串時回傳 0
**功能**:
- 去除千分位逗點後，將輸入轉換為數值型態

---

## autoFormatToDate()
**使用範例**: `autoFormatToDate()`
**輸入**: 無
**輸出**: 無
**功能**:
- 為畫面中所有標註為日期輸入類型且尚未套用過本機制之欄位，統一設定最大輸入長度
- 綁定按鍵事件，限制僅能輸入數字，並於輸入達第 5、8 碼時自動補上日期分隔符號
- 綁定確認事件，於欄位值不符合合理日期時，還原為前一次有效值

---

## autoFormatToNumber(elemID)
**使用範例**: `autoFormatToNumber('grid')`
**輸入**:
- elemID: String - 欲套用數字輸入限制之範圍容器識別碼；省略時套用整個畫面
**輸出**:
- inputs: Array - 套用本機制之輸入欄位集合
**功能**:
- 為指定範圍內標註為數字輸入類型之欄位，統一設定文字靠右對齊之顯示樣式
- 綁定按鍵事件，限制僅能輸入數字；綁定按鍵後續事件，依欄位自訂格式樣板（未指定時採用預設格式）即時格式化顯示內容，並還原游標所在位置

---

## msgWin.show(msg)
**使用範例**: `msgWin.show(alertMessage)`
**輸入**:
- msg: String - 欲顯示之訊息內容；換行字元會轉換為視覺上之換行
**輸出**: 無
**功能**:
- 於畫面中央顯示訊息提示視窗，並同時顯示遮罩以禁止操作下層畫面
- 訊息視窗已顯示中時，新訊息會附加於既有內容之後一併顯示，不重複開啟視窗
- 視窗寬度依訊息長度自動調整，並支援以按鍵（Enter、Esc、空白鍵）觸發確認關閉

---

## msgWin.setCallback(theCB)
**使用範例**: `msgWin.setCallback("");`
**輸入**:
- theCB: Function - 訊息視窗經使用者確認關閉後欲執行之回呼函式
**輸出**: 無
**功能**:
- 設定訊息視窗確認關閉後之後續回呼函式

---

## msgWin.clearCallback()
**使用範例**: `msgWin.clearCallback();`
**輸入**: 無
**輸出**: 無
**功能**:
- 清除已設定之訊息視窗確認關閉後回呼函式

---

## BigNumber
可精確處理大數值計算之數值物件建構子，透過 `new BigNumber(n, p)` 建立，用以避免數值位數過大時計算失準之問題。

### BigNumber.constructor(n, p)
**使用範例**: `new BigNumber(value, scale).toString()`
**輸入**:
- n: String | Number - 初始數值
- p: Number = 40 - 精準度（小數保留位數），可省略
**輸出**:
- 執行個體: BigNumber - 大數值物件，可透過 toString() 取得對應之數值字串
**功能**:
- 依指定數值與精準度建立大數值物件

### BigNumber.toString()
**使用範例**: `new BigNumber(value, scale).toString()`
**輸入**: 無
**輸出**:
- result: String - 依建立時指定精準度四捨五入後之數值字串
**功能**:
- 將大數值物件轉換為字串表示

---

## CSRUtil.linkTo(linkParams, formID)
**使用範例**: `CSRUtil.linkTo(LP_JSON, 'form1');`
**輸入**:
- linkParams: Object - 導覽參數
- linkParams.action: String - 導覽目的路徑（必填）
- linkParams.BQ_ARG: Object - 導覽後欲一併保留、供回上頁使用之自訂參數，可省略
- linkParams.{其他鍵}: 任意 - 一併傳遞至目的頁面之其他參數
- formID: String | Element - 欲一併序列化並隨導覽保留其欄位值之表單識別碼或表單物件，可省略
**輸出**: 無（直接進行頁面導覽）
**當 linkParams 未提供或未含 action 時**:
- 顯示提示訊息並中止導覽
**功能**:
- 將 linkParams（含指定表單序列化後之欄位值）併同目前頁面路徑，記錄為一筆可回溯之導覽紀錄，並保留於跨頁面之全域狀態中
- 記錄同時保留先前既有之導覽紀錄，形成可回溯之導覽堆疊
- 建立隱藏表單並以送出方式導覽至 linkParams.action 所指定之目的路徑

---

## CSRUtil.linkBack(backAction, cbFuncOptions)
**使用範例**: `CSRUtil.linkBack('', { 'isSubmitParameters' : true })`
**輸入**:
- backAction: String - 欲回溯導覽至之九碼作業代碼；省略時依最後一筆導覽紀錄回溯；非九碼時視為目的路徑本身直接導覽
- cbFuncOptions: Object - 回溯控制選項，可省略
- cbFuncOptions.mappingOnError: Function - 指定作業代碼但查無對應紀錄時之替代處理函式
- cbFuncOptions.backOnError: Function - 完全查無任何導覽紀錄時之替代處理函式
- cbFuncOptions.isSubmitParameters: Boolean = false - 回溯導覽時是否一併送出先前保留之自訂參數
**輸出**: 無（直接進行頁面導覽或執行替代處理函式）
**功能**:
- 依 backAction 由導覽紀錄堆疊中尋找對應之回溯目標（省略時取最後一筆），尋得後以送出方式導覽至該目的路徑，並自堆疊中清除經過之不符紀錄
- **當查無對應紀錄且有指定替代處理函式時**: 執行該函式，不進行導覽
- **當查無任何導覽紀錄且未指定替代處理函式時**: 顯示提示訊息並中止

---

## CSRUtil.getLP_JSON()
**使用範例**: `CSRUtil.getLP_JSON()`
**輸入**: 無
**輸出**:
- **當存在導覽紀錄時**: lpJson: Object - 最後一筆已記錄的導覽紀錄內容
- **當查無導覽紀錄時**: lpJson: Object = `{}` - 空物件
**功能**:
- 取得最後一筆已記錄之導覽紀錄內容

---

## CSRUtil.isBackLink(formID, backFunc)
**使用範例**: `CSRUtil.isBackLink('form1', function() { buttons.doQuery(); });`
**輸入**:
- formID: String - 欲還原導覽保留參數之表單識別碼，可省略
- backFunc: Function - 還原參數後欲執行之回呼函式，接收還原後之參數物件，可省略
**輸出**:
- **當判斷為回溯導覽所致時**: result: Object - 該筆導覽紀錄內容
- **當判斷非回溯導覽所致時**: result: Boolean = false - 否
**功能**:
- 判斷目前頁面是否為 linkBack 回溯導覽之目的頁面
- **當判斷為是時**: 清除該筆已使用之導覽紀錄；若有指定 formID，將保留之參數還原至該表單對應欄位；並執行 backFunc（如有指定）

---

## CSRUtil.keepParamsManager.put(inParams)
**使用範例**: `CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value });`
**輸入**:
- inParams: Object - 欲保留之參數，鍵為參數名稱
**輸出**: 無
**功能**:
- 將指定參數併入既有已保留參數集合中；同名參數預設覆寫既有值

---

## CSRUtil.keepParamsManager.get(key)
**使用範例**: `CSRUtil.keepParamsManager.get('BORROW_ID')`
**輸入**:
- key: String - 參數名稱
**輸出**:
- **當查得對應值時**: value: String - 已保留的參數值
- **當查無對應值時**: value: String = `''` - 空字串
**功能**:
- 取得指定名稱之已保留參數值

---

## CSRUtil.maskHandler.getMaskID(str)
**使用範例**: `CSRUtil.maskHandler.getMaskID(A280VO['BORROW_ID'])`
**輸入**:
- str: String - 欲遮蔽之證號字串
**輸出**:
- result: String - 遮蔽後之字串
**功能**:
- 依字串長度計算遮蔽起始位置，將字串中段固定 3 碼取代為遮蔽符號，前後段落保留原字；字串長度不足 3 碼時，整串以遮蔽符號取代

---

## CSRUtil.maskHandler.getMaskName(str)
**使用範例**: `CSRUtil.maskHandler.getMaskName(BORROW_NAME)`
**輸入**:
- str: String - 欲遮蔽之姓名字串
**輸出**:
- result: String - 遮蔽後之字串
**功能**:
- 將字串由右向左數來第 2 個字元取代為遮蔽符號（＊），其餘字元保留原字

---

## CSRUtil.maskHandler.getMaskAddress(str)
**使用範例**: `CSRUtil.maskHandler.getMaskAddress(val)`
**輸入**:
- str: String - 欲遮蔽之地址字串
**輸出**:
- result: String - 遮蔽後之字串
**功能**:
- 保留字串前 3 碼，其餘字元一律取代為遮蔽符號（＊）

---

## CSRUtil.maskHandler.getMaskAddress2(str)
**使用範例**: `CSRUtil.maskHandler.getMaskAddress2(val)`
**輸入**:
- str: String - 欲遮蔽之地址字串
**輸出**:
- result: String - 遮蔽後之字串
**功能**:
- 字串長度超過 20 碼時，保留前 20 碼，其餘取代為遮蔽符號（＊）
- 字串長度超過 10 碼、未逾 20 碼時，保留前 10 碼，其餘取代為遮蔽符號（＊）
- 字串長度未逾 10 碼時，不進行遮蔽，原樣回傳
