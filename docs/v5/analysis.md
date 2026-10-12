# v5 冷啟動差異分析

## 結論

**未收斂，且不是只剩 Low。** 本輪找到 `N_total = 9`：`High = 2`、`Medium = 4`、`Low = 3`。
三組 repo checker 都通過，但仍有一個外部相依狀態被 HTML 寫成肯定事實，以及 AFY10100
服務參數數量的三方矛盾；兩者都會讓反向重建產生行為差異。

`N_new候選 = 2`：

1. 「完整列舉正確，但同一產物內的 authoritative cardinality 多處互相矛盾」。
2. 「Markdown 明列外部相依為 UNKNOWN，HTML 卻把該狀態固定為真」。

因冷啟動限制禁止讀前輪具體遺漏清單，這只是候選數，須由統籌者與前輪結果去重後才能
宣告正式 `N_new`；本報告未用前輪答案反推。

## 機械門檻

| 畫面 | checker 原始摘要 | exit |
|---|---|---:|
| DSC80106 | `ok DSC80106 html_ids=57 md_visual_ids=67` | 0 |
| DSC32200 | `ok DSC32200 html_ids=46 md_visual_ids=58` | 0 |
| AFY10100 | `ok AFY10100 html_ids=124 md_visual_ids=151` | 0 |

來源求值點複算亦吻合帳本：DSC80106 為 EL 4 / Java expression 6；DSC32200 為
EL 12 / Java expression 12 / `c:forEach` 1；AFY10100 為 EL 240 / Java expression 19 /
`c:if` 12 / `c:forEach` 1 / `fmt:formatNumber` 88。

硬門檻判定：

| 硬門檻 | 結果 | 依據 |
|---|---|---|
| High 語意遺漏為 0 | **Fail** | G-01、G-02 |
| 欄位/服務/條件/事件/驗證/演算法覆蓋 100% | **Fail** | G-02、G-03 的數量契約互斥 |
| ID 唯一且雙向引用完整 | Pass（checker 範圍） | 三組 checker exit 0；但 checker 不驗證 U-* 引用，見 G-08 |
| UNKNOWN 不得寫成肯定句；缺陷不得靜默修正 | **Fail** | G-01、G-05、G-06 |
| HTML 離線、無 JSP/EL/業務 script/外部資源 | Pass | 三組 checker exit 0，人工掃描未見反例 |
| 反向重建不需猜測資料或可觀察行為 | **Fail** | 初始選取狀態與 service cardinality 互斥 |
| 外部路徑完整；資料表欄序/逐列格數可唯一重建 | **Fail** | G-04、G-05、G-06 |

## 缺口清單

| ID | Sev | 畫面 | 具體證據與影響 |
|---|---|---|---|
| G-01 | **High** | DSC32200 | Markdown 將 TableUI 的 `Y`→checkbox 映射列為 `U-06 [UNKNOWN]`（§4.1、§13），HTML 第 86 行卻固定輸出 `checked`。原碼只證實 `preCheck:'Y'`、`valueKey:'preCheck'`、`grid.load(...,["Y"])`（JSP 188–191、283–299、324–325），未取得 TableUI 契約。重建成勾選或未勾選會直接改變按「刪除」後是刪列還是顯示「請勾選」的狀態轉換。 |
| G-02 | **High** | AFY10100 | `openDetail` 原碼實際串接 **51** 個 query 參數（JSP 315–367；首個 `INSR_TYPE` 加後續 50 個 `&KEY=`）。Markdown §2 寫 39 個、§16 D1 寫 45 個，§5 雖逐字列出完整 51 鍵卻未給正確總數。39/45/51 三個互斥 service schema 使反向重建者必須自行選擇，可能漏送 `BROKTYPE` 後的個資/碼值欄位。 |
| G-03 | Medium | AFY10100 | 每筆結果列原碼有 **55** 個 hidden input，其中 **53** 個取 `rtnMap.*`、2 個取 description map（JSP 1797–1851）；Markdown R-EL-ROW-HIDDEN 與 R-LOOP-01 均寫「46 個」。§4.2 的分組清單較完整，但演算法與渲染 cardinality 矛盾，無法以宣告數量驗證列骨架。 |
| G-04 | Medium | AFY10100 | companion HTML 把保障彙整由來源的多區塊橫向表（標題 `colspan=16`，每列最多三組「項目/合計/同業合計/收件/承保」，JSP 499–958）轉成單一 5 欄、19 列直表；保費彙整也由 13 欄單列（JSP 959–1094）轉成 5 欄、3 列。Markdown 只保留全頁總格數，沒有兩表逐列格數/欄序，因此原始群組與順序不能唯一重建。 |
| G-05 | Medium | DSC32200 | 來源合計列第二格是 `colspan="5"`（JSP 367–371），Markdown §17 也明載 5；HTML 第 71 行改為 `colspan="4"`。D-01 只記缺 `</B>`/`</td>`，未記跨度正規化。這是跨產物矛盾及未登記的來源結構修正。 |
| G-06 | Low | AFY10100 | 搜尋表只有兩列，但來源查詢按鈕為 `rowspan="3"`（JSP 443–498）；HTML 第 56 行改成 2，D-INVALID-HTML 未列此項。可見效果通常只屬瀏覽器修復細節，但違反「缺陷不得默默修正」及逐列跨度可回轉要求。 |
| G-07 | Medium | AFY10100 | D-MISSING-NAME 把 F-NAME、明細 A_NAME 與 row hidden 沒有 `name` 直接判成 `[DEFECT-CONFIRMED]`。來源只能證實「不隨 form submit」；row hidden 明確被 `selectItem/openDetail` 消費，沒有需求證據要求它們直接提交。依 v5 §4 應先記現況，至多列 `[RISK-CONDITIONAL]`，否則正向工程可能修掉刻意的 staging 資料。 |
| G-08 | Low | AFY10100 | T-COND-ASYNC 引用 `U-HOTKEY-MISSING`，但 §13 沒有此未知；實際定義的是 `U-HOTKEY-DEFAULT`。checker 不檢查 U-*，故 exit 0 未攔到。 |
| G-09 | Low | AFY10100 | `resultList` 是重複資料區，但 HTML 只有一筆示例 `F-DETAIL-ROW`，沒有規則要求的 `<template data-repeat-id=... data-key-ref=...>`。Markdown 有 0-based index/1-based count 與空集合語意，故資料行為未整體遺失；缺的是 HTML 端可機械辨識的列範本/鍵契約。 |

