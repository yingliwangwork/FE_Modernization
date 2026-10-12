---
version: alpha
name: CMP-02 — 共用頁面呈現候選
typography:
  page:
    fontFamily: PMingLiU, MingLiU, Microsoft JhengHei, Meiryo, Arial, Arial Unicode
      MS, Helvetica, sans-serif, Verdana, Trebuchet MS
  textInput:
    fontSize: 12px
---

# CMP-02 樣式規格

## Overview

候選來源完整匹配规则与來源順序；cssBase映射未知。 [CSS](../../styles/CMP-02.css)；[原型](../../prototypes/SCR-01.html)；[tracking](../../../../renovation/sourceCode-AF-AFY10100/tracking.md)。來源E-23，2026-10-12 inventory版本；共同CSS在CMP-01之前載入，訊息窗掛body仍繼承共同字型；CSS全域selector不因審閱工具而縮小。

## Layout

保留10pt表格、line-height21px、padding1pt與text-indent1pt；不將pt换为DTCG dimension。:root .button覆盖padding为0 10px；訊息確定按钮有來源inline左右15px，優先於共用规则。

## Components

| STYLE | selector | property | 值／單位 | 來源／核對 |
| --- | --- | --- | --- | --- |
| STYLE-S-001 | BODY | scrollbar-face-color | #C7E49C | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-002 | BODY | scrollbar-highlight-color | #FFFFFF | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-003 | BODY | scrollbar-3dlight-color | #C7E49C | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-004 | BODY | scrollbar-darkshadow-color | #2B4B21 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-005 | BODY | scrollbar-shadow-color | #96B469 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-006 | BODY | scrollbar-arrow-color | #4F6828 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-007 | BODY | scrollbar-track-color | #C7E49C | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-008 | BODY | font-family | 'PMingLiU', 'MingLiU', 'Microsoft JhengHei', 'Meiryo', 'Arial', 'Arial Unicode MS', 'Helvetica', 'sans-serif', 'Verdana', 'Trebuchet MS' | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-009 | input, textarea | font-family | 'PMingLiU', 'MingLiU', 'Microsoft JhengHei', 'Meiryo', 'Arial', 'Arial Unicode MS', 'Helvetica', 'sans-serif', 'Verdana', 'Trebuchet MS' | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-010 | .textBox2 | font-size | 12px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-011 | .textBox2 | text-decoration | none | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-012 | .textBox2 | letter-spacing | 1pt | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-013 | .textBox2 | border-top | 1px solid #999999 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-014 | .textBox2 | border-right | 1px solid #E1E1E1 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-015 | .textBox2 | border-bottom | 1px solid #E1E1E1 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-016 | .textBox2 | border-left | 1px solid #999999 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-017 | .textDisable | font-size | 12px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-018 | .textDisable | text-decoration | none | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-019 | .textDisable | letter-spacing | 1pt | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-020 | .textDisable | background-color | transparent | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-021 | .textDisable | border | none | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-022 | .button | font-size | 10pt | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-023 | .button | border | 1px solid #6B8D6D | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-024 | .button | color | #006600 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-025 | .button | white-space | nowrap | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-026 | .button | line-height | 19px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-027 | .button | height | 21px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-028 | .button | vertical-align | middle | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-029 | .button | margin | 2px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-030 | .button | padding | 0px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-031 | .button | background | -moz-linear-gradient(top, #eff6ec 0%, #ffffff 40%, #cfe4c1 100%) | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-032 | .button | background | -webkit-linear-gradient(top, #eff6ec 0%,#ffffff 40%,#cfe4c1 100%) | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-033 | .button | background | linear-gradient(to bottom, #eff6ec 0%,#ffffff 40%,#cfe4c1 100%) | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-034 | :root .button, :root .button1, :root .buttonRed | padding | 0px 10px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-035 | .tbBox | border-top-width | 0px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-036 | .tbBox | border-right-width | 1px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-037 | .tbBox | border-bottom-width | 0px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-038 | .tbBox | border-left-width | 1px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-039 | .tbBox | border-top-style | solid | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-040 | .tbBox | border-right-style | solid | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-041 | .tbBox | border-bottom-style | solid | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-042 | .tbBox | border-left-style | solid | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-043 | .tbBox | border-right-color | #6B8D6D | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-044 | .tbBox | border-bottom-color | #6B8D6D | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-045 | .tbBox | border-left-color | #FFFFFF | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-046 | .tbBox | font-size | 10pt | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-047 | .tbBox | background-color | #C7E49C | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-048 | .tbBox2 | background-color | #C7E49C | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-049 | .tbBox2 | border-top-width | 1px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-050 | .tbBox2 | border-right-width | 1px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-051 | .tbBox2 | border-bottom-width | 1px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-052 | .tbBox2 | border-left-width | 1px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-053 | .tbBox2 | border-top-style | solid | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-054 | .tbBox2 | border-right-style | solid | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-055 | .tbBox2 | border-bottom-style | solid | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-056 | .tbBox2 | border-left-style | solid | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-057 | .tbBox2 | border-right-color | #6B8D6D | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-058 | .tbBox2 | border-bottom-color | #6B8D6D | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-059 | .tbBox2 | border-left-color | #FFFFFF | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-060 | .tbBox2 | border-top-color | #FFFFFF | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-061 | .tbBox2 | font-size | 10pt | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-062 | .tbBox2 | text-indent | 1pt | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-063 | .tbBox2 | padding | 1pt | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-064 | .tbBox2 | line-height | 21px | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-065 | .subTitle | font-size | 10pt | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-066 | .subTitle | font-weight | bold | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-067 | .subTitle | color | #339900 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-068 | .subTitle | letter-spacing | 3pt | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-069 | .tbYellow | background-color | #EEF1A7 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-070 | .tbYellow2 | background-color | #FAFBE1 | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-071 | .tbYellow3 | background-color | #FCFDEE | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-072 | .tbBlue | background-color | #99CCFF | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-073 | .tbBlue2 | background-color | #DFEFFF | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-074 | .tbBlue3 | background-color | #F0F8FF | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-075 | input[type=checkbox], input[type=radio] | color | #BBB | E-23；候選映射TODO-02；computed需按最終權重核對 |
| STYLE-S-076 | body | margin | 0px | E-23；候選映射TODO-02；computed需按最終權重核對 |


局部缺口：[TODO-02](../../../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02)（CSS映射／圖片）、[TODO-01](../../../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)（依賴情境／未驗證）。精確CSS即載入版本；STYLE可从對应映射回查，瀏覽器结果仅在tracking维护。tokens不覆蓋所有樣式，pt/%/複合值與公式保留文件/CSS。
