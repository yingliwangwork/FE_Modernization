<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page contentType="text/html; charset=big5" %>

<%@ page import="java.lang.StringBuffer" %>

<%@ page import=" java.io.File" %>
<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.util.NodeTraveler" %>
<%@ page import="com.cathay.common.trx.UCData" %>
<%@ page import="com.cathay.util.FileStoreUtil" %>

<%@ page import="org.apache.commons.lang.builder.ReflectionToStringBuilder" %>
<%@ page import="org.apache.log4j.Category" %>

<%@ taglib uri="/CXL" prefix="CXL" %>
<%! Category LOG = Category.getInstance("AA_GuidePage.jsp"); %>


<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
                           cssBaseName="cssBase" 
                           imageBaseName="imageBase"
                           dispatcherName="dispatcher">
                           
<%
String strContextPath = request.getContextPath();
strContextPath = ( strContextPath == null ? "/" : strContextPath.trim());

String strSysCode = (String) pageContext.getAttribute("syscode");

String saveRoot = "/CXLDocs/AV/directive";  


%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">

<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
<center>

<table id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9" height="30" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="4" background="<%=imageBase%>/CM/border_01.gif">
    	<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
    </td>
    <td valign="top" bgcolor="#F0FBC6"> 
    	<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
	        <tr>
	          <td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
	        </tr>
	    </table>

      	<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
        	<tr>
          		<td width="20" height="24"> <div align="center"><font size="-5">●</font></div></td>
          		<td>理賠相關文件下載</td>
          		<td><div align="right"></div></td>
        	</tr>
      	</table>
    </td>
    <td width="4" background="<%=imageBase%>/CM/border_02.gif">
    	<img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12">
    </td>
    <td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  </tr>
</table>

<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td>　</td>
  </tr>
</table>

