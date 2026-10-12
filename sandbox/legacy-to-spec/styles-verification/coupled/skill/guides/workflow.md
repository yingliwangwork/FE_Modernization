# 單一入口翻新工作方法

## 交付位置與範本

每輪以一個 JSP 檔案為根入口；相依 JSP 是分析依賴，若要翻新其自身行為，另建 scope。scope ID 依相對路徑建立，例如 `CM-login-login`；同名檔案位於不同目錄時不得共用 ID。開始前檢查既有 ID 是否衝突。

先依 [範本客製化](customization.md) 選用並登錄範本，將以下適用範本複製到專案交付目錄，不在 skill 的 templates 中寫入實際業務內容：

| 範本 | 交付位置 | 職責 |
| --- | --- | --- |
| [specification.md](../templates/design/specification.md) | `artifacts/design/<scope-id>/specification.md` | 系統視角的前端行為契約 |
| [prototype.html](../templates/design/prototype.html) | `artifacts/design/<scope-id>/prototypes/<screen-id>.html` | 一份或多份可離線開啟的畫面與已知互動 |
| [DESIGN.md](../templates/design/DESIGN.md) + [component.css](../templates/design/component.css) | `artifacts/design/<scope-id>/components/<CMP-ID>/DESIGN.md` + `styles/<CMP-ID>.css` | 有樣式元件的文件與實際顯示 CSS，同時產出 |
| [tokens.json](../templates/design/tokens.json) | `artifacts/design/<scope-id>/styles/tokens.json` | 選用 DTCG profile 時建立，有證據的可表示值 |
| [plan.md](../templates/renovation/plan.md) | `artifacts/renovation/<scope-id>/plan.md` | 分析前建立的順序、每項任務的依賴與影響、契約查找、依賴決策與後續計劃 |
| [tracking.md](../templates/renovation/tracking.md) | `artifacts/renovation/<scope-id>/tracking.md` | 入口、依賴邊界、證據、覆蓋、TODO、驗證及增量紀錄 |
| [api-spec.md](../templates/integration/api-spec.md) | `artifacts/integration/<scope-id>/api-spec.md` | 有 API 需求時建立；後端契約消費投影與前端映射 |
| [backend-handoff.md](../templates/integration/backend-handoff.md) | `artifacts/integration/<scope-id>/backend-handoff.md` | 有未承接後端責任時建立；有證據的移交需求 |

規格中的追蹤連結由此配置為 `../../renovation/<scope-id>/tracking.md`；追蹤文件的規格連結為 `../../design/<scope-id>/specification.md`。prototype 檔案回到規格使用 `../specification.md`。可依專案慣例改路徑，但所有連結必須同步調整。

規格／追蹤連到介接文件使用 `../../integration/<scope-id>/<file>.md`；介接文件回到規格／追蹤使用 `../../design/<scope-id>/specification.md`、`../../renovation/<scope-id>/tracking.md`。只建立適用文件，其他連結移除並附不適用依據；不建立空殼。

## 輸入、先行計劃與依賴

1. 取得根入口的確切路徑與來源版本。未指定入口且任務是實際翻新時，先請使用者選一個；不要任選業務頁面。只建立範本時不需要實際入口。
   使用者已授權自動化沙盒試用時，可選受控案例或小型真實 JSP 的副本，記錄選定依據與測試限制；沙盒選樣不代表擴大正式翻新範圍。
2. 先建立 plan，登錄唯一入口與初始邊界、依賴盤點任務及完成條件，留下實際建立順序。再在 tracking 記錄版本或內容雜湊、編碼、行號基準、分析日期、現有交付版本。來源不可讀或有亂碼時先記錄阻塞，不從破損文字猜標籤。
3. 明列本輪納入的畫面、分支、共用區塊與邊界互動。列出排除項和理由。若只完成入口的部分分支，範圍仍是單一入口，但交付必須標為部分。
4. 讀 [依賴與決策](dependencies.md)，先盤點外部資源與依賴，在 plan 查找既有技術中立契約並核對版本與適用範圍。已有適用契約直接引用。尚未轉換的資源列出影響與待辦，對話告知使用者並由使用者選先翻新或延後；已有明確決策直接沿用。等待時繼續獨立工作，不生成相依契約。每項任務都記錄依賴、影響範圍、完成條件及驗證方式。
   選先翻新時先完成必要依賴再引用；選延後時在受影響設計位置保留連到 tracking 與 plan 的 TODO，安排後續取得資料、補契約與重新驗證。追查目的、可取得性與停止邊界逐筆登錄；不遍歷整個系統或默默擴大入口。
