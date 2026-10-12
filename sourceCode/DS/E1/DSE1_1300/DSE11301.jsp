<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!--
程式：DSE11301.jsp
功能：放款資產及減損評估二分類
作者：楊青峰
完成：2020-07-15
--> 

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>

<script type="text/javascript">
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSE11301().initApp);

function DSE11301() {
	
	var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSE1_1301/');
	
	var buttons = {
			
		<%-- 查詢 --%>
		doQuery: function() {
			
			var param = {reqMap: Object.toJSON({LOAN_YYMM: $F('LOAN_YYMM')})};
			ajaxRequest.post('query', param,
		        function(resp) {
		            
					$('year').update(resp.year || '');
					$('month').update(resp.month || '');
					grid.load(resp.rtnList || []);
		        }, function(resp) {
		        	
		        	$('year').update(resp.year || '');
					$('month').update(resp.month || '');
					grid.load([]);
		        }
		    );
		},

		<%-- 產製報表按鈕 --%>
		doReport: function() {
			
			RPTUtil.downloadFile('${dispatcher}/DSE1_1301/report', {LOAN_YYMM: $F('LOAN_YYMM')}, true);
		},
		
		<%-- 匯出明細按鈕 --%>
		doExport: function() {
			
			var param = {reqMap: Object.toJSON({LOAN_YYMM: $F('LOAN_YYMM')})};
			
			ajaxRequest.post('checkCHG', param,
		        function(resp) {
		            
					var isCHG = resp.isCHG;
					if(!isCHG) {
						
						alert('覆核後，才可匯出明細');
					} else {
						
						<%-- 下載明細檔案 --%>
						RPTUtil.downloadFile('${dispatcher}/DSE1_1301/export', param, false);						
					}
		        }
		    );
		}
	};

	return{
		initApp : function() {
			
			PageUI.createPageWithAllBodySubElement('DSE11301', '法務作業', '放款資產及減損評估二分類');
			
			grid = new TableUI({
				
				table: $('grid'),
				pageSize: 0,
				column: [
					{header: '', key: 'KIND', render: function(rec, val, sn) {
						if(!val) {
							return '';
						}
						if(val == 'A') {
							return 'EIR餘額';
						} 
						if(val == 'B') {
							return '應備呆金額';
						}
					}},
					{header: '英國不動產', key: 'C1', sortRule: 'number'},
					{header: '100年後之<br>政策性不動產', key: 'C2', sortRule: 'number'},
					{header: '銀行保證', key: 'C3', sortRule: 'number'},
					{header: '動產', key: 'C4', sortRule: 'number'},
					{header: '剩餘案件', key: 'C5', sortRule: 'number'},
					{header: '合計', key: 'TOT', sortRule: 'number'}
				]
			});
			
			$('btnQuery').observe('click', buttons.doQuery); <%-- 查詢 --%>
			$('btnReport').observe('click', buttons.doReport); <%-- 產製報表按鈕 --%>
			$('btnExport').observe('click', buttons.doExport); <%-- 匯出明細按鈕 --%>
			
			displayMessage();
		}
	}
}
</script>
</head>

<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">查核月份</td>
			<td class="tbYellow">
				<select id="LOAN_YYMM">
					<c:forEach var="list" items="${loanYYMM_List}">
						<option value="${list.key}">${list.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow">
				<button type="button" class="button" id="btnQuery">查詢</button>
				<button type="button" class="button" id="btnReport">產製報表</button>
				<button type="button" class="button" id="btnExport">匯出明細</button>
			</td>
		</tr>
	</table>
	<div><span id="year"></span>年<span id="month"></span>月應提備呆表</div>
	<table id="grid"></table>
</form>	
</body>
</html>