# AFWeb HTTP API Contract (OpenAPI 3.1 Markdown)

> 文件狀態：依目前 Spring Boot Controller、Request/Response DTO、驗證註解與全域例外處理器盤點。  
> 最後更新：2026-08-12  
> 對應 OpenAPI：3.1.0  
> API 版本：未於程式碼宣告；本文件暫記為 `0.0.1-SNAPSHOT`

## 1. API 基本資訊

| 項目 | 契約 |
|---|---|
| 預設 Server | `http://localhost:8080` |
| Context Path | `/`（專案未設定 `server.servlet.context-path`） |
| API 數量 | 23 個 HTTP 操作、23 條 Path |
| HTTP Method | 全部為 `POST` |
| 一般請求格式 | `application/json` |
| 一般回應格式 | `application/json` |
| 檔案匯入 | `multipart/form-data` |
| 檔案下載 | `application/octet-stream` |
| 認證 | 應用程式碼未宣告 Security Scheme；部署環境若由 Gateway/容器驗證，應另行補充 |
| Stub Profile | 預設啟用；回應會附帶 `X-AF-Stub: true` |

本文件描述「目前程式實際可接收／輸出的 HTTP 契約」，不把尚未落實的 Design Spec 欄位推測為正式契約。未由 DTO 驗證註解限制的欄位，在 OpenAPI 語意上均視為非必填。

## 2. 共通規則

### 2.1 一般成功回應

除下載端點外，所有端點均使用 `ReturnMsg<T>`：

```json
{
  "code": 200,
  "msg": "success",
  "data": {}
}
```

| JSON 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `code` | integer | 是 | 業務結果碼；成功固定為 `200` |
| `msg` | string | 是 | 結果訊息；預設為 `success`，部分操作使用中文訊息 |
| `data` | 任意型別或 null | 是 | 各操作的回應資料；無資料型操作為 `null` |

### 2.2 錯誤回應與 HTTP 狀態碼

目前 `GlobalExceptionHandler` 將輸入錯誤、查無資料、資料重複、模組錯誤與未預期錯誤都包成 HTTP `200 OK`：

```json
{
  "code": 500,
  "msg": "錯誤原因",
  "data": null
}
```

因此 Client 必須同時判斷 HTTP status 與 body 的 `code`，不可只以 HTTP `200` 認定成功。Bean Validation 錯誤目前也會落入共通 `Exception` handler，body `code` 為 `500`。這是現況相容契約，並非一般 REST API 建議做法。

### 2.3 JSON 命名注意事項

- 未標示 `@JsonProperty` 的欄位使用 Jackson bean property 名稱。
- `AFY10100DoASyncResponse` 的 primitive boolean 實際輸出為 `allow`、`return`。
- `AFY10300DoPromptResponse` 與 `AFY10400DoPromptResponse` 的 primitive `isRType` 實際輸出為 `rtype`。
- 使用 boxed `Boolean isRType` 的其他 AFY10300 Response 實際輸出仍為 `isRType`。
- 全大寫或底線欄位（如 `I_ID`、`SALE_CHNL_OPTION`）是明確的 `@JsonProperty` 契約，大小寫不可任意更改。
- 日期欄位多沿用 Legacy 字串格式；`insrDate` 已知為民國年 `yyyMMdd`。其餘 String 日期若程式未宣告格式，本文件不額外假設。
- 姓名等文字內容直接使用 JSON/UTF-8 Unicode 字串，不轉換為 `&#...;` HTML entity；前端應以文字節點呈現，不使用未消毒的 `innerHTML`。

## 3. 端點總覽

