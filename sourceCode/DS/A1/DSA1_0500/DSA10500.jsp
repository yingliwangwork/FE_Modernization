<%--

	[20210311] 修改件
    1.新增銀行件修改功能，僅可修改移轉年月、前次移轉現值、使用分區。可複製修改內容再修改
    
    [20210323] 問題單 20210323101940
 	1.銀行件修改僅能修改主要用途、附屬建物/層數、建築完成日
	2.若為銀行件，建物樓層資料及建物所有權人新增和刪除按鈕反灰
	3.若不為銀行件，建物樓層資料及建物所有權人新增和刪除按鈕正常
	
	[20210325] 問題單 20210325133132
	1.需求變更:主要用途不可修改
    
    --%>
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource"/>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script src="<%=htmlBase%>/CM/js/date.js"></script>
<script src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script src="<%=htmlBase%>/CM/js/utility.js"></script>
<script src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/Validation.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>
<%--[20240722]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


var SEQUENCE_NUMBER_COLUMN = "sequenceNumber";
var rtnList = null;
var A051List= null;
var A052List= null;
var rtnMap= null;
var rtnA050Map= null;
var B_grid=null;
var B_lastRow;
var OLD_FINISH_DATE=null;
var recordForCheckFast = null;<%--[20210311]方便快速檢核欄位是否有異動--%>

var validate4define;

function initApp(){

	cleanMsgBoard();
	displayMessage();
	buttonAuth();
	PageUI.createPageWithAllBodySubElement("DSA10500" , "受理作業" , "建物謄本輸入", 1, '${param.titleNotDisplay}' == 'Y');
	new UI().init();
	
	fix();
	constructRows_BlockD('D_grid',null);
	constructRows_BlockE('E_grid',null);
	autoFormatToNumber();
	autoFormatToDate();
	
	validate4define = new Validation("body", {useTitles:true, focusOnError:false, immediate:false});
	Validation.addAllThese([
		[ 'customize_returnFalse', '請自訂訊息',
			function(obj){
				return false;
			}
		]
	]);
	
	
	PageUI.resize(true);
	
	if ('${APPLY_ID}' != "") {
		$('APPLY_ID').value = '${APPLY_ID}';
	} else { 
		//保留參數管理-取得受理編號
		$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
	}			
	if($('APPLY_ID').value!=''){
		doQuery();
	}
	
	<%--[20210311]新增按鈕[銀行件修改]--%>
	$('btn_update_for_bank').observe('click', buttons.doUpdateForBank);
}

var btn_insert = false;
var btn_delete = false;
var btn_update = false;
var btn_updateIDBtn = false;
var btn_clear = false;
var btn_cancel = false;
var btn_buildingImageBtn = false;
var btn_query = true;
var btn_tearDownImage = false;
var btn_reject = false;

function buttonAuth(){
	<%--
		2.	查詢(B0001)	6
		4.	新增(B0003)	11
		5.	刪除(B0005)	12
		6.	修正(B0004)	13
		7.	修正建號(B0032)	14
		
		9.	退回(B0008)	15
		10.	取消取件(B0023)	16
		11.	建物謄本影像(B0033)	17
		12.	拆件影像(B0025)	17
		
		13.	新增(D區)(B0002)	17
		15.	刪除(D區)(B0003)	19
		16.	修改(D區)(B0004)	20
		17.	新增(E區)(B0002)	20
		19.	刪除(E區)(B0003)	21
		20.	修改(E區)(B0004)	21
	--%>
//buttons
	var authButtons = {
//			B0001:"queryBtn<%--查詢--%>",
			B0003:"insertBtn<%--新增--%>",
			B0005:"deleteBtn<%--刪除--%>",
			B0004:"updateBtn<%--修改--%>",
			B0032:"updateIDBtn<%--修正建號--%>",
			B0008:"rejectBtn<%--退回--%>",
			B0023:"cancelBtn<%--取消取件--%>",
			B0033:"buildingImageBtn<%--建物謄本影像--%>",
			B0025:"tearDownImageBtn<%--拆件影像--%>"
	};
	<dz:grantButtons FUNC_ID="DSA10500" ignored="false"/>
	
	btn_insert = ($('insertBtn').disabled == false ? true : false);
	btn_delete = ($('deleteBtn').disabled == false ? true : false);
	btn_update = ($('updateBtn').disabled == false ? true : false);
	
	btn_updateIDBtn = ($('updateIDBtn').disabled == false ? true : false);
	btn_clear = ($('clearBtn').disabled == false ? true : false);
	btn_cancel = ($('cancelBtn').disabled == false ? true : false);

	btn_buildingImageBtn = ($('buildingImageBtn').disabled == false ? true : false);
	btn_tearDownImage = ($('tearDownImageBtn').disabled == false ? true : false);
	btn_query = ($('queryBtn').disabled == false ? true : false);
	btn_reject = ($('rejectBtn').disabled == false ? true : false);
}

var buttons = {
		doUpdateForBank: function(){<%--[20210311] 銀行件修改--%>
			if($F('APPLY_ID') != $F('OLD_APPLY_ID')) {
				alert("欲修改的受理編號與原先查詢的資料不同，無法作業!");
				return ;
			}
		
			<%--[20210311]僅可修改主要建材、主要用途、附屬建物名稱、建築完成日，須檢和其他欄位不可修改--%>
			<%--[20210323]需求變更:銀行件修改僅能修改主要用途、附屬建物/層數、建築完成日--%>
			<%--[20210325]需求變更:銀行件修改僅能修改附屬建物/層數、建築完成日--%>
			var fixedFieldC = [];
			$$('tr.block_c').forEach(function(input){
				input.select('input[type="text"]', 'select').forEach(function(it){
					it.removeClassName('m_validator-failed');
					if (!['FINISH_DATE'].include(it.name) && !['ADDR_NO'].include(it.name)) {
						if(recordForCheckFast[it.name] != it.value){
							fixedFieldC.push(it);
						}
						
					} 
				});
				input.select('input[type="radio"]').forEach(function(it){
					it.removeClassName('m_validator-failed');
					if (it.checked && recordForCheckFast[it.name] != it.value) {
						fixedFieldC.push(it);
					} 
				});
			});
			<%--[20210323]
				需求變更:
				1.層次可改層數(ITEM)
				2.除層次以外不可改附屬建號1、附屬建號2(AUX_NO1, AUX_NO2)
			--%>
			var isFloor = false;
			var fixedFieldD = $('D_grid').select('input[type="text"]', 'select').filter(function(it){
				var data_id = it.id;
				data_id = data_id.substring(0, data_id.length - 2);
				var tagName = it.tagName.toLowerCase();
				if (tagName == 'select'){
					isFloor = it.value == '1';
				}
				if (isFloor) {<%--層次下拉可改ITEM--%>
					return ['MEASURE_INPUT', 'HOLD_BASE_INPUT', 'HOLD_UP_INPUT'].include(data_id) && recordForCheckFast[it.id] != it.value;
				} else {<%--其他下拉不可改AUX_NO1, AUX_NO2--%>
					return ['AUX_NO1_INPUT', 'AUX_NO2_INPUT', 'MEASURE_INPUT', 'HOLD_BASE_INPUT', 'HOLD_UP_INPUT'].include(data_id) && recordForCheckFast[it.id] != it.value;
				}
			});
			var fixedFieldE = $('E_grid').select('input[type="text"]', 'select').filter(function(it){
				it.removeClassName('m_validator-failed');
				if(it.id.include('NAME_INPUT')){
					return false;					
				}else{
					return recordForCheckFast[it.id] != it.value;
				}
			});
			
			if (fixedFieldC.length > 0 || fixedFieldD.length > 0 || fixedFieldE.length > 0) {
				fixedFieldC.forEach(function(it) {
					it.addClassName('m_validator-failed');
				});
				fixedFieldD.forEach(function(it) {
					it.addClassName('m_validator-failed');
				});
				fixedFieldE.forEach(function(it) {
					it.addClassName('m_validator-failed');
				});
				alert('僅可修改附屬建物/層數、建築完成日');
				return;
			}
			
			if (!updateValid(true)){<%--[20210318]SA追加檢核:銀行件時先不要檢核建號相關--%>
				return;
			}
			
			<%--
				[20210311] 銀行件修改
			    10.2.1 將畫面資料(C區)存成A050vo、(D區)存成A051voList、(E區)存成A052voList
                10.2.2 另將畫面資料rtnMap存成mapA如下:
					OLD_APPLY_ID  畫面上的受理編號
					APPLY_PROCESS	畫面上的受理進度(隱藏欄位)
					CRED_ID	畫面上的徵信人員ID(隱藏欄位)
					CAPT_DATE	畫面上的組長覆核日期(隱藏欄位)
					BUILD_NO1	畫面上的建號1
					BUILD_NO2	畫面上的建號2
					INPUT_ID	畫面上的建檔人員
					MATERIAL	畫面上的主要建材
					MAIN_USE	畫面上的主要用途
					2Q_PERSON	是否為2Q作業人員
					OLD_BUILD_NO1	修改前建號(主建物建號)1(隱藏欄位)
					OLD_BUILD_NO2	修改前建號(主建物建號)2(隱藏欄位)
                
			--%>
			new Ajax.Request("<%=dispatcher%>/DSA1_0500/updateForBank", 
					{
							parameters:{'A050vo' : getA050(),
										'A051List' : Object.toJSON(A051List),
										'A052List' : Object.toJSON(A052List),
										'APPLY_ID' : $F('APPLY_ID'),
										'mapA': Object.toJSON({
											OLD_APPLY_ID: $F('OLD_APPLY_ID'),
											APPLY_ID: $F('APPLY_ID'),
											APPLY_PROCESS: $F('APPLY_PROCESS'),
											CRED_ID: $F('CRED_ID'),
											CAPT_DATE: $F('CAPT_DATE'),
											BUILD_NO1: $F('BUILD_NO1'),
											BUILD_NO2: $F('BUILD_NO2'),
											INPUT_ID: $F('INPUT_ID'),
											MATERIAL: $F('MATERIAL'),
											MAIN_USE: $F('MAIN_USE'),
											OLD_BUILD_NO1: $F('OLD_BUILD_NO1'),
											OLD_BUILD_NO2: $F('OLD_BUILD_NO2')
										})
									   },
						 	onSuccess:function(XHT, resp){
								if(CSRUtil.isSuccess(resp)){
										showPageData(resp);
								}else{
									if(resp.DATA_NOT_FOUND){
										clearPageData();
									}						
								}
							}
					});
			
		}
};

<%--
	查詢完後開啟相關button，查詢button除外
--%>
function openAllButton() {
	//測試
	btn_insert = ($('insertBtn').disabled == false ? true : false);
	btn_delete = ($('deleteBtn').disabled == false ? true : false);
	btn_update = ($('updateBtn').disabled == false ? true : false);
	btn_updateIDBtn = ($('updateIDBtn').disabled == false ? true : false);
	btn_clear = ($('clearBtn').disabled == false ? true : false);
	btn_cancel = ($('cancelBtn').disabled == false ? true : false);
	btn_buildingImageBtn = ($('buildingImageBtn').disabled == false ? true : false);
	btn_tearDownImage = ($('tearDownImageBtn').disabled == false ? true : false);
	btn_query = ($('queryBtn').disabled == false ? true : false);
	btn_reject = ($('rejectBtn').disabled == false ? true : false);
	
	if(btn_insert) {
		$('insertBtn').disabled = false;
	}
	if(btn_delete) {
		$('deleteBtn').disabled = false;
	}
	if(btn_updateIDBtn) {
		$('updateIDBtn').disabled = false;
	}
	if(btn_clear) {
		$('clearBtn').disabled = false;
	}
	if(btn_cancel) {
		$('cancelBtn').disabled = false;
	}
	
	if(btn_buildingImageBtn) {
		$('buildingImageBtn').disabled = false;
	}
	if(btn_tearDownImage) {
		$('tearDownImageBtn').disabled = false;
	}
	if(btn_reject) {
		$('rejectBtn').disabled = false;
	}
	<%--[20210318]SA追加檢核:當APPLY_ID第4碼有”@” -> 銀行件 ->修改按鈕disable，銀行建修改按鈕enable--%>
	<%--[20210323]
		需求變更
		銀行件判斷條件:受理編號第4碼為“@” AND 受理編號第4,5碼 != “@A” “@B” “@E”
		若為銀行件，建物樓層資料及建物所有權人新增和刪除按鈕反灰
		若不為銀行件，建物樓層資料及建物所有權人新增和刪除按鈕正常
	--%>
	if(!$('updateBtn').disabled) {
		var APPLY_ID = $F('APPLY_ID');
		var btn_update_for_bank = APPLY_ID.substring(3,4) == '@' && !['@A', '@B', '@E'].include(APPLY_ID.substring(3,5));
		if (btn_update_for_bank) {
			$('btn_update_for_bank').disabled = false;
			$('updateBtn').disabled = true;
			$w('insertBtn_BLOCK_D deleteBtn_BLOCK_D insertBtn_BLOCK_E deleteBtn_BLOCK_E').forEach(function(id) {
			    $(id).disabled = true;<%--若為銀行件，建物樓層資料及建物所有權人新增和刪除按鈕反灰--%>
			});
		} else {
			$('btn_update_for_bank').disabled = true;
			$('updateBtn').disabled = false;
			$w('insertBtn_BLOCK_D deleteBtn_BLOCK_D insertBtn_BLOCK_E deleteBtn_BLOCK_E').forEach(function(id) {
			    $(id).disabled = false;<%--若不為銀行件，建物樓層資料及建物所有權人新增和刪除按鈕正常--%>
			});
		}
	} else {
		$('btn_update_for_bank').disabled = true;
		$w('insertBtn_BLOCK_D deleteBtn_BLOCK_D insertBtn_BLOCK_E deleteBtn_BLOCK_E').forEach(function(id) {
		    $(id).disabled = false;
		});
	}
}

<%--
	查詢作業
--%>
function doQuery() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');
	
	<%-- 建號(主建物建號) 補0 --%>
	fillBuildingValue();	

	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色

	<%--
		2.1	畫面程序檢核:
		2.1.1	「受理編號」必須有值，否則顯示警示訊息：‘您必須填入受理編號的資料!!’。
	--%>
	if($F('APPLY_ID') == '') {
		alert('您必須填入受理編號的資料!!');
		return ;
	}

	//保留參數管理-更新受理編號
	CSRUtil.keepParamsManager.put({'APPLY_ID': $F('APPLY_ID')});

  	new Ajax.Request("<%=dispatcher%>/DSA1_0500/doQuery", 
	{
			parameters:{'APPLY_ID':$F('APPLY_ID')},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
						showPageData(resp);
				}else{
					if(resp.DATA_NOT_FOUND){
						clearPageData();
						
						<%--
(C區)建物謄本資料
受理編號	OLD_APPLY_ID	rtnMap.APPLY_ID	顯示欄位
受理進度	APPLY_PROCESS_NM	rtnMap.APPLY_PROCESS_NM	顯示欄位
申請書門牌資料	GAGE_ADDR	rtnMap.GAGE_ADDR	顯示欄位
						--%>
						if(isNotEmpty(resp.APPLY_ID)) {
							$('SHOW_APPLY_ID').innerHTML = resp.APPLY_ID;
							$('OLD_APPLY_ID').value = resp.APPLY_ID;
						}
						if(isNotEmpty(resp.APPLY_PROCESS_NM)) {
							$('SHOW_APPLY_PROCESS_NM').innerHTML = resp.APPLY_PROCESS_NM;
						}
						if(isNotEmpty(resp.GAGE_ADDR)) {
							$('SHOW_GAGE_ADDR').innerHTML = resp.GAGE_ADDR;
						}
					}						
				}
				//openAllButton();
			}
	});
}

<%--顯示資料於頁面--%>
function showPageData(resp) {

	rtnList = resp.rtnList ? resp.rtnList : [];
	A051List= resp.A051List ? resp.A051List : [];
	A052List= resp.A052List ? resp.A052List : [];
	rtnMap= resp.rtnMap ? resp.rtnMap : {};
	rtnA050Map= resp.rtnA050Map ? resp.rtnA050Map : {};

	setSequenceNumber(A051List,SEQUENCE_NUMBER_COLUMN);
	setSequenceNumber(A052List,SEQUENCE_NUMBER_COLUMN);
	
	<%--
		Hidden Fields
		<input type="hidden" name="OLD_APPLY_ID" id="OLD_APPLY_ID" value="">
		<input type="hidden" name="OLD_BUILD_NO1" id="OLD_BUILD_NO1" value="">
		<input type="hidden" name="OLD_BUILD_NO2" id="OLD_BUILD_NO2" value="">
		<input type="hidden" name="INPUT_ID" id="INPUT_ID" value="">
		<input type="hidden" name="APPLY_PROCESS" id="APPLY_PROCESS" value="">
		<input type="hidden" name="CRED_ID" id="CRED_ID" value="">
		<input type="hidden" name="CAPT_DATE" id="CAPT_DATE" value="">
	--%>
	$('OLD_APPLY_ID').value = getValue(rtnMap['APPLY_ID']);
	$('OLD_BUILD_NO1').value = getValue(rtnA050Map['BUILD_NO1']);
	$('OLD_BUILD_NO2').value = getValue(rtnA050Map['BUILD_NO2']);
	$('INPUT_ID').value = getValue(rtnA050Map['INPUT_ID']);
	$('INPUT_DATE').value = getValue(rtnA050Map['INPUT_DATE']);
	$('APPLY_PROCESS').value = getValue(rtnMap['APPLY_PROCESS']);
	$('CRED_ID').value = getValue(rtnMap['CRED_ID']);
	$('CAPT_DATE').value = getValue(rtnMap['CAPT_DATE']);
	
	<%--
		2.4.2	正常顯示:
		2.4.2.1	 將資料放到畫面，顯示欄位依序如下
		2.4.2.2	//判斷若2Q取件人員不一樣,則顯示警示訊息,並且將按鈕disable:
		IF  2Q_PERSON = ‘Y’  AND  lockUser != user.getEmpID()
			     顯示警示訊息：‘登入人員不為取件人員，請確認此件取件人員!!’,
			     新增、刪除、修正、修正地號、退回、取消取件 按鈕disable
		ENDIF
		2.4.2.3	//判斷是否有拆件影像:
		IF  rtnMap.IS_SEPARATE = ‘’  OR  ‘N’                   //是否拆件
			     拆件影像 按鈕disable
		ELSE
			     拆件影像 按鈕enable
        ENDIF
	--%>
	if(resp.imageButtonStatus == "false") {
		$('tearDownImageBtn').disabled = true;
		btn_tearDownImage = false;
	}else {
		$('tearDownImageBtn').disabled = false;
		btn_tearDownImage = true;
	}
	if(resp.mostButtonStatus == "true") {
		$('insertBtn').disabled = true;
		$('deleteBtn').disabled = true;
		$('updateBtn').disabled = true;
		$('updateIDBtn').disabled = true;
		$('rejectBtn').disabled = true;
		$('cancelBtn').disabled = true;
		alert('登入人員不為取件人員，請確認此件取件人員!!');
	}else {
		if(btn_insert) 
			$('insertBtn').disabled = false;
		if(btn_delete) 
			$('deleteBtn').disabled = false;
		if(btn_update) 
			$('updateBtn').disabled = false;
		if(btn_updateIDBtn) 
			$('updateIDBtn').disabled = false;
		if(btn_reject) 
			$('rejectBtn').disabled = false;
		if(btn_cancel) 
			$('cancelBtn').disabled = false;
	}
	
	<%--[20210318]SA追加檢核:當APPLY_ID第4碼有”@” -> 銀行件 ->修改按鈕disable，銀行建修改按鈕enable--%>
	if(!$('updateBtn').disabled) {
		var btn_update_for_bank = $F('APPLY_ID').substring(3,4) == '@';
		if (btn_update_for_bank) {
			$('btn_update_for_bank').disabled = false;
			$('updateBtn').disabled = true;
			$w('insertBtn_BLOCK_D deleteBtn_BLOCK_D insertBtn_BLOCK_E deleteBtn_BLOCK_E').forEach(function(id) {
			    $(id).disabled = true;<%--若為銀行件，建物樓層資料及建物所有權人新增和刪除按鈕反灰--%>
			});
		} else {
			$('btn_update_for_bank').disabled = true;
			$('updateBtn').disabled = false;
			$w('insertBtn_BLOCK_D deleteBtn_BLOCK_D insertBtn_BLOCK_E deleteBtn_BLOCK_E').forEach(function(id) {
			    $(id).disabled = false;<%--若不為銀行件，建物樓層資料及建物所有權人新增和刪除按鈕正常--%>
			});
		}
	} else {
		$('btn_update_for_bank').disabled = true;
		$w('insertBtn_BLOCK_D deleteBtn_BLOCK_D insertBtn_BLOCK_E deleteBtn_BLOCK_E').forEach(function(id) {
		    $(id).disabled = false;
		});
	}
	
	<%-- B BLOCK --%>
	if(rtnList) {
		B_grid.load(rtnList);
	}else {
		B_grid.load([]);
	}
	
	<%-- D BLOCK --%>
	if(A051List) {
		constructRows_BlockD('D_grid',A051List);
	}else {
		constructRows_BlockD('D_grid',null);
	}

	<%-- E BLOCK --%>
	if(A052List) {
		constructRows_BlockE('E_grid',A052List);
	}else {
		constructRows_BlockE('E_grid',null);
	}
	
	autoFormatToNumber();
	autoFormatToDate();
	fix();
	setBlockC(rtnMap,rtnA050Map)	
	
	PageUI.resize(true);
	
	initFastCheck();<%--[20210311]將可輸入欄位放入recordForCheckFast物件，方便快速檢核資料異動--%>
}

