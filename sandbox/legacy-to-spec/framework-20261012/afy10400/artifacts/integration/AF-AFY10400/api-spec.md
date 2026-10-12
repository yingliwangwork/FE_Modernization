# AF-AFY10400：API 消費契約 v1

這是指定基準的消費投影，不是另一份後端權威。對照 [前端規格](../../design/AF-AFY10400/specification.md)、[移交需求](backend-handoff.md)、[tracking](../../renovation/AF-AFY10400/tracking.md)。

## 權威、版本與共通契約

指定 backend_root=`inputs/backend`；基準 `inputs/backend/docs/OPENAPI.md`，SHA-256 `13307ed1144946124179d6e02148999e64783e031d440aacc8ff54e03c32f1ef`，2026-08-12，OpenAPI 3.1.0 Markdown，API 暫記 0.0.1-SNAPSHOT。E-21/22。其内容盤點 Controller/DTO/exception 現況，stub profile 預設啟用；不證明部署。預設 server http://localhost:8080、context / 只屬該文件开发基準；正式server/gateway/header 未定 [TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)，不得推定匿名授權。沒有外部呼叫環境；部署狀態未確認。

一般 POST JSON object，Content-Type application/json、回應 application/json；stub 回應有 `X-AF-Stub: true`。除下载成功外共通 `ReturnMsg<T>`：

| wire字段 | 型别／必填 | 成功／錯誤值与消費 | 依據 |
| --- | --- | --- | --- |
| code | integer，必填 | 成功200；输入、查無、重覆、模組、未預期及Bean Validation錯誤500；Client 必须同时看HTTP和body业务码 | E-21，OPENAPI L29-57；前端舊判定差距TODO-02 |
| msg | string，必填 | 預設success；錯誤为動態原因；舊描述呈現需映射，尚未确认各前缀相容 | E-21；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) |
| data | any或null，必填 | 成功各操作payload；错误null，非旧ErrMsg+頂層payload | E-21；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) |

全域錯誤仍 HTTP 200 OK + code500，不用 HTTP200 推论业务成功；此系现況相容契約。其他未定 HTTP／传输错误的呈現不自创 fallback。重送、幂等、交易原子性、逾時／取消与正式安全情境未定 [TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)。本入口未设置前端timeout。文字为UTF-8 Unicode、前端應用文字節點不使用未消毒 innerHTML（OPENAPI L67）；舊结果含 `<br>` 与原型legacy呈现保留为差距TODO-02。

## 操作索引

| API | 前端需求 | 已確認識別 | 各端依據 |
| --- | --- | --- | --- |
| API-01 | FLOW-04/05、BOUND-01；组合与平行集合匯出、结果与檔名 | afy10400DoExport，POST /afy10400/export | E-04/05 + E-22 |
| API-02 | FLOW-05、BOUND-02；匯出後檔案交接 | afy10400DoDownload，POST /afy10400/download | E-05/17 + E-22 |

可用未消費操作：`afy10400DoPrompt` POST `/afy10400/prompt`（同契約相容 `/afy10400/promp`），request必須 `{}`，payload `insrDate:string yyyMMdd`、`showEdit:string N`、`showQuery:boolean false`、`rtype:boolean false`（不是isRType）；E-22，L502-515。根入口没有发起该事件或消费这些字段，E-03与E-24仅支撑旧渲染上下文线索；不新增前端日期／编辑／查询控制，也不把 prompt 當成 policy／session来源。故不生成消费API-03。

## API-01：匯出

識別 afy10400DoExport；POST `/afy10400/export`；request必須提供JSON object；JSON response使用上述envelope。來源为現況盤點，含stub環境標記，非正式能力验证。E-22 L517-541。

| body 精確名称 | 後端型別／必填與空值 | 前端来源 | 转换／順序與差距 |
| --- | --- | --- | --- |
| insrType | string，非必填；完整enum/nullable未規定 | DATA-01 / UI-03，L或R | 单一選定值，E-03/22；前端選项不升级为DTO验证规则 |
| prodType | string，非必填；完整enum/nullable未規定 | DATA-02 / UI-04，AT/BG/CB | 单一選定值，E-03/22 |
| I_ID | array<string>，非必填；缺省/null/空集合后端結果未完整规定 | DATA-03，有序各列ID | 根頁真正送出來源是表单列，不是未使用param；前端不trim，不改大小寫；target必须array，一列也仍array，E-04/10/22；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) |
| POLICY_NO | array<string>，非必填；索引与I_ID相對应；缺省/null/空集合未完整規定 | DATA-03，有序每列保單多行文字 | 舊序列化LF→CRLF，方法語意用CRLF分割；可保留舊輸入意圖但目标实际拆分規則仍需核對，不能展平失去列對應。E-04/10/22/23；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) |

