<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>交易碼輸入</title>
<link href="<%=cssBase%>/B2C_cm.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#ffffff" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<script>

//------------------------------------------------------------------------------
<!--控制 div 隱藏顯示-->
function theMask(szLayer){
	if(document.getElementById(szLayer).style.visibility == "hidden"){
		document.getElementById(szLayer).style.visibility = "visible";
		settheErr_Layer();
	}else{
		document.getElementById(szLayer).style.visibility = "hidden";
		settheErr_Layer();
	}
}

//------------------------------------------------------------------------------
function settheErr_Layer(){

	var theErr_Layer = document.getElementById('theErr_Layer');

	if(theErr_Layer.style.visibility == "visible"){
		theErr_Layer.style.width = document.body.clientWidth + "px" ;
		theErr_Layer.style.height = document.body.clientHeight + "px" ;
		theErr_Layer.style.left = (document.body.clientWidth/2)-200 + "px" ;
		theErr_Layer.style.top = document.body.scrollTop +100 + "px" ;
	}else{
		theErr_Layer.style.width = "0px" ;
		theErr_Layer.style.height = "0px" ;
		theErr_Layer.style.left = "0px" ;
		theErr_Layer.style.top = "0px" ;
	}
}

function doThePopup(aMsg){
	var theErr_Layer_MSG = document.getElementById('theErr_Layer_MSG');
	theErr_Layer_MSG.innerHTML = " <span class='err_layer'> " + aMsg + "</span> ";
	//theErr_Layer_MSG.innerHTML = aMsg;
	theMask('theErr_Layer');
}
</script>

<div id="theErr_Layer" style="position:absolute;visibility:hidden;z-index:1;" align="center">
	<table border="0" cellspacing="0" cellpadding="2" align="center" width="100%" height="100%" style="background-color: transparent; background-image: url(<%=imageBase%>/CM/B2C/pop_notice.jpg);background-repeat: no-repeat;">
		<tr height="60"><td></td></tr>
		<tr>
			<td>&nbsp;</td>
			<td valign="top" style="color:#333333" >
				<div id="theErr_Layer_MSG" class="theErr_Layer">&nbsp;</div>
				<br>
				<p>
					<div align="center" style="width:400px;">
						<input type="button" onclick="theMask('theErr_Layer')" class="button" value="確　定">
					</div>
				</p>
			</td>
		</tr>
	</table>
</div>

		<table width="97%" border="0" cellpadding="0" cellspacing="1">
            <tr>
              <td>&nbsp;</td>
              <td align="right">&nbsp;</td>
            </tr>
            <tr>
              <td><span class="textContainTitle"><img src="<%=imageBase%>/CM/B2C/icon_1.gif" width="15" height="13">請輸入網路交易密碼</span></td>
              <td align="right">&nbsp;</td>
            </tr>
          </table>

          <table class="tbBox2" border="0" cellpadding="0" cellspacing="1" width="97%">
            <tbody>
              <tr>
                <td width="20%" class="tbGray" >網路交易密碼</td>
                <td width="20%" class="tbWhite" >
                	<input type=password id=pwd name="PWD" maxlength="12" size="15" onkeyup ="capLock()">
               </td>
                <td width="60%" class="tbWhite" >
                 <div>
                 <font color='red'>
			    <span class="highlight" id ="msg1" style ="display:none">提醒您! 大小寫視為不同，您現在輸入的是 大寫模式 喔！ </span>
				<span class="highlight" id ="msg2" style ="display:none">提醒您! 大小寫視為不同，您現在輸入的是 小寫模式 喔！ </span>
				<span class="highlight" id ="msg3" style ="display:none">提醒您! 您現在輸入的是 數字模式 喔！ </span>
				<span class="highlight" id ="msg4" style ="display:none">提醒您! 您現在輸入的不是 英文及數字  喔！ </span>
				<span class="highlight" id ="jimmy" style ="display:none"><input type="text" name="kimmy" disabled/></span>
			</font>
			  </div>
		  </td>
              </tr>
            </tbody>
          </table>

          <table width="97%" border="0" cellspacing="1" cellpadding="0">
            <tr>
              <td>
                <DIV class="textOrange"> <img src="<%=imageBase%>/CM/B2C/notes1.gif" width="54" height="50"><br>
                  1. 英文字母大小寫視為不同字，設定及每次輸入時敬請特別注意。<br>
                  2. 密碼輸入3次錯誤將自動鎖碼，為維護您的權益，請您至個人資料中的「補發網路交易密碼」申請密碼補發或由本人撥打客服專線0800-036-599進行補發。
				</div>
			</td>
            </tr>
          </table>

