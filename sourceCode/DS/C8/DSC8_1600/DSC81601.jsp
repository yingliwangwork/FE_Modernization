<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>


<!--
程式：DSC81601.jsp
功能：保人資料變更明細
作者：余凱鈞
完成：2013/07/

[20230321]
難字調整
高強禾
[20241106]調整聯徵授信餘額月報資料檔案格式:增加[前行庫用途]
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<%-- [20230321] 難字調整，因修改DSZ01000.js內容，為了使server重新讀取js，增加?v=2 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js?v=2"></script> <%-- 地址用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>  <%-- 日曆用--%>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC81601().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC81601(){
var grid;
var NEW_GAGE_ADDR;
var rtnMap;
var SOURCE;
var valid1;
var valid2;
var RELATION;

// 地址輸入不檢核的欄位
var notCheck = {
	CITY_NAME : "CITY_NAME",
	TOWN_NAME : "TOWN_NAME",
	INPUT_ZIPCODE : "INPUT_ZIPCODE"
	//INPUT_ADDR : "INPUT_ADDR"
};

	//查詢用檢核
	function initValidation(){		
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			
		valid2 = new Validation("form", {useTitles:true, focusOnError:false, immediate:false});			
	}
	function buttonAuth() {
		var authButtons = { 
			B0003 : 'BTN_INSERT',
			B0004 : 'BTN_UPDATE',		
			B0005 : 'BTN_DELETE'
		 }; 
		 <dz:grantButtons FUNC_ID='DSC81601'/>
	}
	//共用的Ajax
	function ajaxPost( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_1601/" + actionName, {  
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
	
	function defineValid(ID){
	
		if(ID.length == 8){
			valid1.define( "checkUniSN" , { id: "ID" , errMsg:"統一編號格式有誤" } );		
		} else {
			valid1.define( "checkROCID" , { id: "ID" , errMsg:"身份證字號格式錯誤" } );			
		}	
			
		valid1.define( "required" , { id: "NAME" , errMsg:"保證人姓名不可空白" } );	
		valid1.define( "required" , { id: "ID" , errMsg:"保證人ID不可空白" } );	
		valid1.define( "required" , { id: "GUAR_KIND" , errMsg:"身分不可空白" } );	
		valid1.define( "required" , { id: "RELATION_P" , errMsg:"自然人關係不可空白" } );	
		valid1.define( "validate-ROCDate" , { id: "BIRTHDAY" , errMsg:"保證人生日格式有誤，請輸入民國年月(例：671102)" });
		valid1.define( "validate-number" , { id: "DAY_TEL_NUM" , errMsg:"連絡電話(日)號碼非數字格式，請重新輸入" });
		valid1.define( "validate-number" , { id: "DAY_TEL_EXT" , errMsg:"連絡電話(日)分機非數字格式，請重新輸入" });
		valid1.define( "validate-number" , { id: "NIGHT_TEL_NUM" , errMsg:"連絡電話(夜)號碼非數字格式，請重新輸入" });
		valid1.define( "validate-number" , { id: "NIGHT_TEL_EXT" , errMsg:"連絡電話(夜)分機非數字格式，請重新輸入" });		
		valid1.define( "validate-number" , { id: "MOBILE" , errMsg:"行動電話非數字格式，請重新輸入" });	
		if($F('LOAN_POS') == '01'){
			valid1.define( "validate-selection" , { id: "LOAN_POS01" , errMsg:"請選擇前行庫用途!" });
		}
	}
	
	var action ={
		doQuery : function(){	
			if('${SOURCE}'=='I'){ //新增
				$('APPLY_ID').value = '${APPLY_ID}';
				$('BORROW_NAME').value = '${BORROW_NAME}' ;
				$('BORROW_ID').value = '${BORROW_ID}' ;
				$('LOAN_ID').value = '${LOAN_ID}' ;
				$('COPR_CODE').value = '${COPR_CODE}' ;
				$('IS_EXTRACT').value = '${IS_EXTRACT}';
						
				$('sLOAN_ID').update('${LOAN_ID}' || '');		
						
				$('BTN_INSERT').enable();
				$('BTN_UPDATE').disable();
				$('BTN_DELETE').disable();
				$('BTN_BACK').enable();
						
				if($('COPR_CODE').value!='1'){
					$('RELATION_E').disable();
				}											
			} else {
				ajaxPost( 'query', {	LOAN_ID : '${LOAN_ID}', ID : '${ID}'}
					,function(resp){
							//初始頁面顯示欄位
							var rtnMap = resp.rtnMap ? resp.rtnMap : {};
								$('APPLY_ID').value = '${APPLY_ID}';
								$('BORROW_NAME').value = rtnMap.BORROW_NAME || '' ;
								$('BORROW_ID').value = rtnMap.BORROW_ID || '';
								$('NAME').value = rtnMap.NAME || '' ;
								$('ID').value = rtnMap.ID || '' ;
								$('COPR_CODE').value = rtnMap.COPR_CODE || '' ;
								$('GUAR_KIND').value = rtnMap.GUAR_KIND || '' ;
								$('RELATION_E').value = rtnMap.RELATION_E || '' ;
								$('RELATION_P').value = rtnMap.RELATION_P || '' ;
								$('BIRTHDAY').value = rtnMap.BIRTHDAY || '' ;
								$('LOAN_POS').value = rtnMap.LOAN_POS || '' ;
								$('LOAN_POS01').value = rtnMap.LOAN_POS01 || '' ;<%--[20241106]+前行庫用途--%>
								$('LOAN_POS').simulate('change');<%--[20241106]連動前行庫用途--%>
								$('CON_ZIP').value = rtnMap.CON_ZIP || '' ;	
								NEW_GAGE_ADDR.setINPUT_ZIPCODE(rtnMap.CON_ZIP);	
								NEW_GAGE_ADDR.setINPUT_ADDR(rtnMap.CON_ADDR);	
								$('DAY_TEL_AREA').value = rtnMap.DAY_TEL_AREA || '' ;
								$('DAY_TEL_NUM').value = rtnMap.DAY_TEL_NUM || '' ;
								$('DAY_TEL_EXT').value = rtnMap.DAY_TEL_EXT || '' ;
								$('NIGHT_TEL_AREA').value = rtnMap.NIGHT_TEL_AREA || '' ;
								$('NIGHT_TEL_NUM').value = rtnMap.NIGHT_TEL_NUM || '' ;
								$('NIGHT_TEL_EXT').value = rtnMap.NIGHT_TEL_EXT || '' ;
								$('MOBILE').value = rtnMap.MOBILE || '' ;
								$('LOAN_ID').value = rtnMap.LOAN_ID || '' ;
								$('sLOAN_ID').update(rtnMap.LOAN_ID || '');	
								
								$('BTN_INSERT').disable();
								$('BTN_UPDATE').enable();
								$('BTN_DELETE').enable();
								$('BTN_BACK').enable();
								
								if($('COPR_CODE').value!='1'){
									$('RELATION_E').disable();
								}
								$('IS_EXTRACT').value = rtnMap.IS_EXTRACT || '';
								$('ID').readOnly=true;
							});
			}
		}		
		,doBack : function (){
			if(window.isPopupWin && window.popupWinBack){
			   // 呼叫callback Function(若有) 並關閉
			   window.popupWinBack(); 
			}else if(window.parent && window.parent.popupWin){
				//呼叫callback Function(若有) 並關閉
			   window.parent.popupWin.back();
			}else{
				CSRUtil.linkBack();
			}			
		}
	}

		
	var buttons={
		doInsert : function (){	
			valid1.clear();	
			valid1.reset();
			defineValid($F('ID'))
			if(!valid1.validate()){
			return;
			}	
						
			//若COPR_CODE=1，企業關係才為必填欄位
			if($F('COPR_CODE')=='1'){
				if(!$F('RELATION_E')){
					alert("請輸入企業關係");
					return;
				}
			}
				
			//判斷關係的值
			if($F('COPR_CODE')=='0'){
				if($F('RELATION_P') == 'X'){
					alert("非法人件，保證人的自然人關係不得為本人!!");
					return;
				} else if ($F('RELATION_P') == '0' || $F('RELATION_P') == ''){
					alert("此件為非法人件，請選取自然人關係!!");
					return;
				}
				var RELATION_E = 'X';
				RELATION= RELATION_E + $F('RELATION_P') ;  
			} else {			
				if($F('RELATION_E') == 'X' || $F('RELATION_E') == '0' || $F('RELATION_E') == ''){
					alert("此件為法人件，請選取保證人企業關係!!");
					return;
				}
				var RELATION_P = 'X';
				RELATION= $F('RELATION_E') + RELATION_P ;  
			}	
					
			//檢核地址輸入及內容
			if(!NEW_GAGE_ADDR.getINPUT_ADDR()){
				alert("請輸入通訊地址");
				return;
			}
			//判斷手續費用
			if($('EXPENSE_AMT').value < 0){
				alert('注意!手續費用低於0!');
				return;
			}
			
			valid2.clear();	// 清define
			valid2.reset();
			
			//NEW_GAGE_ADDR.checkData(valid2, notCheck);
			if(!valid2.validate()){
				return;
			}
			
			if ($F('EXPENSE_AMT') > 0 && $F('IS_EXTRACT') == 'Y') {
				//alert('本次期款已抽件，轉帳扣款中，若輸入費用，可能造成扣款成功卻無法入帳，僅能掛電腦暫收，實際上等於未繳，易造成糾紛及後續帳務處理之困難。除要立即開單繳費者外，請於轉帳扣款作業完畢後(確定轉帳成功或不成功後)，再行輸入費用')
				if(!confirm('本次期款已抽件，轉帳扣款中，若輸入費用，可能造成扣款成功卻無法入帳，僅能掛電腦暫收，實際上等於未繳，易造成糾紛及後續帳務處理之困難。除要立即開單繳費者外，請於轉帳扣款作業完畢後(確定轉帳成功或不成功後)，再行輸入費用\n是否確定輸入費用？')) {
					return ;
				}
			}
			
			//畫面各欄位的值存到DATA_MAP
			var DATA_MAP={
				LOAN_ID : $F('LOAN_ID'),
				APPLY_ID : $F('APPLY_ID'),
				BORROW_NAME : $F('BORROW_NAME'),
				BORROW_ID : $F('BORROW_ID'),
				ID : $F('ID'),
				NAME : $F('NAME'),
				GUAR_KIND : $F('GUAR_KIND'),
				RELATION : RELATION,
				BIRTHDAY : $F('BIRTHDAY'),
				LOAN_POS : $F('LOAN_POS'),
				LOAN_POS01 : $F('LOAN_POS01'),<%--[20241106]+前行庫用途--%>
				CON_ZIP : NEW_GAGE_ADDR.getINPUT_ZIPCODE(),
				CON_ADDR : NEW_GAGE_ADDR.getINPUT_ADDR(),
				DAY_TEL_AREA : $F('DAY_TEL_AREA'),
				DAY_TEL_NUM : $F('DAY_TEL_NUM'),
				DAY_TEL_EXT : $F('DAY_TEL_EXT'),
				NIGHT_TEL_AREA : $F('NIGHT_TEL_AREA'),
				NIGHT_TEL_NUM : $F('NIGHT_TEL_NUM'),
				NIGHT_TEL_EXT : $F('NIGHT_TEL_EXT'),
				MOBILE : $F('MOBILE'),
				EXPENSE_AMT : $F('EXPENSE_AMT')
			};
			
			ajaxPost( 'insert', {DATA_MAP : Object.toJSON(DATA_MAP)}
					,function(resp){
						rtnMap=resp.rtnMap;
						$$('.areaA').each(function(ele){
						var id = ele.id;
						ele.value=rtnMap[id] || '';						
					});
						$('sLOAN_ID').update(rtnMap.LOAN_ID || '');	
						$('EXPENSE_AMT').value = 0;
						$('BTN_INSERT').disable();
						$('BTN_UPDATE').enable();
						$('BTN_DELETE').enable();
						$('BTN_BACK').enable();
					}
				);
	}
	,doUpdate :function(){
			valid1.clear();
			valid1.reset();
			defineValid($F('ID'))
			if(!valid1.validate()){
			return;
			}	
	
			//判斷關係的值
			if($F('COPR_CODE')=='0'){
				if($F('RELATION_P') == 'X'){
					alert("非法人件，保證人的自然人關係不得為本人!!");
					return;
				} else if ($F('RELATION_P') == '0' || $F('RELATION_P') == ''){
					alert("此件為非法人件，請選取自然人關係!!");
					return;
				}
				var RELATION_E = 'X';
				RELATION= RELATION_E + $F('RELATION_P') ;  
			} else {			
				if($F('RELATION_E') == 'X' || $F('RELATION_E') == '0' || $F('RELATION_E') == ''){
					alert("此件為法人件，請選取保證人企業關係!!");
					return;
				}
				var RELATION_P = 'X';
				RELATION= $F('RELATION_E') + RELATION_P ;  
			}	
			
			//檢核地址輸入及內容
			if(!NEW_GAGE_ADDR.getINPUT_ADDR()){
				alert("請輸入通訊地址");
				return;
			}
			
			//判斷手續費用
			if($('EXPENSE_AMT').value < 0){
				alert('注意!手續費用低於0!');
				return;
			}
			
			valid2.clear();	// 清define
			valid2.reset();
			
			NEW_GAGE_ADDR.checkData(valid2, notCheck);			
			if(!valid2.validate()){
				return;
			}
			
			if ($F('EXPENSE_AMT') > 0 && $F('IS_EXTRACT') == 'Y') {
				//alert('本次期款已抽件，轉帳扣款中，若輸入費用，可能造成扣款成功卻無法入帳，僅能掛電腦暫收，實際上等於未繳，易造成糾紛及後續帳務處理之困難。除要立即開單繳費者外，請於轉帳扣款作業完畢後(確定轉帳成功或不成功後)，再行輸入費用')
				if(!confirm('本次期款已抽件，轉帳扣款中，若輸入費用，可能造成扣款成功卻無法入帳，僅能掛電腦暫收，實際上等於未繳，易造成糾紛及後續帳務處理之困難。除要立即開單繳費者外，請於轉帳扣款作業完畢後(確定轉帳成功或不成功後)，再行輸入費用\n是否確定輸入費用？')) {
					return ;
				}
			}
			
					
			//畫面各欄位的值存到DATA_MAP
			var DATA_MAP={
				LOAN_ID : $F('LOAN_ID'),
				APPLY_ID : $F('APPLY_ID'),
				BORROW_NAME : $F('BORROW_NAME'),
				BORROW_ID : $F('BORROW_ID'),
				ID : $F('ID'),
				NAME : $F('NAME'),
				GUAR_KIND : $F('GUAR_KIND'),
				RELATION : RELATION,
				BIRTHDAY : $F('BIRTHDAY'),
				LOAN_POS : $F('LOAN_POS'),
				LOAN_POS01 : $F('LOAN_POS01'),<%--[20241106]+前行庫用途--%>
				CON_ZIP : NEW_GAGE_ADDR.getINPUT_ZIPCODE(),
				CON_ADDR : NEW_GAGE_ADDR.getINPUT_ADDR(),
				DAY_TEL_AREA : $F('DAY_TEL_AREA'),
				DAY_TEL_NUM : $F('DAY_TEL_NUM'),
				DAY_TEL_EXT : $F('DAY_TEL_EXT'),
				NIGHT_TEL_AREA : $F('NIGHT_TEL_AREA'),
				NIGHT_TEL_NUM : $F('NIGHT_TEL_NUM'),
				NIGHT_TEL_EXT : $F('NIGHT_TEL_EXT'),
				MOBILE : $F('MOBILE'),
				EXPENSE_AMT : $F('EXPENSE_AMT')
			};
					
			ajaxPost( 'update', {DATA_MAP : Object.toJSON(DATA_MAP)}
					,function(resp){
						rtnMap=resp.rtnMap;
						$$('.areaA').each(function(ele){
							var id = ele.id;
							ele.value = rtnMap[id] || '';						
						});
						$('sLOAN_ID').update(rtnMap.LOAN_ID || '');	
						$('EXPENSE_AMT').value = 0;
						$('BTN_INSERT').disable();
						$('BTN_UPDATE').enable();
						$('BTN_DELETE').enable();
						$('BTN_BACK').enable();
					}
			);	
	}
	,doDelete : function(){
		if(!confirm('確定要刪除保人資料?')){
				return;
		}
		
		//畫面各欄位的值存到DATA_MAP
		var DATA_MAP={
			LOAN_ID : $F('LOAN_ID'),
			APPLY_ID : $F('APPLY_ID'),
			BORROW_NAME : $F('BORROW_NAME'),
			BORROW_ID : $F('BORROW_ID'),
			ID : $F('ID'),
			NAME : $F('NAME'),
			GUAR_KIND : $F('GUAR_KIND'),
			RELATION : RELATION,
			BIRTHDAY : $F('BIRTHDAY'),
			LOAN_POS : $F('LOAN_POS'),
			CON_ZIP : NEW_GAGE_ADDR.getINPUT_ZIPCODE(),
			CON_ADDR : NEW_GAGE_ADDR.getINPUT_ADDR(),
			DAY_TEL_AREA : $F('DAY_TEL_AREA'),
			DAY_TEL_NUM : $F('DAY_TEL_NUM'),
			DAY_TEL_EXT : $F('DAY_TEL_EXT'),
			NIGHT_TEL_AREA : $F('NIGHT_TEL_AREA'),
			NIGHT_TEL_NUM : $F('NIGHT_TEL_NUM'),
			NIGHT_TEL_EXT : $F('NIGHT_TEL_EXT'),
			MOBILE : $F('MOBILE'),
			EXPENSE_AMT : $F('EXPENSE_AMT')
		};
	
		ajaxPost( 'delete', {DATA_MAP : Object.toJSON(DATA_MAP)}
					,function(resp){
						msgWin.setCallback(function(){
								msgWin.clearCallback();
								action.doBack();
						});						
					}				
		);		
	}
}

	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC81601', '收息資料更新', '保人資料變更明細');
                buttonAuth();
				$('BTN_INSERT').observe('click',buttons.doInsert);
				$('BTN_UPDATE').observe('click',buttons.doUpdate);
				$('BTN_DELETE').observe('click',buttons.doDelete);
				$('BTN_BACK').observe('click',action.doBack);
				<%--[20241106]借款用途連動前行庫用途--%>
				$('LOAN_POS').observe('change', function(){
					if(this.value == '01'){
						$('LOAN_POS01').enable();
					}else{
						$('LOAN_POS01').setValue('');
						$('LOAN_POS01').disable();
					}
				});
							
				//產生下拉選單群
				NEW_GAGE_ADDR = new DSZ01000('CON_ADDR', "2");
				var inputs = $('CON_ADDR').select('input');	
				//inputs[0].id = 'NEW_CON_ZIP';
				//inputs[1].id = 'NEW_CON_ADDR';
				inputs[1].className = "checkInputLength hasFullType";
				inputs[1].maxLength = "200"
				inputs[1].size = "60";
				inputs[1].setAttribute( "fieldName" , "通訊地址" );
				action.doQuery();
				autoCreateDate();
				autoFormatToDate();
				autoFormatToNumber();
				
				initValidation();
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
<form id="form" name="form"	style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table width="100%" border="0" cellpadding="0" cellspacing="1"	class="tbBox2">
	<input type="hidden" class="areaA" id="COPR_CODE" name="COPR_CODE" value="" />
	<input type="hidden" class="areaA" id="LOAN_ID" name="LOAN_ID" value="" />
	<input id="IS_EXTRACT" type="hidden"/> 
	<tr>
		<td class="tbYellow" align='center' >貸款帳號</TD>
		<td class="tbYellow2" >
			<span id = 'sLOAN_ID'></span>
		</td>
		<td class="tbYellow2" align='center' colspan='2'><input
			id="BTN_INSERT" type="button" value="新增" class="button"> <input
			id="BTN_UPDATE" type="button" value="變更" class="button"> <input
			id="BTN_DELETE" type="button" value="刪除" class="button"> <input
			id="BTN_BACK" type="button" value="上一頁" class="button">			
		</td>
	</tr>
	<tr>
		<td class="tbYellow0" width="5%" align='center' colspan='4'>保人資料變更明細</td>
	</tr>
	<tr>
		<td class="tbYellow" width="5%" align='center'>受理編號</td>
		<td class="tbYellow2" width="10%" colspan='4'><input
			id="APPLY_ID" type="text" class="areaA" size='15' maxlength="11"
			readOnly /></td>
	</tr>
	<tr>
		<td class="tbYellow" width="5%" align='center'>借款人姓名</td>
		<td class="tbYellow2" width="10%">
			<%-- [20230321] 難字調整 --%>
			<input id="BORROW_NAME" type="text" class="areaA" size='15' maxlength="60" alt="ch" readOnly />
		</td>
		<td class="tbYellow" width="5%" align='center'>借款人ID</td>
		<td class="tbYellow2" width="10%"><input id="BORROW_ID"
			type="text" class="areaA" size='15' maxlength="10" readOnly /></td>
	</tr>
	<tr>
		<td class="tbYellow" width="5%" align='center'>保證人姓名</td>
		<td class="tbYellow2" width="10%">
			<%-- [20230321] 難字調整 --%>
			<input id="NAME" type="text" class="areaA" size='15' maxlength="60" alt="ch" />
		</td>
		<td class="tbYellow" width="5%" align='center'>保證人ID</td>
		<td class="tbYellow2" width="10%"><input id="ID" type="text"
			class="areaA" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()"/></td>
	</tr>
	<tr>
		<td class="tbYellow" width="5%" align='center'>身分</td>
		<td class="tbYellow2" width="8%" colspan='4'><select
			id="GUAR_KIND" class="areaA">
			<option value="">請選擇</option>
			<c:forEach var="map" items="${GUAR_KIND_List}">
				<option value="${map.key}">${map.value}</option>
			</c:forEach>
		</select></td>
	</tr>
	<tr>
		<td class="tbYellow" width="5%" align='center' rowSpan='2'>關係</td>
		<td class="tbYellow2" width="10%">企業關係 <select id="RELATION_E"
			class="areaA">
			<option value="">請選擇</option>
			<c:forEach var="map" items="${RELATION_E_List}">
				<option value="${map.key}">${map.value}</option>
			</c:forEach>
		</select></td>
		<td class="tbYellow" width="5%" align='center' rowSpan='2'>保證人生日</td>
		<td class="tbYellow2" width="10%" rowSpan='2'><input
			id="BIRTHDAY" datatype ='ROCDate' type="text" class="areaA textBox2" size='15' maxlength="10" /></td>
	</tr>
	<tr>
		<td class="tbYellow2" width="10%">自然人關係 <select id="RELATION_P"
			class="areaA">
			<option value="">請選擇</option>
			<c:forEach var="map" items="${RELATION_P_List}">
				<option value="${map.key}">${map.value}</option>
			</c:forEach>
		</select></td>
	</tr>
	<tr>
		<td class="tbYellow" width="5%" align='center'>區域代碼</td>
		<td class="tbYellow2" width="10%"><input id="CON_ZIP"
			type="text" class="areaA" size='15' maxlength="5" readOnly /></td>
		<td class="tbYellow" width="5%" align='center'>借款用途</td>
		<td class="tbYellow2" width="10%"><select id="LOAN_POS"
			class="areaA validate-selection" fieldName = "借款用途">
			<option value="">請選擇</option>
			<c:forEach var="map" items="${LOAN_POS_List}">
				<option value="${map.key}">${map.value}</option>
			</c:forEach></select></td>
	</tr>
	<tr>
		<td class="tbYellow" width="5%" align='center' rowspan='2'>通訊地址</td>
		<td class="tbYellow2" width="4%" id="CON_ADDR" rowspan='2'></td>
		<%--[20241106]增加前行庫用途 --%>
		<td class="tbYellow" align='center' rowspan='2'>前行庫用途</td>
		<td class="tbYellow2" rowspan='2'>
			<select id="LOAN_POS01" name='LOAN_POS01' class="areaA">
				<option value="">請選擇</option>
				<c:forEach var="map" items="${LOAN_POS01_List}">
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
	</tr>
	<tr>
		<td class="tbYellow" width="5%" align='center'>電話</td>
		<td class="tbYellow2">(日) <select name="DAY_TEL_AREA"
			id="DAY_TEL_AREA" class="areaA">
			<option value="">區碼</option>
			<c:forEach var="map" items="${TEL_AREA_List}">
				<option value="${map.key}">${map.value}</option>
			</c:forEach>
		</select>— <input type="text" id="DAY_TEL_NUM" name="DAY_TEL_NUM" size="10"
			fieldName="聯絡人電話號碼" class="areaA" maxlength="10" />#
		<input type="text" id="DAY_TEL_EXT" name="DAY_TEL_EXT" size="6"
			fieldName="聯絡人電話分機" class="areaA" maxlength="6" />
		</td>
		<td class="tbYellow2" colspan='2'>(夜) <select name="NIGHT_TEL_AREA"
			id="NIGHT_TEL_AREA" class="areaA">
			<option value="">區碼</option>
			<c:forEach var="map" items="${TEL_AREA_List}">
				<option value="${map.key}">${map.value}</option>
			</c:forEach>
		</select>— <input type="text" id="NIGHT_TEL_NUM" name="NIGHT_TEL_NUM" size="10"
			fieldName="聯絡人電話號碼" class="areaA" maxlength="10" />#
		<input type="text" id="NIGHT_TEL_EXT" name="NIGHT_TEL_EXT" size="6"
			fieldName="聯絡人電話分機" class="areaA" maxlength="6" />
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="5%" align='center'>行動電話</td>
		<td class="tbYellow2" width="10%" ><input id="MOBILE"
			type="text" class="areaA" size='15' maxlength="15" /></td>
		<td class="tbYellow" width="5%" align='center'>手續費用</td>
		<td class="tbYellow2" width="10%">
		<input id="EXPENSE_AMT" type="text" align='right' class="areaA" size="7" maxlength="6"  datatype="number" value="0" /></td>	
	</tr>
	
</table>
</form>
</body>
</html>