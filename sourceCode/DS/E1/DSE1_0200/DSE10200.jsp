<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
    Date        Version Description Author
    2011/7/25   1.0     Created     楊正弘
    
    程式功能概要說明：
    程式功能　移送案件明細查詢
    程式名稱　DSE1_0200.java
    作業方式　ONLINE
    概要說明　(1)查詢：使用者按下查詢按鈕後，透過模組取得案件移送統計資料並顯示於畫面。
    
    使用檔案：
    項次　中文說明　　　　　檔案名稱
    1.　　收息資料檔　　　　DTDSC100
    2.　　理財型貸款資料檔　DTDSC104
    3.　　法務受理檔　　　　DTDSE010
    
    使用模組：
    項次　中文說明　　　　　程式名稱
    1.　　移送案件查詢模組　DS_E10200

	@author i9300616
	@since 2011-09-01
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

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

<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var grid;
var gridDataList;
var tableInfo;
var validator;

var pattern_time = /(\d+)-(\d+)-(\d\d) (\d+):(\d+)/;	// 日期格式
var pattern_date = /(\d+)-(\d+)-(\d\d)/;	// 日期格式(date)
var pattern_money = "#,###";	// 金額格式(無小數)
var pattern_money2 = "#,###.##";	// 金額格式(小數2位)

function initApp(){
	validator = new Validator();
	new UI().init();
}

