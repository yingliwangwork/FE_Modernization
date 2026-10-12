# AF-AFY10400：翻新追蹤

[設計規格](../../design/AF-AFY10400/specification.md) · [原型](../../design/AF-AFY10400/prototypes/SCR-001.html) · [API](../../integration/AF-AFY10400/api-spec.md) · [移交](../../integration/AF-AFY10400/backend-handoff.md)

## 1. 本輪來源與邊界

| 項目 | 內容 |
| --- | --- |
| Scope | AF-AFY10400 |
| 唯一根 JSP | `inputs/frontend/sourceCode/AF/AFY10400.jsp` |
| SHA-256 | `fbf8f94aee2f03f830f5092ba280dca6f6707ce45d54a929e6ec7cecd4284b1a` |
| 編碼／行號 | 根 JSP 宣告 BIG5；原 bytes 可嚴格 big5 解碼，CRLF，246 行；以原行號分析，stdout 轉 UTF-8，未改原件 |
| 分析日期／執行者 | 2026-10-12／Codex，受控單一快照案例 |
| 契約版本／增量 | 1.0，首次 CHANGE-001 |
| 纳入 | 本页全部标頭／说明／两个组合／零列初始化／新增删除／检核／成功拒绝回填／同窗下载／入口和非同步共用消息／条件政策／浮水印调用边界 |
| 排除 | 其他入口的内部；外部宿主／WI／共用 tag／字型／图片／浮水印引擎内部未提供；真实查询／稽核／產檔不在 prototype 实作 |
| backend_root | `inputs/backend`，使用任务明确指定 `docs/OPENAPI.md`（E-010B、011） |
| 基准版本／雜湊 | 2026-08-12，0.0.1-SNAPSHOT，OpenAPI3.1.0；SHA-256 `13307ed1144946124179d6e02148999e64783e031d440aacc8ff54e03c32f1ef` |
| 性質／環境 | 文件自述目前 Controller／DTO 盘点；默认 stub；其他方法文件为 legacy 语意；未查询外部或执行后端，部署未知 |
| 狀態 | 部分交付：已还原可读来源的已知契约与全部已知条件分支；未解 TODO、无浏览器／正式介接验证；不宣告完整翻新 |

### 依賴邊界與版本

以下原文件 hash 已在 [input-integrity.json](../../checks/input-integrity.json) 与 manifest 逐一实算对比；不使用 origin 路径读取父项目。

| 依賴（均相對 inputs/frontend/sourceCode） | 本輪用途／讀取範圍／停止邊界 | 结果 |
| --- | --- | --- |
| CM/header.jsp | 全部可定位入口情境／PD控制／稽核／浮水印／字型選擇；不追外部 Java 类、tag 或引擎 | E-009，TODO-004、005 |
| CM/msgDisplayer.jsp | 完整188行，本入口初始化及按钮清底部；不翻新 bottomFrame 页面 | E-006，TODO-001、005 |
| CM/css/cm.css | 本頁实际 BODY、文字框、button、tbBox2、subTitle、tbYellow／Yellow2、Blue | E-010；画像 URL 不載入，TODO-005 |
| CM/js/ajax/prototype.js | 表单序列化6475～6524、换行／重复名字及回调顺序相关段；不重写整个库 | E-013 |
| CM/js/ajax/CSRUtil.js | return判定1～29、request/responder371～744、MsgWin1409～1696、UICore2509～2594、注册2618～2638；有条件消息全部保留 | E-007，TODO-001、005、006 |
| CM/js/RPTUtil.js | 判定15～30、同步请求67～188、form204起、download656～688；止于 FileDownload 交接 | E-008，TODO-003 |
| CM/js/HotKey.js | 完整107行，本页无快捷键注册；只设 document.onkeydown dispatch | E-014；不新增匯出快捷键 |
| CM/js/ui/PageUI.js | 检查事件注册辅助和尾段；root没有使用该库控制配置 | E-014；不据库示例新增事件 |
| CM/js/Validator.js | 定义及尾段检查，root未实例化／调用，不新增ID十码前端检核 | E-014 |
| CM/js/calendar.js | 事件注册／末段检查，root无日期UI或调用，未将库能力当本页行为 | E-014 |
| CM/js/date.js | 檔案存在，嚴格 utf8／big5 都解碼失敗，无法可靠分析内容；root没有直接日期调用 | TODO-009；保留未知，不猜或修改原件 |
| 缺少依賴：CM 圖片、watermark-js-plus.js、EUDC字型、CXL tag／Java模块、WI／jQuery与 bottomFrame 本體 | 仅保留已知引入条件／调用结果；未提供则不从其他目录查找 | TODO-004、005 |
| backend/docs/specs/AFY1_0400 三份方法文件 | prompt、export与相关模块语意、download语意；仅参考旧职责，不覆盖选定HTTP基准 | E-012P、012、012D |

