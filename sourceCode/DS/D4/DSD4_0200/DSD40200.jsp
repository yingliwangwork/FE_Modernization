<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename='TextResource' />

<!--
程式：DSD40200.jsp
功能：清償確認作業
作者：林秉宏
完成：2013/07/25

[2023-04-11] 清償原因輸入卡控優化，問題單編號  20221103-0081
1. 畫面檢核字數是否超過上限
2. 提示可以到附件一的其他備註說明詳細的清償原因

[20240326]
難字調整
高強禾
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<%-- [20240326] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type='text/javascript'><!--

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSD40200().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSD40200(){	

		var grid;
		var valid1;
		var valid2;
		
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0003 : 'BTN_insert',		<%--新增--%>	
				B0004 : 'BTN_update'		<%--修改--%>		
			};
			<dz:grantButtons FUNC_ID='DSD40200'/>
		};
		
		// 檢核
		var initValidation = function(){	

			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkLength1', '貸款帳號長度需為10碼!', function( v ) { return chkLength($F('LOAN_ID_Q'));}],
				[ 'chkLength2', '借款人ID長度需為10碼!', function( v ) { return chkLength($F('BORROW_ID_Q'));}]
			] );
			valid1.define( "chkLength1" , [{ id : "LOAN_ID_Q" } ] );
			valid1.define( "chkLength2" , [{ id : "BORROW_ID_Q" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid2.define( "validate-selection" , [{ id : "PAYOFF_LIMIT", errMsg : '請選擇作業種類!' } ] );	
			valid2.define( "validate-number" , { id: "RATE" , errMsg:"利率非數字格式，請重新輸入" });
			//valid2.define( "validate-number" , { id: "RATE_CORP" , errMsg:"本公司利率非數字格式，請重新輸入" });
			//valid2.define( "validate-number" , { id: "BUY_TEL" , errMsg:"買方電話號碼非數字格式，請重新輸入" });
			//valid2.define( "validate-number" , { id: "LAW_TEL" , errMsg:"代書電話號碼非數字格式，請重新輸入" });
		};
		
		// 檢核帳號長度
		var chkLength = function (ID) 
		{		
			var chk = true;
			if(ID && ID.length != 10) {
				chk = false; 
			}
			return chk; 	
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSD4_0200/' + actionName,
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
	
		var actions = {
		
			// 查詢
			doQuery: function(){
				
				// 檢核
				if(!$F('LOAN_ID_Q') && !$F('BORROW_ID_Q') && !$F('BORROW_NAME_Q')){
					alert("貸款帳號.借款人ID.借款人姓名請至少輸入一欄再執行查詢作業");
					return;
				}
				
				valid2.reset();
				
				// 檢核
				if(!valid1.validate()){ 
					return; 
				}
				
				var reqMap = {
					LOAN_ID : $F('LOAN_ID_Q'),
					BORROW_ID : $F('BORROW_ID_Q'),
					BORROW_NAME : $F('BORROW_NAME_Q')
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'info' : Object.toJSON(reqMap) },
					function(resp){
						//使用貸款帳號查詢 且 查詢結果剛好僅有一筆資料，預設點選當筆資料
						if($('LOAN_ID_Q').getValue() && resp.rtnList.length == 1){
							grid.load(resp.rtnList || []);
							var radio = $$('#grid input[type=radio]').each(
								function(text){
									text.simulate('click');
								}
							);
						}else{
							grid.load(resp.rtnList || []);
						}
					},function(resp){
						grid.load([]);
						setValues(resp, true);
					}
				);	
			},
			
			// 查詢清償主檔資料
			doQueryD090: function(){
				
				valid1.reset();
				valid2.reset();
				
				var chkList = grid.getCheckedRecord();
				$('CONTROL_CODE').value = '';
				// 頁面傳入參數
				ajaxPost( 'queryD090' , { 'checkList' : Object.toJSON(chkList) },
					function(resp){				
						setValues(resp, false);
						
						
						var CONTROL_CODE =  resp.CONTROL_CODE;
						var isInternal =  resp.isInternal;
						if (CONTROL_CODE){
						   $('CONTROL_CODE').value = CONTROL_CODE;
							var MSG;
							if(CONTROL_CODE == "ERR"){
							    MSG ="本件有「特殊管控」注意事項。"
							    if(isInternal == 'N'){
							    	MSG = MSG +"\r\n詳細內容請洽"+resp.CONTROL_DEPT_GROUP_NM+"。";
							    }
							    MSG += "\r\n若要查詢特殊件控管變更紀錄請按『確定』鍵?";
							    
							}else if(CONTROL_CODE){
								MSG ="本件有「特殊提醒」注意事項。"
								if(isInternal == 'N'){
									MSG = MSG +"\r\n詳細內容請洽"+resp.CONTROL_DEPT_GROUP_NM+"。";
								}	
								MSG += "\r\n若要查詢特殊件控管變更紀錄請按『確定』鍵?";
								
							}
							if( confirm(MSG)){
								   actions.linkTo_DSC8_3100(resp.BORROW_ID,"3-9");
					        }
						}
						
						
						
						
					},
					function(resp){				
						$$('#grid input[type=radio]:checked').each(
							function(text){
								text.checked = false;
							}
						);
						setValues(resp, true);
					}
				);	
			},
			
			// 新增
			doInsert: function(){
			    
				var rtnList = grid.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行新增作業");
					return;
				}
				
				var chkList = grid.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行新增作業");
				  	return;
				}
				setREASON(); //檢查REASON各清償原因下的資料是否有填寫或勾選;
				// 畫面程序檢核-清償原因為必選欄位
				if($$('#form1 [id^=REASON]:checked').length == 0) {
					alert("請至少選擇一種清償原因!");
					return;
				}
				
				valid1.reset();
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				
				if($F('CONTROL_CODE') == "ERR"){
		    		alert("本件為特殊控管件,無法進行新增!!");
			    	return;
			    }
				
				//[2023-04-11]  清償原因輸入卡控優化
				//1. 畫面檢核字數是否超過上限
				//2. 提示可以到附件一的其他備註說明詳細的清償原因
				if($F('OTHER') != '' && $F('OTHER').length > 30 ) {
					alert("清償原因中「其他原因」欄位字數超過三十字，請簡化清償原因，完整的清償原因或說明請至附件一的「其他備註說明」區塊填寫，謝謝!!");
					return;
				}
				
				var rtnLOAN_ID = chkList[0]['LOAN_ID'];
				var rtnREFER_ID = chkList[0]['REFER_ID'];
			

				// 頁面傳入參數
				ajaxPost( 'insert' , { 'info' : Object.toJSON(reqMap(rtnLOAN_ID, rtnREFER_ID)), 'checkList' : Object.toJSON(chkList),'PAYOFF_LIMIT' : $F('PAYOFF_LIMIT') },
					function(resp){			
						setValues(resp, false);
					}
				);
				
			},
			
			// 修改
			doUpdate: function(){
				
				var rtnList = grid.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行修改作業");
					return;
				}
				
				var chkList = grid.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行修改作業");
				  	return;
				}
				setREASON(); //檢查REASON各清償原因下的資料是否有填寫或勾選;
				
				
				// 畫面程序檢核-清償原因為必選欄位
				if($$('#tableD090 [id^=REASON]:checked').length == 0) {
					alert("請至少選擇一種清償原因!");
					return;
				}
				if($F('CONTROL_CODE') == "ERR"){
		    		alert("本件為特殊控管件,無法進行修改!!");
			    	return;
			    }
				valid1.reset();
				valid2.reset();
				
				//[2023-04-11]  清償原因輸入卡控優化
				//1. 畫面檢核字數是否超過上限
				//2. 提示可以到附件一的其他備註說明詳細的清償原因
				if($F('OTHER') != '' && $F('OTHER').length > 30 ) {
					alert("清償原因中「其他原因」欄位字數超過三十字，請簡化清償原因，完整的清償原因或說明請至附件一的「其他備註說明」區塊填寫，謝謝!!");
					return;
				}
				
				var rtnLOAN_ID = chkList[0]['LOAN_ID'];
				var rtnREFER_ID = chkList[0]['REFER_ID'];
				
				// 頁面傳入參數
				ajaxPost( 'update' , { 'info' : Object.toJSON(reqMap(rtnLOAN_ID, rtnREFER_ID)), 'checkList' : Object.toJSON(chkList) },
					function(resp){			
						setValues(resp, false);
					}
				);
			},
			linkTo_DSC8_3100:function(BORROW_ID,CONTROL_SOURCE){
				popupWin.popup({
					src: '<%=dispatcher%>/DSC8_3100/prompt',scrolling : 'yes',
					parameters: { 
						LOAN_ID : BORROW_ID,
						CONTROL_TYPE : 'U',
						CONTROL_SOURCE : CONTROL_SOURCE
					}, 
					width: 600, 
					height: 350,
					cb : function(obj){}
				});
			},
			doLink: function(){
				var selectedList = grid.getCheckedRecord();	
				if(selectedList.length !=1){
					alert('請選擇一筆貸款帳號，再做附件一處理!');
					return;
				}
				var data = {
					action: '${dispatcher}/DSD4_0100/prompt',
					LINK_FROM: 'DSD40200',
					LOAN_ID: selectedList[0]['LOAN_ID'],
					ACTION_TYPE: 'Q'
				};
				CSRUtil.linkTo(data, 'form1');
			},
			doCheckCHOICE7: function(){
				var rec = grid.getCheckedRecord();
				if(!rec.PAYOFF_LIMIT || rec.PAYOFF_LIMIT != '5' || rec.PAYOFF_LIMIT != '6' || rec.PAYOFF_LIMIT != '7'){
					if($('PAYOFF_LIMIT').getValue() == '6'){
						$('CHOICE7').checked = true;
					}else{
						$('CHOICE7').checked = false;
					}
					
				}
			}
		};
		
		var setREASON = function() {
		
		    //$('REASON1').checked = false;
				$w('TRANS_BANK1 TRANS_AGENT1').each(
					function(id) {	
					    if($F(id) != '') {
					      $('REASON1').checked = true;
					    }
					}
				);
			    $w('RATE RATE_CORP').each(
					function(id) {	
					    if($F(id) == '0' || $F(id) == '') {
					       //不需要做
					    }else{
					      $('REASON1').checked = true;
					    }
					}
				);
			   // $('REASON2').checked = false;
				$w('TRANS_BANK2 TRANS_AGENT2').each(
					function(id) {	
					
					    if($F(id) != '') {
					      $('REASON2').checked = true;
					    }
					}
				);
				$w('TRANS_AMT LOAN_AMT').each(
					function(id) {	
					
					    if($F(id) == '0' ||  $F(id) == '') {
					      //不需要做
					    }else{
					      $('REASON2').checked = true;
					    }
					}
				);
			   // $('REASON4').checked = false;
				/*$w('BUY_NAME BUY_TEL LAW_NAME LAW_TEL').each(
					function(id) {	
					
					    if($F(id) != '') {
					      $('REASON4').checked = true;
					    }
					}
				);*/
			    //$('REASON5').checked = false;
				/*if($('ITEM1').checked == true || $('ITEM2').checked == true || $('ITEM3').checked == true || $F('SUPPLY') != ''){
					$('REASON5').checked = true;
				}*/
				//$('REASON6').checked = false;
				if($('CHOICE6').value != '' || $F('OTHER') != ''){
					$('REASON6').checked = true;
				}
		
		}
		
		
		// 清償確認資料輸入區塊
		var setValues = function(resp, isClear) {
		
			var rtnMap = resp.rtnMap;
			$w('LOAN_ID BORROW_NAME BORROW_ID LOAN_STATUS_NM LOAN_KIND_NM').each(
				function(id) {	
					if (isClear){
						$(id).innerHTML = '';
					}else{
						if (id == 'BORROW_ID'){
							$(id).innerHTML = CSRUtil.maskHandler.getMaskID(rtnMap[id]) || '';
						}else{
							$(id).innerHTML = rtnMap[id] || '';
						}
					}						
				}
			);
			
			var D090Map = resp.D090Map;
			$w('INPUT_ID_NAME D090_DATE D090_TIME').each(
				function(id) {
					if (isClear){
						$(id).innerHTML = '';
					}else{	
						$(id).innerHTML = D090Map[id] || '';
					}					
				}
			);
			
			$w('TRANS_BANK1 TRANS_AGENT1 RATE RATE_CORP TRANS_BANK2 TRANS_AGENT2 TRANS_AMT LOAN_AMT OTHER').each(
				function(id) {
					if (isClear){
						$(id).value = '';
					}else{
						var D090Value = D090Map[id];
						if (D090Value === 0){
							$(id).value = D090Value;
						}else{
							if (id == 'LOAN_AMT' || id == 'TRANS_AMT'){
								$(id).value = CSRUtil.$fmt(D090Value, '#,##0.####', '');
							}else{
								$(id).value = D090Value || '';
							}
						}
						
					}					
				}
			);
			
			$w('PAYOFF_LIMIT CHOICE6').each(
				function(id) {
					if (isClear){
						$(id).selectedIndex = 0;
					}else{
						$(id).value = D090Map[id] || '';
					}					
				}
			);
			
			$w('CHOICE7 REASON1 REASON2 REASON3 REASON4 REASON5 REASON6 REASON7').each(
				function(id) {
					if (isClear){
						$(id).checked = false; 
					}else{
						if (D090Map[id] == '1') {
							$(id).checked = true;										
						} else {
							$(id).checked = false; 
						}
					}				
				}
			);
		};
		
		// 產生清償確認資料回傳資料
		var reqMap = function(rtnLOAN_ID, rtnREFER_ID){
			
			var reqMap = {};
			
			$$('#tableD090 input[type!=checkbox]', '#tableD090 select').each(
				function(text){
					reqMap[text.id] = $F(text.id);
				}
			);
			
			$$('#tableD090 input[type=checkbox]:checked').each(
				function(text){
					reqMap[text.id] = '1';
				}
			);
			
			$$('#tableD090 input[type=checkbox]:not(:checked)').each(
				function(text){
					reqMap[text.id] = '0';
				}
			);
			
			reqMap['LOAN_ID'] = rtnLOAN_ID;
			reqMap['REFER_ID'] = rtnREFER_ID;
			
			return reqMap;		
		};
		
		// 金額格式化
		var gridFmtRender = function(value) { 
			return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : ''; 
		};
		
		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSD40200' ,
					'清償作業' , 
					'清償確認作業'
				);			
				
				// 產生 grid 物件	
				grid = new TableUI(
					{	
						table: $('grid'), allSortable:true, overDiv:false,
						autoCheckBox:{isSelectAll:true, type:'radio', 
						    action:function(node, boxStatus, records ){
								if(!node.checked){ return;}
								actions.doQueryD090();
							}
						},
						<%-- [20240326] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:'契約狀況', key:'LOAN_STATUS_NM'},
							<%-- [20240326] 難字調整：姓名 --%>
							{header:'姓名', key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
							{header:'借款人ID', key:'BORROW_ID',
								render : function (record , value){
									return CSRUtil.maskHandler.getMaskID(value);
								}
							},
							{header:'貸款金額', key:'LOAN_AMT', attrs:{align:'right'},
								render : function (record , value){
									return gridFmtRender(value);
								}
							},
							{header:'本金餘額', key:'REMAIN_AMT', attrs:{align:'right'},
								render : function (record , value){						
									return gridFmtRender(value);
								}
							},
							{header:'收息單位', key:'GETINT_DEPT'},
							{header:'受理編號', key:'APPLY_ID'},
							{header:'原貸帳號', key:'REFER_ID'}
						]						
					}
				);								
					
				initValidation();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
				
				// 新增
				$('BTN_insert').observe('click', actions.doInsert);
				
				// 修改
				$('BTN_update').observe('click', actions.doUpdate);
				
				// 附件一處理
				$('BTN_link').observe('click', actions.doLink);
				
				$('PAYOFF_LIMIT').observe('change', actions.doCheckCHOICE7);

				buttonAuth();
				autoFormatToNumber();
	
				PageUI.resize();
				displayMessage();
		
			} // end initApp()		
		}; // end return
	}

