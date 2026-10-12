// Offline review adapter. No backend business calculation, write, or network call.
const page = document.documentElement;
const byId = id => document.getElementById(id);
const requests = [];
let requestSequence = 0;
let stateBeforeAlert = 'ST-INIT';
function setState(state) { page.dataset.stateId = state; }
function updatePending() {
  const select = byId('pending');
  select.textContent = '';
  requests.filter(request => !request.delivered).forEach(request => {
    const option = document.createElement('option');
    option.value = String(request.id);
    option.textContent = `R${request.id}：${request.query}`;
    select.appendChild(option);
  });
}
function beginSearch() {
  byId('status').textContent = '';
  const request = {id: ++requestSequence, query: byId('filter').value.trim(), delivered: false};
  requests.push(request);
  setState('ST-WAIT');
  updatePending();
  byId('reviewLog').textContent = `已建立 R${request.id}，交接關鍵字「${request.query}」；等待合成回應。`;
}
function receiveResult(result) {
  const body = byId('rows');
  body.textContent = '';
  if (result.businessResult === 'DONE') {
    result.itemList.forEach(item => {
      const row = body.insertRow();
      row.insertCell().textContent = item.itemKey;
      row.insertCell().textContent = item.itemText;
      row.insertCell().textContent = item.rankHint;
    });
    setState('ST-ROWS');
  } else if (result.businessResult === 'NONE') {
    byId('status').textContent = '沒有項目';
    setState('ST-EMPTY');
  } else if (result.businessResult === 'BLOCK') {
    byId('status').textContent = '不允許查閱';
    setState('ST-DENIED');
  } else {
    setState('ST-UNCLASSIFIED');
  }
}
function deliverSelected() {
  const request = requests.find(item => String(item.id) === byId('pending').value && !item.delivered);
  if (!request) { byId('reviewLog').textContent = '先按產品「查閱」建立請求。'; return; }
  const outcome = byId('response').value;
  const synthetic = {businessResult: outcome, itemList: outcome === 'DONE' ? [
    {itemKey:'a', itemText:'展示甲', rankHint:'2'},
    {itemKey:'b', itemText:'展示乙', rankHint:'1'}
  ] : []};
  receiveResult(synthetic);
  request.delivered = true;
  updatePending();
  byId('reviewLog').textContent = `已交付 R${request.id}：${outcome}，為合成 legacy 形狀回應。`;
}
function submitQuantity(event) {
  event.preventDefault();
  if (byId('quantity').value === '') {
    stateBeforeAlert = page.dataset.stateId;
    setState('ST-QUANTITY-EMPTY');
    window.alert('數量不得為空');
    setState(stateBeforeAlert);
    return false;
  }
  setState('ST-SUBMIT');
  byId('handoffNote').textContent = '展示已停在數量提交邊界（TODO-03）；後端責任尚未承接。';
  return true;
}
byId('search').addEventListener('click', beginSearch);
byId('deliver').addEventListener('click', deliverSelected);
byId('quantityForm').addEventListener('submit', submitQuantity);
