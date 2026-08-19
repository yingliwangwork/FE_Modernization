# AlertHandler.js 公開契約

## 使用語法清單
**方法**:
- [AlertHandler](#AlertHandler)
    - [constructor()](#constructor())
    - [display()](#display())
    - [clear()](#clear())

---

## constructor()
**使用範例**: `validator.errHandler = new AlertHandler();`
**輸入**: 無
**輸出**:
- 執行個體: AlertHandler - 錯誤訊息收集與顯示之控制物件
**功能**:
- 建立錯誤訊息收集器，初始化訊息清單與標記清單

---

## display()
**使用範例**: `validator.errHandler.display();`
**輸入**: 無
**輸出**: 無
**功能**:
- 將已收集之錯誤訊息合併為單一文字內容並顯示提示
- **當本輪收集內已顯示過一次時**: 重複呼叫不會再次顯示，須待 clear() 重設後才會再次生效

---

## clear()
**使用範例**: `validator.errHandler.clear();`
**輸入**: 無
**輸出**: 無
**功能**:
- 清空已收集之錯誤訊息與標記清單
- 重設訊息可再次顯示之狀態
