---
version: alpha
name: "CMP-MESSAGE — 自訂訊息視窗"
colors:
  window: "#0066CC"
  content: "#FFFFFF"
  footer: "#EEEEEE"
  title: "#FFFFFF"
typography:
  message:
    fontFamily: 'Verdana, Arial, sans-serif, 微軟正黑體'
    fontSize: '10pt'
---

# CMP-MESSAGE 样式規格

## Overview

適用AF-AFY10400 v1 / SCR-01；证据E-12/20，参见 [tracking](../../../../renovation/AF-AFY10400/tracking.md)。[CSS](../../styles/CMP-MESSAGE.css) 由 [prototype](../../prototypes/SCR-01.html) 实际载入。DESIGN.md alpha profile依所附skill规则，未上网核对最新规范；该选择是快照基准。省略spacing/rounded群組：没有来源尺度／圓角系统；精確padding/margin在下表保留，不自創tokens。CMP-COVER没有已知可用图像颜色，故也省略colors与typography；瀏覽器原生／继承结果按实际环境核对。

## Colors

frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-03](../../../../renovation/AF-AFY10400/tracking.md#todo-03), [TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05), [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07).

## Typography

以输入、body或讯息的來源宣告／继承为準。pt不改成猜测px；font实际是否存在、native控件外观与回退须浏览器验证。

## Layout

首次width=clamp(正規化msg含呈現標記長度×15,180,600)px；重複訊息僅增長不縮小的判定见common-contracts；height初值105px，內容高度不因多筆改大而是overflow auto。top=parseInt(body.clientHeight/4+scrollTop)，left=parseInt((body.clientWidth-window.outerWidth)/2+scrollLeft)。拖曳框width/height等於視窗當時outer dimensions；move随pointer偏移，mouseup視窗採框位置。這些是prototype.js動態inline來源公式，不覆寫另一套CSS。來源title的fontWeight鍵末尾空白未确认有效，不新增bold。STYLE-MESSAGE-DYNAMIC，E-12。

## Elevation & Depth

仅使用CSS表已列的边框、层级与shadow；review.css的dashed panel为工具，不属产品。无证据的hover/focus/disabled业务状态不添加。

## Shapes

未确认圆角或shape尺度；保留原生元素及来源边框，不建立圆角token。

## Components

| STYLE | selector／条件 | token／正文映射 | 規範property与宣告值（实际CSS同值） | 证据 | 原型与检查步骤／预期 |
| --- | --- | --- | --- | --- | --- |
| STYLE-MESSAGE-01 | `#message` | 正文規則；部分值对应frontmatter | `font-family` = `Verdana,Arial,sans-serif,微軟正黑體` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-02 | `#message` | 正文規則；部分值对应frontmatter | `font-size` = `10pt` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-03 | `#message` | 正文規則；部分值对应frontmatter | `border` = `solid 1px #000` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-04 | `#message` | 正文規則；部分值对应frontmatter | `position` = `absolute` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-05 | `#message` | 正文規則；部分值对应frontmatter | `padding` = `0 5px 5px 5px` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-06 | `#message` | 正文規則；部分值对应frontmatter | `background-color` = `#0066CC` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-07 | `#message` | 正文規則；部分值对应frontmatter | `width` = `180px` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-08 | `#message` | 正文規則；部分值对应frontmatter | `z-index` = `999` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-09 | `#message` | 正文規則；部分值对应frontmatter | `opacity` = `.95` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-10 | `#message` | 正文規則；部分值对应frontmatter | `box-shadow` = `0px 0px 10px 2px #000` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-11 | `#message` | 正文規則；部分值对应frontmatter | `text-align` = `center` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-12 | `#message-title` | 正文規則；部分值对应frontmatter | `background-color` = `#0066CC` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-13 | `#message-title` | 正文規則；部分值对应frontmatter | `color` = `#fff` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-14 | `#message-title` | 正文規則；部分值对应frontmatter | `padding` = `8px 0 8px 2px` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-15 | `#message-title` | 正文規則；部分值对应frontmatter | `cursor` = `move` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-16 | `#message-title` | 正文規則；部分值对应frontmatter | `text-align` = `left` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-17 | `#message-content` | 正文規則；部分值对应frontmatter | `background-color` = `#fff` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-18 | `#message-content` | 正文規則；部分值对应frontmatter | `overflow` = `auto` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-19 | `#message-content` | 正文規則；部分值对应frontmatter | `height` = `105px` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-20 | `#message-content` | 正文規則；部分值对应frontmatter | `border-left` = `1px solid #000` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-21 | `#message-content` | 正文規則；部分值对应frontmatter | `border-right` = `1px solid #000` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-22 | `#message-content` | 正文規則；部分值对应frontmatter | `border-top` = `1px solid #000` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-23 | `#message-content` | 正文規則；部分值对应frontmatter | `padding-left` = `15px` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-24 | `#message-content` | 正文規則；部分值对应frontmatter | `padding-top` = `10px` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-25 | `#message-content` | 正文規則；部分值对应frontmatter | `position` = `relative` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-26 | `#message-content` | 正文規則；部分值对应frontmatter | `text-align` = `left` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-27 | `#message-bottom` | 正文規則；部分值对应frontmatter | `background-color` = `#EEE` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-28 | `#message-bottom` | 正文規則；部分值对应frontmatter | `border-left` = `1px solid #000` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-29 | `#message-bottom` | 正文規則；部分值对应frontmatter | `border-right` = `1px solid #000` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-30 | `#message-bottom` | 正文規則；部分值对应frontmatter | `border-bottom` = `1px solid #000` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-31 | `#message-bottom` | 正文規則；部分值对应frontmatter | `padding` = `10px 0` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-32 | `#message-ok` | 正文規則；部分值对应frontmatter | `padding` = `0 15px` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-33 | `#drag-frame` | 正文規則；部分值对应frontmatter | `position` = `absolute` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-MESSAGE-34 | `#drag-frame` | 正文規則；部分值对应frontmatter | `border` = `1px solid #000` | E-12/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |

测试定义：开SCR-01，初始／新增2列／删除／匯出等待／注入自订消息／重复长短讯息／拖曳各状态，逐selector读取computedStyle并将浏览器规范化值与本表比较；root padding、几何及动态公式单独量测。实测结果留tracking V，不把文字同值当computed已经通过。未取得legacy运行画面，不宣称像素等价。缺少来源样式的局部TODO在specification对应CMP/UI/ST亦可见。

## Do's and Don'ts

保持来源顺序、已知颜色及单位；不增加工具样式作为产品需求；不用合成资源宣稱缺少图像已还原。
