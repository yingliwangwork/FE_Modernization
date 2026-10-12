<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSD41601.jsp
功能：清償文件服中確認
作者：周宏哲
完成：2021-07-16

[20240328]
難字調整
高強禾
-->	
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible"> 

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
 
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<%-- [20240328] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type='text/javascript'>
Event.observe(window, 'load', new DSD41601().initApp);

function DSD41601() {
	//按鈕授權
	function buttonAuth(){
		var authButtons = {
			B0028: 'btn_confirm',//確認
			B0008: 'btn_reject'//退回資管
		};		

		<dz:grantButtons FUNC_ID="DSD41601"/>
	};
	
	function doCancel(){
		if(window.isPopupWin && window.popupWinBack){
			window.popupWinBack();
		}else if(window.parent && window.parent.popupWin){
			window.parent.popupWin.back();
		}else{
			CSRUtil.linkBack(); 
		}	
	}

	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1601/');
	var REFER_ID = '${REFER_ID}';
	var APPLY_DATE = '${APPLY_DATE}';
	var SIGN_STATUS = '${SIGN_STATUS}';
	var CASE_STATUS = '${CASE_STATUS}';
	
	var buttons = {		
		doConfirm : function(){		
			
			ajaxRequest.post( 'confirm' , { REFER_ID : REFER_ID,  APPLY_DATE : APPLY_DATE, CASE_STATUS:CASE_STATUS, SIGN_STATUS:SIGN_STATUS},
				function(resp){	
				 doCancel();				
				});
			
			
		},
		doReject : function(){	
			
			var LP_JSON = {
					action : '${dispatcher}/DSD4_1602/prompt',
					REFER_ID : REFER_ID,
					APPLY_DATE : APPLY_DATE,
					CASE_STATUS : CASE_STATUS,
					SIGN_STATUS : SIGN_STATUS
				};
				CSRUtil.linkTo(LP_JSON, 'form1');
												
		}
	};
   return{    
	    initApp : function(){ 
	    	<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>
		    PageUI.createPageWithAllBodySubElement("DSD41601","清償作業","清償文件服中確認");
		    
		    $('btn_confirm').observe('click', buttons.doConfirm);
		    $('btn_reject').observe('click', buttons.doReject);

			buttonAuth();
		    displayMessage();
	   	}
   };
}

</script>
</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<form name="form1" id="form1" method="post">

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>							
		<td class="tbYellow" align="center" width="10%" colspan="4">
			<font>清償文件內容</font>
		</td>
	</tr>
	<%--[20230627]新增顯示欄位 --%>
	<tr>
		<td class="tbYellow" align="center" width="25%">
			<font>原貸帳號：</font>
		</td>
		<td class="tbYellow2" width="25%">
			<font>${REFER_ID}</font>
		</td>
		<td class="tbYellow" align="center" width="25%">
			<font>借款人姓名：</font>
		</td>
		<%-- [20240328] 難字調整：借款人姓名，除CSS外，還將<font>改為<span>，font無法正常顯示難字，原因未知 --%>
		<td class="tbYellow2" width="25%" style="font-family:'EUDC'">
			<span>${BORROW_NAME}</span>
		</td>
	</tr>
	<tr>							
		<td class="tbYellow2" align="center" width="10%" colspan="4">
			<button type="button" class="button" id="btn_confirm">確認</button>
			<button type="button" class="button" id="btn_reject">文件不合退回資管科</button>
		</td>			
	</tr>
</table>

<table id='grid' class='tableGrid' width="100%">
	<thead style="background : #99CCFF">	
		<tr>							
			<th>序號</th>
			<th>目標欄位說明</th>
			<th>來源欄位說明</th>
		</tr>
	</thead>	
	<c:if test="${!empty returnMap}">
		<tbody style="text-align:left">
			<tr>
				<td class="tbYellow">1.</td>
				<td class="tbYellow2">一、抵押權塗銷同意書</td>
				<td class="tbYellow">${returnMap.SIGN_TXT1}份</td>
			</tr>
			<tr>
				<td class="tbYellow">2.</td>
				<td class="tbYellow2">二、抵押權設定契約書及他項權利證明書</td>
				<td class="tbYellow">${returnMap.SIGN_TXT2}份</td>
			</tr>
			<tr>
				<td class="tbYellow">3.</td>
				<td class="tbYellow2">三、證明書(清償證明補發)</td>
				<td class="tbYellow">${returnMap.SIGN_TXT3}份</td>
			</tr>
			<tr>
				<td class="tbYellow">4.</td>
				<td class="tbYellow2">四、火險單</td>
				<td class="tbYellow">${returnMap.SIGN_TXT4}份</td>
			</tr>
			<tr>
				<td class="tbYellow">5.</td>
				<td class="tbYellow2">五、應退暫收款</br></br>【領取方式:(1)現金退款:限借款人臨櫃國泰人壽分公司(2)匯款退款:需檢附相關文件轉送承辦單位】</td>
				<td class="tbYellow">${returnMap.SIGN_TXT5}元</td>
			</tr>
			<tr>
				<td class="tbYellow">6.</td>
				<td class="tbYellow2">六、其他</td>
				<td class="tbYellow">${returnMap.SIGN_TXTOT}</td>
			</tr>
		</tbody>
	</c:if>
</table>


</form>
</body>
</html>