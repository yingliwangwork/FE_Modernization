<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSD11803.jsp
作者：余凱鈞
功能：催收情形維護作業
完成：2013/08/28

[20240326]
難字調整
高強禾
 -->	

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script> 			<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<%-- [20240326] 難字調整 --%>
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
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSD11803().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD11803(){
	var grid;
	var valid;
	var valid1;
	
	function buttonAuth(){
		var authButtons = {	
			B0003:"btn_INSERT",
			B0004:"btn_UPDATE",
			B0005:"btn_DELETE" 
		};
		<dz:grantButtons FUNC_ID="DSD11803" />
	}

	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSD1_1803/');
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		ajaxRequest.post( actionName, params, successFunction , errorFunction);
	
	}		
	
	
	//新增、修改用檢核
	function initValidation(){	
	
		Validation.addAllThese([	
			[ 'chkLOAN_ID',  '貸款帳號長度須為10位', 
				function(v){
					if(v.length=='10' ){
						return true;
					}	
				return false;
			}]
		]);
		valid = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});				
		valid.define( "validate-selection", { id: "STATUS" , errMsg:"催收情況不可空白!" } );	
		
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});	
		valid1.define( "required" , { id: 'LOAN_ID_QUERY' , errMsg:"貸款帳號不可空白!" } );
		valid1.define( "chkLOAN_ID" , { id: 'LOAN_ID_QUERY' } );	
	}
	
	//點選連動帶出資料
	function getData(record){
		
		$('LOAN_STATUS').value = record.LOAN_STATUS || '';
		$('STATUS').value = record.STATUS || '';
		$('DUE_DATE').value = toROC(record.DUE_DATE||'');
		$('NOTE').value = record.NOTE||'';
		$('SEQ_NO').value = record.SEQ_NO||'';
	}
	
	function clearTable(){
		$w('STATUS DUE_DATE NOTE').each( 
			function(ele) { 
				$(ele).value = ''; 
		});	
	}
	
		
	var buttons = {	
		doQuery : function(){ //查詢
			
			var LOAN_ID = $F('LOAN_ID');
			if(!LOAN_ID){
				if(!valid1.validate()){
					return;
				}
				
			}
			
			ajaxPost( 'query', {LOAN_ID : $F('LOAN_ID_QUERY')||$F('LOAN_ID')}
				,function(resp){			

					grid.load(resp.rtnList || []);
					$('LOAN_ID').value = $F('LOAN_ID_QUERY')||$F('LOAN_ID');
				},function(resp){
					grid.load([]);
					$('LOAN_ID').value = $F('LOAN_ID_QUERY')||$F('LOAN_ID');
				}
			);
		},
		doInsert : function(){ //新增
			
			valid.reset();
			valid.clear();
			
			//IF催收情形下拉選單為”已約定繳款日” THEN 約定繳款日欄位不可為空白 
			if($F('STATUS') =='6'){
				valid.define( "required", { id: "DUE_DATE" , errMsg:"約定繳款日不可空白!" } );		
			//IF催收情形下拉選單為”其他” THEN 備註欄位不可為空白 		
			}else if($F('STATUS') =='7'){
				valid.define( "required", { id: "NOTE" , errMsg:"備註欄位不可為空白!" } );				
			//IF催收情形下拉選單為”書面通知” && C100.LOAN_STATUS < 22 THEN 顯示錯誤訊息”擔保品尚未拍賣，催收情形不可為書面通知”
			}else if($F('STATUS') =='8' && CSRUtil.getNumber($F('LOAN_STATUS')) < 22){
				valid.define( "required", { id: "STATUS" , errMsg:"擔保品尚未拍賣，催收情形不可為書面通知!" } );	
			}
			valid.define( "validate-ROCDate" , [{ id : "DUE_DATE" , errMsg:"約定繳款日須符合民國年月日格式!" } ] );
					
			if(!valid.validate()){
				return;
			}
			var reqMap={};
			$('table').select('input[type!=button]','select').each(function(ele){						
				reqMap[ele.id] = ele.value;
			});
			
			reqMap.DUE_DATE = toY2K($('DUE_DATE').value || '');	

			ajaxPost( 'insert', {reqMap : Object.toJSON(reqMap)}
				,function(resp){
					grid.load(resp.rtnList);
					clearTable();
				}
			);
		},
		doUpdate : function(){ //修改
			
			valid.reset();
			valid.clear();
			
			var checkedRecord = grid.getCheckedRecord();
			//檢核是否勾選一筆資料
			if(!checkedRecord.length==1){
				alert("請選取一筆資料");
				return;
			}			
			//IF催收情形下拉選單為”已約定繳款日” THEN 約定繳款日欄位不可為空白 
			if($F('STATUS') =='6'){
				valid.define( "required", { id: "DUE_DATE" , errMsg:"約定繳款日不可空白!" } );		
			//IF催收情形下拉選單為”其他” THEN 備註欄位不可為空白 		
			}else if($F('STATUS') =='7'){
				valid.define( "required", { id: "NOTE" , errMsg:"備註欄位不可為空白!" } );				
			//IF催收情形下拉選單為”書面通知” && C100.LOAN_STATUS < 22 THEN 顯示錯誤訊息”擔保品尚未拍賣，催收情形不可為書面通知”
			}else if($F('STATUS') =='8' && CSRUtil.getNumber($F('LOAN_STATUS')) < 22){
				valid.define( "required", { id: "STATUS" , errMsg:"擔保品尚未拍賣，催收情形不可為書面通知!" } );	
			}
			
			valid.define( "validate-ROCDate" , [{ id : "DUE_DATE" , errMsg:"約定繳款日須符合民國年月日格式!" } ] );
			
			if(!valid.validate()){
				return;
			}

			var reqMap={};
			$('table').select('input[type!=button]','select').each(function(ele){						
				reqMap[ele.id] = ele.value;
			});
			
			
			reqMap.DUE_DATE = toY2K($('DUE_DATE').value || '');	
		
			ajaxPost( 'update', {reqMap : Object.toJSON(reqMap)}
				,function(resp){
					grid.load(resp.rtnList);
					clearTable();
				}
			);
			
		},
		doDelete : function(){ //刪除
			var checkedRecord = grid.getCheckedRecord();
			//檢核是否勾選一筆資料
			if(!checkedRecord.length==1){
				alert("請選取一筆資料");
				return;
			}
			
			var reqMap={
				'LOAN_ID' : checkedRecord[0].LOAN_ID,
				'SEQ_NO' : checkedRecord[0].SEQ_NO	
			};
			
			ajaxPost( 'delete', {reqMap : Object.toJSON(reqMap)}
				,function(resp){
					grid.load(resp.rtnList);
					clearTable();
				}
			);
		}			
	};

	return{	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSD11803" , "催收作業" , "催收紀錄" ,0,true);
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: true,overDiv:false,
				autoCheckBox:{
					text:'選取', 
					type:'radio',
					action:function(node, boxStatus, records ){
						getData(records[0]);
					}
				},
				<%-- [20240326] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: [
					{header:"序號", key:'SEQ_NO'},
					{header:"約定繳款日", key:'DUE_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					<%-- [20240326] 難字調整 --%>
				    {header:"催收人員", key:'INPUT_ID_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"催收日期", key:'INPUT_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"催收情況-備註", key:'STATUS_NM', attrs: {align:"left"},
						render : function (rec , val){
							if(val){
								return (val+" - "+(rec.NOTE || ''));
							}else{
								return '';
							}
					}}						
				]	
			});
			
			
			if($F('LOAN_ID')){
				ajaxRequest.closeSuccMsg();
				buttons.doQuery(); //初始查詢
			}else{
				$('new_query').show();
			}
						
			
			$('btn_QUERY').observe('click',buttons.doQuery);
			$('btn_INSERT').observe('click',buttons.doInsert);
			$('btn_UPDATE').observe('click',buttons.doUpdate);
			$('btn_DELETE').observe('click',buttons.doDelete);
			
			initValidation();
			buttonAuth();
			displayMessage();
			PageUI.resize();
		}
	};	
}
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
		<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr id="new_query" style="display:none">
				<td class="tbYellow" width= "10%" align="center">貸款帳號</td>
				<td class="tbYellow2" colspan='2'>
					<input id="LOAN_ID_QUERY"  type="text" class="textBox2" maxlength="10" size="12" onblur="this.value = this.value.toUpperCase()">
				</td>
				<td class="tbYellow">
					<input id="btn_QUERY" type="button" class="button" value="查詢">
				</td>
			</tr>
			<tr>
				<td align="center" colspan='4'>
					<input id="btn_INSERT" type="button" class="button" value="新增">
					<input id="btn_UPDATE" type="button" class="button" value="修改">
					<input id="btn_DELETE" type="button" class="button" value="刪除">
				</td>
			</tr>			
			<tr>					
				<td class="tbYellow" width= "10%" align="center">催收情形</td>
				<td class="tbYellow2" width= "10%" >
					<select id="STATUS" class="areaB">
					<c:forEach var="map" items="${STATUS_List}">
					<option value="<c:out value='${map.key}'/>"><c:out value="${map.value}" /></option>
					</c:forEach></select>
					
				</td>
				<td class="tbYellow" width="10%" align='center'>約定繳款日</td>
				<td class="tbYellow2" width="10%">
					<input name="DUE_DATE" id="DUE_DATE" datatype="ROCdate" type="text" class="textBox2 " size="8" maxlength="7" />
					<img src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('DUE_DATE'))" /></td>		
				</td>
				</tr>
				<tr>
				<td class="tbYellow" width="10%" align='center'>備註</td>
				<td class="tbYellow2"  colspan="3">
					<input id="NOTE"  type="text" class="textBox2" maxlength="280" size="80">
				</td>				
			</tr>
			<input type="hidden" id="LOAN_ID" name="LOAN_ID" value='${LOAN_ID}' />
			<input type="hidden" id="SEQ_NO" name="SEQ_NO" value='' />
			<input type="hidden" id="LOAN_STATUS" value='' />
		</table>
    <form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="grid" width="100%" class="grid" ></table>
	</form>
</body>
</html>		