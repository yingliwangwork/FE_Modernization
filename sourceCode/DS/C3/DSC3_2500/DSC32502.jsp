<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<!--
程式：DSC3_2502.java
作者：陳思涵 
功能：沖預繳作業異常件帳戶資料
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
Event.observe(window, 'load', new DSC32502().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC32502(){
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_2502/" + actionName,
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
	
	var action = {
		doQuery : function(rtnList){
			ajaxPost('query' , { rtnList : Object.toJSON(rtnList) },
				function(resp){
					var grid = new TableUI({
								table: $('grid'),
								allSortable:false,
								pageSize:10,
								column:[
									{header: "貸款帳號",key: "LOAN_ID"},						
									{header: "借款人姓名",key: "BORROW_NAME"},						
									{header: "電話(日)",key: "DAY_TEL"},						
									{header: "電話(夜)",key: "NIGHT_TEL"},						
									{header: "行動電話",key: "MOBILE"},						
									{header: "通訊地址",key: "CON_ADDR"},						
									{header: "收息單位",key: "GETINT_DEPT"}
								]
						});
					
					grid.load(resp.errList);	
						
				});
		
		
		}
	};
	
	
	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC32502', '核心放款', '沖預繳作業異常件帳戶資料');
			
			<c:if test="${not empty rtnList}">
				var rtnList = ${rtnList};
			</c:if>
			
			action.doQuery(rtnList);
	
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