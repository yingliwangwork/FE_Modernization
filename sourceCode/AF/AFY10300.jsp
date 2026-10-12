<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ include file="/html/CM/header.jsp"%>
<%@ page import="org.apache.commons.collections.map.ListOrderedMap"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/HotKey.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%>
<script language="JavaScript" type="text/JavaScript">
Event.observe(window, 'load', new AFY10300().initApp);

function AFY10300(){
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/AFY1_0300/');

	function setHotKey(){
		HotKeys.addHotKey(Keys.F2, new ButtonAction(document.frm.queryBtn));	// F2 查詢
		HotKeys.addHotKey(Keys.F9, new ButtonAction(document.frm.editBtn));		// F9 修改
		HotKeys.addHotKey(Keys.F10, new ButtonAction(document.frm.cancelBtn));	// F10 取消
		HotKeys.addHotKey(Keys.F8, new ButtonAction(document.uploadFrm.importBtn));	// F8 檔案上傳
	}
	
	var validate = {
		checkQuery: function(){
			var valid = new Validator();
			valid.errHandler = new AlertHandler();
			
			var queryNo = $F('queryNo');
			
			//失敗檔、保單號碼、被保人ID
			var idNo = $F('idNo').trim();	
			if (queryNo != 0 && idNo.length == 0) {
				valid.define("idNo","","失敗檔/保單號碼/被保人ID不得為空白","string", "1", "-1");
			}	
			//通報日期
			var insrDate = $F('insrDate').trim();
			if (insrDate.length > 0) {
				valid.define("insrDate", "通報日期", "通報日期非正確的日期格式", "isROCdate");		
			}		
			
			valid.errHandler.clear();
			if (!valid.validate()) {
				valid.errHandler.display();
				return true;
			} else {
				return false;
			}		
		},
		checkEdit: function(){
			var valid = new Validator();
			valid.errHandler = new AlertHandler();
		
			valid.define("I_ID","被保人","被保人不得為空值","string", "1", "10");
			valid.define("I_BIRTHDAY", "被保人生日", "被保人生日不得為空值、且必須為日期格式", "isROCdate");
			valid.define("MAIN_POLICY_NO","主約保單號碼","主約保單號碼不得為空值","string", "1", "20");
			valid.define("PAY_AMT1","身故","身故不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT2","完全失能","完全失能不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT3","失能扶助金","失能扶助金不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT4","特定事故","特定事故不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT5","醫療限額","醫療限額不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT6","醫療限額自負","醫療限額自負不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT7","醫療日額","醫療日額不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT8","住院手術","住院手術不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT9","住院門診","住院門診不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT11","門診日額","門診日額不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT12","重大疾傷病","重大疾傷病不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT13","重大燒燙傷","重大燒燙傷不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT14","癌症療養","癌症療養不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT15","出院療養","出院療養不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT16","失能","失能不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT17","喪葬費用","喪葬費用不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT18","術接原醫療限額","術接原醫療限額之自負額不得為空值、且需為數字","num", "0", false);
			valid.define("PAY_AMT19","分期給付","分期給付不得為空值、且需為數字","num", "0", false);
			valid.define("ISSUE_DATE", "契約生效日", "契約生效日不得為空值、且必須為日期格式", "isROCdate");
			valid.define("LPS_DATE", "契約滿期日", "契約滿期日不得為空值、且必須為日期格式", "isROCdate");
			valid.define("LST_CHG_DATE", "保單狀況生效日", "保單狀況生效日不得為空值、且必須為日期格式", "isROCdate");
			valid.define("PREM","保費","保費不得為空值、且需為數字","num", "0", false);
			valid.define("A_ID","要保人","要保人不得為空值","string", "1", "10");
			valid.define("A_BIRTHDAY", "要保人生日", "要保人生日不得為空值、且必須為日期格式", "isROCdate");
			
			var LIA_STATUS = $F('LIA_STATUS');
			var re = /[0-9]/;
			if(!re.test(LIA_STATUS)) {
				$('LIA_STATUS').focus();
				alert("通報狀態需選擇");
				return true;
			}
			
			var mainPolicyNo = $F('MAIN_POLICY_NO');
			var policyNo = $F('POLICY_NO'); 	
			if (policyNo.substring(0, mainPolicyNo.length) != mainPolicyNo) {
				alert("保單號碼開頭不同於主約保單號碼");
				valid.define("POLICY_NO","保單號碼","保單號碼開頭不同於主約保單號碼","string", "-1", "-1");	
			}	
			
			if (${isRType}) {
				var signDate = $F('SIGN_DATE').trim();
				if (signDate > 0) {
					valid.define("SIGN_DATE", "要保書填寫日", "要保書填寫日必須為日期格式", "isROCdate");
				}
			}
						
			valid.errHandler.clear();
			if (!valid.validate()) {
				valid.errHandler.display();
				return true;
			} else {
				return false;
			}		
		},		
		checkUpload: function(){
			var file = $F('uploadFile');
			var re = /\.(xlsx)$/i; 			
			if (!re.test(file)) { 
				alert("檔案格式必須為xlsx檔"); 
				return true;
			}
			return false;
		}	
	}
			
	var buttons = {
		<!-- F2查詢 -->
		doQuery: function(){
			if (validate.checkQuery()) {
				return;
			}		
			var frm = document.frm;
			frm.action = "${dispatcher}/AFY1_0300/query";
			frm.submit();
		},
		<!-- F9修改 -->
		doEdit: function(){
			if (validate.checkEdit()) {
				return;
			}
			var frm = document.frm;
			frm.action = "${dispatcher}/AFY1_0300/edit";
			frm.submit();
		},	
		<!-- F10取消 -->
		doCancel: function(){
		    $('showEdit').value = 'N';
		    
			$('editArea').style.display = "none";
			$('editBtn').disabled = true;
			$('cancelBtn').disabled = true;
		},
		<!-- Excel匯出 -->			
    	doExport: function(){    		                       
	        RPTUtil.downloadFile('${dispatcher}/AFY1_0300/export', { 
	        	 'regQueryNo': $F('regQueryNo'),
	        	    'regIdNo': $F('regIdNo'), 
	        	'regInsrDate': $F('regInsrDate'),	        	  
	        	'regInsrType': $F('regInsrType'),
	           'regErrorCode': $F('regErrorCode'),
	        	'regProdType': $F('regProdType'),
	          'regProcStatus': $F('regProcStatus')
	        }, false);     			
		},
		<!-- F8檔案上傳 -->
		doImport: function(){
			if (validate.checkUpload()) {
				return;
			}						
		    var frm = document.uploadFrm;
		    frm.action = "${dispatcher}/AFY1_0300/import";
		    frm.submit();		
		},
		<!-- 大批即時通報 -->
		doInsrGroupBtn: function(){
			var frm = document.frm;
			if($F('insrType') == 'R') {
				alert("僅可選擇承保通報(收件類每30分鐘一次)");
				return;
			} else {
				
				var insrType_obj = $('insrType');
				var insrType_text = insrType_obj.options[insrType_obj.selectedIndex].text;
				
				var prodType_obj = $('prodType');
				var prodType_text = prodType_obj.options[prodType_obj.selectedIndex].text;
				
				if(confirm("確認要執行【" + prodType_text + insrType_text + "】即時大批通報嗎？")) {
					frm.action = "${dispatcher}/AFY1_0300/execute";
				    frm.submit();
				}
			}
		}
	} 	
		
	return {
		initApp: function(){	
			setHotKey();

			$('queryBtn').observe('click', buttons.doQuery);
			$('importBtn').observe('click', buttons.doImport);
			$('insrGroupBtn').observe('click', buttons.doInsrGroupBtn);
			if (<c:out value="${showQuery}" default="false"/>) {
				$('editBtn').observe('click', buttons.doEdit);
				$('cancelBtn').observe('click', buttons.doCancel);
				$('exportBtn').observe('click', buttons.doExport);
			}	
			if ($F('showEdit') == 'Y') {				
				var radioNum = $F('regRadioNum');
				document.getElementById('item'+radioNum).checked = 'checked';
				setEditValue(radioNum);				
			}
													
			PageUI.resize();     
			displayMessage();
		}
	};
}

