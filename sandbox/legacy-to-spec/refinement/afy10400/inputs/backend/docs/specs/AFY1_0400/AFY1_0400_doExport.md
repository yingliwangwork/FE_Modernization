### AFY1_0400.doExport(RequestContext) - 匯出公會通報下傳 Excel 檔案

#### 1. 功能描述
- 接收前端傳入的被保人ID與對應保單號碼，在進行格式驗證後，呼叫模組查詢公會通報記錄，並將查詢結果產生為 Excel 檔案，最終回傳檔名供前端進行下載。

#### 2. 輸入 / 輸出參數

**輸入參數**（均透過 `req` 取得）：

| 參數名稱 | 型態 | 取得方式 | 說明 |
|---------|------|---------|------|
| `insrType` | `String` | `req.getParameter("insrType")` | 險種類型代碼 |
| `prodType` | `String` | `req.getParameter("prodType")` | 商品類型代碼 |
| `I_ID` | `String[]` | `req.getParameterValues("I_ID")` | 被保人ID陣列，每個元素為一筆被保人的身分證字號 |
| `POLICY_NO` | `String[]` | `req.getParameterValues("POLICY_NO")` | 保單號碼陣列，索引與 `I_ID` 對應，每個元素可包含多筆保單號碼（以 `\r\n` 分隔） |

**輸出資料**（寫入 `resp` 的 OutputData）：

| 鍵名 | 型態 | 說明 |
|-----|------|------|
| `rtnMap` | `Map<String, String>` | key 為被保人ID（`I_ID[i]`），value 為驗證結果訊息，成功為 `"已匯出"`，失敗為錯誤說明字串 |
| `fileName` | `String` | 產出的 Excel 檔案名稱，格式為 `prodType + insrType + "_" + yyyymmdd + ".xlsx"` |

**回傳值**：`ResponseContext resp`

#### 3. 業務流程與商業邏輯

**步驟一：取得請求參數**
從 `req` 取得 `insrType`、`prodType`（單值字串）以及 `I_ID`、`POLICY_NO`（多值字串陣列）。初始化 `StringBuffer sb`、`Map<String, String> rtnMap`、`List<String> policyList`。

**步驟二：前置數量一致性檢查**
若 `I_ID == null` 或 `POLICY_NO == null` 或兩者 `length` 不相等，則拋出 `ErrorInputException`，訊息為 `"第N列的被保人ID或保單號碼不得為空值，若不需要請刪除該列"`。

**步驟三：逐筆格式驗證（loop 遍歷 `I_ID` 陣列，索引 `i = 0` 至 `I_ID.length - 1`）**

1. 若 `I_ID[i].trim().length() != 10`，對 `sb` 追加 `"ID長度預為10碼"`。
2. 若 `POLICY_NO[i].length() == 0`，對 `sb` 追加 `"保單號碼不得為空值"`。
3. 將 `POLICY_NO[i]` 以 `"\r\n"` 分割，過濾空白項目後，將每筆有效保單號碼加入 `policyList`。
4. 將 `I_ID[i]` 與 `sb` 目前累積的訊息（錯誤內容或空字串）存入 `rtnMap`：`rtnMap.put(I_ID[i], sb.toString())`。
5. 呼叫 `sb.setLength(0)` 重置 `sb`，供下一筆使用。

完成 loop 後，呼叫 `resp.addOutputData("rtnMap", rtnMap)` 先行輸出初步驗證結果。

**步驟四：後置 sb 長度判斷**
若 `sb.length() > 0`（因 loop 末尾已 reset，此判斷在正常流程下不會成立），拋出 `ErrorInputException`，訊息為 `"檢核錯誤"`。

**步驟五：準備查詢參數**
將 `policyList` 轉為 `String[] POLICY_NOs`：`policyList.toArray(new String[0])`。

**步驟六：記錄安全日誌**
呼叫同類別的內部方法 `logSecurity(I_ID)`，傳入完整的被保人ID陣列，記錄本次查詢的操作日誌（詳見第 5 章）。

**步驟七：查詢公會通報記錄**
呼叫 `mod.doQuery(insrType, prodType, I_ID, POLICY_NOs)` 向模組查詢，回傳 `List<Map> rtnList`，每個 `Map` 代表一筆公會通報記錄（詳見第 6 章）。

**步驟八：比對查詢結果，組裝回應 Map**

雙層 loop 遍歷每個被保人及其保單號碼，確認查詢結果中是否存在對應記錄：

- 外層 loop 遍歷 `I_ID[]`（索引 `i`），取得 `id = I_ID[i]`。
- 內層 loop 將 `POLICY_NO[i]` 以 `"\r\n"` 分割後逐一遍歷，取得 `policy_no`（非空值）。
- 對每個 `(id, policy_no)` 組合，在 `rtnList` 中逐筆比對：
  - 若 `rtnList` 中某筆 Map 的 `"I_ID"` 等於 `id` **且** `"MAIN_POLICY_NO"` 等於 `policy_no`（使用 `StringUtils.equals` 比對），則設 `key = true` 並跳出比對。
  - 若無任何一筆符合（`key = false`），則對 `sb` 追加 `"被保人：" + id + " 查無保單號碼：" + policy_no + "。"`；若 `sb` 已有內容，在追加前先插入 `"<br>"`。
- 內層 loop 結束後判斷 `sb.length()`：
  - `sb.length() == 0` → 代表該被保人所有保單均查到 → `rtnMap.put(id, "已匯出")`。
  - `sb.length() > 0` → 代表有部分保單查無記錄 → `rtnMap.put(id, sb.toString())`，訊息為各查無保單的描述（以 `<br>` 串接）。
