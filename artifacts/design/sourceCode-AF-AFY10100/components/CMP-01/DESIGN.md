---
version: alpha
name: "CMP-01 — 公會通報查詢根頁明示呈現"
colors:
  page: "#F0FBC6"
  frame: "#003366"
  surface: "#FFFFFF"
---

# CMP-01 樣式規格

## Overview

適用 sourceCode-AF-AFY10100／SCR-01／ST-01–02。僅從根 JSP 明示樣式與 HTML 呈現屬性轉寫；不代表完整共用 CSS。來源 E-01、E-08–15，版本與 bytes 雜湊見 [tracking](../../../../renovation/sourceCode-AF-AFY10100/tracking.md)。[CSS](../../styles/CMP-01.css) 由 [prototype](../../prototypes/SCR-01.html) 實際載入。候選字型與class樣式已於CMP-02投影；实际映射、圖片及執行環境仍有缺口：[TODO-02](../../../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02)。

格式依 [DESIGN.md alpha](https://github.com/google-labs-code/design.md/blob/main/docs/spec.md)，2026-10-12 核對；本頁部分已知值不擴張為完整品牌設計系統。未取得的 typography／rounded 不編造，未標 omitted 為不存在。

## Colors

背景 #F0FBC6、外框表格 #003366、內容面 #FFFFFF 是根頁明示值。排序呼叫傳遞 #F0F8FF／#FAFBE1，但 helper 未取得契約，在原型按E-24動態套用行底色，但cell背景可遮蓋；不宣稱像素等價。

## Typography

[TODO-02](../../../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02)：候選共用字型、大小、行高與class級聯見CMP-02；实际cssBase映射未確認。根標題點使用原始 font size=-5；其他文字不任造字型階級。

## Layout

保留原生表格的 width、height、cellspacing、cellpadding、rowspan、colspan、input size（包括空屬性）及只讀／禁用。大框 97%，表格常用100%，標題4px／5px裝飾欄和30px占位保留；圖片本身未取得不重製。精确每个屬性見原型與 E-08–15。每個 inline style 及背景／對齊移至以下 CSS 映射；原生表格屬性未換算成新尺度。

## Elevation & Depth

標題絕對定位 left:0、初始 top:0、width:100%、z-index:9、visibility:visible。FLOW-10 動態 top = body scrollTop − 標題 offsetHeight + 30 px；實際幾何驗證尚需記錄。編輯區初始 display:none，選列 block，取消 none。

## Components

| STYLE | selector | property | 規範值／CSS 宣告 | 證據／適用條件／computed 檢查 |
| --- | --- | --- | --- | --- |
| STYLE-01 | body | background-color | #F0FBC6 | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-02 | body | margin | 0 | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-003 | .root-style-001 | position | absolute | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-004 | .root-style-001 | left | 0 | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-005 | .root-style-001 | top | 0 | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-006 | .root-style-001 | width | 100% | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-007 | .root-style-001 | z-index | 9 | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-008 | .root-style-001 | visibility | visible | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-009 | .root-style-002 | background-color | #F0FBC6 | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-010 | .root-style-003 | vertical-align | top | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-011 | .root-style-004 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-012 | .root-style-005 | text-align | right | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-013 | .root-style-006 | background-color | #F0FBC6 | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-014 | .root-style-007 | vertical-align | top | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-015 | .root-style-008 | vertical-align | top | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-016 | .root-style-009 | background-color | #003366 | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-017 | .root-style-010 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-018 | .root-style-011 | background-color | #FFFFFF | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-019 | .root-style-012 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-020 | .root-style-013 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-021 | .root-style-014 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-022 | .root-style-015 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-023 | .root-style-016 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-024 | .root-style-017 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-025 | .root-style-018 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-026 | .root-style-019 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-027 | .root-style-020 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-028 | .root-style-021 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-029 | .root-style-022 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-030 | .root-style-023 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-031 | .root-style-024 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-032 | .root-style-025 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-033 | .root-style-026 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-034 | .root-style-027 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-035 | .root-style-028 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-036 | .root-style-029 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-037 | .root-style-030 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-038 | .root-style-031 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-039 | .root-style-032 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-040 | .root-style-033 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-041 | .root-style-034 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-042 | .root-style-035 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-043 | .root-style-036 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-044 | .root-style-037 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-045 | .root-style-038 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-046 | .root-style-039 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-047 | .root-style-040 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-048 | .root-style-041 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-049 | .root-style-042 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-050 | .root-style-043 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-051 | .root-style-044 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-052 | .root-style-045 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-053 | .root-style-046 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-054 | .root-style-047 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-055 | .root-style-048 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-056 | .root-style-049 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-057 | .root-style-050 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-058 | .root-style-051 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-059 | .root-style-052 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-060 | .root-style-053 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-061 | .root-style-054 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-062 | .root-style-055 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-063 | .root-style-056 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-064 | .root-style-057 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-065 | .root-style-058 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-066 | .root-style-059 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-067 | .root-style-060 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-068 | .root-style-061 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-069 | .root-style-062 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-070 | .root-style-063 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-071 | .root-style-064 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-072 | .root-style-065 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-073 | .root-style-066 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-074 | .root-style-067 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-075 | .root-style-068 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-076 | .root-style-069 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-077 | .root-style-070 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-078 | .root-style-071 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-079 | .root-style-072 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-080 | .root-style-073 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-081 | .root-style-074 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-082 | .root-style-075 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-083 | .root-style-076 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-084 | .root-style-077 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-085 | .root-style-078 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-086 | .root-style-079 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-087 | .root-style-080 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-088 | .root-style-081 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-089 | .root-style-082 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-090 | .root-style-083 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-091 | .root-style-084 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-092 | .root-style-085 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-093 | .root-style-086 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-094 | .root-style-087 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-095 | .root-style-088 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-096 | .root-style-089 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-097 | .root-style-090 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-098 | .root-style-091 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-099 | .root-style-092 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-100 | .root-style-093 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-101 | .root-style-094 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-102 | .root-style-095 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-103 | .root-style-096 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-104 | .root-style-097 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-105 | .root-style-098 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-106 | .root-style-099 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-107 | .root-style-100 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-108 | .root-style-101 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-109 | .root-style-102 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-110 | .root-style-103 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-111 | .root-style-104 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-112 | .root-style-105 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-113 | .root-style-106 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-114 | .root-style-107 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-115 | .root-style-108 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-116 | .root-style-109 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-117 | .root-style-110 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-118 | .root-style-111 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-119 | .root-style-112 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-120 | .root-style-113 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-121 | .root-style-114 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-122 | .root-style-115 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-123 | .root-style-116 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-124 | .root-style-117 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-125 | .root-style-118 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-126 | .root-style-119 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-127 | .root-style-120 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-128 | .root-style-121 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-129 | .root-style-122 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-130 | .root-style-123 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-131 | .root-style-124 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-132 | .root-style-125 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-133 | .root-style-126 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-134 | .root-style-127 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-135 | .root-style-128 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-136 | .root-style-129 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-137 | .root-style-130 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-138 | .root-style-131 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-139 | .root-style-132 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-140 | .root-style-133 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-141 | .root-style-134 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-142 | .root-style-135 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-143 | .root-style-136 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-144 | .root-style-137 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-145 | .root-style-138 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-146 | .root-style-139 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-147 | .root-style-140 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-148 | .root-style-141 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-149 | .root-style-142 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-150 | .root-style-143 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-151 | .root-style-144 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-152 | .root-style-145 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-153 | .root-style-146 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-154 | .root-style-147 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-155 | .root-style-148 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-156 | .root-style-149 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-157 | .root-style-150 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-158 | .root-style-151 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-159 | .root-style-152 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-160 | .root-style-153 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-161 | .root-style-154 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-162 | .root-style-155 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-163 | .root-style-156 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-164 | .root-style-157 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-165 | .root-style-158 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-166 | .root-style-159 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-167 | .root-style-160 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-168 | .root-style-161 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-169 | .root-style-162 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-170 | .root-style-163 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-171 | .root-style-164 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-172 | .root-style-165 | display | none | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-173 | .root-style-166 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-174 | .root-style-167 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-175 | .root-style-168 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-176 | .root-style-169 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-177 | .root-style-170 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-178 | .root-style-171 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-179 | .root-style-172 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-180 | .root-style-173 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-181 | .root-style-174 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-182 | .root-style-175 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-183 | .root-style-176 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-184 | .root-style-177 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-185 | .root-style-178 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-186 | .root-style-179 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-187 | .root-style-180 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-188 | .root-style-181 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-189 | .root-style-182 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-190 | .root-style-183 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-191 | .root-style-184 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-192 | .root-style-185 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-193 | .root-style-186 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-194 | .root-style-187 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-195 | .root-style-188 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-196 | .root-style-189 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-197 | .root-style-190 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-198 | .root-style-191 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-199 | .root-style-192 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-200 | .root-style-193 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-201 | .root-style-194 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-202 | .root-style-195 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-203 | .root-style-196 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-204 | .root-style-197 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-205 | .root-style-198 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-206 | .root-style-199 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-207 | .root-style-200 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-208 | .root-style-201 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-209 | .root-style-202 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-210 | .root-style-203 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-211 | .root-style-204 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-212 | .root-style-205 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-213 | .root-style-206 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-214 | .root-style-207 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-215 | .root-style-208 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-216 | .root-style-209 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-217 | .root-style-210 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-218 | .root-style-211 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-219 | .root-style-212 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-220 | .root-style-213 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-221 | .root-style-214 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-222 | .root-style-215 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-223 | .root-style-216 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-224 | .root-style-217 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-225 | .root-style-218 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-226 | .root-style-219 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-227 | .root-style-220 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-228 | .root-style-221 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-229 | .root-style-222 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-230 | .root-style-223 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-231 | .root-style-224 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-232 | .root-style-225 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-233 | .root-style-226 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-234 | .root-style-227 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-235 | .root-style-228 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-236 | .root-style-229 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-237 | .root-style-230 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-238 | .root-style-231 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-239 | .root-style-232 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-240 | .root-style-233 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-241 | .root-style-234 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-242 | .root-style-235 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-243 | .root-style-236 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-244 | .root-style-237 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-245 | .root-style-238 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-246 | .root-style-239 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-247 | .root-style-240 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-248 | .root-style-241 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-249 | .root-style-242 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-250 | .root-style-243 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-251 | .root-style-244 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-252 | .root-style-245 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-253 | .root-style-246 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-254 | .root-style-247 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-255 | .root-style-248 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-256 | .root-style-249 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-257 | .root-style-250 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-258 | .root-style-251 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-259 | .root-style-252 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-260 | .root-style-253 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-261 | .root-style-254 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-262 | .root-style-255 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-263 | .root-style-256 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-264 | .root-style-257 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-265 | .root-style-258 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-266 | .root-style-259 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-267 | .root-style-260 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-268 | .root-style-261 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-269 | .root-style-262 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-270 | .root-style-263 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-271 | .root-style-264 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-272 | .root-style-265 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-273 | .root-style-266 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-274 | .root-style-267 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-275 | .root-style-268 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-276 | .root-style-269 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-277 | .root-style-270 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-278 | .root-style-271 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-279 | .root-style-272 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-280 | .root-style-273 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-281 | .root-style-274 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-282 | .root-style-275 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-283 | .root-style-276 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-284 | .root-style-277 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-285 | .root-style-278 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-286 | .root-style-279 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-287 | .root-style-280 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-288 | .root-style-281 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-289 | .root-style-282 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-290 | .root-style-283 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-291 | .root-style-284 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-292 | .root-style-285 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-293 | .root-style-286 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-294 | .root-style-287 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-295 | .root-style-288 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-296 | .root-style-289 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-297 | .root-style-290 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-298 | .root-style-291 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-299 | .root-style-292 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-300 | .root-style-293 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-301 | .root-style-294 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-302 | .root-style-295 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-303 | .root-style-296 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-304 | .root-style-297 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-305 | .root-style-298 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-306 | .root-style-299 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-307 | .root-style-300 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-308 | .root-style-301 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-309 | .root-style-302 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-310 | .root-style-303 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-311 | .root-style-304 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-312 | .root-style-305 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-313 | .root-style-306 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-314 | .root-style-307 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-315 | .root-style-308 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-316 | .root-style-309 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-317 | .root-style-310 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-318 | .root-style-311 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-319 | .root-style-312 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-320 | .root-style-313 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-321 | .root-style-314 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-322 | .root-style-315 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-323 | .root-style-316 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-324 | .root-style-317 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-325 | .root-style-318 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-326 | .root-style-319 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-327 | .root-style-320 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-328 | .root-style-321 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-329 | .root-style-322 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-330 | .root-style-323 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-331 | .root-style-324 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-332 | .root-style-325 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-333 | .root-style-326 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-334 | .root-style-327 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-335 | .root-style-328 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-336 | .root-style-329 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-337 | .root-style-330 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-338 | .root-style-331 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-339 | .root-style-332 | text-align | center | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-340 | .root-style-333 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-341 | .root-style-334 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-342 | .root-style-335 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-343 | .root-style-336 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-344 | .root-style-337 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-345 | .root-style-338 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-346 | .root-style-339 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |
| STYLE-347 | .root-style-340 | text-align | left | E-01／E-08–15；根頁明示值；開啟原型檢查命中 selector，實測在 tracking；共用繼承 TODO-02 |


STYLE-DYNAMIC-01：#bar1/top 初始0、載入／resize／scroll 後依 FLOW-10 公式；STYLE-DYNAMIC-02：#editArea/display none→block→none，原型 script 實際操作。百分比與動態公式不投影 DTCG dimension。

## Do's and Don'ts

保留根頁有證據的順序、尺寸和顯示條件；不以缺失的 CSS 或圖片猜品牌、hover、focus 或響應式斷點。未知共用呈現保留 TODO-02。
