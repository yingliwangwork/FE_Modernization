# AF-AFY10400：後端責任移交 v1

這些是有來源的待承接需求，不是可呼叫API或新增正式scope。根入口證據E-01..05；选定基準E-21/22；legacy业务語意E-23/24/25。連結 [設計](../../design/AF-AFY10400/specification.md)、[API](api-spec.md)、[tracking](../../renovation/AF-AFY10400/tracking.md)。

<a id="handoff-01"></a>
## HANDOFF-01：拒絕結果仍能逐列顯示

FLOW-05/BOUND-01，輸入為DATA-01/02/03；回應拒絕時先按當時列的當時ID回填DATA-04，然後共用完成訊息，绝不下載。E-05，根 L107-113；legacy 方法在错誤回應前可先輸出初步／查无逐列rtnMap，E-23 L31-45/56-100。指定目标共同错误为 data=null（E-21），没有可确认逐列結果输出，不能以默认空map覆写所有列来伪装相容。待后端／产品确认如何承接或明确变更体验；不预设新endpoint、额外schema或固定错误值。[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)。承接核对AC-09/AC-API-03，须保留逐列结果的具体版本与回應验证。

<a id="handoff-02"></a>
## HANDOFF-02：匯出後同頁下載交接

FLOW-05/BOUND-02，在成功回填全部列之后以服务回传檔名DATA-05交接；旧RPTUtil同步取得加密下载檔名/路径，再同頁隐藏表单提交，isOpenNewBrowse=false。E-05/17/25，非前端自行生成可信路径。目标API-02直接binary，是可确认的新传输契约，但旧加密参数链不能直接继续；需确认符合相同用户下载体验的承接与下载前／部分binary异常呈现，不把旧字段加进目标schema。[TODO-02](../../renovation/AF-AFY10400/tracking.md#todo-02)；正式接收者/header与错误结果 [TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)。测试AC-07/08/AC-API-04/05，无来源的取消／回滚不追加。

<a id="handoff-03"></a>
## HANDOFF-03：可信入口情境、功能政策及複製軌跡

LOGIC-04/05/06、FLOW-01/08、BOUND-03/04、DATA-06/07/08。首次渲染前由共用tag設定資源／dispatcher；功能資訊提供政策及浮水印，session提供員工識別與server時間；入口消息依外部來源。根页没有前端合法来源可自行编出這些受信任值。E-06/08/09。先確認可信情境，后按條件渲染與load；政策啟用时每次不同非空复制，保留全文去重、独立60秒清除、裁切及原长，再外部記錄；写入成功、授權与记录服务内部未提供，E-07。目标OPENAPI只涵盖AFY操作与已知Auth缺口，prompt四字段未承接这些要求。需要后端／外部方提供适用情境及记录契約，不把它們改成產品可输入配置，不指定新初始化API。[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)/[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)。浮水印视觉接收者另TODO-05。核对AC-10/15/16，以授权者設定＋輸出证据支撑；未查到不宣称能力不存在。

<a id="handoff-04"></a>
## HANDOFF-04：匯出業務與稽核副作用的承接證據

legacy业务语意E-23：取得组合与两平行集合 → null/长度一致检查 → 每列trim ID長度10及保单非空的结果资料 → CRLF拆分并滤空白 → 记录每笔ID安全日誌 → 查询 → 各ID及主保单号比对，全部有資料为「已匯出」、缺少则「被保人：{id} 查無保單號碼：{policy}。」按br串接 → 查無全部資料「查無資料」 → 可信服务日期組prod+insr_YYYYMMDD.xlsx → 產54欄Excel。前置sb被每列重置使后置檢核无效，这是来源缺陷，不自行改成阻断错误。输出原文与副作用属于后端责任，原型不能用本机算法证明承接。承保／收件 × 个险／团险／意外险的查询分支由E-23的方法语意记录；target OPENAPI说产Excel及可能错误，不证明上述所有业务、副作用、格式与实际运行都已相同。

需要核对目标业务版本：是否保留逐列查询結果与缺少资料、服务日期檔名、查询前每ID稽核、Excel54栏与日期/time转换及异常责任。未提供事务／回滚保证，不推导新原子性要求。E-23自身例子檔名使用非UI代码、日期说明yyy与8位padding不同，应以方法步骤为legacy语意线索且记录差异，不能当wire规则。目标Service承接、可信日期和稽核契約未確認 [TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)，与字段边界相关TODO-02；关联AC-API-01/02/03、AC-09。移交文件生成不意味职责已承接或稽核已写入。

## 承接索引

| HANDOFF | 已确认相关目标操作 | 仍需证实 |
| --- | --- | --- |
| 01 | API-01能匯出并有成功map；E-22 | 拒絕map、結果格式与訊息顺序；TODO-02 |
| 02 | API-02支持JSON/form与binary；E-22 | 同頁体验映射、正式headers/异常；TODO-02/04 |
| 03 | 未取得适用可信情境／记录操作；不能说不存在 | 配置、session、外部消息、copy记录；TODO-01/04/05 |
| 04 | API-01产Excel目的；E-22 | legacy细节与实际业务／稽核执行版本；TODO-02/04 |