- 呼叫 `sb.setLength(0)` 重置。

完成後再次呼叫 `resp.addOutputData("rtnMap", rtnMap)` 更新輸出（覆蓋步驟三的初步結果）。

**步驟九：空結果攔截**
以 `log.fatal` 記錄 `rtnList` 內容。若 `rtnList.isEmpty()`，拋出 `Exception`，訊息為 `"查無資料"`。

**步驟十：組裝 Excel 檔名與路徑**

1. 取得今日日期：呼叫 `DATE.getDBDate()` 取得西元日期字串（格式 `"YYYY-MM-DD"`），再呼叫 `replaceAll("-", "")` 去除分隔符，得到 `date_ser_no`（例如 `"20231209"`）。
2. 取得儲存目錄：呼叫 `FileStoreUtil.getSaveDirForTx(this)` 取得本次交易的目標儲存目錄 `File target`。
3. 組裝檔名：`fileName = prodType + insrType + "_" + date_ser_no + ".xlsx"`，例如 `"A001B_20231209.xlsx"`。
4. 組裝完整路徑：`fileFullPath = target.getPath() + File.separator + fileName`。
5. 以 `log.fatal` 分別記錄 `fileName` 與 `fileFullPath`。

**步驟十一：產生 Excel 並輸出檔名**
呼叫 `mod.createExcel(rtnList, fileFullPath)` 依查詢結果產生 Excel 檔案至指定路徑（詳見第 6 章）。
呼叫 `resp.addOutputData("fileName", fileName)` 將檔名寫入 response，供前端下載使用。

#### 4. 例外與訊息處理

- `ErrorInputException`（步驟二）：
  - 觸發條件：`I_ID == null` 或 `POLICY_NO == null` 或兩者陣列長度不相等。
  - 訊息：`"第N列的被保人ID或保單號碼不得為空值，若不需要請刪除該列"`。
- `ErrorInputException`（步驟四）：
  - 觸發條件：後置 `sb.length() > 0`（正常流程下不觸發）。
  - 訊息：`"檢核錯誤"`。
- `Exception`（步驟九）：
  - 觸發條件：`rtnList.isEmpty()` 為 true。
  - 訊息：`"查無資料"`。
- 其他 `Exception`（catch 區塊）：
  - 呼叫 `log.fatal("匯出檔案失敗", e)` 記錄完整 stack trace。
  - 呼叫 `MessageHelper.setReturnMessage(msg, ReturnCode.ERROR, e.getMessage())` 設定回應碼為 `ERROR` 並帶入例外訊息。

#### 5. 內部方法呼叫

**呼叫 `logSecurity`**
**目的**：記錄本次查詢的安全操作日誌，供稽核追蹤。
**參數組成**：
  - `I_ID`：被保人ID字串陣列，直接傳入自 `req.getParameterValues("I_ID")` 取得的原始陣列。
**回傳結果處理**：無回傳值。

#### 6. 外部模組 / 方法呼叫

**呼叫 `AFY1_0400_mod.doQuery`**
**目的**：查詢曾有公會通報記錄（不論成功或失敗）的資料清單。
**參數組成**：
  - `insrType`：險種類型代碼，來自 `req.getParameter("insrType")`。
  - `prodType`：商品類型代碼，來自 `req.getParameter("prodType")`。
  - `I_ID`：被保人ID陣列，來自 `req.getParameterValues("I_ID")`。
  - `POLICY_NOs`：經 `policyList` 整理後轉換的保單號碼陣列（已去除空值並展平 `\r\n` 分隔的多筆保單）。
**回傳結果處理**：
  - 回傳 `List<Map> rtnList`，每個 Map 代表一筆通報記錄，後續讀取欄位包含：`"I_ID"`（被保人ID）、`"MAIN_POLICY_NO"`（主保單號碼）。

**呼叫 `AFY1_0400_mod.createExcel`**
**目的**：依查詢結果 `rtnList` 產生 Excel 檔案並寫入指定路徑。
**參數組成**：
  - `rtnList`：`mod.doQuery` 回傳的完整查詢結果清單。
  - `fileFullPath`：完整的目標檔案路徑字串，由交易儲存目錄與組裝後的檔名拼接而成。
**回傳結果處理**：無回傳值；若產生失敗，拋出 `ModuleException` 由外層 catch 處理。


---

### AFY1_0400.logSecurity(String[]) - 批次安全稽核記錄

#### 1. 功能描述
- 接收一組被保人ID陣列，對其中每筆ID逐一建立稽核記錄物件，並委派給父類別 `UCBean` 的 `logSecurity(Map)` 方法執行實際的安全稽核記錄寫入。

#### 2. 輸入 / 輸出參數
- **輸入參數**：
  - `IDs`（`String[]`）：被保人ID陣列，由呼叫端 `doExport` 透過 `req.getParameterValues("I_ID")` 取得後傳入。
- **輸出參數**：
  - 無回傳值（`void`）。

#### 3. 業務流程與商業邏輯
1. **前置檢查**：判斷 `IDs` 是否不為 `null` 且 `IDs.length > 0`；若不符合（即陣列為空或 `null`），則直接結束，不執行任何記錄。
2. **建立記錄容器**：建立一個 `HashMap<String, String>` 物件 `logMap`，供迴圈中每次組裝記錄資料使用。
3. **逐筆迴圈處理**：遍歷 `IDs` 陣列中每個 `ID`，執行以下步驟：
   - 以 `ObjectUtils.toString(ID)` 將當前 `ID` 轉換為字串，並以鍵值 `"ID"` 存入 `logMap`（每次迭代覆寫同一個 `logMap` 的 `"ID"` 欄位）。
   - 呼叫 `logSecurity(logMap)`，將組裝好的 `logMap` 傳入，執行該筆 ID 的安全稽核記錄。

