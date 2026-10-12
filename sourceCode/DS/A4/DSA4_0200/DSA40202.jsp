<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!-- Import resource，新增請放下面 -->
<!--
程式：DSA40202.jsp
作者：張憶如
功能：檔案產製作業
完成：
-->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>

<script type="text/JavaScript">


Event.observe(window, 'load', new DSA40202().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


function DSA40202(){

	var grid;
	var grid2;
	
	<%--共用Ajax--%>
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA4_0202/');
	
	<%--按鈕控制--%>
	function buttonControl(){
		if('${isValid}' == 'N'){
			$("btn_produce").disable();
		}
	}

	var buttons = {
		<%--查詢--%>
		doQuery:function(){
			ajaxRequest.post('query', {TYPE: $F('TYPE')}, 
				function(resp){
					var rtnList = resp.rtnList;
					grid.load(rtnList || []);
					var rtnListC = resp.rtnListC;
					grid2.load(rtnListC || []);
				},
				function(resp){
					grid.load([]);
					grid2.load([]);
				});
		},
		<%--檔案產製--%>
		doProduce:function(){
			var data = grid.getCheckedRecord();
			if(data.length == 0){
				alert('必須選取一筆資料');
				return;
			}
			
			ajaxRequest.post('produce', {TYPE: $F('TYPE'), data: Object.toJSON(data[0])});
		},
		<%--上一頁--%>
		doBack:function(){
			CSRUtil.linkBack();
		}
	};
	

	return {
		initApp : function() {

			PageUI.createPageWithAllBodySubElement("DSA40202" , "經手人專區" , "檔案產製作業");
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>
			grid = new TableUI(
				{
					table: $('grid'), pageSize: 10, allSortable: true, overDiv:false,
					autoCheckBox: {type:'radio'},
					column:[
						{header:'資料種類', key:'TYPE_NM'},
						{header:'序號', key:'SEQ_NO'},
						{header:'有效/無效件', key:'VALID_NM'},
						{header:'筆數', key:'INPUT_CNT'},
						{header:'上傳說明', key:'MEMO'},
						{header:'上傳人員', key:'INPUT_NM'},
						{header:'上傳日期', key:'INPUT_DATE1', sortRule:'date'}
					]
				}
			);
			grid2 = new TableUI(
				{
					table: $('grid2'), pageSize: 10, allSortable: true, overDiv:false,title:'執行紀錄',
					column:[
						{header:'批次程式', key:'PROC_NAME'},
						{header:'執行時間', key:'EXEC_TIME', sortRule:'datetime'},
						{header:'訊息', key:'MSG'}
					]
				}
			);
			
			buttonControl();
			
			buttons.doQuery();	
			
			<%--檔案產製--%>
			$('btn_produce').observe('click',buttons.doProduce);

			<%--上一頁--%>
			$('btn_back').observe('click', buttons.doBack);
	
			displayMessage();
		}
	}
}


</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0"	marginwidth="0" marginheight="0">
<form name="form1" id="form1" method="post" action="">
<table width="100%" border="0"	cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbYellow" width="16%">資料種類
			<input type="hidden" name="TYPE" id="TYPE" class="textBox2" value='${TYPE}' />
		</td>
		<td class="tbYellow2" width="16%">${TYPE_NM}</td>
		<td class="tbYellow2">
			<input id="btn_produce" name="btn_produce" type="button" class="button" value="檔案產製">
			<input id="btn_back" name="btn_back" type="button" class="button" value="上一頁">
		</td>
	</tr>
</table>
</form>
<table id="grid" name="grid"></table>
<table id="grid2" name="grid2"></table>
</body>
</html>
