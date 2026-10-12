<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSC2_1800.java
作者：陳思涵 
功能：催收轉出試算
完成：2013-09-10
240614資訊部門內部專用申請書:240611006875自提優化：放款相關帳務查詢畫面移除線上出帳按鈕 BY余凱鈞
 -->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
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

Event.observe(window, 'load', new DSC21800().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC21800(){
var rtnMap=[];
var Detail_List=[];
var ACNT_STATUS;
	
//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_1800/" + actionName,
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
		//查詢
		doQuery: function(){
	
			if(!$F('ACNT_DATE')){
				alert('請輸入結帳日期！');
				return;
			}
			
			ajaxPost( 'query', {ACNT_DATE : $F('ACNT_DATE')}
						,function(resp){
							//查詢前先將資料清空
							$$('#table_show td > Div').each(function(ele){
								ele.update();
							});
						
							rtnMap=resp.rtnMap;
							$$('.areaB').each(function(ele){
								var id = ele.id;
								ele.update(CSRUtil.$fmt(rtnMap[id],'#,###')|| '');
							});
							Detail_List=resp.Detail_List;
						
							for(var i=0;i<Detail_List.length;i++){
								//if(Detail_List[i]['DB_CR']=='CR'&&Detail_List[i]['SEQ_NO']>2){
									//$(Detail_List[i]['NAME']).update(buttons.doLink(Detail_List[i]['SEQ_NO']));
								//} else if(Detail_List[i]['DB_CR']=='DR'){
									//$(Detail_List[i]['NAME']).update(buttons.doLink(Detail_List[i]['SEQ_NO']));
								//}
								
								$(Detail_List[i]['NAME']).update(buttons.doLink(Detail_List[i]['SEQ_NO']));
								$(Detail_List[i]['ID']).update(CSRUtil.$fmt(Detail_List[i]['AMT'],'#,###')||'');
								$(Detail_List[i]['COUNT']).update(Detail_List[i]['CNT']||'');

							}
							ACNT_STATUS = resp.ACNT_STATUS;
							/*$$('.count1').each(function(ele){
								var id = ele.id;
								ele.update(rtnMap[id] || '');
							});
							$$('.money1').each(function(ele){
								var id = ele.id;
								ele.update(CSRUtil.$fmt(rtnMap[id],'#,###')|| '');
							});
							$('EMP_NAME').update(rtnMap['EMP_NAME']);
							
							$('LOAN').update(buttons.doLink(1));
							$('NLOAN').update(buttons.doLink(2));
							$('INT').update(buttons.doLink(3));
							$('RINT').update(buttons.doLink(4));
							$('DA').update(buttons.doLink(5));*/
							//$('table_show').show();
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
							$('RECEIVE1').update('催收款項');
							$('WCA').update('沖其他暫收');
							$('LOAN').update('擔保貸款');
							$('NLOAN').update('擔保貸款-無自用');
							$('INT').update('利息收入');
							$('RINT').update('應收利息');
							$('WDA').update('沖其他應收');
						}
					);
	}
	,doLink :function(type){
		var name;
		var QUERY_TYPE;
		if(type=='1'){
			name="催收款項";
			QUERY_TYPE='RECEIVE1';
		}else if(type=='2'){
			name="沖其他暫收";
			QUERY_TYPE='WCA';
		}else if(type=='3'){
			name="擔保貸款";
			QUERY_TYPE='LOAN';
		}else if(type=='4'){
			name="擔保貸款-無自用";
			QUERY_TYPE='NLOAN';
		}else if(type=='5'){
			name="利息收入";
			QUERY_TYPE='INT';
		}else if(type=='6'){
			name="應收利息";
			QUERY_TYPE='RINT';
		}else if(type=='7'){
			name="沖其他應收";
			QUERY_TYPE='WDA';
		}
		
		var link = new Element("a" , { href : "#" } ).update(name);
						link.observe( 'click', function (event){ 																			
								var LP_JSON = {
									action :'<%=dispatcher%>/DSC2_2710/prompt',	 	
									QUERY_TYPE : QUERY_TYPE, 
									ACNT_DATE : $F('ACNT_DATE'),
									ACNT_GROUP : '${ACNT_GROUP}',
									ACNT_STATUS :　ACNT_STATUS									
								}			
							CSRUtil.linkTo(LP_JSON , 'form');		
							/*popupWin.popup({
								src: '<%=dispatcher%>/DSC2_1810/prompt',
								parameters: { ACNT_DATE: $F('ACNT_DATE') , ACNT_GROUP:$F('ACNT_GROUP'), QUERY_TYPE : QUERY_TYPE}
							});*/
									
						});
		return link;
	}
}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC21800', '收息帳務', '催收轉出試算');
				
				$('BTN_QUERY').observe('click',buttons.doQuery);

				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
			}
	}


}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" >結帳日期</td>
			<td class="tbYellow2"  >
			<input id="ACNT_DATE"  type="text" class="textBox2 " name="ACNT_DATE" value='${ACNT_DATE}'  datatype="ROCDate" maxlength="7"/>
			<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('ACNT_DATE'))"></td>
		<td class="tbYellow2" >
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
			</td>
	</tr>