#### 4. 例外與訊息處理
- 本方法無任何例外捕捉或錯誤訊息處理邏輯，若呼叫鏈中發生例外，將直接向上拋出至呼叫端。

#### 5. 內部方法呼叫
- 無。

#### 6. 外部模組 / 方法呼叫

**呼叫 `UCBean.logSecurity`**  
**目的**：對單一被保人ID執行安全稽核記錄。  
**參數組成**：
  - `logMap`：`HashMap<String, String>`，為每次迴圈中動態組裝的記錄物件，包含以下欄位：
    - `"ID"`：當前迭代的被保人ID，以 `ObjectUtils.toString(ID)` 轉換後填入。  

**回傳結果處理**：無回傳值。


---

### AFY1_0400_mod.doQuery(String, String, String[], String[]) - 依承保/收件別與商品屬性查詢保單資料

#### 1. 功能描述
- 接收承保/收件別 (`insrType`)、商品屬性 (`prodType`)、身分證號陣列 (`I_IDs`) 及主契約保單號陣列 (`POLICY_NOs`) 為查詢條件，依 `insrType` 與 `prodType` 的組合分別存取現況資料表與歷史資料表，將兩批結果合併後回傳保單資料清單；意外險 (`"CB"`) 僅查詢現況資料表，不合併歷史資料。

#### 2. 輸入 / 輸出參數
**輸入參數**：
- `insrType` (String)：承保/收件別。合法值：`"L"`(承保) 或 `"R"`(收件)。
- `prodType` (String)：商品屬性。合法值：`"AT"`(個險)、`"BG"`(團險)、`"CB"`(意外險)。
- `I_IDs` (String[])：身分證號陣列，對應各 SQL 中 `in:I_ID` 多值條件。
- `POLICY_NOs` (String[])：主契約保單號陣列，對應各 SQL 中 `in:MAIN_POLICY_NO` 多值條件。

**輸出參數**：
- `List<Map>`：每筆 Map 代表一筆保單資料，可觀測欄位如下：
  - `INSR_TYPE` (String)：承保/收件別。承保資料表查詢結果固定為 `"L"`，收件資料表查詢結果固定為 `"R"`。
  - `CMNY_CODE` (String)：公司代碼，固定為 `"04"`。
  - `I_NAME`、`I_ID`、`I_BIRTHDAY`、`I_GENDER`：要保人姓名、身分證號、生日、性別。
  - `MAIN_POLICY_NO`：主契約保單號。
  - `POLICY_NO`：保單號。
  - `OIU_IND`、`SALE_CHNL`、`PROD_CODE`、`POLICY_CAT`、`POLICY_DUTY`、`PROD_KIND`：商品相關欄位。
  - `PAY_TYPE`、`PAY_AMT1`-`PAY_AMT19`、`PREM`、`PAY_FREQ`、`PAY_PERIOD`：繳費相關欄位。
  - `ISSUE_DATE`、`ISSUE_TIME`、`LPS_DATE`、`LPS_TIME`：保單日期時間。
  - `STATUS`、`LST_CHG_DATE`、`LST_CHG_TIME`：狀態與最後異動時間。
  - `A_NAME`、`A_ID`、`A_BIRTHDAY`、`RELATION`：被保人姓名、身分證號、生日、關係。
  - `SIGN_DATE` (String)：簽單日。來源為承保別 (`insrType = "L"`) 的資料時，固定為空字串；來源為收件別 (`insrType = "R"`) 的資料時，為資料表實際欄位值。
  - `BROKTYPE` (String)：經紀人類型。規則同 `SIGN_DATE`，承保別來源固定為空字串，收件別來源為實際值。
  - `MEMO` (String)：備註，資料庫原始值中的半形逗號 `,` 已替換為全形逗號 `，`。
  - `ERR_TYPE` (String)：錯誤類型。若 `MEMO LIKE '第%筆%'`，則為 `"內部偵錯"`；否則為 `"公會偵錯"`。
  - `OUTPUT_TIME`：輸出時間。
  - `SER_NO`：序號。

#### 3. 業務流程與商業邏輯

1. **取得資料庫連線**：
   - 呼叫父類別方法 `getDataSet()` 取得現況資料庫的 `DataSet`，命名為 `ds`。
   - 呼叫父類別方法 `getHISDataSet()` 取得歷史資料庫的 `DataSet`，命名為 `his_ds`。

2. **設定現況 `ds` 的查詢條件**：
   - 呼叫 `ds.clear()` 清除先前的所有參數設定。
   - 呼叫 `ds.setFieldValues("I_ID", I_IDs)` 將身分證號陣列設定為多值查詢條件，供 SQL 中 `in:I_ID` 使用。
   - 呼叫 `ds.setFieldValues("MAIN_POLICY_NO", POLICY_NOs)` 將主契約保單號陣列設定為多值查詢條件，供 SQL 中 `in:MAIN_POLICY_NO` 使用。

