<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB20100.jsp
作者：李俊德
功能：匯款文件輸入作業
完成：
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<%-- [20240607] 難字調整 --%>
<style type="text/css"> 
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>

<script type="text/JavaScript">
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSB20100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//查詢條件Map
var reqMap = {};

//儲存資料Map
var saveMap = {};

//--------------------------------------------------------------------------
//	以下為DSB20100() public method,放在 return 中
//--------------------------------------------------------------------------  
function DSB20100(){
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0003:"btn_insert"<%--新增--%>,
			B0004:"btn_update"<%--匯款檢核輸入--%>,
			B0129:"btn_eland"<%--電子謄本查詢--%>,
			B0130:"btn_elandImage"<%--電子謄本影像--%>,
			B0131:"btn_landInput"<%--地政輸入--%>,
			B0132:"btn_remitInput"<%--匯款輸入--%>,
			B0092:"btn_set"<%--設定--%>,
			B0009:"btn_cancel"<%--取消--%>
			,B0132:"btn_tranImage"<%--20190223 匯款影像--%>
		};
		
		<dz:grantButtons FUNC_ID="DSB20100" ignored="false"/>
	}

	var format = {
	
		//取得 checkbox 是否勾選的回傳值
		getCheckedValue : function(ele){
			return ele.checked ? 1 : 0;
		},
		//根據資料判斷 checkbox 是否勾選
		setCheckedValue : function(data, ele){
			ele.checked = data == 1 ? true : false;
		}
	}
	
	var process = {
	
		//載入【B區】受理資訊區塊資料
		loadBlockB : function(rtnMap){
			$('APPLY_ID').innerHTML = rtnMap.APPLY_ID;
			$('BORROW_NAME').innerHTML = rtnMap.BORROW_NAME;
			//避免難字傳入問題
			$('BORROW_NAME_INPUT').value = rtnMap.BORROW_NAME;
			$('BORROW_ID').innerHTML = rtnMap.BORROW_ID;
			$('CRED_DEPT').value = rtnMap.CRED_DEPT;
			$('isGet').value = rtnMap.isGet || ''; //20190223 匯款人員ID是否已取件 
			$('IMG_CASE_ID').value = rtnMap.IMG_CASE_ID || ''; //20190223 影像編號			
		},
		//載入【C區】文件項目輸入區塊資料
		loadBlockC : function(rtnMap){
			$('FLOAT_TYPE').value = rtnMap.FLOAT_TYPE || '';
			$w('RECEIPT GAGE_SETTING BANKBOOK LAND_COPY RECOGNIZANCE FIREINSU_RECEIPT ATM_RECEIPT OTHER_RIGHT CONSENT MULTI_REMIT_FORM').each( 
				function(col){
					format.setCheckedValue(rtnMap[col], $(col));
				}
			);
			
			var LOAN_KIND = rtnMap.LOAN_KIND;
			if (LOAN_KIND == '712' || LOAN_KIND == '972' || LOAN_KIND == '973' || LOAN_KIND == '974' || LOAN_KIND == '975'){
				$('FLOAT_TYPE').disabled = false;
			}else{
				$('FLOAT_TYPE').disabled = true;
			}
			
			//2019-05-06申請書181129001315-新增繳別及對應功能
			//新增繳別下拉選單，法金件可選擇月繳/季繳，其餘類型預設月繳不可修改		
			var bPAY_FREQ = rtnMap.PAY_FREQ;			
			if (LOAN_KIND != '712'){
				$('PAY_FREQ').disabled = true;	
				$('PAY_FREQ').value = "1";			
			} else {
				if (bPAY_FREQ){
					$('PAY_FREQ').value = bPAY_FREQ;		
				} else {
					$('PAY_FREQ').value = "";	
				}
				$('PAY_FREQ').disabled = false;					
			}
		},
		//載入【D區】切結項目區塊資料
		loadBlockD : function(rtnMap){
			$w('BORR_SHARE_Y BORR_SHARE_BANK BORR_SHARE_CENTURY BORR_SHARE_SECURITIES BORR_SHARE_O BORR_SHARE_N BORR_SHARE1 BORR_SHARE2 ORIGINAL INSU_FREE FIREINSU_TRAN FIREINSU_EXPENSE').each( 
				function(col){
					format.setCheckedValue(rtnMap[col], $(col));
					if (col == "BORR_SHARE1" || col == "BORR_SHARE2"){
						$(col).disabled = true;
					}
				}
			);
			$('ISSUE_CODE').value = rtnMap.ISSUE_CODE;
		},
		//載入【E區】輸入資料區塊資料
		loadBlockE : function(rtnMap){
			$w('SCRIVENER_ID SCRIVENER_NAME GUARANTOR_ID CRED_BUSINESS REMIT_ACCOUNT1 REMIT_ACCOUNT2 REMIT_ACCOUNT3 MM_ACCOUNT').each( 
				function(col){
					$(col).value = rtnMap[col] || '';
				}
			);

			$w('IS_AGENCY X104_SEQ_NO X104_SCRIVENER_NAME ACCOUNT_STATUS_NM').each( 
				function(col){
					$(col).innerHTML = rtnMap[col] || '';
				}
			);			
			
			$w('GUARANTOR_DATE LOAN_DATE_M').each( 
				function(col){
					$(col).value = toROC(rtnMap[col] || '');
				}
			);
		},
		
		//讀取選取的【B區】【C區】、【D區】、【E區】區塊資料
		saveBlockCDE : function(){
		
			saveMap = {};
			
			//自動轉大寫
			$('SCRIVENER_ID').value = $F('SCRIVENER_ID').toUpperCase();
			$('GUARANTOR_ID').value = $F('GUARANTOR_ID').toUpperCase();
					
			//取得B區資料 TODO 修正取值
			$w('APPLY_ID BORROW_ID').each( 
				function(col){
					saveMap[col] = $(col).innerHTML;
				}
			);
			
			//避免難字XSS
			saveMap.BORROW_NAME = $('BORROW_NAME_INPUT').getValue();
			
			saveMap.CRED_DEPT = $('CRED_DEPT').value;
			
			//取得D區資料
			$$('#blockD input[type=checkbox]').each( 
				function(col){
					saveMap[col.id] = format.getCheckedValue($(col));
				}
			);
			
			saveMap.ISSUE_CODE=$('ISSUE_CODE').value;
			
			if ($F('TYPE') != '1'){
			
				//取得C區資料
				$$('#blockC input[type=checkbox]').each( 
					function(col){
						saveMap[col.id] = format.getCheckedValue($(col));
					}
				);
				saveMap['FLOAT_TYPE'] = $F('FLOAT_TYPE');
				saveMap['PAY_FREQ'] = $F('PAY_FREQ');				
				
				//取得E區資料
				$$('#blockE input[type=text][datatype!=ROCDate]').each( 
					function(col){
						saveMap[col.id] = $F(col);
					}
				);
				$$('#blockE input[type=text][datatype=ROCDate]').each( 
					function(col){
						saveMap[col.id] = $F(col) ? toY2K($F(col)) : '';
					}
				);
			}

		},
		
		//清空頁面資料
		doClear : function(){
			$('form1').reset();
			$('APPLY_ID').innerHTML = "";
			$('BORROW_NAME').innerHTML = "";
			$('BORROW_ID').innerHTML = "";
			$('IS_AGENCY').innerHTML = "";
			$('X104_SEQ_NO').innerHTML = "";
			$('X104_SCRIVENER_NAME').innerHTML = "";
			$('ACCOUNT_STATUS_NM').innerHTML = "";
			$('APPLY_ID').innerHTML = "";
			$('BORROW_NAME').innerHTML = "";
			$('BORROW_ID').innerHTML = "";
		}		
	}
	
	var actions = {
	
		//共用ajax
		ajaxPost : function( actionName, params, successAction){	
			new Ajax.Request( "<%=dispatcher%>/DSB2_0100/" + actionName,{  
					parameters: params, 
					onSuccess: function(response){ successAction(response.responseJSON );
				}
			});
		},
		// 查詢
		doQuery : function(){
	    	
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.queryChecked();
			
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			//自動轉大寫
			$('INPUT').value = $F('INPUT').toUpperCase();

			reqMap = {};
			//APPLY_ID	畫面上之查詢條件輸入欄位	當查詢別選擇為受理編號時才需設定
			//LOAN_ID	畫面上之查詢條件輸入欄位	當查詢別選擇為貸款帳號時才需設定
			if ($F('QUERY_TYPE_1') == 1){
				reqMap.APPLY_ID = $F('INPUT');
				CSRUtil.keepParamsManager.put({'APPLY_ID': $F('INPUT') });
			} else {
				reqMap.LOAN_ID = $F('INPUT');
			}

			actions.ajaxPost( 'query' ,  { reqMap : Object.toJSON(reqMap) } ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						var rtnMap = resp.rtnMap;
						process.loadBlockB(rtnMap);
						process.loadBlockD(rtnMap);
						
						if ($F('TYPE') != '1'){
							process.loadBlockC(rtnMap);
							process.loadBlockE(rtnMap);
						}
					}else{
						process.doClear();
					}
				}
			);				
		},
		// 新增檢核
		doInsertCheck : function(){

			if ($('APPLY_ID').innerHTML == ''){
				alert("請先查詢再執行新增作業");
				return;
			}
			
			if("2" == $F('CRED_DEPT') && !$F('FLOAT_TYPE')){
				if (!confirm("此案件為法金件，未選擇利率調整方式，則利率為非月調")) {
					return;
				}
			}
			//若「同意提供各子公司往來交易資料」、「不同意提供往來交易資料」、「不同意提供基本及往來交易資料」重複勾取
			if (format.getCheckedValue($('BORR_SHARE_Y'))+format.getCheckedValue($('BORR_SHARE_O'))+format.getCheckedValue($('BORR_SHARE_N')) > 1){
				alert("共同行銷切結，請勿重複點選");
				return;
			}
			
			//若「僅提供國泰世華銀行」、「僅提供國泰世紀產險」、「僅提供國泰綜合證券」3項全部勾取，但「同意提供各子公司往來交易資料」未勾取
			if ($('BORR_SHARE_BANK').checked && $('BORR_SHARE_CENTURY').checked && $('BORR_SHARE_SECURITIES').checked && !$('BORR_SHARE_Y').checked){
				alert("若全部同意，請勾選同意提供各子公司往來交易資料");
				return;
			}
			
			//若TYPE不為1
			if ($F('TYPE') != '1'){
				// 清空檢核
				validates.clear();
				
				// 檢核設定
				validates.insertChecked();
				
				// 檢核觸動：所有檢核設定要在觸動前完成
				if(!validates.valid.validate()){ 
					return; 
				}
				
				//若「理財型預定生效日」有輸入，顯示確認訊息:“理財型生效日確認為:”+「理財型預定生效日」輸入值，確認後才繼續執行
				if ($F('LOAN_DATE_M') != '' && !confirm("理財型生效日確認為: " + $F('LOAN_DATE_M'))){
					return;
				}
			}
			
			//讀取選取的【B區】【C區】、【D區】、【E區】區塊資料
			process.saveBlockCDE();
			saveMap.X104_SEQ_NO=$('X104_SEQ_NO').innerHTML;
			

			actions.ajaxPost( 'insertCheck' ,  { saveMap : Object.toJSON(saveMap), TYPE : $F('TYPE')} ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						if (resp.InsertCheckMSG == 'OK'){
							actions.doInsert();
						} else {
							if(confirm(resp.InsertCheckMSG)){
								actions.doInsert();
							} else {
								return false;
							} 
						}
					}
				}
			);				
		},
		// 新增
		doInsert : function(){
			actions.ajaxPost( 'insert' , { reqMap : Object.toJSON(reqMap), saveMap : Object.toJSON(saveMap), TYPE : $F('TYPE')} ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						var rtnMap = resp.rtnMap;
						process.loadBlockB(rtnMap);
						process.loadBlockD(rtnMap);
						
						if ($F('TYPE') != '1'){
							process.loadBlockC(rtnMap);
							process.loadBlockE(rtnMap);
						}
					}
				}
			);				
		},
		// 修改檢核
		doUpdateCheck : function(){

			if ($('APPLY_ID').innerHTML == ''){
				alert("請先查詢再執行修改作業");
				return;
			}

			//若「同意提供各子公司往來交易資料」、「不同意提供往來交易資料」、「不同意提供基本及往來交易資料」重複勾取
			if (format.getCheckedValue($('BORR_SHARE_Y'))+format.getCheckedValue($('BORR_SHARE_O'))+format.getCheckedValue($('BORR_SHARE_N')) > 1){
				alert("共同行銷切結，請勿重複點選");
				return;
			}
			
			//若「僅提供國泰世華銀行」、「僅提供國泰世紀產險」、「僅提供國泰綜合證券」3項全部勾取，但「同意提供各子公司往來交易資料」未勾取
			if ($('BORR_SHARE_BANK').checked && $('BORR_SHARE_CENTURY').checked && $('BORR_SHARE_SECURITIES').checked && !$('BORR_SHARE_Y').checked){
				alert("若全部同意，請勾選同意提供各子公司往來交易資料");
				return;
			}
			
			//若TYPE不為1
			if ($F('TYPE') != '1'){
				// 清空檢核
				validates.clear();
				
				// 檢核設定
				validates.updateChecked();
				
				// 檢核觸動：所有檢核設定要在觸動前完成
				if(!validates.valid.validate()){ 
					return; 
				}
				
				//若「理財型預定生效日」有輸入，顯示確認訊息:“理財型生效日確認為:”+「理財型預定生效日」輸入值，確認後才繼續執行
				if ($F('LOAN_DATE_M') != '' && !confirm("理財型生效日確認為: " + $F('LOAN_DATE_M'))){
					return;
				}
			}
			
			//讀取選取的【B區】【C區】、【D區】、【E區】區塊資料
			process.saveBlockCDE();
            saveMap.X104_SEQ_NO=$('X104_SEQ_NO').innerHTML;
			actions.ajaxPost( 'updateCheck' ,  { saveMap : Object.toJSON(saveMap), TYPE : $F('TYPE')} ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						if (resp.UpdateCheckMSG == 'OK'){
							actions.doUpdate();
						} else {
							if(confirm(resp.UpdateCheckMSG)){
								actions.doUpdate();
							} else {
								return false;
							} 
						}
					}
				}
			);				
		},
		// 修改
		doUpdate : function(){
			actions.ajaxPost( 'update' , { reqMap : Object.toJSON(reqMap), saveMap : Object.toJSON(saveMap), TYPE : $F('TYPE')} ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						var rtnMap = resp.rtnMap;
						process.loadBlockB(rtnMap);
						process.loadBlockD(rtnMap);
						
						if ($F('TYPE') != '1'){
							process.loadBlockC(rtnMap);
							process.loadBlockE(rtnMap);
						}
					}
				}
			);				
		},
		// 電子謄本查詢
		doEland : function(){
		
			if ($('APPLY_ID').innerHTML == ''){
				alert("請先查詢再執行作業");
				return;
			}
			actions.ajaxPost( 'eland' , { APPLY_ID : $('APPLY_ID').innerHTML} ,
				function(resp){}
			);
			
		},
		// 電子謄本影像
		doElandImage : function(){
		
			if ($('APPLY_ID').innerHTML == ''){
				alert("請先查詢再執行作業");
				return;
			}
			actions.ajaxPost( 'elandImage' , { APPLY_ID : $('APPLY_ID').innerHTML} ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						$('blockF').innerHTML = '<table>' + (resp.rtnStr || '') + '</table>';
					}
				}
			);
		},
		// 地政輸入
		doLandInput : function(){

			if ($('APPLY_ID').innerHTML == ''){
				alert("請先查詢再執行作業");
				return;
			}
					
			var LP_JSON = {};
			LP_JSON.action = "<%=dispatcher%>/DSB2_0200/prompt";	
			LP_JSON.ACTION_TYPE = "Q1"; // 執行別,Q1:以受理編號查詢;Q2:以原貸帳號查詢;Q3:以貸款帳號查詢
			LP_JSON.INPUT = $('APPLY_ID').innerHTML; // 受理編號
			LP_JSON.TYPE = $F('TYPE'); // 異動型態(“”:匯款文件輸入;“1”:切結資料補入)
			
			//超連結至DSB2_0200地政資料輸入作業
			CSRUtil.linkTo(LP_JSON, 'form1');
			
		},
		// 匯款輸入
		doRemitInput : function(){
		
			if ($('APPLY_ID').innerHTML == ''){
				alert("請先查詢再執行作業");
				return;
			}
					
			var LP_JSON = {};
			LP_JSON.action = "<%=dispatcher%>/DSB4_0100/prompt";
			LP_JSON.APPLY_ID = $('APPLY_ID').innerHTML; // 受理編號
			LP_JSON.TYPE = $F('TYPE');  // 異動型態(“”:匯款文件輸入;“1”:切結資料補入)
			
			//超連結至DSB4_0100匯款資料輸入作業
			CSRUtil.linkTo(LP_JSON, 'form1');	
				
		},
		// 設定
		doSet : function(){
		
			if ($('APPLY_ID').innerHTML == ''){
				alert("請先查詢再執行作業");
				return;
			}
			
			actions.ajaxPost( 'set' ,  { reqMap : Object.toJSON(reqMap), APPLY_ID : $('APPLY_ID').innerHTML, BORROW_ID : $('BORROW_ID').innerHTML, MM_ACCOUNT : $F('MM_ACCOUNT')} ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						var rtnMap = resp.rtnMap;
						process.loadBlockB(rtnMap);
						process.loadBlockD(rtnMap);
						
						if ($F('TYPE') != '1'){
							process.loadBlockC(rtnMap);
							process.loadBlockE(rtnMap);
						}
					}
				}
			);				
		},
		// 取消
		doCancel : function(){
			if ($('APPLY_ID').innerHTML == ''){
				alert("請先查詢再執行作業");
				return;
			}
			
			actions.ajaxPost( 'cancel' ,  { reqMap : Object.toJSON(reqMap), APPLY_ID : $('APPLY_ID').innerHTML} ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						var rtnMap = resp.rtnMap;
						process.loadBlockB(rtnMap);
						process.loadBlockD(rtnMap);
						
						if ($F('TYPE') != '1'){
							process.loadBlockC(rtnMap);
							process.loadBlockE(rtnMap);
						}
					}
				}
			);			
		}
		//20190223 匯款影像
		, doTranImage: function(){
			if ($('APPLY_ID').innerHTML == ''){
				alert("請先查詢再執行作業");
				return;
			}
			if ($F('isGet') == 'N'){
				alert("WORKCELL作業進度不為作業撥款處理中，請先取件再點閱匯款影像。");
				return;
			}
			if ($F('IMG_CASE_ID') == ''){
				alert("查無匯款影像掃描文件");
				return;
			}
		
			var url = '${dispatcher}/DSA0_0200/prompt?APPLY_ID='+$F('IMG_CASE_ID');				
			window.open(url, "DSB2_0100", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
		
			/*
			popupWin.popup({									
				src : '${dispatcher}/DSA0_0200/prompt',
				parameters : { 	
					APPLY_ID : $F('IMG_CASE_ID')
				},  	
				cb : function(obj){	}		
			});*/	
		}		
	};
	
	// 檢核
	var validates = {
		initValidation : function() {
		
			// 欄位檢核
			validates.valid = new Validation("form1", {useTitles:true, focusOnError:false, immediate:false});
			Validation.addAllThese([
				['validQueryType', '請輸入正確查詢條件!', function(v , node) { 
					if($('QUERY_TYPE_1').checked && v.length != 11  ){
						return false;
					} else if ($('QUERY_TYPE_2').checked && v.length != 10 ){
						return false;
					} else {
						return true;
					}
				}],
				['validCredBusiness', '授信行業別長度錯誤', function(v , node) { 
					return v.length == 6 ? true : false;
				}],
				[ 'validationINPUT',  '輸入資料有誤，請檢查後重新輸入!', 
					function(v){ 
						if($('QUERY_TYPE_1').checked){
							<%--受理編號：11英數字+@--%>
							return (v.length == 11 && (/^[a-zA-Z0-9@]+$/.test(v))); 
						} else if ($('QUERY_TYPE_2').checked){
							<%--貸款帳號：10英數字--%>
							return (v.length == 10 && (/^[a-zA-Z0-9]+$/.test(v))); 
						}
						return false;						
					} 
				]
			]);
		},
		// 查詢檢核
		queryChecked: function(){
		
			validates.valid.define('required', {id:'INPUT', errMsg: "請輸入查詢條件再執行查詢作業" });
			
			//有輸入條件才檢查長度
			if ($F('INPUT').length != 0){
				if ($('QUERY_TYPE_1').checked){
					validates.valid.define('validationINPUT', {id:'INPUT', errMsg: "受理編號長度或格式錯誤" });				
					
				} else {
					validates.valid.define('validationINPUT', {id:'INPUT', errMsg: "貸款帳號長度或格式錯誤" });
				}
			}
			
		},
		// 新增檢核
		insertChecked: function(){
		
			//若「他項權利證明書」為已勾選，「代書姓名」或「代書ID」未輸入，顯示錯誤訊息："已勾選他項權利證明書，請輸入代書姓名或ID" 
			//1030319 消審一科楊智凱說「代書ID、代書姓名」取消檢核
			//if ($('OTHER_RIGHT').checked && $F('SCRIVENER_NAME') == '' && $F('SCRIVENER_ID') == ''){
			//	validates.valid.define('required', {id:'SCRIVENER_NAME', errMsg: "已勾選他項權利證明書，請輸入代書姓名或ID" });
			//	validates.valid.define('required', {id:'SCRIVENER_ID', errMsg: "已勾選他項權利證明書，請輸入代書姓名或ID" });
			//}
			
			//20200623 申請書-200527001673:配合「不當招攬放款支給扣回辦法」，需比對房貸經手人與新契約經手人是否相同(含對保人)。
        	//故新增放款部法人金融科承辦案件(以下簡稱法金件)於「匯款文件輸入作業」需輸入對保人ID
			//若「對保人ID」未輸入，顯示錯誤訊息："請輸入對保人ID"
			if ($F('GUARANTOR_ID') == ''){
				validates.valid.define('required', {id:'GUARANTOR_ID', errMsg: "請輸入對保人ID" });
			}
			
			//若「對保日」未輸入，顯示錯誤訊息："請輸入對保日"
			//1050205 林宏奇(放款推展科):一律檢核對保日須輸入
			//2019-05-17承辦科別為總公司不更新對保人資訊，不需要輸入對保日期
			if ($F('GUARANTOR_DATE') == ''){
				validates.valid.define('required', {id:'GUARANTOR_DATE', errMsg: "請輸入對保日" });
			}

			//若「授信行業別」未輸入，顯示錯誤訊息："請輸入授信行業別"			
			if ($F('CRED_BUSINESS') == ''){
				validates.valid.define('required', {id:'CRED_BUSINESS', errMsg: "請輸入授信行業別" });
			} else { //若「授信行業別」長度不為6碼，顯示錯誤訊息："請輸入6碼授信行業別"
				validates.valid.define('validCredBusiness', {id:'CRED_BUSINESS', errMsg: "請輸入6碼授信行業別" });
			}
			
			//若「理財連結帳號」有輸入但有非數字，顯示錯誤訊息："理財連結帳號需為數字格式"
			if ($F('MM_ACCOUNT') != ''){
				validates.valid.define('validate-number', {id:'MM_ACCOUNT', errMsg: "理財連結帳號需為數字格式" });
			}
			
			//若繳別未輸入，顯示錯誤訊息："請輸入繳別"
			if ($F('PAY_FREQ') == ''){
				validates.valid.define('required', {id:'PAY_FREQ', errMsg: "請輸入繳別" });
			}

		},
		// 修改檢核
		updateChecked: function(){
		
			//若「他項權利證明書」為已勾選，「代書姓名」或「代書ID」未輸入，顯示錯誤訊息："已勾選他項權利證明書，請輸入代書姓名或ID"
			//1030319 消審一科楊智凱說「代書ID、代書姓名」取消檢核
			//if ($('OTHER_RIGHT').checked && $F('SCRIVENER_NAME') == '' && $F('SCRIVENER_ID') == ''){
			//	validates.valid.define('required', {id:'SCRIVENER_NAME', errMsg: "已勾選他項權利證明書，請輸入代書姓名或ID" });
			//	validates.valid.define('required', {id:'SCRIVENER_ID', errMsg: "已勾選他項權利證明書，請輸入代書姓名或ID" });
			//}
			
			//20200623 申請書-200527001673:配合「不當招攬放款支給扣回辦法」，需比對房貸經手人與新契約經手人是否相同(含對保人)。
        	//故新增放款部法人金融科承辦案件(以下簡稱法金件)於「匯款文件輸入作業」需輸入對保人ID
			//若「對保人ID」未輸入，顯示錯誤訊息："請輸入對保人ID"
			if ($F('GUARANTOR_ID') == ''){
				validates.valid.define('required', {id:'GUARANTOR_ID', errMsg: "請輸入對保人ID" });
			}
			
			//若「對保日」未輸入，顯示錯誤訊息："請輸入對保日"
			//1050205 林宏奇(放款推展科):一律檢核對保日須輸入
			//2019-05-17承辦科別為總公司不更新對保人資訊，不需要輸入對保日期
			if ($F('GUARANTOR_DATE') == ''){
				validates.valid.define('required', {id:'GUARANTOR_DATE', errMsg: "請輸入對保日" });
			}

			//若「授信行業別」未輸入，顯示錯誤訊息："請輸入授信行業別"			
			if ($F('CRED_BUSINESS') == ''){
				validates.valid.define('required', {id:'CRED_BUSINESS', errMsg: "請輸入授信行業別" });
			} else { //若「授信行業別」長度不為6碼，顯示錯誤訊息："請輸入6碼授信行業別"
				validates.valid.define('validCredBusiness', {id:'CRED_BUSINESS', errMsg: "請輸入6碼授信行業別" });
			}
			
			//若「理財連結帳號」有輸入但有非數字，顯示錯誤訊息："理財連結帳號需為數字格式"
			if ($F('MM_ACCOUNT') != ''){
				validates.valid.define('validate-number', {id:'MM_ACCOUNT', errMsg: "理財連結帳號需為數字格式" });
			}
			
			//若繳別未輸入，顯示錯誤訊息："請輸入繳別"
			if ($F('PAY_FREQ') == ''){
				validates.valid.define('required', {id:'PAY_FREQ', errMsg: "請輸入繳別" });
			}

		},
		// 清除檢核設定及記錄
		clear: function(){
			validates.valid.reset();
			validates.valid.clear();
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSB20100" , "匯款文件", "匯款文件輸入作業" );
			
			// 檢核初始化
			validates.initValidation();

			$('btn_query').observe('click', actions.doQuery ); //查詢按鈕
			
			$('btn_insert').observe('click', actions.doInsertCheck ); //新增按鈕
			
			$('btn_update').observe('click', actions.doUpdateCheck ); //修改按鈕
			
			$('btn_eland').observe('click', actions.doEland ); //電子謄本查詢按鈕
			
			$('btn_elandImage').observe('click', actions.doElandImage ); //電子謄本影像按鈕
			
			$('btn_landInput').observe('click', actions.doLandInput ); //地政輸入按鈕
			
			$('btn_remitInput').observe('click', actions.doRemitInput ); //匯款輸入按鈕
			
			$('btn_set').observe('click', actions.doSet ); //設定按鈕
			
			$('btn_cancel').observe('click', actions.doCancel ); //取消按鈕
			
			$('btn_tranImage').observe('click', actions.doTranImage );//20190223 匯款影像
			
			
			buttonAuth();
			
			if ($F('TYPE') == '1'){
				$('blockC').hide();
				$('blockE').hide();
			}
			
			autoFormatToDate();

			displayMessage();
			
			if ($F('INPUT') == '') {
				// 保留參數管理-取得受理編號
				$('INPUT').value = CSRUtil.keepParamsManager.get('APPLY_ID');			
			}
			//若是回上頁所發送回來的，還原 form 的輸入欄值後，執行重新查詢
			if (CSRUtil.isBackLink('form1')){
				actions.doQuery();
			}
			
			//190321:有接值，執行初始查詢
			if($F('INPUT')){
				actions.doQuery();
			}
			
		}// end initApp()--
	}// end return--
}// end DSB20100

