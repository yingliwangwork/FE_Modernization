<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC83100.jsp
作者：吳學建 
功能：特殊件控管變更記錄
完成：2014/12/28

[20230324] 難字修改
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<style type="text/css"><%-- [20230324]難字修改 --%>
	@font-face{
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
			url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		font-weight:normal;
		font-style:normal
	}	
</style>
<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC83100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC83100(){
    var rtnMap = [];
	var rtnMapA = [];
	var rtnMapB = [];
	var rtnMapC = [];	
	var rtnMapE = [];
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_3100/" + actionName,
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
			ajaxPost( 'query', {LOAN_ID : "${LOAN_ID}", CONTROL_TYPE: "${CONTROL_TYPE}", CONTROL_SOURCE: "${CONTROL_SOURCE}", BORROW_NAME: "${BORROW_NAME}"},
				function(resp){	
				    
				    rtnMap = resp.rtnMap;
				    if(rtnMap.rtnMapA){
				        $('table_A').style.display='block';
						rtnMapA = rtnMap.rtnMapA || [];
						$$('#table_A span').each(function(ele){
						   
							ele.update(rtnMapA[ele.id]||'');
						})
					}else{
					
						$('table_A').style.display='none';
					}
					
					if(rtnMap.rtnMapB){
					    $('table_B').style.display='block';
						rtnMapB = rtnMap.rtnMapB || [];
						$$('#table_B span').each(function(ele){
						   
							ele.update(rtnMapB[ele.id]||'');
						})
					}else{
					
						$('table_B').style.display='none';
					}
					if(rtnMap.rtnMapC){
					    
					    $('table_C').style.display='block';
						rtnMapC = rtnMap.rtnMapC || [];
						$$('#table_C span').each(function(ele){
						   
							ele.update(rtnMapC[ele.id]||'');
						})
					}else{
					  $('table_C').style.display='none';
					}
					if(rtnMap.rtnMapE){
					    
					    $('table_E').style.display='block';
						rtnMapE = rtnMap.rtnMapE || [];
						$$('#table_E span').each(function(ele){
						   
							ele.update(rtnMapE[ele.id]||'');
						})
					}else{
					  $('table_E').style.display='none';
					}
					
				}
			);				
		},
		doClose : function (){
			if(window.isPopupWin && window.popupWinBack){
			   // 呼叫callback Function(若有) 並關閉
			   window.popupWinBack(rtnMap); 
			}else if(window.parent && window.parent.popupWin){
				//呼叫callback Function(若有) 並關閉
			   window.parent.popupWin.back(rtnMap);
			}else{
				CSRUtil.linkBack();
			}
		}
	}
	
	
	return{
		initApp:function(){	
			PageUI.createPage( "DSC83100" , "變更作業" , "特殊件控管變更紀錄");
			PageUI.loadin(['form', 'table_A','table_B','table_C','table_E','table_D'], 1);
			//PageUI.loadin(['form', 'table_B'], 1);
			//PageUI.loadin(['form', 'table_C'], 1);
			
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
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style='display: none' >	
			
			<tr>	
				<td class="tbYellow" width="16%">身份證號：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "LOAN_ID" name = "LOAN_ID" value = "${LOAN_ID}"></span>
				</td>
				<td class="tbYellow" width="16%">變更日期：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "UPDATE_DATE" name = "UPDATE_DATE" ></span>
				</td>
				<td class="tbYellow" width="16%">序號：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "SEQ_NO" name = "SEQ_NO" ></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">&nbsp</td>
			</tr>
			<tr>	
				<td class="tbYellow">原控管選項：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_LIMIT1"></span>
				</td>
				<td class="tbYellow">新控管選項：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_LIMIT2"></span>
				</td>
				<td class="tbYellow">控管原因：</td>			
				<td class="tbYellow2">
					<span id = "CONTROL_REASON" style="font-family:'EUDC'"></span><%-- [20230324]難字修改 --%>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">&nbsp</td>
			</tr>
			<tr>	
				<td class="tbYellow">輸入人員：</td>			
				<td class="tbYellow2">
					<span id = "INPUT_ID"></span><br>
					<span id = "INPUT_NM" style="font-family:'EUDC'"></span><%-- [20230324]難字修改 --%>
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
			
			
		</table>
		
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style='display: none' >		
			<tr>	
				<td class="tbYellow" width="16%">身份證號：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "LOAN_ID" name = "LOAN_ID" value = "${LOAN_ID}"></span>
				</td>
				<td class="tbYellow" width="16%">變更日期：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "UPDATE_DATE" name = "UPDATE_DATE" ></span>
				</td>
				<td class="tbYellow" width="16%">序號：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "SEQ_NO" name = "SEQ_NO" ></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">&nbsp</td>
			</tr>
			<tr>	
				<td class="tbYellow">原控管選項：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_LIMIT1"></span>
				</td>
				<td class="tbYellow">新控管選項：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_LIMIT2"></span>
				</td>
				<td class="tbYellow">控管原因：</td>			
				<td class="tbYellow2">
					<span id = "CONTROL_REASON" style="font-family:'EUDC'"></span><%-- [20230324]難字修改 --%>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">&nbsp</td>
			</tr>
			<tr>	
				<td class="tbYellow">輸入人員：</td>			
				<td class="tbYellow2">
					<span id = "INPUT_ID"></span><br>
					<span id = "INPUT_NM" style="font-family:'EUDC'"></span><%-- [20230324]難字修改 --%>
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
			
			
		</table>
		
		<table id="table_C" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style='display: none' >		
			<tr>	
				<td class="tbYellow" width="16%">身份證號：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "LOAN_ID" name = "LOAN_ID" value = "${LOAN_ID}"></span>
				</td>
				<td class="tbYellow" width="16%">變更日期：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "UPDATE_DATE" name = "UPDATE_DATE" ></span>
				</td>
				<td class="tbYellow" width="16%">序號：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "SEQ_NO" name = "SEQ_NO" ></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">&nbsp</td>
			</tr>
			<tr>	
				<td class="tbYellow">原控管選項：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_LIMIT1"></span>
				</td>
				<td class="tbYellow">新控管選項：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_LIMIT2"></span>
				</td>
				<td class="tbYellow">控管原因：</td>			
				<td class="tbYellow2">
					<span id = "CONTROL_REASON" style="font-family:'EUDC'"></span><%-- [20230324]難字修改 --%>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">&nbsp</td>
			</tr>
			<tr>	
				<td class="tbYellow">輸入人員：</td>			
				<td class="tbYellow2">
					<span id = "INPUT_ID"></span><br>
					<span id = "INPUT_NM" style="font-family:'EUDC'"></span><%-- [20230324]難字修改 --%>
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
		</table>
		<table id="table_E" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style='display: none' >		
			<tr>	
				<td class="tbYellow" width="16%">身份證號：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "LOAN_ID" name = "LOAN_ID" value = "${LOAN_ID}"></span>
				</td>
				<td class="tbYellow" width="16%">變更日期：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "UPDATE_DATE" name = "UPDATE_DATE" ></span>
				</td>
				<td class="tbYellow" width="16%">序號：</td>			
				<td class="tbYellow2" width="16%">
					<span id = "SEQ_NO" name = "SEQ_NO" ></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">&nbsp</td>
			</tr>
			<tr>	
				<td class="tbYellow">原控管選項：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_LIMIT1"></span>
				</td>
				<td class="tbYellow">新控管選項：</td>			
				<td class="tbYellow2">
					<span id = "PAYOFF_LIMIT2"></span>
				</td>
				<td class="tbYellow">控管原因：</td>			
				<td class="tbYellow2">
					<span id = "CONTROL_REASON" style="font-family:'EUDC'"></span><%-- [20230324]難字修改 --%>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">&nbsp</td>
			</tr>
			<tr>	
				<td class="tbYellow">輸入人員：</td>			
				<td class="tbYellow2">
					<span id = "INPUT_ID"></span><br>
					<span id = "INPUT_NM" style="font-family:'EUDC'"></span><%-- [20230324]難字修改 --%>
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
		</table>
		<table id="table_D"width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >	
			<tr>
				<td class = "tbYellow2"  align="center">
					<input id = "btn_close" class = "button" type = "button" value="關閉視窗"/>
				</td>
			</tr>
			
		</table>
		
	</form>
</body>
</html>