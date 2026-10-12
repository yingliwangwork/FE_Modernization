<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSC21700.jsp
功能：催收轉入試算
作者：溫子?
完成：2013/05/
240614資訊部門內部專用申請書:240611006875自提優化：放款相關帳務查詢畫面移除線上出帳按鈕 BY余凱鈞
[20241030]修改件 CHROME瀏覽器難字調整
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
<%--[20241030]難字css  --%>
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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC21700().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC21700(){
var rtnMap=[];
var Detail_List=[];
var ACNT_STATUS;

//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_1700/" + actionName,
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
								//if(Detail_List[i]['DB_CR']=='DR'&&Detail_List[i]['SEQ_NO']<6){
									//$(Detail_List[i]['NAME']).update(buttons.doLink(Detail_List[i]['SEQ_NO']));
								//} 
								//if(Detail_List[i]['DB_CR']=='DR'){
									//$(Detail_List[i]['ID']).update(CSRUtil.$fmt(Detail_List[i]['AMT'],'#,###')||'');
									//$(Detail_List[i]['COUNT']).update(Detail_List[i]['CNT']||'');
								//}else{
									//$(Detail_List[i]['ID']).update(CSRUtil.$fmt(Detail_List[i]['AMT'],'#,###')||'');
									//$(Detail_List[i]['COUNT']).update(Detail_List[i]['CNT']||'');
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
							$('LOAN').update('擔保貸款');
							$('NLOAN').update('擔保貸款-無自用');
							$('INT').update('利息收入');
							$('RINT').update('應收利息');
							$('DA').update('其他應收款');
							$('RECEIVE1').update('催收款項');
							$('CA').update('其他暫收');
						}
					);
	}
	,doLink :function(type){
		var name;
		var QUERY_TYPE;
		if(type=='1'){
			name="擔保貸款";
			QUERY_TYPE='LOAN';
		}else if(type=='2'){
			name="擔保貸款-無自用";
			QUERY_TYPE='NLOAN';
		}else if(type=='3'){
			name="利息收入";
			QUERY_TYPE='INT';
		}else if(type=='4'){
			name="應收利息";
			QUERY_TYPE='RINT';
		}else if(type=='5'){
			name="其他應收款";
			QUERY_TYPE='DA';
		}else if(type=='6'){
			name="催收款項";
			QUERY_TYPE='RECEIVE1';
		}else if(type=='7'){
			name="其他暫收";
			QUERY_TYPE='CA';
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
								src: '<%=dispatcher%>/DSC2_1710/prompt',
								parameters: { ACNT_DATE: $F('ACNT_DATE') , ACNT_GROUP:$F('ACNT_GROUP'), QUERY_TYPE : QUERY_TYPE}
							});*/
									
						});
		return link;
	}
}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC21700', '收息帳務', '催收轉入試算');
				
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
		<td class="tbYellow" width="10%" id='LOAN'>擔保貸款</td>
		<td class="tbBlue2">
		<Div id='LOAN_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='LOAN_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2" >
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='NLOAN'>擔保貸款-無自用</td>
		<td class="tbBlue2">
		<Div id='NLOAN_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='NLOAN_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>	
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='INT'>利息收入</td>
		<td class="tbBlue2">
		<Div id='INT_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='INT_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='RINT'>應收利息</td>
		<td class="tbBlue2">
		<Div id='RINT_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='RINT_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='DA'>其他應收款</td>
		<td class="tbBlue2">
		<Div id='DA_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='DA_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='RECEIVE1'>催收款項</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2">
		<Div id='RECEIVE1_AMT' class='money2' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='RECEIVE1_CNT' class='count2' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='CA'>其他暫收</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='CA_AMT' class='money2' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='CA_CNT' class='count2' align='right'></Div>
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
		<td class="tbYellow2" colspan='4'><%-- [20241030] 難字調整 --%>
		<span id='EMP_NAME' class='areaB' style="font-family:'EUDC'"></span>
		</td>
	</tr>
</table>
</form>
</body>
</html>