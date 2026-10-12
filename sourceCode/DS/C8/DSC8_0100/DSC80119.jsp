<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC80119.jsp
作者：張憶如 
功能：清償控管變更記錄
完成：2013/9/4

[20230317]修改件
難字調整
郭曉慧
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<!--[20230317]難字css  -->
<style type="text/css">
@font-face{
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		 url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight:normal;
	font-style:normal
}
</style>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC80119().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC80119(){
		
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0119/" + actionName,
			{  
				parameters: params, 
				onSuccess:function(response){
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){	
						if(successFunction){
							successFunction(resp);
						}
					}else{
						if(errorFunction){
							errorFunction(resp);
						}
					}
				}			
			}
		);
	}	
	
	var actions = {		
		//初始查詢		
		doQuery : function(){
			//發送ajax
			ajaxPost( 'query', {LOAN_ID : "${LOAN_ID}", APPLY_DATE: "${APPLY_DATE}", CHG_KIND: $F('CHG_KIND'), SEQ_NO: "${SEQ_NO}"},
				function(resp){	
					var rtnMap = resp.rtnMap || [];
					$$('#table_A span').each(function(ele){
						ele.update(rtnMap[ele.id]||'');
					})
				}
			);				
		},
		doClose : function (){
			if(window.isPopupWin && window.popupWinBack){
			   // 呼叫callback Function(若有) 並關閉
			   window.popupWinBack(); 
			}else if(window.parent && window.parent.popupWin){
				//呼叫callback Function(若有) 並關閉
			   window.parent.popupWin.back();
			}else{
				CSRUtil.linkBack();
			}
		}
	}
	
	
	return{
		initApp:function(){	
			PageUI.createPage( "DSC80119" , "變更作業" , "清償控管變更記錄");
			PageUI.loadin(['form', 'table_A'], 1);
			
			actions.doQuery();
			
			$('btn_close').observe('click', actions.doClose);
			displayMessage();
			PageUI.resize();
			
		}//end init()--
	};//end return--	
}//end DSC80119
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A"width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<input id = "CHG_KIND" name = "CHG_KIND" value = "${CHG_KIND}" type="hidden"/>
			<input id = "OPTION1" name = "OPTION1" value = "${OPTION1}" type="hidden"/>
			<input id = "OPTION2" name = "OPTION2" value = "${OPTION2}" type="hidden"/>
			<input id = "TABLE_NM" name = "TABLE_NM" value = "${TABLE_NM}" type="hidden"/>
			<tr>	
				<td class="tbYellow" width="16%">貸款帳號：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "LOAN_ID" name = "LOAN_ID" value = "${LOAN_ID}"></span>
				</td>
				<td class="tbYellow" width="16%">變更日期：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "APPLY_DATE" name = "APPLY_DATE" value = "${APPLY_DATE}"></span>
				</td>
				<td class="tbYellow" width="16%">序號：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "SEQ_NO" name = "SEQ_NO" value = "${SEQ_NO}"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">&nbsp</td>
			</tr>
			<!--[20230317]理由/人員姓名加難字style  -->
			<tr>	
				<td class="tbYellow">原清償控管：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_LIMIT1"></span>
				</td>
				<td class="tbYellow">新清償控管：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_LIMIT2"></span>
				</td>
				<td class="tbYellow">輸入理由：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_REASON" style="font-family:'EUDC'"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">&nbsp</td>
			</tr>
			<tr>	
				<td class="tbYellow">輸入人員：</td>			
				<td class="tbYellow2">
					<span id = "INPUT_NM" style="font-family:'EUDC'"></span>
				</td>
				<td class="tbYellow">輸入日期：</td>			
				<td class="tbYellow2">
					<span id = "INPUT_DATE"></span>
				</td>
				<td class="tbYellow">輸入單位：</td>			
				<td class="tbYellow2">
					<span id = "INPUT_DEPT"></span><br>
					<span id = "INPUT_DEPT_NM"></span>
				</td>
			</tr>
			<tr>
				<td class = "tbYellow2" colspan = "6" align="center">
					<input id = "btn_close" class = "button" type = "button" value="關閉視窗"/>
				</td>
			</tr>
		</table>
	</form>
</body>
</html>