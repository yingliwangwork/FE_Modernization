<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename='TextResource' />

<!--
程式：DSC81900.jsp
功能：應繳日期變更
作者：林秉宏
完成：2013/07/17

[2023-01-13] 新增特殊事件緩繳
1. 透過URL重入參數不同，來共用應繳日期變更和特殊事件緩繳作業畫面
2. 特殊事件緩繳因影響客戶權益較大，需多審核機致
3. 特殊事件緩繳作業畫面的下方需有新增變更原因和延繳期期數的區塊

[20230321]
難字調整
高強禾
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<%-- [20230321] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>

<script type='text/javascript'> 

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC81900().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC81900(){
	
		//按鈕權限
		function buttonAuth(){
			var authButtons = {
				B0054 : 'BTN_update', <%--變更--%>		
				B0005: 'BTN_delete', <%--刪除--%>
			    B0070: 'BTN_approve' <%--覆核--%>
			};
			<dz:grantButtons FUNC_ID="DSC81910" />
		}
		
		var valid1;
		var valid2;
		
		//[2023-01-13] 1. 透過URL重入參數不同，來共用應繳日期變更和特殊事件緩繳作業畫面
		var PAGE_TYPE = "${PAGE_TYPE}";//1=>應繳日期變更，2=>特殊事件緩繳
		
		// 檢核
		var initValidation = function(){	
		
			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkLength', '請輸入正確貸款帳號查詢!', function( v ) { return chkLength($F('LOAN_ID'));}]
			] );
			valid1.define( "chkLength" , [{ id : "LOAN_ID" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid2.define( "required" , [{ id : "LOAN_ID_OLD", errMsg : '請先查詢再做變更!' } ] );
			
			if(PAGE_TYPE==1){//1=>應繳日期變更
				Validation.addAllThese( [
					[ 'chkLOAN_DATE', '欲變更的應繳日期不得小於等於貸放日期!', function( v ) { return chkLOAN_DATE($F('NEW_PAYDT'), $('LOAN_DATE').innerHTML);}]
				] );
				valid2.define( "required" , [{ id : "NEW_PAYDT", errMsg : '新應繳日期有誤，請檢查後重新輸入!' } ] );
				valid2.define( "validate-ROCDate" , [{ id : "NEW_PAYDT", errMsg : '新應繳日期有誤，請檢查後重新輸入!' } ] );
				valid2.define( "chkLOAN_DATE" , [{ id : "NEW_PAYDT" } ] );	
			}else{//2=>特殊事件緩繳
				valid2.define('required' , [{ id : "DELAY_TERM", errMsg:"請輸入緩繳期數"}]);
				valid2.define('validate-positive' , [{ id : "DELAY_TERM", errMsg:"緩繳期數請輸入有效數字格式"}]);
				valid2.define('validate-selection' , [{ id : "DELAY_TYPE", errMsg:"請選擇繳款種類"}]);
			}
		}
		
		// 檢核貸款帳號長度
		var chkLength = function (LOAN_ID) 
		{		
			var chk = true;
			if(LOAN_ID.length != 10) {
				chk = false; 
			}
			return chk; 	
		};
		
		// 檢核新下次應繳日需大於貸放日期
		var chkLOAN_DATE = function (NEW_PAYDT, LOAN_DATE) 
		{		
			var chk = true;
			if(diffDay(NEW_PAYDT, LOAN_DATE, true) >= 0) {
				chk = false; 
			}
			return chk; 	
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC8_1900/' + actionName,
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
	
		var actions = {
		
			// 查詢
			doQuery: function(){
	
				valid2.reset();
				
				// 檢核
				if(!valid1.validate()){ 
					return; 
				}

				// 頁面傳入參數
				ajaxPost( 'query' , 
				     { 'LOAN_ID' : $F('LOAN_ID') , 'PAGE_TYPE' : $F('PAGE_TYPE') },
					function(resp){	
						$w('BORROW_NAME LOAN_STATUS_NM').each(
							function(id) {
								$(id).innerHTML = resp.rtnMap[id] || '';
							}
						);
						$w('LOAN_DATE LAST_PAYDT NEXT_PAYDT').each(
							function(id) {
								$(id).innerHTML = Date.toROC(resp.rtnMap[id]) || '';
							}
						);
						
						var PAID_TIMES = resp.rtnMap['PAID_TIMES'];
						if(PAID_TIMES || PAID_TIMES == '0'){
							$('PAID_TIMES').innerHTML = resp.rtnMap['PAID_TIMES'] ;
						}else {
							$('PAID_TIMES').innerHTML = '';
						}
						
						$('LOAN_ID_OLD').value = resp.LOAN_ID;	
						
						if(PAGE_TYPE==1){//1=>應繳日期變更
							$('NEW_PAYDT').value = resp.rtnMap['NEXT_PAYDT'] ? Date.toROC(resp.rtnMap['NEXT_PAYDT']).replace(/\//g,"") : "";
							$('DUTY_DAY').innerHTML = resp.rtnMap['DUTY_DAY'];
						}else{//2=>特殊事件緩繳
							var rtnMap = resp.rtnMap;
							if( rtnMap.UNCONFIRM == 'Y'){ //特殊事件緩繳，有待審件
								$('SEQ_NO').value = rtnMap.SEQ_NO || '';
								$('APPLY_DATE').value = rtnMap.APPLY_DATE || '';
								$('DELAY_TYPE').value = rtnMap.DELAY_TYPE || '';//繳款種類
								$('DELAY_TERM').value = rtnMap.DELAY_TERM || '';//緩繳期數
								$('DELAY_REASON').value = rtnMap.DELAY_REASON || '';//緩繳繳款原因
								
								//查詢案件後才能點選
								$('BTN_approve').enable();
								$('BTN_delete').enable();
							}else{
								$('SEQ_NO').value = '';
								$('APPLY_DATE').value = '';
								$('DELAY_TYPE').value = '';//繳款種類
								$('DELAY_TERM').value = '';//緩繳期數
								$('DELAY_REASON').value = '';//緩繳繳款原因
							}
						}
						
					},function(resp){
						$w('BORROW_NAME LOAN_STATUS_NM PAID_TIMES').each(
							function(id) {
								$(id).innerHTML = '';
							}
						);
						$w('LOAN_DATE LAST_PAYDT NEXT_PAYDT').each(
							function(id) {
								$(id).innerHTML = '';
							}
						);
						$('LOAN_ID_OLD').value = '';
						
						if(PAGE_TYPE==1){//1=>應繳日期變更
							$('DUTY_DAY').innerHTML = '';
						}else{//2=>特殊事件緩繳
							$('SEQ_NO').value = '';
							$('APPLY_DATE').value = '';
							$('DELAY_TYPE').value = '';//繳款種類
							$('DELAY_TERM').value = '';//緩繳期數
							$('DELAY_REASON').value = '';//緩繳繳款原因
							
							//查詢案件後才能點選
							$('BTN_approve').disable();
							$('BTN_delete').disable();
						}
					}
				);	
			},
			
			// 變更(應繳日期變更)
			doUpdate: function(){

				valid1.reset();
				
				var LOAN_ID = $F('LOAN_ID');
				var LOAN_ID_OLD = $F('LOAN_ID_OLD');		
				if(LOAN_ID != LOAN_ID_OLD){
					alert("欲變更的帳號("+LOAN_ID+")與原先查詢的帳號("+LOAN_ID_OLD+")不一致!!");
					return;
				}
				var NEW_PAYDT = $F('NEW_PAYDT');
				var NEXT_PAYDT = $('NEXT_PAYDT').innerHTML;		
				if(diffDay(NEW_PAYDT, NEXT_PAYDT, true) == 0){
					if(NEW_PAYDT.length == 6){
						alert("欲變更的應繳日期("+NEW_PAYDT.substring(0,2)+"/"+NEW_PAYDT.substring(2,4)+"/"+NEW_PAYDT.substring(4,6)+")，與原先查詢的應繳日期("+NEXT_PAYDT+")相同");
					}else{
						alert("欲變更的應繳日期("+NEW_PAYDT.substring(0,3)+"/"+NEW_PAYDT.substring(3,5)+"/"+NEW_PAYDT.substring(5,7)+")，與原先查詢的應繳日期("+NEXT_PAYDT+")相同");
					}
					return;
				}
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}

				// 頁面傳入參數
				ajaxPost( 'update' , { 'LOAN_ID' : $F('LOAN_ID'), 'NEW_PAYDT' : toY2K($F('NEW_PAYDT')) },
					function(resp){	
						$w('BORROW_NAME LOAN_STATUS_NM PAID_TIMES DUTY_DAY').each(
							function(id) {
								$(id).innerHTML = resp.rtnMap[id] || '';
							}
						);
						$w('LOAN_DATE LAST_PAYDT NEXT_PAYDT').each(
							function(id) {
								$(id).innerHTML = Date.toROC(resp.rtnMap[id]) || '';
							}
						);
						$('LOAN_ID_OLD').value = resp.LOAN_ID;
						
					}
				);	
			},
			
			// 新增(特殊事件緩繳)
			doInsertDelay : function(){
				valid1.reset();
				
				var LOAN_ID = $F('LOAN_ID');
				var LOAN_ID_OLD = $F('LOAN_ID_OLD');		
				if(LOAN_ID != LOAN_ID_OLD){
					alert("欲新增的帳號("+LOAN_ID+")與原先查詢的帳號("+LOAN_ID_OLD+")不一致!!");
					return;
				}
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}

				// 頁面傳入參數
				ajaxPost( 'insertDelay' , { 
						'LOAN_ID' : $F('LOAN_ID'), 
						'DELAY_TYPE' : $F('DELAY_TYPE'),
						'DELAY_TERM' : $F('DELAY_TERM'),
						'DELAY_REASON' : $F('DELAY_REASON')
					},
					function(resp){	
						$w('BORROW_NAME LOAN_STATUS_NM PAID_TIMES').each(
							function(id) {
								$(id).innerHTML = resp.rtnMap[id] || '';
							}
						);
						$w('LOAN_DATE LAST_PAYDT NEXT_PAYDT').each(
							function(id) {
								$(id).innerHTML = Date.toROC(resp.rtnMap[id]) || '';
							}
						);
						$('LOAN_ID_OLD').value = resp.LOAN_ID;
						
						var rtnMap = resp.rtnMap;
						if( rtnMap.UNCONFIRM == 'Y'){ //有待審件
							$('SEQ_NO').value = rtnMap.SEQ_NO || '';
							$('APPLY_DATE').value = rtnMap.APPLY_DATE || '';
						}
						
						//查詢案件後才能點選
						$('BTN_approve').enable();
						$('BTN_delete').enable();
					}
				);
			},
			
			// 審核(特殊事件緩繳)
			doApprove : function(){
				valid1.reset();
				
				var LOAN_ID = $F('LOAN_ID');
				var LOAN_ID_OLD = $F('LOAN_ID_OLD');		
				if(LOAN_ID != LOAN_ID_OLD){
					alert("欲審核的帳號("+LOAN_ID+")與原先查詢的帳號("+LOAN_ID_OLD+")不一致!!");
					return;
				}
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}

				// 頁面傳入參數
				ajaxPost( 'approve' , 
					{ 
					   'LOAN_ID' : $F('LOAN_ID'),
					   'SEQ_NO' : $F('SEQ_NO'),
					   'APPLY_DATE' : $F('APPLY_DATE')
					},
					function(resp){	
						$w('BORROW_NAME LOAN_STATUS_NM PAID_TIMES').each(
							function(id) {
								$(id).innerHTML = resp.rtnMap[id] || '';
							}
						);
						$w('LOAN_DATE LAST_PAYDT NEXT_PAYDT').each(
							function(id) {
								$(id).innerHTML = Date.toROC(resp.rtnMap[id]) || '';
							}
						);
						
						$('SEQ_NO').value = '';
						$('APPLY_DATE').value = '';
						$('DELAY_TYPE').value = '';//繳款種類
						$('DELAY_TERM').value = '';//緩繳期數
						$('DELAY_REASON').value = '';//緩繳繳款原因
						//查詢案件後才能點選
						$('BTN_approve').disable();
						$('BTN_delete').disable();
					}
				);
			},
			
			//刪除(特殊事件緩繳)
			doDelete  : function(){
				valid1.reset();
				
				var LOAN_ID = $F('LOAN_ID');
				var LOAN_ID_OLD = $F('LOAN_ID_OLD');		
				if(LOAN_ID != LOAN_ID_OLD){
					alert("欲審核的帳號("+LOAN_ID+")與原先查詢的帳號("+LOAN_ID_OLD+")不一致!!");
					return;
				}
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}

				// 頁面傳入參數
				ajaxPost( 'delete' , 
					{ 
					   'LOAN_ID' : $F('LOAN_ID'),
					   'SEQ_NO' : $F('SEQ_NO'),
					   'APPLY_DATE' : $F('APPLY_DATE')
					},
					function(resp){	
						$w('BORROW_NAME LOAN_STATUS_NM PAID_TIMES').each(
							function(id) {
								$(id).innerHTML = resp.rtnMap[id] || '';
							}
						);
						$w('LOAN_DATE LAST_PAYDT NEXT_PAYDT').each(
							function(id) {
								$(id).innerHTML = Date.toROC(resp.rtnMap[id]) || '';
							}
						);
						$('LOAN_ID_OLD').value = resp.LOAN_ID;							
					}
				);	
			}
		};
		
		return {
			
			initApp : function() {
				var TITLE = '';
				var FUN_ID = '';
				//[2023-01-13] 1. 透過URL重入參數不同，來共用應繳日期變更和特殊事件緩繳作業畫面
				if(PAGE_TYPE==1){//1=>應繳日期變更
					TITLE = '應繳日期變更';
					FUN_ID = 'DSC81900';
				}else{//2=>特殊事件緩繳
					TITLE = '特殊事件緩繳';
					FUN_ID = 'DSC81910';
				}
					
				PageUI.createPageWithAllBodySubElement(
					FUN_ID ,
					'收息資料更新' , 
					TITLE
				);	
				
				initValidation();
					
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
					
				
				// 變更
				if(PAGE_TYPE==1){
					$('BTN_update').observe('click', actions.doUpdate);
				}else if(PAGE_TYPE==2){//2=>特殊事件緩繳
					buttonAuth();//特殊事件緩繳-變更、覆核、刪除的按鈕權限卡控
					
					//2023-01-13 特殊事件緩繳因影響客戶權益較大，需多審核機致
					$('BTN_update').observe('click', actions.doInsertDelay);
					$('BTN_approve').observe('click', actions.doApprove);
					$('BTN_delete').observe('click', actions.doDelete);
					
					//查詢案件後才能點選
					$('BTN_approve').disable();
					$('BTN_delete').disable();
				}		
	
				PageUI.resize();
				displayMessage();
		
			} // end initApp()		
		}; // end return
	}

   </script>
