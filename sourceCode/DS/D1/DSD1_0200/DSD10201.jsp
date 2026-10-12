<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSD10201.jsp
作者：i9300615
功能：DSD1_0201 逾四日未繳件查詢作業
完成：
更新：

[20210107] 修改件                                  
         新增「收費代號」欄位。                            
         將原本欄位「聯絡電話(日)」，改成「收費代號」                
         列印部分一併調整。

[20210922] 修改程式 楊青峰
1. 新增「餘額放款率」欄位

[20240322]難字
-->


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>		<%-- 匯出PDF用--%>

<%-- [20240322]難字 --%>
<style type="text/css">
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type="text/javascript" type="text/JavaScript">

//Event.observe(window, 'load', initApp);

var grid;

function buttonAuth(){
	var authButtons = {
			B0174:'btn_print2'
	};
	<dz:grantButtons FUNC_ID="DSD10201" />
}

<!-- Define UI Class Start----------------------------------------------------- -->
function UI(){

	//--------------------------------------------------------------------------  
	//UI() private variable
	//-------------------------------------------------------------------------- 
	var valid1;
	
	var PRINT_TYPE = '${PRINT_TYPE}';//查詢方式
	var STAT_DATE_Y2K = '${STAT_DATE_Y2K}';	
	var LINK_FROM = '${LINK_FROM}';
	
	var subWindow = null;
	
	var lastQueryMap = {
		STAT_DATE : '${STAT_DATE}',
		DIV_NO : '${DIV_NO}',
		CHECK_TYPE : '${CHECK_TYPE}'	
	
	};
	
	var today_dd = parseInt(getY2KToday().substr(8,10));
	//------------------------------------------------------------------------
	
	//列印
	function print(){
	
		var currentMap = {
			STAT_DATE : $('STAT_DATE').value ,
			DIV_NO : $('DIV_NO').value , 
			CHECK_TYPE : $('CHECK_TYPE').value 			
		}
		
		if( PRINT_TYPE == '4'){
			currentMap.DEPT_ID = $F('DEPT_ID');	
		}else if (PRINT_TYPE == '3'){
			currentMap.TIMES = $('TIMES').value 
		}
		
		for(key in currentMap){
			if(currentMap[key] != lastQueryMap[key]){
				alert('查詢條件與列印查詢條件不同，請重新查詢再列印');
				return;
			}		
		}
	  
		ajaxPost('print', { reqMap : Object.toJSON(currentMap) , PRINT_TYPE : PRINT_TYPE , DIV_NM : '${DIV_NM}'},
			function(resp){
				
				RPTUtil.executePrintByResponse(resp, true);			
			}		
		);
	}
	
	//列印催收函
	function print2(){
		
		var checkedList = grid.getCheckedRecord(['LOAN_ID']);
		
		if(checkedList.length === 0){
			alert('請勾選資料');
			return;
		}
		
		//檢核勾選資料筆數是否大於100
		if(checkedList.length > 100){
			alert('為避免檔案產生時間過長，只列印前100筆催收紀錄的催收函，若欲列印後100筆之資料，請重新勾選後再列印。');
			checkedList = checkedList.slice(0, 100);
			/*if(confirm('為避免檔案產生時間過長，只列印前100筆催收紀錄的催收函，若欲列印後100筆之資料，請重新勾選後再列印。')){
				
			} else{
				return;
			}*/
		}
		
		ajaxPost('print2', { reqList : Object.toJSON(checkedList) },
			function(resp){
				RPTUtil.executePrintByResponse(resp, true);	
				
				if(PRINT_TYPE == '1'){
					queryShort();
				} else if(PRINT_TYPE == '3'){
					queryTimes();
				} else if(PRINT_TYPE == '4'){
					query();
				} else{
					ajaxPost('queryPrompt', {
						STAT_DATE: '${STAT_DATE_Y2K}',
						DIV_NO: '${DIV_NO}',
						CHECK_TYPE: '${CHECK_TYPE}'
					}, successAction, errorAction);					
				}					
			}		
		);
	}
	
	//查詢
	function query(){	
	
		$('DEPT_ID').addClassName('required');
	
		valid1.reset();
		if( !valid1.validate() ) {return;}
		UpperCase('DEPT_ID');
		
		lastQueryMap = {
			STAT_DATE : $('STAT_DATE').value ,
			DIV_NO : $('DIV_NO').value , 
			CHECK_TYPE : $('CHECK_TYPE').value ,
			DEPT_ID : $('DEPT_ID').value 
		}
		
		PRINT_TYPE = '4';
		
		ajaxPost('query', Form.serialize("form1"), successAction, errorAction);
		
		$('DEPT_ID').removeClassName('required');
	}

	function queryShort(){
		
		lastQueryMap = {
			STAT_DATE : $('STAT_DATE').value ,
			DIV_NO : $('DIV_NO').value , 
			CHECK_TYPE : $('CHECK_TYPE').value 			
		}
		
		PRINT_TYPE = '1';
		
		ajaxPost('queryShort', Form.serialize("form1"), successAction, errorAction);
	}
	
	
	function queryTimes(){
		$('TIMES').addClassName('required');
		$('TIMES').addClassName('validate-digits');
			
		valid1.reset();
		if( !valid1.validate() ) {return;}
		
		lastQueryMap = {
			STAT_DATE : $('STAT_DATE').value ,
			DIV_NO : $('DIV_NO').value , 
			CHECK_TYPE : $('CHECK_TYPE').value 	,
			TIMES : $('TIMES').value 
		}
		
		PRINT_TYPE = '3';
		
		ajaxPost('queryTimes', Form.serialize("form1"), successAction, errorAction);
		
		$('TIMES').removeClassName('required');
		$('TIMES').removeClassName('validate-digits');
	}
	

	
	//--------------------------------------------------------------------------	
	function successAction(resp) {
		if(CSRUtil.isSuccess(resp)){
			grid.load( (resp.rtnList) ? resp.rtnList : []);		
			$('MEMO').innerHtml = resp.MEMO;			
		}
	}
		
	function errorAction() {
		grid.load([]);					
	}
	
	var UpperCase=function(ids){
		$w(ids).each(
		function(id){
			$(id).value = $(id).value.toUpperCase();
		});
	};
	
	/* -----自訂的全域function-----*/
	
	function checkDateArea(strObj,endObj,msg,type){
		var strObjIsInput = strObj.value!='';
		var endObjIsInput = endObj.value!='';
		if( (strObjIsInput && endObjIsInput)){
			if(1==type){
				if( eval(endObj.value-strObj.value)>=0){
					return "";
				}
			}else{
				minday = toROC(addDate(toY2K(endObj.value),0,-3,0));
				if( eval(strObj.value-minday)>=0){
					return "";
				}				
			}
			return msg;
		}else{
			return "";
		}
	}
	
	function checkDateInput(strAObj,msg){
		var strAObjIsInput = strAObj.value!='';
		
		var msg1 = "";
		if(strAObjIsInput && !isROCdate(strAObj.value)){
			msg1 += "\n 查詢日期格式有誤";
		}
		
		if(msg1!=""){
			return msg1;
		}
		if(
			(strAObjIsInput)
		){
			return "";
		};
		return msg;
	}
	
	var nextchecktype = "${nextchecktype}";
	
	//--------------------------------------------------------------------------
	//以下為UI() public method,放在 return 中
	//--------------------------------------------------------------------------  
	return{
	
		//init Function for 初始整個UI Class
		init:function(){
		
			if(LINK_FROM != 'DSD10200'){
				$('btn_back').hide();
			}
			
			displayMessage();
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false}); 
		
			
			//產生 Grid 物件
			grid = new TableUI(	{
            table: $("grid"), pageSize: 30, allSortable:true, split: ['MONTH_URGE_CNT'],
			autoCheckBox: { isSelectAll:true,
				genRule:function(record , value){				
					return record.hasPrint == 'N' && record.PAY_STATUS == '未繳';						
				} 
			},
			<%-- [20240322]難字 --%>
            afterLoad: function() {
            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
            },
            pageChange: function() {
            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
            },
			column:[
				{header:"催收次數", key:"TIMES" , attrs: {align:"right"} ,sortRule:'number', 
					render: function( record, value ){		
				     	var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	var TIMES=(value||value===0) ? CSRUtil.$fmt(value,"#,###") : 0;
				     	if (D020_SEND_CNT > 0){	
							    return TIMES;
						}else{
							    return "<span class = 'textRed'>" + TIMES + "</span>";	
						}
	            	}
            	},
            	{header:"繳款狀況", key:"PAY_STATUS"	,
            	    render: function( record, value ){		
				     	var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return value;
						}else{
							    return "<span class = 'textRed'>" + value + "</span>";	
						}
	            	}
            	},
				{header:"約定<br>繳款日<br>", key:'DUE_DATE', //2018-01-02申請書-催收明細查詢及逾四日未繳件明細查詢作業增加上次實繳日欄位 增加此欄位
					render : function (rec , val){
						return Date.toROC(val || '');									
					}
				},				
				{header:"帳號", key:"LOAN_ID", 
					render: function( record, value ){
					
	       				if(value){
							//超連結至 ”DSD01800” 催收明細作業畫面。
							var link = new Element( 'a' , { href : "#" } ).update(value);	
							link.observe( 'click', function (event){
								var url = "${dispatcher}/DSD1_1800/prompt?LOAN_ID="+value+"&INPUT_TYPE=1";		
                            	if(subWindow){
                            		subWindow.close();
                            	}							
								subWindow = window.open(url, "DSD1_1501", "top=250, left=250, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=900, height=600");
							});										
							return link; 															
						}
						return '';
	
	            	}
            	},
				{header:"姓名", key:"BORROW_NAME" , attrs:{ style:"font-family:'EUDC'" },<%-- [20240322]難字 --%>
				   render: function( record, value ){		
				     	var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return value;
						}else{
							    return "<span class = 'textRed'>" + value + "</span>";	
						}
	            	}
				},  
				{header:"本金餘額", key:"PRINCIPAL" , attrs: {align:"right"} ,sortRule:'number', 
					render: function( record, value ){				
	              		var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	var PRINCIPAL=(value||value===0) ? CSRUtil.$fmt(value,"#,###") : 0;
				     	if (D020_SEND_CNT > 0){	
							    return PRINCIPAL;
						}else{
							    return "<span class = 'textRed'>" + PRINCIPAL + "</span>";	
						}
	            	}
            	},
				{header:"繳款方式", key:"PAY_TYPE" ,
				    render: function( record, value ){		
				     	var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return value;
						}else{
							    return "<span class = 'textRed'>" + value + "</span>";	
						}
	            	}
				},
				//{header:"催收簡訊發送", key:"NEXT_PAYDATE" , //2018-01-02申請書-催收明細查詢及逾四日未繳件明細查詢作業增加上次實繳日欄位 拿掉此欄位
					//render : function(rec , val){
						//var int_dd = parseInt(val.substr(8,10));
						//if(val && int_dd <= 20 ){													
							//var link = new Element("a" , { href : "#" } ).update('催收簡訊發送');
							//link.observe( 'click', function (event){
							/* 	
								var LP_JSON = {
									action :'<%=dispatcher%>/DSD1_0410/prompt',
									LOAN_ID : rec.LOAN_ID,
									FUNC_ID : 'DSD10201',
									STAT_DATE : $('STAT_DATE').value , 
									DIV_NO : $('DIV_NO').value , 
									DIV_NM : $('DIV_NM').value , 
									CHECK_TYPE : $('CHECK_TYPE').value ,
									MOBILE : rec.MOBILE
								}
								CSRUtil.linkTo(LP_JSON , 'form1');	
								*/
								//var source = '<%=dispatcher%>/DSD1_0410/prompt'; 
										//popupWin.popup({
										//parameters : {  'LOAN_ID':rec.LOAN_ID,FUNC_ID : 'DSD10201',MOBILE : rec.MOBILE,INPUT_TYPE : '1',
										//TableInfo : grid.getTableInfo()},
										//src : source								
									//});	
							//});		
							//return link;														
						//}	
						//return '';
					//}
				//},
				{header:"已繳期數", key:"PAY_TERM" , attrs: {align:"right"} ,sortRule:'number', 
					render: function( record, value ){				
	              		var D020_SEND_CNT=record.D020_SEND_CNT;		
						var PAY_TERM=(value||value===0) ? CSRUtil.$fmt(value,"#,###") : 0;
				     	if (D020_SEND_CNT > 0){	
							    return PAY_TERM;
						}else{
							    return "<span class = 'textRed'>" + PAY_TERM + "</span>";	
						}
	            	}
            	},
				{header:"簡訊寄送狀態", key:"SEND_STATUS",
					render: function( record, value ){				
	              		var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return value;
						}else{
							    return "<span class = 'textRed'>" + value + "</span>";	
						}
	            	}
				},
				{header:"餘額放款率", key:'REMAIN_AMT_RATE'}, // [20210922]
				{header:"上次實繳日", key:"REAL_PAYDT",
					render: function( record, value ){				
	              		var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return Date.toROC(value);
						}else{
							    return "<span class = 'textRed'>" + Date.toROC(value) + "</span>";	
						}
	            	}
				},				
				{header:"下次應繳日", key:"NEXT_PAYDATE",
					render: function( record, value ){				
	              		var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return Date.toROC(value);
						}else{
							    return "<span class = 'textRed'>" + Date.toROC(value) + "</span>";	
						}
	            	}
				},
				<%--[20210107] 刪除[ 聯絡電話(日) ]，取代為[ 收費代號 ]--%>
				{header:"收費代號", key:"RECEIVE_ID" , 
				    render: function( record, value ){		
				     	var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return value;
						}else{
							    return "<span class = 'textRed'>" + value + "</span>";	
						}
	            	}
				},
				/*{header:"聯絡電話(日)", key:"DAY_TEL_AREA" , 
				render: function( record, value ){	
				     	var D020_SEND_CNT=record.D020_SEND_CNT;	
				     	var DAY_TEL_AREA = "";
						if (value!="") {
							DAY_TEL_AREA = '(' + value + ')';
						}
						if (record.DAY_TEL_NUM!="") {
							DAY_TEL_AREA = value + record.DAY_TEL_NUM;
						}
						if (record.DAY_TEL_EXT!="") {
							DAY_TEL_AREA = value + '#' + record.DAY_TEL_EXT;
						}
              			if (D020_SEND_CNT > 0){	
							    return DAY_TEL_AREA;
						}else{
							    return "<span class = 'textRed'>" + DAY_TEL_AREA + "</span>";	
						}
            		}
            	},*/
				{header:"聯絡電話(夜)", key:"NIGHT_TEL_AREA" , 
				render: function( record, value ){
					    var D020_SEND_CNT=record.D020_SEND_CNT;	
				     	var NIGHT_TEL_AREA = "";
						if (value!="") {
							NIGHT_TEL_AREA = '(' + value + ')';
						}
						if (record.NIGHT_TEL_NUM!="") {
							NIGHT_TEL_AREA = value + record.NIGHT_TEL_NUM;
						}
						if (record.NIGHT_TEL_EXT!="") {
							NIGHT_TEL_AREA = value + '#' + record.NIGHT_TEL_EXT;
						}
              			if (D020_SEND_CNT > 0){	
							    return NIGHT_TEL_AREA;
						}else{
							    return "<span class = 'textRed'>" + NIGHT_TEL_AREA + "</span>";	
						}
            		}
            	},
				{header:"行動電話", key:"MOBILE" ,
				    render: function( record, value ){		
				     	var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return value;
						}else{
							    return "<span class = 'textRed'>" + value + "</span>";	
						}
	            	}
				},
				/*{header:"經手人單位", key:"AGENT_DIV_NM" ,  //2018-01-02申請書-催收明細查詢及逾四日未繳件明細查詢作業增加上次實繳日欄位 拿掉此欄位
				    render: function( record, value ){		
				     	var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return value;
						}else{
							    return "<span class = 'textRed'>" + value + "</span>";	
						}
	            	}
				},*/
				{header:"經手人姓名", key:"AGENT_NAME" , attrs:{ style:"font-family:'EUDC'" },<%-- [20240322]難字 --%>
				    render: function( record, value ){		
				     	var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return value;
						}else{
							    return "<span class = 'textRed'>" + value + "</span>";	
						}
	            	}
				},
				{header:"經手人行動電話", key:"AGENT_MOBILE" ,
				    render: function( record, value ){		
				     	var D020_SEND_CNT=record.D020_SEND_CNT;		
				     	if (D020_SEND_CNT > 0){	
							    return value;
						}else{
							    return "<span class = 'textRed'>" + value + "</span>";	
						}
	            	}
				}								
			]
			});
			
			// end of grid
			buttonAuth();
			//列印
	 		$('btn_print').observe('click', function(event){
	 			print();
	 		});	
			
			//列印催收函
	 		$('btn_print2').observe('click', function(event){
	 			print2();
	 		});				
			
			//查詢
	 		$('btn_query').observe('click', function(event){
	 			query();
	 		});	
	 		
	 		//短逾件查詢
	 		$('btn_query_short').observe('click', function(event){
	 			queryShort();
	 		});	

	 		
	 		//催收次數篩選
	 		$('btn_query_times').observe('click', function(event){
	 			queryTimes();
	 		});	
	 		
	 		$('btn_back').observe('click', function(event){		 		 		 	
	 			CSRUtil.linkBack(CSRUtil.getLP_JSON().RQ_SENDER +'?STAT_DATE='+toY2K($F('STAT_DATE')));		
	 		});	
			
	 		$('STAT_DATE').value =  '${STAT_DATE}';			
			$('STAT_DATE_SPAN').update(Date.toROC(STAT_DATE_Y2K) || '');
			
			
			<c:if test="${not empty rtnList}">
				grid.load(${rtnList});			
			</c:if>
						
	 		
		}//end init()--
		
	}//end return--
	//-------------------------------------------------------------------------- 
	
}
<!--Define UI Class End-------------------------------------------------------->


