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
程式：DSC82200.jsp
功能：ID改號作業
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
	Event.observe(window, 'load', new DSC82200().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC82200(){	

		var grid;
		var valid1, valid2, valid3;
		
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0054 : 'BTN_update',		<%--變更--%>		
				B0005 : 'BTN_delete',		<%--刪除--%>
				B0070 : 'BTN_confirm'		<%--覆核--%>
			};
			<dz:grantButtons FUNC_ID='DSC82200'/>
		};
		
		// 檢核
		var initValidation = function(){	

			Validation.addAllThese( [
				[ 'chkLength1', '舊ID長度需為8碼或10碼!', function( v ) { return chkLength($F('old_ID'));}],
				[ 'chkLength2', '新ID長度需為8碼或10碼!', function( v ) { return chkLength($F('new_ID'));}],
				[ 'checkID',  '', 
					function(v){					  
						return validation.checkROCID(v) ||  validation.checkUniSN(v);						
					}
				],
			] );
			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid1.define( "chkLength1" , [{ id : "old_ID" } ] );
			//20160503有舊件資料身分證字號不符合規則,故將此規則刪除,避免變更時,無法變更
			//valid1.define( "checkID" , [{ id : "old_ID", errMsg : '舊身分證字號不符規則!' } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid2.define( "chkLength2" , [{ id : "new_ID" } ] );
			
			valid3 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid3.define( "checkID" , [{ id : "new_ID", errMsg : '新身分證字號不符規則!' } ] );	
		};
		
		// 檢核帳號長度
		var chkLength = function (ID) 
		{		
			var chk = true;
			if(ID && (ID.length != 10 && ID.length !=8)) {
				chk = false; 
			}
			return chk; 	
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC8_2200/' + actionName,
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
				valid3.reset();
				
				// 檢核
				if(!valid1.validate()){ 
					return; 
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'old_ID' : $F('old_ID') },
					function(resp){			
						grid.load(resp.rtnList || []);
						$('old_ID_OLD').value = resp.old_ID;	
						if("Y" == resp.UNCONFIRM){						
							$('new_ID').value = resp.ID2||'';
							$('new_NAME').value = resp.NAME2;
							//2019-07-02 新增姓名(羅馬拼音)new_NAME_RM
							$('new_NAME_RM').value = resp.NAME2_RM;
							$('CHG_REASON').value = resp.REASON;
							$('MEMO').value = resp.MEMO;
							$('new_ID').disabled=true;
							$('new_NAME').disabled=true;
							$('new_NAME_RM').disabled=true;
							$('CHG_REASON').disabled=true;
							$('MEMO').disabled=true;
						} else {
							$('new_ID').value = '';
							$('new_NAME').value = '';
							//2019-07-02 新增姓名(羅馬拼音)new_NAME_RM
							$('new_NAME_RM').value = '';
							$('CHG_REASON').value = 'A';
							$('MEMO').value = '';
							$('new_ID').disabled=false;
							$('new_NAME').disabled=false;
							$('new_NAME_RM').disabled=false;
							$('CHG_REASON').disabled=false;
							$('MEMO').disabled=false;
						}									
					},function(resp){
						grid.load([]);
						$('new_ID').value = '';
						$('new_NAME').value = '';
						//2019-07-02 新增姓名(羅馬拼音)new_NAME_RM
						$('new_NAME_RM').value = '';
						$('CHG_REASON').value = 'A';
						$('MEMO').value = '';
						$('new_ID').disabled=false;
						$('new_NAME').disabled=false;
						$('new_NAME_RM').disabled=false;
						$('CHG_REASON').disabled=false;
						$('MEMO').disabled=false;
					}
				);	
			},
			
			// 變更
			doUpdate: function(){
				
				// 檢核				
				var dataList = grid.getAllRecords();
				if(dataList.length==0){
					alert("請先查詢再做變更!");
					return;
				}
	
				if($F('old_ID') != $F('old_ID_OLD')){
					alert("欲變更的舊ID(畫面上的舊ID)與原先查詢的舊ID(原查詢舊ID)不一致,請檢查!");
					return;
				}
				//2019-07-02 新增姓名(羅馬拼音)new_NAME_RM
				if(!$F('new_ID') && !$F('new_NAME') && !$F('new_NAME_RM')){
					alert("請輸入新ID或新名字");
					return;
				}
				
				if ($F('old_ID').length == 10) {
					var old_ID2 = $F('old_ID').substring(1,2);
					var new_ID2 = $F('new_ID').substring(1,2);	
		            if($F('new_ID')){	
			            if(old_ID2 != new_ID2){
						  	if(!confirm("變更ID之性別有誤，請確認是否為變性人?")){
								return;
							}
						}
					}
				}
				
				if(!confirm("若有有效火單請至產險出批改單，避免續保資料錯誤!")){
					return;
				}
				
				valid1.reset();
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				if($F('new_ID')){
					if(!valid3.validate()){ 
						return; 
					}
				} else {
					valid3.reset();
				}
								
				var reqMap = {
					old_ID : $F('old_ID'),
					CHG_REASON : $F('CHG_REASON'),
					new_ID : $F('new_ID'),
					new_NAME : $F('new_NAME'),
					//2019-07-02 新增姓名(羅馬拼音)new_NAME_RM
					new_NAME_RM : $F('new_NAME_RM'),
					MEMO  : $F('MEMO')
				}
				
				// 頁面傳入參數
				ajaxPost( 'update' , { 'info' : Object.toJSON(reqMap), 'rtnList' : Object.toJSON(dataList) },
					function(resp){
						grid.load([]);
					}
				);	
			},
						//刪除
			doDelete: function(){				
				// 檢核				
				var dataList = grid.getAllRecords();
				if(dataList.length==0){
					alert("請先查詢再做刪除!");
					return;
				}
	
				if($F('old_ID') != $F('old_ID_OLD')){
					alert("欲變更的舊ID(畫面上的舊ID)與原先查詢的舊ID(原查詢舊ID)不一致,請檢查!");
					return;
				}
				
				valid1.reset();
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				if($F('new_ID')){
					if(!valid3.validate()){ 
						return; 
					}
				} else {
					valid3.reset();
				}
								
				var reqMap = {
					old_ID : $F('old_ID'),
					CHG_REASON : $F('CHG_REASON'),
					new_ID : $F('new_ID'),
					new_NAME : $F('new_NAME'),
					//2019-07-02 新增姓名(羅馬拼音)new_NAME_RM
					new_NAME_RM : $F('new_NAME_RM'),
					MEMO  : $F('MEMO')
				}
				
				// 頁面傳入參數
				ajaxPost( 'delete' , { 'info' : Object.toJSON(reqMap), 'rtnList' : Object.toJSON(dataList) },
					function(resp){
						grid.load([]);
					}
				);	
			},
			//覆核
			doConfirm: function(){				
				// 檢核				
				var dataList = grid.getAllRecords();
				if(dataList.length==0){
					alert("請先查詢再做覆核!");
					return;
				}
	
				if($F('old_ID') != $F('old_ID_OLD')){
					alert("欲變更的舊ID(畫面上的舊ID)與原先查詢的舊ID(原查詢舊ID)不一致,請檢查!");
					return;
				}
				
				valid1.reset();
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				if($F('new_ID')){
					if(!valid3.validate()){ 
						return; 
					}
				} else {
					valid3.reset();
				}
								
				var reqMap = {
					old_ID : $F('old_ID'),
					CHG_REASON : $F('CHG_REASON'),
					new_ID : $F('new_ID'),
					new_NAME : $F('new_NAME'),
					//2019-07-02 新增姓名(羅馬拼音)new_NAME_RM
					new_NAME_RM : $F('new_NAME_RM'),
					MEMO  : $F('MEMO')
				}
				
				// 頁面傳入參數
				ajaxPost( 'confirm' , { 'info' : Object.toJSON(reqMap), 'rtnList' : Object.toJSON(dataList) },
					function(resp){
						grid.load([]);
					}
				);	
			}
			
		};
		
		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSC82200' ,
					'變更作業' , 
					'ID改號作業'
				);			
				
				// 產生 grid 物件	
				grid = new TableUI(
					{	
						table: $('grid'), allSortable:false, overDiv:true,
						<%-- [20230321] --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header:'作業端', key:'TYPE_NM'},
							{header:'受理編號', key:'APPLY_ID'},
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:'關係', key:'RELATION_NM'},
							{header:'客戶關係人姓名', key:'NAME1'},
							{header:'客戶關係人姓名(羅馬拼音)', key:'NAME1_RM'},
							{header:'客戶關係人ID', key:'ID1'}
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
				
				// 覆核
				$('BTN_confirm').observe('click', actions.doConfirm);
				
				// 改號原因：不雅改號
				$('CHG_REASON').value = "A";
				
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
			舊ID
		</td>
		<td class="tbYellow2" width="70%">
			<input id="old_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="old_ID_OLD" type="hidden">
		</td>
		<td class="tbYellow2" width='20%' align='center'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5" align="center">
			 <input id="BTN_update" type="button" class="button" value='變更' /> 		
			 <input id="BTN_delete" type="button" class="button" value='刪除' /> 		
			 <input id="BTN_confirm" type="button" class="button" value='覆核' /> 
		</td>
	</tr>	
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" rowspan="2" width='10%'>
			新ID
		</td>
		<td class="tbYellow2" rowspan="2" width="15%">
			<input id="new_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
		</td>
		<td class="tbYellow" width='10%'>
			新名字
		</td>
		<td class="tbYellow2" width="15%">
			<input id="new_NAME" type="text" class="textBox2 checkInputLength" size="15"  maxlength="100" fieldName="新名字" alt="ch" /> <%-- [20230321] --%>
		</td>
		<td class="tbYellow" width='10%'>
			改號原因
		</td>
		<td class="tbYellow2" width="15%">
			<select id="CHG_REASON" name="CHG_REASON">				
				<c:forEach items="${CHG_REASON_LIST}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
		
	</tr>
	
	<tr>
		<!--2019-07-02 新增欄位-->
		<td class="tbYellow" width='10%'>
			新名字(羅馬拼音)
		</td>
		<td class="tbYellow2" width="15%">
			<input id="new_NAME_RM" type="text" class="textBox2 checkInputLength hasFullType" size="15" maxlength="100" fieldName="新名字(羅馬拼音)" />
		</td>
		<td class="tbYellow" width='10%'>
			原因說明
		</td>
		<td class="tbYellow2" width="15%">
			<input id="MEMO" type="text" class="textBox2" size="25" alt="ch" /> <%-- [20230321] --%>
		</td>
		
		
	</tr>
</table>

<table id="grid" class="grid"></table>

</form>		
</body>
</html>