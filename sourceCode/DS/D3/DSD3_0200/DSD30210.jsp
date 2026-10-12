<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<!--
程式：DSD30210.jsp
功能：借款人資料查詢
作者：林秉宏
完成：2013/11/19

[20240326]
難字調整
高強禾
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
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
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSD30210().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSD30210(){	

		var grid;
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSD3_0210/' + actionName,
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

				// 頁面傳入參數
				ajaxPost( 'query' , { 'BORROW_ID' : '${BORROW_ID}' ,'LINK_FROM' : '${LINK_FROM}'},
					function(resp){			
						grid.load(resp.rtnList || [], resp.totalList || [], resp.subTotalList || []);
					},function(resp){
						grid.load([]);
					}
				);	
			}
		};
		
		//金額 利率格式化
		var gridFmtRender = function(value) { 
			return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.####', 0) : ''; 
		};

		return {
			
			initApp : function() {

				$('TABLE_BACK').hide();
			
				if ('${LINK_FROM}' == 'DSH0_0300') {
					PageUI.createPageWithAllBodySubElement(
					'DSD30210' ,
					'客戶資料查詢' , 
					'同一關係人資料查詢');	

					$('TABLE_BACK').show();
				} else {
					PageUI.createPageWithAllBodySubElement(
					'DSD30210' ,
					'防止清償通報' , 
					'借款人資料查詢');						
				}
			
				
				// 產生 grid 物件	
				grid = new TableUI(
					{	
						table: $('grid'), overDiv:false,
						<%-- [20240326] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header:'項目', key:'TYPE_NM', groupKey:["TYPE_NM"]},	
							<%-- [20240326] 難字調整：姓名 --%>
							{header:'姓名', key:'RELATION_NAME', attrs:{ style:"font-family:'EUDC'" }},
							{header:'關係', key:'RELATION_CODE_NM'},						
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:'原貸帳號', key:'REFER_ID'},
							{header:'擔保品鄉鎮', key:'GAGE_ADDR'},
							{header:'本金餘額' ,key: "REMAIN_AMT",renderInCount:true,
								render : function(rec, val){
									return gridFmtRender(val);
							}},
							{header:'下期利率' ,key: "RATE",
								render : function(rec, val){
									return gridFmtRender(val);
							}},
							{header:'近六期逾15天次數', key:'OVER_TIMES'},
							{header:'最近利率調整日' ,key: "LAST_ADJUST",
								render : function(rec, val){
									return Date.toROC(val) || '';
							}}
						]						
					}
				);	

				// 回上一頁
				$('BTN_back').observe('click', function(event){
					CSRUtil.linkBack();
				});				

				$('BORROW_ID').innerHTML = '${BORROW_ID}';
				actions.doQuery();
	
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
    <input type="hidden" id="LINK_FROM" value="${LINK_FROM}" />
	<td class="tbYellow" width="10%">
		借款人ID
	</td>
	<td class="tbYellow2" width="40%">
		<span id="BORROW_ID"></span>
	</td>
	<td class="tbYellow2" width="50%">
		<font color="red"><b>備註：下期利率為前一工作日計算之利率(非即時)</b></font>
	</td>
</table>

<table id="grid" class="grid"></table>
<table id="TABLE_BACK" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<td class="tbYellow2" width="100%" align='center' >
		<input id="BTN_back" type="button" class="button" value=" 回上一頁"/>
	</td>
</table>
</form>		
</body>
</html>