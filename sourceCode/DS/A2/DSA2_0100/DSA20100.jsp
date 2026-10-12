<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
    Date        Version Description Author
    2011-08-03  1.0     Created     陳正毅
    
    程式功能概要說明：
    程式功能　案件派件查詢
    程式名稱　DSA2_0100.java
    作業方式　ONLINE
    概要說明　(1) 查詢 ─ 使用者輸入查詢條件後，查詢案件派件資料。
    按鈕授權　FUNC_ID = DSA20100
	
	@author 楊宗翰
	@since 2011-08-24
	
[20240731] 修改件 難字調整	
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<%--[20240731]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

// 代碼中文對應
var CRED_DEPT_List = {};	// 承辦科別
var DATE_TYPE_List = {};	// 查詢日期種類
var OPER_CODE_List = {};	// 運算選單
var CRED_ID_Map = {};	// 承辦人員

var column1;
var column2;
var grid;
var old_DateType;
var validator;

var pattern_time = /(\d+)-(\d+)-(\d\d) (\d+):(\d+)/;	// 日期格式
var pattern_date = /(\d+)-(\d+)-(\d\d)/;	// 日期格式(date)

function initApp(){
	validator = new Validator();
	
	PageUI.createPageWithAllBodySubElement("DSA20100" , "核貸作業" , "案件派件查詢", 1);
	
	new UI().init();
	
	PageUI.resize(true);
}

