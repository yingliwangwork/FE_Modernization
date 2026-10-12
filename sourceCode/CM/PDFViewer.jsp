<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<%@taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core'%>
<%
	pageContext.setAttribute("contextPath", request.getContextPath());
%>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=BIG5"/>
    <title></title>
    <style type='text/css'>
    	.button {
			font-family: "新細明體";
			font-size: 10pt;
			background-image: url('${contextPath}/images/CM/bt_bg.gif');
			border: 1px solid #6B8D6D;
			color: #006600;
			height: 19px;
			margin: 2px 2px 0px;
			padding: 1px 2px 0px;		
		}
		
		.bottomDiv {
			border-top-width: 1px;	
			border-top-style: solid;
			border-top-color: 6B8D6D;
		}
    </style>
    <script type='text/javascript' src='${contextPath}/html/CM/js/ajax/prototype.js'></script>
	<script type='text/javascript' src='${contextPath}/html/CM/js/ajax/CSRUtil.js'></script>
    <script type='text/javascript' src='${contextPath}/html/CM/js/RPTUtil.js'></script>
    <script type='text/javascript'>
    	
    	function initApp() {
    		    	
			$('BTN_DOWNLOAD').observe('click', function() {	
				
				var isContinue = true;
				
				<c:forEach items='${URL_LIST}' var='obj'>
							
					if(isContinue) {
					
						isContinue = false;
								
						new Ajax.Request( '${obj.url}',
						{
							asynchronous : false,
							parameters: { actionParam : '${obj.parameters}'},
							onSuccess: function( response ) {
								var resp = response.responseJSON;
								if(CSRUtil.isSuccess(resp)){
									isContinue = true;									
								}
							}
						});					
					}		
				</c:forEach>
				
				if(isContinue) {
					
					RPTUtil.download({
						'downloadFileName': '${encryptMarkedFileName}',
						'downloadFileFullPath': '${encryptMarkedFileFullPath}'
					});
				}	
			});
    	}
    	
    </script>
    
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="initApp()">

<object width="99.9%" height="90%" classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93">
    <param name="type" value="application/x-java-applet"/>
    <param name="archive" value="icepdf-core.jar, icepdf-viewer.jar, icepdf-applet.jar"/>
	<param name="java_arguments" value="-Xmx128m"/>
    <param name="classloader_cache" value="false"/>
	<param name="url" value="${path}" />
    <param name="code" value="pdf/ViewerApplet"/>
    <param name="codebase" value="/ZRWeb/html/CM/applet/"/>
</object>
<div align='center' class='bottomDiv'>
	<input type='button' class='button' id='BTN_DOWNLOAD' value='下載' />
</div>

</body>

</html>