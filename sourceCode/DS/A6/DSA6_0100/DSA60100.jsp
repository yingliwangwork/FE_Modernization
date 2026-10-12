<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA60100.jsp
功能： 覆審案件查詢
[20240930] 修改件 CHROME瀏覽器難字調整
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" />
<!--匯入外部Javascript 與 css-->
<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<%--[20240930]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/popupWin.js'></script>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSA60100().initApp);

function DSA60100(){
	
	var valid;
	var valid2;
    var grid1,grid2,grid3,grid4;
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA6_0100/');
	
	//畫面檢核
	function initValidation(){		
		Validation.addAllThese([
			[ 'validateQueryCondition', '', function(val1, val2){
				if(!val1 && !val2){
					return false;
				} 
				return true;				
			}]
			
		]);		
		valid = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
		valid.define( "validateQueryCondition" , [{ id: "REV_DEPT_CODE", errMsg: "請選擇覆審科別或覆審類別" },{ id: "REV_TYPE", ignore : true} ]);
		valid.define( "required" , [{ id: "REV_YM" }]);
		valid.define( "validate-ROCDateYM" , [{ id: "REV_YM"}]);		
		
		valid2 = new Validation('form1');
		valid2.define( "required" , [{ id: "REV_DEPT_CODE" }]);
		valid2.define( "required" , [{ id: "REV_TYPE" }]);
		valid2.define( "required" , [{ id: "REV_YM" }]);
	};
	
	var actions = {
		getReqMap: function(){
			var reqMap = {};
			$('tableA').select('input, select').each(function(ele){
				var key = ele.name ? ele.name : ele.id;
				reqMap[key]=ele.getValue();
			});
			return reqMap;
		},
		getColumns: function(type){
			<%-- [20240930]  難字調整 --%>
			if('3'==type){
				var cols = [	
					{header:"序號", key:'SEQ_NO', 
						render: function(rec, val, sn){
							return sn;
						}
					},
					{header:"原貸帳號", key:'REFER_ID',
						render:function(record, value){
							CSRUtil.keepParamsManager.put({'REFER_ID': record.REFER_ID });
							var alink = document.createElement("a");
							alink.href = "#";
							alink.innerHTML = record.REFER_ID;
							alink.onclick = function(){
								var url = "<%=dispatcher%>/DSA6_0400/prompt";
				 				popupWin.windowOpen( url ,{
					        		'parameters': {'REFER_ID' : record.REFER_ID, 'REV_YM' : record.REV_YM},
					        		'windowName': 'DSA60400' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
					    		});
							};
							return alink;
						}
					},
					{header:"借款人", key:'BORROW_NAME', style:"font-family:'EUDC'"},
					{header:"統一編號", key:'BORROW_ID'},
					{header:"擔保品地址", key:'GAGE_ADDR', style:"font-family:'EUDC'", attrs:{align:'left'}},
					{header:"覆審人員", key:'REV_NM', style:"font-family:'EUDC'"},
					{header:"覆審結果", key:'REV_RESULT_NM'},
					{header:"說明", key:'REV_DESC', attrs:{align:'left'}},
					{header:"覆審進度", key:'REV_PROCESS_NM'},
					{header:"擔保品種類", key:'GAGE_TYPE_NM'}
				];
				return cols;
			}else if('4'==type){
				var cols = [
					{header:"序號", key:'SEQ_NO', 
						render: function(rec, val, sn){
							return sn;
						}
					},
					{header:"原貸帳號", key:'REFER_ID',
						render:function(record, value){
							CSRUtil.keepParamsManager.put({'REFER_ID': record.REFER_ID });
							var alink = document.createElement("a");
							alink.href = "#";
							alink.innerHTML = record.REFER_ID;
							alink.onclick = function(){
								var url = "<%=dispatcher%>/DSA6_0400/prompt";
				 				popupWin.windowOpen( url ,{
					        		'parameters': {'REFER_ID' : record.REFER_ID, 'REV_YM' : record.REV_YM},
					        		'windowName': 'DSA60400' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
					    		});
							};
							return alink;
						}	
					},
					{header:"借款人", key:'BORROW_NAME', style:"font-family:'EUDC'"},
					{header:"統一編號", key:'BORROW_ID'},
					{header:"擔保品地址", key:'GAGE_ADDR', style:"font-family:'EUDC'", attrs:{align:'left'}},
					{header:"覆審人員", key:'REV_NM', style:"font-family:'EUDC'"},
					{header:"覆審結果", key:'REV_RESULT_NM'},
					{header:"說明", key:'REV_DESC', attrs:{align:'left'}},
					{header:"覆審進度", key:'REV_PROCESS_NM'},
					{header:"本金餘額", key:'REMAIN_AMT', sortRule: 'number'},
					{header:"重估市價", key:'TOTAL_PRICE', sortRule: 'number'},
					{header:"覆審放款率", key:'REV_GA_RATE',
						render:function(record, value, i){
							if(!value && value!='0'){
								return '';
							}
							return localeDisplay.formatNumber(value, 0, false)+'%'; <%-- 最多顯示小數點後兩位 --%>
						}
					},
					{header:"市價比", key:'REALVALUE_RATE',
						render:function(record, value, i){
							if(!value && value!='0'){
								return '';
							}
							return localeDisplay.formatNumber(value, 0, false)+'%'; <%-- 最多顯示小數點後兩位 --%>
						}
					},
					{header:"繳息正常", key:'FINISH_KIND_INT_NM'},
					{header:"債權確保", key:'FINISH_KIND_DEB_NM'}
				];					
				return cols;
			}else{
				var cols = [	
					{header:"序號", key:'SEQ_NO', 
						render: function(rec, val, sn){
							return sn;
						}
					},
					{header:"貸款帳號", key:'LOAN_ID',
						render:function(record, value){
							CSRUtil.keepParamsManager.put({'LOAN_ID': record.LOAN_ID });
							var alink = document.createElement("a");
							alink.href = "#";
							alink.innerHTML = record.LOAN_ID;
							alink.onclick = function(){
								var url = "<%=dispatcher%>/DSA6_0300/prompt";
				 				popupWin.windowOpen( url ,{
					        		'parameters': {'LOAN_ID' : record.LOAN_ID, 'REV_YM' : record.REV_YM},
					        		'windowName': 'DSA60300' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
					    		});
							};
							return alink;
						}	
					},
					{header:"借款人", key:'BORROW_NAME', style:"font-family:'EUDC'"},
					{header:"統一編號", key:'BORROW_ID'},
					{header:"擔保品地址", key:'GAGE_ADDR', style:"font-family:'EUDC'", attrs:{align:'left'}},
					{header:"覆審人員", key:'REV_NM', style:"font-family:'EUDC'"},
					{header:"覆審結果", key:'REV_RESULT_NM'},
					{header:"說明", key:'REV_DESC', attrs:{align:'left'}},
					{header:"覆審進度", key:'REV_PROCESS_NM'}
				];
				return cols;
			}
		},
		gridCtrl: function(resp){
			if(resp && resp.rtnList1){
				grid1.show();
				grid1.load(resp.rtnList1 || []);
			}else{
				grid1.hide();
				grid1.load([]);
			}
			if(resp && resp.rtnList2){
				grid2.show();
				grid2.load(resp.rtnList2 || []);
			}else{
				grid2.hide();
				grid2.load([]);
			}
			if(resp && resp.rtnList3){
				grid3.show();
				grid3.load(resp.rtnList3 || []);
			}else{
				grid3.hide();
				grid3.load([]);
			}
			if(resp && resp.rtnList4){
				grid4.show();
				grid4.load(resp.rtnList4 || []);
			}else{
				grid4.hide();
				grid4.load([]);
			}	
		}		
	};
		
	var buttons = {
		doQuery : function(){
			valid.reset();
			valid2.reset();
			if(!valid.validate()){
				return;
			}		
			var reqMap = actions.getReqMap();
			ajaxRequest.post( 'query', { reqMap: Object.toJSON(reqMap)},
				function(resp){
					actions.gridCtrl(resp);					
				}, function(resp){
					actions.gridCtrl();
				}
			);
	    },
		doPrint : function(event){
			valid.reset();
			valid2.reset();
			if(!valid2.validate()){
				return;
			}
			//var reqMap = actions.getReqMap();
			var reqMap = {};
			reqMap.REV_DEPT_CODE = $('REV_DEPT_CODE').value;
			reqMap.REV_TYPE = $('REV_TYPE').value;
			reqMap.REV_YM = $('REV_YM').value;
			RPTUtil.downloadFile('${dispatcher}/DSA6_0100/print', { "reqMap" : Object.toJSON(reqMap) }, true);
		},
		doClear : function(event){
			$('form1').reset();		
		}
    };

	return{
	
		initApp : function(){
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>
			
			PageUI.createPageWithAllBodySubElement('DSA60100', '覆審作業', '覆審案件查詢');
			<%-- [20240930]  難字調整 --%>
			grid1 = new TableUI({
                table: $("grid1"),	
                title: "一般覆審(法金)",
                pageSize: 8, 	
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column: actions.getColumns()
			});
			grid2 = new TableUI({
                table: $("grid2"),	
                title: "一般覆審(消金)",
                pageSize: 8, 
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column:actions.getColumns()
			});
			grid3 = new TableUI({
                table: $("grid3"),	
                title: "重要覆審(法金)",
                pageSize: 8,
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},				
				column:actions.getColumns("3")
			});			
			grid4 = new TableUI({
                table: $("grid4"),	
                title: "重要覆審(消金)",
                pageSize: 8, 
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column:actions.getColumns("4")
			});
			
			actions.gridCtrl();
			
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_clear').observe('click', buttons.doClear);
			$('btn_print').observe('click', buttons.doPrint);			
			
			initValidation();
			displayMessage();			
		}	
		
	};
}
</script>
</head>
<body>
<form name='form1' id='form1'>
<table id="tableA" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">覆審科別</td>
		<td class="tbYellow2" width="15%">
			<select fieldName="覆審科別" id="REV_DEPT_CODE" name="REV_DEPT_CODE" class="textBox2">
				<option value="">全部</option>
				<c:forEach items="${REV_DEPT_CODE_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
		<td class="tbYellow" width="10%">覆審類別</td>
		<td class="tbYellow2" width="15%">
			<select fieldName="覆審類別" id="REV_TYPE" name="REV_TYPE" class="textBox2">
				<option value="">全部</option>
				<c:forEach items="${REV_TYPE_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width="10%">覆審結果</td>
		<td class="tbYellow2" width="15%">
			<select fieldName="覆審結果" id="REV_RESULT" name="REV_RESULT" class="textBox2">
				<option value="">全部</option>
				<c:forEach items="${REV_RESULT_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow2" align="center" rowspan="2" width="25%">
			<button id="btn_query" type="button" class="button">查詢</button>
			<button id="btn_clear" type="button" class="button">清除</button>
			<button id="btn_print" type="button" class="button">列印</button>
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">覆審進度</td>
		<td class="tbYellow2">
			<select fieldName="覆審進度" id="REV_PROCESS" name="REV_PROCESS" class="textBox2">
				<option value="">全部</option>
				<c:forEach items="${REV_PROCESS_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">覆審年月<font color="red">※例：11010</font></td>
		<td class="tbYellow2" colspan="3">
			<input fieldName="覆審年月" type='text' id='REV_YM' name='REV_YM' class="textBox2" size="8" maxlength="5"/>
		</td>
	</tr>
</table>
<table id="grid1" class="grid"></table>
<table id="grid2" class="grid"></table>
<table id="grid3" class="grid"></table>
<table id="grid4" class="grid"></table>
</form>
</body>
</html>