--></script>
</head>
<body>

<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
<input id="CONTROL_CODE" name="CONTROL_CODE" type="hidden" value="">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width='10%'>
			貸款帳號
		</td>
		<td class="tbYellow2" width="90%" colspan="4">
			<input id="LOAN_ID_Q" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
		</td>
		<!-- <td class="tbYellow" width='10%'>
			借款人ID
		</td>
		<td class="tbYellow2" width="20%"> -->
			<input id="BORROW_ID_Q" type="hidden" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
		<!-- </td>
		<td class="tbYellow" width='10%'>
			借款人姓名
		</td>
		<td class="tbYellow2" width="20%"> -->
			<input id="BORROW_NAME_Q" type="hidden" class="textBox2" size="15"/>
		<!-- </td>
		<td class="tbYellow2" width='10%' align='center'>
			
		</td> -->
	</tr>
	<tr>
		<td colspan="7" align="center">
			<input id="BTN_query" type="button" value="查詢" class="button"> 
			 <input id="BTN_insert" type="button" class="button" value='新增' /> 
			 <input id="BTN_update" type="button" class="button" value='修改' /> 
			 <input id="BTN_link" type="button" class="button" value='附件一處理' />
		</td>
	</tr>
</table>

<table id="grid" class="grid"></table>

<table id="tableD090" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width='10%'>
			貸款帳號
		</td>
		<td class="tbYellow2" width="23%">
			<span id="LOAN_ID"></span>
		</td>
		<td class="tbYellow" width='10%'>
			借款人姓名
		</td>
		<td class="tbYellow2" width="23%">
			<%-- [20240326] 難字調整：借款人姓名 --%>
			<span id="BORROW_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow" width='10%'>
			借款人ID
		</td>
		<td class="tbYellow2" width="23%">
			<span id="BORROW_ID"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width='10%'>
			契約狀況
		</td>
		<td class="tbYellow2" width="23%">
			<span id="LOAN_STATUS_NM"></span>
		</td>
		<td class="tbYellow" width='10%'>
			貸款種類
		</td>
		<td class="tbYellow2" width="23%" colspan="3">
			<span id="LOAN_KIND_NM"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width='10%'>
			作業種類
		</td>
		<td class="tbYellow2" width="23%">
			<select id="PAYOFF_LIMIT">			
				<option value="">請選擇</option>	
				<c:forEach items="${PAYOFF_LIMIT_LIST}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
		<td class="tbYellow">
			同原貸件處理
		</td>
		<td class="tbYellow2" colspan="3">
			<input type="checkbox" id="CHOICE7"><font color="red">※該欄位打勾則表示欲一併處理同一擔保品的所有貸款件</font>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" rowspan="7">
			清償原因
		</td>
		<td class="tbYellow2" colspan="5">
			<input type="checkbox" id="REASON1">1.利率因素:轉貸
			<input id="TRANS_BANK1" type="text" class="textBox2" size="12"/>行庫
			<input id="TRANS_AGENT1" type="hidden" class="textBox2" size="12"/><!-- 分行， -->利率
			<input id="RATE" type="text" class="textBox2" size="6" datatype="number"/>％<!-- (本公司 -->
			<input id="RATE_CORP" type="hidden" class="textBox2" size="6" datatype="number"/><!-- ％) -->
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="checkbox" id="REASON2" name="REASON2">2.貸限因素:轉貸
			<input id="TRANS_BANK2" type="text" class="textBox2" size="12"/>行庫
			<input id="TRANS_AGENT2" type="hidden" class="textBox2" size="12"/><!-- 分行， -->金額
			<input id="TRANS_AMT" type="text" class="textBox2" size="6" datatype="number"/>萬<!-- (本公司 -->
			<input id="LOAN_AMT" type="hidden" class="textBox2" size="6" datatype="number"/><!-- 萬) -->
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="checkbox" id="REASON3" >3.服務或與銀行往來因素-客戶反應事實
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="checkbox" id="REASON4">4.出售<!-- －買方姓名 
			<input id="BUY_NAME" type="text" class="textBox2" size="15"/>電話
			<input id="BUY_TEL" type="text" class="textBox2" size="12"/><br>&nbsp;&emsp;&emsp;&emsp;&emsp;【代書姓名
			<input id="LAW_NAME" type="text" class="textBox2" size="15"/>電話
			<input id="LAW_TEL" type="text" class="textBox2" size="12"/>】 -->
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="checkbox" id="REASON5">5.有閒錢<!-- -【1】 
			<input type="checkbox" id="ITEM1">支票 【2】
			<input type="checkbox" id="ITEM2">現金 【3】
			<input type="checkbox" id="ITEM3">匯款<br>&nbsp;&nbsp;&nbsp;&nbsp;閒錢來源：
			<input id="SUPPLY" type="text" class="textBox2" size="60"/> -->
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="checkbox" id="REASON7">6.申請(定+分)展延未准 
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colspan="5">
			<input type="checkbox" id="REASON6">7.其他-轉【1】 
			<select id="CHOICE6">			
				<option value="">請選擇</option>	
				<c:forEach items="${CHOICE6_LIST}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select><br>&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;【2】其他原因：
			<input id="OTHER" type="text" class="textBox2" size="60"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			輸入人員
		</td>
		<td class="tbYellow2">
			<%-- [20240326] 難字調整：輸入人員 --%>
			<span id="INPUT_ID_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow">
			輸入日期
		</td>
		<td class="tbYellow2" colspan="3">
			<span id="D090_DATE"></span>
			<span id="D090_TIME"></span>
		</td>
	</tr>
</table>

</form>		
</body>
</html>