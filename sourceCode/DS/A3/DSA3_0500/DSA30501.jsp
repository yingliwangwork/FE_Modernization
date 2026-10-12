<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA30501.jsp
作者：闕沛宇
功能：簡易件鑑價輸入
完成：

[20180607]問題單
問題敘述：1.IE11問題 2.若銀行件各擔保品附屬建物資料中有新增車位資料，執行修正或組長覆核時發生錯誤
[20180626]
問題敘述：1.IE11問題 2.onpropertychange在IE11失效，改用onkeyup，並在查詢完成時模擬keyup動作
[20201105]申請書-201019001927：調整承作分區判斷邏輯
[20210323]問題單
問題敘述：1.智能價格區間連動調整2.智能件的修正按鈕僅對覆核組長開放3.價格資料欄位連結(只有DTDSA200.IS_AUTOAPPR=2才顯示)4.非智能件不開放車位新增功能

[20210804] 問題單 單號:20210804140313
問題敘述: 當案件為銀行件，修改時新增檢核車位持分分母欄位不得異動

[20211018] 修改件，立案單號:211015005065
CHROME 進入壽核系統的鑑價報告 textarea 欄位優化

[20220307] IE樓層欄位優化，不得輸入數字以外字元
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
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/date.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/suggest.js'></script>	<%-- 搜尋提示用 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/validation.js'></script> <%-- 檢核用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script> <%-- 匯出PDF用--%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/InputUtility.js'></script>
<script type='text/javascript'>

// 產生畫面物件
var DSA30501 = new DSA30501();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSA30501.initApp);
var defaultPattern1 = '#,###.##';
var defaultPattern2 = '#,###.###';

