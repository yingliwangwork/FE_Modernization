<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSD30200.jsp
作者：張智翔
功能：防止清償通報查詢。
完成：2013-09-27

[20180420] 問題單:20180412084954
           防止清償通報查詢功能呼叫DSD3_0200.doQuery時會逐筆呼叫DS_Z90100().calRateValue計算利息資料，
           若筆數太多時，會造成查詢時間太久，因此將查詢分頁由假分頁改為真分頁，每次查詢限制為10筆資料(分頁一頁5筆)
           
[20200504] 修改件 申請書：200331003369
	1.新增建議利率欄位、刪除客戶等級欄位
	2.核定層級增加選項(副總經理(一)、副總經理(二))
	3.調整核定層級檢核規則
	4.新增附件上傳功能
	5.查詢時單位欄位會預設科別，調整科別要連動承辦人員

210208申請書-簽件作業、核貸案件修正及防止清償通報查詢利率下限卡控  BY余凱鈞
防止清償通報查詢DSD30200，新增利率限制的欄位，符合利率下限的案件顯示利率下限提醒，非利率下限的案件顯示”無”

[20240326]
難字調整
高強禾
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<%-- 匯入外部Javascript 與 css --%>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script language="JavaScript"  src="${htmlBase}/CM/js/ui/popupWin.js"></script> <%-- 超連結用 --%>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script><%-- 日曆用 --%>
<script type="text/JavaScript" src="${htmlBase}/CM/js/date.js"></script><%-- 日期用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script><%-- 檢核用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/InputUtility.js'></script>
<%-- [20240326] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type='text/javascript'>

