<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSD41603.jsp
功能：清償派件及轉移
作者：周宏哲
完成：2021/07/21

問題單號 :20210915091922 

[20230627]修改件
[申請書:230511008861]清償文件簽收電訪卡控
郭曉慧

[20240328]
難字調整
高強禾
-->	
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible"> 

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
 
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="${htmlBase}/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
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
Event.observe(window, 'load', new DSD41603().initApp);

function DSD41603() {
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1603/');
	var cover;
	var FILE_KIND = ""; //領取人角色
	var isQuery = false; //是否執行過查詢
	var valid;
	var D41603grid, D094grid;
	
	<%--[20230328180907][20230413]按鈕授權--%>
	<%--[20230627]增-電訪確認--%>
	function buttonAuth(){
		var authButtons = {
			B0064: ['btn_loan', 'btn_acceptance', 'btn_ownership', 'btn_succession', 'btn_other'], //領取人角色
			B0008: 'btn_reject', //退回金庫(逾期未領)
			B0252: 'btn_sign', //電子簽收條
			B0247: 'btn_print', //列印簽收條
			B0252: 'btn_confirmD094' // 電訪確認
		};		
		
		<dz:grantButtons FUNC_ID="DSD41603"/>
	};
	
	// 檢核
	var initValidation = function(){	
		<%--[20221206173838][20230511]檢核領用人資料相關欄位--%>
		valid = new Validation('form_sign', { focusOnError:true, immediate:false, mode : 'validator' });
		//valid.define( "required" , [{ id : "RECEIVE_NAME", errMsg : '請輸入領用人資料-姓名' } ] );
		valid.define( "required" , [{ id : "RCVD_CUS_ID", errMsg : '請輸入領取人資料-身分證字號' } ] );
		valid.define( "checkID" , [{ id : "RCVD_CUS_ID", errMsg : '領取人資料-身分證字號不符規則' } ] );	
		valid.define( "required" , [{ id : "RCVD_CUS_TEL", errMsg : '請輸入領取人資料-連絡電話' } ] );
		valid.define( "validate-number" , { id: "RCVD_CUS_TEL" , errMsg:"領取人資料-聯絡電話非數字格式，請重新輸入" });
	};
	
	<%--CoverPage(鎖定/開放畫面)--%>
	var auxiliary = {
		createCoverPage:function(){
			cover = CSRUtil.createCoverPage('_frontCover');
			cover.show();
		},
		closeCoverPage: function(){
			cover.hide();
		}
	};
	
	function doCancel(){

		if(window.isPopupWin && window.popupWinBack){
			window.popupWinBack();
		}else if(window.parent && window.parent.popupWin){
			window.parent.popupWin.back();
		}else{
			CSRUtil.linkBack(); 
		}	
	}
	
	function dohide(){
		
		$$('.dataTableAll').each(function(e){
			e.hide();
		});	
		
	}
	<%--[20230627]增--%>
	function showDataDiv6(FILE_KIND){
		$('dataDiv6').show(); //[20220928]驗測問題：需先點選簽收角色，再顯示[電子簽收條]
		$('D094_table').hide();
		if(['02', '04'].include(FILE_KIND)){
			$('D094_table').show();
		}
	}
	
    <%-- [20220301]問題單[20220225170023] 1.新增貸款帳號查詢，英文輸入主動轉大寫 --%>
    function englishToUpperCase() {
    	this.value = this.value.toUpperCase();
    }
	
	
	var buttons = {
			
		doLoan : function(){

			valid.reset();
			
			//借款人
			//[20230328180907][20230413] 點選領取人角色按鈕前須檢核是否按過查詢
			if(!isQuery){
				alert("請先執行查詢");
				return;
			}
			dohide();
			$('dataDiv1').show();
			FILE_KIND = "01"; //[20230328180907][20230413]  領取人角色類型
			<%--[20230627]$('dataDiv64').show()改呼叫showDataDiv6()--%>
			showDataDiv6(FILE_KIND);
		},
		doAcceptance : function(){ 

			valid.reset();
			
			//受任人
			//[20230328180907][20230413] 點選領取人角色按鈕前須檢核是否按過查詢
			if(!isQuery){
				alert("請先執行查詢");
				return;
			}
			dohide();
			$('dataDiv2').show();
			FILE_KIND = "02"; //[20230328180907][20230413] 領取人角色類型
			<%--[20230627]$('dataDiv64').show()改呼叫showDataDiv6()--%>
			showDataDiv6(FILE_KIND);
		},
		doOwnership : function(){

			valid.reset();
			
			//所有權人
			//[20230328180907][20230413] 點選領取人角色按鈕前須檢核是否按過查詢
			if(!isQuery){
				alert("請先執行查詢");
				return;
			}
			dohide();
			$('dataDiv3').show();
			FILE_KIND = "03"; //[20230328180907][20230413] 領取人角色類型
			<%--[20230627]$('dataDiv64').show()改呼叫showDataDiv6()--%>
			showDataDiv6(FILE_KIND);
		},
		doSuccession : function(){

			valid.reset();
			
			//法定繼承人
			//[20230328180907][20230413] 點選領取人角色按鈕前須檢核是否按過查詢
			if(!isQuery){
				alert("請先執行查詢");
				return;
			}
			dohide();
			$('dataDiv4').show();
			FILE_KIND = "04"; //[20230328180907][20230413] 領取人角色類型
			<%--[20230627]$('dataDiv64').show()改呼叫showDataDiv6()--%>
			showDataDiv6(FILE_KIND);
		},
		doOther : function(){

			valid.reset();
			
			//其他(紙本簽收)
			//[20230328180907][20230413] 點選領取人角色按鈕前須檢核是否按過查詢
			if(!isQuery){
				alert("請先執行查詢");
				return;
			}
			dohide();
			$('dataDiv5').show();
			$('dataDiv7').show();//[20230328180907][20230413] 顯示列印簽收條按鈕
			FILE_KIND = "05"; //[20230328180907][20230413] 領取人角色類型
		},
		doReject : function(){

			valid.reset();
			
			//退回金庫
			ajaxRequest.post( 'reject' , { 
					REFER_ID : $F('REFER_ID'), 
					APPLY_DATE : $F('APPLY_DATE'), 
					SIGN_STATUS : $F('SIGN_STATUS'), 
					CASE_STATUS : $F('CASE_STATUS'),
					RETURN_NOTE : $F('RETURN_NOTE')
				  },
				function(resp){	
					 doCancel();				
				});
			
		},
		doSign : function(){
			valid.reset();
			
			//[20230204]驗測問題：增加檢核
			var CASE_STATUS = $F('CASE_STATUS');
			if('20' != CASE_STATUS && '25' != CASE_STATUS && '30' != CASE_STATUS){
				alert('簽收狀態有誤，不可上傳簽收條!(狀態需為"文件已確認"、"待服中主管覆核")');
				return;
			}
			// 檢核領用人資訊
			if(!valid.validate()){ 
				return; 
			}
			
			var RCVD_DATA = {
				RECEIVE_ROLE: FILE_KIND || '', 
				RECEIVE_ID: $F('RCVD_CUS_ID') || '', 
				RECEIVE_TEL: $F('RCVD_CUS_TEL') || '', 
				RECEIVE_MEMO: $F('RCVD_MEMO') || ''
			};
			
			ajaxRequest.post( 'sign' , { REFER_ID : $F('REFER_ID'), APPLY_DATE : $F('APPLY_DATE'),FILE_KIND:FILE_KIND},
					function(resp){	
						var printMap = resp.printMap||{};
						popupWin.popup({
							src: '${dispatcher}/DSD4_1604/prompt',<%--問題單號 :20210915091922  調整1604畫面大小--%>
							scrolling : 'no',
							width: '95%',
							parameters: {
								REFER_ID: $F('REFER_ID'), 
								APPLY_DATE: $F('APPLY_DATE'),
								RCVD_DATA: Object.toJSON(RCVD_DATA)
							},
							onclose: function(){
								buttons.doQuery();
							}
						});
						
					}
				);	
		},doUpload : function(event) {

			valid.reset();
			
			if($F('CASE_STATUS') > 25){
				alert("該案件已簽收，不可上傳影像。");
				return;
			}
			
			var target = event.target || event.srcElement;
			var key = target.getAttribute("data-key");
			if(!$F('import_file_' + key)){
				alert('請先選擇上傳資料再執行!');
				return;
			}
		
			if(key.substr(0, 1) == "E"){
				if(!$F('file_context_temp_' + key)){					
					alert('請輸入該文件檔名!');
					return;
				}
				$('file_context_'+key).setValue($F('file_context_temp_'+key));
			}
			auxiliary.createCoverPage();			
			var form = $('form_' + key);	
			form.action = "${dispatcher}/DSD4_1603/upload";
			submitOnce(form);		
		},doReloadImport: function(){ <%-- 上傳完畢後執行 --%>
		
			var idoc = this.contentDocument.getElementById('filedata');
			if(!idoc){
				return;
			}
			auxiliary.closeCoverPage();
			<%--顯示訊息--%>
			var json = idoc.innerHTML.evalJSON();
			var Msg = json.ErrMsg.msgDesc.replace('\\n','');
			if(Msg){
				alert(Msg);
			}
			<%--[20230328180907][20230417]上傳成功清除畫面--%>
			if(json.ErrMsg.returnCode == 0){
				$('previewImg').src = '';
				$('previewImg_div').hide();
			}
		},
		<%--[20230328180907][20230413] 查詢--%>
		doQuery : function(){

			valid.reset();
			
			var REFER_ID = $F('REFER_ID');
			if(!REFER_ID){
				alert('原貸帳號不可為空。');
				return;
			}
			var reqMap = {
				'REFER_ID' : REFER_ID,
				'APPLY_DATE' : $F('APPLY_DATE')					
			};
			
			ajaxRequest.post( 'query' , { reqMap : Object.toJSON(reqMap)},
					function(resp){	
						$('dataDiv').show();
						var rtnMap = resp.rtnMap;
						$('APPLY_DATE').setValue(rtnMap.APPLY_DATE); //A區塗銷申請日
						$$("input[name='APPLY_DATE']").each(function(elem){
							elem.setValue(rtnMap.APPLY_DATE);
						});
						$$("input[name='REFER_ID']").each(function(elem){
							elem.setValue(rtnMap.REFER_ID);
						});
						$('CASE_STATUS').setValue(rtnMap.CASE_STATUS);
						$('SIGN_TXT1').innerHTML = rtnMap.SIGN_TXT1 || '';
						$('SIGN_TXT2').innerHTML = rtnMap.SIGN_TXT2 || '';
						$('SIGN_TXT3').innerHTML = rtnMap.SIGN_TXT3 || '';
						$('SIGN_TXT4').innerHTML = rtnMap.SIGN_TXT4 || '';
						$('SIGN_TXT5').innerHTML = rtnMap.SIGN_TXT5 || '';
						$('SIGN_TXTOT').innerHTML = rtnMap.SIGN_TXTOT || '';

						$('RCVD_CUS_ID').setValue(rtnMap.RCVD_CUS_ID||'');
						$('RCVD_CUS_TEL').setValue(rtnMap.RCVD_CUS_TEL||'');
						$('RCVD_MEMO').setValue(rtnMap.RCVD_MEMO||'');
						$('BORROW_NAME').innerHTML = rtnMap.BORROW_NAME || '';
						//問題單:20230802-0175] 電子簽收檢核上線後優化
						$('RETURN_NOTE').value = rtnMap.RETURN_NOTE || '';
						isQuery = true;

						<%--[20230601-0151][20230608] 增加顯示已上傳附件清單--%>
						D41603grid.load(resp.D41603List||[]);
						<%--[20230627]增-電訪清單--%>
						D094grid.load(resp.D094List || []);
					}
				);	
		},
		<%--[20230328180907][20230413] 列印簽收條--%>
		doPrint : function(){

			valid.reset();
			
			//[20230204]驗測問題：增加檢核
			var CASE_STATUS = $F('CASE_STATUS');
			if('20' != CASE_STATUS && '25' != CASE_STATUS && '30' != CASE_STATUS){
				alert('簽收狀態有誤，不可列印簽收條!(狀態需為"文件已確認"、"待服中主管覆核")');
				return;
			}
			
			ajaxRequest.post( 'sign' , { REFER_ID : $F('REFER_ID'), APPLY_DATE : $F('APPLY_DATE'),FILE_KIND:FILE_KIND},
					function(resp){	
							var dataList = [];
							var reqMap = {
									'REFER_ID' : $F('REFER_ID'),
									'APPLY_DATE' : $F('APPLY_DATE')
							}
							dataList.push(reqMap);
			
							RPTUtil.downloadFile('${dispatcher}/DSD4_0310/prompt',
									{
										source : 'DSD41603',
										dataList : Object.toJSON(dataList)
									},
									true
								);
					}
				);	
		},
		<%--[20230328180907][20230417] 預覽圖片--%>
		doPreviewImg: function(){
			<%--[20230412]預覽--%>
			var fileData = $(this).files;
			var reader = new FileReader();
			reader.onload = function(event){
				$('previewImg').src = event.target.result;
			};
			reader.readAsDataURL(fileData[0]);
			$('previewImg_div').show();
		},
		<%--[20230601-0151][20230608] 更新領用客戶資訊--%>
		doUpdRcvdData: function(){
			valid.reset();
			// 檢核領用人資訊
			if(!valid.validate()){ 
				return; 
			}
			
			var reqMap = {
					'REFER_ID' : $F('REFER_ID'),
					'APPLY_DATE' : $F('APPLY_DATE')	,
					'RCVD_CUS_ID' : $F('RCVD_CUS_ID')	,
					'RCVD_CUS_TEL' : $F('RCVD_CUS_TEL')	,
					'RCVD_MEMO' : $F('RCVD_MEMO')			
				};
				
			ajaxRequest.post( 'updRcvdData' , { reqMap : Object.toJSON(reqMap)});	
		},
		doAddD094: function(){ <%--[20230627]新增立書人--%>
			D094grid.addRecords({'REFER_ID': $F('REFER_ID'), 'APPLY_DATE': $F('APPLY_DATE')});
		},
		doDelD094: function(){ <%--[20230627]刪除--%>
			var dataList = D094grid.getCheckedRecords();
			if(dataList.length == 0){
				alert('需選一筆電訪資料');
				return;
			}
			D094grid.deleteRecords(dataList[0]);
		},
		doConfirmD094: function(){ <%--[20230627]電訪確認--%>
			var dataList = D094grid.getAllRecords();
			if(dataList.length == 0){
				if(!confirm('本件已親自核對立書人不需電訪!')){
					return;
				}
				dataList = [];
			}else if(D094grid.validTable() != 0){
				alert('請輸入[電訪對象]及[電訪日期]!');
				return;
			}
			var reqMap = {
				'REFER_ID' : $F('REFER_ID'),
				'APPLY_DATE' : $F('APPLY_DATE')
			};
			ajaxRequest.post('confirmD094', {D094List: Object.toJSON(dataList), reqMap: Object.toJSON(reqMap)},
				function(resp){	
					D094grid.load(resp.rtnList || []);
				}
			);
		}
	};
	
    return{
    
    initApp : function(){
    	 
    	<cathay:LocaleDisplay sysCode="DS" var="localeDisplay" dateFields="APPLY_DATE"/>
	    PageUI.createPageWithAllBodySubElement("DSD41603","清償作業","清償文件簽收"); 

		initValidation();
		
		<%--[20230601-0151][20230608] 增加顯示已上傳附件清單--%>
		D41603grid = new TableUI({
			table : $("D41603grid"),
			pageSize : 5,
			title : "已上傳簽收附件",
			column : [
				{header : "塗銷申請日", key : 'REMARK',sortRule:'date'},
				{header: "檔案類型", key: 'FILE_KIND_NM', attrs:{align:'left'}},
				{header : "檔案序號", key : 'FILE_ID'},
				{header : "檔名", key : 'ORG_FILE_NM', attrs:{align:'left'}}
			]
		});
		<%--[20230627] 增-電訪清單--%>
		D094grid = new TableUI({
			table : $("D094grid"),
			pageSize : 0,
			validateRecord: function(rec, sn){ 
				var CALL_NM = rec.CALL_NM || '';
				var CALL_DATE = rec.CALL_DATE || '';
				return CALL_NM != '' && CALL_DATE != ''; 
			},
			autoCheckBox: {type: 'radio'}, 
			column : [
				{header: "電訪對象", key: 'CALL_NM', input: {type: 'TEXT'}},
				{header: "電訪日期", key: 'CALL_DATE', input: {type: 'DATE'}}
			]
		});
		
	    $('dataDiv').hide();
		<%--[20230328180907][20230413] 新增按紐--%>
		$('btn_query').observe('click', buttons.doQuery);
	    $('btn_loan').observe('click', buttons.doLoan);
	    $('btn_acceptance').observe('click', buttons.doAcceptance);
	    $('btn_ownership').observe('click', buttons.doOwnership);
	    $('btn_succession').observe('click', buttons.doSuccession);
	    $('btn_other').observe('click', buttons.doOther);
	    $('btn_reject').observe('click', buttons.doReject);
	    $('btn_sign').observe('click', buttons.doSign);
		$('btn_print').observe('click', buttons.doPrint);
		$('btn_updRcvdData').observe('click', buttons.doUpdRcvdData);
		<%--[20230627]增-電訪區按鈕--%>
		$('btn_addD094').observe('click', buttons.doAddD094);
		$('btn_delD094').observe('click', buttons.doDelD094);
		$('btn_confirmD094').observe('click', buttons.doConfirmD094);
		
	    $$('.btn_upload').invoke('observe', 'click', buttons.doUpload);
		$('iframe_upload').observe('load', buttons.doReloadImport);
		$('previewImg_div').hide();
		
		
		$$("input[name='import_file']").each(function(elem){
			elem.observe('change', buttons.doPreviewImg);
		})
		<%-- [20220301]問題單[20220225170023] 1.新增貸款帳號查詢，英文輸入主動轉大寫 --%>
		$('REFER_ID').observe('change', englishToUpperCase);
		
		<%--[20230328180907][20230413]如果初始有傳入參數，就執行查詢 --%>
		if($F('REFER_ID')){
			buttons.doQuery();
		}
		
		dohide();
	    displayMessage();
	    buttonAuth();
   	}
   };
}

