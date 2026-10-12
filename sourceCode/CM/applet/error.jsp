<%@page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%><!doctype HTML>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <meta charset="big5">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <meta name="google" content="notranslate">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Error</title>
    
</head>

<body>
	<h1>${errorType}</h1>
	<span><c:out value="${errorMessage}" /></span>
	<hr/>
	<button type="button" id="back" onclick="((history.length > 1) ? history.back() : window.close() );">&nbsp;&nbsp;back&nbsp;&nbsp;</button>
	<script>
		history.replaceState && history.replaceState('', '', 'Error');
	</script>
</body>

</html>