<%@ page contentType="text/html; charset=Big5" %>
<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.trx.UCData" %>

<%! String IMAGES_ROOT = "../../../images/CM/skeletons"; %>

<%
	com.igsapp.wibc.dataobj.html.HttpSessionContext sessionCtx = new com.igsapp.wibc.dataobj.html.HttpSessionContext(session);
	UserObject uObj = (UserObject) sessionCtx.getValue(UCData.USER_OBJECT);

	String sEmpName = uObj.getEmpName();
	
	if (sEmpName == null) {
		sEmpName = "   "; 
	}	
%>	


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>

<link href="../css/cm.css" rel="stylesheet" type="text/css">
<script language="JavaScript" src="../js/utility.js"></script>

</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad='fix()' onResize="fix()" onScroll="fix()">

<center>
<div id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility: visible;" > 
<table width="100%" height="20" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="4" background="../../../images/CM/skeletons/border_01.gif">
      <img src="../../../images/CM/skeletons/border_01.gif" width="4" height="12">
    </td>
    <td valign="top" bgcolor="#F0FBC6"> 
    <table width="100%" border="0" cellpadding="0" cellspacing="0" background="../../../images/CM/skeletons/border_03.gif">
      <tr> 
        <td height="4">
          <img src="../../../images/CM/skeletons/border_03.gif" width="12" height="4">
        </td>
      </tr>
    </table>
    <table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
      <tr> 
        <td width="20" height="24" align="center"><font size="-5">●</font></td>
        <td><b>歡迎光臨<font color="#FFCC00"><%=sEmpName%></font>使用本系統!</b></td>
        <td width="223" align="right"></td>
      </tr>
    </table>
    </td>
    <td width="4" background="../../../images/CM/skeletons/border_02.gif">
      <img src="../../../images/CM/skeletons/border_02.gif" width="4" height="12">
    </td>
    <td width="5" class="tbBox">
      <img src="../../../images/CM/skeletons/ecblank.gif" width="5" height="1">
    </td>
  </tr>
</table>
</div> 

<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td>&nbsp;</td>
  </tr>
</table>


<!--<div id="bar1" style="position:absolute; left:0; top:40; width:100%; z-index:9; visibility: visible;" > -->
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="4" background="../../../images/CM/skeletons/border_01.gif">
      <img src="../../../images/CM/skeletons/border_01.gif" width="4" height="12">
    </td>
    <td width="100%" bgcolor="#F0FBC6" valign="top">
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr> 
        <td valign="top"> 
        <table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
          <tr>
            <td class="tbBox2">
              <img src="../../../images/CM/skeletons/icon_dot11.gif" width="18" height="16">業務通告訊息
            </td>
          </tr>
          <tr bgcolor=#FFFFFF> 
            <td>
            <table width="100%" border="0" cellspacing="1" cellpadding="15">
              <tr> 
                <td> 
                <table width="100%" border="0" cellpadding="5" cellspacing="1" bgcolor="#B5B49D">
                  <tr> 
                    <td bgcolor="#F7F5D9" class="tbBox4" align="right">
                      <FONT color=#e90080>3天前的最新消息</FONT> 
                      <SELECT name=fdname1 class="text10" id=fdname1 style="WIDTH: 90px; HEIGHT: 22px">
                        <option selected>請選擇日期</option>
                      </SELECT>
                    <TABLE width="98%" border=0 align="center" cellPadding=7 cellSpacing=0 class="text10">
                      <TR> 
                        <TD width=30 height="25" vAlign=top class=first>08/20</TD>
                        <TD vAlign=top class=text10>
                          <A href="http://query.cathlife.com.tw/employee/pros/bonus/bonus.htm">國泰債券基金申購狀況日報表已出爐</A><BR>
                          可至國泰人園地/整合行銷專區/其他專區/投信基金專區查看<span class="textGray">&lt;整合行銷科&gt;</span>
                        </TD>
                      </TR>
                      <TR> 
                        <TD width=30 height="25" vAlign=top class=first>08/20</TD>
                        <TD vAlign=top class=small></TD>
                      </TR>
                    </TABLE>
                    </td>
                  </tr>
                </table>
                </td>
              </tr>
            </table>
            </td>
          </tr>
        </table>
        </td>
      </tr>
    </table>
    </td>
    <td width="4" background="../../../images/CM/skeletons/border_02.gif">
      <img src="../../../images/CM/skeletons/border_02.gif" width="4" height="12">
    </td>
    <td width="5" class="tbBox">
        <img src="../../../images/CM/skeletons/ecblank.gif" width="5" height="1">
     </td>
  </tr>
</table>
<!--</div>-->
</body>
</html>