<%--
	點選b區後的更新
--%>
function radioBfreshPage(resp,rtnMap,rtnA050Map) {

	A051List= resp.A051List ? resp.A051List : [];
	A052List= resp.A052List ? resp.A052List : [];
	
	setSequenceNumber(A051List,SEQUENCE_NUMBER_COLUMN);
	setSequenceNumber(A052List,SEQUENCE_NUMBER_COLUMN);
	
	$('OLD_APPLY_ID').value = getValue(rtnMap['APPLY_ID']);
	$('OLD_BUILD_NO1').value = getValue(rtnA050Map['BUILD_NO1']);
	$('OLD_BUILD_NO2').value = getValue(rtnA050Map['BUILD_NO2']);
	$('INPUT_ID').value = getValue(rtnA050Map['INPUT_ID']);
	$('INPUT_DATE').value = getValue(rtnA050Map['INPUT_DATE']);
	$('APPLY_PROCESS').value = getValue(rtnMap['APPLY_PROCESS']);
	$('CRED_ID').value = getValue(rtnMap['CRED_ID']);
	$('CAPT_DATE').value = getValue(rtnMap['CAPT_DATE']);
	
	
	<%-- D BLOCK --%>
	if(A051List) {
		constructRows_BlockD('D_grid',A051List);
	}else {
		constructRows_BlockD('D_grid',null);
	}

	<%-- E BLOCK --%>
	if(A052List) {
		constructRows_BlockE('E_grid',A052List);
	}else {
		constructRows_BlockE('E_grid',null);
	}
	
	autoFormatToNumber();
	autoFormatToDate();
	fix();
	setBlockC(rtnMap,rtnA050Map);
	PageUI.resize(true);
	
	initFastCheck();<%--[20210311]將可輸入欄位放入recordForCheckFast物件，方便快速檢核資料異動--%>
}

function initFastCheck() {<%--[20210311]將可輸入欄位放入recordForCheckFast物件，方便快速檢核資料異動--%>
	recordForCheckFast = {};
	$$('tr.block_c').forEach(function(it){<%--C區--%>
	    it.select('input[type="text"]', 'select').forEach(function(fixable){
	        recordForCheckFast[fixable.name] = fixable.value;
	    });
	    it.select('input[type="radio"]:checked').forEach(function(fixable){
	        recordForCheckFast[fixable.name] = fixable.value;
	    });
	})
	$('D_grid').select('input[type="text"]', 'select').forEach(function(it){<%--D區--%>
	    recordForCheckFast[it.id] = it.value;
	});
	$('E_grid').select('input[type="text"]', 'select').forEach(function(it){<%--E區--%>
	    recordForCheckFast[it.id] = it.value;
	});
}

<%--
	設定c區資料
--%>
function setBlockC(rtnMap,rtnA050Map) {

	<%--
		受理編號	OLD_APPLY_ID	rtnMap.APPLY_ID	顯示欄位
		受理進度	APPLY_PROCESS_NM	rtnMap.APPLY_PROCESS_NM	顯示欄位
		申請書門牌資料	GAGE_ADDR	rtnMap.GAGE_ADDR	顯示欄位
		房屋門牌號碼	CITY	rtnA050Map. ADDR_NO	輸入欄位，長度300
		
		建號(主建物建號)1	BUILD_NO1	rtnA050Map.BUILD_NO1	輸入欄位，自動將建號1補滿5個欄位，不足前面補0
		建號(主建物建號)2	BUILD_NO2	rtnA050Map.BUILD_NO2	輸入欄位，自動將建號2補滿3個欄位，不足前面補0
		主建物判別碼	MAIN_BUILD	rtnA050Map.MAIN_BUILD	輸入欄位，radio選單： checked:VALUE= ‘1’;unchecked:value = ‘0’
	--%>
	$('SHOW_APPLY_ID').innerText = getValue(rtnMap.APPLY_ID);
	$('SHOW_APPLY_PROCESS_NM').innerText = getValue(rtnMap.APPLY_PROCESS_NM);
	$('SHOW_GAGE_ADDR').innerText = getValue(rtnMap.GAGE_ADDR) ;
	$('ADDR_NO').value = getValue(rtnA050Map.ADDR_NO).trim();
	
	$('BUILD_NO1').value = getValue(rtnA050Map.BUILD_NO1_FILL);
	$('BUILD_NO2').value = getValue(rtnA050Map.BUILD_NO2_FILL);
	if(rtnA050Map.MAIN_BUILD == "1") {
		$('MAIN_BUILD_1').checked = true;
	}else {
		$('MAIN_BUILD_0').checked = true;
	}
	
	
	<%--
		主要建材	MATERIAL	初始值為MATERIAL_LIST,
		VALUE:
		MATERIAL_LIST[i].CODE
		顯示: MATERIAL_LIST[i].NAME;
		查詢值:
		rtnA050Map. MATERIAL	下拉選單,預設顯示 “R.C結構”
		/*下拉選單資料
		磚造:1	加強磚造:2	R.C結構:3	鋼骨結構:4
		*/
	--%>
	if(haveValue(rtnA050Map.MATERIAL)) {
		$('MATERIAL').value = rtnA050Map.MATERIAL;
	}else {
		$('MATERIAL').value = "3";
	}
	
	<%--
		主要用途	MAIN_USE	初始值為MAIN_USE_LIST,
		VALUE:
		MAIN_USE_LIST[i].CODE
		顯示: MAIN_USE_LIST[i].NAME;
		查詢值:
		rtnA050Map. MAIN_USE	下拉選單,預設顯示空白
		/*下拉選單資料
			住家:1	店舖:2
			辦公室:3		工業用:4
			商業用:5		國民住宅:6
			見使用執照:7	工商用:8
			住商用:9		管理員室:A
			空白:0
		*/
	--%>
	if(haveValue(rtnA050Map.MAIN_USE)) {
		$('MAIN_USE').value = rtnA050Map.MAIN_USE;
	}else {
		$('MAIN_USE').value = "";
	}

	<%--
			總層數	FLOOR	rtnA050Map.FLOOR	數字輸入欄位，長度3
			總面積	BUILD_MEASURE	rtnA050Map.BUILD_MEASURE	數字輸入欄位，小數點3位、整數6位，須為正整數。若無資料預設為0
			建築完成日	FINISH_DATE	rtnA050Map.FINISH_DATE	日期欄位,亦可透過日曆模式點選日期
			屋齡	BUILD_AGE	rtnA050Map.BUILD_AGE	數字輸入欄位，長度3
			建築完成日異動時自動重新計算屋齡:CALL 計算屋齡模組
			原因發生日期 OCCUR_DATE	rtnA050Map.OCCUR_DATE	日期欄位,亦可透過日曆模式點選日期
			
			使用情形	USE_STATUS	初始值為USE_STATUS_LIST,
			VALUE:
			USE_STATUS_LIST[i].CODE
			顯示: USE_STATUS_LIST[i].NAME;
			查詢值:
			rtnA050Map. USE_STATUS	下拉選單,預設顯示第一筆資料
			/*下拉選單資料
				自用:0	出租:1	空屋:2	借住:3
			*/

			建築型態	BUILD_TYPE	初始值為BUILD_TYPE_LIST,
			VALUE:
			BUILD_TYPE_LIST[i].CODE
			顯示: BUILD_TYPE_LIST[i].NAME;
			查詢值:
			rtnA050Map. BUILD_TYPE	下拉選單,預設顯示第一筆資料
			/*下拉選單資料
				公寓:0	透天:1	重疊:2	大樓:3
			*/
	--%>
	$('FLOOR').value = getValue(rtnA050Map.FLOOR);
	$('SHOW_BUILD_MEASURE').innerHTML = CSRUtil.$fmt(getValue(rtnA050Map.BUILD_MEASURE,"0"),"#,###.###");
	$('BUILD_MEASURE').value = rtnA050Map.BUILD_MEASURE;
	$('FINISH_DATE').value = getValue(rtnA050Map.FINISH_DATE_ROC);
	old_FINISH_DATE = getValue(rtnA050Map.FINISH_DATE_ROC);//TODO
	$('BUILD_AGE').value = getValue(rtnA050Map.BUILD_AGE);
	$('OCCUR_DATE').value = getValue(rtnA050Map.OCCUR_DATE_ROC);
	$('SHOW_BUILD_AGE').innerHTML = getValue(rtnA050Map.BUILD_AGE);
	if(haveValue(rtnA050Map.USE_STATUS)) {
		$('USE_STATUS').value = getValue(rtnA050Map.USE_STATUS);
	}else {
		$('USE_STATUS').value = '0';
	}
	
	if(haveValue(rtnA050Map.BUILD_TYPE)) {
		$('BUILD_TYPE').value = getValue(rtnA050Map.BUILD_TYPE);
	}else {
		$('BUILD_TYPE').value = '0';
	}
	
	<%--
		總層數	FLOOR	rtnA050Map.FLOOR	數字輸入欄位，長度3
		屋齡	BUILD_AGE	rtnA050Map.BUILD_AGE	數字輸入欄位，長度3
		月租金	RENTAL	rtnA050Map.RENTAL	數字輸入欄位，長度10，須為正整數。若無資料預設為0
		押金	DEPOSIT	rtnA050Map.DEPOSIT	數字輸入欄位，長度10，須為正整數。若無資料預設為0
	
	
		月租金	RENTAL	rtnA050Map.RENTAL	數字輸入欄位，長度10，須為正整數。若無資料預設為0
		押金	DEPOSIT	rtnA050Map.DEPOSIT	數字輸入欄位，長度10，須為正整數。若無資料預設為0
		租期	START_DATE	rtnA050Map.START_DATE	日期欄位,亦可透過日曆模式點選日期
		租期	END_DATE	rtnA050Map.END_DATE	日期欄位,亦可透過日曆模式點選日期
		建檔人員	INPUT_ID	rtnA050Map.INPUT_ID	顯示欄位
		建檔日期	INPUT_DATE	rtnA050Map.INPUT_DATE	顯示欄位
	--%>	
	if(haveValue(rtnA050Map.RENTAL)) {
		$('RENTAL').value = CSRUtil.$fmt(getValue(rtnA050Map.RENTAL),"#,###");
	}else {
		$('RENTAL').value = '0';
	}
	if(haveValue(rtnA050Map.DEPOSIT)) {
		$('DEPOSIT').value = CSRUtil.$fmt(getValue(rtnA050Map.DEPOSIT),"#,###");
	}else {
		$('DEPOSIT').value = '0';
	}
	$('START_DATE').value = getValue(rtnA050Map.START_DATE_ROC);
	$('END_DATE').value = getValue(rtnA050Map.END_DATE_ROC);
	
	$('SHOW_INPUT_ID').innerText = getValue(rtnA050Map.INPUT_ID_NM,"");
	$('SHOW_INPUT_DATE').innerText = toROC_delimiter(getValue(rtnA050Map.INPUT_DATE_ROC,""));

}


<%--清空頁面資料--%>
function clearPageData(resp) {
	rtnList = [];
	A051List= [];
	A052List= [];
	rtnMap= {};
	rtnA050Map= {};

	B_grid.load([]);
	constructRows_BlockD('D_grid',null);
	constructRows_BlockE('E_grid',null);
		
	<%--
		受理編號	OLD_APPLY_ID	rtnMap.APPLY_ID	顯示欄位
		受理進度	APPLY_PROCESS_NM	rtnMap.APPLY_PROCESS_NM	顯示欄位
		申請書門牌資料	GAGE_ADDR	rtnMap.GAGE_ADDR	顯示欄位
		房屋門牌號碼	CITY	rtnA050Map. ADDR_NO	輸入欄位，長度300
		
		建號(主建物建號)1	BUILD_NO1	rtnA050Map.BUILD_NO1	輸入欄位，自動將建號1補滿5個欄位，不足前面補0
		建號(主建物建號)2	BUILD_NO2	rtnA050Map.BUILD_NO2	輸入欄位，自動將建號2補滿3個欄位，不足前面補0
		主建物判別碼	MAIN_BUILD	rtnA050Map.MAIN_BUILD	輸入欄位，radio選單： checked:VALUE= ‘1’;unchecked:value = ‘0’
	--%>
	$('SHOW_APPLY_ID').innerText = '';
	$('SHOW_APPLY_PROCESS_NM').innerText = '';
	$('SHOW_GAGE_ADDR').innerText = '';
	$('ADDR_NO').value = '';
	$('BUILD_NO1').value = '';
	$('BUILD_NO2').value = '';
	
	$('MAIN_BUILD_1').checked = true;
	$('MAIN_BUILD_0').checked = false;
	
	
	<%--
		主要建材	MATERIAL	初始值為MATERIAL_LIST,
		主要用途	MAIN_USE	初始值為MAIN_USE_LIST,
	--%>
	$('MATERIAL').value = '';
	$('MAIN_USE').value = '';
	
	<%--
			總層數	FLOOR	rtnA050Map.FLOOR	數字輸入欄位，長度3
			總面積	BUILD_MEASURE	rtnA050Map.BUILD_MEASURE	數字輸入欄位，小數點3位、整數6位，須為正整數。若無資料預設為0
			建築完成日	FINISH_DATE	rtnA050Map.FINISH_DATE	日期欄位,亦可透過日曆模式點選日期
			屋齡	BUILD_AGE	rtnA050Map.BUILD_AGE	數字輸入欄位，長度3
			原因發生日期 OCCUR_DATE	rtnA050Map.OCCUR_DATE	日期欄位,亦可透過日曆模式點選日期
			建築完成日異動時自動重新計算屋齡:CALL 計算屋齡模組
			
			使用情形	USE_STATUS	初始值為USE_STATUS_LIST,
			VALUE:
			USE_STATUS_LIST[i].CODE
			顯示: USE_STATUS_LIST[i].NAME;
			查詢值:
			rtnA050Map. USE_STATUS	下拉選單,預設顯示第一筆資料

			建築型態	BUILD_TYPE	初始值為BUILD_TYPE_LIST,
			VALUE:
			BUILD_TYPE_LIST[i].CODE
			顯示: BUILD_TYPE_LIST[i].NAME;
			查詢值:
			rtnA050Map. BUILD_TYPE	下拉選單,預設顯示第一筆資料
	--%>
	$('FLOOR').value = '';
	$('SHOW_BUILD_MEASURE').innerHTML = '';
	$('BUILD_MEASURE').value = '';
	$('FINISH_DATE').value = '';
	$('BUILD_AGE').value = '';
	$('OCCUR_DATE').value = '';	
	$('SHOW_BUILD_AGE').innerHTML = '';
	
	$('USE_STATUS').value = '';
	$('BUILD_TYPE').value = '';

	<%--
		月租金	RENTAL	rtnA050Map.RENTAL	數字輸入欄位，長度10，須為正整數。若無資料預設為0
		押金	DEPOSIT	rtnA050Map.DEPOSIT	數字輸入欄位，長度10，須為正整數。若無資料預設為0
		租期	START_DATE	rtnA050Map.START_DATE	日期欄位,亦可透過日曆模式點選日期
		租期	END_DATE	rtnA050Map.END_DATE	日期欄位,亦可透過日曆模式點選日期
		建檔人員	INPUT_ID	rtnA050Map.INPUT_ID	顯示欄位
		建檔日期	INPUT_DATE	rtnA050Map.INPUT_DATE	顯示欄位
	--%>	
	$('RENTAL').value = '0';
	$('DEPOSIT').value = '0';
	$('START_DATE').value = '';
	$('END_DATE').value = '';

	$('SHOW_INPUT_ID').innerText = '';
	$('SHOW_INPUT_DATE').innerText = '';
	
	PageUI.resize(true);
}

<%--
	==============================================D BLOCK ===============================================
--%>

<%--
	Block D的新增
--%>
function insert_BlockD() {

	if(A051List == null) {
		alert("請先查詢再行操作");
		return;
	}

	var new_index = A051List.length;
	var newSeq = getNextSEQ_NO(A051List,SEQUENCE_NUMBER_COLUMN);
	A051List[new_index] = {};
	A051List[new_index][SEQUENCE_NUMBER_COLUMN] = newSeq;
	
	//受理編號	APPLY_ID	C區之受理編號	HIDDEN
	A051List[new_index]['APPLY_ID'] = null;

	//建號1	BUILD_NO1	C區之建號1	HIDDEN
	A051List[new_index]['BUILD_NO1'] = null;

	//建號2	BUILD_NO2	C區之建號2	HIDDEN
	A051List[new_index]['BUILD_NO2'] = null;

	//細項序號	CELL_NO
	A051List[new_index]['CELL_NO'] = null;

	//項目/層次/其他說明	ITEM
	A051List[new_index]['ITEM'] = null;

	//附屬建號1	AUX_NO1
	A051List[new_index]['AUX_NO1'] = null;

	//附屬建號2	AUX_NO2
	A051List[new_index]['AUX_NO2'] = null;

	//面積	MEASURE	預設為0	數字格式輸入欄位，小數點3位、整數12位，須為正整數
	A051List[new_index]['MEASURE'] = "0";

	//持份分母	HOLD_BASE	預設為1	數字格式輸入欄位，長度15
	A051List[new_index]['HOLD_BASE'] = "1";

	//持份分子	HOLD_UP	預設為1	數字格式輸入欄位，長度15
	A051List[new_index]['HOLD_UP'] = "1";
	
	//序號	SEQ_NO	畫面D區A051List[i].SEQ_NO的最大一筆+1	HIDDEN
	A051List[new_index]['SEQ_NO'] = getNextSEQ_NO(A051List,'SEQ_NO');
	
	var classType = (A051List.length % 2 == 0 ? "tbYellow2" : "tbYellow2" )
	var onlyDisplayOrNot = false ; //可修改
	var content = getNewRow_BlockD(classType,A051List[new_index],onlyDisplayOrNot,newSeq);
	var dataTable = $('D_grid');
	dataTable.insert({bottom : content});
	
	autoFormatToNumber();
	autoFormatToDate();
	PageUI.resize(true);
}

