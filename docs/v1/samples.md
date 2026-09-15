# 迭代基準樣本（Benchmark Samples）

本檔一經確立即**固定不變**，往後每輪迭代都使用同一組樣本，
以確保不同輪次之間的 SoT 品質可直接比較。

## 抽樣方法

1. 對 `sourceCode/` 下全部 603 個 `.jsp`（有效 600 個）計算靜態複雜度指標。
2. 指標與權重：

   | 指標 | 說明 | 權重 |
   |---|---|---|
   | `lines` | 行數 | 1 |
   | `scriptlet` | `<% ... %>` 出現次數 | 3 |
   | `expr` | `<%= ... %>` 出現次數 | 1 |
   | `include` | `<%@ include>` / `<jsp:include>` | 5 |
   | `taglib` | JSTL / 自訂標籤（`c:` `fmt:` 等） | 2 |
   | `el` | `${...}` EL 運算式 | 1 |
   | `jsfunc` | JavaScript 函式宣告 | 4 |
   | `input` | `input` / `select` / `textarea` | 2 |
   | `table` | `<table>` | 3 |
   | `ajax` | 非同步呼叫相關符號 | 5 |

   `score = Σ (指標值 × 權重)`

3. 分位數：`min=6  p25=265  p50=414  p75=718  p90=1209  max=9962`
4. 分層與隨機抽取（`random.seed(20260915)`）：
   - 低：`score ≤ p33`（199 檔）
   - 中：`p33 < score ≤ p75`（252 檔）
   - 高：`score > p90`（58 檔）

> 重現指令：`scripts/metrics.sh`（產生 `metrics.tsv`）→ 依上表計分抽樣。

## 三個基準樣本

| 層級 | 檔案 | score | 行數 | 特徵 |
|---|---|---|---|---|
| 低 | `sourceCode/DS/C8/DSC8_0100/DSC80106.jsp` | 284 | 240 | 唯讀明細頁、單一 Ajax 查詢、以 DOM id 對映資料 |
| 中 | `sourceCode/DS/C3/DSC3_2200/DSC32200.jsp` | 484 | 383 | 可編輯表格（TableUI）、前端驗證、金額合計、彈窗連動 |
| 高 | `sourceCode/AF/AFY10100.jsp` | 2810 | 2012 | 查詢＋列表＋編輯區狀態機、熱鍵、JSTL 迴圈、表單整包 submit |

三者共同涵蓋的技術面：
BIG5 編碼、`/html/CM/header.jsp` 與 `/html/CM/msgDisplayer.jsp` 共用 include、
Prototype.js、伺服器端 EL 內嵌進 JavaScript、table-based layout。

## 樣本未涵蓋、後續輪次需另行補樣的面向

- `<% ... %>` scriptlet 重邏輯頁（三個樣本的 scriptlet 數皆為 0）
- `<jsp:include>` 動態引入與 frameset 頁
- 檔案上傳 / 下載、報表列印、PDF 檢視
- 自訂 taglib（`cathay:` / `input:` / `CXL:`）密集使用的頁面
