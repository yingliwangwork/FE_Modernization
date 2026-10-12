<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>


<!--
程式：DSC50200.jsp
作者：羅巧萱
功能：春節寬限日設定作業
完成：2121-03-18

[20210325][問題單：20210324115256]
1.修正>>按新增一列或換頁後，既有的民國日期欄位1100301，會變為顯示成西元日期2021-03-01

[20241104] 修改件 難字調整 吳志鴻
 -->

<html>
<head>

<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 加這個來導頁用-->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/suggest.js"></script><%-- 搜尋提示用 --%>

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
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSC50200().initApp);
 function DSC50200(){
	 
	 
		<%-- TablE UI物件 --%>
		var gridA;		
		var gridB;
		var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC5_0200/');	
		var FUNC_ID = 'DSC50200';
		var valid;
		
		<%-- 按鈕檢核 --%> 
		function buttonAuth() {
			var authButtons = {
				B0003:'btnInsert',	
				B0004:'btnUpdate',	
				B0005:'btnDelete',	
				B0070:'btnApprove' 
			};
			<dz:grantButtons FUNC_ID="DSC50200" ignored="false"/>
		}
		
		<%--畫面檢核--%>
		function initValidation(){
			
			valid_Year = new Validation('form1', {useTitles:false}); 
			valid_Year.define( 'required' , [{ id : 'YEAR', errMsg : '請輸入春節年度' }] );

		}
		var actions = {
				<%--[20210325]新增一列及刪除一列時檢查明國年轉換--%>
				checkDateToROC : function(addNewRow){
					var templist = gridB.getAllRecords();
					
					for (i = 0; i < templist.length; i++) {
						if(!isROCdate(templist[i].DueDay)){
							templist[i].DueDay = toROC(templist[i].DueDay);
						}
						if(!isROCdate(templist[i].GraceDay)){
							templist[i].GraceDay = toROC(templist[i].GraceDay);
						}
					}
					<%--[20210325]若"新增一列"在這邊加--%>
					if(addNewRow){
						var newRecord = {'DueDay':'', 'GraceDay':'', 'delete':''};
						templist.push(newRecord);
					}
					
					gridB.load(templist);
				},
				
				<%-- 按鈕控制  --%>
				buttonCtrol : function(OP_STATUS){
					if('0'==OP_STATUS){
						<%-- 待審件 --%>
						$('btnUpdate').disabled = false;	
						$('btnDelete').disabled = false;	
						$('btnApprove').disabled = false;	
					} else if('1'==OP_STATUS){
						<%-- 已審件 --%>
						$('btnUpdate').disabled = true;	
						$('btnDelete').disabled = true;	
						$('btnApprove').disabled = true;	
					} else{
						$('btnUpdate').disabled = true;	
						$('btnDelete').disabled = true;	
						$('btnApprove').disabled = true;
					}
				},
				
				<%-- 輸入欄位檢查  --%>
				checkRules : function(){
					valid_Year.reset();                  
					if(!valid_Year.validate()){
						return false;	
					}
					
					var situation1 = $F('EMP_DUE_DATE')!="" && $F('EMP_GRACE_DATE')==""; 
					var situation2 = $F('EMP_GRACE_DATE')!="" && $F('EMP_DUE_DATE')==""; 
					if(situation1 || situation2){
						alert('員工件應繳日和寬限日需同時輸入');
						return false;	
					}
					
					var allRec = gridB.getAllRecords();
					if(allRec.length==0){
						alert('一般件應繳日、一般件寬限日不得為空');
						return false;	
					}
					
					return true;
				}

			};
	    var buttons = {
				<%-- 新增一列 按鈕   --%>
				doCreateRow : function(){
					<%--[20210325]新增一列及刪除一列時檢查明國年轉換--%>
					actions.checkDateToROC(true);
				},
				<%-- 清除全部 按鈕   --%>
				doDeletAll : function(){
					gridB.clear();
				},
				<%-- 查詢按鈕   --%>
				doQuery : function() {
					valid_Year.reset();                  
					if(!valid_Year.validate()){
						return;	
					}
					
					$('EMP_DUE_DATE').setValue('');
					$('EMP_GRACE_DATE').setValue('');
					
					ajaxRequest.post(
						'query', {
							YEAR : $F("YEAR")
						}, 
						function(resp) {
							var rtnMap = resp.rtnMap || [];
							gridA.load(rtnMap);
							$('EMP_DUE_DATE').setValue(rtnMap["EMP_DUE_DATE"]);
							$('EMP_GRACE_DATE').setValue(rtnMap["EMP_GRACE_DATE"]);
							
							var op_status = rtnMap["OP_STATUS"] || "";
							actions.buttonCtrol(op_status);
							
							var D_Block_List = resp.D_Block_List || []
							gridB.load(D_Block_List);

						}
					)
				},
				<%-- 新增 按鈕   --%>
				doInsert : function(){
					if(!actions.checkRules()){
						return;	
					}
					ajaxRequest.post(
							'insert', {
								allRecJson : Object.toJSON(gridB.getAllRecords()),
								YEAR : $F('YEAR'),
								EMP_DUE_DATE : $F('EMP_DUE_DATE'),
								EMP_GRACE_DATE : $F('EMP_GRACE_DATE')
							}, 
							function(resp) {
								var rtnMap = resp.rtnMap || [];
								gridA.load(rtnMap);
								$('EMP_DUE_DATE').setValue(rtnMap["EMP_DUE_DATE"]);
								$('EMP_GRACE_DATE').setValue(rtnMap["EMP_GRACE_DATE"]);
								
								var op_status = rtnMap["OP_STATUS"] || "";
								actions.buttonCtrol(op_status);
								
								var D_Block_List = resp.D_Block_List || []
								gridB.load(D_Block_List);
								
							}
						)
				},
				<%-- 修改 按鈕   --%>
				doUpdate : function(){
					if(!actions.checkRules()){
						return;	
					}
					ajaxRequest.post(
							'update', {
								allRecJson : Object.toJSON(gridB.getAllRecords()),
								YEAR : $F('YEAR'),
								EMP_DUE_DATE : $F('EMP_DUE_DATE'),
								EMP_GRACE_DATE : $F('EMP_GRACE_DATE')
							}, 
							function(resp) {
								var rtnMap = resp.rtnMap || [];
								gridA.load(rtnMap);
								$('EMP_DUE_DATE').setValue(rtnMap["EMP_DUE_DATE"]);
								$('EMP_GRACE_DATE').setValue(rtnMap["EMP_GRACE_DATE"]);
								
								var op_status = rtnMap["OP_STATUS"] || "";
								actions.buttonCtrol(op_status);
								
								var D_Block_List = resp.D_Block_List || []
								gridB.load(D_Block_List);
								
							}
						)
				},
				<%-- 刪除 按鈕   --%>
				doDelete : function(){
					$('EMP_DUE_DATE').setValue("");
					$('EMP_GRACE_DATE').setValue("");
					ajaxRequest.post(
							'delete', {
								YEAR : $F('YEAR')
							}, 
							function(resp) {
								var rtnMap = resp.rtnMap || [];
								gridA.load(rtnMap);
								$('EMP_DUE_DATE').setValue(rtnMap["EMP_DUE_DATE"]);
								$('EMP_GRACE_DATE').setValue(rtnMap["EMP_GRACE_DATE"]);
								
								var op_status = rtnMap["OP_STATUS"] || "";
								actions.buttonCtrol(op_status);
								
								var D_Block_List = resp.D_Block_List || []
								gridB.load(D_Block_List);
								
							}
						)
				},
				<%-- 覆核 按鈕   --%>
				doApprove : function(){
					if(!actions.checkRules()){
						return;	
					}
					ajaxRequest.post(
							'approve', {
								YEAR : $F('YEAR')
							}, 
							function(resp) {
								$('EMP_DUE_DATE').setValue('');
								$('EMP_GRACE_DATE').setValue('');
								var rtnMap = resp.rtnMap || [];
								gridA.load(rtnMap);
								$('EMP_DUE_DATE').setValue(rtnMap["EMP_DUE_DATE"]);
								$('EMP_GRACE_DATE').setValue(rtnMap["EMP_GRACE_DATE"]);
								
								var op_status = rtnMap["OP_STATUS"] || "";
								actions.buttonCtrol(op_status);
								
								var D_Block_List = resp.D_Block_List || []
								gridB.load(D_Block_List);
								
							}
						)
				}
	    };
	    
		
		return {
			
			initApp : function() {
				
				 <cathay:LocaleDisplay sysCode='DS'  var='localeDisplay' dateFields='EMP_GRACE_DATE EMP_DUE_DATE' />
					 PageUI.createPageWithAllBodySubElement("DSC50200", "利率計算", "春節連假調整寬限日作業");
				
				$('btnQuery').observe('click', buttons.doQuery);
				$('btnCreateRow').observe('click',buttons.doCreateRow);
				$('btnDeletAll').observe('click',buttons.doDeletAll);
				$('btnInsert').observe('click',buttons.doInsert);
				$('btnUpdate').observe('click', buttons.doUpdate);
				$('btnDelete').observe('click',buttons.doDelete);
				$('btnApprove').observe('click',buttons.doApprove);
				
				gridA =  new TableUI({ 
					table: $("gridShowInfo"),
        	        column:[
						{header: "春節年度" , key:'YEAR'},
						{header: "狀態" , key:'OP_STATUS_NAME' },
						{header: "輸入日期" , key:'INPUT_DATE' , sortRule:'date'},
						{header: "輸入人員" , key:'INPUT_NAME',attrs:{style:"font-family:'EUDC'"}},  <%-- [20241104] 難字調整: 輸入人員 --%>
						{header: "覆核日期" , key:'CONFIRM_DATE' , sortRule:'date'},
						{header: "覆核人員" , key:'CONFIRM_NAME',attrs:{style:"font-family:'EUDC'"}}, <%-- [20241104] 難字調整: 覆核人員 --%>
	                ]
				});	
				
				gridB =  new TableUI({ 
					table: $("gridShowDate"),
					pageSize:20,
        	        column:[
						{header: "一般件應繳日" , key:'DueDay',input:{type:'ROCDATE'}},
						{header: "一般件寬限日" , key:'GraceDay',input:{type:'ROCDATE'}},<%--,datatype:'ROCDATE', sortRule:'date'--%>
						{header: "",key: "delete", sortable:false, render:function(record,value,sn)
							{var inputtag = new Element('input',{type:'button'}).setValue('刪除');
								inputtag.observe('click',function(){
									gridB.deleteRecords(record);
									<%--[20210325]新增一列及刪除一列時檢查明國年轉換--%>
									actions.checkDateToROC(false);
									
							});
							return inputtag;}
						}
	                ]
				});	
				
				initValidation();
				displayMessage();
				buttonAuth();

			}	
		};	
	}	