3. **依 `insrType` 判斷承保/收件別，再依 `prodType` 判斷商品屬性，執行對應查詢**：

   **當 `insrType = "L"`(承保) 時**：

   - **當 `prodType = "AT"`(個險) 時**：
     - 呼叫 `DBUtil.searchAndRetrieve(ds, SQL_QUERY_DTAFA031, false)` 查詢現況個險承保資料表 `DBAF.DTAFA031`；`false` 表示查無資料時不拋出例外。
     - 呼叫 `VOTool.dataSetToMaps(ds)` 將 `ds` 中的查詢結果轉換為 `List<Map>`，存入 `list`。
     - 呼叫 `his_ds.clear()`，清除歷史 DataSet 的先前參數設定。
     - 呼叫 `his_ds.setFieldValues("I_ID", I_IDs)` 及 `his_ds.setFieldValues("MAIN_POLICY_NO", POLICY_NOs)` 重新設定查詢條件。
     - 呼叫 `DBUtil.searchAndRetrieve(his_ds, SQL_QUERY_HTAFA031, false)` 查詢歷史個險承保資料表 `DBAF.HTAFA031`，查無資料不拋出例外。
     - 呼叫 `VOTool.dataSetToMaps(his_ds)` 將歷史結果轉換為 `List<Map>`，存入 `list2`。
     - 呼叫 `list.addAll(list2)` 將現況與歷史清單合併至 `list`，回傳 `list`。

   - **當 `prodType = "BG"`(團險) 時**：
     - 呼叫 `DBUtil.searchAndRetrieve(ds, SQL_QUERY_DTAFA031_BG, false)` 查詢現況團險承保資料表 `DBAF.DTAFA031_BG`，查無資料不拋出例外。
     - 呼叫 `VOTool.dataSetToMaps(ds)` 轉換為 `list`。
     - 對 `his_ds` 執行 `clear()` 後重設 `I_ID` 與 `MAIN_POLICY_NO`，呼叫 `DBUtil.searchAndRetrieve(his_ds, SQL_QUERY_HTAFA031_BG, false)` 查詢歷史團險承保資料表 `DBAF.HTAFA031_BG`，查無資料不拋出例外。
     - 呼叫 `VOTool.dataSetToMaps(his_ds)` 轉換為 `list2`，呼叫 `list.addAll(list2)` 合併後回傳 `list`。

   - **當 `prodType = "CB"`(意外險) 時**：
     - 呼叫 `DBUtil.searchAndRetrieve(ds, SQL_QUERY_DTAFA031_CB, false)` 查詢現況意外險承保資料表 `DBAF.DTAFA031_CB`，查無資料不拋出例外。
     - 直接呼叫 `VOTool.dataSetToMaps(ds)` 轉換後回傳，**不查詢歷史資料表，也不合併歷史資料**。

   - **其他 `prodType`**：拋出 `ErrorInputException("商品屬性錯誤:" + prodType)`，例如傳入 `"XX"` 時訊息為 `"商品屬性錯誤:XX"`。

   **當 `insrType = "R"`(收件) 時**：

   - **當 `prodType = "AT"`(個險) 時**：
     - 呼叫 `DBUtil.searchAndRetrieve(ds, SQL_QUERY_DTAFA032, false)` 查詢現況個險收件資料表 `DBAF.DTAFA032`，查無資料不拋出例外。
     - 呼叫 `VOTool.dataSetToMaps(ds)` 轉換為 `list`。
     - 對 `his_ds` 執行 `clear()` 後重設 `I_ID` 與 `MAIN_POLICY_NO`，呼叫 `DBUtil.searchAndRetrieve(his_ds, SQL_QUERY_HTAFA032, false)` 查詢歷史個險收件資料表 `DBAF.HTAFA032`，查無資料不拋出例外。
     - 呼叫 `VOTool.dataSetToMaps(his_ds)` 轉換為 `list2`，呼叫 `list.addAll(list2)` 合併後回傳 `list`。

   - **當 `prodType = "BG"`(團險) 時**：
     - 呼叫 `DBUtil.searchAndRetrieve(ds, SQL_QUERY_DTAFA032_BG, false)` 查詢現況團險收件資料表 `DBAF.DTAFA032_BG`，查無資料不拋出例外。
     - 呼叫 `VOTool.dataSetToMaps(ds)` 轉換為 `list`。
     - 對 `his_ds` 執行 `clear()` 後重設 `I_ID` 與 `MAIN_POLICY_NO`，呼叫 `DBUtil.searchAndRetrieve(his_ds, SQL_QUERY_HTAFA032_BG, false)` 查詢歷史團險收件資料表 `DBAF.HTAFA032_BG`，查無資料不拋出例外。
     - 呼叫 `VOTool.dataSetToMaps(his_ds)` 轉換為 `list2`，呼叫 `list.addAll(list2)` 合併後回傳 `list`。

   - **當 `prodType = "CB"`(意外險) 時**：
     - 呼叫 `DBUtil.searchAndRetrieve(ds, SQL_QUERY_DTAFA032_CB, false)` 查詢現況意外險收件資料表 `DBAF.DTAFA032_CB`，查無資料不拋出例外。
     - 直接呼叫 `VOTool.dataSetToMaps(ds)` 轉換後回傳，**不查詢歷史資料表，也不合併歷史資料**。

   - **其他 `prodType`**：拋出 `ErrorInputException("商品屬性錯誤:" + prodType)`。

   **其他 `insrType`**：拋出 `ErrorInputException("收承方式錯誤:" + insrType)`，例如傳入 `"X"` 時訊息為 `"收承方式錯誤:X"`。

#### 4. 例外與訊息處理
整個方法體被單一 `catch (Exception e)` 包覆，所有例外（含 `ErrorInputException`）均依以下方式統一處理：
- 以 `log.fatal("查詢失敗", e)` 記錄 FATAL 等級日誌。
- 拋出 `ModuleException("查詢失敗", e)`，原始例外作為 cause 保留。

