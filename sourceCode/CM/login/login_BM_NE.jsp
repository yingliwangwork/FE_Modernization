<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ include file="/html/CM/header.jsp" %>
<%@ page import="java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.cathay.common.util.STRING"%>
<%@ page import="com.cathay.common.util.FieldOptionList"%>
<%@ page import="org.apache.log4j.Logger"%>
<%
	if(java.io.File.separator.equals("/")){
		imageBase = "/CXBDocs/images";
	}
	String strUserID = (String) pageContext.getAttribute("userid");
	strUserID = ( strUserID == null ? "" : strUserID.trim());
	request.getSession().invalidate();
	com.cathay.common.bo.ReturnMessage msg = null;
	try{
		msg = (com.cathay.common.bo.ReturnMessage) pageContext.getAttribute(com.cathay.common.util.IConstantMap.ErrMsg);
	}catch(ClassCastException cce){
		msg = null;
	}
	if(msg==null){
		 msg = new com.cathay.common.bo.ReturnMessage(0,"","","","","");
	}
	int subURL = dispatcher.indexOf("/servlet");
	String BM_location = "/BMWeb"+dispatcher.substring(subURL);

	// 是否要顯示訊息視窗
	String showMsg;
	try{
		showMsg = FieldOptionList.getName("ZZ", "login_messageBox_BM", "showMsg");
	} catch(Exception e){
		Logger log = Logger.getLogger("login_BM_NE");
		log.error(e);

		showMsg = "";
	}

	pageContext.setAttribute("showMsg", showMsg);
%>

