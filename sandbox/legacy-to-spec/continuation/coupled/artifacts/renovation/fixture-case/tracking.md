# fixture-case：翻新執行與持續追蹤

[計劃](plan.md) · [設計](../../design/fixture-case/specification.md) · [API](../../integration/fixture-case/api-spec.md) · [移交](../../integration/fixture-case/backend-handoff.md)。首次交付版本0.1，分析日期2026-10-12，执行者Codex。

## 1. 來源與邊界

唯一根入口：inputs/frontend/Case.jsp，SHA256 `90f46177654b8276566c96686c667dac1352f2a398fae3d7c50ec930636c1154`。編碼UTF-8，LF行尾，原始行号1～60，无转码；全部manifest来源与skill快照雜湊实际核对匹配。Scope明确沿用manifest `fixture-case`。P0先写plan，P1才读取inputs；没有以事后计划伪装先行。

纳入：首次渲染、数量提交分支、查阅触发／回應、共用按钮本页用法、表单guard、明确样式与服务映射。排除：其他入口、完整共用bridge／style转换、Ledger内部、真实执行与部署。后端根inputs/backend，基准为task指定api-contract.md fixture-v1（沙盒测试交付契约、非正式服务、无可呼叫环境），business-rules.md同版语意补充。部署未确认。状态：**部分交付**，必要资料／服务／验证仍有TODO-01～06。

### 快照索引

| 路径 | SHA256 |
| --- | --- |
| inputs/frontend/components/action-bar.jspf | 61f70725865ae2fc7e49b2aea291e420255f4b1e5049728fc48740431871ff9e |
| inputs/frontend/legacy-bridge.js | f008cb043d31d427d923e66ae33e1e98c13dd1dc9dd3f668c2fd3faf72eda09a |
| inputs/frontend/styles/base.css | 447252200c775df2b42ee0656df20334a806d91799a20602cc8f8b71d8debd99 |
| inputs/specs/action-bar.md | ad476cde1e96947d8a96acf928082ab78b796a8c53eb88d9eb6cfc32b5e1e141 |
| inputs/backend/api-contract.md | 04215f381bc195b357b184c89d90e6f4fba521580feb7147c141a25cdb1ca802 |
| inputs/backend/business-rules.md | 35e4253d281cacc662c065ed690337ae8a71f04233df8289c065828aba7614b7 |

直接依赖资源与停止边界见plan P1/P2 DEP-01～07：共用按钮核对版本与本页回呼；CSS仅本页4条规则；bridge仅查阅直接调用；后端仅本操作与业务语意；Ledger与session机制未提供，停止在已知调用。未追查其他系统、其他试用报告或来源外的工具路径。

## 2. 計劃執行索引

TASK-01～03：在P0后盘点与核对，见E／LOGIC；DEC-01／02：仅task.txt明示沙盒模拟延后与重用，正式延后尚无授权。TASK-04／05：生成一个设计规格、一个prototype、一个API投影与一个移交文件。TASK-06：实际检查见V表；TASK-07～10仍延后或未完成。必要未完成项目不影响已知事实部分的文件交付，但不宣告完整翻新。

## 3. 證據登錄

所有以下来源版本对应§1雜湊；源码事实不等于legacy运行观察。未执行legacy。

