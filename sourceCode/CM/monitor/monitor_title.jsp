<%@ page contentType="text/html; charset=Big5" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ taglib uri="/CXL" prefix="CXL" %>
<%@ taglib uri="/jstl-c" prefix="c" %>

<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
                           cssBaseName="cssBase" 
                           imageBaseName="imageBase"
                           dispatcherName="dispatcher">
<%

	String strSysCode = request.getParameter("syscode");
	String strSysName = request.getParameter("sysname");
	String strRefresh = request.getParameter("refresh");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script>
function refresh_info(){
	parent.frame_<%=strSysCode%>.location="/<%=("ZZ".equals(strSysCode)?"CXL":strSysCode)%>Web/html/CM/monitor/monitor_info.jsp?syscode=<%=strSysCode%>&sysname=<%=strSysName%>&refresh=<%=strRefresh%>";
}
</script>
</head>

<body bgcolor="#F0FBC6"  leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
<center>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td valign="top" bgcolor="#F0FBC6">
    <table width="100%" border="0" cellpadding="2" cellspacing="0" >
      <tr> 
        <td style='font-size:12pt;color:#006600;'' class="tbBox3" style='cursor:pointer' onclick='refresh_info()'><B>　<%=strSysCode%>「<%=strSysName%>」</B></td>
      </tr>
    </table>
    </td>
  </tr>
</table>

</body>
</html>
</CXL:csCommon>