<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--
程式：DSC80126.jsp
作者：余凱鈞
功能：契約狀況變更紀錄
完成：2013/09/04

[20230316]修改件: 難字修改
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

<%-- [20230316]新增style --%>
<style type="text/css">
	@font-face {
		 font-family: 'EUDC';
		 src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
			  url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		 font-weight: normal;
		 font-style: normal
	}
</style>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC80126().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC80126(){
			
	var buttons = {	
		//上一頁
		doBack : function(){
			if(window.isPopupWin && window.popupWinBack){
			   // 呼叫callback Function(若有) 並關閉
			   window.popupWinBack(); 
			}else if(window.parent && window.parent.popupWin){
				//呼叫callback Function(若有) 並關閉
			   window.parent.popupWin.back();
			}else{
				CSRUtil.linkBack();
			}				 
		}			
	};

	return{	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSC80126" , "變更作業" , "契約狀況變更紀錄",1);
		
			$('btn_BACK').observe('click',buttons.doBack);	
		
			PageUI.resize();	
			displayMessage();			
		}
	};	
}
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="10%" align='left'>貸款帳號：</td>
				<td class="tbYellow2" width="20%">
					<span id="LOAN_ID">${rtnMap.LOAN_ID}</span>
				</td>	
				<td class="tbYellow" width="10%" align='left'>變更日期：</td>
				<td class="tbYellow2" width="10%">
					<span id="APPLY_DATE">${rtnMap.APPLY_DATE}</span>
				</td>	
				<td class="tbYellow" width="10%" align='left'>序號：</td>
				<td class="tbYellow2" width="10%">
					<span id="SEQ_NO">${rtnMap.SEQ_NO}</span>
				</td>	
			</tr>	
			<tr>
				<td class="tbYellow" width="8%" align='left'>變更前契約狀況：</td>
				<td class="tbYellow2" width="15%">
					<span id="LOAN_STATUS1">${rtnMap.LOAN_STATUS1}</span>
				</td>	
				<td class="tbYellow" width="8%" align='left'>變更後契約狀況：</td>
				<td class="tbYellow2" width="15%" colspan='3'>
					<span id="LOAN_STATUS2">${rtnMap.LOAN_STATUS2}</span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" width="8%" align='left'>變更原因：</td>
				<td class="tbYellow2" width="15%" colspan='5'>
					<span id="CHANGE_REASON">${rtnMap.CHANGE_REASON}</span>
				</td>	
			</tr>	
			<tr>
				<td class="tbYellow" width="8%" align='left'>輸入人員：</td>
				<td class="tbYellow2" width="15%">
					<span id="INPUT_ID">${rtnMap.INPUT_ID}</span> 
					<span id="INPUT_NM" style="font-family:'EUDC'">${rtnMap.INPUT_NM}</span> <%-- [20230316]難字style --%>
				</td>	
				<td class="tbYellow" width="8%" align='left'>輸入日期：</td>
				<td class="tbYellow2" width="15%">
					<span id="INPUT_DATE">${rtnMap.INPUT_DATE}</span>
				</td>	
				<td class="tbYellow" width="8%" align='left'>輸入單位：</td>
				<td class="tbYellow2" width="15%">
					<span id="INPUT_DEPT">${rtnMap.INPUT_DEPT}</span>
					<span id="INPUT_DEPT_NM">${rtnMap.INPUT_DEPT_NM}</span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" width="8%" align='left'>覆核人員：</td>
				<td class="tbYellow2" width="15%">
					<span id="CONFIRM_ID">${rtnMap.CONFIRM_ID}</span>
					<span id="CONFIRM_NM" style="font-family:'EUDC'">${rtnMap.CONFIRM_NM}</span> <%-- [20230316]難字style --%>
				</td>	
				<td class="tbYellow" width="8%" align='left'>覆核日期：</td>
				<td class="tbYellow2" width="15%">
					<span id="CONFIRM_DATE">${rtnMap.CONFIRM_DATE}</span>
				</td>	
				<td class="tbYellow" width="8%" align='left'>覆核單位：</td>
				<td class="tbYellow2" width="15%">
					<span id="CONFIRM_DEPT">${rtnMap.CONFIRM_DEPT}</span>
					<span id="CONFIRM_DEPT_NM">${rtnMap.CONFIRM_DEPT_NM}</span>
				</td>	
			</tr>	
			<tr>
				<td class="tbYellow" align="center" colspan="6">
					<input id="btn_BACK" type="button" class="button" value="關閉視窗">
				</td>
			</tr>	
		</table>
	</form>
</body>
</html>		