</script>

</head>
	<body>
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A" class="tbBox2" width="100%" cellSpacing="1" cellPadding="1">
			<tbody>
				<tr>
					<td class="tbYellow" id="table_1_R0C0" rowSpan="1" colSpan="1" width="" style="text-align:left;">
						<span id="input-label_1" class="" style="">春節年度</span>
					</td>
					<td class="tbYellow2" id="table_1_R0C1" rowSpan="1" colSpan="1" width="" style="text-align:left;">
						<input type="text" class="textBox2" id="YEAR" title="" maxLength="" size="" value="${NOW_YEAR}" />
					</td>
					<td class="tbYellow2" id="table_1_R0C2" rowSpan="1" colSpan="1" width="" style="text-align:left;">
						<button type="button" id="btnQuery" class="button" title="" style="" ###events###>查詢</button>
					</td>
				</tr>
				<tr>
					<td class="" id="table_1_R1C0" rowSpan="1" colSpan="3" width="" style="text-align:center;">
						<button type="button" id="btnInsert" class="button" title="" style="" ###events###>新增</button>
						<button type="button" id="btnUpdate" class="button" title="" style="" disabled>修改</button>
						<button type="button" id="btnDelete" class="button" title="" style="" disabled>刪除</button>
						<button type="button" id="btnApprove" class="button" title="" style="" disabled>覆核</button>
					</td>
				</tr>
			</tbody>
		</table>
		
		<div class="grid" id="gridShowInfo">&nbsp;&nbsp;</div>
		
		
		<table id="table_C" class="tbBox2" width="100%" cellSpacing="1" cellPadding="1">
			<tbody>
				<tr>
					<td class="tbYellow0" id="table_2_R0C0" rowSpan="1" colSpan="4" width="" style="text-align:center;">
						<span id="input-label_2" class="" style="">員工件應繳日及寬限日對照設定</span>
			
					</td>
				</tr>
				<tr>
					<td class="tbYellow" id="table_2_R1C0" rowSpan="1" colSpan="1" width="" style="text-align:left;">
						<span id="input-label_3" class="" style="">員工件應繳日</span>
					</td>
					<td class="tbYellow2" id="table_2_R1C1" rowSpan="1" colSpan="1" width="" style="text-align:left;">
						<input type="text" class="textBox2" id="EMP_DUE_DATE" title="" dataType="ROCDate" fieldName="員工件應繳日"  />
					</td>
					<td class="tbYellow" id="table_2_R1C2" rowSpan="1" colSpan="1" width="" style="text-align:left;">
						<span id="input-label_5" class="" style="">員工件寬限日</span>
					</td>
					<td class="tbYellow2" id="table_2_R1C3" rowSpan="1" colSpan="1" width="" style="text-align:left;">
						<input type="text" class="textBox2" id="EMP_GRACE_DATE" title="" dataType="Date" fieldName="員工件寬限日"  />
					</td>
				</tr>
			</tbody>
		</table>
		
		<table id="table_D" class="tbBox2" width="100%" cellSpacing="1" cellPadding="1">
				<tr>
					<td class="tbBlue" id="table_3_R0C0" rowSpan="1" colSpan="1" width="" style="text-align:center;">
						<button type="button" id="btnCreateRow" class="button" title="" style="" ###events###>新增一列</button>
					</td>
					<td class="tbBlue" id="table_3_R0C1" rowSpan="1" colSpan="2" width="" style="text-align:center;">
						<span id="input-label_6" class="" style="font-weight:bold; ">一般件應繳日及寬限日對照設定</span>
					</td>
					<td class="tbBlue" id="table_3_R0C0" rowSpan="1" colSpan="1" width="" style="text-align:center;">
						<button type="button" id="btnDeletAll" class="button" title="" style="" ###events###>清除全部</button>
					</td>
				</tr>

			</table>
		<div class="grid" id="gridShowDate">&nbsp;&nbsp;</div>
	</form>
	</body>
</html>