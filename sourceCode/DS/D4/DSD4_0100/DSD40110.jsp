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
程式：DSD40110.jsp
功能：清償附件二處理作業
作者：林秉宏
完成：2013/08/06
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
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/suggest.js'></script>
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
	Event.observe(window, 'load', new DSD40110().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSD40110(){	

		var gridB, gridD;
		var valid1, valid2, valid3;
		
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0231 : 'BTN_update',		<%--承辦--%>		
				B0028 : 'BTN_confirm'		<%--確認--%>	
			};
			<dz:grantButtons FUNC_ID='DSD40110'/>
		};
		
		// 檢核
		var initValidation = function(){	

			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkLength1', '貸款帳號長度需為10碼!', function( v ) { return chkLength($F('LOAN_ID_Q'));}]
			] );
			valid1.define( "chkLength1" , [{ id : "LOAN_ID_Q" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });	
			valid2.define( "required" , [{ id : "RECEIVE_DEPT", errMsg : '請輸入領取單位!' } ] );
			valid2.define( "required" , [{ id : "NOT_PAY_QTY", errMsg : '請輸入未清償件數!' } ] );
			valid2.define( "required" , [{ id : "OTHER_RIGHT_QTY", errMsg : '請輸入他項權利證明份數!' } ] );
			valid2.define( "required" , [{ id : "FIRE_QTY", errMsg : '請輸入火險單份數!' } ] );
			valid2.define( "validate-number" , { id: "NOT_PAY_QTY" , errMsg:"未清償件數非數字格式，請重新輸入" });
			valid2.define( "validate-number" , { id: "OTHER_RIGHT_QTY" , errMsg:"他項權利證明份數非數字格式，請重新輸入" });
			valid2.define( "validate-number" , { id: "FIRE_QTY" , errMsg:"火險單份數非數字格式，請重新輸入" });
			
			valid3 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid3.define( "required" , [{ id : "RECEIVE_DEPT", errMsg : '請輸入領取單位!' } ] );
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
			new Ajax.Request( '<%=dispatcher%>/DSD4_0110/' + actionName,
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
				if(!$F('LOAN_ID_Q')){
					alert("請輸入貸款帳號再執行查詢作業");
					return;
				}
				
				valid2.reset();
				valid3.reset();
				
				// 檢核
				if(!valid1.validate()){ 
					return; 
				}
				
				var reqMap = {
					LOAN_ID : $F('LOAN_ID_Q')
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'info' : Object.toJSON(reqMap) },
					function(resp){			
						gridB.load(resp.rtnList || []);
						gridD.load([]);
						$('form2').reset();
						$('dataB').select('span[field!="LIST"]').each( function(text){ text.innerHTML = ''; } );
						$('dataD').select('span[field!="LIST"]').each( function(text){ text.innerHTML = ''; } );
					},function(resp){
						gridB.load([]);
						gridD.load([]);
						$('form2').reset();
						$('dataB').select('span[field!="LIST"]').each( function(text){ text.innerHTML = ''; } );
						$('dataD').select('span[field!="LIST"]').each( function(text){ text.innerHTML = ''; } );
					}
				);	
			},
			
			// 查詢清償附件二貸款金額資料
			doQueryD050: function(){
				
				valid1.reset();
				valid2.reset();
				valid3.reset();
				
				var chkList = gridB.getCheckedRecord();

				// 頁面傳入參數
				ajaxPost( 'queryD050' , { 'checkList' : Object.toJSON(chkList) },
					function(resp){		
						gridD.load(resp.AMTList || []);		
						setValues(resp);
					},function(resp){
						gridD.load([]);
						$$('#gridB input[type=radio]:checked').each(
							function(text){
								text.checked = false;
							}
						);
						$('form2').reset();
						$('dataB').select('span[field!="LIST"]').each( function(text){ text.innerHTML = ''; } );
						$('dataD').select('span[field!="LIST"]').each( function(text){ text.innerHTML = ''; } );
					}
				);	
			},
			
			// 承辦
			doUpdate: function(){
				
				var rtnList = gridB.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行承辦作業");
					return;
				}
				
				var chkList = gridB.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行承辦作業");
				  	return;
				}
				
				valid1.reset();
				valid3.reset();
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				
				//var rtnPAYOFF_LIMIT = chkList[0]['PAYOFF_LIMIT'];
				
				var dataMap = {
					LOAN_ID : $F('LOAN_ID_HID'),
					PAYOFF_LIMIT : $F('PAYOFF_LIMIT'),
					RECEIVE_DEPT : $F('RECEIVE_DEPT'),
					RECEIVE_DEPTNO : $F('RECEIVE_DEPTNO'),
					NOT_PAY_QTY : $F('NOT_PAY_QTY'),
					<%--[20191113]刪除借據份數，借據金額欄位--%>
					OTHER_RIGHT_QTY : $F('OTHER_RIGHT_QTY'),
					<%--[20191113]刪除他項權利證明金額欄位--%>
					FIRE_QTY : $F('FIRE_QTY'),
					OTHER : $F('OTHER'),
					<%--[20200929]新增欄位--%>
					CERTIFICATE : $F('CERTIFICATE'),
					REMAIN_AMT : $F('REMAIN_AMT_E'),
					AMT_ALL : $F('AMT_ALL'),
					MEMO : $F('MEMO')
				}
				
				// 頁面傳入參數
				ajaxPost( 'update' , { 'checkList' : Object.toJSON(chkList), 'D050Map' : Object.toJSON(dataMap) },
					function(resp){
						setValues(resp);
					}
				);	
			},
			
			// 確認
			doConfirm: function(){
				
				var rtnList = gridB.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行確認作業");
					return;
				}
				
				var chkList = gridB.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行確認作業");
				  	return;
				}
				
				valid1.reset();
				valid2.reset();
				
				// 檢核
				if(!valid3.validate()){ 
					return; 
				}
				
				var rtnLOAN_ID = chkList[0]['LOAN_ID'];
				
				var dataMap = {
					LOAN_ID : $F('LOAN_ID_HID'),
					RECEIVE_DEPT : $F('RECEIVE_DEPT'),
					RECEIVE_DEPTNO : $F('RECEIVE_DEPTNO')
				}
				
				// 頁面傳入參數
				ajaxPost( 'confirm' , { 'checkList' : Object.toJSON(chkList), 'D050Map' : Object.toJSON(dataMap) },
					function(resp){
						setValues(resp);
					}
				);	
			},
			
			// 超連結
			doLink : function(AMT_LOAN_ID){
			
				var LP_JSON = {	
						action : '<%=dispatcher%>/DSH0_0307/prompt',
						LOAN_ID : AMT_LOAN_ID
					};		
				CSRUtil.linkTo(LP_JSON , 'form1');				
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
		
			var rtnMap = resp.rtnMap;
			
			var D050Map = resp.D050Map;
			
			$w('LOAN_ID BORROW_NAME BORROW_ID').each(
				function(id) {
					if (id == 'BORROW_NAME'){
						$(id).innerHTML = CSRUtil.maskHandler.getMaskName(D050Map[id]) || '';
					}else{
						$(id).innerHTML = D050Map[id] || '';
					}					
				}
			);
			
			if (D050Map['LOAN_ID']){
				$('LOAN_ID_HID').value = D050Map['LOAN_ID'];
			}
			
			$w('INPUT_DEPT_NM GETINT_DEPT_NM CHECK_ID_NAME CHECK_LEADER_NAME').each(
				function(id) {		
					$(id).innerHTML = D050Map[id] || '';						
				}
			);
			
			//[2020.09.21] 3.自動帶出客戶基本資料-聯絡電話(日間、夜間、手機)且不能修改
		    $('DAY_TEL').innerHTML = (D050Map['DAY_TEL_AREA'] || '') + '-' + (D050Map['DAY_TEL_NUM'] || '') + '#' + (D050Map['DAY_TEL_EXT'] || '') + ',' + (D050Map['MOBILE'] || '');
			
			$w('CHECK_DATE1 CHECK_DATE2').each(
				function(id) {		
					$(id).innerHTML = Date.toROC(D050Map[id] || '');						
				}
			);
			<%--[20200924] 新增欄位--%>
			$w('PAYOFF_LIMIT RECEIVE_DEPT RECEIVE_DEPTNO NOT_PAY_QTY OTHER_RIGHT_QTY FIRE_QTY OTHER NEW_QTY CERTIFICATE AMT_ALL MEMO').each(
				function(id) {		
					var D050Value = D050Map[id];
					if (D050Value === 0){
						$(id).value = D050Value;
					}else{
						$(id).value = D050Value || '';
					}					
				}
			);
			<%--[20200924] 新增欄位--%>
			$('REMAIN_AMT_E').value = D050Map.REMAIN_AMT;
			
			$w('GUARANTOR_STATUS GUARANTEE_STATUS').each(
				function(id) {						
					if (D050Map[id] == '1') {
						$(id + '_1').checked = true;										
					} else {
						$(id + '_0').checked = true; 
					}
				}
			);
			
			if (D050Map['CONTACT_STATUS']){
				$(D050Map['CONTACT_STATUS']).checked = true;
			}
			
			//[2020.09.21] 8.聯絡人欄位改為顯示領取人，及領取人姓名(不能修改)
			$('RECIPIENT_NAME').innerHTML=D050Map['RECIPIENT_NAME'] || '';
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
					'DSD40110' ,
					'清償作業' , 
					'清償附件二處理' ,
					0 ,
					true
				);		
				</c:if>
				<c:if test="${titleNotDisplay ne 'Y'}">
				PageUI.createPageWithAllBodySubElement(
					'DSD40110' ,
					'清償作業' , 
					'清償附件二處理',
					1,
					false
				);	
				</c:if>			
				
				// 產生 grid 物件
				gridB = new TableUI(
					{	
						table: $('gridB'), allSortable:true, overDiv:false,
						autoCheckBox:{isSelectAll:true, type:'radio', 
						    action:function(node, boxStatus, records ){
								actions.doQueryD050();
							},
							genRule:function( record , value ){
								//if(record.LOAN_ID == '${LOAN_ID}')才顯示radio                                
								return record.LOAN_ID == '${LOAN_ID}' ? true : false;
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
							{header:'連保帳號', key:'REMARK'},
							{header:'貸款帳號', key:'LOAN_ID'},
							<%-- [20240328] 難字調整：姓名 --%>
							{header:'姓名', key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" },
								render : function (record , value){
									return CSRUtil.maskHandler.getMaskName(value);
								}
							},
							{header:'借款人ID', key:'BORROW_ID'},
							{header:'貸款金額', key:'LOAN_AMT', attrs:{align:'right'},
								render:function( record, value ) {																		
									return gridFmtRender(value);
								}
							},
							{header:'本金餘額', key:'REMAIN_AMT', attrs:{align:'right'},
								render:function( record, value ) {																		
									return gridFmtRender(value);
								}
							},
							{header:'受理編號', key:'APPLY_ID'},
							{header:'原貸帳號', key:'REFER_ID'}
						]						
					}
				);		
				
				// 產生 grid 物件	
				gridD = new TableUI(
					{	
						table: $('gridD'), allSortable:true, overDiv:false,
						column:[
							{header:'貸款帳號', key:'LOAN_ID',
								render:function( record, value ) {									
									
									var link = new Element('a', { href : '#' });
									link.update( value );								
									
									link.onclick = function() {
										//actions.doLink(value);
										var url = "<%=dispatcher%>/DSH0_0307/prompt?LOAN_ID="+value;
										window.open(url, "DSD4_0110", "top=50, left=50, toolbar=yes, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
									} ;
									return link;
								}
							},
							{header:'貸款金額', key:'LOAN_AMT', attrs:{align:'right'},
								render:function( record, value ) {																		
									return gridFmtRender(value);
								}
							},
							{header:'本金餘額', key:'PRINCIPAL', attrs:{align:'right'},
								render:function( record, value ) {																		
									return gridFmtRender(value);
								}
							}
						]						
					}
				);						
					
				initValidation();
				
				// 查詢
				//$('BTN_query').observe('click', actions.doQuery);

				// 承辦
				$('BTN_update').observe('click', actions.doUpdate);
				
				// 確認
				$('BTN_confirm').observe('click', actions.doConfirm);
				
				// 上一頁
				$('BTN_back').observe('click', actions.doBack);
				
				//上一頁控制
				$("BTN_back").disable();
				
				// 接值.ACTION_TYPE==“Q”，執行初始查詢
				if('${ACTION_TYPE}' == 'Q'){
					$("BTN_back").enable();
					actions.doQuery();
				}

				Suggest.add(
					"RECEIVE_DEPT",	// (必填)建議輸入欄位的ID
					Suggest.URL,	// (必填)建議輸入的設定型態(動態查詢型態)
					"/DSWeb/servlet/HttpDispatcher/DSD4_0100/suggestQuery",	// (必填)至後端查詢資料的網址。
					{
						"option_key":"DIV_NAME",
						"remark_key":"DIV_NO",
						"dispMax":10,
						"prefix":false,
						"ignoreCase":true,
						"startLength":2,
						"noCookies":true,
						"callBackFunc" : function(node,rec){
							$('RECEIVE_DEPTNO').setValue(rec ? rec['DIV_NO'] : '');
						}
					}	// (選填)其他設定值們
				);

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
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<input id="LOAN_ID_Q" type="hidden" value="${LOAN_ID}"/>
	<tr>
		<td colspan="3" align="center">
			 <input id="BTN_update" type="button" class="button" value='承辦' /> 
			 <input id="BTN_confirm" type="button" class="button" value='確認' /> 
			 <input id="BTN_back" <c:if test="${titleNotDisplay eq 'Y'}">type="hidden"</c:if><c:if test="${titleNotDisplay ne 'Y'}">type="button"</c:if> class="button" value='回上一頁' />
		</td>
	</tr>	
</table>

</form>	

<form id="form2" name="form2" style="PADDING: 0px; MARGIN: 0px;">

<table id="gridB" class="gridB"></table>

<table id="dataB" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr class=tbYellow0 align=middle>
		<td align=middle colspan="6"><strong>一、基本資料</strong></td>
	</tr>
	<tr>
		<td class="tbYellow" width='10%'>
			貸款帳號
		</td>
		<td class="tbYellow2" width="23%">
			<span id="LOAN_ID"></span>
			<input id="LOAN_ID_HID" type="hidden" size='25'/>
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
			作業種類
		</td>
		<td class="tbYellow2">
			<select id="PAYOFF_LIMIT" disabled>			
				<c:forEach items="${PAYOFF_LIMIT_LIST}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
		<td class="tbYellow">
			領取單位
		</td>
		<td class="tbYellow2" colspan="3">
			<input id="RECEIVE_DEPT" class="textBox2" type="text" size='40'/>
			<input id="RECEIVE_DEPTNO" class="textBox2" type="text" size='25' maxlength='25'/><!--領取單位代號 隱藏欄位-->
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			受理單位
		</td>
		<td class="tbYellow2">
			<span id="INPUT_DEPT_NM"></span>
		</td>
		<td class="tbYellow">
			收息單位
		</td>
		<td class="tbYellow2" colspan="3">
			<span id="GETINT_DEPT_NM"></span>
		</td>
	</tr>
</table>

<table id="gridD" class="gridD"></table>

<table  id="dataD" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="15%">
			領取人
		</td>
		<td class="tbYellow2" width="35%">
			<c:forEach items="${CONTACT_STATUS_LIST}" var="item">
				<span style="display:inline-block" field="LIST">
					<input id="${item.key}" name="CONTACT_STATUS" type="radio" value="${item.key}" disabled>${item.value}
				</span>
			</c:forEach>
			<!--[2020.09.21] 8.聯絡人欄位改為顯示領取人，及領取人姓名(不能修改) -->
			&nbsp;&nbsp;&nbsp;&nbsp; 姓名 : 
			<%-- [20240328] 難字調整：姓名 --%>
			<span id='RECIPIENT_NAME' style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow" width="15%">
			聯絡電話
		</td>
		<td class="tbYellow2" colspan="3" width="35%">
			<span id="DAY_TEL"/></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			未清償件數
		</td>
		<td class="tbYellow2" colspan='5'>
			<input id="NOT_PAY_QTY" class="textBox2" type="text" size='3' datatype="number"/>件
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			有無共同擔保
		</td>
		<td class="tbYellow2">
			<input type="radio" name="GUARANTOR_STATUS" id="GUARANTOR_STATUS_0" value="0" disabled>無
			<input type="radio" name="GUARANTOR_STATUS" id="GUARANTOR_STATUS_1" value="1" disabled>有
		</td>
		<td class="tbYellow">
			是否相同擔保品
		</td>
		<td class="tbYellow2" colspan="3">
			<input type="radio" name="GUARANTEE_STATUS" id="GUARANTEE_STATUS_0" value="0" disabled>無
			<input type="radio" name="GUARANTEE_STATUS" id="GUARANTEE_STATUS_1" value="1" disabled>有
		</td>
	</tr>
	<tr class=tbYellow0 align=middle>
		<td align=middle colspan="6"><strong>二、退還文件明細</strong></td>
	</tr>
	<%--[20191113]刪除借據份數，借據金額欄位--%>	
	<tr>
		<td class="tbYellow">
			1.抵押權塗銷同意書
		</td>
		<td class="tbYellow2"> <%--[20191113]刪除他項權利證明金額欄位--%>	
			<input id="NEW_QTY" type="text" class="textBox2" size='3' datatype="number" disabled="true"/>份
		</td>
		<td class="tbYellow">
			4.火險單
		</td>
		<td class="tbYellow2" colspan="3"> <%--[20200924]新增欄位--%>	
			<input id="FIRE_QTY" type="text" class="textBox2" size='3' datatype="number"/>份
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			2.他項權利證明
		</td>
		<td class="tbYellow2">
			<input id="OTHER_RIGHT_QTY" class="textBox2" type="text" size='3' datatype="number"/>份
		</td>
		<td class="tbYellow">
			5.應退暫收款
		</td>
		<td class="tbYellow2" colspan="3"> <%--[20200924]新增欄位--%>	
			<input id="REMAIN_AMT_E" type="text" class="textBox2" datatype="number" size='15'/>元
			<input id="AMT_ALL" type="hidden" datatype="number"/>
			說明：<input id="MEMO" type="text" class="textBox2" size='60' disabled="true"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			3.證明書(清償證明補發)
		</td>
		<td class="tbYellow2">
			
			<input id="CERTIFICATE" type="text" class="textBox2" size='3' datatype="number"/>份
		</td>
		<td class="tbYellow">
			6.其他
		</td>
		<td class="tbYellow2" colspan="3"> <%--[20200924]新增欄位--%>	
			<input id="OTHER" type="text" class="textBox2" size='50'/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			資管科經辦
		</td>
		<td class="tbYellow2">
			<%-- [20240328] 難字調整：資管科經辦 --%>
			<span id="CHECK_ID_NAME" style="font-family:'EUDC'"></span>  
			<span id="CHECK_DATE1"></span>
		</td>
		<td class="tbYellow">
			資管科覆核
		</td>
		<td class="tbYellow2" colspan="3">
			<%-- [20240328] 難字調整：資管科覆核 --%>
			<span id="CHECK_LEADER_NAME" style="font-family:'EUDC'"></span>  
			<span id="CHECK_DATE2"></span>
		</td>
	</tr>
</table>

</form>		
</body>
</html>