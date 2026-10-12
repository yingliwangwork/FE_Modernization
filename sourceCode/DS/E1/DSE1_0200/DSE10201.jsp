<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
    Date        Version Description Author
    2011/8/11   1.0     Created     楊正弘
    
    程式功能概要說明：
    程式功能　移送案件明細查詢
    程式名稱　DSE1_0201.java
    作業方式　ONLINE
    概要說明　(1)初始：透過模組移送案件明細資料，顯示於查詢結果
　　　　　　　(2)明細下載：使用者按下明細下載按鈕後，依查詢條件重新取得資料後，產生CSV檔供使用者下載。
　　　　　　　(3)上一頁：連結至LINK_FROM所傳入參頁面，並依照原來的查詢條件，重新查詢。
    
    使用檔案：
    項次　中文說明　　　　　檔案名稱
    1.　　收息資料檔　　　　DTDSC100
    2.　　理財型貸款資料檔　DTDSC104
    3.　　法務受理檔　　　　DTDSE010
    
    使用模組：
    項次　中文說明　　　　　程式名稱
    1.　　移送案件明細模組　DS_E10201

	@author i9300616
	@since 2011-09-01

[20240207]
難字調整
高強禾
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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<%-- [20240207] 難字調整 --%>
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

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var reqMap; // 查詢條件
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
	                <%-- [20240207] 難字調整 --%>
	                afterLoad: function() {
	                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	                },
	                pageChange: function() {
	                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	                },
					column:[
						{header:'貸款帳號', key:'LOAN_ID'},
						{header:'原貸帳號', key:'REFER_ID'},
						<%-- [20240207] 難字調整：借款人 --%>
						{header:'借款人', key:'BORROW_NAME', render : function (rec, val) {
							return new Element('span', {style:"font-family:'EUDC'"}).update(val);
						}},
						{header:'本金餘額', key:'REMAIN_AMT', attrs:{align:'right'},
							render:function(record, value){
								var REMAIN_AMT = moneyControl.format(record.REMAIN_AMT, pattern_money2);
								return REMAIN_AMT;
							}
						},
						{header:'下次應繳日', key:'NEXT_PAYDT',
							render:function(record, value){
								var NEXT_PAYDT = record.NEXT_PAYDT;
								var result = (!NEXT_PAYDT) ? '':NEXT_PAYDT.match(pattern_date);
								NEXT_PAYDT = (!result) ? '' : auxiliary.Y2KDate2ROCDate(result[0], "/");
								
								return NEXT_PAYDT;
							}
						},
						{header:'貸放日', key:'LOAN_DATE',
							render:function(record, value){
								var LOAN_DATE = record.LOAN_DATE;
								var result = (!LOAN_DATE) ? '':LOAN_DATE.match(pattern_date);
								LOAN_DATE = (!result) ? '' : auxiliary.Y2KDate2ROCDate(result[0], "/");
								
								return LOAN_DATE;
							}
						},
						{header:'移送日', key:'INPUT_LEADER_DATE',
							render:function(record, value){
								var INPUT_LEADER_DATE = record.INPUT_LEADER_DATE;
								var result = (!INPUT_LEADER_DATE) ? '':INPUT_LEADER_DATE.match(pattern_date);
								INPUT_LEADER_DATE = (!result) ? '' : auxiliary.Y2KDate2ROCDate(result[0], "/");
								
								return INPUT_LEADER_DATE;
							}
						},
						{header:'派件日', key:'INPUT_DATE',
							render:function(record, value){
								var INPUT_DATE = record.INPUT_DATE;
								var result = (!INPUT_DATE) ? '':INPUT_DATE.match(pattern_date);
								INPUT_DATE = (!result) ? '' : auxiliary.Y2KDate2ROCDate(result[0], "/");
								
								return INPUT_DATE;
							}
						},
						{header:'到案日', key:'CFM_DATE',
							render:function(record, value){
								var CFM_DATE = record.CFM_DATE;
								var result = (!CFM_DATE) ? '':CFM_DATE.match(pattern_date);
								CFM_DATE = (!result) ? '' : auxiliary.Y2KDate2ROCDate(result[0], "/");
								
								return CFM_DATE;
							}
						},
						{header:'退件日', key:'REJECT_DATE',
							render:function(record, value){
								var REJECT_DATE = record.REJECT_DATE;
								var result = (!REJECT_DATE) ? '':REJECT_DATE.match(pattern_date);
								REJECT_DATE = (!result) ? '' : auxiliary.Y2KDate2ROCDate(result[0], "/");
								
								return REJECT_DATE;
							}
						},
						<%-- [20240207] TODO 難字調整：借款人 --%>
						{header:'承辦法務', key:'CFM_NAME', render : function (rec, val) {
							return new Element('span', {style:"font-family:'EUDC'"}).update(val);
						}},
						{header:'服務中心一',key:'SRV_DEPT_NAME1'},
						{header:'服務中心二三',key:'SRV_DEPT_NAME23'},
						{header:'收息單位', key:'GETINT_DEPT'},
						{header:'已繳期數', key:'PAID_TIMES',
							render:function(record, value){
								var PAID_TIMES = moneyControl.format(record.PAID_TIMES, pattern_money);
								return PAID_TIMES;
							}
						}
					]
				}
			);
			
			// 匯出CSV
			$("btn_exportCSV").observe('click',function(event){
				buttons.doExport("CSV");
			});

			// 回上一頁
			$("btn_back").observe('click',function(event){
				buttons.doBack();
			});
			
			/*
			 * 查詢條件
			 */
			<c:if test="${not empty reqMap}">
				reqMap = ${reqMap};
				$('queryData').value = Object.toJSON(reqMap);
			</c:if>
			
			/*
			 * 查詢結果
			 */
			<c:if test="${not empty rtnList}">
				var rtnList = ${rtnList};
				grid.load(rtnList);
			</c:if>
			
			var count = grid.getAllRecords().length;
			if(count > 0){
				$('btn_exportCSV').enable();
			}else{
				$('btn_exportCSV').disable();
			}
		}
	};
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 匯出
	doExport:function(type){
		var src = "<%=dispatcher%>/DSE1_0201/export2CSV";
		$('gridJSON').value = grid.getXlsSettingJSON("案件移送明細資料");
		RPTUtil.executeCreateXlsFile(src, Form.serialize("form1"));
	},
	// 回上一頁
	doBack:function(){
		CSRUtil.linkBack();
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
	          	<td align="right">畫面編號：DSE10201</td>
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
							移送案件明細查詢
						</td>
					</tr>
					<tr bgcolor=#FFFFFF>
						<td>
						<form name="form1" id="form1" method="post" action="">
							<input id="queryData" name="queryData" type="hidden" value="">
							<input id="gridJSON" name="gridJSON" type="hidden" value="">
							<table id="grid" class="grid" width="100%"></table>
							<div align="center">
								<input id="btn_exportCSV" name="btn_exportCSV" type="button" class="button" value="明細下載">
								<input id="btn_back" name="btn_back" type="button" class="button" value="回上一頁">
							</div>
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