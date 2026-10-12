<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC90200.jsp
作者：楊鈞傑
功能：理財型變更作業
完成：2013/05/02

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
Event.observe(window, "load", new DSC90200().initApp);
Event.observe(window, "resize", fix);
Event.observe(window, "scroll", fix);

function DSC90200(){
var rtnMap={};
	// 按鈕權限
	var buttonAuth = function(){
		var authButtons = {
			B0054 : 'btn_change',		<%--變更--%>		
			B0005 : 'btn_delete',		<%--刪除--%>
			B0070 : 'btn_confirm'		<%--覆核--%>
		};
		<dz:grantButtons FUNC_ID='DSC90200'/>
	};	
	
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
		new Ajax.Request( "<%=dispatcher%>/DSC9_0200/" + actionName,
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
		$w('BORROW_NAME BORROW_ID GAGE_ADDR LOAN_KIND_NM PREFER_TYPE_NM MM_STATUS_NM').each(
			function(ele){
				$(ele).update(resp.rtnMap[ele]||'');			
			}
		)
		//$('REVOLVE_AMT1').value = formatValue(resp.rtnMap.REVOLVE_AMT);//週轉型額度
		//$('REUSE_AMT1').value = formatValue(resp.rtnMap.REUSE_AMT);//回復型額度
		$('LOAN_DATE').innerHTML = Date.toROC(resp.rtnMap.LOAN_DATE); //貸放日期
		$('LIMIT_AMT').innerHTML = formatValue(resp.rtnMap.LIMIT_AMT); //放款值
		$('MM_AMT').innerHTML = formatValue(resp.rtnMap.MM_AMT); //理財型額度
		$('REMAIN_AMT').innerHTML = formatValue(resp.rtnMap.REMAIN_AMT); //已動撥額度
		$('REVOLVE_AMT').innerHTML = formatValue(resp.rtnMap.REVOLVE_AMT); //週轉型額度	
		$('REUSE_AMT').innerHTML = formatValue(resp.rtnMap.REUSE_AMT); //回復型額度
		$('MM_REMAIN').innerHTML = formatValue(resp.rtnMap.MM_REMAIN); //可動撥餘額
		$('LOAN_ID_OLD').value = resp.rtnMap.LOAN_ID;//查詢貸款帳號
	}	
	
	var buttons = {
		//查詢
		doQuery:function(){
									
			if(!valid1.validate()){ 
				return; 
			}	
			
			ajaxPost('query',{LOAN_ID:$F('LOAN_ID')},
				function(resp){
					dosuccessAction(resp);
					if("Y" == resp.rtnMap.UNCONFIRM){
						$('REVOLVE_AMT1').value = formatValue(resp.rtnMap.REVOLVE_AMT1);//週轉型額度
						$('REUSE_AMT1').value = formatValue(resp.rtnMap.REUSE_AMT1);//回復型額度								
						$('REVOLVE_AMT1').disabled=true;
						$('REUSE_AMT1').disabled=true;
					} else {
						$('REVOLVE_AMT1').value = formatValue(resp.rtnMap.REVOLVE_AMT);//週轉型額度
						$('REUSE_AMT1').value = formatValue(resp.rtnMap.REUSE_AMT);//回復型額度
						$('REVOLVE_AMT1').disabled=false;
						$('REUSE_AMT1').disabled=false;
					}					
				},
				function(resp){
					$('REVOLVE_AMT1').disabled=false;
					$('REUSE_AMT1').disabled=false;
					$('LOAN_ID_OLD').value = '';
				}
			);
		},
		
		//變更
		doChange:function(){
						
			if(!valid1.validate()){ 
				return; 
			}
			if($F('LOAN_ID') != $F('LOAN_ID_OLD')){
				alert("欲變更的"+$F('LOAN_ID')+"與原先查詢的"+$F('LOAN_ID_OLD')+"不同，無法作業，請重新查詢!");
				return;
			}			
			if( !$F('REVOLVE_AMT1') || !$F('REUSE_AMT1')){
				alert("請輸入週轉型額度及回復型額度再執行變更");
				return;	
			}
			
			//AJAX發送
			ajaxPost('change',{		
								LOAN_ID : $F('LOAN_ID'), 
								REVOLVE_AMT : $F('REVOLVE_AMT1'), 
								REUSE_AMT : $F('REUSE_AMT1')
							   },
				function(resp){
					dosuccessAction(resp);
					$('REVOLVE_AMT1').value = formatValue(resp.rtnMap.REVOLVE_AMT1);//週轉型額度
					$('REUSE_AMT1').value = formatValue(resp.rtnMap.REUSE_AMT1);//回復型額度								
					$('REVOLVE_AMT1').disabled=true;
					$('REUSE_AMT1').disabled=true;
				}
			);
		},
		//刪除
		doDelete:function(){
						
			if(!valid1.validate()){ 
				return; 
			}
			if($F('LOAN_ID') != $F('LOAN_ID_OLD')){
				alert("欲變更的"+$F('LOAN_ID')+"與原先查詢的"+$F('LOAN_ID_OLD')+"不同，無法作業，請重新查詢!");
				return;
			}
			
			rtnMap['LOAN_ID']=$F('LOAN_ID');
			rtnMap['REVOLVE_AMT']=$F('REVOLVE_AMT1');
			rtnMap['REUSE_AMT']=$F('REUSE_AMT1');							
			//AJAX發送
			ajaxPost('delete',{ 'info' : Object.toJSON(rtnMap), 'LOAN_ID' : $F('LOAN_ID') },
				function(resp){
					dosuccessAction(resp);
					$('REVOLVE_AMT1').value = formatValue(resp.rtnMap.REVOLVE_AMT);//週轉型額度
					$('REUSE_AMT1').value = formatValue(resp.rtnMap.REUSE_AMT);//回復型額度								
					$('REVOLVE_AMT1').disabled=false;
					$('REUSE_AMT1').disabled=false;			
				}
			);
			
		},

		
		//覆核
		doConfirm:function(){
						
			if(!valid1.validate()){ 
				return; 
			}
			if($F('LOAN_ID') != $F('LOAN_ID_OLD')){
				alert("欲變更的"+$F('LOAN_ID')+"與原先查詢的"+$F('LOAN_ID_OLD')+"不同，無法作業，請重新查詢!");
				return;
			}
			rtnMap['LOAN_ID']=$F('LOAN_ID');
			rtnMap['REVOLVE_AMT']=$F('REVOLVE_AMT1');
			rtnMap['REUSE_AMT']=$F('REUSE_AMT1');			
			//AJAX發送
			ajaxPost('confirm',{ 'info' : Object.toJSON(rtnMap), 'LOAN_ID' : $F('LOAN_ID') },
				function(resp){
					dosuccessAction(resp);
					$('REVOLVE_AMT1').value = formatValue(resp.rtnMap.REVOLVE_AMT);//週轉型額度
					$('REUSE_AMT1').value = formatValue(resp.rtnMap.REUSE_AMT);//回復型額度								
					$('REVOLVE_AMT1').disabled=false;
					$('REUSE_AMT1').disabled=false;						
				}
			);
		}
		
	};
	
	return {
		initApp : function() {			
			PageUI.createPageWithAllBodySubElement(
				"DSC90200",
				"理財型房貸",
				"理財型額度變更作業"
			);
			
			initValidation();//畫面檢核
			
			autoFormatToNumber();
			
			$("btn_query").observe('click', buttons.doQuery);
			$("btn_change").observe('click', buttons.doChange);
			$("btn_delete").observe('click', buttons.doDelete);
			$("btn_confirm").observe('click', buttons.doConfirm);

			buttonAuth();
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
			<input id="LOAN_ID_OLD" type="hidden">
			<input id="UNCONFIRM" type="hidden"/>
		</td>
		<td class="tbYellow2" align="center" width="10%">
			<input id="btn_query" type="button" class="button" value="查詢" />
		</td>
	</tr>
	<tr>
		<td colspan="3" align="center" >
			<input id="btn_change" type="button" class="button" value="變更" />
			<input id="btn_delete" type="button" class="button" value="刪除" /> 
			<input id="btn_confirm" type="button" class="button" value="覆核" />  
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<!-- B 區 -->
	<tr>
			<td class="tbYellow" width="15%">週轉型額度</td>
			<td class="tbYellow2" width="35%">
				<input id="REVOLVE_AMT1" type="text" class="textBox2" datatype ="number" size="20" />
			</td>
			<td class="tbYellow" width="15%">回復型額度</td>
			<td class="tbYellow2" width="35%">
				<input id="REUSE_AMT1" type="text" class="textBox2" datatype ="number" size="20" />
			</td>
	</tr>
	
	<!-- C 區 -->
	<tr>
			<td class="tbYellow" >姓名</td>
			<td class="tbYellow2">
				<%-- [20230324] 難字調整 --%>
				<span id='BORROW_NAME' style="font-family:'EUDC'"></span>
			</td>
			<td class="tbYellow" >預計配發日</td>
			<td class="tbYellow2">
				<span id='BORROW_ID'></span>
			</td>			
	</tr>
	<tr>
			<td class="tbYellow">擔保品地址</td>
			<td class="tbYellow2">
				<%-- [20230324] 難字調整 --%>
				<span id='GAGE_ADDR' style="font-family:'EUDC'"></span>
			</td>
			<td class="tbYellow">貸放日期</td>
			<td class="tbYellow2" >
				<span id='LOAN_DATE'></span>
			</td>			
	</tr>
	<tr>
			<td class="tbYellow">貸款種類</td>
			<td class="tbYellow2" >
				<span id='LOAN_KIND_NM'></span>
			</td>
			<td class="tbYellow">優惠種類</td>
			<td class="tbYellow2" >
				<span id='PREFER_TYPE_NM'></span>
			</td>			
	</tr>
	<tr>
			<td class="tbYellow">放款值</td>
			<td class="tbYellow2" colspan="3">
				<span id='LIMIT_AMT'></span>
			</td>	
	</tr>
	<tr>
			<td class="tbYellow">理財型額度</td>
			<td class="tbYellow2">
				<span id='MM_AMT'></span>
			</td>	
			<td class="tbYellow">已動撥額度</td>
			<td class="tbYellow2">
				<span id='REMAIN_AMT'></span>
			</td>			
	</tr>
	<tr>
			<td class="tbYellow">週轉型額度</td>
			<td class="tbYellow2">
				<span id='REVOLVE_AMT'></span>
			</td>
			<td class="tbYellow">回復型額度</td>
			<td class="tbYellow2">
				<span id='REUSE_AMT'></span>
			</td>			
	</tr>
	<tr>
			<td class="tbYellow textRed">可動撥餘額</td>
			<td class="tbYellow2">
				<span id='MM_REMAIN'></span>
			</td>	
			<td class="tbYellow">理財型契約狀態</td>
			<td class="tbYellow2">
				<span id='MM_STATUS_NM'></span>
			</td>			
	</tr>
</table>
</form>
</body>
</html>