## 2. 工作與進度

| 工作 | 完成条件／状态 | 结果 |
| --- | --- | --- |
| WORK-001 | 精確單一來源与快照登记／完成 | 根源码246行；32份输入hash比对 |
| WORK-002 | 可读来源所有已知事件及分支映射／完成，有依赖未知 | E、FLOW、TR、AC、LOGIC 与 TODO |
| WORK-003 | 规范／API／handoff文档与离线原型／完成 | 上述四个文件；不等于契約完整 |
| WORK-004 | 静态语法／链接／占位／不可变检查／完成 | V-001～004，checks/ 记录 |
| WORK-005 | 浏览器实际操作及真实后端验证／本轮未执行 | 按任务禁止browser setup／真实系统调用，TODO-007；父代理可独立补记录 |

## 3. 證據登錄

每项来源版本见 manifest及实算hash记录。行号為原文件，不靠注释推断行为；以下全部是静态来源证据，不是浏览器执行结果。

| E | 可定位来源／原行号 | 最小事实／支持主張 | 限制 |
| --- | --- | --- | --- |
| E-001 | 根JSP1～31、128 | BIG5、依赖、initApp：unique_num=0，取得table，displayMessage | 入口消息实际值未知，無自动新增列 |
| E-002 | 根JSP22～65 | 单调行ID，追加四格，ID maxlength10、textarea3×30、结果空；删指定列无确认 | 不支持最少一列、焦点自动迁移 |
| E-003 | 根JSP67～114 | 列 i 空字串→后列 j 重复→实际Form.serialize；两回调读rtnMap；成功回填后下载false | 暂存param非送出来源；目标错误不能从此补schema |
| E-004 | 根JSP116～124 | 行位置3起，偶#FAFBE1、奇#EEF1A7 | 保留重新排列，无像素观察 |
| E-005 | 根JSP128～244 | 双标题、编号、说明原文、默认L/AT、全部选项、四列头、按钮顺序 | 图片本体缺；业务目的仅限操作说明支持范围 |
| E-006 | CM/msgDisplayer.jsp1～188 | 缺msg建立0；入口码0/99不alert、异常原文、WI条件；首笔底部、回退flag提前return；按钮click清底部 | 框架及WI本体未知；不能一概用异步文案代替入口文案 |
| E-007 | CM/js/ajax/CSRUtil.js1～29、371～744、1409～1696、2509～2594、2618～2638 | ErrMsg.returnCode==0；遮罩；回调先执行后onComplete；普通／特定／EP提示，msgid>17；自訂确定焦点、单次keypress、确定停止传播 | 实际URL模式未知；本页没timeout，不把库示例当实用值；网络异常UI不完整 |
| E-008 | CM/js/RPTUtil.js15～30、67～188、204～254、656～688；根JSP106 | 同步取下载资讯，取得加密name/fullPath后form；isOpenNewBrowse=false，same window | target直接binary有差异，正式adapter未验证 |
| E-009 | CM/header.jsp26～65、67～264、266～413 | 可信基址、配置、PD_CTRL、控制键／右键／copy稽核；session用户回退、服务时间、浮水印配置、字体条件 | 类／tag／引擎资源缺；不能假设本次flag真，未证明服务授权 |
| E-010 | CM/css/cm.css1～15、63～71、108～126、182～199、260～284 | 原頁字型優先序、字级、绿框、绿背景／蓝表头、按钮渐层 | 不加载未提供图片，无legacy像素对照 |
| E-010B | backend/docs/OPENAPI.md1～67、744～752 | 2026-08-12基准、Server/context、默认stub、Security未声明、完整ReturnMsg与HTTP200/code500/data null | 人工Markdown，无机器parser契约，无正式部署证明 |
| E-011 | backend/docs/OPENAPI.md82～84、497～570 | prompt/promp，rtype；export精确平行数组及map；download两种媒体、binary及stubheader／部分错误未知 | 目标错误无map、初始化outputs本页不读 |
| E-012P | backend/docs/specs/AFY1_0400/AFY1_0400_doPrompt.md，完整方法章节 | 旧日期及N/false；rtype目标命名以前述基准为准 | 无法推导HTTP；无本页消费证据 |
| E-012 | backend/docs/specs/AFY1_0400/AFY1_0400_doExport.md，doExport／logSecurity／doQuery／createExcel章节 | CRLF多行、初步map、稽核、结果文字、查无资料、产檔副作用／业务条件 | legacy语意不能覆盖目标data null，也不在prototype重制Excel/查询 |
| E-012D | backend/docs/specs/AFY1_0400/AFY1_0400_doDownload.md，doDownload章节 | 旧可信交易目录与加密下载信息 | 无目标adapter部署证据 |
| E-013 | CM/js/ajax/prototype.js6475～6524，AJAX完成路径 | serialize顺序、同名键重复、LF正規化CRLF；回调在完成responder之前 | 零列Form不包含两个数组，不代表目标空数组等价 |
| E-014 | CM/js/HotKey.js1～107；PageUI、Validator、calendar事件／尾段及根JSP9～16 | root无HotKeys注册、无Validator／calendar／PageUI调用；仅库定义不足以新增功能 | date.js不可解码，依赖内未辨识行为保留TODO-009 |