觸發 `ErrorInputException` 的條件與訊息：
- `insrType` 不為 `"L"` 或 `"R"` 時：訊息為 `"收承方式錯誤:" + insrType`。
- `prodType` 不為 `"AT"`、`"BG"` 或 `"CB"` 時（無論 `insrType` 為何值）：訊息為 `"商品屬性錯誤:" + prodType`。

#### 5. 內部方法呼叫
本方法無呼叫同類別的 private / protected 方法。

#### 6. 外部模組 / 方法呼叫
本方法僅使用 `DBUtil`、`VOTool`、`DataSet` 等框架工具，無其他業務邏輯模組呼叫。

#### 7. SQL 語句使用清單

**`SQL_QUERY_DTAFA031`**
```sql
SELECT 'L' AS INSR_TYPE, '04' AS CMNY_CODE, I_NAME, I_ID, I_BIRTHDAY, I_GENDER, MAIN_POLICY_NO, POLICY_NO, OIU_IND, SALE_CHNL, PROD_CODE, POLICY_CAT, POLICY_DUTY, PROD_KIND, PAY_TYPE, 
       PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, 
       PAY_AMT18, PAY_AMT19, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, PREM,  PAY_FREQ, PAY_PERIOD, STATUS, LST_CHG_DATE, LST_CHG_TIME, A_NAME, A_ID, A_BIRTHDAY, RELATION, '' AS SIGN_DATE, 
       '' AS BROKTYPE, REPLACE(MEMO,',','，') AS MEMO, CASE WHEN MEMO LIKE '第%筆%' THEN '內部偵錯' ELSE '公會偵錯' END AS ERR_TYPE, OUTPUT_TIME, SER_NO
  FROM DBAF.DTAFA031
 WHERE I_ID = 'in:I_ID' AND MAIN_POLICY_NO = 'in:MAIN_POLICY_NO'
```

**`SQL_QUERY_HTAFA031`**
```sql
SELECT 'L' AS INSR_TYPE, '04' AS CMNY_CODE, I_NAME, I_ID, I_BIRTHDAY, I_GENDER, MAIN_POLICY_NO, POLICY_NO, OIU_IND, SALE_CHNL, PROD_CODE, POLICY_CAT, POLICY_DUTY, PROD_KIND, PAY_TYPE, 
       PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, 
       PAY_AMT18, PAY_AMT19, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, PREM,  PAY_FREQ, PAY_PERIOD, STATUS, LST_CHG_DATE, LST_CHG_TIME, A_NAME, A_ID, A_BIRTHDAY, RELATION, '' AS SIGN_DATE, 
       '' AS BROKTYPE, REPLACE(MEMO,',','，') AS MEMO, CASE WHEN MEMO LIKE '第%筆%' THEN '內部偵錯' ELSE '公會偵錯' END AS ERR_TYPE, OUTPUT_TIME, SER_NO
  FROM DBAF.HTAFA031
 WHERE I_ID = 'in:I_ID' AND MAIN_POLICY_NO = 'in:MAIN_POLICY_NO'
```

**`SQL_QUERY_DTAFA031_BG`**
```sql
SELECT 'L' AS INSR_TYPE, '04' AS CMNY_CODE, I_NAME, I_ID, I_BIRTHDAY, I_GENDER, MAIN_POLICY_NO, POLICY_NO, OIU_IND, SALE_CHNL, PROD_CODE, POLICY_CAT, POLICY_DUTY, PROD_KIND, PAY_TYPE, 
       PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, 
       PAY_AMT18, PAY_AMT19, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, PREM,  PAY_FREQ, PAY_PERIOD, STATUS, LST_CHG_DATE, LST_CHG_TIME, A_NAME, A_ID, A_BIRTHDAY, RELATION, '' AS SIGN_DATE, 
       '' AS BROKTYPE, REPLACE(MEMO,',','，') AS MEMO, CASE WHEN MEMO LIKE '第%筆%' THEN '內部偵錯' ELSE '公會偵錯' END AS ERR_TYPE, OUTPUT_TIME, SER_NO
  FROM DBAF.DTAFA031_BG
 WHERE I_ID = 'in:I_ID' AND MAIN_POLICY_NO = 'in:MAIN_POLICY_NO'
```

**`SQL_QUERY_HTAFA031_BG`**
```sql
SELECT 'L' AS INSR_TYPE, '04' AS CMNY_CODE, I_NAME, I_ID, I_BIRTHDAY, I_GENDER, MAIN_POLICY_NO, POLICY_NO, OIU_IND, SALE_CHNL, PROD_CODE, POLICY_CAT, POLICY_DUTY, PROD_KIND, PAY_TYPE, 
       PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, 
       PAY_AMT18, PAY_AMT19, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, PREM,  PAY_FREQ, PAY_PERIOD, STATUS, LST_CHG_DATE, LST_CHG_TIME, A_NAME, A_ID, A_BIRTHDAY, RELATION, '' AS SIGN_DATE, 
       '' AS BROKTYPE, REPLACE(MEMO,',','，') AS MEMO, CASE WHEN MEMO LIKE '第%筆%' THEN '內部偵錯' ELSE '公會偵錯' END AS ERR_TYPE, OUTPUT_TIME, SER_NO
  FROM DBAF.HTAFA031_BG
 WHERE I_ID = 'in:I_ID' AND MAIN_POLICY_NO = 'in:MAIN_POLICY_NO'
```

