from pathlib import Path
import re
D=Path('artifacts/design/AF-AFY10400')
def evidence(c,idx,sel,prop):
 if c=='PAGE':
  if idx==1:return ('E-20','cm.css L687–689')
  if idx==2:return ('E-02','root L128/135/171')
  if idx==3:return ('E-20','cm.css L9')
  if 4<=idx<=9:return ('E-02','root L129')
  if idx in [10,11,12]:return ('E-02','root L130–141')
  if 13<=idx<=16:return ('E-20','cm.css L260–265')
  if idx==17:return ('E-02','root L160–165')
  if idx in [18,19]:return ('E-02','root L166')
  if 20<=idx<=23:return ('E-02','root L175；center→CSS水平居中為呈現映射')
  if idx in [24,25]:return ('E-02','root L182–184；cellpadding5→內距映射')
  if idx==26:return ('E-03','root L191/193')
  if 27<=idx<=29:return ('E-07','header.jsp L101–112；仅政策啟用且列印')
  if sel=='.asset-slot':return ('E-02','root L132–155/179；空槽保留已知圖片幾何，不產生替代圖像')
  if sel.startswith('.border-'):return ('E-02','root L132–155')
  if sel=='.section-icon':return ('E-02','root L179（原E-02 L128–188範圍）')
  if sel=='.tbBox':return ('E-20','cm.css L166–180，root L154使用')
 if c=='FORM':
  if idx==1:return ('E-20','cm.css L12–15；所有產品輸入掛載，含CSR L1449–1474確認input')
  if 2<=idx<=8:return ('E-20','cm.css L182–200')
  if idx==9:return ('E-20','cm.css L273–275')
  if idx==10:return ('E-20','cm.css L276–278')
  if idx==11:return ('E-20','cm.css L282–284')
  if idx==12:return ('E-03','root L188/224')
  if idx==13:return ('E-01/E-03','root L43/48/53及L197/205/214–221；未包含結果格L55–57')
  if idx==14:return ('E-03','root L198/206值格left；说明格L190原生起始方向，左向呈現映射')
  if 15<=idx<=17:return ('E-03','root L197–206')
  if 18<=idx<=24:return ('E-20','cm.css L63–71')
  if 25<=idx<=34:return ('E-20','cm.css L108–124；readonly狀態覆寫border见STYLE-FORM-37')
  if idx==35:return ('E-20','cm.css L162–164；message-ok來源更高指定15px见STYLE-MESSAGE')
  if idx in [36,37]:return ('E-20','cm.css L542–545；含頁面根層確認input')
  if idx==38:return ('E-03','root L226')
  if idx in [39,40]:return ('E-01','root L116–124')
 if c=='COVER':return ('E-11','CSRUtil L210–222/307–314；hidden屬性對應來源顯示狀態，實作符號只在映射')
 if c=='MESSAGE':
  if sel=='#message':return ('E-12','CSRUtil L1432–1447')
  if sel=='#message-title':return ('E-12','CSRUtil L1476–1484（fontWeight尾空白未升格）')
  if sel=='#message-content':return ('E-12','CSRUtil L1486–1504')
  if sel=='#message-bottom':return ('E-12','CSRUtil L1506–1513')
  if sel=='#message-ok':return ('E-12','CSRUtil L1449–1451；來源指定padding比cm.css優先')
  if sel=='#drag-frame':return ('E-12','CSRUtil L1520–1524/1538/1549–1552')
 raise ValueError((c,idx,sel,prop))
def token(c,sel,prop,val):
 maps={
 ('PAGE','body','background'):'colors.page',('PAGE','body','font-family'):'typography.page.fontFamily',('PAGE','.subTitle','font-size'):'typography.title.fontSize',('PAGE','.subTitle','font-weight'):'typography.title.fontWeight',('PAGE','.subTitle','color'):'colors.title',('PAGE','.subTitle','letter-spacing'):'typography.title.letterSpacing',('PAGE','.main-frame','background'):'colors.frame',
 ('FORM','.tbBox2','background-color'):'colors.table',('FORM','.tbBox2','font-size'):'typography.table.fontSize',('FORM','.tbBox2','line-height'):'typography.table.lineHeight',('FORM','.tbYellow','background-color'):'colors.odd',('FORM','.row-odd','background-color'):'colors.odd',('FORM','.tbYellow2','background-color'):'colors.even',('FORM','.row-even','background-color'):'colors.even',('FORM','.tbBlue','background-color'):'colors.header',('FORM','.textBox2','font-size'):'typography.input.fontSize',('FORM','.textBox2','letter-spacing'):'typography.input.letterSpacing',('FORM','.button','font-size'):'typography.button.fontSize',('FORM','.button','line-height'):'typography.button.lineHeight',('FORM','.button','color'):'colors.buttonText',
 ('MESSAGE','#message','font-family'):'typography.message.fontFamily',('MESSAGE','#message','font-size'):'typography.message.fontSize',('MESSAGE','#message','background-color'):'colors.window',('MESSAGE','#message-title','background-color'):'colors.window',('MESSAGE','#message-title','color'):'colors.title',('MESSAGE','#message-content','background-color'):'colors.content',('MESSAGE','#message-bottom','background-color'):'colors.footer'}
 if c=='FORM' and prop=='font-family':return '[CMP-PAGE.typography.page.fontFamily](../CMP-PAGE/DESIGN.md)'
 return maps.get((c,sel,prop),'無 token；本列精確正文規則（'+prop+'='+val+'）')