// 產生畫面物件
var DSD30200 = new DSD30200();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSD30200.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD30200(){	

	var grid;
	var grid_E;<%-- [20200504] 附件上傳區 --%>
	var is_query = false;
	var today = toROC('${today}');
	var today_2month = toROC('${today_2month}');
	var lastCondition = {};
	var checkedValue = '';
	var PROC_ID2_Map = {};	//承辦人員
	
	//檢核
	var valid1;		
	var valid2;	
	
	var rtnMap = {};
	var AUTH = '${AUTH}';
	var DEPT_CKECK = '${DEPT_CKECK}';
	var ACTION_TYPE = "1";	
	
	//按紐權限
	function buttonAuth(){
		var authButtons = {
			B0068:"btn_reject",<%--退件--%>
			B0070:"btn_confirm",<%--審核--%> 
			B0071:"btn_cancelconfirm",<%--取消審核--%>
			B0083:"btn_link",<%--聯徵記錄--%>
			B0219:"btn_autodeal",<%--五年個調附約--%> 
			//B0220:"btn_yeardeal",<%--一年個調附約--%>
			B0243:"btn_print1"<%--批覆書--%>
		};
		
		<dz:grantButtons FUNC_ID="DSD30200" ignored="false"/>
	}
	
	//畫面檢核
	function initValidation(){		
		//查詢用檢核			
		valid1 = new Validation("form", {useTitles:true,focusOnError:false,immediate:false});
		valid2 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
		Validation.addAllThese([
			[ 'checkChooseCondition',  '請輸入任一項查詢條件!', 
				function(v){		
					var is_value = false;
					
					$$('#QUERY_C_1 input[type = "text"]' , '#QUERY_C_1 select').each(
						function(elem){							
							if(elem.value){
								is_value = true;							
							}										
						}	
					);
					return is_value;
				}
			],
			[ 'checkNeedDiv',  '單位查詢請選擇單位別及輸入單位代號!!', 
				function(v){		
					if(($('QUERY_TYPE').value == '1' || $('QUERY_TYPE').value == '2' ||$('QUERY_TYPE').value == '3' )&& !$('DIV_NO').value ){
						return false;					
					}
					return true;
				}
			],
			[ 'checkWithoutDiv',  '資管科查詢不需輸入單位代號!!', 
				function(v){
					var QUERY_TYPE = $('QUERY_TYPE').value;
					if((QUERY_TYPE == '4' || QUERY_TYPE == '5' || QUERY_TYPE == '6' || QUERY_TYPE == '7' || QUERY_TYPE == '8')&& $('DIV_NO').value){
						return false;					
					}
					return true;
				}
			],
			[ 'checkAUTH',  '請輸入查詢輸入日以加快查詢速度!', 
				function(){			
					var K_BEGIN_DATE  = $('K_BEGIN_DATE').value;
					var K_END_DATE	= $('K_END_DATE').value;
					var tempPROCESS_STATUS	= $('PROCESS_STATUS').value;
					if(!$('LOAN_ID_Q').value){
						if(K_BEGIN_DATE && K_END_DATE){
							return true;
						}else{
							if( tempPROCESS_STATUS=='2A'|| tempPROCESS_STATUS=='2B'|| tempPROCESS_STATUS=='21' || tempPROCESS_STATUS=='22' 
							|| tempPROCESS_STATUS=='30'  || tempPROCESS_STATUS=='31'  || tempPROCESS_STATUS=='41' ){
								return false;
							}
						}
					}
					return true;
				}
			],
			[ 'checkLOAN_ID1',  '貸款帳號未輸入，輸入日不可為空，且區間不可超過2個月!', 
				function(){			
					var K_BEGIN_DATE  = $('K_BEGIN_DATE').value;
					var K_END_DATE	= $('K_END_DATE').value;
					var tempPROCESS_STATUS	= $('PROCESS_STATUS').value;
					if(!$('LOAN_ID_Q').value){
						if(K_BEGIN_DATE && K_END_DATE){
							if(diffDay(K_BEGIN_DATE,K_END_DATE) > 62) {
								return false;
							}
							return true;
						}else{
							return false;
						}
					}
					return true;
				}
			],
			[ 'checkLOAN_ID2',  '貸款帳號未輸入，單位、處理狀態、附約進度必須選擇其中一項!', 
				function(){				
					var QUERY_TYPE = $('QUERY_TYPE').value;
					var PROCESS_STATUS = $('PROCESS_STATUS').value;	
					var ADJ_STATUS = $('ADJ_STATUS').value;
					if(!$('LOAN_ID_Q').value){				
						if(!QUERY_TYPE && !PROCESS_STATUS && !ADJ_STATUS){
							return false;
						}
					}
					return true;
				}
			],
			[ 'checkSUG_INPUTS', '建議利率為空或非數值',  
				//必須輸入且為數值
				function(v,elem){
					return !Validation.get('IsEmpty').test(v) && /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(v);
				}
			],
			[ 'checkFINAL1_INPUTS', '',  
				function(v,elem){
					if ($('PROCESS_STATUS_V').value != '10' && $('PROCESS_STATUS_V').value != '11') {
						return !Validation.get('IsEmpty').test(v) && /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(v);	
					}
					return true;
				}
			],
			//[ 'checkFINAL_REDUCE', '',  
				//不可為0
			//	function(v,elem){						
			//		if ($('PROCESS_STATUS_V').value != '10' && $('PROCESS_STATUS_V').value != '11') {
			//			var FINAL_REDUCE = $('FINAL_REDUCE').value;
			//			if(!Validation.get('IsEmpty').test(v) && /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(v)){
			//				return true;	
			//			}
			//		}
			//		return true;
			//	}
			//],
			[ 'checkFINAL_PERIOD', '',  
				//1-60之間正整數
				function(v,elem){
					if ($('PROCESS_STATUS_V').value != '10' && $('PROCESS_STATUS_V').value != '11') {						
						var FINAL_PERIOD = $('FINAL_PERIOD').value;
						if(!Validation.get('IsEmpty').test(v) && /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(v)){
							return FINAL_PERIOD > 0 && FINAL_PERIOD < 61  ? true : false ;	
						}
					}
					return true;
				}
			],
			[ 'checkMoreThanZero', '須大於等於0',  
				//需>=0
				function(v,elem){
					return v >= 0;
				}
			],
			[ 'checkFileUploaded', '必須上傳附件',
				<%--[20200511]審核時附件為必輸--%>
				function(v, elem) {
					return grid_E.getAllRecords().length;
				}
			]
		]);
		valid1.define( "checkChooseCondition" , { id: "show"  } );	
		valid1.define( "checkNeedDiv" , { id: "DIV_NO"  } );
		valid1.define( "checkWithoutDiv" , { id: "DIV_NO"  } );	
		valid1.define( "checkAUTH" , { id: "K_BEGIN_DATE"  } );	
		valid1.define( "checkAUTH" , { id: "K_END_DATE"  } );
		valid1.define( "checkLOAN_ID1" , { id: "K_BEGIN_DATE"  } );	
		valid1.define( "checkLOAN_ID1" , { id: "K_END_DATE"  } );	
		valid1.define( "checkLOAN_ID2" , { id: "QUERY_TYPE"  } );	
		valid1.define( "checkLOAN_ID2" , { id: "PROCESS_STATUS"  } );
		valid2.define( "checkFINAL1_INPUTS" , { id: "FINAL_REDUCE" ,errMsg : '請輸入調降利率!'} );
		valid2.define( "checkFINAL1_INPUTS" , { id: "FINAL_PERIOD"  ,errMsg : '請輸入調降期間!' } );
		valid2.define( "checkFINAL1_INPUTS" , { id: "FINAL_RATE"   ,errMsg : '請輸入調降後保優利率!'} );
		//valid2.define( "checkFINAL_REDUCE" , { id: "FINAL_REDUCE"   ,errMsg : '不可為0!'} );
		valid2.define( "checkFINAL_PERIOD" , { id: "FINAL_PERIOD"   ,errMsg : '需在1~60期!'} );
		valid2.define( "checkMoreThanZero" , { id: "EXPENSE_AMT"   ,errMsg : ''} );
		<%-- [20200504] 新增:建議利率 --%>
 		valid2.define( "checkSUG_INPUTS" , { id: "SUG_RATE"} );
 		<%-- [20200504] 刪除 --%>
// 		valid2.define( "required" , { id: "VIP_GRADE"   ,errMsg : ''} );
		//valid2.define( "checkMoreThanZero" , { id: "FINAL_REDUCE"   ,errMsg : ''} );
		valid2.define( "checkMoreThanZero" , { id: "FINAL_PERIOD"   ,errMsg : ''} );
		valid2.define( "checkMoreThanZero" , { id: "FINAL_RATE"   ,errMsg : ''} );
		valid2.define( "validate-selection" , { id: "PROCESS_LEVEL"   } );
		valid2.define( "checkFileUploaded" , { id: "UploadFile"   } );<%--[20200511]審核時附件為必輸--%>
	}	
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD3_0200/" + actionName,
			{  
			parameters: params, 
			onSuccess:function(response){
				var resp = response.responseJSON
				if(CSRUtil.isSuccess(resp)){	
					if(successFunction){
						successFunction(resp);
					}
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			}			
		});
	}
	
	//修正檔案上傳因難字造成的問題
	function removeInputTypeFile(){
		var input = $('UploadFile');
		$('UploadFile').remove();
		parseEUDC('ap');
		$('import').insert(input);
	}
	
	var auxiliary = {
			createCoverPage:function(){
				cover = CSRUtil.createCoverPage('_frontCover');
				cover.show();
			},
			closeCoverPage: function(){
				cover.hide();
			}
		};
	
	//按鈕功能
	var buttons = {	
		//查詢
		doQuery : function(){	
		
			valid1.reset();
			valid2.reset();			
			if(!valid1.validate()){
				return;
			}	

			var query_reqMap = actions.getDate();
			lastCondition = query_reqMap;
			
			/* [20180420] 調整為真分頁 */
			var params = {
				'reqMap': Object.toJSON(query_reqMap), 				 
				'ACTION_TYPE' : ACTION_TYPE 				
			};
		
			grid.load('${dispatcher}/DSD3_0200/query', params );		
			actions.clearAll();	
		},
		<%-- [20200504] 上傳附件 --%>
        doUpload : function(){
			if(!$F('UploadFile')){
				alert('執行上傳前，請先選擇檔案');
				return;
			}
			<%--把檔案匯入--%>
			$('form1').action= '${dispatcher}/DSD3_0200/upload';
			$('form1').submit();
			auxiliary.createCoverPage();<%--開啟資料處理動畫--%>
        },
		
		//查詢明細
		doQueryDetail : function(rec){				
			
			var reqMap = {
				LOAN_ID : rec.LOAN_ID,
				SEQ_NO : rec.SEQ_NO,
				DEFAULT_STATUS : $F('DEFAULT_STATUS')
			};
				
			//發送ajax
			ajaxPost( 'queryDetail' , { reqMap : Object.toJSON(reqMap) },
				function(resp){	
					actions.showData(resp);
					
					is_query = true;
					if(rtnMap['CASE_TYPE'] == '2'){
						var alertMessage = "";
						if(rtnMap['LOAN_STATUS'] != '1' && parseInt(rtnMap['LOAN_STATUS']) < parseInt(10)){
							alertMessage = alertMessage + "請注意，本件為法務件，清償前請洽法務\n";
						}
						if(rtnMap['check2'] == '1'){
							alertMessage = alertMessage + "請注意，本件為假扣押件且繳息不正常\n";
						}
						if(rtnMap['check4'] == '1'){
							alertMessage = alertMessage + "請注意，本件為貸後特殊件控管案件\n";
						}
						if(alertMessage){
							alert(alertMessage);
						}
					}
				}				
			);				
		},
		doSave : function(){
			buttons.doConfirm('1');
		},		
		//isSave==1執行暫存；isSave!=1執行審核
		doConfirm : function(isSave){
						
			var dataMap = rtnMap;
			if(isSave == 1){
				//isSave==1執行暫存
				dataMap['isSave'] = '1';
			}else{
				dataMap['isSave'] = '0';
			}
			//if(grid.getCheckedRecord()[0]){
			//	dataMap = grid.getCheckedRecord()[0];
			//}else{
			//	alert('請選取一筆資料再進行審核!!!');
			//	return;	
			//}	
			/* [20180420] 調整為真分頁 */
			if(!is_query){			
			 	alert('請選取一筆資料再進行覆核!!!');
			 	return;	
			}
			
			valid1.reset();
			valid2.reset();
			
			if(isSave != 1){
				//isSave!=1審核，要檢核valid2
				if(!valid2.validate()){
					return;
				}	
			}
			
		
			//存取頁面資料
			$$('#form1 input[type = "text"]','#form1 input[type = "checkbox"]','#form1 textarea','#form1 select','#form1 input[type="hidden"]').each(
				function(dom){
					var tagName = dom.tagName;
					var id = dom.id;					
				
					if(tagName == 'INPUT'){
						var type = dom.type;
						if(type == 'checkbox'){	
							if(dom.checked){
								dataMap[id] = '1';								
							}else{
								dataMap[id] = '0';								
							}
							
						}else{
							dataMap[id] = dom.getValue() || '';														
						}
					}else if (tagName =='SELECT'||tagName =='TEXTAREA'){	
						dataMap[id] = dom.getValue() || '';													
					}				
				}
			);
			
			dataMap['DEFAULT_STATUS'] = $F('DEFAULT_STATUS');
			
			//發送ajax
			ajaxPost( 'confirm' , { dataMap : Object.toJSON(dataMap) , reqMap : Object.toJSON(lastCondition) },
				function(resp){	
					is_query = false;	
					actions.clearAll();  //清空table
					/* [20180420] 調整為真分頁 */					
					//grid.load(resp.rtnList || []);
					ACTION_TYPE = "2";
					buttons.doQuery();					
				}
			);
		},
		
		//取消覆核
		doCancelConfirm : function(){
			
			//var dataMap = {};;	
			//if(grid.getCheckedRecord()[0]){
			//	dataMap = grid.getCheckedRecord()[0];
			//}else{
			//	alert('請選取一筆資料再進行取消覆核!!!');
			//	return;	
			//}	
			/* [20180420] 調整為真分頁 */			
			if(!is_query){				
			 	alert('請選取一筆資料再進行取消覆核!!!');
			 	return;	
			}
			
			valid1.reset();
			valid2.reset();

			rtnMap['DEFAULT_STATUS'] = $F('DEFAULT_STATUS');
			
			//發送ajax
			ajaxPost( 'cancelconfirm' , { dataMap : Object.toJSON(rtnMap) , reqMap : Object.toJSON(lastCondition) },
				function(resp){	
					is_query = false;	
					actions.clearAll(); //清空table
					/* [20180420] 調整為真分頁 */					
					//grid.load(resp.rtnList || []);
					ACTION_TYPE = "2";
					buttons.doQuery();					
				}
			);
		},
		
		//個調附約 //2017-09-04申請書-利率調整作業 「一年個調附約」及「五年個調附約」按鈕合併為「個調附約」按鈕，連結新版利率調整附約
		doAutodeal : function(){
			
			//var dataMap = {};	
			//if(grid.getCheckedRecord()[0]){
			//	dataMap = grid.getCheckedRecord()[0];
			//}else {
			//	alert('請先查詢並選取資料再進行列印個調附約!');
			//	return;		
			//}
			/* [20180420] 調整為真分頁 */
			if(!is_query){				
			 	alert('請先查詢並選取資料再進行列印個調附約');
			 	return;	
			}			
			valid1.reset();
			valid2.reset();
		
			//發送ajax
			ajaxPost( 'printAuto' , { dataMap : Object.toJSON(rtnMap)},
				function(resp){							
					RPTUtil.executePrintByResponse(resp, true);	
					is_query = false;
				}
			);		
		
		},
		
		//一年個調附約 
		doYearDeal : function(){
			
			//var dataMap = {};	
			//if(grid.getCheckedRecord()[0]){
			//	dataMap = grid.getCheckedRecord()[0];
			//}else{
			//	alert('請先查詢並選取資料再進行列印一年個調附約!');
			//	return;	
			//}
			/* [20180420] 調整為真分頁 */
			if(!is_query){				
			 	alert('請先查詢並選取資料再進行列印一年個調附約!');
			 	return;	
			}
			
			valid1.reset();
			valid2.reset();
			
			//發送ajax
			ajaxPost( 'printYear' , { dataMap : Object.toJSON(rtnMap)},
				function(resp){							
					RPTUtil.executePrintByResponse(resp, true);	
					is_query = false;
				}
			);	
		},
		doPrint1 :function(){		
				
			valid1.reset();
			valid2.reset();
			if(!valid1.validate()){
				return;
			}
			var LOAN_ID = $('LOAN_ID_SPAN').innerHTML;
			if(!LOAN_ID){
				alert('請先查詢再進行列印!');
				return;		
			}
			
			//發送ajax
			ajaxPost( 'print1' , { LOAN_ID : LOAN_ID},
				function(resp){							
					RPTUtil.executePrintByResponse(resp, true);	
				}
			);	
		
		},		
		//退件
		doReject :function(){
		
			var dataMap = rtnMap;	
			//if(grid.getCheckedRecord()[0]){
			//	dataMap = grid.getCheckedRecord()[0];
			//}else{
			//	alert('請點選下方資料再進行退件!');
			//	return;			
			//}
			/* [20180420] 調整為真分頁 */
			if(!is_query){				
			 	alert('請點選下方資料再進行退件!');
			 	return;	
			}
			
			valid1.reset();
			
			//存取頁面資料
			$$('#form1 input[type = "text"]','#form1 input[type = "checkbox"]','#form1 textarea','#form1 select').each(
				function(dom){
					var tagName = dom.tagName;
					var id = dom.id;					
				
					if(tagName == 'INPUT'){
						var type = dom.type;
						if(type == 'checkbox'){	
							if(dom.checked){
								dataMap[id] = '1';								
							}else{
								dataMap[id] = '0';								
							}
							
						}else{
							dataMap[id] = dom.getValue() || '';
						}
					}else if (tagName =='SELECT'||tagName =='TEXTAREA'){	
						dataMap[id] = dom.getValue() || '';						
					}				
				}
			);
			
			//發送ajax
			ajaxPost( 'reject' , { dataMap : Object.toJSON(dataMap), reqMap : Object.toJSON(lastCondition) },
				function(resp){	
					is_query = false;
					actions.clearAll(); //清空table
					/* [20180420] 調整為真分頁 */					
					//grid.load(resp.rtnList || []);
					ACTION_TYPE = "2";
					buttons.doQuery();						
				});	
		
		},
		
		//聯徵紀錄
		doLink :function(){
		
			var LOAN_ID = $('LOAN_ID_SPAN').innerHTML;
			if(!LOAN_ID){
				alert("請先查詢出客戶資料後，再查詢聯徵紀錄");
				return;
			}
			
			//var source = '<%=dispatcher%>/DSH0_0306/prompt'; 
			//popupWin.popup({
			//	parameters : { LOAN_ID: LOAN_ID ,LINK_FROM :'DSD3_0200'},
			//	src : source				
			//});
			popupWin.windowOpen('<%=dispatcher%>/DSH0_0306/prompt',{
        		'parameters': {'LOAN_ID': LOAN_ID},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'}
    		});
		}
	}

	var selection = {
		// 取得承辦人員下拉選單
		getPROC_ID2_Map : function(){
			selection.clean("PROC_ID2");
			var QUERY_TYPE = $('QUERY_TYPE').getValue();
			var PROC_ID2_List = PROC_ID2_Map[QUERY_TYPE];
			if(PROC_ID2_List){
				selection.createAll("PROC_ID2", PROC_ID2_List, "全部", "", "", "ID", "NAME"); 
			}else{
				var actionName = "getPROD_ID2_Map"; 
				var params = {"QUERY_TYPE" : QUERY_TYPE};
				var successAction = function(resp){
					var PROC_ID2_List = resp.PROC_ID2_List;
					PROC_ID2_Map[QUERY_TYPE] = PROC_ID2_List;
					
					selection.createAll("PROC_ID2", PROC_ID2_List, "全部", "", "", "ID", "NAME"); 
				};
				var errorAction = function(resp){
					var PROC_ID2_List = null;
					
					selection.createAll("PROC_ID2", PROC_ID2_List, "全部", "", "", "ID", "NAME"); 
				};
				ajaxPost(actionName, params, successAction, errorAction);
			}
		},
		// 依照傳入資料與id，產生下拉選單
		createAll : function(tagID, optionList, initialText, choiceValue, isCode_CodeNM, key, value){
			if(!key){
				key = "CODE";
			}
			if(!value){
				value = "CODE_NM";
			}
			
			var target = $(tagID);
			if(target){
				if(initialText){
					selection.create(tagID, "", initialText, "");
				}
				if(optionList){
					for(var i = 0; i < optionList.length; i++){
						if(isCode_CodeNM){
							selection.create(tagID, optionList[i][key], optionList[i][key] + " " + optionList[i][value], choiceValue);
						}else{
							selection.create(tagID, optionList[i][key], optionList[i][value], choiceValue);
						}
					}
				}
			}
		},
		// 依照傳入資料與id，產生下拉選單(資料為Map)
		createAll4Map : function(tagID, optionMap, initialText, choiceValue, isCode_CodeNM){
			var target = $(tagID);
			if(target){
				if(initialText){
					selection.create(tagID, "", initialText, "");
				}
				if(optionMap){
					var dataKey = Object.keys(optionMap);
					dataKey.each(
						function(key){
							if(isCode_CodeNM){
								selection.create(tagID, key, key + " " + optionMap[key], choiceValue);
							}else{
								selection.create(tagID, key, optionMap[key], choiceValue);
							}
						}
					);
				}
			}
		},
		// 產生單一下拉選單(如果下拉選單的value == 資料的Value，則將該option選擇起來)
		create : function(tagID, optionValue, optionText, choiceValue){
			$(tagID).options.add(new Option(optionText, optionValue));
	
			if(choiceValue && optionValue == choiceValue){
				$(tagID).options[$(tagID).length - 1].selected = true;
			}
		},
		// 清空下拉選單
		clean : function(tagID){
			$(tagID).options.length = 0;
		}
	}
	
	var actions = {
		<%-- [20200504] 上傳結束 --%>
		doUploadEnd: function(){
			auxiliary.closeCoverPage();<%--關閉資料處理動畫--%>
			var oFileData = window.importFrame.document.getElementById('filedata'); 
			if(!oFileData){
				alert('上傳失敗');
				return;
			}
			var obj = oFileData.innerHTML.evalJSON();
			var Msg = obj.ErrMsg.msgDesc.replace('\\n','');
			if(Msg){
				msgWin.show(Msg);
			}
			<%--更新附件清單--%>
			if(CSRUtil.isSuccess(obj)){
				grid_E.load(obj.fileList || []);
			}
		},
		//取得頁面資料
		getDate : function(){
			//依照不同條件存取不同的查詢條件
			var reqMap = {};
			
			reqMap.LOAN_ID = $('LOAN_ID_Q').value;
			$$('#QUERY_C_1 input[type = "text"]' , '#QUERY_C_1 select').each(
				function(elem){							
					reqMap[elem.id] = elem.getValue();								
				}
			);
			return reqMap;
		},
		
		//顯示資料
		showData : function(resp){
			if(resp){
				rtnMap = resp.detailMap||{};
			}
			$w('REASON1 REASON2 REASON3 REASON4 REASON5 REASON7 REASON6').each(
			function(id) {
				if (rtnMap['REASON'] == $(id).value) {
					$(id).checked = true;										
				} else {
					$(id).checked = false; 
				}
			});
			
			$$('#form1 input[type="text"]','#form1 input[type="checkbox"]','#form1 input[type="hidden"]','#form1 textarea','#form1 select','#form1 span').each(
				function(dom){
					var tagName = dom.tagName;
					var id = dom.id;
					var datatype = dom.getAttribute('datatype');

					if(tagName == 'INPUT'){
						var type = dom.type;
						if(type == 'checkbox'){	
							if(rtnMap[id]== '1'){
								dom.checked = true;							
							}else{
								dom.checked = false;	
							}
						}else{
							if(datatype == 'ROCdate'){
								dom.setValue(toROC(rtnMap[id] )|| '');		
							}else if(datatype == 'number'){
								dom.setValue(rtnMap[id] ? MoneyFormat(rtnMap[id]) : '0');	
							}else{
								dom.setValue(rtnMap[id] || '');		
							}
						}
					}else if (tagName =='TEXTAREA'){
						dom.setValue(rtnMap[id] || '');
						//reset textarea 字數
						dom.simulate('keyup');
					}else if (tagName =='SELECT'){
						dom.setValue(rtnMap[id] || '');
					}else if (tagName =='SPAN'){
						if(datatype == 'ROCdate'){
							//dom.update( Date.toInputROC(rtnMap[id] || "","/"));   
							dom.update( rtnMap[id]== '無'? rtnMap[id] :Date.toInputROC(rtnMap[id] || "","/"));  		
						}else if(datatype == 'number'){					
							dom.update( rtnMap[id] ? CSRUtil.$fmt(rtnMap[id],"#,###") : 0 );		
						}else{
							//修正難字更新問題
							if(id != 'import'){
								dom.update(rtnMap[id]||'');
							}else if(id == 'import'){
								$('UploadFile').setValue('');
							}
							
						}
					}
				}
			);

			<%-- [20200504]更新附件清單 --%>
			grid_E.load(resp.fileList || []);
			
			<%-- [20200504] 為了附件上傳，將頁面上的LOAN_ID獨立出來 --%>
			$('LOAN_ID_SPAN').update($F('LOAN_ID'));
			
			<%-- [20200525] 資深副總經理欄位依日期判斷顯示內容 --%>
			$('CONFIRM_NAME42_title').update(rtnMap['CONFIRM_NAME42_title']||'資深副總經理');
			
			//連結到DSH0_1400
			var BORROW_ID = rtnMap['BORROW_ID'];
		  	var link1 = new Element('a' , { href : '#' } ).update(BORROW_ID);
			
			link1.observe( 'click', function (event){																			
				//var source = '<%=dispatcher%>/DSD3_0210/prompt'; 
				//popupWin.popup({
				//	parameters : { BORROW_ID: BORROW_ID ,LINK_FROM :'DSD30200'},
				//	src : source				
				//});	
				popupWin.windowOpen('<%=dispatcher%>/DSD3_0210/prompt',{
	        		'parameters': {'BORROW_ID': BORROW_ID},
					'fullScreen': false,
					'attributes': {'resizable': 'yes'}
    			});
				
			});	
			$('BORROW_ID').update(link1);	
			
			if(BORROW_ID){			
				var link2 = new Element('a' , { href : '#' } ).update(rtnMap['INSU_AMT'] ? CSRUtil.$fmt(rtnMap['INSU_AMT'],"#,###") : 0);
				
				link2.observe( 'click', function (event){																			
					//var source = '<%=dispatcher%>/DSH0_1400/prompt'; 
					//popupWin.popup({
					//	parameters : { PERSON_ID: BORROW_ID ,LINK_FROM :'DSD30200'},
					//	src : source				
					//});
					popupWin.windowOpen('<%=dispatcher%>/DSH0_1400/prompt',{
	        			'parameters': {'PERSON_ID': BORROW_ID},
						'fullScreen': false,
						'attributes': {'resizable': 'yes'}
    				});	
				
				
				});	
				$('INSU_AMT').update(link2);	
			}
			<%--個擔分群連結--%>
			var REFER_ID_GROUP = rtnMap['REFER_ID_GROUP'];
			if($('REFER_ID_GROUP').innerHTML != '非有效件'){
		 		var linkREFER_ID_GROUP = new Element('a', { href : 'javascript:;' }).update(REFER_ID_GROUP);
		 		$('REFER_ID_GROUP').update(linkREFER_ID_GROUP);
		 		linkREFER_ID_GROUP.observe('click', function(event){
		 			popupWin.popup({
		 				src : '${dispatcher}/DSH0_0320/prompt', <%--開新視窗顯示客戶分群資料查詢頁面DSH0_0320--%>
		 				parameters : {
		 					TYPE : '1', <%--依擔保品角度查詢,固定給1--%>
							CASE_ID : $F('REFER_ID') <%--原貸帳號--%>
		 				}
		 			});
		 		});
		 	}
			<%--總擔分群連結 --%>
			var BORROW_ID_GROUP = rtnMap['BORROW_ID_GROUP'];
			if($('BORROW_ID_GROUP').innerHTML != '非有效件'){
		 		var linkBORROW_ID_GROUP = new Element('a', { href : 'javascript:;' }).update(BORROW_ID_GROUP);
		 		$('BORROW_ID_GROUP').update(linkBORROW_ID_GROUP);
		 		linkBORROW_ID_GROUP.observe('click', function(event){
		 			popupWin.popup({
		 				src : '${dispatcher}/DSH0_0320/prompt', <%--開新視窗顯示客戶分群資料查詢頁面DSH0_0320--%>
		 				parameters : {
		 					TYPE : '2', <%--依借款人ID查詢,固定給2--%>
							CASE_ID : $('BORROW_ID').textContent <%--借款人ID--%>
		 				}
		 			});
		 		});
		 	}
		},
		

		
		clearAll : function(){
			//將所有欄位清空
			$$('#form1 input[type = "text"]','#form1 textarea','#form1 select','#form1 span').each(
				function(elem){
				
					var tagName = elem.tagName;						
					if(tagName == 'INPUT' || tagName == 'SELECT' || tagName == 'TEXTAREA'){
						elem.setValue('');					
					}else if(tagName == 'SPAN'){
						//避免上傳span被清空
						if(elem.id != 'import'){
							elem.update('');	
						}else{
							$('UploadFile').setValue('');	
						}
										
					}
				
				}			
			);
			
			//將打勾清空
			$$('#form1 input[type = "checkbox"]').each(
				function(elem){
					elem.checked = false;					
				}			
			);
			
			//reset textarea 字數
			$("INPUT_MEMO").simulate('keyup');
		},
		
		
		//狀態連動
		statusChange : function(event){	
			$('K_BEGIN_DATE').setValue(today_2month);
			$('K_END_DATE').setValue(today);
			
		},
		
		//輸入或異動【區塊E】建議調降欄位時，連動計算保優利率		
		changeSubRate3 : function(){
			
			//保優利率 = 目前利率 - 建議調降%數
			var CURR_RATE = $('CURR_RATE').innerHTML;
			
			ajaxPost( 'changesubrate3',	{CURR_RATE:CURR_RATE, FINAL_REDUCE : $F('FINAL_REDUCE') },
				function(resp){
					$('FINAL_RATE').setValue(resp.FINAL_RATE);
		
				}				
			);		
		},
		
		queryResult : function(rtnList){
					grid = new TableUI ({
									table: $('grid'),  allSortable:true, pageSize: 5, split: ['INPUT_DATE'], isLoadByFatch : 5,
									autoCheckBox:{						
										type :"radio" ,
										valueKey:"QUERY_NO",
										action: function(checkbox , boxStatus , records) {
											if(!boxStatus){ return;}
											checkedValue = checkbox.value;
											buttons.doQueryDetail(records[0]);
										}
									},		
									<%-- [20240326] 難字調整 --%>
									pageChange: function() {
										if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
									},
									column: [	
												//申請書221031007009:北南服務部組織調整配套作業-移除顯示區部
												/*{header: '貸款帳號' , key : 'LOAN_ID',
													render : function(rec ,val ){
														return rec.LOAN_ID + '(' +rec.CRED_DEPT_NM + ')';
													}								
												},*/
												{header: '貸款帳號' , key : 'LOAN_ID'},
												<%-- [20240326] 難字調整：借戶姓名 --%>
												{header: '借戶姓名' , key : 'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},	
												{header: '原貸金額' , key : 'LOAN_AMT', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###") : 0;								
													}},	
												{header: '目前商品' , key : 'PREFER_TYPE_NM'},	
												{header: '目前利率' , key : 'CURR_RATE', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###.000") : 0.000;								
													}},	
												{header: '年繳保費' , key : 'INSU_AMT', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###") : 0;								
													}},
												{header: '處理利率' , key : 'FINAL_RATE', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###.000") : 0.000;								
													}},	
												<%-- [20240326] 難字調整：承辦人員 --%>
												{header: '承辦人員' , key : 'PROC_NAME2', attrs:{ style:"font-family:'EUDC'" }},
												{header: '清償原因' , key : 'REASON_NM'},	
												{header: '輸入日' , key : 'INPUT_DATE',
													render : function(rec , val){
														return val ? Date.toInputROC( val || '','/' ) :'' ;									
													}	},	
												{header: '區域' , key : 'MANAGING_NM'},	
												{header: '本金餘額' , key : 'REMAIN_AMT', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###") : 0;								
													}},
												{header: '服務中心' , key : 'SERV_DEPT_NAME'},
												{header: '已繳期數' , key : 'PAID_TIMES', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###") : 0;								
													}},
												{header: '受理來源' , key : 'SOURCE_NM'}, 
												{header: '期數' , key : 'FINAL_PERIOD', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###") : 0;								
													}},
												{header: '處理順序' , key : 'REASON1_NM'},
												{header: '處理狀態' , key : 'PROCESS_STATUS_NM'}
											],
										afterLoad:function(){
											$$('#grid input[type = "radio"]').each(
												function(elem){
													if(elem.value == "0"){
														elem.click();
													}
												});											
											<%-- [20240326] 難字調整 --%>
											if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
										}	
								});	
					
					grid.load(rtnList||[]);

		}
	}
	
	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSD30200", "防止清償通報", "防止清償通報查詢",1 );					
				<cathay:LocaleDisplay sysCode="DS" var="localeDisplay" 
						dateFields = "K_BEGIN_DATE K_END_DATE"
						numberFields = "EXPENSE_AMT RATE RATE_CORP SUG_RATE TRANS_AMT LOAN_AMT TRANSFER_RATE SUG_REDUCE1 SUG_PERIOD1 SUG_RATE1 FINAL_REDUCE FINAL_PERIOD FINAL_RATE"/>

				initValidation();	
				buttonAuth();	
							
				grid = new TableUI ({
								table: $('grid'),  allSortable:true, pageSize: 5, split: ['INPUT_DATE'],isLoadByFatch : 5,
								autoCheckBox:{						
									type :"radio" ,
									valueKey:"QUERY_NO",
									action: function(checkbox , boxStatus , records) {
										if(!boxStatus){ return;}
										checkedValue = checkbox.value;
										buttons.doQueryDetail(records[0]);
									}
								},
										<%-- [20240326] 難字調整 --%>
										pageChange: function() {
											if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
										},
										column: [
												//申請書221031007009:北南服務部組織調整配套作業-移除顯示區部
												/*{header: '貸款帳號' , key : 'LOAN_ID',
													render : function(rec ,val ){
														return rec.LOAN_ID + '(' +rec.CRED_DEPT_NM + ')';
													}								
												},*/
												{header: '貸款帳號' , key : 'LOAN_ID'},
												<%-- [20240326] 難字調整：借戶姓名 --%>
												{header: '借戶姓名' , key : 'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},	
												{header: '原貸金額' , key : 'LOAN_AMT', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###") : 0;								
													}},	
												{header: '目前商品' , key : 'PREFER_TYPE_NM'},	
												{header: '目前利率' , key : 'CURR_RATE', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###.000") : 0.000;								
													}},	
												{header: '年繳保費' , key : 'INSU_AMT', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###") : 0;								
													}},
												{header: '處理利率' , key : 'FINAL_RATE', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###.000") : 0.000;								
													}},	
												<%-- [20240326] 難字調整：承辦人員 --%>
												{header: '承辦人員' , key : 'CRED_NM', attrs:{ style:"font-family:'EUDC'" }},
												{header: '清償原因' , key : 'REASON_NM'},	
												{header: '輸入日' , key : 'INPUT_DATE',
													render : function(rec , val){
														//return (rec.INPUT_DATE + rec.INPUT_TIME) || '';
														return val ? (Date.toInputROC( val || '','/' ) + ' ' + (rec.INPUT_TIME || '')) : '' ;									
													}	},	
												{header: '區域' , key : 'MANAGING_NM'},	
												{header: '本金餘額' , key : 'REMAIN_AMT', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###") : 0;								
													}},
												{header: '服務中心' , key : 'SRV_DEPT_NAME'},
												{header: '已繳期數' , key : 'PAID_TIMES', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###") : 0;								
													}},
												{header: '受理來源' , key : 'SOURCE_NM'},	
												{header: '期數' , key : 'FINAL_PERIOD', 
													render : function(rec , val){
														return val ?  CSRUtil.$fmt(val,"#,###") : 0;								
													}},
												{header: '處理順序' , key : 'CASE_TYPE_NM'},
												{header: '處理狀態' , key : 'PROCESS_STATUS_NM'}
											],
									afterLoad:function(){
										$$('#grid input[type = "radio"]').each(
											function(elem){
												if(elem.value == "0"){
													elem.click();
												}
											
											}							
										);											
										<%-- [20240326] 難字調整 --%>
										if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
									}	
												
							});
				
				<%-- 附件上傳區 --%>	
				grid_E = new TableUI ({
								table: $('grid_E'),
								pageSize : 0,
								<%-- [20240326] 難字調整 --%>
								afterLoad: function() {
									if ( "function" === typeof(parseEUDC) ) { removeInputTypeFile(); }
								},
								pageChange: function() {
									if ( "function" === typeof(parseEUDC) ) { removeInputTypeFile(); }
								},
								column: [	
									{ header: "檔名", key: "FILE_NM",
										render : function(rec , val){
											if(!val){
												return '';
											}
											var FILE_ID = rec.FILE_ID;
											if(!FILE_ID){
												return val;
											}
											var link = new Element('a', { href : 'javascript:void(0)' });
											link.update(val);
											link.observe('click', function(){
												ajaxPost(
													"download",
													{
														FILE_ID: FILE_ID
													},
													function (resp) {
														if(CSRUtil.isSuccess(resp)){
															RPTUtil.download({
																'downloadFileName': resp.FILE_NM,
																'downloadFileFullPath': resp.FILE_PATH
															})
														}
													}
												);
											});
											return link;							
										}
									},
									<%-- [20240326] 難字調整：上傳人員 --%>
									{ header: "上傳人員", key: "LST_PROC_NAME", attrs:{ style:"font-family:'EUDC'" }},
									{ header: "上傳時間", key: "LST_PROC_DATE" },
									{ header: "刪除附件", key: "REMOVE_ITEM", sortable: false,
										input:{
				                            type: 'Button',
				                            text: '移除',
				                            action: function( node , dataObj , textDiv, orgData ){
				                            	var dataObj0 = dataObj[0] || {};
				                            	var FILE_ID = dataObj0.FILE_ID;
				                            	var LOAN_ID = dataObj0.LOAN_ID;
				                            	var SEQ_NO = dataObj0.SEQ_NO;
				                            	if (!FILE_ID) {
				                            		alert('FILE_ID不得為空');
				                            		return;
				                            	}
				                            	if (!LOAN_ID) {
				                            		alert('LOAN_ID不得為空');
				                            		return;
				                            	}
				                            	if (!SEQ_NO) {
				                            		alert('SEQ_NO不得為空');
				                            		return;
				                            	}
				                            	ajaxPost(
				                    					'removeFile',
				                    					{
				                    						FILE_ID: FILE_ID,
				                    						LOAN_ID: LOAN_ID,
				                    						SEQ_NO: SEQ_NO
				                    					},
				                    					function(resp){
				                    						grid_E.load(resp.rtnList || []);
				                    					}
				                    			);
				                            }
				                    	}
									}
								]	
							});
		
				//[20200610]增加輸入欄位字數檢核
				InputUtility.lengthLimit.add("INPUT_MEMO", 400, true, "中文或全型算2個字，已輸入{enter}字，尚可輸入{left}字。");
		
				//click事件
				$('btn_query').observe('click',function(event){
				    ACTION_TYPE = "1";
					buttons.doQuery();
				});
			
				$('btn_save').observe( 'click', buttons.doSave);
				$('btn_confirm').observe( 'click', buttons.doConfirm);
				$('btn_cancelconfirm').observe( 'click', buttons.doCancelConfirm);
				$('btn_autodeal').observe( 'click', buttons.doAutodeal);
				//$('btn_yeardeal').observe( 'click', buttons.doYearDeal); //2017-09-04申請書-利率調整作業 「一年個調附約」及「五年個調附約」按鈕合併為「個調附約」按鈕，連結新版利率調整附約
				$('btn_print1').observe( 'click', buttons.doPrint1);
				$('btn_link').observe( 'click', buttons.doLink);
				$('btn_reject').observe( 'click', buttons.doReject);
				$('btn_upload').observe( 'click', buttons.doUpload);<%-- [20200504] 新增檔案 --%>
				$('importFrame').observe('load', actions.doUploadEnd);<%-- [20200504] 上傳結束的動作 --%>
				$('btn_reject').observe( 'click', buttons.doReject);
				
				$('QUERY_TYPE').observe('change', selection.getPROC_ID2_Map);//單位連動承辦人員
				
				$('LOAN_ID_Q').observe('change' ,  function(event){
						event.target.setValue(event.target.value.toUpperCase());					
				});
				
				$('K_BEGIN_DATE').setValue(today_2month);
				$('K_END_DATE').setValue(today);
				
				//區塊E ─ 建議調降欄位 連動計算保優利率
				$('FINAL_REDUCE').observe('blur',actions.changeSubRate3);

				//處理狀態預設值
				$('PROCESS_STATUS').setValue('${DEFAULT_STATUS}');			
				$('QUERY_TYPE').setValue('${QUERY_TYPE}');	
				$('QUERY_TYPE').simulate('change');
				
				//接值
				<c:if test="${not empty LOAN_ID}">
					$('LOAN_ID_Q').setValue('${LOAN_ID}');
					buttons.doQuery();
				</c:if>
								
				fix();

				displayMessage();											
			}
	};
};

