# AF-AFY10400：翻新執行與追蹤 v1

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

### 5.1 实際局部TODO位置核對

以下位置表由完成后的设计／common／API／handoff／DESIGN文件逐行回读生成；每列给真实行号及实际锚点，含DATA/ST，而不是仅依預期索引。共用CMP-PAGE对所有UI/ST传播TODO-05/06已明記，避免将未知全域影响消失。位置核對不能代表缺失依赖已完整盘点。

| TODO | 实際文件与位置／ID | 实際TODO锚点 | 计划／决策 | 回读 |
| --- | --- | --- | --- | --- |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L13：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；ACT-01 為頁面使用者，可新增、刪除及匯出；ACT-02 為入口生命週期；ACT-03 為服務回應；ACT-04 為外層通知／政策情境。來源沒有證明本頁可取代服務端授權。[TODO-04](../ |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L25：DATA-03 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ DATA-03 ／ 有序被保人列集合 ／ 初始 0 列；每列 ID 文字最多 10 字、保單多行文字無來源最大長度；新增空列、刪除只移除指定列；匯出有列時兩者皆不得精確空字串；前端不 trim、不 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L26：DATA-04 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ DATA-04 ／ 每個被保人的結果文字映射 ／ 回應後以當時現有列的當時 ID 找結果；成功與拒絕均填；新增列結果為空，既有結果不因修改輸入、重新送出、增刪其他列自動清除 ／ E-04/05；[ |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L27：DATA-05 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ DATA-05 ／ 匯出檔名與下載交接資訊 ／ 成功回應帶檔名，先回填列再立即交接下載；前端不自產檔名、日期或加密路徑 ／ E-05/17；[TODO-02](../../renovation/A |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L27：DATA-05 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ DATA-05 ／ 匯出檔名與下載交接資訊 ／ 成功回應帶檔名，先回填列再立即交接下載；前端不自產檔名、日期或加密路徑 ／ E-05/17；[TODO-02](../../renovation/A |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L28：DATA-06 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ DATA-06 ／ 入口／非同步訊息、底部旗標 ／ 入口描述、編號、系統、類型、URL、回傳碼、異常为有序集合；含換行与空值正規化；底部回復旗標消费後清空 ／ E-09/11；[TODO-01]( |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L28：DATA-06 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ DATA-06 ／ 入口／非同步訊息、底部旗標 ／ 入口描述、編號、系統、類型、URL、回傳碼、異常为有序集合；含換行与空值正規化；底部回復旗標消费後清空 ／ E-09/11；[TODO-01]( |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L29：DATA-07 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ DATA-07 ／ 可信功能政策、員工識別、服務端時間 ／ 決定列印／複製政策及浮水印；不得成為可任填產品欄位 ／ E-06/07/08；[TODO-04](../../renovation/AF |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L29：DATA-07 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ DATA-07 ／ 可信功能政策、員工識別、服務端時間 ／ 決定列印／複製政策及浮水印；不得成為可任填產品欄位 ／ E-06/07/08；[TODO-04](../../renovation/AF |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L30：DATA-08 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ DATA-08 ／ 複製去重記錄與獨立到期事件 ／ 去除連續空白后的上次全文；不同非空复制建立獨立 60 秒到期，舊到期不取消 ／ E-07；[TODO-04](../../renovation/ |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L37：BOUND-01, FLOW-04, DATA-01, DATA-03, FLOW-05 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ BOUND-01 ／ FLOW-04 檢查通过，向匯出責任者交付 DATA-01/02 及 DATA-03 两个有序並行集合；換行保持每列多筆語意 ／ FLOW-05 逐列回填；檔案查詢／生成責任 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L37：BOUND-01, FLOW-04, DATA-01, DATA-03, FLOW-05 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ BOUND-01 ／ FLOW-04 檢查通过，向匯出責任者交付 DATA-01/02 及 DATA-03 两个有序並行集合；換行保持每列多筆語意 ／ FLOW-05 逐列回填；檔案查詢／生成責任 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L38：BOUND-02, FLOW-05, DATA-05 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ BOUND-02 ／ FLOW-05 成功回填後立即交付 DATA-05 ／ 舊交接取得加密資訊後交同頁檔案接收者、不新開視窗；目标已确认直接檔案回應，转换选择未確認 ／ E-05/17/22；[ |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L38：BOUND-02, FLOW-05, DATA-05 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ BOUND-02 ／ FLOW-05 成功回填後立即交付 DATA-05 ／ 舊交接取得加密資訊後交同頁檔案接收者、不新開視窗；目标已确认直接檔案回應，转换选择未確認 ／ E-05/17/22；[ |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L39：BOUND-03, FLOW-08, DATA-08 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ BOUND-03 ／ FLOW-08 啟用政策下复制與上次不同非空内容；传送 DATA-08 内容、功能、原長度、時間 ／ 紀錄接收後的結果未知；不能宣稱稽核已寫入 ／ E-07；[TODO-04 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L40：BOUND-04, DATA-07 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ BOUND-04 ／ 首次載入接收 DATA-07，依政策條件顯示浮水印與全頁限制 ／ 功能設定与浮水印實際輸出未知，條件分支的已知反應保留 ／ E-06/08；[TODO-04](../../r |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L40：BOUND-04, DATA-07 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ BOUND-04 ／ 首次載入接收 DATA-07，依政策條件顯示浮水印與全頁限制 ／ 功能設定与浮水印實際輸出未知，條件分支的已知反應保留 ／ E-06/08；[TODO-04](../../r |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L48：UI-01 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-01 ／ 畫面標題、編號 ／ 無操作；頂部全寬 ／ E-02；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05) 圖片／難 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L49：UI-02 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-02 ／ 公會補通報作業及三條說明 ／ Chrome、組合分次、Enter分隔的原文；红字 Chrome/Enter ／ E-03；[TODO-05](../../renovation/AF |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L50：UI-03, DATA-01 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-03 ／ 收承方式選項 ／ DATA-01；標籤／值区各 20% ／ E-03；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L51：UI-04, DATA-02 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-04 ／ 商品屬性選項 ／ DATA-02；標籤20%、值40% ／ E-03；[TODO-05](../../renovation/AF-AFY10400/tracking.md#todo |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L52：UI-05, FLOW-02 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-05 ／ 被保人 ID 標題内「新增一列」 ／ FLOW-02；沒有自動聚焦依據 ／ E-01/03；[TODO-05](../../renovation/AF-AFY10400/track |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L53：UI-06, FLOW-03 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-06 ／ 每列「刪除此列」 ／ FLOW-03；無確認提示；其他列保持 ／ E-01；[TODO-05](../../renovation/AF-AFY10400/tracking.md#t |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L54：UI-07 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-07 ／ ID 输入、保單多行输入 ／ ID size12、max10；保單 rows3 cols30；不默认修剪 ／ E-01/04；[TODO-05](../../renovation/ |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L55：UI-08, DATA-04 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-08 ／ 每列匯出結果 ／ DATA-04；按回應時現有 ID；原呈現容許换行標記 ／ E-05；[TODO-02](../../renovation/AF-AFY10400/trackin |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L55：UI-08, DATA-04 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-08 ／ 每列匯出結果 ／ DATA-04；按回應時現有 ID；原呈現容許换行標記 ／ E-05；[TODO-02](../../renovation/AF-AFY10400/trackin |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L56：UI-09, FLOW-04 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-09 ／ 「匯出檔案」与等待遮罩 ／ FLOW-04；等待遮罩阻隔指標，未禁用控制／未增加取消操作 ／ E-03/11；[TODO-05](../../renovation/AF-AFY10 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L57：UI-10, FLOW-06 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-10 ／ 原生提示、条件自訂「網頁訊息／確定」 ／ FLOW-06/09/10；底部為外部元件，不自創本頁區塊 ／ E-09/11/12；[TODO-01](../../renovation |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L57：UI-10, FLOW-06 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-10 ／ 原生提示、条件自訂「網頁訊息／確定」 ／ FLOW-06/09/10；底部為外部元件，不自創本頁區塊 ／ E-09/11/12；[TODO-01](../../renovation |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L57：UI-10, FLOW-06 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-10 ／ 原生提示、条件自訂「網頁訊息／確定」 ／ FLOW-06/09/10；底部為外部元件，不自創本頁區塊 ／ E-09/11/12；[TODO-01](../../renovation |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L57：UI-10, FLOW-06 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-07](#todo-07) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ UI-10 ／ 原生提示、条件自訂「網頁訊息／確定」 ／ FLOW-06/09/10；底部為外部元件，不自創本頁區塊 ／ E-09/11/12；[TODO-01](../../renovation |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L59：CMP-PAGE, CMP-FORM, CMP-COVER, CMP-MESSAGE, CMP-ENTRY | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；所有 UI 的載入副作用亦受 [TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06) 未解碼依賴影响，此為共用 CMP-PAGE 定義的 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L59：CMP-PAGE, CMP-FORM, CMP-COVER, CMP-MESSAGE, CMP-ENTRY | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；所有 UI 的載入副作用亦受 [TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06) 未解碼依賴影响，此為共用 CMP-PAGE 定義的 |
| TODO-06 | [specification.md](../../design/AF-AFY10400/specification.md) L59：CMP-PAGE, CMP-FORM, CMP-COVER, CMP-MESSAGE, CMP-ENTRY | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-06](#todo-06) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；所有 UI 的載入副作用亦受 [TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06) 未解碼依賴影响，此為共用 CMP-PAGE 定義的 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L59：CMP-PAGE, CMP-FORM, CMP-COVER, CMP-MESSAGE, CMP-ENTRY | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-07](#todo-07) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；所有 UI 的載入副作用亦受 [TODO-06](../../renovation/AF-AFY10400/tracking.md#todo-06) 未解碼依賴影响，此為共用 CMP-PAGE 定義的 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L70：ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；狀態為可组合描述，不假定每次只有一个。ST-01 無列；ST-02 至少一列可编辑；ST-03 活動請求／遮罩顯示；ST-04 列结果已回填；ST-05 原生／自訂／外部訊息；ST-06 政策／浮水印 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L70：ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；狀態為可组合描述，不假定每次只有一个。ST-01 無列；ST-02 至少一列可编辑；ST-03 活動請求／遮罩顯示；ST-04 列结果已回填；ST-05 原生／自訂／外部訊息；ST-06 政策／浮水印 |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L70：ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；狀態為可组合描述，不假定每次只有一个。ST-01 無列；ST-02 至少一列可编辑；ST-03 活動請求／遮罩顯示；ST-04 列结果已回填；ST-05 原生／自訂／外部訊息；ST-06 政策／浮水印 |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L70：ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；狀態為可组合描述，不假定每次只有一个。ST-01 無列；ST-02 至少一列可编辑；ST-03 活動請求／遮罩顯示；ST-04 列结果已回填；ST-05 原生／自訂／外部訊息；ST-06 政策／浮水印 |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L70：ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；狀態為可组合描述，不假定每次只有一个。ST-01 無列；ST-02 至少一列可编辑；ST-03 活動請求／遮罩顯示；ST-04 列结果已回填；ST-05 原生／自訂／外部訊息；ST-06 政策／浮水印 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L70：ST-01, ST-02, ST-03, ST-04, ST-05, ST-06, CMP-PAGE | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-07](#todo-07) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；狀態為可组合描述，不假定每次只有一个。ST-01 無列；ST-02 至少一列可编辑；ST-03 活動請求／遮罩顯示；ST-04 列结果已回填；ST-05 原生／自訂／外部訊息；ST-06 政策／浮水印 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L81：TR-08, ST-04, ST-05, FLOW-05 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ TR-08 ／ 舊拒絕回應 ／ 回填、无下載 → 共用完成訊息；ST-04 可叠 ST-05 ／ FLOW-05/06、E-05/11；[TODO-02](../../renovation/AF- |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L82：TR-09, FLOW-06 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ TR-09 ／ 已解析回應缺失／HTTP失败／回呼例外 ／ 无已知正常回填保证，进入共用完成或診斷分支；未知結果不命名成功 ／ FLOW-06、E-10/11；[TODO-03](../../re |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L83：TR-10, FLOW-01 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ TR-10 ／ 入口回復旗標 ／ 清旗標后停止，無入口警示 ／ FLOW-01、E-09；[TODO-01](../../renovation/AF-AFY10400/tracking.md#to |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L85：TR-12, ST-06, FLOW-08 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ TR-12 ／ 啟用政策下全頁事件／copy 到期 ／ 阻断或轨迹交接、独立清去重；ST-06 ／ FLOW-08、E-07；[TODO-04](../../renovation/AF-AFY10 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L89：BR-01, BR-02, BR-03, BR-04, BR-05, BR-06 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；BR-01：逐列按順序，先检查本列任一值精確等於空字串；成立就原生提示并停止；不将全空白當前端空字串。BR-02：當前列非空後立即与其后各列 ID 精確比对；相同就提示并停止，因此首列 A、第二列 A |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L95：MSG-03 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ MSG-03 ／ 入口／異步动态訊息原文及前缀，逐條见共用契約；不以「成功／失敗」替代 ／ E-09/11；[TODO-01](../../renovation/AF-AFY10400/track |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L95：MSG-03 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ MSG-03 ／ 入口／異步动态訊息原文及前缀，逐條见共用契約；不以「成功／失敗」替代 ／ E-09/11；[TODO-01](../../renovation/AF-AFY10400/track |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L97：MSG-05 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ MSG-05 ／ 「依據資安政策，不開放列印功能」「依據資安政策，不開放剪下功能」「依據資安政策，不開放全選功能」「依據資安政策，不開放頁面儲存功能」；copy 的 Ctrl+Q 說明在來源字典中 |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L104：FLOW-01, CMP-ENTRY, ST-01 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-01 ／ ACT-02 首次進入；尚未接受使用者事件 ／ 初始化列計數及表格參照 → CMP-ENTRY；PageUI 条件外部初始化与resize注册；同頁没有绑定快捷键 ／ ST-0 |
| TODO-06 | [specification.md](../../design/AF-AFY10400/specification.md) L104：FLOW-01, CMP-ENTRY, ST-01 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-06](#todo-06) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-01 ／ ACT-02 首次進入；尚未接受使用者事件 ／ 初始化列計數及表格參照 → CMP-ENTRY；PageUI 条件外部初始化与resize注册；同頁没有绑定快捷键 ／ ST-0 |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L107：FLOW-04, UI-09, ST-01, BR-01, BR-02, BOUND-01, MSG-01, ST-03, FLOW-07 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-04 ／ ACT-01 UI-09，ST-01/02，可包含旧结果 ／ BR-01 → 当前列 BR-02 → 下一列；第一命中停止；全部或0列通過则 BOUND-01，遮罩与活动記錄； |
| TODO-02 | [specification.md](../../design/AF-AFY10400/specification.md) L108：FLOW-05, BOUND-01, ST-03, BOUND-02, ST-04 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-05 ／ ACT-03 BOUND-01 旧响应，ST-03；捕捉到的列集合仍反映当前画面 ／ success／拒絕均依當時 ID 填當時列结果；success填完才 BOUND-02； |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L109：FLOW-06, CMP-REQUEST, FLOW-05, ST-03 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-06 ／ ACT-03 请求创建、完成、傳輸／回呼异常 ／ 完整 Prototype/jQuery、底部、系统模式、原生／自訂、EP、空描述、长編號、文字响应、诊断顺序引用 CMP-RE |
| TODO-03 | [specification.md](../../design/AF-AFY10400/specification.md) L109：FLOW-06, CMP-REQUEST, FLOW-05, ST-03 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-06 ／ ACT-03 请求创建、完成、傳輸／回呼异常 ／ 完整 Prototype/jQuery、底部、系统模式、原生／自訂、EP、空描述、长編號、文字响应、诊断顺序引用 CMP-RE |
| TODO-01 | [specification.md](../../design/AF-AFY10400/specification.md) L110：FLOW-07 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-07 ／ 全文檔冒泡按鈕／submit點擊 ／ 本按钮反應後清底部；自訂確定停止冒泡所以不清；清除錯誤吞下 ／ 本页資料不變；底部受接收者负责 ／ E-09/12；[TODO-01](. |
| TODO-04 | [specification.md](../../design/AF-AFY10400/specification.md) L111：FLOW-08, CMP-POLICY, MSG-05, BOUND-03 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-08 ／ ACT-02/01，政策启用时載入、全页键盘/剪贴/右键/列印與到期 ／ CMP-POLICY；full body/window 捕获，copy独立计时與原序编码 ／ 阻断MS |
| TODO-05 | [specification.md](../../design/AF-AFY10400/specification.md) L111：FLOW-08, CMP-POLICY, MSG-05, BOUND-03 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-08 ／ ACT-02/01，政策启用时載入、全页键盘/剪贴/右键/列印與到期 ／ CMP-POLICY；full body/window 捕获，copy独立计时與原序编码 ／ 阻断MS |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L112：FLOW-09, ST-05, CMP-MESSAGE | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-07](#todo-07) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-09 ／ ACT-03 自訂訊息顯示／ACT-01 首key或確定，ST-05 ／ CMP-MESSAGE 正規化、去重、增長、重定位、聚焦；每个keypress先自除、首键是否关闭；確 |
| TODO-07 | [specification.md](../../design/AF-AFY10400/specification.md) L113：FLOW-10 | [實際位置](../../design/AF-AFY10400/specification.md) → [TODO-07](#todo-07) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ FLOW-10 ／ ACT-01 自訂标题按下→document移动→放開 ／ 保存偏移、拖曳框、隐藏真視窗、放開复位与解除／重建监听 ／ 視窗移動；不改訊息累積或資料 ／ E-12；[TODO- |
| TODO-01 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L17：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；全文件點擊的實際目標，其 type 在 button,submit 中匹配時，嘗試清除底部通知；包含新增、刪除、匯出，發生在按鈕本身反應後的冒泡階段；清除介接異常被吞下。自訂訊息確認按鈕停止冒泡， |
| TODO-03 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L17：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；全文件點擊的實際目標，其 type 在 button,submit 中匹配時，嘗試清除底部通知；包含新增、刪除、匯出，發生在按鈕本身反應後的冒泡階段；清除介接異常被吞下。自訂訊息確認按鈕停止冒泡， |
| TODO-01 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L23：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；完成處理先讀回應；沒有解析物件且有文字時從精確 <body> 區段取文字，僅 <br> 轉換為換行，沒有 body 開頭則用整段；這是代碼 -1 的錯誤訊息。接著活動記錄減一、調整遮罩、清除本 |
| TODO-03 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L32：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；描述」。選用情境未知 [TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)，已知分支不可省略。E-11/13。 |
| TODO-03 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L34：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；沒有 Prototype 而有 jQuery 的分支先共用／替代遮罩；HTTP 成功但沒有舊訊息時不呼叫本頁回呼；錯誤先顯示 WIUtil／原生訊息（長編號 >17 前綴沒有「訊息說明：」），再成功／ |
| TODO-07 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L49：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-07](#todo-07) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；標題按下時暫停新的按下監聽，保存指標相對视窗偏移、建立同寬高位置的拖曳框並註冊 document 移動／放開；移動阻斷事件、框隨偏移移動、真視窗移出；放開時解除兩監聽、取框位置移動真視窗、移除框、重新 |
| TODO-04 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L53：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；功能資訊查詢可帶出 print/download 政策及浮水印開關；本頁是否啟用不能從名稱推論。[TODO-04](../../renovation/AF-AFY10400/tracking.md#t |
| TODO-05 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L55：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；浮水印已知傳入可信員工識別（為空則名稱、再空文字）、服務端時間；同源 mainFrame 重設功能清單；條件啟用時選擇 root、記錄功能 ID、設置多行、190×85、20 行高、黑色、16px、M |
| TODO-02 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L59：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；成功回填之後，同步送出檔名取得下載資訊；收到舊成功訊息時，將加密下載檔名及完整路徑交給隱藏的 POST 表單，false 表示不建立新視窗；接收者責任到表單送出為止。若取得失敗，本頁沒有另加逐列或通用 |
| TODO-04 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L59：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；成功回填之後，同步送出檔名取得下載資訊；收到舊成功訊息時，將加密下載檔名及完整路徑交給隱藏的 POST 表單，false 表示不建立新視窗；接收者責任到表單送出為止。若取得失敗，本頁沒有另加逐列或通用 |
| TODO-01 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L63：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；E-14：PageUI load 只在存在外部 init 時調用，注册 resize；本頁沒有建立它的 table 或 overDiv，故這兩種 resize 會直接停止，不生成另一個畫面殼。未知外部 |
| TODO-05 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L63：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；E-14：PageUI load 只在存在外部 init 時調用，注册 resize；本頁沒有建立它的 table 或 overDiv，故這兩種 resize 會直接停止，不生成另一個畫面殼。未知外部 |
| TODO-06 | [common-contracts.md](../../design/AF-AFY10400/common-contracts.md) L63：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/common-contracts.md) → [TODO-06](#todo-06) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；E-14：PageUI load 只在存在外部 init 時調用，注册 resize；本頁沒有建立它的 table 或 overDiv，故這兩種 resize 會直接停止，不生成另一個畫面殼。未知外部 |
| TODO-03 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L23：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) → [TODO-03](#todo-03) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-03](../../. |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L23：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-03](../../. |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) L23：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/components/CMP-MESSAGE/DESIGN.md) → [TODO-07](#todo-07) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-03](../../. |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L25：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-05](../../. |
| TODO-06 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L25：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) → [TODO-06](#todo-06) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-05](../../. |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) L25：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/components/CMP-PAGE/DESIGN.md) → [TODO-07](#todo-07) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-05](../../. |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L30：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-05](../../. |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) L30：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/components/CMP-FORM/DESIGN.md) → [TODO-07](#todo-07) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-05](../../. |
| TODO-05 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L14：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) → [TODO-05](#todo-05) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-05](../../. |
| TODO-07 | [DESIGN.md](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) L14：共用契約／樣式條件 | [實際位置](../../design/AF-AFY10400/components/CMP-COVER/DESIGN.md) → [TODO-07](#todo-07) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：[TODO-05](../../. |
| TODO-04 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L7：共用契約／樣式條件 | [實際位置](../../integration/AF-AFY10400/api-spec.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；指定 backend_root=inputs/backend；基準 inputs/backend/docs/OPENAPI.md，SHA-256 13307ed1144946124179d6 |
| TODO-02 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L14：共用契約／樣式條件 | [實際位置](../../integration/AF-AFY10400/api-spec.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ msg ／ string，必填 ／ 預設success；錯誤为動態原因；舊描述呈現需映射，尚未确认各前缀相容 ／ E-21；[TODO-02](../../renovation/AF-AFY104 |
| TODO-02 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L15：共用契約／樣式條件 | [實際位置](../../integration/AF-AFY10400/api-spec.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ data ／ any或null，必填 ／ 成功各操作payload；错误null，非旧ErrMsg+頂層payload ／ E-21；[TODO-02](../../renovation/AF-A |
| TODO-04 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L17：共用契約／樣式條件 | [實際位置](../../integration/AF-AFY10400/api-spec.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；全域錯誤仍 HTTP 200 OK + code500，不用 HTTP200 推论业务成功；此系现況相容契約。其他未定 HTTP／传输错误的呈現不自创 fallback。重送、幂等、交易原子性、逾時／ |
| TODO-02 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L36：DATA-03 | [實際位置](../../integration/AF-AFY10400/api-spec.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ I_ID ／ array<string>，非必填；缺省/null/空集合后端結果未完整规定 ／ DATA-03，有序各列ID ／ 根頁真正送出來源是表单列，不是未使用param；前端不trim，不 |
| TODO-02 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L37：DATA-03 | [實際位置](../../integration/AF-AFY10400/api-spec.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ POLICY_NO ／ array<string>，非必填；索引与I_ID相對应；缺省/null/空集合未完整規定 ／ DATA-03，有序每列保單多行文字 ／ 舊序列化LF→CRLF，方法語意用 |
| TODO-02 | [api-spec.md](../../integration/AF-AFY10400/api-spec.md) L45：共用契約／樣式條件 | [實際位置](../../integration/AF-AFY10400/api-spec.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；／ code/msg/data ／ 上述必填envelope ／ code200选择目标成功、code500错误；旧CSR code0/ErrMsg不能直接消费；[TODO-02](../../ren |
| TODO-02 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L8：FLOW-05, BOUND-01, DATA-01, DATA-04, API-03 | [實際位置](../../integration/AF-AFY10400/backend-handoff.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；FLOW-05/BOUND-01，輸入為DATA-01/02/03；回應拒絕時先按當時列的當時ID回填DATA-04，然後共用完成訊息，绝不下載。E-05，根 L107-113；legacy 方法在错 |
| TODO-02 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L13：FLOW-05, BOUND-02, DATA-05, API-02, API-04 | [實際位置](../../integration/AF-AFY10400/backend-handoff.md) → [TODO-02](#todo-02) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；FLOW-05/BOUND-02，在成功回填全部列之后以服务回传檔名DATA-05交接；旧RPTUtil同步取得加密下载檔名/路径，再同頁隐藏表单提交，isOpenNewBrowse=false。E- |
| TODO-04 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L13：FLOW-05, BOUND-02, DATA-05, API-02, API-04 | [實際位置](../../integration/AF-AFY10400/backend-handoff.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；FLOW-05/BOUND-02，在成功回填全部列之后以服务回传檔名DATA-05交接；旧RPTUtil同步取得加密下载檔名/路径，再同頁隐藏表单提交，isOpenNewBrowse=false。E- |
| TODO-01 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L18：FLOW-01, BOUND-03, DATA-06 | [實際位置](../../integration/AF-AFY10400/backend-handoff.md) → [TODO-01](#todo-01) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；LOGIC-04/05/06、FLOW-01/08、BOUND-03/04、DATA-06/07/08。首次渲染前由共用tag設定資源／dispatcher；功能資訊提供政策及浮水印，session提 |
| TODO-04 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L18：FLOW-01, BOUND-03, DATA-06 | [實際位置](../../integration/AF-AFY10400/backend-handoff.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；LOGIC-04/05/06、FLOW-01/08、BOUND-03/04、DATA-06/07/08。首次渲染前由共用tag設定資源／dispatcher；功能資訊提供政策及浮水印，session提 |
| TODO-04 | [backend-handoff.md](../../integration/AF-AFY10400/backend-handoff.md) L25：API-01 | [實際位置](../../integration/AF-AFY10400/backend-handoff.md) → [TODO-04](#todo-04) | TASK-08／DEC-04 | 已逐行回讀存在，V-05；需要核对目标业务版本：是否保留逐列查询結果与缺少资料、服务日期檔名、查询前每ID稽核、Excel54栏与日期/time转换及异常责任。未提供事务／回滚保证，不推导新原子性要求。E-23自身例子檔名使用 |

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