| Tag | Method | Path | operationId | Request Schema | Success Data Schema |
|---|---|---|---|---|---|
| AFY10100 | POST | `/afy10100/asynccheckid` | `afy10100DoASyncCheckId` | `AFY10100DoASyncCheckIdRequest` | `AFY10100DoASyncCheckIdResponse` |
| AFY10100 | POST | `/afy10100/async` | `afy10100DoASync` | `AFY10100DoASyncRequest` | `AFY10100DoASyncResponse` |
| AFY10100 | POST | `/afy10100/query` | `afy10100DoQuery` | `AFY10100DoQueryRequest` | `AFY10100DoQueryResponse` |
| AFY10100 | POST | `/afy10100/showdetail` | `afy10100DoShowDetail` | `AFY10100DoShowDetailRequest` | `AFY10100DoShowDetailResponse` |
| AFY10100 | POST | `/afy10100/edit` | `afy10100DoEdit` | `AFY10100DoEditRequest` | `AFY10100DoEditResponse` |
| AFY10100 | POST | `/afy10100/delete` | `afy10100DoDelete` | `AFY10100DoDeleteRequest` | `AFY10100DoDeleteResponse` |
| AFY10300 | POST | `/afy10300/prompt` | `afy10300DoPrompt` | `AFY10300DoPromptRequest` | `AFY10300DoPromptResponse` |
| AFY10300 | POST | `/afy10300/query` | `afy10300DoQuery` | `AFY10300DoQueryRequest` | `AFY10300DoQueryResponse` |
| AFY10300 | POST | `/afy10300/edit` | `afy10300DoEdit` | `AFY10300DoEditRequest` | `AFY10300DoEditResponse` |
| AFY10300 | POST | `/afy10300/export` | `afy10300DoExport` | `AFY10300DoExportRequest` | XLSX binary |
| AFY10300 | POST | `/afy10300/import` | `afy10300DoImport` | multipart `AFY10300DoImportRequest` | `AFY10300DoImportResponse` |
| AFY10300 | POST | `/afy10300/executebatch` | `afy10300DoExecuteBatch` | `AFY10300DoExecuteBatchRequest` | `AFY10300DoExecuteBatchResponse` |
| AFY10400 | POST | `/afy10400/prompt` | `afy10400DoPrompt` | `AFY10400DoPromptRequest` | `AFY10400DoPromptResponse` |
| AFY10400 | POST | `/afy10400/export` | `afy10400DoExport` | `AFY10400DoExportRequest` | `AFY10400DoExportResponse` |
| AFY10400 | POST | `/afy10400/download` | `afy10400DoDownload` | `AFY10400DoDownloadRequest` | XLSX binary |
| ATA08110 | POST | `/ata08110/prompt` | `ata08110DoPrompt` | `ATA08110DoPromptRequest` | `ATA08110DoPromptResponse` |
| ATA08110 | POST | `/ata08110/insert` | `ata08110DoInsert` | `ATA08110DoInsertRequest` | null |
| ATA08110 | POST | `/ata08110/update` | `ata08110DoUpdate` | `ATA08110DoUpdateRequest` | null |
| ATA08110 | POST | `/ata08110/delete` | `ata08110DoDelete` | `ATA08110DoDeleteRequest` | `ATA08110DoDeleteResponse` |
| ATA08120 | POST | `/ata08120/prompt` | `ata08120DoPrompt` | body 可省略 | `ATA08120DoPromptResponse` |
| ATA08120 | POST | `/ata08120/insert` | `ata08120DoInsert` | `ATA08120DoInsertRequest` | `ATA08120DoInsertResponse` |
| ATA08120 | POST | `/ata08120/update` | `ata08120DoUpdate` | `ATA08120DoUpdateRequest` | `ATA08120DoUpdateResponse` |
| ATA08120 | POST | `/ata08120/delete` | `ata08120DoDelete` | `ATA08120DoDeleteRequest` | `ATA08120DoDeleteResponse` |

`AFY1Z010TimerTaskController.run()` 是 Spring `@Component` 方法，沒有 HTTP Mapping，因此不屬於 OpenAPI paths。

## 4. AFY10100 — 公會通報資料

### 4.1 POST `/afy10100/asynccheckid`

檢查身分證字號或營業人統一編號。

- Request body：必須提供 JSON object。
- 成功訊息：`success`。

`AFY10100DoASyncCheckIdRequest`

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `inputId` | string | 否 | 待檢核的身分證字號或營業人統一編號 |

`AFY10100DoASyncCheckIdResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `isIdError` | string | 證號錯誤旗標 |

### 4.2 POST `/afy10100/async`

檢查操作權限並觸發公會資料即時取回。

- Request body：必須提供 JSON object。
- 成功訊息：`取回公會資料中`。
- 僅 `IS_RETURN` 精確等於 `Y` 時要求回寫契約角色取回狀態。

`AFY10100DoASyncRequest`

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `inputId` | string | 否 | 身分識別值 |
| `IS_RETURN` | string | 否 | 是否要求回寫；有效觸發值為 `Y` |

`AFY10100DoASyncResponse`

| JSON 欄位 | 型別 | 說明 |
|---|---|---|
| `inputId` | string | 正規化後的身分識別值 |
| `allow` | boolean | 是否具備即時取回權限 |
| `return` | boolean | 是否具備更新契約角色取回狀態的權限 |

### 4.3 POST `/afy10100/query`

依身分識別值、角色與狀態查詢公會通報資料。

- Request body：必須提供 JSON object。
- 成功訊息：`success`。
- 查無資料時：HTTP 200，body `code=500`、`msg=查無此ID公會資料`。

`AFY10100DoQueryRequest`

| 欄位 | 型別 | 必填 | 驗證／說明 |
|---|---|---:|---|
| `inputId` | string | 是 | 不可為 null、空字串或全空白；錯誤訊息 `身份證字號/統一編號：不得為空值` |
| `role` | string | 否 | 角色篩選條件 |
| `status` | string | 否 | 狀態篩選條件 |

`AFY10100DoQueryResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `inputId` | string | 正規化後的身分識別值 |
| `role` | string | 原始角色條件 |
| `status` | string | 原始狀態條件 |
| `insrMap` | `object<string,string>` | 通報方式代碼與名稱 |
| `oiuIndDesc` | `object<string,string>` | 保險公司屬性代碼與說明 |
| `saleChnlDesc` | `object<string,string>` | 銷售通路代碼與說明 |
| `resultList` | `array<any>` | 原始查詢結果；完整動態結構尚未定義 |
| `dataMap` | object | 畫面彙整資料；完整動態結構尚未定義 |

