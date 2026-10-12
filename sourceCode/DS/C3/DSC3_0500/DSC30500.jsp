<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC30500.jsp
功能：轉帳個件輸入
作者：溫子
完成：2013/05
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC30500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC30500(){
var rtnMap=[];
var check;

function buttonAuth(){
	var authButtons = {	
		B0003:"BTN_INSERT",	
		B0005:"BTN_DELETE",	
		B0157:"BTN_ONLINE"			
	};
	<dz:grantButtons FUNC_ID="DSC30500"/>
}
	
function initValidation(){		
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});	
	}
	
function validDefine1(){
	valid1.reset();
	valid1.clear();
	valid1.define('required' , [{ id : "LOAN_ID", errMsg:"請輸入貸款帳號"}]);	
	valid1.define('required' , [{ id : "PAY_TERM", errMsg:"請輸入應繳期數"}]);
	valid1.define('required' , [{ id : "SER_NO", errMsg:"請輸入序號"}]);
	valid1.define('validate-number' , [{ id : "PAY_TERM", errMsg:"應繳期數請輸入有效數字格式"}]);
	valid1.define('validate-number' , [{ id : "SER_NO", errMsg:"序號請輸入有效數字格式"}]);			
}
function validDefine2(){ //新增時的檢核
	valid1.reset();
	valid1.clear();
	valid1.define('required' , [{ id : "LOAN_ID", errMsg:"請輸入貸款帳號"}]);	
	valid1.define('required' , [{ id : "PAY_TERM", errMsg:"請輸入應繳期數"}]);
	//valid1.define('required' , [{ id : "TRANS_YM", errMsg:"請輸入轉帳年月"}]);
	valid1.define('required' , [{ id : "TRANS_YM_T", errMsg:"請輸入轉帳年月"}]);
	valid1.define('validate-selection' , [{ id : "TRANS_GROUP", errMsg:"請選擇轉帳組別"}]);
	valid1.define('validate-selection' , [{ id : "TRANS_BANK", errMsg:"請選擇轉帳銀行"}]);
	valid1.define('validate-selection' , [{ id : "SPEC_CODE", errMsg:"請選擇是否不計延滯息"}]);
	valid1.define('validate-number' , [{ id : "PAY_TERM", errMsg:"應繳期數請輸入有效數字格式"}]);
	valid1.define('validate-number' , [{ id : "SER_NO", errMsg:"序號請輸入有效數字格式"}]);
	valid1.define('validate-ROCDate' , [{ id : "TEL_DATE", errMsg:"照會日期請輸入正確的民國日期格式"}]);
}
	
