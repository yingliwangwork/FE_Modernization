<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC91201.jsp
作者：柯玉芳
功能：資金查核銀行交易明細查詢
完成：2016/02/03

[20230325]難字修改
-->

<html> 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<title></title>
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">

<script type="text/javascript" src="${htmlBase}/CM/js/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<style type="text/css"><%-- [20230325]難字修改 --%>
	@font-face{
		font-family: 'EUDC';
		 src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		font-weight:normal;
		font-style:normal
	}	
</style>
<script type="text/javascript">

// 產生畫面物件
var DSC91201 = new DSC91201();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, "load", DSC91201.initApp);
Event.observe(window, "resize", fix);
Event.observe(window, "scroll", fix);

function DSC91201(){

	var grid;
	var reqMap;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC9_1201/');
	
	
	var action = {
		//儲存畫面
		storeMap :function(){
			return{
				BORROW_ID: '${BORROW_ID}',
				APPLY_ID:'${APPLY_ID}'
				
		    }
		}
	};
	
	var buttons = {
		//查詢
		doQuery:function(event){
			ajaxRequest.post('query',{reqMap:Object.toJSON(action.storeMap())},
				function(resp){
					grid.load(resp.rtnList||[]);
				},
				function(resp){
					grid.load([]);
				}
			);
		}	
	};
	
	return {
		initApp : function() {
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay" />		
			PageUI.createPageWithAllBodySubElement( "DSC91201" , "覆審作業", "資金查核銀行交易明細查詢" );
			
			grid = new TableUI({
				table: $("grid"), pageSize: 20, allSortable:true, overDiv:false,	
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }<%-- [20230325]難字修改 --%>
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }<%-- [20230325]難字修改 --%>
				},
				column:[					
					{header:"客戶ID",key:"CUSTOMER_ID"},
					{header:"客戶姓名",key:"CUSTOMER_NAME", attrs:{style:"font-family:'EUDC'"} },	<%-- [20230325]難字修改 --%>
					{header:"客戶帳號",key:"ACCT_NBR"},	
					{header:"貸放金額",key:"LOAN_AMT", sortRule:'number'},
					{header:"撥款金額",key:"CURRENT_BAL", sortRule:'number'},		
					{header:"交易日期",key:"TXN_DATE", sortRule:'date'},							
					{header:"摘要",key:"MEMO", attrs:{style:"font-family:'EUDC'"} },	<%-- [20230325]難字修改 --%>
					{header:"交易金額",key:"TXN_AMT", sortRule:'number'},		
					{header:"累計數",key:"RUNNING_SUM", sortRule:'number'}		
				]
			});
			
			<%--上一頁--%>
			$('btn_back').observe('click', function(){
				if(window['callbackHandler']){     
					//回傳物件陣列
					callbackHandler('');
					close();
				}else if(parent && parent.popupWin ){     
					if(parent.popupWin.callbackHandler){
						parent.popupWin.callbackHandler('');  
					}
					close();     
				}else{    
					CSRUtil.linkBack(); 
				}
			});
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			//畫面檢核

			buttons.doQuery();
			PageUI.resize();
			displayMessage();
		}
	};	
};

</script>
</head>
<body>		
<form id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">

<table id='grid' width='100%'></table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow2" align='center'>
				<input id="btn_back" type="button" value="上一頁" class="button" >	
			</td>
		</tr>
</table>
</form>
</body>
</html>