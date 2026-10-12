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
程式：DSD40300.jsp
功能：清償審核作業
作者：林秉宏
完成：2013/08/19

[20240326]
難字調整
高強禾
 -->

<%-- [20190409] 清償作業優化(第二階段) - 刪除列印(列印清償證明簽收條)按鈕--%>
<%-- [20221205] 問題單編號20220802-0120 : 清償審核刪除優化，
  1. 刪除時跳出確認視窗，避免誤刪
  2. 鎖定短時間僅能點擊一次
--%>

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script><%-- 匯出PDF用--%>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<%-- [20240326] 難字調整 --%>
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
	Event.observe(window, 'load', new DSD40300().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSD40300(){	

		var grid;
		var valid;
		
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0028 : 'BTN_confirm',		<%--確認--%>	
				B0005 : 'BTN_delete'		<%--刪除--%>	
			};
			<dz:grantButtons FUNC_ID='DSD40300'/>
		};
		
		// 檢核
		var initValidation = function(){	

			valid = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkLength', '貸款帳號長度需為10碼!', function( v ) { return chkLength($F('LOAN_ID'));}],
				[ 'chkLength2', '借款人ID長度需為10碼!', function( v ) { return chkLength($F('BORROW_ID'));}]
			] );
			valid.define( "chkLength" , [{ id : "LOAN_ID" } ] );
			valid.define( "chkLength2" , [{ id : "BORROW_ID" } ] );
		};
		
		// 檢核帳號長度
		var chkLength = function (ID) 
		{		
			var chk = true;
			if(ID && ID.length != 10) {
				chk = false; 
			}
			return chk; 	
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSD4_0300/' + actionName,
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
				
				// 檢核
				//if(!$F('LOAN_ID') && !$F('BORROW_ID') && !$F('BORROW_NAME')){
				//	alert("貸款帳號.借款人ID.借款人姓名請至少輸入一欄再執行查詢作業");
				//	return;
				//}
				
				var reqMap = {
					CRED_DEPT : $F('CRED_DEPT'),
					AUDIT_ID : $F('AUDIT_ID'),
					LOAN_ID : $F('LOAN_ID'),
					BORROW_ID : $F('BORROW_ID'),
					BORROW_NAME : $F('BORROW_NAME'),
					linkFrom:$F('linkFrom')
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'info' : Object.toJSON(reqMap) },
					function(resp){			
						grid.load(resp.rtnList || []);
						$('CRED_DEPT_OLD').value = $F('CRED_DEPT');
						$('AUDIT_ID_OLD').value = $F('AUDIT_ID');
						$('LOAN_ID_OLD').value = $F('LOAN_ID');
						$('BORROW_ID_OLD').value = $F('BORROW_ID');
						$('BORROW_NAME_OLD').value = $F('BORROW_NAME');
					},function(resp){
						grid.load([]);
						$('CRED_DEPT_OLD').value = '';
						$('AUDIT_ID_OLD').value = '';
						$('LOAN_ID_OLD').value = '';
						$('BORROW_ID_OLD').value = '';
						$('BORROW_NAME_OLD').value = '';
					}
				);	
			},
			
			// 確認
			doConfirm: function(){
				
				var rtnList = grid.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行確認作業");
					return;
				}
				
				var chkList = grid.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行確認作業");
				  	return;
				}
				
				valid.reset();
				
				var reqMap = {
					CRED_DEPT : $F('CRED_DEPT_OLD'),
					AUDIT_ID : $F('AUDIT_ID_OLD'),
					LOAN_ID : $F('LOAN_ID_OLD'),
					BORROW_ID : $F('BORROW_ID_OLD'),
					BORROW_NAME : $F('BORROW_NAME_OLD')
				}
				
	            //[20221205]鎖定同時僅能點擊一次
				 $('BTN_confirm').disabled = true;
				
				<%--[20190409] 確認後要多做重查--%>
				// 頁面傳入參數
				ajaxPost( 'confirm' , { 'chkList' : Object.toJSON(chkList), 'info' : Object.toJSON(reqMap)},
					function(resp){			
						grid.load(resp.rtnList || []);
						$('BTN_confirm').disabled = false;
					},function(resp){
						$('BTN_confirm').disabled = false;
					}
				);	
			},
			
			// 刪除
			doDelete: function(){
				
				var rtnList = grid.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行刪除作業");
					return;
				}
				
				var chkList = grid.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行刪除作業");
				  	return;
				}
	            
	            //[20221205] 刪除時跳出確認視窗，避免誤刪
	            if(!confirm('請確認是否要刪除？')){
				  	return;
				}
	            
				
				valid.reset();
				
				var reqMap = {
					CRED_DEPT : $F('CRED_DEPT_OLD'),
					AUDIT_ID : $F('AUDIT_ID_OLD'),
					LOAN_ID : $F('LOAN_ID_OLD'),
					BORROW_ID : $F('BORROW_ID_OLD'),
					BORROW_NAME : $F('BORROW_NAME_OLD')
				}
				
	            //[20221205]鎖定同時僅能點擊一次
				 $('BTN_delete').disabled = true;
				
				// 頁面傳入參數 
				ajaxPost( 'delete' , { 'chkList' : Object.toJSON(chkList), 'info' : Object.toJSON(reqMap) },
					function(resp){			
						grid.load(resp.rtnList || []);
						$('BTN_delete').disabled = false;
					},function(resp){
						grid.load([]);
						$('BTN_delete').disabled = false;
					}
				);
			},
			<%-- [20190409] 清償作業優化(第二階段) - 列印簽收條
			(因為總公司的清償案件目前不進抵押權塗銷申請DSF01300流程，因此在此畫面開放總公司的案件可以列印簽收條) --%>
			doSignPrint : function(){
				var rec=grid.getCheckedRecord();
				
				if(rec.length == 0){
					alert("請先選取明細!");
					return ;
				}
				
				var dataList = [];
				rec.each(function(data){
					var reqMap = {
						REFER_ID : data.LOAN_ID,
						CRED_DEPT : data.CRED_DEPT
					};
					dataList.push(reqMap);
				});
				
				
				RPTUtil.downloadFile('${dispatcher}/DSD4_0310/prompt',
					{
						source : 'DSD40300',
						dataList : Object.toJSON(dataList)
					},
					true
				);
			},
			// 超連結
			doLink : function(linkTo, LOAN_ID, ACTION_TYPE){
			
				var LP_JSON = {				
					action : '<%=dispatcher%>/'+linkTo+'/prompt',
					LOAN_ID : LOAN_ID,
					ACTION_TYPE : ACTION_TYPE
				};
						
				CSRUtil.linkTo(LP_JSON , 'form1');		
			}
		};
		<%--[20190409] 清償作業優化(第二階段) 移除程式碼getCheckedMap--%>

		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSD40300' ,
					'清償作業' , 
					'清償審核作業'
				);			
				
				// 產生 grid 物件	
				grid = new TableUI(
					{	
						table: $('grid'), pageSize: 10,allSortable:true, overDiv:true,
						autoCheckBox:{isSelectAll:true, text:"選取"}, <%--[20190409] 換成多選checkbox--%>
						<%-- [20240326] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:"借款人<BR>ID", key:'BORROW_ID',
								render : function (rec , val){
									return CSRUtil.maskHandler.getMaskID(val);
							}},
							<%-- [20240326] 難字調整：借款人姓名 --%>
							{header:'借款人<BR>姓名', key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
							{header:'契約狀況', key:'LOAN_STATUS_NM'},
							{header:'輸入日期', key:'INPUT_DATE',
								render : function (rec , val){
									return Date.toROC(val || "");									
								}
							},
							{header:'輸入時間', key:'INPUT_TIME',
								render : function (rec , val){
											return val.substr(0,19);
								}
							},
							{header:'清償附件分頁', key:'',
								render:function( record, value ) {
									var link = new Element('a', { href : '#' } );
									link.onclick = function() {
										actions.doLink('DSD4_0101', record.LOAN_ID, 'Q');
									} ;
									link.update('附件');
									return link ;
								}
							},
							{header:'補發', key:'PAYOFF_LIMIT',
								render : function (record , value){
									if(value == '7') {
										return 'V';
									} else {
										return '';
									}
								}
							},
							<%-- [20240326] 難字調整：清償人員 --%>
							{header:'清償人員', key:'EMP_NAME', attrs:{ style:"font-family:'EUDC'" }}
						]						
					}
				);								
					
				initValidation();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
				
				// 確認
				$('BTN_confirm').observe('click', actions.doConfirm);
				
				// 刪除
				$('BTN_delete').observe('click', actions.doDelete);
				
				<%--[20190410] 清償作業優化(第二階段) - 列印簽收條--%>
				$('BTN_signPrint').observe('click', actions.doSignPrint);
				
				// 下拉選單控制
				//$("CRED_DEPT").disable();
				
				<%-- [2019/04/02] 清償作業優化(第二階段) - 承辦科別改為"非總公司"與"總公司"，取消承辦科別預設--%>
				if ("${LOGIN_CRED_DEPT}" && "${LOGIN_CRED_DEPT}" != '' && "${LOGIN_CRED_DEPT}" != '0' ){
					$("CRED_DEPT").value = "${LOGIN_CRED_DEPT}";
				}
	
				if ("${LOGIN_AUDIT_ID}" && "${LOGIN_AUDIT_ID}" != '' && "${LOGIN_AUDIT_ID}" != '0' ){
					$("AUDIT_ID").setValue("${LOGIN_AUDIT_ID}");
				}
				buttonAuth();
	
				PageUI.resize();
				displayMessage();
				if(CSRUtil.isBackLink('form1') || $F('linkFrom') == 'AMI01000'){  
				      
					actions.doQuery();  
				}
			} // end initApp()		
		}; // end return
	}

