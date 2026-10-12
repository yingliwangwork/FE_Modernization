<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
    Date        Version Description Author
    2011-08-08  1.0     Created     陳正毅
    
    程式功能概要說明：
    程式功能　案件派件及移轉處理
    程式名稱　DSA2_0101.java
    作業方式　ONLINE
    概要說明　(1) 查詢 ─ 使用者輸入查詢受理編號後，查詢案件資料。
　　　　　　　(2) 派件及移轉 ─ 將案件派件及移轉給選取的新徵信人員。
    按鈕授權　FUNC_ID = DSA20101

	@author 楊宗翰
	@since 2011-08-30
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
//var CRED_DEPT_List = {};	// 承辦科別
var CRED_ID_Map = {};	// 承辦人員
var TRANS_TYPE = "1";	// 移轉種類(1:徵信,2:鑑價)

//var old_B_CRED_DEPT;

var validator;

var pattern_time = /(\d+)-(\d+)-(\d\d) (\d+):(\d+)/;	// 日期格式
var pattern_date = /(\d+)-(\d+)-(\d\d)/;	// 日期格式(date)

function initApp(){
	validator = new Validator();
	PageUI.createPageWithAllBodySubElement("DSA20101" , "核貸作業" , "案件派件及移轉處理", 1);
	new UI().init();
		
	PageUI.resize(true);
}

