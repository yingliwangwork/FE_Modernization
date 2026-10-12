<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.cathay.common.util.STRING"%>
<%@ taglib uri="/CXL" prefix="CXL"%>

<CXL:csCommon trace="false" htmlBaseName="htmlBase"
	cssBaseName="cssBase" imageBaseName="imageBase"
	dispatcherName="dispatcher">

<% 
	if(java.io.File.separator.equals("/")){
		imageBase = "/CXBDocs/images";
	}

	request.getSession().invalidate();

	/* ³B²z¿ù»~°T®§³¡¤À */
	com.cathay.common.bo.ReturnMessage msg = null;
	try{	
		 msg = (com.cathay.common.bo.ReturnMessage) pageContext.getAttribute(com.cathay.common.util.IConstantMap.ErrMsg);
	}catch(ClassCastException cce){
		msg = null;
	}	

	if(msg==null){
		 msg = new com.cathay.common.bo.ReturnMessage(0,"","","","","");
	}

%>

<html>
<head>
<title>³]³Æ¼t°Óµn¤J±M°Ï</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
	body {
		background-color: #44A30B;
		margin-top: 0px;
		margin-bottom: 0px;
		margin-right: 0px;
		margin-bottom: 0px;
	}
	.titleFont {
		font-size: 40px;
		font-family: "·L³n¥¿¶ÂÅé", "Microsoft JhengHei";
	}
</style>	
	<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
	<link href="<%=cssBase%>/a1.css" rel="stylesheet" type="text/css">

	<script type="text/JavaScript">
	
String.prototype.trim = function() {
	var m = this.match(/^\s*(\S+(\s+\S+)*)\s*$/);
	return (m == null) ? "" : m[1];
}
function MM_goToURL() { //v3.0
  var i, args=MM_goToURL.arguments; document.MM_returnValue = false;
  for (i=0; i<(args.length-1); i+=2) eval(args[i]+".location='"+args[i+1]+"'");
}

function check() {

	if(document.form1.userID.value == "") { 
		alert("±b¸¹©Î±K½X¿é¤J¿ù»~\n\n");
		return;
	}

	if(document.form1.passWD.value == "") {
		alert("±b¸¹©Î±K½X¿é¤J¿ù»~\n\n");
		return;
	}

    var frm = document.form1;

    //trim±b¸¹±K½X«e«áªÅ¥Õ
	frm.userID.value = frm.userID.value.trim();
	frm.passWD.value = frm.passWD.value.trim();
	frm.action = "<%=dispatcher%>/login/input?newTxRequest=true";

}

function linkChangePasswordPrompt(){
	var frm = document.form1;
	frm.action = "/CXBWeb/servlet/HttpDispatcher/login/changePasswordPrompt?sys=EE";
	form1.submit();
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

function initApp(){
	document.getElementById("userID").focus();
}

</script>
	</head>
	<body leftmargin="0" topmargin="0" onload="initApp();">
	<div align="left">		
  <table width="98%" border="0" cellspacing="0" cellpadding="0" height="80%">
	<tr>
		<td width="29" background="<%=imageBase%>/BG/login_05.jpg"></td>
		<td bgcolor="#FFFFFF">
		<table width="45%" border=0 align=center cellPadding=3 cellSpacing=1 bgcolor="#FFFFFF">
			<tr valign="middle">
				<td align="center" height="100" colspan="2" style="background-color: #F0FFE7; border: 1px solid #6B8D6D;"><span class="titleFont">³]³Æ¼t°Óµn¤J±M°Ï</span></td>
			</tr>
		</table>
		<table width="45%" border=0 align=center cellPadding=3 cellSpacing=1 bgcolor="#E7DA7E" style="margin-top: 50px;">
			<form method="POST" name="form1" action="" >
			<input type="hidden" name="function_id" value="" />
			<input type="hidden" name="url" value="" />
			<input type="hidden" name="loginPlatform" value="EE" />
				<tr valign="middle" bgcolor="E8D7A1" Height="23">
					<td height="23" colspan="2"><p align="center"><strong>¨­¤ÀÅçÃÒ</strong></p></td>
				</tr>
				<tr bgcolor="#FFFFFF">
					<td valign="middle" width="30%"><p align="center"><span lang="EN-US" >±b¸¹</span></p></td>
					<td width="295" valign="middle"  width="70%"><input type="text" name="userID" size="20" /></td>
				</tr>
				<tr bgcolor="#FFFFFF">
					<td valign="middle"><p align="center"><span lang="EN-US" >±K½X</span></p></td>
					<td width="295" valign="middle" >
						<input type="password" name="passWD" size="20" /><span class="text10">¡]ª`·N­^¤å¤j¤p¼g¡^</span>
						<input name="security" type="hidden" value="0">
						<input name="hostName" type="hidden" value="<%=request.getServerName()%>">
					</td>
				</tr>
				<tr bgcolor="#FFFFFF" align="center">
					<td colspan="2" valign="middle">
						<input type="submit" value="°e¥X" class="button" onclick="check();">
						<input type="button" value="ÅÜ§ó±K½X" class="button" onclick="linkChangePasswordPrompt();">
					</td>
				</tr>
			</form>
		</table>
		</td>
	</tr>
  </table>
  <table width="98%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td width="222"><img src="<%=imageBase%>/BG/login_07.jpg" width="222" height="47" alt=""></td>
      <td background="<%=imageBase%>/BG/login_11.jpg"><div align="center"><img src="<%=imageBase%>/BG/login_08.jpg" width="432" height="47"></div></td>
	</tr>
  </table>
	</div>
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
	
//	showmsg[msgidx][0] = (tmp.getDisplayMsgDescs()!=null)?tmp.getDisplayMsgDescs():"";
	showmsg[msgidx][0] = (tmp.getDisplayMsgDescs()!=null)?tmp.getMsgDesc():"";
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
//¿ù»~®É¤~»Ý­nAlert
function alertMessages(){
	var displayMessage = "";

	for( var varindex=0;varindex<msgs.length;varindex++){
		if (msgs[varindex][6] == ""){
			if (msgs[varindex][5] != "0"){//new
//				displayMessage+="¦^¶Ç½X:"+msgs[varindex][5]+"\n";	//new
//				displayMessage+="°T®§»¡©ú:\n"+msgs[varindex][0]+"\n\n";	//new
				displayMessage+=msgs[varindex][0]+"\n\n";	//new
			}
		}else{
			if ((msgs[varindex][6] != "") || (msgs[varindex][2] != ""))
			{
				displayMessage+="²§±`­ì¦]:"+msgs[varindex][6]+"\n";
				displayMessage+="\nµ{¦¡ID:"+msgs[varindex][2]+"\n\n";				
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

</script>	
	</html>

</CXL:csCommon>
