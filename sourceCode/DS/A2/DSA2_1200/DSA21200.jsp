<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA21200.jsp
作者：孫建成
功能：放款退件處理
完成：2011/10/25
更新：

[20240729] 修改件 陳勁谷 難字修改
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<title></title>
<%--共用定義的css--%>
<style>
	.starColor {
		color: red;
	}	
	.blueColor{
		color: blue;
	}
</style>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var validForQuery;
var dataMap = null;

function initApp(){

	PageUI.createPageWithAllBodySubElement( "DSA21200" , "核貸作業" ,"放款退件處理 " , 0);

	displayMessage();
	validForQuery = new Validator();	
	
	validForQuery.define("APPLY_ID", '',  '受理編號有誤，請檢查後重新輸入!',  function(value){
		if( $F('APPLY_ID') == "" ){
			return false;
		}
		return true;
	});
	
	createREJ_REASON(false);
	
	var authButtons = {
			B0054:"modifyBtn<%--變更--%>"
	};
	<dz:grantButtons FUNC_ID="DSA21200" ignored="false"/>
	
	//先判斷有受理編號時，先用受理編號，否則取保留參數管理的受理編號
	$('APPLY_ID').value='${APPLY_ID}';
	if($('APPLY_ID').value==""){
		$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
	}
	if($('APPLY_ID').value){
		doQuery();
	}
	
	PageUI.resize(true);
}

<%--
	設定檢核條件
--%>
function setModifyCheckRule(validForModify,NOW_APPLY_ID,OLD_APPLY_ID) {
	validForModify.define("APPLY_ID", '',  '受理編號有誤，請檢查後重新輸入!',  function(value){
		if( $F('APPLY_ID') == "" ){
			return false;
		}
		return true;
	});
	
	if(NOW_APPLY_ID != OLD_APPLY_ID) {
		var msg = '欲作業的' + NOW_APPLY_ID + '與原先查詢的' + OLD_APPLY_ID + '不同,請重新查詢!';
		validForModify.define("APPLY_ID", '', msg, function(value) {return false;});
	}
	
	validForModify.define("REJ_REASON", '',  '退件原因為必輸欄位!',  function(value){
		if( $F('REJECT') == "1" && $F('REJ_REASON') == '00'){
			return false;
		}
		return true;
	});
	
	validForModify.define("SEND_CHECK", '',  '是否要送件控管需擇一點選!',  function(value){
		$('SEND_CHECK_TRUE').style.backgroundColor = "#FFFFFF";
		$('SEND_CHECK_FALSE').style.backgroundColor = "#FFFFFF";
		if( $('SEND_CHECK_TRUE').checked == false && $('SEND_CHECK_FALSE').checked == false ){
			return false;
		}
		return true;
	});
}

<%--
	 變更
