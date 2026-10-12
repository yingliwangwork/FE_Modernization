<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC30801.jsp
功能：轉帳扣款查詢
作者：吳昀倫
完成：2019/07/17
-->

<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%> 
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script><!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script><!-- 必要 -->
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/validation.js"></script>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript'>
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSC30801().initApp);
function DSC30801(){
	var grid;
	var valid;
	var EMP_DivNo = '${EMP_DivNo}';
	function initValidation(){
		Validation.addAllThese([
			['validateTRANS_YM', '轉帳年月格式有誤', function(v){
				if(v){
					<%--轉帳年月5碼數字--%>
					return v.length == 5 && (/^\d+$/.test(v));
				}
			}],
			['validGETINT_DEPT', '單位代號格式有誤', function(v) { 
				if(v.length > 0){
					<%--單位代號7碼--%>
					return v.length == 7; 
				}
				return true;
			}],
			['validLOAN_ID', '貸款帳號格式有誤', function(v) { 
				if(v.length > 0){
					<%--貸款帳號10碼英數字--%>
					return /^\w{10}/.test(v);
				}
				return true;
			}],
			['validBORROW_ID', '借款人ID格式有誤', function(v) { 
				if(v.length > 0){
					<%--身份證字號檢核--%>
					return validation.checkROCID(v);
				}
				return true;
			}],
			['validTRANS_GROUP', '當轉帳組別為全部時，至少要輸入另一個查詢條件(貸款帳號 、借款人ID)', function(v) {
				if($F('TRANS_GROUP')=="" && $F('BORROW_ID') == "" && $F('LOAN_ID') == "" ){
					return false;					
				}				
				return true;
			}],
			['validTRANS_BANK2', '當轉帳銀行為全部時，至少要輸入另一個查詢條件(貸款帳號 、借款人ID)', function(v) {
				if($F('TRANS_BANK2')=="" && $F('BORROW_ID') == "" && $F('LOAN_ID') == "" ){
					return false;					
				}				
				return true;
			}],
			['validDEDUCT_STATUS', '當扣款狀態為全部時，至少要輸入另一個查詢條件(貸款帳號 、借款人ID)', function(v) {
				if($F('DEDUCT_STATUS')=="" && $F('BORROW_ID') == "" && $F('LOAN_ID') == "" ){
						return false;
				}				
				return true;
			}],
			['validateIs0800', '請輸入貸款帳號或借款人ID', function(v){
				if($F('LOAN_ID') == '' && $F('BORROW_ID') == ''){
					return false;
				}
				return true;
			}],
			['validateIsServiceCenter', '請輸入貸款帳號、借款人ID或單位代號', function(v){
				if($F('LOAN_ID') == '' && $F('BORROW_ID') == '' && $F('GETINT_DEPT') == ''){
					return false;
				}
				return true;
			}],
			['validateIsServiceCenter_2', '若輸入非自單位代號，僅限以貸款帳號或借款人ID查詢', function(v){
				if(v != '' && v.length == 7){
					if($F('LOAN_ID') == '' && $F('BORROW_ID') == '' && $F('GETINT_DEPT') != EMP_DivNo){
						return false;
					}
				}
				return true;
			}]
		]);
		valid = new Validation("form1");
 	    <c:if test="${is0800 eq 'Y'}">
			valid.define('validateIs0800' , "LOAN_ID");
		</c:if>
		<c:if test="${isServiceCenter eq 'Y'}">
			valid.define('validateIsServiceCenter' , "LOAN_ID");
			valid.define('validateIsServiceCenter_2' , "GETINT_DEPT");
		</c:if>
 	    valid.define('validateTRANS_YM' , "TRANS_YM");
		valid.define('validGETINT_DEPT' , "GETINT_DEPT");
 	    valid.define('validLOAN_ID' , "LOAN_ID");
 	    valid.define('validBORROW_ID' , "BORROW_ID");
 	    valid.define('validTRANS_GROUP' , "TRANS_GROUP");
 	    valid.define('validTRANS_BANK2' , "TRANS_BANK2");
		valid.define('validDEDUCT_STATUS' , "DEDUCT_STATUS");
	}	
	
	var action = {	
		<%-- 取得畫面資料 --%>
		getQueryInfo : function(){
			var record = {
				TRANS_YM : $F('TRANS_YM'),
				TRANS_GROUP : $F('TRANS_GROUP'),
				TRANS_BANK2 : $F('TRANS_BANK2'),
				DEDUCT_STATUS : $F('DEDUCT_STATUS'),
				LOAN_ID : $F('LOAN_ID'),
				BORROW_ID : $F('BORROW_ID'),
				GETINT_DEPT : $F('GETINT_DEPT')
			};
			return record;
		},
		<%-- 輸入內容轉大寫 --%>
		toUpperCase : function(event){
			this.value = this.value.toUpperCase();
		}	
	}
	
	var button = {
		<%-- 查詢 --%>
		doQuery : function(){
			if($F('TRANS_YM') == ''){
				alert('請輸入轉帳年月');
				return;
			}

			if(!valid.validate()){
				return;
			}
			
			var param = {'queryInfo' : Object.toJSON(action.getQueryInfo())};
			grid.load('${dispatcher}/DSC3_0801/query', param);
		}
	}
	
	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement('DSC30801', '繳款方式', '轉帳扣款查詢');
			grid = new TableUI({
				table : $("grid"),
				pageSize: 20,
				isLoadByFatch : true,
				column : [
					{header: '轉帳年月', key: 'TRANS_YM'},
					{header: '轉帳組別', key: 'TRANS_GROUP'},
					{header: '貸款帳號', key: 'LOAN_ID'},
					{header: '借款人ID', key: 'BORROW_ID'},
					{header: '期數', key: 'PAY_TERM'},
					{header: '扣款日期', key: 'DEDUCT_DATE', sortRule:'ROCDate', pattern:'yyy/MM/dd'},
					{header: '扣款金額', key: 'REAL_PAYMT',
						render : function(rec ,val){
							return val ? MoneyFormat(val) : '';
						}
					},
					{header: '扣款狀態', key: 'DEDUCT_STATUS_NM'},
					{header: '扣款不成原因', key: 'TRANS_CSTATUS'},
					{header: '扣款銀行', key: 'TRANS_BANK_NM'},
					{header: '回存日期', key: 'REJECT_DATE', sortRule:'ROCDate', pattern:'yyy/MM/dd'},
					{header: '回存金額', key: 'DEDUCT_AMT',
						render : function(rec ,val){
							return val ? MoneyFormat(val) : '';
						}
					},
					{header: '單位', key: 'DIV_NAME'},
				]				
			});
			
			<%-- 以下欄位要自動轉大寫 --%>
			$('LOAN_ID', 'BORROW_ID', 'GETINT_DEPT').each(function(ele){
				ele.observe('change', action.toUpperCase); 
			});
			
			$('btnQuery').observe('click', button.doQuery);			
			
			<c:if test='${is0800 eq "Y"}'>
			$('GETINT_DEPT').disabled = true;
			</c:if>
			
			initValidation();
			displayMessage();
			//若[貸款帳號]或[借款人ID]或[單位代號]其中之一欲輸入，則另外兩個欄位清空
			$('LOAN_ID').observe('focus',function(){		
				$w('BORROW_ID GETINT_DEPT').each(
					function(id){
						$(id).value ='';
					}
				);
			});
			$('BORROW_ID').observe('focus',function(){		
				$w('LOAN_ID GETINT_DEPT').each(
					function(id){
						$(id).value ='';
					}
				);
			});
			$('GETINT_DEPT').observe('focus',function(){		
				$w('LOAN_ID BORROW_ID').each(
					function(id){
						$(id).value ='';
					}
				);
			});
		}
	};

}
</script>
</head>
<body>
<form id="form1">
	<table id="table1" class="tbBox2" width='100%'>
	<tr>
		<td class="tbYellow">轉帳年月</td>
		<td class="tbYellow2">
			<input type='text' class="textBox2" maxlength="10" id='TRANS_YM' title='轉帳年月' value='${rtnMap.TRANS_YM}'/>
		</td>
		<td class="tbYellow">轉帳組別</td>
		<td class="tbYellow2">
			<select id='TRANS_GROUP'>
				<option value="">全部</option>
				<c:forEach var="map" items="${TRANS_GROUP_List}">
					<option value="${map.key}" <c:if test='${rtnMap.TRANS_GROUP eq map.key}'>selected</c:if>>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">轉帳銀行</td>
		<td class="tbYellow2">
			<select id='TRANS_BANK2'>
				<option value="">全部</option>
				<c:forEach var="map" items="${TRANS_BANK2_List}">
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">扣款狀態</td>
		<td class="tbYellow2">
			<select id='DEDUCT_STATUS'>
				<option value="">全部</option>
				<c:forEach var="map" items="${DEDUCT_STATUS_List}">
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow2" rowspan="2" style="text-align:center; vertical-align: middle">
			<button type='button' class='button' id='btnQuery'>查詢</button>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">貸款帳號</td>
		<td class="tbYellow2">
			<input type='text' class="textBox2" id='LOAN_ID' title='貸款帳號' maxlength="10"/>
		</td>
		<td class="tbYellow">借款人ID</td>
		<td class="tbYellow2">
			<input type='text' class="textBox2" id='BORROW_ID' title='借款人ID' maxlength="10"/>
		</td>
		<td class="tbYellow">單位代號</td>
		<td class="tbYellow2" colspan="3">
			<input type='text' class="textBox2" id='GETINT_DEPT' title='單位代號' <c:if test="${isServiceCenter eq 'Y'}">value='${EMP_DivNo}'</c:if>/>
		</td>
	</tr>
	</table>
	<table id='grid'></table>
</form>
</body>
</html>