<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC30201.jsp
功能：郵局核印進度處理
作者：陳善文
完成：2018/12/04
-->
<%-- 20190703因改由保費送扣，故放企科不需自行上下傳媒體檔 --%>
<%-- 20200707 移除未使用的程式碼：上傳、核印件匯檔 --%>
<%-- 2020-08-06 申請書-國泰世華核印作業 BY余凱鈞
  1.新增扣款銀行選項(國泰世華和郵局)，為必選欄位，篩選國泰世華或是郵局案件。
  2.調整資管二科受理確認權限，只有是國泰世華的案件資管二科可以按受理確認。
  3.新增核印件匯檔紐：只有國泰世華案件，核印進度是核印受理的案件可以按核印件匯檔，產生該批次的核印案件明細檔(格式如附件)，核印進度變成「核印中」，更新申請建檔日期。
  4.新增檔案上傳紐：上傳核印結果明細檔，更新核印進度、核印送回日期和核印失敗原因。--%>
<%-- 2021-11-23 申請書-優化核印檔案編號卡控及員工扣薪、保戶優惠通知  BY陳君櫂 
  1. 新增以用戶編號查詢方式
  2. 押「送件確認」時檢核需送核印的案件是否有相同檔案編號未同時勾選作業，若有未同時勾選的案件，跳出錯誤訊息，然後不能押送件確認
  3. 新增送件退回功能
--%>
<%-- 240611資訊部門內部專用申請書:240611006709簡覆表優化：世華核印結果更新優化 BY余凱鈞
     檢查上傳內容，若皆為核印成功，但無勾選[已確認本次匯入皆為核印成功]，就跳檢核失敗
--%>
<html>
<head>

<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>


<!--匯入外部Javascript 與 css-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>


<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>

<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>
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
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSC30201().initApp);

