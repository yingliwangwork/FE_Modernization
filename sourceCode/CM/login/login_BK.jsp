<%@ page language="java" contentType="text/html; charset=utf-8"%>
<%@ include file="/html/CM/header.jsp"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.cathay.common.util.STRING"%>
<%
	if (java.io.File.separator.equals("/")) {
		imageBase = "/CXBDocs/images";
	}

	String strUserID = null;
	strUserID = (String) pageContext.getAttribute("userid");
	strUserID = (strUserID == null ? "" : strUserID.trim());

	request.getSession().invalidate();

	/* 處理錯誤訊息部分 */
	com.cathay.common.bo.ReturnMessage msg = null;
	try {
		msg = (com.cathay.common.bo.ReturnMessage) pageContext
				.getAttribute(com.cathay.common.util.IConstantMap.ErrMsg);
	} catch (ClassCastException cce) {
		msg = null;
	}

	if (msg == null) {
		msg = new com.cathay.common.bo.ReturnMessage(0, "", "", "", "", "");
	}

	StringBuffer topMessage = new StringBuffer();

	int subURL = dispatcher.indexOf("/servlet");

	String BK_location = "/BKWeb" + dispatcher.substring(subURL);
%>

<html>
<head>
<title>銀保專區</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	background-image: url(images/index_bg.jpg);
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
	background-repeat: repeat-x;
	background-color: #E8D7A1;
}
-->
</style>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<link href="<%=cssBase%>/a1.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" type="text/css"
	href="/BKWeb/html/BK/ZZ/css/base.css" />
<link rel="stylesheet" type="text/css"
	href="/BKWeb/html/BK/ZZ/css/common/component.css" />
<link rel="stylesheet"
	href="/BKWeb/html/BK/ZZ/js/bootstrap/bootstrap-table.min.css">
<script language="JavaScript" type="text/JavaScript">
function MM_goToURL() { //v3.0
  var i, args=MM_goToURL.arguments; document.MM_returnValue = false;
  for (i=0; i<(args.length-1); i+=2) eval(args[i]+".location='"+args[i+1]+"'");
}

