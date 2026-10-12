<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!-- 
[20221226]修改件
[申請書:220725005491]新增本金彈性還還款方式
郭曉慧

[20240729] 修改件 陳勁谷 難字修改
-->
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>

<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var grid = null;
var rtnList=[];
var rtnMap={};
var sectionBChange=false;
var page_DSZ01000 = null;
var validate4define;
//--------------------------------------------------------------------------
// 按鈕權限設定
//--------------------------------------------------------------------------
function buttonAuth(){
	var authButtons = {
		"B0005":'btn_delete<%--刪除--%>',
		"B0004":'btn_modify<%--修改--%>',
		"B0017":'btn_section_approve<%--組長同意--%>',
		"B0020":'btn_reject<%--主管退回--%>',
		"B0019":'btn_department_approve<%--主管同意--%>',
		"B0038":'btn_cancel<%--取消核貸--%>'
	};
	
	<dz:grantButtons FUNC_ID="DSA21100" ignored="false"/>
	
}

function initApp(){
	if (typeof WebRootPath=='undefined') {
		   var WebRootPath='/DSWeb/'; //【BGWeb】請依各子系統替換成自己的 Web
		   var imeServer='https://mi.cathaylife.com.tw/wf/';
		   var jscript = document.createElement('script');
		   jscript.setAttribute('lang', 'text/javascript');
		   jscript.setAttribute('src', '/DSWeb/hanlinks/wf_links.js'); //【BGWeb】請依各子系統替換成自己的 Web
		   document.getElementsByTagName('head').item(0).appendChild(jscript);
	}

	displayMessage();
	PageUI.createPageWithAllBodySubElement("DSA21100" , "核貸案件" , "核貸案件修正作業" , 2 , false);
	buttonAuth();
	autoFormatToDate();
	autoFormatToNumber();
	page_DSZ01000 = new DSZ01000("DSA21100", "2");
	initOps();
	changeReturnType();
	
	validate4define = new Validation(document.body, {useTitles:true, focusOnError:false, immediate:false});
	Validation.addAllThese([
		[ 'customize_returnFalse', '請自訂訊息',
			function(obj){
				return false;
			}
		]
	]);
	
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

function initOps() {
		
	<%--
		修正種類	TYPE	rtnList[i].TYPE_NM	顯示欄位
		修正時間	INPUT_DATE	rtnList[i].INPUT_DATE	顯示欄位,排序由小到大
		修正人員	INPUT_NM	rtnList[i].INPUT_NM	顯示欄位
		組長確認時間	LEADER_DATE	rtnList[i].LEADER_DATE	顯示欄位
		覆核組長	LEADER_NM	rtnList[i].LEADER_NM	顯示欄位
		主管確認時間	CHIEF_DATE	rtnList[i].CHIEF_DATE	顯示欄位
		覆核主管	CHIEF_NM	rtnList[i].CHIEF_NM	顯示欄位
	--%>			
	
	grid = new TableUI({
		table: $('grid'), pageSize: 10, allSortable: false,
					autoCheckBox:{ isSelectAll :true,type: 'radio', valueKey : 'SEQ_NO_CHECK'
						,action: function (checkbox , boxStatus , records) {
							<%--
								記錄區塊B有改變過
							--%>
							sectionBChange = true;
							
							<%--
								3.	選取RADIO(B區) 
								3.1	畫面程序檢核:
								3.2	讀取畫面欄位資料:
								3.2.1	APPLY_ID=畫面C區的受理編號
								3.2.2	TYPE=畫面B區選取的種類
								3.2.3	SeqNO=畫面B區選取的序號
								3.3	資料檢核: 
								3.4	資料處理: 
								3.4.1	取得核貸明細資料(C區&D區):
								rtnMap = DS_A21100.queryLogByApplyID(APPLY_ID, TYPE, SeqNO)
								3.4.2	寫入個資LOG，參見查詢
								3.5	畫面顯示: 
								3.5.1	無資料顯示:跳出警示訊息’查無資料’，清空畫面D區資料顯示區
								3.5.2	正常顯示:更新D區資料，參見查詢
							--%>
							if(boxStatus){
								var targetRow = records[0];
								new Ajax.Request("<%=dispatcher%>/DSA2_1100/doRadioB", 
								{
										parameters:{'APPLY_ID':targetRow['APPLY_ID'],
													'TYPE':targetRow['TYPE'],
													'SeqNO':targetRow['SEQ_NO']										
										},
										onSuccess:function(XHT, resp){
											if(CSRUtil.isSuccess(resp)){
													<%--
														3.5.1	將點選的資料顯示於區塊C、區塊D、區塊E,畫面顯示欄位值如查詢
													--%>
													showSectionCD(resp);
											}else{
												if(resp.DATA_NOT_FOUND){
													showSectionCD({});
												}						
											}
										}
								});
							}
						}
					},
		column:[
			{header:'修正種類', key:'TYPE_NM',
				render:function(record, value){
					return isNotEmpty(value) ? value : "";
				}
			},
			{header:'修正時間', key:'INPUT_DATE',
				render:function(record, value){
					return isNotEmpty(value) ? Date.toROC(value) : "";
				}
			},
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			{header:'修正人員', key:'INPUT_NM', attrs: {style:"font-family:'EUDC'"},
				render:function(record, value){
					return isNotEmpty(value) ? value : "";
				}
			},
			{header:'組長確認時間', key:'LEADER_DATE',
				render:function(record, value){
					return isNotEmpty(value) ? Date.toROC(value) : "";
				}
			},
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			{header:'覆核組長', key:'LEADER_NM', attrs: {style:"font-family:'EUDC'"},
				render:function(record, value){
					return isNotEmpty(value) ? value : "";
				}
			},
			{header:'主管確認時間', key:'CHIEF_DATE',
				render:function(record, value){
					return isNotEmpty(value) ? Date.toROC(value) : "";
				}
			},
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			{header:'覆核主管', key:'CHIEF_NM', attrs: {style:"font-family:'EUDC'"},
				render:function(record, value){
					return isNotEmpty(value) ? value : "";
				}
			}
		]
	});
	
	$w('INTEREST INTEREST_M LOAN_AMT AGREE_AMT LOAN_AMT_M AGREE_AMT_M SET_AMT CRED_TRADE_AMT COMP_AMT FIREINSU_YY FIREINSU_MM FIREINSU_AMT FIX_YY FIX_MM SPR_YY SPR_MM').each(
		function(key){
			$(key).observe('blur', function(event){
				var value = $(key).getValue();
				
				if(isNaN(parseInt(value, 10))){
					$(key).value = "";
				}
			});
		}
	);
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
	
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	if(isUnInput('APPLY_ID')) {
		setFalseCheck('APPLY_ID','受理編號有誤，請檢查後重新輸入!');
	}
	if(validate4define.validate() == false)
		return ;
	
	//保留參數管理-更新受理編號
	CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});	
	
	var reqMap = Object.toJSON({'APPLY_ID':$F('APPLY_ID')});
  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doQuery", 
	{
			parameters:{'reqMap':reqMap},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
				   showPageData(resp);
				}else{
                   showPageData({});
				}
			}
	});
}

<%--
	刪除作業
--%>
function doRemove() {
	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%--
		4.	刪除 (B0005)
		4.1	畫面程序檢核:
		4.1.1	(C)區塊的受理編號與(A)區塊的受理編號不同 || (C)區塊的受理編號為空值時，
				跳出錯誤訊息，”請先查詢，再進行刪除作業!”
	--%>
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	if($F('oldAPPLY_ID') == '' || ($F('APPLY_ID') !=  $F('oldAPPLY_ID'))) {
		setFalseCheck('APPLY_ID','請先[查詢]，再進行[刪除]作業!');
	}
	validateNotANumber('DAY_TEL_NUM',"日間電話需為數字");
	validateNotANumber('NIGHT_TEL_NUM',"夜間電話需為數字");
	validateNotANumber('MOBILE',"行動電話需為數字");
	if(validate4define.validate() == false) {
		return ;
	}

	
	<%--
		4.1.2	顯示確認訊息‘是否確認刪除?’，確認後才繼續執行
		4.2	讀取畫面欄位資料:
		4.2.1	oldAPPLY_ID =(C)區塊的受理編號
		4.3	資料檢核: 
		4.3.1	檢核是否可刪除:
			/*檢核受理進度狀態*/
			DSA2_1100_mod.checkDelete(oldAPPLY_ID)
		4.4	資料處理: 
		4.4.1	刪除資料:
			DS_A21100.delA180ByApplyID(oldAPPLY_ID)
		4.5	畫面顯示: 
		4.5.1	錯誤顯示:顯示錯誤訊息，畫面保留按鈕前資訊
		4.5.2	正常顯示:顯示 ‘刪除成功’，訊息確認後，依原查詢條件重新查詢
	--%>
	var reqMap = getReqMap(rtnMap);
  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doRemove", 
	{
			parameters:{'reqMap':Object.toJSON(reqMap)},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
						showPageData(resp);
				}else{
					if(resp.DATA_NOT_FOUND){
						showPageData({});
					}
				}
			}
	});
}

<%--
	修正作業
--%>
function doModify() {
	if($F('oldAPPLY_ID') == '' || ($F('APPLY_ID') !=  $F('oldAPPLY_ID'))) {
		alert("請先[查詢]，再進行[修正]作業!!");
		return;
	}
	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');
	if($('RETURN_TYPE').value==1){//分期
	      $('FIX_PERIOD').value="0";
	}else if($('RETURN_TYPE').value==3){//定期
	      $('SPR_PERIOD').value="0";
	}

    if(checkSelectValue() == false){
       alert("請先[試算]，再進行[修正]作業!");
       return ;
    }
        
	<%--
		5.1	畫面程序檢核:
		5.1.1	(C)區塊的受理編號與(A)區塊的受理編號不同 || (C)區塊的受理編號為空值時，跳出錯誤訊息，”請先查詢，再進行修改作業!”
		5.1.2	(B)區塊的radio有被點選過，跳出提示訊息”請確認是否以畫面資料做異動!!”
		5.2	讀取畫面欄位資料:
		5.2.1	將畫面D區資料存成reqMap
		5.2.2	若房貸類型「一般型」有勾選：reqMap.LOAN_C="Y"
		5.2.3	若房貸類型「理財型」有勾選：reqMap.LOAN_M="Y"
	--%>
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	if($F('oldAPPLY_ID') == '' || ($F('APPLY_ID') !=  $F('oldAPPLY_ID'))) {
		setFalseCheck('APPLY_ID','請先查詢，再進行刪除作業!');
	}
	validateNotANumber('DAY_TEL_NUM',"日間電話需為數字");
	validateNotANumber('NIGHT_TEL_NUM',"夜間電話需為數字");
	validateNotANumber('MOBILE',"行動電話需為數字");
	validateNotANumber('DAY_TEL_EXT',"日間電話分機需為數字");
	validateNotANumber('NIGHT_TEL_EXT',"夜間電話分機需為數字");
	<%-- [20221226]本金彈性還相關檢核 --%>
	validFLEX();
	
	if(validate4define.validate() == false) {
		return ;
	}
	if($F('INTEREST_M')){
		var new_value = Number($F('INTEREST_M'));
			if(new_value < 0){
				alert('理財型擬准利率不可小於0');
				return;
			}
	}
		
	<%--
		5.1.2	(B)區塊的radio有被點選過，跳出提示訊息”請確認是否以畫面資料做異動!!”	
	--%>
	if(sectionBChange) {
		if(confirm("請確認是否以畫面資料做異動!!") == false)
			return;	
	}
	
	// 若房貸類型「一般型」有勾選：
	if($('LOAN_C').checked && !$('LOAN_M').checked) {
		$('LOAN_AMT_M').value = "0";
		$('AGREE_AMT_M').value = "0"; 
	}
		
	var reqMap = getReqMap(rtnMap);
	
	if($('LOAN_C').checked  && !$('LOAN_M').checked) {
		reqMap['LOAN_C'] = 'Y';		
	}
//	if($('LOAN_M').checked) {
//		reqMap['LOAN_M'] = 'Y';
//	}
	
	var reqMap = Object.toJSON(reqMap);
	var check1 = false;

	<%--
		5.3	資料檢核: 
		5.3.1	//檢核受理檔、徵信核貸檔中該受理編號是否可做核貸案件修正
		DSA2_1100_mod.checkUpdate(reqMap)
		若檢核不通過，程式結束
		5.3.2	//提示確認訊息的檢核
		
		DSA2_1100_mod.checkUpdate1(reqMap)
		若檢核不通過，跳出確認視窗，確認後繼續執行
		
		5.3.3	//提示警示訊息的檢核
		 DSA2_1100_mod.checkUpdate2(reqMap)
		若檢核不通過，跳出警示訊息，關閉後繼續執行
	--%>
  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doModify_checkPart_1", 
	{
			asynchronous : false,
			parameters:{'reqMap':reqMap},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
				   var tmpMap = resp.rtnMap;
				    page_DSZ01000.setINPUT_ZIPCODE(getValue(tmpMap['CON_ZIP'],""));
	                page_DSZ01000.setINPUT_ADDR(getValue(tmpMap['CON_ADDR'],""));	 
	                
	                //將reqMap字串轉為obj,塞值後再轉為字串
	                var obj_reqMap = reqMap.evalJSON();
                    obj_reqMap["CON_ZIP"] = page_DSZ01000.getINPUT_ZIPCODE();
	                obj_reqMap["CON_ADDR"] = page_DSZ01000.getINPUT_ADDR(); 
	                reqMap = Object.toJSON(obj_reqMap);
	                                        
					check1 = true;
				}else{
					check1 = false;
				}
			}
	});
	
	if(check1) {
		var doModify_checkPart_2 = true;
	  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doModify_checkPart_2", 
		{
				asynchronous : false,
				parameters:{'reqMap':reqMap},
			 	onSuccess:function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						if(isNotEmpty(resp.errorMessage) && resp.errorMessage != "") {
							if(confirm(resp.errorMessage) == false)
							{
								doModify_checkPart_2 = false;
							}else {
								doModify_checkPart_2 = true;
							}							
						}
					}
				}
		});
		
		var doModify_checkPart_3_ok = false;
		if(doModify_checkPart_2) {
		  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doModify_checkPart_3", 
			{
					asynchronous : false,
					parameters:{'reqMap':reqMap},
				 	onSuccess:function(XHT, resp){
						if(CSRUtil.isSuccess(resp)){
							doModify_checkPart_3_ok = true;
							if(isNotEmpty(resp.errorMessage) && resp.errorMessage != "")
							{
								alert(resp.errorMessage);
							}							
						}
					}
			}
			);
		}
		
		if(doModify_checkPart_3_ok) {
		  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doModify", 
			{
					asynchronous : false,
					parameters:{'reqMap':reqMap},
				 	onSuccess:function(XHT, resp){
						if(CSRUtil.isSuccess(resp)){
								showPageData(resp);
						}else{
							if(resp.DATA_NOT_FOUND){
								showPageData({});
							}
						}
					}
			});
		}
	}
}

