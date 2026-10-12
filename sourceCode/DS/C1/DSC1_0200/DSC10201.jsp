<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%--
<%@ page import="com.cathay.common.util.trx.RespCtxUtil"%>
<%@ page import="com.cathay.ds.c1.bo.DSC1_0202_bo"%>

<%
	HttpResponseContext resp = new HttpResponseContext(request); // 取 addOutputData
	HttpTxContext txCxt = new HttpTxContext(session);            // 取 putValue
	RespCtxUtil ctxUtil = new RespCtxUtil(resp);
		
	Map viewData = resp.getOutputData("viewData") == null ? Collections.EMPTY_MAP : (Map)resp.getOutputData("viewData");
	DSC1_0202_bo vo = (DSC1_0202_bo)viewData.get("DSC1_0202_bo");  
	pageContext.setAttribute("vo", vo);
	
%>

--%>
<%--
[20241030]修改件 CHROME瀏覽器難字調整
--%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html> 
<head>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<title></title>
<%--[20241030]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>

<script type="text/javascript">
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function initApp(){

	PageUI.createPageWithAllBodySubElement('DSC10201','收息帳務作業','EIR繳息明細查詢作業');
	PageUI.resize();
	// 顯示執行結果
	displayMessage();
}

function doClose(LOAN_ID, LATEST_PAY_TERM) {
	
	var queryObj = {"LOAN_ID":LOAN_ID, "LATEST_PAY_TERM":LATEST_PAY_TERM};
	if( parent.popupWin ){
		if ( parent.popupWin.callbackHandler){
			parent.popupWin.callbackHandler(queryObj);
		}
    	parent.popupWin.close();
	} else if(window['callbackHandler']){
		callbackHandler(queryObj);
		close();
	}
}

function doConfirm(LOAN_ID, PAY_TERM, PAY_KIND, SEQ_NO, opkd, LATEST_PAY_TERM) { 
	var maxPayTerm = Number('${input.MAX_PAY_TERM}');
	var initPayTerm = Number(PAY_TERM);
	var newPayTerm = opkd =='PREV' ? initPayTerm -1 : initPayTerm + 1;
	if ( newPayTerm < 0){
		alert("已無上一期繳息記錄");
		return;
	} else if ( newPayTerm > maxPayTerm) {
		alert("已無下一期繳息記錄");
		return;
	}
	var frm = document.form1;
	var OPTIONS = opkd;
	frm.action="<%=dispatcher%>/DSC1_0200/detail?LOAN_ID="+LOAN_ID+"&PAY_TERM="+newPayTerm+"&PAY_KIND="+PAY_KIND+"&SEQ_NO="+SEQ_NO+"&OPTIONS="+OPTIONS+"&LATEST_PAY_TERM="+LATEST_PAY_TERM + "&MAX_PAY_TERM="+maxPayTerm; 
	frm.target="";
	frm.submit();
}

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="initApp();">
<%--
<span id="bar1"
	style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible;">
<table width="100%" height="30" border="0" cellpadding="0"
	cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img
			src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0"
			background="<%=imageBase%>/CM/border_03.gif">
			<tr>
				<td height="4"><img src="<%=imageBase%>/CM/border_03.gif"
					width="12" height="4"></td>
			</tr>
		</table>
		<!-- InstanceBeginEditable name="title" -->
		<table width="100%" border="0" cellpadding="2" cellspacing="0"
			class="subTitle">
			<tr>
				<td width="20" height="24">
				<div align="center"><font size="-5">●</font></div>
				</td>
				<td>收息帳務作業</td>
				<td align="right">畫面編號：DSC10201</td>
			</tr>
		</table>
		<!-- InstanceEndEditable --></td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img
			src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img
			src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</span>

<table width="100%" height="30" border="0" cellpadding="0"
	cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>