### 4.4 POST `/afy10100/showdetail`

顯示選取資料列與代碼說明。兩條 path 對應同一個 Controller 方法，Request/Response 完全相同。

- Request body：必須提供 JSON object。
- Request 接受任意欄位，所有欄位均收進動態 Map。
- 成功訊息：`success`。

`AFY10100DoShowDetailRequest`

```json
{
  "POLICY_NO": "MOCK-POLICY-001",
  "I_GENDER": "1",
  "anyOtherField": "value"
}
```

Schema：`type: object`、`additionalProperties: true`，沒有已宣告必填欄位。

`AFY10100DoShowDetailResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `dataMap` | `object<string,any>` | 原始明細資料 |
| `genderDesc` | `object<string,string>` | 性別代碼說明 |
| `payTypeDesc` | `object<string,string>` | 付款類型代碼說明 |
| `oiuIndDesc` | `object<string,string>` | 保險公司屬性代碼說明 |
| `saleChnlDesc` | `object<string,string>` | 銷售通路代碼說明 |

### 4.5 POST `/afy10100/edit`

編輯公會通報資料，完成後以保留條件重新查詢。

- Request body：必須提供 JSON object。
- 成功訊息：`success`。
- 除下表欄位外亦接受任意額外欄位，保留於 `additionalParameters`。

`AFY10100DoEditRequest`

| JSON 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `A_NAME` | string | 否 | 姓名；Service 編輯前解除 HTML 實體編碼 |
| `TBL_NAME` | string | 否 | 資料表類型 |
| `INSR_TYPE` | string | 否 | 保險種類 |
| `CMNY_CODE` | string | 否 | 公司代碼 |
| `I_ID` | string | 否 | 原始身分證字號／統編 |
| `I_BIRTHDAY` | string | 否 | 原始生日 |
| `POLICY_NO` | string | 否 | 原始保單號碼 |
| `POLICY_CAT` | string | 否 | 原始保單類別 |
| `POLICY_DUTY` | string | 否 | 原始保單責任別 |
| `PROD_KIND` | string | 否 | 原始商品種類 |
| `status` | string | 否 | 狀態及重查條件 |
| `LST_CHG_DATE` | string | 否 | 最後異動日期 |
| `inputId` | string | 是 | 不可為空；編輯後重查的身分識別值 |
| `role` | string | 否 | 編輯後重查角色 |
| 其他欄位 | any | 否 | 原始編輯 VO 的動態欄位 |

`AFY10100DoEditResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `inputId` | string | 重查身分識別值 |
| `role` | string | 重查角色 |
| `status` | string | 重查狀態 |
| `INSRMAP` | `object<string,string>` | 通報方式代碼與名稱 |
| `insrMap` | `object<string,string>` | `INSRMAP` 的前端相容別名 |
| `oiuIndDesc` | `object<string,string>` | 保險公司屬性說明 |
| `saleChnlDesc` | `object<string,string>` | 銷售通路說明 |
| `resultList` | `array<object>` | 重查原始明細 |
| `dataMap` | `object<string,any>` | 重查畫面資料 |

`resultList` 與 `dataMap` 保證不為 `null`；無資料時分別回傳 `[]` 與 `{}`。

`stub` profile 會更新記憶體內符合 `TBL_NAME + POLICY_NO` 的資料，再以原條件重新查詢。回傳 `resultList` 每筆包含 58 個前端大寫欄位；例如修改 `A_NAME`、`PAY_AMT1` 或 `PREM` 後，明細與相關彙總欄位會同步反映新值。

### 4.6 POST `/afy10100/delete`

依複合鍵刪除公會通報資料，完成後以保留條件重新查詢。

- Request body：必須提供 JSON object。
- 成功訊息：`success`。