<script>
<%--
	//檢查是否為 Caps Lock
	//function capLock(e){
	//	kc = e.keyCode?e.keyCode:e.which;
	//	sk = e.shiftKey?e.shiftKey:((kc == 16)?true:false);
	//	if(((kc >= 65 && kc <= 90) && !sk)||((kc >= 97 && kc <= 122) && sk)){
	//		document.getElementById('msg1').style.display = 'none';
	//		document.getElementById('msg2').style.display = 'block';
	//	}else{
	//		document.getElementById('msg1').style.display = 'block';
	//		document.getElementById('msg2').style.display = 'none';
	//	}
	//}
--%>

	//檢查輸入大小寫及數值
	function capLock(){

		settheErr_Layer();

		var aPwd = document.getElementById("pwd").value;

		//若沒有輸入值
		if(aPwd.length <= 0){
			document.getElementById('msg1').style.display = 'none';
			document.getElementById('msg2').style.display = 'none';
			document.getElementById('msg3').style.display = 'none';
			document.getElementById('msg4').style.display = 'none';
			return;
		}

		//取出輸入值的 index
		var aIndex = aPwd.length - 1;
		//取出最後一個輸入值
		var aPwdChar = aPwd.charAt(aIndex);

		//若為英文大寫
		re = /[A-Z]/;
		if(re.test(aPwdChar)){
			document.getElementById('msg1').style.display = 'block';
			document.getElementById('msg2').style.display = 'none';
			document.getElementById('msg3').style.display = 'none';
			document.getElementById('msg4').style.display = 'none';
			return;
		}

		//若為英交小寫
		re = /[a-z]/;
		if(re.test(aPwdChar)){
			document.getElementById('msg1').style.display = 'none';
			document.getElementById('msg2').style.display = 'block';
			document.getElementById('msg3').style.display = 'none';
			document.getElementById('msg4').style.display = 'none';
			return;
		}

		//若為數字
		re = /[0-9]/;
		if(re.test(aPwdChar)){
			document.getElementById('msg1').style.display = 'none';
			document.getElementById('msg2').style.display = 'none';
			document.getElementById('msg3').style.display = 'block';
			document.getElementById('msg4').style.display = 'none';
			return;
		}

		//若為非英文&數值
		document.getElementById('msg1').style.display = 'none';
		document.getElementById('msg2').style.display = 'none';
		document.getElementById('msg3').style.display = 'none';
		document.getElementById('msg4').style.display = 'block';
		return;

		//alert("提醒您~ 您輸入的密碼格式錯誤，應為 6~12 位英文及數字混合");
		//aPwd.focus();

	}

	//檢查是否輸入6碼以上的數字及英文
	//用法如下:
	//function doQuery(){
	//var isPass = doCheckPassWord();
	//	if(!isPass){
	//		return;
	//	}
	//do submit.......
	//}
	function doCheckPassWord(){

		var aPwd = document.getElementById("pwd");

		//檢查長度是否 6 碼以上
		if(aPwd.value.length < 6){
			doThePopup("提醒您~ 密碼輸入的位數不足 6 碼");
			aPwd.focus();
			return false;
		}

		//檢查是否在 a-z, A-Z, 0-9 之間的值
		//若有任一個不在a-z, A-Z, 0-9 之間的值
		re = /[^A-z0-9]/;
		if(re.test(aPwd.value)){
			doThePopup("提醒您~ 您輸入的密碼格式錯誤，<br>應為 6~12 位英文及數字混合");
			aPwd.focus();
			return false;
		}

		//若沒有包含任一 a-z, A-Z 之間的值
		re = /[A-z]/;
		if(!re.test(aPwd.value)){
			doThePopup("提醒您~ 您輸入的密碼格式錯誤，<br>應為 6~12 位英文及數字混合, 您沒有輸入英文");
			aPwd.focus();
			return false;
		}

<%--
		//2010-07-21 允許可以輸入純英文
		////若沒有包含任一 0-9 之間的值
		//re = /[0-9]/;
		//if(!re.test(aPwd.value)){
		//	doThePopup("提醒您~ 您輸入的密碼格式錯誤，應為 6~12 位英文及數字混合, 您沒有輸入數字");
		//	aPwd.focus();
		//	return false;
		//}
--%>
		return true;

	}

<%--
	//function doAlertPwd(){
	//	alert("請確認交易(變更)內容，確認無誤，請輸入網路交易密碼。");
	//}
--%>

	<%
	com.igsapp.wibc.dataobj.html.HttpResponseContext messageResp
    	= new com.igsapp.wibc.dataobj.html.HttpResponseContext(request);

    com.cathay.common.bo.ReturnMessage message;

    try{
		 message = (com.cathay.common.bo.ReturnMessage) messageResp.getOutputData(com.cathay.common.util.IConstantMap.ErrMsg);
	}catch(ClassCastException cce){
		message = null;
	}

	if(message==null || message.getReturnCode() == com.cathay.util.ReturnCode.OK){
%>
		setTimeout("thePopup()", 100);
<%
	}
%>

	function thePopup(){

		doThePopup("請確認交易(變更)內容，確認無誤，請輸入網路交易密碼。");

	}

</script>

</body>
</html>