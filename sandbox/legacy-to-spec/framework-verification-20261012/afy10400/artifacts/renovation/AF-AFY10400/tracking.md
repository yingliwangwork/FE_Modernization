# AF-AFY10400：翻新執行與追蹤 v2

第1–8節保留初輪記錄（局部位置表已修復引用）；初輪關於中立化／靜態檢查的主張受F-05/07及引用缺陷修正，不代表當時已完整通過。第9節是本輪審查引導續作。初輪所有原件與失敗報告保留於本case inputs/previous-artifacts及inputs/review-*；未讀取舊case。

## 1. 本輪來源與邊界

| 項目 | 實際內容 |
| --- | --- |
| 唯一根入口／scope | `inputs/frontend/sourceCode/AF/AFY10400.jsp`／AF-AFY10400 |
| 根入口版本 | SHA-256 `fbf8f94aee2f03f830f5092ba280dca6f6707ce45d54a929e6ec7cecd4284b1a`，與manifest核對 |
| 编码与行号 | root声明BIG5；CP950 strict valid，中文可读，采用CP950；原始246物理行、CRLF。每个依赖独立inventory，未改原件；date未确认 |
| 日期／执行者 | 2026-10-12，Codex AF forward-test agent；先行plan 2026-10-12T11:11:15.113914+00:00 |
| 纳入 | 唯一入口、直接及必要间接依赖的本頁契約、兩API投影、四CMP样式、离线原型、已辨识生命周期与副作用 |
| 排除 | 另一入口内部、所有库非本頁调用分支、真实后台运行、正式下载／日志、部署；不能读其他case／外部系统 |
| 後端基準 | `inputs/backend/docs/OPENAPI.md`，指定SNAPSHOT现況盘点，默认stub，非正式部署证据；legacy specs只辅助語意 |
| 本輪狀態 | 部分交付：TODO-01..07，缺少依赖、目标映射差距、必要浏览器／正式服务验证未完成 |
| 连结 | [plan](plan.md)、[設計](../../design/AF-AFY10400/specification.md)、[共用契約](../../design/AF-AFY10400/common-contracts.md)、[API](../../integration/AF-AFY10400/api-spec.md)、[handoff](../../integration/AF-AFY10400/backend-handoff.md) |
| 本輪性质 | 首次独立forward test；只由本case快照生成，没有读取前一轮产物或测试scenario |

### 个别来源bytes与编碼

[source-inventory.json](source-inventory.json) 为所附helper实际输出（每檔严格解码、hash、原始行数与行尾）。前端可读者选择CP950、後端UTF-8；严格可解码是候选事实、不是自动证明所有file声明相同。date两候选皆invalid，列TODO-06。没有转码覆盖输入。根script仅在checks/生成UTF-8分析副本，行号仍回查原始246行。

| 来源 | SHA-256 | 原始行数 | 严格候选／实际语义选择 |
| --- | --- | --- | --- |
| `inputs/frontend/sourceCode/AF/AFY10400.jsp` | `fbf8f94aee2f03f830f5092ba280dca6f6707ce45d54a929e6ec7cecd4284b1a` | 246 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/header.jsp` | `60508a333aa5411f59f252489e4ec50746a8ff84103c0083d777ec1b7283d44d` | 413 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/msgDisplayer.jsp` | `e39c5526a4ee108bcd8561716ca1e25324e8ad12e3743b13681193c42c9a1ec6` | 188 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/css/cm.css` | `92b0ad8c25e35c47d46e6f79391803f5f414046faa731712aa7f8478bfee535f` | 957 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/js/ajax/prototype.js` | `f727ce3e418c76558c3882064c7b0b4743cd1bcef0e25ebd19d807ad47850636` | 7745 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/js/ajax/CSRUtil.js` | `d71734e1cd4ec8cd978020cc670101de9b86ff70a96c0daf4c8d875d065a28e6` | 2638 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/js/ui/PageUI.js` | `d733b2884aaf5f6853e4ea75f253117bf72940d0f6c725b4cce71ba18d814f74` | 3428 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/js/HotKey.js` | `7501d3cdd52084dec29be7a18b6b5b232de4fa11447c7a7742a4f7f12b94576d` | 107 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/js/Validator.js` | `ed58fa05914cfa71b96ef79f47ecfa7dfa0c1622393fcc958bb658dcc41d77be` | 372 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/js/RPTUtil.js` | `0b54b047139f08ba233019885d102e095f48d92936a43c536ace524f397638e3` | 764 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/js/calendar.js` | `f39aadb9e108b0aea6ccf6f192cd601c0bc7eed1ea80a4ec7aee8faf1149d778` | 1430 | CP950有效，中文语义可读；UTF-8无效 |
| `inputs/frontend/sourceCode/CM/js/date.js` | `acf6883faeb16f97739af0f13b4a29940be97514b10e93fea39ba6dd7f214185` | 1089 | 未确认（UTF-8/CP950均无效） |
| `inputs/backend/docs/OPENAPI.md` | `13307ed1144946124179d6e02148999e64783e031d440aacc8ff54e03c32f1ef` | 751 | UTF-8有效，本文可读 |
| `inputs/backend/docs/specs/AFY1_0400/AFY1_0400_doPrompt.md` | `082f353e384c1bc2484e07aacfaa57536f53b813fe080df8378e3009a5cb38fc` | 35 | UTF-8有效，本文可读 |
| `inputs/backend/docs/specs/AFY1_0400/AFY1_0400_doExport.md` | `8ed2021657fc3f391f71deb9a556c71919ba06cd469781566e22ef07aface20e` | 515 | UTF-8有效，本文可读 |
| `inputs/backend/docs/specs/AFY1_0400/AFY1_0400_doDownload.md` | `1d07fcd0946717298ce25263901cebc369aa8db7c035efcbed16600d998d1d2c` | 46 | UTF-8有效，本文可读 |

## 2. 计划执行、依赖边界

