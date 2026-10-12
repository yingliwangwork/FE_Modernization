<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC30900.jsp
功能：理財型未辦理轉帳查詢
作者：溫子
完成：2013/05
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<%--[20241101]難字css  --%>
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
Event.observe(window, 'load', new DSC30900().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC30900(){
	var grid;
	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSC3_0900/" + actionName,
				{  
				parameters: params, 
				onSuccess:function(response){
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){	
						if(successFunction){
							successFunction(resp);
						}
					}else{
					    grid.load([]);
						if(errorFunction){
							errorFunction(resp);
						}
					}
				}			
			});
		}
	var buttons={
		doQuery :function(){
			ajaxPost( 'query', {CRED_DEPT: $F('CRED_DEPT')}
				,function(resp){
					grid.load(resp.rtnList);
				}
			);
		
		}

	}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC30900', '繳款方式', '理財型未辦理轉帳查詢');
				
				grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true,			
				<%--[20241101] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[			
					{header:"貸款帳號", key:"LOAN_ID"},
					{header:"受理編號",key:"APPLY_ID"},
					{header:"借款人姓名",key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"}},
					{header:"貸放日期",key:"LOAN_DATE",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					
					},
					{header:"徵信人員",key:"CRED_ID_NAME", attrs:{style:"font-family:'EUDC'"}},
					{header:"新放作業人員",key:"LOAN_INPUT_NAME", attrs:{style:"font-family:'EUDC'"}}
					
				]
				});
				
				$('BTN_QUERY').observe('click',buttons.doQuery);
				
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
			}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<td class="tbYellow" width="5%" >承辦區域</td>
			<td class="tbYellow2" width="5%" >
				<select id="CRED_DEPT">
						<option value="">全部</option>
							<c:forEach var="map" items="${CRED_DEPT_List}">
									<option value="${map.key}">${map.value}</option>
							</c:forEach>
				</select> 
	</td>
	<td class="tbYellow2" width="10%" >
			<input id="BTN_QUERY" type="button" value="查詢" class="button"> 
		</td>
</table>
<table id = "grid" ></table>
</form>
</body>
</html>