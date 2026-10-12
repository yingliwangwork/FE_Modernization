# fixture-case：前端 API 消費規格

投影版本0.1。[前端契約](../../design/fixture-case/specification.md) · [追蹤](../../renovation/fixture-case/tracking.md)。

权威：`backend_root=inputs/backend`，选定 [api-contract.md](../../../inputs/backend/api-contract.md)，fixture-v1，SHA256 `04215f381bc195b357b184c89d90e6f4fba521580feb7147c141a25cdb1ca802`；语意补充 [business-rules.md](../../../inputs/backend/business-rules.md)，fixture-v1，SHA256 `35e4253d281cacc662c065ed690337ae8a71f04233df8289c065828aba7614b7`。这是沙盒测试用后端交付契约、非正式服务，没有可呼叫环境；部署状态未确认，不宣称未部署。不是 OpenAPI 原件，不生成另一个空壳 schema。

## 1. 需求／操作索引

| FLOW／BOUND | 所需能力 | 投影或缺口 | 证据 |
| --- | --- | --- | --- |
| FLOW-02／03，BOUND-02 | 项目查阅、成功／空／拒绝结果 | API-01：searchItems，fixture-v1 | E-04／05、E-09／10／11／12 |
| FLOW-01，BOUND-01 | 可信審閱者名稱 | HANDOFF-01，TODO-01；不发明初始化操作 | E-01／03、E-11 |
| FLOW-03，BOUND-02 | 排序提示 | HANDOFF-03，TODO-02；不能补进 rows schema | E-05、E-11 |
| FLOW-04／05，BOUND-03 | 整数解析、计费、可信单位写入 | HANDOFF-02，TODO-03；未取得操作 | E-02／06、E-11／12 |

## API-01

### 操作與傳輸

| 项目 | 原件定义 | 证据／缺口 |
| --- | --- | --- |
| operationId | `searchItems` | E-09 |
| method / path | `POST /v2/items/search` | E-09 |
| request / response | `application/json` | E-09 |
| 单位情境 | 由服务端提供；不接受 client `unitId` | E-09、E-12 |
| 認證傳輸／必要 header | 尚未定义；不能假定无認證或自行补 Authorization | E-09；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) |
| 性质／环境 | 沙盒 fixture-v1 后端交付契约，非正式服务，无可呼叫环境 | E-09 |
| 其他性质 | 排序、分页、重送、取消、交易未定义；冪等、超时及缓存也无确认依据 | E-12；TODO-04 |

### Request 與前端來源

| 精确位置／wire 名称 | 类型、必填与空值 | 前端来源／转换／时机 | 两端证据 |
| --- | --- | --- | --- |
| body | object | FLOW-02 查阅输入容器；没有服务端单位的客户端字段 | E-09 |
| body.queryText | string，选填，最大长度12；省略或空字串＝不指定关键字；null不合法 | DATA-01／UI-03；来源输入 maxlength12，传送前 trim，不把空白改为null；每次激活查阅传当前值 | E-03／04、E-09／11 |
| 服务端单位情境 | 服务端提供，不接受 client unitId；情境格式未定义 | DATA-08，不把数量旧情境任意转为查阅请求字段 | E-02、E-09／12；TODO-04 |

缺省只由后端定义，本页已有前端规则总是提供去首尾空白后的文字；不增加省略字段的前端新行为。最大长度是原本输入限制与后端接受条件各自的事实。

### Response 與消費映射

| wire 路径 | 类型／原件条件 | 前端语意及反应 | 两端证据 |
| --- | --- | --- | --- |
| body | HTTP200 object，无额外包装层定义 | 传输成功不等于业务成功，需 outcome 判定 | E-10 |
| body.outcome | 必有 string；OK、EMPTY、DENIED | OK→TR-02／ST-03；EMPTY→TR-03／ST-04／MSG-01；DENIED→TR-04／ST-05／MSG-02 | E-05、E-10／11 |
| body.rows | 必有 array；EMPTY／DENIED时[] | FLOW-03 每次回應先清所有旧列；OK依集合原顺序显示，不引入客户端排序 | E-05、E-10／11 |
| body.rows[].rowId | 必有 string | DATA-03／UI-05 第一栏直接显示文字 | E-05、E-10／11 |
| body.rows[].label | 必有 string | DATA-04／UI-05 第二栏直接显示文字 | E-05、E-10／11 |

以上列出本操作全部已知字段；无未消費的已知输出。不得将 `rankHint` 加入 rows 子项：它仅是前端所需但后端未承接的 DATA-05。必有字段的 null 接受性、OK空集合、集合限制等未定义，不从一般 JSON 习惯补造；TODO-04。

### 結果判定与反应

| 条件 | HTTP／业务结果 | 前端可见反应 | 证据 |
| --- | --- | --- | --- |
| 单位不允许查阅 | 200／DENIED，rows=[] | 先清列，UI-06「不允許查閱」 | E-05、E-10／11／12 |
| 允许但无符合项目 | 200／EMPTY，rows=[] | 先清列，UI-06「沒有項目」 | E-05、E-10／11／12 |
| 允许且有符合项目 | 200／OK＋rows | 清列重建代碼与名称；保持回應前状态段落文案；第三栏缺口 TODO-02 | E-05、E-10／11／12 |
| 其他结果码／非200／传输异常 | 未定义 | 不造通用失败提示；legacy 其他码清列但不改文案不证明目标其他码合法 | E-05／09、E-10；TODO-04 |

服务端没有回傳 message 欄位，三条已知 UI 原文来自前端；不能构造后端 message envelope。

### 順序与责任

FLOW-02：清状态 → 读取并trim关键字 → 交接服务。服务端单位置于受信任情境并进行权限／查询判断。FLOW-03：收到结果 → 清列 → 结果判定 → 显示（E-04／05、E-09～12）。重复请求仍可发出；实际回應到达顺序决定显示，未确认取消与重送保证。数量提交从来不是 API-01 的用途。

### 契约核对案例

AC-02 核对 trim、空字串、12长度、null不合法；AC-03核对 rows、rowId／label及缺少排序提示；AC-04／05核对EMPTY／DENIED与空集合；AC-06核对回應到达顺序及状态保持；AC-10只保留legacy其他分支，不将其写成目标合法结果。定义在前端规格第8节；执行结果见tracking，不宣称正式介接通过。

## 3. 未形成可用契約的需求

| 需求 | 原件缺口 | 去向 |
| --- | --- | --- |
| BOUND-01／DATA-02 | 明示未承接首次審閱者名称 | [HANDOFF-01](backend-handoff.md#handoff-01)，[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) |
| BOUND-02／DATA-05 | 明示未承接rankHint；不改写正式schema | [HANDOFF-03](backend-handoff.md#handoff-03)，[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) |
| BOUND-03／DATA-06～09 | 无提交操作、计算／储存／可信单位机制与错误契约 | [HANDOFF-02](backend-handoff.md#handoff-02)，[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) |
| BOUND-02 | 認證机制、非200、其他码、必有字段null等不完整 | [TODO-04](../../renovation/fixture-case/tracking.md#todo-04)；不能以旧传输方式补足目标定义 |
