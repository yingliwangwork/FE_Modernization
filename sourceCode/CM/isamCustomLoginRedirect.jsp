<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ taglib uri="/CXL" prefix="CXL" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<CXL:csCommon trace="false" htmlBaseName="htmlBase" cssBaseName="cssBase" imageBaseName="imageBase" dispatcherName="dispatcher" />

<%
	boolean samlIsOn = com.cathay.isam.util.SamlUtil.samlIsOn();

	if(samlIsOn){
		// 1. default url with sysCode
		String _sys = (String) request.getParameter("sys");
		String _sysCode = (String) request.getParameter("sysCode");
		String thisSysCode = StringUtils.isNotBlank(_sysCode) ? _sysCode : request.getContextPath().replace("/", "").replace("Web", ""); // request.getContextPath="/XXWeb"
		StringBuilder sb = new StringBuilder().append(dispatcher).append("/login/input?");
		if (!thisSysCode.equals(com.cathay.common.util.LoginUtil.loginSysCode())) {
			sb.append("sysCode=").append(thisSysCode).append("&");
		}else if (StringUtils.isNotBlank(_sys)) {
			sb.append("sysCode=").append(_sys).append("&");
		}
		
		// 2. loginPlatform
		_sys = StringUtils.isBlank(_sys) ? thisSysCode : _sys;
		sb.append("loginPlatform=").append(_sys);
		
		// 3. userID and passWD
		String _userID = (String) request.getParameter("userID");
		if (StringUtils.isNotBlank(_userID)) {
			sb.append("&userID=").append(_userID);
			
			String _passWD = (String) request.getParameter("passWD");
			if (StringUtils.isNotBlank(_passWD)) {
				sb.append("&passWD=").append(_passWD);
			}
		}
		
		// 4. url
		String _url = (String) request.getParameter("url");
		if (StringUtils.isNotBlank(_url)) {
			sb.append("&url=").append(_url);
		}
		
		// 5. function_id
		String _function_id = (String) request.getParameter("function_id");
		if (StringUtils.isNotBlank(_function_id)) {
			sb.append("&function_id=").append(_function_id);
		}
		
		String loginUrl = sb.toString();
		
		if(!"Y".equals(pageContext.getAttribute("isamLogOut"))){
			response.sendRedirect(loginUrl);
		} else {
			Object logOutUrlAttr = pageContext.getAttribute("logOutUrl");
	        String logOutUrl = logOutUrlAttr == null ? "" : logOutUrlAttr.toString();
	        if(logOutUrl == null || logOutUrl.replaceAll("\\s","").equals("")){
	            String perfix = "";
	            if(com.cathay.common.util.LoginUtil.isStag()){
	                perfix = "s";
	            }else if(com.cathay.common.util.LoginUtil.isTesting()){
	                perfix = "t";
	            }
	            logOutUrl = String.format("https://%sw3.cathaylife.com.tw/pkmslogout?filename=wpslogout.html" , perfix);
	        }
	        
	        pageContext.setAttribute("logOutUrl", logOutUrl);
	        pageContext.setAttribute("loginUrl", loginUrl);
		}
	}
	
%>
<c:if test="${not empty logOutUrl}">
	<body>
	</body>
	<script type='text/javascript'>
		var script = document.createElement('script');
		script.onload = function() {
			var logoutForm = document.createElement('form');
			document.body.appendChild(logoutForm);
			logoutForm.action = '${loginUrl}';
			logoutForm.submit();
		};
		script.src = '${logOutUrl}';
		document.getElementsByTagName('head')[0].appendChild(script);
	</script>
</c:if>
<%
	if(samlIsOn){
		return;
	}
%>