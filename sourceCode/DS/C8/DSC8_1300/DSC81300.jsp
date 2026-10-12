<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<!--
程式：DSC81300.jsp
功能：清償控管作業
作者：溫子?
完成：2013/08/

[20230321]
難字調整
高強禾
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC81300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC81300(){
	// 按鈕權限
	var buttonAuth = function(){
		var authButtons = {
			B0004 : 'BTN_UPDATE'		<%--變更--%>		
		};
		<dz:grantButtons FUNC_ID='DSC81300'/>
	};
	function initValidation(){		
			//查詢用檢核
			valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid1.define('required' , [{ id : "LOAN_ID" , errMsg:"請輸入貸款帳號"}] );
			valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid2.define('required' , [{ id : "PAYOFF_REASON" , errMsg:"請輸入變更原因"}] );
			valid2.define('validate-selection' , [{ id : "NEW_PAYOFF_LIMIT" , errMsg:"請選擇新個控代碼"}] );
	}
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_1300/" + actionName,
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
var buttons={

	doQuery : function(){
		if(!valid1.validate()){
			return;
		}
		ajaxPost( 'query', {LOAN_ID : $F('LOAN_ID')}
					,function(resp){
						
						var rtnMap=resp.rtnMap;
						$('BORROW_NAME').value=rtnMap['BORROW_NAME'];
						$('PAYOFF_LIMIT').value=rtnMap['PAYOFF_LIMIT'];
						$('LOAN_ID_OLD').value =rtnMap['LOAN_ID'];
						$('BTN_UPDATE').enable();
						if(rtnMap['PAYOFF_LIMIT']=='6'){
							alert("此件不可變更");
							$('BTN_UPDATE').disable();
							return;
						}
					},function(resp){
						$('BORROW_NAME').value='';
						$('PAYOFF_LIMIT').value='';
						$('LOAN_ID_OLD').value ='';
					}
			);
	
	},doUpdate : function(){
		valid1.reset();
		if(!valid2.validate()){
			return;
		}
		if(!$F('LOAN_ID_OLD')){
			alert("請先查詢後再做變更");
			return;
		}
		var LOAN_ID = $F('LOAN_ID');
		var LOAN_ID_OLD = $F('LOAN_ID_OLD');
		if(LOAN_ID!=LOAN_ID_OLD){
			alert("欲變更的"+LOAN_ID+"與原先查詢的"+LOAN_ID_OLD+"不同，無法作業!!");
			return;
		}
		ajaxPost( 'update', {DATA_MAP : Object.toJSON(info())}
					,function(resp){
						var rtnMap=resp.rtnMap;
						$('BORROW_NAME').value=rtnMap['BORROW_NAME'];
						$('PAYOFF_LIMIT').value=rtnMap['PAYOFF_LIMIT'];
						$('LOAN_ID_OLD').value =rtnMap['LOAN_ID'];
						if(rtnMap['PAYOFF_LIMIT']=='6'){
							alert("此件不可變更");
							return;
							$('BTN_UPDATE').disable();
						}
					}
			);
	
	}
}
	var info = function(){
		
			var dataMap = {};
 
			$$('#form input[type!="button"]', '#form select').each(
				function(text){
					dataMap[text.id] =text.value;
				}
			);

			return dataMap;	
		};
	return {
	
		initApp : function(){
			PageUI.createPageWithAllBodySubElement('DSC81300', '變更作業', '清償控管作業');
			
			
			initValidation();
			$('BTN_QUERY').observe('click',buttons.doQuery);
			$('BTN_UPDATE').observe('click',buttons.doUpdate);
			$('PAYOFF_LIMIT').disable();
			buttonAuth();
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
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">貸款帳號</td>
			<td class="tbYellow2" width="30%">
			<input id="LOAN_ID"  type="text" class="textBox2 " onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="LOAN_ID_OLD" type="hidden">
			</td>
			<td class="tbYellow2" colspan='2'>
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >
				<input id="BTN_UPDATE" type="button" value="變更" class="button" >				
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
		<tr>
			<td class="tbBox3" align="center">
				清償控管作業查詢結果
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="15%" align='center'>借款人姓名</td>
			<td class="tbYellow2" >
			<%-- [20230321] 難字調整 --%>
			<input id="BORROW_NAME"  size="30" type="text" class="textBox2" alt="ch" disabled/>
			</td>
			<td class="tbYellow" width="15%" align='center'>原個控代碼</td>
			<td class="tbYellow2" >
				<select id="PAYOFF_LIMIT">
					<option value="">請選擇</option>
						<c:forEach var="map" items="${PAYOFF_LIMIT_List}">
								<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select> 
			</td>
		</tr>
		<tr>
			<td class="tbYellow0" width="10%" align='center' colspan='5'>變更後資料</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" align='center'>新個控代碼</td>
			<td class="tbYellow2" >
				<select id="NEW_PAYOFF_LIMIT">
					<option value="">請選擇</option>
						<c:forEach var="map" items="${PAYOFF_LIMIT_List}">
								<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select> 
			</td>
			<td class="tbYellow" width="10%" align='center'>變更原因</td>
			<td class="tbYellow2" >
			<input id="PAYOFF_REASON"  type="text" class="textBox2 " size="30" maxlength="25"/>
			</td>
		</tr>
	</table>
</form>
</body>
</html>