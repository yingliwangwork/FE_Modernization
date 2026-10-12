<%@ page contentType="text/html; charset=Big5" %>
<!DOCTYPE HTML>
<html>
<head>
<%@ page import="java.util.*" %>
<%@ page import="com.cathay.common.service.login.LoginInfoHandler" %>
<%@ page import="java.io.ByteArrayInputStream" %>
<%@ page import="javax.xml.parsers.DocumentBuilder" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="org.w3c.dom.*" %>
<%@ page import="org.xml.sax.InputSource" %>
<%@ page import="com.cathay.common.util.cache.CacheManager"%>
<%@ page import="com.cathay.common.util.http.HttpClientHelper" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="/CXL" prefix="CXL" %>
<!-- <%-- csCommon會引入沒有用的js檔案，採用HTML註解使其失效 --%>
<CXL:csCommon trace="false" htmlBaseName="htmlBase" cssBaseName="cssBase" imageBaseName="imageBase" dispatcherName="dispatcher" /> -->
<%!static Map<String, String> ruleMap = (Map<String, String>) CacheManager.getManagerMap("ie-compatMode");%>
<%
    Map systemInfo = LoginInfoHandler.getSystemInfo(request);
    String sysCode = (String) systemInfo.get("sysCode");

    // 系統代號
    String strSysCode = (String) pageContext.getAttribute("sysCode");
    StringBuffer sb = new StringBuffer();
    sb.append(htmlBase).append("/");
    if ("FC".equals(strSysCode)) {
        sb.append(strSysCode);
    } else {
        sb.append("CM");
    }

    sb.append("/skeletons/sys_top.jsp");
    // 加密之登入平台相關資訊
    sb.append("?eBAF_loginPlatformInfo=").append(pageContext.getAttribute("eBAF_loginPlatformInfo"));
    // 加密之登入子系統相關資訊
    sb.append("&eBAF_loginSystemInfo=").append(pageContext.getAttribute("eBAF_loginSystemInfo"));

    pageContext.setAttribute("sysTopURL", sb.toString());

    String CurrentLocale = null;

    try {
        String callModule = "com.cathay.im.i18n.LocaleUtil";
        String callMethod = "getCurrentLocale";

        Class aClass = Class.forName(callModule);
        java.lang.reflect.Method aMethod = aClass.getMethod(callMethod);
        Locale locale = (Locale) aMethod.invoke(aClass);
        CurrentLocale = locale.toString();
    } catch (Exception e) {
        CurrentLocale = "";
    }

    pageContext.setAttribute("CurrentLocale", CurrentLocale);
    
    // IE Browser mode setting 1 - FieldOption
    if(sysCode != null && !sysCode.trim().equals("")){
    	String compatible = null;
    	try{
            String exp_str = com.cathay.common.util.FieldOptionList.getName("ZZ", "sys.jsp" , "MODE_EDGE" );
	        if(exp_str != null && !exp_str.trim().equals("")){
	        	java.util.regex.Matcher matcher = java.util.regex.Pattern.compile(exp_str).matcher(sysCode);
	        	if(matcher.find()){
	        		compatible = "edge";
	        	}
	        }
        }catch(Exception e){
            pageContext.setAttribute("CompatibleError", e.getMessage());
        }
        
        try{
            String exp_str = com.cathay.common.util.FieldOptionList.getName("ZZ", "sys.jsp" , "MODE_5" );
	        if(exp_str != null && !exp_str.trim().equals("")){
	        	java.util.regex.Matcher matcher = java.util.regex.Pattern.compile(exp_str).matcher(sysCode);
	        	if(matcher.find()){
	        		compatible = "5";
	        	}
	        }
        }catch(Exception e){
            pageContext.setAttribute("CompatibleError", e.getMessage());
        }
        
        try{
            String compatibleBySysCode = com.cathay.common.util.FieldOptionList.getName("ZZ", "sys.jsp" , sysCode );
            if(compatibleBySysCode != null && !compatibleBySysCode.trim().equals("")){
            	compatible = compatibleBySysCode;
            }
        }catch(Exception e){
            pageContext.setAttribute("CompatibleError", e.getMessage());
        }
        
        if(compatible != null && !compatible.trim().equals("") && org.apache.commons.lang.ArrayUtils.contains(new String[]{"5","6","7","8","9","10","edge"}, compatible)){
            pageContext.setAttribute("compatible1", compatible);
        }
    }

    // IE Browser mode setting 2 - IE11 compatMode List
    String testURL = request.getRequestURL().toString();
    testURL = testURL.replaceFirst("(?i)http[sS]?://", "");
    String host = testURL.split("/")[0];
    boolean isLocal = host.matches("^[0-9.:]*$");
    if (isLocal) {
        testURL = testURL.indexOf("/") > 0 ? testURL.substring(testURL.indexOf("/")) : "";
    }
    String compatMode = null;
    String matchRule = null;
    if (testURL.length() > 1) {
        /* get compare rules for web and cache */
        if (ruleMap == null || ruleMap.isEmpty()) {
            synchronized (this) {
                if (ruleMap == null || ruleMap.isEmpty()) {
                	out.println("<!-- ### do load compatMode List for web ### -->");
                    ruleMap = new HashMap<String, String>();
                    try {
                        String xml_data = new HttpClientHelper().getHttpResponseAsString("https://was3.cathaylife.com.tw/CXLDocs/cxlsites.xml", Collections.EMPTY_MAP, "utf-8");
                        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
                        DocumentBuilder builder = factory.newDocumentBuilder();
                        Document doc = builder.parse(new InputSource(new ByteArrayInputStream(xml_data.getBytes("utf-8"))));
                        NodeList nl = doc.getElementsByTagName("site");
                        for (int i = 0; i < nl.getLength(); i++) {
                            Node attrUrl = nl.item(i).getAttributes().getNamedItem("url");
                            if (attrUrl == null) {
                                continue;
                            }
                            String url = attrUrl.getNodeValue();
                            if (isLocal){
                            	int firstSh = url.indexOf("/");
			                    if (!url.startsWith("t") || firstSh < 0 ) {
			                        continue;
			                    }
                            }else if(url.indexOf(host) != 0) {
                                continue;
                            }
                            NodeList child_nl = nl.item(i).getChildNodes();
                            for (int j = 0; j < child_nl.getLength(); j++) {
                                if (!"compat-mode".equals(child_nl.item(j).getNodeName())) {
                                    continue;
                                }
                                ruleMap.put(url, child_nl.item(j).getTextContent());
                                break;
                            }
                        }
                        if(ruleMap.isEmpty()){
                        	ruleMap.put("error", "no rules");
                        }
                    } catch (Exception e) {
                        ruleMap.put("error", e.getMessage());
                    }
                    CacheManager.register("ie-compatMode", ruleMap);
                }
            }
        }

        int compatMode_length = 0;
        if(ruleMap.containsKey("error") && ruleMap.get("error") != null){
        	compatMode = null;
            matchRule = "Can not get compat-mode cause: " + ruleMap.get("error") ;
        }else{
            for (String testPattern : ruleMap.keySet()) {
                if (isLocal) {
                	int firstSh = testPattern.indexOf("/");
                    if (!testURL.contains(testPattern.substring(firstSh))) {
                        continue;
                    }
                } else if (testURL.length() < testPattern.length() || testURL.indexOf(testPattern) != 0) {
                    continue;
                }
                if (compatMode_length > testPattern.length()) {
                    continue;
                }
                compatMode = ruleMap.get(testPattern);
                compatMode_length = testPattern.length();
                matchRule = testPattern;
            }
            if (compatMode != null && compatMode.length() > 0) {
                if ("IE11".equals(compatMode)) {
                    compatMode = "edge";
                } else {
                    compatMode = compatMode.replace("IE", "");
                }
            }
        }
    } else {
        compatMode = null;
        matchRule = "Compare url too short.";
    }
    pageContext.setAttribute("compatible2", compatMode);
    pageContext.setAttribute("compatibleMatchRule", matchRule);

    try {
        pageContext.setAttribute("PageSupporter_TYPE_0_AVAILABLE", com.cathay.common.util.FieldOptionList.getName("ZZ", "ZZC0_0600_UNIT_TYPE_0", sysCode));
        pageContext.setAttribute("PageSupporter_TYPE_1_AVAILABLE", com.cathay.common.util.FieldOptionList.getName("ZZ", "ZZC0_0600_UNIT_TYPE_1", sysCode));
    } catch (Exception e) {
        pageContext.setAttribute("PageSupporter_msg", "Can not get PageSupporter cause: " + e.getMessage());
    }