| E ID | 原始来源定位 | 最小事实与支撑主张 | 限制 |
| --- | --- | --- | --- |
| E-01 | Case.jsp:4、49 | 从session读reviewerLabel，前于提交判断；显示「審閱者：」 | DATA-02、FLOW-01；目标来源及null未知 |
| E-02 | Case.jsp:5～9 | mode=commit；整数解析；quantity≥4乘8否则乘10；Ledger.store(session.unitId,quantity,charge) | FLOW-05、BR-04；仅调用证据，不证明持久化／交易 |
| E-03 | Case.jsp:11～17、47～53 | 标题、关键字maxlength12、include、状态段、三栏表、初始空body | SCR-01、UI-01～06；结构非实测像素 |
| E-04 | Case.jsp:19～21 | 清status→filter.value.trim→LegacyBridge.searchRows | FLOW-02、BR-01；没有取消旧请求代码，不推导服务保证 |
| E-05 | Case.jsp:21～36 | 回應先清rows；DONE填itemKey/itemText/rankHint；NONE「沒有項目」；BLOCK「不允許查閱」；其他不改status | FLOW-03、DATA-03～05、BR-02、MSG-01／02，所有结果分支 |
| E-06 | Case.jsp:38～44、54～58 | 数量精确空串alert「數量不得為空」return false，否则true；post同入口，hidden mode=commit；文字数量输入／按钮 | FLOW-04、DATA-06／09、MSG-03；没有额外UI数字验证或成功反馈 |
| E-07 | action-bar.jspf:1；Case.jsp:51 | 一个「查閱」按钮回呼searchRows | CMP-01本页接线，不翻新另一个入口 |
| E-08 | base.css:1～4 | body字体／宽／边距／色、表格与单元格、action-bar间距 | SCR-01入口可见源事实，DEP-02独立契约仍缺 |
| E-09 | api-contract.md:3、7～12 | fixture-v1沙盒；searchItems POST /v2/items/search JSON；queryText规则；服务端单位；認證未定义 | API-01，非正式无可呼叫环境，不等于未部署 |
| E-10 | api-contract.md:16～19 | HTTP200 outcome/rows，OK/EMPTY/DENIED；rows[].rowId/label；两拒绝／空分支[] | API-01；其他结果、null规则未定义 |
| E-11 | api-contract.md:23～27 | searchRows承接；输入／结果／集合／代碼／名称逐项映射；未承接rankHint、名称初始化、数量行为 | 双向映射与HANDOFF-01～03，不扩增schema |
| E-12 | business-rules.md:3～6 | 服务端单位权限→DENIED/EMPTY/OK；其他性质、计费／储存未定义 | BR-05、责任与缺口；不表示该能力在整个系统不存在 |
| E-13 | specs/action-bar.md:3～11 | fixture-component-v1，来源路径与源SHA匹配；CMP-SEARCH-ACTION职责与本页符合 | 重用范围仅按钮；源与契约hash实际核对 |
| E-14 | legacy-bridge.js:1～8 | POST /legacy/searchRows，JSON，解析response.json后交receive；未列拒绝／异常处理 | DEP-03有限盘点；旧路径不成为目标API，错误UX未知 |
| E-15 | task.txt；manifest.json | 唯一入口、指定后端基准、仅快照、明示模拟重用／延后 | 测试决策不能用于正式项目授权 |

## 4. 來源到契約覆蓋

