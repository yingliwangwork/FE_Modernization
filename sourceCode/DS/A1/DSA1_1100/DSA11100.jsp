<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA11100.jsp
功能：房貸補全通知查詢

[20201130]修改件  外網多筆個資遮蔽  @author 何宗霖
[20240726]修改件 難字調整

 -->
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<script language="javascript" type="text/javascript">

var valid1;
<%--[20201130]外網多筆個資遮蔽--%>
var preTr;
var preBORROW_NAME_MASK;

var validateDate = function(){		
	if(diffDay($F('QUERY_STR_DATE'),$F('QUERY_END_DATE'), true) < 0)
		return false;
	return true;		
}

function initApp(){  
	PageUI.createPageWithAllBodySubElement("DSA11100" , "受理作業" , "房貸補全通知查詢", 1);
	PageUI.resize(true);	

	// 顯示執行結果
	displayMessage();
	
	// 查詢
	$("btn_query").observe('click',function(event){
		buttons.doQuery();
	});
	
	valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
	
	Validation.addAllThese([
		[ 'validateDate',  '終止日期需大於起始日期，請檢查後重新輸入查詢條件', validateDate]				
	]);	 

  	// 頁面 title 定位
	fix();	
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
		frm.action = "<%=dispatcher%>/DSA1_1100/query";
		frm.target = "";  
		submitOnce($('btn_query'));
	},
	<%--[20201130]外網多筆個資遮蔽_設置切換按鈕
	doHidden : function(sn){
		
		if(preTr===sn){
			return;
		}
		$("BORROW_NAME_MASK_"+sn).toggle();//自身隱藏/顯示
		$("BORROW_NAME_"+sn).toggle();//自身隱藏/顯示
		if(preTr || preTr===0){//上一筆暫存的資料
			$("BORROW_NAME_MASK_"+preTr).toggle();
			$("BORROW_NAME_"+preTr).toggle();
		}
		preTr = sn;
	}--%>
};

<%--
	轉大寫
--%>
function columnToUpperCase(columnName) {
	$(columnName).value = $(columnName).value.toUpperCase();
}

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0"
	marginheight="0" onLoad="initApp();" onResize="fix();"
	onScroll="fix();">

<form name="form1" id="form1" method="post" action="">
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td class="tbYellow" width="15%" align="left">補全日期</td>
		<td class="tbYellow2" width="30%">
			<input type="text" datatype="ROCDate" value="${QUERY_STR_DATE}" class="textBox2 required" size="10" maxlength="7" name="QUERY_STR_DATE" id="QUERY_STR_DATE" />
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('QUERY_STR_DATE'))">
			~
			<input type="text" datatype="ROCDate" value="${QUERY_END_DATE}" class="textBox2 required validateDate" size="10" maxlength="7" name="QUERY_END_DATE" id="QUERY_END_DATE" />
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('QUERY_END_DATE'))">
		</td>
		<td class="tbYellow" width="15%" align="left">受理單位</td>
		<td class="tbYellow2" width="30%">
			<input type="text" value="${DEPT}" class="textBox required" id="DEPT" name="DEPT" size="7" maxlength="5">
		</td>
		<td class="tbYellow2" align="left"><input type="button" name="btn_query" id="btn_query" class="button" value="查詢" /></td>
	</tr>
</table>

<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" id="List_A106">
	<c:forEach var="rtnMap" items="${rtnList}" varStatus="loop" >
		<tr align="left">
			<%--[20201130]外網多筆個資遮蔽_新增欄位 移除--%>
			<%--<td width="10%" class="tbYellow" align="center" >個資顯示</td>--%>
			<td width="18%" class="tbYellow" align="center" >受理編號</td>
			<td width="16%" class="tbYellow" align="center" >受理進度</td>
			<td width="17%" class="tbYellow" align="center" >借款人姓名</td>
			<td width="16%" class="tbYellow" align="center" >送件日期</td>																
			<td width="16%" class="tbYellow" align="center" >補全日期</td>																
			<td width="17%" class="tbYellow" align="center">經手人姓名</td>						
		</tr>
		<tr align="left">
			<%--[20201130]外網多筆個資遮蔽_新增欄位--%>
			<%--移除
			<td class="tbYellow2" align="center" >
				<button id='btn_hidden' type='button' class='button' onclick='buttons.doHidden(${loop.index})'>點我</button>
			</td>--%>
			<td class="tbYellow2" align="center" ><c:out value="${rtnMap.APPLY_ID}"/>-<c:out value="${loop.index}"/></td>									
			<td class="tbYellow2" align="center" ><c:out value="${rtnMap.APPLY_PROCESS_NM}"/></td>
			<%--[20201130]外網多筆個資遮蔽_改變欄位顯示--%>	
			<%--[20240726]難字調整--%>					
			<td class="tbYellow2" align="center"><span style="font-family:'EUDC'">${rtnMap.BORROW_NAME}</span>
				<%--<span id="BORROW_NAME_MASK_${loop.index}"><c:out value="${rtnMap.BORROW_NAME_MASK}"/></span>
				<span id="BORROW_NAME_${loop.index}" style="display:none"><c:out value="${rtnMap.BORROW_NAME}"/></span>--%>
			</td>										
			<td class="tbYellow2" align="center" ><cathay:calendar type="ROC" value="${rtnMap.SEND_DATE}" /></td>	
			<td class="tbYellow2" align="center" ><cathay:calendar type="ROC" value="${rtnMap.INPUT_DATE}" /></td>
			<%--[20240726]難字調整--%>		
			<td class="tbYellow2" align="center" ><span style="font-family:'EUDC'">${rtnMap.AGENT_NAME}</span></td>									
		</tr>
		<tr align="left">
			<td class="tbYellow" align="center">承辦科別</td>					
			<td class="tbYellow" align="center">承辦人員</td>								
			<td class="tbYellow" align="center">承辦人員電話</td>
			<td class="tbYellow" align="center" colspan="4">補全事項</td>
		</tr>
		<tr align="left">									
			<td class="tbYellow2" align="center" ><c:out value="${rtnMap.CRED_DEPT_NM}"/></td> 									
			<td class="tbYellow2" align="center" ><span style="font-family:'EUDC'">${rtnMap.EMP_NAME}</span></td>									
			<td class="tbYellow2" align="center" ><c:out value="${rtnMap.TEL_OFFICE}"/></td>		
			<td class="tbYellow2" colspan="4">
				<c:out value="${rtnMap.TOT_ITEM}" escapeXml="false"/>
				<font color="red">請儘速補全以上資料，以利案件審核</font>
			</td>
		</tr>
		<tr align="left">
		</tr>
		<tr align="left">
		</tr>
		<tr align="left">
			<td colspan="4"></br></td>
		</tr>
	</c:forEach>			
</table>
</form>


<div id='dtlDiv'
	style="position: absolute; top: 0px; left: -2px; visibility: hidden"
	align='center'><iframe src='' name='dtlFrame' width='99%'
	height='500' id='dtlFrame'></iframe></div>

</body>
</html>