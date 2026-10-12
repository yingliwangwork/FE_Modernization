<%@page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%><!DOCTYPE HTML>
<%@taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core'%>
<%
	pageContext.setAttribute("contextPath", request.getContextPath());
	String currentURL = request.getRequestURL().toString();
	int idx = currentURL.lastIndexOf("/");
	String jnlpCodebase = currentURL.substring(0, idx);
	// jnlpCodebase = jnlpCodebase.replace("http:","https:");
%>
<html>
<head>
    <meta charset="big5">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <meta name="google" content="notranslate">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>TIFF VIEWER</title>
    <style type='text/css'>
    	.button {
			font-family: 'PMingLiU','MingLiU';
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
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
	<center>
		<p>
			<input id="jpln_btn" type="button" class="button" value="嘗試再次啟動瀏覽視窗" />
			<c:if test="${ENABLE_DOWNLOAD}">
			&nbsp;&nbsp;<input id="download_btn" type="button" class="button" value="下載  ${fileName} 至本機" />
			<script type='text/javascript' src='${contextPath}/html/CM/js/ajax/prototype.js'></script>			
			<script type='text/javascript' src='${contextPath}/html/CM/js/ajax/CSRUtil.js'></script>
			<script type='text/javascript' src='${contextPath}/html/CM/js/RPTUtil.js'></script>
		    <script type='text/javascript'>
		    $('download_btn').addEventListener('click', function(e) {	
				<c:forEach items='${URL_LIST}' var='obj'>
				var isContinue = false;
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
				if(!isContinue){ return; }
				</c:forEach>
			   	<c:choose><c:when test="${isWindowOpen}">
				window.open("${filePath}");
		       	</c:when><c:otherwise>
				RPTUtil.download({'downloadFileName': '${encryptMarkedFileName}','downloadFileFullPath': '${encryptMarkedFileFullPath}'});
				</c:otherwise></c:choose>
			});
			</script>
			</c:if>
		</p>
	</center>
	<script type='text/javascript' src='${contextPath}/html/CM/js/jquery/jquery-1.10.js'></script>
	<script type='text/javascript' src='${contextPath}/html/CM/applet/jnlpService.js'></script>
	<script type='text/javascript'>
	jQuery(function(){
		var jnlp = new jnlpService('TiffViewerApp','<%=jnlpCodebase%>');
		
		jQuery('#jpln_btn').hide().click(function(){
			jnlp.run( 'filepath',
				{
					contextUrl: '${contextPath}/FileDownload',
					filePath: '${filePath}',
					downloadFileName: '${fileName}',
					encDownloadFileName: '${encryptMarkedFileName}'
				},
				function(){
					window.console & console.log ('tiff loaded');
				}, 
				function(msg){ 
					alert(msg);
					jQuery('#jpln_btn').show();
				} 
			);
		}).click();
	});
	</script>
    
</BODY>
</HTML>