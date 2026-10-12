const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
class Element {
  constructor() { this._text=''; this.value=''; this.children=[]; this.listeners={}; this.dataset={}; }
  get textContent() { return this._text; }
  set textContent(value) { this._text=String(value); this.children=[]; }
  appendChild(element) { this.children.push(element); if (this.value==='' || !this.children.some(c=>c.value===this.value)) this.value=element.value; }
  insertRow() { const row=new Element(); this.children.push(row); return row; }
  insertCell() { const cell=new Element(); this.children.push(cell); return cell; }
  addEventListener(event,callback) { this.listeners[event]=callback; }
}
const ids=['pending','filter','status','rows','response','quantity','search','deliver','quantityForm','reviewLog','handoffNote'];
const elements=Object.fromEntries(ids.map(id=>[id,new Element()]));
const root={dataset:{stateId:'ST-INIT'}};
const alerts=[];
const context=vm.createContext({document:{documentElement:root,getElementById:id=>elements[id],createElement:()=>new Element()},window:{alert:message=>alerts.push(message)}});
const script='artifacts/design/fixture-case/prototypes/prototype.js';
vm.runInContext(fs.readFileSync(script,'utf8'),context);
const invoke=code=>vm.runInContext(code,context);
const result={environment:process.version,kind:'Minimal DOM adapter; does not establish native browser or original runtime behavior.',checks:[]};
function check(name,callback) { callback(); result.checks.push({name,result:'pass'}); }
check('AC-02: clear status, retain existing rows, trim request',()=>{
  elements.rows.insertRow(); elements.status.textContent='previous';elements.filter.value='  文本  ';
  invoke('beginSearch()'); assert.equal(elements.status.textContent,'');assert.equal(elements.rows.children.length,1);assert.equal(invoke('requests[0].query'),'文本');assert.equal(root.dataset.stateId,'ST-WAIT');
});
check('AC-03: success appends exact response order and fields',()=>{
  invoke("receiveResult({businessResult:'DONE',itemList:[{itemKey:'a',itemText:'展示甲',rankHint:'2'},{itemKey:'b',itemText:'展示乙',rankHint:'1'}]})");
  assert.deepEqual(elements.rows.children.map(row=>row.children.map(cell=>cell.textContent)),[['a','展示甲','2'],['b','展示乙','1']]);assert.equal(root.dataset.stateId,'ST-ROWS');
});
check('AC-04/05: empty and denied clear rows and exact message',()=>{
  invoke("receiveResult({businessResult:'NONE',itemList:[]})");assert.equal(elements.rows.children.length,0);assert.equal(elements.status.textContent,'沒有項目');assert.equal(root.dataset.stateId,'ST-EMPTY');
  invoke("receiveResult({businessResult:'BLOCK',itemList:[]})");assert.equal(elements.status.textContent,'不允許查閱');assert.equal(root.dataset.stateId,'ST-DENIED');
});
check('AC-10: R2 delivered before R1, success retains prior message',()=>{
  invoke('beginSearch();beginSearch()');elements.pending.value='3';elements.response.value='NONE';invoke('deliverSelected()');
  assert.equal(invoke('requests[2].delivered'),true);assert.equal(invoke('requests[1].delivered'),false);
  elements.pending.value='2';elements.response.value='DONE';invoke('deliverSelected()');
  assert.equal(elements.rows.children.length,2);assert.equal(elements.status.textContent,'沒有項目');assert.equal(root.dataset.stateId,'ST-ROWS');
});
check('AC-11: readable unknown result clears rows and preserves status',()=>{
  invoke("receiveResult({businessResult:'OTHER',itemList:[]})");assert.equal(elements.rows.children.length,0);assert.equal(elements.status.textContent,'沒有項目');assert.equal(root.dataset.stateId,'ST-UNCLASSIFIED');
});
check('AC-06: quantity empty alert prevents submit, restores product state',()=>{
  elements.quantity.value='';assert.equal(invoke('submitQuantity({preventDefault(){}})'),false);assert.deepEqual(alerts,['數量不得為空']);assert.equal(root.dataset.stateId,'ST-UNCLASSIFIED');
});
check('AC-07: nonempty and whitespace stop at submit boundary',()=>{
  for(const value of ['4',' ']) { elements.quantity.value=value;assert.equal(invoke('submitQuantity({preventDefault(){}})'),true);assert.equal(root.dataset.stateId,'ST-SUBMIT');assert.match(elements.handoffNote.textContent,/TODO-03/); }
});
fs.writeFileSync('artifacts/renovation/fixture-case/checks/interaction-results.json',JSON.stringify(result,null,2)+'\n');
console.log(`${result.checks.length} local interaction checks passed. Minimal DOM adapter only.`);