<%--
	組長同意
--%>
function doConfirm() {

	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%--
		6.1	畫面程序檢核:
		6.1.1	(C)區塊的受理編號與(A)區塊的受理編號不同 || (C)區塊的受理編號為空值時，跳出錯誤訊息，”請先查詢，再進行修改作業!”
		6.1.2	由組長判斷是否呈核完畢，跳出確認訊息,”是否往上一級主管呈核?”
		IF  確定 THEN reqMap.IS_END =’N’
		ELSE reqMap.IS_END =’Y’
		END IF
	--%>
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	if($F('oldAPPLY_ID') == '' || ($F('APPLY_ID') !=  $F('oldAPPLY_ID'))) {
		setFalseCheck('APPLY_ID','請先[查詢]，再進行[組長同意]作業!');
	}
	validateNotANumber('DAY_TEL_NUM',"日間電話需為數字");
	validateNotANumber('NIGHT_TEL_NUM',"夜間電話需為數字");
	validateNotANumber('MOBILE',"行動電話需為數字");
	validateNotANumber('DAY_TEL_EXT',"日間電話分機需為數字");
	validateNotANumber('NIGHT_TEL_EXT',"夜間電話分機需為數字");
	if(validate4define.validate() == false) {
		return ;
	}
	
	var reqMap = getReqMap(rtnMap);
	<%--
		if(confirm("否往上一級主管呈核?")) {
			reqMap['IS_END'] = 'N';
		}else {
			reqMap['IS_END'] = 'Y';
		}
	--%>
	
  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doConfirm_check_1", 
	{
			asynchronous : false,
			parameters:{'reqMap':Object.toJSON(reqMap)},
		 	onSuccess:function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						if(confirm('是否往上一級主管呈核?') == false) {
													reqMap['IS_END'] = 'Y';
												}else {
													reqMap['IS_END'] = 'N';
												}
												
												if(reqMap.IS_END=='Y'){
													new Ajax.Request(
														"<%=dispatcher%>/DSA2_1007/print", 
														{
															parameters:{APPLY_ID:$F('APPLY_ID')},
															onSuccess: function(XHT, resp){
																if(CSRUtil.isSuccess(resp)){
																	<%--執行組長同意作業 --%>
																	reqMap.encryptTempFileFullPath = resp.encryptTempFileFullPath;
																  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doConfirm", 
																	{
																			asynchronous : false,
																			parameters:{'reqMap':Object.toJSON(reqMap)},
																		 	onSuccess:function(XHT, resp){
																				if(CSRUtil.isSuccess(resp)){
																					showPageData(resp);
																				}
																			}
																	});
																}
															}
														}
													);
												}else{
													<%--執行組長同意作業 --%>
												  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doConfirm", 
													{
															asynchronous : false,
															parameters:{'reqMap':Object.toJSON(reqMap)},
														 	onSuccess:function(XHT, resp){
																if(CSRUtil.isSuccess(resp)){
																	showPageData(resp);
																}
															}
													});	
												}
					}else{
						if(resp.DATA_NOT_FOUND){
							showPageData({});
						}
					}
			}
	});
}


<%--
	組長退回
--%>
function doCancelConfirm() {
	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%--
		7.1.1	(C)區塊的受理編號與(A)區塊的受理編號不同 || (C)區塊的受理編號為空值時，跳出錯誤訊息，”請先查詢，再進行修改作業!”	
	--%>
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	if($F('oldAPPLY_ID') == '' || ($F('APPLY_ID') !=  $F('oldAPPLY_ID'))) {
		setFalseCheck('APPLY_ID','請先[查詢]，再進行[組長退回]作業!');
	}
	validateNotANumber('DAY_TEL_NUM',"日間電話需為數字");
	validateNotANumber('NIGHT_TEL_NUM',"夜間電話需為數字");
	validateNotANumber('MOBILE',"行動電話需為數字");
	validateNotANumber('DAY_TEL_EXT',"日間電話分機需為數字");
	validateNotANumber('NIGHT_TEL_EXT',"夜間電話分機需為數字");
	if(validate4define.validate() == false) {
		return ;
	}
	
	var reqMap = getReqMap(rtnMap);
  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doCancelConfirm", 
	{
			asynchronous : false,
			parameters:{'reqMap':Object.toJSON(reqMap)},
		 	onSuccess:function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
							showPageData(resp);
					}else{
						if(resp.DATA_NOT_FOUND){
							showPageData({});
						}
					}
			}
	});
}


<%--
	主管同意
--%>
function doApprove() {
	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%--
		8.1	畫面程序檢核:
		8.1.1	(C)區塊的受理編號與(A)區塊的受理編號不同 || (C)區塊的受理編號為空值時，跳出錯誤訊息，”請先查詢，再進行修改作業!”
		8.2	讀取畫面欄位資料:
		8.2.1	將畫面D區資料存成reqMap
		8.2.2	//是否呈核完畢
		reqMap.IS_END =’Y’
	--%>
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	if($F('oldAPPLY_ID') == '' || ($F('APPLY_ID') !=  $F('oldAPPLY_ID'))) {
		setFalseCheck('APPLY_ID','請先[查詢]，再進行[主管同意]作業!');
	}
	validateNotANumber('DAY_TEL_NUM',"日間電話需為數字");
	validateNotANumber('NIGHT_TEL_NUM',"夜間電話需為數字");
	validateNotANumber('MOBILE',"行動電話需為數字");
	validateNotANumber('DAY_TEL_EXT',"日間電話分機需為數字");
	validateNotANumber('NIGHT_TEL_EXT',"夜間電話分機需為數字");
	if(validate4define.validate() == false) {
		return ;
	}
	
	var reqMap = getReqMap(rtnMap);
	reqMap['IS_END'] = 'Y';
	new Ajax.Request(
		"<%=dispatcher%>/DSA2_1007/print", 
		{
			parameters:{APPLY_ID:$F('APPLY_ID')},
			onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					reqMap.encryptTempFileFullPath = resp.encryptTempFileFullPath;
				  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doApprove", 
					{
							asynchronous : false,
							parameters:{'reqMap':Object.toJSON(reqMap)},
						 	onSuccess:function(XHT, resp){
									if(CSRUtil.isSuccess(resp)){
											showPageData(resp);
									}else{
										if(resp.DATA_NOT_FOUND){
											showPageData({});
										}
									}
							}
					});
				}
			}
		}
	);
}

<%--
	試算
--%>
function doCorrectInt() {
	if($F('oldAPPLY_ID') == '' || ($F('APPLY_ID') !=  $F('oldAPPLY_ID'))) {
		alert("請先[查詢]，再進行[試算]作業!!");
		return;
	}
	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%--
		9.1	畫面程序檢核:
		9.1.1	(C)區塊的受理編號與(A)區塊的受理編號不同 || (C)區塊的受理編號為空值時，跳出錯誤訊息，”請先查詢，再進行試算作業!”
		9.2	讀取畫面欄位資料:
		9.2.1	將畫面D區資料存成mapA 
	--%>
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	<%--if($F('oldAPPLY_ID') == '' || ($F('APPLY_ID') !=  $F('oldAPPLY_ID'))) {
		setFalseCheck('APPLY_ID','請先查詢，再進行刪除作業!');
	}--%>
	validateNotANumber('DAY_TEL_NUM',"日間電話需為數字");
	validateNotANumber('NIGHT_TEL_NUM',"夜間電話需為數字");
	validateNotANumber('MOBILE',"行動電話需為數字");
	validateNotANumber('DAY_TEL_EXT',"日間電話分機需為數字");
	validateNotANumber('NIGHT_TEL_EXT',"夜間電話分機需為數字");
	<%-- [20221226]本金彈性還相關檢核 --%>
	validFLEX();
	if(validate4define.validate() == false) {
		return ;
	}
	
	var reqMap = getReqMap(rtnMap);
  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doCorrectInt", 
	{
			asynchronous : false,
			parameters:{'reqMap':Object.toJSON(reqMap)},
		 	onSuccess:function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
							//showPageData(resp);
	 <%--
		表定利率	INTEREST_C	rtnMap.INTEREST_C	1.	顯示欄位
												2.	後面加上"%"
												3.	若rtnMap.IS_CHANGE =false，以文字顯示
		一般型利率	INTEREST	rtnMap.INTEREST	1.	數字格式輸入欄位
												2.	後面加上"%"
												3.	若rtnMap.IS_CHANGE =false，以文字顯示
		理財型利率	INTEREST_M	rtnMap.INTEREST_M	1.	數字格式輸入欄位
													2.	後面加上"%"
													3.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	                     var rtnMap = resp.rtnMap;
	                     $('INTEREST_C').value = getValue(rtnMap['INTEREST_C'],"") !== "" ? rtnMap['INTEREST_C'] : "";
	                     $('SHOW_INTEREST_C').innerHTML = getValue(rtnMap['INTEREST_C'],"") !== "" ?  (CSRUtil.$fmt(rtnMap['INTEREST_C'],"#,###.####") + '%') : "";
	                     $('INTEREST_C_M').value = getValue(rtnMap['INTEREST_C_M'],"") !== "" ? rtnMap['INTEREST_C_M'] : "";
	                     $('SHOW_INTEREST_C_M').innerHTML = getValue(rtnMap['INTEREST_C_M'],"") !== "" ?  (CSRUtil.$fmt(rtnMap['INTEREST_C_M'],"#,###.####") + '%') : "";
	                     setInputAndSpan('INTEREST',rtnMap,'INTEREST',"#,###.####");
	                     setInputAndSpan('INTEREST_M',rtnMap,'INTEREST_M',"#,###.####");	
	                     $('ORI_LOAN_KIND').value = $('LOAN_KIND').value;
	                     $('ORI_PREFER_TYPE').value = $('PREFER_TYPE').value;
	                     $('ORI_LOAN_KIND_M').value = $('LOAN_KIND_M').value;
	                     $('ORI_PREFER_TYPE_M').value = $('PREFER_TYPE_M').value;						
					}
			}
	});
}

<%--
	取消核貸
--%>
function doCancelLoanAgree() {
	<%-- APPLY_ID轉大寫  --%>
	columnToUpperCase('APPLY_ID');

	<%--
		9.1	畫面程序檢核:
		9.1.1	(C)區塊的受理編號與(A)區塊的受理編號不同 || (C)區塊的受理編號為空值時，跳出錯誤訊息，”請先查詢，再進行試算作業!”
		9.2	讀取畫面欄位資料:
		9.2.1	將畫面D區資料存成mapA 
	--%>
	<%-- 執行檢核 --%>
	validate4define.clear();	// 清define
	validate4define.reset();	// 清背景色
	if($F('oldAPPLY_ID') == '' || ($F('APPLY_ID') !=  $F('oldAPPLY_ID'))) {
		setFalseCheck('APPLY_ID','請先[查詢]，再進行[取消核貸]作業!');
	}
	validateNotANumber('DAY_TEL_NUM',"日間電話需為數字");
	validateNotANumber('NIGHT_TEL_NUM',"夜間電話需為數字");
	validateNotANumber('MOBILE',"行動電話需為數字");
	validateNotANumber('DAY_TEL_EXT',"日間電話分機需為數字");
	validateNotANumber('NIGHT_TEL_EXT',"夜間電話分機需為數字");
	if(validate4define.validate() == false) {
		return ;
	}
	
	var reqMap = getReqMap(rtnMap);
	
	new Ajax.Request("<%=dispatcher%>/DSA2_1100/preCancelLoanAgree",{
		//asynchronous : false,
		parameters:{'reqMap':Object.toJSON(reqMap)},
		onSuccess:function(response){
			var resp=response.responseJSON
			if(CSRUtil.isSuccess(resp)){
				callback(reqMap);
			}else{
				msgWin.setCallback(function(){
					msgWin.clearCallback();
					callback(reqMap);
				});
			}
		}
	});
		
}

