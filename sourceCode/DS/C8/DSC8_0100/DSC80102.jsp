<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC80102.jsp
作者：沈紋任
功能：保戶優惠變更記錄
完成：2012/12/14

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
<script type="text/javascript"
	src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<!--alert訊息-->
<script type="text/javascript">

// 產生畫面物件
var DSC80102 = new DSC80102();

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', DSC80102.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


//以下為UI() public method,放在 return 中
function DSC80102(){
	
	var rtnMap; 
	
	//取值
	var LOAN_ID ='${LOAN_ID}';
	var APPLY_DATE ='${APPLY_DATE}';
	var CHG_KIND ='${CHG_KIND}';
	var SEQ_NO ='${SEQ_NO}';
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0102/" + actionName,
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
	
	//--------------------------------------------------------------------------
	// 功能按鈕
	//--------------------------------------------------------------------------	
	var buttons = {
		
		//初始時查詢
		doPrompt_query: function(event){
			
			ajaxPost( 'query', {'LOAN_ID' :LOAN_ID, 'APPLY_DATE':APPLY_DATE, 'CHG_KIND': CHG_KIND, 'SEQ_NO': SEQ_NO }
				,function(resp){
									
					rtnMap = resp.rtnMap; //查詢成功,載入資料	
					
					//初始頁面顯示欄位
					$$('#table1 div').each(function(ele){
						ele.update(rtnMap[ele.id] || '');
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
				
				PageUI.createPageWithAllBodySubElement("DSC80102", "變更作業", "保戶優惠變更記錄");
				
				//-----------------------------------------------------
				//以下為進入初始頁面時需要執行的動作
				//-----------------------------------------------------
				
				//註冊DOM物件 : 監聽
				$("BTN_close").observe('click',  buttons.doclose);
				
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
<form name="form1" id="form1"
	style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px"
	action="">

<table width='100%' border='0' cellpadding='0' cellspacing='1'
	class='tbBox2' id='table1''>
	<tr>
		<td class='tbYellow' width='10%'>貸款帳號</td>
		<td class='tbYellow2' width='15%'>
		<div id='LOAN_ID'></div>
		</td>
		<td class='tbYellow' width='10%'>變更日期</td>
		<td class='tbYellow2' width='15%'>
		<div id='APPLY_DATE'></div>
		</td>
		<td class='tbYellow' width='10%'>變更序號</td>
		<td class='tbYellow2' width='15%' colspan='2'>
		<div id='SEQ_NO'></div>
		</td>

	</tr>
	<tr>
		<td class='tbYellow' width='10%'>原保優年月</td>
		<td class='tbYellow2' width='15%'>
		<div id='BEGIN_DATE1'></div>
		</td>
		<td class='tbYellow' width='10%'>原保優等級</td>
		<td class='tbYellow2' width='15%' colspan='4'>
		<div id='INSU_PRANK1'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>新保優年月</td>
		<td class='tbYellow2' width='15%'>
		<div id='BEGIN_DATE2'></div>
		</td>
		<td class='tbYellow' width='10%'>新保優等級</td>
		<td class='tbYellow2' width='15%' colspan='4'>
		<div id='INSU_PRANK2'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>輸入人員</td>
		<td class='tbYellow2' width='15%'>
		<div id='INPUT_ID'></div>
		<div id='INPUT_NM' style="font-family: 'EUDC'"></div> <%-- [20230315] --%>
		</td>
		<td class='tbYellow' width='10%'>輸入日期</td>
		<td class='tbYellow2' width='15%'>
		<div id='INPUT_DATE'></div>
		</td>
		<td class='tbYellow' width='10%'>輸入單位</td>
		<td class='tbYellow2' width='15%'>
		<div id='INPUT_DEPT'></div>
		<div id='INPUT_DEPT_NM'></div>
		</td>
	</tr>
	<tr>
		<td align='center' class='tbYellow2' rowspan='2' colspan='8'><input
			id='BTN_close' type='button' class='button' value='關閉視窗' /></td>

	</tr>
</table>
</form>
</body>
</html>