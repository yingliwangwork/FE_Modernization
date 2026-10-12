<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC32500.jsp
作者：余凱鈞
功能：沖預繳-輸入作業
完成：2013/09/13

[20241104] 修改件 難字調整 吳志鴻
 -->	

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>

<%-- [20241104] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>

<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC32500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC32500(){
	var grid;

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_2500/" + actionName,
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
	
	
	<%--按鈕授權--%>
	function buttonAuth(){
		var authButtons = {		
			B0028:"btn_CONFIRM"
		};
		<dz:grantButtons FUNC_ID="DSC32500" />
	}
			
	var buttons = {	
		doQuery : function(){ //查詢
		
			ajaxPost( 'query', {}
				,function(resp){
					rtnList=resp.rtnList;
					for(var i = 0 ;  i < rtnList.size() ; i++ ){
						rtnList[i]['seqNO'] = i + 1;
					}
					grid.load(rtnList);
					$('btn_CONFIRM').enable();
				},function(resp){
					$('btn_CONFIRM').disable();
				}
			);
		},
		doConfirm : function(){ //確認
			var LP_JSON = {	
					action : '<%=dispatcher%>/DSC3_2510/prompt' //不需傳參數
				};
			CSRUtil.linkTo(LP_JSON , 'form1');	
		}
		
	};

	return{	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSC32500" , "核心放款" , "沖預繳 輸入--沖預繳支票" ,1);
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: false,	
				column: [
					{header:"序號", key:'seqNO'},
				    {header:"貸款帳號", key:'LOAN_ID'},
					{header:"借款人姓名", key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"},  <%-- [20241104] 難字調整: 借款人姓名 --%>
						render : function (rec , val){
							return val ? CSRUtil.maskHandler.getMaskName(val) : '';
					}},
					{header:"應繳期數", key:'PAY_TERM'},
					{header:"應繳日期", key:'TAKE_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"應繳金額", key:'TAKE_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"預繳期數", key:'PREPAY_TERM'},
					{header:"實繳日期", key:'REAL_PAYDT',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"繳款金額", key:'REAL_PAYMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}}							
				]	
			});
			
			buttonAuth();

			buttons.doQuery();
			$('btn_CONFIRM').observe('click',buttons.doConfirm);			

			PageUI.resize();
			displayMessage();						
		}
	};	
}
</script>
</head>
<body>
<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
		<table id="grid" width="100%" class="grid" ></table>
		<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>	
				<td class="tbYellow2" >
					<input id="btn_CONFIRM" type="button" class="button" value="確認">
				</td>
			</tr>			
		</table>
		<div class="tbYellow tbBox2">
			<font color="blue">一、作業規定</font>
			<br>1. 此作業為客戶預繳支票後，待<font color="red">支票兌現回來</font>，去沖其當初預繳期數來入帳。
			<br>2. 沖預繳完畢後可至沖預繳查詢當日所有沖預繳之件數。
			<br>
			<br><font color="blue">二、操作方式</font>
			<br>1. 系統會自行讀取有預繳件且預繳票兌現後之件數。
			<br>2. 按確認後系統會自行分析出正常件及異常件。
			<br>3. 正常件可直接沖預繳入帳，異常件則需判斷是何種異常原因：<font color="red">01繳次不對 03契約狀態異常 04金額不足</font>
			<br>4. 異常件可查看借款人資料以利通知借款人。
			<br>5. 異常件可入電腦暫收款或強迫入帳，唯強迫入帳限制為：<font color="red">差額在3000元以內，才可強迫入帳!!</font>
		</div>
</form>
</body>
</html>