</script>
<style>

	.contentDiv{
		margin-bottom: 0px;
		border: 0px;
	}
	
	.contentDivTd {
		border-bottom: 0px;
	}
	
</style>
</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<input id="CASE_STATUS" name="CASE_STATUS" type="hidden" value="${CASE_STATUS}"/>
	<input id="SIGN_STATUS" name="SIGN_STATUS" type="hidden" value="${SIGN_STATUS}"/>  
	<tr>
		<td class="tbYellow" width="10%">原貸帳號</td>
		<td class="tbYellow2" width="15%">
			<input id="REFER_ID" name="REFER_ID" class="textBox2"  type="text" maxlength="25" value="${REFER_ID}"/>
		</td>
		<td class="tbYellow" width="10%">塗銷申請日</td>		
		<td class="tbYellow2" width="15%">
			<input type="text" class="textBox2" name="APPLY_DATE" id="APPLY_DATE" value="${APPLY_DATE}"/>
		</td>
		<td class="tbYellow" width="10%">借款人姓名</td>
		<%-- [20240328] 難字調整：借款人姓名 --%>
		<td class="tbYellow2" width="15%" id="BORROW_NAME" name="BORROW_NAME" style="font-family:'EUDC'"></td>		
		
		<td class="tbYellow2" width="25%" align= "center">
			<button type="button" class="button" id="btn_query">查詢</button>
			<button type="button" class="button" id="btn_reject">退回金庫(逾期未領)</button>
		</td>
	</tr>
