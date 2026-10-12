<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC90500.jsp
作者：楊鈞傑
功能：理財型展期報表呈核作業
完成：2013/05/06

[20230324]
難字調整
高強禾
-->

<html> 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/javascript" src="<%=htmlBase%>/CM/js/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>		<%-- 匯出PDF用--%>

<%-- [20230324] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>

<script type="text/javascript">

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, "load", new DSC90500().initApp);
Event.observe(window, "resize", fix);
Event.observe(window, "scroll", fix);

function DSC90500(){

	var grid;
	var Q_CRED_DEPT;
	var Q_END_DATE;
	var Q_PROC_STATUS;
	var Q_SORT_KEY;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC9_0500/" + actionName,
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
	
	//數字欄位格式
	function formatValue(val){
		return (val || val === 0) ? CSRUtil.$fmt(val,'#,##0.##########'):'';
	}
	
	var buttons = {
		//查詢
		doQuery:function(event){
			
			var reqMap={
				CRED_DEPT:$('CRED_DEPT').value,
				END_DATE:$('END_DATE').value,
				PROC_STATUS:$('PROC_STATUS').value,
				SORT_KEY: $F('SORT_KEY')
			};
			
			ajaxPost("query",{reqMap:Object.toJSON(reqMap)},
				function(resp){
					Q_CRED_DEPT = $('CRED_DEPT').value;
					Q_END_DATE = $('END_DATE').value;
					Q_PROC_STATUS = $('PROC_STATUS').value;
					Q_SORT_KEY = $('SORT_KEY').value;
					grid.load(resp.rtnList||[]);
				},
				function(resp){
					grid.load([]);
				}
			);
		},

		//列印
		doPrint : function(){
			
			var allRec = grid.getAllRecords();
			
			if(allRec.length == 0){			
				alert("請先查詢，再執行列印作業");
				return ;
			}
			
			//當承辦科別為'全部'時，不得列印
			if(Q_CRED_DEPT == ''){			
				alert("請先以承辦科別為條件查詢，再執行列印作業");
				return ;
			}

			var reqMap={
				CRED_DEPT: Q_CRED_DEPT,
				END_DATE: Q_END_DATE,
				PROC_STATUS: Q_PROC_STATUS,
				SORT_KEY: Q_SORT_KEY
			};
			
			ajaxPost("print",{reqMap:Object.toJSON(reqMap)},
				function(resp){
					RPTUtil.executePrintByLink ( "<%=dispatcher%>/DSC9_0510/prompt" , { CRED_DEPT: Q_CRED_DEPT, END_DATE: Q_END_DATE, PROC_STATUS: Q_PROC_STATUS, SORT_KEY: Q_SORT_KEY}, true );
				}
			);
		}
	};
	
	return {
		initApp : function() {			
			PageUI.createPageWithAllBodySubElement(
				"DSC90500",
				"覆審作業",
				"理財型展期報表呈核作業"
			);
			
			grid = new TableUI({
				table:$('grid'), allSortable:false, pageSize:20,
				<%-- [20230324] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{header:"貸款帳號", key:'LOAN_ID',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val: rec.C100_LOAN_ID;
						}
					},
					{header:"使用狀態/契約狀況", key:'MM_STATUS_NM',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val: (rec.LOAN_STATUS_NM || '');
						}
					},
					{header:"原貸帳號",key:"REFER_ID",groupKey:["REFER_ID"]},
					<%-- [20230324] 難字調整 --%>
					{header:"借款人姓名", key:'BORROW_NAME',attrs:{style:"font-family:'EUDC'"}},
					{header:"擔借款總餘額", key:'REMAIN_AMT',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? formatValue(val):'';
						}
					},
					{header:"放款值", key:'LIMIT_AMT',
						render:function(rec,val){
							return formatValue(val);
						}
					},
					{header:"理財型額度", key:'MM_AMT',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? formatValue(val):'';
						}
					},
					{header:"動用金額/本金餘額", key:'C104_REMAIN_AMT',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? formatValue(val): formatValue(rec.C100_REMAIN_AMT);
						} 
					},
					<%-- [20230324] 難字調整 --%>
					{header:"徵信人員", key:'ASSIGN_NAME2',attrs:{style:"font-family:'EUDC'"},
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					},
					<%-- [20230324] 難字調整 --%>
					{header:"覆核人員", key:'CONFIRM_NAME',attrs:{style:"font-family:'EUDC'"},
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					},
					<%-- [20230324] 難字調整 --%>
					{header:"覆核主管", key:'FINAL_NAME',attrs:{style:"font-family:'EUDC'"},
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					},
					{header:"繳息情況", key:'IS_PAY_NM',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					},
					{header:"聯徵記錄", key:'IS_EJCIC_NM',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					},
					{header:"是否展期", key:'IS_EXTEND_NM',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					},
					{header:"說明", key:'EXTEND_NOTE',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					},
					{header:"處理進度",key:"PROC_STATUS_NM",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return val;
							}else{
							    return "";
							}   							
						}
					}
				]
			});
			
			//查詢
			$("btn_query").observe('click', buttons.doQuery);
			
			//列印
			$("btn_print").observe('click', buttons.doPrint);
			
			PageUI.resize();
			displayMessage();
		}
	};	
};

</script>
</head>
<body>		
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbYellow" width="15%">承辦科別</td>
		<td class="tbYellow2" width="30%">
			<select id="CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach var="map" items="${CRED_DEPT_LIST}" >
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width="15%">到期月份</td>
		<td class="tbYellow2" width="30%">
			<select id="END_DATE" class="textBox2">
				<c:forEach var="map" items="${END_DATE_LIST}" >
					<option value = "${map.END_DATE}" > ${map.END_DATE}</option>
				</c:forEach>
			</select>
		</td>
		<td align="center" class="tbYellow2" width="20%" rowspan="2">
			<input id="btn_query" type="button" class="button" value="查詢"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">處理進度</td>
		<td class="tbYellow2" width="30%">
			<select id="PROC_STATUS" class="textBox2">
				<c:forEach var="map" items="${PROC_STATUS_LIST}" >
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow'>
			排序方式
		</td>
		<td class='tbYellow2'>
			<select id="SORT_KEY" class="textBox2">
				<c:forEach items="${SORT_KEY_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td colspan="5" align="center" >
			<input id="btn_print" type="button" class="button" value="列印" /> 
		</td>
	</tr>

</table>
</form>
<table id="grid" width="100%"></table>	
</body>
</html>