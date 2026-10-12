# 必要可用依賴契約 v1

在根入口規格生成前建立；範圍僅本頁使用。來源雜湊見 [inventory](../../renovation/fixture-case/source-inventory.json)。

## DEP-01：重用查閱動作

直接引用 [CMP-SEARCH-ACTION](../../../inputs/specs/action-bar.md#cmp-search-action)，fixture-component-v1。來源片段 SHA-256 与規格相符。標籤「查閱」、啟動引用頁提供的查閱行為；無額外禁用條件。未重写共用行为。

## DEP-02：查閱交換邊界

版本 v1，證據 E-04：legacy-bridge.js 1–8。接收引用頁提供的關鍵字資料，發起交換；解析回傳資料後通知引用頁，由引用頁更新畫面。來源沒有定義 transport／解析失败的可見回饋，不補造成功或错误；TODO-04 見 [tracking](../../renovation/fixture-case/tracking.md#todo-04)。來源 transport 細節留在 tracking，目標 wire 只依 API 基準。

## DEP-03：本頁樣式

版本 v1，證據 E-05：base.css 1–4。僅一个載入的來源 stylesheet，整頁 sans-serif、最大寬 720px、margin 24px、文字 #222；結果表格 collapse、100% 寬、16px 0 margin；所有表頭及資料格 1px solid #555、padding 6px、left 對齊；查閱動作列 margin-top 8px。無批准的新視覺設計。

細項另依各 CMP 的 DESIGN.md／實際載入 CSS 與 tokens 交付；原生輸入、按鈕、標題尺寸及瀏覽器預設仍由瀏覽器決定。
