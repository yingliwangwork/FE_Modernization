<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC32800.jsp
功能：繳現清償授權
作者：溫子
完成：2013/06/

[20241104] 修改件 難字調整 吳志鴻
 -->
 
<html>
<head>

<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js "></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script>

<%-- [20241104] 難字調整 --%>
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
Event.observe(window, 'load', new DSC32800().initApp);

// 按鈕權限
var legal2;//紀錄按鈕授權
var isSRV = '${isSRV}';
var grid;
function DSC32800(){

	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC3_2800/');
	
	function buttonAuth(){
		var authButtons = {
			B0028:'BTN_CONFIRM',
			B0009:'BTN_CANCEL'		
		};
		<dz:grantButtons FUNC_ID="DSC32800"/>  
	}
	
	function initValidation(){
		Validation.addAllThese([
			[ 'validateLOAN_ID',  '授權帳號格式有誤',
				function(v){
					<%--授權帳號10碼英數字--%>
					return v.length == 10 && (/^[a-zA-Z0-9]+$/.test(v));
				}
			],
			[ 'validateID',  '授權繳款人ID格式有誤',
				function(v){
					<%--授權繳款人ID格式有誤--%>
					if(v && v!=''){
						return validation.checkID(v);
					}
					return true;
				}
			]
		]);
		
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
		valid1.define( "required" , { id: "LOAN_ID" , errMsg:"授權帳號不可空白!!" } );
		valid1.define( "validateLOAN_ID" , { id: "LOAN_ID"} );
		valid1.define( "validateID" , { id : "PAY_ID" } );
	}
	

	var gridController={
		initGrid : function(AUTH_TYPE){
			var cols = gridController.gridColumn[AUTH_TYPE];
			grid = new TableUI({
				table: $("grid"), pageSize : 10, allSortable: false, overDiv:true,			
				column:cols
			});
		},
		gridColumn : {
			"1" : [		//繳息	
				{header:"授權日期",key:"AUTH_DATE",render:function(rec,val){
					return localeDisplay.formatDate(val)+' '+ rec['AUTH_TIME'];
				}},
				{header:"貸款帳號", key:"LOAN_ID" },
				{header:"授權繳款人", key:"PAY_ID" },
				{header:"授權人員",key:"INPUT_ID", attrs:{style:"font-family:'EUDC'"}},  <%-- [20241104] 難字調整: 授權人員 --%>
				{header:"授權單位",key:"INPUT_DEPT"},
				{header:"入帳日期",key:"PAY_DATE",sortRule:'datetime'},
				{header:"作廢授權",key:"DELETE_DATE",sortRule:'datetime', render:function(rec,val){
					if(val && val!=''){
						return val;
					}
					if(rec['PAY_DATE']){
						return '已入帳';
					}
					return new Element('button',{'type':'button'}).addClassName('button').update("取消授權").observe('click',function(){
						buttons.doCancel(rec);
					});
				}}
			],
			"2" : [		//清償	
				{header:"授權日期",key:"CONFIRM_DATE",render:function(rec,val){
					return localeDisplay.formatDate(val)+' '+ rec['CONFIRM_TIME'];
				}},
				{header:"貸款帳號", key:"LOAN_ID" },
				{header:"授權人員",key:"CONFIRM_ID"},
				{header:"授權單位",key:"CONFIRM_DEPT"},
				{header:"入帳人員",key:"INPUT_ID"},
				{header:"作廢授權",key:"DELETE_DATE", render:function(rec,val){
					if(val && val!=''){
						return localeDisplay.formatDate(val)+' '+ rec['DELETE_TIME'];
					}
					if(rec['INPUT_ID']){
						return '已入帳';
					}
					return new Element('button',{'type':'button'}).addClassName('button').update("取消授權").observe('click',function(){
						buttons.doCancel(rec);
					});
				}}
			]
		}
	}
	
	var buttons={
		doQuery : function(){
			if(!valid1.validate()){
				return;
			}
			
			var reqMap={
				AUTH_TYPE:$F('AUTH_TYPE'),
				CONFIRM_DATE:$F('CONFIRM_DATE'),
				LOAN_ID:$F('LOAN_ID'),
				PAY_ID:$F('PAY_ID')	
			}
			
			ajaxRequest.post( 'query', {"reqMap":Object.toJSON(reqMap)}
				,function(resp){
					gridController.initGrid($F('AUTH_TYPE'));
					rtnList=resp.rtnList;
					grid.load(rtnList||[]);
				},function(resp){
					gridController.initGrid($F('AUTH_TYPE'));
					grid.load([]);
				}
			);
		}
		,doConfirm : function(){
			if(!valid1.validate()){
				return;
			}
			var LOAN_ID = $('LOAN_ID').value;
			if('X'==LOAN_ID.slice(-1) && "Y" == isSRV){
				alert("服務中心人員無法授權理財型帳號清償");
				return;
			}
	
			var reqMap={
				AUTH_TYPE:$F('AUTH_TYPE'),
				CONFIRM_DATE:$F('CONFIRM_DATE'),
				LOAN_ID:$F('LOAN_ID'),
				PAY_ID:$F('PAY_ID')	
			}
			
			ajaxRequest.post( 'confirm', {"reqMap":Object.toJSON(reqMap)}
				,function(resp){
					gridController.initGrid($F('AUTH_TYPE'));
					rtnList=resp.rtnList;
					grid.load(rtnList||[]);
				}
			);
		}
		,doCancel : function(reqMap){
			if(!valid1.validate()){
				return;
			}
	
			reqMap['AUTH_TYPE'] = $F('AUTH_TYPE');
			reqMap['qLOAN_ID'] = $F('LOAN_ID');
			
			ajaxRequest.post( 'cancel', {"reqMap":Object.toJSON(reqMap)}
				,function(resp){
					gridController.initGrid($F('AUTH_TYPE'));
					rtnList=resp.rtnList;
					grid.load(rtnList||[]);
				}
			);
		}
	}
	
	var actions = {
		chgAUTH_TYPE : function(){
			$('PAY_ID').setValue('');
			if('1'==$F('AUTH_TYPE')){
				$('PAY_ID').enable();
			}else{
				$('PAY_ID').disable();
			}
		}
	}
	
	return {
		initApp : function() {
        	<cathay:LocaleDisplay dateFields="CONFIRM_DATE" sysCode= 'DS' var='localeDisplay' />  
			PageUI.createPageWithAllBodySubElement('DSC32800', '繳款方式', '繳現授權作業');
			
			initValidation();
			
			gridController.initGrid('1');//初始TABLEUI
			
			$('BTN_QUERY').observe('click',buttons.doQuery);
			$('BTN_CONFIRM').observe('click',buttons.doConfirm);
			
			$('AUTH_TYPE').observe('change',actions.chgAUTH_TYPE);
			
			$('CONFIRM_DATE').setValue('${today}');
			
			buttonAuth();
			PageUI.resize();
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
			<td class="tbYellow" width="5%">授權種類</td>
			<td class="tbYellow2" width="4%">
				<select id="AUTH_TYPE">
					<c:forEach var="map" items="${AUTH_TYPE_MAP}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" width="5%">授權日期</td>
			<td class="tbYellow2" width="4%">
				<input id="CONFIRM_DATE" type="text" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="5%">授權帳號</td>
			<td class="tbYellow2" width="4%">
				<input id="LOAN_ID" type="text" maxlength="10" onblur="this.value = this.value.toUpperCase()" />
			</td>
			<td class="tbYellow" width="5%">授權繳款人</td>
			<td class="tbYellow2" width="4%">
				<input id="PAY_ID" type="text" maxlength="10" onblur="this.value = this.value.toUpperCase()" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="5%">授權人員</td>
			<td class="tbYellow2" width="4%">
				<input id="CONFIRM_ID" type="text" class="textBox2" style="background-color:#FCFFCB" alt="ch" readonly="readonly" value='${CONFIRM_ID}'/>  <%-- [20241104] 難字調整: 授權人員 --%>
			</td>
			<td class="tbYellow" width="5%">授權單位</td>
			<td class="tbYellow2" width="4%">
				<input id="CONFIRM_DEPT" type="text" class="textBox2" style="background-color:#FCFFCB" value='${CONFIRM_DEPT}' readonly />
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" align="center" colspan='4'>
			<input id="BTN_QUERY" type="button" value="查詢" class="button" align="center" >
			<input id="BTN_CONFIRM" type="button" value="授權" class="button" align="center" > 
			<!-- <input id="BTN_CANCEL" type="button" value="取消授權" class="button" align="center" >  --> 			
		</tr>
	</table>
	<table id="grid"></table>
</form>
</body>
</html>
