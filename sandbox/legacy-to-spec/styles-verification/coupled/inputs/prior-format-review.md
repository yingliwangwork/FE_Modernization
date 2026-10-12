# DESIGN.md 格式核對

2026-10-12，主代理依 [Google Labs 官方 alpha 格式](https://github.com/google-labs-code/design.md/blob/main/docs/spec.md) 的 typography map／Typography object 定義核對。

FORMAT-01（中）：`components/CMP-PAGE/DESIGN.md` frontmatter 使用 `typography: { font-family: "sans-serif" }`，把 CSS property／字串當成 token。應為有名稱的 typography object，例如 `page: { fontFamily: "sans-serif" }`；不補造未有來源的字級或行高。

[局部形狀檢查](design-metadata-before-fix.json) 以維護套件 check_design_metadata.py 實際重現此錯誤，其他兩份元件檔案通過其檢查範圍。此工具只檢查 name、群組形狀與 typography 欄位，不宣稱完整官方 schema／引用／值驗證。

三份 CSS 及瀏覽器可見樣式未受此錯誤影響；[瀏覽器](browser.json) 5/5 情境、22 斷言通過。修正應在獨立續作目錄保留原產物與錯誤證據。
