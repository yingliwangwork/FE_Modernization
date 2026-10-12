<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC20400.jsp
功能：外幣貸款帳務紀錄
作者：吳昀洋
完成：2021-01-29
-->

<html>
<head>
	<%@ include file='/html/CM/header.jsp'%>
	<%@ include file='/html/CM/msgDisplayer.jsp'%>
	<!--匯入外部Javascript 與 css-->
	<title></title>
	<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
	<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
	<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
	<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
	<script type="text/JavaScript" src='${htmlBase}/CM/js/date.js'></script>
	<script type='text/JavaScript' src='${htmlBase}/CM/js/calendar.js'></script>
	<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
	<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
	<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
	<script type="text/javascript" src='${htmlBase}/CM/js/RPTUtil.js'></script>
	<script type='text/javascript' src='${htmlBase}/CM/js/ui/InputUtility.js'></script>
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
	
	<%--產生畫面物件 --%>
	<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
		Event.observe(window, 'load', new DSC20400().initApp);

		function DSC20400() {

			<%-- 檢核 --%>
			var validA ,validB
			<%-- TablE UI物件 --%>
			var grid;
			<%-- AJAX 請求 --%>
			var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC2_0400/');

			<%-- 修改時日期是否有異動 --%>
			var originalDate;
			<%-- 修改時類型是否有異動 --%>
			var originalType;
			<%-- 按鈕功能--%>
			var buttons = {
				doQuery: function () {
					if(!validA.validate()){
						return;
					}
					validB.reset();
					ajaxRequest.post('query', {'queryMap' :Object.toJSON(actions.getQryMap())},
						function (resp) {
							actions.clearSectionB();
							var loanMap = resp.loanMap;
							$('LOAN_ID').update(loanMap['LOAN_ID']);
							$('BORROW_NAME').update(loanMap['BORROW_NAME']);
							grid.load(resp.rtnList || []);
						}
						);
				},
				<%-- 匯出CSV --%>
				doExport: function () {
					<%--檢查C區是否有資料--%>
					if(grid.getAllRecords().length == 0){
						alert('請先查詢出外幣貸款帳務紀錄！');
						return;
					}
					var reqMap = actions.getExportMap();
					reqMap['gridJSON'] = grid.getXlsSettingJSON($('LOAN_ID').innerText);
					ajaxRequest.post('export',{'reqMap': Object.toJSON(reqMap)},
						function(resp){
							var options = {
									downloadFileName : resp.downloadFileName,
									downloadFileFullPath : resp.downloadFileFullPath,
									isOpenNewBrowse : false
							}
							<%--下載檔案--%>
							RPTUtil.download(options); 
						}		
					)
				},
				<%-- 新增 --%>
				doInsert: function () {
					if(!validB.validate()){
						return;
					}
					ajaxRequest.post('insert',{'qryMap' : Object.toJSON(actions.getQryMap()),'reqMap' : Object.toJSON(actions.getModifyMap())},
						function(resp){
							actions.clearSectionB();
							var loanMap = resp.loanMap;
							$('LOAN_ID').update(loanMap['LOAN_ID']);
							$('BORROW_NAME').update(loanMap['BORROW_NAME'])
							grid.load(resp.rtnList||[]);
						}
					)
				},
				<%-- 修改 --%>
				doUpdate: function() {
					if(grid.getCheckedRecord().length == 0){
						alert('請先選取一筆帳務紀錄進行修改！');
						return;
					}
					if($F('DATA_DATE') != originalDate){
						alert('資料日期已異動，請重新選取再進行修改！若要修改日期請刪除後重新新增!');
						return;
					}
					if($F('DATA_TYPE') != originalType){
						alert('資料類型已異動，請重新選取再進行修改！若要修改日期請刪除後重新新增!');
						return;
					}
					if(!validB.validate()){
						return;
					}
					ajaxRequest.post('update',{'qryMap' : Object.toJSON(actions.getQryMap()),'reqMap' : Object.toJSON(actions.getModifyMap())},
							function(resp){
								actions.clearSectionB();
								var loanMap = resp.loanMap;
								$('LOAN_ID').update(loanMap['LOAN_ID']);
								$('BORROW_NAME').update(loanMap['BORROW_NAME'])
								grid.load(resp.rtnList||[]);
							}
					)
				},
				<%-- 刪除 --%>
				doDelete: function(){
					if(grid.getCheckedRecord().length == 0){
						alert('請先選取一筆帳務紀錄再進行刪除！');
						return;
					}
					<%-- 檢查資料日期是否有異動 --%>
					if($F('DATA_DATE') != originalDate){
						alert('資料日期已異動，請重新選取再進行刪除！');
						return;
					}
					if($F('DATA_TYPE') != originalType){
						alert('資料類型已異動，請重新選取再進行刪除！');
						return;
					}
					ajaxRequest.post('delete',{'qryMap' : Object.toJSON(actions.getQryMap()),'reqMap' : Object.toJSON(actions.getModifyMap())},
							function(resp){
								actions.clearSectionB();
								var loanMap = resp.loanMap;
								$('LOAN_ID').update(loanMap['LOAN_ID']);
								$('BORROW_NAME').update(loanMap['BORROW_NAME'])
								grid.load(resp.rtnList||[]);
							}
					)
				}
			};
			
			var actions = {
					<%-- 取得查詢所需資料 --%>
					getQryMap : function(){
						return{
							'LOAN_ID': $F('LOAN_ID_Q'),
							'DATA_DATES': $F('DATA_DATES'),
							'DATA_DATEE' : $F('DATA_DATEE')
						}
					},
					<%-- 取得匯出所需資料 --%>
					getExportMap : function(){
						return{
							'LOAN_ID': $('LOAN_ID').innerText,
							'BORROW_NAME' : $('BORROW_NAME').innerText,
							'DATA_DATES': $F('DATA_DATES'),
							'DATA_DATEE' : $F('DATA_DATEE')
						}
					},
					<%-- 取得新增資料 --%>
					getModifyMap : function(){
						return{
							'LOAN_ID' : $('LOAN_ID').innerText,
							'DATA_DATE' : $F('DATA_DATE'),
							'DATA_TYPE' : $F('DATA_TYPE'),
							'PAY_TERM' : $F('PAY_TERM'),
							'PAY_KIND' : $F('PAY_KIND'),
							'CURR' : $F('CURR'),
							'EX_RATE' : $F('EX_RATE'),
							'RATE' : $F('RATE'),
							'REMAIN_AMT1' : $F('REMAIN_AMT1'),
							'REMAIN_AMT2' : $F('REMAIN_AMT2'),
							'RETAIN_INT1' : $F('RETAIN_INT1'),
							'RETAIN_INT2' : $F('RETAIN_INT2'),
							'INTEREST1' : $F('INTEREST1'),
							'INTEREST2' : $F('INTEREST2'),
							'MEMO' : $F('MEMO')
						}
					},
					<%-- 清除'外幣貸款帳務資訊輸入'區域的資料 --%>
					clearSectionB : function(){
						$('DATA_DATE').setValue('');
						$('DATA_TYPE').setValue('');
						$('PAY_TERM').setValue('');
						$('PAY_KIND').setValue('');
						$('CURR').setValue('');
						$('EX_RATE').setValue('');
						$('RATE').setValue('');
						$('REMAIN_AMT1').setValue('');
						$('REMAIN_AMT2').setValue('');
						$('RETAIN_INT1').setValue('');
						$('RETAIN_INT2').setValue('');
						$('INTEREST1').setValue('');
						$('INTEREST2').setValue('');
						$('MEMO').setValue('');
					},
					<%-- 資料類型異動 --%>
					changeDATA_TYPE :function(){
						
						<%-- 若為繳息才須填寫期數、解款別 --%>
						if ($F('DATA_TYPE')=="1"){
							$('PAY_TERM').enable();
							$('PAY_KIND').enable();
						} else {
							$('PAY_TERM').setValue('');
							$('PAY_KIND').setValue('');
							
							$('PAY_TERM').disable();
							$('PAY_KIND').disable();
						}						
					},
					<%-- 匯率格式化 --%>
					changeEX_RATE :function(){
						var v = $F('EX_RATE');
						var reAMT1 = $F('REMAIN_AMT1');
						var reINT1 = $F('RETAIN_INT1');
						var interest1 = $F('INTEREST1');
						$('EX_RATE').setValue(localeDisplay.formatNumber(v,5,true));
						<%--連動更改本金餘額(台幣)--%>
						if(reAMT1){
							$('REMAIN_AMT2').setValue(localeDisplay.formatNumber((v * reAMT1),0,true));
						}
						<%--連動更改應收利息(台幣)--%>
						if(reINT1){
							$('RETAIN_INT2').setValue(localeDisplay.formatNumber((v * reINT1),0,true));							
						}
						<%--連動更改利息收入(台幣)--%>
						if(interest1){
							$('INTEREST2').setValue(localeDisplay.formatNumber((v * interest1),0,true));							
						}
					},

					<%-- 利息格式化 --%>
					changeRATE :function(){
						var v = $F('RATE');
						$('RATE').setValue(localeDisplay.formatNumber(v,6,true));
					},
					<%-- 本金餘額(原幣)格式化 --%>
					changeRemainAMT1 :function(){
						var v = $F('REMAIN_AMT1');
						var f = $F('EX_RATE');
						$('REMAIN_AMT1').setValue(localeDisplay.formatNumber(v,2,true));
						if(f){
							$('REMAIN_AMT2').setValue(localeDisplay.formatNumber((v*f),0,true));
						}		
					},
					<%-- 本金餘額(台幣)格式化 --%>
					changeRemainAMT2 :function(){
						var v = $F('REMAIN_AMT2');
						$('REMAIN_AMT2').setValue(localeDisplay.formatNumber(v,0,true));
					},
					<%-- 應收利息(原幣)格式化 --%>
					changeRetainINT1 : function(){
						var v = $F('RETAIN_INT1');
						var f = $F('EX_RATE');
						$('RETAIN_INT1').setValue(localeDisplay.formatNumber(v,2,true));
						if(f){
							$('RETAIN_INT2').setValue(localeDisplay.formatNumber((v*f),0,true));
						}
					},
					<%-- 應收利息(台幣)格式化 --%>
					changeRetainINT2 :function(){
						var v = $F('RETAIN_INT2');
						$('RETAIN_INT2').setValue(localeDisplay.formatNumber(v,0,true));
					},
					<%-- 利息收入(原幣)格式化 --%>
					changeInterest1 :function(){
						var v = $F('INTEREST1');
						var f = $F('EX_RATE');
						$('INTEREST1').setValue(localeDisplay.formatNumber(v,2,true));
						if(f){
							$('INTEREST2').setValue(localeDisplay.formatNumber((v*f),0,true));
						}
					},
					<%-- 利息收入(台幣)格式化 --%>
					changeInterest2 :function(){
						var v = $F('INTEREST2');
						$('INTEREST2').setValue(localeDisplay.formatNumber(v,0,true));
					},
					<%-- 自訂檢核共用方法 --%>
					checkValidRule : function(value, intLen, floatLen){
						if(!value.include('.')){
							return (value.length > intLen) ? false : true
						} else{
							arr = value.split('.');
							if(arr[0].length > intLen || arr[1].length> floatLen){
								return false;
							}
						}
						return true;
					}
			}
			
			<%-- 畫面檢核 --%>
			function initValidation(){
				Validation.addAllThese([
					[ 'validateLOAN_ID_10',  '貸款帳號長度不正確 需為10碼',
						function(v){				
							if(v.length!=0 && v.length!=10){
								return false;
							}
							return true;
						}
					],
					[ 'validatePayTerm', '期數有誤',
						function(v){
							if ($F('DATA_TYPE')!="1"){	
								return true;
							}								
							return actions.checkValidRule(v,3,0);
						}						
					],
					[ 'validatePayTermInput', '期數不得為空',
						function(v){
							if ($F('DATA_TYPE')!="1"){	
								return true;
							}	
							if(v){
								return true;
							}
							return false;
						}						
					],
					[ 'validatePayKindInput', '繳款別不得為空',
						function(v){
							if ($F('DATA_TYPE')!="1"){	
								return true;
							}								
							if(v){
								return true;
							}
							return false;
						}						
					],
					[ 'validateExRate', '匯率格式有誤',
						function(v){
							return actions.checkValidRule(v,5,5);
						}						
					],
					[ 'validateRate', '利率格式有誤',
						function(v){
							return actions.checkValidRule(v,2,6);
						}						
					],
					[ 'validateRemainANT1', '本金餘額(原幣)有誤',
						function(v){
							return actions.checkValidRule(v,11,2);	
						}						
					],
					[ 'validateRemainANT2', '本金餘額(台幣)有誤',
						function(v){
							return actions.checkValidRule(v,11,0);							
						}						
					],
					[ 'validateRetainINT1', '應收利息(原幣)有誤',
						function(v){
							return actions.checkValidRule(v,11,2);
						}						
					],
					[ 'validateRetainINT2', '應收利息(台幣)有誤',
						function(v){
							return actions.checkValidRule(v,11,0);
						}						
					],
					[ 'validateInterest1', '利息收入(原幣)有誤',
						function(v){
							return actions.checkValidRule(v,11,2);
						}						
					],
					[ 'validateInterest2', '利息收入(台幣)有誤',
						function(v){
							return actions.checkValidRule(v,11,0);
						}						
					],
					[ 'validateMemo', '備註不得為空',
						function(v){
							if ($F('DATA_TYPE')!="5"){	
								return true;
							}								
							if(v){
								return true;
							}
							return false;
						}						
					],
				]);

				<%-- 查詢區塊檢核--%>
				validA = new Validation('form1');
				validA.define('required',{id :'LOAN_ID_Q', errMsg: '請輸入貸款帳號查詢！'});
				validA.define('required',{id :'DATA_DATES', errMsg: '請輸入正確的資料日期(起)！'});
				validA.define('required',{id :'DATA_DATEE', errMsg: '請輸入正確的資料日期(迄)！'});
				validA.define('validateLOAN_ID_10',{id :'LOAN_ID_Q', errMsg:'請輸入正確的貸款帳號查詢！'});
				validA.define('validate-ROCDate' , { id : 'DATA_DATES' , errMsg : '請輸入正確的資料日期(起)！'});
				validA.define('validate-ROCDate' , { id : 'DATA_DATEE' , errMsg : '請輸入正確的資料日期(迄)！'});
				<%-- 輸入區塊檢核 --%>
				validB = new Validation('form1');
				<%-- 資料日期檢核 --%>
				validB.define('required',{id:'DATA_DATE',errMsg:'請輸入資料日期！'});
				<%-- 資料類型檢核 --%>
				validB.define('required',{id:'DATA_TYPE',errMsg:'請輸入資料類型！'});
				<%-- 幣別檢核 --%>
				validB.define('required',{id:'CURR',errMsg:'請輸入幣別！'});
				<%-- 匯率檢核 --%>
				validB.define('required',{id:'EX_RATE',errMsg:'請輸入匯率！'});
				validB.define('validateExRate',{id:'EX_RATE',errMsg:'匯率格式有誤(整數最多5位，小數最多5位)'});
				<%-- 利率檢核 --%>
				validB.define('required',{id:'RATE',errMsg:'請輸入利率！'});
				validB.define('validateRate',{id:'RATE',errMsg:'利率格式有誤(整數最多2位，小數最多6位)'});
				<%-- 本金餘額(原幣)檢核 --%>
				validB.define('required',{id:'REMAIN_AMT1',errMsg:'請輸入本金餘額(原幣)！'});
				validB.define('validateRemainANT1',{id:'REMAIN_AMT1',errMsg:'本金餘額(原幣)格式有誤(整數最多11位，小數最多2位)'});
				<%-- 本金餘額(台幣)檢核 --%>
				validB.define('required',{id:'REMAIN_AMT2',errMsg:'請輸入本金餘額(台幣)！'});
				validB.define('validateRemainANT2',{id:'REMAIN_AMT2',errMsg:'本金餘額(台幣)格式有誤(整數最多11位)'});
				<%-- 應收利息(原幣)檢核 --%>
				validB.define('required',{id:'RETAIN_INT1',errMsg:'請輸入應收利息(原幣)！'});
				validB.define('validateRetainINT1',{id:'RETAIN_INT1',errMsg:'應收利息(原幣)格式有誤(整數最多11位，小數最多2位)'});
				<%-- 應收利息(台幣)檢核 --%>
				validB.define('required',{id:'RETAIN_INT2',errMsg:'請輸入應收利息(台幣)！'});
				validB.define('validateRetainINT2',{id:'RETAIN_INT2',errMsg:'應收利息(台幣)格式有誤(整數最多11位)'});
				<%-- 利息收入(原幣)檢核 --%>
				validB.define('required',{id:'INTEREST1',errMsg:'請輸入利息收入(原幣)！'});
				validB.define('validateRetainINT1',{id:'INTEREST1',errMsg:'利息收入(原幣)格式有誤(整數最多11位，小數最多2位)'});
				<%-- 利息收入(台幣)檢核 --%>
				validB.define('required',{id:'INTEREST2',errMsg:'請輸入利息收入(台幣)！'});
				validB.define('validateRetainINT2',{id:'INTEREST2',errMsg:'利息收入(台幣)格式有誤(整數最多11位)'});
				
				<%-- 期數及繳款別檢核 --%>
				validB.define('validatePayTermInput',{id:'PAY_TERM',errMsg:'請輸入期數！'});
				validB.define('validatePayKindInput',{id:'PAY_KIND',errMsg:'請輸入繳款別！'});
				validB.define('validatePayTerm',{id:'PAY_TERM',errMsg:'期數格式有誤(最多3位數字)'});
				
				<%-- 備註檢核 --%>
				validB.define('validateMemo',{id:'MEMO',errMsg:'請輸入備註！'});
				
			}

			return {
				initApp: function () {
					<%-- 直接提供畫面文字 --%>
					PageUI.createPageWithAllBodySubElement('DSC20400','收息帳務','外幣貸款帳務紀錄');

					<%-- 小日曆 --%>
					<cathay:LocaleDisplay sysCode="DS" dateFields="DATA_DATE DATA_DATES DATA_DATEE" numberFields="EX_RATE RATE REMAIN_AMT1 REMAIN_AMT2 RETAIN_INT1 RETAIN_INT2 INTEREST1 INTEREST2 PAY_TERM" var='localeDisplay'/>
					<%-- Validation --%>
					initValidation();
					<%-- 設定呈現用的資料表 --%>
					grid = new TableUI({
						table: $("grid"),
						pageSize: 15,
						autoCheckBox:{
							type:'radio',
							isSelectAll : false,
							action:function(node , boxStatus, records){
									var record = records[0];
									$('DATA_DATE').setValue(record['DATA_DATE']);
									originalDate = record['DATA_DATE'];
									$('DATA_TYPE').setValue(record['DATA_TYPE']);
									originalType = record['DATA_TYPE'];
									$('CURR').setValue(record['CURR']);
									$('EX_RATE').setValue(record['EX_RATE']);
									$('RATE').setValue(record['RATE']);
									$('REMAIN_AMT1').setValue(record['REMAIN_AMT1']);
									$('REMAIN_AMT2').setValue(record['REMAIN_AMT2']);
									$('RETAIN_INT1').setValue(record['RETAIN_INT1']);
									$('RETAIN_INT2').setValue(record['RETAIN_INT2']);
									$('INTEREST1').setValue(record['INTEREST1']);
									$('INTEREST2').setValue(record['INTEREST2']);
									$('PAY_TERM').setValue(record['PAY_TERM']);
									$('PAY_KIND').setValue(record['PAY_KIND']);
									$('MEMO').setValue(record['MEMO']);
							}
						},
						column: [
								{header: '資料日期', key: 'DATA_DATE',sortRule:'date'}, 
								{header: '資料類型', key: 'DATA_TYPE',
									render: function(record,value){
										return record['DATA_TYPE_NM'];
									}
								},
								{header: '期數', key: 'PAY_TERM' },
								{header: '繳款別', key: 'PAY_KIND',
									render: function(record,value){
										return record['PAY_KIND_NM'];
									}
								},
								{header: '幣別', key: 'CURR' },
								{header: '匯率', key: 'EX_RATE',
									render: function(obj, val){
										return CSRUtil.$fmt(val,'#,###.#####');
									}
								},
								{header: '本金餘額(原幣)', key: 'REMAIN_AMT1',
										render: function(obj, val){
											return CSRUtil.$fmt(val,'#,###.##');
										}
								},
								{header: '本金餘額(台幣)', key: 'REMAIN_AMT2',
									render: function(obj, val){
										return CSRUtil.$fmt(val,'#,###');
									}
								},
								{header: '利率(%)', key: 'RATE',
									render: function(obj, val){
										return CSRUtil.$fmt(val,'##.#####');
									}
								},
								{header: '應收利息(原幣)', key: 'RETAIN_INT1',
									render: function(obj, val){
										return CSRUtil.$fmt(val,'#,###.##');
									}
								},
								{header: '應收利息(台幣)', key: 'RETAIN_INT2',
									render: function(obj, val){
										return CSRUtil.$fmt(val,'#,###');
									}
								},
								{header: '利息收入(原幣)', key: 'INTEREST1',
									render: function(obj, val){
										return CSRUtil.$fmt(val,'#,###.##');
									}
								},
								{header: '利息收入(台幣)', key: 'INTEREST2',
									render: function(obj, val){
										return CSRUtil.$fmt(val,'#,###');
									}
								},
								{header: '備註', key: 'MEMO' }
							]
						});

			
					<%--註冊buttons事件 --%>
					$('btn_query').observe('click', buttons.doQuery);
					$('btn_export').observe('click', buttons.doExport);
					$('btn_insert').observe('click', buttons.doInsert);
					$('btn_update').observe('click', buttons.doUpdate);
					$('btn_delete').observe('click', buttons.doDelete);
					
					<%--輸入欄位註冊事件--%>
					$('DATA_TYPE').observe('change',actions.changeDATA_TYPE);
					$('EX_RATE').observe('blur',actions.changeEX_RATE);
					$('RATE').observe('blur',actions.changeRATE);
					$('REMAIN_AMT1').observe('blur',actions.changeRemainAMT1);
					$('REMAIN_AMT2').observe('blur',actions.changeRemainAMT2);
					$('RETAIN_INT1').observe('blur',actions.changeRetainINT1);
					$('RETAIN_INT2').observe('blur',actions.changeRetainINT2);
					$('INTEREST1').observe('blur',actions.changeInterest1);
					$('INTEREST2').observe('blur',actions.changeInterest2);			
					
					$('PAY_TERM').disable();
					$('PAY_KIND').disable();
					
					InputUtility.lengthLimit.add("MEMO", 200, true, "中文或全型算2個字，已輸入{enter}字，尚可輸入{left}字。");

					displayMessage();
				}
			};
		}	
	</script>
