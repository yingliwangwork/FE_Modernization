(function(root){
'use strict';
class ExportModel {
 constructor(){this.rows=[];this.unique=0;this.insrType='L';this.prodType='AT';this.requests=[];this.downloads=[];this.events=[];this.active=0;}
 add(){const r={key:++this.unique,id:'',policy:'',result:''};this.rows.push(r);return r;}
 remove(key){this.rows=this.rows.filter(r=>r.key!==key);}
 validate(){for(let i=0;i<this.rows.length;i++){const r=this.rows[i];if(r.id===''||r.policy==='')return `第${i+1}列的被保人ID或保單號碼不得為空值，若不需要請刪除該列`;for(let j=i+1;j<this.rows.length;j++)if(r.id===this.rows[j].id)return `被保人ID：${r.id}有重覆出現，請合併在同一列處理`;}return null;}
 submit(){const error=this.validate();if(error)return {error};const req={id:'R'+(this.requests.length+1),body:{insrType:this.insrType,prodType:this.prodType,I_ID:this.rows.map(r=>r.id),POLICY_NO:this.rows.map(r=>r.policy.replace(/(\r)?\n/g,'\r\n'))},done:false};this.requests.push(req);this.active++;this.events.push('send:'+req.id);return req;}
 receive(reqId,resp){const req=this.requests.find(r=>r.id===reqId&&!r.done);if(!req)throw Error('審閱工具：請先選擇未交付的請求');req.done=true;const success=resp&&resp.ErrMsg&&resp.ErrMsg.returnCode==0;try {if(resp!==undefined){const map=new Map(Object.entries(resp.rtnMap));for(const r of this.rows)r.result=map.get(r.id);this.events.push('fill:'+req.id);if(success){this.downloads.push({request:req.id,fileName:resp.fileName});this.events.push('download-boundary:'+req.id);}}}catch(e){this.events.push('exception:'+req.id);this.active--;return {error:e,success};}this.active--;this.events.push('complete:'+req.id);return {success};}
}
class CopyPolicy {
 constructor(){this.last='';this.timers=[];this.records=[];}
 copy(text,now){const normalized=text.replace(/\s+/g,' ');if(!normalized.length||normalized===this.last)return null;this.timers.push(now+60000);this.last=normalized;let content=normalized.length>5000?normalized.slice(0,4997)+'...':normalized;for(const [a,b] of [['%','%25'],['#','%23'],['&','%26'],[' ','%20'],['+','%2B'],['?','%3F'],['=','%3D']])content=content.split(a).join(b);const record={content,length:normalized.length,time:now};this.records.push(record);return record;}
 expire(now){const due=this.timers.filter(t=>t<=now);this.timers=this.timers.filter(t=>t>now);for(const t of due)this.last='';return due.length;}
}
function normalizeMessage(msg){return msg===null||msg===undefined||msg===''?'<font color="gray">(無訊息內容)</span>':String(msg).replace(/\\n|\n/g,'<br/>');}
class MessageModel {
 constructor(){this.messages=[];this.width=180;this.open=false;this.attached=false;this.keyInstances=[];}
 show(msg){const n=normalizeMessage(msg),x=n.length*15;if(!this.messages.includes(n))this.messages.push(n);if(!this.open){this.width=Math.max(180,Math.min(600,x));this.keyInstances.push({live:true});this.open=true;this.attached=true;}else if(this.width-12<588&&this.width-12<x&&x>180)this.width=Math.min(600,x);return this.messages.join('<br/>');}
 close(){this.open=false;this.attached=false;this.messages=[];}
 detachForDrag(){this.attached=false;}
 reattachAfterDrag(){this.attached=true;}
 key(code){let stopped=false;for(const k of [...this.keyInstances])if(k.live){k.live=false;if([13,27,32].includes(code)&&this.open&&this.attached){this.close();stopped=true;}}return stopped;}
}
const exported={ExportModel,CopyPolicy,MessageModel,normalizeMessage};root.AFReviewModel=exported;if(typeof module!=='undefined')module.exports=exported;
})(typeof window!=='undefined'?window:globalThis);
