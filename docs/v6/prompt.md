# v6 JSP → 雙產物 IR 生成提示詞

```text
把指定 JSP 轉成同名 `.html` 視覺契約與 `.md` 業務/互動契約；兩者共同構成 IR。

依序讀取並套用：
- docs/v4/prompt.md
- docs/v4/template.visual.html、docs/v4/template.logic.md
- docs/v4/rules.md
- docs/v5/rules.md
- docs/v6/rules.md（優先級最高）
- 核准的共用元件 SoT
- scripts/check-ir-pair.sh

輸入：{{JSP_PATH}}
固定 metadata：screen_id={{SCREEN_ID}}、complexity={{COMPLEXITY}}
輸出：docs/v6/sot/{{SCREEN_ID}}.html 與 `.md`

冷啟動：禁止讀 v1–v5 的畫面 SoT/analysis、其他樣本、git history。

這輪特別程序：
1. 先由實際清單計數服務參數、每列 hidden、欄位、求值與表格逐列格數；把唯一權威數量
   寫進 §0/對應契約，其他章節只引用，不重寫數字。
2. 逐一比對 Markdown 的 UNKNOWN：HTML 若依賴該命題，不得固定畫成其中一種真相；
   改用 data-unknown-ref 的中立呈現或清楚標示的候選快照。
3. 逐表照來源保留方向、每列分組、欄序、空白格、rowspan/colspan；不得重新排版成較簡單網格。
4. 每個可見迴圈在 HTML 建立 template[data-repeat-id][data-key-ref]，保留完整列骨架。
5. 無 name/確認/前端驗證/failure callback 先寫現況；沒有需求證據時只能標
   [RISK-CONDITIONAL]，不可標 [DEFECT-CONFIRMED]。
6. 反查全部 U-* 定義與引用，再執行 `scripts/check-ir-pair.sh docs/v6/sot/{{SCREEN_ID}}`；
   非零就修到通過。最後重算 schema 清單與 cardinality，任何兩處不同就失敗。

只回報兩檔路徑、checker 原始單行、權威 cardinality 摘要與 UNKNOWN 數。
```
