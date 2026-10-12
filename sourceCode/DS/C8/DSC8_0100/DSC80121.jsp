<%@ page language="java" contentType="text/html; charset=BIG5"
    pageEncoding="BIG5"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" >
<!--
程式：DSC8_0121.java
作者：陳思涵 
功能：火險經手人變更記錄
完成：2013-09-04	

[20230316]修改件: 難字修改
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%-- [20230316]新增style --%>
<style type="text/css">
	@font-face {
		 font-family: 'EUDC';
		 src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
			  url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		 font-weight: normal;
		 font-style: normal
	}
</style>

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script><!-- 必要 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script><!-- 必要 -->

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script><!-- 目前畫面的版面設定 -->

<script type="text/JavaScript">
Event.observe(window, 'load', new DSC80121().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC80121(){

	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0121/" + actionName,
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
	}//END   共用AJAX
	
	var buttons = {
		doQuery : function(){
		
			ajaxPost( 'query', {'LOAN_ID' :'${LOAN_ID}','SEQ_NO': '${SEQ_NO}' }
				,function(resp){
					
					var rtnMap = resp.rtnMap || {};
					$$('#table span').each(
						function(ele){
							var id = ele.id;
							if(id == 'INPUT_DATE'){
								ele.update(Date.toROC(rtnMap[id]));
							}else {
								ele.update(rtnMap[id] || '');
							}
					});
				}			
			);
		},
		doClose : function (){
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
	
	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC80121', '變更作業', '火險經手人變更記錄');
			
			$('btn_return').observe('click',buttons.doClose);
			
			//初始時執行查詢功能
			buttons.doQuery();
			
			
			
			PageUI.resize();			
			displayMessage();			
		}
	};

}

</script>
</head>
<body>
<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow"  width="15%">歸戶帳號</td>
			<td class="tbYellow2">
				<span id="REFER_ID"></span>
 			</td>
			<td class="tbYellow"  width="15%">序號</td>
			<td class="tbYellow2">
				<span id="SEQ_NO"></span>
			</td>
			<td class="tbYellow"  width="15%">變更原因</td>
			<td class="tbYellow2">
				<span id="CHG_REASON"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  width="15%">原經手人ID</td>
			<td class="tbYellow2">
				<span id="OLD_FIRE_AGENT_ID"></span>
			</td>
			<td class="tbYellow"  width="15%">原經手人姓名</td>
			<td class="tbYellow2">
				<span id="OLD_FIRE_AGENT_NAME" style="font-family:'EUDC'"></span> <%-- [20230316]難字style --%>
			</td>
			<td class="tbYellow"  width="15%">原經手人單位</td>
			<td class="tbYellow2">
				<span id="OLD_FIRE_AGENT_DEPT_NM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  width="15%">新經手人ID</td>
			<td class="tbYellow2">
				<span id="FIRE_AGENT_ID"></span>
			</td>
			<td class="tbYellow"  width="15%">新經手人姓名</td>
			<td class="tbYellow2">
				<span id="FIRE_AGENT_NAME" style="font-family:'EUDC'"></span> <%-- [20230316]難字style --%>
			</td>
			<td class="tbYellow"  width="15%">新經手人單位</td>
			<td class="tbYellow2">
				<span id="FIRE_AGENT_DEPT_NM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  width="15%">輸入人員</td>
			<td class="tbYellow2">
				<span id="INPUT_ID"></span><br>
				<span id="INPUT_NM" style="font-family:'EUDC'"></span> <%-- [20230316]難字style --%>
			</td>
			<td class="tbYellow"  width="15%">輸入日期</td>
			<td class="tbYellow2">
				<span id="INPUT_DATE"></span>
			</td>
			<td class="tbYellow"  width="15%">輸入單位</td>
			<td class="tbYellow2">
				<span id="INPUT_DEPT"></span><br>
				<span id="INPUT_DEPT_NM"></span>
			</td>
		</tr>
		
		
		
		<tr>
			<td  colspan="6" align="center" >
				<input id="btn_return" type="button" class="button" value="關閉視窗"/>
			</td>
		</tr>
</table>


</body>
</html>