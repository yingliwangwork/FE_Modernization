<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC31310.jsp
作者：林秉宏
功能：房貸扣薪不足明細
完成：2018/07/17
更新：
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">
<title></title>

<%--共用定義的javaScript--%>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>

<script type="text/JavaScript">

// 產生畫面物件
var DSC31310 = new DSC31310();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
Event.observe(window, 'load', DSC31310.initApp);

function DSC31310(){
	
	<%--建立 ajax request 物件--%>
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC3_1310/');
    
    <%--條件map--%>
	var reqMap = <c:out value = "${reqMap}" default = "{}" escapeXml = "false" />;
    
	var grid;
    
    var actions = {
    
    	<%--查詢--%>
		doQuery : function(){	
		
			ajaxRequest.post( 'query' , { reqMap : Object.toJSON(reqMap) },
				function(resp){		
					var empMap = resp.empMap || {};
					$('BORROW_ID').update(empMap.BORROW_ID || '');
					$('BORROW_NAME').update(empMap.BORROW_NAME || '');
					$('DIV_NAME').update(empMap.DIV_NAME || '');
					$('WORK_YM').update(empMap.WORK_YM || '');
					$('HODIV_NAME').update(resp.HODivName || '');
					grid.load(resp.c452List || [], resp.totalList || []);				
				},
				function(resp){	
					$('BORROW_ID').update('');
					$('BORROW_NAME').update('');
					$('DIV_NAME').update('');
					$('WORK_YM').update('');
					$('HODIV_NAME').update('');
					grid.load([]);	
				}
			);
		}
    };
 
    return {
		
		initApp : function() {
		
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay'/>

			PageUI.createPageWithAllBodySubElement("DSC31310", "扣薪作業", "房貸扣薪不足明細");
			
			grid = new TableUI(
				{	
					table:$("grid"), pageSize:10, allSortable:false, overDiv:true,
					column:[			
						{header:"貸款帳號",key:"LOAN_ID"},
						{header:"期數",key:"PAY_TERM"},	
						{header:"應繳日", key:"DUTY_PAYDT", sortRule:"date"},
						{header:"應繳金額 (=A+B+C-D)",key:"DUTY_PAYMT", sortRule:"number"},	
						{header:"本金 (A)",key:"PRINCIPAL", sortRule:"number"},	
						{header:"利息 (B)",key:"INTEREST", sortRule:"number"},	
						{header:"管理費用 (C)",key:"LAWSUIT_FEE", sortRule:"number"},	
						{header:"上期結餘 (D)",key:"LAST_BALANCE", sortRule:"number"},	
						{header:"寬限日", key:"DEADLINE_DATE", sortRule:"date"},	
						{header:"匯款行庫",key:"ACNT_BANK", render:function(val,rec){
							return '國泰世華 013';
						}},
						{header:"ATM匯款帳號",key:"ACCOUNT_NO"}
					]				
				}
			);	
			
			actions.doQuery();	
		
			//回上一頁
			$('BTN_back').observe('click', function(event){								
				history.back();		
			});	
			
			PageUI.resize();
			displayMessage();
		}		
	};
}

</script>
</head>
<body>
<form id="form1" name="form1">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">
				員工ID
			</td>
			<td class="tbYellow2" width="30%">
				<span id="BORROW_ID"></span>　
				<span id="BORROW_NAME"></span>
			</td>
			<td class="tbYellow" width="10%">
				單位
			</td>
			<td class="tbYellow2" width="20%">
				<span id="DIV_NAME"></span>
			</td>
			<td class="tbYellow" width="10%">
				扣薪年月
			</td>
			<td class="tbYellow2" width="20%">
				<span id="WORK_YM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" width="85%" colspan="6">
				請於寬限日前繳費，逾期繳納將依約收取延滯息與違約金。<br>
				負責作業單位：
				<span id="HODIV_NAME"></span>
			</td>
		</tr>
		<tr>
			<td  class="tbYellow2" align="center" colspan="6"><table id='grid' width="100%"></table></td>
		</tr>
		<tr>
			<td class="tbYellow2" align="center" colspan="6">
				<input id = "BTN_back" type = "button" class = "button" value = "回上一頁"/>		
			</td>
		</tr>
	</table>
</form>
</body>
</html>