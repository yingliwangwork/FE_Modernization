<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSB60300.jsp
作者：簡睿甫
功能：借新還舊進度查詢
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

Event.observe(window, 'load', new DSB60300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB60300(){
	var grid;
	
	//--------------------------------------------------------------------------	
	//按鈕授權
	//--------------------------------------------------------------------------	
	function buttonAuth() {
		var authButtons = { 
			B0139:'BTN_0139'<%-- 新放初審確認 --%>,
			B0140:'BTN_0140'<%-- 新放設定輸入 --%>,
			B0141:'BTN_0141'<%-- 新放覆核確認 --%>,
			B0142:'BTN_0142'<%-- 案件轉出設定 --%>,
			B0143:'BTN_0143'<%-- 案件轉出覆核 --%>,
			B0144:'BTN_0144'<%-- 案件轉出取消 --%>,
			B0068:'BTN_0068'<%-- 退件 --%>
		};
		<dz:grantButtons FUNC_ID="DSB60300" ignored="false"/>
	}
	
	//-----------------------------------------------------
	//IM AJAX 國內共用
	//-----------------------------------------------------
	function ajaxPostIM( actionName, params, successAction, errorFunction ){
		new Ajax.Request(
			"<%=dispatcher%>/DSB6_0300/" + actionName, 
			{ parameters : params ,
			  onSuccess : function (response) {
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){      
					successAction(resp);
				}else{
					if(errorFunction){
						var msg = CSRUtil.getReturnMessage(resp);
						if(msg && msg.returnCode == -3){
							errorFunction(resp);
						}
					}
				}
			 }
		});
	}
		
	// 按鈕控制
	var button = {
		// 查詢
		doQuery: function() {
		
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.checkQuery();
			
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			ajaxPostIM( 'query' ,  {reqMap: Object.toJSON($('form').serialize(true))},
				function(resp){
					grid.load(resp.rtnList || []); 
				},
				function(resp){			
					grid.load([]); 
				}				
			);
		},
		
		// 新放初審確認
		doCredConfirm: function() {
		
			var records = grid.getCheckedRecord();
			if(records.length == 0){
				alert("請至少選取一筆資料，再作新放初審確認!");  
				return;
			}

			ajaxPostIM( 'credConfirm' ,  {ListA: Object.toJSON(records), reqMap: Object.toJSON($('form').serialize(true))},
				function(resp){			
					grid.load(resp.rtnList || []); 		
				},
				function(resp){			
					grid.load([]); 
				}				
			);
			
		},
		
		// 新放設定輸入
		doSetInput: function() {
			var records = grid.getCheckedRecord();
			var length = records.length;
			if( length == 0){
				alert("請選取一筆資料，再作新放設定輸入!");  
				return;
			} else if(length > 1) {
				alert("只能選取一筆資料作新放設定輸入!");  
				return;
			}
			
			var LP_JSON = {
				action:'${dispatcher}/DSB6_0400/prompt',
				RENEW_GPID: records[0]['RENEW_GPID'],
				isLinkTo: true
			};      
			CSRUtil.linkTo(LP_JSON, 'form');	
		},
		
		// 新放覆核確認
		doLoanConfirm: function() {
			var records = grid.getCheckedRecord();
			if(records.length == 0){
				alert("請至少選取一筆資料，再作新放覆核確認!");  
				return;
			}
		
			ajaxPostIM( 'loanConfirm' ,  {ListA: Object.toJSON(records), reqMap: Object.toJSON($('form').serialize(true))},
				function(resp){			
					grid.load(resp.rtnList || []); 		
				},
				function(resp){			
					grid.load([]); 
				}				
			);
		},
		
		// 案件轉出設定
		doExportSet: function() {
			var records = grid.getCheckedRecord();
			if(records.length == 0){
				alert("請至少選取一筆資料，再作案件轉出設定!");  
				return;
			}
			
			ajaxPostIM( 'exportSet' ,  {ListA: Object.toJSON(records), reqMap: Object.toJSON($('form').serialize(true))},
				function(resp){			
					grid.load(resp.rtnList || []); 		
				},
				function(resp){			
					grid.load([]); 
				}				
			);
		
		},
		
		// 案件轉出覆核
		doExportConfirm: function() {
			var records = grid.getCheckedRecord();
			if(records.length == 0){
				alert("請至少選取一筆資料，再作案件轉出覆核!");  
				return;
			}
			
			ajaxPostIM( 'exportConfirm' ,  {ListA: Object.toJSON(records), reqMap: Object.toJSON($('form').serialize(true))},
				function(resp){			
					grid.load(resp.rtnList || []); 		
				},
				function(resp){			
					grid.load([]); 
				}				
			);
		
		},
		
		// 案件轉出取消
		doExportCancel: function() {
			var records = grid.getCheckedRecord();
			if(records.length == 0){
				alert("請至少選取一筆資料，再作案件轉出取消!");  
				return;
			}
			
			ajaxPostIM( 'exportCancel' ,  {ListA: Object.toJSON(records), reqMap: Object.toJSON($('form').serialize(true))},
				function(resp){			
					grid.load(resp.rtnList || []); 		
				},
				function(resp){			
					grid.load([]); 
				}				
			);
		
		},
		
		// 退件
		doCancel: function() {
			var records = grid.getCheckedRecord();
			if(records.length == 0){
				alert("請至少選取一筆資料，再作退件!");  
				return;
			}
			
			ajaxPostIM( 'cancel' ,  {ListA: Object.toJSON(records), reqMap: Object.toJSON($('form').serialize(true))},
				function(resp){			
					grid.load(resp.rtnList || []); 		
				},
				function(resp){			
					grid.load([]); 
				}				
			);
		
		}
	};
	
	// 行為
	var action = {
		// 領用單位 連動 領用人員
		doGearingCRED_DEPT: function() {
			var value = $F('CRED_DEPT');
			var USE_ID = $('USE_ID');
			USE_ID.update(USE_ID.firstDescendant('option'));
			var USE_IDList = USER_ID_MAP[value];
			if(USE_IDList) {
				for(var i =0; i<USE_IDList.length;i++ ) {
					var node  = new Element('option',
						{ value: USE_IDList[i].ID }
					).update(USE_IDList[i].NAME);
					USE_ID.appendChild(node);
				}
			}
		},
		
		// 填滿B 區塊
		doFillupBlockB: function(resp) {
			var SHOW_DEPT = resp.SHOW_DEPT;
			$('SHOW_DEPT').value = SHOW_DEPT;
			$('TD_SHOW_DEPT').update(SHOW_DEPT);
					
			var SHOW_DATE = OP_DATE;
			$('SHOW_DATE').value = OP_DATE;
			$('TD_SHOW_DATE').update(OP_DATE);	
		},
		
		// 紀錄查詢條件紀錄
		doRecordHiddenValue:　function() {
			DOC_KIND = $F('DOC_KIND');
			CRED_DEPT = $F('CRED_DEPT');
			NEW_OLD = $F('NEW_OLD');
			REFER_ID = $F('REFER_ID');
			PROOF_NO = $F('PROOF_NO');
			USE_DATE = $F('USE_DATE');
		},
		
		// 數字欄位格式
		pattern : '#,###.###', 
		
		// 數字欄位處理(三位一撇)
		formatValue : function(record, value) {
			if(Object.isNumber(value)) {
				return value ? CSRUtil.$fmt(value, action.pattern) : '0';
			} else {
				return value ?  value : '0';
			}
		}
 	};
	
	// 檢核
	var validates = {
		initValidation : function() {
			// 欄位檢核
			validates.valid = new Validation("form", { mode:'validator'} );	
			Validation.addAllThese( [
				// 檢核 組號、受理編號長度 為 11
				['checkLength11', '請輸入正確受理編號!',
					function( v,ele,info ) {
						if( v && v.length != 11 ) {
							return false;
						}
						return true;				
					}
				],
				
				// 檢核 貸款帳號長度 為 10
				['checkLength10', '請輸入正確貸款帳號!',
					function( v,ele,info ) {
						if( v && v.length != 10 ) {
							return false;
						}
						return true;
					}
				],
				
				// 檢核日期查詢區間不得超過三個月:
				['checkDiffROCDateLessthan90', '查詢區間不得超過三個月!',
					function( v,ele,info ) {
						var TURN_STR_DATE = $F('TURN_STR_DATE');
						var TURN_END_DATE = $F('TURN_END_DATE');
						if( TURN_STR_DATE && TURN_END_DATE && diffDayROC(TURN_STR_DATE, TURN_END_DATE) < 90) {
							return true;
						} else if( !TURN_STR_DATE && !TURN_END_DATE) {
							return true;
						}
						$('TURN_END_DATE').style.backgroundColor = "#FF8888";
						return false;
					}
				],
				
				// 種類若與查詢時不同
				['checkNEW_OLD', '種類與原先查詢條件不同，無法作業!',
					function( v,ele,info ) {
						if( v != NEW_OLD) {
							return false;
						}
						return true;
					}
				],
				
				// 原貸帳號若與查詢時不同
				['checkREFER_ID', '原貸帳號與原先查詢條件不同，無法作業!',
					function( v,ele,info ) {
						if( v != REFER_ID) {
							return false;
						}
						return true;
					}
				],
				
				// 領用編號若與查詢時不同
				['checkPROOF_NO', '領用編號與原先查詢條件不同，無法作業!',
					function( v,ele,info ) {
						if( v != PROOF_NO) {
							return false;
						}
						return true;
					}
				],
				
				// 領用日若與查詢時不同
				['checkUSE_DATE', '領用日與原先查詢條件不同，無法作業!',
					function( v,ele,info ) {
						if( v != USE_DATE) {
							return false;
						}
						return true;
					}
				]/*,
				
				// 【區塊C】至少要有一筆資料
				['checkBEG_NO', '查無剩餘空白塗銷證明，請重新查詢!',
					function( v,ele,info ) {
						if( !Object.isNumber(v) || v < $F('TOT_NUM')) {
							return false;
						}
						return true;
					}
				]*/
			] );
		},
		
		// 查詢檢核
		checkQuery: function() {
			var QUERY_KIND = $F('QUERY_KIND');
			if(QUERY_KIND != "0") {
				// 檢查QUERY_COND不得為空值
				validates.valid.define('required', {id:'QUERY_COND', errMsg: "請輸入查詢條件!"});
				if(QUERY_KIND  ==  "1" ) {/*以受理編號查詢*/
					// 檢查QUERY_COND輸入長度為11碼
					validates.valid.define('checkLength11', {id:'QUERY_COND', errMsg: "請輸入正確受理編號!"});
				} else if( QUERY_KIND  ==  "2" ) {/*以貸款帳號查詢*/
					// 檢查QUERY_COND輸入長度為10碼
					validates.valid.define('checkLength10', {id:'QUERY_COND', errMsg: "請輸入正確貸款帳號!"});
				} else if( QUERY_KIND  ==  "3" ) { /*以借款人ID查詢*/
					// 檢查QUERY_COND輸入長度為11碼
					validates.valid.define('checkLength10', {id:'QUERY_COND', errMsg: "請輸入正確組號!"});
				}
            }
			
			// 檢核日期查詢區間不得超過三個月:
			validates.valid.define('checkDiffROCDateLessthan90', [{id:'TURN_STR_DATE'}]);
		},
		
		// 作廢檢核
		checkAbate: function() {
			validates.valid.define('checkDOC_KIND', {id:'DOC_KIND'});
			validates.valid.define('checkCRED_DEPT', {id:'CRED_DEPT'});
			validates.valid.define('checkNEW_OLD', {id:'NEW_OLD'});
			validates.valid.define('checkREFER_ID', {id:'REFER_ID'});
			validates.valid.define('checkPROOF_NO', {id:'PROOF_NO'});
			validates.valid.define('checkUSE_DATE', {id:'USE_DATE'});
		},
		
		// 檢核 領用 grid 原貸帳號、備註 輸入欄位
		checkUseGridInputs: function(records) {
			var isInputREFER_IDerror = false;
			var isInputNOTELengthCorrect = true;
			for(var i = 0 ; i < records.length; i++) {
				var rec  = records[i];
				var REFER_ID = rec['REFER_ID'];
				if( REFER_ID && REFER_ID.length == 10) {// 每筆輸入的原貸帳號不可為空白並且必須為10個字元
					isInputREFER_IDerror = true;
				}
				
				var NOTE = rec['NOTE'];
				if(NOTE) {
					if(!validation.checkInputLength(NOTE, 30 )){ // 每筆輸入的備註必須小於30個字元
						isInputNOTELengthCorrect = false;
					}
				}
			}
			
			var msg = "";	
			if( !isInputREFER_IDerror) {
				msg = "請輸入正確的原貸帳號";
			}
			
			if( !isInputNOTELengthCorrect) {
				if(msg) {
					msg = msg + "\n備註的長度不可超過30字元";
				} else {
					msg = "備註的長度不可超過30字元";
				}
			}
			
			if(msg) {
				alert(msg);
				return false;
			}
			return true;
		},
		
		// 檢核清除
		clear: function() {
			// 清空檢核標記
			validates.valid.reset();
			// 清空檢核設定
			validates.valid.clear();
			
			$('TURN_END_DATE').style.backgroundColor = "";
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSB60300" , "借新還舊", "借新還舊進度查詢" );
			
			grid = new TableUI(
				{table: $("grid"), allSortable: true, pageSize: 20, whenDataNull:'', autoCheckBox: { text:"選取"}, split: [ 'LOAN_SUM'],
				column:[
					{header:"借新還舊組號",key:"RENEW_GPID" ,attrs:{rowSpan:2}, 
						render: function(rec, v) {
						
							if (rec.RENEW_PROCESS < 5){
								var a = new Element('a',
								{href: '#'}).update(v).observe('click', function() {
									var LP_JSON = {
										action:'${dispatcher}/DSB6_0400/prompt',
										RENEW_GPID: v,
										isLinkTo: true
									};   
									CSRUtil.linkTo(LP_JSON, 'form');
								});
								return a;
							} else { 
								return v;
							}
							
					}},
					{header:"切轉日期",key:"TURN_DATE" ,attrs:{rowSpan:2},
						render: function(rec, v) {
							if(v) {
								return Date.toInputROC(v, '/');
							} else {
								return "";
							}
					}},
					{header:"新放進度",key:"RENEW_PROC_NM" ,attrs:{rowSpan:2}},
					{header:"新件受理編號",key:"APPLY_ID_GROUP",attrs:{rowSpan:2}},
					{header:"舊件貸款帳號",key:"LOAN_ID_GROUP" ,attrs:{rowSpan:2}},
					{header:"新件借款總額",key:"APPLY_SUM" ,attrs:{align:'right'},
						render: action.formatValue
					},
					{header:"新件多餘差額",key:"NEW_REMAIN_AMT" ,attrs:{align:'right'},
						render: action.formatValue
					},
					{header:"舊件未清償總額",key:"LOAN_SUM",attrs:{align:'right'},
						render: action.formatValue
					},
					{header:"應補差額",key:"OLD_REMAIN_AMT" ,attrs:{align:'right'},
						render: action.formatValue
					}
				]
			});
			
			// 檢核初始化
			validates.initValidation();
			
			if(CSRUtil.isBackLink('form')){
				button.doQuery(); 
			}
			
			// 監聽: 查詢
			$("BTN_0001").observe('click', button.doQuery );
			
			// 監聽: 新放初審確認
			$("BTN_0139").observe('click', button.doCredConfirm );
			
			// 監聽: 新放設定輸入
			$("BTN_0140").observe('click', button.doSetInput );
			
			// 監聽: 新放覆核確認
			$("BTN_0141").observe('click', button.doLoanConfirm );
			
			// 監聽: 案件轉出設定
			$("BTN_0142").observe('click', button.doExportSet );
			
			// 監聽: 案件轉出覆核
			$("BTN_0143").observe('click', button.doExportConfirm );
			
			// 監聽: 案件轉出取消
			$("BTN_0144").observe('click', button.doExportCancel );
			
			// 監聽: 退件
			$("BTN_0068").observe('click', button.doCancel );
			
			// 監聽: 狀態 連動 控制畫面顯示
			/*$("CRED_DEPT").observe('change', action.doGearingCRED_DEPT );
			
			// 監聽: 用印
			$("BTN_0146").observe('click', button.doSeal );
			
			// 監聽: 領取
			$("BTN_0147").observe('click', button.doRecieve );
			
			
			
			// 監聽: 未匯金額取消
			$("BORROW_REASON").observe('change', action.doGearingBORROW_REASON );*/
			
			// 監聽: 查詢方式(值) 轉大寫
			$("QUERY_COND").observe('change', function() {$("QUERY_COND").value = $F("QUERY_COND").toUpperCase();} );	
			PageUI.resize();
			autoFormatToDate();
			buttonAuth();
			displayMessage();
		}// end initApp()--
	}// end return--
}// end DSB60300
</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form">
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
		<tbody>
			<tr>
				<td class="tbYellow"  width="10%">查詢方式</td>
				<td class="tbYellow2" width="40%">
					<select id="QUERY_KIND" name="QUERY_KIND" >
						<c:forEach var="map" items="${QUERY_KIND_LIST}" >
							 <option value = "${map.key}" <c:if test="${map.key eq 0}" >selected</c:if>> ${map.value} </option>
						</c:forEach>						
					</select>
					<input name="QUERY_COND" id="QUERY_COND" type="text" class="textBox2" size="15" maxlength="11" value="" >
				</td>
				<td class="tbYellow" width="10%">新放進度</td>
				<td class="tbYellow2"  width="30%">
					<select id="RENEW_PROC" name="RENEW_PROC" >
						<option value="0">全部</option>
						<c:forEach var="map" items="${RENEW_PROC_LIST}" >
							 <option value = "${map.key}" > ${map.value} </option>
						</c:forEach>						
					</select>
				</td>
				<td class="tbYellow2" rowspan="2" align="center" valign="center"  width="10%">
					<input id="BTN_0001" type="button" value="查詢" class="button"> 
				</td>
			</tr>
			<tr>
				<td class="tbYellow"   width="10%">切轉日期</td>
				<td class="tbYellow2"   width="40%">
					<input name="TURN_STR_DATE" id="TURN_STR_DATE" datatype="ROCDate" type="text" 	class="textBox2  validate-ROCDate" size="12" maxlength="7" value=""> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" 	onclick="getCalendarFor($('TURN_STR_DATE'))">
					~
					<input name="TURN_END_DATE" id="TURN_END_DATE" datatype="ROCDate" type="text" 	class="textBox2  validate-ROCDate" size="12" maxlength="7" value=""> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" 	onclick="getCalendarFor($('TURN_END_DATE'))">
				</td>
				<td class="tbYellow" width="10%">承辦科別</td>
				<td class="tbYellow2"  width="30%">
					<select id="CRED_DEPT" name="CRED_DEPT" >
						<c:if test="${CRED_DEPT_ALL eq true}">
							<option value="0">全部</option> 
						</c:if>
						<c:forEach var="map" items="${CRED_DEPT_LIST}" >
							 <option value = "${map.key}" <c:if test="${map.key eq Creddept}" >selected</c:if>> ${map.value} </option>
						</c:forEach>						
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="5"  align="center" >
					<input id="BTN_0139" type="button" value='新放初審確認' class="button"> 
					<input id="BTN_0140" type="button" value='新放設定輸入' class="button"> 
					<input id="BTN_0141" type="button" value='新放覆核確認' class="button"> 
					<input id="BTN_0142" type="button" value='案件轉出設定' class="button"> 
					<input id="BTN_0143" type="button" value='案件轉出覆核' class="button"> 
					<input id="BTN_0144" type="button" value='案件轉出取消' class="button"> 
					<input id="BTN_0068" type="button" value='退件' class="button"> 
				</td>
			</tr>
		</tbody>	
	</table>
	</form>
	<table id='grid'></table>
</body>
</html>	