--%>
function doModify() {

	<%--
		取得selectList的text
	--%>
	function getSelectedText(name,setValue,defaultText) {
		var optiontList = document.getElementById(name).options;
		for(var option in optiontList) {
			if(option.setValue == setValue) return option.text;
		}
		
		if(isNotEmpty(defaultText))
			return defaultText;
		else
			return "";
	}


	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%--
		3.1.1	須先查詢完成後，才可執行變更
		3.1.2	A區之受理編號需要值，若否，跳出警示訊息:‘受理編號有誤，請檢查後重新輸入!’
		3.1.3	A區之受理編號需要值需等於rtnMap.APPLY_ID，若否，跳出警示訊息:‘欲作業的{A區之受理編號}與原先查詢的{rtnMap.APPLY_ID}不同,請重新查詢’
		
		3.1.5	「是否退件」下拉選單為‘徵信退件’時，退件原因為必輸欄位
		3.1.6	if「是否退件」下拉選單為‘非退件’時，且rtnMap.CRED_ID不為空值，則提示確認訊息:‘確定要做退件取消作業？\n(取消退件後再退件，需重新進行退件呈核)’
		3.1.7	提示確認訊息:‘確定要做' + ｛「是否退件」下拉選單之代碼中文｝ + '作業？’
	--%>
	var validForModify = new Validator();	
	
	if( dataMap == null ){
		alert("須先查詢完成後，才可執行變更");
		return ;
	}
	
	var now_APPLY_ID = isNotEmpty(dataMap) && isNotEmpty(dataMap.APPLY_ID) ? dataMap.APPLY_ID : null;
	setModifyCheckRule(validForModify,$('APPLY_ID').value,now_APPLY_ID);
	if(validForModify.validate() == false) {
		return;
	}
	
	if( isNotEmpty(dataMap.CRED_ID) && dataMap.CRED_ID != "" && $F('REJECT') == '0<%--非退件--%>'){
		if(confirm("確定要做退件取消作業？\n(取消退件後再退件，需重新進行退件呈核)") == false) 
			return;
	}
	
	if(confirm("確定要做" + getSelectListText('REJECT') + "作業？") == false) {
		return;
	}
	
	<%--
		「是否退件」下拉選單之代碼中文
	--%>
	var REJ_OTHER_TEXT = getSelectedText('REJECT');
	
	<%--
		APPLY_ID  	rtnMap.APPLY_ID	受理編號
		APPLY_PROCESS	rtnMap.APPLY_PROCESS	受理進度
		BORROW_ID	rtnMap.BORROW_ID	借款人ID
		BORROW_NAME	rtnMap.BORROW_NAME	借款人姓名
		APPLY_DATE	rtnMap.APPLY_DATE	受理日期
		GAGE_ADDR	rtnMap.GAGE_ADDR	擔保品地址
		SEQ_NO_TEMP	rtnMap.SEQ_NO_TEMP	退件處理檔最新序號
		OLD_STATUS	rtnMap.OLD_STATUS	原受理進度
		CRED_ID	rtnMap.CRED_ID	徵信人員ID
		CRED_DEPT	rtnMap.CRED_DEPT	承辦科別
		
		REJ_REASON	畫面上資料	退件原因
		REJECT	畫面上資料	是否退件
		SEND_CHECK	畫面上資料	是否要送件控管
		REJ_OTHER	畫面上資料	其他退件原因
	--%>
  	new Ajax.Request("<%=dispatcher%>/DSA2_1200/doModify", 
	{
			parameters:{
				'APPLY_ID':		getValue(dataMap.APPLY_ID,null),
				'APPLY_PROCESS':getValue(dataMap.APPLY_PROCESS,null),
				'BORROW_ID':	getValue(dataMap.BORROW_ID,null),
				'BORROW_NAME':	getValue(dataMap.BORROW_NAME,null),
				'APPLY_DATE':	getValue(dataMap.APPLY_DATE,null),
				'GAGE_ADDR':	getValue(dataMap.GAGE_ADDR,null),
				'SEQ_NO_TEMP':	getValue(dataMap.SEQ_NO_TEMP,null),
				
				'OLD_STATUS':	getValue(dataMap.OLD_STATUS,null),
				'CRED_ID':		getValue(dataMap.CRED_ID,null),
				'CRED_DEPT':	getValue(dataMap.CRED_DEPT,null),
				
				'REJ_REASON':	getValue($('REJ_REASON').value,null),
				'REJECT':		getValue($('REJECT').value,null),
				'SEND_CHECK':	getRadioValue('SEND_CHECK'),
				'REJ_OTHER':	getValue(dataMap.REJ_OTHER,null),
				'REJ_OTHER_TEXT': REJ_OTHER_TEXT			
			},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
						showPageData(resp.dataMap);
						dataMap = resp.dataMap;
				}else{
					if(resp.DATA_NOT_FOUND){
						clearPageData();
					}						
				}
		 	}
	});
}

<%--
	查詢作業
--%>
function doQuery() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%--
		2.1.1	「受理編號」必須有值，否則顯示警示訊息：‘受理編號有誤，請檢查後重新輸入!’。	
	--%>
	if(validForQuery.validate() == false) {
		return;
	}

	//保留參數管理-更新受理編號
	CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});
	
  	new Ajax.Request("<%=dispatcher%>/DSA2_1200/doQuery", 
	{
			parameters:{'APPLY_ID':$F('APPLY_ID')},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
						showPageData(resp.dataMap);
						dataMap = resp.dataMap;
				}else{
					if(resp.DATA_NOT_FOUND){
						clearPageData();
					}						
				}
				PageUI.resize(true);
			}
	});
}

<%--
	建立REJ_REASON內容
--%>
function createREJ_REASON(withOther) {
	$('REJ_REASON').length = 0;
	<c:forEach var="costRpt" items="${REJ_REASON_LIST}">
		var elOptNew = document.createElement('option');
		elOptNew.text =  '${costRpt.value}';
		elOptNew.value = '${costRpt.key}';
		$('REJ_REASON').add(elOptNew);
	</c:forEach>
	
	if(withOther) {
		var elOptNew = document.createElement('option');
		elOptNew.text =  '其他';
		elOptNew.value = '81';
		$('REJ_REASON').add(elOptNew);
	}
}