function DSC30201() {

	var valid;

	<%-- TablE UI物件 --%>
	var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC3_0201/');

	<%--CoverPage(鎖定/開放畫面)--%>
	var cover;
	var auxiliary = {
		createCoverPage : function() {
			cover = CSRUtil.createCoverPage('_frontCover');
			cover.show();
		}
		, closeCoverPage : function() {
			if (cover) {
				cover.hide();
			}
		}
	};
	
	//按鈕授權
	function buttonAuth(){
		var authButtons = {
			B0063:"btnCheckAndSend", //送件確認
			B0015:"btnCheckAndReceive", //受理確認
			B0197:"btnCheckAndExport", //核印件匯檔
			B0064:"btnUpload", //上傳送回檔
			B0008:"btnCheckAndWithdraw" //送件退回
		};		
		<dz:grantButtons FUNC_ID="DSC30201"/>
	};
	
	function validSet(){
		valid.reset();
		if ($('APPLY_PROCESS_CHK').checked){
			valid.define('required', {id: 'APPLY_PROCESS', errMsg: '請選擇核印進度查詢'});
			<%-- 會自動檢查下列規則：「請輸入正確的民國日期格式」 --%>
			valid.define('required', {id: 'QUERY_DATES', errMsg: '請輸入正確的查詢日期(起)'});
			valid.define('required', {id: 'QUERY_DATEE', errMsg: '請輸入正確的查詢日期(迄)'});
		}
		if ($('REMIT_DATE_CHK').checked){
			valid.define('required', {id: 'APPLY_PROCESS1', errMsg: '請選擇核印進度查詢'});
			<%-- 會自動檢查下列規則：「請輸入正確的民國日期格式」 --%>
			valid.define('required', {id: 'REMIT_DATES', errMsg: '請輸入正確的匯款日期(起)'});
			valid.define('required', {id: 'REMIT_DATEE', errMsg: '請輸入正確的匯款日期(迄)'});
		}
		if ($('LIMIT_ROLE').value == "Y"){ //限制的角色：非放企科人員需輸資管科別查詢
			valid.define('requiredDept', {id: 'TRANS_AREA', errMsg: '請輸入資管科別或輸入單位查詢'});
			valid.define('requiredDept', {id: 'INPUT_DEPT', errMsg: '請輸入資管科別或輸入單位查詢'});
		}
		if ($('LOAN_ID').value == "" && $('FILE_NO').value == "" ){ //[20211123] 新增檔案編號查詢條件
			valid.define('required', {id: 'BANK', errMsg: '請選擇扣款銀行'});
		}
	};

	var actions = {
		doQuery : function(resp) {
			validSet();
			if (!valid.validate()) {
				return;
			}
			ajaxRequest.post(
				'query',
				{
					reqMap: Object.toJSON(webPageDataRetrievals.getReqMap())
				},
				function(resp) {
					grid.load(resp.rtnList || []);
					if (resp.SUCCES_CNT_MSG){
						$('SUCCES_CNT_MSG').update(resp.SUCCES_CNT_MSG);
					} else {
						$('SUCCES_CNT_MSG').innerHTML = '';
					}
				},
				function(resp) {
					grid.load([]);
					$('SUCCES_CNT_MSG').innerHTML = '';
				}
			);
		}
		, doCheckAndSend : function() {
			if (!grid.getCheckedRecord()[0]) {
				alert('請選擇欲送件確認資料');
				return;
			}
			validSet();
			if (!valid.validate()) {
				return;
			}
			ajaxRequest.post(
				'checkAndSend',
				{
					reqMap: Object.toJSON(webPageDataRetrievals.getReqMap()),
					reqList: Object.toJSON(grid.getCheckedRecord())
				},
				function(resp) {
					grid.load(resp.rtnList || []);
					$('SUCCES_CNT_MSG').innerHTML = '';
				},
				function(resp) {
				}
			);
		}
		, doCheckAndReceive : function() {
			if (!grid.getCheckedRecord()[0]) {
				alert('請選擇欲受理確認資料');
				return;
			}
			validSet();
			if (!valid.validate()) {
				return;
			}
			ajaxRequest.post(
				'checkAndReceive',
				{
					reqMap: Object.toJSON(webPageDataRetrievals.getReqMap()),
					reqList: Object.toJSON(grid.getCheckedRecord())
				},
				function(resp) {
					grid.load(resp.rtnList || []);
					$('SUCCES_CNT_MSG').innerHTML = '';
				},
				function(resp) {
					//$('rtnMsg').innerHTML = '';
				}
			);
		},
		doCheckAndWithdraw : function(){ //[20211123] 送件退回
			if (!grid.getCheckedRecord()[0]) {
				alert('請選擇欲送件退回資料');
				return;
			}
			validSet();
			if (!valid.validate()) {
				return;
			}
			ajaxRequest.post(
				'checkAndWithdraw',
				{
					reqMap: Object.toJSON(webPageDataRetrievals.getReqMap()),
					reqList: Object.toJSON(grid.getCheckedRecord())
				},
				function(resp) {
					grid.load(resp.rtnList || []);
					$('SUCCES_CNT_MSG').innerHTML = '';
				},
				function(resp) {
					//$('rtnMsg').innerHTML = '';
				}
			);
		}
		
		, doCheckAndExport : function() {
			if (!grid.getCheckedRecord()[0]) {
				alert('請選擇欲匯檔確認資料');
				return;
			}
			validSet();
			if (!valid.validate()) {
				return;
			}
			ajaxRequest.post(
				'checkAndExport',
				{
					reqMap: Object.toJSON(webPageDataRetrievals.getReqMap()),
					reqList: Object.toJSON(grid.getCheckedRecord())
				},
				function(resp) {
					grid.load(resp.rtnList || []);
					//$('rtnMsg').innerHTML = '';
					RPTUtil.downloadFile('${dispatcher}/DSC3_0201/download', {tempFileName: resp.tempFileName_fromTxBeam, tempFilePath: resp.tempFilePath_fromTxBeam}); <%-- 跳出下載檔案視窗 --%>
				},
				function(resp) {
					//$('rtnMsg').innerHTML = '';
				}
			);
		}
		, doDownloadCsv : function() {
			if (!grid.getCheckedRecord()[0]) {
				alert('請選擇欲匯檔確認資料');
				return;
			}
			validSet();
			if (!valid.validate()) {
				return;
			}
			
			var exportParams = {
					reqMap: Object.toJSON(webPageDataRetrievals.getReqMap()),
					reqList: Object.toJSON(grid.getCheckedRecord())
			}
			RPTUtil.executeCreateXlsFile('${dispatcher}/DSC3_0201/downloadCsv', exportParams);
			
			grid.load([]);
			
	
		}		
		, doUpload : function() {
			var filename = $F('INPUT_FILE');
			if (!filename) {
				alert('請選擇欲上傳的檔案');
				return;
			}
			if (filename.split('.').pop() !== 'txt') {
				alert('上傳檔案必須為txt檔');
				return;
			}

			<%-- 把檔案匯入 --%>
			auxiliary.createCoverPage();
			var form = $('form1');
			form.setAttribute('action', '${dispatcher}/DSC3_0201/upload');
			form.submit();

		}
		, doUploadCsv : function() {
			var filename = $F('INPUT_FILE');
			if (!filename) {
				alert('請選擇欲上傳的檔案');
				return;
			}
			if (filename.split('.').pop() !== 'csv') {
				alert('上傳檔案必須為csv檔');
				return;
			}

			//增加確認檔案內容
			if( $('UPLOAD_CHK').checked == true){
    			$('UPLOAD_SUCCES').setValue("Y");
			} else {
			    $('UPLOAD_SUCCES').setValue("N");
			}

			<%-- 把檔案匯入 --%>
			auxiliary.createCoverPage();
			var form = $('form1');
			form.setAttribute('action', '${dispatcher}/DSC3_0201/uploadCsv');
			form.submit();
	
		}
		<%-- 上載結束的處理(回傳至頁面處理) --%>
		, doReloadImport : function() {
			var filedata = window.importFrame.document.getElementById('filedata');
			if (filedata) {
				var obj = filedata.innerHTML.evalJSON();
				var Msg = obj.ErrMsg.msgDesc.replace('\\n','');
				if (Msg) {
					alert(Msg);
				}
				<%-- 清除檔案路徑欄位 --%>
				$('import').update(new Element( 'input', {
					id:'INPUT_FILE', name:'INPUT_FILE', type:'file', title: '選取檔案'
				}));
				
				$('UPLOAD_CHK').checked = false;
				$('UPLOAD_SUCCES').setValue("");
				
				auxiliary.closeCoverPage();
				if(CSRUtil.isSuccess(obj)){<%-- 執行成功後重新顯示附件區 --%>
					//var rtnMsg = obj.rtnMsg || '';
					//$('rtnMsg').update(rtnMsg);
				}
			}
		}
		//資管轄區下拉選單連動資管人員下拉選單
		,doChangeTRANS_AREA :function(event){
			$('INPUT_DEPT').value = "";
			var rec_TRANS_AREA= event.target.value;
			if(rec_TRANS_AREA ==''){
				$('TRANS_ID').options.length = 1;
				return;
			}
			ajaxRequest.post( 'changeTRANS_AREA' , {TRANS_AREA : rec_TRANS_AREA},
				function(resp){
					var rec_list_A = resp.EMP_LIST;
					if(rec_list_A){
						$('TRANS_ID').options.length = 1;
						rec_list_A.each(
						function(data) {
							$('TRANS_ID').add(new Option(data.EMP_NAME, data.EMP_ID));
							}		
						); 		
					}
				}
			);	
		}
		,doChangeINPUT_DEPT :function(event){
			$('TRANS_AREA').value = "";		
			$('TRANS_ID').value = "";	
			$('TRANS_ID').options.length = 1;			
		}
		,doChangeAPPLY_PROCESS_CHK :function(event){	
			if($('APPLY_PROCESS_CHK').checked){			
				$('REMIT_DATE_CHK').checked = false;	
				$('REMIT_DATES').disable();
				$('REMIT_DATEE').disable();	
				$('APPLY_PROCESS').enable();
				$('QUERY_DATES').enable();
				$('QUERY_DATEE').enable();	
				$('LOAN_ID').value = "";	
				$('APPLY_PROCESS1').disable();
				$('FILE_NO').value = "";
			} else {
				$('REMIT_DATE_CHK').checked = true;	
				$('REMIT_DATES').enable();
				$('REMIT_DATEE').enable();	
				$('APPLY_PROCESS').disable();
				$('QUERY_DATES').disable();
				$('QUERY_DATEE').disable();		
				$('APPLY_PROCESS1').enable();				
			}			
		}
		,doChangeREMIT_DATE_CHK :function(event){
			if($('REMIT_DATE_CHK').checked){			
				$('APPLY_PROCESS_CHK').checked = false;	
				$('REMIT_DATES').enable();
				$('REMIT_DATEE').enable();
				$('APPLY_PROCESS').disable();
				$('QUERY_DATES').disable();
				$('QUERY_DATEE').disable();
				$('LOAN_ID').value = "";	
				$('APPLY_PROCESS1').enable();
				$('FILE_NO').value = "";
			} else {
				$('APPLY_PROCESS_CHK').checked = true;	
				$('REMIT_DATES').disable();
				$('REMIT_DATEE').disable();	
				$('APPLY_PROCESS').enable();
				$('QUERY_DATES').enable();
				$('QUERY_DATEE').enable();	
				$('APPLY_PROCESS1').disable();				
			}
			
		}
		,clearQry : function(event){
			$('APPLY_PROCESS_CHK').checked = false;	
			$('APPLY_PROCESS').disable();
			$('QUERY_DATES').disable();
			$('QUERY_DATEE').disable();		
			$('REMIT_DATE_CHK').checked = false;	
			$('APPLY_PROCESS1').disable();
			$('REMIT_DATES').disable();
			$('REMIT_DATEE').disable();	
			$('BANK').value = "";
			if(event.target.name!='LOAN_ID'){
				$('LOAN_ID').value = "";
			}
			if(event.target.name!='FILE_NO'){
				$('FILE_NO').value = "";
			}
		}
		,removeInputTypeFile : function(){
			var input = $('INPUT_FILE');
			$('INPUT_FILE').remove();
			parseEUDC('ap');
			$('import').insert(input);
		}
	};

	var webPageDataRetrievals = {
		getReqMap : function() {
			if ($('APPLY_PROCESS_CHK').checked){		
				return {
					TRANS_AREA: $F('TRANS_AREA'),
					TRANS_ID: $F('TRANS_ID'),
					APPLY_PROCESS: $F('APPLY_PROCESS'),
					QUERY_DATES: $F('QUERY_DATES'),
					QUERY_DATEE: $F('QUERY_DATEE'),
					INPUT_DEPT: $F('INPUT_DEPT'),
					LOAN_ID: $F('LOAN_ID'),
					BANK: $F('BANK'),
					FILE_NO : $F('FILE_NO')
				};
			} else if ($('REMIT_DATE_CHK').checked){
				return {
					TRANS_AREA: $F('TRANS_AREA'),
					TRANS_ID: $F('TRANS_ID'),
					APPLY_PROCESS: $F('APPLY_PROCESS1'),
					REMIT_DATES: $F('REMIT_DATES'),
					REMIT_DATEE: $F('REMIT_DATEE'),
					INPUT_DEPT: $F('INPUT_DEPT'),
					LOAN_ID: $F('LOAN_ID'),
					BANK: $F('BANK'),
					FILE_NO : $F('FILE_NO')
				};			
			} else {
				return {
					TRANS_AREA: $F('TRANS_AREA'),
					TRANS_ID: $F('TRANS_ID'),
					INPUT_DEPT: $F('INPUT_DEPT'),
					LOAN_ID: $F('LOAN_ID'),
					BANK: $F('BANK'),
					FILE_NO : $F('FILE_NO')
				};			
			}
		}
	};

	return {

		initApp : function(resp) {
			<cathay:LocaleDisplay sysCode='DS' dateFields='QUERY_DATES QUERY_DATEE REMIT_DATES REMIT_DATEE' var='localeDisplay' />
			PageUI.createPageWithAllBodySubElement(
				'DSC30201',
				'銀行轉帳',
				'核印進度處理'
			);

			grid = new TableUI( {
				table: $('grid'),
				autoCheckBox: {type: 'checkbox', isSelectAll:true},
				<%--[20241101] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }
				},
				column: [
					[
						{header: '貸款帳號', key: 'C100_LOAN_ID'},
						{header: '用戶編號', key: 'FILE_NO'},
						{header: '銀行帳號', key: 'ACCOUNT'},
						{
							header: '委託人',
							key: 'TRUST_ID',
							render: function(record, value) {
								<%--[20241101]難字調整 --%>
								var span = new Element('span',{style:"font-family:'EUDC'"}).update(value + ' ' + record.TRUST_NAME);								
								return span;
							}
						},
						{header: '核印進度', key: 'APPLY_PROCESS_NAME'},
						{header: '資管人員', key: 'EMP_NAME', attrs:{style:"font-family:'EUDC'"}}
					],
					[
						{header: '受理編號', key: 'APPLY_ID'},
						{
							header: '送件日期',
							key: 'SEND_DATE',
							sortRule: 'date'
						},
						{
							header: '受理日期',
							key: 'RECEIVE_DATE',
							sortRule: 'date'
						},
						{
							header: '申請建檔日期',
							key: 'EXTRACT_DATE',
							sortRule: 'date'
						},
						{
							header: '核印送回日期',
							key: 'SIGN_DATE',
							sortRule: 'date'
						},
						{header: '核印失敗原因', key: 'FAIL_REASON_NAME'}
					]
				]
			} );
			buttonAuth();
			$('btnQuery').observe('click', actions.doQuery);
			$('btnCheckAndSend').observe('click', actions.doCheckAndSend);
			$('btnCheckAndReceive').observe('click', actions.doCheckAndReceive);
			//$('btnCheckAndExport').observe('click', actions.doCheckAndExport);
			$('btnCheckAndExport').observe('click', actions.doDownloadCsv);
			//$('btnUpload').observe('click', actions.doUpload); 
			<%-- 確認上載 --%>
			$('btnUpload').observe('click', actions.doUploadCsv); <%-- 確認上載 --%>
			$('importFrame').observe('load', actions.doReloadImport); <%-- 監視: iframe有匯入時啟動╱上載結束 --%>
			
			$('TRANS_AREA').observe('change',actions.doChangeTRANS_AREA);//資管轄區連動資管人員
			$('INPUT_DEPT').observe('change',actions.doChangeINPUT_DEPT);
			$('APPLY_PROCESS_CHK').observe('change',actions.doChangeAPPLY_PROCESS_CHK);
			$('REMIT_DATE_CHK').observe('change',actions.doChangeREMIT_DATE_CHK);
			
			$('btnCheckAndWithdraw').observe('click', actions.doCheckAndWithdraw);//[20211123] 新增送件退回功能

			Validation.addAllThese([
				[ 'requiredDept',  '請輸入資管科別或輸入單位查詢!', 
					function(v){
						if(!$F('TRANS_AREA') && !$F('INPUT_DEPT')){
							return false;
						}	
					return true;		
				}],
			]);
			
			valid = new Validation(
				'form1',
				{
					mode: 'validate'
				}
			);


			$('LOAN_ID').observe('blur', actions.clearQry); //貸款帳號
			$('FILE_NO').observe('blur', actions.clearQry); //檔案編號 [20211123] 新增清除邏輯
			
			$('REMIT_DATES').disable();
			$('REMIT_DATEE').disable();	
			
			displayMessage();
		}
	};
}