</table>
<table id='table_show' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbBlue" width="10%" align='center'>項目</td>
		<td class="tbBlue" width="10%" align='center'>借方金額</td>
		<td class="tbBlue" width="10%" align='center'>借方件數</td>
		<td class="tbBlue" width="10%" align='center'>貸方金額</td>
		<td class="tbBlue" width="10%" align='center'>貸方件數</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='RECEIVE1'>催收款項</td>
		<td class="tbBlue2">
		<Div id='RECEIVE1_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2" width="10%" align='center'>
		<Div id='RECEIVE1_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2">
		</td>
		<td class="tbYellow2">
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='WCA'>沖其他暫收</td>
		<td class="tbBlue2" width="10%" align='center'>
		<Div id='WCA_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2" width="10%" align='center'>
		<Div id='WCA_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2">
		</td>
		<td class="tbYellow2">
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='LOAN'>擔保貸款</td>
		<td class="tbBlue2" >
		</td>
		<td class="tbBlue2" width="10%" align='center'>
		</td>
		<td class="tbYellow2">
		<Div id='LOAN_AMT' class='money2' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='LOAN_CNT' class='count2' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='NLOAN'>擔保貸款-無自用</td>
		<td class="tbBlue2" width="10%" align='center'>
		</td>
		<td class="tbBlue2" width="10%" align='center'>	
		</td>
		<td class="tbYellow2">
		<Div id='NLOAN_AMT' class='money2' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='NLOAN_CNT' class='count2' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='INT'>利息收入</td>
		<td class="tbBlue2" width="10%" align='center'>
		</td>
		<td class="tbBlue2" width="10%" align='center'>
		</td>
		<td class="tbYellow2">
		<Div id='INT_AMT' class='money2' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='INT_CNT' class='count2' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='RINT'>應收利息</td>
		<td class="tbBlue2" width="10%" align='center'>
		</td>
		<td class="tbBlue2" width="10%" align='center'>
		</td>
		<td class="tbYellow2">
		<Div id='RINT_AMT' class='money2' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='RINT_CNT' class='count2' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='WDA'>沖其他應收款</td>
		<td class="tbBlue2" width="10%" align='center'>
		</td>
		<td class="tbBlue2" width="10%" align='center'>
		</td>
		<td class="tbYellow2">
		<Div id='WDA_AMT' class='money2' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='WDA_CNT' class='count2' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%">總計</td>
		<td class="tbBlue2">
		<Div id='DTOTAL_AMT' class='areaB' align='right'></Div></td>
		<td class="tbBlue2">
		<Div id='DTOTAL_CNT' class='areaB' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='CTOTAL_AMT' class='areaB' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='CTOTAL_CNT' class='areaB' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%">結帳人員</td>
		<td class="tbYellow2" colspan='4'>
		<Div id='EMP_NAME' class='areaB' style="font-family:'EUDC'"></Div>
		</td>
	</tr>
</table>
</form>
</body>
</html>