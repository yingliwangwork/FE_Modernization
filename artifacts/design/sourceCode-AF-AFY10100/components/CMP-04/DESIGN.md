---
version: alpha
name: CMP-04 — 全頁條件列印政策
---

# CMP-04 樣式規格

## Overview

policy=Y只作合成情境，body/window作用域不缩小。 [CSS](../../styles/CMP-04.css)；[原型](../../prototypes/SCR-01.html)；[tracking](../../../../renovation/sourceCode-AF-AFY10100/tracking.md)。來源E-16，2026-10-12 inventory版本；共同CSS在CMP-01之前載入，訊息窗掛body仍繼承共同字型；CSS全域selector不因審閱工具而縮小。

## Layout

## Components

| STYLE | 條件 | selector/property | 值 | 來源 |
| --- | --- | --- | --- | --- |
| STYLE-P-01 | policy=Y，print | body>* display | none !important | E-16 |
| STYLE-P-02 | policy=Y，print | body::after content/display | 依據資安政策，不開放列印功能／block !important | E-16 |


局部缺口：[TODO-02](../../../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-02)（CSS映射／圖片）、[TODO-01](../../../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)（依賴情境／未驗證）。精確CSS即載入版本；STYLE可从對应映射回查，瀏覽器结果仅在tracking维护。tokens不覆蓋所有樣式，pt/%/複合值與公式保留文件/CSS。
