<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSA20503.jsp
功能：財報分析作業
作者：郭純亨
完成：2020.09.09
-->

<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--匯入外部Javascript 與 css-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>

<script type='text/javascript'>
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSA20503().initApp);

function DSA20503(){
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA2_0503/');
	var isReQuery;
	
	
	var actions = {
		<%--產生Table3--%>
		genTable3 : function(rtnList){
			$w('table2 table3').each(function(tableid){
				$(tableid).style.display = '';
			});
			
			if (isReQuery) {
				$$('td.tdclass').each(function(ele){$(ele).remove()});
			}
			
			$('table3_head').colSpan = 3+rtnList.length;
			
			$$('tr.colTr').each(function(tr){
				var colName = tr.getAttribute('colname');
				var isPercent = ('percent'==tr.getAttribute('datatype'));
				for (var j=0; j<rtnList.length; j++) {
					var ACNT_YEAR = rtnList[j]['ACNT_YEAR'];
					var tmptd = new Element("td", { 'class': 'tdclass' });
					tmptd.setAttribute("align", "center");
					if (j%2 == 0) {
						tmptd.addClassName("tbBlue2");
					} else {
						tmptd.addClassName("tbBlue3");
					}
					
					var updateValue = rtnList[j][colName];
					var elemid = colName+'_'+j;
					var tmpspan = new Element("span");
					tmpspan.setAttribute('rowNo',j);
					tmpspan.setAttribute('id',elemid);
					tmpspan.setAttribute('name',colName);
					tmpspan.setAttribute('ACNT_YEAR',ACNT_YEAR||'');
					if('ACNT_YEAR'==colName){
						tmpspan.update(localeDisplay.formatDate(updateValue));
						tmpspan.setAttribute("style", "font-weight:bold;");
					}else{
						tmpspan.update(localeDisplay.formatNumber(updateValue) + 
								((updateValue && '無法計算'!=updateValue && isPercent) ? " %" : ""));
						<%--流動比率顯示欄位，數字若<100%，則紅字粗體--%>
						if ('CURRENT_RATIO'== colName && parseFloat(updateValue) < 100) {
							tmpspan.setAttribute("style", "color:red; font-weight:bold;");
						}
						<%--營業現金流佔稅後淨利比率顯示欄位，數字若<50%，則紅字粗體--%>
						else if ('CFO_RATIO'== colName && parseFloat(updateValue) < 50) {
							tmpspan.setAttribute("style", "color:red; font-weight:bold;");
						}
						<%--負債比率顯示欄位，數字若>=60%，則紅字粗體--%>
						else if ('DEBT_RATIO'== colName && parseFloat(updateValue) >= 60) {
							tmpspan.setAttribute("style", "color:red; font-weight:bold;");
						}
						<%--長短期金融負債比顯示欄位，數字若>=40%，則紅字粗體--%>
						else if ('LSTFL_RATIO'== colName && parseFloat(updateValue) >= 40) {
							tmpspan.setAttribute("style", "color:red; font-weight:bold;");
						}
						<%--長期資金佔固定資產比率顯示欄位，數字若<100%，則紅字粗體--%>
						else if ('LTCA_RATIO'== colName && parseFloat(updateValue) < 100) {
							tmpspan.setAttribute("style", "color:red; font-weight:bold;");
						}
						<%--【C區】若顯示欄位(數字或百分比)為負值，以-XX,XXX顯示--%>
						else if (parseFloat(updateValue) < 0) {
							tmpspan.setAttribute("style", "color:red; font-weight:bold;");
						}
					}
					tmptd.appendChild(tmpspan);
					tr.appendChild(tmptd);
				}
			});
			isReQuery = true;
		}
	}
	
	var buttons = {
		<%--查詢--%>
		doQuery : function(){

			//保留參數管理-更新受理編號
			CSRUtil.keepParamsManager.put({'APPLY_ID': $F('APPLY_ID')});
			
			<%--ajax--%>
			ajaxRequest.post('query', {reqMap : Object.toJSON({APPLY_ID : $F('APPLY_ID'), ID : $F('ID')})},
				function(resp) {
					<%--查詢成功--%>
					$('ID').setValue(resp.ID);
					$('SUMMARY').update(resp.SUMMARY);
					var rtnList = resp.rtnList || [];
					actions.genTable3(rtnList);
				},
				function(resp) {
					$('ID').setValue("");
					$('SUMMARY').update("");
					$w('table2 table3').each(function(tableid){
						$(tableid).style.display = 'none';
					});
					$$('td.tdclass').each(function(ele){$(ele).remove()});
					
				}
			);
		}	
	}
	
	return {
	
		initApp : function() {
			
			PageUI.createPageWithAllBodySubElement( 'DSA20503', '核貸作業', '財報分析作業' );
			
			window.localeDisplay = new LocaleDisplay({
			    locale:'Y2K'            //地區代碼
			});
			
			<%--註冊事件--%>
			$('btn_query').observe('click', buttons.doQuery);
			isReQuery = false;
			
			<%--受理編號、統一編號接值--%>
			if('${APPLY_ID}'){
				$('APPLY_ID').setValue('${APPLY_ID}');
			}else if(CSRUtil.keepParamsManager.get('APPLY_ID')){
				<%--保留參數管理-取得受理編號--%>
				$('APPLY_ID').setValue(CSRUtil.keepParamsManager.get('APPLY_ID'));
			}
			$('ID').update('${ID}');
			if($F('APPLY_ID') || $F('ID')){//預設查詢
				buttons.doQuery();
			}
			
			displayMessage();		
		}	
	};	
}	
	