<%--
	區D 刪除
--%>
function delete_BlockD() {
	<%--
		15.	刪除(D區)(B0003)
		15.1	畫面程序檢核: 
		15.1.1	必須點選一筆資料，若未點選請顯示警示訊息:‘請選取一筆資料’
		15.2	讀取畫面欄位資料
		15.3	資料檢核: 無
		15.4	資料處理: 無
		15.5	畫面顯示: 
		15.5.1	移除畫面上區塊D資料顯示區所選取列的資料
		15.5.2	不必顯示訊息
	--%>
	if(radioListHaveSelectedOrNot('RADIO_D') == false) {
		alert("請選取一筆資料");
		return;
	}

	removeOneRow("D");	
}

<%--
	==============================================E BLOCK ===============================================
--%>

<%--
	Block E的新增
--%>
function insert_BlockE() {

	if(A052List == null) {
		alert("請先查詢再行操作");
		return;
	}

	<%--
		直接新增一列，以備輸入
		不管控所有BUTTON，也不管控每列選項
	--%>
	var new_index = A052List.length;
	var newSeq = getNextSEQ_NO(A052List,SEQUENCE_NUMBER_COLUMN);;
	A052List[new_index] = {};
	A052List[new_index][SEQUENCE_NUMBER_COLUMN] = newSeq;
	//受理編號	APPLY_ID	C區之受理編號	HIDDEN
	//建號1	BUILD_NO1	C區之建號1	HIDDEN
	//建號2	BUILD_NO2	C區之建號2	HIDDEN
	//所有權人	NAME		輸入欄位
	//所有權人ID	ID		輸入欄位
	//所有權人生日	BIRTHDAY		日期欄位,亦可透過日曆模式點選日期
	A052List[new_index]['APPLY_ID'] = null;
	A052List[new_index]['BUILD_NO1'] = null;
	A052List[new_index]['BUILD_NO2'] = null;
	A052List[new_index]['NAME'] = null;
	A052List[new_index]['ID'] = null;
	A052List[new_index]['BIRTHDAY'] = null;
	
	var classType = (A052List.length % 2 == 0 ? "tbYellow2" : "tbYellow2" )
	var onlyDisplayOrNot = false ; //可修改
	var content = getNewRow_BlockE(classType,A052List[new_index],onlyDisplayOrNot,newSeq);
	var dataTable = $('E_grid');
	dataTable.insert({bottom : content});
	
	autoFormatToNumber();
	autoFormatToDate();
	<%-- [20240723]難字調整 --%>
	$$('#E_grid .addEUDC').each(function(elem){
		var tagName = elem.tagName;
		if('INPUT' == tagName){
			elem.setAttribute('alt','ch');
		}else{
			elem.setStyle({"font-family": 'EUDC'});
	 	}		
	});
	parseEUDC();
	PageUI.resize(true);
}

<%--
	區E 刪除
--%>
function delete_BlockE() {

	<%--
		19.	刪除(E區)(B0003)
		19.1	畫面程序檢核: 
		19.1.1	必須點選一筆資料，若未點選請顯示警示訊息:‘請選取一筆資料’
		19.2	讀取畫面欄位資料
		19.3	資料檢核: 無
		19.4	資料處理: 無
		19.5	畫面顯示: 
		19.5.1	移除畫面上區塊E資料顯示區所選取列的資料
		19.5.2	不必顯示訊息
	--%>
	if(radioListHaveSelectedOrNot('RADIO_E') == false) {
		alert("請選取一筆資料");
		return;
	}
	removeOneRow("E");	
}


<%--
		===================各項button操作======================
--%>

<%--
	新增作業
--%>
function doInsert() {

	if($F('USE_STATUS')!='1' && $F('USE_STATUS')!='4'){
		$('RENTAL').value = '0';
		$('DEPOSIT').value = '0';
		$('START_DATE').value = '';
		$('END_DATE').value = '';
	}


	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');
	
	<%-- 建號(主建物建號) 補0 --%>
	fillBuildingValue();	

	<%--
		4.1.6	建物樓層資料必須至少有一筆資料、建物所有權人資料必須至少有一筆資料
	--%>
	var errorMessage = "";
	if(A051List == null || A051List.length == 0) {
		errorMessage += "建物樓層資料必須至少有一筆資料\n";
	}
	if(A052List == null || A052List.length == 0) {
		errorMessage += "建物所有權人資料必須至少有一筆資料\n";
	}
	if(errorMessage != "") {
		alert(errorMessage);
		return;
	}

	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色

	<%-- 全型字檢查 --%>
	validateHalfType();
	replacetaiwan();
	
	<%--
		4.	新增(B0003)
		4.1	畫面程序檢核: 
		4.1.1	檢核C區的以下欄位必須有值:
		受理編號、建號、房屋門牌號碼
		主要建材、主要用途、房屋門牌號碼,總樓層		
	--%>
	validateEmpty('APPLY_ID',"受理編號必須有值!");
	validateEmpty('BUILD_NO1',"建號1必須有值!");
	validateEmpty('BUILD_NO2',"建號2必須有值!");
	validateEmpty('MATERIAL',"主要建材必須有值!");
	validateEmpty('MAIN_USE',"主要用途必須有值!");
	validateEmpty('ADDR_NO',"房屋門牌號碼必須有值!");
	validateEmpty('FLOOR',"總層數必須有值!");
	validateNum('FLOOR',"總層數只能輸入大於等於0的正整數!");
	validateEmpty('FINISH_DATE',"建築完成日必須有值!");
	validateROCformate('FINISH_DATE',"建築完成日須為正確日期格式!","NO");
	validateROCformate('START_DATE',"租期起日須為正確日期格式!");
	validateROCformate('END_DATE',"租期迄日須為正確日期格式!");
	//validateEmpty('OCCUR_DATE',"原因發生日期必須有值!");
	validateROCformate('OCCUR_DATE',"原因發生日期須為正確日期格式!");
	
	<%-- 
		新增,修改檢核>>  總面積需>0
	--%>
	var BUILD_MEASURE_VALUE = $('BUILD_MEASURE').value;
	if(	BUILD_MEASURE_VALUE - 0 <= 0) {
		setFalseCheck('BUILD_MEASURE','總面積需>0');
	}
	
	<%--
	6.	新增、修改：DSA1_0500新增檢核:租期迄日必須大於租期起日	
	--%>
	if(isNotEmpty($F('START_DATE')) && isNotEmpty($F('END_DATE'))) {
		var START_DATE_Y2K = toY2K($F('START_DATE'));
		var END_DATE_Y2K = toY2K($F('END_DATE'));
		if(diffDay(START_DATE_Y2K,END_DATE_Y2K) -0 < 0) {
			setFalseCheck('START_DATE','租期迄日必須大於租期起日');
		}
	}
	
	if($('USE_STATUS').value == '1' || $('USE_STATUS').value == '4') {
		validateEmpty('RENTAL',"月租金需有值!");
		validateEmpty('DEPOSIT',"押金需有值!");
		if(isNotEmpty($F('RENTAL')) && $('RENTAL').value < 0 ) {
			setFalseCheck('RENTAL','月租金需>0');
		}
		if(isNotEmpty($F('DEPOSIT')) && $('DEPOSIT').value < 0 ) {
			setFalseCheck('RENTAL','押金需>0');
		}
	}
	
	<%-- 長度檢核 --%>
	checkMaxLength();
	
	<%-- D E區塊--%>
	block_DE_check();
	
	if(validate4define.validate() == false)
		return ;

	<%--
		4.1.3	if C區使用情形為出租(1)，則月租金與押金需>0，且租期起迄需有值，若否，警示訊息:“擔保品出租,請確認月租金押金,租期是否正確?”
	--%>
	if($('USE_STATUS').value == '1' || $('USE_STATUS').value == '4') {
		if(confirm('擔保品出租,請確認月租金押金,租期是否正確?') == false) {
			return ;
		}
	}
	<%----%>
	if(!$F('OCCUR_DATE') && !confirm('請確認建物原因發生日期是否正確?')){
		return;
	}
	<%--
		4.1.5	檢核查詢用和顯示用受理編號是否不同:
		if APPLY_ID !=  OLD_APPLY_ID
		需跳出警示訊息‘請確認是否將資料新增到{APPLY_ID}中?’，確認後才繼續執行
	--%>
	if($F('APPLY_ID') != $F('OLD_APPLY_ID')) {
		if(confirm("請確認是否將資料新增到" + $F('APPLY_ID') + "中?") == false) {
			return ;
		}
	}
	
	<%--
		4.2.2	另將畫面資料rtnMap存成mapA如下:
		欄位名稱	欄位值	說明
		OLD_APPLY_ID  	畫面上的受理編號	
		APPLY_PROCESS	畫面上的受理進度(隱藏欄位)	
		CRED_ID	畫面上的徵信人員ID(隱藏欄位)	
		CAPT_DATE	畫面上的組長覆核日期(隱藏欄位)	
		BUILD_NO1	畫面上的建號1	
		BUILD_NO2	畫面上的建號2	
		INPUT_ID	畫面上的建檔人員	
		2Q_PERSON	2Q_PERSON	是否為2Q作業人員
		OCCUR_DATE	畫面上的原因發生日期
	--%>
  	new Ajax.Request("<%=dispatcher%>/DSA1_0500/doInsert", 
	{
			parameters:{'A050vo' : getA050(),
						'A051List' : Object.toJSON(A051List),
						'A052List' : Object.toJSON(A052List),
						'APPLY_ID':$F('APPLY_ID'),
						'APPLY_PROCESS':$F('APPLY_PROCESS'),
						'CRED_ID':$F('CRED_ID'),
						'CAPT_DATE':$F('CAPT_DATE'),
						'BUILD_NO1':$F('BUILD_NO1'),
						'BUILD_NO2':$F('BUILD_NO2'),
						'INPUT_ID':$F('INPUT_ID'),
						'OCCUR_DATE':$F('OCCUR_DATE')
					   },
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
						showPageData(resp);
				}else{
					if(resp.DATA_NOT_FOUND){
						clearPageData();
					}						
				}
			}
	});
}

<%--
	刪除作業
--%>
function doDelete() {
	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%-- 建號(主建物建號) 補0 --%>
	fillBuildingValue();	
	
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	
	<%--
		5.	刪除(B0005)
		5.1	畫面程序檢核:
		5.1.1	檢查受理編號是否與查詢時不同:
		IF  APPLY_ID(受理編號-輸入欄位) NOT  =  OLD_APPLY_ID(受理編號-顯示欄位)
		    顯示錯誤訊息:‘欲刪除的受理編號與原先查詢的資料不同，無法作業!’
		5.1.2	顯示確認訊息‘是否確認刪除?’，確認後才繼續執行
	--%>
	if($F('APPLY_ID') != $F('OLD_APPLY_ID')) {
		alert("欲刪除的受理編號與原先查詢的資料不同，無法作業!");
		return ;
	}
	if(confirm("是否確認刪除?") == false) {
		return ;
	}
	
	<%--
		5.2	讀取畫面欄位資料:
		5.2.1	將畫面資料(C區)存成A050vo
		5.2.2	另將畫面資料rtnMap存成mapA如下:
		欄位名稱	欄位值	說明
		OLD_APPLY_ID  	畫面上的受理編號	
		APPLY_PROCESS	畫面上的受理進度(隱藏欄位)	
		CRED_ID	畫面上的徵信人員ID(隱藏欄位)	
		CAPT_DATE	畫面上的組長覆核日期(隱藏欄位)	
		BUILD_NO1	畫面上的建號1	
		BUILD_NO2	畫面上的建號2	
		INPUT_ID	畫面上的建檔人員
		OCCUR_DATE	畫面上的原因發生日期	
	--%>
  	new Ajax.Request("<%=dispatcher%>/DSA1_0500/doDelete", 
	{
			parameters:{'A050vo' : getA050(),
						'OLD_APPLY_ID':$F('OLD_APPLY_ID'),
						'APPLY_ID':$F('OLD_APPLY_ID'),
						'APPLY_PROCESS':$F('APPLY_PROCESS'),
						'CRED_ID':$F('CRED_ID'),
						'CAPT_DATE':$F('CAPT_DATE'),
						'BUILD_NO1':$F('BUILD_NO1'),
						'BUILD_NO2':$F('BUILD_NO2'),
						'INPUT_ID':$F('INPUT_ID'),
						'OCCUR_DATE':$F('OCCUR_DATE')
					   },
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
						showPageData(resp);
				}else{
					if(resp.DATA_NOT_FOUND){
						clearPageData();
					}						
				}
			}
	});
}

function updateValid(isBankUpdate){<%--[20210318]SA追加檢核:銀行件時先不要檢核建號相關--%>
	if($F('USE_STATUS')!='1' && $F('USE_STATUS')!='4'){
		$('RENTAL').value = '0';
		$('DEPOSIT').value = '0';
		$('START_DATE').value = '';
		$('END_DATE').value = '';
	}

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');
	
	<%-- 建號(主建物建號) 補0 --%>
	fillBuildingValue();	

	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	
	var errorMessage = "";
	if(A051List == null || A051List.length == 0) {
		errorMessage += "建物樓層資料必須至少有一筆資料\n";
	}
	if(A052List == null || A052List.length == 0) {
		errorMessage += "建物所有權人資料必須至少有一筆資料\n";
	}
	if($F('APPLY_ID') != $F('OLD_APPLY_ID')) {
		errorMessage += "欲刪除的受理編號與原先查詢的資料不同，無法作業!\n";
	}
	if(errorMessage != "") {
		alert(errorMessage);
		return false;
	}

	
	<%--
		6.1.1	檢查受理編號是否與查詢時不同:
		IF  APPLY_ID(受理編號-輸入欄位) NOT  =  OLD_APPLY_ID(受理編號-顯示欄位)
		    顯示錯誤訊息:‘欲修改的受理編號與原先查詢的資料不同，無法作業!’
		    
		6.1.2	檢核C區的以下欄位必須有值:
		受理編號、建號、房屋門牌號碼
		6.1.3	檢核「持分(分母)」不可小於「持分(分子)」:
		if HOLD_BASE  <  HOLD_UP，顯示錯誤訊息:‘分母不可小於分子!’
		
		6.1.4	if C區使用情形為出租(1)，則月租金與押金需>0，且租期起迄需有值，若否，警示訊息:“擔保品出租,請確認月租金押金,租期是否正確?”
		6.1.5	檢核C區建號1格式:長度須為5，不足前面須補0；檢核C區建號2格式:長度須為3，不足前面須補0，若否，警示訊息:“建號資料有誤”

		6.1.6	提示訊息: “請再次檢視門牌地址與建物謄本資料是否相符”，USER確認後，繼續往下執行
	--%>
	<%-- 全型字檢查 --%>
	if(isBankUpdate){
		//銀行件所有權人名稱不檢核
	}else{
		validateHalfType();
		replacetaiwan();
	}
	
	<%--
		主要建材、主要用途、房屋門牌號碼,總樓層		
	--%>
	validateEmpty('BUILD_NO1',"建號1必須有值!");
	validateEmpty('BUILD_NO2',"建號2必須有值!");
	validateEmpty('MATERIAL',"主要建材必須有值!");
	validateEmpty('MAIN_USE',"主要用途必須有值!");
	validateEmpty('ADDR_NO',"房屋門牌號碼必須有值!","NO");
	validateEmpty('FLOOR',"總層數必須有值!");
	validateNum('FLOOR',"總層數只能輸入大於等於0的正整數!");
	validateEmpty('FINISH_DATE',"建築完成日必須有值!");
	validateROCformate('FINISH_DATE',"建築完成日須為正確日期格式!","NO");
	validateROCformate('START_DATE',"租期起日須為正確日期格式!");
	validateROCformate('END_DATE',"租期迄日須為正確日期格式!");
	//validateEmpty('OCCUR_DATE',"原因發生日期必須有值!");
	validateROCformate('OCCUR_DATE',"原因發生日期須為正確日期格式!");
	
	<%-- 
		新增,修改檢核>>  總面積需>0
	--%>
	var BUILD_MEASURE_VALUE = $('BUILD_MEASURE').value;
	if(	BUILD_MEASURE_VALUE - 0 <= 0) {
		setFalseCheck('BUILD_MEASURE','總面積需>0');
	}
	
	<%--
	6.	新增、修改：DSA1_0500新增檢核:租期迄日必須大於租期起日	
	--%>
	if(isNotEmpty($F('START_DATE')) && isNotEmpty($F('END_DATE'))) {
		var START_DATE_Y2K = toY2K($F('START_DATE'));
		var END_DATE_Y2K = toY2K($F('END_DATE'));
		if(diffDay(START_DATE_Y2K,END_DATE_Y2K) -0 < 0) {
			setFalseCheck('START_DATE','租期迄日必須大於租期起日');
		}
	}
	
	if($('USE_STATUS').value == '1' || $('USE_STATUS').value == '4') {
		validateEmpty('RENTAL',"月租金需有值!");
		validateEmpty('DEPOSIT',"押金需有值!");
		if(isNotEmpty($F('RENTAL')) && $('RENTAL').value < 0 ) {
			setFalseCheck('RENTAL','月租金需>0');
		}
		if(isNotEmpty($F('DEPOSIT')) && $('DEPOSIT').value < 0 ) {
			setFalseCheck('RENTAL','押金需>0');
		}
	}
	
	<%-- 長度檢核 --%>
	checkMaxLength();
	
	<%-- D E區塊--%>
	block_DE_check(isBankUpdate);
	
	if(validate4define.validate() == false)
		return ;
	
	if($('USE_STATUS').value == '1' || $('USE_STATUS').value == '4') {
		if(confirm('擔保品出租,請確認月租金押金,租期是否正確?') == false) {
			return false;
		}
	}
	if(!$F('OCCUR_DATE') && !confirm('請確認建物原因發生日期是否正確?')){
		return false;
	}
	if(confirm("請再次檢視門牌地址與建物謄本資料是否相符?") == false) {
		return false;
	}
	
	return true;
}

<%--
	修正作業
--%>
function doUpdate() {

	if (!updateValid()){
		return;
	}
	
	<%--
		6.2	讀取畫面欄位資料:
		6.2.1	將畫面資料(C區)存成A050vo、(D區)存成A051List、(E區)存成A052List
		6.2.2	另將畫面資料rtnMap存成mapA如下:
		欄位名稱	欄位值	說明
		OLD_APPLY_ID  	畫面上的受理編號	
		APPLY_PROCESS	畫面上的受理進度(隱藏欄位)	
		CRED_ID	畫面上的徵信人員ID(隱藏欄位)	
		CAPT_DATE	畫面上的組長覆核日期(隱藏欄位)	
		BUILD_NO1	畫面上的建號1	
		BUILD_NO2	畫面上的建號2	
		INPUT_ID	畫面上的建檔人員	
		OCCUR_DATE	畫面上的原因發生日期
	--%>
  	new Ajax.Request("<%=dispatcher%>/DSA1_0500/doUpdate", 
	{
			parameters:{'A050vo' : getA050(),
						'A051List' : Object.toJSON(A051List),
						'A052List' : Object.toJSON(A052List),
						'OLD_APPLY_ID':$F('OLD_APPLY_ID'),
						'OLD_BUILD_NO1':$F('OLD_BUILD_NO1'),
						'OLD_BUILD_NO2':$F('OLD_BUILD_NO2'),
						//'OLD_FINISH_DATE':old_FINISH_DATE,//TODO setDateColumnValue(A050vo,'END_DATE',$F('END_DATE'));
						//toY2K(old_FINISH_DATE);
						'OLD_FINISH_DATE':toY2K(old_FINISH_DATE),//TODO
						'APPLY_ID':$F('APPLY_ID'),
						'APPLY_PROCESS':$F('APPLY_PROCESS'),
						'CRED_ID':$F('CRED_ID'),
						'CAPT_DATE':$F('CAPT_DATE'),
						'BUILD_NO1':$F('BUILD_NO1'),
						'BUILD_NO2':$F('BUILD_NO2'),
						'INPUT_ID':$F('INPUT_ID'),
						'OCCUR_DATE':$F('OCCUR_DATE')
					   },
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
						showPageData(resp);
				}else{
					if(resp.DATA_NOT_FOUND){
						clearPageData();
					}						
				}
			}
	});
}

