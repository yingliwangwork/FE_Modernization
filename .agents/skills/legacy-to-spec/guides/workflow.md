# 工作流程

**職責**：定義順序、模式、任務授權、案件狀態、輸出分類與續作。證據判定見 [evidence](./evidence.md)，完成條件見 [acceptance](./acceptance.md)。

## 單行啟動

```text
legacy-to-spec jsp=sourceCode/<entry>.jsp
legacy-to-spec jsp=sourceCode/<entry>.jsp auto=required
legacy-to-spec jsp=sourceCode/<entry>.jsp auto=all
```

| 模式 | 第一版後的動作 | 原型處理 |
| --- | --- | --- |
| **預設** | 回報狀態與待辦，等待使用者選擇 TASK | 列為 optional，選定後執行 |
| **`auto=required`** | 相容的規格任務選擇模式；回報後等待選擇，**不自動補齊全部規格** | 不列原型任務、不建立原型 |
| **`auto=all`** | 回報相同里程碑後，直接執行同一 scope 全部可執行任務 | 包含高保真原型及驗證，仍依賴完整規格審閱 |

- **第一版必要**：各模式均先產出並檢查第一版，不停在計劃；既有合格第一版可核對版本後重用。
- **只交第一版**：明確如此要求時，完成第一版、狀態及待辦回報後結束，不詢問續作。
- **既有授權**：第一版及回報後沿用，不重問；選定任務包含同一 scope 的必要前置與驗證。
- **入口受阻**：輸入無效、來源不可讀或範圍衝突時回報原因，不建立成功形狀的占位成果。
- **範圍限制**：所有模式都不授權獨立翻新其他入口或自行裁決未知業務行為。

## 建立計劃與來源基線

1. **鎖定來源**：記錄相對路徑、編碼、版本／SHA-256 與行號基準；依 [JSP 解析](../references/legacy/jsp-analysis.md) 盤點。
2. **沿用 scope**：同一入口沿用既有 `<scope>`，例如 `sourceCode-AF-AFY10100`；scope 不含路徑跳脫。
3. **建立 planning**：記錄目標、邊界、排除項、模式、適用產出、任務、授權與風險。
4. **建立 evidence**：保留來源盤點、解碼判定、證據／依賴／缺口索引及模板 manifest。
5. **盤點影響**：追查直接及相關間接依賴，記錄受影響契約、已查範圍、停止邊界及不可取得項。
6. **核對既有文件**：依 [依賴規則](./dependencies.md) 重用適用版本；缺文件先開 TODO，不要求所有依賴完成翻新。

### 任務欄位

| 欄位 | 必填內容 |
| --- | --- |
| **TASK／名稱** | 穩定 ID 與具體動作 |
| **階段／類型** | spec／prototype；查證、依賴缺文件、文件補齊、原型或驗證 |
| **必要性** | required／optional；適用性與理由 |
| **產出** | 實際文件路徑或待取得來源；未建立者明列待建立 |
| **前置／影響** | 前置 TASK、相關 DEP／TODO、受影響契約 |
| **驗收條件** | 可檢查的解決條件，引用對應驗收規則 |
| **授權** | 待選／使用者選定／必要前置／auto=all；確認來源 |
| **狀態** | pending／in_progress／blocked／done／not-selected |

- **另外記錄**：生效 instruction、模板與技術棧版本，依 [客製化規則](./customization.md)。
- **必要不等於已授權**：required 表示完整規格需要該工作；第一版後仍依模式及選擇執行。
- **未選不等於受阻**：待選任務為 pending；未選的 optional 任務可記 not-selected；已授權但缺證據的任務記 blocked。

## 第一階段：形成與審閱規格

