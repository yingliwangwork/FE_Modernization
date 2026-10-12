---
version: alpha
name: "CMP-FORM — 表格按鈕與輸入"
colors:
  table: "#C7E49C"
  odd: "#EEF1A7"
  even: "#FAFBE1"
  header: "#99CCFF"
  buttonText: "#006600"
typography:
  table:
    fontSize: '10pt'
    lineHeight: '21px'
  input:
    fontSize: '12px'
    letterSpacing: '1pt'
  button:
    fontSize: '10pt'
    lineHeight: '19px'
---

# CMP-FORM 样式規格

## Overview

適用AF-AFY10400 v1 / SCR-01；证据E-01/03/20，参见 [tracking](../../../../renovation/AF-AFY10400/tracking.md)。[CSS](../../styles/CMP-FORM.css) 由 [prototype](../../prototypes/SCR-01.html) 实际载入。DESIGN.md alpha profile依所附skill规则，未上网核对最新规范；该选择是快照基准。省略spacing/rounded群組：没有来源尺度／圓角系统；精確padding/margin在下表保留，不自創tokens。CMP-COVER没有已知可用图像颜色，故也省略colors与typography；瀏覽器原生／继承结果按实际环境核对。

## Colors

frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05), [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07).

## Typography

以输入、body或讯息的來源宣告／继承为準。pt不改成猜测px；font实际是否存在、native控件外观与回退须浏览器验证。

## Layout

button的根选择器后置padding0 10px覆写基础0；message-ok inline已知padding0 15px另见CMP-MESSAGE。inputs/textarea字型明确；select保持浏览器原生尺寸/字体。rows3/cols30/size12/max10是HTML配置，实际px不捏造。按新增/删除重新配列，首列odd。later read-only规则只在控件符合状态时透明/无border，不误用到可编辑文本。

## Elevation & Depth

仅使用CSS表已列的边框、层级与shadow；review.css的dashed panel为工具，不属产品。无证据的hover/focus/disabled业务状态不添加。

## Shapes

未确认圆角或shape尺度；保留原生元素及来源边框，不建立圆角token。

## Components

| STYLE | selector／条件 | token／正文映射 | 規範property与宣告值（实际CSS同值） | 证据 | 原型与检查步骤／预期 |
| --- | --- | --- | --- | --- | --- |
| STYLE-FORM-01 | `.product input,.product textarea` | 正文規則；部分值对应frontmatter | `font-family` = `'PMingLiU','MingLiU','Microsoft JhengHei','Meiryo','Arial','Arial Unicode MS','Helvetica','sans-serif','Verdana','Trebuchet MS'` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-02 | `.tbBox2` | 正文規則；部分值对应frontmatter | `background-color` = `#C7E49C` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-03 | `.tbBox2` | 正文規則；部分值对应frontmatter | `border` = `1px solid` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-04 | `.tbBox2` | 正文規則；部分值对应frontmatter | `border-color` = `#FFFFFF #6B8D6D #6B8D6D #FFFFFF` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-05 | `.tbBox2` | 正文規則；部分值对应frontmatter | `font-size` = `10pt` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-06 | `.tbBox2` | 正文規則；部分值对应frontmatter | `text-indent` = `1pt` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-07 | `.tbBox2` | 正文規則；部分值对应frontmatter | `padding` = `1pt` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-08 | `.tbBox2` | 正文規則；部分值对应frontmatter | `line-height` = `21px` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-09 | `.tbYellow` | 正文規則；部分值对应frontmatter | `background-color` = `#EEF1A7` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-10 | `.tbYellow2` | 正文規則；部分值对应frontmatter | `background-color` = `#FAFBE1` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-11 | `.tbBlue` | 正文規則；部分值对应frontmatter | `background-color` = `#99CCFF` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-12 | `.data-table,.export-table` | 正文規則；部分值对应frontmatter | `width` = `100%` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-13 | `.data-table td` | 正文規則；部分值对应frontmatter | `text-align` = `center` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-14 | `.data-table .instructions,.data-table .value-cell` | 正文規則；部分值对应frontmatter | `text-align` = `left` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-15 | `.label-cell` | 正文規則；部分值对应frontmatter | `width` = `20%` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-16 | `.value-cell.first` | 正文規則；部分值对应frontmatter | `width` = `20%` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-17 | `.value-cell.second` | 正文規則；部分值对应frontmatter | `width` = `40%` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-18 | `.textBox2` | 正文規則；部分值对应frontmatter | `font-size` = `12px` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-19 | `.textBox2` | 正文規則；部分值对应frontmatter | `text-decoration` = `none` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-20 | `.textBox2` | 正文規則；部分值对应frontmatter | `letter-spacing` = `1pt` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-21 | `.textBox2` | 正文規則；部分值对应frontmatter | `border-top` = `1px solid #999999` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-22 | `.textBox2` | 正文規則；部分值对应frontmatter | `border-right` = `1px solid #E1E1E1` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-23 | `.textBox2` | 正文規則；部分值对应frontmatter | `border-bottom` = `1px solid #E1E1E1` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-24 | `.textBox2` | 正文規則；部分值对应frontmatter | `border-left` = `1px solid #999999` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-25 | `.button` | 正文規則；部分值对应frontmatter | `font-size` = `10pt` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-26 | `.button` | 正文規則；部分值对应frontmatter | `border` = `1px solid #6B8D6D` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-27 | `.button` | 正文規則；部分值对应frontmatter | `color` = `#006600` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-28 | `.button` | 正文規則；部分值对应frontmatter | `white-space` = `nowrap` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-29 | `.button` | 正文規則；部分值对应frontmatter | `line-height` = `19px` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-30 | `.button` | 正文規則；部分值对应frontmatter | `height` = `21px` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-31 | `.button` | 正文規則；部分值对应frontmatter | `vertical-align` = `middle` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-32 | `.button` | 正文規則；部分值对应frontmatter | `margin` = `2px` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-33 | `.button` | 正文規則；部分值对应frontmatter | `padding` = `0` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-34 | `.button` | 正文規則；部分值对应frontmatter | `background` = `linear-gradient(to bottom,#eff6ec 0%,#ffffff 40%,#cfe4c1 100%)` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-35 | `:root .button` | 正文規則；部分值对应frontmatter | `padding` = `0px 10px` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-36 | `.product input:read-only,.product textarea:read-only` | 正文規則；部分值对应frontmatter | `background-color` = `transparent` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-37 | `.product input:read-only,.product textarea:read-only` | 正文規則；部分值对应frontmatter | `border` = `none` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-38 | `.export-table td` | 正文規則；部分值对应frontmatter | `text-align` = `center` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-39 | `.row-odd` | 正文規則；部分值对应frontmatter | `background-color` = `#EEF1A7` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |
| STYLE-FORM-40 | `.row-even` | 正文規則；部分值对应frontmatter | `background-color` = `#FAFBE1` | E-01/03/20 | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |

测试定义：开SCR-01，初始／新增2列／删除／匯出等待／注入自订消息／重复长短讯息／拖曳各状态，逐selector读取computedStyle并将浏览器规范化值与本表比较；root padding、几何及动态公式单独量测。实测结果留tracking V，不把文字同值当computed已经通过。未取得legacy运行画面，不宣称像素等价。缺少来源样式的局部TODO在specification对应CMP/UI/ST亦可见。

## Do's and Don'ts

保持来源顺序、已知颜色及单位；不增加工具样式作为产品需求；不用合成资源宣稱缺少图像已还原。
