// Offline root behavior. All service and shared-runtime outcomes stay at explicit review boundaries.
// $ uses the locked local Prototype source.
const pendingChecks = []; let nextRequest = 1;
function setState(id){ document.documentElement.dataset.stateId=id; $('product').dataset.stateId=id; }
function reviewNote(text){ $('review-output').textContent=text; }
function snapshot(){ return Array.from(new FormData($('frm')).entries()); }
function handoff(kind){ reviewNote(JSON.stringify({reviewOnly:true, boundary:kind, form:snapshot()},null,2)); }
function doQuery(){ handoff('BOUND-01'); }
function doEdit(){ handoff('BOUND-04'); }
function doDelete(){ handoff('BOUND-05'); }
function doASync(){ handoff('BOUND-03'); }
function doASyncCheck(){ if(!valid.validate())return; injectValidated(); }
function injectValidated(){ const req={id:nextRequest++,inputId:$('inputId').value,options:{parameters:{inputId:$('inputId').value},onSuccess:function(XHT,resp){if(resp.isIdError==='Y'){if(confirm('輸入值 '+req.inputId+' 不符身份證/統一證號檢核規則，請確認，是否要繼續作業?'))doASync();else reviewNote('審閱工具：確認已取消，未取回。');}else doASync();}}};pendingChecks.push(req);Ajax.Responders.dispatch('onCreate',req);const option=document.createElement('option');option.value=req.id;option.textContent='請求 '+req.id+' / '+req.inputId;$('request-choice').append(option);reviewNote(JSON.stringify({reviewOnly:true,boundary:'BOUND-02',requestId:req.id,inputId:req.inputId},null,2));}
function injectResponse(){const id=Number($('request-choice').value);const at=pendingChecks.findIndex(r=>r.id===id);if(at<0){reviewNote('審閱工具：先建立請求。');return;}const req=pendingChecks.splice(at,1)[0];$('request-choice').querySelector('option[value="'+id+'"]').remove();const response={responseJSON:{isIdError:$('response-flag').value},responseText:''};try{req.options.onSuccess(response);}catch(error){Ajax.Responders.dispatch('onException',req,error);}Ajax.Responders.dispatch('onComplete',req,response);}
function sortTable1(col,tableToSort,rowToSort,dataType,idName){const arrow=$(idName);let type;if(arrow.innerText==='▼'){arrow.innerText='▲';type='0';}else{arrow.innerText='▼';type='1';}sortCol=-1;sortTable(col,tableToSort,rowToSort,dataType,type,false,'#F0F8FF','#FAFBE1');}
function openDetail(index){ const keys=["INSR_TYPE", "CMNY_CODE", "I_ID", "I_BIRTHDAY", "POLICY_NO", "POLICY_CAT", "POLICY_DUTY", "PROD_KIND", "STATUS", "LST_CHG_DATE", "MAIN_POLICY_NO", "ISSUE_DATE", "ISSUE_TIME", "LPS_DATE", "LPS_TIME", "SIGN_DATE", "PREM", "PAY_FREQ", "PAY_PERIOD", "LST_CHG_TIME", "PAY_AMT1", "PAY_AMT2", "PAY_AMT3", "PAY_AMT4", "PAY_AMT5", "PAY_AMT6", "PAY_AMT7", "PAY_AMT8", "PAY_AMT9", "PAY_AMT10", "PAY_AMT11", "PAY_AMT12", "PAY_AMT13", "PAY_AMT14", "PAY_AMT15", "PAY_AMT16", "PAY_AMT17", "PAY_AMT18", "PAY_AMT19", "BROKTYPE", "A_NAME", "A_ID", "A_BIRTHDAY", "RELATION", "UPDATE_TIME", "SER_NO", "I_GENDER", "PAY_TYPE", "OIU_IND", "SALE_CHNL", "PROD_CODE"]; const values=Object.fromEntries(keys.map(k=>[k,$(k+(k.startsWith('PAY_AMT')?'_':'')+index).value])); reviewNote(JSON.stringify({reviewOnly:true,boundary:'BOUND-06',newWindow:true,rowIndex:index,values,TODO:'TODO-04'},null,2)); }
function fix(){const bar=$('bar1'); if(bar)bar.style.top=(document.body.scrollTop-bar.offsetHeight+30)+'px';}
window.addEventListener('resize',fix); window.addEventListener('scroll',fix);
function updateFlags(){ document.querySelector('[data-context-flag="return"]').parentElement.hidden=!$('review-return').checked; const b=$('btn_async'); b.hidden=!$('review-allow').checked; }
$('frm').addEventListener('submit',e=>{e.preventDefault();reviewNote('審閱工具：原生隱式送出目的地未確認（TODO-05）；未連線。');});
$('review-return').addEventListener('change',updateFlags); $('review-allow').addEventListener('change',updateFlags);
$('inject-validation').addEventListener('click',function(e){e.stopPropagation();injectValidated();}); $('inject-response').addEventListener('click',function(e){e.stopPropagation();injectResponse();});
$('hide-review').addEventListener('click',()=>{$('review-tools').hidden=true;});
fix();
HotKeys.addHotKey(Keys.F2,new ButtonAction($('btn_query')));HotKeys.addHotKey(Keys.F8,new ButtonAction($('btn_async')));HotKeys.addHotKey(Keys.F9,new ButtonAction($('editBtn')));HotKeys.addHotKey(Keys.F10,new ButtonAction($('deleteBtn')));
var valid=new Validation('frm',{useTitles:false});valid.define('required',{id:'inputId',errMsg:'身份證字號/統一編號：不得為空值'});
updateFlags();displayMessage();
reviewNote('部分原型：根頁與可讀共用來源已還原；造字／自訂tag／CSS路徑／圖片／日期編碼及後端結果仍缺；可操作選列、取消、已知交接、條件展示與合成檢核回應。');
function selectItem(detailRadio) {
	$('TBL_NAME').value = $('TBL_NAME'+detailRadio.value).value;
	$('INSR_TYPE_text').textContent = $('INSR_TYPE'+detailRadio.value).value;
	$('INSR_TYPE').value = $('INSR_TYPE'+detailRadio.value).value;
	$('CMNY_CODE_text').textContent = $('CMNY_CODE'+detailRadio.value).value;
	$('CMNY_CODE').value = $('CMNY_CODE'+detailRadio.value).value;
	$('I_ID_text').textContent = $('I_ID'+detailRadio.value).value;
	$('I_ID').value = $('I_ID'+detailRadio.value).value;
	$('I_BIRTHDAY_text').textContent = $('I_BIRTHDAY'+detailRadio.value).value;
	$('I_BIRTHDAY').value = $('I_BIRTHDAY'+detailRadio.value).value;
	$('POLICY_NO_text').textContent = $('POLICY_NO'+detailRadio.value).value;
	$('POLICY_NO').value = $('POLICY_NO'+detailRadio.value).value;
	$('POLICY_CAT_text').textContent = $('POLICY_CAT'+detailRadio.value).value;
	$('POLICY_CAT').value = $('POLICY_CAT'+detailRadio.value).value;
	$('POLICY_DUTY_text').textContent = $('POLICY_DUTY'+detailRadio.value).value;
	$('POLICY_DUTY').value = $('POLICY_DUTY'+detailRadio.value).value;
	$('PROD_KIND_text').textContent = $('PROD_KIND'+detailRadio.value).value;
	$('PROD_KIND').value = $('PROD_KIND'+detailRadio.value).value;
	$('STATUS_text').textContent = $('STATUS'+detailRadio.value).value;
	$('STATUS').value = $('STATUS'+detailRadio.value).value;
	$('LST_CHG_DATE_text').textContent = $('LST_CHG_DATE'+detailRadio.value).value;
	$('LST_CHG_DATE').value = $('LST_CHG_DATE'+detailRadio.value).value;
	$('MAIN_POLICY_NO_text').textContent = $('MAIN_POLICY_NO'+detailRadio.value).value;
	$('MAIN_POLICY_NO').value = $('MAIN_POLICY_NO'+detailRadio.value).value;
	$('ISSUE_DATE_text').textContent = $('ISSUE_DATE'+detailRadio.value).value;
	$('ISSUE_DATE').value = $('ISSUE_DATE'+detailRadio.value).value;
	$('ISSUE_TIME_text').textContent = $('ISSUE_TIME'+detailRadio.value).value;
	$('ISSUE_TIME').value = $('ISSUE_TIME'+detailRadio.value).value;
	$('LPS_DATE_text').textContent = $('LPS_DATE'+detailRadio.value).value;
	$('LPS_DATE').value = $('LPS_DATE'+detailRadio.value).value;
	$('LPS_TIME_text').textContent = $('LPS_TIME'+detailRadio.value).value;
	$('LPS_TIME').value = $('LPS_TIME'+detailRadio.value).value;
	$('SIGN_DATE_text').textContent = $('SIGN_DATE'+detailRadio.value).value;
	$('SIGN_DATE').value = $('SIGN_DATE'+detailRadio.value).value;
	$('PREM_text').textContent = $('PREM'+detailRadio.value).value;
	$('PREM').value = $('PREM'+detailRadio.value).value;
	$('PAY_FREQ_text').textContent = $('PAY_FREQ'+detailRadio.value).value;
	$('PAY_FREQ').value = $('PAY_FREQ'+detailRadio.value).value;
	$('PAY_PERIOD_text').textContent = $('PAY_PERIOD'+detailRadio.value).value;
	$('PAY_PERIOD').value = $('PAY_PERIOD'+detailRadio.value).value;
	$('LST_CHG_TIME_text').textContent = $('LST_CHG_TIME'+detailRadio.value).value;
	$('LST_CHG_TIME').value = $('LST_CHG_TIME'+detailRadio.value).value;
	$('PAY_AMT1').value = $('PAY_AMT1_'+detailRadio.value).value;
	$('PAY_AMT2').value = $('PAY_AMT2_'+detailRadio.value).value;
	$('PAY_AMT3').value = $('PAY_AMT3_'+detailRadio.value).value;
	$('PAY_AMT4').value = $('PAY_AMT4_'+detailRadio.value).value;
	$('PAY_AMT5').value = $('PAY_AMT5_'+detailRadio.value).value;
	$('PAY_AMT6').value = $('PAY_AMT6_'+detailRadio.value).value;
	$('PAY_AMT7').value = $('PAY_AMT7_'+detailRadio.value).value;
	$('PAY_AMT8').value = $('PAY_AMT8_'+detailRadio.value).value;
	$('PAY_AMT9').value = $('PAY_AMT9_'+detailRadio.value).value;
	$('PAY_AMT10').value = $('PAY_AMT10_'+detailRadio.value).value;
	$('PAY_AMT11').value = $('PAY_AMT11_'+detailRadio.value).value;
	$('PAY_AMT12').value = $('PAY_AMT12_'+detailRadio.value).value;
	$('PAY_AMT13').value = $('PAY_AMT13_'+detailRadio.value).value;
	$('PAY_AMT14').value = $('PAY_AMT14_'+detailRadio.value).value;
	$('PAY_AMT15').value = $('PAY_AMT15_'+detailRadio.value).value;
	$('PAY_AMT16').value = $('PAY_AMT16_'+detailRadio.value).value;
	$('PAY_AMT17').value = $('PAY_AMT17_'+detailRadio.value).value;
	$('PAY_AMT18').value = $('PAY_AMT18_'+detailRadio.value).value;
	$('PAY_AMT19').value = $('PAY_AMT19_'+detailRadio.value).value;
	$('BROKTYPE').value = $('BROKTYPE'+detailRadio.value).value;
	$('A_NAME').value = $('A_NAME'+detailRadio.value).value;
	$('A_ID').value = $('A_ID'+detailRadio.value).value;
	$('A_BIRTHDAY').value = $('A_BIRTHDAY'+detailRadio.value).value;
	$('RELATION').value = $('RELATION'+detailRadio.value).value;
	$('UPDATE_TIME_text').textContent = $('INPUT_TIME'+detailRadio.value).value; // 編輯區內取 INPUT_TIME
	$('UPDATE_TIME').value = $('UPDATE_TIME'+detailRadio.value).value;
	$('SER_NO_text').textContent = $('SER_NO'+detailRadio.value).value;
	$('SER_NO').value = $('SER_NO'+detailRadio.value).value;
	$('I_GENDER').value = $('I_GENDER'+detailRadio.value).value; // 性別
	$('PAY_TYPE').value = $('PAY_TYPE'+detailRadio.value).value; // 公、自費 
	$('OIU_IND').textContent = $('OIU_IND_DESC'+detailRadio.value).value;     // 來源別
	$('SALE_CHNL').textContent = $('SALE_CHNL_DESC'+detailRadio.value).value; // 銷售通路				
    $('PROD_CODE').textContent = $('PROD_CODE'+detailRadio.value).value;      // 商品代碼
	
	$('editBtn').disabled = false;
	$('deleteBtn').disabled = false;
	$('cleanAllBtn').disabled = false;
	$('editArea').style.display = "block";
	
	setState('ST-02'); reviewNote('TODO-01：造字處理未建立共用契約；已停止在該呼叫邊界。');
}
function doCleanAll() {
	$('TBL_NAME').value = "";
	$('INSR_TYPE_text').textContent = "";
	$('INSR_TYPE').value = "";
	$('CMNY_CODE_text').textContent = "";
	$('CMNY_CODE').value = "";
	$('I_ID_text').textContent = "";
	$('I_ID').value = "";
	$('I_BIRTHDAY_text').textContent = "";
	$('I_BIRTHDAY').value = "";
	$('POLICY_NO_text').textContent = "";
	$('POLICY_NO').value = "";
	$('POLICY_CAT_text').textContent = "";
	$('POLICY_CAT').value = "";
	$('POLICY_DUTY_text').textContent = "";
	$('POLICY_DUTY').value = "";
	$('PROD_KIND_text').textContent = "";
	$('PROD_KIND').value = "";
	$('STATUS_text').textContent = "";
	$('STATUS').value = "";
	$('LST_CHG_DATE_text').textContent = "";
	$('LST_CHG_DATE').value = "";
	$('MAIN_POLICY_NO_text').textContent = "";
	$('MAIN_POLICY_NO').value = "";
	$('ISSUE_DATE_text').textContent = "";
	$('ISSUE_DATE').value = "";
	$('ISSUE_TIME_text').textContent = "";
	$('ISSUE_TIME').value = "";
	$('LPS_DATE_text').textContent = "";
	$('LPS_DATE').value = "";
	$('LPS_TIME_text').textContent = "";
	$('LPS_TIME').value = "";
	$('SIGN_DATE_text').textContent = "";
	$('SIGN_DATE').value = ""
	$('PREM_text').textContent = "";
	$('PREM').value = "";
	$('PAY_FREQ_text').textContent = "";
	$('PAY_FREQ').value = "";
	$('PAY_PERIOD_text').textContent = "";
	$('PAY_PERIOD').value = "";
	$('LST_CHG_TIME_text').textContent = "";
	$('LST_CHG_TIME').value = "";
	$('PAY_AMT1').value = "";
	$('PAY_AMT2').value = "";
	$('PAY_AMT3').value = "";
	$('PAY_AMT4').value = "";
	$('PAY_AMT5').value = "";
	$('PAY_AMT6').value = "";
	$('PAY_AMT7').value = "";
	$('PAY_AMT8').value = "";
	$('PAY_AMT9').value = "";
	$('PAY_AMT10').value = "";
	$('PAY_AMT11').value = "";
	$('PAY_AMT12').value = "";
	$('PAY_AMT13').value = "";
	$('PAY_AMT14').value = "";
	$('PAY_AMT15').value = "";
	$('PAY_AMT16').value = "";
	$('PAY_AMT17').value = "";
	$('PAY_AMT18').value = "";
	$('PAY_AMT19').value = "";
	$('BROKTYPE').value = "";
	$('A_NAME').value = "";
	$('A_ID').value = "";
	$('A_BIRTHDAY').value = "";
	$('RELATION').value = "";
	$('UPDATE_TIME_text').textContent = "";
	$('UPDATE_TIME').value = "";
	$('SER_NO_text').textContent = "";
	$('SER_NO').value = "";
	$('I_GENDER').value = "";
	$('PAY_TYPE').value = "";
	$('OIU_IND').textContent = "";
	$('SALE_CHNL').textContent = "";
	$('PROD_CODE').textContent = "";
	
	var ele = document.getElementsByName("item");
   	for(var i=0;i<ele.length;i++){
   		ele[i].checked = false;
   	}
   	
   	$('editBtn').disabled = true;
	$('deleteBtn').disabled = true;
	$('cleanAllBtn').disabled = true;
	$('editArea').style.display = 'none'; setState('ST-01');
}