**`SQL_QUERY_DTAFA031_CB`**
```sql
SELECT 'L' AS INSR_TYPE, '04' AS CMNY_CODE, I_NAME, I_ID, I_BIRTHDAY, I_GENDER, MAIN_POLICY_NO, POLICY_NO, OIU_IND, SALE_CHNL, PROD_CODE, POLICY_CAT, POLICY_DUTY, PROD_KIND, PAY_TYPE, 
       PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, 
       PAY_AMT18, PAY_AMT19, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, PREM,  PAY_FREQ, PAY_PERIOD, STATUS, LST_CHG_DATE, LST_CHG_TIME, A_NAME, A_ID, A_BIRTHDAY, RELATION, '' AS SIGN_DATE, 
       '' AS BROKTYPE, REPLACE(MEMO,',','，') AS MEMO, CASE WHEN MEMO LIKE '第%筆%' THEN '內部偵錯' ELSE '公會偵錯' END AS ERR_TYPE, OUTPUT_TIME, SER_NO
  FROM DBAF.DTAFA031_CB
 WHERE I_ID = 'in:I_ID' AND MAIN_POLICY_NO = 'in:MAIN_POLICY_NO'
```

**`SQL_QUERY_DTAFA032`**
```sql
SELECT 'R' AS INSR_TYPE, '04' AS CMNY_CODE, I_NAME, I_ID, I_BIRTHDAY, I_GENDER, MAIN_POLICY_NO, POLICY_NO, OIU_IND, SALE_CHNL, PROD_CODE, POLICY_CAT, POLICY_DUTY, PROD_KIND, PAY_TYPE, 
       PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, 
       PAY_AMT18, PAY_AMT19, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, PREM,  PAY_FREQ, PAY_PERIOD, STATUS, LST_CHG_DATE, LST_CHG_TIME, A_NAME, A_ID, A_BIRTHDAY, RELATION, SIGN_DATE, 
       BROKTYPE, REPLACE(MEMO,',','，') AS MEMO, CASE WHEN MEMO LIKE '第%筆%' THEN '內部偵錯' ELSE '公會偵錯' END AS ERR_TYPE, OUTPUT_TIME, SER_NO
  FROM DBAF.DTAFA032
 WHERE I_ID = 'in:I_ID' AND MAIN_POLICY_NO = 'in:MAIN_POLICY_NO'
```

**`SQL_QUERY_HTAFA032`**
```sql
SELECT 'R' AS INSR_TYPE, '04' AS CMNY_CODE, I_NAME, I_ID, I_BIRTHDAY, I_GENDER, MAIN_POLICY_NO, POLICY_NO, OIU_IND, SALE_CHNL, PROD_CODE, POLICY_CAT, POLICY_DUTY, PROD_KIND, PAY_TYPE, 
       PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, 
       PAY_AMT18, PAY_AMT19, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, PREM,  PAY_FREQ, PAY_PERIOD, STATUS, LST_CHG_DATE, LST_CHG_TIME, A_NAME, A_ID, A_BIRTHDAY, RELATION, SIGN_DATE, 
       BROKTYPE, REPLACE(MEMO,',','，') AS MEMO, CASE WHEN MEMO LIKE '第%筆%' THEN '內部偵錯' ELSE '公會偵錯' END AS ERR_TYPE, OUTPUT_TIME, SER_NO
  FROM DBAF.HTAFA032
 WHERE I_ID = 'in:I_ID' AND MAIN_POLICY_NO = 'in:MAIN_POLICY_NO'
```

**`SQL_QUERY_DTAFA032_BG`**
```sql
SELECT 'R' AS INSR_TYPE, '04' AS CMNY_CODE, I_NAME, I_ID, I_BIRTHDAY, I_GENDER, MAIN_POLICY_NO, POLICY_NO, OIU_IND, SALE_CHNL, PROD_CODE, POLICY_CAT, POLICY_DUTY, PROD_KIND, PAY_TYPE, 
       PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, 
       PAY_AMT18, PAY_AMT19, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, PREM,  PAY_FREQ, PAY_PERIOD, STATUS, LST_CHG_DATE, LST_CHG_TIME, A_NAME, A_ID, A_BIRTHDAY, RELATION, SIGN_DATE, 
       BROKTYPE, REPLACE(MEMO,',','，') AS MEMO, CASE WHEN MEMO LIKE '第%筆%' THEN '內部偵錯' ELSE '公會偵錯' END AS ERR_TYPE, OUTPUT_TIME, SER_NO
  FROM DBAF.DTAFA032_BG
 WHERE I_ID = 'in:I_ID' AND MAIN_POLICY_NO = 'in:MAIN_POLICY_NO'
```

**`SQL_QUERY_HTAFA032_BG`**
```sql
SELECT 'R' AS INSR_TYPE, '04' AS CMNY_CODE, I_NAME, I_ID, I_BIRTHDAY, I_GENDER, MAIN_POLICY_NO, POLICY_NO, OIU_IND, SALE_CHNL, PROD_CODE, POLICY_CAT, POLICY_DUTY, PROD_KIND, PAY_TYPE, 
       PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, 
       PAY_AMT18, PAY_AMT19, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, PREM,  PAY_FREQ, PAY_PERIOD, STATUS, LST_CHG_DATE, LST_CHG_TIME, A_NAME, A_ID, A_BIRTHDAY, RELATION, SIGN_DATE, 
       BROKTYPE, REPLACE(MEMO,',','，') AS MEMO, CASE WHEN MEMO LIKE '第%筆%' THEN '內部偵錯' ELSE '公會偵錯' END AS ERR_TYPE, OUTPUT_TIME, SER_NO
  FROM DBAF.HTAFA032_BG
 WHERE I_ID = 'in:I_ID' AND MAIN_POLICY_NO = 'in:MAIN_POLICY_NO'
```

