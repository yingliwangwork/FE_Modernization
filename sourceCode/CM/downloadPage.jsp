<%@ page contentType="text/html; charset=BIG5" %>
<%@ page import= "java.io.*" %>
<%@ page import="com.cathay.common.util.*"%>
<%@ page import="com.igsapp.wibc.dataobj.Context.*" %>
<%@ page import="com.igsapp.wibc.dataobj.html.HttpResponseContext" %>
<%@ page import="com.igsapp.wibc.dataobj.html.HttpTxContext" %>                         
<%@ page import="com.cathay.util.*" %>                     
<%@ taglib uri="/CXL" prefix="CXL" %>

<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
                            cssBaseName="cssBase" 
                            imageBaseName="imageBase" 
                            dispatcherName="dispatcher" />
<%
	/* jsp 功能 : 將字串當作檔案下載至 Client 端 */

	HttpResponseContext resp = new HttpResponseContext(request);//取出 trx addOutputData 中的值
	HttpTxContext txCxt = new HttpTxContext(session);//取出自 trx putValue 中的值 

	String FILE_DATA=Base64.decodeToString( request.getParameter( "FILE_DATA")); //要下載的字串
	String FILE_NAME=request.getParameter("FILE_NAME"); //要存成的檔名

	System.out.println("Running downloadPage2 , FILE_NAME="+FILE_NAME);
	
	if (FILE_DATA!=null && FILE_DATA instanceof String){
		
		ServletOutputStream ouputStream=null;
		try{ 
			byte[] wb=FILE_DATA.getBytes();		
			ouputStream = response.getOutputStream();
			response.setContentLength(wb.length  );
			response.setContentType("application/download");
			response.setHeader("Content-disposition","attachment; filename="+FILE_NAME );
		  	ouputStream.write(wb);
		}
		catch(Exception e){
			e.printStackTrace() ;
		}
		finally{
			try{
				ouputStream.flush();
				ouputStream.close();
			}
			catch(Exception fe){
				fe.printStackTrace() ;
			}
		}
	}
	else{
		System.err.println("FILE_DATA must instanceOf String !");
	}
%>
