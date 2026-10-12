<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!--
程式：DSC2_2700.java
作者：黃子玹
功能：電匯帳務
完成：2013/09/27
240612資訊部門內部專用申請書:240611006875自提優化：放款相關帳務查詢畫面移除線上出帳按鈕 BY余凱鈞
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>


<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	 <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>		 <%-- 日曆用 --%>
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
<script type="text/JavaScript">

Event.observe(window, 'load', new DSC22700().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC22700(){
	
	var ACNT_STATUS;	
	var rtnMap = [];
	var Detail_List = [];
		
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_2700/" + actionName,
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

		//查詢
		doQuery : function(event){
			
	    	if(!$F('ACNT_DATE')){
				alert('請輸入結帳日期！');
				return;
			}
			
			
			
			ajaxPost( 'query', {ACNT_DATE: $F('ACNT_DATE'), ACNT_GROUP: $F('ACNT_GROUP')}
						,function(resp){
						    //查詢前先將資料清空
								$$('table#table_B td div').each(function(ele){
									ele.update('');
								});
							rtnMap=resp.rtnMap;
							$$('.areaB').each(function(ele){
								var id = ele.id;
								ele.update(CSRUtil.$fmt(rtnMap[id],'#,###')|| '');
							});
							Detail_List=resp.Detail_List;
						
							for(var i=0;i<Detail_List.length;i++){
								if(Detail_List[i]['DB_CR']=='DR'|| Detail_List[i]['DB_CR']=='CR'){
									$(Detail_List[i]['NAME']).update(buttons.doLink(Detail_List[i]['SEQ_NO']));
								}
								if(Detail_List[i]['DB_CR']=='DR'){
									$(Detail_List[i]['ID']).update(CSRUtil.$fmt(Detail_List[i]['AMT'],'#,###')||'');
									$(Detail_List[i]['COUNT']).update(Detail_List[i]['CNT']||'');
								}else{
									$(Detail_List[i]['ID']).update(CSRUtil.$fmt(Detail_List[i]['AMT'],'#,###')||'');
									$(Detail_List[i]['COUNT']).update(Detail_List[i]['CNT']||'');
								}
							}
							ACNT_STATUS = resp.ACNT_STATUS;
						},function(resp){
							for(var i=0;i<Detail_List.length;i++){
								$(Detail_List[i]['ID']).update('');
								$(Detail_List[i]['COUNT']).update('');
							}
							$$('.areaB').each(function(ele){
								var id = ele.id;
								ele.update('');
							});
							$('EMP_NAME').update('');
							$('CASH').update('銀行存款');
							$('CHECK').update('票據');
							$('WCA').update('沖其他暫收');
							$('DA').update('其他應收款');
							$('WCB').update('沖人工暫收款');
							$('DB').update('人工應收款');
							$('LOAN').update('擔保貸款');
							$('NLOAN').update('擔保貸款-無自用');
							$('INT').update('利息收入');
							$('RINT').update('應收利息');
							$('CA').update('其他暫收');
							$('WDA').update('沖其他應收');
							$('CB').update('人工暫收');
							$('WDB').update('沖人工應收');
							$('EXPENSE').update('管理費用');
							//$('LSFEE2').update('帳戶管理費');					
							//$('LSFEE3').update('代收火險費');
							//$('LSFEE1').update('法律事務費');
							//$('LSFEE4').update('利率調整換約收費');
							
						}
					);
		}
		,doLink :function(type){
		var name;
		var QUERY_TYPE;
		if(type=='1'){
			name="銀行存款";
			QUERY_TYPE='CASH';
		}else if(type=='2'){
			name="票據";
			QUERY_TYPE='CHECK';
		}else if(type=='3'){
			name="沖其他暫收";
			QUERY_TYPE='WCA';
		}else if(type=='4'){
			name="其他應收款";
			QUERY_TYPE='DA';
		}else if(type=='5'){
			name="沖人工暫收款";
			QUERY_TYPE='WCB';
		}else if(type=='6'){
			name="人工應收款";
			QUERY_TYPE='DB';
        }else if(type=='7'){
			name="擔保貸款";
			QUERY_TYPE='LOAN';
		}else if(type=='8'){
			name="擔保貸款-無自用";
			QUERY_TYPE='NLOAN';
		}else if(type=='9'){
			name="利息收入";
			QUERY_TYPE='INT';
		}else if(type=='10'){
			name="應收利息";
			QUERY_TYPE='RINT';
		}else if(type=='11'){
			name="其他暫收";
			QUERY_TYPE='CA';
		}else if(type=='12'){
			name="沖其他應收";
			QUERY_TYPE='WDA';
		}else if(type=='13'){
			name="人工暫收";
			QUERY_TYPE='CB';
		}else if(type=='14'){
			name="沖人工應收";
			QUERY_TYPE='WDB';	
		}else if(type=='15'){
			name="管理費用";
			QUERY_TYPE='EXPENSE';
		/*	
		}else if(type=='15'){
			name="帳戶管理費";
			QUERY_TYPE='LSFEE2';
		}else if(type=='16'){
			name="代收火險費";
			QUERY_TYPE='LSFEE3';
		}else if(type=='17'){
			name="法律事務費";
			QUERY_TYPE='LSFEE1';
		}else if(type=='18'){
			name="利率調整換約收費";
			QUERY_TYPE='LSFEE4';
		*/
		}
	
		var link = new Element("a" , { href : "#" } ).update(name);
						link.observe( 'click', function (event){ 																			
								var LP_JSON = {
									action :'<%=dispatcher%>/DSC2_2710/prompt',	 	
									QUERY_TYPE : QUERY_TYPE, 
									ACNT_DATE : $F('ACNT_DATE'),
									ACNT_GROUP : $('ACNT_GROUP').value,
									ACNT_STATUS :　ACNT_STATUS									
								}			
							CSRUtil.linkTo(LP_JSON , 'form');		
			
						});
		return link;
	}
}
	
	
	return{
		initApp:function() {
			    PageUI.createPageWithAllBodySubElement('DSC22700', '收息帳務', '電匯帳務');

				$('btn_query').observe('click',buttons.doQuery);
				//$('table_show').hide();
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
		}
	};


}
</script>
</head>
<body>
<form name="form1" id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="15%">結帳日期</td>
			<td class="tbYellow2" width="20%">
				<input id="ACNT_DATE" type="text" class="textBox2" size='12' maxlength='10' datatype="ROCDate" value="${ACNT_DATE}"/> 
				<img src="/DSWeb/images/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('ACNT_DATE'))">
			</td>
			<td class="tbYellow" width="15%">結帳組別</td>
			<td class="tbYellow2" width="30%">
				<select id="ACNT_GROUP" fieldName = "結帳組別">						
					<c:forEach var="map" items="${ACNT_GROUP_LIST}">
							<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" width="20%" align = "center">
				<input id="btn_query" type="button" class="button" value="查詢" />
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
			<td class="tbYellow" width="10%" id='CASH' >銀行存款</td>
			<td class="tbBlue2">
				<div id='CASH_AMT' align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='CASH_CNT' align='right'></div>
			</td>
			<td class="tbYellow2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='CHECK' >票據</td>
			<td class="tbBlue2">
				<div id='CHECK_AMT'  align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='CHECK_CNT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='WCA'>沖其他暫收</td>
			<td class="tbBlue2">
				<div id='WCA_AMT' align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='WCA_CNT' align='right'></div>
			</td>
			<td class="tbYellow2" >				
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='DA'>其他應收款</td>
			<td class="tbBlue2">
				<div id='DA_AMT'  align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='DA_CNT'  align='right'></div>	
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
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
				<div id='WCB_CNT' align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
			</td>
			<td class="tbYellow2" width="10%" align='center'>				
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='DB'>人工應收款</td>
			<td class="tbBlue2">
				<div id='DB_AMT'  align='right'></div>
			</td>
			<td class="tbBlue2">
				<div id='DB_CNT' align='right'></div>
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
				<div id='LOAN_AMT'  align='right'></div>
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
				<div id='NLOAN_CNT' align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='INT'>利息收入</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='INT_AMT'  align='right'></div>
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
			<td class="tbYellow" width="10%" id='CB'>人工暫收</td>
			<td class="tbBlue2"></td>
			<td class="tbBlue2"></td>
			<td class="tbYellow2" width="10%" align='center'>				
				<div id='CB_AMT'  align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='CB_CNT'  align='right'></div>	
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='WDB'>沖人工應收</td>
			<td class="tbBlue2">				
			</td>
			<td class="tbBlue2">				
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='WDB_AMT'  align='right'></div>				
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='WDB_CNT'  align='right'></div>				
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='EXPENSE'>管理費用</td>
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
		<!-- 	
		<tr>
			<td class="tbYellow" width="10%" id='LSFEE2'>帳戶管理費</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='LSFEE2_AMT'  align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='LSFEE2_CNT'  align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='LSFEE3'>代收火險費</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='LSFEE3_AMT'  align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='LSFEE3_CNT'  align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='LSFEE1'>法律事務費</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='LSFEE1_AMT'  align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='LSFEE1_CNT'  align='right'></Div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" id='LSFEE4'>利率調整換約收費</td>
			<td class="tbBlue2">
			</td>
			<td class="tbBlue2">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='LSFEE4_AMT'  align='right'></div>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<div id='LSFEE4_CNT'  align='right'></Div>
			</td>
		</tr>
		 -->		
		<tr>
			<td class="tbYellow" width="20%">總計:</td>
			<td class="tbBlue2" width="20%" align="right" ><span id="DTOTAL_AMT" class='areaB' ></span></td>
			<td class="tbBlue2" width="20%" align="right"><span id="DTOTAL_CNT" class='areaB' ></span></td>
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