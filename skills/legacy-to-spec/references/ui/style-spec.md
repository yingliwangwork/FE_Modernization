# 元件樣式規格與 prototype CSS

## 格式基準

採 [Google Labs DESIGN.md 官方規格](https://github.com/google-labs-code/design.md/blob/main/docs/spec.md) 的 `alpha` 格式（核對日期 2026-10-12）：YAML 樣式值與 Markdown 使用規則並存。此專案用它記錄已確認的設計，不從畫面名稱猜品牌、情緒或風格。正式行為規格仍以技術中立語意描述；CSS selector 與 token 路徑放在樣式文件。

選用 tokens 交換格式時採 [DTCG Format 2025.10](https://www.designtokens.org/tr/2025.10/format/) 的 JSON `$type`／`$value`。DESIGN.md frontmatter 不是 DTCG JSON；不得將兩者當作同一 schema。格式版本與核對來源登錄於 tracking，版本升級另記變更。

## 雙份交付

每個有樣式設計的 `CMP-*`，同時交付：

1. `artifacts/design/<scope>/components/<CMP-ID>/DESIGN.md`：值、用途、變體、來源／決策與驗證定義。
2. `artifacts/design/<scope>/styles/<CMP-ID>.css`：prototype 真正載入的元件樣式。

畫面本身的版面／基礎字型也作為有 ID 的呈現元件記錄，不能只交付按鈕而遺漏全頁樣式。有相同定義的共用元件可直接引用既有版本的 DESIGN.md 與 CSS；不重寫、不複製一套分岐值，但須核對適用範圍與本頁變體。元件無來源樣式時，說明採瀏覽器原生呈現及限制，不能為滿足文件數量創造設計。

可加 scope `DESIGN.md` 作元件索引／共同 token 定義；它不能取代元件明確的樣式對應。共同 CSS 可另存 `styles/shared.css`；所有引用保持本地可解析。`design-md+dtcg` 另交付 `styles/tokens.json`，各可表示的值與 DESIGN.md／CSS 共用同一語意。

## DESIGN.md 撰寫

使用 [元件範本](../../templates/design/DESIGN.md)。採官方章節次序，無證據的節刪除或註明具體缺口；不得為湊完整性新增色票、字型階級、間距尺度、圓角、hover、focus 或 responsive breakpoint。

Frontmatter 用 `name`、`version: alpha` 與適用的 `colors`、`typography`、`spacing`、`rounded`、`components`。值只填已知項目；缺少色彩資訊時不補 `primary`。依官方 `omitted` 記錄有理由省略的群組，未取得來源則在正文連 TODO，不能誤寫「不存在」。變體使用相關的 component key，需與已證實的狀態對應。

`typography` 每個 token 是物件，欄位用格式定義的 camelCase，不直接放 CSS 宣告名／字串。例如只有來源證實 sans-serif 時可寫：

```yaml
typography:
  page:
    fontFamily: "sans-serif"
```

未確認的 fontSize／lineHeight 不為通過格式檢查而補值。執行 `python3 <skill>/scripts/check_design_metadata.py <各元件 DESIGN.md>` 檢查本 profile 的 token 群組形狀及 typography 欄位（需現有 PyYAML）；另依來源核對值／引用與 CSS。此 helper 不等於完整官方 validator，結果要保留其檢查限制。

正文逐筆給 `STYLE-*`，連到 CMP／UI／ST／來源 `E-*` 或核准變更。映射表保留：token 路徑（無 token 則明列）、規範值及單位、CSS 檔案／selector／property／宣告值、適用條件、實際載入的 prototype、瀏覽器檢查步驟與預期 computed style。驗證結果留在 tracking。不能只列「使用同一色系」「適當間距」。

格式無法直接表示的 legacy `pt`、`%`、複合 padding、條件尺寸與 `calc()` 等，在正文與 CSS 保留精確值／公式；不放入宣稱符合 schema 的錯誤 token 型別。動態尺寸說明初值、增減條件、上限及中間狀態，不硬編一個展示尺寸取代規則。

## DTCG 選用規則

使用 [tokens 範本](../../templates/design/tokens.json) 作結構起點，刪除非適用項，填入實際來源值；範本的 `$description` 是編寫提示，不得留在成果中冒充來源。

`dimension` 使用 `{ "value": 數值, "unit": "px" 或 "rem" }`；`color` 使用含 `colorSpace`、`components`、`alpha` 的值。引用必須可解析且無循環。不將 pt／百分比／em 隨意轉成 px；有可證實的基準與換算才轉，否則保留在 DESIGN.md／CSS，列出 tokens 未涵蓋項與原因。不能宣告未涵蓋的所有樣式都已符合 DTCG。

## 生成與核對

- 先分析樣式來源、載入順序、selector 優先序、繼承與狀態，再決定值。後端 wire schema 不能替前端決定樣式。
- 產品 CSS 保持在上述樣式交付檔案，由 HTML `<link rel="stylesheet">` 載入。不要在 prototype 複製另一套同名規則；動態 inline style 僅表達已證實的狀態／尺寸公式，並列入映射。審閱工具 CSS 分開標記，不當成產品樣式。
- 每個 styled CMP 在設計規格的樣式索引連到 DESIGN.md、CSS、prototype；tracking 登錄檔案雜湊、STYLE 覆蓋及驗證。延期／待決來源在受影響樣式行、CMP／UI／ST 同時標 TODO，並連 plan 後續任務。
- 在瀏覽器對照各已知變體的 computed style 與必要的幾何／層疊；驗證 selector 實際命中且沒有後載 CSS 覆蓋，檢查拖曳／重複訊息等動態樣式。只比文件與 CSS 文字不能證明顯示一致。
- 純解析或格式檢查只宣告其已檢查範圍。若使用官方格式 validator，記錄實際版本／命令／結果，不以檔名或 JSON 可解析就宣稱符合完整標準。來源執行畫面缺失時不宣告像素等價。
