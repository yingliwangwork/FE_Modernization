<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC31300.jsp
作者：張恆勖
功能：扣薪異常查詢
完成：2012/11/13
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>          <%-- 匯出 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<%--[20241101]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/JavaScript">

Event.observe(window, 'load', new DSC31300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC31300(){
	var grid;		
	
	//日期檢核
	var valid1;		
	
	//檢核日期欄位
	function initValidation(){
		valid1 = new Validation("form", { focusOnError:true, immediate:false});		
		valid1.define('required' , [{ id : "YEAR_MONTH" , errMsg:"請輸入工作年月"}] );				
	}		
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_1300/" + actionName,
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
	
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {
		
			//檢核
			if(!valid1.validate()){
				return; 
			}
			
			//發送AJAX	
			ajaxPost( 'query', {'SALARY_GROUP' :$F('SALARY_GROUP'),'ACTION_TYPE' : $F('ACTION_TYPE'),'YEAR_MONTH' : $F('YEAR_MONTH')}
				,function(resp){
					grid.load(resp.rtnList);
				}
				,function(resp){
					//如果失敗,把前一次的內容清掉
					grid.load([]);
				}
			);
		},	
		// 匯出
		doExport: function() {
		
			//檢核
			if(!valid1.validate()){
				return; 
			}
			
			var obj = {};
			obj.SALARY_GROUP = $F('SALARY_GROUP');
			obj.ACTION_TYPE = $F('ACTION_TYPE');
			obj.YEAR_MONTH = $F('YEAR_MONTH');
			obj.gridJSON = grid.getXlsSettingJSON('扣薪異常查詢'); //讀進頁面回傳資料項目
			
			RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSC3_1300/exportXls', { reqMap : Object.toJSON(obj) });
			
			
		}			
	};	
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSC31300" , "扣薪作業", "扣薪異常查詢" );
			
			grid = new TableUI(
				{table: $("grid"), allSortable: true, pageSize: 20,allSortable:false,
				<%--[20241101] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{header:"扣薪組別",key:"SALARY_GROUP_NM"},
					{header:"貸款種類",key:"LOAN_KIND_NM"},					
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"姓名",key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"}},
					{header:"借款人ID",key:"BORROW_ID"},
					{header:"期數",key:"PAY_TERM"},
					{header:"應繳日",key:"NEXT_PAYDT"},
					//{header:"備註",key:"MEMO"},					
					{header:"人事動態",key:"STATUS"},	
					{header:"動態備註",key:"STS_RMK_NM"},
					{header:"單位",key:"DIV_NAME"},
					{header:"異常原因",key:"ERROR_MSG"},//[2022-08-09]新增
					{header:"繳款方式",key:"PAY_TYPE_NM"},
					{header:"收息單位",key:"GETINT_DEPT_NM"},
					{header:"承辦科別",key:"CRED_DEPT_NM"},
					{header:"優惠等級",key:"VIP_GRADE_NM"}		
				]
			});
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
				
			//畫面日期檢核
			initValidation();
			
			// 監聽: 查詢
			$("BTN_0001").observe('click', button.doQuery);
			
			$("BTN_0002").observe('click', button.doExport);
							
			PageUI.resize();
			//初始頁面alert訊息用		
			displayMessage();
		}// end initApp()--
	}// end return--
}// end DSC31300
</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
		<tbody>
			<form id="form">
			<tr>
				<td class="tbYellow"  width="15%">工作年月</td>
				<td class="tbYellow2" width="15%">
					<input type="text" id="YEAR_MONTH" name="YEAR_MONTH" class='textBox2' size='7' maxLength='5' value="<c:out value="${YEAR_MONTH}"/>" onkeypress="return numberOnly()"/>				    				
				</td>
				<td class="tbYellow" width="15%">扣薪組別</td>
				<td class="tbYellow2"  width="15%">
					<select id="SALARY_GROUP" name="SALARY_GROUP" >					
						<c:forEach var="map" items="${SALARY_LIST}" >
							 <option value = "${map.key}" > ${map.value} </option>
						</c:forEach>					
					</select>
				</td>
				<td class="tbYellow" width="15%">查詢項目</td>
				<td class="tbYellow2"  width="15%">
					<select id="ACTION_TYPE" name="ACTION_TYPE" >						
						<c:forEach var="map" items="${QUERY_LIST}" >
							 <option value = "${map.key}" <c:if test="${map.key eq 1}" >selected</c:if>> ${map.value} </option>
						</c:forEach>						
					</select>
				</td>
				<td class="tbYellow2" align="center" valign="center"  width="10%">
					<input id="BTN_0001" type="button" value="查詢" class="button"> 
					<input id="BTN_0002" type="button" value="匯出" class="button">
				</td>
			</tr>	
			<tr>
				<td class="tbBox3" width="100%" colspan="7" align="center">員工離職查詢明細</td>
			</tr>
			</form>
		</tbody>	
	</table>
	<table id='grid'></table>
</body>
</html>	