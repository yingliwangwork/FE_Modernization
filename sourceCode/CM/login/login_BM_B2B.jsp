<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="/html/CM/header.jsp"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.cathay.common.util.STRING"%>
<%
	String strUserID = null;
	strUserID = (String) pageContext.getAttribute("userid");	
	strUserID = ( strUserID == null ? "" : strUserID.trim());	

	request.getSession().invalidate();

	
	String newBK_loginStatus = (String)request.getParameter("newBK_loginStatus");
	String CathayEmp_loginInfo = (String)request.getParameter("CathayEmp_loginInfo");
	
	HttpResponseContext resp = new HttpResponseContext(request);
	String errMsg = (String)resp.getOutputData("errMsg");

	/* 處理錯誤訊息部分 */
    com.cathay.common.bo.ReturnMessage msg = null;
    try{	
		msg = (com.cathay.common.bo.ReturnMessage) pageContext.getAttribute(com.cathay.common.util.IConstantMap.ErrMsg);
		System.out.println("msg:"+msg);
	}catch(ClassCastException cce){
		msg = null;
	}	
	
	if(msg==null){
		 msg = new com.cathay.common.bo.ReturnMessage(0,"","","","","");
	}

	int subURL = dispatcher.indexOf("/servlet");
	String CXB_location = "/CXBWeb"+dispatcher.substring(subURL);

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
<meta name="viewport" content="width=1024" />
<title>團險客戶網路服務</title>
	<%@ include file="/html/CM/header.jsp" %>
    <link href="${htmlBase}/BM/css/detectCapsLock.css" rel="stylesheet" type="text/css" />
    <link href="${htmlBase}/BM/css/validation.css" rel="stylesheet" type="text/css" />
    <link href="${htmlBase}/BM/css/BM_LOGIN.css" rel="stylesheet" type="text/css">
    <script type="text/javascript" src="${htmlBase}/CM/js/jquery/jquery-3.6.0.js"></script>
    <script src="${htmlBase}/CM/js/ajax/prototype.js"></script>
    <script src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
    <!--<script type="text/javascript" src="https://sb2b.cathaylife.com.tw/CXBWeb/html/CM/js/ajax/prototype.js"></script>-->
    <script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
    <script type="text/javascript" src="${htmlBase}/BM/js/validates.js"></script>
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/moment/moment.min.js"></script>
    <script src="${htmlBase}/BM/js/daterangepicker_3_6_0.js"></script>    
    <script type="text/javascript" src="${htmlBase}/BM/js/formatInput.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" />
	<script src="${htmlBase}/BM/js/BM_MESSAGE.js"></script>
	<script src="${htmlBase}/BM/js/toucher_base.js"></script>
    <script src="${htmlBase}/BM/js/sysBM_calendar.js"></script>
    <script async src="https://www.googletagmanager.com/gtag/js?id=UA-47155404-13"></script>
    <script src="${htmlBase}/BM/js/ga.js"></script>
	
    <script type="text/javascript">
        var sys_obj = new sys();
        String.prototype.trim = function () {
            var m = this.match(/^\s*(\S+(\s+\S+)*)\s*$/);
            return (m == null) ? "" : m[1];
        };
		
		// 自定義一個比較短快捷方式
		var $toucher = jQuery.noConflict(); 
        var $j = jQuery.noConflict();
		
		//紀錄icon的位置
		var iconCalendarInitTop = 0;
		
        function sys() {
            var validate4define;
            function UI() {
                return {
                    init: function () {
                        validate4define = new Validation("form1", { useTitles: true, focusOnError: false, immediate: false });
                        Validation.addAllThese([
                            ['customize_returnFalse', '',
                                function (obj) {
                                    return false;
                                }
                            ]
                        ]);

                        $('userID').observe('blur', action.userIdAndPasswordStatusHandler);
                        $('userID').observe('keyup', action.userIdAndPasswordStatusHandler);
                        $('btn_login').observe('click', action.login);
                        $('link_forgetPW').observe('click', action.forget);
                        $('btn_send_password').observe('click', action.step1);
                        $('otp_btn_send').observe('click', BM_LOGIN.showReplaceStep2);
                        $('otp_btn_resend').observe('click',action.step1);
                        $('btn_true_send').observe('click', action.step2);
                        $('step3_btn_login').observe('click', action.step3);

                        $w('focus keydown keyup').each(
                            function (action) {
                                $('passWD').observe(action, function () {
                                    if (this.value) {
                                        $('pw_hint').update("");
                                    } else {
                                        $('pw_hint').update("提醒您: 密碼輸錯5次將會鎖住帳號，需重新申請補發密碼");
                                    }
                                });
                            }
                        );

                        $('passWD').observe('blur', function () {
                            $('pw_hint').update("");
                        });

                        // 帳號, 密碼輸入欄位控制
                        var user_Id_desc = "請輸入身分證字號";
                        var length = user_Id_desc.length;
                        $('userID').size = length * 2 + 2;
                        $('passWD').size = length * 2 + 2;
						
						$('btn_renewCaptcha').observe('click',action.renewCaptcha);
                        action.renewCaptcha();

						// 設定小日曆
                        new BM_CALENDAR("#step1_userBirthday", {
                            "startDate": moment().subtract(40, 'years'),
                            "singleDatePicker": true,
                            "drops": "up",
                            "minYear": 1912,
                            "maxYear": parseInt(moment().format('YYYY'), 10),
                            "locale": { "format": "YYYY/MM/DD" }
                        });
                    }
                };
            }

            var action = {
                userIdAndPasswordStatusHandler: function () {
                    var oPassWD = document.getElementById('passWD');
                    oPassWD.value = '';
                    if (document.getElementById('userID').value.length >= 10) {
                        oPassWD.focus();
                    }
                }
                , login: function () {
                    var actionName = 'login';
                    if (!action.checkInput(actionName)) {
                        return;
                    }

               	 	let params = { "userID": $('step1_userID').value }
            	   	let url_checkIsCathayEmp = "${dispatcher}/login/";

					var webcontext = '${dispatcher}/login/';
            	   	var ajaxRequest = new CSRUtil.AjaxHandler.request(webcontext);
					ajaxRequest.post('checkIsCathayEmp', { 'userID' : $('userID').value, }, function(resp) {
						if (resp.isCathayEmp) {
							var countdown = 5;
		       		 		action.showPopupPIMS();
		       		 	    
   	       		 			setTimeout(function () {
       	       		 	    	document.location.href = "<%=CXB_location%>/login/samlLogin?TxRequest=true"
   	       		 			}, 5000);
       	       		 	    
						} else {
							//原有CXB登入 
							$('form1').action = "${dispatcher}/login/inputB2B?newTxRequest=true";
							$('form1').submit();
						}
					});
            	   	
                }
                , showPopupPIMS : function() {
           			document.getElementById('popup_pims_notice').style.display = "block";
            	}
                , forget: function () {
                    BM_LOGIN.showReplaceStep1();
                }
                , step1: function () {
                    var actionName = 'forgetPW_step1';
                    if (!action.checkInput(actionName)) {
                        return;
                    }
					
					// 取得otp
					var webcontext = '${dispatcher}/login/';
					
					var ajaxRequest = new CSRUtil.AjaxHandler.request(webcontext);
					ajaxRequest.post(actionName, {
						userID : $('step1_userID').value,
						userBirthday : $('step1_userBirthday').value
					}, function(resp) {
						$('otpKey').value = resp.otpKey;
						BM_LOGIN.showPopupCertificationSuccess(resp.cellphone, resp.email);
					}, function(resp) {
					});
                }
                , step2: function () {
                    var actionName = 'forgetPW_step2';
                    if (!action.checkInput(actionName)) {
                        return;
                    }
                    
                  	// 驗證otp
                    var webcontext = '${dispatcher}/login/';
                    var ajaxRequest = new CSRUtil.AjaxHandler.request(webcontext);
					ajaxRequest.post(actionName, {
						otp : $('step2_otp').value,
						userID : $('step1_userID').value,
						passWD : $('step2_passWD').value,
						otpKey : $('otpKey').value
					}, function(resp) {
						BM_LOGIN.showReplaceStep3();
					}, function(resp) {
					});
                }
                , step3: function () {
                    var actionName = 'login';
                    if (!action.checkInput(actionName)) {
                        return;
                    }
                    $('userID').value = $('step1_userID').value;
                    $('passWD').value = $('step2_passWD').value;
                    $('form1').action = "${dispatcher}/login/input?newTxRequest=true";
                    $('form1').submit();
                }
                , checkInput: function (actionName) {
                    validate4define.clear();
                    validate4define.reset();

                    if (actionName == "login") {
                        var userID = $('userID').value;
                        var userID_blank = validates.isBlank(userID, false);

                        if (userID_blank) {
                            validate4define.define("customize_returnFalse", [{ id: 'userID', errMsg: '不可空白' }], { useTitle: false });
                        }

                        var passWD = $('passWD').value;
                        var passWD_blank = validates.isBlank(passWD, false);

                        if (passWD_blank) {
                            validate4define.define("customize_returnFalse", [{ id: 'passWD', errMsg: '不可空白' }], { useTitle: false });
                        }
                        
                    } else if (actionName == "forgetPW_step1") {
                        var userID = $('step1_userID').value;
                        var userID_blank = validates.isBlank(userID, false);

                        if (userID_blank) {
                            validate4define.define("customize_returnFalse", [{ id: 'step1_userID', errMsg: '不可空白' }], { useTitle: false });

							$('step1_userBirthday_icon').style.top=(iconCalendarInitTop + 19) + "px";
                        }else{
							$('step1_userBirthday_icon').style.top = iconCalendarInitTop + "px";
						}

                        var userBirthday = $('step1_userBirthday').value;
                        var userBirthday_blank = validates.isBlank(userBirthday, false);

                        if (userBirthday_blank) {
                            validate4define.define("customize_returnFalse", [{ id: 'step1_userBirthday', errMsg: '不可空白' }], { useTitle: false });
                        } else {
                            var regex = /^\d{3}\/\d{2}\/\d{2}$/;
                            if (!regex.test(userBirthday)) {
                                validate4define.define("customize_returnFalse", [{ id: 'step1_userBirthday', errMsg: '生日格式錯誤' }], { useTitle: false });
                            }
                        }
                    }
                    else if (actionName == "forgetPW_step2") {
                        var step2_otp = $('step2_otp').value;
                        var step2_otp_blank = validates.isBlank(step2_otp, false);
                        
                        if (step2_otp_blank) {
                            validate4define.define("customize_returnFalse", [{ id: 'step2_otp', errMsg: '不可空白' }], { useTitle: false });
                        } else {
                            var regex = /\d{6}/;
                            if (!regex.test(step2_otp)) {
                                validate4define.define("customize_returnFalse", [{ id: 'step2_otp', errMsg: 'OTP認證碼格式錯誤' }], { useTitle: false });
                            }
                        }

                        var step2_passWD = $('step2_passWD').value;
                        var step2_passWD_blank = validates.isBlank(step2_passWD, false);

                        if (step2_passWD_blank) {
                            validate4define.define("customize_returnFalse", [{ id: 'step2_passWD', errMsg: '不可空白' }], { useTitle: false });
                        } else if (step2_passWD.length > 12 || step2_passWD.length < 8) {
                            validate4define.define("customize_returnFalse", [{ id: 'step2_passWD', errMsg: '密碼須為8-12碼英數字或英文，且不可含空白及特殊符號' }], { useTitle: false });
                        } else if (validates.isNumber(step2_passWD, false)) {
                            validate4define.define("customize_returnFalse", [{ id: 'step2_passWD', errMsg: '密碼不可全為數字' }], { useTitle: false });
                        } else {
                            var regex = /^(?=.*\d)(?=.*[a-zA-Z])([a-zA-Z\d]){8,12}$/;
                            var regex2 = /^(?=.*[a-zA-Z])([a-zA-Z]){8,12}$/;
                            if (!regex.test(step2_passWD) && !regex2.test(step2_passWD)) {
                                validate4define.define("customize_returnFalse", [{ id: 'step2_passWD', errMsg: '密碼須為8-12碼英數字或英文，且不可含空白及特殊符號' }], { useTitle: false });
                            }
                        }

                        var step2_repassWD = $('step2_repassWD').value;
                        var step2_repassWD_blank = validates.isBlank(step2_repassWD, false);
                        if (step2_repassWD_blank) {
                            validate4define.define("customize_returnFalse", [{ id: 'step2_repassWD', errMsg: '不可空白' }], { useTitle: false });
                        } else if (step2_passWD != step2_repassWD) {
                            validate4define.define("customize_returnFalse", [{ id: 'step2_repassWD', errMsg: '確認密碼與密碼不同' }], { useTitle: false });
                        } 
                    }

                    return validate4define.validate();
                }, renewCaptcha : function(){
					$('ContactAuthNo').value="";
					var webcontext = '${dispatcher}/login/';
					
					var ajaxRequest = new CSRUtil.AjaxHandler.request(webcontext);
					ajaxRequest.post('captcha', {
						time : (new Date()).getTime(),
					}, function(resp) {
						$('PEcaptchaImg').setAttribute("src","data:image/png;base64,"+resp.imgBase64String);
					});
                }
            };

            return {
                initApp: function () {
                    new UI().init();
                }
            }
        }

        var BM_LOGIN = {
			init:function(){

			},		
            showLogin: function () {
                document.getElementById("login").style.display = "block";
            },
            showReplaceStep1: function () {
                BM_LOGIN.closeAllBox();
                document.getElementById("replace_step_1").style.display = "block";

				var divHeight = Number($('replace_step_1').getStyle('height').replace('px',''));
				var divPadding = Number($('replace_step_1').getStyle('padding-bottom').replace('px',''));
				var divBorder = Number($('replace_step_1').getStyle('border-width').replace('px',''));
				var iconTopOffset = 526 - (divHeight - divPadding - divBorder);
				iconCalendarInitTop = 377 - iconTopOffset;
				$('step1_userBirthday_icon').style.top =iconCalendarInitTop + 'px';
            },
            showReplaceStep2: function () {
                BM_LOGIN.closeAllBox();
                BM_LOGIN.closePopupCertificationSuccess();
                document.getElementById("replace_step_2").style.display = "block";
            },
            showReplaceStep3: function () {
                BM_LOGIN.closeAllBox();
                document.getElementById("replace_step_3").style.display = "block";
            },
            closeAllBox: function () {
                document.getElementById("login").style.display = "none";
                document.getElementById("replace_step_1").style.display = "";
                document.getElementById("replace_step_2").style.display = "";
                document.getElementById("replace_step_3").style.display = "";
            },
            showPopupCertificationSuccess: function (mobile, email) {
                $('cert_mobile').update(mobile);
                $('cert_email').update(email);
				document.getElementById("popup_certification_success").style.display="block";
				document.getElementById("step1_userBirthday_icon").style.display = "none";
			},
			closePopupCertificationSuccess:function(){
				document.getElementById("popup_certification_success").style.display="none";
				document.getElementById("step1_userBirthday_icon").style.display = "";
			}
        };

        window.onload = function () {
            sys_obj.initApp();

            BM_LOGIN.showLogin();
			BM_LOGIN.init();
			PWD_init.init();
        };
		var PWD_init ={
			init: function(){
				var isIE = /*@cc_on!@*/false || !!document.documentMode;
				if (isIE){
					$toucher(".toggle-password").attr('style','');
					return;
				}
				//設定隱藏OR顯示密碼 功能
				$toucher(".field-icon")
				.css("float", "right")
				.css("margin-left", "-25px")
				.css("margin-top", "-55px")
				.css("width", "30px")
				.css("height", "20px")
				.css("position", "relative")
				.css("background-repeat", "no-repeat")
				.css("z-index", "2");
				
				$toucher(".toggle-password").mouseup(function() {
				  $toucher(this).css("background-image", "url(images/CM/b2b/blink_close.png)");
				  $toucher($toucher(this).attr("toggle")).attr("type", "password");
				}).mousedown(function() {
				  $toucher(this).css("background-image", "url(images/CM/b2b/blink_open.png)");
				  $toucher($toucher(this).attr("toggle")).attr("type", "text");
				});
				//設定隱藏OR顯示提示大寫模式 功能
				$toucher("#passWD").bind('mousedown', checkCapsLock).bind('keyup', checkCapsLock).bind('focusout', checkCapsLock);
				function checkCapsLock(e) {
				 if(e.type === 'focusout'){
				  $toucher('#pw_capslock').hide();
				 }else{
				  var caps_lock_on = e.originalEvent.getModifierState('CapsLock');
				  if(caps_lock_on == true){
				   document.getElementById("capslock").style.visibility = "visible";
				  }else{
				   document.getElementById("capslock").style.visibility = "hidden";
				  }
				 }
				}
			}
		};
    </script>
