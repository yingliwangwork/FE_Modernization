<%@ page contentType="text/html; charset=BIG5" %>
<%@ include file="/html/CM/header.jsp" %>
<%@ page import= "java.io.*" %>
<%@ page import="com.cathay.common.util.Base64"%>
<%@ page import="com.cathay.common.util.*"%>
<%@ page import="java.net.*"%>
<%@ page import="org.apache.log4j.Logger"%>

<%!

	private static Logger log = Logger.getLogger("downloadForAD.jsp");
 %>

<%
	/* jsp 功能 : 輸出指定的檔案 */
	HttpResponseContext resp = new HttpResponseContext(request);
	String FILE_NAME = STRING.objToStrNoNull(resp.getOutputData("fileName"));
	String FILE_PATH = STRING.objToStrNoNull(resp.getOutputData("filePath"));
	
	if (FILE_PATH.length() >0){
		FILE_NAME = Base64.decodeToString(FILE_NAME);
		FILE_PATH = Base64.decodeToString(FILE_PATH);
		FILE_NAME = URLEncoder.encode(FILE_NAME,"UTF-8");
		log.debug("FILE_NAME=" + FILE_NAME);
		log.debug("FILE_PATH=" + FILE_PATH);
		
		FileInputStream fis =null;
		ServletOutputStream ouputStream=null;

		try{ 
			fis = new FileInputStream(FILE_PATH);
			byte[] buf = new byte[1000];
			out.clear(); 
			out = pageContext.pushBody(); 
			ouputStream = response.getOutputStream();

			response.setContentLength(fis.available());

			/* jsp 功能 : 執行 download 的 功能  */
		
		if (FILE_PATH.indexOf(".doc")>-1){
			response.setContentType("application/msword" + "; charset=iso-8859-1");
			response.addHeader("Content-Disposition", "inline;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
		}else if (FILE_PATH.indexOf(".pdf")>-1){
			response.setContentType("application/pdf" + "; charset=iso-8859-1");
			response.addHeader("Content-Disposition", "inline;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
		}else if (FILE_PATH.indexOf(".xls")>-1){
			response.setContentType("application/msexcel" + "; charset=iso-8859-1");
			response.addHeader("Content-Disposition", "inline;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
		}else if (FILE_PATH.indexOf(".ppt")>-1){
			response.setContentType("application/mspowerpoint" + "; charset=iso-8859-1");
			response.addHeader("Content-Disposition", "inline;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
		}else if (FILE_PATH.indexOf(".jpg")>-1 ){
	   		response.setContentType("image/jpeg"); 
	   		response.addHeader("Content-Disposition", "attachment;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
	   	}else if (FILE_PATH.indexOf(".gif")>-1 ){
	   		response.setContentType("image/gif"); 
	   		response.addHeader("Content-Disposition", "attachment;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
		}else if (FILE_PATH.indexOf(".tif")>-1){
	   		response.setContentType("image/tiff"); 
	   		response.addHeader("Content-Disposition", "attachment;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
	 	}else if (FILE_PATH.indexOf(".exe")>-1){
		    response.setContentType("application/exe"); 
		    response.addHeader("Content-Disposition", "inline;filename=" + new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
		}else if (FILE_NAME.indexOf(".txt")>-1){
			response.setContentType("application/download");
			response.addHeader("Content-Disposition", "attachment; filename="+new String(FILE_NAME.getBytes("Big5"),"ISO8859_1"));
		}

			while (fis.read(buf) != -1) {
			  	ouputStream.write(buf);
			}

		}
		catch(Exception e){
		}
		finally{
			try{
				fis.close();
				ouputStream.flush();
				ouputStream.close();
			}
			catch(Exception fe){
				fe.printStackTrace() ;
			}
		}
	} else {
		out.print("檔案不存在");
	}
%>
