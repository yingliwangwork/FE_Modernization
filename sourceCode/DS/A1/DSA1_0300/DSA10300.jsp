<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!-- 
[20200115]問題單:20200115091246 股票型態在查無資料時才控制預設，若資料庫中的資料是NULL，畫面顯示(請選擇)
 -->
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">


<script type="text/JavaScript"
	src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validation.js"></script>
<script type="text/JavaScript"
	src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<script type='text/javascript'
	src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/suggest.js"></script>
<%-- 搜尋提示用 --%>
<%--[20240723]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

<%--
	全區物件
--%>
var sectionA_map ={};
var LIST31 = [];
var LIST32 = [];
var LIST23 = [];
var sectionE_map ={};
var isCORP_DEPT = true;<%--[20191224]新增法金件判斷--%>
<%--[20191224]新增blockF參數(修改開始)--%>
var LISTA035_1 = [];
var LISTA035_2 = [];
var LISTA035_3 = [];
var LISTA035_4 = [];
var LISTA035_5 = [];
var LISTA035_L = [];
var BORROW_NAME = "";
var BORROW_ID = "";
<%--[20191224]新增blockF參數(修改結束)--%>
//擔保品種類
var GAGE_TYPE = '';

<%-- button 權限控制物件 --%>
var btn_B_insert;
var btn_B_update;
var btn_B_delete;
var btn_C_insert;
var btn_C_delete;
var btn_C_insert;
var btn_C_delete;

//建議清單：國家
var COUNTRY_List;

var validate4define;

var CHECK_LIST = <c:out value="${CHECK_LIST}" default="{}" escapeXml="false" />;

<%--
	程式進入點
--%>
function initApp(){
	
	<cathay:LocaleDisplay sysCode='DS' dateFields='' numberFields='' var='localeDisplay'/>
	
	buttonAuth();
	displayMessage();
	
	constructRows_BlockB(LIST31);
	constructRows_BlockC(LIST32);
	constructRows_BlockD(LIST23);
	
	
	<%--[20191224]控制法金件顯示欄位--%>
	actions.controlIsCORP_DEPT();
	<%--[20191224]新增F區資料--%>
	actions.construct_BlockF({});
	
	<%--[20191224]F區註冊事件--%>
	$w('blockF_1 blockF_2 blockF_3 blockF_4 blockF_5 blockF_6').each(function(blockType){
		$(blockType + '_insert').observe('click', function(){actions.insert_BlockF(blockType)});
		$(blockType + '_delete').observe('click', function(){actions.delete_BlockF(blockType)});
	});
	<%--[20191224]IS_GROUP連動--%>
	$$('input[name="IS_GROUP"]').each(function(ele){
		$(ele).observe('click', actions.setSomeDefaultFromIS_GROUP);
	});
	
	$('btn_calculate').observe('click', buttons.calculateLISTA035_L);<%--[20191224]試算事件註冊--%>
	$('btn_upload').observe('click', buttons.uploadFile);<%--[20191224]上傳事件註冊--%>
	$('btn_deleteFile').observe('click', buttons.deleteFile);<%--[20191224]刪除檔案--%>
	$('importFrame').observe('load', buttons.uploadEnd);<%--[20191224]上傳事件註冊--%>
	$('btn_exportTreeChart').observe('click', buttons.doExportTreeChart);<%--[20191224]產出股權結構圖事件註冊--%>
	$('FILE_NAME').observe('click', actions.downloadFile);<%--[20191224]下載檔案註冊事件--%>

	<%--[20200918]集團等級&信用評等註冊事件--%>
	$('GROUP_LVL').observe('change', actions.calcGROUP_INVEST_AMT);
	$('CRED_RATE').observe('change', actions.calcGROUP_INVEST_AMT);
	
	<%-- [20200918] 註冊國家 suggest --%>
	//建議清單：國家
	<c:if test="${not empty COUNTRY_List}">
		COUNTRY_List = ${COUNTRY_List};
	</c:if>
	
	<%-- [20200918] 註冊國家 suggest --%>
	Suggest.add( 'COUNTRY_NM',        // (必填)建議輸入欄位的ID    
		  Suggest.LIST,   // (必填)建議輸入的設定型態(動態查詢型態)   
		  COUNTRY_List,    // (必填)至後端查詢資料的網址。 
		{	"option_key" : "COUNTRY_NM",
			"remark" : "COUNTRY",
			 "startLength" : 1,
			 "noCookies" : true,
			 "ignoreCase" : true,
			 "callBackFunc" : function(node,rec){
				//$('COUNTRY_NM').setValue(rec ? rec['COUNTRY_NM'] : '');
				$('COUNTRY').setValue(rec ? rec['COUNTRY'] : '');
				$('COUNTRY_INVEST_AMT').disabled = (rec['COUNTRY'] == 'TW') ;
			}
		}
	);
	
	autoFormatToNumber();
	autoFormatToDate();
	
	PageUI.createPageWithAllBodySubElement("DSA10300" , "受理作業" , "法人資料輸入", 1, '${param.titleNotDisplay}' == 'Y');
	PageUI.resize(true);
	
	
	validate4define = new Validation("body", {useTitles:true, focusOnError:false, immediate:false});
	Validation.addAllThese([
		[ 'customize_returnFalse', '請自訂訊息',
			function(obj){
				return false;
			}
		]
	]);
	
	$('EMP_NUM').value = "0";
	$('CAPITAL').value = "0";
	$('REAL_CAPITAL').value = "0";
	$('IN_SALE_RATE').value = "0";
	$('OUT_SALE_RATE').value = "0";
	
	$('COP_TEL_AREA').value = '';
	$('FAC_TEL_AREA').value = '';
	
	if ('${APPLY_ID}' != "") {
		$('APPLY_ID').value = '${APPLY_ID}';
	} else { 
		//保留參數管理-取得受理編號
		$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
	}			
	if($('APPLY_ID').value){
		doQuery();
	}
}

<%--
	清除
--%>
function doClear_A() {
	location.href="<%=dispatcher%>/DSA1_0300/prompt";
}

<%--
	button控制
--%>
function buttonAuth(){
	var authButtons = {
		//B0001:"btnQuery",
		B0003:["blockA_insert","blockB_insert","blockC_insert","blockD_insert","blockF_1_insert","blockF_2_insert","blockF_3_insert","blockF_4_insert","blockF_5_insert","blockF_6_insert"],<%--[20191224]新增F區按鈕--%> 			
		B0005:["blockA_delete","blockB_delete","blockC_delete","blockD_delete","blockF_1_delete","blockF_2_delete","blockF_3_delete","blockF_4_delete","blockF_5_delete","blockF_6_delete"],<%--[20191224]新增F區按鈕--%>
		B0004:["blockA_update"],
		B0072 : "btn_calculate",<%--[20191224]新增試算按鈕--%>
		B0064 : "btn_upload",<%--[20191224]新增上傳按鈕--%>
		B0077 : "btn_deleteFile"<%--[20191224]新增刪除檔案按鈕--%>
	};
	<dz:grantButtons FUNC_ID="DSA10300" ignored="false"/> 	
	
	btn_B_insert = ($('blockB_insert').disabled == false ? true : false);
	btn_B_delete = ($('blockB_delete').disabled == false ? true : false);
	btn_C_insert = ($('blockC_insert').disabled == false ? true : false);
	btn_C_delete = ($('blockC_delete').disabled == false ? true : false);
	btn_D_insert = ($('blockD_insert').disabled == false ? true : false);
	btn_D_delete = ($('blockD_delete').disabled == false ? true : false);
}

<%--
	取得「法人與關係企業關係」下拉選單:
--%>
function getCORP_RELATION_LIST(id,onlyDisplayOrNot,onchangeFunction,selectDefaultValue) {
	
	var hiddenAttribute = (onlyDisplayOrNot ? 'style="display: none"' : ''  );

	var returnString = '<select ' ; 
		returnString += 'id="' + id +'" ' ;
		returnString += hiddenAttribute  ;
		returnString += 'onChange =\'' + onchangeFunction + '\' ';
		returnString += '>';
	<c:forEach var="costRpt" items="${CORP_RELATION_LIST}">
		if(selectDefaultValue == '${costRpt.value}') {
			returnString += '<option value="' + '${costRpt.value}' + '" selected>' + '${costRpt.key}' + '</option> '
		}else {
			returnString += '<option value="' + '${costRpt.value}' + '">' + '${costRpt.key}' + '</option> '
		}
	</c:forEach>
	returnString += "</select>";
	return returnString;
}

<%--
	取得「不動產使用情形」下拉選單:
--%>
function getLAND_USE_STS_LIST(id,onlyDisplayOrNot,onchangeFunction,selectDefaultValue) {

	var hiddenAttribute = (onlyDisplayOrNot ? 'style="display: none"' : ''   );

	var returnString = '<select ' ; 
		returnString += 'id="' + id +'" ' ;
		returnString += hiddenAttribute ;
		returnString += 'onChange =\'' + onchangeFunction + '\' ';
		returnString += '>';
	<c:forEach var="costRpt" items="${LAND_USE_STS}">
		if(selectDefaultValue == '${costRpt.value}') {
			returnString += '<option value="' + '${costRpt.value}' + '"selected>' + '${costRpt.key}' + '</option> '
		}else {
			returnString += '<option value="' + '${costRpt.value}' + '">' + '${costRpt.key}' + '</option> '
		}
	</c:forEach>
	returnString += "</select>";
	return returnString;
}

<%--
	取得法人與關係企業關係之顯示值
--%>
function getShowTextFromCORP_RELATION_LIST(value) {
	<c:forEach var="costRpt" items="${CORP_RELATION_LIST}">
		if(value == '${costRpt.value}') return '${costRpt.key}';
	</c:forEach>
	return "";
}

<%--
	取得不動產使用情形之顯示值
--%>
function getShowTextFromLAND_USE_STS_LIST(value) {
	<c:forEach var="costRpt" items="${LAND_USE_STS}">
		if(value == '${costRpt.value}') return '${costRpt.key}';
	</c:forEach>
	return "";
}

<%--
	取得法人與關係企業關係之下拉預設值
--%>
function getDefault_CORP_RELATION_LIST_Value() {
	<c:forEach var="costRpt" items="${LAND_USE_STS}">
		return '${costRpt.value}';
	</c:forEach>
	return "";
}

<%--
	取得法人與關係企業關係之顯示預設值
--%>
function getDefault_CORP_RELATION_LIST_Text() {
	<c:forEach var="costRpt" items="${CORP_RELATION_LIST}">
		return '${costRpt.key}';
	</c:forEach>
	return "";
}

<%--
	取得不動產使用情形之下拉預設值
--%>
function getDefault_LAND_USE_STS_LIST_Value() {
	<c:forEach var="costRpt" items="${LAND_USE_STS}">
		return '${costRpt.value}';
	</c:forEach>
	return "";
}

<%--
	取得不動產使用情形之顯示預設值
--%>
function getDefault_LAND_USE_STS_LIST_Text() {
	<c:forEach var="costRpt" items="${CORP_RELATION_LIST}">
		return '${costRpt.key}';
	</c:forEach>
	return "";

}

function getField(fieldValue) {

	if(isNotEmpty(fieldValue)) {
		return fieldValue;
	}
	return "";
}

function statusOkOrNot() {
	if(getSelectRadioItem('list_B') != null){
		alert('主要董監事區塊操作尚未完成');	
		return false;
	}
	if(getSelectRadioItem('list_C') != null){
		alert('投資事業概況區塊操作尚未完成');	
		return false;
	}
	if(getSelectRadioItem('list_D') != null){
		alert('不動產明細區塊操作尚未完成');	
		return false;
	}
	return true;
}



<%--
	依查詢結果更新整個頁面
--%>
function refreshPage(resp) {
	isCORP_DEPT = resp.isCORP_DEPT;<%--[20191224]新增是否為法金件參數--%>
	
	sectionA_map = (	resp.sectionA_map ? resp.sectionA_map : {} );
	BORROW_NAME = sectionA_map['BORROW_NAME'] || resp.BORROW_NAME || '';<%--[20191224]更新BORROW_NAME--%>
	BORROW_ID = sectionA_map['BORROW_ID'] || resp.BORROW_ID || '';<%--[20191224]更新BORROW_ID--%>

	GAGE_TYPE = resp.GAGE_TYPE;
	construct_BlockA(sectionA_map, resp.DATA_NOT_FOUND, resp);<%--[20200115]新增參數 判斷是否為查無資料--%>
	
	LIST31 = (	resp.LIST31 ? resp.LIST31 : [] );
 	constructRows_BlockB(LIST31);

	LIST32 = (	resp.LIST32 ? resp.LIST32 : [] );
 	constructRows_BlockC(LIST32);

	LIST23 = (	resp.LIST23 ? resp.LIST23 : [] );
 	constructRows_BlockD(LIST23);
	
	sectionE_map = (	resp.sectionE_map ? resp.sectionE_map : {} );
	construct_BlockE(sectionE_map);
	
	<%--[20191224]控制法金件顯示欄位--%>
	actions.controlIsCORP_DEPT();
	if(isCORP_DEPT){
		actions.setSomeDefaultFromIS_GROUP();
	}
	<%--[20191224]新增F區--%>
	actions.construct_BlockF(resp);

	autoFormatToNumber();
	autoFormatToDate();
	PageUI.resize(true);
}

<%--
	查詢作業
--%>
function doQuery() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');
	
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	
	<%--
		2.1.1	「受理編號」必須有值，否則顯示警示訊息：‘您必須填入受理編號的資料!!’。	
	--%>
	
	if($('APPLY_ID').value == "") {
		alert("您必須填入受理編號的資料!!");
		return;
	}

	//保留參數管理-更新受理編號
	CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});

  	new Ajax.Request("<%=dispatcher%>/DSA1_0300/query", 
		{
			asynchronous: false,
			parameters:{"APPLY_ID":$('APPLY_ID').value},
		 	onSuccess: function(XHT, resp){
	 			refresh = false;
		 		if(CSRUtil.isSuccess(resp)){
		 			refresh = true;
		 		}else {
		 			if(resp.DATA_NOT_FOUND) {
			 			refresh = true;
		 			}
		 		}
		 		if(refresh) {
		 			refreshPage(resp);
		 		}
		 	}
		}	
	);
}

<%--
	刪除指定元素: 
	由於 delete無法使用，自行寫一個
--%>
function deleteOneElement(sourceList,index) {
	var outputArray =[];
	for(var mover=0; mover < sourceList.length ; mover++) {
		if(mover !=	index) {
			outputArray.push(sourceList[mover]);
		}
	}
	return outputArray;
}

<%--
	取得SEQ_NO(i)最大一筆+1
--%>

function getNextSEQ_NO(sourceList,SEQ_NO_COLUMN_Name) {
	var MAX_SEQ_NO = 0;
	if(sourceList && sourceList.length > 0) {
		for(var mover=0; mover < sourceList.length ; mover++)
		{
			var targetMover = sourceList[mover];
			if(targetMover[SEQ_NO_COLUMN_Name] > MAX_SEQ_NO)
			{
				MAX_SEQ_NO = targetMover[SEQ_NO_COLUMN_Name];
			}
		}
	}
	return MAX_SEQ_NO - 0 + 1;
}

<%--
	選取radio的 item
--%>
function selectRadioItem(radioListName,setValue) {
	var radioItems = document.getElementsByName(radioListName);
	for(var mover =0; mover < radioItems.length ; mover++)
	{
		var targetElement = radioItems[mover];
		if(targetElement.value == setValue) {
			targetElement.checked = true;
		}
	}
}

<%--
	取得選取的radio item
--%>
function getSelectRadioItem(radioListName) {
	var radioItems = document.getElementsByName(radioListName);
	for(var mover =0; mover < radioItems.length ; mover++)
	{
		var targetElement = radioItems[mover];
		if(targetElement.checked) {
			return targetElement;
		}
	}
	return null;
}


<%--
	取消選取radio的 item
--%>
function unselectRadioItem(radioListName) {
	var radioItems = document.getElementsByName(radioListName);
	for(var mover =0; mover < radioItems.length ; mover++)
	{
		var targetElement = radioItems[mover];
		if(targetElement.checked) {
			targetElement.checked = false;
		}
	}
}

<%--
	開啟或關閉程式
--%>
function setRadioItemDisabled(radioListName,disabledOrNot) {
	var radioItems = document.getElementsByName(radioListName);
	for(var mover =0; mover < radioItems.length ; mover++)
	{
		var targetElement = radioItems[mover];
		targetElement.disabled = disabledOrNot;
	}

}

<%--
	看一個radioList有無任何項目被選取
--%>
function radioListHaveSelectedOrNot(radioListName) {
	var radioItems = document.getElementsByName(radioListName);
	for(var mover =0; mover < radioItems.length ; mover++)
	{
		var targetElement = radioItems[mover];
		if(targetElement.checked) {
			return true;
		}
	}
	return false;
}

<%--
==========================================================
=======================區塊 A程式操作======================
==========================================================
--%>

<%--
	區塊A	新增
--%>
function insert_BlockA() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	
	<%--設定檢核--%>	
	checks();
	
	if(!validate4define.validate()){
		return ;
	}
	
	<%--[20191224]法金件檢核--%>
	/* 20200212 良全：文初時在檢核
	if(isCORP_DEPT && $F('STOCK_TYPE') == 5 && LISTA035_L.length == 0){
		<%--F-6區必須有資料--%>
		alert("請輸入並試算股東持股比例");
		return
	}*/
		
	if($F('APPLY_ID') != $F('OLD_APPLY_ID')) {
		if(confirm("請確認是否將資料新增到" + $F('APPLY_ID') + "中?") == false) {
			return ;
		}
	}
	<%-- [20200907] --%>
	if(isCORP_DEPT){
	//3.1.10.4 集團限額檢核
			var IS_GROUP_radioElement = getSelectRadioItem('IS_GROUP');//是否為集團
			//GROUP_LVL" class="textBox2 isCORP_DEPT" title="集團等級">
			//CRED_RATE" class="textBox2 isCORP_DEPT" title="信用評等">
		<!-- 					集團及其他法人機構尚可投資金額	授信額度			檢核結果(集團)		本公司調整後淨值 -->
		<!-- 					GROUP_INVEST_AMT				CREDIT_AMT		CHECK_GROUP_NM		OWNERSHIP -->
		var key = '';
		if(IS_GROUP_radioElement == null || $F('GROUP_INVEST_AMT')== ''){
			key = '1';// '未完成';
		}else{
			if(parseInt($F('GROUP_INVEST_AMT')) < parseInt($F('CREDIT_AMT'))){
				key = '3';//'不符合規範';
			}else {
				key = '4';//'符合規範';
			}
		}
		$('CHECK_GROUP_NM').update ( CHECK_LIST[key]);
		$('hCHECK_GROUP_NM').setValue ( key);
		
	//3.1.10.5 國家限額檢核
		<!-- 					國家尚可投資金額					國家限額-國家名稱		檢核結果(國家)	 -->
		<!-- 					COUNTRY_INVEST_AMT				COUNTRY					CHECK_COUNTRY_NM -->
		key = '';
		if($F('COUNTRY')==''){
			key = '1';// '未完成';
		}else if($F('COUNTRY')!='TW' && $F('COUNTRY_INVEST_AMT')==''){
			key = '1';// '未完成';
		}else  if($F('COUNTRY') == 'TW' ){
			key = '2';//'不適用';
		}else{
			if(parseInt($F('COUNTRY_INVEST_AMT')) >= parseInt($F('CREDIT_AMT'))) {
				key = '4';//'符合規範';
			}else{
				key = '3';//'不符合規範';
			}
		}
		$('CHECK_COUNTRY_NM').update ( CHECK_LIST[key]);
		$('hCHECK_COUNTRY_NM').setValue (key);
	}
	
	//3.2	讀取畫面資料: 
	//3.2.1	將畫面資料(A區)存成A030vo,
 	//(B區)存成A031List,(C區)存成A032List,(D區)存成A023List
	setBlockA();
	
	var A030vo =   Object.toJSON(sectionA_map);
	var A031List = Object.toJSON(LIST31);
	var A032List = Object.toJSON(LIST32);
	var A023List = Object.toJSON(LIST23);
	var A035Map = actions.getA035Map();<%-- [20191224]新增A035資料 --%>
	
  	new Ajax.Request("<%=dispatcher%>/DSA1_0300/doInsert_sectionA", 
		{
			asynchronous: false,
			parameters:{"APPLY_ID":$('APPLY_ID').value,"A030vo":A030vo, "A031List":A031List, "A032List":A032List, "A023List":A023List, "A035Map": Object.toJSON(A035Map)},
		 	onSuccess: function(XHT, resp){
	 			refresh = false;
		 		if(CSRUtil.isSuccess(resp)){
		 			refreshPage(resp);
		 		}
		 	}
		}	
	);
}

<%--
	區塊A	更新
--%>
function update_BlockA() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%--
		IF  APPLY_ID(受理編號-輸入欄位) NOT  =  OLD_APPLY_ID(受理編號-顯示欄位)
		    顯示錯誤訊息:‘欲修改的受理編號與原先查詢的資料不同，無法作業!’
	--%>
	if($('APPLY_ID').value != $('OLD_APPLY_ID').value) {
		alert('欲刪除的受理編號與原先查詢的資料不同，無法作業!');
		return ;
	}

	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	
	<%--設定檢核--%>	
	checks();
	validateEmpty('CREDIT_AMT',"授信額度必須輸入!");
	
	if(!validate4define.validate()){
		return ;
	}
	
	<%--[20191224]法金件檢核--%>	
	/* 20200212 良全：文初時在檢核
	if(isCORP_DEPT && $F('STOCK_TYPE') == 5 && LISTA035_L.length == 0){
		<%--F-6區必須有資料--%>
		alert("請輸入並試算股東持股比例");
		return
	}*/
	
	<%-- [20200907] --%>
	if(isCORP_DEPT){
	//5.1.7.4 集團限額檢核
			var IS_GROUP_radioElement = getSelectRadioItem('IS_GROUP');//是否為集團
			//GROUP_LVL" class="textBox2 isCORP_DEPT" title="集團等級">
			//CRED_RATE" class="textBox2 isCORP_DEPT" title="信用評等">
		<!-- 					集團及其他法人機構尚可投資金額	授信額度			檢核結果(集團)		本公司調整後淨值 -->
		<!-- 					GROUP_INVEST_AMT				CREDIT_AMT		CHECK_GROUP_NM		OWNERSHIP -->
		<!-- 					國家尚可投資金額					國家限額-國家名稱		檢核結果(國家)	 -->
		<!-- 					COUNTRY_INVEST_AMT				COUNTRY					CHECK_COUNTRY_NM -->
		
		var key = '';
		if(IS_GROUP_radioElement == null || $F('GROUP_INVEST_AMT')== ''){
			key = '1';// '未完成';
		}else{
			if(parseInt($F('GROUP_INVEST_AMT')) < parseInt($F('CREDIT_AMT'))){
				key = '3';//'不符合規範';
			}else {
				key = '4';//'符合規範';
			}
		}
		$('CHECK_GROUP_NM').update ( CHECK_LIST[key]);
		$('hCHECK_GROUP_NM').setValue (key);
	
	//5.1.7.5 國家限額檢核
		key = '';
		if($F('COUNTRY')==''){
			key = '1';// '未完成';
		}else if($F('COUNTRY')!='TW' && $F('COUNTRY_INVEST_AMT')==''){
			key = '1';// '未完成';
		}else  if($F('COUNTRY') == 'TW' ){
			key = '2';//'不適用';
		}else{
			if(parseInt($F('COUNTRY_INVEST_AMT')) >= parseInt($F('CREDIT_AMT'))){
				key = '4';//'符合規範';
			}else{
				key = '3';//'不符合規範';
			}
		}
		$('CHECK_COUNTRY_NM').update ( CHECK_LIST[key]);
		$('hCHECK_COUNTRY_NM').setValue (key);
	}
	<%--
		OLD_APPLY_ID   	畫面上的受理編號	
		ID	畫面上的營利事業統一編號	
		APPLY_PROCESS	畫面上的受理進度(隱藏欄位)	
		A010_INPUT_ID	畫面上的輸入人員ID(受理主檔)(隱藏欄位)	
		CRED_ID	畫面上的徵信人員ID(隱藏欄位)	
		user	user	userObject
	--%>
	var APPLY_ID = $('APPLY_ID').value;
	var ID = $('ID').value;
	var APPLY_PROCESS = $('APPLY_PROCESS').value;
	var A010_INPUT_ID = $('A010_INPUT_ID').value;
	var CRED_ID = $('CRED_ID').value;
	
	setBlockA();
	var A030vo =   Object.toJSON(sectionA_map);
	var A031List = Object.toJSON(LIST31);
	var A032List = Object.toJSON(LIST32);
	var A023List = Object.toJSON(LIST23);
	var A035Map = actions.getA035Map();<%-- [20191224]新增A035資料 --%>
	
  	new Ajax.Request("<%=dispatcher%>/DSA1_0300/doUpdate_sectionA", 
		{
			asynchronous: false,
			parameters:{"A030vo":A030vo, "A031List":A031List, "A032List":A032List, "A023List":A023List
						,"APPLY_ID":APPLY_ID, "ID":ID, "APPLY_PROCESS":APPLY_PROCESS, "APPLY_PROCESS":APPLY_PROCESS, "CRED_ID":CRED_ID,
						"A035Map" : Object.toJSON(A035Map)},
		 	onSuccess: function(XHT, resp){
	 			refresh = false;
		 		if(CSRUtil.isSuccess(resp)){
		 			refreshPage(resp);
		 		}
		 	}
		}	
	);
}