</table>

<div id="dataDiv">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>							
			<td class="tbYellow" align="center" width="10%" colspan="5">
				<button type="button" class="button" id="btn_loan">借款人</button>
				<button type="button" class="button" id="btn_acceptance">受任人</button>
				<button type="button" class="button" id="btn_ownership">所有權人</button>
				<button type="button" class="button" id="btn_succession">法定繼承人</button>
				<button type="button" class="button" id="btn_other">其他(紙本簽收)</button>
			</td>			
		</tr>
	</table>
	<table id='grid' class='tableGrid' width="100%">
		<thead>	
			<tr>										
				<th>貸款清償文件</th>
				<th>份數</th>
			</tr>
		</thead>	
			<tbody style="text-align:left">
				<tr>				
					<td class="tbYellow2" width="70%" style="text-align: left;"><b>一、抵押權塗銷同意書</b></td>
					<td class="tbYellow" width="30%"><span id="SIGN_TXT1"></span>份</td>
				</tr>
				<tr>
					<td class="tbYellow2" style="text-align: left;"><b>二、抵押權設定契約書及他項權利證明書</b></td>
					<td class="tbYellow" ><span id="SIGN_TXT2"></span>份</td>
				</tr>
				<tr>
					<td class="tbYellow2" style="text-align: left;"><b>三、證明書(清償證明補發)</b></td>
					<td class="tbYellow" ><span id="SIGN_TXT3"></span>份</td>
				</tr>
				<tr>
					<td class="tbYellow2" style="text-align: left;"><b>四、火險單</b></td>
					<td class="tbYellow" ><span id="SIGN_TXT4"></span>份</td>
				</tr>
				<tr>
					<td class="tbYellow2" style="text-align: left;"><b>五、應退暫收款</b></br>(1)現金退款:限借款人臨櫃國泰人壽分公司</br>(2)匯款退款:需檢附相關文件轉送承辦單位</td>
					<td class="tbYellow" ><span id="SIGN_TXT5"></span>元</td>
				</tr>
				<tr>
					<td class="tbYellow2" style="text-align: left;"><b>六、其他</b><span id="SIGN_TXTOT"></span></td>
					<td class="tbYellow" ></td>
				</tr>
				<%--問題單:20230802-0175] 電子簽收檢核上線後優化--%>
				<tr>							
					<td class="tbYellow" align="center">退件說明</td>
					<td class="tbYellow2" colspan="3" align="lsfe">
						<textarea id="RETURN_NOTE" rows="5" cols="200"></textarea>
					</td>			
				</tr>
			</tbody>
	</table>
	
	<table id='D41603grid' class='grid' width="100%"></table>
