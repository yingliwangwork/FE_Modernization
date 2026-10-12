<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA21010.jsp
作者：i9100621
功能：主管裁決批示清單
完成：2011/10/28

[20240729] 修改件 陳勁谷 難字修改
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/tabs.js"></script>
<%-- [20180328] 問題單20180327115719 每筆資料中間要有格線  --%>
<style type="text/css">
	tr.tbBlue2{
		border: 1px solid #C7E49C;
	}
</style>
<%--自行定義的javaScript--%>
<script type="text/JavaScript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var tabs;
function initApp(){

	displayMessage();

	//產生Tabs        
	initTabs();     
	
}

//初始化tab
function initTabs(){
		var showTabs = [];

		<c:if test="${showTab.G eq 'Y'}">
			showTabs.push({id:'tab1', title:'徵信案件(${tabMap.GListSize})'});
		</c:if>
		<c:if test="${showTab.R eq 'Y'}">
			showTabs.push({id:'tab2', title:'退件批示(${tabMap.RListSize})'});
		</c:if>
		<c:if test="${showTab.M eq 'Y'}">
			showTabs.push({id:'tab3', title:'變更年期(${tabMap.MListSize})'});
		</c:if>
		<c:if test="${showTab.A eq 'Y'}">
			showTabs.push({id:'tab4', title:'快速審核(${tabMap.AListSize})'});
		</c:if>
		<c:if test="${showTab.E eq 'Y'}">
			showTabs.push({id:'tab5', title:'簡易受理(${tabMap.EListSize})'});
		</c:if>
		<c:if test="${showTab.P eq 'Y'}">
			showTabs.push({id:'tab11', title:'一般鑑價件(${tabMap.PListSize})'});
		</c:if>
		<c:if test="${showTab.S eq 'Y'}">
			showTabs.push({id:'tab8', title:'土建融件(${tabMap.SListSize})'});
		</c:if>
		<c:if test="${showTab.T eq 'Y'}">
			showTabs.push({id:'tab9', title:'整批件(${tabMap.TListSize})'});
		</c:if>
		<c:if test="${showTab.C eq 'Y'}">
			//showTabs.push({id:'tab6', title:'線上放審會(${tabMap.CListSize})'});
		</c:if>
		<c:if test="${showTab.D eq 'Y'}">
			//showTabs.push({id:'tab7', title:'大額件退件(${tabMap.DListSize})'});
		</c:if>
		<c:if test="${showTab.U eq 'Y'}">
			showTabs.push({id:'tab10', title:'防止清償通報(${tabMap.UListSize})'});
		</c:if>
		<c:if test="${showTab.B eq 'Y'}">
			showTabs.push({id:'tab12', title:'其他借新還舊(${tabMap.BListSize})'});
		</c:if>		
		
		//[20201229] 智能件
		<c:if test="${showTab.I eq 'Y'}">
			showTabs.push({id:'tab13', title:'智能件(${tabMap.IListSize})'});
		</c:if>		
		
		//[20200224] 覆審件
		<c:if test="${showTab.F eq 'Y'}">
			showTabs.push({id:'tab14', title:'每月覆審(${tabMap.FListSize})'});
		</c:if>
	
		//定義 tabs
		if(showTabs.length > 0){
			tabs = new Tabs({		
				id:'menu',				
				tabs:showTabs
			});
		}
}

//超連結至DSA2_1011（主管裁決批示層級分頁畫面）
function toDSA2_1011(APPLY_ID, INST_LEVEL, INST_TYPE, SEQ_NO){
	var LP_JSON = {};
	var BQ_ARG = { CRED_DEPT:'${CRED_DEPT}' , INST_LEVEL:'${INST_LEVEL}' , SUP_CRED_DEPT:'${SUP_CRED_DEPT}'};
	LP_JSON.action = "<%=dispatcher%>/DSA2_1011/prompt";
	if('M' == INST_TYPE){
		LP_JSON.REFER_ID = APPLY_ID;
	}else{
		LP_JSON.APPLY_ID = APPLY_ID;
	}	
	
	LP_JSON.INST_LEVEL = INST_LEVEL;
	LP_JSON.INST_TYPE = INST_TYPE;
	LP_JSON.RQ_SENDER = "<%=dispatcher%>/DSA2_1010/prompt?CRED_DEPT=${CRED_DEPT}&INST_LEVEL=${INST_LEVEL}&SUP_CRED_DEPT=${SUP_CRED_DEPT}";
	if(SEQ_NO != ''){
		LP_JSON.SEQ_NO = SEQ_NO;
	}
	LP_JSON.BQ_ARG = BQ_ARG;
	CSRUtil.linkTo(LP_JSON, 'form1');
}

