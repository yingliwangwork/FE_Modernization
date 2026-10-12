# Legacy 前端規格翻新

本專案建立 skills，將 JSP 等 legacy 來源轉為可供 LLM 理解與後續實作的技術中立規格。成果保留有證據的 UI/UX、業務意圖、系統反應與互動流程；無法確認的內容列為具體 TODO，不以推測填補。

目前提供一套可重用 skill 與可客製的交付範本；實際試用結果獨立放在沙盒，尚未產出正式業務翻新交付。設計方法參考使用者提供的 eBAF 後端轉換工具，前端與後端各自維護其責任內的權威。

首次使用可先讀 [操作手冊（Markdown）](docs/legacy-to-spec-manual.md) 或 [離線 HTML 手冊](docs/legacy-to-spec-manual.html)，包含可改填指令、依賴決策、客製設定、輔助命令、驗證及續作方式。

## 範本與 skill

| 文件 | 用途 |
| --- | --- |
| [SKILL.md](skills/legacy-to-spec/SKILL.md) | 翻新哲學、證據原則、範圍與分離原則；不含特定技術、框架或業務細節 |
| [前端系統設計規格](skills/legacy-to-spec/templates/design/specification.md) | 目的、邊界、角色、資料、UI/UX、狀態、規則、被觸發流程、驗收案例及原型索引 |
| [HTML prototype](skills/legacy-to-spec/templates/design/prototype.html) | 可離線開啟的審閱骨架，依來源建立一份或多份真實畫面 |
| [元件 DESIGN.md](skills/legacy-to-spec/templates/design/DESIGN.md) + [CSS](skills/legacy-to-spec/templates/design/component.css) | 有樣式的元件同時產出樣式規格與 prototype 真正載入的 CSS |
| [DTCG tokens](skills/legacy-to-spec/templates/design/tokens.json) | 選用機器可讀的樣式值交換格式，與文件／CSS 共用語意 |
| [翻新計劃](skills/legacy-to-spec/templates/renovation/plan.md) | 分析前建立；每項任務的依賴、影響、完成條件、契約查找、使用者決策及後續順序 |
| [翻新執行與持續追蹤](skills/legacy-to-spec/templates/renovation/tracking.md) | 單一 JSP scope、證據、覆蓋、TODO、驗證執行與增量紀錄 |
| [API 消費規格](skills/legacy-to-spec/templates/integration/api-spec.md) | 有 API 需求時，轉寫指定版本的後端產物與前端雙向映射；不另造端點或 schema |
| [後端責任移交需求](skills/legacy-to-spec/templates/integration/backend-handoff.md) | 有未承接責任時，保留 JSP 後端邏輯的觸發、資料、規則、順序與副作用 |

詳細方法放在 [workflow](skills/legacy-to-spec/guides/workflow.md)、[evidence](skills/legacy-to-spec/guides/evidence.md)、[來源解析](skills/legacy-to-spec/references/legacy/jsp-analysis.md)、[視覺契約](skills/legacy-to-spec/references/ui/writing-rules.md) 與 [驗收規則](skills/legacy-to-spec/guides/acceptance.md)。特定領域知識待實際取得後才建立 reference，並保留權威來源與適用範圍。

前後端介接需讀 [權威分工](skills/legacy-to-spec/references/api/authority.md)、[API 轉寫規則](skills/legacy-to-spec/references/api/writing-rules.md) 與 [JSP 耦合拆解](skills/legacy-to-spec/references/legacy/responsibility-rules.md)。本次參考了哪些後端設計、如何調整及在哪裡探索其產物，記於 [後端設計參考](skills/legacy-to-spec/references/api/backend-profile.md)。

## 範本客製化與樣式

可重用範本統一放在 skill 的 `templates/`，實際成果另存 `artifacts/`。依 [客製化設定](skills/legacy-to-spec/guides/customization.md)，可指定 project template root 或逐角色 override；未覆寫角色使用內建範本，選用檔案與雜湊保留於計劃／追蹤。

UI 預設採 Google Labs DESIGN.md（alpha），可選加上 DTCG 2025.10 tokens。有樣式的元件須同時建立 DESIGN.md 與 prototype 載入的 CSS，記錄樣式值、狀態、來源及映射，並在瀏覽器核對實際樣式；規則見 [UI 樣式規格](skills/legacy-to-spec/references/ui/style-spec.md)。範本客製化不替代既有 API 權威或批准產品設計變更。