`AFY10100DoDeleteRequest`

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `TBL_NAME` | string | 否 | 資料表類型代碼 |
| `INSR_TYPE` | string | 否 | 被保險人類型 |
| `CMNY_CODE` | string | 否 | 公司代碼 |
| `I_ID` | string | 否 | 身分識別值 |
| `I_BIRTHDAY` | string | 否 | 出生日期 |
| `POLICY_NO` | string | 否 | 保單號碼 |
| `POLICY_CAT` | string | 否 | 保單類別 |
| `POLICY_DUTY` | string | 否 | 保單責任別 |
| `PROD_KIND` | string | 否 | 商品種類 |
| `STATUS` | string | 否 | 選取明細的保單狀態 |
| `status` | string | 否 | 刪除後重新查詢的狀態 |
| `LST_CHG_DATE` | string | 否 | 最後異動日期 |
| `inputId` | string | 否 | 刪除後重查身分識別值 |
| `role` | string | 否 | 刪除後重查角色 |

`AFY10100DoDeleteResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `inputId`、`role`、`status` | string | 重查條件 |
| `insuredTypeDescriptions` | `object<string,string>` | 通報方式說明 |
| `oiuIndicatorDescriptions` | `object<string,string>` | 保險公司屬性說明 |
| `salesChannelDescriptions` | `object<string,string>` | 銷售通路說明 |
| `insrMap` | `object<string,string>` | `insuredTypeDescriptions` 的前端相容別名 |
| `oiuIndDesc` | `object<string,string>` | `oiuIndicatorDescriptions` 的前端相容別名 |
| `saleChnlDesc` | `object<string,string>` | `salesChannelDescriptions` 的前端相容別名 |
| `resultList` | `array<object>` | 重查原始明細 |
| `dataMap` | `object<string,any>` | 重查畫面資料 |

`resultList` 與 `dataMap` 保證不為 `null`；無資料時分別回傳 `[]` 與 `{}`。

`stub` profile 會刪除記憶體內符合 `TBL_NAME + POLICY_NO` 的資料，再回傳剩餘完整明細及重新計算的保障／保費彙總。內建刪除測試資料的 `POLICY_NO` 為 `MOCK-POLICY-DELETE`。

## 5. AFY10300 — 補通報

### 5.1 共用查詢與畫面欄位

下列欄位會依操作出現在 Request、Response 或兩者：

| 欄位 | 型別 | 說明 |
|---|---|---|
| `queryNo` | string | 查詢種類／查詢序號條件 |
| `idNo` | string | 查詢 ID 條件 |
| `insrDate` | string | 通報日期；畫面日期為民國年 `yyyMMdd` |
| `insrType` | string | 通報類型；業務流程主要使用 `L` 或 `R` |
| `errorCode` | string | 錯誤碼條件 |
| `prodType` | string | 商品類型 |
| `procStatus` | string | 處理狀態 |
| `regQueryNo` | string | 保留的 `queryNo` |
| `regIdNo` | string | 保留的 `idNo` |
| `regInsrDate` | string | 保留的 `insrDate` |
| `regInsrType` | string | 保留的 `insrType` |
| `regErrorCode` | string | 保留的 `errorCode` |
| `regProdType` | string | 保留的 `prodType` |
| `regProcStatus` | string | 保留的 `procStatus` |

身分欄位若沒有 `@JsonProperty` 時使用 camelCase；Query Request 的七個身分欄位則使用下列固定 JSON 名稱：

| JSON 欄位 | 型別 | 說明 |
|---|---|---|
| `I_ID` | string | 被保險人 ID |
| `I_NAME` | string | 被保險人姓名 |
| `I_BIRTHDAY` | string | 被保險人生日 |
| `I_GENDER` | string | 被保險人性別 |
| `A_ID` | string | 要保人 ID |
| `A_NAME` | string | 要保人姓名 |
| `A_BIRTHDAY` | string | 要保人生日 |

共用選項 Response 欄位：

| JSON 欄位 | 型別 | 說明 |
|---|---|---|
| `SALE_CHNL_OPTION` | `object<string,string>` | 銷售通路選項 |
| `POLICY_DUTY_OPTION` | `object<string,string>` | 保單責任別選項 |
| `PROD_KIND_OPTION` | `object<string,string>` | 商品種類選項 |
| `PAY_FREQ_OPTION` | `object<string,string>` | 繳費頻率選項 |
| `RELATION_OPTION` | `object<string,string>` | 關係選項 |
| `LIA_STATUS_OPTION` | `object<string,string>` | 通報狀態選項 |
| `BROKTYPE_OPTION` | `object<string,string>` | 保經代類別選項 |

### 5.2 POST `/afy10300/prompt`

初始化補通報畫面。

- Request body 必須為 `{}`；Schema 沒有 properties。
- 成功訊息：`success`。

`AFY10300DoPromptResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `insrDate` | string | 系統當日民國年日期 `yyyMMdd` |
| `showEdit` | string | 編輯區顯示旗標，初始化為 `N` |
| `showQuery` | boolean | 查詢結果區顯示旗標，初始化為 `false` |
| `rtype` | boolean | R 類型模式，初始化為 `false`；注意實際 JSON 名稱為全小寫 `rtype` |
| 七個 `*_OPTION` 欄位 | `object<string,string>` | 見 5.1 |

