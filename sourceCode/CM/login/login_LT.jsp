<!DOCTYPE html>
<html>                   
<head>
<meta charset="Big5">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta http-equiv="Pragma" content="no-cache" /> 
<meta http-equiv="Cache-Control" content="no-cache" />
<meta http-equiv="Expires" content="0" /> 

<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.lang.ObjectUtils" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="/CXL" prefix="CXL" %>

<CXL:csCommon trace="false" htmlBaseName="htmlBase" cssBaseName="cssBase" imageBaseName="imageBase" dispatcherName="dispatcher" />
<%
	String encryptUserID = "";
	boolean isSSO = false;
	//--------處理SSO部分---------
	String UserID = request.getHeader("iv-user");
	if (UserID != null && !"".equals(UserID) && !"Unauthenticated".equals(UserID)) {
		isSSO = true;
		//encryptUserID = cathay.util.Crypto.encrypt(UserID.toUpperCase());

		Class aClass = Class.forName("cathay.util.Crypto");
		java.lang.reflect.Method aMethod = aClass.getMethod("encrypt", new Class[]{String.class});
		encryptUserID = (String)aMethod.invoke(null, new String[]{UserID.toUpperCase()});
		
	}
	//----------------------------
	/*
	String strUserID = null;
	strUserID = (String) pageContext.getAttribute("userid");	
	strUserID = ( strUserID == null ? "" : strUserID.trim());
	*/
	
	//----------------------------
	request.getSession().invalidate();
	/* 處理錯誤訊息部分 */
	StringBuffer displayMessage = new StringBuffer();
	if(!isSSO){
		com.cathay.common.bo.ReturnMessage msg = null;
		
		try{
			msg = (com.cathay.common.bo.ReturnMessage) pageContext.getAttribute(com.cathay.common.util.IConstantMap.ErrMsg);
		}catch(ClassCastException cce){
			msg = null;
		}
		
		if(msg != null){
			while(msg.hasNext()){
				com.cathay.common.bo.ReturnMessage tmp = msg.next();
				//Exception訊息
				String displayException = ObjectUtils.toString(tmp.getDisplayException(),"");
				
				if (StringUtils.isBlank(displayException)){
					if (!"0".equals(ObjectUtils.toString(tmp.getReturnCode(),""))){
						displayMessage.append(ObjectUtils.toString(tmp.getMsgDesc(),"")).append("\\n\\n");
					}
				}else{
					displayMessage.append("異常原因:").append(displayException).append("\\n\\n");
					displayMessage.append("程式ID:[").append(ObjectUtils.toString(tmp.getMsgid(),"")).append("\\n\\n");
				}
			}
		}
	}
	
	String sysCode = request.getParameter("sysCode") != null ? request.getParameter("sysCode") : "";
	String url = request.getParameter("url") != null ? request.getParameter("url") : "";
	String function_id = request.getParameter("function_id") != null ? request.getParameter("function_id") : "";
	
	//
	pageContext.setAttribute("loginUrl", dispatcher+"/login/input?newTxRequest=true" );	
	// 自動SSO
	pageContext.setAttribute("isSSO", new Boolean(isSSO));
	// 自動SSO user ID
	pageContext.setAttribute("encryptUserID", encryptUserID);
	//ErrorMsg 
	pageContext.setAttribute("errorMsg", displayMessage.toString());
	
	//ErrorMsg 
	pageContext.setAttribute("platform_im", new Boolean(dispatcher.startsWith("/IMWeb/")));
	
	pageContext.setAttribute("sysCode", sysCode);
	
	pageContext.setAttribute("url", url);
	
	pageContext.setAttribute("function_id", function_id);
	
%>                            
<title>國泰人壽 - <%=request.getServerName() %></title>

<script type="text/javascript">
<!--