## 4. 來源→契約覆蓋

| 源定位 | 類型／事实 | E | 契約／原型去向 | 案例／结论 |
| --- | --- | --- | --- | --- |
| root27～31、128 | onLoad／零计数／消息 | E-001、006 | FLOW-001，ST-001，SCR-001 | AC-001、011；已映射，真实情境TODO-001 |
| root33～59 | 新增四格／内部ID | E-002 | FLOW-002，UI-007～011，TR-002 | AC-002；本机可展示 |
| root61～65 | 删除及recolor | E-002、004 | FLOW-003，TR-003 | AC-002、017 |
| root67～94 | 组合同步读取／空值／重复顺序 | E-003 | FLOW-004，BR-001、002，TR-004～006 | AC-003～007 |
| root95～97 | 实际表单请求，param未传 | E-003、013 | BOUND-001，API-002，LOGIC-003 | AC-005、007；零列映射TODO-006 |
| root98～113 | 成功／拒绝回填、成功下载 | E-003 | FLOW-005，TR-007、008，UI-011 | AC-008～010，HANDOFF-001/002 |
| root116～124 | 当前顺序交错颜色 | E-004 | CMP-003／UI-009～011 | AC-002 |
| root128～181 | 标题／框／图片 | E-005、010 | UI-001、002／SCR-001 | AC-001，圖片TODO-005 |
| root187～230 | form、说明、组合作用、表头、匯出 | E-005 | UI-003～007、012／DATA-001～005 | AC-001、007、017 |
| include msgDisplayer | 入口首条底部／回退／0/99／异常／WI | E-006 | CMP-001、MSG-003、004，FLOW-001 | AC-011；native已映射，WI/宿主TODO-005 |
| msgDisplayer174～185 | 任意产品button／submit清底部 | E-006 | BOUND-003／FLOW-002～004 | AC-002、017；review宿主替身 |
| CSR request/responder | 遮罩／普通错误／普通成功／特定错误／特定成功／EP／无msg | E-007 | CMP-002／FLOW-006，MSG-005～007 | AC-012～014；各分支保留，实际选择TODO-001 |
| MsgWin1451～1473、1609～1632、1673 | 确定停止传播／焦点／单次按键 | E-007 | UI-013／ST-008／TR-009 | AC-013，原型保留首个无關键解除规则 |
| RPT download chain | 同窗下载参数hidden传递 | E-008 | BOUND-002／FLOW-005／API-003 | AC-008、018；只记录边界，不新造UI |
| header可信配置 | 动态显示policy／复制稽核 | E-009 | FLOW-007／CMP-004，HANDOFF-003 | AC-015；本机展示不写日志 |
| header浮水印／字体 | 独立条件／session／时间／资源副作用 | E-009 | FLOW-008／DATA-009，HANDOFF-003 | AC-016；不可模拟引擎，TODO-005 |
| root hidden/session/response盘点 | 根本身无hidden、session写入或业务交易；include有可信session读与资源/稽核，RPT另建hidden | E-001、005、008、009 | LOGIC-005～009；不是“无后端责任” | AC-008、015、016 |
| backend选定契约 | wire命名／错误封套／媒体 | E-010B、011 | API-001～003／TR-010／HANDOFF | AC-010、018；仅契约核对 |
| 引入其余库 | 无本页调用点不生成示例功能，date不可读仍列入分母限制 | E-014 | TODO-009；不适用“快捷匯出／日期输入”有root对照 | 未证明全依赖行为完整 |

### 4.1 耦合责任 LOGIC 盘点