</script>
</head>
<body>
	<form name='form1' id='form1'>
		<table id='table1' class="tbBox2" width="100%" border="0" cellpadding="0" cellspacing="1">
			<tr>
				<td class="tbYellow" align="center" width="20%">受理編號</td>
				<td class="tbYellow2" align="center" width="25%">
					<input id="APPLY_ID" type="text" class="textBox2" maxlength="11" size="15"/>
				</td>
				<td class="tbYellow" align="center" width="20%">統一編號</td>
				<td class="tbYellow2" align="center" width="25%">
					<input id="ID" type="text" class="textBox2" maxlength="8" size="12"/>
				</td>
				<td class="tbYellow" align="center" width="10%">
					<button id="btn_query" type="button" class="button" title="查詢">查詢</button>
				</td>
			</tr>
		</table>
		<table id="table2" style="display: none;" class="tbBox2" width="100%" border="0" cellpadding="0" cellspacing="1">
			<tr>
				<td colspan="5" class="tbYellow0" align="center"><b>財報摘要</b></td>
			</tr>
			<tr>
				<td colspan="5" class="tbYellow2">
					<span id="SUMMARY"></span>
				</td>
			</tr>
		</table>
		<table id='table3' style="display: none;" class="tbBox2" width="100%" border="0" cellpadding="0" cellspacing="1">
			<tr>
				<td id="table3_head" class="tbYellow0" align="center"><b>企業貸款戶財報比率分析項目</b></td>
			</tr>
			<tr class="colTr" colname="ACNT_YEAR">
				<td class="tbYellow" align="center" width="10%"><b>項目</b></td>
				<td class="tbYellow" align="center" width="20%"><b>財務比率</b></td>
				<td class="tbYellow" align="center" width="20%"><b>計算公式</b></td>
			</tr>
			<tr class="colTr" colname="CURRENT_RATIO" datatype="percent">
				<td rowspan="5" class="tbYellow" align="center">償債能力分析</td>
				<td class="tbYellow" align="center">流動比率(至少100%以上↗)</td>
				<td class="tbYellow" align="center">流動資產÷流動負債</td>
			</tr>	
			<tr class="colTr" colname="QUICK_RATIO" datatype="percent">	
				<td class="tbYellow" align="center">速動比率</td>
				<td class="tbYellow" align="center">速動資產÷流動負債</td>
			</tr>	
			<tr class="colTr" colname="CF_RATIO" datatype="percent">	
				<td class="tbYellow" align="center">現金流量比率↗</td>
				<td class="tbYellow" align="center">營業活動淨現金流量÷流動負債</td>
			</tr>	
			<tr class="colTr" colname="CFO_RATIO" datatype="percent">	
				<td class="tbYellow" align="center">營業現金流佔稅後淨利比率(50%↗)</td>
				<td class="tbYellow" align="center">營業現金流入÷稅後淨利</td>
			</tr>	
			<tr class="colTr" colname="TINT_RATIO">	
				<td class="tbYellow" align="center">利息保障倍數↗</td>
				<td class="tbYellow" align="center">稅前息前淨利÷利息費用</td>
			</tr>
			<tr class="colTr" colname="REC_RATIO">
				<td rowspan="6" class="tbYellow" align="center">經營效能分析</td>
				<td class="tbYellow" align="center">應收帳款週轉率↗</td>
				<td class="tbYellow" align="center">營業收入÷應收帳款及票據</td>
			</tr>
			<tr class="colTr" colname="REC_DAYS">
				<td class="tbYellow" align="center">應收帳款週轉天數↘</td>
				<td class="tbYellow" align="center">365÷應收帳款週轉率</td>
			</tr>
			<tr class="colTr" colname="INV_RATIO">
				<td class="tbYellow" align="center">存貨週轉率↗</td>
				<td class="tbYellow" align="center">營業成本÷存貨</td>
			</tr>
			<tr class="colTr" colname="INV_DAYS">
				<td class="tbYellow" align="center">存貨週轉天數↘</td>
				<td class="tbYellow" align="center">365÷存貨週轉率</td>
			</tr>
			<tr class="colTr" colname="FIX_RATIO">
				<td class="tbYellow" align="center">固定資產週轉率↗</td>
				<td class="tbYellow" align="center">營業收入÷固定資產</td>
			</tr>
			<tr class="colTr" colname="TOT_TURN_RATIO">
				<td class="tbYellow" align="center">總資產週轉率↗</td>
				<td class="tbYellow" align="center">營業收入÷資產總額</td>
			</tr>
			<tr class="colTr" colname="DEBT_RATIO" datatype="percent">
				<td rowspan="5" class="tbYellow" align="center">財務結構分析</td>
				<td class="tbYellow" align="center">負債比率(60%以下↘)</td>
				<td class="tbYellow" align="center">負債總額÷資產總額</td>
			</tr>
			<tr class="colTr" colname="LSTFL_RATIO" datatype="percent">
				<td class="tbYellow" align="center">長短期金融負債比(40%以下↘)</td>
				<td class="tbYellow" align="center">長短期金融負債÷資產總額</td>
			</tr>
			<tr class="colTr" colname="EQUITY_RATIO" datatype="percent">
				<td class="tbYellow" align="center">權益比率↗</td>
				<td class="tbYellow" align="center">權益總額÷資產總額</td>
			</tr>
			<tr class="colTr" colname="LTCA_RATIO" datatype="percent">
				<td class="tbYellow" align="center">長期資金佔固定資產比率(100%以上↗)</td>
				<td class="tbYellow" align="center">(非流動負債+權益總和)÷不動產、廠房及設備</td>
			</tr>
			<tr class="colTr" colname="LTCTA_RATIO" datatype="percent">
				<td class="tbYellow" align="center">長期投資佔總資產比率</td>
				<td class="tbYellow" align="center">長期投資÷資產總額</td>
			</tr>
			<tr class="colTr" colname="GROM_RATIO" datatype="percent">
				<td rowspan="5" class="tbYellow" align="center">獲利能力分析</td>
				<td class="tbYellow" align="center">毛利率↗</td>
				<td class="tbYellow" align="center">營業毛利÷營業收入</td>
			</tr>
			<tr class="colTr" colname="CAPT_RATIO" datatype="percent">
				<td class="tbYellow" align="center">營業利益率↗</td>
				<td class="tbYellow" align="center">營業淨利÷營業收入</td>
			</tr>
			<tr class="colTr" colname="PROM_RATIO" datatype="percent">
				<td class="tbYellow" align="center">淨利率↗</td>
				<td class="tbYellow" align="center">本期淨利÷營業收入</td>
			</tr>
			<tr class="colTr" colname="RETE_RATIO" datatype="percent">
				<td class="tbYellow" align="center">股東權益報酬率↗</td>
				<td class="tbYellow" align="center">本期淨利÷權益總額</td>
			</tr>
			<tr class="colTr" colname="RETA_RATIO" datatype="percent">
				<td class="tbYellow" align="center">總資產報酬率↗</td>
				<td class="tbYellow" align="center">(本期淨利+利息費用*(1-20%))÷資產總額</td>
			</tr>
		</table>
	</form>
</body>
</html>