//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_0500/" + actionName,
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
	
		var buttons ={
		getMap :function(){
				return {			
					//TRANS_YM : $F('TRANS_YM'),
					TRANS_YM : $F('TRANS_YM_T'),
					TRANS_GROUP :$F('TRANS_GROUP'),
					TRANS_BANK : $F('TRANS_BANK'),
					SPEC_CODE :$F('SPEC_CODE'),
					LOAN_ID :$F('LOAN_ID'),
					SER_NO: $F('SER_NO'),
					PAY_TERM : $F('PAY_TERM'),
					//ACNT_CODE : $F('ACNT_CODE'),
					//ACNT_DATE : getY2KToday(),
					TEL_DATE : $F('TEL_DATE'),
					HOUR : $F('HOUR'),
					MIN : $F('MIN')
			}
		}
		
		,doQuery : function(){
			validDefine1();
			if(!valid1.validate()){
				return;
			}
			ajaxPost( 'query', {LOAN_ID: $F('LOAN_ID'),PAY_TERM:$F('PAY_TERM'),SER_NO:$F('SER_NO')}
				,function(resp){
					rtnMap=resp.rtnList;
					//$('TRANS_YM').value=rtnMap.TRANS_YM;
					$('TRANS_YM_T').value=rtnMap.TRANS_YM_T;
					$('TRANS_GROUP').value=rtnMap.TRANS_GROUP;
					$('TRANS_BANK').value=rtnMap.TRANS_BANK;
					$('SPEC_CODE').value=rtnMap.SPEC_CODE;
					$('LOAN_ID_OLD').value=rtnMap.LOAN_ID;
					$('SER_NO_OLD').value=rtnMap.SER_NO;
					$('PAY_TERM_OLD').value=rtnMap.PAY_TERM;
					//$('ACNT_CODE').value=rtnMap.ACNT_CODE;
					//$('ACNT_DATE').value=rtnMap.ACNT_DATE;
					if (rtnMap.TEL_DATE) {
						$('TEL_DATE').value=rtnMap.TEL_DATE;
						$('HOUR').value=rtnMap.HOUR;
						$('MIN').value=rtnMap.MIN;
					} else {
						$('TEL_DATE').value='';
						$('HOUR').value='';
						$('MIN').value='';
					}
					check='ok'
					$('BTN_INSERT').enable();
					$('message').update(resp.message);
				},function(resp){
					//$('TRANS_YM').value='';
					$('TRANS_YM_T').value='';
					$('TRANS_GROUP').value='';
					$('TRANS_BANK').value='';
					$('SPEC_CODE').value='';
					$('LOAN_ID_OLD').value='';
					$('SER_NO_OLD').value='';
					$('PAY_TERM_OLD').value='';
					$('TEL_DATE').value='';
					$('HOUR').value='';
					$('MIN').value='';
					$('BTN_INSERT').enable();
					check='error'
				}
			);
		
		}
		,doInsert : function (){
		
			validDefine2();
			if(!valid1.validate()){
				return;
			}
			if(check=='ok'&&($F('LOAN_ID')!=$F('LOAN_ID_OLD')||$F('PAY_TERM')!=$F('PAY_TERM_OLD')/*||$F('SER_NO')!=$F('SER_NO_OLD')*/)){
				alert("與查詢時的資訊不同,請先查詢後再做新增!!");
				return;
			}
			if(!$F('LOAN_ID_OLD')){
				alert("無查詢資料，無法新增!");
				return;
			}
			if($F('SPEC_CODE')!='1'){
				if(!$F('TEL_DATE')){
					if(!confirm('照會日期未輸入,確認是否已送聲明書')){     
		   			 	return;
		   			}
				}else{
					if(!$F('HOUR')||!$F('MIN')){
						alert('請輸入照會時間');
						return;
					}
				}
			}
			
			ajaxPost( 'insert', {dataMap : Object.toJSON(buttons.getMap())}
				,function(resp){
					rtnMap=resp.rtnList;
					//$('TRANS_YM').value=rtnMap.TRANS_YM ||'';
					$('TRANS_YM_T').value=rtnMap.TRANS_YM_T ||'';
					$('TRANS_GROUP').value=rtnMap.TRANS_GROUP ||'';
					$('TRANS_BANK').value=rtnMap.TRANS_BANK ||'';
					$('SPEC_CODE').value=rtnMap.SPEC_CODE ||'';
					$('LOAN_ID_OLD').value=rtnMap.LOAN_ID ||'';
					$('SER_NO').value=rtnMap.SER_NO ||'';
					$('SER_NO_OLD').value=rtnMap.SER_NO ||'';
					$('PAY_TERM_OLD').value=rtnMap.PAY_TERM ||'';
					//$('ACNT_CODE').value=rtnMap.ACNT_CODE ||'';
					//$('ACNT_DATE').value=getY2KToday();
					if (rtnMap.TEL_DATE) {
						$('TEL_DATE').value=rtnMap.TEL_DATE;
						$('HOUR').value=rtnMap.HOUR;
						$('MIN').value=rtnMap.MIN;	
					} else {
						$('TEL_DATE').value='';
						$('HOUR').value='';
						$('MIN').value='';
					}
				}
			);
		}
		,doDelete : function(){
		
			if(!$F('LOAN_ID_OLD')){
				alert("無查詢資料，無法刪除!");
				return;
			}
			if(!confirm('確認是否要刪除該筆資料')){     
   			 	return;
   			}
			if($F('LOAN_ID')!=$F('LOAN_ID_OLD')||$F('PAY_TERM')!=$F('PAY_TERM_OLD')||$F('SER_NO')!=$F('SER_NO_OLD')){
				alert("與查詢時的資訊不同,請先查詢後再做刪除!!");
				return;
			}
			ajaxPost( 'delete', {dataMap : Object.toJSON(buttons.getMap())}
				,function(resp){
					//$('LOAN_ID').value='';
					//$('SER_NO').value='';
					//$('PAY_TERM').value='';
					//$('TRANS_YM').value='';
					$('TRANS_YM_T').value='';
					$('TRANS_GROUP').value='';
					$('TRANS_BANK').value='';
					$('SPEC_CODE').value='';
					$('LOAN_ID_OLD').value='';
					$('SER_NO_OLD').value='';
					$('PAY_TERM_OLD').value='';
					//$('ACNT_CODE').value='';
					$('TEL_DATE').value='';
					$('HOUR').value='';
					$('MIN').value='';
				}
			);
		}
		
		,doOnline : function (){
			if(!$F('LOAN_ID_OLD')){
				alert("無查詢資料，無法加抽!");
				return;
			}
			if($F('LOAN_ID')!=$F('LOAN_ID_OLD')||$F('PAY_TERM')!=$F('PAY_TERM_OLD')||$F('SER_NO')!=$F('SER_NO_OLD')){
				alert("與查詢時的資訊不同,請先查詢後再做加抽!!");
				return;
			}
			
			ajaxPost( 'online', {dataMap : Object.toJSON(buttons.getMap())}
				,function(resp){					
					rtnMap=resp.rtnList;
					//$('TRANS_YM').value=rtnMap.TRANS_YM ||'';
					$('TRANS_YM_T').value=rtnMap.TRANS_YM_T ||'';
					$('TRANS_GROUP').value=rtnMap.TRANS_GROUP ||'';
					$('TRANS_BANK').value=rtnMap.TRANS_BANK ||'';
					$('SPEC_CODE').value=rtnMap.SPEC_CODE ||'';
					$('LOAN_ID_OLD').value=rtnMap.LOAN_ID ||'';
					$('SER_NO').value=rtnMap.SER_NO ||'';
					$('SER_NO_OLD').value=rtnMap.SER_NO ||'';
					$('PAY_TERM_OLD').value=rtnMap.PAY_TERM ||'';
					//$('ACNT_CODE').value=rtnMap.ACNT_CODE ||'';
					//$('ACNT_DATE').value=getY2KToday();
					if (rtnMap.TEL_DATE) {
						$('TEL_DATE').value=rtnMap.TEL_DATE;
						$('HOUR').value=rtnMap.HOUR;
						$('MIN').value=rtnMap.MIN;	
					} else {
						$('TEL_DATE').value='';
						$('HOUR').value='';
						$('MIN').value='';
					}
				}
			);
		}
		
		,chgSPECList : function (){
			if($F('SPEC_CODE')=='1'){
				$('TEL_DATE').disable();
				$('HOUR').disable();
				$('MIN').disable();
			}else{
				$('TEL_DATE').enable();
				$('HOUR').enable();
				$('MIN').enable();
			}
		}
	}

	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC30500', '繳款方式', '轉帳個件輸入');
				//畫面檢核
				initValidation();
				buttonAuth();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('BTN_INSERT').observe('click',buttons.doInsert);
				$('BTN_DELETE').observe('click',buttons.doDelete);
				$('BTN_ONLINE').observe('click',buttons.doOnline);
				$("SPEC_CODE").observe('change', buttons.chgSPECList);
				$('BTN_INSERT').disable();
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
			<td class="tbYellow" width="12%" >貸款帳號</td>
			<td class="tbYellow2" width="18%">
				<input id="LOAN_ID"  type="text" class="textBox2"  onblur="this.value = this.value.toUpperCase()" size='12' maxlength="10" fieldName = "貸款帳號"/>
			</td>
			<td class="tbYellow" width="12%" >應繳期數</td>
			<td class="tbYellow2" width="18%">
				<input id="PAY_TERM"  type="text" class="textBox2"  datatype="number" size='5' maxlength="3" fieldName = "應繳期數"/>
			</td>
			<td class="tbYellow" width="12%" >序號</td>
			<td class="tbYellow2" width="18%">
				<input id="SER_NO"  type="text" class="textBox2"  value="1" datatype="number" size='4' maxlength="2" fieldName = "序號"/>
			</td>
			<td class="tbYellow2" width="10%" align="center">
				<input id="BTN_QUERY" type="button" value="查詢" class="button"> 
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" width="30%" colspan="7" align="center">
				<input id="BTN_INSERT" type="button" value="新增" class="button"> 
				<input id="BTN_DELETE" type="button" value="刪除" class="button">
				<input id="BTN_ONLINE" type="button" value="即時個件加抽" class="button">
			</td>
		</tr>
		<tr>
			<td class="tbBox3" width="5%"  align="center" colspan="7"><b>轉帳個件輸入查詢結果</b></td>
		</tr>
		<tr>
			<td class="tbYellow" width="5%" >轉帳年月</td>
			<td class="tbYellow2" >
			<!-- <input type = 'hidden' name = 'TRANS_YM' id = 'TRANS_YM'/> -->
			<input id="TRANS_YM_T"  type="text" class="textBox2" size='7' maxlength="5"/>
			</td>
			<td class="tbYellow" width="12%" >轉帳組別</td>
				<td class="tbYellow2" width="10%">
				<select id="TRANS_GROUP">
						<option value="">請選擇</option>
							<c:forEach var="map" items="${TRANS_GROUP_List}">
									<option value="${map.key}">${map.value}</option>
							</c:forEach>
				</select> 
				</td>
			<td class="tbYellow" width="12%">轉帳銀行</td>
				<td class="tbYellow2" width="10%" colspan = "2">
				<select id="TRANS_BANK">
						<option value="">請選擇</option>
							<c:forEach var="map" items="${TRANS_List}">
									<option value="${map.key}">${map.value}</option>
							</c:forEach>
				</select> 
			</td>
				<input  type = 'hidden' name = 'LOAN_ID_OLD' id = 'LOAN_ID_OLD'/>
				<input  type = 'hidden' name = 'SER_NO_OLD' id = 'SER_NO_OLD'/>
				<input  type = 'hidden' name = 'PAY_TERM_OLD' id = 'PAY_TERM_OLD'/>
				<!-- <input  type = 'hidden' name = 'ACNT_CODE' id = 'ACNT_CODE'/> -->
				<!-- <input  type = 'hidden' name = 'ACNT_DATE' id = 'ACNT_DATE'/> -->
		</tr>
		<tr>			
			<td class="tbYellow" width="12%">不計延滯息</td>
				<td class="tbYellow2" width="10%">
				<select id="SPEC_CODE">
						<option value="">請選擇</option>
							<c:forEach var="map" items="${SPEC_CODE_List}">
									<option value="${map.key}">${map.value}</option>
							</c:forEach>
				</select> 
			</td>
			<td class="tbYellow" width="5%" >照會日期</td>
			<td class="tbYellow2">
				<input id = "TEL_DATE" name = "TEL_DATE" type="text" class="textBox2" size="9" maxlength="7" datatype ="ROCDate"/>
				<img src="/DSWeb/images/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('TEL_DATE'))">
			</td>
			<td class="tbYellow" width="5%" >照會時間</td>
			<td class="tbYellow2" colspan = "2" >
				<select id="HOUR">
					<option value="">請選擇</option>
					<c:forEach var="map" items="${HOUR_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>時
				<select id="MIN">
					<option value="">請選擇</option>
					<c:forEach var="map" items="${MIN_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>分
			</td>
		</tr>
	</table>
	<tr>
		<td>
			<Strong> <span id = "message"></span></Strong>
		</td>
	</tr>
</form>
</body>
</html>