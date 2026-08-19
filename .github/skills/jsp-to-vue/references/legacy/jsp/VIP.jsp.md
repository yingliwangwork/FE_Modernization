# VIP.jsp 公開契約

## 使用語法清單
- [CM/VIP.jsp](#cmvipjsp)
- **方法**
    - [setVIPforAjax](#setvipforajax)

---

## CM/VIP.jsp
**使用範例**: `<jsp:include page="/html/CM/VIP.jsp" />`
**輸入**: 無
**輸出**: 無（另見下方方法清單）
**功能**:
- 產生VIP身份標示區塊，滑鼠移入時顯示貴賓別清單
- 支援同一頁面重複引用，每次引用自動產生獨立且遞增之識別碼，用以區分頁面上多個VIP標示區塊
- 初始渲染時不顯示VIP資料內容，需另行呼叫 setVIPforAjax 設定顯示內容

---

## setVIPforAjax
**使用範例**: `setVIPforAjax(vipid, vipBo)`
**輸入**:
- vipid: number - 欲更新之VIP標示區塊識別碼，對應該區塊於頁面上第幾次引用
- vipBo: object - VIP身份資料物件，包含以下欄位：
    - VIPF: boolean - 是否為VIP契約關係人
    - VIP: boolean - 是否為VIP
    - VIPOF: boolean - 是否為VIP（另一類別）
    - VIP_KIND: string[] - 貴賓別清單

**輸出**: 無（直接更新指定VIP標示區塊內容）
**功能**:
- **當 vipBo 為空或不含任一 VIP 旗標時**: 清空指定 VIP 標示區塊之內容
- **當 vipBo.VIPF 為真時**: 顯示「VIP 契約關係人」標示，並隱藏貴賓別清單
- **當 vipBo.VIP 或 vipBo.VIPOF 為真時**: 顯示 VIP 標示，並列出貴賓別清單內容
