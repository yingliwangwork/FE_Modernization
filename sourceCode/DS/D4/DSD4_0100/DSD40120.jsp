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
程式：DSD40120.jsp
功能：清償證明預覽作業
作者：林秉宏
完成：2013/08/07

[20190725]問題單(20190724163837) ：有被嵌入DSD40101，頁籤需撐開為全版畫面
[20191113] 陳思涵    申請書-191001000815：清償塗銷同意書改版暨清償作業欄位及簽收條調整	

[20240328]
難字調整
高強禾
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<%-- [20240328] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSD40120().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSD40120(){	

		var grid;
		var valid;
		var D070Map;
		
		
		
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0028 : 'BTN_confirm'		<%--確認--%>	
			};
			<dz:grantButtons FUNC_ID='DSD40120'/>
		};
		
		// 檢核
		var initValidation = function(){	

			valid = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid.define( "required" , [{ id : "PRINT_DATE", errMsg : '請輸入印製日期!' } ] );
			valid.define( "required" , [{ id : "SET_DATE", errMsg : '請輸入設定日期!' } ] );
			valid.define( "validate-ROCDate" , [{ id : "PRINT_DATE" , errMsg:"印製日期非正確民國日期格式，請重新輸入" } ] );
			valid.define( "validate-ROCDate" , [{ id : "SET_DATE" , errMsg:"設定日期非正確民國日期格式，請重新輸入" } ] );
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSD4_0120/' + actionName,
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
				
				var reqMap = {
					LOAN_ID : '${LOAN_ID}'
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
			
			// 查詢清償附件二貸款金額資料
			doQueryD070: function(){
				
				valid.reset();
				
				var chkList = grid.getCheckedRecord();

				// 頁面傳入參數
				ajaxPost( 'queryD070' , { 'checkList' : Object.toJSON(chkList) },
					function(resp){				
						setValues(resp);
					}
				);	
			},
			
			// 確認
			doConfirm: function(){
				
				var rtnList = grid.getAllRecords();
				if(rtnList.length==0){
					alert("無資料，無法進行確認作業");
					return;
				}
				
				var chkList = grid.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行確認作業");
				  	return;
				}
				
				// 檢核
				if(!valid.validate()){ 
					return; 
				}
				
				var rtnMap = chkList[0];
				
				
				var dataMap = {
					LOAN_ID : D070Map['LOAN_ID'],
					APPLY_ID : D070Map['APPLY_ID'],
					RECEIVE_ID : D070Map['RECEIVE_ID'],
					INPUT_ID : D070Map['INPUT_ID'],
					INPUT_DATE : D070Map['INPUT_DATE'],
					LAND_OFFICE : $F('LAND_OFFICE'),
					PRINT_DATE : toY2K($F('PRINT_DATE')),
					SET_AMT : fmtRemove($F('SET_AMT')),
					SET_DATE : toY2K($F('SET_DATE')),
					//[20191113]新增RIGHT_TYPE
					RIGHT_TYPE : $$('[name="RIGHT_TYPE"]:checked')[0].getValue()
				}

				var errMsg = '確認要執行確認作業';
				
				if (!errMsg || confirm(errMsg)) {
					// 頁面傳入參數
					ajaxPost( 'confirm' , {'checkList' : Object.toJSON(chkList), 'D070Map' : Object.toJSON(dataMap) },
						function(resp){
							setValues(resp);
						}
					);	
				}
			},
			
			// 上一頁
			doBack : function(event){
				if( parent.popupWin ){
		  	       if( parent.popupWin.func ) { parent.popupWin.func(); }
				     parent.popupWin.close();
				} else {
					CSRUtil.linkBack(); 
				}
			}
		};

		// 清償附件二貸款金額資料輸入區塊
		var setValues = function(resp) {
			
			$('PROOF_NO').innerHTML = resp.rtnMap['PROOF_NO'] || '';
			
			D070Map = resp.D070Map;
			$w('LOAN_ID BORROW_NAME BORROW_ID RECEIVE_ID INPUT_ID_NAME CHANGE_ID_NAME').each(
				function(id) {		
					if (id == 'BORROW_ID'){
						$(id).innerHTML = CSRUtil.maskHandler.getMaskID(D070Map[id]) || '';
					}else{
						$(id).innerHTML = D070Map[id] || '';
					}						
				}
			);
			
			$w('INPUT_DATE CHANGE_DATE').each(
				function(id) {		
					$(id).innerHTML = Date.toROC(D070Map[id] || '');						
				}
			);
			
			$('LAND_OFFICE').value = D070Map['LAND_OFFICE'] || '';
			$('PRINT_DATE').value = Date.toROC(D070Map['PRINT_DATE'] || '');
			$('SET_DATE').value = Date.toROC(D070Map['SET_DATE'] || '');
			if (D070Map['SET_AMT'] || D070Map['SET_AMT'] === 0){
				$('SET_AMT').value = gridFmtRender(D070Map['SET_AMT']);
			}
			
			//[20191113]新增RIGHT_TYPE
			var RIGHT_TYPE = D070Map['RIGHT_TYPE'];
			if(RIGHT_TYPE) {
				$$('[name="RIGHT_TYPE"]').each(function(e) {
					if(e.value == RIGHT_TYPE) {
						e.checked = true;
					}
				});
			} 
			
			
			
			
			
		};
		
		// 金額格式化
		var gridFmtRender = function(value) { 
			return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : ''; 
		};
		
		// 移除逗號
		var fmtRemove = function(value) {
		
			return value.replace(/,/g, "");
		};
		
		return {
			
			initApp : function() {
				<%-- [20190725]問題單 ：頁籤超出頁面需撐開為全版畫面--%>
				<c:if test="${titleNotDisplay eq 'Y'}">
				PageUI.createPageWithAllBodySubElement(
					'DSD40120' ,
					'清償作業' , 
					'清償證明預覽作業' ,
					0 ,
					true
				);		
				</c:if>
				<c:if test="${titleNotDisplay ne 'Y'}">
				PageUI.createPageWithAllBodySubElement(
					'DSD40120' ,
					'清償作業' , 
					'清償證明預覽作業',
					1,
					false
				);	
				</c:if>	
							
				
				// 產生 grid 物件	
				grid = new TableUI(
					{	
						table: $('grid'), allSortable:true, overDiv:false,
						autoCheckBox:{
							type:'radio', 
						    action:function(node, boxStatus, records ){
						    	if(boxStatus){
						    		actions.doQueryD070();
						    	}
							}
						},
		            	<%-- [20240328] 難字調整 --%>
		            	afterLoad: function() {
		            		if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
		            	},
		            	pageChange: function() {
		            		if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
		            	},
						column:[
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:'受理編號', key:'APPLY_ID'},		
							<%-- [20240328] 難字調整：借款人姓名 --%>
							{header:'借款人姓名', key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
							{header:'收件字號', key:'RECEIVE_ID'},
							{header:'設定金額', key:'SET_AMT', attrs:{align:'right'},
								render:function( record, value ) {																		
									return gridFmtRender(value);
								}
							},
							{header:'抵銷編號', key:'PROOF_NO'}
						]						
					}
				);							
					
				initValidation();
				
				// 確認
				$('BTN_confirm').observe('click', actions.doConfirm);
				
				// 上一頁
				$('BTN_back').observe('click', actions.doBack);
				
				actions.doQuery();

				buttonAuth();
				autoFormatToNumber();
	
				PageUI.resize();
				displayMessage();
		
			} // end initApp()		
		}; // end return
	}

