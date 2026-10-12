---
version: alpha
name: "CMP-COVER — 請求遮罩"
---

# CMP-COVER 样式規格

## Overview

適用AF-AFY10400 v2 / SCR-01；证据E-11，参见 [tracking](../../../../renovation/AF-AFY10400/tracking.md)。[CSS](../../styles/CMP-COVER.css) 由 [prototype](../../prototypes/SCR-01.html) 实际载入。DESIGN.md alpha profile依所附skill规则，未上网核对最新规范；该选择是快照基准。省略spacing/rounded群組：没有来源尺度／圓角系统；精確padding/margin在下表保留，不自創tokens。CMP-COVER没有已知可用图像颜色，故也省略colors与typography；瀏覽器原生／继承结果按实际环境核对。

## Colors

frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05), [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07).

## Typography

以输入、body或讯息的來源宣告／继承为準。pt不改成猜测px；font实际是否存在、native控件外观与回退须浏览器验证。

## Layout

Chrome分支position fixed、宽高100%、层级150、光标progress；旧IE absolute只知长高不减的resize，浏览器差異未驗證。缺png/gif不创造透明黑底、loading spinner或文字；有遮罩几何／阻隔但视觉部分交付。

## Elevation & Depth

仅使用CSS表已列的边框、层级与shadow；review.css的dashed panel为工具，不属产品。无证据的hover/focus/disabled业务状态不添加。

## Shapes

未确认圆角或shape尺度；保留原生元素及来源边框，不建立圆角token。

## Components

| STYLE | CMP／UI／ST／selector條件 | 實際 token 路徑或明確無token正文規則 | 實載 CSS／property／值 | 精確E及來源定位 | 原型／computed檢查定義 | 局部缺口 |
| --- | --- | --- | --- | --- | --- | --- |
| STYLE-COVER-01 | CMP-COVER／UI-09/10；ST-03/05；`#cover` | 無 token；本列精確正文規則（position=fixed） | [CMP-COVER.css](../../styles/CMP-COVER.css)：`position: fixed` | [E-11](../../../../renovation/AF-AFY10400/tracking.md#e-11)；CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `position` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴 |
| STYLE-COVER-02 | CMP-COVER／UI-09/10；ST-03/05；`#cover` | 無 token；本列精確正文規則（width=100%） | [CMP-COVER.css](../../styles/CMP-COVER.css)：`width: 100%` | [E-11](../../../../renovation/AF-AFY10400/tracking.md#e-11)；CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `width` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴 |
| STYLE-COVER-03 | CMP-COVER／UI-09/10；ST-03/05；`#cover` | 無 token；本列精確正文規則（height=100%） | [CMP-COVER.css](../../styles/CMP-COVER.css)：`height: 100%` | [E-11](../../../../renovation/AF-AFY10400/tracking.md#e-11)；CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `height` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴 |
| STYLE-COVER-04 | CMP-COVER／UI-09/10；ST-03/05；`#cover` | 無 token；本列精確正文規則（left=0px） | [CMP-COVER.css](../../styles/CMP-COVER.css)：`left: 0px` | [E-11](../../../../renovation/AF-AFY10400/tracking.md#e-11)；CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `left` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴 |
| STYLE-COVER-05 | CMP-COVER／UI-09/10；ST-03/05；`#cover` | 無 token；本列精確正文規則（top=0px） | [CMP-COVER.css](../../styles/CMP-COVER.css)：`top: 0px` | [E-11](../../../../renovation/AF-AFY10400/tracking.md#e-11)；CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `top` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴 |
| STYLE-COVER-06 | CMP-COVER／UI-09/10；ST-03/05；`#cover` | 無 token；本列精確正文規則（padding=0px） | [CMP-COVER.css](../../styles/CMP-COVER.css)：`padding: 0px` | [E-11](../../../../renovation/AF-AFY10400/tracking.md#e-11)；CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `padding` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴 |
| STYLE-COVER-07 | CMP-COVER／UI-09/10；ST-03/05；`#cover` | 無 token；本列精確正文規則（margin=0px auto） | [CMP-COVER.css](../../styles/CMP-COVER.css)：`margin: 0px auto` | [E-11](../../../../renovation/AF-AFY10400/tracking.md#e-11)；CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `margin` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴 |
| STYLE-COVER-08 | CMP-COVER／UI-09/10；ST-03/05；`#cover` | 無 token；本列精確正文規則（z-index=150） | [CMP-COVER.css](../../styles/CMP-COVER.css)：`z-index: 150` | [E-11](../../../../renovation/AF-AFY10400/tracking.md#e-11)；CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `z-index` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴 |
| STYLE-COVER-09 | CMP-COVER／UI-09/10；ST-03/05；`#cover` | 無 token；本列精確正文規則（cursor=progress） | [CMP-COVER.css](../../styles/CMP-COVER.css)：`cursor: progress` | [E-11](../../../../renovation/AF-AFY10400/tracking.md#e-11)；CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `cursor` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴 |
| STYLE-COVER-10 | CMP-COVER／UI-09/10；ST-03/05；`[hidden]` | 無 token；本列精確正文規則（display=none !important） | [CMP-COVER.css](../../styles/CMP-COVER.css)：`display: none !important` | [E-11](../../../../renovation/AF-AFY10400/tracking.md#e-11)；CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `display` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴 |

测试定义：开SCR-01，初始／新增2列／删除／匯出等待／注入自订消息／重复长短讯息／拖曳各状态，逐selector读取computedStyle并将浏览器规范化值与本表比较；root padding、几何及动态公式单独量测。实测结果留tracking V，不把文字同值当computed已经通过。未取得legacy运行画面，不宣称像素等价。缺少来源样式的局部TODO在specification对应CMP/UI/ST亦可见。

## Do's and Don'ts

保持来源顺序、已知颜色及单位；不增加工具样式作为产品需求；不用合成资源宣稱缺少图像已还原。

取得／建立副作用：當時焦點位於按鈕類才嘗試聚焦所屬視窗，來源CSRUtil L321–326、E-26。這不是CSS token；FLOW-06/AC-19實際效果仍TODO-07，不把嘗試寫成必然聚焦。
