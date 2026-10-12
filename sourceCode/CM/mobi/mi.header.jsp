<%@ page import="java.util.*" %>
<%@ page import="com.igsapp.wibc.dataobj.Context.*" %>
<%@ page import="com.igsapp.wibc.dataobj.html.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="/WEB-INF/tlds/cathay.tld" prefix="cathay" %>
<%

	//copy all output data to pagecontext, for el using easily
	try{
		HttpResponseContext resp = new HttpResponseContext(request);
		Enumeration outNames = resp.getOutputDataNames();

		while(outNames.hasMoreElements()){
			String name = (String)outNames.nextElement();
			pageContext.setAttribute(name, resp.getOutputData(name));
		}
	}catch(Exception e){
	}

	String dispatcher = request.getContextPath() + "/servlet/HttpDispatcher";
	String htmlBase = request.getContextPath() + "/html";
	String cssBase = request.getContextPath() + "/html/CM/css/mobi/jqm";
	String imageBase = request.getContextPath() + "/html/CM/css/mobi/jqm/images";
	String miHome = "/ALWeb/html/CM/mobi/mi.index.jsp"; //固定在 ALWeb
	String miLogout = "/ALWeb/servlet/HttpDispatcher/MIMain/logout"; //固定在 ALWeb
	
	String MI_AT_SYS_NAME = (String) session.getAttribute("MI_AT_SYS_NAME");
	
	if("ATM1".equals(MI_AT_SYS_NAME)) {
		miHome = "/ATWeb/servlet/HttpDispatcher/ATM0_0101/prompt?SYS_NAME=ATM1";
	}
	
	pageContext.setAttribute("dispatcher", dispatcher);
	pageContext.setAttribute("htmlBase", htmlBase);
	pageContext.setAttribute("cssBase", cssBase);
	pageContext.setAttribute("imageBase", imageBase);
	pageContext.setAttribute("miHome", miHome);
	pageContext.setAttribute("miLogout", miLogout);

%>
<meta charset="big5" />
<meta name="viewport" http-equiv="Content-Type" content="width=device-width,initial-scale=1">
<link rel="stylesheet" href="${cssBase}/jquery.mobile.css">
<link rel="stylesheet" href="${cssBase}/mi.css"> 
<script src="${htmlBase}/CM/js/mobi/jqm/jquery-modified.js"></script>
<script src="${htmlBase}/CM/js/mobi/jqm/jquery.mobile.js"></script>
<script id="jqueryMiJs" src="${htmlBase}/CM/js/mobi/jqm/jquery.mi.js" data-uuid="${requestTimeHandleUUID}"></script>
<script src="${htmlBase}/CM/js/mobi/jqm/mi.Validator.js"></script>
<script src="${htmlBase}/CM/js/mobi/jqm/mi.validation.js"></script>