function check() {
	var userID = document.getElementById("userID");
	var passWD = document.getElementById("passWD");
	if(userID.value=="") { 
		alert("帳號或密碼輸入錯誤，請輸入大於等於8碼以上的帳號或密碼\n\n");
	}
	else if(passWD.value=="" || passWD.value.length<8) {
		alert("帳號或密碼輸入錯誤，請輸入大於等於8碼以上的帳號或密碼\n\n");
	}
	else {
		var submit_form = document.getElementById("login_area");
		login_area.submit();
	}
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
//-->
</script>

<style type="text/css">
*{
	font-family: 微軟正黑體, 新細明體, Arial, Helvetica, sans-serif;
	font-size: 12px;
	margin: 0px;
	padding: 0px;
}
<c:choose><c:when test="${platform_im}"> /* IM用的CSS */
body {
	background-image: url(<%=imageBase%>/CM/login/im/loginBG.jpg);
	margin-top: 40px;
}

#main_area{
	border: 5px solid #FFF;
	border-radius: 2px;
	background-color: #F9F9F9;
	width: 698px;
	margin-left:auto;
	margin-right:auto;
	padding: 6px;
	
}

#logo_area{
	height:50px;
	border:0px;
	padding: 5px 0px;
	vertical-align:middle;
	background: url(<%=imageBase%>/CM/login/top_logo.gif) left center no-repeat;
}

#logo_platform{
	//background: url(<%=imageBase%>/CM/login/im/Platform_logo.gif) left bottom no-repeat;
	height:50px;
	margin-left : 240px;
}


#ad_area{
	border: 4px solid #FFF;
	height: 260px;
	background-image: url(<%=imageBase%>/CM/login/im/main_ad.jpg);
}



#copyright{
	text-align:right;
	vertical-align:top;
	font-size: 0.6em !important;	
	color: #CCC;
	margin: 3px 0px 10px 0px;
	padding-right: 3px;
}

#login_area{
	border: 4px solid #FFF;
	border-top: 0px;
	height:205px;
	background-image: url(<%=imageBase%>/CM/login/im/form_login.jpg);
	position:relative;
}

#login_area input{
	border: 2px solid #FFF;
	border-radius: 3px;
	vertical-align:middle;
	width: 205px;
	padding: 2px;
	+border-width: 0px;
}

#login_area input:focus {
	border-color: #f60;

}

#loginId_block{
	position:absolute;
	left: 230px;
	top: 40px;
	height: 30px;
	width: 224px;
	padding-top: 4px;
	padding-left: 130px;
	background-image: url(<%=imageBase%>/CM/login/im/userId.jpg);
}

#loginPw_block{
	position:absolute;
	left: 230px;
	top: 130px;
	height: 30px;
	width: 224px;
	padding-top: 4px;
	padding-left: 130px;
	vertical-align:middle;
	background-image: url(<%=imageBase%>/CM/login/im/userPw.jpg);
}

#btn_submit{
	border: 0px;
	position:absolute;
	left: 600px;
	top: 130px;
	height: 34px;
	width: 60px;
	cursor: pointer;
	background-image: url(<%=imageBase%>/CM/login/im/login_btn_1.gif);
}

#btn_submit:hover{
	background-image: url(<%=imageBase%>/CM/login/im/login_btn_2.gif);
}

#SSO_msg{
	position:absolute;
	left: 340px;
	top: 90px;
	font-size: 18px;
	font-weight:bold;
}

#login_msg{
	display:none;
}
</c:when><c:otherwise> /* CSR用的CSS */
body {
	background: url(<%=imageBase%>/CM/login/csr/index_BG.gif) left top repeat-x;
	background-color: #FFF;
	margin-top: 5px;
}

#main_area{
	width: 845px;
	background: url(<%=imageBase%>/CM/login/csr/index_BG_inside.gif) left top repeat-x;
	background-color: #FFF;
	margin-left:auto;
	margin-right:auto;
	padding: 6px;
	border-radius: 7px;
}

#logo_area{
	height:50px;
	border:0px;
	padding: 5px 0px;
	vertical-align:middle;
	background: url(<%=imageBase%>/CM/login/top_logo.gif) left center no-repeat;
}

#ad_area{
	width: 845px;
	height: 338px;
	background-image: url(<%=imageBase%>/CM/login/csr/main_ad_border.gif);
	border-radius: 7px 7px 0px 0px;
}

#ad_area_inside{
	width: 845px;
	height: 338px;
	background: url(<%=imageBase%>/CM/login/csr/main_ad.gif) 3px 24px no-repeat;

}