//超連結至DSA2_1015（線上放審會分頁畫面）
function toDSA2_1015(APPLY_ID, INST_LEVEL, INST_TYPE, SEQ_NO){
	var LP_JSON = {};
	var BQ_ARG = { CRED_DEPT:'${CRED_DEPT}' , INST_LEVEL:'${INST_LEVEL}' , SUP_CRED_DEPT:'${SUP_CRED_DEPT}'};
	LP_JSON.action = "<%=dispatcher%>/DSA2_1011/prompt";
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.CRED_DEPT = '${CRED_DEPT}';	
	
	LP_JSON.INST_LEVEL = INST_LEVEL;
	LP_JSON.INST_TYPE = INST_TYPE;
	LP_JSON.RQ_SENDER = "<%=dispatcher%>/DSA2_1010/prompt?CRED_DEPT=${CRED_DEPT}&INST_LEVEL=${INST_LEVEL}";
	if(SEQ_NO != ''){
		LP_JSON.SEQ_NO = SEQ_NO;
	}
	LP_JSON.BQ_ARG = BQ_ARG;
	CSRUtil.linkTo(LP_JSON, 'form1');
}

//超連結至放款防止清償通報畫面（防止清償通報畫面）
function toDTDSD300(LOAN_ID,INST_LEVEL, INST_TYPE){
	var LP_JSON = {};
	var BQ_ARG = { CRED_DEPT:'${CRED_DEPT}' , INST_LEVEL:'${INST_LEVEL}'};
	LP_JSON.action = "<%=dispatcher%>/DSD3_0200/prompt?LOAN_ID="+LOAN_ID+"&INST_LEVEL=${INST_LEVEL}";
	LP_JSON.RQ_SENDER = "<%=dispatcher%>/DSA2_1010/prompt?CRED_DEPT=${CRED_DEPT}&INST_LEVEL=${INST_LEVEL}";
	LP_JSON.BQ_ARG = BQ_ARG;
	CSRUtil.linkTo(LP_JSON, 'form1');
}

function toDSA3_0500(APPLY_ID, INST_LEVEL, INST_TYPE){
	var LP_JSON = {};
	var BQ_ARG = { CRED_DEPT:'${CRED_DEPT}' , INST_LEVEL:'${INST_LEVEL}'};
	LP_JSON.action = "<%=dispatcher%>/DSA3_0500/prompt";
	LP_JSON.OP = 2;
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.RQ_SENDER = "<%=dispatcher%>/DSA2_1010/prompt?CRED_DEPT=${CRED_DEPT}&INST_LEVEL=${INST_LEVEL}";
	LP_JSON.BQ_ARG = BQ_ARG;
	CSRUtil.linkTo(LP_JSON, 'form1');
}

function toDSA3_0501(APPLY_ID, INST_LEVEL, INST_TYPE){
	var LP_JSON = {};
	var BQ_ARG = { CRED_DEPT:'${CRED_DEPT}' , INST_LEVEL:'${INST_LEVEL}'};
	LP_JSON.action = "<%=dispatcher%>/DSA3_0500/prompt";
	LP_JSON.OP = 2;
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.RQ_SENDER = "<%=dispatcher%>/DSA2_1010/prompt?CRED_DEPT=${CRED_DEPT}&INST_LEVEL=${INST_LEVEL}";
	LP_JSON.BQ_ARG = BQ_ARG;
	CSRUtil.linkTo(LP_JSON, 'form1');
}

function toDSA3_0600(APPLY_ID, INST_LEVEL, INST_TYPE){
	var LP_JSON = {};
	var BQ_ARG = { CRED_DEPT:'${CRED_DEPT}' , INST_LEVEL:'${INST_LEVEL}'};
	LP_JSON.action = "<%=dispatcher%>/DSA3_0600/prompt";
	LP_JSON.OP = 2;
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.RQ_SENDER = "<%=dispatcher%>/DSA2_1010/prompt?CRED_DEPT=${CRED_DEPT}&INST_LEVEL=${INST_LEVEL}";
	LP_JSON.BQ_ARG = BQ_ARG;
	CSRUtil.linkTo(LP_JSON, 'form1');
}

function toDSA3_0700(APPLY_ID, INST_LEVEL, INST_TYPE){
	var LP_JSON = {};
	var BQ_ARG = { CRED_DEPT:'${CRED_DEPT}' , INST_LEVEL:'${INST_LEVEL}'};
	LP_JSON.action = "<%=dispatcher%>/DSA3_0700/prompt";
	LP_JSON.OP = 2;
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.RQ_SENDER = "<%=dispatcher%>/DSA2_1010/prompt?CRED_DEPT=${CRED_DEPT}&INST_LEVEL=${INST_LEVEL}";
	LP_JSON.BQ_ARG = BQ_ARG;
	CSRUtil.linkTo(LP_JSON, 'form1');
}

