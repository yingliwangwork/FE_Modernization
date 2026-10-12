<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSD41500.jsp
功能：清償派件及轉移
作者：劉懿葶
完成：2019/05/07

[20240328]
難字調整
高強禾
-->	
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible"> 

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
 
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src="${htmlBase}/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
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
<script type='text/javascript'>
Event.observe(window, 'load', new DSD41500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD41500() {
	var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1500/');
	//畫面檢核
	function initValidation(){		
		Validation.addAllThese([
			[ 'oneMonthInterval', '輸入日期區間必在30天內，請縮小查詢範圍'
				, function(v, element) {
					var date_str = $F('STR_INPUT_DATE'),
						date_end = $F('END_INPUT_DATE');

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
			['checkInputLength10', '輸入值超出長度限制', function( v , element  ) {
				if(v){
					return v.length == 10;
				}
				return true;
			}],
			['validate-digits-word', '需為英數字', function(v) {
				return Validation.get('IsEmpty').test(v) || /^(\d|\w)+$/.test(v);
			}],
			['requiredifblank1', '若未輸入貸款帳號則不可為空', function(v, element) {
				var LOAN_ID = $F('LOAN_ID'),
				    OLD_EMP_ID = $F('OLD_EMP_ID');
				if(Validation.get('IsEmpty').test(LOAN_ID) && Validation.get('IsEmpty').test(OLD_EMP_ID)){
					return false;
				}
				return true;
			}]
			,
			['requiredifblank2', '若未輸入貸款帳號則不可為空', function(v, element) {
				var LOAN_ID = $F('LOAN_ID'),
				    STR_INPUT_DATE = $F('STR_INPUT_DATE');
				if(Validation.get('IsEmpty').test(LOAN_ID) && Validation.get('IsEmpty').test(STR_INPUT_DATE)){
					return false;
				}
				return true;
			}]
			,
			['requiredifblank3', '若未輸入貸款帳號則不可為空', function(v, element) {
				var LOAN_ID = $F('LOAN_ID'),
				    END_INPUT_DATE = $F('END_INPUT_DATE');
				if(Validation.get('IsEmpty').test(LOAN_ID) && Validation.get('IsEmpty').test(END_INPUT_DATE)){
					return false;
				}
				return true;
			}]
		]);
		valid = new Validation('form1', {focusOnError:true, immediate:false , mode: 'validator'});
		
		valid.define('requiredifblank1', {id: 'OLD_EMP_ID', errMsg: '原承辦人不得為空'});
		valid.define('requiredifblank2', {id: 'STR_INPUT_DATE', errMsg: '輸入日期(起)不得為空'});
		valid.define('requiredifblank3', {id: 'END_INPUT_DATE', errMsg: '輸入日期(迄)不得為空'});
		valid.define('validate-date-db', {id: 'STR_INPUT_DATE', errMsg: '輸入日期(起)須為日期格式'});
		valid.define('validate-date-db', {id: 'END_INPUT_DATE', errMsg: '輸入日期(迄)須為日期格式'});
		valid.define('oneMonthInterval', {id: 'END_INPUT_DATE', errMsg: '塗銷申請日區間必在30天內'});
		valid.define('validate-digits-word', {id: 'LOAN_ID', errMsg: '貸款帳號需為英數字'});
		valid.define('checkInputLength10', {id: 'LOAN_ID', errMsg: '貸款帳號長度需為10碼'});
	}
	var actions = {
		//[A區]資料
		getreqMap : function (){
			var sendRecord = {
				LOAN_ID : $F('LOAN_ID'), 
				OLD_EMP_ID : $F('OLD_EMP_ID'),
				STR_INPUT_DATE : $F('STR_INPUT_DATE'),
				END_INPUT_DATE : $F('END_INPUT_DATE')
			};
			return sendRecord;
	    },
	    //[C區]資料
	    getreqMap2 : function (){
			var sendRecord = {
				NEW_EMP_ID : $F('NEW_EMP_ID')
			};
			return sendRecord;
	    }			
	};
	var buttons = {
		doQuery : function(){		
			valid.reset();
			if(!valid.validate()){
				return;			
			}
			ajaxRequest.post( 'query' , { reqMap : Object.toJSON(actions.getreqMap())} ,
				function(resp){
					grid.load(resp.rtnList||[]);
				},
				function(resp){ 	
					grid.load([]);
				}
			);	
		},
		dAndt : function(){
			valid.reset();
			if(!valid.validate()){
				return;			
			}
			//確認有先做查詢動作
			var allRecords = grid.getAllRecords();
			if(!allRecords || allRecords.length === 0){
				alert('請先查詢再執行案件派件及轉移作業');
				return;
			}
			//[B區]資料
			var dataList = grid.getCheckedRecord(['LOAN_ID']);
			if(!dataList || dataList.length === 0){
				alert('請先選取資料再執行案件派件及轉移作業');
				return;
			}
			if($F('NEW_EMP_ID') == ""){
				alert('請選取新承辦人');
				return;
			}
			ajaxRequest.post( 'dAndt' , { queryMap : Object.toJSON(actions.getreqMap()), assignMap : Object.toJSON(actions.getreqMap2()),
									      dataList: Object.toJSON(dataList)},
				function(resp){
					grid.load(resp.rtnList||[]);
				}
			);	
		}
	};
    return{
    
    initApp : function(){
		    
		    PageUI.createPageWithAllBodySubElement("DSD41500","清償作業","清償派件及轉移");
		    
		    grid = new TableUI({
		    table : $("grid"),
		    pageSize : 10,
			allSortable : true, 
			autoCheckBox : {
				 type: "checkbox", 
				 text:'全選', 
				 isSelectAll: true
			},
			<%-- [20240328] 難字調整 --%>
			afterLoad: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},
			pageChange: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},
		    column:[
		    	{header:"貸款帳號", key :'LOAN_ID'},
		    	<%-- [20240328] 難字調整：借款人姓名、原承辦人 --%>
		    	{header:"借款人姓名", key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
				{header:"原承辦人", key :'OLD_EMP_NM', attrs:{ style:"font-family:'EUDC'" }},
				{header:"輸入日期", key :'INPUT_DATE'},
				{header:"承辦時間", key :'OLD_EMP_TIME',
					render : function (rec , val){
								return val.substr(0,19);
					}
				}				
		    ]
		    });
		    initValidation();
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_dAndt').observe('click', buttons.dAndt);
		    
			PageUI.resize();
		    displayMessage();
   	}
   };
}

</script>
</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<form name="form1" id="form1" method="post">

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>					
		
		<td class="tbYellow" align="center" width="10%">
			<font>原承辦人</font>
		</td>
		
		<td class="tbYellow2" bgcolor="#FAFBE1" align="center" width="10%">
			<%-- [20240328] 難字調整：原承辦人 --%>
			<select class="input" name="OLD_EMP_ID" id="OLD_EMP_ID" alt="ch">
				<option value="">請選擇</option>
					<c:forEach var="entry" items="${PROC_EMP_LIST}">
				<option value="${entry.key}" <c:if test="${userId eq entry.key}">selected</c:if>>${entry.value}</option>
					</c:forEach>
			</select>
		</td>
		
		<td class="tbYellow" align="center" width="10%">輸入日期
		</td>
		
		<td class="tbYellow2" align="center" width="20%">
			<input type="text" name="STR_INPUT_DATE" id="STR_INPUT_DATE" class="textBox2" size="10" maxlength="10"  tabindex="57" value="${STR_AUDIT_DATE}" />
				<img id="STR_DT_IMG" src="${imageBase}/CM/calendar.gif" alt="Date" height="14" width="14" onclick="getCalendarFor($('STR_INPUT_DATE'))">
			<span>~</span>
			<input type="text" name="END_INPUT_DATE" id="END_INPUT_DATE" class="textBox2" size="10" maxlength="10"  tabindex="57" value="${END_AUDIT_DATE}" />
				<img id="STR_DT_IMG" src="${imageBase}/CM/calendar.gif" alt="Date" height="14" width="14" onclick="getCalendarFor($('END_INPUT_DATE'))">
		</td>
		
		<td class="tbYellow" align="center" width="10%">
			<font>貸款帳號</font>
		</td>
		
        <td class="tbYellow2" bgcolor="#FAFBE1" align="left" width="20%">					
			<input id="LOAN_ID" name="LOAN_ID" type="text" class="textBox2" maxlength="10" size="30" value="${rtnList[0].LOAN_ID}" >
		</td>
		
		<td class="tbYellow2" align="center" width="20%">
			<input type="button" id="btn_query" class="button" value="查詢" />
		</td>
		
	</tr>
</table>

<table id='grid' class='grid' width="100%">
</table>

<table  width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" align="center" width="10%">
			<font>新承辦人</font>
		</td>
		
        <td class="tbYellow2" bgcolor="#FAFBE1" align="center" width="10%">	
			<%-- [20240328] 難字調整：新承辦人 --%>
			<select class="input" name="NEW_EMP_ID" id="NEW_EMP_ID"  alt="ch">
				<option value="">請選擇</option>
					<c:forEach var="entry" items="${PROC_EMP_LIST}">
				<option value="${entry.key}" <c:if test="${userId eq entry.key}">selected</c:if>>${entry.value}</option>
					</c:forEach>
			</select>
		</td>
					
        <td class="tbYellow2" bgcolor="#FAFBE1" align="center" width="10%">					
			<input id="btn_dAndt" type="button" class="button" value="案件派件及轉移">
		</td>
		
        <td class="tbYellow2" bgcolor="#FAFBE1"  width="70%">
		</td>
		
	</tr>
</table>
</form>
</body>
</html>