**`SQL_QUERY_DTAFA032_CB`**
```sql
SELECT 'R' AS INSR_TYPE, '04' AS CMNY_CODE, I_NAME, I_ID, I_BIRTHDAY, I_GENDER, MAIN_POLICY_NO, POLICY_NO, OIU_IND, SALE_CHNL, PROD_CODE, POLICY_CAT, POLICY_DUTY, PROD_KIND, PAY_TYPE, 
       PAY_AMT1, PAY_AMT2, PAY_AMT3, PAY_AMT4, PAY_AMT5, PAY_AMT6, PAY_AMT7, PAY_AMT8, PAY_AMT9, PAY_AMT10, PAY_AMT11, PAY_AMT12, PAY_AMT13, PAY_AMT14, PAY_AMT15, PAY_AMT16, PAY_AMT17, 
       PAY_AMT18, PAY_AMT19, ISSUE_DATE, ISSUE_TIME, LPS_DATE, LPS_TIME, PREM,  PAY_FREQ, PAY_PERIOD, STATUS, LST_CHG_DATE, LST_CHG_TIME, A_NAME, A_ID, A_BIRTHDAY, RELATION, SIGN_DATE, 
       BROKTYPE, REPLACE(MEMO,',','，') AS MEMO, CASE WHEN MEMO LIKE '第%筆%' THEN '內部偵錯' ELSE '公會偵錯' END AS ERR_TYPE, OUTPUT_TIME, SER_NO
  FROM DBAF.DTAFA032_CB
 WHERE I_ID = 'in:I_ID' AND MAIN_POLICY_NO = 'in:MAIN_POLICY_NO'
```


---

### AFY1_0400_mod.createExcel(List, String) - 產生公會補通報資料 Excel 檔

#### 1. 功能描述
- 將傳入的保單資料清單輸出為 Excel (.xlsx) 檔案，並將檔案寫出至指定的完整路徑。
- Excel 第一列為固定欄位標題(共 54 欄)，第二列起依序填入每筆保單資料。
- 日期欄位統一轉換為民國年 8 位格式(YYYMMDD)；時間欄位統一去除冒號後輸出。

#### 2. 輸入 / 輸出參數
**輸入參數：**
- `list`：`List<Map>`，保單資料清單，每個 `Map` 代表一筆資料，key 對應欄位代碼(如 `I_ID`、`POLICY_NO` 等)。
- `fileFullPath`：`String`，輸出 Excel 檔案的完整路徑(含檔名)，例如：`D:\output\report_20221003.xlsx`。

**輸出：**
- 無回傳值 (`void`)。
- 以 `FileOutputStream` 寫出 xlsx 檔案至 `fileFullPath` 所指定的路徑。

**欄位對照(54 欄，索引 0–53)：**

