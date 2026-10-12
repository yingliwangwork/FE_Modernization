---
version: alpha
name: "CMP-PAGE — 全頁與標題"
colors:
  page: "#F0FBC6"
  frame: "#003366"
  title: "#339900"
typography:
  page:
    fontFamily: "'PMingLiU', 'MingLiU', 'Microsoft JhengHei', 'Meiryo', 'Arial', 'Arial Unicode MS', 'Helvetica', 'sans-serif', 'Verdana', 'Trebuchet MS'"
  title:
    fontSize: '10pt'
    fontWeight: bold
    letterSpacing: '3pt'
---

# CMP-PAGE 样式規格

## Overview

適用AF-AFY10400 v1 / SCR-01；证据E-02/08/20，参见 [tracking](../../../../renovation/AF-AFY10400/tracking.md)。[CSS](../../styles/CMP-PAGE.css) 由 [prototype](../../prototypes/SCR-01.html) 实际载入。DESIGN.md alpha profile依所附skill规则，未上网核对最新规范；该选择是快照基准。省略spacing/rounded群組：没有来源尺度／圓角系统；精確padding/margin在下表保留，不自創tokens。CMP-COVER没有已知可用图像颜色，故也省略colors与typography；瀏覽器原生／继承结果按实际环境核对。

## Colors

frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05), [TODO-06](../../../../renovation/AF-AFY10400/tracking.md#todo-06), [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07).

## Typography

以输入、body或讯息的來源宣告／继承为準。pt不改成猜测px；font实际是否存在、native控件外观与回退须浏览器验证。

## Layout

body字型继承与EUDC @font-face源条件已知、真实字体缺失；难字不能宣稱等價。主框97%、顶栏30px、绝对0/0/z9。条件print样式作用于body所有子元素，不能只局限产品容器。框圖4px、留白圖5px及icon18×16的资源缺少，原型不补造图像或形似图标；这些具体未展示尺寸连TODO-05。

## Elevation & Depth

仅使用CSS表已列的边框、层级与shadow；review.css的dashed panel为工具，不属产品。无证据的hover/focus/disabled业务状态不添加。

## Shapes

未确认圆角或shape尺度；保留原生元素及来源边框，不建立圆角token。

## Components

| STYLE | selector／条件 | token／正文映射 | 規範property与宣告值（实际CSS同值） | 证据 | 原型与检查步骤／预期 |
| --- | --- | --- | --- | --- | --- |
| STYLE-PAGE-01 | `body` | 正文規則；部分值对应frontmatter | `margin` = `0` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-02 | `body` | 正文規則；部分值对应frontmatter | `background` = `#F0FBC6` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-03 | `body` | 正文規則；部分值对应frontmatter | `font-family` = `'PMingLiU','MingLiU','Microsoft JhengHei','Meiryo','Arial','Arial Unicode MS','Helvetica','sans-serif','Verdana','Trebuchet MS'` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-04 | `.product-title` | 正文規則；部分值对应frontmatter | `position` = `absolute` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-05 | `.product-title` | 正文規則；部分值对应frontmatter | `left` = `0` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-06 | `.product-title` | 正文規則；部分值对应frontmatter | `top` = `0` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-07 | `.product-title` | 正文規則；部分值对应frontmatter | `width` = `100%` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-08 | `.product-title` | 正文規則；部分值对应frontmatter | `z-index` = `9` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-09 | `.product-title` | 正文規則；部分值对应frontmatter | `visibility` = `visible` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-10 | `.product-title` | 正文規則；部分值对应frontmatter | `height` = `30px` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-11 | `.product-title table` | 正文規則；部分值对应frontmatter | `width` = `100%` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-12 | `.product-title table` | 正文規則；部分值对应frontmatter | `border-spacing` = `0` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-13 | `.subTitle` | 正文規則；部分值对应frontmatter | `font-size` = `10pt` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-14 | `.subTitle` | 正文規則；部分值对应frontmatter | `font-weight` = `bold` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-15 | `.subTitle` | 正文規則；部分值对应frontmatter | `color` = `#339900` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-16 | `.subTitle` | 正文規則；部分值对应frontmatter | `letter-spacing` = `3pt` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-17 | `.title-spacer` | 正文規則；部分值对应frontmatter | `height` = `30px` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-18 | `.outer` | 正文規則；部分值对应frontmatter | `width` = `100%` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-19 | `.outer` | 正文規則；部分值对应frontmatter | `border-spacing` = `0` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-20 | `.main-frame` | 正文規則；部分值对应frontmatter | `width` = `97%` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-21 | `.main-frame` | 正文規則；部分值对应frontmatter | `margin` = `0 auto` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-22 | `.main-frame` | 正文規則；部分值对应frontmatter | `border-spacing` = `1px` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-23 | `.main-frame` | 正文規則；部分值对应frontmatter | `background` = `#003366` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-24 | `.form-body` | 正文規則；部分值对应frontmatter | `background` = `#fff` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-25 | `.form-body` | 正文規則；部分值对应frontmatter | `padding` = `5px` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-26 | `.red` | 正文規則；部分值对应frontmatter | `color` = `red` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-27 | `body.policy-enabled > *` | 正文規則；部分值对应frontmatter | `display` = `none !important` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-28 | `body.policy-enabled::after` | 正文規則；部分值对应frontmatter | `content` = `'依據資安政策，不開放列印功能'` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-PAGE-29 | `body.policy-enabled::after` | 正文規則；部分值对应frontmatter | `display` = `block !important` | E-02/08/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |

测试定义：开SCR-01，初始／新增2列／删除／匯出等待／注入自订消息／重复长短讯息／拖曳各状态，逐selector读取computedStyle并将浏览器规范化值与本表比较；root padding、几何及动态公式单独量测。实测结果留tracking V，不把文字同值当computed已经通过。未取得legacy运行画面，不宣称像素等价。缺少来源样式的局部TODO在specification对应CMP/UI/ST亦可见。

## Do's and Don'ts

保持来源顺序、已知颜色及单位；不增加工具样式作为产品需求；不用合成资源宣稱缺少图像已还原。