#copyright{
	text-align:right;
	vertical-align:top;
	font-size: 0.9em !important;	
	color: #CCC;
	margin: 20px 0px 10px 0px;
	padding-right: 10px;
}

#login_area{
	height:150px;
	background-image: url(<%=imageBase%>/CM/login/csr/form_login.jpg);
	position:relative;
}

#login_area input{
	border: 1px solid #999;
	border-radius: 3px;
	vertical-align:middle;
	width: 130px;
	padding: 2px;
}

#login_area input:focus {
	border-color: #f60;

}

#loginId_block{
	position:absolute;
	left: 105px;
	top: 77px;
	height: 27px;
	width: 164px;
	border: 1px solid #EEE;
	background: url(<%=imageBase%>/CM/login/csr/userId.jpg) no-repeat;
	background-color: #F7F7F7;
	vertical-align:middle;
	padding-top : 5px;
	padding-left : 60px;
}

#loginPw_block{
	position:absolute;
	left: 348px;
	top: 77px;
	height: 27px;
	width: 164px;
	border: 1px solid #EEE;
	background: url(<%=imageBase%>/CM/login/csr/userPw.jpg) no-repeat;
	background-color: #F7F7F7;
	vertical-align:middle;
	padding-top : 5px;
	padding-left : 60px;
}

#btn_submit{
	border: 0px;
	position:absolute;
	left: 589px;
	top: 84px;
	height: 22px;
	width: 47px;
	cursor: pointer;
	background-image: url(<%=imageBase%>/CM/login/csr/login_btn.jpg);
}

#SSO_msg{
	position:absolute;
	left: 250px;
	top: 70px;
	font-size: 18px;
	font-weight:bold;
}

#login_msg{
	color:#900;
	position:absolute;
	left: 370px;
	top: 115px;
	font-weight:bold;
	font-size: 14px;
}
</c:otherwise></c:choose>
</style>


</head>
<body>
<div id="main_area">
	<div id="logo_area"><div id="logo_platform"></div></div>
	<div id="ad_area"><div id="ad_area_inside"></div></div>
	<form id="login_area" method="post" action="${loginUrl}">
	<input name="sysCode" type="hidden" value="${sysCode}">
	<input name="url" type="hidden" value="${url}">
	<input name="function_id" type="hidden" value="${function_id}">
		<c:choose><c:when test="${isSSO}">
			<input name='__UserID__' type='hidden' value="${encryptUserID}"/>
			<input name='__NetType__' type='hidden' value="type01"/>
			<input name='__UserID__' type='hidden' value="${encryptUserID}"/>
			<input name='userID' type='hidden' value=""/>
			<div id="SSO_msg">[ SSO 登入中... 請稍後... ]</div>
		</c:when><c:otherwise>
			<div id="loginId_block"><input type="text" name="userID" id="userID" maxlength="10" onkeyup="return autoTab(this, 10, event);" /></div>
			<div id="loginPw_block"><input type="password" name="passWD" id="passWD" maxlength="20" onKeyDown="return tabTo(event, 'btn_submit');" /></div>
			<button type="button" id="btn_submit"  onclick="check();" onKeyDown="return tabTo(event, 'userID');" >&nbsp;</button>
			<div id="login_msg">請輸入密碼, 密碼同金控入口網站</div>
			<input name="security" type="hidden" value="0">
			<input name="hostName" type="hidden" value="<%=request.getServerName()%>">
		</c:otherwise></c:choose>
		
	</form>
	<div style="text-align:center;color:red"> 帳號 / 密碼 與【金控員工入口網站】相同 </div>
	<div id="copyright">Copyright &copy; 2013 Cathay Financial Holdings. All right reserved.</div>
<div>


<script>
//<!--
	<c:if test="${isSSO}">
		var submit_form = document.getElementById("login_area");
		login_area.submit();
	</c:if>
	
	var errorMsg = "${errorMsg}";
	if(errorMsg){
		alert(errorMsg);
	}
	
	document.getElementById("userID").focus();
	
//-->
</script>
</body>
</html>