<%--
	區塊A	刪除
--%>
function delete_BlockA() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');
	
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色

	<%--
		4.	刪除(A區)(B0005)
		4.1	畫面程序檢核:
		4.1.1	檢查受理編號是否與查詢時不同:
		IF  APPLY_ID(受理編號-輸入欄位) NOT  =  OLD_APPLY_ID(受理編號-顯示欄位)
				 顯示錯誤訊息:‘欲刪除的受理編號與原先查詢的資料不同，無法作業!’
		4.1.2	顯示確認訊息‘是否確認刪除?’，確認後才繼續執行
	--%>
	if($('APPLY_ID').value != $('OLD_APPLY_ID').value) {
		alert('欲刪除的受理編號與原先查詢的資料不同，無法作業!');
		return ;
	}
	if(confirm("是否確認刪除?") == false) {
		return ;
	}
	
	validateEmpty('APPLY_ID',"受理編號必須輸入!");
	
	if(validate4define.validate() == false)
		return ;
	
	<%--
		4.2	讀取畫面欄位資料:
		4.2.1	將畫面資料rtnMap存成mapA:
		欄位名稱	欄位值	說明
		OLD_APPLY_ID  	畫面上的受理編號	
		ID	畫面上的營利事業統一編號	
		APPLY_PROCESS	畫面上的受理進度(隱藏欄位)	
		A010_INPUT_ID	畫面上的輸入人員ID(受理主檔)(隱藏欄位)	
		CRED_ID	畫面上的徵信人員ID(隱藏欄位)	
		user	user	userObject
	--%>
	setBlockA();
	var APPLY_ID = $('APPLY_ID').value;
	var ID = $('ID').value;
	var APPLY_PROCESS = $('APPLY_PROCESS').value;
	var A010_INPUT_ID = $('A010_INPUT_ID').value;
	var CRED_ID = $('CRED_ID').value;
	
  	new Ajax.Request("<%=dispatcher%>/DSA1_0300/doDelete_sectionA", 
		{
			asynchronous: false,
			parameters:{"APPLY_ID":APPLY_ID, "ID":ID, "APPLY_PROCESS":APPLY_PROCESS, "APPLY_PROCESS":APPLY_PROCESS, "CRED_ID":CRED_ID},
		 	onSuccess: function(XHT, resp){
	 			refresh = false;
		 		if(CSRUtil.isSuccess(resp)){
		 			refreshPage(resp);
		 		}
		 	}
		}	
	);
}

<%--
將區塊A的資料設定到sectionA_map
--%>
function setBlockA() {
	<%--
		受理編號			APPLY_ID		畫面上的受理編號	文字輸入欄位，長度11
		受理編號			OLD_APPLY_ID	rtnMap.APPLY_ID	顯示欄位
		受理進度			APPLY_PROCESS_NM	rtnMap.APPLY_PROCESS_NM	顯示欄位
	--%>
	sectionA_map["APPLY_ID"] = $('APPLY_ID').value;
	sectionA_map["OLD_APPLY_ID"] = $('OLD_APPLY_ID').value;
	sectionA_map["APPLY_PROCESS_NM"] = $('APPLY_PROCESS_NM').value;
	
	<%--
		名稱(中文)		CNAME		rtnMap.CNAME	文字輸入欄位，長度26
		名稱(英文)		ENAME		rtnMap.ENAME	文字輸入欄位，長度26
		成立日期			BUILD_DATE		rtnMap.BUILD_DATE	日期欄位,亦可透過日曆模式點選日期
		營利事業統一編號	ID		rtnMap.ID	文字輸入欄位，長度10
		負責人			CHIEF		rtnMap.CHIEF	文字輸入欄位，長度60
		員工人數			EMP_NUM		rtnMap.EMP_NUM	數字格式輸入欄位,無資料預設為0
	--%>
	sectionA_map["CNAME"] = $('CNAME').value;
	sectionA_map["ENAME"] = $('ENAME').value;
	sectionA_map["BUILD_DATE"] = $F('BUILD_DATE');<%--[20191224]改取出西元年--%>
	sectionA_map["ID"] = $('ID').value;
	sectionA_map["CHIEF"] = $('CHIEF').value;
	sectionA_map["EMP_NUM"] = $F('EMP_NUM');<%--[20200916]改取出沒有逗號的數字--%>
	
	<%--
		地址(公司)		COP_ADDR	rtnMap.COP_ADDR	文字輸入欄位，長度26
		電話-區碼(公司)	COP_TEL_AREA	rtnMap.COP_TEL_AREA	數字格式輸入欄位
		電話(公司)		COP_TEL_NUM	rtnMap.COP_TEL_NUM	數字格式輸入欄位
		電話-分機(公司)	COP_TEL_EXT	rtnMap.COP_TEL_EXT	數字格式輸入欄位
	--%>
	sectionA_map["COP_ADDR"] = $('COP_ADDR').value;
	sectionA_map["COP_TEL_AREA"] = $('COP_TEL_AREA').value;
	sectionA_map["COP_TEL_NUM"] = $('COP_TEL_NUM').value;
	sectionA_map["COP_TEL_EXT"] = $('COP_TEL_EXT').value;
	
	<%--
		地址(工廠)		FAC_ADDR	rtnMap.FAC_ADDR	文字輸入欄位，長度26
		電話-區碼(工廠)	FAC_TEL_AREA	rtnMap.FAC_TEL_AREA	數字格式輸入欄位
		電話(工廠)		FAC_TEL_NUM	rtnMap.FAC_TEL_NUM	數字格式輸入欄位
		電話-分機(工廠)	FAC_TEL_EXT	rtnMap.FAC_TEL_EXT	數字格式輸入欄位
	--%>
	sectionA_map["FAC_ADDR"] = $('FAC_ADDR').value;
	sectionA_map["FAC_TEL_AREA"] = $('FAC_TEL_AREA').value;
	sectionA_map["FAC_TEL_NUM"] = $('FAC_TEL_NUM').value;
	sectionA_map["FAC_TEL_EXT"] = $('FAC_TEL_EXT').value;

	<%--
		登記資本額		CAPITAL	rtnMap.CAPITAL	數字格式輸入欄位
		實收資本額		REAL_CAPITAL	rtnMap.REAL_CAPITAL	數字格式輸入欄位
		主要業務及產品	PRODUCT	rtnMap.PRODUCT	文字輸入欄位，長度50
		主要銷售對象		MARKET	rtnMap.MARKET	文字輸入欄位，長度50
	--%>
	sectionA_map["CAPITAL"] = $F('CAPITAL');<%--[20191224]改取出沒有逗號的數字--%>
	sectionA_map["REAL_CAPITAL"] = $F('REAL_CAPITAL');<%--[20191224]改取出沒有逗號的數字--%>
	sectionA_map["PRODUCT"] = $('PRODUCT').value;
	sectionA_map["MARKET"] = $('MARKET').value;

	<%--
		銷售方式(內銷)	IN_SALE_RATE	rtnMap.IN_SALE_RATE	數字格式輸入欄位,
		無資料預設為0
		銷售方式(外銷)	OUT_SALE_RATE	rtnMap.OUT_SALE_RATE	數字格式輸入欄位,
		無資料預設為0
		產業別			TERRITORY	rtnMap.TERRITORY	文字輸入欄位，長度15
		受理進度			APPLY_PROCESS	rtnMap.APPLY_PROCESS	隱藏欄位
	--%>
	sectionA_map["IN_SALE_RATE"] = $F('IN_SALE_RATE');<%--[20191224]改取出沒有逗號的數字--%>
	sectionA_map["OUT_SALE_RATE"] = $F('OUT_SALE_RATE');<%--[20191224]改取出沒有逗號的數字--%>
	sectionA_map["TERRITORY"] = $('TERRITORY').value;
	sectionA_map["APPLY_PROCESS"] = $('APPLY_PROCESS').value;
	
	<%--
		輸入人員ID
		(受理主檔)	A010_INPUT_ID	rtnMap.A010_INPUT_ID	隱藏欄位
		徵信人員ID	CRED_ID	rtnMap.CRED_ID	隱藏欄位
	--%>
	sectionA_map["A010_INPUT_ID"] = $('A010_INPUT_ID').value;
	sectionA_map["CRED_ID"] = $('CRED_ID').value;
	<%--[20191224]新增欄位--%>
	var IS_GROUP_radioElement = getSelectRadioItem('IS_GROUP');
	sectionA_map["IS_GROUP"] = IS_GROUP_radioElement != null ? IS_GROUP_radioElement.value : '';
	sectionA_map["GROUP_NAME"] = $F('GROUP_NAME');
	sectionA_map["GROUP_LVL"] = $F('GROUP_LVL');
	sectionA_map["CRED_RATE"] = $F('CRED_RATE');
	sectionA_map["STOCK_TYPE"] = $F('STOCK_TYPE');
	
	
	<%--[20200907]新增欄位--%>
	sectionA_map["GROUP_INVEST_AMT"  ]=$F('GROUP_INVEST_AMT');
	sectionA_map["CREDIT_AMT"        ]=$F('CREDIT_AMT');
	sectionA_map["CHECK_GROUP"    ]=$F('hCHECK_GROUP_NM');
	sectionA_map["COUNTRY_INVEST_AMT"]=$F('COUNTRY_INVEST_AMT');
	sectionA_map["COUNTRY"           ]=$F('COUNTRY');
	sectionA_map["CHECK_COUNTRY"  ]=$F('hCHECK_COUNTRY_NM');
}

<%--
	建構區塊A
	[20200115]新增判斷是否為查無資料的參數
--%>
function construct_BlockA(rtnMap, isDataNotFound, resp) {
	<%--
		受理編號			APPLY_ID		畫面上的受理編號	文字輸入欄位，長度11
		受理編號			OLD_APPLY_ID	rtnMap.APPLY_ID	顯示欄位
		受理進度			APPLY_PROCESS_NM	rtnMap.APPLY_PROCESS_NM	顯示欄位
	--%>
	$('SHOW_OLD_APPLY_ID').innerHTML = rtnMap.APPLY_ID ? rtnMap.APPLY_ID : "";
	$('OLD_APPLY_ID').value = rtnMap.APPLY_ID ? rtnMap.APPLY_ID : "";
	$('SHOW_APPLY_PROCESS_NM').innerHTML = rtnMap.APPLY_PROCESS_NM ? rtnMap.APPLY_PROCESS_NM : "";
	$('APPLY_PROCESS_NM').value = rtnMap.APPLY_PROCESS_NM ? rtnMap.APPLY_PROCESS_NM : "";
	
	<%--
		名稱(中文)		CNAME		rtnMap.CNAME	文字輸入欄位，長度26
		名稱(英文)		ENAME		rtnMap.ENAME	文字輸入欄位，長度26
		成立日期			BUILD_DATE		rtnMap.BUILD_DATE	日期欄位,亦可透過日曆模式點選日期
		營利事業統一編號	ID		rtnMap.ID	文字輸入欄位，長度10
		負責人			CHIEF		rtnMap.CHIEF	文字輸入欄位，長度60
		員工人數			EMP_NUM		rtnMap.EMP_NUM	數字格式輸入欄位,無資料預設為0
	--%>
	$('CNAME').value = (rtnMap.CNAME ? rtnMap.CNAME : "");
	$('ENAME').value = rtnMap.ENAME ? rtnMap.ENAME : "";
	$('BUILD_DATE').value = rtnMap.BUILD_DATE ? rtnMap.BUILD_DATE : "";
	$('ID').value = rtnMap.ID ? rtnMap.ID : "";
	$('CHIEF').value = rtnMap.CHIEF ? rtnMap.CHIEF : "";
	$('EMP_NUM').value = rtnMap.EMP_NUM ? CSRUtil.$fmt(rtnMap.EMP_NUM,"#,###.###") : "0";
	
	<%--
		地址(公司)		COP_ADDR	rtnMap.COP_ADDR	文字輸入欄位，長度26
		電話-區碼(公司)	COP_TEL_AREA	rtnMap.COP_TEL_AREA	數字格式輸入欄位
		電話(公司)		COP_TEL_NUM	rtnMap.COP_TEL_NUM	數字格式輸入欄位
		電話-分機(公司)	COP_TEL_EXT	rtnMap.COP_TEL_EXT	數字格式輸入欄位
	--%>
	$('COP_ADDR').value = rtnMap.COP_ADDR ? rtnMap.COP_ADDR : "";
	$('COP_TEL_AREA').value = rtnMap.COP_TEL_AREA ? rtnMap.COP_TEL_AREA : "";
	$('COP_TEL_NUM').value = rtnMap.COP_TEL_NUM ? rtnMap.COP_TEL_NUM : "";
	$('COP_TEL_EXT').value = rtnMap.COP_TEL_EXT ? rtnMap.COP_TEL_EXT : "";
	
	<%--
		地址(工廠)		FAC_ADDR	rtnMap.FAC_ADDR	文字輸入欄位，長度26
		電話-區碼(工廠)	FAC_TEL_AREA	rtnMap.FAC_TEL_AREA	數字格式輸入欄位
		電話(工廠)		FAC_TEL_NUM	rtnMap.FAC_TEL_NUM	數字格式輸入欄位
		電話-分機(工廠)	FAC_TEL_EXT	rtnMap.FAC_TEL_EXT	數字格式輸入欄位
	--%>
	$('FAC_ADDR').value = rtnMap.FAC_ADDR ? rtnMap.FAC_ADDR : "";
	$('FAC_TEL_AREA').value = rtnMap.FAC_TEL_AREA ? rtnMap.FAC_TEL_AREA : "";
	$('FAC_TEL_NUM').value = rtnMap.FAC_TEL_NUM ? rtnMap.FAC_TEL_NUM : "";
	$('FAC_TEL_EXT').value = rtnMap.FAC_TEL_EXT ? rtnMap.FAC_TEL_EXT : "";

	<%--
		登記資本額		CAPITAL	rtnMap.CAPITAL	數字格式輸入欄位
		實收資本額		REAL_CAPITAL	rtnMap.REAL_CAPITAL	數字格式輸入欄位
		主要業務及產品	PRODUCT	rtnMap.PRODUCT	文字輸入欄位，長度50
		主要銷售對象		MARKET	rtnMap.MARKET	文字輸入欄位，長度50
	--%>
	$('CAPITAL').value = rtnMap.CAPITAL ? CSRUtil.$fmt(rtnMap.CAPITAL,"#,###.###") : "0";
	$('REAL_CAPITAL').value = rtnMap.REAL_CAPITAL ? CSRUtil.$fmt(rtnMap.REAL_CAPITAL,"#,###.###") : "0";
	$('PRODUCT').value = rtnMap.PRODUCT ? rtnMap.PRODUCT : "";
	$('MARKET').value = rtnMap.MARKET ? rtnMap.MARKET : "";
	
	<%--
		銷售方式(內銷)	IN_SALE_RATE	rtnMap.IN_SALE_RATE	數字格式輸入欄位,
		無資料預設為0
		銷售方式(外銷)	OUT_SALE_RATE	rtnMap.OUT_SALE_RATE	數字格式輸入欄位,
		無資料預設為0
		產業別			TERRITORY	rtnMap.TERRITORY	文字輸入欄位，長度15
		受理進度			APPLY_PROCESS	rtnMap.APPLY_PROCESS	隱藏欄位
	--%>
	$('IN_SALE_RATE').value = rtnMap.IN_SALE_RATE ? rtnMap.IN_SALE_RATE : "0";
	$('OUT_SALE_RATE').value = rtnMap.OUT_SALE_RATE ? rtnMap.OUT_SALE_RATE : "0";
	$('TERRITORY').value = rtnMap.TERRITORY ? rtnMap.TERRITORY : "";
	$('APPLY_PROCESS').value = rtnMap.APPLY_PROCESS ? rtnMap.APPLY_PROCESS : "";

	<%--
		輸入人員ID
		(受理主檔)	A010_INPUT_ID	rtnMap.A010_INPUT_ID	隱藏欄位
		徵信人員ID	CRED_ID	rtnMap.CRED_ID	隱藏欄位
	--%>
	$('A010_INPUT_ID').value = rtnMap.A010_INPUT_ID ? rtnMap.A010_INPUT_ID : "";
	$('CRED_ID').value = rtnMap.CRED_ID ? rtnMap.CRED_ID : "";
	
	if(isCORP_DEPT){
		$w('IS_GROUP GROUP_NAME GROUP_LVL CRED_RATE STOCK_TYPE').each(function(id){
			if('IS_GROUP' == id){<%--radio--%>
				if(rtnMap[id] != undefined){
					selectRadioItem(id, rtnMap[id]);
				}else{
					unselectRadioItem('IS_GROUP');
				}
			}else{
				$(id).setValue(rtnMap[id] || ('STOCK_TYPE' == id && isDataNotFound ? 5 : ''));<%--[20200115]新增是否為查無資料判斷--%>
			}
		});
	}
	<%--[20191224]新增欄位(修改結束)--%>
	<%--[20200907]新增欄位()--%>
	$('GROUP_INVEST_AMT').setValue ( rtnMap.GROUP_INVEST_AMT ? rtnMap.GROUP_INVEST_AMT : "0");
	//[20200925]國家名稱
	var COUNTRY = rtnMap.COUNTRY || '';
	for(var i in COUNTRY_List){
		if(COUNTRY == COUNTRY_List[i]['COUNTRY']){
			COUNTRY_NM = COUNTRY_List[i]['COUNTRY_NM'];
		}
	}
	if(COUNTRY){
		$('COUNTRY_NM').setValue(COUNTRY_NM);
	}
	// 若國家名稱為中華民國時，則disable
	$('COUNTRY_INVEST_AMT').disabled = (COUNTRY == 'TW') ;
	$('COUNTRY_INVEST_AMT').setValue ( rtnMap.COUNTRY_INVEST_AMT ? rtnMap.COUNTRY_INVEST_AMT : "0");
	
	$('CREDIT_AMT').setValue ( rtnMap.CREDIT_AMT ? rtnMap.CREDIT_AMT : "");
	$('COUNTRY').setValue ( rtnMap.COUNTRY ? rtnMap.COUNTRY : "");
	$('CHECK_GROUP_NM').update ( rtnMap.CHECK_GROUP_NM ? rtnMap.CHECK_GROUP_NM : "");
	$('CHECK_COUNTRY_NM').update ( rtnMap.CHECK_COUNTRY_NM ? rtnMap.CHECK_COUNTRY_NM : "");
	if(isDataNotFound){
		<%--[20200907]查無資料需顯示預設值--%>
		$('OWNERSHIP').update (localeDisplay.formatNumber(resp.OWNERSHIP ? resp.OWNERSHIP : "0"));
	}else{
		$('OWNERSHIP').update (localeDisplay.formatNumber(rtnMap.OWNERSHIP ? rtnMap.OWNERSHIP : "0"));
	}
	
	<%--[20200907]新增欄位()--%>
	
}

<%--
	建構區塊E
--%>
function construct_BlockE(sectionE_map) {
	<%--
		輸入人員ID	INPUT_ID	rtnMap.INPUT_ID	顯示欄位
		輸入日期	INPUT_DATE	rtnMap.INPUT_DATE	顯示欄位
	--%>
	$('SHOW_INPUT_NAME').innerHTML = (sectionE_map.INPUT_NAME ? sectionE_map.INPUT_NAME : "");
	$('SHOW_INPUT_DATE').innerHTML = (sectionE_map.INPUT_DATE ? sectionE_map.INPUT_DATE : "");
}

<%--
==========================================================
=======================區塊 B程式操作======================
==========================================================
--%>

<%--
	Block B的新增
--%>
function insert_BlockB() {
	<%--
		7.5.1	新增一列資料於區塊B資料顯示的最後一列,畫面顯示欄位值如下
		7.5.2	新增按鈕改為儲存
		7.5.3	不必顯示訊息
		7.5.4	序號給值如下，其餘欄位空白
		序號	A031_SEQ_NO	DTDSA031vo.SEQ_NO(i)最大一筆+1	隱藏欄位
	--%>
	var newSeq = getNextSEQ_NO(LIST31,'A031_SEQ_NO');
	
	var classType = "tbYellow2";
	var targetRow = null ;
	var onlyDisplayOrNot = false ; //可修改
	var SEQ_NO = newSeq;
	var dataTable = $('block_B');
	
	var new_index = LIST31.length;
	LIST31[new_index] = {};
    //APPLY_ID    VARCHAR(11) NOT NULL
	LIST31[new_index]['A031_APPLY_ID'] = $('APPLY_ID').value;
    //SEQ_NO  DECIMAL(2)  NOT NULL
	LIST31[new_index]['A031_SEQ_NO'] = newSeq;
    //NAME    VARCHAR(60) 
	LIST31[new_index]['A031_NAME'] = null;
    //TITLE   VARCHAR(20) 
	LIST31[new_index]['A031_TITLE'] = null;
    //AGE DECIMAL(3)  
	LIST31[new_index]['A031_AGE'] = null;
    //DEGREE  VARCHAR(10) 
	LIST31[new_index]['A031_DEGREE'] = null;
    //SERV_YEAR   DECIMAL(3)  
	LIST31[new_index]['A031_SERV_YEAR'] = "0";
    //HOLD_RATE   DECIMAL(6,3)    
	LIST31[new_index]['A031_HOLD_RATE'] = "0";
    //EXPERIENCE  VARCHAR(100)
	LIST31[new_index]['A031_EXPERIENCE'] = null;
	
	content = getNewRow_BlockB(classType,LIST31[new_index],onlyDisplayOrNot,SEQ_NO);
	dataTable.insert({bottom : content});
	
	autoFormatToNumber();
	autoFormatToDate();
	<%-- [20240723] 難字調整，動態新增需呼叫parseEUDC --%>
	parseEUDC();
	PageUI.resize(true);
}

<%--
	區B 刪除
--%>
function delete_BlockB() {

	<%--
		9.	刪除(B區)(B0005)
		9.1	畫面程序檢核: 
		9.1.1	必須點選一筆資料，若未點選請顯示警示訊息:‘請選取一筆資料’
		9.2	讀取畫面欄位資料
		9.3	資料檢核: 無
		9.4	資料處理: 無
		9.5	畫面顯示: 
		9.5.1	移除畫面上區塊B資料顯示區所選取列的資料
		9.5.2	不必顯示訊息
	--%>
	if(radioListHaveSelectedOrNot('list_B') == false) {
		alert("請選取一筆資料");
		return;
	}
	
	removeOneRow("B");	
}

<%--
	由sequence取得List的index
--%>
function getTargetRowIndex(list,sequence,SEQ_NO_COLUMN_NAME) {
	if(list != null) {
		for(var mover=0; mover < list.length ;mover++)
		{
			var targetRow = list[mover];
			if(targetRow[SEQ_NO_COLUMN_NAME] == sequence) {
				return mover;
			}
		}
	}
	return -1;
}

<%--
	設定修改的值
