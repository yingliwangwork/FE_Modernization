# 單一入口翻新工作流程

本文件規定工作順序、交付位置與續作方式。依賴決策、證據判定及各領域轉寫依各階段連結執行。

## 交付位置與範本

每輪以一個 JSP 為根入口。scope ID 依相對路徑建立；同名但不同目錄不得共用 ID，開始前檢查既有 ID。依 [客製化設定](customization.md) 選用範本，實際成果另存於以下位置：

| 範本 | 交付位置 | 維護內容 |
| --- | --- | --- |
| [specification.md](../templates/design/specification.md) | `artifacts/design/<scope>/specification.md` | 前端系統行為契約及驗收案例定義 |
| [prototype.html](../templates/design/prototype.html) | `artifacts/design/<scope>/prototypes/<SCR-ID>.html` | 一份或多份畫面及已知互動 |
| [DESIGN.md](../templates/design/DESIGN.md) + [component.css](../templates/design/component.css) | `artifacts/design/<scope>/components/<CMP-ID>/DESIGN.md` + `styles/<CMP-ID>.css` | 元件樣式規格及原型實際載入的樣式 |
| [tokens.json](../templates/design/tokens.json) | `artifacts/design/<scope>/styles/tokens.json` | 選用 DTCG 時的樣式值 |
| [api-spec.md](../templates/integration/api-spec.md) | `artifacts/integration/<scope>/api-spec.md` | API 消費契約與兩端映射；有需求才建立 |
| [backend-handoff.md](../templates/integration/backend-handoff.md) | `artifacts/integration/<scope>/backend-handoff.md` | 未承接的後端責任；有缺口才建立 |
| [plan.md](../templates/renovation/plan.md) | `artifacts/renovation/<scope>/plan.md` | 任務順序、依賴、影響、查找、決策及後續計劃 |
| [tracking.md](../templates/renovation/tracking.md) | `artifacts/renovation/<scope>/tracking.md` | 來源、證據、覆蓋、TODO 詳情、驗證結果與歷史 |

設計／追蹤連到介接文件使用 `../../integration/<scope>/<file>.md`；介接文件回到設計／追蹤使用 `../../design/<scope>/specification.md`、`../../renovation/<scope>/tracking.md`。prototype 回到規格使用 `../specification.md`。自訂路徑時同步調整連結；不適用文件移除連結並附依據。

## 1. 先建立計劃

取得確切根入口與版本；未指定正式入口時先請使用者選一個。建立 plan，登錄唯一入口、初始納入／排除、依賴盤點任務與完成條件，再讀來源分析，保留實際先後紀錄。每項任務記錄依賴、影響、完成條件及驗證方式。

tracking 登錄來源版本／雜湊、編碼、原始行號基準及分析日期。讀取與轉碼依 [來源解析](../references/legacy/jsp-analysis.md)；不可讀時先記錄阻塞。

## 2. 盤點依賴並處理決策

依 [依賴與決策](dependencies.md) 盤點直接及必要間接資源，查找適用契約、核對版本與使用範圍，將結果登錄 plan。未轉換資源依該規則告知使用者並記錄決策；待決時繼續獨立工作。

另一個入口只保留本頁的觸發、傳遞與交接；其內部行為另開 scope。有後端交換或混合責任時，依 [權威分工](../references/api/authority.md) 鎖定後端基準，候選產物見 [後端契約查找](../references/api/backend-profile.md)。

## 3. 形成行為與邊界契約

依 [證據規則](evidence.md) 先盤點事實並分配穩定 ID，再填規格。盤點初始化、條件渲染、元素、事件、資料、分支與副作用，逐項建立來源到契約映射。

以觸發、前置狀態、條件、系統反應、可見結果與後置狀態組織 FLOW；分支只納入有證據者。共用元件的定義與本頁用法依 [UI 規則](../references/ui/writing-rules.md)。混合責任依 [責任拆解](../references/legacy/responsibility-rules.md) 建立 LOGIC 與承接映射；有服務交換時依 [API 轉寫規則](../references/api/writing-rules.md) 建立消費投影。

## 4. 形成視覺成果

依 [UI 規則](../references/ui/writing-rules.md) 以相同契約 ID 建立離線 prototype，並維護規格原型索引。有樣式元件依 [樣式規則](../references/ui/style-spec.md) 同時交付 DESIGN.md 與實際載入的 CSS；選用 DTCG 時另建立 tokens。未知部分保留局部缺口，移除未替換骨架。

## 驗證與續作

依 [驗收規則](acceptance.md) 比對來源、契約、原型與適用後端基準。案例定義留在設計／介接文件；實際操作、結果、截圖與缺陷留在 tracking。摘要列出交付位置、已確認範圍、未解缺口及驗證限制。

續作先讀 plan、tracking 和現有契約，核對來源、後端與共用契約版本是否改變。沿用 ID，回查受影響映射及案例；新證據增補登錄，舊證據保留並標記失效或被取代。刪除行為保留 ID 與刪除依據。

TODO 關閉需解決證據、更新的契約 ID、必要驗證結果及變更紀錄。完整性依驗收判定，不以檔案產生或任務完成宣告。
