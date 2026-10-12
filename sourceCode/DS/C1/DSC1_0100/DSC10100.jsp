<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ page import="com.cathay.common.util.trx.RespCtxUtil"%>
<%@ page import="com.cathay.ds.c1.bo.DSC1_0100_bo"%>
<%--
[20241029]修改件 CHROME瀏覽器難字調整
--%>
<%--
	HttpResponseContext resp = new HttpResponseContext(request); // 取 addOutputData
	HttpTxContext txCxt = new HttpTxContext(session);            // 取 putValue
	RespCtxUtil ctxUtil = new RespCtxUtil(resp);
		
	Map viewData = resp.getOutputData("viewData") == null ? Collections.EMPTY_MAP : (Map)resp.getOutputData("viewData");
	DSC1_0100_bo vo = (DSC1_0100_bo)viewData.get("DSC1_0100_bo");
	pageContext.setAttribute("viewData", viewData);
	pageContext.setAttribute("vo", vo);
	
--%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<title></title>
<%--[20241029]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script src="<%=htmlBase%>/CM/js/pageController.js"></script><!--頁碼-->
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<script language="javascript" type="text/javascript">

function initApp(){
   // 游標定位
	document.form1.LOAN_ID.focus();
  	// 頁面 title 定位
	fix();
	// 顯示執行結果
	displayMessage();
}

//送出form
function doSubmit(btn, act)  {
	var frm = document.form1;

	var validator = new Validator();
	validator.errHandler = new AlertHandler();
	validator.define("LOAN_ID", "", "請輸入貸款帳號", "string", 10, 10, false);
	if(!validator.validate()){		
		validator.errHandler.display();
		return false;
	}

	new Ajax.Request(
		'<%=dispatcher%>/DSC1_0100/query',
		{	method:'post',
			parameters: $('form1').serialize(true),
			onSuccess: function( transport ) {
			
				var json = transport.responseText.evalJSON();
				
				if(CSRUtil.isSuccess(json)){
					var vo = json.viewData.DSC1_0100_bo;
					$('BORROW_ID').innerHTML=!vo.BORROW_ID?"":vo.BORROW_ID;
					$('BORROW_NAME').innerHTML=!vo.BORROW_NAME?"":vo.BORROW_NAME;
					$('REFER_ID').innerHTML=!vo.REFER_ID?"":vo.REFER_ID;
					$('LOAN_DATE').innerHTML=!vo.LOAN_DATE?"":Date.toROC(vo.LOAN_DATE);
					$('DUTY_DAY').innerHTML=!vo.DUTY_DAY?"":vo.DUTY_DAY;
					$('NEXT_PAYDT').innerHTML=!vo.NEXT_PAYDT?"":Date.toROC(vo.NEXT_PAYDT);
					$('SPR_PERIOD').innerHTML=!vo.SPR_PERIOD?"":vo.SPR_PERIOD;
					$('FIX_PERIOD').innerHTML=!vo.FIX_PERIOD?"":vo.FIX_PERIOD;
					$('PAID_TIMES').innerHTML=!vo.PAID_TIMES?"":vo.PAID_TIMES;
					$('LOAN_AMT').innerHTML=!vo.LOAN_AMT?"":CSRUtil.$fmt(vo.LOAN_AMT,"#,###");
					$('SPR_AMT').innerHTML=!vo.SPR_AMT?"":CSRUtil.$fmt(vo.SPR_AMT,"#,###");
					$('FIX_AMT').innerHTML=!vo.FIX_AMT?"":CSRUtil.$fmt(vo.FIX_AMT,"#,###");
					$('AREA_CODE_930318').innerHTML=!vo.AREA_CODE_930318?"":vo.AREA_CODE_930318;
					$('YIELD').innerHTML=!vo.YIELD?"":vo.YIELD+"%";
					$('CALC_DATE').innerHTML=!vo.CALC_DATE?"":Date.toROC(vo.CALC_DATE);
					$('EIR_SPR_AMT').innerHTML=!vo.EIR_SPR_AMT?"":CSRUtil.$fmt(vo.EIR_SPR_AMT,"#,###");
					$('EIR_FIX_AMT').innerHTML=!vo.EIR_FIX_AMT?"":CSRUtil.$fmt(vo.EIR_FIX_AMT,"#,###");
					$('ADJ_BALANCE').innerHTML=!vo.ADJ_BALANCE?"":CSRUtil.$fmt(vo.ADJ_BALANCE,"#,###");
					$('FLEX_PERIOD_NM').innerHTML=!json.viewData.FLEX_PERIOD_NM?"":json.viewData.FLEX_PERIOD_NM;
				}else{
					$('BORROW_ID').innerHTML="";
					$('BORROW_NAME').innerHTML="";
					$('REFER_ID').innerHTML="";
					$('LOAN_DATE').innerHTML="";
					$('DUTY_DAY').innerHTML="";
					$('NEXT_PAYDT').innerHTML="";
					$('SPR_PERIOD').innerHTML="";
					$('FIX_PERIOD').innerHTML="";
					$('PAID_TIMES').innerHTML="";
					$('LOAN_AMT').innerHTML="";
					$('SPR_AMT').innerHTML="";
					$('FIX_AMT').innerHTML="";
					$('AREA_CODE_930318').innerHTML="";
					$('YIELD').innerHTML="";
					$('CALC_DATE').innerHTML="";
					$('EIR_SPR_AMT').innerHTML="";
					$('EIR_FIX_AMT').innerHTML="";
					$('ADJ_BALANCE').innerHTML="";
					$('FLEX_PERIOD_NM').innerHTML="";
				}

            }
		}
	);

	//frm.action="<%=dispatcher%>/DSC1_0100/query";
	//submitOnce(btn);
}

