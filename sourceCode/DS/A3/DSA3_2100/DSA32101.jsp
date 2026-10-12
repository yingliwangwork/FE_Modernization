<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>

<!--
程式：DSA32101.jsp (併入 DSA3_2102)
作者：簡睿甫
功能：基本資料輸入 (併入 擔保品資料輸入)
完成：
[20240930]難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>    <%-- 警告訊息用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>         <%-- 判斷BUTTON用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>        <%-- 地址用 --%>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<%--[20240930]難字css  --%>
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
var DSA32101 = new DSA32101();
Event.observe(window, 'load', DSA32101.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

// 共用變數 PAGEUI用
var VaildationSaves = {};
var ContentSaves = {};
var hasChange;

function DSA32101(){
	// 初估編號 DSA3_2101 DSA3_2102 共用
	var PREAPPR_NO = '<c:out value="${PREAPPR_NO}" default="" escapeXml="false" />';

	// DSA3_2101參數
	var valid1;
	var EmpName = '<c:out value="${EmpName}" default="" escapeXml="false" />';
	var PHONE = '<c:out value="${PHONE}" default="" escapeXml="false" />';
	var MOBILE = '<c:out value="${MOBILE}" default="" escapeXml="false" />';
	var DIV_SHORT_NAME = '<c:out value="${DIV_SHORT_NAME}" default="" escapeXml="false" />';
	
	var A280VO = <c:out value="${A280VO}" default="[]" escapeXml="false" />;

	// 原DSA3_2102參數
	var grid_B;
	
	var LOAN_ID;
	var sourceChoose = 'PREAPPR_NO';
	
	var A285List;
	
	//-----------------------------------------------------
	//IM AJAX 國內共用
	//-----------------------------------------------------
	function ajaxPostIM( actionName, params, successAction, errorFunction ){
		new Ajax.Request(
			"<%=dispatcher%>/DSA3_2101/" + actionName, 
			{ parameters : params ,
			  onSuccess : function (response) {
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){      
					successAction(resp);
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			 }
		});
	}
	
	var button = {
		// 結案案件變更
		doChange:  function(){
			
			if(RecrodsControl.records["B"].length==0){
				return alert('建物資料至少輸入1筆');
			}
			
			var isNoZip = false;
			$$('span').each( 
				function(sp){	
					if(sp.id.indexOf('span_INPUT_ZIPCODE')>=0){
						if(sp.innerHTML==''){
							isNoZip = true;
						}
					}
				}
			);
			if(isNoZip){
				return alert('請輸入正確的地址');
			}
			
			$$('input[type="text"]').each( 
				function(ele){	
					if(ele.id.indexOf('SERV_ADDR_ZIP')>=0){
						ele.className = 'required';
						ele.fieldName = '建物地址';
					}
					if(ele.id.indexOf('HOLD_BASE')>=0 && ele.className.indexOf('validate2Val')<0){
						ele.className = ele.className + ' validate2Val';
					}
				}
			);
		
			// 清空檢核
			valid1.reset();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!valid1.validate() || !validates.doValidation()){ 
				return; 
			}
			
			var A285Map = PageUI.getContentValues( ContentSaves["B"] );
			PageUI.commitContentValues(ContentSaves["B"]);
			A285Map = PageUI.getContentValues( ContentSaves["B"] );
			
			var reqMap = action.getA280Map();
			ajaxPostIM( 'change' ,  {Form: reqMap, PREAPPR_NO: PREAPPR_NO, A285List: Object.toJSON(A285Map), sourceChoose: sourceChoose, LOAN_ID: LOAN_ID}, 
				function(resp){	
					$('A280VO').value = Object.toJSON(resp.A280VO);
					action.initAction(resp.A280VO);
					
					// DSA3_2102 sourceChoose 併入
					A285List = resp.A285List || [];
					$('A285List').value = Object.toJSON(A285List);
					RecrodsControl.clearAll('B');
					RecrodsControl.loadin( 'B' , A285List );
				}				
			);
		},
		
		// 下一步
		doNext:  function(){
			
			if(RecrodsControl.records["B"].length==0){
				return alert('建物資料至少輸入1筆');
			}
			
			var isNoZip = false;
			$$('span').each( 
				function(sp){	
					if(sp.id.indexOf('span_INPUT_ZIPCODE')>=0){
						if(sp.innerHTML==''){
							isNoZip = true;
						}
					}
				}
			);
			if(isNoZip){
				return alert('請輸入正確的地址');
			}
			
			$$('input[type="text"]').each( 
				function(ele){	
					if(ele.id.indexOf('SERV_ADDR_ZIP')>=0){
						ele.className = 'required';
						ele.fieldName = '建物地址';
					}
					if(ele.id.indexOf('HOLD_BASE')>=0 && ele.className.indexOf('validate2Val')<0){
						ele.className = ele.className + ' validate2Val';
					}
				}
			);
			
			// 清空檢核
			valid1.reset();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!valid1.validate() || !validates.doValidation()){ 
				return; 
			}
			
			var reqMap = action.getA280Map();
			var A285Map = PageUI.getContentValues( ContentSaves["B"] );
			ajaxPostIM( 'next' ,  {Form: reqMap, PREAPPR_NO: PREAPPR_NO, A285List: Object.toJSON(A285Map), sourceChoose: sourceChoose, LOAN_ID: LOAN_ID}, 
				function(resp){	
					PREAPPR_NO = resp.PREAPPR_NO;
					$('PREAPPR_NO').value = PREAPPR_NO;
					$('PREAPPR_NO_TD').update(PREAPPR_NO);
					$('A280VO').value = Object.toJSON(resp.A280VO);
					action.initAction(resp.A280VO);
					
					// DSA3_2102 sourceChoose 併入
					A285List = resp.A285List || [];
					$('A285List').value = Object.toJSON(A285List);
					RecrodsControl.clearAll('B');
					RecrodsControl.loadin( 'B' , A285List );
					
					var cover = CSRUtil.createCoverPage('_frontCover');
					cover.hide();
					parent.DSA32100.isDSA32101Next = true;
					parent.DSA32100.TABS.select('DSA32103');
				}				
			);
		},
		
		// 面積.平方公尺與面積.坪連動button.doGearing(value, "", 'BUILD_MEASURE', 'BUILD_MEASURE_F2', target.id);
		doGearing: function(squareMeterValue, fpingValue, Name1, Name2, id){
			ajaxPostIM( 'gearing' ,  {squareMeter: squareMeterValue, fping:fpingValue}, 
				function(resp){	
					if(resp.squareMeter){
						$(id.replace(Name1, Name2)).value = button.formatValue(resp.squareMeter);
					} else if(resp.fping){
						$(id.replace(Name1, Name2)).value = button.formatValue(resp.fping);
					}
				}				
			);
		},
		
		// 取得建物資料 by LOAD_ID
		doQueryByLoadId: function(){
			
			if(!$F('LOAN_ID')) {
				alert("如有異動，請輸入正確原件貸款帳號");
				$('LOAN_ID').value = LOAN_ID; // 回復異動前的值
				return;
			}
			
			LOAN_ID = $F('LOAN_ID');
			if (!confirm("有輸入原件貸款帳號,是否要自動取得擔保品資料?")){
				return;
			}
			
			ajaxPostIM( 'queryByLoadId' ,  {LOAN_ID: LOAN_ID}, 
				function(resp){	
					sourceChoose = 'LOAN_ID';
					A285List = resp.A285List;
					$('A285List').value = Object.toJSON(A285List);
					RecrodsControl.clearAll('B');
					RecrodsControl.loadin( 'B' , A285List );
				}				
			);
		},

		// 數字欄位格式
		pattern : '#,###.####',
 
		// 數字欄位處理(三位一撇)
		formatValue : function(value) {
			if(Object.isNumber(value)) {
				return value ? CSRUtil.$fmt(value, button.pattern) : '';
			} else {
				return value ?  value : '';
			}
		}
	};
	
	var action = {
		<%--[20240930]初始畫面--%>
		initPage: function(){
			action.createUserInterface();			
			ajaxPostIM( 'initQuery' ,  {PREAPPR_NO: '${PREAPPR_NO}'}, 
				function(resp){	
					EmpName = resp.EmpName || '';
					PHONE = resp.PHONE || '';
					MOBILE = resp.MOBILE || '';
					DIV_SHORT_NAME = resp.DIV_SHORT_NAME || '';
				
					A280VO = resp.A280VO || {};				
					$('A280VO').value = Object.toJSON(A280VO);
					action.initAction(A280VO);
					
					A285List = resp.A285List || [];
					$('A285List').value = Object.toJSON(A285List);
					RecrodsControl.loadin( 'B' , A285List );
				}				
			);
		},
		initAction:　function(A280VO) {
			// 承辦人員資訊
			$('DIV_NM').update(DIV_SHORT_NAME);
			$('EMP_NM').update(EmpName);
			$('PHONE').update(PHONE);
			$('MOBILE').update(MOBILE);
			
			if(A280VO) {
				CSRUtil.voToInputs(form, A280VO);
				LOAN_ID = $F('LOAN_ID');
				$('PREAPPR_NO_TD').update(PREAPPR_NO);
				$('TRADE_AMT').setValue(A280VO['TRADE_AMT']);
				$('TURN_AMT').setValue(A280VO['TURN_AMT']);
				$('APPLY_AMT').setValue(A280VO['APPLY_AMT']);
				
				// 轉貸件
				if($("IS_TURN").checked) {
					$("TURN_AMT").readOnly = false;
					$("TRADE_AMT").readOnly = true;
					$("LOAN_ID").readOnly = true;
					$("IS_TRADE").checked = false;
					$("IS_NEW").checked = false;
					$("IS_INCREASE").checked = false;
					$("TRADE_AMT").value = "";
					$("LOAN_ID").value = "";
				} 
				
				// 買賣件
				if($("IS_TRADE").checked) {
					$("TURN_AMT").readOnly = true;
					$("TRADE_AMT").readOnly = false;
					$("LOAN_ID").readOnly = true;
					$("IS_TURN").checked = false;
					$("IS_NEW").checked = false;
					$("IS_INCREASE").checked = false;
					$("TURN_AMT").value = "";
					$("LOAN_ID").value = "";
				}
				
				// 新件
				if($("IS_NEW").checked) {
					$("TURN_AMT").readOnly = true;
					$("TRADE_AMT").readOnly = true;
					$("LOAN_ID").readOnly = true;
					$("IS_TURN").checked = false;
					$("IS_TRADE").checked = false;
					$("IS_INCREASE").checked = false;
					$("TURN_AMT").value = "";
					$("TRADE_AMT").value = "";
					$("LOAN_ID").value = "";
				}
				
				// 增貸件
				if($("IS_INCREASE").checked) {
					$("TURN_AMT").readOnly = true;
					$("TRADE_AMT").readOnly = true;
					$("LOAN_ID").readOnly = false;
					$("IS_TURN").checked = false;
					$("IS_TRADE").checked = false;
					$("IS_NEW").checked = false;
					$("TURN_AMT").value = "";
					$("TRADE_AMT").value = "";
				}
				
			} else {
				$('form').reset();
			}
		},
		
		// 整理回傳A280Map資料，因當radio未點選的為undefine，無法更新至DB中
		getA280Map: function() {
			var reqMap = CSRUtil.inputsToVo('form', true);
			$w('IS_TURN IS_TRADE IS_NEW IS_INCREASE').each(function(ele) {
				if(!reqMap[ele]) {
					reqMap[ele] = 0;
				}
			});
			return Object.toJSON(reqMap);
		},
		
		createUserInterface: function() {
			//-------------------------------------------------------------------------------------------------
			// Block B
			// 建物地址
			//-------------------------------------------------------------------------------------------------
			var areaBsetting =
			{ 
				elem:"areaB", dataColumns: 6, className:"contentBlue", clearChildElements:false, noContent:false, noHeader:true, columnProps:[ 1, 13, 14, 14, 20, 10],
				contents:[
					 { header:"選取", rowSpan:3,   values:[ 
						{key:"CHOOSE", type:"radio", items:{1:""}, attrs:{name:"delTagB" } , events :{ click:function(target){ RecrodsControl.selectToDelete("B" , target); } } } 
					 ]}
					,{ header:"建物地址", colSpan:5, values:[ 
						{ key:"SERV_ADDR_ZIP",type:"dom",attrs:{ value:"" , preKey:"GAGE", inputType:2, className:"required" }
							,elem:theDSZ01000control.create
							,getFunc:theDSZ01000control.get
							,setFunc:theDSZ01000control.set  
						}
					 ]} , 
					{ header:"建號",   values:[
						{key:"BUILD_NO1", type:"number" , attrs:{ value:"" , pattern:"#####" , size:'6', maxLength:'5' },
						 setFunc: function(node , value , values ){
							if(value == '00000'){
								return '0000';
							} else {
								return value;
							}
						}},
						'-',
						{key:"BUILD_NO2", type:"number" , attrs:{ value:"" , pattern:"###" , size:'4', maxLength:'3'},
						 setFunc: function(node , value , values ){
							if(value == '000'){
								return '00';
							} else {
								return value;
							}
						}} 						
					]},
					{ header:"面積(含陽露台)", colSpan:2,  values:[
						{key:"BUILD_MEASURE", type:"number" , attrs:{ value:"" , pattern:"#,###.####" , size:'10', maxLength:'8', className:"required validate-greater-than-zero"},
							events:{ "blur":function(target){
								var value = target.getValue();
								button.doGearing(value, "", 'BUILD_MEASURE', 'BUILD_MEASURE_F2', target.id);
							}}
						},
						'平方公尺或',
						{key:"BUILD_MEASURE_F2", type:"number" , attrs:{ value:"" , pattern:"#,###.####" , size:'10', maxLength:'8', className:"required validate-greater-than-zero"},
							events:{ "blur":function(target){
								var value = target.getValue();
								button.doGearing("", value, 'BUILD_MEASURE_F2', 'BUILD_MEASURE', target.id);
							}}
						},
						'坪'
					 ]}
					,{ header:"持分", values:[
						{key:"HOLD_BASE", type:"number" , attrs:{ value:"" , pattern:"#,###.####" , size:'10', maxLength:'8', className:"required validate-greater-than-zero"}},
						'分之',
						{key:"HOLD_UP", type:"number" , attrs:{ value:"" , pattern:"#,###.####" , size:'10', maxLength:'8', className:"required validate-greater-than-zero"}}
					 ]},
					{ header:"建築完成日", values:[
						{key:"FINISH_DATE", type:"date" 
							,getFunc:function( node , value , valueMap , isForDispaly ){
								if(isForDispaly){
									var testValue = value;
									if(isROCdate(value,false)){
										testValue = toY2K(testValue);
									}
									if(isDate(testValue)){
										df = JsUtils.getSimpleDateFormat("yyyMM" , true );
										value = df.format(testValue);
									}
								}
								return value;
							}
							,attrs:{ value:"" , datatype:"rocdate" , pattern:"yyy/MM/dd", className:"checkIsROCDate" }
						}
					]},
					{ header:"主要用途", values:[

						{key:"MAIN_USE",  type:"radio" ,itemKey:"key",itemValueKey:"value",items: selectionOptions.MAIN_USE_LIST , attrs:{}}						
					]},
					{ header:"建物型態", values:[
						{key:"BUILD_TYPE",  type:"select" ,optKey:"key",optValueKey:"value",opts: selectionOptions.BUILD_TYPE_LIST , attrs:{className:"required"}}
					]},
					{ header:"總樓層", values:[
						{key:"FLOOR", type:"number" , attrs:{ value:"" , pattern:"########" , size:'10', maxLength:'8', className:"required"}}
					]},
					{ header:"有無車位", colSpan:2, values:[
						{key:"HAS_PARK",  type:"radio" ,itemKey:"key",itemValueKey:"value",items: selectionOptions.HAS_PARK_LIST , attrs:{}}
					]}
				]
			}
			var areaBcontent = RecrodsControl.createRecord( "B" , areaBsetting ).parentNode;
			ContentSaves["B"] = areaBcontent;
			VaildationSaves["B"] = new Validation( areaBcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});
			
		}
	};
	
	var validates = {
		initValidation : function() {
			// 欄位檢核
			valid1 = new Validation("form", { mode:'validator'} );	
			Validation.addAllThese( [
				// 借款人ID需符合自然人身分證號碼格式或法人統一編號格式
				['ID-check', '借款人ID需符合自然人身分證號碼格式或法人統一編號格式',
					function( v,ele,info ) {
						if( validation.checkUniSN( v ) || validation.checkROCID( v )){
							return true;
						} else {
							return false;
						}
					}
				],
				
				['validate2Val', '請輸入正確資料(A)>=(B)', 
					function( val,obj){
						id1 = obj.id.replace('HOLD_BASE','HOLD_UP');
						return parseInt($F(obj.id)) >= parseInt($F(id1));
					}
				]
			] );
			valid1.define( "required" , [{ id: "BORROW_NAME" , errMsg:"借款人姓名不可空白"}]);
			valid1.define( "required" , [{ id: "BORROW_ID" , errMsg:"借款人ID不可空白"}]);
			valid1.define( "required" , [{ id: "APPLY_AMT" , errMsg:"欲申貸金額不可空白"}] );
		}, 
		
		// 一般欄位清空檢核
		clear: function() {
			// 清空檢核紀錄
			valid1.reset();
			// 清空檢核設定
			valid1.clear();
		},
		
		// PAGEUI 欄位清空檢核
		doValidation: function(){
			VaildationSaves["B"].reset();
			if( !VaildationSaves["B"].validate() ) {
				return false;
			}
			return true;
		}
	};
	
	var RecrodsControl = {
		 createRecord : function ( area , value ){
			/*var type = RecrodsControl.contentsStatusSave[area] || 0 ;
			if(type !== 2){
				if(type === 1){
					RecrodsControl.commitRecords( area, areaTable );
				}*/
				var areaTable = RecrodsControl.ContentsSave[area];
				var isCreate = areaTable ? false : true ; 
				var setting = isCreate ? value : RecrodsControl.ContentsSettingSave[area];
				if(!JsUtils.isObject(setting)){
					return;
				}
				var copySetting = JsUtils.cloneObject(setting);
				copySetting.KeyToId = function(key){ return (area+"_"+key+(isCreate ? "_HEADER" : "_"+( RecrodsControl.contentsCount[area]|| 0)));  };
				
				if(!isCreate){
					copySetting.elem = areaTable;
					var isValueObject = value && JsUtils.isObject(value);
					//var showType = isValueObject ? 1 : 0;
					var showType = 0;
					var tbody = PageUI.createContent( copySetting , null , showType  );
					if(isValueObject){
						PageUI.setContentValues( tbody , value , true , true );
						RecrodsControl.contentsStatusSave[area] = 0;
					}else{
						RecrodsControl.contentsStatusSave[area] = 2;
					}
					var records = RecrodsControl.records[area]
					records[records.length] = tbody;
					RecrodsControl.contentsCount[area] =  RecrodsControl.contentsCount[area] + 1;
					if(isValueObject){
						if(RecrodsControl.deleteNodeSave[area]){
							PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_MOD" , area+"_DEL"] );
						}else{
							PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_MOD"] );
						}
					}else{
						PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_CAN"] );
					}
					theDSZ01000control.createDSZ01000( tbody );
					RecrodsControl.contentsValidationSave[tbody.getAttribute("id")] = new Validation( tbody, {useTitles:true,focusOnError:false,immediate:false,mode:"validator",alertTitle:RecrodsControl.ValidationTitle[area]});
					return tbody;
				}else{
					copySetting.clearChildElements = true;
					copySetting.noContent = true;
					copySetting.noHeader = false;
					var tbody =  PageUI.createContent( copySetting , null , 1  );
					RecrodsControl.ContentsSave[area] = tbody.parentNode;
					RecrodsControl.records[area] = [];
					RecrodsControl.contentsCount[area] = 0;
					RecrodsControl.ContentsSettingSave[area] = setting;
					RecrodsControl.createButtons( area );
					PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"] );
					return tbody;
				}
			/*}else{
				 RecrodsControl.editRecords( area, areaTable );
			}*/
		}
		,createButtons: function( area ){
			var contentTable = RecrodsControl.ContentsSave[area];
			var buttons = {};
			buttons[area+"_ADD"] = { header:"新增", ignoreAuth:true,
				events:{ "click":
					function(target){
						paramObj = {SEQ_NO:RecrodsControl.records[area].length+1};
						RecrodsControl.createRecord( area, paramObj );
						$$('input[type="radio"]').each( 
							function(ele){	
								if(ele.name.indexOf('HAS_PARK')>=0){
									var defVal = true;
									var radioItems =  $$("input[name="+ele.name+"]");
									
									for(var mover =0; mover < radioItems.length ; mover++)
									{
										var targetElement = radioItems[mover];
										if(targetElement.type == 'radio'&& targetElement.checked) {
											//targetElement.checked = true;
											defVal = false;
										}
									}
									if(defVal){
										for(var mover = radioItems.length-1; mover > 0  ; mover--)
										{
											var targetElement = radioItems[mover];
											if(targetElement.type == 'radio') {
												targetElement.checked = true;
												break;
											}
										}
									}
								}
								if(ele.name.indexOf('MAIN_USE')>=0){
									var defVal = true;
									var radioItems =  $$("input[name="+ele.name+"]");
									for(var mover =0; mover < radioItems.length ; mover++)
									{
										var targetElement = radioItems[mover];
										if(targetElement.type == 'radio'&& targetElement.checked) {
											//targetElement.checked = true;
											defVal = false;
										}
									}
									if(defVal){
										for(var mover =0; mover < radioItems.length ; mover++)
										{
											var targetElement = radioItems[mover];
											if(targetElement.type == 'radio') {
												targetElement.checked = true;
												break;
											}
										}
									}
								}
							}
						);
					} 
				} 
			};
			//buttons[area+"_MOD"] = { header:"修改", ignoreAuth:true,	events:{ "click":function(target){ RecrodsControl.editRecords( area ); } } };
			//buttons[area+"_CAN"] = { header:"取消", ignoreAuth:true,	events:{ "click":function(target){ RecrodsControl.rollbackRecords( area ); } } };
			buttons[area+"_DEL"] = { header:"刪除", ignoreAuth:true,	events:{ "click":function(target){ RecrodsControl.deleteRecords( area ); } } };
			
			RecrodsControl.ButtonContentsSave[area] = PageUI.createButtonArea( contentTable , { changeForOneButton:false, buttonOnRight:false, clearChildElements:false, buttons:buttons });
		}
		,editRecords:function( area ){
			var contentTable = RecrodsControl.ContentsSave[area];
			var type = RecrodsControl.contentsStatusSave[area] || 0 ;
			if( type === 0){
				PageUI.setContentsDisplay( contentTable , 0 );
				RecrodsControl.contentsStatusSave[area] = 1;
				PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_MOD",area+"_CAN" ], [area+"_DEL"] );
			}else if ( type === 1 ){
				RecrodsControl.commitRecords( area, contentTable  );
			}else if( type === 2){
				RecrodsControl.commitRecords( area, contentTable.lastChild );
			}
		}
		,selectToDelete:function( area , node ){
			var type = RecrodsControl.contentsStatusSave[area] || 0 ;
			//if( type == 2){ return; }
			 RecrodsControl.deleteNodeSave[area] = node;
			 PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_DEL"] ,[area+"_ADD",area+"_MOD",area+"_CAN"]);
		}
		,commitRecords:function( area, commitElem ){
			var checkResult = true;
			if(commitElem && commitElem.tagName == "TBODY"){
				var tbodyId = commitElem.getAttribute("id");
				if(tbodyId && RecrodsControl.contentsValidationSave[tbodyId] ){
					RecrodsControl.contentsValidationSave[tbodyId].reset();
					checkResult = RecrodsControl.contentsValidationSave[tbodyId].validate() && checkResult;
				}else{
					alert("發生不明錯誤(MISSING ID)");
					checkResult = false;
				}	
			}else if(commitElem && commitElem.tagName == "TABLE"){
				var testBody = commitElem.firstChild.nextSibling;
				while(testBody){
					var tbodyId = testBody.getAttribute("id");
					if(tbodyId && RecrodsControl.contentsValidationSave[tbodyId] ){
						RecrodsControl.contentsValidationSave[tbodyId].reset();
						checkResult = RecrodsControl.contentsValidationSave[tbodyId].validate() && checkResult;
					}else{
						alert("發生不明錯誤(MISSING ID)");
						checkResult = false;
						break;
					}	
					testBody = testBody.nextSibling;
				}
			}else if( area && RecrodsControl.ContentsSave[area] ){
				commitElem = RecrodsControl.ContentsSave[area]
				var testBody = commitElem.firstChild.nextSibling;
				while(testBody){
					var tbodyId = testBody.getAttribute("id");
					if(tbodyId && RecrodsControl.contentsValidationSave[tbodyId] ){
						RecrodsControl.contentsValidationSave[tbodyId].reset();
						checkResult = RecrodsControl.contentsValidationSave[tbodyId].validate() && checkResult;
					}else{
						alert("發生不明錯誤(MISSING ID)");
						checkResult = false;
						break;
					}	
					testBody = testBody.nextSibling;
				}
			}else{
				alert("發生不明錯誤(ERROR TYPE)");
				checkResult = false;
			}
			
			if(checkResult){
				PageUI.commitContentValues( commitElem );
				RecrodsControl.contentsStatusSave[area] = 0;
			}
			return checkResult;
			
			/*
			if(!checkResult) {return; }
			PageUI.commitContentValues( commitElem );
			PageUI.setContentsDisplay( commitElem , 1 );
			RecrodsControl.contentsStatusSave[area] = 0;
			var records = RecrodsControl.records[area];
			if( records && records.length > 0){
				PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_MOD"], [area+"_DEL"]);
			}else{
				PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"], [area+"_DEL"] );
			}
			*/
		}
		,rollbackRecords:function( area ){
			var contentTable = RecrodsControl.ContentsSave[area];
			var records = RecrodsControl.records[area];
			var type = RecrodsControl.contentsStatusSave[area] || 0 ;
			if( type === 1){
				PageUI.rollbackContentValues( contentTable );
				PageUI.setContentsDisplay( contentTable , 1 );
			}else  if( type === 2){
				
				var buttonArea = RecrodsControl.ButtonContentsSave[area].parentNode.parentNode;
				contentTable.removeChild(records[records.length - 1]);
				contentTable.lastChild.appendChild(buttonArea);
				records = records.splice(records.length-1 , 1 );
			}
			RecrodsControl.contentsStatusSave[area] = 0;
			if( records && records.length > 0){
				PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_MOD"], [area+"_DEL"] );
			}else{
				PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"], [area+"_DEL"] );
			}
		}
		,deleteRecords:function( area ){
			var deleElem = RecrodsControl.deleteNodeSave[area];
			if(!deleElem){ return; }	
			var tbody = JsUtils.getParentByTagName(deleElem , "TBODY");
			if(!tbody) { return; }
			var contentTable = RecrodsControl.ContentsSave[area];
			var records = RecrodsControl.records[area];
			var buttonArea = RecrodsControl.ButtonContentsSave[area].parentNode.parentNode;
			for( var i = 0 ; i < records.length ; i = i + 1 ){
				if(records[i] == tbody ){
					records = records.splice( i , 1 );
					RecrodsControl.contentsCount[area] = RecrodsControl.contentsCount[area] - 1;
					tbody.parentNode.removeChild(tbody);
					break;
				}
			}
			
			var records = RecrodsControl.records[area];
			var valRecords = PageUI.getContentValues( ContentSaves[area] );
			for( var i = 0 ; i < records.length ; i++ ){
				record = records[i];
				valObj = valRecords[record.id];
				valObj.SEQ_NO = i+1;
			}
			
			contentTable.lastChild.appendChild(buttonArea);
			if( RecrodsControl.contentsCount[area] > 0 ){
				PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [0] ,[area+"_ADD",area+"_MOD",area+"_CAN"]);
			}else{
				PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"]);
			}
			RecrodsControl.deleteNodeSave[area] = null;
		 }
		,loadin:function( area , records ){
			if(!JsUtils.isObject(RecrodsControl.ContentsSettingSave[area])){ return; }
			if(JsUtils.isArray(records)){
				for(var i = 0 ; i < records.length ; i = i + 1 ){
					 var tbody = RecrodsControl.createRecord( area , records[i] );
				}
				$$('input[type="radio"]').each( 
					function(ele){	
						if(ele.name.indexOf('HAS_PARK')>=0){
							var defVal = true;
							var radioItems =  $$("input[name="+ele.name+"]");
							for(var mover =0; mover < radioItems.length ; mover++)
							{
								var targetElement = radioItems[mover];
								if(targetElement.type == 'radio'&& targetElement.checked) {
									//targetElement.checked = true;
									defVal = false;
								}
							}
							if(defVal){
								for(var mover = radioItems.length-1; mover > 0  ; mover--)
								{
									var targetElement = radioItems[mover];
									if(targetElement.type == 'radio') {
										targetElement.checked = true;
										break;
									}
								}
							}
						}
						if(ele.name.indexOf('MAIN_USE')>=0){
							var defVal = true;
							var radioItems =  $$("input[name="+ele.name+"]");
							for(var mover =0; mover < radioItems.length ; mover++)
							{
								var targetElement = radioItems[mover];
								if(targetElement.type == 'radio'&& targetElement.checked) {
									//targetElement.checked = true;
									defVal = false;
								}
							}
							if(defVal){
								for(var mover =0; mover < radioItems.length ; mover++)
								{
									var targetElement = radioItems[mover];
									if(targetElement.type == 'radio') {
										targetElement.checked = true;
										break;
									}
								}
							}
						}
					}
				);
			}
		}
		,clearAll:function(area){
			var type = RecrodsControl.contentsStatusSave[area] || 0 ;
			if( type != 0 ){
				RecrodsControl.rollbackRecords(area);
			}
			var contentTable = RecrodsControl.ContentsSave[area];
			if(!JsUtils.isDOMObject(contentTable)){ return; }
			var buttonArea = RecrodsControl.ButtonContentsSave[area].parentNode.parentNode;
			var delBodys = RecrodsControl.records[area];
			for( var i = 0 ; i < delBodys.length  ; i = i + 1 ){
				contentTable.removeChild(contentTable.lastChild);
			}
			RecrodsControl.records[area] = [];
			RecrodsControl.contentsCount[area] = 0;
			contentTable.lastChild.appendChild(buttonArea);
			PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"]);
		}
		/*設定儲存*/
		,ContentsSave:{}
		,ButtonContentsSave:{}
		,ContentsSettingSave:{}
		/*產生的資料儲存*/
		,records:{}
		/* 0:saved , 1:edit , 2:new */
		,contentsStatusSave:{}
		,contentsCount:{}
		,contentsValidationSave:{}
		,deleteNodeSave:{}
		,ValidationTitle:{D:"目前經營事業",E:"目前服務單位",H:"本人其他不動產暨設定明細"}
	}

	theDSZ01000control = {
		create:function(){
			var sno = theDSZ01000control.DSZ01000saves.length;
			var span = new Element("span" , {sno:sno , id:"autoDSZ01000"+sno , DSZ01000:true});
			theDSZ01000control.DSZ01000saves[sno] = span;
			return span;
		}
		,createDSZ01000: function(){
			var saveNum = theDSZ01000control.DSZ01000saves.length;
			for( var i = saveNum-1 ; i >= 0  ; i = i - 1 ){
				var testNode = theDSZ01000control.DSZ01000saves[i];
				if(JsUtils.isDOMObject(testNode))
				{	
					var inputType =  testNode.getAttribute("inputType") || "2";
					var aDSZ01000 = new DSZ01000(testNode, inputType);
					theDSZ01000control.DSZ01000saves[i] =	aDSZ01000
				}else{
					break;
				}
			}
		}
		,get:function( node ,  rtnMap ){
			var preKey = node.getAttribute("preKey");
			/*var CODE = rtnMap[preKey+"_CODE"]  || node.parentNode.previousSibling.firstChild.value || "" ;
			//if( ruleMap[CODE] && ruleMap[CODE] != 'none'){*/
				var sno = node.getAttribute("sno");
				var aDSZ01000 = theDSZ01000control.DSZ01000saves[sno];
				if(aDSZ01000 && !JsUtils.isDOMObject(aDSZ01000)){
					if(aDSZ01000.setINPUT_ZIPCODE) {
						rtnMap[preKey+"_ZIP"] = aDSZ01000.getINPUT_ZIPCODE();
						rtnMap[preKey+"_ADDR"] = aDSZ01000.getINPUT_ADDR();
					  /*DSZ01000.getCITY_NAME			取得縣市別
						DSZ01000.getTOWN_NAME			取得鄉鎮市區別
						DSZ01000.DSZ01000.getROAD_NAME	取得路名
						DSZ01000.getADDR_NAME			取得門牌號碼分群
						DSZ01000.getINPUT_ZIPCODE		取得郵遞區號
						DSZ01000.getINPUT_ADDR			取得地址*/
					} else {
						rtnMap['CITY'] = aDSZ01000.getCITY_NAME();			// 設定縣市別
						rtnMap['LOCATION1'] = aDSZ01000.getTOWN_NAME();			// 設定鄉鎮市區別
						rtnMap['LOCATION2'] = aDSZ01000.getLAND_NAME1();			// 設定地段
						rtnMap['LOCATION3'] = aDSZ01000.getLAND_NAME2();			// 設定小段
					}
				}
				if(rtnMap[preKey+"_ADDR"] ){
					return rtnMap[preKey+"_ZIP"] +" "+ rtnMap[preKey+"_ADDR"];
				}
			//}
			/*rtnMap[preKey+"_ZIP"] = "";
			rtnMap[preKey+"_ADDR"] = "";*/
			return "";
		}
		,set:function( node , value , valuesMap ){
			var sno = node.getAttribute("sno");
			var aDSZ01000 = theDSZ01000control.DSZ01000saves[sno];
			if(JsUtils.isDOMObject(aDSZ01000)){
				theDSZ01000control.createDSZ01000(aDSZ01000);
				aDSZ01000 = theDSZ01000control.DSZ01000saves[sno];
			}
			if(aDSZ01000 && !JsUtils.isDOMObject(aDSZ01000)){
				if(JsUtils.isObject(valuesMap)){
					var preKey = node.getAttribute("preKey");
					if(aDSZ01000.setINPUT_ZIPCODE) {
						if(valuesMap[preKey+"_ZIP"]){
							aDSZ01000.setINPUT_ZIPCODE(valuesMap[preKey+"_ZIP"]);
						}
						if(valuesMap[preKey+"_ADDR"]){
							aDSZ01000.setINPUT_ADDR(valuesMap[preKey+"_ADDR"]);
						}
					} else {
						if(valuesMap['CITY']){
							aDSZ01000.setCITY_NAME(valuesMap['CITY']);			// 設定縣市別
						}
						if(valuesMap['LOCATION1']){
							aDSZ01000.setTOWN_NAME(valuesMap['LOCATION1']);			// 設定鄉鎮市區別
						}
						if(valuesMap['LOCATION2']){
							aDSZ01000.setLAND_NAME1(valuesMap['LOCATION2']);			// 設定地段
						}
						if(valuesMap['LOCATION3']){
							aDSZ01000.setLAND_NAME2(valuesMap['LOCATION3']);			// 設定小段
						}
					}

					var CODE = valuesMap[preKey+"_CODE"];

				}else{
					theDSZ01000control.displayControl( aDSZ01000 , valuesMap );
				}
				
				
			}
		}
		,displayControl:function( aDSZ01000 , type ){
			type = JsUtils.isString(type) ?type.toLowerCase():"";
			switch(type){
				
				case 'editaddr':
					aDSZ01000.displayOnly(false);
					aDSZ01000.display4INPUT_ZIPCODE();
					aDSZ01000.display4INPUT_ADDR(2);
					break;
				case 'edit':
					aDSZ01000.displayOnly(false);
					aDSZ01000.display4INPUT_ZIPCODE(1);
					aDSZ01000.display4INPUT_ADDR(2);
					break;
				case 'none':
				default:
					aDSZ01000.displayOnly(true);
					aDSZ01000.display4INPUT_ZIPCODE(1);
					aDSZ01000.display4INPUT_ADDR(1);
					break;
			}
		}
		,displayControl2:function( elem , changeValue ){
			var sno = elem.firstChild.getAttribute("sno");
			if(!JsUtils.isNumeric(sno) || sno > (theDSZ01000control.DSZ01000saves.length-1) ){ return; }
			var aDSZ01000 = theDSZ01000control.DSZ01000saves[sno];
			var ruleId = elem.getAttribute("autoInputValueKey");
			var ruleMap = theDSZ01000control.showRules[ruleId];
			theDSZ01000control.displayControl( aDSZ01000 , JsUtils.isObject(ruleMap) ? ruleMap[changeValue] : '' );
			
		}
		,DSZ01000saves : []
		,showRules:{
			 CON_ADDR_ZIP:{"4":"edit","9":"edit" }
			,BUSS_ADDR_ZIP:{"9":"editAddr" }
			,SERV_ADDR_ZIP:{"9":"edit" }
		}
		
	}
	
	var selectionOptions = {
		// 「保人戶籍地址碼」、「戶籍地址碼」、「目前經營事業-事業處所碼」、「目前服務單位-詳細地址碼」下拉選單
		BUILD_TYPE_LIST:<c:choose><c:when test="${not empty BUILD_TYPE_LIST}">${BUILD_TYPE_LIST}</c:when><c:otherwise>[]</c:otherwise></c:choose> ,
		MAIN_USE_LIST: <c:choose><c:when test="${not empty MAIN_USE_LIST}">${MAIN_USE_LIST}</c:when><c:otherwise>[]</c:otherwise></c:choose>,
		HAS_PARK_LIST: {"1":"有","0":"無"}
	}
	
	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement( "DSA32101" , "鑑價作業", "基本資料輸入", 0, true);
			
			autoFormatToNumber();
			<%--[20240930] 初始畫面--%>
			action.initPage();
			
			$$('.header').each(function(head) {
				var innerHTML = head.innerHTML;
				if(innerHTML != "選取" && innerHTML != "建號" && innerHTML != "建築完成日") {
					var span = new Element( 'span',
						{
							style: "color:red;"
						}).update('*');
					head.insert({top: span});	
				}
			});
			
			
			
			// 檢核初始化
			validates.initValidation();
			
			// 監聽: 結案案件變更
			$("BTN_0495").observe('click', button.doChange );	
			
			// 監聽: 下一步
			$("BTN_0496").observe('click', button.doNext );
			
			// 監聽: 原件貸款帳號轉大寫
			$("LOAN_ID").observe('change', function() {
				$("LOAN_ID").value = $F("LOAN_ID").toUpperCase();
				button.doQueryByLoadId();
			} );	
			
			// 監聽: 借款人ID轉大寫
			$("BORROW_ID").observe('change', function() {$("BORROW_ID").value = $F("BORROW_ID").toUpperCase();} );	
			
			// 轉貸件
			$("IS_TURN").observe('click', function() {
					$("TURN_AMT").readOnly = false;
					$("TRADE_AMT").readOnly = true;
					$("LOAN_ID").readOnly = true;
					$("IS_TRADE").checked = false;
					$("IS_NEW").checked = false;
					$("IS_INCREASE").checked = false;
					$("TRADE_AMT").value = "";
					$("LOAN_ID").value = "";
				} 
			);
			// 買賣件
			$("IS_TRADE").observe('click', function() {
					$("TURN_AMT").readOnly = true;
					$("TRADE_AMT").readOnly = false;
					$("LOAN_ID").readOnly = true;
					$("IS_TURN").checked = false;
					$("IS_NEW").checked = false;
					$("IS_INCREASE").checked = false;
					$("TURN_AMT").value = "";
					$("LOAN_ID").value = "";
				} 
			);
			// 新件
			$("IS_NEW").observe('click', function() {
					$("TURN_AMT").readOnly = true;
					$("TRADE_AMT").readOnly = true;
					$("LOAN_ID").readOnly = true;
					$("IS_TURN").checked = false;
					$("IS_TRADE").checked = false;
					$("IS_INCREASE").checked = false;
					$("TURN_AMT").value = "";
					$("TRADE_AMT").value = "";
					$("LOAN_ID").value = "";
				} 
			);
			// 增貸件
			$("IS_INCREASE").observe('click', function() {
					$("TURN_AMT").readOnly = true;
					$("TRADE_AMT").readOnly = true;
					$("LOAN_ID").readOnly = false;
					$("IS_TURN").checked = false;
					$("IS_TRADE").checked = false;
					$("IS_NEW").checked = false;
					$("TURN_AMT").value = "";
					$("TRADE_AMT").value = "";
				} 
			);
			
			/*if(!PREAPPR_NO || ''==PREAPPR_NO){
				$("BTN_0495").disabled = true;
				$("BTN_0496").disabled = true;
				$("B_ADD").disabled = true;
				$("B_DEL").disabled = true; 
			}*/
			
			PageUI.resize();
			
			displayMessage();					
		}, // end initApp()--
		
		// 檢查資料是否修改
		isChanged: function(info) {
			var hasChange = false;
			
			A280VO = $('A280VO').value.evalJSON(); 
			$$('#block_A input[type=text]').each(function(ele){
				if( (ele.getValue() != A280VO[ele.id]) && (ele.getValue() || A280VO[ele.id])  ){
					hasChange = true;
				}
			});
			
			$$('#block_A input[type=radio]').each(function(ele){
				if( ele.value == A280VO[ele.id] && ele.checked == false){
					hasChange = true;
				} else if(ele.value != A280VO[ele.id] && ele.checked == true) {
					hasChange = true;
				}
			});

			if(hasChange){
				alert("畫面資料有異動,請按下一步或結案案件變更");
				parent.DSA32100.TABS.select(info.from);
				return;
			}
			
			var A285List = $('A285List').value.evalJSON(); 
			var A285Map = PageUI.getContentValues( ContentSaves["B"] );
			
			var infos =  {};
			infos.A285List = A285List;
			infos.A285Map = A285Map;
			return infos;

		},
		
		// 初始所需參數
		getInfo: function(){
			var infos =  new Hash();
			infos.set('PREAPPR_NO', $F('PREAPPR_NO'));
			infos.set('LOAN_ID', $F('LOAN_ID'));
			infos.set('sourceChoose', sourceChoose);
			return infos;
		}
	}// end return--
}// end DSA32101