function UI(){
	return {
		init:function() {
			displayMessage();

			grid = new TableUI(
				{
					table: $('grid'), pageSize: 10, allSortable: true,
					column:[
						{header:'區域/承辦法務', key:'NO',
							render:function(record, value){
								var TYPE = $('TYPE').value;
								
								if(TYPE == "1"){
									if(record.CRED_DEPT_NAME){
										return record.CRED_DEPT_NAME;
									}else if(record.CRED_DEPT){
										return record.CRED_DEPT;
									}
								}else if(TYPE == "2"){
									if(record.CFM_NAME){
										return record.CFM_NAME;
									}else if(record.CFM_ID){
										return record.CFM_ID;
									}
								}
							}
						},
						{header:'累計移送', key:'TRANS_CNT',
							render:function(record, value){
								var url = "/DSE1_0201/prompt";
								var STR_DATE = $('STR_DATE').value;
								var END_DATE = $('END_DATE').value;
								var TYPE = $('TYPE').value;
								var CRED_DEPT = record.CRED_DEPT;
								var CFM_ID = record.CFM_ID;
								var KIND = "1";
								
								var TRANS_CNT = moneyControl.format(record.TRANS_CNT, pattern_money);
								return '<a href="#" onClick="hyperlinks.linkDetail(\'' + url + '\', \'' + STR_DATE + '\', \'' + END_DATE + '\', \'' + TYPE + '\', \'' + CRED_DEPT + '\', \'' + CFM_ID + '\', \'' + KIND + '\')">'+TRANS_CNT+'</a>';
							}
						},
						{header:'累計到案確認', key:'TRANS_CFM_CNT',
							render:function(record, value){
								var url = "/DSE1_0201/prompt";
								var STR_DATE = $('STR_DATE').value;
								var END_DATE = $('END_DATE').value;
								var TYPE = $('TYPE').value;
								var CRED_DEPT = record.CRED_DEPT;
								var CFM_ID = record.CFM_ID;
								var KIND = "2";
								
								var TRANS_CFM_CNT = moneyControl.format(record.TRANS_CFM_CNT, pattern_money);
								return '<a href="#" onClick="hyperlinks.linkDetail(\'' + url + '\', \'' + STR_DATE + '\', \'' + END_DATE + '\', \'' + TYPE + '\', \'' + CRED_DEPT + '\', \'' + CFM_ID + '\', \'' + KIND + '\')">'+TRANS_CFM_CNT+'</a>';
							}
						},
						{header:'累計退件(轉出)', key:'TRANS_REJECT_CNT',
							render:function(record, value){
								var url = "/DSE1_0201/prompt";
								var STR_DATE = $('STR_DATE').value;
								var END_DATE = $('END_DATE').value;
								var TYPE = $('TYPE').value;
								var CRED_DEPT = record.CRED_DEPT;
								var CFM_ID = record.CFM_ID;
								var KIND = "3";
								
								var TRANS_REJECT_CNT = moneyControl.format(record.TRANS_REJECT_CNT, pattern_money);
								return '<a href="#" onClick="hyperlinks.linkDetail(\'' + url + '\', \'' + STR_DATE + '\', \'' + END_DATE + '\', \'' + TYPE + '\', \'' + CRED_DEPT + '\', \'' + CFM_ID + '\', \'' + KIND + '\')">'+TRANS_REJECT_CNT+'</a>';
							}
						}
					]
				}
			);
			
			// 查詢
			$("btn_query").observe('click',function(event){
				buttons.doQuery();
			});

			// 輸入欄位去空白
			$w('STR_DATE END_DATE').each( 
				function(key){
					$(key).observe('blur', function(event){
						$(key).value = ($(key).value != null) ? $(key).value.trim() : "";
					});
				}
			);

			/*
			 * 載入下拉選單
			 */
			<c:if test="${not empty TYPE_List}">
				var TYPE_List = ${TYPE_List};
				selection.createAll("TYPE", TYPE_List, "", "", "");
			</c:if>

			/*
			 * 從其他頁返回
			 */
			var LP_JSON = CSRUtil.isBackLink('form1');	
			if(LP_JSON){
				tableInfo = LP_JSON.TABLE_INFO;
				
				var BQ_ARG = LP_JSON.BQ_ARG || {};

				//填回顯示的欄位
				if(BQ_ARG.STR_DATE){
					$('STR_DATE').value = BQ_ARG.STR_DATE;
				}
				
				if(BQ_ARG.END_DATE){
					$('END_DATE').value = BQ_ARG.END_DATE;
				}
				
				if(BQ_ARG.TYPE){
					$('TYPE').value = BQ_ARG.TYPE;
				}
				buttons.doQuery2();
			}
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
	

	
		var queryData = {
			STR_DATE:auxiliary.ROCDate2Y2KDate($('STR_DATE').value),
			END_DATE:auxiliary.ROCDate2Y2KDate($('END_DATE').value),
			TYPE:$('TYPE').value,
			isBack:$('isBack').value
		};
		
		var actionName = "query"; 
		var params = {"queryData":Object.toJSON(queryData)};
		ajaxPost(actionName, params);
	},
	// 從其它頁回來的查詢
	doQuery2:function(){
		$('isBack').value = "true";
		buttons.doQuery();
		$('isBack').value = "false";
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

		var check1 = false;
		var check2 = false;
		
		if($('STR_DATE').value == ""){
			validator.define("STR_DATE", '', '移送起日為必要欄位', validates.returnFalse);
		}else if(!validates.checkDate('STR_DATE', "", "ROC")){
			validator.define("STR_DATE", '', '移送起日格式不正確', validates.returnFalse);
		}else{
			check1 = true;
		}
		
		if($('END_DATE').value == ""){
			validator.define("END_DATE", '', '移送訖日為必要欄位', validates.returnFalse);
		}else if(!validates.checkDate('END_DATE', "", "ROC")){
			validator.define("END_DATE", '', '移送訖日格式不正確', validates.returnFalse);
		}else{
			check2 = true;
		}
		
		if(check1 && check2){
			var STR_DATE = auxiliary.ROCDate2Y2KDate($('STR_DATE').value);
			var END_DATE = auxiliary.ROCDate2Y2KDate($('END_DATE').value);
			
			var diff = diffDay(STR_DATE, END_DATE);
			if(diff < 0){
				validator.define("END_DATE", "", '移送訖日應大於等於移送起日', validates.returnFalse);
			}else if(diff > 365){
				validator.define("END_DATE", "", '移送起日至移送訖日區間不可超過1年', validates.returnFalse);
			}
		}
		
	   	return validator.validate();
	},
	// 檢核超連結的參數是否與畫面一致
	checkHyper:function(STR_DATE, END_DATE, TYPE){
		var errMsg = "";
		if(STR_DATE != $('STR_DATE').value){
			errMsg = errMsg + "移送起日";
		}
		
		if(END_DATE != $('END_DATE').value){
			if(errMsg == ""){
				errMsg = errMsg + "移送訖日";
			}else{
				errMsg = errMsg + "、移送訖日";
			}
		}
		
		if(TYPE != $('TYPE').value){
			if(errMsg == ""){
				errMsg = errMsg + "查詢方式";
			}else{
				errMsg = errMsg + "、查詢方式";
			}
		}
		
		if(errMsg != ""){
			errMsg = errMsg + "有異動，是否要以舊資料進行超連結";
			
			if(!confirm(errMsg)){
				return false;
			}
		}
		
		return true;
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
	returnFalse:function(){
		return false;
	}
};

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
		$(tagID).options.length = 1;
	}
};

//--------------------------------------------------------------------------	
// 超連結
//--------------------------------------------------------------------------
var hyperlinks = {
	// 開新視窗
	openwindow:function(url, title, attrs){
		if(url){
			url = "<%=dispatcher%>" + url;
			if(attrs){
				window.open(url, title, attrs); 
			}else{
				window.open(url); 
			}
		}
	},
	// 導頁
	linkDetail:function(URL, STR_DATE, END_DATE, TYPE, CRED_DEPT, CFM_ID, KIND){
		if(!validates.checkHyper(STR_DATE, END_DATE, TYPE)){
			return;
		}
		
		var LP_JSON = LP_JSON ? LP_JSON : {};	// 紀錄連結資訊Object
		LP_JSON.FROM_TRX = 'DSE1_0200';			// 從這頁出發
		LP_JSON.IS_BACK = "N";					// 是否從別頁回來
		LP_JSON.BACK_TRX = 'DSE1_0200';			// 回這頁
		LP_JSON.BACK_ACTION = 'prompt';			// 回來要先做的事
		
		LP_JSON.STR_DATE = auxiliary.ROCDate2Y2KDate(STR_DATE);
		LP_JSON.END_DATE = auxiliary.ROCDate2Y2KDate(END_DATE);
		LP_JSON.TYPE = TYPE;
		LP_JSON.CRED_DEPT = CRED_DEPT;
		LP_JSON.CFM_ID = CFM_ID;
		LP_JSON.KIND = KIND;
		LP_JSON.TABLE_INFO = grid.getTableInfo();
		
		// 畫面欄位資料
		var BQ_ARG = {};
		
		BQ_ARG.STR_DATE = $('STR_DATE').value;
		BQ_ARG.END_DATE = $('END_DATE').value;
		BQ_ARG.TYPE = TYPE;
		LP_JSON.BQ_ARG = BQ_ARG;
		
		LP_JSON.action = "<%=dispatcher%>" + URL;

		CSRUtil.linkTo(LP_JSON, 'form1');
	}
};

