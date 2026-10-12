<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSB40210.jsp
作者：李俊德
功能：匯款審核進度查詢
完成：
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>

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
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSB40210().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);



//--------------------------------------------------------------------------
//	以下為DSB40210() public method,放在 return 中
//--------------------------------------------------------------------------  
function DSB40210(){

	var actions = {
		// 上一頁
		doBack : function(){
			CSRUtil.linkBack();
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSB40210" , "匯款進度", "匯款進度查詢" );
			
			$('btn_back').observe('click', actions.doBack ); // 上一頁按鈕		

			displayMessage();
			
			<c:if test="${not empty rtnMap}">
			
				var rtn = '${rtnMap}'.evalJSON();
				
				$w('INPUT_NM CRED_LEADER_NM LOAN_LEADER_NM FAIL_INPUT_NM ACNT_NO USER_TRN_SERNO SLIP_SET_NO').each( 
					function(col){
						$(col).innerHTML = rtn[col] || '';
					}
				);
				
				$w('INPUT_DATE CRED_LEADER_DATE LOAN_LEADER_DATE FAIL_INPUT_DATE ACNT_DATE').each( 
					function(col){
						$(col).innerHTML = rtn[col] ? Date.toROC(rtn[col]) : '';
						
					}
				);
				
				parseEUDC('ap');

			</c:if>		
			
		}// end initApp()--
	}// end return--
}// end DSB40210

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form name="form1" id="form1" method="post">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >			
			<tr align="center">
				<td width="12%" class="tbYellow">匯款資料輸入人員</td>
				<td width="13%" class="tbYellow2">
					<span id="INPUT_NM" style="font-family:'EUDC'"></span>
				</td>		
				<td width="12%" class="tbYellow">匯款資料輸入日期</td>
				<td width="13%" class="tbYellow2" id="INPUT_DATE"></td>
				<td width="12%" class="tbYellow">新放匯款初審人員</td>
				<td width="13%" class="tbYellow2">
					<span id="CRED_LEADER_NM" style="font-family:'EUDC'"></span>
				</td>
				<td width="12%" class="tbYellow">新放匯款初審日期</td>
				<td width="13%" class="tbYellow2" id="CRED_LEADER_DATE"></td>
			</tr>
			<tr align="center">
				<td width="12%" class="tbYellow">匯款檢核輸入人員</td>
				<td width="13%" class="tbYellow2">
					<span id="LOAN_LEADER_NM" style="font-family:'EUDC'"></span>
				</td>
				<td width="12%" class="tbYellow">匯款檢核輸入日期</td>
				<td width="13%" class="tbYellow2" id="LOAN_LEADER_DATE"></td>
				<td width="12%" class="tbYellow">退匯輸入人員</td>
				<td width="13%" class="tbYellow2" id="FAIL_INPUT_NM">
					<span id="FAIL_INPUT_NM" style="font-family:'EUDC'"></span>
				</td>
				<td width="12%" class="tbYellow">退匯輸入日期</td>
				<td width="13%" class="tbYellow2" id="FAIL_INPUT_DATE"></td>
			</tr>
			<tr align="center">
				<td width="12%" class="tbYellow">結帳日期</td>
				<td width="13%" class="tbYellow2" id="ACNT_DATE"></td>
				<td width="12%" class="tbYellow">結帳序號</td>
				<td width="13%" class="tbYellow2" id="ACNT_NO"></td>
				<td width="12%" class="tbYellow">經辦交易序號</td>
				<td width="13%" class="tbYellow2" id="USER_TRN_SERNO"></td>
				<td width="12%" class="tbYellow">傳票組號</td>
				<td width="13%" class="tbYellow2" id="SLIP_SET_NO"></td>
			</tr>
			<tr align="center">
				<td colspan="8"><input type="button" id="btn_back" value="上一頁" class="button"></td>
			</tr>
		</table>
	</form>
</body>
</html>
