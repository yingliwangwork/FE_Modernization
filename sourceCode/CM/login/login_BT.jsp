<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="BIG5" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
<meta http-equiv="X-Frame-Options" content="deny" />
<meta name="viewport" content="width=1024" />
<title>體檢院所體檢值輸入平台</title>
<%@ include file="/html/CM/header.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ page import="java.text.*"%>
<%@ page import="com.cathay.common.util.STRING"%>
<%@ page import="com.cathay.common.util.FieldOptionList"%>
<%@ page import="org.apache.commons.collections.MapUtils"%>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="com.cathay.common.service.authenticate.Auth_mod"%>
<%@ page import="org.apache.log4j.Logger"%>
<%
	// 取得最新消息
	List<Map> news_List;

	try{
		news_List = new Auth_mod().getNews("BT");

		for(Map tmp:news_List){
			String TITLE = MapUtils.getString(tmp, "TITLE");
			if(StringUtils.isNotBlank(TITLE)){
				tmp.put("TITLE", TITLE.replace("\n", "<br/>"));
			}

			String DESCRIPTION = MapUtils.getString(tmp, "DESCRIPTION");
			if(StringUtils.isNotBlank(DESCRIPTION)){
				tmp.put("DESCRIPTION", DESCRIPTION.replace("\n", "<br/>"));
			}
		}
	} catch(Exception e){
		Logger log = Logger.getLogger("login_BT");
		log.error(e);

		news_List = Collections.EMPTY_LIST;
	}

	pageContext.setAttribute("news_List", news_List);
%>
<link href="<%=htmlBase%>/BT/css/reset.css" rel="stylesheet" type="text/css">
<link href="<%=htmlBase%>/BT/css/show_pic_repeat.css" rel="stylesheet" type="text/css">
<link href="<%=htmlBase%>/BT/css/BT_login.css" rel="stylesheet" type="text/css">

<%-- jQuery --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jquery/jquery-3.6.0.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/BT/js/jq/show_pic_repeat.js'></script>

<%-- prototype --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script><!-- 檢核API -->
<script type="text/javascript" src="<%=htmlBase%>/BT/js/BT_MESSAGE.js"></script><!-- BT訊息 -->
<script type="text/javascript" src="<%=htmlBase%>/BT/js/validation.js"></script><!-- 檢核 -->
<script type="text/javascript" src="<%=htmlBase%>/BT/js/validates.js"></script><!-- 檢核API -->
<script type="text/javascript" src="<%=htmlBase%>/BT/js/BT_EUtil.js"></script><!-- 其他 -->
<script type="text/javascript" src="<%=htmlBase%>/BT/js/elementCreate.js"></script><!-- 元素產生器 -->
<script type="text/javascript" src="<%=htmlBase%>/BT/js/formatInput.js"></script><!-- 格式化 -->

<script type="text/javascript">


<c:choose>
<c:when test="${not empty REDIRECT_URL}">

BT_EUtil.setEventObserve( window, 'load', initApp);
function initApp(){
	//window.location.href=window.location.href+'<c:out value="${REDIRECT_URL}"/>';
	//$('form1').action = '<c:out value="${REDIRECT_URL}"/>';
	//$('form1').submit();
}
//initApp();
</c:when>
<c:otherwise>
BT_EUtil.jsCheck("jQuery");

var sys_obj = new sys();
BT_EUtil.setEventObserve( window, 'load', sys_obj.initApp);
BT_EUtil.setEventObserve( window, 'resize', sys_obj.resize);

String.prototype.trim = function() {
	var m = this.match(/^\s*(\S+(\s+\S+)*)\s*$/);
	return (m == null) ? "" : m[1];
}

