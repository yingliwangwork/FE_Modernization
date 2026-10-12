<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<!--
程式：DSC21900.jsp
功能：提前沖轉試算
作者：卓達瑋
完成：2013/07/30
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
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

Event.observe(window, 'load', new DSC21900().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC21900(){
var rtnMap=[];
var Detail_List=[];
var ACNT_STATUS;
//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_1900/" + actionName,
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

	function initValidation(){

		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
		valid1.define( "required" , { id: "ACNT_DATE" , errMsg:"結帳日期不可空白!!" } );
		valid1.define( "validate-ROCDate" , { id: "ACNT_DATE"} );
		
		valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
		valid2.define( "required" , { id: "ACNT_DATE" , errMsg:"結帳日期有誤請再次確認！" } );
		valid2.define( "validate-ROCDate" , { id: "ACNT_DATE"} );
    }
	
	
var buttons={

	doQuery: function(){
	        if(!valid1.validate()){
				return;
			}
			
			ajaxPost( 'query', {ACNT_DATE : $F('ACNT_DATE')}
						,function(resp){
							rtnMap=resp.rtnMap;
							$$('.areaB').each(function(ele){
								var id = ele.id;
								ele.update(CSRUtil.$fmt(rtnMap[id],'#,###')|| '');
							});
							Detail_List=resp.Detail_List;
							ACNT_STATUS = resp.ACNT_STATUS;	
							for(var i=0;i<Detail_List.length;i++){
								if(Detail_List[i]['SEQ_NO']<6){
									$(Detail_List[i]['NAME']).update(buttons.doLink(Detail_List[i]['SEQ_NO']));
								}
								if(Detail_List[i]['DB_CR']=='DR'){
									$(Detail_List[i]['COUNT2']).update(CSRUtil.$fmt(Detail_List[i]['AMT'],'#,###')||'');
									$(Detail_List[i]['COUNT']).update(Detail_List[i]['CNT']||'');
								}else{
									$(Detail_List[i]['COUNT2']).update(CSRUtil.$fmt(Detail_List[i]['AMT'],'#,###')||'');
									$(Detail_List[i]['COUNT']).update(Detail_List[i]['CNT']||'');
								}
							}		
						},function(resp){
							
							$$('.areaB').each(function(ele){
								var id = ele.id;
								ele.update('');
							});
                            $$('.count1').each(function(ele){
								var id = ele.id;
								ele.update('');
							});
							$$('.money1').each(function(ele){
								var id = ele.id;
								ele.update('');
							});
							$('EMP_NAME').update('');
							$('D_RECEIVE1').update('催收款項-提沖不足');
							$('D_RECEIVE2').update('催收款項-提前沖轉');
							$('BAD').update('備抵呆帳');
							$('RECEIVE1').update('催收款項');
							$('OVERDUE').update('催收款項-提沖不足(貸方)');
						}
					);
	}
	,doLink :function(type){
		var name;
		var QUERY_TYPE;
		if(type=='1'){
			name="催收款項-提沖不足";
			QUERY_TYPE='D_RECEIVE1';
		}else if(type=='2'){
			name="催收款項-提前沖轉";
			QUERY_TYPE='D_RECEIVE2';
		}else if(type=='3'){
			name="備抵呆帳";
			QUERY_TYPE='BAD';
		}else if(type=='4'){
			name="催收款項";
			QUERY_TYPE='RECEIVE1';
		}else if(type=='5'){
			name="催收款項-提沖不足(貸方)";
			QUERY_TYPE='OVERDUE';
		}
	
		var link = new Element("a" , { href : "#" } ).update(name);
						link.observe( 'click', function (event){ 																			
								var LP_JSON = {
									action :'<%=dispatcher%>/DSC2_2710/prompt',	 	
									QUERY_TYPE : QUERY_TYPE, 
									ACNT_DATE : $F('ACNT_DATE'),
									ACNT_GROUP : '${ACNT_GROUP}',
									ACNT_STATUS: ACNT_STATUS
								}							
							CSRUtil.linkTo(LP_JSON , 'form1');		
							
									
						});
		return link;
	}
}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC21900', '收息帳務', '提前沖轉試算');
				
				$('BTN_QUERY').observe('click',buttons.doQuery);
			
				initValidation();
				
				var LP_JSON = CSRUtil.isBackLink('form');
	   			if (LP_JSON) {	   			 
	   			 	$('ACNT_DATE').value = LP_JSON.ACNT_DATE;	   			 
	   			 	buttons.doQuery() ; 
	   			 }
				//先把畫面區塊都調整到位再顯示訊息				
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
			    
			}
	}
}
</script>
</head>
<body >
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

<table id='table_show' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >

	<tr>
		<td class="tbBlue" width="10%" align='center'>項目</td>
		<td class="tbBlue" width="10%" align='center'>借方金額</td>
		<td class="tbBlue" width="10%" align='center'>借方件數</td>
		<td class="tbBlue" width="10%" align='center'>貸方金額</td>
		<td class="tbBlue" width="10%" align='center'>貸方件數</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='D_RECEIVE1'>催收款項-提沖不足</td>
		<td class="tbBlue2">
		<Div id='D_RECEIVE1_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='D_RECEIVE1_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2" >
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='D_RECEIVE2'>催收款項-提前沖轉</td>
		<td class="tbBlue2">
		<Div id='D_RECEIVE2_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='D_RECEIVE2_CNT' class='count1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>	
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='BAD'>備抵呆帳</td>
		<td class="tbBlue2">
		<Div id='BAD_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='BAD_CNT' class='count1' align='right'></Div>
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
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='RECEIVE1_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='RECEIVE1_CNT' class='count1' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" id='OVERDUE'>催收款項-提沖不足</td>

		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='OVERDUE_AMT' class='money1' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='OVERDUE_CNT' class='count1' align='right'></Div>
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