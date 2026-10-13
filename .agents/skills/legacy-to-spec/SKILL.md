---
name: legacy-to-spec
description: '將單一既有入口轉為 AI 可理解、有證據的規格；用於既有系統規格萃取、legacy to spec、user story、use case。必先交付可含可追蹤 TODO 的第一版，再列案件狀態與待辦供使用者選擇；auto=all 自動完成範圍內規格、審閱及供使用者對照的高保真原型。'
argument-hint: 'jsp=<入口 JSP 路徑> auto=<required | all>'
---

# Legacy to Spec

## 目標與使用對象

| 產物 | 主要使用者 | 目的 |
| --- | --- | --- |
| **第一版與完整規格** | AI | 以穩定 ID、結構化欄位、明確條件及證據，支援解析、驗證與續作 |
| **高保真 prototype** | 使用者 | 對照已確認的畫面、文字、視覺、狀態及互動 |
| **案件歷程** | AI 與使用者 | 追蹤來源、任務選擇、案件狀態、缺口及檢查結果 |

## 核心規則

- **唯一入口**：每輪處理一個 JSP；可讀取相關依賴以查證本入口，獨立翻新其他入口需另有授權。
- **第一版先行**：盤點依賴與影響、核對既有文件後，必先產出第一版；缺少依賴文件不阻塞已知契約的描述。
- **證據先行**：不以名稱、慣例或經驗補造行為、意圖、服務能力或未知結果；保留局部 TODO 與已知條件分支。
- **保留體驗**：保留資訊層級、順序、限制、生命週期、時間關係、回饋及副作用；缺陷、改良提案與已確認變更分開記錄。
- **權威分工**：前端來源負責 UI 與共用呈現；後端產物負責服務與業務契約。跨邊界映射需兩端依據，執行位置不等於責任歸屬。
- **選擇關卡**：第一版後列案件狀態及剩餘任務；預設等待使用者選擇，`auto=all` 回報後直接執行。已有明確任務授權不重問。
- **原型關卡**：原型須有選用授權，且依賴完整規格審閱；高保真不能成為補造未知契約的理由。
- **歷程分離**：草稿、證據、計劃與檢查留在 `history/`；通過完整驗收的產物才放入 `deliverables/`。

## 執行摘要

1. **建立基線**：鎖定入口、版本與 scope，盤點依賴及影響，重用適用文件。
2. **產出第一版**：形成 AI 可理解的 UI 與行為規格；未知內容使用可追蹤 TODO。
3. **回報並選擇**：提供第一版連結、案件狀態、已完成項目及剩餘 TASK；依模式等待選擇或直接續作。
4. **補齊並審閱**：執行已授權任務及必要前置，補齊適用 PRD、UI/API spec、BDD；API spec 內保留 HANDOFF。
5. **選配高保真原型**：依已審閱規格實作並驗證；預設 HTML + CSS + JavaScript，適用 instruction 可指定技術棧。
6. **交付並更新狀態**：依實際驗收結果回報完整／部分交付、未解缺口及剩餘任務。

**模式、授權與狀態定義**以 [工作流程](./guides/workflow.md) 為準；**完成判定**以 [驗收規則](./guides/acceptance.md) 為準。

## 文件職責與讀取時機

| 文件 | 主要職責 | 何時讀取 |
| --- | --- | --- |
| **本文件** | 目標、核心約束與閱讀入口 | 啟動 skill |
| [workflow](./guides/workflow.md) | 順序、模式、任務選擇、案件狀態及輸出分類 | 啟動與續作 |
| [evidence](./guides/evidence.md) | 主張分類、證據登錄、中立語意及穩定 ID | 分析及轉寫契約 |
| [dependencies](./guides/dependencies.md) | 依賴適用性、局部 TODO 及缺口回補 | 盤點依賴或遇到缺口 |
| [acceptance](./guides/acceptance.md) | 第一版、完整規格與原型的檢查條件 | 審閱及交付 |
| [customization](./guides/customization.md) | 模板填寫、選取、設定及 instruction 技術棧 | 選模板及實作原型 |
| [JSP 解析](./references/legacy/jsp-analysis.md) | 語法、事件、時間及生命週期觀察點 | 解析 legacy 來源 |
| [責任拆解](./references/legacy/responsibility-rules.md) | 混合邏輯的責任分配與 HANDOFF 內容 | 發現前後端耦合 |
| [API authority](./references/api/authority.md) | 各類主張的權威與版本衝突判定 | 核對基準及兩端映射 |
| [backend profile](./references/api/backend-profile.md) | 後端產物與自訂工具的查找位置 | 查找後端證據 |
| [API writing rules](./references/api/writing-rules.md) | API 消費契約與 wire 轉寫 | 形成 API spec |
| [UI writing rules](./references/ui/writing-rules.md) | AI 可讀 UI 契約與高保真原型映射 | 形成 UI spec 或原型 |
| [style spec](./references/ui/style-spec.md) | STYLE 契約、樣式來源及實作映射 | 解析視覺或實作樣式 |
| [spec 模板](./templates/spec) | PRD、UI/API、BDD 的欄位骨架 | 產出適用規格 |
| [prototype 模板](./templates/prototype) | 原型實作骨架 | 原型關卡通過後 |
| [openai.yaml](./agents/openai.yaml) | UI 顯示資訊與啟動提示 | skill 被列出或啟動時 |
| [source_inventory](./scripts/source_inventory.py) | 原始 bytes、雜湊、行數及候選解碼結果 | 來源盤點 |
| [select_templates](./scripts/select_templates.py) | 模板路徑、版本與設定 manifest | 選模板；不代替授權或驗收 |

**維護原則**：詳細規則只在責任文件維護，其他文件以連結引用。模板只定義產物內容，不重述執行流程或案件狀態。