//--------------------------------------------------------------------------	
// 金額相關
//--------------------------------------------------------------------------
var moneyControl = {
	// 取得金額位數(台幣：整數、非台幣：兩位小數)
	getMoneyPattern:function(CURR){
		if(CURR == "NTD"){
			return pattern_money;
		}else{
			return pattern_money2;
		}
	},
	// 對金額做格式化
	format:function(value, pattern, mode){
		// mode={0:四捨五入, 1:只做格式化(無條件捨去), 2:無條件進位}
		if(pattern){
		}else{
			pattern = "#,###.##";
		}
		
		if(mode){
		}else{
			mode = "0";
		}

		var scale = pattern.split(".");
		var length = scale.length;
		if(length > 1){
			scale = scale[length-1].length;
		}else{
			scale = 0;
		}
		
		
		if(value || value=="0"){
			if(value=="0"){
				return "0";
			}else if(mode=="0"){
				var bigNum = new BigNumber(value, scale).toString();
				return CSRUtil.$fmt(bigNum, pattern);
			}else if(mode=="1"){
				if(scale=="0"){
					return CSRUtil.$fmt(bigNum, pattern, "true");
				}else{
					return CSRUtil.$fmt(bigNum, pattern);
				}
			}else if(mode=="2"){
			
			}
		}
		
		return "";
	}
};

//--------------------------------------------------------------------------
// 輔助工具
//--------------------------------------------------------------------------
var auxiliary = {
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
function ajaxPost( actionName, params, successAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSE1_0200/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){
			if(CSRUtil.isSuccess(resp)){
				if(successAction){
	 				successAction(resp);
	 			}else{
			  		grid.load(resp.rtnList);
			  		if(tableInfo){
			  			grid.setTableInfo(tableInfo);
			  			tableInfo = null;
			  		}
			  	}
			}else if(actionName == "query"){
			  	grid.load([]);
			}
        }}
	);
}

//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<center>
<span id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility: visible;" > 
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr> 
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
   	 	<td valign="top" bgcolor="#F0FBC6">
   	 	<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
	        <tr>
	          	<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
	        </tr>
	  	</table>
		<!-- InstanceBeginEditable name="title" -->
		<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
	  		<tr> 
	          	<td width="20" height="24" align="center"><font size="-5">●</font></td>
	          	<td>法務件</td>
	          	<td align="right">畫面編號：DSE10200</td>
	        </tr>
		</table>
      	<!-- InstanceEndEditable -->
      	</td>
    	<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
   	 	<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  	</tr>
</table>
</span> 
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
  	<tr> 
    	<td>&nbsp;</td>
  	</tr>
</table>
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr> 
	    <td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
	    <td width="100%" valign="top" bgcolor="#F0FBC6"><!-- InstanceBeginEditable name="content" -->
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td valign="top">
				<table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
					<tr> 
						<td class="tbBox2">
							<img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">
							移送案件查詢
						</td>
					</tr>
					<tr bgcolor=#FFFFFF>
						<td>
						<form name="form1" id="form1" method="post" action="">
							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
								<input id="isBack" name="isBack" type="hidden" value="false"/>
								<tr>
									<td class="tbYellow" width="12%">
										移送日期
									</td>
									<td class="tbYellow2" width="32%">
										<input id="STR_DATE" name="STR_DATE" type="text" class="textBox2" size="8" maxlength="7" datatype="ROCDate">
										<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('STR_DATE'))">
										~
										<input id="END_DATE" name="END_DATE" type="text" class="textBox2" size="8" maxlength="7" datatype="ROCDate">
										<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('END_DATE'))">
									</td>
									<td class="tbYellow" width="12%">
										查詢方式
									</td>
									<td class="tbYellow2" width="32%">
										<select id="TYPE" name="TYPE" class="textBox2">
										</select>
									</td>
									<td class="tbYellow2" align="center" width="12%">
										<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
									</td>
								</tr>
							</table>
							<table id="grid" class="grid" width="100%"></table>
						</form>
						</td>
					</tr>
				</table>
				</td>
			</tr>
		</table>
    	</td>
    	<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  	</tr>
</table>
</center>
</body>
</html>