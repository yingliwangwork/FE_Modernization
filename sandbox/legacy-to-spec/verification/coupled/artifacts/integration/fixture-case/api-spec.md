# fixture-case：前端 API 消費規格

投影版本0.2。[前端契約](../../design/fixture-case/specification.md) · [追蹤](../../renovation/fixture-case/tracking.md)。

权威：`backend_root=inputs/backend`，选定 [api-contract.md](../../../inputs/backend/api-contract.md)，fixture-v1，SHA256 `04215f381bc195b357b184c89d90e6f4fba521580feb7147c141a25cdb1ca802`；语意补充 [business-rules.md](../../../inputs/backend/business-rules.md)，fixture-v1，SHA256 `35e4253d281cacc662c065ed690337ae8a71f04233df8289c065828aba7614b7`。这是沙盒测试用后端交付契约、非正式服务，没有可呼叫环境；部署状态未确认，不宣称未部署。不是 OpenAPI 原件，不生成另一个空壳 schema。

## 1. 需求／操作索引

| FLOW／BOUND | 所需能力 | 投影或缺口 | 证据 |
| --- | --- | --- | --- |
| FLOW-02／03，BOUND-02 | 项目查阅、成功／空／拒绝结果 | API-01：searchItems，fixture-v1 | E-04／05、E-09／10／11／12 |
| FLOW-01，BOUND-01 | 可信審閱者名稱 | HANDOFF-01，[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；不发明初始化操作 | E-01／03、E-11 |
| FLOW-03，BOUND-02 | 排序提示 | HANDOFF-03，[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；不能补进 rows schema | E-05、E-11 |
| FLOW-04／05，BOUND-03 | 整数解析、计费、可信单位写入 | HANDOFF-02，[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08)；未取得操作 | E-02／06、E-11／12 |

## API-01

### 操作與傳輸

| 项目 | 原件定义 | 证据／缺口 |
| --- | --- | --- |
| operationId | `searchItems` | E-09 |
| method / path | `POST /v2/items/search` | E-09 |
| request / response | `application/json` | E-09 |
| 单位情境 | 由服务端提供；不接受 client `unitId` | E-09、E-12 |
| 認證傳輸／必要 header | 尚未定义；不能假定无認證或自行补 Authorization | E-09；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |
| 性质／环境 | 沙盒 fixture-v1 后端交付契约，非正式服务，无可呼叫环境 | E-09 |
| 其他性质 | 排序、分页、重送、取消、交易未定义；冪等、超时及缓存也无确认依据 | E-12；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |

### Request 與前端來源

| 精确位置／wire 名称 | 类型、必填与空值 | 前端来源／转换／时机 | 两端证据 |
| --- | --- | --- | --- |
| body | object | FLOW-02 查阅输入容器；没有服务端单位的客户端字段 | E-09 |
| body.queryText | string，选填，最大长度12；省略或空字串＝不指定关键字；null不合法 | DATA-01／UI-03；来源输入 maxlength12，传送前 trim，不把空白改为null；每次激活查阅传当前值 | E-03／04、E-09／11 |
| 服务端单位情境 | 服务端提供，不接受 client unitId；情境格式未定义 | DATA-08，不把数量旧情境任意转为查阅请求字段 | E-02、E-09／12；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |

缺省只由后端定义，本页已有前端规则总是提供去首尾空白后的文字；不增加省略字段的前端新行为。最大长度是原本输入限制与后端接受条件各自的事实。

### Response 與消費映射

| wire 路径 | 类型／原件条件 | 前端语意及反应 | 两端证据 |
| --- | --- | --- | --- |
| body | HTTP200 object，无额外包装层定义 | 传输成功不等于业务成功，需 outcome 判定 | E-10 |
| body.outcome | 必有 string；OK、EMPTY、DENIED | OK→TR-02／ST-03；EMPTY→TR-03／ST-04／MSG-01；DENIED→TR-04／ST-05／MSG-02 | E-05、E-10／11 |
| body.rows | 必有 array；EMPTY／DENIED时[] | FLOW-03 每次回應先清所有旧列；OK依集合原顺序显示，不引入客户端排序 | E-05、E-10／11 |
| body.rows[].rowId | 必有 string | DATA-03／UI-05 第一栏直接显示文字 | E-05、E-10／11 |
| body.rows[].label | 必有 string | DATA-04／UI-05 第二栏直接显示文字 | E-05、E-10／11 |

以上列出本操作全部已知字段；无未消費的已知输出。不得将 `rankHint` 加入 rows 子项：它仅是前端所需但后端未承接的 DATA-05。必有字段的 null 接受性、OK空集合、集合限制等未定义，不从一般 JSON 习惯补造；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)。

### 結果判定与反应

| 条件 | HTTP／业务结果 | 前端可见反应 | 证据 |
| --- | --- | --- | --- |
| 单位不允许查阅 | 200／DENIED，rows=[] | 先清列，UI-06「不允許查閱」 | E-05、E-10／11／12 |
| 允许但无符合项目 | 200／EMPTY，rows=[] | 先清列，UI-06「沒有項目」 | E-05、E-10／11／12 |
| 允许且有符合项目 | 200／OK＋rows | 清列重建代碼与名称；保持回應前状态段落文案；第三栏缺口 [TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) | E-05、E-10／11／12 |
| 其他结果码／非200／传输异常 | 未定义 | 不造通用失败提示；legacy 其他码清列但不改文案不证明目标其他码合法 | E-05／09、E-10；[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |

服务端没有回傳 message 欄位，三条已知 UI 原文来自前端；不能构造后端 message envelope。

### 順序与责任

FLOW-02：清状态 → 读取并trim关键字 → 交接服务。服务端单位置于受信任情境并进行权限／查询判断。FLOW-03：收到结果 → 清列 → 结果判定 → 显示（E-04／05、E-09～12）。重复请求仍可发出；实际回應到达顺序决定显示，未确认取消与重送保证。数量提交从来不是 API-01 的用途。

### 契約核對案例

以下是 API-01 的獨立契約案例定義。用基準文件核對宣告與映射；服務執行須待可呼叫環境及認證契約。非法輸入的拒絕 HTTP／業務碼、文案尚未定義，不在案例中補造。前端 AC-02 只定義一次 trim 及中間狀態，不能代替缺省／空值／長度／型別的 wire 檢查。

| 案例 | 前置資料／事件 | 具體契約預期／證據 |
| --- | --- | --- |
| API-AC-01 | API-01 request body 分別為 `{}`、`{"queryText":""}` | queryText 選填，兩者都表示不指定關鍵字；不是 null。無項目或拒絕取決於服務端情境，不能只依此輸入指定結果。E-09 |
| API-AC-02 | body `{"queryText":null}` | null 不合法；具體拒絕傳輸結果及 UI 反應未定義，[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)。E-09 |
| API-AC-03 | body 分別含文字 `"123456789012"`、`"1234567890123"` | 前者為 12 長度，符合宣告上限；後者超出 12 長度，不符合接受條件。拒絕回應未定義，[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；不以原型 maxlength 檢查冒充服務檢查。E-09 |
| API-AC-04 | body.queryText 分別為文字 `"abc"`、數值 `123`、布林 `false`、集合 `[]`、物件 `{}` | 只有文字符合宣告型別；其他型別不符合契約。錯誤回應未定義，[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)。E-09 |
| API-AC-05 | FLOW-02 關鍵字 `"  示範  "` 啟動；另檢視 request 是否包含 client unitId | 映射結果 queryText=`"示範"`；本頁總是送文字，空輸入送空字串。受信任單位由服務端提供，不接受 client unitId；不以舊 hidden/session 值造 request 欄位。E-04、E-09／11／12；前端時序另見 AC-02 |
| API-AC-06 | HTTP 200，body `{"outcome":"OK","rows":[{"rowId":"DEMO-02","label":"示例乙"},{"rowId":"DEMO-01","label":"示例甲"}]}` | 必有 outcome string、rows array，項目 object 必有 rowId／label string；映射 DATA-03／04，按集合原順序顯示，不自造第三欄。缺少 rankHint 的目標差距仍為 [TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)。E-05、E-10／11 |
| API-AC-07 | 服務端單位不允许／允许但無符合項目，各自檢視 HTTP 200 回應 | 分別 DENIED／EMPTY，兩者 rows=[]。FLOW-03 先清列，再顯示「不允許查閱」／「沒有項目」；映射 TR-04／03、ST-05／04、MSG-02／01。E-05、E-10／11／12；前端呈現另見 AC-04／05 |
| API-AC-08 | 檢視缺 outcome、缺 rows、非 string outcome、非 array rows、row object 缺 rowId／label、非 string rowId／label 的樣本 | 均不符合明示必有／型別契約。必有欄位的 null 語意、額外欄位、OK 空集合、其他結果或非200的處理未定義，不補造可見反應，[TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)。E-10 |

上列 JSON 均為契約審閱樣本，不是服務觀察或 stub 回應。前端 [AC-06](../../design/fixture-case/specification.md#ac-06) 明列請求 A→B 啟動、B 無項目→A 成功抵達及每次抵達的結果／文案觀察，AC-10 定義 legacy 未識別結果；它們不證明目標 API 支援其他結果碼或認證／錯誤行為。實際核對結果與執行限制留在 tracking。

## 3. 未形成可用契約的需求

| 需求 | 原件缺口 | 去向 |
| --- | --- | --- |
| BOUND-01／DATA-02 | 明示未承接首次審閱者名称 | [HANDOFF-01](backend-handoff.md#handoff-01)，[TODO-01](../../renovation/fixture-case/tracking.md#todo-01) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| BOUND-02／DATA-05 | 明示未承接rankHint；不改写正式schema | [HANDOFF-03](backend-handoff.md#handoff-03)，[TODO-02](../../renovation/fixture-case/tracking.md#todo-02) · [TASK-09](../../renovation/fixture-case/plan.md#task-09) |
| BOUND-03／DATA-06～09 | 无提交操作、计算／储存／可信单位机制与错误契约 | [HANDOFF-02](backend-handoff.md#handoff-02)，[TODO-03](../../renovation/fixture-case/tracking.md#todo-03) · [TASK-08](../../renovation/fixture-case/plan.md#task-08) |
| BOUND-02 | 認證机制、非200、其他码、必有字段null等不完整 | [TODO-04](../../renovation/fixture-case/tracking.md#todo-04) · [TASK-09](../../renovation/fixture-case/plan.md#task-09)；不能以旧传输方式补足目标定义 |
