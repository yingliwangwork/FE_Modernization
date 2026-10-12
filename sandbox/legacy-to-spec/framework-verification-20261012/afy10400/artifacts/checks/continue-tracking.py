from pathlib import Path
import json,re,os,hashlib
R=Path('artifacts/renovation/AF-AFY10400');D=Path('artifacts/design/AF-AFY10400');I=Path('artifacts/integration/AF-AFY10400')
p=D/'specification.md';s=p.read_text().replace('不 trim','不自動去除頭尾空白').replace('不trim','不自動去除頭尾空白').replace('返回map A:a,B:b','返回結果對應 A=a、B=b').replace('R2 map A:second','R2 結果對應 A=second').replace('R1 map A:first','R1 結果對應 A=first').replace('舊拒絕map A:原因','舊拒絕回應帶 A=原因').replace('不補出map','不補出逐列結果');p.write_text(s)
p=R/'tracking.md';s=p.read_text();s=s.replace('# AF-AFY10400：翻新執行與追蹤 v1','# AF-AFY10400：翻新執行與追蹤 v2\n\n第1–8節保留初輪記錄（局部位置表已修復引用）；初輪關於中立化／靜態檢查的主張受F-05/07及引用缺陷修正，不代表當時已完整通過。第9節是本輪審查引導續作。初輪所有原件與失敗報告保留於本case inputs/previous-artifacts及inputs/review-*；未讀取舊case。')
# Rewrite only the malformed lookup table, retaining first-round reports and TODO detail/status.
intro='''### 5.1 實際局部TODO位置核對（v2回讀）

以下表由目前設計／共用／介接／樣式正文回讀，僅列實際存在的局部引用；行號是當前版本定位，證據內容未截成殘缺Markdown。來源行上的ID不是自動推導完整影響閉包；TODO-05/06透過CMP-PAGE明示作用於全頁的UI/ST，未取得依賴仍未完整盤點。初輪位置表的未閉合引用原件保留在輸入快照，V-05初輪PASS不足以證明其可渲染。

| TODO | 目前實際文件及行位置 | 該行TODO的有效追蹤錨點 | 計劃／決策 | 實際回讀 |
| --- | --- | --- | --- | --- |
'''
rows=[]
for path in list(D.rglob('*.md'))+list(I.glob('*.md')):
 for n,line in enumerate(path.read_text().splitlines(),1):
  for num in sorted(set(re.findall(r'\[TODO-(\d+)\]\([^\n)]*#todo-\d+\)',line))):
   rel=os.path.relpath(path,R)
   ids=', '.join(dict.fromkeys(re.findall(r'(?:CMP|DATA|FLOW|UI|ST|BOUND|STYLE|AC|MSG|TR|BR)-[A-Z0-9]+(?:-[A-Z0-9]+)*',line))) or '共用條件／本行正文'
   rows.append(f'| TODO-{num} | [{path.name}]({rel}) L{n}；{ids} | [TODO-{num}](#todo-{num})；原行链接逐字確認完整 | TASK-08/11/12、DEC-04/05 | 已回讀，V-10；不將同列ID出現視為完整閉包 |')