</script>
</head>
<body>
	<form name="form1" id="form1" enctype="multipart/form-data" method="post" target="importFrame">
		<input type="hidden" name="gridJSON" id="gridJSON" value="">
		<table border="0" class="tbBox2" width="100%"><tbody>
			<input id="LIMIT_ROLE" name="LIMIT_ROLE" type="hidden" value="${LIMIT_ROLE}"/>
			<input type="hidden" id="UPLOAD_SUCCES" name="UPLOAD_SUCCES" />
			<tr class="tbYellow">
				<td style="width:10%">
					資管科別
				</td>
				<td class="tbYellow2" style="width:10%">
					<select id="TRANS_AREA" class="textBox2" title="資管科別">
						<option value="">全部</option>
						<c:forEach items="${TRANS_AREA_fromTxBeam}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td style="width:10%">
					資管人員
				</td>
				<td class="tbYellow2" style="width:10%" colspan=3 >
					<select id="TRANS_ID" class="textBox2" title="資管人員" alt='ch'><%--[20241101]難字調整 --%>
						<option value="">請選擇</option>
						<c:forEach items="${EMP_LIST}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>				
				<td style="width:10%">
					核印進度
					<input id = "APPLY_PROCESS_CHK", type="checkbox" checked>
				</td>
				<td class="tbYellow2" style="width:20%">
					<select id="APPLY_PROCESS" class="textBox2" title="核印進度">
						<option value="">請選擇</option>
						<c:forEach items="${APPLY_PROCESS_fromTxBeam}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
					<input id="QUERY_DATES" class="textBox2" maxLength="7" size="11" type="text" value="${QUERY_DATES_fromTxBeam}" title="查詢日期(起)">
					~
					<input id="QUERY_DATEE" class="textBox2" maxLength="7" size="11" type="text" value="${QUERY_DATEE_fromTxBeam}" title="查詢日期(迄)">
				</td>
				<td class="tbYellow2" style="width:20%" rowSpan="2">
					<button id="btnQuery" class="button" type="button">查詢</button>
				</td>
			</tr>
			<tr class="tbYellow">
				<td style="width:10%">
					輸入單位
				</td>
				<td class="tbYellow2" style="width:10%">
					<select id="INPUT_DEPT" class="textBox2" title="輸入單位">
						<option value="">全部</option>
						<c:forEach items="${INPUT_DEPT_fromTxBeam}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>			
				<td style="width:10%">
					貸款帳號
				</td>
				<td class="tbYellow2" width='15%'>
					<input id="LOAN_ID"  type="text" class="textBox2 " name="LOAN_ID" maxlength="11" onblur="this.value = this.value.toUpperCase()" />
				</td>
				<td style="width:10%">
					用戶編號
				</td>
				<td class="tbYellow2" width='15%'>
					<input id="FILE_NO"  type="text" class="textBox2 " name="FILE_NO" maxlength="11" />
				</td>
				
				<td style="width:10%">
					匯款日期
					<input id = "REMIT_DATE_CHK", type="checkbox" >					
				</td>
				<td class="tbYellow2" style="width:20%">
					<select id="APPLY_PROCESS1" class="textBox2" title="核印進度1">
						<option value="">請選擇</option>
						<c:forEach items="${APPLY_PROCESS_fromTxBeam}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>				
					<input id="REMIT_DATES" class="textBox2" maxLength="7" size="11" type="text" value="${QUERY_DATES_fromTxBeam}" title="匯款日期(起)">
					~
					<input id="REMIT_DATEE" class="textBox2" maxLength="7" size="11" type="text" value="${QUERY_DATEE_fromTxBeam}" title="匯款日期(迄)">
				</td>				
			</tr>
			<tr class="tbYellow">
				<td style="width:10%">
					扣款銀行
				</td>
				<td class="tbYellow2" style="width:10%">
					<select id="BANK" class="textBox2" title="扣款銀行">
						<option value="">請選擇</option>
						<c:forEach items="${BANK_List}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>	
				<td style="width:10%">
					回送檔
				</td>
				<td class="tbYellow2" width="35%" colspan=3>
					<span id="import">
						<input id="INPUT_FILE" type="file" name="INPUT_FILE" title="選取檔案">
					</span>
					<button id="btnUpload" class="button" type="button">匯入</button>	   									
					<input id = "UPLOAD_CHK", type="checkbox" >已確認本次匯入皆為核印成功
				</td>
				<iframe id="importFrame" style="display:none" name="importFrame"></iframe> <%-- 匯入檔案時，模擬Ajax的效果 --%>								
				<td colSpan="3" style="text-align:center">
					<button id="btnCheckAndSend" class="button" type="button">送件確認</button>
					<button id="btnCheckAndReceive" class="button" type="button">受理確認</button>
					<span id="SUCCES_CNT_MSG"></span>
					<button id="btnCheckAndExport" class="button" type="button">核印件匯檔</button>
					<button id="btnCheckAndWithdraw" class="button" type="button">送件退回</button>				
				</td>
		
			</tr>
		</tbody></table>
		<table id="grid" class="grid">
		</table>
	</form>
</body>
</html>