<%--
	修正建號作業
--%>
function doUpdateConstructID() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');
	
	<%-- 建號(主建物建號) 補0 --%>
	fillBuildingValue();	

	<%--
		7.	修正建號(B0032)
		7.1	畫面程序檢核: 
		7.1.1	檢查受理編號是否與查詢時不同:
		IF  APPLY_ID(受理編號-輸入欄位) NOT  =  OLD_APPLY_ID(受理編號-顯示欄位)
		    顯示錯誤訊息:‘欲修改的受理編號與原先查詢的資料不同，無法作業!’
		    
		7.1.2	檢核修改「建號1」、「建號2」
		IF      BUILD_NO1  != OLD_BUILD_NO1           //建號1
		   and  BUILD_NO2  != OLD_BUILD_NO2           //建號2
		       顯示確認訊息‘請確認要修改建號資料是否正確’，確認後才繼續執行
		ELSE
		       顯示確認訊息‘建號沒有更改過，請重新輸入!!’
		ENDIF
	--%>
	if($F('APPLY_ID') != $F('OLD_APPLY_ID')) {
		alert("欲刪除的受理編號與原先查詢的資料不同，無法作業!");
		return ;
	}
	
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	
	validateEmpty('FINISH_DATE',"建築完成日必須有值!");
	validateROCformate('FINISH_DATE',"建築完成日須為正確日期格式!","NO");
	validateROCformate('START_DATE',"租期起日須為正確日期格式!");
	validateROCformate('END_DATE',"租期迄日須為正確日期格式!");
	//validateEmpty('OCCUR_DATE',"原因發生日期必須有值!");
	validateROCformate('OCCUR_DATE',"原因發生日期須為正確日期格式!");
	<%-- 全型字檢查 --%>
	validateHalfType();
	replacetaiwan();
	if(validate4define.validate() == false)
		return ;
	
	
	if($F('BUILD_NO1') != $F('OLD_BUILD_NO1') || 
	   $F('BUILD_NO2') != $F('OLD_BUILD_NO2') 
	) {
		if(confirm("請確認要修改建號資料是否正確?") == false) {
			return ;
		}
	}else {
		alert('建號沒有更改過，請重新輸入!!');
		return ;
	}
	
	<%--
		7.2	讀取畫面資料: 
		7.2.1	將畫面資料(C區)存成A050vo
		7.2.2	另將畫面資料rtnMap存成mapA如下:
		欄位名稱	欄位值	說明
		OLD_APPLY_ID  	畫面上的受理編號	
		APPLY_PROCESS	畫面上的受理進度(隱藏欄位)	
		CRED_ID	畫面上的徵信人員ID(隱藏欄位)	
		CAPT_DATE	畫面上的組長覆核日期(隱藏欄位)	
		BUILD_NO1	畫面上的建號1	
		BUILD_NO2	畫面上的建號2	
		INPUT_ID	畫面上的建檔人員	
		OLD_BUILD_NO1	修改前建號(主建物建號)1(隱藏欄位)	
		OLD_BUILD_NO2	修改前建號(主建物建號)2(隱藏欄位)	
		OCCUR_DATE	畫面上的原因發生日期
	--%>
	
  	new Ajax.Request("<%=dispatcher%>/DSA1_0500/doUpdateConstructID", 
	{
			parameters:{
						'A050vo' : getA050(),
						'APPLY_ID':$F('APPLY_ID'),
						'OLD_BUILD_NO1':$F('OLD_BUILD_NO1'),
						'OLD_BUILD_NO2':$F('OLD_BUILD_NO2'),
						'APPLY_PROCESS':$F('APPLY_PROCESS'),
						'CRED_ID':$F('CRED_ID'),
						'CAPT_DATE':$F('CAPT_DATE'),
						'BUILD_NO1':$F('BUILD_NO1'),
						'BUILD_NO2':$F('BUILD_NO2'),
						'INPUT_ID':$F('INPUT_ID'),
						'OLD_BUILD_NO1':$F('OLD_BUILD_NO1'),
						'OLD_BUILD_NO2':$F('OLD_BUILD_NO2'),
						'OCCUR_DATE':$F('OCCUR_DATE')
					   },
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
						showPageData(resp);
				}else{
					if(resp.DATA_NOT_FOUND){
						clearPageData();
					}						
				}
			}
	});
}


<%--
	退回
--%>
function doReject() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');
	
	<%-- 建號(主建物建號) 補0 --%>
	fillBuildingValue();	

	<%--
			9.	退回(B0008)
			9.1	畫面程序檢核: 
			9.1.1	檢查受理編號是否與查詢時不同:
			IF  APPLY_ID(受理編號-輸入欄位) NOT  =  OLD_APPLY_ID(受理編號-顯示欄位)
			    顯示錯誤訊息:‘欲退回的受理編號與原先查詢的資料不同，無法作業!’
			9.1.2	必輸欄位:退回原因
			9.1.3	顯示確認訊息‘確定要將此件退件回服務中心?’，確認後才繼續執行
	--%>
	var errorMessage = "";
	if($F('APPLY_ID') != $F('OLD_APPLY_ID')) {
		errorMessage += "欲刪除的受理編號與原先查詢的資料不同，無法作業!";		
	}

	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	<%-- 全型字檢查 --%>
	validateHalfType();
	replacetaiwan();
	if(validate4define.validate() == false)
		return ;
	
	if(confirm("確定要將此件退件回服務中心?") == false) {
		return ;
	}



	var conf = {};
	var url = "<%=dispatcher%>" + "/DSA1_0500/link1";
	conf.src = url;
	conf.width = document.body.scrollWidth*0.5;
	conf.height = document.body.scrollHeight*0.3;
	
	var oEvent = window.event ? window.event : e;
	conf.left = document.body.scrollLeft + oEvent.clientX - conf.width/2;
	conf.top = document.body.scrollTop + oEvent.clientY + 15;
	conf.scrolling = 'no';
	conf.isAdjWin = 'yes';
      
	conf.parameters = Object.toJSON({"width":conf.width, "height":conf.height});
	var callbackFun = function(objs){
		if(objs){
		
				<%--
					9.2	讀取畫面資料: 
					9.2.1	將畫面資料rtnMap存成mapA如下:
					欄位名稱	欄位值	說明
					OLD_APPLY_ID  	畫面上的受理編號	
					APPLY_PROCESS	畫面上的受理進度(隱藏欄位)	
					CRED_ID	畫面上的徵信人員ID(隱藏欄位)	
					CAPT_DATE	畫面上的組長覆核日期(隱藏欄位)	
					BUILD_NO1	畫面上的建號1	
					BUILD_NO2	畫面上的建號2	
					INPUT_ID	畫面上的建檔人員	
				--%>
			  	new Ajax.Request("<%=dispatcher%>/DSA1_0500/doReject", 
				{
						parameters:{
									'A050vo' : getA050(),
									'APPLY_ID':$F('APPLY_ID'),
									'REASON':objs,
									'APPLY_PROCESS':$F('APPLY_PROCESS'),
									'CRED_ID':$F('CRED_ID'),
									'CAPT_DATE':$F('CAPT_DATE'),
									'BUILD_NO1':$F('BUILD_NO1'),
									'BUILD_NO2':$F('BUILD_NO2'),
									'INPUT_ID':$F('INPUT_ID')
								   },
					 	onSuccess:function(XHT, resp){
							if(CSRUtil.isSuccess(resp)){
									showPageData(resp);
							}else{
								if(resp.DATA_NOT_FOUND){
									clearPageData();
								}						
							}
						}
				});
		}
	};
	hyperlinks.popup(conf, callbackFun);

}

<%--
	取消取件
--%>
function doRejectRetrieveItem() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%-- 建號(主建物建號) 補0 --%>
	fillBuildingValue();	

	<%--
		10.	取消取件(B0023)
		10.1	畫面程序檢核: 
		10.1.1	檢查受理編號是否與查詢時不同:
		IF  APPLY_ID(受理編號-輸入欄位) NOT  =  OLD_APPLY_ID(受理編號-顯示欄位)
		    顯示錯誤訊息:‘欲取消取件的受理編號與原先查詢的資料不同，無法作業!’
	--%>
	if($F('APPLY_ID') != $F('OLD_APPLY_ID')) {
		alert("欲刪除的受理編號與原先查詢的資料不同，無法作業!");
		return ;
	}
	
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	<%-- 全型字檢查 --%>
	validateHalfType();
	replacetaiwan();
	if(validate4define.validate() == false)
		return ;
	
	
	<%--
		10.2	讀取畫面資料: 
		10.2.1	將畫面資料rtnMap存成mapA如下:
		欄位名稱	欄位值	說明
		OLD_APPLY_ID  	畫面上的受理編號	
		APPLY_PROCESS	畫面上的受理進度(隱藏欄位)	
		CRED_ID	畫面上的徵信人員ID(隱藏欄位)	
		CAPT_DATE	畫面上的組長覆核日期(隱藏欄位)	
		BUILD_NO1	畫面上的地號(一)	
		BUILD_NO2	畫面上的地號(二)	
		ID	畫面上的所有權人ID	
		TRAN_DATE	畫面上的移轉年月	
		INPUT_ID	畫面上的建檔人員	
	--%>
  	new Ajax.Request("<%=dispatcher%>/DSA1_0500/doRejectRetrieveItem", 
	{
			parameters:{
						'A050vo' : getA050(),
						'APPLY_ID':$F('APPLY_ID'),
						'APPLY_PROCESS':$F('APPLY_PROCESS'),
						'CRED_ID':$F('CRED_ID'),
						'CAPT_DATE':$F('CAPT_DATE'),
						'BUILD_NO1':$F('BUILD_NO1'),
						'BUILD_NO2':$F('BUILD_NO2'),
						'INPUT_ID':$F('INPUT_ID')
					   },
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
						//showPageData(resp);
				}else{
					if(resp.DATA_NOT_FOUND){
						clearPageData();
					}						
				}
			}
	});
}

<%--
	建物謄本影像
--%>
function doBuildingImage() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');
	
	<%-- 建號(主建物建號) 補0 --%>
	fillBuildingValue();	

	<%--
		11.	建物謄本影像(B0033)
		11.1	超連結至DSA0_0100(影像-連結DP)畫面，供使用者查詢影像資料
		11.2	傳入參數：
		11.2.1	 APPLY_ID受理編號
	--%>
	popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
		'parameters': {'APPLY_ID': $F('APPLY_ID')},
		'fullScreen': false,
		'attributes': {'resizable': 'yes'}
	});
}

<%--
	拆件影像
--%>
function doTearDownImage() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');
	
	<%-- 建號(主建物建號) 補0 --%>
	fillBuildingValue();	

	<%--
		12.	拆件影像(B0025)
		12.1	超連結至DSA0_0200(影像-連結AV)畫面，供使用者查詢影像資料
		12.2	傳入參數：
		12.2.1	 APPLY_ID受理編號
	--%>
	popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
		'parameters': {'APPLY_ID': rtnMap['IS_SEPARATE']},
		'fullScreen': false,
		'attributes': {'resizable': 'yes'}
	});
}

<%--
	計算屋齡
--%>
function doBuildAge() {
	if(getValue('OLD_APPLY_ID') == "")
	{
		return ;
	}
	
	if($F('FINISH_DATE') == '' || isROCdate($F('FINISH_DATE')) == false ) {
		$('BUILD_AGE').value = '';
		$('SHOW_BUILD_AGE').innerHTML = '';
	}else {
	  	new Ajax.Request("<%=dispatcher%>/DSA1_0500/doBuildAge", 
		{
				parameters:{
							'OLD_APPLY_ID':$F('OLD_APPLY_ID'),
							'FINISH_DATE':toY2K($F('FINISH_DATE'))
						   },
			 	onSuccess:function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						$('BUILD_AGE').value = resp.HOUSE_AGE;
						$('SHOW_BUILD_AGE').innerHTML = resp.HOUSE_AGE;
					}
				}
		});
	}
}

<%--
	計算面積總合
--%>
function doMeasureCount() {

	<%--
		最新的資料在頁面的欄位上，因此，依序取讀MEASURE欄位資料
		不是合法的數值資料，就不加到LIST中
	--%>
	var passList =[];
	if(A051List != null && A051List.length != 0) {
		for(var mover=0; mover < A051List.length ; mover++) {
			var target_A051 = A051List[mover];
			var NOW_ROW_SEQ_NO = target_A051[SEQUENCE_NUMBER_COLUMN];
				
			var MEASURE_NAME = 'MEASURE' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var MEASURE_VALUE = $(MEASURE_NAME).value.replace(/,/g,'');

			var HOLD_BASE_NAME = 'HOLD_BASE' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var HOLD_BASE_VALUE = $(HOLD_BASE_NAME).value.replace(/,/g,'');

			var HOLD_UP_NAME = 'HOLD_UP' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var HOLD_UP_VALUE = $(HOLD_UP_NAME).value.replace(/,/g,'');
				
				
			if(MEASURE_VALUE !== "" && MEASURE_VALUE !== "0" && isNaN(MEASURE_VALUE) == false && 
			   HOLD_BASE_VALUE !== "" && HOLD_BASE_VALUE !== "0" && isNaN(HOLD_BASE_VALUE) == false && 
			   HOLD_UP_VALUE !== "" && HOLD_UP_VALUE !== "0" && isNaN(HOLD_UP_VALUE) == false
			) {
				passList.push({'MEASURE':MEASURE_VALUE,
							   'HOLD_BASE':HOLD_BASE_VALUE,
							   'HOLD_UP':HOLD_UP_VALUE
							  });
			}
		}
	}
	
	if(passList.length == 0) {
		$('SHOW_BUILD_MEASURE').innerHTML = "0";				
		$('BUILD_MEASURE').value = "0";
	}else {
	  	new Ajax.Request("<%=dispatcher%>/DSA1_0500/doTotalCounting", 
		{
				asynchronous : false,
				parameters:{ 'A051List' : Object.toJSON(passList)	},
			 	onSuccess:function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						$('SHOW_BUILD_MEASURE').innerHTML = CSRUtil.$fmt(getValue(resp.BUILD_MEASURE,"0"),"#,###.###");				
						$('BUILD_MEASURE').value = resp.BUILD_MEASURE;
					}
				}
		});
	}	
}


function doClear() {
	cleanMsgBoard();
	clearPageData();
	$('APPLY_ID').value = '';
}

