<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<!--
程式：DSC31400.jsp
功能：關係企業扣薪
作者：林秉宏
完成：2012/11/19
 -->

<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/calendar.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>

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
<script type='text/javascript'>

	// 產生畫面物件
	var dsc31400 = new DSC31400();
	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', dsc31400.initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
	
	//--------------------------------------------------------------------------
	function DSC31400() {
	
		var grid1, grid2;
		var valid;

		//按鈕權限
		var buttonAuth = function() {			
		
			var authButtons = { 	
				B0001:'BTN_queryconfirm'	<%--扣款確認--%>,
				B0028:'BTN_confirm1'		<%--確認--%>,
				B0152:'BTN_confirm2'		<%--入帳作業--%>
			};
			
			<dz:grantButtons FUNC_ID='DSC31400'/>
		};	
		
		//共用AJAX
		var ajaxPost = function( actionName, params, successAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC3_1400/' + actionName,
			{  
				parameters: params, 
				onSuccess: function(response)
				{
					successAction(response.responseJSON);
				}
			});
		};
		
		//檢核
		var initValidation = function()
		{	
			valid = new Validation('form1', { focusOnError:true, immediate:false , mode : 'validator'});
		};		
		
		var actions = {		
		
			//扣款確認
			doQueryconfirm : function(){	
				
				//查詢條件檢核	
				if(!valid.validate()){ 
					return; 
				}
				
				ajaxPost( 'queryconfirm' , { reqMap : Object.toJSON(reqMap()) },
					function(resp){		
						$w('TOT_CNT SUCC_CNT RE_CNT FAIL_CNT').each(
							function(id){
								$(id + "_SPAN").update('');
							}
						);
						$w('TOT_AMT SUCC_AMT RE_AMT FAIL_AMT').each(
							function(id){
								$(id + "_SPAN").update( '');
							}
						);
						$w('I_TOT_CNT I_SUCC_CNT I_FAIL_CNT').each(
							function(id){
								$(id + "_SPAN").update('');
							}
						);
						$w('I_TOT_AMT I_SUCC_AMT I_FAIL_AMT').each(
							function(id){
								$(id + "_SPAN").update('');
							}
						);
						if (CSRUtil.isSuccess(resp)){
							grid1.load(resp.rtnList || [], resp.totalList || []); //[{text:"總金額：", value:resp.rtnMap}]
							grid2.load([]);				
						} else {
							grid1.load([]);
							grid2.load([]);	
						}						
					}
				);
			},
			
			//確認
			doConfirm1 : function(){

				//頁面有勾選的值為1	沒勾選的值為0				
				var allRecords = grid1.getAllRecords();
				//勾選欄位CHECK_A預設值為 '0'
				allRecords.each(
					function(data) {
						data['CHECK_A'] = '0';
					}
				);
				//若有勾選則修改值為 '1'
				grid1.getCheckedRecord().each(
					function(data) {
						var serNo = data['SER_NO'];
						allRecords[serNo - 1]['CHECK_A'] = '1'; //allRecords[serNo - 1].CHECK_A
					}
				);

				ajaxPost( 'confirm1' , { DATA_LIST : Object.toJSON(allRecords) }, 
					function(resp){
						if (CSRUtil.isSuccess(resp)){
							var rtnMap = resp.rtnMap;  //載入C區
							$w('TOT_CNT SUCC_CNT RE_CNT FAIL_CNT').each(
								function(id){
									$(id + "_SPAN").update(rtnMap[id ] + "件" || '0');
								}
							);
							$w('TOT_AMT SUCC_AMT RE_AMT FAIL_AMT').each(
								function(id){
									$(id + "_SPAN").update(gridFmtRender(rtnMap[id]) + "元" || '0');
								}
							);
						}	
					}
				);				
			},
			
			//入帳作業
			doConfirm2 : function(){

				ajaxPost( 'confirm2' , { reqMap : Object.toJSON(reqMap()) }, 
					function(resp){
						if (CSRUtil.isSuccess(resp)){
						    $w('TOT_CNT SUCC_CNT RE_CNT FAIL_CNT').each(
								function(id){
									$(id + "_SPAN").update('');
								}
							);
							$w('TOT_AMT SUCC_AMT RE_AMT FAIL_AMT').each(
								function(id){
									$(id + "_SPAN").update('');
								}
							);	
							
							if(resp.IS_USE_BATCH == 'N'){ //線上即時入帳
								var rtnMap = resp.rtnMap;  //載入D區
								$w('I_TOT_CNT I_SUCC_CNT I_FAIL_CNT').each(
									function(id){
										$(id + "_SPAN").update(rtnMap[id] + "件" || '0');
									}
								);
								$w('I_TOT_AMT I_SUCC_AMT I_FAIL_AMT').each(
									function(id){
										$(id + "_SPAN").update(gridFmtRender(rtnMap[id]) + "元" || '0');
									}
								);
							}
						}
					}
				);				
			},
		
			//扣薪查詢
			doQuery : function(){	
				
				ajaxPost( 'query' , { reqMap : Object.toJSON(reqMap()) },
					function(resp){		
						if (CSRUtil.isSuccess(resp)){
						    grid1.load([]) ;
							grid2.load(resp.rtnList2 || []);
							$w('TOT_CNT SUCC_CNT RE_CNT FAIL_CNT').each(
								function(id){
									$(id + "_SPAN").update( '');
								}
							);
							$w('TOT_AMT SUCC_AMT RE_AMT FAIL_AMT').each(
								function(id){
									$(id + "_SPAN").update('');
								}
							);
							var BillinInfo = resp.BillinInfo;  //載入D區
							$w('I_TOT_CNT I_SUCC_CNT I_FAIL_CNT').each(
								function(id){
									$(id + "_SPAN").update(BillinInfo[id] + "件" || '0');
								}
							);
							$w('I_TOT_AMT I_SUCC_AMT I_FAIL_AMT').each(
								function(id){
									$(id + "_SPAN").update(gridFmtRender(BillinInfo[id]) + "元" || '0');
								}
							);
						} else {
						    grid1.load([]) ;
							grid2.load([]) ;
							$w('TOT_CNT SUCC_CNT RE_CNT FAIL_CNT').each(
								function(id){
									$(id + "_SPAN").update('');
								}
							);
							$w('TOT_AMT SUCC_AMT RE_AMT FAIL_AMT').each(
								function(id){
									$(id + "_SPAN").update('');
								}
							);
							
							$w('I_TOT_CNT I_SUCC_CNT I_FAIL_CNT').each(
								function(id){
									$(id + "_SPAN").update('');
								}
							);
							$w('I_TOT_AMT I_SUCC_AMT I_FAIL_AMT').each(
								function(id){
									$(id + "_SPAN").update('');
								}
							);
						}
						
					}
				);
			}		 														
		};
		
		//金額格式化
		var gridFmtRender = function(value) {
			return value ? CSRUtil.$fmt(value, '#,##0.####', 0) : '';
		};		
		
		//產生查詢回傳資料
		var reqMap = function(){
		
			var reqMap = {};

			$$('#form1 input[type!="button"]').each(
				function(text){
					reqMap[text.id] = text.value;
				}
			);
			
			$$('#form1 select').each(
				function(text){
					reqMap[text.id] = text.value;
				}
			);
			
			return reqMap;
			
		};
		
	
		return{
		
			initApp  : function(){		
				
				PageUI.createPageWithAllBodySubElement( 
					'DSC31400' , 
					'扣薪作業' ,		
					'關係企業扣薪'				
				);
				
				//產生 Grid1 物件	
				grid1 = new TableUI(
					{	
						table: $("grid1"), pageSize:10, allSortable:false, overDiv:true, title:"扣薪確認結果", autoCheckBox:{text:'請選擇', isSelectAll:true},
						<%--[20241101] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:'借款人姓名', key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"}},
							{header:'繳款期數', key:'PAY_TERM'},
							{header:'扣薪金額', key:'DUTY_PAYMT',
							    renderInCount: true, render:function( record, value ) {																		
									return gridFmtRender(value);
								}
							}												
						]					
					}
				);
				
				//產生 Grid2 物件	
				grid2 = new TableUI(
					{	
						table: $("grid2"), pageSize:10, allSortable:false, overDiv:true, title:"扣薪查詢結果",
						<%--[20241101] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:'借款人姓名', key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"}},
							{header:'繳款期數', key:'PAY_TERM'},
							{header:'扣薪金額', key:'REAL_PAYMT',
								render:function( record, value ) {																		
									return gridFmtRender(value);
								}
							},
							{header:'扣薪狀況', key:'SALARY_STATUS',
								render: function(record, value){
									return record.SALARY_STATUS == '1' ? "扣薪失敗" : "扣薪成功";
								}
							}													
						]					
					}
				);										

				initValidation();				
								
				//扣款確認
				$('BTN_queryconfirm').observe('click', actions.doQueryconfirm );
				
				//確認
				$('BTN_confirm1').observe('click' , actions.doConfirm1);
					
				//入帳作業
				$('BTN_confirm2').observe('click', actions.doConfirm2 );  
				
				//扣薪查詢
				$('BTN_query').observe('click', actions.doQuery );  

				autoFormatToNumber();			
				buttonAuth();			 
				PageUI.resize();	
				displayMessage();	
							
			} //end init()--
		}; //end return--
	
	}