</div>
<div id="dataDiv1" class="dataTableAll">
	<table width="100%" class="tableGrid">
		<thead>
			<tr>
				<td class="tbYellow0" align="center" colspan="2"><font>借款人應備文件</font></td>
			</tr>
		</thead>
		<tbody style="text-align: left;">
			<c:forEach var="entry" items="${FILE_KIND_LIST_01}">
			<tr>
				<td class="tbYellow" width="30%" style="text-align: left"><b>${entry.FILE_KIND_NM}</b>
				<c:if test="${entry.FILE_KIND eq 'I'}"><br>(加蓋大小章，查詢工商登記是否為最新日期)</c:if>
				<c:if test="${entry.FILE_KIND eq 'E'}"><br>【說明】:  <input class="textBox2" type="text" id="file_context_temp_E1"></c:if>
				</td>
				<td class="tbYellow2" >
					<form name="form" method="POST"  id="form_${entry.FILE_KIND}1" target="importFrame" enctype="multipart/form-data" class="form-horizontal input-form">
						<input name="REFER_ID" type="hidden" value="${REFER_ID}">
						<input name="APPLY_DATE" type="hidden" value="${APPLY_DATE}">
						<input name="FILE_KIND" type="hidden" value="${entry.FILE_KIND}">
						<input name="FILE_KIND_NM" type="hidden" value="${entry.FILE_KIND_NM}">
						<c:if test="${entry.FILE_KIND eq 'E'}">
							<input name="FILE_COMMENT" type="hidden"id="file_context_${entry.FILE_KIND}1">
						</c:if>
						<input id="import_file_${entry.FILE_KIND}1" name="import_file" type="file" size="50" capture="environment" accept="image/*">
						<button type="button" class="button btn_upload" data-key="${entry.FILE_KIND}1">確認</button>				
					</form>
				</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>