--%>
function setOnBlurColumn_BlockB(sequence,columnName,value) {
	<%--設定span的值--%>
	$('SPAN_' + columnName + '_' + sequence).innerHTML = value;
	
	<%--設定list的值--%>
	var targetRowIndex = getTargetRowIndex(LIST31,sequence,"A031_SEQ_NO");
	LIST31[targetRowIndex][columnName] = value;
}

<%--
	設定修改的值
--%>
function setOnBlurColumnNumberType_BlockB(sequence,columnName,value) {
	<%--設定span的值--%>
	$('SPAN_' + columnName + '_' + sequence).innerHTML = value;

	<%--設定list的值--%>
	var value = $('INPUT_' + columnName + '_' + sequence).value.replace(/,/g,'');
	var targetRowIndex = getTargetRowIndex(LIST31,sequence,"A031_SEQ_NO");
	LIST31[targetRowIndex][columnName] = value;
}


<%--
	取得一個新ROW
	classType : CSS style
	targetRow : dataRow
	onlyDisplayOrNot : 是不是只顯示
	SEQ_NO : 填入序號
--%>
function getNewRow_BlockB(classType,targetRow,onlyDisplayOrNot,SEQ_NO) {
	function getOneColumn(	classType,
							targetRow,
							onlyDisplayOrNot,
							SEQ_NO,
							columnName,			
							size,
							maxLength,
							setValueFunction,
							dataType,
							pattern
						 ) 
	{
		var spanID =  ' id="' + 'SPAN_' + columnName + '_' + SEQ_NO + '" ';
		var inputID = ' id="' + 'INPUT_' + columnName + '_' + SEQ_NO + '"';
		var columnValue =(targetRow == null ? "" : getField(targetRow[columnName]) );

		var spanShowOrNot = (onlyDisplayOrNot ? '' : 'style="display: none"') ;
		var inputShowOrNot = (onlyDisplayOrNot ? 'style="display: none"' : '') ;
		var inputDataType = (dataType ? ' datatype="' + dataType +'"' : '');
		var inputPattern = (pattern ? ' pattern="' + pattern +'"' : '')
		var inputSetFunction = setValueFunction + '(\"' + SEQ_NO + '\",\"' + columnName + '\",this.value);';
		inputSetFunction = ' onblur=\'' + inputSetFunction + '\' ' ;
		
		var inputSizeAndMaxLength = ' size="' + size + '"' + ' maxlength="' + maxLength + '" ';
		var intpuValue = '" value="' + columnValue + '" ';
		
		<%-- [20240723]難字調整 --%>
		var inputEUDC = '';
		if ("A031_NAME" == columnName){
			inputEUDC = ' alt="ch" ' 
			if(spanShowOrNot.indexOf('style')!=-1){
				spanShowOrNot = spanShowOrNot.substr(0, spanShowOrNot.length -1) + '; font-family:\'EUDC\';"'
			}else{
				spanShowOrNot = 'style="font-family:\'EUDC\'"';
			}
		}

		return      '<td class="'+classType+'" >'
						+ '<span '
						+ spanID 
						+ spanShowOrNot
						+ '>'
						+ columnValue + '</span>' 
						
						+ '<input type="text" '
						+ inputID
						+ inputSizeAndMaxLength
						//+ inputSetFunction
						+ inputShowOrNot
						+ inputDataType
						+ inputPattern
						+ inputEUDC <%-- [20240723]難字調整 --%>
						+ ' value="' + columnValue + '" '
						+' />' 
					+'</td>'
		;
	}

	var TARGET_SEQ_NO = getField(SEQ_NO);
	
	var oneRow = "<tr align='center' >";
		<%--
			<td width="12%" class="tbBlue3" align="center" >
				 <input type="radio" name="ABCDE" >
			</td>
		--%>
	oneRow += '<td width="12%" class="'+classType+'" >'	
		   +    '<input type="radio" name="list_B" value="' + TARGET_SEQ_NO  
		   +    '" />' 
		   +'</td>';

		<%--
			姓名	A031_NAME		輸入欄位
			<td width="12%" class="tbBlue3" align="center" >
				 <span id="SPAN_A031_NAME"></span>
				 <input type="text" name="INPUT_A031_NAME" class="texttype1" size="12" value="">
			</td>
		--%>
	oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A031_NAME',"12","60",'setOnBlurColumn_BlockB',null,null);
	
		<%--
			職稱	A031_TITLE		輸入欄位
			<td width="12%" class="tbBlue3" align="center">
				 <input type="text" name="A031TITLE1" class=texttype1 size="12" value=>
			</td>
		--%>
	oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A031_TITLE',"12","20",'setOnBlurColumn_BlockB',null,null);
		
		<%--
			年齡	A031_AGE		輸入欄位
			<td width="8%" class="tbBlue3" align="center">
				 <input type="text" name="A031_AGE" class=texttype1 size="3" value=>
			</td>
		--%>
	oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A031_AGE',"12","3","setOnBlurColumnNumberType_BlockB","number","#,###.###");
	
		<%--
			學歷	A031_DEGREE		輸入欄位
			<td width="12%" class="tbBlue3" align="center">
				 <input type="text" name="A031_DEGREE" class=texttype1 size="12" value=>
			</td>
		--%>
	oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A031_DEGREE',"12","10",'setOnBlurColumn_BlockB',null,null);
	
		<%--
			服務年資	A031_SERV_YEAR		輸入欄位
			<td width="8%" class="tbBlue3" align="center">
				 <input type="text" name="A031_SERV_YEAR" class=texttype1 size="3" value=>
			</td>
		--%>
	oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A031_SERV_YEAR',"10","3","setOnBlurColumnNumberType_BlockB","number","#,###.###");
	
		<%--
			持股比例％	A031_HOLD_RATE		輸入欄位
			<td width="12%" class="tbBlue3" align="center">
				 <input type="text" name="A031_HOLD_RATE" class=texttype1 size="6" value=>
			</td>
		--%>
	oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A031_HOLD_RATE',"10","10","setOnBlurColumnNumberType_BlockB","number","#,###.###");
		
		<%--
			經歷	A031_EXPERIENCE		輸入欄位
			<td width="36%" class="tbBlue3" align="center">
				 <input type="text" name="A031_EXPERIENCE" class=texttype1 size="20" value=>
			</td>											  
		--%>
	oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A031_EXPERIENCE',"15","100",'setOnBlurColumn_BlockB',null,null);
	
	oneRow += '</tr>';

	return oneRow;
}

<%--
	依List建構區塊B資料
--%>
function constructRows_BlockB(dataList) {
		<%--
		
			7.5.1	新增一列資料於區塊B資料顯示的最後一列,畫面顯示欄位值如下
			7.5.2	新增按鈕改為儲存
			7.5.3	不必顯示訊息
			7.5.4	序號給值如下，其餘欄位空白
		--%>
		var dataTable = $('block_B');
		var le = dataTable.rows.length;
		for(i=le;i>0;i--){
			dataTable.deleteRow(0);
		}
		dataTable.insert({
			top:'<tr align="center" class="tbBlue" >'
				+ '<td width="9%">選取</td>'
				+ '<td width="9%">姓名</td>'
				+ '<td width="9%">職稱</td>'
				+ '<td width="9%">年齡</td>'
				+ '<td width="9%">學歷</td>'
				+ '<td width="8%">服務年資</td>'
				+ '<td width="9%">持股比例％</td>'
				+ '<td width="9%">經歷</td>'
				+ '</tr>'
		});
		
		if(dataList == false) {
			return ;
		}
		
		var content = "";
		var classType = "tbYellow2";
		var onlyDisplayOrNot = false;
		for(var mover=0; mover < dataList.length ; mover++) {
			var targetRow = dataList[mover];
			content += getNewRow_BlockB(classType,targetRow,onlyDisplayOrNot,targetRow['A031_SEQ_NO']);
		}
		dataTable.insert({bottom : content});
		<%-- [20240723] 難字調整，動態新增需呼叫parseEUDC --%>
		parseEUDC();
}



<%--
	==========================================================
	=======================區塊 C程式操作======================
	==========================================================
--%>

<%--
	Block C的新增
--%>
function insert_BlockC() {
	
	<%--
		11.5.1	新增一列資料於區塊C資料顯示的最後一列,畫面顯示欄位值如下
		11.5.2	新增按鈕改為儲存
		11.5.3	不必顯示訊息
		11.5.4	序號給值如下，其餘欄位空白
		
		選取			RADIO不出現
		序號	A032_SEQ_NO	DTDSA032vo.SEQ_NO(j)最大一筆+1	隱藏欄位
		事業名稱	A032_NAME		輸入欄位
		主要業務	A032_PRODUCT		輸入欄位
		統一編號	A032_ID		輸入欄位
		與關係企業關係	A032_RELATION	CORP_RELATION_LIST	下拉選單
		/*欄位代碼對照顯示中文:
		1:有控制與從屬關係
		2:相互投資關係
		3:董事長或總經理與他公司董事長或總經理為同一人或具有配偶關係 */
		實收資本額(萬)	A032_REAL_CAPITAL		輸入欄位
		轉投資金額(萬)	A032_REINVEST_AMT		輸入欄位
		持股比例％	A032_HOLD_RATE		輸入欄位
		
	--%>
	var newSeq = getNextSEQ_NO(LIST32,"A032_SEQ_NO");
	
	var classType = "tbYellow2";
	var targetRow = null ;
	var onlyDisplayOrNot = false ; //可修改
	var SEQ_NO = newSeq;
	var dataTable = $('block_C');
	
	var new_index = LIST32.length;
	LIST32[new_index] = {};
    //APPLY_ID    VARCHAR(11) NOT NULL
	LIST32[new_index]['A032_APPLY_ID'] = $('APPLY_ID').value;
    //SEQ_NO  DECIMAL(2)  NOT NULL
	LIST32[new_index]['A032_SEQ_NO'] = newSeq;
    //ID  VARCHAR(10) 
	LIST32[new_index]['A032_ID'] = null;
    //RELATION    VARCHAR(1)  
	LIST32[new_index]['A032_RELATION'] = null;
    //NAME    VARCHAR(60) 
	LIST32[new_index]['A032_NAME'] = null;
    //PRODUCT VARCHAR(100)    
	LIST32[new_index]['A032_PRODUCT'] = null;
    //REAL_CAPITAL    DECIMAL(14,2)   
	LIST32[new_index]['A032_REAL_CAPITAL'] = null;
    //REINVEST_AMT    DECIMAL(14,2)   
	LIST32[new_index]['A032_REINVEST_AMT'] = null;
    //HOLD_RATE   DECIMAL(6,3)                
	LIST32[new_index]['A032_HOLD_RATE'] = null;
	
	content = getNewRow_BlockC(classType,targetRow,onlyDisplayOrNot,SEQ_NO);
	dataTable.insert({bottom : content});
	
	autoFormatToNumber();
	autoFormatToDate();
	
	<%-- [20240723] 難字調整，動態新增需呼叫parseEUDC --%>
	parseEUDC();
	PageUI.resize(true);
}

<%--
	區C 刪除
--%>
function delete_BlockC() {

	<%--
		9.	刪除(B區)(B0005)
		9.1	畫面程序檢核: 
		9.1.1	必須點選一筆資料，若未點選請顯示警示訊息:‘請選取一筆資料’
		9.2	讀取畫面欄位資料
		9.3	資料檢核: 無
		9.4	資料處理: 無
		9.5	畫面顯示: 
		9.5.1	移除畫面上區塊B資料顯示區所選取列的資料
		9.5.2	不必顯示訊息
	--%>
	if(radioListHaveSelectedOrNot('list_C') == false) {
		alert("請選取一筆資料");
		return;
	}

	removeOneRow("C");	
}

<%--
	區塊C : 設定修改的值
--%>
function setOnBlurColumn_BlockC(sequence,columnName,value) {
	<%--設定span的值--%>
	$('SPAN_' + columnName + '_' + sequence).innerHTML = value;
	
	<%--設定list的值--%>
	var targetRowIndex = getTargetRowIndex(LIST32,sequence,"A032_SEQ_NO");
	LIST32[targetRowIndex][columnName] = value;
}

<%--
	區塊C : 設定修改的值
--%>
function setOnBlurColumnForSelect_BlockC(sequence,columnName,value) {

	<%--設定span的值--%>
	$('SPAN_' + columnName + '_' + sequence).innerHTML = getShowTextFromCORP_RELATION_LIST(value);
	
	<%--設定list的值--%>
	var targetRowIndex = getTargetRowIndex(LIST32,sequence,"A032_SEQ_NO");
	LIST32[targetRowIndex][columnName] = value;
}


<%--
	區塊C : 設定修改的值
--%>
function setOnBlurColumnNumberType_BlockC(sequence,columnName,value) {

	<%--設定span的值--%>
	$('SPAN_' + columnName + '_' + sequence).innerHTML = value;

	<%--設定list的值--%>
	var value = $('INPUT_' + columnName + '_' + sequence).value.replace(/,/g,'');
	var targetRowIndex = getTargetRowIndex(LIST32,sequence,"A032_SEQ_NO");
	LIST32[targetRowIndex][columnName] = value;
}


<%--
	區塊C : 	取得一個新ROW
	classType : CSS style
	targetRow : dataRow
	onlyDisplayOrNot : 是不是只顯示
	SEQ_NO : 填入序號
--%>
function getNewRow_BlockC(classType,targetRow,onlyDisplayOrNot,SEQ_NO) {

	function getOneColumn(	classType,
							targetRow,
							onlyDisplayOrNot,
							SEQ_NO,
							columnName,			
							rowspan,
							size,
							maxLength,
							setValueFunction,
							dataType,
							pattern
						 ) 
	{
		var columnValue =(targetRow == null ? "" : getField(targetRow[columnName]) );
		if(columnValue != "" && dataType == "number") {
			columnValue = CSRUtil.$fmt(columnValue,"#,###.###");
		}
		
		var spanID =  ' id="' + 'SPAN_' + columnName + '_' + SEQ_NO + '" ';
		var inputID = ' id="' + 'INPUT_' + columnName + '_' + SEQ_NO + '" ';
		
		var spanShowOrNot = (onlyDisplayOrNot ? '' : 'style="display: none"') ;
		var inputShowOrNot = (onlyDisplayOrNot ? 'style="display: none"' : '') ;
		var inputDataType = (dataType ? ' datatype="' + dataType +'"' : '');
		var inputPattern = (pattern ? ' pattern="' + pattern +'"' : '')
		var inputSetFunction = setValueFunction + '(\"' + SEQ_NO + '\",\"' + columnName + '\",this.value);';
		inputSetFunction = ' onblur=\'' + inputSetFunction + '\' ' ;
		
		var inputSizeAndMaxLength = ' size="' + size + '"' + ' maxlength="' + maxLength + '" ';
		
		return      '<td rowspan="' + rowspan +  ' class="'+classType+'" >'
					+ '<span ' 
					+ spanID 
					+ spanShowOrNot
					+ '>'
					+ columnValue 
					+ '</span>' 
					
					+ '<input type="text" ' 
					+ inputID 
					+ inputSizeAndMaxLength 
					+ ' value="' + columnValue + '" '
					//+ inputSetFunction 
					+ inputShowOrNot
					+ inputDataType
					+ inputPattern
					+'>' 
					+'</td>'
		;
	}
	
	var TARGET_SEQ_NO = getField(SEQ_NO);
	
	var oneRow = "<tr class='tbYellow2' align=center>";
				<%--
					<tr class='tbYellow2' align=center>											  
					  <td width="12%" rowspan="2" align="center" >
						 <input type="radio" name="CDE" >
					  </td>										  
				--%>
		oneRow += '<td width="12%" rowspan="2" class="'+classType+'" >'	;
		oneRow += '<input type="radio" name="list_C" value="' + TARGET_SEQ_NO + '"' ;
		oneRow += ' />' +'</td>';
		
				<%--
					     事業名稱	A032_NAME		輸入欄位
					  <td width="9%">
						<input type="text" name="A032_NAME" class="texttype1" size="20" >
					  </td>
				--%>
		oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,TARGET_SEQ_NO,'A032_NAME',"0","20","60","setOnBlurColumn_BlockC",null,null);

				<%--
					    主要業務	A032_PRODUCT	輸入欄位
					  <td width="20%">
						<input type="text" name="A032_PRODUCT" class="texttype1" size="20" >
					  </td>
				--%>
		oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,TARGET_SEQ_NO,'A032_PRODUCT',"0","20","100","setOnBlurColumn_BlockC",null,null);
				
				<%--
					    實收資本額(萬)	A032_REAL_CAPITAL		輸入欄位
					  <td width="9%" rowspan="2" >
						<input type="text" name="A032_REAL_CAPITAL" class="texttype1" size="6" >
					  </td>
				--%>
		oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,TARGET_SEQ_NO,'A032_REAL_CAPITAL',"2","14","20","setOnBlurColumnNumberType_BlockC","number","#,###.###");
			
				<%--
					   轉投資金額(萬)	A032_REINVEST_AMT		輸入欄位
					  <td width="8%" rowspan="2" >
						<input type="text" name="A032_REINVEST_AMT" class="texttype1" size="6" >
					  </td>
				--%>
		oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,TARGET_SEQ_NO,'A032_REINVEST_AMT',"2","14","12","setOnBlurColumnNumberType_BlockC","number","#,###.###");
			
				<%--
					   持股比例％	A032_HOLD_RATE		輸入欄位
					  <td width="9%" rowspan="2" >
						<input type="text" name="A032_HOLD_RATE" class="texttype1" size="6" value=>
					  </td>										  
				--%>
		oneRow += getOneColumn(classType,targetRow,onlyDisplayOrNot,TARGET_SEQ_NO,'A032_HOLD_RATE',"2","6","10","setOnBlurColumnNumberType_BlockC","number","#,###.###");
			
		oneRow += '</tr>';
			
			
			<%--
				統一編號	A032_ID			輸入欄位
				與關係企業關係	A032_RELATION	CORP_RELATION_LIST	下拉選單
				<tr class="tbYellow2" align=center>
				  <td width="30%" colspan="2" >
					<input type="text" name="A032_ID" class="texttype1" size="10" maxlength=10 value=>&nbsp;/&nbsp;
					<select name="A032_RELATION">
						<option value='A'>有控制與從屬關係</option>
						<option value='B'>相互投資關係</option>
						<option value='C'>董事長或總經理與他公司董事長或總經理為同一人或具有配偶關係</option>
					</select>
				  </td>
				</tr>										
			--%>
			
		var A032_ID = ( targetRow == null ? "" : getField(targetRow["A032_ID"]) );
		var A032_RELATION = ( targetRow == null ? "" :getField(targetRow["A032_RELATION"]) );
		var selectOnChangeFunction = 'setOnBlurColumnForSelect_BlockC(\"' + TARGET_SEQ_NO + '\", \"A032_RELATION\",this.value);'; 
		
		var spanShowOrNot = (onlyDisplayOrNot ? '' : 'style="display: none"') ;
		var inputShowOrNot = (onlyDisplayOrNot ? 'style="display: none"' : '') ;
		
		<%--
				getDefault_CORP_RELATION_LIST_Value 取得下拉預設值
				getDefault_CORP_RELATION_LIST_Text 取得下拉預設顯示文字
				
		--%>
		
		var spanForSelectText = null;
		if(A032_RELATION) {
			spanForSelectText = getShowTextFromCORP_RELATION_LIST(	A032_RELATION	);
		}else {
			spanForSelectText = getDefault_CORP_RELATION_LIST_Text();
		}

		var selectDefaultValue = null;
		if(A032_RELATION) {
			selectDefaultValue = A032_RELATION;
		}else {
			selectDefaultValue = getDefault_CORP_RELATION_LIST_Value();
		}
		
		oneRow += '<tr class="tbYellow2" align=center>'
					+ '<td colspan="2" >'
						+ '<span id="' + 'SPAN_A032_ID_' + TARGET_SEQ_NO  + '" ' 
						+ spanShowOrNot 
						+ '>' 
						+ A032_ID 
						+ '</span>' 
					
						+ '<input type="text" ID="' 
						+ 'INPUT_A032_ID_' + TARGET_SEQ_NO + '"'
						+  ' value="' + A032_ID + '" '
						+ inputShowOrNot
						+ ' onblur=\'setOnBlurColumn_BlockC(\"' + TARGET_SEQ_NO + '\",\"A032_ID\",this.value);\' ' 
						+ '>' 
						+ '&nbsp;/&nbsp;<br>'
						
						+ '<span id="' + "SPAN_A032_RELATION" + '_' + TARGET_SEQ_NO  + '" ' 
						+ spanShowOrNot
						+ '>' 
						+ spanForSelectText
						+ '</span>' 
						+ getCORP_RELATION_LIST('INPUT_A032_RELATION_' + TARGET_SEQ_NO , onlyDisplayOrNot, selectOnChangeFunction,selectDefaultValue);
					+ '</td>'
			+ '</tr>' ;
		return oneRow;
}

<%--
	依List建構區塊C資料
--%>
function constructRows_BlockC(dataList) {
		<%--
			<tr class="tbBlue" align=center>											  
			  <td width="3%" rowspan="2" >選取</td>
			  <td width="20%">事業名稱</td>
			  <td width="20%">主要業務</td>
			  <td width="15%" rowspan="2" >實收資本額（萬）</td>
			  <td width="15%" rowspan="2" >轉投資金額（萬）</td>
			  <td width="15%" rowspan="2" >持股比例％</td>										  
			</tr>
			<tr class="tbBlue" align=center>
			  <td width="9%" colspan="2" >統一編號/與關係企業關係</td>
			</tr>
		--%>
		var dataTable = $('block_C');
		var le = dataTable.rows.length;
		for(i=le;i>0;i--){
			dataTable.deleteRow(0);
		}
		dataTable.insert({
			top:'<tr class="tbBlue" align=center>'
				+ '<td width="3%" rowspan="2" >選取</td>'
				+ '<td width="20%">事業名稱</td>'
				+ '<td width="20%">主要業務</td>'
				+ '<td width="15%" rowspan="2" >實收資本額（萬）</td>'
				+ '<td width="15%" rowspan="2" >轉投資金額（萬）</td>'
				+ '<td width="15%" rowspan="2" >持股比例％</td>'
				+ '</tr>'
				+ '<tr class="tbBlue" align=center>'
				+ '<td width="9%" colspan="2" >統一編號/與關係企業關係</td>'
				+ '</tr>'
				+ '</tr>'
		});
		
		if(dataList == false) {
			return ;
		}
		
		var content = "";
		var classType = "tbYellow2";
		var onlyDisplayOrNot = false;
		for(var mover=0; mover < dataList.length ; mover++) {
			var targetRow = dataList[mover];
			content += getNewRow_BlockC(classType,targetRow,onlyDisplayOrNot,targetRow['A032_SEQ_NO']);
		}
		dataTable.insert({bottom : content});
		fix();
		autoFormatToNumber();
		autoFormatToDate();
}


<%--
	==========================================================
	=======================區塊 D程式操作======================
	==========================================================
--%>

<%--
	Block D的新增
