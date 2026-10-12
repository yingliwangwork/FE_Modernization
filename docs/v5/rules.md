# v5 收斂規則

本檔是 `docs/v4/rules.md` 的收斂補丁；未覆蓋處全部沿用 v4。v5 不改雙產物形狀，
只修正跨產物可追溯性、事件唯一性、標準標籤邊界與缺陷判定。

## 1. 禁止範圍縮寫代替 ID 索引

- HTML 每個 `data-ir-id` 必須在 Markdown 至少原字出現一次。
- `F-PAY-AMT1..19`、`F-RESULT-*`、`E-SORT-*` 等縮寫可作說明，但**不能取代**逐字索引。
- 大量同構欄位可共用一份業務契約；仍須在 §17 以一列一 ID 或逗號分隔的完整 ID
  建立索引。不得複製 19 次相同敘述。
- 完成後必須執行 repo 的 `scripts/check-ir-pair.sh <base>`；非零即不得交付，
  不得以自行撰寫的較寬鬆檢查取代。

## 2. 事件 ID 是事件定義，不是事件群組

- 一個事件 ID 只代表一個 event type + target + phase。
- `load`、`resize`、`scroll` 必須各自使用不同 ID，即使共用同一處理函式。
- §9 第一欄的事件定義 ID 不得重複；引用可重複。
- `scripts/check-ir-pair.sh` 會檢查 §9 的事件定義唯一性。

## 3. JSTL 標準邊界語意

若來源使用標準 JSTL，且沒有證據顯示容器偏離規格，下列是**確定契約**，不可標 UNKNOWN：

- `<c:forEach items="null">`：把 null 當空集合，不執行迴圈。
- `<fmt:formatNumber value="null或空值">`：不向 `JspWriter` 輸出任何內容；若有 `var`，
  移除該 scoped variable。
- `<fmt:formatNumber>` 的字串值解析失敗：捕捉後以 `JspException` 重拋；訊息包含原值。

規格來源：Jakarta Standard Tag Library 2.0 §6.2 與 §9.7：
`https://jakarta.ee/specifications/tags/2.0/jakarta-tags-spec-2.0`。
「實際部署的實作是否偏離標準」可列 `[RISK-CONDITIONAL]`，但不能讓標準語意退回未知。

## 4. 現況事實與缺陷判定分離

- 能由來源證實「沒有確認、沒有前端驗證、沒有失敗 callback」時，先以中性現況事實記錄。
- 只有具備產品/法規/既有契約證據時，才標 `[DEFECT-CONFIRMED]`。
- 未取得需求但存在可能風險時，標 `[RISK-CONDITIONAL]`，並寫明成立條件與決策者。
- 安全上的情境未轉義、未 URL encode、稽核/管制失效可依技術安全後果標 confirmed risk，
  但「應如何修正」仍是 §16 的人工決策。

## 5. v5 交付門檻

三個固定樣本都必須同時滿足：

1. `scripts/check-ir-pair.sh` exit 0。
2. §9 事件定義 ID 無重複。
3. `c:forEach`、`fmt:formatNumber` 標準 null/empty 行為無 UNKNOWN/ASSUMPTION。
4. HTML-only 與 Markdown-only 視覺 ID 集合差為空（非視覺 `F-HIDDEN-*` 除外）。
5. v4 審查列出的五項不得重現，且不得新增 High/Medium 類型。
