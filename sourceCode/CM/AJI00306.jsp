<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="com.cathay.aj.i0.bo.*"%>
<%@ page import="com.cathay.aj.i0.module.AJ_I0Z011"%>

<%

	 //取出 trx addOutputData 中的值
	HttpResponseContext resp = new HttpResponseContext(request);

	//取出自 trx putValue 中的值
	HttpTxContext txCxt = new HttpTxContext(session);

	//組成FORMAT(A)
	AJI0_0331_bo AJI0_0331_vo = resp.getOutputData("AJI0_0331_vo") == null ? new AJI0_0331_bo() : (AJI0_0331_bo)resp.getOutputData("AJI0_0331_vo");
	//組成FORMAT(B)
	AJI0_0332_bo AJI0_0332_vo = resp.getOutputData("AJI0_0332_vo") == null ? new AJI0_0332_bo() : (AJI0_0332_bo)resp.getOutputData("AJI0_0332_vo");
	//組成FORMAT(C)
	List AJI0_0333_voList = resp.getOutputData("AJI0_0333_voList") == null ? Collections.EMPTY_LIST : (List)resp.getOutputData("AJI0_0333_voList");
	//組成FORMAT(D)
	List AJI0_0334_voList = resp.getOutputData("AJI0_0334_voList") == null ? Collections.EMPTY_LIST : (List)resp.getOutputData("AJI0_0334_voList");
	//colspan
	String colspan = resp.getOutputData("colspan") == null ? "1" : (String)resp.getOutputData("colspan");

	//友善列印
	String PRINT_BTN_DISABLED = StringUtils.isBlank(AJI0_0331_vo.getTRANS_NO()) ? "disabled" : "";

	//交易代號
	String TRAN_ID = txCxt.getValue("TRAN_ID") == null ? "" : (String)txCxt.getValue("TRAN_ID");
	//會員生日
	String ROLE_BRDY = txCxt.getValue("ROLE_BRDY") == null ? "" : (String)txCxt.getValue("ROLE_BRDY");

	//交易名稱
	String TRAN_NAME = txCxt.getValue("TRAN_NAME") == null ? "" : (String)txCxt.getValue("TRAN_NAME");


	pageContext.setAttribute("AJI0_0331_vo", AJI0_0331_vo);
	pageContext.setAttribute("AJI0_0332_vo", AJI0_0332_vo);
	pageContext.setAttribute("AJI0_0333_voList", AJI0_0333_voList);
	pageContext.setAttribute("AJI0_0334_voList", AJI0_0334_voList);
	pageContext.setAttribute("colspan", colspan);

	pageContext.setAttribute("TRAN_ID", TRAN_ID);
	pageContext.setAttribute("TRAN_NAME", TRAN_NAME);//jstl使用
	pageContext.setAttribute("ROLE_BRDY", ROLE_BRDY);
	pageContext.setAttribute("PRINT_BTN_DISABLED", PRINT_BTN_DISABLED);

%>

<!-- saved from url=(0022)http://internet.e-mail -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><!-- InstanceBegin template="/Templates/B2C.dwt" codeOutsideHTMLIsLocked="false" -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=Big5">
<!-- InstanceBeginEditable name="doctitle" --><title></title><!-- InstanceEndEditable -->
<style type="text/css">
<!--

-->
</style>

<link href="<%=cssBase%>/B2C_cm.css" rel="stylesheet" type="text/css">

<!-- InstanceBeginEditable name="head" -->
<!-- InstanceEndEditable -->
</head>

<body bgcolor="#ffffff" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad='initApp()'>

<script src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script src="<%=htmlBase%>/CM/js/pageController.js"></script><!--頁碼-->

<%@ include file="/html/CM/msgDisplayer.jsp" %><!--執行結果顯示-->

<script>

//------------------------------------------------------------------------------
<!--控制 div 隱藏顯示-->
function mask(szLayer){
	if(document.getElementById(szLayer).style.visibility == "hidden"){
		document.getElementById(szLayer).style.visibility = "visible";
		setErr_Layer();
	}else{
		document.getElementById(szLayer).style.visibility = "hidden";
		setErr_Layer();
	}
}

