<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA31200.jsp
作者：王文進
功能：銀行案件退件
完成：2012/04/03
[20240930]難字調整
-->
<html>
<head>
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<%--[20240930]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA31200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31200(){
	
	var valid1;
	var viewMap;
	var buttonAuth = function (){
		var authButtons = {
			B0054:"btn_change"<%--修改--%> 
		};
		<dz:grantButtons FUNC_ID="DSA31200" ignored="false"/>
	};	
	
	//查詢
	function doQuery(){
		$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
		
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		var dataMap = {};
		dataMap.APPLY_ID = $('APPLY_ID').value;
				
		var params = { inputMap:Object.toJSON(dataMap) };
		//成功
		var successActionOpen = function(resp){
			var rtnMap = resp.rtnMap ? resp.rtnMap:[];
			setViewData(rtnMap);
			viewMap = rtnMap;
			CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value });  
		};
		var errorActionOpen = function(resp){
			var rtnMap = [];
			setViewData(rtnMap);
			viewMap = rtnMap;
		};
		ajaxPost('doQuery',params,successActionOpen,errorActionOpen);
	}
	
	//變更
	function doChange(){
	
		$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
		
		var dataMap = {};
		dataMap = viewMap;
		dataMap.REJECT = $('REJECT').value;
		dataMap.REJECT_NM = $('REJECT').options[$('REJECT').selectedIndex].text;
		dataMap.REJ_OTHER = $('REJ_OTHER').value;
		dataMap.REJ_REASON = $('REJ_REASON').value;
		
		if(dataMap.APPLY_ID!=$('APPLY_ID').value){
			alert("欲作業的受理編號{"+$('APPLY_ID').value+"}與原先查詢的受理編號{"+dataMap.APPLY_ID+"}不同,請重新查詢");
			return;
		}
		
		//if「是否退件」下拉選單為‘非退件’時，且rtnMap.CRED_ID不為空值，則提示確認訊息:‘確定要做退件取消作業？\n(取消退件後再退件，需重新進行退件呈核)’
		if($('REJECT').value==0 && dataMap.CRED_ID!=''){
			if(!confirm("確定要做退件取消作業？ \n (取消退件後再退件，需重新進行退件呈核)")){  
				return;
			}
		}
		
		if(dataMap.REJ_OTHER=='' && $('REJECT').value!=0){
			alert("請輸入退件說明");
			return;
		}
		if(dataMap.APPLY_PROCESS=='99' && $('REJECT').value!=0){
			alert("本帳號已為退件狀態，不可再作「退件」處理");
			return;
		}
		
		if(dataMap.APPLY_PROCESS!='99' && $('REJECT').value==0){
			alert("本帳號非為退件狀態，不需再作「非退件」處理");
			return;
		}
		
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		if(!confirm("確定要做「"+$('REJECT').options[$('REJECT').selectedIndex].text+"」作業?")){  
			return;
		}
		if($('REJECT').value==2){
			if(!confirm("因強制退件後無法再以「非退件」處理，請確認銀行端已同意退件?")){  
				return;
			}
		}
		
		var params = { inputMap:Object.toJSON(dataMap)};
		//成功
		var successActionOpen = function(resp){
			var rtnMap = resp.rtnMap ? resp.rtnMap:[];
			setViewData(rtnMap);
			viewMap = rtnMap;
		};  
		var errorActionOpen = function(resp){
			//var rtnMap = [];
			//setViewData(rtnMap);
			//viewMap = rtnMap;
		}; 
		
		ajaxPost('doChange',params,successActionOpen,errorActionOpen);
	}
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA3_1200/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}
	
	function createREJ_REASON(withOther) {
		$('REJ_REASON').length = 0;
		
		$('REJ_OTHER').hide();
		if(withOther) {
			var elOptNew = document.createElement('option');
			elOptNew.text =  '81其他';
			elOptNew.value = '81';
			$('REJ_REASON').add(elOptNew);
			$('REJ_REASON').value = '81';
			$('REJ_OTHER').show();
		}
	}
	
		/* 共用畫面設定 */
	function setViewData(rtnMap){	
		$('MASK_BORROW_NAME').innerHTML = rtnMap.MASK_BORROW_NAME ? rtnMap.MASK_BORROW_NAME : '';
		$('APPLY_PROCESS_NM').innerHTML = rtnMap.APPLY_PROCESS_NM ? rtnMap.APPLY_PROCESS_NM : '';
		$('GAGE_ADDR').innerHTML = rtnMap.GAGE_ADDR ? rtnMap.GAGE_ADDR : '';
		if(rtnMap.APPLY_PROCESS == '99') {
			createREJ_REASON(true);
			$('REJECT').value = '0';
			$('REJ_OTHER').value = rtnMap.REJ_OTHER? rtnMap.REJ_OTHER : '';
			$('REJ_REASON').value = '81';
		}else{
			createREJ_REASON(true);
			$('REJECT').value = '1';
			$('REJ_OTHER').value = rtnMap.REJ_OTHER? rtnMap.REJ_OTHER : '';
			$('REJ_REASON').value = '81';
		}
		$('INPUT_NAME').innerHTML = rtnMap.INPUT_NAME ? rtnMap.INPUT_NAME : '';
		$('INPUT_DATE').innerHTML = rtnMap.INPUT_DATE ? rtnMap.INPUT_DATE : '';
	}

	return{                              
		initApp:function(){

			PageUI.createPage("DSA31200" , "鑑價作業" , "銀行案件退件", false);
			PageUI.loadin(["table_A","table_B"] ,1);
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				['validateMaxLength', '字數過長', function(v , node) { if(!v){return true;} return validation.checkInputLength(v, node.maxLength, node.fullLength, node.halfLength); }],
				[ 'requiredAPPLY_ID',  '受理編號有誤，請檢查後重新輸入!', function(){ if($F('APPLY_ID') == ''){ return false; } return true; } ],
				[ 'chkAPPLY_ID',  '受理編號非國泰世華銀行案件，無法作業!', function(){ if($F('APPLY_ID').substring(3,4) != '@'){ return false; } return true; } ]
			]);
			
			//查詢
			$('btn_query').observe('click',function(event){
					doQuery();
				}
			);
			
			//變更
			$('btn_change').observe('click',function(event){
					doChange();
				}
			);

			$('REJ_REASON').observe('click',function(event){
					if($('REJ_REASON').value=='81'){
						$('REJ_OTHER').show();
					}else{
						$('REJ_OTHER').hide();
					}
				}
			);
			
			$("REJECT").observe('change',
				function(event){ 
					if($('REJECT').value=='2') {
						$("REJ_OTHER").value = $('REJECT').options[$('REJECT').selectedIndex].text;
						
					}
				}
			);
			
			buttonAuth();

			displayMessage();
			
			createREJ_REASON(true);
			
			if('${param.APPLY_ID}'!=''){
				$('APPLY_ID').value = '${param.APPLY_ID}';
			}
			if($('APPLY_ID').value==''){
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			}
			
			if($('APPLY_ID').value!=''){
				doQuery();
			}

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >

		
<!------------------------ A區--------------------->	
			<form id="form1" name="form1" method="post">
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table_A">
				<tr>
					<td class="tbYellow" width="12%">
						受理編號
					</td>
					<td class="tbYellow2">
						<input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2 requiredAPPLY_ID chkAPPLY_ID" size="15" maxlength="11" value="">
					</td>
					<td class="tbYellow2">
						<input id="btn_query" name="btn_query" type="button" class="button" value="查詢" >
					</td>
				</tr>
	 			<tr>
	 				<td colspan="3" align="center">
						<input id="btn_change" name="btn_change" type="button" class="button" value="變更" >
	 				</td>
                </tr>
			</table>