function UI(){
	return {
		init:function() {
			displayMessage();

			// 查詢
			$("btn_query").observe('click',function(event){
				buttons.doQuery();
			});
			
			// 清除
			$("btn_clear").observe('click',function(event){
				buttons.doClear();
			});
			
			// 案件派件及移轉
			$("btn_update").observe('click',function(event){
				buttons.doUpdate();
			});
			
			// 收到包裹
			$("btn_update_packdate").observe('click',function(event){
				buttons.doUpdatePackDate();
			});
			
			// 當承辦科別改變時
			//$("B_CRED_DEPT").observe('change',function(event){
			//	var CRED_DEPT = $('B_CRED_DEPT').value;
			//	selection.getCRED_ID_Map(CRED_DEPT);
			//});
			
			// 輸入欄位去空白
			$w('A_APPLY_ID').each( 
				function(key){
					$(key).observe('blur', function(event){
						if(key == "A_APPLY_ID"){
							register.textNoSpace(key, "upper");
						}else{
							register.textNoSpace(key);
						}
					});
				}
			);
			// 輸入(去空白)
			register.textNoSpace('C_MEMO');
			/*
			 * 載入下拉選單
			 */
			// 承辦科別
			<c:if test="${not empty CRED_DEPT_List}">
				CRED_DEPT_List = ${CRED_DEPT_List};
				selection.createAll("B_CRED_DEPT", CRED_DEPT_List, "", "", "");
            
            
			</c:if>
			
			if ('${APPLY_ID}' != "") {
				$('A_APPLY_ID').value = '${APPLY_ID}';
			} else { 
				//保留參數管理-取得受理編號
				$('A_APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			}			
			if($('A_APPLY_ID').value){
				buttons.doQuery();
			}
		}
	};
}

//--------------------------------------------------------------------------
// 註冊事件
//--------------------------------------------------------------------------
var register = {
	// 欄位去空白
	textNoSpace:function (keys, type){
		$w(keys).each( 
			function(key){
				$(key).observe('blur', function(event){
					formatInput.text(key);
					
					if($(key).value){
						if(type == "upper"){
							$(key).value = $(key).value.toUpperCase();
						}else if(type == "lower"){
							$(key).value = $(key).value.toLowerCase();
						}
					}
				});
			}
		);
	},
	// 數字欄位欄位檢核
	isNumber:function (keys){
		$w(keys).each( 
			function(key){
				$(key).observe('blur', function(event){
					formatInput.number(key);
				});
			}
		);
	},
	// 金額欄位欄位檢核
	isMoney:function (keys){
		$w(keys).each( 
			function(key){
				$(key).observe('blur', function(event){
					formatInput.money(key, true, $(key).pattern);
				});
			}
		);
	}
};

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){
		if(!validates.checkInput("query")){
			return;
		}
		
		columnToUpperCase('A_APPLY_ID');

		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('A_APPLY_ID').value});
		
		layout.clearData("B");
		layout.clearData("C");
			
		var queryData = {
			APPLY_ID: $('A_APPLY_ID').value,
			TRANS_TYPE: TRANS_TYPE
		};
		var actionName = "query"; 
		var params = {"queryData":Object.toJSON(queryData)};
		var successAction = function(resp){
			var userInfo = resp.userInfo;
			layout.loadData(userInfo, "B");
			
			var detail = resp.rtnData;
			layout.loadData(detail, "C");
			//old_B_CRED_DEPT = $F('B_CRED_DEPT');
							
		};
		ajaxPost(actionName, params, successAction);
		
	},
	// 清除
	doClear:function(){
		$w('A_APPLY_ID').each( 
			function(key){
				if($(key).value){
					$(key).value = "";
				}else if($(key).innerHTML){
					$(key).innerHTML = "";
				}
			}
		);
	},
	// 案件派件及移轉
	doUpdate:function(){
		if(!validates.checkInput("update")){
			return;
		}
		
		//if(old_B_CRED_DEPT != $F('B_CRED_DEPT')){
		//	if(!confirm("所選擇的承辦科別與原先的不同，是否要繼續處理此案件?")) {
		//		return ;
		//	}
		//}
		//var DEPT_TYPE = $('B_DEPT_TYPE').value;
		//if (DEPT_TYPE == "1") {
		//	if(!confirm("確定要將案件移轉前台?")) {
		//		return ;
		//	}		
		//} else if (DEPT_TYPE == "2") {
		//	if(!confirm("確定要將案件移轉後台?")) {
		//		return ;
		//	}		
	    //}
		
		var newData = {
			APPLY_ID: $('C_APPLY_ID').innerHTML,
			OLD_DEPT: $('C_CRED_DEPT_NM').innerHTML,
			OLD_ID: $('C_CRED_ID').value,
			//NEW_DEPT: $('B_CRED_DEPT').value,
			CRED_DEPT: $('CRED_DEPT').innerHTML,
			CRED_DEPT_NM: $('C_CRED_DEPT_NM').innerHTML,
			NEW_ID: $('C_CRED_ID').value,
			TRANS_TYPE: TRANS_TYPE,
			INPUT_ID: $('B_INPUT_ID').innerHTML,
			INPUT_DATE: formatInput.ROCDate2Y2KDate($('B_INPUT_DATE').innerHTML),
			FORM_TYPE: $('C_FORM_TYPE').innerHTML,
			MEMO: $('C_MEMO').value
		};

		var actionName = "update"; 
		var params = {"newData":Object.toJSON(newData)};
		var successAction = function(resp){
			layout.clearData("B");
			layout.clearData("C");
			
			var userInfo = resp.userInfo;
			layout.loadData(userInfo, "B");
			
			var detail = resp.rtnData;
			layout.loadData(detail, "C");
		};
		ajaxPost(actionName, params, successAction);
	},
	
	// 收到包裹
	doUpdatePackDate:function(){
		if(!validates.checkInput("updatepackdate")){
			return;
		}
		
		var newData2 = {
			APPLY_ID: $('C_APPLY_ID').innerHTML,
			TRANS_TYPE: TRANS_TYPE
			
		};

		var actionName = "updatepackdate"; 
		var params = {"newData2":Object.toJSON(newData2)};
		var successAction = function(resp){
			layout.clearData("B");
			layout.clearData("C");
			
			var userInfo = resp.userInfo;
			layout.loadData(userInfo, "B");
			
			var detail = resp.rtnData;
			layout.loadData(detail, "C");
		};
		ajaxPost(actionName, params, successAction);
	}
	
};