</div>
<div id="dataDiv2" class="dataTableAll">
	<table width="100%" class="tableGrid">
		<thead>
			<tr>
				<td class="tbYellow0" align="center" colspan="2"><font>受任人應備文件</font></td>
			</tr>
		</thead>
		<tbody style="text-align: left;">
			<c:forEach var="entry" items="${FILE_KIND_LIST_02}">
			<tr>
				<td class="tbYellow" width="30%" style="text-align: left"><b>${entry.FILE_KIND_NM}</b>
				<c:if test="${entry.FILE_KIND eq 'I'}"><br>(加蓋大小章，查詢工商登記是否為最新日期)</c:if>
				<c:if test="${entry.FILE_KIND eq 'E'}"><br>【說明】:  <input class="textBox2" type="text" id="file_context_temp_E2"></c:if>
				</td>
				<td class="tbYellow2" >
					<form name="form" method="POST"  id="form_${entry.FILE_KIND}2" target="importFrame" enctype="multipart/form-data" class="form-horizontal input-form">
						<input name="REFER_ID" type="hidden" value="${REFER_ID}">
						<input name="APPLY_DATE" type="hidden" value="${APPLY_DATE}">
						<input name="FILE_KIND" type="hidden" value="${entry.FILE_KIND}">
						<input name="FILE_KIND_NM" type="hidden" value="${entry.FILE_KIND_NM}">
						<c:if test="${entry.FILE_KIND eq 'E'}">
							<input name="FILE_COMMENT" type="hidden"id="file_context_${entry.FILE_KIND}2">
						</c:if>
						<input id="import_file_${entry.FILE_KIND}2" name="import_file" type="file" size="50" capture="environment" accept="image/*">
						<button type="button" class="button btn_upload" data-key="${entry.FILE_KIND}2">確認</button>			
					</form>
				</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>