--%>
function insert_BlockD() {
	
	<%--
		15.5.1	新增一列資料於區塊D資料顯示的最後一列,畫面顯示欄位值如下
		15.5.2	新增按鈕改為儲存
		15.5.3	不必顯示訊息
		15.5.4	序號、資料類別及營利事業統一編號給值如下，其餘欄位空白
		
		選取			RADIO不出現
		序號	A023_SEQ_NO	DTDSA023vo.SEQ_NO(k)最大一筆+1	隱藏欄位
		資料類別	A023_TYPE	=‘2’ 	隱藏欄位
		營利事業統一編號	A023_ID	= A區的ID	隱藏欄位
		座落所在地	A023_ADDRESS		輸入欄位
		建物門牌	A023_BUILD_DOOR		輸入欄位
		地號(一)	A023_LAND_NO1		輸入欄位
		地號(二)	A023_LAND_NO2		輸入欄位
		建號(一)	A023_BUILD_NO1		輸入欄位
		建號(二)	A023_BUILD_NO2		輸入欄位
		使用情形	A023_USE_STATUS	LAND_USE_STS_LIST	下拉選單
		欄位代碼對照顯示中文:
			1:自用 	2:出租
			3:空屋      4:借住 
		設定情形-行庫	A023_SET_BANK		輸入欄位
		設定情形-金額	A023_SET_AMT		輸入欄位
	--%>
	
	var newSeq = getNextSEQ_NO(LIST23,'A023_SEQ_NO');
	
	var classType = "tbYellow2";
	var targetRow = null ;
	var onlyDisplayOrNot = false ; //可修改
	var SEQ_NO = newSeq;
	var dataTable = $('block_D');
	
	var new_index = LIST23.length;
	LIST23[new_index] = {};
    //APPLY_ID    VARCHAR(11) NOT NULL
	LIST23[new_index]['A023_APPLY_ID'] = $('APPLY_ID').value;
    //TYPE    VARCHAR(1)  NOT NULL
	LIST23[new_index]['A023_TYPE'] = '2';
    //ID  VARCHAR(10) NOT NULL
	LIST23[new_index]['A023_ID'] = sectionA_map["A023_ID"];
    //SEQ_NO  DECIMAL(2)  NOT NULL
	LIST23[new_index]['A023_SEQ_NO'] = newSeq;
    //ADDRESS VARCHAR(80) 
	LIST23[new_index]['A023_ADDRESS'] = null;
    //LAND_NO1    VARCHAR(4)  
	LIST23[new_index]['A023_LAND_NO1'] = null;
    //LAND_NO2    VARCHAR(4)  
	LIST23[new_index]['A023_LAND_NO2'] = null;
    //BUILD_DOOR  VARCHAR(60) 
	LIST23[new_index]['A023_BUILD_DOOR'] = null;
    //BUILD_NO1   VARCHAR(5)  
	LIST23[new_index]['A023_BUILD_NO1'] = null;
    //BUILD_NO2   VARCHAR(3)  
	LIST23[new_index]['A023_BUILD_NO2'] = null;
    //USE_STATUS  VARCHAR(1)  
	LIST23[new_index]['A023_USE_STATUS'] = null;
    //SET_BANK    VARCHAR(12) 
	LIST23[new_index]['A023_SET_BANK'] = null;
    //SET_AMT DECIMAL(10)             	
	LIST23[new_index]['A023_SET_AMT'] = null;
	
	content = getNewRow_BlockD(classType,targetRow,onlyDisplayOrNot,SEQ_NO);
	dataTable.insert({bottom : content});
	
	autoFormatToNumber();
	autoFormatToDate();
	
	<%-- [20240723] 難字調整，動態新增需呼叫parseEUDC --%>
	parseEUDC();
	PageUI.resize(true);
}

<%--
	區D 刪除
--%>
function delete_BlockD() {

	<%--
		17.	刪除(D區)(B0005)
		17.1	畫面程序檢核:
		17.1.1	必須點選一筆資料，若未點選請顯示警示訊息:‘請選取一筆資料’
		17.2	讀取畫面欄位資料
		17.3	資料檢核: 無
		17.4	資料處理: 無
		17.5	畫面顯示: 
		17.5.1	移除畫面上區塊D資料顯示區所選取列的資料
		17.5.2	不必顯示訊息
	--%>
	if( radioListHaveSelectedOrNot('list_D') == false) {
		alert("請選取一筆資料");
		return;
	}
	
	removeOneRow("D");	
}


<%--
	區塊D : 設定修改的值
--%>
function setOnBlurColumn_BlockD(sequence,columnName,value) {
	<%--設定span的值--%>
	$('SPAN_' + columnName + '_' + sequence).innerHTML = value;
	
	<%--設定list的值--%>
	var targetRowIndex = getTargetRowIndex(LIST23,sequence,"A023_SEQ_NO");
	LIST23[targetRowIndex][columnName] = value;
}

<%--
	區塊D : 設定修改的值
--%>
function setOnBlurColumnNumberType_BlockD(sequence,columnName,value) {

	<%--設定span的值--%>
	$('SPAN_' + columnName + '_' + sequence).innerHTML = value;

	<%--設定list的值--%>
	var targetRowIndex = getTargetRowIndex(LIST23,sequence,"A023_SEQ_NO");
	LIST23[targetRowIndex][columnName] = value;
}

<%--
	區塊d : 設定修改的值
--%>
function setOnBlurColumnForSelect_BlockD(sequence,columnName,value) {

	<%--設定span的值--%>
	$('SPAN_' + columnName + '_' + sequence).innerHTML = getLAND_USE_STS_LIST(value);

	<%--設定list的值--%>
	var targetRowIndex = getTargetRowIndex(LIST23,sequence,"A023_SEQ_NO");
	LIST23[targetRowIndex][columnName] = value;
}

<%--
	取得一個新ROW
	classType : CSS style
	targetRow : dataRow
	onlyDisplayOrNot : 是不是只顯示
	SEQ_NO : 填入序號
--%>
function getNewRow_BlockD(classType,targetRow,onlyDisplayOrNot,SEQ_NO) {

	function getOneColumn(	classType,
							targetRow,
							onlyDisplayOrNot,
							SEQ_NO,
							columnName,			
							rowspan,
							size,
							maxLength,
							setValueFunction,
							dataType,
							pattern
						 ) 
	{
		var spanID =  ' id="' + 'SPAN_' + columnName + '_' + SEQ_NO + '" ';
		var inputID = ' id="' + 'INPUT_' + columnName + '_' + SEQ_NO + '"';
	
		var columnValue =(targetRow == null ? "" : getField(targetRow[columnName]) );
		if(columnValue != "" && dataType == "number") {
			columnValue = CSRUtil.$fmt(columnValue, pattern||"#,###.###");
		}
		
		var spanShowOrNot = (onlyDisplayOrNot ? '' : 'style="display: none"') ;
		var inputShowOrNot = (onlyDisplayOrNot ? 'style="display: none"' : '') ;
		var inputDataType = (dataType ? ' datatype="' + dataType +'"' : '');
		var inputPattern = (pattern ? ' pattern="' + pattern +'"' : '')
		var inputSetFunction = setValueFunction + '(\"' + SEQ_NO + '\",\"' + columnName + '\",this.value);';
		inputSetFunction = ' onblur=\'' + inputSetFunction + '\' ' ;
		
		var inputSizeAndMaxLength = ' size="' + size + '"' + ' maxlength="' + maxLength + '" ';
		var intpuValue = '" value="' + columnValue + '" ';
		
		<%-- [20240723]難字調整 --%>
		var inputEUDC = '';
		if ("A023_ADDRESS" == columnName){
			inputEUDC = ' alt="ch" ' 
			if(spanShowOrNot.indexOf('style')!=-1){
				spanShowOrNot = spanShowOrNot.substr(0, spanShowOrNot.length -1) + '; font-family:\'EUDC\';"'
			}else{
				spanShowOrNot = 'style="font-family:\'EUDC\'"';
			}
		}
		
		return      '<span ' 
					+ spanID 
					+ spanShowOrNot 
					+ '>' 
					+ columnValue 
					+ '</span>' 
					
					+ '<input type="text" ' 
					+ intpuValue
					+ inputID 
					+ inputSizeAndMaxLength 
					//+ inputSetFunction
					+ inputShowOrNot
					+ inputDataType
					+ inputPattern
					+ inputEUDC <%-- [20240723]難字調整 --%>
					+'>' ;
	}
	
		var TARGET_SEQ_NO = getField(SEQ_NO);
	
		var oneRow = "<tr class='tbYellow2' align=center>";
			<%--
				<tr class='tbYellow2' align=center>											  
				  <td width="12%" rowspan="2" align="center" >
					 <input type="radio" name="CDE" >
				  </td>										  
			--%>
		oneRow += '<td width="2%" rowspan="2" class="'+classType+'" >'		
					+    '<input type="radio" name="list_D" value="' + TARGET_SEQ_NO  
					+    '" />' 
				  +'</td>';
			<%--
				  <td>
				     	座落所在地	A023_ADDRESS		輸入欄位
						<input type="text" size="59" name="A023_ADDRESS" class="texttype1" >
				  </td>
			--%>
		oneRow += "<td>" 
				  + getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A023_ADDRESS',"0","30","80","setOnBlurColumn_BlockD",null,null)
				  + "</td>";
			<%--
				  <td>
						地號(一)	A023_LAND_NO1		輸入欄位
						地號(二)	A023_LAND_NO2		輸入欄位
						<input type="text" size="5" name="A023_LAND_NO1" class="texttype1" >－
						<input type="text" size="5" name="A023_LAND_NO2" class="texttype1" >
			      </td>
			--%>
		oneRow += "<td>" 
				  + getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A023_LAND_NO1',null,"4","4","setOnBlurColumn_BlockD",null,null)
				  + "－"
				  + getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A023_LAND_NO2',null,"4","4","setOnBlurColumn_BlockD",null,null)
				  + "</td>";
			
		<%--
				使用情形	A023_USE_STATUS	LAND_USE_STS_LIST	下拉選單
				/*欄位代碼對照顯示中文:
				1:自用
				2:出租
				3:空屋
				4:借住 
				*/
			  <td>
					<select name="A023_USE_STATUS">
						<option value='0'>自用</option>
						<option value='1'>出租</option>
						<option value='2'>空屋</option>
						<option value='3'>借住</option>
					</select>
			  </td>
		--%>
		var A023_USE_STATUS = (targetRow == null ? "" :getField(targetRow["A023_USE_STATUS"]) );
		var selectOnChangeFunction = 'setOnBlurColumnForSelect_BlockD(\"' + TARGET_SEQ_NO + '\", \"A023_USE_STATUS\",this.value);'; 

		<%--
			getDefault_LAND_USE_STS_LIST_Value	取得下拉預設值
			getDefault_LAND_USE_STS_LIST_Text	取得下拉預設顯示文字
		--%>
		var spanForSelectText = null;
		if(A023_USE_STATUS) {
			spanForSelectText = getShowTextFromLAND_USE_STS_LIST(	A023_USE_STATUS	);
		}else {
			spanForSelectText = getDefault_LAND_USE_STS_LIST_Text();
		}
		
		var selectDefaultValue = null;
		if(A023_USE_STATUS) {
			selectDefaultValue = A023_USE_STATUS;
		}else {
			selectDefaultValue = getDefault_LAND_USE_STS_LIST_Value();
		}


		oneRow  += "<td>"
				+ '<span id="' + 'SPAN_' + "A023_USE_STATUS" + '_' + TARGET_SEQ_NO  + '" ' 
				+ (onlyDisplayOrNot ? '' : 'style="display: none"') 
				+ '>' 
				+ spanForSelectText
				+ '</span>' 
				+ getLAND_USE_STS_LIST('INPUT_A023_USE_STATUS_' + TARGET_SEQ_NO , onlyDisplayOrNot, selectOnChangeFunction,A023_USE_STATUS)
			    + "</td>";
				  
		oneRow += '</tr>';
		
		oneRow += '<tr class="tbYellow2" align=center>';

		<%--
			建物門牌	A023_BUILD_DOOR		輸入欄位
			<td>
				<input type="text" size="59" name="A023_BUILD_DOOR" class="texttype1" >
		  </td>
		--%>
		oneRow += "<td>"
				  + getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A023_BUILD_DOOR',null,"30","60","setOnBlurColumn_BlockD",null,null)
				  + "</td>";
		
		<%--
				建號(一)	A023_BUILD_NO1		輸入欄位
				建號(二)	A023_BUILD_NO2		輸入欄位
			  <td>
				<input type="text" size="6" name="A023_BUILD_NO1" class="texttype1" >－
				<input type="text" size="6" name="A023_BUILD_NO2" class="texttype1" >
			  </td>
		--%>
		oneRow += "<td>" 
				  + getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A023_BUILD_NO1',null,"5","5","setOnBlurColumn_BlockD",null,null)
				  + "－"
				  + getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A023_BUILD_NO2',null,"3","3","setOnBlurColumn_BlockD",null,null)
				  + "</td>";
			
		<%--
			<tr class="tbYellow2" align=center>
				設定情形-行庫	A023_SET_BANK		輸入欄位
				設定情形-金額	A023_SET_AMT		輸入欄位
			  <td>
				行庫<input type="text" size="12" name="A023_SET_BANK" class="texttype1" >
				金額<input type="text" size="7" name="A023_SET_AMT" class="texttype1" >萬
			  </td>
			</tr>
		--%>
		oneRow += "<td>" 
				  + "行庫 "
				  + getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A023_SET_BANK',null,"12","12","setOnBlurColumn_BlockD",null,null)
				  + " 金額 "
				  + getOneColumn(classType,targetRow,onlyDisplayOrNot,SEQ_NO,'A023_SET_AMT',null,"15","15","setOnBlurColumnNumberType_BlockD","number","#,###.###")
				  + "萬"
				  + "</td>";
		oneRow += '</tr>';
		
		return oneRow;
}


<%--
	依List建構區塊D資料
--%>
function constructRows_BlockD(dataList) {
		var dataTable = $('block_D');
		var le = dataTable.rows.length;
		for(i=le;i>0;i--){
			dataTable.deleteRow(0);
		}
		dataTable.insert({
			top:'<tr class="tbBlue" align=center>'
					+ '<td width="3%" rowspan="2">選取</td>'
					+ '<td width="35%">座落所在地</td>'
					+ '<td width="15%">地號</td>'
					+ '<td width="42%" >使用情形</td>'
				+ '</tr>'
				+ '<tr class="tbBlue" align=center>'
					+ '<td  >建物門牌</td>'
					+ '<td  >建號</td>'
					+ '<td  >設定情形</td>'
				+ '</tr>'
		});
		
		if(dataList == false) {
			return ;
		}
		
		var content = "";
		var classType = "tbYellow2";
		var onlyDisplayOrNot = false;
		for(var mover=0; mover < dataList.length ; mover++) {
			var targetRow = dataList[mover];
			content += getNewRow_BlockD(classType,targetRow,onlyDisplayOrNot,targetRow['A023_SEQ_NO']);
		}
		dataTable.insert({bottom : content});
}
<%--[20191224]
	==========================================================
	=======================區塊 F程式操作======================
	==========================================================