### 5.3 POST `/afy10300/query`

查詢補通報資料。

- Request body：必須提供 JSON object。
- 目前 DTO 沒有 Bean Validation 必填欄位。
- `queryNo`、`insrType`、`errorCode`、`prodType`、`procStatus` 的完整合法值尚未由程式宣告。

`AFY10300DoQueryRequest`

| 欄位 | 型別 | 必填 |
|---|---|---:|
| `queryNo`、`idNo`、`insrDate`、`insrType`、`errorCode`、`prodType`、`procStatus` | string | 否 |
| `I_ID`、`I_NAME`、`I_BIRTHDAY`、`I_GENDER` | string | 否 |
| `A_ID`、`A_NAME`、`A_BIRTHDAY` | string | 否 |

`AFY10300DoQueryResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `showEdit` | string | 編輯顯示旗標 |
| `showQuery` | boolean/null | 是否顯示查詢結果 |
| `isRType` | boolean/null | 是否為 R 類型 |
| `resultList` | `array<object>` | 查詢結果；Map 完整欄位尚未定義 |
| 七個一般查詢欄位 | string | 見 5.1 |
| 七個 `reg*` 欄位 | string | 見 5.1 |
| 七個 `*_OPTION` 欄位 | `object<string,string>` | 見 5.1 |

`stub` profile 在 L 類型的 `resultList` 提供一筆 64 欄、所有值皆非 `null` 且非空字串的測試明細，欄位包括：

- 被保險人與保單：`I_NAME`、`I_ID`、`I_BIRTHDAY`、`I_GENDER`、`POLICY_NO`、`MAIN_POLICY_NO`、`OIU_IND`、`SALE_CHNL`、`PROD_CODE`、`POLICY_CAT`、`POLICY_DUTY`、`PROD_KIND`。
- 金額：`PAY_TYPE`、`PAY_AMT1`～`PAY_AMT19`、`PREM`、`PAY_FREQ`、`PAY_PERIOD`。
- 日期與時間：`ISSUE_DATE`、`ISSUE_TIME`、`SIGN_DATE`、`LPS_DATE`、`LPS_TIME`、`LST_CHG_DATE`、`LST_CHG_TIME`、`UPDATE_TIME`、`OUTPUT_TIME`。
- 要保人與處理資料：`STATUS`、`A_NAME`、`A_ID`、`A_BIRTHDAY`、`RELATION`、`BROKTYPE`、`UPDATE_SRC`、`PROD_ID`、`LIA_STATUS`、`SER_NO`、`MEMO`、`APLY_NO`。
- 顯示轉換：`LIA_STATUS_DESC`、`INSR_TYPE_DESC`、`I_GENDER_DESC`、`I_BIRTHDAY_ROC`、`ISSUE_DATE_ROC`、`LPS_DATE_ROC`、`A_BIRTHDAY_ROC`、`LST_CHG_DATE_ROC`。

可能的業務錯誤訊息包含 `失敗檔、保單號碼、被保人ID 輸入錯誤`、`處理狀態輸入錯誤`、`查詢失敗`。

### 5.4 POST `/afy10300/edit`

修改補通報明細後重查。

- Request body：必須提供 JSON object。
- 目前 DTO 沒有 Bean Validation 必填欄位。
- 成功訊息：`更新完成`。

`AFY10300DoEditRequest`

| 欄位群組 | 型別 | 必填 | 欄位 |
|---|---|---:|---|
| 通報分類 | string | 否 | `insrType`, `prodType` |
| 被保險人 | string | 否 | `iName`, `iId`, `iBirthday`, `iGender` |
| 保單主檔 | string | 否 | `policyNo`, `mainPolicyNo`, `oiuInd`, `saleChnl`, `prodCode`, `policyCat`, `policyDuty`, `prodKind`, `payType` |
| 給付項目 | string | 否 | `payAmt1` 至 `payAmt19`（19 個獨立 properties） |
| 契約日期時間 | string | 否 | `issueDate`, `issueTime`, `signDate`, `lpsDate`, `lpsTime`, `lstChgDate`, `lstChgTime` |
| 保費與狀態 | string | 否 | `prem`, `payFreq`, `payPeriod`, `status`, `liaStatus` |
| 要保人 | string | 否 | `aName`, `aId`, `aBirthday`, `relation`, `brokType` |
| 原複合鍵 | string | 否 | `oldIId`, `oldIBirthday`, `oldPolicyNo`, `oldPolicyCat`, `oldPolicyDuty`, `oldProdKind`, `oldStatus`, `oldLstChgDate`, `oldUpdateTime` |
| 保留條件 | string | 否 | 七個 `reg*` 欄位，見 5.1 |

`AFY10300DoEditResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `showEdit` | string | 編輯顯示旗標 |
| `showQuery` | boolean/null | 查詢結果區顯示旗標 |
| `isRType` | boolean/null | 是否為 R 類型 |
| `resultList` | `array<object>` | 編輯後重查結果 |
| 七個 `reg*` 欄位 | string | 保留條件 |
| 七個 `*_OPTION` 欄位 | `object<string,string>` | 見 5.1 |

