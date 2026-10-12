<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!--
程式：DSC23500.jsp
功能：理財型自動撥償帳務查詢 
作者：溫子
完成：2013/06/
240612資訊部門內部專用申請書:240611006875自提優化：放款相關帳務查詢畫面移除線上出帳按鈕 BY余凱鈞
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示--> 
 
 
 
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
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
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

Event.observe(window, 'load', new DSC23500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC23500(){
var rtnMap={};

	function initValidation(){

			//查詢用檢核
			valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid1.define( "required" , { id: "ACNT_DATE" , errMsg:"結帳日期不可空白!!" } );
			valid1.define( "validate-ROCDate" , { id: "ACNT_DATE"} );
			
			valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid2.define( "required" , { id: "ACNT_DATE" , errMsg:"結帳日期有誤請再次確認！" } );
			valid2.define( "validate-ROCDate" , { id: "ACNT_DATE"} );
			valid2.define( "validate-selection" , { id: "ACNT_GROUP",errMsg:"結帳組別有誤請再次確認！" } );
}
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_3500/" + actionName,
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
	buttons={
		
		doQuery : function(){
			if(!valid1.validate()){
				return;
			}
			$('table_show').show();
			ajaxPost( 'query', {ACNT_DATE : $F('ACNT_DATE')}
						,function(resp){
							rtnMap=resp.rtnMap;
							
							$$('.count1').each(function(ele){
								var id = ele.id;
								ele.update(rtnMap[id] || '');
							});
							$$('.money1').each(function(ele){
								var id = ele.id;
								ele.update(CSRUtil.$fmt(rtnMap[id],'#,###')|| '');
							});
							$('EMP_NAME').update(rtnMap['EMP_NAME']);
							
							$('SHORT').update(buttons.doLink(1));
							$('WCA').update(buttons.doLink(2));
							$('DA').update(buttons.doLink(3));
							$('INT').update(buttons.doLink(4));
							$('CA').update(buttons.doLink(5));
							$('LSFEE').update(buttons.doLink(6));
							$('WDA').update(buttons.doLink(7));
							$('IS_BALANCE').value = resp.rtnMap.IS_BALANCE;
							
							//$('table_show').show();
						},function(resp){
							$$('.count1').each(function(ele){
								var id = ele.id;
								ele.update('');
							});
							$$('.money1').each(function(ele){
								var id = ele.id;
								ele.update('');
								
							});
							$('EMP_NAME').update('');
							$('SHORT').update('短期擔保放款');
							$('WCA').update('沖其他暫收款_電腦');
							$('DA').update('其他應收款_電腦');
							$('INT').update('利息收入');
							$('CA').update('其他暫收款_電腦');
							$('LSFEE').update('管理費用');
							$('WDA').update('沖-其他應收款_電腦');
							$('IS_BALANCE').value = 'N';
						}
					);
		}
		,doLink :function(type){
			var name;
			var QUERY_TYPE;
			if(type=='1'){
				name="短期擔保放款";
				QUERY_TYPE='SHORT';
			}else if(type=='2'){
				name="沖其他暫收款_電腦";
				QUERY_TYPE='WCA';
			}else if(type=='3'){
				name="其他應收款_電腦";
				QUERY_TYPE='DA';
			}else if(type=='4'){
				name="利息收入";
				QUERY_TYPE='INT';
			}else if(type=='5'){
				name="其他暫收款_電腦";
				QUERY_TYPE='CA';
			}else if(type=='6'){
				name="管理費用";
				QUERY_TYPE='LSFEE';
			}else if(type=='7'){
				name="沖-其他應收款_電腦";
				QUERY_TYPE='WDA';
			}
		
			var link = new Element("a" , { href : "#" } ).update(name);
							link.observe( 'click', function (event){ 																			
								var LP_JSON = {
									action :'<%=dispatcher%>/DSC2_3310/prompt',	 	
									QUERY_TYPE : QUERY_TYPE, 
									ACNT_DATE : $F('ACNT_DATE'),
									ACNT_GROUP : $F('ACNT_GROUP')
									
								}			
							CSRUtil.linkTo(LP_JSON , 'form');
								/*popupWin.popup({
									src: '<%=dispatcher%>/DSC2_3310/prompt',
									parameters: { ACNT_DATE: $F('ACNT_DATE') , ACNT_GROUP:$F('ACNT_GROUP'), QUERY_TYPE : QUERY_TYPE}
								});*/
										
							});
			return link;
		}	
	}
return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC23500', '收息帳務', '理財型自動撥償帳務查詢');
				
				initValidation();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
				if(CSRUtil.isBackLink('form')){    
					buttons.doQuery();  
				}
			}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<input type="hidden" id="IS_BALANCE" value="N" />
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class='tbYellow' width='5%'>
			結帳日期
		</td>
		<td class='tbYellow2' width='10%'>
			<input id="ACNT_DATE" name = "ACNT_DATE" datatype="ROCDate" type="text" class="textBox2 "  size="10" maxlength="7" value="${ACNT_DATE}"/>
			<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('ACNT_DATE'))">
		</td>
        <td class='tbYellow' width='15%'>
			結帳組別
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="ACNT_GROUP" name = "ACNT_GROUP" class="textBox2">
				<c:forEach items="${ACNT_GROUP_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
        <td class="tbYellow2" width="10%" align="center">
			<input type="button" class="button" id="BTN_QUERY" value="查詢" />					
		</td>
	</tr>	
