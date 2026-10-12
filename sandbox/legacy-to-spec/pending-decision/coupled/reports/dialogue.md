# 待決依賴：模擬對話試驗

這是獨立測試代理的輸出紀錄，不是正式使用者的待批工作。未提供任何先翻新／延後答案；沒有向真實使用者發送重複的試驗問題。

代理先建立 [plan](../artifacts/renovation/fixture-case/plan.md) 與 [tracking](../artifacts/renovation/fixture-case/tracking.md)，核對共用查閱按鈕來源雜湊與版本後引用，另完成不依賴決策的來源與耦合責任盤點。

代理實際提出的選擇內容：

| 決策 | 資源與查找結果 | 告知的影響 |
| --- | --- | --- |
| DEC-02 | styles/base.css、legacy-bridge.js 未找到適用規格 | 頁面、表格視覺、查詢交換及回呼邊界 |
| DEC-03 | example.Ledger、session 提供端未取得來源／契約 | 數量儲存、受信任單位、首次顯示審閱者；先處理仍需取得資料 |
| DEC-04 | 選定後端未承接排序提示、名稱、數量送出 | 三欄結果、初始化與送出，需後端承接，不補造 API |

代理要求模擬使用者逐組選「先處理或延後，也可拆開選擇」，全部維持待決。沒有自行判為延後，也没有生成受決策影響的設計、原型、API 投影或移交文件。

實際階段是規劃及獨立盤點的部分成果；[階段檢查](../artifacts/renovation/fixture-case/check-result.json) 和 [來源雜湊紀錄](../artifacts/renovation/fixture-case/source-check.json) 分開保存。這個試驗只驗證待決處理及對話內容，不宣稱完整交付或瀏覽器／後端測試通過。