--%>
var actions = {
	<%--Block F的新增--%>
	insert_BlockF : function(blockType) {
		var emptyA035Map = {};
		$w('SOURCE_ID ID_TYPE NAME ID LEVEL HOLDING_RATIO IS_BO ID_TYPE_NM').each(function(key){
			emptyA035Map[key] = '';
		});
		if('blockF_1' == blockType){
			emptyA035Map['SOURCE_ID'] = '';
			emptyA035Map['LEVEL'] = '1';
			LISTA035_1.push(emptyA035Map);
			actions.constructRows_BlockF(LISTA035_1, blockType);
		}else if('blockF_2' == blockType){
			emptyA035Map['LEVEL'] = '2';
			LISTA035_2.push(emptyA035Map);
			actions.constructRows_BlockF(LISTA035_2, blockType);
		}else if('blockF_3' == blockType){
			emptyA035Map['LEVEL'] = '3';
			LISTA035_3.push(emptyA035Map);
			actions.constructRows_BlockF(LISTA035_3, blockType);
		}else if('blockF_4' == blockType){
			emptyA035Map['LEVEL'] = '4';
			LISTA035_4.push(emptyA035Map);
			actions.constructRows_BlockF(LISTA035_4, blockType);
		}else if('blockF_5' == blockType){
			emptyA035Map['LEVEL'] = '5';
			LISTA035_5.push(emptyA035Map);
			actions.constructRows_BlockF(LISTA035_5, blockType);
		}else if('blockF_6' == blockType){
			emptyA035Map['LEVEL'] = 'L';
			LISTA035_L.push(emptyA035Map);
			actions.constructRows_BlockF(LISTA035_L, blockType);
		}
		autoFormatToNumber();
		autoFormatToDate();
		
		<%-- [20240723] 難字調整，動態新增需呼叫parseEUDC --%>
		parseEUDC();
	},
	<%--區F 刪除--%>
	delete_BlockF : function(blockType) {
		var blockTypeMap = {
			'blockF_1' : 'ListA035_1',
			'blockF_2' : 'ListA035_2',
			'blockF_3' : 'ListA035_3',
			'blockF_4' : 'ListA035_4',
			'blockF_5' : 'ListA035_5',
			'blockF_6' : 'ListA035_L',
		};
		if(radioListHaveSelectedOrNot(blockTypeMap[blockType]) == false) {
			alert("請選取一筆資料");
			return;
		}
		removeOneRow(blockType);	
	},
	<%--區塊F : 	取得一個新ROW--%>
	getNewRow_BlockF : function(classType,targetRow,onlyDisplayOrNot,SEQ_NO, blockType) {

		function getOneColumn(	classType,
								targetRow,
								onlyDisplayOrNot,
								SEQ_NO,
								columnName,			
								rowspan,
								size,
								maxLength,
								setValueFunction,
								dataType,
								pattern
							 ) 
		{
			var columnValue =(targetRow == null ? "" : getField(targetRow[columnName]) );
			if(columnValue != "" && dataType == "number") {
				columnValue = CSRUtil.$fmt(columnValue,pattern || "#0.0");
			}
			
			var spanID =  'SPAN_' + columnName + '_' + SEQ_NO;
			var inputID = 'INPUT_' + columnName + '_' + SEQ_NO;
	
			var td = new Element('td', {
				'rowspan' : rowspan,
				'class' : classType
			});
			var span = new Element('span', {'id' : spanID, 'style' : onlyDisplayOrNot ? '' : 'display:none'}).update(columnValue);
			var input = new Element('input', {
				'id' : inputID,
				'name' : inputID,
				'class' : 'textBox2',
				'style' : onlyDisplayOrNot ? 'display:none' : '',
				'pattern' : pattern ? pattern : '',
				'dataType' : dataType ? dataType : '',
				'size' : size ? size : '',
				'maxlength' : maxLength ? maxLength : ''
			}).setValue(columnValue);
			
			<%--[20240723]難字調整 --%>
			if('NAME' == columnName){
				span.setStyle({"font-family": "'EUDC'"});				
				input.setAttribute('alt','ch');
			}
			
			if(setValueFunction){
				input.observe('blur', function(){
					var tmpArray = $(this).id.split('_');
					var index = tmpArray[tmpArray.length-1];
					var value = pattern ? CSRUtil.$fmt($F(this),pattern) : $F(this);
					$(this).setValue(value);<%--[20200116]格式化資料--%>
					if('blockF_1' == blockType){
						LISTA035_1[index][columnName] = value;
					}else if('blockF_2' == blockType){
						LISTA035_2[index][columnName] = value;
					}else if('blockF_3' == blockType){
						LISTA035_3[index][columnName] = value;
					}else if('blockF_4' == blockType){
						LISTA035_4[index][columnName] = value;
					}else if('blockF_5' == blockType){
						LISTA035_5[index][columnName] = value;
					}else if('blockF_6' == blockType){
						if('IS_BO'==columnName){
							LISTA035_L[index][columnName] = value||'0';						
						}else{
							LISTA035_L[index][columnName] = value;
						}
					}
				});
			}
			td.insert(span);
			td.insert(input);
			
			return td;
		}
		
		var TARGET_SEQ_NO = getField(SEQ_NO);
		
		<%--人別下拉選單--%>
		var selectID = 'SELECT_ID_TYPE_' + SEQ_NO;
		var dropDownElement_ID_TYPE = new Element('select', {'id' : selectID, 'name' : selectID});
		<c:forEach var="map" items="${A035_ID_TYPE_LIST}">
		dropDownElement_ID_TYPE.insert(new Option('${map.value}', '${map.key}'));
		</c:forEach>
		dropDownElement_ID_TYPE.observe('change', function(){
			var tmpArray = $(this).id.split('_');
			var index = tmpArray[tmpArray.length-1];
			var ID_TYPE = $F(this);
			var ID_TYPE_NM = $(this).options[$(this).selectedIndex].text;
			if('blockF_1' == blockType){
				LISTA035_1[index]['ID_TYPE'] = ID_TYPE;
				LISTA035_1[index]['ID_TYPE_NM'] = ID_TYPE_NM;
			}else if('blockF_2' == blockType){
				LISTA035_2[index]['ID_TYPE'] = ID_TYPE;
				LISTA035_2[index]['ID_TYPE_NM'] = ID_TYPE_NM;
			}else if('blockF_3' == blockType){
				LISTA035_3[index]['ID_TYPE'] = ID_TYPE;
				LISTA035_3[index]['ID_TYPE_NM'] = ID_TYPE_NM;
			}else if('blockF_4' == blockType){
				LISTA035_4[index]['ID_TYPE'] = ID_TYPE;
				LISTA035_4[index]['ID_TYPE_NM'] = ID_TYPE_NM;
			}else if('blockF_5' == blockType){
				LISTA035_5[index]['ID_TYPE'] = ID_TYPE;
				LISTA035_5[index]['ID_TYPE_NM'] = ID_TYPE_NM;
			}else if('blockF_6' == blockType){
				LISTA035_L[index]['ID_TYPE'] = ID_TYPE;
				LISTA035_L[index]['ID_TYPE_NM'] = ID_TYPE_NM;
			}
		});
		var ID_TYPEvalue = targetRow['ID_TYPE'];
		if(ID_TYPEvalue){
			dropDownElement_ID_TYPE.setValue(ID_TYPEvalue);
		}
		dropDownElement_ID_TYPE.simulate('change');
		
		<%--實質受益人--%>
		var checkBoxID = 'CHECKBOX_IS_BO_' + SEQ_NO;
		var checkBox_IS_BO = new Element('input', {'type' : 'checkbox', 'id' : checkBoxID , 'name' : checkBoxID , 'value' : 1});
		if(targetRow['IS_BO'] == 1){
			checkBox_IS_BO.checked = true;
		}
		checkBox_IS_BO.observe('click', function(){
			var tmpArray = $(this).id.split('_');
			var index = tmpArray[tmpArray.length-1];
			LISTA035_L[index]['IS_BO'] = $(this).checked ? $F(this) : '0';
		});
		
		var tableShow;
		var radioName;
		if('blockF_1' == blockType){
			radioName = 'ListA035_1';
			tableShow = 'ID_TYPE NAME ID HOLDING_RATIO';
		}else if('blockF_2' == blockType){
			radioName = 'ListA035_2';
			tableShow = 'SOURCE_ID ID_TYPE NAME ID HOLDING_RATIO';
		}else if('blockF_3' == blockType){
			radioName = 'ListA035_3';
			tableShow = 'SOURCE_ID ID_TYPE NAME ID HOLDING_RATIO';
		}else if('blockF_4' == blockType){
			radioName = 'ListA035_4';
			tableShow = 'SOURCE_ID ID_TYPE NAME ID HOLDING_RATIO';
		}else if('blockF_5' == blockType){
			radioName = 'ListA035_5';
			tableShow = 'SOURCE_ID ID_TYPE NAME ID HOLDING_RATIO';
		}else if('blockF_6' == blockType){
			radioName = 'ListA035_L';
			tableShow = 'NAME ID_TYPE ID HOLDING_RATIO IS_BO';
		}
		
		var oneRow = new Element('tr', {'class' : 'tbYellow2', 'style' : 'text-align:center'});
		var TARGET_SEQ_NOsplit = TARGET_SEQ_NO.split('_');
		var radioIndex = TARGET_SEQ_NOsplit[TARGET_SEQ_NOsplit.length-1];
		oneRow.insert(new Element('td', {'class' : classType}).insert(new Element('input', {'type' : 'radio', 'name' : radioName, 'value' : radioIndex})));<%--選取--%>
		var isBlockF6 = 'blockF_6' == blockType;
		$w(tableShow).each(function(key){
			if(key == 'ID_TYPE'){
				oneRow.insert(new Element('td').insert(dropDownElement_ID_TYPE));
			}else if(key == 'HOLDING_RATIO'){
				oneRow.insert(getOneColumn(classType, targetRow, false, SEQ_NO, 'HOLDING_RATIO', "1", "6", "6", true, "number", '##.#'));
			}else if(key == 'IS_BO'){
				oneRow.insert(new Element('td').insert(checkBox_IS_BO));
			}else  if(key == 'NAME'){
				oneRow.insert(getOneColumn(classType, targetRow, false, SEQ_NO, 'NAME', "1", "50", "100", true, null, null));
			}else{
				oneRow.insert(getOneColumn(classType, targetRow, false, SEQ_NO, key, "1", "15", "", true, null, null));
			}
		});
	
		return oneRow;
	},
	<%--依List建構區塊F資料--%>
	constructRows_BlockF : function(dataList, blockType) {
		var dataTable = $(blockType);
		var le = dataTable.rows.length;
		for(i=le;i>0;i--){
			dataTable.deleteRow(0);
		}
		var tr = new Element('tr',{'class' : 'tbBlue', 'style' : 'text-align:center'});
		var widths;
		if('blockF_1' == blockType){
			widths = [5,10,50,20,15];
			$w('選取 人別 姓名 ID 持股比例%').each(function(text, sn){
				tr.insert(new Element('td', {'style' : 'width:' + widths[sn] + '%'}).update(text));
			});
		}else if('blockF_2' == blockType || 'blockF_3' == blockType || 'blockF_4' == blockType || 'blockF_5' == blockType){
			var tmpArray = blockType.split('_');
			var previousLevel = tmpArray[tmpArray.length - 1] -1 ;
			widths = [5,15,10,40,15,15];
			$w('選取 第'+previousLevel+'層股東ID 人別 姓名 ID 持股比例%').each(function(text, sn){
				tr.insert(new Element('td', {'style' : 'width:' + widths[sn] + '%'}).update(text));
			});
		}else if('blockF_6' == blockType){
			widths = [5,40,10,15,15,15];
			$w('選取 姓名 人別 ID 持股比例% 實質受益人').each(function(text, sn){
				tr.insert(new Element('td', {'style' : 'width:' + widths[sn] + '%'}).update(text));
			});
		}
		dataTable.insert({top : tr});
		
		if(dataList == false) {<%--如果list是空的--%>
			return ;
		}
		
		var content = "";
		var classType = "tbYellow2";
		var onlyDisplayOrNot = false;
		for(var mover=0; mover < dataList.length ; mover++) {
			dataTable.insert({bottom : actions.getNewRow_BlockF(classType,dataList[mover],onlyDisplayOrNot, blockType+ '_' + mover, blockType)});
		}
		
		if('blockF_6' == blockType){
			actions.blockFControl($('FILE_NAME').text ? true : false);<%--[20200116]新增 FILE_NAME連動 設定區域disabel 或enable--%>
		}
	},
	<%--建構F區塊--%>
	construct_BlockF : function(resp) {
		actions.setFILE_MAPData(resp.FILE_MAP || {});
		
		LISTA035_1 = (resp.A035_1 || []);
		LISTA035_2 = (resp.A035_2 || []);
		LISTA035_3 = (resp.A035_3 || []);
		LISTA035_4 = (resp.A035_4 || []);
		LISTA035_5 = (resp.A035_5 || []);
		LISTA035_L = (resp.A035_L || []);
		actions.constructRows_BlockF(LISTA035_1, 'blockF_1');
		actions.constructRows_BlockF(LISTA035_2, 'blockF_2');
		actions.constructRows_BlockF(LISTA035_3, 'blockF_3');
		actions.constructRows_BlockF(LISTA035_4, 'blockF_4');
		actions.constructRows_BlockF(LISTA035_5, 'blockF_5');
		actions.constructRows_BlockF(LISTA035_L, 'blockF_6');
	},
	<%--法金件顯示欄位控制--%>
	controlIsCORP_DEPT : function(){
		$$('.isCORP_DEPT').each(function(id){
			if(isCORP_DEPT){
				$(id).show();
			}else{
				$(id).hide();
			}
		});
	},
	<%--IS_GROUP連動--%>
	setSomeDefaultFromIS_GROUP : function(){
		<%--取得option value是99 的那筆資料 以利後續被刪掉後補回--%>
		var value99;
		<c:forEach var="map" items="${GROUP_LEVEL_LIST}">
		<c:if test='${map.key eq "99"}'>
		value99 = new Element('option',{'value': '${map.key}'}).update('${map.value}');
		</c:if>
		</c:forEach>
		var radioElement = getSelectRadioItem('IS_GROUP');
		$w('GROUP_NAME GROUP_LVL CRED_RATE').each(function(id){
			$(id).disabled = false;
		});
		if(radioElement == null){
			return;
		}
		var IS_GROUP = $F(radioElement);
		if('0' == IS_GROUP){<%--非集團--%>
			$('GROUP_NAME').setValue(BORROW_NAME);
			if($$('option[value="99"]').length == 0){
				$('GROUP_LVL').insert(value99);
			}
			$('GROUP_LVL').setValue('99');<%--其他法人機構--%>
			$w('GROUP_NAME GROUP_LVL').each(function(id){
				$(id).disabled = true;
			});
		}else{<%--是集團--%>
			var option99 = $$('option[value="99"]');
			if(option99.length != 0){
				$('GROUP_LVL').removeChild(option99[0]);
			}
			$('CRED_RATE').disabled = true;
		}
	},
	<%--取得A035Map資料--%>
	getA035Map : function(){
		var A035Map = {};
		A035Map['isCORP_DEPT'] = isCORP_DEPT;
		A035Map['FILE_MAP'] = {'SER_NO' : $F('FILE_SER_NO'), 'FILE_PATH' : $F('FILE_PATH')};
		
		for(var mover =0; mover < LISTA035_L.length ; mover++){
			var A035L = LISTA035_L[mover]||{};
			A035L['IS_BO'] = A035L['IS_BO']||'0';
		}
		A035Map['A035List'] = [].concat(LISTA035_1).concat(LISTA035_2).concat(LISTA035_3).concat(LISTA035_4).concat(LISTA035_5).concat(LISTA035_L);
		return A035Map;
	},
	<%--FILE_NAME連動--%>
	doFILE_NAMEDefaultValue : function(FILE_NAME){
		$('FILE_NAME').update(FILE_NAME);
		if(FILE_NAME){<%--有上傳股權結構圖，不須輸入【1~5層股權結構】，需自行輸入【持股比例計算區】--%>
			<%--【1~5層股權結構】資料清空--%>
			LISTA035_1 = [];
			LISTA035_2 = [];
			LISTA035_3 = [];
			LISTA035_4 = [];
			LISTA035_5 = [];
			actions.constructRows_BlockF(LISTA035_1, 'blockF_1');
			actions.constructRows_BlockF(LISTA035_2, 'blockF_2');
			actions.constructRows_BlockF(LISTA035_3, 'blockF_3');
			actions.constructRows_BlockF(LISTA035_4, 'blockF_4');
			actions.constructRows_BlockF(LISTA035_5, 'blockF_5');
		}else{<%--沒有上傳股權結構圖，須自行輸入【1~5層股權結構】，【持股比例計算區】由試算產生--%>
			<%--【持股比例計算區】資料清空--%>
			LISTA035_L = [];
			actions.constructRows_BlockF(LISTA035_L, 'blockF_6');
		}
		var FILE_NAMEHasValue_thenDisable = FILE_NAME ? true : false;
		actions.blockFControl(FILE_NAMEHasValue_thenDisable);<%--[20200116]抽出方法--%>
		<%--試算、股權結構圖產出  FILE_NAME 有值disable 沒值enable--%>
		$('btn_calculate').disabled = FILE_NAMEHasValue_thenDisable;
		$('btn_exportTreeChart').disabled = FILE_NAMEHasValue_thenDisable;
		<%--UPLD_FILE、上傳   FILE_NAME 有值disable 沒值enable--%>
		$('UPLD_FILE').disabled = FILE_NAMEHasValue_thenDisable;
		$('btn_upload').disabled = FILE_NAMEHasValue_thenDisable;
	},
	<%--將FILE_MAP的資料重設到頁面上--%>
	setFILE_MAPData : function(FILE_MAP){
		$('FILE_SER_NO').setValue(FILE_MAP['SER_NO'] || '');
		$('FILE_PATH').setValue(FILE_MAP['FILE_PATH'] || '');
		actions.doFILE_NAMEDefaultValue(FILE_MAP['FILE_NAME'] || '');<%--FILE_NAME連動--%>
	},
	<%--下載檔案--%>
	downloadFile : function(){
		RPTUtil.downloadFile ( "${dispatcher}/DSA1_0300/download" ,
			{
				'SER_NO' : $F('FILE_SER_NO'),
				'APPLY_ID' : $F('APPLY_ID')
			},
			true );
	},
	<%--[20200116]blockF裡面的input和button 的disable或enable控制--%>
	blockFControl : function(hasFileName){
		<%--[20200116]新增區塊控制--%>
		$w('blockF_1 blockF_2 blockF_3 blockF_4 blockF_5 blockF_6').each(function(id){
			$(id).up('table').select('button,select,input').each(function(ele){
				$(ele).disabled = false;
			});
		});
		$w('blockF_1 blockF_2 blockF_3 blockF_4 blockF_5').each(function(id){
			$(id).up('table').select('button,select,input').each(function(ele){
				$(ele).disabled = hasFileName;
			});
		});
		<%--【持股比例計算區】input、select欄位、buttons FILE_NAME 有值enable 沒值disable--%>
		$('blockF_6').up('table').select('button,select,input[type!=checkbox]').each(function(ele){
			$(ele).disabled = !hasFileName;
		});
	},
	<%-- [20200916] 國家連動投資金額 --%>
	disabledCOUNTRY_INVEST_AMT : function(){
		$('COUNTRY_INVEST_AMT').disabled = ($F('COUNTRY') == 'TW') ;
	},
	<%-- [20200918] 連動計算集團及其他法人機構尚可投資金額 --%>
	calcGROUP_INVEST_AMT : function(){
		var radioElement = getSelectRadioItem('IS_GROUP');
		if(radioElement == null){
			return;
		}
		var reqMap = {};
		reqMap.OWNERSHIP = $('OWNERSHIP').innerHTML.replace(/[,]+/g , '');//取代千份位
		reqMap.IS_GROUP = $F(radioElement);
		reqMap.GROUP_LVL = $F('GROUP_LVL');
		reqMap.CRED_RATE = $F('CRED_RATE');
		
		if(OWNERSHIP){
			new Ajax.Request("${dispatcher}/DSA1_0300/calcGROUP_INVEST_AMT", 
				{
					asynchronous: false,
					parameters:{reqMap : Object.toJSON(reqMap)},
					onSuccess: function(XHT, resp){
						if(CSRUtil.isSuccess(resp)){
							$('GROUP_INVEST_AMT').setValue(resp.GROUP_INVEST_AMT);
						}
					}
				}	
			);
		}
		
		
	}
	
};
var buttons = {
	<%--試算--%>
	calculateLISTA035_L : function(){
		<%--畫面程序檢核--%>
		if(LISTA035_1.length == 0){
			<%--F-1區需有資料，若無資料，警示訊息:‘請至少輸入一層股權結構’--%>
			alert('請至少輸入一層股權結構');
			return;
		}
		<%--F-1~F-5區，若有輸入，每筆資料的每個欄位都需輸入，若有缺漏，警示訊息:‘股權結構資訊不可為空’(為空的欄位標紅色)--%>
		$w('blockF_1 blockF_2 blockF_3 blockF_4 blockF_5 blockF_6').each(function(id){
			$(id).up('table').select('input[type!=radio],select').each(function(ele){
				validateEmpty(ele.id, '股權結構資訊不可為空');
			});
		});
		var A035List = [].concat(LISTA035_1).concat(LISTA035_2).concat(LISTA035_3).concat(LISTA035_4).concat(LISTA035_5);
		new Ajax.Request("${dispatcher}/DSA1_0300/calculate", 
			{
				asynchronous: false,
				parameters:{"A035List":Object.toJSON(A035List)},
			 	onSuccess: function(XHT, resp){
			 		if(CSRUtil.isSuccess(resp)){
			 			<%--將資料(A035_L)逐筆放到畫面【F-6區】--%>
			 			LISTA035_L = resp.A035_L || [];
			 			actions.constructRows_BlockF(LISTA035_L, 'blockF_6');
			 		}
			 	}
			}	
		);
	},
	<%--上傳--%>
	uploadFile : function(){
		if(!$F('UPLD_FILE')){
			alert('請先選擇上傳資料再執行!');
			return;
		}
		var uploadReqMap = {
			'APPLY_ID' : $F('APPLY_ID'),
			'FILE_SOURCE' : 'DSA1_0300'
		};
		$('uploadReqMap').setValue(Object.toJSON(uploadReqMap));
		$('form1').setAttribute('action','${dispatcher}/DSA1_0300/upload');
		$('form1').setAttribute('target','importFrame');
		
		auxiliary.createCoverPage();			
		<%--把檔案匯入--%>
		$('form1').submit();
	},
	<%--上傳結束回來--%>
	uploadEnd : function(){
		if(!window.importFrame.document.getElementById('filedata')){
			return;
		}
		var obj = window.importFrame.document.getElementById('filedata').innerHTML.evalJSON();				
		var Msg = obj.ErrMsg.msgDesc.replace('\\n','');
		if(Msg){
			alert(Msg);
		}
		
		auxiliary.closeCoverPage();	
		if(CSRUtil.isSuccess(obj)){		
			$('uploadReqMap').setValue('');	
			$('UPLD_FILE').up('span').update(new Element( "input", { id: 'UPLD_FILE', name : 'UPLD_FILE', type:"file" }));
			actions.setFILE_MAPData(obj.FILE_MAP || {});
		}
	},
	<%--刪除檔案--%>
	deleteFile : function(){
		new Ajax.Request("${dispatcher}/DSA1_0300/deleteFile", 
			{
				asynchronous: false,
				parameters:{'APPLY_ID' : $F('APPLY_ID'), 'SER_NO' : $F('FILE_SER_NO')},
			 	onSuccess: function(XHT, resp){
			 		if(CSRUtil.isSuccess(resp)){
			 			actions.setFILE_MAPData({});
			 		}
			 	}
			}	
		);
	},
	<%--產出股權結構圖(F區)--%>
	doExportTreeChart : function(){
		<%--檢核--%>
		<%--F-6區需有資料，若無資料，警示訊息:‘請先試算股東持股比例’--%>
		if(LISTA035_L.length == 0){
			alert('請先試算股東持股比例');
			return;
		}
		validate4define.clear();	<%--清define--%>
		validate4define.reset();	<%--清背景色--%>
		<%--F-1~F-5區，若有輸入，每筆資料的每個欄位都需輸入，若有缺漏，警示訊息:‘股權結構資訊不可為空’(為空的欄位標紅色)--%>
		$w('blockF_1 blockF_2 blockF_3 blockF_4 blockF_5').each(function(id){
			$(id).select('input[type!=radio],select').each(function(ele){
				validateEmpty(ele.id,'股權結構資訊不可為空');
			});
		});
		if(validate4define.validate() == false){
			return ;
		}
		<%--另開分頁顯示樹狀圖--%>
		var A035List = [].concat(LISTA035_1).concat(LISTA035_2).concat(LISTA035_3).concat(LISTA035_4).concat(LISTA035_5).concat(LISTA035_L);
		popupWin.windowOpen('${dispatcher}/DSA1_0301/prompt',{
			'parameters': { 'A035List': encodeURI(Object.toJSON(A035List)), 'BORROW_NAME' : encodeURI(BORROW_NAME), 'BORROW_ID' : encodeURI(BORROW_ID)},
			'attributes': { resizable:'yes'},
			'fullScreen': true,
			'windowName': $F('APPLY_ID')
		});
	}
};
var auxiliary = {
	<%--CoverPage(鎖定畫面)--%>
	createCoverPage:function(){
		cover = CSRUtil.createCoverPage('_frontCover');
		cover.show();
	},
	<%--CoverPage(開放畫面)--%>
	closeCoverPage: function(){
		cover.hide();
	}
}
<%--[20191224]修改結束--%>

<%--
	轉大寫
--%>
function columnToUpperCase(columnName) {
	if(isNotEmpty($F(columnName))) {
		$(columnName).value = $(columnName).value.toUpperCase();
	}
}

<%--
	辨別是不是null或undefined	
--%>
function isNotEmpty(value) {
	if(value == null || typeof(value) == 'undefined') {
		return false;
	}else {
		return true;
	}
}

<%--
	辨別是不是null或undefined	
--%>
function isEmpty(value) {
	if(value == null || typeof(value) == 'undefined') {
		return true;
	}else {
		return false;
	}
}


<%--
	取得數值
--%>
function getNumber(name) {
	return $(name).value.replace(/,/g,'');
}

<%--
	是否非數值
--%>
function isNotANumber(columnName) {
	if(isNotEmpty($(columnName).value) && isNaN($(columnName).value.replace(/,/g,''))) {
		return true;
	}
	return false;
}

<%--
	當不是數值時，設定錯誤
--%>
function validateNotANumber(columnName,message) {
	if(isNotEmpty($(columnName).value) && isNaN($(columnName).value.replace(/,/g,''))) {
		setFalseCheck(columnName,message);
	}
}


<%-- 是否尚未輸入 --%>
function isUnInput(name) {
	if(document.getElementById(name) == null) {
		return false;
	}
	if($F(name) === '') {
		return true;
	}else {
		return false
	}
}

<%--
	檢查是不是空值，並設定訊息
--%>
function validateEmpty(name,errorMessage) {
	if($F(name) == '') {
		setFalseCheck(name,errorMessage);
	}
}

<%--
	檢查是不是空值，並設定訊息
--%>
function validateROCformate(name,errorMessage) {
	if($F(name) == '') {
		return;
	}
	if(isROCdate($(name).value) == false) {
		setFalseCheck(name,errorMessage);
	}
}

<%--
	檢查是否有半型字
--%>
function haveHalfTypeWord(columnName) {
	if(validation.hasHalfType($(columnName).value)) {
		return true;
	}else {
		return false;
	}
}

<%--
	檢查是否有半型字，有時設定錯誤
--%>
function validateHaveHalfTypeWord(columnName,message) {
	if(validation.hasHalfType($(columnName).value)) {
		setFalseCheck(columnName,message);
	}
}

<%--
	檢查是否有全型字
--%>
function haveFullTypeWord(columnName) {
	if(validation.hasFullType($(columnName).value)) {
		return true;
	}else {
		return false;
	}
}

<%--
	檢查是否有全型字，有時設定錯誤
--%>
function validateHaveFullTypeWord(columnName,message) {
	if(validation.hasFullType($(columnName).value)) {
		setFalseCheck(columnName,message);
	}
}


<%--
	設定錯誤訊息
--%>
function setFalseCheck(ID,errorMessage) {
	validate4define.define( "customize_returnFalse" , [{ 'id' :ID , 'errMsg' : errorMessage}] , { 'useTitle': false });
}

<%--
	檢核值的長度
--%>
function setLengthCheck(chineseName,ID,maxLength,isNumber) {
	var value = null;
	if(isNumber) {
		value = $(ID).value.replace(/,/g,'');
	}else {
		value = $(ID).value;
	}
	if(!validation.checkInputLength(value, maxLength)){
		validate4define.define( "customize_returnFalse" , [{ id :ID , errMsg : chineseName + "長度超過" + maxLength + " (全形字為2)"}] , { useTitle: false });
		result = false;
	}
}


<%-- 長度檢核 --%>
function checkMaxLength() {
	<%--
		受理編號	APPLY_ID	
		名稱(中文)	CNAME
		名稱(英文)	ENAME
		成立日期	BUILD_DATE
		營利事業統一編號	ID
		負責人	CHIEF
		員工人數	EMP_NUM
		地址(公司)	COP_ADDR
	--%>
	setLengthCheck('受理編號','APPLY_ID',11);
	setLengthCheck('名稱(中文)','CNAME',40);
	setLengthCheck('名稱(英文)','ENAME',40);
	setLengthCheck('成立日期','BUILD_DATE',7);
	setLengthCheck('營利事業統一編號','ID',10);
	setLengthCheck('負責人','CHIEF',60);
	setLengthCheck('員工人數','EMP_NUM',8);
	setLengthCheck('地址(公司)','COP_ADDR',80);
		
	<%--
		電話(公司)	COP_TEL_NUM
		電話-分機(公司)	COP_TEL_EXT
		地址(工廠)	FAC_ADDR
		電話(工廠)	FAC_TEL_NUM
		電話-分機(工廠)	FAC_TEL_EXT
		登記資本額	CAPITAL
		實收資本額	REAL_CAPITAL
	--%>
	setLengthCheck('電話(公司)','COP_TEL_NUM',10);
	setLengthCheck('電話-分機(公司)','COP_TEL_EXT',6);
	setLengthCheck('地址(工廠)','FAC_ADDR',80);
	setLengthCheck('電話(工廠)','FAC_TEL_NUM',10);
	setLengthCheck('電話-分機(工廠)','FAC_TEL_EXT',6);
	setLengthCheck('登記資本額','CAPITAL',14);
	setLengthCheck('實收資本額','REAL_CAPITAL',14);
		
	<%--
		主要業務及產品	PRODUCT
		主要銷售對象	MARKET
		銷售方式(內銷)	IN_SALE_RATE
		銷售方式(外銷)	OUT_SALE_RATE
		產業別	TERRITORY
	--%>
	setLengthCheck('主要業務及產品','PRODUCT',100);
	setLengthCheck('主要銷售對象','MARKET',100);
	setLengthCheck('銷售方式(內銷)','IN_SALE_RATE',6);
	setLengthCheck('銷售方式(外銷)','OUT_SALE_RATE',6);
	<%--[20200108]移除產業別檢核--%>
}

<%--
	設定一連串檢核