</script>
</head>
<body>

<form id="form1" name="form1" style="PADDING: 0px; MARGIN: 0px;">

<table id="grid" class="grid"></table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width='10%'>
			貸款帳號
		</td>
		<td class="tbYellow2" width="23%">
			<span id="LOAN_ID"></span>
		</td>
		<td class="tbYellow" width='10%'>
			借款人姓名
		</td>
		<td class="tbYellow2" width="23%">
			<%-- [20240328] 難字調整：借款人姓名 --%>
			<span id="BORROW_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow" width='10%'>
			借款人ID
		</td>
		<td class="tbYellow2" width="23%">
			<span id="BORROW_ID"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			收件字號
		</td>
		<td class="tbYellow2" colspan="5">
			<span id="RECEIVE_ID"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			地政事務所
		</td>
		<td class="tbYellow2" >
			<input id="LAND_OFFICE" type="text" size='30'/>
		</td>
		<%--[20191113]增加權利種類選單--%>
		<td class="tbYellow">
			權利種類
		</td>
		<td class="tbYellow2" colspan="3">
			<c:forEach items="${RIGHT_TYPE_MAP}" var="map">
				<input type="radio" name="RIGHT_TYPE" value="${map.key}">${map.value}</option>
			</c:forEach>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			抵銷編號
		</td>
		<td class="tbYellow2">
			<span id="PROOF_NO"></span>
		</td>
		<td class="tbYellow">
			印製日期
		</td>
		<td class="tbYellow2" colspan="3">
			<input id="PRINT_DATE" type="text" datatype="ROCdate" size="9" maxLength ="7"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			設定金額
		</td>
		<td class="tbYellow2">
			<input id="SET_AMT" type="text" datatype="number" size="13" maxLength ="11"/>
		</td>
		<td class="tbYellow">
			設定日期
		</td>
		<td class="tbYellow2" colspan="3">
			<input id="SET_DATE" type="text" datatype="ROCdate" size="9" maxLength ="7"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			輸入人員
		</td>
		<td class="tbYellow2">
			<%-- [20240328] 難字調整：輸入人員 --%>
			<span id="INPUT_ID_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow">
			輸入日期
		</td>
		<td class="tbYellow2" colspan="3">
			<span id="INPUT_DATE"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			覆核人員
		</td>
		<td class="tbYellow2">
			<%-- [20240328] 難字調整：覆核人員 --%>
			<span id="CHANGE_ID_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow">
			覆核日期
		</td>
		<td class="tbYellow2" colspan="3">
			<span id="CHANGE_DATE"></span>
		</td>
	</tr>
	<tr>
		<td colspan="6" align="center">
			 <input id="BTN_confirm" type="button" class="button" value='確認' /> 
			 <input id="BTN_back" <c:if test="${titleNotDisplay eq 'Y'}">type="hidden"</c:if><c:if test="${titleNotDisplay ne 'Y'}">type="button"</c:if> class="button" value='回上一頁' /> 
		</td>
	</tr>
</table>

</form>		
</body>
</html>