<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="4" background="<%=imageBase%>/CM/border_01.gif">
    	<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
    </td>
    <td width="100%" valign="top" bgcolor="#F0FBC6">
    
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
      	<tr><td valign="top"> 
          
          	 <table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
              <tbody>
                <tr>
                  <td class="tbBox2"><p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">作業手冊下載</p></td>
                </tr>
                <tr bgcolor=#FFFFFF>
                  <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="5">
                      <tr>
                        <td>
                          <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
                            <tr class="tbBlue3" >
                             <!--  <td width="28%"><div align="center"><a href="/CXLDocs/AV/AA_Service_OP.doc">理賠服務中心作業手冊</a></div></td> -->
                              <td width="28%"><div align="center"><a href="/CXLDocs/AV/AA_Service_Edu_Data.doc">理賠服務中心作業手冊</a></div></td>
							  <td width="34%"><div align="center"><a href="/CXLDocs/AV/9804.ppt">9804講習資料</a></div></td>
                              <td width="38%"><div align="center"></div></td>
							 <!--  <td width="38%"><div align="center"><a href="/CXLDocs/AV/AA_ServiceRep_OP.ppt">理賠服務中心補全流程說明</a></div></td> -->
							</tr>
							<!--  <tr class="tbBlue3" >
                              <td width="28%"><div align="center"><a href="/CXLDocs/AV/AA_ServiceRep_OP.ppt">理賠服務中心補全流程說明</a></div></td>
                              <td width="34%"><div align="center"></div></td> 
                           	  <td width="38%"><div align="center"></div></td>
                            </tr> -->
                        </table></td>
                      </tr>
                  </table></td>
                </tr>
              </tbody>
            </table>            <p>&nbsp;</p>
			
			 <!-- <table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
              <tbody>
                <tr>
                  <td class="tbBox2"><p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">操作手冊下載</p></td>
                </tr>
                <tr bgcolor=#FFFFFF>
                  <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="5">
                      <tr>
                        <td>
                          <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
                            <tr class="tbBlue3" >
                              <td width="28%"><div align="center"><a href="/CXLDocs/AV/AA_ServiceCenter_manual.doc">理賠服務中心操作手冊</a></div></td>
                              <td width="34%"></td>
							  <td width="38%"></td>
                            </tr>
						 </table></td>
                      </tr>
                  </table></td>
                </tr>
              </tbody>
            </table>            <p>&nbsp;</p> -->
						
			<table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
              <tbody>
                <tr>
                  <td class="tbBox2"><p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">理賠文件下載(<FONT COLOR="#FF0000">請按右鍵另存目標</FONT>)</p></td>
                </tr>
                <tr bgcolor=#FFFFFF>
                  <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="5">
                      <tr>
                        <td>
                          <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
                            <tr class="tbBlue3" >
                              <td width="28%"><div align="center"><a href="<%=saveRoot%>/30000200004.pdf">理賠申請書</a></div></td>
                              <td width="38%"><div align="center"><a href="<%=saveRoot%>/30000400001.pdf">理賠申請書_附件一_多受款人</a></div></td>
						      <td width="34%"><div align="center"><a href="<%=saveRoot%>/30006300002.pdf">門診收據合計表</a></div></td>
					        </tr>
							<tr class="tbBlue3" >
							  <td width="28%"><div align="center"><a href="<%=saveRoot%>/300073.pdf">編制內學團專用門診收據合計表</a></div></td>						  
		 	                  <td width="38%"><div align="center"></div></td>
						      <td width="34%"><div align="center"></div></td>
					        </tr>
                        </table></td>
                      </tr>
                  </table></td>
                </tr>
              </tbody>
            </table>            <p>&nbsp;</p>
            
			<table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
              <tbody>
                <tr>
                  <td class="tbBox2"><p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">理賠聲明書及同意書下載(<FONT COLOR="#FF0000">請按右鍵另存目標</FONT>)</p></td>
                </tr>
                <tr bgcolor=#FFFFFF>
                  <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="5">
                      <tr>
                        <td>
                          <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
                            <tr class="tbBlue3" >
                              <td width="28%"><div align="center"><a href="<%=saveRoot%>/3000293.pdf">監護人聲明同意書</a></div></td>
							  <td width="38%"><div align="center"><a href="<%=saveRoot%>/3000294.pdf">繼承人授權聲明書</a></div></td>			      
		 	                  <td width="34%"><div align="center"><a href="<%=saveRoot%>/3000291.pdf">外幣保單給付聲明書</a></div></td>
					        </tr>
							<tr class="tbBlue3" >
                              <td width="28%"><div align="center"><a href="<%=saveRoot%>/3000292.pdf">申請部份給付聲明書</a></div></td>
							  <td width="38%"><div align="center"></div></td>						  
		 	                  <td width="34%"><div align="center"></div></td>
					        </tr>
						</table></td>
                      </tr>
                  </table></td>
                </tr>
              </tbody>
            </table>            <p>&nbsp;</p>
			
					
			
			<P></p>            
         </td></tr>
      </table>
			  <p>&nbsp;</p>
			
			<table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
              <tbody>
                <tr><td class="tbBox2"><p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">理賠導引頁下載(<FONT COLOR="#FF0000">請按右鍵另存目標</FONT>)</p></td></tr>
                <tr bgcolor=#FFFFFF><td>
                  	<table width="100%" border="0" cellspacing="0" cellpadding="5">
                     	<tr><td>
                        	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
                            	
								<tr class="tbBlue3" >
                                	
                                	<td><div align="center"><a href="<%=saveRoot%>/300008.pdf">診斷書</a></div></td>
                              		
                                	<td><div align="center"><a href="<%=saveRoot%>/300009.pdf">切片報告</a></div></td>
								  
                                	<td><div align="center"><a href="<%=saveRoot%>/300010.pdf">檢驗報告</a></div></td>
								</tr>	
                                <tr class="tbBlue3" >
                                	
                                	<td><div align="center"><a href="<%=saveRoot%>/300011.pdf">死亡證明書</a></div></td>
                              		
                                	<td><div align="center"><a href="<%=saveRoot%>/300012.pdf">出生證明</a></div></td>
								   
                                	<td><div align="center"><a href="<%=saveRoot%>/300013.pdf">用藥明細(如處方箋)</a></div></td>
								</tr>
							    <tr class="tbBlue3" >
                                	
                                	<td><div align="center"><a href="<%=saveRoot%>/300014.pdf">住院收據正本</a></div></td>
                              		
                                	<td><div align="center"><a href="<%=saveRoot%>/300015.pdf">緊急醫療轉送證明</a></div></td>
								    
                                	<td><div align="center"><a href="<%=saveRoot%>/300016.pdf">醫療費用明細</a></div></td>
								</tr>
							    <tr class="tbBlue3" >
                                
                                	<td><div align="center"><a href="<%=saveRoot%>/300017.pdf">住院收據副本</a></div></td>
                              		
                                	<td><div align="center"><a href="<%=saveRoot%>/300018.pdf">健保局或同業給付證明</a></div></td>
								   
                                	<td><div align="center"><a href="<%=saveRoot%>/300019.pdf">戶籍謄本(戶口名簿)</a></div></td>
								</tr>
							    <tr class="tbBlue3" >
                                	
                                	<td><div align="center"><a href="<%=saveRoot%>/300020.pdf">社保身份證明文件</a></div></td>
                              		
                                	<td><div align="center"><a href="<%=saveRoot%>/300021.pdf">學籍資料證明文件</a></div></td>
								  
                                	<td><div align="center"><a href="<%=saveRoot%>/300022.pdf">無記名團險身份證明文件</a></div></td>
								</tr>
								<tr class="tbBlue3" >
                                	
                                	<td><div align="center"><a href="<%=saveRoot%>/30002399999.pdf">健保局同意書</a></div></td>
                              		
                                	<td><div align="center"><a href="<%=saveRoot%>/300024.pdf">交通事故調查同意書</a></div></td>
								 
                                	<td><div align="center"><a href="<%=saveRoot%>/300025.pdf">特殊醫院調查同意書</a></div></td>
								</tr>
								<tr class="tbBlue3" >
                                	
                                	<td><div align="center"><a href="<%=saveRoot%>/300029.pdf">聲明同意書</a></div></td>

									<td><div align="center"><a href="<%=saveRoot%>/300030.pdf">委任辦理書</a></div></td>
                              		
                                	<td><div align="center"><a href="<%=saveRoot%>/300031.pdf">海外文書認證</a></div></td>
    							</tr>
								<tr class="tbBlue3" >
                                	
                                	<td><div align="center"><a href="<%=saveRoot%>/300032.pdf">經手人招攬報告</a></div></td>

									<td><div align="center"><a href="<%=saveRoot%>/300033.pdf">死亡宣告判決書</a></div></td>
                              		
                                	<td><div align="center"><a href="<%=saveRoot%>/300034.pdf">禁治產宣告裁定書</a></div></td>
    							</tr>
								<tr class="tbBlue3" >
                                	
                                	<td><div align="center"><a href="<%=saveRoot%>/300035.pdf">保險事故通知書</a></div></td>

									<td><div align="center"><a href="<%=saveRoot%>/300036.pdf">身份證明文件影本</a></div></td>
                              		
									<td><div align="center"><a href="<%=saveRoot%>/300066.pdf">門診收據正本</a></div></td>
                                </tr>
								<tr class="tbBlue3" >
                        									
									<td><div align="center"><a href="<%=saveRoot%>/300067.pdf">門診收據副本</a></div></td>
                              		
                                	<td><div align="center"><a href="<%=saveRoot%>/300038.pdf">其它附件</a></div></td>
								
                                    <td><div align="center"><a href="<%=saveRoot%>/300889.pdf">補全文件</a></div></td>
								</tr>
									
							</table>
                      	</td></tr>
                    </table>
                  </td></tr>
              </tbody>
            </table>
      
			
      
    </td>
    <td width="4" background="<%=imageBase%>/CM/border_02.gif">
    	<img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12">
    </td>
    <td width="5" class="tbBox"><img src="<%=imageBase%>/ecblank.gif" width="5" height="1"></td>
  </tr>
</table>

</center>

</body>
</html>
</CXL:csCommon>