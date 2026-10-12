<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ include file="/html/CM/header.jsp" %>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><!-- InstanceBegin template="/Templates/page.dwt" codeOutsideHTMLIsLocked="false" -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<!-- InstanceBeginEditable name="doctitle" -->
<title>密碼變更</title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<style type="text/css">
	#inputTable td{
		padding: 10px 0px 10px 20px;
	}
</style>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript">
Event.observe(window, 'load', new changePassword().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function changePassword()  {

	var validator;

	function UI(){

		return {
			init:function() {

				validator = new Validator();
				validator.errHandler = new AlertHandler();

				$('btn_update').observe('click', buttons.doUpdate );
				$('btn_backLogin').observe('click', buttons.doBackLogin );

				displayMessage();
			}
		};

	}

	//--------------------------------------------------------------------------
	// 功能按鈕
	//--------------------------------------------------------------------------
	var buttons = {
		// 確認變更
		doUpdate:function(){
			if(!validates.checkInput()){
				return;
			}
			$('form1').action="/CXBWeb/servlet/HttpDispatcher/login/changePassword";
			submitOnce($('userId'));
		},
		doBackLogin:function(){
			$('form1').action="/CXBWeb/login?sys=${sys}";
			submitOnce($('userId'));
		}
	};

	//--------------------------------------------------------------------------
	// 檢核
	//--------------------------------------------------------------------------
	var validates = {
		// 畫面欄位
		checkInput:function(){
			if(validator.errHandler) {
				validator.errHandler.clear();
			}
			validator.clear();
			validator.errHandler = new AlertHandler();

			var userId = $F('userId');
			var orgPwd = $F('orgPwd');
			var newPwd = $F('newPwd');

			if(validates.isBlank(userId)){
				validator.define("userId","登入者ID","請輸入","string",-1,-1);
			}else{
				var check = false;
				if(!idCheck1(userId) && !iscmpid(userId)){
					validator.define("userId","登入者ID","需為「身份證字號」或「營業人統一編號」","string",-1,-1);
				}
			}

			var orgPwd_isBlank = validates.isBlank(orgPwd);
			if(orgPwd_isBlank){
				validator.define("orgPwd","舊密碼","請輸入","string",-1,-1);
			}

			var newPwd_isBlank = validates.isBlank(newPwd);
			if(newPwd_isBlank){
				validator.define("newPwd","新密碼","請輸入","string",-1,-1);
			}

			if(!orgPwd_isBlank && !newPwd_isBlank){

				if(orgPwd == newPwd){
					validator.define("newPwd","新密碼","與舊密碼不可相同，請重新輸入","string",-1,-1);
				}else{
					var confirm_pw = $F('confirm_pw');
					var confirm_pw_isBlank = validates.isBlank(confirm_pw);
					if(confirm_pw_isBlank){
						validator.define("confirm_pw","再次輸入新密碼","請輸入","string",-1,-1);
					}

					if(!newPwd_isBlank && !confirm_pw_isBlank){

						if(newPwd != confirm_pw){
							validator.define("confirm_pw","再次輸入新密碼","與新密碼不同，請重新輸入","string",-1,-1);
						}
					}
				}
			}

			if(!validator.validate()){
				validator.errHandler.display();
		    	return false;
	        }

			return true;

		}
		// 檢查是否為空值
		,isBlank:function(v){
			return v==='';
		}

	};

	return {
		initApp:function(){
			new UI().init();
		}
	}
}
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<span id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility: visible;" >
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
			<td valign="top" bgcolor="#F0FBC6">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
					<tr>
						<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
					</tr>
				</table>
				<!-- InstanceBeginEditable name="title" -->
				<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
					<tr>
						<td width="20" height="24"> <div align="center"><font size="-5">●</font></div></td>
						<td><b>密碼變更</b></td>
						<td></td>
					</tr>
				</table>
				<!-- InstanceEndEditable --></td>
			<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
			<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
		</tr>
	</table>
	</span>
	<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0" style="padding-top:30px">
		<tr>
			<td width="4" background="<%=imageBase%>/CM/border_01.gif">
				<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
			</td>
			<td width="100%" valign="top" bgcolor="#F0FBC6" align="center">
			<table width="70%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="top"><table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
						<tbody>
							<tr>
								<td class="tbBox2"><p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">密碼變更</p>
								</td>
							</tr>
						    <tr bgcolor=#FFFFFF>
						        <td>
									<table width="100%" border="0" cellspacing="0" cellpadding="5">
										<tr>
											<td>
												<form id="form1" method="post" action="">
													<input name="sys" type="hidden" value="${sys}"/>
													<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="inputTable">
														<tr>
															<td width="30%" class="tbYellow">登入者ID</td>
															<td width="70%" class="tbYellow2">
																<input id="userId" name="userId" type="text" size="50" maxlength="10" value="" onblur="this.value=this.value.toUpperCase();"/>
															</td>
														</tr>
														<tr>
															<td width="25%" class="tbYellow">舊密碼</td>
															<td class="tbYellow2">
																<input id="orgPwd" name="orgPwd" type="password" size="50" maxlength="52" value=""/>（注意英文大小寫）
															</td>
														</tr>
														<tr>
															<td width="25%" class="tbYellow">新密碼</td>
															<td class="tbYellow2">
																<input id="newPwd" name="newPwd" type="password" size="50" maxlength="52" value=""/>（注意英文大小寫）
															</td>
														</tr>
														<tr>
															<td width="25%" class="tbYellow">再次輸入新密碼</td>
															<td class="tbYellow2">
																<input id="confirm_pw" name="confirm_pw" type="password" size="50" maxlength="52" value=""/>（注意英文大小寫）
															</td>
														</tr>
													</form></table>
													<center>
														<div style="padding:15px 0px 5px 0px">
															<input id="btn_update" type="button" class="button" value="確認變更" >
															<input id="btn_backLogin" type="button" class="button" value="回登入頁" >
														</div>
													</center>
											</td>
										</tr>
									</table>
						    	</td>
							</tr>
						</tbody>
					</table>
					</td>
				</tr>
			</table>
			</td>
			<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
			<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
		</tr>
	</table>
</body>