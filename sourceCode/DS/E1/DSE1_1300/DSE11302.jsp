<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<!--

程式功能:放款資產及減損評估作業_5分類調整
程式名稱:DSE1_1302
作者:邱建禕
完成:2020年10月7日

-->
<!DOCTYPE html>
<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<!--匯入外部Javascript 與 css-->
<meta charset="BIG5">
<title>資減作業五分類調整</title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/javascript" src='${htmlBase}/CM/js/date.js'></script><!--判斷isRocDate用-->
<script type="text/javascript" src='${htmlBase}/CM/js/calendar.js'></script>
<script type="text/JavaScript" src='${htmlBase}/CM/js/RPTUtil.js'></script>      <%-- 報表列印 --%>
<script type="text/javascript">
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSE11302().initApp);

function DSE11302(){
	<%-- TablE UI物件 --%>
	var grid;		
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSE1_1302/');
	var rtnList = <c:out value="${rtnList}" default="[]" escapeXml="false" />;
	var FUNC_ID = 'DSE11302';
	<%-- 驗證物件 --%>
	var valid;
	var size = 15;
	
	<%-- buttons 方法  --%>
	var buttons = {
		<%-- 新增一列 --%>
		doAdd : function(){
			grid.addRecords({serialNum: ++size});
		},
		// 清除所有資料
		doClear: function() {
			
			<%-- 恢復原頁面狀態，清空所有欄位資料--%>
			size = 15;
			grid.load(rtnList);
		},
		<%-- 覆核 --%>
		doConfirm : function(){
			ajaxRequest.post('confirm', {reqMap: Object.toJSON({LOAN_YYMM: $F('LOAN_YYMM')})},
			        function(resp) {
			            
						var isManager = resp.isManager;
						if(!isManager) {
							
							alert('需單位主管才可進行覆核');
						}
			        }
			    );
		},
		<%-- 取消覆核 --%>
		doCancel : function(){
			ajaxRequest.post('cancel', {reqMap: Object.toJSON({LOAN_YYMM: $F('LOAN_YYMM')})},
			        function(resp) {
			            
						var isManager = resp.isManager;
						if(!isManager) {
							
							alert('需單位主管才可進行取消覆核');
						}
			        }
			    );
		},
		<%-- 調整資料寫入 --%>
		doUpdate : function(){
			var datalist = [];
			var all_records = grid.getAllRecords();
			for(var i=0;i<all_records.length;i++) {
				var record = all_records[i];
				var loan_id = record.LOAN_ID; 
				if(!loan_id || Validation.get('IsEmpty').test(loan_id)) {//針對有輸入欄位進行資料更新
					continue;
				}
				datalist.push(record);
			}
			
			ajaxRequest.post('update', {reqMap: Object.toJSON({LOAN_YYMM: $F('LOAN_YYMM')}),
				dataList: Object.toJSON(datalist)},
		        function(resp) {
		            
					var isCHK = resp.isCHK;
					if(isCHK) {
						alert('取消覆核後，才可調整資料修正');
					}
		        }
		    );
		},
		<%-- 匯出明細 --%>
		doExport : function(){
			var param = {reqMap: Object.toJSON({LOAN_YYMM: $F('LOAN_YYMM')})};
			
			ajaxRequest.post('checkCHK', param,
		        function(resp) {
		            
					var isCHK = resp.isCHK;
					if(!isCHK) {
						
						alert('覆核後，才可匯出明細');
					} else {
						
						<%-- 下載明細檔案 --%>
						RPTUtil.downloadFile('${dispatcher}/DSE1_1302/export', param, false);		
					}
		        }
		    );
		}
	};

	return {
		
		initApp : function() {
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' />
			PageUI.createPageWithAllBodySubElement(
				'DSE11302',
				'法務作業',
				'資減作業五分類調整'
			);
			
		grid = new TableUI({
				
				table: $('grid'),
				pageSize: 0,
				column: [
					{header: '序號', key: 'serialNum'},
					{header: '帳號', key: 'LOAN_ID',
						input:{
                        	type: 'TEXT', size: 15 , maxlength: 11 //字串11碼
						}
					},
					{header: '逾期種類', key: 'DELAY_TYPE',
						input:{
                        	type: 'TEXT', size: 5 , maxlength: 11 //VARCHAR (1)
						}
					},
					{header: '擔保品價格', key: 'GUARANTEE',
						input:{
                        	type: 'NUMBER', pattern :"###,###" , size: 15 , maxlength: 14 //數字11碼，無小數點
						}
					},
					{header: '足額五分類種類', key: 'SORT5_KIND_INFULL',
						input:{
                        	type: 'TEXT', size: 5 , maxlength: 1 //VARCHAR (1)
						}
					},
					{header: '足額EIR金額', key: 'SORT5_EIR_AMT_INFULL',
						input:{
                        	type: 'NUMBER', pattern :"###,###" , size: 15 , maxlength: 14 //數字11碼，無小數點
						}
					},
					{header: '不足額五分類種類', key: 'SORT5_KIND_OUTFULL',
						input:{
                        	type: 'TEXT', size: 5 , maxlength: 1 //VARCHAR (1)
						}
					},
					{header: '不足額EIR金額', key: 'SORT5_EIR_AMT_OUTFULL',
						input:{
                        	type: 'NUMBER', pattern :"###,###" , size: 15 , maxlength: 14 //數字11碼，無小數點
						}
					},
					{header: '<button type="button" class="button" id="btnClear">清除所有資料</button>', key: '',
						input:{ type: 'button', text: '刪除', className: 'button',
							action: function( node , dataObj , textDiv, orgData ) {
								grid.deleteRecords(dataObj);
							}
                		}	
					}
				]
			});
			
			
			
			<%--註冊事件--%>
			$('btnAdd').observe('click', buttons.doAdd);
			$('btnClear').observe('click', buttons.doClear);
			$('btnConfirm').observe('click', buttons.doConfirm);
			$('btnCancel').observe('click', buttons.doCancel);
			$('btnUpdate').observe('click', buttons.doUpdate);
			$('btnExport').observe('click', buttons.doExport);
			
			grid.load(rtnList);	
			displayMessage();		
		}	
	};	
}


</script>

<style type="text/css">
	
</style>

</head>
<body>

<form name='form1' id='form1'>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">子系統代號</td>
		<td class="tbYellow2" width="10%">DS</td>
		<td class="tbYellow" width="16%">五分類資料調整</td>
		<td class="tbYellow2" width="16%"></td>
		<td class="tbYellow" width="16%">資料年月</td>
		<td class="tbYellow2" width="16%">
			<input type="text" id="LOAN_YYMM" class="textBox2" maxlength="6" value="${LOAN_YYMM}" />
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td width="10%" class="tbBlue" style="text-align: center;">
			<button type="button" class="button" id="btnAdd">新增一列</button>
		</td>
		<td class="tbBlue" colspan="3" style="text-align: center;">
			<span>個案調整</span>
		</td>
	</tr>
</table>
<table id="grid" class="grid"></table>
<div style="text-align: center;">
	<button type="button" id="btnConfirm" class="button">覆核</button>
	<button type="button" id="btnCancel" class="button">取消覆核</button>
	<button type="button" id="btnUpdate" class="button">調整資料寫入</button>
	<button type="button" id="btnExport" class="button">匯出明細</button>
</div>
</form>
</body>
</html>