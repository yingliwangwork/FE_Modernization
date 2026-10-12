<%@ page contentType="text/html; charset=Big5" %>
<%@ include file="/html/CM/header.jsp" %>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=Big5">
<title>國泰人壽</title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
</head>
<body  bgcolor="#F0FBC6">
<script language="JavaScript" type="text/JavaScript">
	displayMessage();
	<c:choose>
		<c:when test="${showError eq 'Y'}">
			top.location = "<%=htmlBase%>/CM/login.jsp";
		</c:when>
		<c:when test="${not empty url}">
			var url = top.location.href;
			url = url.substring(0, url.indexOf('/ZZWeb')) + '${url}';		
			top.location = url;
		</c:when>
		<c:otherwise>
			top.location = "<%=dispatcher%>/SysLogout/main";
		</c:otherwise>
	</c:choose>

</script>
</body>
</html>