//--------------------------------------------------------------------------
// 檢核
//--------------------------------------------------------------------------
var validates = {
	// 畫面欄位
	checkInput:function(type){
		$$('#form1 input[type="text"]').each( function(text){ text.style.backgroundColor = ''; } );	// reset input color
		validator.clear();

		if(type == "query" || type == "updatepackdate"){
			// 受理編號
			var APPLY_ID = $('A_APPLY_ID').value;
			if(!APPLY_ID){
				validator.define("A_APPLY_ID", "", "受理編號不可為空", validates.returnFalse);
			}else if(APPLY_ID.length > 11){
				validator.define("A_APPLY_ID", "", "受理編號長度不可大於11", validates.returnFalse);
			}
		}else if(type == "update"){
			//var CRED_DEPT = $('B_CRED_DEPT').value;
			//if(!CRED_DEPT){
			//	validator.define("B_CRED_DEPT", "", "請選擇任一承辦科別", validates.returnFalse);
			//}
			
			var CRED_ID = $('C_CRED_ID').value;
			if(!CRED_ID){
				validator.define("C_CRED_ID", "", "請選擇任一新徵信人員", validates.returnFalse);
			}
			if(!validates.isTextLengthLegal('C_MEMO', 200)){
				var msg = "字數(中文佔2個字)為" + $('C_MEMO').value.replace(twoBytesRegExp, "rr").length + "，已經超過上限" + 200;
				validator.define( "C_MEMO" , "", msg , validates.returnFalse);
			}			
		}
		
		return validator.validate();
	},
	// 檢查text是否超過字數限制
	isTextLengthLegal:function(key, maxLength){
		var value = $(key).getValue();

		if(!isNaN(parseInt(maxLength, 10))){
			return validateStringBytes(value, 0, maxLength);
		}else{
			return true;
		}
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
				$(key).value = formatInput.money(value, pattern);
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
	// 取得新徵信人員下拉選單
 /*getCRED_ID_Map:function(CRED_DEPT){
		selection.clean("B_CRED_ID");
		var CRED_ID_List = CRED_ID_Map[CRED_DEPT];
		selection.createAll("B_CRED_ID", CRED_ID_List, "", "", "", "ID", "NAME");*/
		/*if(CRED_DEPT){
			var CRED_ID_List = CRED_ID_Map[CRED_DEPT];
			
			if(CRED_ID_List){
				selection.createAll("B_CRED_ID", CRED_ID_List, "", "", "", "ID", "NAME"); 
			}else{
				var actionName = "getCRED_ID_Map"; 
				var params = {"CRED_DEPT":CRED_DEPT};
				var successAction = function(resp){
					var CRED_ID_List = resp.CRED_ID_List;
					CRED_ID_Map[CRED_DEPT] = CRED_ID_List;
					
					selection.createAll("B_CRED_ID", CRED_ID_List, "", "", "", "ID", "NAME"); 
				};
				var errorAction = function(resp){
					var CRED_ID_List = null;
					
					selection.createAll("B_CRED_ID", CRED_ID_List, "", "", "", "ID", "NAME"); 
				};
				ajaxPost(actionName, params, successAction, errorAction);
			}
		}*/
	//}, 

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
	// 產生單一下拉選單(如果下拉選單的value == 資料的Value，則將該option選擇起來)
	create:function(tagID, optionValue, optionText, choiceValue){
		$(tagID).options.add(new Option(optionText, optionValue));

		if(choiceValue && optionValue == choiceValue){
			$(tagID).options[$(tagID).length - 1].selected = true;
		}
	},
	// 清空下拉選單
	clean:function(tagID){
		$(tagID).options.length = 1;
	}
};

//--------------------------------------------------------------------------
// 畫面
//--------------------------------------------------------------------------
var emptyDatas_B = {
	INPUT_ID:"",
	INPUT_DATE:""
};

var emptyDatas_C = {
	APPLY_ID:"",
	BORROW_NAME:"",
	LOAN_KIND_NM:"",
	IMAGE_TYPE:"",
	LOAN_TYPE_NAME:"",
	GAGE_ADDR:"",
	PROCESS_NAME:"",
	SEND_DATE:"",
	CRED_NAME:"",
	CRED_DEPT_NM:"",
	EASY_APPLY_DATE:"",
	EASY_ASSIGN_DATE:"",
	FORM_TYPE:"",
	MEMO_DATA:""
};

var layout = {
	// 載入資料
	loadData:function(datas, preKey){
		if(datas){
			auxiliary.dataInput(datas, preKey);
		}
	},
	// 清空資料
	clearData:function(preKey){
		if(preKey == "B"){
			auxiliary.dataInput(emptyDatas_B, preKey);
			//$('B_CRED_DEPT').value = "";
			//selection.clean('B_CRED_ID');
			//$('B_DEPT_TYPE').value = "";
		}else if(preKey == "C"){
			auxiliary.dataInput(emptyDatas_C, preKey);
		}
	}
};

//--------------------------------------------------------------------------
// 格式化
//--------------------------------------------------------------------------
var formatInput = {
	// 一般輸入
	text:function(key_Value, isKey, defaultVaule){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}
		
		if(!defaultVaule && defaultVaule != "0"){
			defaultVaule = "";
		}
		
		// 取得value
		var value;
		if(isKey){
			value = $(key_Value).value;
		}else{
			value = key_Value;
		}
		
		// 處理value
		if(value || !isNaN(parseInt(value))){
			value = value + "";
		}else {
			value = defaultVaule + "";
		}
		
		// 設定或回傳value
		if(isKey){
			$(key_Value).value = value.trim();
		}else{
			return value.trim();
		}
	},
	// 數字輸入
	number:function(key_Value, isKey,  defaultVaule){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}
		
		if(isNaN(parseInt(defaultVaule))){
			defaultVaule = "";
		}
		
		// 取得value
		var value;
		if(isKey){
			value = $(key_Value).value;
		}else{
			value = key_Value;
		}
		
		// 處理value
		if(isNaN(parseInt(value))){
			value = defaultVaule + "";
		}else {
			value = value + "";
		}
		
		// 設定或回傳value
		if(isKey){
			$(key_Value).value = value.trim();
		}else{
			return value.trim();
		}
	},
	// 金額輸入
	money:function(key_Value, isKey, pattern, mode, defaultVaule){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}
		
		if(isNaN(parseInt(defaultVaule))){
			defaultVaule = "";
		}
		
		// mode={0:四捨五入, 1:只做格式化(無條件捨去), 2:無條件進位}
		if(pattern){
		}else{
			pattern = pattern_money2;
		}
		
		if(mode){
		}else{
			mode = "0";
		}
		
		var value;
		if(isKey){
			value = $(key_Value).getValue().trim();
			pattern = ($(key_Value).pattern) ? $(key_Value).pattern : pattern;
		}else{
			value = key_Value;
		}
		
		var scale = pattern.split(".");
		var length = scale.length;
		if(length > 1){
			scale = scale[length-1].length;
		}else{
			scale = 0;
		}
		
		// 處理value
		if(isNaN(parseInt(value))){
			value = defaultVaule.trim();
		}else {
			var bigNum = new BigNumber(value, scale).toString();
			if(value === 0){
				return "0";
			}else if(mode == "0"){
				value = CSRUtil.$fmt(bigNum, pattern);
			}else if(mode == "1"){
				if(scale == "0"){
					value = CSRUtil.$fmt(bigNum, pattern, "true");
				}else{
					value = CSRUtil.$fmt(bigNum, pattern);
				}
			}else if(mode=="2"){
			
			}
		}
		
		// 設定或回傳value
		if(isKey){
			$(key_Value).value = value.trim();
		}else{
			return value.trim();
		}
	},
	// 取得金額位數(台幣：整數、非台幣：兩位小數)
	getMoneyPattern:function(CURR){
		if(CURR == "NTD"){
			return pattern_money;
		}else{
			return pattern_money2;
		}
	},
	// 民國年轉西元年
	ROCDate2Y2KDate:function(date){
		var rocDate;
		var isKey;
		
		if(date && $(date)){
			rocDate = $(date).value;
			isKey = true;
		}else{
			rocDate = date;
			isKey = false;
		}
		if(rocDate){
			rocDate = rocDate.replace("/","").replace("/","");
			var dateLength = rocDate.length;
			
			if(dateLength == 5 && isROCdate("0" + rocDate)){
				var value = (parseInt(rocDate.substring(0, dateLength-4), 10)+1911) + "-" + rocDate.substring(dateLength-4, dateLength-2) + "-" + rocDate.substring(dateLength-2);
				
				if(isKey){
					$(date).value = value;
				}
				
				return value;
			}else if(dateLength > 5 && isROCdate(rocDate)){
				var value = (parseInt(rocDate.substring(0, dateLength-4), 10)+1911) + "-" + rocDate.substring(dateLength-4, dateLength-2) + "-" + rocDate.substring(dateLength-2);
				
				if(isKey){
					$(date).value = value;
				}
				
				return value;
			}
		}
		
		if(isKey === true){
			alert("輸入的日期：" + rocDate + "，不符合民國年格式(例：1000101)");
			$(date).value = "";
		}
		return "";
	},
	// 西元年轉民國年 
	Y2KDate2ROCDate:function(date, symbol){
		var y2kDate;
		var isKey;
		if(date && $(date)){
			y2kDate = $(date).value;
			isKey = true;
		}else{
			y2kDate = date;
			isKey = false;
		}
		
		if(!symbol){
			symbol = "";
		}

		if(y2kDate){
			var splitTool = y2kDate.split(" ");
			y2kDate = (splitTool[0]) ? splitTool[0] : "";
		
			if(isADdate(y2kDate)){
				var dates = y2kDate.split("-");
				var rocYear = parseInt(dates[0], 10)-1911;
				if(rocYear.length < 2){
					rocYear = "0" + rocYear;
				}
				y2kDate = rocYear + symbol + dates[1] + symbol + dates[2];
				
				if(splitTool.length > 1){
					y2kDate = y2kDate + " " + splitTool[1];
				}
				
				if(isKey){
					$(date).value = y2kDate;
				}
				
				return y2kDate;
			}
		}
		
		if(isKey){
			alert("輸入的日期：" + y2kDate + "，不符合西元年格式(例：2011-01-01)");
			$(date).value = "";
		}
		return "";
	},
	// 西元年月轉民國年月
	Y2KMonth2ROCMonth:function(date, symbol){
		var y2kDate;
		var isKey;
		if(date && $(date)){
			y2kDate = $(date).value;
			isKey = true;
		}else{
			y2kDate = date;
			isKey = false;
		}
		
		if(!symbol){
			symbol = "";
		}

		if(y2kDate){
			var splitTool = y2kDate.split(" ");
			y2kDate = (splitTool[0]) ? splitTool[0] : "";
			
			if(y2kDate.length < 10){
				y2kDate = y2kDate + "-01";
			}
			if(isADdate(y2kDate)){
				var dates = y2kDate.split("-");
				var rocYear = parseInt(dates[0], 10)-1911;
				if(rocYear.length < 2){
					rocYear = "0" + rocYear;
				}
				y2kDate = rocYear + symbol + dates[1];
				
				if($(date)){
					$(date).value = y2kDate;
				}
				
				return y2kDate;
			}
		}
		
		if(isKey){
			alert("輸入的日期：" + y2kDate + "，不符合西元年格式(例：2011-01-01)");
			$(date).value = "";
		}
		return "";
	}
};

