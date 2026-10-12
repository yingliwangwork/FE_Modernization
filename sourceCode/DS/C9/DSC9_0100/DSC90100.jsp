<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC90100.jsp
作者：楊鈞傑
功能：理財型變更作業
完成：2013/04/23

[20230324]
難字調整
高強禾
-->

<html> 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/javascript" src="<%=htmlBase%>/CM/js/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>

<%-- [20230324] 難字調整 --%>
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

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, "load", new DSC90100().initApp);
Event.observe(window, "resize", fix);
Event.observe(window, "scroll", fix);

function DSC90100(){
	
	var valid1;
	
	function initValidation() {
		Validation.addAllThese([		
			[ 'validateLOAN_IDLength',  '貸款帳號長度不正確 需為10碼', 
			//檢核貸款帳號長度
			function(v){
				if(v!==""){
					return v.length === 10 ? true : false;
				}
				return true;
			}]	
		]);
		
		valid1 = new Validation( 'form', { focusOnError: false, useTitles: false } );
		valid1.define('required' , [{ id : "LOAN_ID" , errMsg:'請輸入貸款帳號再執行查詢作業'}] );
		valid1.define('validateLOAN_IDLength' , { id: "LOAN_ID"} );
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC9_0100/" + actionName,
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

	//數字欄位格式
	function formatValue(val){
		return (val || val === 0) ? CSRUtil.$fmt(val,'#,##0.##########'):'';
	}
	
	//查詢後欄位設置
	function dosuccessAction(resp){
		
		$w('BORROW_NAME BORROW_ID GAGE_ADDR LOAN_KIND_NM PREFER_TYPE_NM MM_ACCOUNT MM_STATUS_NM').each(
			function(ele){
				$(ele).update(resp.rtnMap[ele]||'');
			}
		)
		$('REMIT_ACCOUNT').innerHTML = resp.rtnMap.REMIT_ACCOUNT1 + '-' + resp.rtnMap.REMIT_ACCOUNT2 + '-' + resp.rtnMap.REMIT_ACCOUNT3;
		$('LOAN_DATE').innerHTML = Date.toROC(resp.rtnMap.LOAN_DATE);
		$('LIMIT_AMT').innerHTML = formatValue(resp.rtnMap.LIMIT_AMT);
		$('REVOLVE_AMT').innerHTML = formatValue(resp.rtnMap.REVOLVE_AMT);
	}	
	
	var buttons = {
		//查詢
		doQuery:function(event){
		
			$('LOAN_ID').value = $('LOAN_ID').value.toUpperCase();
			
			valid1.reset();
			
			if(!valid1.validate()){ 
				return; 
			}	
			
			ajaxPost('query',{LOAN_ID:$F('LOAN_ID')},
				function(resp){
					dosuccessAction(resp);
				}
			);
		},
		
		//變更
		doChange:function(event){
		
			//畫面程序檢核
			if( !$('CHG_1').checked && !$('CHG_2').checked){
				alert("請選擇變更理財連結帳號或動撥指定帳號");
				return;
			}
			
			if($('CHG_1').checked && !$F('MM_ACCOUNT_2')){
				alert("請輸入欲變更的理財連結帳號再執行變更");
				return;
			}
			
			if($('CHG_1').checked && !$F('CHG_TYPE')){
				alert("請選擇變更種類再執行變更");
				return;
			}
			
			if($('CHG_2').checked){
				if(!$F('REMIT_ACCOUNT_1') || !$F('REMIT_ACCOUNT_2') || !$F('REMIT_ACCOUNT_3')){
					alert("請輸入欲變更的動撥指定帳號再執行變更");
					return;
				}
			}
			
			
			var CHG = $$('input:checked[type=radio]')[0].value;
			
			//AJAX發送
			ajaxPost('change',{		
								LOAN_ID : $F('LOAN_ID'), 
								CHG : CHG , 
								CHG_TYPE : $F('CHG_TYPE') ,
								MM_ACCOUNT : $F('MM_ACCOUNT_2'), 
								REMIT_ACCOUNT1 : $F('REMIT_ACCOUNT_1'), 
								REMIT_ACCOUNT2 : $F('REMIT_ACCOUNT_2'), 
								REMIT_ACCOUNT3 : $F('REMIT_ACCOUNT_3')
							   },
				function(resp){
					dosuccessAction(resp);
				}
			);
		}
		//2018-12-20暫停、暫停回復不需要更新理財連結帳號
		,doChangeCHG_TYPE :function(event){
			if($F('CHG_TYPE') == '3' || $F('CHG_TYPE') == '4'){
				$('MM_ACCOUNT_2').value = $('MM_ACCOUNT').innerHTML || '';
				$('MM_ACCOUNT_2').disable();
			} else {
				if($F('CHG_TYPE') == '2'){
					$('MM_ACCOUNT_2').value = $('MM_ACCOUNT').innerHTML || '';				
				} else {				
					$('MM_ACCOUNT_2').value = "";
				}
				$('MM_ACCOUNT_2').enable();			
			}		
		}
	};
	
	return {
		initApp : function() {			
			PageUI.createPageWithAllBodySubElement(
				"DSC90100",
				"理財型房貸",
				"理財型變更作業"
			);
			
			initValidation();//畫面檢核
			
			$("btn_query").observe('click', buttons.doQuery);
			$("btn_change").observe('click', buttons.doChange);
			
			$('CHG_TYPE').observe('change',buttons.doChangeCHG_TYPE);//變更項目連動

			PageUI.resize();
			displayMessage();
		}
	};	
};

</script>
</head>
<body>		
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<!-- A 區 -->
	<tr>
		<td class="tbYellow" width="15%" align="left">貸款帳號</td>
		<td class="tbYellow2" width="75%">
			<input id="LOAN_ID" type="text" class="textBox2" size="12" maxlength="11" onkeyup="this.value=this.value.toLocaleUpperCase()"/>
		</td>
		<td class="tbYellow2" width="10%" align="center">
			<input id="btn_query" type="button" class="button" value="查詢" />
		</td>
	</tr>
	<tr>
		<td colspan="3" align="center" >
			<input id="btn_change" type="button" class="button" value="變更" /> 
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<!-- B 區 -->
	<tr>
		<td class="tbYellow" width="15%">理財連結帳號</td>
		<td class="tbYellow" width="5%">						
				<input type="radio" id="CHG_1" name="CHG" value='1' checked>
		</td>
		<td class="tbYellow2" width="80%" colspan="3">
			<select id="CHG_TYPE" class="textBox2">
				<option value="">請選擇</option>
				<c:forEach var="map" items="${CHG_TYPE_LIST}" >
					<option value = "${map.key}" > ${map.value}</option>
				</c:forEach>
			</select>
			<input id="MM_ACCOUNT_2" type="text" class="textBox2" size="20"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="15%">動撥指定帳號</td>
		<td class="tbYellow" width="5%">						
				<input type="radio" id="CHG_2" name="CHG" value='2'>
		</td>
		<td class="tbYellow2" width="80%" colspan="3">
			<input id="REMIT_ACCOUNT_1" type="text" class="textBox2" size="5"/>-
			<input id="REMIT_ACCOUNT_2" type="text" class="textBox2" size="6"/>-
			<input id="REMIT_ACCOUNT_3" type="text" class="textBox2" size="12"/>
		</td>
	</tr>
	
	<!-- C 區 -->
	<tr>
		<td class="tbYellow" width="15%">姓名</td>
		<td class="tbYellow2" width="35%" colspan="2">
			<%-- [20230324] 難字調整 --%>
			<span id='BORROW_NAME' style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow" width="15%">身分證字號</td>
		<td class="tbYellow2" width="35%">
			<span id='BORROW_ID'></span>
		</td>			
	</tr>
	<tr>
		<td class="tbYellow">擔保品地址</td>
		<td class="tbYellow2" colspan="2">
			<%-- [20230324] 難字調整 --%>
			<span id='GAGE_ADDR' style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow">貸放日期</td>
		<td class="tbYellow2">
			<span id='LOAN_DATE'></span>
		</td>			
	</tr>
	<tr>
		<td class="tbYellow">貸款種類</td>
		<td class="tbYellow2" colspan="2">
			<span id='LOAN_KIND_NM'></span>
		</td>
		<td class="tbYellow">優惠種類</td>
		<td class="tbYellow2">
			<span id='PREFER_TYPE_NM'></span>
		</td>			
	</tr>
	<tr>
		<td class="tbYellow">放款值</td>
		<td class="tbYellow2" colspan="2">
			<span id='LIMIT_AMT'></span>
		</td>
		<td class="tbYellow">週轉型核准金額</td>
		<td class="tbYellow2">
			<span id='REVOLVE_AMT'></span>
		</td>			
	</tr>
	<tr>
		<td class="tbYellow">理財連結帳號</td>
		<td class="tbYellow2" colspan="2">
			<span id='MM_ACCOUNT'></span>
		</td>
		<td class="tbYellow">理財型契約狀態</td>
		<td class="tbYellow2">
			<span id='MM_STATUS_NM'></span>
		</td>			
	</tr>
	<tr>
		<td class="tbYellow">動撥指定帳號</td>
		<td class="tbYellow2" colspan="4">
			<span id='REMIT_ACCOUNT'></span>
		</td>		
	</tr>
</table>

</form>
</body>
</html>