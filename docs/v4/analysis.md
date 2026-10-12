# v4 冷啟動精簡審查

## 結論

**不通過硬門檻，不得稱為最佳版本。** 本輪只按三個固定樣本各抽查五個最高風險事實，未重做全量來源盤點。

- `N_total = 5`（Medium 4、Low 1）
- `N_high = 0`
- 三組 `check-ir-pair.sh`：`DSC32200` PASS（44/54）、`DSC80106` PASS（47/56）、`AFY10100` FAIL（51 個 HTML IR ID 未在 Markdown 原字出現）

## 硬門檻

| # | 門檻 | 結果 | 證據 |
|---:|---|---|---|
| 1 | High 語意遺漏為 0 | **PASS** | 15 個最高風險抽查點未發現 High；`N_high=0`。 |
| 2 | 欄位、服務、渲染、事件、驗證、演算法覆蓋 100% | **PASS（抽查範圍）** | 三份 §0 均有機械盤點；本輪服務參數、欄序/文字、狀態/事件抽查未見來源原子遺漏。此結論不代表重新做過全量盤點。 |
| 3 | HTML/Markdown ID 唯一且雙向完整 100% | **FAIL** | `AFY10100` 配對檢查列出 51 個 HTML-only ID；另 `DSC32200.md:453-455` 以同一 `E-VIEWPORT` 定義 load/resize/scroll 三個不同事件。 |
| 4 | 未知未寫成肯定句；缺陷未默默修正 | **PASS** | 抽查的未知皆有標記；AFY/DSC 的壞表格與來源風險均在 §14 留痕，視覺正規化未靜默。 |
| 5 | HTML 離線、無業務 script/JSP/EL/外部資源 | **PASS** | 三份皆為完整 HTML5；禁止物掃描無命中，資源全為內嵌 CSS/語意內容。 |
| 6 | 反向重建不需猜會改變行為/資料的規則 | **FAIL** | `DSC32200.md:79` 把標準 `c:forEach` 的 null/空集合語意降為 assumption；`AFY10100.md:64` 把 `fmt:formatNumber` 的 null/空字串語意留為 UNKNOWN。 |
| 7 | 完整外部路徑；表格欄序/逐列格數可唯一重建 | **PASS** | 三份 §12/§17 均保留組合路徑與逐列格數；抽查欄序、文字與排序入口和 JSP 一致。 |

## 15 點抽查摘要

| 樣本 | 服務參數 | Java/EL null | 欄序/文字 | 狀態/事件 | 缺陷分類 |
|---|---|---|---|---|---|
| `DSC80106` | PASS：query 四鍵及三路 close 參數吻合 JSP 79、95–104 | PASS：Java null=`null`、EL null=空字串分開記錄 | PASS：23 欄、9 列及 `colspan=8` 均保留 | PASS：載入、查詢三結果、關閉三分支可重建 | PASS：falsy 資料遺失、無錯誤 UI、注入風險均有條件邊界 |
| `DSC32200` | PASS：confirm、兩個 popup 的鍵與常數吻合 JSP 148–172、196–231 | **GAP M**：標準 tag 行為被降為 assumption | PASS：grid 六欄與靜態 5/2/1 cells 吻合 | **GAP M**：`E-VIEWPORT` 重複定義三種事件 | PASS：已確認/條件風險/疑似死碼分級有證據 |
| `AFY10100` | PASS：detail 51 鍵及五個 submit/Ajax 入口吻合 JSP 94–141、315–370 | **GAP M**：formatNumber null/空字串留 UNKNOWN | PASS：18 欄、五個排序入口、PAY_AMT13 兩種原文均保留 | PASS：選取/清除、條件節點、detail 預設跳頁均記錄 | **GAP L**：`D-08`/`D-09` 的現況已證實，但「一定是缺陷」缺少需求依據 |

## 具證據的缺口

1. **[M] AFY 跨產物 ID 斷鏈。** `check-ir-pair.sh docs/v4/sot/AFY10100` 失敗：19 個彙整、19 個編輯、13 個結果欄位 ID 只存在 HTML。Markdown 使用 `F-SUM-PAY-AMT1..19`、`F-RESULT-*`、`F-EDIT-*` 等範圍寫法（如 `AFY10100.md:64,67,109,479`），不符合原字匹配契約。
2. **[M] DSC32200 事件 ID 不唯一。** `DSC32200.md:453-455` 的 load、resize、scroll 都定義成 `E-VIEWPORT`，但三者分別初始化或只呼叫 `fix()`；引用無法唯一定位。
3. **[M] DSC32200 標準 tag null 語意未落定。** JSP 356–358 是明確的 `c:forEach`；`DSC32200.md:79` 仍標 `[ASSUMPTION]`，讓空集合重建多一個不必要決策。
4. **[M] AFY formatNumber null/空字串語意未落定。** 88 個格式化 tag 被 `AFY10100.md:64-67` 共用同一 UNKNOWN；這會影響大量金額欄空值究竟顯示空白或失敗。
5. **[L] AFY 缺陷標籤過度肯定。** JSP 94–141、1330–1613 能證實「刪除無確認、部分入口無驗證/失敗處理」，但無需求證明它們必然是 defect；`AFY10100.md:433-434` 同時又寫「產品決策／後端是否承擔需確認」。應把事實與缺陷判定拆開。

## v5 最小修正

1. 在 `AFY10100.md` 增加 51 個 HTML ID 的逐字索引（可共用既有群組契約，不需重複業務內容），並讓配對檢查通過。
2. 將 `DSC32200` 的 `E-VIEWPORT` 拆成 `E-WINDOW-LOAD`、`E-WINDOW-RESIZE`、`E-WINDOW-SCROLL`，同步更新引用。
3. 依標準 tag 契約寫死 `c:forEach` 與 `fmt:formatNumber` 的 null/空值輸出；只把容器偏離標準的可能性留作條件風險。
4. 將 AFY `D-08`/`D-09` 拆成「已確認現況」與 `[RISK-CONDITIONAL]`；取得需求後才升格 defect。
5. 重跑三組 `check-ir-pair.sh`，再補一個「Markdown 事件定義 ID 不重複」檢查。
