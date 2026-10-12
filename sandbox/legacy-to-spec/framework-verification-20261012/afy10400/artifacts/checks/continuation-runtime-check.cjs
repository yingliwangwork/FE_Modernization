'use strict';
const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
const checks=[];const run=(id,fn)=>{try{fn();checks.push({id,status:'PASS'});}catch(e){checks.push({id,status:'FAIL',error:e.message});}};
function setup(){
 const nodes=new Map(),documentListeners=new Map(),diagnostics=[];
 const document={activeElement:null,listeners:documentListeners,getElementById:id=>nodes.get(id),createElement:tag=>new Node(tag),addEventListener(type,f){const a=documentListeners.get(type)||[];a.push(f);documentListeners.set(type,a);},removeEventListener(type,f){documentListeners.set(type,(documentListeners.get(type)||[]).filter(x=>x!==f));}};
 class Node{
  constructor(tag='div',id){this.tagName=tag.toUpperCase();this.parentNode=null;this.style={};this.dataset={};this.hidden=false;this.listeners=new Map();this.value='';this.checked=false;this.type='';this.children=[];this._html='';if(id)this.id=id;}
  set id(id){this._id=id;nodes.set(id,this);}get id(){return this._id;}
  set innerHTML(v){this._html=v;}get innerHTML(){return this._html;}get innerText(){return this._html.replace(/<[^>]*>/g,'');}
  addEventListener(t,f){const a=this.listeners.get(t)||[];a.push(f);this.listeners.set(t,a);}removeEventListener(t,f){this.listeners.set(t,(this.listeners.get(t)||[]).filter(x=>x!==f));}
  getAttribute(n){return n==='type'?this.type:null;}focus(){document.activeElement=this;}click(){for(const f of [...this.listeners.get('click')||[]])f({stopPropagation(){}});}
  append(n){if(n.parentNode)n.remove();this.children.push(n);n.parentNode=this;}
  remove(){if(this.parentNode){this.parentNode.children=this.parentNode.children.filter(x=>x!==this);this.parentNode=null;}}
  replaceChildren(){this.children=[];}querySelector(){return new Node('input');}closest(){return null;}
  get offsetWidth(){return this.id==='message'?parseFloat(this.style.width||180)+12:180;}
  get offsetHeight(){return 180;}getBoundingClientRect(){return {left:100,top:100};}
 }
 document.body=new Node('body','body');document.body.clientWidth=1280;document.body.clientHeight=800;document.body.classList={toggle(){}};document.activeElement=document.body;
 for(const id of ['product','rows','cover','message','message-content','message-ok','message-title','message-bottom','drag-frame','review-log','insrType','prodType','policy-on','request-choice','return-code','response-map','file-name','response-msg','message-id','system-mode','bottom-exists','addBtn','exportBtn','frm','inject','inject-target','enqueue','custom-msg','show-custom']){const n=new Node('div',id);document.body.append(n);}
 for(const id of ['cover','message','drag-frame'])nodes.get(id).hidden=true;
 nodes.get('message').append(nodes.get('message-content'));nodes.get('message').append(nodes.get('message-ok'));nodes.get('message').append(nodes.get('message-title'));
 nodes.get('message-ok').type='button';nodes.get('addBtn').type='button';nodes.get('exportBtn').type='button';nodes.get('insrType').value='L';nodes.get('prodType').value='AT';nodes.get('system-mode').value='other';
 const context={document,scrollX:0,scrollY:0,focusCalls:0,diagnostics,console:{log:x=>diagnostics.push(x)},alert:x=>diagnostics.push('alert:'+x),setTimeout(){},addEventListener(){},focus(){context.focusCalls++;if(context.failFocus)throw Error('focus unavailable');}};context.window=context;context.globalThis=context;vm.createContext(context);
 vm.runInContext(fs.readFileSync('artifacts/design/AF-AFY10400/prototypes/model.js','utf8'),context);
 vm.runInContext(fs.readFileSync('artifacts/design/AF-AFY10400/prototypes/prototype.js','utf8'),context);
 return {context,nodes,document,eval:s=>vm.runInContext(s,context)};
}
run('F-04 actual controller acquisition condition',()=>{const t=setup();t.eval('acquireCover()');assert.equal(t.context.focusCalls,0);t.document.activeElement=t.nodes.get('exportBtn');t.eval('acquireCover()');t.eval('acquireCover()');assert.equal(t.context.focusCalls,2);t.document.activeElement=new (t.nodes.get('product').constructor)('input');t.document.activeElement.type='text';t.eval('acquireCover()');assert.equal(t.context.focusCalls,2);});
run('F-04 actual controller acquisition failure diagnostics',()=>{const t=setup();t.document.activeElement=t.nodes.get('exportBtn');t.context.failFocus=true;assert.doesNotThrow(()=>t.eval('acquireCover()'));assert.ok(t.context.diagnostics.some(x=>x.includes('cant read activeElement!')));});
run('F-08 actual controller first close key while dragged out',()=>{const t=setup();t.eval('showMessage("synthetic")');t.eval('down({pageX:200,pageY:200})');t.eval('move({pageX:250,pageY:230,preventDefault(){},stopPropagation(){}})');assert.equal(t.nodes.get('message').parentNode,null);let prevented=0,stopped=0;const e={keyCode:13,preventDefault(){prevented++;},stopPropagation(){stopped++;}};for(const f of [...t.document.listeners.get('keypress')])f(e);assert.equal(prevented,0);assert.equal(stopped,0);assert.equal(t.document.listeners.get('keypress').length,0);t.eval('up({preventDefault(){},stopPropagation(){}})');assert.ok(t.nodes.get('message').parentNode);assert.equal(t.nodes.get('message').hidden,false);});
run('F-08 actual controller attached first close key',()=>{const t=setup();t.eval('showMessage("synthetic")');let prevented=0,stopped=0;for(const f of [...t.document.listeners.get('keypress')])f({keyCode:27,preventDefault(){prevented++;},stopPropagation(){stopped++;}});assert.equal(t.nodes.get('message').hidden,true);assert.equal(prevented,1);assert.equal(stopped,1);});
run('F-03 actual controller result cell excluded from added centers',()=>{const t=setup();t.eval('add()');const html=t.nodes.get('row-1').innerHTML;assert.equal((html.match(/class="center-cell"/g)||[]).length,3);assert.match(html,/<td id="result-1" data-ui-id="UI-08"><\/td>/);});
const report={kind:'actual local prototype controller executed in Node VM with explicit DOM/focus/event doubles',environment:process.version,checks,limits:['Not a browser: no real click accessibility, computed CSS, native alert, layout or window activation demonstrated.','Parent independent browser reports are separately attributed; no scenario read or modified.','No backend, network, file download, audit or business calculations executed.']};console.log(JSON.stringify(report,null,2));if(checks.some(x=>x.status==='FAIL'))process.exitCode=1;