<!-- 選擇單筆資料 -->
function selectItem(radioDom) {	
	setEditValue(radioDom.value);		
}
<!-- 設定編輯區資料 -->
function setEditValue(radioNum) {
	$('regRadioNum').value = radioNum;
	
	$('INSR_TYPE_DESC').textContent = $('INSR_TYPE_DESC'+radioNum).value;
	$('I_ID').value = $('I_ID'+radioNum).value;
	$('I_NAME').value = $('I_NAME'+radioNum).value;
	$('I_BIRTHDAY').value = $('I_BIRTHDAY_ROC'+radioNum).value;
	$('I_GENDER').value = $('I_GENDER'+radioNum).value;	
	$('MAIN_POLICY_NO').value = $('MAIN_POLICY_NO'+radioNum).value;
	$('POLICY_NO').value = $('POLICY_NO'+radioNum).value;
	$('OIU_IND').value = $('OIU_IND'+radioNum).value;
	$('SALE_CHNL').value = $('SALE_CHNL'+radioNum).value;
	$('PROD_CODE').value = $('PROD_CODE'+radioNum).value;
	$('POLICY_CAT').value = $('POLICY_CAT'+radioNum).value;
	$('POLICY_DUTY').value = $('POLICY_DUTY'+radioNum).value;
	$('PROD_KIND').value = $('PROD_KIND'+radioNum).value;
	$('PAY_TYPE').value = $('PAY_TYPE'+radioNum).value;	
	$('PAY_AMT1').value = $('PAY_AMT1-'+radioNum).value;
	$('PAY_AMT2').value = $('PAY_AMT2-'+radioNum).value;
	$('PAY_AMT3').value = $('PAY_AMT3-'+radioNum).value;
	$('PAY_AMT4').value = $('PAY_AMT4-'+radioNum).value;
	$('PAY_AMT5').value = $('PAY_AMT5-'+radioNum).value;
	$('PAY_AMT6').value = $('PAY_AMT6-'+radioNum).value;
	$('PAY_AMT7').value = $('PAY_AMT7-'+radioNum).value;
	$('PAY_AMT8').value = $('PAY_AMT8-'+radioNum).value;
	$('PAY_AMT9').value = $('PAY_AMT9-'+radioNum).value;
	$('PAY_AMT10').value = $('PAY_AMT10-'+radioNum).value;
	$('PAY_AMT11').value = $('PAY_AMT11-'+radioNum).value;
	$('PAY_AMT12').value = $('PAY_AMT12-'+radioNum).value;
	$('PAY_AMT13').value = $('PAY_AMT13-'+radioNum).value;
	$('PAY_AMT14').value = $('PAY_AMT14-'+radioNum).value;
	$('PAY_AMT15').value = $('PAY_AMT15-'+radioNum).value;
	$('PAY_AMT16').value = $('PAY_AMT16-'+radioNum).value;
	$('PAY_AMT17').value = $('PAY_AMT17-'+radioNum).value;
	$('PAY_AMT18').value = $('PAY_AMT18-'+radioNum).value;
	$('PAY_AMT19').value = $('PAY_AMT19-'+radioNum).value;	
	$('ISSUE_DATE').value = $('ISSUE_DATE_ROC'+radioNum).value;
	$('ISSUE_TIME').value = $('ISSUE_TIME'+radioNum).value;
	$('LPS_DATE').value = $('LPS_DATE_ROC'+radioNum).value;
	$('LPS_TIME').value = $('LPS_TIME'+radioNum).value;
	$('PREM').value = $('PREM'+radioNum).value;
	$('PAY_FREQ').value = $('PAY_FREQ'+radioNum).value;
	$('PAY_PERIOD').value = $('PAY_PERIOD'+radioNum).value;	
	$('STATUS').value = $('PAY_PERIOD'+radioNum).value;
	$('LST_CHG_DATE').value = $('LST_CHG_DATE_ROC'+radioNum).value;
	$('LST_CHG_TIME').value = $('LST_CHG_TIME'+radioNum).value;
	$('A_NAME').value = $('A_NAME'+radioNum).value;
	$('A_ID').value = $('A_ID'+radioNum).value;
	$('A_BIRTHDAY').value = $('A_BIRTHDAY_ROC'+radioNum).value;
	$('RELATION').value = $('RELATION'+radioNum).value;
	$('LIA_STATUS').value = $('LIA_STATUS'+radioNum).value;
	$('OUTPUT_TIME').textContent = $('OUTPUT_TIME'+radioNum).value;
	$('SER_NO').textContent = $('SER_NO'+radioNum).value;
	$('UPDATE_SRC').textContent = $('UPDATE_SRC'+radioNum).value;
	$('UPDATE_TIME').value = $('UPDATE_TIME'+radioNum).value;
	$('MEMO').textContent = $('MEMO'+radioNum).value;

	if (${isRType}) {
		$('SIGN_DATE').value = $('SIGN_DATE_ROC'+radioNum).value;
		$('BROKTYPE').value = $('BROKTYPE'+radioNum).value;
	}
	
	$('OLD_I_ID').value = $('I_ID'+radioNum).value;
	$('OLD_I_BIRTHDAY').value = $('I_BIRTHDAY'+radioNum).value;
	$('OLD_POLICY_NO').value = $('POLICY_NO'+radioNum).value;
	$('OLD_POLICY_CAT').value = $('POLICY_CAT'+radioNum).value;
	$('OLD_POLICY_DUTY').value = $('POLICY_DUTY'+radioNum).value;
	$('OLD_PROD_KIND').value = $('PROD_KIND'+radioNum).value;
	$('OLD_STATUS').value = $('STATUS'+radioNum).value;
	$('OLD_LST_CHG_DATE').value = $('LST_CHG_DATE'+radioNum).value;
	$('OLD_UPDATE_TIME').value = $('UPDATE_TIME'+radioNum).value;
	
	//顯示編輯區
	$('editArea').style.display = "block";
	$('editBtn').disabled = false;
	$('cancelBtn').disabled = false;	
}

