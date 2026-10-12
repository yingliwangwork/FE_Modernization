<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5' %>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<%-- 
程式：DSC83300.jsp 
作者：呂適安 
功能：本金彈性還設定變更 
完成：2022/01/06


 [20230322]難字修改 
 [20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更
 --%>

<title>本金彈性還設定變更</title>

<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css' />
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<style type="text/css"><%-- [20230322]難字修改 --%>
	@font-face{
		font-family: 'EUDC';
		src: url('/DSWeb/hanlinks/eudc.ttf') format("truetype");
		font-weight:normal;
		font-style:normal
	}
</style>
<script type='text/JavaScript'>
Event.observe(window, 'load', new DSC83300().initApp);

function DSC83300(){
	<%-- TablE UI物件 --%>
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC8_3300/');
	var grid;
	var valid1;
	var valid2;

	<%-- 按鈕權限 --%>
	var buttonAuth = function(){
		var authButtons = {
			B0004 : 'deleteBtn',		<%--刪除--%>	
			B0005 : 'changeBtn',		<%--變更--%>	
			B0070 : 'confirmBtn'		<%--覆核--%>	
		};
		<dz:grantButtons FUNC_ID='DSC83300'/>
	};
	<%--畫面檢核--%>
    function initValidation(){

		Validation.addAllThese([
				[ 'validateLOAN_ID_Q_10',  '貸款帳號長度不正確 需為10碼',
					function(v){
						return (v.length != 10) ? false : true ;
					}
				],
				[ 'validateFLEX_AMT2_limit',  '[每月還本金金額]未在上下限中!',
					function(v){
						var FLEX_AMT2 = parseInt(v);
						var FLEX_MIN = parseInt($F('FLEX_MIN_VAL')) <%-- 每月還本金下限金額 --%>
						var FLEX_MAX = parseInt($F('FLEX_MAX_VAL'))<%-- 每月還本金上限金額 --%>
						if(FLEX_AMT2 < FLEX_MIN || FLEX_AMT2 >  FLEX_MAX){
							return false;
						}else{
							return true;
						}	
					}
				],
				[ 'validateFLEX_AMT2_1000',  '[每月還本金金額]需以仟元為單位!',
					function(v){		
						var FLEX_AMT2 = parseInt(v);		
						if(FLEX_AMT2 % 1000 != 0){
							return false;
						}else{
							return true;
						}
					}
				],
				[ 'validateInteger',  '請輸入大於零之有效正整數!',
					function(v){		
						if(v!=''){
							if( isNaN(v) || eval(v) < 0 ){
								return false;
							}
							return /^\d+$/.test(v);
						}
						return true;
					}
				],
				<%--[20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更--%>
				[ 'requiredPAY_STATUS',  '請選擇[繳息狀況]!',
					function(v){
						return $$('input[name=PAY_STATUS]:checked').length > 0;
					}
				],
				<%--[20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更--%>
				[ 'validatePAY_NOTE',  '請輸入[繳息狀況說明]!',
					function(v){
						var PAY_STATUS = $$('input[name=PAY_STATUS]:checked'); 
						if (PAY_STATUS.length == 0) {
							return true;
						};
						if (PAY_STATUS[0].value == '2' && !$F('PAY_NOTE')){
							return false;
						} else {
							return true;
						}
					}
				],
				<%--[20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更--%>
				[ 'requiredJCIC_STATUS',  '請選擇[聯徵情況]!',
					function(v){
						return $$('input[name=JCIC_STATUS]:checked').length > 0;
					}
				],
				<%--[20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更--%>
				[ 'validateJCIC_NOTE',  '請輸入[聯徵狀況說明]!',
					function(v){
						var JCIC_STATUS = $$('input[name=JCIC_STATUS]:checked');
						if (JCIC_STATUS.length == 0) {
							return true;
						}
						if (JCIC_STATUS[0].value == '2' && !$F('JCIC_NOTE')){
							return false;
						} else {
							return true;
						}
					}
				]
			]);
		valid1 = new Validation('table_A', { focusOnError:true, immediate:false , mode : 'validator'})	
		valid1.define( 'required' , { id: 'LOAN_ID_Q' , errMsg:'[貸款帳號]不可空白!!' } );
		valid1.define( 'validateLOAN_ID_Q_10' , { id: 'LOAN_ID_Q'});
		valid2 = new Validation('table_C', { focusOnError:true, immediate:false , mode : 'validator'})	
		valid2.define( 'required' , { id: 'FLEX_AMT2' , errMsg:'[每月還本金金額]不可空白!!' } );
		valid2.define( 'validateFLEX_AMT2_limit' , { id:'FLEX_AMT2'});
		valid2.define( 'validateFLEX_AMT2_1000' , { id:'FLEX_AMT2'});
		valid2.define( 'required' , { id: 'EXPENSE_AMT' , errMsg:'[手續費]不可空白!!' } );
		valid2.define( 'requiredPAY_STATUS' , { id: 'tdPAY_STATUS' , errMsg:'請選擇[繳息狀況]!' } );
		valid2.define( 'validatePAY_NOTE' , { id: 'PAY_NOTE' , errMsg:'請輸入[繳息狀況說明]!' } );
		valid2.define( 'requiredJCIC_STATUS' , { id: 'tdJCIC_STATUS' , errMsg:'請選擇[聯徵情況]!' } );
		valid2.define( 'validateJCIC_NOTE' , { id: 'JCIC_NOTE' , errMsg:'請輸入[聯徵狀況說明]!' } );
		valid2.define( "validateInteger" , { id:"FLEX_AMT2", errMsg:'[每月還本金金額]請輸入大於零之有效正整數!'} );
		valid2.define( "validateInteger" , { id:"EXPENSE_AMT", errMsg:'[手續費]請輸入大於零之有效正整數!'} );
		valid2.define( "validateInteger" , { id:"FLEX_PERIOD_B2", errMsg:'[本金彈性還期間]請輸入大於零之有效正整數!'} );
		valid2.define( "validateInteger" , { id:"FLEX_PERIOD_E2", errMsg:'[本金彈性還期間]請輸入大於零之有效正整數!'} );
    }

	var actions = {		
	
		doQuery : function(){
			valid1.reset();			
			if(!valid1.validate()){					
				return;			
			}
			var LOAN_ID_Q = $F('LOAN_ID_Q');
			ajaxRequest.post('query', {
				'LOAN_ID_Q' : LOAN_ID_Q
			},function (resp) {
				actions.display(resp, "Query");
				if(resp.MSG){
					alert(resp.MSG);
				}
				<%--[20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更--%>
				var checkAlertMsg = resp.checkAlertMsg;
				if (checkAlertMsg) {
					alert(checkAlertMsg);
				}
			},function (resp) {
				grid.load([])
			})			
		},
		doChange : function(){
			valid2.reset();			
			if(!valid2.validate()){					
				return;			
			}
			var LOAN_ID_Q = $F('LOAN_ID_Q');
			var PAY_STATUS = $$('input[name=PAY_STATUS]:checked')[0].value;
			var JCIC_STATUS = $$('input[name=JCIC_STATUS]:checked')[0].value;
			var reqMap = {
				LOAN_ID : $F('LOAN_ID_Q'),
				CHG_KIND : '35',
				FLEX_AMT2 : $F('FLEX_AMT2'),
				EXPENSE_AMT : $F('EXPENSE_AMT'),
				<%--[20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更--%>
				FLEX_PERIOD_B2: $F('FLEX_PERIOD_B2'),
				FLEX_PERIOD_E2: $F('FLEX_PERIOD_E2'),
				PAY_STATUS: PAY_STATUS,
				PAY_NOTE: PAY_STATUS == '2' ? $F('PAY_NOTE') : '',
				JCIC_STATUS: JCIC_STATUS,
				JCIC_NOTE: JCIC_STATUS == '2' ? $F('JCIC_NOTE') : '',
				MESSAGE_TYPE: $F('MESSAGE_TYPE')
			};
			ajaxRequest.post('change', {
				'reqMap' : Object.toJSON(reqMap),
				'LOAN_ID_Q' : LOAN_ID_Q
			},function (resp) {
				actions.display(resp, "Change");
				if (resp.EXTRACT_MSG) {
					alert(resp.EXTRACT_MSG);
				}
			},function (resp) {
				grid.load([])
			})			
		},
		doDelete : function(){

			if( grid.getCheckedRecord().length==0 ){
				alert( '請選取欲刪除的資料!' );
				return;
			}
			var LOAN_ID_Q = $F('LOAN_ID_Q');
			var reqMap = {
				LOAN_ID : $F('LOAN_ID_Q'),
				CHG_KIND : '35',
				SEQ_NO : $F('SEQ_NO'),
				APPLY_DATE : $F('APPLY_DATE')
			};
			ajaxRequest.post('delete', {
				'reqMap' : Object.toJSON(reqMap),
				'LOAN_ID_Q' : LOAN_ID_Q
			},function (resp) {
				actions.display(resp, "Delete");
			},function (resp) {
				grid.load([])
			})			
		},
		doConfirm : function(){
			if( grid.getCheckedRecord().length==0 ){
				alert( '請選取欲覆核的資料!' );
				return;
			}
			var LOAN_ID_Q = $F('LOAN_ID_Q');
			var reqMap = {
				LOAN_ID : $F('LOAN_ID_Q'),
				CHG_KIND : '35',
				SEQ_NO : $F('SEQ_NO'),
				EXPENSE_AMT : $F('EXPENSE_AMT'),
				APPLY_DATE : $F('APPLY_DATE')
			};
			ajaxRequest.post('confirm', {
				'reqMap' : Object.toJSON(reqMap),
				'LOAN_ID_Q' : LOAN_ID_Q
			},function (resp) {
				actions.display(resp, "Confirm");
				if (resp.EXTRACT_MSG) {
					alert(resp.EXTRACT_MSG);
				}
			},function (resp) {
				grid.load([])
			})			
		},

		display : function (resp, ACTION) {
		<%-- 查詢結果顯示區塊 --%>
			grid.load([]);
			$('LOAN_ID').update(resp.dataMap.LOAN_ID);<%-- 貸款帳號 --%>
			$('BORROW_NAME').update(resp.dataMap.BORROW_NAME);<%-- 借款人姓名 --%>
			$('REMAIN_AMT').update(localeDisplay.formatNumber(resp.dataMap.REMAIN_AMT),0,false);<%-- 本金餘額 --%>
			$('LOAN_PERIOD').update(resp.dataMap.LOAN_PERIOD);<%-- 貸款期數 --%>
			$('FIX_PERIOD').update(resp.dataMap.FIX_PERIOD);<%-- 定期期數 --%>
			$('SLASH').update('/');
			$('SPR_PERIOD').update(resp.dataMap.SPR_PERIOD);<%-- 分期期數 --%>
			$('PAID_TIMES').update(resp.dataMap.PAID_TIMES);<%-- 已繳期數 --%>
			$('SLASH2').update('/');
			$('VALID_TIMES').update(resp.dataMap.VALID_TIMES);<%-- 有效期數 --%>
			$('NEXT_PAYDT').update(resp.dataMap.NEXT_PAYDT);<%-- 下次應繳日 --%>
			$('FLEX_PERIOD_NM').update(resp.dataMap.FLEX_PERIOD_NM);<%-- 本金彈性還期間 --%>
			$('FLEX_AMT').update(localeDisplay.formatNumber(resp.dataMap.FLEX_AMT),0,false);<%-- 每月約定還本金金額 --%>
			$('FLEX_MIN').update(localeDisplay.formatNumber(resp.dataMap.FLEX_MIN),0,false);<%-- 每月還本金下限金額 --%>
			$('FLEX_MAX').update(localeDisplay.formatNumber(resp.dataMap.FLEX_MAX),0,false);<%-- 每月還本金上限金額 --%>
			$('FLEX_MIN_VAL').setValue(resp.dataMap.FLEX_MIN);
			$('FLEX_MAX_VAL').setValue(resp.dataMap.FLEX_MAX);
		<%-- 改變按鈕屬性 --%>
			$('changeBtn').enable();
			$('deleteBtn').enable();
			$('confirmBtn').enable();
			<%--[20240326] 修改件 陳勁谷 清空--%>
			$('FLEX_AMT2').setValue("");<%-- 每月還本金金額 --%>
			$('EXPENSE_AMT').setValue("");<%-- 手續費 --%>
			$('FLEX_PERIOD_B2').setValue('');
			$('FLEX_PERIOD_E2').setValue('');
			$('PAY_NOTE').setValue('');
			$('JCIC_NOTE').setValue('');
			$$('input[name=PAY_STATUS]').each(function(ele) {
				ele.checked = false;
			});
			$$('input[name=JCIC_STATUS]').each(function(ele) {
				ele.checked = false;
			});
			$('MESSAGE_TYPE').selectedIndex = 0;
			if (resp.rtnList){
				<%--$('REMAIN_AMT').update(resp.rtnList[0].REMAIN_AMT);<%-- 本金餘額 --%>
				<%--$('FLEX_PERIOD_NM').update(resp.rtnList[0].FLEX_PERIOD_NM);--%><%-- 本金彈性還期間 --%>
				<%--$('FLEX_MIN').update(localeDisplay.formatNumber(resp.rtnList[0].FLEX_MIN),0,false);<%-- 每月還本金下限金額 --%>
				<%--$('FLEX_MAX').update(localeDisplay.formatNumber(resp.rtnList[0].FLEX_MAX),0,false);<%-- 每月還本金上限金額 --%>
				<%--$('FLEX_MIN_VAL').setValue(resp.rtnList[0].FLEX_MIN);--%>
				<%--$('FLEX_MAX_VAL').setValue(resp.rtnList[0].FLEX_MAX);--%>
		<%-- TableUI --%>
				grid.load(resp.rtnList || []);
				<%--[20240326] 修改件 陳勁谷 預設勾選第一筆 原程式塞值由grid autoCheckBox action處理--%>
				//$('autoCheckBox_table_E_1').click();
			}
			actions.doDisabled(false);
		},
		doDisabled : function (IS_DISABLED) {
			if(IS_DISABLED){
				$('FLEX_PERIOD_B2').disabled = true;
				$('FLEX_PERIOD_E2').disabled = true;
				$('FLEX_AMT2').disabled = true;
				$('EXPENSE_AMT').disabled = true;
				$$('input[name=PAY_STATUS]').each(function(ele) {
					ele.disabled = true;
				});
				$('PAY_NOTE').disabled = true;
				$$('input[name=JCIC_STATUS]').each(function(ele) {
					ele.disabled = true;
				});
				$('JCIC_NOTE').disabled = true;
				$('MESSAGE_TYPE').disabled = true;
			}else{
				$('FLEX_PERIOD_B2').disabled = false;
				$('FLEX_PERIOD_E2').disabled = false;
				$('FLEX_AMT2').disabled = false;
				$('EXPENSE_AMT').disabled = false;
				$$('input[name=PAY_STATUS]').each(function(ele) {
					ele.disabled = false;
				});
				$('PAY_NOTE').disabled = false;
				$$('input[name=JCIC_STATUS]').each(function(ele) {
					ele.disabled = false;
				});
				$('JCIC_NOTE').disabled = false;
				$('MESSAGE_TYPE').disabled = false;
			}
		}
	}



	return{
		
		initApp:function(){
			
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' numberFields ='FLEX_AMT FLEX_AMT2 FLEX_MIN FLEX_MAX EXPENSE_AMT FLEX_PERIOD_B2 FLEX_PERIOD_E2'/>
			
			PageUI.createPageWithAllBodySubElement(
					'DSC83300',
					'收息資料變更',
					'本金彈性還設定變更'
				)

			<%-- 新增 table --%>
			grid = new TableUI({
				table:$('table_E'),
				allSortable: false,
				autoCheckBox:{
							type:'radio',
							isSelectAll : false,
							action:function(node , boxStatus, records){
								if(false == boxStatus){
									$('FLEX_AMT2').setValue('');
									$('FLEX_PERIOD_B2').setValue('');
									$('FLEX_PERIOD_E2').setValue('');
									$('EXPENSE_AMT').setValue('');
									$('PAY_STATUS').setValue('');
									$('PAY_NOTE').setValue('');
									$('JCIC_STATUS').setValue('');
									$('JCIC_NOTE').setValue('');
									$('MESSAGE_TYPE').setValue('');
									actions.doDisabled(false);
								}else{
									var record = records[0];
									var FLEX_AMT2 = record['FLEX_AMT2'] || 0;
									var EXPENSE_AMT = record['EXPENSE_AMT'] || 0;
									$('FLEX_AMT2').setValue(FLEX_AMT2);
									$('EXPENSE_AMT').setValue(EXPENSE_AMT);
									$('SEQ_NO').setValue(record['SEQ_NO']);
									$('APPLY_DATE').setValue(record['APPLY_DATE']);
									var UNCONFIRM = record['UNCONFIRM'];
									$('UNCONFIRM').setValue(UNCONFIRM);
									$('UNCONFIRM').simulate('change');
									<%--[20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更--%>
									$('FLEX_PERIOD_B2').setValue(record['FLEX_PERIOD_B2'] || '');
									$('FLEX_PERIOD_E2').setValue(record['FLEX_PERIOD_E2'] || '');
									$$('input[type="radio"][name="PAY_STATUS"]').each(function(ele){
										if (record['PAY_STATUS'] == ele.value) {
											ele.checked = true;
										}
									});	
									$('PAY_NOTE').setValue(record['PAY_NOTE']);
									$$('input[type="radio"][name="JCIC_STATUS"]').each(function(ele){
										if (record['JCIC_STATUS'] == ele.value) {
											ele.checked = true;
										}
									});	
									$('JCIC_NOTE').setValue(record['JCIC_NOTE'] || '');
									$('MESSAGE_TYPE').selectedIndex = 0;
									var MESSAGE_TYPE = record['MESSAGE_TYPE'];
									if (MESSAGE_TYPE) {
										$('MESSAGE_TYPE').setValue(MESSAGE_TYPE);
									}
									actions.doDisabled(true);
								}
							}
						},
				column:[
							{header:'序號', key:'SEQ_NO'},
							{header:'每月約定還本金金額', key:'FLEX_AMT2',sortRule:'number'},
							{header:'本金彈性還期間', key:'FLEX_PERIOD_NM'},
							//{header:'適用起期', key:'APPLICABLE_TERM'}, 
							//{header:'適用應繳日', key:'APPLICABLE_PAYDT' ,sortRule:'date'}, 
							{header:'輸入日期', key:'APPLY_DATE' ,sortRule:'date'}, 
							{header:'輸入人員', key:'INPUT_NM', attrs:{style:"color: gray;font-family:'EUDC'"} }, <%--[20230322]難字修改 --%>
							{header:'覆核日期', key:'CONFIRM_DATE' ,sortRule:'date'},
							{header:'覆核人員', key:'CONFIRM_NM', attrs:{style:"color: gray;font-family:'EUDC'"} }<%--[20230322]難字修改 --%>
					]
			}); 
			<%--大寫轉換--%>
			var LOAN_ID_Q = $('LOAN_ID_Q');
			LOAN_ID_Q.observe('blur', function(){
				LOAN_ID_Q.value = LOAN_ID_Q.value.toUpperCase();
			});

			<%-- 查詢方法 --%>
			$('queryBtn').observe('click', actions.doQuery);

			<%-- 變更方法 --%>
			$('changeBtn').observe('click', actions.doChange);

			<%-- 刪除方法 --%>
			$('deleteBtn').observe('click', actions.doDelete);

			<%-- 覆核方法 --%>
			$('confirmBtn').observe('click', actions.doConfirm);

			buttonAuth();
			initValidation();
			displayMessage();
			
		}
	};
}
</script>
		</head>

		<body>

			<%-- table_A --%>
				<table id='table_A' width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
					<tr>
						<td class='tbYellow' width='30%'>貸款帳號</td>
						<td class='tbYellow2' width='15%'>
							<input type='text' name='LOAN_ID_Q' id='LOAN_ID_Q' value='' maxlength='10'>
						</td>
						<td class='tbYellow2' style='display: flex; justify-content: center;'>
							<button id='queryBtn' class='button' type='button'>查詢</button>
						</td>

					</tr>
				</table>

				<%-- table_B --%>
					<table id='table_B' width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>

						<tr>
							<td class='tbYellow' width='16%'>貸款帳號</td>
							<td class='tbYellow2' width='16%'>
								<span id='LOAN_ID' style="color: gray"></span>
							</td>
							<td class='tbYellow' width='16%'>借款人姓名</td>
							<td class='tbYellow2' width='16%'>
								<span id='BORROW_NAME' style="color: gray;font-family:'EUDC'"></span><%--[20230322]難字修改 --%>
							</td>
							<td class='tbYellow' width='16%'>本金餘額</td>
							<td class='tbYellow2' width='16%'>
								<span id='REMAIN_AMT' style="color: gray"></span>
							</td>
						</tr>

						<tr>
							<td class='tbYellow' width='16%'>貸款期數</td>
							<td class='tbYellow2' width='16%'>
								<span id='LOAN_PERIOD' style="color: gray"></span>
							</td>
							<td class='tbYellow' width='16%'>定期期數/分期期數</td>
							<td class='tbYellow2' width='16%'>
								<span id='FIX_PERIOD' style="color: gray"></span>
								<span id='SLASH' style="color: gray"></span>
								<span id='SPR_PERIOD' style="color: gray"></span>
							</td>
							<td class='tbYellow' width='16%'>已繳/有效期數</td>
							<td class='tbYellow2' width='16%'>
								<span id='PAID_TIMES' style="color: gray"></span>
								<span id='SLASH2' style="color: gray"></span>
								<span id='VALID_TIMES' style="color: gray"></span>
							</td>
						</tr>

						<tr>
							<td class='tbYellow' width='16%'>下次應繳日</td>
							<td class='tbYellow2' width='16%'>
								<span id='NEXT_PAYDT' style="color: gray"></span>
							</td>
							<td class='tbYellow' width='16%'>本金彈性還期間</td>
							<td class='tbYellow2' width='16%'>
								<span id='FLEX_PERIOD_NM' style="color: gray"></span>
							</td>
							<td class='tbYellow' width='16%'>每月約定還本金金額</td>
							<td class='tbYellow2' width='16%'>
								<span id='FLEX_AMT' style="color: gray"></span>
							</td>
						</tr>
					</table>

					<%-- table_C --%>
						<table id='table_C' width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
							<tr>
								<td class='tbYellow' width='24%'>每月還本金下限金額</td>
								<td class='tbYellow2' width='24%'>
									<span id='FLEX_MIN' style="color: gray"></span>
									<input type='hidden' name='FLEX_MIN_VAL' id='FLEX_MIN_VAL' value=''>
								</td>
								<td class='tbYellow' width='24%'>每月還本金上限金額</td>
								<td class='tbYellow2' width='24%'>
									<span id='FLEX_MAX' style="color: gray"></span>
									<input type='hidden' name='FLEX_MAX_VAL' id='FLEX_MAX_VAL' value=''>
								</td>
							</tr>
							<tr>
								<td class='tbYellow3' colspan='4'>
									<span>註：每月還本金下限金額為「 本金餘額*0.1% 」，每月還本金上限金額為「本金餘額*0.5% 」，並無條件捨去至仟元，若低於千元以仟元計</span>
								</td>
							</tr>
						</table>

						<%-- table_D --%>
							<table id='table_D' width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>

								<tr>
									<td class='tbYellow0' colspan='4' align='center'>變更後</td>
								</tr>
								<tr>
									<td class='tbYellow' width='16%'>每月還本金金額</td>
									<td class='tbYellow2' width='16%'>
										<input type='text' name='FLEX_AMT2' id='FLEX_AMT2' datatype='number' class="validateInteger"
											maxlength='11' value=''>
									</td>
									<td class='tbYellow' width='16%'>手續費</td>
									<td class='tbYellow2' width='16%'>
										<input type='text' name='EXPENSE_AMT' id='EXPENSE_AMT' datatype='number' class="validateInteger"
											maxlength='6' value=''>
										<input type='hidden' name='SEQ_NO' id='SEQ_NO' value=''>
										<input type='hidden' name='APPLY_DATE' id='APPLY_DATE' datatype='date' value=''>
										<input type='hidden' name='UNCONFIRM' id='UNCONFIRM' value=''>
									</td>
								</tr>
								<%--[20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更 --%>
								<tr>
									<td class='tbYellow' width='16%'>本金彈性還期間</td>
									<td class='tbYellow2' width='16%' colspan='3'>
										第
										<input type='text' name='FLEX_PERIOD_B2' id='FLEX_PERIOD_B2' datatype="number" maxlength="6" class="validateInteger"/>
										-
										<input type='text' name='FLEX_PERIOD_E2' id='FLEX_PERIOD_E2' datatype="number" maxlength="6" class="validateInteger"/>
										期
									</td>
								</tr>
								<%--[20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更 --%>
								<tr>
									<td class='tbYellow0' colspan='4' align='center'>審核狀況</td>
								</tr>
								<tr>
									<td class='tbYellow' width='16%'>繳息狀況</td>
									<td class='tbYellow2' width='16%' id='tdPAY_STATUS'>
										<input type='radio' name='PAY_STATUS' value='0' />免查詢
										<input type='radio' name='PAY_STATUS' value='1' />正常
										<input type='radio' name='PAY_STATUS' value='2' />異常
										-
										<input type='text' name='PAY_NOTE' id='PAY_NOTE' maxlength='50' />
									</td>
									<td class='tbYellow' width='16%'>聯徵情況</td>
									<td class='tbYellow2' width='16%' id='tdJCIC_STATUS'>
										<input type='radio' name='JCIC_STATUS' value='0' />免查詢
										<input type='radio' name='JCIC_STATUS' value='1' />正常
										<input type='radio' name='JCIC_STATUS' value='2' />異常
										-
										<input type='text' name='JCIC_NOTE' id='JCIC_NOTE' maxlength='50' />
									</td>
								</tr>
								<tr>
									<td class='tbYellow' width='16%'>是否發送通知</td>
									<td class='tbYellow2' width='16%' colspan='3'>
										<select name='MESSAGE_TYPE' id='MESSAGE_TYPE'>
											<c:forEach var="map" items="${MESSAGE_TYPE_List}">
												<option value="${map.key}">${map.value}</option>
											</c:forEach>
										</select>
									</td>
								</tr>
								<tr>
									<td class='tbYellow2' colspan='4'>
										<button id='changeBtn' class='button' type='button' disabled>變更</button>
										<button id='deleteBtn' class='button' type='button' disabled>刪除</button>
										<button id='confirmBtn' class='button' type='button' disabled>覆核</button>
									</td>
								</tr>

							</table>

							<%-- table_E --%>
								<table id='table_E' class='grid'>
								</table>
								<table id='table_F' width='100%' border='0' cellpadding='0' cellspacing='1'
									class='tbBox2'>
									<tr>
										<td class='tbYellow3'>
											<span>註：變更時請注意轉帳扣款或扣薪抽件時程。</span>
										</td>
									</tr>
								</table>

		</body>

		</html>