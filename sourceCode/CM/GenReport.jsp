<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<%@ page language="java" import="java.util.*, com.cathay.at.util.InsurCenter "
contentType="text/html; charset=BIG5"
isThreadSafe="false"
isErrorPage="false"
autoFlush="false"
%>
<%@ include file="/html/CM/header.jsp" %>
<%@ page import="com.cathay.at.m0.module.AT_M0Z009" %>
<%@ page import="com.cathay.at.m0.module.AT_M0Z100" %>
<%@ page import="com.cathay.at.m0.bo.AT_M0Z010_bo" %>
<%@ page import="com.cathay.at.m0.module.AT_M0Z001" %>
<%@ page import="com.cathay.at.m0.module.AT_M0Z006" %>
<%@ page import="com.cathay.at.m0.module.AT_M0Z007" %>
<%@ page import="com.cathay.at.m0.module.ATM0_0220_mod" %>

<%@ page import="com.cathay.at.m0.module.AT_M0Z032" %>

<%@ page import="com.cathay.at.vo.DTATM031" %>
<%@ page import="com.cathay.at.vo.DTATM131" %>
<%@ page import="com.cathay.at.vo.DTATM130" %>
<%@ page import="com.cathay.at.m0.bo.AT_M0Z001_bo2" %>


<%@ page import="com.cathay.at.m0.module.AT_M0Z009.AT_M0Z009_VO" %>
<%@ page import="org.apache.commons.httpclient.HttpClient" %>  
<%@ page import="org.apache.commons.httpclient.HttpStatus" %>    
<%@ page import="org.apache.commons.httpclient.methods.PostMethod" %>
<%@ page import="com.cathay.common.util.FieldOptionList" %>

<%@ page import="org.apache.commons.httpclient.methods.PostMethod" %>
<%@ page import="com.cathay.common.util.http.HttpClientTool" %>

<%@ page import="com.cathay.rpt.json.RptJSONUtils" %>

<%@ page import="com.cathay.common.service.ConfigManager" %>
<%@ page import="com.cathay.bg.util.Tools" %>
<%@ page import="com.cathay.common.bo.ReturnMessage" %>

<%@ page import="com.cathay.at.m1.module.AT_M1Z210" %>
<%@ page import="com.cathay.zz.r0.module.ZZ_R0Z001" %>

<%!
	
	public String getURLForCRM() throws Exception {
	
		AT_M1Z210 z210 = new AT_M1Z210();	
		
		String[] hostURLs = z210.getCRMURL(ZZ_R0Z001.fetchREG_CONT("753", "0"));
		String theUrlForCRM = hostURLs[0];
		
		return theUrlForCRM;
		
	}

%>

