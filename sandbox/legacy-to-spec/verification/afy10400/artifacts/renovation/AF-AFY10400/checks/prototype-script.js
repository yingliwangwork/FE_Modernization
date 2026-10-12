
'use strict';
const el=id=>document.getElementById(id), product=el('product');
let serial=0, pending=null, lastCopy='', messages=[], drag=null;
const log=t=>{el('review-log').textContent+=t+'\n';el('review-log').scrollTop=el('review-log').scrollHeight;};
const state=s=>product.dataset.stateId=s;
const rows=()=>Array.from(el('table1').rows).slice(3);
function rowColor(){rows().forEach((r,i)=>r.style.backgroundColor=i%2===0?'#EEF1A7':'#FAFBE1');}
function addRow(){
 const r=el('table1').insertRow();r.id='table1_row_'+(++serial);
 const d=r.insertCell();d.align='center';const b=document.createElement('input');b.type='button';b.value='刪除此列';b.className='button';b.dataset.uiId='UI-06';b.dataset.flowId='FLOW-03';b.onclick=()=>{r.remove();rowColor();state(rows().length?'ST-02':'ST-01');};d.appendChild(b);
 const c=r.insertCell();c.align='center';const id=document.createElement('input');id.type='text';id.size=12;id.maxLength=10;id.name='I_ID';id.id='I_ID_'+serial;id.className='textBox2';id.dataset.uiId='UI-07';c.appendChild(id);
 const p=r.insertCell();p.align='center';const policy=document.createElement('textarea');policy.rows=3;policy.cols=30;policy.name='POLICY_NO';policy.id='POLICY_NO_'+serial;policy.className='textBox2';policy.dataset.uiId='UI-08';p.appendChild(policy);
 r.insertCell().dataset.uiId='UI-09';rowColor();state('ST-02');return r;
}
function exportRequest(){
 const rs=rows(), ids=rs.map(r=>r.cells[1].firstChild.value), policies=rs.map(r=>r.cells[2].firstChild.value);
 for(let i=0;i<ids.length;i++){
  if(ids[i]===''||policies[i]===''){state('ST-08');alert('第'+(i+1)+'列的被保人ID或保單號碼不得為空值，若不需要請刪除該列');state(rows().length?'ST-02':'ST-01');return;}
  for(let j=i+1;j<ids.length;j++)if(ids[i]===ids[j]){state('ST-08');alert('被保人ID：'+ids[i]+'有重覆出現，請合併在同一列處理');state(rows().length?'ST-02':'ST-01');return;}
 }
 pending={insrType:el('insrType').value,prodType:el('prodType').value,I_ID:ids,POLICY_NO:policies.map(p=>p.replace(/(\r)?\n/g,'\r\n'))};state('ST-03');el('cover').hidden=false;
 log('BOUND-01 本機交接（不呼叫 API）：'+JSON.stringify(pending)+'；0列的目標省略/空集合仍是 TODO-05，此摘要不是已核准 wire 範例。');
}
function bottom(text){if(el('bottom-host').checked||el('message-mode').value==='board')el('bottom-msg').textContent=text;}
function clearBottom(){if(el('bottom-host').checked||el('message-mode').value==='board')el('bottom-msg').textContent='';}
function receive(){
 if(!pending){log('審閱工具：目前沒有待交付的匯出交換。');return;}
 const kind=el('response-mode').value;
 if(kind==='target-error'){el('cover').hidden=true;state('ST-05');log('TODO-03：選定目標 HTTP200/code500/msg為服務錯誤/data=null；未提供逐列映射，保留既有結果，不補造回填或下載。');pending=null;return;}
 if(kind==='no-json'){el('cover').hidden=true;state(rows().length?'ST-02':'ST-01');log('TR-09：缺 JSON，未執行頁面 callback；無訊息且無活動，complete 解除 cover。');pending=null;return;}
 if(kind==='processing-exception'||kind==='processing-exception-failure'){
  // Authored readable legacy response with rtnMap:null; no backend contract inferred.
  try{Object.entries(null);}catch(ex){diagnosticAlert('DEMO-EXCHANGE','DEMO-PARAMETERS',ex);}
  log('TR-12：合成頁面結果處理拋錯；诊斷警示已確認，未回填／下載；接著仍進入交換結束處理。');
  pending=null;state(rows().length?'ST-02':'ST-01');exchangeMessage(kind==='processing-exception-failure','查無資料','');return;
 }
 const fixture=Object.fromEntries(pending.I_ID.map(id=>[id,kind==='success'?'已匯出':'被保人：'+id+' 查無保單號碼：DEMO。']));
 // fixture is an explicit authored response, not a query or business calculation.
 rows().forEach(r=>{r.cells[3].textContent=fixture[r.cells[1].firstChild.value];});
 log('TR-'+(kind==='success'?'07':'08')+'：合成逐列結果全部回填完成。');
 if(kind==='success'){state('ST-04');log('BOUND-02：接著交付合成 fileName DEMO.xlsx，不開新窗；TODO-03 原 helper JSON→檔案與目標 binary 差距，未產生檔案。');}else state('ST-05');
 pending=null;exchangeMessage(kind==='failure','查無資料',kind==='failure'?'DEMO-ERROR-0000000001':'');
}
function diagnosticAlert(url,parameters,exception){
 let message='Error :\n'+'url : '+url+'\nparams: '+parameters+'\nException: \n';
 for(const property in exception)message+=property+'='+exception[property]+'\n';
 alert(message);
}
function exchangeMessage(error,desc,id){
 if(!error)desc='已匯出';
 bottom('訊息：'+desc);const mode=el('message-mode').value;
 if(mode==='custom'||mode==='ep'){
  if(error)showModal((id.length>17?'錯誤編號：\n'+id+'\n訊息說明：\n':'')+desc);
  else if(mode==='ep')el('cover').hidden=true;else if(desc!=='')showModal(desc);
 }else{
  el('cover').hidden=true;
  if(error)alert((id.length>17?'錯誤編號：\n'+id+'\n':'')+'訊息說明：\n'+desc);
  else if(desc!==''&&!el('bottom-host').checked&&mode!=='board')alert('訊息說明：\n'+desc);
 }
 log('FLOW-09：頁面結果處理之後（含診斷返回）才執行合成共用 complete 訊息分支 '+mode+'。');
}
function entryMessages(){
 const m=el('entry-mode').value;
 if(m==='rollback'){log('CMP-02：合成 rollback 旗標重設為空，立即返回；未交付底欄或警示。');return;}
 const code=m==='99'?99:m==='none'?0:1,desc='查無資料';bottom(desc);
 if(code===0||code===99){log('CMP-02：先交付第一筆合成底欄，code '+code+' 不產生警示。');return;}
 if(m==='wiutil'){log('TODO-02：WIUtil 與 jQuery 都存在時應交付組裝訊息給 WIUtil；未提供其內部，未以其他視窗冒充。');return;}
 alert(m==='exception'?'異常原因:查無資料\n\n程式ID:DEMO\n\n':'訊息說明:\n查無資料\n\n錯誤編號：\nDEMO');
}
function closeModal(e){
 if(e)e.stopPropagation();const w=el('message-window');if(w.hidden)return;w.hidden=true;messages=[];el('message-content').textContent='';if(!pending)el('cover').hidden=true;state(rows().length?'ST-02':'ST-01');
}
function showModal(msg){
 const w=el('message-window'),content=el('message-content'),fresh=messages.length===0;
 const emptyMarkup='<font color="gray">(無訊息內容)</span>';
 const transformed=msg===null||msg===undefined||msg===''?emptyMarkup:String(msg).replace(/\\n|\n/g,'<br/>');
 if(!messages.includes(transformed))messages.push(transformed);
 const required=transformed.length*15;
 if(fresh)w.style.width=Math.max(180,Math.min(600,required))+'px';
 else{
  const contentWidth=content.getBoundingClientRect().width;
  if(contentWidth<600-12&&contentWidth<required){
   if(required>600)w.style.width='600px';else if(required>180)w.style.width=required+'px';
  }
 }
 content.textContent='';
 messages.forEach((message,index)=>{
  const fragment=document.createElement('span');
  fragment.textContent=(index?'\n':'')+(message===emptyMarkup?'(無訊息內容)':message.replace(/<br\/>/g,'\n'));
  if(message===emptyMarkup)fragment.style.color='gray';
  content.appendChild(fragment);
 });
 w.hidden=false;el('cover').hidden=false;
 w.style.top=Math.trunc(document.body.clientHeight/4+window.scrollY)+'px';w.style.left=Math.trunc((document.body.clientWidth-w.getBoundingClientRect().width)/2+window.scrollX)+'px';state('ST-06');
 if(fresh){const firstKeyHandler=e=>{document.removeEventListener('keypress',firstKeyHandler);if(['Enter','Escape',' '].includes(e.key)||[13,27,32].includes(e.keyCode)){if(!w.hidden){el('message-ok').click();e.preventDefault();e.stopPropagation();}}};document.addEventListener('keypress',firstKeyHandler);}
 el('message-ok').focus();
}
function dragStart(e){
 const w=el('message-window'),b=el('dragbox'),rect=w.getBoundingClientRect();drag={dx:e.pageX-(rect.left+window.scrollX),dy:e.pageY-(rect.top+window.scrollY)};
 b.style.width=rect.width+'px';b.style.height=rect.height+'px';b.style.left=rect.left+window.scrollX+'px';b.style.top=rect.top+window.scrollY+'px';b.hidden=false;
 el('message-title').removeEventListener('mousedown',dragStart);document.addEventListener('mousemove',dragMove);document.addEventListener('mouseup',dragStop);w.dataset.stateId='ST-07';state('ST-07');
}
function dragMove(e){if(!drag)return;e.preventDefault();e.stopPropagation();const b=el('dragbox');b.style.top=e.pageY-drag.dy+'px';b.style.left=e.pageX-drag.dx+'px';el('message-window').hidden=true;}
function dragStop(e){if(!drag)return;e.preventDefault();e.stopPropagation();document.removeEventListener('mousemove',dragMove);document.removeEventListener('mouseup',dragStop);const w=el('message-window'),b=el('dragbox');w.style.top=parseInt(b.style.top,10)+'px';w.style.left=parseInt(b.style.left,10)+'px';b.hidden=true;w.hidden=false;drag=null;w.dataset.stateId='ST-06';state('ST-06');el('message-title').addEventListener('mousedown',dragStart);}
const policyMessages={print:'依據資安政策，不開放列印功能',beforeprint:'依據資安政策，不開放列印功能',cut:'依據資安政策，不開放剪下功能',selectAll:'依據資安政策，不開放全選功能',save:'依據資安政策，不開放頁面儲存功能'};
const enabled=()=>el('policy').checked;
function blockPolicy(e){if(!enabled())return;e.preventDefault();e.stopPropagation();if(policyMessages[e.type])alert(policyMessages[e.type]);}
function policyKey(e){if(!enabled()||!e.ctrlKey)return;const k=e.key.toLowerCase(),map={a:'selectAll',x:'cut',s:'save',p:'print'};if(map[k]){e.preventDefault();e.stopPropagation();alert(policyMessages[map[k]]);}}
function copyPolicy(){
 if(!enabled())return;const ae=document.activeElement;const selection=ae&&ae.tagName==='TEXTAREA'?ae.value.substring(ae.selectionStart,ae.selectionEnd):window.getSelection().toString();
 const text=selection.replace(/\s+/g,' ');if(text.length===0||text===lastCopy)return;
 setTimeout(()=>{lastCopy='';log('FLOW-07：獨立60秒到期清空上筆；其他計時器未取消。');},60000);lastCopy=text;
 let content=text.length>5000?text.substr(0,4997)+'...':text;
 for(const [a,b] of [['%','%25'],['#','%23'],['&','%26'],[' ','%20'],['+','%2B'],['?','%3F'],['=','%3D']])content=content.split(a).join(b);
 log('BOUND-03 本機稽核交接摘要（不寫入）：'+JSON.stringify({content,length:text.length,functionId:'AFY10400',time:Date.now()})+'；TODO-01 未提供目標稽核承接。');
}
for(const t of ['contextmenu','print','beforeprint','cut'])document.body.addEventListener(t,blockPolicy,true);
document.body.addEventListener('copy',copyPolicy,true);window.addEventListener('keydown',policyKey,true);
document.addEventListener('click',e=>{if(['button','submit'].includes(e.target.type))clearBottom();});
el('policy').addEventListener('change',()=>document.body.classList.toggle('policy-on',enabled()));
el('addBtn').onclick=addRow;el('exportBtn').onclick=exportRequest;el('frm').onsubmit=e=>e.preventDefault();el('respond').onclick=()=>setTimeout(receive,0);el('entry').onclick=entryMessages;
el('sample').onclick=()=>{const r=addRow();r.cells[1].firstChild.value='DEMO000001';r.cells[2].firstChild.value='DEMO-POL-1\nDEMO-POL-2';log('審閱工具填入合成列；不是產品預設資料。');};
el('hide-review').onclick=()=>el('review').classList.toggle('review-hidden');el('modal-fixture').onclick=()=>{const kind=el('modal-kind').value;showModal(kind==='null'?null:kind==='undefined'?undefined:kind==='empty'?'':el('modal-text').value);};el('message-ok').onclick=closeModal;el('message-title').addEventListener('mousedown',dragStart);
log('初始 ST-01：0列、L/AT；入口訊息未提供時不生成警示。實際旗標未知，政策默認不啟用；可用合成旗標審閱條件反應。');
