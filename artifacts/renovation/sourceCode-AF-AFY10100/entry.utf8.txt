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
	<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/HotKey.js"></script>
	<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
	<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/sortControler_ac.js"></script><!-- 排序設定 -->	
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
<!-- 設定 Hot Keys -->
function setHotKey(){
	HotKeys.addHotKey(Keys.F2, new ButtonAction(document.frm.btn_query));  // F2 查詢
	HotKeys.addHotKey(Keys.F8, new ButtonAction(document.frm.btn_async));  // F8 即時取回公會資料
	HotKeys.addHotKey(Keys.F9, new ButtonAction(document.frm.editBtn));    // F9 修改
	HotKeys.addHotKey(Keys.F10, new ButtonAction(document.frm.deleteBtn)); // F10 刪除
}
<!-- 排序功能 --> 
function sortTable1(col, tableToSort, rowToSort, dataType, idName){
	var aObj = document.getElementById(idName);
	var sort_type=0;
	
	if (aObj.innerText == '▼') {
		aObj.innerText = '▲';
	 	sort_type = '0';
	} else {
		aObj.innerText = '▼';
	 	sort_type = '1';
	}	
	sortCol = -1;
	sortTable(col, tableToSort, rowToSort, dataType, sort_type, false, '#F0F8FF', '#FAFBE1');
}
<!-- 系統驗證 --> 
function initValidation(){
	valid = new Validation('frm', {useTitles:false});
	valid.define('required', { 
		id: 'inputId', 
		errMsg: '身份證字號/統一編號：不得為空值'
	});	
}
function initApp(){
	fix();            // 頁面 title 定位	
	setHotKey();      // 設定 Hot Key
	initValidation(); // 初始驗證
	displayMessage(); // 顯示執行結果
}

<!-- F2 查詢 -->
function doQuery() {
	var frm = document.frm;
	frm.action = "${dispatcher}/AFY1_0100/doQuery";
	frm.submit();
}

<!-- F10 刪除 -->
function doDelete() {
	var frm = document.frm;
	frm.action = "${dispatcher}/AFY1_0100/doDelete";
	frm.submit();
}

<!-- F9 修改 -->
function doEdit() {
	var frm = document.frm;
	frm.action = "${dispatcher}/AFY1_0100/doEdit";
	frm.submit();
}

<!-- F8 即時取回公會資料 -->
function doASync(){
	var frm = document.frm;
	frm.action = "${dispatcher}/AFY1_0100/doASync";
	frm.submit(); 	
}
function doASyncCheck(){
	if (!valid.validate()) {
		return;
	}	
	
	var inputId = $F("inputId");
	var action = new Ajax.Request("${dispatcher}/AFY1_0100/doASyncCheckId", {		
		parameters: {
			"inputId": inputId
		},
		onSuccess: function(XHT, resp){
			if (resp.isIdError == 'Y') {
				var confirmMsg = "輸入值 " + inputId + " 不符身份證/統一證號檢核規則，請確認，是否要繼續作業?";				
				if (confirm(confirmMsg)){
					doASync();
				}								
			} else {
				doASync();
			}		
		} 
	});
}

//選擇編輯資料
function selectItem(detailRadio) {
	$('TBL_NAME').value = $('TBL_NAME'+detailRadio.value).value;
	$('INSR_TYPE_text').textContent = $('INSR_TYPE'+detailRadio.value).value;
	$('INSR_TYPE').value = $('INSR_TYPE'+detailRadio.value).value;
	$('CMNY_CODE_text').textContent = $('CMNY_CODE'+detailRadio.value).value;
	$('CMNY_CODE').value = $('CMNY_CODE'+detailRadio.value).value;
	$('I_ID_text').textContent = $('I_ID'+detailRadio.value).value;
	$('I_ID').value = $('I_ID'+detailRadio.value).value;
	$('I_BIRTHDAY_text').textContent = $('I_BIRTHDAY'+detailRadio.value).value;
	$('I_BIRTHDAY').value = $('I_BIRTHDAY'+detailRadio.value).value;
	$('POLICY_NO_text').textContent = $('POLICY_NO'+detailRadio.value).value;
	$('POLICY_NO').value = $('POLICY_NO'+detailRadio.value).value;
	$('POLICY_CAT_text').textContent = $('POLICY_CAT'+detailRadio.value).value;
	$('POLICY_CAT').value = $('POLICY_CAT'+detailRadio.value).value;
	$('POLICY_DUTY_text').textContent = $('POLICY_DUTY'+detailRadio.value).value;
	$('POLICY_DUTY').value = $('POLICY_DUTY'+detailRadio.value).value;
	$('PROD_KIND_text').textContent = $('PROD_KIND'+detailRadio.value).value;
	$('PROD_KIND').value = $('PROD_KIND'+detailRadio.value).value;
	$('STATUS_text').textContent = $('STATUS'+detailRadio.value).value;
	$('STATUS').value = $('STATUS'+detailRadio.value).value;
	$('LST_CHG_DATE_text').textContent = $('LST_CHG_DATE'+detailRadio.value).value;
	$('LST_CHG_DATE').value = $('LST_CHG_DATE'+detailRadio.value).value;
	$('MAIN_POLICY_NO_text').textContent = $('MAIN_POLICY_NO'+detailRadio.value).value;
	$('MAIN_POLICY_NO').value = $('MAIN_POLICY_NO'+detailRadio.value).value;
	$('ISSUE_DATE_text').textContent = $('ISSUE_DATE'+detailRadio.value).value;
	$('ISSUE_DATE').value = $('ISSUE_DATE'+detailRadio.value).value;
	$('ISSUE_TIME_text').textContent = $('ISSUE_TIME'+detailRadio.value).value;
	$('ISSUE_TIME').value = $('ISSUE_TIME'+detailRadio.value).value;
	$('LPS_DATE_text').textContent = $('LPS_DATE'+detailRadio.value).value;
	$('LPS_DATE').value = $('LPS_DATE'+detailRadio.value).value;
	$('LPS_TIME_text').textContent = $('LPS_TIME'+detailRadio.value).value;
	$('LPS_TIME').value = $('LPS_TIME'+detailRadio.value).value;
	$('SIGN_DATE_text').textContent = $('SIGN_DATE'+detailRadio.value).value;
	$('SIGN_DATE').value = $('SIGN_DATE'+detailRadio.value).value;
	$('PREM_text').textContent = $('PREM'+detailRadio.value).value;
	$('PREM').value = $('PREM'+detailRadio.value).value;
	$('PAY_FREQ_text').textContent = $('PAY_FREQ'+detailRadio.value).value;
	$('PAY_FREQ').value = $('PAY_FREQ'+detailRadio.value).value;
	$('PAY_PERIOD_text').textContent = $('PAY_PERIOD'+detailRadio.value).value;
	$('PAY_PERIOD').value = $('PAY_PERIOD'+detailRadio.value).value;
	$('LST_CHG_TIME_text').textContent = $('LST_CHG_TIME'+detailRadio.value).value;
	$('LST_CHG_TIME').value = $('LST_CHG_TIME'+detailRadio.value).value;
	$('PAY_AMT1').value = $('PAY_AMT1_'+detailRadio.value).value;
	$('PAY_AMT2').value = $('PAY_AMT2_'+detailRadio.value).value;
	$('PAY_AMT3').value = $('PAY_AMT3_'+detailRadio.value).value;
	$('PAY_AMT4').value = $('PAY_AMT4_'+detailRadio.value).value;
	$('PAY_AMT5').value = $('PAY_AMT5_'+detailRadio.value).value;
	$('PAY_AMT6').value = $('PAY_AMT6_'+detailRadio.value).value;
	$('PAY_AMT7').value = $('PAY_AMT7_'+detailRadio.value).value;
	$('PAY_AMT8').value = $('PAY_AMT8_'+detailRadio.value).value;
	$('PAY_AMT9').value = $('PAY_AMT9_'+detailRadio.value).value;
	$('PAY_AMT10').value = $('PAY_AMT10_'+detailRadio.value).value;
	$('PAY_AMT11').value = $('PAY_AMT11_'+detailRadio.value).value;
	$('PAY_AMT12').value = $('PAY_AMT12_'+detailRadio.value).value;
	$('PAY_AMT13').value = $('PAY_AMT13_'+detailRadio.value).value;
	$('PAY_AMT14').value = $('PAY_AMT14_'+detailRadio.value).value;
	$('PAY_AMT15').value = $('PAY_AMT15_'+detailRadio.value).value;
	$('PAY_AMT16').value = $('PAY_AMT16_'+detailRadio.value).value;
	$('PAY_AMT17').value = $('PAY_AMT17_'+detailRadio.value).value;
	$('PAY_AMT18').value = $('PAY_AMT18_'+detailRadio.value).value;
	$('PAY_AMT19').value = $('PAY_AMT19_'+detailRadio.value).value;
	$('BROKTYPE').value = $('BROKTYPE'+detailRadio.value).value;
	$('A_NAME').value = $('A_NAME'+detailRadio.value).value;
	$('A_ID').value = $('A_ID'+detailRadio.value).value;
	$('A_BIRTHDAY').value = $('A_BIRTHDAY'+detailRadio.value).value;
	$('RELATION').value = $('RELATION'+detailRadio.value).value;
	$('UPDATE_TIME_text').textContent = $('INPUT_TIME'+detailRadio.value).value; // 編輯區內取 INPUT_TIME
	$('UPDATE_TIME').value = $('UPDATE_TIME'+detailRadio.value).value;
	$('SER_NO_text').textContent = $('SER_NO'+detailRadio.value).value;
	$('SER_NO').value = $('SER_NO'+detailRadio.value).value;
	$('I_GENDER').value = $('I_GENDER'+detailRadio.value).value; // 性別
	$('PAY_TYPE').value = $('PAY_TYPE'+detailRadio.value).value; // 公、自費 
	$('OIU_IND').textContent = $('OIU_IND_DESC'+detailRadio.value).value;     // 來源別
	$('SALE_CHNL').textContent = $('SALE_CHNL_DESC'+detailRadio.value).value; // 銷售通路				
    $('PROD_CODE').textContent = $('PROD_CODE'+detailRadio.value).value;      // 商品代碼
	
	$('editBtn').disabled = false;
	$('deleteBtn').disabled = false;
	$('cleanAllBtn').disabled = false;
	$('editArea').style.display = "block";
	
	parseEUDC();
}