</script>
</head>
<body>
<form name="form1" id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
	<tr>
		<td class="tbYellow">
			關係企業
		</td>
		<td class="tbYellow2"  width="15%">
			<select id="CATHAY_GROUP" >					
				<c:forEach items="${CATHAY_List}" var="row">
					<option value="${row.key}" <c:if test="${row.key eq '90'}">selected</c:if> />	<%-- 預設為國泰建設 --%>
						${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
		<td class="tbYellow">
			工作年月
		</td>
		<td class="tbYellow2" width="15%">
			<%-- 工作年月限輸入數字 --%>
			<input type="text" class='textBox2' id="WORK_YM" datatype='number' pattern='#####' size='7' maxLength='5' value="${WORK_YM}" />  				
		</td>
		<td class="tbYellow2" align="center">
			<%-- 扣款確認 --%>
			<input id="BTN_queryconfirm" type="button" class="button" value="扣款確認" /> 
			<%-- 入帳作業 --%>
			<input id="BTN_confirm2" type="button" class="button" value="入帳作業" />
			<%-- 扣薪查詢 --%>
			<input id="BTN_query" type="button" class="button" value="扣薪查詢" />
		</td>
	</tr>

	<tr>
		<td class="tbYellow2" colspan="5" align="center">
			<%-- 確認 --%>
			<input id="BTN_confirm1" type="button" class="button" value="確認" />
		</td>
	</tr>
</table>

<table id="grid1" class="grid1"></table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
	<tr>
		<td class="tbYellow0" align="center" colspan="4">
			<b>作業完成</b>
		</td>
	</tr>
		
	<tr align="center">
		<td class="tbYellow" width="15%" align="center">
			總件數：
		</td>
		<td class="tbYellow2" width="15%" align="center">			
			<span id="TOT_CNT_SPAN"></span>
		</td>
		<td class="tbYellow" width="15%" align="center">
			總金額：
		</td>
		<td class="tbYellow2" >			
			<span id="TOT_AMT_SPAN"></span>
		</td>
	</tr>
	
	<tr>
		<td class="tbYellow"  align="center">
			扣款完成件數：
		</td>
		<td class="tbYellow2" align="center">			
			<span id="SUCC_CNT_SPAN"></span>
		</td>
		<td class="tbYellow"  align="center">
			扣款完成金額：
		</td>
		<td class="tbYellow2" align="center">			
			<span id="SUCC_AMT_SPAN"></span>
		</td>
	</tr>
	
	<tr>
		<td class="tbYellow"  align="center">
			重複輸入件數：
		</td>
		<td class="tbYellow2" align="center">			
			<span id="RE_CNT_SPAN"></span>
		</td>
		<td class="tbYellow" align="center">
			重複輸入金額：
		</td>
		<td class="tbYellow2" align="center">			
			<span id="RE_AMT_SPAN"></span>
		</td>
	</tr>
	
	<tr>
		<td class="tbYellow"  align="center">
			扣款未成件數：
		</td>
		<td class="tbYellow2" align="center">			
			<span id="FAIL_CNT_SPAN"></span>
		</td>
		<td class="tbYellow"  align="center">
			扣款未成金額：
		</td>
		<td class="tbYellow2" align="center">			
			<span id="FAIL_AMT_SPAN"></span>
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
	<tr>
		<td class="tbYellow0" align="center" colspan="4">
			<b>入帳成功</b>
		</td>
	</tr>
		
	<tr>
		<td class="tbYellow" width="15%" align="center">
			入帳總件數：
		</td>
		<td class="tbYellow2" width="15%" align="center">			
			<span id="I_TOT_CNT_SPAN"></span>
		</td>
		<td class="tbYellow" width="15%" align="center">
			入帳總金額：
		</td>
		<td class="tbYellow2" align="center">			
			<span id="I_TOT_AMT_SPAN"></span>
		</td>
	</tr>
	
	<tr>
		<td class="tbYellow"  align="center">
			入帳完成件數：
		</td>
		<td class="tbYellow2"  align="center">			
			<span id="I_SUCC_CNT_SPAN"></span>
		</td>
		<td class="tbYellow"  align="center">
			入帳完成金額：
		</td>
		<td class="tbYellow2" align="center">			
			<span id="I_SUCC_AMT_SPAN"></span>
		</td>
	</tr>
	
	<tr>
		<td class="tbYellow"  align="center">
			入帳未成件數：
		</td>
		<td class="tbYellow2"  align="center">			
			<span id="I_FAIL_CNT_SPAN"></span>
		</td>
		<td class="tbYellow"  align="center">
			入帳未成金額：
		</td>
		<td class="tbYellow2" align="center">			
			<span id="I_FAIL_AMT_SPAN"></span>
		</td>
	</tr>
</table>

<table id="grid2" class="grid2"></table>

</form>
</body>
</html>