DEP-01..15的查找／决策详见[plan依赖表](plan.md#2-依賴與契約查找)。实际只分析本页调用所需部分；E表记录精确范围。缺CSS/font/image/watermark/WIUtil/frame/tag/utility/功能及session提供方没有快照，停止于呼叫端，不推测内部。inputs/specs不存在；既有可复用内容为后端指定基准及legacy方法文档，并核对分工。沙盒DEC-01来自task，DEC-02复用、DEC-03先必要可取得、DEC-04延後缺少；正式扩展未授权。

| TASK | 实际执行与交付 | 验证／限制 |
| --- | --- | --- |
| TASK-01/02 | 先plan，再root/metadata/依赖盘点及有限契約搜寻；DEP表，DEC-01..04 | V-01/02；未知未暗中完整化 |
| TASK-03 | 共用契約先于root规格：entry/request/message/policy/download/载入边界 | E-06..20；日曆内部等有依据不纳入 |
| TASK-04 | specification技术中立FLOW/BR/TR/DATA/UI、AC、局部TODO | V-03/05；必要未知仍开 |
| TASK-05 | API-01/02精确消费；4 HANDOFF保留拒絕/下載/可信上下文/业务副作用 | V-03，正式介接未执行 |
| TASK-06 | SCR-01，四DESIGN及实載CSS；審閱层与產品层分離 | V-04/05；computed/visual未測 |
| TASK-07 | helper metadata、原始root脚本+DOM/transport替身比较、Node模型、结构/链接/封闭性 | V-01..05，实际范围详报告 |
| TASK-08 | TODO后续资料与验证条件逐项记录 | 延后；不能以文件产生结束缺口 |

## 3. 證據登錄

各源版本见上表；以下链接定位快照，range采用原始bytes physical lines，没有逐字copy个人资料。源代码证据证明源码定义、不是运行观察。

| E | 类型／来源及行号 | 最小事实／支撑ID | 限制 |
| --- | --- | --- | --- |
| <a id="e-01"></a>E-01 | 原始碼／文件；[AFY10400.jsp](../../../inputs/frontend/sourceCode/AF/AFY10400.jsp)，21–65、116–124 | 空列新增、单调列识别、删除、按显示位置交错颜色；FLOW-01/02/03、BR-04、DATA-03/09 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-02"></a>E-02 | 原始碼／文件；[AFY10400.jsp](../../../inputs/frontend/sourceCode/AF/AFY10400.jsp)，128–188、231–246 | 单頁标题／編號／主框、圖片、表单位置；SCR-01、UI-01/02、CMP-PAGE | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-03"></a>E-03 | 原始碼／文件；[AFY10400.jsp](../../../inputs/frontend/sourceCode/AF/AFY10400.jsp)，189–230 | 三条说明、L/R及AT/BG/CB选项、空表标题、新增与匯出；INT-01、UI-03/04/05/09、DATA-01/02、ST-01 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-04"></a>E-04 | 原始碼／文件；[AFY10400.jsp](../../../inputs/frontend/sourceCode/AF/AFY10400.jsp)，67–97 | 逐列先空值后前后精确重复、停止、实际Form.serialize而非unused param；BR-01/02/03、FLOW-04、BOUND-01、DATA-03 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-05"></a>E-05 | 原始碼／文件；[AFY10400.jsp](../../../inputs/frontend/sourceCode/AF/AFY10400.jsp)，98–114 | 两回呼取当时现有列ID回填；成功回填後下載false、拒絕無下載；FLOW-05、DATA-04/05、BOUND-02、TR-07/08 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-06"></a>E-06 | 原始碼／文件；[header.jsp](../../../inputs/frontend/sourceCode/CM/header.jsp)，1–66 | 共用tag設定資源、字符bytes默认2、可選utility保持时间／平台参数；LOGIC-04、FLOW-01、TODO-01/04 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-07"></a>E-07 | 原始碼／文件；[header.jsp](../../../inputs/frontend/sourceCode/CM/header.jsp)，70–264 | 功能设置、政策全页capture；copy去重、独立60秒、裁切编码、外部轨迹；CMP-POLICY、FLOW-08、DATA-07/08、BOUND-03 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-08"></a>E-08 | 原始碼／文件；[header.jsp](../../../inputs/frontend/sourceCode/CM/header.jsp)，266–413 | 可信识别與server时间、字体路径／条件浮水印、frame生命周期與拼字；DATA-07、BOUND-04、ST-06、HANDOFF-03 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-09"></a>E-09 | 原始碼／文件；[msgDisplayer.jsp](../../../inputs/frontend/sourceCode/CM/msgDisplayer.jsp)，1–188 | 入口7字段正規化、底部寻找顺序、回復flag、0/99、原生/WIUtil、全document清底部；CMP-ENTRY、FLOW-01/07、DATA-06、MSG-03 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-10"></a>E-10 | 原始碼／文件；[prototype.js](../../../inputs/frontend/sourceCode/CM/js/ajax/prototype.js)，1695–1749、1934–1997、6468–6532 | 活動請求數、回呼先于完成、例外dispatch、序列化字段及LF→CRLF；FLOW-04/05/06、BOUND-01、AC-06/08 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-11"></a>E-11 | 原始碼／文件；[CSRUtil.js](../../../inputs/frontend/sourceCode/CM/js/ajax/CSRUtil.js)，15–29、154–333、371–745、2620–2638 | 旧ErrMsg/代碼0、遮罩、Prototype/jQuery分支、所有完成／异常和通知；CMP-COVER/REQUEST、FLOW-06、MSG-03/06 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-12"></a>E-12 | 原始碼／文件；[CSRUtil.js](../../../inputs/frontend/sourceCode/CM/js/ajax/CSRUtil.js)，1409–1696 | 自訂訊息正規化去重、独立首keypress、尺寸增长、聚焦、确认、拖曳生命周期；CMP-MESSAGE、FLOW-09/10、ST-05 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-13"></a>E-13 | 原始碼／文件；[CSRUtil.js](../../../inputs/frontend/sourceCode/CM/js/ajax/CSRUtil.js)，2509–2594 | 按当前location系统正則选择、資源root推导；CMP-REQUEST、TODO-03 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-14"></a>E-14 | 原始碼／文件；[PageUI.js](../../../inputs/frontend/sourceCode/CM/js/ui/PageUI.js)，1106–1269、1662–1781 | load仅调用存在的init、resize注册；未构造内部table/overDiv则停止；FLOW-01、排除额外畫面殼 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-15"></a>E-15 | 原始碼／文件；[HotKey.js](../../../inputs/frontend/sourceCode/CM/js/HotKey.js)，58–107 | 初始空映射、document keydown；root没有binding调用；FLOW-01，不添加功能键 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-16"></a>E-16 | 原始碼／文件；[Validator.js](../../../inputs/frontend/sourceCode/CM/js/Validator.js)，1–29、定义索引至372；root1–246无调用 | 日期验证函数定义／库；本頁没有Validator调用；不升格格式验证BR，有限盘点 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-17"></a>E-17 | 原始碼／文件；[RPTUtil.js](../../../inputs/frontend/sourceCode/CM/js/RPTUtil.js)，15–66、67–188、204–245、656–689 | 依CSR成功、同步下載資訊、Safari顺序、ZR/ZRB接收者、false不新窗、隐藏form；CMP-DOWNLOAD、BOUND-02、HANDOFF-02 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-18"></a>E-18 | 原始碼／文件；[calendar.js](../../../inputs/frontend/sourceCode/CM/js/calendar.js)，1–50；root无日曆调用 | 可插入calendar CSS；根頁不调用创建日历；TODO-05及排除日曆內部 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-19"></a>E-19 | 原始碼／文件；[date.js](../../../inputs/frontend/sourceCode/CM/js/date.js)，原始bytes inventory，1089 physical lines | UTF-8 invalid offset8、CP950 invalid offset40；未用替代解碼；TODO-06；不能声明无载入副作用 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-20"></a>E-20 | 原始碼／文件；[cm.css](../../../inputs/frontend/sourceCode/CM/css/cm.css)，1–15、63–71、108–124、162–200、260–284、449–452、542–545、687–698 | 实际匹配字体/字段/button最终padding/表格/颜色/margin/状态；CMP-PAGE/FORM、STYLE、AC-18；缺后载CSS | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-21"></a>E-21 | 原始碼／文件；[OPENAPI.md](../../../inputs/backend/docs/OPENAPI.md)，1–67、741–751 | SNAPSHOT、stub、JSON通用ReturnMsg/code200/错误HTTP200code500data null、Unicode、Auth未知；API共通；TODO-02/04 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-22"></a>E-22 | 原始碼／文件；[OPENAPI.md](../../../inputs/backend/docs/OPENAPI.md)，85–87、500–567 | export平行数组/map/檔名、prompt未消费、download JSON/form/binary/stubheader；API-01/02、BOUND-01/02；TODO-02/04 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-23"></a>E-23 | 原始碼／文件；[AFY1_0400_doExport.md](../../../inputs/backend/docs/specs/AFY1_0400/AFY1_0400_doExport.md)，1–264、xlsx说明与字段表及轉換章節（共515行） | legacy匯出語意、逐列結果、CRLF、日志、六组合查询、54栏xlsx及异常；HANDOFF-01/04；不是target HTTP实证 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-24"></a>E-24 | 原始碼／文件；[AFY1_0400_doPrompt.md](../../../inputs/backend/docs/specs/AFY1_0400/AFY1_0400_doPrompt.md)，1–35 | legacy初始化日期及固定flags；root不消费；排除新增产品初始化控制 | 仅来源条件，不证明环境存在／已部署／像素一致 |
| <a id="e-25"></a>E-25 | 原始碼／文件；[AFY1_0400_doDownload.md](../../../inputs/backend/docs/specs/AFY1_0400/AFY1_0400_doDownload.md)，1–46 | legacyfileName、可信目录、加密下载寫resp、错误ReturnMessage；HANDOFF-02、不是target wire | 仅来源条件，不证明环境存在／已部署／像素一致 |

## 4. 来源到契约覆盖

| 源位置／事件 | E | 契约／原型 | 案例／处理 |
| --- | --- | --- | --- |
| root1-18：directives、includes、CSS/scripts | E-06..20 | CMP/common-contracts/plan DEP | TODO-01/03/04/05/06：缺间接来源；原型不载入legacy未知资源 |
| root21-31：计数初始化与displayMessage | E-01/09 | FLOW-01、DATA-09、ST-01；root初始 | AC-01/10，TODO-01/06 |
| root33-65、116-124：新增、删除、动态html／交错 | E-01 | FLOW-02/03、UI-05/06/07/08、DATA-03 | AC-02 |
| root67-94：两选项、数组准备、逐列检查顺序 | E-04 | FLOW-04、BR-01/02/03、DATA-01/02/03 | AC-03/04/05 |
| root95-97：真正序列化/post；param只是未用构造 | E-04/10 | BOUND-01、API-01 | AC-06、API-01/02；没有table1数组wire |
| root98-114：当前live列表回填两分支、成功先填再下载 | E-05/17 | FLOW-05、TR-07/08、DATA-04/05、BOUND-02 | AC-07/08/09；TODO-02/04 |
| root128-188：title、编号、frame、form、icons | E-02/20 | SCR-01、UI-01/02、CMP-PAGE | AC-01/18；TODO-05缺图片字体 |
| root189-230：说明、值/顺序、空数据表、匯出 | E-03/20 | UI-02..09、ST-01、CMP-FORM | AC-01/02/18 |
| root231-246：close markup | E-02 | SCR-01 | legacy没有明确form close；DOM等价需浏览器，TODO-07 |
| header1-66：tag／utility/byte default | E-06 | LOGIC-04、FLOW-01、common契約 | TODO-01/04；不把charBytes2升为ID验证 |
| header70-264：policy选择、全page events、independent copy timer/record | E-07 | FLOW-08、DATA-07/08、BOUND-03、ST-06 | AC-15/16；TODO-04 |
| header266-413：session/time、EUDC、watermark、frame & unload typo | E-08 | BOUND-04、DATA-07、ST-06、CMP-PAGE | TODO-04/05/07；已知参数留共用契約 |
| msg1-188：七字段、入口/底部/flag/0/99/WIUtil、document.onclick | E-09 | CMP-ENTRY、FLOW-01/07、MSG-03、DATA-06 | AC-10/17；TODO-01/03 |
| prototype serializers + responder order/count | E-10 | FLOW-04/05/06、DATA-03、TR-09 | AC-06/08/11；Node替身只验证已列部分 |
| CSR success／missing json、jQuery/Prototype branches、create/complete/text/exception/longid/system/EP | E-11/13 | CMP-REQUEST/COVER、FLOW-06、MSG-03/06、ST-03/05 | AC-11；TODO-01/03/05/07 |
| CSR MsgWin full lifecycle、first any key、close/reopen、dedup/width/drag | E-12 | FLOW-09/10、CMP-MESSAGE | AC-12/13/14；模型仅一部，browser未测 |
| RPT judge/Safari/ZR/ZRB/sync/form | E-17 | BOUND-02、CMP-DOWNLOAD、HANDOFF-02 | AC-API-04/05；TODO-02/04 |
| PageUI init-if-present + resize guards，HotKey empty，Validator only definitions | E-14/15/16 | common-contracts有限用法 | 不添加新页面框／功能键／证号验证；外部initTODO-01 |
| calendar loaded CSS but no root日曆，date无法解码 | E-18/19 | CMP-PAGE所有UI共用缺口 | TODO-05/06；不宣称完整cascade或无副作用 |
| cm CSS matching rules、final :root button、native inputs | E-20 | four DESIGN/css STYLE rows | AC-18；V-04结构不是computed |
| OPENAPI common+AFY10400 & legacy method sources | E-21..25 | API-01/02及HANDOFF；prompt只解释不消费 | AC-API-01..06；未真实HTTP |

不报告全系统覆盖率。分母仅上表20项已盘点来源组；每组有契約或具体TODO，未知依赖仍未完成内部盘点，不能因此声称完整根入口。

### 4.1 混合責任拆解

| LOGIC | 触发／数据／原顺序 | 分类与前端去向 | 目标承接／缺口 |
| --- | --- | --- | --- |
| LOGIC-01 | 首次计数/table→消息；增删→重排 | 呈现及生命周期，FLOW-01/02/03 | 前端E-01/09；入口来源TODO-01 |
| LOGIC-02 | 收承／商品与有序列→空值／重复判定→请求 | 操作呈現檢查与业务语义界线；FLOW-04/BR、API-01 | UI檢查不替代后端；target业务细节HANDOFF-04/ TODO-02/04 |
| LOGIC-03 | 外部两类响应→当时列回填→成功下载→complete消息 | 混合呈現與外部file副作用；FLOW-05/06、BOUND-01/02 | E-22 successmap；拒绝data null/直接binary差距HANDOFF-01/02、TODO-02 |
| LOGIC-04 | 共用tag及utility参数／入口msgs→load使用 | 受信任情境與呈現分離；DATA-06/07、FLOW-01 | tag/utility/入口机制缺失，HANDOFF-03、TODO-01/04 |
| LOGIC-05 | 功能policy→全页事件→copy去重及独立timer→encoded交接 | UI限制属前端，配置与审计记录属外部后端；FLOW-08、BOUND-03 | HANDOFF-03，TODO-04；不把img request当写入成功 |
| LOGIC-06 | session员工/时间→条件watermark/rootframe/font | 可信上下文及条件呈現；DATA-07/BOUND-04 | HANDOFF-03，TODO-04/05；不硬编用户和当天日期 |
| LOGIC-07 | 请求创建／结果／body异常→活动遮罩／message／first key／drag | 呈现与回應生命周期，FLOW-06/09/10 | 前端源E-10/11/12；外部底部/WIUtil未知TODO-01/03，runtimeTODO-07 |
| LOGIC-08 | legacy后台日志→查询→结果→可信日期file→xlsx→加密信息 | 业务、信任与file副作用；保留BOUND结果要求 | legacy语义E-23/25不证明target承接，HANDOFF-04／TODO-04 |

### 4.2 API／移交與樣式

API-01/02实际投影逐wire及envelope核對E-21/22；未把legacy文件升格目标字段。HANDOFF-01..04状态均待承接或确认差异，不因文件生成关闭TODO。styles各元件采用内建component模板的必要信息，profile design-md、无DTCG；selection角色、hash见 [template-selection](template-selection.json)。原型实载四产品CSS与单独reviewCSS，STYLE逐selector/property存在；产物hash在 [artifact-inventory.json](artifact-inventory.json)。所附metadata helper仅形状检查，不是完整官方validator；未browse任何官方格式页面，尊重禁止外連。

## 5. TODO与后续

<a id="todo-01"></a>
### TODO-01

| 字段 | 内容 |
| --- | --- |
| 类型／状态 | 缺少依賴／开启 |
| 具体问题 | 入口ReturnMessage合法来源、外部bottomFrame视觉及show/clear/rollback flag、CXL/utility/可能init內部未提供。 |
| 已知事实 | E-06/09/14；呼叫端反應已保留。 |
| 影响 | CMP-ENTRY、FLOW-01/06/07、DATA-06、ST-05、UI-10、TR-10、HANDOFF-03 |
| 下一可执行动作 | 取得同版本tag/utility/init/入口提供方与bottomFrame快照；先依赖契约，再更新本页受影响处。 |
| 解決条件 | 来源与合法情境确认、AC-10/11/17实际可重现。 |
| 计划／決策／后续顺序 | [TASK-08／DEC](plan.md#3-任務與影響)：DEP-01/02/05/13；TASK-08；DEC-04；取得依赖先确认其契約，再更新所有局部位置及受影响AC |
| 解决纪录 | 尚未解决；文档生成、合成响应或模型测试不关闭缺口 |

<a id="todo-02"></a>
### TODO-02

| 字段 | 内容 |
| --- | --- |
| 类型／状态 | 契约差距／开启 |
| 具体问题 | 目标code200+ReturnMsg及error data=null与旧ErrMsg+returnCode0/拒绝map不同；直接binary与旧加密链不同；Unicode文字呈现与legacybr、数组空值/换行具体接受不完整。 |
| 已知事实 | E-04/05/10/17/21/22/23；不自造旧schema、fallback或目标adapter。 |
| 影响 | FLOW-04/05、BOUND-01/02、DATA-03/04/05、UI-08、ST-04、TR-07/08、BR-05、API-01/02、HANDOFF-01/02/04 |
| 下一可执行动作 | 取得目标Service/错误与兼容消费设计，明确保留或变更逐列拒绝/下载/文本体验；不指定新端点。 |
| 解決条件 | 权威承接/确认纪录 + AC-06..09/AC-API-01..06，成功、错误、数组、换行及文件测试。 |
| 计划／決策／后续顺序 | [TASK-08／DEC](plan.md#3-任務與影響)：DEP-03/08/14/15；TASK-08；DEC-02/04；取得依赖先确认其契約，再更新所有局部位置及受影响AC |
| 解决纪录 | 尚未解决；文档生成、合成响应或模型测试不关闭缺口 |

<a id="todo-03"></a>
### TODO-03

| 字段 | 内容 |
| --- | --- |
| 类型／状态 | 缺少依赖／选用情境未知／开启 |
| 具体问题 | 系统location branch、实际jQuery/Prototype是否成功、WIUtil内外訊息；入口与request模式不同、bottom接收者有无不可推定。 |
| 已知事实 | E-09/11/13；保留所有已知长msgid、EP、success空消息、onException、text fallback分支。 |
| 影响 | CMP-REQUEST/MESSAGE/ENTRY、FLOW-06/09、DATA-06、UI-10、ST-05、TR-09、MSG-03/06 |
| 下一可执行动作 | 取得部署上下文／script加载与WIUtil快照，选择实际情境；仍保留条件分支。 |
| 解決条件 | AC-10/11覆盖所有条件，原型可验证确切已选用情境。 |
| 计划／決策／后续顺序 | [TASK-08／DEC](plan.md#3-任務與影響)：DEP-02/04/13；TASK-08；DEC-04；取得依赖先确认其契約，再更新所有局部位置及受影响AC |
| 解决纪录 | 尚未解决；文档生成、合成响应或模型测试不关闭缺口 |

<a id="todo-04"></a>
### TODO-04

| 字段 | 内容 |
| --- | --- |
| 类型／状态 | 受信任情境／后端未确认承接／开启 |
| 具体问题 | 功能配置、policy/watermark开关、session员工/可信时间、copy记录接收者、下载正式adapter/header与错误、legacy查询/日志/54栏xlsx运行与Auth正式契约未提供。 |
| 已知事实 | E-06/07/08/17/21/22/23/25；未知不说未部署。 |
| 影响 | ACT-04、FLOW-08、BOUND-01/02/03/04、DATA-05/07/08、ST-06、CMP-POLICY、MSG-05、API-01/02、HANDOFF-02/03/04 |
| 下一可执行动作 | 取得同版本配置、合法可信上下文、服务承接／审核记录；以接口或适用后台契約承接，不从前端任填。 |
| 解決条件 | AC-API后端执行记录、AC-15/16情境与copy记录可观察；正式下载/异常与稽核有证据。 |
| 计划／決策／后续顺序 | [TASK-08／DEC](plan.md#3-任務與影響)：DEP-01/08/12/13/14/15；TASK-08；DEC-04；取得依赖先确认其契約，再更新所有局部位置及受影响AC |
| 解决纪录 | 尚未解决；文档生成、合成响应或模型测试不关闭缺口 |

<a id="todo-05"></a>
### TODO-05

| 字段 | 内容 |
| --- | --- |
| 类型／状态 | 缺少视觉依賴／开启 |
| 具体问题 | 边框/icons/blank/buttonfallback、cover PNG/loading GIF、EUDC字体、watermark库与calendar插入CSS皆未提供，不能确认完整cascade或像素。 |
| 已知事实 | E-02/08/11/18/20；已知CSS値照交付，不假设后载CSS无影响。 |
| 影响 | CMP-PAGE/FORM/COVER/MESSAGE、UI-01..10、ST-03/05/06、DATA-07、FLOW-08/10 |
| 下一可执行动作 | 取得对应版本图像/font/watermark/calendarCSS，只补受影响styles契约和原型。 |
| 解決条件 | 真实资源本地可载、各状态computed/几何及样式冲突重新检查；AC-18。 |
| 计划／決策／后续顺序 | [TASK-08／DEC](plan.md#3-任務與影響)：DEP-09/11/12；TASK-08；DEC-04；取得依赖先确认其契約，再更新所有局部位置及受影响AC |
| 解决纪录 | 尚未解决；文档生成、合成响应或模型测试不关闭缺口 |

<a id="todo-06"></a>
### TODO-06

| 字段 | 内容 |
| --- | --- |
| 类型／状态 | 编码／未知载入副作用／开启 |
| 具体问题 | date.js UTF-8及CP950严格解碼均失败；不能按字面推断作用或删去全页载入行为。 |
| 已知事实 | E-19；1089 raw physical lines；两invalid byte offsets已保留。 |
| 影响 | CMP-PAGE（共用所有UI/ST）、FLOW-01、AC-01 |
| 下一可执行动作 | 取得正确编码声明／可strict解码同版本来源或逐bytes可定位原件；先查top-level副作用与本页关联。 |
| 解決条件 | 源码可读且无replacement，映射被影响契約后重跑AC-01与相关生命周期／样式。 |
| 计划／決策／后续顺序 | [TASK-08／DEC](plan.md#3-任務與影響)：DEP-10；TASK-08；DEC-04；取得依赖先确认其契約，再更新所有局部位置及受影响AC |
| 解决纪录 | 尚未解决；文档生成、合成响应或模型测试不关闭缺口 |

<a id="todo-07"></a>
### TODO-07

| 字段 | 内容 |
| --- | --- |
| 类型／状态 | 必要执行验证未完成／开启 |
| 具体问题 | 本agent未运行浏览器原型／computed/drag/keypress传播/真实60s timer；未取得legacy执行画面；没有正式HTTP服务、file/audit环境。 |
| 已知事实 | V-03只Node root+替身/model；metadata不是fidelity验证。 |
| 影响 | 所有SCR/ST/UI/CMP、FLOW-06/08/09/10、AC-10..18、AC-API全体 |
| 下一可执行动作 | 在受允本地浏览器环境开离线原型，逐状态computed与操作并截图；正式介接需适用环境，不查询沙盒外系统。 |
| 解決条件 | 实际浏览器V记录與相关AC通过；后端环境另明确标注，不以浏览器local成功当介接成功。 |
| 计划／決策／后续顺序 | [TASK-08／DEC](plan.md#3-任務與影響)：TASK-07/08；DEC-04延后环境缺口；取得依赖先确认其契約，再更新所有局部位置及受影响AC |
| 解决纪录 | 尚未解决；文档生成、合成响应或模型测试不关闭缺口 |

### 5.1 實際局部TODO位置核對（v2回讀）

以下表由目前設計／共用／介接／樣式正文回讀，僅列實際存在的局部引用；行號是當前版本定位，證據內容未截成殘缺Markdown。來源行上的ID不是自動推導完整影響閉包；TODO-05/06透過CMP-PAGE明示作用於全頁的UI/ST，未取得依賴仍未完整盤點。初輪位置表的未閉合引用原件保留在輸入快照，V-05初輪PASS不足以證明其可渲染。

| TODO | 目前實際文件及行位置 | 該行TODO的有效追蹤錨點 | 計劃／決策 | 實際回讀 |
| --- | --- | --- | --- | --- |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L13；共用條件／本行正文 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L25；DATA-03 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L26；DATA-04 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L27；DATA-05 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L27；DATA-05 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L28；DATA-06 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L28；DATA-06 | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L29；DATA-07 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L29；DATA-07 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L30；DATA-08 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L37；BOUND-01, FLOW-04, DATA-01, DATA-03, FLOW-05 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L37；BOUND-01, FLOW-04, DATA-01, DATA-03, FLOW-05 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L38；BOUND-02, FLOW-05, DATA-05 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L38；BOUND-02, FLOW-05, DATA-05 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L39；BOUND-03, FLOW-08, DATA-08 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L40；BOUND-04, DATA-07 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L40；BOUND-04, DATA-07 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L48；UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L49；UI-02 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L50；UI-03, DATA-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L51；UI-04, DATA-02 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L52；UI-05, FLOW-02 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L53；UI-06, FLOW-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L54；UI-07 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L55；UI-08, DATA-04 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L55；UI-08, DATA-04 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L56；UI-09, FLOW-04 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L57；UI-10, FLOW-06 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L57；UI-10, FLOW-06 | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L57；UI-10, FLOW-06 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L57；UI-10, FLOW-06 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L59；CMP-PAGE, CMP-FORM, CMP-COVER, CMP-MESSAGE, CMP-ENTRY | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L59；CMP-PAGE, CMP-FORM, CMP-COVER, CMP-MESSAGE, CMP-ENTRY | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [specification.md](../../design/AF-AFY10400/specification.md) L59；CMP-PAGE, CMP-FORM, CMP-COVER, CMP-MESSAGE, CMP-ENTRY | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L59；CMP-PAGE, CMP-FORM, CMP-COVER, CMP-MESSAGE, CMP-ENTRY | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L70；ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L70；ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L70；ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L70；ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L70；ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L70；ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L81；TR-08, ST-04, ST-05, FLOW-05 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L82；TR-09, FLOW-06 | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L83；TR-10, FLOW-01 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L85；TR-12, ST-06, FLOW-08 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L89；BR-01, BR-02, BR-03, BR-04, BR-05, BR-06 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L95；MSG-03 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L95；MSG-03 | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L97；MSG-05 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L104；FLOW-01, CMP-ENTRY, ST-01 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [specification.md](../../design/AF-AFY10400/specification.md) L104；FLOW-01, CMP-ENTRY, ST-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L107；FLOW-04, UI-09, ST-01, BR-01, BR-02, BOUND-01, MSG-01, ST-03, FLOW-07 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L108；FLOW-05, BOUND-01, ST-03, BOUND-02, ST-04 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L109；FLOW-06, CMP-REQUEST, FLOW-05, ST-03 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L109；FLOW-06, CMP-REQUEST, FLOW-05, ST-03 | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L110；FLOW-07 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L111；FLOW-08, CMP-POLICY, MSG-05, BOUND-03 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L111；FLOW-08, CMP-POLICY, MSG-05, BOUND-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L112；FLOW-09, ST-05, CMP-MESSAGE | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L113；FLOW-10 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L139；AC-19 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L140；AC-20 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L141；AC-21 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L9；共用條件／本行正文 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L9；共用條件／本行正文 | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L13；共用條件／本行正文 | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L17；共用條件／本行正文 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L21；共用條件／本行正文 | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L27；FLOW-06, AC-19 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L37；AC-20 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L41；共用條件／本行正文 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L43；共用條件／本行正文 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L45；共用條件／本行正文 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L49；共用條件／本行正文 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L49；共用條件／本行正文 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L53；共用條件／本行正文 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L53；共用條件／本行正文 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L53；共用條件／本行正文 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-03 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L23；共用條件／本行正文 | [TODO-03](#todo-03)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L23；共用條件／本行正文 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L23；共用條件／本行正文 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L45；STYLE-MESSAGE-01, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L46；STYLE-MESSAGE-02, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L47；STYLE-MESSAGE-03, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L48；STYLE-MESSAGE-04, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L49；STYLE-MESSAGE-05, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L50；STYLE-MESSAGE-06, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L51；STYLE-MESSAGE-07, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L52；STYLE-MESSAGE-08, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L53；STYLE-MESSAGE-09, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L54；STYLE-MESSAGE-10, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L55；STYLE-MESSAGE-11, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L56；STYLE-MESSAGE-12, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L57；STYLE-MESSAGE-13, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L58；STYLE-MESSAGE-14, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L59；STYLE-MESSAGE-15, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L60；STYLE-MESSAGE-16, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L61；STYLE-MESSAGE-17, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L62；STYLE-MESSAGE-18, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L63；STYLE-MESSAGE-19, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L64；STYLE-MESSAGE-20, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L65；STYLE-MESSAGE-21, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L66；STYLE-MESSAGE-22, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L67；STYLE-MESSAGE-23, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L68；STYLE-MESSAGE-24, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L69；STYLE-MESSAGE-25, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L70；STYLE-MESSAGE-26, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L71；STYLE-MESSAGE-27, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L72；STYLE-MESSAGE-28, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L73；STYLE-MESSAGE-29, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L74；STYLE-MESSAGE-30, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L75；STYLE-MESSAGE-31, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L76；STYLE-MESSAGE-32, CMP-MESSAGE, UI-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L77；STYLE-MESSAGE-33, CMP-MESSAGE, FLOW-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L78；STYLE-MESSAGE-34, CMP-MESSAGE, FLOW-10, ST-05 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L25；共用條件／本行正文 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L25；共用條件／本行正文 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L25；共用條件／本行正文 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L47；STYLE-PAGE-01, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L47；STYLE-PAGE-01, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L47；STYLE-PAGE-01, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L48；STYLE-PAGE-02, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L48；STYLE-PAGE-02, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L48；STYLE-PAGE-02, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L49；STYLE-PAGE-03, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L49；STYLE-PAGE-03, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L49；STYLE-PAGE-03, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L50；STYLE-PAGE-04, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L50；STYLE-PAGE-04, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L50；STYLE-PAGE-04, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L51；STYLE-PAGE-05, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L51；STYLE-PAGE-05, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L51；STYLE-PAGE-05, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L52；STYLE-PAGE-06, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L52；STYLE-PAGE-06, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L52；STYLE-PAGE-06, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L53；STYLE-PAGE-07, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L53；STYLE-PAGE-07, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L53；STYLE-PAGE-07, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L54；STYLE-PAGE-08, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L54；STYLE-PAGE-08, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L54；STYLE-PAGE-08, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L55；STYLE-PAGE-09, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L55；STYLE-PAGE-09, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L55；STYLE-PAGE-09, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L56；STYLE-PAGE-10, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L56；STYLE-PAGE-10, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L56；STYLE-PAGE-10, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L57；STYLE-PAGE-11, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L57；STYLE-PAGE-11, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L57；STYLE-PAGE-11, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L58；STYLE-PAGE-12, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L58；STYLE-PAGE-12, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L58；STYLE-PAGE-12, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L59；STYLE-PAGE-13, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L59；STYLE-PAGE-13, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L59；STYLE-PAGE-13, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L60；STYLE-PAGE-14, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L60；STYLE-PAGE-14, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L60；STYLE-PAGE-14, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L61；STYLE-PAGE-15, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L61；STYLE-PAGE-15, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L61；STYLE-PAGE-15, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L62；STYLE-PAGE-16, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L62；STYLE-PAGE-16, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L62；STYLE-PAGE-16, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L63；STYLE-PAGE-17, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L63；STYLE-PAGE-17, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L63；STYLE-PAGE-17, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L64；STYLE-PAGE-18, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L64；STYLE-PAGE-18, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L64；STYLE-PAGE-18, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L65；STYLE-PAGE-19, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L65；STYLE-PAGE-19, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L65；STYLE-PAGE-19, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L66；STYLE-PAGE-20, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L66；STYLE-PAGE-20, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L66；STYLE-PAGE-20, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L67；STYLE-PAGE-21, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L67；STYLE-PAGE-21, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L67；STYLE-PAGE-21, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L68；STYLE-PAGE-22, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L68；STYLE-PAGE-22, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L68；STYLE-PAGE-22, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L69；STYLE-PAGE-23, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L69；STYLE-PAGE-23, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L69；STYLE-PAGE-23, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L70；STYLE-PAGE-24, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L70；STYLE-PAGE-24, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L70；STYLE-PAGE-24, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L71；STYLE-PAGE-25, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L71；STYLE-PAGE-25, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L71；STYLE-PAGE-25, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L72；STYLE-PAGE-26, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L72；STYLE-PAGE-26, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L72；STYLE-PAGE-26, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L73；STYLE-PAGE-27, CMP-PAGE, FLOW-08, MSG-05, ST-06 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L73；STYLE-PAGE-27, CMP-PAGE, FLOW-08, MSG-05, ST-06 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L73；STYLE-PAGE-27, CMP-PAGE, FLOW-08, MSG-05, ST-06 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L74；STYLE-PAGE-28, CMP-PAGE, FLOW-08, MSG-05, ST-06 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L74；STYLE-PAGE-28, CMP-PAGE, FLOW-08, MSG-05, ST-06 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L74；STYLE-PAGE-28, CMP-PAGE, FLOW-08, MSG-05, ST-06 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L75；STYLE-PAGE-29, CMP-PAGE, FLOW-08, MSG-05, ST-06 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L75；STYLE-PAGE-29, CMP-PAGE, FLOW-08, MSG-05, ST-06 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L75；STYLE-PAGE-29, CMP-PAGE, FLOW-08, MSG-05, ST-06 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L76；STYLE-PAGE-30, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L76；STYLE-PAGE-30, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L76；STYLE-PAGE-30, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L77；STYLE-PAGE-31, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L77；STYLE-PAGE-31, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L77；STYLE-PAGE-31, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L78；STYLE-PAGE-32, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L78；STYLE-PAGE-32, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L78；STYLE-PAGE-32, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L79；STYLE-PAGE-33, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L79；STYLE-PAGE-33, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L79；STYLE-PAGE-33, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L80；STYLE-PAGE-34, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L80；STYLE-PAGE-34, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L80；STYLE-PAGE-34, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L81；STYLE-PAGE-35, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L81；STYLE-PAGE-35, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L81；STYLE-PAGE-35, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L82；STYLE-PAGE-36, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L82；STYLE-PAGE-36, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L82；STYLE-PAGE-36, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L83；STYLE-PAGE-37, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L83；STYLE-PAGE-37, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L83；STYLE-PAGE-37, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L84；STYLE-PAGE-38, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L84；STYLE-PAGE-38, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L84；STYLE-PAGE-38, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L85；STYLE-PAGE-39, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L85；STYLE-PAGE-39, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L85；STYLE-PAGE-39, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L86；STYLE-PAGE-40, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L86；STYLE-PAGE-40, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L86；STYLE-PAGE-40, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L87；STYLE-PAGE-41, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L87；STYLE-PAGE-41, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L87；STYLE-PAGE-41, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L88；STYLE-PAGE-42, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L88；STYLE-PAGE-42, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L88；STYLE-PAGE-42, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L89；STYLE-PAGE-43, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L89；STYLE-PAGE-43, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L89；STYLE-PAGE-43, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L90；STYLE-PAGE-44, CMP-PAGE, UI-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L90；STYLE-PAGE-44, CMP-PAGE, UI-01 | [TODO-06](#todo-06)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L90；STYLE-PAGE-44, CMP-PAGE, UI-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L30；共用條件／本行正文 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L30；共用條件／本行正文 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L52；STYLE-FORM-01, CMP-FORM, UI-03, UI-10, ST-01, CMP-PAGE | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L52；STYLE-FORM-01, CMP-FORM, UI-03, UI-10, ST-01, CMP-PAGE | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L53；STYLE-FORM-02, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L53；STYLE-FORM-02, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L54；STYLE-FORM-03, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L54；STYLE-FORM-03, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L55；STYLE-FORM-04, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L55；STYLE-FORM-04, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L56；STYLE-FORM-05, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L56；STYLE-FORM-05, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L57；STYLE-FORM-06, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L57；STYLE-FORM-06, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L58；STYLE-FORM-07, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L58；STYLE-FORM-07, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L59；STYLE-FORM-08, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L59；STYLE-FORM-08, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L60；STYLE-FORM-09, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L60；STYLE-FORM-09, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L61；STYLE-FORM-10, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L61；STYLE-FORM-10, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L62；STYLE-FORM-11, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L62；STYLE-FORM-11, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L63；STYLE-FORM-12, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L63；STYLE-FORM-12, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L64；STYLE-FORM-13, UI-03, UI-08, CMP-FORM | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L64；STYLE-FORM-13, UI-03, UI-08, CMP-FORM | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L65；STYLE-FORM-14, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L65；STYLE-FORM-14, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L66；STYLE-FORM-15, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L66；STYLE-FORM-15, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L67；STYLE-FORM-16, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L67；STYLE-FORM-16, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L68；STYLE-FORM-17, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L68；STYLE-FORM-17, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L69；STYLE-FORM-18, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L69；STYLE-FORM-18, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L70；STYLE-FORM-19, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L70；STYLE-FORM-19, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L71；STYLE-FORM-20, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L71；STYLE-FORM-20, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L72；STYLE-FORM-21, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L72；STYLE-FORM-21, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L73；STYLE-FORM-22, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L73；STYLE-FORM-22, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L74；STYLE-FORM-23, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L74；STYLE-FORM-23, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L75；STYLE-FORM-24, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L75；STYLE-FORM-24, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L76；STYLE-FORM-25, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L76；STYLE-FORM-25, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L77；STYLE-FORM-26, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L77；STYLE-FORM-26, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L78；STYLE-FORM-27, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L78；STYLE-FORM-27, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L79；STYLE-FORM-28, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L79；STYLE-FORM-28, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L80；STYLE-FORM-29, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L80；STYLE-FORM-29, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L81；STYLE-FORM-30, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L81；STYLE-FORM-30, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L82；STYLE-FORM-31, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L82；STYLE-FORM-31, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L83；STYLE-FORM-32, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L83；STYLE-FORM-32, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L84；STYLE-FORM-33, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L84；STYLE-FORM-33, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L85；STYLE-FORM-34, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L85；STYLE-FORM-34, CMP-FORM, UI-03, UI-10, ST-01, STYLE-FORM-37 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L86；STYLE-FORM-35, CMP-FORM, UI-03, UI-10, ST-01, STYLE-MESSAGE | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L86；STYLE-FORM-35, CMP-FORM, UI-03, UI-10, ST-01, STYLE-MESSAGE | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L87；STYLE-FORM-36, UI-10, CMP-FORM | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L87；STYLE-FORM-36, UI-10, CMP-FORM | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L88；STYLE-FORM-37, UI-10, CMP-FORM | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L88；STYLE-FORM-37, UI-10, CMP-FORM | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L89；STYLE-FORM-38, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L89；STYLE-FORM-38, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L90；STYLE-FORM-39, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L90；STYLE-FORM-39, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L91；STYLE-FORM-40, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L91；STYLE-FORM-40, CMP-FORM, UI-03, UI-10, ST-01 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L14；共用條件／本行正文 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L14；共用條件／本行正文 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L36；STYLE-COVER-01, CMP-COVER, UI-09, ST-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L36；STYLE-COVER-01, CMP-COVER, UI-09, ST-03 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L37；STYLE-COVER-02, CMP-COVER, UI-09, ST-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L37；STYLE-COVER-02, CMP-COVER, UI-09, ST-03 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L38；STYLE-COVER-03, CMP-COVER, UI-09, ST-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L38；STYLE-COVER-03, CMP-COVER, UI-09, ST-03 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L39；STYLE-COVER-04, CMP-COVER, UI-09, ST-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L39；STYLE-COVER-04, CMP-COVER, UI-09, ST-03 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L40；STYLE-COVER-05, CMP-COVER, UI-09, ST-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L40；STYLE-COVER-05, CMP-COVER, UI-09, ST-03 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L41；STYLE-COVER-06, CMP-COVER, UI-09, ST-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L41；STYLE-COVER-06, CMP-COVER, UI-09, ST-03 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L42；STYLE-COVER-07, CMP-COVER, UI-09, ST-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L42；STYLE-COVER-07, CMP-COVER, UI-09, ST-03 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L43；STYLE-COVER-08, CMP-COVER, UI-09, ST-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L43；STYLE-COVER-08, CMP-COVER, UI-09, ST-03 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L44；STYLE-COVER-09, CMP-COVER, UI-09, ST-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L44；STYLE-COVER-09, CMP-COVER, UI-09, ST-03 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L45；STYLE-COVER-10, CMP-COVER, UI-09, ST-03 | [TODO-05](#todo-05)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L45；STYLE-COVER-10, CMP-COVER, UI-09, ST-03 | [TODO-07](#todo-07)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L7；共用條件／本行正文 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L14；共用條件／本行正文 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L15；共用條件／本行正文 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L17；共用條件／本行正文 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L36；DATA-03 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L37；DATA-03 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L45；共用條件／本行正文 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L8；FLOW-05, BOUND-01, DATA-01, DATA-04, AC-09, AC-API-03 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-02 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L13；FLOW-05, BOUND-02, DATA-05, AC-07, AC-API-04 | [TODO-02](#todo-02)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L13；FLOW-05, BOUND-02, DATA-05, AC-07, AC-API-04 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-01 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L18；FLOW-01, BOUND-03, DATA-06, AC-10 | [TODO-01](#todo-01)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L18；FLOW-01, BOUND-03, DATA-06, AC-10 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |
| TODO-04 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L25；AC-API-01, AC-09 | [TODO-04](#todo-04)；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |

## 6. 原有缺陷與未批准改良

| 项目 | 原行为／证据 | 提议与决定 |
| --- | --- | --- |
| root构造param未送，form未明确close | E-02/04 | 原型用明確闭合离线markup；不是批准改变browser恢复后行为，DOM等价TODO-07 |
| 空集合可交接、全空白不攔、ID前端仅max10 | E-04 | 不新增至少一列、trim或证号算法；后端接受规则TODO-02/04 |
| 回應讀現有列而非提交snapshot，无stale guard | E-05 | 不自加latest-wins或disable全表；模型保留，browser交错TODO-07 |
| 旧rtnMap innerHTML允许br；目标要求text nodes | E-05/21/23 | 差距TODO-02，不以静默安全整理抹掉已知换行体验 |
| date无法解码 | E-19 | 不宣稱无使用即可删除；TODO-06 |
| watermark berforeunload拼字／挂错回呼、清單splice覆写 | E-08 | 未确认更正，记录原件；庫缺少TODO-05 |
| MsgWin fontWeight尾空格、placeholder结束span、首任意key自除、click未除旧keypress | E-12 | 不宣稱字重bold／改持续Esc；生命週期保留，模型只部分验证 |
| legacy业务sb每列清空后判断无效；日期8位padding与描述/例子差异 | E-23 | 不改业务结果或API schema；HANDOFF-04待确认 |

## 7. 验证实际执行

| V | 检查／環境／操作 | 實際結果与记录 | 判定與限制 |
| --- | --- | --- | --- |
| V-01 | python3所附source_inventory，每个输入UTF8/CP950；manifest全檔hash compare | [source-inventory](source-inventory.json)、[structural-check](structural-check.json) | 编码事实已执行；date invalid与其他未知保留 |
| V-02 | select_templates.py无config，所有内建角色hash | [template-selection](template-selection.json) | 选用成功，不证明必要资料已完整 |
| V-03 | Node --check两个原型js；behavior-check.cjs运行实际root提取脚本，DOM/transport替身比较＋local模型 | [behavior-check](behavior-check.json)；12 tests PASS，运行版本在JSON | 覆盖AC-01..09及模型AC-12/13/16；非浏览器／真实common库、无HTTP／file/audit |
| V-04 | python3 skill/scripts/check_design_metadata.py四DESIGN；现有PyYAML | [design-metadata-check](design-metadata-check.json) PASS | 只name/token mapping/typography keys形状；非官方fullvalidator、非computed fidelity |
| V-05 | structural-check.py：file/hash integrity、占位符、相对链接+显式TODO锚点、HTML IDs/assets/外连、API已确认wire源核對 | [structural-check](structural-check.json) | 实际結果见JSON；静态解析不是浏览器结构恢复／视觉等价 |
| V-06 | 浏览器computed、native alerts、keypress/reopen/drag、fullpage policies及60s真实timer；AC-10..18 | 本agent未执行，受沙盒材料/可用控制限制；parent可另独立检验 | 未执行，TODO-07；未知资源TODO-01/03/05/06仍未闭合 |
| V-07 | 正式/目标HTTP、Auth／service/file/audit业务验证，AC-API | 用户禁止外部系统，仅消费Markdown快照 | 未执行，TODO-02/04/07；部署状态未确认 |

### 交付判定

部分交付。已确认单一入口、先plan、适用后端复用、必要可取得共用片段先转契約、技术中立行为与独立API/handoff、四份样式与实际CSS、局部TODO及12个本地执行检查。缺少必要间接依赖、目标拒绝/下载/可信情境承接、date编码与浏览器／真实服务验证；没有把未知行为默认为成功、把stub当正式可用或写成完整交付。

## 8. 增量

| CHANGE／日期 | 内容 | 来源／证据与验證 |
| --- | --- | --- |
| CHANGE-01，2026-10-12 | plan先于来源依赖分析建立，锁定唯一root与task沙盒授权 | plan创建stdout时间，manifest原版本 |
| CHANGE-02，同日 | 实际DEP／decision补全，先common再root行为契約；生成API/handoff/style/prototype | E-01..25；V-01..05，TODO-01..07保持 |

CHANGE-03：初次靜態檢查582项報4项失败（尚未写出的report/inventory自链接3项，以及把model.submit误判为网络1项）。保留 [first-run](structural-first-run.json)，修正检查器的网络识别边界并在report生成后复查自链接；这不属于产品行为变更。

## 9. 審查引導續作 v2（framework-verification-20261012）

這是有明示審查資訊的維護續作，不是盲測。先讀本case plan/tracking及task，再建立plan第6節，然後回查相同root與共用原件。新版skill hash已锁定；没有新业务／依赖来源。TODO-01..07均保持开启，仅补验证证据，未更改初轮失败为通过。

### 9.1 新增與精確回查證據

<a id="e-26"></a>
E-26：CSRUtil.js，同E-11 SHA-256，原始L321–326，每次createCoverPage建立／取得後先resize，activeElement具type且匹配button才window.focus；异常记录原诊断文字。補 FLOW-06/CMP-COVER/AC-19及LOGIC-07。當次源定義只證明嘗試，不保證OS焦點轉移。

<a id="e-27"></a>
E-27：同E-12來源，原始L1545–1555移動時將win移出文件；L1613–1625首keypress先以該實例自除，!win.parentNode時直接return，未確認也未Event.stop。補 FLOW-09/10/AC-20、LOGIC-07。

<a id="e-28"></a>
E-28：本case提供的 [初輪語意審查](../../../inputs/review-semantic-review.md)、[初輪結構結果](../../../inputs/review-structure.json)、[初輪瀏覽器結果](../../../inputs/review-browser.json)。角色為本地審查／測試者、資料為合成；引導查證但不作產品行為權威。初輪18情境15PASS/3FAIL：確認按鈕被工具攔截、訊息input border solid、結果center。結構26筆跨行引用訊息需回查成因；實際未閉合引用與DEP欄數是確證。來源判定回查E-01/02/03/07/11/12/20。審查原件自己揭露曾誤讀scenario；本續作只讀提供的審查摘要，不讀scenario，不聲稱盲審。

<a id="e-29"></a>
E-29：父代理2026-10-12明示授權讀本case [browser.json](../../../reports/browser.json) 與 [lifecycle-browser.json](../../../reports/lifecycle-browser.json) 後取得的獨立實測。瀏覽器engine151.0.7922.34、viewport1280×900、本地合成情境；18項PASS及2生命週期PASS。焦點觀察只計focus呼叫，拖曳首鍵使用合成事件；不是實際OS焦點或原生Esc相容性的證明。沒有讀／改scenario或其他reports。runtimeHash核對在V-11，DESIGN文件在瀏覽器期間改動，不能引用報告中的舊DESIGN hashes證明最終文件。

<a id="v2-source-mapping"></a>
### 9.2 中立契約與來源符號映射

| 正式行為語意 | 來源實作定位（仅追踪） | 契約與差距 |
| --- | --- | --- |
| 模式A先回填後完成通知 | CSRUtil L479–499、default responder L518–693；Prototype L1934–1964；Prototype存在時被選用 | CMP-REQUEST/FLOW-06；原Prototype符號移出正式契約；TODO-03部署选择未确认 |
| 模式B替代能力先通知再回填 | CSRUtil L373、389–477，!Prototype且jQuery時分支；可enforceUse_jQuery | CMP-REQUEST/FLOW-06；成功／錯誤／無ErrMsg條件与顺序保留；TODO-03 |
| 外部訊息呈現及必要支援 | msgDisplayer L129–133：WIUtil與jQuery均存在；CSR jQuery branch WIUtil條件 | CMP-ENTRY/REQUEST；完整內部TODO-03 |
| 原生／自訂通知及成功僅收遮罩子情境 | CSRUtil L626–680、UICore L2527–2548，location regex L./R./J./DS/DZ/QB/AN/EP/ZU；EP成功特例 | CMP-REQUEST，分支逐一保留，选择未知TODO-03 |
| 全頁按鈕／送出點擊後清底部 | msgDisplayer L174–185，event.target.type與button,submit字串比對；MsgWin確認stopPropagation | FLOW-07；來源字符串细节留此，不加入产品工具的清底部副作用 |
| 本文文字／換行識別 | CSRUtil L562–577使用精確<body>、</body>及<br>；字面反斜線+n的完成描述處理 | CMP-REQUEST结果语义保留；识别严格性留追踪，不要求实现新框架 |
| 外部初始化及共用尺寸反應 | PageUI initLoad L1261–1269：存在window.init才執行；table/overDiv未建立时返回 | FLOW-01，共用契約；外部init來源TODO-01 |
| 空逐列结果目标拒絕 | OPENAPI L47–57的ReturnMsg code500/data=null；旧ErrMsg returnCode0与rtnMap | DATA-04/FLOW-05中立缺口；准确wire只在API/此表 |
| 首鍵／視窗附著 guard | CSRUtil L1613–1625 document keypress，每个keyPressHandler解除自己；parentNode guard | FLOW-09/10/AC-20；runtime保留首次任意键机制 |
| 条件遮罩聚焦嘗試 | CSRUtil L321–326的getAttribute(type)/button matcher/window.focus | FLOW-06/CMP-COVER/AC-19；无新后端责任 |

### 9.3 F-01..08修正及同步

| Finding | 來源與實際修正 | 同步位置／實際驗證 | 剩餘限制 |
| --- | --- | --- | --- |
| F-01 | review層改200，位於來源cover150之上/message999之下，保留原訊息定位公式，不强制click | review.css、原型工具说明；父browser正常確認/重開PASS，V-11 | 所有viewport或任意工具內容尺寸未全測，不宣稱通用幾何等價 |
| F-02 | 全產品input/textarea樣式包含外置message；readonly透明/無border，審閱控制仍分離 | CMP-FORM CSS、STYLE-FORM-01/36/37、UI-10；父browser readonly/ padding PASS，V-09/11 | 实际字型fallback仍受缺font限制，TODO-05 |
| F-03 | 只標題/标签與动态前三格center，結果格不加center | prototype动态cell class、CSS/STYLE-FORM-13、UI-08；父browser result start PASS | 缺后载CSS仍TODO-05，当前source事实不受此掩盖 |
| F-04 | 每次建立／取得遮罩，当时焦点button才window.focus嘗試，异常留诊断 | CMP-COVER/REQUEST、FLOW-06/AC-19/E-26；V-08及父lifecycle观察1次PASS | 只证明调用尝试，OS可见focus未证明，TODO-07 |
| F-05 | 正式spec/common以可觀察資料/触发/结果表达，源符號置9.2、wire在API | 没合并A/B顺序、EP语意、首鍵/全文檔/未知分支；V-10静态词汇核对+人工回读 | 不用token scan宣称所有业务已完整确认 |
| F-06 | 每STYLE给实际token路径或明确无token规则，E/原始範圍/UI/ST/条件逐项；PAGE26改E03、27–29改E07 | 四DESIGN最终metadata PASS、源映射核对V-09/10；DESIGN最后hash另记录 | metadata不是官方全格式或像素validator；browser旧DESIGNhash不覆盖最终doc |
| F-07 | DEP与资源拆为7列表头／分隔，15row一致；未建立API03更正为prompt未消费 | plan、V-10逐行表格计数 | 契约选择与formal扩展仍依DEC沙盒边界 |
| F-08 | 首鍵先自除，仅message.parentNode存在才click與停止；拖曳detached不停止 | prototype、model、CMP-MESSAGE/FLOW-09/10/AC-20/E-27；V-08actual-controller VM、父lifecycle propagation1/defaultPrevented false PASS | 合成keypress不是原生Esc兼容证明 |

父代理補充回查：一度把來源●與缺邊框圖槽混為一項，提出移除；根L143–144明确有●後父代理撤回要求。不是產品變更授權。保留20×24格、align=center、font size=-5；L132–155/179的圖片只保留4×12、12×4、5×1、18×16空槽，不載入未知資源／不補造圖像，缺圖仍TODO-05。TASK-13、E-02與PAGE新增STYLE及STYLE-PAGE-DOT。

### 9.4 本輪驗證與交付判定

| V | 實際操作與證據 | 結果及能證明的範圍 | 限制／歷史 |
| --- | --- | --- | --- |
| V-08 | node --check兩JS；continuation-runtime-check.cjs實际controller在Node VM+明示DOM/focus/event替身；behavior-check.cjs重跑root/model | [五項controller](continuation-runtime-check.json) PASS；[十二項root/model](behavior-check-v2.json) PASS | 非浏览器computed／click/真实OS焦點。旧behavior-check.json保留不覆盖 |
| V-09 | 所附check_design_metadata.py四份最終DESIGN，现有PyYAML | [v2 metadata](design-metadata-check-v2.json) PASS；STYLE逐项E/token映射人工对照源及V-10 | 仅metadata形状，不是完整官方格式validator；旧report保留 |
| V-10 | continuation-document-check.py：manifest、完整单行链接、表格列数、STYLE→CSS/token/source定位、neutral source-symbol边界、TODO/历史、runtime报告hash | [v2文件检查](continuation-document-check.json) 实际结果与范围在JSON | 未安装完整Markdown parser，使用本地单行引用／表格结构检查；不是GFM完整渲染证明；未安装或网络查询 |
| V-11 | 经父授权读两份独立browser实际报告，逐个最终runtimehash比对 | 18/18与2/2 PASS；无runtime errors/HTTP attempts；[browser](../../../reports/browser.json)、[lifecycle](../../../reports/lifecycle-browser.json) | 原报DESIGNhash为文档整理中版本，只有HTML/JS/CSS最终runtimeHash覆盖有效；最終DESIGN靠V-09/10另核对 |

CHANGE-04：新case续作，plan第6节先建立，源版本未变、新skill规定读入、task明示review-guided；F-01..08按原始来源修正、文件同步，旧失败及report保留；CHANGE-05：补标题原文字与缺图空槽，父误判更正，不增加变更授权。

本輪判定仍為部分交付：確證F-01..08已修正並完成所列範圍的实际检查，独立浏览器覆盖已取得；TODO-01..07保持开启（缺少資料、目標契约/可信情境承接、date编码、全部正式服务／视觉等价／浏览器差异未确认）。父浏览器成功不能把未知依赖、真实业务、file/audit或部署改成已确认。初轮18项中的3FAIL仍保留其原版本事实，本轮PASS仅适用本轮runtimehash。

本輪最終封存記錄：V-10首輪新版檢查4584項、0失敗，含77manifest檔、1593單行Markdown引用、44表格、128STYLE宣告與27直接frontmatter token值；[最終產物hash清單](artifact-inventory-v2.json)保存最終DESIGN與runtime版本。既有未知／初輪失敗無關閉或覆寫。最後plan/tracking摘要更新後重跑同一文件檢查，結果另見v2 JSON；檢查數會因新增此引用略增。
