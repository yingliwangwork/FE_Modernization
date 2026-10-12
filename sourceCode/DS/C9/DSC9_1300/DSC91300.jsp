<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC91300.jsp
作者：柯玉芳
功能：資金流向追蹤總表作業
完成：2016/02/04

[20230325]難字修改
-->

<html> 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<title></title>
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">

<script type="text/javascript" src="${htmlBase}/CM/js/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>		<%-- 匯出PDF用--%>
<style type="text/css"><%-- [20230325]難字修改 --%>
	@font-face{
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
        url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		font-weight:normal;
		font-style:normal
	}	
</style>
<script type="text/javascript">

// 產生畫面物件
var DSC91300 = new DSC91300();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, "load", DSC91300.initApp);
Event.observe(window, "resize", fix);
Event.observe(window, "scroll", fix);

function DSC91300(){

	var grid;
	var qMap;	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC9_1300/');
	
	var action = {
		//儲存畫面
		storeMap :function(){
			return{
				CRED_DEPT: $F('CRED_DEPT'),
				CHECK_YYMM: $F('CHECK_YYMM'),
				PROC_STATUS: $F('PROC_STATUS'),
				BANK_KIND: $F('BANK_KIND')
		    }
		}
	}	
	
	var buttons = {
		//查詢
		doQuery:function(event){
			qMap = action.storeMap();
			ajaxRequest.post( 'query' , { reqMap : Object.toJSON(qMap)},
				function(resp){
					grid.load(resp.rtnList||[]);
				},function(resp){  // 查詢失敗清除先前的查詢資料		
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
			if($F('CRED_DEPT') == ''){			
				alert("請先以承辦科別為條件查詢，再執行列印作業");
				return ;
			}
			
			for(var key in qMap){
				if(qMap[key] != $F(key)){
					alert("條件與原查詢條件不符，請重新查詢後再執行列印作業。");
					return;
				}
			}
			
			ajaxRequest.post( 'print' , {reqMap:Object.toJSON(qMap)},
				function(resp){
					RPTUtil.executePrintByLink ( "<%=dispatcher%>/DSC9_1310/prompt" , { CRED_DEPT: $F('CRED_DEPT'), CHECK_YYMM: $F('CHECK_YYMM'), PROC_STATUS: $F('PROC_STATUS'), BANK_KIND: $F('BANK_KIND')}, true );
				}
			);
		}
	};
	
	return {
		initApp : function() {			
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay" />
			PageUI.createPageWithAllBodySubElement( "DSC91300" , "覆審作業", "資金流向追蹤總表作業" );
			
			grid = new TableUI({
				table: $("grid"), pageSize: 20, allSortable:true, overDiv:false,	
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }<%-- [20230325]難字修改 --%>
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }<%-- [20230325]難字修改 --%>
				},
				column:[	
				    {header:"各科序號",key:"SEQ_NO"},				
					{header:"受理編號",key:"APPLY_ID"},
                    {header:"借款人姓名",key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"} },	<%-- [20230325]難字修改 --%>
					{header:"借款人ID",key:"BORROW_ID"},	
					{header:"是否為高價",key:"REMARK"},							
					{header:"查核人員",key:"CRED_NAME", attrs:{style:"font-family:'EUDC'"} },	<%-- [20230325]難字修改 --%>
					{header:"查核結果",key:"IS_NORMAL_NM"},
					{header:"說明",key:"CHECK_NOTE", attrs:{style:"font-family:'EUDC'"} }	<%-- [20230325]難字修改 --%>
				]
			});
			
			//查詢
			$("btn_query").observe('click', buttons.doQuery);
			
			//列印
			$("btn_print").observe('click', buttons.doPrint);
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			PageUI.resize();
			displayMessage();
		}
	};	
};

</script>
</head>
<body>		
<form id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbYellow" width="10%">承辦科別</td>
		<td class="tbYellow2" width="10%">
			<select id="CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach var="map" items="${CRED_DEPT_LIST}" >
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width="10%">查核月份</td>
		<td class="tbYellow2" width="10%">
			<select id="CHECK_YYMM" class="textBox2">
				<c:forEach var="map" items="${CHECK_YYMM_LIST}" >
					<option value = "${map.CHECK_YYMM}" > ${map.CHECK_YYMM}</option>
				</c:forEach>
			</select>
		</td>
		<td align="center" class="tbYellow2" width="10%" rowspan="2">
			<input id="btn_query" type="button" class="button" value="查詢"/>
		</td>
	</tr>
	
	<tr>
		<td class="tbYellow">
			處理進度
		</td>
		<td class="tbYellow2">
			<select id="PROC_STATUS" class="textBox2">
				<c:forEach var="map" items="${PROC_STATUS_LIST}">							
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">
			銀行別
		</td>
		<td class="tbYellow2">
			<select id="BANK_KIND" class="textBox2">
				<option value="">全部</option>
				<c:forEach var="map" items="${BANK_KIND_LIST}">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td align="center" colspan="5">
			<input id="btn_print" type="button" class="button" value="列印"/>
		</td>
	</tr>	
</table>
<table id='grid' width='100%'></table>
</form>
</body>
</html>