function DSA30501(){
	
	//查詢的檢核 
	var valid1;
	var valid2;
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
	var gridMM;<%--[20250211]公寓估價紀錄--%>
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
	
	// 20210610 3.	拆分價格原因落差欄位為兩欄:價格落差原因一、價格落差原因二
	var PRICE_GAP1_LIST = {};//價格落差原因一選單
	var PRICE_GAP2_LIST = {};//價格落差原因二選單
	// 20240625 車位價格落差原因一、車位價格落差原因二
	var PSM_GAP1_LIST = {};//車位價格落差原因一選單
	var PSM_GAP2_LIST = {};//車位價格落差原因二選單
	//前次查詢條件
	var queryCondition = {APPLY_ID : ""};
	
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
				B0148:"btn_reSend",//報告重送
				B0044:"btn_linkImage",//影像連結
				B0250:"btn_Get_A216List_VIEW",//(1)案例建議
				B0251:"btn_Get_A215List_VIEW",//(2)自動估價
				B0249:"btn_Get_A201List_VIEW",//(3)訪價匯入
				B0054:"btn_change", //報告變更
				B0257:"btn_copyPicAlbum" //引用相簿
		};
		<dz:grantButtons FUNC_ID="DSA30501" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([
			[ 'validateAPPLY_ID',  '受理編號長度不正確 需為11碼',
				function(v){				
					return (v.length != 11) ? false : true ;
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
			[ 'validate1LOC_DESC_VIEW',  '價格補充說明請勿輸入單引號!!',
				function(v){
					return (v.indexOf('\'') != -1) ? false : true ;
				}
			],
			[ 'validate2LOC_DESC_VIEW',  '價格補充說明請勿輸入半形逗號!!',
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
			[ 'validateAREA_CODE',  '承作分區不可為空',
				function(v){				
					return $F('AREA_CODE_930318') ? true : false ;
					//[20201105]申請書-201019001927：調整承作分區判斷邏輯
				}
			],
			[ 'validatePARK',  '請選擇車位型態',
				function(v){
					return (v == '0'   || v == '1') ? false : true ;
				}
			],
			['validateMEMO',  '價格落差原因選擇其他，請輸入備註',
				function(v,ele){
				var GAP_NOTE21 = $$('#'+ele.id +' select[name=GAP_NOTE21]')[0];
				if (GAP_NOTE21 && [15,24,49,59,63,71].include(GAP_NOTE21.value)){
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
		
		valid2 = new Validation("form2", { focusOnError:true, immediate:false, useTitles:true });
		settingValid2('init');

		valid3 = new Validation("form2", { focusOnError:true, immediate:false, useTitles:true });
		valid3.define( "validateCASE_NAME_VIEW" , { id: "CASE_NAME_VIEW" } );
		valid3.define( "validateGridK1" , { id: "gridK1" } );
		valid3.define( "checkParkTypeViewSelectOption" , { id: "gridK1" } );
		
		valid4 = new Validation("form2", { focusOnError:true, immediate:false, useTitles:true });
		<%--[20240613]車位模型檢核--%>
		valid7 = new Validation("form2", { focusOnError:true, immediate:false, useTitles:true});
	}
	
	function settingValid2(actionType){
		if('init'!=actionType){
			valid2.clear();
			valid2.reset();
		}
		
		valid2.define( "validate1BUILD_TYPE_VIEW" , { id: "BUILD_TYPE_VIEW" } );
		valid2.define( "validate2BUILD_TYPE_VIEW" , { id: "BUILD_TYPE_VIEW" } );
		valid2.define( "validate1DESC_VIEW" , { id: "DISLIKE_DESC_VIEW" } );
		valid2.define( "validate2DESC_VIEW" , { id: "DISLIKE_DESC_VIEW" } );
		valid2.define( "validate1DESC_VIEW" , { id: "SPC_DESC_VIEW" } );
		valid2.define( "validate2DESC_VIEW" , { id: "SPC_DESC_VIEW" } );
		valid2.define( "validate1LOC_DESC_VIEW" , { id: "LOC_DESC_VIEW" } );
		valid2.define( "validate2LOC_DESC_VIEW" , { id: "LOC_DESC_VIEW" } );
		valid2.define( "validateUSE_FOR_VIEW" , { id: "USE_FOR_VIEW" } );
		
		if('confirm'==actionType || 'captainConfirm'==actionType || 'update'==actionType){
			valid2.define( "required" , { id: "USE_AREA1_VIEW" } );
			if(isURBAN_PROJECT){
				valid2.define( "required" , { id: "URBAN_PROJECT" } );	
			}
		}
		//因為智能件，有可能組長代理科主管覆核(一階段覆核，組長可以調整落差原因)
		//所以科主管代理覆核也要卡控落差原因
		if('confirm'==actionType || 'captainConfirm'==actionType 
				|| $F('IS_AUTOAPPR')=="2" && 'bossConfirm'==actionType){
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
					valid7.define("validatePARK", { id: elem.id, errMsg:"車位型態必須有值" });
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
						    if(actionName == 'insert') {
						    	buttons.doReQuery();
						    	//新增後差異分析擔保品比較建坪自動觸發計算
						    	changeBUILD_SPACE_A201($('PARK_SPACE_VIEW'), $('BUILD_MEASURE'));
						    	//新增後若無對應社區編號產生提示訊息
						    	if ($('COMMUNITY_NO_VIEW').value=='') {
						    		alert("查無對應社區編號，請確認社區案名是否正確！");
						    	}
							}else if(actionName == 'update' || actionName == 'delete' || actionName == 'confirm' || actionName == 'cancel' ||
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
	function querySuccessFunction(resp){
		var encryptAPPLY_ID = resp.encryptAPPLY_ID;
		if(encryptAPPLY_ID){
			$('encryptAPPLY_ID').value=encryptAPPLY_ID;
		}
		var rtnMap = resp.rtnMap ? resp.rtnMap : {};
		viewMap = rtnMap;
		MISS_REASON = resp.MISS_REASON ||'';<!-- 20210617  顯示買賣件合理議價區間不符原因-->
		chkTRADE_AMT = JsUtils.isBasicType(rtnMap.TRADE_AMT) ? rtnMap.TRADE_AMT:0;
		APPR_PROCESS=rtnMap.APPR_PROCESS;
		
		//[20220119]針對舊件顯示舊素地，新件顯示素地AB
		var useForList=rtnMap.useForList;
		$('USE_FOR_VIEW').length=0;
		if(useForList){
			for(var i=0;i<useForList.length;i++){
				$('USE_FOR_VIEW').add(new Option(useForList[i]['VAL'],useForList[i]['KEY']));
			}
		}
		
		var IS_AUTOAPPR=rtnMap.IS_AUTOAPPR;
		$('IS_AUTOAPPR').setValue(IS_AUTOAPPR);	  //智能件狀態
		
		var AUTO_CAPT_ID=rtnMap.AUTO_CAPT_ID;
		$('AUTO_CAPT_ID').setValue(AUTO_CAPT_ID); //存放智能件指派作業人員
		
		//B區
		buttons.setTable_B(rtnMap,resp);
		//C區
		buttons.setTable_C(rtnMap);		
		
		
		//E區
		//gridE1 訪價資料
		buttons.setGridE1(resp);	
		//F區
		//gridF1 差異分析
		buttons.setGridF1(resp);	
		
		
		//G區
		$('LOC_DESC_VIEW').value = rtnMap.LOC_DESC ? rtnMap.LOC_DESC : '';	
		//H區	
		//gridH1 實價登錄案例建議清單
		var A216List = resp.A216List ? resp.A216List : [];
		gridH1.load(A216List, null, null, ["1"]);
		//J區
		//gridJ1 近三個月同建案紀錄
		var A260List = resp.A260List ? resp.A260List : [];
		gridJ1.load(A260List);
		//K區
		//gridK1 各擔保品鑑價 
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
		//gridL1 各擔保品附屬建物資料
		A217List = resp.A217List ? resp.A217List : [];
		appendGridtoList(A217List, 'gridL1');  
		if (A217List.size() > 0){
			$('div_I3').style.display = 'block';
			$('div_I5').style.display = 'block';
		}else{
			$('div_I3').style.display = 'none';
			$('div_I5').style.display = 'none';
		}
		//M區
		buttons.setTable_M(rtnMap);
		//gridM1 自動估價建議價格
		var A215ListA = resp.A215ListA ? resp.A215ListA : [];
		gridM1.load(A215ListA);
		//gridM2 建議案例平均價格 
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
		//N區
		//gridN1 各擔保品鑑價覆核 
		var A205List = resp.A205List ? resp.A205List : [];
		gridN1.load(A205List);
		//O區
		//gridO1 各擔保品附屬建物資料覆核 
		A217List = resp.A217List ? resp.A217List : [];
		appendGridtoList(A217List, 'gridO1'); 
		//P區
		buttons.setTable_P(rtnMap);
		//gridP1 批示歷程
		A203List = resp.A203List ? resp.A203List : [];
		appendGridtoList(A203List, 'table_P1'); 
		//R區
		//gridR1 評分
		var A107List = resp.A107List ? resp.A107List : [];
		addIndex = A107List.length;
		gridR1.load(A107List);
		
		//價格區間區塊
		$('table_Interval').style.display = 'none';
		if(IS_AUTOAPPR =="2"){//智能件
			//[20210322]價格資料欄位連結
			//鑑估紀錄
			$('COMMPRICE_INTERVAL_VIEW').innerHTML = resp.VALUATION_1 || '';
			//實價登錄
			$('REALPRICE_INTERVAL_VIEW').innerHTML = resp.VALUATION_2 || '';
			//車位價格區間
			$('PARKPRICE_INTERVAL_VIEW').innerHTML = resp.VALUATION_3 || '';
			$('table_Interval').style.display = '';
			if('${APPR_CAPT}'){//若登入人員是鑑價組長，修正按鈕才能顯示
				$("btn_update").show();
			}else{
				$("btn_update").hide();
			}
			$('VISIT_PRICE_L_VIEW').innerHTML = JsUtils.isBasicType(rtnMap.VISIT_PRICE_L) ? rtnMap.VISIT_PRICE_L : '';
			$('VISIT_PRICE_H_VIEW').innerHTML = JsUtils.isBasicType(rtnMap.VISIT_PRICE_H) ? rtnMap.VISIT_PRICE_H : '';
			//綜合分析按鈕
			$w("PER_PRICE_A201_1_btn PER_PRICE_A201_2_btn PER_PRICE_A201_3_btn").each(function(ele){
				$(ele).show();
			});
		}
		
		//日期欄處理		
		autoFormatToDate();
		autoFormatToNumber();
		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value });
		//模擬textarea keyup動作
		$w('DISLIKE_DESC_VIEW SPC_DESC_VIEW LOC_DESC_VIEW CAPT_EXAM_DESC_VIEW BOSS_EXAM_DESC_VIEW GM_EXAM_DESC_VIEW').each( 
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
	
	function queryErrorFunction(resp){					
		//失敗把前次內容清掉 並把鑑價,支援人員list清掉
		var rtnMap = resp.rtnMap ? resp.rtnMap : {};
		viewMap = rtnMap;

		//B區
		buttons.setTable_B(rtnMap,resp);
		//C區
		buttons.setTable_C(rtnMap);
		//E區
		//gridE1 訪價資料
		buttons.setGridE1(resp);	
		//F區
		//gridF1 差異分析
		buttons.setGridF1(resp);
		//G區
		$('LOC_DESC_VIEW').value = rtnMap.LOC_DESC ? rtnMap.LOC_DESC : '';
		//H區
		//gridH1 實價登錄案例建議清單
		var A216List = resp.A216List ? resp.A216List : [];
		gridH1.load(A216List, null, null, ["1"]);		
		//J區
		//gridJ1 近三個月同建案紀錄
		var A260List = resp.A260List ? resp.A260List : [];
		gridJ1.load(A260List);
		//K區
		//gridK1 各擔保品鑑價 
		var A205List = resp.A205List ? resp.A205List : [];
		gridK1.load(A205List);
		//L區
		//gridL1 各擔保品附屬建物資料
		var A217List = resp.A217List ? resp.A217List : [];
		appendGridtoList(A217List, 'gridL1');
		//M區
		buttons.setTable_M(rtnMap);
		//gridM1 自動估價建議價格
		var A215ListA = resp.A215ListA ? resp.A215ListA : [];
		gridM1.load(A215ListA);
		//gridM2 建議案例平均價格 
		var A215ListS = resp.A215ListS ? resp.A215ListS : [];
		gridM2.load(A215ListS);
		//gridM3 社區價格平均價格 20210610 
		var A215ListC = resp.A215ListC ? resp.A215ListC : [];
		gridM3.load(A215ListC);
		<%--[20240613]車位估價紀錄 --%>
		var A215ListP = resp.A215ListP ? resp.A215ListP : [];
		gridMP.load(A215ListP);
		<%--[20250211]公寓估價紀錄 --%>
		var A215ListM = resp.A215ListM ? resp.A215ListM : [];
		gridMM.load(A215ListM);
		//N區
		//gridN1 各擔保品鑑價覆核
		var A205List = resp.A205List ? resp.A205List : [];
		gridN1.load(A205List);
		//O區
		//gridO1 各擔保品附屬建物資料覆核
		A217List = resp.A217List ? resp.A217List : [];
		appendGridtoList(A217List, 'gridO1');
		//P區
		buttons.setTable_P(rtnMap);
		//gridP1 批示歷程
		A203List = resp.A203List ? resp.A203List : [];
		appendGridtoList(A203List, 'table_P1');
		//R區
		//gridR1 評分
		var A107List = resp.A107List ? resp.A107List : [];
		gridR1.load(A107List);
		//日期欄處理
		autoFormatToDate();
		autoFormatToNumber();
		//模擬textarea keyup動作
		$w('DISLIKE_DESC_VIEW SPC_DESC_VIEW LOC_DESC_VIEW CAPT_EXAM_DESC_VIEW BOSS_EXAM_DESC_VIEW GM_EXAM_DESC_VIEW').each( 
			function(id){
				$(id).simulate('keyup');
			}
		);
		
		<%--[20211018] 使用 InputUtility.js 調整成讓 CHORME textarea也能依照內容自動調整欄位高度--%>
		$$('textarea').each(function(e){	
			InputUtility.autoSizingTextarea.doAutoSize(e); //依內容調整高度
		});
	}
	<%--[20250211]M區tableui設定--%>
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
		}
	};
	//buttons對應的event function
	var buttons = {
	
		//設定畫面資料
		//table_B1,table_B2
		setTable_B : function(rtnMap,resp){
			$('APPLY_PROCESS_NM_VIEW').innerHTML=rtnMap.APPLY_PROCESS_NM ? rtnMap.APPLY_PROCESS_NM : '';
			$('AREA_CODE_VIEW').innerHTML=rtnMap.AREA_CODE_NM ? rtnMap.AREA_CODE_NM+'區' : '';
			$('AREA_CODE_930318').setValue(rtnMap.AREA_CODE_930318||'');
			/*if(rtnMap.AREA_CODE) {
				$('AREA_CODE_VIEW').innerHTML=rtnMap.MAP_AREA_CODE ? rtnMap.AREA_CODE+'區(定位'+rtnMap.MAP_AREA_CODE+'區)' : rtnMap.AREA_CODE+'區';
			}else{
				$('AREA_CODE_VIEW').innerHTML=rtnMap.MAP_AREA_CODE ? '(定位'+rtnMap.MAP_AREA_CODE+'區)' : '';
			}*/
			$('APPR_PROCESS_VIEW').innerHTML=rtnMap.APPR_PROCESS_NM ? rtnMap.APPR_PROCESS_NM : '';
			$('UPLOAD_DATE_VIEW').innerHTML=rtnMap.UPLOAD_DATE ? Date.toROC(rtnMap.UPLOAD_DATE) : '';
			
			$('INPUT_NAME_VIEW').innerHTML=rtnMap.INPUT_NAME ? rtnMap.INPUT_NAME : '';
			$('INPUT_DATE_VIEW').innerHTML=rtnMap.INPUT_DATE ? Date.toROC(rtnMap.INPUT_DATE) : '';
			$('INPUT_DATE').value=rtnMap.INPUT_DATE;
			$('IS_SIMPLE_O').value=rtnMap.IS_SIMPLE ? rtnMap.IS_SIMPLE : '1'; //前件是否為簡易報告
			$('APPR_NM_VIEW').innerHTML=rtnMap.APPR_NM ? rtnMap.APPR_NM : '';
			$('AGENCY_NAME_VIEW').innerHTML=rtnMap.AGENCY_NAME ? rtnMap.AGENCY_NAME : '';

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

			//$('BUILD_TYPE_VIEW').value=rtnMap.BUILD_TYPE ? rtnMap.BUILD_TYPE : '';
			//預帶所在樓層/總樓層
			var floorMemoStr="";
			if($('FLOOR_MEMO').value){
				floorMemoStr=" "+ $('FLOOR_MEMO').value;
			}
			$('BUILD_TYPE_VIEW').value=rtnMap.BUILD_TYPE ? rtnMap.BUILD_TYPE : changeBUILDTYPE();
			$('USE_FOR_VIEW').value=rtnMap.USE_FOR ? rtnMap.USE_FOR : '';
			
			$('GAGE_ADDR_VIEW').innerHTML=rtnMap.GAGE_ADDR ? rtnMap.GAGE_ADDR : '';

			$('A040_LAND_SPACE_VIEW').innerHTML=rtnMap.A040_LAND_SPACE ? CSRUtil.$fmt(rtnMap.A040_LAND_SPACE, defaultPattern2)+'坪' : '0坪';
			$('A050_BUILD_SPACE_VIEW').innerHTML=rtnMap.A050_BUILD_SPACE ? CSRUtil.$fmt(rtnMap.A050_BUILD_SPACE, defaultPattern2)+'坪' : '0坪';
			$('BUILD_AGE_VIEW').innerHTML=rtnMap.A050_BUILD_AGE ? CSRUtil.$fmt(rtnMap.A050_BUILD_AGE, defaultPattern2)+'年' : '0年';
			$('USE_AREA1_VIEW').value=rtnMap.USE_AREA1 ? rtnMap.USE_AREA1 : '';
			$('USE_AREA2_VIEW').value=rtnMap.USE_AREA2 ? rtnMap.USE_AREA2 : '';
						
			$('FINISH_DATE').value=rtnMap.FINISH_DATE ? rtnMap.FINISH_DATE : '';
			$('LONGITUDE').value=rtnMap.PIC_LONGITUDE ? rtnMap.PIC_LONGITUDE : ''; //預帶前件經度
			$('LATITUDE').value=rtnMap.PIC_LATITUDE ? rtnMap.PIC_LATITUDE : ''; //預帶前件緯度
			$('ROAD_WIDTH').value=rtnMap.PIC_ROAD_WIDTH ? rtnMap.PIC_ROAD_WIDTH : ''; //預帶前件路寬
			$('LAND_MEASURE').value=rtnMap.A040_LAND_SPACE ? rtnMap.A040_LAND_SPACE : '0';
			$('BUILD_MEASURE').value=rtnMap.A050_BUILD_SPACE ? rtnMap.A050_BUILD_SPACE : '0';
			$('BUILD_AGE').value=rtnMap.A050_BUILD_AGE ? rtnMap.A050_BUILD_AGE : '0';
			$('PIC_CASE_NAME').value=rtnMap.PIC_CASE_NAME ? rtnMap.PIC_CASE_NAME : '';
			$('MAP_AREA_CODE').value=rtnMap.MAP_AREA_CODE ? rtnMap.MAP_AREA_CODE : '';
			
			//[20201105]申請書-201019001927：調整承作分區判斷邏輯
			$('URBAN_PROJECT').options.length = 0;
			var urban_project_list = rtnMap.URBAN_PROJECT_LIST || [];
			if(urban_project_list.length>0){
				isURBAN_PROJECT = true;
				$('URBAN_PROJECT').enable();
				$('URBAN_PROJECT').add(new Option('請選擇都市計畫案', ''));
				urban_project_list.each(function(data) {								
					var option = new Option(data.URBAN_PROJECT_NM, data.POST_CODE+'_'+data.SER_NO);
					$('URBAN_PROJECT').add(option);
				});
				$('URBAN_PROJECT').setValue(rtnMap.URBAN_PROJECT);
			}else{			
				isURBAN_PROJECT = false;
				$('URBAN_PROJECT').add(new Option('無', ''));
				$('URBAN_PROJECT').disable();
			}

			<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%>
			$('SUBMKT_ID').setValue(rtnMap.SUBMKT_ID ||'');
			$('SUBMKT_VERSION').setValue(rtnMap.SUBMKT_VERSION ||'');
			$('SUBMKT_NAME').setValue(rtnMap.SUBMKT_NAME ||'');
			$('AREA_CODE_MATCH_LEVEL').setValue(rtnMap.MATCH_LEVEL || (rtnMap.AREA_CODE_MATCH_LEVEL||''));
			
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
			$('TRADE_AMT_VIEW').value=JsUtils.isBasicType(rtnMap.TRADE_AMT) ? CSRUtil.$fmt(rtnMap.TRADE_AMT, defaultPattern1) : '';
			$('TRADE_DATE_VIEW').value=rtnMap.TRADE_DATE ? Date.toInputROC(rtnMap.TRADE_DATE, '') : '';
			//$('CONTROL_AREA_VIEW').value=rtnMap.CONTROL_AREA ? rtnMap.CONTROL_AREA : '';
			//預帶前件案名
			//$('CASE_NAME_VIEW').value=rtnMap.CASE_NAME ? rtnMap.CASE_NAME : rtnMap.PIC_CASE_NAME;
			$('CASE_NAME_VIEW').value=rtnMap.CASE_NAME ? rtnMap.CASE_NAME : '';
			//預帶前件外觀照日期
			$('APPEARANCE_PIC_DATE_VIEW').value=rtnMap.APPEARANCE_PIC_DATE ? Date.toInputROC(rtnMap.APPEARANCE_PIC_DATE,'') : Date.toInputROC(rtnMap.APPR_PIC_DATE,'');
			//預帶前件受理編號
			$('FOLLOW_NUMBER_VIEW').value=rtnMap.PIC_APPLY_ID ? rtnMap.PIC_APPLY_ID : '';
			if(rtnMap.PIC_APPLY_ID) {				
				var PIC_APPLY_ID = rtnMap.PIC_APPLY_ID;
				var url1;
				if(${IS_BANK_USER}){
					var ActionType;
					if (PIC_APPLY_ID.substring(3,5)=='@A' || PIC_APPLY_ID.substring(3,5)=='@I' || PIC_APPLY_ID.substring(3,5)=='@J') {
						ActionType = '02'; //土建融鑑價報告
					} else if (PIC_APPLY_ID.substring(3,5)=='@B' || PIC_APPLY_ID.substring(3,5)=='@U' || PIC_APPLY_ID.substring(3,5)=='@V') {
					 	ActionType = '03'; //整批分戶鑑價報告
					} else {
					 	ActionType = '01'; //鑑價報告
				 	}
				 	url1 = "<%=dispatcher%>/DSA3_2400/prompt";
					//產生超連結
					var link = new Element('a',
					{ href: '#'}).update(PIC_APPLY_ID).observe('click',
						function() {
							popupWin.windowOpen( url1 ,
							{
								'parameters': {'CathayNo': PIC_APPLY_ID, 'ActionType': ActionType},
								'fullScreen': false,
								'attributes': {'resizable': 'yes'},
								'windowName': 'DSA30500'
							});
						}
					);	
					$('FOLLOW_NUMBER_LINK_VIEW').update(link);
				} else {
					if (PIC_APPLY_ID.substring(3,5)=='@A' || PIC_APPLY_ID.substring(3,5)=='@I' || PIC_APPLY_ID.substring(3,5)=='@J') {
						url1 = '<%=dispatcher%>/DSA3_0600/prompt';
					} else if (PIC_APPLY_ID.substring(3,5)=='@B' || PIC_APPLY_ID.substring(3,5)=='@U' || PIC_APPLY_ID.substring(3,5)=='@V') {
					 	url1 = '<%=dispatcher%>/DSA3_0700/prompt';
					} else {
					 	url1 = '<%=dispatcher%>/DSA3_0500/prompt';
				 	}
				 	//產生超連結
					var link = new Element('a',
					{ href: '#'}).update(PIC_APPLY_ID).observe('click',
						function() {
							popupWin.windowOpen( url1 ,
							{
								'parameters': {'APPLY_ID': PIC_APPLY_ID},
								'fullScreen': false,
								'attributes': {'resizable': 'yes'}
							});
						}
					);	
					$('FOLLOW_NUMBER_LINK_VIEW').update(link);
				}
			}	
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
				$('COMMUNITY_NO_LINK_VIEW').update('');
			}
			resetSPC_CONDITION(rtnMap);//重設特殊屋況檢核區塊
			
			$('PUB_RATE_VIEW').value=JsUtils.isBasicType(rtnMap.PUB_RATE) ? CSRUtil.$fmt(rtnMap.PUB_RATE, defaultPattern1) : '';
			$('PARK_VIEW').value=JsUtils.isBasicType(rtnMap.PARK) ? CSRUtil.$fmt(rtnMap.PARK, defaultPattern1) : '';
			$('PARK_NO_VIEW').value=rtnMap.PARK_NO ? rtnMap.PARK_NO : '';
			$('PARK_SPACE_VIEW').value=JsUtils.isBasicType(rtnMap.PARK_SPACE) ? CSRUtil.$fmt(rtnMap.PARK_SPACE, defaultPattern2) : '';
			$('DISLIKE_DESC_VIEW').value=rtnMap.DISLIKE_DESC ? rtnMap.DISLIKE_DESC : '';
			$('SPC_DESC_VIEW').value=rtnMap.SPC_DESC ? rtnMap.SPC_DESC : '';
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
			
			//EF區擔保品資料
			$('ADDRESS_A201_VIEW').innerHTML=rtnMap.GAGE_ADDR ? rtnMap.GAGE_ADDR : '';
			//$('PARK_SPACE_A201_VIEW').innerHTML=rtnMap.PARK_SPACE ? CSRUtil.$fmt(rtnMap.PARK_SPACE, defaultPattern2) : '';
			$('REF_TIME_A201_VIEW').innerHTML=rtnMap.UPLOAD_DATE ? Date.toROC(rtnMap.UPLOAD_DATE) : '';
			$('BUILD_AGE_A201_VIEW').innerHTML=rtnMap.A050_BUILD_AGE ? rtnMap.A050_BUILD_AGE : '';
			var A201Map = rtnMap.A201Map;
			if(A201Map){
				$('FLOOR_A201_VIEW').value=A201Map.FLOOR ? A201Map.FLOOR : '';
				$('BUILD_SPACE_A201_VIEW').value=A201Map.BUILD_SPACE ? CSRUtil.$fmt(A201Map.BUILD_SPACE, defaultPattern1) : '';
				//$('PARK_TYPE_A201_VIEW').innerHTML=A201Map.PARK_TYPE ? A201Map.PARK_TYPE : '';
				//$('PARK_NUM_A201_VIEW').value=A201Map.PARK_NUM ? CSRUtil.$fmt(A201Map.PARK_NUM, defaultPattern1) : '';
			}else{
				var targetFloorStr=$('TARGET_FLOOR').value;
				if(JsUtils.isNumeric(targetFloorStr)){
					targetFloorStr = $('TARGET_FLOOR').value<0? "B"+$('TARGET_FLOOR').value.substring(1):$('TARGET_FLOOR').value;
					$('FLOOR_A201_VIEW').value = targetFloorStr +'/'+CSRUtil.$fmt( $('TOTAL_FLOOR').getValue() , "###");
				}else{
					$('FLOOR_A201_VIEW').value=rtnMap.BUILD_TYPE;
				}
				$('BUILD_SPACE_A201_VIEW').value=JsUtils.isBasicType(rtnMap.BUILD_AREA) ? CSRUtil.$fmt(rtnMap.BUILD_AREA, defaultPattern1) : '';
				//$('PARK_TYPE_A201_VIEW').innerHTML=JsUtils.isBasicType(rtnMap.PARK) ? $('PARK_VIEW').options[$('PARK_VIEW').selectedIndex].text : '';
				//$('PARK_NUM_A201_VIEW').value='';
			}
		},
		
		//gridE1
		setGridE1 : function(resp){		
					
			var A201List = resp.A201List ? resp.A201List : [];
			
			if(A201List){
				for(var i = 1; i <= A201List.length; i++){
					if (i <= 3) { //若是一般鑑價報告有4筆,但簡易報告只有3筆
						var obj = A201List[i-1];
						$('SEQ_NO_A201_'+i).value = JsUtils.isBasicType(obj.SEQ_NO) ? obj.SEQ_NO : '';
						$('APPLY_ID_A201_'+i).value = JsUtils.isBasicType(obj.APPLY_ID) ? obj.APPLY_ID : '';
						$('ADDRESS_A201_'+i).value = JsUtils.isBasicType(obj.ADDRESS) ? obj.ADDRESS : '';
						$('REF_TIME_A201_'+i).value = JsUtils.isBasicType(obj.REF_TIME) ? obj.REF_TIME : '';
						$('BUILD_AGE_A201_'+i).value = JsUtils.isBasicType(obj.BUILD_AGE) ? obj.BUILD_AGE : '';
						$('FLOOR_A201_'+i).value = JsUtils.isBasicType(obj.FLOOR) ? obj.FLOOR : '';
						$('BUILD_SPACE_A201_'+i).value = JsUtils.isBasicType(obj.BUILD_SPACE) ? obj.BUILD_SPACE : '';
						$('PER_PRICE_A201_'+i).value = JsUtils.isBasicType(obj.PER_PRICE) ? obj.PER_PRICE : '';
						$('TOTAL_PRICE_A201_'+i).value = JsUtils.isBasicType(obj.TOTAL_PRICE) ? obj.TOTAL_PRICE : '';
						$('PARK_SPACE_A201_'+i).value = JsUtils.isBasicType(obj.PARK_SPACE) ? obj.PARK_SPACE : '';
						$('PARK_PRICE_A201_'+i).value = JsUtils.isBasicType(obj.PARK_PRICE) ? obj.PARK_PRICE : '';
						$('REF_SRC_A201_'+i).value = JsUtils.isBasicType(obj.REF_SRC) ? obj.REF_SRC : '';
						$('TIME_TEL_A201_'+i).value = JsUtils.isBasicType(obj.TIME_TEL) ? obj.TIME_TEL : '';
						$('PARK_TYPE_A201_'+i).value = JsUtils.isBasicType(obj.PARK_TYPE) ? obj.PARK_TYPE : '';
						$('PARK_NUM_A201_'+i).value = JsUtils.isBasicType(obj.PARK_NUM) ? obj.PARK_NUM : '';
					}
				}
			}
		},
		//gridE1 訪價匯入
		setRefGridE1 : function(resp){
		
			var A201List = resp.A201List ? resp.A201List : [];
			
			if(A201List){
				for(var i = 1; i <= A201List.length; i++){
					var obj = A201List[i-1];
					//取得對應SEQ_NO寫入畫面欄位 EX:SEQ_NO=1對應訪價資料甲,SEQ_NO=2對應訪價資料乙...
					var j = JsUtils.isBasicType(obj.SEQ_NO) ? obj.SEQ_NO : '';
					if (j != '' && j <= 3) { //若是一般鑑價報告有4筆,但簡易報告只有3筆
						$('SEQ_NO_A201_'+j).value = JsUtils.isBasicType(obj.SEQ_NO) ? obj.SEQ_NO : '';
						$('APPLY_ID_A201_'+j).value = JsUtils.isBasicType(obj.APPLY_ID) ? obj.APPLY_ID : '';
						$('ADDRESS_A201_'+j).value = JsUtils.isBasicType(obj.ADDRESS) ? obj.ADDRESS : '';
						$('REF_TIME_A201_'+j).value = JsUtils.isBasicType(obj.REF_TIME) ? obj.REF_TIME : '';
						$('BUILD_AGE_A201_'+j).value = JsUtils.isBasicType(obj.BUILD_AGE) ? obj.BUILD_AGE : '';
						$('FLOOR_A201_'+j).value = JsUtils.isBasicType(obj.FLOOR) ? obj.FLOOR : '';
						$('BUILD_SPACE_A201_'+j).value = JsUtils.isBasicType(obj.BUILD_SPACE) ? obj.BUILD_SPACE : '';
						$('PER_PRICE_A201_'+j).value = JsUtils.isBasicType(obj.PER_PRICE) ? obj.PER_PRICE : '';
						$('TOTAL_PRICE_A201_'+j).value = JsUtils.isBasicType(obj.TOTAL_PRICE) ? obj.TOTAL_PRICE : '';
						$('PARK_SPACE_A201_'+j).value = JsUtils.isBasicType(obj.PARK_SPACE) ? obj.PARK_SPACE : '';
						$('PARK_PRICE_A201_'+j).value = JsUtils.isBasicType(obj.PARK_PRICE) ? obj.PARK_PRICE : '';
						$('REF_SRC_A201_'+j).value = JsUtils.isBasicType(obj.REF_SRC) ? obj.REF_SRC : '';
						$('TIME_TEL_A201_'+j).value = JsUtils.isBasicType(obj.TIME_TEL) ? obj.TIME_TEL : '';
						$('PARK_TYPE_A201_'+j).value = JsUtils.isBasicType(obj.PARK_TYPE) ? obj.PARK_TYPE : '';
						$('PARK_NUM_A201_'+j).value = JsUtils.isBasicType(obj.PARK_NUM) ? obj.PARK_NUM : '';
					}
				}
			}
		},
		
		//gridF1
		setGridF1 : function(resp){

			var A209List = resp.A209List ? resp.A209List : [];
			
			if(A209List && A209List.length != 0){
				$('DIFF_KIND_A_A209_VIEW').value = JsUtils.isBasicType(A209List[0].DIFF_KIND_A) ? A209List[0].DIFF_KIND_A : '';
				$('DIFF_KIND_B_A209_VIEW').value = JsUtils.isBasicType(A209List[0].DIFF_KIND_B) ? A209List[0].DIFF_KIND_B : '';
				$('LOWER_PRICE_A209_VIEW').value = JsUtils.isBasicType(A209List[0].LOWER_PRICE) ? A209List[0].LOWER_PRICE : '';
				$('UPPER_PRICE_A209_VIEW').value = JsUtils.isBasicType(A209List[0].UPPER_PRICE) ? A209List[0].UPPER_PRICE : '';
				
				for(var i = 1; i <= A209List.length; i++){
					if (i <= 3) { //若是一般鑑價報告有4筆,但簡易報告只有3筆
						var obj = A209List[i-1];
						$('APPLY_ID_A209_'+i).value = JsUtils.isBasicType(obj.APPLY_ID) ? obj.APPLY_ID : '';
						$('DIFF_TIME_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_TIME) ? obj.DIFF_TIME : '';
						$('DIFF_TRAFFIC_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_TRAFFIC) ? obj.DIFF_TRAFFIC : '';
						$('DIFF_LIFE_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_LIFE) ? obj.DIFF_LIFE : '';
						$('DIFF_NEAR_ROAD_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_NEAR_ROAD) ? obj.DIFF_NEAR_ROAD : '';
						$('DIFF_BUILD_AGE_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_BUILD_AGE) ? obj.DIFF_BUILD_AGE : '';
						$('DIFF_FLOOR_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_FLOOR) ? obj.DIFF_FLOOR : '';
						$('DIFF_MEASURE_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_MEASURE) ? obj.DIFF_MEASURE : '';
						$('DIFF_OPTION_A_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_OPTION_A) ? obj.DIFF_OPTION_A : '';
						$('DIFF_OPTION_B_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_OPTION_B) ? obj.DIFF_OPTION_B : '';
						$('DIFF_SYNTH_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_SYNTH) ? obj.DIFF_SYNTH : '';
					}
				}
			}
		},
		
		//table_M 建議價格
		setTable_M : function(rtnMap){
			$('PARK_NUM_VIEW_1').value=JsUtils.isBasicType(rtnMap.PARK_NUM) ? CSRUtil.$fmt(rtnMap.PARK_NUM, defaultPattern1) : '';
			$('PARK_AMT_VIEW_1').value=JsUtils.isBasicType(rtnMap.PARK_AMT) ? CSRUtil.$fmt(rtnMap.PARK_AMT, defaultPattern1) : '';
			$('PARK_SPACEB_VIEW').value=JsUtils.isBasicType(rtnMap.PARK_SPACEB) ? CSRUtil.$fmt(rtnMap.PARK_SPACEB, defaultPattern2) : '';
			$('PARK_SPACEB1_VIEW').innerHTML=JsUtils.isBasicType(rtnMap.PARK_SPACEB) ? CSRUtil.$fmt(rtnMap.PARK_SPACEB, defaultPattern2) : '';
			$('PER_PRICE_VIEW').value=JsUtils.isBasicType(rtnMap.PER_PRICE) ? CSRUtil.$fmt(rtnMap.PER_PRICE, defaultPattern1) : '';
			$('TOTAL_PRICE_VIEW').value=JsUtils.isBasicType(rtnMap.TOTAL_PRICE) ? CSRUtil.$fmt(rtnMap.TOTAL_PRICE, defaultPattern1) : '';
			$('AVG_PRICE_VIEW').value=JsUtils.isBasicType(rtnMap.AVG_PRICE) ? CSRUtil.$fmt(rtnMap.AVG_PRICE, defaultPattern1) : '';
			$('FORMULA1_VIEW').value=rtnMap.FORMULA ? rtnMap.FORMULA : '';
			$('FORMULA_VIEW').value=rtnMap.FORMULA ? rtnMap.FORMULA : '';
			$('TOTAL_PRICE_B_VIEW').innerHTML=JsUtils.isBasicType(rtnMap.TOTAL_PRICE) ? CSRUtil.$fmt(rtnMap.TOTAL_PRICE, defaultPattern1) + '萬' : '';
		},
		
		//table_P 覆核
		setTable_P : function(rtnMap){
			$('CAPT_EXAM_VIEW').value=rtnMap.CAPT_EXAM ? rtnMap.CAPT_EXAM : '';
			$('CAPT_EXAM_DESC_VIEW').value=rtnMap.CAPT_EXAM_DESC ? rtnMap.CAPT_EXAM_DESC : '';
			$('CAPT_PARK_PRICEA_VIEW').value=rtnMap.CAPT_PARK_PRICEA ? CSRUtil.$fmt(rtnMap.CAPT_PARK_PRICEA, defaultPattern1) : '0';
			$('CAPT_PARK_NUMA_VIEW').value=rtnMap.CAPT_PARK_NUMA ? CSRUtil.$fmt(rtnMap.CAPT_PARK_NUMA, defaultPattern1) : '0';
			$('CAPT_PER_PRICEA_VIEW').value=rtnMap.CAPT_PER_PRICEA ? CSRUtil.$fmt(rtnMap.CAPT_PER_PRICEA, defaultPattern1) : '0';
			$('CAPT_TOTAL_PRICEA_VIEW').value=rtnMap.CAPT_TOTAL_PRICEA ? CSRUtil.$fmt(rtnMap.CAPT_TOTAL_PRICEA, defaultPattern1) : '0';
			$('CAPT_AVG_PRICEA_VIEW').value=rtnMap.CAPT_AVG_PRICEA ? CSRUtil.$fmt(rtnMap.CAPT_AVG_PRICEA, defaultPattern1) : '0';
			$('CAPT_PARK_SPACEA_VIEW').value=rtnMap.CAPT_PARK_SPACEA ? CSRUtil.$fmt(rtnMap.CAPT_PARK_SPACEA, defaultPattern2) : '0';
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
			$('BOSS_PARK_PRICEA_VIEW').value=rtnMap.BOSS_PARK_PRICEA ? CSRUtil.$fmt(rtnMap.BOSS_PARK_PRICEA, defaultPattern1) : '0';
			$('BOSS_PARK_NUMA_VIEW').value=rtnMap.BOSS_PARK_NUMA ? CSRUtil.$fmt(rtnMap.BOSS_PARK_NUMA, defaultPattern1) : '0';
			$('BOSS_PER_PRICEA_VIEW').value=rtnMap.BOSS_PER_PRICEA ? CSRUtil.$fmt(rtnMap.BOSS_PER_PRICEA, defaultPattern1) : '0';
			$('BOSS_TOTAL_PRICEA_VIEW').value=rtnMap.BOSS_TOTAL_PRICEA ? CSRUtil.$fmt(rtnMap.BOSS_TOTAL_PRICEA, defaultPattern1) : '0';
			$('BOSS_AVG_PRICEA_VIEW').value=rtnMap.BOSS_AVG_PRICEA ? CSRUtil.$fmt(rtnMap.BOSS_AVG_PRICEA, defaultPattern1) : '0';
			$('BOSS_PARK_SPACEA_VIEW').value=rtnMap.BOSS_PARK_SPACEA ? CSRUtil.$fmt(rtnMap.BOSS_PARK_SPACEA, defaultPattern2) : '0';
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
			$('ADDRESS_A201_'+val).value=rtnMap.ADDR ? rtnMap.ADDR.trim() : '';
			$('BUILD_AGE_A201_'+val).value=rtnMap.OBJ_AGE ? CSRUtil.$fmt(rtnMap.OBJ_AGE, defaultPattern1) : '';
			$('PER_PRICE_A201_'+val).value=rtnMap.UNIT_PRICE ? CSRUtil.$fmt(rtnMap.UNIT_PRICE, defaultPattern1) : '';
			$('FLOOR_A201_'+val).value= (rtnMap.OBJ_FLOOR ? CSRUtil.$fmt(rtnMap.OBJ_FLOOR, defaultPattern1) : '0') + '/' + (rtnMap.BLD_FLOOR ? CSRUtil.$fmt(rtnMap.BLD_FLOOR, defaultPattern1) : '0');
			$('BUILD_SPACE_A201_'+val).value=rtnMap.OBJ_AREA ? CSRUtil.$fmt(rtnMap.OBJ_AREA, defaultPattern1) : '';
			$('TOTAL_PRICE_A201_'+val).value=rtnMap.PRICE ? CSRUtil.$fmt(rtnMap.PRICE, defaultPattern1) : '';
			$('REF_TIME_A201_'+val).value=rtnMap.DEAL_DATE ? rtnMap.DEAL_DATE : '0';
			$('PARK_SPACE_A201_'+val).value=rtnMap.PAREA ? CSRUtil.$fmt(rtnMap.PAREA, defaultPattern1) : '';
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
						
		//查詢比較建坪
		doGetBuildSpaceA201 : function(park_space, build_space){
			//發送ajax
			ajaxPost( 'getBuildSpaceA201' , {'PARK_SPACE' : park_space.value.replace(/,/gi,''), 'BUILD_SPACE' : build_space.value}, true,
				function(resp){	
					$('BUILD_SPACE_A201_VIEW').value = resp.buildSpaceA201 ? CSRUtil.$fmt(resp.buildSpaceA201, defaultPattern1) : 0;
				},
				function(resp){					
					//失敗把前次內容清掉 
					$('BUILD_SPACE_A201_VIEW').value = '0';
				}
			);		
		},
		
		//查詢聯徵鑑價記錄
		doQueryMAM003 : function(val){

			if ($('TIME_TEL_A201_'+val).value!='' && $('REF_SRC_A201_'+val).value=='F'){
			
				//發送ajax
				ajaxPost( 'queryMAM003' , {'TIME_TEL' : $('TIME_TEL_A201_' + val).value, 'APPLY_ID': $F('APPLY_ID') },true,
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
	
		//查詢資料
		doQuery : function(event){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
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
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}	

			//將畫面欄位存成record
			var sendRecord = makeRecord();	
			//將查詢條件存起來
			queryCondition = sendRecord;	
			//發送ajax
			ajaxPost( 'reQuery' , {sendRecord : Object.toJSON(sendRecord) },false,
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
				valid4.define( "validatePARK" , { id: record.id } );
			});
			if(!valid4.validate()){ 
				return; 
			}

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
				valid4.define( "validatePARK" , { id: record.id } );
			});
			if(!valid4.validate()){ 
				return; 
			}
	
			inputMap = makeInputMap('update');
			
			var paramMap = {'sendRecord' : Object.toJSON(queryCondition), 'inputMap' : Object.toJSON(inputMap) };	
			
			//發送ajax
			ajaxPost( 'update' , paramMap,true, querySuccessFunction,
					function(resp){					
						//修正失敗時，若是智能件，須更新智能價格區間 
						var rtnMap = resp.rtnMap ? resp.rtnMap : {};
						var IS_AUTOAPPR=rtnMap.IS_AUTOAPPR;
						$('IS_AUTOAPPR').setValue(IS_AUTOAPPR);
						if(IS_AUTOAPPR =="2"){//智能件							
							$('VISIT_PRICE_L_VIEW').innerHTML = JsUtils.isBasicType(rtnMap.VISIT_PRICE_L) ? rtnMap.VISIT_PRICE_L : '';
							$('VISIT_PRICE_H_VIEW').innerHTML = JsUtils.isBasicType(rtnMap.VISIT_PRICE_H) ? rtnMap.VISIT_PRICE_H : '';
							viewMap.VISIT_PRICE_L=rtnMap.VISIT_PRICE_L;
							viewMap.VISIT_PRICE_H=rtnMap.VISIT_PRICE_H;
						}
					}		
			);

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
				valid4.define( "validatePARK" , { id: record.id } );
			});
			if(!valid4.validate()){ 
				return; 
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
				valid4.define( "validatePARK" , { id: record.id } );
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
			//[20210628 ]點選 組長退回時，畫面須檢查 組長批示 
			valid4.clear();
			valid4.reset();
			if($F('IS_AUTOAPPR')=='2'){
				valid4.define( "required" , { id: "CAPT_EXAM_DESC_VIEW" , errMsg :"智能轉一般案件請註記原因"  } );
			}	
			if(!valid4.validate()){ 
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
				valid4.define( "validatePARK" , { id: record.id } );
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
			
			//檢核3
			settingValid2('gmConfirm');
			if(!valid2.validate()){ 
				return; 
			}
			
			//檢核4
			//[20201012]新增各擔保品附屬建物資料車位檢核
			valid4.clear();
			valid4.reset();
			$$('#gridL1 select').each(function(record){
				valid4.define( "validatePARK" , { id: record.id } );
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
			ajaxPost( 'copyPicAlbum' , {
							'APPLY_ID' : $('APPLY_ID').value, 
							'FOLLOW_NUMBER' : $('COMMUNITY_NO_VIEW').value, 
							'APPEARANCE_PIC_DATE' : $("APPEARANCE_PIC_DATE_VIEW").value
						}, true,
				function(resp){	
					
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
	
			var XML = {};
			XML.APPLY_ID = $F('APPLY_ID');
			XML.GAGE_ADDR = $('GAGE_ADDR_VIEW').innerHTML;
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
			inputMap.IS_SIMPLE = '1'; //簡易鑑價報告
			inputMap.COMMUNITY_NO = $('COMMUNITY_NO_LINK_VIEW').innerHTML.stripTags(); //[20210323]社區編號
			
			//發送ajax
			ajaxPost( 'getA216List', {'inputMap' : Object.toJSON(inputMap) } , true,
				function(resp){	
					//gridH1
					var A216List = resp.A216List ? resp.A216List : [];
					gridH1.load(A216List, null, null, ["1"]);
					//gridM2
					var A215ListS = resp.A215ListS ? resp.A215ListS : [];
					gridM2.load(A215ListS);
					//[20210322]智能價格區間: 建議案例
					//異動結果存回viewMap
					viewMap.VISIT_PRICE_L=resp.VISIT_PRICE_L || '';
					viewMap.VISIT_PRICE_H=resp.VISIT_PRICE_H || '';
					$('VISIT_PRICE_L_VIEW').innerHTML = resp.VISIT_PRICE_L || '' ;
					$('VISIT_PRICE_H_VIEW').innerHTML = resp.VISIT_PRICE_H || '' ;
				},
				function(resp){					
					//失敗保留畫面資料
				}
			);		
		},
		
		//(3)自動估價
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
			inputMap.IS_SIMPLE = '1'; //簡易鑑價報告
			inputMap.TRADE_AMT = $F('TRADE_AMT_VIEW') ? $F('TRADE_AMT_VIEW'): '';
			inputMap.WELL_CONTRACT = WELL_CONTRACT ? WELL_CONTRACT: '';
			inputMap.COMMUNITY_NO = $('COMMUNITY_NO_LINK_VIEW').innerHTML.stripTags(); //[20210323]社區編號
			
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
					//[20210322]智能價格區間: 自動估價
					//異動結果存回viewMap
					viewMap.VISIT_PRICE_L=resp.VISIT_PRICE_L || '';
					viewMap.VISIT_PRICE_H=resp.VISIT_PRICE_H || '';
					$('VISIT_PRICE_L_VIEW').innerHTML = resp.VISIT_PRICE_L || '' ;
					$('VISIT_PRICE_H_VIEW').innerHTML = resp.VISIT_PRICE_H || '' ;
					<%--[20240613]車位估價紀錄 --%>
					var A215ListP = resp.A215ListP ? resp.A215ListP : [];
					gridMP.load(A215ListP);
					<%--[20250211]公寓估價紀錄 --%>
					var A215ListM = resp.A215ListM ? resp.A215ListM : [];
					gridMM.load(A215ListM);
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
			ajaxPost( 'reSend' , {'APPLY_ID' : $('APPLY_ID').value, 'MAP_AREA_CODE' : $('MAP_AREA_CODE').value ,
				'AREA_CODE_930318' : $F('AREA_CODE_930318')},true );
		},
		
		//列印
		doPrint : function(event){
		
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			
			<c:choose>
				<c:when test="${fromPublicBean eq 'DSA3_2400'}">var action = "DSA3_2400/simplePrint";</c:when>
				<c:otherwise>var action = "DSA3_0500/simplePrint";</c:otherwise>
			</c:choose>
			new Ajax.Request( "<%=dispatcher%>/"+action, {
				parameters: { APPLY_ID : $F('encryptAPPLY_ID'), ActionType : '${ActionType}'},
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
			
			var successActionOpen = function(resp){
				if(resp.isExternal && resp.isApprExternalAuth) { //高級主管由外網登入開啟影像
					RPTUtil.download({'downloadFileName': resp.apprFileNM,	'downloadFileFullPath': resp.apprPath});
				} else {
					window.open(resp.apprPath);
				}
			};
			
			
			ajaxPost('getFile',params,true,successActionOpen,null);
		},
		
		//超連結 "土地、建物謄本影像"
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
		
		doCalculatePrice:function(btnName){
			var nameSet=btnName.split("_");
			var ser=nameSet[nameSet.length-2];
			//先清空
			$('PER_PRICE_A201_'+ser).value = '';
			var reqMap={
				TOTAL_PRICE:$('TOTAL_PRICE_A201_'+ser).value.replace(/,/gi,''),
				BUILD_SPACE:$('BUILD_SPACE_A201_'+ser).value.replace(/,/gi,'')
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
					$('PER_PRICE_A201_'+ser).setValue((rtnPrice===0||rtnPrice)?rtnPrice:'');
				}
			);
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
		
		//自動分析
		doAutoAnalysis : function(){
		
			var inputMap = {};
			var analysisList = [
				makeSingleMapForAutoAnalysis('1'),  
				makeSingleMapForAutoAnalysis('2'),  
				makeSingleMapForAutoAnalysis('3') 
			];
			inputMap.analysisList = analysisList;
			inputMap.BUILD_AGE = $('BUILD_AGE_A201_VIEW').innerHTML;
			inputMap.FLOOR = $F('FLOOR_A201_VIEW');
			inputMap.BUILD_SPACE = $F('BUILD_SPACE_A201_VIEW');
			ajaxPost('autoAnalysis',{inputMap:Object.toJSON(inputMap)},true,
				function(resp){	
					var rtnList = resp.rtnList ? resp.rtnList : [];
					for(var i = 1; i <= rtnList.length; i++){
						if (i <= 3) { //若是一般鑑價報告有4筆,但簡易報告只有3筆
							var obj = rtnList[i-1];
							$('DIFF_BUILD_AGE_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_BUILD_AGE) ? obj.DIFF_BUILD_AGE : '';
							$('DIFF_FLOOR_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_FLOOR) ? obj.DIFF_FLOOR : '';
							$('DIFF_MEASURE_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_MEASURE) ? obj.DIFF_MEASURE : '';
						}
					}
				}
			);
		},
		
		//綜合分析
		doAllAnalysis : function(){
		
			var inputMap = {};
			var analysisList = [
				makeSingleMapForAllAnalysis('1'),  
				makeSingleMapForAllAnalysis('2'),  
				makeSingleMapForAllAnalysis('3') 
			];
			inputMap.analysisList = analysisList;
			
			ajaxPost('allAnalysis',{inputMap:Object.toJSON(inputMap)},true,
				function(resp){	
					var rtnList = resp.rtnList ? resp.rtnList : {};
					for(var i = 1; i <= rtnList.length; i++){
						if (i <= 3) { //若是一般鑑價報告有4筆,但簡易報告只有3筆
							var obj = rtnList[i-1];
							$('DIFF_SYNTH_A209_'+i).value = JsUtils.isBasicType(obj.DIFF_SYNTH) ? obj.DIFF_SYNTH : '';
						}
					}
					$('LOWER_PRICE_A209_VIEW').value = JsUtils.isBasicType(resp.LOWER_PRICE) ? resp.LOWER_PRICE : '';
					$('UPPER_PRICE_A209_VIEW').value = JsUtils.isBasicType(resp.UPPER_PRICE) ? resp.UPPER_PRICE : '';
					alert(resp.PRICE);
				}
			);
		}, 
		
		//[20201105]申請書-201019001927：調整承作分區判斷邏輯
		//連動產生「承作分區」
		doAreaCode : function(){		
					
			ajaxPost('areaCode',{'APPLY_ID':viewMap.APPLY_ID, 'USE_AREA1':$F('USE_AREA1_VIEW'), 'URBAN_PROJECT':$F('URBAN_PROJECT'), 'GAGE_ZIP':viewMap.GAGE_ZIP },true,
				function(resp){	
					var areaCodeMap = resp.areaCodeMap ? resp.areaCodeMap : {};
										
					$('AREA_CODE_VIEW').update(areaCodeMap.AREA_CODE_NM+'區');
					$('AREA_CODE_930318').setValue(areaCodeMap.AREA_CODE_930318);					
				}
			);
		}, 
		
		//報告變更
		doChange : function(){
		
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
			
			if (confirm("確定要變更" + $('APPLY_ID').value + "為一般鑑價報告資料?")) {
				//發送ajax
				ajaxPost( 'change' , {'APPLY_ID' : $('APPLY_ID').value },true,
					function(resp){	
						var LP_JSON = {				  		    
			       			'APPLY_ID' : $F('APPLY_ID')  //受理編號								
			       		};
			            LP_JSON.action = "<%=dispatcher%>/DSA3_0500/prompt?OP=1";
			            CSRUtil.linkTo(LP_JSON , "form1");
					}
				);
			}
		},
		
		doLinkTo3700: function(){<%--[20250213]公寓資料庫--%>
		<%--[20250424] 問題單: 公寓資料庫調整同(同社區編號方式，開啟新視窗，不要用100%遮蔽) --%>
			var paramMap = {
				LINK_FROM: 'DSA30501',
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
	};
	
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
	
	//檢核是否有選擇單選
	function checkRadio(radioName){
		var is_check = false;
		var radioItems = document.getElementsByName(radioName);
		for(var mover =0; mover < radioItems.length ; mover++)
		{
			var targetElement = radioItems[mover];
			if(targetElement.checked) {
				is_check = true;
			}
		}
		return is_check;
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

		rtnMap.IS_SIMPLE = '1'; //簡易鑑價報告
		//B區
		rtnMap.BUILD_TYPE = $('BUILD_TYPE_VIEW').value;
		rtnMap.TARGET_FLOOR=$('TARGET_FLOOR').value;
		rtnMap.USE_FOR = $('USE_FOR_VIEW').value;
		rtnMap.USE_AREA1 = $('USE_AREA1_VIEW').value;
		rtnMap.USE_AREA2 = $('USE_AREA2_VIEW').value;
		rtnMap.BORROW_ID = $('BORROW_ID').value;
		rtnMap.LONGITUDE = $('LONGITUDE').value;
		rtnMap.LATITUDE = $('LATITUDE').value;
		rtnMap.ROAD_WIDTH = $('ROAD_WIDTH').value;
		rtnMap.IS_SIMPLE_O = $('IS_SIMPLE_O').value;
		rtnMap.PIC_CASE_NAME = $('PIC_CASE_NAME').value;
		rtnMap.MAP_AREA_CODE = $('MAP_AREA_CODE').value;
		rtnMap.AREA_CODE_930318 = $F('AREA_CODE_930318');
		rtnMap.URBAN_PROJECT = $F('URBAN_PROJECT');
		<%--[20240311]申請書24020579343：依生活圈判斷承作等級調整--%> 
		rtnMap.SUBMKT_ID = $F('SUBMKT_ID');
		rtnMap.SUBMKT_VERSION = $F('SUBMKT_VERSION');
		rtnMap.SUBMKT_NAME = $F('SUBMKT_NAME');
		rtnMap.AREA_CODE_MATCH_LEVEL = $F('AREA_CODE_MATCH_LEVEL');
		//C區
		if($('IS_LAND_Y').checked ==true){
			rtnMap.IS_LAND = '1';
		}else if($('IS_LAND_N').checked ==true){
			rtnMap.IS_LAND = '0';
		}else {
		    rtnMap.IS_LAND = '';
		}
		rtnMap.TRADE_AMT = $('TRADE_AMT_VIEW').value.replace(/,/gi,'');
		rtnMap.TRADE_DATE = toY2K($('TRADE_DATE_VIEW').value);
		//rtnMap.CONTROL_AREA = $('CONTROL_AREA_VIEW').value;
		rtnMap.CASE_NAME = $('CASE_NAME_VIEW').value;
		rtnMap.APPEARANCE_PIC_DATE = toY2K($('APPEARANCE_PIC_DATE_VIEW').value);
		rtnMap.FOLLOW_NUMBER = $('FOLLOW_NUMBER_VIEW').value;
		rtnMap.COMMUNITY_NO = $('COMMUNITY_NO_VIEW').value;
		rtnMap.SPC_CONDITION = $('SPC_CONDITION_VIEW').checked ? 1 : 0;
		rtnMap.PUB_RATE = $('PUB_RATE_VIEW').value ? $('PUB_RATE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.PARK = $('PARK_VIEW').value ? $('PARK_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.PARK_NO = $('PARK_NO_VIEW').value;
		rtnMap.PARK_SPACE = $('PARK_SPACE_VIEW').value ? $('PARK_SPACE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.DISLIKE_DESC = $('DISLIKE_DESC_VIEW').value;
		rtnMap.SPC_DESC = $('SPC_DESC_VIEW').value;
		
		rtnMap.BROKER_NAME = $('BROKER_NAME').value;
		if($('WELL_CONTRACT_Y').checked ==true){
			rtnMap.WELL_CONTRACT = '1';
		}else if($('WELL_CONTRACT_N').checked ==true){
			rtnMap.WELL_CONTRACT = '0';
		}else {
		    rtnMap.WELL_CONTRACT = '';
		}
		
		//G區
		rtnMap.LOC_DESC = $('LOC_DESC_VIEW').value;
		//M區
		rtnMap.PARK_NUM = $('PARK_NUM_VIEW_1').value ? $('PARK_NUM_VIEW_1').value.replace(/,/gi,'') : '0';
		rtnMap.PARK_AMT = $('PARK_AMT_VIEW_1').value ? $('PARK_AMT_VIEW_1').value.replace(/,/gi,'') : '0';
		rtnMap.PARK_SPACEB = $('PARK_SPACEB_VIEW').value ? $('PARK_SPACEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.PER_PRICE = $('PER_PRICE_VIEW').value ? $('PER_PRICE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.TOTAL_PRICE = $('TOTAL_PRICE_VIEW').value ? $('TOTAL_PRICE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.AVG_PRICE = $('AVG_PRICE_VIEW').value ? $('AVG_PRICE_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.FORMULA = $('FORMULA1_VIEW').value;
		rtnMap.FORMULA = $('FORMULA_VIEW').value;
		//P區
		//組長批示
		rtnMap.CAPT_EXAM = $('CAPT_EXAM_VIEW').value;
		rtnMap.CAPT_EXAM_DESC = $('CAPT_EXAM_DESC_VIEW').value;
		//一般行情
		rtnMap.CAPT_LAND_PRICEA = '0'; //簡易件無地價
		rtnMap.CAPT_BUILD_PRICEA = '0'; //簡易件無造價
		rtnMap.CAPT_PARK_PRICEA = $('CAPT_PARK_PRICEA_VIEW').value ? $('CAPT_PARK_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PARK_NUMA = $('CAPT_PARK_NUMA_VIEW').value ? $('CAPT_PARK_NUMA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PER_PRICEA = $('CAPT_PER_PRICEA_VIEW').value ? $('CAPT_PER_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_TOTAL_PRICEA = $('CAPT_TOTAL_PRICEA_VIEW').value ? $('CAPT_TOTAL_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_AVG_PRICEA = $('CAPT_AVG_PRICEA_VIEW').value ? $('CAPT_AVG_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PARK_SPACEA = $('CAPT_PARK_SPACEA_VIEW').value ? $('CAPT_PARK_SPACEA_VIEW').value.replace(/,/gi,'') : '0';
		//特殊行情
		rtnMap.CAPT_LAND_PRICEB = '0'; //簡易件無地價
		rtnMap.CAPT_BUILD_PRICEB = '0'; //簡易件無造價
		rtnMap.CAPT_PARK_PRICEB = $('CAPT_PARK_PRICEB_VIEW').value ? $('CAPT_PARK_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PARK_NUMB = $('CAPT_PARK_NUMB_VIEW').value ? $('CAPT_PARK_NUMB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PER_PRICEB = $('CAPT_PER_PRICEB_VIEW').value ? $('CAPT_PER_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_TOTAL_PRICEB = $('CAPT_TOTAL_PRICEB_VIEW').value ? $('CAPT_TOTAL_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_AVG_PRICEB = $('CAPT_AVG_PRICEB_VIEW').value ? $('CAPT_AVG_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.CAPT_PARK_SPACEB = $('CAPT_PARK_SPACEB_VIEW').value ? $('CAPT_PARK_SPACEB_VIEW').value.replace(/,/gi,'') : '0';
		//主管批示
		rtnMap.BOSS_EXAM = $('BOSS_EXAM_VIEW').value;
		rtnMap.BOSS_EXAM_DESC = $('BOSS_EXAM_DESC_VIEW').value;
		//一般行情
		rtnMap.BOSS_LAND_PRICEA = '0'; //簡易件無地價
		rtnMap.BOSS_BUILD_PRICEA = '0'; //簡易件無造價
		rtnMap.BOSS_PARK_PRICEA = $('BOSS_PARK_PRICEA_VIEW').value ? $('BOSS_PARK_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PARK_NUMA = $('BOSS_PARK_NUMA_VIEW').value ? $('BOSS_PARK_NUMA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PER_PRICEA = $('BOSS_PER_PRICEA_VIEW').value ? $('BOSS_PER_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_TOTAL_PRICEA = $('BOSS_TOTAL_PRICEA_VIEW').value ? $('BOSS_TOTAL_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_AVG_PRICEA = $('BOSS_AVG_PRICEA_VIEW').value ? $('BOSS_AVG_PRICEA_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PARK_SPACEA = $('BOSS_PARK_SPACEA_VIEW').value ? $('BOSS_PARK_SPACEA_VIEW').value.replace(/,/gi,'') : '0';
		//特殊行情
		rtnMap.BOSS_LAND_PRICEB = '0'; //簡易件無地價
		rtnMap.BOSS_BUILD_PRICEB = '0'; //簡易件無造價
		rtnMap.BOSS_PARK_PRICEB = $('BOSS_PARK_PRICEB_VIEW').value ? $('BOSS_PARK_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PARK_NUMB = $('BOSS_PARK_NUMB_VIEW').value ? $('BOSS_PARK_NUMB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PER_PRICEB = $('BOSS_PER_PRICEB_VIEW').value ? $('BOSS_PER_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_TOTAL_PRICEB = $('BOSS_TOTAL_PRICEB_VIEW').value ? $('BOSS_TOTAL_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_AVG_PRICEB = $('BOSS_AVG_PRICEB_VIEW').value ? $('BOSS_AVG_PRICEB_VIEW').value.replace(/,/gi,'') : '0';
		rtnMap.BOSS_PARK_SPACEB = $('BOSS_PARK_SPACEB_VIEW').value ? $('BOSS_PARK_SPACEB_VIEW').value.replace(/,/gi,'') : '0';
		//部室主管批示
		rtnMap.GM_EXAM_DESC = $('GM_EXAM_DESC_VIEW').value;
		
		//新增、修正、呈核
		if('insert'==action || 'update'==action || 'confirm'==action){
			
			//EF區擔保品資料
			var A201Map = makeSingleMapFromClass('A201_VIEW');
			inputMap.A201Map = A201Map;

			//E區 
			var A201List = [
				makeSingleMapFromClass('A201_1'),  
				makeSingleMapFromClass('A201_2'),  
				makeSingleMapFromClass('A201_3') 
			];
			inputMap.A201List = A201List;
			//F1區 
			var A209List = [
				makeSingleMapFromClass('A209_1'),  
				makeSingleMapFromClass('A209_2'),  
				makeSingleMapFromClass('A209_3') 
			];
			inputMap.A209List = A209List;
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
		//20210721 智能件組長覆核、科主管代理覆核 放入對應資料

		if($F('IS_AUTOAPPR')=='2'){
			//EF區擔保品資料
			var A201Map = makeSingleMapFromClass('A201_VIEW');
			inputMap.A201Map = A201Map;

			//E區 
			var A201List = [
				makeSingleMapFromClass('A201_1'),  
				makeSingleMapFromClass('A201_2'),  
				makeSingleMapFromClass('A201_3') 
			];
			inputMap.A201List = A201List;
			//F1區 
			var A209List = [
				makeSingleMapFromClass('A209_1'),  
				makeSingleMapFromClass('A209_2'),  
				makeSingleMapFromClass('A209_3') 
			];
			inputMap.A209List = A209List;
			
			//M1,M2區
			inputMap.A215ListA = gridM1.getAllRecords();
			inputMap.A215ListS = gridM2.getAllRecords();
			inputMap.A215ListC = gridM3.getAllRecords(); //20210615 社區價格
			inputMap.A215ListP = gridMP.getAllRecords(); <%--[20240613]車位估價紀錄 --%>
			inputMap.A215ListM = gridMM.getAllRecords(); <%--[20250211]公寓估價紀錄--%>
			//H1區
			inputMap.A216List = gridH1.getCheckedRecord();
		}
		inputMap.rtnMap = rtnMap;
		inputMap.CHK_APPLY_ID = $('APPLY_ID').value;
		inputMap.VIEW_APPLY_ID = viewMap.APPLY_ID;
		//R區
		inputMap.A107List = gridR1.getAllRecords();
		
		return inputMap;	
	}
	
	//用class取得屬於自己的map
	function makeSingleMapFromClass(func){
		var returnMap = {};
		if( func=="A201_VIEW") {
			returnMap['FLOOR'] = $F('FLOOR_'+func);
			returnMap['BUILD_SPACE'] = $F('BUILD_SPACE_'+func);
			//returnMap['PARK_TYPE'] = $('PARK_TYPE_'+func).innerHTML;
			//returnMap['PARK_NUM'] = $F('PARK_NUM_'+func);
		}
		if( func=="A201_1" || func=="A201_2" || func=="A201_3") {
			returnMap['ADDRESS'] = $('ADDRESS_'+func).value;
			returnMap['REF_TIME'] = $('REF_TIME_'+func).value;
			returnMap['BUILD_AGE'] = $('BUILD_AGE_'+func).value.replace(/,/gi,'');
			returnMap['FLOOR'] = $('FLOOR_'+func).value;
			returnMap['BUILD_SPACE'] = $('BUILD_SPACE_'+func).value.replace(/,/gi,'');
			returnMap['PER_PRICE'] = $('PER_PRICE_'+func).value.replace(/,/gi,'');
			returnMap['TOTAL_PRICE'] = $('TOTAL_PRICE_'+func).value.replace(/,/gi,'');
			returnMap['PARK_SPACE'] = $('PARK_SPACE_'+func).value.replace(/,/gi,'');
			returnMap['PARK_PRICE'] = $('PARK_PRICE_'+func).value.replace(/,/gi,'');
			returnMap['REF_SRC'] = $('REF_SRC_'+func).value;
			returnMap['TIME_TEL'] = $('TIME_TEL_'+func).value;
			returnMap['PARK_TYPE'] = $('PARK_TYPE_'+func).value;
			returnMap['PARK_NUM'] = $('PARK_NUM_'+func).value.replace(/,/gi,'');
		}
		if( func=="A209_1" || func=="A209_2" || func=="A209_3") {
			returnMap['DIFF_TIME'] = $('DIFF_TIME_'+func).value;
			returnMap['DIFF_TRAFFIC'] = $('DIFF_TRAFFIC_'+func).value;
			returnMap['DIFF_LIFE'] = $('DIFF_LIFE_'+func).value;
			returnMap['DIFF_NEAR_ROAD'] = $('DIFF_NEAR_ROAD_'+func).value;
			returnMap['DIFF_BUILD_AGE'] = $('DIFF_BUILD_AGE_'+func).value;
			returnMap['DIFF_FLOOR'] = $('DIFF_FLOOR_'+func).value;
			returnMap['DIFF_MEASURE'] = $('DIFF_MEASURE_'+func).value;
			returnMap['DIFF_OPTION_A'] = $('DIFF_OPTION_A_'+func).value;
			returnMap['DIFF_OPTION_B'] = $('DIFF_OPTION_B_'+func).value;
			returnMap['DIFF_SYNTH'] = $('DIFF_SYNTH_'+func).value;			
			returnMap['MEASURE_KIND'] = '1';
			returnMap['DIFF_KIND_A'] = $F('DIFF_KIND_A_A209_VIEW');
			returnMap['DIFF_KIND_B'] = $F('DIFF_KIND_B_A209_VIEW');
			returnMap['LOWER_PRICE'] = $F('LOWER_PRICE_A209_VIEW');
			returnMap['UPPER_PRICE'] = $F('UPPER_PRICE_A209_VIEW');
		}
		return returnMap;
	}
	
	//取得自動分析資料的map
	function makeSingleMapForAutoAnalysis(func){
		var returnMap = {};
		returnMap['BUILD_AGE'] = $('BUILD_AGE_A201_'+func).value;
		returnMap['FLOOR'] = $('FLOOR_A201_'+func).value;
		returnMap['BUILD_SPACE'] = $('BUILD_SPACE_A201_'+func).value;
		return returnMap;
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
	
	
	//取得綜合分析資料的map
	function makeSingleMapForAllAnalysis(func){
		var returnMap = {};
		returnMap['PER_PRICE'] = $('PER_PRICE_A201_'+func).value;
		returnMap['DIFF_TIME'] = $('DIFF_TIME_A209_'+func).value;
		returnMap['DIFF_TRAFFIC'] = $('DIFF_TRAFFIC_A209_'+func).value;
		returnMap['DIFF_LIFE'] = $('DIFF_LIFE_A209_'+func).value;
		returnMap['DIFF_NEAR_ROAD'] = $('DIFF_NEAR_ROAD_A209_'+func).value;
		returnMap['DIFF_BUILD_AGE'] = $('DIFF_BUILD_AGE_A209_'+func).value;
		returnMap['DIFF_FLOOR'] = $('DIFF_FLOOR_A209_'+func).value;
		returnMap['DIFF_MEASURE'] = $('DIFF_MEASURE_A209_'+func).value;
		returnMap['DIFF_OPTION_A'] = $('DIFF_OPTION_A_A209_'+func).value;
		returnMap['DIFF_OPTION_B'] = $('DIFF_OPTION_B_A209_'+func).value;
		return returnMap;
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
						insertString1 += "<td class='tbYellow2' width='24%'>" + INPUT_DATE + "　" + EMP_NAME + "　" + CODE_NAME + "</td>";
						if('3'==INPUT_TYPE || '4'==INPUT_TYPE || '5'==INPUT_TYPE){
							insertString1 += "<td class='tbYellow2'><a href='#"+target+"_INPUT_DESC_VIEW_"+mover+"' onClick='DSA30501.doShowdiv_A203List_VIEW("+mover+",\""+target+"\")'>批示</a>：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto; '>" + INPUT_DESC + "</div></td>";
						}else{
							insertString1 += "<td class='tbYellow2'>批示：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto; '>" + INPUT_DESC + "</div></td>";
						}
						insertString1 += "</tr>";
					}else{
						insertString1 += "<tr class=tbBlue3>";
						insertString1 += "<td class='tbYellow2'>" + INPUT_DATE + "　" + EMP_NAME + "　" + CODE_NAME + "</td>";
						if('3'==INPUT_TYPE || '4'==INPUT_TYPE || '5'==INPUT_TYPE){
							insertString1 += "<td class='tbYellow2'><a href='#"+target+"_INPUT_DESC_VIEW_"+mover+"' onClick='DSA30501.doShowdiv_A203List_VIEW("+mover+",\""+target+"\")'>批示</a>：<div id='"+target+"_INPUT_DESC_VIEW_"+mover+"' style='overflow:auto; '>" + INPUT_DESC + "</div></td>";
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
							insertString1 += "<td align=middle>" + ADDR_NO + "</td>";
							insertString1 += "<td align=middle>" + BUILD_NO1 + "-" + BUILD_NO2 + "</td>";
							insertString1 += "<td align=middle>" + AUX_NO1 + "-" + AUX_NO2 + "</td>";
							insertString1 += "<td align=middle>" + A051_MEASURE + "</td>";
							insertString1 += "<td align=middle>" + ITEM_NM + "</td>";
							insertString1 += "<td align=middle>"; 
							if (('${OP}'!='4' || ('${OP}'=='4' && $F('IS_AUTOAPPR')=='2')) ) {
								//[20210322]覆核時，智能件才顯示按鈕
								insertString1 += "<input type='button' class='button' value='新增' onClick='DSA30501.addRows("+mover+",\""+target+"\")'>"
							}
							insertString1 += "</td></tr>";
						}else{
							insertString1 += "<tr class=tbBlue3 align=middle>";
							insertString1 += "<td align=middle>" + ADDR_NO + "</td>";
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
							//insertString1 += "車位持分<input type='text' class='textBox2' size='14' maxLength='14' id='"+target+"_HOLD_BASE_VIEW_"+mover+"' value='"+HOLD_BASE+"' style='text-align:right;' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)' onBlur='DSA30501.changePARK_AMT("+mover+",\""+target+"\")'>" ;
							
							insertString1 += "分之<input type='text' class='textBox2' size='14' maxLength='14' id='"+target+"_HOLD_UP_VIEW_"+mover+"' value='"+HOLD_UP+"' style='text-align:right;' onkeypress='return CSRUtil.pressNumber(event.keyCode)' onkeyup='this.value = CSRUtil.$fmt(this.value, defaultPattern1, true)' onBlur='DSA30501.changePARK_AMT("+mover+",\""+target+"\")'>" ;
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
							if (('${OP}'!='4' || ('${OP}'=='4' && $F('IS_AUTOAPPR')=='2')) ) {
								//[20210322]智能件才顯示按鈕
								insertString1 += "<input type='button' class='button' id='"+target+"_XXX_"+mover+"' value='移除' onClick='DSA30501.removeRows("+mover+",\""+target+"\")'>"
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
					//[20180607]問題單 由o.index改成o.readAttribute('index')
					//第一個ID時取MAP資料
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
				//[20180607]問題單 由o.index改成o.readAttribute('index')
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
	
	//車位坪資料異動時調整(F區)比較建坪BUILD_SPACE
	function changeBUILD_SPACE_A201(park_space, build_space){
		buttons.doGetBuildSpaceA201(park_space, build_space);
	}
		
	//建議價格資料異動時調整(M區)總價TOTAL_PRICE
	function changeTOTAL_PRICE(mover , target){
		if('2'==$("FORMULA1_VIEW").value){
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
	function changeCAPT_EXAM_VIEW(){
	
		//選擇“如擬”
		if('1'==$("CAPT_EXAM_VIEW").value){
		
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
			
			$$('#gridL1 input[type="text"]','#gridL1 select').each(function(record){
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
			$w('CAPT_PARK_PRICEA_VIEW CAPT_PARK_NUMA_VIEW CAPT_PER_PRICEA_VIEW CAPT_TOTAL_PRICEA_VIEW CAPT_AVG_PRICEA_VIEW CAPT_PARK_SPACEA_VIEW CAPT_PARK_PRICEB_VIEW CAPT_PARK_NUMB_VIEW CAPT_PER_PRICEB_VIEW CAPT_TOTAL_PRICEB_VIEW CAPT_AVG_PRICEB_VIEW CAPT_PARK_SPACEB_VIEW').each( 
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

				$("BOSS_PARK_PRICEA_VIEW").value = $("CAPT_PARK_PRICEA_VIEW").value;
				$("BOSS_PARK_NUMA_VIEW").value = $("CAPT_PARK_NUMA_VIEW").value;
				$("BOSS_PER_PRICEA_VIEW").value = $("CAPT_PER_PRICEA_VIEW").value;
				$("BOSS_TOTAL_PRICEA_VIEW").value = $("CAPT_TOTAL_PRICEA_VIEW").value;
				$("BOSS_AVG_PRICEA_VIEW").value = $("CAPT_AVG_PRICEA_VIEW").value;
				$("BOSS_PARK_SPACEA_VIEW").value = $("CAPT_PARK_SPACEA_VIEW").value;
				
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
				
				$$('#gridL1 input[type="text"]','#gridL1 select').each(function(record){
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
			$w('BOSS_PARK_PRICEA_VIEW BOSS_PARK_NUMA_VIEW BOSS_PER_PRICEA_VIEW BOSS_TOTAL_PRICEA_VIEW BOSS_AVG_PRICEA_VIEW BOSS_PARK_SPACEA_VIEW BOSS_PARK_PRICEB_VIEW BOSS_PARK_NUMB_VIEW BOSS_PER_PRICEB_VIEW BOSS_TOTAL_PRICEB_VIEW BOSS_AVG_PRICEB_VIEW BOSS_PARK_SPACEB_VIEW').each( 
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

	var layout = {
		
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

			PageUI.createPage("DSA30501", "鑑價作業", "簡易件鑑價報告輸入");
			PageUI.loadin(["form1","form2"] , 1);
			
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
					{header: "擔保品地址",key: "ADDR_NO",styles:{'whiteSpace':'pre','width':'400px'},
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
									//node.setAttribute("className" , "required validate-positive-number");
									//node.setAttribute("title" , "單價(萬/坪)必須輸入");
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
					{header: "擔保品地址",key: "ADDR_NO", attrs:{ rowSpan:2 },styles:{'whiteSpace':'pre','width':'400px'},
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
							var v1 = rec.TRANS_FLOOR ? rec.TRANS_FLOOR : '';
							var v2 = rec.TOTAL_FLOOR ? rec.TOTAL_FLOOR : '';
							return v1 + "/" + v2;
						}
					},
					{header: "總價",key: "TOTAL_PRICE",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) : '0';
						}
					},	
					{header: "建坪",key: "BUILD_AREA_ADJ",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) : '0';
						}
					},
					{header: "建坪單價",key: "BUILD_U_PRICE_ADJ",
						render : function(rec , val){
							return val ? CSRUtil.$fmt(val, defaultPattern1) : '0';
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
			<%--[20250211]M區 grid tableui 欄位設定一樣，改用方法取得--%>
			gridM1 = new TableUI ( actions.setGridM('gridM1','自動估價建議價格') );
			gridM2 = new TableUI ( actions.setGridM('gridM2','建議案例平均價格') );
			gridM3 = new TableUI ( actions.setGridM('gridM3','社區行情價格區間') );
			gridMM = new TableUI ( actions.setGridM('gridMM','公寓行情價格區間') );<%--[20250211]公寓估價紀錄--%>
			
			<%--[20240613]車位估價紀錄 --%>
			gridMP = new TableUI ( { 
				table: $("gridMP"), pageSize:0, allSortable:false, overDiv:false,
				column:[
					{header: "車位模型建議總價",key: "PRINCE", styles:{'width':'12%'},
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
								$$('#gridMP SELECT[name=GAP_NOTE2'+sn+"]")[0].replace(SELECT2);
								
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
			});
			//註冊DOM物件
			//click事件
			$("btn_query").observe("click", buttons.doQuery );//查詢
			
			$("btn_captainConfirm").observe("click", buttons.doCaptainConfirmCheck );//組長覆核
			$("btn_captainReject").observe("click", buttons.doCaptainReject );//組長退回
			$("btn_bossConfirm").observe("click", buttons.doBossConfirmCheck );//主管(代理)覆核
			$("btn_bossReject").observe("click", buttons.doBossReject );//主管退回
			$("btn_gmConfirm").observe("click", buttons.doGmConfirm);//部室主管覆核
			$("btn_cancelConfirm").observe("click", buttons.doCancelConfirm );//取消覆核

			$("btn_insert").observe("click", buttons.doInsert );//新增
			$("btn_update").observe("click", buttons.doUpdate );//修正
			$("btn_delete").observe("click", buttons.doDelete );//刪除
			$("btn_confirm").observe("click", buttons.doConfirmCheck );//呈核
			$("btn_cancel").observe("click", buttons.doCancel );//取消呈核
			$("btn_electronicMap").observe("click", buttons.doElectronicMap );//(1)電子地圖
			$("btn_change").observe("click", buttons.doChange );//報告變更

			$("btn_print").observe("click", buttons.doPrint );//列印
			$("btn_Get_A216List_VIEW").observe("click", buttons.getA216List );//(2)案例建議 
			$("btn_Get_A215List_VIEW").observe("click", buttons.getA215List );//(3)自動估價 
			$("btnGenCommPrice").observe("click",buttons.getA350List);// 20210610 社區價格
			$('btnCfmComm').observe("click",buttons.doCfmComm);
			$("btn_Get_A201List_VIEW").observe("click", buttons.getA201List );//(4)訪價匯入
			$("btn_reSend").observe("click", buttons.doReSend );//報告重送
			$("btn_linkImage").observe("click", buttons.doLinkImage );//影像連結
			
			$("btn_autoAnalysis").observe("click", buttons.doAutoAnalysis );//(5)自動分析
			$("btn_allAnalysis").observe("click", buttons.doAllAnalysis );//綜合分析
			$("btn_copyPicAlbum").observe("click", buttons.doCopyPicAlbum );//引用相簿
			$("btnLinkTo3700").observe("click", buttons.doLinkTo3700 );<%--[20250213]公寓資料庫--%>
			
			//[20201105]申請書-201019001927：調整承作分區判斷邏輯
			$("URBAN_PROJECT").observe("change", buttons.doAreaCode );
			$("USE_AREA1_VIEW").observe("change", buttons.doAreaCode );

			// 顯示隱藏
			$("A_divI2").observe("click", layout.doShowdiv_I2 );
			$("A_divI3").observe("click", layout.doShowdiv_I3 );
			$("A_divI4").observe("click", layout.doShowdiv_I4 );
			$("A_divI5").observe("click", layout.doShowdiv_I5 );
						
			//公式
			$("FORMULA1_VIEW").observe('change',
				function(event){ 
					$("FORMULA_VIEW").value = $('FORMULA1_VIEW').options[$('FORMULA1_VIEW').selectedIndex].text;
					changeTOTAL_PRICE();
					changeAVG_PRICE($('TOTAL_PRICE_VIEW'), $('AVG_PRICE_VIEW'));
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
			
			
			//車位坪數-比較建坪
			$("PARK_SPACE_VIEW").observe('blur',
				function(event){
					$("PARK_SPACEB_VIEW").value = $('PARK_SPACE_VIEW').value;
					$("PARK_SPACEB1_VIEW").innerHTML = $('PARK_SPACE_VIEW').value;
					changeBUILD_SPACE_A201($('PARK_SPACE_VIEW'), $('BUILD_MEASURE'));
				}
			);
			/*$("PARK_SPACEB_VIEW").observe('blur',
				function(event){
					$("PARK_SPACE_VIEW").value = $('PARK_SPACEB_VIEW').value;
					changeBUILD_SPACE_A201($('PARK_SPACEB_VIEW'), $('BUILD_MEASURE'));
				}
			);*/
			
			//建築型態-樓層
			$("BUILD_TYPE_VIEW").observe('blur',
				function(event){
					var targetFloorStr = $('TARGET_FLOOR').value<0? "B"+$('TARGET_FLOOR').value.substring(1):$('TARGET_FLOOR').value
					$('FLOOR_A201_VIEW').value = targetFloorStr +'/'+CSRUtil.$fmt( $('TOTAL_FLOOR').getValue() , "###");
				}
			);
			
			//停車位-車位型態
			/*$("PARK_VIEW").observe('change',
				function(event){
					$("PARK_TYPE_A201_VIEW").innerHTML = $('PARK_VIEW').options[$('PARK_VIEW').selectedIndex].text;
				}
			);*/
			
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
			$w('REF_SRC_A201_1 REF_SRC_A201_2 REF_SRC_A201_3 TIME_TEL_A201_1 TIME_TEL_A201_2 TIME_TEL_A201_3').each(
				function(key){
					var index = key.substring(key.lastIndexOf('_')+1);
					$(key).observe('change', function(event){
						buttons.doQueryMAM003(index);
					});
				}
			);
			
			$w("PER_PRICE_A201_1_btn PER_PRICE_A201_2_btn PER_PRICE_A201_3_btn").each(
				function(ele){
					$(ele).observe('click',function(event){
						buttons.doCalculatePrice(ele);
					});
				}
			);

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
			if('${OP}'=='3'){

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
				$("btn_reSend").hide();//報告重送
		
				$("btn_insert").show();//新增
				$("btn_update").show();//修正
				$("btn_delete").show();//刪除
				$("btn_confirm").show();//呈核
				$("btn_cancel").show();//取消呈核
				$("btn_electronicMap").show();//(1)電子地圖
				$("btn_linkImage").show();//影像連結
				$("btn_change").show();//報告變更
				
				$w("PER_PRICE_A201_1_btn PER_PRICE_A201_2_btn PER_PRICE_A201_3_btn").each(function(ele){
					$(ele).show();
				});
			
			}else if('${OP}'=='4'){

				//覆核人員
				//A~Q區塊
				//[20201130]block改成''解chrome table長不滿問題
				$('table_N').style.display = '';
				$('table_O').style.display = '';
				$('table_P').style.display = '';
				$('table_P1').style.display = '';
				$('table_R').style.display = '';
				
				$("btn_captainConfirm").show();//組長覆核
				$("btn_captainReject").show();//組長退回
				$("btn_bossConfirm").show();//科主管(代理)覆核
				$("btn_bossReject").show();//主管退回
				$("btn_gmConfirm").show();//部室主管覆核
				$("btn_cancelConfirm").show();//取消覆核
				$("btn_reSend").show();//報告重送
				$("btn_electronicMap").show();//(1)電子地圖
				$("btn_linkImage").show();//影像連結
				
				$("btn_insert").hide();//新增
				$("btn_update").hide();//修正
				
				$("btn_delete").hide();//刪除
				$("btn_confirm").hide();//呈核 
				$("btn_cancel").hide();//取消呈核 
				$("btn_change").hide();//報告變更
				
				$w("PER_PRICE_A201_1_btn PER_PRICE_A201_2_btn PER_PRICE_A201_3_btn").each(function(ele){
					$(ele).hide();
				});
			}
	
			//銀行人員：按鈕、Q區不顯示
			if (${IS_BANK_USER}){
				$('APPLY_ID').readOnly = true;
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
				$('table_Interval').style.display = 'none';
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
		changeBUILD_SPACE_A201 : changeBUILD_SPACE_A201,
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
		doInsert : buttons.doInsert,
		doUpdate : buttons.doUpdate,
		doDelete : buttons.doDelete,
		doConfirm : buttons.doConfirmCheck,
		doCancel : buttons.doCancel,
		doElectronicMap : buttons.doElectronicMap,
		doCopyPicAlbum : buttons.doCopyPicAlbum
	};	
};

</script>

</head>
<body>
<!-- A區 -->
<form id="form1">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table_A">
		<tr>
			<td class="tbYellow" width="10%" align="left">受理編號</td>
			<td class="tbYellow2" width="20%">
				<input id="APPLY_ID" type="text" class="text2" size="12" maxLength="11" value="${param.APPLY_ID}"/>
				<input id="encryptAPPLY_ID" type="hidden" value="${encryptAPPLY_ID}"/>
				<input type="hidden" id="BORROW_ID" value="">
				<input type="hidden" id="FINISH_DATE" value="">
				<input type="hidden" id="LONGITUDE" value="">
				<input type="hidden" id="LATITUDE" value="">
				<input type="hidden" id="ROAD_WIDTH" value="">
				<input type="hidden" id="LAND_MEASURE" value="">
				<input type="hidden" id="BUILD_MEASURE" value="">
				<input type="hidden" id="BUILD_AGE" value="">
				<input type="hidden" id="INPUT_DATE" value="">
				<input type="hidden" id="IS_SIMPLE_O" value="">
				<input type="hidden" id="PIC_CASE_NAME" name="PIC_CASE_NAME"  value="">
				<input type="hidden" id="MAP_AREA_CODE" name="MAP_AREA_CODE"  value="">
				<%--[20201127] 調整承作分區判斷邏輯新增承作分區、擔保品郵遞區號欄位--%> 
				<input type="hidden" id="AREA_CODE_930318" name="AREA_CODE_930318" value=""> 
				<input type="hidden" id="IS_AUTOAPPR" name="IS_AUTOAPPR" value=""> 				
				<input type="hidden" id="AUTO_CAPT_ID" name="AUTO_CAPT_ID"  value=""> 
			</td>
			<td class="tbYellow2" align="center">
				<input id="btn_query" type="button" class="button" value="查詢" /> 
				<input id="btn_print" type="button" class="button" value="列印" />
				<input id="btn_electronicMap" type="button" class="button" value="(1)電子地圖">
				<input id="btn_linkImage" type="button" class="button" value="影像連結">
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
				<input id="btn_reSend" type="button" class="button" value="報告重送">
				
				<input id="btn_insert" type="button" class="button" value="新增">
				<input id="btn_update" type="button" class="button" value="修正">
				<input id="btn_delete" type="button" class="button" value="刪除">
				<input id="btn_confirm" type="button" class="button" value="呈核">
				<input id="btn_cancel" type="button" class="button" value="取消呈核">
				<input id="btn_change" type="button" class="button" value="報告變更">
				<img id="img_getfile" style="cursor: hand;" src="<%=imageBase%>/DS/star5.gif" border=0 onClick="DSA30501.doGetFile()">
			</td>
		</tr>
	</table>
</form>
<!-- A區 -->
<!-- B區 -->
<form id="form2" name="form2">
	<table class="tbBox2" cellspacing="1" style="width: 100%; border: 0;" id="table_B1">
		<tr>
			<td class="tbYellow" width="10%">建議總價</td>
			<td class="tbYellow2" colspan="7" id="TOTAL_PRICE_B_VIEW"></td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%">受理進度</td>
			<td class="tbYellow2" width="10%" id="APPLY_PROCESS_NM_VIEW"></td>
			<td class="tbYellow" width="10%">承作分區</td>
			<td class="tbYellow2" width="10%" id="AREA_CODE_VIEW"></td>
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
				<input type="text" id="TARGET_FLOOR" style="width: 5em" value="">樓
				<input type="hidden" id="TOTAL_FLOOR"  value="">
			</td>
			<%-- 20210701 所在樓層版面調整:--%>
			<td class="tbYellow" width="10%">樓層備註</td>
			<td class="tbYellow2" width="10%" >
				<input type="text" id="FLOOR_MEMO" size="6" value="">
			</td>
			<td class="tbYellow" width="10%">建築型態</td>
			<td class="tbYellow2"  width="30%" colspan="3" nowrap>
				<input type="text" class="textBox2 checkInputLength" fieldName="建築型態" maxLength="10"  id="BUILD_TYPE_VIEW" readonly> 
				<select id="USE_FOR_VIEW">
			       	<c:forEach var="map" items="${USE_FOR_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%">擔保品地址</td>
			<td class="tbYellow2" colspan="5">
				<span id="GAGE_ADDR_VIEW" style="font-family:'EUDC'"></span><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				<img id="img_LinkToDSA3_0900" style="cursor: hand;" src="<%=imageBase%>/DS/cup.gif" border=0 onClick="DSA30501.doLinkToDSA3_0900()">
			</td>
			<td class="tbYellow" width="10%">價量燈號</td>
			<td class="tbYellow2" width="30%">
				<span id="LIGHT_VIEW"></span>
			</td>	
		</tr>
		<tr>
			<td class="tbYellow" width="10%">地坪</td>
			<td class="tbYellow2" width="10%" id="A040_LAND_SPACE_VIEW"></td>
			<td class="tbYellow" width="10%">建坪</td>
			<td class="tbYellow2" width="10%" id="A050_BUILD_SPACE_VIEW"></td>
			<td class="tbYellow" width="10%">屋齡</td>
			<td class="tbYellow2" width="10%" id="BUILD_AGE_VIEW"></td>
			<td class="tbYellow" width="10%">使用分區</td>
			<td class="tbYellow2" width="30%" nowrap>
				<select id="USE_AREA1_VIEW" fieldName="使用分區">
			       	<c:forEach var="map" items="${USE_AREA1_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select> 
				<input type="text" class="textBox2 checkInputLength" size="10" maxLength="10" value="" id="USE_AREA2_VIEW">
			</td>
		</tr>
		<tr>			
			<td class="tbYellow" width="10%">都市計畫案</td>
			<td class="tbYellow2" width="30%" colspan="3">
				<select id="URBAN_PROJECT" fieldName="都市計畫案">
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
		</tr>
	</table>
<!-- B區 -->
<!-- C區 -->
	<table class="tbBox2" cellspacing="1" style="width: 100%; border: 0;" id="table_C">
		<tr class=tbYellow0 align=middle>
			<td align=middle colspan="2"><strong>一、擔保品</strong>
			<input type="button" class="button" id="btn_Get_A216List_VIEW" value="(2)案例建議"></td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" rowspan="2">1.基本資料</td>
			<td class="tbYellow2">
				<!--
				管制區 
				<select id="CONTROL_AREA_VIEW">
			       	<c:forEach var="map" items="${CONTROL_AREA_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select> 
			 	-->
				土地/建物
				<input name='IS_LAND' id = 'IS_LAND_Y' type="radio" value ='1'>有
				<input name='IS_LAND' id = 'IS_LAND_N' type="radio" value ='0'>無&nbsp;&nbsp;&nbsp;其他登記事項
			</td>
		</tr>
		<tr>
			<td class="tbYellow2">
				買賣金額 
				<input type="text" class="textBox2" size="13" maxLength="10" datatype="number" id="TRADE_AMT_VIEW" pattern="#,###.##"> 
				萬，買賣日期 
				<input type="text" class="textBox2 checkInputLength validate-ROCDate" datatype="ROCDate" size="9" maxLength="7" value="" id="TRADE_DATE_VIEW"> 
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
			<td class="tbYellow">2.案名</td>
			<td class="tbYellow2">
				<input type="text" class="textBox2" size="15" maxLength="20" id="CASE_NAME_VIEW">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				外觀照日期
				<input type="text" class="textBox2 checkInputLength validate-ROCDate" datatype="ROCDate" size="10" maxLength="7" value="" id="APPEARANCE_PIC_DATE_VIEW">
				<img src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onclick="getCalendarFor($('APPEARANCE_PIC_DATE_VIEW'))">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				沿用編號
				<span id="FOLLOW_NUMBER_LINK_VIEW"></span>
				<input type="hidden" id="FOLLOW_NUMBER_VIEW" value="">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				社區編號
				<span id="COMMUNITY_NO_LINK_VIEW"></span>
				<input type="button" class="button" id="btn_copyPicAlbum" value="引用相簿">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="hidden" id="COMMUNITY_NO_VIEW" value="">
				<div id = "DYNAMIC_SPC_CONDITION" style="display:inline"></div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">3.公設比</td>
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
			<td class="tbYellow">4.嫌惡設施</td>			
			<td class="tbYellow2">
				<textarea rows=3 cols=80 id="DISLIKE_DESC_VIEW" class="textAreaOldSys checkInputLength" maxLength="500" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">5.環境設施</td>			
			<td class="tbYellow2">
				<textarea rows=3 cols=80 id="SPC_DESC_VIEW" class="textAreaOldSys checkInputLength" maxLength="500" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">6.鑑價記錄</td>
			<td class="tbYellow2"><font color='red'><span id="SLOGAN_VIEW"></span></font></td>
		</tr>
	</table>
<!-- C區 -->
<!-- D區 -->
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
<!-- H1區 --> 
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_H1">
		<tr class=tbYellow0 align=middle>
			<td align=middle ><strong>實價登錄案例建議清單</strong></td>
		</tr>
		<tr align=middle>
			<td class="tbYellow2" >
				<table id='gridH1' width="100%"></table>
			</td>
		</tr>
	</table>
<!-- H1區 -->
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
<!-- M區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_M">
		<tr class=tbYellow0 align=middle>
			<td align=middle ><strong>二、建議價格(單位：萬,位,坪)</strong>
			<!-- 20210610 1.	新增按鈕:社區價格 -->
			<button class="button" type="button" id="btn_Get_A215List_VIEW">(3)自動估價</button>
			<button class="button" type="button" id="btnGenCommPrice">匯入社區/公寓價格</button><%--[20250211]匯入社區價格調整為匯入社區/公寓價格--%>
			<button class="button" type="button" id="btnCfmComm">確認社區/公寓價格</button><%--[20250213]確認社區價格調整為確認社區/公寓價格--%>
			<button class="button" type="button" id="btnLinkTo3700">公寓資料庫</button><%--[20250213]增加公寓資料庫按鈕--%>
			</td>
		</tr>							
		<tr>
			<td class="tbYellow2" >
				車位<input type="text" class="textBox2" size="10" maxLength="3" datatype="number" id="PARK_NUM_VIEW_1" pattern="#,###">個&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="PARK_AMT_VIEW_1" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				坪數：<span id="PARK_SPACEB1_VIEW"></span>
				<input type="hidden" class="textBox2" size="10" maxLength="8" datatype="number" id="PARK_SPACEB_VIEW" pattern="#,###.####">坪
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
					<c:forEach var='map' items='${FORMULA_LIST2}'> 
						<option value='${map.key}'>${map.value}</option> 
					</c:forEach> 
				</select>
				<input type="text" class="textBox2 checkInputLength" size="50" maxLength="40" value="" id="FORMULA_VIEW">
			</td>
		</tr>
	</table>
<!-- M區 -->
<!-- G區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_G">
		<tr class=tbYellow0 align=middle>
			<td align=middle><strong>價格補充說明</strong></td>
		</tr>				
		<tr align=middle>
			<td class="tbYellow2" >
				<textarea rows=10 cols=115 id="LOC_DESC_VIEW" class="textAreaOldSys checkInputLength" maxLength="2000"  onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
			</td>
		</tr>
	</table>
<!-- G區 -->
<!-- P區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_P">
		<tr class=tbYellow0 align=middle>
			<td align=middle colspan="6"><strong>覆核</strong></td>
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
				車位總價<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="CAPT_PARK_PRICEA_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位數<input type="text" class="textBox2" size="5" maxLength="3" datatype="number" id="CAPT_PARK_NUMA_VIEW" pattern="#,###.##">位&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位面積<input type="text" class="textBox2" size="7" maxLength="8" datatype="number" id="CAPT_PARK_SPACEA_VIEW" pattern="#,###.###">坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">	
				單價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_PER_PRICEA_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="10" maxLength="10" datatype="number" id="CAPT_TOTAL_PRICEA_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				均價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_AVG_PRICEA_VIEW" pattern="#,###.##" readonly>萬/坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2" width="5%" align="center">特殊行情</td>
			<td class="tbYellow2" colspan="3">	
				車位總價<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="CAPT_PARK_PRICEB_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位數<input type="text" class="textBox2" size="5" maxLength="3" datatype="number" id="CAPT_PARK_NUMB_VIEW" pattern="#,###.##">位&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位面積<input type="text" class="textBox2" size="7" maxLength="8" datatype="number" id="CAPT_PARK_SPACEB_VIEW" pattern="#,###.###">坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">	
				單價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_PER_PRICEB_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="10" maxLength="10" datatype="number" id="CAPT_TOTAL_PRICEB_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				均價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="CAPT_AVG_PRICEB_VIEW" pattern="#,###.##" readonly>萬/坪
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
				<textarea rows=5 cols=70 id="BOSS_EXAM_DESC_VIEW" class="textBox2 checkInputLength" maxLength="500" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2" width="5%" align="center">一般行情</td>
			<td class="tbYellow2" colspan="3">	
				車位總價<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="BOSS_PARK_PRICEA_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位數<input type="text" class="textBox2" size="5" maxLength="3" datatype="number" id="BOSS_PARK_NUMA_VIEW" pattern="#,###.##">位&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位面積<input type="text" class="textBox2" size="7" maxLength="8" datatype="number" id="BOSS_PARK_SPACEA_VIEW" pattern="#,###.###">坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">	
				單價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_PER_PRICEA_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="10" maxLength="10" datatype="number" id="BOSS_TOTAL_PRICEA_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				均價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_AVG_PRICEA_VIEW" pattern="#,###.##" readonly>萬/坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow" rowspan="2" width="5%" align="center">特殊行情</td>
			<td class="tbYellow2" colspan="3">	
				車位總價<input type="text" class="textBox2" size="10" maxLength="8" datatype="number" id="BOSS_PARK_PRICEB_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位數<input type="text" class="textBox2" size="5" maxLength="3" datatype="number" id="BOSS_PARK_NUMB_VIEW" pattern="#,###.##">位&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				車位面積<input type="text" class="textBox2" size="7" maxLength="8" datatype="number" id="BOSS_PARK_SPACEB_VIEW" pattern="#,###.###">坪
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">	
				單價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_PER_PRICEB_VIEW" pattern="#,###.##">萬/坪&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				總價<input type="text" class="textBox2" size="10" maxLength="10" datatype="number" id="BOSS_TOTAL_PRICEB_VIEW" pattern="#,###.##">萬&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				均價<input type="text" class="textBox2" size="10" maxLength="7" datatype="number" id="BOSS_AVG_PRICEB_VIEW" pattern="#,###.##" readonly>萬/坪
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
<!-- Q區 -->
    <table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_R">
		<tr align="center" class="tbYellow0">
			  <td colspan="8" class="textBold">評分</td>
		</tr>
		<tr> 
		  <td colspan="3">
			<table id="gridR1" >
			</table>
		  </td>
		</tr>
		<tr>
			<td class=tbYellow2 align="center" colspan="3">
				<input id="btn_add_1" class="button" type="button" value="新增評分" /> 
			</td>
		</tr>
	</table>
<!-- Q區 -->
<!-- E區 -->
	<table class="tbBox2" cellspacing="1" style="width: 100%; border: 0;" id="table_EF">
		<tr class=tbYellow0 align=middle >
			<td align=middle colSpan="8" ><strong>三、訪價資料(單位：萬,坪)</strong>
			<input type="button" class="button" id="btn_Get_A201List_VIEW" value="(4)訪價匯入"></td>
		</tr>
		<tr>
			<td class="tbBlue" width ="8%" align="center">
				項目
			</td>	
			<td class="tbBlue" width ="23%" align="center" >
				擔保品
			</td>
			<td class="tbBlue" width ="23%" align="center" colspan = "2">
				甲
				<input type = "hidden" id="SEQ_NO_A201_1" class = "A201_1" />
				<input type = "hidden" id="APPLY_ID_A201_1" class = "A201_1" >
			</td>
			<td class="tbBlue" width ="23%" align="center" colspan = "2">
				乙
				<input type = "hidden" id="SEQ_NO_A201_2" class = "A201_2" />
				<input type = "hidden" id="APPLY_ID_A201_2" class = "A201_2" >
			</td>				
			<td class="tbBlue" width ="23%" align="center" colspan = "2">
				丙
				<input type = "hidden" id="SEQ_NO_A201_3" class = "A201_3" />
				<input type = "hidden" id="APPLY_ID_A201_3" class = "A201_3" >
			</td>	
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				地址
			</td>	
			<td class="tbYellow2" align="center" >
				<span id="ADDRESS_A201_VIEW" style="font-family:'EUDC'"/></span><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="ADDRESS_A201_1" maxlength ="60" size ="40" class = "A201_1 textBox2 checkInputLength" alt="ch"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="ADDRESS_A201_2" maxlength ="60" size ="40" class = "A201_2 textBox2 checkInputLength" alt="ch"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="ADDRESS_A201_3" maxlength ="60" size ="40" class = "A201_3 textBox2 checkInputLength" alt="ch"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			</td>
		</tr>	
		<tr>
			<td class="tbYellow" align="left" >
				車位型態
			</td>	
			<td class="tbYellow2" align="center" >
				<!-- <span id="PARK_TYPE_A201_VIEW" /></span> -->
				---
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_TYPE_A201_1" maxlength ="10" size ="9" class = "A201_1 textBox2 checkInputLength" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_TYPE_A201_2" maxlength ="10" size ="9" class = "A201_2 textBox2 checkInputLength" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_TYPE_A201_3" maxlength ="10" size ="9" class = "A201_3 textBox2 checkInputLength" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				車位數
			</td>	
			<td class="tbYellow2" align="center" >
				<!-- <input type = "text" id="PARK_NUM_A201_VIEW" maxlength ="3" size ="2" class = "A201_VIEW textBox2 checkInputLength" />	-->
				---
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_NUM_A201_1" maxlength ="3" size ="2" class = "A201_1 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_NUM_A201_2" maxlength ="3" size ="2" class = "A201_2 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_NUM_A201_3" maxlength ="3" size ="2" class = "A201_3 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				車位坪
			</td>	
			<td class="tbYellow2" align="center" >
				<!-- <span id="PARK_SPACE_A201_VIEW" /></span> -->
				---
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_SPACE_A201_1" maxlength ="7" size ="6" class = "A201_1 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_SPACE_A201_2" maxlength ="7" size ="6" class = "A201_2 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_SPACE_A201_3" maxlength ="7" size ="6" class = "A201_3 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				車位價
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_PRICE_A201_1" maxlength ="8" size ="6" class = "A201_1 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_PRICE_A201_2" maxlength ="8" size ="6" class = "A201_2 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PARK_PRICE_A201_3" maxlength ="8" size ="6" class = "A201_3 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				成交/預估建坪總價(萬)
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="TOTAL_PRICE_A201_1" maxlength ="10" size ="9" class = "A201_1 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="TOTAL_PRICE_A201_2" maxlength ="10" size ="9" class = "A201_2 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="TOTAL_PRICE_A201_3" maxlength ="10" size ="9" class = "A201_3 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				成交/預估建坪單價
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PER_PRICE_A201_1" maxlength ="8" size ="7" class = "A201_1 textBox2 checkInputLength" datatype="number" pattern="#,###.##" 
					readonly style="background-color:#FFEE99"/>
				<input id="PER_PRICE_A201_1_btn" type="button" class="button" value="C">
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="PER_PRICE_A201_2" maxlength ="8" size ="7" class = "A201_2 textBox2 checkInputLength" datatype="number" pattern="#,###.##" 
					readonly style="background-color:#FFEE99"/>
				<input id="PER_PRICE_A201_2_btn" type="button" class="button" value="C">
			</td>
			<td class="tbYellow2" align="center"colspan = "2" >
				<input type = "text" id="PER_PRICE_A201_3" maxlength ="8" size ="7" class = "A201_3 textBox2 checkInputLength" datatype="number" pattern="#,###.##" 
					readonly style="background-color:#FFEE99"/>
				<input id="PER_PRICE_A201_3_btn" type="button" class="button" value="C">
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				資料來源
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
                <select id="REF_SRC_A201_1" class="A201_1 textBox2" >
					<c:forEach var="map" items='${REF_SRC_LIST}' >
						<!-- <option value='${map.key}'>${map.value}</option> -->
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
			<td class="tbYellow2" align="center" colspan = "2">
                <select id="REF_SRC_A201_2" class="A201_2 textBox2" >
					<c:forEach var="map" items='${REF_SRC_LIST}' >
						<!-- <option value='${map.key}'>${map.value}</option> -->
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
			<td class="tbYellow2" align="center" colspan = "2">
                <select id="REF_SRC_A201_3" class="A201_3 textBox2" >
					<c:forEach var="map" items='${REF_SRC_LIST}' >
						<!-- <option value='${map.key}'>${map.value}</option> -->
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
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				開價(萬)/仲介
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="TIME_TEL_A201_1" maxlength ="16" size ="12" class = "A201_1 textBox2 checkInputLength" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="TIME_TEL_A201_2" maxlength ="16" size ="12" class = "A201_2 textBox2 checkInputLength" />
			</td>
			<td class="tbYellow2" align="center" colspan = "2">
				<input type = "text" id="TIME_TEL_A201_3" maxlength ="16" size ="12" class = "A201_3 textBox2 checkInputLength" />
			</td>
		</tr>
<!-- E區 -->
<!-- F區 -->
		<tr class=tbYellow0 align=middle >
			<td align=middle colSpan="8" ><strong>四、差異分析</strong>
			<input type="button" class="button" id="btn_autoAnalysis" value="(5)自動分析"></td>
		</tr>
		<tr>
			<td class="tbBlue" width ="8%" align="center">
				項目
			</td>	
			<td class="tbBlue" width ="23%" align="center" >
				擔保品
			</td>
			<td class="tbBlue" width ="23%" align="center" colspan = "2">
				甲
				<input type = "hidden" id="APPLY_ID_A209_1" class = "A209_1" >
			</td>
			<td class="tbBlue" width ="23%" align="center" colspan = "2">
				乙
				<input type = "hidden" id="APPLY_ID_A209_2" class = "A209_2" >
			</td>				
			<td class="tbBlue" width ="23%" align="center" colspan = "2">
				丙
				<input type = "hidden" id="APPLY_ID_A209_3" class = "A209_3" >
			</td>	
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				時間
			</td>	
			<td class="tbYellow2" align="center" >
				<span id="REF_TIME_A201_VIEW" /></span>
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="REF_TIME_A201_1" maxlength ="5" size ="6" class = "A201_1 textBox2 checkInputLength" />
			</td>
			<td class="tbYellow2" align="left" >
	            <select id="DIFF_TIME_A209_1" class="A209_1 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="REF_TIME_A201_2" maxlength ="5" size ="6" class = "A201_2 textBox2 checkInputLength" />
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_TIME_A209_2" class="A209_2 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="REF_TIME_A201_3" maxlength ="5" size ="6" class = "A201_3 textBox2 checkInputLength" /><br/>
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_TIME_A209_3" class="A209_3 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				交通
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
	            <select id="DIFF_TRAFFIC_A209_1" class="A209_1 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_TRAFFIC_A209_2" class="A209_2 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_TRAFFIC_A209_3" class="A209_3 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				生活
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
	            <select id="DIFF_LIFE_A209_1" class="A209_1 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_LIFE_A209_2" class="A209_2 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_LIFE_A209_3" class="A209_3 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				臨路
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
	            <select id="DIFF_NEAR_ROAD_A209_1" class="A209_1 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_NEAR_ROAD_A209_2" class="A209_2 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right"v >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_NEAR_ROAD_A209_3" class="A209_3 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				屋齡
			</td>	
			<td class="tbYellow2" align="center" >
				<span id="BUILD_AGE_A201_VIEW" /></span>
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="BUILD_AGE_A201_1" maxlength ="3" size ="2" class = "A201_1 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="left" >
	            <select id="DIFF_BUILD_AGE_A209_1" class="A209_1 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="BUILD_AGE_A201_2" maxlength ="3" size ="2" class = "A201_2 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_BUILD_AGE_A209_2" class="A209_2 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="BUILD_AGE_A201_3" maxlength ="3" size ="2" class = "A201_3 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_BUILD_AGE_A209_3" class="A209_3 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				樓層
			</td>	
			<td class="tbYellow2" align="center" >
				<input type = "text" id="FLOOR_A201_VIEW" maxlength ="9" size ="5" class = "A201_VIEW textBox2 checkInputLength" />			
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="FLOOR_A201_1" maxlength ="9" size ="5" class = "A201_1 textBox2 checkInputLength" />
			</td>
			<td class="tbYellow2" align="left" >
	            <select id="DIFF_FLOOR_A209_1" class="A209_1 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="FLOOR_A201_2" maxlength ="9" size ="5" class = "A201_2 textBox2 checkInputLength" />
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_FLOOR_A209_2" class="A209_2 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="FLOOR_A201_3" maxlength ="9" size ="5" class = "A201_3 textBox2 checkInputLength" />
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_FLOOR_A209_3" class="A209_3 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				比較建坪
			</td>	
			<td class="tbYellow2" align="center" >
				<input type = "text" id="BUILD_SPACE_A201_VIEW" maxlength ="9" size ="6" class = "A201_VIEW textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="BUILD_SPACE_A201_1" maxlength ="9" size ="6" class = "A201_1 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="left" >
	            <select id="DIFF_MEASURE_A209_1" class="A209_1 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL1_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="BUILD_SPACE_A201_2" maxlength ="9" size ="6" class = "A201_2 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_MEASURE_A209_2" class="A209_2 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL1_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
				<input type = "text" id="BUILD_SPACE_A201_3" maxlength ="9" size ="6" class = "A201_3 textBox2 checkInputLength" datatype="number" pattern="#,###.##" />			
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_MEASURE_A209_3" class="A209_3 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL1_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				<select id="DIFF_KIND_A_A209_VIEW" class="textBox2">
					<c:forEach var='map' items='${DIFF_KIND2_A_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
	            <select id="DIFF_OPTION_A_A209_1" class="A209_1 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_OPTION_A_A209_2" class="A209_2 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_OPTION_A_A209_3" class="A209_3 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				<select id="DIFF_KIND_B_A209_VIEW" class="textBox2">
					<c:forEach var='map' items='${DIFF_KIND2_B_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
	            <select id="DIFF_OPTION_B_A209_1" class="A209_1 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_OPTION_B_A209_2" class="A209_2 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_OPTION_B_A209_3" class="A209_3 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				綜合分析
				<input id="btn_allAnalysis" type="button" class="button" value="C">
			</td>	
			<td class="tbYellow2" align="center" >
				---
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
	            <select id="DIFF_SYNTH_A209_1" class="A209_1 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_SYNTH_A209_2" class="A209_2 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
				<select id="DIFF_SYNTH_A209_3" class="A209_3 textBox2">
					<c:forEach var='map' items='${COMP_LEVEL2_LIST}'>
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				訪價區間(萬/坪)
			</td>	
			<td class="tbYellow2" align="center" >
				<input type="text" class="textBox2" size="7" value="" id="LOWER_PRICE_A209_VIEW" readonly style="background-color:#FFEE99">
				&nbsp;~&nbsp; 
				<input type="text" class="textBox2" size="7" value="" id="UPPER_PRICE_A209_VIEW" readonly style="background-color:#FFEE99">
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
			</td>
			<td class="tbYellow2" align="right" >
			</td>
			<td class="tbYellow2" align="left" >
			</td>
		</tr>
	</table>	
<!-- F區 -->	
<!-- H區 -->
<!-- I區 -->
<!-- J區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_J">
		<tr class=tbYellow0 align=middle>
			<td align=middle ><strong>五、近三個月同建案紀錄</strong></td>
		</tr>
		<tr align=middle>
			<td class="tbYellow2" >
				<table id='gridJ1' width="100%"></table>
			</td>
		</tr>
	</table>
<!-- J區 -->
	<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="table_Interval">
		<tr class=tbYellow0 align=middle>
			<td align=middle colspan="8"><strong>六、價格資料</strong></td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%">智能價格區間</td>
			<td class="tbYellow2" width="15%" >
				<span id="VISIT_PRICE_L_VIEW"></span>萬
				&nbsp;~&nbsp; 
				<span id="VISIT_PRICE_H_VIEW"></span>萬
			</td>
			<td class="tbYellow" width="10%">鑑估紀錄</td>
			<td class="tbYellow2" width="15%" id="COMMPRICE_INTERVAL_VIEW"></td>
			<td class="tbYellow" width="10%">實價登錄</td>
			<td class="tbYellow2" width="15%" id="REALPRICE_INTERVAL_VIEW"></td>
			<td class="tbYellow" width="10%">車位價格區間</td>
			<td class="tbYellow2" width="15%" id="PARKPRICE_INTERVAL_VIEW"></td>
		</tr>		
	</table>
</form>
</body>
</html>