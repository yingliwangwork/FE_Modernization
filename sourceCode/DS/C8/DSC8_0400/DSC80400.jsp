<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!--
程式：DSC80400.jsp
作者：溫子?
功能：貸款年期變更
完成：2013/8//28

[20230317] 修改程式  楊青峰
難字調整
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<%-- [20230317] --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
	         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	      font-weight: normal;
	      font-style: normal
	}
</style>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<!--alert訊息-->

<script type="text/javascript">
//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC80400().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC80400(){
var rtnMap={};
	// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0004 : 'BTN_UPDATE',		<%--變更--%>		
				B0005 : 'BTN_DELETE',		<%--刪除--%>
				B0070 : 'BTN_CONFIRM'		<%--覆核--%>		
				
			};
			<dz:grantButtons FUNC_ID='DSC80400'/>
		};
	function initValidation(){
			//查詢用檢核
				
			Validation.addAllThese([
				[ 'validateLOAN_ID_10',  '貸款帳號長度不正確 需為10碼',
					function(v){				
						return (v.length != 10) ? false : true ;
					}
				],
				[ 'check_NEW_SPR_PERIOD',  '定期期數請輸入大於零之整數',
					function(v){	
						if(!v||v==0){
							return false;
						}
						return Validation.get('IsEmpty').test(v) || /^\d+$/.test(v);
					}
				],
				[ 'check_NEW_FIX_PERIOD',  '分期期數請輸入大於零之整數',
					function(v){	
						if(!v||v==0){
							return false;
						}
						return Validation.get('IsEmpty').test(v) || /^\d+$/.test(v);
					}
				],
				[ 'check_NEW_FIX_SPR_PERIOD',  '請輸入分期或定期期數',
					function(v){
						var NEW_FIX_PERIOD = $F('NEW_FIX_PERIOD');
						var NEW_SPR_PERIOD = $F('NEW_SPR_PERIOD');
						if((!NEW_FIX_PERIOD||NEW_FIX_PERIOD==0) && (!NEW_SPR_PERIOD||NEW_SPR_PERIOD==0)){
							return false;
						}
						return Validation.get('IsEmpty').test(v) || /^\d+$/.test(v);
					}
				]
				
			]);
			valid1 = new Validation("table", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid1.define( "required" , { id: "LOAN_ID_Q" , errMsg:"貸款帳號不可空白!!" } );
			valid1.define( "validateLOAN_ID_10" , { id: "LOAN_ID_Q"});
			
			valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid2.define( "check_NEW_SPR_PERIOD" , { id: "NEW_SPR_PERIOD", errMsg:"定期期數請輸入大於零之整數"});
			valid2.define( "validate-selection" , { id: "NEW_RETURN_TYPE", errMsg:"請選擇還款方式" });
			
			valid3 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid3.define( "check_NEW_FIX_PERIOD" , { id: "NEW_FIX_PERIOD" , errMsg:"分期期數請輸入大於零之整數" } );	
			valid3.define( "validate-selection" , { id: "NEW_RETURN_TYPE", errMsg:"請選擇還款方式!!" });
			
			valid4 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid4.define( "check_NEW_FIX_SPR_PERIOD" , { id: "NEW_FIX_PERIOD" , errMsg:"請輸入分期或定期期數" } );
			valid4.define( "check_NEW_FIX_SPR_PERIOD" , { id: "NEW_SPR_PERIOD", errMsg:"請輸入分期或定期期數"});
			valid4.define( "validate-selection" , { id: "NEW_RETURN_TYPE", errMsg:"請選擇還款方式!!" });
			valid5 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid5.define( "validate-selection" , { id: "NEW_RETURN_TYPE", errMsg:"請選擇還款方式!!" });
	}
// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC8_0400/' + actionName,
			{  
				parameters: params, 
				onSuccess: function(response)
				{
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){
						if(successAction){
							successAction(resp);
						}
					}else{
						if(errorAction){
							errorAction(resp);
						}
					}
				}
			});
		};
