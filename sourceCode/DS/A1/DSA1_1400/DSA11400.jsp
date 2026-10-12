<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<%-- 
[20190701] 修改件：增加借款人與保證人姓名羅馬拼音
[20201130] 修改件：外網多筆個資遮蔽  @author 何宗霖
[20240726] 修改件 難字調整
[20250217] 修改件 [申請書:25020405429]核准明細查詢作業畫面優化
--%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<%--[20240726]難字css  --%>
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/pageController.js"></script><!--頁碼-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<script language="javascript" type="text/javascript">

var valid1;
<%--[20201130]外網多筆個資遮蔽--%>
var preTr;

var validateDate = function(){		
	if(diffDay($F('QUERY_STR_DATE'),$F('QUERY_END_DATE'), true) < 0)
		return false;
	return true;		
};

var validateDate1 = function(){	
	if($F('DEPT').length == 2 && diffDay($F('QUERY_STR_DATE'),$F('QUERY_END_DATE'), true) >= 15){
		return false;
	}else{
		return true;
	}	
};

var validateDate2 = function(){	
	if($F('DEPT').length != 2 && diffDay($F('QUERY_STR_DATE'),$F('QUERY_END_DATE'), true) > 30){
		return false;
	}else{
		return true;
	}	
};


function initApp(){
	PageUI.createPageWithAllBodySubElement("DSA11400" , "受理作業" , "核准明細查詢", 1);
    //$('PageUiOverDiv').hide();
  	// 頁面 title 定位
	fix();
	// 顯示執行結果
	displayMessage();
	
	// 查詢
	$("btn_query").observe('click',function(event){
		buttons.doQuery();
	});
	
	// 列印
	$("btn_print").observe('click',function(event){
		buttons.doPrint();
	});
	
	
	
	
	valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
	
	Validation.addAllThese([
		[ 'validateDate',  '終止日期需大於起始日期，請檢查後重新輸入查詢條件', validateDate],
		[ 'validateDate1',  '進行區部查詢時，查詢區間不得超過15天!', validateDate1],
		[ 'validateDate2',  '查詢區間不得超過一個月!', validateDate2]
	]);	 
	
	var LP_JSON = CSRUtil.isBackLink('form1');
	if(LP_JSON){
		//$('APPLY_DIV').value = LP_JSON.BQ_ARG.APPLY_DIV;
		buttons.doQuery();
	};
		
	<c:if test="${not empty rtnList}">
		//$('PageUiOverDiv').show();
		PageUI.resize(true);
	</c:if>
	
	
}