## 每輪交付結構

```text
skills/legacy-to-spec/                 # 可版本管理的 skill 原始套件
  SKILL.md                            # YAML name／description 與 Goals 等章節的翻新哲學
  agents/openai.yaml                  # skill 的顯示資訊
  guides/                             # 工作流程、依賴決策、證據、驗收與客製化
  references/api/                     # API 撰寫規則、權威與後端背景
  references/ui/                      # UI／樣式設計與撰寫規則
  references/legacy/                  # JSP 分析與耦合責任拆解
  scripts/source_inventory.py         # 位元組、行數與嚴格解碼證據；不猜編碼
  scripts/select_templates.py         # 客製範本優先序、檔案雜湊與補充規則
  scripts/check_design_metadata.py    # DESIGN token 群組／欄位形狀核對（需 PyYAML）
  templates/design/                   # 規格、原型、DESIGN.md、CSS 與 tokens 範本
  templates/integration/              # API 消費規格與後端移交需求範本
  templates/renovation/                # 計劃與翻新追蹤範本

artifacts/                            # 正式翻新時建立，目前尚無正式業務交付
  design/<scope-id>/
    specification.md                  # 系統契約
    prototypes/<screen-id>.html        # 可有多份
    components/<CMP-ID>/DESIGN.md      # 有樣式的元件；共用定義可引用
    styles/<CMP-ID>.css                # prototype 真正載入的產品樣式
    styles/tokens.json                 # 選用 DTCG 時建立
  integration/<scope-id>/              # 按實際需求建立
    api-spec.md                       # 後端契約消費投影與前端映射
    backend-handoff.md                # 尚未承接的 JSP 後端責任
  renovation/<scope-id>/
    plan.md                           # 先行計劃、依賴／影響與使用者決策
    tracking.md                       # 證據、缺口與執行追蹤

tests/legacy-to-spec/                  # 受控原始材料、獨立瀏覽器案例與檢查工具測試
sandbox/legacy-to-spec/                # 實際 LLM 試用的不可混淆快照、產物與報告
output/playwright/skill-sandbox/       # 真實瀏覽器的畫面截圖
```

設計、介接與翻新追蹤分目錄維護。前端規格保持技術中立；API 文件獨立保留後端已確認的傳輸細節。工作安排、任務依賴、影響與決策留在 plan，來源語法、缺口詳情與驗證執行留在 tracking，驗收預期留在契約文件。

## 權威與 JSP 耦合

| 內容 | 權威 |
| --- | --- |
| 畫面、UI/UX、互動、共用元件及本頁用法 | 前端來源與執行觀察 |
| API method/path、wire 名稱、型別、共通回應、結果碼及業務能力 | 指定版本的 eBAF 後端產物 |
| API 與前端資料／狀態的映射 | 各端在其責任內的證據共同支持 |
| JSP 中尚未被後端承接的邏輯 | JSP 證明舊行為，HANDOFF 保留移交需求；不宣稱目標 API 已存在 |

JSP 的執行位置不決定責任。逐段盤點呈現、業務判斷、資料／外部副作用與受信任情境，核對後端承接，並保留執行順序和資料相依。缺少承接時建立 HANDOFF／TODO，不把後端邏輯搬入前端或以本機假成功掩蓋缺口。

後端工具的 `.github` 是方法與框架參考；真正的 API 權威須來自其交付產物。實際翻新時指定 `backend_root`、契約位置與版本，分清發布、設計和 stub。只有方法規格時不推導 HTTP API，後端資料不足時仍可繼續不依賴它的前端分析。

## 使用方式

此 skill 原始套件放在 `skills/`，尚未安裝到環境的自動探索目錄。可先以明確路徑要求 LLM 讀取並遵循：

