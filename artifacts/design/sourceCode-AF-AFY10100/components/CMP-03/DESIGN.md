---
version: alpha
name: CMP-03 — 遮罩與訊息視窗
colors:
  window: '#0066CC'
  content: '#FFFFFF'
  footer: '#EEEEEE'
typography:
  message:
    fontFamily: Verdana, Arial, sans-serif, 微軟正黑體
---

# CMP-03 樣式規格

## Overview

MsgWin静态样式外置；动态尺寸/位置/显示公式留实际脚本；遮罩图片未知。 [CSS](../../styles/CMP-03.css)；[原型](../../prototypes/SCR-01.html)；[tracking](../../../../renovation/sourceCode-AF-AFY10100/tracking.md)。來源E-21，2026-10-12 inventory版本；共同CSS在CMP-01之前載入，訊息窗掛body仍繼承共同字型；CSS全域selector不因審閱工具而縮小。

## Layout

寬180–600px、content初高105px，後續判斷content宽<588与msg.length×15才增长；定位公式見FLOW-14。拖曳框依实际window尺寸與指標offset；遮罩fixed/absolute條件以及只增高度見FLOW-12。

## Components

| STYLE | 來源物件 | class | property | 值 |
| --- | --- | --- | --- | --- |
| STYLE-C-001 | win | common-style-1 | font-family | Verdana, Arial, sans-serif, 微軟正黑體 |
| STYLE-C-002 | win | common-style-1 | font-size | 10pt |
| STYLE-C-003 | win | common-style-1 | border | solid 1px #000 |
| STYLE-C-004 | win | common-style-1 | position | absolute |
| STYLE-C-005 | win | common-style-1 | padding | 0 5px 5px 5px |
| STYLE-C-006 | win | common-style-1 | background-color | #0066CC |
| STYLE-C-007 | win | common-style-1 | z-index | 999 |
| STYLE-C-008 | win | common-style-1 | opacity | 0.95 |
| STYLE-C-009 | win | common-style-1 | box-shadow | 0px 0px 10px 2px #000 |
| STYLE-C-010 | titleDiv | common-style-2 | background-color | #0066CC |
| STYLE-C-011 | titleDiv | common-style-2 | color | #fff |
| STYLE-C-012 | titleDiv | common-style-2 | padding | 8px 0 8px 2px |
| STYLE-C-013 | titleDiv | common-style-2 | cursor | move |
| STYLE-C-014 | contentDiv | common-style-3 | background-color | #FFFFFF |
| STYLE-C-015 | contentDiv | common-style-3 | overflow | auto |
| STYLE-C-016 | contentDiv | common-style-3 | height | 105px |
| STYLE-C-017 | contentDiv | common-style-3 | border-left | 1px solid #000 |
| STYLE-C-018 | contentDiv | common-style-3 | border-right | 1px solid #000 |
| STYLE-C-019 | contentDiv | common-style-3 | border-top | 1px solid #000 |
| STYLE-C-020 | contentDiv | common-style-3 | padding-left | 15px |
| STYLE-C-021 | contentDiv | common-style-3 | padding-top | 10px |
| STYLE-C-022 | contentDiv | common-style-3 | position | relative |
| STYLE-C-023 | contentDiv | common-style-3 | scrollbar-face-color | #D4D0C8 |
| STYLE-C-024 | contentDiv | common-style-3 | scrollbar-highlight-color | #FFFFFF |
| STYLE-C-025 | contentDiv | common-style-3 | scrollbar-3dlight-color | #D4D0C8 |
| STYLE-C-026 | contentDiv | common-style-3 | scrollbar-darkshadow-color | #404040 |
| STYLE-C-027 | contentDiv | common-style-3 | scrollbar-shadow-color | #808080 |
| STYLE-C-028 | contentDiv | common-style-3 | scrollbar-arrow-color | #000000 |
| STYLE-C-029 | contentDiv | common-style-3 | scrollbar-track-color | #CCCCCC |
| STYLE-C-030 | bottomDiv | common-style-4 | background-color | #EEEEEE |
| STYLE-C-031 | bottomDiv | common-style-4 | border-left | 1px solid #000 |
| STYLE-C-032 | bottomDiv | common-style-4 | border-right | 1px solid #000 |
| STYLE-C-033 | bottomDiv | common-style-4 | border-bottom | 1px solid #000 |
| STYLE-C-034 | bottomDiv | common-style-4 | padding | 10px 0 10px 0 |
| STYLE-C-035 | dragDiv | common-style-5 | position | absolute |
| STYLE-C-036 | dragDiv | common-style-5 | border | 1px solid #000000 |


局部缺口：[TODO-02](../../../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02)（CSS映射／圖片）、[TODO-01](../../../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)（依賴情境／未驗證）。精確CSS即載入版本；STYLE可从對应映射回查，瀏覽器结果仅在tracking维护。tokens不覆蓋所有樣式，pt/%/複合值與公式保留文件/CSS。

STYLE-C-CONFIRM：`:root .button.common-confirm / padding / 0 15px`，E-21，保留原inline優先序；STYLE-C-COVER：`.common-cover / width,height,left,top,padding,margin / 100%,100%,0,0,0,0 auto`，E-21。位置分支与动态公式仍在实际脚本；不把review层级写成产品需求。
