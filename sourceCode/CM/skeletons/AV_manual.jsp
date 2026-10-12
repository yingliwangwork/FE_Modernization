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

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {color: #FF0000}
.style2 {color: #CCCCCC}
.style3 {color: #999999}
.style4 {color: #FFFFFF}
-->
</style>
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
                                    <td><div align="center"><a href="/CXLDocs/AV/Scanner_install.doc">掃描器安裝手冊</a></div></td>
                                </tr>                                                                  
                                <tr class="tbBlue3" >
                                    <td align="center">2</td>
                                    <td><div align="center"><a href="/CXLDocs/AV/Scanner_setting.doc">掃瞄設定手冊</a></div></td>
                                </tr>
                                <tr class="tbBlue3" >
                                    <td align="center">3</td>
                                    <td><div align="center"><a href="/CXLDocs/AV/AT_Service_OP.doc"></a><A href="/CXLDocs/AV/AV_FAQ.doc">影像系統常見問題圖文版下載</A></div></td>
                                </tr>
                                <tr class="tbBlue3" >
                                    <td align="center">4</td>
                                    <td><div align="center"><a href="/CXLDocs/AV/AC_Scan_Manual.doc"></a><A href="\\cxlcsfs\08-Tools\SCAN_EXPLAIN.doc"></A><a href="/CXLDocs/AV/DP_Manual.doc"></a><a href="/CXLDocs/AV/AT_Service_OP.doc">新契約服務中心影像作業說明</a></div></td>
                                </tr>
								<tr class="tbBlue3" >
                                	<td align="center">5</td>
                                	<td><div align="center"><a href="/CXLDocs/AV/AV_MedicalGuide.doc"></a><a href="/CXLDocs/AV/DP_Manual.doc">放款掃描作業操作手冊.doc</a></div></td>
                              	</tr>
								<tr class="tbBlue3" >
								    <td align="center">6</td>
								    <td><div align="center"><A href="/CXLDocs/AV/ED_Manual.doc"></A><a href="/CXLDocs/AV/AV_MedicalGuide.doc">醫療理賠資料庫掃描說明</a></div></td>
							    </tr>
								<tr class="tbBlue3" >
								    <td align="center">7</td>
								    <td><div align="center"><a href="/CXLDocs/AV/DP_Manual.doc"></a><A href="\AVWeb\html\AV\doc\AV_FAQ.doc"></A><A href="/CXLDocs/AV/ED_Manual.doc">文件庫存管理說明文件</A><BR>
								    </div></td>
							    </tr>
								<tr class="tbBlue3" >
								    <td align="center">8</td>
								    <td><div align="center"><a href="/CXLDocs/AV/AC_Scan_Manual.doc">送金單盤點操作說明</a></div></td>
							    </tr>
								<tr class="tbBlue3" >
									<td align="center">9</td>
									<td><div align="center">
									<!--
									<a href="<%=htmlBase%>/CM/skeletons/AA_GuidePage.jsp">
									-->
									<a href="https://w3.cathaylife.com.tw/portal/wps/myportal/!ut/p/c5/pZJdC4IwFIZ_Sz8gduZwzEvzq8EyMTLzRryIGKR2Ef3-NCyHrRF5dvnw8J4dXlSg7jXVXZ6rm2yb6oJyVNAysWyGeQTONqQ28E3qiITsABju-JGW8GVc6G2IwBUOFj4DCxORxmEy8MGe8lXw4r9kT2zP9_FoTykPODFlZ-Nuf9jxLFvhGtvPPGqyvQxmXM0mc2xlN7N96Pv16QuG3-k6rv5Nx9Xtn9zQR20jlcZp85VO6bjSmnjd1id0rffD5CC55Et3sXgAMbbhmw!!/dl3/d3/L2dJQSEvUUt3QS9ZQnZ3LzZfUDI1ODFJRzA5T0Y2NTBJTVI5TFAzUzAwODE!/" target="_blank">
									理賠相關文件下載</a></div></td>
								</tr>
								<tr class="tbBlue3" >
									<td align="center">10</td>
									<td><div align="center"><a href="/CXLDocs/AV/AV_NotScan_Guide.doc">車險預約投保服務中心作業規定(新增不同意件不需掃描部份)</a></div></td>
								</tr>
								<tr class="tbBlue3" >
									<td align="center">11</td>
								<td><div align="center"><a href="/CXLDocs/AV/AA_AVE05800Menu.doc">影像歸檔批號(箱號)列印問題處理</a></div></td>
								</tr>
								<tr class="tbBlue3" >
								<td align="center">12</td>
								<td><div align="center"><a href="/CXLDocs/AV/AV_SVR_SCAN.pdf">墊繳送金單影像掃描手冊</a></div></td>
								</tr>
                            </table>
                          </td></tr>
                    </table>
                  </td></tr>
                         <tr><td>
                            <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
                                <tr class="tbBlue">
                                    <td align="center" width="100">編號</td>
                                    <td align="center">程式下載</td>
                                  </tr>
                                  <tr class="tbBlue3" >
                                    <td align="center">1</td>
                                    <td><div align="center">JAVA程式<br><a href="/CXLDocs/ZZ/JAVA.exe" class="style2">JRE142</a>　　 <a href="/CXLDocs/ZZ/jre-6u26-windows-i586.exe" class="style2">JRE6</a></div></td>
                                  </tr>                                                                  
                                <tr class="tbBlue3" >
                                    <td align="center">2</td>
                                    <td><div align="center"><A HREF="\\cxlsvr01\免費資源區\add_to_admin.exe" class="style3">我要變管理者(add_to_admin)</a>，初次使用完畢後，請重新登出系統使程式生效</div></td>
                                  </tr>
                                <tr class="tbBlue3" >
                                    <td align="center">3</td>
                                    <td><div align="center"><a href="/CXLDocs/ZZ/PrintOnlineSetup-2.02.exe" class="style1">報表列印程式 -雙十精巧版 (2008-10-10)</a></div></td>
                                  </tr>
                              	<tr class="tbBlue3" >
                                	<td align="center">4</td>
                                	<td>
                                		<div align="center"><span class="style1"><a href="/CXLDocs/ZZ/PrintOnlineSetup-2.02.exe" class="style1"></a></span><A href="/CXLDocs/AV/TrustSite.reg" class="style2">信任網站與安全性設定檔下載</A></div>                                	</td>
                              	</tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">5</td>
                              	  <td><div align="center"><A href="/CXLDocs/AV/TrustSite.reg" class="style2"></A><A href="/CXLDocs/AV/CXLAV.exe" class="style2">AV懶人包下載</A><A HREF="\\cxlsvr01\免費資源區\add_to_admin.exe" class="style3"></a>，初次使用完畢後，請重新登出系統使程式生效</div></td>
                           	  </tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">6</td>
                              	  <td><div align="center"><span class="style2"><A href="/CXLDocs/AV/SCAN_TEST.exe">掃瞄器測試程式</A></span></div></td>
                           	  </tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">7</td>
                              	  <td><div align="center" class="style3"><a href="/CXLDocs/AV/AV220C2_V110.zip">掃描器驅動程式FORAV220C2</a></div></td>
                           	  </tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">8</td>
                              	  <td><div align="center" class="style3"><A HREF="/CXLDocs/AV/3of9_new.TTF" class="style3">3of9_new字型檔</a></div></td>
                           	  </tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">9</td>
                              	  <td><div align="center" class="style3">
								  
								  <A href="/CXLDocs/AV/BarCodePrint_1020514.exe">條碼標籤列印程式<font color=red>1020514</font></A></div></td>
                          	  </tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">10</td>
                              	  <td><div align="center" class="style3"><A href="/CXLDocs/AV/MSCOMCTL.OCX" class="style4">若條碼標籤列印程式執行有問題,MSCOMCTL.OC,請另存目標到此路徑C:\WINDOWS\system32</A></div></td>
                           	  </tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">11</td>
                              	  <td><div align="center" class="style3"><a href="/CXLDocs/AV/AC_Scan.zip" class="style3">送金單批次掃描程式相關檔案</a></div></td>
                           	  </tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">12</td>
                              	  <td><div align="center" class="style3"><a href="/CXLDocs/ZZ/printer_ud0_2kxp03_x86_pcl_emul_sys_zh_tw.exe" class="style2">IBM印表機驅動程式(適用機型IBM - InfoPrint 11xx - 12xx - 13xx - 14xx - 15xx Windows 32-bit Universal Print Driver)</a></div></td>
                           	  </tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">13</td>
                              	  <td><div align="center"><a href="/CXLDocs/AV/32.exe">3+2郵遞區號</a></div></td>
                           	  </tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">14</td>
                              	  <td><div align="center">送金單掃瞄:請先閱讀<a href="\\cxlsvr01\免費資源區\送金單掃瞄安裝說明.doc">送金單掃瞄安裝說明.doc</a>，再行下載<a href="\\cxlsvr01\免費資源區\送金單掃瞄.exe">送金單掃瞄.exe</a></div></td>
                           	  </tr>
                              	<tr class="tbBlue3" >
                              	  <td align="center">15</td>
                              	  <td><div align="center"><a href="/CXLDocs/AV/ip.bat">我的電腦</a></div></td>
                           	  </tr>
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