function doLink(YEAR_MONTH) {
	var loan_id = document.getElementById("LOAN_ID").value;
	
	window.location = "<%=dispatcher%>/DSC1_0200/prompt?LOAN_ID=" + loan_id + "&LATEST_PAY_TERM=6";
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
				<td align="right">畫面編號：DSC10100</td>
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
					<p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16" />EIR貸款帳號查詢作業</p>
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
								<td class="tbYellow" width="15%" align="left">貸款帳號</td>
								<td class="tbYellow2" width="85%"><input type="text" name="LOAN_ID" id="LOAN_ID" class='textBox2' size='13' maxLength='10' value=""/>
								&nbsp;<input type="button" name="btn_query" class="button" onclick="doSubmit(this, 'query')" value="查詢" /></td>
							</tr>
						</table>
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
							<tr align="left">
								<td class="tbYellow" width="15%">貸款人ID</td>
								<td class="tbYellow2" width="20%" id="BORROW_ID"></td>
								<td class="tbYellow" width="15%">借款人姓名</td>
								<td class="tbYellow2" width="20%"><span id="BORROW_NAME" style="font-family:'EUDC'"></span></td><%-- [20241030] 難字調整 --%>
								<td class="tbYellow" width="15%">原貸帳號</td>
								<td class="tbYellow2" width="15%" id="REFER_ID"></td>								
							</tr>
							<tr align="left">
								<td class="tbYellow" width="15%">貸放日期</td>
								<td class="tbYellow2" align="right" width="20%" id="LOAN_DATE"></td> 
								<td class="tbYellow" width="15%">應繳日</td>
								<td class="tbYellow2" width="20%" id="DUTY_DAY"></td>
								<td class="tbYellow" width="15%">下次應繳日</td>
								<td class="tbYellow2" align="right" width="15%" id="NEXT_PAYDT"></td>		
							</tr>
							<tr align="left">
								<td class="tbYellow" width="15%">分期期數</td>
								<td class="tbYellow2" width="20%" align="right" id="SPR_PERIOD"></td>
								<td class="tbYellow" width="15%">定期期數</td>
								<td class="tbYellow2" width="20%" align="right" id="FIX_PERIOD"></td>
								<td class="tbYellow" width="15%">已繳期數</td>
								<td class="tbYellow2" width="15%" align="right" id="PAID_TIMES"></td>		
							</tr>
							<tr align="left">
								<td class="tbYellow" width="15%">貸款金額</td>
								<td class="tbYellow2" width="20%" align="right" id="LOAN_AMT"></td>
								<td class="tbYellow" width="15%">分期餘額</td>
								<td class="tbYellow2" width="20%" align="right" id="SPR_AMT"></td>
								<td class="tbYellow" width="15%">定期餘額</td>
								<td class="tbYellow2" width="15%" align="right" id="FIX_AMT"></td>		
							</tr>
							<tr align="left">
								<td class="tbYellow" width="15%">地區別</td>
								<td class="tbYellow2" width="20%" id="AREA_CODE_930318"></td>
								<td class="tbYellow" width="15%">EIR利率</td>
								<td class="tbYellow2" width="20%" align="right" id="YIELD"></td>
								<td class="tbYellow" width="15%">EIR計算日期</td> 
								<td class="tbYellow2" align="right" width="15%" id="CALC_DATE"></td>		
							</tr>
							<tr align="left">
								<td class="tbYellow" width="15%">EIR分期餘額</td>
								<td class="tbYellow2" width="20%" align="right" id="EIR_SPR_AMT"></td>
								<td class="tbYellow" width="15%">EIR定期餘額</td> 
								<td class="tbYellow2" width="20%" align="right" id="EIR_FIX_AMT"></td>
								<td class="tbYellow" width="15%">EIR溢折價累計金額</td>
								<td class="tbYellow2" width="15%" align="right" id="ADJ_BALANCE"></td>	 	 
							</tr>
							<tr align="left">
								<td class="tbYellow" width="15%">查詢連結</td>
								<td class="tbYellow2" width="20%" align="right"><input type="button" name="btn_link" class="button" onclick="doLink(this, 'link')" value="繳息紀錄" /></td>
								<td class="tbYellow" width="15%">本金彈性還期間</td><!--[20230131]新增本金彈性還期間欄位-->
								<td class="tbYellow2" width="20%" id="FLEX_PERIOD_NM"></td>	
								<td class="tbYellow2" width="30%" align="center" colspan="2"></td>
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
