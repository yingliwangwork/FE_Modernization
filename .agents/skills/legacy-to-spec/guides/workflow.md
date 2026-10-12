# 單一入口翻新工作流程

本文件規定工作順序、交付位置與續作方式。依賴決策、證據判定及各領域轉寫依各階段連結執行。

## 單行啟動

```text
/legacy-to-spec jsp=sourceCode/AF/AFY10400.jsp
```

`jsp` 是唯一必要輸入，接受相對工作區或絕對路徑；路徑含空白時使用引號。只接受一個存在的 JSP 檔案，不展開萬用字元、目錄或多檔清單。路徑有誤時指出原因並取得正確入口，不自行另選頁面。

自動取得來源版本／位元組雜湊，從相對路徑核對或建立 scope ID，讀取既有 plan、tracking、規格索引及專案設定。未提供 scope、編碼、輸出路徑、後端位置或範本設定，都不要求重貼啟動指令。範本依 [客製化設定](customization.md) 選用；未知的編碼或外部權威如實記錄，不由預設值冒充證據。只有任務需要且工作區無法取得的資訊，才在計劃中列出並詢問。

預設首次呼叫授權建立計劃、依賴盤點與契約適用性核對，完成下列第 1、2 步後，**提供可複選的任務類型選單並等待選擇**。此時不生成行為規格、API 或 prototype；尚未建立的文件列預期路徑與 TODO，不放可點擊的失效連結。若使用者已明確指定類型、TASK 或自動模式，盤點後記錄授權並接續所選工作。再呼叫同一入口時讀取既有選擇與版本，依「驗證與續作」處理，不重建 scope 或反覆要求啟動資訊。

`auto` 為選用參數，**省略即讓使用者選擇類型**，沒有預設自動值。`auto=required` 明確授權執行本 scope 適用的必要任務；`auto=all` 明確授權執行本 scope 已列明的必要及選用任務。兩者都需先建立計劃與盤點，且不授權翻新外部依賴、替使用者決定延後或新增範圍。無法執行的項目保持待決／阻塞；新發現的額外成果不自動納入 `all`。參數值有誤或與明確類型限制衝突時，先澄清執行範圍。

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

核對根入口存在後，先從 plan 範本建立唯一入口、初始納入／排除與依賴盤點任務，再讀來源分析，保留實際先後紀錄。每項任務記錄分類、依賴、影響、完成條件及驗證方式；分析後補上來源版本與詳細影響。

tracking 登錄來源版本／雜湊、編碼、原始行號基準及分析日期。讀取與轉碼依 [來源解析](../references/legacy/jsp-analysis.md)；不可讀時先記錄阻塞。

## 2. 盤點依賴並處理決策

依 [依賴與決策](dependencies.md) 盤點直接及必要間接資源；未指定查找位置時先查工作區的交付目錄、索引及既有紀錄，明列實際搜尋範圍。查找適用契約、核對版本與使用範圍，將結果登錄 plan。不可取得的依賴仍需列出資源、引入位置與影響，不因部分沙盒缺少原始檔就略過。

另一個入口只保留本頁的觸發、傳遞與交接；其內部行為另開 scope。有後端交換或混合責任時，依 [權威分工](../references/api/authority.md) 鎖定後端基準，候選產物見 [後端契約查找](../references/api/backend-profile.md)。

### 任務分類、順序與選擇

任務**類型**描述工作內容，`required／optional` 描述完整交付的必要性，兩者分開記錄。依盤點結果提供下列適用類型；沒有來源依據的類型不建立任務，尚未確認適用性則標示待確認。

| 類型 | 工作內容 |
| --- | --- |
| 行為規格 | 系統行為、狀態、資料與驗收案例定義 |
| 視覺原型 | 畫面與已確認互動的 HTML prototype |
| 元件樣式 | DESIGN.md 與原型實際載入的 CSS 雙份交付 |
| API 消費契約 | 有服務交換時的消費契約與兩端映射 |
| 後端責任移交 | 未承接責任、所需能力與移交缺口 |
| 設計 tokens | 選用 DTCG 的樣式值與映射 |
| 驗證 | 既有或本輪成果的文字、視覺、互動及適用介接驗證 |

