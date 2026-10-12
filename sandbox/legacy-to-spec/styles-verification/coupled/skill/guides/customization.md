# 範本選用與客製化

`templates/` 只存可重用範本；實際文件另存於 `artifacts/` 的 scope。客製化可以改章節、語言、版面與交付路徑，不能刪除必要資訊、降低證據要求，或覆寫前後端的權威分工。

## 選用方式

沒有設定時使用 skill 內建範本。可在專案建立 JSON 設定（路徑相對於設定檔）：

```json
{
  "template_root": "./project-templates",
  "overrides": {"api-spec": "./contracts/api-consumption.md"},
  "references": {"api": [], "ui": [], "domain": []},
  "style_profile": "design-md",
  "output_root": "./artifacts"
}
```

每個角色依序選：`overrides` 的確切檔案 → `template_root` 下相同相對路徑 → 內建範本。指定的 override 不存在是設定錯誤，不能默默 fallback；custom root 只缺某個角色時可 fallback。未指定 custom root 不需建立空目錄。

| override 角色 | template root 下的相對路徑 |
| --- | --- |
| `specification`／`prototype` | `design/specification.md`／`design/prototype.html` |
| `component-design`／`component-css`／`tokens` | `design/DESIGN.md`／`design/component.css`／`design/tokens.json` |
| `api-spec`／`backend-handoff` | `integration/api-spec.md`／`integration/backend-handoff.md` |
| `plan`／`tracking` | `renovation/plan.md`／`renovation/tracking.md` |

執行 `python3 <skill>/scripts/select_templates.py --config <設定檔>`，將輸出的選用清單另存於本輪 renovation scope。無設定時省略 `--config`。輸出含各角色的實際路徑、選用理由、SHA-256、補充 references 與輸出根目錄；計劃引用此清單，追蹤記錄實際採用的角色。只複製適用角色，不因清單列出就建立空 API 或移交文件。設定改變時保留前一版清單。

`style_profile` 可選 `design-md`（預設）或 `design-md+dtcg`；兩者都要求有樣式的元件同時交付 DESIGN.md 與 prototype CSS，後者另交付 DTCG tokens。樣式細節見 [UI 樣式規則](../references/ui/style-spec.md)。

## 必要資訊與權威

客製範本使用前，比對 [驗收規則](acceptance.md) 與相應撰寫規則；缺漏必要欄位時補入或停止該角色生成，指出缺漏，不將客製化當作豁免。

- 設計：範圍、資料、畫面／元件、狀態、觸發流程及已知分支、驗收、證據／缺口、原型索引。
- 計劃／追蹤：單一入口、實際先後、任務依賴與影響、契約查找及使用者決策、來源版本、覆蓋、TODO 位置、實際驗證與歷史。
- API／移交：後端基準、前端所需能力、雙向映射、已知 wire 契約、未承接責任與缺口；不可由客製範本補造後端。
- 樣式：元件及變體、樣式值、適用條件、證據／核准變更、DESIGN.md 與 CSS 映射及瀏覽器核對。

設定中的 references 是補充規則，不是 API 或業務事實本身。API 規則仍服從指定 eBAF 後端產物，UI 規則以前端來源及有紀錄的設計變更為依據；領域文件需有可定位的權威與適用範圍。規則衝突時保留衝突及 TODO。提供範本或風格指南本身不表示批准改變原系統的樣式／互動；需先核對已有授權或取得明確決策。
