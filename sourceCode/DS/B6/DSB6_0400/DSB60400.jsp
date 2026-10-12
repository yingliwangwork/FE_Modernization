<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSB60400.jsp
作者：簡睿甫
功能：新放設定輸入
完成：
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>
<script type="text/JavaScript">

Event.observe(window, 'load', new DSB60400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var theDSB60400 = new DSB60400();
function DSB60400(){
	var grid_B;
	var grid_C;
	var grid_E;
	var RENEW_GPID = '<c:out value="${RENEW_GPID}" default="" escapeXml="false" />';
	
	var B400Map = <c:out value="${B400Map}" default="[]" escapeXml="false" />;
	var addrList = <c:out value="${addrList}" default="[]" escapeXml="false" />;
	var newList = <c:out value="${newList}" default="[]" escapeXml="false" />;
	var IntMap = <c:out value="${IntMap}" default="[]" escapeXml="false" />;
	var oldList = <c:out value="${oldList}" default="[]" escapeXml="false" />;
	
	var ApplySum = '<c:out value="${ApplySum}" default="" escapeXml="false" />';
	var LoanSum = '<c:out value="${LoanSum}" default="" escapeXml="false" />';
	var NewRemainAmt = '<c:out value="${NewRemainAmt}" default="" escapeXml="false" />';
	var OldRemainAmt = '<c:out value="${OldRemainAmt}" default="" escapeXml="false" />';
	var TOT_REMIT_AMT = '<c:out value="${TOT_REMIT_AMT}" default="" escapeXml="false" />';
	var LP_JSON;
	
	//--------------------------------------------------------------------------	
	//按鈕授權
	//--------------------------------------------------------------------------	
	function buttonAuth() {
		var authButtons = { 
			B0016:'BTN_0016'<%-- 輸入 --%>,
			B0068:'BTN_0068'<%-- 退件 --%>
		};
		<dz:grantButtons FUNC_ID="DSB60400" ignored="false"/>
	}
	
	//-----------------------------------------------------
	//IM AJAX 國內共用
	//-----------------------------------------------------
	function ajaxPostIM( actionName, params, successAction, errorFunction ){
		new Ajax.Request(
			"<%=dispatcher%>/DSB6_0400/" + actionName, 
			{ parameters : params ,
			  onSuccess : function (response) {
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){      
					successAction(resp);
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			 }
		});
	}
		
	// 按鈕控制
	var button = {
		// 輸入
		doLoanInput: function() {

			// 清空檢核
			validates.clear();
			// 檢核設定
			validates.checkLoadInput();
			
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			var MapB = {
				// 借新還舊組號	
				RENEW_GPID: RENEW_GPID,
				// 收息單位
				GETINT_DEPT: $F('GETINT_DEPT'),
				// 尚未使用
				// 新放進度代碼
				RENEW_PROCESS: B400Map.RENEW_PROCESS,
				// 切轉日期	
				TURN_DATE: B400Map.TURN_DATE,
				// 新件匯款總額.
				TOT_REMIT_AMT: TOT_REMIT_AMT,
				// 扣薪組別
				SALARY_GROUP: $F('SALARY_GROUP')
			}
			
			ajaxPostIM( 'loanInput' ,  {MapB: Object.toJSON(MapB), RENEW_GPID: RENEW_GPID}, 
				function(resp) {
					action.rtnAjaxDataHandler(resp);
					$('BTN_0016').disable(); 
					$('BTN_0068').disable(); 
				}	
			);
		},
		
		// 退件
		doCancel: function() {
			var MapA = {
				// 借新還舊組號
				RENEW_GPID: B400Map.RENEW_GPID,
				// 新放進度代碼
				RENEW_PROCESS: B400Map.RENEW_PROCESS,
				// 切轉日期	
				TURN_DATE: B400Map.TURN_DATE,
				// 新件匯款總額
				TOT_REMIT_AMT: TOT_REMIT_AMT
			}
			
			ajaxPostIM( 'cancel' ,  {MapA: Object.toJSON(MapA), RENEW_GPID: RENEW_GPID}, action.rtnAjaxDataHandler);
			
		},
		
		// 為了linkBack無法prompt取得參數，所設置的查詢功能
		doQuery: function() {
			ajaxPostIM( 'queryData' ,  {RENEW_GPID: RENEW_GPID}, action.rtnAjaxDataHandler);
		}
	};
	
	// 行為
	var action = {
		// AJAX成功後處理動作
		rtnAjaxDataHandler: function(resp) {
			B400Map = resp.B400Map;
			addrList = resp.addrList;
			newList = resp.newList;
			IntMap = resp.IntMap;
			oldList = resp.oldList;
			TOT_REMIT_AMT = resp.TOT_REMIT_AMT;
			ApplySum = resp.ApplySum;
			LoanSum = resp.LoanSum;
			NewRemainAmt = resp.NewRemainAmt;
			OldRemainAmt = resp.OldRemainAmt;
			
			// 初始頁面資料處理 A區塊到G區塊 (1 ~ 7)
			action.doFillupBlockA();
			grid_B.load(addrList);
			grid_C.load(newList);
			$('APPLY_SUM').update( action.formatValue("",ApplySum));
			action.doFillupBlockD();
			grid_E.load(oldList);
			
			$('LOAN_SUM').update( action.formatValue("",LoanSum));
			$('NEW_REMAIN_AMT').update( action.formatValue("", NewRemainAmt));
			$('OLD_REMAIN_AMT').update( action.formatValue("",OldRemainAmt));
			action.doFillupBlockG();
			if(B400Map.CRED_INPUT_ID) {
				$('block_G').hide();
			}
			
			if(LP_JSON) {
				if(B400Map.RENEW_PROCESS == '2') { // 新放初審
					$("BTN_0016").enable();
					$("BTN_0068").enable();
					// 【 D 區】欄位型態改成可輸入欄位
					$('GETINT_DEPT').readOnly = false;
					
					var SALARY_GROUP_LIST = resp.SALARY_GROUP_LIST;
					$('SALARY_GROUP').update();
					var keys = Object.keys(SALARY_GROUP_LIST);
					for(var i = 0; i < keys.length; i++ ) {
						var option = new Element('option',
							{value: keys[i] }).update(SALARY_GROUP_LIST[keys[i]]);
						$('SALARY_GROUP').appendChild(option);
					}
					$('SALARY_GROUP').value = IntMap.SALARY_GROUP;
					$('SALARY_GROUP').enable();
				} else {
					$("BTN_0016").disable();
					$("BTN_0068").disable();
					
					$('SALARY_GROUP').update();
					var option = new Element('option',
						{value: IntMap.SALARY_GROUP }).update(IntMap.SALARY_GROUP_NM);
					$('SALARY_GROUP').appendChild(option);
						
					if( B400Map.RENEW_PROCESS == '1') { // 徵信設定
						$('block_D').hide();
					} else {
						// 【 D 區】欄位型態為顯示欄位
						$('GETINT_DEPT').readOnly = true;
						$('SALARY_GROUP').disable();
					}
				}
				
				
			}
		},
		
		// 填滿A 區塊
		doFillupBlockA: function() {
			CSRUtil.voToInputs(formA, B400Map);
			// 切轉日期
			var TURN_DATE = B400Map.TURN_DATE;
			if(TURN_DATE) {
				$('TD_TURN_DATE').update( Date.toInputROC(TURN_DATE, '/') || "");
			}
			
			// 借新還舊組號	
			$('TD_RENEW_GPID').update(B400Map.RENEW_GPID || "");
			
			// 新放進度	
			$('TD_RENEW_PROC_NM').update(B400Map.RENEW_PROC_NM || "");
		},
		
		// 填滿D 區塊
		doFillupBlockD: function() {
			// 收息單位
			$('GETINT_DEPT').value = IntMap.GETINT_DEPT || "";
			
			// 扣薪組別說明 
			$('PERSONNEL').update( IntMap.PERSONNEL || "");
		},
		
		// 填滿G 區塊
		doFillupBlockG: function() {
			CSRUtil.voToInputs(formG, B400Map);
			
			$$('#block_G  td[class=tbYellow2]').each(function(td) {
				var id = td.id;
				if(id) {
					td.update(B400Map[id.replace('TD_', '')]);
				}
			});
			
			$w('TD_CRED_INPUT_DATE TD_CRED_CONFIRM_DATE TD_LOAN_INPUT_DATE TD_LOAN_CONFIRM_DATE TD_ACNT_DATE TD_EXPORT_INPUT_DATE TD_EXPORT_CONFIRM_DATE TD_EX_ACNT_DATE').each(function(ele) {
				var key = ele.replace('TD_', '');
				var value = B400Map[key];
				if(value) {
					$(ele).update(Date.toInputROC(value, '/'));
				}
			});
		},
		
		// 數字欄位格式
		pattern : '#,###.###', 
		
		// 數字欄位處理(三位一撇)
		formatValue : function(record, value) {
			return value ? CSRUtil.$fmt(value, action.pattern) : '0';
		}
 	};
	
	// 檢核
	var validates = {
		initValidation : function() {
			// 欄位檢核
			validates.valid = new Validation("formA", { mode:'validator'} );	
			Validation.addAllThese( [
				// 檢核 收息單位長度 為 7
				['checkLength7', '請輸入正確收息單位!',
					function( v,ele,info ) {
						if( v && v.length != 7 ) {
							return false;
						}
						return true;				
					}
				]
			] );
		},
		
		// 輸入檢核
		checkLoadInput: function() {
			validates.valid.define('required', {id:'GETINT_DEPT', errMsg: "請輸入收息單位!"});
			validates.valid.define('checkLength7', {id:'GETINT_DEPT'});
		},
		
		// 檢核清除
		clear: function() {
			// 清空檢核標記
			validates.valid.reset();
			// 清空檢核設定
			validates.valid.clear();
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSB60400" , "借新還舊", "新放設定輸入" );
			
			grid_B = new TableUI(
				{table: $("grid_B"), allSortable: true, pageSize: 10, whenDataNull:'', title:"擔保品資訊", 
				column:[
					{header:"新件受理編號╱舊件貸款帳號",key:"ID", attrs:{width:'30%'} },
					{header:"擔保品地址",key:"GAGE_ADDR" , attrs:{width:'70%'}}
				]
			});
			
			grid_C = new TableUI(
				{table: $("grid_C"), allSortable: true, pageSize: 10, whenDataNull:'', title:"新件",  
				column:[
					{header:"受理編號",key:"NAPPLY_ID" },
					{header:"借款人ID",key:"NBORROW_ID" },
					{header:"借款人姓名",key:"NBORROW_NAME" },
					{header:"借款金額",key:"NLOAN_AMT" ,attrs:{align:'right'},
						render: action.formatValue
					},
					{header:"作業種類",key:"TRANS_KIND_NM" },
					{header:"匯款金額",key:"REMIT_AMT" ,attrs:{align:'right'}, 
						render: function(rec, v) {
							var a = new Element('a',
							{href: '#'}).update(action.formatValue("",  v)).observe('click', function() {
								var LP_JSON = {
									action:'${dispatcher}/DSB4_0220/prompt',
									APPLY_ID: rec.NAPPLY_ID, // 匯款檔受理編號
									SER_NO: rec.NSER_NO,  // 匯款檔序號
									RENEW_GPID: RENEW_GPID,
									isLinkTo: true
								};   
								CSRUtil.linkTo(LP_JSON, 'formA');
							});
							return a;
					}},
					{header:"部入金額",key:"PARTIAL_AMT" ,attrs:{align:'right'},
						render: action.formatValue
					}
				]
			});
			
			grid_E = new TableUI(
				{table: $("grid_E"), allSortable: true, pageSize: 10, whenDataNull:'', split: [ 'PAY_DATE'], title:"舊件", 
				column:[
					{header:"帳號",key:"OLOAN_ID" , attrs:{rowSpan:2}},
					{header:"借款人ID",key:"OBORROW_ID" , attrs:{rowSpan:2}},
					{header:"借款人姓名",key:"OBORROW_NAME" , attrs:{rowSpan:2}},
					{header:"期數",key:"PAID_TIMES" , attrs:{rowSpan:2}},
					{header:"應繳日",key:"NEXT_PAYDT" ,
						render: function(rec, v) {
							if(v) {
								return Date.toInputROC(v, '/');
							} else {
								return "　";
							}
					}},
					{header:"應繳金額",key:"DUTY_PAYMT" ,attrs:{align:'right'},
						render: action.formatValue
					},
					{header:"利息",key:"INTEREST" ,attrs:{align:'right'},
						render: function(rec, v) {
							return v+rec.RETAIN_INT;
					}},
					{header:"違約金",key:"RENEGE" ,attrs:{align:'right'},
						render: action.formatValue
					},
					{header:"上期結餘",key:"LAST_BALANCE" ,attrs:{align:'right'},
						render: action.formatValue
					},
					{header:"未清償金額",key:"LOAN_REMAIN" , attrs:{rowSpan:2, align:'right'},
						render: action.formatValue
					},
					{header:"人工暫收金額",key:"BALC_AMT" , attrs:{rowSpan:2, align:'right'},
						render: action.formatValue
					},
					{header:"實繳日",key:"PAY_DATE" ,
						render: function(rec, v) {
							if(v) {
								return Date.toInputROC(v, '/');
							} else {
								return "　";
							}
					}},
					{header:"應攤本金",key:"PRINCIPAL" ,attrs:{align:'right'},
						render: action.formatValue
					},
					{header:"逾期息",key:"DELAY_INT" ,attrs:{align:'right'},
						render: action.formatValue
					},
					{header:"管理費",key:"LAWSUIT_FEE" ,attrs:{align:'right'},
						render: action.formatValue
					},
					{header:"代扣稅款",key:"TAX" ,attrs:{align:'right'},
						render: action.formatValue
					}
				]
			});
			
			// 檢核初始化
			validates.initValidation();
			
			buttonAuth();
			
			// 回上頁處理
			LP_JSON = CSRUtil.isBackLink('formA');
			if(LP_JSON){            
				var BQ_ARG = LP_JSON.BQ_ARG || {};
				//填回顯示的欄位 
				RENEW_GPID = BQ_ARG.RENEW_GPID;
				if(RENEW_GPID){
					$('RENEW_GPID').value = RENEW_GPID;
				}            

				//在畫面欄位處理完後才執行 doQuery() 
				button.doQuery();
				
				
			} else {
				// 初始頁面資料處理 A區塊到G區塊 (1 ~ 7)
				action.doFillupBlockA();
				grid_B.load(addrList);
				grid_C.load(newList);
				$('APPLY_SUM').update( action.formatValue("",ApplySum));
				action.doFillupBlockD();
				grid_E.load(oldList);
				$('LOAN_SUM').update( action.formatValue("",LoanSum));
				$('NEW_REMAIN_AMT').update( action.formatValue("", NewRemainAmt));
				$('OLD_REMAIN_AMT').update( action.formatValue("",OldRemainAmt));
				action.doFillupBlockG();
				if(B400Map.CRED_INPUT_ID) {
					$('block_G').hide();
				}
				
				if(B400Map.RENEW_PROCESS == '2') { // 新放初審
					$("BTN_0016").enable();
					$("BTN_0068").enable();
					// 【 D 區】欄位型態改成可輸入欄位
					$('GETINT_DEPT').readOnly = false;
					$('SALARY_GROUP').value = IntMap.SALARY_GROUP;
					$('SALARY_GROUP').enable();
				} else {
					$("BTN_0016").disable();
					$("BTN_0068").disable();
					
					$('SALARY_GROUP').update();
					var option = new Element('option',
						{value: IntMap.SALARY_GROUP }).update(IntMap.SALARY_GROUP_NM);
					$('SALARY_GROUP').appendChild(option);
					
					if( B400Map.RENEW_PROCESS == '1') { // 徵信設定
						$('block_D').hide();
					} else {
						// 【 D 區】欄位型態為顯示欄位
						$('GETINT_DEPT').readOnly = true;
						$('SALARY_GROUP').disable();
					}
				}

			}

			// 監聽: 輸入
			$("BTN_0016").observe('click', button.doLoanInput );
			
			// 監聽: 退件
			$("BTN_0068").observe('click', button.doCancel );
			
			// 監聽: 上一頁
			$("BTN_LINKBACK").observe('click', function() { CSRUtil.linkBack() });

			// 監聽: 收息單位轉大寫
			$("GETINT_DEPT").observe('change', function() {$("GETINT_DEPT").value = $F("GETINT_DEPT").toUpperCase();} );

			PageUI.resize();
			autoFormatToDate();
			
			displayMessage();
		},// end initApp()--
		
		// 點選＊其他資訊 可控制區塊的表格顯示或不顯示
		doShowBlockGorNot: function() {
			if($('block_G').getStyle('display') == 'none') {
				$('block_G').show();
			} else {
				$('block_G').hide();
			}
		}
	}// end return--
}// end DSB60400
</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="formA">
	<table id='block_A' width="100%" border="0" cellspacing="0" cellpadding="0" class="tbBox2">
		<tbody>
				<tr>
					<td class="tbYellow"   width="10%">切轉日期
						<input type="hidden" id="TURN_DATE" name="TURN_DATE" value="">
					</td>
					<td id="TD_TURN_DATE" class="tbYellow2"   width="20%">
					</td>
					<td class="tbYellow"   width="10%">借新還舊組號
						<input type="hidden" id="RENEW_GPID" name="RENEW_GPID" value="">
					</td>
					<td id="TD_RENEW_GPID" class="tbYellow2" width="20%">
					</td>
					<td class="tbYellow"   width="10%">新放進度
						<input type="hidden" id="RENEW_PROC_NM" name="RENEW_PROC_NM" value="">
					</td>
					<td id="TD_RENEW_PROC_NM" class="tbYellow2" width="30%">
					</td>
				</tr>
				<tr>
					<td colspan="6"  align="center" >
						<input id="BTN_0016" type="button" value='輸入' class="button"> 
						<input id="BTN_0068" type="button" value='退件' class="button"> 
					</td>
				</tr>
		</tbody>	
	</table>
	</form>
	<table id='grid_B'></table>
	<table id='grid_C'></table>
	<form id="formD0">
	<table id='block_D0' width="100%" class="tbBox2">
		<tbody>
				<tr>
					<td >新件借款總額 == <span id="APPLY_SUM"></span>元</td>
				</tr>
		</tbody>	
	</table>
	</form>
	<form id="formD">
	<div id='block_D'>
		<table  width="100%" class="tbBox2">
			<tbody>					
					<tr>
						<td class="tbBlue"   width="25%">收息單位</td>
						<td class="tbBlue" align="center"  width="75%">扣薪組別</td>					
					</tr>
					<tr>
						<td class="tbBlue2"   width="25%">
							<input name="GETINT_DEPT" id="GETINT_DEPT" type="text" class="textBox2" size="10" maxlength="7" value="" >
						</td>
						<td class="tbBlue2"  width="30%">
							<select id="SALARY_GROUP" name="SALARY_GROUP" >
								<c:forEach var="map" items="${SALARY_GROUP_LIST}" >
									 <option value = "${map.key}" <c:if test="${map.key eq SALARY_GROUP}" >selected</c:if>> ${map.value} </option>
								</c:forEach>						
							</select>
							<span id="PERSONNEL" ></span>
						</td>
					</tr>
			</tbody>	
		</table>	
	</div>
	</form>		
	<table id='grid_E'></table>
	<form id="formE">
	<table id='block_E' width="100%" class="tbBox2">
		<tbody>
				<tr>
					<td >舊件未清償總額 == <span id="LOAN_SUM"></span>元</td>
				</tr>
		</tbody>	
	</table>
	</form>	
	<form id="formF">
	<table id='block_F' width="100%" class="tbBox2">
		<tbody>
				<tr>
					<td class="tbYellow0" >新件多餘差額 ==<span id="NEW_REMAIN_AMT"></span>元</td>
				</tr>
				<tr>
					<td class="tbYellow0" >應補差額 ==<span id="OLD_REMAIN_AMT"></span>元</td>
				</tr>
			</form>
		</tbody>	
	</table>
	</form>	
	<div class="tbBox2"><a href="#" onclick="theDSB60400.doShowBlockGorNot()" >＊其他資訊</a></div>
	<form id="formG">	
	<div id='block_G'>
		<table width="100%" class="tbBox2">
			<tbody>
					<tr>
						<td class="tbYellow"   width="10%">徵信設定人員
							<input type="hidden" id="CRED_INPUT_NAME" name="CRED_INPUT_NAME" value="">
						</td>
						<td id="TD_CRED_INPUT_NAME" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">徵信設定日期
							<input type="hidden" id="CRED_INPUT_DATE" name="CRED_INPUT_DATE" value="">
						</td>
						<td id="TD_CRED_INPUT_DATE" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">新放初審人員
							<input type="hidden" id="CRED_CONFIRM_NAME" name="CRED_CONFIRM_NAME" value="">
						</td>
						<td id="TD_CRED_CONFIRM_NAME" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">新放初審日期
							<input type="hidden" id="CRED_CONFIRM_DATE" name="CRED_CONFIRM_DATE" value="">
						</td>
						<td id="TD_CRED_CONFIRM_DATE" class="tbYellow2"   width="10%">
					</tr>
					<tr>
						<td class="tbYellow"   width="10%">新放設定人員
							<input type="hidden" id="LOAN_INPUT_NAME" name="LOAN_INPUT_NAME" value="">
						</td>
						<td id="TD_LOAN_INPUT_NAME" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">新放設定日期
							<input type="hidden" id="LOAN_INPUT_DATE" name="LOAN_INPUT_DATE" value="">
						</td>
						<td id="TD_LOAN_INPUT_DATE" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">新放覆核人員
							<input type="hidden" id="LOAN_CONFIRM_NAME" name="LOAN_CONFIRM_NAME" value="">
						</td>
						<td id="TD_LOAN_CONFIRM_NAME" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">新放覆核日期
							<input type="hidden" id="LOAN_CONFIRM_DATE" name="LOAN_CONFIRM_DATE" value="">
						</td>
						<td id="TD_LOAN_CONFIRM_DATE" class="tbYellow2"   width="10%">
					</tr>
					<tr>
						<td class="tbYellow"   width="10%">結帳人員
							<input type="hidden" id="ACNT_NAME" name="ACNT_NAME" value="">
						</td>
						<td id="TD_ACNT_NAME" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">結帳日期
							<input type="hidden" id="ACNT_DATE" name="ACNT_DATE" value="">
						</td>
						<td id="TD_ACNT_DATE" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">結帳序號
							<input type="hidden" id="ACNT_NO" name="ACNT_NO" value="">
						</td>
						<td id="TD_ACNT_NO" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%"></td>
						<td class="tbYellow2"   width="10%">
					</tr>
					<tr>
						<td class="tbYellow"   width="10%">轉出設定人員
							<input type="hidden" id="EXPORT_INPUT_NAME" name="EXPORT_INPUT_NAME" value="">
						</td>
						<td id="TD_EXPORT_INPUT_NAME" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">轉出設定日期
							<input type="hidden" id="EXPORT_INPUT_DATE" name="EXPORT_INPUT_DATE" value="">
						</td>
						<td id="TD_EXPORT_INPUT_DATE" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">轉出覆核人員
							<input type="hidden" id="EXPORT_CONFIRM_NAME" name="EXPORT_CONFIRM_NAME" value="">
						</td>
						<td id="TD_EXPORT_CONFIRM_NAME" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">轉出覆核日期
							<input type="hidden" id="EXPORT_CONFIRM_DATE" name="EXPORT_CONFIRM_DATE" value="">
						</td>
						<td id="TD_EXPORT_CONFIRM_DATE" class="tbYellow2"   width="10%">
					</tr>
					<tr>
						<td class="tbYellow"   width="10%">轉出結帳人員
							<input type="hidden" id="EX_ACNT_NAME" name="EX_ACNT_NAME" value="">
						</td>
						<td id="TD_EX_ACNT_NAME" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">轉出結帳日期
							<input type="hidden" id="EX_ACNT_DATE" name="EX_ACNT_DATE" value="">
						</td>
						<td id="TD_EX_ACNT_DATE" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">轉出結帳序號
							<input type="hidden" id="EX_ACNT_NO" name="EX_ACNT_NO" value="">
						</td>
						<td id="TD_EX_ACNT_NO" class="tbYellow2"   width="10%">
						<td class="tbYellow"   width="10%">
						</td>
						<td class="tbYellow2"   width="10%">
					</tr>
			</tbody>	
		</table>
	</div>
	</form>	
	<div align="center">				
		<tr>
			<td colspan="8"   >
				<input id="BTN_LINKBACK" type="button" value='回上一頁' class="button"> 
			</td>
		</tr>
	</div>
</body>
</html>	