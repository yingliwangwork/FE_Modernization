
'use strict';
// Offline presentation only. No calculation, endpoint, storage or trusted state emulation.
const product = document.getElementById('product');
const statusNode = document.getElementById('status');
const rowsNode = document.getElementById('rows');
const filterNode = document.getElementById('filter');
const quantityNode = document.getElementById('quantity');
const reviewLog = document.getElementById('review-log');
let pending = false;
function setState(id) {
 document.documentElement.dataset.stateId = id;
 product.dataset.stateId = id;
}
function note(text) { reviewLog.textContent = text; }
document.getElementById('search').addEventListener('click', () => {
 statusNode.textContent = '';
 const searchWord = filterNode.value.trim();
 pending = true;
 setState('ST-02');
 note('ST-02；清空狀態，保留舊列。修剪後關鍵字：' + JSON.stringify(searchWord) + '\nBOUND-02 僅記錄本機交接；目標 queryText 有證據映射，不含 client unitId。請用審閱工具交付合成回應。');
});
document.getElementById('review-deliver').addEventListener('click', () => {
 if (!pending) {
  note('審閱工具：請先點產品「查閱」。這是本機展示順序限制，不是新增產品規則。');
  return;
 }
 const result = document.getElementById('review-result').value;
 rowsNode.textContent = '';
 if (result === 'DONE') {
  // Synthetic legacy snapshots; rankHint is deliberately not a target API schema claim.
  const fixtures = [
   {itemKey:'DEMO01', itemText:'展示名稱一', rankHint:'展示排序值甲'},
   {itemKey:'DEMO02', itemText:'展示名稱二', rankHint:'展示排序值乙'}
  ];
  fixtures.forEach(item => {
   const row = rowsNode.insertRow();
   row.insertCell().textContent = item.itemKey;
   row.insertCell().textContent = item.itemText;
   row.insertCell().textContent = item.rankHint;
  });
  setState('ST-03');
  note('ST-03；只交付合成 legacy 資料。目標 OK 僅確認 rowId、label，沒有 rankHint；TODO-02 尚未解決。');
 } else if (result === 'NONE') {
  statusNode.textContent = '沒有項目';
  setState('ST-04');
  note('ST-04；空列與 MSG-01 原文。對應目標 EMPTY；無真實服務呼叫。');
 } else if (result === 'BLOCK') {
  statusNode.textContent = '不允許查閱';
  setState('ST-05');
  note('ST-05；空列與 MSG-02 原文。對應目標 DENIED；不代表實際授權已驗證。');
 } else {
  setState('ST-06');
  note('ST-06；只展示 legacy 其他碼的已知前綴：清空列且未新增訊息。目標未定義其他結果，完整反應 TODO-05。');
 }
 pending = false;
});
document.getElementById('quantity-form').addEventListener('submit', event => {
 event.preventDefault();
 if (quantityNode.value === '') {
  window.alert('數量不得為空');
  setState('ST-07');
  note('ST-07；MSG-03 警示後攔截；查閱內容與輸入保持不變，沒有 BOUND-03 交接。');
  return;
 }
 note('BOUND-03：前端允許交接數量原文 ' + JSON.stringify(quantityNode.value) + '。停在已知邊界（TODO-03／TODO-04）；未解析、未計算、未保存、未重新呈現。產品內容未添加完成訊息。');
});
document.getElementById('review-reset').addEventListener('click', () => {
 filterNode.value = '';
 quantityNode.value = '';
 statusNode.textContent = '';
 rowsNode.textContent = '';
 pending = false;
 setState('ST-01');
 note('ST-01；審閱工具重設合成展示，不代表產品有重設操作。尚未執行瀏覽器驗證。');
});
