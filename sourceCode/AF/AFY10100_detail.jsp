<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ page import="org.apache.commons.collections.map.ListOrderedMap"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<!-- InstanceBegin template="/Templates/page.dwt" codeOutsideHTMLIsLocked="false" -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<!-- InstanceBeginEditable name="doctitle" -->
<title></title>
<!-- InstanceEndEditable -->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<!-- InstanceBeginEditable name="head" -->

<!-- InstanceEndEditable -->
<head>
<title></title>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0"
	marginheight="0" onLoad="initApp();" onResize="fix()" onScroll="fix()">

	<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
	<!-- 必要 -->
	<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
	<!-- 必要 -->
	<!-- 目前畫面的版面設定 -->
	<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
	<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
	<!--頁碼-->
	<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

	<script language="JavaScript" type="text/JavaScript">	
function stat(){
	//註:firefox 3 已經不支援window.onresize，暫不處理
	if(document.bar1!=null){
		var a = pageYOffset+window.innerHeight-document.bar1.document.height-15;
		document.bar1.top = a;
	}
	setTimeout('stat()',2);
}
function fix(){
	//瀏覽器偵測 navigator.appName 內部編碼名稱...不要再使用
	//appName 瀏覽器的正式名稱
	//navigator.appName IE 傳回 Microsoft Internet Explorer, IE11 傳回 Netscape
	//Firefox, Safari, Chrome 均傳回 Netscape；Opera 傳回 Opera	
	
	if(document.getElementById('bar1')!=null){
		var a=document.body.scrollTop-document.getElementById('bar1').offsetHeight+30;
		bar1.style.top = a;
	}else{
		stat();
	}
}