function toDSA6_0500(REV_DEPT_CODE, REV_TYPE, REV_YM){
	var LP_JSON = {};
	var BQ_ARG = { CRED_DEPT:'${CRED_DEPT}' , INST_LEVEL:'${INST_LEVEL}'};
	LP_JSON.action = "<%=dispatcher%>/DSA6_0500/prompt";
	LP_JSON.REV_DEPT_CODE = REV_DEPT_CODE;
	LP_JSON.REV_TYPE = REV_TYPE;
	LP_JSON.REV_YM = REV_YM;
	LP_JSON.CRED_DEPT = '${CRED_DEPT}';	
	LP_JSON.INST_LEVEL = '${INST_LEVEL}';
	LP_JSON.INST_TYPE = 'F';
	LP_JSON.RQ_SENDER = "<%=dispatcher%>/DSA2_1010/prompt?CRED_DEPT=${CRED_DEPT}&INST_LEVEL=${INST_LEVEL}";
	LP_JSON.BQ_ARG = BQ_ARG;
	CSRUtil.linkTo(LP_JSON, 'form1');
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
<span id="bar1"	style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible;">
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
			<tr>
				<td height="4"><img src="<%=imageBase%>/CM/border_03.gif"
					width="12" height="4"></td>
			</tr>
		</table>
		<!-- InstanceBeginEditable name="title" -->
		<table width="100%" border="0" cellpadding="2" cellspacing="0"
			class="subTitle">
			<tr>
				<td width="20" height="24">
				<div align="center"><font size="-5">●</font></div>
				</td>
				<td><b>核心放款</b><br>
				</td>
				<td align="right">畫面編號：DSA21010</td>
			</tr>
		</table>
		<!-- InstanceEndEditable --></td>
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
		<td width="100%" valign="top" bgcolor="#F0FBC6"><!-- InstanceBeginEditable name="content" -->
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td valign="top">
				<table width=97% border=0 align=center cellpadding="0"
					cellspacing="1" bgcolor="#003366">
					<!--<tbody>-->
						<tr>
							<td class="tbBox2">
							<p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18"
								height="16">主管裁決批示清單</p>
							</td>
						</tr>
						<tr bgcolor=#FFFFFF>
							<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="5">
								<tr>
									<td>
									<form id="" name="form1" method="post">	
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
												<tr>
													<td bgcolor="#F0FBC6" >  									
														<div id="menu" style="width:100%"></div>
														<div id="contents1" class="tab" style="width:100%" >
												<!-- 頁籤1（徵信案件） -->
														<c:if test="${showTab.G eq 'Y'}">
								                          <table id="tab1" name="tab1" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>徵信案件  </b><font color="red"><b>    Ａ：ＡＰＰ受理件</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.GListSize > 0}">																			
																	<c:set var="GListbgColor" value="" /><!-- TD背景底色 -->
																	<c:set var="GListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.GList}' varStatus="status1" >
																		<!-- 根據呈核最高層級(GList[i].AGREE_LEVEL)顯示每筆資料的TD背景底色 -->
																		<c:choose>
																			<c:when test="${map.AGREE_LEVEL eq '90'}">
																				<c:set var="GListbgColor" value="#f0e68c" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '80'}">
																				<c:set var="GListbgColor" value="#d9ed92" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '70'}">
																				<c:set var="GListbgColor" value="#fff8dc" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '60'}">
																				<c:set var="GListbgColor" value="#a0ffff" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '50'}">
																				<c:set var="GListbgColor" value="#eebbff" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '40'}">
																				<c:set var="GListbgColor" value="#ffffa0" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="GListbgColor" value="#ccccff" />
																			</c:otherwise>
																		</c:choose>	
																		<!-- 若GList[i].IS_AGREE==”N” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.IS_AGREE eq 'N'}">
																				<c:set var="GListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="GListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${GListbgColor}" width="33%" valign="top">
																			<font color="red"><c:out value='${map.ELITE_AGENT}' /></font> <!-- 優先承辦符號 -->
																			<c:out value='${map.CRED_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(核定層級：<c:out value='${map.AGREE_LEVEL_NM}' />)
																			<c:if test="${map.PREFER_TYPE eq '56'}">
																				<font color="red">　(築)</font>
																			</c:if>
																			<c:if test="${map.FAST_AGREE eq 'A'}">
																				<font color="red">　(快)</font>
																			</c:if>																			
																			<BR><!-- 徵信人員姓名  (核定層級:中文名稱) -->
																			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
																			<a href="#" style="color:${GListFontColor1}; font-family:'EUDC';" onClick="toDSA2_1011('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>','')" >
																			<c:out value='${map.APPLY_ID}${map.BORROW_NAME}' /></a><!--受理編號 借款人姓名-->
																			(<c:out value='${map.LOAN_TYPE_NM}' /><!--貸款種類中文-->
																			&nbsp;擬准金額 :<c:out value='${map.TOTAL_AGREE_AMT}' />萬)<!--擬准金額 -->
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="GListSpace" value="${tabMap.GListSize % 3}" />
																	<c:if test="${GListSpace != 0}">
																		 <c:forEach var="j" begin="${GListSpace}" end="2" step="1">
																			<td bgcolor="${GListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
								                         </c:if>

												<!-- 頁籤2（退件批示） -->
														<c:if test="${showTab.R eq 'Y'}">
								                          <table id="tab2" name="tab2" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>退件批示</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.RListSize > 0}">
																	<c:forEach var="map" items='${tabMap.RList}' varStatus="status1" >
																		<c:set var="RListbgColor" value="#eebbff" /><!-- 變動TD背景底色 -->																		
																			<c:choose>
																				<c:when test="${map.REJ_LEVEL eq '50'}">
																					<c:set var="RListbgColor" value="#eebbff" />
																				</c:when>
																				<c:otherwise>
																					<c:set var="RListbgColor" value="#ffffa0" />
																				</c:otherwise>
																			</c:choose>																																
																		<c:set var="RListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																		<!-- 若RList[i].IS_REJ==”N” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.IS_REJ eq 'N'}">
																				<c:set var="RListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="RListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${RListbgColor}" width="33%" valign="top">
																			<font color="red"><c:out value='${map.WORK_CELL}' /></font> <!-- WORKCELL-->
																			<c:out value='${map.REJ_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(核定層級：<c:out value='${map.REJ_LEVEL_NM}' />)<BR><!-- 徵信人員姓名  (核定層級:中文名稱) -->
																			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
																			<a href="#" style="color:${RListFontColor1}; font-family:'EUDC';" onClick="toDSA2_1011('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>','')" >
																			<c:out value='${map.APPLY_ID}${map.BORROW_NAME}' /></a><!--受理編號 借款人姓名-->
																			<!-- 審查結果 -->
																			<c:if test="${map.REJ_AUDIT_AGREE eq 'N'}">
																				<font color="red">審查不同意</font>
																			</c:if>																																																																		
																		
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="RListSpace" value="${tabMap.RListSize % 3}" />
																	<c:if test="${RListSpace != 0}">
																		 <c:forEach var="j" begin="${RListSpace}" end="2" step="1">
																			<td bgcolor="${RListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
														</c:if>
														
												<!-- 頁籤3（變更年期） -->
														<c:if test="${showTab.M eq 'Y'}">
								                          <table id="tab3" name="tab3" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>變更年期</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.MListSize > 0}">
																	<c:set var="MListbgColor" value="#eebbff" /><!-- TD背景底色 -->																		
																	<c:set var="MListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.MList}' varStatus="status1" >
																		<!-- 若MList[i].IS_AGREE==”N” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.IS_AGREE eq 'N'}">
																				<c:set var="MListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="MListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${MListbgColor}" width="33%" valign="top">
																			<c:out value='${map.CRED_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(核定層級：<c:out value='${map.AGREE_LEVEL_NM}' />)<BR><!-- 徵信人員姓名  (核定層級:中文名稱) -->
																			<a href="#" style="color:${MListFontColor1};" onClick="toDSA2_1011('<c:out value='${map.REFER_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>','<c:out value='${map.SEQ_NO}'/>')" >
																			<c:out value='${map.REFER_ID}${map.BORROW_NAME}' /></a><!--受理編號 借款人姓名-->												
																			<font color="red">(<c:out value='${map.CRED_DEPT_NM}' />)</font>
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="MListSpace" value="${tabMap.MListSize % 3}" />
																	<c:if test="${MListSpace != 0}">
																		 <c:forEach var="j" begin="${MListSpace}" end="2" step="1">
																			<td bgcolor="${MListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
								                         </c:if> 
								                         
												<!-- 頁籤4（快速審核） -->
														<c:if test="${showTab.A eq 'Y'}">
								                          <table id="tab4" name="tab4" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>快速審核</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.AListSize > 0}">																			
																	<c:set var="AListbgColor" value="" /><!-- TD背景底色 -->
																	<c:set var="AListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.AList}' varStatus="status1" >
																		<!-- 根據呈核最高層級(AList[i].AGREE_LEVEL)顯示每筆資料的TD背景底色 -->
																		<c:choose>
																			<c:when test="${map.AGREE_LEVEL eq '90'}">
																				<c:set var="GListbgColor" value="#f0e68c" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '80'}">
																				<c:set var="GListbgColor" value="#d9ed92" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '70'}">
																				<c:set var="GListbgColor" value="#fff8dc" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '60'}">
																				<c:set var="AListbgColor" value="#a0ffff" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '50'}">
																				<c:set var="AListbgColor" value="#eebbff" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '40'}">
																				<c:set var="AListbgColor" value="#ffffa0" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="AListbgColor" value="#ccccff" />
																			</c:otherwise>
																		</c:choose>	
																		<!-- 若AList[i].IS_AGREE==”N” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.IS_AGREE eq 'N'}">
																				<c:set var="AListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="AListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${AListbgColor}" width="33%" valign="top">
																			<font color="red"><c:out value='${map.ELITE_AGENT}' /></font> <!-- 優先承辦符號 -->
																			<c:out value='${map.CRED_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(核定層級：<c:out value='${map.AGREE_LEVEL_NM}' />)
																			<c:if test="${map.PREFER_TYPE eq '56'}">
																				<font color="red">　(築)</font>
																			</c:if>																			
																			<BR><!-- 徵信人員姓名  (核定層級:中文名稱) -->
																			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
																			<a href="#" style="color:${AListFontColor1}; font-family:'EUDC';" onClick="toDSA2_1011('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>','')" >
																			<c:out value='${map.APPLY_ID}${map.BORROW_NAME}' /></a><!--受理編號 借款人姓名-->
																			(<c:out value='${map.LOAN_TYPE_NM}' /><!--貸款種類中文-->
																			&nbsp;擬准金額 :<c:out value='${map.TOTAL_AGREE_AMT}' />萬)<!--擬准金額 -->
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="AListSpace" value="${tabMap.AListSize % 3}" />
																	<c:if test="${AListSpace != 0}">
																		 <c:forEach var="j" begin="${AListSpace}" end="2" step="1">
																			<td bgcolor="${AListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>								                          
														</c:if>
														
												<!-- 頁籤5（簡易受理） -->
														<c:if test="${showTab.E eq 'Y'}">
								                          <table id="tab5" name="tab5" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>簡易受理</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.EListSize > 0}">
																	<c:set var="EListbgColor" value="#eebbff" /><!-- TD背景底色 -->																		
																	<c:set var="EListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.EList}' varStatus="status1" >
																		<!-- 若EList[i].IS_AGREE==”N” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.IS_AGREE eq 'N'}">
																				<c:set var="EListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="EListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${EListbgColor}" width="33%" valign="top">
																			<c:out value='${map.CRED_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR><!-- 徵信人員姓名  (核定層級:中文名稱) -->
																			<a href="#" style="color:${EListFontColor1};" onClick="toDSA2_1011('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>','<c:out value='${map.SEQ_NO}'/>')" >
																			<c:out value='${map.APPLY_ID}${map.BORROW_NAME}' /></a><!--受理編號 借款人姓名-->														
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="EListSpace" value="${tabMap.EListSize % 3}" />
																	<c:if test="${EListSpace != 0}">
																		 <c:forEach var="j" begin="${EListSpace}" end="2" step="1">
																			<td bgcolor="${EListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
								                         </c:if>
								                         
												<!-- 頁籤6（線上放審會） -->
														<c:if test="${showTab.C eq 'Y'}">
								                          <table id="tab6" name="tab6" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>線上放審會</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.CListSize > 0}">																			
																	<c:set var="CListbgColor" value="#eebbff" /><!-- TD背景底色 -->
																	<c:set var="CListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.CList}' varStatus="status1" >
																		<!-- 若CList[i].IS_AGREE==”N” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.IS_AGREE eq 'N'}">
																				<c:set var="CListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="CListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${CListbgColor}" width="33%" valign="top">
																			<!--20140814刪除<font color="red"><c:out value='${map.ELITE_AGENT}' /></font>  --> <!-- 優先承辦符號 -->
																			<c:out value='${map.CRED_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(核定層級：<c:out value='${map.AGREE_LEVEL_NM}' />)<BR><!-- 徵信人員姓名  (核定層級:中文名稱) -->
																			<a href="#" style="color:${CListFontColor1};" onClick="toDSA2_1015('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>','')" >
																			<c:out value='${map.APPLY_ID}${map.BORROW_NAME}' /></a><!--受理編號 借款人姓名-->
																			(<c:out value='${map.LOAN_TYPE_NM}' /><!--貸款種類中文-->
																			&nbsp;擬准金額 :<c:out value='${map.TOTAL_AGREE_AMT}' />萬)<!--擬准金額 -->
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="CListSpace" value="${tabMap.CListSize % 3}" />
																	<c:if test="${CListSpace != 0}">
																		 <c:forEach var="j" begin="${CListSpace}" end="2" step="1">
																			<td bgcolor="${CListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
								                         </c:if> 							                          														

												<!-- 頁籤7（大額件退件） -->
														<c:if test="${showTab.D eq 'Y'}">
								                          <table id="tab7" name="tab7" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>大額件退件</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.DListSize > 0}">																			
																	<c:set var="DListbgColor" value="#eebbff" /><!-- TD背景底色 -->
																	<c:set var="DListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.DList}' varStatus="status1" >
																		<!-- 根據呈核最高層級(GList[i].AGREE_LEVEL)顯示每筆資料的TD背景底色 -->
																		<c:choose>
																			<c:when test="${map.REJ_LEVEL eq '50'}">
																				<c:set var="DListbgColor" value="#eebbff" />
																			</c:when>
																			<c:when test="${map.REJ_LEVEL eq '40'}">
																				<c:set var="DListbgColor" value="#ffffa0" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="DListbgColor" value="#ccccff" />
																			</c:otherwise>
																		</c:choose>	
																		<!-- 若DList[i].IS_AGREE==”N” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.IS_AGREE eq 'N'}">
																				<c:set var="DListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="DListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${DListbgColor}" width="33%" valign="top">
																			<!--20140814刪除<font color="red"><c:out value='${map.ELITE_AGENT}' /></font>--> <!-- 優先承辦符號 -->
																			<c:out value='${map.REJ_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(核定層級：<c:out value='${map.REJ_LEVEL_NM}' />)<BR><!-- 徵信人員姓名  (核定層級:中文名稱) -->
																			<a href="#" style="color:${DListFontColor1};" onClick="toDSA2_1015('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>','')" >
																			<c:out value='${map.APPLY_ID}${map.BORROW_NAME}' /></a><!--受理編號 借款人姓名-->
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="DListSpace" value="${tabMap.DListSize % 3}" />
																	<c:if test="${DListSpace != 0}">
																		 <c:forEach var="j" begin="${DListSpace}" end="2" step="1">
																			<td bgcolor="${DListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
								                         </c:if> 
												<!-- 頁籤8（土建融件） -->
														<c:if test="${showTab.S eq 'Y'}">
								                          <table id="tab8" name="tab8" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>土建融件</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.SListSize > 0}">
																	<c:set var="SListbgColor" value="#eebbff" /><!-- TD背景底色 -->																		
																	<c:set var="SListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.SList}' varStatus="status1" >
																		<c:set var="SListFontColor1" value="blue"  />
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${SListbgColor}" width="33%" valign="top">
																			<!--20140814刪除<font color="red"><c:out value='${map.ELITE_AGENT}' /></font>--> <!-- 優先承辦符號 -->
																			<c:out value='${map.APPR_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR><!-- 鑑價人員姓名 -->
																			<a href="#" style="color:${SListFontColor1};" onClick="toDSA3_0600('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>')" >
																			<c:out value='${map.APPLY_ID}${map.NAME}' /></a><!--受理編號 借款人姓名-->												
																			<font color="red">(<c:out value='${map.APPR_DEPT_NM}' />)</font>
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="SListSpace" value="${tabMap.SListSize % 3}" />
																	<c:if test="${SListSpace != 0}">
																		 <c:forEach var="j" begin="${SListSpace}" end="2" step="1">
																			<td bgcolor="${SListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
								                         </c:if> 
												<!-- 頁籤9（整批件） -->
														<c:if test="${showTab.T eq 'Y'}">
								                          <table id="tab9" name="tab9" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>整批件</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.TListSize > 0}">
																	<c:set var="TListbgColor" value="#eebbff" /><!-- TD背景底色 -->																		
																	<c:set var="TListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.TList}' varStatus="status1" >
																		<c:set var="TListFontColor1" value="blue"  />
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${TListbgColor}" width="33%" valign="top">
																			<!--20140814刪除<font color="red"><c:out value='${map.ELITE_AGENT}' /></font> --><!-- 優先承辦符號 -->
																			<c:out value='${map.APPR_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR><!-- 鑑價人員姓名 -->
																			<a href="#" style="color:${SListFontColor1};" onClick="toDSA3_0700('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>')" >
																			<c:out value='${map.APPLY_ID}${map.NAME}' /></a><!--受理編號 借款人姓名-->												
																			<font color="red">(<c:out value='${map.APPR_DEPT_NM}' />)</font>
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="TListSpace" value="${tabMap.TListSize % 3}" />
																	<c:if test="${SListSpace != 0}">
																		 <c:forEach var="j" begin="${TListSpace}" end="2" step="1">
																			<td bgcolor="${TListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
								                         </c:if>
												<!-- 頁籤10（防止清償通報） -->
														<c:if test="${showTab.U eq 'Y'}">
								                          <table id="tab10" name="tab10" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>防止清償通報</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.UListSize > 0}">
																	<c:set var="MListbgColor" value="#eebbff" /><!-- TD背景底色 -->																		
																	<c:set var="MListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.UList}' varStatus="status1" >
																		<!-- 若MList[i].IS_AGREE==”N” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.IS_AGREE eq 'N'}">
																				<c:set var="UListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="UListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${MListbgColor}" width="33%" valign="top">
																			<c:out value='${map.PROC_NAME2}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(核定層級：<c:out value='${map.PROCESS_LEVEL_NM}' />)<BR><!-- 通報人員  (核定層級:中文名稱) -->
																			<a href="#" style="color:${UListFontColor1};" onClick="toDTDSD300('<c:out value='${map.LOAN_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>')" >
																			<c:out value='${map.LOAN_ID} ${map.BORROW_NAME} (利率調降件)' /></a><!--原貸帳號+客戶姓名+(利率調降件)-->												
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="MListSpace" value="${tabMap.MListSize % 3}" />
																	<c:if test="${MListSpace != 0}">
																		 <c:forEach var="j" begin="${MListSpace}" end="2" step="1">
																			<td bgcolor="${MListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
								                         </c:if> 
								                         
												<!-- 頁籤11（一般鑑價件） -->
														<c:if test="${showTab.P eq 'Y'}">
								                          <table id="tab11" name="tab11" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="3"><b>一般鑑價件</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.PListSize > 0}">
																	<c:set var="PListbgColor" value="#eebbff" /><!-- TD背景底色 -->																		
																	<c:set var="PListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.PList}' varStatus="status1" >
																		<!-- 若EList[i].APPR_PROCESS==”4” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.APPR_PROCESS eq '4'}">
																				<c:set var="PListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="PListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${PListbgColor}" width="33%" valign="top">
																			<font color="red"><c:out value='${map.ELITE_AGENT}' /></font> <!-- 優先承辦符號 -->
																			<c:out value='${map.APPR_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR><!-- 鑑價人員姓名 -->
																			<a href="#" style="color:${PListFontColor1};" onClick="toDSA3_0500('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>')" >
																			<c:out value='${map.APPLY_ID}${map.NAME}' /></a><!--受理編號 借款人姓名-->												
																			<font color="red">(<c:out value='${map.APPR_DEPT_NM}' />)</font>
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="PListSpace" value="${tabMap.PListSize % 3}" />
																	<c:if test="${PListSpace != 0}">
																		 <c:forEach var="j" begin="${PListSpace}" end="2" step="1">
																			<td bgcolor="${PListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
								                         </c:if> 
								                         <!-- 頁籤12（其他借新還舊(帳號整併)） -->
														<c:if test="${showTab.B eq 'Y'}">
								                          <table id="tab12" name="tab12" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="4"><b>其他借新還舊</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.BListSize > 0}">																			
																	<c:set var="BListbgColor" value="" /><!-- TD背景底色 -->
																	<c:set var="BListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.BList}' varStatus="status1" >
																		<!-- 根據呈核最高層級(AList[i].AGREE_LEVEL)顯示每筆資料的TD背景底色 -->
																		<c:choose>
																			<c:when test="${map.AGREE_LEVEL eq '90'}">
																				<c:set var="BListbgColor" value="#f0e68c" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '80'}">
																				<c:set var="BListbgColor" value="#d9ed92" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '70'}">
																				<c:set var="BListbgColor" value="#fff8dc" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '60'}">
																				<c:set var="BListbgColor" value="#a0ffff" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '50'}">
																				<c:set var="BListbgColor" value="#eebbff" />
																			</c:when>
																			<c:when test="${map.AGREE_LEVEL eq '40'}">
																				<c:set var="BListbgColor" value="#ffffa0" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="BListbgColor" value="#ccccff" />
																			</c:otherwise>
																		</c:choose>	
																		<!-- 若BList[i].IS_AGREE==”N” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.IS_AGREE eq 'N'}">
																				<c:set var="BListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="BListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${BListbgColor}" width="33%" valign="top">
																			<font color="red"><c:out value='${map.ELITE_AGENT}' /></font> <!-- 優先承辦符號 -->
																			<c:out value='${map.CRED_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(核定層級：<c:out value='${map.AGREE_LEVEL_NM}' />)
																			<c:if test="${map.PREFER_TYPE eq '56'}">
																				<font color="red">　(築)</font>
																			</c:if>																			
																			<BR><!-- 徵信人員姓名  (核定層級:中文名稱) -->
																			<a href="#" style="color:${AListFontColor1};" onClick="toDSA2_1011('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>','')" >
																			<c:out value='${map.APPLY_ID}${map.BORROW_NAME}' /></a><!--受理編號 借款人姓名-->
																			(<c:out value='${map.LOAN_TYPE_NM}' /><!--貸款種類中文-->
																			&nbsp;擬准金額 :<c:out value='${map.TOTAL_AGREE_AMT}' />萬)<!--擬准金額 -->
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="AListSpace" value="${tabMap.BListSize % 3}" />
																	<c:if test="${BListSpace != 0}">
																		 <c:forEach var="j" begin="${BListSpace}" end="2" step="1">
																			<td bgcolor="${BListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>								                          
														</c:if>
														<!-- 頁籤13（智能件）[20201229] -->
														<c:if test="${showTab.I eq 'Y'}">
								                          <table id="tab13" name="tab13" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															<tr><td class="tbYellow0" align="center" colspan="5"><b>智能件</b></td></tr>
															<tr class="tbBlue2" >									
															<c:choose>
																<c:when test="${tabMap.IListSize > 0}">
																	<c:set var="IListbgColor" value="#eebbff" /><!-- TD背景底色 -->																		
																	<c:set var="IListFontColor1" value="" /><!-- 變動字體色(IS_AGREE) -->
																	<c:forEach var="map" items='${tabMap.IList}' varStatus="status1" >
																		<!-- 若EList[i].APPR_PROCESS==”4” 顯示綠色字體，否則，顯示藍色字體 -->
																		<c:choose>
																			<c:when test="${map.APPR_PROCESS eq '4'}">
																				<c:set var="IListFontColor1" value="green" />
																			</c:when>																																																																		
																			<c:otherwise>
																				<c:set var="IListFontColor1" value="blue"  />
																			</c:otherwise>
																		</c:choose>																																
																		<c:if test="${status1.count % 3 == 1 }">
																		<tr class="tbBlue2">																		
																		</c:if>
																		<td bgcolor="${IListbgColor}" width="33%" valign="top">
																			<!--<font color="red"><c:out value='${map.ELITE_AGENT}' /></font>--> <!-- 優先承辦符號 -->
																			<c:out value='${map.AUDIT_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR><!-- 覆核人員姓名 -->
																			<a href="#" style="color:${IListFontColor1};" onClick="toDSA3_0501('<c:out value='${map.APPLY_ID}'/>','<c:out value='${INST_LEVEL}'/>','<c:out value='${map.INST_TYPE}'/>')" >
																			<c:out value='${map.APPLY_ID}${map.NAME}' /></a><!--受理編號 借款人姓名-->												
																			<font color="red">(<c:out value='${map.APPR_DEPT_NM}' />)</font> 
																		</td>
																		<c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		</c:if>														
																	</c:forEach>
																	<!-- 補空格 -->
																	<c:set var="PListSpace" value="${tabMap.IListSize % 3}" />
																	<c:if test="${IListSpace != 0}">
																		 <c:forEach var="j" begin="${IListSpace}" end="2" step="1">
																			<td bgcolor="${IListbgColor}">&nbsp;</td>
																		 </c:forEach>																			
																	</c:if>
																</c:when>
																<c:otherwise>
																	<td bgcolor="#eebbff">無待審件</td>
																</c:otherwise>																					
															</c:choose>
															</tr>				                            
								                          </table>
								                         </c:if> 
								                         <!-- 頁籤14（每月覆審） -->
														 <c:if test="${showTab.F eq 'Y'}">
								                           <table id="tab14" name="tab14" width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tbBox2" style="display:none">
															 <tr><td class="tbYellow0" align="center" colspan="3"><b>一般覆審</b></td></tr>
															 <tr class="tbBlue2" >	
															 <c:set var="FListbgColor" value="#eebbff" />								
															 <c:choose>
																 <c:when test="${tabMap.F0ListSize > 0}">
																	 <c:forEach var="map" items='${tabMap.F0List}' varStatus="status1" >
																		 <c:if test="${status1.count % 3 == 1 }">
																		 <tr class="tbBlue2">																		
																		 </c:if>
																		 <td bgcolor="${FListbgColor}" width="33%" valign="top">
																			 <c:out value='${map.REV_DEPT_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR><!-- 覆審科別 -->
																			 <a href="#" onClick="toDSA6_0500('<c:out value='${map.REV_DEPT_CODE}'/>','<c:out value='${map.REV_TYPE}'/>','<c:out value='${map.REV_YM}'/>')" >
																			 <!--<c:out value='${map.REV_YY}年度${map.REV_MM}月份 ${map.REV_TYPE_NAME}' /></a>--><!--OOO年度OO月份 OO覆審 -->
																			 <c:out value='${map.REV_YY}年度${map.REV_MM}月份 ' /></a><!--OOO年度OO月份 -->
																		 </td>
																		 <c:if test="${status1.count % 3 == 0 }">
																		 </tr>
																		 <tr class="tbBlue2">																				
																		 </c:if>														
																	 </c:forEach>
																	 <!-- 補空格 -->
																	 <c:set var="FListSpace" value="${tabMap.F0ListSize % 3}" />
																	 <c:if test="${FListSpace != 0}">
																		  <c:forEach var="j" begin="${FListSpace}" end="2" step="1">
																			 <td bgcolor="${FListbgColor}">&nbsp;</td>
																		  </c:forEach>																			
																	 </c:if>
																 </c:when>
																 <c:otherwise>
																	 <td bgcolor="${FListbgColor}" colspan="3">無待審件</td>
																 </c:otherwise>																						
															 </c:choose>
															 </tr>
															 <tr><td class="tbYellow0" align="center" colspan="3"><b>重要覆審</b></td></tr>
															 <tr class="tbBlue2" >									
															 <c:choose>
																 <c:when test="${tabMap.F1ListSize > 0}">
																	 <c:forEach var="map" items='${tabMap.F1List}' varStatus="status1" >
																		 <c:if test="${status1.count % 3 == 1 }">
																		 <tr class="tbBlue2">																		
																		 </c:if>
																		 <td bgcolor="${FListbgColor}" width="33%" valign="top">
																			 <c:out value='${map.REV_DEPT_NAME}' />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR>
																			 <a href="#" onClick="toDSA6_0500('<c:out value='${map.REV_DEPT_CODE}'/>','<c:out value='${map.REV_TYPE}'/>','<c:out value='${map.REV_YM}'/>')" >
																			 <c:out value='${map.REV_YY}年度${map.REV_MM}月份 ' /></a>											
																		 </td>
																		 <c:if test="${status1.count % 3 == 0 }">
																		  </tr>
																		  <tr class="tbBlue2">																				
																		 </c:if>														
																	 </c:forEach>
																	 <c:set var="FListSpace" value="${tabMap.F1ListSize % 3}" />
																	 <c:if test="${FListSpace != 0}">
																		  <c:forEach var="j" begin="${FListSpace}" end="2" step="1">
																			 <td bgcolor="${FListbgColor}">&nbsp;</td>
																		  </c:forEach>																			
																	 </c:if>
																 </c:when>
																 <c:otherwise>
																	 <td bgcolor="${FListbgColor}" colspan="3">無待審件</td>
																 </c:otherwise>																						
															 </c:choose>
															 </tr> 			                            
								                           </table>								                          
														 </c:if>
														
														</div>
					
													</td>
												</tr>
											</table>
									</form>
									</td>
								</tr>
							</table>
							</td>
						</tr>
					<!--</tbody>-->
				</table>
				</td>
			</tr>
		</table>
		<!-- InstanceEndEditable --></td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</body>
<!-- InstanceEnd -->
</html>
