<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ taglib uri="/CXL" prefix="CXL" %>
<CXL:csCommon trace="false" htmlBaseName="htmlBase" cssBaseName="cssBase" imageBaseName="imageBase" dispatcherName="dispatcher" />
<%
	StringBuilder sb = new StringBuilder();

	// 1. serverName+port
	String serverName = com.cathay.common.service.ConfigManager.getProperty("serverNameWithScheme");
	if(StringUtils.isNotBlank(serverName)) {// special serverName. ex.B2E get "newwasvip" not "w3"
		sb.append(serverName);
	} else {
		boolean isLocal = !com.cathay.common.util.LoginUtil.isProd() && !com.cathay.common.util.LoginUtil.isStag() && !com.cathay.common.util.LoginUtil.isTesting();
		String scheme = isLocal ? "http://" : "https://";
		sb.append(scheme).append(request.getServerName());
		
		int port = request.getServerPort();
		if(port != 80 && port != 443) {
		    sb.append(':').append(port);
		}
	}
	
	String loginSysCode = com.cathay.common.util.LoginUtil.loginSysCode();
	sb.append("/").append(loginSysCode).append("Web");
	
	// 2. others
	String thisWeb = request.getContextPath();
	if (com.cathay.isam.util.SamlUtil.samlIsOn() && StringUtils.isNotBlank(thisWeb) && StringUtils.isNotBlank(dispatcher)){
		String sysCode = thisWeb.replace("/", "").replace("Web", "");
		if(!sysCode.equals(loginSysCode)) {
			String redirectServlet = dispatcher.replace(thisWeb, "");
			sb.append(redirectServlet).append("/login/input?sysCode=").append(sysCode);
		}
	}

	response.sendRedirect(sb.toString());
%>