<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC91100.jsp
作者：林楷傑
功能：資金流向查核派件作業
完成：2016/01/26

[20230325]難字修改
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/LocaleDisplay.js"></script>
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
var DSC91100 = new DSC91100();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, "load", DSC91100.initApp);
Event.observe(window, "resize", fix);
Event.observe(window, "scroll", fix);

function DSC91100(){

	var grid;
	var reqMap;
	
	function buttonAuth() {
		var authButtons = { 
			B0067 : 'BTN_SEND'    <%--派件--%>
		};	
	}
	
	//檢核欄位
	function initValidation(){
		valid1 = new Validation("form", { focusOnError:true, immediate:false});				
		valid1.define('required' , [{ id : "CRED_ID2" , errMsg:'請先選取查核人員，才能作業！'}] );
	}
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC9_1100/');
	
	var action = {
		//儲存畫面
		storeMap :function(){
			return{
				CRED_DEPT:$F('CRED_DEPT'),
				CHECK_YYMM:$F('CHECK_YYMM'),
				CRED_ID1: $F('CRED_ID1'),
				SORT_KEY: $F('SORT_KEY'),
				NEW_DEPT:$F('NEW_DEPT'),
				CRED_ID2: $F('CRED_ID2')
		    }
		},
		
		//承辦科別下拉選單連動原徵信人員下拉選單
		doChangeCRED_ID1 :function(event){
			var rec_CRED_DEPT = event.target.value;
			if(rec_CRED_DEPT ==''){
				$('CRED_ID1').options.length = 1;
				return;
			}
			ajaxRequest.post( 'changeCRED_ID1' , {CRED_DEPT : rec_CRED_DEPT},
				function(resp){
					var rec_list_A = resp.RLDS2_LIST1;
					if(rec_list_A){
						$('CRED_ID1').options.length = 1;
						rec_list_A.each(
						function(data) {
							$('CRED_ID1').add(new Option(data.NAME, data.ID));
							}		
						); 		
					}
				}
			);	
		},
		//查核單位下拉選單連動查核人員下拉選單
		doChangeCRED_ID2 :function(event){
			var rec_NEW_DEPT = event.target.value;
			if(rec_NEW_DEPT ==''){
				$('CRED_ID2').options.length = 1;
				return;
			}
			ajaxRequest.post( 'changeCRED_ID2' , {NEW_DEPT : rec_NEW_DEPT},
				function(resp){
					var rec_list_A = resp.RLDS2_LIST2;
					if(rec_list_A){
						$('CRED_ID2').options.length = 1;
						rec_list_A.each(
						function(data) {
							$('CRED_ID2').add(new Option(data.NAME, data.ID));
							}		
						); 	
					}
				}
			);				
		}
	}	
	
	var buttons = {
		//查詢
		doQuery:function(event){
			ajaxRequest.post( 'query' , { reqMap : Object.toJSON(action.storeMap())},
				function(resp){
					grid.load(resp.rtnList||[]);
					var rtnMap = resp.rtnList[0] || '';
					$('NEW_DEPT').value = rtnMap.CRED_DEPT;		    
				    $('NEW_DEPT').observe('change',action.doChangeCRED_ID2);//查核單位 連動查核人員
				    $('CRED_ID2').add(new Option(rtnMap.CRED_NAME2, rtnMap.CRED_ID2));	
                    $('CRED_ID2').value = rtnMap.CRED_ID2;	
	           			
				},function(resp){  // 查詢失敗清除先前的查詢資料		
					grid.load([]);
				}
			);	
		},
		//派件
		doSend: function() {	
		    var data =grid.getCheckedRecord();	
			if(data.length==0){
			  alert("請先勾選欲派件資料，才能作業");
			  return;
			}
			if(!valid1.validate()){
				return; 
			} 
			ajaxRequest.post( 'send' , {dataList :Object.toJSON(data), CRED_ID2:$F('CRED_ID2'), NEW_DEPT:$F('NEW_DEPT'), reqMap :Object.toJSON(action.storeMap())},
				function(resp){
					grid.load(resp.rtnList||[]);
				}
			);
		}	
	};
	
	return {
		initApp : function() {			
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay" />
			PageUI.createPageWithAllBodySubElement( "DSC91100" , "查核派件作業", "資金流向查核派件作業" );
			
			grid = new TableUI({
				table: $("grid"), pageSize: 10, allSortable:true,	split: ['BORROW_ID'],	
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }<%-- [20230325]難字修改 --%>
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }<%-- [20230325]難字修改 --%>
				},
				autoCheckBox:{
				    isSelectAll:true,
				    withoutGroup: true
				},	
				column:[					
					{header:"貸款帳號",key:"LOAN_ID",attrs:{rowSpan:2}},
					{header:"受理編號",key:"APPLY_ID",attrs:{rowSpan:2}},
                    {header:"借款人姓名",key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"} },	<%-- [20230325]難字修改 --%>
					{header:"保證人姓名",key:"GUARANTEE_NAME", attrs:{style:"font-family:'EUDC'"} },<%-- [20230325]難字修改 --%>
					{header:"處理進度",key:"PROC_STATUS_NM",attrs:{rowSpan:2}},
					{header:"簽報單位",key:"DOC_DEPT_NAME",attrs:{rowSpan:2}},							
					{header:"原徵信人員",key:"LST_DOC_NAME",attrs:{rowSpan:2,style:"font-family:'EUDC'"}},<%-- [20230325]難字修改 --%>
					{header:"匯款人員",key:"REMIT_NAME",attrs:{rowSpan:2,style:"font-family:'EUDC'"}},<%-- [20230325]難字修改 --%>
					{header:"查核單位",key:"CRED_DEPT_NAME",attrs:{rowSpan:2}},
					{header:"查核人員",key:"CRED_NAME",attrs:{rowSpan:2,style:"font-family:'EUDC'"}},<%-- [20230325]難字修改 --%>
					{header:"派件日期",key:"ASSIGN_DATE",attrs:{rowSpan:2},sortRule:'date'},					
					{header:"借款人ID",key:"BORROW_ID"},
					{header:"保證人ID",key:"GUARANTEE_ID"}
				]
			});
			
			$('btn_query').observe('click', buttons.doQuery);           
            $('BTN_SEND').observe('click', buttons.doSend);
			$('CRED_DEPT').observe('change',action.doChangeCRED_ID1);//承辦科別連動徵信人員
			$('NEW_DEPT').observe('change',action.doChangeCRED_ID2);//查核單位 連動查核人員
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			//畫面檢核
			initValidation();
			buttonAuth();
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
		<td class="tbYellow">承辦科別</td>
		<td class="tbYellow2">
			<select id="CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach var="map" items="${CRED_DEPT_LIST}" >
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">查核月份</td>
		<td class="tbYellow2">
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
			原徵信人員
		</td>
		<td class="tbYellow2">
			<select id="CRED_ID1" class="textBox2" style="font-family:'EUDC'" alt="ch"><%-- [20230325]難字修改 --%>
				<option value="">全部</option>
				<c:forEach var="map" items="${RLDS2_LIST1}">							
					<option value='${map.ID}'>${map.NAME}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">
			排序方式
		</td>
		<td class="tbYellow2">
			<select id="SORT_KEY" class="textBox2">
				<c:forEach var="map" items="${SORT_KEY_LIST}">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td align="center" colspan="5">
			<input id="BTN_SEND" type="button" class="button" value="派件"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			查核單位
		</td>
		<td class="tbYellow2">
			<select id="NEW_DEPT" class="textBox2">
				<option value="">請選擇</option>
				<c:forEach var="map" items="${NEW_DEPT_LIST}">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">
			查核人員
		</td>
		<td class="tbYellow2" colspan="2">
			<select id="CRED_ID2" class="textBox2" style="font-family:'EUDC'"><%-- [20230325]難字修改 --%>
				<option value="">請選擇</option>
				<c:forEach var="map" items="${RLDS2_LIST2}">							
					<option value='${map.ID}'>${map.NAME}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	
</table>
<table id='grid' width='100%'></table>
</form>
</body>
</html>