//-->
</script>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		  <td width="15%" class="tbYellow">受理編號</td>
		  <td class="tbYellow2" colspan="4">
			<input type="text" size="14" maxlength="11" value ="" name="APPLY_ID" ID="APPLY_ID" class="textBox2">
			<input name="queryBtn" ID="queryBtn" onClick="doQuery()" type="button" class="button" value="查詢"> 
			<input name="buildingImageBtn"   ID="buildingImageBtn" onClick="doBuildingImage()" type="button" class="button" value="建物謄本影像">
			<input name="tearDownImageBtn"   ID="tearDownImageBtn" onClick="doTearDownImage()" type="button" class="button" value="拆件影像">	
		  </td>								                               
	</tr>	
	<tr>
		 <td colspan="5" align="center">
			<input name="insertBtn" ID="insertBtn" onClick="doInsert()" type="button" class="button"	value="新增"> 
			<input name="deleteBtn" ID="deleteBtn" onClick="doDelete()" type="button" class="button"	value="刪除"> 
			<input name="updateBtn" ID="updateBtn" onClick="doUpdate()" type="button" class="button" value="修正"> 
			<input name="updateIDBtn" ID="updateIDBtn" onClick="doUpdateConstructID()" type="button" class="button" value="修正建號"> 
			<input name="clearBtn" 	ID="clearBtn" onClick="doClear()" type="button" class="button" value="清除">		
			<input name="cancelBtn" ID="cancelBtn" onClick="doRejectRetrieveItem()" type="button" class="button" value="取消取件">		
			<input name="rejectBtn" ID="rejectBtn" onClick="doReject()" type="button" class="button"	value="退回">
			<input id="btn_update_for_bank" name="btn_update_for_bank" type="button" class="button" value="銀行件修改"><%--[20210311]新增按鈕[銀行件修改]--%>
			
			<input type="hidden" name="OLD_APPLY_ID" id="OLD_APPLY_ID" value="">
			<input type="hidden" name="OLD_BUILD_NO1" id="OLD_BUILD_NO1" value="">
			<input type="hidden" name="OLD_BUILD_NO2" id="OLD_BUILD_NO2" value="">
			<input type="hidden" name="INPUT_ID" id="INPUT_ID" value="">
			<input type="hidden" name="INPUT_DATE" id="INPUT_DATE" value="">
			<input type="hidden" name="APPLY_PROCESS" id="APPLY_PROCESS" value="">
			<input type="hidden" name="CRED_ID" id="CRED_ID" value="">
			<input type="hidden" name="CAPT_DATE" id="CAPT_DATE" value="">
			<input type="hidden" name="REASON" id="REASON" value="">
			<input type="hidden" name="BUILD_AGE" id="BUILD_AGE" value="">
			<input type="HIDDEN" name="BUILD_MEASURE" ID="BUILD_MEASURE" >
		</td>
	</tr>	
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
					<tr>
						<td colspan='5'>
							<%-- 
								=====================B 區=====================
							--%>
							<table id='B_grid' class="B_grid"></table>
						</td>
					</tr>
					
					<%-- 
						=====================C 區=====================
					--%>
					<tr class="block_c"><%--[20210311]加入block_c的class以快速檢核資料是否異動--%>
						  <td width="15%" class="tbYellow">受理編號</td>
						  <td width="25%" class="tbYellow2"><SPAN ID="SHOW_APPLY_ID"></SPAN></td>
						  <td width="15%" class="tbYellow">受理進度</td>
						  <td width="45%" class="tbYellow2" colspan="2"><SPAN ID="SHOW_APPLY_PROCESS_NM"></SPAN></td>
					</tr>				
					
					<tr class="block_c"><%--[20210311]加入block_c的class以快速檢核資料是否異動--%>
						  <td class="tbYellow">申請書門牌資料</td>
						  <td class="tbYellow2" colspan="4"><font color=red><span ID="SHOW_GAGE_ADDR" style="font-family:'EUDC'"></span><%--[20240723]難字調整 --%></font></td>
					</tr>
					<tr class="block_c"><%--[20210311]加入block_c的class以快速檢核資料是否異動--%>				  
						  <td class="tbYellow">房屋門牌號碼</td>
						  <td class="tbYellow2" colspan="4">
							<input type="text" name="ADDR_NO" ID="ADDR_NO" size="80" alt="ch"/><%--[20240723]難字調整 --%>
						  </td>
					</tr>
					<tr class="block_c"><%--[20210311]加入block_c的class以快速檢核資料是否異動--%>
						  <td class="tbYellow">建號(主建物建號)</td>
						  <td class="tbYellow2" >
							<input type="text" name="BUILD_NO1" ID="BUILD_NO1" maxlength="5" size="6" >─
							<input type="text" name="BUILD_NO2" ID="BUILD_NO2" maxlength="3" size="4" >
						  </td>
						  <td class="tbYellow">主建物判別碼</td>
						  <td class="tbYellow2">
								<input name='MAIN_BUILD' id = 'MAIN_BUILD_1' type="radio" value ='1'>是
								<input name='MAIN_BUILD' id = 'MAIN_BUILD_0' type="radio" value ='0'>否
						  </td>
					</tr>
					<tr class="block_c"><%--[20210311]加入block_c的class以快速檢核資料是否異動--%>
						  <td class="tbYellow">主要建材</td>
						  <td class="tbYellow2">
							<select name="MATERIAL" id="MATERIAL" class="textBox2">
								<option value="">請選擇</option>
								<c:forEach var="costRpt" items="${MATERIAL_LIST}">
									<option value="${costRpt.value}">${costRpt.key}</option>
								</c:forEach>
							</select>
						  </td>
						  <td class="tbYellow">主要用途</td>
						  <td class="tbYellow2" colspan="2">
							<select name="MAIN_USE" id="MAIN_USE" class="textBox2">
								<option value="">請選擇</option>
								<c:forEach var="costRpt" items="${MAIN_USE_LIST}">
									<option value="${costRpt.value}">${costRpt.key}</option>
								</c:forEach>
							</select>
						  </td>                             
					</tr>
					<tr class="block_c"><%--[20210311]加入block_c的class以快速檢核資料是否異動--%>
						  <td class="tbYellow">總層數</td>
						  <td class="tbYellow2">
							<input type="text" name="FLOOR" ID="FLOOR" size="3" maxlength="3" datatype="number" pattern="#,###" name="FLOOR" >
						  </td>
						  <td class="tbYellow">總面積</td>
						  <td class="tbYellow2" colspan="2">
						  	<span name="SHOW_BUILD_MEASURE" ID="SHOW_BUILD_MEASURE"/>
							<font size="2">平方公尺</font>
						  </td>                             
					</tr>
		  </table>
		  										
		  <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr align="center" class="tbYellow0">
				<td colspan="8" class="textBold">建物樓層資料</td>
			</tr>
		 </table>
		<%-- 
			=====================E 區=====================
		--%>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='D_grid'></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr align="center" class="tbYellow">
				<td>
					<input name="insertBtn_BLOCK_D" ID="insertBtn_BLOCK_D" onClick="insert_BlockD()" type="button" class="button"	value="新增"> 
					<input name="deleteBtn_BLOCK_D" ID="deleteBtn_BLOCK_D" onClick="delete_BlockD()" type="button" class="button" 	value="刪除"> 
				</td>
			</tr>
		</table>					
		 
		 
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr class="block_c"><%--[20210311]加入block_c的class以快速檢核資料是否異動--%>
				<td width="15%" class="tbYellow">建築完成日</td>
				<td width="20%" class="tbYellow2">
					<input name="FINISH_DATE" id="FINISH_DATE" type="text" class="textBox2" datatype="ROCDate" size="7" maxlength="7" onChange="doBuildAge();">
					<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor('FINISH_DATE');">
				</td>
				<td width="15%" class="tbYellow">屋齡</td>
				<td width="15%" class="tbYellow2">
					<span id ='SHOW_BUILD_AGE'></span>
				</td>
				<td width="15%" class="tbYellow">原因發生日期</td>
				<td width="20%" class="tbYellow2">
				    <input name="OCCUR_DATE" id="OCCUR_DATE" type="text" class="textBox2" datatype="ROCDate" size="7" maxlength="7" onchange='''>
					<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('OCCUR_DATE'))">
				</td>                                
			</tr>
		</table>
		 	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr align="center" class="tbYellow0">
				<td colspan="8" class="textBold">建物所有權人</td>
			</tr>
			<tr align="center" class="tbYellow0">
				  <td colspan="8" class="textBold">
				  </td>
			</tr>
		</table>					
		<%-- 
			=====================E 區=====================
		--%>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='E_grid'></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr align="center" class="tbYellow">
				<td>
					<input name="insertBtn_BLOCK_E" ID="insertBtn_BLOCK_E" onClick="insert_BlockE()" type="button" class="button"	value="新增"> 
					<input name="deleteBtn_BLOCK_E" ID="deleteBtn_BLOCK_E" onClick="delete_BlockE()" type="button" class="button" 	value="刪除"> 
				</td>
			</tr>
		</table>					
		
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr class="block_c"><%--[20210311]加入block_c的class以快速檢核資料是否異動--%>
				  <td width="15%" class="tbYellow">使用情形</td>
				  <td width="25%" class="tbYellow2">
					<select name="USE_STATUS" id="USE_STATUS" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach var="costRpt" items="${USE_STATUS_LIST}">
							<option value="${costRpt.value}">${costRpt.key}</option>
						</c:forEach>
					</select>
				  </td>
				  <td width="15%" class="tbYellow">建築型態</td>
				  <td width="45%" class="tbYellow2" colspan="2">
					<select name="BUILD_TYPE" id="BUILD_TYPE" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach var="costRpt" items="${BUILD_TYPE_LIST}">
							<option value="${costRpt.value}">${costRpt.key}</option>
						</c:forEach>
					</select>
				  </td>                             
			</tr>
			<tr class="block_c"><%--[20210311]加入block_c的class以快速檢核資料是否異動--%>
				  <td class="tbYellow">月租金</td>
				  <td class="tbYellow2">
					<input type="text" size="14" maxlength="13" name="RENTAL" datatype = "number" pattern="#,###" ID="RENTAL" value=0>
				  </td>
				  <td class="tbYellow">押金</td>
				  <td class="tbYellow2" colspan="2">
				    <input type="text" size="14" maxlength="13" name="DEPOSIT" datatype = "number" pattern="#,###" ID="DEPOSIT" value=0>
				  </td>                             
			</tr>		
			<tr class="block_c"><%--[20210311]加入block_c的class以快速檢核資料是否異動--%>
				  <td class="tbYellow">租期</td>
				  <td class="tbYellow2"  colspan="4">
					<input name="START_DATE" id="START_DATE" type="text" class="textBox2" datatype="ROCDate" size="7" maxlength="7" onchange='''>
					<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('START_DATE'))">
					~<input name="END_DATE" id="END_DATE" type="text" class="textBox2" datatype="ROCDate" size="7" maxlength="7">
					<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('END_DATE'))">
				  </td>                         
		     </tr>			
			 <tr>
							  <td class="tbYellow">輸入人員</td>
							  <td class="tbYellow2"><span id='SHOW_INPUT_ID' style="font-family:'EUDC'"></span><%--[20240723]難字調整 --%></td>
							  <td class="tbYellow">輸入日期</td>
							  <td class="tbYellow2"><SPAN ID="SHOW_INPUT_DATE"></SPAN></td>                             								  
			 </tr>
					</table>
			</td>
		</tr> 
</table>


</body>
</html>


