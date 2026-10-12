<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC80107.jsp
作者：劉金宜
功能：優惠同意變更記錄
完成：2013/01/23

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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<!--alert訊息-->
<script type="text/javascript">

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC80107().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC80107(){
	var rtnMap; 
	
	//==========================================================================
	// 功能按鈕
	//==========================================================================
	var actions = {
		//--------------------------------------------------------------------------
		// 共用的Ajax
		//--------------------------------------------------------------------------
		ajaxPost : function( actionName, params, successFunction, errorFunction ){	
			new Ajax.Request( "<%=dispatcher%>/DSC8_0107/" + actionName,
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
		getValue : function(value){
			if(value == null){
				return '';
			}
			return value;
		},
		//--------------------------------------------------------------------------
		// 查詢
		//--------------------------------------------------------------------------
		doQuery: function(event){
			actions.ajaxPost( 'query', {'LOAN_ID' :'${LOAN_ID}', 'APPLY_DATE':'${APPLY_DATE}', 'CHG_KIND': '${CHG_KIND}', 'SEQ_NO': '${SEQ_NO}' }
				,function(resp){
					
					//載入資料					
					rtnMap = resp.rtnMap;	
					
					$$('.class1').each(function(ele){
						var id = ele.id;
						ele.update(rtnMap[id] || '');
					});
					
					for(var i = 1; i < 3; i++){
						$('INSU_NOTE'+i).update(rtnMap['INSU_NOTE'+i+'_NM'] || ''); //優惠同意
						$('INSU_DATA'+i).update(actions.getValue(rtnMap['INSU_NOTE'+i])+ '級'); //保優資料
					}
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
				
				PageUI.createPageWithAllBodySubElement('DSC80107', '變更作業', '優惠同意變更記錄');
				
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
		<div id='LOAN_ID' class='class1'></div>
		</td>
		<td class='tbYellow' width='10%'>變更日期</td>
		<td class='tbYellow2' width='15%'>
		<div id='APPLY_DATE' class='class1'></div>
		</td>
		<td class='tbYellow' width='10%'>序號</td>
		<td class='tbYellow2' width='15%'>
		<div id='SEQ_NO' class='class1'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>原優惠同意 </td>
		<td class='tbYellow2' width='15%'>
		<div id='INSU_NOTE1' ></div>
		</td>
		<td class='tbYellow' width='10%'>原建物用途</td>
		<td class='tbYellow2' width='15%'>
		<div id='BUILD_USE1' class='class1'></div>
		</td>
		<td class='tbYellow' width='10%'>原保優資料</td>
		<td class='tbYellow2' width='15%'>
		<div id='INSU_DATA1'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>新優惠同意</td>
		<td class='tbYellow2' width='15%'>
		<div id='INSU_NOTE2' ></div>
		</td>
		<td class='tbYellow' width='10%'>新建物用途</td>
		<td class='tbYellow2' width='15%'>
		<div id='BUILD_USE2' class='class1'></div>
		</td>
		<td class='tbYellow' width='10%'>新保優資料</td>
		<td class='tbYellow2' width='15%'>
		<div id='INSU_DATA2'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%' rowspan='2'>輸入人員</td>
		<td class='tbYellow2' width='15%' rowspan='2'>
		<div id='INPUT_ID' class='class1'></div>
		<div id='INPUT_NM' class='class1' style="font-family: 'EUDC'"></div> <%-- [20230315] --%>
		</td>
		<td class='tbYellow' width='10%' rowspan='2'>輸入日期</td>
		<td class='tbYellow2' width='15%' rowspan='2'>
		<div id='INPUT_DATE' class='class1'></div>
		</td>
		<td class='tbYellow' width='10%' rowspan='2'>輸入單位</td>
		<td class='tbYellow2' width='15%' rowspan='2'>
		<div id='INPUT_DEPT' class='class1'></div>
		<div id='INPUT_DEPT_NM' class='class1'></div>
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