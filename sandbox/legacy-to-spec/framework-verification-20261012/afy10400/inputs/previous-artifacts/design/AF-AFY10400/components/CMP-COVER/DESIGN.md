---
version: alpha
name: "CMP-COVER — 請求遮罩"
---

# CMP-COVER 样式規格

## Overview

適用AF-AFY10400 v1 / SCR-01；证据E-11，参见 [tracking](../../../../renovation/AF-AFY10400/tracking.md)。[CSS](../../styles/CMP-COVER.css) 由 [prototype](../../prototypes/SCR-01.html) 实际载入。DESIGN.md alpha profile依所附skill规则，未上网核对最新规范；该选择是快照基准。省略spacing/rounded群組：没有来源尺度／圓角系统；精確padding/margin在下表保留，不自創tokens。CMP-COVER没有已知可用图像颜色，故也省略colors与typography；瀏覽器原生／继承结果按实际环境核对。

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

| STYLE | selector／条件 | token／正文映射 | 規範property与宣告值（实际CSS同值） | 证据 | 原型与检查步骤／预期 |
| --- | --- | --- | --- | --- | --- |
| STYLE-COVER-01 | `#cover` | 正文規則；部分值对应frontmatter | `position` = `fixed` | E-11 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-COVER-02 | `#cover` | 正文規則；部分值对应frontmatter | `width` = `100%` | E-11 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-COVER-03 | `#cover` | 正文規則；部分值对应frontmatter | `height` = `100%` | E-11 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-COVER-04 | `#cover` | 正文規則；部分值对应frontmatter | `left` = `0px` | E-11 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-COVER-05 | `#cover` | 正文規則；部分值对应frontmatter | `top` = `0px` | E-11 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-COVER-06 | `#cover` | 正文規則；部分值对应frontmatter | `padding` = `0px` | E-11 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-COVER-07 | `#cover` | 正文規則；部分值对应frontmatter | `margin` = `0px auto` | E-11 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-COVER-08 | `#cover` | 正文規則；部分值对应frontmatter | `z-index` = `150` | E-11 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-COVER-09 | `#cover` | 正文規則；部分值对应frontmatter | `cursor` = `progress` | E-11 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-COVER-10 | `[hidden]` | 正文規則；部分值对应frontmatter | `display` = `none !important` | E-11 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |

测试定义：开SCR-01，初始／新增2列／删除／匯出等待／注入自订消息／重复长短讯息／拖曳各状态，逐selector读取computedStyle并将浏览器规范化值与本表比较；root padding、几何及动态公式单独量测。实测结果留tracking V，不把文字同值当computed已经通过。未取得legacy运行画面，不宣称像素等价。缺少来源样式的局部TODO在specification对应CMP/UI/ST亦可见。

## Do's and Don'ts

保持来源顺序、已知颜色及单位；不增加工具样式作为产品需求；不用合成资源宣稱缺少图像已还原。
