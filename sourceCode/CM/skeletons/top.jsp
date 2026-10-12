<%@ page contentType="text/html; charset=Big5" %>
<%@ page import="java.lang.StringBuffer" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.util.NodeTraveler" %>
<%@ page import="com.cathay.common.trx.UCData" %>
<%@ page import="com.cathay.common.service.authenticate.UserObject" %>
<%@ page import="com.igsapp.wibc.dataobj.html.HttpSessionContext" %>
<%@ page import="com.cathay.fm.component.FM_A0Z001" %>
<%@ taglib uri="/CXL" prefix="CXL" %>

<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
							cssBaseName="cssBase" 
							imageBaseName="imageBase"
							dispatcherName="dispatcher">

<%!
    private static String[] prodHost = { "was1.cathaylife.com.tw", "10.87.48.43",
    									 "was2.cathaylife.com.tw", "10.87.48.2", "10.87.48.6",
										 "was3.cathaylife.com.tw", "10.87.48.45", "10.87.48.46",
										 "was4.cathaylife.com.tw", "10.87.48.88",
										 "im.cathaylife.com.tw", "10.87.48.131", "10.87.48.132", "10.87.48.133",
										 "w3.cathaylife.com.tw"
										};

    private static String[] stageHost = { "wast.cathaylife.com.tw", "10.87.50.8","sw3.cathaylife.com.tw" };

    private static String[] testHost = { "test.cathaylife.com.tw", "10.87.50.41","tw3.cathaylife.com.tw" };

    private static String[][] HOSTLIST = new String[3][];
	
	private static String[] CHECK_STRING = {"<",">","'","\"","%"};

	static{
		HOSTLIST[0] = prodHost;
		HOSTLIST[1] = stageHost;
		HOSTLIST[2] = testHost;
	}

	private int getHostType(String hostName){
		int hostType = 3;
		for (int i=0; i<HOSTLIST.length; i++){
			if (hostType!=3) break;
			for(int j=0; j<HOSTLIST[i].length; j++ ){
				if (HOSTLIST[i][j].equalsIgnoreCase(hostName)){
					hostType = i;
					break;
				}
			}
		}
		return hostType;
	}


%>

<%
	HttpSessionContext sessionCtx = new HttpSessionContext(session);/* 取得 eBAF session */	
	UserObject userObj = (UserObject) sessionCtx.getValue(UCData.USER_OBJECT);/* 從 eBAF session 取得 UserObject */
	if(java.io.File.separator.equals("/")){
		imageBase = "/CXLDocs/images";
	}

	String IMAGES_SKEL = imageBase + "/CM/skeletons";

	String originalID = userObj.getOriginUserID();
	String originalName = "";
	
	request.getParameter("originalName");
	
	if (originalID!=null && originalID.length()>0){
		Hashtable htb = (new FM_A0Z001()).getEmpBasic(originalID);
		if(htb.get("EMP_NAME") != null){
			originalName = htb.get("EMP_NAME").toString();
		}
	}
	
	String authType = userObj.getAuthType();
	boolean isSwitch = (originalID!=null && originalID.length()>0);

	/* 登入者姓名 */
	String strEmpName = userObj.getEmpName();
	if (strEmpName == null) {
		strEmpName = "   "; 
	}

	/* 登入者作業單位簡稱 */
	String strOpUnitName = userObj.getOpUnitShortName();
	if (strOpUnitName == null) {
		strOpUnitName = "             "; 
	}

	String hostName = request.getServerName();

    String[] hostTypeImage = { "", "logo_stag.gif", "logo_test.gif", "logo_deve.gif" };
    int intHostType = getHostType(hostName);

	/* 僅本機、測試及平測環境可顯示環境logo */
    boolean isShowImageAndButton = intHostType > 0;

	Date now = new Date();

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>TOP</title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<style>
.datestyle{
	color:#005500;
	font-size:10pt;
	font-family:"MS Arial";
	vertical-align:middle;
	text-align:center;
	height:12px;
	padding-top:4px;
}
.timestyle{
	color:#000099; 
	font-size:9pt;
	font-family:"serif";
	background-color:#ffffff; 
	border:1px solid #003300;
	vertical-align:middle;
	text-align:center;
	padding-top:3px;
	padding-bottom:1px;
}
</style>

<script language="JavaScript" type="text/JavaScript">
<!--

var sysHour = <%=(new SimpleDateFormat("HH")).format(now) %>;
var sysMinute = <%=(new SimpleDateFormat("mm")).format(now) %>;
var sysSecond = <%=(new SimpleDateFormat("ss")).format(now) %>; 

var dateObj = new Date();
var dateObj2 = new Date();
dateObj2.setHours(sysHour, sysMinute, sysSecond);
var gap = dateObj2-dateObj;
var weekDay = new Array("日","一","二","三","四","五","六");

function show_time(){
	var now = new Date();
	var sysTime = new Date(now.getTime() + gap);
	var sysDay = sysTime.getDay();
	var sysDate = sysTime.getYear()+" / "+(sysTime.getMonth()*1+1*1)+" / "+sysTime.getDate()+" 星期"+weekDay[sysDay];
	var strHours = sysTime.getHours();
	if (strHours<10) strHours = "0"+strHours;
	var strMinutes = sysTime.getMinutes();
	if (strMinutes<10) strMinutes = "0"+strMinutes;
	var strSeconds = sysTime.getSeconds();
	if (strSeconds<10) strSeconds = "0"+strSeconds;

	dateText.innerHTML = sysDate;
	timeText.innerHTML = strHours+":"+strMinutes+":"+strSeconds; 
}

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

