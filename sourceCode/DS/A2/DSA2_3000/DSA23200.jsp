<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<!--
程式：DSA23200.jsp
功能：照會情形維護作業
作者：林秉宏
完成：2014/01/02
      2019/09/19業務員簡訊改推播

[20240729] 修改件 陳勁谷 難字修改
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
<script type="text/JavaScript" src='<%=htmlBase%>/CM/js/calendar.js'></script><%-- 日曆用 --%>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSA23200().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSA23200(){	

		var grid;
		var valid1, valid2;
		var MSG;
		
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0003 : 'BTN_insert',		<%--新增--%>	
				B0004 : 'BTN_update',		<%--修改--%>	
				B0005 : 'BTN_delete'		<%--刪除--%>	
			};
			<dz:grantButtons FUNC_ID='DSA23200'/>
		};
		
		// 檢核
		var initValidation = function(){	
		
			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkLength', '請輸入正確受理編號查詢!', function( v ) { return chkLength($F('APPLY_ID'));}]
			] );
			valid1.define( "chkLength" , [{ id : "APPLY_ID" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid2.define('validate-selection' , [{ id : "STATUS" , errMsg:"請選擇照會情形!"}] );
			valid2.define('validate-ROCDate' , [{ id : "GUAR_DATE" , errMsg:"約定對保日請輸入正確日期格式!"}] );
		};
		
		// 檢核受理編號長度
		var chkLength = function (APPLY_ID) 
		{		
			var chk = true;
			if(APPLY_ID.length != 11) {
				chk = false; 
			}
			return chk; 	
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSA2_3200/' + actionName,
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
				valid2.reset();
				if(!valid1.validate()){ 
					return; 
				}

				//保留參數管理-更新受理編號
				CSRUtil.keepParamsManager.put({'APPLY_ID': $F('APPLY_ID') });

				// 頁面傳入參數
				ajaxPost( 'query' , { 'APPLY_ID' : $F('APPLY_ID') },
					function(resp){		
						var rtnList = resp.rtnList;
						grid.load(rtnList || []);
						$('OLD_APPLY_ID').value = $F('APPLY_ID');
						$('BORROW_NAME').setValue(rtnList[0]['BORROW_NAME'] || '');
						MSG = resp.MSG;				
					},function(resp){
						grid.load([]);
						$('OLD_APPLY_ID').value = $F('APPLY_ID');
						$('BORROW_NAME').setValue('');	
						MSG = '';
					}
				);	
			},
			
			// 新增
			doInsert : function(){
				
				valid1.reset();
				if(!valid2.validate()){ 
					return; 
				}
				
				var APPLY_ID = $F('APPLY_ID');
				var OLD_APPLY_ID = $F('OLD_APPLY_ID');		
				if(APPLY_ID != OLD_APPLY_ID){
					alert("受理編號與原先查詢的資料不同，無法作業!");
					return;
				}
				
				if($F('STATUS') =='5'){
					// IF照會情形下拉選單為”已約定對保日" THEN 約定對保日欄位不可為空白 
					if($F('GUAR_DATE') == ''){
						alert("約定對保日欄位不可為空白!");
						return;
					}		 		
				}else if($F('STATUS') =='6'){
					// IF照會情形下拉選單為”其他” THEN 備註欄位不可為空白 	
					if($F('NOTE') == ''){
						alert(" 備註欄位不可為空白!");
						return;
					}
				}				
	
				ajaxPost( 'insert', {'info' : Object.toJSON(reqMap())}
					,function(resp){
						var rtnList = resp.rtnList;
						grid.load(rtnList || []);
						clearTable();
						$('BORROW_NAME').setValue(rtnList[0]['BORROW_NAME'] || '');
					}
				);
			},
			
			// 修改
			doUpdate : function(){
				
				valid1.reset();
				if(!valid2.validate()){ 
					return; 
				}
				
				var checkList = grid.getCheckedRecord();
				if (checkList.length == 0){
					alert('請先選取再執行修改作業');	
					return;
				}	
				
				if($F('STATUS') =='5'){
					// IF照會情形下拉選單為”已約定對保日" THEN 約定對保日欄位不可為空白 
					if($F('GUAR_DATE') == ''){
						alert("約定對保日欄位不可為空白!");
						return;
					}		 		
				}else if($F('STATUS') =='6'){
					// IF照會情形下拉選單為”其他” THEN 備註欄位不可為空白 	
					if($F('NOTE') == ''){
						alert(" 備註欄位不可為空白!");
						return;
					}
				}				
	
				ajaxPost( 'update', {'info' : Object.toJSON(reqMap())}
					,function(resp){
						var rtnList = resp.rtnList;
						grid.load(rtnList || []);
						clearTable();
						$('BORROW_NAME').setValue(rtnList[0]['BORROW_NAME'] || '');
					}
				);
			},
			
			// 刪除
			doDelete : function(){
				
				valid1.reset();
				valid2.reset();
				
				var APPLY_ID = $F('APPLY_ID');
				var OLD_APPLY_ID = $F('OLD_APPLY_ID');		
				if(APPLY_ID != OLD_APPLY_ID){
					alert("受理編號與原先查詢的資料不同，無法作業!");
					return;
				}	
	
				ajaxPost( 'delete', {'info' : Object.toJSON(reqMap())}
					,function(resp){
						var rtnList = resp.rtnList;
						grid.load(rtnList || []);
						clearTable();
						$('BORROW_NAME').setValue(rtnList[0]['BORROW_NAME'] || '');						
					}
				);
			},
			
			// 推播發送
			doSendmsg : function(){
				
				valid1.reset();
				//發送推播時新增檢核人事檔手機與受理檔聯絡人手機，若不符合則提示確認訊息
				if (MSG){
					if (!confirm(MSG)){
						return;
					}
				}
	
				ajaxPost( 'sendmsg', {'info' : Object.toJSON(reqMap())}
					,function(resp){
					    var rtnList = resp.rtnList;
						grid.load(rtnList || []);
						clearTable();
						$('BORROW_NAME').setValue(rtnList[0]['BORROW_NAME'] || '');
					}
				);
			}
		};
		
		//產生查詢回傳資料(B區塊)
		var reqMap = function(){
		
			var reqMap = {};
			var reqMap={
				'OLD_APPLY_ID': $('OLD_APPLY_ID').value,
				'GUAR_DATE': toY2K($('GUAR_DATE').value),
				'STATUS': $('STATUS').value,
				'NOTE': $('NOTE').value,
				'SEQ_NO' : $('SEQ_NO').value,
				'MSG_TYPE': $('MSG_TYPE').value,
				'BORROW_NAME': $('BORROW_NAME').getValue()
			};
			return reqMap;	
		};
		
		// 點選連動帶出資料
		var getData = function(record){

			$('GUAR_DATE').value = toROC(record.GUAR_DATE||'');
			$('STATUS').value = record.STATUS || '';
			$('NOTE').value = record.NOTE||'';
			$('SEQ_NO').value = record.SEQ_NO||'';
		}
		
		// 清空欄位
		var clearTable = function(){
			$w('STATUS GUAR_DATE NOTE MSG_TYPE').each( 
				function(ele) { 
					$(ele).value = ''; 
			});	
			
			$('BORROW_NAME').setValue('');
		}
		
		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSA23200' ,
					'核貸作業' , 
					'照會情形維護作業'
				);	
				
				grid = new TableUI({
					table: $('grid'), pageSize: 20, allSortable: true,overDiv:false,
					autoCheckBox:{
						text:'選取', 
						type:'radio',
						action:function(node, boxStatus, records ){
							getData(records[0]);
						}
					},
					column: [
						{header:"序號", key:'SEQ_NO'},
						{header:"約定對保日", key:'GUAR_DATE',
							render : function (rec , val){
								return Date.toROC(val || "");
						}},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
					    {header:"異動人員", key:'INPUT_NAME', attrs: {style:"font-family:'EUDC'"}},
						{header:"異動日期", key:'INPUT_DATE',
							render : function (rec , val){
								return Date.toROC(val || "");
						}},
						{header:"異動種類", key:'INPUT_KIND_NM'}, 
						{header:"照會情形(備註)", key:'STATUS_NM', attrs: {style:"font-family:'EUDC'",align:"left"}}						
					]	
				});			
						
				initValidation();
				buttonAuth();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
				
				// 新增
				$('BTN_insert').observe('click', actions.doInsert);
				
				// 修改
				$('BTN_update').observe('click', actions.doUpdate);
				
				// 刪除
				$('BTN_delete').observe('click', actions.doDelete);

                // 推播發送
				$('BTN_sendmsg').observe('click', actions.doSendmsg);

				//保留參數管理-取得受理編號
				APPLY_ID = CSRUtil.keepParamsManager.get('APPLY_ID');
				$('APPLY_ID').value = APPLY_ID;
				
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
		<td class="tbYellow" width="10%">
			受理編號
		</td>
		<td class="tbYellow2" width="20%">
			<input id="APPLY_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="15" maxlength="11"/>
			<input id="OLD_APPLY_ID" type="hidden">
			<input id="SEQ_NO" type="hidden"/>
		</td>
		<td class="tbYellow" width="10%">
		          借款人姓名
		</td>	
		<td class="tbYellow2" width="20%" >
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			<input id="BORROW_NAME" alt="ch" readonly/>
		</td> 
		<td class="tbYellow2" width="40%" align="left">
			<input id="BTN_query" type="button" value="查詢" class="button"> 
		</td>
	</tr>
	<tr>					
		<td class="tbYellow" width= "10%">
			推播發送
		</td>
		<td class="tbYellow2" width="20%" align="left">
			<select id="MSG_TYPE">	
				<c:forEach items="${MSG_TYPE_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>		
		</td>	
		<td class="tbYellow2" colspan="3" align="left">
			<input id="BTN_sendmsg" type="button" class="button" value='推播發送' />  
		</td>
	</tr>			
	<tr>
		<td class="tbYellow1" colspan="5" align="center">
			<input id="BTN_insert" type="button" class="button" value='新增' /> 
			<input id="BTN_update" type="button" class="button" value='修改' /> 
			<input id="BTN_delete" type="button" class="button" value='刪除' /> 
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>					
		<td class="tbYellow" width= "10%">
			照會情形
		</td>
		<td class="tbYellow2" width= "20%" >
			<select id="STATUS">	
				<c:forEach items="${STATUS_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>		
		</td>
		<td class="tbYellow" width="10%">
			約定對保日
		</td>
		<td class="tbYellow2" width="20%">
			<input id="GUAR_DATE" name="GUAR_DATE" datatype="ROCDate" type="text" class="textBox2" size="9" maxlength="7" value="${START_DATE}">
			<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('GUAR_DATE'))">		
		</td>
		<td class="tbYellow" width="10%">
			備註
		</td>
		<td class="tbYellow2" width="30%">
			<input id="NOTE" type="text" class="textBox2" maxlength="200" size="40">
		</td>				
	</tr>
</table>

<table id="grid" class="grid"></table>

</form>		
</body>
</html>