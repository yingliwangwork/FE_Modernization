// Executes only this case's inline prototype script with minimal DOM test doubles.
// Not a browser, native HTML validation, JSP execution or backend integration test.
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { resolve } from 'node:path';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
const report = [];
function passed(name) { report.push('PASS: ' + name); }
const manifest = JSON.parse(readFileSync('manifest.json', 'utf8'));
for (const entry of manifest.files) {
  const actual = createHash('sha256').update(readFileSync(entry.path)).digest('hex');
  assert.equal(actual, entry.sha256, entry.path);
}
passed('all 22 frozen input/skill SHA-256 values unchanged');
const files = [
  'artifacts/design/fixture-case/specification.md',
  'artifacts/design/fixture-case/prototypes/SCR-001.html',
  'artifacts/integration/fixture-case/api-spec.md',
  'artifacts/integration/fixture-case/backend-handoff.md',
  'artifacts/renovation/fixture-case/tracking.md'
];
const specification = readFileSync(files[0], 'utf8');
const html = readFileSync(files[1], 'utf8');
const tracking = readFileSync(files[4], 'utf8');
for (const file of files) {
  const text = readFileSync(file, 'utf8');
  assert(!/\{\{[^}]*\}\}/.test(text), 'placeholder in ' + file);
  for (const match of text.matchAll(/\]\(([^)]+)\)/g)) {
    const target = match[1].split('#')[0];
    if (!target || /^https?:/.test(target)) continue;
    assert(existsSync(resolve(file, '..', target)), file + ' missing link ' + target);
  }
  for (const match of text.matchAll(/tracking\.md#([a-z0-9-]+)/g)) {
    assert(match[1] === '3-evidence-register' || tracking.includes('### ' + match[1].toUpperCase()), 'missing tracking anchor ' + match[1]);
  }
}
passed('five primary artifacts: no template placeholders; relative links and tracking anchors resolve');
assert(/data-scope-id="fixture-case"/.test(html));
assert(/data-screen-id="SCR-001"/.test(html));
assert(/data-state-id="ST-001"/.test(html));
for (const match of html.matchAll(/data-(?:ui|flow|component)-id="([A-Z]+-\d+)"/g)) {
  assert(specification.includes(match[1]), 'unmapped prototype ID ' + match[1]);
}
for (const match of html.matchAll(/'((?:ST|UI)-\d+)'/g)) assert(specification.includes(match[1]), 'unmapped script ID ' + match[1]);
const uniqueIds = [...html.matchAll(/\sid="([^"]+)"/g)].map(match => match[1]);
assert.equal(new Set(uniqueIds).size, uniqueIds.length);
passed('scope/screen/state attributes, all DOM product IDs and script state/cell IDs map to specification; HTML id attributes unique');
assert(!/<(?:script|link|img|iframe)[^>]+(?:src|href)=/i.test(html), 'unexpected external resource');
const script = html.match(/<script>([\s\S]*?)<\/script>/)[1];
assert(!/\b(?:fetch|XMLHttpRequest|WebSocket|localStorage|sessionStorage)\s*[.(]/.test(script));
assert(!/quantity\s*\*|quantity\s*>=|Ledger\s*\./.test(script));
passed('static prototype has no fetched resources, network/storage APIs, charge calculation or Ledger invocation');
const syntax = spawnSync(process.execPath, ['--check', '--input-type=commonjs'], { input: script, encoding: 'utf8' });
assert.equal(syntax.status, 0, syntax.stderr);
passed('Node --check passes for actual inline prototype script');
function element(id) {
  return { id, value: '', checked: false, dataset: {}, textContent: '', listeners: {},
    addEventListener(type, fn) { this.listeners[type] = fn; } };
}
const elements = Object.fromEntries(uniqueIds.map(id => [id, element(id)]));
const rows = elements.rows;
rows.rowData = [];
Object.defineProperty(rows, 'textContent', { get() { return ''; }, set() { this.rowData = []; } });
rows.insertRow = function () {
  const row = { cells: [], insertCell() { const cell = { textContent: '', dataset: {} }; this.cells.push(cell); return cell; } };
  this.rowData.push(row); return row;
};
elements['response-scenario'].value = 'DONE';
const alerts = [];
const timers = new Map();
let timerId = 0;
const context = vm.createContext({ document: { getElementById(id) { assert(elements[id], 'missing element ' + id); return elements[id]; } },
  alert(message) { alerts.push(message); },
  setTimeout(fn) { const id = ++timerId; timers.set(id, fn); return id; },
  clearTimeout(id) { timers.delete(id); }
});
vm.runInContext(script, context);
function click(id) { elements[id].listeners.click(); }
function flush() { for (const [id, fn] of [...timers]) { timers.delete(id); fn(); } }
function cells() { return rows.rowData.map(row => row.cells.map(cell => cell.textContent)); }
function scenario(value) { elements['response-scenario'].value = value; }
const canvas = elements['product-canvas'];
// AC-002/003: status first; old rows survive until callback; input is not rewritten.
elements.status.textContent = '舊訊息';
rows.insertRow().insertCell().textContent = '舊資料';
elements.filter.value = '  示例  ';
click('lookup');
assert.equal(elements.status.textContent, '');
assert.equal(rows.rowData[0].cells[0].textContent, '舊資料');
assert.equal(elements.filter.value, '  示例  ');
assert(elements['boundary-log'].textContent.includes('{"queryText":"示例"}'));
assert.equal(canvas.dataset.stateId, 'ST-002');
flush();
assert.deepEqual(cells(), [['DEMO-B', '展示項目乙', '展示提示乙'], ['DEMO-A', '展示項目甲', '展示提示甲']]);
assert.equal(canvas.dataset.stateId, 'ST-003');
passed('AC-002/003: status clears before callback; old rows/input retained; trim logged; success renders supplied order and static hints');
for (const [value, message, state] of [['NONE', '沒有項目', 'ST-004'], ['BLOCK', '不允許查閱', 'ST-005'], ['OTHER', '', 'ST-006']]) {
  scenario(value); click('lookup'); flush();
  assert.equal(rows.rowData.length, 0);
  assert.equal(elements.status.textContent, message);
  assert.equal(canvas.dataset.stateId, state);
}
passed('AC-004/005/006: no-items, denied and unmatched legacy branches clear rows and preserve sourced messages/no extra message');
// AC-012: overlapping source callbacks retain the earlier denied message on success.
elements['hold-response'].checked = true;
scenario('BLOCK'); click('lookup');
scenario('DONE'); click('lookup');
click('release-response');
assert.equal(elements.status.textContent, '不允許查閱');
click('release-response');
assert.equal(rows.rowData.length, 2);
assert.equal(elements.status.textContent, '不允許查閱');
assert.equal(canvas.dataset.stateId, 'ST-003');
passed('AC-012: two held calls accepted; denied then success leaves denied status beside success rows, matching source sequence');
// Quantity uses the actual submit listener; real posting is always prevented.
let preventionCount = 0;
const event = { preventDefault() { preventionCount++; } };
elements.quantity.value = '';
assert.equal(elements['quantity-form'].listeners.submit(event), false);
assert.equal(alerts.at(-1), '數量不得為空');
assert.equal(canvas.dataset.stateId, 'ST-007');
assert.equal(canvas.dataset.searchStateId, 'ST-003');
assert.equal(rows.rowData.length, 2);
assert.equal(elements.status.textContent, '不允許查閱');
passed('AC-007: actual quantity listener blocks empty text, alerts exact message, retains prior rows/status/search state');
for (const quantity of [' ', 'abc', '3', '4']) {
  elements.quantity.value = quantity;
  assert.equal(elements['quantity-form'].listeners.submit(event), true);
  assert.equal(canvas.dataset.stateId, 'ST-008');
  assert(elements['boundary-log'].textContent.includes(JSON.stringify({ mode: 'commit', quantity })));
  assert(!elements['boundary-log'].textContent.includes('charge'));
}
assert.equal(preventionCount, 5);
passed('AC-008: whitespace/nonnumeric/3/4 pass only exact-empty check; boundary reached; form posting prevented and no charge computed');
scenario('TARGET_OK'); click('lookup'); click('release-response');
assert.deepEqual(cells(), [['DEMO-B', '展示項目乙', ''], ['DEMO-A', '展示項目甲', '']]);
assert(elements['review-status'].textContent.includes('TODO-002'));
passed('AC-013: target fixture has only confirmed identifier/name data; ranking gap blank and disclosed in review layer');
click('reset-review');
assert.equal(rows.rowData.length, 0);
assert.equal(elements.status.textContent, '');
assert.equal(elements.filter.value, '');
assert.equal(elements.quantity.value, '');
assert.equal(canvas.dataset.stateId, 'ST-001');
assert.equal(canvas.dataset.searchStateId, 'ST-001');
assert.equal(canvas.dataset.quantityStateId, 'ST-001');
passed('review reset restores initial local values and all state attributes');
report.push('LIMIT: minimal DOM doubles execute actual script only. No native maxlength/keyboard/focus/layout/dialog behavior, browser console/network observation, JSP runtime, backend call, persistence, auth or deployment check. AC-001/009/010/011/014 are not fully runtime-executed.');
const output = report.join('\n') + '\n';
writeFileSync('artifacts/renovation/fixture-case/local-check-results.txt', output);
console.log(output);
