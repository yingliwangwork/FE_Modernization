<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>

<!--
程式：DSC2_3100.java
作者：黃子玹
功能：陳報債權帳務
完成：2013/09/

240612資訊部門內部專用申請書:240611006875自提優化：放款相關帳務查詢畫面移除線上出帳按鈕 BY余凱鈞
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/prototype.js'></script><!--JS基礎底層必備用-->
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>  <!--CSR相關處理用-->
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>    <!--表格用-->
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>     <!--標準外框表格-->
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script> <!--檢核用-->
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>	  <!--日曆用-->
<%-- [20241104]難字 css --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		font-weight: normal;
		font-style: normal
	}
</style>
<script type='text/javascript'>

Event.observe(window, 'load', new DSC23100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC23100() {
	
	var rtnMap = [];
	var Detail_List = [];
	var ACNT_STATUS;

	<%--共用AJAX--%>
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( '${dispatcher}/DSC2_3100/' + actionName,
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

	var buttons = {
		<%--查詢--%>
		doQuery : function(event) {
			if (!$F('ACNT_DATE')) {
				alert('請輸入結帳日期！');
				return;
			}

			ajaxPost(
				  'query'
				, { 'ACNT_DATE' : $F('ACNT_DATE') }
				, function(resp) {
					<%--查詢前先將資料清空--%>
					$$('#table_show td > Div').each(function(ele) {
						ele.update();
					});

					rtnMap = resp.rtnMap;

					$$('.areaB').each(function(ele) {
						var id = ele.id;
						ele.update(CSRUtil.$fmt(rtnMap[id],'#,###') || '');
					});

					Detail_List = resp.Detail_List;

					for (var i = 0 ; i < Detail_List.length ; i++) {
						if (Detail_List[i]['DB_CR'] == 'DR' || Detail_List[i]['DB_CR'] == 'CR') {
							$(Detail_List[i]['NAME']).update(buttons.doLink(Detail_List[i]['SEQ_NO']));
						}

						if (Detail_List[i]['DB_CR'] == 'DR') {
							$(Detail_List[i]['ID']).update(CSRUtil.$fmt(Detail_List[i]['AMT'],'#,###') || '');
							$(Detail_List[i]['COUNT']).update(Detail_List[i]['CNT'] || '');
						} else {
							$(Detail_List[i]['ID']).update(CSRUtil.$fmt(Detail_List[i]['AMT'],'#,###') || '');
							$(Detail_List[i]['COUNT']).update(Detail_List[i]['CNT'] || '');
						}
					}

					ACNT_STATUS = resp.ACNT_STATUS;
				}
				, function(resp) {
					for (var i = 0 ; i < Detail_List.length ; i++) {
						$(Detail_List[i]['ID']).update('');
						$(Detail_List[i]['COUNT']).update('');
					}

					$$('.areaB').each(function(ele) {
						<%--var id = ele.id;--%>
						ele.update('');
					});

					$('EMP_NAME').update('');
					$('D_OVERDUE').update('催收款項-拍賣不足');
					$('COURT').update('催收款項-法院分配款');
					$('RECEIVE2').update('催收款項-協議不足');
					$('WCB').update('沖人工暫收款');
					$('WCA').update('沖其他暫收');
					$('D_RECEIVE1').update('催收款項-提沖不足');
					$('DA').update('其他應收款');
					$('LOAN').update('擔保貸款');
					$('NLOAN').update('擔保貸款-無自用');
					$('RECEIVE1').update('催收款項');
					$('EXPENSE').update('帳戶管理費');
					$('INT').update('利息收入');
					$('RINT').update('應收利息');
					$('CA').update('其他暫收');
					$('WDA').update('沖其他應收');
					$('C_RECEIVE2').update('催收款項－提前沖轉');
					$('C_OVERDUE').update('收回呆帳');
				}
			);
		}
		<%--超連結--%>
		, doLink :function(type) {
			var name;
			var QUERY_TYPE;

			if (type == '1') {
				name = '催收款項-拍賣不足';
				QUERY_TYPE = 'D_OVERDUE';

			} else if (type == '2') {
				name = '催收款項-法院分配款';
				QUERY_TYPE = 'COURT';

			} else if (type == '3') {
				name = '催收款項-協議不足';
				QUERY_TYPE = 'RECEIVE2';

			} else if (type == '4') {
				name = '沖人工暫收款';
				QUERY_TYPE = 'WCB';

			} else if (type == '5') {
				name = '沖其他暫收';
				QUERY_TYPE = 'WCA';

			} else if (type == '6') {
				name = '催收款項-提沖不足';
				QUERY_TYPE = 'D_RECEIVE1';

	        } else if (type == '7') {
				name = '其他應收款';
				QUERY_TYPE = 'DA';

			} else if (type == '8') {
				name = '擔保貸款';
				QUERY_TYPE = 'LOAN';

			} else if (type == '9') {
				name = '擔保貸款-無自用';
				QUERY_TYPE = 'NLOAN';

			} else if (type == '10') {
				name = '催收款項';
				QUERY_TYPE = 'RECEIVE1';

			} else if (type == '11') {
				name = '帳戶管理費';
				QUERY_TYPE = 'EXPENSE';

			} else if (type == '12') {
				name = '利息收入';
				QUERY_TYPE = 'INT';

			} else if (type == '13') {
				name = '應收利息';
				QUERY_TYPE = 'RINT';

			} else if (type == '14') {
				name = '其他暫收';
				QUERY_TYPE = 'CA';	

			} else if (type == '15') {
				name = '沖其他應收';
				QUERY_TYPE = 'WDA';

			} else if (type == '16') {
				name = '催收款項－提前沖轉';
				QUERY_TYPE = 'C_RECEIVE2';

			} else if (type == '17') {
				name = '收回呆帳';
				QUERY_TYPE = 'C_OVERDUE';
			}
	
			var link = new Element('a' , { href : '#' } ).update(name);
				link.observe(
					  'click'
					, function(event) {
						var LP_JSON = {
							  action :'${dispatcher}/DSC2_2710/prompt'
							, QUERY_TYPE  : QUERY_TYPE
							, ACNT_DATE   : $F('ACNT_DATE')
							, ACNT_GROUP  : '${ACNT_GROUP}'
							, ACNT_STATUS : ACNT_STATUS
						};

						CSRUtil.linkTo(LP_JSON , 'form');
					}
				);

			return link;
		}
	};

	return {
		'initApp' : function() {
				PageUI.createPageWithAllBodySubElement('DSC23100', '收息帳務', '陳報債權帳務');

				$('BTN_QUERY').observe('click', buttons.doQuery);

				var LP_JSON = CSRUtil.isBackLink('form1');
	   			if (LP_JSON) {	   			 
	   			 	$('ACNT_DATE').value = LP_JSON.ACNT_DATE;	   			 
	   			 	buttons.doQuery() ; 
	   			 }

				fix();<%--先把畫面區塊都調整到位再顯示訊息--%>
				displayMessage();<%--初始頁面alert訊息用--%>
			}
	};
}
</script>
</head>

<body>
<form name="form1" id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="20%">結帳日期</td>
			<td class="tbYellow2" width="60%">
				<input id="ACNT_DATE" name="ACNT_DATE" type="text" class="textBox2" size='12' maxlength='10' datatype="ROCDate" value="${ACNT_DATE}"/> 
				<img src="/DSWeb/images/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('ACNT_DATE'))">
			</td>
			<td class="tbYellow2" width="20%">
				<input id="BTN_QUERY" type="button" class="button" value="查詢" />
			</td>
		</tr>
	</table>

	<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" 	>
		<tr>
			<td class="tbBlue" width="10%" align='center'>項目</td>
			<td class="tbBlue" width="10%" align='center'>借方金額</td>
			<td class="tbBlue" width="10%" align='center'>借方件數</td>
			<td class="tbBlue" width="10%" align='center'>貸方金額</td>
			<td class="tbBlue" width="10%" align='center'>貸方件數</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='D_OVERDUE' >催收款項-拍賣不足</td>
			<td class="tbBlue2">
				<div id='D_OVERDUE_AMT' align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='D_OVERDUE_CNT' align='right'></div>
			</td>
			<td class="tbYellow2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='COURT' >催收款項-法院分配款</td>
			<td class="tbBlue2">
				<div id='COURT_AMT'  align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='COURT_CNT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='RECEIVE2'>催收款項-協議不足</td>
			<td class="tbBlue2">
				<div id='RECEIVE2_AMT' align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='RECEIVE2_CNT' align='right'></div>
			</td>
			<td class="tbYellow2" >				
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='WCB'>沖人工暫收款</td>
			<td class="tbBlue2">
				<div id='WCB_AMT'  align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='WCB_CNT'  align='right'></div>	
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='WCA'>沖其他暫收</td>
			<td class="tbBlue2">
				<div id='WCA_AMT'  align='right'></div>
			</td>			
			<td class="tbBlue2">
				<div id='WCA_CNT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='D_RECEIVE1'>催收款項-提沖不足</td>
			<td class="tbBlue2">
				<div id='D_RECEIVE1_AMT'  align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='D_RECEIVE1_CNT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='DA'>其他應收款</td>
			<td class="tbBlue2">
				<div id='DA_AMT' align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='DA_CNT'  align='right'></Div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
			</td>
		</tr>		
		<tr>
			<td class="tbYellow" width="10%" id='LOAN'>擔保貸款</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='LOAN_AMT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='LOAN_CNT' align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='NLOAN'>擔保貸款-無自用</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='NLOAN_AMT'  align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='NLOAN_CNT'  align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='RECEIVE1'>催收款項</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='RECEIVE1_AMT'  align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='RECEIVE1_CNT' align='right'></Div>
			</td>
		</tr>		
		<tr>
			<td class="tbYellow" width="10%" id='EXPENSE'>帳戶管理費</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='EXPENSE_AMT'  align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='EXPENSE_CNT'  align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='INT'>利息收入</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='INT_AMT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='INT_CNT' align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='RINT'>應收利息</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='RINT_AMT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='RINT_CNT' align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='CA'>其他暫收</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='CA_AMT'  align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='CA_CNT'  align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='WDA'>沖其他應收</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='WDA_AMT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='WDA_CNT' align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='C_RECEIVE2'>催收款項－提前沖轉</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='C_RECEIVE2_AMT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='C_RECEIVE2_CNT' align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='C_OVERDUE'>收回呆帳</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='C_OVERDUE_AMT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='C_OVERDUE_CNT' align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="20%">總計</td>
			<td class="tbYellow2" width="20%" align="right" ><span id="DTOTAL_AMT" class='areaB' ></span></td>
			<td class="tbYellow2" width="20%" align="right"><span id="DTOTAL_CNT" class='areaB' ></span></td>
			<td class="tbYellow2" width="20%" align="right"><span id="CTOTAL_AMT" class='areaB' ></span></td>
			<td class="tbYellow2" width="20%" align="right"><span id="CTOTAL_CNT" class='areaB' ></span></td>
		</tr>
		<tr class="tbYellow" >
			<td class="tbYellow">結帳人員</td>
			<td class="tbYellow2" colspan="4">
				<span id="EMP_NAME" class='areaB' style="font-family:'EUDC'"></span>
			</td>
		</tr>
	</table>
</form>
</body>
</html>