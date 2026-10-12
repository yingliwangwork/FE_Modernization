<%@ page contentType="text/html; charset=Big5"%>
<%@ include file="/html/CM/header.jsp" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=Big5">
<%
	String currPlatform = com.cathay.common.service.ConfigManager.getProperty("com.cathay.zz.trx.SysLogin.currPlatform");
	if("B2E".equals(currPlatform)){
		String B2E_TAM_Junction = com.cathay.common.service.ConfigManager.getProperty("B2E_TAM_Junction");
		pageContext.setAttribute("B2E_TAM_Junction", B2E_TAM_Junction);
	}
%>
<title>主選單</title>
<link type="text/css" href="<%=cssBase%>/cm.css" rel="stylesheet">
<style type="text/css">
li.no_menu{
	background-color: #EECE6C;
	border-width:1px;
	border-style:solid;
	border-right-color: 6B8D6D;
	border-bottom-color: 6B8D6D;
	border-left-color: #FFFFFF;
	border-top-color: #FFFFFF;
	font-size: 10pt;
	font-family: "新細明體";
	padding-left: 2.4em;
	padding-top: 5;
	padding-bottom: 5;
	text-align:left;
}

li.main_menu{
	background:url("<%=imageBase%>/CM/skeletons/icon_arrow.gif") no-repeat 0.3em ;
	background-color: #EECE6C;
	border-width:1px;
	border-style:solid;
	border-right-color: 6B8D6D;
	border-bottom-color: 6B8D6D;
	border-left-color: #FFFFFF;
	border-top-color: #FFFFFF;
	font-size: 10pt;
	font-family: "新細明體";
	padding-left: 2.4em;
	padding-top: 5;
	padding-bottom: 5;
	color:blue;
	text-align:left;
	text-decoration:underline;
	cursor:pointer;
}
</style>
<script type='text/javascript'>
<!--

	function initApp(){
		var mainMenuDatas = [];
		<c:forEach var="data" items="${outputDataMap.sysContextPathList}" varStatus="status"><c:forEach var="entry" items="${data}" varStatus="entryStatus">
		<c:if test="${entryStatus.first}">mainMenuDatas.push({</c:if>'<c:out value="${entry.key}"/>':'<c:out value="${entry.value}" escapeXml="false"/>'<c:if test="${!entryStatus.last}">,</c:if><c:if test="${entryStatus.last}">});</c:if></c:forEach></c:forEach>

		var convertSysContextPath = {
			DC: '/DJWeb',
			DE: '/DJWeb',
			DK: '/DJWeb',
			LJ: '/IMWeb',
			LK: '/IMWeb',
			JA: '/IMWeb'
		};

		var dispatcher = '${dispatcher}';
		if(dispatcher.indexOf('CXBWeb')>=0){
			convertSysContextPath['EE']='/CXBWeb';
			convertSysContextPath['EH']='/CXBWeb';
			convertSysContextPath['EP']='/CXBWeb';
			convertSysContextPath['LL']='/CXBWeb';
		}

		var inputFields = {};

		var gotoSys = function(mainMenuData){

			var varMainForm = document.mainForm;

			var invkUrl = mainMenuData['invkUrl'];
			var sysCode = mainMenuData['sysCode'];
			var varContext = mainMenuData['contextPath'];
			if(convertSysContextPath[sysCode]){
				varContext = convertSysContextPath[sysCode];
			}
			if(invkUrl){
				var prefix = "/";
				if(invkUrl.substr(0, prefix.length) === prefix){
					if(invkUrl.indexOf("Web/") <= 0){
						invkUrl = varContext + invkUrl;
					}
				}
			}else{
				invkUrl = varContext + '/servlet/HttpDispatcher/SysLogin/prompt';
			}

			varMainForm.action = invkUrl;

			var params = "";

			function setParameterToHiddenInput(name, value, isParamsValue){
				if(value){
					if(isParamsValue){
						if(params.length > 0){
							params = params + ";;";
						}

						params = params + name + ";;" + value;
					}else{
						if(!inputFields[name]){
							inputFields[name] = document.createElement('input');
							inputFields[name].type = 'hidden';
							inputFields[name].name = name;
							varMainForm.appendChild(inputFields[name]);
						}
						inputFields[name].value = value;
					}
				}
			}

			var isPortalRedirect = invkUrl.indexOf("Web/redirect.jsp?Project=") > 0;

			setParameterToHiddenInput("eBAF_loginSystemInfo", mainMenuData['eBAF_loginSystemInfo'], false);
			setParameterToHiddenInput("uid", mainMenuData['uid'], isPortalRedirect);
			setParameterToHiddenInput("func_id", mainMenuData['func_id'], isPortalRedirect);
			setParameterToHiddenInput("eBAF_UserObject_Flag", top['eBAF_UserObject_Flag'], false);
			setParameterToHiddenInput("eBAF_loginPlatformInfo", top['eBAF_loginPlatformInfo'], false);<%-- 加密後之登入平台相關資訊 --%>
			setParameterToHiddenInput("params", params, false);

			var B2E_TAM_Junction = '${B2E_TAM_Junction}';
			if(B2E_TAM_Junction){
				document.cookie = "IV_JCT=%2F" + B2E_TAM_Junction + "; path=/";
			}

			varMainForm.submit();

		}

		var addSysMenu=function(mainMenuData){
			var li = document.createElement('li');
			var func_name = mainMenuData['func_name'];
			if(mainMenuData['isLinkToSys']==='Y'){
				li.onclick=function(){gotoSys(mainMenuData);};
			}else{
				var showText = '「'+func_name+'」必需在公司內部網路才可連結';
				li.title=showText;
				li.onclick=function(){alert(showText);};
			}

			li.className= "main_menu";
			li.appendChild( document.createTextNode(func_name) );

			document.getElementById('showMainMenu').appendChild(li);
		}

		if(mainMenuDatas.length==0){
			var li = document.createElement('li');
			li.className = "no_menu";
			li.appendChild( document.createTextNode("無可使用系統") );
			document.getElementById('showMainMenu').appendChild(li);
		}else{
			for(var i=0;i<mainMenuDatas.length;i++){
				addSysMenu(mainMenuDatas[i]);
			}
		}
	}
//-->
</script>
</head>

<body onload='initApp()' style="margin:0;padding:0;background-color:#C7E49C;overflow:auto;">
<div class="tbBox" >
    <ul id="showMainMenu" style="width:100%;padding:0;margin:0;list-style:none;">
    </ul>
</div>

<form name="mainForm" method="post" target="_top">
	<input type="hidden" name="isInt" value='<c:out value="${outputDataMap.isInt}"/>'>
	<input type="hidden" name="mainContext" value='<c:out value="${outputDataMap.mainContext}"/>'>
	<input type="hidden" name="mainSessionID" value='<c:out value="${outputDataMap.mainSessionID}"/>'>
</form>
</body>
</html>