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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
</head>

<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function initApp(){

	cleanMsgBoard();
	
	displayMessage();
	
	// 視窗關閉按鈕
	$("btn_close").observe('click', function(event){
			close();
		}
	);
	
	if('${isFirst}' == ''){
		$('FILE_NAME').value = '<c:out value="${FILE_NAME}" default="[]" escapeXml="false" />'; 
		CSRUtil.createCoverPage({'id':'DSA30200_coverpage', 'transparent':false, 'cursor':'auto', 'show': true}); 
		$('form1').action = "<%=dispatcher%>/DSA0_0100/prompt";
		submitOnce($('btn_close'));
	}

}

//--------------------------------------------------------------------------	
//	回上頁Function
//--------------------------------------------------------------------------
function doBack(){
	CSRUtil.linkBack();
}

//--------------------------------------------------------------------------	
//	影像清單超連結Function
//--------------------------------------------------------------------------
function doDownloadImage(FILE_NAME) {
	RPTUtil.downloadFile( '<%=dispatcher%>/DSA0_0100/downloadImage', { 'FILE_NAME': FILE_NAME, 'APPLY_ID': $F('APPLY_ID') } );
}

//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
		<center>
			<span id="bar1"	style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible;">
				<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
						<td valign="top" bgcolor="#F0FBC6" >
							<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
							<tr>
								<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
							</tr>
						</table>
						<!-- Block_1_Start 表單的開頭 次功能名稱 畫面編號-->
						<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
							<tr>
								<td width="20" height="24" align="center"><font size="-5">●</font></td>
								<td>受理作業</td>
								<td align="right">畫面編號：DSA00100&nbsp;</td>
							</tr>
						</table>
						<!-- Block_1_End 表單的開頭 次功能名稱 畫面編號-->
					</td>
					<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
					<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
				</tr>
			</table>
		</span>
		<table width="100%" height="30" border="0" cellpadding="0"
			cellspacing="0">
			<tr>
				<td>&nbsp;</td>
			</tr>
		</table>
		<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
				<td width="100%" valign="top" bgcolor="#F0FBC6">
					<table height="6" ><tr><td></td></tr></table>
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td valign="top"><table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
								<!-- Block_2_Start 子功能名稱-->
								<tr>
									<td class="tbBox2"><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">影像-連結DP</td>
								</tr>
								<!-- Block_2_End 子功能名稱-->
								<tr bgcolor=#FFFFFF>
									<td>
										<!-- Block_3_Start 表單主功能區塊-->
										<form name="form1" id="form1" method="post"><input name="LP_JSON" id="LP_JSON" type="hidden" value="">
											<input type="hidden" name="gridJSON" id="gridJSON" value="">
											<input type="hidden" name="isFirst" id="isFirst" value="Y">
											<input type="hidden" name="APPLY_ID" id="APPLY_ID" value="${APPLY_ID}">
											<input type="hidden" name="FILE_NAME" id="FILE_NAME" value="">
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
												<!-- Block_4_Start 輸入區塊-->
												<tr>
													<td class="tbYellow" align="center">借款人姓名</td>
													<td class="tbYellow" align="center">受理進度</td>
													<td class="tbYellow" align="center">徵信人員</td>
												</tr>
												<tr>
													<td class="tbYellow2" align="center">${rtnMap.BORROW_NAME}</td>
													<td class="tbYellow2" align="center"><cathay:conver sys="DS" field="APPLY_PROCESS" value="${rtnMap.APPLY_PROCESS}"/></td>
													<td class="tbYellow2" align="center"><cathay:transEmployeeIDForName value="${rtnMap.CRED_ID}" /></td>
												</tr>
												<tr>
													<td class="tbYellow" align="center" colspan="3">影像清單</td>
												</tr>
												<c:forEach var="BPMMap" items="${rtnMap.BPMList}" varStatus="status" >												
												<tr>
													<td class="tbYellow2" colspan="3">&nbsp;&nbsp;&nbsp;
														<a href="javascript:doDownloadImage('<c:out value="${BPMMap.fileName}"/>')">
															<c:out value="${BPMMap.fileName}"/>
														</a>
													</td>
												</tr>
												</c:forEach>
												<!-- Block_4_End 輸入區塊-->
											</table><p>&nbsp;
											<input type="button" id="btn_close" value="視窗關閉" class="button">
										</form>
										<!-- Block_3_End 表單主功能區塊-->
									</td>
								</tr>
							</table></td>
						</tr>
					</table>
				</td>
				<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
				<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
			</tr>
		</table>
		</center>
	</body>
</html>
