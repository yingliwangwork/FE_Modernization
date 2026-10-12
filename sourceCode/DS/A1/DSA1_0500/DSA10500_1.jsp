<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>

<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var validator;

function initApp(){
	validator = new Validator();
	new UI().init();
}

function UI(){
	return {
		init:function() {
			displayMessage();
			
			//--------- 按鈕 ----------
			// 確認
			$("btn_confirm").observe('click',function(event){
				buttons.doBack("1");
			});
			
			// 關閉
			$("btn_close").observe('click',function(event){
				buttons.doBack("2");
			});
			
			//--------- 輸入欄位去空白 ----------
			$w('RETURN_REASON').each( 
				function(key){
					$(key).observe('blur', function(event){
						formatInput.text(key);
					});
				}
			);
			
			$('RETURN_REASON').cols = ('${width}') ? '${width}'/8 : $('RETURN_REASON').cols;
			$('RETURN_REASON').rows = ('${height}') ? '${height}'/30 : $('RETURN_REASON').rows;
		}
	};
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 回上一頁
	doBack:function(type){
		if(type=="1"){
			if(!validates.checkInput()){
				return;
			}
			
			if(window['callbackHandler']){
				callbackHandler($('RETURN_REASON').value);
				close();
			}else if(parent.popupWin != null && parent.popupWin.callbackHandler){
				parent.popupWin.callbackHandler($('RETURN_REASON').value);
				close();
			}
		}else{
			if(window['callbackHandler']){
				close();
			}else if(parent.popupWin != null && parent.popupWin.callbackHandler){
				close();
			}
		}
	}
};

//--------------------------------------------------------------------------
// 檢核
//--------------------------------------------------------------------------
var keyMap = {
	RETURN_REASON:"退件原因"
};
var comment_Limit = {
	RETURN_REASON:300
};
var validates = {
	// 畫面欄位
	checkInput:function(type){
		$$('#form1 input[type="text"]').each( 
			function(text){ 
				text.style.backgroundColor = '';
			}
		);
		
		validator.clear();

		// 檢核字數-修正原因說明
		var twoBytesRegExp = /[^\x00-\xff]/g;
		
		var dataKey = Object.keys(keyMap);
		dataKey.each(
			function(key){
				var value = $(key).value;
				var len = comment_Limit[key];
				if(key == "RETURN_REASON" && value == ""){
					validator.define(key, '', keyMap[key] + '不可空白', validates.returnFalse);
				}else if(!validateStringBytes(value, 0, len)){
					var msg = keyMap[key] + "的字數(中文佔2個字)為" + $(key).value.replace(twoBytesRegExp, "rr").length + "，已經超過上限(" + comment_Limit[key] + ")";
					validator.define(key, '', msg, validates.returnFalse);
				}
			}
		);
		
		return validator.validate();
	},
	// 回傳false
	returnFalse:function(){
		return false;
	}
};

//--------------------------------------------------------------------------
// 格式化
//--------------------------------------------------------------------------
var formatInput = {
	// 一般輸入
	text:function(key_Value, isKey, defaultVaule){
		if(isKey == null || isKey == undefined){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!$(key_Value)){
			isKey = false;
		}
		
		if(!defaultVaule && defaultVaule != "0"){
			defaultVaule = "";
		}
		
		// 取得value
		var value;
		if(isKey){
			value = $(key_Value).value;
		}else{
			value = key_Value;
		}
		
		// 處理value
		if(value || !isNaN(parseInt(value))){
			value = value;
		}else {
			value = defaultVaule;
		}
		
		// 設定或回傳value
		if(isKey){
			$(key_Value).value = value.trim();
		}else{
			return value.trim();
		}
	}
};

//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<center>
<table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
	<tr> 
		<td class="tbBox2">
			<img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">
			退件原因
		</td>
	</tr>
	<tr bgcolor=#FFFFFF>
		<td>
		<form name="form1" id="form1" method="post" action="">
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td align="center">
						<textarea id="RETURN_REASON" name="RETURN_REASON" wrap="hard" cols="80" rows="10"></textarea>
					</td>
				</tr>
			</table>
			<div align="center">
				<input id="btn_confirm" name="btn_confirm" type="button" class="button" value="確認">
				<input id="btn_close" name="btn_close" type="button" class="button" value="關閉">
			</div>
		</form>
		</td>
	</tr>
</table>
</center>
</body>
</html>