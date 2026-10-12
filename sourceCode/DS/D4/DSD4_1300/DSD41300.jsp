<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSD41300.jsp
功能：清償補發作業
作者：余凱鈞
完成：2014/11/13

[20240328]
難字調整
高強禾
 -->
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible" content="IE=5.5"> 

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
 
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src="${htmlBase}/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
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
Event.observe(window, 'load', new DSD41300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSD41300(){
	var grid;
	var tmpMap;
	var APPLY_REASONList=<c:out value="${APPLY_REASONList}" default="[]" escapeXml="false" />;
	var REJECT_REASONList=<c:out value="${REJECT_REASONList}" default="[]" escapeXml="false" />;
	var selectMap=<c:out value="${selectMap}" default="[]" escapeXml="false" />;
	var SYS_DATE = "${SYS_DATE}";
	var valid1;
	
	function initValidation(){
		//新增/修改用檢核			
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	;
		valid1.define( "required", { id: "RECEIPT_SERNO" , errMsg:"單據序號不可空白!" } );
	}
		
	//建立 ajax request 物件
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1300/');
	
	//按鈕授權
	function buttonAuth(){
		var authButtons = {
			B0199:"BTN_CONFIRM", //確認入帳
			B0200:"BTN_ACNTCANCEL", //入帳轉出
			B0050:"BTN_REJECTENTER", //退費輸入
			B0051:"BTN_REJECTCONFIRM" //退費審核		
		};		
		<dz:grantButtons FUNC_ID="DSD41300"/>
	};
	
	var buttons={
		//取得查詢條件
		getReqMap : function(){
			
			var reqMap={};
			$w('LOAN_ID BORROW_ID BORROW_NAME APPLY_STATUS INPUT_DATES INPUT_DATEE').each(function(ele){
				reqMap[ele] = $(ele).value || '';
			})

			return reqMap;
		},
		//查詢
		doQuery : function(){
			$('table2').hide();	
			
			var LOAN_ID = $F('LOAN_ID');
			var BORROW_ID = $F('BORROW_ID');
			var BORROW_NAME = $F('BORROW_NAME');
			var APPLY_STATUS = $F('APPLY_STATUS');
			var INPUT_DATES = $F('INPUT_DATES');
			var INPUT_DATEE = $F('INPUT_DATEE');
			
			var check1 = (!LOAN_ID && !BORROW_ID && !BORROW_NAME) ;			
			if(check1 && (!APPLY_STATUS && !INPUT_DATES && !INPUT_DATEE)){
				alert("請輸入貸款帳號/借款人ID/借款人姓名任一個查詢條件或是以申請狀態+輸入日期區間做查詢!");
				return;
			}
			if(check1){
				if(!APPLY_STATUS || !INPUT_DATES || !INPUT_DATEE){
					alert("不以貸款帳號/借款人ID/借款人姓名查詢時，申請狀態及輸入日期區間不可為空!");
					return;
				}				
			}
			
			var reqMap = buttons.getReqMap();	
			
			ajaxRequest.post( 'query', {reqMap: Object.toJSON(reqMap)}
				,function(resp){
					$('RECEIPT_SERNO').value = resp.RECEIPT_SERNO || '';
					grid.load(resp.rtnList||[]);				
				},function(resp){
					grid.load([]);	
				});			
		},
		//新增
		doInsert : function(){
			valid1.reset();	
			var reqList = grid.getCheckedRecord();	
			if(reqList.length == 0){
				alert("請選取一筆欲新增資料");
				return;
			}	
			
			var APPLY_AMT = reqList[0]['APPLY_AMT'];
			if(!(APPLY_AMT > 0 || APPLY_AMT === 0)){
				alert("請輸入正確的手續費");
				return;
			}	
			
			if(APPLY_AMT > 0 && !(APPLY_AMT === 0) ){
				if(!valid1.validate()){
					return;
				}
			}
		
			var LOAN_ID = $F('LOAN_ID');
			var BORROW_ID = $F('BORROW_ID');
			var BORROW_NAME = $F('BORROW_NAME');
			var APPLY_STATUS = $F('APPLY_STATUS');
			var INPUT_DATES = $F('INPUT_DATES');
			var INPUT_DATEE = $F('INPUT_DATEE');
			
			var check1 = (!LOAN_ID && !BORROW_ID && !BORROW_NAME) ;			
			if(check1 && (!APPLY_STATUS && !INPUT_DATES && !INPUT_DATEE)){
				alert("請輸入貸款帳號/借款人ID/借款人姓名任一個查詢條件或是以申請狀態+輸入日期區間做查詢!");
				return;
			}
			if(check1){
				if(!APPLY_STATUS || !INPUT_DATES || !INPUT_DATEE){
					alert("不以貸款帳號/借款人ID/借款人姓名查詢時，申請狀態及輸入日期區間不可為空!");
					return;
				}				
			}			
						
			var reQueryMap = buttons.getReqMap();	
			
			ajaxRequest.post( 'insert' ,{'reqMap':Object.toJSON(reqList[0]),'reQueryMap':Object.toJSON(reQueryMap),'RECEIPT_SERNO':$F('RECEIPT_SERNO')},
				function(resp){	
					$('table2').hide();		
					$('RECEIPT_SERNO').value = resp.RECEIPT_SERNO || '';					
					grid.load(resp.rtnList || []);
					if(resp.isWriteDK){ //若金額大於0才需開立收據
						buttons.doPrint(resp.rtnMap, false);
					}
				} 
			);				
		},	
		//列印
		doPrint: function(rtnMap, isReject) {   
			if(!isReject){
				ajaxRequest.post( 'print' , { 'info' : Object.toJSON(rtnMap)},
							function(resp){			
								RPTUtil.executePrintByResponse(resp, true);
							}
						);
			} else {
				ajaxRequest.post( 'rejectPrint' , { 'info' : Object.toJSON(rtnMap)},
						function(resp){			
							RPTUtil.executePrintByResponse(resp, true);
						}
					);			
			}
		},	
		//單據補發
		doReprint: function(rtnMap) {   
			valid1.reset();
			if(!valid1.validate()){
				return;
			}		
			var reQueryMap = buttons.getReqMap();	

			ajaxRequest.post( 'reprint' ,{'reqMap':Object.toJSON(rtnMap),'reQueryMap':Object.toJSON(reQueryMap),'RECEIPT_SERNO':$F('RECEIPT_SERNO')},
				function(resp){	
					$('table2').hide();		
					$('RECEIPT_SERNO').value = resp.RECEIPT_SERNO || '';					
					grid.load(resp.rtnList || []);
					buttons.doPrint(resp.rtnMap, false);
				}
			);	
		},				
		//修改
		doUpdate : function(){
			
			var reqList = grid.getCheckedRecord();	
			if(reqList.length == 0){
				alert("請選取一筆欲修改資料");
				return;
			}
			if(!reqList[0]['APPLY_STATUS']){
				alert("新增件不需修改");
				return;					
			}
			
			var LOAN_ID = $F('LOAN_ID');
			var BORROW_ID = $F('BORROW_ID');
			var BORROW_NAME = $F('BORROW_NAME');
			var APPLY_STATUS = $F('APPLY_STATUS');
			var INPUT_DATES = $F('INPUT_DATES');
			var INPUT_DATEE = $F('INPUT_DATEE');
			
			var check1 = (!LOAN_ID && !BORROW_ID && !BORROW_NAME) ;			
			if(check1 && (!APPLY_STATUS && !INPUT_DATES && !INPUT_DATEE)){
				alert("請輸入貸款帳號/借款人ID/借款人姓名任一個查詢條件或是以申請狀態+輸入日期區間做查詢!");
				return;
			}
			if(check1){
				if(!APPLY_STATUS || !INPUT_DATES || !INPUT_DATEE){
					alert("不以貸款帳號/借款人ID/借款人姓名查詢時，申請狀態及輸入日期區間不可為空!");
					return;
				}				
			}
			
			var reQueryMap = buttons.getReqMap();	

			ajaxRequest.post( 'update' ,{'reqMap':Object.toJSON(reqList[0]),'reQueryMap':Object.toJSON(reQueryMap),'RECEIPT_SERNO':$F('RECEIPT_SERNO')},
				function(resp){	
					$('table2').hide();		
					$('RECEIPT_SERNO').value = resp.RECEIPT_SERNO || '';					
					grid.load(resp.rtnList || []);
					if(resp.amtChange){ //若有修改金額才需作廢原收據，重新開立新收據
						buttons.doPrint(resp.rtnMap, false);
					}
				}
			);	
		},		
		//確認入帳
		doConfirm : function(){
			var reqList = grid.getCheckedRecord();	
			if(reqList.length == 0){
				alert("請選取一筆欲確認入帳資料");
				return;
			}
	
			var LOAN_ID = $F('LOAN_ID');
			var BORROW_ID = $F('BORROW_ID');
			var BORROW_NAME = $F('BORROW_NAME');
			var APPLY_STATUS = $F('APPLY_STATUS');
			var INPUT_DATES = $F('INPUT_DATES');
			var INPUT_DATEE = $F('INPUT_DATEE');
			
			var check1 = (!LOAN_ID && !BORROW_ID && !BORROW_NAME) ;			
			if(check1 && (!APPLY_STATUS && !INPUT_DATES && !INPUT_DATEE)){
				alert("請輸入貸款帳號/借款人ID/借款人姓名任一個查詢條件或是以申請狀態+輸入日期區間做查詢!");
				return;
			}
			if(check1){
				if(!APPLY_STATUS || !INPUT_DATES || !INPUT_DATEE){
					alert("不以貸款帳號/借款人ID/借款人姓名查詢時，申請狀態及輸入日期區間不可為空!");
					return;
				}				
			}
			
			var reQueryMap = buttons.getReqMap();	

			ajaxRequest.post( 'confirm' ,{'reqMap':Object.toJSON(reqList[0]),'reQueryMap':Object.toJSON(reQueryMap)},
				function(resp){	
					$('table2').hide();	
					$('RECEIPT_SERNO').value = resp.RECEIPT_SERNO || '';					
					grid.load(resp.rtnList || []);
				}
			);	
		},
		//入帳轉出
		doAcntCancel : function(){
			var reqList = grid.getCheckedRecord();	
			if(reqList.length == 0){
				alert("請選取一筆欲入帳轉出資料");
				return;
			}

			var LOAN_ID = $F('LOAN_ID');
			var BORROW_ID = $F('BORROW_ID');
			var BORROW_NAME = $F('BORROW_NAME');
			var APPLY_STATUS = $F('APPLY_STATUS');
			var INPUT_DATES = $F('INPUT_DATES');
			var INPUT_DATEE = $F('INPUT_DATEE');
			
			var check1 = (!LOAN_ID && !BORROW_ID && !BORROW_NAME) ;			
			if(check1 && (!APPLY_STATUS && !INPUT_DATES && !INPUT_DATEE)){
				alert("請輸入貸款帳號/借款人ID/借款人姓名任一個查詢條件或是以申請狀態+輸入日期區間做查詢!");
				return;
			}
			if(check1){
				if(!APPLY_STATUS || !INPUT_DATES || !INPUT_DATEE){
					alert("不以貸款帳號/借款人ID/借款人姓名查詢時，申請狀態及輸入日期區間不可為空!");
					return;
				}				
			}
			
			var reQueryMap = buttons.getReqMap();	

			ajaxRequest.post( 'acntCancel' ,{'reqMap':Object.toJSON(reqList[0]),'reQueryMap':Object.toJSON(reQueryMap)},
				function(resp){	
					$('table2').hide();	
					$('RECEIPT_SERNO').value = resp.RECEIPT_SERNO || '';					
					grid.load(resp.rtnList || []);
				}
			);
		},
		//退費輸入
		doRejectEnter : function(){
			var reqList = grid.getCheckedRecord();	
			if(reqList.length == 0){
				alert("請選取一筆欲退費輸入資料");
				return;
			}

			var LOAN_ID = $F('LOAN_ID');
			var BORROW_ID = $F('BORROW_ID');
			var BORROW_NAME = $F('BORROW_NAME');
			var APPLY_STATUS = $F('APPLY_STATUS');
			var INPUT_DATES = $F('INPUT_DATES');
			var INPUT_DATEE = $F('INPUT_DATEE');
			
			var check1 = (!LOAN_ID && !BORROW_ID && !BORROW_NAME) ;			
			if(check1 && (!APPLY_STATUS && !INPUT_DATES && !INPUT_DATEE)){
				alert("請輸入貸款帳號/借款人ID/借款人姓名任一個查詢條件或是以申請狀態+輸入日期區間做查詢!");
				return;
			}
			if(check1){
				if(!APPLY_STATUS || !INPUT_DATES || !INPUT_DATEE){
					alert("不以貸款帳號/借款人ID/借款人姓名查詢時，申請狀態及輸入日期區間不可為空!");
					return;
				}				
			}
			
			var reQueryMap = buttons.getReqMap();	

			ajaxRequest.post( 'rejectEnter' ,{'reqMap':Object.toJSON(reqList[0]),'reQueryMap':Object.toJSON(reQueryMap)},
				function(resp){	
					$('table2').hide();	
					$('RECEIPT_SERNO').value = resp.RECEIPT_SERNO || '';					
					grid.load(resp.rtnList || []);
				}
			);
		},
		//退費審核
		doRejectConfirm : function(){
			var reqList = grid.getCheckedRecord();	
			if(reqList.length == 0){
				alert("請選取一筆欲退費審核資料");
				return;
			}

			var LOAN_ID = $F('LOAN_ID');
			var BORROW_ID = $F('BORROW_ID');
			var BORROW_NAME = $F('BORROW_NAME');
			var APPLY_STATUS = $F('APPLY_STATUS');
			var INPUT_DATES = $F('INPUT_DATES');
			var INPUT_DATEE = $F('INPUT_DATEE');
			
			var check1 = (!LOAN_ID && !BORROW_ID && !BORROW_NAME) ;			
			if(check1 && (!APPLY_STATUS && !INPUT_DATES && !INPUT_DATEE)){
				alert("請輸入貸款帳號/借款人ID/借款人姓名任一個查詢條件或是以申請狀態+輸入日期區間做查詢!");
				return;
			}
			if(check1){
				if(!APPLY_STATUS || !INPUT_DATES || !INPUT_DATEE){
					alert("不以貸款帳號/借款人ID/借款人姓名查詢時，申請狀態及輸入日期區間不可為空!");
					return;
				}				
			}
			
			var reQueryMap = buttons.getReqMap();	

			ajaxRequest.post( 'rejectConfirm' ,{'reqMap':Object.toJSON(reqList[0]),'reQueryMap':Object.toJSON(reQueryMap)},
				function(resp){	
		        	$('table2').hide();	
					$('RECEIPT_SERNO').value = resp.RECEIPT_SERNO || '';					
					grid.load(resp.rtnList || []);
				}
			);
		},		
		//退費
		doReject : function(){
			var reqList = grid.getCheckedRecord();	
			if(reqList.length == 0){
				alert("請選取一筆欲退費資料");
				return;
			}

			var LOAN_ID = $F('LOAN_ID');
			var BORROW_ID = $F('BORROW_ID');
			var BORROW_NAME = $F('BORROW_NAME');
			var APPLY_STATUS = $F('APPLY_STATUS');
			var INPUT_DATES = $F('INPUT_DATES');
			var INPUT_DATEE = $F('INPUT_DATEE');
			
			var check1 = (!LOAN_ID && !BORROW_ID && !BORROW_NAME) ;			
			if(check1 && (!APPLY_STATUS && !INPUT_DATES && !INPUT_DATEE)){
				alert("請輸入貸款帳號/借款人ID/借款人姓名任一個查詢條件或是以申請狀態+輸入日期區間做查詢!");
				return;
			}
			if(check1){
				if(!APPLY_STATUS || !INPUT_DATES || !INPUT_DATEE){
					alert("不以貸款帳號/借款人ID/借款人姓名查詢時，申請狀態及輸入日期區間不可為空!");
					return;
				}				
			}
			
			var reQueryMap = buttons.getReqMap();	

			ajaxRequest.post( 'reject' ,{'reqMap':Object.toJSON(reqList[0]),'reQueryMap':Object.toJSON(reQueryMap)},
				function(resp){	
					$('table2').hide();		
					$('RECEIPT_SERNO').value = resp.RECEIPT_SERNO || '';					
					grid.load(resp.rtnList || []);		
					buttons.doPrint(resp.rtnMap, true);
				}
			);
		},
		//清除查詢欄位
		clearQry : function(event){
			var qryStr=this.id;
			$w("LOAN_ID BORROW_ID BORROW_NAME").each(function(QRY_KEY){
				if(QRY_KEY == qryStr){ return;}
				$(QRY_KEY).setValue('');
			});
		},
		//其他申請原因可填寫備註欄位
		/*APPLY_REASONChangeAPPLY_REASON_DESC: function(node, dataObj){		
			var val=node.value;
			var input = grid.getAutoInput(node,['APPLY_REASON_DESC'])[0];
			if(val=='99'){	
				input["APPLY_REASON_DESC"].disabled=false;
			}else{	
				input["APPLY_REASON_DESC"].disabled=true;
				input["APPLY_REASON_DESC"].value='';
				dataObj.APPLY_REASON_DESC = '';
			}		
		},*/
		//其他退費原因可填寫備註欄位
		REJECT_REASONChangeREJECT_REASON_DESC: function(node, dataObj){
		
			var val=node.value;
			var input = grid.getAutoInput(node,['REJECT_REASON_DESC'])[0];
			if(val=='99'){	
				input["REJECT_REASON_DESC"].disabled=false;
			}else{	
				input["REJECT_REASON_DESC"].disabled=true;
				input["REJECT_REASON_DESC"].value='';
				dataObj.REJECT_REASON_DESC = '';
			}		
		},
		//點選時，帶出流程中各作業日期、人員、單位
		insertTable2 : function(record){		
			$('CONFIRM_DATE').update(Date.toROC(record['CONFIRM_DATE'] || ''));
			$('CONFIRM_NM').update((record['CONFIRM_DEPT_NM']? record['CONFIRM_DEPT_NM']:'')+'&nbsp'+(record['CONFIRM_NM']? record['CONFIRM_NM']:'') || '');
			$('ACNT_CANCEL_DATE').update(Date.toROC(record['ACNT_CANCEL_DATE'] || ''));
			$('ACNT_CANCEL_NM').update((record['ACNT_CANCEL_DEPT_NM']? record['ACNT_CANCEL_DEPT_NM']:'')+'&nbsp'+(record['ACNT_CANCEL_NM']? record['ACNT_CANCEL_NM']:'') || '');
			$('REJECT_INPUT_DATE').update(Date.toROC(record['REJECT_INPUT_DATE'] || ''));
			$('REJECT_INPUT_NM').update((record['REJECT_INPUT_DEPT_NM']? record['REJECT_INPUT_DEPT_NM']:'')+'&nbsp'+(record['REJECT_INPUT_NM']? record['REJECT_INPUT_NM']:'') || '');
			$('REJECT_CONFIRM_DATE').update(Date.toROC(record['REJECT_CONFIRM_DATE'] || ''));
			$('REJECT_CONFIRM_NM').update((record['REJECT_CONFIRM_DEPT_NM']? record['REJECT_CONFIRM_DEPT_NM']:'')+'&nbsp'+(record['REJECT_CONFIRM_NM']? record['REJECT_CONFIRM_NM']:'') || '');
			$('REJECT_DATE').update(Date.toROC(record['REJECT_DATE'] || ''));
			$('REJECT_NM').update((record['REJECT_DEPT_NM']? record['REJECT_DEPT_NM']:'')+'&nbsp'+(record['REJECT_NM']? record['REJECT_NM']:'') || '');
		},
		//選擇狀態時，需輸入日期區間查詢
		doEnterDates : function(){	
			if($F('APPLY_STATUS')){
				if(!$F('INPUT_DATES')){
					$('INPUT_DATES').value = SYS_DATE;
				}
				if(!$F('INPUT_DATEE')){
					$('INPUT_DATEE').value = SYS_DATE;
				}
				$('INPUT_DATES').disabled = false;				
				$('INPUT_DATEE').disabled = false;
			}else{
				$('INPUT_DATES').value = "";
				$('INPUT_DATEE').value = "";	
				$('INPUT_DATES').disabled = true;				
				$('INPUT_DATEE').disabled = true;				
			}
		}		
	}

	return {
			
		initApp : function(){
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>
			PageUI.createPageWithAllBodySubElement('DSD41300', '清償作業', '清償補發作業');
			grid = new TableUI(
				{table: $("grid"), allSortable: true, overDiv:true, pageSize:10, 				
				autoCheckBox:{
				    text:'選取',
					type:'radio',
					isSelectAll:true,
                    /*genRule:function(record , value){ 
						return (record.APPLY_STATUS == '06') ? false : true; 
					},*/
					action: function(radio , boxStatus , records ){
						
						var node = $(radio).up('tr');
						var dataObj = grid.isNew ? grid.getDataObj(radio) : node.dataObj;
						if(!radio.checked){
							$('table2').hide();
						}else{
							buttons.insertTable2(records[0]);
							$('table2').show();
						}
						
					}						
				},	
				afterLoad : function() {
					$$('#grid select').each(
						function(elem){
							elem.simulate('change');
						}							
					);															
					<%-- [20240328] 難字調整 --%>
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},				
				<%-- [20240328] 難字調整 --%>
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[									
					{header:"貸款帳號",key:"C100_LOAN_ID"},
					<%-- [20240328] 難字調整：借款人姓名 --%>
					{header:"借款人姓名",key:"BORROW_NAME", attrs:{ style:"font-family:'EUDC'" },
						render:function(record,value){  // 非輸入模式時的處理
							return value + '<br>' + record.BORROW_ID;
						} 
					},		
					{header:"契約狀況",key:"LOAN_STATUS_NM"},							
					{header:"申請項目",key:"APPLY_ITEM",
						/*input:{type:"select" ,opts : APPLY_ITEMList,					
							genRule:function(record , value){
								return !record.APPLY_STATUS  ? true : false;
							}													
						}
						,render:function(record,value){  // 非輸入模式時的處理
							return record.APPLY_ITEM_NM ? record.APPLY_ITEM_NM: '';
						}*/
						render:function(record,value){
							if(record.APPLY_STATUS){
								return record.APPLY_ITEM_NM ? record.APPLY_ITEM_NM: '';														
							}
							var select = new Element('select',{name: 'APPLY_ITEM'});

							var list=selectMap[record.LOAN_STATUS]||[];
							for(var i=0;i<list.length;i++){
								var data = list[i];
								select.add(new Option(data.APPLY_ITEM_NM,data.APPLY_ITEM));
							}
							select.observe('change', function(event){
								var dataObj = grid.isNew ? grid.getDataObj(this) : this.up('tr').dataObj;
								dataObj.APPLY_ITEM=this.value;
							});						

							return select;
						}						
					},
					{header:"序號",key:"SER_NO"},						
					/*{header:"申請原因",key:"APPLY_REASON",
						input:{type:"select", opts : APPLY_REASONList,
							action:function( node , dataObj , textDiv, orgData ){  
								buttons.APPLY_REASONChangeAPPLY_REASON_DESC(node, dataObj[0]);
							},					
							genRule:function(record , value){
								return !record.APPLY_STATUS || record.APPLY_STATUS == '01' ? true : false;
							}	
						},					
						render:function(record,value){  // 非輸入模式時的處理
							return record.APPLY_REASON_NM ? record.APPLY_REASON_NM: '';
						} 			
					},*/	
					{header:"申請原因",key:"APPLY_REASON_DESC",					
					    input:{ type:'TEXT' , size:15 , maxlength:40,
							genRule:function(record , value){
								return !record.APPLY_STATUS || record.APPLY_STATUS == '01' ? true : false;
							}		
						}			
					},							
					{header:"手續費",key:"APPLY_AMT", sortRule: "number",
						input:{type:'number', size:10 , maxlength:10,
							genRule:function(record , value){
								return !record.APPLY_STATUS || record.APPLY_STATUS == '01' ? true : false;
							}					
						},
						render :function(record, value){
							return value || value === 0 ? CSRUtil.$fmt(value,'#,###') : '';
						}
					},
				    {header:"申請狀態",key:"APPLY_STATUS_NM",
						render : function(record, value){
							return value ? value : '新增';						
						}
					},					
					{header:"退費原因",key:"REJECT_REASON",
						input:{type:"select" ,opts : REJECT_REASONList,
							action:function( node , dataObj , textDiv, orgData ){  
								buttons.REJECT_REASONChangeREJECT_REASON_DESC(node, dataObj[0]);
							},					
							genRule:function(record , value){
								return record.APPLY_STATUS == '01' ? true : false;
							}	
						},					
						render:function(record,value){  // 非輸入模式時的處理
							if(record.APPLY_STATUS == "05" && record.APPLY_AMT){ //已退費才可以補發
								var button = new Element('input',{name: 'REREJECTPRINT', type:"button", value:"簽收單補發"});
								button.className = 'button';
								var span = new Element('span',{align: "center"});
								
								button.onclick = function(){buttons.doPrint(record, true)};					

								span.insert(record.REJECT_REASON_NM ? record.REJECT_REASON_NM: '');
								span.insert("<br>");							
								span.insert(button);
								return span;
							}
													
							return record.REJECT_REASON_NM ? record.REJECT_REASON_NM: '';
						} 						
					},				
					{header:"其他退費原因",key:"REJECT_REASON_DESC",					
					    input:{ type:'TEXT' , size:15 , maxlength:40, attrs :{disabled :true},
							genRule:function(record , value){
								return record.APPLY_STATUS == '01' ? true : false;
							}	
						}						
					},															
					{header:"單據序號",key:"RECEIPT_SERNO",
						render:function(record,value){
							if(value && (record.APPLY_STATUS == "01" || record.APPLY_STATUS == "02")){ //待/已入帳才可以單據補發
								var button = new Element('input',{name: 'REPRINT', type:"button", value:"單據補發"});
								button.className = 'button';
								var span = new Element('span',{align: "center"});
								
								button.onclick = function(){buttons.doReprint(record)};					

								span.insert(value);
								span.insert("<br>");							
								span.insert(button);
								return span;
							}
							
							return value;
						}													
					},
					{header:"輸入日期",key:"INPUT_DATE",sortRule: "date"},		
					<%-- [20240328] 難字調整：輸入人員 --%>
					{header:"輸入人員",key:"INPUT_NM", attrs:{ style:"font-family:'EUDC'" },
						render:function(record,value){
							return record.INPUT_DEPT_NM ? record.INPUT_DEPT_NM + '<br>' + value : value;
						} 						
					}       					
				]
			});
			
			initValidation();
			
			autoCreateDate(); 
			autoFormatToDate();	
			
			buttonAuth();
			$('table2').hide();
			
			$('LOAN_ID').observe('click', buttons.clearQry); //貸款帳號
			$('BORROW_ID').observe('click', buttons.clearQry); //借款人ID
			$('BORROW_NAME').observe('click', buttons.clearQry); //借款人姓名
			
			$('BTN_QUERY').observe('click',buttons.doQuery);
			$('BTN_INSERT').observe('click',buttons.doInsert);
			$('BTN_UPDATE').observe('click',buttons.doUpdate);
			$('BTN_CONFIRM').observe('click',buttons.doConfirm);			
			$('BTN_ACNTCANCEL').observe('click',buttons.doAcntCancel);
			$('BTN_REJECTENTER').observe('click',buttons.doRejectEnter);
			$('BTN_REJECTCONFIRM').observe('click',buttons.doRejectConfirm);
			$('BTN_REJECT').observe('click',buttons.doReject);	
			
			$('APPLY_STATUS').observe('change',buttons.doEnterDates);	
			
			fix();	
			//初始頁面alert訊息用	
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='table1'>
		<tr>
			<td class="tbYellow" width="10%">貸款帳號</td>		
			<td class="tbYellow2" width="15%">
				<input id="LOAN_ID" name="LOAN_ID" type='text' class= 'textBox2' size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()"/>
			</td>		
			<td class="tbYellow" width="10%">借款人ID</td>		
			<td class="tbYellow2" width="15%">
				<input id="BORROW_ID" name="BORROW_ID" type='text' class= 'textBox2' size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()"/>
			</td>		
			<td class="tbYellow" width="10%">借款人姓名</td>		
			<td class="tbYellow2" width="15%">
				<%-- [20240328] 難字調整：借款人姓名 --%>
				<input id="BORROW_NAME" name="BORROW_NAME" type='text' class= 'textBox2' size='20' maxlength='60' alt="ch" />
			</td>					
			<td class="tbYellow2" width = "25%" align= "center" rowspan="2">
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
			</td>				
		</tr>
		<tr>	
			<td class="tbYellow" width = "10%">申請狀態</td>
			<td class="tbYellow2" width = "15%">
				<select id="APPLY_STATUS" name='APPLY_STATUS'>
					<option value="">全部</option>
					<c:forEach var="map" items="${APPLY_STATUSList}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select> 
			</td>		
			<td class = "tbYellow" width = "10%">輸入日期</td>
			<td class = "tbYellow2" width = "40%" colspan="3">
				<input type='text' id='INPUT_DATES' class="textBox2" name='INPUT_DATES' maxlength='7' size='8' datatype="ROCDate" disabled/>
				~
				<input type='text' id='INPUT_DATEE' class="textBox2" name='INPUT_DATEE' maxlength='7' size='8' datatype="ROCDate" disabled/>
			</td>	
		</tr>			
		<tr>
			<td class="tbYellow2" colspan='9' align= "center">收據列印-單據序號：
				<input id="RECEIPT_SERNO" type="text" class="textBox2" size='15' maxlength="10" />	
				<input id="BTN_INSERT" type="button" value="新增" class="button" >	
				<input id="BTN_UPDATE" type="button" value="修改" class="button" >										
				<input id="BTN_CONFIRM" type="button" value="確認入帳" class="button" >	
				<input id="BTN_ACNTCANCEL" type="button" value="入帳轉出" class="button" >					
				<input id="BTN_REJECTENTER" type="button" value="退費輸入" class="button" >	
				<input id="BTN_REJECTCONFIRM" type="button" value="退費審核" class="button" >	
				<input id="BTN_REJECT" type="button" value="退費" class="button" >										
			</td>		
		</tr>
	</table>
	<table id = "grid" ></table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='table2'>
		<tr>					
			<td class="tbYellow" align="center" width = "10%">確認入帳日期</td>
			<td class="tbYellow2" width = "15%" >
				<span id="CONFIRM_DATE"></span>
			</td>
			<td class="tbYellow" align="center" width = "10%">確認入帳人員</td>
			<td class="tbYellow2" width = "15%" >
				<span id="CONFIRM_NM" style="font-family:'EUDC'"></span>
			</td>			
			<td class="tbYellow" align='center' width = "10%">入帳轉出日期</td>
			<td class="tbYellow2" width = "15%">
				<span id="ACNT_CANCEL_DATE"></span>
			</td>
			<td class="tbYellow" align='center' width = "10%">入帳轉出人員</td>
			<td class="tbYellow2" width = "15%">
				<span id="ACNT_CANCEL_NM" style="font-family:'EUDC'"></span>
			</td>				
		</tr>	
		<tr>					
			<td class="tbYellow" align="center" width = "10%">退費輸入日期</td>
			<td class="tbYellow2" width = "15%" >
				<span id="REJECT_INPUT_DATE"></span>
			</td>
			<td class="tbYellow" align="center" width = "10%">退費輸入人員</td>
			<td class="tbYellow2" width = "15%" >
				<span id="REJECT_INPUT_NM" style="font-family:'EUDC'"></span>
			</td>			
			<td class="tbYellow" align='center' width = "10%">退費審核日期</td>
			<td class="tbYellow2" width = "15%">
				<span id="REJECT_CONFIRM_DATE"></span>
			</td>
			<td class="tbYellow" align='center' width = "10%">退費審核人員</td>
			<td class="tbYellow2" width = "15%">
				<span id="REJECT_CONFIRM_NM" style="font-family:'EUDC'"></span>
			</td>				
		</tr>
		<tr>					
			<td class="tbYellow" align="center" width = "10%">退費日期</td>
			<td class="tbYellow2" width = "15%" >
				<span id="REJECT_DATE"></span>
			</td>
			<td class="tbYellow" align="center" width = "10%">退費人員</td>
			<td class="tbYellow2" width = "15%" >
				<span id="REJECT_NM" style="font-family:'EUDC'"></span>
			</td>			
			<td class="tbYellow" align='center' width = "10%"></td>
			<td class="tbYellow2" width = "15%">
				<span ></span>
			</td>
			<td class="tbYellow" align='center' width = "10%"></td>
			<td class="tbYellow2" width = "15%">
				<span ></span>
			</td>				
		</tr>		
	</table>
</form>
</body>
</html>