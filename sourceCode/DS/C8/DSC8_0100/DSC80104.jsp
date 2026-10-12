<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC80104.jsp
作者：謝博全
功能：應繳日變更記錄
完成：2012/12/24

[20230315] 修改程式  楊青峰
難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<%-- [20230315] --%>
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script> <!--alert訊息-->
<script type="text/javascript">

var DSC80104 = new DSC80104();

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', DSC80104.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


//以下為UI() public method,放在 return 中
function DSC80104(){
	
	var rtnMap; 
	
	//取值
	var LOAN_ID ='${LOAN_ID}';
	var OPTION1 = '${OPTION1}';
	var OPTION2 = '${OPTION2}';
	var APPLY_DATE ='${APPLY_DATE}';
	var CHG_KIND ='${CHG_KIND}';
	var SEQ_NO ='${SEQ_NO}';
	var INPUT_ID = '${INPUT_ID}';
	var TABLE_NM = '${TABLE_NM}';
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( '<%=dispatcher%>/DSC8_0104/' + actionName,
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
	
	//--------------------------------------------------------------------------
	// 功能按鈕
	//--------------------------------------------------------------------------	
	var buttons = {
		
		//初始時查詢
		doPrompt_query: function(event){
			
			var	map = {'INPUT_ID' : INPUT_ID, 'APPLY_DATE' : APPLY_DATE, 'OPTION1' : OPTION1 ,'TABLE_NM' : TABLE_NM};
			if(TABLE_NM == 'DTDSC070'){
				map  = {'LOAN_ID' :LOAN_ID, 'OPTION1':OPTION1, 'OPTION2': OPTION2, 'SEQ_NO': SEQ_NO ,'TABLE_NM' : TABLE_NM};
			}
			
			ajaxPost( 'query', map
				,function(resp){
					//查詢成功,載入資料					
					rtnMap = resp.rtnMap;	

					//初始頁面顯示欄位
					$$('#table1 span').each(function(ele){
						var id = ele.id;
						ele.update(rtnMap[id]);
					});
				}			
			);
		},
			
		//上一頁:執行關閉功能
		doclose : function(event){	
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
	};	 
	
	return {
	
			initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC80104', '變更作業', '收息調整變更記錄');
				
				//-----------------------------------------------------
				//以下為進入初始頁面時需要執行的動作
				//-----------------------------------------------------
				
				//註冊DOM物件 : 監聽
				$('BTN_close').observe('click',  buttons.doclose);
				
				//初始時執行查詢功能
				buttons.doPrompt_query();
				
				//初始頁面alert訊息用	
				displayMessage();
			
				PageUI.resize();
				
			}// end initApp()
	};// end return--
}

</script>
</head>
<body>
<form name='form1' id='form1'  style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px' >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2' id="table1">
	<tr>
		<td class='tbYellow' width='10%'>貸款帳號</td>
		<td class='tbYellow2' width='15%'>			
			<span id='LOAN_ID'></span>
		</td>
		<td class='tbYellow' width='10%'>期數</td>
		<td class='tbYellow2' width='15%'>
			<span id ='PAY_TERM'></span>
		</td>
		<td class='tbYellow' width='10%'>繳別</td>
		<td class='tbYellow2' width='15%'>
			<span id ='PAY_KIND'></span>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>利息調整</td>
		<td class='tbYellow2' width='15%'>			
			<span id='INTEREST'></span>
		</td>
		<td class='tbYellow' width='10%'>延滯息調整</td>
		<td class='tbYellow2' width='15%'>
			<span id ='DELAY_INT'></span>
		</td>
		<td class='tbYellow' width='10%'>違約金調整</td>
		<td class='tbYellow2' width='15%'>
			<span id ='RENEGE'></span>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>調整原因</td>
		<td class='tbYellow2' width='15%'>			
			<span id='ADJUST_REASON'></span>
		</td>
		<td class='tbYellow' width='10%'>銷帳註記</td>
		<td class='tbYellow2' width='15%'>
			<span id ='ACNT_NOTE'></span>
		</td>
		<td class='tbYellow' width='10%'>銷帳日期</td>
		<td class='tbYellow2' width='15%'>
			<span id ='ACNT_DATE'></span>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'   >輸入人員</td>
		<td class='tbYellow2' width='15%'>
			<span id ='INPUT_ID'></span><br>
			<span id ='INPUT_NM' style="font-family: 'EUDC'"></span> <%-- [20230315] --%>
		</td>
		<td class='tbYellow' width='10%'   >輸入日期</td>
		<td class='tbYellow2' width='15%'  >
			<span id='INPUT_DT'></span>
		</td>
		<td class='tbYellow' width='10%'   >輸入單位</td>
		<td class='tbYellow2' width='15%'  >
			<span id ='INPUT_DEPT'></span><br>
			<span id ='INPUT_DEPT_NM'></span>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'   >刪除人員</td>
		<td class='tbYellow2' width='15%' >			 
			<span id ='DELETE_ID'></span><br>
			<span id ='DELETE_NM'></span>
		</td>
		<td class='tbYellow' width='10%'   >刪除日期</td>
		<td class='tbYellow2' width='15%' >
			<span id='DELETE_DT'></span>
		</td>
		<td class='tbYellow' width='10%'   >刪除單位</td>
		<td class='tbYellow2' width='15%'  >
			<span id ='DELETE_DEPT'></span><br>
			<span id ='DELETE_DEPT_NM'></span>
		</td>
	</tr>	
	<tr>
		<td align ='center'  class='tbYellow2' colspan ='6'>	
			<input id='BTN_close' type='button' class='button' value='關閉視窗' /> 				
		</td>
	</tr>
</table>
</form>
</body>
</html>