var buttons = {

	doQuery : function(){
		if(!valid1.validate()){ 
			return; 
		}//A671125099
		// 頁面傳入參數
				ajaxPost( 'query' , { 'LOAN_ID_Q' : $F('LOAN_ID_Q') },
					function(resp){
						rtnMap = resp.rtnMap;
						$w('LOAN_ID BORROW_NAME LOAN_KIND LOAN_PERIOD '
						+ 'GROUP_NOTE GETINT_DEPT '
						+ 'RETURN_TYPE GETINT_CODE '
						+ 'SPR_PERIOD LOAN_KIND_NM TERM_TYPE IS_EXTRACT APPLY_DATE CHG_KIND SEQ_NO').each(
							function(id) {
								$(id).value = rtnMap[id] || '';						
							} 
						);
						$w('LOAN_DATE NEXT_PAYDT END_DATE').each(function(id){
							$(id).value=Date.toROC(rtnMap[id] || '');
						})
						$w('LOAN_AMT SPR_AMT FIX_AMT LAST_BALANCE').each(function(id){
							$(id).value=MoneyFormat(rtnMap[id])||'';
						})
						
						$w('FIX_PERIOD PAID_TIMES VALID_TIMES PREPAY_TIMES' ).each(
							function(id) {
								$(id).value = rtnMap[id] || '0';						
							})					
						if("Y" == rtnMap['UNCONFIRM']){						
							$w('NEW_RETURN_TYPE NEW_TERM_TYPE' ).each(
								function(id) {
									$(id).value = rtnMap[id] || '';						
								})												
							
							$w('NEW_SPR_PERIOD NEW_FIX_PERIOD' ).each(
								function(id) {
									$(id).value = rtnMap[id] || '0';						
								})
							$('EXPENSE_AMT').value = MoneyFormat(rtnMap['EXPENSE_AMT'])||'';
							$('NEW_RETURN_TYPE').disabled=true;
							$('NEW_SPR_PERIOD').disabled=true;
							$('NEW_FIX_PERIOD').disabled=true;
							$('EXPENSE_AMT').disabled=true;
						} else {
							$('NEW_RETURN_TYPE').value = '';							
							$w('NEW_SPR_PERIOD NEW_FIX_PERIOD EXPENSE_AMT').each(
								function(id) {
									$(id).value = '0';						
								}
							);
							$('NEW_RETURN_TYPE').disabled=false;
							$('NEW_SPR_PERIOD').disabled=false;
							$('NEW_FIX_PERIOD').disabled=false;
							$('EXPENSE_AMT').disabled=false;
						}
						$('LOAN_ID_OLD').value = rtnMap['LOAN_ID'] || '';
					},function(resp){
						$w('LOAN_ID BORROW_NAME LOAN_KIND LOAN_PERIOD '
						+ 'GROUP_NOTE GETINT_DEPT RETURN_TYPE GETINT_CODE '
						+ 'SPR_PERIOD LOAN_KIND_NM TERM_TYPE '
						+ 'LOAN_DATE NEXT_PAYDT END_DATE '
						+ 'LOAN_AMT SPR_AMT FIX_AMT LAST_BALANCE '
						+ 'FIX_PERIOD PAID_TIMES VALID_TIMES PREPAY_TIMES '
						+ 'NEW_RETURN_TYPE APPLY_DATE CHG_KIND SEQ_NO').each(
							function(id) {
								$(id).value = '';						
							}
						);
						
						$w('NEW_SPR_PERIOD NEW_FIX_PERIOD EXPENSE_AMT').each(
							function(id) {
								$(id).value = '0';						
							}
						);
						$('NEW_RETURN_TYPE').disabled=false;
						$('NEW_SPR_PERIOD').disabled=false;
						$('NEW_FIX_PERIOD').disabled=false;
						$('EXPENSE_AMT').disabled=false;
						$('LOAN_ID_OLD').value = '';
					}
				);
	}
	,doUpdate : function(){
		// 檢核	
		valid2.reset();
		valid3.reset();
		valid4.reset();
		valid5.reset();
		if(!$F('LOAN_ID_OLD')){
			alert("請先查詢後再變更!");
			return;
		}
		if($F('LOAN_ID_Q') != $F('LOAN_ID_OLD')){
			alert("欲變更的"+$F('LOAN_ID_Q')+"與原先查詢的"+$F('LOAN_ID_OLD')+"不同，無法作業!");
			return;
		}
		var LOAN_ID = $F('LOAN_ID_Q');
		var postFix=LOAN_ID.substr(LOAN_ID.length-1);
		if ("X" == postFix) {
			alert("理財型帳號不得變更年期!! ");
			return;
		}
		if(!valid5.validate()){ 
			return; 
		}
		if($F('NEW_SPR_PERIOD')&&$F('NEW_SPR_PERIOD')<=0&&$F('NEW_RETURN_TYPE')==2){
			alert("已選定期+分期，分期期數不得為0!! ");
			return;
		}
		if($F('NEW_FIX_PERIOD')&&$F('NEW_FIX_PERIOD')<=0&&$F('NEW_RETURN_TYPE')==2){
			alert("已選定期+分期，定期期數不得為0!! ");
			return;
		}
		if($F('NEW_SPR_PERIOD')&&$F('NEW_SPR_PERIOD')!=0&&$F('NEW_RETURN_TYPE')==3){
			alert("已選分期，還款方式不可為定期!! ");
			$('NEW_SPR_PERIOD').value=0
			return;
		}
		if($F('NEW_FIX_PERIOD')&&$F('NEW_FIX_PERIOD')!=0&&$F('NEW_RETURN_TYPE')==1){
			alert("已選定期，還款方式不可為分期!!");
			$('NEW_FIX_PERIOD').value=0
			return;
		}
		
		//判斷手續費用
		if($('EXPENSE_AMT').value < 0){
			alert('注意!手續費用低於0!');
			return;
		}
		
		
		if($F('NEW_RETURN_TYPE')==1){
			if(!valid2.validate()){ 
				return; 
			}
		}
		if($F('NEW_RETURN_TYPE')==3){
			if(!valid3.validate()){ 
				return; 
			}
		}
		if($F('NEW_RETURN_TYPE')==2||$F('NEW_RETURN_TYPE')==4){
			if(!valid4.validate()){ 
				return; 
			}
		}
		//20160428 資產管理一科調整訊息內容  且  不檢核手續費用,一律跳出訊息
		//if ($F('EXPENSE_AMT') > 0 && $F('IS_EXTRACT') == 'Y') {
		if ($F('IS_EXTRACT') == 'Y') {
			//alert('本次期款已抽件，轉帳扣款中，若輸入費用，可能造成扣款成功卻無法入帳，僅能掛電腦暫收，實際上等於未繳，易造成糾紛及後續帳務處理之困難。除要立即開單繳費者外，請於轉帳扣款作業完畢後(確定轉帳成功或不成功後)，再行輸入費用')
			//if(!confirm('本次期款已抽件，轉帳扣款中，若輸入費用，可能造成扣款成功卻無法入帳，僅能掛電腦暫收，實際上等於未繳，易造成糾紛及後續帳務處理之困難。除要立即開單繳費者外，請於轉帳扣款作業完畢後(確定轉帳成功或不成功後)，再行輸入費用\n是否確定輸入費用？')) {
			if(!confirm('本次期款已抽件，轉帳扣款中，若變更輸入，可能造成扣款成功卻無法入帳，另易造成糾紛及後續帳務處理之困難。請確認是否輸入？')) {
				return ;
			}
		}
		rtnMap['NEW_RETURN_TYPE']=$('NEW_RETURN_TYPE').value;
		rtnMap['NEW_SPR_PERIOD']=$('NEW_SPR_PERIOD').value;
		rtnMap['NEW_FIX_PERIOD']=$('NEW_FIX_PERIOD').value;
		rtnMap['NEW_TERM_TYPE']=$('NEW_TERM_TYPE').value;
		rtnMap['EXPENSE_AMT']=$F('EXPENSE_AMT');
		rtnMap['LOAN_AMT']=$F('LOAN_AMT');
		rtnMap['SPR_AMT']=$F('SPR_AMT');
		rtnMap['FIX_AMT']=$F('FIX_AMT');
		rtnMap['LAST_BALANCE']=$F('LAST_BALANCE');
		rtnMap['APPLY_DATE']=$F('APPLY_DATE');
		rtnMap['CHG_KIND']=$F('CHG_KIND');
		rtnMap['SEQ_NO']=$F('SEQ_NO');
		
		ajaxPost( 'update' , { 'info' : Object.toJSON(rtnMap), 'LOAN_ID' : $F('LOAN_ID_Q') },
				function(resp){					
					var rtnMap = resp.rtnMap;
						$w('LOAN_ID BORROW_NAME LOAN_KIND LOAN_PERIOD '
						+ 'GROUP_NOTE GETINT_DEPT RETURN_TYPE GETINT_CODE '
						+'SPR_PERIOD LOAN_KIND_NM TERM_TYPE EXPENSE_AMT APPLY_DATE CHG_KIND SEQ_NO').each(
							function(id) {
								$(id).value = rtnMap[id] || '';						
							}
						);
						$w('LOAN_DATE NEXT_PAYDT END_DATE').each(function(id){
							$(id).value=Date.toROC(rtnMap[id] || '');
						})
						$w('LOAN_AMT SPR_AMT FIX_AMT LAST_BALANCE').each(function(id){
							$(id).value=MoneyFormat(rtnMap[id])||'';
						})
						$('LOAN_ID_OLD').value = rtnMap['LOAN_ID'] || '';
						$w('FIX_PERIOD PAID_TIMES VALID_TIMES PREPAY_TIMES' ).each(
							function(id) {
								$(id).value = rtnMap[id] || '0';						
						})	
						$w('NEW_RETURN_TYPE NEW_TERM_TYPE' ).each(
							function(id) {
								$(id).value = rtnMap[id] || '';						
						})												
							
						$w('NEW_SPR_PERIOD NEW_FIX_PERIOD' ).each(
							function(id) {
								$(id).value = rtnMap[id] || '0';						
						})
						$('EXPENSE_AMT').value = MoneyFormat(rtnMap['EXPENSE_AMT'])||'';
						$('NEW_RETURN_TYPE').disabled=true;
						$('NEW_SPR_PERIOD').disabled=true;
						$('NEW_FIX_PERIOD').disabled=true;
						$('EXPENSE_AMT').disabled=true;					
				
				}
			);	
	}
	,doDelete : function(){
		// 檢核	
		valid2.reset();
		valid3.reset();
		valid4.reset();
		valid5.reset();
		if(!$F('LOAN_ID_OLD')){
			alert("請先查詢後再刪除!");
			return;
		}
		if($F('LOAN_ID_Q') != $F('LOAN_ID_OLD')){
			alert("欲刪除的"+$F('LOAN_ID_Q')+"與原先查詢的"+$F('LOAN_ID_OLD')+"不同，無法作業!");
			return;
		}
		if(!valid5.validate()){ 
			return; 
		}
				
		rtnMap['NEW_RETURN_TYPE']=$('NEW_RETURN_TYPE').value;
		rtnMap['NEW_SPR_PERIOD']=$('NEW_SPR_PERIOD').value;
		rtnMap['NEW_FIX_PERIOD']=$('NEW_FIX_PERIOD').value;
		rtnMap['NEW_TERM_TYPE']=$('NEW_TERM_TYPE').value;
		rtnMap['EXPENSE_AMT']=$F('EXPENSE_AMT');
		rtnMap['LOAN_AMT']=$F('LOAN_AMT');
		rtnMap['SPR_AMT']=$F('SPR_AMT');
		rtnMap['FIX_AMT']=$F('FIX_AMT');
		rtnMap['LAST_BALANCE']=$F('LAST_BALANCE');
		rtnMap['APPLY_DATE']=$F('APPLY_DATE');
		rtnMap['CHG_KIND']=$F('CHG_KIND');
		rtnMap['SEQ_NO']=$F('SEQ_NO');
		
		ajaxPost( 'delete' , { 'info' : Object.toJSON(rtnMap), 'LOAN_ID' : $F('LOAN_ID_Q') },
				function(resp){					
					var rtnMap = resp.rtnMap;
						$w('LOAN_ID BORROW_NAME LOAN_KIND LOAN_PERIOD '
						+ 'GROUP_NOTE GETINT_DEPT RETURN_TYPE GETINT_CODE '
						+'SPR_PERIOD LOAN_KIND_NM TERM_TYPE EXPENSE_AMT APPLY_DATE CHG_KIND SEQ_NO').each(
							function(id) {
								$(id).value = rtnMap[id] || '';						
							}
						);
						$w('LOAN_DATE NEXT_PAYDT END_DATE').each(function(id){
							$(id).value=Date.toROC(rtnMap[id] || '');
						})
						$w('LOAN_AMT SPR_AMT FIX_AMT LAST_BALANCE').each(function(id){
							$(id).value=MoneyFormat(rtnMap[id])||'';
						})
						$('LOAN_ID_OLD').value = rtnMap['LOAN_ID'] || '';
						$w('FIX_PERIOD PAID_TIMES VALID_TIMES PREPAY_TIMES' ).each(
						function(id) {
								$(id).value = rtnMap[id] || '0';						
						})
						$('NEW_RETURN_TYPE').value = '';							
						$w('NEW_SPR_PERIOD NEW_FIX_PERIOD EXPENSE_AMT').each(
							function(id) {
								$(id).value = '0';						
							}
						);
						$('NEW_RETURN_TYPE').disabled=false;
						$('NEW_SPR_PERIOD').disabled=false;
						$('NEW_FIX_PERIOD').disabled=false;
						$('EXPENSE_AMT').disabled=false;						
					
				}
			);
	}		
	,doConfirm : function(){
		// 檢核	
		valid2.reset();
		valid3.reset();
		valid4.reset();
		valid5.reset();
		if(!$F('LOAN_ID_OLD')){
			alert("請先查詢後再覆核!");
			return;
		}
		if($F('LOAN_ID_Q') != $F('LOAN_ID_OLD')){
			alert("欲覆核的"+$F('LOAN_ID_Q')+"與原先查詢的"+$F('LOAN_ID_OLD')+"不同，無法作業!");
			return;
		}
		if(!valid5.validate()){ 
			return; 
		}
				
		rtnMap['NEW_RETURN_TYPE']=$('NEW_RETURN_TYPE').value;
		rtnMap['NEW_SPR_PERIOD']=$('NEW_SPR_PERIOD').value;
		rtnMap['NEW_FIX_PERIOD']=$('NEW_FIX_PERIOD').value;
		rtnMap['NEW_TERM_TYPE']=$('NEW_TERM_TYPE').value;
		rtnMap['EXPENSE_AMT']=$F('EXPENSE_AMT');
		rtnMap['LOAN_AMT']=$F('LOAN_AMT');
		rtnMap['SPR_AMT']=$F('SPR_AMT');
		rtnMap['FIX_AMT']=$F('FIX_AMT');
		rtnMap['LAST_BALANCE']=$F('LAST_BALANCE');
		rtnMap['APPLY_DATE']=$F('APPLY_DATE');
		rtnMap['CHG_KIND']=$F('CHG_KIND');
		rtnMap['SEQ_NO']=$F('SEQ_NO');

		ajaxPost( 'confirm' , { 'info' : Object.toJSON(rtnMap), 'LOAN_ID' : $F('LOAN_ID_Q') },
				function(resp){
					
					var rtnMap = resp.rtnMap;
						$w('LOAN_ID BORROW_NAME LOAN_KIND LOAN_PERIOD '
						+ 'GROUP_NOTE GETINT_DEPT RETURN_TYPE GETINT_CODE '
						+'SPR_PERIOD LOAN_KIND_NM TERM_TYPE EXPENSE_AMT APPLY_DATE CHG_KIND SEQ_NO').each(
							function(id) {
								$(id).value = rtnMap[id] || '';						
							}
						);
						$w('LOAN_DATE NEXT_PAYDT END_DATE').each(function(id){
							$(id).value=Date.toROC(rtnMap[id] || '');
						})
						$w('LOAN_AMT SPR_AMT FIX_AMT LAST_BALANCE').each(function(id){
							$(id).value=MoneyFormat(rtnMap[id])||'';
						})
						$('LOAN_ID_OLD').value = rtnMap['LOAN_ID'] || '';
						$w('FIX_PERIOD PAID_TIMES VALID_TIMES PREPAY_TIMES' ).each(
							function(id) {
								$(id).value = rtnMap[id] || '0';						
						})						
						$('NEW_RETURN_TYPE').value = '';							
						$w('NEW_SPR_PERIOD NEW_FIX_PERIOD EXPENSE_AMT').each(
							function(id) {
								$(id).value = '0';						
							}
						);
						$('NEW_RETURN_TYPE').disabled=false;
						$('NEW_SPR_PERIOD').disabled=false;
						$('NEW_FIX_PERIOD').disabled=false;
						$('EXPENSE_AMT').disabled=false;		
				}
			);				
	}
}
// 產生查詢回傳資料
	var reqMap = function(){
		
		var reqMap = {};

		$$('#form input[type!="button"]', '#form select').each(
			function(text){
				reqMap[text.id] = text.value;
			}
		);
		
		return reqMap;		
	};	
