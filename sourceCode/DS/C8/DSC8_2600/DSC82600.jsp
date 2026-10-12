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
程式：DSC82600.jsp
功能：利率控管作業
作者：林秉宏
完成：2013/08/16

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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>		 
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC82600().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC82600(){	

		var grid;
		var valid1, valid2;
		var CONTROL_TYPE_MAP_ORIGIN = {};
		var CONTROL_TYPE_MAP = {};
		
		
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0003 : 'BTN_insert',		<%--新增--%>	
				B0054 : 'BTN_update',		<%--變更--%>	
				B0217 : 'BTN_delete'		<%--終止--%>		
			};
			<dz:grantButtons FUNC_ID='DSC82600'/>
		};
		
		// 檢核
		var initValidation = function(){	

			Validation.addAllThese( [
				[ 'chkLength', '貸款帳號需輸入且需為10碼!', function( v ) { return chkLength($F('LOAN_ID_Q'));}]
			] );
			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid1.define( "chkLength" , [{ id : "LOAN_ID_Q" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid2.define( "chkLength" , [{ id : "LOAN_ID_Q" } ] );
			valid2.define( "validate-selection" , [{ id : "CONTROL_TYPE", errMsg : '請選擇控管種類!' } ] );	
			valid2.define( "validate-selection" , [{ id : "CONTROL_SOURCE", errMsg : '請選擇控管來源!' } ] );
			valid2.define( "required" , [{ id : "BEGIN_DATE", errMsg : '請確認起始日期填寫正確!' } ] );
			valid2.define( "required" , [{ id : "END_DATE", errMsg : '請確認終止日期填寫正確!' } ] );
			valid2.define( "required" , [{ id : "CONTROL_REASON", errMsg : '請輸入控管原因!' } ] );
			valid2.define( "validate-ROCDate" , [{ id : "BEGIN_DATE" } ] );
			valid2.define( "validate-ROCDate" , [{ id : "END_DATE" } ] );
			valid2.define( "validate-ROCDate-Interval" , [{ id : "BEGIN_DATE", errMsg : '起始日期要比終止日期早!'},{ id : "END_DATE", errMsg : '起始日期要比終止日期早!'} ] );
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
			new Ajax.Request( '<%=dispatcher%>/DSC8_2600/' + actionName,
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
			//清除中間顯示區塊
			clear: function(){
				$$('#dataTable input[type="text"]','#dataTable select').each(
					function(elem){
						elem.value ='';					
					}
				);
				
				//還原到沒B、C的選項
				$('CONTROL_TYPE').options.length = 1;
				for(key in CONTROL_TYPE_MAP){
					$('CONTROL_TYPE').add(new Option(CONTROL_TYPE_MAP[key],key));
				}				
			
			},			
			
			// 查詢
			doQuery : function(){
				
				valid2.reset();
				
				// 檢核
				if(!valid1.validate()){ 
					return; 
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'LOAN_ID' : $F('LOAN_ID_Q') },
					function(resp){	
						var rtnList = resp.rtnList;
						if(rtnList && rtnList.length >= 1 && rtnList[0].CONTROL_TYPE){
							grid.load(resp.rtnList || []);
						}else{
							grid.load([]);
						}
						
						$('BORROW_NAME').innerHTML = resp.rtnList[0]['BORROW_NAME'] || '';
						$('LOAN_ID_OLD').value = resp.rtnList[0]['LOAN_ID'] || '';
						actions.clear();
					},function(resp){
						grid.load([]);
						$('LOAN_ID_Q').value = '';	
						$('LOAN_ID_OLD').value = '';
						$('BORROW_NAME').innerHTML = '';
						actions.clear();
					}
				);	
			},
			
			// 查詢清償控管資料
			doQueryC105: function(rec){
				
				//valid1.reset();
				//valid2.reset();
				
				//var chkList = grid.getCheckedRecord();

				$w('CONTROL_SOURCE CONTROL_REASON').each(
					function(id) {		
						$(id).value = rec[id] || '';						
					}
				);
					
				var CONTROL_TYPE = rec['CONTROL_TYPE'] || '';
				$('CONTROL_TYPE_OLD').value = CONTROL_TYPE || ''; 				
				$('CONTROL_TYPE').options.length = 1;
				//控管種類為B、C時，LOAD有B、C的選項 //2018-01-26申請書-修改放款契約效力：E參與分配查詢時才顯示
				if(CONTROL_TYPE == 'B' ||  CONTROL_TYPE == 'C' || CONTROL_TYPE == 'E'){

					for(key in CONTROL_TYPE_MAP_ORIGIN){
						$('CONTROL_TYPE').add(new Option(CONTROL_TYPE_MAP_ORIGIN[key],key));
					}					
					$('CONTROL_TYPE').value = CONTROL_TYPE;
					//$('CONTROL_TYPE').disable();//控管種類為B、C時不得修改。
					
				}else{
				//控管種類不為B、C時，LOAD無B、C的選項
					for(key in CONTROL_TYPE_MAP){
						$('CONTROL_TYPE').add(new Option(CONTROL_TYPE_MAP[key],key));
					}	
					$('CONTROL_TYPE').value = CONTROL_TYPE;
					//$('CONTROL_TYPE').enable();
				}
				
				$w('BEGIN_DATE END_DATE').each(
					function(id) {		
						$(id).value = toROC(rec[id] || '');						
					}
				);
				
				
				return;
				// 頁面傳入參數
				ajaxPost( 'queryC105' , { 'checkList' : Object.toJSON(chkList) },
					function(resp){				
						$w('CONTROL_TYPE CONTROL_SOURCE CONTROL_REASON').each(
							function(id) {		
								$(id).value = resp.rtnList[0][id] || '';						
							}
						);
						$w('BEGIN_DATE END_DATE').each(
							function(id) {		
								$(id).value = toROC(resp.rtnList[0][id] || '');						
							}
						);
					}
				);	
			},
			
			// 新增
			doInsert : function(){
				
				valid1.reset();
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				
				<%-- 
					[20230321]  借款人 若含有難字, 則會導致 AntiXSSRequestData$InputXSSError輸入值格式有安全性的錯誤
					移除 借款人   
				--%>
				var reqMap = {
					LOAN_ID : $F('LOAN_ID_Q'),
					// BORROW_NAME : $('BORROW_NAME').innerHTML,
					CONTROL_TYPE : $F('CONTROL_TYPE'),
					CONTROL_SOURCE : $F('CONTROL_SOURCE'),
					CONTROL_REASON : $F('CONTROL_REASON'),
					BEGIN_DATE : toY2K($F('BEGIN_DATE')),
					END_DATE : toY2K($F('END_DATE'))
				}
				
				// 頁面傳入參數
				ajaxPost( 'insert' , { 'info' : Object.toJSON(reqMap),'LOAN_ID' : $F('LOAN_ID_Q')},
					function(resp){	
						var rtnList = resp.rtnList;
						if(rtnList && rtnList.length >= 1 && rtnList[0].CONTROL_TYPE){
							grid.load(resp.rtnList || []);
						}else{
							grid.load([]);
						}
						
						$('BORROW_NAME').innerHTML = resp.rtnList[0]['BORROW_NAME'] || '';
						$('LOAN_ID_OLD').value = resp.rtnList[0]['LOAN_ID'] || '';
						actions.clear();
					},function(resp){						
						actions.clear();						
						$('LOAN_ID_OLD').value = '';
					}
				);	
			},
			
			// 變更
			doUpdate : function(){
			
				if($F('LOAN_ID_Q') != $F('LOAN_ID_OLD')){
					alert("查詢與變更時的貸款帳號不同!");
					return;
				}
						
				var chkList = grid.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請勾選一筆資料變更");
				  	return;
				}
				
				valid1.reset();
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				
				var reqMap = {
					LOAN_ID : $F('LOAN_ID_Q'),
					CONTROL_TYPE : $F('CONTROL_TYPE'),
					CONTROL_TYPE_OLD : $F('CONTROL_TYPE_OLD'),
					CONTROL_SOURCE : $F('CONTROL_SOURCE'),
					CONTROL_REASON : $F('CONTROL_REASON'),
					BEGIN_DATE : toY2K($F('BEGIN_DATE')),
					END_DATE : toY2K($F('END_DATE'))
				}
				
				// 頁面傳入參數
				ajaxPost( 'update' , { 'info' : Object.toJSON(reqMap), 'chkMap' : Object.toJSON(chkList[0]), 'LOAN_ID' : $F('LOAN_ID_Q') },
					function(resp){
						var rtnList = resp.rtnList || {};
						if(rtnList && rtnList.length >= 1 && rtnList[0].CONTROL_TYPE){
							grid.load(resp.rtnList || []);
						}else{
							grid.load([]);
						}
						
						$('BORROW_NAME').innerHTML = resp.rtnList[0]['BORROW_NAME'] || '';
						$('LOAN_ID_OLD').value = resp.rtnList[0]['LOAN_ID'] || '';
						actions.clear();
					
					},function(resp){					
						actions.clear();
						//$('LOAN_ID_OLD').value = '';
					}
				);	
			},
			
			// 終止
			doDelete : function(){
				
				// 檢核				
				var chkList = grid.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請勾選一筆資料終止");
				  	return;
				}
				
				valid1.reset();
				valid2.reset();
				
				var errMsg = '確認是否終止案件控管？';
				
				// 頁面傳入參數
				if (!errMsg || confirm(errMsg)) {
					ajaxPost( 'delete' , { 'chkMap' : Object.toJSON(chkList[0]),'LOAN_ID' : $F('LOAN_ID_Q'),'CONTROL_TYPE' : $F('CONTROL_TYPE_OLD')},
						function(resp){
							var rtnList = resp.rtnList || {};
							if(rtnList && rtnList.length >= 1 && rtnList[0].CONTROL_TYPE){
								grid.load(resp.rtnList || []);
							}else{
								grid.load([]);
							}
							
							$('BORROW_NAME').innerHTML = resp.rtnList[0]['BORROW_NAME'] || '';
							$('LOAN_ID_OLD').value = resp.rtnList[0]['LOAN_ID'] || '';
							actions.clear();
						
						},function(resp){
							actions.clear();
							//$('LOAN_ID_OLD').value = '';
						}
					);	
				}
			}
					
		};
		
		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSC82600' ,
					'變更作業' , 
					'利率控管作業'
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
						autoCheckBox:{isSelectAll:true, type:'radio', 
						    action:function(node, boxStatus, records ){
								actions.doQueryC105(records[0]);
							}
						},
						column:[
							{header:'起始日期', key:'BEGIN_DATE',
								render:function( record, value ){								
									return Date.toROC(value)||'';
								}
							},
							{header:'終止日期', key:'END_DATE',
								render:function( record, value ){								
									return Date.toROC(value)||'';
								}
							},
							{header:'輸入人員', key:'INPUT_NM'},
							{header:'控管種類', key:'CONTROL_TYPE_NM'},
							{header:'控管來源', key:'CONTROL_SOURCE_NM'},
							{header:'控管原因', key:'CONTROL_REASON'}
						]						
					}
				);				
					
				initValidation();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
				
				// 新增
				$('BTN_insert').observe('click', actions.doInsert);
				
				// 變更
				$('BTN_update').observe('click', actions.doUpdate);
				
				// 終止
				$('BTN_delete').observe('click', actions.doDelete);
				
				//控管種類下拉選單(沒去掉B、C選項)
				<c:forEach var="map" items="${CONTROL_TYPE_LIST_ORIGIN}">
					CONTROL_TYPE_MAP_ORIGIN['${map.key}']='${map.value}';
				</c:forEach>
				
				//控管種類下拉選單(去掉B、C選項)
				<c:forEach var="map" items="${CONTROL_TYPE_LIST}">
					CONTROL_TYPE_MAP['${map.key}']='${map.value}';
				</c:forEach>
				
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
		<td class="tbYellow2" width="25%">
			<input id="LOAN_ID_Q" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="LOAN_ID_OLD" type="hidden">
		</td>
		<td class="tbYellow" width='10%'>
			借款人
		</td>
		<td class="tbYellow2" width="25%">
			<span id="BORROW_NAME" style="font-family: 'EUDC'"></span> <%-- [20230321] --%>
		</td>
		<td class="tbYellow2" width='30%' align='center'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
			<input id="BTN_insert" type="button" value="新增" class="button"> 
			<input id="BTN_update" type="button" value="變更" class="button"> 
			<input id="BTN_delete" type="button" value="終止" class="button">
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="dataTable">
	<tr>
		<td class="tbBox3" align="center" colspan="6">
		</td>
	</tr>
	<tr>
		<input type="hidden" id="CONTROL_TYPE_OLD" value="">
		<td class="tbYellow" width='10%'>
			控管種類
		</td>
		<td class="tbYellow2" width="23%">
			<select id="CONTROL_TYPE">	
				<option value="">請選擇</option>			
				<c:forEach items="${CONTROL_TYPE_LIST}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
		<td class="tbYellow" width='10%'>
			控管來源
		</td>
		<td class="tbYellow2" width="23%">
			<select id="CONTROL_SOURCE">	
				<option value="">請選擇</option>			
				<c:forEach items="${CONTROL_SOURCE_LIST}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
		<td class="tbYellow" width='10%'>
			控管原因
		</td>
		<td class="tbYellow2" width="23%">
			<input id="CONTROL_REASON" type="text" class="textBox2" size="40" alt="ch" /> <%-- [20230321] --%>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			起始日期
		</td>
		<td class="tbYellow2">
			<input id="BEGIN_DATE" type="text" datatype="ROCdate" size="9" maxLength ="7"/>
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('BEGIN_DATE'))" />
		</td>
		<td class="tbYellow">
			終止日期
		</td>
		<td class="tbYellow2" colspan="3">
			<input id="END_DATE" type="text" datatype="ROCdate" size="9" maxLength ="7"/>
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('END_DATE'))" />
		</td>
	</tr>
	<tr>
		<td class="tbBox3" align="center" colspan="6">
			案件控管明細查詢
		</td>
	</tr>
</table>

<table id="grid" class="grid"></table>

</form>		
</body>
</html>