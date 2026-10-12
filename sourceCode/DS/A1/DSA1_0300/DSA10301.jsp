<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<fmt:setBundle basename="TextResource" />
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<link rel="stylesheet" href="${htmlBase}/DS/skeletons/orgChart/css/jquery.orgchart.css">
<script type="text/JavaScript" src="${htmlBase}/CM/js/jquery/jquery-3.6.0.js"></script>
<script type="text/javascript" src="${htmlBase}/DS/skeletons/orgChart/js/jquery.orgchart.js"></script>
<script type="text/javascript">

var DSA10301 = new DSA10301();

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
//Event.observe(window, 'load', DSA10301.initApp );
$( document ).ready(DSA10301.initApp);

//以下為UI() public method,放在 return 中
function DSA10301(){
	
	return {			
		initApp : function() {
			$('#chart-container').orgchart({
		      'data' : <c:out value="${treeData}" escapeXml="false" default="{}"/>,
		      'nodeContent': 'title',
		      'direction': 'b2t'
		    });
			alertMessages();
		}// end initApp()
	};// end return-
}	

</script>
</head>
<body>
	<div id="radioList">
		<span>股東持股比例計算結果：</span><br>
		<span id="radios">
		<c:set var='isFirstL' value="${true}"/>
		<c:forEach var="A035Map" items="${A035List}" varStatus="loop">
			<c:if test='${A035Map.LEVEL eq "L"}'>
				<c:if test='${isFirstL ne true}'>，</c:if>
				<c:set var='isFirstL' value="${false}"/>
				${A035Map.NAME}:${A035Map.HOLDING_RATIO}%
			</c:if>
		</c:forEach>
		</span>
	</div>
	<div id="chart-container"></div>
</body>
</html>