<%--
	顯示資料於頁面
--%>
function showPageData(dataMap) {
	if(isNotEmpty(dataMap) && isNotEmpty(dataMap.APPLY_PROCESS) && dataMap.APPLY_PROCESS == '99') {
		<%--
			2.4.2.3	if rtnMap.APPLY_PROCESS = ‘99’ //目前受理進度為退件
			欄位名稱	NAME	欄位值	說明
			B區
				受理編號	APPLY_ID 	rtnMap.APPLY_ID	隱藏欄位
				借款人姓名	BORROW_NAME	rtnMap.BORROW_NAME	顯示欄位
				受理進度	APPLY_PROCESS_NM	rtnMap.APPLY_PROCESS_NM	顯示欄位
				擔保品位置	GAGE_ADDR	rtnMap.GAGE_ADDR	顯示欄位，需資料遮蔽
				徵信人員	CRED_NM	rtnMap.CRED_NM	顯示欄位
				連絡電話	TEL	rtnMap.TEL	顯示欄位
		--%>
		$('BORROW_NAME').innerHTML = getValue(dataMap.MARK_BORROW_NAME,'');	
		$('APPLY_PROCESS_NM').innerHTML = getValue(dataMap.APPLY_PROCESS_NM,'');	
		$('GAGE_ADDR').innerHTML = getValue(dataMap.GAGE_ADDR,'');	
		$('CRED_NM').innerHTML = getValue(dataMap.CRED_NM,'');	
		$('TEL').innerHTML = getValue(dataMap.TEL,'');	
		
		<%--
			C區
				是否退件	REJECT	REJ_LIST
					value:代碼
					顯示:代碼名稱	下拉選單
					/*非退件(value=0)、徵信退件(value=1)*/
					預設值:
					非退件(value=0)
				是否要送件控管	SEND_CHECK		RADIO輸入欄位
					checked(value=1)
					unchecked(value=0)
				退件原因	REJ_REASON	SHOW_REJ_REASON_LIST
					value:代碼
					顯示:代碼名稱	下拉選單，不可異動
					預設值:rtnMap.REJ_REASON
					其他退件原因	REJ_OTHER	rtnMap.REJ_OTHER	顯示欄位
					if rtnMap.REJ_REASON = ‘81’ //其他
					才需顯示
				退件人員	INPUT_NAME	rtnMap.INPUT_NAME	顯示欄位
				退件日期	INPUT_DATE	rtnMap.INPUT_DATE	顯示欄位，民國日期格式
				退件人員id	INPUT_ID	rtnMap.INPUT_ID	隱藏欄位
				退件處理檔最新序號	SEQ_NO_TEMP	rtnMap.SEQ_NO_TEMP	隱藏欄位
				原受理進度	OLD_STATUS	rtnMap.OLD_STATUS	隱藏欄位
		--%>
		$('REJECT').value = getValue(dataMap.REJECT,'0');
		setRadioValue('SEND_CHECK',		getValue(dataMap.SEND_CHECK,'')		);
		
		createREJ_REASON(true);
		$('REJ_REASON').value = getValue(dataMap.REJ_REASON,'00');
		$('REJ_REASON').disabled = true;
		
		$('INPUT_NAME').innerHTML = getValue(dataMap.INPUT_NAME,'');
		$('INPUT_DATE').innerHTML = getValue(dataMap.INPUT_DATE_ROC,'');
		
	}else {
		<%--
			2.4.2.4	if rtnMap.APPLY_PROCESS <> ‘99’ //目前受理進度非退件
			欄位名稱	NAME	欄位值	說明
			B區
				受理編號	APPLY_ID 	rtnMap.APPLY_ID	隱藏欄位
				借款人姓名	BORROW_NAME	rtnMap.BORROW_NAME	顯示欄位
				受理進度	APPLY_PROCESS_NM	rtnMap.APPLY_PROCESS_NM	顯示欄位
				擔保品位置	GAGE_ADDR	rtnMap.GAGE_ADDR	顯示欄位，需資料遮蔽
				徵信人員	CRED_NM	rtnMap.CRED_NM	顯示欄位
				連絡電話	TEL	rtnMap.TEL	顯示欄位
		--%>
		$('BORROW_NAME').innerHTML = getValue(dataMap.MARK_BORROW_NAME,'');	
		$('APPLY_PROCESS_NM').innerHTML = getValue(dataMap.APPLY_PROCESS_NM,'');	
		$('GAGE_ADDR').innerHTML = getValue(dataMap.GAGE_ADDR,'');	
		$('CRED_NM').innerHTML = getValue(dataMap.CRED_NM,'');	
		$('TEL').innerHTML = getValue(dataMap.TEL,'');	
	
	
		<%--
			C區
				是否退件	REJECT	REJ_LIST
				value:代碼
					顯示:代碼名稱	下拉選單
					/*非退件(value=0)、徵信退件(value=1)*/
					預設值:
					徵信退件(value=1)
				是否要送件控管	SEND_CHECK		RADIO輸入欄位
					checked(value=1)
					unchecked(value=0)
				退件原因	REJ_REASON	REJ_REASON_LIST	下拉選單，預設顯示第一筆資料
				
				作業人員	INPUT_NAME	rtnMap.INPUT_NAME	顯示欄位
				作業日期	INPUT_DATE	rtnMap.INPUT_DATE	顯示欄位，民國日期格式
				作業人員id	INPUT_ID	rtnMap.INPUT_ID	隱藏欄位
				退件處理檔最新序號	SEQ_NO_TEMP	rtnMap.SEQ_NO_TEMP	隱藏欄位
				原受理進度	OLD_STATUS	rtnMap.OLD_STATUS	隱藏欄位
		--%>
		$('REJECT').value = getValue(dataMap.REJECT,'1');
		setRadioValue('SEND_CHECK',		getValue(dataMap.SEND_CHECK,'')		);

		createREJ_REASON(false);
		$('REJ_REASON').value = getValue(dataMap.REJ_REASON,'00');
		$('REJ_REASON').disabled = false;
		
		$('INPUT_NAME').innerHTML = getValue(dataMap.INPUT_NAME,'');
		$('INPUT_DATE').innerHTML = getValue(dataMap.INPUT_DATE_ROC,'');
	}
	
	$('APPLY_ID').value = getValue(dataMap.APPLY_ID,'');
	$('INPUT_ID').value = getValue(dataMap.INPUT_ID,'');
	$('SEQ_NO_TEMP').value = getValue(dataMap.SEQ_NO_TEMP,'');
	$('OLD_STATUS').value = getValue(dataMap.OLD_STATUS,'');
	
	
	
}