</script>
</head>
<body>
<form id="form" name="form"
	style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">

<table id="QUERY_C_1" width="100%" border="0" cellpadding="0"
	cellspacing="1" class="tbBox2">
	<tbody id="show">
		<tr>
			<td class="tbYellow" width="11%" align="left"><!-- <input name = "QUERY_KIND" type = "radio" value = "1" checked />-->貸款帳號
			</td>
			<td class="tbYellow2" colspan="8"><input id="LOAN_ID_Q" name="LOAN_ID_Q" type="text" class="textBox2" fieldName="貸款帳號" size="12" maxlength="10" />
			</td>
			<td class="tbYellow2" align="center" rowspan="3">
				<input id="btn_query" type="button" class="button" value="查詢" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" align="left" rowspan="2"><!-- <input name = "QUERY_KIND" type = "radio" value = "2"/>-->其他
			</td>
			<td class="tbYellow" width="6%" align="left">單位</td>
			<td class="tbYellow2">
				<select name="QUERY_TYPE" id="QUERY_TYPE"	class="textBox2" fieldName="單位">
					<option value="">請選擇</option>
					<c:forEach items="${QUERY_TYPE_LIST}" var="map">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" width="8%" align="left">單位代號</td>
			<td class="tbYellow2">
				<input id="DIV_NO" name="DIV_NO" type="text" class="textBox2" fieldName="單位代號" size="8" maxlength="7" value="${DIV_NO}" />
			</td>
			<td class="tbYellow" width="8%" align="left">承辦人員</td>
			<td class="tbYellow2" colspan="3">
				<%-- [20240326] 難字調整：承辦人員 --%>
				<select name="PROC_ID2" id="PROC_ID2" class="textBox2" fieldName="承辦人員" alt="ch">
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left">處理順序</td>
			<td class="tbYellow2">
				<select name="CASE_TYPE" id="CASE_TYPE" class="textBox2" fieldName="處理順序">
					<option value="">請選擇</option>
					<c:forEach items="${D3_CASE_TYPE}" var="map">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" align="left">處理狀態</td>
			<td class="tbYellow2">
				<select name="PROCESS_STATUS" id="PROCESS_STATUS" class="textBox2" fieldName="處理狀態">
					<option value="">請選擇</option>
					<c:forEach items="${PROCESS_STATUS1_LIST}" var="map">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" width="6%" align="left">附約進度</td>
			<td class="tbYellow2">
				<select name="ADJ_STATUS" id="ADJ_STATUS"	class="textBox2" fieldName="附約進度">
					<option value="">請選擇</option>
					<c:forEach items="${ADJ_STATUS_LIST}" var="map">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" align="left">輸入日</td>
			<td class="tbYellow2">
				<input name="K_BEGIN_DATE" id="K_BEGIN_DATE" type="text" class="textBox2 validate-ROCDate" size="7" maxlength="7" fieldName="查詢起日" /> 
				 ~ 
				<input name="K_END_DATE" id="K_END_DATE" type="text" class="textBox2 validate-ROCDate" size="7" maxlength="7" fieldName="查詢迄日" /> 
			</td>
		</tr>
	</tbody>
	<tr>
		<td align="center" colspan="8">
		<input id="btn_save" type="button" class="button" value="暫存" />
		<input id="btn_confirm" type="button" class="button" value="審核" />
		<input id="btn_cancelconfirm" type="button" class="button" value="取消審核" />
		<input id="btn_autodeal" type="button" class="button" value="個調附約" />
		<!--<input id="btn_yeardeal" type="button" class="button" value="一年個調附約" />--> 
		<input id="btn_print1" type="button" class="button" value="批覆書" />
		<input id="btn_reject" type="button" class="button" value="退件" />
		<input id="DEFAULT_STATUS" type="hidden" value="${DEFAULT_STATUS}"/>
	</tr>
