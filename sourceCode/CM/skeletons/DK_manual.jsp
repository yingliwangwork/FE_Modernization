<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page contentType="text/html; charset=Big5" %>
<%@ include file="/html/CM/header.jsp" %>

<%@ page import="java.lang.StringBuffer" %>

<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.util.NodeTraveler" %>
<%@ page import="com.cathay.common.trx.UCData" %>

<%@ page import="org.apache.commons.lang.builder.ReflectionToStringBuilder" %>
<%@ page import="org.apache.log4j.Category" %>

<%@ taglib uri="/CXL" prefix="CXL" %>
<%! Category LOG = Category.getInstance("sys_menu.jsp"); %>
<%@ page import="com.cathay.common.service.authenticate.UserObject"%>
<%@ page import="com.cathay.common.trx.UCData"%>
<%@ page import="com.igsapp.wibc.dataobj.html.HttpSessionContext" %>

<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Map.Entry" %>

<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
                           cssBaseName="cssBase" 
                           imageBaseName="imageBase"
                           dispatcherName="dispatcher">
						   
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script> <!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
                           
<%
String strContextPath = request.getContextPath();
strContextPath = ( strContextPath == null ? "/" : strContextPath.trim());

String strSysCode = (String) pageContext.getAttribute("syscode");

HttpSessionContext ses = new HttpSessionContext(session);
UserObject userObj = (UserObject)ses.getValue(UCData.USER_OBJECT);
Boolean chkDKQ = true; //排除非國壽員工
String use_div_no = userObj.getDivNo();
if(!"0".equals(use_div_no.substring(2, 3))){
	chkDKQ = false;
}
/*
Map roles = userObj.getRoles();
for(Iterator it = (Iterator)roles.entrySet().iterator(); it.hasNext();){
	Map.Entry ent = (Entry)it.next();
	String key = ent.getKey().toString();
	if("RLDKQ".equals(key.substring(0, 5))){
		chkDKQ = false;
	}
}
*/
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
								<c:if test="<%=chkDKQ%>">	
								  <tr class="tbBlue3" >
									<td align="center">1</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKI_borrow_manual.doc">借款系統操作手冊</a></div></td>
								  </tr>
								  <tr class="tbBlue3" >
									<td align="center">2</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKJ_manual.doc">運營基金暨獎勵金系統－獎勵金作業操作手冊</a></div></td>
								  </tr>       
								  <tr class="tbBlue3" >
									<td align="center">3</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKJ1_manual.doc">運營基金暨獎勵金系統－外部調撥作業操作手冊</a></div></td>
								  </tr> 						
								  <tr class="tbBlue3" >
									<td align="center">4</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKC_manual.doc">保戶服務專款操作手冊</a></div></td>
								  </tr> 											  
								  <tr class="tbBlue3" >
									<td align="center">5</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKH1_manual.doc">公用費用核銷系統操作手冊</a></div></td>
								  </tr> 								  
								  <tr class="tbBlue3" >
									<td align="center">6</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKM_manual.doc">請款暨核銷系統操作手冊</a></div></td>
								  </tr> 		
								  <tr class="tbBlue3" >
									<td align="center">7</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKN_manual.ppt">地方帳系統操作手冊</a></div></td>
								  </tr> 		
								  <tr class="tbBlue3" >
									<td align="center">8</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKP_manual.ppt">固定週轉金系統操作手冊</a></div></td>
								  </tr>
  								  <tr class="tbBlue3" >
									<td align="center">9</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKN1_manual.doc">地方帳系統會計分錄</a></div></td>
								  </tr>
  								  <tr class="tbBlue3" >
									<td align="center">10</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKF_manual.doc">帳務日結系統會計分錄</a></div></td>
								  </tr> 
								  <tr class="tbBlue3" >
									<td align="center">11</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKP1_manual.doc">固定週轉金系統交易分錄</a></div></td>
								  </tr> 	
								  <tr class="tbBlue3" >
									<td align="center">12</td>
									<td><div align="center"><a href="/CXLDocs/DK/DKN_input_manual.ppt">地方帳系統-病歷調查費核銷輸入操作手冊</a></div></td>
								  </tr> 	
								</c:if>	
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
    <td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  </tr>
</table>

</center>

</body>
</html>
</CXL:csCommon>