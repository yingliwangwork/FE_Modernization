const fs = require('fs');
const vm = require('vm');
const assert = require('assert/strict');
const html = fs.readFileSync('artifacts/design/fixture-case/prototypes/items.html', 'utf8');
const source = html.match(/<script>([\s\S]*?)<\/script>/)[1];
const dom = {};
class Element {
  constructor(id) { this.id=id; this.value=''; this._text=''; this.children=[]; this.listeners={}; this.dataset={}; this.hidden=false; }
  set textContent(value) { this._text=value; this.children=[]; if (this.id==='pending') this.value=''; }
  get textContent() { return this._text; }
  addEventListener(type, fn) { this.listeners[type]=fn; }
  appendChild(child) { this.children.push(child); if (this.id==='pending'&&!this.value) this.value=child.value; }
  insertRow() { const row=new Element('row'); row.insertCell=()=>{const cell=new Element('cell'); row.children.push(cell); return cell;}; this.children.push(row); return row; }
  fire(type) { let prevented=false; this.listeners[type]({preventDefault(){prevented=true;}}); return prevented; }
}
for (const id of ['product','filter','status','rows','pending','review-status','search','reply-ok','reply-empty','reply-denied','reply-other','quantity-form','quantity','reset','toggle-review','review']) dom[id]=new Element(id);
dom.product.dataset.stateId='ST-01';
const alerts=[];
const context=vm.createContext({document:{getElementById:id=>{assert(dom[id],id);return dom[id];},createElement:tag=>new Element(tag)},alert:text=>alerts.push(text)});
new vm.Script(source).runInContext(context);
const click=id=>dom[id].fire('click');
const state=()=>dom.product.dataset.stateId;
const table=()=>dom.rows.children.map(row=>row.children.map(cell=>cell.textContent));
assert.equal(state(),'ST-01');
assert.equal(dom.status.textContent,'');
dom.status.textContent='不允許查閱';
const old=dom.rows.insertRow();old.insertCell().textContent='OLD';
dom.filter.value='  示範  ';
click('search');
assert.equal(state(),'ST-02'); assert.equal(dom.status.textContent,''); assert.equal(table()[0][0],'OLD');
assert(dom.pending.children[0].textContent.endsWith('關鍵字：示範'));
click('reply-ok');
assert.equal(state(),'ST-03'); assert.deepEqual(table(),[['DEMO-01','示例項目甲','示例提示甲'],['DEMO-02','示例項目乙','示例提示乙']]);
assert.equal(dom.pending.children.length,0);
click('search');click('reply-empty');assert.equal(state(),'ST-04');assert.equal(dom.status.textContent,'沒有項目');assert.equal(table().length,0);
click('search');click('reply-denied');assert.equal(state(),'ST-05');assert.equal(dom.status.textContent,'不允許查閱');assert.equal(table().length,0);
click('search');click('search');
// Receive the second started request first; the first one remains usable.
const first=dom.pending.children[0].value; const second=dom.pending.children[1].value;
dom.pending.value=second;click('reply-empty');assert.equal(dom.status.textContent,'沒有項目');
dom.pending.value=first;click('reply-ok');assert.equal(state(),'ST-03');assert.equal(table().length,2);assert.equal(dom.status.textContent,'沒有項目');
// Two callbacks can interleave: unrecognized result clears rows but retains preceding text.
click('search');click('search');click('reply-denied');click('reply-other');
assert.equal(state(),'ST-08');assert.equal(table().length,0);assert.equal(dom.status.textContent,'不允許查閱');
dom.quantity.value='';const previous=state();const text=dom.status.textContent;
assert(dom['quantity-form'].fire('submit'));assert.deepEqual(alerts,['數量不得為空']);assert.equal(state(),previous);assert.equal(dom.status.textContent,text);
for (const value of ['3','4','-1','abc',' ']) {
 dom.quantity.value=value;assert(dom['quantity-form'].fire('submit'));assert.equal(state(),'ST-07');
 assert(dom['review-status'].textContent.includes('沒有計算費用'));
}
click('toggle-review');assert(dom.review.hidden);click('toggle-review');assert(!dom.review.hidden);
click('reset');assert.equal(state(),'ST-01');assert.equal(dom.status.textContent,'');assert.equal(table().length,0);assert.equal(dom.filter.value,'');assert.equal(dom.quantity.value,'');assert.equal(dom.pending.children.length,0);
click('reply-ok');assert.equal(state(),'ST-01');assert(dom['review-status'].textContent.includes('沒有待回應'));
console.log('PASS V-03: generated prototype script syntax and local DOM reactions executed.');
console.log('PASS: AC-01 visible initial subset; AC-02 trim/status/old-row timing; AC-03 synthetic rows; AC-04 EMPTY; AC-05 DENIED; AC-06 out-of-order response/status retention; AC-07 native alert invocation/block; AC-08 nonempty boundary subset; AC-10 other result; review reset/toggle.');
console.log('LIMIT: minimal fake DOM, not a browser; native dialog presentation, layout, focus, network panel and real initialization/API/business execution are unverified.');
