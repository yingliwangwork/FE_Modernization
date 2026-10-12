<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSD10100.jsp
作者：i9300606
功能：DSD1_0100 約定繳款明細查詢
完成：
更新：

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
<!-- //============匯出調整區塊================== -->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<!-- //============匯出調整區塊================== -->

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

<!-- Define UI Class Start----------------------------------------------------- -->
function UI(){

	//--------------------------------------------------------------------------  
	//UI() private variable
	//-------------------------------------------------------------------------- 
	
	//------------------------------------------------------------------------
	//查詢
	function query(){
	
		var msg = checkDateInput($('DUE_DATE_STR'),$('DUE_DATE_END'),'\n 約定繳款日(起日)、約定繳款日(迄日)皆為必需輸入欄位');
		if(msg!=""){
			alert(msg);
			return;
		}
		msg += checkDateArea($('DUE_DATE_STR'),$('DUE_DATE_END'),'\n 約定繳款日(起)需小於等於約定繳款日(迄)', 1);
		if(msg!=""){
			alert(msg);
			return;
		}
		msg += checkDateArea($('DUE_DATE_STR'),$('DUE_DATE_END'),'\n 約定繳款日(起日)至約定繳款日(迄日)區間不可超過3個月)', 2);
		if(msg!=""){
			alert(msg);
			return;
		}
	
		ajaxPost('query', Form.serialize("form1"), successAction, errorAction);
	}
	//------------------------------------------------------------------------
	//查詢服務中心
	function getSrvDeptList(){
		ajaxPost('getSrvDeptList', Form.serialize("form1"), successAction1, errorAction);
	}
	
	//--------------------------------------------------------------------------	
	//AJAX SuccessAction
	function successAction1(resp) {
		if(CSRUtil.isSuccess(resp)){
			SRV_DEPT_List = resp.SRV_DEPT_List;
			selection.clean("SRV_DEPT");
			selection.createAll("SRV_DEPT", SRV_DEPT_List, "全部", "", "");
			auxiliary.createKey_Value(SRV_DEPT_List, "SRV_DEPT");		
		}
	}

	function successAction(resp) {
		if(CSRUtil.isSuccess(resp)){
			grid.load( (resp.rtnList) ? resp.rtnList : []);					
		}
	}
		
	function errorAction() {
		grid.load([]);					
	}
	
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
	
	function checkDateInput(strAObj,endAObj,msg){
		var strAObjIsInput = strAObj.value!='';
		var endAObjIsInput = endAObj.value!='';
		var msg1 = "";
		if(strAObjIsInput && !isROCdate(strAObj.value)){
			msg1 += "\n 約定繳款日起日格式有誤";
		}
		if(endAObjIsInput && !isROCdate(endAObj.value)){
			msg1 += "\n 約定繳款日訖日格式有誤";
		}
		if(msg1!=""){
			return msg1;
		}
		if(
			(strAObjIsInput && endAObjIsInput)
		){
			return "";
		};
		return msg;
	}
	
	//--------------------------------------------------------------------------
	//以下為UI() public method,放在 return 中
	//--------------------------------------------------------------------------  
	return{
	
		//init Function for 初始整個UI Class
		init:function(){
			
			displayMessage();
			
			//產生 Grid 物件
			grid = new TableUI(	{
            table: $("grid"), pageSize: 10, allSortable:true,
            <%-- [20240322]難字 --%>
            afterLoad: function() {
            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
            },
            pageChange: function() {
            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
            },
			column:[
            {key:"LOAN_ID",header: "貸款帳號"},
			{key:"REFER_ID",header: "原貸帳號" },
			{key:"BORROW_NAME",header: "借款人", attrs:{ style:"font-family:'EUDC'" } },<%-- [20240322]難字 --%>
			{key:"REMAIN_AMT",header: "本金餘額", attrs: {align:"right"} ,sortRule:'number', 
				render: function( record, value ){
              		return CSRUtil.$fmt(value, "#,##0.##");
            	}
            },
			{key:"NEXT_PAYDT",header: "下次應繳日" , 
				render: function( record, value ){
              		return Date.toROC(value);
            	}
            },
			{key:"MAX_DUE_DATE",header: "約定繳款日" , 
				render: function( record, value ){
              		return Date.toROC(value);
            	}
            },
			{key:"INPUT_DATE" ,header: "催收日期" , 
				render: function( record, value ){
              		return Date.toROC(value);
            	}
            },
			{key:"EMP_NAME" ,header: "催收人員", attrs:{ style:"font-family:'EUDC'" } },<%-- [20240322]難字 --%>
			{key:"DIV_NO_CENTER_NAME",header: "區域" },
			{key:"SRV_DEPT_NAME1",header: "服務中心一" },
			{key:"SRV_DEPT_NAME23",header: "服務中心二三" },
			{key:"PAID_TIMES",header: "已繳期數" }
			]
			});
			
			// end of grid
			
			//取得服務中心一下拉選單內容
	 		$('DIV_NO_CENTER').observe('change', function(event){
	 			getSrvDeptList();
	 		});
			
			//查詢
	 		$('btn_QUERY').observe('click', function(event){
	 			query();
	 		});	
	 		
			<c:if test="${not empty DIV_NO_CENTER_List}">
				DIV_NO_CENTER_List = ${DIV_NO_CENTER_List};
				selection.createAll("DIV_NO_CENTER", DIV_NO_CENTER_List, "全部", "", "");
				auxiliary.createKey_Value(DIV_NO_CENTER_List, "DIV_NO_CENTER");
				selection.createAll("SRV_DEPT", [], "全部", "", "");
				auxiliary.createKey_Value([], "SRV_DEPT");
			</c:if>
			
			//============匯出調整區塊==================
			//匯出XLS
			$('btn_EXCEL').observe('click', function(event){	

				var msg = checkDateInput($('DUE_DATE_STR'),$('DUE_DATE_END'),'\n 約定繳款日(起日)、約定繳款日(迄日)皆為必需輸入欄位');
				if(msg!=""){
					alert(msg);
					return;
				}
				msg += checkDateArea($('DUE_DATE_STR'),$('DUE_DATE_END'),'\n 約定繳款日(起)需小於等於約定繳款日(迄)', 1);
				if(msg!=""){
					alert(msg);
					return;
				}
				msg += checkDateArea($('DUE_DATE_STR'),$('DUE_DATE_END'),'\n 約定繳款日(起日)至約定繳款日(迄日)區間不可超過3個月)', 2);
				if(msg!=""){
					alert(msg);
					return;
				}

				$('gridJSON').value = grid.getXlsSettingJSON('約定繳款明細資料');
				
				RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSD1_0100/exportCsv', Form.serialize("form1"));
				
			});
			//============匯出調整區塊==================
	 		
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
		"<%=dispatcher%>/DSD1_0100/" + actionName,
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
				<div align="right">畫面編號：DSD10100</div>
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
							<td class="tbBox2" colspan="5">約定繳款明細查詢</td>							
						</tr>
						<tr bgcolor=#FFFFFF>
						  <td>
							<form name="form1" id="form1" method="post" action="">
								<!-- //============匯出調整區塊6================== -->
								<input type="hidden" name="gridJSON" id="gridJSON" value="">
								<!-- //============匯出調整區塊6================== -->
								
								<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
								<tr>
									<td class="tbYellow" width="10%" nowrap>約定繳款日</td>										
						            <td class="tbYellow2" width="30%" nowrap>
							           	<input name="DUE_DATE_STR" id="DUE_DATE_STR" datatype="ROCDate" type="text" class="textBox2" size="12" maxlength="7" value="" >
							           	<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('DUE_DATE_STR'))"> ~ 
							            <input name="DUE_DATE_END" id="DUE_DATE_END" datatype="ROCDate" type="text" class="textBox2" size="12" maxlength="7" value="" >
							            <img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('DUE_DATE_END'))"> 
							        </td>
									<td class="tbYellow" width="10%" nowrap>區域</td>										
						            <td class="tbYellow2" width="15%" nowrap>
										<select id="DIV_NO_CENTER" name="DIV_NO_CENTER" class="textBox2">
										</select>
							        </td>
									<td class="tbYellow" width="10%" nowrap>服務中心一</td>										
						            <td class="tbYellow2" width="15%" nowrap>
										<select id="SRV_DEPT" name="SRV_DEPT" class="textBox2">
										</select>
							        </td>
									<td class="tbYellow2" rowspan='2' width="10%" align="center" nowrap>
									    <input name="btn_QUERY"	id="btn_QUERY" type="button" value="查詢" class="button">

   									</td>
								</tr>								
							   </table>
							   
							   <table class="grid" id="grid" width=100% border="1" cellpadding="0" cellspacing="0" class="tbBox2" bordercolorlight="#C7E49C" bordercolordark="#C7E49C" >
							   </table>
							   	
							   <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table2">
							   	  <tr  bgcolor=#FFFFFF><td colspan="6" align="center">
							   	  		<input name="btn_EXCEL"	id="btn_EXCEL" type="button" value="下載明細" class="button">
							   	  </td></tr>
							   </table>	
							   
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