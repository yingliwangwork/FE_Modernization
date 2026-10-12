<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ page import="com.cathay.common.service.authenticate.UserObject" %>
<%@ page import="com.cathay.common.trx.UCData" %>
<%@ page import="com.igsapp.wibc.dataobj.html.HttpSessionContext" %>
<%@ page import="org.apache.commons.lang.builder.ToStringBuilder"%>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="org.apache.log4j.Logger"%>
<%@ taglib uri="/CXL" prefix="CXL" %>
<CXL:csCommon trace="false" htmlBaseName="htmlBase"
                            cssBaseName="cssBase"
                            imageBaseName="imageBase"
                            dispatcherName="dispatcher" />

<%
    String FUNC_ID_BEFORE_FORWARD = "FIBF";
	//Logger logger = Logger.getLogger( this.getClass() );

	HttpSessionContext sessionCtx = new HttpSessionContext(session);/* 取得 eBAF session */
	//logger.debug(  "sessionCtx : " + ( sessionCtx == null ) );

	//logger.debug(  "\r\n==========SESSION==========\r\n");
	//logger.debug( 	ToStringBuilder.reflectionToString( session ));
	//logger.debug(  "\r\n==========SESSION==========\r\n");

	UserObject userObj = (UserObject) sessionCtx.getValue(UCData.USER_OBJECT);/* 從 eBAF session 取得 UserObject */
	//logger.debug(  "userObj : " + ( userObj == null ) );

	/*========== 處理功能代號 ==========*/
	String strFuncID = "";
	if( userObj != null ){
		//logger.debug( "***** UserObject is not null !!!" );
		strFuncID = StringUtils.trimToEmpty( userObj.getLastFuncId() ); /* 從 UserObject 上一次執行的 功能代號 */

		if( !"".equals( strFuncID ) ){/* 如果是有效的功能代號，放到cookie暫存  */
			//logger.debug( "***** put function id into cookie!!! *****" );
	        Cookie lastFuncIDCookie = new Cookie( FUNC_ID_BEFORE_FORWARD, strFuncID );
	        lastFuncIDCookie.setPath("/");
	        response.addCookie( lastFuncIDCookie );

		//}else{
			//logger.debug( "========== Function id id blank or null!!! ==========" );

		}

	}else{
		//logger.debug( "========== UserObject is null!!!==========" );
		/* 經forward 切換一次後， session 可能被換掉時，無法從 session 取出 UserObject 而無法取得功能代號時，改從 cookie 取。 */
	    Cookie cookies[] = request.getCookies();
        if(cookies != null){

            for(int i = 0, cookieNum = cookies.length; i < cookieNum; i++){
                Cookie cookie = cookies[i];

                if(!FUNC_ID_BEFORE_FORWARD.equals( cookie.getName() )){
                    continue;
                }

                strFuncID = cookie.getValue();
                //logger.debug("========== Getting strFuncID_BEFORE_FORWARD from cookie: " + strFuncID + "==========");
                break;
            }

        //}else{
        	//logger.debug( "========== Cokkies is null!!!==========" );
        }
	}
	//logger.debug(  "strFuncID : " + strFuncID );

	/*========== 處理功能代號 ==========*/
	String strTX = StringUtils.trimToEmpty( request.getParameter("TX") );		/* 欲轉送的 TxBean Name  */

	//logger.debug( "TX: " + strTX  );
	//logger.debug( "ACT: " + strACT  );

	String strAction;

	/* 如果是要進行 QA 的作業，才轉送到 QAWeb */
	if ( strTX.startsWith( "QA" ) ) {
		String strACT = StringUtils.trimToEmpty( request.getParameter("ACT") );		/* 欲轉送的 Action Name  */
		StringBuffer sbAction = new StringBuffer( );
		sbAction.append( "/QAWeb/servlet/HttpDispatcher" );
		sbAction.append( "/" ).append( strTX );
		sbAction.append( "/" ).append( strACT );
		sbAction.append( "?" );

		String strSRC = StringUtils.trimToEmpty( request.getParameter("SRC") );
		//logger.debug( "SRC: " + strSRC  );

		if( !"".equals( strSRC ) ){
			sbAction.append( "SRC=" ).append( strSRC );
		}

		strAction = sbAction.toString();
	}else{
		strAction = "";
	}

	//logger.debug( "strAction: " + strAction  );

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html><!-- InstanceBegin template="/Templates/page.dwt" codeOutsideHTMLIsLocked="false" -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<!-- InstanceBeginEditable name="doctitle" -->

<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type='text/javascript'>

	if(window.addEventListener){
		window.addEventListener('load',  initApp);
	}else if(window.attachEvent){
		window.attachEvent('onload',  initApp);
	}

	function initApp(){

		var strAct = "<%=strAction%>";
		if(strAct==''){
			alert(" 非合理之交易，無法轉送!!!  ");
			window.close();

		}else{

			// 若經由此頁面開始時，應無任何 history ，故當 window.history.length > 0 時
			// 則表示為所導向頁面有出現 Exception 導致再回到本頁，藉此判斷來避免無窮迴圈
			if(window.history.length){
				window.close();
			}else{
				var frm = document.createElement("form");
					frm.action=strAct;
					frm.method="post";
				document.appendChild(frm);

				var input = document.createElement("input");
					input.type='hidden';
					input.name="CUR_FUNC_ID";
					input.value="<%=strFuncID%>";
				frm.appendChild(input);
				frm.submit();
			}
		}
	}

</script>
</head>
<body></body>
<!-- InstanceEnd --></html>
