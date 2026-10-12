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
程式：DSC81500.jsp
功能：收息單位變更
作者：林秉宏
完成：2013/07/18

[20230321]
難字調整
高強禾
[20250219]
問題單編號20250214-0138收息單位取得判斷優化 BY余凱鈞
//一般外勤招攬案件取其單位代號前三碼+0000、案件承辦科別為總公司則是6400100，其餘皆判斷以通訊地址或擔保品地址去呼叫AD_T0Z004模組取得收息單位，
//但部分情況取到的收息單位非三碼0000的單位，導致無法直接對應到資管單位
//=>另外DSC81500收息單位變更也要卡控只能輸入前三碼
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC81500().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC81500(){
		
		var valid1;
		var valid2;
	
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0054 : 'BTN_update'		<%--變更--%>		
			};
			<dz:grantButtons FUNC_ID='DSC81500'/>
		};
		
		// 檢核
		var initValidation = function(){	

			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkLength', '請輸入正確貸款帳號查詢!', function( v ) { return chkLength($F('LOAN_ID'));}]
			] );
			valid1.define( "chkLength" , [{ id : "LOAN_ID" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkDeptLength', '請輸入3碼單位代號!', function( v ) { return chkDeptLength($F('NEW_GETINT_DEPT'));}]
			] );
			valid2.define( "required" , [{ id : "LOAN_ID_OLD", errMsg : '無查詢資料，無法變更!' } ] );	
			valid2.define( "chkDeptLength" , [{ id : "NEW_GETINT_DEPT" } ] );
		};
		
		// 檢核貸款帳號長度
		var chkLength = function (LOAN_ID) 
		{		
			var chk = true;
			if(LOAN_ID.length != 10 || !(/^[a-zA-Z0-9]+$/.test(LOAN_ID))) {
				chk = false; 
			}
			return chk; 	
		};
		
		// 檢核新收息單位代號長度
		var chkDeptLength = function (NEW_GETINT_DEPT) 
		{		
			var chk = true;
			if(NEW_GETINT_DEPT.length != 3) {
				chk = false; 
			}
			return chk; 	
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC8_1500/' + actionName,
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
				ajaxPost( 'query' , { 'LOAN_ID' : $F('LOAN_ID') },
					function(resp){	
						$w('BORROW_NAME CON_ZIP CON_ADDR DIFFER GETINT_DEPT').each(
							function(id) {
								$(id).value = resp.rtnMap[id] || '';
							}
						);
						
						$('NEW_GETINT_DEPT').value = resp.rtnMap['GETINT_DEPT'].substr(0, 3) || '';
						//$('GETINT_DEPT').value = resp.rtnMap['GETINT_DEPT'].substr(0, 5) || '';
						$('LOAN_ID_OLD').value = resp.rtnMap['LOAN_ID'];

						if (resp.rtnMap['OPER_AUTH'] == 'N') {
							alert(resp.rtnMap['GETINT_NOTE']);
							$('BTN_update').disable();
						};					
						
					},function(resp){
						$w('BORROW_NAME CON_ZIP CON_ADDR GETINT_DEPT DIFFER').each(
							function(id) {
								$(id).value = '';
							}
						);
						$('LOAN_ID_OLD').value = '';
					}
				);	
			},
			
			// 變更
			doUpdate: function(){

				valid1.reset();
				
				var LOAN_ID = $F('LOAN_ID');
				var LOAN_ID_OLD = $F('LOAN_ID_OLD');		
				if(LOAN_ID != LOAN_ID_OLD){
					alert("欲變更的"+LOAN_ID+"與原先查詢的"+LOAN_ID_OLD+"不同，無法作業!!");
					return;
				}
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}

				// 頁面傳入參數
				ajaxPost( 'update' , { 'info' : Object.toJSON(reqMap()) },
					function(resp){						
						$w('BORROW_NAME CON_ZIP CON_ADDR DIFFER GETINT_DEPT').each(
							function(id) {
								$(id).value = resp.rtnMap[id] || '';
							}
						);
						//$('GETINT_DEPT').value = resp.rtnMap['GETINT_DEPT'].substr(0, 5) || '';
						$('LOAN_ID_OLD').value = resp.rtnMap['LOAN_ID'];
						$('NEW_GETINT_DEPT').value = '';					
					}
				);	
			}
		};
		
		//產生查詢回傳資料
		var reqMap = function(){
		
			var reqMap = {};

			$$('#form1 input[type!="button"]').each(
				function(text){
					reqMap[text.id] = text.value;
				}
			);
			
			reqMap['NEW_GETINT_DEPT'] = $('NEW_GETINT_DEPT').value + '0000';
			
			return reqMap;
			
		};

		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSC81500' ,
					'收息資料更新' , 
					'收息單位變更'
				);			
					
				initValidation();	
					
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
					
				// 變更
				$('BTN_update').observe('click', actions.doUpdate);

				buttonAuth();	
	
				PageUI.resize();
				displayMessage();
		
			} // end initApp()		
		}; // end return
	}

--></script>
</head>
<body>

<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width='10%'>
			貸款帳號
		</td>
		<td class="tbYellow2" width="70%">
			<input id="LOAN_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="LOAN_ID_OLD" type="hidden">
			<input id="DIFFER" type="hidden">
		</td>
		<td class="tbYellow2" width='20%' align='center'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
			<input id="BTN_update" type="button" value="變更" class="button"> 
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbBox3" align="center">
			收費單位資料
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="15%" align="center">
			姓名
		</td>
		<td class="tbYellow2" width="85%">
			<%-- [20230321] 難字調整 --%>
			<input id="BORROW_NAME" type="text" size='15' alt="ch" readonly/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="15%" align="center">
			原區域代碼
		</td>
		<td class="tbYellow2" width="85%">
			<input id="CON_ZIP" type="text" size='7' readonly/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="15%" align="center">
			原通訊地址
		</td>
		<td class="tbYellow2" width="85%">
			<%-- [20230321] 難字調整 --%>
			<input id="CON_ADDR" type="text" size='60' alt="ch" readonly/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="15%" align="center">
			原收息單位代號
		</td>
		<td class="tbYellow2" width="85%">
			<input id="GETINT_DEPT" type="text" size='7' readonly/>
		</td>
	</tr>	
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbBox3" align="center">
			變更後資料
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="15%" align="center">
			新收息單位代號
		</td>
		<td class="tbYellow2" width="85%">
			<input id="NEW_GETINT_DEPT" type="text" maxlength='3' size='7' onblur="this.value = this.value.toUpperCase()"/>
			(請輸入3碼單位代號)
		</td>
	</tr>
</table>

</form>		
</body>
</html>