<table width="100%" height="100%" border="0" cellpadding="0"
	cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
			<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
		<table width="97%" border="0" align="center" cellpadding="0"
			cellspacing="1" bgcolor="#003366">
			<tr><!-- InstanceBeginEditable name="title2" -->
				<td class="tbBox2">
					<p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16" />EIR繳息明細查詢作業</p>
				</td>
			</tr>
			<tr bgcolor="#FFFFFF">
				<td>
				--%>
				<!-- InstanceBeginEditable name="content" -->
				<table width="100%" border="0" cellspacing="0" cellpadding="5">
					<tr>
						<td>
						<form name="form1" method="post" action="">
						
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
							<tr>
                            	<td class="tbYellow" width="10%" align="left">貸款帳號</td> 
                                <td class="tbYellow2" width="10%" align="left"><c:out value="${input.LOAN_ID}"/></td>
                                <td class="tbYellow" width="10%" align="left">期數</td>
                                <td class="tbYellow2" width="10%" align="left"><c:out value="${input.PAY_TERM}"/></td>
                                <td class="tbYellow" width="10%" align="left">繳款別</td>
                                <td class="tbYellow2" width="10%" align="left"><cathay:conver sys="DS" field="PAY_KIND" value="${input.PAY_KIND}"/></td>
                                <td class="tbYellow2" width="40%" align="left">
									<input type="button" id="btn_confirm1" class="button" onclick="doConfirm('<c:out value="${input.LOAN_ID}"/>','<c:out value="${input.PAY_TERM}" />','<c:out value="${input.PAY_KIND}" />','<c:out value="${input.SEQ_NO}" />','PREV','<c:out value="${input.LATEST_PAY_TERM}" />');" value="上一期" />
                            		&nbsp;&nbsp;&nbsp;&nbsp; 
                            		<input type="button" id="btn_confirm2" class="button" onclick="doConfirm('<c:out value="${input.LOAN_ID}"/>','<c:out value="${input.PAY_TERM}" />','<c:out value="${input.PAY_KIND}" />','<c:out value="${input.SEQ_NO}" />','NEXT','<c:out value="${input.LATEST_PAY_TERM}" />');" value="下一期" />
                            		&nbsp;&nbsp;&nbsp;&nbsp;
                            		<input type="button" id="btn_close" class="button" onclick="doClose('<c:out value="${input.LOAN_ID}"/>','<c:out value="${input.LATEST_PAY_TERM}" />')" value="關閉" />
                            	</td>
                            </tr>  
						</table>
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
							<tbody>
                            	<tr>
                                	<td class="tbYellow" align="left" width=15%>姓名1</td>
                                    <td class="tbYellow2" align="left" colspan="3" width=90%><span id="BORROW_NAME" style="font-family:'EUDC'">${vo.BORROW_NAME}</span></td><%-- [20241030] 難字調整 --%>
                                </tr>
                                <tr>  
                                    <td class="tbYellow" align="left" width=15%>應繳日期</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:calendar type="ROC" value="${vo.DUTY_PAYDT}"/></td>
                                    <td class="tbYellow" align="left" width=15%>本金</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.PRINCIPAL}" /></td>
                                </tr>  
                                <tr>  
                                    <td class="tbYellow" align="left" width=15%>實繳日期</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:calendar type="ROC" value="${vo.REAL_PAYDT}"/></td>
                                    <td class="tbYellow" align="left" width=15%>利息</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.INTEREST}" /></td>
                                </tr>  
                                <tr>  
                                    <td class="tbYellow" align="left" width=15%>繳款前本金餘額</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:formatNumber type="number" pattern=",##0" value="${vo.LAST_PRINCIPAL}" /></td>
                                    <td class="tbYellow" align="left" width=15%>延滯息</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.DELAY_INT}" /></td>
                                </tr>  
                                <tr>  
                                    <td class="tbYellow" align="left" width=15%>災戶攤繳利息</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:formatNumber type="number" pattern=",##0" value="${vo.VICTIM_INT}" /></td>
                                    <td class="tbYellow" align="left" width=15%>違約金</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.RENEGE}" /></td>
                                </tr>  
                                <tr>  
                                    <td class="tbYellow" align="left" width=15%>票據日期</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:calendar type="ROC" value="${vo.CHECK_DATE}"/></td>
                                    <td class="tbYellow" align="left" width=15%>管理費用</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.LAWSUIT_FEE}" /></td>
                                </tr>  
                                <tr>  
                                    <td class="tbYellow" align="left" width=15%>票據表示</td>
                                    <td class="tbYellow2" align="left" width=25%>
                                    	<cathay:conver sys="DS" field="CHECK_STATUS" value="${vo.CHECK_STATUS}"/>
                                    </td>
                                    <td class="tbYellow" align="left" width=15%>代扣稅款</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.TAX}" /></td>
                                </tr>  
                                <tr>  
                                    <td class="tbYellow" align="left" width=15%>繳款方式</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:conver sys="DS" field="PAY_TYPE" value="${vo.PAY_TYPE}"/></td>
                                    <td class="tbYellow" align="left" width=15%>上期結餘</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.LAST_BALANCE}" /></td>
                                </tr> 
                                <tr>  
                                    <td class="tbYellow" align="left" width=15%>扣薪狀況</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:conver sys="DS" field="SALARY_STATUS" value="${vo.SALARY_STATUS}"/></td>
                                    <td class="tbYellow" align="left" width=15%>應收利息</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.RETAIN_INT}" /></td>
                                </tr> 
                                <tr>  
                                    <td class="tbYellow" align="left" width=15%>輸入日期</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:calendar type="ROC" value="${vo.INPUT_DATE}"/></td>
                                    <td class="tbYellow" align="left" width=15%>實繳金額</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.REAL_PAYMT}" /></td>
                               </tr> 
                               <tr>  
                                    <td class="tbYellow" align="left" width=15%>輸入人員/單位</td> 
                                    <td class="tbYellow2" align="left" width=25%><c:out value="${vo.INPUT_ID}"/>/<c:out value="${vo.INPUT_DEPT}"/></td>
                                    <td class="tbYellow" align="left" width=15%>本期結餘</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.THIS_BALANCE}" /></td>
                               </tr> 
                               <tr>  
                                    <td class="tbYellow" align="left" width=15%>作帳日期</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:calendar type="ROC" value="${vo.ACNT_DATE}"/></td>
                                    <td class="tbYellow" align="left" width=15%>繳款後本金餘額</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.NEW_PRINCIPAL}" /></td>
                               </tr> 
                               <tr>   
                                    <td class="tbYellow" align="left" width=15%>本期利率</td>
                                    <td class="tbYellow2" align="left" width=25%><c:out value="${vo.NEW_RATE}"/>%</td>
                                    <td class="tbYellow" align="left" width=15%>優惠後利率</td>
                                    <td class="tbYellow2" align="left" width=45%><c:out value="${vo.AFTER_RATE}"/>%</td>
                               </tr> 
                               <tr>
                                    <td class="tbBlue" align="center" colspan="4" >EIR繳息記錄</td>
                               </tr>
                               <tr>  
                                  	<td class="tbYellow" align="left" width=15%>EIR計算日期</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:calendar type="ROC" value="${vo.YIELD_DATE}"/></td>
                                    <td class="tbYellow" align="left" width=15%>EIR利率</td>
                                    <td class="tbYellow2" align="left" width=45%><c:out value="${vo.YIELD}"/>%</td>
                               </tr> 
                               <tr>  
                                  	<td class="tbYellow" align="left" width=15%>EIR延滯息</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:formatNumber type="number" pattern=",##0" value="${vo.DELAY_INT}" /></td>
                                    <td class="tbYellow" align="left" width=15%>EIR違約金</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.RENEGE}" /></td>
                               </tr> 
                               <tr>  
                                  	<td class="tbYellow" align="left" width=15%>EIR繳款前本金餘額</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:formatNumber type="number" pattern=",##0" value="${vo.EIR_LAST_PRINCIPAL}" /></td>
                                  	<td class="tbYellow" align="left" width=15%>EIR應收利息</td> 
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.RETAIN_INT}" /></td>
                               </tr> 
                               <tr>  
                                  	<td class="tbYellow" align="left" width=15%>EIR本金</td> 
                                    <td class="tbYellow2" align="left" width=25%><cathay:formatNumber type="number" pattern=",##0" value="${vo.EIR_PRINCIPAL}" /></td>
                                  	<td class="tbYellow" align="left" width=15%>EIR利息</td>
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.EIR_INTEREST}" /></td>
                               </tr> 
                               <tr>  
                                  	<td class="tbYellow" align="left" width=15%>EIR繳款後本金餘額</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:formatNumber type="number" pattern=",##0" value="${vo.EIR_LAST_PRINCIPAL - vo.EIR_PRINCIPAL}" /></td>
                                  	<td class="tbYellow" align="left" width=15%>債權本金調整數</td> 
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.ADJ_AMT}" /></td>
                               </tr> 
                               <tr>  
                                  	<td class="tbYellow" align="left" width=15%>EIR繳款後累計調整金額</td>
                                    <td class="tbYellow2" align="left" width=25%><cathay:formatNumber type="number" pattern=",##0" value="${vo.LAST_ADJBALC + vo.ADJ_AMT}" /></td>
                                  	<td class="tbYellow" align="left" width=15%>EIR繳款前累計調整金額</td> 
                                    <td class="tbYellow2" align="left" width=45%><cathay:formatNumber type="number" pattern=",##0" value="${vo.LAST_ADJBALC}" /></td>
                               </tr> 
                           </tbody>  
						</table>
						</form>
						</td>
					</tr>
				</table>
				<!-- InstanceEndEditable -->
				<%--
				</td>
			</tr>
		</table>
		<!-- InstanceEndEditable --></td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img
			src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img
			src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
 --%>
<div id='dtlDiv' style="position: absolute; top: 0px; left: -2px; visibility: hidden" align='center'>
<iframe src='' name='dtlFrame' width='99%' height='500' id='dtlFrame'></iframe>
</div>
</body>
</html>
