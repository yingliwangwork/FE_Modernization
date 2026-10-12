<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="/CXL" prefix="CXL" %>

<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
                            cssBaseName="cssBase" 
                            imageBaseName="imageBase"
                            dispatcherName="dispatcher" >

<%
//	String cssBase = "/CXLWeb/html/CM/css";
//	String dispatcher = "/CXLWeb/servlet/HttpDispatcher";
//	String imageBase = "/CXLWeb/images";
	if(java.io.File.separator.equals("/")){
		imageBase = "/CXLDocs/images";
	}

	String strUserID = null;
	strUserID = (String) pageContext.getAttribute("userid");	
	strUserID = ( strUserID == null ? "" : strUserID.trim());	

	request.getSession().invalidate();
	
	/* 處理錯誤訊息部分 */
    com.cathay.common.bo.ReturnMessage msg = null;
    try{	
		 msg = (com.cathay.common.bo.ReturnMessage) pageContext.getAttribute(com.cathay.common.util.IConstantMap.ErrMsg);
	}catch(ClassCastException cce){
		msg = null;
	}	
	
	if(msg==null){
		 msg = new com.cathay.common.bo.ReturnMessage(0,"","","","","");
	}
	
	
	StringBuffer topMessage = new StringBuffer();

%>
<html>
<head>
<title>國泰人壽 - <%=request.getServerName() %></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/JavaScript">
function MM_goToURL() { //v3.0
  var i, args=MM_goToURL.arguments; document.MM_returnValue = false;
  for (i=0; i<(args.length-1); i+=2) eval(args[i]+".location='"+args[i+1]+"'");
}

function check() {
	if(document.form1.userID.value=="") { 
		alert("請輸入帳號");
	}
	else if(document.form1.passWD.value=="") {
		alert("請輸入密碼");
	}
	else {
		document.form1.action = "<%=dispatcher%>/login/input?newTxRequest=true";
		document.form1.submit();
	}
}

function clear() {
	document.form1.passWD.value == "";
}

var isNN = (navigator.appName.indexOf("Netscape")!=-1);

function autoTab(input,len, e) {
	var keyCode = (isNN) ? e.which : e.keyCode; 
	var filter = (isNN) ? [0,8,9] : [0,8,9,16,17,18,37,38,39,40,46];
	
	if(input.value.length >= len && !containsElement(filter,keyCode)) {
		input.value = input.value.slice(0, len);
		input.form[(getIndex(input)+1) % input.form.length].focus();
	}
	
	function containsElement(arr, ele) {
		var found = false, index = 0;
		while(!found && index < arr.length)
			if(arr[index] == ele)
				found = true;
			else
				index++;
		return found;
	}

	function getIndex(input) {
		var index = -1, i = 0, found = false;
		while (i < input.form.length && index == -1)
			if (input.form[i] == input)
				index = i;
			else 
				i++;
			return index;
	}
	return true
}

function tabTo(e, n){
	var keyCode = (isNN) ? e.which : e.keyCode;
	if(keyCode == 9){
		document.getElementById(n).focus();
		return false;
	}else if(keyCode == 13){
		check();
		return false;
	}
	return true;
}

