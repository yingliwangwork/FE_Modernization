<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">

<%@ include file="/html/CM/header.jsp"%>
<%@ page import="java.lang.*" %>
<%@ page import="com.igsapp.wibc.dataobj.Context.ResponseContext" %>
<%@ page import="com.cathay.common.util.*"%>

<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%
/*取得ResponseContext物件*/
	ResponseContext resp = (ResponseContext)request.getAttribute("$Attribute.responseContext");

/*取得代理人*/
%>

<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script>
<!--
function doAction() {
	docum = document.form1;
	docum.action = "<%=dispatcher%>/login/selectUnit";
	docum.submit();
}

function stat(){
	var a = pageYOffset+window.innerHeight-document.getElementById('bar1').height-15;
	document.getElementById('bar1').top = a;
	setTimeout('stat()',2);
}

function fix(){
	nome=navigator.appName;
	if(nome=='Netscape'){
		stat();
	}
	else{
		var a=document.body.scrollTop-document.getElementById('bar1').offsetHeight+30;
		document.getElementById('bar1').style.top = a;
	}
}
//-->
</script>

</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad='displayMessage();'>
<center>
<span id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility: visible;" >
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
    <td valign="top" bgcolor="#F0FBC6"> <table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
        <tr>
          <td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
        </tr>
      </table>

      <table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
        <tr>
          <td width="20" height="24"> <div align="center"><font size="-5">●</font></div></td>
          <td><b>登入作業－兼職單位切換</b></td>
          <td>
            <div align="right">畫面編號： </div></td>
        </tr>
      </table>
      <!-- InstanceEndEditable --></td>
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
    <td width="100%" valign="top" bgcolor="#F0FBC6">
    <!-- InstanceBeginEditable name="content" -->
      <table width="500" border="0" cellpadding="0" cellspacing="0" align="center">
        <tr>
          <td valign="top"> <table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
              <tbody>
                <tr>
                  <td class="tbBox2"> <img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">單位選單</td>
                </tr>
                <tr bgcolor=#FFFFFF>
                  <td><table width="100%" border="0" cellspacing="0" cellpadding="5">
                      <tr>
                        <td>
                          <form name="form1" method="post" action="">
	                        <input name='div_no' type='hidden' value="">
                            <input name='div_name' type='hidden' value="">
                            <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
                              <tr>
                                <td width="15%" class="tbYellow">登入人員

                                </td>
                                <td width="35%" class="tbYellow2">${userName}</td>
                              </tr>
                            </table>
                            <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
                              <tr class="tbBlue">
                              	<td width='40'> </td>
                                <td><div align="center">公司名稱</div></td>
                                <td><div align="center">單位名稱</div></td>
                                <td><div align="center">單位代號</div></td>
                              </tr>
                              <c:forEach var="divs" items="${userDivList}" varStatus="status" >
                              <TR class='<cathay:even>tbYellow2</cathay:even><cathay:odd>tbBlue3</cathay:odd>' align='center'>
                                <td><input type="radio" name='DIV_NO' value='${divs.COMP_CODE},${divs.DIV_NO}' <c:if test="${divs.DIV_NO==defaultDivNo}">checked</c:if>></td>
                                <td>${divs.COMP_NAME}</td>
                                <td>${divs.DIV_NM}</td>
                                <td>${divs.DIV_NO} (${divs.COMP_CODE})</td>
                              </tr>
                              </c:forEach>
                            </table>
                            <p align="center">
                              <input name="btn_sumnit" type="button" class="button" value="確定" onClick="doAction()">
                              <input name='eBAF_loginPlatformInfo' type="hidden" value='${eBAF_loginPlatformInfo}'>
                              <input name='loginPlatform' type="hidden" value='${loginPlatform}'>
                            </p>
                          </form></td>
                      </tr>
                    </table></td>
                </tr>
              </tbody>
            </table>
            <div align="center"><br>
            <table width='100%'><tr><td>

         </td></tr></table>
            </div></td>
        </tr>
      </table>
    <!-- InstanceEndEditable -->
    </td>
    <td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
    <td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  </tr>
</table>

</body>
<!-- InstanceEnd -->
<!-- show error msg -->
</html>
