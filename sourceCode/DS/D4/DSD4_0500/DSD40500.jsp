<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!--
程式：DSD40500.jsp
作者：溫子?
功能：清償證明領迄作業
完成：2013/9/


[20190725]問題單(20190724163837)：	
1.查詢後的表格改為每頁顯示10筆
2.不清除TableUI的筆數顯示
3.選取的紀錄與底下顯示需同步

[20240328]
難字調整
高強禾
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<%-- [20240328] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<!--alert訊息-->

<script type="text/javascript">
//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSD40500().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSD40500(){
var grid;
var grid2;
var D200Map={};
	// 按鈕權限
	var buttonAuth = function(){
		var authButtons = {
			B0028 : 'BTN_CONFIRM'
		};
		<dz:grantButtons FUNC_ID='DSD40500'/>
	};
	function initValidation(){
			//查詢用檢核
				
			Validation.addAllThese([
				[ 'oneMonthInterval', '清償證明開立日期區間必在1個月內，請縮小查詢範圍'
					, function(v, element) {
						var date_str = $F('STR_OPEN_DATE'),
							date_end = $F('END_OPEN_DATE');
	
						if(!Validation.get('IsEmpty').test(date_str) && !Validation.get('IsEmpty').test(date_end)){	//確認有輸入
							if(isROCdate(date_str)){
								return !(diffDayROC(date_str, date_end) > 30);
							}else{
								return !(diffDayY2K(date_str, date_end) > 30);
							}
						}
						return true;
					}
				],
				['requiredifblank1', '若未輸入貸款帳號則不可為空', function(v, element) {
					var LOAN_ID_Q = $F('LOAN_ID_Q'),
					    AUDIT_ID = $F('AUDIT_ID');
					if(Validation.get('IsEmpty').test(LOAN_ID_Q) && Validation.get('IsEmpty').test(AUDIT_ID)){
						return false;
					}
					return true;
				}]
				,
				['requiredifblank2', '若未輸入貸款帳號則不可為空', function(v, element) {
					var LOAN_ID_Q = $F('LOAN_ID_Q'),
					    STR_OPEN_DATE = $F('STR_OPEN_DATE');
					if(Validation.get('IsEmpty').test(LOAN_ID_Q) && Validation.get('IsEmpty').test(STR_OPEN_DATE)){
						return false;
					}
					return true;
				}]
				,
				['requiredifblank3', '若未輸入貸款帳號則不可為空', function(v, element) {
					var LOAN_ID_Q = $F('LOAN_ID_Q'),
					    END_OPEN_DATE = $F('END_OPEN_DATE');
					if(Validation.get('IsEmpty').test(LOAN_ID_Q) && Validation.get('IsEmpty').test(END_OPEN_DATE)){
						return false;
					}
					return true;
				}],
				[ 'validateLOAN_ID_10',  '貸款帳號長度不正確 需為10碼',
					function(v){
						if(!Validation.get('IsEmpty').test(v)){	//確認有輸入
							return (v.length != 10) ? false : true ;
						}
						return true;
					}
				]
			]);
			valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'})
			valid1.define('oneMonthInterval', {id: 'END_OPEN_DATE', errMsg: '清償證明開立日期區間不可超過30天'} );
			valid1.define('requiredifblank1', {id: 'AUDIT_ID', errMsg: '清償人員不得為空'});
			valid1.define('requiredifblank2', {id: 'STR_OPEN_DATE', errMsg: '清償證明開立日期(起)不得為空'});
			valid1.define('requiredifblank3', {id: 'END_OPEN_DATE', errMsg: '清償證明開立日期(迄)不得為空'});
			//valid1.define( "required" , { id: "LOAN_ID_Q" , errMsg:"貸款帳號不可空白!!" } );
			valid1.define( "validateLOAN_ID_10" , { id: "LOAN_ID_Q"});
	}
	
	var ajaxPost = function (actionName, params, successAction, errorAction){	
		new Ajax.Request( '<%=dispatcher%>/DSD4_0500/' + actionName,
		{  
			parameters: params, 
			onSuccess: function(response)
			{
				var resp = response.responseJSON
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
						successAction(resp);
					}
				}else{
					if(errorAction){
						errorAction(resp);
					}
				}
			}
		});
	};
	var buttons ={
	
		doQuery : function(){
			// 檢核
			if(!valid1.validate()){ 
				return; 
			}
			var reqMap = {
				STR_OPEN_DATE : $F('STR_OPEN_DATE'),
				END_OPEN_DATE : $F('END_OPEN_DATE'),
				CRED_DEPT : $F('CRED_DEPT'),
				AUDIT_ID : $F('AUDIT_ID'),
				LOAN_ID : $F('LOAN_ID_Q')
			}
			// 頁面傳入參數
			ajaxPost( 'query' , { 'reqMap' : Object.toJSON(reqMap) },
				function(resp){	
				<%-- [20190725]問題單：不清除TableUI的筆數顯示 --%>
					$$('#form2 span[class="clean"]').each(
						function(text){
							text.innerHTML = '';
						}
					);		
					grid.load(resp.rtnList || []);					
					grid2.load([]);
					$('form2').reset();
					
				},function(resp){
					grid.load([]);
					grid2.load([]);
					
					$('form2').reset();
					$$('#form2 span[class="clean"]').each(
						function(text){
							text.innerHTML = '';
						}
					);
				}
			);
		}
		,doShow : function(records){
			//var datas=grid.getCheckedRecord();	
			ajaxPost( 'show' , { 'LOAN_ID' : records[0]['LOAN_ID'] },
					function(resp){			
						$('LOAN_ID').update(records[0]['LOAN_ID']);
						grid2.load(resp.D150List || []);
						D200Map=resp.D200Map||'';
						
						if (D200Map['PAY_OFF_STATUS']){
							$(D200Map['PAY_OFF_STATUS']).checked = true;
						}
						$('NOTE').value=D200Map['NOTE']||'';
						$('INPUT_ID_NAME').update(D200Map['INPUT_ID_NAME']);
						$('INPUT_DATE').update(Date.toROC(D200Map['INPUT_DATE']||''));
					},function(resp){
						grid2.load([]);
						
						$$('#grid input[type=radio]:checked').each(
							function(text){
								text.checked = false;
							}
						);
						
						$('form2').reset();
						$$('#form2 span[class="clean"]').each(
							function(text){
								text.innerHTML = '';
							}
						);
					}
				);
		}
		,doConfrim : function(){
			var rtnList = grid.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行確認作業");
					return;
				}
			var chkList = grid.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行確認作業");
				  	return;
				}
			var check=false	
			$$('#table2 input[type=radio][name=PAY_OFF_STATUS]:checked').each(function(ele){
				D200Map['PAY_OFF_STATUS']=ele.value;
				check=true;
			})
			if(!check){
				alert("請選擇清償證明領迄狀態");
				return;
			}
			D200Map['NOTE']=$F('NOTE');
			if(!confirm("確定要執行確認作業？")){
				return;
			}
			ajaxPost( 'confirm' , { 'D200Map' : Object.toJSON(D200Map) },
					function(resp){		
						grid2.load(resp.D150List || []);
						D200Map=resp.D200Map||'';
						
						if (D200Map['PAY_OFF_STATUS']){
							$(D200Map['PAY_OFF_STATUS']).checked = true;
						}
						$('NOTE').value=D200Map['NOTE']||'';
						$('INPUT_ID_NAME').update(D200Map['INPUT_ID_NAME']);
						$('INPUT_DATE').update(Date.toROC(D200Map['INPUT_DATE']||''));
					}
				);
		}
	}
	return {

		initApp : function(){
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay" dateFields="STR_OPEN_DATE END_OPEN_DATE"/>
			PageUI.createPageWithAllBodySubElement('DSD40500', '清償作業', '清償證明領迄作業');
			grid = new TableUI(
					<%-- [20190725]問題單：每頁顯示筆數改為10 --%>
					{table: $("grid"), pageSize : 10, allSortable: true, overDiv:false,	
					autoCheckBox:{
							text:'選取',
							type:'radio',
							action:function(node, boxStatus, records){
								<%-- [20190725]問題單：radio解除時不執行function --%>
								if(!boxStatus){ return; }
								buttons.doShow(records);
							}
						},		
					<%-- [20240328] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{header:"貸款帳號",key:"LOAN_ID"},
						<%-- [20240328] 難字調整：姓名 --%>
						{header:"姓名",key:"BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
						{header:"借款人ID",key:"BORROW_ID",
							render : function (rec , val){
								return CSRUtil.maskHandler.getMaskID(val);
						}},
						{header:"清償證明開立日期",key:"OPEN_DATE",
							render : function (rec , val){
								return Date.toROC(val || "");									
							}
						},
						{header:"清償證明狀態",key:"STATUS_NM"},
						{header:"清償證明領迄狀態",key:"PAY_OFF_STATUS_NM"},
						{header:"領取單位",key:"RECEIVE_DEPT"},
						{header:"確認日期",key:"FINAL_DATE",
							render : function (rec , val){
								return Date.toROC(val || "");									
							}
						},
						{header:'補發', key:'PAYOFF_LIMIT',
							render : function (record , value){
								if(value == '7') {
									return 'V';
								} else {
									return '';
								}
							}
						}
					]
				});
					
			grid2 = new TableUI(
					{table: $("grid2"), pageSize : 20, allSortable: true, overDiv:false,			
					<%-- [20240328] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{header:"貸款帳號",key:"LOAN_ID"},
						<%-- [20240328] 難字調整：姓名 --%>
						{header:"姓名",key:"BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }}
					]
				});
			$('BTN_QUERY').observe('click',buttons.doQuery);
			$('BTN_CONFIRM').observe('click',buttons.doConfrim);
			
			// 下拉選單控制
			//$("CRED_DEPT").disable();
			
			//$("CRED_DEPT").value = "${LOGIN_CRED_DEPT}";

			//<c:if test="${LOGIN_CRED_DEPT eq '2'}">
			//	$("CRED_DEPT").enable();
			//</c:if>
			
			//先把畫面區塊都調整到位再顯示訊息
			<%-- [2019/04/02] 清償作業優化(第二階段) - 承辦科別改為"非總公司"與"總公司"，取消承辦科別預設--%>
			if ("${LOGIN_CRED_DEPT}" && "${LOGIN_CRED_DEPT}" != '' && "${LOGIN_CRED_DEPT}" != '0' ){
				$("CRED_DEPT").value = "${LOGIN_CRED_DEPT}";
			}
			if ("${LOGIN_AUDIT_ID}" && "${LOGIN_AUDIT_ID}" != '' && "${LOGIN_AUDIT_ID}" != '0' ){
				$("AUDIT_ID").setValue("${LOGIN_AUDIT_ID}");
			}
			
			buttonAuth();
			
			initValidation();
			
			fix();
			
			//初始頁面alert訊息用	
			displayMessage();
		}
	}	
}
</script>
</head>
<body>
<form id='form1' name='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
	<tr>
		<td class="tbYellow" width="8%">清償證明開立日期</td>
		<td class="tbYellow2" width="14%">
			<input type="text" class="input" name="STR_OPEN_DATE" id="STR_OPEN_DATE" value="${CURRENT_DATE}"/>
			~
			<input type="text" class="input" name="END_OPEN_DATE" id="END_OPEN_DATE" value="${CURRENT_DATE}"/>
		</td>
		<td class="tbYellow" width='8%'>
			承辦科別
		</td>
		<td class="tbYellow2" width="14%">
			<select id="CRED_DEPT" name = "CRED_DEPT">
				<c:forEach items="${CRED_DEPT_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width='8%'>
			清償人員
		</td>
		<td class="tbYellow2" width="14%">
			<%-- [20240328] 難字調整：清償人員 --%>
			<select id="AUDIT_ID" name = "AUDIT_ID" alt="ch">
				<option value="">全部</option>
				<c:forEach items="${AUDIT_ID_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width="8%">貸款帳號</td>
		<td class="tbYellow2" width="14%">
			<input id="LOAN_ID_Q" type="text" class="textBox2"  onblur="this.value = this.value.toUpperCase()"  size="12" maxlength="10" />
		</td>
		<td class="tbYellow2" width="12%" align="center">
			<input id="BTN_QUERY" type="button" value="查詢" class="button"> 
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan='9' align='center'>
			<input id="BTN_CONFIRM" type="button" value="確認" class="button"> 
		</td>
	</tr>
	</table>