```text
請讀取 skills/legacy-to-spec/SKILL.md，依其 references 與範本，
翻新 sourceCode/<確切路徑>/<檔名>.jsp。
本輪只以此 JSP 為根入口。先建立 plan，再盤點外部資源與依賴。
既有適用技術中立契約直接引用；尚未轉換的依賴列出影響並詢問先翻新或延後。
沿用已明確授權的決策；待決時繼續獨立工作，延後時在對應規格位置連結 TODO。
產生技術中立規格、一份或多份 HTML prototype，及分離的翻新追蹤。
有樣式元件同時產出 DESIGN.md 與載入的 CSS；可選 design-md+dtcg profile。
後端專案根目錄：<backend_root>；本輪基準：<產物路徑、版本與適用環境>。
有 API 需求時依後端產物轉寫 api-spec；未承接的 JSP 後端責任另建 handoff。
畫面與共用元件以前端為權威，後端能力與傳輸契約以後端為權威。
未知、未建立或衝突的內容逐項列 TODO，不自行推測。
```

1. 確認唯一 JSP、版本及 scope，先建立 `plan.md`，登錄初始邊界與依賴盤點任務。
2. 盤點外部資源並查找既有契約，核對版本、權威、所需行為及缺口；適用時引用，避免重複翻新。
3. 尚未轉換的依賴納入 plan，對話告知資源與影響，由使用者選先翻新或延後。待決時只繼續獨立工作；既有明確決策不重問。
4. 先翻新時安排依賴順序；延後時在每個受影響的設計位置保留 TODO，連到 tracking 詳情與 plan 的後續任務。
5. 從來源與已選定契約建立規格、prototype、API／移交需求；每項任務記錄依賴、影響與驗證條件。
6. 執行核對，把實際驗證記錄到 tracking；後續沿用 ID、回查依賴版本並維護計劃及 TODO。

依賴查找與兩種處理的詳細規則見 [dependencies](skills/legacy-to-spec/guides/dependencies.md)。plan 管理順序與決策，tracking 保存執行證據；設計規格只描述系統行為及其具體契約缺口。

HTML 範本可直接在瀏覽器開啟。其配置提示與審閱控制不是產品需求，實際生成時須依證據替換；範本未包含任何示範業務流程。

## 交付原則

- 系統流程要能回答：誰觸發、何時觸發、前置狀態、條件與順序、系統反應、可見結果、資料副作用及後置狀態。
- 已知行為逐項引用證據；未知寫明受影響契約與下一個可執行查證動作。未看到不代表不存在，未取得不代表不適用。
- 不預設新的 UX、權限、驗證、後端成功或技術棧。原有缺陷與改良提案分開記錄。
- 每輪以一個 JSP 為單位；另一頁的內部行為另建 scope，跨頁交接仍保留於本頁契約。
- 完整性以本輪範圍的來源覆蓋、契約確認與必要驗證判定。必要內容仍未知或驗證未執行時，交付標為部分。

## 沙盒測試與 skill 修正

依 [沙盒操作說明](tests/legacy-to-spec/README.md) 建立輸入與 skill 快照，交給獨立代理實際翻新，再分別執行結構、來源語意與本地瀏覽器檢查。只依有證據的失敗修正 skill，保留舊產物並以新快照重測，避免只修測試產物。

來源檔案的行數、雜湊與解碼可用 [source_inventory.py](skills/legacy-to-spec/scripts/source_inventory.py) 核對；解碼成功不自動證明實際編碼。

可重跑的測試程式、案例與 fixture 隨工具維護；歷次測試快照、報告、試用產物與截圖分開保存於本地分支 `backup/legacy-to-spec-tests-2026-10-12`。目前分支忽略本地產生的 `sandbox/` 與 `output/playwright/`，原始記錄仍可從備份分支查閱。

可在另一個工作目錄開啟備份：

```sh
git worktree add ../FE_Modernization-test-backup backup/legacy-to-spec-tests-2026-10-12
```

目標目錄需尚未被使用。於備份工作目錄查看 `sandbox/legacy-to-spec/REPORT.md`，可找到來源審查、格式修正、元件 DESIGN.md／CSS、prototype 與瀏覽器報告；截圖在 `output/playwright/`。該分支包含建立備份時的工具與手冊版本。

試用範圍是一個受控耦合案例及真實 `AFY10400.jsp`；每個 scope 只有一個根 JSP。24 項工具測試及 5 組本地瀏覽器樣式情境通過；格式／來源問題已依獨立復核修正，後端與來源執行畫面的缺口仍保留。沙盒成功不代表正式系統翻新已完成。