</head>

<body>
	<form name='form1' id='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
		<table id="table_A" width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr class="tbYellow">
				<td width="10%">
					貸款帳號
				</td>
				<td width="15%" class="tbYellow2">
					<input type="text" class="textbox2" id="LOAN_ID_Q" name="LOAN_ID_Q" onblur="this.value = this.value.toUpperCase()" maxlength="10" value="${LOAN_ID_Q}">
				</td>
				<td width="10%">
					資料日期
				</td>
				<td width="15%" class="tbYellow2">
					<input type="text" class="textbox2" id="DATA_DATES" name="DATA_DATES" value="${DATA_DATES}"/>
					<span>~</span>
					<input type="text" class="textbox2" id="DATA_DATEE" name="DATA_DATEE" value="${DATA_DATEE}"/>
				</td>
				<td width="50%" class="tbYellow2" colspan="4" align="center">
					<button type="button" class="button" id="btn_query">查詢</button>
					<button type="button" class="button" id="btn_export">匯出</button>
				</td>
			</tr>
		</table>
		<table id="table_B" width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr class="tbYellow0">
				<td colspan="8">
					<b>外幣貸款帳務資訊輸入</b>
				</td>
			</tr>
			<tr class="tbYellow">
				<td width="10%">貸款帳號</td>
				<td width="15%" class="tbYellow2">
					<span id="LOAN_ID"></span>
				</td>
				<td width="10%">貸款人姓名</td>
				<td width="15%" class="tbYellow2">
					<span id="BORROW_NAME"></span>
				</td>
				<td width="10%">資料日期</td>
				<td width="15%" class="tbYellow2">
					<input type="text" class="textbox2" id="DATA_DATE" name="DATA_DATE"/>
				</td>
				<td width="10%">資料類型</td>
				<td width="15%" class="tbYellow2">
					<select name="DATA_TYPE" id="DATA_TYPE">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${dataTypeMap}">
						<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>
			<tr class="tbYellow">
				<td>期數</td>
				<td class="tbYellow2">
					<input type="text" class="textbox2" name="PAY_TERM" id="PAY_TERM"/>
				</td>
				<td>繳款別</td>
				<td class="tbYellow2">
					<select name="PAY_KIND" id="PAY_KIND">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${payKindMap}">
						<option value="${map.key}" currency="${map.value}">${map.value}</option>
						</c:forEach>
					</select>
				</td>				
				<td>幣別/匯率</td>
				<td class="tbYellow2">
					<select name="CURR" id="CURR">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${currMap}">
						<option value="${map.key}" currency="${map.value}">${map.value}</option>
						</c:forEach>
					</select>
					<input type="text" class="textbox2" name="EX_RATE" id="EX_RATE"/>
				</td>
				<td>利率(%)</td>
				<td class="tbYellow2">
					<input type="text" class="textbox2" name="RATE" id="RATE"/>
				</td>
			</tr>
			<tr class="tbYellow">
				<td>本金餘額(原幣)</td>
				<td class="tbYellow2">
					<input type="text" class="textbox2" name="REMAIN_AMT1" id="REMAIN_AMT1">
				</td>
				<td>本金餘額(台幣)</td>
				<td class="tbYellow2">
					<input type="text" class="textbox2" name="REMAIN_AMT2" id="REMAIN_AMT2">
				</td>
				<td rowspan="3">備註</td>
				<td class="tbYellow2" colspan="3" rowspan="3">
					<textarea id="MEMO" name="MEMO" cols="70" rows="3"></textarea>
				</td>
			</tr>
			<tr class="tbYellow">
				<td>應收利息(原幣)</td>
				<td class="tbYellow2">
					<input type="text" class="textbox2" name="RETAIN_INT1" id="RETAIN_INT1">
				</td>
				<td>應收利息(台幣)</td>
				<td class="tbYellow2">
					<input type="text" class="textbox2" name="RETAIN_INT2" id="RETAIN_INT2">
				</td>
			</tr>			
			<tr class="tbYellow">
				<td>利息收入(原幣)</td>
				<td class="tbYellow2">
					<input type="text" class="textbox2" name="INTEREST1" id="INTEREST1">
				</td>
				<td>利息收入(台幣)</td>
				<td class="tbYellow2">
					<input type="text" class="textbox2" name="INTEREST2" id="INTEREST2"/>
				</td>
			</tr>
			<tr>
				<td colspan="8" class="tbYellow2" align="center">
					<button type="button" class="button" id="btn_insert">新增</button>
					<button type="button" class="button" id="btn_update">修改</button>
					<button type="button" class="button" id="btn_delete">刪除</button>
				</td>
			</tr>
		</table>
		<div id="grid" class="grid">
		</div>
	</form>
</body>

</html>