//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){
		valid1.reset();
		
		columnToUpperCase('DEPT');
		
		if( !valid1.validate() ) {return;}
		
		preTr = null ;//再次查詢時清除preTr，避免顯示到上一次的暫存個資
		
		var frm = document.form1;		
		frm.action = "<%=dispatcher%>/DSA1_1400/query";
		frm.target = "";  
		submitOnce($('btn_query'));
	},
	// 列印
	doPrint:function(){
		valid1.reset();
		
		columnToUpperCase('DEPT');
		
		if( !valid1.validate() ) {return;}

				
		var url = "<%=dispatcher%>/DSA1_1402/prompt?QUERY_STR_DATE="+$F('QUERY_STR_DATE')+"&QUERY_END_DATE="+$F('QUERY_END_DATE')+"&DEPT="+$F('DEPT')+"&APPLY_ID="+'${APPLY_ID}';
	
		window.open(url,"DSA1_1402", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
		
	},
	<%--[20201204]外網多筆個資遮蔽_設置切換按鈕
	doHidden : function(sn){
		if(preTr){
			$("BORROW_NAME_MASK_"+preTr).toggle();
			$("BORROW_NAME_"+preTr).toggle();
			$("DAY_TEL_MASK_"+preTr).toggle();
			$("DAY_TEL_"+preTr).toggle();
			$("NIGHT_TEL_MASK_"+preTr).toggle();
			$("NIGHT_TEL_"+preTr).toggle();
			$("GUAR_NAME1_MASK_"+preTr).toggle();
			$("GUAR_NAME1_"+preTr).toggle();
			$("GUAR_NAME2_MASK_"+preTr).toggle();
			$("GUAR_NAME2_"+preTr).toggle();
			$("GUAR_NAME3_MASK_"+preTr).toggle();
			$("GUAR_NAME3_"+preTr).toggle();
			$("GUAR_NAME4_MASK_"+preTr).toggle();
			$("GUAR_NAME4_"+preTr).toggle();
			$("GAGE_ADDR_MASK_"+preTr).toggle();
			$("GAGE_ADDR_"+preTr).toggle();
			$("GUAR_NOTICE_NAME_MASK_"+preTr).toggle();
			$("GUAR_NOTICE_NAME_"+preTr).toggle();
			$("OWNER_NAME2_MASK_"+preTr).toggle();
			$("OWNER_NAME2_"+preTr).toggle();
		}
		$("BORROW_NAME_MASK_"+sn).toggle();
		$("BORROW_NAME_"+sn).toggle();
		$("DAY_TEL_MASK_"+sn).toggle();
		$("DAY_TEL_"+sn).toggle();
		$("NIGHT_TEL_MASK_"+sn).toggle();
		$("NIGHT_TEL_"+sn).toggle();
		$("GUAR_NAME1_MASK_"+sn).toggle();
		$("GUAR_NAME1_"+sn).toggle();
		$("GUAR_NAME2_MASK_"+sn).toggle();
		$("GUAR_NAME2_"+sn).toggle();
		$("GUAR_NAME3_MASK_"+sn).toggle();
		$("GUAR_NAME3_"+sn).toggle();
		$("GUAR_NAME4_MASK_"+sn).toggle();
		$("GUAR_NAME4_"+sn).toggle();
		$("GAGE_ADDR_MASK_"+sn).toggle();
		$("GAGE_ADDR_"+sn).toggle();
		$("GUAR_NOTICE_NAME_MASK_"+sn).toggle();
		$("GUAR_NOTICE_NAME_"+sn).toggle();
		$("OWNER_NAME2_MASK_"+sn).toggle();
		$("OWNER_NAME2_"+sn).toggle();
		preTr = sn;
	}--%>
};

function doLinkAPPLY_ID(APPLY_ID) { 
		var LP_JSON = {};
		LP_JSON.action = "<%=dispatcher%>/DSA1_1700/prompt";	
		LP_JSON.APPLY_ID = APPLY_ID;
		LP_JSON.BACK_TRX = 'DSA1_1400';			// 回這頁
		LP_JSON.BACK_ACTION = 'query';			// 回來要先做的事
	
		CSRUtil.linkTo(LP_JSON, 'form1');
}

function doLinkLOAN_KIND_NM(){		
		//var url="https://newquery.cathaylife.com.tw/employee/loan/loan%20collection%20I/appliance/index.htm";
		var url="https://events2.cathaylife.com.tw/events/Loan/loan_collection_I/appliance/index.htm";
		window.open(url);
}

function doLinkOWE_DATA(APPLY_ID,url){
	if(!doCheck(APPLY_ID)){return;}
	if(url != ''){
		window.open(url);
	}
}

function doLinkDIVNO_GUAR_LEVEL(){		
		var LP_JSON = {};
		LP_JSON.action = "<%=dispatcher%>/DSB1_0200/prompt";	
		LP_JSON.BACK_TRX = 'DSB1_0200';			// 回這頁
		LP_JSON.BACK_ACTION = 'query';			// 回來要先做的事
	
		CSRUtil.linkTo(LP_JSON, 'form1');
}

function doLinkDIVNO_GUAR_LEVEL_EXAMPLE(){		
		//var url="https://newquery.cathaylife.com.tw/employee/loan/training%20supplies%20I/guaranty/ex1060324.pdf";
		var url="https://events2.cathaylife.com.tw/events/Loan/training_supplies_I/guaranty/ex1060324.pdf";
		window.open(url);
}