| LOGIC／源 | 顺序、输入与条件 | 分責／去向／承接 |
| --- | --- | --- |
| LOGIC-001 root27～31、128 | 建立client计数→table→入口讯息 | 呈现／FLOW-001；消息取得另LOGIC-006 |
| LOGIC-002 root33～65、116～124 | 追加／刪除→上色，保留值与内在识别 | 前端操作与呈现／FLOW-002、003，无后端业务运算 |
| LOGIC-003 root67～97 | 读取UI→逐列检查→序列化请求；暂无后端计算 | 前端检查保留BR-001／002；API-002仅业务边界，不以客户端检查代后端 |
| LOGIC-004 root98～113 | 外部结果按ID回填→成功下载；拒绝无下载 | 已知呈现转换；目标成功E-011覆盖，拒绝HANDOFF-001／TODO-002 |
| LOGIC-005 root106、RPT656～688 | 成功檔名→同步下载info→hidden form同窗 | 混合：呈现交接与加密檔案责任；API-003已存在但方式差异HANDOFF-002 |
| LOGIC-006 msgDisplayer1～58、137～170 | 受信任回应转消息集合→底部首条→异常或0/99分支 | 受信任数据与呈现拆分；CMP-001，HANDOFF-003；prompt不承接消息 |
| LOGIC-007 header26～98 | 基址／login参数→功能ID→查询配置首笔→两个独立flag | 受信任配置／外部数据读取；FLOW-007/008，HANDOFF-003／TODO-004 |
| LOGIC-008 header128～183 | policy成立→阻止/复制不阻止→空白归一、去重、裁切→日志边界 | UI政策前端，日志副作用后端；原型仅记录，不访问稽核URL；HANDOFF-003 |
| LOGIC-009 header266～413 | session用户→编号/姓名回退→服务时间→条件引擎；host条件字体URL | 受信任情境／显示混合；FLOW-008，HANDOFF-003，引擎资源TODO-005 |
| LOGIC-010 CSR371～744、MsgWin | 请求建立cover→回调业务呈现→完成消息→条件关闭 | 前端共用体验CMP-002；策略实际条件TODO-001，不把加载遮罩当交易保证 |

### 4.2 API／handoff 追踪

| 项目 | 已确认／差距 | 状态与证据 |
| --- | --- | --- |
| API-001 | 操作有但本页无消费，rtype不写旧名 | 文档映射完成，未调用；E-011 |
| API-002 | 完整共通封套／四个request／map/name已转写 | 成功投影完成；错误HANDOFF-001，未验证 |
| API-003 | 两种媒体／binary／stubheader／两种异常 | 投影完成，HANDOFF-002未关闭 |
| HANDOFF-001 | 旧错误map与目标data null | 待确认等价承接或经确认变更，TODO-002 |
| HANDOFF-002 | 旧加密链与目标binary | 待正式adapter／体验证据，TODO-003 |
| HANDOFF-003 | 可信配置、消息、稽核、浮水印 | 待目标共用证据，TODO-001、004、005 |

## 5. TODO 与契約缺口

### TODO-001
未知／开启。入口真实消息、宿主URL／底部／WI、角色、正式认证环境没有提供。E-006、007、009、010B定义了条件分支，不代表本次实际条件。影响FLOW-001、006、API与CMP。下一步取得受控入口渲染上下文及目标gateway共用契约；以各分支环境证据／消息映射验证解決。尚未解决。

### TODO-002
契约差距／开启。E-003两回调均读取rtnMap，E-010B／011错误data=null；不能用E-012旧语意升格目标能力。影响TR-008、010／HANDOFF-001／AC-009、010。下一步向后端交付逐列错误需求，取得明确承接或确认变更及测试结果。尚未解决，原型目标错误停在差距。

### TODO-003
契约差距／开启。旧同步加密资讯与目标binary不同；正式headers、同窗体验与部分写入错误不明确。影响BOUND-002／HANDOFF-002／AC-018。下一步取得正式adapter契约及受控下载观察；核对不新增窗口、错误与binary分支。尚未解决。

### TODO-004
未承接证据／开启。header的功能配置、session身分／时间、稽核、tag、复制日志未有目标承接契约；没有证据不能写“后端不存在”。影响FLOW-007、008／LOGIC-007～009／HANDOFF-003。取得共用基础设施及目标trusted context契约并验证已知顺序。尚未解决。

### TODO-005
缺少依赖／开启。图片、底部页面、WI本体、字体、浮水印脚本、tag／Java依赖未提供。影响外观、WI关闭、浮水印与用户信任context。取得与快照匹配依赖后核对分支和视覺；不以画图或猜源码替代。尚未解决，FLOW-008未在HTML假造引擎。