</head>
<body>
	<script type="text/javascript" src="https://www.cathaylife.com.tw/oc/OCWeb/html/CM/js/CelebrusInsert.js"></script>
    <form id="form1" name="form1" method="post">
    	<input name="function_id" type="hidden" value="">
		<input name="url" type="hidden" value="">
		<input name="loginPlatform" type="hidden" value="BM_B2B">
		<input name="sys" type="hidden" value="BM_B2B" />
		<input name="security" type="hidden" value="0">
		<input name="hostName" type="hidden" value="${request.getServerName()}">
		<input id="TITLE" name="TITLE" type="hidden" value="">
	    <div class="container">
		    <div class="inner">
			    <div class="logo"></div>
			    <div class="login_box" id="login">
				    <h1>團險網路服務系統</h1>
				    <h3><span>企業承辦人的聰明選擇</span></h3>
				    <input type="text" placeholder="身分證字號" id="userID" name="userID" size="14" maxLength="10" oninput="this.value = this.value.toUpperCase()"/>
				    <small></small>
				    <input type="password" placeholder="密碼" id="passWD" name="passWD" size="14" maxLength="12" AUTOCOMPLETE="off"/>
					<div id="capslock" style="color:red; font-size:12px; visibility:hidden;"><span>您現在使用大寫模式</span></div>
					<span toggle="#passWD" class="fa-eye field-icon toggle-password" style="background-image: url(&quot;images/CM/b2b/blink_close.png&quot;);"></span>
				    <small id="pw_hint" style="color:red;"></small>
				    <div>
						<input type="text" placeholder="請輸入圖中驗證碼" id="ContactAuthNo" name="ContactAuthNo" size="4" maxlength="4" style="width: 35%" oninput="this.value = this.value.toUpperCase()">
						<img id="PEcaptchaImg" name="PEcaptchaImg" alt="驗證碼" src="" style="vertical-align: bottom;height: 62px;">
						<a href="#" class="" id="btn_renewCaptcha" style="vertical-align: bottom;">
							<span>重新產生</span>
						</a>
				    </div>
				    <small id="ContactAuthNo_hint" style="color:red;"></small>
				    <div class="row_button_center">
					    <button id="link_forgetPW" type="button">忘記密碼</button>
					    <button class="active focus" id="btn_login" type="button">登入</button>
				    </div>
			    </div>
			    <div class="replace_password_box" id="replace_step_1">
				    <h3>補發密碼</h3>
				    <div class="content">
					    <div class="row_step">
						    <div class="step active">
							    <div class="pic pic_1"></div>
							    <div class="txt">身分驗證</div>
						    </div>
						    <div class="line">----</div>
						    <div class="step">
							    <div class="pic pic_2"></div>
							    <div class="txt">輸入認證碼設定密碼</div>
						    </div>
						    <div class="line">----</div>
						    <div class="step">
							    <div class="pic pic_3"></div>
							    <div class="txt">補發完成</div>
						    </div>
					    </div>
					    <p>請填選以下資料，系統驗證後將透過 Email 或手機補發一組認證碼。</p>
					    <input type="text" placeholder="身分證字號" id="step1_userID" name="step1_userID" size="14" maxLength="10" />
					    <small></small>
					    <input type="text" placeholder="生日民國年 YYY/MM/DD" id="step1_userBirthday" name="step1_userBirthday" maxLength="9" autocomplete="off" onkeyup="this.value=this.value.replace(/[^\d\/]/gi,'');"/>
					    <label for="step1_userBirthday" class="icon_calendar" id="step1_userBirthday_icon"></label>
						<small></small>
					    <div class="row_button_center">
						    <button type="reset">清除重填</button>
						    <button class="active focus" id="btn_send_password" type="button">寄送認證碼</button>
					    </div>					
				    </div>
			    </div>
			
			    <div class="replace_password_box" id="replace_step_2">
			        <h3>補發密碼</h3>	
				    <div class="content">
					    <div class="row_step">
						    <div class="step active">
							    <div class="pic pic_1"></div>
							    <div class="txt">身分驗證</div>
						    </div>
						    <div class="line">----</div>
						    <div class="step active">
							    <div class="pic pic_2"></div>
							    <div class="txt">輸入認證碼設定密碼</div>
						    </div>
						    <div class="line">----</div>
						    <div class="step">
							    <div class="pic pic_3"></div>
							    <div class="txt">補發完成</div>
						    </div>
					    </div>
					    <p>請將您收到的一次性認證碼 (OTP) 填入以下表格中，並立即設定新的會員密碼，提醒您，<span class="color_o">如未在 5 分鐘內輸入 OTP 認證碼或輸入 3 次錯誤，此次發送的 OTP 認證碼將失效，需重新進行 OTP 認證碼的申請，若有任何疑問歡迎來電客服詢問02-7757-0109轉22096、22101、22102</span></p>
					    <input type="text" placeholder="請輸入OTP認證碼" maxlength="8" id="step2_otp" name="step2_otp" />
					    <input type="hidden" id="otpKey"/>
					    <small></small>
					    <input type="password" placeholder="輸入新密碼(8-12碼英文及數字)" id="step2_passWD" name="step2_passWD" class="step2_passWD" size="14" maxLength="12" AUTOCOMPLETE="off" />
					    <small></small>
					    <input type="password" placeholder="再次輸入新密碼" id="step2_repassWD" name="step2_repassWD" size="14" maxLength="12" AUTOCOMPLETE="off"/>
					    <small></small>
					    <div class="row_button_center">
						    <button type="reset">清除重填</button>
						    <button class="active focus" id="btn_true_send" type="button">確定送出</button>
					    </div>					
				    </div>
			    </div>
			
			    <div class="replace_password_box" id="replace_step_3">
				    <h3>補發密碼</h3>
				    <div class="content">
					    <div class="row_step">
						    <div class="step active">
							    <div class="pic pic_1"></div>
							    <div class="txt">身分驗證</div>
						    </div>
						    <div class="line">----</div>
						    <div class="step active">
							    <div class="pic pic_2"></div>
							    <div class="txt">輸入認證碼設定密碼</div>
						    </div>
						    <div class="line">----</div>
						    <div class="step active">
							    <div class="pic pic_3"></div>
							    <div class="txt">補發完成</div>
						    </div>
					    </div>
					    <p class="txt_ok">您已完成密碼變更設定！</p>
					    <div class="row_button_center">
						    <button class="active focus" type="button" id="step3_btn_login">登入</button>
					    </div>	
									
				    </div>				

			    </div>

		    </div>
	    </div>
        <div class="popup" style="display: none;" id="popup_certification_success" >
		    <div class="mask"></div>
		    <div class="popup_content">
			    <div class="popup_certification_success_box">
				    <h3>認證碼已成功發送</h3>
				    <div class="pic"></div>
				    <div class="txt">
					    <span>已將OTP認證碼發送至您的 </span>
					    <table>
						    <tr>
							    <th>手機</th>
							    <td id="cert_mobile"></td>
						    </tr>
						    <tr>
							    <th>Email</th>
							    <td id="cert_email"></td>
						    </tr>
					    </table>
				    </div>
				    <div class="row_button_center">
					    <button type="button" id="otp_btn_resend">重新發送</button>
					    <button class="active focus" type="button" id="otp_btn_send">下一步</button>
				    </div>	

			    </div>
		    </div>
	    </div>
	    
	    <div class="popup" id="popup_pims_notice" style="position: absolute; width: 100%; min-height: 100%; top: 0; left: 0px; z-index: 5; display: none;">
			<div class="mask" style="position: fixed; background-color: #63687B; opacity: 0.7; top: 0; left: 0; width: 100%; height: 100%;"></div>
			<div class="popup_content" style=" position: absolute; top: 50%; left: 50%; transform: translate(-50%, -60%); border-radius: 8px; background-color: #fff; width: 600px;">
				<div class="popup_help_box" style="color: #00994E; font-size: 1.375rem; padding: 15px 0; margin: 0; text-align: center; border-bottom: 1px solid #8F95A6;">
					<h3 class="PIMS_text">經檢核為國泰員工，針對員工已調整登入模式</h3>
					<h3 class="PIMS_text">5秒後為您轉到「員工登入網」登入</h3>
				</div>
			</div>
		</div>
	</form>
	<%@ include file="/html/BM/popupMsgDisplayer.jsp" %>
</body>
</html>