<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC80106.jsp
作者：劉金宜
功能：貸款年期變更記錄
完成：2013/01/23

[20230316] 修改程式  楊青峰
難字調整
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
Event.observe(window, 'load', new DSC80106().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC80106(){
	var rtnMap; 
	
	//==========================================================================
	// 功能按鈕
	//==========================================================================
	var actions = {
		//--------------------------------------------------------------------------
		// 共用的Ajax
		//--------------------------------------------------------------------------
		ajaxPost : function( actionName, params, successFunction, errorFunction ){	
			new Ajax.Request( "<%=dispatcher%>/DSC8_0106/" + actionName,
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
		},	
		//--------------------------------------------------------------------------
		// 查詢
		//--------------------------------------------------------------------------
		doQuery: function(event){
			actions.ajaxPost( 'query', {'LOAN_ID' :'${LOAN_ID}', 'APPLY_DATE':'${APPLY_DATE}', 'CHG_KIND': '${CHG_KIND}', 'SEQ_NO': '${SEQ_NO}' }
				,function(resp){
					
					//載入資料					
					rtnMap = resp.rtnMap;
					
					$$('#table1 div').each(function(ele){
						var id = ele.id;
						ele.update(rtnMap[id] || '');
					});
				}			
			);
		},
		//--------------------------------------------------------------------------
		// 上一頁:執行關閉功能
		//--------------------------------------------------------------------------
		doClose : function(event){	
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
				
				PageUI.createPageWithAllBodySubElement('DSC80106', '變更作業', '貸款年期變更記錄');
				
				//註冊DOM物件 : 監聽
				$('btn_close').observe('click',  actions.doClose);
				
				//初始時執行查詢功能
				actions.doQuery();
				
				fix();
			
                displayMessage();
			
				PageUI.resize();
				
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
		<td class='tbYellow' width='10%'>貸款帳號</td>
		<td class='tbYellow2' width='15%'>
		<div id='LOAN_ID' ></div>
		</td>
		<td class='tbYellow' width='10%'>變更日期</td>
		<td class='tbYellow2' width='15%'>
		<div id='APPLY_DATE' ></div>
		</td>
		<td class='tbYellow' width='10%'>序號</td>
		<td class='tbYellow2' width='15%'>
		<div id='SEQ_NO' ></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>原貸款期數</td>
		<td class='tbYellow2' width='15%'>
		<div id='LOAN_PERIOD1' ></div>
		</td>
		<td class='tbYellow' width='10%'>原分期期數</td>
		<td class='tbYellow2' width='15%'>
		<div id='SPR_PERIOD1'></div>
		</td>
		<td class='tbYellow' width='10%'>原定期期數</td>
		<td class='tbYellow2' width='15%'>
		<div id='FIX_PERIOD1'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>原期別</td>
		<td class='tbYellow2' width='15%'>
		<div id='TERM_TYPE1' ></div>
		</td>
		<td class='tbYellow' width='10%'>原還款方式</td>
		<td class='tbYellow2' width='15%' colspan='3'>
		<div id='RETURN_TYPE1'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>新貸款期數</td>
		<td class='tbYellow2' width='15%'>
		<div id='LOAN_PERIOD2' ></div>
		</td>
		<td class='tbYellow' width='10%'>新分期期數</td>
		<td class='tbYellow2' width='15%'>
		<div id='SPR_PERIOD2'></div>
		</td>
		<td class='tbYellow' width='10%'>新定期期數</td>
		<td class='tbYellow2' width='15%'>
		<div id='FIX_PERIOD2'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>新期別</td>
		<td class='tbYellow2' width='15%'>
		<div id='TERM_TYPE2' ></div>
		</td>
		<td class='tbYellow' width='10%'>新還款方式</td>
		<td class='tbYellow2' width='15%' colspan='3'>
		<div id='RETURN_TYPE2'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>輸入人員</td>
		<td class='tbYellow2' width='15%'>
		<div id='INPUT_ID' ></div>
		<div id='INPUT_NM' style="font-family: 'EUDC'"></div> <%-- [20230316] --%>
		</td>
		<td class='tbYellow' width='10%'>輸入日期</td>
		<td class='tbYellow2' width='15%'>
		<div id='INPUT_DATE' ></div>
		</td>
		<td class='tbYellow' width='10%'>輸入單位</td>
		<td class='tbYellow2' width='15%'>
		<div id='INPUT_DEPT' ></div>
		<div id='INPUT_DEPT_NM' ></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%' rowspan='2'>覆核人員</td>
		<td class='tbYellow2' width='15%' rowspan='2'>
		<div id='CONFIRM_ID' ></div>
		<div id='CONFIRM_NM' style="font-family: 'EUDC'"></div> <%-- [20230316] --%>
		</td>
		<td class='tbYellow' width='10%' rowspan='2'>覆核日期</td>
		<td class='tbYellow2' width='15%' rowspan='2'>
		<div id='CONFIRM_DATE' ></div>
		</td>
		<td class='tbYellow' width='10%' rowspan='2'>覆核單位</td>
		<td class='tbYellow2' width='15%' rowspan='2'>
		<div id='CONFIRM_DEPT' ></div>
		<div id='CONFIRM_DEPT_NM' ></div>
		</td>
	</tr>	
	<tr>
	</tr>
	<tr>
		<td align='center' class='tbYellow2' colspan='8'><input
			id='btn_close' type='button' class='button' value='關閉視窗' /></td>
	</tr>
</table>
</form>
</body>
</html>