<script type="text/javascript" >
<!--
	<%--
		設定sequcenc number
	--%>
	function setSequenceNumber(sourceList,columnName) {
		var serialNumber = 1;
		for(var mover=0; mover < sourceList.length ; mover++) {
			var targetRow = sourceList[mover];
			targetRow[columnName] = serialNumber;
			serialNumber ++ ;
		}
	}


	<%--
		填補String 
	--%>
	function fillString(length,orgValue) {

		var fileString = "";
		for(var mover=0; mover < length - orgValue.length ; mover++) {
			fileString += "0";
		}
		fileString += orgValue;
		return 	fileString;
	}
	
	function haveValue(value) {
		if(value == null || value == undefined)
			return false;
		else
			return true;
	}

	<%--
		取得A050 VO
	--%>
	function getA050() {
	
		function setColumnValue(vo,name,value) {
			if(getValue(value) != "") {
				A050vo[name] = value;
			}
		}
		
		function setDateColumnValue(vo,name,value) {
			if(getValue(value) != "") {
				A050vo[name] = toY2K(value);
			}
		}
	
		A050vo = {};
		//ADDR_NO	房屋門牌號碼
		setColumnValue(A050vo,'ADDR_NO',$F('ADDR_NO'));

		//APPLY_ID	受理編號
		setColumnValue(A050vo,'APPLY_ID',$F('APPLY_ID'));

		//BUILD_AGE	屋齡
		setColumnValue(A050vo,'BUILD_AGE',$F('BUILD_AGE'));

		//BUILD_MEASURE	總面積
		setColumnValue(A050vo,'BUILD_MEASURE',$('BUILD_MEASURE').value.replace(/,/g,''));

		//BUILD_NO1	建號1
		setColumnValue(A050vo,'BUILD_NO1',$F('BUILD_NO1'));

		//BUILD_NO2	建號2
		setColumnValue(A050vo,'BUILD_NO2',$F('BUILD_NO2'));

		//BUILD_TYPE	建築型態
		setColumnValue(A050vo,'BUILD_TYPE',$F('BUILD_TYPE'));

		//DEPOSIT	押金
		setColumnValue(A050vo,'DEPOSIT',$('DEPOSIT').value.replace(/,/g,''));

		//END_DATE	租期迄日
		setDateColumnValue(A050vo,'END_DATE',$F('END_DATE'));
	
		//FINISH_DATE	建築完成日
		setDateColumnValue(A050vo,'FINISH_DATE',$F('FINISH_DATE'));
	
		//FLOOR	總層數
		setColumnValue(A050vo,'FLOOR',$F('FLOOR'));
	
		//INPUT_DATE	建檔日期
		setDateColumnValue(A050vo,'INPUT_DATE',$F('INPUT_DATE'));

		//INPUT_ID	建檔人員
		setColumnValue(A050vo,'INPUT_ID',$F('INPUT_ID'));

		//MAIN_BUILD	主建物判別碼
		setColumnValue(A050vo,'MAIN_BUILD',$('MAIN_BUILD_1').checked ? "1" : "0");

		//MAIN_USE	主要用途
		setColumnValue(A050vo,'MAIN_USE',$F('MAIN_USE'));

		//MATERIAL	主要建材
		setColumnValue(A050vo,'MATERIAL',$F('MATERIAL'));

		//OTHER_USE	主要用途其他說明
		//setColumnValue(A050vo,'OTHER_USE',$F('OTHER_USE'));

		//RENTAL	月租金
		setColumnValue(A050vo,'RENTAL',$('RENTAL').getValue().replace(/,/g,''));

		//START_DATE	租期起日
		setDateColumnValue(A050vo,'START_DATE',$F('START_DATE'));

		//USE_STATUS	使用情形	
		setDateColumnValue(A050vo,'USE_STATUS',$F('USE_STATUS'));
		
		//OCCUR_DATE	原因發生日期
		setDateColumnValue(A050vo,'OCCUR_DATE',$F('OCCUR_DATE'));
		
		return Object.toJSON(A050vo);
	}

	<%--
		取得Block的One Row
	--%>
	function getNewRow_BlockD(classType,targetRow,rowForDisplay,TARGET_SEQ_NO) {
		
		<%--
			取得ItemList的內容
		--%>
		function getITEM_LIST_content(selectDefaultValue) {
		
			var selectValue = (selectDefaultValue === "" ? selectDefaultValue : '0');
		
			var returnString="";
			if(selectDefaultValue == '0') {
				returnString += '<option value="' + '0' + '" selected>' + '請選擇' + '</option> '
			}else {
				returnString += '<option value="' + '0' + '">' + '請選擇' + '</option> '
			}
			if(selectDefaultValue == '1') {
				returnString += '<option value="' + '1' + '" selected>' + '層次' + '</option> '
			}else {
				returnString += '<option value="' + '1' + '">' + '層次' + '</option> '
			}
			
			
			<c:forEach var="costRpt" items="${ITEM_LIST}">
				if(selectDefaultValue == '${costRpt.value}') {
					returnString += '<option value="' + '${costRpt.value}' + '" selected>' + '${costRpt.key}' + '</option> '
				}else {
					returnString += '<option value="' + '${costRpt.value}' + '">' + '${costRpt.key}' + '</option> '
				}
			</c:forEach>
			
			
			if(selectDefaultValue == 'V') {
				returnString += '<option value="' + 'V' + '" selected>' + '其他' + '</option> '
			}else {
				returnString += '<option value="' + 'V' + '">' + '其他' + '</option> '
			}
			
			return returnString;
		}
		
		<%--
			取得ItemList Key所對應的顯示文字
		--%>
		function getITEM_LIST_showWord(value) {
			if(value == '1') {
				return '層次';
			}
			if(value == 'V') {
				return '其他';
			}
		
			<c:forEach var="costRpt" items="${ITEM_LIST}">
				if(value == '${costRpt.value}') {
					return '${costRpt.key}';
				}
			</c:forEach>
			return "";
		}
		
		
		<%--
			radio item column
		--%>
		var radioString = '<input type="radio" name="RADIO_D" value="##<TARGET_SEQ_NO>##" />';
		radioString = radioString.replace(/##<TARGET_SEQ_NO>##/g,TARGET_SEQ_NO);
		var oneRow = getHTMLTAG( { 
									'tagName' : "td", 
									'widthValue' : "5%", 
									'classValue' : null, 
									'alignValue' : null, 
									'insertValue' : radioString 
								});
		


		<%--
			畫面			層次─XX層	(下拉選單)YY – ZZ	XX  YY – ZZ
			CELL_NO			A~G				H~L				M~O
			ITEM			XX			(下拉選單)值			XX
			AUX_NO1							YY				YY
			AUX_NO2							ZZ				ZZ
		--%>
		<%--
			所有權人	NAME	A052List[i].NAME	顯示欄位		
		--%>
		var selectListValue;
		var CELL_NO_VALUE = getValue(targetRow['CELL_NO']);
		var selectListDefaultValue;
		
		
		<%--
			這邊是最終CELL_NO值，依條件決定下拉值
			if 		ITEM_LIST 選擇“層次” then 值 = ‘A’		下拉實值 ==> 1
			elseif 	ITEM_LIST 選擇“其他” then 值 = ‘M’		下拉實值 ==> V
			else值 = ‘H’	下拉實值 ==> !(1,V) 存於ITEM欄位上
			end if 
		--%>
		if(CELL_NO_VALUE == "A" || CELL_NO_VALUE == "B" || CELL_NO_VALUE == "C" || CELL_NO_VALUE == "D" || CELL_NO_VALUE == "E" || CELL_NO_VALUE == "F" || CELL_NO_VALUE == "G") {

			<%--當下拉值為1時，CELL_NO的值應填'A'--%>
			selectListDefaultValue = "1";
		}else if(CELL_NO_VALUE == "M" || CELL_NO_VALUE == "N" || CELL_NO_VALUE == "O") {

			<%--當下拉值為V時，CELL_NO的值應填'M'--%>
			selectListDefaultValue = "V";
		}else {

			<%--當下拉值為!(1,V)時，CELL_NO的值應填'H'--%>
			selectListDefaultValue = getValue(targetRow['ITEM']);
		}
		
		var spanSetMap = {};
		spanSetMap['displayPartID'] = 'SPAN' + '_' + 'CELL_NO' + '_' + 'DISPLAY' + '_' +TARGET_SEQ_NO;
		spanSetMap['displayPartOrNot'] = rowForDisplay;
		var showText = "";
		if(CELL_NO_VALUE == "A" || CELL_NO_VALUE == "B" || CELL_NO_VALUE == "C" || CELL_NO_VALUE == "D" || CELL_NO_VALUE == "E" || CELL_NO_VALUE == "F" || CELL_NO_VALUE == "G") {
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : '層次: '
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : getValue(targetRow['ITEM'])
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : ' 層'
						});
		}
		else if(CELL_NO_VALUE == "M" || CELL_NO_VALUE == "N" || CELL_NO_VALUE == "O") {
			//其他
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : "其他: "
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : getValue(targetRow['ITEM'])
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : ' '
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : getValue(targetRow['AUX_NO1'])
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : ' - '
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : getValue(targetRow['AUX_NO2'])
						});
		}
		else {
			// || CELL_NO_VALUE == "H"
			//非層次非其他
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : getITEM_LIST_showWord(getValue(targetRow['ITEM']))
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : ' : '
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : getValue(targetRow['AUX_NO1'])
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : ' - '
						});
			showText += getFontHTML( {
							'idValue' : null,
							'styleValue' : true,
							'insertValue' : getValue(targetRow['AUX_NO2'])
						});
		}
		spanSetMap['displayPart'] = showText;
		
		spanSetMap['inputPartID'] = 'SPAN' + '_' + 'CELL_NO' + '_' + 'INPUT' + '_' + TARGET_SEQ_NO ;
		spanSetMap['inputPartOrNot'] = !rowForDisplay;

		spanSetMap['inputPart'] =	getSelectListHTML( {
										'idValue' : 'CELL_NO' + '_' + 'INPUT' + '_' + TARGET_SEQ_NO,
										'styleValue' : true,
										'options' : getITEM_LIST_content(selectListDefaultValue),
										'onchangeValue' : 'ItemListOnChnageFun(this.value,\'TARGET_SEQ_NO\');clearAllInputValue(\'TARGET_SEQ_NO\');'.replace(/TARGET_SEQ_NO/g,TARGET_SEQ_NO)
									})
									+
									getInputTextHTML( {
										'idValue' : 'ITEM' + '_' + 'INPUT' + '_' + TARGET_SEQ_NO,
										'valueValue' : getValue(targetRow['ITEM']),
										'sizeValue' : "10",
										'maxlengthValue' : null,
										'styleValue' : false,
										'dataTypeValue' : null,
										'onchangeValue' : null
									})
									+
									getFontHTML( {
										'idValue' : 'LEVEL' + '_'  + 'INPUT' + '_' + TARGET_SEQ_NO,
										'styleValue' : false,
										'insertValue' : '層'
									})							
									+
									getInputTextHTML( {
										'idValue' : 'AUX_NO1' + '_' + 'INPUT' + '_' + TARGET_SEQ_NO,
										'valueValue' : getValue(targetRow['AUX_NO1']),
										'sizeValue' : 5,
										'maxlengthValue' :5,
										'styleValue' : false,
										'dataTypeValue' : null
									})
									+
									getFontHTML( {
										'idValue' : 'CONNECTOR' + '_' + 'INPUT' + '_' + TARGET_SEQ_NO,
										'styleValue' : false,
										'insertValue' : '-'
									})								
									+									
									getInputTextHTML( {
										'idValue' : 'AUX_NO2' + '_' + 'INPUT' + '_' + TARGET_SEQ_NO,
										'valueValue' : getValue(targetRow['AUX_NO2']),
										'sizeValue' : 3,
										'maxlengthValue' : 3,
										'styleValue' : false,
										'dataTypeValue' : null
									}) ;
		oneRow += 		getHTMLTAG( {
							'tagName' : "td",
							'widthValue' : "40%",
							'classValue' : null,
							'alignValue' : null,
							'insertValue' : getTDColumnSPAN(spanSetMap)
						});

		<%--
			//面積	MEASURE	預設為0	數字格式輸入欄位，小數點3位、整數12位，須為正整數
			面積(平方公尺)	MEASURE	A051List[i].MEASURE	顯示欄位
		--%>
		targetColumnName = 'MEASURE';
		targetColumnValue = CSRUtil.$fmt(getValue(targetRow[targetColumnName]),"#,###.###");
		spanSetMap = {};
		spanSetMap['displayPartID'] = 'SPAN' + '_' + targetColumnName + '_' + 'DISPLAY' + '_' +TARGET_SEQ_NO;
		spanSetMap['displayPartOrNot'] = rowForDisplay;
		spanSetMap['displayPart'] = getFontHTML( {
										'idValue' : null,
										'styleValue' : true,
										'insertValue' : targetColumnValue
									});
		spanSetMap['inputPartID'] = 'SPAN' + '_' + targetColumnName + '_' + 'INPUT' + '_' +TARGET_SEQ_NO ;
		spanSetMap['inputPartOrNot'] = !rowForDisplay;
		spanSetMap['inputPart'] =		getInputTextHTML( {
										'idValue' : targetColumnName + '_' + 'INPUT' + '_' +TARGET_SEQ_NO,
										'valueValue' : targetColumnValue,
										'sizeValue' : "14",
										'maxlengthValue' : "20",
										'styleValue' : true,
										'dataTypeValue' : "number",
										'patternValue' : "#,###.###",
										'onblurValue' : "doMeasureCount()"
									});
		oneRow += 		getHTMLTAG( {
							'tagName' : "td",
							'widthValue' : "20%",
							'classValue' : null,
							'alignValue' : null,
							'insertValue' : getTDColumnSPAN(spanSetMap)
		});
	
		<%--
			持份分母	HOLD_BASE	預設為1	數字格式輸入欄位，長度15
			持份分子	HOLD_UP	預設為1	數字格式輸入欄位，長度15
		
			持份(分母)	HOLD_BASE	A051List[i].HOLD_BASE	顯示欄位
			持份(分子)	HOLD_UP		A051List[i].HOLD_UP	顯示欄位
		--%>
		var leftPart = 'HOLD_BASE';
		var rightPart = 'HOLD_UP';
		var leftPartValue = CSRUtil.$fmt(getValue(targetRow[leftPart],'0'),"#,###");
		var rightPartValue = CSRUtil.$fmt(getValue(targetRow[rightPart],'0'),"#,###");
		targetColumnName = 'HOLD_BASE_HOLD_UP';
		spanSetMap = {};
		spanSetMap['displayPartID'] = 'SPAN' + '_' + targetColumnName + '_' + 'DISPLAY' + '_' +TARGET_SEQ_NO;
		spanSetMap['displayPartOrNot'] = rowForDisplay;
		spanSetMap['displayPart'] = 	getFontHTML( {
											'idValue' : null,
											'styleValue' : true,
											'insertValue' : leftPartValue + "分之" + rightPartValue
									});
		spanSetMap['inputPartID'] = 'SPAN' + '_' + targetColumnName + '_' + 'INPUT' + '_' +TARGET_SEQ_NO ;
		spanSetMap['inputPartOrNot'] = !rowForDisplay;
		spanSetMap['inputPart'] =		getInputTextHTML( {
											'idValue' : leftPart + '_' + 'INPUT' + '_' +TARGET_SEQ_NO,
											'valueValue' : leftPartValue,
											'sizeValue' : "14",
											'maxlengthValue' : "19",
											'styleValue' : true,
											'patternValue' : "#,###",
											'dataTypeValue' : "number",
											'onblurValue' : "doMeasureCount()"
										})
										+ 		
										getFontHTML( {
											'idValue' : null,
											'styleValue' : true,
											'insertValue' : "分之"
										})
										+
										getInputTextHTML( {
											'idValue' : rightPart + '_' + 'INPUT' + '_' +TARGET_SEQ_NO,
											'valueValue' : rightPartValue,
											'sizeValue' : "14",
											'maxlengthValue' : "19",
											'styleValue' : true,
											'patternValue' : "#,###",
											'dataTypeValue' : "number",
											'onblurValue' : "doMeasureCount()"
										})										
										;										
		oneRow += 		getHTMLTAG( {
							'tagName' : "td",
							'widthValue' : "35%",
							'classValue' : null,
							'alignValue' : null,
							'insertValue' : getTDColumnSPAN(spanSetMap)
		});

		
		<%--
			建立tr
		--%>
		oneRow = 		getHTMLTAG( {
					'tagName' : "tr",
					'widthValue' : null,
					'classValue' : classType,
					'alignValue' : 'center',
					'insertValue' : oneRow
		});
		return oneRow;
	}


	 <%--
		依List建構區塊D資料
	--%>
	function constructRows_BlockD(tableName,dataList) {
		var dataTable = $(tableName);
		var le = dataTable.rows.length;
		for(i=le;i>0;i--){
			dataTable.deleteRow(0);
		}
		var content = '<tr align="center" class="tbBlue" >'
							+ '<td>選取</td>'
							+ '<td>項目/建號</td>'
							+ '<td>面積(平方公尺)</td>'
							+ '<td>持份</td>'
							+ '</tr>' ;
		
		if(dataList == null || dataList == undefined) {
			dataTable.insert({top: content});		
			return ;
		}
		
		var classType;
		var targetRow;
		var onlyDisplayOrNot = false;
		for(var mover=0; mover < dataList.length ; mover++) {
			targetRow = dataList[mover];
			classType = (mover % 2 == 0 ? "tbYellow2" : "tbYellow2" );
			content += getNewRow_BlockD(classType,targetRow,onlyDisplayOrNot,targetRow[SEQUENCE_NUMBER_COLUMN]);
		}
		dataTable.insert({top : content});
	
		for(var mover=0; mover < A051List.length ; mover++) {
			var target_A051 = A051List[mover];
			var TARGET_SEQ_NO = target_A051[SEQUENCE_NUMBER_COLUMN];
			var selectListValue = $F('CELL_NO' + '_' + 'INPUT' + '_' + TARGET_SEQ_NO);
			ItemListOnChnageFun(selectListValue,TARGET_SEQ_NO);
		}
	}

	<%--
		===================================================================================================================================
	--%>

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
		取得Block的One Row
	--%>
	function getNewRow_BlockE(classType,targetRow,rowForDisplay,TARGET_SEQ_NO) {
		/*
			radio item column
		*/
		var radioString = '<input type="radio" name="RADIO_E" value="##<TARGET_SEQ_NO>##" />';
		radioString = radioString.replace(/##<TARGET_SEQ_NO>##/g,TARGET_SEQ_NO);
		var oneRow = getHTMLTAG( {
							'tagName' : "td",
							'widthValue' : "5%",
							'classValue' : null,
							'alignValue' : null,
							'insertValue' : radioString
						});
		<%--
			所有權人	NAME	A052List[i].NAME	顯示欄位
		--%>
		var targetColumnName = 'NAME';
		var targetColumnValue = getValue(targetRow[targetColumnName]);
		var spanSetMap = {};
		spanSetMap['displayPartID'] = 'SPAN' + '_' + targetColumnName + '_' + 'DISPLAY' + '_' +TARGET_SEQ_NO;
		spanSetMap['displayPartOrNot'] = rowForDisplay;
		spanSetMap['displayPart'] = 	getFontHTML( {
										'idValue' : null,
										'styleValue' : true,
										'insertValue' : targetColumnValue,
										'classValue' : "addEUDC"<%-- [20240723]難字調整  --%>
									});
		spanSetMap['inputPartID'] = 'SPAN' + '_' + targetColumnName + '_' + 'INPUT' + '_' +TARGET_SEQ_NO ;
		spanSetMap['inputPartOrNot'] = !rowForDisplay;
		spanSetMap['inputPart'] =		getInputTextHTML( {
										'idValue' : targetColumnName + '_' + 'INPUT' + '_' +TARGET_SEQ_NO,
										'valueValue' : targetColumnValue,
										'sizeValue' : "80",//原住民
										'maxlengthValue' : null,
										'styleValue' : true,
										'dataTypeValue' : null,
										'classValue' : "addEUDC"<%-- [20240723]難字調整  --%>
									});
		 
		oneRow += 		getHTMLTAG( {
							'tagName' : "td",
							'widthValue' : "45%",
							'classValue' : null,
							'alignValue' : null,
							'insertValue' : getTDColumnSPAN(spanSetMap)
						});
						
		
		<%--
			所有權人ID	ID	A052List[i].ID	顯示欄位
		--%>
		targetColumnName = 'ID';
		targetColumnValue = getValue(targetRow[targetColumnName]);
		spanSetMap = {};
		spanSetMap['displayPartID'] = 'SPAN' + '_' + targetColumnName + '_' + 'DISPLAY' + '_' +TARGET_SEQ_NO;
		spanSetMap['displayPartOrNot'] = rowForDisplay;
		spanSetMap['displayPart'] = 	getFontHTML( {
										'idValue' : null,
										'styleValue' : true,
										'insertValue' : targetColumnValue
									});
		spanSetMap['inputPartID'] = 'SPAN' + '_' + targetColumnName + '_' + 'INPUT' + '_' +TARGET_SEQ_NO ;
		spanSetMap['inputPartOrNot'] = !rowForDisplay;
		spanSetMap['inputPart'] =		getInputTextHTML( {
										'idValue' : targetColumnName + '_' + 'INPUT' + '_' +TARGET_SEQ_NO,
										'valueValue' : targetColumnValue,
										'sizeValue' : "10",
										'maxlengthValue' : "10",
										'styleValue' : true,
										'dataTypeValue' : null
									});
		oneRow += 		getHTMLTAG( {
							'tagName' : "td",
							'widthValue' : "25%",
							'classValue' : null,
							'alignValue' : null,
							'insertValue' : getTDColumnSPAN(spanSetMap)
		});
	
		<%--
			所有權人生日	BIRTHDAY	A052List[i].BIRTHDAY	顯示欄位
		--%>    
		<%--            
		targetColumnName = 'BIRTHDAY';
		targetColumnValue = getValue(targetRow[targetColumnName]);
		spanSetMap = {};
		spanSetMap['displayPartID'] = 'SPAN' + '_' + targetColumnName + '_' + 'DISPLAY' + '_' + TARGET_SEQ_NO;
		spanSetMap['displayPartOrNot'] = rowForDisplay;
		spanSetMap['displayPart'] = 	getFontHTML( {
											'idValue' : null,
											'styleValue' : true,
											'insertValue' : toROC_delimiter(targetColumnValue)
									});
		spanSetMap['inputPartID'] = 'SPAN' + '_' + targetColumnName + '_' + 'INPUT' + '_' + TARGET_SEQ_NO ;
		spanSetMap['inputPartOrNot'] = !rowForDisplay;
		spanSetMap['inputPart'] =		getInputTextHTML( {
											'idValue' : targetColumnName + '_' + 'INPUT' + '_' + TARGET_SEQ_NO,
											'valueValue' : targetColumnValue,
											'sizeValue' : '7',
											'maxlengthValue' : '7',
											'styleValue' : true,
											'dataTypeValue' : "ROCDate"
										})
										+ 		
										getImageHTML( {
											'inputTextName' : targetColumnName + '_' + 'INPUT' + '_' + TARGET_SEQ_NO
										})
										;
		oneRow += 		getHTMLTAG( {
							'tagName' : "td",
							'widthValue' : "25%",
							'classValue' : null,
							'alignValue' : null,
							'insertValue' : getTDColumnSPAN(spanSetMap)
		});
		--%>
		oneRow += 		getHTMLTAG( {
							'tagName' : "td",
							'widthValue' : "25%",
							'classValue' : null,
							'alignValue' : null,
							'insertValue' : toROC_delimiter(getValue(targetRow['BIRTHDAY']))
		});

		<%--
			建立tr
		--%>
		oneRow = 		getHTMLTAG( {
			'tagName' : "tr",
			'widthValue' : null,
			'classValue' : classType,
			'alignValue' : 'center',
			'insertValue' : oneRow
		});
		return oneRow;
	}
	
	 <%--
		依List建構區塊E資料
	--%>
	function constructRows_BlockE(tableName,dataList) {
		
		<%--
			(E區)建物所有權人資料
			所有權人	NAME	A052List[i].NAME	顯示欄位
			所有權人ID	ID	A052List[i].ID	顯示欄位
			所有權人生日	BIRTHDAY	A052List[i].BIRTHDAY	顯示欄位
		--%>
		var dataTable = $(tableName);
		var le = dataTable.rows.length;
		for(i=le;i>0;i--){
			dataTable.deleteRow(0);
		}
		var content = '<tr align="center" class="tbBlue" >'
							+ '<td>選取</td>'
							+ '<td>所有權人</td>'
							+ '<td>所有權人ID</td>'
							+ '<td>所有權人生日</td>'
							+ '</tr>' ;
		
		if(dataList == null || dataList == undefined) {
			dataTable.insert({top: content});		
			return ;
		}
		
		var classType;
		var targetRow;
		var onlyDisplayOrNot = false;
		for(var mover=0; mover < dataList.length ; mover++) {
			targetRow = dataList[mover];
			classType = (mover % 2 == 0 ? "tbYellow2" : "tbYellow2" )
			content += getNewRow_BlockE(classType,targetRow,onlyDisplayOrNot,targetRow[SEQUENCE_NUMBER_COLUMN]);
		}
		dataTable.insert({top : content});
		
		<%-- [20240723]難字調整 --%>
		$$('#E_grid .addEUDC').each(function(elem){
			var tagName = elem.tagName;
			if('INPUT' == tagName){
				elem.setAttribute('alt','ch');
			}else{
				elem.setStyle({"font-family": 'EUDC'});
		 	}		
		});
		parseEUDC();
	}
	
	
	
function UI(){

	return{
	
		init:function(){
				<%--
					選取			點選欄位，預設第一筆資料checked
				--%>
		
				B_grid = new TableUI( 
					{
		                table: $("B_grid"), 
		                pageSize: 3, 
		                allSortable: true,
		                overDiv:false,
						afterLoad:function(tableElement){
							var inputs = $('B_grid').select("input[type='radio']");
							var length = inputs.length;
							if(length > 0){
								inputs[0].checked = true;
							}
						},
		                autoCheckBox:{ isSelectAll :true,type: 'radio'
							,action: function (checkbox , boxStatus , records) {
								if(!boxStatus){return;}
								<%--
									3.	選取radio(B區)
									3.1	畫面程序檢核: 無
									3.2	讀取畫面資料: 無
									3.3	資料檢核: 無
									3.4	資料處理: 
									3.4.1	建物謄本資料檔rtnA050Map = 點選之資料
									3.4.2	取出建物樓層資料檔A051List = DS_A10500.queryA051(rtnA050Map.APPLY_ID, rtnA050Map.BUILD_NO1, rtnA050Map.BUILD_NO2)，若查無資料視為正常
									3.4.3	取出建物所有權人資料檔A052List = DS_A10500.queryA052(rtnA050Map.APPLY_ID, rtnA050Map.BUILD_NO1, rtnA050Map.BUILD_NO2)，若查無資料視為正常
									3.4.4	寫入個資LOG，將以下欄位存成Map:
									欄位名稱	值	說明
									以下欄位紀錄建物所有權人資料(DTDSA052)資訊：逐筆讀取A052List
									A052_ID[i]	A052List[i].ID	所有權人ID
									A052_NAME[i]	A052List[i].NAME	所有權人姓名
									A052_BIRTHDAY[i]	A052List[i].BIRTHDAY	所有權人生日
									3.5	畫面顯示: 
									3.5.1	將點選的資料顯示於區塊C、區塊D、區塊E,畫面顯示欄位值如查詢
									3.5.2	不必顯示訊息
								--%>
								var data = B_grid.getCheckedRecord();	
								var targetRow = data[0];
							
							  	new Ajax.Request("<%=dispatcher%>/DSA1_0500/doRadioB", 
								{
										parameters:{'APPLY_ID':targetRow['APPLY_ID'],
													'BUILD_NO1':targetRow['BUILD_NO1'],
													'BUILD_NO2':targetRow['BUILD_NO2']										
										},
									 	onSuccess:function(XHT, resp){
											if(CSRUtil.isSuccess(resp)){
													<%--
														3.5.1	將點選的資料顯示於區塊C、區塊D、區塊E,畫面顯示欄位值如查詢
													--%>
													radioBfreshPage(resp,rtnMap,targetRow);
											}else{
												if(resp.DATA_NOT_FOUND){
													radioBfreshPage({},{},{});
												}						
											}
										}
								});
							
							
							}
		                },
		                split: ["BUILD_MEASURE"],   
						column:[
			                    <%-- 
									建號(主建物建號)	A050_ BUILD_NO	
									rtnList[i]. BUILD_NO1+‘-’rtnList[i]. BUILD_NO2	顯示欄位
			                    --%>
			                    { header: "建號(主建物建號)", key: "BUILD_NO", 
									render: function (record, value) {
										var BUILD_NO1 = record.BUILD_NO1 ? record.BUILD_NO1 : "";
										var BUILD_NO2 = record.BUILD_NO2 ? record.BUILD_NO2 : "";
										return 	BUILD_NO1	+ '-' + BUILD_NO2;				
									}
								},
			                    <%-- 
									房屋門牌號碼	A050_ADDR_NO	
									rtnList[i].ADDR_NO	顯示欄位
			                    --%>
			                    { header: "房屋門牌號碼", key: "ADDR_NO",  attrs:{colSpan:5, style:"font-family:'EUDC'"} ,<%--[20240723]難字調整 --%>
									render: function (record, value) {
										return 	value ? value.trim() : "";				
									}
								},
			                    <%-- 
									主要建材	A050_MATERIAL	
									rtnList[i].MATERIAL_NM	顯示欄位
			                    --%>
			                    { header: "主要建材", key: "MATERIAL_NM" ,
									render: function (record, value) {
										return 	value ? value : "";				
									}
								},
			                    <%-- 
									主要用途	A050_MAIN_USE	
									rtnList[i].MAIN_USE_NM	顯示欄位
			                    --%>
			                    { header: "主要用途", key: "MAIN_USE_NM",
									render: function (record, value) {
										return 	value ? value : "";				
									}
								},
			                    <%-- 
									總層數	A050_FLOOR	
									rtnList[i].FLOOR	顯示欄位			                    
								--%>
			                    { header: "總層數", key: "FLOOR",
									render: function (record, value) {
										return 	value ? value : "";				
									}
								},
			                    <%-- 
									總面積	A050_BUILD_MEASURE	
									rtnList[i].BUILD_MEASURE	顯示欄位
								--%>
			                    { header: "總面積", key: "BUILD_MEASURE",
									render: function (record, value) {
										return 	value ?  CSRUtil.$fmt(value,"#,###.############") : "";				
									}
								},
			                    <%-- 
									建築完成日	A050_FINISH_DATE	
									rtnList[i].FINISH_DATE	顯示欄位,日期欄位
								--%>
			                    { header: "建築完成日", key: "FINISH_DATE_ROC",
									render: function (record, value) {
										return 	value ? toROC_delimiter(value) : "";				
									}
								},
			                    <%-- 
									屋齡	A050_BUILD_AGE	
									rtnList[i].BUILD_AGE	顯示欄位
								--%>
			                    { header: "屋齡", key: "BUILD_AGE",
									render: function (record, value) {
										return 	value ? value : "";				
									}
								},
								<%-- 
									原因發生日期	A050_OCCUR_DATE	
									rtnList[i].OCCUR_DATE	顯示欄位,日期欄位
								--%>
			                    { header: "原因發生日期", key: "OCCUR_DATE_ROC",
									render: function (record, value) {
										return 	value ? toROC_delimiter(value) : "";				
									}
								},
			                    <%-- 
									使用情形	A050_USE_STATUS	
									rtnList[i].USE_STATUS_NM	顯示欄位
								--%>
			                    { header: "使用情形", key: "USE_STATUS_NM",
									render: function (record, value) {
										return 	value ? value : "";				
									}
								},
			                    <%-- 
									建築型態	A050_BUILD_TYPE	
									rtnList[i].BUILD_TYPE_NM	顯示欄位
								--%>
			                    { header: "建築型態", key: "BUILD_TYPE_NM",
									render: function (record, value) {
										return 	value ? value : "";				
									}
								},
			                    <%-- 
									月租金	A050_RENTAL	
									rtnList[i].RENTAL	顯示欄位,金額欄位
								--%>
			                    { header: "月租金", key: "RENTAL",attrs:{ align : "right" },
									render: function (record, value) {
										return 	value ? CSRUtil.$fmt(value,"#,###.############") : "";				
									}
								},
			                    <%-- 
									押金	A050_DEPOSIT	
									rtnList[i].DEPOSIT	顯示欄位,金額欄位
								--%>
			                    { header: "押金", key: "DEPOSIT",attrs:{ align : "right" },
									render: function (record, value) {
										return 	value ? CSRUtil.$fmt(value,"#,###.############") : "";				
									}
								},
			                    <%-- 
									租期	A050_START_DATE	
									rtnList[i].START_DATE +‘~’+rtnList[i]. END_DATE	顯示欄位,日期欄位
								--%>
			                    { header: "租期", key: "START_DATE",
									render: function (record, value) {
										var START_DATE = record.START_DATE_ROC ? toROC_delimiter(record.START_DATE_ROC) : "";
										var END_DATE = record.END_DATE_ROC ? toROC_delimiter(record.END_DATE_ROC) : "";
										return 	START_DATE	+ '~' + END_DATE;				
									}
								}
						]
					}
				);
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
	}
	

	<%--
		===================================================================================================================================
	--%>

	<%--
		取得值，當是空時，回傳""
	--%>
	function getValue(value,defaultValue) {
	
		function falseCondition(testValue) {
			if(testValue == null || typeof(testValue) == 'undefined'){
				return true;
			}else {
				return false;
			}
		}
	
		if(falseCondition(value)) {
			if(falseCondition(defaultValue)) {
				return "";
			}else {
				return defaultValue;
			}
		}else {
			return value;
		}
	}
	
	<%--
		設定屬性值
	--%>
	function formulatOneAttribute(attributeName , attributeValue) {
		var content = "";
		if(attributeValue != null && typeof(attributeValue) != 'undefined') {
			content +=	'	';
			content += 	attributeName + '="';
			content +=	attributeValue;
			content +=	'"';
			content +=	'	';
		}
		return content;
	}
	
	<%--
		取得一個input text tag
		getImageHTML( {
			'inputTextName' :
		});
	--%>
	function getImageHTML(setMap) {
		var content = '<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($(\'##<inputTextName>##\'))">';
		content = content.replace(/##<inputTextName>##/g,	setMap['inputTextName']	);
		return content;
	}
	
	<%--
		取得ITEM LIST
		getSelectListHTML( {
			'idValue' : ,
			'styleValue' : ,
			'options' : ,
			'onchangeValue' :
		});
	--%>
	function getSelectListHTML(setMap) {
	
		var content = '<select ##<idValue>## ##<styleValue>## ##<onchangeValue>## > ##<options>## </select>';
		content = content.replace(/##<idValue>##/g,	formulatOneAttribute('id',setMap['idValue'])	);
		if(isNotEmpty(setMap['styleValue'])) {
			content = content.replace(/##<styleValue>##/g,	formulatOneAttribute('style',getSytleSetValue(	setMap['styleValue'])  )	);
		}else {
			content = content.replace(/##<styleValue>##/g,	""	);
		}
		content = content.replace(/##<onchangeValue>##/g,	formulatOneAttribute('onChange',setMap['onchangeValue'])	);
		content = content.replace(/##<options>##/g,	getValue(setMap['options'])	);
		return content;
	}
	
	<%--
		取得一個font
		getInputTextHTML( {
			'idValue' : 
			'styleValue' : 
			'insertValue' : 
		});
	--%>
	function getFontHTML(setMap) {
		var content = '<span type="text" ##<classValue>##  ##<idValue>## ##<styleValue>##>##<insertValue>##</span>';
		content = content.replace(/##<idValue>##/g,	formulatOneAttribute('id',setMap['idValue'])	);
		if(isNotEmpty(setMap['styleValue'])) {
			content = content.replace(/##<styleValue>##/g,	formulatOneAttribute('style',getSytleSetValue(	setMap['styleValue'])  )	);
		}else {
			content = content.replace(/##<styleValue>##/g,	""	);
		}
		content = content.replace(/##<insertValue>##/g,	getValue(setMap['insertValue'])	);
		content = content.replace(/##<classValue>##/g,	formulatOneAttribute('class',setMap['classValue']));<%--[20240723]難字調整--%>
		
		return content;
	}
	
	<%--
		取得一個input text tag
		getInputTextHTML( {
			'idValue' : ,
			'valueValue' : ,
			'sizeValue' : ,
			'maxlengthValue' : ,
			'styleValue' : ,
			'dataTypeValue' : ,
			'onchangeValue' : ,
			'pattern' :
		});
	--%>
	function getInputTextHTML(setMap) {
		var content = '<input type="text" ##<idValue>## ##<valueValue>## ##<sizeValue>## ##<classValue>## ' + 
					  '##<maxlengthValue>## ##<styleValue>## ##<dataTypeValue>## ##<patternValue>## ##<onchangeValue>## ##<onblurValue>##>';

		content = content.replace(/##<idValue>##/g,	formulatOneAttribute('id',setMap['idValue'])	);
		content = content.replace(/##<valueValue>##/g,	formulatOneAttribute('value',setMap['valueValue'])	);
		content = content.replace(/##<sizeValue>##/g,	formulatOneAttribute('size',setMap['sizeValue'])	);
		content = content.replace(/##<maxlengthValue>##/g,	formulatOneAttribute('maxlength',setMap['maxlengthValue'])	);
		content = content.replace(/##<dataTypeValue>##/g,	formulatOneAttribute('datatype',setMap['dataTypeValue'])	);
		if(isNotEmpty(setMap['styleValue'])) {
			content = content.replace(/##<styleValue>##/g,	formulatOneAttribute('style',getSytleSetValue(	setMap['styleValue'])  )	);
		}else {
			content = content.replace(/##<styleValue>##/g,	""	);
		}
		content = content.replace(/##<dataTypeValue>##/g,	formulatOneAttribute('dataType',setMap['dataTypeValue'])	);
		content = content.replace(/##<patternValue>##/g,	formulatOneAttribute('pattern',setMap['patternValue'])	);
		content = content.replace(/##<onchangeValue>##/g,	formulatOneAttribute('onchange',setMap['onchangeValue'])	);
		content = content.replace(/##<onblurValue>##/g,	formulatOneAttribute('onblur',setMap['onblurValue'])	);
		content = content.replace(/##<classValue>##/g,	formulatOneAttribute('class',setMap['classValue'])	);<%--[20240723]難字調整--%>
		return content;
	}
	
	<%--
		用以建立td中span的結構
	--%>
	function getTDColumnSPAN(setMap) {
		var content = '<span ##<displayPartID>## ##<displayPartOrNot>##>	##<displayPart>##	</span>' 
					  + '<span ##<inputPartID>## ##<inputPartOrNot>##>	##<inputPart>##		</span>';
					  
		content = content.replace(/##<displayPartID>##/g,	formulatOneAttribute('id',setMap['displayPartID'])	);
		if(isNotEmpty(setMap['displayPartOrNot'])) {
			content = content.replace(/##<displayPartOrNot>##/g,	formulatOneAttribute('style',getSytleSetValue(	setMap['displayPartOrNot'])  )	);
		}else {
			content = content.replace(/##<displayPartOrNot>##/g,	""	);
		}
		content = content.replace(/##<displayPart>##/g,	getValue(setMap['displayPart'])	);
		
		content = content.replace(/##<inputPartID>##/g,	formulatOneAttribute('id',setMap['inputPartID'])	);
		if(isNotEmpty(setMap['inputPartOrNot'])) {
			content = content.replace(/##<inputPartOrNot>##/g,	formulatOneAttribute('style',getSytleSetValue(	setMap['inputPartOrNot'])  )	);
		}else {
			content = content.replace(/##<inputPartOrNot>##/g,	""	);
		}
		content = content.replace(/##<inputPart>##/g,	getValue(setMap['inputPart'])	);
		return content;
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
		取得style設定的值
	--%>
	function getSytleSetValue(setValue) {
		return setValue == true ? 'display: inline;' : 'display: none;';
	}
	
	<%--
		建立td的屬性值，及其內容
		getHTMLTAG( {
			'tagName' : ,
			'widthValue' : ,
			'classValue' : ,
			'alignValue' : ,
			'insertValue' : 
		});
	--%>
	function getHTMLTAG(setMap) {
		var content = '<##<tagName>## ##<widthValue>## ##<classValue>## ##<alignValue>## >##<insertValue>##</##<tagName>##>';
		content = content.replace(/##<tagName>##/g,	setMap['tagName']	);
		content = content.replace(/##<widthValue>##/g,	formulatOneAttribute('width',setMap['widthValue'])	);
		content = content.replace(/##<classValue>##/g,	formulatOneAttribute('class',setMap['classValue'])	);
		content = content.replace(/##<alignValue>##/g,	formulatOneAttribute('align',setMap['alignValue'])	);
		content = content.replace(/##<insertValue>##/g,	getValue(setMap['insertValue'])	);
		return content;
	}
	
	
	<%--
		選取radio的 item
	--%>
	function selectRadioItem(radioListName,SEQ_NUMBER) {
		var radioItems = document.getElementsByName(radioListName);
		for(var mover =0; mover < radioItems.length ; mover++)
		{
			var targetElement = radioItems[mover];
			if(targetElement.value == SEQ_NUMBER) {
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
		開啟或關閉整個RADIO LIST
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
	 	刪除作業:
		利用sourceList中的index值，執行刪除作業
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
		處理Item List的輸入模式切換
	--%>
	function ItemListOnChnageFun(value,TARGET_SEQ_NO,clearOrNot) {
		<%--
			// ITEM : 'ITEM' + '_' + 'INPUT' + '_' + seqenceNumber,
			// '層' : 'LEVEL' + '_' + 'INPUT' + '_' + seqenceNumber,
			// '-' : 'CONNECTOR' + '_' + 'INPUT' + '_' + seqenceNumber,
			// 'AUX_NO1' : 'AUX_NO1' + '_' + 'INPUT' + '_' + seqenceNumber,
			// 'AUX_NO2' : 'AUX_NO2' + '_' + 'INPUT' + '_' + seqenceNumber,
		--%>		
		function setComShowOrNot(name,displayOrNot,TARGET_SEQ_NO) {
			var targetName = name + '_' + 'INPUT' + '_' + TARGET_SEQ_NO;
			$(targetName).style.display = (displayOrNot ? 'inline' : 'none' );
		}
		
		<%--
			此處的value值是下拉實際的值，而不是最後資料庫中CELL_NO所歸納完的值
			所以是4類
			"" --> 請選擇
			1  ==> 層次
			V  ==> 其他
			非三者 ==> 非層次非其他
		--%>
		if(value == "0") {
			<%--
				請選擇
				僅有下拉可以操作
				下拉已設為顯示
			--%>
			setComShowOrNot('ITEM' ,false,TARGET_SEQ_NO);
			setComShowOrNot('LEVEL',false,TARGET_SEQ_NO);	<%-- LABEL :層 --%>
			
			setComShowOrNot('AUX_NO1',false,TARGET_SEQ_NO);
			setComShowOrNot('CONNECTOR',false,TARGET_SEQ_NO);	<%-- LABEL : '-'--%>
			setComShowOrNot('AUX_NO2',false,TARGET_SEQ_NO);
		}
		
		else if(value == "1") {
			<%--
				value == 1 層次
				下拉及ITEM
			--%>
			setComShowOrNot('ITEM',true,TARGET_SEQ_NO);
			setComShowOrNot('LEVEL',true,TARGET_SEQ_NO);  <%-- LABEL :層 --%>
			
			setComShowOrNot('AUX_NO1',false,TARGET_SEQ_NO);
			setComShowOrNot('CONNECTOR',false,TARGET_SEQ_NO);	<%-- LABEL : '-'--%>
			setComShowOrNot('AUX_NO2',false,TARGET_SEQ_NO);
		}

		else if(value == "V") {
			<%--
				value == V其他
			--%>
			setComShowOrNot('ITEM',true,TARGET_SEQ_NO);
			setComShowOrNot('LEVEL',false,TARGET_SEQ_NO);	<%-- LABEL :層 --%>
			
			setComShowOrNot('AUX_NO1',true,TARGET_SEQ_NO);
			setComShowOrNot('CONNECTOR',true,TARGET_SEQ_NO);	<%-- LABEL : '-'--%>
			setComShowOrNot('AUX_NO2',true,TARGET_SEQ_NO);
		}
		
		else {
			<%--
				value == H非 層次非其他
				此時 ITEM是用來存下拉的值，ITEM不顯層
			--%>
			setComShowOrNot('ITEM',false,TARGET_SEQ_NO);
			setComShowOrNot('LEVEL',false,TARGET_SEQ_NO);	<%-- LABEL :層 --%>
			
			setComShowOrNot('AUX_NO1',true,TARGET_SEQ_NO);
			setComShowOrNot('CONNECTOR',true,TARGET_SEQ_NO);	<%-- LABEL : '-'--%>
			setComShowOrNot('AUX_NO2',true,TARGET_SEQ_NO);
		}
	}
	
	<%--
		清空項目/建號所有值	
	--%>
	function clearAllInputValue(TARGET_SEQ_NO) {
	
			function setValueEmpty(name,TARGET_SEQ_NO) {
				var targetName = name + '_' + 'INPUT' + '_' + TARGET_SEQ_NO;
				$(targetName).value = '';
				Validation.reset(targetName);
			}
			setValueEmpty('ITEM' ,TARGET_SEQ_NO);
			setValueEmpty('AUX_NO1',TARGET_SEQ_NO);
			setValueEmpty('AUX_NO2',TARGET_SEQ_NO);
	
	}
	
	<%--
		區D E 取消
	--%>
	function cancel_Block(tableName,sourceList,addButtonName,cancelButtonName,constructFunc) {
		
		if($(addButtonName).value == '儲存') {
			
			<%--表示為新增取消 --%>
			$(addButtonName).value = '新增';
			
			<%--刪除最後一筆--%>
			sourceList = deleteOneElement(sourceList,sourceList.length-1);
		}
		
		constructFunc(tableName,sourceList);
		autoFormatToNumber();
		autoFormatToDate();
		fix();
		$(cancelButtonName).disabled = true;	<%--取消完成，關閉 --%>
		return sourceList;
	}
	
	<%--
		轉大寫
	--%>
	function columnToUpperCase(columnName) {
		if(isNotEmpty($F(columnName))) {
			$(columnName).value = $(columnName).value.toUpperCase();
		}
	}
	
//--------------------------------------------------------------------------
// 超連結
//--------------------------------------------------------------------------
var hyperlinks = {
	// popUp
	popup:function(conf, callbackFun){
		popupWin.callbackHandler = callbackFun;
		popupWin.popup(conf);
	},
	// fullPopUp
	fullpopup:function(url, text){
		if(url){
			if(text){
				return popupWin.createFullPopupLink(text, url);
			}else{
				popupWin.fullPopup(url);
			}
		}
	},
	// 開新視窗
	openwindow:function(url, title, attrs){
		
		
		if(url){
			if(attrs){
				window.open(url, title, attrs); 
			}else{
				window.open(url); 
			}
		}
	}
};
	
<%--
	針對Roc Date加上'/'字元
--%>
function toROC_delimiter(ROCdate)
{
	if (isEmpty(ROCdate) || ROCdate.length < 6) return "";
	
	var	returnDate = ROCdate.substring(0,ROCdate.length-4) + "/" 
					 + ROCdate.substring(ROCdate.length-4,ROCdate.length-2) + "/" 
					 + ROCdate.substring(ROCdate.length-2,ROCdate.length);
	return returnDate;
}
		
<%--
	填補0值
--%>
function fillBuildingValue() {
	
	<%--
       //建號(主建物建號)1  BUILD_NO1   rtnA050Map.BUILD_NO1    輸入欄位，自動將建號1補滿5個欄位，不足前面補0
       //建號(主建物建號)2  BUILD_NO2   rtnA050Map.BUILD_NO2    輸入欄位，自動將建號2補滿3個欄位，不足前面補0
	--%>

	var BUILD_NO1 = $('BUILD_NO1').value;
	var BUILD_NO2 = $('BUILD_NO2').value;
	
	if(isNotEmpty(BUILD_NO1) && BUILD_NO1 != '') {
		$('BUILD_NO1').value = fillString(5,BUILD_NO1);
	} 
	
	if(isNotEmpty(BUILD_NO2) && BUILD_NO2 != '') {
		$('BUILD_NO2').value = fillString(3,BUILD_NO2);
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
	檢查是不是數字，並設定訊息
--%>
function validateNum(name,errorMessage) {
	var value = $F(name)

	if(isNaN(parseInt(value, 10))){
		setFalseCheck(name,errorMessage);
	}else{
		var new_value = Number(value);
		if(new_value <0 || (new_value - parseInt(value, 10) != 0)){
			setFalseCheck(name,errorMessage);	
		}
	}
}

<%--
	檢查ADDR_NO是否有繁體的臺
--%>
function replacetaiwan() {
   $('ADDR_NO').value=$('ADDR_NO').value.replace("臺北", "台北");
   $('ADDR_NO').value=$('ADDR_NO').value.replace("臺中", "台中");
   $('ADDR_NO').value=$('ADDR_NO').value.replace("臺南", "台南");
   $('ADDR_NO').value=$('ADDR_NO').value.replace("臺東", "台東");
}

<%--
	檢查是不是空值，並設定訊息
--%>
function validateROCformate(name,errorMessage) {
	if($F(name) == '') {
		return;
	}
	if(isROCdate($F(name)) == false, false) {
		setFalseCheck(name,errorMessage);
	}
}

<%--
	檢查ADDR_NO是否為全型字
--%>
function validateHalfType() {
    if(validation.hasHalfType($('ADDR_NO').value)) {
    		setFalseCheck('ADDR_NO','請輸入全型字');
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

<%--
	檢查長度
--%>
function checkMaxLength() {
	<%--
		4.1.4	輸入欄位長度及資料型態檢核	
		受理編號	APPLY_ID	畫面上的受理編號	輸入欄位		

		(C區)建物謄本資料
		房屋門牌號碼	CITY	rtnA050Map. ADDR_NO	輸入欄位
		建號(主建物建號)1	BUILD_NO1	rtnA050Map.BUILD_NO1	1. 輸入欄位
																2. 自動補滿5個欄位，不足前面補0

		建號(主建物建號)2	BUILD_NO2	rtnA050Map.BUILD_NO2	1. 輸入欄位
																2. 自動補滿3個欄位，不足前面補0
		總層數	FLOOR	rtnA050Map.FLOOR	輸入欄位(數字)																
		建築完成日	FINISH_DATE	rtnA050Map.FINISH_DATE	1.	輸入欄位(日期)
														2.	可透過日曆模式點選日期
		月租金	RENTAL	rtnA050Map.RENTAL	輸入欄位(數字),
											須為正整數,
											無資料預設為0
		押金	DEPOSIT	rtnA050Map.DEPOSIT	輸入欄位(數字),
										須為正整數,
										無資料預設為0
										
		租期	START_DATE	rtnA050Map.START_DATE	1.	輸入欄位(日期)
												2.	可透過日曆模式點選日期
		租期	END_DATE	rtnA050Map.END_DATE	1.	輸入欄位(日期)
												2.	可透過日曆模式點選日期
		原因發生日期	OCCUR_DATE	rtnA050Map.OCCUR_DATE	1.	輸入欄位(日期)
											        	2.	可透過日曆模式點選日期
	--%>
	setLengthCheck('受理編號','APPLY_ID',11);
	setLengthCheck('房屋門牌號碼','ADDR_NO',300);
	setLengthCheck('建號(主建物建號)1','BUILD_NO1',5);
	setLengthCheck('建號(主建物建號)2','BUILD_NO2',5);
	setLengthCheck('總層數','FLOOR',3);
	setLengthCheck('建築完成日','FINISH_DATE',7);
	setLengthCheck('月租金','RENTAL',10,true);
	setLengthCheck('押金','DEPOSIT',10,true);
	setLengthCheck('租期起','START_DATE',10);
	setLengthCheck('租期迄','END_DATE',10);
	setLengthCheck('原因發生日期','OCCUR_DATE',10);
}

<%--
	執行共同性的頁面檢核
--%>
function block_DE_check(isBankUpdate) {

	<%-- 建物樓層資料 --%>
	if(isNotEmpty(A051List)) {
		var A051_errorMessage = "";
		for(var mover=0; mover < A051List.length ; mover++) {
			var target_A051 = A051List[mover];
			var NOW_ROW_SEQ_NO = target_A051[SEQUENCE_NUMBER_COLUMN];
			<%--
				面積	MEASURE	預設為0	數字格式輸入欄位，小數點3位、整數12位，須為正整數
			--%>
			var MEASURE_NAME = 'MEASURE' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			if(isUnInput(MEASURE_NAME)) {
				setFalseCheck(MEASURE_NAME,'面積必須有值!');
			}
			var MEASURE_VALUE = $(MEASURE_NAME).value.replace(/,/g,'');
			if(MEASURE_VALUE < 0) {
				setFalseCheck(MEASURE_VALUE,'面積值必須大於0有值!\n');
			}
			if(MEASURE_VALUE > 1000000000000) {
				setFalseCheck(MEASURE_NAME,'面積值整數最多12位!');
			}
			
			<%--
				//4.1.2	檢核「持分(分母)」不可小於「持分(分子)」:
				//if HOLD_BASE  <  HOLD_UP，顯示錯誤訊息:‘分母不可小於分子!’
			--%>
			var HOLD_BASE_NAME = 'HOLD_BASE' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var HOLD_BASE_VALUE = $(HOLD_BASE_NAME).value.replace(/,/g,'');
			if(isUnInput(HOLD_BASE_NAME)) {
				setFalseCheck(HOLD_BASE_NAME,'持份分母必須有值!');
			}
			var HOLD_UP_NAME = 'HOLD_UP' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var HOLD_UP_VALUE = $(HOLD_UP_NAME).value.replace(/,/g,'');
			if(isUnInput(HOLD_UP_NAME)) {
				setFalseCheck(HOLD_UP_NAME,'持份分子必須有值!\n');
			}
			if(HOLD_BASE_VALUE - HOLD_UP_VALUE < 0) {
				setFalseCheck(HOLD_UP_NAME,'分母不可小於分子!');
			}
			if(HOLD_BASE_VALUE == 0 || HOLD_UP_VALUE == 0) {
				setFalseCheck(HOLD_UP_NAME,'持份分子分母不得輸入０!');
			}

			var CELL_NO = 'CELL_NO' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var CELL_NO_VALUE = $(CELL_NO).value;
			var ITEM = 'ITEM' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var AUX_NO1 = 'AUX_NO1' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var AUX_NO2 = 'AUX_NO2' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var ITEM_VALUE = $F(ITEM);
			var AUX_NO1_VALUE = $F(AUX_NO1);
			var AUX_NO2_VALUE = $F(AUX_NO2);
			
			if (!isBankUpdate) {<%--[20210318]SA追加檢核:銀行件時先不要檢核建號相關--%>
				var haveErrorOrNot = false;
				if(CELL_NO_VALUE == "0") {
					setFalseCheck(CELL_NO,'請選擇項目/建號!');
				}else if(CELL_NO_VALUE == "1") {	
					if(isUnInput(ITEM)) {
						setFalseCheck(ITEM,'層次值不得為空!');
					}
	
					//層次輸入值需為’1234567890bB’且檢核不可單輸入’0’ 
					if ($F(ITEM).match(/[^\d|b|B]/g)){
						setFalseCheck(ITEM,'層數資料有誤(請輸入1234567890bB)!');
					} else if ($F(ITEM) == '0'){
						setFalseCheck(ITEM,'層數資料不得輸入０!');
					}
					
				}else if(CELL_NO_VALUE == "V") {	
					//其他
					if(ITEM_VALUE == '') {
						setFalseCheck(ITEM,'項目/建號內容必須有值!');
					}
					if(AUX_NO1_VALUE == '') {
						setFalseCheck(AUX_NO1,'項目/建號內容必須有值!');
					}
					if(AUX_NO2_VALUE == '') {
						setFalseCheck(AUX_NO2,'項目/建號內容必須有值!');
					}				
				}else {
					if(AUX_NO1_VALUE == '') {
						setFalseCheck(AUX_NO1,'項目/建號內容必須有值!');
					}
					if(AUX_NO2_VALUE == '') {
						setFalseCheck(AUX_NO2,'項目/建號內容必須有值!');
					}
				}
				<%--
					長度檢核
					附屬建號1	AUX_NO1
					附屬建號2	AUX_NO2
					面積	MEASURE
					持份分母	HOLD_BASE
					持份分子	HOLD_UP
				--%>
				setLengthCheck('附屬建號1',AUX_NO1,5);
				setLengthCheck('附屬建號2',AUX_NO2,5);
			}
			setLengthCheck('面積',MEASURE_NAME,15,true);
			setLengthCheck('持份分母',HOLD_BASE_NAME,15,true);
			setLengthCheck('持份分子',HOLD_UP_NAME,15,true);
		}
	}
	
	<%-- 建物所有權人 --%>
	if(isNotEmpty(A052List)) {
		var A052_errorMessage = "";
		for(var mover=0; mover < A052List.length ; mover++) {
			var target_A052 = A052List[mover];
			var NOW_ROW_SEQ_NO = target_A052[SEQUENCE_NUMBER_COLUMN];
			
			<%--
				檢核項目
						選取			RADIO不出現
						受理編號	APPLY_ID	C區之受理編號	HIDDEN
						建號1	BUILD_NO1	C區之建號1	HIDDEN
						建號2	BULID_NO2	C區之建號2	HIDDEN
						所有權人	NAME		輸入欄位(全形)
						所有權人ID	ID		1.	輸入欄位
											2.	須符合8碼法人統一編號格式或10碼自然人身分證號碼格式
						所有權人生日	BIRTHDAY		1.	輸入欄位(日期)
													2.	可透過日曆模式點選日期
				*已錯的訊息不累加
			--%>
			var NAME = 'NAME' + '_' + 'INPUT_' +  + NOW_ROW_SEQ_NO;
			if(isBankUpdate){
				//銀行件所有權人名稱不檢核
			}else{
				
				if(isUnInput(NAME)) {
					setFalseCheck(NAME,'所有權人名稱必須有值!!');
				}else{
				    if(validation.hasHalfType($(NAME).value)) {
				    	setFalseCheck(NAME,'所有權人名稱請輸入全型字');
					}
				}
			}
			
			var ID_NAME = 'ID' + '_' + 'INPUT_' +  + NOW_ROW_SEQ_NO;
			columnToUpperCase(ID_NAME);	<%-- APPLY_ID轉大寫  --%>
			if(isUnInput(ID_NAME)) {
				setFalseCheck(ID_NAME,'所有權人ID名稱必須有值!');
			}
			var ID_VALUE = $(ID_NAME).value;
			if(ID_VALUE.length!=10 && ID_VALUE.length!=8){
				setFalseCheck(ID_NAME,'所有權人ID需符合8碼法人統一編號格式或10碼自然人身分證號碼格式!');
			}else if(ID_VALUE.length==10 && idCheck1(ID_VALUE) == false) {
				setFalseCheck(ID_NAME,'所有權人ID需符合10碼自然人身分證號碼格式!');
			}else if(ID_VALUE.length==8 && !validation.checkUniSN(ID_VALUE)){
				setFalseCheck(ID_NAME,'所有權人ID需符合8碼法人統一編號格式!');
			}
			//var BIRTHDAY_NAME = 'BIRTHDAY' + '_' + 'INPUT_' +  + NOW_ROW_SEQ_NO;
			//if(isUnInput(BIRTHDAY_NAME)) {
			//	setFalseCheck(BIRTHDAY_NAME,'生日為必輸欄位!');
			//}
			
			<%--
				長度檢核
				所有權人	NAME
				所有權人ID	ID
				//所有權人生日	BIRTHDAY
			--%>
			setLengthCheck('所有權人名稱',NAME,100);//原住民調整長度
			setLengthCheck('所有權人ID',ID_NAME,10);
			//setLengthCheck('所有權人生日',BIRTHDAY_NAME,10);
		}
	}
	
	<%--
		通過檢核將資料放到A052List
	--%>
	<%-- 51list --%>	
	for(var mover=0; mover < A051List.length ; mover++) {
		var target_A051 = A051List[mover];
		var targetRowIndex = mover;
		var NOW_ROW_SEQ_NO = target_A051[SEQUENCE_NUMBER_COLUMN];
		
		A051List[targetRowIndex]['APPLY_ID'] = $F('APPLY_ID');
		A051List[targetRowIndex]['BUILD_NO1'] = $F('BUILD_NO1');
		A051List[targetRowIndex]['BUILD_NO2'] = $F('BUILD_NO2');

		var CELL_NO = 'CELL_NO' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
		var CELL_NO_VALUE = $(CELL_NO).value;
		var ITEM = 'ITEM' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
		var AUX_NO1 = 'AUX_NO1' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
		var AUX_NO2 = 'AUX_NO2' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
		var ITEM_VALUE = $F(ITEM);
		var AUX_NO1_VALUE = $F(AUX_NO1);
		var AUX_NO2_VALUE = $F(AUX_NO2);
		
		if(CELL_NO_VALUE == "1") {
		
			<%--當下拉值為1時，CELL_NO的值應填'A'--%>
			A051List[targetRowIndex]['CELL_NO'] = 'A';
			A051List[targetRowIndex]['ITEM'] = ITEM_VALUE;
			A051List[targetRowIndex]['AUX_NO1'] = null;
			A051List[targetRowIndex]['AUX_NO2'] = null;
		}else if(CELL_NO_VALUE == "V") {	
		
			<%--當下拉值為1時，CELL_NO的值應填'A'--%>
			A051List[targetRowIndex]['CELL_NO'] = 'M';
			A051List[targetRowIndex]['ITEM'] = ITEM_VALUE;
			A051List[targetRowIndex]['AUX_NO1'] = (AUX_NO1_VALUE == '' ? '' : fillString(5,AUX_NO1_VALUE));
			A051List[targetRowIndex]['AUX_NO2'] = (AUX_NO2_VALUE == '' ? '' : fillString(3,AUX_NO2_VALUE));
		}else {
		
			<%--當下拉值為1時，CELL_NO的值應填'A'--%>
			A051List[targetRowIndex]['CELL_NO'] = 'H';
			A051List[targetRowIndex]['ITEM'] = CELL_NO_VALUE;
			A051List[targetRowIndex]['AUX_NO1'] = (AUX_NO1_VALUE == '' ? '' : fillString(5,AUX_NO1_VALUE));
			A051List[targetRowIndex]['AUX_NO2'] = (AUX_NO2_VALUE == '' ? '' : fillString(3,AUX_NO2_VALUE));
		}
		var MEASURE_NAME = 'MEASURE' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
		var MEASURE_VALUE = $(MEASURE_NAME).value.replace(/,/g,'');
		A051List[targetRowIndex]['MEASURE'] = MEASURE_VALUE;
		
		var HOLD_BASE_NAME = 'HOLD_BASE' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
		var HOLD_BASE_VALUE = $(HOLD_BASE_NAME).value.replace(/,/g,'');
		var HOLD_UP_NAME = 'HOLD_UP' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
		var HOLD_UP_VALUE = $(HOLD_UP_NAME).value.replace(/,/g,'');
		A051List[targetRowIndex]['HOLD_BASE'] = HOLD_BASE_VALUE;
		A051List[targetRowIndex]['HOLD_UP'] = HOLD_UP_VALUE;
	}

	<%-- 52list --%>
	for(var mover=0; mover < A052List.length ; mover++) {
		var target_A052 = A052List[mover];
		var targetRowIndex = mover;
		var NOW_ROW_SEQ_NO = target_A052[SEQUENCE_NUMBER_COLUMN];
		
		A052List[targetRowIndex]['APPLY_ID'] = $F('APPLY_ID');
		A052List[targetRowIndex]['BUILD_NO1'] = $F('BUILD_NO1');
		A052List[targetRowIndex]['BUILD_NO2'] = $F('BUILD_NO2');

		//所有權人	NAME		輸入欄位
		var NAME = 'NAME' + '_' + 'INPUT_' +  + NOW_ROW_SEQ_NO;
		var NAME_VALUE = $(NAME).value;
		A052List[targetRowIndex]['NAME'] = NAME_VALUE;

		//所有權人ID	ID		輸入欄位
		var ID_NAME = 'ID' + '_' + 'INPUT_' +  + NOW_ROW_SEQ_NO;
		var ID_VALUE = $(ID_NAME).value;
		A052List[targetRowIndex]['ID'] = ID_VALUE;
		
		//所有權人生日	BIRTHDAY		日期欄位,亦可透過日曆模式點選日期
		//var BIRTHDAY_NAME = 'BIRTHDAY' + '_' + 'INPUT_' +  + NOW_ROW_SEQ_NO;
		//var BIRTHDAY_VALUE = $(BIRTHDAY_NAME).value;
		//A052List[targetRowIndex]['BIRTHDAY'] = BIRTHDAY_VALUE;
	}
}


<%--
	移除一列資料
--%>
function removeOneRow(BLOCK) {
	if(BLOCK == "D") {
		<%-- 51list --%>	
		for(var mover=0; mover < A051List.length ; mover++) {
			var target_A051 = A051List[mover];
			var targetRowIndex = mover;
			var NOW_ROW_SEQ_NO = target_A051[SEQUENCE_NUMBER_COLUMN];
			
			var CELL_NO = 'CELL_NO' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var CELL_NO_VALUE = $(CELL_NO).value;
			var ITEM = 'ITEM' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var AUX_NO1 = 'AUX_NO1' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var AUX_NO2 = 'AUX_NO2' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var ITEM_VALUE = $F(ITEM);
			var AUX_NO1_VALUE = $F(AUX_NO1);
			var AUX_NO2_VALUE = $F(AUX_NO2);
			
			if(CELL_NO_VALUE == "1") {
			
				<%--當下拉值為1時，CELL_NO的值應填'A'--%>
				A051List[targetRowIndex]['CELL_NO'] = 'A';
				A051List[targetRowIndex]['ITEM'] = ITEM_VALUE;
				A051List[targetRowIndex]['AUX_NO1'] = null;
				A051List[targetRowIndex]['AUX_NO2'] = null;
			}else if(CELL_NO_VALUE == "V") {	
			
				<%--當下拉值為1時，CELL_NO的值應填'A'--%>
				A051List[targetRowIndex]['CELL_NO'] = 'M';
				A051List[targetRowIndex]['ITEM'] = ITEM_VALUE;
				A051List[targetRowIndex]['AUX_NO1'] = (AUX_NO1_VALUE == '' ? '' : fillString(5,AUX_NO1_VALUE));
				A051List[targetRowIndex]['AUX_NO2'] = (AUX_NO2_VALUE == '' ? '' : fillString(3,AUX_NO2_VALUE));
			}else {
			
				<%--當下拉值為1時，CELL_NO的值應填'A'--%>
				A051List[targetRowIndex]['CELL_NO'] = 'H';
				A051List[targetRowIndex]['ITEM'] = CELL_NO_VALUE;
				A051List[targetRowIndex]['AUX_NO1'] = (AUX_NO1_VALUE == '' ? '' : fillString(5,AUX_NO1_VALUE));
				A051List[targetRowIndex]['AUX_NO2'] = (AUX_NO2_VALUE == '' ? '' : fillString(3,AUX_NO2_VALUE));
			}
			var MEASURE_NAME = 'MEASURE' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var MEASURE_VALUE = $(MEASURE_NAME).value.replace(/,/g,'');
			A051List[targetRowIndex]['MEASURE'] = MEASURE_VALUE;
			
			var HOLD_BASE_NAME = 'HOLD_BASE' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var HOLD_BASE_VALUE = $(HOLD_BASE_NAME).value.replace(/,/g,'');
			var HOLD_UP_NAME = 'HOLD_UP' + '_' + 'INPUT' + '_' + NOW_ROW_SEQ_NO;
			var HOLD_UP_VALUE = $(HOLD_UP_NAME).value.replace(/,/g,'');
			A051List[targetRowIndex]['HOLD_BASE'] = HOLD_BASE_VALUE;
			A051List[targetRowIndex]['HOLD_UP'] = HOLD_UP_VALUE;
			
		}
		var selectItem = getSelectRadioItem('RADIO_D');
		var target_SEQ_NO = selectItem.value;
		var targetRowIndex = getTargetRowIndex(A051List,target_SEQ_NO,SEQUENCE_NUMBER_COLUMN);
		A051List = deleteOneElement(A051List,targetRowIndex);
		setSequenceNumber(A051List,SEQUENCE_NUMBER_COLUMN);	
		constructRows_BlockD('D_grid',A051List);
		<%-- 總面積計算 --%>
		doMeasureCount();
	
	}else {
		<%-- 52list --%>
		for(var mover=0; mover < A052List.length ; mover++) {
			var target_A052 = A052List[mover];
			var targetRowIndex = mover;
			var NOW_ROW_SEQ_NO = target_A052[SEQUENCE_NUMBER_COLUMN];
			
			//所有權人	NAME		輸入欄位
			var NAME = 'NAME' + '_' + 'INPUT_' +  + NOW_ROW_SEQ_NO;
			var NAME_VALUE = $(NAME).value;
			A052List[targetRowIndex]['NAME'] = NAME_VALUE;

			//所有權人ID	ID		輸入欄位
			var ID_NAME = 'ID' + '_' + 'INPUT_' +  + NOW_ROW_SEQ_NO;
			var ID_VALUE = $(ID_NAME).value;
			A052List[targetRowIndex]['ID'] = ID_VALUE;
			
			//所有權人生日	BIRTHDAY		日期欄位,亦可透過日曆模式點選日期
			//var BIRTHDAY_NAME = 'BIRTHDAY' + '_' + 'INPUT_' +  + NOW_ROW_SEQ_NO;
			//var BIRTHDAY_VALUE = $(BIRTHDAY_NAME).value;
			//A052List[targetRowIndex]['BIRTHDAY'] = BIRTHDAY_VALUE;
		}
		var selectItem = getSelectRadioItem('RADIO_E');
		var target_SEQ_NO = selectItem.value;
		var targetRowIndex = getTargetRowIndex(A052List,target_SEQ_NO,SEQUENCE_NUMBER_COLUMN);
		A052List = deleteOneElement(A052List,targetRowIndex);
		setSequenceNumber(A052List,SEQUENCE_NUMBER_COLUMN);
		constructRows_BlockE('E_grid',A052List);
	}
	autoFormatToNumber();
	autoFormatToDate();
	PageUI.resize(true);
}
	
//
--></script>
