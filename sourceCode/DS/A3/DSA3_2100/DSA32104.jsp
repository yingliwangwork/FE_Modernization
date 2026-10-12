<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSA32101.jsp
作者：簡睿甫
功能：基本資料輸入
完成：

[20241119]問題單 20241114165621 doPrint()難字異常
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />
<title></title>
<STYLE TYPE="text/css">


table.grid {
    font-size: 10pt;
    border:1px solid #000;
    border-collapse: collapse;
    background-color: #FFFFFF;
}

table.grid td {
    margin: 0px;
    padding: 2px;
    padding-top: 5px;
    border:1px solid #000;
}

table.grid th {
    margin: 0px;
    padding: 2px;
    padding-top: 5px;
    border:1px solid #000;
}

table.contentTable {
	width:100%;
    font-size: 10pt;
    border:1px solid #000;
    border-collapse: collapse;
    background-color: #FFFFFF;
}

table.contentTable td {
    margin: 0px;
    padding: 2px;
    padding-top: 5px;
    border:1px solid #000;
}

table.contentTable th {
    margin: 0px;
    padding: 2px;
    padding-top: 5px;
    border:1px solid #000;
}

table.contentTable .buttons {
    display:none;
}

</STYLE>
<!--匯入外部Javascript 與 css, 新增請放下面-->

<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>    <%-- 警告訊息用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>         <%-- 判斷BUTTON用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>        <%-- 地址用 --%>

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

