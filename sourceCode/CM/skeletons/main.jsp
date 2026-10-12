<%@ page language="java" contentType="text/html; charset=BIG5" %><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=Big5">
<title>國泰人壽 - ${pageContext.request.serverName}</title>
<%@ page import="com.cathay.common.service.login.LoginInfoHandler" %>
<%@ page import="com.cathay.common.service.ConfigManager" %>
<%@ page import="com.cathay.common.util.EncodingHelper" %>
<%@ include file="/html/CM/header.jsp" %>
<%
	Map systemInfo = LoginInfoHandler.getSystemInfo(request);

	String mainURI = ConfigManager.getProperty("com.cathay.zz.trx.Login.mainURI");

	com.igsapp.wibc.dataobj.Context.ResponseContext resp = (com.igsapp.wibc.dataobj.Context.ResponseContext)request.getAttribute("$Attribute.responseContext");
	String strSysCode = resp.getAttribute("sysCode")!=null ? (String)resp.getAttribute("sysCode") : null;
	boolean hasSysCode = strSysCode != null && strSysCode.length( )> 0;

	if(mainURI!=null && mainURI.length()>0 && !hasSysCode){
		StringBuilder sb = new StringBuilder();
		String string_web = "Web";
		if(mainURI.indexOf(string_web) < 0){
			String uri = request.getRequestURI();
			String tmp = uri.substring(0, uri.indexOf(string_web)+string_web.length());
			String webRoot = tmp.substring(tmp.lastIndexOf("/"));

			sb.append(webRoot);
		}
		sb.append(mainURI);

		boolean hasParam = false;
		Object eBAF_loginPlatformInfo = pageContext.getAttribute("eBAF_loginPlatformInfo");
		if(eBAF_loginPlatformInfo != null){
			if(hasParam){
				sb.append("&");
			}else{
				sb.append("?");
				hasParam = true;
			}
			sb.append("eBAF_loginPlatformInfo=").append(eBAF_loginPlatformInfo);
		}

		Object eBAF_loginSystemInfo = pageContext.getAttribute("eBAF_loginSystemInfo");
		if(eBAF_loginSystemInfo != null){
			if(hasParam){
				sb.append("&");
			}else{
				sb.append("?");
				hasParam = true;
			}
			sb.append("eBAF_loginSystemInfo=").append(eBAF_loginSystemInfo);
		}

		if(hasParam){
			sb.append("&");
		}else{
			sb.append("?");
			hasParam = true;
		}
		sb.append("&_=" + new Date().getTime());

		String redirectURL = sb.toString();
		response.sendRedirect(redirectURL);
		return;
	}

	if(hasSysCode){

		String strFuncID = resp.getAttribute("funcID")!=null?(String)resp.getAttribute("funcID"):"";
		String url = resp.getAttribute("url")!=null?(String)resp.getAttribute("url"):"";

		String webRoot;
		if(strSysCode.equals("DK")){
			webRoot = "/DJWeb";
		}else {
			webRoot = "/"+strSysCode.toUpperCase()+"Web";
		}

		StringBuilder sb = new StringBuilder();
		sb.append(webRoot).append("/servlet/HttpDispatcher/SysLogin/");

		if(strFuncID!=null && strFuncID.length()>0){
			sb.append("forward");
			sb.append("?url=").append(java.net.URLEncoder.encode(url, EncodingHelper.serverEncoding));
			sb.append("&function_id=").append(strFuncID);
		}else{
			sb.append("prompt");
			sb.append("?eBAF_loginPlatformInfo=").append(pageContext.getAttribute("eBAF_loginPlatformInfo"));
			sb.append("&eBAF_loginSystemInfo=").append(pageContext.getAttribute("eBAF_loginSystemInfo"));
		}
		String redirectURL = sb.toString();
		response.sendRedirect(redirectURL);
		return;
	}
%>

<script type="text/JavaScript">
<!--
	function mainJSP(){
		return {
			initApp: function(){
				try{
					top['eBAF_UserObject_Flag']='<c:out value="${eBAF_UserObject_Flag}"/>';
					top['eBAF_loginPlatformInfo']='<c:out value="${eBAF_loginPlatformInfo}"/>';
				}catch(e){
				}
			}
		};
	}
	new mainJSP().initApp();
//-->
</script>
</head>
<frameset rows="50,*" cols="*" frameborder="NO" border="0" framespacing="0" >
	<frame src="<%=dispatcher%>/MainTop/init?eBAF_loginPlatformInfo=<c:out value="${eBAF_loginPlatformInfo}"/>" name="topFrame" scrolling="yes" noresize>
	<frameset cols="183px,*" frameborder="NO" border="0" framespacing="0">
		<frame src="<%=dispatcher%>/MainMenu/init" name="leftFrame"  noresize>
		<frameset rows="*,30px" frameborder="NO" border="0" framespacing="0">
			<frame src="<%=dispatcher%>/SysNews/main" name="mainFrame" scrolling="yes" noresize id="mainFrame">
			<frame src="<%=htmlBase%>/CM/skeletons/bottom.htm" name="bottomFrame" scrolling="yes" noresize>
		</frameset>
	</frameset>
</frameset>
<noframes><body></body></noframes>
</html>