function linkATA00611() {
	var url = "/AAWeb/servlet/HttpDispatcher/AAZ0_0404/prompt?SYS_NO=AT&SUB_SYS_NO=A0&FUNC_ID=ATA00611&isShowQueryItem=R";
	var frm = document.getElementById("frm");
	frm.action = url;
	frm.submit();
}
</script>
</head>
<span id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility:visible;">
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
			<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td valign="top" bgcolor="#F0FBC6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
				<tr>
					<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
				</tr>
			</table>
			<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
				<tr>
					<td width="20" height="24">
						<div align="center"><font size="-5">●</font></div>
					</td>
					<td>公會補通報作業</td>
					<td><div align="right">畫面編號：AFY10300</div></td>
				</tr>
			</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif">
			<img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12">
		</td>
		<td width="5" class="tbBox">
			<img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1">
		</td>
	</tr>
</table>
</span>
<table width="100%" height="30" border="0" cellpadding="0"
	cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
			<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="top">
						<table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
							<tbody>
								<tr>
									<td class="tbBox2">
										<p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">公會補通報作業</p>
									</td>
								</tr>
								<tr bgcolor=#FFFFFF>
									<td>
										<table width="100%" border="0" cellspacing="0" cellpadding="5">
											<tr>
												<td>
													<form id="frm" name="frm" method="post">													
													<table width="100%" class="tbBox2">
														<tr>
															<td class="tbYellow" width="8%" align="center">
																查詢方式
															</td>
															<td class="tbYellow2" width="10%">
																<select id="queryNo" name="queryNo">															
																	<option value="0" <c:if test="${queryNo eq '0'}">selected</c:if>>失敗檔&nbsp;(可不輸入失敗檔序號)</option>
																	<option value="1" <c:if test="${queryNo eq '1'}">selected</c:if>>保單號碼</option>
																	<option value="2" <c:if test="${queryNo eq '2'}">selected</c:if>>被保人ID</option>
																</select>
															</td>
															<td class="tbYellow" width="12%" align="center">
																失敗檔/保單號碼/被保人ID
															</td>
															<td class="tbYellow2" width="10%">
																<input type="text" id="idNo" name="idNo" value="${idNo}" class="textBox2" />
															</td>
															<td class="tbYellow" width="8%" align="center">
																通報日期
															</td>
															<td class="tbYellow2" width="10%" style="text-align:left;">
														    	<!--<input type="text" id="insrDate" name="insrDate" value="<c:out value='${insrDate}'/>" maxlength="7" size="9" class="textBox2">-->
														    	<input type="text" id="insrDate" name="insrDate" value="" maxlength="7" size="9" class="textBox2">
															</td>
															<td class="tbYellow" width="8%" align="center">
																錯誤代碼
															</td>
															<td class="tbYellow2" width="10%" style="text-align:left;">
																<select id="errorCode" name="errorCode">
																	<option value="99" <c:if test="${errorCode eq '99'}">selected</c:if>>全部</option>
																	<option value="36" <c:if test="${errorCode eq '36'}">selected</c:if>>36</option>
																	<option value="37" <c:if test="${errorCode eq '37'}">selected</c:if>>37</option>
																	<option value="39" <c:if test="${errorCode eq '39'}">selected</c:if>>39</option>
																	<option value="40" <c:if test="${errorCode eq '40'}">selected</c:if>>40</option>
																	<option value="45" <c:if test="${errorCode eq '45'}">selected</c:if>>45</option>
																</select>
															</td>														
															<td class="tbYellow2" width="10%" rowspan="2" align="center">
																<input type="button" id="queryBtn" name="queryBtn" class="button" value="F2查詢" />
															</td>
														</tr>
														<tr>
															<td class="tbYellow" align="center">
																收承方式
															</td>
															<td class="tbYellow2" style="text-align:left;">
																<select id="insrType" name="insrType">
																	<option value="L" <c:if test="${insrType eq 'L'}">selected</c:if>>承保</option>
																	<option value="R" <c:if test="${insrType eq 'R'}">selected</c:if>>收件</option>																	
																</select>																
																
															</td>
															<td class="tbYellow" align="center">
																商品屬性
															</td>
															<td class="tbYellow2" style="text-align:left;">
																<select id="prodType" name="prodType">
																	<option value="AT" <c:if test="${prodType eq 'AT'}">selected</c:if>>個險</option>
																	<option value="BG" <c:if test="${prodType eq 'BG'}">selected</c:if>>團險</option>
																	<option value="CB" <c:if test="${prodType eq 'CB'}">selected</c:if>>意外險</option>																	
																</select>																
															</td>
															<td class="tbYellow" align="center">
																處理狀態
															</td>
															<td class="tbYellow2" style="text-align:left;">
																<select id="procStatus" name="procStatus">
																	<option value="1" <c:if test="${procStatus eq '1'}">selected</c:if>>未處理</option>
																	<option value="2" <c:if test="${procStatus eq '2'}">selected</c:if>>已處理</option>
																	<option value="0" <c:if test="${procStatus eq '0'}">selected</c:if>>全部</option>																	
																</select>																
															</td>
															<td class="tbYellow">
																<input type="hidden" id="regQueryNo" name="regQueryNo" value="${regQueryNo}">
																<input type="hidden" id="regIdNo" name="regIdNo" value="${regIdNo}">
																<input type="hidden" id="regInsrDate" name="regInsrDate" value="${regInsrDate}">
																<input type="hidden" id="regInsrType" name="regInsrType" value="${regInsrType}">
																<input type="hidden" id="regErrorCode" name="regErrorCode" value="${regErrorCode}">
																<input type="hidden" id="regProdType" name="regProdType" value="${regProdType}">
																<input type="hidden" id="regProcStatus" name="regProcStatus" value="${regProcStatus}">																																
																<input type="hidden" id="regRadioNum" name="regRadioNum" value="${regRadioNum}">
																
																<input type="hidden" id="showEdit" name="showEdit">			
																																
																<input type="hidden" id="OLD_I_ID" name="OLD_I_ID">
																<input type="hidden" id="OLD_I_BIRTHDAY" name="OLD_I_BIRTHDAY">
																<input type="hidden" id="OLD_POLICY_NO" name="OLD_POLICY_NO">
																<input type="hidden" id="OLD_POLICY_CAT" name="OLD_POLICY_CAT">
																<input type="hidden" id="OLD_POLICY_DUTY" name="OLD_POLICY_DUTY">
																<input type="hidden" id="OLD_PROD_KIND" name="OLD_PROD_KIND">
																<input type="hidden" id="OLD_STATUS" name="OLD_STATUS">
																<input type="hidden" id="OLD_LST_CHG_DATE" name="OLD_LST_CHG_DATE">
																<input type="hidden" id="OLD_UPDATE_TIME" name="OLD_UPDATE_TIME">
															</td>
															<td class="tbYellow2"></td>
														</tr>	
													</table>
													<table id="editArea" name="editArea" class="tbBox2" width="100%" cellspacing="1" cellpadding="1" style="display:none;">
														<tbody>
															<tr>
																<td class="" id="table_2_R0C0" rowspan="1" colspan="10" width="" style="text-align:;">
																	<span id="input-label_12">資料編輯區</span>
																</td>
															</tr>
															<tr>
																<td class="tbYellow" width="8%" align="center">通報方式</td>
																<td class="tbYellow2" width="12%"><span id="INSR_TYPE_DESC"></span></td>
																<td class="tbYellow" width="8%" align="center">被保險人姓名</td>
																<td class="tbYellow2" width="12%">
																	<input type="text" id="I_NAME" name="I_NAME" class="textBox2">
																</td>
																<td class="tbYellow" width="8%" align="center">被保人ID</td>
																<td class="tbYellow2" width="12%">
																	<input type="text" id="I_ID" name="I_ID" class="textBox2">
																</td>
																<td class="tbYellow" width="8%" align="center">被保人生日</td>
																<td class="tbYellow2" width="12%">
																	<input type="text" id="I_BIRTHDAY" name="I_BIRTHDAY" value="<c:out value='${I_BIRTHDAY}'/>" maxlength="7" size="9" class="textBox2">
																</td>
																<td class="tbYellow" width="8%" align="center">被保險人性別</td>
																<td class="tbYellow2" width="12%">
																	<select id="I_GENDER" name="I_GENDER">
																		<option value="1" <c:if test="${status eq '1'}">selected</c:if>>男</option>
																		<option value="2" <c:if test="${status eq '2'}">selected</c:if>>女</option>																	
																	</select>
																</td>																
															</tr>
															<tr>
																<td class="tbYellow" align="center">主約保單號碼</td>
																<td class="tbYellow2">
																	<input type="text" id="MAIN_POLICY_NO" name="MAIN_POLICY_NO" class="textBox2">
																</td>
																<td class="tbYellow" align="center">保單號碼</td>
																<td class="tbYellow2">
																	<input type="text" id="POLICY_NO" name="POLICY_NO" class="textBox2">
																</td>
																<td class="tbYellow" align="center">來源別OIU</td>
																<td class="tbYellow2">
																	<input type="text" id="OIU_IND" name="OIU_IND" class="textBox2">
																</td>
																<td class="tbYellow" align="center">銷售通路別</td>
																<td class="tbYellow2">
																	<select id="SALE_CHNL" name="SALE_CHNL">
																	<c:forEach var="bo" items="${SALE_CHNL_OPTION}">
																		<option value="${bo.key}">${bo.key}&nbsp;${bo.value}</option>
																	</c:forEach>
																	</select>
																</td>
																<td class="tbYellow" align="center">商品代碼</td>
																<td class="tbYellow2">
																	<input type="text" id="PROD_CODE" name="PROD_CODE" class="textBox2">
																</td>																
															</tr>
															<tr>
																<td class="tbYellow" align="center">保單分類</td>
																<td class="tbYellow2">
																	<select id="POLICY_CAT" name="POLICY_CAT">
																		<option value="1" <c:if test="${status eq '1'}">selected</c:if>>個人</option>
																		<option value="2" <c:if test="${status eq '2'}">selected</c:if>>團體</option>
																	</select>																																		
																</td>
																<td class="tbYellow" align="center">險種分類</td>
																<td class="tbYellow2">
																	<select id="POLICY_DUTY" name="POLICY_DUTY">
																	<c:forEach var="bo" items="${POLICY_DUTY_OPTION}">
																		<option value="${bo.key}" <c:if test="${bo.key eq status }">selected</c:if>>${bo.key}&nbsp;${bo.value}</option>
																	</c:forEach>
																	</select>																	
																</td>
																<td class="tbYellow" align="center">險種</td>
																<td class="tbYellow2">
																	<select id="PROD_KIND" name="PROD_KIND">
																	<c:forEach var="bo" items="${PROD_KIND_OPTION}">
																		<option value="${bo.key}">${bo.key}&nbsp;${bo.value}</option>
																	</c:forEach>
																	</select>																	
																</td>
																<td class="tbYellow" align="center">公、自費件</td>
																<td class="tbYellow2">
																	<select id="PAY_TYPE" name="PAY_TYPE">
																		<option value="0" <c:if test="${status eq '0'}">selected</c:if>>無</option>
																		<option value="1" <c:if test="${status eq '1'}">selected</c:if>>公費</option>
																		<option value="2" <c:if test="${status eq '2'}">selected</c:if>>自費</option>
																	</select>																																		
																</td>
																<td class="tbYellow" align="center">身故</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT1" name="PAY_AMT1" class="textBox2">
																</td>																
															</tr>
															<tr>
																<td class="tbYellow" align="center">完全失能</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT2" name="PAY_AMT2" class="textBox2">
																</td>
																<td class="tbYellow" align="center">失能扶助金</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT3" name="PAY_AMT3" class="textBox2">
																</td>
																<td class="tbYellow" align="center">特定事故</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT4" name="PAY_AMT4" class="textBox2">
																</td>
																<td class="tbYellow" align="center">初次罹患</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT5" name="PAY_AMT5" class="textBox2">
																</td>
																<td class="tbYellow" align="center">醫療限額</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT6" name="PAY_AMT6" class="textBox2">
																</td>																
															</tr>	
															<tr>
																<td class="tbYellow" align="center">醫療限額自負</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT7" name="PAY_AMT7" class="textBox2">
																</td>
																<td class="tbYellow" align="center">醫療日期</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT8" name="PAY_AMT8" class="textBox2">
																</td>
																<td class="tbYellow" align="center">住院手術</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT9" name="PAY_AMT9" class="textBox2">
																</td>
																<td class="tbYellow" align="center">住院門診</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT10" name="PAY_AMT10" class="textBox2">
																</td>
																<td class="tbYellow" align="center">門診日額</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT11" name="PAY_AMT11" class="textBox2">
																</td>																
															</tr>
															<tr>
																<td class="tbYellow" align="center">重大疾/傷病</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT12" name="PAY_AMT12" class="textBox2">
																</td>
																<td class="tbYellow" align="center">重大燒燙傷</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT13" name="PAY_AMT13" class="textBox2">
																</td>
																<td class="tbYellow" align="center">癌症療養</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT14" name="PAY_AMT14" class="textBox2">
																</td>
																<td class="tbYellow" align="center">出院療養</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT15" name="PAY_AMT15" class="textBox2">
																</td>
																<td class="tbYellow" align="center">失能</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT16" name="PAY_AMT16" class="textBox2">
																</td>																
															</tr>	
															<tr>
																<td class="tbYellow" align="center">喪葬費用</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT17" name="PAY_AMT17" class="textBox2">
																</td>
																<td class="tbYellow" align="center">銜接原醫療限額之自負額</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT18" name="PAY_AMT18" class="textBox2">
																</td>
																<td class="tbYellow" align="center">分開給付</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_AMT19" name="PAY_AMT19" class="textBox2">
																</td>
																<td class="tbYellow" align="center">契約生效日期</td>
																<td class="tbYellow2">
																	<input type="text" id="ISSUE_DATE" name="ISSUE_DATE" class="textBox2">
																</td>
																<td class="tbYellow" align="center">契約生效時分<br>(旅平險)</td>
																<td class="tbYellow2">
																	<input type="text" id="ISSUE_TIME" name="ISSUE_TIME" class="textBox2">
																</td>																
															</tr>	
															<tr>
																<td class="tbYellow" align="center">契約滿期日期</td>
																<td class="tbYellow2">
																	<input type="text" id="LPS_DATE" name="LPS_DATE" value="<c:out value='${LPS_DATE}'/>" maxlength="7" size="9" class="textBox2">																	
																</td>
																<td class="tbYellow" align="center">契約滿期時分</td>
																<td class="tbYellow2">
																	<input type="text" id="LPS_TIME" name="LPS_TIME" class="textBox2">
																</td>
																<td class="tbYellow" align="center">保費</td>
																<td class="tbYellow2">
																	<input type="text" id="PREM" name="PREM" class="textBox2">
																</td>
																<td class="tbYellow" align="center">保費繳別</td>
																<td class="tbYellow2">
																	<select id="PAY_FREQ" name="PAY_FREQ">
																	<c:forEach var="bo" items="${PAY_FREQ_OPTION}">
																		<option value="${bo.key}">${bo.key}&nbsp;${bo.value}</option>
																	</c:forEach>
																	</select>																		
																</td>
																<td class="tbYellow" align="center">保費繳費年期</td>
																<td class="tbYellow2">
																	<input type="text" id="PAY_PERIOD" name="PAY_PERIOD" class="textBox2">
																</td>																
															</tr>	
															<tr>
																<td class="tbYellow" align="center">保單狀況</td>
																<td class="tbYellow2">
																	<input type="text" id="STATUS" name="STATUS" class="textBox2">
																</td>
																<td class="tbYellow" align="center"><font color="red">保單狀況生效日期</font></td>
																<td class="tbYellow2">
																	<input type="text" id="LST_CHG_DATE" name="LST_CHG_DATE" class="textBox2">
																</td>
																<td class="tbYellow" align="center">保單狀況生效時分</td>
																<td class="tbYellow2">
																	<input type="text" id="LST_CHG_TIME" name="LST_CHG_TIME" class="textBox2">
																</td>
																<td class="tbYellow" align="center">要保人姓名</td>
																<td class="tbYellow2">
																	<input type="text" id="A_NAME" name="A_NAME" class="textBox2">
																</td>
																<td class="tbYellow" align="center">要保人身分證號碼</td>
																<td class="tbYellow2">
																	<input type="text" id="A_ID" name="A_ID" class="textBox2">
																</td>																
															</tr>	
															<tr>
																<td class="tbYellow" align="center">要保人生日</td>
																<td class="tbYellow2">
																	<input type="text" id="A_BIRTHDAY" name="A_BIRTHDAY" value="<c:out value='${A_BIRTHDAY}'/>" maxlength="7" size="9" class="textBox2">
																</td>
																<td class="tbYellow" align="center">要被保人關係</td>
																<td class="tbYellow2">
																	<select id="RELATION" name="RELATION">
																	<c:forEach var="bo" items="${RELATION_OPTION}">
																		<option value="${bo.key}">${bo.key}&nbsp;${bo.value}</option>
																	</c:forEach>
																	</select>																		
																</td>
																<td class="tbYellow" align="center"><font color='red'>要保書填寫日<br>(收件才需要)</font></td>
																<td class="tbYellow2">
																	<c:if test="${isRType}">
																		<input type="text" id="SIGN_DATE" name="SIGN_DATE" value="<c:out value='${SIGN_DATE}'/>" maxlength="7" size="9" class="textBox2">
																	</c:if>																																																		
																</td>
																<td class="tbYellow" align="center">保經代類別</td>
																<td class="tbYellow2">
																	<c:if test="${isRType}">
																		<select id="BROKTYPE" name="BROKTYPE">
																		<c:forEach var="bo" items="${BROKTYPE_OPTION}">
																			<option value="${bo.key}">${bo.key}&nbsp;${bo.value}</option>
																		</c:forEach>
																		</select>
																	</c:if>																																			
																</td>
																<td class="tbYellow" align="center"><font color='red'>通報狀態</font></td>
																<td class="tbYellow2" colspan="3">
																	<select id="LIA_STATUS" name="LIA_STATUS">
																	<c:forEach var="bo" items="${LIA_STATUS_OPTION}">
																		<option value="${bo.key}">${bo.key}&nbsp;${bo.value}</option>
																	</c:forEach>
																	</select>
																</td>																
															</tr>	
															<tr>
																<td class="tbYellow" align="center">通報日期</td>
																<td class="tbYellow2">
																	<span id="OUTPUT_TIME" name="OUTPUT_TIME"></span>
																</td>
																<td class="tbYellow" align="center">公會通報序號</td>
																<td class="tbYellow2">
																	<span id="SER_NO" name="SER_NO"></span>																	
																</td>
																<td class="tbYellow" align="center">資料來源</td>
																<td class="tbYellow2">
																	<span id="UPDATE_SRC" name="UPDATE_SRC"></span>
																	<input type="hidden" id="UPDATE_TIME" name="UPDATE_TIME">																																		
																</td>
																<td class="tbYellow" align="center">失敗原因</td>
																<td class="tbYellow2" colspan="3">
																	<span id="MEMO" name="MEMO"></span>
																</td>
															</tr>																																														
															<tr>
																<td class="tbYellow2" id="table_4_R11C0" colspan="10" align="center">
																	<input type="button" id="editBtn" value="F9修改" class="button" disabled />
																	<input type="button" id="cancelBtn" value="F10取消" class="button" disabled />
																</td>
															</tr>
														</tbody>
													</table>
													<c:if test="${showQuery}">
													<table class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
														<tbody>
															<tr>
																<td class="tbBlue" align="center" width="3%">序號</td>																																					
																<td class="tbBlue" align="center" width="3%">選取</td>
																<td class="tbBlue" align="center" width="5%">結果</td>
																<td class="tbBlue" align="center" width="5%">保額</td>
																<td class="tbBlue" align="center" width="6%">通報方式</td>
																<td class="tbBlue" align="center" width="6%">被保人ID</td>
																<td class="tbBlue" align="center" width="5%">被保人生日</td>
																<td class="tbBlue" align="center" width="5%">被保人性別</td>
																<td class="tbBlue" align="center" width="8%">商品代碼</td>
																<td class="tbBlue" align="center" width="5%">險種分類</td>
																<td class="tbBlue" align="center" width="4%">險種</td>
																<td class="tbBlue" align="center" width="5%">保單狀況</td>
																<td class="tbBlue" align="center" width="5%">契約生效日</td>
																<td class="tbBlue" align="center" width="5%">契約滿期日</td>
																<td class="tbBlue" align="center" width="8%">保單狀況生效日期</td>
																<c:if test="${isRType}">
																	<td class="tbBlue" align="center" width="7%">要保書填寫日期</td>
																</c:if>
																<td class="tbBlue" align="center" width="8%">通報時間</td>
																<td class="tbBlue" align="center">錯誤原因</td>
															</tr>
															<c:forEach var="resultMap" items="${resultList}" varStatus="status">
															<tr>
																<td class="tbYellow2" align="center">${status.count}</td>
																<td class="tbYellow2" align="center">
																	<input type="radio" id="item${status.index}" name="item" onclick="selectItem(this);" value="${status.index}">
																	<input type="hidden" id="INSR_TYPE_DESC${status.index}" value="${resultMap.INSR_TYPE_DESC}">
																	<input type="hidden" id="I_ID${status.index}" value="${resultMap.I_ID}">
																	<input type="hidden" id="I_NAME${status.index}" value="${resultMap.I_NAME}">
																	<input type="hidden" id="I_BIRTHDAY${status.index}" value="${resultMap.I_BIRTHDAY}">
																	<input type="hidden" id="I_BIRTHDAY_ROC${status.index}" value="${resultMap.I_BIRTHDAY_ROC}">
																	<input type="hidden" id="I_GENDER${status.index}" value="${resultMap.I_GENDER}">																	
																	<input type="hidden" id="MAIN_POLICY_NO${status.index}" value="${resultMap.MAIN_POLICY_NO}">
																	<input type="hidden" id="POLICY_NO${status.index}" value="${resultMap.POLICY_NO}">
																	<input type="hidden" id="OIU_IND${status.index}" value="${resultMap.OIU_IND}">
																	<input type="hidden" id="SALE_CHNL${status.index}" value="${resultMap.SALE_CHNL}">
																	<input type="hidden" id="PROD_CODE${status.index}" value="${resultMap.PROD_CODE}">
																	<input type="hidden" id="POLICY_CAT${status.index}" value="${resultMap.POLICY_CAT}">
																	<input type="hidden" id="POLICY_DUTY${status.index}" value="${resultMap.POLICY_DUTY}">
																	<input type="hidden" id="PROD_KIND${status.index}" value="${resultMap.PROD_KIND}">
																	<input type="hidden" id="PAY_TYPE${status.index}" value="${resultMap.PAY_TYPE}">																	
																	<input type="hidden" id="PAY_AMT1-${status.index}" value="${resultMap.PAY_AMT1}">
																	<input type="hidden" id="PAY_AMT2-${status.index}" value="${resultMap.PAY_AMT2}">
																	<input type="hidden" id="PAY_AMT3-${status.index}" value="${resultMap.PAY_AMT3}">
																	<input type="hidden" id="PAY_AMT4-${status.index}" value="${resultMap.PAY_AMT4}">
																	<input type="hidden" id="PAY_AMT5-${status.index}" value="${resultMap.PAY_AMT5}">
																	<input type="hidden" id="PAY_AMT6-${status.index}" value="${resultMap.PAY_AMT6}">
																	<input type="hidden" id="PAY_AMT7-${status.index}" value="${resultMap.PAY_AMT7}">
																	<input type="hidden" id="PAY_AMT8-${status.index}" value="${resultMap.PAY_AMT8}">
																	<input type="hidden" id="PAY_AMT9-${status.index}" value="${resultMap.PAY_AMT9}">
																	<input type="hidden" id="PAY_AMT10-${status.index}" value="${resultMap.PAY_AMT10}">
																	<input type="hidden" id="PAY_AMT11-${status.index}" value="${resultMap.PAY_AMT11}">
																	<input type="hidden" id="PAY_AMT12-${status.index}" value="${resultMap.PAY_AMT12}">
																	<input type="hidden" id="PAY_AMT13-${status.index}" value="${resultMap.PAY_AMT13}">
																	<input type="hidden" id="PAY_AMT14-${status.index}" value="${resultMap.PAY_AMT14}">
																	<input type="hidden" id="PAY_AMT15-${status.index}" value="${resultMap.PAY_AMT15}">
																	<input type="hidden" id="PAY_AMT16-${status.index}" value="${resultMap.PAY_AMT16}">
																	<input type="hidden" id="PAY_AMT17-${status.index}" value="${resultMap.PAY_AMT17}">
																	<input type="hidden" id="PAY_AMT18-${status.index}" value="${resultMap.PAY_AMT18}">
																	<input type="hidden" id="PAY_AMT19-${status.index}" value="${resultMap.PAY_AMT19}">																	
																	<input type="hidden" id="ISSUE_DATE${status.index}" value="${resultMap.ISSUE_DATE}">
																	<input type="hidden" id="ISSUE_DATE_ROC${status.index}" value="${resultMap.ISSUE_DATE_ROC}">
																	<input type="hidden" id="ISSUE_TIME${status.index}" value="${resultMap.ISSUE_TIME}">																	
																	<input type="hidden" id="LPS_DATE${status.index}" value="${resultMap.LPS_DATE}">
																	<input type="hidden" id="LPS_DATE_ROC${status.index}" value="${resultMap.LPS_DATE_ROC}">
																	<input type="hidden" id="LPS_TIME${status.index}" value="${resultMap.LPS_TIME}">
																	<input type="hidden" id="PREM${status.index}" value="${resultMap.PREM}">
																	<input type="hidden" id="PAY_FREQ${status.index}" value="${resultMap.PAY_FREQ}">
																	<input type="hidden" id="PAY_PERIOD${status.index}" value="${resultMap.PAY_PERIOD}">																	
																	<input type="hidden" id="STATUS${status.index}" value="${resultMap.STATUS}">
																	<input type="hidden" id="LST_CHG_DATE${status.index}" value="${resultMap.LST_CHG_DATE}">
																	<input type="hidden" id="LST_CHG_DATE_ROC${status.index}" value="${resultMap.LST_CHG_DATE_ROC}">
																	<input type="hidden" id="LST_CHG_TIME${status.index}" value="${resultMap.LST_CHG_TIME}">
																	<input type="hidden" id="A_NAME${status.index}" value="${resultMap.A_NAME}">
																	<input type="hidden" id="A_ID${status.index}" value="${resultMap.A_ID}">																	
																	<input type="hidden" id="A_BIRTHDAY${status.index}" value="${resultMap.A_BIRTHDAY}">
																	<input type="hidden" id="A_BIRTHDAY_ROC${status.index}" value="${resultMap.A_BIRTHDAY_ROC}">
																	<input type="hidden" id="RELATION${status.index}" value="${resultMap.RELATION}">
																	<input type="hidden" id="LIA_STATUS${status.index}" value="${resultMap.LIA_STATUS}">																	
																	<input type="hidden" id="OUTPUT_TIME${status.index}" value="${resultMap.OUTPUT_TIME}">
																	<input type="hidden" id="SER_NO${status.index}" value="${resultMap.SER_NO}">
																	<input type="hidden" id="UPDATE_SRC${status.index}" value="${resultMap.UPDATE_SRC}">
																	<input type="hidden" id="UPDATE_TIME${status.index}" value="${resultMap.UPDATE_TIME}">																	
																	<input type="hidden" id="MEMO${status.index}" value="${resultMap.MEMO}">
																	<c:if test="${isRType}">
																		<input type="hidden" id="SIGN_DATE${status.index}" value="${resultMap.SIGN_DATE}">
																		<input type="hidden" id="SIGN_DATE_ROC${status.index}" value="${resultMap.SIGN_DATE_ROC}">
																		<input type="hidden" id="BROKTYPE${status.index}" value="${resultMap.BROKTYPE}">
																	</c:if>																																																		
																</td>
																<td class="tbYellow2" align="center">${resultMap.LIA_STATUS_DESC}</td>
																<td class="tbYellow2" align="center">${resultMap.FACE_AMT}</td>																
																<td class="tbYellow2" align="center">${resultMap.INSR_TYPE_DESC}</td>
																<td class="tbYellow2" align="center">${resultMap.I_ID}</td>
																<td class="tbYellow2" align="center">${resultMap.I_BIRTHDAY_ROC}</td>
																<td class="tbYellow2" align="center">${resultMap.I_GENDER_DESC}</td>
																<td class="tbYellow2" align="center">${resultMap.PROD_CODE}</td>
																<td class="tbYellow2" align="center">${resultMap.POLICY_DUTY}</td>
																<td class="tbYellow2" align="center">${resultMap.PROD_KIND}</td>
																<td class="tbYellow2" align="center">${resultMap.STATUS}</td>
																<td class="tbYellow2" align="center">${resultMap.ISSUE_DATE_ROC}</td>
																<td class="tbYellow2" align="center">${resultMap.LPS_DATE_ROC}</td>
																<td class="tbYellow2" align="center">${resultMap.LST_CHG_DATE_ROC}</td>
																<c:if test="${isRType}">
																	<td class="tbYellow2" align="center">${resultMap.SIGN_DATE}</td>
																</c:if>
																<td class="tbYellow2">${resultMap.OUTPUT_TIME}</td>
																<td class="tbYellow2">${resultMap.MEMO}</td>
															</tr>																		
															</c:forEach>
															<tr>
																<td class="tbYellow2" colspan="18" align="center">
																	<input type="button" id="exportBtn" name="exportBtn" value="Excel匯出" class="button" />
																</td>
															</tr>
														</tbody>
													</table>
													</c:if>
													</form>
													<form id="uploadFrm" name="uploadFrm" method="post" enctype="multipart/form-data">
													<table class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
														<tbody>
														<tr>
															<td class="tbYellow" width="20%" align="center">檔案匯入</td>
															<td class="tbYellow2" width="40%">																
																<input type="file" id="uploadFile" name="uploadFile">																
															</td>
															<td class="tbYellow2" width="40%" align="center">
																<input type="button" id="importBtn" name="importBtn" value="F8檔案上傳" class="button" />
																<input type="button" id="insrGroupBtn" name="insrGroupBtn" value="即時大批通報" class="button" />
															</td>
														</tr>
														</tbody>
													</table>
													</form>
													<table class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
														<tbody>
															<tr>
																<td class="tbYellow3">1.用大批匯入時，請先叫出資料後按Excel匯出鈕-->修改錯誤及處理結果(千萬記得保單狀況生效日也要調整)-->至檔案匯入-->按選擇檔案鈕-->選擇檔案-->按F8檔案上傳。<font color='red'>（限用Google  Chrome）</font></td>
															</tr>
															<tr>
																<td class="tbYellow3">2.Excel表格內容說明</td>
															</tr>
															<tr>
																<td class="tbYellow3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;　　
																	A.處理結果: 輸入代碼如：用此畫面修正及上傳時輸入8。
																</td>
															</tr>
															<tr>
																<td class="tbYellow3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;　　
																	(7:不需通報、8重新通報、9至公會系統人工通)
																</td>
															</tr>
															<tr>
																<td class="tbYellow3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;　　
																	B.結果:目前僅會顯示3(通報失敗)
																</td>
															</tr>
															<tr>
																<td class="tbYellow3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;　　
																	C.保額:此為投保保額，目前僅出壽險會顯示
																</td>
															</tr>
															<tr>
																<td class="tbYellow3">3.按F8檔案上傳鈕:收件批次每半小時、承保隔天通報</td>
															</tr>
															<tr>
																<td class="tbYellow3">4.即時大批通報鈕:將目前所有待通報之案件(收、承保)立即通報公會</td>
															</tr>
															<tr>
																<td class="tbYellow3">5.請參考公會補通報操作手冊、新通報平台系統操作手冊，<a href="#" onclick="linkATA00611();">點我開啟</a></td>
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
</body>
</html>