Event.observe(window, 'load', new DSA32104().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA32104(){
	var EmpName = '<c:out value="${EmpName}" default="" escapeXml="false" />';
	var PHONE = '<c:out value="${PHONE}" default="" escapeXml="false" />';
	var MOBILE = '<c:out value="${MOBILE}" default="" escapeXml="false" />';
	var DIV_SHORT_NAME = '<c:out value="${DIV_SHORT_NAME}" default="" escapeXml="false" />';
	var PREAPPR_NO = '<c:out value="${PREAPPR_NO}" default="" escapeXml="false" />';
	
	var A280VO = <c:out value="${A280VO}" default="[]" escapeXml="false" />;
	
	var ContentSaves = {};
	
	var sourceChoose = 'PREAPPR_NO';
	
	var PREAPPR_NO = '<c:out value="${PREAPPR_NO}" default="" escapeXml="false" />';
	var LOAN_ID = '<c:out value="${LOAN_ID}" default="" escapeXml="false" />';
	
	var A285List = <c:out value="${A285List}" default="[]" escapeXml="false" />;
	
	var action = {
		initAction:　function(A280VO) {
			// 承辦人員資訊
			$('DIV_NM').update(DIV_SHORT_NAME);
			$('EMP_NM').update('${SHOW_EmpName}');
			$('PHONE').update(PHONE);
			$('MOBILE').update(MOBILE);
			
			if(A280VO) {
				CSRUtil.voToInputs(form, A280VO);
				$('BUILD_MEASURE_C').value = '${BUILD_MEASURE}'!='' ? CSRUtil.$fmt('${BUILD_MEASURE}', CSRUtil.defaultPattern) : '';
				
				// DSA32101
				$('PREAPPR_NO').update(PREAPPR_NO);
				
				// DSA32103
				<%--[20241119]難字調整--%>
				$('BORROW_NAME').update('${SHOW_BORROW_NAME}');
				$('BORROW_ID').update(A280VO['BORROW_ID'] ? CSRUtil.maskHandler.getMaskID(A280VO['BORROW_ID']) : '');
				$('APPLY_AMT').update(A280VO['APPLY_AMT'] ? CSRUtil.$fmt(A280VO['APPLY_AMT']+'萬', CSRUtil.defaultPattern) : '');
				$('PREAPPR_ZIP').update(A280VO['PREAPPR_ZIP']);
				var LAND_MEASURE = "${LAND_MEASURE}" ? "土地${LAND_MEASURE}坪" : "";
				var BUILD_MEASURE = "${BUILD_MEASURE}" ? " 建物${BUILD_MEASURE}坪" : "";
				var PF_MEASURE = "${PF_MEASURE}" ? " (含公設${PF_MEASURE}坪)" : "";
				$('MEASURE').update( LAND_MEASURE+BUILD_MEASURE+PF_MEASURE );
				
				$('AGENT_DATE_VIEW').innerHTML = Date.toROC(getY2KToday());
			} else {
				$('form').reset();
			}
		},
		
		createUserInterface: function() {
			//-------------------------------------------------------------------------------------------------
			// Block B
			// 建物地址
			//-------------------------------------------------------------------------------------------------
			var areaBsetting =
			{ 
				elem:"areaB", dataColumns: 6, className:"contentBlue", clearChildElements:false, noContent:false, noHeader:true, columnProps:[ 1, 20, 20, 20, 20, 20],
				contents:[
					 { header:"選取", rowSpan:3, values:[ 
						{key:"CHOOSE", type:"radio", items:{1:""}, attrs:{name:"delTagB"} , events :{ click:function(target){ RecrodsControl.selectToDelete("B" , target); } } } 
					 ]}
					,{ header:"建物地址", colSpan:5, values:[ 
						{ key:"SERV_ADDR_ZIP",type:"dom",attrs:{ preKey:"GAGE", inputType:2, className:"required" }
							,elem:theDSZ01000control.create
							,getFunc:theDSZ01000control.get
							,setFunc:theDSZ01000control.set  
						}
					 ]} , 
					{ header:"建號", values:[
						{key:"BUILD_NO1", type:"number" , attrs:{ pattern:"#####" , size:'10', maxLength:'5'},
						 setFunc: function(node , value , values ){
							if(value == '00000'){
								return '0000';
							} else {
								return value;
							}
						}},
						'-',
						{key:"BUILD_NO2", type:"number" , attrs:{ pattern:"###" , size:'10', maxLength:'3'},
						 setFunc: function(node , value , values ){
							if(value == '000'){
								return '00';
							} else {
								return value;
							}
						}} 						
					]},
					{ header:"面積(含陽露台)", colSpan:2, values:[
						{key:"BUILD_MEASURE", type:"number" , attrs:{ pattern:"#,###.####" , size:'10', maxLength:'8', className:"required validate-greater-than-zero"},
							events:{ "blur":function(target){
								var value = target.getValue();
								button.doGearing(value, "", 'BUILD_MEASURE', 'BUILD_MEASURE_F2', target.id);
							}}
						},
						'平方公尺或',
						{key:"BUILD_MEASURE_F2", type:"number" , attrs:{ pattern:"#,###.####" , size:'10', maxLength:'8', className:"required validate-greater-than-zero"},
							events:{ "blur":function(target){
								var value = target.getValue();
								button.doGearing("", value, 'BUILD_MEASURE_F2', 'BUILD_MEASURE', target.id);
							}}
						},
						'坪'
					 ]}
					,{ header:"持分", values:[
						{key:"HOLD_BASE", type:"number" , attrs:{ pattern:"########" , size:'10', maxLength:'8', className:"required validate-greater-than-zero"}},
						'分之',
						{key:"HOLD_UP", type:"number" , attrs:{ pattern:"########" , size:'10', maxLength:'8', className:"required validate-greater-than-zero"}}
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
							,attrs:{ datatype:"rocdate" , pattern:"yyy/MM/dd", className:"checkIsROCDate" }
						}
					]},
					{ header:"主要用途", values:[

						{key:"MAIN_USE",  type:"radio" ,itemKey:"key",itemValueKey:"value",items: selectionOptions.MAIN_USE_LIST , attrs:{}}						
					]},
					{ header:"建物型態", values:[
						{key:"BUILD_TYPE",  type:"select" ,optKey:"key",optValueKey:"value",opts: selectionOptions.BUILD_TYPE_LIST , attrs:{className:"required"}}
					]},
					{ header:"總樓層", values:[
						{key:"FLOOR", type:"number" , attrs:{ pattern:"########" , size:'10', maxLength:'8', className:"required"}}
					]},
					{ header:"有無車位", colSpan:2, values:[
						{key:"HAS_PARK",  type:"radio" ,itemKey:"key",itemValueKey:"value",items: selectionOptions.HAS_PARK_LIST , attrs:{}}
					]}
				]
			}
			var areaBcontent = RecrodsControl.createRecord( "B" , areaBsetting ).parentNode;
			ContentSaves["B"] = areaBcontent;
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
									var radioItems = document.getElementsByName(ele.name);
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
									var radioItems = document.getElementsByName(ele.name);
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
							var radioItems = document.getElementsByName(ele.name);
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
							var radioItems = document.getElementsByName(ele.name);
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
			var span = JsUtils.createDOMElement("span" , {sno:sno , id:"autoDSZ01000"+sno , DSZ01000:true});
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
			autoFormatToNumber();
			autoFormatToDate();
			action.initAction(A280VO);
			<%--[20241119]難字處理，隱藏原有的PREAPPR_ADDR--%>
			$('PREAPPR_ADDR').hide();

			//action.createUserInterface();
			
			//RecrodsControl.loadin( 'B' , A285List );
			parseEUDC();
			displayMessage();
			
			/*
			
			$$('select').each(function(record){
				record.disabled = true;
			});
			
			$$('input[type="radio"]').each(function(record){
				record.disabled = true;
			});
			
			$$('input[type="checkbox"]').each(function(record){
				record.disabled = true;
			});*/
			
			$$('input[type="text"]').each(function(record){
				record.readOnly = true;
			});
			
			<%--[20241119]難字處理，註解img display=none--%>
			/*$$('img').each(function(record){
				record.style.display = 'none';
			});*/
			
			if(msgs[0][5] == "0"){
				window.print();
			}
			
			CSRUtil.createCoverPage({'id':'DSA32104_coverpage', 'transparent':true, 'cursor':'auto', 'show': true});
			
		}// end initApp()--
	}// end return--
}// end DSA32104
</script>
</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form">
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="grid">
		<tbody>
			<tr>
				<td class="tbYellow" width="15%" >單位</td>
				<td id="DIV_NM" class="tbYellow2" colspan="5" ></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >姓名</td>
				<td id="EMP_NM" class="tbYellow2" style="font-family:'EUDC'"></td>
				<td class="tbYellow" width="15%" >電話</td>
				<td id="PHONE" class="tbYellow2"></td>
				<td class="tbYellow" width="15%" >手機</td>
				<td id="MOBILE" class="tbYellow2"></td>
			</tr>
			<tr>
				<td id="" class="tbYellow2"  colspan="6" >
					【重要說明事項】<br>
					1.本線上初估系統為簡略性作業畫面，僅供申貸與否參考，實際仍需查詢借款人債信及擔保品實地勘查。<br>
					2.提供您公司承作區域仍有未開放者，甚或工業住宅、臨重大嫌惡設施等建物，原則不承作。<br>
					3.本初估不得作為客戶買賣參考依據。
				</td>
			</tr>
			
		</tbody>	
	</table>
	
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="grid">
		<tbody>
			<tr>
				<td class="tbYellow" width="15%" >初估編號</td><td class="tbYellow2"><span id="PREAPPR_NO"></span></td>
			</tr>
			<tr>
				<td class="tbYellow"  colspan="2" >1.借款人資料</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >借款人</td><td class="tbYellow2"><span id="BORROW_NAME" style="font-family:'EUDC'"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >借款人ID</td><td class="tbYellow2"><span id="BORROW_ID"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >欲申貸金額</td><td class="tbYellow2"><span id="APPLY_AMT"></span></td>
			</tr>
			<tr>
				<td class="tbYellow"  colspan="2" >2.擔保品內容</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >建物郵遞區號</td><td class="tbYellow2"><span id="PREAPPR_ZIP"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >建物地址</td>
				<td class="tbYellow2" >
					<input id="SHOW_PREAPPR_ADDR" name="SHOW_PREAPPR_ADDR" type="text" size="80" alt="ch" value='${SHOW_PREAPPR_ADDR}'/>
					<input id="PREAPPR_ADDR" name="PREAPPR_ADDR" type="text" size="80" alt="ch"/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >總坪數</td><td class="tbYellow2"><span id="MEASURE"></span></td>
			</tr>
			<tr>
				<td class="tbYellow"  colspan="2" >3.區域放款率</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >主要用途</td>
				<td class="tbYellow2" >
					<c:forEach var="map" items="${MAIN_USE_LIST_1}" >
						<input disabled  name="MAIN_USE" type="radio" class="button" value = "${map.key}"/> ${map.value}  
					</c:forEach>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >公司放款區域成數</td>
				<td class="tbYellow2" >
					<input readOnly  readOnly  id="AREA_CODE" name="AREA_CODE" type="text" value="" size="3" />區
					<input readOnly  readOnly  id="LIMIT_RATE" name="LIMIT_RATE" type="text" value="" size="5" datatype="number"/>%成數
				</td>
			</tr>
			<tr>
				<td id="" class="tbYellow2"  colspan="2" >
					【重要說明事項1】<br>
					 (1) 擔保品若屬於主管機關認定的特定地區或高價住宅，受『購罝住宅貸款業務規範』限制。<br>
					 (2) 『購罝住宅貸款業務規範』承作成數最高60%，不得申請只繳利息，利率亦不得低於公司規定。
				</td>
			</tr>
			
			<tr>
				<td class="tbYellow"  colspan="2" >4.初估貸放金額</td>
			</tr>
			<tr>
				<td class="tbYellow2"  colspan="2" >(1)平均單價查詢
				</td>
			</tr>
			<tr>
				<td class="tbYellow2"  colspan="2" >
					初估貸放金額(萬)<input readOnly  readOnly  id="TOTAL_PRICE" name="TOTAL_PRICE" type="text" value="" datatype="number" value="" size="12" pattern="#,###.##"/>
					=建物<input readOnly  readOnly  readOnly  id="BUILD_MEASURE_C" name="BUILD_MEASURE" type="text" value="" size="10" datatype="number"/>
					(坪)X<input readOnly  readOnly  id="PER_PRICE" name="PER_PRICE" type="text" value="" datatype="number" value="" size="10" pattern="#,###.##"/>
					輸入均價(萬)X<input readOnly  readOnly  readOnly  id="LIMIT_RATE_C" name="LIMIT_RATE" type="text" value="" size="5" datatype="number"/>
					%放款成數
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >申請日期</td>
				<td class="tbYellow2" id="AGENT_DATE_VIEW"></td>
			</tr>
			<tr>
				<td id="" class="tbYellow2"  colspan="2" >
					【重要說明事項2】<br>
					(1) 初估貸放金額未扣除『土地增值稅』及未考慮擔保品有『嫌惡設施』情形。<br>
					(2) 實際可承作額度內容需視『借款人債信收入條件』及『投資客規範』重新評估。
				</td>
			</tr>
		</tbody>	
	</table>
	</form>
</body>
</html>