</form>
<form id='form2' name='form2' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
	<table id='grid'></table>
	<table  id='table2'width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
	<tr>
	<td class="tbYellow" width="20%">貸款帳號</td>
		<td class="tbYellow2" >
			<span id='LOAN_ID' class='clean'></span></td>
	</tr>
	<tr>
		<td class="tbYellow" >清償證明領迄狀態</td>
		<td class="tbYellow2">
			<c:forEach items="${PAY_OFF_STATUS_LIST}" var="item">
				<span style="display:inline-block" field="LIST">
					<input id="${item.key}" name="PAY_OFF_STATUS" type="radio" value="${item.key}">${item.value}
				</span>
			</c:forEach>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >備註</td>
		<td class="tbYellow2">
			<textarea id="NOTE" rows="5" cols="35"></textarea>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >將同步異動相關帳號之<br>【契約狀況】或【備註內容】</td>
		<td class="tbYellow2" >
			<table id='grid2'></table>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >確認人員</td>
		<td class="tbYellow2" >
			<%-- [20240328] 難字調整：確認人員 --%>
			<span id='INPUT_ID_NAME' class='clean' style="font-family:'EUDC'"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >確認日期</td>
		<td class="tbYellow2" >
			<span id='INPUT_DATE' class='clean'></span>
		</td>
	</tr>
	</table>
</form>
</body>
</html>