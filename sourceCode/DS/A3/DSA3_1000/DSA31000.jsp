<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA31000.jsp
作者：王文進
功能：鑑價資訊情報
完成：2012/3/26
更新：
[20240930]難字調整
-->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<%--[20240930]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<%--自行定義的javaScript--%>
<script type="text/JavaScript">
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA31000().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31000(){
	
	var valid1;
	var column1;
	var column2;
	var grid = {};

	<%--
	button控制
	--%>
	<%--	
	var buttonAuth = function (){
		var authButtons = {
			B0004:"btn_query" 
		};
		<dz:grantButtons FUNC_ID="DSA31000" ignored="false"/>
	};
	--%>
	
	//查詢
	function doQuery(){
		
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		var dataMap = {};
		if($('REPORT_0').checked){
			//產生 Grid 物件                
			grid = new TableUI({
				table: $('grid'), pageSize: 10, allSortable: true,
				<%-- [20240930] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:column1
			});
			
			dataMap.REPORT = $('REPORT_0').value;
		}else if($('REPORT_1').checked){
			//產生 Grid 物件                
			grid = new TableUI({
				table: $('grid'), pageSize: 10, allSortable: true,
				<%-- [20240930] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:column2
			});
			
			dataMap.REPORT = $('REPORT_1').value;
		}

		dataMap.APPR_DEPT = $('APPR_DEPT').value;
		dataMap.APPR_GROUP = $('APPR_GROUP').value;
		dataMap.DATE_BEG = $('DATE_BEG').value;
		dataMap.DATE_END = $('DATE_END').value;
				
		var params = { inputMap:Object.toJSON(dataMap) };
		//成功
		var successActionOpen = function(resp){
		
			if($('REPORT_0').checked){
				theRtnList = resp.outputDataMap.rtnList;
				sumSubList1 = resp.outputDataMap.summurySubList1;
				sumSubList2 = resp.outputDataMap.summurySubList2;
				sumTotalList = resp.outputDataMap.sumTotalList;
						
				var subObj1 = [];	
				var subObj2 = [];
				subObj = [];
			
				// 產生小計 1
				for (var i = 0; i < sumSubList1.length; i++){
					subObj1[i] = { text:  sumSubList1[i].APPR_GROUP_NM , key:{APPR_GROUP:[sumSubList1[i].APPR_GROUP]} ,
								   textAlign : 'center',
								   value:{ 
												APPR_GROUP_NM:[sumSubList1[i].APPR_GROUP_NM],
												APPLY_ID:MoneyFormat(sumSubList1[i].APPLY_ID)
									} 
					};
				}	
				
				// 產生小計 2
				for (var i = 0; i < sumSubList2.length; i++){
					subObj2[i] = { text:  sumSubList2[i].APPR_NM , key:{APPR_GROUP:[sumSubList2[i].APPR_GROUP],APPR_ID:[sumSubList2[i].APPR_ID]} ,
								   textAlign : 'center',
								   value:{ 
												APPR_GROUP_NM:[sumSubList2[i].APPR_GROUP_NM],
												APPLY_ID:MoneyFormat(sumSubList2[i].APPLY_ID)
									} 
					};
				}		
				
				subObj = [subObj2,subObj1];
	 
				grid.load(theRtnList,sumTotalList,subObj );
				
				grid.sort( 'APPR_GROUP', SORT_INCREASE , "string", null , false );  
			}else if($('REPORT_1').checked){
				theRtnList = resp.outputDataMap.rtnList;
				sumSubList1 = resp.outputDataMap.summurySubList1;
				sumTotalList = resp.outputDataMap.sumTotalList;
						
				var subObj1 = [];	
				subObj = [];
			
				// 產生小計 1
				for (var i = 0; i < sumSubList1.length; i++){
					subObj1[i] = { text:  sumSubList1[i].APPR_GROUP_NM , key:{APPR_GROUP:[sumSubList1[i].APPR_GROUP]} ,
								   textAlign : 'center',
								   value:{ 
												APPR_GROUP_NM:[sumSubList1[i].APPR_GROUP_NM],
												ASSIGN_CNT:sumSubList1[i].ASSIGN_CNT, 
												CONVERT_ASSIGN_CNT:sumSubList1[i].CONVERT_ASSIGN_CNT, 
												FINISH_CNT:sumSubList1[i].FINISH_CNT, 
												CONVERT_FINISH_CNT:sumSubList1[i].CONVERT_FINISH_CNT, 
												NOT_FINISH_CNT:sumSubList1[i].NOT_FINISH_CNT
									} 
					};
				}	

				subObj = [subObj1];
	 
				grid.load(theRtnList,sumTotalList,subObj );
				
				grid.sort( 'APPR_GROUP', SORT_INCREASE , "string", null , false );  
			}

		};
		ajaxPost('query',params,successActionOpen,null);
	}
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA3_1000/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}

	return{                              
		initApp:function(){
		
			PageUI.createPage("DSA31000" , "鑑價作業" , "鑑價資訊情報");
			PageUI.loadin(["tableA","grid"] ,1);
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				[ 'chkDATE_END',  '報表種類選擇『派件件數統計表』派件日期迄必須輸入', function(){ if($('REPORT_1').checked && $F('DATE_END') == ''){ return false; } return true; } ],
				[ 'chkDATE_BEG',  '派件日期起必須輸入', function(){ if($F('DATE_BEG') == ''){ return false; } return true; } ] 
			]);
			
			column1 = [
				{header:'鑑價組別', key:'APPR_GROUP', groupKey:["APPR_GROUP"],
					render:function(record, value){
					 	return record.APPR_GROUP_NM ? record.APPR_GROUP_NM : '';
					}
				},
				{header:'鑑價人員', key:'APPR_ID', groupKey:["APPR_GROUP","APPR_ID"], attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
					render:function(record, value){
					 	return record.APPR_NM ? record.APPR_NM : '';
					}
				},
				{header:'受理編號', key:'APPLY_ID',
					render:function(record, value){
					 	return value ? value : '';
					}
				},
				{header:'借款人', key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
					render:function(record, value){
					 	return value ? value : '';
					}
				},
				{header:'擔保品地址', key:'GAGE_ADDR', attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
					render:function(record, value){
					 	return value ? value : '';
					}
				},
				{header:'派件日期', key:'ASSIGN_DATE',
					render:function(record, value){
						return value ? Date.toROC(value) : '';
					}
				}
			];
			
			column2 = [
				{header:'鑑價組別', key:'APPR_GROUP', groupKey:["APPR_GROUP"],
					render:function(record, value){
					 	return record.APPR_GROUP_NM ? record.APPR_GROUP_NM : '';
					}
				},
				{header:'鑑價人員', key:'APPR_NM', attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
					render:function(record, value){
					 	return value ? value : '';
					}
				},
				{header:'派件件數', key:'ASSIGN_CNT',
					render:function(record, value){
					 	return value ? value : '0';
					}
				},
				{header:'派件件數轉換後', key:'CONVERT_ASSIGN_CNT',
					render:function(record, value){
					 	return value ? value : '0';
					}
				},
				{header:'完成件數', key:'FINISH_CNT',
					render:function(record, value){
					 	return value ? value : '0';
					}
				},
				{header:'完成件數轉換後', key:'CONVERT_FINISH_CNT',
					render:function(record, value){
						return value ? value : '0';
					}
				},
				{header:'未結件數', key:'NOT_FINISH_CNT',
					render:function(record, value){
						return value ? value : '0';
					}
				}
			];
			
			//查詢
			$('btn_query').observe('click',function(event){
					doQuery();
				}
			);
			
			//清除
			$('btn_clear').observe('click',function(event){
					$('form1').reset();
					$('REPORT_0').click();
					$('DATE_BEG').value = '${DATE_BEG}';
					$('DATE_END').value = '${DATE_END}';
					grid.load([]);
				}
			);
			
			$('REPORT_0').observe('click',function(event){
					//產生 Grid 物件                
					grid = new TableUI({
						table: $('grid'), pageSize: 10, allSortable: true,
						<%-- [20240930] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:column1
					});
				}
			);
			
			$('REPORT_1').observe('click',function(event){
					//產生 Grid 物件                
					grid = new TableUI({
						table: $('grid'), pageSize: 10, allSortable: true,
						<%-- [20240930] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:column2
					});
				}
			);
						
			//buttonAuth();

			displayMessage();
			
			$('REPORT_0').click();
			$('DATE_BEG').value = '${DATE_BEG}';
			$('DATE_END').value = '${DATE_END}';

		}                 
	}

}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<form id="form1" name="form1" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
		<tr>
			<td class="tbYellow">
				報表種類
			</td>
			<td class="tbYellow2" colspan="5" width ="10%">
					<input type="radio" id="REPORT_0" name="REPORT" value="0" checked>逾三日未完成統計表
					<input type="radio" id="REPORT_1" name="REPORT" value="1">派件件數統計表
				
			</td>
			<td class="tbYellow2" align="center" rowspan="2" width ="10%">
				<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
				<input id="btn_clear" name="btn_clear" type="button" class="button" value="清除">
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width ="10%">派件日期</td>
			<td class="tbYellow2" width ="25%">
				<input name="DATE_BEG" id='DATE_BEG' type="text" class="textBox2 required validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('DATE_BEG'))">
				~
				<input name="DATE_END" id='DATE_END' type="text" class="textBox2 validate-ROCDate chkDATE_END" size="10" maxlength="7" datatype="ROCDate" value="">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('DATE_END'))">  
			</td>
			<td class="tbYellow" width ="10%">鑑價科</td>
			<td class="tbYellow2" width ="10%">
				<select name="APPR_DEPT" id="APPR_DEPT">
					<option value=''>全部</option>
					<c:forEach var="map" items="${APPR_DEPT_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
		
			<td class="tbYellow" width ="10%">鑑價組</td>
			<td class="tbYellow2" width ="10%">
				<select name="APPR_GROUP" id="APPR_GROUP">
					<option value=''>全部</option>
					<c:forEach var="map" items="${APPR_GROUP_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
	</table>
	
	<table id="grid" class="grid"></table>
	
	</form>

</body>
<!-- InstanceEnd -->
</html>