</div>
<div id="dataDiv3" class="dataTableAll">
	<table width="100%" class="tableGrid">
		<thead>
			<tr>
				<td class="tbYellow0" align="center" colspan="2"><font>所有權人應備文件</font></td>
			</tr>
		</thead>
		<tbody style="text-align: left;">
			<c:forEach var="entry" items="${FILE_KIND_LIST_03}">
			<tr>
				<td class="tbYellow" width="30%" style="text-align: left"><b>${entry.FILE_KIND_NM}</b>
				<c:if test="${entry.FILE_KIND eq 'I'}"><br>(加蓋大小章，查詢工商登記是否為最新日期)</c:if>
				<c:if test="${entry.FILE_KIND eq 'E'}"><br>【說明】:  <input class="textBox2" type="text" id="file_context_temp_E3"></c:if>
				</td>
				<td class="tbYellow2" >
					<form name="form" method="POST"  id="form_${entry.FILE_KIND}3" target="importFrame" enctype="multipart/form-data" class="form-horizontal input-form">
						<input name="REFER_ID" type="hidden" value="${REFER_ID}">
						<input name="APPLY_DATE" type="hidden" value="${APPLY_DATE}">
						<input name="FILE_KIND" type="hidden" value="${entry.FILE_KIND}">
						<input name="FILE_KIND_NM" type="hidden" value="${entry.FILE_KIND_NM}">
						<c:if test="${entry.FILE_KIND eq 'E'}">
							<input name="FILE_COMMENT" type="hidden"id="file_context_${entry.FILE_KIND}3">
						</c:if>
						<input id="import_file_${entry.FILE_KIND}3" name="import_file" type="file" size="50" capture="environment" accept="image/*">
						<button type="button" class="button btn_upload" data-key="${entry.FILE_KIND}3">確認</button>
					</form>
				</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>
