<%@ page contentType="text/html; charset=Big5" %>
<%@ page import="java.lang.StringBuffer"%>
<%@ page import="com.cathay.common.service.authenticate.MenuObject"%>
<%@ page import="org.apache.commons.lang.StringUtils"%>

<%
    /* 登入者作業單位簡稱 */
    String strOpUnitName = (String) pageContext.getAttribute("opUnitName");
    /* 登入者姓名 */
    String strEmpName = (String) pageContext.getAttribute("empName");

    /* 登入位置之 ContextPath */
    String strMainContext = (String) pageContext.getAttribute("mainContext");
    /* 系統代號 */
    String strSysCode = (String) pageContext.getAttribute("syscode");
    /* 系統名稱 */
    String strSysName = (String) pageContext.getAttribute("sysname");
    /* URL*/
    String URL = (String) pageContext.getAttribute("URL");
    String forwardUrl = (String) pageContext.getAttribute("forwardUrl");
    String hasAuth = (String) pageContext.getAttribute("hasAuth");

    if("Y".equals(request.getAttribute("forward4OTT"))){
        pageContext.setAttribute("hasAuth", "true");
        pageContext.setAttribute("URL", request.getAttribute("URL"));
        pageContext.setAttribute("formMethod", request.getAttribute("formMethod"));
        pageContext.setAttribute("params", request.getAttribute("params"));
    }
%>

<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=Big5">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta isamLogin="samlLoginSuccessForAPP"> <%-- APP SAML登入成功判斷會抓此input的value，不可刪!!!! --%>
<title>國泰人壽</title>

<%@ taglib uri="/CXL" prefix="CXL" %>
<%@ taglib uri="/jstl-c" prefix="c" %>

<CXL:csCommon trace="false" htmlBaseName="htmlBase"
	cssBaseName="cssBase" imageBaseName="imageBase" dispatcherName="dispatcher"></CXL:csCommon>
						   
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script><!-- 必要 -->
<script language="JavaScript" type="text/JavaScript">
	function MM_reloadPage(init) {  //reloads the window if Nav4 resized
		if (init==true) with (navigator) {
			if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
				document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; 
			}
		} else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) {
			location.reload();
		}
	}
	MM_reloadPage(true);
</script>
</head>

<body  bgcolor="#F0FBC6">
<br/>

<c:choose>
<c:when test="${hasAuth eq 'true'}">
    <div align=center>處理中，請稍候...</div>
</c:when>
<c:otherwise>
    <div align=center>使用者 ${strEmpName} 無此作業權限!</div>
</c:otherwise>
</c:choose>

<c:if test="${hasAuth eq 'true'}">
	<script type='text/javascript'>
	<c:choose>
	<c:when test="${not empty URL}">
		var url="<c:out value='${URL}'/>";
	</c:when>
	<c:otherwise>
		var url="${dispatcher}/<c:out value='${forwardUrl}'/>";
	</c:otherwise>
	</c:choose>
		if(url){
			url = url.replace(/&amp;/g,'&');
			var method = '${formMethod}'?'${formMethod}':'post';
			var form = new Element('form', {
				'id':'_crossForward_form'
				,'method':method
				,'action':url
			});
			document.body.appendChild(form);

			<c:if test="${not empty params}">
			function createParameters(form, key, value){
				var input = new Element('input', {
					'name':key
					,'type':'hidden'
					,'value':value
				});

				form.insert(input);
			}

			var _params = ${params};
			for(key in _params){
				var values = _params[key];

				if(values instanceof Array){
					for(var i=0; i<values.length; i++){
						createParameters(form, key, values[i]);
					}
				}else{
					createParameters(form, key, values);
				}
			}
			</c:if>

			form.submit();
		}
	</script>
</c:if>

</body>
</html>