%>
<!-- info: sysCode=<%=sysCode%> , strSysCode=<%=strSysCode%> , elSysCode=${sysCode} -->
<meta http-equiv="Content-Type" content="text/html; charset=Big5">
<c:choose><c:when test="${not empty compatible1}"><meta http-equiv="X-UA-Compatible" content="IE=${compatible1};chrome=1">
</c:when><c:when test="${not empty compatible2}"><meta http-equiv="X-UA-Compatible" content="IE=${compatible2};chrome=1">
</c:when><c:otherwise><meta http-equiv="X-UA-Compatible" content="IE=edge;chrome=1"></c:otherwise></c:choose>
<!-- compatible1: ${compatible1} = ${CompatibleError} -->
<!-- compatible2: ${compatible2} = ${compatibleMatchRule} -->

<title><c:out value="${func_name}"/> - 國泰人壽 - ${pageContext.request.serverName}</title>

<script type="text/JavaScript">
<!--
top['eBAF_loginPlatformInfo']='<c:out value="${eBAF_loginPlatformInfo}"/>';
top['eBAF_loginSystemInfo']='<c:out value="${eBAF_loginSystemInfo}"/>';
top['eBAF_UserObject_Flag']='<c:out value="${eBAF_UserObject_Flag}"/>';
top['CurrentLocale']='<c:out value="${CurrentLocale}"/>';
<c:if test="${not empty platformDispatcher}">top['platformDispatcher']='<c:out value="${platformDispatcher}"/>';</c:if>

