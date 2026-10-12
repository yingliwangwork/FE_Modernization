<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA30500.jsp
作者：王文進
功能：鑑價報告資料。
完成：

[20180607]問題單
問題敘述：1.IE11問題 2.若銀行件各擔保品附屬建物資料中有新增車位資料，執行修正或組長覆核時發生錯誤
[20180626]
問題敘述：1.IE11問題 2.onpropertychange在IE11失效，改用onkeyup，並在查詢完成時模擬keyup動作
[20201127]修改件
申請書-201019001927：調整承作分區判斷邏輯

[20210712]修改件，立案單號 210706010909
1.  C區新增特殊擔保品選項(必填)，及現況出入無虞(預設不顯示)，新增/修改可以寫入資料庫
2.  若特殊擔保品選項選擇'裡地'，現況出入無虞顯示且必填
3.  報表一併新增欄位
@modifier 蔡明芳
@since 2021-07-12

[20210804] 問題單 單號:20210804140313
問題敘述: 當案件為銀行件，修改時新增檢核車位持分分母欄位不得異動

[20211018] 修改件，立案單號:211015005065
CHROME 進入壽核系統的鑑價報告 textarea 欄位優化

[20220307] IE樓層欄位優化，不得輸入數字以外字元

[20221206]問題單20221206144003
調整新增社區資料連結，調整成檢核後新增社區，再導頁到社區維護畫面
郭曉慧
[20240613]修改件
1. 【查詢】調整增加車位價格落差原因 (M1 跟 M2區塊，增加MP區，若A215ListP有值，顯示該區塊
2. 【新增】、【修改】增加車位價格區間檢核
3. 【自動估價】若有車位，檢核必須輸入數字，自動估價增加車位模型參數檢核、增加呼叫車位模型
4. 【呈核】若有車位，呈核車位模型是否有執行且輸入價格落差原因
5. queryDate 增加查詢A215ListP車位價格落差原因

[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
[20250211] 修改件
1.匯入社區價格調整為匯入社區/公寓價格，調整doGetA350List方法，畫面參數調整傳入參數 增加 MM區塊公寓價格落差原因 
2.queryDate增加查詢 A215ListM公寓落差原因
3.呈核若有公寓估價紀錄，檢核是否有輸入價格落差原因
[20250213]問題單:20250212142432
1.queryDate增加查詢公寓資料庫 (DSA3_0500)
2.修改調整公寓價格落差原因維護(DS_A30500)
3.呈核調整檢核公寓資料庫是否有維護(DSA3_0500_mod)
4.調整確認社區/公寓價格，更新公寓資料庫異動人員時間 (DSA3_0500)
5.增加公寓資料庫按鈕 (確認社區/公寓價格右邊) (DSA3_0500/DSA33700)

[20250310] 問題單 20250307092641
各擔保品附屬建物資料，若車位編號為車公，車位型態可不輸入 
1.(調整檢核4車位型態檢核，新增doInsert、修改doUpdate、呈核doConfirmCheck、組長覆核doCaptainConfirmCheck、科主管覆核doBossConfirmCheck、部室主管覆核doGmConfirm  無SPEC修改程式) 
2.調整自動估價 doGetA215List

[20250424] 問題單 20250307092641
公寓資料庫調整同(同社區編號方式，開啟新視窗，不要用100%遮蔽) 

-->

<fmt:setBundle basename='TextResource' />
<STYLE TYPE="text/css">
.textAreaOldSys {
    font-size: 9pt;
}
table.tableGrid th[name="PRINCE"] {
    width: 12%;
}
table.tableGrid th[name="REGION_NM"] {
    width: 9%;
}
table.tableGrid th[name="GAP_VALUE"] {
    width: 11%;
}
table.tableGrid th[name="GAP_NOTE1"] {
    width: 15%;
}
table.tableGrid th[name="GAP_NOTE2"] {
    width: 15%;
}
table.tableGrid th[name="MEMO"] {
    width: 38%;
}
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
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
<script type='text/javascript' src='<%=htmlBase%>/CM/js/calendar.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/popupWin.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script> 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/suggest.js'></script>	<%-- 搜尋提示用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>	<%-- 檢核用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>		<%-- 匯出PDF用--%>
<script type="text/javascript" src='<%=htmlBase%>/CM/js/ui/InputUtility.js'></script>
<script type='text/javascript'>

// 產生畫面物件
var DSA30500 = new DSA30500();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSA30500.initApp);
var defaultPattern1 = '#,###.##';
var defaultPattern2 = '#,###.###';

function DSA30500(){
	//查詢的檢核
	var valid1;
	var valid2;
	var valid3;
	var valid4;
	var valid5;//[20210712] 新增「特殊擔保品選項」與「現況出入無虞」欄位，新增與修改增加檢核
	var valid7;<%--[20240613]車位模型檢核--%>
	var viewMap;
	
	var gridF2;
	var gridJ1;
	var gridK1;
	var gridL1;
	var A217List;
	var gridN1;
	var gridO1;
	var table_P1;
	var gridR1;
	var addIndex = 0;//動態刪除,新增識別值
	var gridH1;
	var gridM1;
	var gridM2;
	var gridM3; <!-- 20210610 2.	新增顯示區塊:社區價格區間-->
	var gridMP; <%--[20240613]增加車位估價紀錄區--%>
	var gridMM;<%--[20250211]--%>
	var showAVM = '${showAVM}';//是否顯示自動估價相關資料
	var MISS_REASON ;	 <!-- 20210617  顯示買賣件合理議價區間不符原因-->
	var chkTRADE_AMT;	 <!-- 20210617 當chkTRADE_AMT>1時，才需顯示合理議價區間不符原因-->
	var APPR_PROCESS;    <!-- 20210726 當鑑價進度在呈核之後(1,3,4,5,6)，才需顯示合理議價區間不符原因-->
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
	// 20210610 3.	拆分價格原因落差欄位為兩欄:價格落差原因一、價格落差原因二
	var PRICE_GAP1_LIST = {};//價格落差原因一選單
	var PRICE_GAP2_LIST = {};//價格落差原因二選單
	// 20240625 車位價格落差原因一、車位價格落差原因二
	var PSM_GAP1_LIST = {};//車位價格落差原因一選單
	var PSM_GAP2_LIST = {};//車位價格落差原因二選單	
	//前次查詢條件
	var queryCondition = {APPLY_ID : ""};
	var SUPPORT_NAME = <c:out value="${SUPPORT_NAME}" default="[]" escapeXml="false" />;
	
	var isURBAN_PROJECT = false;//若為都市計畫案區域，須檢核都市計畫案不可為空

	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0003:"btn_insert",//新增
				B0004:"btn_update",//修正
				B0005:"btn_delete",//刪除
				B0116:"btn_confirm",//呈核
				B0085:"btn_cancel",//取消呈核
				B0117:"btn_captainConfirm",//組長覆核
				B0018:"btn_captainReject",//組長退回
				B0118:"btn_bossConfirm",//科主管(代理)覆核
				B0119:"btn_bossReject",//主管退回
				B0125:"btn_gmConfirm",//部室主管覆核 
				B0071:"btn_cancelConfirm",//取消覆核
				B0120:"btn_imageConfirm",//影像確認
				B0133:"btn_Get_A213List_VIEW",//(2)環域分析
				B0148:"btn_reSend",//報告重送
				B0044:"btn_linkImage",//影像連結
				B0249:"btn_Get_A201List_VIEW",//(4)訪價匯入
				B0250:"btn_Get_A216List_VIEW",//(3)案例建議
				B0251:"btn_Get_A215List_VIEW",//(5)自動估價
				B0255:"btn_communityInsert",//新增社區資料
				B0257:"btn_copyPicAlbum"//引用相簿
		};
		<dz:grantButtons FUNC_ID="DSA30500" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([
			[ 'validateAPPLY_ID',  '受理編號長度不正確 需為11碼',
				function(v){				
					return (v.length != 11) ? false : true ;
				}
			],
			[ 'validateCONTRACT_AREA_VIEW',  '承作區必須輸入',
				function(v){
					return (v.length == 0) ? false : true ;
				}
			],
			[ 'validate1BUILD_TYPE_VIEW',  '建築型態請勿輸入單引號!!',
				function(v){
					return (v.indexOf('\'') != -1) ? false : true ;
				}
			],
			[ 'validate2BUILD_TYPE_VIEW',  '建築型態請勿輸入半形逗號!!',
				function(v){
					return (v.indexOf(',') != -1) ? false : true ;
				}
			],
			[ 'validateCASE_NAME_VIEW',  '此為整批件，請輸入案名!',
				function(v){
					return (viewMap.LOAN_KIND == '200' && v.length == 0) ? false : true ;
				}
			],
			[ 'validateNOPIC_REASON_VIEW',  '室內照拍攝說明必須輸入',
				function(v){
					return (v.length == 0) ? false : true ;
				}
			],
			[ 'validateBUILD_LINE',  '捷運專案請輸入相關資料',
				function(v1,v2){
					return (viewMap.METRO_CASE == '1' && v1.length == 0 && v2.length == 0) ? false : true ;
				}
			],
			[ 'validateROUND_DISTANCE',  '捷運專案請輸入相關資料',
				function(v1,v2,v3){
					return (viewMap.METRO_CASE == '3' && v1.length == 0 && v2.length == 0 && v3!='3') ? false : true ;
				}
			],
			[ 'validate1DESC_VIEW',  '補充說明請勿輸入單引號!!',
				function(v){
					return (v.indexOf('\'') != -1) ? false : true ;
				}
			],
			[ 'validate2DESC_VIEW',  '補充說明請勿輸入半形逗號!!',
				function(v){
					return (v.indexOf(',') != -1) ? false : true ;
				}
			],
			[ 'validate1LOC_DESC_VIEW',  '綜合分析請勿輸入單引號!!',
				function(v){
					return (v.indexOf('\'') != -1) ? false : true ;
				}
			],
			[ 'validate2LOC_DESC_VIEW',  '綜合分析請勿輸入半形逗號!!',
				function(v){
					return (v.indexOf(',') != -1) ? false : true ;
				}
			],
			[ 'validateGridK1',  '各擔保品鑑價資料至少需有一筆資料且單價、車位(個)、車位坪數、車位均價均需輸入值',
				function(v){
					return (viewMap.BANK_CASE == '1' && gridK1.getAllRecords().size()==0) ? false : true ;
				}
			],
			[ 'checkParkTypeViewSelectOption', '請選擇車位型態',
				function(v){
					var hasSelected = true;
					$$('.parkTypeViewSelectOption').each(function(ele){
						var noSelected = ele.value=='0';
						if(noSelected){
							hasSelected = false;
							ele.style.backgroundColor = '#FF8888';
						}else{
							ele.style.backgroundColor = '';
						}
					});
					return hasSelected;
				} 
			],
			[ 'validateUSE_FOR_VIEW',  '使用別必須輸入',
				function(v){
					return (v.length == 0) ? false : true ;
				}
			],
			[ 'validateGRADING_ITEM_VIEW',  '飯店旅館、商場、其他之分級項必須輸入',
				function(v){
				    if($F('USE_FOR_VIEW')=='I' || $F('USE_FOR_VIEW')=='J' || $F('USE_FOR_VIEW')=='M'){
						return (v == '0') ? false : true ;
					}else{
						return true;
					}
				}
			],
			[ 'validateAPPEARANCE_PIC_REASON_VIEW',  '外觀照說明必須輸入',
				function(v){
					return (v.length == 0) ? false : true ;
				}
			],
			[ 'validateAPPEARANCE_PIC_DATE_VIEW',  '外觀照日期必須輸入',
				function(v){
					return (v.length == 0) ? false : true ;
				}
			],
			[ 'validate1FOLLOW_NUMBER',  '沿用編號欄位不可輸入',
				function(v){
					return (viewMap.APPEARANCE_PIC_REASON == '1' && v.length != 0) ? false : true ;
				}
			],
			[ 'validate2FOLLOW_NUMBER',  '請輸入沿用編號',
				function(v){
					return (viewMap.APPEARANCE_PIC_REASON == '2' && v.length == 0) ? false : true ;
				}
			],
			[ 'validatePARK',  '請選擇車位型態',
				function(v){
					return (v == '0'  || v == '1') ? false : true ;
				}
			],
			['validateMEMO',  '價格落差原因選擇其他，請輸入備註',
				function(v,ele){
				var GAP_NOTE21 = $$('#'+ele.id +' select[name=GAP_NOTE21]')[0];
				if (GAP_NOTE21 && [15,24,49,59,63,71].include(GAP_NOTE21.value) ){
					return $$('#'+ele.id +' input[type="text"]')[0].value?  true : false ;
				}
				
				return true  ;
			}				
			],
			['validateGAPNOTE',  '請選擇價格落差原因',
				function(v,ele){
				var REGION_NM = $$('#'+ele.id +' td[name=REGION_NM]')[0];
				var GAP_NOTE11 = $$('#'+ele.id +' select[name=GAP_NOTE11]')[0];
				var GAP_NOTE21 = $$('#'+ele.id +' select[name=GAP_NOTE21]')[0];
				if (REGION_NM && REGION_NM.innerText =='否' && (GAP_NOTE11.value=='' || GAP_NOTE21.value=='')){
					return false;
				}else{
					return true  ;
				}
			}
			],
			<%-- [20210712] 新增「特殊擔保品選項」與「現況出入無虞」欄位，「新增」與「修改」增加檢核： --%>
			[ 'validateSPC_GAGE_OPT',  '特殊擔保品選項必須輸入',
				function(v){
					return (v.length == 0) ? false : true ;
				}
			],
			<%--            若「特殊擔保品選項」為「裡地」，則「現況出入無虞」必須有值 --%>
			[ 'validateSPC_GAGE_TYPE',  '特殊擔保品選項為「裡地」，現況出入無虞欄位必須有值',
				function(v1, v2){
 					var radioAry = 'SPC_GAGE_TYPE_Y SPC_GAGE_TYPE_N';
 					var checkedAtLeastOne = false;
 					
 					$w(radioAry).each(function(radioID){
 						if($(radioID).checked){
 							checkedAtLeastOne = true;
 						}
 					})
					return checkedAtLeastOne;
				}
			],
			<%-- 有車位數量，車位坪數與車位總價需>0 --%>
			['validateOverZero', '請輸入>0數值', 
			    function (AREA_SIZE){
			    if(AREA_SIZE <=0){
			        return false;
		        } else {
			        return true;		        	
		        }
		    }
		    ]
		]);
		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		valid1.define( "validateAPPLY_ID" , { id: "APPLY_ID" } );
		
		valid2 = new Validation("form2", { focusOnError:true, immediate:false });
		settingValid2('init');
		
		valid3 = new Validation("form2", { focusOnError:true, immediate:false, useTitles:true });
		valid3.define( "validateCONTRACT_AREA_VIEW" , { id: "CONTRACT_AREA_VIEW" } );
		valid3.define( "validateCASE_NAME_VIEW" , { id: "CASE_NAME_VIEW" } );
		valid3.define( "validateNOPIC_REASON_VIEW" , { id: "NOPIC_REASON_VIEW" } );
		valid3.define( "validateBUILD_LINE" , [{ id: "BUILD_LINE_VIEW"},{ id: "ROUND_LINE_VIEW" }] );
		valid3.define( "validateROUND_DISTANCE" , [{ id: "BUILD_LINE_VIEW"},{ id: "ROUND_LINE_VIEW" },{ id: "ROUND_DISTANCE_VIEW" }] );
		valid3.define( "validateGridK1" , { id: "gridK1" } );
		
		<%--[20250310] 與SA討論後移除此檢核--%>
		//valid3.define( "checkParkTypeViewSelectOption" , { id: "gridK1" } );
		
		valid3.define( "validateAPPEARANCE_PIC_REASON_VIEW" , { id: "APPEARANCE_PIC_REASON_VIEW" } );
		valid3.define( "validateAPPEARANCE_PIC_DATE_VIEW" , { id: "APPEARANCE_PIC_DATE_VIEW" } );
		valid3.define( "validate1FOLLOW_NUMBER" , { id: "FOLLOW_NUMBER_VIEW" } );
		valid3.define( "validate2FOLLOW_NUMBER" , { id: "FOLLOW_NUMBER_VIEW" } );
		
		valid4 = new Validation("form2", { focusOnError:true, immediate:false, useTitles:true });

		//[20210712] 新增「特殊擔保品選項」與「現況出入無虞」欄位，執行新增與修改功能時，增加檢核
		valid5 = new Validation("form2", { focusOnError:true, immediate:false });
		valid5.define( "validateSPC_GAGE_TYPE" , [{ id: "SPC_GAGE_TYPE_Y" }, { id: "SPC_GAGE_TYPE_N", ignore : true }] );
		valid5.define( "validateSPC_GAGE_OPT" , { id: "SPC_GAGE_OPT_VIEW" } );
		
		//[20231030] 231020023853_承作分區_上線前置作業調整，增加社區案名(CASE_NMAE)檢核
		valid6 = new Validation("form2", { focusOnError:true, immediate:false, useTitles:true});
		valid6.define( "required" , { id: "CASE_NAME_VIEW" } );
		<%--[20240613]車位模型檢核--%>
		valid7 = new Validation("form2", { focusOnError:true, immediate:false, useTitles:true});
	}
	
	function settingValid2(actionType){
		if('init'!=actionType){
			valid2.clear();
			valid2.reset();
		}
		
		//valid2.define( "validateCONTRACT_AREA_VIEW" , { id: "CONTRACT_AREA_VIEW" } );
		valid2.define( "validate1BUILD_TYPE_VIEW" , { id: "BUILD_TYPE_VIEW" } );
		valid2.define( "validate2BUILD_TYPE_VIEW" , { id: "BUILD_TYPE_VIEW" } );
		//valid2.define( "validateCASE_NAME_VIEW" , { id: "CASE_NAME_VIEW" } );
		//valid2.define( "validateNOPIC_REASON_VIEW" , { id: "NOPIC_REASON_VIEW" } );
		//valid2.define( "validateBUILD_LINE" , [{ id: "BUILD_LINE_VIEW"},{ id: "ROUND_LINE_VIEW" }] );
		//valid2.define( "validateROUND_DISTANCE" , [{ id: "BUILD_LINE_VIEW"},{ id: "ROUND_LINE_VIEW" },{ id: "ROUND_DISTANCE_VIEW" }] );
		valid2.define( "validate1DESC_VIEW" , { id: "DISLIKE_DESC_VIEW" } );
		valid2.define( "validate2DESC_VIEW" , { id: "DISLIKE_DESC_VIEW" } );
		valid2.define( "validate1DESC_VIEW" , { id: "SPC_DESC_VIEW" } );
		valid2.define( "validate2DESC_VIEW" , { id: "SPC_DESC_VIEW" } );
		valid2.define( "validate1LOC_DESC_VIEW" , { id: "LOC_DESC_VIEW" } );
		valid2.define( "validate2LOC_DESC_VIEW" , { id: "LOC_DESC_VIEW" } );
		valid2.define( "validateUSE_FOR_VIEW" , { id: "USE_FOR_VIEW" } );
		valid2.define( "validateGRADING_ITEM_VIEW" , { id: "GRADING_ITEM_VIEW" } );
		
		if('confirm'==actionType){//呈核時才檢核
			valid2.define( "required" , { id: "USE_AREA1_VIEW" } );
			if(isURBAN_PROJECT){
				valid2.define( "required" , { id: "URBAN_PROJECT" } );	
			}
			//20210719 當下拉選單PRICE_GAP1選擇其他，備註欄為須卡控必須輸入
			valid2.define( "validateMEMO" , { id: "gridM3" } );	
			valid2.define( "validateMEMO" , { id: "gridM2" } );	
			valid2.define( "validateMEMO" , { id: "gridM1" } );	
			valid2.define( "validateMEMO" , { id: "gridMP" } );		
			valid2.define( "validateMEMO" , { id: "gridMM" } );	<%--[20250211]公寓估價紀錄--%>
			//20210719 請選擇價格落差原因
			valid2.define( "validateGAPNOTE" , { id: "gridM3" } );	
			valid2.define( "validateGAPNOTE" , { id: "gridM2" } );	
			valid2.define( "validateGAPNOTE" , { id: "gridM1" } );	
			valid2.define( "validateGAPNOTE" , { id: "gridMP" } );	
			valid2.define( "validateGAPNOTE" , { id: "gridMM" } );	<%--[20250211]公寓估價紀錄--%>
		}
	}
	<%--[20240613]車位模型檢核--%>
	function chkPSM(){
		valid7.clear();
		valid7.reset();
		
		valid7.define("validate-integer", { id: "PARK_NUM_VIEW_1", errMsg:"車位必須為數字" });
		
		var PARK_NUM = $F("PARK_NUM_VIEW_1");
		if(PARK_NUM && parseInt(PARK_NUM) > 0){
			valid7.define("required", { id: "PARK_NO_VIEW",errMsg:"編號必須輸入" });			
			if( A217List.length > 0){
				$$('[id^="gridL1_PARK_NO_VIEW"]').each(function(elem){
					valid7.define("required", { id: elem.id, errMsg:"車位編號必須有值" });
				});	
				$$('[id^="gridL1_PARK_TYPE_VIEW"]').each(function(elem){
										
					<%--[20250310]各擔保品附屬建物資料，若車位編號為車公，車位型態可不輸入。--%>
					var targetTypeId = elem.id;
					var targetNoId = targetTypeId.replace('TYPE','NO');
					if($F(targetNoId) !== '車公'){
						valid7.define("validatePARK", { id: targetTypeId, errMsg:"車位型態必須有值" });
					}
				});
				$$('[id^="gridL1_PARK_NUM_VIEW"]').each(function(elem){
					valid7.define("validate-integer", { id: elem.id, errMsg:"車位數量必須數字" });
				});
				valid7.define("validatePARK", { id: "PARK_VIEW", errMsg:"停車位必須輸入" });
				valid7.define("validateOverZero", { id: "PARK_SPACE_VIEW", errMsg:"車位坪數必須輸入" });
				valid7.define("validateOverZero", { id: "PARK_AMT_VIEW_1", errMsg:"總價必須輸入" });
				if(!valid7.validate()){
					alert('銀行件車位資料不全，請先修正資料再執行自動估價');
					return false;
				}
			}else{
				valid7.define("validatePARK", { id: "PARK_VIEW", errMsg:"停車位必須輸入" });
				valid7.define("validateOverZero", { id: "PARK_SPACE_VIEW", errMsg:"車位坪數必須輸入" });
				valid7.define("validateOverZero", { id: "PARK_AMT_VIEW_1", errMsg:"總價必須輸入" });
				if(!valid7.validate()){
					alert('國壽件車位資料不全，請先修正資料再執行自動估價');
					return false;
				}
			}
		}
		return valid7.validate();
	}
	//共用的Ajax
	function ajaxPost ( actionName, params, async, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSA3_0500/" + actionName,		
		{  
				parameters: params, asynchronous : async,
				onSuccess:function(response){
					var resp = response.responseJSON;
					if(CSRUtil.isSuccess(resp)){	
						if(successFunction){
						    //原部份交易查詢成功後，點確認後才會進行重查(因效能考量，
							if(actionName == 'insert' || actionName == 'update' || actionName == 'delete' || actionName == 'confirm' || actionName == 'cancel' ||
							   actionName == 'captainConfirm' || actionName == 'captainReject' || actionName == 'bossConfirm' || actionName == 'gmConfirm' ||
							   actionName == 'bossReject' || actionName == 'cancelConfirm' || actionName == 'imageConfirm') {
								buttons.doReQuery();
							}else{
								successFunction(resp);
							}
						}
					}else{
						if(errorFunction){
							errorFunction(resp);
						}
					}
				}			
			});
	}	

	//查詢成功
	function querySuccessFunction (resp){
		var encryptAPPLY_ID = resp.encryptAPPLY_ID;
		if(encryptAPPLY_ID){
			$('encryptAPPLY_ID').value=encryptAPPLY_ID;
		}
		var rtnMap = resp.rtnMap ? resp.rtnMap : {};
		viewMap = rtnMap;
		MISS_REASON = resp.MISS_REASON ||'';<!-- 20210617  顯示買賣件合理議價區間不符原因-->
		chkTRADE_AMT = JsUtils.isBasicType(rtnMap.TRADE_AMT) ? rtnMap.TRADE_AMT:0;
		APPR_PROCESS=rtnMap.APPR_PROCESS;
		
		//[20220119]針對舊建顯示舊素地，新建顯示素地AB
		var useForList=rtnMap.useForList;
		$('USE_FOR_VIEW').length=0;
		if(useForList){
			for(var i=0;i<useForList.length;i++){
				$('USE_FOR_VIEW').add(new Option(useForList[i]['VAL'],useForList[i]['KEY']));
			}
		}

		//B區
		buttons.setTable_B(rtnMap);
		<%--[20201127] 新增所屬都市計畫案下拉選單--%>
		buttons.selectUrban((rtnMap.URBAN_PROJECT_LIST||[]), (rtnMap.URBAN_PROJECT||''));
		//C區
		buttons.setTable_C(rtnMap);
		//D區
		buttons.setTable_D(resp);	
		
		//捷運專案，才需顯示7.捷運說明
		var MERO_CASE = rtnMap.METRO_CASE ? rtnMap.METRO_CASE : '';
		if ( MERO_CASE == '3'){ 
			$('A_divI8').style.display = 'block';
		} else {
			$('A_divI8').style.display = 'none';
		}
		if (resp.A213AList && resp.A213AList != "") {
			$('A213AList_VIEW').style.display = 'block';
		}else{
			$('A213AList_VIEW').style.display = 'none';
		}
		if (resp.A213BList && resp.A213BList != "") {
			$('A213BList_VIEW').style.display = 'block';
		}else{
			$('A213BList_VIEW').style.display = 'none';
		}
		if (resp.A213CList && resp.A213CList != "") {
			$('A213CList_VIEW').style.display = 'block';
		}else{
			$('A213CList_VIEW').style.display = 'none';
		}		
		//E區
		//gridE1
		buttons.setGridE1(resp);		
		//F區
		//gridF1
		buttons.setGridF1(resp);		
		//gridF2
		var A202List = resp.A202List ? resp.A202List : [];
		gridF2.load(A202List);
		if (A202List.size() > 0){
			$('div_I0').style.display = 'block';
		}else{
			$('div_I0').style.display = 'none';
		}		
		//G區
		$('LOC_DESC_VIEW').value = rtnMap.LOC_DESC ? rtnMap.LOC_DESC : '';		
		//H區
		$('HIGH_AMT_DESC_VIEW').value = rtnMap.HIGH_AMT_DESC ? rtnMap.HIGH_AMT_DESC : '';
		if ($('HIGH_AMT_DESC_VIEW').value != ''){
			$('div_I1').style.display = 'block';
		}else{
			$('div_I1').style.display = 'none';
		}
		//gridH1
		var A216List = resp.A216List ? resp.A216List : [];
		gridH1.load(A216List, null, null, ["1"]);		
		//gridM1
		var A215ListA = resp.A215ListA ? resp.A215ListA : [];
		gridM1.load(A215ListA);
		//gridM2
		var A215ListS = resp.A215ListS ? resp.A215ListS : [];
		gridM2.load(A215ListS);
		//gridM3 社區價格 
		var A215ListC = resp.A215ListC ? resp.A215ListC : [];
		gridM3.load(A215ListC);
		<%--[20240613]車位估價紀錄 --%>
		var A215ListP = resp.A215ListP ? resp.A215ListP : [];
		gridMP.load(A215ListP);
		<%--[20250211]公寓估價紀錄 --%>
		var A215ListM = resp.A215ListM ? resp.A215ListM : [];
		gridMM.load(A215ListM);
		//I區
		$('TAKE_OVER_VIEW').value = rtnMap.TAKE_OVER ? rtnMap.TAKE_OVER : '';
		//J區
		//gridJ1
		var A260List = resp.A260List ? resp.A260List : [];
		gridJ1.load(A260List);
		//K區
		//gridK1
		var A205List = resp.A205List ? resp.A205List : [];
		if(A205List.length==1 
			&& CSRUtil.getNumber(A205List[0]["EACH_PRICE"]) == 0 && CSRUtil.getNumber(A205List[0]["PARK_NUM"]) == 0 
			&& CSRUtil.getNumber(A205List[0]["PARK_SPACEA"]) == 0 && CSRUtil.getNumber(A205List[0]["PARK_AMT"]) == 0){
			
			if(CSRUtil.getNumber(rtnMap.PER_PRICE)==0){
				A205List[0]["EACH_PRICE"] = rtnMap.AVG_PRICE ? rtnMap.AVG_PRICE : '';
			}else{
				A205List[0]["EACH_PRICE"] = rtnMap.PER_PRICE ? rtnMap.PER_PRICE : ''; 
			}
			if(CSRUtil.getNumber(rtnMap.NEW_BANK_CASE)==0 && rtnMap.PARK_NUM!='0'){
				A205List[0]["PARK_NUM"] = rtnMap.PARK_NUM ? rtnMap.PARK_NUM : '0';
				A205List[0]["PARK_SPACEA"] = rtnMap.PARK_SPACEA ? rtnMap.PARK_SPACEA : '0';
				A205List[0]["PARK_AMT"] = rtnMap.M_PARK_AMT ? rtnMap.M_PARK_AMT : '0';
			}else{
				A205List[0]["PARK_NUM"] = '0';
				A205List[0]["PARK_SPACEA"] = '0';
				A205List[0]["PARK_AMT"] = '0';
			}
		}else{
			for(var i = 0; i < A205List.length; i++){
				A205List[i]["PARK_NUM"] = '0';
				A205List[i]["PARK_SPACEA"] = '0';
				A205List[i]["PARK_AMT"] = '0';
			}
		}
		gridK1.load(A205List);
		if (A205List.size() > 0){
			$('div_I2').style.display = 'block';
			$('div_I4').style.display = 'block';
		}else{
			$('div_I2').style.display = 'none';
			$('div_I4').style.display = 'none';
		}
		//L區
		//gridL1
		A217List = resp.A217List ? resp.A217List : [];
		appendGridtoList(A217List, 'gridL1');  
		if (A217List.size() > 0){
			$('div_I3').style.display = 'block';
			$('div_I5').style.display = 'block';
		}else{
			$('div_I3').style.display = 'none';
			$('div_I5').style.display = 'none';
		}
		var dis_fa = $F('DISLIKE_FACILITY_VIEW') ? $F('DISLIKE_FACILITY_VIEW') : '0';
		var dis_fa2 = $F('DISLIKE_FACILITY2_VIEW') ? $F('DISLIKE_FACILITY2_VIEW') : '0';
		if ((dis_fa != '0' && dis_fa != '1') || (dis_fa2 != '0' && dis_fa2 != '1')) {
			$('A_divI6').style.display = '';
		}
		var spc_kd = $F('SPC_KD_GOOD_VIEW') ? $F('SPC_KD_GOOD_VIEW') : '0';
		var spc_kd2 = $F('SPC_KD_GOOD2_VIEW') ? $F('SPC_KD_GOOD2_VIEW') : '0';
		if ($F('SPC_KD_GOOD_NAME_VIEW')!="" || spc_kd!="0" ||
			$F('SPC_KD_GOOD_NAME2_VIEW')!="" || spc_kd2!="0") {
			$('A_divI7').style.display = '';
		}
		//M區
		buttons.setTable_M(rtnMap);
		//N區
		//gridN1
		var A205List = resp.A205List ? resp.A205List : [];
		gridN1.load(A205List);
		//O區
		//gridO1
		A217List = resp.A217List ? resp.A217List : [];
		appendGridtoList(A217List, 'gridO1'); 
		//P區
		buttons.setTable_P(rtnMap);
		//gridP1
		A203List = resp.A203List ? resp.A203List : [];
		appendGridtoList(A203List, 'table_P1'); 
		//Q區
		//buttons.setTable_Q(rtnMap); //20141008
		var A107List = resp.A107List ? resp.A107List : [];
		addIndex = A107List.length;
		gridR1.load(A107List);
		//日期欄處理		
		autoFormatToDate();
		autoFormatToNumber();
		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value });
		//模擬textarea keyup動作
		$w('BUILD_ADD_DESC_VIEW DISLIKE_DESC_VIEW SPC_DESC_VIEW LOC_DESC_VIEW HIGH_AMT_DESC_VIEW CAPT_EXAM_DESC_VIEW BOSS_EXAM_DESC_VIEW GM_EXAM_DESC_VIEW').each( 
			function(id){
				$(id).simulate('keyup');
			}
		);

		//M3 20210702
		if (viewMap.IS_AUTOAPPR == '2'){
    		 $('btnCfmComm').hide();
    	 }else{
    		 $('btnCfmComm').show();
		}
		
		<%--[20211018] 使用 InputUtility.js 調整成讓 CHORME textarea也能依照內容自動調整欄位高度--%>
		$$('textarea').each(function(e){	
			InputUtility.autoSizingTextarea.doAutoSize(e); //依內容調整高度
		});
	}
	
	function queryErrorFunction (resp){					
		//失敗把前次內容清掉 並把鑑價,支援人員list清掉
		var rtnMap = resp.rtnMap ? resp.rtnMap : {};
		viewMap = rtnMap;

		//B區
		buttons.setTable_B(rtnMap);
		//C區
		buttons.setTable_C(rtnMap);
		//D區
		buttons.setTable_D(resp);	
		//捷運專案，才需顯示7.捷運說明
		var MERO_CASE = rtnMap.METRO_CASE ? rtnMap.METRO_CASE : '';
		if ( MERO_CASE == '3'){
			$('A_divI8').style.display = 'block';
		} else {
			$('A_divI8').style.display = 'none';
		}
		//E區
		//gridE1
		buttons.setGridE1(resp);	
		//F區
		buttons.setGridF1(resp);
		
		var A202List = resp.A202List ? resp.A202List : [];
		gridF2.load(A202List);
		//G區
		$('LOC_DESC_VIEW').value = rtnMap.LOC_DESC ? rtnMap.LOC_DESC : '';
		//H區
		$('HIGH_AMT_DESC_VIEW').value = rtnMap.HIGH_AMT_DESC ? rtnMap.HIGH_AMT_DESC : '';
		//gridH1
		var A216List = resp.A216List ? resp.A216List : [];
		gridH1.load(A216List, null, null, ["1"]);		
		//gridM1
		var A215ListA = resp.A215ListA ? resp.A215ListA : [];
		gridM1.load(A215ListA);
		//gridM2
		var A215ListS = resp.A215ListS ? resp.A215ListS : [];
		gridM2.load(A215ListS);
		<%--[20240613]車位估價紀錄 --%>
		var A215ListP = resp.A215ListP ? resp.A215ListP : [];
		gridMP.load(A215ListP);
		<%--[20250211]公寓估價紀錄 --%>
		var A215ListM = resp.A215ListM ? resp.A215ListM : [];
		gridMM.load(A215ListM);
		//I區
		$('TAKE_OVER_VIEW').value = rtnMap.TAKE_OVER ? rtnMap.TAKE_OVER : '';
		//J區
		//gridJ1
		var A260List = resp.A260List ? resp.A260List : [];
		gridJ1.load(A260List);
		//K區
		//gridK1
		var A205List = resp.A205List ? resp.A205List : [];
		gridK1.load(A205List);
		//L區
		//gridL1
		var A217List = resp.A217List ? resp.A217List : [];
		appendGridtoList(A217List, 'gridL1');
		//M區
		buttons.setTable_M(rtnMap);
		//N區
		//gridN1
		var A205List = resp.A205List ? resp.A205List : [];
		gridN1.load(A205List);
		//O區
		//gridO1
		A217List = resp.A217List ? resp.A217List : [];
		appendGridtoList(A217List, 'gridO1');
		//P區
		buttons.setTable_P(rtnMap);
		//gridP1
		A203List = resp.A203List ? resp.A203List : [];
		appendGridtoList(A203List, 'table_P1');
		//Q區
		//buttons.setTable_Q(rtnMap); //20141008
		var A107List = resp.A107List ? resp.A107List : [];
		gridR1.load(A107List);
		//日期欄處理
		autoFormatToDate();
		autoFormatToNumber();
		//模擬textarea keyup動作
		$w('BUILD_ADD_DESC_VIEW DISLIKE_DESC_VIEW SPC_DESC_VIEW LOC_DESC_VIEW HIGH_AMT_DESC_VIEW CAPT_EXAM_DESC_VIEW BOSS_EXAM_DESC_VIEW GM_EXAM_DESC_VIEW').each( 
			function(id){
				$(id).simulate('keyup');
			}
		);
		
		<%--[20211018] 使用 InputUtility.js 調整成讓 CHORME textarea也能依照內容自動調整欄位高度--%>
		$$('textarea').each(function(e){	
			InputUtility.autoSizingTextarea.doAutoSize(e); //依內容調整高度
		});
	}
	<%--[20240614]M區tableui設定--%>
	var actions = {
		setGridM: function(gridId, headerNm){
			var tableui_obj = {
				table: $(gridId), pageSize:0, allSortable:false, overDiv:false,
				column:[
					{header: headerNm, key: "PRINCE", styles:{'width':'12%'},
						render : function(rec , val){
							var v1 = rec.HIGH_PRICE !== undefined ? rec.HIGH_PRICE : '';
							var v2 = rec.LOW_PRICE !== undefined ? rec.LOW_PRICE : '';
							return v2 + "~" + v1 + "萬/坪";
						}
					},
					{header: "是否落入區間",key: "REGION_NM", styles:{'width':'9%'}, 
						render : function(rec , val){
							return val ? val : '';
						}
					},
					{header: "價格落差",key: "GAP_VALUE", styles:{'width':'11%'},
						render : function(rec , val){
							var v1 = rec.GAP_VALUE ? rec.GAP_VALUE + "萬" : '';
							var v2 = rec.GAP_RATE ? "(" + rec.GAP_RATE + "%)": '';
							return v1 + v2;
						}
					},
					{header:"價格落差原因一", key:"GAP_NOTE1", styles:{'width':'15%'},
						render:function(rec,val,sn){
							var SELECT1 = new Element('SELECT',{name:'GAP_NOTE1'+sn})
							SELECT1.add(new Option("請選擇", ""));
							if(PRICE_GAP1_LIST && PRICE_GAP1_LIST.length != 0){
								for (key in PRICE_GAP1_LIST){
									SELECT1.add(new Option(PRICE_GAP1_LIST[key], key));
								}
								if(rec.GAP_NOTE){
									SELECT1.value = rec.GAP_NOTE[0] ||'';
								}else{
									SELECT1.value = '';
								}
							}
							SELECT1.observe('change',function(){
								rec.GAP_NOTE = $(this).value;
						
								var SELECT2 = dropDownGAP_NOTE2List(sn, rec.GAP_NOTE);
								SELECT2.name = "GAP_NOTE2"+sn;
								SELECT2.observe('change',function(){
						 			rec.GAP_NOTE = $(this).value;
						 		  });
								$$('#'+gridId+' SELECT[name=GAP_NOTE2'+sn+"]")[0].replace(SELECT2);
								
							});
							if(rec.REGION == '1'){
								SELECT1.disabled = true;
							}
						 	return SELECT1;
						}
					},
					{header: "價格落差原因二",key: "GAP_NOTE2", styles:{'width':'15%'},
						render: function(rec,val,sn){
					 		var SELECT2 = dropDownGAP_NOTE2List(sn, rec.GAP_NOTE);
					 		SELECT2.name = "GAP_NOTE2"+sn;
					 		SELECT2.observe('change', function(){
					 			rec.GAP_NOTE = $(this).value;
					 		});
					 		if(rec.REGION == '1'){
								SELECT2.disabled = true;
							}
					 		return SELECT2;
						}  
					},
					{header: "備註",key: "MEMO", styles:{'width':'38%'}, 
				 		render:function(rec,val,sn){  				 		   
				 			var input = new Element('input',{type:'text',size:55,maxlength:50});
				 			input.value= rec.MEMO ? rec.MEMO:"";
				 			if(rec.REGION == '1'){
				 				input.disabled = true;
							}
				 			input.observe('blur',function(){
				 				rec.MEMO = $(this).value;
				 			});
				 	    	return input;							 	                                   
				 	   }  
					}
				]				
			}
			return tableui_obj;
		},
		setGridMP: function(gridId, headerNm){
			var tableui_obj = {
				table: $(gridId), pageSize:0, allSortable:false, overDiv:false,
				column:[
					{header: headerNm, key: "PRINCE", styles:{'width':'12%'},
						render : function(rec , val){
							var v1 = rec.HIGH_PRICE !== undefined ? rec.HIGH_PRICE : '';
							var v2 = rec.LOW_PRICE !== undefined ? rec.LOW_PRICE : '';
							return v2 + "~" + v1 + "萬";
						}
					},
					{header: "是否落入區間",key: "REGION_NM", styles:{'width':'9%'}, 
						render : function(rec , val){
							return val ? val : '';
						}
					},
					{header: "價格落差",key: "GAP_VALUE", styles:{'width':'11%'},
						render : function(rec , val){
							var v1 = rec.GAP_VALUE ? rec.GAP_VALUE + "萬" : '';
							var v2 = rec.GAP_RATE ? "(" + rec.GAP_RATE + "%)": '';
							return v1 + v2;
						}
					},
					{header:"價格落差原因一", key:"GAP_NOTE1", styles:{'width':'15%'},
						render:function(rec,val,sn){
							var SELECT1 = new Element('SELECT',{name:'GAP_NOTE1'+sn})
							SELECT1.add(new Option("請選擇", ""));
							if(PSM_GAP1_LIST && PSM_GAP1_LIST.length != 0){
								for (key in PSM_GAP1_LIST){
									SELECT1.add(new Option(PSM_GAP1_LIST[key], key));
								}
								if(rec.GAP_NOTE){
									SELECT1.value = rec.GAP_NOTE[0] ||'';
								}else{
									SELECT1.value = '';
								}
							}
							SELECT1.observe('change',function(){
								rec.GAP_NOTE = $(this).value;
						
								var SELECT2 = dropDownPSMGAP_NOTE2List(sn, rec.GAP_NOTE);
								SELECT2.name = "GAP_NOTE2"+sn;
								SELECT2.observe('change',function(){
						 			rec.GAP_NOTE = $(this).value;
						 		  });
								$$('#'+gridId+' SELECT[name=GAP_NOTE2'+sn+"]")[0].replace(SELECT2);
								
							});
							if(rec.REGION == '1'){
								SELECT1.disabled = true;
							}
						 	return SELECT1;
						}
					},
					{header: "價格落差原因二",key: "GAP_NOTE2", styles:{'width':'15%'},
						render: function(rec,val,sn){
					 		var SELECT2 = dropDownPSMGAP_NOTE2List(sn, rec.GAP_NOTE);
					 		SELECT2.name = "GAP_NOTE2"+sn;
					 		SELECT2.observe('change', function(){
					 			rec.GAP_NOTE = $(this).value;
					 		});
					 		if(rec.REGION == '1'){
								SELECT2.disabled = true;
							}
					 		return SELECT2;
						}  
					},
					{header: "備註",key: "MEMO", styles:{'width':'38%'}, 
				 		render:function(rec,val,sn){  				 		   
				 			var input = new Element('input',{type:'text',size:55,maxlength:50});
				 			input.value= rec.MEMO ? rec.MEMO:"";
				 			if(rec.REGION == '1'){
				 				input.disabled = true;
							}
				 			input.observe('blur',function(){
				 				rec.MEMO = $(this).value;
				 			});
				 	    	return input;							 	                                   
				 	   }  
					}
				]				
			}
			return tableui_obj;
		}
	};
	//buttons對應的event function
	var buttons = {
	
		//設定畫面資料
		//table_B1,table_B2
		setTable_B : function(rtnMap){
			$('APPLY_PROCESS_NM_VIEW').innerHTML=rtnMap.APPLY_PROCESS_NM ? rtnMap.APPLY_PROCESS_NM : '';
			$('AREA_CODE_VIEW').innerHTML=rtnMap.AREA_CODE_NM ? rtnMap.AREA_CODE_NM+'區' : '';
			/*if(rtnMap.AREA_CODE) {
				$('AREA_CODE_VIEW').innerHTML=rtnMap.MAP_AREA_CODE ? rtnMap.AREA_CODE+'區(定位'+rtnMap.MAP_AREA_CODE+'區)' : rtnMap.AREA_CODE+'區';
			}else{
				$('AREA_CODE_VIEW').innerHTML=rtnMap.MAP_AREA_CODE ? '(定位'+rtnMap.MAP_AREA_CODE+'區)' : '';
			}*/
			$('APPR_PROCESS_VIEW').innerHTML=rtnMap.APPR_PROCESS_NM ? rtnMap.APPR_PROCESS_NM : '';
			$('INPUT_NAME_VIEW').innerHTML=rtnMap.INPUT_NAME ? rtnMap.INPUT_NAME : '';
			$('APPR_NM_VIEW').innerHTML=rtnMap.APPR_NM ? rtnMap.APPR_NM : '';
			//$('CRED_NM_VIEW').innerHTML=rtnMap.CRED_NM ? rtnMap.CRED_NM : '';
			$('INPUT_DATE_VIEW').innerHTML=rtnMap.INPUT_DATE ? Date.toROC(rtnMap.INPUT_DATE) : '';
			$('INPUT_DATE').value=rtnMap.INPUT_DATE;
			$('AGENCY_NAME_VIEW').innerHTML=rtnMap.AGENCY_NAME ? rtnMap.AGENCY_NAME : '';
			//$('APPR_DATE_VIEW').innerHTML=rtnMap.APPR_DATE ? Date.toROC(rtnMap.APPR_DATE) : '';
			$('UPLOAD_DATE_VIEW').innerHTML=rtnMap.UPLOAD_DATE ? Date.toROC(rtnMap.UPLOAD_DATE) : '';
			//$('BORROW_NAME_VIEW').innerHTML=rtnMap.BORROW_NAME ? CSRUtil.maskHandler.getMaskName(rtnMap.BORROW_NAME) : '';
			if(rtnMap.ELITE_AGENT!=''){
				$('BORROW_NAME_VIEW').innerHTML=rtnMap.BORROW_NAME ? CSRUtil.maskHandler.getMaskName(rtnMap.BORROW_NAME)+'<font color="red"><B> '+rtnMap.ELITE_AGENT+'</B></font>' : '';
			}else {
			    $('BORROW_NAME_VIEW').innerHTML=rtnMap.BORROW_NAME ? CSRUtil.maskHandler.getMaskName(rtnMap.BORROW_NAME) : '';
			}
			$('BORROW_ID').value=rtnMap.BORROW_ID ? rtnMap.BORROW_ID : '';
			$('TOTAL_FLOOR').value=rtnMap.TOTAL_FLOOR ? rtnMap.TOTAL_FLOOR : '';
			$('TARGET_FLOOR').value=rtnMap.TARGET_FLOOR ? rtnMap.TARGET_FLOOR : '';
			<%-- 20210617 調整鑑價報告上，建物型態與樓層輸入方式--%>
			if (rtnMap.BUILD_TYPE && rtnMap.TARGET_FLOOR){
				$('FLOOR_MEMO').value = rtnMap.BUILD_TYPE.split('/')[0].split(' ')[1] ||'';
			}else if(rtnMap.BUILD_TYPE){
				$('FLOOR_MEMO').value = rtnMap.BUILD_TYPE.split('/')[0] ||'';
			}else{
				$('FLOOR_MEMO').value ='';
			}
			
						
			$('BUILD_TYPE_VIEW').value=rtnMap.BUILD_TYPE ? rtnMap.BUILD_TYPE : changeBUILDTYPE();
			
			$('USE_FOR_VIEW').value=rtnMap.USE_FOR ? rtnMap.USE_FOR : '';
			<%--[20230201] 新增分級項下拉選單，針對選擇【飯店旅館】、【商場】提示使用者必須選擇A、B；【其他】時，提示使用者必須選擇A、B、C --%>
			buttons.setSelectOption();
			$('GRADING_ITEM_VIEW').value=rtnMap.GRADING_ITEM ? rtnMap.GRADING_ITEM : '';
			$('BASEMENT_FLOOR_VIEW').value=rtnMap.BASEMENT_FLOOR ? rtnMap.BASEMENT_FLOOR : '';
			
			$('BUILD_AGE_VIEW').innerHTML=rtnMap.A050_BUILD_AGE ? CSRUtil.$fmt(rtnMap.A050_BUILD_AGE, defaultPattern2)+'年' : '0年';
			$('GAGE_ADDR_VIEW').innerHTML=rtnMap.GAGE_ADDR ? rtnMap.GAGE_ADDR : '';
			//$('LIGHT_VIEW').innerHTML=rtnMap.LIGHT ? eval('rtnMap.LIGHT') : ''; //改由A214List取得
			$('A040_LAND_SPACE_VIEW').innerHTML=rtnMap.A040_LAND_SPACE ? CSRUtil.$fmt(rtnMap.A040_LAND_SPACE, defaultPattern2)+'坪' : '0坪';
			$('A050_BUILD_SPACE_VIEW').innerHTML=rtnMap.A050_BUILD_SPACE ? CSRUtil.$fmt(rtnMap.A050_BUILD_SPACE, defaultPattern2)+'坪' : '0坪';
			$('USE_AREA1_VIEW').value=rtnMap.USE_AREA1 ? rtnMap.USE_AREA1 : '0';
			$('USE_AREA2_VIEW').value=rtnMap.USE_AREA2 ? rtnMap.USE_AREA2 : '';
			$('FINISH_DATE').value=rtnMap.FINISH_DATE ? rtnMap.FINISH_DATE : '';
			$('LONGITUDE').value=rtnMap.LONGITUDE ? rtnMap.LONGITUDE : ''; 
			$('LATITUDE').value=rtnMap.LATITUDE ? rtnMap.LATITUDE : '';
			$('LAND_MEASURE').value=rtnMap.A040_LAND_SPACE ? rtnMap.A040_LAND_SPACE : '0';
			$('BUILD_MEASURE').value=rtnMap.A050_BUILD_SPACE ? rtnMap.A050_BUILD_SPACE : '0';
			$('BUILD_AGE').value=rtnMap.A050_BUILD_AGE ? rtnMap.A050_BUILD_AGE : '0';
			$('PIC_CASE_NAME').value=rtnMap.PIC_CASE_NAME ? rtnMap.PIC_CASE_NAME : '';
			$('MAP_AREA_CODE').value=rtnMap.MAP_AREA_CODE ? rtnMap.MAP_AREA_CODE : '';
			<%--[20201127] 調整承作分區判斷邏輯新增承作分區、擔保品郵遞區號欄位--%>
			var AREA_CODE_930318 = rtnMap.AREA_CODE_930318 ? rtnMap.AREA_CODE_930318 : '';
			$('AREA_CODE_930318').value = AREA_CODE_930318;
			$('CONTRACT_AREA_VIEW').value=rtnMap.CONTRACT_AREA ? rtnMap.CONTRACT_AREA : '0';
			<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%>
			$('SUBMKT_ID').setValue(rtnMap.SUBMKT_ID ||'');
			$('SUBMKT_VERSION').setValue(rtnMap.SUBMKT_VERSION ||'');
			$('SUBMKT_NAME').setValue(rtnMap.SUBMKT_NAME ||'');
			$('AREA_CODE_MATCH_LEVEL').setValue(rtnMap.MATCH_LEVEL || (rtnMap.AREA_CODE_MATCH_LEVEL||''));
			
			$('GAGE_ZIP').value = rtnMap.GAGE_ZIP ? rtnMap.GAGE_ZIP : '';
			
			var A214List = rtnMap.A214List ? rtnMap.A214List : [];
			if(A214List){
				var LIGHT_VIEW = '';
				for(var i = 1; i <= A214List.length; i++){
					var A214Map = A214List[i-1];
					var PERIOD = A214Map.PERIOD ? A214Map.PERIOD : '';
					var LIGHT = A214Map.LIGHT ? A214Map.LIGHT : '';
					if(LIGHT=='紅燈'){
						LIGHT_VIEW = LIGHT_VIEW+PERIOD+"<font color=red>紅燈</font><img id='IMG_LIGHT' src='/DSWeb/images/DS/lightR.gif' border=0>";
					}else if(LIGHT=='橘燈'){
						LIGHT_VIEW = LIGHT_VIEW+PERIOD+"<font color=orange>橘燈</font><img id='IMG_LIGHT' src='/DSWeb/images/DS/lightO.gif' border=0>";
					}else if(LIGHT=='綠燈'){
						LIGHT_VIEW = LIGHT_VIEW+PERIOD+"<font color=green>綠燈</font><img id='IMG_LIGHT' src='/DSWeb/images/DS/lightG.gif' border=0>";
					}else if(LIGHT=='黃燈'){
						LIGHT_VIEW = LIGHT_VIEW+PERIOD+"<font color=yellow>黃燈</font><img id='IMG_LIGHT' src='/DSWeb/images/DS/lightY.gif' border=0>";
					}else if(LIGHT=='藍燈'){
						LIGHT_VIEW = LIGHT_VIEW+PERIOD+"<font color=blue>藍燈</font><img id='IMG_LIGHT' src='/DSWeb/images/DS/lightB.gif' border=0>";
					}else if(LIGHT=='紫燈'){
						LIGHT_VIEW = LIGHT_VIEW+PERIOD+"<font color=purple>紫燈</font><img id='IMG_LIGHT' src='/DSWeb/images/DS/lightP.gif' border=0>";
					}
				}
				$('LIGHT_VIEW').innerHTML=LIGHT_VIEW;
			}
		},
		
		//table_C
		setTable_C : function(rtnMap){
			$('BROKER_NAME').value=rtnMap.BROKER_NAME ? rtnMap.BROKER_NAME : '';
			if(rtnMap.WELL_CONTRACT=='1'){
				$('WELL_CONTRACT_Y').checked = true;
			}else if(rtnMap.WELL_CONTRACT=='0'){
				$('WELL_CONTRACT_N').checked = true;
			}else {
			    $('WELL_CONTRACT_Y').checked = false;
			    $('WELL_CONTRACT_N').checked = false;
			}
			
			//土地是否其他登記事項
			if(rtnMap.IS_LAND=='1'){
				$('IS_LAND_Y').checked = true;
			}else if(rtnMap.IS_LAND=='0'){
				$('IS_LAND_N').checked = true;
			}else {
			    $('IS_LAND_Y').checked = false;
			    $('IS_LAND_N').checked = false;
			}
			$('RESTRICT_AREA_VIEW').value=rtnMap.RESTRICT_AREA ? rtnMap.RESTRICT_AREA : '';
			$('TRADE_AMT_VIEW').value=JsUtils.isBasicType(rtnMap.TRADE_AMT) ? CSRUtil.$fmt(rtnMap.TRADE_AMT, defaultPattern1) : '';
			$('TRADE_DATE_VIEW').value=rtnMap.TRADE_DATE ? Date.toInputROC(rtnMap.TRADE_DATE, '') : '';
			//$('CONTROL_AREA_VIEW').value=rtnMap.CONTROL_AREA ? rtnMap.CONTROL_AREA : '';
			$('CASE_NAME_VIEW').value=rtnMap.CASE_NAME ? rtnMap.CASE_NAME : '';
			//社區編號
			$('COMMUNITY_NO_VIEW').value=rtnMap.COMMUNITY_NO ? rtnMap.COMMUNITY_NO : '';
			if(rtnMap.COMMUNITY_NO) {
				var COMMUNITY_NO = rtnMap.COMMUNITY_NO;
				var url2;
				if(${IS_BANK_USER}){
					url2 = "<%=dispatcher%>/DSA3_2400/prompt";
					//產生超連結
					var link = new Element('a',
					{ href: '#'}).update(COMMUNITY_NO).observe('click',
						function() {
							popupWin.windowOpen( url2 ,
							{
								'parameters': {'CathayNo': COMMUNITY_NO, 'ActionType': '06'},
								'fullScreen': false,
								'attributes': {'resizable': 'yes'},
								'windowName': 'DSA33310'
							});
						}
					);	
					$('COMMUNITY_NO_LINK_VIEW').update(link);
				} else {
					url2 = '<%=dispatcher%>/DSA3_3310/prompt';
					//產生超連結
					var link = new Element('a',
					{ href: '#'}).update(COMMUNITY_NO).observe('click',
						function() {
							popupWin.windowOpen( url2 ,
							{
								'parameters': {'COMMUNITY_NO': COMMUNITY_NO},
								'fullScreen': false,
								'attributes': {'resizable': 'yes'}
							});
						}
					);	
					$('COMMUNITY_NO_LINK_VIEW').update(link);
				}
			} else {
				$('COMMUNITY_NO_LINK_VIEW').update("");
			}
			$('UPDATE_PIC_DATE_VIEW').innerHTML=rtnMap.UPDATE_PIC_DATE ? Date.toInputROC(rtnMap.UPDATE_PIC_DATE, '/') : '';
			$('HOUSE_NO_VIEW').value=JsUtils.isBasicType(rtnMap.HOUSE_NO) ? CSRUtil.$fmt(rtnMap.HOUSE_NO, defaultPattern1) : '';
			$('SALE_RATE_VIEW').value=JsUtils.isBasicType(rtnMap.SALE_RATE) ? CSRUtil.$fmt(rtnMap.SALE_RATE, defaultPattern1) : '';
			$('REST_RATE_VIEW').value=JsUtils.isBasicType(rtnMap.REST_RATE) ? CSRUtil.$fmt(rtnMap.REST_RATE, defaultPattern1) : '';
			$('OPEN_RATE_VIEW').value=JsUtils.isBasicType(rtnMap.OPEN_RATE) ? CSRUtil.$fmt(rtnMap.OPEN_RATE, defaultPattern1) : '';
			resetSPC_CONDITION(rtnMap);//重設特殊屋況檢核區塊
			$('ROAD_WIDTH_VIEW').value=JsUtils.isBasicType(rtnMap.ROAD_WIDTH) ? CSRUtil.$fmt(rtnMap.ROAD_WIDTH, defaultPattern1) : '';
			$('NEAR_DEPTH_VIEW').value=JsUtils.isBasicType(rtnMap.NEAR_DEPTH) ? CSRUtil.$fmt(rtnMap.NEAR_DEPTH, defaultPattern1) : '';
			$('LAND_WIDTH_VIEW').value=JsUtils.isBasicType(rtnMap.LAND_WIDTH) ? CSRUtil.$fmt(rtnMap.LAND_WIDTH, defaultPattern1) : '';
			$('BUILD_WIDTH_VIEW').value=JsUtils.isBasicType(rtnMap.BUILD_WIDTH) ? CSRUtil.$fmt(rtnMap.BUILD_WIDTH, defaultPattern1) : '';
			$('USE_STATUS_VIEW').value=rtnMap.USE_STATUS ? rtnMap.USE_STATUS : '';
			$('RENT_PRICE_VIEW').value=JsUtils.isBasicType(rtnMap.RENT_PRICE) ? CSRUtil.$fmt(rtnMap.RENT_PRICE, defaultPattern1) : '';
			$('INVESTIGATE_STATUS_VIEW').value=rtnMap.INVESTIGATE_STATUS ? rtnMap.INVESTIGATE_STATUS : ''; 
			$('ASPECT_VIEW').value=rtnMap.ASPECT ? rtnMap.ASPECT : '';
			$('SITE_VIEW').value=rtnMap.SITE ? rtnMap.SITE : '';
			$('A200_BUILD_ADD_VIEW').value=rtnMap.BUILD_ADD ? rtnMap.BUILD_ADD : '';
			$('TOTAL_SPACE_VIEW').value=JsUtils.isBasicType(rtnMap.TOTAL_SPACE) ? CSRUtil.$fmt(rtnMap.TOTAL_SPACE, defaultPattern2) : '';
			$('BUILD_ADD_DESC_VIEW').value=rtnMap.BUILD_ADD_DESC ? rtnMap.BUILD_ADD_DESC : '';
			$('PUB_RATE_VIEW').value=JsUtils.isBasicType(rtnMap.PUB_RATE) ? CSRUtil.$fmt(rtnMap.PUB_RATE, defaultPattern1) : '';
			$('PARK_VIEW').value=JsUtils.isBasicType(rtnMap.PARK) ? CSRUtil.$fmt(rtnMap.PARK, defaultPattern1) : '';
			$('PARK_NO_VIEW').value=rtnMap.PARK_NO ? rtnMap.PARK_NO : '';
			$('PARK_SPACE_VIEW').value=JsUtils.isBasicType(rtnMap.PARK_SPACE) ? CSRUtil.$fmt(rtnMap.PARK_SPACE, defaultPattern2) : '';
			var sloganStr = rtnMap.SLOGAN1 ? rtnMap.SLOGAN1 : '';
			if(rtnMap.SLOGAN2) {
				if(sloganStr) {
					sloganStr = sloganStr + '<br>' + rtnMap.SLOGAN2;
				} else {
					sloganStr = sloganStr + rtnMap.SLOGAN2;
				}
			}
			if(rtnMap.SLOGAN3) {
				if(sloganStr) {
					sloganStr = sloganStr + '<br>' + rtnMap.SLOGAN3;
				} else {
					sloganStr = sloganStr + rtnMap.SLOGAN3;
				}
			}
			$('SLOGAN_VIEW').innerHTML=sloganStr;

			//[20210712] 特殊擔保品選項、現況出入無虞
			//特殊擔保品選項
			$('SPC_GAGE_OPT_VIEW').setValue(rtnMap.SPC_GAGE_OPT ? rtnMap.SPC_GAGE_OPT : '');

			//現況出入無虞 (若「特殊擔保品選項」為「裡地」(18)，現況出入無虞資料才顯示，否則不顯示)
			if ($('SPC_GAGE_OPT_VIEW').value == '18') {
				//顯示 DIV 區塊 (文字「現況出入無虞」 + 是/否 2個 radio )
				//inline-block 水平排列不換行 
				$('SPC_GAGE_TYPE_NM').style.display = 'inline-block';
				if(rtnMap.SPC_GAGE_TYPE=='Y'){
					$('SPC_GAGE_TYPE_Y').checked = true;
					$('SPC_GAGE_TYPE_hidden').setValue('Y');
				}else if(rtnMap.SPC_GAGE_TYPE=='N'){
					$('SPC_GAGE_TYPE_N').checked = true;
					$('SPC_GAGE_TYPE_hidden').setValue('N');
				}else {
				    $('SPC_GAGE_TYPE_Y').checked = false;
				    $('SPC_GAGE_TYPE_N').checked = false;
				    $('SPC_GAGE_TYPE_hidden').setValue('');
				}
			} else {
				//隱藏 DIV 區塊
				$('SPC_GAGE_TYPE_Y').checked = false;
				$('SPC_GAGE_TYPE_N').checked = false;
			    $('SPC_GAGE_TYPE_hidden').setValue('');
				$('SPC_GAGE_TYPE_NM').style.display = 'none';
			}
		},
		
		//table_D
		setTable_D : function(resp){
			var rtnMap = resp.rtnMap ? resp.rtnMap : {};
			//$('ROAD_WIDTH2_VIEW').value=JsUtils.isBasicType(rtnMap.ROAD_WIDTH2) ? CSRUtil.$fmt(rtnMap.ROAD_WIDTH2, defaultPattern1) : '';
			//$('ROAD_NAME_VIEW').value=rtnMap.ROAD_NAME ? rtnMap.ROAD_NAME : '';
			//$('NEAR_DISTANCE_VIEW').value=JsUtils.isBasicType(rtnMap.NEAR_DISTANCE) ? CSRUtil.$fmt(rtnMap.NEAR_DISTANCE, defaultPattern1) : '';
			$('SHOP_KIND_VIEW').value=rtnMap.SHOP_KIND ? rtnMap.SHOP_KIND : '';
			$('SHOP_STATUS_VIEW').value=rtnMap.SHOP_STATUS ? rtnMap.SHOP_STATUS : '';
			if(rtnMap.AREA_ADD && rtnMap.AREA_ADD=='1'){
				$('AREA_ADD_VIEW').checked = true;
			}else{
				$('AREA_ADD_VIEW').checked = false;
			}
			//$('AREA_ADD_VIEW').value=rtnMap.AREA_ADD ? rtnMap.AREA_ADD : '';
			$('MANAGE_STATUS_VIEW').value=rtnMap.MANAGE_STATUS ? rtnMap.MANAGE_STATUS : '';
			$('LIFE_FUNC_VIEW').value=rtnMap.LIFE_FUNC ? rtnMap.LIFE_FUNC : '';
			$('TRFC_FUNC_VIEW').value=rtnMap.TRFC_FUNC ? rtnMap.TRFC_FUNC : '';
			$('HOUSE_CONDITIONS_VIEW').value=rtnMap.HOUSE_CONDITIONS ? rtnMap.HOUSE_CONDITIONS : '';
			$('NOPIC_REASON_VIEW').value=rtnMap.NOPIC_REASON ? rtnMap.NOPIC_REASON : '';
			$('HOUSE_PIC_DATE_VIEW').value=rtnMap.HOUSE_PIC_DATE ? Date.toInputROC(rtnMap.HOUSE_PIC_DATE,'') : '';
			$('APPEARANCE_PIC_REASON_VIEW').value=rtnMap.APPEARANCE_PIC_REASON ? rtnMap.APPEARANCE_PIC_REASON : '';
			$('APPEARANCE_PIC_DATE_VIEW').value=rtnMap.APPEARANCE_PIC_DATE ? Date.toInputROC(rtnMap.APPEARANCE_PIC_DATE,'') : '';
			$('FOLLOW_NUMBER_VIEW').value=rtnMap.FOLLOW_NUMBER ? rtnMap.FOLLOW_NUMBER : '';
			$('PHOTO_ID_VIEW').value=rtnMap.PHOTO_ID ? rtnMap.PHOTO_ID : '';
			$('PHOTO_NM_VIEW').innerHTML=rtnMap.PHOTO_NM ? rtnMap.PHOTO_NM : '';
			$('DISLIKE_FACILITY_VIEW').value=rtnMap.DISLIKE_FACILITY ? rtnMap.DISLIKE_FACILITY : '';
			$('DISLIKE_DISTANCE_VIEW').value=JsUtils.isBasicType(rtnMap.DISLIKE_DISTANCE) ? CSRUtil.$fmt(rtnMap.DISLIKE_DISTANCE, defaultPattern1) : '';
			$('DISLIKE_EFFECT_VIEW').value=rtnMap.DISLIKE_EFFECT ? rtnMap.DISLIKE_EFFECT : '';
			$('DISLIKE_FACILITY2_VIEW').value=rtnMap.DISLIKE_FACILITY2 ? rtnMap.DISLIKE_FACILITY2 : '';
			$('DISLIKE_DISTANCE2_VIEW').value=JsUtils.isBasicType(rtnMap.DISLIKE_DISTANCE2) ? CSRUtil.$fmt(rtnMap.DISLIKE_DISTANCE2, defaultPattern1) : '';
			$('DISLIKE_EFFECT2_VIEW').value=rtnMap.DISLIKE_EFFECT2 ? rtnMap.DISLIKE_EFFECT2 : '';
			$('SPC_DISTANCE_VIEW').value=JsUtils.isBasicType(rtnMap.SPC_DISTANCE) ? CSRUtil.$fmt(rtnMap.SPC_DISTANCE, defaultPattern1) : '';
			$('SPC_KD_BAD_VIEW').value=rtnMap.SPC_KD_BAD ? rtnMap.SPC_KD_BAD : '';
			$('SPC_RATE_VIEW').value=JsUtils.isBasicType(rtnMap.SPC_RATE) ? CSRUtil.$fmt(rtnMap.SPC_RATE, defaultPattern1) : '';
			$('DISLIKE_DESC_VIEW').value=rtnMap.DISLIKE_DESC ? rtnMap.DISLIKE_DESC : '';
			$('SPC_KD_GOOD_NAME_VIEW').value=rtnMap.SPC_KD_GOOD_NAME ? rtnMap.SPC_KD_GOOD_NAME : '';
			$('SPC_KD_GOOD_VIEW').value=rtnMap.SPC_KD_GOOD ? rtnMap.SPC_KD_GOOD : '';
			$('SPC_DISTANCE1_VIEW').value=JsUtils.isBasicType(rtnMap.SPC_DISTANCE1) ? CSRUtil.$fmt(rtnMap.SPC_DISTANCE1, defaultPattern1) : '';
			$('SPC_KD_GOOD_NAME2_VIEW').value=rtnMap.SPC_KD_GOOD_NAME2 ? rtnMap.SPC_KD_GOOD_NAME2 : '';
			$('SPC_KD_GOOD2_VIEW').value=rtnMap.SPC_KD_GOOD2 ? rtnMap.SPC_KD_GOOD2 : '';
			$('SPC_DISTANCE2_VIEW').value=JsUtils.isBasicType(rtnMap.SPC_DISTANCE2) ? CSRUtil.$fmt(rtnMap.SPC_DISTANCE2, defaultPattern1) : '';
			$('SPC_DESC_VIEW').value=rtnMap.SPC_DESC ? rtnMap.SPC_DESC : '';
			
			//D區A213List
			buttons.setTable_D1(resp);
			
			$('METRO_VIEW').value=rtnMap.METRO ? rtnMap.METRO : '';
			$('BUILD_LINE_VIEW').value=rtnMap.BUILD_LINE ? rtnMap.BUILD_LINE : '';
			$('STATION_VIEW').value=rtnMap.STATION ? rtnMap.STATION : '';
			$('BUILD_STATION_VIEW').value=rtnMap.BUILD_STATION ? rtnMap.BUILD_STATION : '';
			$('METRO1_VIEW').value=rtnMap.METRO1 ? rtnMap.METRO1 : '';
			$('ROUND_LINE_VIEW').value=rtnMap.ROUND_LINE ? rtnMap.ROUND_LINE : '';
			$('STATION1_VIEW').value=rtnMap.STATION1 ? rtnMap.STATION1 : '';
			$('ROUND_STATION_VIEW').value=rtnMap.ROUND_STATION ? rtnMap.ROUND_STATION : '';
			$('ROUND_EXIT_VIEW').value=rtnMap.ROUND_EXIT ? rtnMap.ROUND_EXIT : '';
			$('ROUND_DISTANCE_VIEW').value=rtnMap.ROUND_DISTANCE ? rtnMap.ROUND_DISTANCE : '';
		},
		//gridE1
		setGridE1 : function(resp){
		
			var A201List = resp.A201List ? resp.A201List : [];
			
			if(A201List){
				for(var i = 1; i <= A201List.length; i++){
					var obj = A201List[i-1];
					$('APPLY_ID_VIEW_'+i).value = JsUtils.isBasicType(obj.APPLY_ID) ? obj.APPLY_ID : '';
					$('ADDRESS_VIEW_'+i).value = JsUtils.isBasicType(obj.ADDRESS) ? obj.ADDRESS : '';
					$('REF_TIME_VIEW_'+i).value = JsUtils.isBasicType(obj.REF_TIME) ? obj.REF_TIME : '';
					$('BUILD_AGE_VIEW_'+i).value = JsUtils.isBasicType(obj.BUILD_AGE) ? obj.BUILD_AGE : '';
					$('FLOOR_VIEW_'+i).value = JsUtils.isBasicType(obj.FLOOR) ? obj.FLOOR : '';
					$('MONTH_RENT_VIEW_'+i).value = JsUtils.isBasicType(obj.MONTH_RENT) ? obj.MONTH_RENT : '';
					$('RECOV_RATE_VIEW_'+i).value = JsUtils.isBasicType(obj.RECOV_RATE) ? obj.RECOV_RATE : '';
					$('LAND_SPACE_VIEW_'+i).value = JsUtils.isBasicType(obj.LAND_SPACE) ? obj.LAND_SPACE : '';
					$('BUILD_SPACE_VIEW_'+i).value = JsUtils.isBasicType(obj.BUILD_SPACE) ? obj.BUILD_SPACE : '';
					$('BUILD_WIDTH_VIEW_'+i).value = JsUtils.isBasicType(obj.BUILD_WIDTH) ? obj.BUILD_WIDTH : '';
					$('BUILD_ADD_VIEW_'+i).value = JsUtils.isBasicType(obj.BUILD_ADD) ? obj.BUILD_ADD : '';
					$('BUILD_PRICE_VIEW_'+i).value = JsUtils.isBasicType(obj.BUILD_PRICE) ? obj.BUILD_PRICE : '';
					$('LAND_PRICE_VIEW_'+i).value = JsUtils.isBasicType(obj.LAND_PRICE) ? obj.LAND_PRICE : '';
					$('PER_PRICE_VIEW_'+i).value = JsUtils.isBasicType(obj.PER_PRICE) ? obj.PER_PRICE : '';
					$('TOTAL_PRICE_VIEW_'+i).value = JsUtils.isBasicType(obj.TOTAL_PRICE) ? obj.TOTAL_PRICE : '';
					$('PARK_SPACE_VIEW_'+i).value = JsUtils.isBasicType(obj.PARK_SPACE) ? obj.PARK_SPACE : '';
					$('PARK_PRICE_VIEW_'+i).value = JsUtils.isBasicType(obj.PARK_PRICE) ? obj.PARK_PRICE : '';
					//$('DISTANCE_VIEW_'+i).value = JsUtils.isBasicType(obj.DISTANCE) ? obj.DISTANCE : '';
					$('REF_SRC_VIEW_'+i).value = JsUtils.isBasicType(obj.REF_SRC) ? obj.REF_SRC : '';
					$('TIME_TEL_VIEW_'+i).value = JsUtils.isBasicType(obj.TIME_TEL) ? obj.TIME_TEL : '';
					//$('USE_TYPE_VIEW_'+i).value = JsUtils.isBasicType(obj.USE_TYPE) ? obj.USE_TYPE : '';
				}
			}
		},
		//gridE1
		setRefGridE1 : function(resp){
		
			var A201List = resp.A201List ? resp.A201List : [];
			
			if(A201List){
				for(var i = 1; i <= A201List.length; i++){
					var obj = A201List[i-1];
					//取得對應SEQ_NO寫入畫面欄位 EX:SEQ_NO=1對應訪價資料甲,SEQ_NO=2對應訪價資料乙...
					var j = JsUtils.isBasicType(obj.SEQ_NO) ? obj.SEQ_NO : '';
					if (j != '') {
						$('APPLY_ID_VIEW_'+j).value = JsUtils.isBasicType(obj.APPLY_ID) ? obj.APPLY_ID : '';
						$('ADDRESS_VIEW_'+j).value = JsUtils.isBasicType(obj.ADDRESS) ? obj.ADDRESS : '';
						$('REF_TIME_VIEW_'+j).value = JsUtils.isBasicType(obj.REF_TIME) ? obj.REF_TIME : '';
						$('BUILD_AGE_VIEW_'+j).value = JsUtils.isBasicType(obj.BUILD_AGE) ? obj.BUILD_AGE : '';
						$('FLOOR_VIEW_'+j).value = JsUtils.isBasicType(obj.FLOOR) ? obj.FLOOR : '';
						$('MONTH_RENT_VIEW_'+j).value = JsUtils.isBasicType(obj.MONTH_RENT) ? obj.MONTH_RENT : '';
						$('RECOV_RATE_VIEW_'+j).value = JsUtils.isBasicType(obj.RECOV_RATE) ? obj.RECOV_RATE : '';
						$('LAND_SPACE_VIEW_'+j).value = JsUtils.isBasicType(obj.LAND_SPACE) ? obj.LAND_SPACE : '';
						$('BUILD_SPACE_VIEW_'+j).value = JsUtils.isBasicType(obj.BUILD_SPACE) ? obj.BUILD_SPACE : '';
						$('BUILD_WIDTH_VIEW_'+j).value = JsUtils.isBasicType(obj.BUILD_WIDTH) ? obj.BUILD_WIDTH : '';
						$('BUILD_ADD_VIEW_'+j).value = JsUtils.isBasicType(obj.BUILD_ADD) ? obj.BUILD_ADD : '';
						$('BUILD_PRICE_VIEW_'+j).value = JsUtils.isBasicType(obj.BUILD_PRICE) ? obj.BUILD_PRICE : '';
						$('LAND_PRICE_VIEW_'+j).value = JsUtils.isBasicType(obj.LAND_PRICE) ? obj.LAND_PRICE : '';
						$('PER_PRICE_VIEW_'+j).value = JsUtils.isBasicType(obj.PER_PRICE) ? obj.PER_PRICE : '';
						$('TOTAL_PRICE_VIEW_'+j).value = JsUtils.isBasicType(obj.TOTAL_PRICE) ? obj.TOTAL_PRICE : '';
						$('PARK_SPACE_VIEW_'+j).value = JsUtils.isBasicType(obj.PARK_SPACE) ? obj.PARK_SPACE : '';
						$('PARK_PRICE_VIEW_'+j).value = JsUtils.isBasicType(obj.PARK_PRICE) ? obj.PARK_PRICE : '';
						//$('DISTANCE_VIEW_'+j).value = JsUtils.isBasicType(obj.DISTANCE) ? obj.DISTANCE : '';
						$('REF_SRC_VIEW_'+j).value = JsUtils.isBasicType(obj.REF_SRC) ? obj.REF_SRC : '';
						$('TIME_TEL_VIEW_'+j).value = JsUtils.isBasicType(obj.TIME_TEL) ? obj.TIME_TEL : '';
						//$('USE_TYPE_VIEW_'+j).value = JsUtils.isBasicType(obj.USE_TYPE) ? obj.USE_TYPE : '';
					}
				}
			}
		},
		//gridF1
		setGridF1 : function(resp){

			var A209List = resp.A209List ? resp.A209List : [];
			if(A209List && A209List.length != 0){
				$('MEASURE_KIND_VIEW').value = JsUtils.isBasicType(A209List[0].MEASURE_KIND) ? A209List[0].MEASURE_KIND : '';
				$('DIFF_KIND_A_VIEW').value = JsUtils.isBasicType(A209List[0].DIFF_KIND_A) ? A209List[0].DIFF_KIND_A : '';
				$('DIFF_KIND_B_VIEW').value = JsUtils.isBasicType(A209List[0].DIFF_KIND_B) ? A209List[0].DIFF_KIND_B : '';
				
				for(var i = 1; i <= A209List.length; i++){
					var obj = A209List[i-1];
					$('APPLY_ID_'+i).value = JsUtils.isBasicType(obj.APPLY_ID) ? obj.APPLY_ID : '';
					$('DIFF_TIME_'+i).value = JsUtils.isBasicType(obj.DIFF_TIME) ? obj.DIFF_TIME : '';
					$('DIFF_TRAFFIC_'+i).value = JsUtils.isBasicType(obj.DIFF_TRAFFIC) ? obj.DIFF_TRAFFIC : '';
					$('DIFF_LIFE_'+i).value = JsUtils.isBasicType(obj.DIFF_LIFE) ? obj.DIFF_LIFE : '';
					$('DIFF_NEAR_ROAD_'+i).value = JsUtils.isBasicType(obj.DIFF_NEAR_ROAD) ? obj.DIFF_NEAR_ROAD : '';
					$('DIFF_BUILD_AGE_'+i).value = JsUtils.isBasicType(obj.DIFF_BUILD_AGE) ? obj.DIFF_BUILD_AGE : '';
					$('DIFF_FLOOR_'+i).value = JsUtils.isBasicType(obj.DIFF_FLOOR) ? obj.DIFF_FLOOR : '';
					$('DIFF_MEASURE_'+i).value = JsUtils.isBasicType(obj.DIFF_MEASURE) ? obj.DIFF_MEASURE : '';
					$('DIFF_OPTION_A_'+i).value = JsUtils.isBasicType(obj.DIFF_OPTION_A) ? obj.DIFF_OPTION_A : '';
					$('DIFF_OPTION_B_'+i).value = JsUtils.isBasicType(obj.DIFF_OPTION_B) ? obj.DIFF_OPTION_B : '';
					$('DIFF_SYNTH_'+i).value = JsUtils.isBasicType(obj.DIFF_SYNTH) ? obj.DIFF_SYNTH : '';
					$('LOWER_PRICE_'+i).value = JsUtils.isBasicType(obj.LOWER_PRICE) ? obj.LOWER_PRICE : '';
					$('UPPER_PRICE_'+i).value = JsUtils.isBasicType(obj.UPPER_PRICE) ? obj.UPPER_PRICE : '';
				}
			}
		},
		//table_D1
		setTable_D1 : function(resp){
			//D區A213BList(DISLIKEList)
			//A213BList_VIEW
			var A213BList = resp.A213BList ? resp.A213BList : [];
			if(A213BList){
				$('A213BList_VIEW').innerHTML = '';
				var A213BList_VIEW = $('A213BList_VIEW');
				for(var i = 0; i < A213BList.length; i++){
					var obj = A213BList[i];
					var textNode = document.createTextNode('近');
					A213BList_VIEW.appendChild(textNode);
					var input = document.createElement('input');
					input.id = 'SPC_NAME_A213B_VIEW_'+i;
					input.value = obj.SPC_NAME ? obj.SPC_NAME : "";
					input.type = 'TEXT';
					input.size = "20";
					input.maxLength = "30";
					input.fieldName = "設施名稱";
					input.className = 'required';
					A213BList_VIEW.appendChild(input);
					
					textNode = document.createTextNode('');
					A213BList_VIEW.appendChild(textNode);
					
					var select = document.createElement('select');
					select.id = 'SPC_FACILITY_A213B_VIEW_'+i;
					select.className = 'required';
					A213BList_VIEW.appendChild(select);
					<c:forEach var="map" items="${DISLIKE_FACILITY_LIST}">
						var opt = document.createElement("option");
						opt.text = "${map.value}";
						opt.value = "${map.key}";
						$(select.id).add(opt);
					</c:forEach>
					$(select.id).value = obj.SPC_FACILITY;
					
					textNode = document.createTextNode('約');
					A213BList_VIEW.appendChild(textNode);
					
					input = document.createElement('input');
					input.id = 'SPC_DISTANCE_A213B_VIEW_'+i;
					input.value = obj.SPC_DISTANCE ? CSRUtil.$fmt(obj.SPC_DISTANCE, defaultPattern1) : "0";
					input.type = 'TEXT';
					input.size = "5";
					input.maxLength = "10";
					input.datatype = "number"; 
					input.pattern = defaultPattern1;
					input.fieldName = "距離";
					input.className = 'required';
					A213BList_VIEW.appendChild(input);
					
					textNode = document.createTextNode('公尺，影響');
					A213BList_VIEW.appendChild(textNode);
					
					select = document.createElement('select');
					select.id = 'SPC_EFFECT_A213B_VIEW_'+i;
					select.className = 'required';
					A213BList_VIEW.appendChild(select);
					<c:forEach var="map" items="${DISLIKE_EFFECT_LIST}">
						var opt = document.createElement("option");
						opt.text = "${map.value}";
						opt.value = "${map.key}";
						$(select.id).add(opt);
					</c:forEach>
					$(select.id).value = obj.SPC_EFFECT;
					
					input = document.createElement('input');
					input.id = 'APPLY_ID_A213B_VIEW_'+i;
					input.value = obj.APPLY_ID ? obj.APPLY_ID : "";
					input.type = 'hidden';
					A213BList_VIEW.appendChild(input);
					
					input = document.createElement('input');
					input.id = 'SPC_TYPE_A213B_VIEW_'+i;
					input.value = obj.SPC_TYPE ? obj. SPC_TYPE : "";
					input.type = 'hidden';
					A213BList_VIEW.appendChild(input);

					input = document.createElement('input');
					input.id = 'SPC_SOURCE_A213B_VIEW_'+i;
					input.value = obj.SPC_SOURCE ? obj.SPC_SOURCE : "";
					input.type = 'hidden';
					A213BList_VIEW.appendChild(input);
					
					input = document.createElement('input');
					input.id = 'SPC_KIND_A213B_VIEW_'+i;
					input.value = obj.SPC_KIND ? obj.SPC_KIND : "";
					input.type = 'hidden';
					A213BList_VIEW.appendChild(input);
					
					input = document.createElement('input');
					input.id = 'SPC_ID_A213B_VIEW_'+i;
					input.value = obj.SPC_ID ? obj.SPC_ID : "";
					input.type = 'hidden';
					A213BList_VIEW.appendChild(input);
					
					var br = document.createElement("br");
					A213BList_VIEW.appendChild(br);	
				}
				$('A213BList_VIEW').style.display = 'block';
				
			}
			//D區A213AList(GOODList)
			var A213AList = resp.A213AList ? resp.A213AList : [];
			if(A213AList){
				$('A213AList_VIEW').innerHTML = '';
				var A213AList_VIEW = $('A213AList_VIEW');
				for(var i = 0; i < A213AList.length; i++){
					var obj = A213AList[i];
					var textNode = document.createTextNode('，');
					if (i%2==1) {
						A213AList_VIEW.appendChild(textNode);
					}
					textNode = document.createTextNode('近');
					A213AList_VIEW.appendChild(textNode);
					var input = document.createElement('input');
					input.id = 'SPC_NAME_A213A_VIEW_'+i;
					input.value = obj.SPC_NAME ? obj.SPC_NAME : "";
					input.type = 'TEXT';
					input.size = "20";
					input.maxLength = "30";
					input.fieldName = "設施名稱";
					input.className = 'required';
					A213AList_VIEW.appendChild(input);
					
					textNode = document.createTextNode('');
					A213AList_VIEW.appendChild(textNode);
					
					var select = document.createElement('select');
					select.id = 'SPC_FACILITY_A213A_VIEW_'+i;
					select.className = 'required';
					A213AList_VIEW.appendChild(select);
					<c:forEach var="map" items="${SPC_KD_GOOD_LIST}">
						var opt = document.createElement("option");
						opt.text = "${map.value}";
						opt.value = "${map.key}";
						$(select.id).add(opt);
					</c:forEach>
					$(select.id).value = obj.SPC_FACILITY;
					
					textNode = document.createTextNode('約');
					A213AList_VIEW.appendChild(textNode);
					
					input = document.createElement('input');
					input.id = 'SPC_DISTANCE_A213A_VIEW_'+i;
					input.value = obj.SPC_DISTANCE ? CSRUtil.$fmt(obj.SPC_DISTANCE, defaultPattern1) : "0";
					input.type = 'TEXT';
					input.size = "5";
					input.maxLength = "10";
					input.datatype = "number"; 
					input.pattern = defaultPattern1;
					input.fieldName = "距離";
					input.className = 'required';
					A213AList_VIEW.appendChild(input);
					
					textNode = document.createTextNode('公尺');
					A213AList_VIEW.appendChild(textNode);
					
					input = document.createElement('input');
					input.id = 'APPLY_ID_A213A_VIEW_'+i;
					input.value = obj.APPLY_ID ? obj.APPLY_ID : "";
					input.type = 'hidden';
					A213AList_VIEW.appendChild(input);
					
					input = document.createElement('input');
					input.id = 'SPC_TYPE_A213A_VIEW_'+i;
					input.value = obj.SPC_TYPE ? obj. SPC_TYPE : "";
					input.type = 'hidden';
					A213AList_VIEW.appendChild(input);

					input = document.createElement('input');
					input.id = 'SPC_SOURCE_A213A_VIEW_'+i;
					input.value = obj.SPC_SOURCE ? obj.SPC_SOURCE : "";
					input.type = 'hidden';
					A213AList_VIEW.appendChild(input);
					
					input = document.createElement('input');
					input.id = 'SPC_KIND_A213A_VIEW_'+i;
					input.value = obj.SPC_KIND ? obj.SPC_KIND : "";
					input.type = 'hidden';
					A213AList_VIEW.appendChild(input);
					
					input = document.createElement('input');
					input.id = 'SPC_ID_A213A_VIEW_'+i;
					input.value = obj.SPC_ID ? obj.SPC_ID : "";
					input.type = 'hidden';
					A213AList_VIEW.appendChild(input);
					
					if (i%2==1) {
						var br = document.createElement("br");
						A213AList_VIEW.appendChild(br);
					}
				}
				$('A213AList_VIEW').style.display = 'block';
				
			}
			//D區A213CList(GOODList)
			var A213CList = resp.A213CList ? resp.A213CList : [];
			if(A213CList){
				$('A213CList_VIEW').innerHTML = '';
				var A213CList_VIEW = $('A213CList_VIEW');
				for(var i = 0; i < A213CList.length; i++){
					var obj = A213CList[i];
					var textNode = document.createTextNode('，');
					if (i%2==1) {
						A213CList_VIEW.appendChild(textNode);
					}
					textNode = document.createTextNode('近');
					A213CList_VIEW.appendChild(textNode);
					var input = document.createElement('input');
					input.id = 'SPC_NAME_A213C_VIEW_'+i;
					input.value = obj.SPC_NAME ? obj.SPC_NAME : "";
					input.type = 'TEXT';
					input.size = "20";
					input.maxLength = "30";
					input.fieldName = "設施名稱";
					input.className = 'required';
					A213CList_VIEW.appendChild(input);
					
					textNode = document.createTextNode('');
					A213CList_VIEW.appendChild(textNode);
					
					var select = document.createElement('select');
					select.id = 'SPC_FACILITY_A213C_VIEW_'+i;
					select.className = 'required';
					A213CList_VIEW.appendChild(select);
					<c:forEach var="map" items="${SPC_KD_GOOD_LIST}">
						var opt = document.createElement("option");
						opt.text = "${map.value}";
						opt.value = "${map.key}";
						$(select.id).add(opt);
					</c:forEach>
					$(select.id).value = obj.SPC_FACILITY;
					
					textNode = document.createTextNode('約');
					A213CList_VIEW.appendChild(textNode);
					
					input = document.createElement('input');
					input.id = 'SPC_DISTANCE_A213C_VIEW_'+i;
					input.value = obj.SPC_DISTANCE ? CSRUtil.$fmt(obj.SPC_DISTANCE, defaultPattern1) : "0";
					input.type = 'TEXT';
					input.size = "5";
					input.maxLength = "10";
					input.datatype = "number"; 
					input.pattern = defaultPattern1;
					input.fieldName = "距離";
					input.className = 'required';
					A213CList_VIEW.appendChild(input);
					
					textNode = document.createTextNode('公尺');
					A213CList_VIEW.appendChild(textNode);
					
					input = document.createElement('input');
					input.id = 'APPLY_ID_A213C_VIEW_'+i;
					input.value = obj.APPLY_ID ? obj.APPLY_ID : "";
					input.type = 'hidden';
					A213CList_VIEW.appendChild(input);
					
					input = document.createElement('input');
					input.id = 'SPC_TYPE_A213C_VIEW_'+i;
					input.value = obj.SPC_TYPE ? obj. SPC_TYPE : "";
					input.type = 'hidden';
					A213CList_VIEW.appendChild(input);

					input = document.createElement('input');
					input.id = 'SPC_SOURCE_A213C_VIEW_'+i;
					input.value = obj.SPC_SOURCE ? obj.SPC_SOURCE : "";
					input.type = 'hidden';
					A213CList_VIEW.appendChild(input);
					
					input = document.createElement('input');
					input.id = 'SPC_KIND_A213C_VIEW_'+i;
					input.value = obj.SPC_KIND ? obj.SPC_KIND : "";
					input.type = 'hidden';
					A213CList_VIEW.appendChild(input);
					
					input = document.createElement('input');
					input.id = 'SPC_ID_A213C_VIEW_'+i;
					input.value = obj.SPC_ID ? obj.SPC_ID : "";
					input.type = 'hidden';
					A213CList_VIEW.appendChild(input);
					
					if (i%2==1) {
						var br = document.createElement("br");
						A213CList_VIEW.appendChild(br);
					}
				}
				$('A213CList_VIEW').style.display = 'block';
			}
		},
		
		//table_M
		setTable_M : function(rtnMap){
			$('LAND_PRICEA_VIEW').value=JsUtils.isBasicType(rtnMap.LAND_PRICEA) ? CSRUtil.$fmt(rtnMap.LAND_PRICEA, defaultPattern1) : '';
			$('BUILD_PRICEA_VIEW').value=JsUtils.isBasicType(rtnMap.BUILD_PRICEA) ? CSRUtil.$fmt(rtnMap.BUILD_PRICEA, defaultPattern1) : '';
			$('PARK_NUM_VIEW_1').value=JsUtils.isBasicType(rtnMap.PARK_NUM) ? CSRUtil.$fmt(rtnMap.PARK_NUM, defaultPattern1) : '';
			$('PARK_AMT_VIEW_1').value=JsUtils.isBasicType(rtnMap.PARK_AMT) ? CSRUtil.$fmt(rtnMap.PARK_AMT, defaultPattern1) : '';
			$('PARK_SPACEB_VIEW').value=JsUtils.isBasicType(rtnMap.PARK_SPACEB) ? CSRUtil.$fmt(rtnMap.PARK_SPACEB, defaultPattern2) : '';
			$('PARK_SPACEB1_VIEW').innerHTML=JsUtils.isBasicType(rtnMap.PARK_SPACEB) ? CSRUtil.$fmt(rtnMap.PARK_SPACEB, defaultPattern2) : '';
			$('ADD_SPACE_VIEW').value=JsUtils.isBasicType(rtnMap.ADD_SPACE) ? CSRUtil.$fmt(rtnMap.ADD_SPACE, defaultPattern1) : '';
			$('ADD_PRICE_VIEW').value=JsUtils.isBasicType(rtnMap.ADD_PRICE) ? CSRUtil.$fmt(rtnMap.ADD_PRICE, defaultPattern1) : '';
			$('PER_PRICE_VIEW').value=JsUtils.isBasicType(rtnMap.PER_PRICE) ? CSRUtil.$fmt(rtnMap.PER_PRICE, defaultPattern1) : '';
			$('TOTAL_PRICE_VIEW').value=JsUtils.isBasicType(rtnMap.TOTAL_PRICE) ? CSRUtil.$fmt(rtnMap.TOTAL_PRICE, defaultPattern1) : '';
			$('AVG_PRICE_VIEW').value=JsUtils.isBasicType(rtnMap.AVG_PRICE) ? CSRUtil.$fmt(rtnMap.AVG_PRICE, defaultPattern1) : '';
			$('FORMULA1_VIEW').value=rtnMap.FORMULA ? rtnMap.FORMULA : '';
			$('FORMULA_VIEW').value=rtnMap.FORMULA ? rtnMap.FORMULA : '';
		},
		
		//table_P
		setTable_P : function(rtnMap){
			$('CAPT_EXAM_VIEW').value=rtnMap.CAPT_EXAM ? rtnMap.CAPT_EXAM : '';
			$('CAPT_EXAM_DESC_VIEW').value=rtnMap.CAPT_EXAM_DESC ? rtnMap.CAPT_EXAM_DESC : '';
			$('CAPT_LAND_PRICEA_VIEW').value=rtnMap.CAPT_LAND_PRICEA ? CSRUtil.$fmt(rtnMap.CAPT_LAND_PRICEA, defaultPattern1) : '0';
			$('CAPT_BUILD_PRICEA_VIEW').value=rtnMap.CAPT_BUILD_PRICEA ? CSRUtil.$fmt(rtnMap.CAPT_BUILD_PRICEA, defaultPattern1) : '0';
			$('CAPT_PARK_PRICEA_VIEW').value=rtnMap.CAPT_PARK_PRICEA ? CSRUtil.$fmt(rtnMap.CAPT_PARK_PRICEA, defaultPattern1) : '0';
			$('CAPT_PARK_NUMA_VIEW').value=rtnMap.CAPT_PARK_NUMA ? CSRUtil.$fmt(rtnMap.CAPT_PARK_NUMA, defaultPattern1) : '0';
			$('CAPT_PER_PRICEA_VIEW').value=rtnMap.CAPT_PER_PRICEA ? CSRUtil.$fmt(rtnMap.CAPT_PER_PRICEA, defaultPattern1) : '0';
			$('CAPT_TOTAL_PRICEA_VIEW').value=rtnMap.CAPT_TOTAL_PRICEA ? CSRUtil.$fmt(rtnMap.CAPT_TOTAL_PRICEA, defaultPattern1) : '0';
			$('CAPT_AVG_PRICEA_VIEW').value=rtnMap.CAPT_AVG_PRICEA ? CSRUtil.$fmt(rtnMap.CAPT_AVG_PRICEA, defaultPattern1) : '0';
			$('CAPT_PARK_SPACEA_VIEW').value=rtnMap.CAPT_PARK_SPACEA ? CSRUtil.$fmt(rtnMap.CAPT_PARK_SPACEA, defaultPattern2) : '0';
			$('CAPT_LAND_PRICEB_VIEW').value=rtnMap.CAPT_LAND_PRICEB ? CSRUtil.$fmt(rtnMap.CAPT_LAND_PRICEB, defaultPattern1) : '0';
			$('CAPT_BUILD_PRICEB_VIEW').value=rtnMap.CAPT_BUILD_PRICEB ? CSRUtil.$fmt(rtnMap.CAPT_BUILD_PRICEB, defaultPattern1) : '0';
			$('CAPT_PARK_PRICEB_VIEW').value=rtnMap.CAPT_PARK_PRICEB ? CSRUtil.$fmt(rtnMap.CAPT_PARK_PRICEB, defaultPattern1) : '0';
			$('CAPT_PARK_NUMB_VIEW').value=rtnMap.CAPT_PARK_NUMB ? CSRUtil.$fmt(rtnMap.CAPT_PARK_NUMB, defaultPattern1) : '0';
			$('CAPT_PER_PRICEB_VIEW').value=rtnMap.CAPT_PER_PRICEB ? CSRUtil.$fmt(rtnMap.CAPT_PER_PRICEB, defaultPattern1) : '0';
			$('CAPT_TOTAL_PRICEB_VIEW').value=rtnMap.CAPT_TOTAL_PRICEB ? CSRUtil.$fmt(rtnMap.CAPT_TOTAL_PRICEB, defaultPattern1) : '0';
			$('CAPT_AVG_PRICEB_VIEW').value=rtnMap.CAPT_AVG_PRICEB ? CSRUtil.$fmt(rtnMap.CAPT_AVG_PRICEB, defaultPattern1) : '0';
			$('CAPT_PARK_SPACEB_VIEW').value=rtnMap.CAPT_PARK_SPACEB ? CSRUtil.$fmt(rtnMap.CAPT_PARK_SPACEB, defaultPattern2) : '0';
			var CAPT_NM_VIEW = rtnMap.CAPT_NM ? rtnMap.CAPT_NM : '';
			var CAPT_DATE_VIEW = rtnMap.CAPT_DATE ? Date.toROC(rtnMap.CAPT_DATE) : '';
			$('CAPT_NM_CAPT_DATE_VIEW').innerHTML = CAPT_NM_VIEW + CAPT_DATE_VIEW;
			

			$('BOSS_EXAM_VIEW').value=rtnMap.BOSS_EXAM ? rtnMap.BOSS_EXAM : '';
			$('BOSS_EXAM_DESC_VIEW').value=rtnMap.BOSS_EXAM_DESC ? rtnMap.BOSS_EXAM_DESC : '';
			$('BOSS_LAND_PRICEA_VIEW').value=rtnMap.BOSS_LAND_PRICEA ? CSRUtil.$fmt(rtnMap.BOSS_LAND_PRICEA, defaultPattern1) : '0';
			$('BOSS_BUILD_PRICEA_VIEW').value=rtnMap.BOSS_BUILD_PRICEA ? CSRUtil.$fmt(rtnMap.BOSS_BUILD_PRICEA, defaultPattern1) : '0';
			$('BOSS_PARK_PRICEA_VIEW').value=rtnMap.BOSS_PARK_PRICEA ? CSRUtil.$fmt(rtnMap.BOSS_PARK_PRICEA, defaultPattern1) : '0';
			$('BOSS_PARK_NUMA_VIEW').value=rtnMap.BOSS_PARK_NUMA ? CSRUtil.$fmt(rtnMap.BOSS_PARK_NUMA, defaultPattern1) : '0';
			$('BOSS_PER_PRICEA_VIEW').value=rtnMap.BOSS_PER_PRICEA ? CSRUtil.$fmt(rtnMap.BOSS_PER_PRICEA, defaultPattern1) : '0';
			$('BOSS_TOTAL_PRICEA_VIEW').value=rtnMap.BOSS_TOTAL_PRICEA ? CSRUtil.$fmt(rtnMap.BOSS_TOTAL_PRICEA, defaultPattern1) : '0';
			$('BOSS_AVG_PRICEA_VIEW').value=rtnMap.BOSS_AVG_PRICEA ? CSRUtil.$fmt(rtnMap.BOSS_AVG_PRICEA, defaultPattern1) : '0';
			$('BOSS_PARK_SPACEA_VIEW').value=rtnMap.BOSS_PARK_SPACEA ? CSRUtil.$fmt(rtnMap.BOSS_PARK_SPACEA, defaultPattern2) : '0';
			$('BOSS_LAND_PRICEB_VIEW').value=rtnMap.BOSS_LAND_PRICEB ? CSRUtil.$fmt(rtnMap.BOSS_LAND_PRICEB, defaultPattern1) : '0';
			$('BOSS_BUILD_PRICEB_VIEW').value=rtnMap.BOSS_BUILD_PRICEB ? CSRUtil.$fmt(rtnMap.BOSS_BUILD_PRICEB, defaultPattern1) : '0';
			$('BOSS_PARK_PRICEB_VIEW').value=rtnMap.BOSS_PARK_PRICEB ? CSRUtil.$fmt(rtnMap.BOSS_PARK_PRICEB, defaultPattern1) : '0';
			$('BOSS_PARK_NUMB_VIEW').value=rtnMap.BOSS_PARK_NUMB ? CSRUtil.$fmt(rtnMap.BOSS_PARK_NUMB, defaultPattern1) : '0';
			$('BOSS_PER_PRICEB_VIEW').value=rtnMap.BOSS_PER_PRICEB ? CSRUtil.$fmt(rtnMap.BOSS_PER_PRICEB, defaultPattern1) : '0';
			$('BOSS_TOTAL_PRICEB_VIEW').value=rtnMap.BOSS_TOTAL_PRICEB ? CSRUtil.$fmt(rtnMap.BOSS_TOTAL_PRICEB, defaultPattern1) : '0';
			$('BOSS_AVG_PRICEB_VIEW').value=rtnMap.BOSS_AVG_PRICEB ? CSRUtil.$fmt(rtnMap.BOSS_AVG_PRICEB, defaultPattern1) : '0';
			$('BOSS_PARK_SPACEB_VIEW').value=rtnMap.BOSS_PARK_SPACEB ? CSRUtil.$fmt(rtnMap.BOSS_PARK_SPACEB, defaultPattern2) : '0';
			var BOSS_NM_VIEW = rtnMap.BOSS_NM ? rtnMap.BOSS_NM : '';
			var BOSS_DATE_VIEW = rtnMap.BOSS_DATE ? Date.toROC(rtnMap.BOSS_DATE) : '';
			$('BOSS_NM_BOSS_DATE_VIEW').innerHTML = BOSS_NM_VIEW + BOSS_DATE_VIEW;
			
			var GM_NM_VIEW = rtnMap.GM_NM ? rtnMap.GM_NM : '';
			var GM_DATE_VIEW = rtnMap.GM_DATE ? Date.toROC(rtnMap.GM_DATE) : '';
			$('GM_NM_GM_DATE_VIEW').innerHTML = GM_NM_VIEW + GM_DATE_VIEW;
			$('GM_EXAM_DESC_VIEW').value=rtnMap.GM_EXAM_DESC ? rtnMap.GM_EXAM_DESC : '';
		},
		
		//E區gridE1Map
		setGridE1MAM003Map : function(rtnMap,val){
			$('ADDRESS_VIEW_'+val).value=rtnMap.ADDR ? rtnMap.ADDR.trim() : '';
			$('BUILD_AGE_VIEW_'+val).value=rtnMap.OBJ_AGE ? CSRUtil.$fmt(rtnMap.OBJ_AGE, defaultPattern1) : '';
			//$('LAND_SPACE_VIEW_'+val).value=rtnMap.OWN_AREA ? CSRUtil.$fmt(rtnMap.OWN_AREA, defaultPattern1) : '';
			$('PER_PRICE_VIEW_'+val).value=rtnMap.UNIT_PRICE ? CSRUtil.$fmt(rtnMap.UNIT_PRICE, defaultPattern1) : '';
			$('FLOOR_VIEW_'+val).value= (rtnMap.OBJ_FLOOR ? CSRUtil.$fmt(rtnMap.OBJ_FLOOR, defaultPattern1) : '0') + '/' + (rtnMap.BLD_FLOOR ? CSRUtil.$fmt(rtnMap.BLD_FLOOR, defaultPattern1) : '0');
			$('BUILD_SPACE_VIEW_'+val).value=rtnMap.OBJ_AREA ? CSRUtil.$fmt(rtnMap.OBJ_AREA, defaultPattern1) : '';
			$('TOTAL_PRICE_VIEW_'+val).value=rtnMap.PRICE ? CSRUtil.$fmt(rtnMap.PRICE, defaultPattern1) : '';
			$('REF_TIME_VIEW_'+val).value=rtnMap.DEAL_DATE ? rtnMap.DEAL_DATE : '0';
			$('PARK_SPACE_VIEW_'+val).value=rtnMap.PAREA ? CSRUtil.$fmt(rtnMap.PAREA, defaultPattern1) : '';
		},
		
		//查詢捷運站下拉選單資料
		doGetStation : function(val){

			if(val=="METRO_VIEW"){
				//清除下拉選單
				$('STATION_VIEW').length = 1;
				if($('METRO_VIEW').value==''){
					$('BUILD_LINE_VIEW').value = '';
					$('BUILD_STATION_VIEW').value = '';
					return;
				}else{
					$('BUILD_LINE_VIEW').value = $('METRO_VIEW').options[$('METRO_VIEW').selectedIndex].text;
				}
			}else if(val=="METRO1_VIEW"){
				//清除下拉選單
				$('STATION1_VIEW').length = 1;
				if($('METRO1_VIEW').value==''){
					$('ROUND_LINE_VIEW').value = '';
					$('ROUND_STATION_VIEW').value = '';
					return;
				}else{
					$('ROUND_LINE_VIEW').value = $('METRO_VIEW').options[$('METRO1_VIEW').selectedIndex].text;
				}
			}
			
			//發送ajax
			ajaxPost( 'getStation' , {'L_SEQ' : $(val).value	}, true,
				function(resp){	
					var STATION_LIST = resp.STATION_LIST ? resp.STATION_LIST : [];
					appendList(STATION_LIST , val);
				},
				function(resp){					
					//失敗把前次內容清掉 
				}
			);		
		},
		
		//查詢平均(建議單價)
		doGetAvgPrice : function(total_price, avg_price){
			A040_LAND_SPACE = viewMap.A040_LAND_SPACE ? viewMap.A040_LAND_SPACE : 0;
			A050_BUILD_SPACE = viewMap.A050_BUILD_SPACE ? viewMap.A050_BUILD_SPACE : 0;
			//發送ajax
			ajaxPost( 'getAvgPrice' , {'TOTAL_PRICE' : total_price.value.replace(/,/gi,''), 'A040_LAND_SPACE' : A040_LAND_SPACE, 'A050_BUILD_SPACE' : A050_BUILD_SPACE}, true,
				function(resp){	
					var avgPrice = resp.avgPrice ? resp.avgPrice : 0;
					avg_price.value = CSRUtil.$fmt(avgPrice, defaultPattern1);
				},
				function(resp){					
					//失敗把前次內容清掉 
					avg_price.value = '0';
				}
			);		
		},
		//20210611 確認社區價格 
		doCfmComm : function(){<%--[20250213]改為確認社區/公寓價格--%>
			APPLY_ID = viewMap.APPLY_ID;
			ajaxPost('CfmComm',{ APPLY_ID : viewMap.APPLY_ID,  //畫面.受理編號
				COMMUNITY_NO : viewMap.COMMUNITY_NO, 
				APR_SUBMKT_ID : viewMap.APR_SUBMKT_ID, <%--20250213鑑價生活圈編號--%>
				APR_SUBMKT_VERSION : viewMap.APR_SUBMKT_VERSION <%--20250213鑑價生活圈版次--%>
				},true//畫面.社區編號
			);
			
		},
		//查詢聯徵鑑價記錄
		doQueryMAM003 : function(val){
		
			if ($('TIME_TEL_VIEW_'+val).value!='' && $('REF_SRC_VIEW_'+val).value=='F'){
			
				//發送ajax
				ajaxPost( 'queryMAM003' , {'TIME_TEL' : $('TIME_TEL_VIEW_' + val).value, 'APPLY_ID': $F('APPLY_ID') },true,
					function(resp){	
						var MAM003Map = resp.MAM003Map ? resp.MAM003Map : {};
						buttons.setGridE1MAM003Map(MAM003Map,val);
					},
					function(resp){					
						//失敗把前次內容清掉 
						var MAM003Map = resp.MAM003Map ? resp.MAM003Map : {};
						buttons.setGridE1MAM003Map(MAM003Map,val);
					}
				);
			}
					
		},
		
		//查詢扣分
		changeGetMinus : function(id1, id2){
			//發送ajax
			ajaxPost( 'getMinus' , {'QUALITY' : $(id1).value },true,
				function(resp){	
					var MINUS = resp.MINUS ? CSRUtil.$fmt(resp.MINUS, defaultPattern1) : '0';
					$(id2).innerHTML = MINUS;
					$('TOTAL_MINUS_VIEW').innerHTML = parseInt($('MINUS_VIEW').innerHTML) + parseInt($('MINUS1_VIEW').innerHTML) + parseInt($('MINUS2_VIEW').innerHTML) + parseInt($('MINUS3_VIEW').innerHTML);
				},
				function(resp){					
					//失敗把前次內容清掉 
					$(id2).innerHTML = '0';
					$('TOTAL_MINUS_VIEW').innerHTML = parseInt($('MINUS_VIEW').innerHTML) + parseInt($('MINUS1_VIEW').innerHTML) + parseInt($('MINUS2_VIEW').innerHTML) + parseInt($('MINUS3_VIEW').innerHTML);
				}
			);		
		},
	
		//查詢資料
		doQuery : function(event){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			$('CONTRACT_AREA_VIEW').className = '';
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}	

			//將畫面欄位存成record
			var sendRecord = makeRecord();	
			//將查詢條件存起來
			queryCondition = sendRecord;	
			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},true,
				querySuccessFunction,
				queryErrorFunction
				
			);
		},
		//重新查詢資料
		doReQuery : function(event){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			$('CONTRACT_AREA_VIEW').className = '';
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}	

			//將畫面欄位存成record
			var sendRecord = makeRecord();	
			//將查詢條件存起來
			queryCondition = sendRecord;	
			//發送ajax
			ajaxPost( 'reQuery' , {sendRecord : Object.toJSON(sendRecord)	},false,
				querySuccessFunction,
				queryErrorFunction
			);
		},
		
		//新增
		doInsert : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			
			//檢核2
			var msg = checkApplyIdValue2();
			if(''!=msg){
				alert(msg);
				return;
			}
			//檢核3
			settingValid2('insert');
			if(!valid2.validate()){ 
				return; 
			}
			
			//檢核4
			//[20201012]新增各擔保品附屬建物資料車位檢核
			valid4.clear();
			valid4.reset();
			$$('#gridL1 select').each(function(record){

				<%--[20250310]各擔保品附屬建物資料，若車位編號為車公，車位型態可不輸入。--%>
				var targetTypeId = record.id;
				var targetNoId = targetTypeId.replace('TYPE','NO');
				if($F(targetNoId) !== '車公'){
					valid4.define( "validatePARK" , { id: targetTypeId } );
				}
			});
			if(!valid4.validate()){ 
				return; 
			}

			//承作區選否:提示確認訊息
			/*if($('CONTRACT_AREA_VIEW').value=='1'){
				if (!confirm("請確認是否為非承作區?")) {
					return;
				}
			}*/

			inputMap = makeInputMap('insert');
			//將畫面欄位存成record
			var sendRecord = makeRecord();	
			//將查詢條件存起來
			queryCondition = sendRecord;
	
			//發送ajax
			ajaxPost( 'insert' , {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) },true,
				querySuccessFunction
			);
			
		},
		
		//修正
		doUpdate : function(paramMap){
			//msgWin.clearCallback();
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}

			//檢核2
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//檢核3
			settingValid2('update');
			if(!valid2.validate()){ 
				return; 
			}
			
			//檢核4
			//[20201012]新增各擔保品附屬建物資料車位檢核
			valid4.clear();
			valid4.reset();
			$$('#gridL1 select').each(function(record){

				<%--[20250310]各擔保品附屬建物資料，若車位編號為車公，車位型態可不輸入。--%>
				var targetTypeId = record.id;
				var targetNoId = targetTypeId.replace('TYPE','NO');
				if($F(targetNoId) !== '車公'){
					valid4.define( "validatePARK" , { id: targetTypeId } );
				}
			});
			if(!valid4.validate()){ 
				return; 
			}

			//承作區選否:提示確認訊息
			/*if($('CONTRACT_AREA_VIEW').value=='1'){
				if (!confirm("請確認是否為非承作區?")) {
					return;
				}
			}*/
			
			inputMap = makeInputMap('update');
			
			var paramMap = {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) };	
			
			//發送ajax
			ajaxPost( 'update' , paramMap,true, querySuccessFunction );

		},
		//刪除
		doDelete : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			//檢核2
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}

			if (confirm("確定要刪除" + $('APPLY_ID').value + "之鑑價報告書資料?")) {
				//發送ajax
				ajaxPost( 'delete' , {'APPLY_ID' : $('APPLY_ID').value },true,
					querySuccessFunction,
					queryErrorFunction
				);
			}
		},
		
		//呈核檢核
		doConfirmCheck : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			
			//檢核2
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//檢核3
			settingValid2('confirm');
			if(!valid2.validate()){ 
				return; 
			}
			
			//檢核4
			valid3.reset();
			if(!valid3.validate()){ 
				return; 
			}
			
			//檢核5
			//[20201012]新增各擔保品附屬建物資料車位檢核
			valid4.clear();
			valid4.reset();
			$$('#gridL1 select').each(function(record){

				<%--[20250310]各擔保品附屬建物資料，若車位編號為車公，車位型態可不輸入。--%>
				var targetTypeId = record.id;
				var targetNoId = targetTypeId.replace('TYPE','NO');
				if($F(targetNoId) !== '車公'){
					valid4.define( "validatePARK" , { id: targetTypeId } );
				}
			});
			if(!valid4.validate()){ 
				return; 
			}
			
			//[20210712]新增特殊擔保品選項檢核
			valid5.reset();
			if(!valid5.validate()) {
				return;
			}
			if ('18' == $F('SPC_GAGE_OPT_VIEW')) {
				if(!valid5.validate()) {
					return;
				}
			}

			//承作區選否:提示確認訊息
			if($('CONTRACT_AREA_VIEW').value=='1'){
				if (!confirm("請確認是否為非承作區?")) {
					return;
				}
			}
			
			inputMap = makeInputMap('confirm');
	
			var paramMap = {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) };	
			
			//發送ajax
			new Ajax.Request( 
				"<%=dispatcher%>/DSA3_0500/updateCheck",
				{ parameters: paramMap,
		          onSuccess: function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						if (resp.UpdateCheckMSG == 'OK'){
							buttons.doConfirm(paramMap);
						} else {
							var UpdateCheckMSG = resp.UpdateCheckMSG;
							if(UpdateCheckMSG){
								UpdateCheckMSG = UpdateCheckMSG.replace(/\\r|\\n|\\r\\n/g, "\n");
							}
							if(!confirm(UpdateCheckMSG)){
								return false;
							}
							buttons.doConfirm(paramMap);
						}				
					}
		        }}
			);
		},
		
		//呈核
		doConfirm : function(paramMap){
			msgWin.clearCallback();
			
			//發送ajax
			ajaxPost( 'confirm' , paramMap, true,querySuccessFunction	);

		},

		//取消呈核
		doCancel : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			//檢核2
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			if (confirm("確定要取消" + $('APPLY_ID').value + "之呈核?")) {
				inputMap = makeInputMap('cancel');
		
				//發送ajax
				ajaxPost( 'cancel' , {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) },true,
					querySuccessFunction
				);
			}
		},

		//組長覆核檢核
		doCaptainConfirmCheck : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			$$('#gridN1 input').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				record.className = '';
				if('CAPT_EACH_PRICE'==id){
					record.className = 'required validate-positive-number';
				}
			});
			
			
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			//檢核2
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//檢核3
			settingValid2('captainConfirm');
			if(!valid2.validate()){ 
				return; 
			}
			
			//檢核4
			//[20201012]新增各擔保品附屬建物資料車位檢核
			valid4.clear();
			valid4.reset();
			$$('#gridL1 select').each(function(record){

				<%--[20250310]各擔保品附屬建物資料，若車位編號為車公，車位型態可不輸入。--%>
				var targetTypeId = record.id;
				var targetNoId = targetTypeId.replace('TYPE','NO');
				if($F(targetNoId) !== '車公'){
					valid4.define( "validatePARK" , { id: targetTypeId } );
				}
			});
			if(!valid4.validate()){ 
				return; 
			}
			
			inputMap = makeInputMap('captainConfirm');

			var paramMap = {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) };	
			
			//發送ajax
			new Ajax.Request( 
				"<%=dispatcher%>/DSA3_0500/captainConfirmCheck",
				{ parameters: paramMap,
		          onSuccess: function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						if (resp.CaptainConfirmMSG == 'OK'){
							buttons.doCaptainConfirm(paramMap);
						} else {
							var CaptainConfirmMSG = resp.CaptainConfirmMSG;
							if(CaptainConfirmMSG){
								CaptainConfirmMSG = CaptainConfirmMSG.replace(/\\r|\\n|\\r\\n/g, "\n");
							}
							if(!confirm(CaptainConfirmMSG)){
								return false;
							}
							buttons.doCaptainConfirm(paramMap);
						}				
					}
		        }}
			);
		},
		
		//組長覆核
		doCaptainConfirm : function(paramMap){
			msgWin.clearCallback();
			
			//發送ajax
			ajaxPost( 'captainConfirm' , paramMap, true,querySuccessFunction	);

		},
		
		//組長退回
		doCaptainReject : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			//檢核2
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			if (confirm("確定要退回" + $('APPLY_ID').value + "之鑑價報告書?")) {
				inputMap = makeInputMap('captainReject');
		
				//發送ajax
				ajaxPost( 'captainReject' , {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) },true,
					querySuccessFunction
				);
			}
		},
		
		//科主管(代理)覆核
		doBossConfirmCheck : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			$$('#gridN1 input').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				record.className = '';
				if('BOSS_EACH_PRICE'==id){
					record.className = 'required validate-positive-number';
				}
			});
			
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			//檢核2
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//檢核3
			settingValid2('bossConfirm');
			if(!valid2.validate()){ 
				return; 
			}
			
			//檢核4
			//[20201012]新增各擔保品附屬建物資料車位檢核
			valid4.clear();
			valid4.reset();
			$$('#gridL1 select').each(function(record){

				<%--[20250310]各擔保品附屬建物資料，若車位編號為車公，車位型態可不輸入。--%>
				var targetTypeId = record.id;
				var targetNoId = targetTypeId.replace('TYPE','NO');
				if($F(targetNoId) !== '車公'){
					valid4.define( "validatePARK" , { id: targetTypeId } );
				}
			});
			if(!valid4.validate()){ 
				return; 
			}
			
			inputMap = makeInputMap('bossConfirm');
			
			var paramMap = {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) };	
			
			//發送ajax
			new Ajax.Request( 
				"<%=dispatcher%>/DSA3_0500/bossConfirmCheck",
				{ parameters: paramMap,
		          onSuccess: function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						if (resp.BossConfirmMSG == 'OK'){
							buttons.doBossConfirm(paramMap);
						} else {
							var BossConfirmMSG = resp.BossConfirmMSG;
							if(BossConfirmMSG){
								BossConfirmMSG = BossConfirmMSG.replace(/\\r|\\n|\\r\\n/g, "\n");
							}
							if(!confirm(BossConfirmMSG)){
								return false;
							}
							buttons.doBossConfirm(paramMap);
						}				
					}
		        }}
			);
		},
		
		//科主管(代理)覆核
		doBossConfirm : function(paramMap){
			msgWin.clearCallback();
			
			//發送ajax
			ajaxPost( 'bossConfirm' , paramMap, true,querySuccessFunction	);

		},
		
		//部室主管覆核
		doGmConfirm : function(){
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			//檢核2
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//檢核2
			settingValid2('gmConfirm');
			if(!valid2.validate()){ 
				return; 
			}
			
			//檢核3
			//[20201012]新增各擔保品附屬建物資料車位檢核
			valid4.clear();
			valid4.reset();
			$$('#gridL1 select').each(function(record){

				<%--[20250310]各擔保品附屬建物資料，若車位編號為車公，車位型態可不輸入。--%>
				var targetTypeId = record.id;
				var targetNoId = targetTypeId.replace('TYPE','NO');
				if($F(targetNoId) !== '車公'){
					valid4.define( "validatePARK" , { id: targetTypeId } );
				}
			});
			if(!valid4.validate()){ 
				return; 
			}
			
			inputMap = makeInputMap('gmConfirm');
			
			var paramMap = {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) };	
			
			//發送ajax
			ajaxPost( 'gmConfirm' , paramMap, true,querySuccessFunction	);

		},
		
		//主管退回
		doBossReject : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			//檢核2
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			if (confirm("確定要退回" + $('APPLY_ID').value + "之鑑價報告書?")) {
				inputMap = makeInputMap('bossReject');
		
				//發送ajax
				ajaxPost( 'bossReject' , {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) },true,
					querySuccessFunction
				);
			}
		},
		
		//取消覆核
		doCancelConfirm : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			//檢核1
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			//檢核2
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			if (confirm("確定要取消" + $('APPLY_ID').value + "之鑑價報告書覆核?")) {
				inputMap = makeInputMap('cancelConfirm');
		
				//發送ajax
				ajaxPost( 'cancelConfirm' , {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) },true,
					querySuccessFunction
				);
			}
		},
		
		//影像確認
		doImageConfirm : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}

			//發送ajax
			ajaxPost( 'imageConfirm' , {'sendRecord' : Object.toJSON(queryCondition), 
										'APPLY_ID' : $('APPLY_ID').value, 
										'NOPIC_REASON' : $('NOPIC_REASON_VIEW').value, 
										'PHOTO_ID' : $('PHOTO_ID_VIEW').value,
										'MAP_AREA_CODE' : $('MAP_AREA_CODE').value,
										'AREA_CODE_930318' : $F('AREA_CODE_930318')
										}, true,
				querySuccessFunction
			);
		},
		
		//取得相簿資訊
		/*
	
		doGetPicAlbum : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//發送ajax
			ajaxPost( 'getPicAlbum' , {'APPLY_ID' : $('APPLY_ID').value }, true,
				function(resp){	
					$("PHOTO_NM_VIEW").innerHTML = resp.PHOTO_NM ? resp.PHOTO_NM : '';
					$("PHOTO_ID_VIEW").value = resp.PHOTO_ID ? resp.PHOTO_ID : '';
					$("APPEARANCE_PIC_DATE_VIEW").value = resp.APPEARANCE_PIC_DATE ? Date.toInputROC(resp.APPEARANCE_PIC_DATE,'') : '';
					$("FOLLOW_NUMBER_VIEW").value = '';
				},
				function(resp){					
					//失敗保留畫面資料
				}
			);
		},
		*/
		//20210811 取得鑑價科別
		doGetApprDept : function(){
			//發送ajax
			ajaxPost( 'getApprDept' , {'APPR_GROUP' :viewMap.APPR_GROUP }, true,
				function(resp){	
				$('APPR_DEPT').value = resp.APPR_DEPT;
				buttons.doGearing();
				$('SUPPORT_ID_VIEW').value = viewMap.APPR_ID;
				changeSUPPORT_ID_VIEW();
				},
				function(resp){					
					//失敗保留畫面資料
				}
			);
			
		},
		
		// 取得舊照連動 20210811
		doGetAPPEARANCE_PIC_REASON_VIEW_02 : function(){
			//發送ajax
			ajaxPost( 'getAPPEARANCE_PIC_REASON_VIEW_02' , {'APPLY_ID' :viewMap.APPLY_ID,'PIC_APPLY_ID': viewMap.PIC_APPLY_ID }, true,
				function(resp){	
				$('APPR_DEPT').value = $('APPR_DEPT').options[0].value;//初始的鑑價科下拉選單
				buttons.doGearing(); //鑑價科連動鑑價人員
				$('SUPPORT_ID_VIEW').value =  $('SUPPORT_ID_VIEW').options[0].value;
				changeSUPPORT_ID_VIEW();// 鑑價人員連動
				//APPEARANCE_PIC_DATE
				//FOLLOW
				$('FOLLOW_NUMBER_VIEW').value = resp.FOLLOW_NUMBER||"";//沿用編號
				$('APPEARANCE_PIC_DATE_VIEW').value = resp.APPEARANCE_PIC_DATE? Date.toInputROC(resp.APPEARANCE_PIC_DATE,''):""; //外觀照日期
				},
				function(resp){					
					//失敗保留畫面資料
				}
			);
			
		},
		
		
		//引用相簿
		doCopyPicAlbum : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//發送ajax
			ajaxPost( 'copyPicAlbum' , {'APPLY_ID' : $('APPLY_ID').value, 'FOLLOW_NUMBER' : $('FOLLOW_NUMBER_VIEW').value }, true,
				function(resp){	
					$("PHOTO_NM_VIEW").innerHTML = resp.PHOTO_NM ? resp.PHOTO_NM : '';
					$("PHOTO_ID_VIEW").value = resp.PHOTO_ID ? resp.PHOTO_ID : '';
					$("APPEARANCE_PIC_DATE_VIEW").value = resp.APPEARANCE_PIC_DATE ? Date.toInputROC(resp.APPEARANCE_PIC_DATE,'') : '';
					$('APPEARANCE_PIC_REASON_VIEW').value=resp.APPEARANCE_PIC_REASON ? resp.APPEARANCE_PIC_REASON : '';
				},
				function(resp){					
					//失敗保留畫面資料
				}
			);
		},
		
		//(1)電子地圖
		doElectronicMap : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			
			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//E區甲乙丙丁地址
			var ADDRESSList = [];
			$$('#gridE1 input').each(function(record){
				var id = record.id.substring(0,record.id.indexOf('_VIEW_'));
				var index = record.id.substring(record.id.indexOf('_VIEW_')+6);
				if(id.indexOf('ADDRESS')>=0){
					ADDRESSList[index-1] = record.value;
				}
			});			
			var XML = {};
			XML.APPLY_ID = $F('APPLY_ID');
			XML.GAGE_ADDR = $('GAGE_ADDR_VIEW').innerHTML;
			//XML.ADDRESS1 = ADDRESSList[0];//E區甲地址,若無資料則為’’
			//XML.ADDRESS2 = ADDRESSList[1];//E區乙地址,若無資料則為’’
			//XML.ADDRESS3 = ADDRESSList[2];//E區丙地址,若無資料則為’’
			//XML.ADDRESS4 = ADDRESSList[3];//E區丁地址,若無資料則為’’
			XML.USE_FOR = $F('USE_FOR_VIEW');
			XML.TOTAL_FLOOR = $F('TOTAL_FLOOR');
			XML.TARGET_FLOOR = $F('TARGET_FLOOR');
			XML.LAND_MEASURE = $F('LAND_MEASURE');
			XML.BUILD_MEASURE = $F('BUILD_MEASURE');
			XML.BUILD_AGE = $F('BUILD_AGE');
			
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
		
		//(2)環域分析
		getA213List : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}

			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//發送ajax
			ajaxPost( 'getA213List' , {'APPLY_ID' : $('APPLY_ID').value },true,
				function(resp){	
					//D區A213List
					buttons.setTable_D1(resp);
					
					var xyMap = resp.xyMap ? resp.xyMap : {};
					if(xyMap){
						$('LONGITUDE').value=xyMap.LONGITUDE ? xyMap.LONGITUDE : '';
						$('LATITUDE').value=xyMap.LATITUDE ? xyMap.LATITUDE : '';
						//$('CONTROL_AREA_VIEW').value=xyMap.CONTROL_AREA ? xyMap.CONTROL_AREA : '';
					}
					
					/*var roadMap = resp.roadMap ? resp.roadMap : {};
					if(roadMap){
						//20160504 李怡寬-鑑價企劃科:取消環域分析後頁面路寬欄位設值
						//$('ROAD_WIDTH_VIEW').value = roadMap.ROAD_WIDTH ? CSRUtil.$fmt(roadMap.ROAD_WIDTH, defaultPattern1) : '0';
						//20160810 范貴華-鑑價企劃科:取消環域分析後頁面交通欄位設值
						//$('ROAD_WIDTH2_VIEW').value = roadMap.ROAD_WIDTH2 ? CSRUtil.$fmt(roadMap.ROAD_WIDTH2, defaultPattern1) : '0';
						//$('ROAD_NAME_VIEW').value = roadMap.ROAD_NAME2 ? roadMap.ROAD_NAME2 : '';
						//$('NEAR_DISTANCE_VIEW').value = roadMap.NEAR_DISTANCE ? CSRUtil.$fmt(roadMap.NEAR_DISTANCE, defaultPattern1) : '0';
					}*/
										
					//20191231 電子地圖改版					
					/*var distanceMap = resp.distanceMap ? resp.distanceMap : {};
					if(distanceMap){
						$('DISTANCE_VIEW_1').value = distanceMap.DISTANCE_A ? CSRUtil.$fmt(distanceMap.DISTANCE_A, defaultPattern1) : '0';
						$('DISTANCE_VIEW_2').value = distanceMap.DISTANCE_B ? CSRUtil.$fmt(distanceMap.DISTANCE_B, defaultPattern1) : '0';
						$('DISTANCE_VIEW_3').value = distanceMap.DISTANCE_C ? CSRUtil.$fmt(distanceMap.DISTANCE_C, defaultPattern1) : '0';
						$('DISTANCE_VIEW_4').value = distanceMap.DISTANCE_D ? CSRUtil.$fmt(distanceMap.DISTANCE_D, defaultPattern1) : '0';
					}*/
				},
				function(resp){					
					//失敗把前次內容清掉 
					//D區A213List
					buttons.setTable_D1(resp);
				}
			);		
		},
		
		//(4)訪價匯入
		getA201List : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}

			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//發送ajax
			ajaxPost( 'getA201List' , {'APPLY_ID' : $('APPLY_ID').value },true,
				function(resp){	
					//E區A201List
					buttons.setRefGridE1(resp);
					//訪價匯入自動組成文字
					if(resp.RefDesc){
						if($('LOC_DESC_VIEW').value == ''){
							if (confirm("綜合分析是否帶入訪價匯入文字說明?")) {
								$('LOC_DESC_VIEW').value = resp.RefDesc;
							}
						}
					}
				},
				function(resp){					
					//失敗保留畫面資料
				}
			);		
		},
		
		//(3)案例建議
		getA216List : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}

			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			inputMap = viewMap;
			inputMap.USE_FOR = $('USE_FOR_VIEW').value;
			inputMap.PER_PRICE = $('PER_PRICE_VIEW').value;
			inputMap.PARK_SPACE = $('PARK_SPACE_VIEW').value ? $('PARK_SPACE_VIEW').value.replace(/,/gi,'') : '0';
			inputMap.LONGITUDE = $('LONGITUDE').value ? $('LONGITUDE').value : '';
			inputMap.LATITUDE = $('LATITUDE').value ? $('LATITUDE').value : '';
			inputMap.INPUT_DATE = $F('INPUT_DATE') ? $F('INPUT_DATE'): '';
			inputMap.IS_SIMPLE = '0'; //一般鑑價報告
			
			//發送ajax
			ajaxPost( 'getA216List', {'inputMap' : Object.toJSON(inputMap) } , true,
				function(resp){	
					//gridH1
					var A216List = resp.A216List ? resp.A216List : [];
					gridH1.load(A216List, null, null, ["1"]);
					//gridM2
					var A215ListS = resp.A215ListS ? resp.A215ListS : [];
					gridM2.load(A215ListS);
				},
				function(resp){					
					//失敗保留畫面資料
				}
			);		
		},
		
		//(5)自動估價
		getA215List : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}

			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			
			/*
			var records = gridM2.getAllRecords();
			if(records.length==0){
				alert("尚未執行案例建議!!");
				return;
			}
			*/
			
			//[20201130]取買賣契約影像是/否完整
			var radios = document.getElementsByName('WELL_CONTRACT');
			var WELL_CONTRACT;
			for (var i = 0, length = radios.length; i < length; i++) {
			  if (radios[i].checked) {
				WELL_CONTRACT = radios[i].value;
				break;
			  }
			}

			inputMap = viewMap;
			var inParkNum = $('PARK_NUM_VIEW_1').value;
			var inParkAmt = $('PARK_AMT_VIEW_1').value ? $('PARK_AMT_VIEW_1').value.replace(/,/gi,'') : '0';
			if(inputMap.PARK_NUM != inParkNum || inputMap.PARK_AMT != inParkAmt) {
				alert('車位數量與總價異動尚未儲存，請先修正資料再執行估價!');				
				return;
			}			
			inputMap.USE_FOR = $('USE_FOR_VIEW').value;
			inputMap.PER_PRICE = $('PER_PRICE_VIEW').value;
			inputMap.PARK_SPACE = $('PARK_SPACE_VIEW').value ? $('PARK_SPACE_VIEW').value.replace(/,/gi,'') : '0';
			inputMap.LONGITUDE = $('LONGITUDE').value ? $('LONGITUDE').value : '';
			inputMap.LATITUDE = $('LATITUDE').value ? $('LATITUDE').value : '';
			inputMap.INPUT_DATE = $F('INPUT_DATE') ? $F('INPUT_DATE'): '';
			inputMap.IS_SIMPLE = '0'; //一般鑑價報告
			inputMap.TRADE_AMT = $F('TRADE_AMT_VIEW') ? $F('TRADE_AMT_VIEW'): '';
			inputMap.WELL_CONTRACT = WELL_CONTRACT ? WELL_CONTRACT: '';
			
			<%--[20240613]車位檢核--%>			
			if(!chkPSM()){
				return;
			}

			//發送ajax
			ajaxPost( 'getA215List', {'inputMap' : Object.toJSON(inputMap) } , true,
				function(resp){	
					//gridM1
					var A215ListA = resp.A215ListA ? resp.A215ListA : [];
					gridM1.load(A215ListA);
					//gridM2
					var A215ListS = resp.A215ListS ? resp.A215ListS : [];
					gridM2.load(A215ListS);
					<%--[20240613]車位估價紀錄 --%>
					var A215ListP = resp.A215ListP ? resp.A215ListP : [];
					gridMP.load(A215ListP);
				},
				function(resp){					
					//失敗保留畫面資料
				}
			);		
		},
		///社區價格  20210610 
		getA350List: function(){<%--[20250211]匯入社區價格調整為匯入社區/公寓價格--%>
			ajaxPost('getA350List',{ APPLY_ID : viewMap.APPLY_ID,  //畫面.受理編號
				COMMUNITY_NO : viewMap.COMMUNITY_NO,//畫面.社區編號
				PER_PRICE : $('PER_PRICE_VIEW').value},true,
			function(resp){
				//gridM3
				var A215ListC = resp.A215ListC ? resp.A215ListC : [];
				gridM3.load(A215ListC);
				<%--[20250211]公寓估價紀錄 --%>
				var A215ListM = resp.A215ListM ? resp.A215ListM : [];
				gridMM.load(A215ListM);
			},function(resp){
				//失敗保留畫面資料
			});

		},
		//報告重送
		doReSend : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}

			var msg = checkApplyIdValue();
			if(''!=msg){
				alert(msg);
				return;
			}
			
			//發送ajax
			ajaxPost( 'reSend' , {'APPLY_ID' : $('APPLY_ID').value, 
				'MAP_AREA_CODE' : $('MAP_AREA_CODE').value,
				'AREA_CODE_930318' : $F('AREA_CODE_930318')
				},true );
		},
		
		//列印
		doPrint : function(event){
		<c:choose>
			<c:when test="${fromPublicBean eq 'DSA3_2400'}">var action = "DSA3_2400/print";</c:when>
			<c:otherwise>var action = "DSA3_0500/print";</c:otherwise>
		</c:choose>
			new Ajax.Request( "<%=dispatcher%>/"+action, {
				parameters: { APPLY_ID : $F('encryptAPPLY_ID'), ActionType : '${ActionType}', OP : '${OP}'},
				onSuccess:function(response){
					var resp = response.responseJSON;
					if(CSRUtil.isSuccess(resp)){
						RPTUtil.executePrintByResponse(resp, true);
					}
				}
			});
		},

		//鑑價影像檔               
		doGetFile : function(){
		
			if(!viewMap || viewMap.APPLY_ID!=$('APPLY_ID').value){
				if(!viewMap || !viewMap.APPLY_ID){
					alert("需查詢成功後才可作業");
				}else{
					alert("欲作業的受理編號{"+$('APPLY_ID').value+"}與原先查詢的受理編號{"+viewMap.APPLY_ID+"}不同,無法作業!");
				}
				return;
			}
		
			var params = {};
			
			params.APPLY_ID = viewMap.APPLY_ID;
			params.APPR_GROUP = viewMap.APPR_GROUP;	
			params.APPR_DEPT = viewMap.APPR_DEPT;	

			var successActionOpen = function(resp){
				if(resp.isExternal && resp.isApprExternalAuth) { //高級主管由外網登入開啟影像
					RPTUtil.download({'downloadFileName': resp.apprFileNM,	'downloadFileFullPath': resp.apprPath});
				} else {
					window.open(resp.apprPath);
				}
			};
			
			
			ajaxPost('getFile',params,true,successActionOpen,null);
		},
		
		// 超連結 "土地、建物謄本影像"
		doLinkImage: function(APPLY_ID) {
			var APPLY_ID = $('APPLY_ID').value.toUpperCase();
			if( APPLY_ID.length < 11 ){
				alert("請輸入正確的受理編號");
				return;
			}
			if( APPLY_ID.indexOf('@') != -1) {
				alert("銀行件請改至鑑價資料查詢作業進行影像查詢");
				return;
			}
			//產生超連結
			popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
				'windowName': 'DSA0_0200',
				'parameters': {'APPLY_ID': APPLY_ID},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'}
			});
		},
		
		//擔保品行情查詢               
		doLinkToDSA3_0900 : function(){
			
			if(!viewMap || viewMap.APPLY_ID!=$('APPLY_ID').value){
				if(!viewMap || !viewMap.APPLY_ID){
					alert("需查詢成功後才可作業");
				}else{
					alert("欲作業的受理編號{"+$('APPLY_ID').value+"}與原先查詢的受理編號{"+viewMap.APPLY_ID+"}不同,無法作業!");
				}
				return;
			}
			
			popupWin.windowOpen('<%=dispatcher%>/DSA3_0900/prompt',{
				'parameters': {'APPLY_ID': viewMap.APPLY_ID},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'}
			});
		},
		
		//新增社區資料檢核
		doCommunityInsert : function(){
			
			if(!viewMap || viewMap.APPLY_ID!=$('APPLY_ID').value){
				if(!viewMap || !viewMap.APPLY_ID){
					alert("需查詢成功後才可作業");
				}else{
					alert("欲作業的受理編號{"+$('APPLY_ID').value+"}與原先查詢的受理編號{"+viewMap.APPLY_ID+"}不同,無法作業!");
				}
				return;
			}
			valid6.reset();
			if(!valid6.validate()){ 
				return; 
			}
			var isConfirm = 'N'
			ajaxPost('communityInsert', {'APPLY_ID': $F('APPLY_ID')} , true,
				function(resp){	
					if(resp.CFM_MSG){
						if(confirm(resp.CFM_MSG)){
							isConfirm = 'Y';
						}
					}else{
						isConfirm = 'Y';
					}
					if(isConfirm == 'Y'){
						ajaxPost('communityInsert', {'APPLY_ID': $F('APPLY_ID'), isConfirm: isConfirm} , true,
							function(resp){	
								var mapA349 = resp.mapA349;
								var paramMap = {
									LINK_FROM: 'DSA30500',
									LINK_TYPE: 'IN',
									COMMUNITY_NO: mapA349.COMMUNITY_NO,
									UPDATE_TIME: mapA349.UPDATE_TIME
								};
								popupWin.popup({
									src : '${dispatcher}/DSA3_3390/prompt'
									,scrolling : 'yes'
									,parameters : paramMap
									,width : "100%"
									,height : "100%"
									,left : "0"
									,top : "0"
									,onclose: function(){
										$('btn_query').simulate('click');
									}
								}); 
							}
						);
					}
				}
			);
		},
		
		//新增社區資料               
		doLinkToDSA3_3301 : function(){
			
			popupWin.windowOpen('<%=dispatcher%>/DSA3_3301/prompt',{
				'parameters': {'APPLY_ID': viewMap.APPLY_ID},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'}
			});
		},
		// 鑑價科 連動 鑑價人員 
		doGearing: function() {
			var SUPPORT_ID_VIEW = $('SUPPORT_ID_VIEW');
			SUPPORT_ID_VIEW.update(SUPPORT_ID_VIEW.firstDescendant('option'));
	
			
			var EMPList = SUPPORT_NAME[$F('APPR_DEPT')];
			if(EMPList) {
				for(var i =0; i<EMPList.length;i++ ) {
					var node  = new Element('option',
						{ value: EMPList[i].ID }
					).update(EMPList[i].NAME);
					
					SUPPORT_ID_VIEW.appendChild(node);

				}
				//智能件選項
				var node  = new Element('option',
						{ value: "DSA3_B200" }
					).update("智能件");
				SUPPORT_ID_VIEW.appendChild(node);
			}
			SUPPORT_ID_VIEW.value = '';
		},
		
		doCalculatePrice:function(btnName){
			var nameSet=btnName.split("_");
			var ser=nameSet[nameSet.length-2];
			//先清空
			$('LAND_PRICE_VIEW_'+ser).value = '';
			$('PER_PRICE_VIEW_'+ser).value = '';
			if(nameSet[0]=="LAND"){
				var reqMap={
					TOTAL_PRICE:$('TOTAL_PRICE_VIEW_'+ser).value.replace(/,/gi,''),
					//BUILD_PRICE:$('BUILD_PRICE_VIEW_'+ser).value.replace(/,/gi,''),
					//BUILD_SPACE:$('BUILD_SPACE_VIEW_'+ser).value.replace(/,/gi,''),
					LAND_SPACE:$('LAND_SPACE_VIEW_'+ser).value.replace(/,/gi,'')
				};
				for(key in reqMap){
					if(reqMap[key]===0||reqMap[key]=="0"||!reqMap[key]){
						alert("總價、地坪必須>0");
						return;
					}
				}
				reqMap.BUILD_PRICE = $('BUILD_PRICE_VIEW_'+ser).value.replace(/,/gi,'');
				reqMap.BUILD_SPACE = $('BUILD_SPACE_VIEW_'+ser).value.replace(/,/gi,''),
				//發送ajax
				ajaxPost('CalculatePriceLand',{reqMap:Object.toJSON(reqMap)},true,
					function(resp){
						var rtnPrice=resp.rtnPrice;
						$('LAND_PRICE_VIEW_'+ser).setValue((rtnPrice===0||rtnPrice)?rtnPrice:'');
					}
				);
			}else{
				var reqMap={
					TOTAL_PRICE:$('TOTAL_PRICE_VIEW_'+ser).value.replace(/,/gi,''),
					BUILD_SPACE:$('BUILD_SPACE_VIEW_'+ser).value.replace(/,/gi,'')
				};
				for(key in reqMap){
					if(reqMap[key]===0||reqMap[key]=="0"||!reqMap[key]){
						alert("總價、建坪必須>0");
						return;
					}
				}
				ajaxPost('CalculatePricePer',{reqMap:Object.toJSON(reqMap)},true,
					function(resp){	
						var rtnPrice=resp.rtnPrice;
						$('PER_PRICE_VIEW_'+ser).setValue((rtnPrice===0||rtnPrice)?rtnPrice:'');
					}
				);
			}
		},
		
		//建議清單
		suggestALL : function(){			
			<%--社區名稱搜尋，加入suggestion裡面--%>
			Suggest.add( 
				'CASE_NAME_VIEW', 			  
		        Suggest.URL,
				'${dispatcher}/DSA3_0500/suggestCaseName',
				{						
		            ignoreCase:true,
		            startLength:2,
		            option_key:"CASE_NAME",
		            remark_key:"COMMUNITY_NO",	
		            noCookies:true,
					"callBackFunc" : function(node,rec){}
				}
			);
		},
		<%--[20201127]新增都市計劃案下拉選單--%>
		selectUrban : function(URBAN_PROJECT_LIST, URBAN_PROJECT){
			$('URBAN_PROJECT').options.length = 0;
			if(URBAN_PROJECT_LIST.length>0){
				isURBAN_PROJECT = true;
				$('URBAN_PROJECT').enable();
				$('URBAN_PROJECT').add(new Option('請選擇都市計畫案', ''));
				URBAN_PROJECT_LIST.each(function(map){
					$('URBAN_PROJECT').add(new Option(map.URBAN_PROJECT_NM, map.POST_CODE +'_'+ map.SER_NO));
				});		
				$('URBAN_PROJECT').setValue(URBAN_PROJECT);
			}else{
				isURBAN_PROJECT = false;
				$('URBAN_PROJECT').add(new Option('無', ''));
				$('URBAN_PROJECT').disable();
			}
		},
		setSelectOption : function(){
			var use_for = $F('USE_FOR_VIEW');
			$('GRADING_ITEM_VIEW').length = 0;
			$('GRADING_ITEM_VIEW').insert('<option value="0"></option>');
			$('GRADING_ITEM_VIEW').insert('<option value="1">A</option>');
			$('GRADING_ITEM_VIEW').insert('<option value="2">B</option>');
			$('GRADING_ITEM_VIEW').insert('<option value="3">C</option>');
				
			if (use_for=='I' || use_for=='J'){
				$('GRADING_ITEM_VIEW').options.item(3).remove();
			}else if (use_for=='M'){
				$('GRADING_ITEM_VIEW').selectedIndex = 0;
			}else{
				$('GRADING_ITEM_VIEW').length=1;
			}
		},
		doLinkTo3700: function(){<%--[20250213]公寓資料庫--%>
		<%--[20250424] 問題單: 公寓資料庫調整同(同社區編號方式，開啟新視窗，不要用100%遮蔽) --%>
			var paramMap = {
				LINK_FROM: 'DSA30500',
				LINK_TYPE: 'IN',
				SUBMKT_ID: viewMap.APR_SUBMKT_ID,
				SUBMKT_NAME: viewMap.APR_SUBMKT_NAME,
				VERSION: viewMap.APR_SUBMKT_VERSION,
				CITY: viewMap.CITY_NAME,
				TOWN: viewMap.TOWN_NAME, 
			};
			popupWin.windowOpen('${dispatcher}/DSA3_3700/prompt',
				{
				'parameters': paramMap,
				'fullScreen': false,
				'attributes': {'resizable': 'yes'}
				});
		}
	}
	
	//檢核
	function checkApplyIdValue(){
		
		if(!viewMap || viewMap.APPLY_ID!=$('APPLY_ID').value){
			if(!viewMap || !viewMap.APPLY_ID){
				return "需查詢成功後才可作業";
			}else{
				return "欲作業的受理編號{"+$('APPLY_ID').value+"}與原先查詢的受理編號{"+viewMap.APPLY_ID+"}不同,無法作業!";
			}
		}else{
			return "";
		}
	}
	//檢核
	function checkApplyIdValue2(){
		
		if(!viewMap || viewMap.APPLY_ID!=$('APPLY_ID').value){
			if(!viewMap || !viewMap.APPLY_ID){
				return "需查詢成功後才可作業";
			}
		}
		return "";
	}
	
	//將畫面資料存成要派件或轉移的List
	function makeEditRecord(list){
		var editList = [];
		for(var i = 0 ; i < list.length ; i++){
			var tempMap = {};
			tempMap["APPLY_ID"] = list[i]["APPLY_ID"];           //受理編號
			tempMap["APPR_ID"] = $("APPR_ID").value;             //鑑價人員
			tempMap["SUPPORT_ID"] = $("SUPPORT_ID").value  ;     //支援人員
			editList.push(tempMap);
		}
		return editList;
	}
	
	//將畫面A資料存成Record
	function makeRecord(){
		var sendRecord = {
			APPLY_ID	: $('APPLY_ID').value.toUpperCase() //受理編號			
		}
		return sendRecord;	
	}
	
	//將畫面A資料存成Record
	function makeInputMap(action){
		var inputMap = {};
		var rtnMap = viewMap;

		//移除LIGHT值避免產生非安全值輸入問題 
		//rtnMap.LIGHT = ''; //改由A214List取得
		
		rtnMap.IS_SIMPLE = '0'; //一般鑑價報告
		//B區
		rtnMap.BUILD_TYPE = $('BUILD_TYPE_VIEW').value;
		rtnMap.TARGET_FLOOR=$('TARGET_FLOOR').value;
		rtnMap.USE_FOR = $('USE_FOR_VIEW').value;
		<%--[20230201] 新增 分級項下拉選項--%> 
		rtnMap.GRADING_ITEM = $('GRADING_ITEM_VIEW').value;
		rtnMap.BASEMENT_FLOOR = $('BASEMENT_FLOOR_VIEW').value;
		rtnMap.CONTRACT_AREA = $('CONTRACT_AREA_VIEW').value;
		rtnMap.USE_AREA1 = $('USE_AREA1_VIEW').value;
		rtnMap.USE_AREA2 = $('USE_AREA2_VIEW').value;
		rtnMap.BORROW_ID = $('BORROW_ID').value;
		rtnMap.LONGITUDE = $('LONGITUDE').value;
		rtnMap.LATITUDE = $('LATITUDE').value;
		rtnMap.PIC_CASE_NAME = $('PIC_CASE_NAME').value;
		rtnMap.MAP_AREA_CODE = $('MAP_AREA_CODE').value;
		<%--[20201127] 調整承作分區判斷邏輯新增承作分區、擔保品郵遞區號欄位--%> 
		rtnMap.AREA_CODE_930318 = $F('AREA_CODE_930318');
		rtnMap.URBAN_PROJECT = $F('URBAN_PROJECT');
		<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%> 
		rtnMap.SUBMKT_ID = $F('SUBMKT_ID');
		rtnMap.SUBMKT_NAME = $F('SUBMKT_NAME');
		rtnMap.SUBMKT_VERSION = $F('SUBMKT_VERSION');
		rtnMap.AREA_CODE_MATCH_LEVEL = $F('AREA_CODE_MATCH_LEVEL');
		
		//C區
		rtnMap.RESTRICT_AREA = $('RESTRICT_AREA_VIEW').value;
		rtnMap.TRADE_AMT = $('TRADE_AMT_VIEW').value.replace(/,/gi,'');
		rtnMap.TRADE_DATE = toY2K($('TRADE_DATE_VIEW').value);
		//rtnMap.CONTROL_AREA = $('CONTROL_AREA_VIEW').value;
		rtnMap.CASE_NAME = $('CASE_NAME_VIEW').value;
		rtnMap.COMMUNITY_NO = $('COMMUNITY_NO_VIEW').value;
		rtnMap.HOUSE_NO = $('HOUSE_NO_VIEW').value ? $('HOUSE_NO_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.SALE_RATE = $('SALE_RATE_VIEW').value ? $('SALE_RATE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.REST_RATE = $('REST_RATE_VIEW').value ? $('REST_RATE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.OPEN_RATE = $('OPEN_RATE_VIEW').value ? $('OPEN_RATE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.SPC_CONDITION = $('SPC_CONDITION_VIEW').checked ? 1 : 0;
		rtnMap.ROAD_WIDTH = $('ROAD_WIDTH_VIEW').value ? $('ROAD_WIDTH_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.NEAR_DEPTH = $('NEAR_DEPTH_VIEW').value ? $('NEAR_DEPTH_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.LAND_WIDTH = $('LAND_WIDTH_VIEW').value ? $('LAND_WIDTH_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BUILD_WIDTH = $('BUILD_WIDTH_VIEW').value ? $('BUILD_WIDTH_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.USE_STATUS = $('USE_STATUS_VIEW').value;
		rtnMap.RENT_PRICE = $('RENT_PRICE_VIEW').value ? $('RENT_PRICE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.INVESTIGATE_STATUS = $('INVESTIGATE_STATUS_VIEW').value;
		rtnMap.ASPECT = $('ASPECT_VIEW').value;
		rtnMap.SITE = $('SITE_VIEW').value;
		rtnMap.BUILD_ADD = $('A200_BUILD_ADD_VIEW').value;
		rtnMap.TOTAL_SPACE = $('TOTAL_SPACE_VIEW').value ? $('TOTAL_SPACE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BUILD_ADD_DESC = $('BUILD_ADD_DESC_VIEW').value;
		rtnMap.PUB_RATE = $('PUB_RATE_VIEW').value ? $('PUB_RATE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.PARK = $('PARK_VIEW').value ? $('PARK_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.PARK_NO = $('PARK_NO_VIEW').value;
		rtnMap.PARK_SPACE = $('PARK_SPACE_VIEW').value ? $('PARK_SPACE_VIEW').value.replace(/,/gi,'') : '0';
		if($('IS_LAND_Y').checked ==true){
			rtnMap.IS_LAND = '1';
		}else if($('IS_LAND_N').checked ==true){
			rtnMap.IS_LAND = '0';
		}else {
		    rtnMap.IS_LAND = '';
		}
		rtnMap.BROKER_NAME = $('BROKER_NAME').value;
		if($('WELL_CONTRACT_Y').checked ==true){
			rtnMap.WELL_CONTRACT = '1';
		}else if($('WELL_CONTRACT_N').checked ==true){
			rtnMap.WELL_CONTRACT = '0';
		}else {
		    rtnMap.WELL_CONTRACT = '';
		}

		<%--[20210712] 增加「特殊擔保品選項」與「現況出入無虞」兩個欄位--%>
		rtnMap.SPC_GAGE_OPT = $F('SPC_GAGE_OPT_VIEW');
		if($('SPC_GAGE_TYPE_Y').checked ==true){
			rtnMap.SPC_GAGE_TYPE = '1';
		}else if($('SPC_GAGE_TYPE_N').checked ==true){
			rtnMap.SPC_GAGE_TYPE = '0';
		}else {
		    rtnMap.SPC_GAGE_TYPE = '';
		}
		
		//D區
		//rtnMap.ROAD_WIDTH2 = $('ROAD_WIDTH2_VIEW').value ? $('ROAD_WIDTH2_VIEW').value.replace(/,/gi,'') : '0';
		//rtnMap.ROAD_NAME = $('ROAD_NAME_VIEW').value;
		//rtnMap.NEAR_DISTANCE = $('NEAR_DISTANCE_VIEW').value ? $('NEAR_DISTANCE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.SHOP_KIND = $('SHOP_KIND_VIEW').value;
		rtnMap.SHOP_STATUS = $('SHOP_STATUS_VIEW').value;
		rtnMap.AREA_ADD = $('AREA_ADD_VIEW').checked ? 1 : 0;
		rtnMap.MANAGE_STATUS = $('MANAGE_STATUS_VIEW').value;
		rtnMap.LIFE_FUNC = $('LIFE_FUNC_VIEW').value;
		rtnMap.TRFC_FUNC = $('TRFC_FUNC_VIEW').value;
		rtnMap.HOUSE_CONDITIONS = $('HOUSE_CONDITIONS_VIEW').value;
		rtnMap.NOPIC_REASON = $('NOPIC_REASON_VIEW').value;
		rtnMap.APPEARANCE_PIC_REASON = $('APPEARANCE_PIC_REASON_VIEW').value;
		rtnMap.APPEARANCE_PIC_DATE = toY2K($('APPEARANCE_PIC_DATE_VIEW').value);
		rtnMap.FOLLOW_NUMBER = $('FOLLOW_NUMBER_VIEW').value;
		rtnMap.PHOTO_ID = $('PHOTO_ID_VIEW').value;
		rtnMap.DISLIKE_FACILITY = $('DISLIKE_FACILITY_VIEW').value;
		rtnMap.DISLIKE_DISTANCE = $('DISLIKE_DISTANCE_VIEW').value ? $('DISLIKE_DISTANCE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.DISLIKE_EFFECT = $('DISLIKE_EFFECT_VIEW').value;
		rtnMap.DISLIKE_FACILITY2 = $('DISLIKE_FACILITY2_VIEW').value;
		rtnMap.DISLIKE_DISTANCE2 = $('DISLIKE_DISTANCE2_VIEW').value ? $('DISLIKE_DISTANCE2_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.DISLIKE_EFFECT2 = $('DISLIKE_EFFECT2_VIEW').value;
		rtnMap.SPC_DISTANCE = $('SPC_DISTANCE_VIEW').value ? $('SPC_DISTANCE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.SPC_KD_BAD = $('SPC_KD_BAD_VIEW').value;
		rtnMap.SPC_RATE = $('SPC_RATE_VIEW').value ? $('SPC_RATE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.DISLIKE_DESC = $('DISLIKE_DESC_VIEW').value;
		rtnMap.SPC_KD_GOOD_NAME = $('SPC_KD_GOOD_NAME_VIEW').value;
		rtnMap.SPC_KD_GOOD = $('SPC_KD_GOOD_VIEW').value;
		rtnMap.SPC_DISTANCE1 = $('SPC_DISTANCE1_VIEW').value ? $('SPC_DISTANCE1_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.SPC_KD_GOOD_NAME2 = $('SPC_KD_GOOD_NAME2_VIEW').value;
		rtnMap.SPC_KD_GOOD2 = $('SPC_KD_GOOD2_VIEW').value;
		rtnMap.SPC_DISTANCE2 = $('SPC_DISTANCE2_VIEW').value ? $('SPC_DISTANCE2_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.SPC_DESC = $('SPC_DESC_VIEW').value;
		rtnMap.METRO = $('METRO_VIEW').value;
		rtnMap.BUILD_LINE = $('BUILD_LINE_VIEW').value;
		rtnMap.STATION = $('STATION_VIEW').value;
		rtnMap.BUILD_STATION = $('BUILD_STATION_VIEW').value;
		rtnMap.METRO1 = $('METRO1_VIEW').value;
		rtnMap.ROUND_LINE = $('ROUND_LINE_VIEW').value;
		rtnMap.STATION1 = $('STATION1_VIEW').value;
		rtnMap.ROUND_STATION = $('ROUND_STATION_VIEW').value;
		rtnMap.ROUND_EXIT = $('ROUND_EXIT_VIEW').value;
		rtnMap.ROUND_DISTANCE = $('ROUND_DISTANCE_VIEW').value;

		var A213BList = [];
		$$('#A213BList_VIEW input[id]','#A213BList_VIEW select[id]').each(function(record){
			var id = record.id.substring(0,record.id.indexOf('_A213'));
			var index = record.id.substring(record.id.indexOf('_VIEW_')+6);
			var insRec = A213BList[index] ? A213BList[index] : {};
			insRec[id] = record.value ? record.value.replace(/,/gi,'') : '0';
			A213BList[index] = insRec;
		});
		inputMap.DISLIKEList = A213BList;
		
		var A213AList = [];
		$$('#A213AList_VIEW input[id]','#A213AList_VIEW select[id]').each(function(record){
			var id = record.id.substring(0,record.id.indexOf('_A213'));
			var index = record.id.substring(record.id.indexOf('_VIEW_')+6);
			var insRec = A213AList[index] ? A213AList[index] : {};
			insRec[id] = record.value ? record.value.replace(/,/gi,'') : '0';
			A213AList[index] = insRec;
		});
		
		var A213CList = [];
		$$('#A213CList_VIEW input[id]','#A213CList_VIEW select[id]').each(function(record){
			var id = record.id.substring(0,record.id.indexOf('_A213'));
			var index = record.id.substring(record.id.indexOf('_VIEW_')+6);
			var insRec = A213CList[index] ? A213CList[index] : {};
			insRec[id] = record.value ? record.value.replace(/,/gi,'') : '0';
			A213CList[index] = insRec;
		});
		
		var GOODList = [];
		for(var i = 0 ; i < A213AList.length ; i++){
			GOODList.push(A213AList[i]);
		}
		for(var i = 0 ; i < A213CList.length ; i++){
			GOODList.push(A213CList[i]);
		}
		inputMap.GOODList = GOODList;
		
		//G區
		rtnMap.LOC_DESC = $('LOC_DESC_VIEW').value;
		//H區
		rtnMap.HIGH_AMT_DESC = $('HIGH_AMT_DESC_VIEW').value;
		//I區
		rtnMap.TAKE_OVER = $('TAKE_OVER_VIEW').value;
		//M區
		rtnMap.LAND_PRICEA = $('LAND_PRICEA_VIEW').value ? $('LAND_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BUILD_PRICEA = $('BUILD_PRICEA_VIEW').value ? $('BUILD_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.PARK_NUM = $('PARK_NUM_VIEW_1').value ? $('PARK_NUM_VIEW_1').value.replace(/,/gi,'') : '0';
		rtnMap.PARK_AMT = $('PARK_AMT_VIEW_1').value ? $('PARK_AMT_VIEW_1').value.replace(/,/gi,'') : '0';
		rtnMap.PARK_SPACEB = $('PARK_SPACEB_VIEW').value ? $('PARK_SPACEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.ADD_SPACE = $('ADD_SPACE_VIEW').value ? $('ADD_SPACE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.ADD_PRICE = $('ADD_PRICE_VIEW').value ? $('ADD_PRICE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.PER_PRICE = $('PER_PRICE_VIEW').value ? $('PER_PRICE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.TOTAL_PRICE = $('TOTAL_PRICE_VIEW').value ? $('TOTAL_PRICE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.AVG_PRICE = $('AVG_PRICE_VIEW').value ? $('AVG_PRICE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.FORMULA = $('FORMULA1_VIEW').value;
		rtnMap.FORMULA = $('FORMULA_VIEW').value;
		//P區
		rtnMap.CAPT_EXAM = $('CAPT_EXAM_VIEW').value;
		rtnMap.CAPT_EXAM_DESC = $('CAPT_EXAM_DESC_VIEW').value;
		rtnMap.CAPT_LAND_PRICEA = $('CAPT_LAND_PRICEA_VIEW').value ? $('CAPT_LAND_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_BUILD_PRICEA = $('CAPT_BUILD_PRICEA_VIEW').value ? $('CAPT_BUILD_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PARK_PRICEA = $('CAPT_PARK_PRICEA_VIEW').value ? $('CAPT_PARK_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PARK_NUMA = $('CAPT_PARK_NUMA_VIEW').value ? $('CAPT_PARK_NUMA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PER_PRICEA = $('CAPT_PER_PRICEA_VIEW').value ? $('CAPT_PER_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_TOTAL_PRICEA = $('CAPT_TOTAL_PRICEA_VIEW').value ? $('CAPT_TOTAL_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_AVG_PRICEA = $('CAPT_AVG_PRICEA_VIEW').value ? $('CAPT_AVG_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PARK_SPACEA = $('CAPT_PARK_SPACEA_VIEW').value ? $('CAPT_PARK_SPACEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_LAND_PRICEB = $('CAPT_LAND_PRICEB_VIEW').value ? $('CAPT_LAND_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_BUILD_PRICEB = $('CAPT_BUILD_PRICEB_VIEW').value ? $('CAPT_BUILD_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PARK_PRICEB = $('CAPT_PARK_PRICEB_VIEW').value ? $('CAPT_PARK_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PARK_NUMB = $('CAPT_PARK_NUMB_VIEW').value ? $('CAPT_PARK_NUMB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PER_PRICEB = $('CAPT_PER_PRICEB_VIEW').value ? $('CAPT_PER_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_TOTAL_PRICEB = $('CAPT_TOTAL_PRICEB_VIEW').value ? $('CAPT_TOTAL_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_AVG_PRICEB = $('CAPT_AVG_PRICEB_VIEW').value ? $('CAPT_AVG_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PARK_SPACEB = $('CAPT_PARK_SPACEB_VIEW').value ? $('CAPT_PARK_SPACEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_EXAM = $('BOSS_EXAM_VIEW').value;
		rtnMap.BOSS_EXAM_DESC = $('BOSS_EXAM_DESC_VIEW').value;
		rtnMap.BOSS_LAND_PRICEA = $('BOSS_LAND_PRICEA_VIEW').value ? $('BOSS_LAND_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_BUILD_PRICEA = $('BOSS_BUILD_PRICEA_VIEW').value ? $('BOSS_BUILD_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PARK_PRICEA = $('BOSS_PARK_PRICEA_VIEW').value ? $('BOSS_PARK_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PARK_NUMA = $('BOSS_PARK_NUMA_VIEW').value ? $('BOSS_PARK_NUMA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PER_PRICEA = $('BOSS_PER_PRICEA_VIEW').value ? $('BOSS_PER_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_TOTAL_PRICEA = $('BOSS_TOTAL_PRICEA_VIEW').value ? $('BOSS_TOTAL_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_AVG_PRICEA = $('BOSS_AVG_PRICEA_VIEW').value ? $('BOSS_AVG_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PARK_SPACEA = $('BOSS_PARK_SPACEA_VIEW').value ? $('BOSS_PARK_SPACEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_LAND_PRICEB = $('BOSS_LAND_PRICEB_VIEW').value ? $('BOSS_LAND_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_BUILD_PRICEB = $('BOSS_BUILD_PRICEB_VIEW').value ? $('BOSS_BUILD_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PARK_PRICEB = $('BOSS_PARK_PRICEB_VIEW').value ? $('BOSS_PARK_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PARK_NUMB = $('BOSS_PARK_NUMB_VIEW').value ? $('BOSS_PARK_NUMB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PER_PRICEB = $('BOSS_PER_PRICEB_VIEW').value ? $('BOSS_PER_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_TOTAL_PRICEB = $('BOSS_TOTAL_PRICEB_VIEW').value ? $('BOSS_TOTAL_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_AVG_PRICEB = $('BOSS_AVG_PRICEB_VIEW').value ? $('BOSS_AVG_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PARK_SPACEB = $('BOSS_PARK_SPACEB_VIEW').value ? $('BOSS_PARK_SPACEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.GM_EXAM_DESC = $('GM_EXAM_DESC_VIEW').value;
		
		//新增、修正、呈核
		if('insert'==action || 'update'==action || 'confirm'==action){
			
			//E區
			var A201List = [];
			$$('#gridE1 input','#gridE1 select').each(function(record){
				var id = record.id.substring(0,record.id.indexOf('_VIEW_'));
				var index = record.id.substring(record.id.indexOf('_VIEW_')+6);
				var insRec = A201List[index-1] ? A201List[index-1] : {};
				insRec[id] = record.value.replace(/,/gi,'');
				A201List[index-1] = insRec;
			});
			inputMap.A201List = A201List;
			//F1區
			var A209List = [];
			$$('#gridF1 input','#gridF1 select').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				var index = record.id.substring(record.id.lastIndexOf('_')+1);

				if(!isNaN(index)){
					var insRec = A209List[index-1] ? A209List[index-1] : {};
					insRec[id] = record.value.replace(/,/gi,'');
					insRec['DIFF_MEASURE'] = insRec['DIFF_MEASURE'];
					insRec['LOWER_PRICE'] = insRec['LOWER_PRICE'];
					insRec['UPPER_PRICE'] = insRec['UPPER_PRICE'];
					insRec['MEASURE_KIND'] = $F('MEASURE_KIND_VIEW');
					insRec['DIFF_KIND_A'] = $F('DIFF_KIND_A_VIEW');
					insRec['DIFF_KIND_B'] = $F('DIFF_KIND_B_VIEW');
					A209List[index-1] = insRec;
				}
			});
			
			inputMap.A209List = A209List;
			//F2區
			var A202List = [];
			$$('#gridF2 input','#gridF2 select').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				var index = record.id.substring(record.id.lastIndexOf('_')+1);
				if(!isNaN(index )){
					var insRec = A202List[index-1] ? A202List[index-1] : {};
					if(id=='COMP_ITEM'){
						insRec['APPLY_ID'] = record.APPLY_ID;
						insRec['SEQ_NO'] = record.SEQ_NO;
					}
					insRec[id] = record.value.replace(/,/gi,'');
					A202List[index-1] = insRec;
				}
			});
			inputMap.A202List = A202List;
			//K區N區
			var A205List = [];
			$$('#gridK1 input','#gridN1 input').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				var index = record.id.substring(record.id.lastIndexOf('_')+1);
				if(!isNaN(index )){
					var insRec = A205List[index-1] ? A205List[index-1] : {};
					if(id=='EACH_PRICE'){
						insRec['APPLY_ID'] = record.getAttribute('APPLY_ID');
						insRec['BUILD_NO1'] = record.getAttribute('BUILD_NO1');
						insRec['BUILD_NO2'] = record.getAttribute('BUILD_NO2');
					}
					insRec[id] = record.value.replace(/,/gi,'');
					if(id=='PARK_SPACEA'){
						insRec['PARK_SPACE'] = insRec['PARK_SPACEA'];
					}
					A205List[index-1] = insRec;
				}
			});
			//各筆擔保品1筆時將鑑價人員批示資料帶到該筆
			if (A205List.length==1) {
				if(CSRUtil.getNumber(rtnMap.PER_PRICE)==0){
					A205List[0].EACH_PRICE = rtnMap.AVG_PRICE ? rtnMap.AVG_PRICE : '0';
				}else{
					A205List[0].EACH_PRICE = rtnMap.PER_PRICE ? rtnMap.PER_PRICE : '0'; 
				}
			}

			inputMap.A205List = A205List;
			inputMap.A205ListCheck = A205List;
			//L區O區
			//複製修改後資料到A217List
			copyTableListToA217List('gridL1');
			inputMap.A217List = A217List;
			//M1,M2區
			inputMap.A215ListA = gridM1.getAllRecords();
			inputMap.A215ListS = gridM2.getAllRecords();
			inputMap.A215ListC = gridM3.getAllRecords(); //20210615 社區價格
			inputMap.A215ListP = gridMP.getAllRecords(); <%--[20240613]車位估價紀錄 --%>
			inputMap.A215ListM = gridMM.getAllRecords();<%--[20250211]公寓估價紀錄 --%>
			//H1區
			inputMap.A216List = gridH1.getCheckedRecord();
		}else if('captainConfirm'==action || 'bossConfirm'==action){
			//組長覆核、主管(代理)覆核
			//N區
			var A205List = [];
			$$('#gridN1 input').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				var index = record.id.substring(record.id.lastIndexOf('_')+1);
				if(!isNaN(index )){
					var insRec = A205List[index-1] ? A205List[index-1] : {};
					if(id=='CAPT_EACH_PRICE'){
						insRec['APPLY_ID'] = record.getAttribute('APPLY_ID');
						insRec['BUILD_NO1'] = record.getAttribute('BUILD_NO1');
						insRec['BUILD_NO2'] = record.getAttribute('BUILD_NO2');
					}
					insRec[id] = record.value.replace(/,/gi,'');
					A205List[index-1] = insRec;
				}
			});
			inputMap.A205List = A205List;
			
			$$('#gridK1 input','#gridN1 input').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				var index = record.id.substring(record.id.lastIndexOf('_')+1);
				if(!isNaN(index )){
					var insRec = A205List[index-1] ? A205List[index-1] : {};
					if(id=='EACH_PRICE'){
						insRec['APPLY_ID'] = record.getAttribute('APPLY_ID');
						insRec['BUILD_NO1'] = record.getAttribute('BUILD_NO1');
						insRec['BUILD_NO2'] = record.getAttribute('BUILD_NO2');
					}
					insRec[id] = record.value.replace(/,/gi,'');
					if(id=='PARK_SPACEA'){
						insRec['PARK_SPACE'] = insRec['PARK_SPACEA'];
					}
					A205List[index-1] = insRec;
				}
			});
			//各筆擔保品1筆時將鑑價人員批示資料帶到該筆
			if (A205List.length==1) {
				if(CSRUtil.getNumber(rtnMap.PER_PRICE)==0){
					A205List[0].EACH_PRICE = rtnMap.AVG_PRICE ? rtnMap.AVG_PRICE : '0';
				}else{
					A205List[0].EACH_PRICE = rtnMap.PER_PRICE ? rtnMap.PER_PRICE : '0'; 
				}
			}
			inputMap.A205ListCheck = A205List;
			//O區
			//複製修改後資料到A217List
			copyTableListToA217List('gridO1');
			inputMap.A217List = A217List;
		}

		inputMap.rtnMap = rtnMap;
		inputMap.CHK_APPLY_ID = $('APPLY_ID').value;
		inputMap.VIEW_APPLY_ID = viewMap.APPLY_ID;
		//R區
		inputMap.A107List = gridR1.getAllRecords();
		
		return inputMap;	
	}
	
	//重設特殊屋況檢核區塊
	function resetSPC_CONDITION(rtnMap){
		//每次清除特殊屋況區塊再新增
		$('DYNAMIC_SPC_CONDITION').childElements().each(
		   function(child) {
		      Event.stopObserving(child);
		      child.remove();
		   }
		);
		
		var font1 = new Element('font',{color : 'red', style : 'display:none'}).update('特殊屋況：');
		var input1 = new Element('input',{id : 'SPC_CONDITION_VIEW', type : 'checkbox', style : 'display:none'});
		var font2 = new Element('font',{color : 'red', style : 'display:none'}).update('是否已查證或進行適當處理');
		$('DYNAMIC_SPC_CONDITION').appendChild(font1);
		$('DYNAMIC_SPC_CONDITION').appendChild(input1);
		$('DYNAMIC_SPC_CONDITION').appendChild(font2);
		
		//登入者為國壽人員 且 查詢有特殊屋況 才顯示SPC_CONDITION區塊
		if((${IS_BANK_USER} == false) && (rtnMap.HAS_SPC_CONDITION == 'Y')){
			font1.setAttribute('style', 'display:inline');
			input1.setAttribute('style', 'display:inline');
			font2.setAttribute('style', 'display:inline');
		}
		
		if(rtnMap.SPC_CONDITION && rtnMap.SPC_CONDITION == '1'){
			$('SPC_CONDITION_VIEW').checked = true;
		}else{
			$('SPC_CONDITION_VIEW').checked = false;
		}
	}
	
	//將List增加到下拉選單中
	function appendList(list , target){
		//加入List	
		if(list){
			for(var i = 0; i < list.length; i++){ 
				if(target=="METRO_VIEW"){
					$('STATION_VIEW').options.add(new Option(list[i]['S_NAME'], list[i]['S_SEQ'])); 
				}else if(target=="METRO1_VIEW"){
					$('STATION1_VIEW').options.add(new Option(list[i]['S_NAME'], list[i]['S_SEQ'])); 
				}
			}
		}
	}

	//將收下拉選單清除,加入請選擇 , target為要清除的dom物件
	function updateList(target){
		target.update();
		//請選擇
		target.options.add(new Option( "請選擇" , "")); 
	}
	//20210610 PRICE_GAP1與PRICE_GAP2連動
	function dropDownGAP_NOTE2List(sn,GAP_NOTE){
		
		var SELECT2 = new Element('SELECT');
		SELECT2.add(new Option("請選擇", ""));
		if(PRICE_GAP2_LIST && PRICE_GAP2_LIST.length != 0){
			for (key in PRICE_GAP2_LIST){
				if (GAP_NOTE && key[0]==GAP_NOTE[0]){
				SELECT2.add(new Option(PRICE_GAP2_LIST[key], key));
				}
			}
			if(GAP_NOTE){
				SELECT2.value = GAP_NOTE ||'';
			}else{
				SELECT2.value = '';
			}
		}
		return SELECT2
	}
	
	//20240625  PSM_GAP1與PSM_GAP2連動 車位價格落差原因連動
	function dropDownPSMGAP_NOTE2List(sn,GAP_NOTE){
		
		var SELECT2 = new Element('SELECT');
		SELECT2.add(new Option("請選擇", ""));
		if(PSM_GAP2_LIST && PSM_GAP2_LIST.length != 0){
			for (key in PSM_GAP2_LIST){
				if (GAP_NOTE && key[0]==GAP_NOTE[0]){
				SELECT2.add(new Option(PSM_GAP2_LIST[key], key));
				}
			}
			if(GAP_NOTE){
				SELECT2.value = GAP_NOTE ||'';
			}else{
				SELECT2.value = '';
			}
		}
		return SELECT2
		
		
	}		
	
	//將List增加到清單中
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
		
		//加入List
		if(list){
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
							insertString1 += "<td class='tbYellow2'><a href='#"+target+"_INPUT_DESC_VIEW_"+mover+"' onClick='DSA30500.doShowdiv_A203List_VIEW("+mover+",\""+target+"\")'>批示</a>：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto; '>" + INPUT_DESC + "</div></td>";
						}else{
							insertString1 += "<td class='tbYellow2'>批示：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto; '>" + INPUT_DESC + "</div></td>";
						}
						insertString1 += "</tr>";
					}else{
						insertString1 += "<tr class=tbBlue3>";
						insertString1 += "<td class='tbYellow2' style='font-family:EUDC'>" + INPUT_DATE + "　" + EMP_NAME + "　" + CODE_NAME + "</td>";<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						if('3'==INPUT_TYPE || '4'==INPUT_TYPE || '5'==INPUT_TYPE){
							insertString1 += "<td class='tbYellow2'><a href='#"+target+"_INPUT_DESC_VIEW_"+mover+"' onClick='DSA30500.doShowdiv_A203List_VIEW("+mover+",\""+target+"\")'>批示</a>：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto; '>" + INPUT_DESC + "</div></td>";
						}else{
							insertString1 += "<td class='tbYellow2'>批示：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto; '>" + INPUT_DESC + "</div></td>";
						}
						insertString1 += "</tr>";
					}
				}else{
					// 若valMap.CASE_SEQ_NO = 1時，表示為原貸件，先寫一筆頭表，再寫明細
					if (valMap.SEQ_NO == '0'){
						ADDR_NO = valMap.ADDR_NO ? valMap.ADDR_NO : '';
						BUILD_NO1 = valMap.BUILD_NO1 ? valMap.BUILD_NO1 : '';
						BUILD_NO2 = valMap.BUILD_NO2 ? valMap.BUILD_NO2 : '';
						AUX_NO1 = valMap.AUX_NO1 ? valMap.AUX_NO1 : '';
						AUX_NO2 = valMap.AUX_NO2 ? valMap.AUX_NO2 : '';
						A051_MEASURE = valMap.A051_MEASURE ? valMap.A051_MEASURE : '';
						ITEM_NM = valMap.ITEM_NM ? valMap.ITEM_NM : '';
						if(target=='gridL1'){
							insertString1 += "<tr class=tbBlue3 align=middle>";
							insertString1 += "<td align=middle style='font-family:EUDC'>" + ADDR_NO + "</td>";<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
							insertString1 += "<td align=middle>" + BUILD_NO1 + "-" + BUILD_NO2 + "</td>";
							insertString1 += "<td align=middle>" + AUX_NO1 + "-" + AUX_NO2 + "</td>";
							insertString1 += "<td align=middle>" + A051_MEASURE + "</td>";
							insertString1 += "<td align=middle>" + ITEM_NM + "</td>";
							insertString1 += "<td align=middle>"; 
							if ('${OP}'!='2') {
								insertString1 += "<input type='button' class='button' value='新增' onClick='DSA30500.addRows("+mover+",\""+target+"\")'>"
							}
							insertString1 += "</td></tr>";
						}else{
							insertString1 += "<tr class=tbBlue3 align=middle>";
							insertString1 += "<td align=middle style='font-family:EUDC'>" + ADDR_NO + "</td>";<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
							insertString1 += "<td align=middle>" + BUILD_NO1 + "-" + BUILD_NO2 + "</td>";
							insertString1 += "<td align=middle>" + AUX_NO1 + "-" + AUX_NO2 + "</td>";
							insertString1 += "<td align=middle>" + A051_MEASURE + "</td>";
							insertString1 += "<td align=middle>" + ITEM_NM + "</td>";
							insertString1 += "</tr>";
						}
					}else{
						if(target=='gridL1'){
							PARK_NO = valMap.PARK_NO ? valMap.PARK_NO : '';
							HOLD_BASE = valMap.HOLD_BASE ? CSRUtil.$fmt(valMap.HOLD_BASE, defaultPattern1) : '0';
							HOLD_UP = valMap.HOLD_UP ? CSRUtil.$fmt(valMap.HOLD_UP, defaultPattern1) : '0';
							PARK_TYPE = valMap.PARK_TYPE ? valMap.PARK_TYPE : $F('PARK_VIEW');
							PARK_NUM = valMap.PARK_NUM ? CSRUtil.$fmt(valMap.PARK_NUM, defaultPattern1) : '';
							if(HOLD_BASE && HOLD_UP) {
								//MEASURE = CSRUtil.round(valMap.MEASURE * 0.3025, 3);
								//valMap.PARK_SPACE = CSRUtil.round(MEASURE * valMap.HOLD_UP / valMap.HOLD_BASE,3);
								valMap.PARK_SPACE = CSRUtil.round(valMap.MEASURE * valMap.HOLD_UP * 0.3025 / valMap.HOLD_BASE, 3);
							}
							PARK_SPACE = valMap.PARK_SPACE ? CSRUtil.$fmt(valMap.PARK_SPACE, defaultPattern2) : '0';
							PARK_AMT = valMap.PARK_AMT ? CSRUtil.$fmt(valMap.PARK_AMT, defaultPattern1) : '';
							insertString1 += "<tr class='tbBlue3' align='middle'>";
							insertString1 += "<td align='middle'>" 
							insertString1 += "車位編號<input type='text' class='textBox2' size='15' maxLength='40' id='"+target+"_PARK_NO_VIEW_"+mover+"' value='"+PARK_NO+"'>" ;
							insertString1 += "<br>";
							//[20210804] 問題單 單號:20210804140313 敘述: 當案件為銀行件，修改時新增檢核車位持分分母欄位不得異動
						    insertString1 += "車位持分<input type='text' class='textBox2' size='14' maxLength='14' id='"+target+"_HOLD_BASE_VIEW_"+mover+"' value='"+HOLD_BASE+"' style='text-align:right;' onclick='alert("+'"銀行件公設拆分計算其分母不得異動!"'+")' readonly>" ;
						    //insertString1 += "車位持分<input type='text' class='textBox2' size='14' maxLength='14' id='"+target+"_HOLD_BASE_VIEW_"+mover+"' value='"+HOLD_BASE+"' style='text-align:right;' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)' onBlur='DSA30500.changePARK_AMT("+mover+",\""+target+"\")'>" ;
						    
							insertString1 += "分之<input type='text' class='textBox2' size='14' maxLength='14' id='"+target+"_HOLD_UP_VIEW_"+mover+"' value='"+HOLD_UP+"' style='text-align:right;' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)' onBlur='DSA30500.changePARK_AMT("+mover+",\""+target+"\")'>" ;
							insertString1 += "</td>";
							insertString1 += "<td align='middle'>" ;
							insertString1 += "<select id='"+target+"_PARK_TYPE_VIEW_"+mover+"' class='parkTypeViewSelectOption' index="+mover+">"
							<c:forEach var="map" items="${PARK_TYPE_LIST}">
								insertString1 += "<option value='${map.key}' ";
								if('${map.key}'==PARK_TYPE){
									insertString1 += "selected";
								}
								insertString1 += ">${map.value}</option>"; 
							</c:forEach>
							insertString1 += "</select>";
							insertString1 += "</td>";
							insertString1 += "<td align='middle'>";
							insertString1 += "<input type='text' class='textBox2' size='5' maxLength='11' id='"+target+"_PARK_NUM_VIEW_"+mover+"' value='"+PARK_NUM+"' style='text-align:right' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)'>";
							insertString1 += "</td>";
							insertString1 += "<td align='middle' id='"+target+"_PARK_SPACE_VIEW_"+mover+"'>" 
							
							insertString1 += PARK_SPACE;
							insertString1 += "</td>";
							insertString1 += "<td align='middle'>" 
							insertString1 += "<input type='text' class='textBox2' size='5' maxLength='11' id='"+target+"_PARK_AMT_VIEW_"+mover+"' value='"+PARK_AMT+"' style='text-align:right' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)'>";
							insertString1 += "</td>";
							insertString1 += "<td align=middle>";
							if ('${OP}'!='2') {
								insertString1 += "<input type='button' class='button' value='移除' onClick='DSA30500.removeRows("+mover+",\""+target+"\")'>"
							}
							insertString1 += "</td></tr>";
						}else{
							PARK_NO = valMap.PARK_NO ? valMap.PARK_NO : '';
							HOLD_BASE = valMap.HOLD_BASE ? CSRUtil.$fmt(valMap.HOLD_BASE, defaultPattern1) : '0';
							HOLD_UP = valMap.HOLD_UP ? CSRUtil.$fmt(valMap.HOLD_UP, defaultPattern1) : '0';
							CAPT_PARK_TYPE = valMap.CAPT_PARK_TYPE ? valMap.CAPT_PARK_TYPE : '';
							CAPT_PARK_NUM = valMap.CAPT_PARK_NUM ? CSRUtil.$fmt(valMap.CAPT_PARK_NUM, defaultPattern1) : '0';
							PARK_SPACE = valMap.PARK_SPACE ? CSRUtil.$fmt(valMap.PARK_SPACE, defaultPattern2) : '0';
							CAPT_PARK_AMT = valMap.CAPT_PARK_AMT ? CSRUtil.$fmt(valMap.CAPT_PARK_AMT, defaultPattern1) : '0';
							BOSS_PARK_TYPE = valMap.BOSS_PARK_TYPE ? valMap.BOSS_PARK_TYPE : '';
							BOSS_PARK_NUM = valMap.BOSS_PARK_NUM ? CSRUtil.$fmt(valMap.BOSS_PARK_NUM, defaultPattern1) : '0';
							BOSS_PARK_SPACE = valMap.BOSS_PARK_SPACE ? CSRUtil.$fmt(valMap.BOSS_PARK_SPACE, defaultPattern2) : '0';
							BOSS_PARK_AMT = valMap.BOSS_PARK_AMT ? CSRUtil.$fmt(valMap.BOSS_PARK_AMT, defaultPattern1) : '0';

							insertString1 += "<tr class='tbBlue3' align='middle'>";
							insertString1 += "<td align='middle'>" 
							insertString1 += "車位編號<input readOnly type='text' class='textBox2' size='15' maxLength='40' id='"+target+"_PARK_NO_VIEW_"+mover+"' value='"+PARK_NO+"'>" ;
							insertString1 += "<br>";
							insertString1 += "車位持分<input readOnly type='text' class='textBox2' size='10' maxLength='10' id='"+target+"_HOLD_BASE_VIEW_"+mover+"' value='"+HOLD_BASE+"' style='text-align:right;' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)'>" ;
							insertString1 += "分之<input readOnly type='text' class='textBox2' size='10' maxLength='10' id='"+target+"_HOLD_UP_VIEW_"+mover+"' value='"+HOLD_UP+"' style='text-align:right;' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)'>" ;
							insertString1 += "</td>";
							insertString1 += "<td align='middle'>" ;
							insertString1 += "組長<select id='"+target+"_CAPT_PARK_TYPE_VIEW_"+mover+"' index="+mover+">"
							<c:forEach var="map" items="${PARK_LIST}">
								insertString1 += "<option value='${map.key}' ";
								if('${map.key}'==CAPT_PARK_TYPE){
									insertString1 += "selected";
								}
								insertString1 += ">${map.value}</option>"; 
							</c:forEach>
							insertString1 += "</select>";
							insertString1 += "<br>";
							insertString1 += "主管<select id='"+target+"_BOSS_PARK_TYPE_VIEW_"+mover+"' index="+mover+">"
							<c:forEach var="map" items="${PARK_LIST}">
								insertString1 += "<option value='${map.key}' ";
								if('${map.key}'==BOSS_PARK_TYPE){
									insertString1 += "selected";
								}
								insertString1 += ">${map.value}</option>"; 
							</c:forEach>
							insertString1 += "</select>";
							insertString1 += "</td>";
							insertString1 += "<td align='middle'>";
							insertString1 += "<input type='text' class='textBox2' size='5' maxLength='11' id='"+target+"_CAPT_PARK_NUM_VIEW_"+mover+"' value='"+CAPT_PARK_NUM+"' index="+mover+" style='text-align:right' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)'>";
							insertString1 += "<br>";
							insertString1 += "<input type='text' class='textBox2' size='5' maxLength='11' id='"+target+"_BOSS_PARK_NUM_VIEW_"+mover+"' value='"+BOSS_PARK_NUM+"' index="+mover+" style='text-align:right' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)'>";
							insertString1 += "</td>";
							insertString1 += "<td align='middle' id='CAPT_PARK_SPACE_VIEW'>" 
							insertString1 += PARK_SPACE;
							insertString1 += "</td>";
							insertString1 += "<td align='middle'>" 
							insertString1 += "<input type='text' class='textBox2' size='5' maxLength='11' id='"+target+"_CAPT_PARK_AMT_VIEW_"+mover+"' value='"+CAPT_PARK_AMT+"' index="+mover+" style='text-align:right' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)'>";
							insertString1 += "<br>";
							insertString1 += "<input type='text' class='textBox2' size='5' maxLength='11' id='"+target+"_BOSS_PARK_AMT_VIEW_"+mover+"' value='"+BOSS_PARK_AMT+"' index="+mover+" style='text-align:right' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)'>";
							insertString1 += "</td>";
							insertString1 += "</tr>";
						}
					}
				}
			}
			dataTable1.insert({	bottom:insertString1 });
			<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			parseEUDC();
		}
	}
	
	//將List增加到清單中
	function addRows(mover1 , target){
		//複製修改後資料到A217List
		copyTableListToA217List(target);
		//新增一筆資料
		valMap = A217List[mover1];
		var copySetting = JsUtils.cloneObject(valMap);  
		copySetting.SEQ_NO = '';
		
		for(var i = mover1+1; i < A217List.length; i++){
			if (A217List[i].SEQ_NO == '0'){
				break;
			}
		}
		A217List.splice(i,0,copySetting); 
		appendGridtoList(A217List, target);
	}

	//複製修改後資料到A217List
	function copyTableListToA217List(target){
		var valMap;
		
		if(target=='gridL1') {  
		//各擔保品附屬建物資料
			var rowIndex = 0;
			//複製輸入欄位
			$$('#'+target+' input').each(function(o){
				if(o.id){
					if(o.id.indexOf('PARK_NO_VIEW')!=-1){
						//第一個ID時取MAP資料
						valMap = A217List[rowIndex];
						valMap.PARK_NO = o.value ? o.value : '';
					} if(o.id.indexOf('HOLD_BASE_VIEW')!=-1){
						valMap.HOLD_BASE = o.value ? o.value.replace(/,/gi,'') : '0';
					} else if(o.id.indexOf('HOLD_UP_VIEW')!=-1){
						valMap.HOLD_UP = o.value ? o.value.replace(/,/gi,'') : '0';
					} else if(o.id.indexOf('PARK_NUM_VIEW')!=-1){
						valMap.PARK_NUM = o.value ? o.value.replace(/,/gi,'') : '0';
					} else if(o.id.indexOf('PARK_SPACE_VIEW')!=-1){
						valMap.PARK_SPACE = o.value ? o.value.replace(/,/gi,'') : '0';
					} else if(o.id.indexOf('PARK_AMT_VIEW')!=-1){
						valMap.PARK_AMT = o.value ? o.value.replace(/,/gi,'') : '0';
						//最後一個ID時塞回MAP資料
						A217List[rowIndex] = valMap;
					}
				}
				if(o.type=='button'){
					rowIndex++;
				}
			});

			//複製下拉選單
			$$('#gridL1 select').each(function(o){
				if(o.id.indexOf('PARK_TYPE_VIEW')!=-1){
					//第一個ID時取MAP資料
					//[20180607]問題單 原本使用o.index改使用o.readAttribute
					var index = o.readAttribute('index');
					valMap = A217List[index];
					valMap.PARK_TYPE = o.value ? o.value : '';
					//最後一個ID時塞回MAP資料
					A217List[index] = valMap;
				}
			});
			
		} else {
		//各擔保品附屬建物資料覆核 
			var rowIndex2;
			//複製輸入欄位
			$$('#gridO1 input').each(function(o){
				if(o.id){
					if(o.id.indexOf('PARK_NO_VIEW')!=-1){
					    //抓取車位資料在A217List的第幾筆
						rowIndex2 = o.id.substring(o.id.lastIndexOf('_')+1);
						//第一個ID時取MAP資料
						valMap = A217List[rowIndex2];
						valMap.PARK_NO = o.value ? o.value : '';
					} else if(o.id.indexOf('CAPT_PARK_NUM_VIEW')!=-1){
						valMap.CAPT_PARK_NUM = o.value ? o.value.replace(/,/gi,'') : '0';
					} else if(o.id.indexOf('BOSS_PARK_NUM_VIEW')!=-1){
						valMap.BOSS_PARK_NUM = o.value ? o.value.replace(/,/gi,'') : '0';
					} else if(o.id.indexOf('CAPT_PARK_SPACE_VIEW')!=-1){
						valMap.CAPT_PARK_SPACE = o.value ? o.value.replace(/,/gi,'') : '0';
					} else if(o.id.indexOf('BOSS_PARK_SPACE_VIEW')!=-1){
						valMap.BOSS_PARK_SPACE = o.value ? o.value.replace(/,/gi,'') : '0';
					} else if(o.id.indexOf('CAPT_PARK_AMT_VIEW')!=-1){
						valMap.CAPT_PARK_AMT = o.value ? o.value.replace(/,/gi,'') : '0';
					} else if(o.id.indexOf('BOSS_PARK_AMT_VIEW')!=-1){
						valMap.BOSS_PARK_AMT = o.value ? o.value.replace(/,/gi,'') : '0';
						//最後一個ID時塞回MAP資料
						A217List[rowIndex2] = valMap;
						rowIndex2++;
					}
				}
			});

			//
			$$('#gridO1 select').each(function(o){
				//[20180607]問題單 原本使用o.index改使用o.readAttribute
				var index = o.readAttribute('index');
				valMap = A217List[index];
				if(o.id.indexOf('CAPT_PARK_TYPE_VIEW')!=-1){
					valMap.CAPT_PARK_TYPE = o.value ? o.value : '';
				} else if(o.id.indexOf('BOSS_PARK_TYPE_VIEW')!=-1){
					valMap.BOSS_PARK_TYPE = o.value ? o.value : '';
				}
				A217List[index] = valMap;
			});
		}
	}
	
	
	//將List增加到清單中
	function removeRows(mover1 , target){
		//複製修改後資料到A217List
		copyTableListToA217List(target);

		A217List.splice(mover1,1);
		appendGridtoList(A217List, target);
		//if(target=='gridL1'){
		//	appendGridtoList(A217List, 'gridO1');
		//}
	}
	
	//各擔保品附屬建物資料異動時調整(L區或O區)
	function changePARK_AMT(mover , target){
	
		//複製修改後資料到A217List
		copyTableListToA217List(target);
		//修改資料
		var valMap = JsUtils.cloneObject(A217List[mover]);
		if(target=='gridL1'){
			valMap.HOLD_BASE = $(target+"_HOLD_BASE_VIEW_"+mover).value.replace(/,/gi,'');
			valMap.HOLD_UP = $(target+"_HOLD_UP_VIEW_"+mover).value.replace(/,/gi,'');
			//MEASURE = CSRUtil.round(valMap.MEASURE * 0.3025, 3);
			//valMap.PARK_SPACE = CSRUtil.round(MEASURE * valMap.HOLD_UP / valMap.HOLD_BASE,3);
			valMap.PARK_SPACE = CSRUtil.round(valMap.MEASURE * valMap.HOLD_UP * 0.3025 / valMap.HOLD_BASE, 3);
		}else{
			valMap.HOLD_BASE = $(target+"_HOLD_BASE_VIEW_"+mover).value.replace(/,/gi,'');
			valMap.HOLD_UP = $(target+"_HOLD_UP_VIEW_"+mover).value.replace(/,/gi,'');
			//MEASURE = CSRUtil.round(valMap.MEASURE * 0.3025, 3);
			//valMap.CAPT_PARK_SPACE = CSRUtil.round(MEASURE * valMap.HOLD_UP / valMap.HOLD_BASE,3);
			valMap.CAPT_PARK_SPACE = CSRUtil.round(valMap.MEASURE * valMap.HOLD_UP * 0.3025 / valMap.HOLD_BASE, 3);
			valMap.BOSS_PARK_SPACE = valMap.CAPT_PARK_SPACE;
		}
		A217List[mover] = valMap;
		//重新載入修改後資料
		appendGridtoList(A217List, target);
	}

	//建議價格資料異動時調整(M區)平均(建議單價)AVG_PRICE
	function changeAVG_PRICE(total_price, avg_price){
		buttons.doGetAvgPrice(total_price, avg_price);
	}
		
	//建議價格資料異動時調整(M區)總價TOTAL_PRICE 
	function changeTOTAL_PRICE(mover , target){
		if('1'==$("FORMULA1_VIEW").value){
			A040_LAND_SPACE = viewMap.A040_LAND_SPACE ? viewMap.A040_LAND_SPACE : 0;
			A050_BUILD_SPACE = viewMap.A050_BUILD_SPACE ? viewMap.A050_BUILD_SPACE : 0;
			$("TOTAL_PRICE_VIEW").value = CSRUtil.$fmt((A040_LAND_SPACE * $("LAND_PRICEA_VIEW").value.replace(/,/gi,'')) + (A050_BUILD_SPACE * $("BUILD_PRICEA_VIEW").value.replace(/,/gi,'')), defaultPattern1);
		}else if('2'==$("FORMULA1_VIEW").value){
			A050_BUILD_SPACE = viewMap.A050_BUILD_SPACE ? viewMap.A050_BUILD_SPACE : 0;
			$("TOTAL_PRICE_VIEW").value = CSRUtil.$fmt(A050_BUILD_SPACE * $("PER_PRICE_VIEW").value.replace(/,/gi,''), defaultPattern1);
		}else if('3'==$("FORMULA1_VIEW").value){
			A050_BUILD_SPACE = viewMap.A050_BUILD_SPACE ? viewMap.A050_BUILD_SPACE : 0;
			$("TOTAL_PRICE_VIEW").value = CSRUtil.$fmt((A050_BUILD_SPACE - $("PARK_SPACEB_VIEW").value.replace(/,/gi,'')) * $("PER_PRICE_VIEW").value.replace(/,/gi,'') + CSRUtil.getNumber($("PARK_AMT_VIEW_1").value.replace(/,/gi,'')), defaultPattern1);
		}else{
			$("TOTAL_PRICE_VIEW").value = "0";
		}
	}
	 //20210617 調整鑑價報告上，建物型態與樓層輸入方式
	function changeBUILDTYPE(){
		var floorMemoStr="";
		
		if($('FLOOR_MEMO').value){
			floorMemoStr=" "+ $('FLOOR_MEMO').value;
		}
		
		var tmptargetFloor = parseInt($('TARGET_FLOOR').value) || '';
		var tmpStrtargetFloor = tmptargetFloor.toString();
		var targetFloorStr = tmptargetFloor < 0? "B" + tmpStrtargetFloor.substring(1) : tmpStrtargetFloor;
		$('BUILD_TYPE_VIEW').value = targetFloorStr +floorMemoStr+'/'+CSRUtil.$fmt( $('TOTAL_FLOOR').getValue() , "###");
		
		return $('BUILD_TYPE_VIEW').value;
	 }
	 
	 //20210811 SUPPORT_ID改變後連動
	 function changeSUPPORT_ID_VIEW(){
		 //[20240507]fixbug，SUPPORT_ID_VIEW避免下拉選單對應不到時會拋錯
		 if($('SUPPORT_ID_VIEW').selectedIndex>=0){
			 $("PHOTO_NM_VIEW").innerHTML = $('SUPPORT_ID_VIEW').options[$('SUPPORT_ID_VIEW').selectedIndex].text;	 
		 }else{
			 $("PHOTO_NM_VIEW").innerHTML = '';
		 }
		$("PHOTO_ID_VIEW").value = $('SUPPORT_ID_VIEW').value;
	 }
		
	
	function changeCAPT_EXAM_VIEW(){
	
		//選擇“如擬”
		if('1'==$("CAPT_EXAM_VIEW").value){
			$("CAPT_LAND_PRICEA_VIEW").value = $("LAND_PRICEA_VIEW").value;
			$("CAPT_BUILD_PRICEA_VIEW").value = $("BUILD_PRICEA_VIEW").value;
			$("CAPT_PARK_PRICEA_VIEW").value = $("PARK_AMT_VIEW_1").value;
			$("CAPT_PARK_NUMA_VIEW").value = $("PARK_NUM_VIEW_1").value;
			$("CAPT_PER_PRICEA_VIEW").value = $("PER_PRICE_VIEW").value;
			$("CAPT_TOTAL_PRICEA_VIEW").value = $("TOTAL_PRICE_VIEW").value;
			$("CAPT_AVG_PRICEA_VIEW").value = $("AVG_PRICE_VIEW").value;
			$("CAPT_PARK_SPACEA_VIEW").value = $("PARK_SPACEB_VIEW").value;
			
			$$('#gridK1 input').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				var index = record.id.substring(record.id.lastIndexOf('_')+1);
				if(!isNaN(index)){
					if(id=='EACH_PRICE'){
						$("CAPT_"+record.id).value = record.value;
					}
				}
			});
			
			$$('#gridL1 input','#gridL1 select').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				var index = record.id.substring(record.id.lastIndexOf('_')+1);
				if(!isNaN(index)){
					if(id=='gridL1_PARK_TYPE_VIEW' || id=='gridL1_PARK_NUM_VIEW' || id=='gridL1_PARK_AMT_VIEW'){
						$(record.id.replace('gridL1','gridO1_CAPT')).value = record.value;
					} else {	
						$(record.id.replace('gridL1','gridO1')).value = record.value;
					}
				}
			});
			
			
		} else if ('0'==$("CAPT_EXAM_VIEW").value){
			$('CAPT_EXAM_DESC_VIEW').value = '';
			$w('CAPT_LAND_PRICEA_VIEW CAPT_BUILD_PRICEA_VIEW CAPT_PARK_PRICEA_VIEW CAPT_PARK_NUMA_VIEW CAPT_PER_PRICEA_VIEW CAPT_TOTAL_PRICEA_VIEW CAPT_AVG_PRICEA_VIEW CAPT_PARK_SPACEA_VIEW CAPT_LAND_PRICEB_VIEW CAPT_BUILD_PRICEB_VIEW CAPT_PARK_PRICEB_VIEW CAPT_PARK_NUMB_VIEW CAPT_PER_PRICEB_VIEW CAPT_TOTAL_PRICEB_VIEW CAPT_AVG_PRICEB_VIEW CAPT_PARK_SPACEB_VIEW').each( 
				function(col){
					$(col).value = '0';
				}
			);
			
			$$('#gridN1 input').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				if(id=='CAPT_EACH_PRICE'){
					$(record).value = '0';
				}
			});
			
			appendGridtoList(A217List, 'gridO1');
		}
	}
	
	function changeAPPEARANCE_PIC_REASON_VIEW(){
		if('1'==$("APPEARANCE_PIC_REASON_VIEW").value){ //新拍攝
			//buttons.doGetPicAlbum();
			buttons.doGetApprDept();
			$('FOLLOW_NUMBER_VIEW').value = "";//沿用編號:清空
			$('APPEARANCE_PIC_DATE_VIEW').value = ""; //外觀照日期:清空
		}
		if('2'==$("APPEARANCE_PIC_REASON_VIEW").value){ //新拍攝
			buttons.doGetAPPEARANCE_PIC_REASON_VIEW_02();

		}
	}
	
	function noNull(v){
		if(v==undefined || v==null){
			v='';
		}
		if(typeof(v)=='string'){
			v = v.trim();
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
	
	
	function changeBOSS_EXAM_VIEW(){
	
		//選擇“如擬”
		if('1'==$("BOSS_EXAM_VIEW").value){
		
			//有組長覆核資料:把畫面上組長批示資料帶到主管批示
			if ((''!=$("CAPT_EXAM_VIEW").value &&'0'!=$("CAPT_EXAM_VIEW").value) || ''!=$("CAPT_EXAM_DESC_VIEW").value){
				
				$("BOSS_LAND_PRICEA_VIEW").value = $("CAPT_LAND_PRICEA_VIEW").value;
				$("BOSS_BUILD_PRICEA_VIEW").value = $("CAPT_BUILD_PRICEA_VIEW").value;
				$("BOSS_PARK_PRICEA_VIEW").value = $("CAPT_PARK_PRICEA_VIEW").value;
				$("BOSS_PARK_NUMA_VIEW").value = $("CAPT_PARK_NUMA_VIEW").value;
				$("BOSS_PER_PRICEA_VIEW").value = $("CAPT_PER_PRICEA_VIEW").value;
				$("BOSS_TOTAL_PRICEA_VIEW").value = $("CAPT_TOTAL_PRICEA_VIEW").value;
				$("BOSS_AVG_PRICEA_VIEW").value = $("CAPT_AVG_PRICEA_VIEW").value;
				$("BOSS_PARK_SPACEA_VIEW").value = $("CAPT_PARK_SPACEA_VIEW").value;
				
				$("BOSS_LAND_PRICEB_VIEW").value = $("CAPT_LAND_PRICEB_VIEW").value;
				$("BOSS_BUILD_PRICEB_VIEW").value = $("CAPT_BUILD_PRICEB_VIEW").value;
				$("BOSS_PARK_PRICEB_VIEW").value = $("CAPT_PARK_PRICEB_VIEW").value;
				$("BOSS_PARK_NUMB_VIEW").value = $("CAPT_PARK_NUMB_VIEW").value;
				$("BOSS_PER_PRICEB_VIEW").value = $("CAPT_PER_PRICEB_VIEW").value;
				$("BOSS_TOTAL_PRICEB_VIEW").value = $("CAPT_TOTAL_PRICEB_VIEW").value;
				$("BOSS_AVG_PRICEB_VIEW").value = $("CAPT_AVG_PRICEB_VIEW").value;
				$("BOSS_PARK_SPACEB_VIEW").value = $("CAPT_PARK_SPACEB_VIEW").value;
				
				$$('#gridN1 input').each(function(record){
					var id = record.id.substring(0,record.id.lastIndexOf('_'));
					var index = record.id.substring(record.id.lastIndexOf('_')+1);
					if(!isNaN(index)){
						if(id=='CAPT_EACH_PRICE'){
							$("BOSS_EACH_PRICE_"+index).value = record.value;
						}
					}
				});
				
				$$('#gridO1 input','#gridO1 select').each(function(record){
					var id = record.id.substring(0,record.id.lastIndexOf('_'));
					var index = record.id.substring(record.id.lastIndexOf('_')+1);
					if(!isNaN(index)){
						if(id=='gridO1_CAPT_PARK_TYPE_VIEW' || id=='gridO1_CAPT_PARK_NUM_VIEW' || id=='gridO1_CAPT_PARK_AMT_VIEW'){
							$(record.id.replace('CAPT_','BOSS_')).value = record.value;
						}
					}
				});

				 
			} else {
				$("BOSS_LAND_PRICEA_VIEW").value = $("LAND_PRICEA_VIEW").value;
				$("BOSS_BUILD_PRICEA_VIEW").value = $("BUILD_PRICEA_VIEW").value;
				$("BOSS_PARK_PRICEA_VIEW").value = $("PARK_AMT_VIEW_1").value;
				$("BOSS_PARK_NUMA_VIEW").value = $("PARK_NUM_VIEW_1").value;
				$("BOSS_PER_PRICEA_VIEW").value = $("PER_PRICE_VIEW").value;
				$("BOSS_TOTAL_PRICEA_VIEW").value = $("TOTAL_PRICE_VIEW").value;
				$("BOSS_AVG_PRICEA_VIEW").value = $("AVG_PRICE_VIEW").value;
				$("BOSS_PARK_SPACEA_VIEW").value = $("PARK_SPACEB_VIEW").value;
				
				$$('#gridK1 input').each(function(record){
					var id = record.id.substring(0,record.id.lastIndexOf('_'));
					var index = record.id.substring(record.id.lastIndexOf('_')+1);
					if(!isNaN(index)){
						if(id=='EACH_PRICE'){
							$("BOSS_"+record.id).value = record.value;
						}
					}
				});
				
				$$('#gridL1 input','#gridL1 select').each(function(record){
					var id = record.id.substring(0,record.id.lastIndexOf('_'));
					var index = record.id.substring(record.id.lastIndexOf('_')+1);
					if(!isNaN(index)){
						if(id=='gridL1_PARK_TYPE_VIEW' || id=='gridL1_PARK_NUM_VIEW' || id=='gridL1_PARK_AMT_VIEW'){
							$(record.id.replace('gridL1','gridO1_BOSS')).value = record.value;
						} else {	
							$(record.id.replace('gridL1','gridO1')).value = record.value;
						}
					}
				});
			}
			
		} else if ('0'==$("BOSS_EXAM_VIEW").value){
			$('BOSS_EXAM_DESC_VIEW').value = '';
			$w('BOSS_LAND_PRICEA_VIEW BOSS_BUILD_PRICEA_VIEW BOSS_PARK_PRICEA_VIEW BOSS_PARK_NUMA_VIEW BOSS_PER_PRICEA_VIEW BOSS_TOTAL_PRICEA_VIEW BOSS_AVG_PRICEA_VIEW BOSS_PARK_SPACEA_VIEW  BOSS_LAND_PRICEB_VIEW BOSS_BUILD_PRICEB_VIEW BOSS_PARK_PRICEB_VIEW BOSS_PARK_NUMB_VIEW BOSS_PER_PRICEB_VIEW BOSS_TOTAL_PRICEB_VIEW BOSS_AVG_PRICEB_VIEW BOSS_PARK_SPACEB_VIEW').each( 
				function(col){
					$(col).value = '0';
				}
			);
			
			$$('#gridN1 input').each(function(record){
				var id = record.id.substring(0,record.id.lastIndexOf('_'));
				if(id=='BOSS_EACH_PRICE'){
					$(record).value = '0';
				}
			});
			
			appendGridtoList(A217List, 'gridO1');
		}
	}
	
	//資料來源
	function initREF_SRC_LIST(node) {
       <c:forEach var="map" items="${REF_SRC_LIST}">
			var elOptNew = document.createElement('option');
			elOptNew.text =  '${map.value}';
			elOptNew.value = '${map.key}';
			node.add(elOptNew);
       </c:forEach>
	}
	
	//使用性質
	function initUSE_TYPE_LIST(node) {
       <c:forEach var="map" items="${USE_TYPE_LIST}">
			var elOptNew = document.createElement('option');
			elOptNew.text =  '${map.value}';
			elOptNew.value = '${map.key}';
			node.add(elOptNew);
       </c:forEach>
	}
	
	//時間差異分析
	function initCOMP_LEVEL2_LIST(node) {
       <c:forEach var="map" items="${COMP_LEVEL2_LIST}">
			var elOptNew = document.createElement('option');
			elOptNew.text =  '${map.value}';
			elOptNew.value = '${map.key}';
			node.add(elOptNew);
       </c:forEach>
	}
	
	//項目1差異分析
	function initCOMP_LEVEL1_LIST(node) {
       <c:forEach var="map" items="${COMP_LEVEL1_LIST}">
			var elOptNew = document.createElement('option');
			elOptNew.text =  '${map.value}';
			elOptNew.value = '${map.key}';
			node.add(elOptNew);
       </c:forEach>
	}
	
	//項目差異分析
	function initCOMP_ITEM_LIST(node) {
       <c:forEach var="map" items="${COMP_ITEM_LIST}">
			var elOptNew = document.createElement('option');
			elOptNew.text =  '${map.value}';
			elOptNew.value = '${map.key}';
			node.add(elOptNew);
       </c:forEach>
	}

	
	var layout = {
		
		doShowdiv_I0:function(){
			
			if($('div_I0').style.display != 'none'){
				$('div_I0').style.display = 'none';
			}else{
				$('div_I0').style.display = 'block';
			}
		},
		
		doShowdiv_I1:function(){
			if($('div_I1').style.display != 'none'){
				$('div_I1').style.display = 'none';
			}else{
				$('div_I1').style.display = 'block';
			}
		},
		
		doShowdiv_I2:function(){
			if(viewMap && viewMap.BANK_CASE=='1'){
				if($('div_I2').style.display != 'none'){
					$('div_I2').style.display = 'none';
				}else{
					$('div_I2').style.display = 'block';
				}
			}else{
				return alert("此件非國泰世華件，無須輸入各筆資料");
			}
		},
		
		doShowdiv_I3:function(){
			if(viewMap && viewMap.NEW_BANK_CASE!='0'){
				if($('div_I3').style.display != 'none'){
					$('div_I3').style.display = 'none';
				}else{
					$('div_I3').style.display = 'block';
				}
			}else{
				if(viewMap && viewMap.BANK_CASE=='1'){
					return alert("非銀行新制案件，請於各擔保品鑑價中輸入車位！！");
				}else{
					return alert("此件非國泰世華件，無須輸入各筆資料");
				}
			}
		},
		
		doShowdiv_I4:function(){
			if(viewMap && viewMap.BANK_CASE=='1'){
				if($('div_I4').style.display != 'none'){
					$('div_I4').style.display = 'none';
				}else{
					$('div_I4').style.display = 'block';
				}
			}else{
				return alert("此件非國泰世華件，無須輸入各筆資料");
			}
		},
		
		doShowdiv_I5:function(){
			if(viewMap && viewMap.NEW_BANK_CASE!='0'){
				if($('div_I5').style.display != 'none'){
					$('div_I5').style.display = 'none';
				}else{
					$('div_I5').style.display = 'block';
				}
			}else{
				if(viewMap && viewMap.BANK_CASE=='1'){
					return alert("非銀行新制案件，請於各擔保品鑑價中輸入車位！！");
				}else{
					return alert("此件非國泰世華件，無須輸入各筆資料");
				}
			}
		},
		
		doShowdiv_A213BList_VIEW:function(){
	
			if($('A213BList_VIEW').style.display != 'none'){
				$('A213BList_VIEW').style.display = 'none';
			}else{
				$('A213BList_VIEW').style.display = 'block';
			}
		},
		
		doShowdiv_A213AList_VIEW:function(){
	
			if($('A213AList_VIEW').style.display != 'none'){
				$('A213AList_VIEW').style.display = 'none';
				$('A213CList_VIEW').style.display = 'none';
			}else{
				$('A213AList_VIEW').style.display = 'block';
				$('A213CList_VIEW').style.display = 'block';
			}
		},
		
		doShowdiv_A203List_VIEW:function(mover, target){
	
			if($(target+"_INPUT_DESC_VIEW_"+mover).style.display != 'none'){
				$(target+"_INPUT_DESC_VIEW_"+mover).style.display = 'none';
			}else{
				$(target+"_INPUT_DESC_VIEW_"+mover).style.display = 'block';
			}
		}
		
		
	}

	return {

		initApp : function() {

			//PageUI.createPageWithAllBodySubElement("DSA30500", "鑑價作業", "鑑價報告資料", 1);
			PageUI.createPage("DSA30500", "鑑價作業", "鑑價報告資料");
			PageUI.loadin(["form1","form2"] , 1);
			//PageUI.loadin(["table_A","table_B1","table_B2","table_C","table_D","table_E","table_F1","table_F2","table_G","table_H","table_I","table_J","table_K","table_L","table_M","table_N","table_O","table_P","table_Q"] ,1);
			
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
			
			// 20210610 價格落差原因一選單
			<c:if test='${not empty PRICE_GAP1_LIST}'>
			<%--價格落差選單--%>
			PRICE_GAP1_LIST = ${PRICE_GAP1_LIST};
			</c:if>	
			
			// 20210610 價格落差原因二選單
			<c:if test='${not empty PRICE_GAP2_LIST}'>
			<%--價格落差選單--%>
			PRICE_GAP2_LIST = ${PRICE_GAP2_LIST};
			</c:if>		
			
			// 20240625 車位價格落差原因一選單
			<c:if test='${not empty PSM_GAP1_LIST}'>
			<%--價格落差選單--%>
			PSM_GAP1_LIST = ${PSM_GAP1_LIST};
			</c:if>	
			
			// 20240625 車位價格落差原因二選單
			<c:if test='${not empty PSM_GAP2_LIST}'>
			<%--價格落差選單--%>
			PSM_GAP2_LIST = ${PSM_GAP2_LIST};
			</c:if>				
			
			gridF2 = new TableUI ( {
				table: $("gridF2"), pageSize: 10, allSortable:false, overDiv:false,
				column:[
					{header: "項目",key: "COMP_ITEM",
						input:{
							type:'select',
							actionWhenStart:true,
							action : function( node , dataObj , textDiv, record, isOnChange){
								if(!isOnChange){
									initCOMP_ITEM_LIST(node);
									//設定預設值
									if(dataObj[0]['COMP_ITEM']) {
										node.value = dataObj[0]['COMP_ITEM'];
									}
									node.id = 'COMP_ITEM_' + dataObj[0]["SEQ_NO"];
									node.APPLY_ID = dataObj[0]["APPLY_ID"];
									node.SEQ_NO = dataObj[0]["SEQ_NO"];
									node.disabled = true;
								}
								dataObj[0]["COMP_ITEM"] = (node.value ? node.value : "");
							},
							genRule:function(record , value){
								return true;
							}
						}
					},
					{header: "標的",key: "BUILD1",
						input:{
							type:'select',
							actionWhenStart:true,
							action : function( node , dataObj , textDiv, record, isOnChange){
								if(!isOnChange){
									initCOMP_LEVEL2_LIST(node);
									//設定預設值
									if(dataObj[0]['BUILD1']) {
										node.value = dataObj[0]['BUILD1'];
									}
									node.id = 'BUILD1_' + dataObj[0]["SEQ_NO"]; 
									node.disabled = true;
								}
								dataObj[0]["BUILD1"] = (node.value ? node.value : "");
							},
							genRule:function(record , value){
								return true;
							}
						}
					},
					{header: "比較符號",key: "OP1",
						input:{
							type:'select',
							actionWhenStart:true,
							action : function( node , dataObj , textDiv, record, isOnChange){
								if(!isOnChange){
									initCOMP_LEVEL2_LIST(node);
									//設定預設值
									if(dataObj[0]['OP1']) {
										node.value = dataObj[0]['OP1'];
									}
									node.id = 'OP1_' + dataObj[0]["SEQ_NO"]; 
									node.disabled = true;
								}
								dataObj[0]["OP1"] = (node.value ? node.value : "");
							},
							genRule:function(record , value){
								return true;
							}
						}
					},
					{header: "標的",key: "BUILD2",
						input:{
							type:'select',
							actionWhenStart:true,
							action : function( node , dataObj , textDiv, record, isOnChange){
								if(!isOnChange){
									initCOMP_LEVEL2_LIST(node);
									//設定預設值
									if(dataObj[0]['BUILD2']) {
										node.value = dataObj[0]['BUILD2'];
									}
									node.id = 'BUILD2_' + dataObj[0]["SEQ_NO"]; 
									node.disabled = true;
								}
								dataObj[0]["BUILD2"] = (node.value ? node.value : "");
							},
							genRule:function(record , value){
								return true;
							}
						}
					},
					{header: "比較符號",key: "OP2",
						input:{
							type:'select',
							actionWhenStart:true,
							action : function( node , dataObj , textDiv, record, isOnChange){
								if(!isOnChange){
									initCOMP_LEVEL2_LIST(node);
									//設定預設值
									if(dataObj[0]['OP2']) {
										node.value = dataObj[0]['OP2'];
									}
									node.id = 'OP2_' + dataObj[0]["SEQ_NO"]; 
									node.disabled = true;
								}
								dataObj[0]["OP2"] = (node.value ? node.value : "");
							},
							genRule:function(record , value){
								return true;
							}
						}
					},
					{header: "標的",key: "BUILD3",
						input:{
							type:'select',
							actionWhenStart:true,
							action : function( node , dataObj , textDiv, record, isOnChange){
								if(!isOnChange){
									initCOMP_LEVEL2_LIST(node);
									//設定預設值
									if(dataObj[0]['BUILD3']) {
										node.value = dataObj[0]['BUILD3'];
									}
									node.id = 'BUILD3_' + dataObj[0]["SEQ_NO"]; 
									node.disabled = true;
								}
								dataObj[0]["BUILD3"] = (node.value ? node.value : "");
							},
							genRule:function(record , value){
								return true;
							}
						}
					},
					{header: "比較符號",key: "OP3",
						input:{
							type:'select',
							actionWhenStart:true,
							action : function( node , dataObj , textDiv, record, isOnChange){
								if(!isOnChange){
									initCOMP_LEVEL2_LIST(node);
									//設定預設值
									if(dataObj[0]['OP3']) {
										node.value = dataObj[0]['OP3'];
									}
									node.id = 'OP3_' + dataObj[0]["SEQ_NO"]; 
									node.disabled = true;
								}
								dataObj[0]["OP3"] = (node.value ? node.value : "");
							},
							genRule:function(record , value){
								return true;
							}
						}
					},
					{header: "標的",key: "BUILD4",
						input:{
							type:'select',
							actionWhenStart:true,
							action : function( node , dataObj , textDiv, record, isOnChange){
								if(!isOnChange){
									initCOMP_LEVEL2_LIST(node);
									//設定預設值
									if(dataObj[0]['BUILD4']) {
										node.value = dataObj[0]['BUILD4'];
									}
									node.id = 'BUILD4_' + dataObj[0]["SEQ_NO"]; 
									node.disabled = true;
								}
								dataObj[0]["BUILD4"] = (node.value ? node.value : "");
							},
							genRule:function(record , value){
								return true;
							}
						}
					},
					{header: "比較符號",key: "OP4",
						input:{
							type:'select',
							actionWhenStart:true,
							action : function( node , dataObj , textDiv, record, isOnChange){
								if(!isOnChange){
									initCOMP_LEVEL2_LIST(node);
									//設定預設值
									if(dataObj[0]['OP4']) {
										node.value = dataObj[0]['OP4'];
									}
									node.id = 'OP4_' + dataObj[0]["SEQ_NO"]; 
									node.disabled = true;
								}
								dataObj[0]["OP4"] = (node.value ? node.value : "");
							},
							genRule:function(record , value){
								return true;
							}
						}
					},
					{header: "標的",key: "BUILD5",
						input:{
							type:'select',
							actionWhenStart:true,
							action : function( node , dataObj , textDiv, record, isOnChange){
								if(!isOnChange){
									initCOMP_LEVEL2_LIST(node);
									//設定預設值
									if(dataObj[0]['BUILD5']) {
										node.value = dataObj[0]['BUILD5'];
									}
									node.id = 'BUILD5_' + dataObj[0]["SEQ_NO"]; 
									node.disabled = true;
								}
								dataObj[0]["BUILD5"] = (node.value ? node.value : "");
							},
							genRule:function(record , value){
								return true;
							}
						}
					}
				],pageChange:function(pageNo){ 
					autoFormatToNumber();
				}
				
			});
					
			gridJ1 = new TableUI ( {
				table: $("gridJ1"), pageSize: 5, allSortable:true,
				split: ['BUILD_MEASURE'],
				column:[
					{header: "受理編號",key: "APPLY_ID", attrs:{ rowSpan:2 },
						render : function(rec , val){
							return val ? val :'';
						}
					},
					{header: "地址 ",key: "CITY", attrs:{ rowSpan:2 }, styles:{'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						render : function(rec , val){
							var v1 = rec.CITY ? rec.CITY : '';
							var v2 = rec.ADDR_NO ? rec.ADDR_NO : '';
							return v1 + v2;
						}
					},
					{header: "地坪",key: "LAND_MEASURE",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) :'';
						}
					},
					{header: "屋齡",key: "BUILD_AGE",
						render : function(rec , val){
							return val ? val+'年' :'';
						}
					},
					{header: "單價",key: "BOSS_PER_PRICEA",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) :'';
						}
					},
					{header: "總價",key: "BOSS_TOTAL_PRICEA",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) :'';
						}
					},
					{header: "總樓層",key: "FLOOR", attrs:{ rowSpan:2 },
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) :'';
						}
					},					
					{header: "建築完成日期",key: "FINISH_DATE",
						render : function(rec , val){
							return val ? Date.toROC(val) :'';
						}						
					},
					{header: "類別",key: "USE_FOR_NM",
						render : function(rec , val){
							return val ? val :'';
						}
					},	
					{header: "建坪",key: "BUILD_MEASURE",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) :'';
						}
					},
					{header: "車位價",key: "BOSS_PARK_PRICEA",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) :'';
						}
					},
					{header: "地價",key: "BOSS_LAND_PRICEA",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) :'';
						}
					},
					{header: "均價",key: "AVG_PRICE",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) :'';
						}
					},
					{header: "鑑估日期",key: "APPR_DATE",
						render : function(rec , val){
							return val ? Date.toROC(val) :'';
						}
					},
					{header: "案名",key: "CASE_NAME",
						render : function(rec , val){
							return val ? val :'';
						}
					}
				]
				
			});
			
			gridK1 = new TableUI ( {
				table: $("gridK1"), allSortable:false, overDiv:false, pageSize:0,
				column:[
					{header: "擔保品地址",key: "ADDR_NO",styles:{'whiteSpace':'pre','width':'400px', 'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						render : function(rec , val){
							var v1 = rec.ADDR_NO ? rec.ADDR_NO : '';
							var v2 = rec.BUILD_NO1 ? rec.BUILD_NO1 : '';
							var v3 = rec.BUILD_NO2 ? rec.BUILD_NO2 : '';
							var v4 = rec.TYPE ? rec.TYPE : '';
							var v5 = rec.MEASURE ? rec.MEASURE : '';
							if(chkTRADE_AMT>1 && [1,3,4,5,6].include(APPR_PROCESS)){
								//20210617 擔保品地址改成超連結，顯示買賣件合理議價區間不符原因
								var div = new Element('div');
								var link = new Element('a', { href : '#' });
								link.update( v1 );	
								link.observe('click', function(){
									alert(MISS_REASON);
								} );
								div.appendChild(link)
								var br = new Element('br');
								
								var p = new Element('p1').update( v4 + '號:' + v2 + '－' + v3 + '坪數:' + v5);
								div.appendChild(br);
								div.appendChild(p);
								return div;
							}else{
								return v1 + '<br>' + v4 + '號:' + v2 + '－' + v3 + '坪數:' + v5;
							}
						}
					},
					{header: "單價(萬/坪)",key: "EACH_PRICE", sortRule:'number', 
						input:{
							type:'TEXT',
							size:7,
							maxlength:7,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'EACH_PRICE_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("APPLY_ID",dataObj[0]["APPLY_ID"]);
									node.setAttribute("BUILD_NO1",dataObj[0]["BUILD_NO1"]);
									node.setAttribute("BUILD_NO2",dataObj[0]["BUILD_NO2"]);
								}								
							}, actionWhenStart:true
						}
					},
					{header:"合理議價區間_下限",key: "TRADE_PRICE_L", sortRule: 'number'},
					{header:"合理議價區間_上限",key: "TRADE_PRICE_H", sortRule: 'number'},					
					{header: "車位(個)",key: "PARK_NUM", sortRule:'number', 
						input:{
							type:'TEXT',
							size:3,
							maxlength:3,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'PARK_NUM_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("className" , "required");
									node.setAttribute("readOnly" , true);
								}
							}, actionWhenStart:true
						}
					},
					{header: "車位坪數(坪)",key: "PARK_SPACEA", sortRule:'number', 
						input:{
							type:'TEXT',
							size:7,
							maxlength:7,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'PARK_SPACEA_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("className" , "required");
									node.setAttribute("readOnly" , true);
								}
							}, actionWhenStart:true
						}
					},
					{header: "車位均價(萬)",key: "PARK_AMT", sortRule:'number', 
						input:{
							type:'TEXT',
							size:7,
							maxlength:7,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'PARK_AMT_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("className" , "required");
									node.setAttribute("readOnly" , true);
								}
							}, actionWhenStart:true
						}
					}
				],pageChange:function(pageNo){ 
					autoFormatToNumber();
				}
				
			});
			
			gridN1 = new TableUI ( {
				table: $("gridN1"), allSortable:false, overDiv:false, pageSize:0,
				split: ['CAPT_EACH_PRICE'],
				column:[
					{header: "擔保品地址",key: "ADDR_NO", attrs:{ rowSpan:2 },styles:{'whiteSpace':'pre','width':'400px', 'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						render : function(rec , val){
							var v1 = rec.ADDR_NO ? rec.ADDR_NO : '';
							var v2 = rec.BUILD_NO1 ? rec.BUILD_NO1 : '';
							var v3 = rec.BUILD_NO2 ? rec.BUILD_NO2 : '';
							var v4 = rec.TYPE ? rec.TYPE : '';
							var v5 = rec.MEASURE ? rec.MEASURE : '';
							return v1 + '<br>' + v4 + '號:' + v2 + '－' + v3 + '坪數:' + v5;
						}
					},
					{header: "組長", attrs:{ colSpan:4 }, empty: "rowSpan_down"},
					{header: "主管", attrs:{ colSpan:4 }, empty: "rowSpan_down"},
					{header: "單價 ",key: "CAPT_EACH_PRICE", sortRule:'number', 
						input:{
							type:'TEXT',
							size:7,
							maxlength:7,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'CAPT_EACH_PRICE_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("APPLY_ID", dataObj[0]["APPLY_ID"]);
									node.setAttribute("BUILD_NO1", dataObj[0]["BUILD_NO1"]);
									node.setAttribute("BUILD_NO2", dataObj[0]["BUILD_NO2"]);
									node.setAttribute("className" , "");
								}
								if(node.value==''){
									node.value = 0;
								}
								dataObj[0]["CAPT_EACH_PRICE"] = (node.value ? node.value : "");
							}, actionWhenStart:true
						}
					},
					{header: "車位個數",key: "CAPT_PARK_NUM", sortRule:'number', 
						input:{
							type:'TEXT',
							size:3,
							maxlength:3,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'CAPT_PARK_NUM_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("className" , "");
									node.setAttribute("readOnly" , true);
								}
								if(node.value==''){
									node.value = 0;
								}
								dataObj[0]["CAPT_PARK_NUM"] = (node.value ? node.value : "");
							}, actionWhenStart:true
						}
					},
					{header: "車位面積",key: "CAPT_PARK_SPACE", sortRule:'number', 
						input:{
							type:'TEXT',
							size:7,
							maxlength:7,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'CAPT_PARK_SPACE_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("className" , "");
									node.setAttribute("readOnly" , true);
								}
								if(node.value==''){
									node.value = 0;
								}
								dataObj[0]["CAPT_PARK_SPACE"] = (node.value ? node.value : "");
							}, actionWhenStart:true
						}
					},
					{header: "車位均價",key: "CAPT_PARK_AMT", sortRule:'number', 
						input:{
							type:'TEXT',
							size:7,
							maxlength:7,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'CAPT_PARK_AMT_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("className" , "");
									node.setAttribute("readOnly" , true);
								}
								if(node.value==''){
									node.value = 0;
								}
								dataObj[0]["CAPT_PARK_AMT"] = (node.value ? node.value : "");
							}, actionWhenStart:true
						}
					},
					{header: "單價 ",key: "BOSS_EACH_PRICE", sortRule:'number', 
						input:{
							type:'TEXT',
							size:7,
							maxlength:7,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'BOSS_EACH_PRICE_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("className" , "");
								}
								if(node.value==''){
									node.value = 0;
								}
								dataObj[0]["BOSS_EACH_PRICE"] = (node.value ? node.value : "");
							}, actionWhenStart:true
						}
					},
					{header: "車位個數",key: "BOSS_PARK_NUM", sortRule:'number', 
						input:{
							type:'TEXT',
							size:3,
							maxlength:3,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'BOSS_PARK_NUM_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("className" , "");
									node.setAttribute("readOnly" , true);
								}
								if(node.value==''){
									node.value = 0;
								}
								dataObj[0]["BOSS_PARK_NUM"] = (node.value ? node.value : "");
							}, actionWhenStart:true
						}
					},
					{header: "車位面積",key: "BOSS_PARK_SPACE", sortRule:'number', 
						input:{
							type:'TEXT',
							size:7,
							maxlength:7,
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'BOSS_PARK_SPACE_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("className" , "");
									node.setAttribute("readOnly" , true);
								}
								if(node.value==''){
									node.value = 0;
								}
								dataObj[0]["BOSS_PARK_SPACE"] = (node.value ? node.value : "");
							}, actionWhenStart:true
						}
					},
					{header: "車位均價",key: "BOSS_PARK_AMT", sortRule:'number', 
						input:{
							type:'TEXT',
							size:7,
							maxlength:7,	
							genRule:function(record , value){
								return true;
							},
							action:function( node , dataObj , textDiv, orgData , isOnChange ){
								if(!isOnChange){
									node.setAttribute("datatype","number");
									node.setAttribute("pattern", defaultPattern1);
									node.setAttribute("id", 'BOSS_PARK_AMT_' + dataObj[0]["SEQ_NO"]);
									node.setAttribute("className" , "");
									node.setAttribute("readOnly" , true);
								}
								if(node.value==''){
									node.value = 0;
								}
								dataObj[0]["BOSS_PARK_AMT"] = (node.value ? node.value : "");
							}, actionWhenStart:true
						}
					}
				],pageChange:function(pageNo){ 
					autoFormatToNumber();
				}
				
			});
			
			
			gridR1 = new TableUI ( {
				table: $("gridR1"), allSortable:false, overDiv:false, pageSize:0,
				
				column:[
					//電腦作業申請書170911001823:新增簡易報告格式-評分系統改版
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
			
			gridH1 = new TableUI ( { 
				table: $("gridH1"), pageSize:0, allSortable:true, overDiv:false,
				autoCheckBox:{
					type:"checkbox"
				},
				autoCheckBox:{ 
					type:'checkbox',
					text:'選取',
					attrs:{width:"6%"} , 
					valueKey:'SUIT'
				},
				column:[
					{header: "地址 ",key: "ADDR", styles:{'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						render : function(rec , val){
							var v1 = rec.ADDR ? rec.ADDR : '';
							var v2 = rec.COMMUNITY_NAME ? "(" + rec.COMMUNITY_NAME + ")" : '';
							return v1 + v2;
						}
					},
					{header: "交易年月",key: "TRADE_YM",
						render : function(rec , val){
							return val ? val : '';
						}
					},
					{header: "屋齡",key: "HOUSE_YEAR",
						render : function(rec , val){
							return val ? val + '年' : '';
						}
					},
					{header: "樓層",key: "FLOOR",
						render : function(rec , val){
							<%--[20230503]判斷假透天--%>
							if('8' == viewMap['USE_FOR']){
								return rec.TARGET_FLOOR || '';
							}else{
								var v1 = rec.TRANS_FLOOR ? rec.TRANS_FLOOR : '';
								var v2 = rec.TOTAL_FLOOR ? rec.TOTAL_FLOOR : '';								
								return v1 + "/" + v2;
							}							
						}
					},
					{header: "總價",key: "TOTAL_PRICE",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) : '0';
						}
					},	
					{header: "建坪",key: "BUILD_AREA_ADJ",
						render : function(rec , val){
							<%--[20230503]判斷假透天--%>
							if('8' == viewMap['USE_FOR']){
								return rec.BUILD_AREA ? CSRUtil.$fmt(rec.BUILD_AREA, defaultPattern1) : '0';
							}else{
								return val ? CSRUtil.$fmt(val, defaultPattern1) : '0';
							}
						}
					},
					{header: "建坪單價",key: "BUILD_U_PRICE_ADJ",
						render : function(rec , val){
							<%--[20230503]判斷假透天--%>
							if('8' == viewMap['USE_FOR']){
								return rec.BUILD_U_PRICE ? CSRUtil.$fmt(rec.BUILD_U_PRICE, defaultPattern1) : '0';
							}else{
								return val ? CSRUtil.$fmt(val, defaultPattern1) : '0';
							}
						}
					},
					{header: "車位坪",key: "PARK_AREA",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) : '0';
						}
					},
					{header: "車位價",key: "PARK_PRICE",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) : '0';
						}
					}
				]
				
			});
			<%--[20240614]修正 the error The code of method _jspService is exceeding the 65535 bytes limit Jboss，
			 M區 grid tableui 欄位設定一樣，改用方法取得--%>
			gridM1 = new TableUI ( actions.setGridM('gridM1','自動估價建議價格') );
			gridM2 = new TableUI ( actions.setGridM('gridM2','建議案例平均價格') );
			gridM3 = new TableUI ( actions.setGridM('gridM3','社區行情價格區間') );
			gridMP = new TableUI ( actions.setGridMP('gridMP','車位模型建議總價') );<%--[20240613]車位估價紀錄 --%>
			gridMM = new TableUI ( actions.setGridM('gridMM','公寓行情價格區間') );<%--[20250211]公寓估價紀錄--%>
			//註冊DOM物件
			//click事件
			$("btn_query").observe("click", buttons.doQuery );//查詢
			
			$("btn_captainConfirm").observe("click", buttons.doCaptainConfirmCheck );//組長覆核
			$("btn_captainReject").observe("click", buttons.doCaptainReject );//組長退回
			$("btn_bossConfirm").observe("click", buttons.doBossConfirmCheck );//主管(代理)覆核
			$("btn_bossReject").observe("click", buttons.doBossReject );//主管退回
			$("btn_gmConfirm").observe("click", buttons.doGmConfirm);//部室主管覆核
			$("btn_cancelConfirm").observe("click", buttons.doCancelConfirm );//取消覆核
			$("btn_imageConfirm").observe("click", buttons.doImageConfirm );//影像確認

			$("btn_insert").observe("click", buttons.doInsert );//新增
			$("btn_update").observe("click", buttons.doUpdate );//修正
			$("btn_delete").observe("click", buttons.doDelete );//刪除
			$("btn_confirm").observe("click", buttons.doConfirmCheck );//呈核
			$("btn_cancel").observe("click", buttons.doCancel );//取消呈核
			$("btn_electronicMap").observe("click", buttons.doElectronicMap );//(1)電子地圖

			$("btn_print").observe("click", buttons.doPrint );//列印
			$("btn_Get_A213List_VIEW").observe("click", buttons.getA213List );//(2)環域分析
			$("btn_Get_A201List_VIEW").observe("click", buttons.getA201List );//(4)訪價匯入
			$("btn_Get_A216List_VIEW").observe("click", buttons.getA216List );//(3)案例建議 
			$("btn_Get_A215List_VIEW").observe("click", buttons.getA215List );//(5)自動估價 
			$("btnGenCommPrice").observe("click",buttons.getA350List);// 20210610 社區價格
			$('btnCfmComm').observe("click",buttons.doCfmComm);
			$("btn_reSend").observe("click", buttons.doReSend );//報告重送
			$("btn_linkImage").observe("click", buttons.doLinkImage );//影像連結
			$("btn_communityInsert").observe("click", buttons.doCommunityInsert );//新增社區資料
			$("btn_copyPicAlbum").observe("click", buttons.doCopyPicAlbum );//引用相簿
			$("btnLinkTo3700").observe("click", buttons.doLinkTo3700 );<%--[20250213]公寓資料庫--%>
			
			// 20210728: 鑑價科 連動 鑑價人員
			$("APPR_DEPT").observe('change', buttons.doGearing );
			//顯示隱藏
			$("A_divI0").observe("click", layout.doShowdiv_I0 );
			$("A_divI1").observe("click", layout.doShowdiv_I1 );
			$("A_divI2").observe("click", layout.doShowdiv_I2 );
			$("A_divI3").observe("click", layout.doShowdiv_I3 );
			$("A_divI4").observe("click", layout.doShowdiv_I4 );
			$("A_divI5").observe("click", layout.doShowdiv_I5 );
			
			//外觀照說明連動外觀照日期、拍照人員
			$("APPEARANCE_PIC_REASON_VIEW").observe('change',
				function(event){ 
					changeAPPEARANCE_PIC_REASON_VIEW();
					
					changeSUPPORT_ID_VIEW();
				}
			);
			
			//拍照人員清單連動拍照人員
			$("SUPPORT_ID_VIEW").observe('change',
				function(event){ 
					changeSUPPORT_ID_VIEW();
				}
			);
			
			//捷運線別連動捷運站名
			$("METRO_VIEW").observe('change',function(event){ buttons.doGetStation("METRO_VIEW"); });
			$("STATION_VIEW").observe('change',function(event){ if($('STATION_VIEW').value==''){$('BUILD_STATION_VIEW').value = '';}else{$('BUILD_STATION_VIEW').value = $('STATION_VIEW').options[$('STATION_VIEW').selectedIndex].text; }});
			$("METRO1_VIEW").observe('change',function(event){ buttons.doGetStation("METRO1_VIEW"); });
			$("STATION1_VIEW").observe('change',function(event){ if($('STATION1_VIEW').value==''){$('ROUND_STATION_VIEW').value = '';}else{$('ROUND_STATION_VIEW').value = $('STATION1_VIEW').options[$('STATION1_VIEW').selectedIndex].text; }});
			
			//公式
			$("FORMULA1_VIEW").observe('change',
				function(event){ 
					$("FORMULA_VIEW").value = $('FORMULA1_VIEW').options[$('FORMULA1_VIEW').selectedIndex].text;
					changeTOTAL_PRICE();
					changeAVG_PRICE($('TOTAL_PRICE_VIEW'), $('AVG_PRICE_VIEW'));
				}
			);
			
			//車位坪數
			$("PARK_SPACE_VIEW").observe('blur',
				function(event){
					$("PARK_SPACEB_VIEW").value = $('PARK_SPACE_VIEW').value;
					$("PARK_SPACEB1_VIEW").innerHTML = $('PARK_SPACE_VIEW').value;
				}
			);
			
			//總價
			$("TOTAL_PRICE_VIEW").observe('blur',
				function(event){
					changeAVG_PRICE($('TOTAL_PRICE_VIEW'), $('AVG_PRICE_VIEW'));
				}
			);
			 <%-- 20210617 調整鑑價報告上，建物型態與樓層輸入方式--%>
				$('FLOOR_MEMO').observe('blur', function(){
					changeBUILDTYPE()});
				$('TARGET_FLOOR').observe('blur', function(){
					changeBUILDTYPE()});
			
			//組長批示/一般行情/總價
			$("CAPT_TOTAL_PRICEA_VIEW").observe('blur',
				function(event){
					changeAVG_PRICE($('CAPT_TOTAL_PRICEA_VIEW'), $('CAPT_AVG_PRICEA_VIEW'));
				}
			);

			//組長批示/特殊行情/總價
			$("CAPT_TOTAL_PRICEB_VIEW").observe('blur',
				function(event){
					changeAVG_PRICE($('CAPT_TOTAL_PRICEB_VIEW'), $('CAPT_AVG_PRICEB_VIEW'));
				}
			);
			
			//主管批示/一般行情/總價
			$("BOSS_TOTAL_PRICEA_VIEW").observe('blur',
				function(event){
					changeAVG_PRICE($('BOSS_TOTAL_PRICEA_VIEW'), $('BOSS_AVG_PRICEA_VIEW'));
				}
			);
			
			//主管批示/特殊行情/總價
			$("BOSS_TOTAL_PRICEB_VIEW").observe('blur',
				function(event){
					changeAVG_PRICE($('BOSS_TOTAL_PRICEB_VIEW'), $('BOSS_AVG_PRICEB_VIEW'));
				}
			);	
			
			
			//組長批示
			$("CAPT_EXAM_VIEW").observe('change',
				function(event){
					changeCAPT_EXAM_VIEW();
				}
			);
			
			//主管批示
			$("BOSS_EXAM_VIEW").observe('change',
				function(event){
					changeBOSS_EXAM_VIEW();
				}
			);
			
			
			<%--新增評分--%>
			$('btn_add_1').observe('click' , doAdd1);

			//資料來源1 2 3 4 電話1 2 3 4
			$w('REF_SRC_VIEW_1 REF_SRC_VIEW_2 REF_SRC_VIEW_3 REF_SRC_VIEW_4 TIME_TEL_VIEW_1 TIME_TEL_VIEW_2 TIME_TEL_VIEW_3 TIME_TEL_VIEW_4').each(
				function(key){
					var index = key.substring(key.lastIndexOf('_')+1);
					$(key).observe('change', function(event){
						buttons.doQueryMAM003(index);
					});
				}
			);
			
			$w("LAND_PRICE_VIEW_1_btn LAND_PRICE_VIEW_2_btn LAND_PRICE_VIEW_3_btn LAND_PRICE_VIEW_4_btn PER_PRICE_VIEW_1_btn PER_PRICE_VIEW_2_btn PER_PRICE_VIEW_3_btn PER_PRICE_VIEW_4_btn").each(
				function(ele){
					$(ele).observe('click',function(event){
						buttons.doCalculatePrice(ele);
					});
				}
			);
			
			<%--[20201127]調整承作分區判斷邏輯--%>
			$w("USE_AREA1_VIEW URBAN_PROJECT").each(function(ele){
				$(ele).observe('change',function(event){
					ajaxPost('areaCode',{
						'APPLY_ID' : $F('APPLY_ID'),
						'USE_AREA1' : $F('USE_AREA1_VIEW'),
						'URBAN_PROJECT' : $F('URBAN_PROJECT'),
						'GAGE_ZIP' : $F('GAGE_ZIP')
						},
						true,
						function(resp){
							var areaCodeMap = resp.areaCodeMap||{};
							var AREA_CODE_930318 = areaCodeMap.AREA_CODE_930318||'';
							$('AREA_CODE_VIEW').update(areaCodeMap.AREA_CODE_NM+'區');
							$('AREA_CODE_930318').setValue(AREA_CODE_930318);
							$('CONTRACT_AREA_VIEW').setValue(areaCodeMap.CONTRACT_AREA);
						}
					);
				});
			});
			
			initValidation();	
			buttons.suggestALL();
			buttonAuth();
			<%--[20211018] 使用 InputUtility.js 調整成讓 CHORME textarea也能依照內容自動調整欄位高度--%>
			$$('textarea').each(function(e){	
				InputUtility.autoSizingTextarea.add(e); //註冊事件
			});

			if ('${APPLY_ID}' == '') {
				//保留參數管理-取得受理編號
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			} else {
				$('APPLY_ID').value = '${APPLY_ID}';
			} 

			var isShow_btn_print = false;

			if($('APPLY_ID').value!=''){
				var isbeanName = 'DSA3_2400'=='${fromPublicBean}' ? true : false;
				if(isbeanName){			
					$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
					$('CONTRACT_AREA_VIEW').className = '';
				
					var rtnMap = <c:choose><c:when test="${not empty rtnMap}">${rtnMap}</c:when><c:otherwise>{}</c:otherwise></c:choose>;
					var A201List = <c:choose><c:when test="${not empty A201List}">${A201List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A202List = <c:choose><c:when test="${not empty A202List}">${A202List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A203List = <c:choose><c:when test="${not empty A203List}">${A203List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A205List = <c:choose><c:when test="${not empty A205List}">${A205List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A209List = <c:choose><c:when test="${not empty A209List}">${A209List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A213AList = <c:choose><c:when test="${not empty A213AList}">${A213AList}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A213BList = <c:choose><c:when test="${not empty A213BList}">${A213BList}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A213CList = <c:choose><c:when test="${not empty A213CList}">${A213CList}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A217List = <c:choose><c:when test="${not empty A217List}">${A217List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var A260List = <c:choose><c:when test="${not empty A260List}">${A260List}</c:when><c:otherwise>[]</c:otherwise></c:choose>;
					var resp = {
						'rtnMap' : rtnMap,
						'A201List' : A201List,
						'A202List' : A202List,
						'A203List' : A203List,
						'A205List' : A205List,
						'A209List' : A209List,
						'A213AList' : A213AList,
						'A213BList' : A213BList,
						'A213CList' : A213CList,
						'A217List' : A217List,
						'A260List' : A260List
					};
					isShow_btn_print = true;
					querySuccessFunction(resp);
				}else{
					buttons.doQuery();
				}
			}
			
			if('${OP}'=='1'){

				//輸入人員 or 查詢人員
				//顯示A~M區塊 
				$('table_N').style.display = 'none';
				$('table_O').style.display = 'none';
				$('table_P1').style.display = 'none';
				$('table_P').style.display = 'none';
				$('table_R').style.display = 'none';
			
				$("btn_captainConfirm").hide();//組長覆核
				$("btn_captainReject").hide();//組長退回
				$("btn_bossConfirm").hide();//科主管(代理)覆核
				$("btn_bossReject").hide();//主管退回
				$("btn_gmConfirm").hide();//部室主管(代理)覆核
				$("btn_cancelConfirm").hide();//取消覆核
				$("btn_imageConfirm").hide();//影像確認
				$("btn_reSend").hide();//報告重送
		
				$("btn_insert").show();//新增
				$("btn_update").show();//修正
				$("btn_delete").show();//刪除
				$("btn_confirm").show();//呈核
				$("btn_cancel").show();//取消呈核
				$("btn_electronicMap").show();//(1)電子地圖
				$("btn_linkImage").show();//影像連結
		
				$w("LAND_PRICE_VIEW_1_btn LAND_PRICE_VIEW_2_btn LAND_PRICE_VIEW_3_btn LAND_PRICE_VIEW_4_btn PER_PRICE_VIEW_1_btn PER_PRICE_VIEW_2_btn PER_PRICE_VIEW_3_btn PER_PRICE_VIEW_4_btn").each(function(ele){
					$(ele).show();
				});
			
			}else{

				//覆核人員
				//A~Q區塊
				//[20201130]block改成''解chrome table長不滿問題
				$('table_N').style.display = '';
				$('table_O').style.display = '';
				$('table_P').style.display = '';
				$('table_P1').style.display = '';
				//$('table_Q').style.display = 'block';//20141008
				$('table_R').style.display = '';
				
				$("btn_captainConfirm").show();//組長覆核
				$("btn_captainReject").show();//組長退回
				$("btn_bossConfirm").show();//科主管(代理)覆核
				$("btn_bossReject").show();//主管退回
				$("btn_gmConfirm").show();//部室主管覆核
				$("btn_cancelConfirm").show();//取消覆核
				$("btn_imageConfirm").show();//影像確認
				$("btn_reSend").show();//報告重送
				$("btn_electronicMap").show();//(1)電子地圖
				$("btn_linkImage").show();//影像連結
				
				$("btn_insert").hide();//新增
				$("btn_update").hide();//修正
				$("btn_delete").hide();//刪除
				$("btn_confirm").hide();//呈核 
				$("btn_cancel").hide();//取消呈核 
				
				$w("LAND_PRICE_VIEW_1_btn LAND_PRICE_VIEW_2_btn LAND_PRICE_VIEW_3_btn LAND_PRICE_VIEW_4_btn PER_PRICE_VIEW_1_btn PER_PRICE_VIEW_2_btn PER_PRICE_VIEW_3_btn PER_PRICE_VIEW_4_btn").each(function(ele){
					$(ele).hide();
				});
			}
	
			//銀行人員：按鈕、Q區不顯示
			if (${IS_BANK_USER}){
				$('APPLY_ID').readOnly = true;
				//$('table_Q').style.display = 'none';//20141008
				$('table_R').style.display = 'none';
				$('img_getfile').hide();
				$('img_LinkToDSA3_0900').hide();
				$$('input[type="button"]').each( 
					function(elem) {
						if(isShow_btn_print && elem.id=='btn_print'){
							return;
						}
						elem.hide();
					}
				);
				//[20201203] 開放銀行人員可以查詢電子地圖
				$("btn_electronicMap").show();//(1)電子地圖
			}
			
			//非鑑價角色不顯示AVM區
			<c:if test="${showAVM ne true}">
				$('table_H1').style.display = 'none';
				$('table_M1').style.display = 'none';
				$('table_M2').style.display = 'none';
				$('table_M3').style.display = 'none';
				$('table_MP').style.display = 'none';<%--[20240613]車位模型價格落差原因區塊--%>
				$('table_MM').style.display = 'none';<%--[20250211]公寓估價紀錄--%>
			</c:if>
			
			<%-- [20230131]需求書230131003715 非放款鑑價部人員無法瀏覽相關欄位資訊--%>
			<c:if test="${showEXAM ne true}">
				$('table_P1').style.display = 'none';
			</c:if>
			
			<%-- [20210712] 當C區 特殊擔保品選項選取後，判斷：若是「裡地」(18)：顯示現況出入無虞欄位資料；若否，則不顯示 (連動的概念) --%>
			$('SPC_GAGE_OPT_VIEW').observe('change',function(){
			    if('18' == $F('SPC_GAGE_OPT_VIEW')){
			    	<%-- 如果原本查詢結果為裡地(18)，就把查詢結果的值放回去 --%>
			    	if ($F('SPC_GAGE_TYPE_hidden') == 'Y') {
			    		$('SPC_GAGE_TYPE_Y').checked = true;
			    	} else if ($F('SPC_GAGE_TYPE_hidden') == 'N') {
			    		$('SPC_GAGE_TYPE_N').checked = true;
			    	}
			    	$('SPC_GAGE_TYPE_NM').style.display = 'inline-block';
			    }else{
			    	<%-- 非裡地(18)時，現況出入無虞沒有值 --%>
			    	$('SPC_GAGE_TYPE_Y').setValue('');
			    	$('SPC_GAGE_TYPE_N').setValue('');
			    	$('SPC_GAGE_TYPE_NM').style.display = 'none';
			    }
			 });
			<%--[20230201] 新增分級項下拉選單，針對選擇【飯店旅館】、【商場】提示使用者必須選擇A、B；【其他】時，提示使用者必須選擇A、B、C --%>
			$('USE_FOR_VIEW').observe('change', buttons.setSelectOption);
			//日期欄處理
			autoFormatToDate();
			autoFormatToNumber();

			$$('#form1','#form2').each(function(e){e.show();});

			displayMessage();				

		},
		addRows : addRows,
		removeRows : removeRows,
		changePARK_AMT : changePARK_AMT,
		changeAVG_PRICE : changeAVG_PRICE,
		changeTOTAL_PRICE : changeTOTAL_PRICE,
		changeAPPEARANCE_PIC_REASON_VIEW : changeAPPEARANCE_PIC_REASON_VIEW,
		doShowdiv_A203List_VIEW : layout.doShowdiv_A203List_VIEW,
		changeGetMinus : buttons.changeGetMinus,
		doGetFile : buttons.doGetFile, 
		doLinkToDSA3_0900 : buttons.doLinkToDSA3_0900,
		doCaptainConfirm : buttons.doCaptainConfirmCheck,
		doCaptainReject : buttons.doCaptainReject,
		doBossConfirm : buttons.doBossConfirmCheck,
		doGmConfirm : buttons.doGmConfirm,
		doBossReject : buttons.doBossReject,
		doCancelConfirm : buttons.doCancelConfirm,
		doImageConfirm : buttons.doImageConfirm,
		doInsert : buttons.doInsert,
		doUpdate : buttons.doUpdate,
		doDelete : buttons.doDelete,
		doConfirm : buttons.doConfirmCheck,
		doCancel : buttons.doCancel,
		doElectronicMap : buttons.doElectronicMap,
		doCopyPicAlbum : buttons.doCopyPicAlbum,
		//doGetPicAlbum : buttons.doGetPicAlbum
	};	
};

</script>

</head>
<body>
<!-- A區 -->
<form id="form1" name="form1"> <!--  style="display:none">-->
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table_A">
		<tr>
			<td class="tbYellow" width="10%" align="left">受理編號</td>
			<td class="tbYellow2" width="20%">
				<input id="APPLY_ID" name="APPLY_ID" type="text" class="text2" size="12" maxLength="11" value="${param.APPLY_ID}"/>
				<input id="encryptAPPLY_ID" name="encryptAPPLY_ID" type="hidden" value="${encryptAPPLY_ID}"/>
				<input type="hidden" id="BORROW_ID" name="BORROW_ID" value="">
				<input type="hidden" id="FINISH_DATE" name="FINISH_DATE" value="">
				<input type="hidden" id="LONGITUDE" name="LONGITUDE" value="">
				<input type="hidden" id="LATITUDE" name="LATITUDE" value="">
				<input type="hidden" id="LAND_MEASURE" name="LAND_MEASURE" value="">
				<input type="hidden" id="BUILD_MEASURE" name="BUILD_MEASURE" value="">
				<input type="hidden" id="BUILD_AGE" name="BUILD_AGE" value="">
				<input type="hidden" id="INPUT_DATE" name="INPUT_DATE"  value="">
				<input type="hidden" id="PIC_CASE_NAME" name="PIC_CASE_NAME"  value="">
				<input type="hidden" id="MAP_AREA_CODE" name="MAP_AREA_CODE"  value="">
			</td>
			<td class="tbYellow2" align="center">
				<input id="btn_query" type="button" class="button" value="查詢" /> 
				<input id="btn_print" type="button" class="button" value="列印" />
				<input id="btn_electronicMap" type="button" class="button" value="(1)電子地圖">
				<input id="btn_linkImage" type="button" class="button" value="影像連結">
				<%--[20201127] 調整承作分區判斷邏輯新增承作分區、擔保品郵遞區號欄位--%> 
				<input type="hidden" id="AREA_CODE_930318" name="AREA_CODE_930318" value=""> 
				<input type="hidden" id="GAGE_ZIP" name="GAGE_ZIP" value="">
			</td>
		</tr>
		<tr>
			<td align="center" colspan="3">
				<input id="btn_captainConfirm" type="button" class="button" value="組長覆核"> 
				<input id="btn_captainReject" type="button" class="button" value="組長退回">
				<input id="btn_bossConfirm" type="button" class="button" value="科主管(代理)覆核"> 
				<input id="btn_gmConfirm" type="button" class="button" value="部室主管覆核">
				<input id="btn_bossReject" type="button" class="button" value="主管退回"> 
				<input id="btn_cancelConfirm" type="button" class="button" value="取消覆核"> 
				<input id="btn_imageConfirm" type="button" class="button" value="影像確認">
				<input id="btn_reSend" type="button" class="button" value="報告重送">
				
				<input id="btn_insert" type="button" class="button" value="新增">
				<input id="btn_update" type="button" class="button" value="修正">
				<input id="btn_delete" type="button" class="button" value="刪除">
				<input id="btn_confirm" type="button" class="button" value="呈核">
				<input id="btn_cancel" type="button" class="button" value="取消呈核">
				<img id="img_getfile" style="cursor: hand;" src="<%=imageBase%>/DS/star5.gif" border=0 onClick="DSA30500.doGetFile()">
			</td>
		</tr>
	</table>
</form>
<!-- A區 -->
<!-- B區 -->
<form id="form2" name="form2">
	<table class="tbBox2" cellspacing="1" style="width: 100%; border: 0;" id="table_B1">
		<tr>
			<td class="tbYellow" width="10%">受理進度</td>
			<td class="tbYellow2" width="10%" id="APPLY_PROCESS_NM_VIEW"></td>
			<td class="tbYellow" width="10%">承作分區</td>
			<td class="tbYellow2" width="10%" id="AREA_CODE_VIEW" ></td>
			<td class="tbYellow" width="10%">目前呈核進度</td>
			<td class="tbYellow2" width="10%" id="APPR_PROCESS_VIEW"></td>
			<td class="tbYellow" width="10%">影像上傳日期</td>
			<td class="tbYellow2" width="30%" id="UPLOAD_DATE_VIEW"></td>
		</tr>
		<tr>
			<td class="tbYellow">輸入人員</td>
			<td class="tbYellow2" id="INPUT_NAME_VIEW" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			<td class="tbYellow">輸入日期</td>
			<td class="tbYellow2" id="INPUT_DATE_VIEW"></td>			
			<td class="tbYellow">鑑價人員</td>
			<td class="tbYellow2" id="APPR_NM_VIEW" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			<td class="tbYellow">代理人</td>
			<td class="tbYellow2" id="AGENCY_NAME_VIEW" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
		</tr>
		
	</table>
	<table class="tbBox2" cellspacing="1" style="width: 100%; border: 0;" id="table_B2">
		<tr>
			<td class="tbYellow" width="10%">借款人</td>
			<td class="tbYellow2" width="10%" id="BORROW_NAME_VIEW" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			<%-- 20210617 調整鑑價報告上，建物型態與樓層輸入方式--%>
			<td class="tbYellow" width="10%">所在樓層</td>
			<td class="tbYellow2" width="10%" >
				<input type="text" id="TARGET_FLOOR"  style="width: 5em" value="">樓
				<input type="hidden" id="TOTAL_FLOOR"  value="">
			</td>
			<%-- 20210702  調整鑑價報告上，所在樓層版面調整--%>
			<td class="tbYellow" width="10%">樓層備註</td>
			<td class="tbYellow2" width="10%" >
				<input type="text" id="FLOOR_MEMO" size="6" value="">
			</td>
			<td class="tbYellow" width="10%">建築型態</td>
			<td class="tbYellow2"  width="30%" nowrap>
				<input type="text" class="textBox2 checkInputLength" fieldName="建築型態"  maxLength="10"  id="BUILD_TYPE_VIEW" readonly> 
				<select id="USE_FOR_VIEW">
			       	<c:forEach var="map" items="${USE_FOR_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				<select id="GRADING_ITEM_VIEW">
			       	<c:forEach var="map" items="${GRADING_ITEM_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				<select id="BASEMENT_FLOOR_VIEW">
			       	<c:forEach var="map" items="${BASEMENT_FLOOR_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>		
		</tr>
		<tr>
			<td class="tbYellow">擔保品地址</td>
			<td class="tbYellow2" colspan="5">
				<span id="GAGE_ADDR_VIEW" style="font-family:'EUDC'"></span><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				<img id="img_LinkToDSA3_0900" style="cursor: hand;" src="<%=imageBase%>/DS/cup.gif" border=0 onClick="DSA30500.doLinkToDSA3_0900()">
			</td>
			<td class="tbYellow">價量燈號</td>
			<td class="tbYellow2"colspan="3">
				<span id="LIGHT_VIEW"></span>
			</td>	
		</tr>
		<tr>
			<td class="tbYellow"  width="10%">地坪</td>
			<td class="tbYellow2"  width="10%" id="A040_LAND_SPACE_VIEW"></td>
			<td class="tbYellow"  width="10%">建坪</td>
			<td class="tbYellow2" width="10%" id="A050_BUILD_SPACE_VIEW"></td>
			<td class="tbYellow" width="10%" >屋齡</td>
			<td class="tbYellow2" width="10%" id="BUILD_AGE_VIEW"></td>
			<td class="tbYellow"  width="10%">使用分區</td>
			<td class="tbYellow2"  colspan="3"nowrap>
				<select id="USE_AREA1_VIEW" fieldName="使用分區">
			       	<c:forEach var="map" items="${USE_AREA1_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select> 
				<input type="text" class="textBox2 checkInputLength" size="10" maxLength="10" value="" id="USE_AREA2_VIEW">
			</td>
		</tr>
		<%--[20201127] 調整承作分區判斷邏輯-新增都市規劃案下拉選單--%>
		<tr>
			<td class="tbYellow">都市計畫案</td>
			<td class="tbYellow2">
				<select id="URBAN_PROJECT" name="URBAN_PROJECT" fieldName="都市計畫案">		
					<option value="">無</option>					
				</select>
			</td>
			<td class="tbYellow">生活圈</td>
			<td class="tbYellow2" colspan="3">
				<input type="text" id="SUBMKT_NAME" readonly size="42"></input>
				<input type="hidden" id="SUBMKT_ID"></input>
				<input type="hidden" id="SUBMKT_VERSION"></input>
				<input type="hidden" id="AREA_CODE_MATCH_LEVEL"></input>
			</td>
			<td class="tbYellow">承作區</td>
			<td class="tbYellow2" colspan="3">
				<select id="CONTRACT_AREA_VIEW" disabled>
					<%--[20201127] 調整承作分區判斷邏輯-承作區Disabled--%>
					<option value=''></option>
			       	<c:forEach var="map" items="${CONTRACT_AREA_LIST}">
						<option value="${map.key}" <c:if test="${map.key eq 0}">selected</c:if>>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>	
		</tr>
	</table>
<!-- B區 -->
<!-- C區 -->
	<table class="tbBox2" cellspacing="1" style="width: 100%; border: 0;" id="table_C">
		<tr class=tbYellow0 align=middle>
			<td align=middle colspan="2"><strong>一、擔保品</strong>
			<input type="button" class="button" id="btn_communityInsert" value="新增社區資料"></td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" rowspan="2">1.基本資料</td>
			<td class="tbYellow2">
				列管區 
				<select id="RESTRICT_AREA_VIEW">
			       	<c:forEach var="map" items="${RESTRICT_AREA_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>&nbsp;&nbsp;&nbsp;
				土地/建物
				<input name='IS_LAND' id = 'IS_LAND_Y' type="radio" value ='1'>有
				<input name='IS_LAND' id = 'IS_LAND_N' type="radio" value ='0'>無&nbsp;&nbsp;&nbsp;其他登記事項
				<%-- [20210712] 增加「特殊擔保品選項」與「現況出入無虞」資料。新增/修改功能，資料寫入DB --%>
				<%-- [20210712] 「特殊擔保品選項」與下一列的「買賣契約影像是/否完整」對齊 --%>
				<%-- 若「特殊擔保品選項」的值為「裡地」，才顯示「現況出入無虞」，且必須有值。 --%>
				<%-- 若「特殊擔保品選項」的值非「裡地」，「現況出入無虞」與對應的 radio 按鈕，均不顯示。 --%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				特殊擔保品選項
				<select id="SPC_GAGE_OPT_VIEW">
				    <option value=''></option>
			       	<c:forEach var="map" items="${SPC_GAGE_OPT_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>&nbsp;&nbsp;&nbsp;
				<div id="SPC_GAGE_TYPE_NM" style="display:none">
					現況出入無虞
					<input name='SPC_GAGE_TYPE' id = 'SPC_GAGE_TYPE_Y' type="radio" value ='1'>是
					<input name='SPC_GAGE_TYPE' id = 'SPC_GAGE_TYPE_N' type="radio" value ='0'>否
					<input name='SPC_GAGE_TYPE_hidden' id ='SPC_GAGE_TYPE_hidden' type="hidden" value =''>
				</div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2">
				買賣金額 
				<input type="text" class="textBox2" size="13" maxLength="10" datatype="number" id="TRADE_AMT_VIEW" pattern="#,###.##"> 
				萬，買賣日期 
				<input name="TRADE_DATE_VIEW" type="text" class="textBox2 checkInputLength validate-ROCDate" datatype="ROCDate" size="9" maxLength="7" value="" id="TRADE_DATE_VIEW"> 
				<img src="<%=imageBase%>/CM/calendar.gif" width="18" height="18" onclick="getCalendarFor($('TRADE_DATE_VIEW'))">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
				仲介商:
				<input type="text" id="BROKER_NAME" name="BROKER_NAME" class="textBox2" maxlength="10" size='15'/>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				買賣契約影像是/否完整:&nbsp;&nbsp;&nbsp;
				<input name='WELL_CONTRACT' id = 'WELL_CONTRACT_Y' type="radio" value ='1'>是
				<input name='WELL_CONTRACT' id = 'WELL_CONTRACT_N' type="radio" value ='0'>否
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2">2.案名</td>
			<td class="tbYellow2">
				<input type="text" class="textBox2" size="15" maxLength="20" fieldName="社區案名" id="CASE_NAME_VIEW">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				社區編號： <span id="COMMUNITY_NO_LINK_VIEW"></span><input type="hidden" id="COMMUNITY_NO_VIEW" value="">&nbsp;&nbsp;&nbsp;
				社區照片最新日期：<span id="UPDATE_PIC_DATE_VIEW"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2">
				戶數 <input type="text" class="textBox2" size="8" maxLength="4" datatype="number" id="HOUSE_NO_VIEW" pattern="#,###.##">戶&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				銷售率 <input type="text" class="textBox2" size="8" maxLength="5" datatype="number" id="SALE_RATE_VIEW" pattern="#,###.##">%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				進駐率 <input type="text" class="textBox2" size="8" maxLength="5" datatype="number" id="REST_RATE_VIEW" pattern="#,###.##">%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
				開店率 <input type="text" class="textBox2" size="8" maxLength="5" datatype="number" id="OPEN_RATE_VIEW" pattern="#,###.##">%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<div id="DYNAMIC_SPC_CONDITION" style="display:inline"></div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2">3.路寬</td>
			<td class="tbYellow2">
				<input type="text" class="textBox2" size="8" maxLength="6" datatype="number" id="ROAD_WIDTH_VIEW" pattern="#,###.##">米&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				臨路縱深 <input type="text" class="textBox2" size="8" maxLength="6" datatype="number" id="NEAR_DEPTH_VIEW" pattern="#,###.##">米&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
				地面寬 <input type="text" class="textBox2" size="8" maxLength="6" datatype="number" id="LAND_WIDTH_VIEW" pattern="#,###.##">米&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				建物面寬 <input type="text" class="textBox2" size="8" maxLength="7" datatype="number" id="BUILD_WIDTH_VIEW" pattern="#,###.##">米
			</td>
		</tr>
		<tr>
			<td class="tbYellow2">
				使用現況 
				<select id="USE_STATUS_VIEW">
			       	<c:forEach var="map" items="${USE_STATUS_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select> 
				，訪查租金：約
				<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="RENT_PRICE_VIEW" pattern="#,###.##">萬/月
				，訪查現況用途
				<select id="INVESTIGATE_STATUS_VIEW">
			       	<c:forEach var="map" items="${INVESTIGATE_STATUS_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
			       	<option value=""></option>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">4.座向</td>
			<td class="tbYellow2">
				朝 
				<select id="ASPECT_VIEW">
			       	<c:forEach var="map" items="${ASPECT_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select> 
				座落 
				<select id="SITE_VIEW">
			       	<c:forEach var="map" items="${SITE_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2">5.增建情形</td>
			<td class="tbYellow2">
				<select id="A200_BUILD_ADD_VIEW">
			       	<c:forEach var="map" items="${BUILD_ADD_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select> 
				總使用坪數 
				<input type="text" class="textBox2" size="10" maxLength="9" datatype="number" id="TOTAL_SPACE_VIEW" pattern="#,###.###">坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow2">
				其他說明 
				<textarea rows=1 cols=80 id="BUILD_ADD_DESC_VIEW" class="textAreaOldSys checkInputLength" maxLength="120"  onkeyup="this.style.posHeight=this.scrollHeight"></textarea>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">6.公設比</td>
			<td class="tbYellow2">
				<input type="text" class="textBox2" size="8" maxLength="5" datatype="number" id="PUB_RATE_VIEW" pattern="#,###.##">%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				停車位 
				<select id="PARK_VIEW">
			       	<c:forEach var="map" items="${PARK_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
				編號 
				<input type="text" class="textBox2 checkInputLength" size="20" maxLength="40" value="" id="PARK_NO_VIEW">號&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				坪數 
				<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="PARK_SPACE_VIEW" pattern="#,###.###">坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow">7.鑑價記錄</td>
			<td class="tbYellow2"><font color='red'><span id="SLOGAN_VIEW"></span></font></td>
		</tr>		
	</table>
<!-- C區 -->
<!-- D區 -->
	<table id="table_D" name="table_F" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
		<tr class=tbYellow0 align=middle>
			<td align=middle colspan="2"><strong>二、區域環境</strong>
			<input type="button" class="button" id="btn_Get_A213List_VIEW" value="(2)環域分析">
			<input type="button" class="button" id="btn_Get_A216List_VIEW" value="(3)案例建議"></td>
		</tr>
		<tr>
			<td class="tbYellow">1.附近商家</td>
			<td class="tbYellow2" >
				為
				<select id="SHOP_KIND_VIEW">
			       	<c:forEach var="map" items="${SHOP_KIND_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				市況
				<select id="SHOP_STATUS_VIEW">
			       	<c:forEach var="map" items="${SHOP_STATUS_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="checkbox" class="checkboxbig" id="AREA_ADD_VIEW">
				距DE區單位500公尺內
			</td>
		</tr>
		<tr>
			<td class="tbYellow">2.管理情形</td>
			<td class="tbYellow2" >
				<select id="MANAGE_STATUS_VIEW">
			       	<c:forEach var="map" items="${MANAGE_STATUS_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				生活機能
				<select id="LIFE_FUNC_VIEW">
			       	<c:forEach var="map" items="${LIFE_FUNC_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				交通機能
				<select id="TRFC_FUNC_VIEW">
			       	<c:forEach var="map" items="${TRFC_FUNC_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="text" class="textBox2" size="7" maxLength="6" datatype="number" id="SPC_DISTANCE_VIEW" pattern="#,###.##"> 米
				<select id="SPC_KD_BAD_VIEW">
			       	<c:forEach var="map" items="${SPC_KD_BAD_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				<input type="text" class="textBox2" size="7" maxLength="5" datatype="number" id="SPC_RATE_VIEW" pattern="#,###.##">%
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="3">3.勘查紀錄</td>
			<td class="tbYellow2" >
				屋況
				<select id="HOUSE_CONDITIONS_VIEW">
			       	<c:forEach var="map" items="${HOUSE_CONDITIONS_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				拍攝說明
				<select id="NOPIC_REASON_VIEW">
			       	<c:forEach var="map" items="${NOPIC_REASON_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				室內照入檔日期
				<input type="text" class="textBox2 checkInputLength validate-ROCDate" datatype="ROCDate" size="10" maxLength="7" value="" id="HOUSE_PIC_DATE_VIEW">
				<img src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onclick="getCalendarFor($('HOUSE_PIC_DATE_VIEW'))">
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" >
				外觀照說明
				<select id="APPEARANCE_PIC_REASON_VIEW">
					<option value="" selected></option>
			       	<c:forEach var="map" items="${APPEARANCE_PIC_REASON_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				外觀照日期
				<input type="text" class="textBox2 checkInputLength validate-ROCDate" datatype="ROCDate" size="10" maxLength="7" value="" id="APPEARANCE_PIC_DATE_VIEW">
				<img src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onclick="getCalendarFor($('APPEARANCE_PIC_DATE_VIEW'))">
			</td>
		</tr>
			<td class="tbYellow2" >
				沿用編號
				<input type="text" class="textBox2 checkInputLength" size="13" maxLength="11" value="" id="FOLLOW_NUMBER_VIEW">
				<input type="button" class="button" id="btn_copyPicAlbum" value="引用相簿">
				拍照人員：
				<span id="PHOTO_NM_VIEW"></span><input type="hidden" id="PHOTO_ID_VIEW" value="">
				鑑價科:
				<select id="APPR_DEPT" name="APPR_DEPT" class="choose-one" >
					<option value="">全部</option>
					<c:forEach var="map" items="${APPR_DEPT_LIST}" >
						 <option value = "${map.key}"> ${map.value} </option>
					</c:forEach>
				</select> 
				<select id="SUPPORT_ID_VIEW">
					<option value="" selected></option>
			       	<c:forEach var="map" items="${SUPPORT_ID_LIST}">
						<option value='${map.ID}'>${map.NAME}</option>
			       	</c:forEach>
				</select>
			</td>
		<tr>
		</tr>
		<tr class=tbYellow >
			<td align=left rowspan="2">4.嫌惡設施</td>
			<td class="tbYellow2" disabled>
				<div id="A_divI6" style="overflow:auto; display:none;">
				<select id="DISLIKE_FACILITY_VIEW" style="width:100px">
			       	<c:forEach var="map" items="${DISLIKE_FACILITY_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				約<input type="text" class="textBox2" size="10" maxLength="6" datatype="number" id="DISLIKE_DISTANCE_VIEW" pattern="#,###.##">公尺，
				影響
				<select id="DISLIKE_EFFECT_VIEW">
			       	<c:forEach var="map" items="${DISLIKE_EFFECT_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>；<br>
				<select id="DISLIKE_FACILITY2_VIEW" style="width:100px">
			       	<c:forEach var="map" items="${DISLIKE_FACILITY_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				約<input type="text" class="textBox2" size="10" maxLength="6" datatype="number" id="DISLIKE_DISTANCE2_VIEW" pattern="#,###.##">公尺，
				影響
				<select id="DISLIKE_EFFECT2_VIEW">
			       	<c:forEach var="map" items="${DISLIKE_EFFECT_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				</div>
			</td>
		</tr>
		<tr class=tbYellow >
			<td class="tbYellow2" >
				<div id="A213BList_VIEW" style="overflow:auto; display:none;"></div>
				<textarea rows=3 cols=80 id="DISLIKE_DESC_VIEW" class="textAreaOldSys checkInputLength" maxLength="500"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
			</td>
		</tr>
		<tr class=tbYellow >
			<td align=left rowspan="2">5.環境設施</td>
			<td class="tbYellow2" disabled>
				<div id="A_divI7" style="overflow:auto; display:none;">
				近<input type="text" class="textBox2 checkInputLength" size="30" maxLength="10" value="" id="SPC_KD_GOOD_NAME_VIEW">
				<select id="SPC_KD_GOOD_VIEW">
			       	<c:forEach var="map" items="${SPC_KD_GOOD_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				約<input type="text" class="textBox2" size="10" maxLength="6" datatype="number" id="SPC_DISTANCE1_VIEW" pattern="#,###.##">公尺；<br>
				近<input type="text" class="textBox2 checkInputLength" size="30" maxLength="10" value="" id="SPC_KD_GOOD_NAME2_VIEW">
				<select id="SPC_KD_GOOD2_VIEW">
			       	<c:forEach var="map" items="${SPC_KD_GOOD_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				約<input type="text" class="textBox2" size="10" maxLength="6" datatype="number" id="SPC_DISTANCE2_VIEW" pattern="#,###.##">公尺
				</div>
			</td>	
		</tr>
		<tr class=tbYellow >
			<td class="tbYellow2">
				<div id="A213AList_VIEW" style="overflow:auto; display:none;"></div>
				<div id="A213CList_VIEW" style="overflow:auto; display:none;"></div>
				<textarea rows=3 cols=80 id="SPC_DESC_VIEW" class="textAreaOldSys checkInputLength" maxLength="500"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" colspan='2'>
				<div id="A_divI8" style="overflow:auto; display:block;">
					<table class="tbBox2" border="0" width='100%' cellpadding="0" cellspacing="1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
						<tr>
							<td class="tbYellow" rowspan="2" width="10%">
								6.捷運說明
							</td>
							<td class="tbYellow2" >
								屬
								<select id="METRO_VIEW">
							       	<option value=''>選捷運線別</option>
									<c:forEach var="map" items="${METRO_LIST}">
										<option value='${map.L_SEQ}'>${map.L_NAME}</option>
							       	</c:forEach>
								</select>
								<input type="text" class="textBox2 checkInputLength" size="22" maxLength="20" value="" id="BUILD_LINE_VIEW">
								<select id="STATION_VIEW">
							       	<option value=''>選站名</option>
									<c:forEach var="map" items="${STATION_LIST}">
										<option value='${map.S_SEQ}'>${map.S_NAME}</option>
							       	</c:forEach>
								</select>
								<input type="text" class="textBox2 checkInputLength" size="22" maxLength="20" value="" id="BUILD_STATION_VIEW">
								之捷運共構產品
							</td>
						</tr>
						<tr>
							<td class="tbYellow2">
								屬
								<select id="METRO1_VIEW">
							       	<option value=''>選捷運線別</option>
									<c:forEach var="map" items="${METRO_LIST}">
										<option value='${map.L_SEQ}'>${map.L_NAME}</option>
							       	</c:forEach>
								</select>
								<input type="text" class="textBox2 checkInputLength" size="22" maxLength="20" value="" id="ROUND_LINE_VIEW">
								<select id="STATION1_VIEW">
							       	<option value=''>選站名</option>
									<c:forEach var="map" items="${STATION_LIST}">
										<option value='${map.S_SEQ}'>${map.S_NAME}</option>
							       	</c:forEach>
								</select>
								<input type="text" class="textBox2 checkInputLength" size="22" maxLength="20" value="" id="ROUND_STATION_VIEW">
								<input type="text" class="textBox2 checkInputLength" size="8" maxLength="10" value="" id="ROUND_EXIT_VIEW"> 號出口，為圓心
								<select id="ROUND_DISTANCE_VIEW">
							       	<c:forEach var="map" items="${ROUND_DISTANCE_LIST}">
										<option value='${map.key}'>${map.value}</option>
							       	</c:forEach>
								</select>
								之建物
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
	</table>
<!-- D區 -->
<!-- E區 -->
	<table class="tbBox2" cellspacing="1" style="width: 100%; border: 0;" id="table_E">
		<tr class=tbYellow0 align=middle>
			<td align=middle><strong>三、訪價資料(單位：萬,坪)</strong>
			<input type="button" class="button" id="btn_Get_A201List_VIEW" value="(4)訪價匯入"></td>
		</tr>
		<tr class=tbBlue align=middle>
			<td align=middle>
				<table id="gridE1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
					<tr align="center" class="tbBlue">
						<td rowSpan="2"><b>編號</b></td>
						<td colSpan="2"><b>地址</b></td>
						<td rowSpan="2"><b>時間</b></td>
						<td rowSpan="2"><b>屋齡<br>樓層</b></td>
						<td rowSpan="2"><b>月租金<br>還原率(%)</b></td>
						<td rowSpan="2"><b>地坪<br>建坪</b></td>
						<td rowSpan="2"><b>面寬<br>縱深</b></td>
						<td rowSpan="2"><b>造價<br>地價(萬/坪)</b></td>
						<td rowSpan="2"><b>建坪單價<br>成交/預估建坪總價(萬)</b></td>
						<td rowSpan="2"><b>車位坪<br>車位價</b></td>
					</tr>
					<tr align="center" class="tbBlue">
						<!-- <td><b>距離</b></td> -->
						<td><b>資料來源</b></td>
						<td><b>開價(萬)/仲介</b></td>
						<!-- <td><b>使用性質</b></td> -->
					</tr>
					<tr align="center" class="tbBlue3">
						<td rowSpan="2">
							甲<input id="SEQ_NO_VIEW_1" value="1" type="hidden">	<input id="APPLY_ID_VIEW_1" type="hidden">
						</td>
						<td colSpan="2">
							<input id="ADDRESS_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="60" size="50" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						</td>
						<td rowSpan="2">
							<input id="REF_TIME_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="5" size="6">
						</td>
						<td rowSpan="2">
							<input id="BUILD_AGE_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="3" size="2" datatype="number" pattern="#,###.##"><br>
							<input id="FLOOR_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="9" size="5">
						</td>
						<td rowSpan="2">
							<input id="MONTH_RENT_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="8" size="6" datatype="number" pattern="#,###.##"><br>
							<input id="RECOV_RATE_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="5" size="6" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="LAND_SPACE_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##"><br>
							<input id="BUILD_SPACE_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="BUILD_WIDTH_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="6" size="4" datatype="number" pattern="#,###.##"><br>
							<input id="BUILD_ADD_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="6" size="4" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="BUILD_PRICE_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="8" size="7" datatype="number" pattern="#,###.##"><br>
							<input id="LAND_PRICE_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##" readonly style="background-color:#FFEE99">
							<input id="LAND_PRICE_VIEW_1_btn" type="button" class="button" value="C">
						</td>
						<td rowSpan="2">
							<input id="PER_PRICE_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="8" size="7" datatype="number" pattern="#,###.##" readonly style="background-color:#FFEE99">
							<input id="PER_PRICE_VIEW_1_btn" type="button" class="button" value="C">
							<br>
							<input id="TOTAL_PRICE_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="10" size="9" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="PARK_SPACE_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="7" size="6" datatype="number" pattern="#,###.###"><br>
							<input id="PARK_PRICE_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
					</tr>
					<tr align="center" class="tbBlue3">
						<td>
                        	<select id="REF_SRC_VIEW_1" class="textBox2">
								<c:forEach items="${REF_SRC_LIST}" var="map">
									<c:choose>
										<c:when test="${map.key eq 'I' }">
											<option value="<c:out value="${map.key}" />" disabled ><c:out value="${map.value}" /></option>
										</c:when>
										<c:otherwise>
											<option value="<c:out value="${map.key}" />" ><c:out value="${map.value}" /></option>
										</c:otherwise>
									</c:choose>
								</c:forEach>
							</select>
						</td>
						<td>
							<input id="TIME_TEL_VIEW_1" type="text" class="textBox2 checkInputLength" maxlength="16" size="12">
						</td>
					</tr>
					<tr align="center" class="tbYellow2">
						<td rowSpan="2">
							乙<input id="SEQ_NO_VIEW_2" value="1" type="hidden">	<input id="APPLY_ID_VIEW_2" type="hidden">
						</td>
						<td colSpan="2">
							<input id="ADDRESS_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="60" size="50" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						</td>
						<td rowSpan="2">
							<input id="REF_TIME_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="5" size="6">
						</td>
						<td rowSpan="2">
							<input id="BUILD_AGE_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="3" size="2" datatype="number" pattern="#,###.##"><br>
							<input id="FLOOR_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="9" size="5">
						</td>
						<td rowSpan="2">
							<input id="MONTH_RENT_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="8" size="6" datatype="number" pattern="#,###.##"><br>
							<input id="RECOV_RATE_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="5" size="6" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="LAND_SPACE_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##"><br>
							<input id="BUILD_SPACE_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="BUILD_WIDTH_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="6" size="4" datatype="number" pattern="#,###.##"><br>
							<input id="BUILD_ADD_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="6" size="4" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="BUILD_PRICE_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="8" size="7" datatype="number" pattern="#,###.##"><br>
							<input id="LAND_PRICE_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##" readonly style="background-color:#FFEE99">
							<input id="LAND_PRICE_VIEW_2_btn" type="button" class="button" value="C">
						</td>
						<td rowSpan="2">
							<input id="PER_PRICE_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="8" size="7" datatype="number" pattern="#,###.##" readonly style="background-color:#FFEE99">
							<input id="PER_PRICE_VIEW_2_btn" type="button" class="button" value="C">
							<br>
							<input id="TOTAL_PRICE_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="10" size="9" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="PARK_SPACE_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="7" size="6" datatype="number" pattern="#,###.###"><br>
							<input id="PARK_PRICE_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
					</tr>
					<tr align="center" class="tbYellow2">
						<td>
                        	<select id="REF_SRC_VIEW_2" class="textBox2">
								<c:forEach items="${REF_SRC_LIST}" var="map">
									<c:choose>
										<c:when test="${map.key eq 'I' }">
											<option value="<c:out value="${map.key}" />" disabled ><c:out value="${map.value}" /></option>
										</c:when>
										<c:otherwise>
											<option value="<c:out value="${map.key}" />" ><c:out value="${map.value}" /></option>
										</c:otherwise>
									</c:choose>
								</c:forEach>
							</select>
						</td>
						<td>
							<input id="TIME_TEL_VIEW_2" type="text" class="textBox2 checkInputLength" maxlength="16" size="12">
						</td>
					</tr>
					<tr align="center" class="tbBlue3">
						<td rowSpan="2">
							丙<input id="SEQ_NO_VIEW_3" value="1" type="hidden">	<input id="APPLY_ID_VIEW_3" type="hidden">
						</td>
						<td colSpan="2">
							<input id="ADDRESS_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="60" size="50" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						</td>
						<td rowSpan="2">
							<input id="REF_TIME_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="5" size="6">
						</td>
						<td rowSpan="2">
							<input id="BUILD_AGE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="3" size="2" datatype="number" pattern="#,###.##"><br>
							<input id="FLOOR_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="9" size="5">
						</td>
						<td rowSpan="2">
							<input id="MONTH_RENT_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="8" size="6" datatype="number" pattern="#,###.##"><br>
							<input id="RECOV_RATE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="5" size="6" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="LAND_SPACE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##"><br>
							<input id="BUILD_SPACE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="BUILD_WIDTH_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="6" size="4" datatype="number" pattern="#,###.##"><br>
							<input id="BUILD_ADD_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="6" size="4" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="BUILD_PRICE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="8" size="7" datatype="number" pattern="#,###.##"><br>
							<input id="LAND_PRICE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##" readonly style="background-color:#FFEE99">
							<input id="LAND_PRICE_VIEW_3_btn" type="button" class="button" value="C">
						</td>
						<td rowSpan="2">
							<input id="PER_PRICE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="8" size="7" datatype="number" pattern="#,###.##" readonly style="background-color:#FFEE99">
							<input id="PER_PRICE_VIEW_3_btn" type="button" class="button" value="C">
							<br>
							<input id="TOTAL_PRICE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="10" size="9" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="PARK_SPACE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="7" size="6" datatype="number" pattern="#,###.###"><br>
							<input id="PARK_PRICE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
					</tr>
					<tr align="center" class="tbBlue3">
						<!-- <td>
							<input id="DISTANCE_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td> -->
						<td>
                        	<select id="REF_SRC_VIEW_3" class="textBox2">
								<c:forEach items="${REF_SRC_LIST}" var="map">
									<c:choose>
										<c:when test="${map.key eq 'I' }">
											<option value="<c:out value="${map.key}" />" disabled ><c:out value="${map.value}" /></option>
										</c:when>
										<c:otherwise>
											<option value="<c:out value="${map.key}" />" ><c:out value="${map.value}" /></option>
										</c:otherwise>
									</c:choose>
								</c:forEach>
							</select>
						</td>
						<td>
							<input id="TIME_TEL_VIEW_3" type="text" class="textBox2 checkInputLength" maxlength="16" size="12">
						</td>
					</tr>
					<tr align="center" class="tbYellow2">
						<td rowSpan="2">
							丁<input id="SEQ_NO_VIEW_4" value="1" type="hidden">	<input id="APPLY_ID_VIEW_4" type="hidden">
						</td>
						<td colSpan="2">
							<input id="ADDRESS_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="60" size="50" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						</td>
						<td rowSpan="2">
							<input id="REF_TIME_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="5" size="6">
						</td>
						<td rowSpan="2">
							<input id="BUILD_AGE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="3" size="2" datatype="number" pattern="#,###.##"><br>
							<input id="FLOOR_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="9" size="5">
						</td>
						<td rowSpan="2">
							<input id="MONTH_RENT_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="8" size="6" datatype="number" pattern="#,###.##"><br>
							<input id="RECOV_RATE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="5" size="6" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="LAND_SPACE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.###"><br>
							<input id="BUILD_SPACE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="BUILD_WIDTH_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="6" size="4" datatype="number" pattern="#,###.##"><br>
							<input id="BUILD_ADD_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="6" size="4" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="BUILD_PRICE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="8" size="7" datatype="number" pattern="#,###.##"><br>
							<input id="LAND_PRICE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="9" size="5" datatype="number" pattern="#,###.##" readonly style="background-color:#FFEE99">
							<input id="LAND_PRICE_VIEW_4_btn" type="button" class="button" value="C">
						</td>
						<td rowSpan="2">
							<input id="PER_PRICE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="8" size="7" datatype="number" pattern="#,###.##" readonly style="background-color:#FFEE99">
							<input id="PER_PRICE_VIEW_4_btn" type="button" class="button" value="C">
							<br>
							<input id="TOTAL_PRICE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="10" size="9" datatype="number" pattern="#,###.##">
						</td>
						<td rowSpan="2">
							<input id="PARK_SPACE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="7" size="6" datatype="number" pattern="#,###.###"><br>
							<input id="PARK_PRICE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
					</tr>
					<tr align="center" class="tbYellow2">
						<!-- <td>
							<input id="DISTANCE_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td> -->
						<td>
							<select id="REF_SRC_VIEW_4" class="textBox2">
								<c:forEach items="${REF_SRC_LIST}" var="map">
									<c:choose>
										<c:when test="${map.key eq 'I' }">
											<option value="<c:out value="${map.key}" />" disabled ><c:out value="${map.value}" /></option>
										</c:when>
										<c:otherwise>
											<option value="<c:out value="${map.key}" />" ><c:out value="${map.value}" /></option>
										</c:otherwise>
									</c:choose>
								</c:forEach>
							</select>
						</td>
						<td>
							<input id="TIME_TEL_VIEW_4" type="text" class="textBox2 checkInputLength" maxlength="16" size="12">
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
<!-- E區 -->
<!-- F區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_F1">
		<tr class=tbYellow0 align=middle>
			<td align=middle><strong>四、差異分析</strong></td>
		</tr>
		<tr class=tbBlue align=middle>
			<td align=middle>
				<table id="gridF1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
					<tr align="center" class="tbBlue">
						<td><b>編號</b></td>
						<td><b>時間</b></td>
						<td><b>交通</b></td>
						<td><b>生活</b></td>
						<td><b>臨路</b></td>
						<td><b>屋齡</b></td>
						<td><b>樓層</b></td>
						<td>
							<select id='MEASURE_KIND_VIEW'>
								<c:forEach var='map' items='${MEASURE_KIND_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
							<select id='DIFF_KIND_A_VIEW'>
								<c:forEach var='map' items='${DIFF_KIND_A_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
							<select id='DIFF_KIND_B_VIEW'>
								<c:forEach var='map' items='${DIFF_KIND_B_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td><b>綜合</b></td>
						<td><b>試算價格起</b></td>
						<td><b>試算價格迄</b></td>
					</tr>
					<tr align="center" class="tbBlue3">
						<td>
							甲<input id="SEQ_NO_1" value="1" type="hidden">	<input id="APPLY_ID_1" type="hidden">
						</td>
						<td>
                        	<select id="DIFF_TIME_1" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_TRAFFIC_1" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_LIFE_1" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_NEAR_ROAD_1" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_BUILD_AGE_1" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_FLOOR_1" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_MEASURE_1" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL1_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_OPTION_A_1" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_OPTION_B_1" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_SYNTH_1" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
							<input id="LOWER_PRICE_1" type="text" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
						<td>
							<input id="UPPER_PRICE_1" type="text" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
					</tr>
					<tr align="center" class="tbYellow2">
						<td>
							乙<input id="SEQ_NO_2" value="1" type="hidden">	<input id="APPLY_ID_2" type="hidden">
						</td>
						<td>
                        	<select id="DIFF_TIME_2" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_TRAFFIC_2" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_LIFE_2" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_NEAR_ROAD_2" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_BUILD_AGE_2" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_FLOOR_2" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_MEASURE_2" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL1_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_OPTION_A_2" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_OPTION_B_2" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_SYNTH_2" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
							<input id="LOWER_PRICE_2" type="text" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
						<td>
							<input id="UPPER_PRICE_2" type="text" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
					</tr>
					<tr align="center" class="tbBlue3">
						<td>
							丙<input id="SEQ_NO_3" value="1" type="hidden">	<input id="APPLY_ID_3" type="hidden">
						</td>
						<td>
                        	<select id="DIFF_TIME_3" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_TRAFFIC_3" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_LIFE_3" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_NEAR_ROAD_3" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_BUILD_AGE_3" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_FLOOR_3" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_MEASURE_3" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL1_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_OPTION_A_3" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_OPTION_B_3" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_SYNTH_3" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
							<input id="LOWER_PRICE_3" type="text" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
						<td>
							<input id="UPPER_PRICE_3" type="text" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
					</tr>
					<tr align="center" class="tbYellow2">
						<td>
							丁<input id="SEQ_NO_4" value="1" type="hidden">	<input id="APPLY_ID_4" type="hidden">
						</td>
						<td>
                        	<select id="DIFF_TIME_4" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_TRAFFIC_4" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_LIFE_4" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_NEAR_ROAD_4" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_BUILD_AGE_4" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_FLOOR_4" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_MEASURE_4" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL1_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_OPTION_A_4" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_OPTION_B_4" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
                        	<select id="DIFF_SYNTH_4" class="textBox2">
								<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
									<option value='${map.key}'>${map.value}</option>
								</c:forEach>
							</select>
						</td>
						<td>
							<input id="LOWER_PRICE_4" type="text" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
						<td>
							<input id="UPPER_PRICE_4" type="text" maxlength="8" size="6" datatype="number" pattern="#,###.##">
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_F2">
		<tr class=tbYellow0 align=middle>
			<td align=middle>
				<strong>
					<a href="#A_divI0" id="A_divI0">原差異分析</a>
				</strong>
			</td>
		</tr>
		<tr class=tbYellow align=middle>
			<td align=middle>
				<div id="div_I0" style="overflow:auto; display:none;">
					<table id='gridF2' width="100%"></table>
				</div>
			</td>
		</tr>
	</table>
<!-- F區 -->
<!-- G區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_G">
		<tr class=tbYellow0 align=middle>
			<td align=middle><strong>五、綜合分析</strong></td>
		</tr>				
		<tr align=middle>
			<td class="tbYellow2" >
				<textarea rows=10 cols=115 id="LOC_DESC_VIEW" class="textAreaOldSys checkInputLength" maxLength="2000"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
			</td>
		</tr>
	</table>
<!-- G區 -->
<!-- H區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_H">
		<tr class=tbYellow0 align=middle>
			<td align=middle>
				<strong>
					<a href="#A_divI1" id="A_divI1">六、高額件說明</a>
				</strong>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align=middle>
				<div id="div_I1" style="overflow:auto; display:block;">
					<textarea rows=10 cols=115 id="HIGH_AMT_DESC_VIEW" class="textAreaOldSys checkInputLength" maxLength="3000"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
				</div>
			</td>
		</tr>
	</table>
<!-- H區 -->
<!-- H1區 --> 
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_H1">
		<tr class=tbYellow0 align=middle>
			<td align=middle colspan="10"><strong>實價登錄案例建議清單</strong></td>
		</tr>
		<tr align=middle>
			<td class="tbYellow2" >
				<table id='gridH1' width="100%"></table>
			</td>
		</tr>
	</table>
<!-- H1區 -->
<!-- I區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_I">
		<tr class=tbYellow0 align=middle>
			<td align=middle><strong>七、接手性</strong></td>
		</tr>
		<tr align=middle>
			<td class="tbYellow2" >
				<select id='TAKE_OVER_VIEW'> 
					<c:forEach var='map' items='${TAKE_OVER_LIST}'> 
						<option value='${map.key}'>${map.value}</option> 
					</c:forEach> 
				</select>
			</td>
		</tr>
	</table>
<!-- I區 -->
<!-- J區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_J">
		<tr class=tbYellow0 align=middle>
			<td align=middle colspan="10"><strong>八、近三個月同建案紀錄</strong></td>
		</tr>
		<tr align=middle>
			<td class="tbYellow2" >
				<table id='gridJ1' width="100%"></table>
			</td>
		</tr>
	</table>
<!-- J區 -->
<!-- K區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_K">
		<tr class=tbYellow0 align=middle>
			<td align=middle>
				<strong>
					<a href="#A_divI2" id="A_divI2">各擔保品鑑價</a>
				</strong>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				<div id="div_I2" style="overflow:auto; display:none;">
					<table id='gridK1' width="100%"></table>
				</div>
			</td>
		</tr>
	</table>
<!-- K區 -->
<!-- L區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_L">
		<tr class=tbYellow0 align=middle>
			<td align=middle>
				<strong>
					<a href="#A_divI3" id="A_divI3">各擔保品附屬建物資料</a>
				</strong>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				<div id="div_I3" style="overflow:auto; display:none;">
					<table id='gridL1' class="tbBox2" width="100%">
						<tr class=tbBlue align=middle>
							<td align=middle>擔保品地址</td>
							<td align=middle>建號</td>
							<td align=middle>附屬建號</td>
							<td align=middle>坪數(坪)</td>
							<td align=middle>項目</td>
							<td align=middle>車位設定</td>
						</tr>	
						<tr class=tbBlue align=middle>
							<td align=middle>車位編號，車位持分</td>
							<td align=middle>車位型態</td>
							<td align=middle>車位數量(個)</td>
							<td align=middle>車位坪數(坪)</td>
							<td align=middle>車位均價(萬)</td>
							<td align=middle>取消車位</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
	</table>
<!-- L區 -->
<!-- M區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_M">
		<tr class=tbYellow0 align=middle>
			<td align=middle colspan="6"><strong>九、建議價格(單位：萬,位,坪)</strong>
		<!-- 20210610 1.	新增按鈕:社區價格 -->
			<button class="button" type="button" id="btn_Get_A215List_VIEW">(5)自動估價</button>
			<button class="button" type="button" id="btnGenCommPrice">匯入社區/公寓價格</button><%--[20250211]匯入社區價格調整為匯入社區/公寓價格--%>
			<button class="button" type="button" id="btnCfmComm">確認社區/公寓價格</button><%--[20250213]確認社區價格調整為確認社區/公寓價格--%>
			<button class="button" type="button" id="btnLinkTo3700">公寓資料庫</button><%--[20250213]增加公寓資料庫按鈕--%>
			</td>
		</tr>							
		<tr>
			<td class="tbYellow2">
				擬以
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;地價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="LAND_PRICEA_VIEW" pattern="#,###.##">萬/坪
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;造價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BUILD_PRICEA_VIEW" pattern="#,###.##">萬/坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" >
				車位<input type="text" class="textBox2" size="10" maxLength="3" datatype="number" id="PARK_NUM_VIEW_1" pattern="#,###">個&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="PARK_AMT_VIEW_1" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				坪數：<span id="PARK_SPACEB1_VIEW"></span>
				<input type="hidden" class="textBox2" size="10" maxLength="8" datatype="number" id="PARK_SPACEB_VIEW" pattern="#,###.####">坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				增建<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="ADD_SPACE_VIEW" pattern="#,###.####">坪
				<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="ADD_PRICE_VIEW" pattern="#,###.##">萬
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" >
				單價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="PER_PRICE_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="12" maxLength="10" datatype="number" id="TOTAL_PRICE_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				平均(建議單價)<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="AVG_PRICE_VIEW" pattern="#,###.##" readonly >萬/坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" >
				公式
				<select id='FORMULA1_VIEW'> 
					<c:forEach var='map' items='${FORMULA_LIST}'> 
						<option value='${map.key}'>${map.value}</option> 
					</c:forEach> 
				</select>
				<input type="text" class="textBox2 checkInputLength" size="50" maxLength="40" value="" id="FORMULA_VIEW">
			</td>
		</tr>
	</table>
<!-- M區 -->
<!-- M1區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_M1">
		<tr align=middle>
			<td class="tbYellow2" >
				<table id='gridM1' width="100%"></table>
			</td>
		</tr>
	</table>
<!-- M1區 -->
<%-- [20240613]M1 跟 M2區塊中間， 增加 MP 的車位模型價格落差原因區塊 --%>
<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_MP">
	<tr align=middle>
		<td class="tbYellow2" >
			<table id='gridMP' width="100%"></table>
		</td>
	</tr>
</table>
<%-- MP區 --%>
<!-- M2區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_M2">
		<tr align=middle>
			<td class="tbYellow2" >
				<table id='gridM2' width="100%"></table>
			</td>
		</tr>
	</table>
<!-- M2區 -->
<!-- M3區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_M3">
		<tr align=middle>
			<td class="tbYellow2" >
				<table id='gridM3' width="100%"></table>
			</td>
		</tr>
	</table>
<!-- M3區 -->
<%-- [20250211]增加MM公寓行情價格落差原因，區塊顯示同M3方式處理 --%>
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_MM">
		<tr align=middle>
			<td class="tbYellow2" >
				<table id='gridMM' width="100%"></table>
			</td>
		</tr>
	</table>
<%-- MM區 --%>
<!-- N區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_N">
		<tr class=tbYellow0 align=middle>
			<td align=middle>
				<strong>
					<a href="#A_divI4" id="A_divI4">各擔保品鑑價覆核</a>
				</strong>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				<div id="div_I4" style="overflow:auto; display:none;">
					<table id='gridN1' width="100%"></table>
				</div>
			</td>
		</tr>
	</table>
<!-- N區 -->
<!-- O區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_O">
		<tr class=tbYellow0 align=middle>
			<td align=middle>
			<strong>
				<a href="#A_divI5" id="A_divI5">各擔保品附屬建物資料覆核</a>
				</strong>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				<div id="div_I5" style="overflow:auto; display:none;">
					<table id='gridO1' class="tbBox2" width="100%">
						<tr class=tbBlue align=middle>
							<td align=middle>擔保品地址</td>
							<td align=middle>建號</td>
							<td align=middle>附屬建號</td>
							<td align=middle>坪數(坪)</td>
							<td align=middle>項目</td>
						</tr>	
						<tr class=tbBlue align=middle>
							<td align=middle>車位編號，車位持分</td>
							<td align=middle>車位型態</td>
							<td align=middle>車位數量(個)</td>
							<td align=middle>車位坪數(坪)</td>
							<td align=middle>車位均價(萬)</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
	</table>
<!-- O區 -->
<!-- P區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_P">
		<tr class=tbYellow0 align=middle>
			<td align=middle colspan="6"><strong>十、覆核</strong></td>
		</tr>
		
		<tr>
			<td class="tbYellow" rowspan="6" width="5%">組長批示</td>
			<td class="tbYellow2" colspan="4" valign="top"> 
				<select id="CAPT_EXAM_VIEW">
			       	<c:forEach var="map" items="${CAPT_EXAM_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				<textarea rows=5 cols=70 id="CAPT_EXAM_DESC_VIEW" class="textBox2 checkInputLength" maxLength="500"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2" width="5%" align="center">一般行情</td>
			<td class="tbYellow2" colspan="3">	
				地價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_LAND_PRICEA_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				造價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_BUILD_PRICEA_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位總價<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="CAPT_PARK_PRICEA_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位數<input type="text" class="textBox2" size="5" maxLength="3" datatype="number" id="CAPT_PARK_NUMA_VIEW" pattern="#,###.##">位
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">	
				單價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_PER_PRICEA_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="10" maxLength="10" datatype="number" id="CAPT_TOTAL_PRICEA_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				均價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_AVG_PRICEA_VIEW" pattern="#,###.##" readonly>萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位面積<input type="text" class="textBox2" size="7" maxLength="8" datatype="number" id="CAPT_PARK_SPACEA_VIEW" pattern="#,###.###">坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2" width="5%" align="center">特殊行情</td>
			<td class="tbYellow2" colspan="3">	
				地價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_LAND_PRICEB_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				造價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_BUILD_PRICEB_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位總價<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="CAPT_PARK_PRICEB_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位數<input type="text" class="textBox2" size="5" maxLength="3" datatype="number" id="CAPT_PARK_NUMB_VIEW" pattern="#,###.##">位
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">	
				單價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_PER_PRICEB_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="10" maxLength="10" datatype="number" id="CAPT_TOTAL_PRICEB_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				均價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_AVG_PRICEB_VIEW" pattern="#,###.##" readonly>萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位面積<input type="text" class="textBox2" size="7" maxLength="8" datatype="number" id="CAPT_PARK_SPACEB_VIEW" pattern="#,###.###">坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" width="5%" colspan="5" id="CAPT_NM_CAPT_DATE_VIEW"></td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="6" width="14%">主管批示</td>
			<td class="tbYellow2" colspan="4" valign="top"> 
				<select id="BOSS_EXAM_VIEW">
			       	<c:forEach var="map" items="${BOSS_EXAM_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
				<textarea rows=5 cols=70 id="BOSS_EXAM_DESC_VIEW" class="textBox2 checkInputLength" maxLength="500"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2" width="5%" align="center">一般行情</td>
			<td class="tbYellow2" colspan="3">	
				地價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_LAND_PRICEA_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				造價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_BUILD_PRICEA_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位總價<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="BOSS_PARK_PRICEA_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位數<input type="text" class="textBox2" size="5" maxLength="3" datatype="number" id="BOSS_PARK_NUMA_VIEW" pattern="#,###.##">位
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">	
				單價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_PER_PRICEA_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="10" maxLength="10" datatype="number" id="BOSS_TOTAL_PRICEA_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				均價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_AVG_PRICEA_VIEW" pattern="#,###.##" readonly>萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位面積<input type="text" class="textBox2" size="7" maxLength="8" datatype="number" id="BOSS_PARK_SPACEA_VIEW" pattern="#,###.###">坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2" width="5%" align="center">特殊行情</td>
			<td class="tbYellow2" colspan="3">	
				地價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_LAND_PRICEB_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				造價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_BUILD_PRICEB_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位總價<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="BOSS_PARK_PRICEB_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位數<input type="text" class="textBox2" size="5" maxLength="3" datatype="number" id="BOSS_PARK_NUMB_VIEW" pattern="#,###.##">位
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">	
				單價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_PER_PRICEB_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="10" maxLength="10" datatype="number" id="BOSS_TOTAL_PRICEB_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				均價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_AVG_PRICEB_VIEW" pattern="#,###.##" readonly>萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位面積<input type="text" class="textBox2" size="7" maxLength="8" datatype="number" id="BOSS_PARK_SPACEB_VIEW" pattern="#,###.###">坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" width="5%" colspan="5" id="BOSS_NM_BOSS_DATE_VIEW"></td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2" width="5%">部室主管批示</td>
		</tr>
		<tr>
			<td class="tbYellow2" width="9%" id="GM_NM_GM_DATE_VIEW"></td>
			<td class="tbYellow2" colspan="4" ><textarea rows=2 cols=70 id="GM_EXAM_DESC_VIEW" class="textBox2 checkInputLength" maxLength="500"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea></td>
		</tr>
	</table>
	<table id='table_P1' class="tbBox2" cellspacing="1" style="width:100%; border:0;"></table>
<!-- P區 -->
<!-- Q區 -->
    <table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_R">
		<tr align="center" class="tbYellow0">
			  <td colspan="8" class="textBold">十一、評分</td>
		</tr>
		<tr> 
		  <td>
			<table id="gridR1" >
			</table>
		  </td>
		</tr>
		<tr>
			<td class=tbYellow2 align="center">
				<input id="btn_add_1" class="button" type="button" value="新增評分" /> 
			</td>
		</tr>			
	</table>
</form>
	</body>
</html>