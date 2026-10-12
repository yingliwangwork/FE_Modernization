<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSB30201.jsp
作者：王文進
功能：免鑑價之處理
完成：2012/03/14
-->
<html>
<head>
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%-- [20240607] 難字調整 --%>
<style type="text/css"> 
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSB30201().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB30201(){
	

	var buttonAuth = function (){
		var authButtons = {
			//B0054:"btn_change"<%--修改--%> 
		};
		<dz:grantButtons FUNC_ID="DSB30201" ignored="false"/>
	};	
	
	//查詢
	function doQuery(){
	
		LP_JSON = CSRUtil.getLP_JSON();
		
		var dataMap = {};
		dataMap.APPLY_ID = LP_JSON.APPLY_ID;
		dataMap.SEQ_NO = LP_JSON.SEQ_NO;
		dataMap.LOAN_ID = LP_JSON.LOAN_ID;
				
		var params = { inputMap:Object.toJSON(dataMap) };
		//成功
		var successActionOpen = function(resp){
			var rtnMap = resp.rtnMap ? resp.rtnMap:[];
			setViewData(rtnMap);
		};
		var errorActionOpen = function(resp){
			var rtnMap = [];
			setViewData(rtnMap);
		}; 
		ajaxPost('doQuery',params,successActionOpen,errorActionOpen);
	}
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSB3_0201/" + actionName,
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
		$('APPLY_ID').innerHTML = rtnMap.APPLY_ID ? rtnMap.APPLY_ID : '';
		$('SEQ_NO').innerHTML = rtnMap.SEQ_NO ? rtnMap.SEQ_NO : '';
		$('APPLY_DIV_NAME').innerHTML = rtnMap.APPLY_DIV_NAME ? rtnMap.APPLY_DIV_NAME : '';
		$('BORROW_NAME').innerHTML = rtnMap.BORROW_NAME ? rtnMap.BORROW_NAME : '';
		$('LOAN_ID').innerHTML = rtnMap.LOAN_ID ? rtnMap.LOAN_ID : '';
		var v1 = rtnMap.LOAN_KIND_NM ? rtnMap.LOAN_KIND_NM : '';
		var v2 = rtnMap.LOAN_TYPE_NM ? rtnMap.LOAN_TYPE_NM : '';
		$('LOAN_NM').innerHTML = v1+'/'+v2;
		$('PREFER_TYPE_NM').innerHTML = rtnMap.PREFER_TYPE_NM ? rtnMap.PREFER_TYPE_NM : '';
		var v3 = rtnMap.LOAN_PERIOD_YY ? rtnMap.LOAN_PERIOD_YY : '0';
		var v4 = rtnMap.LOAN_PERIOD_MM ? rtnMap.LOAN_PERIOD_MM : '0';
		$('LOAN_PERIOD').innerHTML = v3+'年'+v4+'月';
		$('AGREE_AMT').innerHTML = rtnMap.AGREE_AMT ? CSRUtil.$fmt(rtnMap.AGREE_AMT,'#,###') : '';
		$('FIREINSU_KIND_NM').innerHTML = rtnMap.FIREINSU_KIND_NM ? rtnMap.FIREINSU_KIND_NM : '';
		$('ISSUE_CODE_NM').innerHTML = rtnMap.ISSUE_CODE_NM ? rtnMap.ISSUE_CODE_NM : '';
		$('AGENT_ID').innerHTML = rtnMap.AGENT_ID ? rtnMap.AGENT_ID : '';
		$('AGENT_NAME').innerHTML = rtnMap.AGENT_NAME ? rtnMap.AGENT_NAME : '';
		$('AGENT_DEPT').innerHTML = rtnMap.AGENT_DEPT ? rtnMap.AGENT_DEPT : '';
		$('CRED_ID').innerHTML = rtnMap.CRED_ID ? rtnMap.CRED_ID : '';
		$('CRED_NAME').innerHTML = rtnMap.CRED_NAME ? rtnMap.CRED_NAME : '';
		$('CRED_DEPT').innerHTML = rtnMap.CRED_DEPT ? rtnMap.CRED_DEPT : '';
		$('FIREINSU_BEGDT').innerHTML = rtnMap.FIREINSU_BEGDT ? Date.toROC(rtnMap.FIREINSU_BEGDT) : '';
		$('FIREINSU_POLNO_OLD').innerHTML = rtnMap.FIREINSU_POLNO_OLD ? rtnMap.FIREINSU_POLNO_OLD : '';
		$('FIREINSU_ENDDT').innerHTML = rtnMap.FIREINSU_ENDDT ? Date.toROC(rtnMap.FIREINSU_ENDDT) : '';
		$('FIREINSU_POLNO').innerHTML = rtnMap.FIREINSU_POLNO ? rtnMap.FIREINSU_POLNO : '';
		$('FIREINSU_COMPANY_NM').innerHTML = rtnMap.FIREINSU_COMPANY_NM ? rtnMap.FIREINSU_COMPANY_NM : '';
		var v5 = rtnMap.FIREINSU_YY ? rtnMap.FIREINSU_YY : '0';
		var v6 = rtnMap.FIREINSU_MM ? rtnMap.FIREINSU_MM : '0';
		$('FIREINSU_PERIOD').innerHTML = v5+'年'+v6+'月';
		$('FIREINSU_AMT').innerHTML = rtnMap.FIREINSU_AMT ? CSRUtil.$fmt(rtnMap.FIREINSU_AMT,'#,###') : '';
		$('EARTH_AMT').innerHTML = rtnMap.EARTH_AMT ? CSRUtil.$fmt(rtnMap.EARTH_AMT,'#,###') : '';
		$('BORROW_NAME1').innerHTML = rtnMap.BORROW_NAME ? rtnMap.BORROW_NAME : '';
		$('GAGE_ZIP').innerHTML = rtnMap.GAGE_ZIP ? rtnMap.GAGE_ZIP : '';
		$('MATERIAL_NM').innerHTML = rtnMap.MATERIAL_NM ? rtnMap.MATERIAL_NM : '';
		$('FLOOR').innerHTML = rtnMap.FLOOR ? rtnMap.FLOOR : '';
		$('GAGE_ADDR').innerHTML = rtnMap.GAGE_ADDR ? rtnMap.GAGE_ADDR : '';
		$('OWNER_ID').innerHTML = rtnMap.OWNER_ID ? rtnMap.OWNER_ID : '';
		$('OWNER_NAME').innerHTML = rtnMap.OWNER_NAME ? rtnMap.OWNER_NAME : '';
	}

	return{                              
		initApp:function(){
		
			PageUI.createPageWithAllBodySubElement("DSB30201" , "火險作業" , "火險資料明細作業" , 1 , false);
			
			//查詢
			doQuery();
			
			//上一頁		
			$("btn_back").observe('click',function(event){
					CSRUtil.linkBack();
	 			}
			);
			
			buttonAuth();

			displayMessage();

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >

		
<!------------------------ A區--------------------->	
			<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<!------------------------ B區--------------------->											
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td class="tbYellow" width="12%">
						受理編號
					</td>
					<td class="tbYellow2" id="APPLY_ID">
					</td>
					<td class="tbYellow" width="12%">
						序號
					</td>
					<td class="tbYellow2" id="SEQ_NO">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						受理單位
					</td>
					<td class="tbYellow2" colspan="3" id="APPLY_DIV_NAME">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						借款人(要保人)
					</td>
					<td class="tbYellow2" id="BORROW_NAME">
					</td>
					<td class="tbYellow" width="12%">
						貸款帳號
					</td>
					<td class="tbYellow2" id="LOAN_ID">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						貸款種類/類別
					</td>
					<td class="tbYellow2" id="LOAN_NM">
					</td>
					<td class="tbYellow" width="12%">
						優惠種類
					</td>
					<td class="tbYellow2" id="PREFER_TYPE_NM">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						核准年期
					</td>
					<td class="tbYellow2" id="LOAN_PERIOD">
					</td>
					<td class="tbYellow" width="12%">
						核准金額(萬元)
					</td>
					<td class="tbYellow2" id="AGREE_AMT">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						保單種類
					</td>
					<td class="tbYellow2" id="FIREINSU_KIND_NM">
					</td>
					<td class="tbYellow" width="12%">
						出單狀況
					</td>
					<td class="tbYellow2" id="ISSUE_CODE_NM">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						經手人員ID
					</td>
					<td class="tbYellow2" id="AGENT_ID">
					</td>
					<td class="tbYellow" width="12%">
						經手人員姓名
					</td>
					<td class="tbYellow2" id="AGENT_NAME">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						經手人單位代號
					</td>
					<td class="tbYellow2" id="AGENT_DEPT">
					</td>
					<td class="tbYellow" width="12%">
						承辦人員ID
					</td>
					<td class="tbYellow2" id="CRED_ID">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						承辦人員姓名
					</td>
					<td class="tbYellow2" id="CRED_NAME">
					</td>
					<td class="tbYellow" width="12%">
						承辦人單位代號
					</td>
					<td class="tbYellow2" id="CRED_DEPT">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						火險起日
					</td>
					<td class="tbYellow2" id="FIREINSU_BEGDT">
					</td>
					<td class="tbYellow" width="12%">
						原保單號碼
					</td>
					<td class="tbYellow2" id="FIREINSU_POLNO_OLD">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						火險迄日
					</td>
					<td class="tbYellow2" id="FIREINSU_ENDDT">
					</td>
					<td class="tbYellow" width="12%">
						保單號碼
					</td>
					<td class="tbYellow2" id="FIREINSU_POLNO">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						投保公司
					</td>
					<td class="tbYellow2" id="FIREINSU_COMPANY_NM">
					</td>
					<td class="tbYellow" width="12%">
						火險年期
					</td>
					<td class="tbYellow2" id="FIREINSU_PERIOD">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="12%">
						火險保額(萬元)
					</td>
					<td class="tbYellow2" id="FIREINSU_AMT">
					</td>
					<td class="tbYellow" width="12%">
						地震險保額(萬元)
					</td>
					<td class="tbYellow2" id="EARTH_AMT">
					</td>
				</tr>
				<tr>
					<td class="tbBlue" colspan="4">
						擔保品資訊 
					</td>
				</tr>
				<tr>
					<td class="tbBlue" width="12%">
						要保人(借款人)
					</td>
					<td class="tbBlue2" id="BORROW_NAME1">
					</td>
					<td class="tbBlue" width="12%">
						區域代碼
					</td>
					<td class="tbBlue2" id="GAGE_ZIP">
					</td>
				</tr>
				<tr>
					<td class="tbBlue" width="12%">
						建築結構
					</td>
					<td class="tbBlue2" id="MATERIAL_NM">
					</td>
					<td class="tbBlue" width="12%">
						樓層
					</td>
					<td class="tbBlue2" id="FLOOR">
					</td>
				</tr>
				<tr>
					<td class="tbBlue" width="12%">
						保險標的
					</td>
					<td class="tbBlue2" colspan="3" id="GAGE_ADDR">
					</td>
				</tr>
				<tr>
					<td class="tbBlue" width="12%">
						被保險人ID
					</td>
					<td class="tbBlue2" id="OWNER_ID">
					</td>
					<td class="tbBlue" width="12%">
						被保險人姓名
					</td>
					<td class="tbBlue2" id="OWNER_NAME">
					</td>
				</tr>
				<tr>
					<td colspan="4" align="center">
						<input name="LP_JSON" id="LP_JSON" type="hidden" value="${LP_JSON}" >
						<input type="button" name="btn_back" id="btn_back" class="button" value="上一頁" />
					</td>
				</tr>
			</table>
			</form>

</body>
<!-- InstanceEnd -->
</html>