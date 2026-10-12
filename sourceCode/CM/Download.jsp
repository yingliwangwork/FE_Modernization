<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp" %>
<!-- Custome import declare -->
<%@ page import = "com.cathay.common.util.STRING"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="com.cathay.util.FileStoreUtil" %>
<%@ page import="org.apache.commons.lang.ObjectUtils" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="com.cathay.common.service.ConfigManager" %>
<%@ page import="com.cathay.common.exception.ModuleException" %>
<%@ page import="org.apache.log4j.Logger"%>
<%!static List<String> filePathList = null;%>
<%!static List<String> illegalFilePathList = null;%>
<%!static String serverType = null;%>
<%!static Logger log = Logger.getLogger("monitor_info.jsp");%>
<%!static List<String> blockContext = Arrays.asList("/AAWeb","/XXWeb");%>

<%!
String getFILE_NAME(HttpServletRequest request, HttpResponseContext resp) {
	if((String)request.getParameter( "FILE_NAME") == null) {
		return (String)resp.getOutputData("FILE_NAME");
	} else {
		return (String)request.getParameter( "FILE_NAME");
	}
}
%>
<%!
String getFILE_PATH(HttpServletRequest request, HttpResponseContext resp) {
	if((String)request.getParameter( "FILE_PATH") == null) {
		return (String)resp.getOutputData("FILE_PATH");
	} else {
		return (String)request.getParameter( "FILE_PATH");
	}
}
%>

<%!
static{
	//legal path
	filePathList = new ArrayList<String>();
	Method[] method = FileStoreUtil.class.getMethods();
	File tempFile = null;
	String methodName = null;
	for(Method eachMethod : method){
		methodName = eachMethod.getName();
		if(methodName.contains("get")){
			try{
				Object rtnObj = eachMethod.invoke(methodName);
				if(rtnObj instanceof File){
					tempFile = (File)rtnObj;
					filePathList.add(tempFile.getPath());
				}
			}catch(Exception e){
				log.fatal("",e);
			}
		}
	}
	String jasperReportSaveRoot = ConfigManager.getProperty("com.cathay.util.jasper.JasperUtils.jasperReportSaveRoot");
	String xlsSaveRoot = ConfigManager.getProperty("com.cathay.rpt.XlsUtils.saveRoot");
	String csvSaveRoot = ConfigManager.getProperty("com.cathay.rpt.CsvUtils.saveRoot");
	filePathList.add(jasperReportSaveRoot);
	filePathList.add(xlsSaveRoot);
	filePathList.add(csvSaveRoot);
	filePathList.add("/usr/WebSphere/data/");
	
	//illegal path
	illegalFilePathList = new ArrayList<String>();
	illegalFilePathList.add("../");
	
	//get run environment
   	try {
   	    serverType = ConfigManager.getProperty("ebaf.ServerType");// 由程式自己判斷執行環境  
   	} catch (Exception e) {
   		System.out.println("抓取執行環境設定發生異常!");
   		log.fatal("",e);
   	}
}
%>

<%!
void logIllegalPath(HttpServletRequest request, String FILE_NAME, String FILE_PATH) {
	StringBuffer errorSb = new StringBuffer();
	errorSb.append("FILE_PATH : ")
			.append(FILE_PATH)
			.append(" | FILE_NAME : ")
			.append(FILE_NAME)
			.append(" | Client Req URL : ")
			.append(request.getRequestURI())
			.append(" | Forward Req URL : ")
			.append((String)request.getAttribute("javax.servlet.forward.request_uri"))
			.append(" | Header Referer URL : ")
			.append(request.getHeader("Referer"));
	System.out.println(errorSb.toString());
}
%>

<%!
boolean doValidateFilePath(String FILE_PATH){
	String filePathTemp = FILE_PATH;
	boolean isIllegal = true;
	for(String eachIllegalPath : illegalFilePathList){
		if(filePathTemp.contains(eachIllegalPath)){
			isIllegal = true;
			return isIllegal;
		}
	}
	if(StringUtils.isBlank(serverType)){
		filePathTemp = filePathTemp.replaceAll("/", "\\\\");
	}
	for(String eachPath : filePathList){
		if(StringUtils.isNotBlank(eachPath) && filePathTemp.contains(eachPath)){
			isIllegal = false;
			break;
		}
	}
	return isIllegal;
}
%>

