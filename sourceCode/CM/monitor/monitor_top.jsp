<%@ page contentType="text/html; charset=Big5" %>
<%@ page import="java.lang.StringBuffer" %>
<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.util.NodeTraveler" %>
<%@ page import="com.cathay.common.trx.UCData" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ taglib uri="/CXL" prefix="CXL" %>
<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
                           cssBaseName="cssBase" 
                           imageBaseName="imageBase"
                           dispatcherName="dispatcher">
<%
	/* 登入者姓名 */
	String strServerName = request.getParameter( "serverName" );
	if (strServerName == null || strServerName.equals("null")) {
		strServerName = "   "; 
	}

	/* 登入者作業單位簡稱 */
	String strServerIP = request.getParameter( "serverIP" );
	if (strServerIP == null || strServerIP.equals("null")) {
		strServerIP = "             "; 
	}
	
	String strIsProd = request.getParameter( "isProd" );
	String fontColor="#000099"; 
	if (strIsProd != null && strIsProd.equals("1")) {
		fontColor = "#990000"; 
	}
	
	Date now = new Date();
	
%>	

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>TOP</title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/JavaScript">

	var sysHour = <%=(new SimpleDateFormat("HH")).format(now) %>;
	var sysMinute = <%=(new SimpleDateFormat("mm")).format(now) %>;
	var sysSecond = <%=(new SimpleDateFormat("ss")).format(now) %>; 
	
	var dateObj = new Date();
	var dateObj2 = new Date();
	dateObj2.setHours(sysHour, sysMinute, sysSecond);
	var gap = dateObj2-dateObj;
	
	function show_time(){
		var now = new Date();
		var sysTime = new Date(now.getTime() + gap);
		var sysDate = sysTime.getYear()+"/"+(sysTime.getMonth()*1+1*1)+"/"+sysTime.getDate();
		var strHours = sysTime.getHours();
		if (strHours<10) strHours = "0"+strHours;
		var strMinutes = sysTime.getMinutes();
		if (strMinutes<10) strMinutes = "0"+strMinutes;
		var strSeconds = sysTime.getSeconds();
		if (strSeconds<10) strSeconds = "0"+strSeconds;
		
		dateText.innerHTML = sysDate;
		timeText.innerHTML = strHours+":"+strMinutes+":"+strSeconds; 
	}
</script>
<style>
.datestyle{
	color:#005500;
	font-size:9pt;
	font-family:"MS Arial";
	vertical-align:middle;
	text-align:center;
	height:12px;
	padding-top:2px;
}
.timestyle{
	color:#000099; 
	font-size:8pt;
	font-family:"MS Arial";
	background-color:#ffffff; 
	border:1px solid #003300;
	vertical-align:middle;
	text-align:center;
	padding-top:2px;
	padding-bottom:1px;
}
</style>
</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('<%=imageBase%>/CM/button_01_1.gif','<%=imageBase%>/CM/button_02_1.gif','<%=imageBase%>/CM/button_02_2.gif')">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td><table width="100%" height="50" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/skeletons/top_logo_bg.jpg">
        <tr>
          <td width="183" height="50" valign="top">
          		<img src="<%=imageBase%>/CM/skeletons/top_logo.gif" width="183" height="50" border="0" align="top">
          </td>
          <td valign="bottom">
          <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td height="22" valign="bottom" class="text10" colspan=5> 
                  <div align="right">Host Name：<font color="<%=fontColor%>"><b><%=strServerName%></b></font>　IP：<font color="<%=fontColor%>"><b><%=strServerIP%></b></font></div>
                 </td>
              </tr>
              <tr>
              	<td>
              		<table border='0' align=right><tr >
			        	<td  style='font-size:9pt' width='55'>系統時間 : </td>
		 	            <td width="60" id = dateText class='datestyle' > </td>
		 	            <td width="45" id = timeText class='timestyle' > </td>
		 	            <td width="10" > </td>
 	              	</tr></table>
 	            </td>
                <td width="200">
             <!--   	//登入登出-->
                	<table width="197" height="28" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                      <td width="92">
                      		<a href="<%=dispatcher%>/logout/logout?newTxRequest=true" target="_top" onMouseOver="MM_swapImage('Image4','','<%=imageBase%>/CM/skeletons/button_01_1.gif','Image5','','<%=imageBase%>/CM/skeletons/button_03_2.gif',1)" onMouseOut="MM_swapImgRestore()">
                      		<img src="<%=imageBase%>/CM/skeletons/button_01.gif" name="Image4" width="92" height="28" border="0">
                      	</a>
                      </td>
                      <td>                
                     		<img src="<%=imageBase%>/CM/skeletons/button_03.gif" name="Image5" width="105" height="28" border="0">
                      </td>
                    </tr>
                  </table>
                  
                  <!-- 
                  <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="https://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" height="23" align="right">
                    <param name="movie" value="<%=imageBase%>/CM/skeletons/time.swf">
                    <param name="quality" value="high">
                    <param name="wmode" value="transparent">
                    <embed src="<%=imageBase%>/CM/skeletons/time.swf" width="193" height="23" align="right" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" wmode="transparent"></embed></object>
                    -->
                </td>
              </tr>
            </table>
          </td>
          <td width="50"> 
              <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="https://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" width="50" height="50">
              <param name="movie" value="<%=imageBase%>/CM/skeletons/line.swf">
              <param name="quality" value="high">
              <param name="wmode" value="transparent">
              <embed src="<%=imageBase%>/CM/skeletons/line.swf" width="50" height="50" quality="high" pluginspage="https://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" wmode="transparent"></embed>
              </object> 
          </td>
          <td width="20"><img src="<%=imageBase%>/CM/skeletons/top_logo_right.jpg" width="20" height="50"></td>
        </tr>
      </table></td>
  </tr>
</table>
<script language="JavaScript" type="text/JavaScript">

	var timer01 = setInterval("show_time()", 1000);

</script>
</body>
<script language="JavaScript" type="text/JavaScript">

<!--
function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
//-->
</script>

</html>
</CXL:csCommon>