5. 頁面依賴另一個入口時，只描述本頁觸發、傳遞資料與交接結果；另一頁內部行為留給獨立 scope。必須理解的共用邏輯可作為本輪證據。
6. 有後端交換或耦合責任時，讀 [權威分工](../references/api/authority.md) 與 [後端設計參考](../references/api/backend-profile.md)，指定 `backend_root`、產物與版本。後端 `.github` 供方法／框架語意參考，不以範本冒充 API 原件。未取得基準時保留缺口，其餘前端分析繼續。

## 建立事實到契約的映射

先讀 [證據規則](evidence.md) 和 [來源解析參考](../references/legacy/jsp-analysis.md)。先盤點，再組織規格，避免套用範本反向發明功能。混合責任依 [耦合拆解方法](../references/legacy/responsibility-rules.md) 逐項建立 LOGIC 與承接映射。

- 盤點入口初始化、條件渲染、區塊、欄位、顯示文字、選項、動作、鍵盤事件、導覽、外部呼叫及所有可辨識分支。
- 每項來源事實分配 `E-*`；給可見元素、流程、規則等分配穩定 ID，填入來源到契約覆蓋表。
- 每個觸發建立流程，從前置狀態走到可見結果、後置狀態與邊界副作用。成功、拒絕、取消、失敗等分支只在有證據時加入。
- 多個來源實作同一規則可以合併，但來源覆蓋不能丟失；相似命名不代表相同行為。
- 依前端來源建立共用元件 CMP 與本頁用法，不擴張為整個系統的元件庫分析。
- 對不適用章節寫明檢查範圍、理由與證據；對未知部分只寫缺口及 `TODO-*` 指向。不得用「略」「正常處理」「依需求」「其他邏輯」填滿章節。

## 轉寫介接與移交責任

依 [API 轉寫規則](../references/api/writing-rules.md) 對照 FLOW／BOUND 所需能力與後端產物。已確認操作建立 API 投影，精確傳輸定義只寫在介接文件；前端規格以 ID 引用中立語意。

未承接的 JSP 後端邏輯建立 HANDOFF 和 TODO；不將業務運算搬到 prototype，也不替後端設計端點。前端與目標後端有差距時保留兩端依據，取得承接或變更證據後才更新。

## 建立視覺成果

讀 [視覺契約](../references/ui/writing-rules.md)。依規格的 `SCR-*`、`ST-*`、`UI-*`、`FLOW-*`、`BR-*` 建立 prototype。至少一份 HTML；同一入口有多種畫面或視窗時可拆多份，並列於規格原型索引。

有樣式設計的元件依 [樣式規則](../references/ui/style-spec.md) 同時建立 DESIGN.md 與 prototype 實際載入的 CSS；選用 DTCG 時另建立 tokens。規格樣式索引連到三者，逐筆核對值、條件與證據，結果留在 tracking。

範本本身只有審閱骨架，沒有業務功能。產出的 prototype 必須移除未替換的骨架，依來源重建真實資訊層級與有證據的互動；未知區域僅保留清楚標示的缺口，不填入常見產品設計。

## 驗證與續作

讀 [驗收規則](acceptance.md)，核對來源、文字、prototype 及適用的後端基準與 API 投影。案例定義留在設計／介接文件；執行結果、截圖、缺陷與待辦留在 tracking。

續作先讀 plan、tracking 和現有規格，確認前端、後端基準及共用元件版本是否改變，逐項回查受影響映射。沿用 ID，新證據補入登錄表；舊證據保留並標記失效或被取代。TODO 關閉需填解決證據、更新的規格／畫面／API／HANDOFF ID 和必要驗證結果。刪除的行為也保留其 ID 與刪除依據於追蹤紀錄，不重新編號。

輸出摘要指出交付位置、已確認的範圍、未解缺口與驗證限制。必要契約仍未知、衝突未解或必要驗證未執行時，標示部分成果；不能把「檔案已產生」當作「翻新完整」。