--%>
function checks() {
	<%--
		3.	新增(A區)(B0003)
		3.1	畫面程序檢核: 
		3.1.1	檢核A區的以下欄位必須有值:
		     名稱(中文)、CNAME
		     負責人、CHIEF
		     地址(公司)、COP_ADDR
		     電話-區碼(公司)、COP_TEL_AREA
		     電話(公司)、COP_TEL_NUM
		     登記資本額、CAPITAL
		     實收資本額、REAL_CAPITAL
		主要業務及產品、銷售方式(內銷)、銷售方式(外銷)、產業別
		3.1.2	檢核「銷售方式(內銷)」輸入值:
				IF  IN_SALE_RATE  >  100，顯示錯誤訊息:‘內銷比率有誤!’
		3.1.3	檢核「銷售方式(外銷)」輸入值:
				IF  OUT_SALE_RATE  >  100，顯示錯誤訊息:‘外銷比率有誤!’
	--%>
	
	validateEmpty('APPLY_ID',"受理編號必須輸入!");
	
	if($('IN_SALE_RATE').value.replace(/,/g,'') - 100 > 0) {
		setFalseCheck('IN_SALE_RATE',"內銷比率有誤!");
	}
	if($('OUT_SALE_RATE').value.replace(/,/g,'') - 100 >  0) {
		setFalseCheck('OUT_SALE_RATE',"外銷比率有誤!");
	}
	
	if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){
		// 名稱(英文)、CNAME
		validateEmpty('ENAME',"名稱(英文)必須輸入!");
	}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
		// 名稱(中文)、CNAME
		validateEmpty('CNAME',"名稱(中文)必須輸入!");
	}
	
	// 負責人、CHIEF
	validateEmpty('CHIEF',"負責人必須輸入!");
	
	// 地址(公司)、COP_ADDR
	validateEmpty('COP_ADDR',"地址(公司)必須輸入!");
	
	// 電話(公司)、COP_TEL_NUM
	validateEmpty('COP_TEL_NUM',"電話(公司)必須輸入!");
	
	// 登記資本額、CAPITAL
	validateEmpty('CAPITAL',"登記資本額必須輸入!");
	
	//實收資本額、REAL_CAPITAL
	validateEmpty('REAL_CAPITAL',"實收資本額必須輸入!");
	
    //主要業務及產品、PRODUCT
	validateEmpty('PRODUCT',"主要業務及產品必須輸入!");
	
    //銷售方式(內銷)、IN_SALE_RATE
	validateEmpty('IN_SALE_RATE',"銷售方式(內銷)必須輸入!");
	
    //銷售方式(外銷)、OUT_SALE_RATE
	validateEmpty('OUT_SALE_RATE',"銷售方式(外銷)必須輸入!");
	
    //產業別、TERRITORY
	validateEmpty('TERRITORY',"產業別必須輸入!");
	
	
	<%--[20191224]法金件檢核--%>
	//有選"是否為集團"才檢核
	var IS_GROUP = $$('input[name=IS_GROUP]:checked');
	if(isCORP_DEPT && IS_GROUP.size()>0){
		validateEmpty('GROUP_NAME',"集團名稱必須有值!");
		if($F('GROUP_LVL') == 99){
			validateEmpty('CRED_RATE',"信用評等為必輸欄位!");
		}
	}
	
	<%--[20200928]法金件檢核授信額度--%>
	if(isCORP_DEPT){
		validateNotANumber('GROUP_INVEST_AMT',"集團及其他法人機構尚可投資金額為數字!");
		validateNotANumber('CREDIT_AMT',"授信額度須為數字!");
		validateNotANumber('COUNTRY_INVEST_AMT',"國家尚可投資金額須為數字!");
	}
	
	<%-- 欄位長度檢核--%>
	checkMaxLength();
	
	<%-- 檢核格式 --%>
	if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){
		validateHaveHalfTypeWord('CNAME',"名稱(中文)須為全形中文!");
		validateHaveFullTypeWord('ENAME',"名稱(英文)須為半形英文!");
		validateHaveFullTypeWord('CHIEF',"負責人須為半形英文!");
		validateHaveFullTypeWord('COP_ADDR',"地址(公司)須為半形英文!");
		validateHaveFullTypeWord('FAC_ADDR',"地址(工廠)須為半形英文!");
		validateHaveHalfTypeWord('PRODUCT',"主要業務及產品須為全形中文!");
		validateHaveHalfTypeWord('MARKET',"主要銷售對象須為全形中文!");
		<%--[20200108]移除產業別檢核--%>
	}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
		validateHaveHalfTypeWord('CNAME',"名稱(中文)須為全形中文!");
		validateHaveHalfTypeWord('CHIEF',"負責人須為全形中文!");
		validateHaveHalfTypeWord('COP_ADDR',"地址(公司)須為全形中文!");
		validateHaveHalfTypeWord('FAC_ADDR',"地址(工廠)須為全形中文!");
		validateHaveHalfTypeWord('PRODUCT',"主要業務及產品須為全形中文!");
		validateHaveHalfTypeWord('MARKET',"主要銷售對象須為全形中文!");
		<%--[20200108]移除產業別檢核--%>
	}
	
	validateNotANumber('EMP_NUM',"員工人數須為數字!");
	validateNotANumber('COP_TEL_NUM',"電話(公司)須為數字!");
	validateNotANumber('COP_TEL_EXT',"電話(分機)須為數字!");
	validateNotANumber('FAC_TEL_NUM',"電話(工廠)須為數字!");
	validateNotANumber('FAC_TEL_EXT',"電話(分機)須為數字!");
	validateNotANumber('CAPITAL',"登記資本額須為數字!");
	validateNotANumber('REAL_CAPITAL',"實收資本額須為數字!");
	validateNotANumber('IN_SALE_RATE',"銷售方式(內銷)須為數字!");
	validateNotANumber('OUT_SALE_RATE',"銷售方式(外銷)須為數字!");
	validateROCformate('BUILD_DATE','成立日期須為日期格式!');
	
	<%-- 檢核統編 --%>
	if(isUnInput('ID') == false) {
		if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){
			//不檢核統一編號檢核規則!
			/*if(isNotANumber('ID')) {
				setFalseCheck('ID',"營利事業統一編號須為數字!");
			}*/
		}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
			if(isNotANumber('ID')) {
				setFalseCheck('ID',"營利事業統一編號須為數字!");
			}
			if(iscmpid($F('ID')) == false) {
				setFalseCheck('ID',"營利事業統一編號須符合統一編號檢核規則!");
			} 
		}
	}
	
	<%-- 輸入區塊檢核--%>
	input_block_check();
	
}


<%--
	移除一列資料
--%>
function removeOneRow(BLOCK) {
	if(BLOCK == "B") {
		for(var mover=0; mover < LIST31.length ; mover++) {
			var target_A031 = LIST31[mover];
			var NOW_ROW_SEQ_NO = target_A031["A031_SEQ_NO"];
			var targetRowIndex = mover;
		
			var A031_NAME = 'INPUT_' + 'A031_NAME' + '_' +  NOW_ROW_SEQ_NO;
			var A031_NAME_VALUE = $(A031_NAME).value;

			var A031_TITLE = 'INPUT_' + 'A031_TITLE' + '_' + NOW_ROW_SEQ_NO;
			var A031_TITLE_VALUE = $(A031_TITLE).value;

			var A031_AGE = 'INPUT_' + 'A031_AGE' + '_' + NOW_ROW_SEQ_NO;
			var A031_AGE_VALUE = $(A031_AGE).value;
			
			var A031_DEGREE_VALUE = $('INPUT_' + 'A031_DEGREE' + '_' +  NOW_ROW_SEQ_NO).value;

			var A031_SERV_YEAR = 'INPUT_' + 'A031_SERV_YEAR' + '_' + NOW_ROW_SEQ_NO;
			var A031_SERV_YEAR_VALUE = $(A031_SERV_YEAR).value;
			
			var A031_HOLD_RATE = 'INPUT_' + 'A031_HOLD_RATE' + '_' + NOW_ROW_SEQ_NO;
			var A031_HOLD_RATE_VALUE = $(A031_HOLD_RATE).value;
			
			var A031_EXPERIENCE_VALUE = $('INPUT_' + 'A031_EXPERIENCE' + '_' +  NOW_ROW_SEQ_NO).value;

		    //NAME    VARCHAR(60) 
			LIST31[targetRowIndex]['A031_NAME'] = A031_NAME_VALUE;
		    //TITLE   VARCHAR(20) 
			LIST31[targetRowIndex]['A031_TITLE'] = A031_TITLE_VALUE;
		    //AGE DECIMAL(3)  
			LIST31[targetRowIndex]['A031_AGE'] = A031_AGE_VALUE;
		    //DEGREE  VARCHAR(10) 
			LIST31[targetRowIndex]['A031_DEGREE'] = A031_DEGREE_VALUE;
		    //SERV_YEAR   DECIMAL(3)  
			LIST31[targetRowIndex]['A031_SERV_YEAR'] = A031_SERV_YEAR_VALUE;
		    //HOLD_RATE   DECIMAL(6,3)    
			LIST31[targetRowIndex]['A031_HOLD_RATE'] = A031_HOLD_RATE_VALUE;
		    //EXPERIENCE  VARCHAR(100)                
			LIST31[targetRowIndex]['A031_EXPERIENCE'] = A031_EXPERIENCE_VALUE;
		}
		<%--
			將目標row 刪除
		--%>
		var selectItem = getSelectRadioItem('list_B');
		var target_SEQ_NO = selectItem.value;
		var targetRowIndex = getTargetRowIndex(LIST31,target_SEQ_NO,"A031_SEQ_NO");
		LIST31 = deleteOneElement(LIST31,targetRowIndex);
		<%-- 依LIST31最新資料重建區塊B --%>
		constructRows_BlockB(LIST31);
		
	}else if(BLOCK == "C") {
		for(var mover=0; mover < LIST32.length ; mover++) {
			var target_A032 = LIST32[mover];
			var NOW_ROW_SEQ_NO = target_A032["A032_SEQ_NO"];
			var targetRowIndex = mover;
			
			var A032_NAME = 'INPUT_' + 'A032_NAME' + '_' +  NOW_ROW_SEQ_NO;
			var A032_NAME_VALUE = $(A032_NAME).value;

			var A032_PRODUCT = 'INPUT_' + 'A032_PRODUCT' + '_' +  NOW_ROW_SEQ_NO;
			var A032_PRODUCT_VALUE = $(A032_PRODUCT).value;

			var A032_ID = 'INPUT_' + 'A032_ID' + '_' +  NOW_ROW_SEQ_NO;
			var A032_ID_VALUE = $(A032_ID).value;
			
			var A032_RELATION = 'INPUT_A032_RELATION_' +  NOW_ROW_SEQ_NO;
			var A032_RELATION_VALUE = $(A032_RELATION).value;

			var A032_REAL_CAPITAL = 'INPUT_' + 'A032_REAL_CAPITAL' + '_' +  NOW_ROW_SEQ_NO;
			var A032_REAL_CAPITAL_VALUE = $(A032_REAL_CAPITAL).value;

			var A032_REINVEST_AMT = 'INPUT_' + 'A032_REINVEST_AMT' + '_' +  NOW_ROW_SEQ_NO;
			var A032_REINVEST_AMT_VALUE = $(A032_REINVEST_AMT).value;

			var A032_HOLD_RATE = 'INPUT_' + 'A032_HOLD_RATE' + '_' +  NOW_ROW_SEQ_NO;
			var A032_HOLD_RATE_VALUE = $(A032_HOLD_RATE).value;
			
			//事業名稱	A032_NAME
			LIST32[targetRowIndex]['A032_NAME'] = A032_NAME_VALUE;
			//主要業務	A032_PRODUCT
			LIST32[targetRowIndex]['A032_PRODUCT'] = A032_PRODUCT_VALUE;
			//統一編號	A032_ID
			LIST32[targetRowIndex]['A032_ID'] = A032_ID_VALUE;
			//與關係企業關係	A032_RELATION
			LIST32[targetRowIndex]['A032_RELATION'] = A032_RELATION_VALUE;
			//實收資本額(萬)	A032_REAL_CAPITAL
			LIST32[targetRowIndex]['A032_REAL_CAPITAL']= A032_REAL_CAPITAL_VALUE;
			//轉投資金額(萬)	A032_REINVEST_AMT
			LIST32[targetRowIndex]['A032_REINVEST_AMT']= A032_REINVEST_AMT_VALUE;
			//持股比例％	A032_HOLD_RATE
			LIST32[targetRowIndex]['A032_HOLD_RATE'] = A032_HOLD_RATE_VALUE;
		}
		
		<%--
			將目標row 刪除
		--%>
		var selectItem = getSelectRadioItem('list_C');
		var target_SEQ_NO = selectItem.value;
		var targetRowIndex = getTargetRowIndex(LIST32,target_SEQ_NO,"A032_SEQ_NO");
		LIST32 = deleteOneElement(LIST32,targetRowIndex);
	
		<%-- 依LIST31最新資料重建區塊B --%>
		constructRows_BlockC(LIST32);
	
	}else if(BLOCK == 'blockF_1'){<%--[20191224]新增區域F的刪除--%>

		var selectItem = getSelectRadioItem('ListA035_1');
		LISTA035_1 = deleteOneElement(LISTA035_1, selectItem.value);

		actions.constructRows_BlockF(LISTA035_1,BLOCK);
		
	}else if(BLOCK == 'blockF_2'){<%--[20191224]新增區域F的刪除--%>

		var selectItem = getSelectRadioItem('ListA035_2');
		LISTA035_2 = deleteOneElement(LISTA035_2, selectItem.value);

		actions.constructRows_BlockF(LISTA035_2,BLOCK);
		
	}else if(BLOCK == 'blockF_3'){<%--[20191224]新增區域F的刪除--%>

		var selectItem = getSelectRadioItem('ListA035_3');
		LISTA035_3 = deleteOneElement(LISTA035_3, selectItem.value);

		actions.constructRows_BlockF(LISTA035_3,BLOCK);
		
	}else if(BLOCK == 'blockF_4'){<%--[20191224]新增區域F的刪除--%>

		var selectItem = getSelectRadioItem('ListA035_4');
		LISTA035_4 = deleteOneElement(LISTA035_4, selectItem.value);

		actions.constructRows_BlockF(LISTA035_4,BLOCK);
		
	}else if(BLOCK == 'blockF_5'){<%--[20191224]新增區域F的刪除--%>

		var selectItem = getSelectRadioItem('ListA035_5');
		LISTA035_5 = deleteOneElement(LISTA035_5, selectItem.value);

		actions.constructRows_BlockF(LISTA035_5,BLOCK);
		
	}else if(BLOCK == 'blockF_6'){<%--[20191224]新增區域F的刪除--%>

		var selectItem = getSelectRadioItem('ListA035_L');
		LISTA035_L = deleteOneElement(LISTA035_L, selectItem.value);

		actions.constructRows_BlockF(LISTA035_L,BLOCK);
		
	}else {
		for(var mover=0; mover < LIST23.length ; mover++) {
			var target_A023 = LIST23[mover];
			var NOW_ROW_SEQ_NO = target_A023["A023_SEQ_NO"];
			var targetRowIndex = mover;
			
			var A023_ADDRESS = 'INPUT_' + 'A023_ADDRESS' + '_' +  NOW_ROW_SEQ_NO;
			var A023_ADDRESS_VALUE = $(A023_ADDRESS).value;

			var A023_BUILD_DOOR = 'INPUT_' + 'A023_BUILD_DOOR' + '_' +  NOW_ROW_SEQ_NO;
			var A023_BUILD_DOOR_VALUE = $(A023_BUILD_DOOR).value;

			var A023_LAND_NO1 = 'INPUT_' + 'A023_LAND_NO1' + '_' +  NOW_ROW_SEQ_NO;
			var A023_LAND_NO1_VALUE = $(A023_LAND_NO1).value;

			var A023_LAND_NO2 = 'INPUT_' + 'A023_LAND_NO2' + '_' +  NOW_ROW_SEQ_NO;
			var A023_LAND_NO2_VALUE = $(A023_LAND_NO2).value;

			var A023_BUILD_NO1 = 'INPUT_' + 'A023_BUILD_NO1' + '_' +  NOW_ROW_SEQ_NO;
			var A023_BUILD_NO1_VALUE = $(A023_BUILD_NO1).value;

			var A023_BUILD_NO2 = 'INPUT_' + 'A023_BUILD_NO2' + '_' +  NOW_ROW_SEQ_NO;
			var A023_BUILD_NO2_VALUE = $(A023_BUILD_NO2).value;
			
			//使用情形	A023_USE_STATUS	LAND_USE_STS_LIST	下拉選單
			var A023_USE_STATUS_VALUE = $('INPUT_' + 'A023_USE_STATUS' + '_' +  + NOW_ROW_SEQ_NO).value;
			//設定情形-行庫	A023_SET_BANK		輸入欄位
			var A023_SET_BANK_VALUE = $('INPUT_' + 'A023_SET_BANK' + '_' +  + NOW_ROW_SEQ_NO).value;		
			//設定情形-金額	A023_SET_AMT		輸入欄位
			var A023_SET_AMT_VALUE = $('INPUT_' + 'A023_SET_AMT' + '_' +  + NOW_ROW_SEQ_NO).value;		
			
			//座落所在地	A023_ADDRESS		輸入欄位
			LIST23[targetRowIndex]['A023_ADDRESS'] = A023_ADDRESS_VALUE;
			//建物門牌	A023_BUILD_DOOR		輸入欄位
			LIST23[targetRowIndex]['A023_BUILD_DOOR'] = A023_BUILD_DOOR_VALUE;
			//地號(一)	A023_LAND_NO1		輸入欄位
			LIST23[targetRowIndex]['A023_LAND_NO1'] = A023_LAND_NO1_VALUE;
			//地號(二)	A023_LAND_NO2		輸入欄位
			LIST23[targetRowIndex]['A023_LAND_NO2'] = A023_LAND_NO2_VALUE;
			//建號(一)	A023_BUILD_NO1		輸入欄位
			LIST23[targetRowIndex]['A023_BUILD_NO1'] = A023_BUILD_NO1_VALUE;
			//建號(二)	A023_BUILD_NO2		輸入欄位
			LIST23[targetRowIndex]['A023_BUILD_NO2'] = A023_BUILD_NO2_VALUE;
			//使用情形	A023_USE_STATUS	LAND_USE_STS_LIST	下拉選單
			LIST23[targetRowIndex]['A023_USE_STATUS'] = A023_USE_STATUS_VALUE;
			//設定情形-行庫	A023_SET_BANK		輸入欄位
			LIST23[targetRowIndex]['A023_SET_BANK'] = A023_SET_BANK_VALUE;
			//設定情形-金額	A023_SET_AMT		輸入欄位
			LIST23[targetRowIndex]['A023_SET_AMT'] = A023_SET_AMT_VALUE;
		}
		<%--
			將目標row 刪除
		--%>
		var selectItem = getSelectRadioItem('list_D');
		var target_SEQ_NO = selectItem.value;
		var targetRowIndex = getTargetRowIndex(LIST23,target_SEQ_NO,"A023_SEQ_NO");
		LIST23 = deleteOneElement(LIST23,targetRowIndex);
		<%-- 依LIST23最新資料重建區塊C --%>
		constructRows_BlockD(LIST23);
	}
	autoFormatToNumber();
	autoFormatToDate();
	PageUI.resize(true);
}