## 每檔高風險語意抽查

### DSC80106（抽查 5 項，未發現缺口）

| 抽查事實 | 原碼證據 | IR 結果 |
|---|---|---|
| query endpoint 與 4 鍵 payload | JSP 57–90 | S-01 完整保留 `LOAN_ID/APPLY_DATE/CHG_KIND/SEQ_NO`、成功與無 error callback 現況 |
| 23 個回填欄位、falsey→空字串及 9 列欄序/跨度 | JSP 83–88、136–237 | §4/A-02 與兩快照一致；`6,6,4,6,4,6,6,0,1`、rowspan 及按鈕 `colspan=8` 均保留 |
| 關閉三路優先序及未載入時 `undefined` | JSP 48、95–104 | S-02～S-04、A-03、D-06 一致 |
| load→綁定→query→fix→message→resize 順序 | JSP 110–124 | A-04/T-INIT 一致 |
| load/resize/scroll 各自事件 | JSP 42–44 | §9 使用三個不同 ID，無重複 |

### DSC32200（抽查 5 項，2 項有缺口）

| 抽查事實 | 原碼證據 | IR 結果 |
|---|---|---|
| confirm endpoint、4 鍵 payload、ERR/TIPS 分支 | JSP 196–231 | Pass；S-CONFIRM 可重建時序 |
| 6 欄 grid、日期/金額事件及合計 | JSP 97–135、282–320 | Pass；欄序、record 寫回、格式與 NaN 邊界可重建 |
| 新增/刪除重編與驗證/確認順序 | JSP 44–69、178–205、234–274 | Pass；三種刪除轉換及 17→15→valid1 順序完整 |
| `c:forEach(null)` 與 option 渲染 | JSP 356–358 | Pass；null/empty 均零次，不標 UNKNOWN |
| 初始 checkbox、靜態表格跨度 | JSP 283–325、347–373 | **Fail**；分別見 G-01、G-05 |

### AFY10100（抽查 5 項，7 個缺口落在 5 類事實）

| 抽查事實 | 原碼證據 | IR 結果 |
|---|---|---|
| 六個服務、S-DETAIL payload 與 method | JSP 94–140、315–370 | endpoint/submit/Ajax/GET 大致完整；51 鍵列舉與 39/45 旁述互斥，見 G-02 |
| 選列/取消狀態、18 欄明細與 5 個 sort index | JSP 144–313、1708–1919 | 搬移、按鈕狀態與 2/3/4/9/14 映射一致；row hidden 數量錯誤見 G-03 |
| JSTL 與 null/解析邊界 | JSP 450–470、570–1086、1629–1642、1786、1892–1900、1920 | 12 `c:if`、1 `forEach`、88 `formatNumber` 的標準邊界皆正確 |
| 摘要表欄序/逐列格數與來源缺陷 | JSP 443–1094 | **Fail**；見 G-04、G-06 |
| 缺陷強度、未知引用、repeat 契約 | JSP 483、1786–1919 | **Fail**；見 G-07～G-09 |

## 反向重建風險

只讀雙產物的重建者至少仍需做四個不可接受的選擇：

1. DSC32200 初始列究竟是否已勾選；此選擇改變刪除行為（High）。
2. AFY10100 明細 GET 應送 39、45 或列舉出的 51 個參數（High）。
3. AFY10100 每筆 result row 應建立 46 或 55 個 hidden inputs（Medium）。
4. 保障/保費彙整應採來源的 16/13 欄橫向群組，或 companion HTML 的 5 欄直向表（Medium）。

因此不能宣告 JSP ↔ IR 無損，也不能宣告「只剩 Low」。本報告只記錄缺口，未修改六份 SoT。
