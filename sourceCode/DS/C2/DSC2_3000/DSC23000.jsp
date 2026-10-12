<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSC23000.jsp
功能：呆帳轉銷帳務維護模組
作者：溫子?
完成：2013/09/
240612資訊部門內部專用申請書:240611006875自提優化：放款相關帳務查詢畫面移除線上出帳按鈕 BY余凱鈞
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>	
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
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

Event.observe(window, 'load', new DSC23000().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC23000(){

var rtnMap=[];
var Detail_List=[];
var ACNT_STATUS;

	function  initValidation(){
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define("required", { id: "ACNT_DATE" , errMsg: "請輸入結帳日期"} );
		valid1.define( "validate-ROCDate" , { id: "ACNT_DATE", errMsg:'請輸入有效日期格式!!'} );
	}
//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_3000/" + actionName,
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
	function showView(rtnMap, Detail_List){
		$$('.areaB').each(function(ele){
			var id = ele.id;
			ele.update(CSRUtil.$fmt(rtnMap[id],'#,###')|| '');
		});

		for(var i=0;i<Detail_List.length;i++){
			$(Detail_List[i]['NAME']).update(buttons.doLink(Detail_List[i]['SEQ_NO']));
			$(Detail_List[i]['ID']).update(CSRUtil.$fmt(Detail_List[i]['AMT'],'#,###')||'');
			$(Detail_List[i]['COUNT']).update(Detail_List[i]['CNT']||'');
		}
		
	}
	buttons={
	
		doQuery : function(){
			if(!valid1.validate()){ 
				return; 
			}
			ajaxPost( 'query', {ACNT_DATE: $F('ACNT_DATE'), ACNT_GROUP: $F('ACNT_GROUP')}
						,function(resp){
							rtnMap=resp.rtnMap||'';
							Detail_List=resp.Detail_List;
							showView(rtnMap, Detail_List)
							ACNT_STATUS = resp.ACNT_STATUS;
							
						},function(resp){
							$$('#table_show div').each(function(ele){
								var id =ele.id;
								ele.update('');
							})
							$$('.areaB').each(function(ele){
								var id = ele.id;
								ele.update('');
							});
							$('EMP_NAME').update('');
							$('BAD').update('備抵呆帳');
							$('OVERDUE').update('催收款項-拍賣不足');
							$('RECEIVE2').update('催收款項-協議不足');
							$('RECEIVE1').update('催收款項-提沖不足');
						
						}
					);
		}
		,doLink :function(type){
		var name;
		var QUERY_TYPE;
		if(type=='1'){
			name="備抵呆帳";
			QUERY_TYPE='BAD';
		}else if(type=='2'){
			name="催收款項-拍賣不足";
			QUERY_TYPE='OVERDUE';
		}else if(type=='3'){
			name="催收款項-協議不足";
			QUERY_TYPE='RECEIVE2';
		}else if(type=='4'){
			name="催收款項-提沖不足";
			QUERY_TYPE='RECEIVE1';
		}
	
		var link = new Element("a" , { href : "#" } ).update(name);
						link.observe( 'click', function (event){ 																			
								var LP_JSON = {
									action :'<%=dispatcher%>/DSC2_2710/prompt',	 	
									QUERY_TYPE : QUERY_TYPE, 
									ACNT_DATE : $F('ACNT_DATE'),
									ACNT_GROUP : $F('ACNT_GROUP'),
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
				
				PageUI.createPageWithAllBodySubElement('DSC23000', '收息帳務', '呆帳轉銷帳務');
				
				initValidation();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				//$('table_show').hide();
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
			<td class="tbYellow" width="15%">結帳組別</td>
			<td class="tbYellow2" width="30%">
				<select id="ACNT_GROUP" fieldName = "結帳組別">						
					<option value="17_TEST">提呆</option>
					<option value="17">轉呆</option>
				</select>
			</td>			
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
		<td class="tbYellow" width="10%" id='BAD'>備抵呆帳</td>
		<td class="tbBlue2">
		<Div id='BAD_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='BAD_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2" >
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='OVERDUE'>催收款項-拍賣不足</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2">
		<Div id='OVERDUE_AMT' class='money2' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='OVERDUE_CNT' class='count2' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='RECEIVE2'>催收款項-協議不足</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2">
		<Div id='RECEIVE2_AMT' class='money2' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='RECEIVE2_CNT' class='count2' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='RECEIVE1'>催收款項-提沖不足</td>
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
</body>
</html>