function sys(){
	var validate4define;

	function UI(){
		return {
			init:function(){
				validate4define = new Validation("form1", {useTitles:true, focusOnError:false, immediate:false});<%--, mode:"validator"--%>
				Validation.addAllThese([
					[ 'customize_returnFalse', '',
						function(obj){
							return false;
						}
					]
				]);
				$('userID').observe('blur', action.userIdAndPasswordStatusHandler);
				$('userID').observe('keyup', action.userIdAndPasswordStatusHandler);
				$('btn_login').observe('click', action.login);
				$('link_forgetPW').observe('click', action.forget);
				$('link_firstRegist').observe('click',action.regist);
				$w('focus keydown keyup').each(
					function(action){
						$('passWD').observe(action, function(){
							if(this.value){
								$('pw_hint').hide();
							}else{
								$('pw_hint').show();
							}
						});
					}
				);

				$('passWD').observe('blur', function(){
					$('pw_hint').hide();
				});

				$$('#news_block li[name=title]').each(
					function(ele){
						ele.observe('mouseover', function(event){
							var content = ele.getAttribute("content");
							action.news_desc_Control(content, 'show', event);
						});
						ele.observe('mouseout', function(){
							action.news_desc_Control();
						});

						ele.observe('click', function(event){
							var visibility = $('news_desc').style.visibility == 'visible'?'hidden':'visible';
							var curr_content = $('news_desc').innerHTML;
							var content = ele.getAttribute("content");

							if(curr_content == content){
								visibility = 'hidden';
								$('news_desc').update();
							}else{
								visibility = 'visible';
							}

							if(visibility == "visible"){

								action.news_desc_Control(content, 'show', event);
							}else{
								action.news_desc_Control();
							}
						});
					}
				);

				// 帳號, 密碼輸入欄位控制
				var user_Id_desc = "請輸入身份證字號";
				var length = user_Id_desc.length;
				$('userID').size = length*2+2;
				$('passWD').size = length*2+2;

				function userID_init(){
					$('userID').value=user_Id_desc;
					$('userID').setStyle({'color':'gray'});
				}

				$('userID').observe('focus', function(event){
					if($('userID').value == "請輸入身份證字號"){
						$('userID').value="";
						$('userID').setStyle({'color':'black'});
					}
				});

				$('userID').observe('blur', function(event){
					if(validates.isBlank($('userID').value, false)){
						userID_init();
					}
				});
				userID_init();

				register.textNoSpace('userID', true);

				BT_EUtil.detectCapsLock(null, {"msg":"您現在的輸入模式為「大寫模式」!!!"});

				layout.resize();
			}
		};
	}

	var action={
		userIdAndPasswordStatusHandler:function(){
			var oPassWD = document.getElementById('passWD');
			oPassWD.value='';
			if(document.getElementById('userID').value.length>=10){
				oPassWD.focus();
			}
		}
		,login:function(){
			var actionName = 'login';
			if(!action.checkInput(actionName)){
				return;
			}
			$('form1').action="<%=dispatcher%>/login/input?newTxRequest=true";
			$('form1').submit();
		}
		,forget:function(){
			$('form1').action="<%=dispatcher%>/login/changePasswordPrompt?sys=BT";
			$('TITLE').value = $('link_forgetPW').innerHTML;
			$('form1').submit();
		}
		,regist:function(){
			$('form1').action="/BMWeb/servlet/HttpDispatcher/BMM0_9998/prompt";
			$('form1').submit();
		}
		,checkInput:function(actionName){
			validate4define.clear();
			validate4define.reset();

			if(actionName == "login"){
				var userID = $('userID').value;
				var userID_blank = validates.isBlank(userID, false);

				if(userID_blank){
					validate4define.define( "customize_returnFalse" , [{ id :'userID' , errMsg : '不可空白'}] , { useTitle: false });
				}

				var passWD = $('passWD').value;
				var passWD_blank = validates.isBlank(passWD, false);

				if(passWD_blank){
					validate4define.define( "customize_returnFalse" , [{ id :'passWD' , errMsg : '不可空白'}] , { useTitle: false });
				}else if(passWD.length > 12 || passWD.length < 6){
					validate4define.define( "customize_returnFalse" , [{ id :'passWD' , errMsg : '密碼須為6~12碼英數字或英文，且不可含空白及特殊符號'}] , { useTitle: false });
				}else if(validates.isNumber(passWD, false)){
					validate4define.define( "customize_returnFalse" , [{ id :'passWD' , errMsg : '密碼不可全為數字'}] , { useTitle: false });
				}else{
					var regex = /^(?=.*\d)(?=.*[a-zA-Z])([a-zA-Z\d]){6,12}$/;
					var regex2 = /^(?=.*[a-zA-Z])([a-zA-Z]){6,12}$/;
					if(!regex.test(passWD) && !regex2.test(passWD)){
						validate4define.define( "customize_returnFalse" , [{ id :'passWD' , errMsg : '密碼須為6~12碼英數字或英文，且不可含空白及特殊符號'}] , { useTitle: false });
					}
				}
			}

			return validate4define.validate();
		}
		,news_desc_Control:function(desc, type, e){
			var layer = $('news_desc');
			var is_show = type=='show';
			var visibility = is_show?'visible':'hidden';

			if(layer){
				if(is_show && e){
					layer.update(desc);
					var e = e || window.event;
					layer.style.left = $('content').getWidth()/2-130 + 'px';
					layer.style.top = (e.target.offsetTop+20) + 'px';
				}
				layer.style.visibility = visibility;
			}
		}
	};

	var layout = {
		resize: function (){
			var content = $('content');
			var middleBlock = $('middle-block');

			content.setStyle({'height':''});
			middleBlock.setStyle({'height':''});

			//----- 高度調整 -----
			var topHeight = $('top').getHeight();
			var headerHeight = $('wrapper').getStyle('padding-top').split("px")[0];

			var left_blockHeight = $('left-block').getHeight();
			var middle_blockHeight = $('middle-block').getHeight();
			var right_blockHeight = $('right-block').getHeight();

			var footerHeight = $('footer').getHeight();

			var contentHeight_ori = Math.max(
				Math.max(document.body.offsetHeight, document.documentElement.offsetHeight),
				Math.max(document.body.clientHeight, document.documentElement.clientHeight)
			);

			contentHeight_ori = contentHeight_ori-topHeight-headerHeight-footerHeight;

			var contentHeight = Math.max( left_blockHeight , middle_blockHeight, right_blockHeight , contentHeight_ori );
			contentHeight -= 6;

			content.setStyle({'height':contentHeight+ "px"});
			middleBlock.setStyle({'height':(contentHeight-30)+ "px"});
		}
	};

	return{
		initApp:function(){
			new UI().init();
		}
		,resize:layout.resize
	}
}

