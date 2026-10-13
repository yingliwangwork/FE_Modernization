# API 契約轉寫規則

**職責**：把後端權威契約轉為本入口的 API 消費投影，並保留未承接需求。欄位骨架見 [API 模板](../../templates/spec/api-spec.md)，版本權威見 [authority](./authority.md)。

## 契約性質

| 分類 | 描述方式 |
| --- | --- |
| **已存在交換** | 原件內容、權威來源及適用版本 |
| **已確認設計** | 目標承諾與版本，不宣稱部署完成 |
| **未承接需求** | HANDOFF 與局部 TODO，不指定虛構操作 |
| **展示替身** | Mock／stub 性質明示，不當實際服務能力 |

**前端需求只能證明需要什麼**；後端提供什麼須另有依據。產物查找依 [backend profile](./backend-profile.md)。

## 邊界映射

- **雙向追溯**：FLOW／BOUND ↔ API／HANDOFF ↔ DATA／TR／ST／BR／MSG，以及 PRD／BDD 的 AC。
- **兩端依據**：每個映射記前後端 E-ID 與版本；只知單端時保留缺口。
- **完整邊界**：核對 hidden、session、cookie、callback、重導、檔案及批次，不只 AJAX。
- **操作與需求**：每個跨邊界流程有操作或缺口，每個 API 有已知使用情境。

## Wire 契約

| 契約面向 | 轉寫要求 |
| --- | --- |
| **操作與傳輸** | 保留 operation、HTTP method、path、media type、header、認證與授權；未知不推定 REST／JSON |
| **欄位與型別** | request／response 使用原件 wire 名稱及傳輸型別；可另附業務語意，不為中立而改名 |
| **值與邊界** | 分開 missing、null、空字串、零、false、缺省；記必填、限制、格式、編碼、精度、時區、列舉及順序 |
| **資料形狀** | 保留巢狀、分頁、排序、識別碼、重複值、檔案／串流及 envelope；不統一改成成功回應 |
| **可信情境** | 記合法提供者及服務端保證；client 驗證不能當後端授權或業務保證 |
| **順序與副作用** | 保留交易、併發、重試、冪等、取消、逾時及副作用；未知不新增可靠性保證 |

## 結果與未承接責任

- **各分支保留**：條件、資料、狀態、訊息、交接及後續動作分別描述；錯誤、空資料、未完成不混為成功。
- **傳輸不等於業務**：HTTP 成功不能代替業務結果；未知回應不自創 fallback。
- **內容不重複**：UI spec 負責呈現／流程，API spec 負責 wire／消費映射；不複製 DOM、建置步驟或 mock 程式。
- **HANDOFF 內容**：依 [責任拆解](../legacy/responsibility-rules.md) 定義需求、輸入輸出、順序、條件、副作用及 AC，保留在同一 API spec。
- **不適用需證據**：未取得後端通常是缺口；可證實無交換與待承接責任才列不適用。

**缺口與驗證**：TODO 格式與回補依 [dependencies](../../guides/dependencies.md)；真實檢查與完成判定依 [acceptance](../../guides/acceptance.md)，不在 API 契約混入排程或 log。