<!------------------------ B區--------------------->											
			<table id="table_B" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
				<tr>
                    <td class="tbBlue" width="12%">借款人姓名</td>
                    <td class="tbBlue2" id="MASK_BORROW_NAME" style="font-family:'EUDC'"></td><%--[20240930]難字調整 --%>
                    <td  class="tbBlue" width="12%">受理進度</td>
                    <td  class="tbBlue2" id="APPLY_PROCESS_NM"></td>
				</tr>
                <tr>
                 	<td class="tbBlue">擔保品地址</td>
                 	<td class="tbBlue2" colspan="3" id="GAGE_ADDR" style="font-family:'EUDC'"></td><%--[20240930]難字調整 --%>
               	</tr>
				<tr>
                    <td class="tbBlue2" colspan="4"><font color=red>本作業僅供處理銀行鑑價案件，請於退件說明欄位輸入銀行退件聯繫行員及退件原因。</font></td>
				</tr>
               	<tr>
               		<td width="10%" height="22" class="tbYellow">是否退件</td>
               		<td width="37%" class="tbYellow2" colspan="3">
						<select name="REJECT" id="REJECT">
							<c:forEach var="map" items="${REJ_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select>
					</td>
                </tr>
                <tr>
                    <td width="10%" height="22" class="tbYellow">退件說明</td>
                    <td width="37%" class="tbYellow2" colspan="3">
						<select name="REJ_REASON" id="REJ_REASON" class="textBox2">
						</select>
						<input id="REJ_OTHER" name="REJ_OTHER" type="text" class="textBox2 validateMaxLength" size="50" maxlength="40" value="">
					</td>
				</tr>
				<tr>
                    <td  class="tbYellow">退件人員</td>
                    <td  class="tbYellow2" id="INPUT_NAME" style="font-family:'EUDC'"></td><%--[20240930]難字調整 --%>
					<td  class="tbYellow">退件日期</td>
					<td  class="tbYellow2" id="INPUT_DATE"></td>
				</tr>
			</table>
			</form>

</body>
<!-- InstanceEnd -->
</html>