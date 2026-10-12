<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC8_0109.jsp
作者：張恆勖
功能：暫收原因變更
完成：2013/02/26

[20230316] 修改程式  楊青峰
難字調整
[20231017]問題單號:20230912-0073暫收變更債務人選單調整 BY余凱鈞
變更債務人有留變更紀錄，但未留下債務人變更前後資訊，一併調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<%-- [20230316] --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
	         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	      font-weight: normal;
	      font-style: normal
	}
</style>

<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<!--alert訊息-->
<script type="text/javascript">

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC80109().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC80109(){
	
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0109/" + actionName,
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
		});
	}
	
	var actions = {
		
		//--------------------------------------------------------------------------
		// 查詢
		//--------------------------------------------------------------------------
		doQuery: function(event){
					
			ajaxPost('query', {	LOAN_ID 		: '${LOAN_ID}', 
								APPLY_DATE	: '${APPLY_DATE}', 
								CHG_KIND	: '${CHG_KIND}', 
								SEQ_NO		: '${SEQ_NO}',
								OPTION1		: '${OPTION1}'}
				,function(resp){
				
					//載入資料					
					var rtnMap = resp.rtnMap;	
					
					$w('LOAN_ID BALC_NO BALC_REASON1 BALC_MEMO1 BALC_REASON2 BALC_MEMO2 INPUT_ID'+
						' INPUT_NM INPUT_DEPT INPUT_DEPT_NM INPUT_DATE REAL_PAYDT1 REAL_PAYDT2'+
						' DEBTOR_ID1 DEBTOR_NAME1 DEBTOR_ID2 DEBTOR_NAME2').each(
						function(id) {
							$(id).innerHTML = rtnMap[id] || '';
						}
					);
					$('LOAN_ID1').innerHTML = rtnMap['LOAN_ID'] || '';
					$('LOAN_ID2').innerHTML = rtnMap['LOAN_ID2'] || '';									
				}			
			);
		},
		//--------------------------------------------------------------------------
		// 上一頁:執行關閉功能
		//--------------------------------------------------------------------------
		doBack : function(event){	
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
    };
	
	return {
	
		initApp : function() {
			
		PageUI.createPageWithAllBodySubElement('DSC80109', '收息資料更新', '暫收原因變更查詢');
						
		//初始時執行查詢功能
		actions.doQuery();
		
		//註冊DOM物件 : 監聽	
		$('BTN_BACK').observe('click',actions.doBack);	
		
		PageUI.resize();
		displayMessage();	
		
		}// end initApp()
	};// end return--
}

</script>
</head>
<body>
<form name='form1' id='form1'
	style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>

<table width='100%' border='0' cellpadding='0' cellspacing='1'
	class='tbBox2' id="table1">
	<tr>
		<td class='tbYellow' >貸款帳號</td>
		<td class='tbYellow2'  colspan='3'>
			<span id='LOAN_ID'></span>
		</td>
		<td class='tbYellow'>暫應收編號</td>
		<td class='tbYellow2'  colspan='3'>
			<span id='BALC_NO'></span>
		</td>
	</tr>
	<tr>
		<td class='tbYellow0' colspan='8'>原資料</td>
		
	</tr>
	<tr>
		<td class='tbYellow' width="10%">舊貸款帳號</td>
		<td class='tbYellow2' width="12%">
			<span id='LOAN_ID1'></span>
		</td>
		<td class='tbYellow' width="12%">舊暫應收原因</td>
		<td class='tbYellow2' width="12%">
			<span id='BALC_REASON1' style="font-family: 'EUDC'"></span> <%-- [20230316] --%>
		</td>
		<td class='tbYellow' width="12%">舊暫應收備註</td>
		<td class='tbYellow2' width="20%">
			<span id='BALC_MEMO1' style="font-family: 'EUDC'"></span> <%-- [20230316] --%>
		</td>
		<td class='tbYellow' width="10%">舊應繳日</td>
		<td class='tbYellow2' width="12%">
			<span id='REAL_PAYDT1'></span>
		</td>
	</tr>
	<tr>
		<td class='tbYellow'>舊債務人ID</td>
		<td class='tbYellow2'>
			<span id='DEBTOR_ID1'></span>
		</td>
		<td class='tbYellow'>舊債務人姓名</td>
		<td class='tbYellow2'>
			<span id='DEBTOR_NAME1' style="font-family: 'EUDC'"></span> 
		</td>
		<td class='tbYellow'></td>
		<td class='tbYellow2'></td>
		<td class='tbYellow'></td>
		<td class='tbYellow2'></td>
	</tr>		
	<tr>
		<td class='tbYellow0' colspan='8'>新資料</td>
		
	</tr>
	<tr>
		<td class='tbYellow'>新貸款帳號</td>
		<td class='tbYellow2'>
			<span id='LOAN_ID2'></span>
		</td>
		<td class='tbYellow'>新暫應收原因</td>
		<td class='tbYellow2'>
			<span id='BALC_REASON2' style="font-family: 'EUDC'"></span> <%-- [20230316] --%>
		</td>
		<td class='tbYellow'>新暫應收備註</td>
		<td class='tbYellow2'>
			<span id='BALC_MEMO2' style="font-family: 'EUDC'"></span> <%-- [20230316] --%>
		</td>
		<td class='tbYellow'>新應繳日</td>
		<td class='tbYellow2'>
			<span id='REAL_PAYDT2'></span>
		</td>
	</tr>
	<tr>
		<td class='tbYellow'>新債務人ID</td>
		<td class='tbYellow2'>
			<span id='DEBTOR_ID2'></span>
		</td>
		<td class='tbYellow'>新債務人姓名</td>
		<td class='tbYellow2'>
			<span id='DEBTOR_NAME2' style="font-family: 'EUDC'"></span> 
		</td>
		<td class='tbYellow'></td>
		<td class='tbYellow2'></td>
		<td class='tbYellow'></td>
		<td class='tbYellow2'></td>
	</tr>	
	<tr>
		<td class='tbYellow0' colspan='8'>作業單位</td>
		
	</tr>	
	<tr>
		<td class='tbYellow'>作業人員</td>
		<td class='tbYellow2' colspan='3'>
			<span id='INPUT_ID'></span>
			<span id='INPUT_NM' style="font-family: 'EUDC'"></span> <%-- [20230316] --%>
			<BR>		
			<span id='INPUT_DEPT'></span>
			<span id='INPUT_DEPT_NM' style="font-family: 'EUDC'"></span> <%-- [20230316] --%>
		</td>
		<td class='tbYellow'>輸入日期</td>
		<td class='tbYellow2' colspan='3'>
			<span id='INPUT_DATE'></span>
		</td>
	</tr>
	<tr>
		<td align='center' class='tbYellow2' colspan='8'><input
			id='BTN_BACK' type='button' class='button' value='關閉視窗' /></td>
	</tr>
</table>
</form>
</body>
</html>