| 定位／类型 | E | 契約去向 | 原型／案例 | 結論 |
| --- | --- | --- | --- | --- |
| Case.jsp:1～2 编码／类依赖 | E-02／03 | encoding登记；DEP-05、HANDOFF-02 | 非UI；AC-09 | 已映射＋TODO-03 |
| :4 名称读入；:49输出 | E-01 | FLOW-01、BOUND-01、DATA-02、UI-02 | items.html UI-02／ST-01，AC-01 | 已知映射＋TODO-01 |
| :5 模式条件 | E-02 | FLOW-05、DATA-09 | 不做可见控件；AC-09 | 两分支映射＋TODO-03 |
| :6 解析 | E-02 | HANDOFF-02、DATA-06 | 不执行运算；AC-08 | 目标未承接，TODO-03 |
| :7 费用两个分支 | E-02 | BR-04、DATA-07、HANDOFF-02 | 不加金额字段；AC-08／09 | 已知legacy＋TODO-03 |
| :8 可信单位、存储副作用 | E-02 | DATA-08、BOUND-03、HANDOFF-02 | 非UI副作用；AC-09 | TODO-03，Ledger实现未取得 |
| :11～17 文档／title／CSS／script | E-03／08／14 | SCR-01、UI-01、CMP-02、DEP-02／03 | 本地内嵌样式；AC-11 | TODO-06，共用契約不新造 |
| :19～21 查阅清状态、trim、交接 | E-04 | FLOW-02、BR-01、BOUND-02、API-01 | UI-04、ST-02，AC-02／06 | 已映射；TODO-04／06 |
| :22～30 清列／成功集合三个值 | E-05 | FLOW-03、TR-02、DATA-03～05、UI-05 | ST-03、AC-03／06 | 名称／代碼已映射，第三栏TODO-02 |
| :31～35 空／拒绝／未匹配分支 | E-05 | TR-03／04／07、MSG-01／02、ST-04／05／08 | 可注入三分支；AC-04／05／10 | 已映射；目标其他码TODO-04 |
| :38～44 空guard／非空放行 | E-06 | FLOW-04、BR-03、TR-05／06、MSG-03 | 原生alert／边界；AC-07／08 | 已映射；非空交接TODO-03 |
| :47～53 信息顺序、输入、include、表头 | E-03／07 | SCR-01、UI-01～06、CMP-01 | items.html；AC-01／11 | 共用契约重用；TODO-01／02／06 |
| :54～58 form、hidden、数量、submit | E-06 | DATA-09、FLOW-04、BOUND-03、UI-07／08 | 安全阻断真提交；AC-07／08 | 已映射＋TODO-03 |
| action-bar:1 | E-07／13 | CMP-01外部版本引用，FLOW-02 | data-component-id；AC-02 | 适用原契约重用 |
| base.css:1～4 | E-08 | 源定义视觉事实、CMP-02 | inline CSS、AC-11 | 依赖契约TODO-06、视觉TODO-05 |
| bridge:1～8 | E-14 | FLOW-02／03、BOUND-02、DEP-03 | 无fetch、不执行旧代码 | TODO-04／06；目标投影E-09～11 |
| 后端全部操作／结果／映射／责任 | E-09～12 | API-01、BR-05、HANDOFF | AC-02～06／08～10 | 所有已知wire字段映射，无新字段 |

覆盖分母是本入口及已盘点的直接相关来源，不含未取得Ledger、session或响应者内部。每条已识别事实有映射或TODO；无百分比或“全部系统覆盖”宣称。

### 4.1 耦合責任與原順序

| LOGIC | 触发、条件、输入及原顺序 | 责任／前端去向 | 目标承接或缺口 |
| --- | --- | --- | --- |
| LOGIC-01 | 初入第1步，session名称读取 | 受信任情境；DATA-02、BOUND-01 | HANDOFF-01、TODO-01 |
| LOGIC-02 | 业务正常继续后的名称显示 | 呈现；UI-02、FLOW-01 | 前端已知；目标来源TODO-01 |
| LOGIC-03 | 名称捕捉后判断mode=commit | 动作路由，非可见状态DATA-09 | HANDOFF-02、TODO-03；非提交跳过已保留 |
| LOGIC-04 | 提交分支第1步Integer.parseInt | 业务检核，DATA-06、FLOW-05 | HANDOFF-02、TODO-03；非整数反应未知 |
| LOGIC-05 | 解析后≥4?×8:×10 | 业务计算，DATA-07、BR-04 | HANDOFF-02、TODO-03；不搬入prototype |
| LOGIC-06 | 写入时读取session.unitId | 受信任单位情境，DATA-08 | 数量HANDOFF-02；查阅单位置API-01由E-09／12提供 |
| LOGIC-07 | 计算后Ledger.store(unit,quantity,charge) | 存取副作用，BOUND-03 | HANDOFF-02、TODO-03；原子性／异常未取得 |
| LOGIC-08 | 用户查阅：清文案→trim→请求 | 呈现＋输入转换＋边界；FLOW-02 | API-01输入映射E-09／11；旧bridge契约TODO-06 |
| LOGIC-09 | 每回應先清列，然后成功集合显示三值 | 呈现，FLOW-03、DATA-03～05 | API-01两字段承接；第三栏HANDOFF-03、TODO-02 |
| LOGIC-10 | 回應空／拒绝判定与文案 | 结果映射呈现；TR-03／04、MSG-01／02 | API-01对应E-10／11，权限由E-12；其他TODO-04 |
| LOGIC-11 | 前端空数量alert+阻断，非空允许 | 操作体验；FLOW-04／BR-03 | 保留前端提示，不替代后端解析保证；TODO-03 |
| LOGIC-12 | 内部mode提交意图→同入口form提交 | 内部状态＋边界，DATA-09／BOUND-03 | 未取得目标操作；HANDOFF-02、TODO-03 |
| LOGIC-13 | 业务正常继续后静态结构／样式渲染 | 呈现；SCR-01、UI、CMP-01／02 | 源事实可见，样式独立契约TODO-06、视觉TODO-05 |

