'use strict';
const fs=require('fs'),vm=require('vm'),assert=require('assert');
const contextFile='artifacts/renovation/AF-AFY10400/checks/prototype-script.js';
class Element{
 constructor(tag='div'){this.tagName=tag;this.dataset={};this.style={};this.children=[];this.events={};this.value='';this.hidden=false;this.textContent='';this.id='';}
 append(child){child.parent=this;this.children.push(child);}
 addEventListener(name,fn){this.events[name]=fn;}
 querySelector(selector){const tag=selector.startsWith('input')?'input':'textarea';return this.descendants().find(el=>el.tagName===tag&&(tag!=='input'||el.name==='I_ID'));}
 descendants(){return this.children.flatMap(c=>[c,...c.descendants()]);}
}
class Cell extends Element{constructor(){super('td');}}
class Row extends Element{constructor(table){super('tr');this.table=table;this.cells=[];}insertCell(){const c=new Cell();this.cells.push(c);this.append(c);return c;}remove(){this.table.rows.splice(this.table.rows.indexOf(this),1);}}
class Table extends Element{constructor(){super('table');this.rows=[];for(let i=0;i<3;i++)this.rows.push(new Row(this));}insertRow(){const r=new Row(this);this.rows.push(r);return r;}}
function setup(){
 const elements=Object.fromEntries(['product','cover','reviewStatus','frm','addBtn','exportBtn','accept','reject','reset','hide','review','fixture','insrType','prodType'].map(id=>[id,new Element()]));
 elements.table1=new Table();elements.product.dataset.stateId='ST-01';elements.insrType.value='L';elements.prodType.value='AT';elements.cover.hidden=true;
 const alerts=[];const ctx=vm.createContext({document:{getElementById:id=>elements[id],createElement:tag=>new Element(tag)},alert:value=>alerts.push(value),Map,Array});
 vm.runInContext(fs.readFileSync(contextFile,'utf8'),ctx);
 return{elements,alerts,eval:code=>vm.runInContext(code,ctx),click:id=>elements[id].events.click(),rows:()=>elements.table1.rows.slice(3)};
}
const results=[];function test(name,fn){try{fn();results.push({name,result:'passed'});}catch(e){results.push({name,result:'failed',error:e.message});}}
test('Initial zero rows; defaults preserved; added row controls and alternating colors',()=>{const t=setup();assert.equal(t.rows().length,0);assert.equal(t.elements.insrType.value,'L');assert.equal(t.elements.prodType.value,'AT');t.click('addBtn');t.click('addBtn');assert.equal(t.rows().length,2);assert.equal(t.rows()[0].style.backgroundColor,'#EEF1A7');assert.equal(t.rows()[1].style.backgroundColor,'#FAFBE1');assert.equal(t.rows()[0].querySelector('input').maxLength,10);assert.equal(t.rows()[0].querySelector('textarea').rows,3);});
test('Deletion removes only selected row and recolors retained row',()=>{const t=setup();t.click('fixture');t.rows()[0].cells[0].children[0].events.click();assert.equal(t.rows().length,1);assert.equal(t.rows()[0].querySelector('input').value,'DEMO000002');assert.equal(t.rows()[0].style.backgroundColor,'#EEF1A7');t.rows()[0].cells[0].children[0].events.click();assert.equal(t.elements.product.dataset.stateId,'ST-01');});
test('Empty ID or policy shows exact first-row alert and leaves input/results intact',()=>{for(const emptyField of ['input','textarea']){const t=setup();t.click('fixture');t.rows()[0].querySelector(emptyField).value='';t.rows()[0].cells[3].textContent='kept';t.click('exportBtn');assert.equal(t.alerts[0],'第1列的被保人ID或保單號碼不得為空值，若不需要請刪除該列');assert.equal(t.elements.product.dataset.stateId,'ST-03');assert.equal(t.rows()[0].cells[3].textContent,'kept');assert.equal(t.elements.cover.hidden,true);}});
test('Duplicate check in earlier nonempty row precedes later blank-policy check',()=>{const t=setup();t.click('fixture');t.rows()[1].querySelector('input').value='DEMO000001';t.rows()[1].querySelector('textarea').value='';t.click('exportBtn');assert.equal(t.alerts[0],'被保人ID：DEMO000001有重覆出現，請合併在同一列處理');});
test('Zero-row export reaches boundary without alert',()=>{const t=setup();t.click('exportBtn');assert.equal(t.alerts.length,0);assert.equal(t.elements.product.dataset.stateId,'ST-04');assert.equal(t.elements.cover.hidden,false);});
test('Whitespace passes exact-empty front guard; multiline remains unmodified',()=>{const t=setup();t.click('addBtn');t.rows()[0].querySelector('input').value=' ';t.rows()[0].querySelector('textarea').value=' \n ';t.click('exportBtn');assert.equal(t.alerts.length,0);assert.equal(t.elements.product.dataset.stateId,'ST-04');assert.equal(t.rows()[0].querySelector('textarea').value,' \n ');});
test('Review acceptance writes results before download-boundary state; no file generation',()=>{const t=setup();t.click('fixture');t.click('exportBtn');t.click('accept');assert.equal(t.elements.product.dataset.stateId,'ST-06');assert.equal(t.rows()[0].cells[3].textContent,'已匯出');assert.equal(t.rows()[1].cells[3].textContent,'已匯出');assert.ok(t.elements.reviewStatus.textContent.includes('未下載／未產生檔案'));assert.equal(t.elements.cover.hidden,true);});
test('Review rejection writes known synthetic per-row text without download',()=>{const t=setup();t.click('fixture');t.click('exportBtn');t.click('reject');assert.equal(t.elements.product.dataset.stateId,'ST-05');assert.equal(t.rows()[0].cells[3].textContent,'ID長度預為10碼');assert.ok(t.elements.reviewStatus.textContent.includes('沒有下載'));});
test('Editing inputs and options leaves existing export result text',()=>{const t=setup();t.click('fixture');t.click('exportBtn');t.click('accept');t.rows()[0].querySelector('input').value='DEMO000003';t.elements.insrType.value='R';assert.equal(t.rows()[0].cells[3].textContent,'已匯出');});
test('Review reply injection requires prior export boundary',()=>{const t=setup();t.click('fixture');t.click('accept');assert.equal(t.elements.product.dataset.stateId,'ST-02');assert.equal(t.rows()[0].cells[3].textContent,'');});
const report={environment:'Node vm with a minimal local DOM substitute; no real browser, legacy JSP, network, service or file download.',results,passed:results.filter(r=>r.result==='passed').length,failed:results.filter(r=>r.result==='failed').length,limits:['Does not test layout, native maxlength/input/Enter/alert behavior, focus, keyboard, CSS, browser events, console or network monitor.','Does not test missing external message frames, conditional information protection, trusted context, watermark, target envelopes or binary transfer.']};
fs.writeFileSync('artifacts/renovation/AF-AFY10400/checks/interaction-report.json',JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));process.exitCode=report.failed?1:0;