function callback(reqMap){
	new Ajax.Request("<%=dispatcher%>/DSA2_1007/print",{
			asynchronous : false,
			parameters:{APPLY_ID:$F('APPLY_ID')},
			onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					reqMap.encryptTempFileFullPath = resp.encryptTempFileFullPath;
				  	new Ajax.Request("<%=dispatcher%>/DSA2_1100/doCancelLoanAgree", {
							parameters:{'reqMap':Object.toJSON(reqMap)},
						 	onSuccess:function(XHT, resp){
									if(CSRUtil.isSuccess(resp)){
											showPageData(resp);
									}else{
										if(resp.DATA_NOT_FOUND){
											showPageData({});
										}
									}
							}
					});
				}
			}
		});
}

<%--
	清除
--%>
function doClear() {
	<%--
	11.	清除
	11.1	清空頁面欄位資料，同初始狀態。
	--%>
	$('APPLY_ID').value = "";
	showPageData({});
}

<%--
	設定select list和span元件
--%>
function setSelectListAndSpan(componentID,rtnMap,columnName) {
	 var spanID = 'SHOW_' + componentID;
	 
	 
	 if(document.getElementById(spanID) == null) {
	 	alert(spanID + "無此元件");
	 	return;
	 }
	 if(document.getElementById(componentID) == null) {
	 	alert(componentID + "無此元件");
	 	return;
	 }
	 
	 
	 if(isNotEmpty(rtnMap[columnName]) && rtnMap[columnName] !== "") {
	 	$(componentID).value = rtnMap[columnName];
	 }else {
	 	setFirstOption(componentID);
	 }

	 $(spanID).innerHTML = getSelectedText(componentID,$F(componentID),"");

	 if(isNotEmpty(rtnMap.IS_CHANGE) && rtnMap.IS_CHANGE == "false") {
		$(componentID).style.display = 'none';
		$(spanID).style.display = 'inline';
	 }else {
		$(componentID).style.display = 'inline';
		$(spanID).style.display = 'none';
	 }
}

<%--
	設定input和span元件
--%>
function setInputAndSpan(componentID,rtnMap,columnName,numberPattern,isReadOnly) {
	 var spanID = 'SHOW_' + componentID;
	 
	 if(document.getElementById(spanID) == null) {
	 	alert(spanID + "無此元件");
	 	return;
	 }
	 if(document.getElementById(componentID) == null) {
	 	alert(componentID + "無此元件");
	 	return;
	 }
	 
	 
	 var showValue;
	 if(isNotEmpty(numberPattern)) {
	 	 showValue = getValue(rtnMap[columnName],"") !== "" ? CSRUtil.$fmt(rtnMap[columnName],numberPattern) : "";
	 }else {
	 	 showValue = getValue(rtnMap[columnName],"");
	 }
	 $(componentID).value = showValue;
	 $(spanID).innerHTML = showValue;
	 if(isNotEmpty(isReadOnly) && isReadOnly) {
		 setDisplayComponent(componentID,true,spanID,false);
	 }else {
		 if(isNotEmpty(rtnMap.IS_CHANGE) && rtnMap.IS_CHANGE == "false") {
			 setDisplayComponent(componentID,false,spanID,true);
		 }else {
			 setDisplayComponent(componentID,true,spanID,false);
		 }
	 }
}

<%--
	設定顯示輸入元件還是span元件
--%>
function setDisplayComponent(orgComponentID,orgShow,spanID,spanShow) {
	$(orgComponentID).style.display = (orgShow ? 'inline' : 'none');
	$(spanID).style.display = (spanShow ? 'inline' : 'none');
}

<%--
	設定第一項
--%>
function setFirstOption(name) {
	var targetList = document.getElementById(name);
	if(targetList !=0 && targetList.options.length > 0) {
		$(name).value = targetList.options[0].value;
	}
}

<%--
	取得下拉text
	name : selectList ID
	setValue : 取得的text的value
	defaultText : 預設text
--%>
function getSelectedText(ID,setValue,defaultText) {
	var optiontList = document.getElementById(ID).options;
	
	for( var mover=0; mover < optiontList.length ; mover++) {
		var option = optiontList[mover];
		if(option.value == setValue) {
			return option.text;
		}
	}
	
	return isNotEmpty(defaultText) ?  defaultText : "";
}

<%--
	辨別是否為null or undefined
--%>
function isNotEmpty(value) {
	if(value == null || typeof(value) == 'undefined') {
		return false;
	}else {
		return true;
	}
}

<%--
	取得欄位值
--%>
function getValue(value,defaultValue) {
	return isNotEmpty(value) ? value : defaultValue;
}

<%--
	轉大寫
--%>
function columnToUpperCase(columnName) {
	if(isNotEmpty($F(columnName))) {
		$(columnName).value = $(columnName).value.toUpperCase();
	}
}

<%--
	設定radio值
--%>
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

<%--
	取得radio值
--%>
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

<%--
	顯示資料
--%>
function showPageData(resp) {

	<%--
		已重新查詢過，更新B區選取記錄
	--%>
	sectionBChange = false;

	<%-- 明細(B區) --%>
	rtnList = isNotEmpty(resp.rtnList) ? resp.rtnList : [];
	
	var checkData = ['Y'];	
	
	grid.load(rtnList, null, null, checkData);
    
	<%-- 明細(C D區) --%>
	showSectionCD(resp);	     
}
					
<%--
	設定顯示C D區資料
