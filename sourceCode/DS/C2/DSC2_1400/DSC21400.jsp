<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC21400.jsp
功能：退票轉出作業
作者：溫子?
完成：2013/05/
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC21400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC21400(){

var grid; 
var reqMap_rc;//查詢條件
	function initValidation(){		
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});	
		valid1.define( "required" , [{ id: "LOAN_ID"  , errMsg:"請輸入貸款帳號查詢!!"}]);
		valid1.define( "required" , [{ id: "PAY_TERM"  , errMsg:"請輸入繳款期數查詢!!"}]);
		//valid1.define( "required" , [{ id: "SEQ_NO"  , errMsg:"請輸入序號查詢!!"}]);
		
		valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});	
		valid2.define( "validate-digits" , [{ id: "PAY_TERM"  , errMsg:"繳款期數有誤，無法作業!!(須為數值)"}]);
		valid2.define( "validate-digits" , [{ id: "SEQ_NO"  , errMsg:"序號有誤，無法作業!!(須為數值)"}]);
	}
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_1400/" + actionName,
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
var buttons ={

	getMap : function(){
				return {			
					LOAN_ID : $F('LOAN_ID'),
					PAY_TERM :$F('PAY_TERM'),
					SEQ_NO : $F('SEQ_NO'),
					PAY_KIND :$F('PAY_KIND')
				}	
			
			}
	,doQuery : function (){
		if(!valid1.validate()){
			return;
		}
		if(!valid2.validate()){
			return;
		}
		reqMap_rc=buttons.getMap();
		ajaxPost( 'query', {reqMap : Object.toJSON(reqMap_rc)}
					,function(resp){
						grid.load(resp.rtnList);
					},function(resp){
						grid.load([]);
					}
				);
	}
	,doReject : function(rec){
		if(!valid1.validate(rec)){
			return;
		}
		if(!valid2.validate()){
			return;
		}
		var tempCondition = buttons.getMap();
				for(key in tempCondition){
					if(tempCondition[key] != reqMap_rc[key]){
						alert('欲轉出的貸款帳號、繳款期數、序號、繳別與原先查詢的資料不同，無法作業!');
						return;
					}				
				}
		var Export_Map = {};
		Export_Map['LOAN_ID']=rec['LOAN_ID'];
		Export_Map['PAY_KIND']=rec['PAY_KIND'];
		Export_Map['PAY_TERM']=rec['PAY_TERM'];
		Export_Map['SEQ_NO']=rec['SEQ_NO'];
		Export_Map['EXPORT_DEPT']=$F('EXPORT_DEPT');
		Export_Map['EXPORT_REASON']='5';

		reqMap_rc=buttons.getMap();
		
		ajaxPost( 'reject', {Export_Map : Object.toJSON(Export_Map),reqMap : Object.toJSON(reqMap_rc)}
				,function(resp){
					grid.load(resp.rtnList);
				}
			);
	
	}

}
	return {
		initApp : function() {

			PageUI.createPageWithAllBodySubElement('DSC21400', '收息帳務', '退票轉出作業');
				
			
				autoFormatToNumber();
				grid = new TableUI(//B950000398
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true,	split: ['RETAIN_INT','BANK_CODE'],
				
				column:[			
					{header:"期數", key:"PAY_TERM"},
					{header:"繳別",key:"PAY_KIND_NM"},
					{header:"序號",key:"SEQ_NO"},
					{header:"計息起日",key:"INT_BEGDT",
						render : function(rec ,val ){
							
							return rec.PAY_KIND!=5 && val ? Date.toROC(val) : '';
						}
					},
					{header:"計息終日",key:"INT_ENDDT",
						render : function(rec ,val ){
							
							return rec.PAY_KIND!=5 && val ? Date.toROC(val) : '';
						}
					},
					{header:"實繳日",key:"REAL_PAYDT",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					},
					{header:"繳前本金",key:"LAST_PRINCIPAL", sortRule:'number',
						render : function(rec ,val ){
						
							return rec.PAY_KIND!=5 && val || val===0 ? MoneyFormat(val) : '';
						}
					},
					{header:"利率",key:"RATE",
						render : function(rec ,val ){
							
							return rec.PAY_KIND!=5 && val ? val : '';
						}
					},
					{header:"本金",key:"PRINCIPAL", sortRule:'number',
						render : function(rec ,val ){
							
							return rec.PAY_KIND!=5 && val || val===0 ? MoneyFormat(val) : '';
						}
					},
					{header:"利息",key:"INTEREST", sortRule:'number',
						render : function(rec ,val ){
							
							return rec.PAY_KIND!=5 && val || val===0 ? MoneyFormat(val) : '';
						}
					},
					{header:"應利",key:"RETAIN_INT", sortRule:'number',
						render : function(rec ,val ){
							
							return rec.PAY_KIND!=5 && val || val===0 ? MoneyFormat(val) : '';
						}
					},
					{header:"延滯息",key:"DELAY_INT", sortRule:'number',
						render : function(rec ,val ){
							
							return rec.PAY_KIND!=5 && val || val===0 ? MoneyFormat(val) : '';
						}
					},
					{header:"違約金",key:"RENEGE", sortRule:'number',
						render : function(rec ,val ){
							
							return rec.PAY_KIND!=5 && val || val===0 ? MoneyFormat(val) : '';
						}
					},
					{header:"訴訟管理費",key:"LAWSUIT_FEE", sortRule:'number',
						render : function(rec ,val ){
								return  val || val===0 ? MoneyFormat(val) : '';
							}
					},
					{header:"代扣稅款",key:"TAX", sortRule:'number',
						render : function(rec ,val ){
							
							return rec.PAY_KIND!=5 && val || val===0 ? MoneyFormat(val) : '';
						}
					},
					{header:"上期結餘",key:"LAST_BALANCE", sortRule:'number',
						render : function(rec ,val ){
							
							return rec.PAY_KIND!=5 && val || val===0 ? MoneyFormat(val) : '';
						}
					},
					{header:"繳款方式",key:"PAY_TYPE_NM"},
					{header:"票據狀態",key:"CHECK_STATUS_NM"},
					{header:"入帳單位",key:"ACNT_DEPT"},
					{header:"轉出原因",key:"EXPORT_REASON",
						render : function(rec ,val ){
							
							if(rec.CHECK_STATUS==2){
								 var span = new Element('span');
								 var check = new Element("input" , {type : 'button' , value : '轉出' , className : 'button' ,id:'reject'} );
								 check.observe("click",function(event){buttons.doReject(rec)});
								 var input1 = new Element("select");
								 input1.add(new Option('退票轉出','5'));
								 span.insert(input1).insert(check);
								 return span;	
							}else{
								return '';
							}
						}
					},
					{header:"行庫代號",key:"BANK_CODE",attrs:{colSpan:3},
						render : function(rec ,val ){
							
							return  val ? val : '非票據';
						}
					},
					{header:"票據號碼",key:"CHECK_NO"},
					{header:"繳現金額",key:"CASH_AMT", sortRule:'number',
						render : function(rec ,val ){
								return  val || val===0 ? MoneyFormat(val) : '';
							}},
					{header:"票據日期",key:"CHECK_DATE",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					},
					{header:"",key:"none1",attrs:{colSpan:4} }
					
				]
				});
				//畫面檢核
				initValidation();
				$("BTN_QUERY").observe('click', buttons.doQuery);
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
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">貸款帳號</td>
			<td class="tbYellow2"  >
			<input id="LOAN_ID"  type="text" class="textBox2 " onblur="this.value = this.value.toUpperCase()"  maxlength="10"/></td>
			<td class="tbYellow" width="10%">繳款期數</td>
			<td class="tbYellow2"  >
			<input id="PAY_TERM"  type="text" class="textBox2" maxlength="3" /></td>
			<td class="tbYellow" width="10%">序號</td>
			<td class="tbYellow2"  >
			<input id="SEQ_NO"  type="text" class="textBox2" maxlength="2" /></td>
			
			<td class="tbYellow" width="10%">繳別</td>
			<input  type = 'hidden' id = 'EXPORT_DEPT' value='${EXPORT_DEPT}'/>
			<td class="tbYellow2" width="15%" >
				<select id="PAY_KIND">
							<c:forEach var="map" items="${PAY_KIND_LIST}">
									<option value="${map.key}">${map.value}</option>
							</c:forEach>
				</select> 
		
			</td>
			<td class="tbYellow2" >
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
			</td>
		</tr>
	</table>
	<table id = "grid" ></table>
</form>
</body>
</html>