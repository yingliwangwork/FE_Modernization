<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--
程式：DSC80128.jsp
作者：吳誌倫
功能：本金彈性變更記錄
完成：2023/01/17
 -->	

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->	
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/JavaScript">
// 產生畫面物件  //TODO
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC80128().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC80128(){
			
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
			PageUI.createPageWithAllBodySubElement( "DSC80128" , "變更作業" , "本金彈性變更記錄", 1);
			$('btn_BACK').observe('click',buttons.doBack);	
			PageUI.resize();	
			displayMessage();		
		}
	};	
}
</script>
</head>
<body>
	<form id="form" method="post">	
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="10%" align='left'>貸款帳號</td>
				<td class="tbYellow2" width="20%">
					<span id="LOAN_ID">${rtnMap.LOAN_ID}</span>
				</td>	
				<td class="tbYellow" width="10%" align='left'>變更日期</td>
				<td class="tbYellow2" width="10%">
					<span id="APPLY_DATE">${rtnMap.APPLY_DATE}</span>
				</td>	
				<td class="tbYellow" width="10%" align='left'>序號</td>
				<td class="tbYellow2" width="10%">
					<span id="SEQ_NO">${rtnMap.SEQ_NO}</span>
				</td>	
			</tr>	
			<tr>
				<td class="tbYellow" width="8%" align='left'>原每月約定還本金額(元)</td>
				<td class="tbYellow2" width="15%">
					<span id="FLEX_AMT1">${rtnMap.FLEX_AMT1}</span>
				</td>	
				<td class="tbYellow" width="8%" align='left'>新每月約定還本金額(元)</td>
				<td class="tbYellow2" width="15%" colspan='3'>
					<span id="FLEX_AMT2">${rtnMap.FLEX_AMT2}</span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" width="8%" align='left'>原本金彈性還期間</td>
				<td class="tbYellow2" width="15%">
					<span id="FLEX_AMT1">${rtnMap.FLEX_PERIOD_NM_1}</span>
				</td>	
				<td class="tbYellow" width="8%" align='left'>新本金彈性還期間</td>
				<td class="tbYellow2" width="15%" colspan='3'>
					<span id="FLEX_AMT2">${rtnMap.FLEX_PERIOD_NM_2}</span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" width="8%" align='left'>輸入人員</td>
				<td class="tbYellow2" width="15%">
					<span id="INPUT_ID">${rtnMap.INPUT_ID}</span> 
					<span id="INPUT_NM">${rtnMap.INPUT_NM}</span>
				</td>	
				<td class="tbYellow" width="8%" align='left'>輸入日期</td>
				<td class="tbYellow2" width="15%">
					<span id="APPLY_DATE">${rtnMap.APPLY_DATE}</span>
				</td>	
				<td class="tbYellow" width="8%" align='left'>輸入單位</td>
				<td class="tbYellow2" width="15%">
					<span id="INPUT_DEPT_NM">${rtnMap.INPUT_DEPT_NM}</span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" width="8%" align='left'>覆核人員</td>
				<td class="tbYellow2" width="15%">
					<span id="CONFIRM_NM">${rtnMap.CONFIRM_NM}</span>
				</td>	
				<td class="tbYellow" width="8%" align='left'>覆核日期</td>
				<td class="tbYellow2" width="15%">
					<span id="CONFIRM_DATE">${rtnMap.CONFIRM_DATE}</span>
				</td>	
				<td class="tbYellow" width="8%" align='left'>覆核單位</td>
				<td class="tbYellow2" width="15%">
					<span id="CONFIRM_DEPT_NM">${rtnMap.CONFIRM_DEPT_NM}</span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="center" colspan="6">
					<button id="btn_BACK" type="button" class="button" >上一頁</button>
				</td>
			</tr>	
		</table>
	</form>
</body>
</html>		