function nav_goto(type){
	var curr_page = $('_current_page').innerHTML;
	var tab = "middle-block";

	if(type == "first"){
		if(curr_page == 1){
			return;
		}

		$$('#' + tab + ' ul[name=news]').each(
			function(ele){
				ele.hide();
			}
		);

		$$('#' + tab + ' ul[id=_0]').each(
			function(ele){
				ele.show();
			}
		);
		$('_current_page').update(1);
	}else if(type == "previous"){
		if(curr_page == 1){
			return;
		}

		$$('#' + tab + ' ul[name=news]').each(
			function(ele){
				ele.hide();
			}
		);

		var target_page = curr_page-1;
		var target_idx = target_page-1;
		$$('#' + tab + ' ul[id=_' + target_idx + ']').each(
			function(ele){
				ele.show();
			}
		);
		$('_current_page').update(target_page);
	}else if(type == "next"){
		var total_page = $('_total_page').innerHTML;
		if(curr_page == total_page){
			return;
		}

		$$('#' + tab + ' ul[name=news]').each(
			function(ele){
				ele.hide();
			}
		);

		var target_page = Number(curr_page)+Number(1);
		var target_idx = target_page-1;
		$$('#' + tab + ' ul[id=_' + target_idx + ']').each(
			function(ele){
				ele.show();
			}
		);
		$('_current_page').update(target_page);
	}else if(type == "last"){
		var total_page = $('_total_page').innerHTML;
		if(curr_page == total_page){
			return;
		}

		$$('#' + tab + ' ul[name=news]').each(
			function(ele){
				ele.hide();
			}
		);

		var last_idx = total_page-1;
		$$('#' + tab + ' ul[id=_' + last_idx + ']').each(
			function(ele){
				ele.show();
			}
		);
		$('_current_page').update(total_page);
	}
	sys_obj.resize();
}
</c:otherwise>
</c:choose>
</script>
</head>
<body>
	<div id="top"></div>
	<!-- 標題列 -->
	<div id="header"></div>
	<div id="wrapper">
	<div id="content">
		<!-- 廣告 -->
		<div id="left-block" class="content">
			<div id="abgneBlock">
				<ul class="list">					
				</ul>
			</div>
		</div>

		<!-- 登入 -->
		<div id="right-block" class="content">
			<form id="form1" name="form1" method="post">
				<input name="function_id" type="hidden" value="">
				<input name="url" type="hidden" value="">
				<input name="loginPlatform" type="hidden" value="BT">
				<input name="security" type="hidden" value="0">
				<input name="hostName" type="hidden" value="<%=request.getServerName()%>">
				<input id="TITLE" name="TITLE" type="hidden" value="">
				<div class="content_title">會員登入</div>
				<div class="button_common">
					帳號： <span lang="EN-US"><input id="userID" name="userID" type="text" size="14" maxLength="10"></span>
				</div>
				<div class="button_common">
					密碼： <span lang="EN-US"><input id="passWD" name="passWD" type="password" size="14" maxLength="12" AUTOCOMPLETE="off"></span>
				</div>
				<div id="pw_hint" class="button_common" style="color:red; display:none;">
					<span>提醒您: 密碼輸錯3次將會鎖住帳號，需重新申請補發密碼</span>
				</div>
				<div class="button_common">
					<button id="btn_login" class="focus" type="button">登入</button>
				</div>
			</form>
		</div>
	</div>
	</div>

	<div id="footer">
		<div id="usless_footer"></div>
		<br>瀏覽本站，建議採用chrome或其他瀏覽器最新版本，解析度1024×768。版權所有，未經同意請勿轉載本網站內容
	</div>
</body>
</html>
<c:if test= "${ErrMsg.msgDesc != '' }">
<script type="text/javascript">
	<% request.setAttribute("vEnter", "\n"); %>
	msg.show("${fn:replace(ErrMsg.msgDesc,vEnter,'<br>')}");
</script>
</c:if>