</table>	
<table id='table_show' style="display:none;" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow0" width="10%" align='center' colspan='3'>借方項目</td>
		<td class="tbYellow0" width="10%" align='center' colspan='3'>貸方項目</td>
	</tr>
	<tr>
		<td class="tbBlue" width="10%"></td>
		<td class="tbBlue" width="10%" align='center'>件數</td>
		<td class="tbBlue" width="10%" align='center'>金額</td>
		<td class="tbYellow" width="10%"></td>
		<td class="tbYellow" width="10%" align='center'>件數</td>
		<td class="tbYellow" width="10%" align='center'>金額</td>
	</tr>
	<tr>
		<td class="tbYellow2" width="10%" id='SHORT'>短期擔保放款</td>
		<td class="tbYellow2">
		<Div id='SHORT_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='SHORT_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" id='INT'>利息收入</td>
		<td class="tbYellow2">
		<Div id='INT_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='INT_AMT' class='money1' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" width="10%" id='WCA'>沖其他暫收款_電腦</td>
		<td class="tbYellow2">
		<Div id='WCA_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='WCA_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" id='CA'>其他應收款_電腦</td>
		<td class="tbYellow2">
		<Div id='CA_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='CA_AMT' class='money1' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" width="10%" id='DA'>其他應收款_電腦</td>
		<td class="tbYellow2">
		<Div id='DA_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2">
		<Div id='DA_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" id='LSFEE'>管理費用</td>
		<td class="tbYellow2" width="10%">
		<Div id='LSFEE_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%">
		<Div id='LSFEE_AMT' class='money1' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" width="10%" ></td>
		<td class="tbYellow2">
		</td>
		<td class="tbYellow2">
		</td>
		<td class="tbYellow2" width="10%" id='WDA'>沖-其他應收款_電腦</td>
		<td class="tbYellow2" width="10%">
		<Div id='WDA_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%">
		<Div id='WDA_AMT' class='money1' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow1" width="10%">總計</td>
		<td class="tbYellow1" width="10%"></td>
		<td class="tbYellow1">
		<Div id='DTOTAL_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbYellow1" width="10%">總計</td>
		<td class="tbYellow1" width="10%"></td>
		<td class="tbYellow1">
		<Div id='CTOTAL_AMT' class='money1' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow0" width="10%">結帳人員</td>
		<td class="tbYellow2" colspan='5'>
		<Div id='EMP_NAME' style="font-family:'EUDC'"></Div>
		</td>
	</tr>
</table>


</form>
</body>
</html>