function doCleanAll() {
	$('TBL_NAME').value = "";
	$('INSR_TYPE_text').textContent = "";
	$('INSR_TYPE').value = "";
	$('CMNY_CODE_text').textContent = "";
	$('CMNY_CODE').value = "";
	$('I_ID_text').textContent = "";
	$('I_ID').value = "";
	$('I_BIRTHDAY_text').textContent = "";
	$('I_BIRTHDAY').value = "";
	$('POLICY_NO_text').textContent = "";
	$('POLICY_NO').value = "";
	$('POLICY_CAT_text').textContent = "";
	$('POLICY_CAT').value = "";
	$('POLICY_DUTY_text').textContent = "";
	$('POLICY_DUTY').value = "";
	$('PROD_KIND_text').textContent = "";
	$('PROD_KIND').value = "";
	$('STATUS_text').textContent = "";
	$('STATUS').value = "";
	$('LST_CHG_DATE_text').textContent = "";
	$('LST_CHG_DATE').value = "";
	$('MAIN_POLICY_NO_text').textContent = "";
	$('MAIN_POLICY_NO').value = "";
	$('ISSUE_DATE_text').textContent = "";
	$('ISSUE_DATE').value = "";
	$('ISSUE_TIME_text').textContent = "";
	$('ISSUE_TIME').value = "";
	$('LPS_DATE_text').textContent = "";
	$('LPS_DATE').value = "";
	$('LPS_TIME_text').textContent = "";
	$('LPS_TIME').value = "";
	$('SIGN_DATE_text').textContent = "";
	$('SIGN_DATE').value = ""
	$('PREM_text').textContent = "";
	$('PREM').value = "";
	$('PAY_FREQ_text').textContent = "";
	$('PAY_FREQ').value = "";
	$('PAY_PERIOD_text').textContent = "";
	$('PAY_PERIOD').value = "";
	$('LST_CHG_TIME_text').textContent = "";
	$('LST_CHG_TIME').value = "";
	$('PAY_AMT1').value = "";
	$('PAY_AMT2').value = "";
	$('PAY_AMT3').value = "";
	$('PAY_AMT4').value = "";
	$('PAY_AMT5').value = "";
	$('PAY_AMT6').value = "";
	$('PAY_AMT7').value = "";
	$('PAY_AMT8').value = "";
	$('PAY_AMT9').value = "";
	$('PAY_AMT10').value = "";
	$('PAY_AMT11').value = "";
	$('PAY_AMT12').value = "";
	$('PAY_AMT13').value = "";
	$('PAY_AMT14').value = "";
	$('PAY_AMT15').value = "";
	$('PAY_AMT16').value = "";
	$('PAY_AMT17').value = "";
	$('PAY_AMT18').value = "";
	$('PAY_AMT19').value = "";
	$('BROKTYPE').value = "";
	$('A_NAME').value = "";
	$('A_ID').value = "";
	$('A_BIRTHDAY').value = "";
	$('RELATION').value = "";
	$('UPDATE_TIME_text').textContent = "";
	$('UPDATE_TIME').value = "";
	$('SER_NO_text').textContent = "";
	$('SER_NO').value = "";
	$('I_GENDER').value = "";
	$('PAY_TYPE').value = "";
	$('OIU_IND').textContent = "";
	$('SALE_CHNL').textContent = "";
	$('PROD_CODE').textContent = "";
	
	var ele = document.getElementsByName("item");
   	for(var i=0;i<ele.length;i++){
   		ele[i].checked = false;
   	}
   	
   	$('editBtn').disabled = true;
	$('deleteBtn').disabled = true;
	$('cleanAllBtn').disabled = true;
	$('editArea').style.display = "none";
}

