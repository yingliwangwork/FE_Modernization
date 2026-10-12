<%@ page contentType="text/html; charset=Big5" %>
<%@ taglib uri="/CXL" prefix="CXL" %>

<CXL:csCommon trace="false" htmlBaseName="htmlBase"
                            cssBaseName="cssBase"
                            imageBaseName="imageBase"
                            dispatcherName="dispatcher" />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_jumpMenu(targ,selObj,restore){
  eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
  if (restore) selObj.selectedIndex=0;
}
function stat(){
var a = pageYOffset+window.innerHeight-document.getElementById('bar1').height-15
document.getElementById('bar1').top = a
setTimeout('stat()',2)
}
function fix(){
nome=navigator.appName
if(nome=='Netscape'){
stat()
}
else{
var a=document.body.scrollTop-document.getElementById('bar1').offsetHeight+10
document.getElementById('bar1').style.top = a
}}

function showHide(){
	var f = parent['mainFrame'];
	var bpmF = parent['bpmMemoFrame'];
	if(f.frameElement.height == '65%'){
		f.frameElement.height = '85%';
		bpmF.frameElement.height = '10%';
	}else if(f.frameElement.height == '85%'){
		f.frameElement.height = '65%';
		bpmF.frameElement.height = '30%';
	}
}
//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onResize="fix()" onScroll="fix()">
<center>
<span id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility: visible;" >
<table width="100%" height="10" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
    <td valign="top" bgcolor="#F0FBC6"> <table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
        <tr>
          <td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
        </tr>
      </table>
      </td>
    <td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
    <td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  </tr>
</table>
</span>
<table width="100%" height="10" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td></td>
  </tr>
</table>
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
    <td width="100%" valign="top" bgcolor="#F0FBC6">
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td valign="top"> <table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
              <tbody>
                <tr>
                  <td class="tbBox2" ondblclick="showHide();"> <p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">備註輸入查詢</p>
                  </td>
                </tr>
                <tr bgcolor=#FFFFFF>
                  <td><table width="100%" border="0" cellspacing="0" cellpadding="5">
                      <tr>
                        <td> <form name="form1" method="post" action="">
                          <table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
                            <tr>
                              <td width="15%" class="tbYellow">備註</td>
                              <td width="30%" class="tbYellow2" ><input type="text" name="POLICY_NO3" class="textBox2"  size="40" maxlength="38" /></td>
                              <td width="10%" class="tbYellow">通知對象</td>
                              <td class="tbYellow2" >
								<input name="radiobutton" type="checkbox" value="radiobutton">服務中心
								<input name="radiobutton" type="checkbox" value="radiobutton">作業中心
								<input name="radiobutton" type="checkbox" value="radiobutton">行政中心
							  </td>
                              <td width="10%" class="tbYellow2" ><span class="style4">
                                <input name="QUERY332" type="button" class="button" value="輸入"  onClick = "doQuery()">
                              </span></td>
                            </tr>
                          </table>
                          <table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
                            <tr class="tbBlue2">
                              <td align="center">通知對象</td>
                              <td align="center">備註</td>
                              <td align="center">輸入單位</td>
                              <td align="center">輸入人員</td>
                              <td width="30%" align="center">輸入時間</td>
                            </tr>
                            <tr class="tbBlue3">
                              <td align="center">&nbsp;</td>
                              <td align="center">&nbsp;</td>
                              <td align="center">&nbsp;</td>
                              <td align="center">&nbsp;</td>
                              <td align="center" nowrap>&nbsp;</td>
                            </tr>
                            <tr class="tbYellow2">
                              <td align="center">&nbsp;</td>
                              <td align="center">&nbsp;</td>
                              <td align="center">&nbsp;</td>
                              <td align="center">&nbsp;</td>
                              <td align="center">&nbsp;</td>
                            </tr>
                            <tr class="tbYellow2">
                              <td colspan="5" align="center" class="tbBlue2"><table width="100%" border="0" align="center" cellpadding="0" cellspacing="1">
                                  <tr>
                                    <td width="30%"><div align="center"> </div></td>
                                    <td width="40%"><div align="center"></div></td>
                                    <td width="10%"><div align="right"><span class="text10"><img src="<%=imageBase%>/CM/previous2.gif" width="20" height="15"><img src="<%=imageBase%>/CM/previous1.gif" width="20" height="15"><img src="<%=imageBase%>/CM/next1.gif" width="20" height="15"><img src="<%=imageBase%>/CM/next2.gif" width="20" height="15"></span></div></td>
                                    <td width="20%" align="right"><span class="text10">第1頁/共3頁　共10件</span></td>
                                  </tr>
                              </table></td>
                            </tr>
                          </table>

                            </form>

                        </td>
                      </tr>
                    </table></td>
                </tr>
              </tbody>
            </table>
            <div align="center">
              <p> <br>
              </p>
            </div></td>
        </tr>
      </table>
      </td>
    <td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
    <td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  </tr>
</table>
</body>
</html>