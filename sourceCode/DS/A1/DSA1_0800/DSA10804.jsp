<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!--
程式：DSA10804.jsp
功能：2Q案件改派作業
作者：韓軍逸
完成：2021-12-03
-->

<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<!--匯入外部Javascript 與 css-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>

<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript'>

<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSA10804().initApp);

function DSA10804() {
	
	<%-- CSRUtil.AjaxHandler --%>
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA1_0804/');
	<%-- validation --%>
	var valid;

	<%--畫面檢核--%>
	function initValidation(){
		valid = new Validation('form1');
		valid.define( 'required' , [{ id : '2Q_CRED_DEPT', errMsg:'請選擇轉派單位' }] );
	}
			
	var actions = {
		<%-- 取得input輸入的資料給java --%>
		getRecord : function(){
			var record = { 
				'APPLY_ID' : '${APPLY_ID}',  
				'2Q_CRED_DEPT' : $F("2Q_CRED_DEPT"),
				'StepName' : '${StepName}'
			};
			return record;			
		}
		
	};

	var buttons = {

		doReassign : function() {<%-- 確定改派 --%>
			
			valid.reset();
			if(!valid.validate()){
				return;
			}

		    <%-- 發出ajaxRequest請求--%>
			ajaxRequest.post('reassign',
				{
					reqMap : Object.toJSON(actions.getRecord())
				}
			);
		},
		
		doPrepage : function(){<%-- 回上一頁 --%>
			if(window.isPopupWin && window.popupWinBack){
				window.popupWinBack();
			}else if(window.parent && window.parent.popupWin){
				window.parent.popupWin.back();
			}else{
				CSRUtil.linkBack(); 
			}
		}
	};
	
	return {

		initApp : function() {
			<%-- PageUI --%>
			PageUI.createPageWithAllBodySubElement('DSA10804', '2Q案件改派作業', '2Q案件改派作業');
			
			<%-- 註冊事件 --%>
			$('btn_reassign').observe('click', buttons.doReassign);
			$('btn_prepage').observe('click', buttons.doPrepage);

			
			initValidation();
			displayMessage();
		}
	};
}
</script>
</head>
<body>
<form id="form1" name="form1">
	<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0" class="tbBox2">
		<tr>
			<td align="left" class="tbYellow">受理編號</td>
			<td align="left" class="tbYellow2" ><span id="APPLY_ID">${APPLY_ID}</span></td>
			<td align="left" class="tbYellow">進度</td>
			<td align="left" class="tbYellow2" ><span id="StepName">${StepName}</span></td>				
		</tr>	
		<tr>	
			<td align="left" class="tbYellow">比對紀錄</td>
			<td align="left" class="tbYellow2" ><span id="ASSIGN_2Q_CNT">${ASSIGN_2Q_CNT}</span>
			<td align="left" class="tbYellow">轉派單位</td>
			<td align="left" class="tbYellow2">
					<select class="textBox2" name="2Q_CRED_DEPT" id="2Q_CRED_DEPT">
                         <option value="">請選擇</option>
                         	<c:forEach var="map" items="${CRED_DEPT_EXP_LIST}">
                           	<option value="${map.key}">${map.value}</option>
                         	</c:forEach>
                       </select>
			</td>
		</tr>
		<tr>	
			<td align="left" class="tbYellow">轉派人員</td>
			<td align="left" class="tbYellow2" ><span>${INPUT_ID}</span></td>
			<td align="left" class="tbYellow">轉派時間</td>
			<td align="left" class="tbYellow2" ><span>${INPUT_TIME}</span></td>
		</tr>
		<tr>
			<td align="center" colspan="4" class="tbYellow2">
				<button type="button" id="btn_reassign" class="button">確定改派</button>			
				<button type="button" id="btn_prepage" class="button">回上一頁</button>
			</td>
		</tr>
	</table>
</form>
</body>
</html>