<%--
	清空頁面資料
--%>
function clearPageData() {
	$('BORROW_NAME').innerHTML = '';
	$('APPLY_PROCESS_NM').innerHTML = '';
	$('GAGE_ADDR').innerHTML = '';
	$('CRED_NM').innerHTML = '';
	$('TEL').innerHTML = '';

	$('REJECT').value = '';
	setRadioValue('SEND_CHECK',		''		);
	$('REJ_REASON').value = '';
	$('REJ_REASON').value = '';
		
	$('INPUT_NAME').innerHTML = '';
	$('INPUT_DATE').innerHTML = '';
	$('APPLY_ID').value = '';
	$('INPUT_ID').value = '';
	$('SEQ_NO_TEMP').value = '';
	$('OLD_STATUS').value = '';
}

<%--
	辨別是不是為空值
--%>
function isNotEmpty(value) {
	if(value == null || typeof(value) == 'undefined') {
		return false;
	}else {
		return true;
	}
}
	
<%--
	轉大寫
--%>
function columnToUpperCase(columnName) {
	if(isNotEmpty($F(columnName))) {
		$(columnName).value = $(columnName).value.toUpperCase();
	}
}
	
	
function getValue(value,defaultValue) {
	return isNotEmpty(value) ? value : defaultValue;
}

function setRadioValue(name,value) {
	var radioItems = document.getElementsByName(name);
	for(var mover=0; mover < radioItems.length ; mover++) {
		var item = radioItems[mover];
		if(item.value == value) {
			item.checked = true;
		}else {
			item.checked = false;
		}
	}
}

function getRadioValue(name) {
	var radioItems = document.getElementsByName(name);
	for(var mover=0; mover < radioItems.length ; mover++) {
		var item = radioItems[mover];
		if(item.checked) {
			return item.value;
		}
	}
	return '';
}