--%>
function showSectionCD(resp) {

	rtnMap = isNotEmpty(resp.rtnMap) ? resp.rtnMap : [];
	
	//FIXME
	//rtnMap['IS_CHANGE'] = "false";


<%-- 明細(c區) --%>
	<%--受理編號	oldAPPLY_ID	rtnMap.APPLY_ID	顯示欄位--%>
	$('SHOW_oldAPPLY_ID').innerHTML = getValue(rtnMap.APPLY_ID,"");
	$('oldAPPLY_ID').value = getValue(rtnMap.APPLY_ID,"");
	
	<%--借款人ID	BORROW_ID	rtnMap.BORROW_ID + rtnMap.BORROW_NAME	顯示欄位--%>
	$('SHOW_BORROW_ID').innerHTML = getValue(rtnMap.BORROW_NAME,"");
	$('BORROW_ID').value = getValue(rtnMap.BORROW_ID,"");

	<%--受理進度	APPLY_PROCESS_NM	rtnMap.APPLY_PROCESS_NM	顯示欄位--%>
	$('SHOW_APPLY_PROCESS_NM').innerHTML = getValue(rtnMap.APPLY_PROCESS_NM,"");
	$('APPLY_PROCESS_NM').value = getValue(rtnMap.APPLY_PROCESS_NM,"");

	<%--變更進度	AGREE_PROCESS_NM	rtnMap.AGREE_PROCESS_NM	顯示欄位--%>
	$('SHOW_AGREE_PROCESS_NM').innerHTML = getValue(rtnMap.AGREE_PROCESS_A180_NM,"");
	$('AGREE_PROCESS_NM').value = getValue(rtnMap.AGREE_PROCESS_A180_NM,"");
	
<%-- 明細(D區) --%>
	<%-- 房貸類型
				1.	初始:預設未勾選
				2.	查詢:
				IF rtnMap.MM_CODE=’0’:
					勾選「一般型」,
				ELSEIF rtnMap.MM_CODE=’1’:
					勾選「理財型」
				ELSEIF rtnMap.MM_CODE=’2’:
					「一般型」、「理財型」皆勾選
				ELSE
					「一般型」、「理財型」皆未勾選
				END IF 
	 --%>
	 var MM_CODE = getValue(rtnMap.MM_CODE,"");
	 if(MM_CODE == "0") {
		 $('LOAN_C').checked = true; <%-- 一般型 --%>
		 $('LOAN_M').checked = false; <%-- 理財型 --%>
		$('SHOW_LOAN').innerHTML = "一般型";		 
	 }else if(MM_CODE == "1") {
		 $('LOAN_C').checked = false; <%-- 一般型 --%>
		 $('LOAN_M').checked = true; <%-- 理財型 --%>
		$('SHOW_LOAN').innerHTML = "理財型";		 
	 }else if(MM_CODE == "2") {
		 $('LOAN_C').checked = true; <%-- 一般型 --%>
		 $('LOAN_M').checked = true; <%-- 理財型 --%>
		$('SHOW_LOAN').innerHTML = "一般型　理財型";		 
	 }else {
		 $('LOAN_C').checked = false; <%-- 一般型 --%>
		 $('LOAN_M').checked = false; <%-- 理財型 --%>
	 }
	 if(isNotEmpty(rtnMap.IS_CHANGE) && rtnMap.IS_CHANGE == "false") {
		$("SPAN_LOAN").style.display = 'none';
		$("SHOW_LOAN").style.display = 'inline';
	 }else {
		$("SPAN_LOAN").style.display = 'inline';
		$("SHOW_LOAN").style.display = 'none';
	 }
	 
	 
	 <%--
		表定利率	INTEREST_C	rtnMap.INTEREST_C	1.	顯示欄位
												2.	後面加上"%"
												3.	若rtnMap.IS_CHANGE =false，以文字顯示
		一般型利率	INTEREST	rtnMap.INTEREST	1.	數字格式輸入欄位
												2.	後面加上"%"
												3.	若rtnMap.IS_CHANGE =false，以文字顯示
		理財型利率	INTEREST_M	rtnMap.INTEREST_M	1.	數字格式輸入欄位
													2.	後面加上"%"
													3.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	 //setInputAndSpan('INTEREST_C',rtnMap,'INTEREST_C',"#,###.00");
	 $('INTEREST_C').value = getValue(rtnMap['INTEREST_C'],"") !== "" ? rtnMap['INTEREST_C'] : "";
	 $('SHOW_INTEREST_C').innerHTML = getValue(rtnMap['INTEREST_C'],"") !== "" ?  (CSRUtil.$fmt(rtnMap['INTEREST_C'],"#,###.####") + '%') : "";
	 $('INTEREST_C_M').value = getValue(rtnMap['INTEREST_C_M'],"") !== "" ? rtnMap['INTEREST_C_M'] : "";
	 $('SHOW_INTEREST_C_M').innerHTML = getValue(rtnMap['INTEREST_C_M'],"") !== "" ?  (CSRUtil.$fmt(rtnMap['INTEREST_C_M'],"#,###.####") + '%') : "";

	 setInputAndSpan('INTEREST',rtnMap,'INTEREST',"#,###.####");
	 setInputAndSpan('INTEREST_M',rtnMap,'INTEREST_M',"#,###.####");
	 
	 
	 <%--
			一般貸款種類	LOAN_KIND	LOAN_KIND_LIST
			VALUE:
					LOAN_KIND_LIST[i].CODE
			顯示:
					LOAN_KIND_LIST[i].NAME;
					初始:預設顯示第一筆
					查詢:rtnMap.LOAN_KIND	
			
			1.	下拉選單
			2.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	setSelectListAndSpan('LOAN_KIND',rtnMap,'LOAN_KIND'); 
	$('ORI_LOAN_KIND').value = getValue(rtnMap['LOAN_KIND'],"");

	 <%--
			一般優惠種類	PREFER_TYPE	PREFER_TYPE_LIST
			VALUE:
				PREFER_TYPE_LIST[i].CODE
			顯示:
				PREFER_TYPE_LIST[i].NAME;
			初始:預設顯示第一筆
			查詢:rtnMap.PREFER_TYPE	
			1.	下拉選單
			2.	若rtnMap.IS_CHANGE =false，以文字顯示
			
			INSU_PRANK_1_NM	rtnMap.INSU_PRANK_1_NM	顯示欄位，呈現在下拉選單後面
	 --%>
	setSelectListAndSpan('PREFER_TYPE',rtnMap,'PREFER_TYPE'); 
	$('ORI_PREFER_TYPE').value = getValue(rtnMap['PREFER_TYPE'],"");
	if(getValue(rtnMap.INSU_PRANK_1_NM,"") === "") {
		 $('INSU_PRANK_1_NM').innerHTML = "";
	}else {
		 $('INSU_PRANK_1_NM').innerHTML = getValue(rtnMap.INSU_PRANK_1_NM,"");
	}
	 
	 <%--
			一般申請金額	LOAN_AMT	rtnMap.LOAN_AMT	
				1.	數字格式輸入欄位，預設為空白
				2.	後面加上"萬元"
				3.	若rtnMap.IS_CHANGE =false，以文字顯示
				
			一般擬准金額	AGREE_AMT	rtnMap.AGREE_AMT	
				1.	數字格式輸入欄位，預設為空白
				2.	後面加上"萬元"
				3.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	 setInputAndSpan('LOAN_AMT',rtnMap,'LOAN_AMT',"#,###");
	 setInputAndSpan('AGREE_AMT',rtnMap,'AGREE_AMT',"#,###");
	 
	 <%--
		理財貸款種類	LOAN_KIND_M	LOAN_KIND_M_LIST
		VALUE:
			LOAN_KIND_M_LIST[i].CODE
		顯示:
			LOAN_KIND_M_LIST[i].NAME;
			初始:預設顯示第一筆
			查詢:rtnMap.LOAN_KIND_M	
			1.	下拉選單 
			2.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	setSelectListAndSpan('LOAN_KIND_M',rtnMap,'LOAN_KIND_M');
	$('ORI_LOAN_KIND_M').value = getValue(rtnMap['LOAN_KIND_M'],""); 
	 
	 <%--
		理財優惠種類	PREFER_TYPE_M	PREFER_TYPE_M_LIST
		VALUE:
			PREFER_TYPE_M_LIST[i].CODE
		顯示:
			PREFER_TYPE_M_LIST[i].NAME;
			初始:預設顯示第一筆
			查詢:rtnMap.PREFER_TYPE_M	
			1.	下拉選單
			2.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	//setSelectListAndSpan('PREFER_TYPE_M',rtnMap,'PREFER_TYPE_M'); 
	$('PROD_ID').setValue (rtnMap['PREFER_TYPE_M']? '97' + getValue(rtnMap['INSU_PRANK'].substring(0,1),"") : "");
	$('PREFER_TYPE_M').value = getValue(rtnMap['PREFER_TYPE_M'],"");
	$('ORI_PREFER_TYPE_M').value = getValue(rtnMap['PREFER_TYPE_M'],"");
	 
	 <%--
		理財申請金額	LOAN_AMT_M	rtnMap.LOAN_AMT_M	
			1.	數字格式輸入欄位，預設為空白
			2.	後面加上"萬元"
			3.	若rtnMap.IS_CHANGE =false，以文字顯示
		
		理財擬准金額	AGREE_AMT_M	rtnMap.AGREE_AMT_M	
			1.	數字格式輸入欄位，預設為空白
			2.	後面加上"萬元"
			3.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	 setInputAndSpan('LOAN_AMT_M',rtnMap,'LOAN_AMT_M',"#,###");
	 setInputAndSpan('AGREE_AMT_M',rtnMap,'AGREE_AMT_M',"#,###");
	 
	 
	 <%--
		電話(日)_區碼	DAY_TEL_AREA	TEL_AREA_LIST
		VALUE:
			TEL_AREA_LIST[i].CODE
		顯示:
			TEL_AREA_LIST[i].NAME;
			初始:預設顯示第一筆
			查詢:rtnMap.DAY_TEL_AREA	
			1.	下拉選單
			2.	若rtnMap.IS_CHANGE =false，以文字顯示
		電話(日)_號碼	DAY_TEL_NUM	rtnMap.DAY_TEL_NUM	
			1.	文數字格式輸入欄位
			2.	預設為空白
			3.	後面加上"#"
			4.	若rtnMap.IS_CHANGE =false，以文字顯示
		電話(日)_分機	DAY_TEL_EXT	rtnMap.DAY_TEL_EXT	
			1.	文數字格式輸入欄位
			2.	預設為空白
			3.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	setSelectListAndSpan('DAY_TEL_AREA',rtnMap,'DAY_TEL_AREA'); 
	setInputAndSpan('DAY_TEL_NUM',rtnMap,'DAY_TEL_NUM');
	setInputAndSpan('DAY_TEL_EXT',rtnMap,'DAY_TEL_EXT');
	 
	 
	 <%--
		設定金額	SET_AMT	rtnMap.SET_AMT	
		1.	數字格式輸入欄位，預設為空白
		2.	後面加上"萬元"
		3.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	setInputAndSpan('SET_AMT',rtnMap,'SET_AMT',"#,###");
	
	setInputAndSpan('CRED_TRADE_AMT',rtnMap,'CRED_TRADE_AMT',"#,###.#");
	 
	 <%--
		電話(夜)_區碼	NIGHT_TEL_AREA	TEL_AREA_LIST
		VALUE:
			TEL_AREA_LIST[i].CODE
		顯示:
			TEL_AREA_LIST[i].NAME;
		初始:預設顯示第一筆
		查詢:rtnMap.NIGHT_TEL_AREA	1.	下拉選單
		
		2.	若rtnMap.IS_CHANGE =false，以文字顯示-
		電話(夜)_號碼	NIGHT_TEL_NUM	rtnMap.NIGHT_TEL_NUM	1.	文數字格式輸入欄位
		2.	預設為空白
		3.	後面加上”#”
		4.	若rtnMap.IS_CHANGE =false，以文字顯示

		電話(夜)_分機	NIGHT_TEL_EXT	rtnMap.NIGHT_TEL_EXT	1.	文數字格式輸入欄位
		2.	預設為空白
		3.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	setSelectListAndSpan('NIGHT_TEL_AREA',rtnMap,'NIGHT_TEL_AREA'); 
	setInputAndSpan('NIGHT_TEL_NUM',rtnMap,'NIGHT_TEL_NUM');
	setInputAndSpan('NIGHT_TEL_EXT',rtnMap,'NIGHT_TEL_EXT');
	
	 <%--
		代償金額	COMP_AMT	rtnMap.COMP_AMT	
		1.	數字格式輸入欄位，預設為空白
		2.	後面加上"萬元"
		3.	若rtnMap.IS_CHANGE =false，以文字顯示
		行動電話	MOBILE	rtnMap.MOBILE	
		1.	文數字格式輸入欄位
		2.	預設為空白
		3.	若rtnMap.IS_CHANGE =false，以文字顯示
		
		火險年期_年	FIREINSU_YY	rtnMap.FIREINSU_YY	
		1.	數字格式輸入欄位
		2.	預設為空白
		3.	後面加上"年"
		4.	若rtnMap.IS_CHANGE =false，以文字顯示
		火險年期_月	FIREINSU_MM	rtnMap.FIREINSU_MM	
		1.	數字格式輸入欄位
		2.	預設為空白
		3.	後面加上"月"
		4.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	 setInputAndSpan('COMP_AMT',rtnMap,'COMP_AMT',"#,###");
	 setInputAndSpan('MOBILE',rtnMap,'MOBILE');
	 setInputAndSpan('FIREINSU_YY',rtnMap,'FIREINSU_YY');
	 setInputAndSpan('FIREINSU_MM',rtnMap,'FIREINSU_MM');
	 
	 <%--
		是否贈送火險	INSUFREE_CODE	rtnMap.INSUFREE_CODE	
		1.	RADIO 0:否  1:是
		2.	若rtnMap.IS_CHANGE =false，以文字顯示

		火險保額	FIREINSU_AMT	rtnMap.FIREINSU_AMT	
		1.	數字格式輸入欄位
		2.	預設為空白
		3.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	 setRadioValue("INSUFREE_CODE",rtnMap.INSUFREE_CODE);
	 $('SHOW_INSUFREE_CODE').innerHTML = (rtnMap.INSUFREE_CODE == "1" ? "是" : "否") ;
	 if(isNotEmpty(rtnMap.IS_CHANGE) && rtnMap.IS_CHANGE == "false") {
		$("SPAN_INSUFREE_CODE").style.display = 'none';
		$("SHOW_INSUFREE_CODE").style.display = 'inline';
	 }else {
		$("SPAN_INSUFREE_CODE").style.display = 'inline';
		$("SHOW_INSUFREE_CODE").style.display = 'none';
	 }
	 setInputAndSpan('FIREINSU_AMT',rtnMap,'FIREINSU_AMT',"#,###");
	 
	 <%-- 
	        換算業績(元)	BASE_AMT
	   1.	IF  loan_type=2 ,6，才顯示
       2.	顯示欄位	 
	 --%>
	 if(rtnMap.LOAN_TYPE=="2" || rtnMap.LOAN_TYPE=="6" ){
	    $("SHOW_BASE_AMT").innerHTML = getValue(rtnMap["BASE_AMT"],"") !== "" ? CSRUtil.$fmt(rtnMap["BASE_AMT"],"#,###") : "";
	    $("SHOW_BASE_AMT_LABEL").style.display = 'inline';
	    $("SHOW_BASE_AMT").style.display = 'inline';
	 }else{
	    $("SHOW_BASE_AMT_LABEL").style.display = 'none';
	    $("SHOW_BASE_AMT").style.display = 'none';
	 }
	 
	 
	 <%--
		還款方式	RETURN_TYPE	RETURN_TYPE_LIST
		VALUE:
			RETURN_TYPE_LIST[i].CODE
		顯示:
			RETURN_TYPE_LIST[i].NAME;
		初始:預設顯示第一筆
		查詢:rtnMap.RETURN_TYPE	
			1.	下拉選單 
			2.	後面加上"定期"+  rtnMap.FIX_YY +"年"+ rtnMap.FIX_MM + "月+"+ rtnMap.SPR_YY+"年"+ rtnMap.SPR_MM+"月"
			3.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	setSelectListAndSpan('RETURN_TYPE',rtnMap,'RETURN_TYPE');
	$('SHOW_RETURN_TYPE').style.display = 'none';
	
	setInputAndSpan('FIX_YY',rtnMap,'FIX_YY');
	setInputAndSpan('FIX_MM',rtnMap,'FIX_MM');
	setInputAndSpan('SPR_YY',rtnMap,'SPR_YY');
	setInputAndSpan('SPR_MM',rtnMap,'SPR_MM');
	changeReturnType();	
	if(rtnMap['IS_CHANGE'] == 'false') {
		showOnlyReturnType();
	}
	
	 <%--
		定期期數	FIX_PERIOD	rtnMap.FIX_PERIOD	
		1.	隱藏欄位
		2.	rtnMap.FIX_PERIOD= FIX_YY * 12 + FIX_MM
		
		分期期數	SPR_PERIOD	rtnMap.SPR_PERIOD	
		1.	隱藏欄位
		2.	rtnMap.SPR_PERIOD= SPR_YY * 12 + SPR_MM
	 --%>
	 $('FIX_PERIOD').value = getValue(rtnMap.FIX_PERIOD,"0");
	 $('SPR_PERIOD').value = getValue(rtnMap.SPR_PERIOD,"0");
	 
	 <%--
		A值	A_VALUE	A_VALUE_LIST
		VALUE:
			A_VALUE_LIST[i].CODE
		顯示:
			A_VALUE_LIST[i].NAME;
		初始:預設顯示第一筆
		查詢:rtnMap.A_VALUE	
			1.	下拉選單
			2.	若rtnMap.IS_CHANGE =false，以文字顯示
		
		
		優質客戶等級	VIP_GRADE	VIP_GRADE_LIST
		VALUE:
			VIP_GRADE_LIST[i].CODE
		顯示:
			VIP_GRADE_LIST[i].NAME;
		初始:預設顯示第一筆
		查詢:rtnMap.VIP_GRADE	
			1.	下拉選單
			2.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	setSelectListAndSpan('A_VALUE',rtnMap,'A_VALUE');
	setSelectListAndSpan('VIP_GRADE',rtnMap,'VIP_GRADE');
	setSelectListAndSpan('VIP_GRADE_M',rtnMap,'VIP_GRADE_M');
	 
	 
	<%--
		是否檢附相關證明	CHECK_PAPER	rtnMap.CHECK_PAPER	
			1.	RADIO
			false:否  true:是
			2.	若rtnMap.IS_CHANGE =false，以文字顯示
	--%>
	 setRadioValue("CHECK_PAPER",rtnMap.CHECK_PAPER);
	 $('SHOW_CHECK_PAPER').innerHTML = (rtnMap.CHECK_PAPER === "true" ? "是" : "否") ;
	 if(isNotEmpty(rtnMap.IS_CHANGE) && rtnMap.IS_CHANGE == "false") {
		$("SPAN_CHECK_PAPER").style.display = 'none';
		$("SHOW_CHECK_PAPER").style.display = 'inline';
	 }else {
		$("SPAN_CHECK_PAPER").style.display = 'inline';
		$("SHOW_CHECK_PAPER").style.display = 'none';
	 }
	 
	 <%--
		客戶類別	VIP_CUSTOMER	VIP_CUSTOMER_LIST
		VALUE:
			VIP_CUSTOMER_LIST[i].CODE
		顯示:
			VIP_CUSTOMER_LIST[i].NAME
		初始:預設顯示第一筆
		查詢:rtnMap.VIP_CUSTOMER	1.	下拉選單
		2.	若rtnMap.IS_CHANGE =false，以文字顯示
		
		地段類別	VIP_AREA	VIP_AREA_LIST
		VALUE:
			VIP_AREA_LIST[i].CODE
		顯示:
			VIP_AREA_LIST[i].NAME;
		初始:預設顯示第一筆
		查詢:rtnMap.VIP_AREA	
		1.	下拉選單
		2.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>
	setSelectListAndSpan('VIP_CUSTOMER',rtnMap,'VIP_CUSTOMER');
	setSelectListAndSpan('VIP_AREA',rtnMap,'VIP_AREA');
	
	 <%--
		是否首月免息	REMISSION_INT	rtnMap.REMISSION_INT	
		1.	RADIO 0:否  1:是
		2.	若rtnMap.IS_CHANGE =false，以文字顯示
	 --%>	 
	 setRadioValue("REMISSION_INT",rtnMap.REMISSION_INT);
	 $('SHOW_REMISSION_INT').innerHTML = rtnMap.REMISSION_INT == "1" ? "是" : "否" ;
	 if(isNotEmpty(rtnMap.IS_CHANGE) && rtnMap.IS_CHANGE == "false") {
		$("SPAN_REMISSION_INT").style.display = 'none';
		$("SHOW_REMISSION_INT").style.display = 'inline';
	 }else {
		$("SPAN_REMISSION_INT").style.display = 'inline';
		$("SHOW_REMISSION_INT").style.display = 'none';
	 }
	 //setInputAndSpan('REMISSION_INT',rtnMap,'REMISSION_INT');
	 
	<%--
		修改原因	CORRECT_NOTE	rtnMap.CORRECT_NOTE	
		1.	文字輸入欄位，長度500
		2.	若rtnMap.IS_CHANGE =false，以文字顯示
	--%>
	setInputAndSpan('CORRECT_NOTE',rtnMap,'CORRECT_NOTE');
	$('SHOW_CORRECT_LOG').innerHTML = getValue(rtnMap.CORRECT_LOG,"");;
	
	<%--
		========================DSZ0_1000===========================
	--%>
	
<%--
------------------------------ inputType=2 ------------------------------
DSZ01000.setCITY_NAME			設定縣市別
DSZ01000.getCITY_NAME			取得縣市別
DSZ01000.setTOWN_NAME			設定鄉鎮市區別
DSZ01000.getTOWN_NAME			取得鄉鎮市區別
DSZ01000.setROAD_NAME			設定路名
DSZ01000.DSZ01000.getROAD_NAME	取得路名
DSZ01000.setADDR_NAME			設定門牌號碼分群
DSZ01000.getADDR_NAME			取得門牌號碼分群
DSZ01000.setINPUT_ZIPCODE		設定郵遞區號
DSZ01000.getINPUT_ZIPCODE		取得郵遞區號
DSZ01000.setINPUT_ADDR			設定地址
DSZ01000.getINPUT_ADDR			取得地址
DSZ01000.displayOnly			單純顯示地址
DSZ01000.getAllSelectObject		取得全部的欄位DOM物件
DSZ01000.checkData				檢核欄位
DSZ01000.display4INPUT_ZIPCODE	決定INPUT_ZIPCODE的顯示方式("1":顯示span, "2":輸入input, 其他輸入為隱藏)
DSZ01000.display4INPUT_ADDR		決定INPUT_ADDR的顯示方式("1":顯示span, "2":輸入input, 其他輸入為隱藏)
--%>

	<%--
		收息地址_通訊地址碼	CON_CODE	rtnMap.CON_CODE	
		1.	RADIO	={1:同擔保品地址  2:其他如下}
		2.	若選”1”，則下列收息地址相關資料不需呈現
		3.	若rtnMap.IS_CHANGE =false，以文字顯示
	--%>
	 setRadioValue("CON_CODE",rtnMap.CON_CODE);
	 $('SHOW_CON_CODE').innerHTML = (rtnMap.CON_CODE == "1" ? "同擔保品地址" : "其他如下");
	 if(isNotEmpty(rtnMap.IS_CHANGE) && rtnMap.IS_CHANGE == "false") {
		$("SPAN_CON_CODE").style.display = 'none';
		$("SHOW_CON_CODE").style.display = 'inline';
	 }else {
		$("SPAN_CON_CODE").style.display = 'inline';
		$("SHOW_CON_CODE").style.display = 'none';
	 }
	
	<%--
		收息地址_其他(郵遞區號)	ZIPCODE	VALUE:
		DSZ01000.jsp 回傳值;
		初始:預設顯示空白
		查詢:SET rtnMap.ZIPCODE =  rtnMap.COND_CODE	
		1.	rtnMap.CON_CODE=’2’ ，才顯示
		2.	下拉選單
		3.	若rtnMap.IS_CHANGE =false，以文字顯示
	--%>
	page_DSZ01000.setINPUT_ZIPCODE(getValue(rtnMap['CON_ZIP'],""));
	
	<%--
		收息地址_其他(詳細地址)	ADDR	VALUE:
		DSZ01000.jsp 回傳值;
		初始:預設顯示空白
		查詢:SET rtnMap.ADDR =  rtnMap.COND_ADDR
		1.	rtnMap.CON_CPDE=’2’，才顯示
		2.	下拉選單
	--%>
	page_DSZ01000.setINPUT_ADDR(getValue(rtnMap['CON_ADDR'],""));
	
	<%--
		顯示部份文字
	--%>
	$('SHOW_DSA21100').innerHTML = getValue(rtnMap['CON_ZIP'],"") + " " + getValue(rtnMap['CON_ADDR'],"");
	
	if(isNotEmpty(rtnMap.IS_CHANGE) && rtnMap.IS_CHANGE == "false") { 
		//顯示模式
			$('DSA21100_MODIFY').style.display = 'none';		
			$('DSA21100_TEXT').style.display = 'inline';		
	}else {
		if(rtnMap.CON_CODE == "1"){
		<%--
			<td colspan="5" class="tbYellow2">
				<span id="SPAN_CON_CODE">
					<input type="radio" name="CON_CODE" value="1"/>同擔保品地址
					<input type="radio" name="CON_CODE" value="0"/>其他如下
				</span>
				<span name="SHOW_CON_CODE" id="SHOW_CON_CODE"/>
				<br>
				<span id="DSA21100_MODIFY">
					<span id="DSA21100"></span>
				</span>
				<span id="DSA21100_TEXT">
					<span id="SHOW_DSA21100"></span>
				</span>
			</td>
		--%>	
			<%-- 下列收息地址相關資料不需呈現 --%>
			$('DSA21100_MODIFY').style.display = 'none';		
			$('DSA21100_TEXT').style.display = 'none';		
		}else {
			$('DSA21100_MODIFY').style.display = 'inline';		
			$('DSA21100_TEXT').style.display = 'none';		
		}
	}
	<%--[20221226]本金彈性還/每月約定還本擬准類型--%>
	setRadioValue("IS_FLEX", rtnMap.IS_FLEX);
	if(rtnMap.IS_FLEX){
		chgIS_FLEX();
	}
	$('FLEX_MIN').update(CSRUtil.$fmt(rtnMap.FLEX_MIN, "#,###"));
	$('FLEX_MAX').update(CSRUtil.$fmt(rtnMap.FLEX_MAX, "#,###"));
	$('AGREE_FLEX_AMT').setValue('');
	$('FLEX_PERIOD_B').setValue('');
	$('FLEX_PERIOD_E').setValue('');
	if(rtnMap.IS_FLEX == 'Y'){
		setRadioValue("AGREE_FLEX_TYPE", rtnMap.AGREE_FLEX_TYPE);
		if(rtnMap.AGREE_FLEX_TYPE == '2'){
			$('AGREE_FLEX_AMT').setValue(rtnMap.AGREE_FLEX_AMT || '');
		}
		$('FLEX_PERIOD_B').setValue(rtnMap.FLEX_PERIOD_B || '');
		$('FLEX_PERIOD_E').setValue(rtnMap.FLEX_PERIOD_E || '');
	}
}

