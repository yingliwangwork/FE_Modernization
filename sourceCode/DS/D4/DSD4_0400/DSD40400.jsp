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
程式：DSD40400.jsp
功能：清償證明列印作業
作者：林秉宏
完成：2013/07/30

[20240328]
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
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script><%-- 匯出PDF用--%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<%-- [20240328] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSD40400().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSD40400(){	

		var grid;
		var valid;
		
		// 檢核
		var initValidation = function(){	

			valid = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkLength', '請輸入正確貸款帳號查詢!', function( v ) { return chkLength($F('LOAN_ID'));}]
			] );
			valid.define( "validate-selection" , [{ id : "CRED_DEPT" , errMsg : "請選擇承辦科別再執行查詢作業" } ] );
			valid.define( "validate-ROCDate" , [{ id : "FINAL_DATE" } ] );
			valid.define( "chkLength" , [{ id : "LOAN_ID" } ] );
		};
		
		// 檢核帳號長度
		var chkLength = function (ID) 
		{		
			var chk = true;
			if(ID && ID.length != 10) {
				chk = false; 
			}
			return chk; 	
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSD4_0400/' + actionName,
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

				// 檢核
				if(!valid.validate()){ 
					return; 
				}
				
				// 檢核
				if(!$F('FINAL_DATE') && !$F('LOAN_ID')){
					alert("確認日期.貸款帳號請至少輸入一欄再執行查詢作業");
					return;
				}
				
				var reqMap = {
					CRED_DEPT : $F('CRED_DEPT'),
					AUDIT_ID : $F('AUDIT_ID'),
					FINAL_DATE : toY2K($F('FINAL_DATE')),
					LOAN_ID : $F('LOAN_ID')
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'info' : Object.toJSON(reqMap) },
					function(resp){			
						grid.load(resp.rtnList || []);
					},function(resp){
						grid.load([]);
					}
				);	
			},
			
			// 列印
			doPrint : function(){
				
				valid.reset();
				
				var rtnList = grid.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行列印作業");
					return;
				}
				
				var chkMap = getCheckedMap();

				if(!chkMap) {
					return;
				}
				
				ajaxPost( 'print' , { chkMap : Object.toJSON(chkMap) },
					function(resp){		
						var msg='';
						if(resp.nameOverMaxLength=='Y'){
							msg+='借款人姓名字數超過可顯示長度，請自行補寫借款人姓名';
						}
						//[191119] 申請書-191001000815:塗銷證明改版，若權利種類為選，跳提示訊息請作業人員自行輸入權利種類
						if(resp.rightTypeIsNull=='Y'){
							if(msg.length>0){
								msg+='\n';
							}
							msg+='此件未選擇權利種類，請自行補寫「權利種類」';
						}
						if(msg.length>0){
							alert(msg);
						}
						var url = "${dispatcher}/DSD4_0410/prompt";
						
						/*new Ajax.Request( url , 
						{
							parameters: { 'LOAN_ID' : chkMap.LOAN_ID },
							onSuccess: function(response)
							{
								var resp = response.responseJSON;
								if(CSRUtil.isSuccess(resp)){
									RPTUtil.executePrintByResponse(resp, true);
								}
							}
						});*/	
						//因應報表浮水印控管，需設白名單之報表要有引用到浮水印模組
						RPTUtil.downloadFile(url , { 'LOAN_ID' : chkMap.LOAN_ID }, true );							
					}
				);			
			}
		};
		
		// 將勾選資料存成chkMap
		var getCheckedMap = function(){
			
			var checkList = grid.getCheckedRecord();
				
			if (checkList.length == 0){
				alert('請先選取再執行列印作業');	
				return false;
			}	
			return checkList[0];
		};
		
		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSD40400' ,
					'清償作業' , 
					'清償證明列印'
				);			
				
				// 產生 grid 物件	
				grid = new TableUI(
					{	
						table: $('grid'), pageSize: 10,allSortable:true, overDiv:false,
						autoCheckBox:{isSelectAll:true, type:'radio'},
						<%-- [20240328] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header:'貸款帳號', key:'LOAN_ID'},
							<%-- [20240328] 難字調整：姓名 --%>
							{header:'姓名', key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
							{header:'借款人ID', key:'BORROW_ID',
								render : function (rec , val){
									return CSRUtil.maskHandler.getMaskID(val);
							}},
							{header:'契約狀況', key:'LOAN_STATUS_NM',
								render : function (rec , val){
									//13 清償有暫收、14 清償有未兌票，以紅字顯示
									if (rec.LOAN_STATUS == '13' || rec.LOAN_STATUS == '14'){

										return "<font color='red'>" + val + "</font>";
									}else{
										return val;
									}
							}},
							{header:'承辦單位', key:'CRED_DEPT_NM'},
							<%-- [20240328] 難字調整：輸入人員、輸入覆核、資管科經辦、資管科主管 --%>
							{header:'輸入人員', key:'INPUT_ID_NAME', attrs:{ style:"font-family:'EUDC'" },
								render : function (rec , val){
									return val ? CSRUtil.maskHandler.getMaskName(val) : '';
							}},
							{header:'輸入覆核', key:'INPUT_LEADER_NAME', attrs:{ style:"font-family:'EUDC'" },
								render : function (rec , val){
									return val ? CSRUtil.maskHandler.getMaskName(val) : '';
							}},
							{header:'資管科經辦', key:'CHECK_ID_NAME', attrs:{ style:"font-family:'EUDC'" },
								render : function (rec , val){
									return val ? CSRUtil.maskHandler.getMaskName(val) : '';
							}},
							{header:'資管科主管', key:'CHECK_LEADER_NAME', attrs:{ style:"font-family:'EUDC'" },
								render : function (rec , val){
									return val ? CSRUtil.maskHandler.getMaskName(val) : '';
							}},
							{header:'確認日期', key:'FINAL_DATE',
								render : function (record , value){
									return Date.toROC(value);
								}
							}
						]						
					}
				);								
					
				initValidation();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
				
				// 列印
				$('BTN_print').observe('click', actions.doPrint);
				
				// 下拉選單控制
				//$("CRED_DEPT").disable();
				
				<%-- [2019/04/02] 清償作業優化(第二階段) - 承辦科別改為"非總公司"與"總公司"，取消承辦科別預設--%>
				if ("${LOGIN_CRED_DEPT}" && "${LOGIN_CRED_DEPT}" != '' && "${LOGIN_CRED_DEPT}" != '0' ){
					$("CRED_DEPT").value = "${LOGIN_CRED_DEPT}";
				}
				
				if ("${LOGIN_AUDIT_ID}" && "${LOGIN_AUDIT_ID}" != '' && "${LOGIN_AUDIT_ID}" != '0' ){
					$("AUDIT_ID").setValue("${LOGIN_AUDIT_ID}");
				}

				//<c:if test="${LOGIN_CRED_DEPT eq '2'}">
				//	$("CRED_DEPT").enable();
				//</c:if>
	
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
		<td class="tbYellow" width='9%'>
			承辦科別
		</td>
		<td class="tbYellow2" width="13%">
			<select id="CRED_DEPT">
				<c:forEach items="${CRED_DEPT_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width='9%'>
			清償人員
		</td>
		<td class="tbYellow2" width="13%">
			<%-- [20240328] 難字調整：清償人員 --%>
			<select id="AUDIT_ID" name = "AUDIT_ID" alt="ch">
				<option value="">全部</option>
				<c:forEach items="${AUDIT_ID_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width='9%'>
			確認日期
		</td>
		<td class="tbYellow2" width="13%">
			<input name="FINAL_DATE" id="FINAL_DATE" type="text" datatype="ROCdate" size="8" maxLength ="7"/>
			<img src="<%=imageBase%>/CM/calendar.gif" height="20" onclick="getCalendarFor($('FINAL_DATE'))">
		</td>
		<td class="tbYellow" width='9%'>
			貸款帳號
		</td>
		<td class="tbYellow2" width="13%">
			<input id="LOAN_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
		</td>
		<td class="tbYellow2" width='12%' align='center'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="9" align="center">
			 <input id="BTN_print" type="button" class="button" value='列印' /> 
		</td>
	</tr>
</table>

<table id="grid" class="grid"></table>

</form>		
</body>
</html>