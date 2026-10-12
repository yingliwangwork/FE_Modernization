<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSA11600
功能：法金件明細輸入
作者： 
完成： 
[20220309] 修改件：申請書[調整聯徵授信餘額月報資料檔案格式(代號:B201)]，增加「永續績效連結約定條件全部未達成」欄位
[20221012] 修改件：配合聯徵信增加購地貸款相關資料之報送    修改人員：吳誌倫
[20240730] 修改件 難字調整
-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<%--[20240730]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<script language="javascript" type="text/javascript">

var valid1;
var grid;
var ACTION_TYPE='';
function buttonAuth(){
	var authButtons = {
			B0003:"btn_insert"<%--新增--%> ,
			B0004:"btn_update"<%--修改--%> ,
			B0005:"btn_delete"<%--刪除--%>
	};
	<dz:grantButtons FUNC_ID="DSA11600" ignored="false"/>
}


function initApp(){  
  	buttonAuth();
	
	PageUI.createPage("DSA11600" , "受理作業" ,"法金件明細輸入");
    PageUI.loadin(["form1","grid"] ,1);
	
	new UI().init();
	
	$("btn_query").observe('click',function(event){ buttons.doQuery(); });
	$("btn_insert").observe('click',function(event){ buttons.doInsert(); });
	$("btn_update").observe('click',function(event){ buttons.doUpdate(); });
	$("btn_delete").observe('click',function(event){ buttons.doDelete(); });
	
	valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
	Validation.addAllThese([
		[ 'validateBORROW_ID',  '請輸入借款人ID!', function(){ if( getRadioValue('form1','QUERY_TYPE') =="BORROW_ID" && $F('BORROW_ID') === "" && ACTION_TYPE=='query'){ return false; } $('BORROW_ID').value=$F('BORROW_ID').toUpperCase(); return true; } ] ,
		[ 'validateLOAN_ID',  '請輸入貸款帳號!', function(){ if( getRadioValue('form1','QUERY_TYPE') =="LOAN_ID" && $F('LOAN_ID') === "" && ACTION_TYPE=='query'){ return false; } $('LOAN_ID').value=$F('LOAN_ID').toUpperCase(); return true; } ] ,
		[ 'validateAPPLY_ID',  '請輸入受理編號!', function(){ if( getRadioValue('form1','QUERY_TYPE') =="APPLY_ID" && $F('APPLY_ID') === ""  && ACTION_TYPE=='query'){ return false; } $('APPLY_ID').value=$F('APPLY_ID').toUpperCase(); return true; } ] ,
		[ 'validateSTR_DT',  '開始年月輸入資料錯誤', function(v){ return (isNumeric(disZero(v)) && isROCdate(disZero(v)+""+"01",false)); } ] ,
		[ 'validateEND_DT',  '截止年月月份輸入錯誤', function(v){ return (isNumeric(disZero(v)) && isROCdate(disZero(v)+""+"01",false)); } ] ,
		[ 'chkUsableID',  '請輸入正確借款人ID', function(v){ if(v.length == 8){ return iscmpid(v) }else{ return validation.checkROCID(v) } return true; } ],
		[ 'chkDate',  '請輸入正確日期格式', function(v){ if(v.length > 0){ return isROCdate(v) } return true; } ],
		[ 'validateUsableID',  '請輸入正確借款人ID', function(v){ if(getRadioValue('form1','QUERY_TYPE') =="BORROW_ID"){ if(v.length == 8){ return iscmpid(v) }else{ return validation.checkROCID(v)	} } return true; } ]
	]);
	
	PageUI.resize(true);
		
}


//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

var grid_count = 0;
var checkRadio;
var preClick;

