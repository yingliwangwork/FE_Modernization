<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSD41602.jsp
功能：清償文件服中退回
作者：周宏哲
完成：2021/07/13
問題單號 :20210913172244 
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
<script type='text/javascript' src='${htmlBase}/CM/js/ui/InputUtility.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript'>
Event.observe(window, 'load', new DSD41602().initApp);

function DSD41602() {

	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1602/');
	var REFER_ID = '${REFER_ID}';
	var APPLY_DATE = '${APPLY_DATE}';
	
	//按鈕授權
	function buttonAuth(){
		var authButtons = {
			B0028: 'btn_confirm'//確認
		};		

		<dz:grantButtons FUNC_ID="DSD41602"/>
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
	
	var buttons = {		
			
		doConfirm : function(){	 
			var RETURN_ITEM = '';
			var checkbox1 = $$('input[name="checkbox1"]:checked');
			
			checkbox1.each(function(e){
				 RETURN_ITEM += e.getValue()+',';
			});		
			
			ajaxRequest.post( 'confirm' , { REFER_ID : REFER_ID,APPLY_DATE : APPLY_DATE,
				RETURN_ITEM : RETURN_ITEM.substr(0,RETURN_ITEM.length-1),RETURN_NOTE : $F('RETURN_NOTE'),
				SIGN_STATUS:'${returnMap.SIGN_STATUS}',
				CASE_STATUS:'${returnMap.CASE_STATUS}'},
				function(resp){	
			
				 alert("已退回資管科");
				 doCancel();//關閉popupwin
				  
				}
			 );				
		}
	
	};
	
    return{   
    initApp : function(){	    
	    PageUI.createPageWithAllBodySubElement("DSD41602","清償作業","清償文件服中退回");
	    InputUtility.lengthLimit.add("RETURN_NOTE", 100, true, "中文或全型算2個字，已輸入{enter}字，尚可輸入{left}字。");
	    
	    $('btn_confirm').observe('click', buttons.doConfirm);
	    
	    var RETURN_ITEM = "${returnMap.RETURN_ITEM}";
	  	var RETURN_ITEMS = RETURN_ITEM.split(',');
	  	RETURN_ITEMS.forEach(function(item, i) {
	  	 var RETURN_ITEM_ID = "cbox"+item;
	  	 document.getElementById(RETURN_ITEM_ID).checked = true;
	  	});
	  	

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
		<td style="background : #99CCFF" align="center" width="10%">
			<font >退件輸入作業</font>
		</td>
			
	</tr>
</table>

<table id='grid' class='tableGrid' width="100%" style="text-align:left">
	<tr>
		<td class="tbYellow"  rowspan="6">缺漏文件</td>
		<td><input name=checkbox1 type="checkbox" id="cbox1" value="1" class="tbYellow2"  <c:if test='${returnMap.CASE_STATUS == "05"}'>disabled</c:if>></td>
		<td class="tbYellow2">一、抵押權塗銷同意書</td>
		<td class="tbYellow2">${returnMap.SIGN_TXT1}份</td>
	</tr>
	<tr>
		<td><input name=checkbox1 type="checkbox" id="cbox2" value="2" class="tbYellow2" <c:if test='${returnMap.CASE_STATUS == "05"}'>disabled</c:if>></td>				
		<td class="tbYellow2">二、抵押權設定契約書及他項權利證明書</td>
		<td class="tbYellow2">${returnMap.SIGN_TXT2}份</td>
	</tr>
	<tr>
		<td><input name=checkbox1 type="checkbox" id="cbox3" value="3" class="tbYellow2" <c:if test='${returnMap.CASE_STATUS == "05"}'>disabled</c:if>></td>
		<td class="tbYellow2">三、證明書(清償證明補發)</td>
		<td class="tbYellow2">${returnMap.SIGN_TXT3}份</td>
	</tr>
	<tr>
	    <td><input name=checkbox1 type="checkbox" id="cbox4" value="4" class="tbYellow2" <c:if test='${returnMap.CASE_STATUS == "05"}'>disabled</c:if>></td>
		<td class="tbYellow2">四、火險單</td>
		<td class="tbYellow2">${returnMap.SIGN_TXT4}份</td>
	</tr>
	<tr>
		<td><input name=checkbox1 type="checkbox" id="cbox5" value="5" class="tbYellow2" <c:if test='${returnMap.CASE_STATUS == "05"}'>disabled</c:if>></td>
		<td class="tbYellow2">五、應退暫收款</br></br>【領取方式:(1)現金退款:限借款人臨櫃國泰人壽分公司(2)匯款退款:需檢附相關文件轉送承辦單位】</td>
		<td class="tbYellow2">${returnMap.SIGN_TXT5}份</td>
	</tr>
	<tr>
		<td><input name=checkbox1 type="checkbox" id="cbox6" value="6" class="tbYellow2" <c:if test='${returnMap.CASE_STATUS == "05"}'>disabled</c:if>></td>
		<td class="tbYellow2">六、其他</td>
		<td class="tbYellow2">${returnMap.SIGN_TXTOT}</td>
	</tr>	
	<tr>							
		<td class="tbYellow" align="center">
			退件說明
		</td>
		<td class="tbYellow2" colspan="3" align="lsfe">
			<textarea id="RETURN_NOTE" rows="5" cols="200" <c:if test='${returnMap.CASE_STATUS == "05"}'>readonly</c:if>>${returnMap.RETURN_NOTE}</textarea>	<%--問題單號 :20210913172244  調整輸入框寬度 --%>
		</td>			
	</tr>
	<tr>							
		<td class="tbYellow" align="center" width="10%" colspan="4">
			<button type="button" class="button" id="btn_confirm" <c:if test='${returnMap.CASE_STATUS == "05"}'>disabled</c:if>>確認</button>			
		</td>			
	</tr>
</table>
</form>
</body>
</html>