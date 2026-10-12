
'use strict';
const root=document.getElementById('product'), table=document.getElementById('table1'), cover=document.getElementById('cover'), reviewStatus=document.getElementById('reviewStatus');
let sequence=0, pending=false;
function rows(){return Array.from(table.rows).slice(3);}
function state(value){root.dataset.stateId=value;}
function note(value){reviewStatus.textContent=value;}
function colorRows(){rows().forEach((row,index)=>{row.style.backgroundColor=index%2===0?'#EEF1A7':'#FAFBE1';});}
function editableState(){state(rows().length?'ST-02':'ST-01');}
function addRow(){
 sequence+=1; const row=table.insertRow(); row.id='table1_row_'+sequence;
 const del=row.insertCell();del.align='center'; const b=document.createElement('input');b.type='button';b.value='刪除此列';b.className='button';b.dataset.uiId='UI-07';b.dataset.flowId='FLOW-03'; b.addEventListener('click',()=>{row.remove();colorRows();editableState();});del.append(b);
 const idcell=row.insertCell();idcell.align='center';const id=document.createElement('input');id.type='text';id.name='I_ID';id.size=12;id.maxLength=10;id.id='I_ID_'+sequence;id.className='textBox2';id.dataset.uiId='UI-08';id.dataset.flowId='FLOW-07';idcell.append(id);
 const policycell=row.insertCell();policycell.align='center';const p=document.createElement('textarea');p.rows=3;p.cols=30;p.name='POLICY_NO';p.id='POLICY_NO_'+sequence;p.className='textBox2';p.dataset.uiId='UI-09';p.dataset.flowId='FLOW-07';policycell.append(p);
 const result=row.insertCell();result.dataset.uiId='UI-10';colorRows();editableState();return row;
}
function exportRows(){
 const list=rows();
 for(let i=0;i<list.length;i++){
  const id=list[i].querySelector('input[name="I_ID"]').value, policy=list[i].querySelector('textarea').value;
  if(id===''||policy===''){state('ST-03');alert('第'+(i+1)+'列的被保人ID或保單號碼不得為空值，若不需要請刪除該列');return;}
  for(let j=i+1;j<list.length;j++){
   if(id===list[j].querySelector('input[name="I_ID"]').value){state('ST-03');alert('被保人ID：'+id+'有重覆出現，請合併在同一列處理');return;}
  }
 }
 pending=true;cover.hidden=false;state('ST-04');note('ST-04／BOUND-01：已到匯出交接邊界，未送出請求。零列不受前端阻擋。使用審閱工具注入已知舊回應形狀；新目標错误 data=null 無法替代此形狀。');
}
function inject(accepted){
 if(!pending){note('審閱工具：先點產品「匯出檔案」進入交接狀態；沒有請求，不注入回應。');return;}
 const map=new Map(rows().map(row=>[row.querySelector('input[name="I_ID"]').value,accepted?'已匯出':'ID長度預為10碼']));
 rows().forEach(row=>{row.cells[3].textContent=map.get(row.querySelector('input[name="I_ID"]').value);});
 pending=false;cover.hidden=true;state('ST-05');
 if(accepted){state('ST-06');note('ST-06／BOUND-02：先更新逐列結果，再交接合成檔名 ATL_DEMO.xlsx。未下載／未產生檔案；此非正式服務結果。');}
 else {note('ST-05：注入舊拒絕形狀，只更新逐列結果，沒有下載。所選目標 code=500／data=null 無此結果，TODO-01 未解。');}
}
function reset(){rows().forEach(row=>row.remove());sequence=0;pending=false;cover.hidden=true;document.getElementById('insrType').value='L';document.getElementById('prodType').value='AT';state('ST-01');note('初始 ST-01：零列；入口訊息來源未知，未模擬訊息。');}
document.getElementById('frm').addEventListener('submit',event=>event.preventDefault());
document.getElementById('addBtn').addEventListener('click',addRow);
document.getElementById('exportBtn').addEventListener('click',exportRows);
document.getElementById('accept').addEventListener('click',()=>inject(true));
document.getElementById('reject').addEventListener('click',()=>inject(false));
document.getElementById('reset').addEventListener('click',reset);
document.getElementById('hide').addEventListener('click',()=>{document.getElementById('review').hidden=true;});
document.getElementById('fixture').addEventListener('click',()=>{reset();['DEMO000001','DEMO000002'].forEach((id,i)=>{const row=addRow();row.querySelector('input[name="I_ID"]').value=id;row.querySelector('textarea').value=i===0?'DEMO-P01\nDEMO-P02':'DEMO-P03';});note('合成輸入；不是可查到的保單。點「匯出檔案」可到交接邊界。');});