function initApp(){

	// 頁面 title 定位
	fix();	
	
	// 顯示執行結果
	displayMessage();
}

	//-->
	</script>
	<center>
		<span id="bar1" style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible;">
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
						</table> <!-- InstanceBeginEditable name="title" -->
						<table width="100%" border="0" cellpadding="2" cellspacing="0"
							class="subTitle">
							<tr>
								<td width="20" height="24">
									<div align="center">
										<font size="-5">●</font>
									</div>
								</td>
								<td>公會通報查詢</td>
								<td>
									<div align="right">畫面編號：AFY10100</div>
								</td>
							</tr>
						</table> <!-- InstanceEndEditable -->
					</td>
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
		<form name="frm" id="frm" method="post" action="">
		<table width="100%" height="100%" border="0" cellpadding="0"
			cellspacing="0">
			<tr>
				<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img
					src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
				<td width="100%" valign="top" bgcolor="#F0FBC6">
					<!-- InstanceBeginEditable name="content" -->
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td valign="top">
								<table width=97% border=0 align=center cellpadding="0"
									cellspacing="1" bgcolor="#003366">
									<tbody>
										<tr>
											<td class="tbBox2">
												<p>
													<img src="<%=imageBase%>/CM/icon_dot11.gif" width="18"
														height="16">公會通報查詢
												</p>
											</td>
										</tr>
										<tr bgcolor=#FFFFFF>
											<td><table width="100%" border="0" cellspacing="0"
													cellpadding="5">
													<tr>
														<td>
																<table class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
																	<tbody>
																		<tr>
																			<td class="" id="table_4_R0C0" rowspan="1"
																				colspan="10" width="10%" style="text-align: left;">
																				<span id="input-label_63" class="" style="">資料編輯區</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R1C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_64" class="" style="">通報方式</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R1C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="INSR_TYPE_text">${dataMap.INSR_TYPE}</span>
																			</td>
																			<td class="tbYellow" id="table_4_R1C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_66" class="" style="">公司別</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R1C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="CMNY_CODE_text">${dataMap.CMNY_CODE}</span>
																			</td>
																			<td class="tbYellow" id="table_4_R1C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_68" class="" style="">被保人ID</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R1C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="I_ID_text">${dataMap.I_ID}</span>
																			</td>
																			<td class="tbYellow" id="table_4_R1C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_70" class="" style="">被保人生日</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R1C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="I_BIRTHDAY_text">${dataMap.I_BIRTHDAY}</span>
																			</td>
																			<td class="tbYellow" id="table_4_R1C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_72" class="" style="">保單號碼</span>
																			</td>
																			<td class="tbYellow2" id="table_4_R1C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="POLICY_NO_text">${dataMap.POLICY_NO}</span>
																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R2C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_74" class="" style="">保單分類</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R2C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="POLICY_CAT_text">${dataMap.POLICY_CAT}</span>
																			</td>
																			<td class="tbYellow" id="table_4_R2C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_76" class="" style="">險種分類</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R2C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="POLICY_DUTY_text">${dataMap.POLICY_DUTY}</span>
																			</td>
																			<td class="tbYellow" id="table_4_R2C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_78" class="" style="">險種</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R2C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PROD_KIND_text">${dataMap.PROD_KIND}</span>
																			</td>
																			<td class="tbYellow" id="table_4_R2C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_80" class="" style="">保單狀況</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R2C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="STATUS_text">${dataMap.STATUS}</span>
																			</td>
																			<td class="tbYellow" id="table_4_R2C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_82" class="" style="">保單狀況生效日期(受理理賠日、身故日)</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R2C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="LST_CHG_DATE_text">${dataMap.LST_CHG_DATE}</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R3C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_84" class="" style="">主約保單號碼</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R3C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="MAIN_POLICY_NO_text">${dataMap.MAIN_POLICY_NO}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R3C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_86" class="" style="">契約生效日</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R3C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="ISSUE_DATE_text">${dataMap.ISSUE_DATE}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R3C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_88" class="" style="">契約生效時分</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R3C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="ISSUE_TIME_text">${dataMap.ISSUE_TIME}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R3C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_90" class="" style="">契約滿期日</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R3C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="LPS_DATE_text">${dataMap.LPS_DATE}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R3C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_92" class="" style="">契約滿期時分</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R3C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="LPS_TIME_text">${dataMap.LPS_TIME}</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R4C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_94" class="" style="">要保書填寫日</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R4C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="SIGN_DATE_text">${dataMap.SIGN_DATE}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R4C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_96" class="" style="">保費</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R4C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PREM_text">${dataMap.PREM}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R4C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_98" class="" style="">保費繳別</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R4C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_FREQ_text">${dataMap.PAY_FREQ}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R4C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_100" class="" style="">保費繳費年期</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R4C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_PERIOD_text">${dataMap.PAY_PERIOD}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R4C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_102" class="" style="">保單狀況生效時分</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R4C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="LST_CHG_TIME_text">${dataMap.LST_CHG_TIME}</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R5C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_104" class="" style="">身故</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R5C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT1_text">${dataMap.PAY_AMT1}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R5C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_105" class="" style="">完全失能或最高級失能</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R5C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT2_text">${dataMap.PAY_AMT2}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R5C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_106" class="" style="">失能扶助金</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R5C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT3_text">${dataMap.PAY_AMT3}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R5C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_107" class="" style="">特定事故</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R5C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT4_text">${dataMap.PAY_AMT4}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R5C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_108" class="" style="">初次罹患</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R5C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT5_text">${dataMap.PAY_AMT5}</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R6C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_109" class="" style="">醫療限額</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R6C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT6_text">${dataMap.PAY_AMT6}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R6C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_110" class="" style="">醫療限額自負</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R6C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT7_text">${dataMap.PAY_AMT7}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R6C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_111" class="" style="">醫療日額</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R6C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT8_text">${dataMap.PAY_AMT8}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R6C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_112" class="" style="">住院手術</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R6C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT9_text">${dataMap.PAY_AMT9}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R6C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_113" class="" style="">門診手術</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R6C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT10_text">${dataMap.PAY_AMT10}</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R7C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_114" class="" style="">門診</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R7C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT11_text">${dataMap.PAY_AMT11}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R7C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_115" class="" style="">重大疾/傷病</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R7C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT12_text">${dataMap.PAY_AMT12}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R7C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_116" class="" style="">重大燒燙傷</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R7C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT13_text">${dataMap.PAY_AMT13}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R7C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_117" class="" style="">癌症療養</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R7C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT14_text">${dataMap.PAY_AMT14}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R7C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_118" class="" style="">出院療養</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R7C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT15_text">${dataMap.PAY_AMT15}</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R8C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_119" class="" style="">喪失工作能力</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R8C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT16_text">${dataMap.PAY_AMT16}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R8C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_120" class="" style="">喪葬費用</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R8C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT17_text">${dataMap.PAY_AMT17}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R8C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_121" class="" style="">銜接原醫療限額之自負額</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R8C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT18_text">${dataMap.PAY_AMT18}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R8C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_122" class="" style="">分期給付</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R8C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_AMT19_text">${dataMap.PAY_AMT19}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R8C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_123" class="" style="">保經代分類</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R8C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="BROKTYPE_text">${dataMap.BROKTYPE}</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R9C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_124" class="" style="">要保人姓名</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R9C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="A_NAME_text">${dataMap.A_NAME}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R9C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_125" class="" style="">要保人身分證號碼</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R9C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="A_ID_text">${dataMap.A_ID}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R9C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_126" class="" style="">要保人出生日期</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R9C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="A_BIRTHDAY_text">${dataMap.A_BIRTHDAY}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R9C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_127" class="" style="">要保人與被保險人關係</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R9C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="RELATION_text">${dataMap.RELATION}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R9C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_128" class="" style="">資料寫入時間</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R9C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="UPDATE_TIME_text">${dataMap.UPDATE_TIME}</span>
																			</td>
																		</tr>
																		<tr>
																			<td style="text-align: center;" class="tbYellow">被保險人性別</td>
																			<td style="text-align: center;" class="tbYellow2"><span id="I_GENDER">${genderDesc[dataMap.I_GENDER]}</span></td>
																			<td style="text-align: center;" class="tbYellow">公、自費件</td>
																			<td style="text-align: center;" class="tbYellow2"><span id="PAY_TYPE">${payTypeDesc[dataMap.PAY_TYPE]}</span></td>
																			<td style="text-align: center;" class="tbYellow">來源別</td>
																			<td style="text-align: center;" class="tbYellow2"><span id="OIU_IND">${oiuIndDesc[dataMap.OIU_IND]}</span></td>
																			<td style="text-align: center;" class="tbYellow">銷售通路</td>
																			<td style="text-align: center;" class="tbYellow2"><span id="SALE_CHNL">${saleChnlDesc[dataMap.SALE_CHNL]}</span></td>
																			<td style="text-align: center;" class="tbYellow">商品代碼</td>
																			<td style="text-align: center;" class="tbYellow2"><span id="PROD_CODE">${dataMap.PROD_CODE}</span></td>																		
																		</tr>																		
																		<tr>
																			<td class="tbYellow" id="table_4_R10C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_130" class="" style="">公會取回序號</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R10C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="SER_NO_text">${dataMap.SER_NO}</span>

																			</td>
																			<td class="tbYellow" id="table_4_R10C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">

																			</td>
																			<td class="tbYellow2" id="table_4_R10C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">

																			</td>
																			<td class="tbYellow" id="table_4_R10C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">

																			</td>
																			<td class="tbYellow2" id="table_4_R10C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">

																			</td>
																			<td class="tbYellow" id="table_4_R10C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">

																			</td>
																			<td class="tbYellow2" id="table_4_R10C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">

																			</td>
																			<td class="tbYellow" id="table_4_R10C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">

																			</td>
																			<td class="tbYellow2" id="table_4_R10C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">

																			</td>
																		</tr>
																	</tbody>
																</table>
															</td>
													</tr>
												</table>
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
					</table> 
				</td>
			</tr>
		</table>
	</center>
	</form>
</body>
<!-- InstanceEnd -->
</html>
