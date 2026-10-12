<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC31320.jsp
作者：林秉宏
功能：房貸扣繳記錄明細
完成：2018/07/18
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
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>

<script type="text/JavaScript">

// 產生畫面物件
var DSC31320 = new DSC31320();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
Event.observe(window, 'load', DSC31320.initApp);

function DSC31320(){
	
	<%--建立 ajax request 物件--%>
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC3_1320/');
    
    <%--條件map--%>
	var reqMap = <c:out value = "${reqMap}" default = "{}" escapeXml = "false" />;
    
	var grid;
    
    var actions = {
    
    	<%--查詢--%>
		doQuery : function(){	
		
			ajaxRequest.post( 'query' , { reqMap : Object.toJSON(reqMap) },
				function(resp){		
					grid.load(resp.rtnList || []);				
				},
				function(resp){	
					grid.load([]);	
				}
			);
		}
    };
 
    return {
		
		initApp : function() {
		
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay'/>

			PageUI.createPageWithAllBodySubElement("DSC31320", "扣薪作業", "房貸扣繳記錄明細");
			
			grid = new TableUI(
				{	
					table:$("grid"), pageSize:10, allSortable:false, overDiv:true, split: ['BORROW_NAME'],
					column:[			
						{header:"貸款帳號", key:"LOAN_ID"},
						{header:"期數",key:"PAY_TERM"},	
						{header:"應繳日", key:"DUTY_PAYDT", sortRule:"date"},
						{header:"實繳日", key:"REAL_PAYDT", sortRule:"date"},
						{header:"本金",key:"PRINCIPAL", sortRule:"number"},
						{header:"利息",key:"TOT_INT", sortRule:"number"},
						{header:"延滯息",key:"DELAY_INT", sortRule:"number"},
						{header:"違約金",key:"RENEGE", sortRule:"number"},
						{header:"借款人姓名", key:"BORROW_NAME"},
						{header:"災戶攤繳利息",key:"VICTIM_INT", sortRule:"number"},
						{header:"管理費用",key:"LAWSUIT_FEE", sortRule:"number"},	
					
						{header:"上期結餘",key:"LAST_BALANCE", sortRule:"number"},	
						{header:"本期結餘",key:"THIS_BALANCE", sortRule:"number"},	
						{header:"本期利率",key:"RATE", sortRule:"number"},	
						{header:"下期應繳",key:"NDUTY_PAYMT", sortRule:"number"},	
						{header:"繳款後本金餘額",key:"REMAIN_AMT", sortRule:"number"}
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
<table id='grid' width="100%"></table>	
<form id="form1" name="form1">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow1" align="center">
				<input id = "BTN_back" type = "button" class = "button" value = "回上一頁"/>		
			</td>
		</tr>
	</table>
</form>
</body>
</html>