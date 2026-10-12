<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSD41000.jsp
功能：清償案件退回作業
作者：邱建禕
完成：2022-12-08

[20240328]
難字調整
高強禾
 -->
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible" content="IE=5.5"> 

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
 
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type='text/JavaScript' src='<%=htmlBase%>/CM/js/date.js'></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src="${htmlBase}/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/suggest.js'></script>
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

Event.observe(window, 'load', new DSD41000().initApp);

function DSD41000() {
	var grid;
	var validA,validC;
	var Q_REFER_ID;
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1000/');//建立 ajax request 物件
	
	function initValidation(){
		Validation.addAllThese([
			[ 'requiredOne', '請輸入查詢條件!'
				, function(v, element) { <%-- 若狀態為全部，則「原貸帳號」、「借款人ID	」、「原貸帳號」、「年份」必須輸入其中一個欄位，否則顯示錯誤訊息:‘請輸入查詢條件!’ --%>
					var OP_STATUS = $F('OP_STATUS');
					if('' == OP_STATUS 
					  && Validation.get('IsEmpty').test($F('REFER_ID'))
					  && Validation.get('IsEmpty').test($F('YEAR'))
					  && Validation.get('IsEmpty').test($F('BORROW_ID'))){
						return false;
					}
					return true;
				}
			],
			['checkInputREFER_ID', '請輸入正確原貸帳號!', function( v , element  ) {
				if(v){
					return v.length == 10;
				}
				return true;
			}],
			['checkInputBORROW_ID', '請輸入正確借款人ID!', function( v , element  ) {
				if(v){
					return v.length == 10 && validation.checkID(v);
				}
				return true;
			}],
			['checkYEAR', '請輸入正確的民國年份!', function( v , element  ) {
				if(v){
					return isROCdate(v+'-01-01');
				}
				return true;
			}]
		]);
		validA = new Validation('tableA', {focusOnError:true, immediate:false , mode: 'validator'});
		validA.define('requiredOne', {id: 'REFER_ID', errMsg: '請輸入查詢條件!'} );
		validA.define('checkInputREFER_ID', {id: 'REFER_ID', errMsg: '請輸入正確原貸帳號!'} );
		validA.define('checkInputBORROW_ID', {id: 'BORROW_ID', errMsg: '請輸入正確借款人ID!'} );
		validA.define('checkYEAR', {id: 'YEAR', errMsg: '請輸入正確的民國年份!'} );
		
		validC = new Validation('tableC', {focusOnError:true, immediate:false , mode: 'validator'});
		validC.define('required', {id: 'C_REFER_ID', errMsg: '請輸入原貸帳號!'} );
		validC.define('checkInputREFER_ID', {id: 'C_REFER_ID', errMsg: '請輸入正確原貸帳號!'} );
	}
	
	//按鈕授權
	function buttonAuth(){

		var authButtons = {
			B0005: 'btn_delete',//刪除
			B0117: 'btn_GlConfirm',//組長覆核
			B0123: 'btn_CGMConfirm',//科主管覆核
			B0003: 'btn_insert'//新增
		};		

		<dz:grantButtons FUNC_ID="DSD41000"/>
	};
	
	var actions = {
		<%-- 依table名稱取得 --%>
		getParams: function(target) {
			if(!target){
				return {};
			}
			var $target = $(target);

			var params = {};
			$target.select('input[type!=button], select, textarea, span').each(function(elem){
				var $elem = $(elem),
					key = $elem.getAttribute('key'),
					id = $elem.getAttribute('id'),
					field = key || id,
					tagNM = $elem.tagName;
				if(!field){
					return;
				}

				var val;
				
				if('SPAN' == tagNM){
					val = $elem.innerHTML;
				} else {
					val = $elem.getValue();
				}
				
				if(!val){
					return;
				}
				
				if('PAY_OFF_DAY' == field){
					val = toY2K(val);
				}
				
				params[field] = val;
			});
			return params;
		},
		<%-- 將查詢出來的資料放到tableC --%>
		setTableC : function(rtnMap){
			
			if(!rtnMap){
				return;
			}
			
			$('tableC').select('input[type!=button], select, textarea, span').each(function(elem){
				
				var $elem = $(elem),
				key = $elem.getAttribute('key'),
				id = $elem.getAttribute('id'),
				field = key || id,
				tagNM = $elem.tagName;
				
				if(!field){
					return;
				}
				
				var val = rtnMap[field] || '';
				
				if('PAY_OFF_DAY' == field){
					val = Date.toROC(val);
				}
				
				if('SPAN' == tagNM){
					$elem.update(val);
				} else {
					$elem.setValue(val);
				}
			});
		}
	};

	var buttons = {		
		<%-- 舊件查詢 --%>
		doOldQuery : function(){
			
			validA.reset();
			if(!validA.validate()){
				return;			
			}
			
			ajaxRequest.post('oldQuery', {reqMap : Object.toJSON(actions.getParams($('tableA')))},
				function(resp){
					grid.load(resp.rtnList || []);
				},function(resp){
					grid.load([]);
				}
			);
		},
		<%-- 刪除 --%>
		doDelete : function(){
			
			var dataList = grid.getCheckedRecord();
			if(!dataList || dataList.length === 0){
				alert('請至少選取一筆資料');
				return;
			}
			
			ajaxRequest.post('delete', 
				{reqMap : Object.toJSON(actions.getParams($('tableA'))), dataList: Object.toJSON(dataList)},
				function(resp){
					grid.load(resp.rtnList||[]);
				}
			);
			
		},
		<%-- 組長覆核 --%>
		doGlConfirm : function(){
			
			var dataList = grid.getCheckedRecord();
			if(!dataList || dataList.length === 0){
				alert('請至少選取一筆資料');
				return;
			}
			
			ajaxRequest.post('doGlConfirm', 
				{reqMap : Object.toJSON(actions.getParams($('tableA'))), dataList: Object.toJSON(dataList)},
				function(resp){
					grid.load(resp.rtnList||[]);
				}
			);
			
		},
		<%-- 科主管覆核 --%>
		doCGMConfirm : function(){
			
			var dataList = grid.getCheckedRecord();
			if(!dataList || dataList.length === 0){
				alert('請至少選取一筆資料');
				return;
			}
			
			ajaxRequest.post('doCGMConfirm', 
				{reqMap : Object.toJSON(actions.getParams($('tableA'))), dataList: Object.toJSON(dataList)},
				function(resp){
					grid.load(resp.rtnList || []);
				}
			);
			
		},
		<%-- 新增前查詢  --%>
		doQueryForInsert : function(){
			
			validC.reset();
			if(!validC.validate()){
				return;			
			}
			
			Q_REFER_ID = '';
			
			ajaxRequest.post('queryForInsert', 
				{REFER_ID : $('C_REFER_ID').getValue()},
				function(resp){
					var rtnMap = resp.rtnMap || '';
					actions.setTableC(rtnMap);
					Q_REFER_ID = rtnMap['REFER_ID'];
				}
			);
		},
		<%-- 新增 --%>
		doInsert : function(){
			
			if(!Q_REFER_ID){
				alert('請先以原貸帳號查詢!');
				return;
			}
			
			if(Q_REFER_ID != $F('C_REFER_ID')){
				alert('原貸帳號已異動，請重新查詢!');
				return;
			}
			
			ajaxRequest.post('insert', 
				{reqMap : Object.toJSON(actions.getParams($('tableA'))), insertMap : Object.toJSON(actions.getParams($('tableC')))},
				function(resp){
					grid.load(resp.rtnList || []);
				}
			);
		}
	};

	return {
			
		initApp : function(){
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>
			PageUI.createPageWithAllBodySubElement('DSD41000', '清償作業', '清償案件退回作業');

			<%-- tableUI設定 --%>
			grid = new TableUI ({
				table:$("grid"), pageSize: 5, allSortable:true ,
				autoCheckBox:{ type: "checkbox", text:'選取', isSelectAll: true},
				<%-- [20240328] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{ header: "原貸帳號",key: "REFER_ID" },
					{ header: "同原貸下貸款帳號",key: "LOAN_IDS" },
					{ header: "契約效力",key: "LOAN_STATUS_NM" },
					{ header: "核發清償日期",key: "PAY_OFF_DAY",
						render : function(rec , val){ <%-- 顯示民國年 --%>
							return Date.toROC(val);
						}
					},
					{ header: "清償已結案資料袋",key: "CLOSED_BAG_NM" },
					{ header: "資料袋位置",key: "BAG_LOCATION_NM" },
					{ header: "備註",key: "COMMENT" },
					{ header: "作業進度",key: "OP_STATUS_NM" },
					{ header: "輸入人員單位",key: "INPUT_DEPT" },
					{ header: "輸入日期",key: "INPUT_DATE",
						render : function(rec , val){ <%-- 顯示民國年 --%>
							return Date.toROC(val);
						} 
					},
					<%-- [20240328] 難字調整：輸入人員、組長覆核人員 --%>
					{ header: "輸入人員",key: "INPUT_NAME", attrs:{ style:"font-family:'EUDC'" }},
					{ header: "組長覆核人員",key: "CHECK_NAME1", attrs:{ style:"font-family:'EUDC'" }},
					{ header: "科主管覆核日期",key: "CHECK_DATE2",
						render : function(rec , val){ <%-- 顯示民國年 --%>
							return Date.toROC(val);
						} 
					},
					<%-- [20240328] 難字調整：科主管覆核人員 --%>
					{ header: "科主管覆核人員",key: "CHECK_NAME2", attrs:{ style:"font-family:'EUDC'" }}
				]
			});
			
			$('btn_oldQuery').observe('click', buttons.doOldQuery); <%-- 舊件查詢 --%>
			$('btn_delete').observe('click', buttons.doDelete); <%-- 刪除 --%>
			$('btn_GlConfirm').observe('click', buttons.doGlConfirm); <%-- 組長覆核 --%>
			$('btn_CGMConfirm').observe('click', buttons.doCGMConfirm);  <%-- 科主管覆核 --%>
			$('btn_queryForInsert').observe('click', buttons.doQueryForInsert); <%-- 新增前查詢 --%>
			$('btn_insert').observe('click', buttons.doInsert); <%-- 新增 --%>
			// 監聽: 原貸帳號轉大寫
			$('REFER_ID').observe('keyup', 
				function(){
					$('REFER_ID').value = $F('REFER_ID').toUpperCase();
				} 
			);
			initValidation();
			buttonAuth();
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id='tableA' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
		<tr>
			<td class="tbYellow" width="15%">原貸帳號</td>		
			<td class="tbYellow2" width="30%">
				<input type="text" class="input" name="REFER_ID" id="REFER_ID"/>
			</td>		
			<td class="tbYellow" width="15%">年份</td>		
			<td class="tbYellow2" width="30%">
				<input type="text" class="input" name="YEAR" id="YEAR"/>
			</td>		
			<td class="tbYellow2" width="10%" >
				<button type="button" class="button" id="btn_oldQuery">查詢</button>
				<button type="button" class="button" id="btn_delete">刪除</button>
			</td>				
		</tr>
		<tr>
			<td class="tbYellow" width="15%">借款人ID</td>
			<td class="tbYellow2" width="30%">
				<input type="text" class="input" name="BORROW_ID" id="BORROW_ID"/>
			</td>		
			<td class="tbYellow" width="15%">狀態</td>
			<td class="tbYellow2" width="30%">
				<select id='OP_STATUS'>
					<option value=''>全部</option>
					<c:forEach var="entry" items="${OP_STATUS_LIST}">
						<option value="${entry.key}">${entry.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" width="10%" >
				<button type="button" class="button" id="btn_GlConfirm">組長覆核</button>
				<button type="button" class="button" id="btn_CGMConfirm">科主管覆核</button>
			</td>		
		</tr>
	</table>
	<table id="grid"></table>
	<table id='tableC' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow0" colspan="4" align="center">新增清償案件退回</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="4" align="center">
				<button type="button" class="button" id="btn_queryForInsert">查詢</button>
				<button type="button" class="button" id="btn_insert">新增</button>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">原貸帳號</td>
			<td class="tbYellow2" width="30%">
				<input type="text" class="input" name="C_REFER_ID" id="C_REFER_ID" key='REFER_ID' />
			</td>
			<td class="tbYellow" width="15%">同原貸下貸款帳號</td>
			<td class="tbYellow2" width="30%">
				<span id='C_LOAN_IDS' key='LOAN_IDS'></span>
				<input type="hidden" name="C_LOAN_STATUS" id="C_LOAN_STATUS" key='LOAN_STATUS' /> <%-- 隱藏欄位 --%>
			</td>	
		</tr>
		<tr>
			<td class="tbYellow" width="15%">核發清償日期</td>
			<td class="tbYellow2" width="30%">
				<span id='PAY_OFF_DAY' key='PAY_OFF_DAY'></span>
			</td>
			<td class="tbYellow" width="15%">契約效力</td>
			<td class="tbYellow2" width="30%">
				<span id='LOAN_STATUS_NM' key='LOAN_STATUS_NM'></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">清償已結案資料袋</td>
			<td class="tbYellow2" width="30%">
			    <span id='CLOSED_BAG_NM' key='CLOSED_BAG_NM'></span>
				<input type="hidden" name="CLOSED_BAG" id="CLOSED_BAG" key='CLOSED_BAG' /> <%-- 隱藏欄位 --%>
			</td>
			<td class="tbYellow" width="15%">資料袋所在地</td>
			<td class="tbYellow2" width="30%">
				<select id='C_BAG_LOCATION' key='BAG_LOCATION'>
					<c:forEach var="entry" items="${BAG_LOCATION_LIST}">
						<option value="${entry.key}">${entry.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">備註</td>
			<td class="tbYellow2" width="50%" colspan="3">
				<textarea id="C_COMMENT" key='COMMENT' rows="5" cols="100"></textarea>
			</td>
		</tr>
	</table>
</form>
</body>
</html>