<%!
boolean blockDownload(HttpServletRequest request) {
	String contextPath = request.getContextPath();
	if(blockContext.contains(contextPath)) {
		return true;
	}
	return false;
}
%>

<%
if(blockDownload(request)){
	response.setStatus(404);
	return;
}
out.clear();
out = pageContext.pushBody();	
BufferedInputStream in= null;
File file = null;
try{
	HttpResponseContext resp = new HttpResponseContext(request);	

	String FILE_NAME = getFILE_NAME(request, resp);
	String FILE_PATH = getFILE_PATH(request, resp);

	if(doValidateFilePath(FILE_PATH)){
		System.out.println("Illegal File Path!");
		logIllegalPath(request, FILE_NAME, FILE_PATH);
		response.sendError(HttpServletResponse.SC_NOT_FOUND);
		return;
	}

	boolean deleteFile = (resp.getOutputData("deleteFile") instanceof Boolean) ? ((Boolean) resp.getOutputData("deleteFile")) : false;
	if(!deleteFile){
		deleteFile = resp.getOutputData("deleteTemp")==null ? false : (Boolean) resp.getOutputData("deleteTemp"); 
	}

	/* jsp 功能 : 執行 download 的 功能  */
	String FILE_NAME_U=FILE_NAME.toLowerCase();
	if (FILE_NAME.indexOf(".docx")>-1) {			
		response.setContentType("application/vnd.ms-word" + "; charset=iso-8859-1");
		response.addHeader("Content-Disposition", "attachment;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
	}else if (FILE_NAME_U.indexOf(".doc")>-1){
		response.setContentType("application/msword" + "; charset=iso-8859-1");
		response.addHeader("Content-Disposition", "inline;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
	}else if (FILE_NAME_U.indexOf(".xls")>-1){
			response.setContentType("application/msexcel" + "; charset=iso-8859-1");
		response.addHeader("Content-Disposition", "inline;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));

	}else if (FILE_NAME_U.indexOf(".jpg")>-1 || FILE_NAME_U.indexOf(".gif")>-1  || FILE_PATH.indexOf(".png")>-1){
   		response.setContentType("image/jpg"); 
   		response.addHeader("Content-Disposition", "inline;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
 	}else if (FILE_NAME_U.indexOf(".exe")>-1){
	    response.setContentType("application/exe"); 
	    response.addHeader("Content-Disposition", "inline;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
	}else if (FILE_NAME_U.indexOf(".txt")>-1){
		response.setContentType("application/download");
		response.addHeader("Content-Disposition", "attachment; filename="+new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
	}else if (FILE_NAME_U.indexOf(".pdf")>-1){
   		//response.setContentType("image/pdf"); 
		response.setContentType("application/pdf");
   		response.addHeader("Content-Disposition", "inline;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
	}else if (FILE_NAME.indexOf(".ppt") > -1) {
			response.setContentType("application/mspowerpoint" + "; charset=iso-8859-1");
			response.addHeader("Content-Disposition", "attachment;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
	}else {
			response.setContentType("application/download");
			response.addHeader("Content-Disposition", "attachment;filename="+new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));			
	}
	
	file = new java.io.File(FILE_PATH);
/*
	if(isDebug) {
		log.debug("file1_getPath="+file.getPath());
		log.debug("file1_getName="+file.getName());
		log.debug("FILE_PATH="+FILE_PATH);		
	}
*/
	InputStream fis = new FileInputStream(file);     
	in = new BufferedInputStream(fis);
	OutputStream outs = response.getOutputStream();
	int aRead = 0;
	while((aRead = in.read()) != -1 & in != null){
		outs.write(aRead);
	}
	outs.flush();
	fis.close();
	outs.close();
	
	if (deleteFile) file.delete();
}catch(Exception e){
	log.fatal("",e);
}
%>
