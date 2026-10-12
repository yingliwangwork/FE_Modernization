<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC3_2501.java
作者：陳思涵 
功能：沖預繳作業入帳結果
完成：2013-09-17
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>


<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script><!-- 必要 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script><!-- 必要 -->

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script><!-- 目前畫面的版面設定 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script><!-- 目前系統常用的表格工具 -->

<script type="text/JavaScript">
Event.observe(window, 'load', new DSC32501().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC32501(){

	var Action;
	var washList;
			
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_2501/" + actionName,
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
	}//END   共用AJAX

    //按鈕授權
	function buttonAuth(){
		var authButtons = {		
			B0214:"btn_CONFIRM"
		};
		<dz:grantButtons FUNC_ID="DSC32501" />
	}

	var buttons = {
		doConfirm : function(){
			
			ajaxPost('confirm' , { Action : Action , washList : Object.toJSON(washList) },
				function(resp){
					$('msg').update(resp.rtnMSG);
				},function(resp){
					$('msg').update(resp.rtnMSG);
				});
		
		}
	}; 

	// 金額格式化
	var gridFmtRender = function(value) { 
	   return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : '0'; 
	};


	var colObj = {
		a : [
			{header: "貸款帳號",key: "LOAN_ID"},						
			{header: "沖預繳期數",key: "PAY_TERM"},						
			{header: "應繳日期",key: "TAKE_DATE",render:function(rec, val){
					return Date.toROC(val) || '';
				}},						
			{header: "應繳金額",key: "TAKE_AMT",attrs:{align:"right"},render:function(rec, val){
					return gridFmtRender(val);
				}},						
			{header: "暫收款",key: "WASH_TEMP",attrs:{align:"right"},render:function(rec, val){
					return gridFmtRender(val);
				}},						
			{header: "實繳金額",key: "REAL_PAYMT",attrs:{align:"right"},render:function(rec, val){
					return gridFmtRender(val);
				}}
			],
		b : [
			{header: "貸款帳號",key: "LOAN_ID"},						
			{header: "期數",key: "PAY_TERM"},						
			{header: "應繳日期",key: "TAKE_DATE",render:function(rec, val){
					return Date.toROC(val) || '';
				}},						
			{header: "應繳金額",key: "TAKE_AMT",attrs:{align:"right"},render:function(rec, val){
					return gridFmtRender(val);
				}},						
			{header: "沖帳後暫收款",key: "WASH_TEMP",attrs:{align:"right"},render:function(rec, val){
					return gridFmtRender(val);
				}},						
			{header: "實繳日期",key: "REAL_PAYDT",render:function(rec, val){
					return Date.toROC(val) || '';
				}},						
			{header: "實繳金額",key: "REAL_PAYMT",attrs:{align:"right"},render:function(rec, val){
					return gridFmtRender(val);
				}}
		]
	}

	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC32501', '核心放款', '沖預繳作業入帳結果');
	
			$('btn_confirm').observe('click', buttons.doConfirm);
			
			Action = '${Action}';
			
			<c:if test="${not empty washList}">
				washList = ${washList};
			</c:if>
			
			
			var grid;
			
			if(Action=='CONFIRM'){
				 grid = new TableUI({
								table: $('grid'),
								allSortable:false,
								pageSize:10,
								column:colObj.a
						});
			}else if(Action=='FORCE'||Action=='INTEMP'){
				grid = new TableUI({
								table: $('grid'),
								allSortable:false,
								pageSize:10,
								column:colObj.b
						});
			}
			grid.load(washList);
			
			buttonAuth();
			
			PageUI.resize();			
			displayMessage();			
		}
	};
	

}
</script>
</head>
<body>

<table id="table1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td>
			<table id="grid" class="grid"></table>
		</td>
	</tr>
	<tr>
		<td class="tbYellow2">
			<input id="btn_confirm" type="button" class="button" value="入帳確認" />
		</td>
	</tr>
	<tr>
		<td class="tbYellow2">
			<span id="msg" class="textRed"></span>
		</td>
	</tr>
</table>

</body>
</html>