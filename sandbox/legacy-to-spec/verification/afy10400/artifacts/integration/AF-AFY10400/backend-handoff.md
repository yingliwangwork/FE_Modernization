# AF-AFY10400：未承接後端責任與相容需求

需求v1；唯一根入口E-01–04，必要include E-06，交換helper E-11。與指定OPENAPI E-12對照；方法語意E-13–15只支持legacy責任。這些需求不是已存在API，沒有新增端點。[前端規格](../../design/AF-AFY10400/specification.md)；[API投影](api-spec.md)；[追蹤](../../renovation/AF-AFY10400/tracking.md)。

## HANDOFF-01

功能政策、身分與環境初始化。FLOW-01/06、BOUND-04、DATA-09、LOGIC-01/02/03/04。E-06：進入頁面先由交易名稱去底線／請求路徑取功能識別；非空才查功能設定，首筆取操作政策與浮水印旗標Y。可信登入者員編null時退姓名，null再空；服務端產生yyyy-MM-dd HH:mm:ss。配置字元bytes、難字來源、回應時間識別與登入平台等同樣來自可信環境。前端可執行顯示與事件政策，但不能任填員編/旗標冒充服務。查功能無資料／例外時不生成該條件政策（原例外僅log），实际採哪個旗標未知。

OPENAPI prompt只insrDate/showEdit/showQuery/rtype，不能作policy/watermark/data-context承接證據。需後端提供合法情境与功能决策来源，不指定傳輸方式。浮水印工具本身未知归呈現依賴[TODO-04](../../renovation/AF-AFY10400/tracking.md#todo-04)，不要求後端生成圖形。驗證AC-08要確認實際旗標並逐条件驗證；初始化來源與fallback需可定位证据。[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)。

## HANDOFF-02

复制稽核交接。FLOW-07、BOUND-03、LOGIC-05。E-06：政策启用後body copy取得正規化選取；空/同前笔不送，非空新內容传經必要编码/5000字截断后的内容、功能识别、原全文长度、時間。每筆獨立60秒清前筆缓存，旧计時不取消。前端负责選取/比對/時間事件，後端负责信任情境与紀錄写入，不能以image请求存在当寫入成功。

当前OPENAPI没有scope copy日誌能力證據；需确认接收與可信身份绑定、接受內容/長度/功能語意、结果與失败责任。原片段沒有成功/失敗回調與回滾保证，不發明用户警示或交易原子性。AC-09验证旧計時交錯、長文本截斷、重复不发、日誌接收结果独立確認。[TODO-01](../../renovation/AF-AFY10400/tracking.md#todo-01)。

## HANDOFF-03

匯出失敗逐列結果與顯示相容。FLOW-04、BOUND-01、DATA-06、UI-09、LOGIC-07/08。E-03成功与failureAction均读rtnMap并逐ID回填，只有成功取fileName下載。E-13方法規格先輸出初步結果後查询及更新结果，可能在查無資料／Excel產生失败带错误消息；可见逐列文案含「已匯出」、查无保单字串，可能有`<br>`，不得由前端重製查询/成功判斷。

API-01 E-12已有成功rtnMap/fileName；但所有目标handler错误data=null，不保证failureAction需要的映射；target文字節點要求与legacy markup解释有差距。需後端或已核准变更证据说明哪些失败保留逐列结果、格式/换行如何呈现與消息次序，不發明字段，也不把每列改为通用失败。各ID业务結果、查詢、Excel寫入、安全操作紀錄等服務责任由E-13說明，OPENAPI不能證明全部實作已等價。AC-05/06/14确认成功与逐列失败不同路径；不可把交付本移交文件当已承接。[TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)。

## HANDOFF-04

下载相容责任。FLOW-05、BOUND-02、LOGIC-09。E-03先回填再请求下載，E-11同步JSON→加密名稱/完整路径→FileDownload，无新窗口；E-14方法语意以交易目录/fileName换取加密下载资讯、失败给异常文字。E-12已提供直接octet-stream二进制，附件header只stub确认，例外先/部分输出有不同不确定性。

需承接原用户可见意图（成功匯出后自动下载、不另开窗）与目標binary的相容方式，明确错误/部分输出之结果；後端可选择合适机制，不要求恢复旧私有字段或特定实现。前端不能拼真实目录/加密下载参数或把binary当JSON，原型不产生/写入Excel。AC-12按JSON/form、成功、预先例外、部分输出验证；目标service真实环境与正式headers [TODO-05](../../renovation/AF-AFY10400/tracking.md#todo-05)，helper到target差距 [TODO-03](../../renovation/AF-AFY10400/tracking.md#todo-03)。

## 承接依據與順序

| HANDOFF | 已取得目标覆盖 | 仍需证据 | 输入输出／順序 |
|---|---|---|---|
| 01 | API prompt存在但未涵盖policy/context | 配置、功能及登入情境來源，不能client自填 | 可信DATA-09→FLOW-01条件呈現→FLOW-06/07 |
| 02 | 未取得copy操作契约 | 稽核写入、信任來源与结果責任 | 本頁选取/正規化/独立计時→BOUND-03→记录服務 |
| 03 | API-01成功payload | 失败逐列结果与原文格式相容；无rollback证据 | 分类+平行列→服务判定/查詢/檔案→逐列结果→下载 |
| 04 | API-02binary | 原helper JSON链差距、正式adapter/headers | API-01檔名→回填後交接→下載接收者 |

改造责任不由執行位置決定；业务查詢、資料有效性、安全稽核、檔案副作用皆不会进入原型。本输入没有可定位的跨API交易原子性/取消/重试保证，保留未知，不能用前端补偿算法冒充。
