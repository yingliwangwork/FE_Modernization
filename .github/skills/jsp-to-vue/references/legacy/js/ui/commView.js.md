# commView.js 公開契約

## 使用語法清單
**方法**:
- [viewBizEvent(FLOW_NO, openAtNewPopupWin)](#viewBizEvent(FLOW_NO,-openAtNewPopupWin))

---

## viewBizEvent(FLOW_NO, openAtNewPopupWin)
**使用範例**: `viewBizEvent(rec.FLOW_NO);`
**輸入**:
- FLOW_NO: string - 審批流程編號
- openAtNewPopupWin: boolean = false - 是否另外建立獨立彈出視窗實體
**輸出**: 無
**功能**:
- 開啟彈出視窗顯示指定流程編號之作業流程內容，預設顯示於可視範圍右下方
- 依可視範圍尺寸調整彈出視窗之大小與顯示位置
- **當 openAtNewPopupWin 為 true 時**: 建立並使用獨立彈出視窗實體
- **當 openAtNewPopupWin 非 true 時**: 共用既有彈出視窗實體
- 依目前網址判斷所屬系統代碼，以組成查詢位址
