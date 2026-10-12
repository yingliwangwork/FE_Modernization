<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA30600.jsp
作者：張智翔
功能：土建融鑑價報告輸入。
完成：2012/05/23

[20180626]
問題敘述：1.IE11問題 2.onpropertychange在IE11失效，改用onkeyup，並在查詢完成時模擬keyup動作

[20201126]修改件
  申請書-201019001927：調整承作分區判斷邏輯(立案單：201106001527)
  申請書-201102001309
   1. 新增H區覆核區塊
   2. C區新增鑑價紀錄欄位

[20210714]修改件
立案單：210706010909
   1.	C區原先的”已取得外部估價報告書”下拉選單隱藏，新增下拉選單內容，並且新增/修改至DB
   2.	報表一併修改   
   
[20211018] 修改件，立案單號:211015005065
CHROME 進入壽核系統的鑑價報告 textarea 欄位優化

[20221109]修改件
1. 於土建融報告中新增正常/特定價格設計容積率，共兩個欄位。
2. 鑑價員呈核前需點擊環域分析，帶回擔保品座標。
高強禾

[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
-->

<fmt:setBundle basename='TextResource' />
<STYLE TYPE="text/css">
.textAreaOldSys {
    font-size: 8pt;
}
@font-face {
font-family: 'EUDC';
  src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
       url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
 font-weight: normal;
 font-style: normal
}
</STYLE>

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/popupWin.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>	<%-- 檢核用 --%>
<script type='text/JavaScript' src='<%=htmlBase%>/CM/js/date.js'></script>			<%-- 日期用 --%>
<script type='text/JavaScript' src='<%=htmlBase%>/CM/js/calendar.js'></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>		<%-- 匯出PDF用--%>
<script type="text/javascript" src='<%=htmlBase%>/CM/js/ui/InputUtility.js'></script>
<script type='text/javascript'>

// 產生畫面物件
var DSA30600 = new DSA30600();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSA30600.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA30600(){
	//查詢的檢核
	var valid1;
	//新增的檢核
	var valid2;
	//修正的檢核
	var valid3;
	//呈核的檢核
	var valid4;
	
	//三個TablE UI物件
	var grid;
	var grid1;	
	var grid2;
	
	var gridR1; //評分
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
	var AVM_GAP_A_LIST = {};//自動估價價格落差選單
	var AVM_GAP_S_LIST = {};//建議案例價格落差選單

	var isURBAN_PROJECT = false;//若為都市計畫案區域，須檢核都市計畫案不可為空
	
	//A231_A固定的欄位,一定不會變
	var gridFieldFormat = [
		{ COL_NAME : "基地座落方向"},
		{ COL_NAME : "基地面臨道路寬度"},
		{ COL_NAME : "土地正面臨接面寬度"},
		{ COL_NAME : "土地最大深度"},
		{ COL_NAME : "基地面臨道路是否開闢"},
		{ COL_NAME : "基地是否臨建築線"},
		{ COL_NAME : "基地內是否有既成道路"},
		{ COL_NAME : "基地是否鄰近寺廟及嫌惡"},
		{ COL_NAME : "基地是否與圳溝、河川為臨"},
		{ COL_NAME : "基地與其他道路是否路沖"},
		{ COL_NAME : "基地是否有地上物"},
		{ COL_NAME : "地形"},
		{ COL_NAME : "地勢"}	
	]
	
	//A231_B固定的欄位,一定不會變
	var grid1FieldFormat = [
		{ COL_NAME : "容積率"},
		{ COL_NAME : "建蔽率"},
		{ COL_NAME : "二樓以上平均單價"},
		{ COL_NAME : "地面層平均單價"},
		{ COL_NAME : "停車場單價"},
		{ COL_NAME : "營造單價"},
		{ COL_NAME : "設計費用率"},
		{ COL_NAME : "稅金管理費用率"},
		{ COL_NAME : "廣告銷售費用率"},
		{ COL_NAME : "融資利率"},
		{ COL_NAME : "投資興建利潤率"},
		{ COL_NAME : "規劃樓層"}		
	]
	//需檢核的textArea欄位
	var validArray = [
		"USE_AREA2",
		"LAND_MARK",
		"LAND_MEASURE_DESC",
		"USE_AREA_REG",
		"ANNOU_VALUE",
		"USE_STATUS",
		"BUILD_PLAN",
		"BASE_DESC",
		"TRAFFIC_DESC",
		"PARK_DESC",
		"SCHOOL_DESC",
		"VISIT_DESC_M",
		"VISIT_DESC_L",
		"OTHER_DESC",
		"MARKET_DESC",
		"DEVELOP_DESC",
		"FORMULA",
		"MARKET_DESCB",
		"DEVELOP_DESCB",
		"FORMULAB",
		"CONCLUSION_DESC",
		"CONCLUSION_DESCB"
	];
	
	//顯示資料為 變數+%					
	var readOnlyWithPercent = [
		'TRADE_STATUS_RATE_A232_',
		'TRADE_TIME_RATE_A232_',
		'SPEC_ADJUST_RATE_A232_',
		'BASE_SPEC_RATE_A232_',
		'AREA_UPDATE_RATE_A232_'		
	]
	//顯示資料為 變數+萬/坪			
	var readOnlyWithMoney = [
		'BASE_SPEC_PRICE_A232_',
		'AREA_UPDATE_PRICE_A232_',
		'TRADE_STATUS_PRICE_A232_',
		'TRADE_TIME_PRICE_A232_',
		'SPEC_ADJUST_PRICE_A232_'		
	]
	
	//檢核用迴圈
	function validDefineInfo(defineValid , type){
		for(var i = 0 ; i < validArray.length ; i++){
			defineValid.define( type , { id: validArray[i] } );		
		}
	}
	
	//數字檢核用loop
	function getNumberValid(defineValid){
	var func = $$('#form2 input[datatype =number]');
		func.each(
			function(elem){
				defineValid.define( 'validate-number' , { id: elem.id } );	
			
			}

		)	
	}
	//將查詢完結果的 APPLY_ID存起來
	var rtnMapApply_id;
	//頁面上查詢完的結果
	var rtnMap ={ APPLY_ID : ""};	
				
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0003:'btn_insert'<%--新增--%> ,
				B0004:'btn_update'<%--修改--%> ,
				B0005:'btn_delete'<%--刪除--%> ,
				B0116:'btn_confirm'<%--呈核--%> ,
				B0085:'btn_cancel'<%--取消呈核--%> ,
				B0117:'btn_glConfirm'<%--組長覆核--%> ,
				B0018:'btn_glReject'<%--組長退回--%> ,
				B0123:'btn_cgmConfirm'<%--科主管覆核--%> ,
				B0125:'btn_gmConfirm'<%--部室主管覆核--%> ,
				B0124:'btn_Reject'<%--主管退回覆核--%> ,
				B0128:"btn_count"<%--試算--%> ,
				B0134:"btn_getNearThing"<%--取得鄰近設施資料--%>,
				B0148:"btn_reSend"<%--報告重送 --%>
		};
		
		<dz:grantButtons FUNC_ID="DSA30600" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([	
			[ 'validateAPPLY_ID',  '受理編號長度不正確 需為11碼', 
				function(v){				
					return (v!=="" && v.length != 11) ? false : true ;   
			} ],
			[ 'SPEC_ADJUST_RATE',  '市場比較法個案加權數相加不為100,請修正!', 
				function(){					
					var sar1 = parseFloat($('SPEC_ADJUST_RATE_A232_1').value);
					var sar2 = parseFloat($('SPEC_ADJUST_RATE_A232_2').value);
					var sar3 = parseFloat($('SPEC_ADJUST_RATE_A232_3').value);
					return sar1 + sar2 + sar3 === 100 ? true : false ;   
			} ],
			[ 'textAreaInfo',  "內容文字不得包合單引號('')或半形逗號(,)", 
				function(v){					
					return ((v.search(',') == "-1") && (v.search('\'') == "-1")) ? true : false;
			} ],
			[ 'IS_TRADE',  '請選擇是否為買賣件', 
				function(v){				
					return v!=="0" ? true : false ;   
			} ],
			['checkNumeralFormat_5_2', '數值輸入格式錯誤，整數僅接受5位整數，小數點僅接受到小數點後2位!', function(v , node) { 
				return checkNumeralFormat(v , 5 , 2);
			}],
			<%-- [20230217] 230131003715 若新件/修改件 分級項需選擇土建融A/土建融B，土建融選項僅供舊件查詢使用。--%>
			['validateGRADING_ITEM', '新增、修改時，分級項需選土建融A或土建融B。',
				function(v){
 					return (v == '0') ? false : true ;
			}]
		]);		
		
		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "validateAPPLY_ID" , { id: "APPLY_ID" } );	
		valid1.define( "required" , { id: "APPLY_ID" ,errMsg : "受理編號不得為空值" } );
		
		//新增用檢核
		valid2 = new Validation("form3", { focusOnError:true, immediate:false });		
		valid2.define( "required" , { id: "CONTRACT_AREA" } );
		//長度檢核
		validDefineInfo(valid2 , 'checkInputLength');
		//文字內容檢核
		validDefineInfo(valid2 , 'textAreaInfo');		
		valid2.define( "SPEC_ADJUST_RATE" , { id: "SPEC_ADJUST_RATE_A232_1" } );
		valid2.define( "IS_TRADE" , { id: "IS_TRADE" } );			
		valid2.define( "validateGRADING_ITEM" , { id: "GRADING_ITEM" } );	
		getNumberValid(valid2);
		
		//修改用檢核
		valid3 = new Validation("form3", { focusOnError:true, immediate:false });	
		validDefineInfo(valid3 , 'checkInputLength');
		valid3.define( "SPEC_ADJUST_RATE" , { id: "SPEC_ADJUST_RATE_A232_1" } );
		valid3.define( "IS_TRADE" , { id: "IS_TRADE" } );
		valid3.define( "validateGRADING_ITEM" , { id: "GRADING_ITEM" } );	
		getNumberValid(valid3);
		
		//呈核用檢核
		valid4 = new Validation("form2", { focusOnError:true, immediate:false });	
		valid4.define( "required" , { id: "USE_AREA1" } );
		<%-- [20221109] 增加設計容積率(正常)檢核 --%>
		valid4.define("required", [{ id : 'BOSS_REG_FLAR', errMsg:'設計容積率(正常)不可為空' }] );
		valid4.define( "validateGRADING_ITEM" , { id: "GRADING_ITEM" } );
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSA3_0600/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {
		//查詢資料
		doQuery : function(event){
			
			var APPLY_ID = $('APPLY_ID').value.toUpperCase();
			//轉大寫回頁面 
			$('APPLY_ID').value = APPLY_ID;

			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}		
			
			
			//發送ajax
			ajaxPost( 'query' , {APPLY_ID : APPLY_ID},
				function(resp){						
					//保留參數管理-更新受理編號
					CSRUtil.keepParamsManager.put({'APPLY_ID': APPLY_ID });
					//載入資料
					writeDataToView(resp , 'allLoad');
				},
				function(resp){					
					//失敗就清空所有欄位
					buttons.doClear();
					
					<%--[20211018] 使用 InputUtility.js 調整成讓 CHORME textarea也能依照內容自動調整欄位高度--%>
					$$('textarea').each(function(e){	
						InputUtility.autoSizingTextarea.doAutoSize(e); //依內容調整高度
					});
				}
			);		
		},	
		

		//列印
		doOutput : function(event){
			//列印
			<c:choose>
				<c:when test="${fromPublicBean eq 'DSA3_2400'}">var action = "DSA3_2400/print";</c:when>
				<c:otherwise>var action = "DSA3_0600/print";</c:otherwise>
			</c:choose>
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
		
		//新增
		doInsert : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch1(queryApply_id)){
				return;			
			}		

			valid2.reset();
			if(!valid2.validate()){ 
				return; 
			}	
			
			//總價值的檢核
			if(!checkIS_GM()){
				return;
			}
			//確認A234List中每筆土地價值不是0
			if(!checkLandPrice()){
				return;
			}		
			var sendReocrd = makeInputRecord();		
		
			//發送ajax
			ajaxPost( 'insert' , { APPLY_ID : queryApply_id, sendReocrd : Object.toJSON(sendReocrd)},
				function(resp){			
					writeDataToView(resp , 'allLoad');				
				}
			);	
		},		
		
		//修正
		doUpdate : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
			
			//總價值的檢核
			if(!checkIS_GM()){
				return;
			}
			//確認A234List中每筆土地價值不是0
			if(!checkLandPrice()){
				return;
			}

			valid3.reset();
			if(!valid3.validate()){ 
				return; 
			}	
			
			var sendReocrd = makeInputRecord();					
			//發送ajax
			ajaxPost( 'update' , { APPLY_ID : queryApply_id, sendReocrd : Object.toJSON(sendReocrd)},
				function(resp){			
					writeDataToView(resp,'allLoad');	
				}
			);	
		}
		,
		//刪除
		doDelete : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
		
			if(!confirm('確定要刪除 '+ queryApply_id + ' 之鑑價報告書資料？')){
				return;
			}
			
			var sendReocrd = makeInputRecord();		
			
			//發送ajax
			ajaxPost( 'delete' , { APPLY_ID : queryApply_id , rtnMap : Object.toJSON(sendReocrd.rtnMap)},
				function(resp){			
					deleteInitGrid(gridFieldFormat);
					deleteInitGrid(grid1FieldFormat);
					writeDataToView(resp,'allLoad');	
				}
			);	
		
		},
		
		//呈核
		doConfirm : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
			
			//總價值的檢核
			if(!checkIS_GM()){
				return;
			}

			<%-- [20221109]  增加經位度hidden欄位檢核 --%>
			if (!$F('LONGITUDE') || !$F('LATITUDE')) {
				alert('座標不可為空，請進行環域分析');
				return;
			}

			//確認A234List中每筆土地價值不是0
			if(!checkLandPrice()){
				return;
			}

			valid4.reset();
			if(isURBAN_PROJECT){
				valid4.define( "required" , { id: "URBAN_PROJECT" } );	
			}
			if(!valid4.validate()){ 
				return; 
			}		
			
			//將畫面資料存成List
			var sendReocrd = makeInputRecord();		
		
			//發送ajax
			ajaxPost( 'confirm' , { APPLY_ID : queryApply_id, sendReocrd : Object.toJSON(sendReocrd)},
				function(resp){			
					writeDataToView(resp,'allLoad');	
				}
			);	
		
		
		},

		//取消呈核
		doCancel : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;
			}

			//將畫面資料存成List
			var sendReocrd = makeInputRecord();

			//發送ajax
			ajaxPost( 'cancel' , { APPLY_ID : queryApply_id, sendReocrd : Object.toJSON(sendReocrd)},
				function(resp){
					writeDataToView(resp,'allLoad');
				}
			);
		},
		
		//組長覆核
		/*doGlConfirm : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
			//土地總價檢核
			if(!checkTotalPrice()){
				return;			
			}
			
			//將畫面資料存成List
			var sendReocrd = makeInputRecord();
		
			//發送ajax
			ajaxPost( 'glConfirm' , { APPLY_ID : queryApply_id, sendReocrd : Object.toJSON(sendReocrd)},
				function(resp){		
					writeDataToView(resp,'allLoad');	
				}
			);	
		
		},*/
		
		//組長覆核作業確認訊息
		//[20211025] 組長批示與建議價格欄位數值不一致時出現提醒視窗
		doGlConfirmCheck : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
			//土地總價檢核
			if(!checkTotalPrice()){
				return;			
			}
			
			//將畫面資料存成List
			var sendReocrd = makeInputRecord();
			
			var paramMap = { APPLY_ID : queryApply_id, sendReocrd : Object.toJSON(sendReocrd)};
			
			//發送ajax
			new Ajax.Request( 
				"<%=dispatcher%>/DSA3_0600/glConfirmCheck",
				{ parameters: paramMap,
		          onSuccess: function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						if (resp.GlConfirmMSG == 'OK'){
							buttons.doGlConfirm(paramMap);
						} else {
							var GlConfirmMSG = resp.GlConfirmMSG;
							if(GlConfirmMSG){
								GlConfirmMSG = GlConfirmMSG.replace(/\\r|\\n|\\r\\n/g, "\n");
							}
							if(!confirm(GlConfirmMSG)){
								return false;
							}
							buttons.doGlConfirm(paramMap);
						}				
					}
		        }}
			);
			
		},
		
		//組長覆核
		doGlConfirm : function(paramMap){
			msgWin.clearCallback();
			
			//發送ajax
			ajaxPost( 'glConfirm' , paramMap,
				function(resp){		
					writeDataToView(resp,'allLoad');	
				}
			);	
		
		},
		
		//組長退回
		doGlReject : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
		
			//提示確認訊息:‘確定要退回’+ A區受理編號 + ‘之鑑價報告書資料？’,確認後才繼續執行			
			if(!confirm('確定要退回 ' + queryApply_id +' 之鑑價報告書資料？')){
				return
			}
			
			//將畫面資料存成List
			var sendReocrd = makeInputRecord();
			
			//發送ajax
			ajaxPost( 'glReject' , { APPLY_ID : queryApply_id, sendReocrd : Object.toJSON(sendReocrd)},
				function(resp){	
					writeDataToView(resp,'allLoad');	
				}
			);	
		
		},
		
		//科主管覆核
		/*doCGMConfirm : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
			//土地總價檢核
			if(!checkTotalPrice()){
				return;			
			}
		
			//20200616 鄒佩蓉-鑑價企劃科:取消科主管覆核可變更是否轉呈部室主管
			//var IS_GM = $('IS_GM').checked === true ?  "1" : "0" ;
		
			var sendMap = {
				//IS_GM : IS_GM ,
				IS_GM : rtnMap.IS_GM ,
				CAPT_ID : rtnMap.CAPT_ID
			}			
			
			//將畫面資料存成List
			var sendReocrd = makeInputRecord();
			
			//發送ajax
			ajaxPost( 'CGMConfrim' , { APPLY_ID : queryApply_id , sendMap : Object.toJSON(sendMap), sendReocrd : Object.toJSON(sendReocrd) },
				function(resp){			
					writeDataToView(resp,'allLoad');	
				}
			);	
		},*/
		
		//科主管覆核作業確認訊息
		//[20211025] 主管批示與建議價格欄位數值不一致時出現提醒視窗
		doCGMConfirmCheck : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
			//土地總價檢核
			if(!checkTotalPrice()){
				return;			
			}
			
			var sendMap = {
				IS_GM : rtnMap.IS_GM ,
				CAPT_ID : rtnMap.CAPT_ID
			}			
				
			//將畫面資料存成List
			var sendReocrd = makeInputRecord();
			
			var paramMap = { APPLY_ID : queryApply_id , sendMap : Object.toJSON(sendMap), sendReocrd : Object.toJSON(sendReocrd) }
			
			//發送ajax
			new Ajax.Request( 
				"<%=dispatcher%>/DSA3_0600/CGMConfrimCheck",
				{ parameters: paramMap,
		          onSuccess: function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						if (resp.CGMConfirmMSG == 'OK'){
							buttons.doCGMConfirm(paramMap);
						} else {
							var CGMConfirmMSG = resp.CGMConfirmMSG;
							if(CGMConfirmMSG){
								CGMConfirmMSG = CGMConfirmMSG.replace(/\\r|\\n|\\r\\n/g, "\n");
							}
							if(!confirm(CGMConfirmMSG)){
								return false;
							}
							buttons.doCGMConfirm(paramMap);
						}				
					}
		        }}
			);
			
		},
		
		//科主管覆核
		doCGMConfirm : function(paramMap){
			msgWin.clearCallback();
			
			//發送ajax
			ajaxPost( 'CGMConfrim' , paramMap,
				function(resp){			
					writeDataToView(resp,'allLoad');	
				}
			);	
		},
		
		//部室主管覆核
		doGMConfirm : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
			//土地總價檢核
			if(!checkTotalPrice()){
				return;			
			}
			
			//[20201126]將畫面資料存成List
			var sendReocrd = makeInputRecord();			
			
			//發送ajax
			ajaxPost( 'GMConfirm' , { 
					APPLY_ID : queryApply_id,
					CAPT_ID : rtnMap.CAPT_ID,
					BOSS_ID : rtnMap.BOSS_ID,
					MAP_AREA_CODE : rtnMap.MAP_AREA_CODE, 
					sendReocrd : Object.toJSON(sendReocrd)
				},
				function(resp){			
					writeDataToView(resp,'allLoad');	
				}
			);	
		
		
		},
		
		//主管退回覆核
		doReject : function(event){
			var act;
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
		
			//取消覆核
			if (rtnMap.GM_DATE) {
				//提示確認訊息:“確定要取消” + APPLY_ID + “之鑑價報告書？”
				if(!confirm('確定要取消 ' + queryApply_id +' 之鑑價報告書？')){
					return
				}
				act = 'GMCancel';
			} else {
				//提示確認訊息:“確定要退回” + APPLY_ID + “之鑑價報告書？”
				if(!confirm('確定要退回 ' + queryApply_id +' 之鑑價報告書？')){
					return
				}
				
				act = 'CGMReject';

			}
			
			//將畫面資料存成List
			var sendReocrd = makeInputRecord();
			
			//發送ajax
			ajaxPost(act, { APPLY_ID : queryApply_id, sendReocrd : Object.toJSON(sendReocrd)},
				function(resp){			
					writeDataToView(resp,'allLoad');	
				}
			);	
		},
		
		//試算
		doCount : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
			
			var sendReocrd = makeInputRecord();		
									
			//發送ajax
			ajaxPost( 'count' , 
			{
				APPLY_ID : queryApply_id , 
				sendReocrd : Object.toJSON({ A231ListA : sendReocrd.A231ListA, A231ListB : sendReocrd.A231ListB, A233List : sendReocrd.A233List, A232List : sendReocrd.A232List , A234List : sendReocrd.A234List , rtnMap : sendReocrd.rtnMap})
			},
				function(resp){			
					writeDataToView(resp,'countOnly');	
				}
			);	
		
		},
		
		
		//鑑價影像檔               
		doGetFile : function(){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
					
			//發送ajax
			ajaxPost( 'getFile' , 
			{
				APPLY_ID : queryApply_id , 
				APPR_GROUP : rtnMap.APPR_GROUP
			},
				function(resp){			
					if(resp.apprPath && resp.apprPath!=''){
						var theAction = resp.apprPath;							
						window.open(theAction);
						
					}else{
						alert('取得鑑價影像檔失敗');
					}
				}
			);				
		},
		
		//取得鄰近設施資料
		doGetNear : function(event){
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}	
			//發送ajax
			ajaxPost( 'getNear' , { APPLY_ID : queryApply_id },
				function(resp){	
					
					var xyMap = resp.xyMap ? resp.xyMap : {};
					if(xyMap){
						$('LONGITUDE').value=xyMap.LONGITUDE ? xyMap.LONGITUDE : '';
						$('LATITUDE').value=xyMap.LATITUDE ? xyMap.LATITUDE : '';
						//$('CONTROL_AREA').value=xyMap.CONTROL_AREA ? xyMap.CONTROL_AREA : '';
					}
					
					var SPC_DISTANCE = resp.SPC_DISTANCE ? resp.SPC_DISTANCE : '';
					if(SPC_DISTANCE){
						$('BASE_DESC').value = $('BASE_DESC').value + resp.SPC_DISTANCE;
					}
					
					var distanceMap = resp.distanceMap ? resp.distanceMap : {};
					if(distanceMap){
						$('DISTANCE_A232_1').value = distanceMap.DISTANCE_A ? distanceMap.DISTANCE_A : '0';
						$('DISTANCE_A232_2').value = distanceMap.DISTANCE_B ? distanceMap.DISTANCE_B : '0';
						$('DISTANCE_A232_3').value = distanceMap.DISTANCE_C ? distanceMap.DISTANCE_C : '0';
					}
				}
			);	
		},
		
		//電子地圖
		doElectronicMap:function(){
		
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}		
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}
			
			var XML = Object.toJSON( {'APPLY_ID' : $('APPLY_ID').value, 'GAGE_ADDR' : rtnMap.GAGE_ADDR} );
			
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
		
		//報告重送
		doReSend : function(){
			
			var APPLY_ID = $('APPLY_ID').value.toUpperCase();
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}		
			//判別要作業的ID是否與頁面相同檢核
			var queryApply_id = $('APPLY_ID').value;
			if(!checkAPLLY_IDMatch(queryApply_id)){
				return;			
			}
			
			//發送ajax
			ajaxPost( 'reSend' , { APPLY_ID : queryApply_id, MAP_AREA_CODE : $F('MAP_AREA_CODE'), AREA_CODE_930318 : $F('AREA_CODE_930318')} );
		},
		
		//清除畫面 回到初始狀況
		doClear : function(event){
			//將畫面全部清空
			$('form2').reset();			
			$$('#form2 span').each(
				function(elem){
					elem.innerHTML = '';
				
				}
			);
			grid.load([]);
			grid1.load([]);
			grid2.load([]);
			gridR1.load([]);
			rtnMap = {};
			rtnMapApply_id = "";
		}
	}
	
	var actions = {
		//客製化某些格式
		nineFields : function(target , value , type){	
			var tempValue = value ? value : 0 ;
			var lastAppend = "";
			if(type === 'percent'){
				lastAppend = ' %';				
			}else if(type === 'money'){
				lastAppend = ' 萬/坪';				
			}
			target.update(MoneyFormat(tempValue)  + lastAppend);
		},
		
		//計算總價格
		doCount : function(PER_PRICE , LAND_MEASURE , totalNumb){
			
			ajaxPost( 'countTotalMoney' ,
			{ 
				PER_PRICE : $(PER_PRICE).getValue(),
				LAND_MEASURE : $(LAND_MEASURE).getValue()
			},
				function(resp){	
					$(totalNumb).value = MoneyFormat(resp.TOTAL_PRICE);	
					$(totalNumb+'_TXT').update ( MoneyFormat(resp.TOTAL_PRICE));		
				},
				function(resp){						
					$(PER_PRICE).value = 0;
					$(LAND_MEASURE).value = 0;
					$(totalNumb).value = 0;
				}
			);
		},
		//將顯示格式改成ROC
		datafields : function(target , val ){	
			target.value = Date.toInputROC( val || "" ,"/");
			target.update(Date.toInputROC( val || "" ,"/"))	;	
		},
		
		// 參、價格評估一、市場比較法之各筆土地單價直接帶入4、整體綜合修正表的訪價價格
		dotheSame: function() {
			
			var v = $F('LAND_PRE_PRICE_A232_1');
			$('TD_PER_PRICE_A232_1').update(v);
			$('PER_PRICE_A232_1').value = v;
		
		
			v = $F('LAND_PRE_PRICE_A232_2');
			$('TD_PER_PRICE_A232_2').update(v);
			$('PER_PRICE_A232_2').value = v;
		
		
			v = $F('LAND_PRE_PRICE_A232_3');
			$('TD_PER_PRICE_A232_3').update(v);
			$('PER_PRICE_A232_3').value = v;
			
		},
		
		// 輸入面積或總價時自動計算土地單位，土地單價 = 面積 / 總價  (四捨五入取到小數第2位)
		doCountLAND_PRE_PRICE: function(land, price, perPrice) {
			if($F(land) == 0 || $F(price) == 0) {
				$(perPrice).value = 0;
			} else if($F(land) && $F(price)) {
				ajaxPost( 'countLAND_PRE_PRICE' ,
				{ 
					TOTAL_PRICE : $(price).getValue(),
					BUILD_MEASURE : $(land).getValue()
				},
					function(resp){	
						$(perPrice).value = MoneyFormat(resp.LAND_PRE_PRICE);	
						actions.dotheSame();
					}
				);
			}
		},
		
		//  正常價格土地單價試算公式
		doUseFORMULA: function() {
			var MARKET_PER_PRICE = rtnMap.MARKET_PER_PRICE?  rtnMap.MARKET_PER_PRICE: '0';
			var LAND_PER_PRICE = rtnMap.LAND_PER_PRICE?  rtnMap.LAND_PER_PRICE: '0';
			
			ajaxPost( 'useFORMULA' ,
				{ 
					MARKET_PER_PRICE : MARKET_PER_PRICE,
					LAND_PER_PRICE : LAND_PER_PRICE,
					MARKET_RATE : $F('MARKET_RATE'),
					DEVELOP_RATE : $F('DEVELOP_RATE')
				},
					function(resp){	
						$('FORMULA').value = resp.FORMULA + '\n' + $('FORMULA').value;	
					}
				);
		},
		
		// 特﹝限﹞定價格土地單價試算公式
		doUseFORMULAB: function() {
			var MARKET_PER_PRICEB = rtnMap.MARKET_PER_PRICEB?  rtnMap.MARKET_PER_PRICEB: '0';
			var LAND_PER_PRICEB = rtnMap.LAND_PER_PRICEB?  rtnMap.LAND_PER_PRICEB: '0';

			ajaxPost( 'useFORMULAB' ,
				{ 
					MARKET_PER_PRICEB : $F('MARKET_PER_PRICEB'),
					LAND_PER_PRICEB : $F('LAND_PER_PRICEB'),
					MARKET_RATEB : $F('MARKET_RATEB'),
					DEVELOP_RATEB : $F('DEVELOP_RATEB')
				},
					function(resp){	
						$('FORMULAB').value = resp.FORMULAB + '\n' + $('FORMULAB').value;	
					}
				);
		},
		// [20201126] 都市計畫案
		doGetURBAN_PROJECT_LIST: function(list,URBAN_PROJECT){	
			$('URBAN_PROJECT').options.length = 0;
			if(list.length>0){
				isURBAN_PROJECT = true;
				$('URBAN_PROJECT').enable();
				$('URBAN_PROJECT').add(new Option('請選擇都市計畫案', ''));
				list.each(function(map){
					$('URBAN_PROJECT').add(new Option(map.URBAN_PROJECT_NM, map.POST_CODE +'_'+ map.SER_NO));
				});		
				$('URBAN_PROJECT').setValue(URBAN_PROJECT);
			}else{
				isURBAN_PROJECT = false;
				$('URBAN_PROJECT').add(new Option('無', ''));
				$('URBAN_PROJECT').disable();
			}
		},
		//[20201126]連動產生「承作分區」
		doGetAreaCode930318: function(){
			ajaxPost( 'getAreaCode930318' , { APPLY_ID: rtnMap.APPLY_ID, USE_AREA1: $F('USE_AREA1'), URBAN_PROJECT: $F('URBAN_PROJECT'), GAGE_ZIP: rtnMap.GAGE_ZIP },
				function(resp){	
					var data = resp.rtnMap || {};
					$('AREA_CODE_TXT').update(data.AREA_CODE_NM+'區' || '');
					$('AREA_CODE_NM').setValue(data.AREA_CODE_NM || '');
					$('AREA_CODE_930318').setValue(data.AREA_CODE_930318 || '');
					$('CONTRACT_AREA').setValue(data.CONTRACT_AREA || '');

					<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%>
					$('SUBMKT_ID').setValue(data.SUBMKT_ID ||'');
					$('SUBMKT_VERSION').setValue(data.SUBMKT_VERSION ||'');
					$('SUBMKT_NAME').setValue(data.SUBMKT_NAME ||'');
					$('AREA_CODE_MATCH_LEVEL').setValue(data.MATCH_LEVEL || (data.AREA_CODE_MATCH_LEVEL||''));
				}
			);
		},
		//[20201126]批示連動
		chgExam: function(TYPE){
			if('CAPT' == TYPE){
				if($F('CAPT_EXAM') == '1'){
					$('CAPT_REG_PER_PRICE').setValue($F('PER_PRICE'));
					$('CAPT_REG_TOTAL_PRICE').setValue($F('TOTAL_PRICE'));
					$('CAPT_SPEC_PER_PRICE').setValue($F('PER_PRICEB'));
					$('CAPT_SPEC_TOTAL_PRICE').setValue($F('TOTAL_PRICEB'));
				}else{
					$w('CAPT_REG_PER_PRICE CAPT_REG_TOTAL_PRICE CAPT_SPEC_PER_PRICE CAPT_SPEC_TOTAL_PRICE').each(function(id){
						$(id).setValue('0');
					});
				}
			}else if('BOSS' == TYPE){
				if($F('BOSS_EXAM') == '1'){
					$('BOSS_REG_PER_PRICE').setValue($F('PER_PRICE'));
					$('BOSS_REG_TOTAL_PRICE').setValue($F('TOTAL_PRICE'));
					$('BOSS_SPEC_PER_PRICE').setValue($F('PER_PRICEB'));
					$('BOSS_SPEC_TOTAL_PRICE').setValue($F('TOTAL_PRICEB'));
				}else{
					$w('BOSS_REG_PER_PRICE BOSS_REG_TOTAL_PRICE BOSS_SPEC_PER_PRICE BOSS_SPEC_TOTAL_PRICE').each(function(id){
						$(id).setValue('0');
					});
				}
			}
		}
	}
	
	//將資料顯示在畫面上
	//[20210714] 已取得外部估價報告書 下拉選單資料調整
	function writeDataToView(resp , writeType){	
		buttons.doClear();	

		var encryptAPPLY_ID = resp.encryptAPPLY_ID;
		if(encryptAPPLY_ID){
			$('encryptAPPLY_ID').value=encryptAPPLY_ID;
		}
	
		//先將數值欄位補0
		$$('#form2 input[datatype = number]').each(
			function(elem){
				elem.value = 0;	
				$w('BUILD_RATE_A232_1 BUILD_RATE_A232_2 BUILD_RATE_A232_3 FLOOR_RATE_A232_1 FLOOR_RATE_A232_2 FLOOR_RATE_A232_3 BUILD_MEASURE_A232_1 BUILD_MEASURE_A232_2 BUILD_MEASURE_A232_3 TOTAL_PRICE_A232_1 TOTAL_PRICE_A232_2 TOTAL_PRICE_A232_3 LAND_PRE_PRICE_A232_1 LAND_PRE_PRICE_A232_2 LAND_PRE_PRICE_A232_3 BOSS_REG_FLAR BOSS_SPEC_FLAR').each(function(id) {
					if(elem.id == id) {
						elem.value = "";	
					}
				});
			}
		)
		
		//  ﹝三﹞、權數加權與依據及判斷 .1 .2 .3 default值為100
		$$('.default100').each(
			function(elem){
				elem.value = 100;			
			}
		)
		
		
		//如果作業完有rtnMap
		if(resp.rtnMap){			
			
			rtnMap = resp.rtnMap;				
			//清乾form2的span區域
			$$('#form2 span').each(
				function(elem){
					elem.innerHTML = "";
				
				}
			);			
			//將APPLY_ID放入通用變數
			rtnMapApply_id = rtnMap.APPLY_ID;
			//將rtnMap放入畫面顯示區
			CSRUtil.voToInputs('form2' , rtnMap);
			//[20201126]將rtnMap放入畫面顯示區H
			//CSRUtil.voToInputs('form3' , rtnMap);
			$('CAPT_EXAM').setValue(rtnMap.CAPT_EXAM ? rtnMap.CAPT_EXAM : '');
			$('CAPT_EXAM_DESC').setValue(rtnMap.CAPT_EXAM_DESC ? rtnMap.CAPT_EXAM_DESC : '');
			$('CAPT_REG_PER_PRICE').setValue(rtnMap.CAPT_REG_PER_PRICE ? rtnMap.CAPT_REG_PER_PRICE : '0');
			$('CAPT_REG_TOTAL_PRICE').setValue(rtnMap.CAPT_REG_TOTAL_PRICE ? rtnMap.CAPT_REG_TOTAL_PRICE : '0');
			$('CAPT_SPEC_PER_PRICE').setValue(rtnMap.CAPT_SPEC_PER_PRICE ? rtnMap.CAPT_SPEC_PER_PRICE : '0');
			$('CAPT_SPEC_TOTAL_PRICE').setValue(rtnMap.CAPT_SPEC_TOTAL_PRICE ? rtnMap.CAPT_SPEC_TOTAL_PRICE : '0');
			$('BOSS_EXAM').setValue(rtnMap.BOSS_EXAM ? rtnMap.BOSS_EXAM : '');
			$('BOSS_EXAM_DESC').setValue(rtnMap.BOSS_EXAM_DESC ? rtnMap.BOSS_EXAM_DESC : '');
			$('BOSS_REG_PER_PRICE').setValue(rtnMap.BOSS_REG_PER_PRICE ? rtnMap.BOSS_REG_PER_PRICE : '0');
			$('BOSS_REG_TOTAL_PRICE').setValue(rtnMap.BOSS_REG_TOTAL_PRICE ? rtnMap.BOSS_REG_TOTAL_PRICE : '0');
			$('BOSS_SPEC_PER_PRICE').setValue(rtnMap.BOSS_SPEC_PER_PRICE ? rtnMap.BOSS_SPEC_PER_PRICE : '0');
			$('BOSS_SPEC_TOTAL_PRICE').setValue(rtnMap.BOSS_SPEC_TOTAL_PRICE ? rtnMap.BOSS_SPEC_TOTAL_PRICE : '0');
			$('GM_EXAM_DESC').setValue(rtnMap.GM_EXAM_DESC ? rtnMap.GM_EXAM_DESC : '');
			//[20240424]fixbug：發現form3的hidden欄位都未塞值
			$('form3').select('input[type="hidden"]').each(function(e){
				var id = e.id;
				e.setValue(rtnMap[id]||'');
			});
			
			//座標
			$('LONGITUDE').value=rtnMap.LONGITUDE ? rtnMap.LONGITUDE : ''; 
			$('LATITUDE').value=rtnMap.LATITUDE ? rtnMap.LATITUDE : '';
			
			//承作分區 [20201126] AREA_CODE --> AREA_CODE_NM
			if(rtnMap.AREA_CODE_NM) {
				$('AREA_CODE_TXT').update(rtnMap.MAP_AREA_CODE ? rtnMap.AREA_CODE_NM+'區(定位'+rtnMap.MAP_AREA_CODE+'區)' : rtnMap.AREA_CODE_NM+'區');
			}else{
				$('AREA_CODE_TXT').update(rtnMap.MAP_AREA_CODE ? '(定位'+rtnMap.MAP_AREA_CODE+'區)' : '');
			}
			$('MAP_AREA_CODE').value=rtnMap.MAP_AREA_CODE ? rtnMap.MAP_AREA_CODE : '';

			<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%>
			$('SUBMKT_ID').setValue(rtnMap.SUBMKT_ID ||'');
			$('SUBMKT_VERSION').setValue(rtnMap.SUBMKT_VERSION ||'');
			$('SUBMKT_NAME').setValue(rtnMap.SUBMKT_NAME ||'');
			$('AREA_CODE_MATCH_LEVEL').setValue(rtnMap.MATCH_LEVEL || (rtnMap.AREA_CODE_MATCH_LEVEL||''));	
			
			//如果IS_GM為1就打勾
			$('IS_GM').checked = rtnMap.IS_GM === "1" ? true : false;	
			
			//三個span update成MoneyFormat 
			actions.nineFields( $('TOTAL_PRICE_TXT'), rtnMap.TOTAL_PRICE , "puerMoney");
			actions.nineFields( $('TOTAL_PRICEB_TXT'), rtnMap.TOTAL_PRICEB , "puerMoney");
			actions.nineFields( $('LAND_MEASURE_TXT'), rtnMap.LAND_MEASURE , "puerMoney");	
			actions.nineFields( $('MARKET_PER_PRICE_TXT'), rtnMap.MARKET_PER_PRICE , "money");
			actions.nineFields( $('LAND_PER_PRICE_TXT'), rtnMap.LAND_PER_PRICE , "money");
			//四個span顯示民國年
			actions.datafields( $('GM_DATE_TXT'), rtnMap.GM_DATE);
			actions.datafields( $('BOSS_DATE_TXT'), rtnMap.BOSS_DATE);
			actions.datafields( $('CAPT_DATE_TXT'), rtnMap.CAPT_DATE);
			actions.datafields( $('APPR_DATE_TXT'), rtnMap.APPR_DATE);
			
			//[20201126]新增欄位
			$('SLOGAN1').update(rtnMap.SLOGAN1 || '');//鑑價記錄
			$('SLOGAN2').update(rtnMap.SLOGAN2 || '');
			actions.doGetURBAN_PROJECT_LIST((rtnMap.URBAN_PROJECT_LIST||[]),rtnMap.URBAN_PROJECT); //都市計畫案		

			//[20210714] 已取得外部估價報告書調整 (DB DTDSA230 增加 IS_REPORT1 欄位，改用這個設值。)
			$('IS_REPORT').setValue(rtnMap.IS_REPORT1 ? rtnMap.IS_REPORT1 : '0');
		}
		
		//給定A232的初始List
		var A232List = resp.A232List ? resp.A232List : [{},{},{}];
		
		for(var i = 0 ; i < A232List.length ; i++){	
			var numb = i+1;
			//將資料顯示在畫面上
			CSRUtil.voToInputs('form2' , A232List[i]);		
			//input欄位			
			for(var p = 0 ; p < readOnlyWithPercent.length ; p++){
				var percentKey = readOnlyWithPercent[p];					
				actions.nineFields( $(percentKey+ (numb+'') + '_TXT'),  A232List[i][percentKey+(numb+'')] , "percent");
			}
			
			for(var w = 0 ; w < readOnlyWithMoney.length ; w++){
				var wonKey = readOnlyWithMoney[w];
				actions.nineFields( $(wonKey+ (numb+'') + '_TXT'),  A232List[i][wonKey+(numb+'')] , "money");
			}				
		}	
							
		var A233List = resp.A233List;
		if(A233List){
			for(var i = 0 ; i < A233List.length ; i++){							
				CSRUtil.voToInputs('form2' , A233List[i]);						
			}	
		}
			
		loadGridIfExsit(grid , resp.A231ListA, []);
		loadGridIfExsit(grid1 , resp.A231ListB, []);
		loadGridIfExsit(grid2 , resp.A234List, []);		
		
		//[20201126]批示歷程
		A203List = resp.A203List ? resp.A203List : [];
		appendGridtoList(A203List, 'table_P1'); 
		
		//gridR1 評分
		var A107List = resp.A107List ? resp.A107List : [];
		addIndex = A107List.length;
		gridR1.load(A107List);	
		
		actions.dotheSame();	
		
		//模擬textarea keyup動作
		$w('LAND_MARK LAND_MEASURE_DESC USE_AREA_REG ANNOU_VALUE USE_STATUS BUILD_PLAN BASE_DESC TRAFFIC_DESC PARK_DESC SCHOOL_DESC VISIT_DESC_M VISIT_DESC_L OTHER_DESC FORMULA CONCLUSION_DESC FORMULAB CONCLUSION_DESCB').each( 
			function(id){
				$(id).simulate('keyup');
			}
		);
		
		<%--[20211018] 使用 InputUtility.js 調整成讓 CHORME textarea也能依照內容自動調整欄位高度--%>
		$$('textarea').each(function(e){	
			InputUtility.autoSizingTextarea.doAutoSize(e); //依內容調整高度
		});
	}
	
	//判斷要load進table UI的資料是否存在, 如不存在就load預設值
	function loadGridIfExsit(gridName, list, initList){
		if(list){
			gridName.load(list);
		}else {			
			gridName.load(initList);
		}
	
	}
	
	//[20201203] 將List增加到清單中
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
	
	//將初始表格清空
	function deleteInitGrid(list){
		for(var i = 0 ; i < list.length ; i ++){
			list[i].COL_DESC='';
			list[i].COL_NOTE='';
		}
	
	}
	

	
	//判別要作業的ID是否與頁面相同
	function checkAPLLY_IDMatch1(queryApply_id){
		
		rtnMapApply_id = rtnMap.APPLY_ID;			
		
		if(rtnMapApply_id===''){
			alert('請先執行查詢!');
			return false;	
		}else if(queryApply_id ===''){
			alert('畫面的查詢編號不得為空');
			return false;
		}
		return true;
	}
	
	//判別要作業的ID是否與頁面相同
	function checkAPLLY_IDMatch(queryApply_id){
		
		rtnMapApply_id = rtnMap.APPLY_ID;			
		
		if(rtnMapApply_id===''){
			alert('請先執行查詢!');
			return false;	
		}else if(queryApply_id ===''){
			alert('畫面的查詢編號不得為空');
			return false;
		}else if(queryApply_id !== rtnMapApply_id){
			alert('欲作業的 ' + queryApply_id + ' 與原先查詢的 '+ rtnMapApply_id + ' 不同,無法作業!');
			return false;
		}
		return true;
	}
	
	//確認A234List中每筆土地價值不是0
	function checkLandPrice(){
		var checkRecords = grid2.getAllRecords();	
		//當A234List有資料才去做資料檢核	
		if(checkRecords.length > 0){
			for(var i = 0 ; i < checkRecords.length ; i++){
				var PER_PRICE = checkRecords[i].PER_PRICE ;					
				//只要其中一筆有值,不為0或空白,就算檢核通過
				if(JsUtils.isNumeric(PER_PRICE) && PER_PRICE != 0){			
					return true;
					break;
				}
			
			}
			return confirm("各筆土地單價為0,請確認是否繼續執行?");		
		}else{
			return true;
		}
	}
	
	//土地總價檢核
	function checkTotalPrice(){
		//如果價值不相同就檢核失敗		
			
		if($('PER_PRICE').getValue() != rtnMap.PER_PRICE || $('TOTAL_PRICE').getValue() != rtnMap.TOTAL_PRICE){
			alert("土地總價有異動，請重新查詢再做覆核作業");
			return false;
		}	
		return true;
	}
	
	//總價值的檢核
	function checkIS_GM(){	
		if($('CONTRACT_AREA').value === "1" && !confirm("請確認是否為非承作區？")){
			return false;		
		}
		var TOTAL_PRICE  = $('TOTAL_PRICE').getValue();
		var IS_GM = $('IS_GM').checked === true ? true : false;
		
		//畫面上的TOTAL_PRICE >= 10000且是否轉呈部室主管unchecked
		if (TOTAL_PRICE >= 10000 && !IS_GM){
			alert("鑑估總值超過1億,已自動勾選轉呈部室主管");
			//並將畫面上的是否轉呈部室主管checked
			$('IS_GM').checked = true;
		}else if (TOTAL_PRICE < 10000 && IS_GM){
			alert("鑑估總值未超過1億,無須轉呈部室主管");
			//並將畫面上的是否轉呈部室主管unchecked
			$('IS_GM').checked = false;
		}
		return true;
	}	
	
	//將畫面上的資料組成各字的List
	function makeInputRecord(){
		//先取得畫面上的rtnMap
		var tempRtnMap = makeSingleMapFromClass('.rtnMap');		
		//因有些資訊是span,因此拿原先的rtnMap,再把畫面的輸入欄位作更新
		var sendRtnMap = Object.extend(rtnMap , tempRtnMap);
		//將IS_GM設定進去
		sendRtnMap.IS_GM = $('IS_GM').checked === true ? 1 : 0;
		//[20210714] 將 IS_REPORT 設定進去
		sendRtnMap.IS_REPORT = $('IS_REPORT').getValue();
		//將畫面所有的欄位製作成List			
		var sendRecord = {
			rtnMap : sendRtnMap,
			A231ListA : grid.getAllRecords(),
			A231ListB : grid1.getAllRecords(),
			A232List : [ 
				makeSingleMapFromClass('.A232_1'),  
				makeSingleMapFromClass('.A232_2'),  
				makeSingleMapFromClass('.A232_3') 
			],
			A233List : [ 
				makeSingleMapFromClass('.A233_1'), 
				makeSingleMapFromClass('.A233_2'), 
				makeSingleMapFromClass('.A233_3') 
			],
			A234List : grid2.getAllRecords(),
			A107List : gridR1.getAllRecords()
		}						
		return sendRecord;
	}
	
	//用class取得屬於自己的map
	function makeSingleMapFromClass(func){
		var returnMap = {};		
		$$(func).each(
			function(elem){				
				var value = elem.getValue();
					if( func==".A232_1" || func==".A232_2" || func==".A232_3") {
						$w('BUILD_RATE_A232_1 BUILD_RATE_A232_2 BUILD_RATE_A232_3 FLOOR_RATE_A232_1 FLOOR_RATE_A232_2 FLOOR_RATE_A232_3 BUILD_MEASURE_A232_1 BUILD_MEASURE_A232_2 BUILD_MEASURE_A232_3 TOTAL_PRICE_A232_1 TOTAL_PRICE_A232_2 TOTAL_PRICE_A232_3 LAND_PRE_PRICE_A232_1 LAND_PRE_PRICE_A232_2 LAND_PRE_PRICE_A232_3').each(function(id) {
							if(elem.id == id && !value) {
								value = 0;	
							}
						});
					}
				returnMap[elem.id] = value;
			}		
		);
		return returnMap;
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
	
	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSA30600", "鑑價作業", "土建融鑑價報告輸入", 1);		
				
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
					
				//基地個別條件
				grid =  new TableUI ( {
					table: $("grid"), pageSize : 0, allSortable:false,
						column:	[		
							{header: "個別條件 ",key: "COL_NAME"},
							{header: "標的狀況 ",key: "COL_DESC",
								input:{type:'TEXT', size:50 , width:45}
							},			
							{header: "備註 (序號)",key: "COL_NOTE",
								input:{type:'TEXT', size:30 , width:30}
							}	
						]
					});		
				
				grid1 =  new TableUI ( {
					table: $("grid1"), pageSize : 0, allSortable:false,
						column:	[		
							{header: "設定條件",key: "COL_NAME"},
							{header: "數值",key: "COL_DESC",
								input:{type:'TEXT', size:50 , width:45}
							},			
							{header: "備註 (序號)",key: "COL_NOTE",
								input:{type:'TEXT', size:30 , width:30}
							}	
							
						]
					});	
				
				grid2 = new TableUI ( {
					table: $("grid2"), pageSize : 0, allSortable:false,
						column:	[		
							{header: "土地座落",key: "A234_ADDR_NO", styles:{'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
								render : function(rec ,val){
									return rec.LOCATION1 +' '+ rec.LOCATION2 +'段 '+rec.LOCATION3  + '小段';
								
								}							
							},
							{header: "地號",key: "A234_LAND_NO",
								render : function(rec ,val){
									return (rec.LAND_NO1||"") + '-' + (rec.LAND_NO2||"");								
								}
							},			
							{header: "所有權人ID(序號)",key: "ID"},		
							{header: "移轉年月",key: "TRAN_DATE",
								render : function(rec , val){
									return Date.toInputROC(val || '' , '/');
								}
							},		
							{header: "正常價格單價",key: "PER_PRICE",
								input:{type:'NUMBER', size:10 , maxlength:12 , width:30,
								action:function( node , dataObj , textDiv, orgData ){
										var result = setValidRecord( node , dataObj , JsUtils.isNumeric(node.getValue()) , "[正常價格單價]請輸入數字格式！");
										if(result){
											alert(result);	
											node.value = '';
										}	
									}
								},
								render : function(rec , val){
									return val? JsUtils.isNumeric(val) ? MoneyFormat(val):val: 0 ;
								}
							},
							{header: "特定價格單價",key: "SPECIAL_PER_PRICE",
								input:{type:'NUMBER', size:10 , maxlength:12 , width:30,
								action:function( node , dataObj , textDiv, orgData ){
										var result = setValidRecord( node , dataObj , JsUtils.isNumeric(node.getValue()) , "[特定價格單價]請輸入數字格式！");
										if(result){
											alert(result);	
											node.value = '';
										}	
									}
								},
								render : function(rec , val){
									return val? JsUtils.isNumeric(val) ? MoneyFormat(val):val: 0 ;
								}
							}
						],pageChange:function(){
							var fun1 = $$("td[name=PER_PRICE] input");														
							fun1.each(
								function(elem){					
								elem.setAttribute("className" , "validate-number");		
								elem.setAttribute("datatype" , "number");								
								elem.setAttribute("fieldName" , "正常價格單價");
							});	
							var fun2 = $$("td[name=SPECIAL_PER_PRICE] input");														
							fun2.each(
								function(elem){					
								elem.setAttribute("className" , "validate-number");		
								elem.setAttribute("datatype" , "number");								
								elem.setAttribute("fieldName" , "特定價格單價");
							});		
						}
					});		

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

				//註冊DOM物件
				//click事件			
				$("btn_query").observe("click", buttons.doQuery );		
				$("btn_output").observe("click", buttons.doOutput );	
				$("btn_insert").observe("click", buttons.doInsert );	
				$("btn_update").observe("click", buttons.doUpdate );		
				$("btn_delete").observe("click", buttons.doDelete );		
				$("btn_confirm").observe("click", buttons.doConfirm );		
				$("btn_cancel").observe("click", buttons.doCancel );		
				//$("btn_glConfirm").observe("click", buttons.doGlConfirm );
				$("btn_glConfirm").observe("click", buttons.doGlConfirmCheck );
				$("btn_glReject").observe("click", buttons.doGlReject );		
				//$("btn_cgmConfirm").observe("click", buttons.doCGMConfirm );
				$("btn_cgmConfirm").observe("click", buttons.doCGMConfirmCheck );
				$("btn_gmConfirm").observe("click", buttons.doGMConfirm);		
				$("btn_Reject").observe("click", buttons.doReject );		
				$("btn_count").observe("click", buttons.doCount );		
				$("btn_getNearThing").observe("click", buttons.doGetNear );
				$("btn_reSend").observe("click", buttons.doReSend );	
				
				<%--新增評分--%>
				$('btn_add_1').observe('click' , doAdd1);	
				
				// 參、價格評估一、市場比較法之各筆土地單價直接帶入4、整體綜合修正表的訪價價格
				$('TD_PER_PRICE_A232_1').update($('PER_PRICE_A232_1').value);
				$('LAND_PRE_PRICE_A232_1').observe('blur', function() {
					var v = $F('LAND_PRE_PRICE_A232_1');
					$('TD_PER_PRICE_A232_1').update(v);
					$('PER_PRICE_A232_1').value = v;
				});
				$('LAND_PRE_PRICE_A232_2').observe('blur', function() {
					var v = $F('LAND_PRE_PRICE_A232_2');
					$('TD_PER_PRICE_A232_2').update(v);
					$('PER_PRICE_A232_2').value = v;
				});
				$('LAND_PRE_PRICE_A232_3').observe('blur', function() {
					var v = $F('LAND_PRE_PRICE_A232_3');
					$('TD_PER_PRICE_A232_3').update(v);
					$('PER_PRICE_A232_3').value = v;
				});
				
				//電子地圖
				$('btn_electronicMap').observe('click',function(event){buttons.doElectronicMap();});	
				
				$("star1").observe("click", buttons.doGetFile );	
				$("star2").observe("click", buttons.doGetFile );	
				$("LAND_MEASURE").observe("blur", function(event){				
					actions.nineFields($('LAND_MEASURE_TXT') , event.target.value , 'pureMoney');
					actions.doCount('PER_PRICE' , 'LAND_MEASURE' , 'TOTAL_PRICE');
				});	
				$("LAND_PER_PRICE").observe("blur", function(event){				
					actions.nineFields($('LAND_PER_PRICE_TXT') , event.target.value , 'money');
				});	
				$("MARKET_PER_PRICE").observe("blur", function(event){				
					actions.nineFields($('MARKET_PER_PRICE_TXT') , event.target.value , 'money');
				});	
				$("PER_PRICE").observe("blur", function(event){				
					actions.doCount('PER_PRICE' , 'LAND_MEASURE' , 'TOTAL_PRICE');
				});	

				$("PER_PRICEB").observe("blur", function(event){
					actions.doCount('PER_PRICEB' , 'LAND_MEASUREB' , 'TOTAL_PRICEB');
				});		
				$("LAND_MEASUREB").observe("blur", function(event){
					actions.doCount('PER_PRICEB' , 'LAND_MEASUREB' , 'TOTAL_PRICEB');
				});	
				
				//將此三個class的Input加入,如果改變就顯示在某個span上面
				var changeEventList = ['trade_s' ,'trade_t' ,'spec_a'];
				for(var i = 0 ; i < changeEventList.length ; i++){
					
					var fun = $$('#'+changeEventList[i]+' input').each(
						function(elem){								
							elem.observe("blur", 							
								function(event){									
									actions.nineFields($(elem.id +'_TXT') , elem.getValue() , 'percent');
								}						
							);	
						}
					
					);
				}						
				
				//將有'率'的欄位設定不能超過999 , 輸入時會提示
				var fun = $$('.rate5').each(
						function(elem){								
							elem.observe("blur", 							
								function(event){	
									
									var value = parseInt(event.target.getValue() );
									if(value > 1000){
										alert("此欄位數值不可超過3位數(1000)");
										event.target.value =0;
									}
								}						
							);	
						}
					
					);
				
				actions.dotheSame();
				
				$('BUILD_MEASURE_A232_1').observe('blur', function() {actions.doCountLAND_PRE_PRICE('BUILD_MEASURE_A232_1', 'TOTAL_PRICE_A232_1', 'LAND_PRE_PRICE_A232_1'); });
				$('BUILD_MEASURE_A232_2').observe('blur', function() {actions.doCountLAND_PRE_PRICE('BUILD_MEASURE_A232_2', 'TOTAL_PRICE_A232_2', 'LAND_PRE_PRICE_A232_2'); });
				$('BUILD_MEASURE_A232_3').observe('blur', function() {actions.doCountLAND_PRE_PRICE('BUILD_MEASURE_A232_3', 'TOTAL_PRICE_A232_3', 'LAND_PRE_PRICE_A232_3'); });
				$('TOTAL_PRICE_A232_1').observe('blur', function() {actions.doCountLAND_PRE_PRICE('BUILD_MEASURE_A232_1', 'TOTAL_PRICE_A232_1', 'LAND_PRE_PRICE_A232_1'); });
				$('TOTAL_PRICE_A232_2').observe('blur', function() {actions.doCountLAND_PRE_PRICE('BUILD_MEASURE_A232_2', 'TOTAL_PRICE_A232_2', 'LAND_PRE_PRICE_A232_2'); });
				$('TOTAL_PRICE_A232_3').observe('blur', function() {actions.doCountLAND_PRE_PRICE('BUILD_MEASURE_A232_3', 'TOTAL_PRICE_A232_3', 'LAND_PRE_PRICE_A232_3'); });

				$('BTN_FORMULA').observe('click', actions.doUseFORMULA );
				$('BTN_FORMULAB').observe('click', actions.doUseFORMULAB );
				
				//[20201126]連動產生「承作分區」
				$('USE_AREA1').observe('change', actions.doGetAreaCode930318 );
				$('URBAN_PROJECT').observe('change', actions.doGetAreaCode930318 );
				//[20201126]批示連動
				$('CAPT_EXAM').observe('change', function() { actions.chgExam('CAPT'); });
				$('BOSS_EXAM').observe('change', function() { actions.chgExam('BOSS'); });
				
				
				initValidation();	
				
				fix();

				displayMessage();				
								
				buttonAuth();
							
				autoFormatToNumber();
				
				autoFormatToDate();				
				//抓取前端傳過來的值	
				doinit();				
				
				<%--[20211018] 使用 InputUtility.js 調整成讓 CHORME textarea也能依照內容自動調整欄位高度--%>
				$$('textarea').each(function(e){	
					InputUtility.autoSizingTextarea.add(e); //註冊事件
				});
			}
	};	
	
	//初始參數
	function doinit(){
		var APPLY_ID = '${APPLY_ID}';
		if ( APPLY_ID === "") {
			//保留參數管理-取得受理編號
			APPLY_ID = CSRUtil.keepParamsManager.get('APPLY_ID');
		}	
		
		$('APPLY_ID').value = APPLY_ID;
		//如果不為空`就
		if($('APPLY_ID').value!==""){
			var isbeanName = 'DSA3_2400'=='${fromPublicBean}' ? true : false;
			if(isbeanName){
				var APPLY_ID = $('APPLY_ID').value.toUpperCase();
				//轉大寫回頁面 
				$('APPLY_ID').value = APPLY_ID;
			
				//保留參數管理-更新受理編號
				CSRUtil.keepParamsManager.put({'APPLY_ID': APPLY_ID });
				//載入資料
				var rtnMap = <c:choose><c:when test="${not empty rtnMap}">${rtnMap}</c:when><c:otherwise>{}</c:otherwise></c:choose>;
				var A232List = <c:choose><c:when test="${not empty A232List}">${A232List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
				var A233List = <c:choose><c:when test="${not empty A233List}">${A233List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
				var A231ListA = <c:choose><c:when test="${not empty A231ListA}">${A231ListA}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
				var A231ListB = <c:choose><c:when test="${not empty A231ListB}">${A231ListB}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
				var A234List = <c:choose><c:when test="${not empty A234List}">${A234List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
				//[20201126] 查詢【H區】批示歷程資料
				var A203List = <c:choose><c:when test="${not empty A203List}">${A203List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
				var resp ={
					'rtnMap' : rtnMap,
					'A232List' : A232List,
					'A233List' : A233List,
					'A231ListA' : A231ListA,
					'A231ListB' : A231ListB,
					'A234List' : A234List,
					'A203List' : A203List
				}
				writeDataToView(resp, 'allLoad');
			}else{
				buttons.doQuery();
			}
		}		

		//根據前端傳入的值來開關按鈕顯示範圍
		<c:choose>
		<c:when test='${OP eq 1}'> //輸入人員
			$('OP1').show();
			$('OP2').hide();
			$('table_H').style.display = 'none';
			$('table_R').style.display = 'none';
		</c:when>
		<c:otherwise> //覆核人員or 查詢人員 [20201201] block 改成 ''解chrome table長不滿問題
			$('OP2').show();
			$('OP1').hide();
			$('table_H').style.display = '';
			$('table_R').style.display = '';
		</c:otherwise>
	   </c:choose>	
	   
		//銀行人員：按鈕不顯示
		if (${IS_BANK_USER}){
			$('APPLY_ID').readOnly = true;
			$('table_R').style.display = 'none';
			$('OP1').hide();
			$('OP2').hide();
			$$('input[type="button"]').each( 
				function(elem) {
					if(elem.id=='btn_output'){
						return;
					}
					elem.hide();
				}
			);
			//[20201203] 開放銀行人員可以查詢電子地圖
			$("btn_electronicMap").show();//(1)電子地圖
		}
		
		<%-- [20230131]需求書230131003715 非放款鑑價部人員無法瀏覽相關欄位資訊--%>
		<c:if test="${showEXAM ne true}">
			$('table_P1').style.display = 'none';
		</c:if>
	}
	
};

</script>
</head>
<body>		
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width="8%" align="left" >
					受理編號
				</td>
				<td class="tbYellow2" width="30%" >
					<input id="APPLY_ID" type="text" class="text2" size="12" maxlength="11" />		
					<input id="encryptAPPLY_ID" name="encryptAPPLY_ID" type="hidden" value="${encryptAPPLY_ID}"/>
					<input type="hidden" id="LONGITUDE" name="LONGITUDE" class ="rtnMap" value="">
					<input type="hidden" id="LATITUDE" name="LATITUDE" class ="rtnMap" value="">
					<input type="hidden" id="MAP_AREA_CODE" name="MAP_AREA_CODE" class ="rtnMap" value="">
				</td>			
				<td class="tbYellow2"  align = "center">
					<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
					<input id = "btn_output" type = "button" class = "button" value = "列印"/>
					<input id=  "btn_electronicMap" type="button" class="button" value="(1)電子地圖">
				</td>
			</tr>
			<tr id = "OP1">
				<td  colspan = "3" align = "center" bgcolor = "#C7E49C">
					<input id = "btn_insert" type = "button" class = "button" value = "新增"/>
					<input id = "btn_update" type = "button" class = "button" value = "修正"/>
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"/>
					<input id = "btn_confirm" type = "button" class = "button" value = "呈核"/>
					<input id = "btn_cancel" type = "button" class = "button" value = "取消呈核"/>
					<img id = "star1" style="cursor: hand;" src="<%=imageBase%>/DS/star5.gif" border="0">					
				</td>
			</tr>
			<tr id = "OP2">
				<td  colspan = "3" align = "center" bgcolor = "#C7E49C">
					<input id = "btn_glConfirm" type = "button" class = "button" value = "組長覆核"/>
					<input id = "btn_glReject" type = "button" class = "button" value = "組長退回"/>
					<input id = "btn_cgmConfirm" type = "button" class = "button" value = "科主管覆核"/>
					<input id = "btn_gmConfirm" type = "button" class = "button" value = "部室主管覆核"/>
					<input id = "btn_Reject" type = "button" class = "button" value = "主管退回覆核"/>	
					<input id = "btn_reSend" type = "button" class = "button" value = "報告重送">			
					<img id = "star2" style="cursor: hand;" src="<%=imageBase%>/DS/star5.gif" border="0">		
				</td>
			</tr>
		</table>
	</form>	
	
	<form id="form2" name="form2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width="12%" align="left" >
					鑑價單位
				</td>
				<td class="tbYellow2" width = "12%">
					<Span id = "APPR_DEPT_NM_TXT" name ="APPR_DEPT_NM_TXT"/>
				</td>	
				<td class="tbYellow" width="12%" align="left" >
					承作分區
				</td>
				<td class="tbYellow2" width = "12%">
					<span id = "AREA_CODE_TXT" name ="AREA_CODE_TXT"></span>
					<input type="hidden" id="AREA_CODE_NM" name="AREA_CODE_NM" class = "rtnMap"  />
					<input type="hidden" id="AREA_CODE_930318" name="AREA_CODE_930318" class = "rtnMap"  />
					<input type="hidden" id="GAGE_ZIP" name="GAGE_ZIP" class = "rtnMap"  />
				</td>
				<td class="tbYellow" width="12%" align="left" >
					是否轉呈部室主管
				</td>
				<td class="tbYellow2" width = "12%">
					<input id = "IS_GM" type = "checkbox" class ="rtnMap"/>					
				</td>	
				<td class="tbYellow" width="14%" align="left" >
					目前呈核進度
				</td>
				<td class="tbYellow2"  width="14%" >
					<Span id = "APPR_PROCESS_NM_TXT" name ="APPR_PROCESS_NM_TXT"/>
				</td>				
			</tr>
			<tr>
				<td class="tbYellow" width="12%" align="left" >
					代理人
				</td>
				<td class="tbYellow2" width = "12%">
					<Span id = "AGENCY_NAME_TXT" name ="AGENCY_NAME_TXT" style="font-family:'EUDC'"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>
				<td class="tbYellow" width="12%" align="left" >
					分級項
				</td>
				<td class="tbYellow2" colspan="5" width="12%" >
					<select  id="GRADING_ITEM" name = "GRADING_ITEM" class ="rtnMap" fieldName = "分級項">							
						<c:forEach var="map" items="${GRADING_ITEM_LIST}">
							<option value='${map.key}'>${map.value}</option>
				       	</c:forEach>						
					</select>	
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" width="8%" align="left" >
					部室主管
				</td>
				<td class="tbYellow2" >
					<Span id = "GM_NM_TXT" name ="GM_NM_TXT" style="font-family:'EUDC'"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>	
				<td class="tbYellow" width="8%" align="left" >
					科主管
				</td>
				<td class="tbYellow2" >
					<Span id = "BOSS_NM_TXT" name ="BOSS_NM_TXT" style="font-family:'EUDC'"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>
				<td class="tbYellow" width="8%" align="left" >
					組長
				</td>
				<td class="tbYellow2" >
					<Span id = "CAPT_NM_TXT" name ="CAPT_NM_TXT" style="font-family:'EUDC'"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>	
				<td class="tbYellow" width="8%" align="left" >
					鑑價人員
				</td>
				<td class="tbYellow2" >
					<Span id = "APPR_NM_TXT" name ="APPR_NM_TXT" style="font-family:'EUDC'"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>				
			</tr>
			<tr>
				<td class="tbYellow" width="8%" align="left" >
					部室主管覆核日期
				</td>
				<td class="tbYellow2">
					<Span id = "GM_DATE_TXT" name ="GM_DATE_TXT"/>
				</td>	
				<td class="tbYellow" width="8%" align="left" >
					科主管覆核日期
				</td>
				<td class="tbYellow2">
					<Span id = "BOSS_DATE_TXT" name ="BOSS_DATE_TXT"/>
				</td>
				<td class="tbYellow" width="8%" align="left" >
					組長覆核日期
				</td>
				<td class="tbYellow2">
					<Span id = "CAPT_DATE_TXT" name ="CAPT_DATE_TXT"/>
				</td>	
				<td class="tbYellow" width="8%" align="left" >
					鑑價人員呈核日期
				</td>
				<td class="tbYellow2">
					<Span id = "APPR_DATE_TXT" name ="APPR_DATE_TXT"/>
				</td>				
			</tr>
		</table>
		<table id = "tableA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0" colspan = "8" align ="center">
					<b/>壹、標的基本資料
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width = "12%" align="left" >
					承作區
				</td>
				<td class="tbYellow2" width ="12%">
					<!--[20201126]disabled 改由系統判斷-->
					<select  id="CONTRACT_AREA" name = "CONTRACT_AREA" class ="rtnMap" fieldName = "承作區" disabled>							
						<c:forEach items="${CONTRACT_AREA_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>	
				</td>	
				<td class="tbYellow" width="12%" align="left" >
					列管區
				</td>
				<td class="tbYellow2" width="12%" >
					<select  id="RESTRICT_AREA" name = "RESTRICT_AREA" class ="rtnMap" fieldName = "列管區">							
						<c:forEach items="${RESTRICT_AREA_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>	
				</td>	
				<!--[20201126]新增欄位-->
				<td class="tbYellow" width="12%">鑑價記錄</td>
				<td class="tbYellow2" width="52%" colspan ="3" >
					<font color='red'>
					<span id='SLOGAN1'></span><br />
					<span id='SLOGAN2'></span>
					</font>
				</td>	
				<!-- 
				<td class="tbYellow" width="12%" align="left" >
					管制區
				</td>
				<td class="tbYellow2" width="52%" colspan ="3">
					<select  id="CONTROL_AREA" name = "CONTROL_AREA" class ="rtnMap" fieldName = "管制區">							
						<c:forEach items="${CONTROL_AREA_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>	
				</td>	
				 -->
			</tr>			
			<tr>
				<td class="tbYellow" width="12%" align="left" >
					買賣件
				</td>
				<td class="tbYellow2" width="12%">
					<select  id="IS_TRADE" name = "IS_TRADE" class ="rtnMap" fieldName = "買賣件">							
						<c:forEach items="${IS_TRADE_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>	
				</td>	
				<td class="tbYellow" width="12%" align="left" >
					買賣一方為公開發行公司
				</td>
				<td class="tbYellow2" width="12%">
					<select  id="IS_PUBLIC" name = "IS_PUBLIC" class ="rtnMap" fieldName = "買賣一方為公開發行公司">							
						<c:forEach items="${IS_TRADE_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>	
				</td>	
				<td class="tbYellow" width="12%" align="left" >
					已取得外部估價報告書
				</td>
				<td class="tbYellow2" width="12%">
					<%-- [20210714] C區原先的 "已取得外部估價報告書" 下拉選單隱藏，新增下拉選單內容 (原本下拉選單內容註解掉，不要刪除) --%>
					<select  id="IS_REPORT" name = "IS_REPORT" class ="rtnMap" fieldName = "已取得外部估價報告書">							
						<%-- 
						<c:forEach items="${IS_TRADE_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>
						--%>
						<c:forEach var="map" items="${IS_REPORT1_LIST}">
							<option value='${map.key}'>${map.value}</option>
			       		</c:forEach>							
					</select>	
				</td>	
				<td class="tbYellow" width="14%" align="left" >
					 未取得報告原因
				</td>
				<td class="tbYellow2" width="14%">
					<select  id="NOREPORT_REASON" name = "NOREPORT_REASON" class ="rtnMap" fieldName = "未取得報告原因">							
						<c:forEach items="${NOREPORT_REASON_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>	
				</td>	
			</tr>
			<tr>
				<!--[20201126]新增欄位-->
				<td class="tbYellow" align="left" >使用分區</td>
				<td class="tbYellow2" colspan="3">
					<select id="USE_AREA1" name = "USE_AREA1" class ="rtnMap" fieldName = "使用分區">							
						<c:forEach items="${USE_AREA1_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>	
					<%-- [20231110]問題單編號20230620-0159 使用分區欄位應增加輸入文字長度檢核--%>
					<input id="USE_AREA2" name="USE_AREA2" type="text" class ="rtnMap textAreaInfo" maxlength="10" size="10" fieldName = "使用分區2" />
				</td>		
				<td class="tbYellow" align="left" >生活圈</td>
				<td class="tbYellow2">
					<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%>
					<input type="text" id="SUBMKT_NAME" class = "rtnMap" readonly size="42"></input>
					<input type="hidden" id="SUBMKT_ID" class = "rtnMap"></input>
					<input type="hidden" id="SUBMKT_VERSION" class = "rtnMap"></input>
					<input type="hidden" id="AREA_CODE_MATCH_LEVEL" class = "rtnMap"></input>
				</td>
				<td class="tbYellow" align="left" >都市計畫案</td>
				<td class="tbYellow2">
					<select id="URBAN_PROJECT" name="URBAN_PROJECT" class="rtnMap" fieldName = "都市計畫案">		
						<option value="">無</option>					
					</select>	
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					一.土地標示
				</td>
				<td class="tbYellow2" colspan ="7">
					<textarea cols="88" rows="2" id="LAND_MARK" name="LAND_MARK" class ="rtnMap textAreaInfo"  maxLength ="300" fieldName = "土地標示" onkeyup="if(this.scrollHeight > 35) this.style.posHeight=this.scrollHeight"></textarea>
				</td>					
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					二.土地面積<br>
					總地坪<input type="text" class = "text2 rtnMap" id="LAND_MEASURE" name="LAND_MEASURE" maxLength ="10" size ="7" datatype = "number"/>
				</td>
				<td class="tbYellow2" colspan ="7">
					<textarea cols="88" rows="2" id="LAND_MEASURE_DESC" name="LAND_MEASURE_DESC"  class ="rtnMap" maxLength ="300" fieldName = "土地面積" onkeyup="if(this.scrollHeight > 35) this.style.posHeight=this.scrollHeight"></textarea>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					三.使用分區管制規定
				</td>
				<td class="tbYellow2" colspan ="7">
					<textarea cols="88" rows="2" id="USE_AREA_REG" name="USE_AREA_REG" class ="rtnMap" maxLength ="300" fieldName = "使用分區管制規定" onkeyup="if(this.scrollHeight > 35) this.style.posHeight=this.scrollHeight"></textarea>
				</td>					
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					四.公告現值
				</td>
				<td class="tbYellow2" colspan ="7">
					<textarea cols="88" rows="2" id="ANNOU_VALUE" name="ANNOU_VALUE" class ="rtnMap"  maxLength ="300" fieldName = "公告現值" onkeyup="if(this.scrollHeight > 35) this.style.posHeight=this.scrollHeight"></textarea>
				</td>					
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					五.現況
				</td>
				<td class="tbYellow2" colspan ="7">
					<textarea cols="88" rows="2" id="USE_STATUS" name="USE_STATUS" class ="rtnMap"  maxLength ="300" fieldName = "現況" onkeyup="if(this.scrollHeight > 35) this.style.posHeight=this.scrollHeight"></textarea>
				</td>					
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					六.建築規劃
				</td>
				<td class="tbYellow2" colspan ="7">
					<textarea cols="88" rows="2" id="BUILD_PLAN" name="BUILD_PLAN" class ="rtnMap"  maxLength ="300" fieldName = "建築規劃" onkeyup="if(this.scrollHeight > 35) this.style.posHeight=this.scrollHeight"></textarea>
				</td>					
			</tr>
			<tr>
				<td class="tbYellow"  align="left" colspan ="8">
					七.基地個別條件
				</td>							
			</tr>			
		</table>
		<table id='grid' width="100%"></table>	
		<table id ="tableB" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0" colspan ="4" align ="center">
					<b/>貳、區域環境
					<input id = "btn_getNearThing" type= "button" class = "button" value = "(2)環域分析"/>
				</td>
			</tr>			
			<tr>
				<td  width = "10%"  class="tbYellow" align="left" >
					一.基地位置
				</td>
				<td class="tbYellow2">
					<textarea cols="88" rows="4" id="BASE_DESC" name="BASE_DESC" class ="rtnMap"  maxLength ="300" fieldName = "基地位置" onkeyup="if(this.scrollHeight > 35) this.style.posHeight=this.scrollHeight"></textarea>
				</td>					
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					二.交通建設
				</td>
				<td class="tbYellow2">
					<textarea cols="88" rows="4" id="TRAFFIC_DESC" name="TRAFFIC_DESC" class ="rtnMap"  maxLength ="300" fieldName = "交通建設" onkeyup="if(this.scrollHeight > 35) this.style.posHeight=this.scrollHeight"></textarea>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					三.公園綠地
				</td>
				<td class="tbYellow2">
					<textarea cols="88" rows="2" id="PARK_DESC" name="PARK_DESC" class ="rtnMap"  maxLength ="300" fieldName = "公園綠地" onkeyup="if(this.scrollHeight > 35) this.style.posHeight=this.scrollHeight"></textarea>
				</td>					
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					四.學區
				</td>
				<td class="tbYellow2">
					<textarea cols="88" rows="2" id="SCHOOL_DESC" name="SCHOOL_DESC" class ="rtnMap"  maxLength ="300" fieldName = "學區" onkeyup="if(this.scrollHeight > 35) this.style.posHeight=this.scrollHeight"></textarea>
				</td>					
			</tr>
		</table>
	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0" colspan = "5" align ="center">
					<b/>參、價格評估
				</td>
			</tr>			
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					一、市場比較法
				</td>								
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					&nbsp﹝一﹞、土地市調案例
				</td>								
			</tr>
			<tr>
				<td class="tbBlue" width ="15%" align="center" colspan ="2">
					項目
				</td>	
				<td class="tbBlue" width ="25%" align="center" >
					甲
					<input type = "hidden"  id="CASE_NO_A232_1" name="CASE_NO_A232_1" class = "A232_1" />
				</td>
				<td class="tbBlue" width ="25%" align="center" >
					乙
					<input type = "hidden"  id="CASE_NO_A232_2" name="CASE_NO_A232_2" class = "A232_2" />
				</td>				
				<td class="tbBlue" width ="25%" align="center" >
					丙
					<input type = "hidden"  id="CASE_NO_A232_3" name="CASE_NO_A232_3" class = "A232_3"  />
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					價值日期
				</td>	
				<td class="tbBlue2" align="center" >
					<input type = "text" id="PRICE_DATE_A232_1" name="PRICE_DATE_A232_1" maxlength ="10" size ="11" class = "A232_1 text2"  />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="PRICE_DATE_A232_2" name="PRICE_DATE_A232_2" maxlength ="10" size ="11" class = "A232_2 text2"  />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="PRICE_DATE_A232_3" name="PRICE_DATE_A232_3" maxlength ="10" size ="11" class = "A232_3 text2"  />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					地段﹝地址﹞
				</td>	
				<td class="tbYellow2" align="center" >
					<input type = "text" id="ADDR_NO_A232_1" name="ADDR_NO_A232_1" size ="25" class = "A232_1 text2" alt="ch"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ADDR_NO_A232_2" name="ADDR_NO_A232_2" size ="25" class = "A232_2 text2" alt="ch"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ADDR_NO_A232_3" name="ADDR_NO_A232_3" size ="25" class = "A232_3 text2" alt="ch"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					使用分區
				</td>	
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="USE_AREA_A232_1" name="USE_AREA_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="USE_AREA_A232_2" name="USE_AREA_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="USE_AREA_A232_3" name="USE_AREA_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					建蔽率
				</td>	 
				<td class="tbYellow2" align="center" >
					<input type = "text" id="BUILD_RATE_A232_1" name="BUILD_RATE_A232_1" size ="8" maxLength ="7"class = "A232_1 text2 validate-number" datatype = "number" />%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUILD_RATE_A232_2" name="BUILD_RATE_A232_2" size ="8" maxLength ="7"class = "A232_2 text2 validate-number" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text" id="BUILD_RATE_A232_3" name="BUILD_RATE_A232_3" size ="8" maxLength ="7"class = "A232_3 text2 validate-number" datatype = "number"/>%
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					容積率
				</td>	
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="FLOOR_RATE_A232_1" name="FLOOR_RATE_A232_1" size ="8" maxLength ="7"class = "A232_1 text2 validate-number" datatype = "number"/>%
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="FLOOR_RATE_A232_2" name="FLOOR_RATE_A232_2" size ="8" maxLength ="7"class = "A232_2 text2 validate-number" datatype = "number"/>%
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="FLOOR_RATE_A232_3" name="FLOOR_RATE_A232_3" size ="8" maxLength ="7"class = "A232_3 text2 validate-number" datatype = "number"/>%
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					建築樓層
				</td>	
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="FLOOR_A232_1" name="FLOOR_A232_1" size ="25" class = "A232_1 text2"  />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="FLOOR_A232_2" name="FLOOR_A232_2" size ="25" class = "A232_2 text2"  />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text" id="FLOOR_A232_3" name="FLOOR_A232_3" size ="25" class = "A232_3 text2"  />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					屋齡
				</td>	
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="BUILD_AGE_A232_1" name="BUILD_AGE_A232_1" size ="25" class = "A232_1 text2"  />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="BUILD_AGE_A232_2" name="BUILD_AGE_A232_2" size ="25" class = "A232_2 text2"  />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text" id="BUILD_AGE_A232_3" name="BUILD_AGE_A232_3" size ="25" class = "A232_3 text2"  />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					面積
				</td>	
				<td class="tbYellow2" align="center" > 
					<input type = "text"  id="BUILD_MEASURE_A232_1" name="BUILD_MEASURE_A232_1" maxLength ="9" size ="10" class = "A232_1 text2 validate-number" datatype = "number" />坪
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUILD_MEASURE_A232_2" name="BUILD_MEASURE_A232_2" maxLength ="9"  size ="10" class = "A232_2 text2 validate-number" datatype = "number"/>坪
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUILD_MEASURE_A232_3" name="BUILD_MEASURE_A232_3" maxLength ="9" size ="10" class = "A232_3 text2 validate-number" datatype = "number"/>坪
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					結構
				</td>	
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="BUILD_TYPE_A232_1" name="BUILD_TYPE_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="BUILD_TYPE_A232_2" name="BUILD_TYPE_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="BUILD_TYPE_A232_3" name="BUILD_TYPE_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					土地面寬/縱深
				</td>	
				<td class="tbYellow2" align="center" >
					<input type = "text" id="LAND_WIDTH_A232_1" name="LAND_WIDTH_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text" id="LAND_WIDTH_A232_2" name="LAND_WIDTH_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text" id="LAND_WIDTH_A232_3" name="LAND_WIDTH_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					地形
				</td>	
				<td class="tbBlue2" align="center" >
					<input type = "text" id="LANDFORM_A232_1" name="LANDFORM_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text" id="LANDFORM_A232_2" name="LANDFORM_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text" id="LANDFORM_A232_3" name="LANDFORM_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					臨路狀況
				</td>	
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_STATUS_A232_1" name="ROAD_STATUS_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_STATUS_A232_2" name="ROAD_STATUS_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_STATUS_A232_3" name="ROAD_STATUS_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					交通條件
				</td>	
				<td class="tbBlue2" align="center" >
					<input type = "text" id="TRAFFIC_STATUS_A232_1" name="TRAFFIC_STATUS_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text" id="TRAFFIC_STATUS_A232_2" name="TRAFFIC_STATUS_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text" id="TRAFFIC_STATUS_A232_3" name="TRAFFIC_STATUS_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					公共設施
				</td>	
				<td class="tbYellow2" align="center" >
					<input type = "text" id="PUBLIC_INST_A232_1" name="PUBLIC_INST_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text" id="PUBLIC_INST_A232_2" name="PUBLIC_INST_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PUBLIC_INST_A232_3" name="PUBLIC_INST_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					嫌惡設施說明
				</td>	
				<td class="tbBlue2" align="center" >
					<input type = "text" id="DISLIKE_DESC_A232_1" name="DISLIKE_DESC_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text" id="DISLIKE_DESC_A232_2" name="DISLIKE_DESC_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="DISLIKE_DESC_A232_3" name="DISLIKE_DESC_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					交易型態
				</td>	
				<td class="tbYellow2" align="center" >
					<input type = "text" id="TRADE_TYPE_A232_1" name="TRADE_TYPE_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text" id="TRADE_TYPE_A232_2" name="TRADE_TYPE_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="TRADE_TYPE_A232_3" name="TRADE_TYPE_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					總價
				</td>	
				<td class="tbBlue2" align="center" >  
					<input type = "text"  id="TOTAL_PRICE_A232_1" name="TOTAL_PRICE_A232_1" maxLength ="11" size ="12" class = "A232_1 text2 validate-number" datatype = "number"/>萬
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="TOTAL_PRICE_A232_2" name="TOTAL_PRICE_A232_2" maxLength ="11" size ="12" class = "A232_2 text2 validate-number" datatype = "number"/>萬
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="TOTAL_PRICE_A232_3" name="TOTAL_PRICE_A232_3" maxLength ="11" size ="12" class = "A232_3 text2 validate-number" datatype = "number"/>萬
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					土地單價
				</td>	
				<td class="tbYellow2" align="center" > 
					<input type = "text"  id="LAND_PRE_PRICE_A232_1" name="LAND_PRE_PRICE_A232_1" maxLength ="11" size ="12" class = "A232_1 text2 validate-number" datatype = "number"/>萬/坪
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="LAND_PRE_PRICE_A232_2" name="LAND_PRE_PRICE_A232_2" maxLength ="11" size ="12" class = "A232_2 text2 validate-number" datatype = "number"/>萬/坪
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="LAND_PRE_PRICE_A232_3" name="LAND_PRE_PRICE_A232_3" maxLength ="11" size ="12" class = "A232_3 text2 validate-number" datatype = "number"/>萬/坪
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					資料來源
				</td>	
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="DATA_SOURCE_A232_1" name="DATA_SOURCE_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="DATA_SOURCE_A232_2" name="DATA_SOURCE_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="DATA_SOURCE_A232_3" name="DATA_SOURCE_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					與擔保品距離(公尺)
				</td>	
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DISTANCE_A232_1" name="DISTANCE_A232_1" size ="25" class = "A232_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DISTANCE_A232_2" name="DISTANCE_A232_2" size ="25" class = "A232_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DISTANCE_A232_3" name="DISTANCE_A232_3" size ="25" class = "A232_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="5">
					&nbsp﹝二﹞、訪價資料分析
				</td>												
			</tr>
			<tr>				
				<td class="tbYellow2" colspan ="5">
					<textarea cols="115" rows="8" id="VISIT_DESC_M" name="VISIT_DESC_M" colspan="3"  class ="rtnMap textAreaOldSys" maxLength ="1500" fieldName = "市場比較-訪價資料分析" onkeyup="if(this.scrollHeight > 110) this.style.posHeight=this.scrollHeight"></textarea>
				</td>								
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="5">
					&nbsp﹝三﹞、權數加權與依據及判斷
				</td>												
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="5">
					1、擔保品與訪價標的個別因素修正比率表
				</td>												
			</tr>
			<tr>
				<td class="tbBlue" align="center" colspan ="2" >
					修正因素
				</td>	
				<td class="tbBlue" align="center" >
					甲
				</td>
				<td class="tbBlue" align="center" >
					乙
				</td>				
				<td class="tbBlue" align="center" >
					丙
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" rowspan ="8">
					基地個別因素
				</td>
				<td class="tbYellow" align="left" >
					使用分區
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="USE_AREA_RATE_A232_1" name="USE_AREA_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="USE_AREA_RATE_A232_2" name="USE_AREA_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="USE_AREA_RATE_A232_3" name="USE_AREA_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					土地面積
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="LAND_SPACE_RATE_A232_1" name="LAND_SPACE_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="LAND_SPACE_RATE_A232_2" name="LAND_SPACE_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="LAND_SPACE_RATE_A232_3" name="LAND_SPACE_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					正面路寬
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_WIDTH_RATE_A232_1" name="ROAD_WIDTH_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_WIDTH_RATE_A232_2" name="ROAD_WIDTH_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_WIDTH_RATE_A232_3" name="ROAD_WIDTH_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					基地形狀
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_RATE_A232_1" name="BASE_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_RATE_A232_2" name="BASE_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_RATE_A232_3" name="BASE_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					寬深度修正
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="WIDTH_RATE_A232_1" name="WIDTH_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="WIDTH_RATE_A232_2" name="WIDTH_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="WIDTH_RATE_A232_3" name="WIDTH_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					臨路狀況
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_STATUS_RATE_A232_1" name="ROAD_STATUS_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_STATUS_RATE_A232_2" name="ROAD_STATUS_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_STATUS_RATE_A232_3" name="ROAD_STATUS_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					視野景觀
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="VIEW_RATE_A232_1" name="VIEW_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="VIEW_RATE_A232_2" name="VIEW_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="VIEW_RATE_A232_3" name="VIEW_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					綜合修正率
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_SPEC_RATE_A232_1" name="BASE_SPEC_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number" readonly />%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_SPEC_RATE_A232_2" name="BASE_SPEC_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number" readonly />%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_SPEC_RATE_A232_3" name="BASE_SPEC_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number" readonly />%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="5">
					2、擔保品與訪價標的區域環境修正比率表
				</td>												
			</tr>
			<tr>
				<td class="tbBlue" align="center" colspan ="2" >
					修正因素
				</td>	
				<td class="tbBlue" align="center" >
					甲
				</td>
				<td class="tbBlue" align="center" >
					乙
				</td>				
				<td class="tbBlue" align="center" >
					丙
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" rowspan ="12">
					區域環境因素
				</td>
				<td class="tbYellow" align="left" >
					交通便捷性
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUS_RATE_A232_1" name="BUS_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUS_RATE_A232_2" name="BUS_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUS_RATE_A232_3" name="BUS_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					學校接近程度
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SCHOOL_RATE_A232_1" name="SCHOOL_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SCHOOL_RATE_A232_2" name="SCHOOL_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SCHOOL_RATE_A232_3" name="SCHOOL_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					市場接近程度
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="MARKET_RATE_A232_1" name="MARKET_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="MARKET_RATE_A232_2" name="MARKET_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="MARKET_RATE_A232_3" name="MARKET_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					公園接近程度
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PARK_RATE_A232_1" name="PARK_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PARK_RATE_A232_2" name="PARK_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PARK_RATE_A232_3" name="PARK_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					座落區域
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="LOCATION_RATE_A232_1" name="LOCATION_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="LOCATION_RATE_A232_2" name="LOCATION_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="LOCATION_RATE_A232_3" name="LOCATION_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					商業活動
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUSINESS_RATE_A232_1" name="BUSINESS_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUSINESS_RATE_A232_2" name="BUSINESS_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUSINESS_RATE_A232_3" name="BUSINESS_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					鄰地使用
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="NEAR_RATE_A232_1" name="NEAR_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="NEAR_RATE_A232_2" name="NEAR_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="NEAR_RATE_A232_3" name="NEAR_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					嫌惡設施
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DISLIKE_RATE_A232_1" name="DISLIKE_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DISLIKE_RATE_A232_2" name="DISLIKE_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DISLIKE_RATE_A232_3" name="DISLIKE_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
				<tr>
				<td class="tbYellow" align="left"  >
					寧適性
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="CONFORM_RATE_A232_1" name="CONFORM_RATE_A232_1" size ="7"  class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="CONFORM_RATE_A232_2" name="CONFORM_RATE_A232_2" size ="7"  class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="CONFORM_RATE_A232_3" name="CONFORM_RATE_A232_3" size ="7"  class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					未來發展
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DEVELOP_RATE_A232_1" name="DEVELOP_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DEVELOP_RATE_A232_2" name="DEVELOP_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DEVELOP_RATE_A232_3" name="DEVELOP_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					其他條件
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="OTHER_RATE_A232_1" name="OTHER_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="OTHER_RATE_A232_2" name="OTHER_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="OTHER_RATE_A232_3" name="OTHER_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left"  >
					綜合修正率
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="AREA_UPDATE_RATE_A232_1" name="AREA_UPDATE_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number" readonly />%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="AREA_UPDATE_RATE_A232_2" name="AREA_UPDATE_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number" readonly />%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="AREA_UPDATE_RATE_A232_3" name="AREA_UPDATE_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number" readonly />%
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="5">
					3、擔保品與訪價標的之交易情況、交易時間、個案加權數調整率如下
				</td>												
			</tr>
			<tr>
				<td class="tbBlue" align="center" colspan ="2" >
					項目
				</td>	
				<td class="tbBlue" align="center" >
					甲
				</td>
				<td class="tbBlue" align="center" >
					乙
				</td>				
				<td class="tbBlue" align="center" >
					丙
				</td>	
			</tr>
			<tr id = "trade_s">				
				<td class="tbYellow" align="left" colspan ="2">
					交易情況調整率
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="TRADE_STATUS_RATE_A232_1" name="TRADE_STATUS_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="TRADE_STATUS_RATE_A232_2" name="TRADE_STATUS_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="TRADE_STATUS_RATE_A232_3" name="TRADE_STATUS_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>										
			</tr>
			<tr id="trade_t">				
				<td class="tbYellow" align="left" colspan ="2">
					交易時間調整率
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="TRADE_TIME_RATE_A232_1" name="TRADE_TIME_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="TRADE_TIME_RATE_A232_2" name="TRADE_TIME_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="TRADE_TIME_RATE_A232_3" name="TRADE_TIME_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number default100" datatype = "number"/>%
				</td>										
			</tr>
			<tr id="spec_a">				
				<td class="tbYellow" align="left" colspan ="2">
					個案加權數
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SPEC_ADJUST_RATE_A232_1" name="SPEC_ADJUST_RATE_A232_1" size ="7" class = "A232_1 text2 rate5 validate-number" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SPEC_ADJUST_RATE_A232_2" name="SPEC_ADJUST_RATE_A232_2" size ="7" class = "A232_2 text2 rate5 validate-number" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SPEC_ADJUST_RATE_A232_3" name="SPEC_ADJUST_RATE_A232_3" size ="7" class = "A232_3 text2 rate5 validate-number" datatype = "number"/>%
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="5">
					4、整體綜合修正表及價格推算
				</td>												
			</tr>
			<tr>
				<td class="tbBlue" align="center" colspan ="2" >
					項目
				</td>	
				<td class="tbBlue" align="center" >
					甲
				</td>
				<td class="tbBlue" align="center" >
					乙
				</td>				
				<td class="tbBlue" align="center" >
					丙
				</td>	
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					訪價
				</td>
				<td class="tbYellow2" align="center" >
					<span id="TD_PER_PRICE_A232_1" ></span>萬/坪
					<input type = "hidden"  id="PER_PRICE_A232_1" name="PER_PRICE_A232_1"  class = "A232_1 text2 validate-number" />
				</td>
				<td class="tbYellow2" align="center" >
					<span id="TD_PER_PRICE_A232_2" ></span>萬/坪
					<input type = "hidden"  id="PER_PRICE_A232_2" name="PER_PRICE_A232_2"  class = "A232_2 text2 validate-number" />
				</td>
				<td class="tbYellow2" align="center" >
					<span id="TD_PER_PRICE_A232_3" ></span>萬/坪
					<input type = "hidden"  id="PER_PRICE_A232_3" name="PER_PRICE_A232_3"  class = "A232_3 text2 validate-number" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					交易情況調整率
				</td>
				<td class="tbYellow2" align="center" >
					<span id="TRADE_STATUS_RATE_A232_1_TXT" name = "TRADE_STATUS_RATE_A232_1_TXT"/>
				</td>
				<td class="tbYellow2" align="center" >
					<span id="TRADE_STATUS_RATE_A232_2_TXT" name = "TRADE_STATUS_RATE_A232_2_TXT"/>
				</td>
				<td class="tbYellow2" align="center" >
					<span id="TRADE_STATUS_RATE_A232_3_TXT" name = "TRADE_STATUS_RATE_A232_3_TXT"/>
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					交易情況修正後價格
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="TRADE_STATUS_PRICE_A232_1" name="TRADE_STATUS_PRICE_A232_1" class = "A232_1" datatype = "number"/>
					<span id="TRADE_STATUS_PRICE_A232_1_TXT" name = "TRADE_STATUS_PRICE_A232_1_TXT"></span>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="TRADE_STATUS_PRICE_A232_2" name="TRADE_STATUS_PRICE_A232_2" class = "A232_2" datatype = "number"/>
					<span id="TRADE_STATUS_PRICE_A232_2_TXT" name = "TRADE_STATUS_PRICE_A232_2_TXT"></span>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="TRADE_STATUS_PRICE_A232_3" name="TRADE_STATUS_PRICE_A232_3" class = "A232_3" datatype = "number"/>
					<span id="TRADE_STATUS_PRICE_A232_3_TXT" name = "TRADE_STATUS_PRICE_A232_3_TXT"></span>
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					交易時間調整率
				</td>
				<td class="tbYellow2" align="center" >
					<span id="TRADE_TIME_RATE_A232_1_TXT" />					
				</td>
				<td class="tbYellow2" align="center" >
					<span id="TRADE_TIME_RATE_A232_2_TXT" />		
				</td>
				<td class="tbYellow2" align="center" >
					<span id="TRADE_TIME_RATE_A232_3_TXT" />		
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					交易時間修正後價格
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="TRADE_TIME_PRICE_A232_1" name="TRADE_TIME_PRICE_A232_1" class = "A232_1" datatype = "number"/>
					<span id="TRADE_TIME_PRICE_A232_1_TXT" name = "TRADE_TIME_PRICE_A232_1_TXT"></span>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="TRADE_TIME_PRICE_A232_2" name="TRADE_TIME_PRICE_A232_2" class = "A232_2" datatype = "number"/>
					<span id="TRADE_TIME_PRICE_A232_2_TXT" name = "TRADE_TIME_PRICE_A232_2_TXT"></span>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="TRADE_TIME_PRICE_A232_3" name="TRADE_TIME_PRICE_A232_3" class = "A232_3" datatype = "number"/>
					<span id="TRADE_TIME_PRICE_A232_3_TXT" name = "TRADE_TIME_PRICE_A232_3_TXT"></span>
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					區域因素修正率
				</td>
				<td class="tbYellow2" align="center" >
					<span id="AREA_UPDATE_RATE_A232_1_TXT" name = "AREA_UPDATE_RATE_A232_1_TXT"/>	
				</td>
				<td class="tbYellow2" align="center" >
					<span id="AREA_UPDATE_RATE_A232_2_TXT" name = "AREA_UPDATE_RATE_A232_2_TXT"/>	
				</td>
				<td class="tbYellow2" align="center" >
					<span id="AREA_UPDATE_RATE_A232_3_TXT" name = "AREA_UPDATE_RATE_A232_3_TXT"/>	
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					區域因素修正後價格
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="AREA_UPDATE_PRICE_A232_1" name="AREA_UPDATE_PRICE_A232_1" class = "A232_1" datatype = "number"/>
					<span id="AREA_UPDATE_PRICE_A232_1_TXT" name = "AREA_UPDATE_PRICE_A232_1_TXT"></span>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="AREA_UPDATE_PRICE_A232_2" name="AREA_UPDATE_PRICE_A232_2" class = "A232_2" datatype = "number"/>
					<span id="AREA_UPDATE_PRICE_A232_2_TXT" name = "AREA_UPDATE_PRICE_A232_2_TXT"></span>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="AREA_UPDATE_PRICE_A232_3" name="AREA_UPDATE_PRICE_A232_3" class = "A232_3" datatype = "number"/>
					<span id="AREA_UPDATE_PRICE_A232_3_TXT" name = "AREA_UPDATE_PRICE_A232_3_TXT"></span>	
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					基地個別因素修正率
				</td>
				<td class="tbYellow2" align="center" >
					<span id="BASE_SPEC_RATE_A232_1_TXT" name = "BASE_SPEC_RATE_A232_1_TXT" />						
				</td>
				<td class="tbYellow2" align="center" >
					<span id="BASE_SPEC_RATE_A232_2_TXT" name = "BASE_SPEC_RATE_A232_2_TXT" />		
				</td>
				<td class="tbYellow2" align="center" >
					<span id="BASE_SPEC_RATE_A232_3_TXT" name = "BASE_SPEC_RATE_A232_3_TXT" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					基地個別因素修正後價格
				</td>
				<td class="tbYellow2" align="center" >					
					<input type = "hidden"  id="BASE_SPEC_PRICE_A232_1" name="BASE_SPEC_PRICE_A232_1" class = "A232_1" datatype = "number"	/>
					<span id="BASE_SPEC_PRICE_A232_1_TXT" name = "BASE_SPEC_PRICE_A232_1_TXT"></span>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="BASE_SPEC_PRICE_A232_2" name="BASE_SPEC_PRICE_A232_2" class = "A232_2" datatype = "number"	/>
					<span id="BASE_SPEC_PRICE_A232_2_TXT" name = "BASE_SPEC_PRICE_A232_2_TXT"></span>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="BASE_SPEC_PRICE_A232_3" name="BASE_SPEC_PRICE_A232_3" class = "A232_3" datatype = "number"	/>
					<span id="BASE_SPEC_PRICE_A232_3_TXT" name = "BASE_SPEC_PRICE_A232_3_TXT"></span>
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					個案加權數
				</td>
				<td class="tbYellow2" align="center" >
					<span id="SPEC_ADJUST_RATE_A232_1_TXT" />		
				</td>
				<td class="tbYellow2" align="center" >
					<span id="SPEC_ADJUST_RATE_A232_2_TXT" />		
				</td>
				<td class="tbYellow2" align="center" >
					<span id="SPEC_ADJUST_RATE_A232_3_TXT" />		
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					加權後價格
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="SPEC_ADJUST_PRICE_A232_1" name="SPEC_ADJUST_PRICE_A232_1" class = "A232_1" datatype = "number"/>
					<span id="SPEC_ADJUST_PRICE_A232_1_TXT" name = "SPEC_ADJUST_PRICE_A232_1_TXT"></span>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="SPEC_ADJUST_PRICE_A232_2" name="SPEC_ADJUST_PRICE_A232_2" class = "A232_2" datatype = "number"/>
					<span id="SPEC_ADJUST_PRICE_A232_2_TXT" name = "SPEC_ADJUST_PRICE_A232_2_TXT"></span>
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "hidden"  id="SPEC_ADJUST_PRICE_A232_3" name="SPEC_ADJUST_PRICE_A232_3" class = "A232_3" datatype = "number"/>
					<span id="SPEC_ADJUST_PRICE_A232_3_TXT" name = "SPEC_ADJUST_PRICE_A232_3_TXT"></span>
				</td>										
			</tr>
			<tr>
				<td class="tbYellow2" align="left" colspan = "5">
					依市場比較法，修正擔保品與訪價標的各項差異因素，推定價格為 
					<input type = "text"  id="MARKET_PER_PRICE" name="MARKET_PER_PRICE" maxlength = "11" size ="10" class ="rtnMap text2 validate-number" datatype = "number"/>萬/坪
					<input type = "button" class ="button" id="btn_count" value ="試算"/>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					<br>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					二、土地開發分析法
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					&nbsp﹝一﹞、房價市調案例
				</td>	
			</tr>
			<tr>
				<td class="tbBlue" align="center" colspan ="2" >
					項目
				</td>	
				<td class="tbBlue" align="center" >
					案例一
					<input type = "hidden" id="CASE_NO_A233_1" name="CASE_NO_A233_1"  class = "A233_1" />
				</td>
				<td class="tbBlue" align="center" >
					案例二
					<input type = "hidden" id="CASE_NO_A233_2" name="CASE_NO_A233_2"  class = "A233_2" />
				</td>				
				<td class="tbBlue" align="center" >
					案例三
					<input type = "hidden" id="CASE_NO_A233_3" name="CASE_NO_A233_3"  class = "A233_3" />
				</td>	
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					價格日期
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PRICE_DATE_A233_1" name="PRICE_DATE_A233_1" maxlength ="10" size ="11" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PRICE_DATE_A233_2" name="PRICE_DATE_A233_2" maxlength ="10" size ="11" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PRICE_DATE_A233_3" name="PRICE_DATE_A233_3" maxlength ="10" size ="11" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					案名
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="CASE_NAME_A233_1" name="CASE_NAME_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="CASE_NAME_A233_2" name="CASE_NAME_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="CASE_NAME_A233_3" name="CASE_NAME_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					使用分區
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="USE_AREA_A233_1" name="USE_AREA_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="USE_AREA_A233_2" name="USE_AREA_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="USE_AREA_A233_3" name="USE_AREA_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					基地面積
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_MEASURE_A233_1" name="BASE_MEASURE_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_MEASURE_A233_2" name="BASE_MEASURE_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_MEASURE_A233_3" name="BASE_MEASURE_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					基地座落
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_STATUS_A233_1" name="BASE_STATUS_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_STATUS_A233_2" name="BASE_STATUS_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BASE_STATUS_A233_3" name="BASE_STATUS_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					產品型態
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PRODUCT_TYPE_A233_1" name="PRODUCT_TYPE_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PRODUCT_TYPE_A233_2" name="PRODUCT_TYPE_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PRODUCT_TYPE_A233_3" name="PRODUCT_TYPE_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					興建樓層
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="FLOOR_A233_1" name="FLOOR_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="FLOOR_A233_2" name="FLOOR_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="FLOOR_A233_3" name="FLOOR_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					建物構造
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUILD_STRUCTION_A233_1" name="BUILD_STRUCTION_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUILD_STRUCTION_A233_2" name="BUILD_STRUCTION_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUILD_STRUCTION_A233_3" name="BUILD_STRUCTION_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					主力坪數
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="MAIN_MEASURE_A233_1" name="MAIN_MEASURE_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="MAIN_MEASURE_A233_2" name="MAIN_MEASURE_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="MAIN_MEASURE_A233_3" name="MAIN_MEASURE_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					屋齡
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUILD_AGE_A233_1" name="BUILD_AGE_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUILD_AGE_A233_2" name="BUILD_AGE_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="BUILD_AGE_A233_3" name="BUILD_AGE_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					戶數
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="HOUSE_NO_A233_1" name="HOUSE_NO_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="HOUSE_NO_A233_2" name="HOUSE_NO_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="HOUSE_NO_A233_3" name="HOUSE_NO_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					銷售率
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SALE_RATE_A233_1" name="SALE_RATE_A233_1" size ="7" class = "A233_1 text2 rate5 validate-number" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SALE_RATE_A233_2" name="SALE_RATE_A233_2" size ="7" class = "A233_2 text2 rate5 validate-number" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SALE_RATE_A233_3" name="SALE_RATE_A233_3" size ="7" class = "A233_3 text2 rate5 validate-number" datatype = "number"/>%
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					臨路條件
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_STATUS_A233_1" name="ROAD_STATUS_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_STATUS_A233_2" name="ROAD_STATUS_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="ROAD_STATUS_A233_3" name="ROAD_STATUS_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					產品塑造條件
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PRODUCT_POSITION_A233_1" name="PRODUCT_POSITION_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PRODUCT_POSITION_A233_2" name="PRODUCT_POSITION_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PRODUCT_POSITION_A233_3" name="PRODUCT_POSITION_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					二樓以上均價
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SECOND_FLOOR_PRICE_A233_1" name="SECOND_FLOOR_PRICE_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SECOND_FLOOR_PRICE_A233_2" name="SECOND_FLOOR_PRICE_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="SECOND_FLOOR_PRICE_A233_3" name="SECOND_FLOOR_PRICE_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					地面層單價
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="FIRST_FLOOR_PRICE_A233_1" name="FIRST_FLOOR_PRICE_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="FIRST_FLOOR_PRICE_A233_2" name="FIRST_FLOOR_PRICE_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="FIRST_FLOOR_PRICE_A233_3" name="FIRST_FLOOR_PRICE_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					車位成交價
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PARK_PRICE_A233_1" name="PARK_PRICE_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PARK_PRICE_A233_2" name="PARK_PRICE_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="PARK_PRICE_A233_3" name="PARK_PRICE_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan ="2">
					資料來源
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DATA_SOURCE_A233_1" name="DATA_SOURCE_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DATA_SOURCE_A233_2" name="DATA_SOURCE_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbYellow2" align="center" >
					<input type = "text"  id="DATA_SOURCE_A233_3" name="DATA_SOURCE_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan ="2">
					與擔保品距離(公尺)
				</td>	
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="DISTANCE_A233_1" name="DISTANCE_A233_1" size ="25" class = "A233_1 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="DISTANCE_A233_2" name="DISTANCE_A233_2" size ="25" class = "A233_2 text2" />
				</td>
				<td class="tbBlue2" align="center" >
					<input type = "text"  id="DISTANCE_A233_3" name="DISTANCE_A233_3" size ="25" class = "A233_3 text2" />
				</td>										
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan = "5">
					&nbsp﹝二﹞、訪價資料分析
				</td>	
			</tr>
			<tr>				
				<td class="tbYellow2" colspan ="5">
					<textarea cols="115" rows="8" id="VISIT_DESC_L" name="VISIT_DESC_L" colspan="3" class ="rtnMap textAreaOldSys" maxLength ="1500" fieldName = "土地開發-訪價資料分析" onkeyup="if(this.scrollHeight > 110) this.style.posHeight=this.scrollHeight"></textarea>
				</td>								
			</tr>
			<tr>				
				<td class="tbYellow" align="left" colspan = "5">
					&nbsp﹝三﹞、設定條件及價格推算
				</td>	
			</tr>
			</table>
		<table id='grid1' width="100%"></table>		
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow2" align="left" colspan = "5">
					依土地開發分析法﹝如附件﹞，推定價格為 
					<input type = "text"  id="LAND_PER_PRICE" name="LAND_PER_PRICE" maxLength ="11" size ="10" class ="rtnMap text2 validate-number" datatype = "number"/>萬/坪
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					三、不動產業者、國泰建設之看法
				</td>	
			</tr>
				<tr>				
				<td class="tbYellow2" colspan ="5">
					<textarea cols="95" rows="6" id="OTHER_DESC" name="OTHER_DESC" colspan="3" class ="rtnMap text2" maxLength ="1000" fieldName = "仲介、鑑價公司、國泰建設之看法" onkeyup="if(this.scrollHeight > 90) this.style.posHeight=this.scrollHeight"></textarea>
				</td>								
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0" colspan = "5" align ="center">
					<b/>肆、綜合評估
				</td>
			</tr>	
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					一、正常價格
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" align="left" colspan = "5">
					&nbsp﹝一﹞以市場比較法推土地單價&nbsp
					<b><span id="MARKET_PER_PRICE_TXT" name="MARKET_PER_PRICE_TXT" datatype = "number"/></b>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" align="left" colspan = "5">
					&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp以土地開發分析法推土地單價&nbsp
					<b><span id="LAND_PER_PRICE_TXT" name="LAND_PER_PRICE_TXT" datatype = "number"/></b>					
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					&nbsp﹝二﹞權數加權判斷及理由
				</td>
			</tr>
			<tr>
				<td class="tbBlue" width ="25%" align="center" colspan ="2">
					估價方法
				</td>	
				<td class="tbBlue" width ="25%" align="center" >
					加權數
				</td>
				<td class="tbBlue" width ="50%" align="center" colspan ="2">
					說明
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "2">
					市場比較法
				</td>
				<td class="tbYellow2" align="center" >			
					<input type = "text"  id="MARKET_RATE" name="MARKET_RATE"  size ="8" class ="rtnMap text2 rate5 validate-number" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" colspan = "2">					
					<input type = "text"  id="MARKET_DESC" name="MARKET_DESC" size ="34" class ="rtnMap text2"  maxLength ="300" fieldName = "正常價格-市場比較法說明"/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "2">
					土地開發分析法
				</td>
				<td class="tbYellow2" align="center" >					
					<input type = "text"  id="DEVELOP_RATE" name="DEVELOP_RATE" size ="8" class ="rtnMap text2 rate5 validate-number" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" colspan = "2">					
					<input type = "text"  id="DEVELOP_DESC" name="DEVELOP_DESC" size ="34" class ="rtnMap text2"  maxLength ="300" fieldName = "正常價格-土地開發法說明"/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					土地單價試算公式
					<input id="BTN_FORMULA" class="button" type="button" value="公式" >
				</td>				
			</tr>
			<tr>
				<td class="tbYellow2" colspan ="5">
					<textarea cols="95" rows="3" id="FORMULA" name="FORMULA"  class ="rtnMap"  maxLength ="500" fieldName ="正常價格-土地單價試算公式" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					&nbsp﹝三﹞建議價格
				</td>
			</tr>
			<tr>
				<%-- [20221109] colspan="5"改為"3" --%>
				<td class="tbYellow2" align="left" colspan = "3">					
					土地總價
					<input type = "text"  id="PER_PRICE" name="PER_PRICE" maxLength ="12" size ="10" class ="rtnMap text2 validate-number" datatype="number"/>
					萬&nbsp＊&nbsp
					<b><span id="LAND_MEASURE_TXT" name = "LAND_MEASURE_TXT"></span></b> &nbsp 坪&nbsp＝	
					<b><span id="TOTAL_PRICE_TXT" name = "TOTAL_PRICE_TXT"></span></b>
					<input type = "hidden"  id="TOTAL_PRICE" name="TOTAL_PRICE" class ="rtnMap validate-number" datatype = "number"/>&nbsp萬
				</td>
				<%-- [20221109] 新增設計容積率(正常) --%>
				<td class="tbYellow2" align="left" colspan = "2">
					設計容積率(正常)
					<input type = "text"  id="BOSS_REG_FLAR" name="BOSS_REG_FLAR" maxLength ="8" size ="10" class ="rtnMap text2 checkNumeralFormat_5_2" datatype="number"/>
					%
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					&nbsp﹝四﹞綜合結論
				</td>	
			</tr>
			<tr>				
				<td class="tbYellow2" colspan ="5">
					<textarea cols="95" rows="4" id="CONCLUSION_DESC" name="CONCLUSION_DESC" colspan="3" class ="rtnMap text2" maxLength ="400" fieldName ="正常價格-綜合結論" onkeyup="if(this.scrollHeight > 90) this.style.posHeight=this.scrollHeight"></textarea>
				</td>								
			</tr>					
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					二、特﹝限﹞定價格
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" align="left" colspan = "5">
					&nbsp﹝一﹞以市場比較法推土地單價
					<input type = "text"  id="MARKET_PER_PRICEB" name="MARKET_PER_PRICEB" maxlength = "11" size ="10" class ="rtnMap text2 validate-number" datatype="number"/>萬/坪
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" align="left" colspan = "5">
					&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp以土地開發分析法推土地單價
					<input type = "text"  id="LAND_PER_PRICEB" name="LAND_PER_PRICEB" maxlength = "11" size ="10" class ="rtnMap text2 validate-number" datatype="number"/>萬/坪
				</td>
			</tr>	
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					&nbsp﹝二﹞權數加權判斷及理由
				</td>
			</tr>
			<tr>
				<td class="tbBlue" width ="25%" align="center" colspan ="2">
					估價方法
				</td>	
				<td class="tbBlue" width ="25%" align="center" >
					加權數
				</td>
				<td class="tbBlue" width ="50%" align="center" colspan ="2">
					說明
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "2">
					市場比較法
				</td>
				<td class="tbYellow2" align="center" >					
					<input type = "text"  id="MARKET_RATEB" name="MARKET_RATEB" size ="7" class ="rtnMap text2 rate5 validate-number" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" colspan = "2">					
					<input type = "text"  id="MARKET_DESCB" name="MARKET_DESCB" size ="34" class ="rtnMap text2"  maxLength ="300" fieldName = "特﹝限﹞定價格-市場比較法"/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "2">
					土地開發分析法
				</td>
				<td class="tbYellow2" align="center" >					
					<input type = "text"  id="DEVELOP_RATEB" name="DEVELOP_RATEB" size ="7" class ="rtnMap text2 rate5 validate-number" datatype = "number"/>%
				</td>
				<td class="tbYellow2" align="center" colspan = "2">					
					<input type = "text"  id="DEVELOP_DESCB" name="DEVELOP_DESCB" size ="34" class ="rtnMap text2"  maxLength ="300" fieldName = "特﹝限﹞定價格-土地開發法"/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					土地單價試算公式
					<input id="BTN_FORMULAB" class="button" type="button" value="公式" >
				</td>				
			</tr>
			<tr>
				<td class="tbYellow2" colspan ="5">
					<textarea cols="95" rows="3" id="FORMULAB" name="FORMULAB"  class ="rtnMap text2 "  maxLength ="500" fieldName = "特﹝限﹞定價格-土地單價試算公式" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					&nbsp﹝三﹞建議價格
				</td>
			</tr>
			<tr>
				<%-- [20221109] colspan="5"改為"3" --%>
				<td class="tbYellow2" align="left" colspan = "3">					
					土地總價
					<input type = "text"  id="PER_PRICEB" name="PER_PRICEB" maxLength ="12" size ="10" class ="rtnMap text2 validate-number" datatype="number"/>萬＊
					<input type = "text"  id="LAND_MEASUREB" name="LAND_MEASUREB" class ="rtnMap text2 validate-number" datatype="number" maxLength ="10" size ="10"/>坪＝ &nbsp
					<b><span id="TOTAL_PRICEB_TXT" name = "TOTAL_PRICEB_TXT"></span></b>
					<input type = "hidden"  id="TOTAL_PRICEB" name="TOTAL_PRICEB" class ="rtnMap validate-number" datatype = "number"/>&nbsp 萬
				</td>
				<%-- [20221109] 設計容積率(特/限定) --%>
				<td class="tbYellow2" align="left" colspan = "2">
					設計容積率(特/限定)
					<input type="text"  id="BOSS_SPEC_FLAR" name="BOSS_SPEC_FLAR" maxLength="8" size="10" class="rtnMap text2 checkNumeralFormat_5_2" datatype="number"/>
					%
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" colspan = "5">
					&nbsp﹝四﹞綜合結論
				</td>	
			</tr>
			<tr>				
				<td class="tbYellow2" colspan ="5">
					<textarea cols="95" rows="4" id="CONCLUSION_DESCB" name="CONCLUSION_DESCB" colspan="3" class ="rtnMap text2" maxLength ="400" fieldName = "特﹝限﹞定價格-綜合結論" onkeyup="if(this.scrollHeight > 90) this.style.posHeight=this.scrollHeight"></textarea>
				</td>								
			</tr>		
		</table>
	</form>		 
	<form id="form3" name="form3" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id='grid2' width="100%"></table>		
		<!-- [20201126]新增欄位 -->
		<table id="table_H" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0" colspan="5" align ="center">
					<b/>伍、覆核
				</td>
			</tr>			
			<tr>
				<td class="tbYellow" rowspan='3'>組長批示</td>
				<td class="tbYellow2" colspan='4'>
					<select id="CAPT_EXAM" name = "CAPT_EXAM" class ="rtnMap" fieldName="使用分區">							
						<c:forEach items="${CAPT_EXAM_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>	
					<textarea cols="95" rows="4" id="CAPT_EXAM_DESC" name="CAPT_EXAM_DESC" class ="rtnMap text2" maxLength ="400" fieldName = "批示內容" onkeyup="if(this.scrollHeight > 90) this.style.posHeight=this.scrollHeight"></textarea>
					<input type='hidden' id='CAPT_ID' name='CAPT_ID' class ="rtnMap" />
					<input type='hidden' id='CAPT_DATE' name='CAPT_DATE' class ="rtnMap" />
				</td>	
			</tr>
			<tr>
				<td class="tbYellow">正常價格</td>
				<td class="tbYellow2" colspan='3'>
					單價<input type='text' id='CAPT_REG_PER_PRICE' name='CAPT_REG_PER_PRICE' class ="rtnMap validate-number" datatype="number" pattern="#,###.##"/>萬/坪 &nbsp;&nbsp;&nbsp;&nbsp;
					總價<input type='text' id='CAPT_REG_TOTAL_PRICE' name='CAPT_REG_TOTAL_PRICE' class ="rtnMap validate-number" datatype="number" pattern="#,###.##"/>萬
				</td>				
			</tr>
			<tr>
				<td class="tbYellow">特定價格</td>
				<td class="tbYellow2" colspan='3'>
					單價<input type='text' id='CAPT_SPEC_PER_PRICE' name='CAPT_SPEC_PER_PRICE' class ="rtnMap validate-number" datatype="number" pattern="#,###.##"/>萬/坪 &nbsp;&nbsp;&nbsp;&nbsp;
					總價<input type='text' id='CAPT_SPEC_TOTAL_PRICE' name='CAPT_SPEC_TOTAL_PRICE' class ="rtnMap validate-number" datatype="number" pattern="#,###.##"/>萬
				</td>				
			</tr>				
			<tr>
				<td class="tbYellow" rowspan='3'>主管批示</td>
				<td class="tbYellow2" colspan='4'>
					<select id="BOSS_EXAM" name = "BOSS_EXAM" class ="rtnMap" fieldName="使用分區">							
						<c:forEach items="${BOSS_EXAM_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>	
					<textarea cols="95" rows="4" id="BOSS_EXAM_DESC" name="BOSS_EXAM_DESC" class ="rtnMap text2" maxLength ="400" fieldName = "批示內容" onkeyup="if(this.scrollHeight > 90) this.style.posHeight=this.scrollHeight"></textarea>
					<input type='hidden' id='BOSS_ID' name='BOSS_ID' class ="rtnMap" />
					<input type='hidden' id='BOSS_DATE' name='BOSS_DATE' class ="rtnMap" />
				</td>	
			</tr>
			<tr>
				<td class="tbYellow">正常價格</td>
				<td class="tbYellow2" colspan='3'>
					單價<input type='text' id='BOSS_REG_PER_PRICE' name='BOSS_REG_PER_PRICE' class ="rtnMap validate-number" datatype="number" pattern="#,###.##"/>萬/坪 &nbsp;&nbsp;&nbsp;&nbsp;
					總價<input type='text' id='BOSS_REG_TOTAL_PRICE' name='BOSS_REG_TOTAL_PRICE' class ="rtnMap validate-number" datatype="number" pattern="#,###.##"/>萬
				</td>				
			</tr>
			<tr>
				<td class="tbYellow">特定價格</td>
				<td class="tbYellow2" colspan='3'>
					單價<input type='text' id='BOSS_SPEC_PER_PRICE' name='CAPT_SPEC_PER_PRICE' class ="rtnMap validate-number" datatype="number" pattern="#,###.##"/>萬/坪 &nbsp;&nbsp;&nbsp;&nbsp;
					總價<input type='text' id='BOSS_SPEC_TOTAL_PRICE' name='CAPT_SPEC_TOTAL_PRICE' class ="rtnMap validate-number" datatype="number" pattern="#,###.##" />萬
				</td>				
			</tr>				
			<tr>
				<td class="tbYellow" >部室主管批示</td>
				<td class="tbYellow2"></td>
				<td class="tbYellow2" colspan='3'>					
					<textarea cols="95" rows="4" id="GM_EXAM_DESC" name="GM_EXAM_DESC" class ="rtnMap text2" maxLength ="400" fieldName = "批示內容" onkeyup="if(this.scrollHeight > 90) this.style.posHeight=this.scrollHeight"></textarea>
					<input type='hidden' id='GM_ID' name='GM_ID' class ="rtnMap" />
					<input type='hidden' id='GM_DATE' name='GM_DATE' class ="rtnMap" />
				</td>	
			</tr>						
		</table>		
		<table id='table_P1' class="tbBox2" cellspacing="1" style="width:100%; border:0;"></table>
	    <table id="table_R" class="tbBox2" cellspacing="1" style="width:100%; border:0;" >
			<tr align="center" class="tbYellow0">
				<td class="textBold">陸、評分</td>
			</tr>
			<tr> 
			 	<td colspan="3">
					<table id="gridR1" ></table>
			  	</td>
			</tr>
			<tr>
				<td class=tbYellow2 align="center" >
					<input id="btn_add_1" class="button" type="button" value="新增評分" /> 
				</td>
			</tr>
		</table>
	</form>
</body>
</html>