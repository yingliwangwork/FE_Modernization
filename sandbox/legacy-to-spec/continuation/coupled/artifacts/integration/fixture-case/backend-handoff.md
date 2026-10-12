# fixture-case：後端責任移交需求

需求版本0.2，来源根入口证据 E-01～06。已比对 fixture-v1 的 [后端基准](../../../inputs/backend/api-contract.md) 与 [业务责任](../../../inputs/backend/business-rules.md)（E-09～12）。[前端契约](../../design/fixture-case/specification.md) · [API投影](api-spec.md) · [追踪](../../renovation/fixture-case/tracking.md)。以下是有来源的待承接责任，不是可呼叫端点；不选择框架、交易方案或数据表。

## 1. 責任索引

| 移交 | LOGIC／FLOW／BOUND | 旧事实／目标缺口 | TODO |
| --- | --- | --- | --- |
| HANDOFF-01：可信名称初始化 | LOGIC-01／02，FLOW-01，BOUND-01 | 读取受信任名称并显示；目标明示未承接 | [TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| HANDOFF-02：数量计费与写入 | LOGIC-03～07，FLOW-04／05，BOUND-03 | 整数解析→门槛计算→可信单位写入；目标未承接 | [TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| HANDOFF-03：排序提示来源 | LOGIC-09，FLOW-03，BOUND-02 | 每项目第三栏显示原值，目标只给代碼与名称 | [TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |

## HANDOFF-01

触发：入口生命週期（ACT-02）。原顺序为先读取 DATA-02，再检查是否数量提交，最后正常渲染时显示「審閱者：」＋名称（E-01／03）。这项读取属于受信任情境，显示属于前端；不可改成用户可编辑名称、固定产品值或从查阅结果取代。

| 方向／语意 | 类型／空值 | 来源与消費 |
| --- | --- | --- |
| 服务情境→DATA-02 | 名称文字；空值／缺失反应未确认 | 受信任既有情境→UI-02 |

后端 API 原件明确未承接首次名称（E-11）。承接需可定位地提供合法来源、初始化时机、缺失／异常定义，并与 FLOW-01 原顺序核对。AC-01／09验证显示与读名称先于数量业务；现阶段 [TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)，无假初始化端点。

## HANDOFF-02

触发：入口收到数量提交模式，不要求一定来自可见表单；前端空值阻断只覆盖可见表单事件，不能当作受信任后端验证（E-02／06）。模式未选提交时跳过计算与写入。触发前已读取名称；使用 DATA-06、DATA-09、受信任 DATA-08。

| 方向／语意 | 类型／格式／限制 | 消費 |
| --- | --- | --- |
| 输入 DATA-06 | 用户文字，原业务解析整数；范围与非法格式错误未定义 | 数量解析与计费 |
| 输入 DATA-09 | 内部动作意图，提交模式才执行业务 | 分支选择，非可见控件 |
| 情境 DATA-08 | 受信任单位识别；来源机制、缺失与型别不完整 | 写入归属，不改成用户任填 |
| 输出 DATA-07 | 整数费用，币种／单位不明 | 与单位、整数数量一起传入写入行为；无可见金额字段 |

| 步骤 | 条件／顺序 | 结果与副作用 |
| --- | --- | --- |
| 1 | 数量提交且名称已捕捉 | 解析数量文字为整数 |
| 2a | 数量≥4 | 费用＝数量×8 |
| 2b | 数量<4 | 费用＝数量×10；没有额外正数检查证据 |
| 3 | 前置解析／计算正常继续 | 使用受信任单位、数量、费用调用写入行为 |
| 4 | 写入正常返回 | 继续原画面生成；不自行加入成功提示 |

这些顺序与门槛由 E-02 支撑。`Ledger.store`只能证明写入调用及参数；储存层实现未提供，不能确认持久化、交易原子性、回滚、重复提交保障或异常回傳。解析非法文字、缺失数量、缺失单位、写入异常时的可见结果未知。不能将原一段业务拆成前端计算＋多个调用后声称等价。

fixture-v1 明示未承接数量送出；业务责任文件亦不定义计费／储存（E-11／12）。AC-08核对前端非空放行与服务解析分离、3→30／4→32／-1→-10的legacy分支；AC-09核对非提交跳过、正常提交顺序。以上只用于后端承接核对，不在原型运算／写入。[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)。

## HANDOFF-03

触发：成功查阅回應。前端显示每项 DATA-03、04、05，其中 DATA-05 原值直接作为第三栏文本，不存在前端计算或排序证据（E-05）。原值类型、业务含义、排序保证与空值意义未知。

服务目标只定义 rowId与label，并明确未承接rankHint（E-10／11）。后端需确认该展示资料的来源及契约，或由有权者确认可见行为变更；前端不能自造序号、空字串或从行顺序算提示来关闭缺口。AC-03核对三栏及集合顺序；承接前合成第三栏只是已知legacy形状展示。[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)。

## 3. 承接依据索引

| 移交 | 已确认承接 | 仍待确认 |
| --- | --- | --- |
| HANDOFF-01 | 未取得；基准明确未承接名称 | 合法来源、顺序与异常；[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| HANDOFF-02 | 未取得；API-01只承接查阅 | 解析／计费／写入／情境／失败与保证；[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| HANDOFF-03 | API-01已承接其同列代碼与名称 | 排序提示的类型、来源与可见契约；[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |

移交文件完成不等于后端承接完成。取得新证据后才能更新 API 投影、前端映射及必要验证，TODO关闭纪录只在tracking维护。
