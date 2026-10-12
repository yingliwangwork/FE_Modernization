<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!--
程式：DSC80112.jsp
作者：溫子
功能：扣薪組別變更記錄
完成：2013/3/14

[20230317]修改件
難字調整
郭曉慧

-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<fmt:setBundle basename="TextResource" />
<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
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
<link href="<%=htmlBase%>/CM/js/ext/resources/css/ext-all.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<!--alert訊息-->

<script type="text/javascript">
//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC80112().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC80112(){

	var rtnMap;
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0112/" + actionName,
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

	var actions ={
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
		,doClose : function (event){
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
				
				PageUI.createPageWithAllBodySubElement('DSC80112', '變更作業', '扣薪組別變更記錄');
				
				actions.doQuery();
				
				$('BTN_CLOSE').observe('click', actions.doClose);
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
				<td class="tbYellow" width="5%">貸款帳號</td>
				<td class="tbYellow2" width="10%">
				<div id='LOAN_ID' class='class1'></div>
				</td>
				<td class="tbYellow" width="5%">變更日期</td>
				<td class="tbYellow2" width="10%">
				<div id='APPLY_DATE' class='class1'></div>
				</td>
				<td class="tbYellow" width="5%">序號</td>
				<td class="tbYellow2" width="10%" colspan="3">
				<div id='SEQ_NO' class='class1'></div>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="5%">原扣薪組別</td>
				<td class="tbYellow2" width="10%">
				<div id='SALARY_GROUP1' class='class1'></div>
				</td>
				<td class="tbYellow" width="5%">原扣薪狀態</td>
				<td class="tbYellow2" width="10%">
				<div id='SALARY_STATUS1' class='class1'></div>
				</td>
				<td class="tbYellow" width="5%">新扣薪組別</td>
				<td class="tbYellow2" width="10%">
				<div id='SALARY_GROUP2' class='class1'></div>
				</td>
				<td class="tbYellow" width="5%">新扣薪狀態</td>
				<td class="tbYellow2" width="10%">
				<div id='SALARY_STATUS2' class='class1'></div>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="5%">輸入人員</td>
				<td class="tbYellow2" width="10%">
				<div id='INPUT_ID' class='class1'></div>
				<!--[20230317]人員姓名加難字style  -->
				<div id='INPUT_NM' class='class1' style="font-family:'EUDC'"></div>
				</td>
				<td class="tbYellow" width="5%">輸入日期</td>
				<td class="tbYellow2" width="10%">
				<div id='INPUT_DATE' class='class1'></div>
				</td>
				<td class="tbYellow" width="5%">輸入單位</td>
				<td class="tbYellow2" width="10%" colspan="3">
				<div id='INPUT_DEPT' class='class1'></div>
				<div id='INPUT_DEPT_NM' class='class1'></div>
				</td>
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