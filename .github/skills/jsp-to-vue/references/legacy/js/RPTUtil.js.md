# RPTUtil.js 公開契約

## 使用語法清單
**方法**:
- [RPTUtil.downloadFile(requestURL, params, isOpenNewBrowse)](#RPTUtil.downloadFile(requestURL,-params,-isOpenNewBrowse))
- [RPTUtil.executeCreateXlsFile(requestURL, params, isOpenNewBrowse)](#RPTUtil.executeCreateXlsFile(requestURL,-params,-isOpenNewBrowse))
- [RPTUtil.executeCreateCsvFile(requestURL, params)](#RPTUtil.executeCreateCsvFile(requestURL,-params))
- [RPTUtil.executePrintByResponse(resp, isOpenNewBrowse)](#RPTUtil.executePrintByResponse(resp,-isOpenNewBrowse))
- [RPTUtil.executePrintByLink(requestURL, params, isOpenNewBrowse)](#RPTUtil.executePrintByLink(requestURL,-params,-isOpenNewBrowse))
- [RPTUtil.download(options)](#RPTUtil.download(options))
- [RPTUtil.executeSecurityPrintHandler(resp, isOpenNewBrowse, beforeActions, isIndependent)](#RPTUtil.executeSecurityPrintHandler(resp,-isOpenNewBrowse,-beforeActions,-isIndependent))
- [RPTUtil.fileWatchDog(requestURL, params)](#RPTUtil.fileWatchDog(requestURL,-params))
- [RPTUtil.fileWatchDog4WaterMark(requestURL, params)](#RPTUtil.fileWatchDog4WaterMark(requestURL,-params))

---

## 共用模式
- 下列各方法之請求皆以同步方式送出；請求失敗時回傳錯誤訊息文字，並於畫面未具備其他錯誤訊息顯示機制時，以提示視窗顯示該訊息；請求成功時無回傳值
- isOpenNewBrowse 參數用於控制下載或列印之目的視窗是否另開新視窗，省略時預設為開啟新視窗

---

## RPTUtil.downloadFile(requestURL, params, isOpenNewBrowse)
**使用範例**: `RPTUtil.downloadFile('${dispatcher}/DSA3_0200/download', {'downloadFileName': bankfile['ATTACH_NM'], 'downloadFileFullPath': toAttachPath}, true);`
**輸入**:
- requestURL: String - 請求路徑
- params: Object - 請求參數
- isOpenNewBrowse: Boolean = true - 是否開啟新視窗
**輸出**:
- **當請求失敗時**: 回傳值: String - 錯誤訊息文字
- **當請求成功時**: 回傳值: undefined - 無
**功能**:
- 以同步方式送出請求，成功後依回應內所設定之檔案名稱與完整路徑，轉送請求至下載服務進行檔案下載

---

## RPTUtil.executeCreateXlsFile(requestURL, params, isOpenNewBrowse)
**使用範例**: `RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSA3_0300/export', Form.serialize("form1"));`
**輸入**:
- requestURL: String - 請求路徑
- params: Object - 請求參數
- isOpenNewBrowse: Boolean = true - 是否開啟新視窗
**輸出**:
- **當請求失敗時**: 回傳值: String - 錯誤訊息文字
- **當請求成功時**: 回傳值: undefined - 無
**功能**:
- 以同步方式送出請求，成功後依回應內所設定之檔案名稱與完整路徑，轉送請求至試算表下載服務進行下載

---

## RPTUtil.executeCreateCsvFile(requestURL, params)
**使用範例**: `RPTUtil.executeCreateCsvFile('${dispatcher}/DSA3_1700/exportXls', exportParams );`
**輸入**:
- requestURL: String - 請求路徑
- params: Object - 請求參數
**輸出**:
- **當請求失敗時**: 回傳值: String - 錯誤訊息文字
- **當請求成功時**: 回傳值: undefined - 無
**功能**:
- 固定以開啟新視窗之方式，執行與 executeCreateXlsFile 相同之下載流程

---

## RPTUtil.executePrintByResponse(resp, isOpenNewBrowse)
**使用範例**: `RPTUtil.executePrintByResponse(resp, true);`
**輸入**:
- resp: Object - 回應資料（JSON 格式），須含報表產生之暫存檔完整路徑等資訊
- isOpenNewBrowse: Boolean = true - 是否開啟新視窗
**輸出**: 無
**功能**:
- 依回應資料中之暫存檔路徑等資訊，送出列印請求

---

## RPTUtil.executePrintByLink(requestURL, params, isOpenNewBrowse)
**使用範例**: `RPTUtil.executePrintByLink('print' , {DEPT_ID: $F('DEPT_ID')}, true );`
**輸入**:
- requestURL: String - 連結路徑
- params: Object - 該連結所需使用之相關參數
- isOpenNewBrowse: Boolean = true - 是否開啟新視窗
**輸出**:
- **當請求失敗時**: 回傳值: String - 錯誤訊息文字
- **當請求成功時**: 回傳值: undefined - 無
**功能**:
- 以同步方式依連結路徑查詢，查詢成功後依回應資料直接送出列印請求

---

## RPTUtil.download(options)
**使用範例**: `RPTUtil.download({'downloadFileName': resp.apprFileNM,	'downloadFileFullPath': resp.apprPath});`
**輸入**:
- options: Object - 下載設定
- options.downloadFileName: String - 加密後之下載檔案名稱
- options.downloadFileFullPath: String - 加密後之下載檔案完整路徑
- options.isOpenNewBrowse: Boolean = true - 是否開啟新視窗
**輸出**: 無
**功能**:
- 依指定之檔案名稱與完整路徑，轉送請求至下載服務進行檔案下載

---

## RPTUtil.executeSecurityPrintHandler(resp, isOpenNewBrowse, beforeActions, isIndependent)
**使用範例**: `RPTUtil.executeSecurityPrintHandler(dataMap,false);`
**輸入**:
- resp: Object - 回應資料（JSON 格式），須含加密暫存檔路徑等資訊
- isOpenNewBrowse: Boolean = true - 是否開啟新視窗
- beforeActions: Object[] - 下載前需先執行之動作清單，每個項目包含 url（必要）與 parameters（非必要）
- isIndependent: Boolean = false - 每次開啟之新視窗是否各自獨立、不重複使用
**輸出**: 無
**功能**:
- 透過安全列印元件開啟報表，依回應資料中之加密檔案路徑、浮水印檔案資訊與下載檔名等設定送出請求

---

## RPTUtil.fileWatchDog(requestURL, params)
**使用範例**: `RPTUtil.fileWatchDog(url, {allrec : Object.toJSON(checkRec)});`
**輸入**:
- requestURL: String - 連結路徑
- params: Object - 該連結所需使用之相關參數，可含 enableWaterMark 設定
**輸出**:
- **當請求失敗時**: 回傳值: String - 錯誤訊息文字
- **當請求成功時**: 回傳值: undefined - 無
**功能**:
- 依查詢結果所回傳之一或多筆加密暫存檔路徑，各自開啟獨立視窗執行檔案下載監控

---

## RPTUtil.fileWatchDog4WaterMark(requestURL, params)
**使用範例**: `RPTUtil.fileWatchDog4WaterMark(url, {allrec : Object.toJSON(checkRec)});`
**輸入**:
- requestURL: String - 連結路徑
- params: Object - 該連結所需使用之相關參數
**輸出**:
- **當請求失敗時**: 回傳值: String - 錯誤訊息文字
- **當請求成功時**: 回傳值: undefined - 無
**功能**:
- 以強制啟用浮水印之設定，執行與 fileWatchDog 相同之檔案下載監控流程