</script>
</head>
<body bgcolor="#ffffff" background="<%=imageBase%>/CM/index_BG.gif" leftmargin="0" topmargin="0">
<form name="form1" method="post">
<table border="0" cellpadding="0" cellspacing="0" width="1000">
  <tr>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="12" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="164" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="25" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="125" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="93" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="150" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="29" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="51" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="22" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="9" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="206" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="114" height="1" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="1" border="0" alt=""></td>
  </tr>
  <tr>
    <td rowspan="11"><img src="<%=imageBase%>/CM/index_r1_c1.gif" width="12" height="657"></td>
   <td rowspan="2" colspan="2"><img name="index_r1_c2" src="<%=imageBase%>/CM/index_r1_c2.gif" width="189" height="83" border="0" alt=""></td>
    <td colspan="7" rowspan="2" background="<%=imageBase%>/CM/index_r1_c4.gif">&nbsp;</td>
   <td><img src="<%=imageBase%>/CM/index_r1_c11.gif" alt="" name="index_r1_c11" width="206" height="67" border="0" usemap="#index_r1_c11Map"></td>
    <td rowspan="11">&nbsp;</td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="67" border="0" alt=""></td>
  </tr>
  <tr>
    <td rowspan="4" background="<%=imageBase%>/CM/index_r2_c11.jpg">&nbsp;</td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="16" border="0" alt=""></td>
  </tr>
  <tr>
   <td colspan="9"><img name="index_r3_c2" src="<%=imageBase%>/CM/index_r3_c2.gif" width="668" height="9" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="9" border="0" alt=""></td>
  </tr>
  <tr>
    <td colspan="8">
        <img src="<%=imageBase%>/CM/loginMain.gif" width="659" height="298" border="0" alt="">
   </td>
   <td><img name="index_r4_c10" src="<%=imageBase%>/CM/index_r4_c10.gif" width="9" height="304" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="304" border="0" alt=""></td>
  </tr>
  <tr>
   <td colspan="9"><img name="index_r5_c2" src="<%=imageBase%>/CM/index_r5_c2.gif" width="668" height="9" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="9" border="0" alt=""></td>
  </tr>
  <tr>
   <td><img name="index_r6_c2" src="<%=imageBase%>/CM/index_r6_c2.gif" width="164" height="81" border="0" alt=""></td>
    <td colspan="6"><img src="<%=imageBase%>/CM/index_r6_c3.gif" width="473" height="81"></td>
   <td colspan="2"><img name="index_r6_c9" src="<%=imageBase%>/CM/index_r6_c9.gif" width="31" height="81" border="0" alt=""></td>
    <td rowspan="4"><img src="<%=imageBase%>/CM/index_r6_c11.gif" width="206" height="108"></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="81" border="0" alt=""></td>
  </tr>
  <tr>
   <td rowspan="3"><img name="index_r7_c2" src="<%=imageBase%>/CM/index_r7_c2.gif" width="164" height="27" border="0" alt=""></td>
   <td colspan="2"><img name="index_r7_c3" src="<%=imageBase%>/CM/index_r7_c3.gif" width="150" height="4" border="0" alt=""></td>
   <td rowspan="3"><img name="index_r7_c5" src="<%=imageBase%>/CM/index_r7_c5.gif" width="93" height="27" border="0" alt=""></td>
   <td><img name="index_r7_c6" src="<%=imageBase%>/CM/index_r7_c6.gif" width="150" height="4" border="0" alt=""></td>
   <td rowspan="3"><img name="index_r7_c7" src="<%=imageBase%>/CM/index_r7_c7.gif" width="29" height="27" border="0" alt=""></td>
    <td rowspan="3"><a href="#" id="loginLink" onclick="check();"><img name="index_r7_c8" src="<%=imageBase%>/CM/index_r7_c8.gif" width="51" height="27" border="0" alt=""></a></td>
   <td rowspan="3" colspan="2"><img name="index_r7_c9" src="<%=imageBase%>/CM/index_r7_c9.gif" width="31" height="27" border="0" alt=""></td>
   <td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="4" border="0" alt=""></td>
  </tr>
  <tr>
    <td colspan="2" bgcolor="#F7F7F7"><input name="userID" type="text" class="textBoxNew" size="22" maxlength="10" onKeyUp="return autoTab(this, 10, event);"></td>
    <td bgcolor="#F7F7F7">
    	<input name="passWD" type="password" class="textBoxNew" size="22" maxlength="20" onKeyDown="return tabTo(event, 'loginLink');">
    	<input name="security" type="hidden" value="0">
    	<input name="hostName" type="hidden" value="<%=request.getServerName()%>">
    </td>
    <td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="19" border="0" alt=""></td>
  </tr>
  <tr>
  	<td colspan="2"><img name="index_r9_c3" src="<%=imageBase%>/CM/index_r9_c3.gif" width="150" height="4" border="0" alt=""></td>
   	<td><img name="index_r9_c6" src="<%=imageBase%>/CM/index_r9_c6.gif" width="150" height="4" border="0" alt=""></td>
   	<td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="4" border="0" alt=""></td>
  </tr>
  <tr>
   	<td colspan="10"><img src="<%=imageBase%>/CM/index_r10_c2.gif" alt="" name="index_r10_c2" width="874" height="91" border="0" usemap="#index_r10_c2Map"></td>
   	<td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="91" border="0" alt=""></td>
  </tr>
  <tr>
    <td colspan="10" align="right"><img src="<%=imageBase%>/CM/index_r11_c2.gif" width="41" height="53"></td>
   	<td><img src="<%=imageBase%>/CM/images_new/.gif" width="1" height="53" border="0" alt=""></td>
  </tr>
