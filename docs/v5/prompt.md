# v5 JSP → 雙產物 IR 生成提示詞

```text
把指定 JSP 轉成一對 `<ID>.html` 視覺契約與 `<ID>.md` 業務/互動契約。
兩份合起來才是 IR，目標是功能與結構可近乎無損反向重建，不追求原技術語法相同。

必讀且依序套用：
1. docs/v4/prompt.md（完整工作流程）
2. docs/v4/template.visual.html 與 docs/v4/template.logic.md（產物形狀）
3. docs/v4/rules.md（基礎規則）
4. docs/v5/rules.md（優先級最高的收斂補丁）
5. 已核准的共用元件 SoT

固定輸入：
- JSP：{{JSP_PATH}}
- screen_id：{{SCREEN_ID}}
- complexity：{{COMPLEXITY}}
- 輸出 base：docs/v5/sot/{{SCREEN_ID}}

冷啟動限制：只讀以上輸入，不得讀任何 v1–v4 畫面 SoT/analysis、其他樣本或 git history。

除 v4 的全部要求外，這輪強制：
- HTML 的每個 data-ir-id 都要在 Markdown 原字出現；範圍或 wildcard 不算。
- 同構欄位共用契約，但在 §17 建立逐字 ID 索引，不複製敘述。
- load/resize/scroll 等不同事件使用不同 ID；§9 定義 ID 不重複。
- 按 JSTL 標準記錄 c:forEach 與 fmt:formatNumber 的 null/empty/解析失敗行為。
- 沒有需求證據時，把「缺確認/前端驗證/失敗 callback」記為現況或
  [RISK-CONDITIONAL]，不可直接判 [DEFECT-CONFIRMED]。
- 最後必須執行 `scripts/check-ir-pair.sh docs/v5/sot/{{SCREEN_ID}}`；
  若失敗就修正並重跑，直到 exit 0。不得用自製替代檢查器宣稱通過。

完成只回報兩個路徑、checker 原始單行摘要、來源盤點覆蓋數與 UNKNOWN 數。
```