var setCookie = function(name, value , stayDays){
	document.cookie = name + "=" + escape(value) + ";path=/";
}
/* page supporter status */ 
setCookie('isUnitType0Avalible${sysCode}','${empty PageSupporter_TYPE_0_AVAILABLE?"N":"Y"}');
setCookie('isUnitType1Avalible${sysCode}','${empty PageSupporter_TYPE_1_AVAILABLE?"N":"Y"}');
<c:if test="${not empty PageSupporter_msg}">/* PageSupporter:${PageSupporter_msg} */</c:if> 

//-->
</script>
</head>
<c:choose><c:when test="${sysCode eq 'FC'}"><%-- FC 的結構與一般不同 --%>
	<frameset cols="*,1000,*" framespacing="0" frameborder="no" border="0">
	<frame name="left_blank" src="${htmlBase}/FC/skeletons/bg.html" title="左空框">
	<frameset rows="136,*" cols="*" frameborder="no" border="0" framespacing="0">
		<frame src="<c:out value="${sysTopURL}"/>" name="topFrame" scrolling="No" noresize="noresize" id="topFrame" title="topFrame" />
		<frameset rows="*" cols="204,*" framespacing="0" frameborder="no" border="0">
		<frame src="${dispatcher}/SysMenu/init?eBAF_loginSystemInfo=${eBAF_loginSystemInfo}" name="leftFrame" frameborder="no" scrolling="no" noresize marginwidth="0" marginheight="0">
		<frame src="${htmlBase}/FC/skeletons/main.html" name="mainFrame" scrolling="No" id="mainFrame" title="mainFrame" />
		</frameset>
	</frameset>
	<frame src="<%=htmlBase%>/FC/skeletons/bg.html">
	</frameset><noframes></noframes>
	<frame name="right_blank" src="" title="右空框">
</c:when><c:otherwise>  <%-- 一般子系統的結構 --%>
<frameset rows="50,*" cols="*" frameborder="NO" border="0" framespacing="0">
	<frame src="<c:out value="${sysTopURL}"/>" name="topFrame" scrolling="yes" noresize>
	<frame src="${dispatcher}/SysMenu/init?eBAF_loginSystemInfo=${eBAF_loginSystemInfo}" name="leftFrame" frameborder="no" scrolling="no" noresize marginwidth="0" marginheight="0">
</frameset>
</c:otherwise></c:choose>
<noframes>
<body></body>
</noframes>
</html>