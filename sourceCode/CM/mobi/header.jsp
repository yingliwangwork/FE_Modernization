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
		//ignored
	}
	
	String dispatcher = request.getContextPath() + "/servlet/HttpDispatcher";
	String htmlBase = request.getContextPath() + "/html";
	String cssBase = request.getContextPath() + "/html/CM/css/mobi";
	String imageBase = request.getContextPath() + "/images/mobi";
	
	pageContext.setAttribute("dispatcher", dispatcher);
	pageContext.setAttribute("htmlBase", htmlBase);
	pageContext.setAttribute("cssBase", cssBase);
	pageContext.setAttribute("imageBase", imageBase);
	
%>
<meta name="viewport" http-equiv="Content-Type" content=" width=device-width ;text/html; charset=Big5">
<link rel="stylesheet" media="all and (orientation:portrait)" href="${cssBase}/mcm.css">
<link rel="stylesheet" media="all and (orientation:landscape)" href="${cssBase}/mcm.css">
<script src="<%=request.getContextPath()%>/html/CM/js/mobi/zepto.js"></script>
<script src="<%=request.getContextPath()%>/html/CM/js/mobi/mcxl.js"></script>
<script src="<%=request.getContextPath()%>/html/CM/js/mobi/iscroll.js"></script>