<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html;charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename='TextResource' />

<!--
程式：DSD40100.jsp
功能：清償附件一處理作業
作者：林秉宏
完成：2013/08/01


[20190725]問題單(20190724163837) ：有被嵌入DSD40101，頁籤需撐開為全版畫面
[2020.09.21] 申請書編號 200803001097
 1.聯絡人欄位改為領取人，另修改其領取人身分別
 2.行動電話新增可輸入欄位
 3.自動帶出客戶基本資料-聯絡電話(日間、夜間、手機)且不能修改
 4.移除顯示匯款人、匯款金額、匯入行庫、匯出行庫欄位
 5.新增變更鈕，資管二科經辦於清償附件二覆核前，可按變更鈕修改清償附件一之資料
 6.匯款日期欄位改為清償日期，點選清償日期後，系統自動帶出領取期限
 7.領取人、連絡電話(日間或行電擇一)、清償日期等三項皆有輸入資料後，輸入人員才能新增完成
 
[20210517] 問題單 楊青峰
1. 畫面借款人電話部分改成申請人資料。
2. 新增按鈕，針對補發件，主動跳出DSD4_0130電子補發申請書。
3. 新增影像上傳功能，按下按鈕跳出DSD4_0131。
4. 新增影像查詢功能，按下按鈕跳出DSD4_0132。
5. 申請人資料-姓名&身份證字號&地址, 寫入DTDSD060

[20230329][20230327162052]
1.刪除按鈕：【影像上傳】、【補發申請書】
2.查詢調整
高強禾