</table>
<div style="top:-135;left:390;position:relative;color:#990000;font-size:10pt">請輸入密碼, 密碼同金控入口網站</div>
<map name="index_r10_c2Map">
  <area shape="rect" coords="742,31,834,66" href="https://www.macromedia.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" target="_blank">
</map>
<map name="index_r1_c11Map">
  <area shape="rect" coords="40,46,97,63" href="#">
  <area shape="rect" coords="103,46,170,63" href="#">
</map>
</form>
</body>
<!-- show error msg -->
<script language="JavaScript">
msgs = new Array(<%=msg.getLength()%>);
<%
int msglen = msg.getLength();
int msgidx = 0;
String[][] showmsg = new String[msglen][7];

com.cathay.common.bo.ReturnMessage tmp=null;
while(msg.hasNext()){
	tmp=msg.next();
	
	showmsg[msgidx][0] = (tmp.getDisplayMsgDescs()!=null)?tmp.getDisplayMsgDescs():"";
	showmsg[msgidx][1] = (tmp.getMsgid()!=null)?tmp.getMsgid():"";
	showmsg[msgidx][2] = (tmp.getSysid()!=null)?tmp.getSysid():"";
	showmsg[msgidx][3] = (tmp.getType()!=null)?tmp.getType():"";
	showmsg[msgidx][4] = (tmp.getUrl()!=null)?tmp.getUrl():"";
	showmsg[msgidx][5] = tmp.getReturnCode()+"";
	showmsg[msgidx][6] = (tmp.getDisplayException()!=null)?tmp.getDisplayException():"";
%>
msgs[<%=msgidx%>] = new Array("<%=showmsg[msgidx][0]%>","<%=showmsg[msgidx][1]%>","<%=showmsg[msgidx][2]%>","<%=showmsg[msgidx][3]%>","<%=showmsg[msgidx][4]%>","<%=showmsg[msgidx][5]%>","<%=showmsg[msgidx][6]%>");
<%
	msgidx++;
}
%>
//錯誤時才需要Alert
function alertMessages(){
	var displayMessage = "";

	for( var varindex=0;varindex<msgs.length;varindex++){
		if (msgs[varindex][6] == ""){
			if (msgs[varindex][5] != "0"){//new
				displayMessage+="回傳碼:"+msgs[varindex][5]+"\n";	//new
				displayMessage+="訊息說明:\n"+msgs[varindex][0]+"\n\n";	//new
			}
		}else{
			if ((msgs[varindex][6] != "") || (msgs[varindex][2] != ""))
			{
				displayMessage+="異常原因:"+msgs[varindex][6]+"\n";
				displayMessage+="\n程式ID:"+msgs[varindex][2]+"\n\n";				
			}
		}
	}
	
	if (displayMessage != ""){
		alert(displayMessage);
	}
}

var msgindex = 0;

function nextMessage(){
		var idx = msgindex+1;
		if (idx >= msgs.length){
			msgindex = msgs.length-1;
		}else if(idx <= 0){
			msgindex = 0;
		}else{
			msgindex++;
		}
		displayMessage();
}

function prevMessage(){
		var idx = msgindex-1;
		if (idx >= msgs.length){
			msgindex = msgs.length-1;
		}else if(idx <= 0){
			msgindex = 0;
		}else{
			msgindex--;
		}
		displayMessage();
}

function displayMessage(){
	alertMessages();
}

function checkDisplayType(type){
    switch(type){
    	case "E": return "textError";
        case "N": return "textNotify";
        case "W":
        default: return "textWarning";
    }
}
document.form1.userID.focus();
alertMessages();

<%

Date today = new Date();
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

Calendar startCa =  Calendar.getInstance();
Calendar endCa =  Calendar.getInstance();
startCa.set(2007,1, 9,0,0,0);
endCa.set (2007,1,16,18,0,0);
Date startDate = startCa.getTime();
Date endDate = endCa.getTime();

boolean isValidate = (today.after(startDate) && today.before(endDate));
if (isValidate){
%>
	alert("<%=topMessage.toString() %>");
<%
}
%>
</script>
</html>

</CXL:csCommon>
