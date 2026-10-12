<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC80105.jsp
作者：劉金宜
功能：收息地址變更記錄
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
Event.observe(window, 'load', new DSC80105().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC80105(){
	var rtnMap; 
	
	//==========================================================================
	// 功能按鈕
	//==========================================================================
	var actions = {
		//--------------------------------------------------------------------------
		// 共用的Ajax
		//--------------------------------------------------------------------------
		ajaxPost : function( actionName, params, successFunction, errorFunction ){	
			new Ajax.Request( "<%=dispatcher%>/DSC8_0105/" + actionName,
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
						$('ADDRESS'+i).update(actions.getValue(rtnMap['ZIP'+i])+actions.getValue(rtnMap['ADDRESS'+i])); //收息資料
						$('DAY_TEL'+i).update(actions.getValue(rtnMap['DAY_TEL_AREA'+i])+actions.getValue(rtnMap['DAY_TEL_NUM'+i])+actions.getValue(rtnMap['DAY_TEL_EXT'+i])); //日間電話
						$('NIGHT_TEL'+i).update(actions.getValue(rtnMap['NIGHT_TEL_AREA'+i])+actions.getValue(rtnMap['NIGHT_TEL_NUM'+i])+actions.getValue(rtnMap['NIGHT_TEL_EXT'+i])); //夜間電話
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
				
				PageUI.createPageWithAllBodySubElement('DSC80105', '變更作業', '轉籍資料變更記錄');
				
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
		<td class='tbYellow' width='10%'>原收息資料</td>
		<td class='tbYellow2' width='15%' colspan='5'>
		<div id='ADDRESS1' style="font-family: 'EUDC'"></div> <%-- [20230316] --%>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>原收息單位</td>
		<td class='tbYellow2' width='15%'>
		<div id='GETINT_DEPT1' class='class1'></div>
		</td>
		<td class='tbYellow' width='10%'>原日間電話</td>
		<td class='tbYellow2' width='15%'>
		<div id='DAY_TEL1'></div>
		</td>
		<td class='tbYellow' width='10%'>原夜間電話</td>
		<td class='tbYellow2' width='15%'>
		<div id='NIGHT_TEL1'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>新收息資料</td>
		<td class='tbYellow2' width='15%' colspan='5'>
		<div id='ADDRESS2' style="font-family: 'EUDC'"></div> <%-- [20230316] --%>
		</td>

	</tr>
	<tr>
		<td class='tbYellow' width='10%'>新收息單位</td>
		<td class='tbYellow2' width='15%'>
		<div id='GETINT_DEPT2' class='class1'></div>
		</td>
		<td class='tbYellow' width='10%'>新日間電話</td>
		<td class='tbYellow2' width='15%'>
		<div id='DAY_TEL2'></div>
		</td>
		<td class='tbYellow' width='10%'>新夜間電話</td>
		<td class='tbYellow2' width='15%'>
		<div id='NIGHT_TEL2'></div>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%' rowspan='2'>輸入人員</td>
		<td class='tbYellow2' width='15%' rowspan='2'>
		<div id='INPUT_ID' class='class1'></div>
		<div id='INPUT_NM' class='class1' style="font-family: 'EUDC'"></div> <%-- [20230316] --%>
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