<%--
	取得reqMap
--%>
function getReqMap(reqMap) {
	//var reqMap = {};
	
<%-- 明細(c區) --%>
	<%--受理編號	oldAPPLY_ID	rtnMap.APPLY_ID	顯示欄位--%>
	reqMap["APPLY_ID"] = $('oldAPPLY_ID').value;
	reqMap["oldAPPLY_ID"] = $('oldAPPLY_ID').value;

	<%--借款人ID	BORROW_ID	rtnMap.BORROW_ID + rtnMap.BORROW_NAME	顯示欄位--%>
	reqMap["BORROW_ID"] = $('BORROW_ID').value;

	<%--受理進度	APPLY_PROCESS_NM	rtnMap.APPLY_PROCESS_NM	顯示欄位--%>
	reqMap["APPLY_PROCESS_NM"] = $('APPLY_PROCESS_NM').value;

	<%--變更進度	AGREE_PROCESS_NM	rtnMap.AGREE_PROCESS_NM	顯示欄位--%>
	reqMap["AGREE_PROCESS_NM"] = $('AGREE_PROCESS_NM').value;
	
<%-- 明細(D區) --%>
	<%-- 房貸類型
				IF rtnMap.MM_CODE=’0’:			勾選「一般型」,
				ELSEIF rtnMap.MM_CODE=’1’:		勾選「理財型」
				ELSEIF rtnMap.MM_CODE=’2’:		「一般型」、「理財型」皆勾選
				ELSE							「一般型」、「理財型」皆未勾選
				END IF 
	 --%>
	if($('LOAN_C').checked && $('LOAN_M').checked) {
		reqMap["MM_CODE"] = '2';
		reqMap['PREFER_TYPE_M'] = "00";
	}else if($('LOAN_C').checked && $('LOAN_M').checked == false) {
		reqMap["MM_CODE"] = '0';
		reqMap['PREFER_TYPE_M'] = "";		
	}else if($('LOAN_C').checked == false && $('LOAN_M').checked) {
		reqMap["MM_CODE"] = '1';
		reqMap['PREFER_TYPE_M'] = "00";
	}else {
		reqMap["MM_CODE"] = null;
		reqMap['PREFER_TYPE_M'] = "";
	}
	
	 <%--
		表定利率	INTEREST_C	rtnMap.INTEREST_C	1.	顯示欄位
		一般型利率	INTEREST	rtnMap.INTEREST	1.	數字格式輸入欄位
		理財型利率	INTEREST_M	rtnMap.INTEREST_M	1.	數字格式輸入欄位
	 --%>
	reqMap["INTEREST_C"] = getNumberValue('INTEREST_C');
	reqMap["INTEREST_C_M"] = getNumberValue('INTEREST_C_M');
	reqMap["INTEREST"] = getNumberValue('INTEREST');
	reqMap["INTEREST_M"] = getNumberValue('INTEREST_M');
	
	
	 <%--
			一般貸款種類	LOAN_KIND	LOAN_KIND_LIST
			一般優惠種類	PREFER_TYPE	PREFER_TYPE_LIST
			INSU_PRANK_1_NM	rtnMap.INSU_PRANK_1_NM	顯示欄位，呈現在下拉選單後面
	 --%>
	reqMap["LOAN_KIND"] = $('LOAN_KIND').value;
	reqMap["PREFER_TYPE"] = $('PREFER_TYPE').value;
	reqMap["INSU_PRANK_1_NM"] = $('INSU_PRANK_1_NM').value;
	
	
	 <%--
			一般申請金額	LOAN_AMT	rtnMap.LOAN_AMT	
			一般擬准金額	AGREE_AMT	rtnMap.AGREE_AMT	
			理財貸款種類	LOAN_KIND_M	LOAN_KIND_M_LIST
			理財優惠種類	PREFER_TYPE_M	PREFER_TYPE_M_LIST
			理財申請金額	LOAN_AMT_M	rtnMap.LOAN_AMT_M	
			理財擬准金額	AGREE_AMT_M	rtnMap.AGREE_AMT_M	
			
			電話(日)_區碼	DAY_TEL_AREA	TEL_AREA_LIST
			電話(日)_號碼	DAY_TEL_NUM	rtnMap.DAY_TEL_NUM	
			電話(日)_分機	DAY_TEL_EXT	rtnMap.DAY_TEL_EXT	
	 --%>
	reqMap["LOAN_AMT"] = getNumberValue('LOAN_AMT');
	reqMap["AGREE_AMT"] = getNumberValue('AGREE_AMT');
	reqMap["LOAN_KIND_M"] = $('LOAN_KIND_M').value;
	//reqMap["PREFER_TYPE_M"] = $('PREFER_TYPE_M').value;
	reqMap["LOAN_AMT_M"] = getNumberValue('LOAN_AMT_M');
	reqMap["AGREE_AMT_M"] = getNumberValue('AGREE_AMT_M');
	
	reqMap["DAY_TEL_AREA"] = $('DAY_TEL_AREA').value;
	reqMap["DAY_TEL_NUM"] = $('DAY_TEL_NUM').value;
	reqMap["DAY_TEL_EXT"] = $('DAY_TEL_EXT').value;
	 
	 
	 <%--
		電話(夜)_區碼	NIGHT_TEL_AREA	TEL_AREA_LIST
		電話(夜)_號碼	NIGHT_TEL_NUM	rtnMap.NIGHT_TEL_NUM	1.	文數字格式輸入欄位
		電話(夜)_分機	NIGHT_TEL_EXT	rtnMap.NIGHT_TEL_EXT	1.	文數字格式輸入欄位
		
		設定金額	SET_AMT	rtnMap.SET_AMT	
		
		代償金額	COMP_AMT	rtnMap.COMP_AMT	
		行動電話	MOBILE	rtnMap.MOBILE	
		火險年期_年	FIREINSU_YY	rtnMap.FIREINSU_YY	
		火險年期_月	FIREINSU_MM	rtnMap.FIREINSU_MM	
		
		是否贈送火險	INSUFREE_CODE	rtnMap.INSUFREE_CODE	
		火險保額	FIREINSU_AMT	rtnMap.FIREINSU_AMT	
	 --%>
	reqMap["NIGHT_TEL_AREA"] = $('NIGHT_TEL_AREA').value;
	reqMap["NIGHT_TEL_NUM"] = $('NIGHT_TEL_NUM').value;
	reqMap["NIGHT_TEL_EXT"] = $('NIGHT_TEL_EXT').value;
	 
	reqMap["SET_AMT"] = getNumberValue('SET_AMT');
	reqMap["CRED_TRADE_AMT"] = getNumberValue('CRED_TRADE_AMT');
	 
	reqMap["COMP_AMT"] = getNumberValue('COMP_AMT');
	reqMap["MOBILE"] = $('MOBILE').value;
	reqMap["FIREINSU_YY"] = getNumberValue('FIREINSU_YY');
	reqMap["FIREINSU_MM"] = getNumberValue('FIREINSU_MM');
	
	reqMap["INSUFREE_CODE"] = getRadioValue('INSUFREE_CODE');
	reqMap["FIREINSU_AMT"] = getNumberValue('FIREINSU_AMT');
	
	
	 <%--
		還款方式	RETURN_TYPE	RETURN_TYPE_LIST
		定期期數	FIX_PERIOD	rtnMap.FIX_PERIOD	
		分期期數	SPR_PERIOD	rtnMap.SPR_PERIOD	

		A值	A_VALUE	A_VALUE_LIST
		優質客戶等級	VIP_GRADE	VIP_GRADE_LIST
		
		換算業績(元)	BASE_AMT	rtnMap.VIP_GRADE	
		是否檢附相關證明	CHECK_PAPER	rtnMap.CHECK_PAPER	
		
		
		客戶類別	VIP_CUSTOMER	VIP_CUSTOMER_LIST
		地段類別	VIP_AREA	VIP_AREA_LIST

		是否首月免息	REMISSION_INT	rtnMap.REMISSION_INT	
		
		修改原因	CORRECT_NOTE	rtnMap.CORRECT_NOTE	
	 --%>
	reqMap["RETURN_TYPE"] = $('RETURN_TYPE').value;
	reqMap["FIX_PERIOD"] = $('FIX_PERIOD').value;
	reqMap["SPR_PERIOD"] = $('SPR_PERIOD').value;

	reqMap["FIX_YY"] = $('FIX_YY').value;
	reqMap["FIX_MM"] = $('FIX_MM').value;
	reqMap["SPR_YY"] = $('SPR_YY').value;
	reqMap["SPR_MM"] = $('SPR_MM').value;

	reqMap["A_VALUE"] = $('A_VALUE').value;
	reqMap["VIP_GRADE"] = $('VIP_GRADE').value;
	reqMap["VIP_GRADE_M"] = $('VIP_GRADE_M').value;

	reqMap["BASE_AMT"] = getValue(rtnMap.BASE_AMT);
	reqMap["CHECK_PAPER"] = getRadioValue('CHECK_PAPER');
	
	reqMap["VIP_CUSTOMER"] = $('VIP_CUSTOMER').value;
	reqMap["VIP_AREA"] = $('VIP_AREA').value;

	reqMap["REMISSION_INT"] = getRadioValue('REMISSION_INT');
	reqMap["CORRECT_NOTE"] = $('CORRECT_NOTE').value;
	
	
	<%--
		========================DSZ0_1000===========================
		
DSZ01000.setCITY_NAME			設定縣市別
DSZ01000.getCITY_NAME			取得縣市別
DSZ01000.setTOWN_NAME			設定鄉鎮市區別
DSZ01000.getTOWN_NAME			取得鄉鎮市區別
DSZ01000.setROAD_NAME			設定路名
DSZ01000.DSZ01000.getROAD_NAME	取得路名
DSZ01000.setADDR_NAME			設定門牌號碼分群
DSZ01000.getADDR_NAME			取得門牌號碼分群
DSZ01000.setINPUT_ZIPCODE		設定郵遞區號
DSZ01000.getINPUT_ZIPCODE		取得郵遞區號
DSZ01000.setINPUT_ADDR			設定地址
DSZ01000.getINPUT_ADDR			取得地址
DSZ01000.displayOnly			單純顯示地址
DSZ01000.getAllSelectObject		取得全部的欄位DOM物件
DSZ01000.checkData				檢核欄位
DSZ01000.display4INPUT_ZIPCODE	決定INPUT_ZIPCODE的顯示方式("1":顯示span, "2":輸入input, 其他輸入為隱藏)
DSZ01000.display4INPUT_ADDR		決定INPUT_ADDR的顯示方式("1":顯示span, "2":輸入input, 其他輸入為隱藏)
	--%>
	
	<%--
		收息地址_通訊地址碼	CON_CODE	rtnMap.CON_CODE	
		1.	RADIO	={1:同擔保品地址  2:其他如下}
		2.	若選”1”，則下列收息地址相關資料不需呈現
		3.	若rtnMap.IS_CHANGE =false，以文字顯示
	--%>
	reqMap["CON_CODE"] = getRadioValue('CON_CODE');
	
	<%--
		收息地址_其他(郵遞區號)	ZIPCODE	VALUE:
		DSZ01000.jsp 回傳值;
		初始:預設顯示空白
		查詢:SET rtnMap.ZIPCODE =  rtnMap.COND_CODE	
		1.	rtnMap.CON_CODE=’2’ ，才顯示
		2.	下拉選單
		3.	若rtnMap.IS_CHANGE =false，以文字顯示
	--%>
	reqMap["CON_ZIP"] = page_DSZ01000.getINPUT_ZIPCODE();
	
	<%--
		收息地址_其他(詳細地址)	ADDR	VALUE:
		DSZ01000.jsp 回傳值;
		初始:預設顯示空白
		查詢:SET rtnMap.ADDR =  rtnMap.COND_ADDR
		1.	rtnMap.CON_CPDE=’2’，才顯示
		2.	下拉選單
	--%>
	reqMap["CON_ADDR"] = page_DSZ01000.getINPUT_ADDR();
	
	<%--[20221226]本金彈性還相關欄位--%>
	reqMap["IS_FLEX"] = getRadioValue('IS_FLEX');
	reqMap["FLEX_PERIOD_B"] = '';
	reqMap["FLEX_PERIOD_E"] = '';
	if(reqMap["IS_FLEX"] == 'Y'){
		reqMap["AGREE_FLEX_TYPE"] = getRadioValue('AGREE_FLEX_TYPE');
		reqMap["AGREE_FLEX_AMT"] = $F('AGREE_FLEX_AMT');
		if(reqMap["AGREE_FLEX_TYPE"] ==  '0'){
			reqMap["AGREE_FLEX_AMT"] = $('FLEX_MIN').innerHTML.gsub(',', '');
		}else if(reqMap["AGREE_FLEX_TYPE"] ==  '1'){
			reqMap["AGREE_FLEX_AMT"] = $('FLEX_MAX').innerHTML.gsub(',', '');
		}
		reqMap["FLEX_PERIOD_B"] = $F('FLEX_PERIOD_B').blank() ? '0' : $F('FLEX_PERIOD_B');
		reqMap["FLEX_PERIOD_E"] = $F('FLEX_PERIOD_E').blank() ? '0' : $F('FLEX_PERIOD_E');
	}
	return reqMap;
}