### 4.2 API／移交状态

API-01：fixture-v1契约已核对，queryText←trim输入，outcome→三结果，rows.rowId/label→代碼／名称；没有把unitId从前端传入，也没有rankHint schema。认證／实际环境／未定义结果未解决TODO-04。HANDOFF-01／02／03文件已生成，目标责任未承接；各缺口分别TODO-01／03／02，文件完成不关闭TODO。

## 5. TODO

### TODO-01

类型／状态：未建立目标初始化契约，沙盒延后、开启。已知E-01／03先读可信名称并显示，E-11明确未承接。影响FLOW-01、BOUND-01、UI-02、DATA-02、AC-01／09。下一步取得可信初始化资料，核对名称合法來源、读入时机、空值／缺失／异常；更新HANDOFF-01与前端，再重新验证AC-01／09。关闭需目标承接证据及必要执行验证。依赖DEP-06；[TASK-08](plan.md#task-08)、DEC-01。尚未解决。

### TODO-02

类型／状态：服务输出未承接，沙盒延后、开启。E-05每列显示rankHint，E-10只定义rowId／label，E-11明确未承接。影响FLOW-03、BOUND-02、DATA-05、UI-05、ST-03、AC-03／06。下一步取得排序提示来源／类型／空值定义或有权确认可见变更，再更新HANDOFF-03／API／前端，重新验证三栏与回應顺序。关闭需合法来源与两端验证，合成值不算证据。DEP-04缺项；[TASK-09](plan.md#task-09)、DEC-01。尚未解决。

### TODO-03

类型／状态：未承接业务与副作用，沙盒延后、开启。E-02数量模式→解析→计费→可信单位写入，E-06前端仅精确空值阻断，E-11／12未定义数量目标。影响FLOW-01／04／05、BOUND-03、DATA-06～09、UI-07／08、AC-07～09。Ledger实现、解析失败／溢出、单位缺失、写入异常、原子性／回滚／重送均未知。下一步取得后端正式承接与缺失依赖契约，先还原原顺序及保证，再更新HANDOFF-02／API／前端并验证门槛、非法输入、无提交模式与异常。关闭需责任完整覆盖、合法单位来源、目标结果与必要验证；前端本地计算不可替代。DEP-05／06；[TASK-08](plan.md#task-08)、DEC-01。尚未解决。

### TODO-04

类型／状态：认證／响应／环境契约不完整，沙盒延后、开启。E-09认证未定义、无环境；E-10无非200或其他码；E-14缺已定义异常UX。影响API-01、FLOW-02／03、BOUND-02、AC-02～06／10，目标字段null／缺失及格式异常也未知。下一步取得目标認證、必要headers、服务错误、合法空值及测试环境，不以旧bridge或命名猜测；再核对UI反馈、API与必要介接。关闭需对应契约／映射与真实必要验证。DEP-04／07；[TASK-09](plan.md#task-09)、DEC-01。部署状态未确认；不能由禁止网络推出未部署。尚未解决。

### TODO-05

类型／状态：未验证与操作体验未知，开启。E-03／08仅源码，未执行legacy；无焦点恢复、快捷键、实际尺寸／像素比较材料。影响SCR-01、全部UI、AC-01～11。下一步在受控浏览器实际渲染prototype、检验警示／键盘／中间状态／控制台／意外连线，必要另获legacy观察环境与范围授权。关闭需具体角色、数据、步骤、截图／日志及源与渲染比对；脚本DOM模拟不替代浏览器。依赖环境；[TASK-10](plan.md#task-10)。本案例禁止legacy执行，不擅自突破。尚未解决。

### TODO-06

类型／状态：缺适用共用契约，沙盒延后、开启。在inputs/specs唯一候选只覆盖按钮，未取得style或bridge契约。E-08／14只是对本页影响的有限盘点，不是完整独立依赖翻新。影响CMP-02、SCR-01、FLOW-02／03、BOUND-02、AC-02～06／10／11。下一步取得版本适用契约或在明确范围内独立翻新，核对本页视觉及传输／回應行为；再更新引用并重验相关AC。关闭需可定位契约、适用性与必要验证，不能只因源可读就宣告完整。DEP-02／03；[TASK-07](plan.md#task-07)、DEC-01。尚未解决。

## 6. 原有差距与未确认提案

已知源行为：成功回應不清除前一回應文案；前端数量仅精确空串阻断（E-05／06）。可提出“只显示最后启动查询”“统一清状态”“数字输入限制”等变更，但均未获确认，正式规格与prototype保留原语意。无其他已执行缺陷观察，不将源码推论冒充运行缺陷。

## 7. 验证与交付判定

实际结果与可重现脚本见[检查纪录](checks/results.txt)、[静态脚本](checks/static.py)、[原型脚本执行](checks/prototype.js)。静态与Node假DOM为实际执行检查，均非真实浏览器或legacy。

| V | 环境／操作／预期 | 实际结果／判定 |
| --- | --- | --- |
| V-01 | Python读manifest逐件核对SHA、UTF-8与LF；输入应未变 | 快照全部匹配；通过；见results |
| V-02 | Python检查文件、local links／fragments、无placeholder、prototype离线引用与ID、已知样式／API原文 | 见results实际输出；通过只说明结构与明示事实，不代表系统完整 |
| V-03 | Node VM执行生成prototype脚本＋最小DOM模拟；AC-01～07／10可见部分、非空数量边界与重复查阅 | 见results；检查清状态但保留旧列、trim、成功两列形状、无项目／拒绝／其他、乱序文案、alert、非空停边界与reset通过；不执行legacy脚本或计费 |
| V-04 | 源到契约与API人工核对 | 所有60行及直接相关来源见覆盖表；wire只投影已知字段／三结果、3个HANDOFF；通过已知部分，TODO-01～04／06未解 |
| V-05 | 浏览器实际render、视觉／原生警示／焦点／控制台／network | 未执行。case没有配置浏览器测试会话；本地Python playwright与Node playwright/puppeteer不可解析，selenium可导入但没有建立受控浏览器会话。没有下载工具、尝试driver联网或截图；TODO-05 |
| V-06 | legacy／实际目标服务介接，数量写入与可信情境验证 | 未执行。task禁止legacy／真实网络；后端原件无可呼叫环境；不能宣告介接通过，TODO-01～04 |

已确认的是来源中清晰的结构、分支、顺序、提示与目标查阅定义；已验证的是静态结构、引用和本地prototype脚本反应。必要的目标名称、排序提示、数量业务、认證／异常、独立依赖契约与浏览器验证仍未完成，故**部分交付**。没有像素一致、生产可用、完整迁移或全入口真实运行等宣称。

## 8. 增量紀錄

CHANGE-00：首次P0计划实际建立，来源待分析。CHANGE-01：P1依赖与权威盘点、适用共用按钮重用、沙盒模拟延期。CHANGE-02：生成0.1契约、原型、API与HANDOFF；登记TODO-01～06，V-01～06。没有旧证据失效、未关闭TODO、未改动任何inputs／skill。


CHANGE-03：0.2 續作修訂與實際位置核對見第9節；本輪執行結果見 [第10節](#revision-02-verification)。既有 evidence、ID 與模擬決策保留。

## 9. 續作來源、適用性與缺口位置核對

CHANGE-03，版本 0.2，2026-10-12。task 指定同一入口與後端 baseline；沿用 E-01～15、LOGIC-01～13、所有設計／契約／任務／TODO ID。輸入及共用契約版本於本輪重新核對，不以 0.1 通過紀錄證明 0.2。首次 P0/P1 及 V-01～06 保留為历史紀錄；本輪結果見第10節。

E-16：本輪 manifest／task／skill snapshot 與既有 artifacts 的續作檢查。適用規則為本案例 skill/references/dependencies.md「缺口影響 ID 展開位置表」及 integration-contract.md「跨文件 AC 實際涵蓋與獨立 wire 案例」。這是交付修訂方法證據，不新增系統行為。前端根、後端 fixture-v1、共用 fixture-component-v1 均未改版；沒有來源證據失效。DEP-01／04 可重用，其他依賴及 DEP-04 缺項仍按 task 的沙盒 DEC-01 延後。

位置表逐項回讀下面實際定義中的 TODO 與 TASK href，包含資料、狀態、畫面、邊界和案例。新增的是缺口標記的可定位性，不是已承接能力或 TODO 關閉證據。集中索引不算就地標記。每一列指出實際設計錨點及已讀到的 TODO 連結，完整影響清單以本表為本輪更新；既有 TODO 敘述保留。

| TODO | 實際受影響定義位置 | 該位置已讀到的連結 | 後續任務／決策 |
| --- | --- | --- | --- |
| TODO-01 | [FLOW-01](../../design/fixture-case/specification.md#flow-01) | [TODO-01](#todo-01) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-01 | [BOUND-01](../../design/fixture-case/specification.md#bound-01) | [TODO-01](#todo-01) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-01 | [UI-02](../../design/fixture-case/specification.md#ui-02) | [TODO-01](#todo-01) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-01 | [DATA-02](../../design/fixture-case/specification.md#data-02) | [TODO-01](#todo-01) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-01 | [ST-01](../../design/fixture-case/specification.md#st-01) | [TODO-01](#todo-01) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-01 | [AC-01](../../design/fixture-case/specification.md#ac-01) | [TODO-01](#todo-01) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-01 | [AC-09](../../design/fixture-case/specification.md#ac-09) | [TODO-01](#todo-01) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-02 | [FLOW-03](../../design/fixture-case/specification.md#flow-03) | [TODO-02](#todo-02) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-02 | [BOUND-02](../../design/fixture-case/specification.md#bound-02) | [TODO-02](#todo-02) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-02 | [DATA-05](../../design/fixture-case/specification.md#data-05) | [TODO-02](#todo-02) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-02 | [UI-05](../../design/fixture-case/specification.md#ui-05) | [TODO-02](#todo-02) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-02 | [ST-03](../../design/fixture-case/specification.md#st-03) | [TODO-02](#todo-02) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-02 | [AC-03](../../design/fixture-case/specification.md#ac-03) | [TODO-02](#todo-02) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-02 | [AC-06](../../design/fixture-case/specification.md#ac-06) | [TODO-02](#todo-02) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [FLOW-01](../../design/fixture-case/specification.md#flow-01) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [FLOW-04](../../design/fixture-case/specification.md#flow-04) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [FLOW-05](../../design/fixture-case/specification.md#flow-05) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [BOUND-03](../../design/fixture-case/specification.md#bound-03) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [DATA-06](../../design/fixture-case/specification.md#data-06) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [DATA-07](../../design/fixture-case/specification.md#data-07) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [DATA-08](../../design/fixture-case/specification.md#data-08) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [DATA-09](../../design/fixture-case/specification.md#data-09) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [UI-07](../../design/fixture-case/specification.md#ui-07) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [UI-08](../../design/fixture-case/specification.md#ui-08) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [ST-01](../../design/fixture-case/specification.md#st-01) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [ST-07](../../design/fixture-case/specification.md#st-07) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [BR-04](../../design/fixture-case/specification.md#br-04) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [AC-07](../../design/fixture-case/specification.md#ac-07) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [AC-08](../../design/fixture-case/specification.md#ac-08) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [AC-09](../../design/fixture-case/specification.md#ac-09) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [FLOW-02](../../design/fixture-case/specification.md#flow-02) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [FLOW-03](../../design/fixture-case/specification.md#flow-03) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [BOUND-02](../../design/fixture-case/specification.md#bound-02) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [DATA-08](../../design/fixture-case/specification.md#data-08) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [ST-02](../../design/fixture-case/specification.md#st-02) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [ST-08](../../design/fixture-case/specification.md#st-08) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [TR-07](../../design/fixture-case/specification.md#tr-07) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [AC-02](../../design/fixture-case/specification.md#ac-02) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [AC-03](../../design/fixture-case/specification.md#ac-03) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [AC-04](../../design/fixture-case/specification.md#ac-04) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [AC-05](../../design/fixture-case/specification.md#ac-05) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [AC-06](../../design/fixture-case/specification.md#ac-06) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [AC-10](../../design/fixture-case/specification.md#ac-10) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-05 | [SCR-01](../../design/fixture-case/specification.md#scr-01) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [UI-01](../../design/fixture-case/specification.md#ui-01) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [UI-02](../../design/fixture-case/specification.md#ui-02) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [UI-03](../../design/fixture-case/specification.md#ui-03) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [UI-04](../../design/fixture-case/specification.md#ui-04) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [UI-05](../../design/fixture-case/specification.md#ui-05) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [UI-06](../../design/fixture-case/specification.md#ui-06) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [UI-07](../../design/fixture-case/specification.md#ui-07) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [UI-08](../../design/fixture-case/specification.md#ui-08) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [ST-01](../../design/fixture-case/specification.md#st-01) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [ST-02](../../design/fixture-case/specification.md#st-02) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [ST-03](../../design/fixture-case/specification.md#st-03) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [ST-04](../../design/fixture-case/specification.md#st-04) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [ST-05](../../design/fixture-case/specification.md#st-05) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [ST-06](../../design/fixture-case/specification.md#st-06) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [ST-07](../../design/fixture-case/specification.md#st-07) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [ST-08](../../design/fixture-case/specification.md#st-08) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-01](../../design/fixture-case/specification.md#ac-01) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-02](../../design/fixture-case/specification.md#ac-02) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-03](../../design/fixture-case/specification.md#ac-03) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-04](../../design/fixture-case/specification.md#ac-04) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-05](../../design/fixture-case/specification.md#ac-05) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-06](../../design/fixture-case/specification.md#ac-06) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-07](../../design/fixture-case/specification.md#ac-07) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-08](../../design/fixture-case/specification.md#ac-08) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-09](../../design/fixture-case/specification.md#ac-09) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-10](../../design/fixture-case/specification.md#ac-10) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-05 | [AC-11](../../design/fixture-case/specification.md#ac-11) | [TODO-05](#todo-05) | [TASK-10](plan.md#task-10)；執行環境限制；task 禁止真實服務 |
| TODO-06 | [CMP-02](../../design/fixture-case/specification.md#cmp-02) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [SCR-01](../../design/fixture-case/specification.md#scr-01) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [UI-05](../../design/fixture-case/specification.md#ui-05) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [FLOW-02](../../design/fixture-case/specification.md#flow-02) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [FLOW-03](../../design/fixture-case/specification.md#flow-03) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [BOUND-02](../../design/fixture-case/specification.md#bound-02) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [ST-02](../../design/fixture-case/specification.md#st-02) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [AC-02](../../design/fixture-case/specification.md#ac-02) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [AC-03](../../design/fixture-case/specification.md#ac-03) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [AC-04](../../design/fixture-case/specification.md#ac-04) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [AC-05](../../design/fixture-case/specification.md#ac-05) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [AC-06](../../design/fixture-case/specification.md#ac-06) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [AC-10](../../design/fixture-case/specification.md#ac-10) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |
| TODO-06 | [AC-11](../../design/fixture-case/specification.md#ac-11) | [TODO-06](#todo-06) | [TASK-07](plan.md#task-07)；[DEC-01](plan.md#dec-01) |

| TODO-01 | [HANDOFF-01](../../integration/fixture-case/backend-handoff.md#handoff-01) | [TODO-01](#todo-01) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-02 | [HANDOFF-03](../../integration/fixture-case/backend-handoff.md#handoff-03) | [TODO-02](#todo-02) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-02 | [API-01](../../integration/fixture-case/api-spec.md#api-01) | [TODO-02](#todo-02) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |
| TODO-03 | [HANDOFF-02](../../integration/fixture-case/backend-handoff.md#handoff-02) | [TODO-03](#todo-03) | [TASK-08](plan.md#task-08)；[DEC-01](plan.md#dec-01) |
| TODO-04 | [API-01](../../integration/fixture-case/api-spec.md#api-01) | [TODO-04](#todo-04) | [TASK-09](plan.md#task-09)；[DEC-01](plan.md#dec-01) |

## 10. 本輪驗證（0.2）

<a id="revision-02-verification"></a>

0.2 實際重跑 `python3 artifacts/renovation/fixture-case/checks/static.py` 及 `node artifacts/renovation/fixture-case/checks/prototype.js`。本輪在來源快照核對、local links／fragments、明示樣式／產品 ID、API 已知欄位與結果、90 個缺口／ID 位置配對、8 個 API 獨立案例定義及既有 ID 保留檢查通過；歷史 V-01～06 不作此結論的證明。詳細 stdout 分輪保留於 [results.txt](checks/results.txt)。

| 本輪檢查 | 實際結果與限制 |
| --- | --- |
| V-01／02 重跑 | 所有 manifest snapshots 包含 prior-artifacts 均匹配；UTF-8/LF、local links、明示 UI／樣式／API facts 通過。沒有修改 inputs／skill／manifest。 |
| V-03 重跑 | Node VM 與最小 DOM 模擬執行：初始可見子集、trim、查閱清文案但保留舊列、三欄合成資料、無項目／拒絕、亂序回應／狀態保留、空值 alert 呼叫與阻断、非空停邊界、審閱 reset/toggle 通過。沒有執行計費／Ledger。 |
| V-07 | 90 個實際受影響位置逐項回讀，TODO 與 TASK links 都存在；表中實際 ID 錨點、tracking／plan links 解析通過。包含 DATA-06～09、ST-01／02／03／07／08。 |
| V-08 | 人工比對 API-AC-01～08 與 E-09～12：缺省／空字串、null、12／13 長度、型別、trim／單位、OK 欄位形狀、EMPTY／DENIED 空集合及必有欄位的範圍與原件一致。腳本確認獨立案例與樣本存在；這是文件核對，不是服務執行。未定義拒絕回應不被補造。 |
| V-09 | 五份 Markdown 的 prior-artifacts ID 集合逐檔與本輪比對，沒有移除既有 ID；E-01～15 與 LOGIC-01～13 證據／分類保留。新增 E-16／TASK-11／API-AC-01～08／CHANGE-03。 |
| 本輪瀏覽器環境檢查 | PATH 上 chromium／chromium-browser／google-chrome／playwright／firefox 均無；Python playwright 不可解析、selenium 可解析；Node playwright／puppeteer 不可解析。沒有配置或啟動受控瀏覽器、下載工具或啟動 driver；瀏覽器 render、原生警示呈現、焦點、控制台與 network panel **未執行**。此 probe 只說明可用指令／套件，不能宣稱整台主機無瀏覽器。TODO-05 開啟。 |
| legacy／目標服務 | 本輪未執行。僅使用提供快照、沒有 JSP/Ledger runtime 或可呼叫後端環境；本輪授權禁止呼叫服務與網路。TODO-01～04／06 未解；服務部署狀態仍未確認。 |

續作更正：0.1 文字曾將「task 禁止 legacy 執行」寫為限制；task 的可定位明文是只用快照且不 query/call external systems，並未單獨宣告所有本地 legacy 執行禁止。歷史敘述不作新權威；本輪確實沒有啟動 legacy，原因與執行界限以本節為準。API-AC-01～08 定義於 [API-01 契約案例](../../integration/fixture-case/api-spec.md#契約核對案例)，與前端 AC-01～11 分開。TODO-01～06 全部開啟；TASK-07～10 尚未完成。此續作僅補齊本輪可處理的契約與追蹤；交付仍為部分。

CHANGE-03 完成：缺口影響位置與直接 TASK 連結補齊，移除 API 文件對 AC-02 的過度涵蓋主張，建立 API-AC-01～08；原型只增補審閱說明，產品互動不變。TODO-01～06 均未關閉，仍為**部分交付**。
