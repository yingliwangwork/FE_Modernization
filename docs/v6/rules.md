# v6 語意一致性規則

本檔依序覆蓋 `docs/v4/rules.md`、`docs/v5/rules.md`。v6 修正「內部連結正確但語意仍矛盾」的失敗模式。

## 1. UNKNOWN 不得被 HTML 具象成單一真相

- 若 Markdown 明列某外部元件的狀態映射為 `[UNKNOWN]`，HTML 不得固定呈現其中一種結果
  （例如固定 `checked`、固定 disabled、固定排序後順序）。
- HTML 應使用 `data-unknown-ref="U-*"` 並採中立呈現，或各做一個有清楚標籤的候選快照；
  候選快照不得被標成 default/current。
- 來源輸入值仍要如實保留，例如 `preCheck='Y'` 是確定資料；`Y` 是否映射為勾選則是另一個命題。
- `scripts/check-ir-pair.sh` 會要求所有 `U-*` 引用都在 Markdown §13 有定義。

## 2. 數量與 schema 只有一個權威帳本

- 服務參數數、每列 hidden 數、求值點數、欄位數等 cardinality 只能在 §0 完整性帳本
  與對應契約表列為權威數字。
- 其他章節只能說「完整清單見 §X / ID」，不得重新手寫數字。
- 產出前由**清單機械計數**，再填數字；禁止先估計數字再補清單。
- 對服務/row schema，`宣告數量 == 清單實際項數 == 來源機械計數` 必須成立。

## 3. HTML 是來源視覺結構，不是重新設計

- 保留來源由上而下/由左至右的區塊順序、橫向/縱向方向、每列群組、欄序、
  rowspan/colspan 與空白保留格。不得把橫向 15/13 欄彙整改畫成 5 欄直表。
- 可以修成有效 HTML5 標記，但修復後的表格網格必須呈現來源在目標瀏覽器可觀察的結構；
  任何 normalized change 都要 `data-defect-ref` 且在 Markdown §14 記原值與新值。
- 每個來源表格在 §17 有逐列 `th/td` 數、rowspan/colspan、排序入口與 HTML anchor。

## 4. 現況事實、風險、缺陷三層分開

- `無 name`、`無確認`、`無前端驗證`、`無 failure callback` 先記為現況事實。
- 只有可由需求/契約/安全後果證明「現況不符合要求」時才用 `[DEFECT-CONFIRMED]`。
- 缺少需求證據時使用 `[RISK-CONDITIONAL]`，並寫成立條件；不可把 staging/cache 欄位
  因無 name 就判為 defect。

## 5. 重複區與語意引用

- 來源迴圈產生可見列時，HTML 必須有 `<template data-repeat-id="R-*" data-key-ref="...">`，
  並至少包含完整欄位骨架；示例列不能取代 template。
- Markdown/HTML 所有 `U-*` 引用必須可解析到 §13；拼字相近不算。
- 對 `D-*`、`R-*`、`S-*` 等 ID 也要人工做同樣的定義/引用反查。

## 6. v6 交付門檻

1. 三組 repo checker exit 0。
2. HTML 不把 UNKNOWN 固定成 default truth。
3. 所有 schema/cardinality 單一且由清單計數。
4. 所有來源表格的方向、分組、欄序與跨度可由 HTML 唯一重建。
5. 可見迴圈有 `template[data-repeat-id]`。
6. v5 的 G-01～G-09 不重現，且不新增 High/Medium 類型。
