# popupWin.js 公開契約

## 使用語法清單

**變數**:
- [isPopupWin](#ispopupwin)

**方法**:
- [popupWin.popup()](#popupwinpopup)
- [popupWin.popup()](#popupwinpopup-1)
- [popupWin.fullPopup()](#popupwinfullpopup)
- [popupWin.fullPopup()](#popupwinfullpopup-1)
- [popupWin.close()](#popupwinclose)
- [popupWin.back()](#popupwinback)
- [popupWin.createPopupLink()](#popupwincreatepopuplink)
- [popupWin.createFullPopupLink()](#popupwincreatefullpopuplink)
- [popupWin.windowOpen()](#popupwinwindowopen)
- [popupWin.callbackHandler](#popupwincallbackhandler)
- [popupWinclose()](#popupwinclose-1)
- [popupWinBack()](#popupwinback-1)
- [callbackHandler()](#callbackhandler)

---

## 共用模式
`popupWin` 為本檔案載入時建立之全域視窗控制單例，`popupWin.popup()` / `popupWin.fullPopup()` 開啟之視窗中，會另外提供 `popupWinclose()`、`popupWinBack()`、`callbackHandler()` 等全域操作介面供該視窗內容自身呼叫，用以與開啟者（`popupWin`）互動。

---

## popupWin.popup()
**使用範例**: `popupWin.popup({'src':'<%=dispatcher%>/DSC2_2200/prompt'});`
**輸入**:
- config: 物件
  - config.src: 字串 - 欲載入之路徑（必要）
  - config.width: 數值 = 0.9 - 視窗寬度，可為 0~1 之比例值或像素值
  - config.height: 數值 = 0.8 - 視窗高度，可為 0~1 之比例值或像素值
  - config.left: 數值 = 0.5 - 視窗左側位置，可為 0~1 之比例值或像素值
  - config.top: 數值 = 0.4 - 視窗頂端位置，可為 0~1 之比例值或像素值
  - config.scrolling: 字串（`yes` | `no`） = 'Y' - 是否顯示捲軸
  - config.parameters: 陣列 | 物件 | 字串 - 傳遞至目標路徑之參數
  - config.closeConfirm: 物件 - 關閉前確認設定
    - closeConfirm.msg: 字串 - 確認訊息內容
    - closeConfirm.assignConfirmType: 布林值 = true - 確認對話框中「確認」或「取消」何者對應實際關閉動作
  - config.title: 字串 - 視窗標題
  - config.resizable: 布林值 = true - 是否可調整大小
  - config.movable: 布林值 = true - 是否可移動
  - config.closeBtn: 布林值 = true - 是否顯示關閉按鈕
  - config.isFullPopup: 布林值 = false - 是否以全視窗顯示；**為 true 時**，強制不可調整大小、不可移動
  - config.cb | config.onBack: 函式 - 視窗關閉後執行之回呼函式，等同設定 `popupWin.callbackHandler`
  - config.onClose | config.onclose: 函式 - 視窗關閉時執行之函式
**輸出**: 無
**功能**:
- 開啟一個模擬視窗之區塊，以背景表單提交方式載入 `config.src` 指定之路徑與參數
- 依 config 設定調整視窗大小、位置，及是否可調整大小／可移動／顯示關閉按鈕
- 視窗開啟後，其內容環境中會提供 `isPopupWin`、`popupWinclose()`、`popupWinBack()`，並於設定回呼函式時提供 `callbackHandler()`
- **當前一個視窗仍在使用中時**: 同一時間僅能開啟一個視窗，不執行本次開啟並記錄除錯訊息
- **當 `config` 非物件或缺少 `src` 時**: 記錄除錯訊息並中止，不開啟視窗

---

## popupWin.popup()
**使用範例**: `popupWin.popup( indexUrl );`
**輸入**:
- src: 字串 - 欲載入之路徑
**輸出**: 無
**功能**:
- 等同以 `{src: src}` 作為設定物件呼叫 `popupWin.popup()`，其餘設定皆採預設值

---

## popupWin.fullPopup()
**使用範例**: `popupWin.fullPopup(conf);`
**輸入**:
- config: 物件
  - config.src: 字串 - 欲載入之路徑（必要）
  - config.scrolling: 字串（`yes` | `no`） = 'Y' - 是否顯示捲軸
  - config.parameters: 陣列 | 物件 | 字串 - 傳遞至目標路徑之參數
**輸出**: 無
**功能**:
- 等同呼叫 `popupWin.popup()` 並強制 `isFullPopup` 為 true、`closeConfirm` 為空，以與目前瀏覽頁面相同大小開啟視窗

---

## popupWin.fullPopup()
**使用範例**: `popupWin.fullPopup(url);`
**輸入**:
- src: 字串 - 欲載入之路徑
**輸出**: 無
**功能**:
- 等同以 `{src: src}` 作為設定物件呼叫 `popupWin.fullPopup()`

---

## popupWin.close()
**使用範例**: `parent.popupWin.close();`
**輸入**: 無
**輸出**: 無
**功能**:
- 關閉目前開啟中之視窗，還原其顯示狀態
- **當關閉前已設定 `config.onClose`／`config.onclose` 時**: 先執行該函式
- **當目前無開啟中之視窗時**: 改為關閉瀏覽器視窗

---

## popupWin.back()
**使用範例**: `window.parent.popupWin.back(rtnMap);`
**輸入**:
- obj1 ~ obj0: 混合型別 - 依序傳遞至回呼函式（`config.cb`／`config.onBack`／`popupWin.callbackHandler`）之參數，最多 10 個；**實際使用僅觀察到 0 或 1 個參數**
**輸出**: 無
**功能**:
- **當已設定回呼函式時**: 依序將輸入參數轉換後傳入該函式並執行
- 關閉目前開啟中的視窗

---

## popupWin.createPopupLink()
**使用範例**: `popupWin.createPopupLink( value , { src : "<%=dispatcher%>/DSC0_1001/prompt", parameters : { "RATE_MSG" : record.RATE_MSG } } );`
**輸入**:
- text: 字串 - 連結顯示之文字
- config: 物件 - 結構同 `popupWin.popup()` 之 config
**輸出**:
- 連結元件: 元素 - 點擊後會以輸入之 config 呼叫 `popupWin.popup()` 開啟視窗之連結元件
**功能**:
- 建立一個點擊後開啟視窗（呼叫 `popupWin.popup(config)`）之連結元件

---

## popupWin.createFullPopupLink()
**使用範例**: `popupWin.createFullPopupLink( val, url );`
**輸入**:
- text: 字串 - 連結顯示之文字
- config: 物件 | 字串 - 結構同 `popupWin.fullPopup()` 之 config，或欲載入之路徑字串
**輸出**:
- 連結元件: 元素 - 點擊後會以輸入之 config 呼叫 `popupWin.fullPopup()` 開啟視窗之連結元件
**功能**:
- 建立一個點擊後以全視窗大小開啟視窗（呼叫 `popupWin.fullPopup(config)`）之連結元件

---

## popupWin.windowOpen()
**使用範例**: `popupWin.windowOpen( linkUrl , { 'parameters' : LP_JSON });`
**輸入**:
- url: 字串 - 欲開啟之路徑
- opts: 物件
  - opts.parameters: 物件 - 傳遞至目標路徑之參數
  - opts.attributes: 物件 - 開啟視窗之顯示屬性（如 status、toolbar、menubar、resizable、width、height、top、left 等）
  - opts.windowName: 字串 = 'popupWinWindowOpen' - 開啟視窗之名稱；**相同名稱之視窗會被共用**
  - opts.fullScreen: 布林值 = false - 是否以全螢幕開啟；**為 true 時**，視窗寬高採用螢幕可用尺寸，且預設不可調整大小
**輸出**: 無
**功能**:
- 以背景表單提交方式開啟一個新的獨立瀏覽器視窗載入 `url` 與 `opts.parameters`
- 依 `opts.attributes` 設定該視窗之顯示屬性

---

## popupWin.callbackHandler
**使用範例**: `popupWin.callbackHandler = function(){actions.doReject();};`
**輸入**:
- callback: 函式 - 視窗關閉（透過 `popupWin.back()` 或視窗內容自身呼叫 `callbackHandler()`）時執行之回呼函式
**輸出**: 無
**功能**:
- 設定 `popupWin.popup()` 所開啟視窗關閉時執行之回呼函式
- **當呼叫 `popupWin.popup()` 時之 config 已提供 `config.cb`／`config.onBack`，且本屬性未被改寫時**: 以 config 提供之函式為準

---

## isPopupWin
**使用範例**: `if(window.isPopupWin && window.popupWinBack){`
**輸入**: 無
**輸出**:
- isPopupWin: 布林值 = true - 標示目前視窗是否為 `popupWin.popup()`／`popupWin.fullPopup()` 所開啟之視窗內容
**功能**:
- 供視窗內容自身判斷是否處於本檔案所開啟之視窗環境中

---

## popupWinclose()
**使用範例**: `window.popupWinclose();`
**輸入**: 無
**輸出**: 無
**功能**:
- 於 `popupWin.popup()`／`popupWin.fullPopup()` 所開啟之視窗內容中，關閉自身所在之視窗，行為等同開啟者呼叫 `popupWin.close()`

---

## popupWinBack()
**使用範例**: `window.popupWinBack(data);`
**輸入**:
- obj1 ~ obj0: 混合型別 - 依序傳遞至回呼函式之參數，最多 10 個；**實際使用僅觀察到 0 或 1 個參數**
**輸出**: 無
**功能**:
- 於 `popupWin.popup()`／`popupWin.fullPopup()` 所開啟之視窗內容中，執行已設定之回呼函式並關閉自身所在之視窗，行為等同開啟者呼叫 `popupWin.back()`

---

## callbackHandler()
**使用範例**: `callbackHandler(queryObj);`
**輸入**:
- obj1 ~ obj0: 混合型別 - 依序傳遞至回呼函式之參數，最多 10 個；**實際使用僅觀察到 0 或 1 個參數**
**輸出**: 無
**功能**:
- 於 `popupWin.popup()`／`popupWin.fullPopup()` 所開啟之視窗內容中，執行已設定之回呼函式（不關閉視窗）
- **當開啟視窗時已設定回呼函式（`config.cb`／`config.onBack`／`popupWin.callbackHandler`）時**: 才會提供
