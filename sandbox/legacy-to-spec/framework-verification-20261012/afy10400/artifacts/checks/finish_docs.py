from pathlib import Path
import hashlib,json,re
S='AF-AFY10400';D=Path('artifacts/design')/S;I=Path('artifacts/integration')/S;R=Path('artifacts/renovation')/S
inv=json.loads((R/'source-inventory.json').read_text())['files'];by={r['path']:r for r in inv}
def w(p,t):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(t.strip()+'\n')
def gap(n):return f'[TODO-{n:02}](../../renovation/{S}/tracking.md#todo-{n:02})'
api='''# AF-AFY10400：API 消費契約 v1

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
'''
w(I/'api-spec.md',api)

handoff='''# AF-AFY10400：後端責任移交 v1

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
'''
w(I/'backend-handoff.md',handoff)

# Source-backed style values and per-declaration mapping, no invented palette.
styles={
'CMP-PAGE':('全頁與標題',{'page':'#F0FBC6','frame':'#003366','title':'#339900'},"  page:\n    fontFamily: \"'PMingLiU', 'MingLiU', 'Microsoft JhengHei', 'Meiryo', 'Arial', 'Arial Unicode MS', 'Helvetica', 'sans-serif', 'Verdana', 'Trebuchet MS'\"\n  title:\n    fontSize: '10pt'\n    fontWeight: bold\n    letterSpacing: '3pt'",'E-02/08/20','TODO-05/06/07'),
'CMP-FORM':('表格按鈕與輸入',{'table':'#C7E49C','odd':'#EEF1A7','even':'#FAFBE1','header':'#99CCFF','buttonText':'#006600'},"  table:\n    fontSize: '10pt'\n    lineHeight: '21px'\n  input:\n    fontSize: '12px'\n    letterSpacing: '1pt'\n  button:\n    fontSize: '10pt'\n    lineHeight: '19px'",'E-01/03/20','TODO-05/07'),
'CMP-COVER':('請求遮罩',{},None,'E-11','TODO-05/07'),
'CMP-MESSAGE':('自訂訊息視窗',{'window':'#0066CC','content':'#FFFFFF','footer':'#EEEEEE','title':'#FFFFFF'},"  message:\n    fontFamily: 'Verdana, Arial, sans-serif, 微軟正黑體'\n    fontSize: '10pt'",'E-12/20','TODO-03/05/07')}
for ci,(name,colors,typ,ev,gaps) in styles.items():
 front='---\nversion: alpha\nname: "'+ci+' — '+name+'"\n'
 if colors:front+='colors:\n'+''.join('  '+k+': "'+v+'"\n' for k,v in colors.items())
 if typ:front+='typography:\n'+typ+'\n'
 front+='---\n'
 css=(D/'styles'/f'{ci}.css').read_text();css_clean=re.sub(r'/\*.*?\*/','',css,flags=re.S)
 rows=[];idx=1
 for selector,body in re.findall(r'([^{}]+)\{([^{}]*)\}',css_clean):
  selector=selector.strip()
  for decl in body.split(';'):
   if ':' not in decl:continue
   prop,val=decl.split(':',1);prop=prop.strip();val=val.strip();rows.append(f'| STYLE-{ci[4:]}-{idx:02} | `{selector}` | 正文規則；部分值对应frontmatter | `{prop}` = `{val}` | {ev} | SCR-01，依下述狀態操作；computed须按值核對，V结果另記 |');idx+=1
 extra=''
 if ci=='CMP-MESSAGE':extra='''首次width=clamp(正規化msg含呈現標記長度×15,180,600)px；重複訊息僅增長不縮小的判定见common-contracts；height初值105px，內容高度不因多筆改大而是overflow auto。top=parseInt(body.clientHeight/4+scrollTop)，left=parseInt((body.clientWidth-window.outerWidth)/2+scrollLeft)。拖曳框width/height等於視窗當時outer dimensions；move随pointer偏移，mouseup視窗採框位置。這些是prototype.js動態inline來源公式，不覆寫另一套CSS。來源title的fontWeight鍵末尾空白未确认有效，不新增bold。STYLE-MESSAGE-DYNAMIC，E-12。'''
 if ci=='CMP-COVER':extra='''Chrome分支position fixed、宽高100%、层级150、光标progress；旧IE absolute只知长高不减的resize，浏览器差異未驗證。缺png/gif不创造透明黑底、loading spinner或文字；有遮罩几何／阻隔但视觉部分交付。'''
 if ci=='CMP-PAGE':extra='''body字型继承与EUDC @font-face源条件已知、真实字体缺失；难字不能宣稱等價。主框97%、顶栏30px、绝对0/0/z9。条件print样式作用于body所有子元素，不能只局限产品容器。框圖4px、留白圖5px及icon18×16的资源缺少，原型不补造图像或形似图标；这些具体未展示尺寸连TODO-05。'''
 if ci=='CMP-FORM':extra='''button的根选择器后置padding0 10px覆写基础0；message-ok inline已知padding0 15px另见CMP-MESSAGE。inputs/textarea字型明确；select保持浏览器原生尺寸/字体。rows3/cols30/size12/max10是HTML配置，实际px不捏造。按新增/删除重新配列，首列odd。later read-only规则只在控件符合状态时透明/无border，不误用到可编辑文本。'''
 text=front+f'''\n# {ci} 样式規格

## Overview

適用AF-AFY10400 v1 / SCR-01；证据{ev}，参见 [tracking](../../../../renovation/AF-AFY10400/tracking.md)。[CSS](../../styles/{ci}.css) 由 [prototype](../../prototypes/SCR-01.html) 实际载入。DESIGN.md alpha profile依所附skill规则，未上网核对最新规范；该选择是快照基准。省略spacing/rounded群組：没有来源尺度／圓角系统；精確padding/margin在下表保留，不自創tokens。CMP-COVER没有已知可用图像颜色，故也省略colors与typography；瀏覽器原生／继承结果按实际环境核对。

## Colors

frontmatter已列可确认值；下表gradient与边框精确值也属于契约，不扩大为系统主题。缺少图片与后载calendar CSS导致最终cascade不完整：'''+', '.join(f'[{g}](../../../../renovation/{S}/tracking.md#{g.lower()})' for g in [('TODO-'+x) if not x.startswith('TODO-') else x for x in gaps.split('/')])+'''.

## Typography

以输入、body或讯息的來源宣告／继承为準。pt不改成猜测px；font实际是否存在、native控件外观与回退须浏览器验证。

## Layout

'''+extra+'''

## Elevation & Depth

仅使用CSS表已列的边框、层级与shadow；review.css的dashed panel为工具，不属产品。无证据的hover/focus/disabled业务状态不添加。

## Shapes

未确认圆角或shape尺度；保留原生元素及来源边框，不建立圆角token。

## Components

| STYLE | selector／条件 | token／正文映射 | 規範property与宣告值（实际CSS同值） | 证据 | 原型与检查步骤／预期 |
| --- | --- | --- | --- | --- | --- |
'''+ '\n'.join(rows)+'''

测试定义：开SCR-01，初始／新增2列／删除／匯出等待／注入自订消息／重复长短讯息／拖曳各状态，逐selector读取computedStyle并将浏览器规范化值与本表比较；root padding、几何及动态公式单独量测。实测结果留tracking V，不把文字同值当computed已经通过。未取得legacy运行画面，不宣称像素等价。缺少来源样式的局部TODO在specification对应CMP/UI/ST亦可见。

## Do's and Don'ts

保持来源顺序、已知颜色及单位；不增加工具样式作为产品需求；不用合成资源宣稱缺少图像已还原。
'''
 # Fix each TODO slug rather than incomplete split fragments.
 text=text.replace('TODO-05/06/07','TODO-05、TODO-06、TODO-07')
 w(D/'components'/ci/'DESIGN.md',text)
print('API, handoff, and four DESIGN/CSS mappings generated.')
