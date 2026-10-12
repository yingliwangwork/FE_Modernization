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
程式：DSC80500.jsp
功能：貸款種類變更
作者：林秉宏
完成：2013/08/26

[20230317] 修改程式  楊青峰
難字調整
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

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
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC80500().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC80500(){	

		var valid;
		var valid2;
		
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0005 : 'BTN_delete',		<%--刪除--%>	
				B0054 : 'BTN_update'		<%--變更--%>		
			};
			<dz:grantButtons FUNC_ID='DSC80500'/>
		};
		
		// 檢核
		var initValidation = function(){	

			Validation.addAllThese( [
				[ 'chkLength', '貸款帳號需輸入且需為10碼!', function( v ) { return chkLength($F('LOAN_ID_Q'));}]
			] );
			valid = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid.define( "chkLength" , [{ id : "LOAN_ID_Q" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid2.define( "required" , [{ id : "NEW_SALARY_GROUP" } ] );
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
			new Ajax.Request( '<%=dispatcher%>/DSC8_0500/' + actionName,
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
				valid.reset();
				valid2.reset();
				
				// 檢核
				if(!valid.validate()){ 
					return; 
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'LOAN_ID' : $F('LOAN_ID_Q') },
					function(resp){
						var rtnMap = resp.rtnMap;
						$w('LOAN_ID BORROW_NAME LOAN_KIND LOAN_KIND_NM PREFER_TYPE PREFER_TYPE_NM '
						+ 'GAGE_TYPE GAGE_TYPE_NM SALARY_STATUS SALARY_STATUS_NM INSU_NOTE INSU_NOTE_NM '
						+ 'SALARY_GROUP SALARY_GROUP_NM	PAY_TYPE PAY_TYPE_NM LIMIT_CODE LIMIT_CODE_NM '
						+ 'OWNER_SW LOAN_ID2 DELAY_SW REFER_SW NEW_LOAN_KIND NEW_SALARY_GROUP NEW_LIMIT_CODE '
						+ 'NEW_SALARY_STATUS EMP_ID CON_ZIP NEXT_PAYDT BORROW_ID INDIV_ADJUST').each(
							function(id) {		
								$(id).value = rtnMap[id] || '';						
							}
						);
						$('LOAN_ID_OLD').value = rtnMap['LOAN_ID'] || '';
						$('REMAIN_AMT').value = rtnMap['REMAIN_AMT'];

					},function(resp){
						$w('LOAN_ID BORROW_NAME LOAN_KIND LOAN_KIND_NM PREFER_TYPE PREFER_TYPE_NM '
						+ 'GAGE_TYPE GAGE_TYPE_NM SALARY_STATUS SALARY_STATUS_NM INSU_NOTE INSU_NOTE_NM '
						+ 'SALARY_GROUP SALARY_GROUP_NM	PAY_TYPE PAY_TYPE_NM LIMIT_CODE LIMIT_CODE_NM '
						+ 'OWNER_SW LOAN_ID2 DELAY_SW REFER_SW NEW_LOAN_KIND NEW_SALARY_GROUP NEW_LIMIT_CODE '
						+ 'NEW_SALARY_STATUS EMP_ID CON_ZIP NEXT_PAYDT BORROW_ID INDIV_ADJUST').each(
							function(id) {		
								$(id).value = '';						
							}
						);
						$('LOAN_ID_OLD').value = '';
						$('REMAIN_AMT').value = 0;
					}
				);	
			},
			
			// 變更
			doUpdate : function(){
				
				// 檢核				
				if(!$F('LOAN_ID_OLD')){
					alert("請先查詢後再變更!");
					return;
				}
	
				if($F('LOAN_ID_Q') != $F('LOAN_ID_OLD')){
					alert("欲變更的"+$F('LOAN_ID_Q')+"與原先查詢的"+$F('LOAN_ID_OLD')+"不同，無法作業!");
					return;
				}
				
				valid.reset();	
				valid2.reset();	
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}				
				
				var errMsg = '';
				var isSelect = 'Y';
				if ($('NEW_LOAN_KIND').value == '') {
					//errMsg = '您未選擇新貸款種類，確定要變更扣薪組別?';
					isSelect = 'N';
				}

				//if (!errMsg || confirm(errMsg)) {	
					// 頁面傳入參數
					ajaxPost( 'update' , { 'info' : Object.toJSON(reqMap()), 'LOAN_ID' : $F('LOAN_ID_Q'), 'isSelect' : isSelect },
						function(resp){
							var rtnMap = resp.rtnMap;
							$w('LOAN_ID BORROW_NAME LOAN_KIND LOAN_KIND_NM PREFER_TYPE PREFER_TYPE_NM '
							+ 'GAGE_TYPE GAGE_TYPE_NM SALARY_STATUS SALARY_STATUS_NM INSU_NOTE INSU_NOTE_NM '
							+ 'SALARY_GROUP SALARY_GROUP_NM	PAY_TYPE PAY_TYPE_NM LIMIT_CODE LIMIT_CODE_NM '
							+ 'OWNER_SW LOAN_ID2 DELAY_SW REFER_SW NEW_LOAN_KIND NEW_SALARY_GROUP NEW_LIMIT_CODE '
							+ 'NEW_SALARY_STATUS EMP_ID CON_ZIP NEXT_PAYDT BORROW_ID INDIV_ADJUST').each(
								function(id) {		
									$(id).value = rtnMap[id] || '';						
								}
							);
							$('REMAIN_AMT').value = rtnMap['REMAIN_AMT'];
						}
					);	
				//}
			},
			
			// 刪除
			doDelete : function(){
				
				// 檢核				
				if(!$F('LOAN_ID_OLD')){
					alert("請先查詢後再刪除!");
					return;
				}
	
				if($F('LOAN_ID_Q') != $F('LOAN_ID_OLD')){
					alert("欲刪除的"+$F('LOAN_ID_Q')+"與原先查詢的"+$F('LOAN_ID_OLD')+"不同，無法作業!");
					return;
				}
				
				valid.reset();

				var errMsg = '確定要刪除?';
				
				if (!errMsg || confirm(errMsg)) {				
					// 頁面傳入參數
					ajaxPost( 'delete' , { 'info' : Object.toJSON(reqMap()), 'LOAN_ID' : $F('LOAN_ID_Q') },
						function(resp){
							var rtnMap = resp.rtnMap;
							$w('LOAN_ID BORROW_NAME LOAN_KIND LOAN_KIND_NM PREFER_TYPE PREFER_TYPE_NM '
							+ 'GAGE_TYPE GAGE_TYPE_NM SALARY_STATUS SALARY_STATUS_NM INSU_NOTE INSU_NOTE_NM '
							+ 'SALARY_GROUP SALARY_GROUP_NM	PAY_TYPE PAY_TYPE_NM LIMIT_CODE LIMIT_CODE_NM '
							+ 'OWNER_SW LOAN_ID2 DELAY_SW REFER_SW NEW_LOAN_KIND NEW_SALARY_GROUP NEW_LIMIT_CODE '
							+ 'NEW_SALARY_STATUS EMP_ID CON_ZIP NEXT_PAYDT BORROW_ID INDIV_ADJUST').each(
								function(id) {		
									$(id).value = rtnMap[id] || '';						
								}
							);
							$('REMAIN_AMT').value = rtnMap['REMAIN_AMT'];
						}
					);	
				}
			}
		};
		
		// 產生查詢回傳資料
		var reqMap = function(){
			
			var reqMap = {};

			$$('#form1 input[type!="button"]', '#form1 select').each(
				function(text){
					reqMap[text.id] = text.value;
				}
			);
			
			return reqMap;		
		};
		
		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSC80500' ,
					'變更作業' , 
					'貸款種類變更 ※變更貸款種類可能變動同意優惠請至同意優惠再次確認※'
				);					
					
				initValidation();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
				
				// 變更
				$('BTN_update').observe('click', actions.doUpdate);
				
				// 刪除
				$('BTN_delete').observe('click', actions.doDelete);
								
				buttonAuth();
				
				$('BTN_delete').hide(); //刪除功能先隱藏 2014/7/11
	
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
		<td class="tbYellow" width='20%'>
			貸款帳號
		</td>
		<td class="tbYellow2" width="30%">
			<input id="LOAN_ID_Q" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="LOAN_ID_OLD" type="hidden">
		</td>
		<td class="tbYellow2" width='50%' align='center'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
			<input id="BTN_update" type="button" value="變更" class="button"> 
			<input id="BTN_delete" type="button" value="刪除" class="button">
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="20%">
			貸款帳號
		</td>
		<td class="tbYellow2" width="30%" colspan="3">
			<input id="LOAN_ID" type="text" class="textBox2" size="30" maxlength="10" disabled/>
			<input id="EMP_ID" type="hidden">
			<input id="CON_ZIP" type="hidden">
			<input id="REMAIN_AMT" type="hidden">
			<input id="NEXT_PAYDT" type="hidden">
			<input id="BORROW_ID" type="hidden">
			<input id="INDIV_ADJUST" type="hidden">
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="20%">
			借款人姓名
		</td>
		<td class="tbYellow2" width="30%" colspan="3">
			<input id="BORROW_NAME" type="text" class="textBox2" size="30" alt="ch" disabled /> <%-- [20230317] --%>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="20%">
			原貸款種類
		</td>
		<td class="tbYellow2" width="30%">
			<input id="LOAN_KIND_NM" type="text" class="textBox2" size="30" disabled/>
			<input id="LOAN_KIND" type="hidden">
		</td>
		<td class="tbYellow" width="20%">
			原優惠種類
		</td>
		<td class="tbYellow2" width="30%">
			<input id="PREFER_TYPE_NM" type="text" class="textBox2" size="30" disabled/>
			<input id="PREFER_TYPE" type="hidden">
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			原擔保種類
		</td>
		<td class="tbYellow2">
			<input id="GAGE_TYPE_NM" type="text" class="textBox2" size="30" disabled/>
			<input id="GAGE_TYPE" type="hidden">
		</td>
		<td class="tbYellow">
			原扣薪狀況
		</td>
		<td class="tbYellow2">
			<input id="SALARY_STATUS_NM" type="text" class="textBox2" size="30" disabled/>
			<input id="SALARY_STATUS" type="hidden">
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			原同意優惠
		</td>
		<td class="tbYellow2">
			<input id="INSU_NOTE_NM" type="text" class="textBox2" size="30" disabled/>
			<input id="INSU_NOTE" type="hidden">
		</td>
		<td class="tbYellow">
			原扣薪組別
		</td>
		<td class="tbYellow2">
			<input id="SALARY_GROUP_NM" type="text" class="textBox2" size="30" disabled/>
			<input id="SALARY_GROUP" type="hidden">
			
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			原繳款方式
		</td>
		<td class="tbYellow2">
			<input id="PAY_TYPE_NM" type="text" class="textBox2" size="30" disabled/>
			<input id="PAY_TYPE" type="hidden">
		</td>
		<td class="tbYellow">
			原資料限制
		</td>
		<td class="tbYellow2">
			<input id="LIMIT_CODE_NM" type="text" class="textBox2" size="30" disabled/>
			<input id="LIMIT_CODE" type="hidden">		
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			所有權人
		</td>
		<td class="tbYellow2">
			<input id="OWNER_SW" type="text" class="textBox2" size="30" disabled/>
		</td>
		<td class="tbYellow">
			另一件指標指數員工貸款帳號
		</td>
		<td class="tbYellow2">
			<input id="LOAN_ID2" type="text" class="textBox2" size="30" disabled/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			繳息狀況
		</td>
		<td class="tbYellow2">
			<input id="DELAY_SW" type="text" class="textBox2" size="30" disabled/>
		</td>
		<td class="tbYellow">
			另一件指標指數員工可貸狀況
		</td>
		<td class="tbYellow2">
			<input id="REFER_SW" type="text" class="textBox2" size="30" disabled/>
		</td>
	</tr>
	<tr>
		<td class="tbBox3" align="center" colspan="4">變更後
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			新貸款種類
		</td>
		<td class="tbYellow2">
			<select id="NEW_LOAN_KIND" name="NEW_LOAN_KIND" disabled>	
				<option value="">請選擇</option>			
				<c:forEach items="${LOAN_KIND_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
			<font color="blue"><br>－不選擇新的貸款種類可只變更扣薪組別</font>
		</td>
		<td class="tbYellow">
			新扣薪組別
		</td>
		<td class="tbYellow2">
			<select id="NEW_SALARY_GROUP" name="NEW_SALARY_GROUP">	
				<option value="">請選擇</option>			
				<c:forEach items="${SALARY_GROUP_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
			<font color="blue"><br>－請選擇正確的扣薪組別</font>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			新資料限制
		</td>
		<td class="tbYellow2">
			<input id="NEW_LIMIT_CODE" type="text" class="textBox2" size="30" disabled/>
		</td>
		<td class="tbYellow">
			新扣薪狀況
		</td>
		<td class="tbYellow2">
			<input id="NEW_SALARY_STATUS" type="text" class="textBox2" size="30" disabled/>
		</td>
	</tr>
</table>

</form>		
</body>
</html>