<%--
	顯示或不顯示地址
--%>
function changeAddressStatus() {
	var CON_CODE = getRadioValue('CON_CODE');
	if(CON_CODE === '1') {
		$('DSA21100_MODIFY').style.display = 'none';		
		$('DSA21100_TEXT').style.display = 'none';		
	}else {
		$('DSA21100_MODIFY').style.display = 'inline';		
		$('DSA21100_TEXT').style.display = 'none';		
	}
}

<%--
	取得數值
--%>
function getNumberValue(ID) {
	return $F(ID).replace(/,/g,'');
}

<%--
	計算FIX_PERIOD連動
--%>
function calFIX_PERIOD() {
	<%--
		定期期數	FIX_PERIOD	rtnMap.FIX_PERIOD	
		1.	隱藏欄位
		2.	rtnMap.FIX_PERIOD= FIX_YY * 12 + FIX_MM
	--%>
	var FIX_YY = getNumberValue('FIX_YY') === '' ? "0" : getNumberValue('FIX_YY');
	var FIX_MM = getNumberValue('FIX_MM') === '' ? "0" : getNumberValue('FIX_MM');
	$('FIX_PERIOD').value = FIX_YY * 12 + parseInt(FIX_MM);
}

<%--
	計算FIX_PERIOD連動
--%>
function calSPR_PERIOD() {
	<%--
		分期期數	SPR_PERIOD	rtnMap.SPR_PERIOD	
		1.	隱藏欄位
		2.	rtnMap.SPR_PERIOD= SPR_YY * 12 + SPR_MM
	--%>
	var SPR_YY = getNumberValue('SPR_YY') === '' ? "0" : getNumberValue('SPR_YY');
	var SPR_MM = getNumberValue('SPR_MM') === '' ? "0" : getNumberValue('SPR_MM');
	$('SPR_PERIOD').value = SPR_YY * 12 + parseInt(SPR_MM);
}

<%--
	還款方式連動設定
--%>
function changeReturnType() {
	<%--
		<span id="leftPartTitle">定期</span>

		<input type="text" name="FIX_YY" ID="FIX_YY" value ="" size="2" class="textBox2" onChange="calFIX_PERIOD()" datatype="number" pattern="#,###" >
		<span id="SHOW_FIX_YY"></span>

		<span id="leftPartYear">年</span>

		<input type="text" name="FIX_MM" ID="FIX_MM" value ="" size="2" class="textBox2" onChange="calFIX_PERIOD()" datatype="number" pattern="#,###">
		<span id="SHOW_FIX_MM"></span>

		<span id="leftPartMonth">月</span>
		
		<span id="plus">+</span>

		<span id="rightPartTitle">分期</span>
		<input type="text" name="SPR_YY" ID="SPR_YY" value ="" size="2" class="textBox2" onChange="calSPR_PERIOD()" datatype="number" pattern="#,###">
		<span id="SHOW_SPR_YY"></span>

		<span id="rightPartYear">年</span>

		<input type="text" name="SPR_MM" ID="SPR_MM" value ="" size="2" class="textBox2" onChange="calSPR_PERIOD()" datatype="number" pattern="#,###">
		<span id="SHOW_SPR_MM"></span>

		<span id="rightPartMonth">月</span>
		
<option value="1">分期</option>
<option value="3">定期</option>
<option value="2">定期+分期</option>
<option value="4">定期+分期+部分本金攤還(屆期還款)</option>
		
	--%>
	$('leftPartTitle').style.display = 'none';
	$('FIX_YY').style.display = 'none';
	$('leftPartYear').style.display = 'none';
	$('FIX_MM').style.display = 'none';
	$('leftPartMonth').style.display = 'none';
	$('plus').style.display = 'none';
	$('rightPartTitle').style.display = 'none';
	$('SPR_YY').style.display = 'none';
	$('rightPartYear').style.display = 'none';
	$('SPR_MM').style.display = 'none';
	$('rightPartMonth').style.display = 'none';
	
	var value = $('RETURN_TYPE').value
	if(value == '1') {
		$('rightPartTitle').style.display = 'inline';
		$('SPR_YY').style.display = 'inline';
		$('rightPartYear').style.display = 'inline';
		$('SPR_MM').style.display = 'inline';
		$('rightPartMonth').style.display = 'inline';
	}else if(value == '3') {
		$('leftPartTitle').style.display = 'inline';
		$('FIX_YY').style.display = 'inline';
		$('leftPartYear').style.display = 'inline';
		$('FIX_MM').style.display = 'inline';
		$('leftPartMonth').style.display = 'inline';
	}else if(value == '2' || value == '4') {
		$('leftPartTitle').style.display = 'inline';
		$('FIX_YY').style.display = 'inline';
		$('leftPartYear').style.display = 'inline';
		$('FIX_MM').style.display = 'inline';
		$('leftPartMonth').style.display = 'inline';
		$('plus').style.display = 'inline';
		$('rightPartTitle').style.display = 'inline';
		$('SPR_YY').style.display = 'inline';
		$('rightPartYear').style.display = 'inline';
		$('SPR_MM').style.display = 'inline';
		$('rightPartMonth').style.display = 'inline';
	}
}

