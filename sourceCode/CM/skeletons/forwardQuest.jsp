<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ include file="/html/CM/header.jsp"%>
<%@ page import="com.igsapp.wibc.dataobj.html.HttpSessionContext" %>
<%@ page import="com.cathay.common.service.authenticate.UserObject" %>
<%@ page import="com.cathay.common.trx.UCData" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>

<%

	String TYPE = request.getParameter("TYPE");
	String SRC = request.getParameter("SRC");

	/*========== 處理功能代號 ==========*/

	HttpSessionContext sessionCtx = new HttpSessionContext(session);/* 取得 eBAF session */

	UserObject userObj = (UserObject) sessionCtx.getValue(UCData.USER_OBJECT);/* 從 eBAF session 取得 UserObject */

	String FUNC_ID_BEFORE_FORWARD = "FIBF";
	String funcID = "";
	if( userObj != null ){
		funcID = StringUtils.trimToEmpty( userObj.getLastFuncId() ); /* 從 UserObject 上一次執行的 功能代號 */

		if( !"".equals( funcID ) ){/* 如果是有效的功能代號，放到cookie暫存  */
	        Cookie lastFuncIDCookie = new Cookie( FUNC_ID_BEFORE_FORWARD, funcID );
	        lastFuncIDCookie.setPath("/");
	        response.addCookie( lastFuncIDCookie );

		}

	}else{
		/* 經forward 切換一次後， session 可能被換掉時，無法從 session 取出 UserObject 而無法取得功能代號時，改從 cookie 取。 */
	    Cookie cookies[] = request.getCookies();
        if(cookies != null){

            for(int i = 0, cookieNum = cookies.length; i < cookieNum; i++){
                Cookie cookie = cookies[i];

                if(!FUNC_ID_BEFORE_FORWARD.equals( cookie.getName() )){
                    continue;
                }

                funcID = cookie.getValue();
                break;
            }
        }
	}

	pageContext.setAttribute("TYPE", TYPE);
	pageContext.setAttribute("SRC", SRC);
	pageContext.setAttribute("funcID", funcID);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html><!-- InstanceBegin template="/Templates/page.dwt" codeOutsideHTMLIsLocked="false" -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<!-- InstanceBeginEditable name="doctitle" -->

<title></title>
<script type='text/javascript'>
	historyMinLength = 1;
</script>
<!--[if lte IE 9]>
<script type='text/javascript'>
	historyMinLength = 0;
</script>
<![endif]-->
<script type='text/javascript'>
	function registerEvent(ele, eventName, action){
		if(ele.addEventListener){
			ele.addEventListener(eventName, action);
		}else{
			ele.attachEvent('on'+eventName, action);
		}
	}

	function initApp(){

		var createInputParam = function(oForm, option){
			var input = document.createElement("input");
				input.type='hidden';
				input.id=option['id'];
				input.name=option['id'];
				input.value=option['value'];
			oForm.appendChild(input);
		};

		var funcID = '<c:out value="${funcID}"/>';
		var type = '<c:out value="${TYPE}"/>';

		var target = '';
		var SRC='';
		if('QUERY'==type){
			target='QPA0_0200/prompt';
			SRC = 'LIST';

		}else if('CREATE'==type){
			target='QPA0_0100/prompt';
			SRC = 'BTN';

		}

		if(target==''){
			alert("非合理之交易，無法轉送!!!");
			window.close();
			return;
		}

		// 若經由此頁面開始時，應無任何 history ，故當 window.history.length > 0 時
		// 則表示為所導向頁面有出現 Exception 導致再回到本頁，藉此判斷來避免無窮迴圈
		if(window.history.length > historyMinLength){
			window.close();
			return;
		}

		var oForm = document.createElement("form");
			oForm.action='/QPWeb/servlet/HttpDispatcher/'+target;
			oForm.method="post";
		if(document.body != null){
			document.body.appendChild(oForm);
		}else{
			document.appendChild(oForm);
		}

		createInputParam(oForm, { 'id':'CUR_FUNC_ID', 'value':funcID });
		createInputParam(oForm, { 'id':'SRC', 'value':SRC });

		oForm.submit();

	}

	registerEvent(window, 'load', initApp);
</script>
</head>
<body></body>
</html>