return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC80400', '變更作業', '貸款年期變更');
				
				
				autoFormatToNumber();
				// 查詢
				$('BTN_QUERY').observe('click', buttons.doQuery);
				
				// 變更
				$('BTN_UPDATE').observe('click', buttons.doUpdate);
				
				// 刪除
				$('BTN_DELETE').observe('click', buttons.doDelete);
				
				// 覆核
				$('BTN_CONFIRM').observe('click', buttons.doConfirm);
				
				buttonAuth();
				initValidation();
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
				
			}
	}
}
</script>
</head>
<body>
<form id="form" name="form"  style="PADDING: 0px; MARGIN: 0px;">
<input id="IS_EXTRACT" type="hidden"/>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table">
	<tr>
		<td class="tbYellow" width="10%">貸款帳號</td>
			<td class="tbYellow2" width="15%">
			<input id="LOAN_ID_Q" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="LOAN_ID_OLD" type="hidden">
		</td>
		<td class="tbYellow2" width="30%" colspan="6">
			<input id="BTN_QUERY" type="button" value="查詢" class="button"> 
			<input id="BTN_UPDATE" type="button" value="變更" class="button">
			<input id="BTN_DELETE" type="button" value="刪除" class="button">
			<input id="BTN_CONFIRM" type="button" value="覆核" class="button"> 
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%">借款人姓名</td>
		<td class="tbYellow2" colspan="7">
			<input id="BORROW_NAME" type="text" class="textBox2" alt="ch" disabled/> <%-- [20230317] --%>
			<input id="SPEC_CHECK_990625" type="hidden">
			<input id="IS_MANSION" type="hidden">
			<input id="LOAN_ID" type="hidden">
			<input id="GROUP_NOTE" type="hidden">
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >貸款種類</td>
		<td class="tbYellow2" colspan="2">
			<input id="LOAN_KIND_NM" type="text" class="textBox2"  size='30' disabled/>
			<input id="LOAN_KIND" type="hidden">
		</td>
		<td class="tbYellow" >貸款期數</td>
		<td class="tbYellow2" colspan="4">
			<input id="LOAN_PERIOD" type="text" class="textBox2"  disabled/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">原貸款金額</td>
		<td class="tbYellow2" colspan="2">
			<input id="LOAN_AMT" type="text" class="textBox2" disabled/>
		</td>
		<td class="tbYellow">分期╱定期期數</td>
		<td class="tbYellow2" colspan="4">
			<input id="SPR_PERIOD" type="text" class="textBox2"  size='12' disabled/>╱
			<input id="FIX_PERIOD" type="text" class="textBox2" size='12' disabled/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">分期本金餘額</td>
		<td class="tbYellow2" colspan="2"> 
			<input id="SPR_AMT" type="text" class="textBox2" disabled/>
		</td>
		<td class="tbYellow">已繳╱有效期數</td>
		<td class="tbYellow2" colspan="4">
			<input id="PAID_TIMES" type="text" class="textBox2" size='12' disabled/>╱
			<input id="VALID_TIMES" type="text" class="textBox2" size='12' disabled/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">定期本金餘額</td>
		<td class="tbYellow2" colspan="2">
			<input id="FIX_AMT" type="text" class="textBox2" disabled/>
		</td>
		<td class="tbYellow">預繳期數</td>
		<td class="tbYellow2" colspan="4">
			<input id="PREPAY_TIMES" type="text" class="textBox2"  disabled/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">貸放日期</td>
		<td class="tbYellow2" colspan="2">
			<input id="LOAN_DATE" type="text" class="textBox2"  disabled/>
		</td>
		<td class="tbYellow">下次應繳日</td>
		<td class="tbYellow2" colspan="4">
			<input id="NEXT_PAYDT" type="text" class="textBox2"  disabled/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">到期日期</td>
		<td class="tbYellow2" colspan="2">
			<input id="END_DATE" type="text" class="textBox2"  disabled/>
		</td>
		<td class="tbYellow">暫應收款</td>
		<td class="tbYellow2" colspan="4">
			<input id="LAST_BALANCE" type="text" class="textBox2" datatype="number" disabled/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">收息單位</td>
		<td class="tbYellow2" colspan="2">
			<input id="GETINT_DEPT" type="text" class="textBox2"  disabled/>
		</td>
		<td class="tbYellow">還款方式</td>
		<td class="tbYellow2" colspan="4">
			<select id="RETURN_TYPE" name="RETURN_TYPE" disabled>	
				<option value="">請選擇</option>			
				<c:forEach items="${RETURN_TYPE_List}" var="row">
					<option value="${row.key}" />${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">收費代號</td>
		<td class="tbYellow2" colspan="2">
			<input id="GETINT_CODE" type="text" class="textBox2"  disabled/>
		</td>
		<td class="tbYellow">期　別</td>
			<td class="tbYellow2" colspan="4">
			<select id="TERM_TYPE" name="TERM_TYPE" disabled>	
				<option value="">請選擇</option>			
				<c:forEach items="${TERM_TYPE_List}" var="row">
					<option value="${row.key}" />${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
	</tr>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2"  >
	<tr>
		<td class="tbBox3" align="center" colspan="10">變更後
		<input id="UNCONFIRM" type="hidden"/>
		<input id="APPLY_DATE" type="hidden"/>
		<input id="CHG_KIND" type="hidden"/>
		<input id="SEQ_NO" type="hidden"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >還款方式</td>
		<td class="tbYellow2">
			<select id="NEW_RETURN_TYPE" name="NEW_RETURN_TYPE">	
				<option value="">請選擇</option>			
				<c:forEach items="${RETURN_TYPE_List}" var="row">
					<option value="${row.key}" />${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
		<td class="tbYellow">手續費用</td>
		<td class="tbYellow2" colspan="5">
			<input id="EXPENSE_AMT" type="text" class="textBox2" size="7" maxlength="6"  datatype="number" value="0" />	
		</td>
		
	</tr>
	<tr>
		
		<td class="tbYellow">分期期數</td>
		<td class="tbYellow2">
			<input id="NEW_SPR_PERIOD" type="text" class="textBox2 " size="12" value="0"/>
		</td>
		<td class="tbYellow">定期期數</td>
		<td class="tbYellow2">
			<input id="NEW_FIX_PERIOD" type="text" class="textBox2 " size="12" value="0"/>
		</td>
		<td class="tbYellow">期　別</td>
		<td class="tbYellow2" colspan="3">
			<input id="NEW_TERM_TYPE" type="text" class="textBox2" size="12" disabled />
		</td>
	</tr>
	</table>
</form>
</body>
</body>
</html>