function UI(){

	var CIRCLE_CREDList = {};<c:forEach items="${CIRCLE_CREDList}" var="circleCredEntry" varStatus="status">CIRCLE_CREDList['<c:out value="${circleCredEntry.key}"/>']='<c:out value="${circleCredEntry.value}"/>';</c:forEach>

	var UNION_LOANList = {};<c:forEach items="${UNION_LOANList}" var="unionLoanEntry" varStatus="status">UNION_LOANList['<c:out value="${unionLoanEntry.key}"/>']='<c:out value="${unionLoanEntry.value}"/>';</c:forEach>

	var FINANCE_CANCEList = {};<c:forEach items="${FINANCE_CANCEList}" var="financeCanceEntry" varStatus="status">FINANCE_CANCEList['<c:out value="${financeCanceEntry.key}"/>']='<c:out value="${financeCanceEntry.value}"/>';</c:forEach>
	<%--[20220309] 「永續績效連結約定條件全部未達成」下拉選單接值--%>
	var INCOMPLETE_ESGList = {};<c:forEach items="${INCOMPLETE_ESGList}" var="incompleteESGEntry" varStatus="status">INCOMPLETE_ESGList['<c:out value="${incompleteESGEntry.key}"/>']='<c:out value="${incompleteESGEntry.value}"/>';</c:forEach>
	
	return{

		init:function(){
		
			//產生 Grid 物件
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 0, allSortable: true, split :["BORROW_ID"], allSortable:false,
					<%--[20240730] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					autoCheckBox:{
						text:"請選擇",
						type:"radio",
						action:function( node , checkStatus , records){
							if(checkStatus){
								checkRadio = node;
							}
							var td = getCellByTagName(node,"TD");
							var rowSpan = td.rowSpan || 1;
							var tr = td.parentNode;
							var isNotNullLine = records[0].UPDATE_ID;
							if(preClick){
								grid.exchangeAutoInput( preClick , 
									["LOAN_ID","UNION_AMT","UNION_BEGDT","CIRCLE_CRED","FINANCE_CANCEL","UNION_LOAN","UNION_DATE",
									 "UNION_RATIO","TOTAL_UNION_AMT","BORROW_ID","BORROW_NAME","UNION_ENDDT","INCOMPLETE_ESG","LAND_LOAN","AGREE_CONST","REAL_CONST"]);
							}
							if(isNotNullLine){
								preClick = tr;
								grid.exchangeAutoInput( tr , 
									["LOAN_ID","UNION_AMT","UNION_BEGDT","CIRCLE_CRED","FINANCE_CANCEL","UNION_LOAN","UNION_DATE",
									 "UNION_RATIO","TOTAL_UNION_AMT","BORROW_ID","BORROW_NAME","UNION_ENDDT","INCOMPLETE_ESG","LAND_LOAN","AGREE_CONST","REAL_CONST"]);
							}else{
								preClick = null;
							}
							for(var i = 0 ; i < rowSpan ; i = i + 1 ){
								tr.validation.reset();
								if(checkStatus && isNotNullLine){
									tr.validation.validate();
								}
								if(tr.nextSibling){
									tr = tr.nextSibling;
								}
							}
							//$('grid').parentNode.resetDivHeight();
						}
					},					
					column:[
						//line1
						{header:"受理編號", key:"APPLY_ID",
							input:{
								type:"text", maxlength :11, 
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action: function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){
										grid_count = grid_count + 1;
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
										if(!records[0].UPDATE_ID){
											inputNode.className = "text2 required";
										}
									}else{
										var newValue = inputNode.value.toUpperCase();
										inputNode.value = newValue;
										records[0].APPLY_ID = newValue;
									}
								},
								actionWhenStart :true
							}
						},
						{header:"貸款帳號", key:"LOAN_ID",
							input:{
								type:"text", maxlength :10, //className :"text2 required",
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action: function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){						
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}else{
										var newValue = inputNode.value.toUpperCase();
										inputNode.value = newValue;
										records[0].LOAN_ID = newValue;
									}
								},
								actionWhenStart :true
							}
						},
						{header:"訂約金額", key:"UNION_AMT", attrs:{rowSpan:2},
							input:{
								type:"text", maxlength :10, className :"text2 required validate-number",
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action : function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){							
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}else{
										if(inputNode.value){
											var newValue = addZero ( inputNode.value , 10);
											inputNode.value = newValue;
											records[0].UNION_AMT = newValue;
											textElement.innerText = newValue;
										}
									}
								},
								actionWhenStart :true
							}
						},
						{header:"開始年月", key:"UNION_BEGDT",
							input:{
								type:"text", maxlength :5,  className :"text2 required validateSTR_DT",
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action : function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){							
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}else{
										if(inputNode.value){
											var newValue = addZero ( inputNode.value , 5);
											inputNode.value = newValue;
											records[0].UNION_BEGDT = newValue;
											textElement.innerText = newValue;
										}
									}
								},
								actionWhenStart :true
							}
						},
						<%--[20220309] 增加「永續績效連結約定條件全部未達成」欄位--%>
						{header:"永續績效連結約定<br>條件全部未達成<br><font color='red'>(條件全部未達成<br>即點選「是」)</font>", key:"INCOMPLETE_ESG", attrs:{rowSpan:2},
							input:{
								type:"select", opts:INCOMPLETE_ESGList,
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action: function(inputNode,records,textElement,orgData,isOnChange ){
								    if (records[0].ESG_TYPE=='0' || !records[0].ESG_TYPE){
											inputNode.disable();
									}
									if(!isOnChange){		
										textElement.innerText = records[0].INCOMPLETE_ESG_NM;
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}
								},
								actionWhenStart :true
							}
						},
						{header:"循環信用", key:"CIRCLE_CRED", attrs:{rowSpan:2},
							input:{
								type:"select", opts:CIRCLE_CREDList,
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action: function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){		
										textElement.innerText = records[0].CIRCLE_CRED_NM;
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}
								},
								actionWhenStart :true
							}
						},
						{header:"額度撤銷", key:"FINANCE_CANCEL", attrs:{rowSpan:2},
							input:{
								type:"select", opts:FINANCE_CANCEList, 
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action: function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){							
										textElement.innerText = records[0].FINANCE_CANCEL_NM;
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}
								},
								actionWhenStart :true
							}
						},
						{header:"聯貸表示", key:"UNION_LOAN", attrs:{rowSpan:2},
							input:{
								type:"select", opts:UNION_LOANList, 
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action: function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){	
										textElement.innerText = records[0].UNION_LOAN_NM;
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}
								},
								actionWhenStart :true
							}
						},
						{header:"簽約日", key:"UNION_DATE", attrs:{rowSpan:2},
							input:{
								type:"date", imgBase:"<%=imageBase%>",  className :"text2 chkDate",
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action : function(inputNode,records,textElement,orgData,isOnChange ){
									inputNode.maxLength=7;
									if(!isOnChange){
										inputNode.setAttribute("datatype","ROCDate");
										if(inputNode.value){
											var newDate = inputNode.value;
											if(newDate){
												newDate = newDate.substr(0,4)+"-"+newDate.substr(4,2)+"-"+newDate.substr(6,2);
												var newROCDate = toROC(newDate);
												inputNode.value = newROCDate;
												textElement.innerHTML = newROCDate;
											}
											//
											inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
										}
									}else{
										if(inputNode.value){
											records[0].UNION_DATE = toY2K(inputNode.value);
										}
									}
								},
								actionWhenStart :true
							}
						},
						{header:"參貸比率", key:"UNION_RATIO", attrs:{rowSpan:2},
							input:{
								type:"text", maxlength :4, className :"text2 required validate-number",
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action : function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){							
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}else{
										var newValue = addZero ( inputNode.value , 4);
										inputNode.value = newValue;
										records[0].UNION_RATIO = newValue;
										textElement.innerText = newValue;
									}
								},
								actionWhenStart :true
							}
						},
						{header:"總(聯)貸金額", key:"TOTAL_UNION_AMT", attrs:{rowSpan:2},
							input:{
								type:"text", maxlength :10, className :"text2 required validate-number",
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action : function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){							
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}else{
										var newValue = addZero ( inputNode.value , 10);
										inputNode.value = newValue;
										records[0].TOTAL_UNION_AMT = newValue;
										textElement.innerText = newValue;
									}
								},
								actionWhenStart :true
							}
						},
						<%--[20221012] 增加「央行購地貸款」欄位--%>
						{header:"央行購地貸款", key:"LAND_LOAN", attrs:{rowSpan:2},
							input:{
								type:"select", opts:INCOMPLETE_ESGList,
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action: function(inputNode,records,textElement,orgData,isOnChange ){
									//初始
									if(!isOnChange){
										textElement.innerText = records[0].LAND_LOAN_NM;
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
										if(records[0].LAND_LOAN){
											inputNode.value = records[0].LAND_LOAN;
										}else{
											inputNode.value = 'N';
											records[0].LAND_LOAN = 'N';
										}
									} else { //異動時
										records[0].LAND_LOAN = inputNode.value;
										var thisAC = grid.getAutoInput(inputNode, "AGREE_CONST")[0]['AGREE_CONST'];
										var thisRC = grid.getAutoInput(inputNode, "REAL_CONST")[0]['REAL_CONST'];
										
										if(inputNode.value == 'N'){
											records[0].AGREE_CONST = '';
											thisAC.value = '';
											thisAC.readOnly = true;
											thisAC.style.backgroundColor = '#CED4D5';
											records[0].REAL_CONST = '';
											thisRC.value= '';
											thisRC.readOnly = true;
											thisRC.style.backgroundColor = '#CED4D5';
										}else{
											thisAC.readOnly = false;
											thisAC.style.backgroundColor = '';
											thisRC.readOnly = false;
											thisRC.style.backgroundColor = '';
										}
									}
								},
								actionWhenStart :true
							}
						},
						<%--[20221012] 增加「約定動工年月」欄位--%>
						{header:"約定動工年月<br><font color='red'>(輸入YYYMM「例11205」<br>；若尚未確認或無約定動工<br>年月，輸入「00000」)</font>", key:"AGREE_CONST", attrs:{rowSpan:2},
							input:{
								type:"text", maxlength :5, className :"text2 required validate-number",
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action : function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){							
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
										if(!records[0].LAND_LOAN || records[0].LAND_LOAN == 'N'){
											records[0].AGREE_CONST = '';
											inputNode.value = '';
											inputNode.readOnly = true;
											inputNode.style.backgroundColor = '#CED4D5';
										}else if(records[0].AGREE_CONST){
											inputNode.value = records[0].AGREE_CONST;
										}else{
											inputNode.value = '';
										}
									}else{
										records[0].AGREE_CONST = inputNode.value;
									}
								},
								actionWhenStart :true
							}
						},
						<%--[20221012] 增加「實際動工年月」欄位--%>
						{header:"實際動工年月<br><font color='red'>(輸入YYYMM<br>；若尚未動工，<br>輸入「00000」)</font>", key:"REAL_CONST", attrs:{rowSpan:2},
							input:{
								type:"text", maxlength :5, className :"text2 required validate-number",
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action : function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){							
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
										if(!records[0].LAND_LOAN || records[0].LAND_LOAN == 'N'){
											records[0].REAL_CONST = '';
											inputNode.value = '';
											inputNode.readOnly = true;
											inputNode.style.backgroundColor = '#CED4D5';
										}else if(records[0].REAL_CONST){
											inputNode.value = records[0].REAL_CONST;
										}else{
											inputNode.value = '';
										}
									}else{
										records[0].REAL_CONST = inputNode.value;
									}
								},
								actionWhenStart :true
							}
						},
						<%--[20240730] 難字調整 --%>
						{header:"作業人員", key:"UPDATE_NM", attrs:{rowSpan:2, style:"font-family:'EUDC'"}},
						{header:"作業日期", key:"UPDATE_DATE", attrs:{rowSpan:2}},
						//line2
						{header:"借款人ID", key:"BORROW_ID",
							input:{
								type:"text", maxlength :10,  className :"text2 required chkUsableID",
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action: function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){							
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}else{
										var newValue = inputNode.value.toUpperCase();
										inputNode.value = newValue;
										records[0].LOAN_ID = newValue;
									}
								},
								actionWhenStart :true
							}
						},
						{header:"借款人姓名", key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"}},
						{header:"截止年月", key:"UNION_ENDDT", 
							input:{
								type:"text", maxlength :5, className :"text2 required validateEND_DT",
								genRule : function(rec , value){ if(rec.UPDATE_ID){return false;} return true; },
								action : function(inputNode,records,textElement,orgData,isOnChange ){
									if(!isOnChange){							
										inputNode.id = (inputNode.name || inputNode.submitName) + grid_count;
									}else{
										if(inputNode.value){
											var newValue = addZero ( inputNode.value , 5);
											inputNode.value = newValue;
											records[0].UNION_ENDDT = newValue;
											textElement.innerText = newValue;
										}
									}
								},
								actionWhenStart :true
							}
						}
					],
					afterLoad:function( table ){
						var grid_count = 0;
						var preClick = null;
						var trs = $('grid').select('tbody tr').each(function(tr){
							if(tr.dataObj){
								tr.validation =  new Validation(tr, {useTitles:true,focusOnError:false,immediate:false});
							}
						});
						
						var radioes = $('grid').select("input[type=radio]");
						radioes[radioes.length-1].checked = true;
						checkRadio = radioes[radioes.length-1];
						
						var radioes = $('grid').select("td[name=UNION_DATE]").each( function(ele){ 

							if(ele.parentNode.dataObj && ele.parentNode.dataObj.UNION_DATE){
								var newDate=ele.parentNode.dataObj.UNION_DATE;
								ele.parentNode.dataObj.UNION_DATE = newDate.substr(0,4)+"-"+newDate.substr(4,2)+"-"+newDate.substr(6,2);
							}
						})
						
					}
				}
			);
			<%--[20220309] 增加INCOMPLETE_ESG欄位--%>
			grid.load([{CIRCLE_CRED:"Y",FINANCE_CANCEL:"Y",UNION_LOAN:"Y", INCOMPLETE_ESG:"N", ESG_TYPE:"N"}]);
			
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){
		ACTION_TYPE='query';
		valid1.reset();
		modifyClassName(ACTION_TYPE);
		if( !valid1.validate() ) {return;}		
		
		var activeRule = getRadioValue('form1','QUERY_TYPE');
		var activeMap = {};
		activeMap[activeRule] =  $F(activeRule);
		
		new Ajax.Request("<%=dispatcher%>/DSA1_1600/query", 
		{
			parameters: activeMap,
		 	onSuccess:function(XHT, resp){
		 		<%--[20220309] 增加INCOMPLETE_ESG欄位--%>
				if(CSRUtil.isSuccess(resp)){		
					resp.rtnList[resp.rtnList.length]={CIRCLE_CRED:"Y",FINANCE_CANCEL:"Y",UNION_LOAN:"Y", INCOMPLETE_ESG:"N", ESG_TYPE:"N"};
					grid.load(resp.rtnList);
				}else{
					if(resp.DataNotFoundException){
						grid.load([{CIRCLE_CRED:"Y",FINANCE_CANCEL:"Y",UNION_LOAN:"Y", INCOMPLETE_ESG:"N", ESG_TYPE:"N"}]);
					}
				}
			}
		});
	},
	doInsert:function(){
		ACTION_TYPE='insert';
		modifyClassName(ACTION_TYPE);
		var radioes = $('grid').select("input[type=radio]");
		if( radioes[radioes.length-1] != checkRadio){
			alert("請點選最後一筆資料，新增聯貸紀錄");
			return;
		}
		valid1.reset();
		var td = getCellByTagName(checkRadio,"TD");
		var rowSpan = td.rowSpan || 1;
		var tr = td.parentNode;
		var dataMap = tr.dataObj;
		
		var isValidPass = true;
		for(var i = 0 ; i < rowSpan ; i = i + 1 ){
			tr.validation.reset();
			isValidPass = tr.validation.validate() && isValidPass;
			if(tr.nextSibling){
				tr = tr.nextSibling;
			}
		}
		//$('grid').parentNode.resetDivHeight();
		if( !valid1.validate() || !isValidPass ) {return;}
		
		//[20221012]若央行購地貸款為'是'，則約定動工年月和實際動工年月不可為空。
		var errStr = "";
		if(dataMap.LAND_LOAN == 'Y'){
			if(!dataMap.AGREE_CONST){
				errStr = errStr + '約定動工年月不可為空。';
			}else if(!isNumeric2(dataMap.AGREE_CONST)){
				errStr = errStr + '約定動工年月僅限輸入數字。';
			}
			if(!dataMap.REAL_CONST){
				errStr = errStr + '實際動工年月不可為空。';
			}else if(!isNumeric2(dataMap.REAL_CONST)){
				errStr = errStr + '實際動工年月僅限輸入數字。';
			}
			if(errStr.length > 0){
				alert(errStr);
				return;
			}
		}
		
		var activeRule = getRadioValue('form1','QUERY_TYPE');
		var qryMap = {}
		qryMap[activeRule] =  $F(activeRule);
		//設定查詢條件
		qryMap['BORROW_ID']=dataMap.BORROW_ID;
		qryMap['APPLY_ID']=dataMap.APPLY_ID;
		
		
		new Ajax.Request("<%=dispatcher%>/DSA1_1600/insert", 
		{
			parameters: {qryMap:Object.toJSON(qryMap) , dataMap:Object.toJSON(dataMap)},
		 	onSuccess:function(XHT, resp){
		 		<%--[20220309] 增加INCOMPLETE_ESG欄位--%>
				if(CSRUtil.isSuccess(resp)){
					if(resp.rtnList){
						resp.rtnList[resp.rtnList.length]={CIRCLE_CRED:"Y",FINANCE_CANCEL:"Y",UNION_LOAN:"Y", INCOMPLETE_ESG:"N", ESG_TYPE:"N"};
						grid.load(resp.rtnList);
					}else{
						grid.load([{CIRCLE_CRED:"Y",FINANCE_CANCEL:"Y",UNION_LOAN:"Y", INCOMPLETE_ESG:"N", ESG_TYPE:"N"}]);
					}		
					
				}
			}
		});
	},
	doUpdate:function(){
		ACTION_TYPE='update';
		modifyClassName(ACTION_TYPE);
		var radioes = $('grid').select("input[type=radio]");
		if( radioes[radioes.length-1] == checkRadio){
			alert("請點選待修改資料，更新聯貸紀錄");
			return;
		}
		valid1.reset();
		var td = getCellByTagName(checkRadio,"TD");
		var rowSpan = td.rowSpan || 1;
		var tr = td.parentNode;
		var dataMap = tr.dataObj;
		var isValidPass = true;
		for(var i = 0 ; i < rowSpan ; i = i + 1 ){
			tr.validation.reset();
			isValidPass = tr.validation.validate() && isValidPass;
			if(tr.nextSibling){
				tr = tr.nextSibling;
			}
		}
		//$('grid').parentNode.resetDivHeight();
		if( !valid1.validate() || !isValidPass ) {return;}
		
		//[20221012]若央行購地貸款為'是'，則約定動工年月和實際動工年月不可為空。
		var errStr = "";
		if(dataMap.LAND_LOAN == 'Y'){
			if(!dataMap.AGREE_CONST){
				errStr = errStr + '約定動工年月不可為空。';
			}else if(!isNumeric2(dataMap.AGREE_CONST)){
				errStr = errStr + '約定動工年月僅限輸入數字。';
			}
			if(!dataMap.REAL_CONST){
				errStr = errStr + '實際動工年月不可為空。';
			}else if(!isNumeric2(dataMap.REAL_CONST)){
				errStr = errStr + '實際動工年月僅限輸入數字。';
			}
			if(errStr.length > 0){
				alert(errStr);
				return;
			}
		}
		
		var activeRule = getRadioValue('form1','QUERY_TYPE');
		var qryMap = {}
		qryMap[activeRule] =  $F(activeRule);
		//設定查詢條件
		qryMap['BORROW_ID']=dataMap.BORROW_ID;
		qryMap['APPLY_ID']=dataMap.APPLY_ID;
		
		//跳出確認視窗，讓user確認目前作業的受理編號。
		var answer = confirm("受理編號："+dataMap.APPLY_ID+" 是否修改？")<%--受理編號 * 是否修改？--%>;
			if (!answer){
				return;
		}

		new Ajax.Request("<%=dispatcher%>/DSA1_1600/update", 
		{
			parameters: {qryMap:Object.toJSON(qryMap) , dataMap:Object.toJSON(dataMap)},
		 	onSuccess:function(XHT, resp){
		 		<%--[20220309] 增加INCOMPLETE_ESG欄位--%>
				if(CSRUtil.isSuccess(resp)){		
					if(resp.rtnList){
						resp.rtnList[resp.rtnList.length]={CIRCLE_CRED:"Y",FINANCE_CANCEL:"Y",UNION_LOAN:"Y", INCOMPLETE_ESG:"N", ESG_TYPE:"N"};
						grid.load(resp.rtnList);
					}else{
						grid.load([{CIRCLE_CRED:"Y",FINANCE_CANCEL:"Y",UNION_LOAN:"Y", INCOMPLETE_ESG:"N", ESG_TYPE:"N"}]);
					}
				}
			}
		});
	},
	doDelete:function(){
		ACTION_TYPE='delete';
		modifyClassName(ACTION_TYPE);
		var radioes = $('grid').select("input[type=radio]");
		if( radioes[radioes.length-1] == checkRadio){
			alert("請點選待刪除資料，刪除聯貸紀錄");
			return;
		}
		valid1.reset();
		var td = getCellByTagName(checkRadio,"TD");
		var rowSpan = td.rowSpan || 1;
		var tr = td.parentNode;
		var dataMap = tr.dataObj;
		var isValidPass = true;
		for(var i = 0 ; i < rowSpan ; i = i + 1 ){
			tr.validation.reset();
			isValidPass = tr.validation.validate() && isValidPass;
			if(tr.nextSibling){
				tr = tr.nextSibling;
			}
		}
		//$('grid').parentNode.resetDivHeight();
		if( !valid1.validate() || !isValidPass ) {return;}
		
		var activeRule = getRadioValue('form1','QUERY_TYPE');
		var qryMap = {}
		qryMap[activeRule] =  $F(activeRule);
		//設定查詢條件
		qryMap['BORROW_ID']=dataMap.BORROW_ID;
		qryMap['APPLY_ID']=dataMap.APPLY_ID;
		
		new Ajax.Request("<%=dispatcher%>/DSA1_1600/delete", 
		{
			parameters: {qryMap:Object.toJSON(qryMap) , dataMap:Object.toJSON(dataMap)},
		 	onSuccess:function(XHT, resp){
		 		<%--[20220309] 增加INCOMPLETE_ESG欄位--%>
				if(CSRUtil.isSuccess(resp)){		
					if(resp.rtnList){
						resp.rtnList[resp.rtnList.length]={CIRCLE_CRED:"Y",FINANCE_CANCEL:"Y",UNION_LOAN:"Y", INCOMPLETE_ESG:"N", ESG_TYPE:"N"};
						grid.load(resp.rtnList);
					}else{
						grid.load([{CIRCLE_CRED:"Y",FINANCE_CANCEL:"Y",UNION_LOAN:"Y", INCOMPLETE_ESG:"N", ESG_TYPE:"N"}]);
					}
				}
			}
		});
	}
	
};

