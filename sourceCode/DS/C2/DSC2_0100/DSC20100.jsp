<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ page import="com.cathay.common.util.trx.RespCtxUtil"%>
<%--
	HttpResponseContext resp = new HttpResponseContext(request); // 取 addOutputData
	HttpTxContext txCxt = new HttpTxContext(session);            // 取 putValue
	RespCtxUtil ctxUtil = new RespCtxUtil(resp);
	
	String YEAR_MONTH = ctxUtil.getOutputData_String("YEAR_MONTH");
	Map viewData = ctxUtil.getOutputData_Map("viewData");

	
--%>
<%--
[20241030]修改件 CHROME瀏覽器難字調整
--%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<link href="<%=htmlBase%>/CM/js/ext/resources/css/ext-all.css" rel="stylesheet" type="text/css" />
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
<script language="JavaScript" src="<%=htmlBase%>/CM/js/prototype.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/prototypeUtils.js"></script>

<script language="JavaScript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script> 
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ui/progress.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ext/ext-base.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ext/ext-all.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>

<script src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script src="<%=htmlBase%>/CM/js/pageController.js"></script><!--頁碼-->

<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<script language="javascript" type="text/javascript">

function initApp(){
   // 游標定位
	document.form1.YEAR_MONTH.focus();
  	// 頁面 title 定位
	fix();
	// 顯示執行結果
	displayMessage();
}


//檢核輸入
function checkInput(act) {
	var frm = document.form1;
	var result = true;
	var validator = new Validator();
	validator.errHandler = new AlertHandler();
	//trimSpace(frm);
	
	if (act=='query') {
		
		validator.define("YEAR_MONTH", "", "請輸入提存年月", "string", 4, 5, false);
	} else {
		return false;
	}
	
	if(!validator.validate()){
		result = false;
		validator.errHandler.display();
	}
	return result;
}


//送出form
function doSubmit(btn, act) {
	var frm = document.form1;
	//submitToUpper(frm);
	if(checkInput(act)){
		frm.YEAR_MONTH.value = addPrefix(frm.YEAR_MONTH.value, 5, '0');	//年月補滿5碼	
		new Ajax.Request(
			'<%=dispatcher%>/DSC2_0100/'+ act,
			{	method:'post',
				parameters: $('form1').serialize(true),
				onSuccess: function( transport ) {
					var json = transport.responseText.evalJSON();
					//alert(Object.toJSON(json));				
					if(CSRUtil.isSuccess(json)){
						var vo = json.viewData;
						//alert(vo.YEAR_MONTH);
						YEAR_MONTH = !vo.YEAR_MONTH?"":vo.YEAR_MONTH;
						$('UI_YEAR_MONTH').innerHTML=YEAR_MONTH+'&nbsp;提存資訊';
						$('UI_ACNT_DATE').innerHTML=!vo.ACNT_DATE?"":Date.toROC(vo.ACNT_DATE);
						$('UI_ACNT_DIV_NO').innerHTML=!vo.ACNT_DIV_NO?"":vo.ACNT_DIV_NO;
						$('UI_SLIP_SEQ_NO').innerHTML=!vo.SLIP_SEQ_NO?"":vo.SLIP_SEQ_NO;
						$('UI_SLIP_SET_NO').innerHTML=!vo.SLIP_SET_NO && isNaN(vo.SLIP_SET_NO)?"":vo.SLIP_SET_NO;
						$('UI_SLIP_LOT_NO').innerHTML=!vo.SLIP_LOT_NO?"":vo.SLIP_LOT_NO;
						
						OPR_NAME = !vo.OPR_NAME?"":vo.OPR_NAME;
						OPR_TIME = !vo.OPR_TIME?"":vo.OPR_TIME;
						if(OPR_TIME.length>10){
							OPR_TIME = Date.toROC(OPR_TIME.substr(0,10))
						}
						$('UI_OPR_NAME_OPR_TIME').innerHTML=OPR_NAME+OPR_TIME;
						
						if(!vo.DB_CR && '' == vo.DB_CR){
							$('UI_DB_CR1').innerHTML='';
						}else if('DR'==vo.DB_CR){
							$('UI_DB_CR1').innerHTML='應收利息';
						}else{
							$('UI_DB_CR1').innerHTML='利息收入';
						}

						$('UI_RETAIN_CNT1').innerHTML=!vo.RETAIN_CNT && isNaN(vo.RETAIN_CNT)?"":CSRUtil.$fmt(vo.RETAIN_CNT,'#,###');
						$('UI_RETAIN_INT1').innerHTML=!vo.RETAIN_INT && isNaN(vo.RETAIN_INT)?"":CSRUtil.$fmt(vo.RETAIN_INT,'#,###');
						
						if(!vo.DB_CR && '' == vo.DB_CR){
							$('UI_DB_CR2').innerHTML='';
						}else if('DR'==vo.DB_CR){
							$('UI_DB_CR2').innerHTML='利息收入';
						}else{
							$('UI_DB_CR2').innerHTML='應收利息';
						}
						
						$('UI_RETAIN_CNT2').innerHTML=!vo.RETAIN_CNT && isNaN(vo.RETAIN_CNT)?"":CSRUtil.$fmt(vo.RETAIN_CNT,'#,###');
						$('UI_RETAIN_INT2').innerHTML=!vo.RETAIN_INT && isNaN(vo.RETAIN_INT)?"":CSRUtil.$fmt(vo.RETAIN_INT,'#,###');
						$('UI_ACC_BALANCE').innerHTML=!vo.ACC_BALANCE && isNaN(vo.ACC_BALANCE)?"":CSRUtil.$fmt(vo.ACC_BALANCE,'#,###');

						$('UI_YEAR_MONTH_ADD_RETAIN_INT').innerHTML='<a href="#" onclick="doLink(\''+YEAR_MONTH+'\')">'+CSRUtil.$fmt(vo.ADD_RETAIN_INT,'#,###')+'</a>';
					}else{
						$('UI_YEAR_MONTH').innerHTML="";
						$('UI_ACNT_DATE').innerHTML="";
						$('UI_ACNT_DIV_NO').innerHTML="";
						$('UI_SLIP_SEQ_NO').innerHTML="";
						$('UI_SLIP_SET_NO').innerHTML="";
						$('UI_SLIP_LOT_NO').innerHTML="";
						$('UI_OPR_NAME_OPR_TIME').innerHTML="";
						$('UI_DB_CR1').innerHTML="";
						$('UI_RETAIN_CNT1').innerHTML="";
						$('UI_RETAIN_INT1').innerHTML="";
						$('UI_DB_CR2').innerHTML="";
						$('UI_RETAIN_CNT2').innerHTML="";
						$('UI_RETAIN_INT2').innerHTML="";
						$('UI_ACC_BALANCE').innerHTML="";
						$('UI_YEAR_MONTH_ADD_RETAIN_INT').innerHTML="";
					}
	
	            }
			}
		);
		
	}
	return false;
}