function getSelectListText(listName) {
	var selectList = document.getElementById(listName);
	return selectList.options[selectList.selectedIndex].text;
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >

											<table width="100%" class="tbBox2" border="0" cellspacing="1" cellpadding="0">
											  <tr>
												  <td width="15%" class="tbYellow">受理編號</td>
												  <td class="tbYellow2" width="85%">
												  	<%-- YK100000213 value ="BG400940163" --%>
													<input type="text" size="14" maxlength="11" value ="" name="APPLY_ID" ID="APPLY_ID" class="textBox2">
													<input name="queryBtn" ID="queryBtn" onClick="doQuery()" type="button" class="button"	value="查詢"> 
												  </td>
											  </tr>	
											  <tr>
		  										  <td colspan="4" align="center">
													<input name="modifyBtn" ID="modifyBtn" onClick="doModify()" type="button" class="button" value="變更"> 
												  </td>
											  </tr>
											</table>
											
						                    <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
						                      <tr>
						                        <td width="15%" class="tbBlue">借款人姓名</td>
						                        <%--[20240729] 修改件 陳勁谷 難字修改 --%>
						                        <td width="35%" class="tbBlue2"><span id="BORROW_NAME" style="font-family:'EUDC'" /></td>
						                        <td width="15%" class="tbBlue">受理進度</td>
						                        <td width="35%" class="tbBlue2"><span id="APPLY_PROCESS_NM" /></td>
						                      </tr>
						                      <tr>
						                        <td class="tbBlue">擔保品位置</td>
						                        <%--[20240729] 修改件 陳勁谷 難字修改 --%>
						                        <td colspan="3" class="tbBlue2"><span id="GAGE_ADDR" style="font-family:'EUDC'" /></td>
						                      </tr>
						                      <tr>
						                        <td class="tbBlue">徵信人員</td>
						                        <%--[20240729] 修改件 陳勁谷 難字修改 --%>
						                        <td class="tbBlue2"><span id="CRED_NM" style="font-family:'EUDC'" /></td>
						                        <td class="tbBlue">連絡電話</td>
						                        <td class="tbBlue2"><span id="TEL" /></td>
						                      </tr>
						                      <tr>
						                        <td colspan="4" class="tbBlue2 "><font color="#FF0000">＊本項作業提供行政組或組長針對尚未派件案件做變更處理，徵信人員僅能做退件查詢</font></td>
						                      </tr>
						                    </table>
											

										<form name="form1" id="form1" method="post" action="">
				                            <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
					                        	<input type="hidden" name="APPLY_ID" id="APPLY_ID" value="">
					                        	<input type="hidden" name="INPUT_ID" id="INPUT_ID" value="">
					                        	<input type="hidden" name="SEQ_NO_TEMP" id="SEQ_NO_TEMP" value="">
					                        	<input type="hidden" name="OLD_STATUS" id="OLD_STATUS" value="">
					                        	<input type="hidden" name="REJ_OTHER_TEXT" id="REJ_OTHER_TEXT" value="">
					                              <tr>
					                                <td width="15%" height="22" class="tbYellow">是否退件</td>
					                                <td width="35%" class="tbYellow2">
														<select name="REJECT" id="REJECT" class="textBox2">
															<c:forEach var="costRpt" items="${REJ_LIST}">
																<option value="${costRpt.key}">${costRpt.value}</option>
															</c:forEach>
														</select>
					                                </td>
					                                <td width="15%" class="tbYellow"  >是否要送件控管</td>
					                                <td width="35%" class="tbYellow2" ><label>
					                                  <input name="SEND_CHECK" id="SEND_CHECK_TRUE" type="radio" value="1">
					                                  </label>是
					                                  <label>
					                                    <input name="SEND_CHECK" id="SEND_CHECK_FALSE" type="radio" value="0">
					                                  </label>否
					                                </td>
					                             </tr>
					                              <tr>
					                                <td height="22" class="tbYellow">退件原因</td>
					                                <td colspan="3" class="tbYellow2">
															<select name="REJ_REASON" id="REJ_REASON" class="textBox2">
															</select>
					                                </td>
					                             </tr>
					                              <tr>
					                                <td class="tbYellow">作業人員</td>
					                                <%--[20240729] 修改件 陳勁谷 難字修改 --%>
					                                <td height="22" class="tbYellow2"><span id="INPUT_NAME" style="font-family:'EUDC'" /></td>
					                                <td class="tbYellow">作業日期</td>
					                                <td height="22" class="tbYellow2"><span id="INPUT_DATE" /></td>
					                              </tr>
				                            </table>
			                             </form>
</body>
</html>
