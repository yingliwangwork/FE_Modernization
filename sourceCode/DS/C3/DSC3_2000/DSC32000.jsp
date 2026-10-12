<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC32000.jsp
功能：沖暫收款退現
作者：溫子?
完成：2013/06/

[20200731] 
1.	備註新增文字
2.	查詢清單新增印花稅金額、退現金額、沖帳組別
3.	新增可取消沖暫收查詢明細
4.	新增取消功能

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
<script type='text/javascript'>
Event.observe(window, 'load', new DSC32000().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC32000(){
var grid;
var grid2;
var BALC_NOstr;
var queryLOAN_ID;
//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_2000/" + actionName,
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
function initValidation(){	
		Validation.addAllThese([
			['validLOAN_ID', '退現帳號格式有誤', function(v , node) { 
				if(v){
					//return v.length == 10 &&  2014-11-24因C140的LOAN_ID可能為貸款帳號、受理編號或單位代號，不需檢核長度等於10，僅檢核只能輸入英數字
					return (/^[a-zA-Z0-9]+$/.test(v)); 
				}
				return true;
			}]
		]);
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define('required' , [{ id : "LOAN_ID" , errMsg:"請輸入退現帳號"}] );
		valid1.define('validLOAN_ID' , [{ id : "LOAN_ID" , errMsg:"退現帳號格式有誤"}] );
		}
var buttons = {
	
	doQuery : function(){
		$('BTN_PRINT').disable();
		if(!valid1.validate()){
			return;
		}
		queryLOAN_ID=$F('LOAN_ID');
		var qryMap={
			LOAN_ID : queryLOAN_ID
		};
		ajaxPost( 'query', {qryMap : Object.toJSON(qryMap)}
					,function(resp){
						grid.load(resp.dataList||[]);
						grid2.load(resp.dataList2||[]);
					},function(resp){
						grid.load([]);
						grid2.load([]);
					}
				);
		
	}
	,doConfirm : function(){
		var checkedRecord = grid.getCheckedRecord();
			if(checkedRecord.length==0){
				alert("請選取一筆資料");
				return;
			};
		ajaxPost( 'confirm', {selectList : Object.toJSON(checkedRecord)}
					,function(resp){
						if(resp.isprint){
							$('BTN_PRINT').enable();
							BALC_NOstr=resp.BALC_NOstr;
						}
					},function(resp){
							$('BTN_PRINT').disable();
						});
	}
	,doPrint : function (){
		var qryMap={
			LOAN_ID : queryLOAN_ID,
			BALC_NOstr : BALC_NOstr
		};
		RPTUtil.executePrintByLink('print' , {qryMap: Object.toJSON(qryMap)}, true );
	}
	<%--[20200731] 4.	新增取消功能--%>
	,doCancel : function (){
		var checkedRecord = grid2.getCheckedRecord();
		if(checkedRecord.length==0){
			alert("請選取一筆資料");
			return;
		}
		queryLOAN_ID=$F('LOAN_ID');
		var qryMap={
			LOAN_ID : queryLOAN_ID
		};
		ajaxPost( 'cancel', {selectList : Object.toJSON(checkedRecord), qryMap : Object.toJSON(qryMap)}
					,function(resp){
						grid.load(resp.dataList||[]);
						grid2.load(resp.dataList2||[]);
					});
	}
}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC32000', '繳款方式', '沖暫收款退現');
				grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true,			
					autoCheckBox:{
							text:'選取', 
							type:'checkbox',
							isSelectAll:true 
				},
				column:[			
					{header:"暫收款編號", key:"BALC_NO"},
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"暫收實繳日",key:"REAL_PAYDT",
						render : function(rec ,val ){
							if(rec.BALC_REASON=='09'){
								return Date.toROC(rec.REAL_PAYDT)||'';
							}else{
								return Date.toROC(rec.INPUT_DATE)||'';
							}
						}
					},
					{header:"票據狀態中文",key:"CHECK_CSTATUS"},
					{header:"暫收款金額",key:"REMAIN_AMT",sortRule:"number"},
					<%--[20200731] 2.	查詢清單新增印花稅金額、退現金額、沖帳組別--%>
					{header:"印花稅金額",key:"TAX",sortRule:"number"},
					{header:"退現金額",key:"CASH_BACK_AMT",sortRule:"number"},
					{header:"沖帳組別",key:"AUTHED_GROUP_NM"}
				]
				});
			<%--[20200731] 3.	新增可取消沖暫收查詢明細--%>
			grid2 = new TableUI(
				{table: $("grid2"), pageSize : 20, allSortable: false, overDiv:true,			
					autoCheckBox:{
							text:'選取', 
							type:'checkbox',
							isSelectAll:true 
				},
				column:[			
					{header:"暫收款編號", key:"BALC_NO"},
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"暫收實繳日",key:"REAL_PAYDT",
						render : function(rec ,val ){
							if(rec.BALC_REASON=='09'){
								return Date.toROC(rec.REAL_PAYDT)||'';
							}else{
								return Date.toROC(rec.INPUT_DATE)||'';
							}
						}
					},
					{header:"票據狀態中文",key:"CHECK_CSTATUS"},
					{header:"暫收款金額",key:"REMAIN_AMT",sortRule:"number"},
					{header:"印花稅金額",key:"TAX",sortRule:"number"},
					{header:"退現金額",key:"CASH_BACK_AMT",sortRule:"number"},
					{header:"沖帳組別",key:"AUTHED_GROUP_NM"}
				]
				});
				
				$('BTN_PRINT').disable();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('BTN_CONFIRM').observe('click',buttons.doConfirm);
				$('BTN_PRINT').observe('click',buttons.doPrint);
				$('BTN_CANCEL').observe('click',buttons.doCancel);
				initValidation();
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
			<td class="tbYellow" width="5%">人工應暫收─退現帳號</td>
			<td class="tbYellow2" width="4%">
				<input id="LOAN_ID" type="text" class="textBox2" maxlength="11" onblur="this.value = this.value.toUpperCase()"  />
			</td>
			<td class="tbYellow2" width="8%">
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
			</td>
		</tr>
		<tr>
			<td class="tbYellow0" colspan='3'>
				<font color="black" size='3'><b>暫應收款資料</b></font>
				<br><font color="red">*退還金額超過5000以上，需影印借款人身份證，連同放款簽收單寄回總公司放款部*</font>
				<br><font color="red">*暫收編號前二碼為CB表暫收，為DB表應收─暫收退現，應收沖帳*</font>
				<%--[20200731] 1.	備註新增文字--%>
				<br><font color="red">*借款人退現金，系統自動以保戶服務專款支付，須扣印花稅千分之四*</font>
			</td>
		</tr>
	</table>
	<table id = "grid" ></table>
	<tr>
		<td class="tbYellow2" align="left">
			<input id="BTN_CONFIRM" type="button" value="確認" class="button" align="center" > 
			<input id="BTN_PRINT" type="button" value="列印簽收條" class="button" align="center" > 
		</td>
	</tr>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow0" colspan='3'>
				<font color="black" size='3'><b>可取消暫應收款資料明細</b></font>
			</td>
		</tr>
	</table>
	<table id = "grid2" ></table>
	<tr>
		<td class="tbYellow2" align="left">
			<input id="BTN_CANCEL" type="button" value="取消" class="button" align="center" > 
		</td>
	</tr>
</form>
</body>
</html>