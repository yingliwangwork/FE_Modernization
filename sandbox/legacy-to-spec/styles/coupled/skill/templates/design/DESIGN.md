---
version: alpha
name: "{{CMP-ID}} — {{已確認的元件名稱}}"
---

# {{CMP-ID}} 樣式規格

> 範本未設定任何產品樣式。依來源填入適用 frontmatter tokens；無依據的群組省略並說明缺口。不從文案、角色或元件名稱推測品牌意圖。

## Overview

{{元件呈現責任、適用 scope／UI／ST、前端來源版本與 E-ID；有批准變更時另列決策。}}

{{連結到本元件 CSS、使用它的 prototype 及 tracking；共用定義則指定契約版本與適用範圍。}}

## Colors

{{已確認的色彩值與用途及 E-ID；尚未取得連到 TODO；無此節資訊時刪除此節並在 Overview 說明。}}

## Typography

{{已确认的字型、尺寸、行高與继承条件；不新增字型階級。}}

## Layout

{{精確間距、對齊、寬高、單位、相對位置與動態公式；缺口指向 TODO。}}

## Elevation & Depth

{{已知邊框、陰影、遮罩、層級與重疊條件；不補造陰影。}}

## Shapes

{{已知形狀／圓角與值；不補造尺度。}}

## Components

### {{CMP-ID}}／{{有證據的變體}}

| STYLE ID | 適用元件／UI／ST、條件 | DESIGN token 路徑或正文規則 | 規範值與單位 | CSS 檔案／selector／property／宣告值 | 證據／核准變更／缺口 | prototype 與檢查步驟／預期 computed style |
| --- | --- | --- | --- | --- | --- | --- |
| {{STYLE-ID}} | {{明確條件，不新增 hover 等狀態}} | {{token path 或本節規則}} | {{精確值、繼承或公式}} | {{CSS 連結及精確位置，不能僅寫「對應 CSS」}} | {{E-ID／決策／TODO 連結}} | {{HTML 連結、可重現狀態及預期值；實測結果另存 tracking}} |

{{tokens.json 選用時列本元件 token 映射；無法表示的項目、保留的 CSS 及原因逐項說明。}}

## Do's and Don'ts

{{只列有來源／批准決策的元件使用約束；不填一般美學建議。}}