</script>
</head>
<body>

<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
<input type="hidden" id="linkFrom" name="linkFrom" value="${linkFrom}"/>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width='10%'>
			承辦科別
		</td>
		<td class="tbYellow2" width="13%">
			<select id="CRED_DEPT" name = "CRED_DEPT">
				<c:forEach items="${CRED_DEPT_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
			<input id="CRED_DEPT_OLD" name = "CRED_DEPT_OLD" type="hidden">
		</td>
		<td class="tbYellow" width='10%'>
			清償人員
		</td>
		<td class="tbYellow2" width="13%">
			<%-- [20240326] 難字調整：清償人員 --%>
			<select id="AUDIT_ID" name = "AUDIT_ID" alt="ch">
				<option value="">全部</option>	
				<c:forEach items="${AUDIT_ID_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
			<input id="AUDIT_ID_OLD" name = "AUDIT_ID_OLD" type="hidden">
		</td>
		<td class="tbYellow" width='10%'>
			貸款帳號
		</td>
		<td class="tbYellow2" width="13%">
			<input id="LOAN_ID" name = "LOAN_ID" type="text" class="textBox2"  onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="LOAN_ID_OLD" name = "LOAN_ID_OLD" type="hidden">
		</td>
		<td class="tbYellow" width='10%'>
			借款人ID
		</td>
		<td class="tbYellow2" width="13%">
			<input id="BORROW_ID" name = "BORROW_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="BORROW_ID_OLD" name = "BORROW_ID_OLD" type="hidden">
		</td>
		<td class="tbYellow" width='10%'>
			借款人姓名
		</td>
		<td class="tbYellow2" width="13%">
			<%-- [20240326] 難字調整：借款人姓名 --%>
			<input id="BORROW_NAME" name = "BORROW_NAME" type="text" class="textBox2" size="12" alt="ch" />
			<input id="BORROW_NAME_OLD" name = "BORROW_NAME_OLD"type="hidden">
		</td>
		<td class="tbYellow2" width='8%' align='center'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
		</td>
	</tr>
	<tr>
		<td colspan="9" align="center">
			<input id="BTN_confirm" type="button" class="button" value='確認' /> 
			<input id="BTN_delete" type="button" class="button" value='刪除' />
			<input id="BTN_signPrint" type="button" class="button" value='列印簽收條(總公司)' />
		</td>
	</tr>
</table>
</form>
<table id="grid" class="grid"></table>
</body>
</html>