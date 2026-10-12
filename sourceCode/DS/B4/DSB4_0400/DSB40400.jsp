
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB40400.jsp
作者：張智翔
功能：退件紀錄查詢
完成：2012/05/02

[20240613]
難字調整
高強禾
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<%-- [20240613] 難字調整 --%>
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

// 產生畫面物件
var DSB40400 = new DSB40400();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB40400.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB40400(){
	//檢核變數宣告
	var valid1;		
	
	var grid;		
	
	//檢核輸入欄用Array
	var inputsArray = [
		{ id: "APPLY_ID" },
		{ id: "REMIT_STR_DATE" },
		{ id: "REMIT_END_DATE" },
		{ id: "CANCEL_STR_DATE" },
		{ id: "CANCEL_END_DATE" },
		{ id: "CRED_INPUT_ID" },
		{ id: "LOAN_INPUT_ID" },
		{ id: "CRED_ID" }
	]	
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'validatequery8',  '請至少輸入一條件查詢!', 
			//8個欄位要選一個輸入
			function(){	
				var check = false;
				var fun = $$('#form1 input[type = text]' , '#form1 select');
				fun.each(
					function(elem){				
						if(!Validation.get('IsEmpty').test(elem.value)){
							check = true;
						}
					}
				)
				return check ? true : false;
			}],
			[ 'validateID_withDate',  '選擇退件人員或輸入人員時，請指定日期查詢!', 
			//8個欄位要選一個輸入
			function(){	
				var check = false;
				var dateIDS = $$('.select1');
				var dateInputs = $$('.date1');		
				for(var i = 0 ; i < dateIDS.length ; i ++){
					if(!Validation.get('IsEmpty').test(dateIDS[i].value)){
							//如果有選值 , 檢查date , 只要其中一個值,就ok return true
							for(var k = 0 ; k < dateInputs.length ; k ++){
								if(!Validation.get('IsEmpty').test(dateInputs[k].value)){
									return true;
								}
							}							
							//當今天都跑完,發現日期沒值,代表下拉選單有選ID,但日期為空,就false							
							return false;
					}				
				}		
				return true;
			}],
			[ 'validateChooseInput_Id',  '退件人員請擇一輸入一項(徵信或新放)', 
			//退件人員只能擇一輸入
			function(){				
				var CRED_INPUT_ID = $("CRED_INPUT_ID").value;
				var LOAN_INPUT_ID = $("LOAN_INPUT_ID").value;
				return CRED_INPUT_ID !== "" && LOAN_INPUT_ID !== "" ? false : true;			
			}],
			
			[ 'validateAPPLY_ID',  '請輸入正確受理編號!(長度需為11碼)', 
			//投保公司檢核要為產險
			function(v){				
				return !Validation.get('IsEmpty').test(v) && (v.length !== 11) ? false : true;				
			}],	
			['validate-3Month-Interval', '查詢區間不得超過三個月(90天)!', function(str_dt , end_dt) {
				var o=0;
				if(Validation.get('IsEmpty').test(str_dt)){
				    o=o+1;
				}
				if(Validation.get('IsEmpty').test(end_dt)){
				    o=o+1;
				}				
				if(o==1){
					return false;
				}				
				if( !Validation.get('IsEmpty').test(str_dt) && !Validation.get('IsEmpty').test(end_dt) ){	//確認有輸入		
					return diffDayROC(str_dt, end_dt ) <=90;
				}
				return true;
			}]
			
		]);
		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });			
		valid1.define( "validate-ROCDate" , { id: "REMIT_STR_DATE" } );	
		valid1.define( "validate-ROCDate" , { id: "REMIT_END_DATE" } );	
		valid1.define( "validate-ROCDate" , { id: "CANCEL_STR_DATE" } );	
		valid1.define( "validate-ROCDate" , { id: "CANCEL_END_DATE" } );
		valid1.define( "validate-ROCDate-Interval" , [{ id : "REMIT_STR_DATE" },{ id: "REMIT_END_DATE" }] );		
		valid1.define( "validate-ROCDate-Interval" , [{ id : "CANCEL_STR_DATE" },{ id: "CANCEL_END_DATE" }] );	
		valid1.define( "validate-3Month-Interval" , [{ id : "REMIT_STR_DATE" },{ id: "REMIT_END_DATE" }] );
		valid1.define( "validate-3Month-Interval" , [{ id : "CANCEL_STR_DATE" },{ id: "CANCEL_END_DATE" }] );
		valid1.define( "validatequery8" , inputsArray );	
		valid1.define( "validateID_withDate" , 
		[
			{ id : "REMIT_STR_DATE" },
			{ id : "REMIT_END_DATE" },
			{ id : "CANCEL_STR_DATE" },
			{ id : "CANCEL_END_DATE" }
			
		]);
		valid1.define( "validateAPPLY_ID" , { id: "APPLY_ID" });	
		valid1.define( "validateChooseInput_Id" , { id: "CRED_INPUT_ID" } );	
		valid1.define( "validateChooseInput_Id" , { id: "LOAN_INPUT_ID" } );
		
	}    

	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSB4_0400/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {	
		
		//查詢資料
		doQuery : function(event){	
			//先把下面資料清掉,因為dataMapForNew裡面不包含B區TABLE UI裡面的欄位			
			
			if(!valid1.validate()){
				return;			
			}
			
			//轉大寫
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			var sendRecord = makeRecord();		
			
			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){						
					grid.load(resp.rtnList);						
				},
				function(resp){	
					//失敗把前次內容清掉 
					grid.load([]);			
				}
			);		
		}
	};
	

	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {
			APPLY_ID	: $('APPLY_ID').value,// 受理編號
			REMIT_STR_DATE	: toY2K($('REMIT_STR_DATE').value),// 原定匯款日(起)	
			REMIT_END_DATE	: toY2K($('REMIT_END_DATE').value),// 原定匯款日(迄)	
			CANCEL_STR_DATE	: toY2K($('CANCEL_STR_DATE').value), // 退件日期(起)	
			CANCEL_END_DATE	: toY2K($('CANCEL_END_DATE').value),//退件日期(迄)	
			CRED_INPUT_ID	: $('CRED_INPUT_ID').value ,// 退件人員(徵信)
			LOAN_INPUT_ID	: $('LOAN_INPUT_ID').value ,// 退件人員(新放	
			CRED_ID	: $('CRED_ID').value //徵信輸入人員					
		}
		return sendRecord;	
	}
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB40400", "匯款處理", "退件紀錄查詢");			
				grid = new TableUI ( {
						table: $("grid"), pageSize: 20, allSortable:true , split: ['BORROW_NAME'],
						<%-- [20240613] 難字調整 --%>
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:	[		
							{header: "受理編號",key: "APPLY_ID"},
							{header: "帳號",key: "ACNT"},			
							{header: "貸款種類",key: "LOAN_KIND_NM"},		
							{header: "原匯款日",key: "REMIT_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}			
							},		
							{header: "退件日期",key: "CANCEL_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							},		
							{header: "退件原因",key: "CANCEL_REASON_NM",attrs : { rowSpan : 2}},
							<%-- [20240613] 難字調整：借款人、戶名 --%>
							{header: "借款人",key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},			
							{header: "戶名",key: "ACCOUNT_NAME", attrs:{ style:"font-family:'EUDC'" }},		
							{header: "匯款金額",key: "REMIT_AMT",
								render : function(rec , val){
									return val ? MoneyFormat(val) : 0
								}					
							},		
							{header: "匯款狀況",key: "REMIT_TYPE_NM"},			
							<%-- [20240613] 難字調整：退件人員 --%>
							{header: "退件人員",key: "CANCEL_NM", attrs:{ style:"font-family:'EUDC'" }}	
						]
					});		
					
								
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );				
								
				initValidation();	
				
				fix();

				displayMessage();						
			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" width="8%" align="left">
				受理編號
			</td>
			<td class="tbYellow2">
				<input id="APPLY_ID" name="APPLY_ID" type="text" size="11" maxlength = "11" class="text2" fieldName = "受理編號" />				
			</td>
			<td class="tbYellow" width="10%" align="left" >
				原定匯款日
			</td>
			<td class="tbYellow2" colspan = "3">
				<input name="REMIT_STR_DATE" id='REMIT_STR_DATE' type="text" class="textBox2 date1" size="8" maxlength="7" datatype="ROCDate" fieldName = "原定匯款日(起)">
				<img id="calImg1" src="<%=imageBase%>/CM/calendar.gif"  alt="Date" onclick="getCalendarFor($('REMIT_STR_DATE'))">
				~
				<input name="REMIT_END_DATE" id='REMIT_END_DATE' type="text" class="textBox2 date1" size="8" maxlength="7" datatype="ROCDate" fieldName = "原定匯款日(迄)">
				<img id="calImg2" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('REMIT_END_DATE'))">  
			</td>				
			<td class="tbYellow2"  align = "center" rowspan="2">
				<input id = "btn_query" type = "button" class = "button" value = "查詢"/>				
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				退件日期
			</td>
			<td class="tbYellow2" >
				<input name="CANCEL_STR_DATE" id='CANCEL_STR_DATE' type="text" class="textBox2 date1" size="8" maxlength="7" datatype="ROCDate" fieldName = "退件日期(起)">
				<img id="calImg1" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('CANCEL_STR_DATE'))">
				~
				<input name="CANCEL_END_DATE" id='CANCEL_END_DATE' type="text" class="textBox2 date1" size="8" maxlength="7" datatype="ROCDate" fieldName = "退件日期(迄)">
				<img id="calImg2" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('CANCEL_END_DATE'))">  
			</td>	
			<td class="tbYellow"  align="left">
				退件人員
			</td>
			<td class="tbYellow2">
				(徵信)
				<%-- [20240613] 難字調整：徵信人員 --%>
				<select id="CRED_INPUT_ID" name="CRED_INPUT_ID" class="select1" fieldName="徵信人員" alt="ch">	
					<option value="" />全部</option>
					<c:forEach items="${CRED_INPUT_ID_LIST}" var="row">
						<option value="${row.ID}"/>${row.NAME}</option>						
					</c:forEach>							
				</select>
				(新放)
				<%-- [20240613] 難字調整：新放人員 --%>
				<select id="LOAN_INPUT_ID" name="LOAN_INPUT_ID" class="select1" fieldName="新放人員" alt="ch">	
					<option value="" />全部</option>
					<c:forEach items="${LOAN_INPUT_ID_LIST}" var="row">
						<option value="${row.ID}"/>${row.NAME}</option>						
					</c:forEach>							
				</select>
			</td>
			<td class="tbYellow" width = "12%" align="left">
				徵信輸入人員
			</td>
			<td class="tbYellow2">				
				<%-- [20240613] 難字調整：徵信輸入人員 --%>
				<select id="CRED_ID" name="CRED_ID" class="select1" fieldName="徵信輸入人員" alt="ch">	
					<option value="" />全部</option>
					<c:forEach items="${CRED_ID_LIST}" var="row">
						<option value="${row.ID}"/>${row.NAME}</option>						
					</c:forEach>							
				</select>				
			</td>
		</tr>	
		</table>
	</form>	
		<table id='grid' width="100%"></table>
</body>
</html>