function doLink(YEAR_MONTH) {
	var Quy_YY = '';
	var Quy_MM = '';
	if (YEAR_MONTH.length==4) {
		Quy_YY = YEAR_MONTH.substring(0,2);
		Quy_MM = YEAR_MONTH.substring(2,4);
	} else if (YEAR_MONTH.length==5) {
		Quy_YY = YEAR_MONTH.substring(0,3);
		Quy_MM = YEAR_MONTH.substring(3,5);
	} else {
		return;
	}
	
	window.location = "<%=dispatcher%>/DSM2_0100/query?Quy_YY=" + Quy_YY + "&Quy_MM=" + Quy_MM+"&CAN_BACK=1";
}


//只能輸入數字
function numberOnly(){
	return (event.keyCode > 47 && event.keyCode < 58 );
}

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0"
	marginheight="0" onLoad="initApp();" onResize="fix();"
	onScroll="fix();">
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
				<td align="right">畫面編號：DSC20100</td>
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
					<p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16" />應利提存試算作業</p>
				</td>
			</tr>
			<tr bgcolor="#FFFFFF">
				<td><!-- InstanceBeginEditable name="content" -->
				<table width="100%" border="0" cellspacing="0" cellpadding="5">
					<tr>
						<td>
						<form name="form1" id="form1" method="post" action="">
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
							<tr>
								<td class="tbYellow" width="20%" align="center">提存年月</td>
								<td class="tbYellow2" width="80%"><input type="text" name="YEAR_MONTH" class='textBox2' size='7' maxLength='5' value="<c:out value="${YEAR_MONTH}"/>" onkeypress="return numberOnly()"/>
								&nbsp;<input type="button" name="btn_query" class="button" onclick="doSubmit(this, 'query')" value="查詢" /></td>
							</tr>
						</table>
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
							<tr align="center">
								<td class="tbBlue" colspan="6" id="UI_YEAR_MONTH"><c:out value="${viewData.YEAR_MONTH}"/>&nbsp;提存資訊</td>	
							</tr>
							<tr align="center">
								<td class="tbBlue2" width="20%">傳票日期</td>
								<td class="tbBlue3" width="16%" id="UI_ACNT_DATE"><cathay:calendar type="ROC" value="${viewData.ACNT_DATE}"/></td>
								<td class="tbBlue2" width="16%">製票單位</td>
								<td class="tbBlue3" width="16%" id="UI_ACNT_DIV_NO"><c:out value="${viewData.ACNT_DIV_NO}"/></td>
								<td class="tbBlue2" width="16%">傳票序號</td>
								<td class="tbBlue3" width="16%" id="UI_SLIP_SEQ_NO"><c:out value="${viewData.SLIP_SEQ_NO}"/></td>
							</tr>
							<tr align="center"> 
								<td class="tbBlue2">傳票組號</td>
								<td class="tbBlue3" id="UI_SLIP_SET_NO"><c:out value="${viewData.SLIP_SET_NO}"/></td>
								<td class="tbBlue2">傳票批號</td>
								<td class="tbBlue3" id="UI_SLIP_LOT_NO"><c:out value="${viewData.SLIP_LOT_NO}"/></td>
								<td class="tbBlue2">結帳人員</td>
								<td class="tbBlue3" id="UI_OPR_NAME_OPR_TIME">
									<%-- [20241030] 難字調整 --%><span style="font-family:'EUDC'">${viewData.OPR_NAME}</span>
									&nbsp;<cathay:calendar type="ROC" value="${viewData.OPR_TIME}"/></td>
							</tr>
							<tr align="center">
								<td class="tbBlue2">借方項目</td>
								<td class="tbBlue3" id="UI_DB_CR1">
									<c:choose>
										<c:when test="${viewData.DB_CR eq null || viewData.DB_CR eq ''}"></c:when>
										<c:when test="${viewData.DB_CR eq 'DR'}">應收利息</c:when>
										<c:otherwise>利息收入</c:otherwise>
									</c:choose>
								</td>
								<td class="tbBlue2">件數</td>
								<td class="tbBlue3" align="right" id="UI_RETAIN_CNT1"><fmt:formatNumber type="number" pattern="#,###" value="${viewData.RETAIN_CNT}"/></td>
								<td class="tbBlue2">金額</td>
								<td class="tbBlue3" align="right" id="UI_RETAIN_INT1"><fmt:formatNumber type="number" pattern="#,###" value="${viewData.RETAIN_INT}"/></td>
							</tr>
							<tr align="center">
								<td class="tbBlue2">貸方項目</td>
								<td class="tbBlue3" id="UI_DB_CR2">
									<c:choose>
										<c:when test="${viewData.DB_CR eq null || viewData.DB_CR eq ''}"></c:when>
										<c:when test="${viewData.DB_CR eq 'DR'}">利息收入</c:when>
										<c:otherwise>應收利息</c:otherwise>
									</c:choose>
								</td>
								<td class="tbBlue2">件數</td>
								<td class="tbBlue3" align="right" id="UI_RETAIN_CNT2"><fmt:formatNumber type="number" pattern="#,###" value="${viewData.RETAIN_CNT}"/></td>
								<td class="tbBlue2">金額</td>
								<td class="tbBlue3" align="right" id="UI_RETAIN_INT2"><fmt:formatNumber type="number" pattern="#,###" value="${viewData.RETAIN_INT}"/></td>
							</tr>
							<tr align="center">
								<td class="tbBlue2">會計帳應收利息餘額</td>
								<td class="tbBlue3" align="right" id="UI_ACC_BALANCE"><fmt:formatNumber type="number" pattern="#,###" value="${viewData.ACC_BALANCE}"/></td>
								<td class="tbBlue2">累計應收利息提存</td>
								<td class="tbBlue3" align="right" id="UI_YEAR_MONTH_ADD_RETAIN_INT"><a href="#" onclick="doLink('${YEAR_MONTH}')"><fmt:formatNumber type="number" pattern="#,###" value="${viewData.ADD_RETAIN_INT}"/></a></td>
								<td class="tbBlue2">&nbsp;</td>
								<td class="tbBlue3">&nbsp;</td>
							</tr>
						</table>
						<br/>
						</form>
						</td>
					</tr>
				</table>
				<!-- InstanceEndEditable --></td>
			</tr>
		</table>
		<!-- InstanceEndEditable --></td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img
			src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img
			src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>

<div id='dtlDiv'
	style="position: absolute; top: 0px; left: -2px; visibility: hidden"
	align='center'><iframe src='' name='dtlFrame' width='99%'
	height='500' id='dtlFrame'></iframe></div>
</body>
</html>
