### AFY1_0400.doDownload(RequestContext) - 下載已產生的檔案

#### 1. 功能描述
- 根據前端傳入的檔案名稱，組合出該交易程式的存檔完整路徑，並透過 `RptUtils.cryptoDownloadParameterToResp` 將檔案以加密方式回應給使用者下載。

#### 2. 輸入 / 輸出參數
- **輸入參數**：
  - `req` (`RequestContext`)：包含前端請求參數，本方法讀取其中的 `fileName`(String)，即欲下載的目標檔名。
- **輸出參數**：
  - `resp` (`ResponseContext`)：類別成員變數，在 `initApp` 中初始化。正常情況下由 `RptUtils` 直接將下載內容寫入其中；例外情況下，`resp` 中的 `msg`(ReturnMessage) 會被設定錯誤碼與訊息後回傳。

#### 3. 業務流程與商業邏輯
1. 從 `req.getParameter("fileName")` 取得欲下載的檔案名稱，存入區域變數 `fileName`(String)。
2. 呼叫 `FileStoreUtil.getSaveDirForTx(this)` 取得本交易程式(AFY1_0400)的專屬存檔目錄，回傳值為 `File` 物件，存入 `target`。
   - 路徑依據 `this` 的 Package Name 自動推算，結構通常為：`ROOT/子系統/次系統/交易代號`。
3. 以 `StringBuilder` 串接 `target.getPath()`、`File.separator`、`fileName`，組成完整的檔案絕對路徑字串 `fileFullPath`(String)。
4. 呼叫 `RptUtils.cryptoDownloadParameterToResp(fileName, fileFullPath, resp)`，將檔案以加密下載方式寫入 `resp`，供使用者瀏覽器下載。
5. 回傳 `resp`。

#### 4. 例外與訊息處理
- `Exception`(所有例外皆被捕捉)：
  - 以 `log.fatal("下載檔案失敗", e)` 記錄嚴重錯誤至 Log。
  - 呼叫 `MessageHelper.setReturnMessage(msg, ReturnCode.ERROR, e.getMessage())`，將 `msg` 設定為 `ReturnCode.ERROR`，訊息內容為例外的 `e.getMessage()`。

#### 5. 內部方法呼叫
- 無。

#### 6. 外部模組 / 方法呼叫

**呼叫 `FileStoreUtil.getSaveDirForTx`**
**目的**：取得 AFY1_0400 交易程式的專屬存檔目錄，作為組合完整下載路徑的基礎。
**參數組成**：
  - `txObj`：傳入 `this`(AFY1_0400 本身)，框架依其 Package Name 自動推算存檔目錄路徑。
**回傳結果處理**：回傳 `File` 物件，賦值給 `target`，後續取 `target.getPath()` 串接檔名。

**呼叫 `RptUtils.cryptoDownloadParameterToResp`**
**目的**：執行檔案加密下載，將指定路徑的檔案內容寫入 `ResponseContext`，使前端瀏覽器觸發下載。
**參數組成**：
  - `fileName`：從 `req.getParameter("fileName")` 取得的檔案名稱字串，作為下載時的呈現檔名。
  - `fileFullPath`：由 `target.getPath()` + `File.separator` + `fileName` 組合的完整絕對路徑字串。
  - `resp`：類別成員變數 `ResponseContext`，由框架作為下載回應的輸出載體。
**回傳結果處理**：無回傳值，下載資料直接寫入 `resp`。


---