function doSetPrint(APPLY_ID, TYPE) {
	if(!doCheck(APPLY_ID)){return;}
	new Ajax.Request( '<%=dispatcher%>/DSA1_1400/setPrint', 
		{
			parameters:{'APPLY_ID' :APPLY_ID, 'TYPE' : TYPE},
			onSuccess:function(response){
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){	
					var frm = $('form1');					
					frm.target = '_blank';
					frm.action = resp.URL+"?PARAMETERS="+resp.PARAMETERS;
					frm.submit();	
				}				
			}
		}
	);
	
}

function doDownloadAll(APPLY_ID){ <%--[20250218]待補全部下載--%>
	var rtnMap = getApplyData(APPLY_ID);
	rtnMap.UPD_TYPE = 'CHECK_02';
	RPTUtil.downloadFile("${dispatcher}/DSA1_1400/downloadAll", {'rtnMap': Object.toJSON(rtnMap)}, true);
	var target = getHiddenCheck(APPLY_ID, rtnMap.UPD_TYPE);
	target.setValue('Y');
}

function getApplyData(APPLY_ID){  <%--[20250218]取貸款資料--%>
	var dataList = <c:out value="${rtnListJSON}" default="[]" escapeXml="false" />;
	var rtnMap;
	dataList.each(function(dataMap){
		if(dataMap.APPLY_ID == APPLY_ID){
			rtnMap = dataMap;
		}
	});
	return rtnMap;
}

function getHiddenCheck(APPLY_ID, eleName){ <%--[20250219]增--%>
	var target;
	$$('input[name='+eleName+']').each(function(ele){
		if(ele.readAttribute('APPLY_ID') == APPLY_ID) {
			target = ele;
		}
	});
	return target;
}

function doPrintFireChangeApply(APPLY_ID){
	if(!doCheck(APPLY_ID)){return;}
	new Ajax.Request( '<%=dispatcher%>/DSA1_1400/printFireChangeApply', 
		{
			parameters:{'APPLY_ID' :APPLY_ID},
			onSuccess:function(response){
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){	
					RPTUtil.executePrintByResponse(resp, true);	
				}				
			}
		}
	);
}


function doLinkDSA1_1401(LOAN_KIND_NM, OWE_DATA){
	
	$('rtnMap').value = OWE_DATA;
	var url = "<%=dispatcher%>/DSA1_1401/prompt?APPLY_ID="+ LOAN_KIND_NM;

	var form = document.form1;	
	form.action = url;		
	form.target='_blank';
	form.submit();
	
}

function doLinkGUAR_NOTICE(APPLY_ID){
	//var url="https://newquery.cathaylife.com.tw/employee/loan/training%20supplies%20I/guaranty/index.htm";
	var rtnMap = getApplyData(APPLY_ID);
	rtnMap.UPD_TYPE = 'CHECK_01';
	var target = getHiddenCheck(APPLY_ID, rtnMap.UPD_TYPE);
	<%--[20250219]更新A145.CHECK_01--%>
	new Ajax.Request( '${dispatcher}/DSA1_1400/update',{
			parameters:{'rtnMap': Object.toJSON(rtnMap)},
			onSuccess:function(response){
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){	
					target.setValue('Y');
					RPTUtil.executePrintByLink ( "<%=dispatcher%>/DSA1_1405/prompt" ,{APPLY_ID : APPLY_ID, QUERY_STR_DATE : $F('QUERY_STR_DATE'), QUERY_END_DATE : $F('QUERY_END_DATE'), DEPT : $F('DEPT')}, true );
				}				
			}
		}
	);
	//window.open(url);	
}

function doLinkGUAR_CONTRACT(APPLY_ID){
	if(!doCheck(APPLY_ID)){return;}
	//檢核是否有對保資格
	if("${isGuar}" == "N"){
		<%--[20250219]調整文字訊息--%>
		alert("經手人無對保資格請先取得對保資格，或由直屬主管列印貸款契約文件後，可請有對保資格同仁協助對保！");
		return;
	}
	RPTUtil.downloadFile ( "${dispatcher}/DSA1_1406/prompt" ,{APPLY_ID : APPLY_ID, QUERY_STR_DATE : $F('QUERY_STR_DATE'), QUERY_END_DATE : $F('QUERY_END_DATE'), DEPT : $F('DEPT')}, true );	
}