function modifyClassName(action_type){
	if(action_type=='query'){
		$('BORROW_ID').className='text2 validateBORROW_ID validateUsableID';
	}else{
		$('BORROW_ID').className='text2 validateBORROW_ID';
	}
}

function getRadioValue( form , inputName){
	var radioes = document.getElementsByName(inputName);	
	//var radioes = $(form)[inputName];
	if(radioes){
		if(radioes.value != 'undefined' && radioes.checked){ 
			return radioes.value 
		}else{
			for( var i = 0 ; i < radioes.length ; i = i + 1){
				if(radioes[i].checked){
					return radioes[i].value;
				}
			}
		}
	}
	return "";
}

function addZero( orgValue , maxLength ){
	while( orgValue.length < maxLength){
		orgValue = "0"+orgValue;
	}
	return orgValue;
}

function disZero( orgValue ){
	while( orgValue.substr(0,1) === "0" ){
		orgValue = orgValue.substr(1,orgValue.length-1);
	}
	return orgValue;
}


function isNumeric(node){ return isBasicType( node )&&(/^-?(0|[1-9]\d*|(?=\.))(\.\d+)?$/.test(node)); } 

function isBasicType( node ){	var type = typeof(node); return !!( type === 'string' || type ==='number' || type === 'boolean' ); }
<%--[20221012]避免造成原功能出錯，另寫這個方法來檢核僅能輸入數字--%>
function isNumeric2(node){ return isBasicType( node )&&(/^[0-9]*$/g.test(node)); } 

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0"
	marginheight="0" onLoad="initApp();" onResize="fix();"
	onScroll="fix();">
	
                               <form name="form1" id="form1">
                           	
                               <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="areaA">
                                   <tr>
                                    <td class="tbYellow" width="5%" align="center"><input type="radio" value="BORROW_ID" name="QUERY_TYPE" checked /></td>
                                       <td class="tbYellow" width="10%" align="left">借款人ID</td>
                                       <td class="tbYellow2" >
                                           <input id="BORROW_ID" name="BORROW_ID" type="text" maxlength="10" size="12" class="text2 validateBORROW_ID"  />
                                       </td>
                                       <td class="tbYellow2" width="7%"  rowspan="3" align="left"><input type="button" name="btn_query" id="btn_query" class="button" value="查詢" /></td>
                                   </tr>
                                   <tr>
                                    <td class="tbYellow" width="5%" align="center"><input type="radio" value="LOAN_ID" name="QUERY_TYPE" /></td>
                                       <td class="tbYellow" width="10%" align="left">貸款帳號</td>
                                       <td class="tbYellow2" >
                                           <input id="LOAN_ID" name="LOAN_ID" type="text" maxlength="10" size="12" class="text2 validateLOAN_ID" />
                                       </td>
                                   </tr>
                                   <tr>
                                    <td class="tbYellow" width="5%" align="center"><input type="radio" value="APPLY_ID" name="QUERY_TYPE" /></td>
                                       <td class="tbYellow" width="10%" align="left">受理編號</td>
                                       <td class="tbYellow2" >
                                           <input id="APPLY_ID" name="APPLY_ID" type="text" maxlength="11" size="12" class="text2 validateAPPLY_ID" />
                                       </td>
                                   </tr>
                                   <tr>
                                    <td align="center" colspan="4">
                                       	<input type="button" name="btn_insert" id="btn_insert" class="button" value="新增" />
                                           <input type="button" name="btn_update" id="btn_update" class="button" value="修改" />
                                           <input type="button" name="btn_delete" id="btn_delete" class="button" value="刪除" />
                                       </td>
                                   </tr>                               
                               </table>
                            	</form>    

                            <table id='grid'></table>	
                            

<div id='dtlDiv'
	style="position: absolute; top: 0px; left: -2px; visibility: hidden"
	align='center'><iframe src='' name='dtlFrame' width='99%'
	height='500' id='dtlFrame'></iframe></div>

</body>
</html>
