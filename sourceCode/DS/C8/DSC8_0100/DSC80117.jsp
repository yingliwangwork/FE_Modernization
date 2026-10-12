<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!--
程式：DSC80117.jsp
作者：溫子?
功能：收息單位變更記錄
完成：2013/8//28

[20230316]修改件
難字調整
郭曉慧
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<!--[20230316]難字css  -->
<style type="text/css">
@font-face{
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		 url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight:normal;
	font-style:normal
}
</style>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<!--alert訊息-->

<script type="text/javascript">
//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC80117().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC80117(){
//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0117/" + actionName,
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
	var action ={
		doQuery : function(event){
			ajaxPost('query', {	LOAN_ID : '${LOAN_ID}', APPLY_DATE : '${APPLY_DATE}',CHG_KIND : '${CHG_KIND}',SEQ_NO : '${SEQ_NO}'}
				,function(resp){
					rtnMap=resp.rtnMap;
					//初始頁面顯示欄位
					$$('.class1').each(function(ele){
						var id = ele.id;
						
						ele.update(rtnMap[id] || '');
					});
				})
		}
		,doClose : function (){
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
				
				PageUI.createPageWithAllBodySubElement('DSC80117', '變更作業', '收息單位變更記錄');
				
				action.doQuery();
				
				$('BTN_CLOSE').observe('click', action.doClose);
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
				
			}
	}
}
</script>
</head>
<body>
<form  id='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
			<tr>
				<td class="tbYellow" width="10%">貸款帳號:</td>
				<td class="tbYellow2" width="10%">
				<div id='LOAN_ID' class='class1'></div> 
				</td>
				<td class="tbYellow" width="5%">變更日期:</td>
				<td class="tbYellow2" width="10%">
				<div id='APPLY_DATE' class='class1'></div>
				</td>
				<td class="tbYellow" width="5%">序號:</td>
				<td class="tbYellow2" width="10%">
				<div id='SEQ_NO' class='class1'></div>
				</td>
			</tr>
			<tr>
			<!--[20230330]補-收息資料加難字style  -->
			<td class="tbYellow" width="5%">原收息資料:</td>
			<td class="tbYellow2" width="10%" colspan='5'>
			<span id='ADDRESS1' class='class1' style="font-family:'EUDC'"></span>
			</td>
			</tr>
			<tr>
				<td class="tbYellow" width="5%" >原收息單位:</td>
				<td class="tbYellow2" width="10%" >
				<span id='GETINT_DEPT1' class='class1'></span>
				</td>
				<td class="tbYellow" width="10%" >原日間電話:</td>
				<td class="tbYellow2" width="10%" >
				<span id='DAY_TEL1' class='class1'></span>
				</td>	
				<td class="tbYellow" width="10%">原夜間電話:</td>
				<td class="tbYellow2" width="10%">
				<span id='NIGHT_TEL1' class='class1'></span>
				</td>	
			</tr>
			<!--[20230316]備註/人員姓名加難字style  -->
			<tr>
				<td class="tbYellow" width="5%" >原備註</td>
				<td class="tbYellow2" width="10%" colspan="6">
				<div id='UPDATE_MEMO1' class='class1' style="font-family:'EUDC'"></div>
			</tr>
			<tr>
			<td class="tbYellow" width="5%" >新收息資料:</td>
			<td class="tbYellow2" width="10%" colspan='5'>
			<span id='ADDRESS2' class='class1' style="font-family:'EUDC'"></span>
			</td>
			</tr>
			<tr>
				<td class="tbYellow" width="5%" >新收息單位:</td>
				<td class="tbYellow2" width="10%" >
				<span id='GETINT_DEPT2' class='class1'></span>
				</td>
				<td class="tbYellow" width="10%" >新日間電話:</td>
				<td class="tbYellow2" width="10%">
				<span id='DAY_TEL2' class='class1'></span>
				</td>
				<td class="tbYellow" width="10%" >新夜間電話:</td>
				<td class="tbYellow2" width="10%">
				<span id='NIGHT_TEL1' class='class1'></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="5%" >新備註</td>
				<td class="tbYellow2" width="10%" colspan="6">
				<div id='UPDATE_MEMO2' class='class1' style="font-family:'EUDC'"></div>
			</tr>
			<tr>
			<td class="tbYellow" width="5%" >輸入人員:</td>
				<td class="tbYellow2" width="10%" >
				<div id='INPUT_ID' class='class1'></div>
				<div id='INPUT_NM' class='class1' style="font-family:'EUDC'"></div>
				<td class="tbYellow" width="5%" >輸入日期:</td>
				<td class="tbYellow2" width="10%" >
				<div id='INPUT_DATE' class='class1'></div>
				<td class="tbYellow" width="5%" >輸入單位:</td>
				<td class="tbYellow2" width="10%" >
				<div id='INPUT_DEPT' class='class1'></div>
				<div id='INPUT_DEPT_NM' class='class1'></div>
			</tr>
			<tr>
				<td align='center' class='tbYellow2' colspan='8'>
				<input id='BTN_CLOSE' type='button' class='button' value='關閉視窗' />
				</td>
			</tr>
	</table>
</form>
</body>
</html>