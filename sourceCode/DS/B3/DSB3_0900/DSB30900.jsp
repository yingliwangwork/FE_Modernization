<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSB30900.jsp
作者：張憶如 
功能：火險加保資料輸入
完成：2014/4/24

[20240613]
難字調整
高強禾
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script> 	<%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>		<%-- CSR相關處理用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>		<%-- TableUI --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>		<%-- 標準外框表格 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>		<%-- 檢核用 --%>
<script type="text/JavaScript" src="${htmlBase}/CM/js/RPTUtil.js"></script>		<%-- 報表列印 --%>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script>
<%-- [20240613] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/JavaScript">

<%--產生畫面物件--%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp--%>
Event.observe(window, 'load', new DSB30900().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
<%--以下為UI() public method,放在 return 中--%>
function DSB30900(){
	
	var grid;
	var validQuery;		<%--查詢檢核--%>
	var validInsert;	<%--新增、修改檢核--%>
	
	function buttonAuth(){
		var authButtons = {
			B0003:"btn_insert",		<%--新增--%>
			B0004:"btn_update",		<%--修改--%>			
			B0005:"btn_delete",		<%--刪除--%>			
			B0028:"btn_confirm",	<%--確認--%> 
			B0174:"btn_print"		<%--列印--%> 			
		};
		
		<dz:grantButtons FUNC_ID="DSB30900"/>
	}
	
	<%--畫面檢核--%>
	function initValidation(){
		Validation.addAllThese([
			[ 'check2ID',  '受理編號、貸款帳號請至少輸入一欄再執行查詢作業',
				function(v){
					if(Validation.get('IsEmpty').test($F('LOAN_ID_INPUT')) && Validation.get('IsEmpty').test($F('APPLY_ID_INPUT'))){
						return false;
					}
					return true;
				}
			],
			[ 'checkEFFECT_DATE',  '批單生效日必須大於等於前一日',checkEFFECT_DATE],
			[ 'checkEFFECT_DATE2',  '批單生效日需介於火險起日~火險迄日',checkEFFECT_DATE2],
			[ 'checkADD_AMT',  '火險加保保額需為大於0之正整數',function(v){
					var new_value = Number(v);
					if(new_value <= 0 || (new_value - parseInt(v, 10) != 0)){
						return false;	
					}
					return true;
			}]
		]);
		validQuery = new Validation("form", { focusOnError:true, immediate:false, mode:'validator'});	
		validQuery.define('check2ID' , [{ id : "LOAN_ID_INPUT" , ignore : true}]);
		validQuery.define('check2ID' , [{ id : "APPLY_ID_INPUT"}]);
		
		validInsert = new Validation("form", { focusOnError:true, immediate:false, mode:'validator'});	
		
	}
	<%--批單生效日需>=CURRENT DATE-1--%>
	var checkEFFECT_DATE = function(v){
		var today = getToday();					
		if(diffDayROC(today,v) < -1){
			return false;
		}
		return true;
	}
	
	<%--批單生效日需介於火險起日~火險迄日--%>
	var checkEFFECT_DATE2 = function(v){
		if(diffDay($('FIREINSU_BEGDT').innerHTML,v) < 0 || diffDay($('FIREINSU_ENDDT').innerHTML,v) > 0){
			return false;
		}
		return true;
	}
	
	
	function validateInsertAndUpdate(action){
		validQuery.reset();
		validInsert.reset();
		validInsert.clear();
		validInsert.define('validate-selection', [{id: 'FIREINSU_POLNO', errMsg: '請選擇保單號碼'}]);
		validInsert.define('required', [{id: 'ADD_APPLY_ID', errMsg: '請輸入增貸件受理編號'}]);
		validInsert.define('required', [{id: 'ADD_AMT', errMsg: '請輸入火險加保保額'}]);
		validInsert.define('checkADD_AMT', [{id: 'ADD_AMT'}]);
		validInsert.define('required', [{id: 'EFFECT_DATE', errMsg: '請輸入批單生效日'}]);
		validInsert.define('checkEFFECT_DATE', [{id: 'EFFECT_DATE'}]);
		validInsert.define('checkEFFECT_DATE2', [{id: 'EFFECT_DATE'}]);
		if(!$('AGENT_NAME').innerHTML){
			validInsert.define('required', [{id: 'NEW_AGENT_ID', errMsg: '無經手人員，請輸入新火險經手人ID'}]);
		}
		if($('AGENT_IS_CHANGE').checked){
			validInsert.define('required', [{id: 'NEW_AGENT_ID', errMsg: '請輸入新火險經手人ID'}]);
		}	
		
	}
	
	<%--建立 ajax request 物件--%>
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSB3_0900/');
	
	var actions = {
		showData: function(resp){
			<%--B Block--%>
			grid.load(resp.rtnList || []);
			
			<%--保單號碼下拉選單--%>
			var FIREINSU_LIST = resp.FIREINSU_LIST || [];
			$('FIREINSU_POLNO').length = 1;		
			for(var i =0; i < FIREINSU_LIST.length; i++){
				var map = FIREINSU_LIST[i]||{};
				var value = map['FIREINSU_POLNO']||'';
				var option = new Option(value,value);
				option.GAGE_ADDR = map['GAGE_ADDR']||'';
				option.INSUFREE_CODE = map['INSUFREE_CODE']||'';
				option.FIREINSU_BEGDT = map['FIREINSU_BEGDT']||'';
				option.FIREINSU_ENDDT = map['FIREINSU_ENDDT']||'';
				$('FIREINSU_POLNO').add(option);
			}
			
			$('btn_insert').enable();
			<%--C Block--%>
			var newMap = resp.newMap || {};
			actions.showBlockC(newMap);			
			
		},
		<%--顯示C Block的資料--%>
		showBlockC: function(newMap){
			
			$('tableC').select('input[type!=button]', 'select').each(function(ele){
				var id = ele.id;
				var value = newMap[id];
				var datatype = ele.getAttribute("datatype");
				if(datatype=='ROCdate'){					
					ele.value = value? toROC(value):'';
				}else if(datatype=='number'){
					ele.value = CSRUtil.$fmt(value, '#,###.#####');
				}else{
					ele.value = value||'';
				}
			});
			var df = new SimpleDateFormat('yyy/MM/dd', SimpleDateFormat.TW);
			$('tableC').select('span').each(function(ele){
				var id = ele.id;
				var value = newMap[id];
				var datatype = ele.getAttribute("datatype");
				if(datatype=='ROCdate'){					
					ele.update(value?df.format(value):'');	
				}else if(datatype=='number'){
					ele.update(CSRUtil.$fmt(value, '#,###.#####'));
				}else{
					ele.update(value||'');
				}
			});
			
			$('AGENT_IS_CHANGE').checked = newMap['AGENT_IS_CHANGE']=='1';
			
		},
		<%--取得C Block的資料--%>
		getCBlock: function(){
			var reqMap = {};
			var df = new SimpleDateFormat('yyyy-MM-dd', SimpleDateFormat.US);
			$('tableC').select('input[type!=button]', 'select').each(function(ele){
				var id = ele.id;
				var value = ele.getValue();
				if(ele.getAttribute("datatype")=='ROCdate'){
					reqMap[id] = value ? df.format(value):'';
				}else{
					reqMap[id] = value||'';
				}
			});
			$('tableC').select('span').each(function(ele){
				var id = ele.id;
				var value = ele.innerHTML;
				if(ele.getAttribute("datatype")=='ROCdate'){
					reqMap[id] = value?df.format(value):'';
				}else{
					reqMap[id] = value||'';
				}
			});
			
			reqMap['AGENT_IS_CHANGE']= $('AGENT_IS_CHANGE').checked? '1': '0';
			
			return reqMap;
		},
		<%--保單號碼連動事件--%>
		changeFIREINSU_POLNO:function(event){			
			var ele = event.target;
			if(ele.value){
				var df = new SimpleDateFormat('yyy/MM/dd', SimpleDateFormat.TW);
				var selectOption = ele.options[ele.selectedIndex];
				<%--保險標的--%>
				$('GAGE_ADDR').innerHTML = selectOption.GAGE_ADDR||'';
				
				<%--是否贈送火險--%>
				$('INSUFREE_CODE').value = selectOption.INSUFREE_CODE||'0';
				
				<%--火險起日--%>
				var FIREINSU_BEGDT = selectOption.FIREINSU_BEGDT||'';
				$('FIREINSU_BEGDT').innerHTML = FIREINSU_BEGDT ? df.format(FIREINSU_BEGDT):'';
				
				<%--火險迄日--%>
				var FIREINSU_ENDDT = selectOption.FIREINSU_ENDDT||'';
				$('FIREINSU_ENDDT').innerHTML = FIREINSU_ENDDT? df.format(FIREINSU_ENDDT):'';
			}else{
				$w('GAGE_ADDR FIREINSU_BEGDT FIREINSU_ENDDT').each(function(ele){
					ele.innerHTML = '';
				});
				
				$('INSUFREE_CODE').value = '0';
			}
		},
		<%--增貸件受理編號連動事件--%>
		changeADD_APPLY_ID:function(event){
			var ADD_APPLY_ID = event.target.value.toUpperCase();
			if(ADD_APPLY_ID){
				ajaxRequest.post( 'changeADD_APPLY_ID', {ADD_APPLY_ID : ADD_APPLY_ID}, 
					function(resp){
						var A010VO = resp.A010VO;
						<%--經手人員--%>
						$('AGENT_NAME').innerHTML = A010VO.AGENT_NAME||'';
						<%--經手人員id--%>
						$('AGENT_ID').value = A010VO.AGENT_ID||'';
					},
					function(resp){
						<%--經手人員--%>
						$('AGENT_NAME').innerHTML = '';				
						<%--經手人員id--%>
						$('AGENT_ID').value = '';
						<%--增貸件受理編號--%>
						event.target.value = '';
					}
				);				
			}else{
				<%--經手人員--%>
				$('AGENT_NAME').innerHTML = '';				
				<%--經手人員id--%>
				$('AGENT_ID').value = '';
			}
		},
		getReqMap: function(){
			var reqMap = {
				'LOAN_ID': $F('LOAN_ID_INPUT')
				,'APPLY_ID': $F('APPLY_ID_INPUT')
			};
			return reqMap;
		}
	};
	var oldQueryData = {};
	var buttons = {		
		<%--查詢--%>
		doQuery : function(){
			
			validQuery.reset();
			validInsert.reset();
			
			if(!validQuery.validate()){					
				return;			
			}
			var reqMap = actions.getReqMap();
			oldQueryData = reqMap;
			ajaxRequest.post( 'query', {reqMap: Object.toJSON(reqMap)},
				function(resp){	
					actions.showData(resp);
				},
				function(resp){
					actions.showData({});
					grid.load([]);
				}
			);				
		},
		<%--新增前的檢核--%>
		doInsertCheck : function(){
			
			if($('APPLY_ID').innerHTML == ''){
				alert('請先查詢再執行新增作業');
				return;
			}			
			validateInsertAndUpdate('insert');
			if(!validInsert.validate()){					
				return;			
			}
			if(!$('AGENT_IS_CHANGE').checked && $F('NEW_AGENT_ID')){
				alert('若輸入新火險經手人ID，請勾選是否變更');
				return;
			}
			
			if($('AGENT_IS_CHANGE').checked){
				if(!confirm('確定要變更火險經手人為'+$F('NEW_AGENT_ID')+'？')){
					return;
				}
			}
			var reqMap = actions.getReqMap();
			
			for(var key in reqMap){
				if(oldQueryData[key]!=reqMap[key]){
					alert('查詢條件與原查詢條件不符，請重新查詢後再執行新增');
					return;
				}
			}		
			
			var newMap = actions.getCBlock();			
			
			ajaxRequest.post( 'insertCheck', {B300Map : Object.toJSON(newMap)}, 
				function(resp){
					var msg = resp.msg;
					if(msg){
						if(!confirm(msg)){
							return;
						}
						buttons.doInsert(newMap, reqMap);
					}
					buttons.doInsert(newMap, reqMap);
				}
			);				
		},
		<%--新增--%>
		doInsert: function(newMap, reqMap){
			ajaxRequest.post( 'insert', {B300Map : Object.toJSON(newMap), reqMap: Object.toJSON(reqMap)}, 
				function(resp){
					actions.showData(resp);
				}
			);		
		},
		<%--修改--%>
		doUpdate : function(){
		
			if(grid.getCheckedRecord().length===0){
				alert('請先選取資料');
				return;
			}
			if($('APPLY_ID').innerHTML == ''){
				alert('請先查詢再執行修改作業');
				return;
			}
			validateInsertAndUpdate('update');
			
			if(!validInsert.validate()){					
				return;			
			}
			if(!$('AGENT_IS_CHANGE').checked && $F('NEW_AGENT_ID')){
				alert('若輸入新火險經手人ID，請勾選是否變更');
				return;
			}
			if($('AGENT_IS_CHANGE').checked){
				if(!confirm('確定要變更火險經手人為'+$F('NEW_AGENT_ID')+'？')){
					return;
				}
			}
			
			var reqMap = actions.getReqMap();
			
			for(var key in reqMap){
				if(oldQueryData[key]!=reqMap[key]){
					alert('查詢條件與原查詢條件不符，請重新查詢後再執行修改');
					return;
				}
			}
			
			var B300Map = actions.getCBlock();			
			
			ajaxRequest.post( 'update', {B300Map : Object.toJSON(B300Map), reqMap: Object.toJSON(reqMap)},
				function(resp){
					actions.showData(resp);
				}
			);				
		},
		<%--刪除--%>
		doDelete : function(){
		
			var chkList = grid.getCheckedRecord();
			if(chkList.length===0){
				alert('請先選取資料');
				return;
			}
			
			if($('APPLY_ID').innerHTML == ''){
				alert('請先查詢再執行刪除作業');
				return;
			}
			
			var reqMap = actions.getReqMap();
			
			for(var key in reqMap){
				if(oldQueryData[key]!=reqMap[key]){
					alert('查詢條件與原查詢條件不符，請重新查詢後再執行刪除');
					return;
				}
			}
			
			if(!confirm('確定要刪除該筆資料?')){
				return;
			}
			
			ajaxRequest.post( 'delete', {B300Map: Object.toJSON(chkList[0]), reqMap: Object.toJSON(reqMap)},
				function(resp){	
					actions.showData(resp);
				}
			);				
		},
		<%--確認--%>
		doConfirm : function(){
		
			var chkList = grid.getCheckedRecord();
			if(chkList.length===0){
				alert('請先選取資料');
				return;
			}
			var chkMap = chkList[0];
			var EFFECT_DATE = chkMap['EFFECT_DATE'];
			if(!checkEFFECT_DATE(toROC(EFFECT_DATE))){
				alert('批單生效日必須大於等於前一日');
				return;
			}
			if(!checkEFFECT_DATE2(toROC(EFFECT_DATE))){
				alert('批單生效日需介於火險起日~火險迄日');
				return;
			}
			
			var currentHHMM = getTime().substring(0,4);
			var diffday = diffDay(getY2KToday(), EFFECT_DATE);
			if(parseInt(currentHHMM) > 1330 && (diffday==0 || diffday == -1)){
				if(!confirm('生效日將自動變更為 ${lastDate}，是否同意？')){
					return;
				}
			}
			var reqMap = actions.getReqMap();
			for(var key in reqMap){
				if(oldQueryData[key]!=reqMap[key]){
					alert('查詢條件與原查詢條件不符，請重新查詢後再執行確認');
					return;
				}
			}
			
			ajaxRequest.post( 'confirm', {B300Map: Object.toJSON(chkMap), reqMap: Object.toJSON(reqMap)},
				function(resp){	
					actions.showData(resp);
				}
			);				
		},
		<%--列印--%>
		doPrint: function(){
			var chkList = grid.getCheckedRecord();
			if(chkList.length===0){
				alert('請先選取資料');
				return;
			}
			
			var reqMap = actions.getReqMap();
			
			for(var key in reqMap){
				if(oldQueryData[key]!=reqMap[key]){
					alert('查詢條件與原查詢條件不符，請重新查詢後再執行列印');
					return;
				}
			}
			ajaxRequest.post( 'print', {inputMap: Object.toJSON(chkList[0])},
				function(resp){	
					RPTUtil.executePrintByResponse(resp, true);	
				}
			);
		},
		<%--資格查詢--%>
		doQualificationQuery: function(){
			var AGENT_ID = $('AGENT_ID').value ||'';
			if(!AGENT_ID){
				alert('無經手人員ID，無法作業');
				return;
			}
			<%-- [20240613] 因span改成input，$('AGENT_NAME').innerHTML改為$F('AGENT_NAME') --%>
			ajaxRequest.post( 'qualificationQuery', {AGENT_ID: AGENT_ID, AGENT_NAME: $F('AGENT_NAME')},
				function(resp){
					var msg = resp.MSG||'';
					if(msg){
						alert(msg);					
					}
				}
			);
		}
	}
	
	
	return{
		initApp:function(){	
		PageUI.createPageWithAllBodySubElement( "DSB30900" , "火險作業", "火險加保資料輸入" );
			
			initValidation();
			var df = new SimpleDateFormat('yyy/MM/dd', SimpleDateFormat.TW);
			grid = new TableUI({	
					table :$('grid'),
					pageSize : 10,
					allSortable: true,
					split:['LOAN_ID'],
					autoCheckBox:{text:'選取',type:'radio',
						action: function(checkbox , boxStatus , records) {
							validQuery.reset();								
							validInsert.reset();
							$('btn_insert').disable();
							actions.showBlockC(records[0]);
						}
					},
					<%-- [20240613] 難字調整 --%>
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column: [
						<%-- [20240613] 難字調整：借款人 --%>
						{header:'借款人', key:'BORROW_NAME', attrs:{rowSpan:2, style:"font-family:'EUDC'"}},
						{header:'受理編號', key:'APPLY_ID'},
						<%-- [20240613] 難字調整：經手人 --%>
						{header:'經手人', key:'AGENT_NAME', attrs:{rowSpan:2, style:"font-family:'EUDC'"}, render:function(rec, val){
							return '<div>'+(val||'')+'</div><div>'+(rec.AGENT_ID||'')+'</div>';
						}},
						{header:'火險起日', key:'FIREINSU_BEGDT', render:function(rec,val){
							return  val?df.format(val):'';
						}},
						{header:'加保保額（萬元）', key:'ADD_AMT', attrs:{rowSpan:2}, render:function(rec,val){
							return  '<div align="right">'+CSRUtil.$fmt(val, '#,###.#####')+'</div>';
						}},
						{header:'加保保費', key:'ADD_PAYMENT', attrs:{rowSpan:2}, render:function(rec,val){
							return  '<div align="right">'+CSRUtil.$fmt(val, '#,###.#####')+'</div>';
						}},
						{header:'加批生效日', key:'EFFECT_DATE', attrs:{rowSpan:2}, render:function(rec,val){
							return  val?df.format(val):'';
						}},
						{header:'火險保額（萬元）', key:'FINAL_AMT', render:function(rec,val){
							return  '<div align="right">'+CSRUtil.$fmt(val, '#,###.#####')+'</div>';
						}},
						{header:'出單狀況', key:'ISSUE_CODE_NM', attrs:{rowSpan:2}},
						{header:'貸款帳號', key:'LOAN_ID'},
						{header:'火險迄日', key:'FIREINSU_ENDDT', render:function(rec,val){
							return  val?df.format(val):'';
						}},
						{header:'火險保費（元）', key:'FINAL_PAYMENT', render:function(rec,val){
							return  '<div align="right">'+CSRUtil.$fmt(val, '#,###.#####')+'</div>';
						}}
					]
				}
			);
			
			autoCreateDate();
			autoFormatToDate();		
			autoFormatToNumber();	
			buttonAuth();
			
			<%--查詢--%>
			$('btn_query').observe('click', buttons.doQuery);
			<%--新增--%>
			$('btn_insert').observe('click', buttons.doInsertCheck);
			<%--修改--%>
			$('btn_update').observe('click', buttons.doUpdate);
			<%--刪除--%>
			$('btn_delete').observe('click', buttons.doDelete);
			<%--確認--%>
			$('btn_confirm').observe('click', buttons.doConfirm);
			<%--資格查詢--%>
			$('btn_qualify').observe('click', buttons.doQualificationQuery);
			<%--列印--%>
			$('btn_print').observe('click', buttons.doPrint);
			
			<%--保單號碼連動--%>
			$('FIREINSU_POLNO').observe('change', actions.changeFIREINSU_POLNO);
			<%--增貸件受理編號連動--%>
			$('ADD_APPLY_ID').observe('change', actions.changeADD_APPLY_ID);
			
			
			<%--轉大寫--%>
			$('APPLY_ID_INPUT').observe('blur', function(event){			
				event.target.value = event.target.value.toUpperCase();
			});
			$('LOAN_ID_INPUT').observe('blur', function(event){			
				event.target.value = event.target.value.toUpperCase();
			});
			$('NEW_AGENT_ID').observe('blur', function(event){			
				event.target.value = event.target.value.toUpperCase();
			});
			$('ADD_APPLY_ID').observe('blur', function(event){
				event.target.value = event.target.value.toUpperCase();
			});
			
			PageUI.resize();
			displayMessage();			
			
		}
	};
}

</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="15%">受理編號</td>
				<td class="tbYellow2" width="30%">
					<input id="APPLY_ID_INPUT" class="textBox2" maxlength="11" size="15"/>
				</td>
				<td class="tbYellow" width="15%">貸款帳號</td>
				<td class="tbYellow2" width="30%">
					<input id="LOAN_ID_INPUT" class="textBox2" maxlength="10" size="15"/>
				</td>
				<td class="tbYellow2" width="10%" align="center">
					<input type="button" class="button" id="btn_query" value="查詢"/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow1" colspan="5" align="center"> 
					<input type="button" class="button" id="btn_insert" value="新增"/>
					<input type="button" class="button" id="btn_update" value="修改"/>
					<input type="button" class="button" id="btn_delete" value="刪除"/>
					<input type="button" class="button" id="btn_confirm" value="確認"/>
					<input type="button" class="button" id="btn_print" value="列印"/>
				</td>
			</tr>
		</table>
		<table id="grid"></table>
		<table id="tableC" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<input id="BORROW_ID" type="hidden"/>
			<input id="AGENT_ID" type="hidden"/>
			<input id="SEQ_NO" type="hidden"/>
			<tr class="tbYellow" >
				<td class="tbYellow" width="25%">受理編號</td>
				<td class="tbYellow2" width="25%">
					<span id="APPLY_ID"></span>
				</td>
				<td class="tbYellow" width="25%">貸款帳號</td>
				<td class="tbYellow2" width="25%">
					<span id="LOAN_ID"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">保單號碼</td>
				<td class="tbYellow2">
					<select id="FIREINSU_POLNO">
						<option value="">請選擇</option>
					</select>
				</td>
				<td class="tbYellow">增貸件受理編號</td>
				<td class="tbYellow2">
					<input id="ADD_APPLY_ID" class="textBox2" maxlength="11" size="15"/>
				</td>
			</tr>			
			<tr>
				<td class="tbYellow">批單號碼</td>
				<td class="tbYellow2" colspan="3">
					<span id="ADD_POLNO"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">借款人</td>
				<td class="tbYellow2">
					<%-- [20240613] 難字調整：借款人，將span改成input --%>
					<input type="text" id="BORROW_NAME" class="textDisable" alt="ch" readonly>
				</td>
				<td class="tbYellow">保險標的</td>
				<td class="tbYellow2">
					<input type="text" id="GAGE_ADDR" class="textDisable" alt="ch" readonly>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">批單生效日</td>
				<td class="tbYellow2">
					<input id="EFFECT_DATE" name="EFFECT_DATE" datatype="ROCdate" type="text" class="textBox validate-ROCDate" size="8" maxlength="7"/>
				</td>
				<td class="tbYellow">出單狀況</td>
				<td class="tbYellow2">
					<span id="ISSUE_CODE_NM"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">火險加保保額</td>
				<td class="tbYellow2">
					<input id="ADD_AMT" name="ADD_AMT" type="text" datatype="number" maxlength="4" size="5"/>萬元
				</td>
				<td class="tbYellow">火險總保額</td>
				<td class="tbYellow2">
					<span id="FINAL_AMT" datatype="number"></span>萬元
				</td>
			</tr>
			<tr>
				<td class="tbYellow">火險加保保費</td>
				<td class="tbYellow2">
					<span id="ADD_PAYMENT" datatype="number"></span>元
				</td>
				<td class="tbYellow">火險總保費</td>
				<td class="tbYellow2">
					<span id="FINAL_PAYMENT" datatype="number"></span>元
				</td>
			</tr>
			<tr>
				<td class="tbYellow">是否贈送火險</td>
				<td class="tbYellow2">
					<select id="INSUFREE_CODE" name="INSUFREE_CODE">
					<c:forEach var="map" items="${INSUFREE_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
					</select>
				</td>
				<td class="tbYellow">經手人員</td>
				<td class="tbYellow2">
					<%-- [20240613] 難字調整：經手人員，將span改成input --%>
					<input type="text" id="AGENT_NAME" class="textDisable" alt="ch" readonly>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">火險起日</td>
				<td class="tbYellow2">
					<span id="FIREINSU_BEGDT" datatype="ROCdate" ></span>
				</td>
				<td class="tbYellow">火險迄日</td>
				<td class="tbYellow2">
					<span id="FIREINSU_ENDDT" datatype="ROCdate" ></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">變更火險經手人</td>
				<td class="tbYellow2">
					<input id="btn_qualify" type="button" class="button" value="資格查詢"/>
					<input id="AGENT_IS_CHANGE" type="checkbox"/> 是否變更？
				</td>
				<td class="tbYellow">新火險經手人ID</td>
				<td class="tbYellow2">
					<input id="NEW_AGENT_ID" name="NEW_AGENT_ID" type="text" maxLength="10" size="11"/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">火險資料輸入人員</td>
				<td class="tbYellow2">
					<%-- [20240613] 難字調整：火險資料輸入人員，將span改成input --%>
					<input type="text" id="INPUT_NAME" class="textDisable" alt="ch" readonly>
				</td>
				<td class="tbYellow">火險資料輸入日期</td>
				<td class="tbYellow2">
					<span id="INPUT_DATE" datatype="ROCdate" ></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">火險出單確認人員</td>
				<td class="tbYellow2">
					<%-- [20240613] 難字調整：火險出單確認人員，將span改成input --%>
					<input type="text" id="ISSUE_NAME" class="textDisable" alt="ch" readonly>
				</td>
				<td class="tbYellow">火險出單確認日期</td>
				<td class="tbYellow2">
					<span id="ISSUE_DATE" datatype="ROCdate" ></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">火險歸檔確認人員</td>
				<td class="tbYellow2">
					<%-- [20240613] 難字調整：火險歸檔確認人員，將span改成input --%>
					<input type="text" id="FILE_NAME" class="textDisable" alt="ch" readonly>
				</td>
				<td class="tbYellow">火險歸檔確認日期</td>
				<td class="tbYellow2">
					<span id="FILE_DATE" datatype="ROCdate" ></span>
				</td>
			</tr>
		</table>
	</form>
</body>
</html>