function showOnlyReturnType() {
	<%--
		<span id="leftPartTitle">定期</span>

		<input type="text" name="FIX_YY" ID="FIX_YY" value ="" size="2" class="textBox2" onChange="calFIX_PERIOD()" datatype="number" pattern="#,###" >
		<span id="SHOW_FIX_YY"></span>

		<span id="leftPartYear">年</span>

		<input type="text" name="FIX_MM" ID="FIX_MM" value ="" size="2" class="textBox2" onChange="calFIX_PERIOD()" datatype="number" pattern="#,###">
		<span id="SHOW_FIX_MM"></span>

		<span id="leftPartMonth">月</span>
		
		<span id="plus">+</span>

		<span id="rightPartTitle">分期</span>
		<input type="text" name="SPR_YY" ID="SPR_YY" value ="" size="2" class="textBox2" onChange="calSPR_PERIOD()" datatype="number" pattern="#,###">
		<span id="SHOW_SPR_YY"></span>

		<span id="rightPartYear">年</span>

		<input type="text" name="SPR_MM" ID="SPR_MM" value ="" size="2" class="textBox2" onChange="calSPR_PERIOD()" datatype="number" pattern="#,###">
		<span id="SHOW_SPR_MM"></span>

		<span id="rightPartMonth">月</span>
		
<option value="1">分期</option>
<option value="3">定期</option>
<option value="2">定期+分期</option>
<option value="4">定期+分期+部分本金攤還(屆期還款)</option>
		
	--%>
	$('leftPartTitle').style.display = 'none';
	$('FIX_YY').style.display = 'none';
	$('SHOW_FIX_YY').style.display = 'none';
	$('leftPartYear').style.display = 'none';
	$('FIX_MM').style.display = 'none';
	$('SHOW_FIX_MM').style.display = 'none';
	$('leftPartMonth').style.display = 'none';
	$('plus').style.display = 'none';

	$('rightPartTitle').style.display = 'none';
	$('SPR_YY').style.display = 'none';
	$('SHOW_SPR_YY').style.display = 'none';
	$('rightPartYear').style.display = 'none';
	$('SPR_MM').style.display = 'none';
	$('SHOW_SPR_MM').style.display = 'none';
	$('rightPartMonth').style.display = 'none';
	
	var value = $('RETURN_TYPE').value
	if(value == '1') {
		$('rightPartTitle').style.display = 'inline';
		$('SHOW_SPR_YY').style.display = 'inline';
		$('rightPartYear').style.display = 'inline';
		$('SHOW_SPR_MM').style.display = 'inline';
		$('rightPartMonth').style.display = 'inline';
	}else if(value == '3') {
		$('leftPartTitle').style.display = 'inline';
		$('SHOW_FIX_YY').style.display = 'inline';
		$('leftPartYear').style.display = 'inline';
		$('SHOW_FIX_MM').style.display = 'inline';
		$('leftPartMonth').style.display = 'inline';
	}else if(value == '2' || value == '4') {
		$('leftPartTitle').style.display = 'inline';
		$('SHOW_FIX_YY').style.display = 'inline';
		$('leftPartYear').style.display = 'inline';
		$('SHOW_FIX_MM').style.display = 'inline';
		$('leftPartMonth').style.display = 'inline';
		$('plus').style.display = 'inline';
		$('rightPartTitle').style.display = 'inline';
		$('SHOW_SPR_YY').style.display = 'inline';
		$('rightPartYear').style.display = 'inline';
		$('SHOW_SPR_MM').style.display = 'inline';
		$('rightPartMonth').style.display = 'inline';
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
	當不是數值時，設定錯誤
--%>
function validateNotANumber(columnName,message) {
	if(isNotEmpty($(columnName).value) && isNaN($(columnName).value.replace(/,/g,''))) {
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
    檢核下拉選單是否有異動
--%>
function checkSelectValue(){
                 
    if( $F('LOAN_KIND') != $F('ORI_LOAN_KIND') ||  
        $F('PREFER_TYPE') != $F('ORI_PREFER_TYPE') ||
        $F('LOAN_KIND_M') != $F('ORI_LOAN_KIND_M') ||
        $F('PREFER_TYPE_M') != $F('ORI_PREFER_TYPE_M') ){  
                                        
        return false;   
    }else{
       return true;
    }
}

<%--[20221226]本金彈性還連動--%>
function chgIS_FLEX(){
	var IS_FLEX = $$('input[name=IS_FLEX]:checked')[0].value;
	var isDisabled = IS_FLEX == 'N';
	$$('td[name=FLEX_INFO]').each(function(td){
		td.select('input').each(function(ele){
			if(isDisabled){
				if(ele.type == 'radio'){
					ele.checked = false;
				}
				ele.setValue('');
			}
			ele.disabled = isDisabled;
		});
	});
}
<%--[20221226]一般擬准金額連動--%>
function chgAGREE_AMT(){
	new Ajax.Request("<%=dispatcher%>/DSA2_1100/chgAGREE_AMT",{
		parameters:{'AGREE_AMT': $F('AGREE_AMT')},
		onSuccess:function(response){
			var resp=response.responseJSON
			if(CSRUtil.isSuccess(resp)){
				var rtnMap = resp.rtnMap;
				$('FLEX_MIN').update(CSRUtil.$fmt(rtnMap.FLEX_MIN, "#,###"));
				$('FLEX_MAX').update(CSRUtil.$fmt(rtnMap.FLEX_MAX, "#,###"));
			}
		}
	});	
}
<%--[20221226]檢核本金彈性還--%>
function validFLEX(){
	var IS_FLEX;
	if($$('input[name=IS_FLEX]:checked')[0] != null){
		IS_FLEX = $$('input[name=IS_FLEX]:checked')[0].value;
	}

	if(IS_FLEX == 'Y'){
		if($$('input[name=AGREE_FLEX_TYPE]:checked').length == 0){
			setFalseCheck('AGREE_FLEX_TYPE_1', '請選擇[本金彈性還類型]!');
		}else if($$('input[name=AGREE_FLEX_TYPE]:checked')[0].value == '2'){
			if($F('AGREE_FLEX_AMT').blank()){
				setFalseCheck('AGREE_FLEX_AMT', '請輸入[本金彈性金額]!');  
			}else{
				var AGREE_FLEX_AMT = parseInt($F('AGREE_FLEX_AMT'), 10);
				var FLEX_MIN = parseInt($('FLEX_MIN').innerHTML.gsub(',',''), 10);
				var FLEX_MAX = parseInt($('FLEX_MAX').innerHTML.gsub(',',''), 10);
				if(AGREE_FLEX_AMT < FLEX_MIN || AGREE_FLEX_AMT > FLEX_MAX){
					setFalseCheck('AGREE_FLEX_AMT', '[約定金額]需於上下限金額內!!');  
				}
				if(AGREE_FLEX_AMT % 1000 != 0){
					setFalseCheck('AGREE_FLEX_AMT', '[約定金額]需以仟元為單位!');  
				}
			}
		}
		if($F('FLEX_PERIOD_B').blank()){
			setFalseCheck('FLEX_PERIOD_B', '請輸入[本金彈性還期間_起期]!');
		}
		if($F('FLEX_PERIOD_E').blank()){
			setFalseCheck('FLEX_PERIOD_E', '請輸入[本金彈性還期間_迄期]!');
		}
	}
}

//-->
</script>
</head>
<body>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<input type="hidden" name="oldAPPLY_ID" id="oldAPPLY_ID" value="">
		<input type="hidden" name="BORROW_ID" id="BORROW_ID" value="">
		<input type="hidden" name="APPLY_PROCESS_NM" id="APPLY_PROCESS_NM" value="">
		<input type="hidden" name="AGREE_PROCESS_NM" id="AGREE_PROCESS_NM" value="">
		
		<input type="hidden" name="FIX_PERIOD" id="FIX_PERIOD" value="">
		<input type="hidden" name="SPR_PERIOD" id="SPR_PERIOD" value="">
		<tr>
			<td class="tbYellow" width="12%">
				受理編號
			</td>
			<td class="tbYellow2">
				<input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2" size="15" maxlength="11" value="">
				<input id="btn_query" name="btn_query" type="button" class="button" value="查詢" onclick="doQuery()">
			</td>
		</tr>
	</table>
	
	<div class="buttons">
		<center>
			<input id="btn_modify" name="btn_modify" type="button" value="修正" onclick="doModify()">
			<input id="btn_delete" name="btn_delete" type="button" value="刪除" onclick="doRemove()">
			<input id="btn_section_approve" name="btn_section_approve" type="button" value="組長同意" onclick="doConfirm()">
			<input id="btn_reject" name="btn_reject" type="button" value="主管退回" onclick="doCancelConfirm()">
			<input id="btn_department_approve" name="btn_department_approve" type="button" value="主管同意" onclick="doApprove()">
			<input id="btn_cal" name="btn_cal" type="button" value="試算" onclick="doCorrectInt()">
			<input id="btn_cancel" name="btn_cancel" type="button" value="取消核貸" onclick="doCancelLoanAgree()">
			<input id="btn_clear" name="btn_clear" type="button" value="清除" onclick="doClear()">
		</center>
	</div>
	
	<div>
		<table id="grid" class="grid" width="100%"></table>
		<table width="100%" border=0 cellSpacing=1 cellPadding=0 >
			<tr class="tbBox2">
		        <td width="12%" class="tbBlue">受理編號</td>
		        <td width="13%" class="tbBlue2"><span id="SHOW_oldAPPLY_ID" ></span></td>
		        <td width="12%" class="tbBlue">借款人ID</td>
		        <%--[20240729] 修改件 陳勁谷 難字修改 --%>
		        <td width="13%" class="tbBlue2"><span id="SHOW_BORROW_ID" style="font-family:'EUDC'" ></span></td>
		        <td width="12%" class="tbBlue">受理進度</td>
		        <td width="13%" class="tbBlue2"><span id="SHOW_APPLY_PROCESS_NM" ></span></td>
		        <td width="12%" class="tbBlue">變更進度</td>
		        <td width="13%" class="tbBlue2"><span id="SHOW_AGREE_PROCESS_NM" ></span></td>
			</tr>
		</table>
	</div>
							
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" >
				房貸類型
			</td>
			<td class="tbYellow2">
				<span id="SPAN_LOAN">
					<input type="checkbox" name="LOAN_C" id="LOAN_C" value="0" />一般型
					<input type="checkbox" name="LOAN_M" id="LOAN_M" value="1" />理財型
				</span>
				<span id="SHOW_LOAN"></span>
			</td>
			<td class="tbYellow" >
				一般型表定利率
			</td>
			<td class="tbYellow2" >
				<input type="HIDDEN" name="INTEREST_C" ID="INTEREST_C" value ="" class="textBox2" size='6' maxlength='6' datatype="number" pattern="#,###.####">
				<span id="SHOW_INTEREST_C"></span>
			</td>
			<td class="tbYellow" >
				理財型表定利率
			</td>
			<td class="tbYellow2" >
				<input type="HIDDEN" name="INTEREST_C_M" ID="INTEREST_C_M" value ="" class="textBox2" size='6' maxlength='6' datatype="number" pattern="#,###.####">
				<span id="SHOW_INTEREST_C_M"></span>
			</td>
		</tr>

		<tr>
			<td class="tbYellow" width="15%">
				一般房貸類型:
			</td>
			<td class="tbYellow2"  >
				<span id="SHOW_LOAN_KIND" ></span>
				<select name="LOAN_KIND" id="LOAN_KIND" class="textBox2">
					<option value=""></option>
					<c:forEach var="costRpt" items="${LOAN_KIND_LIST}">
						<option value="${costRpt.key}">${costRpt.value}</option>
					</c:forEach>
				</select>
				<input type="hidden" name="ORI_LOAN_KIND" id="ORI_LOAN_KIND" value="">
			</td>
			<td class="tbYellow" width="13%">
				一般申請金額
			</td>
			<td class="tbYellow2" width="10%">
				<input type="text" name="LOAN_AMT" ID="LOAN_AMT" value ="" class="textBox2" datatype="number" pattern="#,###" size=10 maxlength=7>
				<span id="SHOW_LOAN_AMT"></span>萬元
			</td>
			<td class="tbYellow" width="18%">
				一般型擬准利率
			</td>
			<td class="tbYellow2" width="12%">
				<input type="text" name="INTEREST" ID="INTEREST" value ="" class="textBox2" size='7' maxlength='7' datatype="number" pattern="#,###.####">
				<span id="SHOW_INTEREST"></span>%
			</td>
		</tr>
		<tr>
			<td class="tbYellow" >
				一般優惠種類:
			</td>
			<td class="tbYellow2"  >
				<span id="SHOW_PREFER_TYPE" ></span>
				<select name="PREFER_TYPE" id="PREFER_TYPE" class="textBox2">
					<option value=""></option>
					<c:forEach var="costRpt" items="${PREFER_TYPE_LIST}">
						<option value="${costRpt.key}">${costRpt.value}</option>
					</c:forEach>
				</select>
				<input type="hidden" name="ORI_PREFER_TYPE" id="ORI_PREFER_TYPE" value="">
				<font color="FF8888">
					<bold>
						<span id="INSU_PRANK_1_NM" ></span>
					</bold>
				</font>								
			</td>
			<td class="tbYellow" >
				一般擬准金額
			</td>
			<td class="tbYellow2" >
				<input type="text" name="AGREE_AMT" ID="AGREE_AMT" value ="" class="textBox2" datatype="number" pattern="#,###" size=10 maxlength=7 onchange="chgAGREE_AMT()">
				<span id="SHOW_AGREE_AMT"></span>萬元
			</td>
			<td class="tbYellow" >
				理財型擬准利率
			</td>
			<td class="tbYellow2" >
				<input type="text" name="INTEREST_M" ID="INTEREST_M" value ="" class="textBox2" size='7' maxlength='7' datatype="number" pattern="#,###.####">
				<span id="SHOW_INTEREST_M"></span>%
			</td>
		</tr>
		
		<tr>
			<td class="tbYellow" >
				理財貸款種類:
			</td>
			<td class="tbYellow2"  >
				<span id="SHOW_LOAN_KIND_M" ></span>
				<select name="LOAN_KIND_M" id="LOAN_KIND_M" class="textBox2">
					<option value=""></option>
					<c:forEach var="costRpt" items="${LOAN_KIND_M_LIST}">
						<option value="${costRpt.key}">${costRpt.value}</option>
					</c:forEach>
				</select>
				<input type="hidden" name="ORI_LOAN_KIND_M" id="ORI_LOAN_KIND_M" value="">
				<span id="SHOW_LOAN_KIND_M" ></span>
			</td>
			<td class="tbYellow" >
				理財申請金額
			</td>
			<td class="tbYellow2" >
				<input type="text" name="LOAN_AMT_M" ID="LOAN_AMT_M" value ="" class="textBox2" datatype="number" pattern="#,###" size=10 maxlength=7>
				<span id="SHOW_LOAN_AMT_M"></span>萬元
			</td>
			<td class="tbYellow" >
			</td>
			<td class="tbYellow2" >
			</td>
		</tr>
		
		<tr>
			<td class="tbYellow" >
				理財優惠種類:
			</td>
			<td class="tbYellow2"  >
				<span id="SHOW_PREFER_TYPE_M" ></span>
				<select name="PROD_ID" id="PROD_ID" class="textBox2" disabled>
					<option value=""></option>
					<c:forEach var="costRpt" items="${PREFER_TYPE_M_LIST}">
						<option value="${costRpt.PROD_ID}">${costRpt.PROD_NAME}</option>	
						<!--<option value="${costRpt.key}">${costRpt.value}</option>-->
					</c:forEach>
				</select>
				<input type="hidden" name="PREFER_TYPE_M" id="PREFER_TYPE_M" value="">				
				<input type="hidden" name="ORI_PREFER_TYPE_M" id="ORI_PREFER_TYPE_M" value="">
			</td>
			<td class="tbYellow" >
				理財擬准金額
			</td>
			<td class="tbYellow2" >
				<input type="text" name="AGREE_AMT_M" ID="AGREE_AMT_M" value ="" class="textBox2" datatype="number" pattern="#,###" size=10 maxlength=7>
				<span id="SHOW_AGREE_AMT_M"></span>萬元
			</td>
			<td class="tbYellow" >
			</td>
			<td class="tbYellow2" >
			</td>
		</tr>
		<tr>
			<td class="tbYellow" >
				電話(日):
			</td>
			<td class="tbYellow2"  >
				<span id="SHOW_DAY_TEL_AREA"></span>
				<select name="DAY_TEL_AREA" id="DAY_TEL_AREA" class="textBox2">
					<option value="">(區碼)</option>
					<c:forEach var="costRpt" items="${TEL_AREA_LIST}">
						<option value="${costRpt.value}">${costRpt.key}</option>
					</c:forEach>
				</select>
				-
				<input type="text" name="DAY_TEL_NUM" ID="DAY_TEL_NUM" value ="" size="11" maxlength="10" class="textBox2">
				<span id="SHOW_DAY_TEL_NUM"></span>
				#
				<input type="text" name="DAY_TEL_EXT" ID="DAY_TEL_EXT" value ="" size="6" maxlength="6" class="textBox2">
				<span id="SHOW_DAY_TEL_EXT"></span>
			</td>
			<td class="tbYellow" >
				設定金額
			</td>
			<td class="tbYellow2" >
				<input type="text" name="SET_AMT" ID="SET_AMT" value ="" class="textBox2" datatype="number" pattern="#,###" size="14" maxlength="14">
				<span id="SHOW_SET_AMT"></span>
				元
			</td>
			<td class="tbYellow" >
				買契價格
			</td>
			<td class="tbYellow2" >
				<input type="text" name="CRED_TRADE_AMT" ID="CRED_TRADE_AMT" value ="" class="textBox2" datatype="number" pattern="#,###.#" size="11" maxlength="11">
				<span id="SHOW_CRED_TRADE_AMT"></span>
				萬元
			</td>
		</tr>
		<tr>
			<td class="tbYellow" >
				電話(夜):
			</td>
			<td class="tbYellow2"  >
				<span id="SHOW_NIGHT_TEL_AREA"></span>
				<select name="NIGHT_TEL_AREA" id="NIGHT_TEL_AREA" class="textBox2">
					<option value="">(區碼)</option>
					<c:forEach var="costRpt" items="${TEL_AREA_LIST}">
						<option value="${costRpt.value}">${costRpt.key}</option>
					</c:forEach>
				</select>
				-
				<input type="text" name="NIGHT_TEL_NUM" ID="NIGHT_TEL_NUM" value ="" size="11" maxlength="10" class="textBox2">
				<span id="SHOW_NIGHT_TEL_NUM"></span>
				#
				<input type="text" name="NIGHT_TEL_EXT" ID="NIGHT_TEL_EXT" value ="" size="6" maxlength="6" class="textBox2">
				<span id="SHOW_NIGHT_TEL_EXT"></span>
			</td>
			<td class="tbYellow" >
				代償金額
			</td>
			<td class="tbYellow2" >
				<input type="text" name="COMP_AMT" ID="COMP_AMT" value ="" class="textBox2" datatype="number" pattern="#,###" size=14 maxlength="15">
				<span id="SHOW_COMP_AMT"></span>
				元
			</td>
			<td class="tbYellow" >
			</td>
			<td class="tbYellow2" >
			</td>
		</tr>
		
		<tr>
			<td class="tbYellow" >
				行動電話:
			</td>
			<td class="tbYellow2"  >
				<input type="text" name="MOBILE" ID="MOBILE" value ="" size="15" maxlength="15" class="textBox2">
				<span id="SHOW_MOBILE"></span>
			</td>
			<td class="tbYellow" >
				火險年期
			</td>
			<td class="tbYellow2" >
				<input type="text" name="FIREINSU_YY" ID="FIREINSU_YY" value ="" class="textBox2" datatype="number" pattern="#,###" size=2>
				<span id="SHOW_FIREINSU_YY"></span>
				年
				<input type="text" name="FIREINSU_MM" ID="FIREINSU_MM" value ="" class="textBox2" datatype="number" pattern="#,###" size=2>
				<span id="SHOW_FIREINSU_MM"></span>
				月
			</td>
			<td class="tbYellow" >
			</td>
			<td class="tbYellow2" >
			</td>
		</tr>
		<tr>
			<td class="tbYellow" >
				是否贈送火險:
			</td>
			<td class="tbYellow2"  >
				<span id="SPAN_INSUFREE_CODE">
					<input type="radio" name="INSUFREE_CODE" value="1"/>是
					<input type="radio" name="INSUFREE_CODE" value="0"/>否
				</span>
				<span id="SHOW_INSUFREE_CODE"></span>
			</td>
			<td class="tbYellow" >
				火險保額
			</td>
			<td class="tbYellow2" >
				<input type="text" name="FIREINSU_AMT" ID="FIREINSU_AMT" value ="" class="textBox2" datatype="number" pattern="#,###" size=5>
				<span id="SHOW_FIREINSU_AMT"></span>
				萬元
			</td>
			<td class="tbYellow" >
			A值
			</td>
			<td class="tbYellow2" >
				<span id="SHOW_A_VALUE"></span>
				<select name="A_VALUE" id='A_VALUE' class="textBox2">
					<option value=""></option>
					<c:forEach var="costRpt" items="${A_VALUE_LIST}">
						<option value="${costRpt.value}">${costRpt.key}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" >
				還款方式:
			</td>
			<td class="tbYellow2" colspan='3'>
				<span id="SHOW_RETURN_TYPE"></span>
				<select name="RETURN_TYPE" id="RETURN_TYPE" class="textBox2" onChange="changeReturnType()">
					<option value=""></option>
					<c:forEach var="costRpt" items="${RETURN_TYPE_LIST}">
						<option value="${costRpt.value}">${costRpt.key}</option>
					</c:forEach>
				</select><span id="leftPartTitle">定期</span><input type="text" name="FIX_YY" ID="FIX_YY" value ="" size="2" class="textBox2" onblur="calFIX_PERIOD()" datatype="number" pattern="#,###" ><span id="SHOW_FIX_YY"></span><span id="leftPartYear">年</span><input type="text" name="FIX_MM" ID="FIX_MM" value ="" size="2" class="textBox2" onblur="calFIX_PERIOD()" datatype="number" pattern="#,###"><span id="SHOW_FIX_MM"></span><span id="leftPartMonth">月</span><span id="plus">+</span>
				<span id="rightPartTitle">分期</span><input type="text" name="SPR_YY" ID="SPR_YY" value ="" size="2" class="textBox2" onblur="calSPR_PERIOD()" datatype="number" pattern="#,###"><span id="SHOW_SPR_YY"></span><span id="rightPartYear">年</span><input type="text" name="SPR_MM" ID="SPR_MM" value ="" size="2" class="textBox2" onblur="calSPR_PERIOD()" datatype="number" pattern="#,###"><span id="SHOW_SPR_MM"></span><span id="rightPartMonth">月</span>
			</td>
			<td class="tbYellow" >
				<span id="SHOW_BASE_AMT_LABEL" style="display:none">換算業績(元):</span>
			</td>
			<td class="tbYellow2">										
				<span id="SHOW_BASE_AMT" style="display:none"></span>										
			</td>							
		</tr>
		<%--[20221226]增-本金彈性還/每月約定還本擬准類型--%>
		<tr>
			<td class="tbYellow" >本金彈性還:</td>
			<td class="tbYellow2">
				<input type="radio" name="IS_FLEX" id="IS_FLEX_Y" value="Y" onclick="chgIS_FLEX()"/>是
				<input type="radio" name="IS_FLEX" id="IS_FLEX_N" value="N" onclick="chgIS_FLEX()"/>否
			</td>
			<td class="tbYellow" >本金彈性還期間:</td>
			<td class="tbYellow2" colspan="3" name="FLEX_INFO">
				第<input type="text" name="FLEX_PERIOD_B" ID="FLEX_PERIOD_B" value ="" size="3" class="textBox2" datatype="number" pattern="#,###" >~
				<input type="text" name="FLEX_PERIOD_E" ID="FLEX_PERIOD_E" value ="" size="3" class="textBox2" datatype="number" pattern="#,###">期
			</td>
		</tr>		
		<tr>
			<td class="tbYellow" >
				每月約定還本擬准金額:
			</td>
			<td class="tbYellow2" colspan='5' name="FLEX_INFO">
				<input type="radio" name="AGREE_FLEX_TYPE" id="AGREE_FLEX_TYPE_0" value="0"/>下限金額
				<span id='FLEX_MIN'></span>
				<input type="radio" name="AGREE_FLEX_TYPE" id="AGREE_FLEX_TYPE_2" value="2"/>自行約定金額
				<input type="text" name="AGREE_FLEX_AMT" ID="AGREE_FLEX_AMT" value ="" class="textBox2" datatype="number" pattern="#,###">
				<input type="radio" name="AGREE_FLEX_TYPE" id="AGREE_FLEX_TYPE_1" value="1"/>上限金額
				<span id='FLEX_MAX'></span>
			</td>
		</tr>	
		<tr>
			<td class="tbYellow" >
				一般優質客戶等級:
			</td>
			<td class="tbYellow2">
				<span id="SHOW_VIP_GRADE"/></span>
				<select name="VIP_GRADE" id="VIP_GRADE" class="textBox2">
					<option value=""></option>
					<c:forEach var="costRpt" items="${VIP_GRADE_LIST}">
						<option value="${costRpt.value}">${costRpt.key}</option>
					</c:forEach>
				</select>
			</td>
			
			<td class="tbYellow" >
				理財型優質客戶等級:
			</td>
			<td class="tbYellow2">										
				<span id="SHOW_VIP_GRADE_M"/></span>
				<select name="VIP_GRADE_M" id="VIP_GRADE_M" class="textBox2">
					<option value=""></option>
					<c:forEach var="costRpt" items="${VIP_GRADE_M_LIST}">
						<option value="${costRpt.value}">${costRpt.key}</option>
					</c:forEach>
				</select>										
			</td>		
										
			<td class="tbYellow" >
			是否檢附相關證明:
			</td>
			<td class="tbYellow2" >
				<span id="SPAN_CHECK_PAPER">
					<input type="radio" name="CHECK_PAPER" value="true"/>是
					<input type="radio" name="CHECK_PAPER" value="false"/>否
				</span>
				<span name="SHOW_CHECK_PAPER" id="SHOW_CHECK_PAPER"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" >
				客戶類別:
			</td>
			<td class="tbYellow2" >
				<span id="SHOW_VIP_CUSTOMER"></span>
				<select name="VIP_CUSTOMER" id="VIP_CUSTOMER" class="textBox2">
					<option value=""></option>
					<c:forEach var="costRpt" items="${VIP_CUSTOMER_LIST}">
						<option value="${costRpt.value}">${costRpt.key}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" >
				地段類別:
			</td>
			<td class="tbYellow2" >
				<span id="SHOW_VIP_AREA"></span>
				<select name="VIP_AREA" id="VIP_AREA" class="textBox2">
					<option value=""></option>
					<c:forEach var="costRpt" items="${VIP_AREA_LIST}">
						<option value="${costRpt.value}">${costRpt.key}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" >
			是否首月免息:
			</td>
			<td class="tbYellow2" >
				<span id="SPAN_REMISSION_INT">
					<input type="radio" name="REMISSION_INT" value="1"/>是
					<input type="radio" name="REMISSION_INT" value="0"/>否
				</span>
				<span id="SHOW_REMISSION_INT"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				收息地址:
			</td>
			<td colspan="5" class="tbYellow2">
				<span id="SPAN_CON_CODE">
					<input type="radio" name="CON_CODE" value="1" onclick="changeAddressStatus()"/>同擔保品地址
					<input type="radio" name="CON_CODE" value="2" onclick="changeAddressStatus()"/>其他如下
				</span>
				<span id="SHOW_CON_CODE"></span>
				<br>
				<span id="DSA21100_MODIFY">
					<span id="DSA21100"></span>
				</span>
				<span id="DSA21100_TEXT">
					<span id="SHOW_DSA21100"></span>
				</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" >
				修改原因:
			</td>
			<td class="tbYellow2"  colspan="5">
				<textarea name="CORRECT_NOTE" id="CORRECT_NOTE" rows="2" cols="50">
				</textarea>
				<span id="SHOW_CORRECT_NOTE" ></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" >
				修改記錄:
			</td>
			<td class="tbYellow2"  colspan="5">
				<span id="SHOW_CORRECT_LOG" ></span>
			</td>
		</tr>
	</table>
</body>
</html>