<html>
	<head>
		<title>學校名冊登錄系統</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<link href="<%=htmlBase%>/BG/css/BM_CM.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="<%=htmlBase%>/CM/js/jquery/jquery-3.6.0.js"></script>
		<script type="text/javascript" src="<%=htmlBase%>/BM/js/BM_EUtil.js"></script><!-- 其他 -->
		<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
		<script type="text/javascript" src="<%=htmlBase%>/BM/js/elementCreate.js"></script><!-- 元素產生器 -->
		<script src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
		<script src="${htmlBase}/BM/js/BM_MESSAGE.js"></script>

		<script type="text/javascript">
			String.prototype.trim = function() {
				var m = this.match(/^\s*(\S+(\s+\S+)*)\s*$/);
				return (m == null) ? "" : m[1];
			}
			function MM_goToURL() { //v3.0
			  var i, args=MM_goToURL.arguments; document.MM_returnValue = false;
			  for (i=0; i<(args.length-1); i+=2) eval(args[i]+".location='"+args[i+1]+"'");
			}
			function check(btn) {
				if(document.form1.userID.value == "") {
					BM_POPUP.alert({txt: "帳號或密碼輸入錯誤"});
				} else if(document.form1.passWD.value == "") {
					BM_POPUP.alert({txt: "帳號或密碼輸入錯誤"});
				} else {
				    var frm = document.form1;
				    //trim帳號密碼前後空白
					frm.userID.value = frm.userID.value.trim();
					frm.passWD.value = frm.passWD.value.trim();
					frm.action = "<%=dispatcher%>/login/inputB2B?newTxRequest=true";

					submitOnce(btn);
				}
			}
			function renewCaptcha(){
				$('ContactAuthNo').value="";
				var webcontext = '${dispatcher}/login/';
				
				var ajaxRequest = new CSRUtil.AjaxHandler.request(webcontext);
				ajaxRequest.post('captcha', {
					time : (new Date()).getTime(),
				}, function(resp) {
					$('PEcaptchaImg').setAttribute("src","data:image/png;base64,"+resp.imgBase64String);
				});
             }
			function messageHandler(){

				var msgs = new Array(<%=msg.getLength()%>);
				<%
				int msglen = msg.getLength();
				int msgidx = 0;
				String[][] showmsg = new String[msglen][7];
				com.cathay.common.bo.ReturnMessage tmp=null;
				while(msg.hasNext()){
					tmp=msg.next();
					String displayMsgDescs = tmp.getDisplayMsgDescs();
					if(displayMsgDescs!=null){
						displayMsgDescs = displayMsgDescs.replaceAll("\\r\\n", "<br>").replaceAll("\\n", "<br>").replaceAll("\\r", "<br>");
					}else{
						displayMsgDescs = "";
					}
					String msgid = tmp.getMsgid();
					if(msgid!=null){
						msgid = msgid.replaceAll("\\r\\n", "<br>").replaceAll("\\n", "<br>").replaceAll("\\r", "<br>");
					}else{
						msgid = "";
					}
					String displayException = tmp.getDisplayException();
					if(displayException!=null){
						displayException = displayException.replaceAll("\\r\\n", "<br>").replaceAll("\\n", "<br>").replaceAll("\\r", "<br>");
					}else{
						displayException = "";
					}
					showmsg[msgidx][0] = displayMsgDescs;
					showmsg[msgidx][1] = msgid;
					showmsg[msgidx][2] = (tmp.getSysid()!=null)?tmp.getSysid():"";
					showmsg[msgidx][3] = (tmp.getType()!=null)?tmp.getType():"";
					showmsg[msgidx][4] = (tmp.getUrl()!=null)?tmp.getUrl():"";
					showmsg[msgidx][5] = tmp.getReturnCode()+"";
					showmsg[msgidx][6] = displayException;
				%>
					msgs[<%=msgidx%>] = new Array(
						"<%=showmsg[msgidx][0]%>".replace(/<br>/gi, "\n")
						,"<%=showmsg[msgidx][1]%>".replace(/<br>/gi, "\n"),"<%=showmsg[msgidx][2]%>"
						,"<%=showmsg[msgidx][3]%>","<%=showmsg[msgidx][4]%>","<%=showmsg[msgidx][5]%>","<%=showmsg[msgidx][6]%>");
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
								displayMessage+=msgs[varindex][0]+"\n\n";	//new
							}
						}else{
							if ((msgs[varindex][6] != "") || (msgs[varindex][2] != "")){
								displayMessage+="異常原因:"+msgs[varindex][6]+"\n";
								displayMessage+="\n程式ID:"+msgs[varindex][2]+"\n\n";
							}
						}
					}
					if (displayMessage != ""){
						BM_POPUP.alert({txt: displayMessage});
					}
				}

				alertMessages();
				document.form1.userID.focus();
			}			
						
			function initApp(){
				messageHandler();

				<c:if test="${showMsg eq 'Y'}">
					var windowName = "公告訊息";
					var attribute = "status=no,toolbar=no,resizable=no,scrollbars=no,width=500,height=325,top=200,left=200";

					var theForm = document.form1;
					theForm.setAttribute( "target", windowName );

					theForm.action = "${htmlBase}/CM/login/messageBox_BM.jsp";

					window.open('about:blank',windowName,attribute);
					theForm.submit();
					
					theForm.removeAttribute("target");
					theForm.action = "";
				</c:if>
				
				BM_EUtil.detectCapsLock(null, {"msg":"您現在的輸入模式為「大寫模式」!!!"});
				renewCaptcha();
				$w('focus keydown keyup').each(
					function (action) {
						$('passWD').observe(action, function () {
							if (this.value) {
								$('pw_hint').style.display="none";
							} else {
								$('pw_hint').style.display="block";
							}
						});
					}
				);

				$('passWD').observe('blur', function () {
					$('pw_hint').style.display="none";
				});
			}
			
			function doOpenWindow(){
				window.open("<%=BM_location%>/BMM0_9999/prompt");
			}
			
			function doOpenWindow_BMM00024() {
				window.open("<%=dispatcher%>/BMM0_0024/prompt");
			}
		</script>
	</head>
	<body leftmargin="0" topmargin="0" onload="initApp();">
		<div align="center">
			<table align="center" border="0" cellpadding="0" cellspacing="0">
				<tr>
				  <td>
				  	<div style="position:relative;"> 
						<img src="<%=imageBase%>/BG/banner.jpg" width='800px' height='162px'>
						<div style="position:absolute; font-weight:bold; left:10px; top:0px; width:200px; height:20px; opacity: 0.7;font-size: 40px;font-family: 微軟正黑體, 新細明體, Arial, Helvetica, sans-serif;"> 
							學校名冊登錄系統 
						</div>
					</div>
				  </td>
				</tr>
			</table>
			<div class="content">
			<form method="POST" name="form1" action="" >
			<table width="400px" border="0" cellspacing="0" cellpadding="0" align="center">
				<tr>
					<td height="315">
						<TABLE border=0 align=center cellPadding=3 cellSpacing=1 class="dataTable">
							
							<input type="hidden" name="function_id" value="" />
							<input type="hidden" name="url" value="" />
							<input type="hidden" name="loginPlatform" value="BM_NE" />
								<tr valign="middle" height="23">
									<td class="sub_title" height="23" colspan="2">身分驗證</td>
								</tr>
								<tr height="24">
									<td class="dataHead" height="24" width='150px'>帳號(學校編號)</td>
									<td class="contents_left" width="295" height="24">
										<input type="text" name="userID" size="20" onKeyUp="this.value=this.value.toUpperCase();"/>
									</td>
								</tr>
								<tr height="24">
									<td height="24" class="dataHead">密碼</td>
									<td width="295" height="24" class="contents_left">
										<input type="password" name="passWD" id="passWD" size="20" maxLength="12"/><br>
										<span class="text10">（注意英文大小寫）</span>
										<div style="display: none;" id='pw_hint'>
											<small style="color:red;white-space:pre-wrap;">提醒您:</small>
											<br>
											<small style="color:red;white-space:pre-wrap;">密碼輸錯5次將會鎖住帳號，需重新申請補發密碼</small>
										</div>										
										<input name="security" type="hidden" value="0">
										<input name="hostName" type="hidden" value="<%=request.getServerName()%>">
									</td>
								</tr>
								<tr height="24">
									<td height="24" class="dataHead">驗證碼</td>
									<td width="295" height="24" class="contents_left">
										<input type="text" placeholder="請輸入圖中驗證碼" id="ContactAuthNo" name="ContactAuthNo" size="4" maxlength="4" style="width: 35%"  oninput="this.value = this.value.toUpperCase()">
										<img id="PEcaptchaImg" name="PEcaptchaImg" alt="驗證碼" src="" style="vertical-align: bottom;height: 24px;">
										<img src="${imageBase}/CM/login/refresh.png" alt="" style="width: 5%;vertical-align: bottom;" onclick='renewCaptcha()'>
									</td>
								</tr>
								<tr height="24">
									<td height="24" colspan="2" valign="middle" class="a4">
										<button type="button" onclick="check(this);">送出</button>
									</td>
								</tr>
				                <tr height="24">
									<td colspan="2" colspan="2">
										<a href="javascript:doOpenWindow()" >學校老師註冊</a>
										<a href="javascript:doOpenWindow_BMM00024()" >忘記密碼</a>
									</td>
				                </tr>
						</TABLE>
					</td>
				</tr>
			</table>
			</form>
			</div>
		</div>
	</body>
</html>