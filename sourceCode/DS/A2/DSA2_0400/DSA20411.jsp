<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />



<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<style>
	.watermarks{
		left: 160px;
		-ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=10)";
		filter: alpha(opacity=10);
		color: #F0F0F0;
		color: rgba(0, 0, 0, 0.1); 
		letter-spacing: 5pt; 
		font-size: 500%; 
		position: absolute; 
		z-index: -1;
	}
</style>

<script type="text/JavaScript">
function wm(msg){
	var i=0;
	var	str="";

	var tH=lastone1.offsetTop;
	var iT=tH/300+1;
	if(iT<1) iT=1;
	

	for(iO=1;iO<=iT;iO++){
		//20190329 林孟平	聯徵中心規定要套浮水印
		str=str + '<p class="watermarks" style="position:absolute;top:'+(300*iO) + 'px;">' + msg + '</p>';
	}
	//alert(str);
	document.getElementById("wm1test").innerHTML=str;
	//document.getElementByID("wm1test").innerHTML=str;
}
</script>

</head>

 <body bgproperties="fixed"  onload="wm('${user}')"   background="<%=request.getContextPath()%>/images/watermark.gif" oncontextmenu="window.event.returnValue=false" ondragstart="return false" onselectstart="return false">
 	<div id="wm1test"></div>							
	<c:if test="${not empty rtnMap}">
		${rtnMap}
	</c:if>
	<c:if test="${ empty rtnMap}">
		找不到資料
	</c:if>
	<div id="lastone1" ></div>
 </body> 

</html>