//--------------------------------------------------------------------------
// 輔助工具
//--------------------------------------------------------------------------
var auxiliary = {
	// 將資料放進對應的欄位
	dataInput:function(datas, preKey){
		function trim(s) {
			var m = s.match(/^\s*(\S+(\s+\S+)*)\s*$/);
			return (m == null) ? "" : m[1];
		}

		var dataKey = Object.keys(datas);
		
		dataKey.each(
			function(key){
				try {
			 		var value = datas[key];
			 		//value = (value == null || Object.keys(value).length == 0) ? "" : trim(value.toString());
					
					if(preKey){
						key = preKey + "_" + key;
					}
					
					var element = $(key);
					
					if (element) {
						var tagType = element.tagName;

						if ( tagType != null) {
							tagType = trim(tagType).toLocaleLowerCase();
							var datatype = element.getAttribute("datatype");	// 自訂的型態(可能需要format)
							var pattern = element.getAttribute("pattern");		// 自訂的format格式

							if (tagType == 'div' || tagType == 'span' || tagType == 'td') {
								value = auxiliary.trim(value, datatype, pattern, key);
								element.setAttribute('old_value', value);
								element.update( value );
							} else {
								var type = element.type;
								if (type == 'checkbox' || type == 'radio') {
									var objs = document.getElementsByName(key);
									for (var j=0; j<objs.length; j++) {
										if (objs[j].value == value) {
											objs[j].checked = true;
										}
										objs[j].old_value = value;
									}
								}else {
									var tmpNum = auxiliary.trim(value, datatype, pattern, key);

									element.setValue(tmpNum);
									element.setAttribute('old_value', tmpNum);
								}
							}
						}
					}
				} catch (e) {
					//alert(e.message);
				}
			}
		);
	    //查詢成功後將徵信單位帶到承辦科別裡
		//$('B_CRED_DEPT').value = $('C_CRED_DEPT').innerHTML;
		//selection.getCRED_ID_Map($('B_CRED_DEPT').value);
		//selection.getCRED_ID_Map($('CRED_DEPT').innerHTML);
		return;
	},
	// 將傳進來的字串去掉空白。或是當字串為null時，回傳""
	trim:function(s, datatype, pattern, key){
		if(typeof(s) == "number"){
			s = s + "";
		}else if(!s){
			return "";
		}

		if(datatype == "number"){
			if(!pattern){
				pattern = pattern_money;
			}
			return CSRUtil.$fmt(s, pattern);
			
		}else if(datatype == "date"){
			if(pattern == "time"){
				pattern = pattern_time;
			} else{
				pattern = pattern_date;
			}
 			var result = (!s) ? '':s.match(pattern);
		    return (!result) ? '' : result[0];
			
		}else if(datatype == "ROCDate"){
			if(pattern == "time"){
				pattern = pattern_time;
			} else{
				pattern = pattern_date;
			}
 			var result = (!s) ? '':s.match(pattern);
			return (!result) ? '' : formatInput.Y2KDate2ROCDate(result[0], "/");
		}else if(datatype == "cm"){
		
		}

		return s.trim();
	}
};

