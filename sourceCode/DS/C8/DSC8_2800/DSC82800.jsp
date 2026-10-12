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
程式：DSC82800.jsp
功能：契約狀況變更
作者：林秉宏
完成：2013/08/13

[20230321] 修改程式  楊青峰
難字調整
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<%-- [20230321] --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
	         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	      font-weight: normal;
	      font-style: normal
	}
</style>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC82800().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC82800(){	

		var grid;
		var valid1, valid2;
		var LOAN_STATUS1_VALUE;
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0005 : 'BTN_delete',		<%--刪除--%>	
				B0054 : 'BTN_update',		<%--變更--%>	
				B0070 : 'BTN_confirm',		<%--覆核--%>	
				B0215 : 'BTN_queryUnConfirm'<%--未覆核查詢--%>		
			};
			<dz:grantButtons FUNC_ID='DSC82800'/>
		};
		
		// 檢核
		var initValidation = function(){	

			Validation.addAllThese( [
				[ 'chkLength', '貸款帳號需輸入且需為10碼!', function( v ) { return chkLength($F('LOAN_ID_Q'));}]
			] );
			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid1.define( "chkLength" , [{ id : "LOAN_ID_Q" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid2.define( "validate-selection" , [{ id : "LOAN_STATUS2", errMsg : '請選擇變更後契約狀況!' } ] );
	
		};
		
		// 檢核帳號長度
		var chkLength = function (ID) 
		{		
			var chk = true;
			if(ID.length != 10) {
				chk = false; 
			}
			return chk; 	
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC8_2800/' + actionName,
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
			doQuery : function(){
				
				valid2.reset();
				// 檢核
				if(!valid1.validate()){ 
					return; 
				}
				grid.load([]);
				// 頁面傳入參數
				ajaxPost( 'query' , { 'LOAN_ID' : $F('LOAN_ID_Q') },
					function(resp){			
						var rtnMap = resp.rtnMap;
						$w('LOAN_ID BORROW_ID BORROW_NAME').each(
							function(id) {		
								$(id).innerHTML = rtnMap[id] || '';						
							}
						);
						LOAN_STATUS1_VALUE = rtnMap['LOAN_STATUS1'];
						$('LOAN_STATUS1').innerHTML = rtnMap['LOAN_STATUS1_NM'] || '';	
						$('LOAN_ID_OLD').value = rtnMap['LOAN_ID'] || '';
						$('LOAN_STATUS2').value = rtnMap['LOAN_STATUS2'] || ''; 
						$('CHANGE_REASON').value = rtnMap['CHANGE_REASON'] || '';
					},function(resp){
						$w('LOAN_ID BORROW_ID BORROW_NAME').each(
							function(id) {		
								$(id).innerHTML = '';						
							}
						);
						LOAN_STATUS1_VALUE = '';
						$('LOAN_STATUS1').innerHTML = '';	
						$('LOAN_ID_OLD').value = '';
						$('LOAN_STATUS2').value = '';
						$('CHANGE_REASON').value = '';
					}
				);	
			},
			
			// 變更
			doUpdate : function(){
				
				// 檢核				
				if(!$F('LOAN_ID_OLD')){
					alert("請先查詢後再作業!");
					return;
				}
	
				if($F('LOAN_ID_Q') != $F('LOAN_ID_OLD')){
					alert("欲異動的貸款帳號與原先查詢的帳號不同，無法作業!");
					return;
				}
				
				valid1.reset();
				$('CHANGE_REASON').className = 'textBox2 required';
				// 檢核
				if(!valid2.validate()){
					$('CHANGE_REASON').className = 'textBox2'; 
					return; 
				}
				$('CHANGE_REASON').className = 'textBox2';
				var reqMap = {
					LOAN_ID : $F('LOAN_ID_Q'),
					LOAN_STATUS1 : LOAN_STATUS1_VALUE,
					LOAN_STATUS2 : $F('LOAN_STATUS2'),
					CHANGE_REASON : $F('CHANGE_REASON')
				}
				
				// 頁面傳入參數
				ajaxPost( 'update' , { 'info' : Object.toJSON(reqMap) },
					function(resp){}
				);	
			},
			
			// 刪除
			doDelete : function(){
				
				// 檢核				
				if(!$F('LOAN_ID_OLD')){
					alert("請先查詢後再作業!");
					return;
				}
	
				if($F('LOAN_ID_Q') != $F('LOAN_ID_OLD')){
					alert("欲刪除的貸款帳號與原先查詢的帳號不同，無法作業!");
					return;
				}
				
				valid1.reset();
				valid2.reset();
				
				// 頁面傳入參數
				ajaxPost( 'delete' , { 'LOAN_ID' : $F('LOAN_ID_Q') },
					function(resp){
						grid.load(resp.rtnList || []);
					},function(resp){
						grid.load([]);
					}
				);	
			},
			
			// 未覆核查詢
			doQueryUnConfirm : function(){
				
				valid1.reset();
				valid2.reset();
				
				// 頁面傳入參數
				ajaxPost( 'queryUnConfirm' , { },
					function(resp){
						grid.load(resp.rtnList || []);
					},function(resp){
						grid.load([]);
					}
				);	
			},
			
			// 覆核
			doConfirm : function(){
				
				// 檢核				
				var chkList = grid.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請至少選擇一筆欲覆核資料");
				  	return;
				}
				
				valid1.reset();
				valid2.reset();
				
				// 頁面傳入參數
				ajaxPost( 'confirm' , { 'checkList' : Object.toJSON(chkList), 'LOAN_ID' : $F('LOAN_ID_Q') },
					function(resp){			
						var rtnMap = resp.rtnMap;
						$w('LOAN_ID BORROW_ID BORROW_NAME').each(
							function(id) {		
								$(id).innerHTML = rtnMap[id] || '';						
							}
						);
						LOAN_STATUS1_VALUE = rtnMap['LOAN_STATUS1'];
						$('LOAN_STATUS1').innerHTML = rtnMap['LOAN_STATUS1_NM'] || '';	
						$('LOAN_ID_OLD').value = rtnMap['LOAN_ID'] || '';
						$('LOAN_STATUS2').value = rtnMap['LOAN_STATUS2'] || ''; 
						$('CHANGE_REASON').value = rtnMap['CHANGE_REASON'] || '';
						grid.load(resp.rtnList || []);
					}/*,function(resp){
						$w('LOAN_ID BORROW_ID BORROW_NAME').each(
							function(id) {		
								$(id).innerHTML = '';						
							}
						);
						LOAN_STATUS1_VALUE = '';
						$('LOAN_STATUS1').innerHTML = '';	
						$('LOAN_ID_OLD').value = '';
						$('LOAN_STATUS2').value = '';
						$('CHANGE_REASON').value = '';
						grid.load(resp.rtnList || []);
					}*/
				);	
			}
		};
		
		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSC82800' ,
					'變更作業' , 
					'契約狀況變更'
				);			
				
				// 產生 grid 物件	
				grid = new TableUI(
					{	
						table: $('grid'), allSortable:false, overDiv:false,
						<%-- [20230321] --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						autoCheckBox:{isSelectAll:true},
						column:[
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:'變更前契約狀況', key:'LOAN_STATUS1_NM'},
							{header:'變更後契約狀況', key:'LOAN_STATUS2_NM'},
							{header:'變更原因', key:'CHANGE_REASON'},
							{header:'輸入人員', key:'INPUT_NM'},
							{header:'輸入日期', key:'INPUT_DATE'}
						]						
					}
				);				
					
				initValidation();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
				
				// 變更
				$('BTN_update').observe('click', actions.doUpdate);
				
				// 刪除
				$('BTN_delete').observe('click', actions.doDelete);
				
				// 未覆核查詢
				$('BTN_queryUnConfirm').observe('click', actions.doQueryUnConfirm);
				
				// 覆核
				$('BTN_confirm').observe('click', actions.doConfirm);
				
				buttonAuth();
	
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
		<td class="tbYellow2" width="40%">
			<input id="LOAN_ID_Q" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="LOAN_ID_OLD" type="hidden">
		</td>
		<td class="tbYellow2" width='50%' align='center'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
			<input id="BTN_update" type="button" value="變更" class="button"> 
			<input id="BTN_delete" type="button" value="刪除" class="button">
			<input id="BTN_queryUnConfirm" type="button" value="未覆核查詢" class="button">
			<input id="BTN_confirm" type="button" value="覆核" class="button">
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbBox3" align="center" colspan="6"">
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width='10%'>
			貸款帳號
		</td>
		<td class="tbYellow2" width="23%">
			<span id="LOAN_ID"></span>
		</td>
		<td class="tbYellow" width='10%'>
			借款人ID
		</td>
		<td class="tbYellow2" width="23%">
			<span id="BORROW_ID"></span>
		</td>
		<td class="tbYellow" width='10%'>
			借款人姓名
		</td>
		<td class="tbYellow2" width="23%">
			<span id="BORROW_NAME" style="font-family: 'EUDC'"></span> <%-- [20230321] --%>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			契約狀況
		</td>
		<td class="tbYellow2" colspan="5">	
			<span id="LOAN_STATUS1"></span>
		</td>
	</tr>
	<tr>
		<td class="tbBox3" align="center" colspan="6">
			變更後資料
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			契約狀況
		</td>
		<td class="tbYellow2">
			<select id="LOAN_STATUS2" name="LOAN_STATUS2">	
				<option value="">請選擇</option>			
				<c:forEach items="${LOAN_STATUS_LIST}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
		<td class="tbYellow">
			修改原因
		</td>
		<td class="tbYellow2" width="23%" colspan="3">
			<input id="CHANGE_REASON" type="text" class="textBox2" size="80" alt="ch" /> <%-- [20230321] --%>
		</td>
	</tr>
	<tr>
		<td class="tbBox3" align="center" colspan="6"">
			未覆核資料
		</td>
	</tr>
</table>

<table id="grid" class="grid"></table>

</form>		
</body>
</html>