s=re.sub(r'### 5\.1 .*?(?=\n## 6\.)',intro+'\n'.join(rows)+'\n',s,flags=re.S)
# Known-source evidence enriched while retaining E-01..25.
s+='''
## 9. 審查引導續作 v2（framework-verification-20261012）

這是有明示審查資訊的維護續作，不是盲測。先讀本case plan/tracking及task，再建立plan第6節，然後回查相同root與共用原件。新版skill hash已锁定；没有新业务／依赖来源。TODO-01..07均保持开启，仅补验证证据，未更改初轮失败为通过。

### 9.1 新增與精確回查證據

<a id="e-26"></a>
E-26：CSRUtil.js，同E-11 SHA-256，原始L321–326，每次createCoverPage建立／取得後先resize，activeElement具type且匹配button才window.focus；异常记录原诊断文字。補 FLOW-06/CMP-COVER/AC-19及LOGIC-07。當次源定義只證明嘗試，不保證OS焦點轉移。

<a id="e-27"></a>
E-27：同E-12來源，原始L1545–1555移動時將win移出文件；L1613–1625首keypress先以該實例自除，!win.parentNode時直接return，未確認也未Event.stop。補 FLOW-09/10/AC-20、LOGIC-07。

<a id="e-28"></a>
E-28：本case提供的 [初輪語意審查](../../../inputs/review-semantic-review.md)、[初輪結構結果](../../../inputs/review-structure.json)、[初輪瀏覽器結果](../../../inputs/review-browser.json)。角色為本地審查／測試者、資料為合成；引導查證但不作產品行為權威。初輪18情境15PASS/3FAIL：確認按鈕被工具攔截、訊息input border solid、結果center。結構26筆跨行引用訊息需回查成因；實際未閉合引用與DEP欄數是確證。來源判定回查E-01/02/03/07/11/12/20。審查原件自己揭露曾誤讀scenario；本續作只讀提供的審查摘要，不讀scenario，不聲稱盲審。

<a id="e-29"></a>
E-29：父代理2026-10-12明示授權讀本case [browser.json](../../../reports/browser.json) 與 [lifecycle-browser.json](../../../reports/lifecycle-browser.json) 後取得的獨立實測。瀏覽器engine151.0.7922.34、viewport1280×900、本地合成情境；18項PASS及2生命週期PASS。焦點觀察只計focus呼叫，拖曳首鍵使用合成事件；不是實際OS焦點或原生Esc相容性的證明。沒有讀／改scenario或其他reports。runtimeHash核對在V-11，DESIGN文件在瀏覽器期間改動，不能引用報告中的舊DESIGN hashes證明最終文件。

<a id="v2-source-mapping"></a>
### 9.2 中立契約與來源符號映射

| 正式行為語意 | 來源實作定位（仅追踪） | 契約與差距 |
| --- | --- | --- |
| 模式A先回填後完成通知 | CSRUtil L479–499、default responder L518–693；Prototype L1934–1964；Prototype存在時被選用 | CMP-REQUEST/FLOW-06；原Prototype符號移出正式契約；TODO-03部署选择未确认 |
| 模式B替代能力先通知再回填 | CSRUtil L373、389–477，!Prototype且jQuery時分支；可enforceUse_jQuery | CMP-REQUEST/FLOW-06；成功／錯誤／無ErrMsg條件与顺序保留；TODO-03 |
| 外部訊息呈現及必要支援 | msgDisplayer L129–133：WIUtil與jQuery均存在；CSR jQuery branch WIUtil條件 | CMP-ENTRY/REQUEST；完整內部TODO-03 |
| 原生／自訂通知及成功僅收遮罩子情境 | CSRUtil L626–680、UICore L2527–2548，location regex L./R./J./DS/DZ/QB/AN/EP/ZU；EP成功特例 | CMP-REQUEST，分支逐一保留，选择未知TODO-03 |
| 全頁按鈕／送出點擊後清底部 | msgDisplayer L174–185，event.target.type與button,submit字串比對；MsgWin確認stopPropagation | FLOW-07；來源字符串细节留此，不加入产品工具的清底部副作用 |
| 本文文字／換行識別 | CSRUtil L562–577使用精確<body>、</body>及<br>；字面反斜線+n的完成描述處理 | CMP-REQUEST结果语义保留；识别严格性留追踪，不要求实现新框架 |
| 外部初始化及共用尺寸反應 | PageUI initLoad L1261–1269：存在window.init才執行；table/overDiv未建立时返回 | FLOW-01，共用契約；外部init來源TODO-01 |
| 空逐列结果目标拒絕 | OPENAPI L47–57的ReturnMsg code500/data=null；旧ErrMsg returnCode0与rtnMap | DATA-04/FLOW-05中立缺口；准确wire只在API/此表 |
| 首鍵／視窗附著 guard | CSRUtil L1613–1625 document keypress，每个keyPressHandler解除自己；parentNode guard | FLOW-09/10/AC-20；runtime保留首次任意键机制 |
| 条件遮罩聚焦嘗試 | CSRUtil L321–326的getAttribute(type)/button matcher/window.focus | FLOW-06/CMP-COVER/AC-19；无新后端责任 |

### 9.3 F-01..08修正及同步

| Finding | 來源與實際修正 | 同步位置／實際驗證 | 剩餘限制 |
| --- | --- | --- | --- |
| F-01 | review層改200，位於來源cover150之上/message999之下，保留原訊息定位公式，不强制click | review.css、原型工具说明；父browser正常確認/重開PASS，V-11 | 所有viewport或任意工具內容尺寸未全測，不宣稱通用幾何等價 |
| F-02 | 全產品input/textarea樣式包含外置message；readonly透明/無border，審閱控制仍分離 | CMP-FORM CSS、STYLE-FORM-01/36/37、UI-10；父browser readonly/ padding PASS，V-09/11 | 实际字型fallback仍受缺font限制，TODO-05 |
| F-03 | 只標題/标签與动态前三格center，結果格不加center | prototype动态cell class、CSS/STYLE-FORM-13、UI-08；父browser result start PASS | 缺后载CSS仍TODO-05，当前source事实不受此掩盖 |
| F-04 | 每次建立／取得遮罩，当时焦点button才window.focus嘗試，异常留诊断 | CMP-COVER/REQUEST、FLOW-06/AC-19/E-26；V-08及父lifecycle观察1次PASS | 只证明调用尝试，OS可见focus未证明，TODO-07 |
| F-05 | 正式spec/common以可觀察資料/触发/结果表达，源符號置9.2、wire在API | 没合并A/B顺序、EP语意、首鍵/全文檔/未知分支；V-10静态词汇核对+人工回读 | 不用token scan宣称所有业务已完整确认 |
| F-06 | 每STYLE给实际token路径或明确无token规则，E/原始範圍/UI/ST/条件逐项；PAGE26改E03、27–29改E07 | 四DESIGN最终metadata PASS、源映射核对V-09/10；DESIGN最后hash另记录 | metadata不是官方全格式或像素validator；browser旧DESIGNhash不覆盖最终doc |
| F-07 | DEP与资源拆为7列表头／分隔，15row一致；未建立API03更正为prompt未消费 | plan、V-10逐行表格计数 | 契约选择与formal扩展仍依DEC沙盒边界 |
| F-08 | 首鍵先自除，仅message.parentNode存在才click與停止；拖曳detached不停止 | prototype、model、CMP-MESSAGE/FLOW-09/10/AC-20/E-27；V-08actual-controller VM、父lifecycle propagation1/defaultPrevented false PASS | 合成keypress不是原生Esc兼容证明 |

父代理補充回查：一度把來源●與缺邊框圖槽混為一項，提出移除；根L143–144明确有●後父代理撤回要求。不是產品變更授權。保留20×24格、align=center、font size=-5；L132–155/179的圖片只保留4×12、12×4、5×1、18×16空槽，不載入未知資源／不補造圖像，缺圖仍TODO-05。TASK-13、E-02與PAGE新增STYLE及STYLE-PAGE-DOT。

### 9.4 本輪驗證與交付判定

| V | 實際操作與證據 | 結果及能證明的範圍 | 限制／歷史 |
| --- | --- | --- | --- |
| V-08 | node --check兩JS；continuation-runtime-check.cjs實际controller在Node VM+明示DOM/focus/event替身；behavior-check.cjs重跑root/model | [五項controller](continuation-runtime-check.json) PASS；[十二項root/model](behavior-check-v2.json) PASS | 非浏览器computed／click/真实OS焦點。旧behavior-check.json保留不覆盖 |
| V-09 | 所附check_design_metadata.py四份最終DESIGN，现有PyYAML | [v2 metadata](design-metadata-check-v2.json) PASS；STYLE逐项E/token映射人工对照源及V-10 | 仅metadata形状，不是完整官方格式validator；旧report保留 |
| V-10 | continuation-document-check.py：manifest、完整单行链接、表格列数、STYLE→CSS/token/source定位、neutral source-symbol边界、TODO/历史、runtime报告hash | [v2文件检查](continuation-document-check.json) 实际结果与范围在JSON | 未安装完整Markdown parser，使用本地单行引用／表格结构检查；不是GFM完整渲染证明；未安装或网络查询 |
| V-11 | 经父授权读两份独立browser实际报告，逐个最终runtimehash比对 | 18/18与2/2 PASS；无runtime errors/HTTP attempts；[browser](../../../reports/browser.json)、[lifecycle](../../../reports/lifecycle-browser.json) | 原报DESIGNhash为文档整理中版本，只有HTML/JS/CSS最终runtimeHash覆盖有效；最終DESIGN靠V-09/10另核对 |

CHANGE-04：新case续作，plan第6节先建立，源版本未变、新skill规定读入、task明示review-guided；F-01..08按原始来源修正、文件同步，旧失败及report保留；CHANGE-05：补标题原文字与缺图空槽，父误判更正，不增加变更授权。

本輪判定仍為部分交付：確證F-01..08已修正並完成所列範圍的实际检查，独立浏览器覆盖已取得；TODO-01..07保持开启（缺少資料、目標契约/可信情境承接、date编码、全部正式服务／视觉等价／浏览器差异未确认）。父浏览器成功不能把未知依赖、真实业务、file/audit或部署改成已确认。初轮18项中的3FAIL仍保留其原版本事实，本轮PASS仅适用本轮runtimehash。
'''
p.write_text(s)
# Per-source behavior and review hashes remain authority snapshot; source inventory is versioned.
import subprocess
j=json.loads((R/'source-inventory.json').read_text())
cmd=['python3','skill/scripts/source_inventory.py']+[x['path'] for x in j['files']]+['--candidate','utf-8','--candidate','cp950']
r=subprocess.run(cmd,capture_output=True,text=True,check=True);(R/'source-inventory-v2.json').write_text(r.stdout)
print('Tracking history retained, malformed references regenerated, continuation evidence/results appended; TODOs remain open.')