function doList(btn){
	window.open("forward_QA.jsp?SRC=LIST&TX=QAA0_0200&ACT=prompt","QAA0_0200","width=1000,height=600,scrollbars=yes,resizable=yes,titlebar=no");	
}

function doOpen(btn){
	window.open("forward_QA.jsp?SRC=BTN&TX=QAA0_0100&ACT=prompt","QAA0_0100","width=1000,height=600,scrollbars=yes,resizable=yes,titlebar=no");
}

function initApp(){
	show_time();
	setInterval("show_time()", 1000);
<%
		if (strOpUnitName!=null && strOpUnitName.indexOf("查無單位")>=0){
%>
		alert("作業單位錯誤: <%=strOpUnitName%>\n請連絡主管重設作業單位");
<%			
		}
%>

	MM_preloadImages('<%=imageBase%>/CM/button_01_1.gif','<%=imageBase%>CM/button_02_1.gif','<%=imageBase%>/CM/button_02_2.gif');
}

//-->
</script>

</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="initApp();">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td><table width="100%" height="50" border="0" cellpadding="0" cellspacing="0" background="<%=IMAGES_SKEL%>/top_logo_bg.jpg">
			<tr> 
				<td width="183" height="50" valign="top"><img src="<%=IMAGES_SKEL%>/top_logo.gif" width="183" height="50" border="0" align="top"></td>
<%
	if(isShowImageAndButton){
%>
				<td valign="top">
	          		<img src="<%=IMAGES_SKEL%>/<%=hostTypeImage[intHostType]%>" width="175" height="50" border="0" align="top">
				</td>
<%
	}
%>
				<td valign="bottom"><table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td height="22" valign="bottom" class="text10" colspan="3">
							<div align="right">
								使用者：<font color='#000099'><%=strEmpName%></font>　作業單位：<font color='#000099'><%=strOpUnitName%></font>
			                 	<%=("2".equals(authType)? "　<img src='"+IMAGES_SKEL+"/internet.gif' name='Image_circle' width='15' height='15' border='0' valign='botten' title='外部網路'>":"")%>
			                 	<%=isSwitch?"　<span style='color:#990000'>[ <a href=\""+dispatcher+"/login/return?newTxRequest=true\" target='_top' title='切回登入者'>原登入者："+originalName+"</a> ]</span>":""%>
							</div>
						</td>
					</tr>
					<tr>
						<td valign="top" align="center"></td>
						<td valign="top" align="center">
<%
	if(isShowImageAndButton){
%>
		              		<input name="List_btn" type="button" onclick="doList(this)" class="button" value="查詢問題單">
		              		<input name="open_btn" type="button" onclick="doOpen(this)"	class="button" value="開立問題單">
<%
	}
%>
						</td>
						<td width="390">
							<table width="197" height="28" border="0" align="right" cellpadding="0" cellspacing="0">
								<tr>
								  	<td width="92">
								  		<a href="<%=dispatcher%>/logout/logout?newTxRequest=true" target="_top" onMouseOver="MM_swapImage('Image4','','<%=IMAGES_SKEL%>/button_01_1.gif','Image5','','<%=IMAGES_SKEL%>/button_03_2.gif',1)" onMouseOut="MM_swapImgRestore()">
								  			<img src="<%=IMAGES_SKEL%>/button_01.gif" name="Image4" width="92" height="28" border="0">
								  		</a>
								  	</td>
								  	<td>
								  		<img src="<%=IMAGES_SKEL%>/button_03.gif" name="Image5" width="105" height="28" border="0">
								  	</td>
								</tr>
							</table>

		              		<table border='0' align=right  height='23' cellpadding="0" cellspacing="0">
		              			<tr height='5'><td></td></tr>
		              			<tr height='18'>
					        		<td width='16'><img src="<%=IMAGES_SKEL%>/clock.gif" name="Image_circle" width="14" height="14" border="0" valign='top'></td>
				 	            	<td width="120" id ="dateText" class='datestyle' > </td>
				 	            	<td width="50" id="timeText" class='timestyle' > </td>
				 	            	<td width="20" ></td>
		 	              		</tr>
		 	              	</table>
<%--
							<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="https://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" height="23" align="right">
								<param name="movie" value="<%=IMAGES_SKEL%>/time.swf">
								<param name="quality" value="high">
								<param name="wmode" value="transparent">
								<embed src="<%=IMAGES_SKEL%>/time.swf" width="193" height="23" align="right" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" wmode="transparent"></embed>
							</object>
--%>
		                </td>
					</tr>
				</table></td>
				<td width="50"> 
					<img src="<%=IMAGES_SKEL%>/circle.gif" name="Image_circle" width="48" height="48" border="0">
<%--
					<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" width="50" height="50">
						<param name="movie" value="<%=IMAGES_SKEL%>/line.swf">
						<param name="quality" value="high">
						<param name="wmode" value="transparent"><embed src="<%=IMAGES_SKEL%>/line.swf" width="50" height="50" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" wmode="transparent"></embed>
					</object>
--%>
				</td>
				<td width="20"><img src="<%=IMAGES_SKEL%>/top_logo_right.jpg" width="20" height="50"></td>
			</tr>
		</table></td>
	</tr>
</table>
</body>
</html>
</CXL:csCommon>