function doCheck(APPLY_ID){
	<%--[20250219]檢核順序1、2需皆下載後(先下載1或2都可以)，才可下載順序3--%>
	var msgArys = [];
	var check01_hidden = getHiddenCheck(APPLY_ID, 'CHECK_01');
	if(check01_hidden.getValue() != 'Y'){
		msgArys.push('順序1：貸款契約書(填寫範例)');
	}
	var check02_hidden = getHiddenCheck(APPLY_ID, 'CHECK_02');
	var isCheck02_hidden = getHiddenCheck(APPLY_ID, 'isCheck02');
	if(check02_hidden.getValue() != 'Y' && isCheck02_hidden.getValue() == 'Y'){
		msgArys.push('順序2：待補資料');
	}
	if(msgArys.length != 0){
		alert('請先下載，'+ msgArys.join("及"));
		return false;
	}
	return true;
}
/*
function doLinkRECOMMEND(){
	//var url="https://newquery.cathaylife.com.tw/employee/loan/form/newnew1060324.pdf";
	var url="https://events.cathaylife.com.tw/employee/loan/form/newnew1060324.pdf";
	window.open(url);
}

function doLinkRECOMMEND_EXAMPLE(){
	//var url="https://newquery.cathaylife.com.tw/employee/loan/form/exnewnew1060324.pdf";
	var url="https://events.cathaylife.com.tw/employee/loan/form/exnewnew1060324.pdf";	
	window.open(url);
}*/


function doLinkMortgage_Setting(){
	//var url="https://newquery.cathaylife.com.tw/employee/loan/training%20supplies%20I/guaranty/Mortgage%20Setting%20ex.pdf";
	var url="https://events2.cathaylife.com.tw/events/Loan/training_supplies_I/guaranty/mortgage_setting_ex.pdf";
	window.open(url);
}

function doLinkGuarNotice(){
	//var url="https://newquery.cathaylife.com.tw/employee/loan/training%20supplies%20I/guaranty/note.pdf";
	var url="https://events2.cathaylife.com.tw/events/Loan/training_supplies_I/guaranty/note.pdf";
	window.open(url);
}

function doLinkGuarTraining(){
	//var url="https://newquery.cathaylife.com.tw/employee/loan/training%20supplies%20I/guaranty/index.htm";
	var url="https://events2.cathaylife.com.tw/events/Loan/training_supplies_I/guaranty/index.htm";
	window.open(url);
}

function doLinkQA(){ <%--[20250218]增--%>
	var url="https://events2.cathaylife.com.tw/events/Loan/training_supplies_I/guaranty/對保契據填寫重點提醒.pdf";
	window.open(url);
}


<%--
	轉大寫
--%>
function columnToUpperCase(columnName) {
	$(columnName).value = $(columnName).value.toUpperCase();
}