function openDetail(index){
	var url="<%=dispatcher%>/AFY1_0100/doShowDetail?"+
			"INSR_TYPE="+$('INSR_TYPE'+index).value+
			"&CMNY_CODE="+$('CMNY_CODE'+index).value+
			"&I_ID="+$('I_ID'+index).value+
			"&I_BIRTHDAY="+$('I_BIRTHDAY'+index).value+
			"&POLICY_NO="+$('POLICY_NO'+index).value+
			"&POLICY_CAT="+$('POLICY_CAT'+index).value+
			"&POLICY_DUTY="+$('POLICY_DUTY'+index).value+
			"&PROD_KIND="+$('PROD_KIND'+index).value+
			"&STATUS="+$('STATUS'+index).value+
			"&LST_CHG_DATE="+$('LST_CHG_DATE'+index).value+
			"&MAIN_POLICY_NO="+$('MAIN_POLICY_NO'+index).value+
			"&ISSUE_DATE="+$('ISSUE_DATE'+index).value+
			"&ISSUE_TIME="+$('ISSUE_TIME'+index).value+
			"&LPS_DATE="+$('LPS_DATE'+index).value+
			"&LPS_TIME="+$('LPS_TIME'+index).value+
			"&SIGN_DATE="+$('SIGN_DATE'+index).value+
			"&PREM="+$('PREM'+index).value+
			"&PAY_FREQ="+$('PAY_FREQ'+index).value+
			"&PAY_PERIOD="+$('PAY_PERIOD'+index).value+
			"&LST_CHG_TIME="+$('LST_CHG_TIME'+index).value+
			"&PAY_AMT1="+$('PAY_AMT1_'+index).value+
			"&PAY_AMT2="+$('PAY_AMT2_'+index).value+
			"&PAY_AMT3="+$('PAY_AMT3_'+index).value+
			"&PAY_AMT4="+$('PAY_AMT4_'+index).value+
			"&PAY_AMT5="+$('PAY_AMT5_'+index).value+
			"&PAY_AMT6="+$('PAY_AMT6_'+index).value+
			"&PAY_AMT7="+$('PAY_AMT7_'+index).value+
			"&PAY_AMT8="+$('PAY_AMT8_'+index).value+
			"&PAY_AMT9="+$('PAY_AMT9_'+index).value+
			"&PAY_AMT10="+$('PAY_AMT10_'+index).value+
			"&PAY_AMT11="+$('PAY_AMT11_'+index).value+
			"&PAY_AMT12="+$('PAY_AMT12_'+index).value+
			"&PAY_AMT13="+$('PAY_AMT13_'+index).value+
			"&PAY_AMT14="+$('PAY_AMT14_'+index).value+
			"&PAY_AMT15="+$('PAY_AMT15_'+index).value+
			"&PAY_AMT16="+$('PAY_AMT16_'+index).value+
			"&PAY_AMT17="+$('PAY_AMT17_'+index).value+
			"&PAY_AMT18="+$('PAY_AMT18_'+index).value+
			"&PAY_AMT19="+$('PAY_AMT19_'+index).value+
			"&BROKTYPE="+$('BROKTYPE'+index).value+
			"&A_NAME="+$('A_NAME'+index).value+
			"&A_ID="+$('A_ID'+index).value+
			"&A_BIRTHDAY="+$('A_BIRTHDAY'+index).value+
			"&RELATION="+$('RELATION'+index).value+
			"&UPDATE_TIME="+$('UPDATE_TIME'+index).value+
			"&SER_NO="+$('SER_NO'+index).value+
			"&I_GENDER="+$('I_GENDER'+index).value+
			"&PAY_TYPE="+$('PAY_TYPE'+index).value+
			"&OIU_IND="+$('OIU_IND'+index).value+
			"&SALE_CHNL="+$('SALE_CHNL'+index).value+
			"&PROD_CODE="+$('PROD_CODE'+index).value;
	
	window.open(url);	
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
															<table width="100%" border=0 cellpadding=0 cellspacing=1 class="tbBox2">
																<tr>
																	<td class="tbYellow" rowspan="1" colspan="1" width="8%" style="text-align:left;">
																	身份證字號/統一編號
																	</td>
																	<td class="tbYellow2" rowspan="1" colspan="1" style="text-align:left;">
																		<input id="inputId" name="inputId" value="${inputId}" type="text" class="textBox2"/>
																		<c:if test="${isReturn}">
																			<input type="checkbox" id="IS_RETURN" name="IS_RETURN" value="Y"/>同步更新公會回檔狀態
																		</c:if>
																	</td>
																	<td class="tbYellow" rowspan="1" colspan="1" width="8%" style="text-align:left;">
																	契約角色
																	</td>
																	<td class="tbYellow2" rowspan="1" colspan="1" style="text-align:left;">
																	<select id="role" name="role">
																		<option value="I" <c:if test="${role eq 'I' }">selected</c:if>>被保人</option>
																		<option value="A" <c:if test="${role eq 'A' }">selected</c:if>>要保人</option>
																	</select>
																	</td>
																	<td class="tbYellow" rowspan="1" colspan="1" width="8%" style="text-align:left;">
																	保單效力
																	</td>
																	<td class="tbYellow2" rowspan="1" colspan="1" style="text-align:left;">
																	<select id="status" name="status">
																		<option value="Y" <c:if test="${status eq 'Y' }">selected</c:if>>有效</option>
																		<option value="N" <c:if test="${status eq 'N' }">selected</c:if>>無效</option>
																		<option value="A" <c:if test="${status eq 'A' }">selected</c:if>>全部</option>
																	</select>
																	</td>
																	<td class="tbYellow2" rowspan="3" colspan="1" style="text-align:center;">
																		<input id="btn_query" name="btn_query" type="button"
																		class="button" value="F2查詢" onclick="doQuery()" />
																	</td>
																</tr>
																<tr>
																	<td class="tbYellow" rowspan="1" colspan="1" width="8%" style="text-align:left;">
																	姓名
																	</td>
																	<td class="tbYellow2" rowspan="1" colspan="1" style="text-align:left;">
																		<input alt='ch' class="textDisable" readonly="readonly" value='${dataMap.NAME}'>
																	</td>
																	<td class="tbYellow" rowspan="1" colspan="1" width="8%" style="text-align:left;">
																	生日
																	</td>
																	<td class="tbYellow2" rowspan="1" colspan="1" style="text-align:left;">
																	${dataMap.BIRTHDAY}
																	</td>
																	<td class="tbYellow" rowspan="1" colspan="1" width="8%" style="text-align:left;">
																	公會資料取回日期
																	</td>
																	<td class="tbYellow2" rowspan="1" colspan="2" style="text-align:left;">
																	${dataMap.LAST_UPDATE_TIME}
																	</td>
																</tr>
															</table>
															<table width="100%" cellpadding="1" cellspacing="1" class="tbBox2">
																<tbody>
																	<tr>
																		<td class="" id="table_2_R0C0" rowspan="1"
																			colspan="16" width="" style="text-align:;"><span
																			id="input-label_12" class="" style="">保障項目彙整</span>
																		</td>
																	</tr>
																	<tr>
																		<%-- 保障項目彙整 A --%>
																		<td class="tbBlue2" id="table_2_R1C0" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_13" class="" style="">項目</span>
																		</td>
																		<td class="tbBlue" id="table_2_R1C1" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_14" class="" style="">合計</span>
																		</td>
																		<td class="tbBlue" style="text-align: center;">同業合計</td>
																		<td class="tbBlue" id="table_2_R1C2" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_15" class="" style="">收件</span>
																		</td>
																		<td class="tbBlue" id="table_2_R1C3" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_16" class="" style="">承保</span>
																		</td>
																		<%-- 保障項目彙整 B --%>
																		<td class="tbBlue2" id="table_2_R1C4" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_17" class="" style="">項目</span>
																		</td>
																		<td class="tbBlue" id="table_2_R1C5" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_18" class="" style="">合計</span>
																		</td>
																		<td class="tbBlue" style="text-align: center;">同業合計</td>
																		<td class="tbBlue" id="table_2_R1C6" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_19" class="" style="">收件</span>
																		</td>
																		<td class="tbBlue" id="table_2_R1C7" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_20" class="" style="">承保</span>
																		</td>
																		<%-- 保障項目彙整 Sector C --%>
																		<td class="tbBlue2" id="table_2_R1C8" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_21" class="" style="">項目</span>
																		</td>
																		<td class="tbBlue" id="table_2_R1C9" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_22" class="" style="">合計</span>
																		</td>
																		<td class="tbBlue" style="text-align: center;">同業合計</td>
																		<td class="tbBlue" id="table_2_R1C10" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_23" class="" style="">收件</span>
																		</td>
																		<td class="tbBlue" id="table_2_R1C11" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_24" class="" style="">承保</span>
																		</td>
																	</tr>
																	<tr>
																		<td class="tbBlue2" id="table_2_R2C0" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_29" class="" style="">身故</span>
																		</td>
																		<td class="tbYellow2" id="table_2_R2C1" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT1_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT1_TotSame}' />
																		</td>
																		</td>
																		<td class="tbYellow2" id="table_2_R2C2" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT1_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R2C3" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT1_LN}' />
																		</td>																																					
																		<td class="tbBlue2" id="table_2_R2C4" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_30" class="" style="">完全失能或最高級失能</span>
																		</td>																			
																		<td class="tbYellow2" id="table_2_R2C5" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT2_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT2_TotSame}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R2C6" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT2_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R2C7" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT2_LN}' />
																		</td>																			
																		<td class="tbBlue2" id="table_2_R2C8" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_31" class="" style="">失能扶助金</span>
																		</td>
																		<td class="tbYellow2" id="table_2_R2C9" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT3_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT3_TotSame}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R2C10" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT3_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R2C11" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT3_LN}' />
																		</td>
																	</tr>
																	<tr>
																		<td class="tbBlue2" id="table_2_R2C12" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_32" class="" style="">特定事故</span>
																		</td>
																		<td class="tbYellow2" id="table_2_R2C13" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT4_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT4_TotSame}' />
																		</td>																			
																		<td class="tbYellow2" id="table_2_R2C14" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT4_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R2C15" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT4_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R3C0" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_33" class="" style="">初次罹患</span>
																		</td>																			
																		<td class="tbYellow3" id="table_2_R3C1" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT5_Tot}' />
																		</td>
																		<td class="tbYellow3" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT5_TotSame}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R3C2" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT5_Rr}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R3C3" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT5_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R3C4" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_34" class="" style="">醫療限額</span>
																		</td>																			
																		<td class="tbYellow3" id="table_2_R3C5" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT6_Tot}' />
																		</td>
																		<td class="tbYellow3" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT6_TotSame}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R3C6" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT6_Rr}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R3C7" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT6_LN}' />
																		</td>
																	</tr>
																	<tr>
																		<td class="tbBlue2" id="table_2_R3C8" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_35" class="" style="">醫療限額自負</span>
																		</td>																			
																		<td class="tbYellow3" id="table_2_R3C9" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT7_Tot}' />
																		</td>
																		<td class="tbYellow3" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT7_TotSame}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R3C10" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT7_Rr}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R3C11" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT7_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R3C12" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_36" class="" style="">醫療日額</span>
																		</td>																			
																		<td class="tbYellow3" id="table_2_R3C13" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT8_Tot}' />
																		</td>
																		<td class="tbYellow3" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT8_TotSame}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R3C14" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT8_Rr}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R3C15" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT8_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R4C0" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_37" class="" style="">住院手術</span>
																		</td>																			
																		<td class="tbYellow2" id="table_2_R4C1" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT9_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT9_TotSame}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R4C2" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT9_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R4C3" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT9_LN}' />
																		</td>
																	</tr>
																	<tr>																			
																		<td class="tbBlue2" id="table_2_R4C4" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_38" class="" style="">門診手術</span>
																		</td>																			
																		<td class="tbYellow2" id="table_2_R4C5" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT10_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT10_TotSame}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R4C6" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT10_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R4C7" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT10_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R4C8" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_39" class="" style="">門診</span>
																		</td>																			
																		<td class="tbYellow2" id="table_2_R4C9" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT11_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT11_TotSame}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R4C10" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT11_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R4C11" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT11_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R4C12" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_40" class="" style="">重大疾/傷病</span>
																		</td>																			
																		<td class="tbYellow2" id="table_2_R4C13" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT12_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT12_TotSame}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R4C14" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT12_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R4C15" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT12_LN}' />
																		</td>
																	</tr>
																	<tr>
																		<td class="tbBlue2" id="table_2_R5C0" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_41" class="" style="">重大傷燙傷</span>
																		</td>																			
																		<td class="tbYellow3" id="table_2_R5C1" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT13_Tot}' />
																		</td>
																		<td class="tbYellow3" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT13_TotSame}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R5C2" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT13_Rr}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R5C3" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT13_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R5C4" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_42" class="" style="">癌症療養</span>
																		</td>																			
																		<td class="tbYellow3" id="table_2_R5C5" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT14_Tot}' />
																		</td>
																		<td class="tbYellow3" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT14_TotSame}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R5C6" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT14_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R5C7" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT14_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R5C8" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_43" class="" style="">出院療養</span>
																		</td>
																		<td class="tbYellow3" id="table_2_R5C9" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT15_Tot}' />
																		</td>
																		<td class="tbYellow3" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT15_TotSame}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R5C10" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT15_Rr}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R5C11" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT15_LN}' />
																		</td>
																	</tr>
																	<tr>
																		<td class="tbBlue2" id="table_2_R5C12" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_44" class="" style="">喪失工作能力</span>
																		</td>																			
																		<td class="tbYellow3" id="table_2_R5C13" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT16_Tot}' />
																		</td>
																		<td class="tbYellow3" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT16_TotSame}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R5C14" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT16_Rr}' />
																		</td>
																		<td class="tbYellow3" id="table_2_R5C15" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT16_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R6C0" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_45" class="" style="">喪葬費用</span>
																		</td>																			
																		<td class="tbYellow2" id="table_2_R6C1" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT17_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT17_TotSame}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R6C2" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT17_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R6C3" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT17_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R6C4" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_46" class="" style="">銜接原醫療限額之自負額</span>
																		</td>
																		<td class="tbYellow2" id="table_2_R6C5" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT18_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT18_TotSame}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R6C6" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT18_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R6C7" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT18_LN}' />
																		</td>
																	</tr>
																	<tr>
																		<td class="tbBlue2" id="table_2_R6C8" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<span id="input-label_47" class="" style="">分期給付</span>
																		</td>																			
																		<td class="tbYellow2" id="table_2_R6C9" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT19_Tot}' />
																		</td>
																		<td class="tbYellow2" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT19_TotSame}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R6C10" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT19_Rr}' />
																		</td>
																		<td class="tbYellow2" id="table_2_R6C11" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																			<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.PAY_AMT19_LN}' />
																		</td>
																		<td class="tbBlue2" id="table_2_R6C12" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																		</td>
																		<td class="tbYellow2" id="table_2_R6C13" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																		</td>
																		<td class="tbYellow2" id="table_2_R6C14" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																		</td>
																		<td class="tbYellow2" id="table_2_R6C15" rowspan="1"
																			colspan="1" width="" style="text-align: center;">
																		</td>
																		<td class="tbYellow2"></td>
																		<td class="tbBlue2"></td>
																		<td class="tbYellow2"></td>
																		<td class="tbYellow2"></td>
																		<td class="tbYellow2"></td>
																		<td class="tbYellow2"></td>
																	</tr>
																</tbody>
															</table>  
																<table width="100%" cellpadding="1" cellspacing="1"
																	class="tbBox2">
																	<tbody>
																		<tr>
																			<td class="" id="table_3_R0C0" rowspan="1"
																				colspan="13" width="" style="text-align:;"><span
																				id="input-label_48" class="" style="">保費資料彙整</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbBlue2" id="table_3_R1C0" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_49" class="" style="">項目</span>

																			</td>
																			<td class="tbBlue" id="table_3_R1C1" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_50" class="" style="">合計</span>

																			</td>
																			<td class="tbBlue" id="table_3_R1C2" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_51" class="" style="">收件</span>

																			</td>
																			<td class="tbBlue" id="table_3_R1C3" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_52" class="" style="">承保</span>

																			</td>
																			<td class="tbBlue2" id="table_3_R1C4" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_53" class="" style="">項目</span>

																			</td>
																			<td class="tbBlue" id="table_3_R1C5" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_54" class="" style="">合計</span>

																			</td>
																			<td class="tbBlue" id="table_3_R1C6" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_55" class="" style="">收件</span>

																			</td>
																			<td class="tbBlue" id="table_3_R1C7" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_56" class="" style="">承保</span>

																			</td>
																			<td class="tbBlue2" id="table_3_R1C8" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_57" class="" style="">項目</span>

																			</td>
																			<td class="tbBlue" id="table_3_R1C9" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_58" class="" style="">合計</span>

																			</td>
																			<td class="tbBlue" id="table_3_R1C10" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_59" class="" style="">收件</span>

																			</td>
																			<td class="tbBlue" id="table_3_R1C11" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_60" class="" style="">承保</span>

																			</td>
																			<td class="tbBlue" id="table_3_R1C12" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_61" class="" style="">操作者</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbBlue2" id="table_3_R2C0" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_62" class="" style="">年繳保費</span>

																			</td>
																			<td class="tbYellow2" id="table_3_R2C1" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.YEAR_PREM_Tot}' />
																			</td>
																			<td class="tbYellow2" id="table_3_R2C2" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.YEAR_PREM_Rr}' />
																			</td>
																			<td class="tbYellow2" id="table_3_R2C3" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.YEAR_PREM_LN}' />
																			</td>
																			<td class="tbBlue2" id="table_3_R2C4" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_63" class="" style="">躉繳保費</span>

																			</td>
																			<td class="tbYellow2" id="table_3_R2C5" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.ONCE_PREM_Tot}' />
																			</td>
																			<td class="tbYellow2" id="table_3_R2C6" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.ONCE_PREM_Rr}' />
																			</td>
																			<td class="tbYellow2" id="table_3_R2C7" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.ONCE_PREM_LN}' />
																			</td>
																			<td class="tbBlue2" id="table_3_R2C8" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_64" class="" style="">超額(彈性)保險費</span>

																			</td>
																			<td class="tbYellow2" id="table_3_R2C9" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.FLEX_PREM_Tot}' />
																			</td>
																			<td class="tbYellow2" id="table_3_R2C10" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.FLEX_PREM_Rr}' />
																			</td>
																			<td class="tbYellow2" id="table_3_R2C11" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value='${dataMap.FLEX_PREM_LN}' />
																			</td>
																			<td class="tbYellow2" id="table_3_R2C12" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				${dataMap.UPDATE_ID}
																			</td>
																		</tr>
																	</tbody>
																</table>
																<table id="editArea" style="display:none" class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
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
																				<span id="INSR_TYPE_text"></span>
																				<input type="hidden" id="INSR_TYPE" name="INSR_TYPE" value="">
																			</td>
																			<td class="tbYellow" id="table_4_R1C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_66" class="" style="">公司別</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R1C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="CMNY_CODE_text"></span>
																				<input type="hidden" id="CMNY_CODE" name="CMNY_CODE" value="">
																			</td>
																			<td class="tbYellow" id="table_4_R1C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_68" class="" style="">被保人ID</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R1C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="I_ID_text"></span>
																				<input type="hidden" id="I_ID" name="I_ID" value="">
																			</td>
																			<td class="tbYellow" id="table_4_R1C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_70" class="" style="">被保人生日</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R1C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="I_BIRTHDAY_text"></span>
																				<input type="hidden" id="I_BIRTHDAY" name="I_BIRTHDAY" value="">
																			</td>
																			<td class="tbYellow" id="table_4_R1C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_72" class="" style="">保單號碼</span>
																			</td>
																			<td class="tbYellow2" id="table_4_R1C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="POLICY_NO_text"></span>
																				<input type="hidden" id="POLICY_NO" name="POLICY_NO" value="">
																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R2C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_74" class="" style="">保單分類</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R2C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="POLICY_CAT_text"></span>
																				<input type="hidden" id="POLICY_CAT" name="POLICY_CAT" value="">
																			</td>
																			<td class="tbYellow" id="table_4_R2C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_76" class="" style="">險種分類</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R2C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="POLICY_DUTY_text"></span>
																				<input type="hidden" id="POLICY_DUTY" name="POLICY_DUTY" value="">
																			</td>
																			<td class="tbYellow" id="table_4_R2C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_78" class="" style="">險種</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R2C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PROD_KIND_text"></span>
																				<input type="hidden" id="PROD_KIND" name="PROD_KIND" value="">
																			</td>
																			<td class="tbYellow" id="table_4_R2C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_80" class="" style="">保單狀況</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R2C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="STATUS_text"></span>
																				<input type="hidden" id="STATUS" name="STATUS" value="">
																			</td>
																			<td class="tbYellow" id="table_4_R2C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_82" class="" style="">保單狀況生效日期(受理理賠日、身故日)</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R2C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="LST_CHG_DATE_text"></span>
																				<input type="hidden" id="LST_CHG_DATE" name="LST_CHG_DATE" value="">

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R3C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_84" class="" style="">主約保單號碼</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R3C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="MAIN_POLICY_NO_text"></span>
																				<input type="hidden" id="MAIN_POLICY_NO" name="MAIN_POLICY_NO" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R3C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_86" class="" style="">契約生效日</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R3C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="ISSUE_DATE_text"></span>
																				<input type="hidden" id="ISSUE_DATE" name="ISSUE_DATE" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R3C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_88" class="" style="">契約生效時分</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R3C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="ISSUE_TIME_text"></span>
																				<input type="hidden" id="ISSUE_TIME" name="ISSUE_TIME" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R3C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_90" class="" style="">契約滿期日</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R3C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="LPS_DATE_text"></span>
																				<input type="hidden" id="LPS_DATE" name="LPS_DATE" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R3C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_92" class="" style="">契約滿期時分</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R3C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="LPS_TIME_text"></span>
																				<input type="hidden" id="LPS_TIME" name="LPS_TIME" value="">

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R4C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_94" class="" style="">要保書填寫日</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R4C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="SIGN_DATE_text"></span>
																				<input type="hidden" id="SIGN_DATE" name="SIGN_DATE" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R4C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_96" class="" style="">保費</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R4C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PREM_text"></span>
																				<input type="hidden" id="PREM" name="PREM" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R4C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_98" class="" style="">保費繳別</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R4C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_FREQ_text"></span>
																				<input type="hidden" id="PAY_FREQ" name="PAY_FREQ" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R4C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_100" class="" style="">保費繳費年期</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R4C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="PAY_PERIOD_text"></span>
																				<input type="hidden" id="PAY_PERIOD" name="PAY_PERIOD" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R4C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_102" class="" style="">保單狀況生效時分</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R4C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="LST_CHG_TIME_text"></span>
																				<input type="hidden" id="LST_CHG_TIME" name="LST_CHG_TIME" value="">

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R5C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_104" class="" style="">身故</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R5C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT1" name="PAY_AMT1" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R5C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_105" class="" style="">完全失能或最高級失能</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R5C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT2" name="PAY_AMT2" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R5C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_106" class="" style="">失能扶助金</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R5C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT3" name="PAY_AMT3" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R5C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_107" class="" style="">特定事故</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R5C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT4" name="PAY_AMT4" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R5C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_108" class="" style="">初次罹患</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R5C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT5" name="PAY_AMT5" title="" maxlength=""
																				size="" value="">

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R6C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_109" class="" style="">醫療限額</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R6C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT6" name="PAY_AMT6" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R6C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_110" class="" style="">醫療限額自負</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R6C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT7" name="PAY_AMT7" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R6C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_111" class="" style="">醫療日額</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R6C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT8" name="PAY_AMT8" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R6C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_112" class="" style="">住院手術</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R6C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT9" name="PAY_AMT9" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R6C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_113" class="" style="">門診手術</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R6C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT10" name="PAY_AMT10" title="" maxlength=""
																				size="" value="">

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R7C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_114" class="" style="">門診</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R7C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT11" name="PAY_AMT11" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R7C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_115" class="" style="">重大疾/傷病</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R7C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT12" name="PAY_AMT12" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R7C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_116" class="" style="">重大燒燙傷</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R7C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT13" name="PAY_AMT13" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R7C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_117" class="" style="">癌症療養</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R7C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT14" name="PAY_AMT14" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R7C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_118" class="" style="">出院療養</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R7C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT15" name="PAY_AMT15" title="" maxlength=""
																				size="" value="">

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R8C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_119" class="" style="">喪失工作能力</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R8C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT16" name="PAY_AMT16" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R8C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_120" class="" style="">喪葬費用</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R8C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT17" name="PAY_AMT17" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R8C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_121" class="" style="">銜接原醫療限額之自負額</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R8C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT18" name="PAY_AMT18" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R8C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_122" class="" style="">分期給付</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R8C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="PAY_AMT19" name="PAY_AMT19" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R8C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_123" class="" style="">保經代分類</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R8C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="BROKTYPE" name="BROKTYPE" title="" maxlength=""
																				size="" value="">

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow" id="table_4_R9C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_124" class="" style="">要保人姓名</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R9C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2" name="A_NAME" id="A_NAME" value="" alt="ch"/>
																			</td>
																			<td class="tbYellow" id="table_4_R9C2" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_125" class="" style="">要保人身分證號碼</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R9C3" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="A_ID" name="A_ID" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R9C4" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_126" class="" style="">要保人出生日期</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R9C5" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="A_BIRTHDAY" name="A_BIRTHDAY" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R9C6" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_127" class="" style="">要保人與被保險人關係</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R9C7" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<input type="text" class="textBox2"
																				id="RELATION" name="RELATION" title="" maxlength=""
																				size="" value="">

																			</td>
																			<td class="tbYellow" id="table_4_R9C8" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_128" class="" style="">資料寫入時間</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R9C9" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="UPDATE_TIME_text"></span>
																				<input type="hidden" id="UPDATE_TIME" name="UPDATE_TIME" value="">
																				<input type="hidden" id="TBL_NAME" name="TBL_NAME" value="${rtnMap.TBL_NAME}">
																			</td>
																		</tr>
																		<tr>
																			<td style="text-align: center;" class="tbYellow">被保險人性別</td>
																			<td style="text-align: center;" class="tbYellow2">
																				<select id="I_GENDER" name="I_GENDER">
																					<option value="1" <c:if test="${I_GENDER eq '1'}">selected</c:if>>男</option>
																					<option value="2" <c:if test="${I_GENDER eq '2'}">selected</c:if>>女</option>
																				</select>
																			</td>
																			<td style="text-align: center;" class="tbYellow">公、自費件</td>
																			<td style="text-align: center;" class="tbYellow2">
																				<select id="PAY_TYPE" name="PAY_TYPE">
																					<option value="0" <c:if test="${PAY_TYPE eq '0'}">selected</c:if>>無</option>
																					<option value="1" <c:if test="${PAY_TYPE eq '1'}">selected</c:if>>公費</option>
																					<option value="2" <c:if test="${PAY_TYPE eq '2'}">selected</c:if>>自費</option>
																				</select>																			
																			</td>
																			<td style="text-align: center;" class="tbYellow">來源別</td>
																			<td style="text-align: center;" class="tbYellow2"><span id="OIU_IND"></span></td>
																			<td style="text-align: center;" class="tbYellow">銷售通路</td>
																			<td style="text-align: center;" class="tbYellow2"><span id="SALE_CHNL"></span></td>
																			<td style="text-align: center;" class="tbYellow">商品代碼</td>
																			<td style="text-align: center;" class="tbYellow2"><span id="PROD_CODE"></span></td>																			
																		</tr>																		
																		<tr>
																			<td class="tbYellow" id="table_4_R10C0" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="input-label_130" class="" style="">公會取回序號</span>

																			</td>
																			<td class="tbYellow2" id="table_4_R10C1" rowspan="1"
																				colspan="1" width="10%" style="text-align: center;">
																				<span id="SER_NO_text"></span>
																				<input type="hidden" id="SER_NO" name="SER_NO" value="">

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
																		<tr>
																			<td class="tbYellow2" id="table_4_R11C0" rowspan="1"
																				colspan="10" width="10%" style="text-align: center;">
																				<button type="button" id="editBtn" disabled class="button" onclick="doEdit()">F9修改</button>
																				<button type="button" id="deleteBtn" disabled
																					class="button" onclick="doDelete()">F10刪除</button>
																				<button type="button" id="cleanAllBtn" disabled
																					class="button" onclick="doCleanAll()">取消</button>
																			</td>
																		</tr>
																	</tbody>
																</table>
																<table id="rtnTable" class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
																	<tbody>
																		<tr>
																			<td class="" id="table_5_R0C0" rowspan="1"
																				colspan="18" width="" style="text-align:;"><span
																				id="input-label_132" class="" style="">新制通報資料明細</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbBlue" style="text-align:center;">序號</td>																																					
																			<td class="tbBlue" id="table_5_R1C0" style="text-align: center;">
																				<span id="input-label_133" class="" style="">選取</span>
																			</td>
																			<td class="tbBlue" id="table_5_R1C1" style="text-align: center;">
																				<A href="javascript:sortTable1(2, rtnTable, 'rtnID', 0, 'sort2');">通報方式<span id='sort2'>▼</span></A>
																			</td>
																			</td>
																			<td class="tbBlue" id="table_5_R1C2" style="text-align: center;">
																				<A href="javascript:sortTable1(3, rtnTable, 'rtnID', 0, 'sort3');">公司別<span id='sort3'>▼</span></A>
																			</td>
																			<td class="tbBlue" id="table_5_R1C3" style="text-align: center;">
																				<A href="javascript:sortTable1(4, rtnTable, 'rtnID', 0, 'sort4');">保單號碼<span id='sort4'>▼</span></A>
																			</td>
																			<td class="tbBlue" id="table_5_R1C4" style="text-align: center;">
																				<span id="input-label_137" class="" style="">銷售通路</span>

																			</td>
																			<td class="tbBlue" id="table_5_R1C5" style="text-align: center;">
																				<span id="input-label_141" class="" style="">商品代碼</span>

																			</td>
																			<td class="tbBlue" id="table_5_R1C6" style="text-align: center;">
																				<span id="input-label_142" class="" style="">保單分類</span>

																			</td>
																			<td class="tbBlue" id="table_5_R1C7" style="text-align: center;">
																				<span id="input-label_138" class="" style="">險種分類</span>

																			</td>
																			<td class="tbBlue" id="table_5_R1C8" style="text-align: center;">
																				<A href="javascript:sortTable1(9, rtnTable, 'rtnID', 0, 'sort9');">險種<span id='sort9'>▼</span></A>
																			</td>
																			<td class="tbBlue" id="table_5_R1C9" style="text-align: center;">
																				<span id="input-label_140" class="" style="">保單狀況</span>

																			</td>
																			<td class="tbBlue" id="table_5_R1C10" style="text-align: center;">
																				<span id="input-label_150" class="" style="">身故保額</span>

																			</td>
																			<td class="tbBlue" id="table_5_R1C11" style="text-align: center;">
																				<span id="input-label_151" class="" style="">醫療限額</span>

																			</td>
																			<td class="tbBlue" id="table_5_R1C12" style="text-align: center;">
																				<span id="input-label_152" class="" style="">醫療日額</span>

																			</td>
																			<td class="tbBlue" id="table_5_R1C13" style="text-align: center;">
																				<A href="javascript:sortTable1(14, rtnTable, 'rtnID', 0, 'sort14');">契約生效日<span id='sort14'>▼</span></A>
																			</td>																																						
																			<td class="tbBlue" id="table_5_R1C14" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_154" class="" style="">契約滿期日</span>

																			</td>
																			<td class="tbBlue" id="table_5_R1C15" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_155" class="" style="">要保人姓名</span>

																			</td>
																			<td class="tbBlue" id="table_5_R1C16" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				<span id="input-label_143" class="" style="">通報時間</span>

																			</td>
																		</tr>
																		<c:forEach var="rtnMap" items="${resultList}" varStatus="status"  >
																		<tr id="rtnID">
																			<td class="tbYellow2" style="text-align: center;">${status.count}</td>
																			<td class="tbYellow2" id="table_5_R2C0" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				<span id="input-input_radio_1">
																				<label>&nbsp;
																				<input type="radio" id="item${status.index}" name="item" onclick="selectItem(this);" value="${status.index}">
																				&nbsp;&nbsp;&nbsp;&nbsp;
																				</label>&nbsp;&nbsp; 
																				</span>
																				<input type="hidden" id="TBL_NAME${status.index}" value="${rtnMap.TBL_NAME}">
																				<input type="hidden" id="INSR_TYPE${status.index}" value="${rtnMap.INSR_TYPE}">
																				<input type="hidden" id="CMNY_CODE${status.index}" value="${rtnMap.CMNY_CODE}">
																				<input type="hidden" id="I_ID${status.index}" value="${rtnMap.I_ID}">
																				<input type="hidden" id="I_BIRTHDAY${status.index}" value="${rtnMap.I_BIRTHDAY}">
																				<input type="hidden" id="POLICY_NO${status.index}" value="${rtnMap.POLICY_NO}">
																				<input type="hidden" id="POLICY_CAT${status.index}" value="${rtnMap.POLICY_CAT}">
																				<input type="hidden" id="POLICY_DUTY${status.index}" value="${rtnMap.POLICY_DUTY}">
																				<input type="hidden" id="PROD_KIND${status.index}" value="${rtnMap.PROD_KIND}">
																				<input type="hidden" id="STATUS${status.index}" value="${rtnMap.STATUS}">
																				<input type="hidden" id="LST_CHG_DATE${status.index}" value="${rtnMap.LST_CHG_DATE}">
																				<input type="hidden" id="MAIN_POLICY_NO${status.index}" value="${rtnMap.MAIN_POLICY_NO}">
																				<input type="hidden" id="ISSUE_DATE${status.index}" value="${rtnMap.ISSUE_DATE}">
																				<input type="hidden" id="ISSUE_TIME${status.index}" value="${rtnMap.ISSUE_TIME}">
																				<input type="hidden" id="LPS_DATE${status.index}" value="${rtnMap.LPS_DATE}">
																				<input type="hidden" id="LPS_TIME${status.index}" value="${rtnMap.LPS_TIME}">
																				<input type="hidden" id="SIGN_DATE${status.index}" value="${rtnMap.SIGN_DATE}">
																				<input type="hidden" id="PREM${status.index}" value="${rtnMap.PREM}">
																				<input type="hidden" id="PAY_FREQ${status.index}" value="${rtnMap.PAY_FREQ}">
																				<input type="hidden" id="PAY_PERIOD${status.index}" value="${rtnMap.PAY_PERIOD}">
																				<input type="hidden" id="LST_CHG_TIME${status.index}" value="${rtnMap.LST_CHG_TIME}">
																				<input type="hidden" id="PAY_AMT1_${status.index}" value="${rtnMap.PAY_AMT1}">
																				<input type="hidden" id="PAY_AMT2_${status.index}" value="${rtnMap.PAY_AMT2}">
																				<input type="hidden" id="PAY_AMT3_${status.index}" value="${rtnMap.PAY_AMT3}">
																				<input type="hidden" id="PAY_AMT4_${status.index}" value="${rtnMap.PAY_AMT4}">
																				<input type="hidden" id="PAY_AMT5_${status.index}" value="${rtnMap.PAY_AMT5}">
																				<input type="hidden" id="PAY_AMT6_${status.index}" value="${rtnMap.PAY_AMT6}">
																				<input type="hidden" id="PAY_AMT7_${status.index}" value="${rtnMap.PAY_AMT7}">
																				<input type="hidden" id="PAY_AMT8_${status.index}" value="${rtnMap.PAY_AMT8}">
																				<input type="hidden" id="PAY_AMT9_${status.index}" value="${rtnMap.PAY_AMT9}">
																				<input type="hidden" id="PAY_AMT10_${status.index}" value="${rtnMap.PAY_AMT10}">
																				<input type="hidden" id="PAY_AMT11_${status.index}" value="${rtnMap.PAY_AMT11}">
																				<input type="hidden" id="PAY_AMT12_${status.index}" value="${rtnMap.PAY_AMT12}">
																				<input type="hidden" id="PAY_AMT13_${status.index}" value="${rtnMap.PAY_AMT13}">
																				<input type="hidden" id="PAY_AMT14_${status.index}" value="${rtnMap.PAY_AMT14}">
																				<input type="hidden" id="PAY_AMT15_${status.index}" value="${rtnMap.PAY_AMT15}">
																				<input type="hidden" id="PAY_AMT16_${status.index}" value="${rtnMap.PAY_AMT16}">
																				<input type="hidden" id="PAY_AMT17_${status.index}" value="${rtnMap.PAY_AMT17}">
																				<input type="hidden" id="PAY_AMT18_${status.index}" value="${rtnMap.PAY_AMT18}">
																				<input type="hidden" id="PAY_AMT19_${status.index}" value="${rtnMap.PAY_AMT19}">
																				<input type="hidden" id="BROKTYPE${status.index}" value="${rtnMap.BROKTYPE}">
																				<input type="hidden" id="A_NAME${status.index}" value="${rtnMap.A_NAME}">
																				<input type="hidden" id="A_ID${status.index}" value="${rtnMap.A_ID}">
																				<input type="hidden" id="A_BIRTHDAY${status.index}" value="${rtnMap.A_BIRTHDAY}">
																				<input type="hidden" id="RELATION${status.index}" value="${rtnMap.RELATION}">
																				<input type="hidden" id="UPDATE_TIME${status.index}" value="${rtnMap.UPDATE_TIME}">
																				<input type="hidden" id="SER_NO${status.index}" value="${rtnMap.SER_NO}">
																				<input type="hidden" id="INPUT_TIME${status.index}" value="${rtnMap.INPUT_TIME}">																				
																				<input type="hidden" id="I_GENDER${status.index}" value="${rtnMap.I_GENDER}">																				
																				<input type="hidden" id="PAY_TYPE${status.index}" value="${rtnMap.PAY_TYPE}">																				
																				<input type="hidden" id="OIU_IND${status.index}" value="${rtnMap.OIU_IND}">
																				<input type="hidden" id="OIU_IND_DESC${status.index}" value="${oiuIndDesc[rtnMap.OIU_IND]}">
																				<input type="hidden" id="SALE_CHNL${status.index}" value="${rtnMap.SALE_CHNL}">
																				<input type="hidden" id="SALE_CHNL_DESC${status.index}" value="${saleChnlDesc[rtnMap.SALE_CHNL]}">
																				<input type="hidden" id="PROD_CODE${status.index}" value="${rtnMap.PROD_CODE}">
																			</td>
																			<td class="tbYellow2" id="table_5_R2C1" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				<a href="#" id="input-hyperlink_1" title=""
																				onclick="openDetail(${status.index});">${rtnMap.INSR_TYPE}&nbsp;${INSRMAP[rtnMap.INSR_TYPE]}</a>
																			</td>																			
																			<td class="tbYellow2" id="table_5_R2C2" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				${rtnMap.COMPANY_NAME}
																			</td>
																			<td class="tbYellow2" id="table_5_R2C3" rowspan="1"
																				colspan="1" width="" style="text-align: center;">
																				${rtnMap.POLICY_NO}
																			</td>
																			<td class="tbYellow2" id="table_5_R2C4" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				${rtnMap.SALE_CHNL}
																			</td>
																			<td class="tbYellow2" id="table_5_R2C5" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				${rtnMap.PROD_CODE}
																			</td>
																			<td class="tbYellow2" id="table_5_R2C6" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				${rtnMap.POLICY_CAT}
																			</td>
																			<td class="tbYellow2" id="table_5_R2C7" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				${rtnMap.POLICY_DUTY}
																			</td>
																			<td class="tbYellow2" id="table_5_R2C8" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				${rtnMap.PROD_KIND}
																			</td>
																			<td class="tbYellow2" id="table_5_R2C9" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				${rtnMap.STATUS}
																			</td>
																			<td class="tbYellow2" id="table_5_R2C10" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value="${rtnMap.PAY_AMT1}"/>
																			</td>
																			<td class="tbYellow2" id="table_5_R2C11" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value="${rtnMap.PAY_AMT6}"/>
																			</td>
																			<td class="tbYellow2" id="table_5_R2C12" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				<fmt:formatNumber type="number" pattern="###,###,###" value="${rtnMap.PAY_AMT8}"/>
																			</td>
																			<td class="tbYellow2" id="table_5_R2C13" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				${rtnMap.ISSUE_DATE}
																			</td>
																			<td class="tbYellow2" id="table_5_R2C14" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				${rtnMap.LPS_DATE}
																			</td>
																			<td class="tbYellow2" id="table_5_R2C15" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				<input alt='ch' class="textDisable" readonly="readonly" value='${rtnMap.A_NAME}'>
																			</td>
																			<td class="tbYellow2" id="table_5_R2C16" rowspan="1"
																				colspan="1" width="" style="text-align: left;">
																				${rtnMap.UPDATE_TIME}
																			</td>
																		</tr>																		
																		</c:forEach>
																		<c:if test="${isAllow}">
																		<tr>
																			<td class="tbYellow2" id="table_5_R4C0" rowspan="1"
																				colspan="18" width="" style="text-align: center;">
																				<button type="button" id="btn_async" class="button" onclick="doASyncCheck()">F8即時取回公會資料</button>
																			</td>
																		</tr>
																		</c:if>
																	</tbody>
																</table>
																<table class="tbBox2" width="100%"
																	cellspacing="1" cellpadding="1">
																	<tbody>
																		<tr>
																			<td class="tbYellow3" id="table_6_R0C0" style="text-align: left;">
																				<span id="input-label_144" class="" style="">
																					1.	銷售通路:1網路投保 2業務員3保經、保代 4電話行銷 5機場櫃檯
																				</span>
																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow3" id="table_6_R1C0" style="text-align: left;">
																				<span id="input-label_145" class="" style="">
																					2.	保單分類：1個人；2團體
																				</span>
																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow3" id="table_6_R2C0" style="text-align: left;">
																				<span id="input-label_146" class="" style="">
																					3.	險種分類：1人壽保險；2傷害保險；3健康保險 4.年金保險。
																				</span>
																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow3" id="table_6_R3C0" style="text-align: left;">
																				<span id="input-label_147" class="" style="">
																					4.	險種：01一般；02特定；03投資型；04日額型；05實支實付型；06日額或實支實付擇一型；07手術型；08重大疾病；09帳戶型；10長期看護型；11喪失工作能力；12防癌；13旅平險；14微型；15微型實支實付；16小額終老保險；17.失能扶助保險；18.登山綜合保險；19定期人壽保險(不含一年期)；20海域活動綜合保險；21一年期
																				</span>
																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow3" id="table_6_R4C0" style="text-align: left;">
																				<span id="input-label_148" class="" style="">
																					5.	繳別：1躉繳；2年繳；3半年繳；4季繳；5月繳；6彈性繳；9繳費期滿
																				</span>
																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow3" id="table_6_R5C0" style="text-align: left;">
																				<span id="input-label_149" class="" style="">
																					6.	保單狀況： 收件:
																					01有效；06未承保取消件；07契約註銷；11滿期(契約到期)；12鍵值欄位通報錯誤終止；15通報更正;
																					50一○七條/一○七條之一承保資料；51一○七條理賠資料（未滿14足歲之未成年人）；52一○七條/一○七條之一理賠資料（精神障礙或其他心智缺陷/受監護宣告尚未撤銷）。
																					承保: 01有效；02增額；03減額；04展期；05繳清；06契約撤銷； 07停效;
																					10解除契約；11滿期(契約到期)
																					；12鍵值欄位通報錯誤終止；20終止1:由要保人提出終止契約效力;21.終止2:主被保險人死亡，其他被保險人附同時終止或完全失能或理賠給付後終止附約;30被保險人因自然死身故；31被保險人因意外身故;32被保險人因其他原因故;50一○七條/一○七條之一承保資料；51一○七條理賠資料（未滿14足歲之未成年人）；52一○七條/一○七條之一理賠資料（精神障礙或其他心智缺陷/受監護宣告尚未撤銷）。</span>

																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow3" id="table_6_R7C0" style="text-align: left;">
																				<span id="input-label_148" class="" style="">
																					7.	保障及保費彙整欄位，金額依頁面上的筆數加總，含本公司及產、壽險通報資料。
																				</span>
																			</td>
																		</tr>
																		<tr>
																			<td class="tbYellow3" id="table_6_R7C0" style="text-align: left;">
																				<span id="input-label_148" class="" style="">
																					8.	即時捉取公會資料：輸入身份證字號∕統一證號，按F8即時捉取公會資料鈕
																				</span>
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