function UI(){
	return {
		init:function() {
			displayMessage();

			// DATE_TYPE日期種類<> “3”(初核受理日期)
			<%--[20240731] 難字調整 --%>
			column1 = [
				{header:'受理編號', key:'APPLY_ID'},
				{header:'借款人', key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"}},
				{header:'受理進度', key:'PROCESS_NAME'},
				{header:'貸款類別', key:'LOAN_TYPE_NAME'},
				{header:'送件日期', key:'SEND_DATE',
					render:function(record, value){
						var result = (!value) ? '':value.match(pattern_date);
						return (result) ? auxiliary.Y2KDate2ROCDate(result[0], "/") : '';
					}
				},
				{header:'包裹日期', key:'PACK_DATE',
					render:function(record, value){
						var result = (!value) ? '':value.match(pattern_date);
						return (result) ? auxiliary.Y2KDate2ROCDate(result[0], "/") : '<font color="red">包裹未確認</font>';
					}
				},
				{header:'徵信人員', key:'CRED_NAME', attrs:{style:"font-family:'EUDC'"}},
				{header:'貸款種類', key:'LOAN_KIND_NM1',
					render:function(record, value){
						var LOAN_KIND_NM1 = record.LOAN_KIND_NM1;
						var INSU_PRANK_NM1 = record.INSU_PRANK_NM1;
						var LOAN_KIND_NM2 = record.LOAN_KIND_NM2;
						var INSU_PRANK_NM2 = record.INSU_PRANK_NM2;
						
						var show = "";
						if(LOAN_KIND_NM1){
							show = show + LOAN_KIND_NM1;
						}
						if(INSU_PRANK_NM1){
							show = show + '<font color="red">' + INSU_PRANK_NM1 + '</font>';
						}
						
						if(show){
							if(LOAN_KIND_NM2){
								show = show + '<br/>' + LOAN_KIND_NM2;
								
								if(INSU_PRANK_NM2){
									show = show + '<font color="red">' + INSU_PRANK_NM2 + '</font>';
								}
							}else if(INSU_PRANK_NM2){
								show = show + '<br/>' +'<font color="red">' + INSU_PRANK_NM2 + '</font>';
							}
						}else{
							if(LOAN_KIND_NM2){
								show = show + LOAN_KIND_NM2;
							}
							if(INSU_PRANK_NM2){
								show = show + '<font color="red">' + INSU_PRANK_NM2 + '</font>';
							}
						}
						
						return show;
					}
				},
				{header:'送件單位', key:'DIV_NAME'},
				{header:'經手人姓名', key:'AGENT_NAME', attrs:{style:"font-family:'EUDC'"}},
				{header:'影像件', key:'IMAGE_TYPE'}
			];
			
			// DATE_TYPE日期種類 = “3”(初核受理日期)
			column2 = [
				{header:'受理編號', key:'APPLY_ID'},
				{header:'借款人', key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"}},
				{header:'受理進度', key:'PROCESS_NAME'},
				{header:'貸款類別', key:'LOAN_TYPE_NAME'},
				{header:'初核受理日期', key:'EASY_APPLY_DATE',
					render:function(record, value){
						var result = (!value) ? '':value.match(pattern_date);
						return (result) ? auxiliary.Y2KDate2ROCDate(result[0], "/") : '';
					}
				},
				{header:'徵信人員', key:'CRED_NAME', attrs:{style:"font-family:'EUDC'"}},
				{header:'送件單位', key:'DIV_NAME'},
				{header:'經手人姓名', key:'AGENT_NAME', attrs:{style:"font-family:'EUDC'"}},
				{header:'影像件', key:'IMAGE_TYPE'}
			];

			// 查詢
			$("btn_query").observe('click',function(event){
				buttons.doQuery();
			});
			
			// 當承辦科別改變時
			$("CRED_DEPT").observe('change',function(event){
				var CRED_DEPT = $('CRED_DEPT').value;
				selection.getCRED_ID_Map(CRED_DEPT);
			});
			
			// 輸入欄位去空白
			$w('QRY_DT APPLY_ID').each( 
				function(key){
					$(key).observe('blur', function(event){
						$(key).value = ($(key).value != null) ? $(key).value.trim() : "";
					});
				}
			);

			/*
			 * 載入下拉選單
			 */
			// 承辦科別
			<c:if test="${not empty CRED_DEPT_List}">
				CRED_DEPT_List = ${CRED_DEPT_List};
				selection.createAll("CRED_DEPT", CRED_DEPT_List, "", "", "");
				
				var CRED_DEPT = $('CRED_DEPT').value;
				selection.getCRED_ID_Map(CRED_DEPT);
			</c:if>

			// 查詢日期種類
			<c:if test="${not empty DATE_TYPE_List}">
				DATE_TYPE_List = ${DATE_TYPE_List};
				selection.createAll("DATE_TYPE", DATE_TYPE_List, "", "1", "");
			</c:if>

			// 運算選單
			<c:if test="${not empty OPER_CODE_List}">
				OPER_CODE_List = ${OPER_CODE_List};
				selection.createAll("OPER_CODE", OPER_CODE_List, "", "<=", "");
			</c:if>
			
			// 日期(預設為今天)
			var QRY_DT = '${QRY_DT}';
			var result = (!QRY_DT) ? '' : QRY_DT.match(pattern_date);
			QRY_DT = (result) ? auxiliary.Y2KDate2ROCDate(result[0], "") : '';
			$('QRY_DT').value = QRY_DT;
			
			var new_DateType = $('DATE_TYPE').value;
			layout.changeTableUI(new_DateType);
		}
	};
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){
		if(!validates.checkInput()){
			return;
		}
		
		columnToUpperCase('APPLY_ID');
		
		// 依照日期下拉選單來決定tableUI的欄位
		var new_DateType = $('DATE_TYPE').value;
		layout.changeTableUI(new_DateType);
		
		var queryData = {
			CRED_DEPT: $('CRED_DEPT').value,
			CRED_ID: $('CRED_ID').value,
			DATE_TYPE: $('DATE_TYPE').value,
			OPER_CODE: $('OPER_CODE').value,
			QRY_DT: auxiliary.ROCDate2Y2KDate($('QRY_DT').value),
			APPLY_ID: $('APPLY_ID').value
		};
		var actionName = "query"; 
		var params = {"queryData":Object.toJSON(queryData)};
		ajaxPost(actionName, params);
	}
};

//--------------------------------------------------------------------------
// 檢核
//--------------------------------------------------------------------------
var validates = {
	// 畫面欄位
	checkInput:function(){
		$$('#form1 input[type="text"]').each( function(text){ text.style.backgroundColor = ''; } );	// reset input color
		validator.clear();

		// 承辦科別
		validator.define("CRED_DEPT", "", "承辦科別不可為空", "string", "1");
			
		// 日期
		if($('QRY_DT').value == ""){
			validator.define("QRY_DT", "", "日期不可為空", validates.returnFalse);
		} else if(!validates.checkDate('QRY_DT', "false", "ROC")){
			validator.define("QRY_DT", "", "日期格式錯誤", validates.returnFalse);
		}
		
		return validator.validate();
	},
	// 檢查輸入日期是否合法
	checkDate:function(date, checkEmpty, mod){
		var inputDate;
		if($(date)){
			inputDate = $(date).value;
		}else{
			inputDate = date;
		}
	
		if(checkEmpty != "true" && inputDate == ""){
			return true;
		}else{
			if(mod == "ROC"){
				return isROCdate(inputDate);
			}else{
				return isDate(inputDate);
			}
		}
	},
	// 檢核傳進來的值是否為正確的數字格式？是，則將該欄位依照pattern(自訂或預設)格式化；否，則將該欄位清空
	checkedNum:function(key){
		var value = $(key).getValue().trim();

		if(value != ""){
			var isNum = value * 0;

			if(isNum || isNum == 0){
				var pattern = ($(key).pattern) ? $(key).pattern : pattern_money2;
				$(key).value = moneyControl.format(value, pattern);
				return true;
			}
		}
		$(key).value = "";

		return false;
	},
	returnFalse:function(){
		return false;
	}
};

//--------------------------------------------------------------------------
// 下拉選單操作
//--------------------------------------------------------------------------
var selection = {
	// 取得承辦人員下拉選單
	getCRED_ID_Map:function(CRED_DEPT){
		selection.clean("CRED_ID");
		
		var CRED_ID_List = CRED_ID_Map[CRED_DEPT];
		if(CRED_ID_List){
			selection.createAll("CRED_ID", CRED_ID_List, "全部", "", "", "ID", "NAME"); 
		}else{
			var actionName = "getCRED_ID_Map"; 
			var params = {"CRED_DEPT":CRED_DEPT};
			var successAction = function(resp){
				var CRED_ID_List = resp.CRED_ID_List;
				CRED_ID_Map[CRED_DEPT] = CRED_ID_List;
				
				selection.createAll("CRED_ID", CRED_ID_List, "全部", "", "", "ID", "NAME"); 
			};
			var errorAction = function(resp){
				var CRED_ID_List = null;
				
				selection.createAll("CRED_ID", CRED_ID_List, "全部", "", "", "ID", "NAME"); 
			};
			ajaxPost(actionName, params, successAction, errorAction);
		}
	},
	// 依照傳入資料與id，產生下拉選單
	createAll:function(tagID, optionList, initialText, choiceValue, isCode_CodeNM, key, value){
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
	createAll4Map:function(tagID, optionMap, initialText, choiceValue, isCode_CodeNM){
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
// 畫面操作
//--------------------------------------------------------------------------
var layout = {
	changeTableUI:function(new_DateType){
		if(!old_DateType){
			if(new_DateType == "3"){
				grid = new TableUI({
					table: $('grid'), pageSize: 10, allSortable: true,
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:column2
				});
			}else{
				grid = new TableUI({
					table: $('grid'), pageSize: 10, allSortable: true,
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:column1
				});
			}
		}else if(old_DateType == "3"){
			if(new_DateType != "3"){
				grid = new TableUI({
					table: $('grid'), pageSize: 10, allSortable: true,
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:column1
				});
			}
		}else if(new_DateType == "3"){
			grid = new TableUI({
				table: $('grid'), pageSize: 10, allSortable: true,
				<%--[20240731] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:column2
			});
		}else {
			grid = new TableUI({
				table: $('grid'), pageSize: 10, allSortable: true,
				<%--[20240731] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:column1
			});
		}
		
		old_DateType = new_DateType;
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
	},
	// 民國年轉西元年
	ROCDate2Y2KDate:function(date){
		var rocDate;
		
		if(date && $(date)){
			rocDate = $(date).value;
		}else{
			rocDate = date;
		}
		
		if(rocDate){
			var dateLength = rocDate.length;

			if(dateLength == 5 && isROCdate("0" + rocDate)){
				return (parseInt(rocDate.substring(0, dateLength-4), 10)+1911) + "-" + rocDate.substring(dateLength-4, dateLength-2) + "-" + rocDate.substring(dateLength-2);
			}else if(dateLength > 5 && isROCdate(rocDate)){
				return (parseInt(rocDate.substring(0, dateLength-4), 10)+1911) + "-" + rocDate.substring(dateLength-4, dateLength-2) + "-" + rocDate.substring(dateLength-2);
			}
			
			if($(date)){
				alert("輸入的日期：" + rocDate + "，不符合民國年格式(例：1000101)");
				$(date).value = "";
			}
		}
		
		return "";
	},
	// 西元年轉民國年 
	Y2KDate2ROCDate:function(date, symbol){
		var y2kDate;
		
		if(date && $(date)){
			y2kDate = $(date).value;
		}else{
			y2kDate = date;
		}
		
		if(!symbol){
			symbol = "";
		}

		if(y2kDate){
			var splitTool = y2kDate.split(" ");
			y2kDate = (splitTool[0]) ? splitTool[0] : "";
			if(isDate(y2kDate)){
				var dates = y2kDate.split("-");
				y2kDate = (parseInt(dates[0], 10)-1911) + symbol + dates[1] + symbol + dates[2];
				
				if(splitTool.length > 1){
					y2kDate = y2kDate + " " + splitTool[1];
				}
				return y2kDate;
			}else if($(date)){
				alert("輸入的日期：" + y2kDate + "，不符合西元年格式(例：2011-01-01)");
				$(date).value = "";
			}
		}
		
		return "";
	}
};

//--------------------------------------------------------------------------
// 共用－Ajax
//--------------------------------------------------------------------------
function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSA2_0100/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){
			if(CSRUtil.isSuccess(resp)){
				if(successAction){
	 				successAction(resp);
	 			}else{
			  		grid.load(resp.rtnList);
			  	}
			}else if(actionName == "query"){
			  	grid.load([]);
			}else if(errorAction){
				errorAction(resp);
			}
        }}
	);
}

