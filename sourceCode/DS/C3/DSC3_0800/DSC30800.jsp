<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC30800.jsp
功能：轉帳重覆退匯查詢
作者：溫子?
完成：2013/05
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/date.js'></script>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC30800().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC30800(){
	var grid;
	var valid1;
	
	var TRANS_YM_Q=[];
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_0800/" + actionName,
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
	
	//檢核欄位
	function initValidation(){
		Validation.addAllThese([
			['validTRANS_GROUP_Q', '當轉帳組別為全部時，至少要輸入另一個查詢條件(貸款帳號 、借款人ID、單位代號)', function(v , node) { 
				if($F('TRANS_GROUP_Q')=="" && ($F('LOAN_ID_Q') == "" && $F('BORROW_ID_Q') == "" && $F('GETINT_DEPT_Q') == "" )){
					return false;
				}
				return true;
			}],
			['validLOAN_ID_Q', '貸款帳號格式有誤', function(v , node) { 
				if(v){
					<%--貸款帳號10碼英數字--%>
					return v.length == 10 && (/^[a-zA-Z0-9]+$/.test(v)); 
				}
				return true;
			}],
			['validBORROW_ID_Q', '借款人ID格式有誤', function(v , node) { 
				if(v){
					<%--身份證字號檢核--%>
					return validation.checkROCID( v );
				}
				return true;
			}],
			['validGETINT_DEPT_Q', '單位代號格式有誤', function(v , node) { 
				if(v){
					<%--單位代號7碼英數字--%>
					return v.length == 7 && (/^[a-zA-Z0-9]+$/.test(v)); 
				}
				return true;
			}]
		]);
		valid1 = new Validation("form", { focusOnError:true, immediate:false});
 	    valid1.define('required' , [{ id : "TRANS_YM_Q" , errMsg:'請輸入轉帳年月'}] );
 	    valid1.define('validLOAN_ID_Q' , [{ id : "LOAN_ID_Q" }] );
 	    valid1.define('validBORROW_ID_Q' , [{ id : "BORROW_ID_Q" }] );
 	    valid1.define('validate-ROCDateYM' , [{ id : "TRANS_YM_Q" , errMsg:'轉帳年月格式有誤'}] );
 	    valid1.define('validTRANS_GROUP_Q' , [{ id : "TRANS_GROUP_Q" , errMsg:'當轉帳組別為全部時，至少要輸入另一個查詢條件(貸款帳號 、借款人ID、單位代號)'}] );
 	    valid1.define('validGETINT_DEPT_Q' , [{ id : "GETINT_DEPT_Q" , errMsg:'單位代號格式有誤'}] );
	}	
	
	var buttons ={
		doQuery : function(){
			if(!valid1.validate()){
				return;
			}
			var TRANS_GROUP_Q=$('TRANS_GROUP_Q').value;
			//發送AJAX
			if(!$F('TRANS_YM_Q')){
				alert("請輸入畫面的轉帳年月");
				return;
			}
			if($F('TRANS_GROUP_Q')=="" && ($F('LOAN_ID_Q') == "" && $F('BORROW_ID_Q') == "" && $F('GETINT_DEPT_Q') == "" )){
				alert("當轉帳組別為全部時，至少要輸入另一個查詢條件(貸款帳號 、借款人ID、單位代號)");
				return;
			}
			ajaxPost( 'query', {TRANS_YM_Q: $F('TRANS_YM_Q'),TRANS_GROUP_Q:TRANS_GROUP_Q,LOAN_ID_Q:$F('LOAN_ID_Q'),BORROW_ID_Q:$F('BORROW_ID_Q'),GETINT_DEPT_Q:$F('GETINT_DEPT_Q')}
				,function(resp){
					
					grid.load(resp.rtnList);
				},function(resp){ 
					
					//如果失敗,把前一次的內容清掉
					grid.load([]);
				}
			);
		
		},
		doQueryPayment : function(){

			ajaxPost( 'query', {BORROW_ID: $F('QBORROW_ID'),LOAN_ID:$F('QLOAN_ID'),LINK_FROM:$F('LINK_FROM')}
				,function(resp){
					
					grid.load(resp.rtnList);
				},function(resp){ 
					
					//如果失敗,把前一次的內容清掉
					grid.load([]);
				}
			);
		
		}		
	
	}
		return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC30800', '繳款方式', '轉帳重覆退匯查詢');
				
				grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: true, overDiv:true,			
				column:[			
					{header:"轉帳年月", key:"TRANS_YM",
						render : function(rec ,val ){
								return Date.toROC(val).replace(/\//g,'').substring(0,5)||'';
						}
					},
					{header:"轉帳組別",key:"TRANS_GROUP"},
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"借款人ID",key:"BORROW_ID"},
					{header:"期數",key:"PAY_TERM"},
					{header:"扣款日期",key:"DEDUCT_DATE"},
					{header:"扣款金額",key:"DEDUCT_AMT",
						render : function(rec ,val ){
								return val ? MoneyFormat(val) : '';
							}
					},
					{header:"扣款銀行",key:"TRANS_BANK"},
					{header:"回存日期",key:"REJECT_DATE"},
					{header:"回存金額",key:"DEDUCT_AMT1",
						render : function(rec ,val ){
								return val ? MoneyFormat(val) : '';
							}
					},
					{header:"單位",key:"GETINT_DEPT_NM"}
					
					
				
				]
				});
				initValidation();
				$('TRANS_GROUP_Q').value="${rtnList.TRANS_GROUP}";
				$('TRANS_YM_Q').value=Date.toROC("${rtnList.TRANS_YM}").replace(/\//g,'').substring(0,5);
				$('GETINT_DEPT_Q').value="${user_unit}";
				
				$('BTN_QUERY').observe('click',buttons.doQuery);
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
				
				//2019-03-19客戶收付款系統查詢查詢期款重複扣款回存
				if('${QBORROW_ID}' || '${QLOAN_ID}'){		
					buttons.doQueryPayment();
					$('table1').hide();
				}	
			}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id="table1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<input id="QBORROW_ID" name="QBORROW_ID" value='${QBORROW_ID}' type="hidden"/>
		<input id="QLOAN_ID" name="QLOAN_ID" value='${QLOAN_ID}' type="hidden"/>
		<input id="LINK_FROM" name="LINK_FROM" value='${LINK_FROM}' type="hidden"/>	
	<td class="tbYellow" width="12%" align="left" >轉帳年月</td>
		<td class="tbYellow2" >
			<input id="TRANS_YM_Q"  name="TRANS_YM_Q" type="text" class="textBox2"  maxlength="5"  fieldName = "資料日期"/>
		</td>
	<td class="tbYellow" width="12%" align="left" >轉帳組別</td>
	<td class="tbYellow2" width="10%">
				<select id="TRANS_GROUP_Q"">
						<option value="">全部</option>
							<c:forEach var="map" items="${TRANS_GROUP_List}">
									<option value="${map.key}">${map.value}</option>
							</c:forEach>
				</select> 
	</td>
	<td class="tbYellow" width="12%" align="left" >貸款帳號</td>
	<td class="tbYellow2" width="10%">
	<input id="LOAN_ID_Q"  type="text" class="textBox2 " onblur="this.value = this.value.toUpperCase()"/></td>
	<td class="tbYellow" width="12%" align="left" >借款人ID</td>
	<td class="tbYellow2" width="10%">
	<input id="BORROW_ID_Q"  type="text" class="textBox2 " onblur="this.value = this.value.toUpperCase()"/></td>
	<td class="tbYellow" width="12%" align="left" >單位代號</td>
	<td class="tbYellow2" width="10%">
	<input id="GETINT_DEPT_Q"  type="text" class="textBox2 " /></td>
	<td class="tbYellow2" >
			<input id="BTN_QUERY" type="button" value="查詢" class="button"> 
		</td>
	</table>
	<table id = "grid" ></table>
</form>
</body>
</html>