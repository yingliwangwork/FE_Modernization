<%@ page contentType="text/html; charset=Big5" %>
<%@ taglib uri="/CXL" prefix="CXL" %>
<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
                           cssBaseName="cssBase" 
                           imageBaseName="imageBase"
                           dispatcherName="dispatcher">

<%

	String functionId = (String) pageContext.getAttribute("functionId");
	String forwardUrl = (String) pageContext.getAttribute("forwardUrl");
	String DATASTR3 = (String) pageContext.getAttribute("DATASTR3");
	String sysID = functionId.substring(0, 2);

	//String forwardPageUrl = "/B2CPX/oc/"+functionId.substring(0,2)+dispatcher.substring(3, dispatcher.length())+"/"+forwardUrl;
	String forwardPageUrl = new com.cathay.aj.i0.module.AJ_I0Z006().getDispatcher(sysID, dispatcher) + "/" + forwardUrl;

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=Big5">
<title>國泰人壽</title>

</head>
<body  bgcolor="#FFFFFF">
<form id="form1" method="post" style="display:none" action="<%=forwardPageUrl%>">
<input type="hidden" name="DATASTR3" value="<%=DATASTR3%>" />
<input type="hidden" name="reCreateSession" value="Y" />
</form>
<script>
var f = document.getElementById('form1');
f.submit();
</script>
</body>
</html>

</CXL:csCommon>