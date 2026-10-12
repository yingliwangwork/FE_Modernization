<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%--
[20241030]修改件 CHROME瀏覽器難字調整
--%>
<%@ include file="/html/CM/header.jsp"%>
<%@ page import="java.util.*" %>
<%@ page import="com.cathay.common.util.DATE" %>
<%@ page import="org.apache.commons.collections.MapUtils"%>

<%@ page import="com.igsapp.wibc.dataobj.Context.*" %>
<%@ page import="com.igsapp.wibc.dataobj.html.HttpResponseContext" %>
<%@ page import="com.igsapp.wibc.dataobj.html.HttpTxContext" %>
<%@ page import="org.apache.log4j.Logger"%>

<!-- 使用taglib 必需引用的宣告 START -->
<%@ taglib uri="/WEB-INF/tlds/taglibs-input.tld" prefix="input" %>
<%@ taglib uri="/WEB-INF/tlds/cathay.tld" prefix="cathay" %>


<%@ taglib uri="/WEB-INF/tlds/fmt-rt.tld" prefix="fmt-rt"%>
<%@ taglib uri="/CXL" prefix="CXL" %>
<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
                            cssBaseName="cssBase" 
                            imageBaseName="imageBase" 
                            dispatcherName="dispatcher" />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <!-- InstanceBegin template="/Templates/page.dwt" codeOutsideHTMLIsLocked="false" -->
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=big5">
    <!-- InstanceBeginEditable name="doctitle" -->
    <title>
    </title>
    <!-- InstanceEndEditable -->
    <link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<%--[20241030]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>    
    <!-- InstanceBeginEditable name="head" -->
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
if (restore) selObj.selectedIndex=0;
}
//-->
</script>
    <!-- InstanceEndEditable -->
  </head>
 <script src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script src="<%=htmlBase%>/CM/js/pageController.js"></script><!--頁碼-->
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<%@ page import="com.igsapp.wibc.dataobj.Context.*" %>

<%

	HttpTxContext txCxt = new HttpTxContext(session);//取出自 trx putValue 中的值
	Map outputDataMap = (Map)txCxt.getValue("outputDataMap");
	
	if(outputDataMap!=null) {		
		pageContext.setAttribute("outputDataMap",outputDataMap);
	}
%>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad='iniApp()' onResize="fix()" onScroll="fix()">
<script>
function iniApp() {
	$('btnBack').observe('click',close);

	displayMessage();
}
function stat(){
	var a = pageYOffset+window.innerHeight - document.getElementById('bar1').height - 15;
	document.getElementById('bar1').top = a;
	setTimeout('stat()',2);
}
function fix(){
	var nome=navigator.appName;
	if(nome=='Netscape'){
		stat();
	} else {
		var a = document.body.scrollTop - document.getElementById('bar1').offsetHeight + 30;
		bar1.style.top = a;
	}
}
function close(){

	if(window.isPopupWin && window.popupWinBack){
	
	   // 呼叫callback Function(若有) 並關閉
	   window.popupWinBack(); 
	
	}else if(window.parent && window.parent.popupWin){
	
	    //呼叫callback Function(若有) 並關閉
	   window.parent.popupWin.back();
	
	}else{
	    CSRUtil.linkBack();
	   // ↑↓依據需求擇一使用    
	   close();
	}

}
</script>
    <center>
      <span id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility: visible;" >
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
                    <div align="center">
                      <font size="-5">
                        ●
                      </font>
                    </div>
                  </td>
                  <td>
                    收息帳務作業
                  </td>
                  <td>
                    <div align="right">
                      畫面編號：DSC20201 
                    </div>
                  </td>
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
      </span>
      <table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td>
            　
          </td>
        </tr>
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
                          <p>
                            <img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">
                            EIR調整帳務明細查詢作業
                          </p>
                        </td>
                      </tr>
                      <tr bgcolor=#FFFFFF>
                        <td>
                          <table width="100%" border="0" cellspacing="0" cellpadding="5">
                            <tr>
                              <td>
                                <form name="form1" method="post" action="">
                                 <TABLE class=tbBox2 id=voList cellSpacing=1 

                        cellPadding=0 width="100%" border=0>

                          <TBODY><!-- Block_6_Start 資料抬頭-->

							  <TR align=center class=tbBlue>

								<TD colspan='8'>帳務資訊</TD>
								</TR>
							  <TR align=center>

								<TD class=tbBlue2 width="10%" >傳票日期</TD>

								<TD class=tbBlue3 width="15%"><cathay:calendar type="ROC" isInput="false" value="${outputDataMap.accMap.ACNT_DATE}" /></TD>

								<TD class=tbBlue2 width="10%">製票單位</TD>

								<TD class=tbBlue3 width="15%">${outputDataMap.accMap.ACNT_DIV_NO}</TD>
								<TD class=tbBlue2 width="10%">傳票序號</TD>
								<TD class=tbBlue3 width="15%">${outputDataMap.accMap.SLIP_SEQ_NO}</TD>
								<TD class=tbBlue2 width="10%">傳票組號</TD>
								<TD class=tbBlue3 width="15%">${outputDataMap.accMap.SLIP_SET_NO}</TD>
								</TR>
								<TR align=center>
								<TD class=tbBlue2 >傳票批號</TD>
								<TD class=tbBlue3 >${outputDataMap.accMap.SLIP_LOT_NO}</TD>
								<TD class=tbBlue2>帳務類別</TD>
								<TD class=tbBlue3 >${outputDataMap.accMap.ACNT_TYPE}&nbsp;<cathay:conver sys="DSC" field="ACNT_TYPE" value="${outputDataMap.accMap.ACNT_TYPE}" /></TD>
								<TD class=tbBlue2>結帳人員</TD>
								<TD class=tbBlue3 ><%-- [20241030] 難字調整 --%>
								  <span style="font-family:'EUDC'">${outputDataMap.accMap.OPR_NAME}</span>&nbsp;<cathay:calendar type="ROC" isInput="false" value="${outputDataMap.accMap.OPR_TIME}" /></TD>
								<TD class=tbBlue2>&nbsp;</TD>
								<TD class=tbBlue3 >&nbsp;</TD>
								</TR>
						</TBODY>
