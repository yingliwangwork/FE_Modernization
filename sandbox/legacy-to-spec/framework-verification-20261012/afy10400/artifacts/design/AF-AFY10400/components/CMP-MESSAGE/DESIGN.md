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

適用AF-AFY10400 v2 / SCR-01；证据E-12/20，参见 [tracking](../../../../renovation/AF-AFY10400/tracking.md)。[CSS](../../styles/CMP-MESSAGE.css) 由 [prototype](../../prototypes/SCR-01.html) 实际载入。DESIGN.md alpha profile依所附skill规则，未上网核对最新规范；该选择是快照基准。省略spacing/rounded群組：没有来源尺度／圓角系统；精確padding/margin在下表保留，不自創tokens。CMP-COVER没有已知可用图像颜色，故也省略colors与typography；瀏覽器原生／继承结果按实际环境核对。

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

| STYLE | CMP／UI／ST／selector條件 | 實際 token 路徑或明確無token正文規則 | 實載 CSS／property／值 | 精確E及來源定位 | 原型／computed檢查定義 | 局部缺口 |
| --- | --- | --- | --- | --- | --- | --- |
| STYLE-MESSAGE-01 | CMP-MESSAGE／UI-10；ST-05；`#message` | typography.message.fontFamily | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`font-family: Verdana,Arial,sans-serif,微軟正黑體` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `font-family` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-02 | CMP-MESSAGE／UI-10；ST-05；`#message` | typography.message.fontSize | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`font-size: 10pt` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `font-size` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-03 | CMP-MESSAGE／UI-10；ST-05；`#message` | 無 token；本列精確正文規則（border=solid 1px #000） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`border: solid 1px #000` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `border` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-04 | CMP-MESSAGE／UI-10；ST-05；`#message` | 無 token；本列精確正文規則（position=absolute） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`position: absolute` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `position` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-05 | CMP-MESSAGE／UI-10；ST-05；`#message` | 無 token；本列精確正文規則（padding=0 5px 5px 5px） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`padding: 0 5px 5px 5px` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `padding` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-06 | CMP-MESSAGE／UI-10；ST-05；`#message` | colors.window | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`background-color: #0066CC` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `background-color` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-07 | CMP-MESSAGE／UI-10；ST-05；`#message` | 無 token；本列精確正文規則（width=180px） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`width: 180px` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `width` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-08 | CMP-MESSAGE／UI-10；ST-05；`#message` | 無 token；本列精確正文規則（z-index=999） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`z-index: 999` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `z-index` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-09 | CMP-MESSAGE／UI-10；ST-05；`#message` | 無 token；本列精確正文規則（opacity=.95） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`opacity: .95` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `opacity` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-10 | CMP-MESSAGE／UI-10；ST-05；`#message` | 無 token；本列精確正文規則（box-shadow=0px 0px 10px 2px #000） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`box-shadow: 0px 0px 10px 2px #000` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `box-shadow` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-11 | CMP-MESSAGE／UI-10；ST-05；`#message` | 無 token；本列精確正文規則（text-align=center） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`text-align: center` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1432–1447 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `text-align` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-12 | CMP-MESSAGE／UI-10；ST-05；`#message-title` | colors.window | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`background-color: #0066CC` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1476–1484（fontWeight尾空白未升格） | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `background-color` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-13 | CMP-MESSAGE／UI-10；ST-05；`#message-title` | colors.title | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`color: #fff` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1476–1484（fontWeight尾空白未升格） | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `color` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-14 | CMP-MESSAGE／UI-10；ST-05；`#message-title` | 無 token；本列精確正文規則（padding=8px 0 8px 2px） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`padding: 8px 0 8px 2px` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1476–1484（fontWeight尾空白未升格） | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `padding` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-15 | CMP-MESSAGE／UI-10；ST-05；`#message-title` | 無 token；本列精確正文規則（cursor=move） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`cursor: move` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1476–1484（fontWeight尾空白未升格） | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `cursor` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-16 | CMP-MESSAGE／UI-10；ST-05；`#message-title` | 無 token；本列精確正文規則（text-align=left） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`text-align: left` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1476–1484（fontWeight尾空白未升格） | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `text-align` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-17 | CMP-MESSAGE／UI-10；ST-05；`#message-content` | colors.content | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`background-color: #fff` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1486–1504 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `background-color` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-18 | CMP-MESSAGE／UI-10；ST-05；`#message-content` | 無 token；本列精確正文規則（overflow=auto） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`overflow: auto` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1486–1504 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `overflow` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-19 | CMP-MESSAGE／UI-10；ST-05；`#message-content` | 無 token；本列精確正文規則（height=105px） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`height: 105px` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1486–1504 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `height` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-20 | CMP-MESSAGE／UI-10；ST-05；`#message-content` | 無 token；本列精確正文規則（border-left=1px solid #000） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`border-left: 1px solid #000` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1486–1504 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `border-left` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-21 | CMP-MESSAGE／UI-10；ST-05；`#message-content` | 無 token；本列精確正文規則（border-right=1px solid #000） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`border-right: 1px solid #000` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1486–1504 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `border-right` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-22 | CMP-MESSAGE／UI-10；ST-05；`#message-content` | 無 token；本列精確正文規則（border-top=1px solid #000） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`border-top: 1px solid #000` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1486–1504 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `border-top` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-23 | CMP-MESSAGE／UI-10；ST-05；`#message-content` | 無 token；本列精確正文規則（padding-left=15px） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`padding-left: 15px` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1486–1504 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `padding-left` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-24 | CMP-MESSAGE／UI-10；ST-05；`#message-content` | 無 token；本列精確正文規則（padding-top=10px） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`padding-top: 10px` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1486–1504 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `padding-top` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-25 | CMP-MESSAGE／UI-10；ST-05；`#message-content` | 無 token；本列精確正文規則（position=relative） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`position: relative` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1486–1504 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `position` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-26 | CMP-MESSAGE／UI-10；ST-05；`#message-content` | 無 token；本列精確正文規則（text-align=left） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`text-align: left` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1486–1504 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `text-align` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-27 | CMP-MESSAGE／UI-10；ST-05；`#message-bottom` | colors.footer | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`background-color: #EEE` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1506–1513 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `background-color` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-28 | CMP-MESSAGE／UI-10；ST-05；`#message-bottom` | 無 token；本列精確正文規則（border-left=1px solid #000） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`border-left: 1px solid #000` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1506–1513 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `border-left` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-29 | CMP-MESSAGE／UI-10；ST-05；`#message-bottom` | 無 token；本列精確正文規則（border-right=1px solid #000） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`border-right: 1px solid #000` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1506–1513 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `border-right` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-30 | CMP-MESSAGE／UI-10；ST-05；`#message-bottom` | 無 token；本列精確正文規則（border-bottom=1px solid #000） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`border-bottom: 1px solid #000` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1506–1513 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `border-bottom` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-31 | CMP-MESSAGE／UI-10；ST-05；`#message-bottom` | 無 token；本列精確正文規則（padding=10px 0） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`padding: 10px 0` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1506–1513 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `padding` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-32 | CMP-MESSAGE／UI-10；ST-05；`#message-ok` | 無 token；本列精確正文規則（padding=0 15px） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`padding: 0 15px` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1449–1451；來源指定padding比cm.css優先 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `padding` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-33 | CMP-MESSAGE／FLOW-10，拖曳中的框；ST-05；`#drag-frame` | 無 token；本列精確正文規則（position=absolute） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`position: absolute` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1520–1524/1538/1549–1552 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `position` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |
| STYLE-MESSAGE-34 | CMP-MESSAGE／FLOW-10，拖曳中的框；ST-05；`#drag-frame` | 無 token；本列精確正文規則（border=1px solid #000） | [CMP-MESSAGE.css](../../styles/CMP-MESSAGE.css)：`border: 1px solid #000` | [E-12](../../../../renovation/AF-AFY10400/tracking.md#e-12)；CSRUtil L1520–1524/1538/1549–1552 | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `border` 比較本宣告的瀏覽器等價值 | [TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行 |

测试定义：开SCR-01，初始／新增2列／删除／匯出等待／注入自订消息／重复长短讯息／拖曳各状态，逐selector读取computedStyle并将浏览器规范化值与本表比较；root padding、几何及动态公式单独量测。实测结果留tracking V，不把文字同值当computed已经通过。未取得legacy运行画面，不宣称像素等价。缺少来源样式的局部TODO在specification对应CMP/UI/ST亦可见。

## Do's and Don'ts

保持来源顺序、已知颜色及单位；不增加工具样式作为产品需求；不用合成资源宣稱缺少图像已还原。

首鍵交錯：真視窗拖曳移出頁面時，先解除该首鍵實例再停止反應，不確認或阻斷；放開重附著不恢复已解除實例。E-12 CSRUtil L1545–1555/L1613–1625，FLOW-09/10、AC-20。