</div>
<div id="dataDiv4" class="dataTableAll">
	<table width="100%" class="tableGrid">
		<thead>
			<tr>
				<td class="tbYellow0" align="center" colspan="2"><font>法定繼承人應備文件</font></td>
			</tr>
		</thead>
		<tbody style="text-align: left;">
			<c:forEach var="entry" items="${FILE_KIND_LIST_04}">
			<tr>
				<td class="tbYellow" width="30%" style="text-align: left"><b>${entry.FILE_KIND_NM}</b>
				<c:if test="${entry.FILE_KIND eq 'I'}"><br>(加蓋大小章，查詢工商登記是否為最新日期)</c:if>
				<c:if test="${entry.FILE_KIND eq 'E'}"><br>【說明】:  <input class="textBox2" type="text" id="file_context_temp_E4"></c:if>
				</td>
				<td class="tbYellow2" >
					<form name="form" method="POST"  id="form_${entry.FILE_KIND}4" target="importFrame" enctype="multipart/form-data" class="form-horizontal input-form">
						<input name="REFER_ID" type="hidden" value="${REFER_ID}">
						<input name="APPLY_DATE" type="hidden" value="${APPLY_DATE}">
						<input name="FILE_KIND" type="hidden" value="${entry.FILE_KIND}">
						<input name="FILE_KIND_NM" type="hidden" value="${entry.FILE_KIND_NM}">
						<c:if test="${entry.FILE_KIND eq 'E'}">
							<input name="FILE_COMMENT" type="hidden"id="file_context_${entry.FILE_KIND}4">
						</c:if>
						<input id="import_file_${entry.FILE_KIND}4" name="import_file" type="file" size="50" capture="environment" accept="image/*" >
						<button type="button" class="button btn_upload" data-key="${entry.FILE_KIND}4">確認</button>
					</form>
				</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>
