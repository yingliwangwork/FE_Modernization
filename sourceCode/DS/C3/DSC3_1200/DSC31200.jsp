<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename='TextResource' />

<!--
程式：DSC31200.jsp
功能：轉帳個件查詢
作者：林秉宏
完成：2014/07/21
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
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
<script type='text/javascript'><!--

	// 透過 prototype 的 Event 物件監聽 onloRad 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC31200().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC31200(){	

		var grid;
		var valid;
		
		// 檢核
		var initValidation = function(){		
			valid = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid.define('required' , [{ id : "TRANS_YM" , errMsg:"請輸入轉帳年月"}] );
		}
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC3_1200/' + actionName,
			{  
				parameters: params, 
				onSuccess: function(response)
				{
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){
						if(successAction){
							successAction(resp);
						}
					}else{
						if(errorAction){
							errorAction(resp);
						}
					}
				}
			});
		};	
	
		var actions = {
		
			// 查詢
			doQuery: function(){
				
				// 檢核
				if(!valid.validate()){ 
					return; 
				}
				
				var reqMap = {
					TRANS_YM : $F('TRANS_YM')+'01',
					TRANS_GROUP : $F('TRANS_GROUP'),
					INPUT_DEPT : $F('INPUT_DEPT'),
					TRANS_BANK : $F('TRANS_BANK')
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'info' : Object.toJSON(reqMap) },
					function(resp){			
						grid.load(resp.rtnList || []);
					},function(resp){
						grid.load([]);
					}
				);	
			},
			
			// 匯出
			doExport: function(){

				// 檢核
				if(!valid.validate()){ 
					return; 
				}
				
				var reqMap = {
					TRANS_YM : $F('TRANS_YM')+'01',
					TRANS_GROUP : $F('TRANS_GROUP'),
					INPUT_DEPT : $F('INPUT_DEPT'),
					TRANS_BANK : $F('TRANS_BANK'),
					gridJSON : grid.getXlsSettingJSON('轉帳個件查詢')
				}
				
				RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSC3_1200/exportXls', { info : Object.toJSON(reqMap) });
			}
		};

		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSC31200' ,
					'銀行轉帳' , 
					'轉帳個件查詢'
				);			
				
				// 產生 grid 物件	
				grid = new TableUI(
					{	
						table: $('grid'), allSortable:true, overDiv:false,
						<%--[20241101] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header:'單位', key:'INPUT_DEPT_NM'},
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:'借款人姓名', key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"}},
							{header:'不計延滯息', key:'SPEC_CODE_NM'},
							{header:'期數', key:'PAY_TERM'},
							{header:'輸入人員', key:'INPUT_NM', attrs:{style:"font-family:'EUDC'"}},
							{header:'照會時間', key:'TEL_TIME'},
							{header:'加抽狀態', key:'ACNT_CODE_NM'},
							{header:'轉帳狀態', key:'TRANS_STATUS_NM'}
						]						
					}
				);		
					
				initValidation();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
				
				// 確認
				$('BTN_export').observe('click', actions.doExport);
				
				//單位別預設
				switch ('${DIV_NO}') 
				{
					<c:forEach items="${INPUT_DEPT_List}" var="row">
					case '${row.key}' : $('INPUT_DEPT').value = '${DIV_NO}'; 
					break;
					</c:forEach>
					default : $('INPUT_DEPT').value = ''; 
				}
				
				//轉帳組別預設
				$('TRANS_GROUP').value = '';
				
				//轉帳銀行預設
				$('TRANS_BANK').value = '';
	
				PageUI.resize();
				displayMessage();
		
			} // end initApp()		
		}; // end return
	}

-->
</script>
</head>
<body>

<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width='10%'>
			轉帳年月
		</td>
		<td class="tbYellow2" width="35%">
			<input id="TRANS_YM" name="TRANS_YM" type="text" class="textBox2"  maxlength="5" size="7" value='${SYS_YM}'/>
		</td>
		<td class="tbYellow" width="10%" >
			轉帳組別
		</td>
		<td class="tbYellow2" width="35%">
			<select id="TRANS_GROUP">
				<option value="">全部</option>
				<c:forEach items="${TRANS_GROUP_List}" var="row">
					<option value="${row.key}">
						${row.value}
					</option>
				</c:forEach>
			</select> 
		</td>
		<td class="tbYellow2" width='10%' align='center' rowspan = '2'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
			<input id="BTN_export" type="button" value="匯出" class="button"> 
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="12%" >
			單位別
		</td>
		<td class="tbYellow2" width="10%">
			<select id="INPUT_DEPT">
				<option value="">全部</option>
				<c:forEach items="${INPUT_DEPT_List}" var="row">
					<option value="${row.key}">
						${row.value}
					</option>
				</c:forEach>
			</select> 
		</td>
		<td class="tbYellow" width='10%'>
			轉帳銀行
		</td>
		<td class="tbYellow2" width="35%">
			<select id="TRANS_BANK">
				<option value="">全部</option>
				<c:forEach items="${BANK_List}" var="row">
					<option value="${row.key}">
						${row.value}
					</option>
				</c:forEach>
			</select> 
		</td>
	</tr>
</table>

<table id="grid" class="grid"></table>

</form>		
</body>
</html>