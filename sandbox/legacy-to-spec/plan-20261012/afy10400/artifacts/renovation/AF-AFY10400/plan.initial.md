# AF-AFY10400：翻新計劃

> 初始計劃於依賴分析前建立；後續盤點將更新同一計劃。設計規格預期位置：`artifacts/design/AF-AFY10400/specification.md`（待建立）。追蹤預期位置：`artifacts/renovation/AF-AFY10400/tracking.md`（待建立）。

## 1. 初始範圍與順序

| 項目 | 內容 |
| --- | --- |
| 唯一根 JSP／scope | `inputs/frontend/sourceCode/AF/AFY10400.jsp`／AF-AFY10400 |
| 來源版本 | SHA-256 `fbf8f94aee2f03f830f5092ba280dca6f6707ce45d54a929e6ec7cecd4284b1a`；未以案例外 Git 版本補充 |
| 初始納入 | 根入口的有限依賴盤點、既有契約適用性查找、必要與選用任務及選擇關卡 |
| 初始排除 | 未選擇的行為規格、API、移交、原型、CSS、tokens；相依入口內部翻新；外部系統查詢；後端程式執行 |
| 建立時間／依據 | 2026-10-12T12:43:01.157003+00:00；入口存在性與 hash 已核對，尚未讀取 JSP 內容進行依賴分析 |
| 啟動／目前階段 | `/legacy-to-spec jsp=inputs/frontend/sourceCode/AF/AFY10400.jsp`；首次啟動，準備盤點 |
| 工作順序 | 建立計劃 → 依賴盤點與契約查找 → 任務與依賴選單 → 等待選擇 → 執行所選工作 → 驗證與更新 |
| 既有授權 | 啟動僅授權計劃與盤點；無執行任務、依賴扩充或延後決策 |
| 沙盒限制 | 只讀案例 task、manifest、skill、inputs；只寫 artifacts；不詢問真實使用者 |

### 範本與規則

預設內建範本、style_profile=`design-md`；本輪未提供 config；選用路徑、理由與雜湊見 [選用清單](template-selection.json)。本次先採用 plan/tracking 角色；其餘角色待任務选择。無補充 reference、風格或行為變更授權。

## 2. 依賴與契約查找

尚未分析。TASK-01 将記錄根 JSP 引入點、可得性、inputs 中實際查找範圍、適用性及停止邊界。依賴未取得不代表系統不存在該能力。

## 3. Required／Optional 任務與影響

| TASK ID | 分類／適用依據 | 建議順位 | 工作及明確範圍 | 前置依賴 | 影響／預期交付 | 完成條件與驗證 | 執行狀態／選擇 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TASK-01 | required；首次啟動盤點 | 0 | 根入口有限盤點與既有契約查找 | 初始計劃已建立 | plan、tracking、來源 metadata | 逐項資源定位、實際查找及未決影響；入口 hash／行數／编码核對 | 可執行；由啟動授權 |
| TASK-02 | required；行為契約 | 待盤點排序 | 根入口可觀察行為與責任映射 | TASK-01；依賴影響待盤點 | 預期 specification.md | 來源事件／分支／資料到契約映射，未知有 TODO | 未選；可執行範圍待盤點 |
| TASK-03 | required（若有交換／未承接責任） | 待盤點排序 | 邊界契約與後端移交 | TASK-01；後端基準未提供 | 預期 api-spec.md／backend-handoff.md | 兩端映射及承接證據；未知不補造 | 未選；適用性待盤點 |
| TASK-04 | required；視覺與互動 | 待盤點排序 | 已知行為離線原型 | TASK-02；呈現依賴待盤點 | 預期 prototypes/SCR-ID.html | 文字／互動一致且有驗證 | 未選 |
| TASK-05 | required（有樣式元件時） | 待盤點排序 | 樣式規格與實際 CSS 雙份交付 | TASK-01；樣式來源待盤點 | 預期 components/CMP-ID/DESIGN.md、styles/CMP-ID.css | 來源與生效值映射、瀏覽器核對 | 未選 |
| TASK-06 | required；交付驗證 | 待盤點排序 | 所選範圍驗證與持續追蹤 | 對應所選任務完成 | tracking.md | 引用、覆蓋及必要視覺／互動檢查並記限制 | 未選 |
| TASK-07 | optional；額外樣式 tokens | 待盤點排序 | DTCG tokens | TASK-05 | 預期 styles/tokens.json | 格式及 CSS 值映射 | 未選 |

## 4. 任務選擇、依賴決策與對話紀錄

尚未提供盤點後選單，尚無使用者選擇；不默認選任務或延後資源。

## 5. 計劃變更

CHANGE-01：本檔及初始快照於 2026-10-12T12:43:01.157003+00:00 建立；尚未進行內容分析。