| 順序 | 動作 | 產出／前置 |
| --- | --- | --- |
| **1. 選模板** | 執行 `--phase spec`，先載入 UI spec 模板 | manifest 列四個 role 不表示須同時產出四份文件 |
| **2. 形成第一版** | 用穩定 ID、結構化契約、證據及局部 TODO 描述已知 UI 與行為 | `history/draft/<revision>/spec/ui-spec.md` |
| **3. 檢查並回報** | 執行 [第一版檢查](./acceptance.md#第一階段第一版交付檢查)，進入下節選擇關卡 | review、案件狀態及剩餘 TASK |
| **4. 執行後續任務** | 按已選或 auto=all 授權補齊適用 PRD、UI/API spec、BDD 及查證 | 依真實任務依賴，不要求後續文件全部串行 |
| **5. 回補與審閱** | 回補受影響契約，核對跨文件映射 | 依 [缺口回補](./dependencies.md#取得證據後回補) 保存解決依據 |
| **6. 完整交付** | 通過 [完整規格關卡](./acceptance.md#第一階段完整規格完成關卡) 才提升 | deliverables；記版本與 SHA-256，重算連結 |

- **適用必要文件**：PRD 包含 User Story 與 Use Case；UI spec 包含 UI／行為／資料／樣式；API spec 包含交換契約及 HANDOFF；BDD 包含有證據的可觀察情境。
- **不適用需證據**：不把未取得當成不適用，不用 optional 消除必要工作。
- **部分交付**：缺少必要契約、適用文件或驗證時交付 draft 及待辦，不提升為完整規格。

## 案件狀態與任務選擇關卡

**先提供實際文件，再請使用者選擇。** 更新 `history/planning/plan.md` 後回報：

| 回報項目 | 必含內容 |
| --- | --- |
| **案件** | scope、入口、模式、案件狀態、規格完整性 |
| **已完成** | 第一版路徑／版本、檢查結果及已完成 TASK |
| **剩餘待辦** | TASK ID、名稱、required／optional、前置、產出、影響、可執行性及阻塞原因 |
| **缺口** | 未解 TODO、待取得證據／裁決、解決條件及是否涉及另一入口 |
| **續作方式** | 預設等待 TASK ID／名稱選擇；auto=all 記錄整批授權後直接執行 |

- **展開前置**：使用者選定任務時，列出同範圍必要前置及驗證，記錄授權後執行，不重問。
- **選原型**：第一版後可選原型，執行須先補齊適用規格及審閱；auto=required 模式只列規格任務。
- **無剩餘任務**：如實回報，不詢問空的任務選擇。
- **auto=all 受阻**：保留待查證或裁決 TODO，繼續其他可執行任務，最後回報限制，不宣告全部成功。

### 案件狀態與規格完整性

| 案件狀態 | 意義 |
| --- | --- |
| **`in_progress`** | 正在產出第一版或執行已授權任務 |
| **`awaiting_selection`** | 第一版已交付，等待後續選擇 |
| **`blocked`** | 已授權剩餘任務均需外部證據或決策，無法繼續 |
| **`partial`** | 本輪可執行／已選任務已處理，但必要規格或驗證仍缺少 |
| **`complete`** | 必要規格及驗證全部通過，已選原型也通過；未選原型不阻塞結案 |

- **完整性另記**：`first_draft`／`partial`／`complete` 與實際版本。
- **第一版完成不等於結案**：只完成選定的部分任務不代表完整規格完成。
- **狀態留 planning**：不放進系統行為契約；每輪結束更新已完成、剩餘與阻塞。

## 第二階段：根據規格產出原型

1. **核對啟動關卡**：依 [原型啟動驗收](./acceptance.md#第二階段原型啟動關卡) 核對授權、完整規格基線及必要缺口。
2. **讀取 instruction**：選模板及建檔前確認技術棧，依 [客製化規則](./customization.md#單位-instruction-指定技術棧) 記錄；未指定時使用 HTML + CSS + JavaScript。
3. **實作高保真原型**：依 [UI 規則](../references/ui/writing-rules.md) 與 [樣式契約](../references/ui/style-spec.md) 還原已確認視覺、狀態與互動。
4. **查證差異**：來源只供查證；矛盾先開缺口、修訂並審閱規格，再調整原型。
5. **驗證與交付**：通過 [原型完成關卡](./acceptance.md#第二階段原型完成關卡) 才提升；未選原型不建立空目錄或資產。

## 輸出分類與相對連結

預設根為 `artifacts`；客製 `output_root` 只替換根，不改變分類。

| 類型 | 相對於 scope 的路徑 | 內容 |
| --- | --- | --- |
| **planning** | `history/planning/plan.md` | 任務、授權、案件狀態、決策與變更 |
| **draft** | `history/draft/<revision>/` | 第一版、部分規格與原型工作版本 |
| **review** | `history/review/<revision>/` | 審閱、結果、截圖、log 與限制 |
| **evidence** | `history/evidence/` | 來源／依賴／缺口／責任索引、雜湊與 manifest |
| **spec** | `deliverables/spec/ui-spec.md`、適用 `api-spec.md` | 通過完整驗收的 UI／API 契約 |
| **prd** | `deliverables/prd/prd.md` | 通過完整驗收的 User Story 與 Use Case |
| **bdd** | `deliverables/bdd/behavior.feature` | 通過審閱的行為情境；不宣稱已執行測試 |
| **prototype** | `deliverables/prototype/` | 選用且驗收通過的實作資產與使用說明 |

- **有效連結**：只連已存在文件，未建立寫待建立；提升草稿後重算相對連結。
- **連結例**：最終 UI spec 到 evidence 為 `../../history/evidence/evidence.md#e-001`；到 PRD 為 `../prd/prd.md`。
- **舊結構**：design／integration／renovation 文件只當可核對來源；記錄遷移範圍並取得授權才搬移，不自動刪除、復原或認作已審閱基線。

## 驗證與續作

- **沿用基線**：讀取同一 scope 的 planning、evidence、review，沿用 ID、模式、任務選擇及 instruction。
- **保留歷史**：版本變動時保存被取代證據與決策，回查受影響依賴、契約、案例與原型，只重驗受影響範圍。
- **沿用授權**：已選任務及前置不重問；未選工作依選擇關卡處理，新增入口或業務變更需明確依據。
- **據實回報**：依 [完成宣告](./acceptance.md#驗證紀錄與完成宣告) 區分預期、實測、未執行與限制。