<!--全域 函數 UI 與 畫面 公用 Start-------------------------------------------------->
//--------------------------------------------------------------------------  
//共用ajaxpost function
function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSD1_0201/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){
			if(CSRUtil.isSuccess(resp)){
				if(successAction){
	 				successAction(resp);
	 			}
			}else if(errorAction){
	 			errorAction();
	 		}
        }}
	);
}	
//--------------------------------------------------------------------------
// 下拉選單操作
//--------------------------------------------------------------------------
var selection = {
	// 依照傳入資料與id，產生下拉選單
	createAll:function(tagID, optionList, initialText, choiceValue, isCode_CodeNM){
		var target = $(tagID);
		if(target){
			if(initialText){
				selection.create(tagID, "", initialText, "");
			}
			if(optionList){
				for(var i = 0; i < optionList.length; i++){
					if(isCode_CodeNM){
						selection.create(tagID, optionList[i].CODE, optionList[i].CODE + " " + optionList[i].CODE_NM, choiceValue);
					}else{
						selection.create(tagID, optionList[i].CODE, optionList[i].CODE_NM, choiceValue);
					}
				}
			}
		}
	},
	// 產生單一下拉選單(如果下拉選單的value == 資料的Value，則將該option選擇起來)
	create:function(tagID, optionValue, optionText, choiceValue){
		$(tagID).options.add(new Option(optionText, optionValue));

		if(choiceValue && optionValue == choiceValue){
			$(tagID).options[$(tagID).length - 1].selected = true;
		}
	},
	// 清空下拉選單
	clean:function(tagID){
		$(tagID).options.length = 0;
	}
};
//--------------------------------------------------------------------------
// 輔助工具
//--------------------------------------------------------------------------
var auxiliary = {	
	// 將代碼與對照的中文組成陣列
	createKey_Value:function(optionList, type){
		// 佣金基礎
		if(type == "RBT_BAS"){
			for(var i = 0; i < optionList.length; i++){
				RBT_BAS_Map[optionList[i].CODE] = optionList[i].CODE_NM;
			}
		}
		// 型態
		else if(type == "TYPE"){
			for(var i = 0; i < optionList.length; i++){
				TYPE_Map[optionList[i].CODE] = optionList[i].CODE_NM;
			}
		}
		// 狀態
		else if(type == "STS"){
			for(var i = 0; i < optionList.length; i++){
				STS_Map[optionList[i].CODE] = optionList[i].CODE_NM;
			}
		}
	}
};
//-------------------------------------------------------------------------- 
<!--全域 函數 UI 與 畫面 公用 End---------------------------------------------------->
</script>

