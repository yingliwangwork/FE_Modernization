# Legacy to Spec 操作手冊

以單一 JSP 為單位，建立有來源證據的技術中立規格、可審閱原型與獨立翻新紀錄。

**適用套件**：[legacy-to-spec](../.agent/skills/legacy-to-spec/SKILL.md) · **手冊更新日期**：2026-10-12 · **閱讀版本**：[HTML](legacy-to-spec-manual.html)

本手冊依目前專案內的 skill、guides、references 與腳本整理。你只需提供單一 JSP 路徑，由它依 skill 建立計劃，再按你的任務選擇產出；輔助腳本負責來源盤點、範本選用與檢查。規則的維護來源仍是 SKILL.md 及其引用文件。

SKILL.md 定義翻新框架與流程；guides 管理作業，references 提供 API、UI 與來源解析規則，templates 提供可重用交付欄位。逐份文件的職責見 [專案文件索引](../README.md#文件職責)。

## 目錄

- [1. 快速開始](#1-快速開始)
- [2. 自動取得與按需補充的輸入](#2-自動取得與按需補充的輸入)
- [3. 計劃與任務選擇](#3-計劃與任務選擇)
- [4. 外部依賴如何決策](#4-外部依賴如何決策)
- [5. 找到與理解交付文件](#5-找到與理解交付文件)
- [6. 檢視畫面與元件樣式](#6-檢視畫面與元件樣式)
- [7. 客製範本與撰寫規則](#7-客製範本與撰寫規則)
- [8. 輔助工具操作](#8-輔助工具操作)
- [9. 驗證與交付判定](#9-驗證與交付判定)
- [10. 續作與關閉待辦](#10-續作與關閉待辦)
- [11. 沙盒練習](#11-沙盒練習)
- [12. 常見問題與規則索引](#12-常見問題與規則索引)

## 1. 快速開始

在 LLM 可讀取此專案的工作區，選一個 JSP，送出：

```text
/legacy-to-spec jsp=sourceCode/AF/AFY10400.jsp
```

`jsp` 是唯一必要參數。路徑含空白時用引號包住；不要給目錄、萬用字元或多檔清單。

首次啟動會先建立 plan、盤點依賴並查找適用契約，列出 **required／optional** 任務與建議順序，然後等待選擇。此時尚未生成規格或原型。回覆可執行的任務編號即可：

```text
TASK-03
```

任務編號以本輪選單為準。已授權的選擇會被保留，同一 JSP 再次啟動時可續作。

**Codex 使用方式**：本專案 [AGENTS.md](../AGENTS.md) 將 `/legacy-to-spec jsp=...` 文字指令導向 `.agent/skills/legacy-to-spec/`。Codex 原生探索目錄是 `.agents/skills/`，本專案以符號連結指向同一套件；原生明確啟動可用 `$legacy-to-spec jsp=...` 或 `/skills` 選取。自訂 slash 文字入口不代表原生選單已註冊同名命令，依 [官方 skills 文件](https://developers.openai.com/codex/skills)。

## 2. 自動取得與按需補充的輸入

| 資訊 | 流程如何取得 | 無法取得時 |
| --- | --- | --- |
| 唯一入口 | 你提供的 `jsp` 路徑 | 指出錯誤並請提供正確單一檔案，不自行另選 |
| 來源版本／scope ID | 讀取 Git 版本、檔案雜湊與既有交付紀錄 | 使用可核對內容雜湊，不猜測版本或共用 ID |
| 依賴與既有契約 | 分析入口引入位置，查工作區交付目錄、索引及已提供材料 | 明列實際查找範圍、缺失資源、影響與待決事項 |
| 範本與輸出 | 預設內建 templates、`artifacts/` 與 `design-md`；沿用既有設定或自動查看 `config/legacy-to-spec.json` | 沒有設定就使用預設，不要求額外參數 |
| 編碼／執行觀察 | 來源 inventory、已存在且可定位的觀察紀錄 | 嚴格解碼成功不代表編碼已確認；未比較原畫面不宣告視覺等價 |
| 後端權威／補充規則 | 工作區已有設定及已指定版本的產物 | 只有所選任務需要時再請提供；缺少時保留 API／承接缺口 |

**權威分工**：UI／UX、互動與共用元件以前端為依據；API 與業務能力以指定 eBAF 後端產物為依據。後端工具的 `.github` 只提供方法參考。

詳見 [工作流程](../.agent/skills/legacy-to-spec/guides/workflow.md) 與 [權威分工](../.agent/skills/legacy-to-spec/references/api/authority.md)。

## 3. 計劃與任務選擇

| 階段 | LLM 的工作 | 使用者看到的結果 |
| --- | --- | --- |
| 01 建立計劃 | 核對入口，先建立邊界、盤點任務與完成條件 | plan 建立先於來源分析的實際紀錄 |
| 02 盤點依賴 | 分析外部資源、影響，核對可重用契約 | DEP 清單、版本、查找範圍、缺口與停止邊界 |
| 03 提供選單 | 分類 required／optional，排列順位及前置條件 | 可先執行任務、待決依賴、阻塞原因；等待你選擇 |
| 04 執行所選任務 | 只在已選範圍內建立規格、介接或視覺成果 | 有證據的契約與局部 TODO，其他工作仍留在 plan |
| 05 驗證並更新 | 執行所選工作必要核對，記錄結果與限制 | tracking、完成或部分交付狀態、下一批可選項 |

**required** 是本 scope 完整交付所需工作。API、後端移交、元件 DESIGN.md／CSS 依來源需求列為條件式必要工作；尚待確認時不能假稱不適用。必要工作被延後仍是 required，最終只可判定部分交付。

**optional** 是不影響已界定範圍完整性的額外成果，例如另輸出 DTCG tokens。它也有依賴與驗證條件，符合前置條件時可以先執行。

計劃列 TASK-ID、分類、建議順位、前置 TASK／DEP／決策、影響、完成條件與狀態。獨立任務可在同一順位，你可選一項或明確選一組。選到阻塞任務時，流程會說明需要先做什麼，不自動代選、翻新外部資源或延後。

未轉換依賴的先翻新／延後選擇可以與任務選擇一併回答，詳見下一節。只選根入口工作並不授權外部依賴翻新。首次啟動預設就是先看計劃，無需額外追加提示。

## 4. 外部依賴如何決策

### 已有契約先重用

契約必須與來源版本、責任權威、所需行為、條件分支及本頁情境相符。**檔案存在、名稱相同或被標為完成，均不足以證明適用。**只有部分適用時，引用適用部分，其餘保留缺口。

### 尚未轉換時的選項

| 狀態／選擇 | 後續動作 | 保留的紀錄 |
| --- | --- | --- |
| 先翻新 | 在 plan 排必要依賴順序，完成後再引用；不可取得的部分仍列缺口 | 決策來源、授權範圍、依賴任務、完成條件與驗證 |
| 延後 | 在每個受影響位置標 TODO，安排取得材料、補契約與重新驗證 | tracking 的具體缺口與 plan 的後續任務、依賴、順序 |
| 尚未回答 | 保持待決，只做不依賴該決策的工作 | 已告知的資源與影響、待決 DEC；不記錄成同意延後 |

依賴告知至少要有資源位置、查找結果、未確認內容、受影響畫面／流程／資料與可獨立繼續部分。成組決策也要覆蓋該組的全部缺口。

### 回覆範例

以下 `DEP-xx` 與資源範圍必須改成實際對話中已告知的項目。

```text
DEP-xx 先翻新：只建立本頁必要的共用契約，先完成再引用到根入口。
其他未轉換依賴仍待決，不擴大本輪根入口。
若依賴是另一個 JSP 的完整行為，請另建 scope 並留下交接引用。
```

```text
DEP-xx 本輪延後。請在所有受影響的 UI、CMP、FLOW、BOUND、DATA、ST 等位置
保留具體 TODO 連結，tracking 記錄缺失資料與解決條件，
plan 記錄取得材料後的補契約順序及重新驗證任務。
```

可以逐項決定，不必整組採同一策略。選擇先翻新但材料仍不可取得時，該部分仍需等待材料；決策本身不會證明未知行為。

詳見 [依賴與決策](../.agent/skills/legacy-to-spec/guides/dependencies.md)。

## 5. 找到與理解交付文件

可重用範本在 `.agent/skills/legacy-to-spec/templates/`，實際成果另存。以下是預設交付位置；有客製設定時，以本輪選用清單與有效連結為準。

```text
artifacts/
  design/<scope-id>/
    specification.md
    prototypes/<screen-id>.html
    components/<CMP-ID>/DESIGN.md
    styles/<CMP-ID>.css
    styles/tokens.json                  # design-md+dtcg 時建立
  integration/<scope-id>/
    api-spec.md                        # 有 API 消費需求時建立
    backend-handoff.md                 # 有未承接後端責任時建立
  renovation/<scope-id>/
    plan.md
    tracking.md
    template-selection.json            # 範本選用與版本紀錄
```

| 文件 | 讀它可以回答什麼 | 維護責任 |
| --- | --- | --- |
| plan.md | 先做什麼？依賴與影響在哪裡？哪些決策仍待回答？ | 任務、決策與後續順序 |
| tracking.md | 依據在哪裡？哪些缺口未解？實際測過什麼？ | 來源、證據、覆蓋、TODO、執行與歷史 |
| specification.md | 誰在什麼狀態觸發事件？系統如何反應、改變資料與畫面？ | 技術中立行為契約、驗收預期與文件索引 |
| HTML prototype | 已確認的資訊層級、畫面與互動如何呈現？ | 可審閱畫面、已知操作與展示限制 |
| DESIGN.md + CSS | 元件在哪些條件使用哪些樣式？原型實際如何顯示？ | 樣式值、變體、來源及文件／CSS 映射 |
| api-spec.md | 本頁如何消費選定的後端契約？兩端資料與結果如何映射？ | 已確認 wire 契約、映射與介接缺口 |
| backend-handoff.md | JSP 內哪些後端責任尚未被目標承接？ | 已知觸發、規則、順序、受信任資料與副作用 |

JSP 可能混合呈現、資料轉換、業務判斷與儲存責任。LLM 需逐項建立 LOGIC 分類與去向，不能因邏輯寫在 JSP 就搬進前端。缺少目標承接時保留 HANDOFF／TODO，不能自行造端點或以原型計算代替後端。

沒有適用需求的文件可不建立，並記錄不適用的依據；不要以空文件湊齊上述結構。

## 6. 檢視畫面與元件樣式

1. 從規格的 prototype 索引開啟本輪 HTML。實際原型可離線開啟，依索引步驟進入已確認狀態。
2. 核對標籤、選項、順序、初始值、操作條件、訊息與狀態轉移；檢查取消、重複操作、鍵盤、時間關係或拖曳等已證實行為。
3. 有樣式的元件須能沿 CMP 找到 DESIGN.md、CSS 與使用它的 HTML；共用定義可引用已核對的既有版本。
4. 在瀏覽器確認 CSS 實際載入、selector 命中、computed style 與必要幾何／層疊；只比文字內容不足以證明顯示一致。
5. 把觀察環境、操作、實際結果與截圖放進 tracking；驗收預期留在契約文件。

**樣式 profile**：`design-md` 使用本套件指定的 DESIGN.md alpha 格式；`design-md+dtcg` 再輸出 DTCG 2025.10 tokens。DESIGN.md frontmatter 與 DTCG JSON 是不同格式。格式細節以 [樣式規則](../.agent/skills/legacy-to-spec/references/ui/style-spec.md) 為準。

例如來源只證實字型族時，DESIGN.md 的 typography token 要是物件；不為格式完整而添加未確認的字級或行高：

```yaml
typography:
  page:
    fontFamily: "sans-serif"
```

百分比、複合宣告或動態公式需要保留精確語意；無法直接輸出成所選 token 型別時，在 DESIGN.md／CSS 保留並說明未輸出的項目。未取得的樣式、hover、色票與品牌意圖不可自行補造。

審閱工具和合成資料只用來展示已確認的形狀與互動，不是產品需求，也不能證明 API 已有能力。缺少來源執行畫面時，記錄尚未完成的視覺比對。

受控案例的元件文件與原型保存在測試備份分支，查閱方法見第 11 節。備份工作目錄中的 `sandbox/legacy-to-spec/styles-verification/coupled/artifacts/design/fixture-case/` 包含元件 DESIGN.md、CSS 與 prototype。它們是沙盒部分成果，不能用作其他頁面的業務來源。

## 7. 客製範本與撰寫規則

### 直接修改範本

可直接編輯 `.agent/skills/legacy-to-spec/templates/` 中對應的文件骨架；下一輪自動採用，計劃記錄實際檔案與雜湊。生成成果另存 `artifacts/`。修改章節、語言與版面時保留必要證據、映射、缺口及驗證欄位，不需新增啟動參數。

### 只切換樣式 profile

如在專案建立 `config/legacy-to-spec.json`，可先使用下列設定；其中路徑相對於**設定檔所在目錄**，所以 `../artifacts` 會指向專案根的交付目錄。

```json
{
  "style_profile": "design-md+dtcg",
  "output_root": "../artifacts"
}
```

流程會自動查看 `config/legacy-to-spec.json`，同一 scope 沿用已記錄設定；無設定則用內建範本與 `design-md`。使用其他路徑時可在對話中補充，無需長篇啟動提示。

### 加入專案範本與規則

以下是配置範例。先準備實際檔案，再填設定；不使用的項目應移除，避免引用不存在的路徑。

```json
{
  "template_root": "../project-templates",
  "overrides": {
    "api-spec": "../project-templates/integration/api-consumption.md"
  },
  "references": {
    "api": ["../project-rules/api-writing.md"],
    "ui": ["../project-rules/ui-writing.md"],
    "domain": []
  },
  "style_profile": "design-md+dtcg",
  "output_root": "../artifacts"
}
```

選用優先序：**逐角色 override → project template root 同相對路徑 → 內建範本**。

| 角色 | template root 下的相對路徑 |
| --- | --- |
| specification | design/specification.md |
| prototype | design/prototype.html |
| component-design | design/DESIGN.md |
| component-css | design/component.css |
| tokens | design/tokens.json |
| api-spec | integration/api-spec.md |
| backend-handoff | integration/backend-handoff.md |
| plan | renovation/plan.md |
| tracking | renovation/tracking.md |

指定的 override 或 template root 不存在會報設定錯誤；已存在的 custom root 只缺部分角色時，該角色可 fallback 到內建範本。

可以調整章節、語言、版面與路徑，但必須保留必要資訊、穩定 ID、證據與缺口連結。補充 API／UI／domain 文件是撰寫規則，不能取代後端產物或前端來源的事實；提供風格指南不代表批准改變原系統設計。

詳見 [客製化規則](../.agent/skills/legacy-to-spec/guides/customization.md)。

## 8. 輔助工具操作

以下命令從**專案根目錄**執行。路徑有空白時加引號；範例只展示工具的檢查能力，不表示已正式翻新某個業務頁面。先建立本輪 plan，再進行來源盤點。工具輸出需由 LLM 登錄到本輪追蹤文件。

### 來源雜湊、物理行與解碼核對

這個可執行範例讀取倉庫的合成 JSP，不修改來源：

```sh
python3 .agent/skills/legacy-to-spec/scripts/source_inventory.py \
  tests/legacy-to-spec/fixtures/coupled/frontend/Case.jsp \
  --candidate utf-8 --candidate cp950
```

實際翻新時改成根入口與本輪必要依賴的確切檔案。輸出包含 SHA-256、位元組數、物理行、行尾與 strict decoding 結果。**成功解碼不代表已確認預期編碼**；引用末行不能超過原始物理行數。

### 範本選用

```sh
python3 .agent/skills/legacy-to-spec/scripts/select_templates.py
```

若有第 7 節設定檔：

```sh
python3 .agent/skills/legacy-to-spec/scripts/select_templates.py \
  --config config/legacy-to-spec.json
```

輸出選用理由、實際檔案、SHA-256、補充 references 與 output root；它不生成規格，也不驗證範本必要資訊已完整。保留本輪清單，例如 renovation scope 的 `template-selection.json`，並從 plan／tracking 引用；設定變動時保留舊版。

### DESIGN.md metadata 形狀檢查

先將下一段的引號內路徑換成已產出的元件 DESIGN.md，再執行。此工具需 Python 環境已提供 PyYAML；缺少時會明確回報未執行，不自動安裝。

```sh
python3 .agent/skills/legacy-to-spec/scripts/check_design_metadata.py \
  "artifacts/design/<scope-id>/components/<CMP-ID>/DESIGN.md"
```

實際翻新時改成自己的元件路徑。檢查範圍是 name、token 群組形狀與 typography 欄位；**不等於完整官方 DESIGN.md／DTCG validator**，也不驗證來源忠實度或瀏覽器顯示。

## 9. 驗證與交付判定

| 核對層次 | 實際操作 | 紀錄位置與限制 |
| --- | --- | --- |
| 來源與文字 | 回查原始來源、條件分支、資料與副作用；反查每個主張的 E 證據 | tracking 覆蓋表；未知依賴不能省略以提高完成率 |
| 文件關係 | 核對 ID、錨點、版本、TODO 局部位置與 plan 後續任務 | tracking；只有缺口總索引不夠 |
| 介接與移交 | 對照後端指定基準、wire 契約、兩端映射及未承接 LOGIC | api-spec／handoff 描述契約；tracking 管進度與驗證 |
| 畫面與樣式 | 開原型，測已知狀態、操作、動態樣式與 CSS 實際效果 | tracking V 記錄實測與截圖；未比較來源畫面不宣告像素等價 |
| 驗收案例 | 使用 AC 明列的前置資料、事件與具體預期執行核對 | 預期在設計／介接，實際結果在 tracking；mock 通過不代表正式服務通過 |

交付前可逐項確認：

- [ ] 唯一根入口、來源版本、邊界與排除理由明確。
- [ ] plan 先建立，每項任務有 required／optional、順位、狀態、依賴、影響及完成條件，選擇有紀錄。
- [ ] 適用契約已核對後引用；未轉換資源有決策或明確待決。
- [ ] 所有已辨識的事件與已知分支都有契約去向，沒有推測行為。
- [ ] 每個受影響位置的 TODO 能連到 tracking，tracking 能連回 plan。
- [ ] prototype、樣式文件與實際載入 CSS 一致，使用的示例資料已標示。
- [ ] 必要 API 投影以後端為權威，未承接責任有 HANDOFF／TODO。
- [ ] 驗證結果反映實際執行，未執行的部分有具體理由與後續動作。

**完整交付**需要範圍內必要契約已確認、矛盾已解、覆蓋無缺口，且必要驗證完成。其餘情況標為**部分交付**，列出受影響內容與下一步；檔案齊全、測試通過數或 TODO 數歸零不能單獨證明完整。

完整準則見 [驗收規則](../.agent/skills/legacy-to-spec/guides/acceptance.md)。

## 10. 續作與關閉待辦

先讀既有 plan、tracking 與契約，確認來源、後端基準、共用元件及範本版本是否改變。沿用穩定 ID，保留失效／被取代的證據與先前驗證，不重新編號。

### 可直接改填的續作指令

```text
/legacy-to-spec jsp=<同一個 JSP 路徑>
續作既有 scope：<scope-id>，執行 <本輪可選 TASK-ID>。
先讀 artifacts/renovation/<scope-id>/plan.md、tracking.md 與既有設計／介接文件。
本輪處理的 TODO：<已存在的 TODO-ID 清單>。
新材料與版本：<確切來源路徑、後端承接產物或確認紀錄>。

先更新 plan，記錄此次任務的依賴、影響及完成條件。
核對新舊版本；保留既有 ID、決策與證據歷史，只更新有新依據的契約。
同步更新受影響的規格、API／HANDOFF、DESIGN.md、CSS 及 prototype。
依影響重新驗證，將實際結果記入 tracking。
只有解決證據、契約更新及必要驗證均足夠時才關閉 TODO；其他缺口保持開啟。
```

| TODO 關閉條件 | 要留下的依據 |
| --- | --- |
| 未知內容已取得 | 新證據 E、權威、適用版本與實際解決範圍 |
| 相依契約已承接 | 契約引用、版本、前後端映射與有證據的責任去向 |
| 文件與原型已更新 | 受影響 FLOW／UI／ST／API／HANDOFF／STYLE 等 ID |
| 必要驗證已完成 | 實際 V 結果與 CHANGE 歷史；仍未驗證部分分開保留 |

共用契約變動時回查消費它的其他 scope；只更新本輪授權範圍，新的影響或依賴決策需另記錄。

## 11. 沙盒練習

沙盒適合練習依賴決策、驗證 skill 或比較不同版本的產物。它會複製輸入與 skill 快照並保留 SHA-256；準備腳本不產生設計規格。

### 準備受控案例

```sh
python3 scripts/skill-sandbox.py prepare \
  --case coupled --run manual-practice-01
```

run ID 只能使用小寫英數與連字號；已存在時改用新的 ID，腳本不覆蓋舊試用。預設 `ask` 沒有預先同意依賴翻新或延後。

| dependency-policy | 沙盒用意 |
| --- | --- |
| ask | 測試未預先決策的告知與待決行為；預設值 |
| defer | 明示模擬：引用適用契約，其他依賴延後 |
| convert-available | 明示模擬：先轉必要可取得依賴，不可取得者延後 |

`defer`／`convert-available` 必須在 prepare 命令明確加入 `--dependency-policy`。這些是**沙盒模擬決策**，不代表正式業務翻新的範圍擴張或延後授權。

### 交給 LLM 實際操作

```text
請在 sandbox/legacy-to-spec/manual-practice-01/coupled 內工作。
先讀 task.txt、manifest.json 與 skill/SKILL.md，按提供快照完成本輪任務。
不要修改 inputs、skill 或 manifest；交付寫入 artifacts。
遵守 task 的依賴政策，不查詢外部系統、不執行後端。
記錄實際驗證與限制，待決依賴只繼續獨立工作。
```

### 檢查交付

完成適用交付後再執行：

```sh
python3 scripts/skill-sandbox.py check \
  --case-dir sandbox/legacy-to-spec/manual-practice-01/coupled
```

此 checker 僅適用倉庫的 sandbox case，檢查快照、必要文件、ID、連結、佔位符與部分腳本語法。新版 manifest 明列 plan／delivery 階段；plan 只要求計劃與追蹤，並拒絕尚未選任務就生成設計成果。舊 manifest 保留原有全交付檢查語意。結構通過不等於任務分類、依賴影響或來源語意均已正確。

只有已產出 prototype 的 delivery 階段才需要瀏覽器檢查；本地瀏覽器觀察需要 Node.js、可用的 Playwright 模組與瀏覽器；將下一個命令的模組路徑替換為當前環境已存在的入口，再執行：

```sh
SKILL_SANDBOX_PLAYWRIGHT="<本機 playwright-core 模組入口>" \
  node scripts/skill-sandbox-browser.mjs \
  sandbox/legacy-to-spec/manual-practice-01/coupled
```

沒有 scenario 檔時產生 DOM／控制項觀察與截圖；依來源建立可觀察案例後，可將 scenario JSON 作為第二個參數另跑操作驗證。腳本使用獨立 context 並阻擋 HTTP。瀏覽器無法啟動時如實記錄未執行，保留其他已完成核對。

最後另做來源審查，將來源語意、結構與瀏覽器結果分開判定。保留原產物和失敗，再用新快照重測；有既有審查意見的修補應標為審查引導續作。

詳見 [沙盒操作說明](../tests/legacy-to-spec/README.md)。

### 查閱既有測試備份

歷次測試記錄保存於本地分支 `backup/legacy-to-spec-tests-2026-10-12`，可另開工作目錄讀取：

```sh
git worktree add ../FE_Modernization-test-backup backup/legacy-to-spec-tests-2026-10-12
```

目標目錄需尚未被使用。在該目錄開啟 `sandbox/legacy-to-spec/REPORT.md` 查看試用紀錄，或開啟 `output/playwright/` 下的截圖及手冊瀏覽器檢查報告。備份分支含其建立時的工具版本；目前工作分支保留可重跑的測試程式與 fixture，新的本地記錄由 `.gitignore` 排除。

## 12. 常見問題與規則索引

| 問題 | 處理方式 |
| --- | --- |
| LLM 找不到 skill | 提供 `.agent/skills/legacy-to-spec/SKILL.md` 的確切路徑，要求讀取及遵循，再核對其能存取的工作區 |
| JSP 有亂碼或 codec 結果不一致 | 先登錄原始 bytes、hash、行號與 strict 解碼限制，取得正確來源；不從 replacement 字元猜文案 |
| 依賴有來源，但沒有中立契約 | 先登錄查找結果、缺口與影響，由使用者決定；有來源不自動授權翻新 |
| 後端只有方法規格 | 可作已知責任的依據，但不能直接推導 HTTP 操作；API 缺口保留，前端獨立部分繼續 |
| 客製設定報檔案不存在 | 回查相對於設定檔的路徑；刪除未使用項或補上實際檔案，不把指定 override 失效當 fallback |
| DESIGN.md 檢查通過，但 CSS 不符合畫面 | 回查載入、selector、cascade、繼承與動態狀態；metadata 檢查不包含瀏覽器效果 |
| 原型有合成成功畫面 | 核對是否只展示已證實的資料形狀與反應；未知後端成功不能由替身填補 |
| 文件齊全但仍標為部分 | 檢查必要契約與驗證缺口；依證據補齊後再更新判定，不只改狀態文字 |

| SKILL 編號 | 主題 |
| --- | --- |
| R1 | 證據先於描述 |
| R2 | 保留意圖與體驗 |
| R3 | 權威依責任分配 |
| R4 | 耦合必須拆責任 |
| R5 | 以觸發與結果組織契約 |
| R6 | 先計劃，再沿依賴推進 |
| R7 | 小範圍累積 |
| R8 | 契約與執行分離 |
| R9 | 完整性必須能被檢查 |

SKILL.md 的 **E1–E3 是原則示例**；交付文件的 **E-* 是來源證據**，兩者用途不同。其他常用 ID：DEP（依賴）、TASK（任務）、DEC（決策）、TODO（缺口）、AC（驗收預期）、V（驗證執行）、CHANGE（變更）。完整 ID 定義見 [證據規則](../.agent/skills/legacy-to-spec/guides/evidence.md)。

Markdown 與 HTML 是同一份手冊的兩種閱讀形式；維護時同步更新。HTML 正文、樣式與互動可離線使用，專案來源連結需保留 `docs/` 與倉庫的相對目錄結構。