### TODO-006
未知／开启。无map／缺key、HTTP失败、空值／省略／零列数组接受、下载取消、幂等、回滚／重送、竞态未经契约定义。E-003保留零列和回填，E-010B/011不提供所有保障。影响API-002/003／AC-005、018。下一步取得后端边界契约或受控观察，逐分支记录；未知不能直接补通用fallback。尚未解决。

### TODO-007
未验证／开启。按任务不设置或启动browser、不调用后端；缺旧执行画面、视觉／交互／控制台／连网实际检查。影响所有AC及视觉等价。下一步由有权限的独立父执行者按AC场景真正开HTML并记录截图／结果，后续真实介接另需环境。静态检查不关闭本TODO。尚未解决。

### TODO-008
目标换行语意未知／开启。E-013旧serializer正規化CRLF、E-012旧服务按CRLF分割，目标E-011只说array<string>没有明确分割规则。影响多保单AC-007。投影描述旧转换及尚待确认目标，未把JSON自动换行当已验证。取得目标service契约与多行测试后关闭。尚未解决。

### TODO-009
依赖不可可靠解码／开启。date.js bytes存在且hash匹配；2026-10-12用utf8／big5／cp950／big5hkscs严格解码均报UnicodeDecodeError。root只引入、无直接日期UI或调用，不靠名称推断行为。影响依赖分析完整性。下一步确认原文件实际编码，保留bytes严格解码再查看全局副作用；不得用replace默默替换乱码。尚未解决。

## 6. 原有缺陷與改良提案

| 來源觀察／限制 | 决定 |
| --- | --- |
| E-003 无最少一列／ID最小长度／trim／normalize | 保留当前操作；没有获授权“改善”前端检查 |
| E-003 用innerHTML直接写结果，E-010B要求JSON文字节点呈现 | 原型按已知文字和br换行展示，拒绝任意HTML执行；真实渲染策略需实现阶段确认，记录该呈现安全差异，不将任意HTML执行视为业务要求 |
| E-007自订keydown监听只消费第一次keypress | 保留首个无关键会取消快捷关闭行为；不暗改为持久监听 |
| E-009浮水印卸载处理有拼字／注册关联可疑 | 未执行验证，视为静态线索不是已观察缺陷；引擎未知TODO-005 |
| E-012末尾reset后檢查sb长度的旧逻辑 | 文档保留语意参考，不在前端重制或自主修正后端算法 |

## 7. 本地檢查與交付判定

实际执行细节及退出码在 [local-checks.json](../../checks/local-checks.json)；校验脚本 [check_artifacts.py](../../checks/check_artifacts.py)。

| V | 检查／环境／实际范围 | 结果 | 限制 |
| --- | --- | --- | --- |
| V-001 | macOS 本地 Python，32个 manifest输入／skill hash逐一读取计算 | 32/32匹配；input-integrity.json | 不证明内容行为完整 |
| V-002 | HTML内嵌JS提取，本地node --check | 通过，退出0；prototype-script.js | 语法检查不运行DOM或浏览器交互 |
| V-003 | 本地Python检查HTML ID唯一、初始无資料列／默认组合、引用ID在规范、无模板占位、Markdown相对链接存在 | 首轮报告尚未生成时其自引用链接缺1个；报告形成后复查26链接全通过，首轮保留local-checks-first.json；local-checks.json | 不测像素／布局／键盘／控制台 |
| V-004 | input全部hash再检查；HTML无script src/link stylesheet/remote img；内嵌JS无fetch/XHR | 通过；local-checks.json | 静态离线约束检查，不宣称实测浏览器无意外请求 |
| V-005 | AC-001～018 browser／旧视觉／真正介接 | 未执行，任务明确禁browser setup和后端调用 | TODO-007、001～009 |

本輪結論：交付文件与已盘点来源映射已完成，本地静态检查实际通过；全范围未知依赖、目标差距、正式情境与视觉／交互验证仍未满足完整验收。覆盖表20项均有映射或具体TODO，但依赖未知行为不计为已穷尽；不发布总体百分率。部分交付，不能称为正式介接完成或视觉等价。

## 8. 增量記錄

| CHANGE／日期 | 来源／证据／产物／TODO／验证 |
| --- | --- |
| CHANGE-001／2026-10-12 | 首次锁定32份输入hash；建立E-001～014及子编号，FLOW/TR/UI/AC/LOGIC、三个API与三个handoff；生成四份文档与一份离线HTML；TODO-001～009开启；V-001～004本地执行，V-005未执行 |
