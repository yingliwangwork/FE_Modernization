<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<!--
程式：DSC3_2503.java
作者：陳思涵 
功能：沖預繳應繳金額明細
完成：2013-09-17
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>


<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script><!-- 必要 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script><!-- 必要 -->

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script><!-- 目前畫面的版面設定 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script><!-- 目前系統常用的表格工具 -->

<script type="text/JavaScript">
Event.observe(window, 'load', new DSC32503().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC32503(){
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_2503/" + actionName,
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
	
	// 金額格式化
	var gridFmtRender = function(value) { 
	   return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : '0'; 
	};

	var action = {
		doQuery : function(LOAN_ID, REAL_PAYDT){
			ajaxPost('query' , { LOAN_ID :LOAN_ID, REAL_PAYDT:REAL_PAYDT },
				function(resp){
					var grid = new TableUI({
								table: $('grid'),
								allSortable:false,
								pageSize:10,
								column:[
									{header: "貸款帳號",key: "LOAN_ID"},						
									{header: "期數",key: "PAY_TERM"},						
									{header: "應繳日",key: "TAKE_DATE",render:function(rec, val){
												return Date.toROC(val) || '';
											}},						
									{header: "實繳日",key: "PAY_DATE",render:function(rec, val){
												return Date.toROC(val) || '';
											}},						
									{header: "應繳金額",key: "DUTY_PAYMT",attrs:{align:"right"},render:function(rec, val){
												return gridFmtRender(val);
											}},						
									{header: "應攤本金",key: "PRINCIPAL",attrs:{align:"right"},render:function(rec, val){
												return gridFmtRender(val);
											}},						
									{header: "利息",key: "INTEREST",attrs:{align:"right"},render:function(rec, val){
												return gridFmtRender(val);
											}},						
									{header: "災戶攤繳",key: "VICTIM_INT",attrs:{align:"right"},render:function(rec, val){
												return gridFmtRender(val);
											}},						
									{header: "逾期息",key: "DELAY_INT",attrs:{align:"right"},render:function(rec, val){
												return gridFmtRender(val);
											}},						
									{header: "違約金",key: "RENEGE",attrs:{align:"right"},render:function(rec, val){
												return gridFmtRender(val);
											}},						
									{header: "訴訟費",key: "LAWSUIT_FEE",attrs:{align:"right"},render:function(rec, val){
												return gridFmtRender(val);
											}},						
									{header: "上期結餘",key: "LAST_BALANCE",attrs:{align:"right"},render:function(rec, val){
												return gridFmtRender(val);
											}},						
									{header: "代扣稅款",key: "TAX",attrs:{align:"right"},render:function(rec, val){
												return gridFmtRender(val);
											}}
								]
						});
					
					grid.load(resp.rtnMap);	
						
				});
		
		}
	};
	
	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC32503', '核心放款', '沖預繳應繳金額明細');
			
			var LOAN_ID = '${LOAN_ID}';
			var REAL_PAYDT = '${REAL_PAYDT}';
			
			action.doQuery(LOAN_ID, REAL_PAYDT);
	
			$('btn_return').observe('click', function(){
				CSRUtil.linkBack();
			});
			
			
			PageUI.resize();			
			displayMessage();			
		}
	};
	

}

</script>
</head>
<body>
<form name="form1" id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table id="grid" class="grid"></table>
<table id="table1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td colspan="3" align="center">
			<input id="btn_return" type="button" class="button" value="回上一頁" />
		</td>
	</tr>
</table>
</form>
</body>
</html>