</head>
<body>

<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width='10%'>
			貸款帳號
		</td>
		<td class="tbYellow2" width="65%">
			<input id="LOAN_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="LOAN_ID_OLD" type="hidden">
		</td>
		<td class="tbYellow2" width='35%' align='center'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
			<input id="BTN_update" type="button" value="變更" class="button"> 
			<c:if test="${PAGE_TYPE == '2' }"> 
				<!-- [2023-01-13] 特殊事件緩繳因影響客戶權益較大，需多審核機致 -->
				<input id="BTN_delete" type="button" value="刪除" class="button"> 
				<input id="BTN_approve" type="button" value="審核" class="button"> 
			</c:if>
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="15%" align="center">
			借款人
		</td>
		<td class="tbYellow2" width="20%">
			<%-- [20230321] 難字調整 --%>
			<span id="BORROW_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow" width="15%" align="center">
			契約狀態
		</td>
		<td class="tbYellow2" width="20%">
			<span id="LOAN_STATUS_NM"></span>
		</td>
		<td class="tbYellow" width="15%" align="center">
			貸放日期
		</td>
		<td class="tbYellow2" width="20%">
			<span id="LOAN_DATE"></span>
		</td>
	</tr>
	
	<tr>
		<td class="tbYellow" width="15%" align="center">
			已繳期數
		</td>
		<td class="tbYellow2" width="20%">
			<span id="PAID_TIMES"></span>
		</td>
		<td class="tbYellow" width="15%" align="center">
			原上次已繳日
		</td>
		<td class="tbYellow2" width="20%">
			<span id="LAST_PAYDT"></span>
		</td>
		<td class="tbYellow" width="15%" align="center">
			原下次應繳日
		</td>
		<td class="tbYellow2" width="20%">
			<span id="NEXT_PAYDT"></span>
			<input id="PAGE_TYPE" type="hidden" value = "${PAGE_TYPE}" />
			<input id="SEQ_NO" type="hidden" value = "${SEQ_NO}" />
			<input id="APPLY_DATE" type="hidden" value = "${APPLY_DATE}" />
		</td>
	</tr>
	
	<tr>
		<c:if test="${PAGE_TYPE == '1'}">
			<td class="tbYellow" width="15%" align="center">
				原每月繳日
			</td>
			<td class="tbYellow2" width="20%">
				<span id="DUTY_DAY"></span>
			</td>
			<td class="tbYellow" width="15%" align="center">
				新下次應繳日
			</td>	
			<td class="tbYellow2" width="20%">
				<input id="NEW_PAYDT" datatype="ROCdate" type="text" class="textBox2" size="9" maxlength="7"/>
			</td>
			<td class="tbYellow" width="15%" align="center"></td>
			<td class="tbYellow2" width="20%"></td>
		</c:if>
		
		<!--[2023-01-13] 特殊事件緩繳作業畫面的下方需有新增變更原因和延繳期期數的區塊 -->
		<c:if test="${PAGE_TYPE == '2'}">
			<td class="tbYellow" width='15%' align="center">
				 緩繳種類
			</td>
			<td class="tbYellow2" width="20%">
				<select id="DELAY_TYPE" name=DELAY_TYPE>
				    <option value="">請選擇</option>
					<c:forEach items="${DelayTypeList}" var="item">
						<option value="${item.key}" />${item.value}</option>
					</c:forEach>
				</select>
			</td>	
			<td class="tbYellow" width="15%" align="center">
				緩繳期數
			</td>	
			<td class="tbYellow2" width="20%">
				<input id="DELAY_TERM" type="text" class="textBox2" size="9" maxlength="3"/>
			</td>
			<td class="tbYellow" width="15%" align="center">
				 緩繳繳款原因
			</td>
			<td class="tbYellow2" width="20%">
				<input id="DELAY_REASON" type="text" class="textBox2" size="30" maxlength="100"/>
			</td>
		</c:if>
	</tr>
	
</table>

</form>		
</body>
</html>