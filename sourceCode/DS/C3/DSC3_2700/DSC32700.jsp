<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC32700.jsp
功能：預繳明細列印
作者：溫子?
完成：2013/06/

[20241104] 修改件 難字調整 吳志鴻
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>

<%-- [20241104] 難字調整 --%>
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
Event.observe(window, 'load', new DSC32700().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC32700(){
var grid;
var reqList=[];
function initValidation(){

		Validation.addAllThese([
			[ 'validateLOAN_ID_10',  '貸款帳號長度不正確 需為10碼',
				function(v){				
					return (v.length != 10) ? false : true ;
				}
			],
			[ 'chkUsableID',  '請輸入正確借款人ID', 
				function(v){ 
					if(v.length == 8){ 
						return iscmpid(v) 
					}else{ 
						return validation.checkROCID(v) 
					} 
					return true; 
				} 
			]
		]);
			//查詢用檢核
			valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
			//valid1.define( "required" , { id: "LOAN_ID" , errMsg:"貸款帳號不可空白!!" } );
			valid1.define( "validateLOAN_ID_10" , { id: "LOAN_ID"});
			valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid2.define( "chkUsableID" , { id: "BORROW_ID"});
}
//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_2700/" + actionName,
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
var buttons={
	doshow : function (node , boxStatus , records ){
	
		reqList = [];		
		//取TABLE UI 點選的資料
		for(var i=0;i<grid.getCheckedRecord().length;i++){
			var map ={
				LOAN_ID : records[i].LOAN_ID
				,BORROW_ID : records[i].BORROW_ID
				,BORROW_NAME : records[i].BORROW_NAME
				,BANK_CODE : records[i].BANK_CODE
				,CHECK_NO : records[i].CHECK_NO
				,CHECK_ACCNO : records[i].CHECK_ACCNO
				,CHECK_DATE : records[i].CHECK_DATE
				,CHECK_AMT : records[i].CHECK_AMT
				,TICKET_AMT : records[i].TICKET_AMT
				,CASH_AMT : records[i].CASH_AMT
			}
			reqList.push(map);
		}		
	}
	,doQuery : function(){
		valid1.reset();
		if (!$F('LOAN_ID') && !$F('BORROW_ID')) {
			alert('請輸入貸款帳號或借款人ID查詢');
			return;
		}
		if ($F('LOAN_ID')&&!valid1.validate()) {
			return;
		}
		if($F('BORROW_ID')&&!valid2.validate()){
			return;
		}
		ajaxPost( 'query', {LOAN_ID : $F('LOAN_ID'),BORROW_ID: $F('BORROW_ID')}
					,function(resp){
						grid.load(resp.dataList);
					},function(resp){
						grid.load([])
					}
				);
	}
	,doPrint : function(){
		if(grid.getCheckedRecord().length==0){
			alert("請先點選一筆預繳明細資料才能列印");
			return;
		}
		
		RPTUtil.executePrintByLink('print' , {reqList: Object.toJSON(reqList)}, true );
	}
}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC32700', '繳款方式', '預繳明細列印');
								grid = new TableUI(
				{table: $("grid"), pageSize : 10, allSortable: false, overDiv:true,			
				autoCheckBox:{
							text:'選取', 
							type:'radio',
							action:buttons.doshow,
							isSelectAll:false
							
				},
				column:[			
					{header:"貸款帳號", key:"LOAN_ID",groupKey:["LOAN_ID"] },
					{header:"借款人ID",key:"BORROW_ID"},
					{header:"借款人姓名",key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"}}, <%-- [20241104] 難字調整: 借款人姓名 --%>
					{header:"付款行庫",key:"BANK_CODE"},
					{header:"票據號碼",key:"CHECK_NO"},
					{header:"開票人帳號",key:"CHECK_ACCNO"},
					{header:"票據日期",key:"CHECK_DATE",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					},
					{header:"票據金額",key:"CHECK_AMT", attrs:{align:"right"},
						render : function(rec ,val ){
								return MoneyFormat(val) || '';
							}
					},
					{header:"繳票金額",key:"TICKET_AMT", attrs:{align:"right"},
						render : function(rec ,val ){
								return MoneyFormat(val) || '';
							}
					},
					{header:"繳現金額",key:"CASH_AMT", attrs:{align:"right"},
						render : function(rec ,val ){
								return MoneyFormat(val) || '';
							}
					}
					
				]
				});
				initValidation();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('BTN_PRINT').observe('click',buttons.doPrint);
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
			<td class="tbYellow" width="15%">貸款帳號</td>
			<td class="tbYellow2" width="15%">
				<input id="LOAN_ID" type="text" class="textBox2" maxlength="10" onblur="this.value = this.value.toUpperCase()"/>
			</td>
			<td class="tbYellow2" rowspan='2'>
			<input id="BTN_QUERY" type="button" value="查詢" class="button">
			<input id="BTN_PRINT" type="button" value="列印預繳明細" class="button"> 			
		</tr>
		<tr>
			<td class="tbYellow" width="15%">借款人ID</td>
			<td class="tbYellow2" width="15%">
			<input id="BORROW_ID" type="text" class="textBox2" maxlength="10" onblur="this.value = this.value.toUpperCase()"/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow0" width="15%" align='left' colspan='4'><B>預繳明細清單</td>
		</tr>
	</table>
	
	<table id = "grid" ></table>
</form>
</body>
</html>