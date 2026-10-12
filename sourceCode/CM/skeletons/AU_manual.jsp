<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<%@ page contentType="text/html; charset=Big5" %>
<%@ page import="java.lang.StringBuffer" %>
<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.util.NodeTraveler" %>
<%@ page import="com.cathay.common.trx.UCData" %>
<%@ page import="org.apache.commons.lang.builder.ReflectionToStringBuilder" %>
<%@ page import="org.apache.log4j.Category" %>
<%@ taglib uri="/CXL" prefix="CXL" %>
<%! Category LOG = Category.getInstance("sys_menu.jsp"); %>


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
                  <td>操作手冊</td>
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
                <tr><td class="tbBox2"><p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">操作手冊</p></td></tr>
                <tr bgcolor=#FFFFFF><td>
                      <table width="100%" border="0" cellspacing="0" cellpadding="5">
                         <tr><td>
                            <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
                                <tr class="tbBlue">
                                    <td align="center" width="100">編號</td>
                                    <td align="center">手冊名稱</td>
                                  </tr>
                                  <tr class="tbBlue3" >
                                    <td align="center">1</td>
                                    <td><div align="center"><a href="/CXLDocs/AU/Cred_Card_Manual.pdf">信用卡作業操作手冊</a></div></td>
                                  </tr>                       
								 
							</table>
                          </td></tr>
                       </table>
                </td></tr>
             </table>
           </td></tr>
       </table>
       </td></tr>
       </tbody>
            </table>
                 </td></tr>
     
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
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