前端 BR-01/02 在送出前执行，不证明服务端做相同檢核。零列旧表单省略两数组，目标JSON `[]` 的接受结果未知；不把这兩種wire当作已验证相等。`table1_I_ID/table1_POLICY_NOs` 在根源码仅构造从未送出，不作为目标wire字段。

| response完整路径 | 后端形状／语义 | 前端消费与两端映射 |
| --- | --- | --- |
| data.rtnMap | object<string,string>，各ID匯出結果；子key動態，不補固定属性；省略/null边界未列 | DATA-04/UI-08，以回應时現有列當時ID找結果；E-05/22；值以原文文字的目标呈現与旧br不同，TODO-02 |
| data.fileName | string，产出檔名供download；null／缺省未列 | DATA-05→API-02.body.fileName；E-05/22；不重新生成、不自行預設 |
| code/msg/data | 上述必填envelope | code200选择目标成功、code500错误；旧CSR code0/ErrMsg不能直接消费；[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02) |

成功訊息 `success`。业务错误包括空白列、查无、收承方式错误、商品属性错误、Excel產生失敗；共同错误 HTTP200/code500/msg动态原因/data=null。这类错误没有可确认逐列rtnMap，FLOW-05的旧拒绝回填未承接，[HANDOFF-01](backend-handoff.md#handoff-01) + TODO-02。目标成功后按前端既有順序先回填、再交接download；原型只允许旧合成契約展示，並未证明目标adapter。legacy方法文件描述查詢、逐列比對、稽核、xlsx生成，但它不是目标服务部署证据；[HANDOFF-04](backend-handoff.md#handoff-04) + TODO-04。

## API-02：下載

識別 afy10400DoDownload；POST `/afy10400/download`。E-22 L543-567。

| 方向／名稱 | 精確契約 | 来源／消费 |
| --- | --- | --- |
| request Content-Type | application/json，或 application/x-www-form-urlencoded（含charset=UTF-8亦支援） | 基準不改为GET；JSON/表单二者同fileName语义 |
| body fileName | string，非必填；目前DTO没有null/空白驗证，不等于不存在业务错误 | DATA-05/API-01.data.fileName；不由使用者自行构造；E-05/22 |
| successful HTTP | 200 | file交接；旧取得加密JSON再提交不相容，TODO-02 |
| successful Content-Type | application/octet-stream | binary string，format binary；Excel下載 |
| Content-Disposition | attachment; filename="{fileName}"；仅stub adapter已确认 | 正式所有headers未确认，TODO-04 |
| successful body | 二进位，不使用ReturnMsg | 交给同頁下載接收者；不把二進位当JSON解析，不自创downloadFileName/path字段 |
| 下載前 exception | 尝试全域handler ReturnMsg；可能HTTP200/code500/msg动态原因/data=null | 前端错误呈现／半binary处理尚未定义，TODO-02/04 |
| 部分binary已寫入后的exception | 由容器/正式adapter而异，具体结果未定 | 未知，不能宣称已下载完成；TODO-04 |

数据相依：API-01成功有DATA-05 → 先UI-08回填 → API-02；API-01失败不下载。旧RPT链的加密信息不属于目标schema；[HANDOFF-02](backend-handoff.md#handoff-02)保留交接体验与待确认映射，不增加新endpoint。

## 精確 wire 案例

| AC | 前置／操作 | 契約預期與不確定範圍 |
| --- | --- | --- |
| AC-API-01 | API-01 POST JSON 两列，R/CB，I_ID顺序A/B，POLICY_NO顺序P1 CRLF P2/P3 | Request型別与索引匹配；JSON code200、msg success、data.rtnMap及fileName保留精确名称；实际值需后端；E-22，映射AC-06/07 |
| AC-API-02 | 缺省/null/[]/仅一列以及不等长数组，前端不额外假设成功 | DTO非必填与已知业务检查分开；缺省/空集合具体结果TODO-02/04，不写成200必成功；E-22/23 |
| AC-API-03 | 输入錯誤／查无／异常之已知handler合成回應 | HTTP200 code500 msg動態 data=null；必填envelope不可漏；无法符合旧拒绝map回填，HANDOFF-01；E-21/22 |
| AC-API-04 | API-02 JSON及UTF8 form兩種fileName | POST不改GET，成功HTTP200/octet-stream/binary，stub disposition指定；真实文件与正式header未測；E-22 |
| AC-API-05 | 下载前异常／部分binary异常 | 前者尝试ReturnMsg；后者结果未知，不让UI宣称下载成功；E-22、TODO-04 |
| AC-API-06 | 目标文字包含中文及br字面 | 保留UTF8文字节点规定；与旧HTML换行形式冲突保留，不默默移除／注入；E-21/05，TODO-02 |

这些是契約核對案例，實際执行在tracking；没有真实HTTP调用、机讀OpenAPI parser或业务stub测试。後端源仅Markdown，故不主动生成空OpenAPI壳或 server/security 推測。