### 5.5 POST `/afy10300/export`

依保留條件產生補通報 Excel。

- 支援 `application/json` 與 `application/x-www-form-urlencoded;charset=UTF-8`。
- JSON 使用 object；表單格式使用同名欄位，例如 `regQueryNo=0&regIdNo=&regInsrType=L`。
- 成功時直接回傳 XLSX binary，前端應以 `blob`／`arraybuffer` 接收。
- `Content-Type`：`application/octet-stream`（符合既有前端下載 helper 的成功判斷）。
- `Content-Disposition`：`attachment; filename="{regProdType}{regInsrType}.xlsx"`。

`AFY10300DoExportRequest`

| 欄位群組 | 型別 | 必填 | 欄位 |
|---|---|---:|---|
| 一般查詢條件 | string | 否 | `queryNo`, `idNo`, `insrDate`, `insrType`, `errorCode`, `prodType`, `procStatus` |
| 保留條件 | string | 否 | 七個 `reg*` 欄位 |
| 被保險人 | string | 否 | `iId`, `iName`, `iBirthday`, `iGender` |
| 要保人 | string | 否 | `aId`, `aName`, `aBirthday` |

成功回應 body 為 Excel OOXML bytes（ZIP magic bytes：`PK`），不使用 `ReturnMsg` JSON 包裝。

### 5.6 POST `/afy10300/import`

匯入補通報 Excel。

- Content-Type：`multipart/form-data`。
- 成功訊息：`匯入檔案成功`。
- `file` 缺少或為 null 時違反 `@NotNull`；空檔案由 Service 回傳業務錯誤 `匯入的檔案有誤`。

`AFY10300DoImportRequest`（multipart fields）

| 欄位 | 型別／格式 | 必填 | 說明 |
|---|---|---:|---|
| `file` | string / binary | 是 | 上傳檔案 |
| `iId`, `iName`, `iBirthday`, `iGender` | string | 否 | 被保險人保留欄位 |
| `aId`, `aName`, `aBirthday` | string | 否 | 要保人保留欄位 |
| `queryNo`, `idNo`, `insrDate`, `insrType`, `errorCode`, `prodType`, `procStatus` | string | 否 | 查詢保留條件 |

`AFY10300DoImportResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| 七個一般查詢欄位 | string | 見 5.1 |
| 七個 `reg*` 欄位 | string | 見 5.1 |
| `showEdit` | string | 編輯顯示旗標 |
| `showQuery` | boolean/null | 查詢區顯示旗標 |
| `isRType` | boolean/null | 依上傳檔名判斷的 R 類型旗標 |

### 5.7 POST `/afy10300/executebatch`

呼叫即時補通報批次。

- Request body：必須提供 JSON object。
- 成功訊息：`即時通報處理中`。

`AFY10300DoExecuteBatchRequest`

| 欄位群組 | 型別 | 必填 | 欄位 |
|---|---|---:|---|
| 商品 | string | 否 | `prodType` |
| 被保險人 | string | 否 | `iId`, `iName`, `iBirthday`, `iGender` |
| 要保人 | string | 否 | `aId`, `aName`, `aBirthday` |
| 保留條件 | string | 否 | 七個 `reg*` 欄位 |

`AFY10300DoExecuteBatchResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `showEdit` | string | 固定畫面狀態 |
| `showQuery` | boolean/null | 查詢區顯示旗標 |
| `isRType` | boolean/null | R 類型旗標 |
| 七個 `reg*` 欄位 | string | 保留條件 |

## 6. AFY10400 — 通報資料匯出／下載

### 6.1 POST `/afy10400/prompt`

初始化下載畫面。Request body 必須為 `{}`，成功訊息為 `success`。

為相容既有呼叫，同時接受 `POST /afy10400/promp`，回應契約完全相同；新程式仍應優先使用標準 `/prompt`。

`AFY10400DoPromptResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `insrDate` | string | 今日民國年日期 `yyyMMdd` |
| `showEdit` | string | 固定為 `N` |
| `showQuery` | boolean | 固定為 `false` |
| `rtype` | boolean | 固定為 `false`；注意實際 JSON 名稱為全小寫 `rtype` |

### 6.2 POST `/afy10400/export`

依被保險人與保單清單產生 Excel。

- Request body：必須提供 JSON object。
- 成功訊息：`success`。
- `I_ID` 與 `POLICY_NO` 為平行陣列，索引必須互相對應。

`AFY10400DoExportRequest`

| JSON 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `insrType` | string | 否 | 收承方式；Service 支援值依業務流程判定 |
| `prodType` | string | 否 | 商品類型 |
| `I_ID` | `array<string>` | 否 | 被保險人 ID 陣列 |
| `POLICY_NO` | `array<string>` | 否 | 保單號碼陣列，索引與 `I_ID` 對應 |

`AFY10400DoExportResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `rtnMap` | `object<string,string>` | 各被保險人的匯出結果 |
| `fileName` | string | 產出的 Excel 檔名，供 download 端點使用 |

