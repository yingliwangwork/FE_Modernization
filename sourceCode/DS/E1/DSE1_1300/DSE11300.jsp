<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!--
程式：DSE11300.jsp
功能：放款資產及減損評估作業
作者：楊青峰
完成：2020-07-13

[20200728]問題單 楊青峰
1. 請針對有輸入欄位進行資料更新，無輸入空白欄位不進行檢核及更新
--> 

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>

<script type="text/javascript">
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSE11300().initApp);

function DSE11300() {
	
	var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSE1_1300/');
	var rtnList = <c:out value="${rtnList}" default="[]" escapeXml="false" />;
	var size = 15;
	
	var buttons = {
			
		// 新增
		doAdd: function() {
			
			grid.addRecords({serialNum: ++size});
		},
		
		// 清除所有資料
		doClear: function() {
			
			<%-- 恢復原頁面狀態，清空所有欄位資料--%>
			size = 15;
			grid.load(rtnList);
		},
		
		<%-- 調整資料寫入按鈕 --%>
		doUpdate: function() {
			
			<%--
				[20200728]問題單  請針對有輸入欄位進行資料更新，無輸入空白欄位不進行檢核及更新
			--%>
			var datalist = [];
			var all_records = grid.getAllRecords();
			for(var i=0;i<all_records.length;i++) {
				
				var record = all_records[i];
				var loan_id = record.LOAN_ID;
				if(!loan_id || Validation.get('IsEmpty').test(loan_id)) {
					continue;
				}
				
				var eir_remain_amt_a = record.EIR_REMAIN_AMT_A;
				if(!eir_remain_amt_a || Validation.get('IsEmpty').test(eir_remain_amt_a)) {
					continue;
				}
				
				datalist.push(record);
			}
			
			ajaxRequest.post('update', {reqMap: Object.toJSON({LOAN_YYMM: $F('LOAN_YYMM')}),
				dataList: Object.toJSON(datalist)},
		        function(resp) {
		            
					var isCHG = resp.isCHG;
					if(isCHG) {
						
						alert('取消覆核後，才可調整資料修正');
					}
		        }
		    );
		},
		
		<%-- 覆核按鈕 --%>
		doConfirm: function() {
			
			ajaxRequest.post('confirm', {reqMap: Object.toJSON({LOAN_YYMM: $F('LOAN_YYMM')})},
		        function(resp) {
		            
					var isManager = resp.isManager;
					if(!isManager) {
						
						alert('需單位主管才可進行覆核');
					}
		        }
		    );
		},
		
		<%-- 取消覆核按鈕 --%>
		doCancel: function() {
			
			ajaxRequest.post('cancel', {reqMap: Object.toJSON({LOAN_YYMM: $F('LOAN_YYMM')})},
		        function(resp) {
		            
					var isManager = resp.isManager;
					if(!isManager) {
						
						alert('需單位主管才可進行取消覆核');
					}
		        }
		    );
		},
		
		<%-- 匯出明細按鈕 --%>
		doExport: function() {
			
			var param = {reqMap: Object.toJSON({LOAN_YYMM: $F('LOAN_YYMM')})};
			
			ajaxRequest.post('checkCHG', param,
		        function(resp) {
		            
					var isCHG = resp.isCHG;
					if(!isCHG) {
						
						alert('覆核後，才可匯出明細');
					} else {
						
						<%-- 下載明細檔案 --%>
						RPTUtil.downloadFile('${dispatcher}/DSE1_1300/export', param, false);						
					}
		        }
		    );
		}
	};

	return{
		initApp : function() {
			
			PageUI.createPageWithAllBodySubElement('DSE11300', '法務作業', '放款資產及減損評估作業');
			
			grid = new TableUI({
				
				table: $('grid'),
				pageSize: 0,
				column: [
					{header: '序號', key: 'serialNum'},
					{header: '帳號', key: 'LOAN_ID',
						input:{
                        	type: 'TEXT', size: 15 , maxlength: 11
						}
					},
					{header: '替換EIR餘額', key: 'EIR_REMAIN_AMT_A', 
						input:{
                        	type: 'NUMBER', size: 15 , maxlength: 11
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
			
			$('btnAdd').observe('click', buttons.doAdd); <%-- 新增一列按鈕 --%>
			$('btnClear').observe('click', buttons.doClear); <%-- 清除所有資料按鈕 --%>
			$('btnUpdate').observe('click', buttons.doUpdate); <%-- 調整資料寫入按鈕 --%>
			$('btnConfirm').observe('click', buttons.doConfirm); <%-- 覆核按鈕 --%>
			$('btnCancel').observe('click', buttons.doCancel); <%-- 取消覆核按鈕 --%>
			$('btnExport').observe('click', buttons.doExport); <%-- 匯出明細按鈕 --%>
			
			grid.load(rtnList);
			
			displayMessage();
		}
	}
}
</script>
</head>

<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">子系統代號</td>
			<td class="tbYellow2" width="10%">DS</td>
			<td class="tbYellow" width="16%">欄位名稱</td>
			<td class="tbYellow2" width="16%">EIR_REMAIN_AMT</td>
			<td class="tbYellow" width="16%">資料年月</td>
			<td class="tbYellow2" width="16%">
				<input type="text" id="LOAN_YYMM" class="textBox2" maxlength="12" value="${LOAN_YYMM}" />
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
	<table id="grid"></table>
	<div style="text-align: center;">
		<button type="button" id="btnConfirm" class="button">覆核</button>
		<button type="button" id="btnCancel" class="button">取消覆核</button>
		<button type="button" id="btnUpdate" class="button">調整資料寫入</button>
		<button type="button" id="btnExport" class="button">匯出明細</button>
	</div>
</form>	
</body>
</html>