<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource"/>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>

<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function initApp(){
	PageUI.createPageWithAllBodySubElement("DSA22200" , "核貸作業" , "聯徵系統連結", 1, true);

	cleanMsgBoard();
	displayMessage();
	
	ajaxPost("getURL", {"url":'${url}'}, function(resp){
		link(resp.url);
	});
	
	PageUI.resize(true);
}

function link(url){
	var conf = {};
	conf.src = url;
	popupWin.fullPopup(conf);
}

function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request(
		"<%=dispatcher%>/DSA2_2200/" + actionName,
		{ parameters: params,
          onSuccess: function(response) {
			var resp = response.responseJSON;

			if(CSRUtil.isSuccess(resp)){
				if(successAction){
	 				successAction(resp);
	 			}
			}else if(errorAction){
				errorAction(resp);
			}
			PageUI.resize(true);
        }}
	);
}

//-->
</script>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
</body>
</html>