</table>
</form>
<table id="grid"></table>

<form id="form1" name="form1"
	style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" method="post" enctype="multipart/form-data" target="importFrame">
<iframe id="importFrame" name="importFrame" width="0" height="0"></iframe><%-- 匯入檔案時，模擬Ajax的效果 --%>
<input id="LOAN_ID" name="LOAN_ID" type="hidden"/>
<input id="SEQ_NO" name="SEQ_NO" type="hidden"/>
<table width="100%" border="0" cellpadding="0" cellspacing="1"
	class="tbBox2">
	<tr>
		<td class="tbYellow0" align="center" colspan="6"><b>客戶資料</b></td>
		<input id="PROCESS_STATUS_V" type="hidden" value=""/>
	</tr>
	<tr>
		<td class="tbYellow" width="8%" align="left">貸款帳號</td>
		<td class="tbYellow2" width="10%" align="left">
			<span id="LOAN_ID_SPAN"></span>
			&nbsp&nbsp<span id="REFER_ID_GROUP"></span><%--個擔分群--%>
			<input id="REFER_ID" type="hidden"><%--原貸帳號--%>
		</td>
		<td class="tbYellow" width="8%" align="left">借款人姓名</td>
		<td class="tbYellow2" width="10%" align="left">
			<%-- [20240326] 難字調整：借款人姓名 --%>
			<span id="BORROW_NAME" style="font-family:'EUDC'"></span>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<span style="color:red;" id="VIP_MSG"></span>
		</td>
		<td class="tbYellow" width="8%" align="left">借款人ID</td>
		<td class="tbYellow2" width="10%" align="left">
			<span id="BORROW_ID"></span>
			&nbsp&nbsp<span id="BORROW_ID_GROUP"></span><%--總擔分群--%>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="8%" align="left">本金餘額</td>
		<td class="tbYellow2" width="10%" align="left"><span id="REMAIN_AMT" dataType="number"></span></td>
		<td class="tbYellow" width="8%" align="left">目前商品</td>
		<td class="tbYellow2" width="10%" align="left"><span id="PREFER_TYPE_NM"></span></td>
		<td class="tbYellow" width="8%" align="left">擔保品鄉鎮</td>
		<td class="tbYellow2" width="10%" align="left"><span id="GAGE_ADDR_NM"></span>(<span id="AREA_CODE_930318"></span>區)</td>
	</tr>
	<tr>
		<td class="tbYellow" width="8%" align="left">已繳期數</td>
		<td class="tbYellow2" width="10%" align="left"><span id="PAID_TIMES" datatype="number"></span></td>
		<td class="tbYellow" width="8%" align="left">近六期逾15天次數</td>
		<td class="tbYellow2" width="10%" align="left"><span id="OVER_TIMES"></span></td>
		<td class="tbYellow" width="8%" align="left">下次應繳日</td>
		<td class="tbYellow2" width="10%" align="left"><span id="NEXT_PAYDT" datatype="ROCdate"></span></td>
	</tr>
	<tr>
		<td class="tbYellow" width="8%" align="left">目前利率</td>
		<td class="tbYellow2" width="10%" align="left"><span id="CURR_RATE" datatype="number"></span></td>
		<td class="tbYellow" width="8%" align="left">原契約利率</td>
		<td class="tbYellow2" width="10%" align="left"><span id="PROD_RATE" datatype="number"></span></td>
		<td class="tbYellow" width="8%" align="left">指數(指標)利率</td>
		<td class="tbYellow2" width="10%" align="left"><span id="BASE_RATE" datatype="number"></span></td>
	</tr>
	<tr>
		<td class="tbYellow" width="8%" align="left">清償違約金</td>
		<td class="tbYellow2" width="10%" align="left"><span id="RENEGE" datatype="number"></span></td>
		<td class="tbYellow" width="8%" align="left">參考年保費</td>
		<td class="tbYellow2" width="10%" align="left"><span id="INSU_AMT" datatype="number"></span></td>
		<td class="tbYellow" width="8%" align="left">最近利率調整日</td>
		<td class="tbYellow2" width="10%" align="left"><span id="LAST_ADJUST" datatype="ROCdate"></span></td>
	</tr>
	<tr>
		<td class="tbYellow" width="8%" align="left">生效日</td>
		<td class="tbYellow2" width="10%" align="left"><span id="BEGIN_DATE" datatype="ROCdate"></span></td>
		<td class="tbYellow" width="8%" align="left">終止日</td>
		<td class="tbYellow2" width="10%" align="left"><span id="END_DATE" datatype="ROCdate"></span></td>
		<td class="tbYellow" width="8%" align="left">繳息狀況</td>
		<td class="tbYellow2" width="10%" align="left"><font color="red"><span id="C_PAY_DELAY"></span></font></td>
	</tr>
	<tr>
		<td class="tbYellow" width="8%" align="left">通報人員</td>
		<td class="tbYellow2" width="10%" align="left">
			<%-- [20240326] 難字調整：通報人員 --%>
			<span id="INPUT_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow" width="8%" align="left">通報人員電話</td>
		<td class="tbYellow2" width="10%" align="left"><span id="INPUT_TEL"></span></td>
		<td class="tbYellow" width="8%" align="left">關係人</td>
		<td class="tbYellow2" width="10%" align="left">
			<%-- [20240326] 難字調整：關係人 --%>
			<span id="RELATION" style="font-family:'EUDC'"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="8%" align="left">定期期數</td>
		<td class="tbYellow2" width="10%" align="left"><span id="FIX_PERIOD" datatype="number"></span></td>
		<td class="tbYellow" width="8%" align="left">分期期數</td>
		<td class="tbYellow2" width="10%" align="left"><span id="SPR_PERIOD" datatype="number"></span></td>
		<td class="tbYellow" width="8%" align="left">受理來源</td>
		<td class="tbYellow2" width="10%" align="left"><span id="SOURCE"></span></td>
	</tr>
	<tr>
		<td class="tbYellow" width="8%" align="left">客戶行動電話</td>
		<td class="tbYellow2" width="10%" align="left"><span id="CUSTOM_TEL"></span></td>
		<td class="tbYellow" width="8%" align="left">利率限制</td>
		<td class="tbYellow2" width="10%" align="left"><span id="LIMIT_MSG"></span></td>
		<%--[20221229]新增本金彈性還期間--%>
		<td class="tbYellow" width="8%" align="left">本金彈性還期間</td>
		<td class="tbYellow2" width="10%" align="left"><span id="FLEX_PERIOD_NM"></span></td>
	</tr>
	<tr>
		<td class="tbYellow" rowspan="7">
			清償原因
		</td>
		<td class="tbYellow2" colspan="5">
			<input type="radio" id="REASON1" name="radio" value="1" disabled>1.利率因素:轉貸
			<input id="TRANS_BANK1" type="text" class="textBox2" size="12" readonly/>行庫
			<input id="TRANS_AGENT1" type="hidden" class="textBox2" size="12"readonly/><!--分行，-->利率
			<input id="RATE" type="text" class="textBox2" size="6"  readonly/>％<!--(本公司-->
			<input id="RATE_CORP" type="hidden" class="textBox2" size="6" readonly/><!--％)-->
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="radio" id="REASON2" name="radio" value="2" disabled>2.貸限因素:轉貸
			<input id="TRANS_BANK2" type="text" class="textBox2" size="12" readonly/>行庫
			<input id="TRANS_AGENT2" type="hidden" class="textBox2" size="12" readonly/><!--分行，-->金額
			<input id="TRANS_AMT" type="text" class="textBox2" size="6" readonly/>萬<!--(本公司-->
			<input id="LOAN_AMT" type="hidden" class="textBox2" size="6" readonly/><!--萬)-->
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="radio" id="REASON3" name="radio" value="3" disabled>3.服務或與銀行往來因素-客戶反應事實
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="radio" id="REASON4" name="radio" value="4" disabled>4.出售<!--－買方姓名-->
			<input id="BUY_NAME" type="hidden" class="textBox2" size="15" readonly/><!--電話-->
			<input id="BUY_TEL" type="hidden" class="textBox2" size="12" readonly/><!--<br>&nbsp;&emsp;&emsp;&emsp;&emsp;【代書姓名-->
			<input id="LAW_NAME" type="hidden" class="textBox2" size="15" readonly/><!--電話-->
			<input id="LAW_TEL" type="hidden" class="textBox2" size="12" readonly/><!--】-->
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="radio" id="REASON5" name="radio" value="5" disabled>5.有閒錢<!--【1】
			<input type="checkbox" id="ITEM1" disabled>支票 【2】
			<input type="checkbox" id="ITEM2" disabled>現金 【3】
			<input type="checkbox" id="ITEM3" disabled>匯款<br>&nbsp;&nbsp;&nbsp;&nbsp;閒錢來源：-->
			<input id="SUPPLY" type="hidden" class="textBox2" size="60" readonly/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="radio" id="REASON7" name="radio" value="7" disabled>6.申請(定+分)展延未准
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="radio" id="REASON6" name="radio" value="6" disabled>7.其他-轉【1】
			<select id="CHOICE6" disabled>			
				<option value="">請選擇</option>	
				<c:forEach items="${CHOICE6_LIST}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select><br>&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;【2】其他原因：
			<input id="OTHER" type="text" class="textBox2" size="60" readonly/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow"  align="left" >備註</td>
		<td class="tbYellow2" align="left" colspan="5"><span id="INPUT_NOTE"></span></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow0" align="center" colspan="9"><b>資產管理科處理結果</b>
			<input id="btn_link" type="button" class="button" value="聯徵紀錄" />
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" align="left" rowspan="5">處理情形</td>
		<td class="tbYellow2" align="left" colspan="6">本案經評估調降 
			<input id="FINAL_REDUCE" name="FINAL_REDUCE" type="text" class="textBox2" size="7" fieldName = "調降利率" />%，期間
			<input id="FINAL_PERIOD" name="FINAL_PERIOD" type="text" class="textBox2" size="7" fieldName = "調降期間" />期，調降後之保優利率為
			<input id="FINAL_RATE" name="FINAL_RATE" type="text" class="textBox2" size="7" fieldName = "調降後保優利率" readOnly /> %，手續費金額
			<input id="EXPENSE_AMT" name="EXPENSE_AMT" type="text" class="textBox2" size="7" fieldName = "手續費金額"/>元，建議利率 
			<!-- [20200504] 刪除 -->