[20240326]
難字調整
高強禾
 -->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript'
	src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<%-- 日曆用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/suggest.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
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
	Event.observe(window, 'load', new DSD40100().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSD40100(){	

		var gridB, gridC, gridD;
		var valid1, valid2;
		
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0003 : 'BTN_insert',		<%--新增--%>	
				B0004 : 'BTN_update',		<%--修改--%>		
				B0028 : 'BTN_confirm',		<%--確認--%>	
			    B0054 : 'BTN_modify'        <%--變更--%>	
			};
			<dz:grantButtons FUNC_ID='DSD40100'/>
		};
		
		// 檢核
		var initValidation = function(){	

			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkLength1', '貸款帳號長度需為10碼!', function( v ) { return chkLength($F('LOAN_ID_Q'));}],
				[ 'chkLength2', '借款人ID長度需為10碼!', function( v ) { return chkLength($F('BORROW_ID_Q'));}],
	           	['validRequireOne', '連絡電話(日間或行電擇一)',
	               	function(val1, val2, inputs){
	                   	if(Validation.get('IsEmpty').test(val1) && Validation.get('IsEmpty').test(val2)){
	                   		return false;
	                   	}
	                   	return true;
	               	}
	           	]
			] );
			valid1.define( "chkLength1" , [{ id : "LOAN_ID_Q" } ] );
			valid1.define( "chkLength2" , [{ id : "BORROW_ID_Q" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid2.define( "validate-selection" , [{ id : "PAYOFF_LIMIT", errMsg : '請選擇作業種類!' } ] );	
			valid2.define( "required" , [{ id : "NOT_PAY_QTY", errMsg : '請輸入未清償件數!' } ] );
			valid2.define( "required" , [{ id : "RECEIVE_DEPT", errMsg : '請輸入領取單位 !' } ] );
			//valid2.define( "required" , [{ id : "HANDLE1", errMsg : '請輸入輸入人員處理經過!' } ] );
			//valid2.define( "validate-number" , { id: "DAY_TEL_AREA" , errMsg:"借款人日間電話區碼非數字格式，請重新輸入" });
			//valid2.define( "validate-number" , { id: "DAY_TEL_NUM" , errMsg:"借款人日間電話號碼非數字格式，請重新輸入" });
			//valid2.define( "validate-number" , { id: "DAY_TEL_EXT" , errMsg:"借款人日間電話分機非數字格式，請重新輸入" });
			valid2.define( "validate-number" , { id: "D050_DAY_TEL_AREA" , errMsg:"聯絡電話區碼非數字格式，請重新輸入" });
			valid2.define( "validate-number" , { id: "D050_DAY_TEL_NUM" , errMsg:"聯絡電話號碼非數字格式，請重新輸入" });
			valid2.define( "validate-number" , { id: "D050_DAY_TEL_EXT" , errMsg:"聯絡電話分機非數字格式，請重新輸入" });
			valid2.define( "validate-number" , { id: "NOT_PAY_QTY" , errMsg:"未清償件數非數字格式，請重新輸入" });
			valid2.define( "validate-ROCDate" , [{ id : "REMIT_DATE" , errMsg:"清償日期非正確民國日期格式，請重新輸入" } ] );
			
			//[2020.09.21] 7.領取人、連絡電話(日間或行電擇一)、清償日期等三項皆有輸入資料後，輸入人員才能新增完成
			valid2.define( "validate-number" , { id: "D050_MOBILE" , errMsg:"行動電話非數字格式，請重新輸入" });
			valid2.define( "required" , [{ id : "RECIPIENT_NAME", errMsg : '請輸入領取人姓名' } ] );
			valid2.define( "required" , [{ id : "REMIT_DATE", errMsg : '請輸入清償日期 ' } ] );
			valid2.define('validRequireOne',[{id:'D050_MOBILE'},{id : 'D050_DAY_TEL_NUM'}]);
			
			<%--[20221206173838][20221207]檢核申請人資料相關欄位--%>
			valid3 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid3.define( "required" , [{ id : "APPLYMAN_NAME", errMsg : '請輸入申請人資料-姓名' } ] );
			valid3.define( "required" , [{ id : "APPLYMAN_ID", errMsg : '請輸入申請人資料-身分證字號' } ] );
			valid3.define( "checkID" , [{ id : "APPLYMAN_ID", errMsg : '申請人資料-身分證字號不符規則' } ] );	
			valid3.define( "required" , [{ id : "APPLYMAN_ADD", errMsg : '請輸入申請人資料-地址' } ] );
			valid3.define( "required" , [{ id : "APPLYMAN_TEL", errMsg : '請輸入申請人資料-連絡電話' } ] );
			valid3.define( "validate-number" , { id: "APPLYMAN_TEL" , errMsg:"申請人資料-聯絡電話非數字格式，請重新輸入" });
			
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
		
		//檢核領取人是否
		var chkContactStatus = function(){
			var chk = false;
			$$('#tableD060 input[type=radio][name=CONTACT_STATUS]:checked').each(
				function(text){
					chk = true; 
				}
			);
			
			return chk; 	
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSD4_0100/' + actionName,
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
				
				
				
				if($F('linkFrom') == 'AMI01000'){
				
				}else{
					// 檢核
					if(!$F('LOAN_ID_Q') && !$F('BORROW_ID_Q') && !$F('BORROW_NAME_Q')){
						alert("貸款帳號.借款人ID.借款人姓名請至少輸入一欄再執行查詢作業");
						return;
					}
					
					valid2.reset();
					
					// 檢核
					if(!valid1.validate()){ 
						return; 
					}
				}
				var reqMap = {
					LOAN_ID : $F('LOAN_ID_Q'),
					BORROW_ID : $F('BORROW_ID_Q'),
					BORROW_NAME : $F('BORROW_NAME_Q'),
					linkFrom:$F('linkFrom'),
					queryOpUnit:$F('queryOpUnit')
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'info' : Object.toJSON(reqMap) },
					function(resp){
						
						<%-- [20230329] --%>
						$('REFER_ID_Q').setValue(resp.C100Map.REFER_ID);
					
						if($('LOAN_ID_Q').getValue() && resp.rtnList.length == 1){
							gridB.load(resp.rtnList || []);
							var radio = $$('#gridB input[type=radio]').each(
								function(text){
									text.simulate('click');
								}
							);
						}else{
							gridB.load(resp.rtnList || []);
							gridC.load([]);
							gridD.load([]);
							$('form2').reset();
							$$('#tableD060 span[field!="LIST"][field!="word"]').each(
								function(text){
									text.innerHTML = '';
								}
							);
						}
						
					},function(resp){
						<%-- [20230329] --%>
						$('REFER_ID_Q').setValue('');
						gridB.load([]);
						gridC.load([]);
						gridD.load([]);
						$('form2').reset();
						$$('#tableD060 span[field!="LIST"][field!="word"]').each(
							function(text){
								text.innerHTML = '';
							}
						);
					}
				);	
			},
			// 查詢清償附件一附件二資料
			doQueryD060: function(){
				
				valid1.reset();
				valid2.reset();
				
				var chkList = gridB.getCheckedRecord();
				if(!chkList || chkList.length == 0){
					return;
				}
				// 頁面傳入參數
				ajaxPost( 'queryD060' , { 'checkList' : Object.toJSON(chkList) },
					function(resp){
						gridC.load(resp.C100List || []);
						gridD.load(resp.C102List || []);		
						setValues(resp);
					},
					function(){
						gridC.load([]);
						gridD.load([]);
						
						$$('#gridB input[type=radio]:checked').each(
							function(text){
								text.checked = false;
							}
						);
						$('form2').reset();
						$$('#tableD060 span[field!="LIST"][field!="word"]').each(
							function(text){
								text.innerHTML = '';
							}
						);
					}
				);	
			},
			
			// 新增
			doInsert: function(){
				
				var rtnList = gridB.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行新增作業");
					return;
				}
				
				var chkList = gridB.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行新增作業");
				  	return;
				}
				
				valid1.reset();
				
				if(!chkContactStatus()){
				  	alert("請先選取領取人再執行新增作業");
				  	return;
				}
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				<%--[20221206173838][20221207]檢核申請人資料相關欄位(補發才檢核)--%>
				var rtnPAYOFF_LIMIT = chkList[0]['PAYOFF_LIMIT'];
				if(rtnPAYOFF_LIMIT == '7' && !valid3.validate()){ 
					return; 
				}
				
				var rtnLOAN_ID = chkList[0]['LOAN_ID'];
				var rtnCRED_DEPT = chkList[0]['CRED_DEPT'];
				var rtnGETINT_DEPT = chkList[0]['GETINT_DEPT'];
				
				var reqMap = {
					LOAN_ID : $F('LOAN_ID_Q'),
					BORROW_ID : $F('BORROW_ID_Q'),
					BORROW_NAME : $F('BORROW_NAME_Q')
				}
				
				// 頁面傳入參數
				ajaxPost( 'insert' ,
				{
					'checkList' : Object.toJSON(chkList),
					'D060Map' : Object.toJSON(dataMap(rtnLOAN_ID, rtnCRED_DEPT, rtnGETINT_DEPT)), 
					'info' : Object.toJSON(reqMap)
				},
					function(resp){
						gridB.load(resp.rtnList || []);
						gridC.load([]);
						gridD.load([]);
						$('form2').reset();
						$$('#tableD060 span[field!="LIST"][field!="word"]').each(
							function(text){
								text.innerHTML = '';
							}
						);
					}
				);	
			},
			
			// 修改
			doUpdate: function(){
				
				var rtnList = gridB.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行修改作業");
					return;
				}
				
				var chkList = gridB.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行修改作業");
				  	return;
				}
				
				valid1.reset();
				
				if(!chkContactStatus()){
				  	alert("請先選取領取人再執行修改作業");
				  	return;
				}
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				<%--[20221206173838][20221207]檢核申請人資料相關欄位(補發才檢核)--%>
				var rtnPAYOFF_LIMIT = chkList[0]['PAYOFF_LIMIT'];
				if(rtnPAYOFF_LIMIT == '7' && !valid3.validate()){ 
					return; 
				}

				var rtnLOAN_ID = chkList[0]['LOAN_ID'];
				var rtnCRED_DEPT = chkList[0]['CRED_DEPT'];
				var rtnGETINT_DEPT = chkList[0]['GETINT_DEPT'];
				
				// 頁面傳入參數
				ajaxPost( 'update' ,
				{
					'checkList' : Object.toJSON(chkList),
					'D060Map' : Object.toJSON(dataMap(rtnLOAN_ID, rtnCRED_DEPT, rtnGETINT_DEPT))
				},
					function(resp){
						setValues(resp);
					}
				);	
			},
			
			// 變更
			doModify: function(){
				
				var rtnList = gridB.getAllRecords();
				if(rtnList.length==0){
					alert("請先查詢再執行變更作業");
					return;
				}
				
				var chkList = gridB.getCheckedRecord();
	            if(chkList.length==0){
				  	alert("請先選取再執行變更作業");
				  	return;
				}
				
				valid1.reset();
				
				if(!chkContactStatus()){
				  	alert("請先選取領取人再執行變更作業");
				  	return;
				}
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}

				var rtnLOAN_ID = chkList[0]['LOAN_ID'];
				var rtnCRED_DEPT = chkList[0]['CRED_DEPT'];
				var rtnGETINT_DEPT = chkList[0]['GETINT_DEPT'];
				
				// 頁面傳入參數
				ajaxPost( 'modify' ,
				{
					'checkList' : Object.toJSON(chkList),
					'D060Map' : Object.toJSON(dataMap(rtnLOAN_ID, rtnCRED_DEPT, rtnGETINT_DEPT))
				},
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
				
				if(!chkContactStatus()){
				  	alert("請先選取領取人再執行確認作業");
				  	return;
				}
				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				<%--[20221206173838][20221207]檢核申請人資料相關欄位(補發才檢核)--%>
				var rtnPAYOFF_LIMIT = chkList[0]['PAYOFF_LIMIT'];
				if(rtnPAYOFF_LIMIT == '7' && !valid3.validate()){ 
					return; 
				}
				
				var rtnLOAN_ID = chkList[0]['LOAN_ID'];
				var rtnCRED_DEPT = chkList[0]['CRED_DEPT'];
				var rtnGETINT_DEPT = chkList[0]['GETINT_DEPT'];
				
				// 頁面傳入參數
				ajaxPost( 'confirm' , { 'checkList' : Object.toJSON(chkList), 'D060Map' : Object.toJSON(dataMap(rtnLOAN_ID, rtnCRED_DEPT, rtnGETINT_DEPT)) },
					function(resp){
						var tempErrMsg = resp.tempErrMsg;	
						if(tempErrMsg){	
							//確認ok , 繼續執行
							if(!confirm(tempErrMsg)){
								return;
							}
						}
						
						ajaxPost( 'confirmTwo' , { 'checkList' : Object.toJSON(chkList), 'D060Map' : Object.toJSON(dataMap(rtnLOAN_ID, rtnCRED_DEPT, rtnGETINT_DEPT)) },
							function(resp2){
								setValues(resp2);
							}			
						);
					}
				);	
			},
			
			// 上一頁
			doBack : function(event){
				if( parent.popupWin ){
		  	       if( parent.popupWin.func ) { parent.popupWin.func(); }
				     parent.popupWin.close();
				} else {
					CSRUtil.linkBack(); 
				}
			},
			
			<%--[20221206173838][20221207]新增按鈕-補發申請書--%>
			<%-- [20230329] 移除補發申請書 --%>

			// [20210517]
			<%-- [20230329] doPopup移除傳入參數 --%>
			doPopup: function() {
				
				<%-- [20230329] 移除影像上傳判斷，src固定為影像查詢 --%>
				popupWin.popup({
					src: '${dispatcher}/DSD4_0132/prompt',
					scrolling : 'yes',
					parameters: { 
						LOAN_ID: $F('LOAN_ID_Q'),
						<%-- [20230329] --%>
						REFER_ID: $F('REFER_ID_Q'),
						APPLY_DATE: $F('REMIT_DATE')
					}
				});
			},
			
			//[2020.09.21] 6.匯款日期欄位改為清償日期，點選清償日期後，系統自動帶出領取期限
			calculDeadline : function(){
				if(!$F('REMIT_DATE')){ //空值
					return;
				}
				ajaxPost( 'calculDeadline' ,
				{
					'REMIT_DATE' : Object.toJSON($F('REMIT_DATE'))
				},
					function(resp){
						$('RECEIVE_DEADLINE').setValue(localeDisplay.formatDate(resp.RECEIVE_DEADLINE || ''));
					}
				);
			},
			
			//[2020.09.21] 1.聯絡人欄位改為領取人，另修改其領取人身分別，自動帶出借款人姓名或人工輸入(其他、所有權人) 
			getRECIPIENT_NAME : function(CONTACT_STATUS_ele){
				//領取人-3 本人,4 所有權人, 9 其他
				if(!$F('LOAN_ID_Q')){
					alert("請輸入貸款帳號");
					return;
				}
				if(CONTACT_STATUS_ele.value=='3'){//本人
					//到DTDSC100收息主檔查詢
					ajaxPost( 'getRECIPIENT_NAME' ,
						{
							'LOAN_ID' : Object.toJSON($F('LOAN_ID_Q'))
						},
						function(resp){
							$('RECIPIENT_NAME').value= resp.BORROW_NAME || '';
						}
					); 
							
				}else {//4 所有權人, 9 其他則自行輸入
					$('RECIPIENT_NAME').value='' ;//清空欄位
				}
			}
		};
		
		// 清償附件一附件二資料輸入區塊
		var setValues = function(resp) {
		
			var rtnMap = resp.rtnMap;
			$w('LOAN_ID BORROW_NAME BORROW_ID').each(
				function(id) {		
					$(id).innerHTML = rtnMap[id] || '';						
				}
			);
			$('LOAN_ID_2').innerHTML = rtnMap['LOAN_ID'] || '';	
			
			var D060Map = resp.D060Map;
			$w('INPUT_DEPT_NM GETINT_DEPT_NM INPUT_ID1_NAME INPUT_LEADER_NAME INPUT_ID3_NAME TIME1 TIME2 TIME4').each(
				function(id) {		
					$(id).innerHTML = D060Map[id] || '';						
				}
			);
			//[2020.09.21] 3.自動帶出客戶基本資料-聯絡電話(日間、夜間、手機)且不能修改
			var C101Map = resp.C101Map;
		    $('DAY_TEL').innerHTML = (C101Map['DAY_TEL_AREA'] || '') + '-' + (C101Map['DAY_TEL_NUM'] || '') + '#' + (C101Map['DAY_TEL_EXT'] || '');
			$('NIGHT_TEL').innerHTML = (C101Map['NIGHT_TEL_AREA'] || '') + '-' + (C101Map['NIGHT_TEL_NUM'] || '') + '#' + (C101Map['NIGHT_TEL_EXT'] || '');
			$('MOBILE').innerHTML = C101Map['MOBILE'] ||'';
			
			$w('DATE1 DATE2 DATE4').each(
				function(id) {		
					$(id).innerHTML = localeDisplay.formatDate(D060Map[id] || '');						
				}
			);
			
			//[2020.09.21] 1.聯絡人欄位改為領取人，另修改其領取人身分別，自動帶出借款人姓名或人工輸入(其他、所有權人) -> 多加RECIPIENT_NAME
			//[2020.09.21] 2.行動電話新增可輸入欄位(D050.D050_MOBILE)
			//[2020.09.21] 4.移除顯示匯款人、匯款金額、匯入行庫、匯出行庫欄位
			$w('PAYOFF_LIMIT RECEIVE_DEPT RECEIVE_DEPTNO '
			 + 'TRANS_BANK1 TRANS_AGENT1 RATE RATE_CORP TRANS_BANK2 TRANS_AGENT2 ' 
			 + 'TRANS_AMT LOAN_AMT CHOICE6 OTHER '
			 + 'D050_DAY_TEL_AREA D050_DAY_TEL_NUM D050_DAY_TEL_EXT NOT_PAY_QTY '
			 + 'HANDLE1 D050_MOBILE RECIPIENT_NAME').each(
				function(id) {
					var D060Value = D060Map[id];
					if (D060Value === 0){
						$(id).value = D060Value;
					}else{
						$(id).value = D060Value || '';
					}					
				}
			);
			
			//$('REMIT_AMT').value = gridFmtRender(D060Map['REMIT_AMT'] || '');	
			$('REMIT_DATE').setValue(D060Map['REMIT_DATE'] || ''); //2020-08-11 -> 1090811
			$('RECEIVE_DEADLINE').setValue(localeDisplay.formatDate(D060Map['RECEIVE_DEADLINE'] || '')); //2020-08-11 -> 1090811
			
			$w('CHOICE7 REASON1 REASON2 REASON3 REASON4 REASON5 REASON6 REASON7').each(
				function(id) {						
					if (D060Map[id] == '1') {
						$(id).checked = true;										
					} else {
						$(id).checked = false; 
					}					
				}
			);
			
			$w('GUARANTOR_STATUS GUARANTEE_STATUS GUAR_COUNT').each(
				function(id) {						
					if (D060Map[id] == '1') {
						$(id + '_1').checked = true;										
					} else {
						$(id + '_0').checked = true; 
					}					
				}
			);
			
			var CONTACT_STATUS=D060Map.CONTACT_STATUS || '';
			if (CONTACT_STATUS){
				$(CONTACT_STATUS).checked = true;
			}
			

			<%--[20221206173838][20221207]清償控管為補發時才顯--%>
			var pl = rtnMap['PAYOFF_LIMIT']
			var fc = rtnMap['FINAL_CHECK']<%--[20221213183205][20221214]新增按鈕控制條件--%>
			if ('7' == pl) {//補發案件
				<%-- [20230329] 移除影像上傳.補發申請書 --%>
				$('BTN_imageQuery').style.display = 'inline';

				//[2023-06-01]問題單20230601-0151-電子簽收條上線問題處理：舊件補發會因為沒有D050，無法進行修改；判斷若補發件無D050，可按【新增】按紐
				if('N'==D060Map['HAS_D050']){
					$('BTN_insert').enable();
				}else{
					$('BTN_insert').disable(); //若補發案件，附件一、二只會清空審核紀錄，不會刪除，故不需要重新新增
				}
				$('BTN_imageQuery').enable();
				
				<%-- [20230329] 移除影像上傳.補發申請書 --%>
			}else {//非補發案件
				$('BTN_insert').enable();
				<%-- [20230329] 移除影像上傳.補發申請書 --%>
				$('BTN_imageQuery').disable();
				$('BTN_imageQuery').style.display = 'none';
			}
			
			<%--[20221206173838][20221207]申請人資料-姓名改為輸入欄位--%>
			if(D060Map['PAYOFF_LIMIT'] == '7') {
				$w('APPLYMAN_ID APPLYMAN_NAME APPLYMAN_ADD APPLYMAN_TEL').each(
						function(id) {						
							$(id).setValue(D060Map[id]||'');	
							$(id).style.display = 'block';		
						}
					);
			} else {
				$w('APPLYMAN_ID APPLYMAN_NAME APPLYMAN_ADD APPLYMAN_TEL').each(
						function(id) {						
							$(id).setValue('');	
							$(id).style.display = 'none';		
						}
					);
			}
		};
		
		// 產生清償確認資料回傳資料
		var dataMap = function(rtnLOAN_ID, rtnCRED_DEPT, rtnGETINT_DEPT){
			
			//自動帶出客戶基本資料-聯絡電話(日間、夜間、手機)且不能修改 
			var reqMap = {};
			
			$$('#tableD060 input[type!=checkbox][type!=radio][field!="DISABLE"], #tableD060 textarea').each(
				function(text){
					reqMap[text.id] = text.value;
				}
			);
			//reqMap['REMIT_AMT'] = fmtRemove($('REMIT_AMT').value);
			reqMap['REMIT_DATE'] = $('REMIT_DATE').getValue();
			
			$$('#tableD060 input[type=radio][id^=GUAR]:checked').each(
				function(text){
					reqMap[text.name] = text.value;
				}
			);
			
			$$('#tableD060 input[type=radio][name=CONTACT_STATUS]:checked').each(
				function(text){
					reqMap['CONTACT_STATUS'] = text.value;
				}
			);
			
			reqMap['LOAN_ID'] = rtnLOAN_ID;
			reqMap['CRED_DEPT'] = rtnCRED_DEPT;
			reqMap['GETINT_DEPT'] = rtnGETINT_DEPT;
			
			// [20210517]  申請人資料-姓名&身份證字號&地址, 寫入DTDSD060
			reqMap['APPLYMAN_ID'] = $F('APPLYMAN_ID');<%--[20221206173838][20221207]申請人資料-姓名改為輸入欄位--%>
			reqMap['APPLYMAN_NAME'] = $F('APPLYMAN_NAME');<%--[20221206173838][20221207]申請人資料-身分證字號改為輸入欄位--%>
			reqMap['APPLYMAN_ADD'] = $F('APPLYMAN_ADD');
			reqMap['APPLYMAN_TEL'] = $F('APPLYMAN_TEL');<%--[20221206173838][20221207]新增申請人資料-連絡電話--%>
			
			return reqMap;		
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
				<cathay:LocaleDisplay dateFields="REMIT_DATE" sysCode= 'DS' var='localeDisplay' />
				
		        <%-- [20190725]問題單 ：頁籤超出頁面需撐開為全版畫面--%>
				<c:if test="${titleNotDisplay eq 'Y'}">
				PageUI.createPageWithAllBodySubElement(
					'DSD40100' ,
					'清償作業' , 
					'清償附件一處理' ,
					0 ,
					true
				);		
				</c:if>
				<c:if test="${titleNotDisplay ne 'Y'}">
				PageUI.createPageWithAllBodySubElement(
					'DSD40100' ,
					'清償作業' , 
					'清償附件一處理',
					1,
					false
				);	
				</c:if>			
				
				// 產生 grid 物件	
				gridB = new TableUI(
					{	
						table: $('gridB'), allSortable:true, overDiv:false,
						autoCheckBox:{isSelectAll:true, type:'radio', 
						    action:function(node, boxStatus, records){
								actions.doQueryD060();
							}
						},
						<%-- [20240326] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:'契約狀況', key:'LOAN_STATUS_NM'},
							<%-- [20240326] 難字調整：姓名 --%>
							{header:'姓名', key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
							{header:'借款人ID', key:'BORROW_ID'},
							{header:'收息單位', key:'GETINT_DEPT'}
						]						
					}
				);		
				
				// 產生 grid 物件	
				gridC = new TableUI(
					{	
						table: $('gridC'), allSortable:true, overDiv:false,title:"貸款資料",
						column:[
							{header:'貸款帳號', key:'LOAN_ID'},
							{header:'狀態', key:'PAYOFF_LIMIT_NM'}
						]						
					}
				);
				
				// 產生 grid 物件	
				gridD = new TableUI(
					{	
						table: $('gridD'), allSortable:true, overDiv:false,title:"保證人資料",
						<%-- [20240326] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header:'擔保帳號', key:'LOAN_ID'},
							{header:'借款人ID', key:'BORROW_ID'},
							<%-- [20240326] 難字調整：借款人姓名 --%>
							{header:'借款人姓名', key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }}
						]						
					}
				);						
					
				initValidation();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
				
				// 新增
				$('BTN_insert').observe('click', actions.doInsert);
				
				// 修改
				$('BTN_update').observe('click', actions.doUpdate);
				
				// 確認
				$('BTN_confirm').observe('click', actions.doConfirm);
				
				// 變更  [2020.09.21] 5.新增變更鈕，資管二科經辦於清償附件二覆核前，可按變更鈕修改清償附件一之資料
				$('BTN_modify').observe('click', actions.doModify);
				
				// 上一頁
				$('BTN_back').observe('click', actions.doBack);
				
				// [20210517]
				<%-- [20230329] 移除影像上傳 --%>
				<%-- [20230329] doPopup移除傳入參數 --%>
				$('BTN_imageQuery').observe('click', actions.doPopup);
				<%--[20221206173838][20221207]補發申請書--%>
				<%-- [20230329] 移除補發申請書 --%>
				
				//上一頁控制
				$("BTN_back").disable();
				<%--[20221206173838][20221207]影像上傳、影像查詢查詢前disable--%>
				<%-- [20230329] 移除影像上傳 --%>
				$("BTN_imageQuery").disable();
				
				// 接值.ACTION_TYPE==“Q”，執行初始查詢
				if('${ACTION_TYPE}' == 'Q' || $F('linkFrom') == 'AMI01000'){
					$("BTN_back").enable();
					<%--[20221206173838][20221207]影像上傳、影像查詢查詢後enable--%>
					<%-- [20230329] 移除影像上傳 --%>
					$("BTN_imageQuery").enable();
					actions.doQuery();
				}

				//suggest-領取單位名稱
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
						"params":{"eletag":"DIV_NAME"},
						"callBackFunc" : function(node,rec){
							 $('RECEIVE_DEPTNO').value = (rec ? rec['DIV_NO'] : '');
						}
					}	// (選填)其他設定值們
				);
				
				<%--[20240220]問題單-20240130-0051：因單位異動(單位名稱不變，僅變更單位代號)，SUGGEST機制導致無法選取正確單位代號，改為也可用單位代號查詢帶出其他單位資訊--%>
				//suggest-領取單位代號
				Suggest.add(
						"RECEIVE_DEPTNO",	// (必填)建議輸入欄位的ID
						Suggest.URL,	// (必填)建議輸入的設定型態(動態查詢型態)
						"/DSWeb/servlet/HttpDispatcher/DSD4_0100/suggestQuery",	// (必填)至後端查詢資料的網址。
						{
							"option_key":"DIV_NO",
							"remark_key":"DIV_NAME",
							"dispMax":10,
							"prefix":false,
							"ignoreCase":true,
							"startLength":2,
							"noCookies":true,
							"params":{"eletag":"DIV_NO"},
							"callBackFunc" : function(node,rec){
								 $('RECEIVE_DEPT').value = (rec ? rec['DIV_NAME'] : '');
							}
						}	// (選填)其他設定值們
					);

				//[2020.09.21] 6.匯款日期欄位改為清償日期，點選清償日期後，系統自動帶出領取期限
				$('REMIT_DATE').observe('change', actions.calculDeadline);
				
				//[2020.09.21] 1.聯絡人欄位改為領取人，另修改其領取人身分別，自動帶出借款人姓名或人工輸入(其他、所有權人) 
				$$('input[name=CONTACT_STATUS]').each(
					function(element){
						element.observe('change',function (){
							actions.getRECIPIENT_NAME(this);
						})
					}
				);
				
				<%--[20221206173838][20221207]申請人資料初始預設不顯示--%>
				$('APPLYMAN_ID').style.display = 'none';
				$('APPLYMAN_NAME').style.display = 'none';
				$('APPLYMAN_ADD').style.display = 'none';
				$('APPLYMAN_TEL').style.display = 'none';
				<%--[20221206173838][20221207]補發申請書按鈕初始預設不顯示--%>
				<%-- [20230329] 移除補發申請書 --%>
				
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
		<input type="hidden" id="linkFrom" name="linkFrom" value="${linkFrom}" />
		<input type="hidden" id="queryOpUnit" name="queryOpUnit"
			value="${queryOpUnit}" />
		<%-- [20230329] 增加原貸帳號 --%>
		<input type="hidden" id="REFER_ID_Q" name="REFER_ID_Q" />
		<table width="100%" border="0" cellpadding="0" cellspacing="1"
			class="tbBox2">
			<tr>
				<td class="tbYellow" width='10%'>貸款帳號</td>
				<td class="tbYellow2" width="90%" colspan="2"><input
					id="LOAN_ID_Q" type="text" class="textBox2"
					onblur="this.value = this.value.toUpperCase()" size="12"
					maxlength="10" value="${LOAN_ID}" /></td>
				<!-- 
		<td class="tbYellow" width='10%'>
			借款人ID
		</td>
		<td class="tbYellow2" width="20%"> -->
				<input id="BORROW_ID_Q" type="hidden" class="textBox2"
					onblur="this.value = this.value.toUpperCase()" size="12"
					maxlength="10" />
				<!-- </td>
		<td class="tbYellow" width='10%'>
			借款人姓名
		</td>
		<td class="tbYellow2" width="20%"> -->
				<input id="BORROW_NAME_Q" type="hidden" class="textBox2" size="15" />
				<!-- </td>
		<td class="tbYellow2" width='10%' align='center'>
			
		</td> -->
			</tr>
			<tr>
				<td colspan="7" align="center">
					<button id="BTN_query" type="button"  class="button">查詢</button>
					<button id="BTN_insert" type="button" class="button" >新增</button>
					<button id="BTN_update" type="button" class="button"  >修改</button>
					<button id="BTN_confirm" type="button" class="button"  >確認</button>
					<button id="BTN_modify" type="button" class="button"  >變更</button>
					<button id="BTN_back"  type="button"  class="button" >回上一頁</button>
					<%-- [20210517] --%>
					<%-- [20230329] 移除影像上傳 --%>
					<button type="button" class="button" id="BTN_imageQuery">影像查詢</button>
					<%-- [20221206173838][20221207]新增補發申請書按鈕 --%>
					<%-- [20230329] 移除補發申請書 --%>
				</td>
			</tr>
		</table>

	</form>

	<form id="form2" name="form2" style="PADDING: 0px; MARGIN: 0px;">

		<table width="100%" border="0" cellpadding="0" cellspacing="1"
			class="tbBox2">
			<tr>
				<td class="tbYellow2" colspan="2" align="center">
					<table id="gridB" class="gridB"></table>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" valign="TOP" width='50%'>
					<table id="gridC" class="gridC" width="50%"></table>
				</td>
				<td class="tbYellow2" valign="TOP" width='50%'>
					<table id="gridD" class="gridD"></table>
				</td>
			</tr>
		</table>


		<table id="tableD060" width="100%" border="0" cellpadding="0"
			cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width='14%'>貸款帳號</td>
				<td class="tbYellow2" width="19%"><span id="LOAN_ID"></span></td>
				<td class="tbYellow" width='14%'>借款人姓名</td>
				<td class="tbYellow2" width="20%">
					<%-- [20240326] 難字調整：借款人姓名 --%>
					<span id="BORROW_NAME" style="font-family:'EUDC'"></span>
				</td>
				<td class="tbYellow" width='13%'>借款人ID</td>
				<td class="tbYellow2" width="21%"><span id="BORROW_ID"></span>
				</td>
			</tr>
			
			<%-- [20210517] E區新增欄位 --%>
			<tr>
				<td class="tbYellow" rowspan="4"><span field="word" style="color:red;">申請人資料</span></td>
				<td class="tbYellow2" colspan="5">
					<span field="word" style="color:red;">姓名：</span>
					<%-- [20240326] 難字調整：姓名 --%>
					<input id="APPLYMAN_NAME" type="text" size='30' title="申請人資料-姓名" alt="ch" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5"><span field="word" style="color:red;">身分證字號：</span><input id="APPLYMAN_ID" type="text" size='30' title="申請人資料-身分證字號" /></td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5">
					<span field="word" style="color:red;">住址：</span>
					<%-- [20240326] 難字調整：住址 --%>
					<input id="APPLYMAN_ADD" type="text" size='30' title="申請人資料-住址" alt="ch" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5"><span field="word" style="color:red;">連絡電話：</span><input id="APPLYMAN_TEL" type="text" size='30' title="申請人資料-連絡電話" /></td>
			</tr>
			<tr>
				<td class="tbYellow" rowspan="3">借款人電話</td>
				<td class="tbYellow2" colspan="5">
					<!-- [2020.09.21] 3.自動帶出客戶基本資料-聯絡電話(日間、夜間、手機)且不能修改 --> 
					日間：<span id="DAY_TEL"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5">夜間：<span id="NIGHT_TEL"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5">手機：<span id="MOBILE"></span>
				</td>
			</tr>
			
			<tr>
				<td class="tbYellow">清償帳號</td>
				<td class="tbYellow2"><span id="LOAN_ID_2"></span></td>
				<td class="tbYellow">作業種類</td>
				<td class="tbYellow2"><select id="PAYOFF_LIMIT" disabled>
						<c:forEach items="${PAYOFF_LIMIT_LIST}" var="row">
							<option value="${row.key}" />
						${row.value}
					</option>
						</c:forEach>
				</select></td>
				<td class="tbYellow">同原貸件處理</td>
				<td class="tbYellow2"><input type="checkbox" id="CHOICE7"
					disabled></td>
			</tr>
			<tr>
				<td class="tbYellow">領取單位</td>
				<td class="tbYellow2">
				<!-- [20240220]問題單-20240130-0051：因單位異動(單位名稱不變，僅變更單位代號)，SUGGEST機制導致無法選取正確單位代號，改為也可用單位代號查詢帶出其他單位資訊-->
					<input id="RECEIVE_DEPTNO" type="text" size='10' maxlength='7' placeholder="單位代號"/>
					<input id="RECEIVE_DEPT" type="text" size='25' maxlength='25' placeholder="單位名稱"/> 
				<td class="tbYellow">受理單位</td>
				<td class="tbYellow2"><span id="INPUT_DEPT_NM"></span></td>
				<td class="tbYellow">收息單位</td>
				<td class="tbYellow2"><span id="GETINT_DEPT_NM"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" rowspan="7">清償原因</td>
				<td class="tbYellow2" colspan="5"><input type="checkbox"
					id="REASON1" disabled>1.利率因素:轉貸 <input id="TRANS_BANK1"
					type="text" class="textBox2" size="12" field="DISABLE" readonly />行庫
					<input id="TRANS_AGENT1" type="hidden" class="textBox2" size="12"
					field="DISABLE" readonly />
				<!--分行，-->利率 <input id="RATE" type="text" class="textBox2" size="6"
					datatype="number" field="DISABLE" readonly />％<!--(本公司--> <input
					id="RATE_CORP" type="hidden" class="textBox2" size="6"
					datatype="number" field="DISABLE" readonly />
				<!--％)--></td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5"><input type="checkbox"
					id="REASON2" name="REASON2" disabled>2.貸限因素:轉貸 <input
					id="TRANS_BANK2" type="text" class="textBox2" size="12"
					field="DISABLE" readonly />行庫 <input id="TRANS_AGENT2"
					type="hidden" class="textBox2" size="12" field="DISABLE" readonly />
				<!--分行，-->金額 <input id="TRANS_AMT" type="text" class="textBox2"
					size="6" datatype="number" field="DISABLE" readonly />萬<!--(本公司-->
					<input id="LOAN_AMT" type="hidden" class="textBox2" size="6"
					datatype="number" field="DISABLE" readonly />
				<!--萬)--></td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5"><input type="checkbox"
					id="REASON3" disabled>3.服務或與銀行往來因素-客戶反應事實</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5"><input type="checkbox"
					id="REASON4" disabled>4.出售<!-- －買方姓名 
			<input id="BUY_NAME" type="text" class="textBox2" size="15" field="DISABLE" readonly/>電話
			<input id="BUY_TEL" type="text" class="textBox2" size="12" field="DISABLE" readonly/><br>&nbsp;&emsp;&emsp;&emsp;&emsp;【代書姓名
			<input id="LAW_NAME" type="text" class="textBox2" size="15" field="DISABLE" readonly/>電話
			<input id="LAW_TEL" type="text" class="textBox2" size="12" field="DISABLE" readonly/>】 -->
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5"><input type="checkbox"
					id="REASON5" disabled>5.有閒錢<!-- -【1】 
			<input type="checkbox" id="ITEM1" disabled>支票 【2】
			<input type="checkbox" id="ITEM2" disabled>現金 【3】
			<input type="checkbox" id="ITEM3" disabled>匯款<br>&nbsp;&nbsp;&nbsp;&nbsp;閒錢來源：
			<input id="SUPPLY" type="text" class="textBox2" size="60" field="DISABLE" readonly/> -->
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5"><input type="checkbox"
					id="REASON7" disabled>6.申請(定+分)展延未准</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="5"><input type="checkbox"
					id="REASON6" disabled>7.其他-轉【1】 <select id="CHOICE6"
					disabled>
						<c:forEach items="${CHOICE6_LIST}" var="row">
							<option value="${row.key}" />
						${row.value}
					</option>
						</c:forEach>
				</select><br>&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;【2】其他原因： <input
					id="OTHER" type="text" class="textBox2" size="60" readonly /></td>
			</tr>
			<tr>
				<td class="tbYellow">未清償件數</td>
				<td class="tbYellow2" colspan='5'><input id="NOT_PAY_QTY"
					type="text" size='3' datatype="number" />件</td>
			</tr>
			<tr>
				<td class="tbYellow">有無共同擔保</td>
				<td class="tbYellow2"><input type="radio"
					name="GUARANTOR_STATUS" id="GUARANTOR_STATUS_0" value="0">無
					<input type="radio" name="GUARANTOR_STATUS" id="GUARANTOR_STATUS_1"
					value="1">有</td>
				<td class="tbYellow">是否相同擔保品</td>
				<td class="tbYellow2"><input type="radio"
					name="GUARANTEE_STATUS" id="GUARANTEE_STATUS_0" value="0">無
					<input type="radio" name="GUARANTEE_STATUS" id="GUARANTEE_STATUS_1"
					value="1">有</td>
				<td class="tbYellow">有無保證債務</td>
				<td class="tbYellow2"><input type="radio" name="GUAR_COUNT"
					id="GUAR_COUNT_0" value="0">無 <input type="radio"
					name="GUAR_COUNT" id="GUAR_COUNT_1" value="1">有</td>
			</tr>
			<tr>
				<td class="tbYellow">
					<!-- [2020.09.21] 1.聯絡人欄位改為領取人，另修改其領取人身分別，自動帶出借款人姓名或人工輸入(其他、所有權人) --> 
					領取人
				</td>
				<td class="tbYellow2" colspan="5">
					<c:forEach items="${CONTACT_STATUS_LIST}" var="item">
						<span style="display: inline-block" field="LIST"> <input id="${item.key}" name="CONTACT_STATUS" type="radio" value="${item.key}">${item.value} </span>
					</c:forEach>
					<span field='word' style="color:red;">(須註明關係及檢附委任書) </span>
					<%-- [20240326] 難字調整：領取人 --%>
					<input id="RECIPIENT_NAME" type="text" size='15' maxlength='15' alt="ch" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow">領取人-連絡電話</td>
				<td class="tbYellow2"><input id="D050_DAY_TEL_AREA" type="text"
					size='3' maxlength='4' /> -<input id="D050_DAY_TEL_NUM" type="text"
					size='11' maxlength='15' /> #<input id="D050_DAY_TEL_EXT"
					type="text" size='5' maxlength='6' /></td>
				<td class="tbYellow">領取人-行動電話</td>
				<!-- [2020.09.21] 2.行動電話新增可輸入欄位  -->
				<td class="tbYellow2" colspan='3'><input id="D050_MOBILE" type="text" size='15' maxlength='15' /></td>
			</tr>
			
			<!-- 
				[2020.09.21] 4.移除顯示匯款人、匯款金額、匯入行庫、匯出行庫欄位
				<tr>
					<td class="tbYellow">匯款人</td>
					<td class="tbYellow2"><input id="REMIT_NAME" type="text"
						class="textBox2" size="15" /></td>
					<td class="tbYellow">匯款金額</td>
					<td class="tbYellow2"><input id="REMIT_AMT" type="text"
						datatype="number" size="13" maxLength="11" /></td>
					<td class="tbYellow">匯款日期</td>
					<td class="tbYellow2"><input name="REMIT_DATE" id="REMIT_DATE"
						type="text" datatype="ROCdate" size="9" maxLength="9" /> <img src="<%=imageBase%>/CM/calendar.gif" height="20"
						onclick="getCalendarFor($('REMIT_DATE'))"></td>
				</tr>
				<tr>
					<td class="tbYellow">匯入行庫</td>
					<td class="tbYellow2"><input id="IN_BANK" type="text"
						class="textBox2" size="15" /></td>
					<td class="tbYellow">匯出行庫</td>
					<td class="tbYellow2" colspan="3"><input id="OUT_BANK"
						type="text" class="textBox2" size="15" /></td>
				</tr>
			 -->
			 
			 <!-- [2020.09.21] 6.匯款日期(REMIT_DATE)欄位改為清償日期，點選清償日期後，系統自動帶出領取期限 --> 
 			<tr>
 				<td class="tbYellow"> 清償日期【餘額為0請輸入申請日】</td>
	 			<td class="tbYellow2">
	 				<input name="REMIT_DATE" id="REMIT_DATE" type="text" size="9" maxLength="9" />
	 				<span field='word' style="color:red;">(民國年YYYMMDD) </span>
	 		    </td>
	 		    <td class="tbYellow"> 領取期限 </td>
	 		    <td class="tbYellow2" colspan="3">
	 		    	<input id="RECEIVE_DEADLINE" type="text" class="textBox2" size="15" readonly/>
	 		    	<span field='word' style="color:red;">(請務必告知客戶清償文件領取期限) </span>
	 		    </td>
	 	 	</tr>
			 
			 <!-- [2020.09.21] 原輸入人員處理經過欄位改為其他備註說明  -->
			<tr>
				<td class="tbYellow">其他備註說明 </td>
				<td class="tbYellow2" colspan="5"><textarea id="HANDLE1" rows="3" cols="80"></textarea></td>
			</tr>
			<!--
	<tr>
		<td class="tbYellow">
			作業科<br>處理經過
		</td>
		<td class="tbYellow2" colspan="5">
		 	<textarea id="HANDLE3" rows="3" cols="80"></textarea>
		</td>
	</tr>
	 -->
			<tr>
				<td class="tbYellow">輸入人員</td>
				<td class="tbYellow2">
					<%-- [20240326] 難字調整：輸入人員 --%>
					<span id="INPUT_ID1_NAME" style="font-family:'EUDC'"></span>
				</td>
				<td class="tbYellow">日期</td>
				<td class="tbYellow2" colspan="3"><span id="DATE1"></span> <span
					id="TIME1"></span></td>
			</tr>
			<tr>
				<td class="tbYellow">輸入覆核</td>
				<td class="tbYellow2">
					<%-- [20240326] 難字調整：輸入覆核 --%>
					<span id="INPUT_LEADER_NAME" style="font-family:'EUDC'"></span>
				</td>
				<td class="tbYellow">日期</td>
				<td class="tbYellow2" colspan="3"><span id="DATE2"></span> <span
					id="TIME2"></span></td>
			</tr>
			<tr>
				<td class="tbYellow">資管科經辦</td>
				<td class="tbYellow2">
					<%-- [20240326] 難字調整：資管科經辦 --%>
					<span id="INPUT_ID3_NAME" style="font-family:'EUDC'"></span>
				</td>
				<td class="tbYellow">日期</td>
				<td class="tbYellow2" colspan="3"><span id="DATE4"></span> <span
					id="TIME4"></span></td>
			</tr>
		</table>

	</form>
</body>
</html>