</script>
</head>
<body bgcolor="#F0FBC6"  leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="initApp();" onResize="fix();"	onScroll="fix();">

		<form name="form1" id="form1" method="post" action="" >
		    <table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" >
			<input type="hidden" name="isBack" value="N"/>
			<input type="hidden" id="rtnMap" name="rtnMap" value="${rtnMap}"/>
			<tr>
				<td class="tbYellow" width="15%" align="left">核准日期</td>
				<td class="tbYellow2" width="30%">
					<input type="text" datatype="ROCDate" value="${QUERY_STR_DATE}" class="textBox2 required" size="10" maxlength="7" name="QUERY_STR_DATE" id="QUERY_STR_DATE" />
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onClick="getCalendarFor($('QUERY_STR_DATE'))">
					~
					<input type="text" datatype="ROCDate" value="${QUERY_END_DATE}" class="textBox2 required validateDate validateDate1 validateDate2" size="10" maxlength="7" name="QUERY_END_DATE" id="QUERY_END_DATE" />
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onClick="getCalendarFor($('QUERY_END_DATE'))">
				</td>
				<td class="tbYellow" width="15%" align="left">受理單位</td>
				<td class="tbYellow2" width="30%">
					<input type="text" value="${DEPT}" class="textBox required" id="DEPT" name="DEPT" size="7" maxlength="5">
					<font color='red'>可輸入兩碼區部代號查詢</font>
				</td>
				<td class="tbYellow2" align="left"><input type="button" name="btn_query" id="btn_query" class="button" value="查詢" /></td>
				<td class="tbYellow2" align="left"><input type="button" name="btn_print" id="btn_print" class="button" value="列印" /></td>
			</tr>
			</table>
		</form>
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA1">
			<c:forEach var="rtnMap" items="${rtnList}" varStatus="status" >
				<tr>
					<td class="tbYellow2" colspan="3">
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">
							<tr>
								<td class="tbBlue">
									本案請通知【<font color='blue'><span style="font-family:'EUDC'">${rtnMap.GUAR_NOTICE_NAME}</span>
										 	</font>】前來對保<br/>
									<b>
									放款部對保聯繫窗口：<span style="font-family:'EUDC'">${rtnMap.CRED_NAME}</span><br/>
									電話分機：${rtnMap.CRED_EXT}<br/>
									<font color="red">對保、設定、待補資料文件寄至：${rtnMap.CRED_DEPT_ADDR} ${rtnMap.CRED_DEPT_NAME}</font>
									</b>	
								</td>
							</tr>
						</table> 	
					</td>
				</tr>
				<tr>
					<td class="tbYellow2" width="25%" valign="top">
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA1-1">
						   <tr>
						  	 <td class="tbYellow0"colspan="2" align="center"><b>【1】請確認客戶資料</b></td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" width="30%" align="center">受理編號</td>
							 <td class="tbYellow2" width="70%" align="center">
								<a href="javascript:void(0)" onClick="doLinkAPPLY_ID('<c:out value="${rtnMap.APPLY_ID}"/>')"/> <font color="blue">${rtnMap.APPLY_ID}</font></a>
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">核准日期</td>
							 <td class="tbYellow2" align="center">
								<cathay:calendar type="ROC" value="${rtnMap.AGREE_DATE}" />
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">借款人姓名</td>
							 <td class="tbYellow2" align="center">
								<span style="font-family:'EUDC'">${rtnMap.BORROW_NAME}</span>
								<br/>
								<span style="font-family:'EUDC'">${rtnMap.BORROW_NAME_RM}</span>
							 </td>
						   </tr>	
						   <tr>
						  	 <td class="tbYellow" align="center">連絡電話(日)</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.DAY_TEL}
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">連絡電話(夜)</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.NIGHT_TEL}
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">行動電話</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.MOBILE}
							 </td>
						   </tr>
						   <tr>						   						   					   						   
						  	 <td class="tbYellow" align="center">保證人種類</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.GUAR_KIND_NM}
							 </td>
						   </tr>
						   <tr>						   						   					   						   
						  	 <td class="tbYellow" align="center">保證人1</td>
							 <td class="tbYellow2" align="center">
								<span style="font-family:'EUDC'">${rtnMap.GUAR_NAME1}</span>
								<br/>
								<span style="font-family:'EUDC'">${rtnMap.GUAR_NAME1_RM}</span>
							 </td>
						   </tr>
						   <tr>						   						   					   						  
						  	 <td class="tbYellow" align="center">保證人2</td>
							 <td class="tbYellow2" align="center">
								<span style="font-family:'EUDC'">${rtnMap.GUAR_NAME2}</span>
								<br/>
								<span style="font-family:'EUDC'">${rtnMap.GUAR_NAME2_RM}</span>
							 </td>
						   </tr>
						   <tr>						   						   					   						   
						  	 <td class="tbYellow" align="center">保證人3</td>
							 <td class="tbYellow2" align="center">
								<span style="font-family:'EUDC'">${rtnMap.GUAR_NAME3}</span>
								<br/>
								<span style="font-family:'EUDC'">${rtnMap.GUAR_NAME3_RM}</span>
							 </td>
						   </tr>
						   <tr>						   						   					   						 
						  	 <td class="tbYellow" align="center">保證人4</td>
							 <td class="tbYellow2" align="center">
								<span style="font-family:'EUDC'">${rtnMap.GUAR_NAME4}</span>
								<br/>
								<span style="font-family:'EUDC'">${rtnMap.GUAR_NAME4_RM}</span>
							 </td>
						   </tr>
						   <tr>						   						   					   						 
						  	 <td class="tbYellow" align="center">所有權人姓名</td>
							 <td class="tbYellow2" align="center">
								<span style="font-family:'EUDC'">${rtnMap.OWNER_NAME2}</span>
							 </td>
						   </tr>
						   <tr>						   						   					   						 
						  	 <td class="tbYellow" align="center">二順位</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.S_SECOND}
							 </td>
						   </tr>	
						   <tr>						   						   					   						 
						  	 <td class="tbYellow" align="center">經手人</td>
							 <td class="tbYellow2" align="center">
								<span style="font-family:'EUDC'">${rtnMap.SERVICE_NAME}</span>
							 </td>
						   </tr>						   						   							   						   						   						   						   	
						</table>
					</td>
					<td class="tbYellow2" width="25%" valign="top">
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA1-2">
						   <tr>
						  	 <td class="tbYellow0" colspan="2" align="center"><b>【2】請確認核准條件內容</b></td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" width="30%" align="center">貸款種類</td>
							 <td class="tbYellow2" width="70%" align="center">
								<a href="javascript:void(0)" onClick="doLinkLOAN_KIND_NM()"/><font color="blue">${rtnMap.LOAN_KIND_NM}</font></a>
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">貸款類別</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.LOAN_TYPE_NM}
							 </td>
						   </tr>	
						   <tr>
						  	 <td class="tbYellow" align="center">核准金額(萬)</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.AGREE_AMOUNT}
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">定期期數</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.FIX_PERIOD}
							 </td>
						   </tr>	
						   <tr>
						  	 <td class="tbYellow" align="center">分期期數</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.SPR_PERIOD2}
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">核准利率(％)</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.INTEREST_DISPLAY}
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">提前清償違約金比率</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.RENEGE_DISPLAY}
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">帳管費</td>
							 <td class="tbYellow2" align="center">
								<fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.EXPENSE_AMT}" />
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">設定金額(萬)</td>
							 <td class="tbYellow2" align="center">
								<fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.SET_AMT}" />
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">代償金額</td>
							 <td class="tbYellow2" align="center">
								<fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.COMP_AMT}" />
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">代償行庫分行</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.COMP_BANK}
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">火險保額(萬)</td>
							 <td class="tbYellow2" align="center">
								<fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.FIREINSU_AMT}" />
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">地震險保額(萬)</td>
							 <td class="tbYellow2" align="center">
								${rtnMap.EARTH_AMT}
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">住宅火險總保費</td>
							 <td class="tbYellow2" align="center">
								<fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.FIREINSU_PAYMENT}" />${rtnMap.A106_98}
							 </td>
						   </tr>						   	
						</table>
					</td>
					<td class="tbYellow2" width="50%" valign="top">
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA1-3">
						   <tr>
						  	 <td class="tbYellow0" colspan="2" align="center"><b>【3】約客戶對保前-請詳閱以下說明</b></td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" width="30%" align="center">對保前應注意事項</td>
							 <td class="tbYellow2" width="70%">
								<font color='red'>1.請務必查詢是否具有對保資格</font>(<a href="javascript:void(0)" onClick="doLinkDIVNO_GUAR_LEVEL()"/>點我查詢</a>)(<a href='javascript:void(0)' onClick="doLinkDIVNO_GUAR_LEVEL_EXAMPLE()"/>查詢說明</a>)。<br/>
								2.匯款文件需齊備(對保、設定、待補資料)後再行寄送。<br/> 
								3.請詳閱房貸對保應注意事項(<a href='javascript:void(0)' onClick="doLinkGuarNotice()"/>點我下載</a>)、對保常見錯誤QA(<a href='javascript:void(0)' onClick="doLinkQA()"/>點我下載</a>)。<br>
								4.其他對保事項：<a href='javascript:void(0)' onClick="doLinkGuarTraining()"/>對保學習區</a><br/>
								5.最高限額抵押權設定契約書(本契約書請於各服務據點索取)(<a href='javascript:void(0)' onClick="doLinkMortgage_Setting()"/>填寫範例</a>)。 
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">其他應注意事項</td>
							 <td class="tbYellow2">
								<b style="text-decoration: underline">
								1.本案須於核准後4個月內撥款，逾期須重新受理，條件另議且須依央行最新規範辦理。<br>
								2.因應央行相關規範，本案撥款前須重新查詢聯徵，若借、保人新增他行貸款，則無法撥款，核貸條件將重新評估。
								</b>
							 </td>
						   </tr>
						   <tr>
						  	 <td class="tbYellow" align="center">
						  	 	提醒對保<br>
						  	 	<font color='red'>應補全事項</font>
						  	 </td>
							 <td class="tbYellow2">
								<c:if test="${not empty rtnMap.LINK }">
									${rtnMap.LINK}&nbsp;${rtnMap.MSG}<br>
								</c:if>
								<c:if test="${rtnMap.A106_97 eq 'Y'}">
									${rtnMap.A106_97_NAME}<br>
								</c:if>						
								<c:forEach var="rtnMap1" items="${rtnMap.OWE_DATA}" >
									${rtnMap1.OWE_DATA}<br>
								</c:forEach>
								<!--  [20250418]移除OWE_DATA11-通知訊息
								 ${rtnMap.OWE_DATA11}&nbsp;
								 -->
							 </td>
						   </tr>						   
						</table>					
					</td>
				</tr>
				<tr>
				  <td class="tbYellow2" colspan="3">
				  	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" id="tableE">
				  		<tr>
						  	<td class="tbYellow0" colspan="2" align="center"><b>【4】最後-列印貸款契約書套印連結&nbsp;<font color='red'>*請先下載填寫範例及待補資料後，才可下載貸款契約書*</font></b></td>
						</tr>
						<tr>
							<td class="tbYellow" width="10%" align="center">完整下載處</td>
							<td class="tbYellow2" width="90%">
								順序1：貸款契約書(填寫範例)(<a href='javascript:void(0)' onClick="doLinkGUAR_NOTICE('<c:out value="${rtnMap.APPLY_ID}"/>')"/>點我下載</a>)&nbsp;→&nbsp;
								順序2：待補資料
								<c:choose> 
									<c:when test="${rtnMap.isCheck02 eq 'Y'}">
										(<a href='javascript:void(0)' onClick="doDownloadAll('<c:out value="${rtnMap.APPLY_ID}"/>')"/>點我下載</a>)
									</c:when>
									<c:otherwise> 
										(無)
									</c:otherwise>
								</c:choose>
								&nbsp;→&nbsp;
								順序3：貸款契約書(<a href='javascript:void(0)' onClick="doLinkGUAR_CONTRACT('<c:out value="${rtnMap.APPLY_ID}"/>')"/>點我下載</a>)
								<input type='hidden' name="CHECK_01" APPLY_ID="${rtnMap.APPLY_ID}" value="${rtnMap.CHECK_01}"/>
								<input type='hidden' name="CHECK_02" APPLY_ID="${rtnMap.APPLY_ID}" value="${rtnMap.CHECK_02}"/>
								<input type='hidden' name="isCheck02" APPLY_ID="${rtnMap.APPLY_ID}" value="${rtnMap.isCheck02}"/>
							</td>
						</tr>
						<tr>
							<td class="tbYellow" align="center">單獨下載處(待補資料)</td>
							<td class="tbYellow2">
								<c:choose> 
									<c:when test="${rtnMap.isCheck02 eq 'Y'}">
										<c:if test="${not empty rtnMap.LINK}">
											補全${rtnMap.LINK_SEQ_NO}.<a href="javascript:void(0)" onClick="doSetPrint('<c:out value="${rtnMap.APPLY_ID}"/>', '<c:out value="${rtnMap.TYPE}"/>')"/>${rtnMap.LINK}</a>${rtnMap.MSG}
											<br>
										</c:if>	
										<c:if test="${rtnMap.A106_97 eq 'Y'}">
											補全${rtnMap.A106_97_SEQ_NO}.<a href="javascript:void(0)" onClick="doPrintFireChangeApply('<c:out value="${rtnMap.APPLY_ID}"/>')"/>${rtnMap.A106_97_NAME}</a>
											<br>
										</c:if>	
										<c:forEach var="rtnMap1" items="${rtnMap.OWE_DATA}" >
											<c:if test="${not empty rtnMap1.URL_LINK }">
												補全${rtnMap1.URL_LINK_SEQ_NO}.<a href="javascript:void(0)" onClick="doLinkOWE_DATA('<c:out value="${rtnMap.APPLY_ID}"/>','<c:out value="${rtnMap1.URL_LINK}"/>')"/>${rtnMap1.OWE_DATA2}</a>
												<br>
											</c:if>	
										</c:forEach>							
									</c:when>
									<c:otherwise> 
										(無)
									</c:otherwise>
								</c:choose>
							</td>
						</tr>						
				  	</table>
				  </td>
				</tr>
			</c:forEach>
		</table>
		<div id='dtlDiv' style="position: absolute; top: 0px; left: -2px; display:none" align='center'>
			<iframe src='' name='dtlFrame' width='99%' height='500' id='dtlFrame'></iframe>
		</div>