<!-- 			<select	name="VIP_GRADE" id="VIP_GRADE" class="textBox2" fieldName = "客戶等級"> -->
<!-- 				<option value="">請選擇</option> -->
<!-- 				<c:forEach items="${VIP_GRADE_LIST}" var="map"> -->
<!-- 					<option value="${map.key}">${map.value}</option> -->
<!-- 				</c:forEach> -->
<!-- 			</select> -->
			<!-- [20200504] 新增：建議利率 -->
			<input id="SUG_RATE" name="SUG_RATE" type="text" class="textBox2" size="7" fieldName = "建議利率" />%
			，核定層級
			<select	name="PROCESS_LEVEL" id="PROCESS_LEVEL" class="textBox2" fieldName = "核定層級">
				<option value="">請選擇</option>
				<c:forEach items="${PROCESS_LEVEL_LIST}" var="map">
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>，以避免流失。
			<br>
		<input id="IS_SEND_MSG" type="checkbox"/>是否發送核准通知(通報人及客戶)		
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" align="left" colspan="7">
			<!-- [20200525] 調整批示內容顯示方式(參考變更年期簽件) -->
			<span id="BOSS_COMMENT"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" align="left" colspan="7">
			作業內容：<br>
			<textarea id="INPUT_MEMO" name="INPUT_MEMO" cols="90" rows="3"></textarea>
		</td>
	</tr>
	<!-- [20200504] 新增【上傳附件】區 -->
	<tr>
		<td class="tbYellow" width="10%" align="left" rowspan="2">上傳附件</td>
		<td class="tbYellow2" align="left" colspan="6">
			<span id = import>
				<input id="UploadFile" name="UploadFile" type="file" title="附件上傳" class="input">
			</span>
			
			<button type='button' id='btn_upload' class='button' title='新增檔案'>新增檔案</button>
		</td>
		</td>
		<%--檔名、移除附件--%>
		<tr>
		    <td colSpan='6'>
				<table id='grid_E'></table>
			</td>
		</tr>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" align="left" rowspan="2">審核人員</td>
		<td class="tbYellow" width="6%" align="left">承辦</td>
		<td class="tbYellow2" width="14%" align="left">
			<%-- [20240326] 難字調整：承辦 --%>
			<span id="PROC_NAME2" style="font-family:'EUDC'"></span>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<span id="PROC_DATE2" datatype="ROCdate"></span>
		</td>
		<td class="tbYellow" width="6%" align="left">組長</td>
		<td class="tbYellow2" width="14%" align="left">
			<%-- [20240326] 難字調整：組長 --%>
			<span id="PROC_NAME3" style="font-family:'EUDC'"></span>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<span id="PROC_DATE3" datatype="ROCdate"></span>
		</td>
		<td class="tbYellow" width="6%" align="left">科主管</td>
		<td class="tbYellow2" width="14%" align="left">
			<%-- [20240326] 難字調整：科主管 --%>
			<span id="CONFIRM_NAME2" style="font-family:'EUDC'"></span>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<span id="CONFIRM_DATE2" datatype="ROCdate"></span>
		</td>
		
		
	</tr>
	<tr>
		<td class="tbYellow" width="6%" align="left">部室主管</td>
		<td class="tbYellow2" width="14%" align="left" >
			<%-- [20240326] 難字調整：部室主管 --%>
			<span id="CONFIRM_NAME3" style="font-family:'EUDC'"></span>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<span id="CONFIRM_DATE3" datatype="ROCdate"></span>
		</td>
		<td class="tbYellow" width="6%" align="left">副總經理</td>
		<td class="tbYellow2" width="14%" align="left">
			<%-- [20240326] 難字調整：副總經理 --%>
			<span id="CONFIRM_NAME4" style="font-family:'EUDC'"></span>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<span id="CONFIRM_DATE4" datatype="ROCdate"></span>
		</td>
		<!-- [20200504] 新增：副總經理(二)、ID、日期 -->	
		<td class="tbYellow" width="6%" align="left" id='CONFIRM_NAME42_title'>資深副總經理</td>
		<td class="tbYellow2" width="14%" align="left">
			<%-- [20240326] 難字調整：資深副總經理 --%>
			<span id="CONFIRM_NAME42" style="font-family:'EUDC'"></span>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<span id="CONFIRM_DATE42" datatype="ROCdate"></span>
		</td>
	</tr>
</table>
</form>
</body>
</html>