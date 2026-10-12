<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA31901.jsp
作者：周宏哲
功能：圖資平台系統
完成：2022/01/10
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
Event.observe(window, 'load', new DSA31901().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31901(){
	
	return{                              
		initApp:function(){
			PageUI.createPage("DSA31901", "鑑價作業", "圖資平台系統", false);
			displayMessage();		
			<c:if test="${not empty ARCGIS_MAP_URL}"> 
				window.open('${ARCGIS_MAP_URL}','DSA31901','left=0,top=0,status=no,toolbar=no,menubar=no,scrollbars=yes,resizable=no,width='+window.screen.width+',height='+window.screen.height);
			</c:if>
		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>
</script>
</head>

<!-- InstanceEnd -->
</html>