可能的業務錯誤包含空白列、查無資料、收承方式錯誤、商品屬性錯誤與 Excel 產生失敗。

### 6.3 POST `/afy10400/download`

下載 export 產生的 Excel。

支援兩種 Request Content-Type：

- `application/json`：`{"fileName":"ATL_20260101.xlsx"}`
- `application/x-www-form-urlencoded`：`fileName=ATL_20260101.xlsx`（包含 `charset=UTF-8` 的前端請求亦支援）

`AFY10400DoDownloadRequest`

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `fileName` | string | 否 | export 回傳的檔名；目前 DTO 尚無 null／空白驗證 |

成功 Response：

| 項目 | 值 |
|---|---|
| HTTP status | `200` |
| Content-Type | `application/octet-stream` |
| Content-Disposition | `attachment; filename="{fileName}"`（stub adapter） |
| Body | binary string (`format: binary`) |

下載成功不使用 `ReturnMsg`。下載前發生例外時會嘗試交由全域 handler 回傳 `ReturnMsg`；若 response 已經寫入部分 binary，實際結果可能因 Servlet 容器與正式下載 adapter 而異。

## 7. ATA08110 — DTCBZ004 連線設定

### 7.1 POST `/ata08110/prompt`

查詢連線設定。Request body 必須為 `{}`，成功訊息為 `查詢成功`。

`ATA08110DoPromptResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `DTCBZ004_List` | `array<object<string,string>>` | 連線設定清單 |

目前 stub/adapter 輸出的 row keys 為 `SRC`, `TIMEOUT`, `CALL_ASSO`, `UPDATE_ID`, `UPDATE_TIME`, `URL`, `MAX_AMT`, `CONNECT_TIMEOUT`, `RETRY`；正式 Legacy mapper 應維持同一資料表欄位語意。

### 7.2 POST `/ata08110/insert`

新增連線設定。成功 Response 為 `{"code":200,"msg":"新增成功","data":null}`。

`ATA08110DoInsertRequest`

| 欄位 | 型別 | 必填 | 驗證／說明 |
|---|---|---:|---|
| `srcNew` | string | 是 | 契約來源；不可為空白 |
| `timeoutNew` | string | 是 | 等待時間；不可為空白 |
| `callAssoNew` | string | 是 | 是否通算；不可為空白 |
| `urlNew` | string | 是 | 通算網址；不可為空白 |
| `maxAmtNew` | string | 是 | 累計最大保額；不可為空白 |
| `connectTimeoutNew` | string | 是 | 連線等待時間；不可為空白 |
| `retryNew` | string | 是 | 重試次數；不可為空白 |

### 7.3 POST `/ata08110/update`

依畫面陣列與索引更新連線設定。成功 Response 為 `{"code":200,"msg":"修改成功","data":null}`。

`ATA08110DoUpdateRequest`

| 欄位 | 型別 | 必填 | 驗證／說明 |
|---|---|---:|---|
| `index` | string | 是 | 不可空白，且必須符合 `^[0-9]+$` |
| `src` | `array<string>` | 否 | 來源別陣列 |
| `timeout` | `array<integer>` | 否 | 逾時設定陣列 |
| `callAsso` | `array<string>` | 否 | 是否呼叫公會陣列 |
| `url` | `array<string>` | 否 | 呼叫位址陣列 |
| `maxAmt` | `array<integer>` | 否 | 最高金額陣列 |
| `connectTimeout` | `array<integer>` | 否 | 連線逾時陣列 |
| `retry` | `array<integer>` | 否 | 重試次數陣列 |

### 7.4 POST `/ata08110/delete`

依畫面索引刪除連線設定。成功訊息預設為 `success`。

`ATA08110DoDeleteRequest`

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `index` | string | 否 | 畫面資料列索引；格式與越界行為尚未由 DTO 宣告 |
| `src` | `array<string>` | 否 | 契約來源陣列 |

`ATA08110DoDeleteResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `message` | string | 處理結果訊息 |

## 8. ATA08120 — DTAFY001 通報設定

### 8.1 POST `/ata08120/prompt`

查詢通報設定。此端點是唯一可省略 Request body 的 JSON 端點，也接受 `{}`。

`ATA08120DoPromptResponse`