建立計劃、初步依賴盤點、選擇紀錄及所選成果的基本核對是共同工作，不另要求使用者勾選。詳細契約、完整原型或額外驗證仍按類型選擇；未選「驗證」不代表可以略過所選成果的基本核對或宣稱已通過完整驗收。

| 分類 | 判定與處理 |
| --- | --- |
| **required** | 本 scope 完整交付所需工作，包括行為規格、必要原型與驗證；有服務交換、未承接責任或元件樣式時，對應 API／移交／樣式雙份交付也是 required。記錄適用條件，尚待確認時不假稱不適用。 |
| **optional** | 不影響已界定範圍完整性的額外成果，例如預設 DESIGN.md／CSS 以外的 DTCG tokens；需指出用途、依賴與額外影響。完成既有產品樣式所需工作不可改列 optional。 |

依前置 TASK、DEP、決策與資料排列建議順序；獨立任務可並列同一順位。另列執行狀態：`可執行／待決／阻塞／執行中／已完成／已延後`。分類與狀態分開，required 被延後仍然是 required，最終只能部分交付。不要用固定流水線掩蓋可並行或需先解決的工作。

在對話先按類型彙整，提供簡短編號供複選，附各類對應 TASK-ID、required／optional、前置條件、影響及可執行狀態，連到 plan 的詳細順位與完成條件。提示可回覆類型名稱、多個編號（如 `1、3`）、個別 `TASK-03`、`只做 required` 或 `全部`；編號以當輪選單為準，不預選任何類型。optional 只要前置條件滿足，也能先執行。未轉換依賴的「先翻新／延後」選擇依 [dependencies](dependencies.md)，可與任務選擇同一輪提出，避免分散追問。

將所選類型解析為當輪已列明的 TASK，或將 `auto`／文字授權解析為對應任務集合，寫入 plan 的 DEC 紀錄與授權來源。選到阻塞任務時說明缺少的前置條件及可先執行的任務，不能自動代選或默認延後。跨類型前置成果若已有適用版本可直接引用；若尚未建立，提供補選前置類型或等待的選項，不因選了原型就自動生成未選的完整規格或樣式成果。未選類型記為「未選」，不冒充已決定延後，也不改成 optional。只執行選定任務及其已授權工作；選根入口工作不代表授權翻新外部依賴。所選部分不受待決依賴影響時可先執行，受影響部分維持待決。完成後更新計劃、實際驗證與下一批可選類型；除非使用者已授權連續執行，不自動包辦其餘任務。

## 3. 形成行為與邊界契約

依 [證據規則](evidence.md) 先盤點事實並分配穩定 ID，再填規格。盤點初始化、條件渲染、元素、事件、資料、分支與副作用，逐項建立來源到契約映射。

以觸發、前置狀態、條件、系統反應、可見結果與後置狀態組織 FLOW；分支只納入有證據者。共用元件的定義與本頁用法依 [UI 規則](../references/ui/writing-rules.md)。混合責任依 [責任拆解](../references/legacy/responsibility-rules.md) 建立 LOGIC 與承接映射；有服務交換時依 [API 轉寫規則](../references/api/writing-rules.md) 建立消費投影。

## 4. 形成視覺成果

依 [UI 規則](../references/ui/writing-rules.md) 以相同契約 ID 建立離線 prototype，並維護規格原型索引。有樣式元件依 [樣式規則](../references/ui/style-spec.md) 同時交付 DESIGN.md 與實際載入的 CSS；選用 DTCG 時另建立 tokens。未知部分保留局部缺口，移除未替換骨架。

## 驗證與續作

依 [驗收規則](acceptance.md) 比對來源、契約、原型與適用後端基準。案例定義留在設計／介接文件；實際操作、結果、截圖與缺陷留在 tracking。摘要列出交付位置、已確認範圍、未解缺口及驗證限制。

續作先讀 plan、tracking 和現有契約，核對來源、後端與共用契約版本是否改變。沿用 ID，回查受影響映射及案例；新證據增補登錄，舊證據保留並標記失效或被取代。刪除行為保留 ID 與刪除依據。

已選任務及依賴決策在其明確範圍內沿用，不因新一輪呼叫而重問；新增依賴、版本漂移或範圍變動時，只補充告知新增影響及所需決策。

TODO 關閉需解決證據、更新的契約 ID、必要驗證結果及變更紀錄。完整性依驗收判定，不以檔案產生或任務完成宣告。
