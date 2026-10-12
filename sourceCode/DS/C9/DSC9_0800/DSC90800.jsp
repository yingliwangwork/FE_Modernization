<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC90800.jsp
作者：楊鈞傑
功能：理財型屆期未處理作業
完成：2013/04/15

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
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>

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

// 產生畫面物件
var DSC90800 = new DSC90800();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, "load", DSC90800.initApp);
Event.observe(window, "resize", fix);
Event.observe(window, "scroll", fix);

function DSC90800(){

	var grid;
	var reqMap;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC9_0800/" + actionName,
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
	
	//儲存畫面
	function storeMap(){
		var reqMap={
			CRED_DEPT:$('CRED_DEPT').value,
			END_DATE:$('END_DATE').value,
			SORT_KEY: $F('SORT_KEY')
		};
		return reqMap;
	}
	
	//數字欄位格式
	function formatValue(val){
		return (val || val === 0) ? CSRUtil.$fmt(val,'#,##0.##########'):'';
	}
	
	var buttons = {
		//查詢
		doQuery:function(event){
			reqMap = storeMap();
			ajaxPost("query",{reqMap:Object.toJSON(reqMap)},
				function(resp){
					grid.load(resp.rtnList||[]);
				},
				function(resp){
					grid.load([]);
				}
			);
		}
		// 匯出
		,doExport : function () {
					
			if(!reqMap){
				alert('請先查詢再匯出!');
				return;	
			}

			//現行異常案件報表_畫面上的報表種類(中文)_日期
			$('gridJSON').value = grid.getXlsSettingJSON('理財型屆期未處理資料');
											
			var dataMap = storeMap();
			dataMap['gridJSON'] = $('gridJSON').value;

			var params = { reqMap : Object.toJSON(dataMap)};
			
			RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSC9_0800/export', params); 
		}
		
	};
	
	return {
		initApp : function() {			
			PageUI.createPageWithAllBodySubElement(
				"DSC90800",
				"理財型房貸",
				"理財型屆期未處理作業"
			);
			
			grid = new TableUI({
				table:$('grid'),pageSize:20,allSortable:false,
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
							return rec.ROW_TYPE=='1' ? val:rec.LOAN_STATUS_NM;
						}
					},
					{header:"原貸帳號", key:'REFER_ID',groupKey:["REFER_ID"]},
					<%-- [20230324] 難字調整 --%>
					{header:"借款人姓名", key:'BORROW_NAME',attrs:{style:"font-family:'EUDC'"}},
					
					{header:"擔借款總餘額", key:'REMAIN_AMT',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? formatValue(val):'';
						}
					},
					{header:"理財型額度", key:'MM_AMT',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? formatValue(val):'';
						}
					},
					{header:"動用金額", key:'C104_REMAIN_AMT',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? formatValue(val):'';
						}
					},
					{header:"本金餘額", key:'TYPE_NM',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val : formatValue(rec.C100_REMAIN_AMT);
						}
					},
					{header:"到期日", key:'END_DATE',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? Date.toROC(val||'') : Date.toROC(rec.C100_END_DATE||'');
						}
					},
					<%-- [20230324] 難字調整 --%>
					{header:"處理人員", key:'ASSIGN_NAME',attrs:{style:"font-family:'EUDC'"},
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					},
					<%-- [20230324] 難字調整 --%>
					{header:"經手人/收展員", key:'AGENT_NAME',attrs:{style:"font-family:'EUDC'"},
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					},
					{header:"到期通知書列印日期", key:'EXP_PRINT_DATE',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? Date.toROC(val||'') : '';
						}
					},
					{header:"換約申請書列印日期", key:'CHG_PRINT_DATE',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? Date.toROC(val||'') : '';
						}
					}
				]
			});
			
			$("btn_query").observe('click', buttons.doQuery);
			           
            $('btn_export').observe('click', buttons.doExport);
			
			PageUI.resize();
			displayMessage();
		}
	};	
};

</script>
</head>
<body>		
<form id="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<input type="hidden" id="gridJSON" value="">
		<td class="tbYellow">承辦科別</td>
		<td class="tbYellow2">
			<select id="CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach var="map" items="${CRED_DEPT_LIST}" >
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">到期月份</td>
		<td class="tbYellow2">
			<select id="END_DATE" class="textBox2">
				<c:forEach var="map" items="${END_DATE_LIST}" >
					<option value = "${map.END_DATE}" > ${map.END_DATE}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">
			排序方式
		</td>
		<td class="tbYellow2">
			<select id="SORT_KEY" class="textBox2">
				<c:forEach items="${SORT_KEY_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td align="center" class="tbYellow2" width="10%">
			<input id="btn_query" type="button" class="button" value="查詢"/>
			<input id="btn_export" type="button" class="button" value="匯出"/>
		</td>
	</tr>
</table>
</form>
<table id="grid" width="100%"></table>	
</body>
</html>