<META http-equiv="Content-Type" content="text/html; charset=BIG5">
<TITLE>重新產生DATA</TITLE>
</HEAD>
<BODY>
<P>重新產生DATA</P>
<%

	
	
	String APPLY_NO = request.getParameter("APPLY_NO");
	
	if (APPLY_NO == null || APPLY_NO.equals("")) {
	
	}else{
	
		
		out.println("受理編號 "  +APPLY_NO+ "<br>");
	 
	 		AT_M0Z009 M0Z009_mod = new AT_M0Z009();
			List<AT_M0Z009_VO> AT_M0Z009_voList = M0Z009_mod.doALL(APPLY_NO);
			
			
			PostMethod method = new PostMethod( ConfigManager.getProperty("MI_HOME_URL")+"PostData");
			
			 method.addRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");

			for (AT_M0Z009_VO AT_M0Z009_vo : AT_M0Z009_voList) {
				
				String PROM_NAME =  AT_M0Z009_vo.getPROG_NAME();
				
					if(PROM_NAME.length()>9){
			    		PROM_NAME = PROM_NAME.substring(9, PROM_NAME.length());
			    		
			    	}
			    	
					String SUB_SYS = PROM_NAME.substring(3, 5).toLowerCase();
					
					try {
						AT_M0Z100 AT_M0Z100 = (AT_M0Z100)Class.forName("com.cathay.at."+SUB_SYS+".module." +PROM_NAME).newInstance();
						
						AT_M0Z010_bo result = AT_M0Z100.doPrint(APPLY_NO);
					
						method.addParameter("APPLY_NO", APPLY_NO);
	    				method.addParameter("REPORT_ID", result.getREPORT_ID());
	    				method.addParameter("RPT_PARAM", new String(RptJSONUtils.objectToJSON(result.getREPORT_PARAM()).getBytes("IBM950"), "MS950"));
	    				method.addParameter("RPT_DETAIL", RptJSONUtils.objectToJSON(result.getREPORT_DETAIL()));
						
					} catch (Exception e) {

						out.println(PROM_NAME + "模組執行有誤,<br>" + e.getMessage());
						out.println("<br>=========================================================<br>");
						java.io.StringWriter sw = new java.io.StringWriter();
                		java.io.PrintWriter pw = new java.io.PrintWriter(sw);
                		e.printStackTrace(pw);
                		out.println(sw.toString());

						break;
					}
				
        	}
			
			HttpClient client = new HttpClient();
		    int returnCode = client.executeMethod(method);
			if(returnCode != HttpStatus.SC_OK) {
				out.println("產生報表資料發生異常!<br>");
									
			}else{
				out.println("產生報表資料完成!<br>");
									
			}
			
			
			
			
			
	   Map MI_CRM_PDF_SERVICEMap = FieldOptionList.getFieldOptions("AT", "MI_CRM_PDF_SERVICE");
	   
        if(MI_CRM_PDF_SERVICEMap.containsKey(APPLY_NO.substring(0,2))){
            
           out.println("<br>"); 
           out.println("<br>");
            
           out.println("重新產生傳建議書JASON資料<br>");
            
           ATM0_0220_mod mod = new ATM0_0220_mod();
         
          String serverType =  ConfigManager.getProperty("ebaf.ServerType");
            
			//4.10	判斷是否回傳建議書JASON資料回給CRM
	        AT_M0Z001 at_m0z001 = new AT_M0Z001(); 
	        AT_M0Z007 at_m0z007 = new AT_M0Z007();
	        try{
				
				String theUrlForCRM = getURLForCRM();				
				
	        	DTATM131 DTATM131_VO = mod.formatDTATM131(APPLY_NO); 
	        	
	    	
	            DTATM031 DTATM031_VO = new DTATM031();
	            DTATM031_VO = mod.doQuery_DTATM031(DTATM131_VO);
	            //4.10.4	若DTATM131_VO 不存在或DTATM131_vo 與DTATM031 INSURED_ID, INSURED_NAME, INSURED_BIRTH, INSURED_SEX 有任一不同
	            String [] fields = {"INSURED_ID","INSURED_NAME","INSURED_BITH","INSURED_SEX"};
	            boolean isDiffFlag = AT_M0Z032.isDiff(DTATM131_VO, DTATM031_VO, fields);
	            if(Tools.isNull(DTATM131_VO) || isDiffFlag){
	            
	            	out.println("建議書資料不一致，需更新<br>");
	            	
	            	AT_M0Z001_bo2 AT_M0Z001_bo2 = new AT_M0Z001_bo2();
	            	DTATM131_VO.setSTS_CODE("1");
	            	at_m0z007.doUpdate_DTATM131(DTATM131_VO);
	            	
	            	AT_M0Z001_bo2 = at_m0z001.transIntoProposal(APPLY_NO);
	            	
	        	    PostMethod postmethod = new PostMethod(theUrlForCRM);	        	   
	        	    postmethod.addRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=IBM950");
	        	    
	        	    
	        	   
	        	    	out.println("PostMethod getHostAuthState : "+postmethod.getHostAuthState() + "<br>");
	        	    	out.println("PostMethod getHostConfiguration : "+postmethod.getHostConfiguration()+ "<br>");
	        	    	out.println("PostMethod getParams : "+postmethod.getParams()+ "<br>");
	        	    	out.println("PostMethod getProxyAuthState : "+postmethod.getProxyAuthState()+ "<br>");
	        	    	out.println("PostMethod getStatusLine : "+postmethod.getStatusLine()+ "<br>");
	        	    	out.println("PostMethod getURI : "+postmethod.getURI()+ "<br>");
	        	    
	        		
	        	    postmethod.addParameter("XMLString", AT_M0Z001_bo2.getXMLString());
	        	    postmethod.addParameter("CRMXML", AT_M0Z001_bo2.getCRMXML());
	        	    postmethod.addParameter("FUNDSXML", AT_M0Z001_bo2.getFUNDSXML());
	        	    postmethod.addParameter("FUNDSXML_S", AT_M0Z001_bo2.getFUNDSXML_S());
	        	    postmethod.addParameter("FUNDSXML_D", AT_M0Z001_bo2.getFUNDSXML_D());
	        	    postmethod.addParameter("SUGXML", AT_M0Z001_bo2.getSUGXML());
	       	    
	        	    HttpClient client_CRM = HttpClientTool.createClient();
	        	    returnCode = client_CRM.executeMethod(postmethod);

					out.println("PostMethod getURI : "+returnCode + "<br>");
	
	        	    if(returnCode == HttpStatus.SC_OK){
	        	    	
	        	    }else if(returnCode == 301 || returnCode == 302) {
	        			//It's OK
	        		}else{
	        			
	        			out.println("資料上傳失敗，回傳建議書JASON資料回給CRM發生異常，請稍後再試<br>");
	        		}
	        		
	            }else{
	            	out.println("建議書資料一致不需更新<br>");
	            }
	    		
	    		out.println("建議書資料更新完成!<br>");
	        	
	        }catch(Exception e){
	        	out.println("資料上傳失敗，回傳建議書JASON資料回給CRM發生異常，請稍後再試<br>" + e.getMessage());
	        }
        
        }
        List<DTATM130> DTATM130_voList;
        AT_M0Z006 at_m0z006 = new AT_M0Z006();
        DTATM130_voList = at_m0z006.doQuery_DTATM130(APPLY_NO, null);
        String DOC_PATH = "";
        for(DTATM130 m130:DTATM130_voList){
        	DOC_PATH = m130.getDOC_PATH();
        }
        String serverType =  ConfigManager.getProperty("ebaf.ServerType");
        String IMG_PATH = "";
       	if("P".equals(serverType)){
	    	IMG_PATH = "http://was3.cathaylife.com.tw/ALWeb/task/GetApplyDoc?";
	    }else if("S".equals(serverType)){
	    	IMG_PATH = "http://swas3.cathaylife.com.tw/ALWeb/task/GetApplyDoc?";
	    }else{
	    	IMG_PATH = "http://twas3.cathaylife.com.tw/ALWeb/task/GetApplyDoc?";
	    }
        out.println(IMG_PATH+"DOC_PATH="+DOC_PATH+"&DOC_TYPE=PDF&WITH_SIGN=true");
        
	
	}


%>
<form action="GenReport.jsp" method="post">
輸入受理編號 <INPUT TYPE="TEXT" name="APPLY_NO" MAXLENGTH="10" SIZE="10" VALUE="">
<INPUT TYPE="SUBMIT">
</form>	
</BODY>
</HTML>