function check() {
	if(document.form1.userID.value=="") { 
		alert("帳號或密碼輸入錯誤\n\n");
	}
	else if(document.form1.passWD.value=="") {
		alert("帳號或密碼輸入錯誤\n\n");
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
<body bgcolor="#ffffff" background="<%=imageBase%>/CM/index_BG.gif"
	leftmargin="0" topmargin="0">
	<div align="center">
		<table width="780" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td width="395"><img src="<%=imageBase%>/CM/index_02.jpg"
					width="365" height="175" /></td>
				<td width="385"><img src="<%=imageBase%>/CM/index_03.jpg"
					width="416" height="175" /></td>
			</tr>
		</table>
		<table width="780" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="19"><img src="<%=imageBase%>/CM/index_05_1.gif"
					width="19" height="38" /></td>
				<TD background="<%=imageBase%>/CM/index_06_1.jpg" class="a1">
					&nbsp;</TD>
				<td width="129" background="<%=imageBase%>/CM/index_27.gif"><img
					src="<%=imageBase%>/CM/index_09.jpg" width="129" height="38" /></td>
			</tr>
		</table>
		<table width="780" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td background="<%=imageBase%>/CM/index_27_1.gif"><table
						width="95%" border="0" align="center" cellpadding="0"
						cellspacing="0">
						<tr>

							<td><br />
							<br />
								<form method="POST" name="form1" action="">
									<input type="hidden" name="function_id" value="" /> <input
										type="hidden" name="url" value="" /> <input type="hidden"
										name="loginPlatform" value="BK" />
									<table border="0" align="center" cellpadding="0"
										cellspacing="0" width="50%">
										<tr valign="middle" bgcolor="E8D7A1" class="a3" height="23">
											<td height="23" colspan="2"><p align="center">
													<strong><span lang="EN-US">身份驗證</span></strong>
												</p></td>
										</tr>
										<tr bgcolor="#FFFFFF" height="24">
											<td width="101" height="24" valign="middle" class="a4"><p
													align="center">
													<span lang="EN-US">通路代號</span>
												</p></td>
											<td width="267" height="24" valign="middle" class="a4"><span
												lang="EN-US"> <input type="text" name="userID"
													size="20" /></span></td>
										</tr>
										<tr bgcolor="#FFFFFF" height="24">
											<td height="24" valign="middle" class="a4"><p
													align="center">
													<span lang="EN-US">通路密碼</span>
												</p></td>
											<td width="267" height="24" valign="middle" class="a4"><span
												lang="EN-US"> <input type="password" name="passWD"
													size="20" /></span> <span class="text10">（注意英文大小寫）</span> <input
												name="security" type="hidden" value="0"> <input
												name="hostName" type="hidden"
												value="<%=request.getServerName()%>"></td>
										</tr>

										<tr bgcolor="#FFFFFF" height="24">
											<td height="24" colspan="2" valign="middle" class="a4"><p
													align="center">
													<span lang="EN-US"><input type="submit"
														name="submit" value="送出" onclick="check();"></span>
												</p></td>
										</tr>
										<tr bgcolor="#FFFFFF" height="24">
											<td><a href="<%=BK_location%>/BKRG_0100/prompt">我要註冊</a></td>

										</tr>
										<tr bgcolor="#FFFFFF" height="24">
											<td><a href="<%=BK_location%>/BKRG_0300/prompt">忘記密碼</a></td>
										</tr>
									</table>
								</form> <br />
							<br />
							<br />
							<br />
							<br /></td>
						</tr>
					</table></td>
			</tr>
		</table>
		<table width="780" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td><img src="<%=imageBase%>/CM/index_28.gif" width="780"
					height="54" /></td>
			</tr>
		</table>
	</div>

	<div class="modal fade" id="successModal" tabindex="-1"
		aria-labelledby="success-modalLabel" aria-hidden="true">
		<div
			class="modal-dialog modal-dialog-centered modal-dialog-scrollable custom-modal custom-modal-xs">
			<div class="modal-content">
				<div class="modal-header border-0">
					<a href="#" class="ml-auto" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true"><img class="close-btn"
							src="/BKWeb/html/BK/ZZ/img/icon/close-bk.svg" alt="close">
					</a>
				</div>
				<div class="modal-body">
					<div class="delete-box">
						<img class="warning-icon"
							src="/BKWeb/html/BK/ZZ/img/icon/warning-icon.svg" alt="warning" />
						<div class="title" id='successText'></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>


<script type="text/javascript"
	src="/BKWeb/html/BK/ZZ/js/jquery/jquery-3.5.1.min.js"></script>
<script src="/BKWeb/html/BK/ZZ/js/bootstrap/bootstrap.bundle.min.js"></script>
<!-- show error msg -->
<script language="JavaScript">

var $j = jQuery.noConflict();

$j(document).ready(function () {
	
	$j('#successText').empty()
    $j('#successText').append('目前已改為新的登入頁，2秒後為您轉到新的登入頁');
    $j('#successModal').modal('show');
    
    setTimeout(() => {
		location.href = '/BKWeb/html/BK/R0/BKR0_0100/BKR00100.jsp';
	}, 2000);
	
});


msgs = new Array(<%=msg.getLength()%>);
<%int msglen = msg.getLength();
			int msgidx = 0;
			String[][] showmsg = new String[msglen][7];

			com.cathay.common.bo.ReturnMessage tmp = null;
			while (msg.hasNext()) {
				tmp = msg.next();

				//	showmsg[msgidx][0] = (tmp.getDisplayMsgDescs()!=null)?tmp.getDisplayMsgDescs():"";
				showmsg[msgidx][0] = (tmp.getDisplayMsgDescs() != null) ? tmp.getMsgDesc() : "";
				showmsg[msgidx][1] = (tmp.getMsgid() != null) ? tmp.getMsgid() : "";
				showmsg[msgidx][2] = (tmp.getSysid() != null) ? tmp.getSysid() : "";
				showmsg[msgidx][3] = (tmp.getType() != null) ? tmp.getType() : "";
				showmsg[msgidx][4] = (tmp.getUrl() != null) ? tmp.getUrl() : "";
				showmsg[msgidx][5] = tmp.getReturnCode() + "";
				showmsg[msgidx][6] = (tmp.getDisplayException() != null) ? tmp.getDisplayException() : "";%>
msgs[<%=msgidx%>] = new Array("<%=showmsg[msgidx][0]%>","<%=showmsg[msgidx][1]%>","<%=showmsg[msgidx][2]%>","<%=showmsg[msgidx][3]%>","<%=showmsg[msgidx][4]%>","<%=showmsg[msgidx][5]%>","<%=showmsg[msgidx][6]%>");
<%msgidx++;
			}%>
//錯誤時才需要Alert
function alertMessages(){
	var displayMessage = "";

	for( var varindex=0;varindex<msgs.length;varindex++){
		if (msgs[varindex][6] == ""){
			if (msgs[varindex][5] != "0"){//new
//				displayMessage+="回傳碼:"+msgs[varindex][5]+"\n";	//new
//				displayMessage+="訊息說明:\n"+msgs[varindex][0]+"\n\n";	//new
				displayMessage+=msgs[varindex][0]+"\n\n";	//new
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

<%Date today = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

			Calendar startCa = Calendar.getInstance();
			Calendar endCa = Calendar.getInstance();
			startCa.set(2007, 1, 9, 0, 0, 0);
			endCa.set(2007, 1, 16, 18, 0, 0);
			Date startDate = startCa.getTime();
			Date endDate = endCa.getTime();

			boolean isValidate = (today.after(startDate) && today.before(endDate));
			if (isValidate) {%>
	alert("<%=topMessage.toString()%>");
<%}%>
</script>
</html>