<!-- [20250219]新畫面無此區塊，SA註解
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" >
	<c:if test="${rtnMap.BANK_SECOND eq '1'}">
		<tr align="left">	
			<td class="tbYellow" align="center">搭配貸核准金額</td>					
			<td class="tbYellow" align="center">搭配貸核准利率</td>	
			<td class="tbYellow" align="center">搭配貸設定金額</td>
			<td class="tbYellow" align="center">搭配貸核准期數</td>
			<td class="tbYellow" align="center">搭配貸帳管費</td>															
		</tr>
		<tr align="left">							
			<td class="tbYellow2" align="center" ><fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.AGREE_AMT_B}" /></td> 									
			<td class="tbYellow2" align="center" ><c:out value="${rtnMap.BANK_SECOND_RATE}"/></td>									
			<td class="tbYellow2" align="center" ><fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.SET_AMT_B}" /></td>									
			<td class="tbYellow2" align="center" ><c:out value="${rtnMap.BANK_PERIOD}"/></td>		
			<td class="tbYellow2" align="center" ><fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.LOAN_EXPENSE_B}" /></td>		
		</tr>
	</c:if>
	<c:if test="${rtnMap.INSURANCE  eq '1' || rtnMap.INSURANCE  eq '2'}">
		<tr align="left">	
			<td class="tbYellow" align="center">
				<c:if test="${rtnMap.INSURANCE eq '2'}">
					建議投保有巢氏
				</c:if>
				<c:if test="${rtnMap.INSURANCE eq '1'}">
					有巢氏險種
				</c:if>
			</td>					
			<td class="tbYellow" align="center">增貸金額(萬)</td>	
			<td class="tbYellow" align="center">有巢氏投保金額(萬)</td>
			<td class="tbYellow" align="center">有巢氏投保年期(年)</td>
			<td class="tbYellow" align="center">有巢氏試算保費(元)</td>															
		</tr>
                                                                               <tr align="left">							
			<td class="tbYellow2" align="center" ><c:out value="${rtnMap.INSURANCE_KIND}"/></td> 									
			<td class="tbYellow2" align="center" ><fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.EXTRA_INSU}" /></td>									
			<td class="tbYellow2" align="center" ><fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.LIMIT_INSU}" /></td>									
			<td class="tbYellow2" align="center" ><c:out value="${rtnMap.INSU_YEAR}"/></td>		
			<td class="tbYellow2" align="center" ><fmt:formatNumber type="number" pattern="#,###" value="${rtnMap.INSU_PAYMENT}" /></td>		
		</tr>
		<tr align="left">							
			<td class="tbYellow" align="center" colspan="3">自投保成功後，次月起連續半年利率減碼(%)</td>	
			<td class="tbYellow" align="center" colspan="2"></td>	
		</tr>
		<tr align="left">							
			<td class="tbYellow2" align="center" colspan="3"><c:out value="${rtnMap.INSURANCE_ADJUST}"/></td> 									
			<td class="tbYellow2" align="center" colspan="2"></td>									
				
		</tr>
	</c:if>
</table>
 -->		
</body>
</html>
