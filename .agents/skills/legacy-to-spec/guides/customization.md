# 模板與技術棧客製化

**職責**：定義模板填寫、選取、設定及 instruction 技術棧。任務順序與授權依 [workflow](./workflow.md)，驗收依 [acceptance](./acceptance.md)。

## 兩類模板

| 階段 | role | 內建模板 | 完整驗收後的產出 |
| --- | --- | --- | --- |
| **spec** | `ui-spec` | [ui-spec.md](../templates/spec/ui-spec.md) | `deliverables/spec/ui-spec.md` |
| **spec** | `api-spec` | [api-spec.md](../templates/spec/api-spec.md) | `deliverables/spec/api-spec.md`，適用時 |
| **spec** | `prd` | [prd.md](../templates/spec/prd.md) | `deliverables/prd/prd.md` |
| **spec** | `bdd` | [bdd.feature](../templates/spec/bdd.feature) | `deliverables/bdd/behavior.feature` |
| **prototype** | `prototype` | [prototype.html](../templates/prototype/prototype.html) | `deliverables/prototype/` 的實際入口 |
| **prototype** | `prototype-css` | [prototype.css](../templates/prototype/prototype.css) | 選定技術棧的樣式資產 |
| **prototype** | `prototype-js` | [prototype.js](../templates/prototype/prototype.js) | 選定技術棧的互動資產 |

- **第一版沿用 ui-spec**：不新增第一版模板或文件類型；草稿與最終位置由 workflow 定義。
- **歷程不用產物模板**：planning、review、evidence 各依責任指南記錄。
- **內容歸併**：HANDOFF 在 API spec，STYLE 在 UI spec；不另維護 backend-handoff、DESIGN 或 tokens 模板。
- **骨架不等於產品**：原型資產只供實作起點，不能當作產品配色、佈局或高保真完成依據。

## 模板填寫規則

- **移除提示**：產出時刪除「模板填寫提示」及不適用示例列，保留真正契約內容。
- **一般占位符**：`{{...}}` 必須替換；無依據且影響契約時轉為 [具體 TODO](./dependencies.md#局部-todo-與缺口索引)。
- **未知與不適用**：未知用可追蹤標記；不適用寫理由與 E-ID，不用空白代表不存在。
- **穩定欄位**：保持契約、證據、缺口及 AC 欄位；客製版面不能刪除可驗證內容。
- **關聯文件**：只連已建立文件；其他適用文件標待建立，進度與任務留 planning。
- **BDD 特例**：只對已知前置、觸發及結果建立英文關鍵字 scenario；未知留註解／限制與 TODO 引用，不放入 executable steps。
- **原型特例**：所有產品 ID、文字、資料與互動取自已審閱規格；移除 scaffold 提示，審閱工具與產品 UI 分離。

## 選取與版本

```sh
python3 .agents/skills/legacy-to-spec/scripts/select_templates.py --phase spec
python3 .agents/skills/legacy-to-spec/scripts/select_templates.py --phase prototype --config /path/to/template-config.json
```

**工具職責**：只解析路徑、設定與雜湊，不建立交付文件，不決定任務選擇、授權或驗收。

| 選取規則 | 行為 |
| --- | --- |
| **階段** | 預設 spec，只選四個 spec role；prototype 只選原型 role |
| **優先序** | 明確 `overrides` → `template_root` 同相對路徑 → 內建模板 |
| **明確覆寫缺檔** | 報錯，不回退 |
| **一般客製根缺檔** | 可回退內建並揭露限制；非預設技術棧另依下節規則 |
| **無效設定** | 未知 role／欄位、無效路徑與已移除 `style_profile` 明確報錯 |
| **相對路徑** | 以設定檔位置為基準 |

### 設定範例

```json
{
  "output_root": "artifacts",
  "template_root": "./unit-templates",
  "overrides": {
    "ui-spec": "./unit-templates/spec/ui-spec.md"
  },
  "references": {
    "api": [],
    "ui": [],
    "domain": []
  }
}
```

- **設定位置**：由單位自行管理；output_root 只替換產出根，不改變 history／deliverables 分類。
- **參考資料**：只採用本輪適用規則；設定中列出不代表業務能力已取得證據。
- **變更追溯**：設定或模板改版後回查受影響契約與驗收。

### Manifest schema version 2

| 欄位 | 內容 |
| --- | --- |
| **phase／config** | 階段、設定路徑及設定 SHA-256 |
| **templates** | 各 role 的 `path`、`origin`、`sha256` |
| **references** | 適用 reference 的路徑與雜湊 |
| **limits** | 回退與限制 |
| **output_root／output_layout** | scope 根與歷程／產物分類 |
| **prototype_stack** | 只在 prototype 階段出現 |

- **保存位置**：`history/evidence/`，不當成 spec 成品。
- **舊 schema**：`selected_by` 改為 `origin`，style profile 不再輸出；舊 manifest 不能當成新設定沿用。

## 單位 instruction 指定技術棧

**預設**：HTML + CSS + JavaScript，可離線開啟；不因 repository 有 Angular／React 就自行切換框架。

1. **主動讀取**：在第二階段選模板或建檔前讀適用 instruction，不等檔案生成後才匹配 applyTo。
2. **核對指示**：依正常優先序處理全域、工作區及更細範圍指示；未能解決的衝突需確認，不自行猜測。
3. **記錄基線**：planning 記 instruction 路徑、SHA-256、適用範圍、選定棧與啟動方式。
4. **映射設定**：將決議轉成 `prototype_stack` 及相容模板設定，再執行 selector；selector 不自動查找 instruction。

### Instruction 範例

單位可自行建立 `.github/instructions/prototype.instructions.md`；本 skill 不自動建立此檔。

```markdown
---
description: '此單位的 legacy-to-spec prototype 使用 React；只適用原型階段。'
applyTo: 'artifacts/**/deliverables/prototype/**,artifacts/**/history/draft/**/prototype/**'
---

# Prototype 技術棧

- 使用 React 與工作區既有建置／啟動方式。
- 依已審閱規格實作，使用本單位模板及共用元件。
- 不呼叫真實服務；mock 與展示工具不構成新需求。
```

- **其他棧**：Angular 等沿用相同方式，指定其工具鏈與模板。
- **客製根**：output_root 改變時，單位須調整 applyTo 路徑模式。

### 非預設棧的模板

```json
{
  "prototype_stack": "react-typescript",
  "overrides": {
    "prototype": "./custom/Screen.tsx",
    "prototype-css": "./custom/screen.css"
  }
}
```

| 規則 | 非預設棧行為 |
| --- | --- |
| **入口** | 必須提供客製 prototype；overrides 不限制副檔名 |
| **CSS／JS role** | 選擇性，僅選明確提供資產，不回退 vanilla 內建資產 |
| **canonical slot** | 可放 `prototype/prototype.html`、`.css`、`.js`；入口必須存在，其他有提供才選 |
| **輸出名稱** | 符合實際框架結構，不強迫名為 prototype.html／css／js |
| **驗證方式** | 使用說明記啟動及驗證；檢查真實框架入口，不用 HTML 代理替代 |

**不可覆寫核心契約**：客製模板及技術棧須遵守 [SKILL.md](../SKILL.md) 的證據、單一入口、規格先行與歷程分離規則；技術棧設定不代表原型已獲授權。