<%--
	轉大寫
--%>
function columnToUpperCase(columnName) {
	$(columnName).value = $(columnName).value.toUpperCase();
}

//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">


<form name="form1" id="form1" method="post" action="">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="12%">
				承辦科別
			</td>
			<td class="tbYellow2" width="35%">
				<select id="CRED_DEPT" name="CRED_DEPT" class="textBox2">
				</select>
			</td>
			<td class="tbYellow" width="15%">
				承辦人員
			</td>
			<td class="tbYellow2" width="25%">
				<%--[20240731]難字調整--%>
				<select id="CRED_ID" name="CRED_ID" class="textBox2" alt="ch">
				</select>
			</td>
			<td class="tbYellow2" rowspan="2" align="center" width="13%">
				<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				查詢條件
			</td>
			<td class="tbYellow2">
				<select id="DATE_TYPE" name="DATE_TYPE" class="textBox2">
				</select>
				<select id="OPER_CODE" name="OPER_CODE" class="textBox2">
				</select>
				<input id="QRY_DT" name="QRY_DT" type="text" class="textBox2" size="10" maxlength="7" datatype="ROCDate" value="">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('QRY_DT'))">
			</td>
			<td class="tbYellow">
				受理單位代號
			</td>
			<td class="tbYellow2" >
				<input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2" size="7" maxlength="5" value="">
			</td>
		</tr>
</table>

<table id="grid" class="grid" width="100%"></table>
</form>

</body>
</html>