function input_block_check() {
	var A031List_ok = true;
	var A032List_ok = true;
	var A023List_ok = true;
	
	<%-- 建物樓層資料 --%>
	if(isNotEmpty(LIST31)) {
		for(var mover=0; mover < LIST31.length ; mover++) {
			<%--
				8.	儲存(B區)
				8.1	畫面程序檢核: 
				8.1.1	檢核B區的以下欄位必須有值: 姓名、職稱、年齡
				8.2	讀取畫面欄位資料
				8.3	資料檢核: 無
				8.4	資料處理: 無
				8.5	畫面顯示:
				8.5.1	該列資料欄位全部改為顯示欄位，選取欄位顯示RADIO
				8.5.2	儲存按鈕改為新增
				8.5.3	不必顯示訊息
				
				姓名	A031_NAME		輸入欄位
				職稱	A031_TITLE		輸入欄位
				年齡	A031_AGE		輸入欄位
				學歷	A031_DEGREE		輸入欄位
				服務年資	A031_SERV_YEAR		輸入欄位
				持股比例％	A031_HOLD_RATE		輸入欄位
				經歷	A031_EXPERIENCE		輸入欄位
			--%>
			var target_A031 = LIST31[mover];
			var NOW_ROW_SEQ_NO = target_A031["A031_SEQ_NO"];
			
			var A031_NAME = 'INPUT_' + 'A031_NAME' + '_' +  NOW_ROW_SEQ_NO;
			var A031_NAME_VALUE = $(A031_NAME).value;
			if(isUnInput(A031_NAME)) {
				setFalseCheck(A031_NAME,'姓名必須有值!');
				A031List_ok = false;
			}else {
				if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){
					if(haveFullTypeWord(A031_NAME)) {
						setFalseCheck(A031_NAME,'姓名須為半形英文!');
						A031List_ok = false;
					}
				}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
					if(haveHalfTypeWord(A031_NAME)) {
						setFalseCheck(A031_NAME,'姓名須為全形中文!');
						A031List_ok = false;
					} 
				}
			}
			
			var A031_TITLE = 'INPUT_' + 'A031_TITLE' + '_' + NOW_ROW_SEQ_NO;
			var A031_TITLE_VALUE = $(A031_TITLE).value;
			if(isUnInput(A031_TITLE)) {
				setFalseCheck(A031_TITLE,'職稱必須有值!');
				A031List_ok = false;
			}else {
				if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){
					if(haveFullTypeWord(A031_TITLE)) {
						setFalseCheck(A031_TITLE,'職稱須為半形英文!');
						A031List_ok = false;
					}
				}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
					if(haveHalfTypeWord(A031_TITLE)) {
						setFalseCheck(A031_TITLE,'職稱須為全形中文!');
						A031List_ok = false;
					} 
				}
			}
			
			var A031_AGE = 'INPUT_' + 'A031_AGE' + '_' + NOW_ROW_SEQ_NO;
			var A031_AGE_VALUE = $(A031_AGE).value;
			if(isUnInput(A031_AGE)) {
				setFalseCheck(A031_AGE,'年齡必須有值!');
				A031List_ok = false;
			}else {
				if(isNotANumber(A031_AGE)) {
					setFalseCheck(A031_AGE,'年齡須為數字!');
					A031List_ok = false;
				}
			}
			
			<%--
				姓名、職稱 -- 須為全形中文
				年齡、服務年資 -- 須為數字
			--%>
			var A031_SERV_YEAR = 'INPUT_' + 'A031_SERV_YEAR' + '_' + NOW_ROW_SEQ_NO;
			var A031_SERV_YEAR_VALUE = $(A031_SERV_YEAR).value;
			if(isUnInput(A031_SERV_YEAR)) {
				setFalseCheck(A031_SERV_YEAR,'服務年資必須有值!');
				A031List_ok = false;
			}else {
				if(isNotANumber(A031_SERV_YEAR)) {
					setFalseCheck(A031_SERV_YEAR,'服務年資須為數字!');
					A031List_ok = false;
				}
			}
			
			var A031_HOLD_RATE = 'INPUT_' + 'A031_HOLD_RATE' + '_' + NOW_ROW_SEQ_NO;
			var A031_HOLD_RATE_VALUE = $(A031_HOLD_RATE).value;
			if(isUnInput(A031_HOLD_RATE) == false) {
				if(isNotANumber(A031_HOLD_RATE)) {
					setFalseCheck(A031_HOLD_RATE,'持股比例必須為數值!');
					A031List_ok = false;
				}
			}
			
			<%-- 1.主要董監事持股比例加總不得超過100% --%>
			if(A031_HOLD_RATE_VALUE !== ''  &&  isNaN(A031_HOLD_RATE_VALUE) == false  &&  LIST31 != null) {
			   
			   
				var sum = 0;
				for(var mover_1=0; mover_1 < LIST31.length ; mover_1++ ) {
					var targetRow = LIST31[mover_1];
					
					<%--
						排除當前目標資料
						NOW_ROW_SEQ_NO == targetRow['A031_SEQ_NO']
						不可加
					--%>
					if(isNotEmpty(NOW_ROW_SEQ_NO) && 
					   isNotEmpty(targetRow['A031_SEQ_NO']) && 
					   NOW_ROW_SEQ_NO - targetRow['A031_SEQ_NO'] != 0) {
					   
					   		if(isNotEmpty(targetRow['A031_HOLD_RATE']) == false)
					   		{
					   			continue;
					   		}
					   		
					   		var target_A031_HOLD_RATE = new String(targetRow['A031_HOLD_RATE']);
					   		target_A031_HOLD_RATE = target_A031_HOLD_RATE.replace(/,/g,'');
							if(target_A031_HOLD_RATE !== '' && target_A031_HOLD_RATE !== '0' && isNaN(target_A031_HOLD_RATE) == false) {
								sum += parseFloat(targetRow['A031_HOLD_RATE']);
							}
					}
				}
				
				<%--
					加當前目標的數值
				--%>
				sum += parseFloat(A031_HOLD_RATE_VALUE);
					
				if(sum - 100 > 0) {
					setFalseCheck(A031_HOLD_RATE,'主要董監事持股比例加總不得超過100%!');
					A031List_ok = false;
				}
			}
			
			<%--
				長度檢核
				姓名	A031_NAME
				職稱	A031_TITLE
				年齡	A031_AGE
				學歷	A031_DEGREE
				服務年資	A031_SERV_YEAR
				持股比例％	A031_HOLD_RATE
				經歷	A031_EXPERIENCE
			--%>
			var A031_DEGREE = 'INPUT_' + 'A031_DEGREE' + '_' +  NOW_ROW_SEQ_NO;
			var A031_EXPERIENCE = 'INPUT_' + 'A031_DEGREE' + '_' +  NOW_ROW_SEQ_NO;
			setLengthCheck('姓名',A031_NAME,60);
			setLengthCheck('職稱',A031_TITLE,20);
			setLengthCheck('年齡',A031_AGE,3,true);
			setLengthCheck('學歷',A031_DEGREE,10);
			setLengthCheck('服務年資',A031_SERV_YEAR,3,true);
			setLengthCheck('持股比例％',A031_HOLD_RATE,6,true);
			setLengthCheck('經歷',A031_EXPERIENCE,100);
		}	
	}////////////
	
	if(isNotEmpty(LIST32)) {
		for(var mover=0; mover < LIST32.length ; mover++) {
			<%--
				12.	儲存(C區)
				12.1	畫面程序檢核:
				12.1.1	檢核C區的以下欄位必須有值:
				          事業名稱、A032_NAME
				          主要業務、A032_PRODUCT
				          統一編號、A032_ID
				          實收資本額(萬)、A032_REAL_CAPITAL
				          轉投資金額(萬)、A032_REINVEST_AMT
				          持股比例％	A032_HOLD_RATE
				12.1.2	檢核「持股比例％」輸入值  : IF  A032_HOLD_RATE  >  100，顯示錯誤訊息:‘持股比例有誤!’
				12.2	讀取畫面欄位資料
				12.3	資料檢核: 無
				12.4	資料處理: 無
				12.5	畫面顯示:
				12.5.1	該列資料欄位全部改為顯示欄位，選取欄位顯示RADIO
				12.5.2	儲存按鈕改為新增
				12.5.3	不必顯示訊息
				
				事業名稱、主要業務 -- 須為全形中文
				統一編號 -- 須為數字且符合統一編號檢核規則
				實收資本額(萬)、轉投資金額(萬)、持股比例％ -- 須為數字
			--%>
			var target_A032 = LIST32[mover];
			var NOW_ROW_SEQ_NO = target_A032["A032_SEQ_NO"];
			
			var A032_NAME = 'INPUT_' + 'A032_NAME' + '_' +  NOW_ROW_SEQ_NO;
			var A032_NAME_VALUE = $(A032_NAME).value;
			if(isUnInput(A032_NAME)) {
				setFalseCheck(A032_NAME,'事業名稱必須有值!');
				A032List_ok = false;
			}else {
				if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){
					if(haveFullTypeWord(A032_NAME)) {
						setFalseCheck(A032_NAME,'事業名稱須為半形英文!');
						A032List_ok = false;
					}
				}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
					if(haveHalfTypeWord(A032_NAME)) {
						setFalseCheck(A032_NAME,'事業名稱須為全形中文!');
						A032List_ok = false;
					} 
				}
			}
			
			var A032_PRODUCT = 'INPUT_' + 'A032_PRODUCT' + '_' +  NOW_ROW_SEQ_NO;
			var A032_PRODUCT_VALUE = $(A032_PRODUCT).value;
			if(isUnInput(A032_PRODUCT)) {
				setFalseCheck(A032_PRODUCT,'主要業務必須有值!');
				A032List_ok = false;
			}else {
				if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){
					if(haveFullTypeWord(A032_PRODUCT)) {
						setFalseCheck(A032_PRODUCT,'主要業務須為半形英文!');
						A032List_ok = false;
					}
				}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
					if(haveHalfTypeWord(A032_PRODUCT)) {
						setFalseCheck(A032_PRODUCT,'主要業務須為全形中文!');
						A032List_ok = false;
					}
				}

			}
			
			var A032_ID = 'INPUT_' + 'A032_ID' + '_' +  NOW_ROW_SEQ_NO;
			var A032_ID_VALUE = $(A032_ID).value;
			if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){
				//不檢核統一編號檢核規則!
				if(isUnInput(A032_ID)) {
					setFalseCheck(A032_ID,'統一編號必須有值!');
					A032List_ok = false;
				}
			}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
				if(isUnInput(A032_ID)) {
					setFalseCheck(A032_ID,'統一編號必須有值!');
					A032List_ok = false;
				}else {
					if(iscmpid(A032_ID_VALUE) == false) {
						setFalseCheck(A032_ID,'營利事業統一編號須符合統一編號檢核規則!');
						A032List_ok = false;
					}
				} 
			}

			
			var A032_REAL_CAPITAL = 'INPUT_' + 'A032_REAL_CAPITAL' + '_' +  NOW_ROW_SEQ_NO;
			var A032_REAL_CAPITAL_VALUE = $(A032_REAL_CAPITAL).value.replace(/,/g,'');
			if(isUnInput(A032_REAL_CAPITAL)) {
				setFalseCheck(A032_REAL_CAPITAL,'實收資本額(萬)必須有值!');
				A032List_ok = false;
			}else {
				if(isNotANumber(A032_REAL_CAPITAL)) {
					setFalseCheck(A032_REAL_CAPITAL,'實收資本額(萬)須為數字!');
					A032List_ok = false;
				}
			}
			
			var A032_REINVEST_AMT = 'INPUT_' + 'A032_REINVEST_AMT' + '_' +  NOW_ROW_SEQ_NO;
			var A032_REINVEST_AMT_VALUE = $(A032_REINVEST_AMT).value.replace(/,/g,'');
			if(isUnInput(A032_REINVEST_AMT)) {
				setFalseCheck(A032_REINVEST_AMT,'轉投資金額(萬)必須有值!');
				A032List_ok = false;
			}else {
				if(isNotANumber(A032_REINVEST_AMT)) {
					setFalseCheck(A032_REINVEST_AMT,'轉投資金額(萬)須為數字!');
					A032List_ok = false;
				}
			}
			
			<%--
				2.投資事業概況：設控轉投資金額必需≦實收資本額
			--%>
			if(A032_REAL_CAPITAL_VALUE != '' && A032_REINVEST_AMT_VALUE != '' && A032_REINVEST_AMT_VALUE - A032_REAL_CAPITAL_VALUE.replace(/,/g,'') > 0) {
				setFalseCheck(A032_REAL_CAPITAL,'轉投資金額必需≦實收資本額!');
			}
			
			var A032_HOLD_RATE = 'INPUT_' + 'A032_HOLD_RATE' + '_' +  NOW_ROW_SEQ_NO;
			var A032_HOLD_RATE_VALUE = $(A032_HOLD_RATE).value.replace(/,/g,'');
			if(isUnInput(A032_HOLD_RATE)) {
				setFalseCheck(A032_HOLD_RATE,'持股比例必須有值!');
				A032List_ok = false;
			}else {
				if(isNotANumber(A032_HOLD_RATE)) {
					setFalseCheck(A032_HOLD_RATE,'持股比例須為數字!');
					A032List_ok = false;
				}else if(A032_HOLD_RATE_VALUE - 100 > 0) {
					setFalseCheck(A032_HOLD_RATE,'持股比例有誤!');
					A032List_ok = false;
				}
			}
			
			<%--
				長度檢核
				事業名稱	A032_NAME
				主要業務	A032_PRODUCT
				統一編號	A032_ID
				實收資本額(萬)	A032_REAL_CAPITAL
				轉投資金額(萬)	A032_REINVEST_AMT
				持股比例％	A032_HOLD_RATE
			--%>
			setLengthCheck('事業名稱',A032_NAME,60);
			setLengthCheck('主要業務',A032_PRODUCT,100);
			setLengthCheck('統一編號',A032_ID,10);
			setLengthCheck('實收資本額(萬)',A032_REAL_CAPITAL,14,true);
			setLengthCheck('轉投資金額(萬)',A032_REINVEST_AMT,14,true);
			setLengthCheck('持股比例％',A032_HOLD_RATE,6,true);
		}
	}
	
	if(isNotEmpty(LIST23)) {
		for(var mover=0; mover < LIST23.length ; mover++) {
			<%--
				12.	儲存(C區)
				12.1	畫面程序檢核:
				12.1.1	檢核C區的以下欄位必須有值:
				          事業名稱、A032_NAME
				          主要業務、A032_PRODUCT
				          統一編號、A032_ID
				          實收資本額(萬)、A032_REAL_CAPITAL
				          轉投資金額(萬)、A032_REINVEST_AMT
				          持股比例％	A032_HOLD_RATE
				12.1.2	檢核「持股比例％」輸入值  : IF  A032_HOLD_RATE  >  100，顯示錯誤訊息:‘持股比例有誤!’
				12.2	讀取畫面欄位資料
				12.3	資料檢核: 無
				12.4	資料處理: 無
				12.5	畫面顯示:
				12.5.1	該列資料欄位全部改為顯示欄位，選取欄位顯示RADIO
				12.5.2	儲存按鈕改為新增
				12.5.3	不必顯示訊息
				
				事業名稱、主要業務 -- 須為全形中文
				統一編號 -- 須為數字且符合統一編號檢核規則
				實收資本額(萬)、轉投資金額(萬)、持股比例％ -- 須為數字
			--%>
			var target_A023 = LIST23[mover];
			var NOW_ROW_SEQ_NO = target_A023["A023_SEQ_NO"];
			
	        //座落所在地、A023_ADDRESS
			var A023_ADDRESS = 'INPUT_' + 'A023_ADDRESS' + '_' +  NOW_ROW_SEQ_NO;
			var A023_ADDRESS_VALUE = $(A023_ADDRESS).value;
			if(isUnInput(A023_ADDRESS)) {
				setFalseCheck(A023_ADDRESS,'座落所在地必須有值!');
				A023List_ok = false;
			}
			
	        //建物門牌、A023_BUILD_DOOR
			var A023_BUILD_DOOR = 'INPUT_' + 'A023_BUILD_DOOR' + '_' +  NOW_ROW_SEQ_NO;
			var A023_BUILD_DOOR_VALUE = $(A023_BUILD_DOOR).value;
			if(isUnInput(A023_BUILD_DOOR)) {
				setFalseCheck(A023_BUILD_DOOR,'建物門牌必須有值!');
				A023List_ok = false;
			}
			
	        //地號(一)、A023_LAND_NO1
			var A023_LAND_NO1 = 'INPUT_' + 'A023_LAND_NO1' + '_' +  NOW_ROW_SEQ_NO;
			var A023_LAND_NO1_VALUE = $(A023_LAND_NO1).value;
			if(isUnInput(A023_LAND_NO1)) {
				setFalseCheck(A023_LAND_NO1,'地號(一)必須有值!');
				A023List_ok = false;
			}else {
				if(isNotANumber(A023_LAND_NO1)) {
					setFalseCheck(A023_LAND_NO1,'地號(一)必須為數值!');
					A023List_ok = false;
				}
			}			
			
	        //地號(二)、A023_LAND_NO2
			var A023_LAND_NO2 = 'INPUT_' + 'A023_LAND_NO2' + '_' +  NOW_ROW_SEQ_NO;
			var A023_LAND_NO2_VALUE = $(A023_LAND_NO2).value;
			if(isUnInput(A023_LAND_NO2)) {
				setFalseCheck(A023_LAND_NO2,'地號(二)必須有值!');
				A023List_ok = false;
			}else {
				if(isNotANumber(A023_LAND_NO2)) {
					setFalseCheck(A023_LAND_NO2,'地號(二)必須為數值!');
					A023List_ok = false;
				}
			}			
			
	        //建號(一)、A023_BUILD_NO1
			var A023_BUILD_NO1 = 'INPUT_' + 'A023_BUILD_NO1' + '_' +  NOW_ROW_SEQ_NO;
			var A023_BUILD_NO1_VALUE = $(A023_BUILD_NO1).value;
			if(isUnInput(A023_BUILD_NO1)) {
				setFalseCheck(A023_BUILD_NO1,'建號(一)必須有值!');
				A023List_ok = false;
			}else {
				if(isNotANumber(A023_BUILD_NO1)) {
					setFalseCheck(A023_BUILD_NO1,'建號(一)必須為數值!');
					A023List_ok = false;
				}
			}			
	        
	        //建號(二)	A023_BUILD_NO2
			var A023_BUILD_NO2 = 'INPUT_' + 'A023_BUILD_NO2' + '_' +  NOW_ROW_SEQ_NO;
			var A023_BUILD_NO2_VALUE = $(A023_BUILD_NO2).value;
			if(isUnInput(A023_BUILD_NO2)) {
				setFalseCheck(A023_BUILD_NO2,'建號(二)必須有值!');
				A023List_ok = false;
			}
			
			var A023_SET_AMT = 'INPUT_' + 'A023_SET_AMT' + '_' +  + NOW_ROW_SEQ_NO;
			var A023_SET_AMT_VALUE = $(A023_SET_AMT).value;
			if(isUnInput(A023_SET_AMT) == false) {
				if(isNotANumber(A023_SET_AMT)) {
					setFalseCheck(A023_SET_AMT,'設定情形-金額必須為數值!');
					A023List_ok = false;
				}
			}
			
			
			<%--
				長度檢核
				座落所在地	A023_ADDRESS
				建物門牌	A023_BUILD_DOOR
				地號(一)	A023_LAND_NO1
				地號(二)	A023_LAND_NO2
				建號(一)	A023_BUILD_NO1
				建號(二)	A023_BUILD_NO2
				設定情形-行庫	A023_SET_BANK
				設定情形-金額	A023_SET_AMT
			--%>
			var A023_SET_BANK = 'INPUT_' + 'A023_SET_BANK' + '_' +  + NOW_ROW_SEQ_NO;
			setLengthCheck('座落所在地',A023_ADDRESS,80);
			setLengthCheck('建物門牌',A023_BUILD_DOOR,60);
			setLengthCheck('地號(一)',A023_LAND_NO1,4);
			setLengthCheck('地號(二)',A023_LAND_NO2,4);
			setLengthCheck('建號(一)',A023_BUILD_NO1,5);
			setLengthCheck('建號(二)',A023_BUILD_NO2,3);
			setLengthCheck('設定情形-行庫',A023_SET_BANK,12);
			setLengthCheck('設定情形-金額',A023_SET_AMT,10,true);
		}
	}
	
	if( A031List_ok && A032List_ok && A023List_ok) {
	
		<%-- 23List --%>
		for(var mover=0; mover < LIST23.length ; mover++) {
			var target_A023 = LIST23[mover];
			var NOW_ROW_SEQ_NO = target_A023["A023_SEQ_NO"];
			var targetRowIndex = mover;
			
			var A023_ADDRESS = 'INPUT_' + 'A023_ADDRESS' + '_' +  NOW_ROW_SEQ_NO;
			var A023_ADDRESS_VALUE = $(A023_ADDRESS).value;

			var A023_BUILD_DOOR = 'INPUT_' + 'A023_BUILD_DOOR' + '_' +  NOW_ROW_SEQ_NO;
			var A023_BUILD_DOOR_VALUE = $(A023_BUILD_DOOR).value;

			var A023_LAND_NO1 = 'INPUT_' + 'A023_LAND_NO1' + '_' +  NOW_ROW_SEQ_NO;
			var A023_LAND_NO1_VALUE = $(A023_LAND_NO1).value;

			var A023_LAND_NO2 = 'INPUT_' + 'A023_LAND_NO2' + '_' +  NOW_ROW_SEQ_NO;
			var A023_LAND_NO2_VALUE = $(A023_LAND_NO2).value;

			var A023_BUILD_NO1 = 'INPUT_' + 'A023_BUILD_NO1' + '_' +  NOW_ROW_SEQ_NO;
			var A023_BUILD_NO1_VALUE = $(A023_BUILD_NO1).value;

			var A023_BUILD_NO2 = 'INPUT_' + 'A023_BUILD_NO2' + '_' +  NOW_ROW_SEQ_NO;
			var A023_BUILD_NO2_VALUE = $(A023_BUILD_NO2).value;
			
			//使用情形	A023_USE_STATUS	LAND_USE_STS_LIST	下拉選單
			var A023_USE_STATUS_VALUE = $('INPUT_' + 'A023_USE_STATUS' + '_' +  + NOW_ROW_SEQ_NO).value;
			//設定情形-行庫	A023_SET_BANK		輸入欄位
			var A023_SET_BANK_VALUE = $('INPUT_' + 'A023_SET_BANK' + '_' +  + NOW_ROW_SEQ_NO).value;		
			//設定情形-金額	A023_SET_AMT		輸入欄位
			var A023_SET_AMT_VALUE = getNumber('INPUT_' + 'A023_SET_AMT' + '_' +  + NOW_ROW_SEQ_NO);		
			
			
			LIST23[targetRowIndex]['A023_APPLY_ID'] = $('APPLY_ID').value;
			//座落所在地	A023_ADDRESS		輸入欄位
			LIST23[targetRowIndex]['A023_ADDRESS'] = A023_ADDRESS_VALUE;
			//建物門牌	A023_BUILD_DOOR		輸入欄位
			LIST23[targetRowIndex]['A023_BUILD_DOOR'] = A023_BUILD_DOOR_VALUE;
			//地號(一)	A023_LAND_NO1		輸入欄位
			LIST23[targetRowIndex]['A023_LAND_NO1'] = A023_LAND_NO1_VALUE;
			//地號(二)	A023_LAND_NO2		輸入欄位
			LIST23[targetRowIndex]['A023_LAND_NO2'] = A023_LAND_NO2_VALUE;
			//建號(一)	A023_BUILD_NO1		輸入欄位
			LIST23[targetRowIndex]['A023_BUILD_NO1'] = A023_BUILD_NO1_VALUE;
			//建號(二)	A023_BUILD_NO2		輸入欄位
			LIST23[targetRowIndex]['A023_BUILD_NO2'] = A023_BUILD_NO2_VALUE;
			//使用情形	A023_USE_STATUS	LAND_USE_STS_LIST	下拉選單
			LIST23[targetRowIndex]['A023_USE_STATUS'] = A023_USE_STATUS_VALUE;
			//設定情形-行庫	A023_SET_BANK		輸入欄位
			LIST23[targetRowIndex]['A023_SET_BANK'] = A023_SET_BANK_VALUE;
			//設定情形-金額	A023_SET_AMT		輸入欄位
			LIST23[targetRowIndex]['A023_SET_AMT'] = A023_SET_AMT_VALUE;
		}
	
	
		<%-- 32List --%>
		for(var mover=0; mover < LIST32.length ; mover++) {
			var target_A032 = LIST32[mover];
			var NOW_ROW_SEQ_NO = target_A032["A032_SEQ_NO"];
			var targetRowIndex = mover;
			
			var A032_NAME = 'INPUT_' + 'A032_NAME' + '_' +  NOW_ROW_SEQ_NO;
			var A032_NAME_VALUE = $(A032_NAME).value;

			var A032_PRODUCT = 'INPUT_' + 'A032_PRODUCT' + '_' +  NOW_ROW_SEQ_NO;
			var A032_PRODUCT_VALUE = $(A032_PRODUCT).value;

			var A032_ID = 'INPUT_' + 'A032_ID' + '_' +  NOW_ROW_SEQ_NO;
			var A032_ID_VALUE = $(A032_ID).value;
			
			var A032_RELATION = 'INPUT_A032_RELATION_' +  NOW_ROW_SEQ_NO;
			var A032_RELATION_VALUE = $(A032_RELATION).value;

			var A032_REAL_CAPITAL = 'INPUT_' + 'A032_REAL_CAPITAL' + '_' +  NOW_ROW_SEQ_NO;
			var A032_REAL_CAPITAL_VALUE = getNumber(A032_REAL_CAPITAL);

			var A032_REINVEST_AMT = 'INPUT_' + 'A032_REINVEST_AMT' + '_' +  NOW_ROW_SEQ_NO;
			var A032_REINVEST_AMT_VALUE = getNumber(A032_REAL_CAPITAL);

			var A032_HOLD_RATE = 'INPUT_' + 'A032_HOLD_RATE' + '_' +  NOW_ROW_SEQ_NO;
			var A032_HOLD_RATE_VALUE = getNumber(A032_HOLD_RATE);
			
			//序號	A032_SEQ_NO
			LIST32[targetRowIndex]['A032_APPLY_ID'] = $('APPLY_ID').value;
			//事業名稱	A032_NAME
			LIST32[targetRowIndex]['A032_NAME'] = A032_NAME_VALUE;
			//主要業務	A032_PRODUCT
			LIST32[targetRowIndex]['A032_PRODUCT'] = A032_PRODUCT_VALUE;
			//統一編號	A032_ID
			LIST32[targetRowIndex]['A032_ID'] = A032_ID_VALUE;
			//與關係企業關係	A032_RELATION
			LIST32[targetRowIndex]['A032_RELATION'] = A032_RELATION_VALUE;
			//實收資本額(萬)	A032_REAL_CAPITAL
			LIST32[targetRowIndex]['A032_REAL_CAPITAL']= A032_REAL_CAPITAL_VALUE;
			//轉投資金額(萬)	A032_REINVEST_AMT
			LIST32[targetRowIndex]['A032_REINVEST_AMT']= A032_REINVEST_AMT_VALUE;
			//持股比例％	A032_HOLD_RATE
			LIST32[targetRowIndex]['A032_HOLD_RATE'] = A032_HOLD_RATE_VALUE;
		}
	
	
		<%-- 31List --%>
		for(var mover=0; mover < LIST31.length ; mover++) {
			var target_A031 = LIST31[mover];
			var NOW_ROW_SEQ_NO = target_A031["A031_SEQ_NO"];
			var targetRowIndex = mover;
			
			var A031_NAME = 'INPUT_' + 'A031_NAME' + '_' +  NOW_ROW_SEQ_NO;
			var A031_NAME_VALUE = $(A031_NAME).value;

			var A031_TITLE = 'INPUT_' + 'A031_TITLE' + '_' + NOW_ROW_SEQ_NO;
			var A031_TITLE_VALUE = $(A031_TITLE).value;

			var A031_AGE = 'INPUT_' + 'A031_AGE' + '_' + NOW_ROW_SEQ_NO;
			var A031_AGE_VALUE = getNumber(A031_AGE);
			
			var A031_DEGREE_VALUE = $('INPUT_' + 'A031_DEGREE' + '_' +  NOW_ROW_SEQ_NO).value;

			var A031_SERV_YEAR = 'INPUT_' + 'A031_SERV_YEAR' + '_' + NOW_ROW_SEQ_NO;
			var A031_SERV_YEAR_VALUE = getNumber(A031_SERV_YEAR);
			
			var A031_HOLD_RATE = 'INPUT_' + 'A031_HOLD_RATE' + '_' + NOW_ROW_SEQ_NO;
			var A031_HOLD_RATE_VALUE = getNumber(A031_HOLD_RATE);
			
			var A031_EXPERIENCE_VALUE = $('INPUT_' + 'A031_EXPERIENCE' + '_' +  NOW_ROW_SEQ_NO).value;

		    //APPLY_ID    VARCHAR(11) NOT NULL
			LIST31[targetRowIndex]['A031_APPLY_ID'] = $('APPLY_ID').value;
		    //SEQ_NO  DECIMAL(2)  NOT NULL
		    //NAME    VARCHAR(60) 
			LIST31[targetRowIndex]['A031_NAME'] = A031_NAME_VALUE;
		    //TITLE   VARCHAR(20) 
			LIST31[targetRowIndex]['A031_TITLE'] = A031_TITLE_VALUE;
		    //AGE DECIMAL(3)  
			LIST31[targetRowIndex]['A031_AGE'] = A031_AGE_VALUE;
		    //DEGREE  VARCHAR(10) 
			LIST31[targetRowIndex]['A031_DEGREE'] = A031_DEGREE_VALUE;
		    //SERV_YEAR   DECIMAL(3)  
			LIST31[targetRowIndex]['A031_SERV_YEAR'] = A031_SERV_YEAR_VALUE;
		    //HOLD_RATE   DECIMAL(6,3)    
			LIST31[targetRowIndex]['A031_HOLD_RATE'] = A031_HOLD_RATE_VALUE;
		    //EXPERIENCE  VARCHAR(100)                
			LIST31[targetRowIndex]['A031_EXPERIENCE'] = A031_EXPERIENCE_VALUE;
		}	
	}
}


















//-->
</script>
</head>