for c in ['PAGE','FORM','COVER','MESSAGE']:
 p=D/'components'/('CMP-'+c)/'DESIGN.md';s=p.read_text().replace('適用AF-AFY10400 v1','適用AF-AFY10400 v2');css=(D/'styles'/('CMP-'+c+'.css')).read_text();css=re.sub(r'/\*.*?\*/','',css,flags=re.S)
 rows=[];idx=0
 for sel,body in re.findall(r'([^{}]+)\{([^{}]*)\}',css):
  sel=sel.strip()
  for item in body.split(';'):
   if ':' not in item:continue
   prop,val=item.split(':',1);prop=prop.strip();val=val.strip();idx+=1;ev,loc=evidence(c,idx,sel,prop)
   evlinks='/'.join(f'[{e}](../../../../renovation/AF-AFY10400/tracking.md#{e.lower()})' for e in ev.split('/'))
   applicable={'PAGE':'CMP-PAGE／UI-01/02；所有頁面ST','FORM':'CMP-FORM／UI-03..09及外置UI-10；ST-01/02/04/05','COVER':'CMP-COVER／UI-09/10；ST-03/05','MESSAGE':'CMP-MESSAGE／UI-10；ST-05'}[c]
   if c=='PAGE' and 'policy' in sel:applicable='CMP-PAGE／FLOW-08／MSG-05；ST-06；政策啟用且列印'
   if c=='FORM' and idx==13:applicable='UI-03/04標籤、四欄標題、動態前三格；UI-08結果格排除'
   if c=='FORM' and idx in [36,37]:applicable='全部產品input/textarea的readonly狀態；含UI-10確定，審閱輸入排除'
   if c=='MESSAGE' and sel=='#drag-frame':applicable='CMP-MESSAGE／FLOW-10，拖曳中的框；ST-05'
   gaps='[TODO-07](../../../../renovation/AF-AFY10400/tracking.md#todo-07) 實測未由本代理執行'
   if c in ['PAGE','FORM','COVER']:gaps+='；[TODO-05](../../../../renovation/AF-AFY10400/tracking.md#todo-05) 缺失視覺依賴'
   if c=='PAGE':gaps+='；[TODO-06](../../../../renovation/AF-AFY10400/tracking.md#todo-06) 未確認載入'
   rows.append(f'| STYLE-{c}-{idx:02} | {applicable}；`{sel}` | {token(c,sel,prop,val)} | [CMP-{c}.css](../../styles/CMP-{c}.css)：`{prop}: {val}` | {evlinks}；{loc} | [SCR-01](../../prototypes/SCR-01.html)；按條件進入，computed `{prop}` 比較本宣告的瀏覽器等價值 | {gaps} |')
 table='''| STYLE | CMP／UI／ST／selector條件 | 實際 token 路徑或明確無token正文規則 | 實載 CSS／property／值 | 精確E及來源定位 | 原型／computed檢查定義 | 局部缺口 |
| --- | --- | --- | --- | --- | --- | --- |
'''+ '\n'.join(rows)+'\n'
 s=re.sub(r'\| STYLE \|.*?(?=\n测试定义：)',table,s,flags=re.S)
 if c=='PAGE':s=s.replace('框圖4px、留白圖5px及icon18×16的资源缺少，原型不补造图像或形似图标；这些具体未展示尺寸连TODO-05。','邊框圖槽4×12、12×4、留白5×1及icon18×16保留空槽幾何，资源缺少仍TODO-05；沒有替代圖像。原●是根L144文字，保留20×24格、置中与HTML size=-5，字体由瀏覽器原生規則解釋；不是把缺圖換成●。')
 if c=='FORM':s=s.replace('inputs/textarea字型明确','input/textarea的字型規則覆蓋主畫面及外置訊息視窗');s=s.replace('later read-only规则只在控件符合状态时透明/无border，不误用到可编辑文本。','readonly規則符合時透明且無border，包含外置確定input；可編輯文本不套用。STYLE-FORM-13仅中心对齐已知标签/标题及动态前三格，结果格不指定center，保留来源起始方向。')
 if c=='COVER':s+='\n取得／建立副作用：當時焦點位於按鈕類才嘗試聚焦所屬視窗，來源CSRUtil L321–326、E-26。這不是CSS token；FLOW-06/AC-19實際效果仍TODO-07，不把嘗試寫成必然聚焦。\n'
 if c=='MESSAGE':s+='\n首鍵交錯：真視窗拖曳移出頁面時，先解除该首鍵實例再停止反應，不確認或阻斷；放開重附著不恢复已解除實例。E-12 CSRUtil L1545–1555/L1613–1625，FLOW-09/10、AC-20。\n'
 if c=='PAGE':s+='\nSTYLE-PAGE-DOT：無token；SCR-01.html保留原根L143–144的20×24格、align=center、HTML font size=-5與文字●，E-02。圖片空槽的width/height已逐列映射；其display:inline-block只表達已知圖片幾何，缺圖未解，不是替代圖像。\n'
 p.write_text(s)
p=D/'specification.md';s=p.read_text().replace('\n\n| AC-19','\n| AC-19');s=s.replace('Prototype完成：各系统模式、EP、空描述、>17编号、非JSON、傳輸失敗、callback异常','共用回應完成：各呈現模式、成功僅收遮罩子情境、空描述、長度>17編號、僅文字、傳輸失敗、處理例外');s=s.replace('prompt已取得','初始化操作已取得').replace('Prototype/jQuery','兩種共用回應能力').replace('WIUtil','外部訊息能力').replace('keypress','首鍵反應').replace('body/window','全頁／所屬視窗').replace('callback','回應處理').replace('stale guard','忽略較舊回應的限制').replace('init／table／overDiv','外部初始化／主版面／子區域');p.write_text(s)
print('All STYLE rows have exact evidence/token or explicit no-token mapping; stable prior IDs retained.')
