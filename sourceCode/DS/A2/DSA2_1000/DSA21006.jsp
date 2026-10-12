<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<!-- InstanceBegin template="/Templates/page.dwt" codeOutsideHTMLIsLocked="false" -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<!-- InstanceBeginEditable name="doctitle" -->
<title></title>
<!-- InstanceEndEditable -->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isROCdate用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/pageController.js"></script><!--控制資料分頁顯示-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script>
<!--

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


function initApp(){

	//顯示執行結果
	displayMessage();

		
	new Ajax.Request(
		"<%=dispatcher%>/DSA2_1006/print", 
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


//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad='initApp()' onResize="fix()" onScroll="fix()">
	<center>
		<div id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility: visible;">
			<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="4" background="<%=imageBase%>/CM/border_01.gif">
						<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
					</td>
					<td valign="top" bgcolor="#F0FBC6">
						<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
							<tr>
								<td height="4">
									<img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4">
								</td>
							</tr>
						</table>
						<!-- InstanceBeginEditable name="title" -->
						<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
							<tr>
								<td width="20" height="24">
									<div align="center"><font size="-5">●</font></div>
								</td>
								<td>核貸作業</td>
								<td><div align="right">畫面編號：DSA21006</div></td>
							</tr>
						</table>
						<!-- InstanceEndEditable -->
					</td>
					<td width="4" background="<%=imageBase%>/CM/border_02.gif">
						<img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12">
					</td>
					<td width="5" class="tbBox">
						<img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1">
					</td>
				</tr>
			</table>
		</div>
	</center>
	<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
		<tr><td></td></tr>
	</table>
	<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="4" background="<%=imageBase%>/CM/border_01.gif">
				<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
			</td>
			<td width="100%" valign="top" bgcolor="#F0FBC6">
				<!-- InstanceBeginEditable name="content" -->
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td valign="top">
							<table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
							<tbody>
								<tr>
									<td class="tbBox2"> 
										<table width="100%"  border="0" cellspacing="0" cellpadding="0">
											<tr>
												<td><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">鑑估表 </td>
											</tr>
										</table>
									</td>
								</tr>
								<tr bgcolor=#FFFFFF>
									<td>
										
									</td>
								</tr>
							</tbody>
							</table>
						</td>
					</tr>
				</table>
				<!-- InstanceEndEditable -->
			</td>
			<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
			<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
		</tr>
	</table>
</body>
<!-- InstanceEnd -->
</html>