<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0"
	marginwidth="0" marginheight="0">
	.
	<form name="form1" id="form1" method="post"
		enctype="multipart/form-data">
		<%--[20191224]新增form --%>
		<table width="100%" border="0" cellpadding="0" cellspacing="1"
			class="tbBox2">
			<tr>
				<td width="14%" class="tbYellow">受理編號</td>
				<td class="tbYellow2" colspan="2"><input ID="APPLY_ID"
					name="APPLY_ID" type="text" size="15" maxlength="11"
					class="textBox2" value=""> <!--  90000000000 --></td>

				<td width="26%" class="tbYellow2" align="center"><input
					ID="btnQuery" name="btnQuery" onClick="doQuery()" type="button"
					class="button" value="查詢" /></td>
			</tr>
			<tr>
				<td colspan="5" align="center"><input ID="btnClear"
					name="btnClear" onClick="doClear_A()" type="button" class="button"
					value="清除"> <input id="blockA_insert" name="blockA_insert"
					onClick="insert_BlockA()" type="button" class="button" value="新增">
					<input id="blockA_update" name="blockA_update"
					onClick="update_BlockA()" type="button" class="button" value="修改">
					<input id="blockA_delete" name="blockA_delete"
					onClick="delete_BlockA()" type="button" class="button" value="刪除">

					<!-- 
				受理進度					APPLY_PROCESS	rtnMap.APPLY_PROCESS	隱藏欄位
				輸入人員ID (受理主檔)	A010_INPUT_ID	rtnMap.A010_INPUT_ID	隱藏欄位
				徵信人員ID				CRED_ID	rtnMap.CRED_ID	隱藏欄位
			 --> <input type="HIDDEN" ID="APPLY_PROCESS" NAME="APPLY_PROCESS">
					<input type="HIDDEN" ID="A010_INPUT_ID" NAME="A010_INPUT_ID">
					<input type="HIDDEN" ID="CRED_ID" NAME="CRED_ID"> <input
					type="HIDDEN" ID="OLD_APPLY_ID" NAME="OLD_APPLY_ID"> <input
					type="HIDDEN" ID="APPLY_PROCESS_NM" NAME="APPLY_PROCESS_NM">
				</td>
			</tr>
		</table>


		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td>
					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2">
						<tr>
							<%-- 
						受理編號	APPLY_ID	畫面上的受理編號	文字輸入欄位，長度11
						受理編號	OLD_APPLY_ID	rtnMap.APPLY_ID	顯示欄位
						受理進度	APPLY_PROCESS_NM	rtnMap.APPLY_PROCESS_NM	顯示欄位
					--%>
							<td width="13%" class="tbYellow">受理編號</td>
							<td width="38%" class="tbYellow2" colspan="3">
								<%--[20191224]欄位格式修改 --%> <SPAN ID="SHOW_OLD_APPLY_ID" />
							</td>
							<td width="14%" class="tbYellow">受理進度</td>
							<td width="30%" class="tbYellow2"><SPAN
								ID="SHOW_APPLY_PROCESS_NM" /></td>
						</tr>
						<tr>
							<%-- 
						名稱(中文)	CNAME	rtnMap.CNAME	文字輸入欄位，長度26
						名稱(英文)	ENAME	rtnMap.ENAME	文字輸入欄位，長度26
						成立日期	BUILD_DATE	rtnMap.BUILD_DATE	日期欄位,亦可透過日曆模式點選日期
						營利事業統一編號	ID	rtnMap.ID	文字輸入欄位，長度10
					--%>
							<td rowspan="2" class="tbYellow">名稱</td>
							<td class="tbYellow2" colspan="3">
								<%--[20191224]欄位格式修改 --%> （中文）<input type="text" size="35"
								maxlength="40" ID="CNAME" name="CNAME" class="textBox2" alt="ch"/><%--[20240723]難字調整 --%>
							</td>
							<td class="tbYellow">成立日期</td>
							<td class="tbYellow2"><input type="text" ID="BUILD_DATE"
								name="BUILD_DATE" datatype="ROCDate" class="textBox2" size="10"
								maxlength="8"> <img class="img"
								src="<%=imageBase%>/CM/calendar.gif" width="20" height="20"
								onClick="getCalendarFor($('BUILD_DATE'))"></td>
						</tr>
						<tr>
							<td class="tbYellow2" colspan="3">
								<%--[20191224]欄位格式修改 --%> （英文）<input type="text" size="35"
								maxlength="40" ID="ENAME" name="ENAME" class="textBox2">
							</td>
							<td class="tbYellow">統一編號</td>
							<td class="tbYellow2"><input type="text" ID="ID" name="ID"
								size="10" maxlength="10" class="textBox2"></td>
						</tr>

						<tr>
							<%-- 
						負責人	CHIEF	rtnMap.CHIEF	文字輸入欄位，長度60
						員工人數	EMP_NUM	rtnMap.EMP_NUM	數字格式輸入欄位,
						無資料預設為0
					--%>
							<td class="tbYellow">負責人</td>
							<td class="tbYellow2" colspan="3">
								<%--[20191224]欄位格式修改 --%> <input type="text" ID="CHIEF"
								name="CHIEF" class="textBox2" size="12" maxlength="60" alt="ch"/><%--[20240723]難字調整 --%>
							</td>
							<td class="tbYellow">員工人數</td>
							<td class="tbYellow2"><input type="text" datatype="number"
								pattern="#,###.###" ID="EMP_NUM" name="EMP_NUM" class="textBox2"
								size="8" maxlength="8">人</font></td>
						</tr>
						<tr>
							<%-- 
						地址(公司)	COP_ADDR	rtnMap.COP_ADDR	文字輸入欄位，長度26
						電話-區碼(公司)	COP_TEL_AREA	rtnMap.COP_TEL_AREA	數字格式輸入欄位
						電話(公司)	COP_TEL_NUM	rtnMap.COP_TEL_NUM	數字格式輸入欄位
						電話-分機(公司)	COP_TEL_EXT	rtnMap.COP_TEL_EXT	數字格式輸入欄位
					--%>
							<td rowspan="2" class="tbYellow">地址</td>
							<td class="tbYellow2" colspan="3">
								<%--[20191224]欄位格式修改 --%> （公司）<input type="text"
								class="textBox2" ID="COP_ADDR" name="COP_ADDR" size="26"
								maxlength="80" alt="ch"/><%--[20240723]難字調整 --%>
							</td>
							<td rowspan="2" class="tbYellow">電話</td>
							<td class="tbYellow2">
								<%-- 
						(<input type="text" ID="COP_TEL_AREA" name="COP_TEL_AREA" size="2" class="texttype1" >)
					  	--%> <select name="COP_TEL_AREA" id="COP_TEL_AREA"
								class="textBox2">
									<option value="" selected>(區碼)</option>
									<c:forEach var="costRpt" items="${COP_TEL_AREA_LIST}">
										<option value="${costRpt.value}">${costRpt.key}</option>
									</c:forEach>
							</select> <input type="text" ID="COP_TEL_NUM" name="COP_TEL_NUM" size="10"
								maxlength="10" class="textBox2"> <font size="2">#</font>
								<input type="text" class="textBox2" ID="COP_TEL_EXT"
								name="COP_TEL_EXT" size="4">
							</td>
						</tr>
						<tr>
							<%-- 
						地址(工廠)	FAC_ADDR	rtnMap.FAC_ADDR	文字輸入欄位，長度26
						電話-區碼(工廠)	FAC_TEL_AREA	rtnMap.FAC_TEL_AREA	數字格式輸入欄位
						電話(工廠)	FAC_TEL_NUM	rtnMap.FAC_TEL_NUM	數字格式輸入欄位
						電話-分機(工廠)	FAC_TEL_EXT	rtnMap.FAC_TEL_EXT	數字格式輸入欄位
					--%>
							<td class="tbYellow2" colspan="3">
								<%--[20191224]欄位格式修改 --%> （工廠）<input type="text"
								class="textBox2" ID="FAC_ADDR" name="FAC_ADDR" size="26"
								maxlength="80" alt="ch"/><%--[20240723]難字調整 --%>
							</td>
							<td class="tbYellow2" colspan="3">
								<%--[20191224]欄位格式修改 --%> <%-- 
							(<input type="text" ID="FAC_TEL_AREA" name="FAC_TEL_AREA" size="2" class="texttype1" >)
							--%> <select name="FAC_TEL_AREA" id="FAC_TEL_AREA"
								class="textBox2">
									<option value="" selected>(區碼)</option>
									<c:forEach var="costRpt" items="${FAC_TEL_AREA_LIST}">
										<option value="${costRpt.value}">${costRpt.key}</option>
									</c:forEach>
							</select> <input type="text" ID="FAC_TEL_NUM" name="FAC_TEL_NUM" size="10"
								maxlength="10" class="textBox2"> <font size="2">#</font>
								<input type="text" ID="FAC_TEL_EXT" name="FAC_TEL_EXT"
								class="textBox2" size="4">
							</td>
						</tr>
						<tr>
							<%-- 
							登記資本額	CAPITAL	rtnMap.CAPITAL	數字格式輸入欄位
							實收資本額	REAL_CAPITAL	rtnMap.REAL_CAPITAL	數字格式輸入欄位
					  --%>
							<td class="tbYellow">登記資本額</td>
							<td class="tbYellow2" colspan="3">
								<%--[20191224]欄位格式修改 --%> <input type="text" ID="CAPITAL"
								name="CAPITAL" datatype="number" pattern="#,###.###"
								class="textBox2" size="15" maxlength="14">萬
							</td>
							<td class="tbYellow">實收資本額</td>
							<td class="tbYellow2"><input type="text" ID="REAL_CAPITAL"
								name="REAL_CAPITAL" datatype="number" pattern="#,###.###"
								class="textBox2" size="11" maxlength="14">萬</td>
						</tr>
						<tr>
							<%-- 
							主要業務及產品	PRODUCT	rtnMap.PRODUCT	文字輸入欄位，長度50
							主要銷售對象	MARKET	rtnMap.MARKET	文字輸入欄位，長度50
						--%>
							<td class="tbYellow">主要業務及產品</td>
							<td class="tbYellow2" colspan="3"><input type="text"
								class="textBox2" ID="PRODUCT" name="PRODUCT" size="50"
								maxlength="100"></td>
							<%--[20191224]新增欄位--%>
							<td class="tbYellow"><span class="isCORP_DEPT">是否為集團<span></td>
							<td class="tbYellow2">
								<div class="isCORP_DEPT">
									<c:forEach var="map" items="${YES_NO_LIST}">
										<input type="radio" name="IS_GROUP" id="IS_GROUP_${map.key}"
											value="${map.key}" />
										<label for="IS_GROUP_${map.key}">${map.value}</label>
									</c:forEach>
								</div>
							</td>
						</tr>
						<tr>
							<td class="tbYellow">主要銷售對象</td>
							<td class="tbYellow2" colspan="3"><input type="text"
								class="textBox2" ID="MARKET" name="MARKET" size="50"
								maxlength="100"></td>
							<%--[20191224]新增欄位--%>
							<td class="tbYellow"><span class="isCORP_DEPT">集團名稱<span></td>
							<td class="tbYellow2"><input id="GROUP_NAME"
								name="GROUP_NAME" class="textBox2 isCORP_DEPT" alt="ch"/><%--[20240723]難字調整 --%></td>
						</tr>
						<tr>
							<!-- 
						銷售方式(內銷)	IN_SALE_RATE	rtnMap.IN_SALE_RATE	數字格式輸入欄位,
						無資料預設為0
						銷售方式(外銷)	OUT_SALE_RATE	rtnMap.OUT_SALE_RATE	數字格式輸入欄位,
						無資料預設為0
					   -->
							<td class="tbYellow">銷售方式</td>
							<td class="tbYellow2" colspan="3">
								<%--[20191224]欄位格式修改 --%> 內銷<input type="text" datatype="number"
								pattern="#,###.###" id="IN_SALE_RATE" name="IN_SALE_RATE"
								size="5" maxlength="6">&nbsp;％&nbsp;&nbsp; 外銷<input
								type="text" datatype="number" pattern="#,###.###"
								id="OUT_SALE_RATE" name="OUT_SALE_RATE" size="5" maxlength="6">&nbsp;％

							</td>
							<!-- 
						產業別	TERRITORY	rtnMap.TERRITORY	文字輸入欄位，長度15
						 -->
							<td class="tbYellow">產業別</td>
							<td class="tbYellow2">
								<%--[20191224]改為下拉選單 --%> <select name="TERRITORY"
								id="TERRITORY" class="textBox2">
									<option value="" selected>請選擇</option>
									<c:forEach var="map" items="${A030_TERRITORY_LIST}">
										<option value="${map.key}">${map.value}</option>
									</c:forEach>
							</select>
							</td>
						</tr>
						<%--[20191224]新增欄位--%>
						<tr>
							<td class="tbYellow"><span class="isCORP_DEPT">集團等級<span></td>
							<td class="tbYellow2"><select name="GROUP_LVL"
								id="GROUP_LVL" class="textBox2 isCORP_DEPT" title="集團等級">
									<option value="" selected>請選擇</option>
									<c:forEach var="map" items="${GROUP_LEVEL_LIST}">
										<option value="${map.key}">${map.value}</option>
									</c:forEach>
							</select></td>
							<td class="tbYellow"><span class="isCORP_DEPT">信用評等<span></td>
							<td class="tbYellow2"><select name="CRED_RATE"
								id="CRED_RATE" class="textBox2 isCORP_DEPT" title="信用評等">
									<option value="" selected>請選擇</option>
									<c:forEach var="map" items="${A030_CRED_RATE_LIST}">
										<option value="${map.key}">${map.value}</option>
									</c:forEach>
							</select></td>
							<td class="tbYellow"><span class="isCORP_DEPT">股票型態<span></td>
							<td class="tbYellow2"><select name="STOCK_TYPE"
								id="STOCK_TYPE" class="textBox2 isCORP_DEPT" title="股票型態">
									<option value="">請選擇</option>
									<c:forEach var="map" items="${STOCK_TYPE_LIST}">
										<option value="${map.key}"
											<c:if test='${map.key eq "5"}'>selected</c:if>>${map.value}</option>
									</c:forEach>
							</select></td>
						</tr>
						<!-- [20200907] 新增欄位 -->
						<tr>
							<!-- 					集團及其他法人機構尚可投資金額	授信額度			檢核結果(集團)		本公司調整後淨值 -->
							<!-- 					GROUP_INVEST_AMT				CREDIT_AMT		CHECK_GROUP_NM		OWNERSHIP -->
							<td class="tbYellow"><span class="isCORP_DEPT">集團及其他法人機構尚可投資金額<span></td>
							<td class="tbYellow2"><input id="GROUP_INVEST_AMT"
								name="GROUP_INVEST_AMT" class="textBox2 isCORP_DEPT" maxlength='18'
								datatype="number" pattern="#,###.###" /></td>
							<td class="tbYellow"><span class="isCORP_DEPT">授信額度<span></td>
							<td class="tbYellow2"><input id="CREDIT_AMT"
								name="CREDIT_AMT" class="textBox2 isCORP_DEPT" maxlength='18' datatype="number"
								pattern="#,###.###" /></td>
							<td class="tbYellow"><span class="isCORP_DEPT">檢核結果(集團)<span></td>
							<td class="tbYellow2"><input type="text" hidden
								id="hCHECK_GROUP_NM" name="hCHECK_GROUP_NM"
								class="textBox2 isCORP_DEPT" /> <SPAN ID="CHECK_GROUP_NM"
								class="isCORP_DEPT" /></td>
						</tr>
						<tr>
							<!-- 					國家尚可投資金額					國家限額-國家名稱		檢核結果(國家)	 -->
							<!-- 					COUNTRY_INVEST_AMT				COUNTRY					CHECK_COUNTRY_NM -->
							<td class="tbYellow"><span class="isCORP_DEPT">國家尚可投資金額<span></td>
							<td class="tbYellow2"><input id="COUNTRY_INVEST_AMT"
								name="COUNTRY_INVEST_AMT" class="textBox2 isCORP_DEPT" maxlength='18'
								datatype="number" pattern="#,###.###" /></td>
							<td class="tbYellow"><span class="isCORP_DEPT">國家限額-國家名稱<span></td>
							<td class="tbYellow2"><input type="text" id="COUNTRY_NM"
								name="COUNTRY_NM" size="40" maxlength="40" /> <input
								type="hidden" id="COUNTRY" name="COUNTRY" /></td>
							<td class="tbYellow"><span class="isCORP_DEPT">檢核結果(國家)<span></td>
							<td class="tbYellow2"><input type="text" hidden
								id="hCHECK_COUNTRY_NM" name="hCHECK_COUNTRY_NM"
								class="textBox2 isCORP_DEPT" /> <SPAN ID="CHECK_COUNTRY_NM"
								class="isCORP_DEPT" /></td>
						</tr>
						<tr>
							<td class="tbYellow"><span class="isCORP_DEPT">本公司調整後淨值<span></td>
							<td class="tbYellow2" colspan="5"><SPAN ID="OWNERSHIP"
								class="isCORP_DEPT" pattern="#,###.##" /></td>
						</tr>
						<tr>
							<td colspan='6'><font size="2" color='red'>註：尚可投資金額及授信額度單位均為新台幣(元)，請與風管一部確認尚可投資金額及本公司調整後淨值資料</font>
							</td>
						</tr>
					</table> <%-- 
=====主要董監事 B 區=====
--%>

					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2">
						<tr align="center" class="tbYellow0">
							<td colspan="8" class="textBold">主要董監事</td>
						</tr>

						<tr bgcolor=#FFFFFF>
							<td>
								<table width="100%" border="0" cellpadding="0" cellspacing="1"
									class="tbBox2" id="block_B" name="block_B">
								</table>

							</td>
						</tr>
						<tr>
							<td class="tbYellow2">
								<p align="center">
									<input id="blockB_insert" name="blockB_insert"
										onClick="insert_BlockB()" type="button" class="button"
										value="新增"> <input id="blockB_delete"
										name="blockB_delete" onClick="delete_BlockB()" type="button"
										class="button" value="刪除">
								</p>
							</td>
						</tr>
					</table> <%-- 
=====投資事業概況C 區=====
--%>
					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2">
						<tr align="center" class="tbYellow0">
							<td colspan="8" class="textBold">投資事業概況</td>
						</tr>

						<tr bgcolor=#FFFFFF>
							<td>
								<table width="100%" border="0" cellpadding="0" cellspacing="1"
									class="tbBox2" id="block_C" name="block_C">
								</table>
							</td>
						</tr>
						<tr>
							<td class="tbYellow2">
								<p align="center">
									<input id="blockC_insert" name="blockC_insert"
										onClick="insert_BlockC()" type="button" class="button"
										value="新增"> <input id="blockC_delete"
										name="blockC_delete" onClick="delete_BlockC()" type="button"
										class="button" value="刪除">
								</p>
							</td>
						</tr>
					</table> <%-- 
=====不動產明細（請填寫擔保品以外之其它不動產）=====
--%>
					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2">
						<tr align="center" class="tbYellow0">
							<td colspan="8" class="textBold">不動產明細（請填寫擔保品以外之其它不動產）</td>
						</tr>

						<tr bgcolor=#FFFFFF>
							<td colspan="6">
								<table width="100%" border="0" cellpadding="0" cellspacing="1"
									class="tbBox2" id="block_D" name="block_D">
								</table>
							</td>
						</tr>
						<tr>
							<td class="tbYellow2" colspan="6">
								<p align="center">
									<input id="blockD_insert" name="blockD_insert"
										onClick="insert_BlockD()" type="button" class="button"
										value="新增"> <input id="blockD_delete"
										name="blockD_delete" onClick="delete_BlockD()" type="button"
										class="button" value="刪除">
								</p>
							</td>
						</tr>
					</table> <%-- 
=====[20191224] 新增【股權結構】區域(F區)=====
--%>
					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2 isCORP_DEPT" id="block_F">
						<tr align="center" class="tbYellow0">
							<td class="textBold">股權結構
								<button class="button" type="button" id="btn_calculate"
									name="btn_calculate">試算</button>
								<button class="button" type="button" id="btn_exportTreeChart"
									name="btn_exportTreeChart">股權結構圖產出</button>
							</td>
						</tr>
						<tr align="center" class="tbYellow0">
							<td><input type="hidden" id="uploadReqMap"
								name="uploadReqMap" />
								<div style="display: inline-block">
									<span>上傳股權結構圖</span> <span> <input type="file"
										class="textBox2" id="UPLD_FILE" name="UPLD_FILE" />
									</span>
									<button class="button" type="button" id="btn_upload"
										name="btn_upload">上傳</button>
									<div style="display: inline-block">
										<input type="hidden" id="FILE_SER_NO" name="FILE_SER_NO" />
										<%--檔案序號 --%>
										<input type="hidden" id="FILE_PATH" name="FILE_PATH" />
										<%--檔案路徑 --%>
										<a id="FILE_NAME" href="javascript:void(0)"></a>
										<button class="button" type="button" id="btn_deleteFile"
											name="btn_deleteFile">刪除</button>
										<iframe id="importFrame" name="importFrame" width="0"
											height="0"></iframe>
										<%-- 上傳檔案處理用 iframe--%>
									</div>
								</div></td>
						</tr>
					</table>
					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2 isCORP_DEPT">
						<tr align="center" class="tbYellow0">
							<td class="textBold">第一層</td>
						</tr>
						<tr>
							<td class="tbYellow2">
								<table width="100%" border="0" cellpadding="0" cellspacing="1"
									class="tbBox2" id="blockF_1"></table>
							</td>
						</tr>
						<tr align="center" class="tbYellow2">
							<td>
								<button class="button" type="button" id="blockF_1_insert"
									name="blockF_1_insert">新增</button>
								<button class="button" type="button" id="blockF_1_delete"
									name="blockF_1_delete">刪除</button>
							</td>
						</tr>
					</table>
					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2 isCORP_DEPT">
						<tr align="center" class="tbYellow0">
							<td class="textBold">第二層</td>
						</tr>
						<tr>
							<td class="tbYellow2">
								<table width="100%" border="0" cellpadding="0" cellspacing="1"
									class="tbBox2" id="blockF_2"></table>
							</td>
						</tr>
						<tr align="center" class="tbYellow2">
							<td>
								<button class="button" type="button" id="blockF_2_insert"
									name="blockF_2_insert">新增</button>
								<button class="button" type="button" id="blockF_2_delete"
									name="blockF_2_delete">刪除</button>
							</td>
						</tr>
					</table>
					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2 isCORP_DEPT">
						<tr align="center" class="tbYellow0">
							<td class="textBold">第三層</td>
						</tr>
						<tr>
							<td class="tbYellow2">
								<table width="100%" border="0" cellpadding="0" cellspacing="1"
									class="tbBox2" id="blockF_3"></table>
							</td>
						</tr>
						<tr align="center" class="tbYellow2">
							<td>
								<button class="button" type="button" id="blockF_3_insert"
									name="blockF_3_insert">新增</button>
								<button class="button" type="button" id="blockF_3_delete"
									name="blockF_3_delete">刪除</button>
							</td>
						</tr>
					</table>
					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2 isCORP_DEPT">
						<tr align="center" class="tbYellow0">
							<td class="textBold">第四層</td>
						</tr>
						<tr>
							<td class="tbYellow2">
								<table width="100%" border="0" cellpadding="0" cellspacing="1"
									class="tbBox2" id="blockF_4"></table>
							</td>
						</tr>
						<tr align="center" class="tbYellow2">
							<td>
								<button class="button" type="button" id="blockF_4_insert"
									name="blockF_4_insert">新增</button>
								<button class="button" type="button" id="blockF_4_delete"
									name="blockF_4_delete">刪除</button>
							</td>
						</tr>
					</table>
					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2 isCORP_DEPT">
						<tr align="center" class="tbYellow0">
							<td class="textBold">第五層</td>
						</tr>
						<tr>
							<td class="tbYellow2">
								<table width="100%" border="0" cellpadding="0" cellspacing="1"
									class="tbBox2" id="blockF_5"></table>
							</td>
						</tr>
						<tr align="center" class="tbYellow2">
							<td>
								<button class="button" type="button" id="blockF_5_insert"
									name="blockF_5_insert">新增</button>
								<button class="button" type="button" id="blockF_5_delete"
									name="blockF_5_delete">刪除</button>
							</td>
						</tr>
					</table>
					<table width="100%" border="0" cellpadding="0" cellspacing="1"
						class="tbBox2 isCORP_DEPT">
						<tr align="center" class="tbYellow0">
							<td class="textBold">股東持股比例計算</td>
						</tr>
						<tr>
							<td class="tbYellow2">
								<table width="100%" border="0" cellpadding="0" cellspacing="1"
									class="tbBox2" id="blockF_6"></table>
							</td>
						</tr>
						<tr align="center" class="tbYellow2">
							<td>
								<button class="button" type="button" id="blockF_6_insert"
									name="blockF_6_insert">新增</button>
								<button class="button" type="button" id="blockF_6_delete"
									name="blockF_6_delete">刪除</button>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1"
			class="tbBox2">
			<tr>
				<td width="11%" class="tbYellow">輸入人員</td>
				<td class="tbYellow2"><span name='SHOW_INPUT_NAME'
					id='SHOW_INPUT_NAME' style="font-family:'EUDC'"></span><%--[20240723]難字調整 --%></td>
				<td width="13%" class="tbYellow">輸入日期</td>
				<td width="43%" class="tbYellow2"><SPAN NAME='SHOW_INPUT_DATE'
					ID='SHOW_INPUT_DATE' /></td>
			</tr>
		</table>
	</form>
</body>
</html>

