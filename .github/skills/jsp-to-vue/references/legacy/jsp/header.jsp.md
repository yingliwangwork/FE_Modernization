# header.jsp 公開契約

## 使用語法清單
- [CM/header.jsp](#cmheaderjsp)
- **變數**
    - [htmlBase](#htmlbase)
    - [cssBase](#cssbase)
    - [imageBase](#imagebase)
    - [dispatcher](#dispatcher)
    - [window.charCountsByte](#windowcharcountsbyte)

---

## CM/header.jsp
**使用範例**: `<%@ include file="/html/CM/header.jsp" %>`
**輸入**: 無
**輸出**: 無（另見下方變數清單）
**功能**:
- 設定頁面共用基礎路徑變數（見 htmlBase、cssBase、imageBase、dispatcher）
- 設定文字長度計算基準變數（見 window.charCountsByte）
- **當該功能已啟用列印控管時**: 依當前頁面功能設定套用防列印保護
    - 列印時隱藏頁面內容，改為顯示禁止列印之提示文字
- **當該功能已啟用操作防護時**: 依當前頁面功能設定攔截滑鼠右鍵選單、剪下、全選、頁面儲存、複製等操作
    - 攔截上述操作並跳出提示訊息，說明依資安政策不開放對應功能
    - 複製操作額外記錄複製內容
- **當該功能已啟用浮水印時**: 依當前頁面功能設定於頁面套用浮水印
    - 浮水印內容包含使用者代號與套用當下的日期時間
    - **當無使用者代號時**: 改用使用者姓名
- **當請求來源網域為特定站台時**: 套用該站台指定之難字字型來源
- **當請求來源網域非特定站台時**: 使用預設難字字型來源
- **當存在回應時間量測識別碼時**: 於頁面載入完成時登錄量測結束時間點
- **當存在對應平台或系統識別資訊時**: 保留該資訊供後續換頁使用

---

## htmlBase
**使用範例**:
- `${htmlBase}`
- `<%=htmlBase%>`

**輸入**: 無
**輸出**:
- htmlBase: string - 網頁腳本等靜態資源之基礎路徑

**功能**:
- 提供頁面組成靜態網頁資源（如腳本檔案）之參照路徑

---

## cssBase
**使用範例**:
- `${cssBase}`
- `<%=cssBase%>`

**輸入**: 無
**輸出**:
- cssBase: string - 樣式表資源之基礎路徑

**功能**:
- 提供頁面組成樣式表資源之參照路徑

---

## imageBase
**使用範例**:
- `${imageBase}`
- `<%=imageBase%>`

**輸入**: 無
**輸出**:
- imageBase: string - 圖片資源之基礎路徑

**功能**:
- 提供頁面組成圖片資源之參照路徑

---

## dispatcher
**使用範例**:
- `${dispatcher}`
- `<%=dispatcher%>`

**輸入**: 無
**輸出**:
- dispatcher: string - 後端服務請求之基礎路徑

**功能**:
- 提供頁面組成後端服務請求路徑

---

## window.charCountsByte
**使用範例**: `window.charCountsByte`
**輸入**: 無
**輸出**:
- **當設定值為正整數時**: window.charCountsByte: number - 計算全形字元（如中文）所佔位元組數的基準值
- **當設定值非正整數時**: window.charCountsByte: number = 2 - 預設值

**功能**:
- 提供頁面計算文字長度限制時，作為全形字元位元組數之計算基準