</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onload="new UI().init()" onResize='fix()' onScroll="fix()">

<!--此網頁自建使用的JavaScript 放下面 -->

<center><!-- Bolck_1_Start 表單的開頭 功能名稱 畫面編號--> 
<span id="bar1" style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible">
<table width="100%" height="30" border="0" cellpadding="0" 	cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
			<tr>
				<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
			<tr>
				<td width="20" height="24">
				<div align="center"><font size="-5">●</font></div>
				</td>
				<td><b>逾繳催收</b></td>
				<td>
				<div align="right">畫面編號：DSD10201</div>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</span> <!-- Bolck_1_ End--> <!-- Bolck_2_Start 空白區塊 版面跳行-->

<table width="100%" height="30" border="0" cellpadding="0" 	cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>

<!-- Bolck_2_End--> <!-- Bolck_3_Start 表單主功能區塊-->
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
		    <img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td valign="top">
				<table width=97% border=0 align=center cellpadding="5" cellspacing="1" bgcolor="#003366">
					<tbody>
						<tr>
							<td class="tbBox2" colspan="5">逾四日未繳件明細查詢作業</td>							
						</tr>
						<tr bgcolor=#FFFFFF>
						  <td>
							<form name="form1" id="form1" method="post" action="">
								
								<input type="hidden" name="STAT_DATE" id="STAT_DATE" value="">
								<input type="hidden" name="DIV_NO" id="DIV_NO" value="${DIV_NO}">
								<input type="hidden" name="CHECK_TYPE" id="CHECK_TYPE" value="${CHECK_TYPE}">
								<input type="hidden" name="DIV_NM" id="DIV_NM" value="${DIV_NM}">
								
								<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
								<tr>
									<td class="tbYellow" width="10%" nowrap>統計日期</td>										
						            <td class="tbYellow2" width="30%" nowrap>
							          	<span id = "STAT_DATE_SPAN">					           
							        </td>
							        <td class="tbYellow" width="10%" nowrap>單位</td>										
						            <td class="tbYellow2" width="30%" nowrap>
						            	${DIV_NM}									          						           
							        </td>
									
								</tr>	
								<tr>
									<td colspan='4' align="center" class="tbYellow2">
										<input id="btn_query_short" type="button" value="短逾件查詢" class="button">
										催收次數
										<input name="TIMES" id="TIMES" type="text" class="textBox2" size="12" maxlength="7" value="" >
										<input id="btn_query_times" type="button" value="催收次數篩選" class="button">
										收息單位
										<input name="DEPT_ID" id="DEPT_ID" type="text" class="textBox2" size="10" maxlength="7" value="" >
										
										<input id="btn_query" type="button" value="查詢" class="button">
										<input id="btn_print" type="button" value="列印" class="button">
										<input id="btn_print2" type="button" value="列印催收函" class="button">
										<input id="btn_back" type="button" value="上一頁" class="button">
									</td>
								</tr>							
							   </table>
							   
							   <table class="grid" id="grid" width=100% border="1" cellpadding="0" cellspacing="0" class="tbBox2" bordercolorlight="#C7E49C" bordercolordark="#C7E49C" >
							   </table>
							   	
							   	<div id="MEMO">
							   		${MEMO}
							   	</div>
							   
							</form>
							  
							  </td>
						</tr>
					</tbody>
				</table>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
<!-- Bolck_3_End--></center>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
</BODY>
</HTML>