//--------------------------------------------------------------------------
// 共用－Ajax
//--------------------------------------------------------------------------
function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSA2_0101/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){
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
		<td  class="tbYellow" width="12%">
			受理編號
		</td>
		<td class="tbYellow2" colspan="3">
			<input id="A_APPLY_ID" name="A_APPLY_ID" type="text" class="textBox2" size="15" maxlength="11" value="">
			<span id="CRED_DEPT" style="display:none"></span>
			<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
			<input id="btn_clear" name="btn_clear" type="button" class="button" value="清除">
		</td>
	</tr>
	<tr>
		<td class="tbYellow1" align="center" colspan="4">
			<input id="btn_update" name="btn_update" type="button" class="button" value="案件派件及移轉">
			<input id="btn_update_packdate" name="btn_update_packdate" type="button" class="button" value="收到包裹">
		</td>
	</tr>
	<tr>
		<td class="tbYellow0" align="center" colspan="4">
			<span style="font-weight:bold">作業功能</span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="15%">
			承辦科別
		</td>
		<td class="tbYellow2" width="35%">
			<span id="C_CRED_DEPT_NM"></span>
		</td>
		<td class="tbYellow" width="15%">
			新徵信人員
		</td>
		<td class="tbYellow2" width="35%">
			<select id="C_CRED_ID" name="C_CRED_ID" class="textBox2" alt="ch">
				<option value="">請選擇</option>
				<c:forEach var="map" items="${CRED_ID_List}">
					<option value="${map.key}">${map.value}</option>
				</c:forEach>				
			</select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			備註說明
		</td>
		<td class="tbYellow2" colspan="3">
			<input id="C_MEMO" name="C_MEMO" fieldName="備註說明" type="text" class="textBox2" size="95" maxlength="200" value="">
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			移轉人員
		</td>
		<td class="tbYellow2">
			<span id="B_INPUT_ID"></span>
		</td>
		<td class="tbYellow">
			派件或移轉日期
		</td>
		<td class="tbYellow2">
			<span id="B_INPUT_DATE" datatype="ROCDate"></span>
		</td>
	</tr>			
	<tr>
		<td class="tbYellow0" align="center" colspan="4">
			<span style="font-weight:bold">案件明細</span>
			<span id="C_FORM_TYPE" style="display:none"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			受理編號
		</td>
		<td class="tbYellow2" colspan="3">
			<span id="C_APPLY_ID"></span>
			 <span id="applyId"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			借款人姓名
		</td>
		<td class="tbYellow2">
		 	<%--[20240731]難字調整--%>
			<span id="C_BORROW_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow">
			貸款種類
		</td>
		<td class="tbYellow2">
			<span id="C_LOAN_KIND_NM"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			影像件
		</td>
		<td class="tbYellow2">
			<span id="C_IMAGE_TYPE"></span>
		</td>
		<td class="tbYellow">
			貸款類別
		</td>
		<td class="tbYellow2">
			<span id="C_LOAN_TYPE_NAME"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			擔保品地址
		</td>
		<td class="tbYellow2" colspan="3">
			<%--[20240731]難字調整--%>
			<span id="C_GAGE_ADDR" style="font-family:'EUDC'"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			受理進度
		</td>
		<td class="tbYellow2">
			<span id="C_PROCESS_NAME"></span>
		</td>
		<td class="tbYellow">
			送件日期
		</td>
		<td class="tbYellow2">
			<span id="C_SEND_DATE" datatype="ROCDate"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
		</td>
		<td class="tbYellow2">
		</td>
		<td class="tbYellow">
			原徵信人員
		</td>
		<td class="tbYellow2">
			<span id="C_CRED_ID" style="display:none"></span>
			<%--[20240731]難字調整--%>
			<span id="C_CRED_NAME" style="font-family:'EUDC'"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			初核受理日期
		</td>
		<td class="tbYellow2">
			<span id="C_EASY_APPLY_DATE" datatype="ROCDate"></span>
		</td>
		<td class="tbYellow">
			初核派件日期
		</td>
		<td class="tbYellow2">
			<span id="C_EASY_ASSIGN_DATE" datatype="ROCDate"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			備註
		</td>
		<td class="tbYellow2" colspan="3">
			<span id="C_MEMO_DATA"></span>
		</td>
	</tr>	
</table>
</form>

</body>
</html>