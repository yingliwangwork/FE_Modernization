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
	
%>                            
<title>國泰人壽 投資研究管理登入 <%=request.getServerName() %></title>

<script type="text/javascript">
<!--

function check() {
	var userID = document.getElementById("userID");
	var passWD = document.getElementById("passWD");
	if(userID.value=="") { 
		alert("帳號或密碼輸入錯誤\n\n");
	}
	else if(passWD.value=="") {
		alert("帳號或密碼輸入錯誤\n\n");
	}
	else {
		var submit_form = document.getElementById("login_area");
		setCookie('CATHAY_LL_LOGIN_ID',userID.value);
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

function setCookie(name,value)
{
    var exp  = new Date();    // new Date("December 31, 9998");
    exp.setTime(exp.getTime() + 7*24*60*60*1000); // 最長保存七日
    document.cookie = name + "="+ escape (value) + ";expires=" + exp.toGMTString();
}

function getCookie(name)//取cookies函
{
    var arr = document.cookie.match(new RegExp("(^| )"+name+"=([^;]*)(;|$)"));
    return (arr != null) ? unescape(arr[2])||"" : "" ;

}
	
//-->
</script>
<style type="text/css">
*{
	font-family: 微軟正黑體, 新細明體, Arial, Helvetica, sans-serif;
	font-size: 18px;
	margin: 0px;
	padding: 0px;
}
 /* IM用的CSS */
body {
	background-image: url(<%=imageBase%>/CM/login/ll/background.png);
	margin-top: 160px;
}

#main_area{
	background-image: url(<%=imageBase%>/CM/login/ll/input_bg_title.png);
	width: 673px;
	height: 390px;
	margin-left:auto;
	margin-right:auto;
}

#logo_area{	display:none;}
#logo_platform{	display:none;}
#ad_area{ display:none;}



#copyright{
	text-align:right;
	vertical-align:top;
	font-size: 0.6em !important;	
	color: #000;
	margin: 3px 0px 10px 0px;
	padding-right: 20px;
}

#login_area{
	border-top: 0px;
	height:395px;
	position:relative;
}

#login_area input{
	border: 0px solid #FFF;
	vertical-align:middle;
	width: 218px;
	padding: 2px 10px;
	+border-width: 0px;
	background-color:transparent;
}

#loginId_block{
	position:absolute;
	left: 115px;
	top: 160px;
	padding-top: 4px;
	padding-left: 130px;
}

#loginPw_block{
	position:absolute;
	left: 115px;
	top: 210px;
	padding-top: 4px;
	padding-left: 130px;
	vertical-align:middle;
}

#btn_submit{
	border: 0px;
	position:absolute;
	left: 346px;
	top: 264px;
	height: 36px;
	width: 140px;
	cursor: pointer;
	background-image: url(<%=imageBase%>/CM/login/ll/login_btn.png);
}
#SSO_msg{
	position:absolute;
	background-image: url(<%=imageBase%>/CM/login/ll/SSO_background.png);
	left: 150px;
	top: 150px;
	padding-top: 50px;
	padding-left: 100px;
	width: 250px;
	height: 150px;
	font-weight:bold;
}
#login_msg{
	display:none;
}
</style>


</head>
<body>
<div id="main_area">
	<div id="logo_area"><div id="logo_platform"></div></div>
	<div id="ad_area"><div id="ad_area_inside"></div></div>
	<form id="login_area" method="post" action="${loginUrl}">
		<input name='sysCode' type='hidden' value="LL"/>
		<input type="hidden" name="loginPlatform" value="LL" />
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
	
	var userID = document.getElementById("userID");
	var LOGIN_ID = getCookie('CATHAY_LL_LOGIN_ID')
	if(LOGIN_ID){
		userID.value = LOGIN_ID;
		document.getElementById("passWD").focus();
	}else{
		userID.focus();
	}
	
//-->
</script>
</body>
</html>

