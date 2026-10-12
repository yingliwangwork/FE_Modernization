---
version: alpha
name: "CMP-05 — 條件水印"
colors:
  text: "#000000"
typography:
  text:
    fontFamily: "Microsoft JhengHei"
    fontSize: "16px"
    fontWeight: 400
---

# CMP-05 樣式規格

## Overview

來源E-16/header與E-26/本地watermark-js-plus 1.6.0，僅選用根頁multi-line-text/grid組態。[CSS](../../styles/CMP-05.css)、[prototype](../../prototypes/SCR-01.html)、[tracking](../../../../renovation/sourceCode-AF-AFY10100/tracking.md)。真實受信任旗標、身份、時間與字型仍為[TODO-01](../../../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-01)／[TODO-04](../../../../renovation/sourceCode-AF-AFY10100/tracking.md#todo-04)。URL開關與文字是審閱情境，不屬產品可改權限。

## Colors

黑色文字；canvas globalAlpha=0.07，不是整個DOM opacity。沒有自行改色或可讀性增強。

## Typography

Microsoft JhengHei、16px、normal；兩行、lineHeight20，旋轉17度。fontStyle空、letterSpacing/wordSpacing0px來自工具預設；不新增字型／圖片。

## Layout

單格190×85px；2×2、gap[-18,-8]、matrix[[1,0],[0,1]]。工具grid背景尺寸公式為190×2−18×2=344px、85×2−8×2=154px。root下內層fixed全幅，pointer-events:none；外層relative。庫監聽自己的DOM與parent childList，在被移動／移除或樣式變動時remove/create；remove解除observer與檢查事件後移除節點。monProtection=true會保護頁內MutationObserver/requestAnimationFrame，作用在此頁，不外推其他視窗。

## Components

| STYLE | selector／property或畫布值 | 值／條件 | 來源与核對 |
| --- | --- | --- | --- |
| STYLE-W-01 | .legacy-watermark position/z-index/display/visibility/transform/scale | relative/2147483647/block/visible/none/none，important | E-26；實際CSS與工具相同基準 |
| STYLE-W-02 | .legacy-watermark > div position/width/height/pointer-events | fixed/100%/100%/none | E-26 root模式，CSS實際載入 |
| STYLE-W-03 | 背景image/size/repeat/position | 工具畫布產生data URL／344px 154px／repeat／0 0 | E-16/26；image與size為工具組態動態inline，未複製另一套圖像 |
| STYLE-W-04 | canvas文字／字型／rotate/globalAlpha/grid | 黑/16px Microsoft JhengHei normal/17/.07/上述grid | E-16；不是CSS opacity，配置在watermark-review.js；實測結果在tracking |

## Do's and Don'ts

保留條件呈現與來源配置；合成身份／时间明列。後端來源未知不烘成產品常數。原header berforeunload拼字與現代/舊事件分支handler不同不擅自修正。