//交易憑證
function OpenNewWindow(eviurl) {
	window.open(eviurl,"eDoc","menubar=0,resizable=yes,scrollbars=yes,directories=0,toolbar=0,height=500,width=650");
}

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form name="form1" id="form1" method="post" style="MARGIN: 0px">
		<table id="blockA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td class="tbYellow" width="25%" >
					<input id="QUERY_TYPE_1" name="QUERY_TYPE" class="validate-one-required" type="radio" value="1" checked >受理編號
					<input id="QUERY_TYPE_2" name="QUERY_TYPE" class="validate-one-required" type="radio" value="2" >貸款帳號
				</td>
				<td  class="tbYellow2" width="50%" >
					<input id="INPUT" name="INPUT" type="text" size="13" maxLength="11" fieldName="查詢條件" value="${INPUT_VALUE}">
				</td>
				<td class="tbYellow2" width="25%" align="center">
				    <input type="button" id="btn_query" value="查詢" class="button">
				</td>
			</tr>
			<tr>
				<td colspan="3" align="center">
					<input type="button" id="btn_insert" value="新增" class="button">
					<input type="button" id="btn_update" value="修改" class="button">
					<input type="button" id="btn_eland" value="電子謄本查詢" class="button">
					<input type="button" id="btn_elandImage" value="電子謄本影像" class="button">
					<input type="button" id="btn_tranImage" value="匯款影像" class="button"> <%--20190223 增加匯款影像--%>
					<input type="hidden" id="TYPE" name="TYPE" value="${TYPE}">
				</td>
			</tr>
		</table>
		<table id="blockB" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td class="tbYellow" width="15%">受理編號</td>
				<td class="tbYellow2" width="18%" id="APPLY_ID"></td>
				<td class="tbYellow" width="15%">借款人姓名</td>
				<!-- [20240607] 難字調整 -->
				<td class="tbYellow2" width="19%" id="BORROW_NAME" style="font-family:'EUDC'"></td>
				<input id="BORROW_NAME_INPUT" name="BORROW_NAME_INPUT" type="hidden" alt="ch">
				<td class="tbYellow" width="15%">借款人ID</td>
				<td class="tbYellow2" width="18%" id="BORROW_ID"></td>
				<input id="CRED_DEPT" type="hidden">
				<input id="isGet" type="hidden">
				<input id="IMG_CASE_ID" name="IMG_CASE_ID" type="hidden"><%--20190223 影像編號 --%>
			</tr>
		</table>
		<table id="blockC" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td class="tbYellow0" align="center" colspan="3">
					<b>文件項目</b>					
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" width="36%">
					<input id="RECEIPT" type="checkbox">借據&nbsp;&nbsp;&nbsp;
					利率調整方式：
					<select id="FLOAT_TYPE" fieldName="利率調整方式">
						<option value="" selected>請選擇</option>
						<c:forEach var="map" items="${FLOAT_TYPE_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow2" width="32%">
					<input id="GAGE_SETTING" type="checkbox">抵押權設定契約書
				</td>
				<td class="tbYellow2" width="32%">
					<input id="BANKBOOK" type="checkbox">存摺封面影本
				</td>
			</tr>
			<tr>
				<td class="tbYellow2">
					<input id="LAND_COPY" type="checkbox">土地及建物謄本
				</td>
				<td class="tbYellow2">
					<input id="RECOGNIZANCE" type="checkbox">切結書
				</td>
				<td class="tbYellow2">
					<input id="FIREINSU_RECEIPT" type="checkbox">火災保險單正本及收據副本
				</td>
			</tr>
			<tr>
				<td class="tbYellow2">
					<input id="ATM_RECEIPT" type="checkbox">電子化交易申請書
				</td>
				<td class="tbYellow2">
					<input id="OTHER_RIGHT" type="checkbox">他項權利證明書
					<input type="button" id="btn_landInput" value="地政輸入" class="button">
				</td>
				<td class="tbYellow2">
					<input id="CONSENT" type="checkbox">匯款同意書
					<input type="button" id="btn_remitInput" value="匯款輸入" class="button">
				</td>
			</tr>
			<tr>
				<td class="tbYellow2">
					<input id="MULTI_REMIT_FORM" type="checkbox">房貸分次動撥申請
				</td>
				<td class="tbYellow2">	
					繳別：
					<select id="PAY_FREQ" fieldName="繳別">
						<option value="" selected>請選擇</option>
						<c:forEach var="map" items="${PAY_FREQ_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>				
				</td>
				<td class="tbYellow2">				
				</td>
			</tr>
		</table>
		<table id="blockD" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td class="tbYellow0" align="center" colspan="3">
					<b>切結項目</b>					
				</td>
			</tr>
			<tr align="center">
				<td class="tbYellow" width="36%">※共同行銷(新版)</td>
				<td class="tbYellow" width="32%">(舊版)僅供查詢用</td>
				<td class="tbYellow" width="32%">其他</td>
			</tr>
			<tr>
				<td class="tbYellow2">
					1.<input id="BORR_SHARE_Y" type="checkbox">同意提供各子公司往來交易資料<br>
					&nbsp;&nbsp;(1)<input id="BORR_SHARE_BANK" type="checkbox">僅提供國泰世華銀行<br>
					&nbsp;&nbsp;(2)<input id="BORR_SHARE_CENTURY" type="checkbox">僅提供國泰世紀產險<br>
					&nbsp;&nbsp;(3)<input id="BORR_SHARE_SECURITIES" type="checkbox">僅提供國泰綜合證券
				</td>
				<td class="tbYellow2" valign="top">
					<input id="BORR_SHARE1" type="checkbox">同意基本資料共用
				</td>
				<td class="tbYellow2" valign="top">
					<input id="ORIGINAL" type="checkbox">採用舊版切結
				</td>
			</tr>
			<tr>
				<td class="tbYellow2">
					2.<input id="BORR_SHARE_O" type="checkbox">不同意提供往來交易資料
				</td>
				<td class="tbYellow2" rowspan="3" valign="top">
					<input id="BORR_SHARE2" type="checkbox">同意帳務，信用，投資，保險資料共用
				</td>
				<td class="tbYellow2">
					<input id="INSU_FREE" type="checkbox">贈送火險地震險切結
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" rowspan="2" valign="top">
					3.<input id="BORR_SHARE_N" type="checkbox">不同意提供基本及往來交易資料
				</td>
				<td class="tbYellow2">
					<input id="FIREINSU_TRAN" type="checkbox">火險轉帳切結
				</td>
			</tr>
			<tr>
				<td class="tbYellow2">
					<input id="FIREINSU_EXPENSE" type="checkbox">火險掛帳管費切結
					<input type="hidden" name="ISSUE_CODE" id="ISSUE_CODE" class="textBox2" maxLength="5" size="10" value="" />
				</td>
			</tr>
		</table>
			</form>
		<table id="blockE" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td class="tbYellow0" align="center" colspan="6">
					<b>輸入資料</b>					
				</td>
			</tr>
			<tr>
				<td class="tbYellow">代書ID</td>
				<td class="tbYellow2">
					<input id="SCRIVENER_ID" name="SCRIVENER_ID" type="text" size="12" maxLength="10" fieldName="代書ID">
				</td>
				<td class="tbYellow">代書姓名</td>
				<%-- [20240607] 難字調整 --%>
				<td class="tbYellow2">
					<input id="SCRIVENER_NAME" name="SCRIVENER_NAME" type="text" size="15" fieldName="代書姓名" alt="ch">
				</td>
				<td class="tbYellow" >是否為特約代書</td>
				<td class="tbYellow2" id="IS_AGENCY"></td>
			</tr>
			<tr>
				<td class="tbYellow">對保人ID</td>
				<td class="tbYellow2">
					<input id="GUARANTOR_ID" name="GUARANTOR_ID" type="text" size="12" maxLength="10" fieldName="對保人ID" >
				</td>
				<td class="tbYellow">對保日</td>
				<td class="tbYellow2">
					<input name="GUARANTOR_DATE" id="GUARANTOR_DATE" datatype="ROCDate" type="text" class="textBox2 validate-ROCDate" fieldName="對保日" size="10" maxlength="7"> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('GUARANTOR_DATE'))">
				</td>
				<td class="tbYellow">授信行業別</td>
				<td class="tbYellow2">
					<input id="CRED_BUSINESS" name="CRED_BUSINESS" type="text" size="8" maxLength="6" fieldName="授信行業別">
				</td>
			</tr>
			<tr>
				<td class="tbYellow">設定契約書領用序號</td>
				<td class="tbYellow2" id="X104_SEQ_NO"></td>
				<td class="tbYellow">設定契約書領用代書</td>
				<td class="tbYellow2" id="X104_SCRIVENER_NAME" colspan="3"></td>
			</tr>
			<tr>
				<td class="tbYellow">動撥指定帳號</td>
				<td class="tbYellow2">
					<input id="REMIT_ACCOUNT1" name="REMIT_ACCOUNT1" type="text" size="5" maxLength="3">
					<input id="REMIT_ACCOUNT2" name="REMIT_ACCOUNT2" type="text" size="6" maxLength="4">
					<input id="REMIT_ACCOUNT3" name="REMIT_ACCOUNT3" type="text" size="18" maxLength="16">
				</td>
				<td class="tbYellow">理財連結帳號</td>
				<td class="tbYellow2" colspan="3">
					<input id="MM_ACCOUNT" name="MM_ACCOUNT" type="text" size="18" maxLength="16"  fieldName="理財連結帳號">
					<span id="ACCOUNT_STATUS_NM"></span>
					<input type="button" id="btn_set" value="設定" class="button">
					<input type="button" id="btn_cancel" value="取消" class="button">
				</td>
			</tr>
			<tr>
				<td class="tbYellow">理財型預定生效日</td>
				<td class="tbYellow2" colspan="5">
					<input name="LOAN_DATE_M" id="LOAN_DATE_M" datatype="ROCDate" type="text" class="textBox2 validate-ROCDate" fieldName="理財型預定生效日" size="10" maxlength="7"> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('LOAN_DATE_M'))">
					<font color="red">僅申請理財型且無首次動撥之案件請輸入預定理財型生效日</font>
				</td>
			</tr>
			<tr>
				<td align="center" colspan="6">
					<span id="blockF"></span>
				</td>
			</tr>
		</table>

</body>
</html>