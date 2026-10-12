# 瀏覽器案例量測更正

初次 accumulated-message-width 用 textContent 檢查含 br 的換行；textContent 不產生 br 的視覺換行，因此該筆失敗不能據此判為產品反應缺陷。改以 innerText（contains 動作）核對可見內容及寬度。初次報告與 scenario 原件保留，產物沒有修改。

本次另外加入來源確認的匯出結果格對齊檢查；根頁僅將新增列前三格置中，結果格保留預設。所有結果以更正後的 browser.json 為本輪結論，初次結果另存 browser-first-run.json。
