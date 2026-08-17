# CXL:csCommon 公開契約

**原始資源**: taglib `uri="/CXL"`、`prefix="CXL"`（專案來源未包含 `CXL.tld` 實體檔）

> 專案內查無 `CXL.tld` 檔案，本文件僅能依 `header.jsp` 對 `<CXL:csCommon>` 之唯一呼叫方式逆推其對外行為：
> `<CXL:csCommon trace="false" htmlBaseName="htmlBase" cssBaseName="cssBase" imageBaseName="imageBase" dispatcherName="dispatcher" />`
> 範圍限定於此已被觀察到的用法，不臆測未出現之屬性或行為。

## CXL:csCommon
**使用情境**: 建立頁面共用之既有路徑變數（非業務資料，見下列各節）
**使用方式**: `<CXL:csCommon trace="false" htmlBaseName="htmlBase" cssBaseName="cssBase" imageBaseName="imageBase" dispatcherName="dispatcher" />`
**主要功能**:
- 依 `htmlBaseName`、`cssBaseName`、`imageBaseName`、`dispatcherName` 四個屬性指定之名稱，各自建立一個 EL 變數（見 [htmlBase](#htmlbase)、[cssBase](#cssbase)、[imageBase](#imagebase)、[dispatcher](#dispatcher)）
**輸入**:
- `trace` [String] - 專案唯一呼叫方式固定傳入 `"false"`；其作用無法由現有用法推知
- `htmlBaseName` [String] - 指定用於存放 HTML／JavaScript 等靜態資源路徑基準之 EL 變數名稱；專案唯一呼叫方式固定傳入 `htmlBase`
- `cssBaseName` [String] - 指定用於存放 CSS 資源路徑基準之 EL 變數名稱；專案唯一呼叫方式固定傳入 `cssBase`
- `imageBaseName` [String] - 指定用於存放圖片資源路徑基準之 EL 變數名稱；專案唯一呼叫方式固定傳入 `imageBase`
- `dispatcherName` [String] - 指定用於存放後端派送端點基準之 EL 變數名稱；專案唯一呼叫方式固定傳入 `dispatcher`
**輸出**: 無（輸出以各屬性指定名稱建立之 EL 變數形式提供，見下列各節）
**輸出條件**: 預設輸出

## htmlBase
**使用情境**: HTML／JavaScript 等靜態資源路徑基準；既有路徑變數，非業務資料
**使用方式**: EL `${htmlBase}`
**主要功能**:
- 提供頁面組成共用靜態資源請求路徑時所需之前綴（`header.jsp` 用法見 [watermark-js-plus.js 靜態載入](../jsp/header.jsp.md#watermark-js-plusjs-靜態載入)、[watermark-js-plus.js 動態注入](../jsp/header.jsp.md#watermark-js-plusjs-動態注入)）
**輸入**: 無
**輸出**:
- `htmlBase` [String] - HTML／JavaScript 資源路徑前綴，實際來源由後端決定
**輸出條件**: 預設輸出

## cssBase
**使用情境**: CSS 資源路徑基準；既有路徑變數，非業務資料
**使用方式**: EL `${cssBase}`
**主要功能**:
- 提供頁面組成共用樣式資源請求路徑時所需之前綴；`header.jsp` 未消費此變數
**輸入**: 無
**輸出**:
- `cssBase` [String] - CSS 資源路徑前綴，實際來源由後端決定
**輸出條件**: 預設輸出

## imageBase
**使用情境**: 圖片資源路徑基準；既有路徑變數，非業務資料
**使用方式**: EL `${imageBase}`
**主要功能**:
- 提供頁面組成共用圖片資源請求路徑時所需之前綴；`header.jsp` 未消費此變數
**輸入**: 無
**輸出**:
- `imageBase` [String] - 圖片資源路徑前綴，實際來源由後端決定
**輸出條件**: 預設輸出

## dispatcher
**使用情境**: 後端派送端點基準；既有路徑變數，非業務資料
**使用方式**: EL `${dispatcher}`
**主要功能**:
- 提供頁面組成後端請求端點時所需之前綴；`header.jsp` 未消費此變數
**輸入**: 無
**輸出**:
- `dispatcher` [String] - 後端派送端點前綴，實際來源由後端決定
**輸出條件**: 預設輸出
