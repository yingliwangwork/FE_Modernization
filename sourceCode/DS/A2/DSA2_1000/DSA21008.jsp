<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<!-- InstanceBegin template="/Templates/page.dwt" codeOutsideHTMLIsLocked="false" -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<!-- InstanceBeginEditable name="doctitle" -->
<!-- InstanceEndEditable -->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script>
Event.observe(window, 'load', initApp);

function initApp(){

	//顯示執行結果
	displayMessage();
		
	new Ajax.Request(
		"<%=dispatcher%>/DSA2_1008/print", 
		{
			parameters:{APPLY_ID:'${APPLY_ID}'},
			onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					RPTUtil.executePrintByResponse(resp, false);
				}
			}
		}
	);		

}
</script>
</head>
</html>