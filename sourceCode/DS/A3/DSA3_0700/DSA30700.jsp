<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>



<!--
程式：DSA30700.jsp
作者：謝雅筑
功能：整批件鑑價報告輸入
完成：2012/05/21

[20180626]
問題敘述：1.IE11問題 2.onpropertychange在IE11失效，改用onkeyup，並在查詢完成時模擬keyup動作

 * [20201112] 修改件 立案單號:201106001527
 *  1. 申請書-201019001927：調整承作分區判斷邏輯
    2. 新增覆核G區塊
    3. 報表列印補上G區塊
    
[20211018] 修改件，立案單號:211015005065
CHROME 進入壽核系統的鑑價報告 textarea 欄位優化

[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>
<script type="text/javascript" src='<%=htmlBase%>/CM/js/ui/InputUtility.js'></script>

<style type="text/css">
@font-face {
font-family: 'EUDC';
  src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
       url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
 font-weight: normal;
 font-style: normal
}
</style>

<script type="text/javascript">


// 產生畫面物件
var DSA30700 = new DSA30700();

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', DSA30700.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA30700(){

	var valid1; //區塊A
	var valid2; //區塊B~F區
	var pageRtnMap = {}; //目前頁面顯示的查詢結果
	
	var gridR1;
	var addIndex = 0;//動態刪除,新增識別值
	
	var A3_QUALITY_LIST = {};//錯誤原因選單
	var A3_MEMO1_LIST = {};//錯誤說明(資料查證判讀)選單
	var A3_MEMO2_LIST = {};//錯誤說明(擔保品敘述)選單
	var A3_MEMO3_LIST = {};//錯誤說明(擔保品計算)選單
	var A3_MEMO4_LIST = {};//錯誤說明(影像圖檔製作)選單
	var A3_MEMO5_LIST = {};//錯誤說明(案例查證與計算)選單
	var A3_MEMO6_LIST = {};//錯誤說明(差異分析過程)選單
	var A3_MEMO7_LIST = {};//錯誤說明(綜合分析與比較)選單
	var A3_MEMO8_LIST = {};//錯誤說明(價格評估結論)選單
	
	var isURBAN_PROJECT = false;//若為都市計畫案區域，須檢核都市計畫案不可為空
	
	//需檢核的textArea欄位
	var validArray = [
		"AREA_DESC",
		"TRAFFIC_DESC",
		"BUILD_TYPE",
		"MAIN_USE",
		"PARK_TYPE",
		"PUB_RATE",
		"CONSTRUCT_DESC",
		"OTHER_DESC",
		"VISIT_DESC",
		"VISIT_OTHER_DESC",
		"AGENT_DESC",
		"PRICE_DESC",
		"PRICE_OTHER_DESC"
	];

	//檢核用迴圈
	function validDefineInfo(defineValid , type){
		for(var i = 0 ; i < validArray.length ; i++){
			defineValid.define( type , { id: validArray[i] } );		
		}
	}

	var buttonAuth = function (){
		var authButtons = {
			B0003:"btn_insert"<%--新增--%> ,
			B0004:"btn_update"<%--修正--%> ,
			B0005:"btn_delete"<%--刪除--%> ,
			B0116:"btn_confirm"<%--呈核--%> ,
			B0085:"btn_cancel"<%--取消呈核--%> ,
			B0117:"btn_captainConfirm"<%--組長覆核--%> ,
			B0018:"btn_captainReject"<%--組長退回--%> ,
			B0123:"btn_bossConfirm"<%--科主管覆核--%> ,
			B0125:"btn_gmConfirm"<%--部室主管覆核--%> ,
			B0126:"btn_Reject"<%--部室主管退回--%> ,
			B0134:"btn_getSpcDistance"<%--取得鄰近設施資料--%>,
			B0148:"btn_reSend"<%--報告重送 --%>
		};
		<dz:grantButtons FUNC_ID="DSA30700" ignored="false"/>
	};	
	
	var actions = {

		//查詢
		doQuery:function(){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			valid1.reset();
			valid2.reset();
			if( !valid1.validate() ) {
	    		return;
	    	}	
	    	
			ajaxPost('query',{APPLY_ID:$F('APPLY_ID')},
				function(resp){
					//保留參數管理-更新受理編號
					CSRUtil.keepParamsManager.put({'APPLY_ID': $F('APPLY_ID') });
					commonTools.loadData(resp.rtnMap, resp.A241List, resp.A242VO, resp.A107List, resp.encryptAPPLY_ID, resp.A203List);
				},
				function(){
					commonTools.clearForm2();
					pageRtnMap.APPLY_ID = $F('APPLY_ID');
					
					<%--[20211018] 使用 InputUtility.js 調整成讓 CHORME textarea也能依照內容自動調整欄位高度--%>
					$$('textarea').each(function(e){	
						InputUtility.autoSizingTextarea.doAutoSize(e); //依內容調整高度
					});
				}
			);
		},
		
		//新增
		doInsert:function(){
			valid1.reset();
			valid2.reset();
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			if( !valid1.validate() ) {
	    		return;
	    	}
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}
			//A區檢核
			if( !valid1.validate() ) {
	    		return;
	    	}	
	    	
	    	//B~F區檢核
	    	$('PRICE_OTHER_DESC').show();
	    	$('VISIT_OTHER_DESC').show();
			if( !valid2.validate() ) {
	    		return;
	    	}	

	    	var params = commonTools.getParams();
			ajaxPost('insert',params,
				function(resp){
					commonTools.loadData(resp.rtnMap, resp.A241List, resp.A242VO, resp.A107List);
				}
			);
		},
		
		//修正,呈核
		doAction1:function(act){
			valid1.reset();
			valid2.reset();
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			if( !valid1.validate() ) {
	    		return;
	    	}
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}else if(v1 != v2){
				alert('欲作業的'+v2+'與原先查詢的'+v1+'不同,無法作業!');
				return;
			}
			//A區檢核
			if( !valid1.validate() ) {
	    		return;
	    	}	
			
			if('confirm'==act){
				valid2.clear();
				valid2.define( "required" , { id: "USE_AREA1" } );
				if(isURBAN_PROJECT){
					valid2.define( "required" , { id: "URBAN_PROJECT" } );	
				}
				<%-- [20231026]  231020023853 增加經緯度hidden欄位檢核 承作分區上線前置作業 --%>
				if (!$F('LONGITUDE') || !$F('LATITUDE')) {
					alert('座標不可為空，請進行環域分析');
					return;
				}
			}
	    	//B~F區檢核
	    	$('PRICE_OTHER_DESC').show();
	    	$('VISIT_OTHER_DESC').show();
			if( !valid2.validate() ) {
	    		return;
	    	}
			
	    	var params = commonTools.getParams();
			ajaxPost(act,params,
				function(resp){
					commonTools.loadData(resp.rtnMap, resp.A241List, resp.A242VO, resp.A107List);
				}
			);
		},
		
		
		//刪除
		doDelete:function(){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			valid1.reset();
			if( !valid1.validate() ) {
	    		return;
	    	}
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}else if(v1 != v2){
				alert('欲作業的'+v2+'與原先查詢的'+v1+'不同,無法作業!');
				return;
			}		
			if(!confirm('確定要刪除' + v1 + '之鑑價報告書資料？')){
				return;
			}
			ajaxPost('delete',{APPLY_ID: $F('APPLY_ID'),INPUT_ID:pageRtnMap.INPUT_ID},
				function(resp){
					commonTools.loadData(resp.rtnMap, resp.A241List, resp.A242VO, resp.A107List);
				}
			);
		},
		
		//組長覆核,科主管覆核作業確認訊息
		//[20211025] 　組長及主管批示與建議價格欄位數值不一致時出現提醒視窗
		doActionApproveCheck : function(act){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			valid1.reset();
			if( !valid1.validate() ) {
	    		return;
	    	}
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}else if(v1 != v2){
				alert('欲作業的'+v2+'與原先查詢的'+v1+'不同,無法作業!');
				return;
			}
			
			var paramMap = commonTools.getParams4Approve(act);
			
			//發送ajax
			new Ajax.Request( 
				"<%=dispatcher%>/DSA3_0700/" + act + "Check",
				{ parameters: paramMap,
		          onSuccess: function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						if (resp.ConfirmMSG == 'OK'){
							actions.doActionApprove(act);
						} else {
							var ConfirmMSG = resp.ConfirmMSG;
							if(ConfirmMSG){
								ConfirmMSG = ConfirmMSG.replace(/\\r|\\n|\\r\\n/g, "\n");
							}
							if(!confirm(ConfirmMSG)){
								return false;
							}
							actions.doActionApprove(act);
						}				
					}
		        }}
			);
			
		},
		
		//組長覆核,科主管覆核,部室主管覆核
		doActionApprove:function(act){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			valid1.reset();
			if( !valid1.validate() ) {
	    		return;
	    	}
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}else if(v1 != v2){
				alert('欲作業的'+v2+'與原先查詢的'+v1+'不同,無法作業!');
				return;
			}
			
	    	var params = commonTools.getParams4Approve(act);
			ajaxPost(act,params,
				function(resp){
					commonTools.loadData(resp.rtnMap, resp.A241List, resp.A242VO, resp.A107List);
				}
			);	
		},
		
		//組長退回,科主管退回,部室主管退回
		doActionReject:function(act){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			valid1.reset();
			if( !valid1.validate() ) {
	    		return;
	    	}
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}else if(v1 != v2){
				alert('欲作業的'+v2+'與原先查詢的'+v1+'不同,無法作業!');
				return;
			}	

			if (pageRtnMap.GM_DATE) {
				if(!confirm('確定要取消'+v1+ '之鑑價報告書覆核？')){
					return;
				}
				act='gmCancel';
			} else {
				if(!confirm('確定要退回'+v1+ '之鑑價報告書資料？')){
					return;
				}
				if (pageRtnMap.BOSS_DATE || act=='Reject') {
					act='bossReject';
				} else {
					act='captainReject';
				}
			}
			var params = commonTools.getParams4Reject(act);
			ajaxPost(act,params,
				function(resp){
					commonTools.loadData(resp.rtnMap, resp.A241List, resp.A242VO, resp.A107List);
				}
			);	
		},
		
		//報告重送
		doReSend : function(){
			
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			valid1.reset();
			if( !valid1.validate() ) {
	    		return;
	    	}
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}else if(v1 != v2){
				alert('欲作業的'+v2+'與原先查詢的'+v1+'不同,無法作業!');
				return;
			}	
			
			//發送ajax
			ajaxPost( 'reSend' , {'APPLY_ID' : $('APPLY_ID').value, MAP_AREA_CODE : $('MAP_AREA_CODE').value, AREA_CODE_930318 : $F('AREA_CODE_930318')} );
		},
		
		//取得鄰近設施資料
		doGetSpcDistance:function(){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			valid1.reset();
			if( !valid1.validate() ) {
	    		return;
	    	}
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}else if(v1 != v2){
				alert('欲作業的'+v2+'與原先查詢的'+v1+'不同,無法作業!');
				return;
			}	
			var inputMap = {APPLY_ID:v1 ,INPUT_ID:pageRtnMap.INPUT_ID};
	    
			ajaxPost('getSpcDistance',{inputMap:Object.toJSON(inputMap)},
				function(resp){
				
					var xyMap = resp.xyMap ? resp.xyMap : {};
					if(xyMap){
						$('LONGITUDE').setValue(noNull(xyMap.LONGITUDE));
						$('LATITUDE').setValue(noNull(xyMap.LATITUDE));
						//$('CONTROL_AREA').value=noNull(xyMap.CONTROL_AREA);
					}
					
					var SPC_DISTANCE = noNull(resp.SPC_DISTANCE);
					if(SPC_DISTANCE){
						var oldValue = $F('AREA_DESC');
						if(oldValue != ''){
							oldValue += '\n';
						}
						$('AREA_DESC').value = oldValue + noNull(resp.SPC_DISTANCE);
					}
				}
			);			
		},
		
		//鑑價影像檔               
		doGetFile:function(){
		
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			valid1.reset();
			if( !valid1.validate() ) {
	    		return;
	    	}
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}else if(v1 != v2){
				alert('欲作業的'+v2+'與原先查詢的'+v1+'不同,無法作業!');
				return;
			}
			
			var params = {};
			params.APPR_GROUP = pageRtnMap.APPR_GROUP;			
			if (pageRtnMap.APPR_APPLY_ID && pageRtnMap.APPR_APPLY_ID !=''){
				params.APPLY_ID = pageRtnMap.APPR_APPLY_ID;
			}else{
				params.APPLY_ID = pageRtnMap.APPLY_ID;
			}	
			
			//ajaxPost('getFile',params,
			//	function(resp){
			//		if(resp.apprPath && resp.apprPath!=''){
			//			var theAction = resp.apprPath;
			//			window.open(theAction);
			//			
			//		}else{
			//			alert('取得鑑價影像檔失敗');
			//		}
			//	}
			//);

			var successActionOpen = function(resp){
				if(resp.isExternal && resp.isApprExternalAuth) { //高級主管由外網登入開啟影像
					RPTUtil.download({'downloadFileName': resp.apprFileNM,	'downloadFileFullPath': resp.apprPath});
				} else {
					window.open(resp.apprPath);
				}
			};
			
			
			ajaxPost('getFile',params,successActionOpen);
		},
		
		//列印
		doPrint:function(event){
			<c:choose>
				<c:when test="${fromPublicBean eq 'DSA3_2400'}">var action = "DSA3_2400/print";</c:when>
				<c:otherwise>var action = "DSA3_0700/print";</c:otherwise>
			</c:choose>
			
			//[2019.05.24]START	列印前應先執行查詢
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}else if(v1 != v2){
				alert('欲作業的'+v2+'與原先查詢的'+v1+'不同,無法作業!');
				return;
			}
			//[2019.05.24]END
			
			new Ajax.Request( "<%=dispatcher%>/"+action, {
				parameters: { APPLY_ID : $F('encryptAPPLY_ID'), ActionType : '${ActionType}' , OP : '${OP}'},
				onSuccess:function(response){
					var resp = response.responseJSON;
					if(CSRUtil.isSuccess(resp)){
						RPTUtil.executePrintByResponse(resp, true);
					}
				}
			});
		},
		
		//電子地圖
		doElectronicMap:function(){
		
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			valid1.reset();
			if( !valid1.validate() ) {
	    		return;
	    	}
			var v1 = $F('APPLY_ID');
			var v2 = noNull(pageRtnMap.APPLY_ID);
			if(v2 == ''){
				alert('請先執行查詢!');
				return;			
			}else if(v1 != v2){
				alert('欲作業的'+v2+'與原先查詢的'+v1+'不同,無法作業!');
				return;
			}
			
			var XML = Object.toJSON( {'APPLY_ID' : $F('APPLY_ID'), 'GAGE_ADDR' : $F('GAGE_ADDR')} );
			
			//[20201223]調整判斷是否為銀行人員，若是則導至DSA3_2400
			<c:choose>
				<c:when test="${fromPublicBean eq 'DSA3_2400'}">		
					popupWin.windowOpen('<%=dispatcher%>/DSA3_2400/electronicMap',{
				    	'windowName': 'DSA3_1900',
		        		'parameters': {'CASE_NO' : $('APPLY_ID').value, 'CASE_TYPE' : 'DSA'},
		        		'fullScreen': true
		    		});		
				</c:when>
				<c:otherwise>
					 popupWin.windowOpen('<%=dispatcher%>/DSA3_1900/prompt',{
				    	'windowName': 'DSA3_1900',
		        		'parameters': {'CASE_NO' : $('APPLY_ID').value, 'CASE_TYPE' : 'DSA'},
		        		'fullScreen': true
		    		});
				</c:otherwise>
			</c:choose>
		},
		//[20201112] 修改件 立案單號:201106001527  連動產生「承作分區」19.1 讀取畫面資料: 19.1.1 C區.使用分區(USE_AREA1)、C區.都市計畫案(URBAN_PROJECT)、C區.GAGE_ZIP 
		doChgAREA_CODE : function(){
			ajaxPost('chgAREA_CODE',{'APPLY_ID':$F('APPLY_ID'),
									'USE_AREA1':$F('USE_AREA1'),
									'URBAN_PROJECT':$F('URBAN_PROJECT'),
									'GAGE_ZIP':$F('GAGE_ZIP')},
					function(resp){
						var rtnMap = resp.rtnMap;
						$('AREA_CODE').update(rtnMap.AREA_CODE_NM ? rtnMap.AREA_CODE_NM+'區' : '');
						$('AREA_CODE_930318').setValue(rtnMap.AREA_CODE_930318 || '');
						
						<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%>
						$('SUBMKT_ID').setValue(rtnMap.SUBMKT_ID ||'');
						$('SUBMKT_VERSION').setValue(rtnMap.SUBMKT_VERSION ||'');
						$('SUBMKT_NAME').setValue(rtnMap.SUBMKT_NAME ||'');
						$('AREA_CODE_MATCH_LEVEL').setValue(rtnMap.MATCH_LEVEL || (rtnMap.AREA_CODE_MATCH_LEVEL||''));
					}
			);	
		},
		//[20201112] 修改件 立案單號:201106001527 如果下拉選單選擇 如擬，複製欄位
		doCopyFtable : function(){
			var element = $(this);
			var value = element.getValue();
			var key = element.getAttribute('key');//BOSS or CAPT
			if(value == '1'){//如擬
				$w('MIN_STOREFRONT_PRICE MAX_STOREFRONT_PRICE MIN_HOUSE_PRICE MAX_HOUSE_PRICE MIN_2F_PRICE MAX_2F_PRICE MIN_LAND_PRICE MAX_LAND_PRICE MIN_BUILDING_COST MAX_BUILDING_COST TOTAL_SALE_PRICE').each(function(id){
					$(key+'_'+id).setValue($F(id));
				});
			}else{
				$w('MIN_STOREFRONT_PRICE MAX_STOREFRONT_PRICE MIN_HOUSE_PRICE MAX_HOUSE_PRICE MIN_2F_PRICE MAX_2F_PRICE MIN_LAND_PRICE MAX_LAND_PRICE MIN_BUILDING_COST MAX_BUILDING_COST TOTAL_SALE_PRICE').each(function(id){
					$(key+'_'+id).setValue('0');
				});
			}
		}
	};

	var blockControl = {
		//顯示/隱藏控制
		openArea:function(ele){
			if(ele.style.display != 'none'){
				ele.style.display = 'none';
			}else{
				ele.style.display = 'block';
			}
		}
		//[2019.05.24]START	補充說明區塊有資料就顯示
		,openAreaByValue:function(ele){
			if(ele.value){
				ele.style.display = 'block';
			}else{
				ele.style.display = 'none';
			}
		}
	};
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		//beanName = 'DSA3_2400'=='${fromPublicBean}' ? '${fromPublicBean}' : 'DSA3_0700';
		//actionName = 'DSA3_2400'=='${fromPublicBean}' ? 'queryByDSA3_0700' : actionName;
		//new Ajax.Request( "<%=dispatcher%>/"+beanName+"/" + actionName,	
		new Ajax.Request( "<%=dispatcher%>/DSA3_0700/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}
	
	//undefined,null 顯示''
	function noNull(v,v2){
		v2 = (v2==undefined)?'':v2;
		if(v == null || v == undefined){
			v=v2;
		}
		return v; 
	}
	
	//gridR1新增一列
	function addRow(objGrid,newRec){
		objGrid.addRecords(newRec);		
	}
    //gridR1新增評分
	function doAdd1(){
		var newRec = {
			PK_INDEX:'new'+ addIndex
			, RETURN_ITEM: '01'
			, NOTE:'01'
			
		};	
		addIndex++;		
		addRow(gridR1,newRec);					
	}			
	//gridR1刪除評分
    function doDeleteRow(objGrid,delIndex){
		var allRecs = objGrid.getAllRecords();
		var newList = [];
		allRecs.each(function(rec){
			 if(rec.PK_INDEX!=delIndex){
			 	newList.push(rec);
			 }
		});
		objGrid.load(newList);
	}
	
	
	// [20201203] 將List增加到清單中
	function appendGridtoList(list , target){
		//先清除
		var dataTable1 = $(target);
		var le = dataTable1.rows.length;
		if(target=='table_P1'){
			for( i = le ; i > 0 ; i--){
				dataTable1.deleteRow(i-1);
			}
		}else{
			for( i = le ; i > 2 ; i--){
				dataTable1.deleteRow(i-1);
			}
		}
		//批示歷程
		if(target=='table_P1' && list.length==0){
			insertString1 = "<tr>";
			insertString1 += "<td class='tbYellow' width='14%'>批示歷程</td>";
			insertString1 += "<td class='tbYellow2' width='14%'></td>";
			insertString1 += "<td class='tbYellow2'></td>";
			insertString1 += "</tr>";
			dataTable1.insert({	bottom:insertString1 });
		}
		
		if(target=='table_P1'){
			// 逐筆顯示list
			insertString1 = "";
			for(var mover=0; mover < list.length ; mover++) {
				var valMap = list[mover];
				if(target=='table_P1'){
					INPUT_DATE = valMap.INPUT_DATE ? Date.toInputROC(valMap.INPUT_DATE,'') : '';
					EMP_NAME = valMap.EMP_NAME ? valMap.EMP_NAME : '';
					CODE_NAME = valMap.CODE_NAME ? valMap.CODE_NAME : '';
					INPUT_DESC = valMap.INPUT_DESC ? valMap.INPUT_DESC : '';
					INPUT_TYPE = valMap.INPUT_TYPE ? valMap.INPUT_TYPE : '';
					if(mover==0){
						insertString1 += "<tr>";
						insertString1 += "<td class='tbYellow' rowspan='"+ list.length +"' width='14%'>批示歷程</td>";
						insertString1 += "<td class='tbYellow2' width='24%' style='font-family:EUDC'>" + INPUT_DATE + "　" + EMP_NAME + "　" + CODE_NAME + "</td>";<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						if('3'==INPUT_TYPE || '4'==INPUT_TYPE || '5'==INPUT_TYPE){
							insertString1 += "<td class='tbYellow2'><a href='#"+target+"_INPUT_DESC_VIEW_"+mover+"' onClick='DSA30500.doShowdiv_A203List_VIEW("+mover+",\""+target+"\")'>批示</a>：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto;'>" + INPUT_DESC + "</div></td>";
						}else{
							insertString1 += "<td class='tbYellow2'>批示：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto;'>" + INPUT_DESC + "</div></td>";
						}
						insertString1 += "</tr>";
					}else{
						insertString1 += "<tr class=tbBlue3>";
						insertString1 += "<td class='tbYellow2' style='font-family:EUDC'>" + INPUT_DATE + "　" + EMP_NAME + "　" + CODE_NAME + "</td>";<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						if('3'==INPUT_TYPE || '4'==INPUT_TYPE || '5'==INPUT_TYPE){
							insertString1 += "<td class='tbYellow2'><a href='#"+target+"_INPUT_DESC_VIEW_"+mover+"' onClick='DSA30500.doShowdiv_A203List_VIEW("+mover+",\""+target+"\")'>批示</a>：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto;'>" + INPUT_DESC + "</div></td>";
						}else{
							insertString1 += "<td class='tbYellow2'>批示：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto;'>" + INPUT_DESC + "</div></td>";
						}
						insertString1 += "</tr>";
					}
				}
			}
			dataTable1.insert({	bottom:insertString1 });
			<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			parseEUDC();
		}
	}
	
	var commonTools = {		
		//清空B~F區	
		clearForm2:function(){
			pageRtnMap = {};//清空頁面儲存資料
			
			$('form2').reset();
			$$('#form2 span').each(function(o){
				o.update('');
			});
			
			gridR1.load([]);
		},
		
		//載入資料
		loadData:function(rtnMap, A241List, A242VO, A107List, encryptAPPLY_ID, A203List){

			if(encryptAPPLY_ID){
				$('encryptAPPLY_ID').setValue(encryptAPPLY_ID);
			}

			rtnMap = rtnMap ? rtnMap : {};
			A241List = A241List ? A241List : [];
			A242VO = A242VO ? A242VO : {};
			
			//清空B~F區	
			commonTools.clearForm2();
		
			//儲存查詢rtnMap結果
			pageRtnMap = rtnMap;

			//區塊B
			$$('#tableB span').each(function(o){
				var value = noNull(rtnMap[o.id]);
				if(o.getAttribute('datatype') == 'ROCDate'){
					value = Date.toROC(value);
				}
				o.update(value);
			});
			
			//座標
			$('LONGITUDE').setValue(noNull(rtnMap.LONGITUDE)); 
			$('LATITUDE').setValue(noNull(rtnMap.LATITUDE));
			
			//新增都市計畫案 [20201112] 修改件 立案單號:201106001527
			var URBAN_PROJECT_LIST = rtnMap.URBAN_PROJECT_LIST || [];
			$('URBAN_PROJECT').options.length = 0;
			if(URBAN_PROJECT_LIST.length>0){
				isURBAN_PROJECT = true;
				$('URBAN_PROJECT').enable();
				$('URBAN_PROJECT').add(new Option('請選擇都市計畫案', ''));
				URBAN_PROJECT_LIST.each(function(map){
					$('URBAN_PROJECT').add(new Option(map.URBAN_PROJECT_NM, map.POST_CODE +'_'+ map.SER_NO));
				});		
				$('URBAN_PROJECT').setValue(rtnMap.URBAN_PROJECT);
			}else{
				isURBAN_PROJECT = false;
				$('URBAN_PROJECT').add(new Option('無', ''));
				$('URBAN_PROJECT').disable();
			}
			
			$('IS_GM').value = noNull(rtnMap.IS_GM);//鑑估總價
			$('IS_GM_checkbox').checked = noNull(rtnMap.IS_GM)=='1';//是否轉呈部室主管
			$('UPDATE_DATE').value = Date.toInputROC(noNull(rtnMap.UPDATE_DATE),'');//資料補全日期
			
			//區塊C
			$$('#tableC input','#tableC select').each(function(o){
				var value = noNull(rtnMap[o.name]);
				if(o.getAttribute('datatype') == 'ROCDate'){
					value = Date.toROC(value);
				}
				o.setValue(value);
			});		
			//[20201211]預設為0
			$('USE_AREA1').setValue(rtnMap.USE_AREA1 ? rtnMap.USE_AREA1 : '0');
			
			//承作分區 [20201112] 修改件 立案單號:201106001527
			$('AREA_CODE').update(rtnMap.AREA_CODE_NM ? rtnMap.AREA_CODE_NM+'區' : ''); //承作分區 [20201112] 修改件 立案單號:201106001527
			$('AREA_CODE_930318').setValue(rtnMap.AREA_CODE_930318 ? rtnMap.AREA_CODE_930318 : ''); //承作分區 [20201112] 修改件 立案單號:201106001527
			$('MAP_AREA_CODE').setValue(rtnMap.MAP_AREA_CODE ? rtnMap.MAP_AREA_CODE : '');
			<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%>
			$('SUBMKT_ID').setValue(rtnMap.SUBMKT_ID ||'');
			$('SUBMKT_VERSION').setValue(rtnMap.SUBMKT_VERSION ||'');
			$('SUBMKT_NAME').setValue(rtnMap.SUBMKT_NAME ||'');
			$('AREA_CODE_MATCH_LEVEL').setValue(rtnMap.MATCH_LEVEL ||'');
			
			//$('CONTROL_AREA').value=noNull(rtnMap.CONTROL_AREA);//管制區
			
			//區塊D
			$$('#tableD textarea').each(function(o){
				o.value = noNull(rtnMap[o.name]);
			});	
			
			//區塊E
			A241List.each(function(map){
				var key = map.KEY;
				$(key+'_1').value = noNull(map.COL_VAL1);
				$(key+'_2').value = noNull(map.COL_VAL2);
				$(key+'_3').value = noNull(map.COL_VAL3);
				$(key+'_4').value = noNull(map.COL_VAL4);
			});	
			$$('#tableE textarea').each(function(o){
				o.value = noNull(rtnMap[o.name]);
			});	
			
			//區塊F
			$$('#tableF input[datatype="number"]').each(function(o){
				var value = noNull(A242VO[o.name],'0');
				o.value = CSRUtil.$fmt(value,o.pattern,true);
			});
			$('IS_STOREFRONT').checked = noNull(A242VO.IS_STOREFRONT)=='1';
			$('IS_HOUSE').checked = noNull(A242VO.IS_HOUSE)=='1';
			$$('#tableF textarea').each(function(o){
				o.value = noNull(rtnMap[o.name]);
			});
			//區塊G [20201112] 修改件 立案單號:201106001527
			$$('#tableG input[datatype="number"]').each(function(o){
				var value = noNull(rtnMap[o.name],'0');
				o.value = CSRUtil.$fmt(value,o.pattern,true);
			});
			$$('#tableG textarea').each(function(o){
				o.value = noNull(rtnMap[o.name]);
			});
			
			$$('#tableG select').each(function(o){
				o.value = noNull(rtnMap[o.name]);
			});
			
			$$('#tableG span').each(function(o){
				var value = noNull(rtnMap[o.id]);
				if(o.getAttribute('datatype') == 'ROCDate'){
					value = Date.toROC(value);
				}
				o.update(value);
			});
			
			
			
			//[2019.05.24]START若有資訊及顯示該區塊
			//if ($('PRICE_OTHER_DESC').value != '') { 
				//blockControl.openArea($('PRICE_OTHER_DESC'));
			//}
			//if ($('VISIT_OTHER_DESC').value != '') { 
				//blockControl.openArea($('VISIT_OTHER_DESC'));
			//}
			
			blockControl.openAreaByValue($('PRICE_OTHER_DESC'));
			blockControl.openAreaByValue($('VISIT_OTHER_DESC'));
			//[2019.05.24]END
			
			//批示歷程
			A203List = A203List ? A203List : [];
			appendGridtoList(A203List, "table_P1");
			
			
			//gridR1 評分
			A107List = A107List ? A107List : [];
			addIndex = A107List.length;
			gridR1.load(A107List);
			
			//模擬textarea keyup動作
			$w('AREA_DESC TRAFFIC_DESC BUILD_TYPE MAIN_USE PARK_TYPE PUB_RATE CONSTRUCT_DESC OTHER_DESC VISIT_DESC VISIT_OTHER_DESC AGENT_DESC PRICE_DESC PRICE_OTHER_DESC').each( 
				function(id){
					$(id).simulate('keyup');
				}
			);
			
			<%--[20211018] 使用 InputUtility.js 調整成讓 CHORME textarea也能依照內容自動調整欄位高度--%>
			$$('textarea').each(function(e){	
				InputUtility.autoSizingTextarea.doAutoSize(e); //依內容調整高度
			});
		},
		
		//取得畫面輸入資料
		getParams:function(){
			var rtnMap = Object.clone(pageRtnMap);
			var A241List = [];
			var A242VO = {};
			rtnMap.LONGITUDE = $F('LONGITUDE'); //經度
			rtnMap.LATITUDE = $F('LATITUDE'); //緯度
			rtnMap.IS_GM = $F('IS_GM');
			rtnMap.UPDATE_DATE = toY2K($F('UPDATE_DATE'));//資料補全日期
			rtnMap.INPUT_APPLY_ID = $F('APPLY_ID');
			rtnMap.AREA_CODE_930318 = $F('AREA_CODE_930318');//承作分區
			<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%> 
			rtnMap.SUBMKT_ID = $F('SUBMKT_ID');
			rtnMap.SUBMKT_NAME = $F('SUBMKT_NAME');
			rtnMap.AREA_CODE_MATCH_LEVEL = $F('AREA_CODE_MATCH_LEVEL');
			
			//區塊C
			$$('#tableC input','#tableC select').each(function(o){
				var value = o.value;
				if(o.getAttribute('datatype') == 'ROCDate'){
					value = toY2K(value);
				}
				rtnMap[o.name] = value;
			});		
			//rtnMap.CONTROL_AREA = $F('CONTROL_AREA'); //管制區
			
			//區塊D
			$$('#tableD textarea').each(function(o){
				rtnMap[o.name] = o.value;
			});	
			
			//區塊E
			A241List.push(commonTools.createA241Map('1'));
			A241List.push(commonTools.createA241Map('2'));
			A241List.push(commonTools.createA241Map('3'));
			A241List.push(commonTools.createA241Map('4'));
			$$('#tableE textarea').each(function(o){
				rtnMap[o.name] = o.value;
			});	
			
			//區塊F
			$$('#tableF input[datatype="number"]').each(function(o){
				A242VO[o.name] = o.getValue();
			});
			A242VO.IS_STOREFRONT = $('IS_STOREFRONT').checked?'1':'0';
			A242VO.IS_HOUSE = $('IS_HOUSE').checked?'1':'0';
			$$('#tableF textarea').each(function(o){
				rtnMap[o.name] = o.value;
			});
			
			//區塊G [20201112] 修改件 立案單號:201106001527
			$$('#tableG input[datatype="number"]').each(function(o){
				rtnMap[o.name] = o.getValue();
			});
			$$('#tableG textarea').each(function(o){
				rtnMap[o.name] = o.value;
			});
			
			$$('#tableG select').each(function(o){
				rtnMap[o.name] = o.value;
			});
			
			var params = {rtnMap:Object.toJSON(rtnMap),A241List:Object.toJSON(A241List),A242VO:Object.toJSON(A242VO)};
			return 	params;	
		},
		
		createA241Map:function(index){
			var CASE_MAP = {};
			CASE_MAP.CASE_NO = ('0'+index);
			$$('#tableE input[case='+index+']').each(function(o){
				CASE_MAP[o.name] = o.value;
			});	
			
			return CASE_MAP;
		},
		
		//取得畫面輸入資料
		getParams4Approve:function(act){
			var inputMap = {};
			inputMap.APPLY_ID = pageRtnMap.APPLY_ID;
			inputMap.MAP_AREA_CODE = pageRtnMap.MAP_AREA_CODE;
			inputMap.AREA_CODE_930318 = pageRtnMap.AREA_CODE_930318;
			inputMap.IS_GM = $F('IS_GM');
			if(act == 'bossConfirm' || act == 'gmConfirm'){
				inputMap.CAPT_ID = pageRtnMap.CAPT_ID;
				if(act == 'gmConfirm'){
					inputMap.BOSS_ID = pageRtnMap.BOSS_ID;
				}
			}
			inputMap.A107List = gridR1.getAllRecords();
			var rtnMap = {};
			rtnMap['TOTAL_SALE_PRICE'] = $F('TOTAL_SALE_PRICE');
			if(act == 'captainConfirm'){
				rtnMap['CAPT_EXAM'] = $F('CAPT_EXAM');
				rtnMap['CAPT_EXAM_DESC'] = $F('CAPT_EXAM_DESC');
				$$('#tableG input[key="CAPT"]').each(function(o){
					rtnMap[o.name] = o.getValue();
				});
				inputMap['rtnMap'] = rtnMap;
			}
			else if(act == 'bossConfirm'){
				rtnMap['BOSS_EXAM'] = $F('BOSS_EXAM');
				rtnMap['BOSS_EXAM_DESC'] = $F('BOSS_EXAM_DESC');
				$$('#tableG input[key="BOSS"]').each(function(o){
					rtnMap[o.name] = o.getValue();
				});
				inputMap['rtnMap'] = rtnMap;
			}

			var params = {inputMap:Object.toJSON(inputMap)};
			if(act == 'gmConfirm'){ // [20201112] 修改件 立案單號:201106001527
				params['GM_EXAM_DESC'] = $F('GM_EXAM_DESC') || '';
			}
			return params;
		},
		
		getParams4Reject:function(act){
			var inputMap = {};
			inputMap.APPLY_ID = pageRtnMap.APPLY_ID;
			inputMap.A107List = gridR1.getAllRecords();
			var params = {inputMap:Object.toJSON(inputMap)};
			return params;
		}
	};

	return{                              
		initApp:function(){
			PageUI.createPage("DSA30700" , "鑑價作業" , "整批件鑑價報告輸入", false);
			PageUI.loadin(["form1","form2"] ,1);
			
			//gridR1下拉選單
			<c:if test='${not empty A3_QUALITY_LIST}'>
				<%--錯誤原因選單--%>
				A3_QUALITY_LIST = ${A3_QUALITY_LIST};
			</c:if>	
			
			<c:if test='${not empty A3_MEMO1_LIST}'>
				<%--錯誤說明(資料查證判讀)選單--%>
				A3_MEMO1_LIST = ${A3_MEMO1_LIST};
			</c:if>	
			
			<c:if test='${not empty A3_MEMO2_LIST}'>
				<%--錯誤說明(擔保品敘述)選單--%>
				A3_MEMO2_LIST = ${A3_MEMO2_LIST};
			</c:if>	
			
			<c:if test='${not empty A3_MEMO3_LIST}'>
				<%--錯誤說明(擔保品計算)選單--%>
				A3_MEMO3_LIST = ${A3_MEMO3_LIST};
			</c:if>	
			
			<c:if test='${not empty A3_MEMO4_LIST}'>
				<%--錯誤說明(影像圖檔製作)選單--%>
				A3_MEMO4_LIST = ${A3_MEMO4_LIST};
			</c:if>	
			
			<c:if test='${not empty A3_MEMO5_LIST}'>
				<%--錯誤說明(案例查證與計算)選單--%>
				A3_MEMO5_LIST = ${A3_MEMO5_LIST};
			</c:if>	
			
			<c:if test='${not empty A3_MEMO6_LIST}'>
				<%--錯誤說明(差異分析過程)選單--%>
				A3_MEMO6_LIST = ${A3_MEMO6_LIST};
			</c:if>	
			
			<c:if test='${not empty A3_MEMO7_LIST}'>
				<%--錯誤說明(綜合分析與比較)選單--%>
				A3_MEMO7_LIST = ${A3_MEMO7_LIST};
			</c:if>	
			
			<c:if test='${not empty A3_MEMO8_LIST}'>
				<%--錯誤說明(價格評估結論)選單--%>
				A3_MEMO8_LIST = ${A3_MEMO8_LIST};
			</c:if>	
			
			gridR1 = new TableUI ( {
				table: $("gridR1"), allSortable:false, overDiv:false, pageSize:0,
				
				column:[
				    {header:"錯誤原因", key:"RETURN_ITEM", attrs:{align:'left'},
				    	render : function (rec , val){
				    		//製作錯誤原因下拉選單
							var SELECT1 = new Element('SELECT' , {className : 'textBox2' , fieldName : '錯誤原因' });
							for (key in A3_QUALITY_LIST){
								SELECT1.add(new Option(A3_QUALITY_LIST[key], key));
							}

							//製作錯誤說明下拉選單
							var SELECT2 = new Element('SELECT' , {className : 'textBox2' , fieldName : '錯誤說明' });
							switch(val) {
										case '01':
											SELECT2.length = 0;
											for (key in A3_MEMO1_LIST){
												SELECT2.add(new Option(A3_MEMO1_LIST[key], key));
											}
											break;
										case '02':
											SELECT2.length = 0;
											for (key in A3_MEMO2_LIST){
												SELECT2.add(new Option(A3_MEMO2_LIST[key], key));
											}
											break;
										case '03':
											SELECT2.length = 0;
											for (key in A3_MEMO3_LIST){
												SELECT2.add(new Option(A3_MEMO3_LIST[key], key));
											}
											break;
										case '04':
											SELECT2.length = 0;
											for (key in A3_MEMO4_LIST){
												SELECT2.add(new Option(A3_MEMO4_LIST[key], key));
											}
											break;
										case '05':
											SELECT2.length = 0;
											for (key in A3_MEMO5_LIST){
												SELECT2.add(new Option(A3_MEMO5_LIST[key], key));
											}
											break;		
										case '06':
											SELECT2.length = 0;
											for (key in A3_MEMO6_LIST){
												SELECT2.add(new Option(A3_MEMO6_LIST[key], key));
											}
											break;	
										case '07':
											SELECT2.length = 0;
											for (key in A3_MEMO7_LIST){
												SELECT2.add(new Option(A3_MEMO7_LIST[key], key));
											}
											break;			
										case '08':
											SELECT2.length = 0;
											for (key in A3_MEMO8_LIST){
												SELECT2.add(new Option(A3_MEMO8_LIST[key], key));
											}
											break;																																																
							}		
							
							//註冊事件
							//如果改下拉選單，直接將錯誤說明內的值改掉
							SELECT1.observe('change' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || gridR1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									var targetValue = event.target.value;
									dataObj.RETURN_ITEM = targetValue;
									
									switch(targetValue) {
										case '01':
											SELECT2.length = 0;
											for (key in A3_MEMO1_LIST){
												SELECT2.add(new Option(A3_MEMO1_LIST[key], key));
											}
											break;
										case '02':
											SELECT2.length = 0;
											for (key in A3_MEMO2_LIST){
												SELECT2.add(new Option(A3_MEMO2_LIST[key], key));
											}
											break;
										case '03':
											SELECT2.length = 0;
											for (key in A3_MEMO3_LIST){
												SELECT2.add(new Option(A3_MEMO3_LIST[key], key));
											}
											break;
										case '04':
											SELECT2.length = 0;
											for (key in A3_MEMO4_LIST){
												SELECT2.add(new Option(A3_MEMO4_LIST[key], key));
											}
											break;
										case '05':
											SELECT2.length = 0;
											for (key in A3_MEMO5_LIST){
												SELECT2.add(new Option(A3_MEMO5_LIST[key], key));
											}
											break;		
										case '06':
											SELECT2.length = 0;
											for (key in A3_MEMO6_LIST){
												SELECT2.add(new Option(A3_MEMO6_LIST[key], key));
											}
											break;	
										case '07':
											SELECT2.length = 0;
											for (key in A3_MEMO7_LIST){
												SELECT2.add(new Option(A3_MEMO7_LIST[key], key));
											}
											break;			
										case '08':
											SELECT2.length = 0;
											for (key in A3_MEMO8_LIST){
												SELECT2.add(new Option(A3_MEMO8_LIST[key], key));
											}
											break;																																																	
									}																
								}
							);

							SELECT2.observe('change' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || gridR1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.NOTE = event.target.value;		
									SELECT2.value = event.target.value;										
								}
							);
							SELECT1.value = val;
							SELECT2.value = rec.NOTE;
							
							var SPAN = new Element('SPAN');
							SPAN.insert('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp原因 :&nbsp').insert(SELECT1).insert('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp說明 :&nbsp').insert(SELECT2);
							return SPAN;
				    	}		 	                       
				 	},
					{header:"刪除",key: "DEL_BTN",
				 	   input:{                                 
				 	         type:'button',text:"刪除評分"
				 	         ,action:function(node , dataObj , textDiv, orgData ){
				 	         	doDeleteRow(gridR1,dataObj[0].PK_INDEX);
				 	         }
				 	         ,genRule: function(record , value){
									return true;
								}                        
				 	   }                         
				 	} 
				],pageChange:function(pageNo){ 
					autoFormatToNumber();
				}
				
			});
			
			//按鈕顯示控制
			<c:choose>
				<c:when test='${OP eq 1}'> //輸入人員
				 	$('btn_div1').show();
				 	$('btn_div2').hide();
				 	$('tableG').style.display = 'none';
				 	$('table_R').style.display = 'none';
				</c:when>
				<c:otherwise> //覆核人員or 查詢人員 [20201203] block改成''解chrome table長不滿問題
				 	$('btn_div1').hide();
				 	$('btn_div2').show();
				 	$('tableG').style.display = '';
				 	$('table_R').style.display = '';
				</c:otherwise>
		   	</c:choose>	
			
			//銀行人員：按鈕不顯示
			if (${IS_BANK_USER}){
				$('APPLY_ID').readOnly = true;
				$('table_R').style.display = 'none';
				$('btn_div1').hide();
				$('btn_div2').hide();
				$$('input[type="button"]').each( 
					function(elem) {
						if(elem.id=='btn_print'){
							return;
						}
						elem.hide();
					}
				);
				//[20201203] 開放銀行人員可以查詢電子地圖
				$('btn_electronicMap').show();
			}
			
			<%-- [20230131]需求書230131003715 非放款鑑價部人員無法瀏覽相關欄位資訊--%>
			<c:if test="${showEXAM ne true}">
				$('table_P1').style.display = 'none';
			</c:if>
			 
			valid1 = new Validation("form1", { focusOnError:true, immediate:false });
			valid2 = new Validation("form2", { focusOnError:true, immediate:false });
			Validation.addAllThese([
				[ 'validateAPPLY_ID', '需為11碼',
					function(v){				
						return (v.length != 11) ? false : true ;
					}
				],
				[ 'validate1QUOTATION', '請勿輸入單引號',
					function(v){
						return (v.indexOf('\'') != -1) ? false : true ;
					}
				],
				
				[ 'validate1COMMA', '請勿輸入逗號',
					function(v){
						return (v.indexOf(',') != -1) ? false : true ;
					}
				]
			]);

			//查詢
			$('btn_query').observe('click',function(event){actions.doQuery();});
			
			//新增
			$('btn_insert').observe('click',function(event){actions.doInsert();});
			
			//修正
			$('btn_update').observe('click',function(event){actions.doAction1('update');});
			
			//刪除
			$('btn_delete').observe('click',function(event){actions.doDelete();});
			
			//呈核
			$('btn_confirm').observe('click',function(event){actions.doAction1('confirm');});
			
			//取消呈核
			$('btn_cancel').observe('click',function(event){actions.doAction1('cancel');});
			
			//組長覆核
			//$('btn_captainConfirm').observe('click',function(event){actions.doActionApprove('captainConfirm');});
			$('btn_captainConfirm').observe('click',function(event){actions.doActionApproveCheck('captainConfirm');});
			
			//組長退回
			$('btn_captainReject').observe('click',function(event){actions.doActionReject('captainReject');});
			
			//科主管覆核
			//$('btn_bossConfirm').observe('click',function(event){actions.doActionApprove('bossConfirm');});	
			$('btn_bossConfirm').observe('click',function(event){actions.doActionApproveCheck('bossConfirm');});		
			
			//部室主管覆核
			$('btn_gmConfirm').observe('click',function(event){actions.doActionApprove('gmConfirm');});	
					
			//主管退回覆核
			$('btn_Reject').observe('click',function(event){actions.doActionReject('Reject');});	

			//取得鄰近設施資料
			$('btn_getSpcDistance').observe('click',function(event){actions.doGetSpcDistance();});	
			
			//電子地圖
			$('btn_electronicMap').observe('click',function(event){actions.doElectronicMap();});	
			
			//列印
			$('btn_print').observe('click',function(event){actions.doPrint();});
			
			//報告重送
			$("btn_reSend").observe("click", actions.doReSend );	
			
			//說明 補充說明
			/*
			$('LINK_PRICE_OTHER').observe('click',function(event){                                        
				blockControl.openArea($('PRICE_OTHER_DESC'));					
			});
			*/ 
			
			//訪價資料比較分析 補充說明
			$('LINK_VISIT_OTHER').observe('click',function(event){                                        
				blockControl.openArea($('VISIT_OTHER_DESC'));					
			}); 
			
			<%--新增評分--%>
			$('btn_add_1').observe('click' , doAdd1);
			
			<%--[20201112] 修改件 立案單號:201106001527 使用分區 都市計畫案 連動承作分區 --%>
			$('USE_AREA1').observe('change',actions.doChgAREA_CODE);
			$('URBAN_PROJECT').observe('change',actions.doChgAREA_CODE);
			
			<%--[20201112] 修改件 立案單號:201106001527 批示下拉選單連動 --%>
			$('BOSS_EXAM').observe('change',actions.doCopyFtable);
			$('CAPT_EXAM').observe('change',actions.doCopyFtable);
			
				
			autoFormatToNumber();
			buttonAuth();
			displayMessage();
			<%--[20211018] 使用 InputUtility.js 調整成讓 CHORME textarea也能依照內容自動調整欄位高度--%>
			$$('textarea').each(function(e){	
				InputUtility.autoSizingTextarea.add(e); //註冊事件
			});
			
   			//抓取前端傳過來的值
			if ('${APPLY_ID}' == '') {
				//保留參數管理-取得受理編號
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			} else {
				$('APPLY_ID').value = '${APPLY_ID}';
			}

			if($F('APPLY_ID')!=''){
				var isbeanName = 'DSA3_2400'=='${fromPublicBean}' ? true : false;
				if(isbeanName){
					$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
					//保留參數管理-更新受理編號
					var rtnMap = <c:choose><c:when test="${not empty rtnMap}">${rtnMap}</c:when><c:otherwise>{}</c:otherwise></c:choose>;
					var A241List = <c:choose><c:when test="${not empty A241List}">${A241List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A242VO = <c:choose><c:when test="${not empty A242VO}">${A242VO}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A203List = <c:choose><c:when test="${not empty A203List}">${A203List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					CSRUtil.keepParamsManager.put({'APPLY_ID': $F('APPLY_ID') });
					commonTools.loadData(rtnMap, A241List, A242VO, null, null,A203List);
				}else{
					actions.doQuery();
				}
			}
		} ,
		doGetFile : actions.doGetFile               
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<form id="form1" name="form1" method="post">	
<!------------------------ A區--------------------->			
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
				<tr>
					<td class="tbYellow" width="12%" >受理編號</td>
					<td class="tbYellow2" width="24%">
						<input id="APPLY_ID" name="APPLY_ID" type="text" value="${param.APPLY_ID}" fieldName="受理編號" class="textBox2 required validateAPPLY_ID checkInputLength" size="13" maxlength="11" />
						<input id="encryptAPPLY_ID" name="encryptAPPLY_ID" type="hidden" value="${encryptAPPLY_ID}"/>
						<input type="hidden" id="LONGITUDE" name="LONGITUDE" class ="rtnMap" value="">
						<input type="hidden" id="LATITUDE" name="LATITUDE" class ="rtnMap" value="">
						<input type="hidden" id="MAP_AREA_CODE" name="MAP_AREA_CODE" class ="rtnMap" value="">
					</td>
					<td class="tbYellow2" align="center">
						<input id="btn_query" type="button" class="button" value="查詢" />
						<input id="btn_print" type="button" class="button" value="列印" />
						<input id="btn_electronicMap" type="button" class="button" value="(1)電子地圖">
					</td>
				</tr>
				<tr id="btn_div1">
					<td align="center" colspan="3">
						<input id="btn_insert" type="button" class="button" value="新增" />
						<input id="btn_delete" type="button" class="button" value="刪除" />
						<input id="btn_update" type="button" class="button" value="修正" />
						<input id="btn_confirm" type="button" class="button" value="呈核" />
						<input id="btn_cancel" type="button" class="button" value="取消呈核" />
						<img style="cursor: hand;" src="<%=imageBase%>/DS/star5.gif" border=0 onClick="DSA30700.doGetFile()">
					</td>
				</tr>
				<tr id="btn_div2">
					<td align="center" colspan="3">
						<input id="btn_captainConfirm" type="button" class="button" value="組長覆核" />
						<input id="btn_captainReject" type="button" class="button" value="組長退回" />
						<input id="btn_bossConfirm" type="button" class="button" value="科主管覆核" />
						<input id="btn_gmConfirm" type="button" class="button" value="部室主管覆核" />
						<input id="btn_Reject" type="button" class="button" value="主管退回覆核" />
						<input id="btn_reSend" type="button" class="button" value="報告重送">
						<img style="cursor: hand;" src="<%=imageBase%>/DS/star5.gif" border=0 onClick="DSA30700.doGetFile()">																			
					</td>
				</tr>
			</table>
	</form>	
	<form id="form2" name="form2" method="post">	
<!------------------------ B區--------------------->		
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">
	 			<tr>
	 				<td class="tbYellow" width="12%" >鑑價單位</td><td class="tbYellow2" width="13%"><span id="APPR_DEPT_NM"></span></td>
	 				<td class="tbYellow" width="12%" >受理日期</td><td class="tbYellow2" width="13%"><span id="SEND_DATE" datatype="ROCDate"></span></td>
                    <td class="tbYellow" width="12%" >鑑估總價</td>
                    <td class="tbYellow2" width="13%" >
						<select name="IS_GM" id="IS_GM" class="textBox2 validate-selection" fieldName="鑑估總價">
							<option value=""></option>
							<c:forEach var="map" items="${IS_GM_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select>
					</td>
					<td class="tbYellow" width="15%" >是否轉呈部室主管</td><td class="tbYellow2" width="10%"><input id="IS_GM_checkbox" name="IS_GM_checkbox" type="checkbox" class="textBox2" value="1" /></td>
	 			</tr>
	 			<tr>
	 				<td class="tbYellow" >目前呈核進度</td><td class="tbYellow2"><span id=APPR_PROCESS_NM></span></td>
	 				<td class="tbYellow" >資料補全日期</td>
					<td class="tbYellow2"> 
						<input type="text" datatype="ROCDate" fieldName="鑑價日期(起)" class="textBox2 validate-ROCDate" size="8" maxlength="7" name="UPDATE_DATE" id="UPDATE_DATE" />
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('UPDATE_DATE'))">
					</td>
					<td class="tbYellow" >代理人</td><td class="tbYellow2"><span id="AGENCY_NAME" style='font-family:EUDC'></span></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<td class="tbYellow" >承作分區</td><td class="tbYellow2"><span id="AREA_CODE"/></span>
						<input type="hidden" id="AREA_CODE_930318" name="AREA_CODE_930318" class ="rtnMap" value=""><!-- [20201112] 修改件 立案單號:201106001527 -->
					</td>
				</tr>
				<tr>
					<td class="tbYellow" >部室主管</td><td class="tbYellow2"><span id="GM_NM" style='font-family:EUDC'></span></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<td class="tbYellow" >科主管</td><td class="tbYellow2"><span id="BOSS_NM" style='font-family:EUDC'></span></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<td class="tbYellow" >組長</td><td class="tbYellow2"><span id="CAPT_NM" style='font-family:EUDC'></span></td>	<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<td class="tbYellow" >鑑價人員</td><td class="tbYellow2"><span id="APPR_NM" style='font-family:EUDC'></span></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</tr>
				<tr>
					<td class="tbYellow" >部室主管覆核日期</td><td class="tbYellow2"><span id="GM_DATE" datatype="ROCDate"></span></td>
					<td class="tbYellow" >科主管覆核日期</td><td class="tbYellow2"><span id="BOSS_DATE" datatype="ROCDate"></span></td>	
					<td class="tbYellow" >組長覆核日期</td><td class="tbYellow2"><span id="CAPT_DATE" datatype="ROCDate"></span></td>	
					<td class="tbYellow" >鑑價人員呈核日期</td><td class="tbYellow2"><span id="APPR_DATE" datatype="ROCDate" ></span></td>	
				</tr>
			</table>
<!------------------------ C區--------------------->		
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableC">
				<tr><td class="tbYellow0" align="center" colspan="2"><div style="font-weight: bold;">壹、標的基本資料</div></td></tr>
	 			<tr>
	 				<td class="tbYellow" width="12%" >一.建商名稱</td>
	 				<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
	 				<td class="tbYellow2"><input id="BORROW_NAME" name="BORROW_NAME" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="25" maxlength="60" fieldName="建商名稱" alt="ch"/></td>
	 			</tr>
	 			<tr>
	 				<td class="tbYellow">二.建案名稱</td>
	 				<td class="tbYellow2"><input id="CASE_NAME" name="CASE_NAME" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="25" maxlength="40" fieldName="建案名稱" /></td>
	 			</tr>
	 			<tr>
	 				<td class="tbYellow">三.建案地址</td>
	 				<td class="tbYellow2">
	 				<input type="hidden" id="GAGE_ZIP" name="GAGE_ZIP" class ="rtnMap" value=""><!-- [20201112] 修改件 立案單號:201106001527 -->
	 				<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
	 				<input id="GAGE_ADDR" name="GAGE_ADDR" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="25"  maxlength="200" fieldName="建案地址" alt="ch" />&nbsp;&nbsp;&nbsp;
			 			<!--
			 			管制區 
						<select id="CONTROL_AREA">
					       	<c:forEach var="map" items="${CONTROL_AREA_LIST}">
								<option value='${map.key}'>${map.value}</option>
					       	</c:forEach>
						</select> 
						-->
					</td>
	 			</tr>
	 			<tr>
	 				<td class="tbYellow" rowSpan="2">四.推案內容</td>
	 				<td class="tbYellow2">
	 				總戶數<input id="HOUSE_NO" name="HOUSE_NO" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="40" size="10" fieldName="總戶數" />
	 				&nbsp; 可銷售戶數<input id="CAN_SALE_NO" name="CAN_SALE_NO" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="40" size="10" fieldName="可銷售戶數" />
	 				&nbsp; 銷售戶數<input id="SALE_NO" name="SALE_NO" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="40" size="10" fieldName="銷售戶數" />
	 				&nbsp; 銷售率<input id="SALE_RATE" name="SALE_RATE" type="text"  class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="40" size="10" fieldName="銷售率" />	 				
	 				</td>
	 			</tr>
	 			<tr>
	 				<td class="tbYellow2">
						推案日<input type="text" name="SALE_DATE" id="SALE_DATE" fieldName="推案日" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="40" size="10"/>
						&nbsp; 交屋日<input type="text"  name="FINIST_DATE" id="FINIST_DATE" fieldName="交屋日" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="40" size="10"/>
						&nbsp; 施工進度<input id="BUILD_PROCESS" name="BUILD_PROCESS" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="40" size="10" fieldName="施工進度" />	 				
	 				</td>
	 			</tr>
	 			<tr>
	 				<td class="tbYellow">五.使用分區</td>
	 				<td class="tbYellow2">
	 					<select name="USE_AREA1" id="USE_AREA1" class="textBox2 validate-selection" fieldName="使用分區1">
							<c:forEach var="map" items="${USE_AREA1_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select>
						<input id="USE_AREA2" name="USE_AREA2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="10" size="10" fieldName="使用分區2" />	
	 				</td>
	 			</tr>
	 			<tr>
	 				<td class="tbYellow">六.都市計畫案</td>
	 				<td class="tbYellow2">
	 					<select name="URBAN_PROJECT" id="URBAN_PROJECT" class="textBox2" fieldName="都市計畫案">
	 						<option value="">無</option>
						</select>
	 				</td>
	 			</tr>
	 			<tr>
	 				<td class="tbYellow">七.生活圈</td>
	 				<td class="tbYellow2">
						<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%>
						<input type="text" id="SUBMKT_NAME" name="SUBMKT_NAME" readonly size="42"></input>
						<input type="hidden" id="SUBMKT_ID" name="SUBMKT_ID"></input>
						<input type="hidden" id="SUBMKT_VERSION" name="SUBMKT_VERSION"></input>
						<input type="hidden" id="AREA_CODE_MATCH_LEVEL" name="AREA_CODE_MATCH_LEVEL"></input>
	 				</td>
	 			</tr>
			</table>
<!------------------------ D區--------------------->			
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableD">
				<tr><td class="tbYellow0" align="center" colspan="2"><div style="font-weight: bold;">貳、區域環境與擔保品狀況<input id="btn_getSpcDistance" type="button" class="button" value="(2)環域分析" /></div></td></tr>
	 			<tr>
	 				<td class="tbYellow" width="15%">一.區域環境 </td>
	 				<td class="tbYellow2"  width="85%">
	 				<textarea id="AREA_DESC" name="AREA_DESC" fieldName="區域環境" rows="3" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
				</tr>
				<tr>
	 				<td class="tbYellow" >二.交通狀況</td>
	 				<td class="tbYellow2">
	 				<textarea id="TRAFFIC_DESC" name="TRAFFIC_DESC" fieldName="交通狀況" rows="3" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
				</tr>
				<tr>
	 				<td class="tbYellow" >三.產品型態</td>
	 				<td class="tbYellow2">
	 				<textarea id="BUILD_TYPE" name="BUILD_TYPE" fieldName="產品型態" rows="9" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="3000" onkeyup="if(this.scrollHeight > 120) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
	 			</tr>
				<tr>
	 				<td class="tbYellow" >四.主要用途</td>
	 				<td class="tbYellow2">
	 				<textarea id="MAIN_USE" name="MAIN_USE" fieldName="主要用途" rows="3" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
				</tr>
				<tr>
	 				<td class="tbYellow" >五.車位型態</td>
	 				<td class="tbYellow2">
	 				<textarea id="PARK_TYPE" name="PARK_TYPE" fieldName="車位型態" rows="3" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
				</tr>
				<tr>
	 				<td class="tbYellow" >六.公設比</td>
	 				<td class="tbYellow2">
	 				<textarea id="PUB_RATE" name="PUB_RATE" fieldName="公設比" rows="3" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
				</tr>		
				<tr>
	 				<td class="tbYellow" >七.結構體完成狀況</td>
	 				<td class="tbYellow2">
	 				<textarea id="CONSTRUCT_DESC" name="CONSTRUCT_DESC" fieldName="結構體完成狀況" rows="3" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
				</tr>	
				<tr>
	 				<td class="tbYellow" >八.其他</td>
	 				<td class="tbYellow2">
	 				<textarea id="OTHER_DESC" name="OTHER_DESC" fieldName="其他" rows="3" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
				</tr>
			</table>
<!------------------------ E區--------------------->			
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableE">
				<tr><td class="tbYellow0" align="center" colspan="5"><div style="font-weight: bold;">參、價格評估</div></td></tr>
				<tr><td class="tbYellow" colspan="5">(一)、整批市調案例</td></tr>
				<tr class="tbBlue" align="center"><td  width="12%">項目</td><td width="22%">案例甲</td><td width="22%">案例乙</td><td width="22%">案例丙</td><td width="22%">案例丁</td></tr>
				<tr class="tbBlue3" align="center">
					<td class="tbYellow" align="left">案例名稱</td>
					<td><input id="CASE_NAME_1" name="CASE_NAME" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-案例名稱" /></td>	
					<td><input id="CASE_NAME_2" name="CASE_NAME" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-案例名稱" /></td>	
					<td><input id="CASE_NAME_3" name="CASE_NAME" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-案例名稱" /></td>	
					<td><input id="CASE_NAME_4" name="CASE_NAME" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-案例名稱" /></td>	
				</tr>
				<tr class="tbYellow2" align="center">
					<td class="tbYellow" align="left">基地座落</td>
					<td><input id="BASE_DESC_1" name="BASE_DESC" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-基地座落" alt="ch"/></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<td><input id="BASE_DESC_2" name="BASE_DESC" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-基地座落" alt="ch"/></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<td><input id="BASE_DESC_3" name="BASE_DESC" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-基地座落" alt="ch"/></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<td><input id="BASE_DESC_4" name="BASE_DESC" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-基地座落" alt="ch"/></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</tr>
				<tr class="tbBlue3" align="center">
					<td class="tbYellow" align="left">案例來源</td>
					<td><input id="CASE_SOURCE_1" name="CASE_SOURCE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-案例來源" /></td>	
					<td><input id="CASE_SOURCE_2" name="CASE_SOURCE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-案例來源" /></td>	
					<td><input id="CASE_SOURCE_3" name="CASE_SOURCE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-案例來源" /></td>	
					<td><input id="CASE_SOURCE_4" name="CASE_SOURCE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-案例來源" /></td>	
				</tr>
				<tr class="tbYellow2" align="center">
					<td class="tbYellow" align="left">價格日期</td>
					<td><input id="PRICE_DATE_1" name="PRICE_DATE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-價格日期" /></td>	
					<td><input id="PRICE_DATE_2" name="PRICE_DATE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-價格日期" /></td>	
					<td><input id="PRICE_DATE_3" name="PRICE_DATE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-價格日期" /></td>	
					<td><input id="PRICE_DATE_4" name="PRICE_DATE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-價格日期" /></td>	
				</tr>
				<tr class="tbBlue3" align="center">
					<td class="tbYellow" align="left">產品型態</td>
					<td><input id="PRODUCT_TYPE_1" name="PRODUCT_TYPE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-產品型態" /></td>	
					<td><input id="PRODUCT_TYPE_2" name="PRODUCT_TYPE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-產品型態" /></td>	
					<td><input id="PRODUCT_TYPE_3" name="PRODUCT_TYPE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-產品型態" /></td>	
					<td><input id="PRODUCT_TYPE_4" name="PRODUCT_TYPE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-產品型態" /></td>	
				</tr>
				<tr class="tbYellow2" align="center">
					<td class="tbYellow" align="left">總樓層</td>
					<td><input id="FLOOR_1" name="FLOOR" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-總樓層" /></td>	
					<td><input id="FLOOR_2" name="FLOOR" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-總樓層" /></td>	
					<td><input id="FLOOR_3" name="FLOOR" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-總樓層" /></td>	
					<td><input id="FLOOR_4" name="FLOOR" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-總樓層" /></td>	
				</tr>
				<tr class="tbBlue3" align="center">
					<td class="tbYellow" align="left">屋齡</td>
					<td><input id="BUILD_AGE_1" name="BUILD_AGE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-屋齡" /></td>	
					<td><input id="BUILD_AGE_2" name="BUILD_AGE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-屋齡" /></td>	
					<td><input id="BUILD_AGE_3" name="BUILD_AGE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-屋齡" /></td>	
					<td><input id="BUILD_AGE_4" name="BUILD_AGE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-屋齡" /></td>	
				</tr>
				<tr class="tbYellow2" align="center">
					<td class="tbYellow" align="left">主力坪數</td>
					<td><input id="MAIN_SPACE_1" name="MAIN_SPACE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-主力坪數" /></td>	
					<td><input id="MAIN_SPACE_2" name="MAIN_SPACE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-主力坪數" /></td>	
					<td><input id="MAIN_SPACE_3" name="MAIN_SPACE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-主力坪數" /></td>	
					<td><input id="MAIN_SPACE_4" name="MAIN_SPACE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-主力坪數" /></td>	
				</tr>
				<tr class="tbBlue3" align="center">
					<td class="tbYellow" align="left">1F開價</td>
					<td><input id="FIRST_LISTPRICE_1" name="FIRST_LISTPRICE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-1F開價" /></td>	
					<td><input id="FIRST_LISTPRICE_2" name="FIRST_LISTPRICE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-1F開價" /></td>	
					<td><input id="FIRST_LISTPRICE_3" name="FIRST_LISTPRICE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-1F開價" /></td>	
					<td><input id="FIRST_LISTPRICE_4" name="FIRST_LISTPRICE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-1F開價" /></td>	
				</tr>
				<tr class="tbYellow2" align="center">
					<td class="tbYellow" align="left">1F成交價</td>
					<td><input id="FIRST_DEALPRICE_1" name="FIRST_DEALPRICE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-1F成交價" /></td>	
					<td><input id="FIRST_DEALPRICE_2" name="FIRST_DEALPRICE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-1F成交價" /></td>	
					<td><input id="FIRST_DEALPRICE_3" name="FIRST_DEALPRICE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-1F成交價" /></td>	
					<td><input id="FIRST_DEALPRICE_4" name="FIRST_DEALPRICE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-1F成交價" /></td>	
				</tr>
				<tr class="tbBlue3" align="center">
					<td class="tbYellow" align="left">樓上開價</td>
					<td><input id="ABOVE_LISTPRICE_1" name="ABOVE_LISTPRICE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-樓上開價" /></td>	
					<td><input id="ABOVE_LISTPRICE_2" name="ABOVE_LISTPRICE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-樓上開價" /></td>	
					<td><input id="ABOVE_LISTPRICE_3" name="ABOVE_LISTPRICE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-樓上開價" /></td>	
					<td><input id="ABOVE_LISTPRICE_4" name="ABOVE_LISTPRICE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-樓上開價" /></td>	
				</tr>
				<tr class="tbYellow2" align="center">
					<td class="tbYellow" align="left">樓上成交價</td>
					<td><input id="ABOVE_DEALPRICE_1" name="ABOVE_DEALPRICE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-樓上成交價" /></td>	
					<td><input id="ABOVE_DEALPRICE_2" name="ABOVE_DEALPRICE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-樓上成交價" /></td>	
					<td><input id="ABOVE_DEALPRICE_3" name="ABOVE_DEALPRICE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-樓上成交價" /></td>	
					<td><input id="ABOVE_DEALPRICE_4" name="ABOVE_DEALPRICE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-樓上成交價" /></td>	
				</tr>
				<tr class="tbBlue3" align="center">
					<td class="tbYellow" align="left">透天總價</td>
					<td><input id="TOTAL_PRICE_1" name="TOTAL_PRICE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-透天總價" /></td>	
					<td><input id="TOTAL_PRICE_2" name="TOTAL_PRICE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-透天總價" /></td>	
					<td><input id="TOTAL_PRICE_3" name="TOTAL_PRICE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-透天總價" /></td>	
					<td><input id="TOTAL_PRICE_4" name="TOTAL_PRICE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-透天總價" /></td>	
				</tr>
				<tr class="tbYellow2" align="center">
					<td class="tbYellow" align="left">透天土地單價</td>
					<td><input id="LAND_PERPRICE_1" name="LAND_PERPRICE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-透天土地單價" /></td>	
					<td><input id="LAND_PERPRICE_2" name="LAND_PERPRICE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-透天土地單價" /></td>	
					<td><input id="LAND_PERPRICE_3" name="LAND_PERPRICE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-透天土地單價" /></td>	
					<td><input id="LAND_PERPRICE_4" name="LAND_PERPRICE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-透天土地單價" /></td>	
				</tr>
				<tr class="tbBlue3" align="center">
					<td class="tbYellow" align="left">透天建坪單價</td>
					<td><input id="BUILD_PERPRICE_1" name="BUILD_PERPRICE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-透天建坪單價" /></td>	
					<td><input id="BUILD_PERPRICE_2" name="BUILD_PERPRICE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-透天建坪單價" /></td>	
					<td><input id="BUILD_PERPRICE_3" name="BUILD_PERPRICE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-透天建坪單價" /></td>	
					<td><input id="BUILD_PERPRICE_4" name="BUILD_PERPRICE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-透天建坪單價" /></td>	
				</tr>
				<tr class="tbYellow2" align="center">
					<td class="tbYellow" align="left">車位價</td>
					<td><input id="PARK_PRICE_1" name="PARK_PRICE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-車位價" /></td>	
					<td><input id="PARK_PRICE_2" name="PARK_PRICE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-車位價" /></td>	
					<td><input id="PARK_PRICE_3" name="PARK_PRICE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-車位價" /></td>	
					<td><input id="PARK_PRICE_4" name="PARK_PRICE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-車位價" /></td>	
				</tr>
				<tr class="tbBlue3" align="center">
					<td class="tbYellow" align="left">銷售率</td>
					<td><input id="SALE_RATE_1" name="SALE_RATE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-銷售率" /></td>	
					<td><input id="SALE_RATE_2" name="SALE_RATE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-銷售率" /></td>	
					<td><input id="SALE_RATE_3" name="SALE_RATE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-銷售率" /></td>	
					<td><input id="SALE_RATE_4" name="SALE_RATE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-銷售率" /></td>	
				</tr>
				<tr class="tbYellow2" align="center">
					<td class="tbYellow" align="left">公設比</td>
					<td><input id="PUB_RATE_1" name="PUB_RATE" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-公設比" /></td>	
					<td><input id="PUB_RATE_2" name="PUB_RATE" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-公設比" /></td>	
					<td><input id="PUB_RATE_3" name="PUB_RATE" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-公設比" /></td>	
					<td><input id="PUB_RATE_4" name="PUB_RATE" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-公設比" /></td>	
				</tr>
				<tr class="tbBlue3" align="center">
					<td class="tbYellow" align="left">公設設施</td>
					<td><input id="PUBLIC_INST_1" name="PUBLIC_INST" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-公設設施" /></td>	
					<td><input id="PUBLIC_INST_2" name="PUBLIC_INST" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-公設設施" /></td>	
					<td><input id="PUBLIC_INST_3" name="PUBLIC_INST" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-公設設施" /></td>	
					<td><input id="PUBLIC_INST_4" name="PUBLIC_INST" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-公設設施" /></td>	
				</tr>
				<tr class="tbYellow2" align="center">
					<td class="tbYellow" align="left">其他</td>
					<td><input id="OTHER_1" name="OTHER" case="1" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例甲-其他" /></td>	
					<td><input id="OTHER_2" name="OTHER" case="2" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例乙-其他" /></td>	
					<td><input id="OTHER_3" name="OTHER" case="3" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丙-其他" /></td>	
					<td><input id="OTHER_4" name="OTHER" case="4" type="text" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" size="20" maxlength="100" fieldName="案例丁-其他" /></td>	
				</tr>
				<tr><td class="tbYellow" colspan="5">(二)、訪價資料比較分析<a href="#VISIT_OTHER_DESC"  id="LINK_VISIT_OTHER">補充說明</a></td></tr>
				<tr>
	 				<td class="tbYellow2" colspan="5">
	 				<textarea id="VISIT_DESC" name="VISIT_DESC" fieldName="訪價資料比較分析" rows="9" cols="115" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="4000" onkeyup="if(this.scrollHeight > 120) this.style.posHeight=this.scrollHeight"></textarea>
	 				<br><textarea style="{display:none;}" id="VISIT_OTHER_DESC" name="VISIT_OTHER_DESC" fieldName="訪價資料比較分析補充說明" rows="9" cols="115" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="2000" onkeyup="if(this.scrollHeight > 120) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
	 			</tr>
				<tr><td class="tbYellow" colspan="5">(三)、仲介行情</td></tr>
				<tr>
	 				<td class="tbYellow2" colspan="5">
	 				<textarea id="AGENT_DESC" name="AGENT_DESC" fieldName="仲介行情" rows="6" cols="115" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300" onkeyup="if(this.scrollHeight > 100) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
	 			</tr>
			</table>							
<!------------------------ F區--------------------->	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableF">
				<tr><td class="tbYellow0" align="center" colspan="2"><div style="font-weight: bold;">肆、建議價格</div></td></tr>
				<tr><td class="tbYellow">一、價格概要</td></tr>
				<tr>
	 				<td class="tbYellow2">
	 				一樓店面區間價<input id="MIN_STOREFRONT_PRICE" name="MIN_STOREFRONT_PRICE" action="copy" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="一樓店面區間價起" value="0"/>萬∕坪
	 				~<input id="MAX_STOREFRONT_PRICE" name="MAX_STOREFRONT_PRICE" action="copy" type="text" datatype="number" pattern="#,###.###"" class="textBox2" size="10" fieldName="一樓店面區間價迄" value="0"/>萬∕坪
	 				<input id="IS_STOREFRONT" name="IS_STOREFRONT" type="checkbox" class="textBox2" value="1" />本區無此產品
	 				</td>
				</tr>
				<tr>
	 				<td class="tbYellow2">
	 				一樓住家區間價<input id="MIN_HOUSE_PRICE" name="MIN_HOUSE_PRICE" action="copy" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="一樓住家區間價起" value="0"/>萬∕坪
	 				~<input id="MAX_HOUSE_PRICE" name="MAX_HOUSE_PRICE" action="copy" type="text" datatype="number" pattern="#,###.###"" class="textBox2" size="10" fieldName="一樓住家區間價迄" value="0"/>萬∕坪
	 				<input id="IS_HOUSE" name="IS_HOUSE" type="checkbox" class="textBox2" value="1" />本區無此產品
	 				</td>
				</tr>
				<tr>
	 				<td class="tbYellow2">
	 				二樓以上區間價<input id="MIN_2F_PRICE" name="MIN_2F_PRICE" action="copy" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="二樓以上區間價起" value="0"/>萬∕坪
	 				~<input id="MAX_2F_PRICE" name="MAX_2F_PRICE" action="copy" type="text" datatype="number" pattern="#,###.###"" class="textBox2" size="10" fieldName="二樓以上區間價迄" value="0"/>萬∕坪
	 				</td>
				</tr>
				<tr>
	 				<td class="tbYellow2">總戶數<input id="TOTAL_FAMILY_CNT" name="TOTAL_FAMILY_CNT" action="copy" type="text" datatype="number" pattern="#,###" class="textBox2 validate-digits" size="10" fieldName="總戶數" value="0"/>戶</td>
	 			</tr>
				<tr>
	 				<td class="tbYellow2">總坪數約<input id="TOTAL_LEVEL_GROUND" name="TOTAL_LEVEL_GROUND" action="copy" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="總坪數約" value="0"/>坪</td>
	 			</tr>
				<tr>
	 				<td class="tbYellow2">
	 				地價區間價<input id="MIN_LAND_PRICE" name="MIN_LAND_PRICE" action="copy" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="地價區間價起" value="0"/>萬∕坪
	 				~<input id="MAX_LAND_PRICE" name="MAX_LAND_PRICE" action="copy" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="地價區間價迄" value="0"/>萬∕坪
	 				</td>
				<tr>
	 				<td class="tbYellow2">
	 				造價區間價<input id="MIN_BUILDING_COST" name="MIN_BUILDING_COST" action="copy" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="造價區間價起" value="0"/>萬∕坪
	 				~<input id="MAX_BUILDING_COST" name="MAX_BUILDING_COST" action="copy" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="造價區間價迄" value="0"/>萬∕坪
	 				</td>
				</tr>
				<tr>
	 				<td class="tbYellow2">總銷金額<input id="TOTAL_SALE_PRICE" action="copy" name="TOTAL_SALE_PRICE" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="總銷金額" value="0"/>萬</td>
	 			</tr>
				<tr><td class="tbYellow" >二、說明<a href="#PRICE_OTHER_DESC"  id="LINK_PRICE_OTHER">補充說明</a></td></tr>
				<tr>
	 				<td class="tbYellow2" >
	 				<textarea id="PRICE_DESC" name="PRICE_DESC" fieldName="說明" rows="9" cols="115"  class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="4000" onkeyup="if(this.scrollHeight > 120) this.style.posHeight=this.scrollHeight"></textarea>
	 				<br><textarea style="{display:none;}" id="PRICE_OTHER_DESC" name="PRICE_OTHER_DESC" fieldName="補充說明" rows="9" cols="115" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="2000" onkeyup="if(this.scrollHeight > 120) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
	 			</tr>
			</table>
			<!------------------------ G區---------------------> <!--  [20201112] 修改件 立案單號:201106001527 -->
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableG">
				<tr><td class="tbYellow0" align="center" colspan="4"><div style="font-weight: bold;">伍、覆核</div></td></tr>
				<tr><td class="tbYellow" rowspan="6">組長批示</td></tr>
				<tr>
					<td class="tbYellow2" rowspan="6"> <!--下拉選單,異動時連動一般行情欄位,連動方式參見2.4.2.9.1 -->
						<select name="CAPT_EXAM" id="CAPT_EXAM" class="textBox2 validate-selection" fieldName="批示" key="CAPT">
							<c:forEach var="map" items="${CAPT_EXAM_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select>
					</td>
				</tr>
				<tr>
					<td class="tbYellow2" colspan="2">
						<textarea id="CAPT_EXAM_DESC" name="CAPT_EXAM_DESC" key="CAPT" fieldName="批示內容" rows="3" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
				</tr>
				<tr>
					<td class="tbYellow2">
						<!-- 一樓店面區間價起 CAPT_MIN_STOREFRONT_PRICE 一樓店面區間價迄 CAPT_MAX_STOREFRONT_PRICE -->
						一樓店面區間價 <input id="CAPT_MIN_STOREFRONT_PRICE" name="CAPT_MIN_STOREFRONT_PRICE" key="CAPT" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="一樓店面區間價起" value="0"/>萬∕坪
					    ~<input id="CAPT_MAX_STOREFRONT_PRICE" name="CAPT_MAX_STOREFRONT_PRICE" key="CAPT" type="text" datatype="number" pattern="#,###.###"" class="textBox2" size="10" fieldName="一樓店面區間價迄" value="0"/>萬∕坪
					</td>
					<td class="tbYellow2"><!-- 地價區間價起 CAPT_MIN_LAND_PRICE 地價區間價迄 CAPT_MAX_LAND_PRICE -->
	 				地價區間價<input id="CAPT_MIN_LAND_PRICE" name="CAPT_MIN_LAND_PRICE" key="CAPT" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="地價區間價起" value="0"/>萬∕坪
	 				~<input id="CAPT_MAX_LAND_PRICE" name="CAPT_MAX_LAND_PRICE" key="CAPT" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="地價區間價迄" value="0"/>萬∕坪
	 				</td>
				</tr>
				<tr>
					<td class="tbYellow2">
						<!-- 一樓住家區間價起 CAPT_MIN_HOUSE_PRICE 一樓住家區間價迄 CAPT_MAX_HOUSE_PRICE -->
						 一樓住家區間價<input id="CAPT_MIN_HOUSE_PRICE" name="CAPT_MIN_HOUSE_PRICE" key="CAPT" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="一樓店面區間價起" value="0"/>萬∕坪
					    ~<input id="CAPT_MAX_HOUSE_PRICE" name="CAPT_MAX_HOUSE_PRICE" key="CAPT" type="text" datatype="number" pattern="#,###.###"" class="textBox2" size="10" fieldName="一樓店面區間價迄" value="0"/>萬∕坪
					</td>
					<td class="tbYellow2"> <!-- 造價區間價起 CAPT_MIN_BUILDING_COST 造價區間價迄 CAPT_MAX_BUILDING_COST	 -->
	 				造價區間價<input id="CAPT_MIN_BUILDING_COST" name="CAPT_MIN_BUILDING_COST" key="CAPT" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="造價區間價起" value="0"/>萬∕坪
	 				~<input id="CAPT_MAX_BUILDING_COST" name="CAPT_MAX_BUILDING_COST" key="CAPT" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="造價區間價迄" value="0"/>萬∕坪
	 				</td>
				</tr>
				<tr>
					<td class="tbYellow2">
						<!-- 二樓以上區間價起 CAPT_MIN_2F_PRICE 二樓以上區間價迄 CAPT_MAX_2F_PRICE  -->
						 二樓以上區間價<input id="CAPT_MIN_2F_PRICE" name="CAPT_MIN_2F_PRICE" key="CAPT" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="二樓以上區間價起" value="0"/>萬∕坪
					    ~<input id="CAPT_MAX_2F_PRICE" name="CAPT_MAX_2F_PRICE" key="CAPT" type="text" datatype="number" pattern="#,###.###"" class="textBox2" size="10" fieldName="二樓以上區間價迄" value="0"/>萬∕坪
					
					</td>
					<!-- CAPT_TOTAL_SALE_PRICE -->
	 				<td class="tbYellow2">總銷金額<input id="CAPT_TOTAL_SALE_PRICE" key="CAPT" name="CAPT_TOTAL_SALE_PRICE" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="總銷金額" value="0"/>萬</td>
				</tr>
				<tr><td class="tbYellow" rowspan="6">主管批示</td></tr>
				<tr>
					<td class="tbYellow2" rowspan="5"> <!--下拉選單,異動時連動一般行情欄位,連動方式參見2.4.2.9.1 -->
						<select name="BOSS_EXAM" id="BOSS_EXAM" class="textBox2 validate-selection" fieldName="批示" key="BOSS">
							<c:forEach var="map" items="${BOSS_EXAM_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select>
					</td>
				</tr>
				<tr>
					<td class="tbYellow2" colspan="2">
						<textarea id="BOSS_EXAM_DESC" name="BOSS_EXAM_DESC" key="BOSS" fieldName="批示內容" rows="3" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
				</tr>
				<tr>
					<td class="tbYellow2">
						<!-- 一樓店面區間價起 BOSS_MIN_STOREFRONT_PRICE 一樓店面區間價迄 BOSS_MAX_STOREFRONT_PRICE -->
						一樓店面區間價 <input id="BOSS_MIN_STOREFRONT_PRICE" name="BOSS_MIN_STOREFRONT_PRICE" key="BOSS" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="一樓店面區間價起" value="0"/>萬∕坪
					    ~<input id="BOSS_MAX_STOREFRONT_PRICE" name="BOSS_MAX_STOREFRONT_PRICE" key="BOSS" type="text" datatype="number" pattern="#,###.###"" class="textBox2" size="10" fieldName="一樓店面區間價迄" value="0"/>萬∕坪
					</td>
					<td class="tbYellow2"><!-- 地價區間價起 BOSS_MIN_LAND_PRICE 地價區間價迄 BOSS_MAX_LAND_PRICE -->
	 				地價區間價<input id="BOSS_MIN_LAND_PRICE" name="BOSS_MIN_LAND_PRICE" key="BOSS" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="地價區間價起" value="0"/>萬∕坪
	 				~<input id="BOSS_MAX_LAND_PRICE" name="BOSS_MAX_LAND_PRICE" key="BOSS" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="地價區間價迄" value="0"/>萬∕坪
	 				</td>
				</tr>
				<tr>
					<td class="tbYellow2">
						<!-- 一樓住家區間價起 BOSS_MIN_HOUSE_PRICE 一樓住家區間價迄 BOSS_MAX_HOUSE_PRICE -->
						 一樓住家區間價<input id="BOSS_MIN_HOUSE_PRICE" name="BOSS_MIN_HOUSE_PRICE" key="BOSS" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="一樓店面區間價起" value="0"/>萬∕坪
					    ~<input id="BOSS_MAX_HOUSE_PRICE" name="BOSS_MAX_HOUSE_PRICE" key="BOSS" type="text" datatype="number" pattern="#,###.###"" class="textBox2" size="10" fieldName="一樓店面區間價迄" value="0"/>萬∕坪
					</td>
					<td class="tbYellow2"> <!-- 造價區間價起 BOSS_MIN_BUILDING_COST 造價區間價迄 BOSS_MAX_BUILDING_COST	 -->
	 				造價區間價<input id="BOSS_MIN_BUILDING_COST" name="BOSS_MIN_BUILDING_COST" key="BOSS" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="造價區間價起" value="0"/>萬∕坪
	 				~<input id="BOSS_MAX_BUILDING_COST" name="BOSS_MAX_BUILDING_COST" key="BOSS" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="造價區間價迄" value="0"/>萬∕坪
	 				</td>
				</tr>
				<tr>
					<td class="tbYellow2">
						<!-- 二樓以上區間價起 BOSS_MIN_2F_PRICE 二樓以上區間價迄 BOSS_MAX_2F_PRICE  -->
						 二樓以上區間價<input id="BOSS_MIN_2F_PRICE" name="BOSS_MIN_2F_PRICE" key="BOSS" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="二樓以上區間價起" value="0"/>萬∕坪
					    ~<input id="BOSS_MAX_2F_PRICE" name="BOSS_MAX_2F_PRICE" key="BOSS" type="text" datatype="number" pattern="#,###.###"" class="textBox2" size="10" fieldName="二樓以上區間價迄" value="0"/>萬∕坪
					
					</td>
					<!-- BOSS_TOTAL_SALE_PRICE -->
	 				<td class="tbYellow2">總銷金額<input id="BOSS_TOTAL_SALE_PRICE" name="BOSS_TOTAL_SALE_PRICE" key="BOSS" type="text" datatype="number" pattern="#,###.###" class="textBox2" size="10" fieldName="總銷金額" value="0"/>萬</td>
				</tr>
				<tr>
					<td class="tbYellow" rowspan="2">部室主管批示</td></tr>
				</tr>
				<tr>
					<td class="tbYellow2"> <span id="GM_NM"></span><span id="GM_DATE" datatype="ROCDate"></span></td><!-- GM_NM --> 
					<td class="tbYellow2" colspan="2"> 
						<textarea id="GM_EXAM_DESC" name="GM_EXAM_DESC" fieldName="部室主管覆核說明" rows="3" cols="90" class="textBox2 validate1QUOTATION validate1COMMA checkInputLength" maxlength="300"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
					</td>
				</tr>
			</table>
			
			<table id='table_P1' class="tbBox2" cellspacing="1" style="width:100%; border:0;"></table>
			<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_R">
				<tr align="center" class="tbYellow0">
					<td colspan="8" class="textBold">陸、評分</td>
				</tr>
				<tr> 
				 	<td colspan="3">
						<table id="gridR1" ></table>
				  	</td>
				</tr>
				<tr>
					<td class=tbYellow2 align="center" colspan="3">
						<input id="btn_add_1" class="button" type="button" value="新增評分" /> 
					</td>
				</tr>
			</table>
		</form>
</body>
<!-- InstanceEnd -->
</html>