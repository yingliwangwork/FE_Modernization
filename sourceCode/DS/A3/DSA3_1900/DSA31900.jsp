<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA31900.jsp
作者：謝雅筑
功能：轉電子地圖系統
完成：2012/05/25
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA31900().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31900(){
	
	var rtnMap;
	
	function doQueryOpen(){
		document.form1.action = 'http://${strElandUrl}/CathayLifeGISWeb/index.aspx';
		document.form1.target = "_self";
		document.form1.submit();
	}
	
	function doDirectOpen(){
		document.form1.action = 'http://${strElandUrl}/CathayLifeGISWeb/index.aspx';
		document.form1.target = "_blank";
		document.form1.submit();
	}
	
	return{                              
		initApp:function(){
			PageUI.createPage("DSA31900", "鑑價作業", "轉電子地圖系統", false);
			PageUI.loadin(["form1"] ,1);
			displayMessage();
			
			<c:if test="${not empty strElandUrl}"> //舊電子地圖
				if('${XML}'=='Y'){//接值.XML == ‘Y’
					doQueryOpen();
				}else{
					doDirectOpen();
				}
			</c:if>
			
			<c:if test="${not empty MapUrl}"> //新電子地圖
				/*if('${hasData}'=='Y'){
					window.open('${MapUrl}', "DSA3_1900");
					//popupWin.close();
				}else{
					window.open('${MapUrl}', "DSA3_1900");
				}*/
				<%--[20211020] 點擊電子地圖後，新開畫面自動顯示為最大化全螢幕--%>
				window.open('${MapUrl}','DSA3_1900','left=0,top=0,status=no,toolbar=no,menubar=no,scrollbars=yes,resizable=no,width='+window.screen.width+',height='+window.screen.height);
			</c:if>
		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >			
	<form id="form1" name="form1" method="post">
		<input name="USER_ID" type="hidden" value="${rtnMap.USER_ID}" />
		<input name="USER_NAME" type="hidden"  value="${rtnMap.USER_NAME}" />
		<input name="DIV_NO" type="hidden" value="${rtnMap.DIV_NO}" />
		<input name="DIV_NAME" type="hidden" value="${rtnMap.DIV_NAME}" />
		<input name="AUTH_TYPE" type="hidden" value="${rtnMap.AUTH_TYPE}" />
		<input name="APPLY_ID" type="hidden" value="${rtnMap.APPLY_ID}" />
		<input name="ADDR" type="hidden" value="${rtnMap.ADDR}" />
		<input name="ADDR2" type="hidden" value="${rtnMap.ADDR2}" />
		<input name="PREAPPR_NO" type="hidden" value="${rtnMap.PREAPPR_NO}" />
		<input name="PREAPPR_ADDR" type="hidden" value="${rtnMap.PREAPPR_ADDR}" />
		<input name="USE_FOR" type="hidden" value="${rtnMap.USE_FOR}" />
		<input name="TOTAL_FLOOR" type="hidden" value="${rtnMap.TOTAL_FLOOR}" />
		<input name="TARGET_FLOOR" type="hidden" value="${rtnMap.TARGET_FLOOR}" />
		<input name="BUILD_AGE" type="hidden" value="${rtnMap.BUILD_AGE}" />
		<input name="BUILD_MEASURE" type="hidden" value="${rtnMap.BUILD_MEASURE}" />
		<input name="LAND_MEASURE" type="hidden" value="${rtnMap.LAND_MEASURE}" />
	</form>
</body>
<!-- InstanceEnd -->
</html>