</table>
<TABLE class=tbBox2 id=voList cellSpacing=1 

                        cellPadding=0 width="100%" border=0>
                        <TBODY><!-- Block_6_Start 資料抬頭-->
							 <TR align=center class=tbBlue>

								<TD colspan='7'>調整明細</TD>
							 </TR>
							 <TR align=center>
								<TD class=tbBlue width="5%">序號</TD>	

								<TD class=tbBlue width="24%">會計科目</TD>
								<TD class=tbBlue width="23%">會計子目</TD>
								<TD class=tbBlue width="23%">會計細目</TD>
								<TD class=tbBlue width="8%">借貸方</TD>
								<TD class=tbBlue width="7%">件數</TD>
								<TD class=tbBlue width="10%">金額</TD>
							</TR>
							<c:forEach var="boList" items="${outputDataMap.boList1}" varStatus="boListStatus">
								<cathay:even><c:set var="rowStyle" value="tbYellow2"/></cathay:even>
								<cathay:odd><c:set var="rowStyle" value="tbBlue3"/></cathay:odd>
								<!-- 資料開始 -->
								<%--[20241030]chrome跑版 移除display block --%>
								<TR class="<c:out value='${rowStyle}'/>">
									<td align="center">${boListStatus.count}</td>
									<td align="left">${boList.ACNT_CODE}&nbsp;${boList.ACNT_NAME}</td>
									<td align="left">${boList.SUB_ACNT_CODE}&nbsp;${boList.SUB_ACNT_NAME}</td>
									<td align="left">${boList.DTL_ACNT_CODE}&nbsp;${boList.DTL_ACNT_NAME}</td>
									<td align="center">
										<c:if test="${boList.DB_CR eq 'DR'}">
											<c:out value="借方"/>
										</c:if>
										<c:if test="${boList.DB_CR eq 'CR'}">
											<c:out value="貸方"/>
										</c:if>  
									</td>
									<td align=right>${boList.CNT}</td>
									<td align=right><fmt:formatNumber value="${boList.AMT}" pattern="#,#00"/></td>
								</TR>
							</c:forEach>
							</tbody>
							</table>
                                </form>                                
                              </td>
                            </tr>
                          </table>
						  <div align="center">
                      <input id="btnBack" name="btnBack" type="button" class="button" value="回上層">
                    
                  </div>
						  
                        </td>
                      </tr>
                    </tbody>
                  </table>
                  <div align="center">
                    <p>
                      <br>
                    </p>
                  </div>
                </td>
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
      </center>
  </body>
  <!-- InstanceEnd -->
</html>