//------------------------------------------------------------------------------
function setErr_Layer(){
	var Err_Layer = document.getElementById('Err_Layer');

	if(Err_Layer.style.visibility == "visible"){
		Err_Layer.style.width = document.body.clientWidth + "px" ;
		Err_Layer.style.height = document.body.clientHeight + "px" ;
		Err_Layer.style.left = (document.body.clientWidth/2)-100 + "px" ;
		Err_Layer.style.top = (document.body.clientHeight/2)-50 + "px" ;
	}else{
		var Err_Layer = document.getElementById('Err_Layer');
		Err_Layer.style.width = "0px" ;
		Err_Layer.style.height = "0px" ;
		Err_Layer.style.left = "0px" ;
		Err_Layer.style.top = "0px" ;
	}
}

function doPopup(){
	var Err_Layer_MSG = document.getElementById('Err_Layer_MSG');
	Err_Layer_MSG.innerHTML = " <span class='textOrange'> 感謝您使用本系統 </span> ";
	mask('Err_Layer');
}
</script>


<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">

</table>

<form name="form1" method="post">

<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="100%" valign="top" bgcolor="#FFFFFF">
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="top"><!-- InstanceBeginEditable name="EditRegion2" -->
            <table width="97%" border="0" cellpadding="0" cellspacing="1">
              <tr>
                <td><table width="100%" height="57" border="0" cellpadding="0"  background="<%=imageBase%>/CM/B2C/STEP_bg.gif" cellspacing="0" id="Table_01">
                  <tr>
                    <td><img src="<%=imageBase%>/CM/B2C/STEP_01.gif" width="23" height="57" alt=""></td>
                    <td align="center"><img src="<%=imageBase%>/CM/B2C/AJI0/STEP_1g.gif" width="120" height="40"></td>
                    <td><img src="<%=imageBase%>/CM/B2C/STEP_05.gif" width="23" height="57" alt=""></td>
                    <td align="center"><img src="<%=imageBase%>/CM/B2C/AJI0/STEP_2g.gif" width="120" height="40"></td>
                    <td><img src="<%=imageBase%>/CM/B2C/STEP_05.gif" width="23" height="57" alt=""></td>
                    <td align="center"><img src="<%=imageBase%>/CM/B2C/AJI0/STEP_3g.gif" width="120" height="40"></td>
                    <td><img src="<%=imageBase%>/CM/B2C/STEP_05.gif" width="23" height="57" alt=""></td>
                    <td align="center"><img src="<%=imageBase%>/CM/B2C/AJI0/STEP_4.gif" width="120" height="40"></td>
                    <td align="right"><img src="<%=imageBase%>/CM/B2C/STEP_11.gif" width="21" height="57" alt=""></td>
                  </tr>
                </table></td>
              </tr>
              <tr>
                <td align="right">&nbsp;</td>
              </tr>
            </table>

          <!-- print -->
          <div id="Display">
          <!--
            <table width="97%" border="0" cellpadding="0" cellspacing="1">
              <tr>
                <td>&nbsp;</td>
                <td align="right">&nbsp;</td>
              </tr>
              <tr>
                <td><span class="textContainTitle"><img src="<%=imageBase%>/CM/B2C/icon_1.gif" width="15" height="13">保單基本資料</span></td>
                <td align="right">&nbsp;</td>
              </tr>
              <tr>
                <td colspan="2" align="right"><span class="textDate"><%=AJ_I0Z011.formatDate()%></span></td>
              </tr>
            </table>
			 -->
            <jsp:include page="/html/AJ/I0/AJI0_0303/AJI00303.jsp"/>

            <table width="97%" border="0" cellpadding="0" cellspacing="1">
              <tr>
                <td>&nbsp;</td>
                <td align="right">&nbsp;</td>
              </tr>
              <tr>
                <td><span class="textContainTitle"><img src="<%=imageBase%>/CM/B2C/icon_1.gif" width="15" height="13">交易明細資料</span></td>
                <td align="right">&nbsp;</td>
              </tr>

            </table>
            <table class="tbBox2" border="0" cellpadding="0" cellspacing="1" width="97%">
              <tbody>
                <tr>
                  <td width="10%" class="tbGray" >保單號碼</td>
                  <td class="tbWhite" ><c:out value="${AJI0_0331_vo.POLICY_NO}"/></td>
                  <td width="10%" class="tbGray" >要保人ID</td>
                  <td colspan="3" class="tbWhite" ><c:out value="${AJI0_0331_vo.ID}"/></td>
                </tr>
                <tr>
                  <td class="tbGray" >交易時間</td>
                  <td class="tbWhite" ><c:out value="${AJI0_0331_vo.BGN_TIME}"/></td>
                  <td class="tbGray" >交易編號</td>
                  <td class="tbWhite" ><c:out value="${AJI0_0331_vo.TRANS_NO}"/></td>
                  <td width="10%" class="tbGray" >交易種類</td>
                  <td class="tbWhite" ><c:out value="${AJI0_0331_vo.TRAN_NAME}"/></td>
                </tr>
              </tbody>
            </table>

            <table class="tbBox2" border="0" cellpadding="0" cellspacing="1" width="97%">

              <tr class="tbWhite">
                <td colspan="<c:out value='${colspan}'/>" class="textOrange" >交易(變更)前</td>
              </tr>
              <%
			     			     for(int i=0; i<AJI0_0333_voList.size(); i++){

			     			     	if(i==0){	%>
			     			     		<tr class='tbGray'>
			     			     	<%}else if(i%2==0){%>
			     			     		<tr class='tbYellow2'>
			     			     	<%}else{%>
			     			     		<tr class='tbWhite'>
			     			     	<%
			     			     	}

			     			     	List aList = (List)AJI0_0333_voList.get(i);

			     			     	for(int j=0; j<aList.size(); j++){
			     			     	%>
			     			     		<td><%=aList.get(j)%>
			     			     	<%
			     			     	}

			     			     }
			     			      %>

              <tr class="tbWhite">
                <td colspan="<c:out value='${colspan}'/>" class="textOrange" >交易(變更)後</td>
              </tr>

                            <%
			     			     for(int i=0; i<AJI0_0334_voList.size(); i++){

			     			     	if(i==0){	%>
			     			     		<tr class='tbGray'>
			     			     	<%}else if(i%2==0){%>
			     			     		<tr class='tbYellow2'>
			     			     	<%}else{%>
			     			     		<tr class='tbWhite'>
			     			     	<%
			     			     	}

			     			     	List aList = (List)AJI0_0334_voList.get(i);

			     			     	for(int j=0; j<aList.size(); j++){
			     			     	%>
			     			     		<td><%=aList.get(j)%>
			     			     	<%
			     			     	}

			     			     }
			     			      %>

                <tr class="tbWhite">
                  <td colspan="3" class="textOrange" >
				  <c:out escapeXml="false" value="${AJI0_0331_vo.MEMO}"/>
                </tr>

              </tbody>
            </table>

            </div>

            <div class="text10"></div>
							<div align="center">
								<input type="button" class="button" name="btn_print" value="友善列印" onClick="doPrint()" <c:out value="${PRINT_BTN_DISABLED}"/>/>
								<input type="button" class="button" name="btn_prev" value="我要變更其他保單" onClick="doPrev(this)"/>
			  				</div>
          <!-- InstanceEndEditable --></td>
        </tr>
      </table>
     </td>
  </tr>
</table>

<input type="hidden" name="TRAN_ID"/>
<input type="hidden" name="ROLE_BRDY"/>

</form>
<script>

	var frm=document.form1;

	//初始化
	function initApp(){

		//validator = new Validator();
		displayMessage();

	}

	//友善列印
	function doPrint(){

		window.open('<%=htmlBase%>/AJ/I0/AJI0_0306/AJI00306_print.jsp','_blank','width=800,height=480,scrollbars=1,menubar=1,status=1');

	}

	//我要變更其他保單
	function doPrev(btn){

		frm.TRAN_ID.value="<c:out value='${TRAN_ID}'/>"
		frm.ROLE_BRDY.value="<c:out value='${ROLE_BRDY}'/>"

		frm.action="<%=dispatcher%>/AJI0_0300/query";

		submitOnce(btn);

	}

</script>
</body>
<!-- InstanceEnd --></html>
