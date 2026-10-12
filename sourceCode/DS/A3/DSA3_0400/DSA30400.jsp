<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA30400.jsp
作者：王文進
功能：免鑑價之處理
完成：2012/03/14

[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
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

<style type="text/css">
@font-face {
font-family: 'EUDC';
  src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
       url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
 font-weight: normal;
 font-style: normal
}
</style>

<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA30400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA30400(){
	
	var valid1;
	var viewMap;
	var buttonAuth = function (){
		var authButtons = {
			B0054:"btn_change"<%--修改--%> 
		};
		<dz:grantButtons FUNC_ID="DSA30400" ignored="false"/>
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
		dataMap.IS_APPRAISAL = $('IS_APPRAISAL').value;
		dataMap.IS_APPRAISAL_NM = $('IS_APPRAISAL').options[$('IS_APPRAISAL').selectedIndex].text;
		dataMap.REASON = $('REASON').value;
		dataMap.REASON_TEXT = $('REASON_TEXT').value;
		
		if(dataMap.APPLY_ID!=$('APPLY_ID').value){
			alert("欲作業的受理編號{"+$('APPLY_ID').value+"}與原先查詢的受理編號{"+dataMap.APPLY_ID+"}不同,請重新查詢");
			return;
		}
		
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}

		var params = { inputMap:Object.toJSON(dataMap)};
		//成功
		var successActionOpen = function(resp){
			var rtnMap = resp.rtnMap ? resp.rtnMap:[];
			setViewData(rtnMap);
			viewMap = rtnMap;
		};
		var errorActionOpen = function(resp){
			var rtnMap = [];
			setViewData(rtnMap);
			viewMap = rtnMap;
		};  
		if(confirm("確定要做「"+$('IS_APPRAISAL').options[$('IS_APPRAISAL').selectedIndex].text+"」作業?")){  
			ajaxPost('doChange',params,successActionOpen,errorActionOpen);
		}
		
	}
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA3_0400/" + actionName,
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
	
		/* 共用畫面設定 */
	function setViewData(rtnMap){	
		$('BORROW_NAME').innerHTML = rtnMap.BORROW_NAME ? rtnMap.BORROW_NAME : '';
		$('APPLY_PROCESS_NM').innerHTML = rtnMap.APPLY_PROCESS_NM ? rtnMap.APPLY_PROCESS_NM : '';
		$('GAGE_ADDR').innerHTML = rtnMap.GAGE_ADDR ? rtnMap.GAGE_ADDR : '';
		$('CRED_NM').innerHTML = rtnMap.CRED_NM ? rtnMap.CRED_NM : '';
		$('CRED_TEL').innerHTML = rtnMap.CRED_TEL ? rtnMap.CRED_TEL : '';
		$('APPR_NM').innerHTML = rtnMap.APPR_NM ? rtnMap.APPR_NM : '';
		$('APPR_TEL').innerHTML = rtnMap.APPR_TEL ? rtnMap.APPR_TEL : '';
		$('IS_APPRAISAL').value = rtnMap.IS_APPRAISAL ? rtnMap.IS_APPRAISAL : '';
		$('INPUT_NM').innerHTML = rtnMap.INPUT_NM ? rtnMap.INPUT_NM : '';
		$('REASON').value = rtnMap.REASON ? rtnMap.REASON : '';
		$('INPUT_DATE').innerHTML = rtnMap.INPUT_DATE ? rtnMap.INPUT_DATE : '';
		$('REASON_TEXT').value = rtnMap.REASON_TEXT ? rtnMap.REASON_TEXT : '';
		$('ASSIGN_NAME').innerHTML = rtnMap.ASSIGN_NAME ? rtnMap.ASSIGN_NAME : '';
		$('ASSIGN_DATE').innerHTML = rtnMap.REASSIGN_DATE ? rtnMap.REASSIGN_DATE : (rtnMap.ASSIGN_DATE ? rtnMap.ASSIGN_DATE : '');
	}

	return{                              
		initApp:function(){
		
			//PageUI.createPageWithAllBodySubElement("DSA30400" , "經手人專區" , "免鑑價之處理" , 1 , false);
			PageUI.createPage("DSA30400" , "經手人專區" , "免鑑價之處理", false);
			PageUI.loadin(["table_A","table_B"] ,1);
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				['validateMaxLength', '字數過長', function(v , node) { if(!v){return true;} return validation.checkInputLength(v, node.maxLength, node.fullLength, node.halfLength); }]
			]);
			
			//查詢
			$('btn_query').observe('click',function(event){
					doQuery();
				}
			);
			
			//確認
			$('btn_change').observe('click',function(event){
					doChange();
				}
			);
			
			buttonAuth();

			displayMessage();
			
			if('${param.APPLY_ID}'!=''){
				$('APPLY_ID').value = '${param.APPLY_ID}';
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
						<input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2 required" size="15" maxlength="11" value="">
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
                    <td class="tbBlue2" id="BORROW_NAME" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
                    <td  class="tbBlue" width="12%">受理進度</td>
                    <td  class="tbBlue2" id="APPLY_PROCESS_NM"></td>
				</tr>
                <tr>
                 	<td class="tbBlue">擔保品地址</td>
                 	<td class="tbBlue2" colspan="3" id="GAGE_ADDR" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
               	</tr>
                <tr>
                 	<td  class="tbBlue">徵信人員</td>
                 	<td  class="tbBlue2" id="CRED_NM"style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
                 	<td  class="tbBlue">聯絡電話</td>
                 	<td  class="tbBlue2" id="CRED_TEL"></td>
               	</tr>
               	<tr>
                	<td class="tbBlue">鑑價人員</td>
                 	<td class="tbBlue2" id="APPR_NM" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
                 	<td  class="tbBlue">聯絡電話</td>
                 	<td  class="tbBlue2" id="APPR_TEL"></td>
               	</tr>
               	<tr>
               		<td width="10%" height="22" class="tbYellow">是否鑑價</td>
               		<td width="37%" class="tbYellow2">
						<select name="IS_APPRAISAL" id="IS_APPRAISAL">
							<c:forEach var="map" items="${IS_APPRAISAL_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select>
					</td>
                    <td  class="tbYellow">輸入人員</td>
                    <td  class="tbYellow2" id="INPUT_NM" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
                </tr>
                <tr>
                    <td width="10%" height="22" class="tbYellow">免鑑價原因</td>
                    <td width="37%" class="tbYellow2">
						<select name="REASON" id="REASON">
							<c:forEach var="map" items="${REASON_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select>
					</td>
					<td  class="tbYellow">輸入日期</td>
					<td  class="tbYellow2" id="INPUT_DATE"></td>
				</tr>
				<tr>
					<td  class="tbYellow">免鑑價說明</td>
					<td  class="tbYellow2" colspan="3">
						<input id="REASON_TEXT" name="REASON_TEXT" type="text" class="textBox2 validateMaxLength" size="100" maxlength="100" value="">
					</td>
				</tr>
				<tr>
                    <td width="10%" height="22" class="tbYellow">派件人員</td>
                    <td width="37%" class="tbYellow2"  id="ASSIGN_NAME" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
                    <td  class="tbYellow">派件日期</td>
                    <td  class="tbYellow2" id="ASSIGN_DATE"></td>
                </tr>
			</table>
			</form>

</body>
<!-- InstanceEnd -->
</html>