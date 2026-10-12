<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--
程式：DSD40600.jsp
作者：余凱鈞
功能：清償證明狀態查詢作業
完成：2013/09/05

[20240328]
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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<!--自行定義的javaScript-->	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
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
<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSD40600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD40600(){
	var grid;
	var valid;

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD4_0600/" + actionName,
			{  
				parameters: params, 
				onSuccess:function(response){
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){	
						if(successFunction){
							successFunction(resp);
						}
					}else{
						if(errorFunction){
							errorFunction(resp);
						}
					}
				}			
			});
	}
	
	//檢核
	function initValidation(){
		valid = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});	
		valid.define( "required" , { id: "qCRED_DEPT" , errMsg:"請輸入承辦科別!" } );	
		valid.define( "required" , { id: "FINAL_DATE" , errMsg:"請輸入確認日期!" } );
	}
				
	var buttons = {	
		doQuery : function(){ //查詢
		
			if(!valid.validate()){
				return;
			}	
			
			var reqMap = {
				'CRED_DEPT' : $('qCRED_DEPT').value,
				'FINAL_DATE' : toY2K($('FINAL_DATE').value || '')					
			};
			
			ajaxPost( 'query', {reqMap : Object.toJSON(reqMap)}
				,function(resp){
					grid.load(resp.rtnList);
				},function(){
					grid.load();
				}
			);
		}			
	};

	return{	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSD40600" , "清償作業" , "證明狀態查詢" ,1);
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: true,	
				<%-- [20240328] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: [
					{header:"帳號", key:'LOAN_ID'},
					<%-- [20240328] 難字調整：姓名、輸入人員、輸入覆核、資管科經辦、資管科覆核 --%>
				    {header:"姓名", key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" },
						render : function (rec , val){
							return val ? CSRUtil.maskHandler.getMaskName(val) : '';
					}},
					{header:"輸入人員", key:'INPUT_ID_NAME', attrs:{ style:"font-family:'EUDC'" },
						render : function (rec , val){
							return val ? CSRUtil.maskHandler.getMaskName(val) : '';
					}},
					{header:"輸入覆核", key:'INPUT_LEADER_NAME', attrs:{ style:"font-family:'EUDC'" },
						render : function (rec , val){
							return val ? CSRUtil.maskHandler.getMaskName(val) : '';
					}},
					{header:"資管科經辦", key:'CHECK_ID_NAME', attrs:{ style:"font-family:'EUDC'" },
						render : function (rec , val){
							return val ? CSRUtil.maskHandler.getMaskName(val) : '';
					}},
					{header:"資管科覆核", key:'CHECK_LEADER_NAME', attrs:{ style:"font-family:'EUDC'" },
						render : function (rec , val){
							return val ? CSRUtil.maskHandler.getMaskName(val) : '';
					}},
					{header:"確認日期", key:'FINAL_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"開立日期", key:'OPEN_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"領迄日期", key:'GET_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}}						
				]	
			});

			$('btn_QUERY').observe('click',buttons.doQuery);							

			initValidation();
			PageUI.resize();
			displayMessage();						
		}
	};	
}
</script>
</head>
<body>
<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
		<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="10%">承辦科別</td>
				<td class="tbYellow2" width="30%">
					<select id="qCRED_DEPT" class="areaB">
					<c:forEach var="map" items="${CRED_DEPT_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach></select>
				</td>	
				<td class="tbYellow" width="10%">確認日期</td>
				<td class="tbYellow2" width="30%">
					<input name="FINAL_DATE" id="FINAL_DATE" type="text" datatype="ROCdate" size="8" maxLength ="7"/>
					<img src="<%=imageBase%>/CM/calendar.gif" height="20" onclick="getCalendarFor($('FINAL_DATE'))">
				</td>		
				<td class="tbYellow2" align="center">
					<input id="btn_QUERY" type="button" class="button" value="查詢">
				</td>
			</tr>			
		</table>
		<table id="grid" width="100%" class="grid" ></table>
</form>
</body>
</html>		