</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form">
	<input id="A280VO" name="A280VO" type="hidden" value="" />
	<input id="A285List" name="A285List" type="hidden" value="" />
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
		<tbody>
			<tr>
				<td colspan='6' align='center' vlign='center' >
					<input type="button" class="button" id="BTN_0495" value="結案案件變更" />
					<input type="button" class="button" id="BTN_0496" value="下一步" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow"  width = "12%" align='center' >單位</td>
				<td id="DIV_NM" class="tbYellow2" colspan="5" ></td>
			</tr>
			<tr>
				<td class="tbYellow"  align='center' >姓名</td>
				<td id="EMP_NM" class="tbYellow2" width="21%" style="font-family:'EUDC'"><%--[20240930]難字調整 --%></td>
				<td class="tbYellow" width="12%" align='center' >電話</td>
				<td id="PHONE" class="tbYellow2" width="17%"></td>
				<td class="tbYellow"  width="13%" align='center'  >手機</td>
				<td id="MOBILE" class="tbYellow2" ></td>
			</tr>
			<tr>
				<td id="" class="tbYellow2"  colspan="6" >
					<span style="color:red;">【重要說明事項】</span><br>
					<span style="color:red;">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp(1) 本線上初估系統為簡略性作業畫面，僅供申貸與否參考，實際仍需查詢借款人債信及擔保品實地勘查。</span><br>
					<span style="color:red;">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp(2) 提供您公司承作區域仍有未開放者，甚或工業住宅、臨重大嫌惡設施等建物，原則不承作。</span><br>
					<span style="color:red;">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp(3) 本初估不得作為客戶買賣參考依據</span><br>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >初估編號
					<input id="PREAPPR_NO" name="PREAPPR_NO" type="hidden" value="" />
				</td>
				<td id="PREAPPR_NO_TD" class="tbYellow2" colspan="5" ></td>
			</tr>
			<tr>
				<td class="tbYellow"  colspan="6" ><span style="color:red;">*</span>1.案件類別<span style="color:red;">(*為必填)</span><br></td>
			</tr>
			<tr>
				<td class="tbYellow"  >
					  &nbsp&nbsp<input id="IS_TURN" name="IS_TURN" type="radio" value="1" />
					轉貸件
				</td>
				<td  class="tbYellow2"  colspan="2" >
					(請提供原銀行餘額<input id="TURN_AMT" name="TURN_AMT" type="text" value="" datatype="number" maxlength="9" readonly="readonly" size = "9"/>萬元)
				</td>
				<td class="tbYellow" >
					&nbsp&nbsp<input id="IS_TRADE" name="IS_TRADE" type="radio" value="1" />
					買賣件
				</td>
				<td  class="tbYellow2"  colspan="2" >
					(請提供買賣金額<input id="TRADE_AMT" name="TRADE_AMT" type="text" value="" datatype="number" maxlength="9" readonly="readonly" size = "9"/>萬元)
				</td>
			</tr>
			<tr>
				<td class="tbYellow"  >
					&nbsp&nbsp<input id="IS_NEW" name="IS_NEW" type="radio"  value="1" />
					新件
				</td>
				<td  class="tbYellow2"  colspan="2" ></td>
				<td class="tbYellow" >
					&nbsp&nbsp<input id="IS_INCREASE" name="IS_INCREASE" type="radio" value="1" />
					增貸件
				</td>
				<td  class="tbYellow2"  colspan="2" >
					(＊請提供原件貸款帳號<input id="LOAN_ID" name="LOAN_ID" type="text" value="" size="11" maxlength="11" readonly="readonly"/>)<br>
					提供原貸帳號件免再輸入土地建物基本資料
				</td>
			</tr>
			<tr>
				<td class="tbYellow"  colspan="6" ><span style="color:red;">*</span>2.借款人資料輸入</td>
			</tr>
			<tr>
				<td class="tbYellow"  >&nbsp&nbsp&nbsp借款人</td>
				<td  class="tbYellow2"  colspan="2" >
					<input id="BORROW_NAME" name="BORROW_NAME" type="text" value=""  size = "16" alt="ch" /><%--[20240930]難字調整 --%>
				</td>
				<td class="tbYellow"  >&nbsp&nbsp&nbsp借款人ID</td>
				<td  class="tbYellow2" colspan="2" >
					<input id="BORROW_ID" name="BORROW_ID" class="ID-check" type="text" value="" size = "12"/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow"  >&nbsp&nbsp&nbsp欲申貸金額</td>
				<td  class="tbYellow2" colspan="2" >
					<input id="APPLY_AMT" name="APPLY_AMT" type="text" value="" datatype="number" maxlength="9" size = "8" />萬
				</td>
				<td class="tbYellow"  ></td>
				<td  class="tbYellow2" colspan="2" >
				</td>
			</tr>
		</tbody>	
	</table>
	</form>
	<div id="areaB" >B</div>
</body>
</html>