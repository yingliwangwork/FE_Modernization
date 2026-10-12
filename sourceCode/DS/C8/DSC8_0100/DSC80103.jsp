<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC80103.jsp
作者：謝博全
功能：應繳日變更記錄
完成：2012/12/17

[2023-01-13] 新增特殊事件緩繳
1. 透過URL重入參數不同，來共用應繳日期變更和特殊事件緩繳作業畫面
2. 特殊事件緩繳作業畫面新增變更原因和延繳期期數的區塊

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

var DSC80103 = new DSC80103();

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', DSC80103.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


//以下為UI() public method,放在 return 中
function DSC80103(){
	
	//[2023-01-13] 1. 透過URL重入參數不同，來共用應繳日期變更和特殊事件緩繳作業畫面
	var PAGE_TYPE = "${PAGE_TYPE}";//1=>應繳日期變更，2=>特殊事件緩繳
	
	var rtnMap; 
	
	//取值
	var LOAN_ID ='${LOAN_ID}';
	var APPLY_DATE ='${APPLY_DATE}';
	var CHG_KIND ='${CHG_KIND}';
	var SEQ_NO ='${SEQ_NO}';
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( '<%=dispatcher%>/DSC8_0103/' + actionName,
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
			
			ajaxPost( 'query', {'LOAN_ID' :LOAN_ID, 'APPLY_DATE':APPLY_DATE, 'CHG_KIND': CHG_KIND, 'SEQ_NO': SEQ_NO , 'PAGE_TYPE': PAGE_TYPE }
				,function(resp){
					//查詢成功,載入資料					
					rtnMap = resp.rtnMap;
					//初始頁面顯示欄位
					$$('#table1 div').each(function(ele){
						var id = ele.id;
						id = id.substring(0,id.length-4);
						ele.update(rtnMap[id]||'');
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
				
				var TITLE = '';
				//[2023-01-13] 1. 透過URL重入參數不同，來共用應繳日期變更和特殊事件緩繳作業畫面
				if(PAGE_TYPE==1){//1=>應繳日期變更
					TITLE = '應繳日變更記錄';
				}else{//2=>特殊事件緩繳
					TITLE = '特殊事件緩繳記錄';
				}
				
				PageUI.createPageWithAllBodySubElement('DSC80103', '變更作業', TITLE);
				
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
			<div id='LOAN_ID_DIV'></div>
		</td>
		<td class='tbYellow' width='10%'>變更日期</td>
		<td class='tbYellow2' width='15%'>
			<div id ='APPLY_DATE_DIV'></div>
		</td>
		<td class='tbYellow' width='10%'>變更序號</td>
		<td class='tbYellow2' width='15%'>
			<div id ='SEQ_NO_DIV'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>原每月繳日</td>
		<td class='tbYellow2' width='15%'>
			<div id='DUTY_DAY1_DIV'></div>
		</td>
		
		<td class='tbYellow' width='10%'>原上次已繳日</td>
		<td class='tbYellow2' width='15%'>
			<div id ='LAST_PAYDT1_DIV'></div>
		</td>
		<td class='tbYellow' width='10%'>原下次應繳日</td>
		<td class='tbYellow2' width='15%'>
			<div id ='NEXT_PAYDT1_DIV'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>新每月繳日</td>
		<td class='tbYellow2' width='15%'>
			<div id='DUTY_DAY2_DIV'></div>
		</td>
		<td class='tbYellow' width='10%'>新上次已繳日</td>
		<td class='tbYellow2' width='15%'>
			<div id ='LAST_PAYDT2_DIV'></div>
		</td>
		<td class='tbYellow' width='10%'>新下次應繳日</td>
		<td class='tbYellow2' width='15%'>
			<div id ='NEXT_PAYDT2_DIV'></div>
		</td>
	</tr>
	
	<!--[2023-01-13] 特殊事件緩繳作業畫面的下方需有新增變更原因和延繳期期數的區塊 -->
	<c:if test="${PAGE_TYPE == '2'}">
		<tr>
			<td class='tbYellow' width='10%'>緩繳分類</td>
			<td class='tbYellow2' width='15%'>
				<div id='DELAY_TYPE_NM_DIV'></div>
			</td>
			<td class='tbYellow' width='10%'>緩繳期數</td>
			<td class='tbYellow2' width='15%'>
				<div id ='DELAY_TERM_DIV'></div>
			</td>
			<td class='tbYellow' width='10%'>緩繳繳款原因</td>
			<td class='tbYellow2' width='15%'>
				<div id ='DELAY_REASON_DIV'></div>
			</td>
		</tr>
	</c:if>
	
	<tr>
		<td class='tbYellow' width='10%'  rowspan = '2' >輸入人員</td>
		<td class='tbYellow2' width='15%' rowspan = '2'>
			<div id ='INPUT_ID_DIV'></div>
			<div id ='INPUT_NM_DIV' style="font-family: 'EUDC'"></div> <%-- [20230315] --%>
		</td>
		<td class='tbYellow' width='10%'  rowspan = '2' >輸入日期</td>
		<td class='tbYellow2' width='15%' rowspan = '2' >
			<div id='INPUT_DATE_DIV'></div>
		</td>
		<td class='tbYellow' width='10%'  rowspan = '2'  >輸入單位</td>
		<td class='tbYellow2' width='15%' rowspan = '2' >
			<div id ='INPUT_DEPT_DIV'></div>
			<div id ='INPUT_DEPT_NM_DIV'></div>
		</td>
	</tr>
	<tr>
	</tr>
	<tr>
		<td align ='center'  class='tbYellow2' colspan ='8'>	
			<input id='BTN_close' type='button' class='button' value='關閉視窗' /> 				
		</td>
	</tr>
</table>
</form>
</body>
</html>