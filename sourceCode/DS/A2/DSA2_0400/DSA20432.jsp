<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--
程式：DSA20432.jsp
作者：蘇敬友
功能：公務機關授權書預覽
完成：
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="BIG5"/>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css" />

<title></title>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<script type="text/javascript">

Event.observe(window, 'load', new DSA20432().initApp);
function DSA20432(){
	
	return{
		initApp:function(){
			var filePath = "${filePath}" ; 
			var dataMap = {
					 'encryptTempFileFullPath': filePath
					};
			RPTUtil.executeSecurityPrintHandler(dataMap,false);
		}
		};
}
</script>
</html>