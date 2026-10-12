<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA21800.jsp
作者：i9300623
功能：每日受理即時資訊查詢
完成：2011/10/26
更新：
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<title></title>
<%--共用定義的css--%>
<style>
	.blueColor{
		color: blue;
		background-color: #DEC87C;
		text-align:center;
	}
</style>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<%--自行定義的javaScript--%>
<script type="text/JavaScript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var valid;
function initApp(){
	displayMessage();
	
	PageUI.createPageWithAllBodySubElement("DSA21800" , "核貸作業" , "每日受理即時資訊查詢", 1);
		
	ValidationFunction.init();
	new UI().init(); 
	
	PageUI.resize(true);
}

function UI(){                
	return{
		init:function(){
			//查詢                    
			$('btn_query').observe('click',function(event){
					doAction.doQuery();					
				}
			);
		}                 
	}
}
//---------------------------------按鈕功能---------------------------------
var doAction = {
	//查詢
	doQuery : function(){
		valid.reset();
		if( !valid.validate() ) {return;}
		new Ajax.Request( '<%=dispatcher%>/DSA2_1800/query',
    	{ 	
	    	parameters:  { 'QRY_DATES':$F('QRY_DATES'),'QRY_DATEE':$F('QRY_DATEE'),'CRED_DEPT':$F('CRED_DEPT')}, 	    	
	        onSuccess: function(XHT, resp){
	        	var spans = $('grid').select('span');
				if(CSRUtil.isSuccess(resp)){
					var rtnMap=resp.rtnMap;
					spans.each(function(it){
						var span_id = it.id.toUpperCase();
						var span_len=span_id.length;
						if (span_len > 4 && span_id.endsWith('_TXT')){
							var v = rtnMap[it.id.substr(0,span_len-4)];
							if(Object.isUndefined(v)) return;				
							
							it.innerHTML = CSRUtil.$fmt(v,'#,###');
						}
					});
					$('dataTitle').innerHTML=$F('QRY_DATES')+'~'+$F('QRY_DATEE')+'國壽案件即時資訊';
				}else{
		 			spans.each(
						function(ele){
							ele.innerHTML='&nbsp;';
						}
					);	
					$('dataTitle').innerHTML='國壽案件即時資訊';
		 		}
	        }
	    });
	}
};
//------------------------------------------------------------------
//***
//所有頁面檢核相關方法
//***
var ValidationFunction = {
	//資料檢核
	init : function(){
		valid  = new Validation('form1',{useTitles:true} );
		Validation.addAllThese( [
			[ 'validateDate1', '日期迄日不可小於起日',	function(v){ return ValidationFunction.validateDate( $F('QRY_DATES'), v); }]
			,[ 'validateROC', '請輸入正確日期格式', function(v){ return ValidationFunction.validateROC(v); }]
		] );
	}
	//檢核日期是否符合民國年月日格式
	,validateROC : function(v){
		return (v) ? isROCdate(v) : true;
	}
	// 檢核日期迄日是否大於起日
	,validateDate : function (STR_DT, END_DT){
		if(STR_DT && END_DT){
			return diffDayROC(STR_DT, END_DT)<0?false:true;
		}else{
			return true;
		} 
	}
};
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
<form id="form1" name="form1" method="post">
<table width="100%" class="tbBox2" border="0" cellspacing="1" cellpadding="0">
		<tr>
			<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
					<tr>
						<td class="tbYellow" width="8%">查詢日期</td>
						<td class="tbYellow2" width="30%">
							<input type="text" datatype="ROCDate" value="${CURRENT_DATE}" class="textBox2 required validateROC" size="10" maxlength="7" name="QRY_DATES" id="QRY_DATES" fieldName="查詢日期(起)"/>
							<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('QRY_DATES'))">
							~
							<input type="text" datatype="ROCDate" value="${CURRENT_DATE}" class="textBox2 required validateROC validateDate1" size="10" maxlength="7" name="QRY_DATEE" id="QRY_DATEE" fieldName="查詢日期(迄)"/>
							<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('QRY_DATEE'))">
						</td>
						<td class="tbYellow" width="8%">承辦科別</td>
						<td class="tbYellow2" width="25%">
							<select class="textBox2" name="CRED_DEPT" id="CRED_DEPT">
                              <option value=""></option>													
                              <c:forEach var="map" items="${DEPT_LIST}">
                                <option value="${map.key}">${map.value}</option>
                              </c:forEach>
                            </select>
						</td>
						<td class="tbYellow2" width="29%">
							<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
						</td>
					</tr>
				</table>
				<table class="tbBox2" border="0" cellSpacing=1 cellPadding=0 width="100%" id="grid">
					<tr>
						<td class="blueColor" colspan="4" nowrap><span id="dataTitle">國壽案件即時資訊</span></td>
					</tr>
					<tr align="center">
						<td class="tbYellow" width="20%" nowrap>送件件數</td>
						<td class="tbYellow" width="20%" nowrap>送件件數-影像件</td>
						<td class="tbYellow" width="20%" nowrap>送件件數-非影像件</td>
						<td class="tbYellow" width="20%" nowrap>送件件數-行動受理件</td>
					</tr>
					<tr align="right">
						<td class="tbYellow2" nowrap><span id="LIFE_CNT_TXT">&nbsp;</span></td>
						<td class="tbYellow2" nowrap><span id="AV_CNT_TXT">&nbsp;</span></td>
						<td class="tbYellow2" nowrap><span id="DP_CNT_TXT">&nbsp;</span></td>
						<td class="tbYellow2" nowrap><span id="APP_CNT_TXT">&nbsp;</span></td>
					</tr>
					<tr align="center">
						<td class="tbYellow" nowrap>鑑價覆核件數</td>
						<td class="tbYellow" nowrap>核准件數</td>
						<td class="tbYellow" nowrap>匯款件數</td>
						<td class="tbYellow"></td>
					</tr>
					<tr align="right">
						<td class="tbYellow2" nowrap><span id="LIFE_APPR_CNT_TXT">&nbsp;</span></td>
						<td class="tbYellow2" nowrap><span id="AGREE_CNT_TXT">&nbsp;</span></td>
						<td class="tbYellow2" nowrap><span id="REMIT_CNT_TXT">&nbsp;</span></td>
						<td class="tbYellow2"></td>
					</tr>
				</table>
			</td>
		</tr>
</table>
</form>	
</body>
</html>