| 欄位 | 型別 | 是否一定輸出 | 說明 |
|---|---|---:|---|
| `DTAFY001_List` | `array<object<string,string>>` | 否 | 有資料時輸出；查無資料時因 `NON_NULL` 而省略 |

`msg` 依結果為 `查詢成功` 或 `查無資料`。目前 stub/adapter row keys 為 `SRC`, `TYPE`, `CONNECTION`, `FTP_HOST`, `TIMEOUT`, `IS_EFFECTIVE`, `UPDATE_ID`, `UPDATE_TIME`, `RETRY`, `DATA_TIMEOUT`, `ACTION`。

### 8.2 POST `/ata08120/insert`

新增通報設定。成功 `msg` 取自 Response 的 `message`。

`ATA08120DoInsertRequest`

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `srcNew` | string | 否 | 契約來源 |
| `timeoutNew` | string | 否 | 連線等候時間 |
| `isEffectiveNew` | string | 否 | 作業開關 |
| `connectionNew` | string | 是 | 公會連線方式；不可為 null，但空字串目前可通過 DTO 驗證 |
| `retryNew` | string | 否 | 重試次數 |
| `typeNew` | string | 否 | 種類 |
| `ftpHostNew` | string | 否 | FTP 登入帳號設定值 |
| `dataTimeoutNew` | string | 否 | 資料連線等候時間 |
| `actionNew` | string | 否 | WebService 呼叫方法 |

`ATA08120DoInsertResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `message` | string | 處理結果訊息，同時作為外層 `msg` |

### 8.3 POST `/ata08120/update`

依畫面陣列與索引更新通報設定。成功 `msg` 取自 Response 的 `message`。

`ATA08120DoUpdateRequest`

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `index` | string | 否 | 零起算資料列索引；格式與陣列一致性尚未宣告 |
| `src` | `array<string>` | 否 | 契約來源，也是是否執行修改的判斷依據 |
| `timeout` | `array<string>` | 否 | 連線等候時間 |
| `isEffective` | `array<string>` | 否 | 作業開關 |
| `connection` | `array<string>` | 否 | 公會連線方式 |
| `type` | `array<string>` | 否 | 種類 |
| `ftpHost` | `array<string>` | 否 | FTP 設定值 |
| `retry` | `array<string>` | 否 | 重試次數 |
| `dataTimeout` | `array<string>` | 否 | 資料連線等候時間 |
| `action` | `array<string>` | 否 | WebService 呼叫方法 |

`ATA08120DoUpdateResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `message` | string/null | 修改結果；完成時通常為 `修改成功`，略過時可為 null |

### 8.4 POST `/ata08120/delete`

依畫面索引刪除通報設定。成功 `msg` 取自 Response 的 `message`。

`ATA08120DoDeleteRequest`

| JSON 欄位 | 型別 | 必填 | 說明 |
|---|---|---:|---|
| `index` | string | 否 | 資料列索引；空白、非數字與越界行為尚未由 DTO 宣告 |
| `SRC` | `array<string>` | 否 | 契約來源集合；注意固定為大寫 JSON key |

`ATA08120DoDeleteResponse`

| 欄位 | 型別 | 說明 |
|---|---|---|
| `message` | string | 處理結果訊息，同時作為外層 `msg` |

## 9. 呼叫範例

### 9.1 JSON 查詢

```bash
curl -X POST 'http://localhost:8080/afy10100/query' \
  -H 'Content-Type: application/json' \
  -d '{"inputId":"A123456789","role":"I","status":"Y"}'
```

### 9.2 Multipart 匯入

```bash
curl -X POST 'http://localhost:8080/afy10300/import' \
  -F 'file=@/path/to/input.xlsx' \
  -F 'queryNo=2' \
  -F 'insrType=L'
```

### 9.3 Excel 下載

```bash
curl -X POST 'http://localhost:8080/afy10400/download' \
  -H 'Content-Type: application/x-www-form-urlencoded;charset=UTF-8' \
  --data-urlencode 'fileName=ATL_20260101.xlsx' \
  --output ATL_20260101.xlsx
```

## 10. 已知契約缺口

以下項目在目前程式中沒有足夠資訊，不應由 Client 自行假設：

1. 多數 Legacy 代碼欄位的完整 enum、長度、pattern 與 nullable 規則。
2. AFY10100 `resultList`／`dataMap` 的完整動態 property schema。
3. AFY10300 export 的加密下載資訊欄位。
4. 多個 index + 平行陣列 API 的越界、陣列長度一致性與空值規則。
5. 正式環境的 Server URL、Gateway base path、認證／授權 header。
6. 正式下載 adapter 的所有 response headers；本文件可確認的 XLSX header 來自目前 stub 實作。
7. 專案目前未整合 springdoc，因此沒有可直接匯入 Swagger UI 的 `/v3/api-docs`；本文件是人工可讀的 OpenAPI 契約基線。