| 索引 | 標題 | 欄位代碼 | 備註 |
|-----|------|---------|------|
| 0 | 產壽險別 | INSR_TYPE | |
| 1 | 公司代號 | CMNY_CODE | |
| 2 | 被保險人姓名 | I_NAME | |
| 3 | 被保險人身分證號碼 | I_ID | |
| 4 | 被保險人出生日期 | I_BIRTHDAY | 日期欄位 |
| 5 | 被保險人性別 | I_GENDER | |
| 6 | 主約保單號碼 | MAIN_POLICY_NO | |
| 7 | 保單號碼 | POLICY_NO | |
| 8 | 來源別OIU | OIU_IND | |
| 9 | 銷售通路別 | SALE_CHNL | |
| 10 | 商品代碼 | PROD_CODE | |
| 11 | 保單分類 | POLICY_CAT | |
| 12 | 險種分類 | POLICY_DUTY | |
| 13 | 險種 | PROD_KIND | |
| 14 | 公、自費件 | PAY_TYPE | |
| 15 | 給付項目(身故) | PAY_AMT1 | |
| 16 | 給付項目(完全失能或最高級失能) | PAY_AMT2 | |
| 17 | 給付項目(失能扶助金) | PAY_AMT3 | |
| 18 | 給付項目(特定事故保險金) | PAY_AMT4 | |
| 19 | 給付項目(初次罹患) | PAY_AMT5 | |
| 20 | 給付項目(醫療限額) | PAY_AMT6 | |
| 21 | 給付項目(醫療限額自負額) | PAY_AMT7 | |
| 22 | 給付項目(日額) | PAY_AMT8 | |
| 23 | 給付項目(住院手術) | PAY_AMT9 | |
| 24 | 給付項目(門診手術) | PAY_AMT10 | |
| 25 | 給付項目(門診) | PAY_AMT11 | |
| 26 | 給付項目(重大疾病(含特定傷病) | PAY_AMT12 | |
| 27 | 給付項目(重大燒燙傷) | PAY_AMT13 | |
| 28 | 給付項目(癌症療養) | PAY_AMT14 | |
| 29 | 給付項目(出院療養) | PAY_AMT15 | |
| 30 | 給付項目(喪失工作能力) | PAY_AMT16 | |
| 31 | 給付項目(喪葬費用) | PAY_AMT17 | |
| 32 | 給付項目(銜接原醫療限額之自負額) | PAY_AMT18 | |
| 33 | 給付項目(分期給付) | PAY_AMT19 | |
| 34 | 契約生效日期 | ISSUE_DATE | 日期欄位 |
| 35 | 契約生效時分 | ISSUE_TIME | 時間欄位 |
| 36 | 契約滿期日期 | LPS_DATE | 日期欄位 |
| 37 | 契約滿期時分 | LPS_TIME | 時間欄位 |
| 38 | 保費 | PREM | |
| 39 | 保費繳別 | PAY_FREQ | |
| 40 | 保費繳費年期 | PAY_PERIOD | |
| 41 | 保單狀況 | STATUS | |
| 42 | 保單狀況生效日期 | LST_CHG_DATE | 日期欄位 |
| 43 | 保單狀況生效時分 | LST_CHG_TIME | 時間欄位 |
| 44 | 要保人姓名 | A_NAME | |
| 45 | 要保人身分證號碼 | A_ID | |
| 46 | 要保人出生日期 | A_BIRTHDAY | 日期欄位 |
| 47 | 要保人與被保險人關係 | RELATION | |
| 48 | 要保書填寫日期 | SIGN_DATE | 日期欄位 |
| 49 | 保經代類別 | BROKTYPE | |
| 50 | 失敗原因 | MEMO | |
| 51 | 偵錯來源 | ERR_TYPE | |
| 52 | 通報日期 | OUTPUT_TIME | |
| 53 | 公會序號 | SER_NO | |

#### 3. 業務流程與商業邏輯

**步驟一：定義欄位對應陣列**

宣告兩個等長的字串陣列，長度均為 54：
- `HEADERs`：Excel 標題列文字(中文)，依序對應上方欄位對照表的「標題」欄。
- `HEADER_NAMEs`：每欄對應的 Map key(欄位代碼)，依序對應上方欄位對照表的「欄位代碼」欄。

**步驟二：建立 Excel 工作簿與標題列**

1. 建立 `XSSFWorkbook` 物件(Apache POI，xlsx 格式)，並於其中建立一個 `XSSFSheet`。
2. 於 sheet 的第 0 列 (`sheet.createRow(0)`) 建立標題行 `rowhead`。
3. 依序迴圈 `i = 0` 至 `HEADERs.length - 1`，對每個索引執行 `rowhead.createCell(i).setCellValue(HEADERs[i])`，將中文標題填入對應欄位。

**步驟三：迭代資料清單，填寫資料列**

從 `rowNum = 1` 開始，對 `list` 中每個 `Map` 物件建立一個新資料列，並逐欄填寫欄位值：

對每個欄位索引 `i`，根據 `HEADER_NAMEs[i]` 從 `map.get(HEADER_NAMEs[i])` 取得原始值，再以 `ObjectUtils.toString()` 轉為字串。依據欄位分三種處理路徑：

**路徑 A：日期欄位(索引 4, 34, 36, 42, 46, 48)**
對應欄位：`I_BIRTHDAY`、`ISSUE_DATE`、`LPS_DATE`、`LST_CHG_DATE`、`A_BIRTHDAY`、`SIGN_DATE`

1. 以 `DATE.isDate(date)` 判斷日期字串是否為合法西元年格式：
   - **合法**：呼叫 `DATE.toROCDate(date)` 將西元年日期轉換為民國年格式(例如 `"2022-10-03"` → `"1111003"`)，再以 `replaceAll("-", StringUtils.EMPTY)` 去除可能包含的連字號，最後以 `StringUtils.leftPad(..., 8, "0")` 左補零至 8 位，例如 `"1111003"` → `"01111003"`。填入儲存格。
   - **空白字串**：以 `StringUtils.isBlank(date)` 判斷為空 → 填入空字串 (`StringUtils.EMPTY`)。
   - **非合法日期且非空白**：直接將原始字串填入儲存格，不做轉換。

**路徑 B：時間欄位(索引 35, 37, 43)**
對應欄位：`ISSUE_TIME`、`LPS_TIME`、`LST_CHG_TIME`

1. 以 `StringUtils.isNotBlank(time)` 判斷時間字串是否有值：
   - **有值**：以 `replaceAll(":", "")` 去除冒號(例如 `"10:30"` → `"1030"`)，填入儲存格。
   - **空白**：填入空字串 (`StringUtils.EMPTY`)。

**路徑 C：一般欄位(其餘索引)**
直接以 `ObjectUtils.toString(map.get(HEADER_NAMEs[i]))` 取值，填入儲存格。若 map 中無對應 key，`ObjectUtils.toString(null)` 回傳空字串 `""`。

每筆 Map 處理完畢後 `rowNum` 遞增 1，繼續下一筆。

**步驟四：寫出檔案**

1. 建立 `FileOutputStream(fileFullPath)` 物件，開啟指定路徑的輸出串流。
2. 呼叫 `workbook.write(fos)` 將工作簿序列化寫入串流。
3. 呼叫 `fos.flush()` 確保資料完整寫出。

#### 4. 例外與訊息處理
- 任意 `Exception`(包含 `IOException`、`POI` 相關例外等)：
  - 記錄 fatal 等級 log：`log.fatal("產生Excel發生錯誤", e)`。
  - 拋出 `ModuleException("產生Excel發生錯誤:" + e.getMessage(), e)`，訊息包含原始例外訊息。
- `finally` 區塊：
  - 若 `fos` 不為 `null`，嘗試呼叫 `fos.close()` 關閉輸出串流。
  - 若 `close()` 拋出例外，記錄 fatal 等級 log：`log.fatal("關閉串流發生錯誤", e)`，不再向上拋出例外。

#### 5. 內部方法呼叫
無。

#### 6. 外部模組 / 方法呼叫
無。


---

