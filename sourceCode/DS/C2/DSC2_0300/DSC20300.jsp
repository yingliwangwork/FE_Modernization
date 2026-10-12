<%@ page language="java" contentType="text/html; charset=BIG5"%>

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
<!-- 使用taglib 必需引用的宣告 END -->
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<!DOCTYPE HTML PUBLIC "-//W3C//Dtd HTML 4.01 Transitional//EN">
<html>
  <!-- InstanceBegin template="/Templates/page.dwt" codeOutsideHTMLIsLocked="false" -->
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=big5">
    <!-- InstanceBeginEditable name="doctitle" -->
    <title>
    </title>
    <!-- InstanceEndEditable -->
    <link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
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

<script src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script src="<%=htmlBase%>/CM/js/validation.js"></script>
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script src="<%=htmlBase%>/CM/js/pageController.js"></script><!--頁碼-->
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad='iniApp()' onResize="fix()" onScroll="fix()">
<script>
function stat(){
	var a = pageYOffset+window.innerHeight-document.getElementById('bar1').height-15;
	document.getElementById('bar1').top = a;
	setTimeout('stat()',2);
}
function fix(){
	nome=navigator.appName
	if(nome=='Netscape'){
		stat()
	} else {
		var a = document.body.scrollTop - document.getElementById('bar1').offsetHeight + 30;
		bar1.style.top = a
	}
}

function iniApp() {
	  //顯示執行結果
	  displayMessage();
}

function doQuery(btn) {
	document.form1.action="<%=dispatcher%>/DSC2_0300/query";
	submitOnce(btn);
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
                      畫面編號：DSC20300 
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
                           擔保放款對帳查詢作業
                          </p>
                        </td>
                      </tr>
                      <tr bgcolor=#FFFFFF>
                        <td>
                          <table width="100%" border="0" cellspacing="0" cellpadding="5">
                            <tr>
                              <td>
                                <form name="form1" method="post" action="">
                                  <table width=100% border=0 align=center cellpadding="0" cellspacing="1" class="tbBox2">
                                    <tbody>
										<tr>
                							<td class="tbYellow"  width="20%" align="center">結帳日期</td>
                                            <td class="tbYellow2"  width="20%" align="left">&nbsp;&nbsp;
	                                        	<input type='text' name='ACNT_DATE' value='${ACNT_DATE}' maxlength='7' size = '10'/>
											</td>
											<td class="tbYellow"  width="20%" align="center">科目</td>
                                            <td class="tbYellow2"  width="20%" align="left">&nbsp;&nbsp;
	                                            <input type='text' name='ACNT_CODE' value='${ACNT_CODE}' maxlength='7' size = '10'/>
                                            </td>
                							<td class="tbYellow2"  align ="center"><input name="btnQuery" type="button" class="button" value="查詢" onClick="doQuery(this)"></td>
                						</tr>                                   
                                    </tbody>
                                  </table>
								  <table class=tbBox2 id=voList cellSpacing=1 cellPadding=0 width="100%" border=0>
                          			<tbody><!-- Block_6_Start 資料抬頭-->
							 			<tr align=middle>
											<td class=tbBlue  colspan='4'>會計帳</td>	
											<td class=tbBlue colspan='3'>電腦帳</td>
											<td class=tbBlue width="8%" rowspan='2'>差額</td>
											<td class=tbBlue width="8%" rowspan='2'>備註</td>
										</tr>
										<tr>
											<td class=tbBlue align=middle width="13%">科目</td>	
											<td class=tbBlue align=middle width="13%">子目</td>
											<td class=tbBlue align=middle width="18%">細目</td>
											<td class=tbBlue align=middle width="10%">餘額</td>
											<td class=tbBlue align=middle width="10%">餘額</td>
											<td class=tbBlue align=middle width="10%">EIR調整</td>
											<td class=tbBlue align=middle width="10%">合計餘額</td>
										</tr>
										<c:forEach items="${outputDataMap.outputDataList}" var="output" varStatus="status">
					 						<c:choose>
					 							<c:when test="${output.IS_DATA eq 'Y'}">
					 								<tr <c:if test="${status.index%2==0}">class="tbBlue3"</c:if> class="tbYellow2">
					 									<td align=middle>${output.ACNT_CODE}<br>${output.ACNT_NAME}</td>
						 								<td align=middle>${output.SUB_ACNT_CODE}<br>${output.SUB_ACNT_NAME}</td>
						 								<td align=middle>${output.DTL_ACNT_CODE}<br>${output.DTL_ACNT_NAME}</td>
						 								<td align=right><cathay:formatNumber type="number"  value="${output.ACC_BAL_AMT}" pattern="#,###"/></td>
						 								<td align=right><cathay:formatNumber type="number"  value="${output.LOAN_AMT}" pattern="#,###"/></td>
						 								<td align=right><cathay:formatNumber type="number"  value="${output.EIR_AMT}" pattern="#,###"/></td>
						 								<td align=right><cathay:formatNumber type="number"  value="${output.AMT}" pattern="#,###"/></td>
						 								<td align=right><cathay:formatNumber type="number"  value="${output.DIFF}" pattern="#,###"/></td>
						 								<td align=right>&nbsp;</td>
						 							</tr>
					 							</c:when>
					 							<c:when test="${output.IS_DATA eq 'N'}">
					 								<tr <c:if test="${output.SUM_DIFF ne '0.00'}">class="textRed"</c:if>>
					 									<td class=tbYellow align=middle colspan='3'>合計</td>	
														<td class=tbYellow align=right><cathay:formatNumber type="number"  value="${output.SUM_ACC_BAL_AMT}" pattern="#,###"/></td>
														<td class=tbYellow align=right><cathay:formatNumber type="number"  value="${output.SUM_LOAN_AMT}" pattern="#,###"/></td>
														<td class=tbYellow align=right><cathay:formatNumber type="number"  value="${output.SUM_EIR_AMT}" pattern="#,###"/></td>
														<td class=tbYellow align=right><cathay:formatNumber type="number"  value="${output.SUM_AMT}" pattern="#,###"/></td>
														<td class=tbYellow align=right><cathay:formatNumber type="number"  value="${output.SUM_DIFF}" pattern="#,###"/></td>
														<td class=tbYellow align=middle><c:if test="${output.SUM_DIFF ne '0.00'}">異常</c:if></td>
													</tr>
					 							</c:when>
					 						</c:choose>
										</c:forEach>
							</tbody>
							</table>
                                </form>                                
                              </td>
                            </tr>
                          </table>
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