</div>
<div id="dataDiv5" class="dataTableAll">
	<table width="100%" class="tableGrid">
		<thead>
			<tr>
				<td class="tbYellow0" align="center" colspan="2"><font>其他紙本簽收</font></td>
			</tr>
		</thead>
		<tbody style="text-align: left;">
			<tr>
				<td class="tbYellow" align="center" colspan="2">(其他紙本簽收案件比照原紙本簽收作業流程，寄回紙本簽收條與相關附件予資產管理科結案歸檔)</td>
			</tr>
			<c:forEach var="entry" items="${FILE_KIND_LIST_05}">
			<tr>
				<td class="tbYellow" width="30%" style="text-align: left"><b>${entry.FILE_KIND_NM}</b>
				<c:if test="${entry.FILE_KIND eq 'I'}"><br>
				1.負責人領取：公司變更登記表(加蓋大小章並查詢商工登記核對變更日期)、負責人身分證雙證件、公司大小章<br>
				2. 受任人領取：公司變更登記表(加蓋大小章並查詢商工登記核對變更日期)、負責人身分證影本，委任書(加蓋公司大小章、負責人簽名)，受任人身分證雙證件
				</c:if>
				<c:if test="${entry.FILE_KIND eq 'J'}"><br> 以押指印＋見證人方式簽收（檢附領取人、見證人身分證影本）</c:if>
				<c:if test="${entry.FILE_KIND eq 'E'}"><br>【說明】:  <input class="textBox2" type="text" id="file_context_temp_E5"></c:if>
				</td>
				<td class="tbYellow2" >
					<form name="form" method="POST"  id="form_${entry.FILE_KIND}5" target="importFrame" enctype="multipart/form-data" class="form-horizontal input-form">
						<input name="REFER_ID" type="hidden" value="${REFER_ID}">
						<input name="APPLY_DATE" type="hidden" value="${APPLY_DATE}">
						<input name="FILE_KIND" type="hidden" value="${entry.FILE_KIND}">
						<input name="FILE_KIND_NM" type="hidden" value="${entry.FILE_KIND_NM}">
						<c:if test="${entry.FILE_KIND eq 'E'}">
							<input name="FILE_COMMENT" type="hidden"id="file_context_${entry.FILE_KIND}5">
						</c:if>
						<input id="import_file_${entry.FILE_KIND}5" name="import_file" type="file" size="50" capture="environment" accept="image/*">
						<button type="button" class="button btn_upload" data-key="${entry.FILE_KIND}5">確認</button>
					</form>
				</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>
</div>
<div id="previewImg_div" style='text-align: center' class="tbYellow3">
	<img id="previewImg" width="700px"/>
</div>
<div id="dataDiv6" class="dataTableAll">
	<form id="form_sign" name="form_sign" style="PADDING: 0px; MARGIN: 0px;">
		<table width="100%" class="tableGrid">
			<tbody>
				<tr>
					<td class="tbYellow" width="30%" style="text-align:left;">
						<b>領取人資料</b>
					</td>
					<td class="tbYellow2" style="text-align:left;">
						身分證字號：<input id="RCVD_CUS_ID" name="RCVD_CUS_ID" class="textBox2" size="12" length="10"/>　
						聯絡電話：<input id="RCVD_CUS_TEL" name="RCVD_CUS_TEL" class="textBox2" size="12" length="10"/><br/>
						其它備註：<input id="RCVD_MEMO" name="RCVD_MEMO" class="textBox2" size="100"/>
						<button type="button" class="button" id="btn_updRcvdData">確認</button>
					</td>
				</tr>
			</tbody>
		</table>
		<!-- [20230627]增-電訪區 -->
		<table width="100%" class="tableGrid" id="D094_table">
			<thead>
				<tr>
					<td class="tbYellow0" align="center"><font>電訪</font></td>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td class="tbYellow" width="100%" align="center">
						<button type="button" class="button" id="btn_addD094">新增立書人</button>
						<button type="button" class="button" id="btn_delD094">刪除</button>
						<button type="button" class="button" id="btn_confirmD094">電訪確認</button>
					</td>
				</tr>
				<tr>
					<td style="padding: 0px;"><table id='D094grid' class='grid' width="100%"></table></td>
				</tr>
			</tbody>
		</table>
		<div class="tbYellow" align="center">
			<button type="button" class="button" id="btn_sign">電子簽收條</button>
		</div>
	</form>
</div>
<div id="dataDiv7" class="dataTableAll">
	<table width="100%" class="tableGrid">
		<tbody style="text-align: left;">
			<tr>
				<td class="tbYellow" width="100%" align="center">
					<button type="button" class="button" id="btn_print">列印簽收條</button>
				</td>
			</tr>
		</tbody>
	</table>
</div>
<iframe id="iframe_upload" name="importFrame" width="0" height="0"></iframe>
</body>
</html>