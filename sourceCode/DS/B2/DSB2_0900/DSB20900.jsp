<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB20900.jsp
作者：吳學建
功能：貸款契約書交付控管作業。
完成：2015/09/21

[20190730] 修改件
增加input:交付姓名(羅馬拼音)
[20190807] 問題單 20190806132006	
畫面「新增/修改」時，需檢核交付姓名羅馬拼音不可為半型

[20190927] 問題單 	20190927111754
羅馬拼音半形檢查改為tableUI檢核

[20201028] 立案單(修改件) 	201027001579
交付方式下拉選單若選「服中臨櫃」，查詢服務中心名稱，連動寄送地址郵遞區號與地址欄位
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<title></title>
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

<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>      <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>      <%-- 標準外框表格 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>     <%-- 表格用 --%>
<script type="text/javascript" src='${htmlBase}/CM/js/RPTUtil.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="${htmlBase}/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/suggest.js"></script>		<%-- 搜尋提示用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>

<script type='text/javascript'>

// 產生畫面物件
var DSB20900 = new DSB20900();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB20900.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB20900(){
	
	var grid;
	//[20201028] 修改交付方式下拉選單
	<%-- 交付方式 下拉選單--%>
	var SEND_KIND_LIST = [];

	<c:forEach var="map" items="${SEND_KIND_MAP}">
	SEND_KIND_LIST.push({key: '${map.key}', value: '${map.value}'});		
	</c:forEach>
	
	var sugeestInputList = [];
	
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			
			B0003:"btn_insert",<%--新增--%>
			B0004:"btn_update",<%--修改--%>
			B0028:"btn_confirm",<%--收執確認--%>
			B0008:"btn_reject",<%--退郵--%> 
			B0244:"btn_reSend",<%--補件查詢--%>
			B0245:"btn_sendprint",<%--郵寄列印--%>
			B0246:"btn_conprint", <%--通訊列印--%>
			B0247:"btn_signprint",<%--簽收條列印--%>
			B0248:"btn_print", <%--本息攤還試算列印--%>
			B0253:"btn_detailPrint"<%--匯款明細列印--%>
		};
		
		<dz:grantButtons FUNC_ID="DSB20900" ignored="false"/>
	}
	
	//檢核變數
	var valid1;	
	//全型檢核
	var validFull;	
	
	//畫面檢核
	function initValidation(){
	
	    Validation.addAllThese([
			[ 'check_DATE',  '貸放日期或輸入日期須擇一輸入',
				function(date1,date2,date3,date4,loan_id,custom_id){
					//當貸放日期無值  //且輸入日期無值，貸款帳號或客戶ID有輸入，則不檢核貸放日及輸入日
					if(Validation.get('IsEmpty').test(date1) && Validation.get('IsEmpty').test(date2)
						&& Validation.get('IsEmpty').test(date3) && Validation.get('IsEmpty').test(date4)
						&& Validation.get('IsEmpty').test(loan_id) && Validation.get('IsEmpty').test(custom_id)){
							return false;
					}
					
					return true;
				}
			],		
			[ 'check_LOAN_DATE',  '貸放日期需同時輸入或同時不輸入',
				function(date1,date2){
					if(!Validation.get('IsEmpty').test(date1)){
						if(Validation.get('IsEmpty').test(date2)){
							return false;
						}
					}
					
					if(!Validation.get('IsEmpty').test(date2)){
						if(Validation.get('IsEmpty').test(date1)){
							return false;
						}
					}
					
					return true
				}
			],
			[ 'check_INPUT_DATE',  '輸入日期需同時輸入或同時不輸入',
				function(date1,date2){
					if(!Validation.get('IsEmpty').test(date1)){
						if(Validation.get('IsEmpty').test(date2)){
							return false;
						}
					}
					
					if(!Validation.get('IsEmpty').test(date2)){
						if(Validation.get('IsEmpty').test(date1)){
							return false;
						}
					}
					
					return true
				}
			],
			[ 'check_LOAN_DATE_MONTH',  '貸放日期區間必在1個月內，請縮小查詢範圍',
				function(date1,date2){
					var check = true;
					if(!(Validation.get('IsEmpty').test(date1) || Validation.get('IsEmpty').test(date2))){
						var dt1 = date1;
						var theDLength = dt1.length;
						var d1;
						
						if(theDLength == 7){
							dt1 += '-01';
						}else if(theDLength != 10){
							return;
						}

						dt1.match(/^(\d{4})-(\d{2})-(\d{2})$/);
						d1 = new Date(RegExp.$1+"/"+RegExp.$2+"/"+RegExp.$3);
						
						var dt2 = date2;
						var theDLength2 = dt2.length;
						var d2;
						
						if(theDLength2 == 7){
							dt1 += '-01';
						}else if(theDLength2 != 10){
							return;
						}

						dt2.match(/^(\d{4})-(\d{2})-(\d{2})$/);
						d2 = new Date(RegExp.$1+"/"+RegExp.$2+"/"+RegExp.$3);
						
						var checkDate = ((d2-d1)/ (1000 * 60 * 60 * 24));
						return checkDate <= 31 && checkDate >=0
					}
					return check;
				}
			],
			//[20211112]承辦科別若選擇全部，貸放日期起訖皆預帶前一工作日，且區間不得大於1天
			[ 'check_LOAN_DATE_DAY',  '承辦科別若選全部，貸放日期區間不可大於１天',
				function(date1,date2){
					var check = true;
					if($F('CRED_DEPT') == ''){
						if(!(Validation.get('IsEmpty').test(date1) || Validation.get('IsEmpty').test(date2))){
							var dt1 = date1;
							var theDLength = dt1.length;
							var d1;
							
							if(theDLength == 7){
								dt1 += '-01';
							}else if(theDLength != 10){
								return;
							}

							dt1.match(/^(\d{4})-(\d{2})-(\d{2})$/);
							d1 = new Date(RegExp.$1+"/"+RegExp.$2+"/"+RegExp.$3);
							
							var dt2 = date2;
							var theDLength2 = dt2.length;
							var d2;
							
							if(theDLength2 == 7){
								dt1 += '-01';
							}else if(theDLength2 != 10){
								return;
							}

							dt2.match(/^(\d{4})-(\d{2})-(\d{2})$/);
							d2 = new Date(RegExp.$1+"/"+RegExp.$2+"/"+RegExp.$3);
							
							var checkDate = ((d2-d1)/ (1000 * 60 * 60 * 24));
							return checkDate <= 1 && checkDate >=0
						}
					}
					
					return check;
				}
			],
			[ 'check_INPUT_DATE_MONTH',  '輸入日期區間必在1個月內，請縮小查詢範圍',
				function(date1,date2){
					var check = true;
					if(!(Validation.get('IsEmpty').test(date1) || Validation.get('IsEmpty').test(date2))){
						var dt1 = date1;
						var theDLength = dt1.length;
						var d1;
						
						if(theDLength == 7){
							dt1 += '-01';
						}else if(theDLength != 10){
							return;
						}

						dt1.match(/^(\d{4})-(\d{2})-(\d{2})$/);
						d1 = new Date(RegExp.$1+"/"+RegExp.$2+"/"+RegExp.$3);
						
						var dt2 = date2;
						var theDLength2 = dt2.length;
						var d2;
						
						if(theDLength2 == 7){
							dt1 += '-01';
						}else if(theDLength2 != 10){
							return;
						}

						dt2.match(/^(\d{4})-(\d{2})-(\d{2})$/);
						d2 = new Date(RegExp.$1+"/"+RegExp.$2+"/"+RegExp.$3);
						
						var checkDate = ((d2-d1)/ (1000 * 60 * 60 * 24));
						return checkDate <= 31 && checkDate >=0
					}
					return check;
				}
			]
		]);
	
	
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		valid1.define( "check_DATE" , [{id:'STR_INPUT_DATE'},{id:'END_INPUT_DATE'},{id:'STR_LOAN_DATE'},{id:'END_LOAN_DATE'},{id:'LOAN_ID'},{id:'CUSTOM_ID'}] );
	
		valid1.define( "check_LOAN_DATE" , [{id:'STR_LOAN_DATE'},{id:'END_LOAN_DATE'}] );
		valid1.define( "check_INPUT_DATE" , [{id:'STR_INPUT_DATE'},{id:'END_INPUT_DATE'}] );
		valid1.define( "check_LOAN_DATE_MONTH" , [{id:'STR_LOAN_DATE'},{id:'END_LOAN_DATE'}] );
		valid1.define( "check_INPUT_DATE_MONTH" , [{id:'STR_INPUT_DATE'},{id:'END_INPUT_DATE'}] );
		//[20211112]承辦科別若選擇全部，貸放日期起訖皆預帶前一工作日，且區間不得大於1天
		valid1.define( "check_LOAN_DATE_DAY" , [{id:'STR_LOAN_DATE'},{id:'END_LOAN_DATE'}] );

		validFull= new Validation("form1", { focusOnError:true, immediate:false });

	}    

	
	// 共用AJAX
		<%--共用Ajax--%>
	    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSB2_0900/');
	
	
	//buttons對應的event function
	var buttons = {	
	
	
	   //查詢資料
		doQuery : function(event){	
		    
			valid1.reset();
			if(!valid1.validate()){
				return;			
			}
			
			actions.clearSuggest();
			var sendRecord = makeRecord();
			
			ajaxRequest.post( 'query' , {sendRecord : Object.toJSON(sendRecord)},
					function(resp){	
						grid.load(resp.rtnList );
						$('queryType').value = resp.queryType;
						
					},function(resp){					
						grid.load([]);
						
					}
				);
		},
		//補件查詢
		doReSend : function(event){	
		    
			if($F('LOAN_ID') == ''){
			   alert('請先輸入貸款帳號後，再執行補件查詢!!');
			   return;			
			}
			
			actions.clearSuggest();
			ajaxRequest.post( 'resend' , {LOAN_ID : $F('LOAN_ID')},
					function(resp){	
						grid.load(resp.rtnList);
						$('queryType').value = resp.queryType;
						
					},function(resp){					
						grid.load([]);
						
					}
				);
		},
		//新增
		doInsert : function(event){	
		    
			if($F('queryType') == ''){
			   alert('需先執行過查詢,才能新增!!');
			   return;			
			}
			var checkRec = grid.getCheckedRecord();
            if(checkRec.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}
			//[20190807]檢核羅馬拼音不可為半型
			if (!utils.validateFull()) {
				return;
			}

			var sendRecord = makeRecord();
			
			ajaxRequest.post( 'insert' , {sendRecord : Object.toJSON(sendRecord),reqList : Object.toJSON(checkRec)},
					function(resp){	
						grid.load(resp.rtnList );
						
					},function(resp){					
						//grid.load([]);
						
					}
				);
		},
		//修改
		doUpdate : function(event){	
		    
			if($F('queryType') == ''){
			   alert('需先執行過查詢,才能修改!!');
			   return;			
			}
			var checkRec = grid.getCheckedRecord();
            if(checkRec.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}
			//[20190807]檢核羅馬拼音不可為半型
			if (!utils.validateFull()) {
				return;
			}

			var sendRecord = makeRecord();
			ajaxRequest.post( 'update' , {sendRecord : Object.toJSON(sendRecord),reqList : Object.toJSON(checkRec)},
					function(resp){	
						grid.load(resp.rtnList );
					},function(resp){					
						//grid.load([]);
						
					}
				);
		},
		
		//收執確認
		doConfirm : function(event){
		
			if($F('queryType') == ''){
			   alert('需先執行過查詢,才能收執確認!!');
			   return;			
			}
			var checkRec = grid.getCheckedRecord(['LOAN_ID','CUSTOM_TYPE','CUSTOM_ID','SEQ_NO','RECEIPT_NO','MEMO']);
            if(checkRec.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}			
			
			var sendRecord = makeRecord();
			
			ajaxRequest.post( 'confirm' , {sendRecord : Object.toJSON(sendRecord), reqList : Object.toJSON(checkRec)},
					function(resp){	
						qryLoanId = $('LOAN_ID').value; //供列印做檢核是否有異動過帳號
						grid.load(resp.rtnList );
						
					},function(resp){					
						//grid.load([]);
						
					}
				);
		},	
		//退郵
		doReject : function(event){	
		
		
		    if($F('queryType') == ''){
			   alert('需先執行過查詢,才能退郵!!');
			   return;			
			}
			var checkRec = grid.getCheckedRecord(['LOAN_ID','CUSTOM_TYPE','CUSTOM_ID','SEQ_NO']);
            if(checkRec.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}	
			
			var sendRecord = makeRecord();
			
			ajaxRequest.post( 'reject' , {sendRecord : Object.toJSON(sendRecord), reqList : Object.toJSON(checkRec)},
					function(resp){	
						qryLoanId = $('LOAN_ID').value; //供列印做檢核是否有異動過帳號
						grid.load(resp.rtnList );
						
					},function(resp){					
						//grid.load([]);
						
					}
				);
		},	
		//郵寄列印
        doSendPrint : function(){			
			if($F('queryType') == ''){
			   alert('請先查詢再執行郵寄列印作業');
			   return;			
			}
			var checkRec = grid.getCheckedRecord(['LOAN_ID','CUSTOM_TYPE','CUSTOM_ID','SEQ_NO']);
            if(checkRec.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}
			
			//RPTUtil.executePrintByLink('sendprint' , {allrec : Object.toJSON(checkRec)}, true );
			//因應報表浮水印控管，需設白名單之報表要有引用到浮水印模組
			RPTUtil.downloadFile('${dispatcher}/DSB2_0900/sendprint' , {allrec : Object.toJSON(checkRec)}, true );				
	    },
		//通訊列印
        doConPrint : function(){
			 if($F('queryType') == ''){
			   alert('需先執行過查詢,才能通訊列印!!');
			   return;			
			}
			var checkRec = grid.getCheckedRecord(['LOAN_ID','CUSTOM_TYPE','CUSTOM_ID','SEQ_NO']);
            if(checkRec.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}	
			
			var number = prompt('請輸入條碼標籤位置(由左至右分別為1,2,3,4)，請輸入數字1~4' , 1); 
			
			//RPTUtil.executePrintByLink('conprint' , {allrec : Object.toJSON(checkRec), number : number}, true );
			//因應報表浮水印控管，需設白名單之報表要有引用到浮水印模組
			RPTUtil.downloadFile('${dispatcher}/DSB2_0900/conprint' , {allrec : Object.toJSON(checkRec), number : number}, true );			
	    },
	    //簽收條列印
        doSignPrint : function(){
			if($F('queryType') == ''){
			   alert('需先執行過查詢,才能簽收條列印!!');
			   return;			
			}
			var checkRec = grid.getCheckedRecord(['LOAN_ID','CUSTOM_TYPE','CUSTOM_ID','SEQ_NO']);
            if(checkRec.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}	
			
			//RPTUtil.executePrintByLink('SignPrint' , {allrec : Object.toJSON(checkRec)}, true );
			//因應報表浮水印控管，需設白名單之報表要有引用到浮水印模組
			RPTUtil.downloadFile('${dispatcher}/DSB2_0900/SignPrint' , {allrec : Object.toJSON(checkRec)}, true );
			
	    },
	    //本息攤還試算列印
        doPrint : function(){
			if($F('queryType') == ''){
			   alert('需先執行過查詢,才能本息攤還試算列印!!');
			   return;			
			}
			var checkRec = grid.getCheckedRecord(['LOAN_ID','CUSTOM_TYPE','CUSTOM_ID','SEQ_NO']);
            if(checkRec.length==0){
			  alert("請先選取再執行本息攤還試算列印作業");
			  return;
			}	
			
			var url = "<%=dispatcher%>/DSB2_0900/print";
			//RPTUtil.fileWatchDog(url, {allrec : Object.toJSON(checkRec)});		
			//RPTUtil.executePrintByLink('print' , {allrec : Object.toJSON(checkRec)}, true );
			//因應報表浮水印控管，需設白名單之報表要有引用到浮水印模組
			RPTUtil.fileWatchDog4WaterMark(url, {allrec : Object.toJSON(checkRec)});
	    },
	    //匯款明細列印
	    doDetailPrint : function(){
	    	if($F('queryType') == ''){
	    	   alert('請先查詢再執行匯款明細列印作業');
			   return;	
	    	}
	    	var checkRec = grid.getCheckedRecord(['LOAN_ID','CUSTOM_TYPE','CUSTOM_ID','SEQ_NO']);
	    	var len = checkRec.length;
            if(len == 0){
			  alert("請至少勾選一筆資料");
			  return;
			}	
			
			<%-- for check same LOAN_ID --%>
			var reqRec = [];
			
	    	checkRec.each(function(item){
	    		var LOAN_ID = item['LOAN_ID'];
	    		if( !reqRec.include(LOAN_ID)){
	    			reqRec.push({
	    				LOAN_ID : LOAN_ID,
	    				CUSTOM_TYPE : item['CUSTOM_TYPE'],
	    				CUSTOM_ID : item['CUSTOM_ID'],
	    				SEQ_NO : item['SEQ_NO']
	    			});
	    		}	
	    	});
	    	
	    	var postData = {
	    		REPORT_ID : 'DSA1_1301',
	    		LINK_FORM : 'DSB20900',
	    		rtnList : Object.toJSON(reqRec)
	    	};

	    	RPTUtil.downloadFile ( "${dispatcher}/DSA1_1301/prompt" , postData, true );	
	
	    	
	    }
	
	};

	utils = {
		//[20190927] 羅馬拼音不可為半型
		validateFull: function () {
			grid.validCheckedOnTable();
			var errArray = grid.getCheckedErrorRecords();
			var len =errArray.length;
			if (len<1) {
				return true;
			}

			var ErrMsg = '';
			for (var i = 0; i < len; i++) {
				var errMap=errArray[i];
				ErrMsg = ErrMsg +'羅馬拼音不可為半型:'+ "\n"+ "貸款帳號:" + errMap['LOAN_ID'] + "、客戶ID:" + errMap['CUSTOM_ID']+ "\n\r";
			}
			alert(ErrMsg);
			return false;
		}
	};
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {}
		
		sendRecord.START_LOAN_DATE= $('STR_LOAN_DATE').getValue(); //貸放日期(起)
		sendRecord.END_LOAN_DATE= $('END_LOAN_DATE').getValue();//貸放日期(迄)
		sendRecord.START_INPUT_DATE= $('STR_INPUT_DATE').getValue();//作業日期(起)
		sendRecord.END_INPUT_DATE= $('END_INPUT_DATE').getValue();//作業日期(迄)
		sendRecord.CRED_DEPT= $('CRED_DEPT').value;//承辦科別
		sendRecord.SEND_STATUS= $('SEND_STATUS').value;//交付狀態
		sendRecord.SEND_KIND= $('SEND_KIND').value;//交付方式
		sendRecord.LOAN_ID= $('LOAN_ID').value;//貸款帳號
		sendRecord.CUSTOM_ID= $('CUSTOM_ID').value;//客戶ID
		sendRecord.SIGN_STATUS= $('SIGN_STATUS').value;//簽收條狀態
		sendRecord.COMP2_CLOSE= $('COMP2_CLOSE').value;//代償二匯狀態
		sendRecord.INPUT_DIV_NO= $('INPUT_DIV_NO').value;//作業單位代號
		
		return sendRecord;	
	}	
	
	
	// 金額格式化
	function gridFmtRender(value) { 
		return value || value === 0 ? localeDisplay.formatNumber(value||'0') : ''; 
	};
	
	//[20201028] 修改交付方式下拉選單
	var actions = {
		initSuggestInTableUI : function(rec, v, SN, needToClearInput){
			
			var SEND_KIND = rec.SEND_KIND;
			var input;
			if(SEND_KIND=='2'){
				
				input = new Element('input', {
					'isNotSug': 'N',
					'size': 50,
					'maxLength': 50
				});

				if(!needToClearInput && rec['SEND_ZIP'] != '' && rec['SEND_ADDR'] != '') {
					input.setValue(rec['ACCEPT_NAME'])
				}

				$('suggestTempDiv').insert(input);
				
				Suggest.add(
					input,
					Suggest.URL,	// (必填)建議輸入的設定型態(動態查詢型態)
					"${dispatcher}/DSB2_0900/queryDEPT",	// (必填)至後端查詢資料的網址。
					{
						"option_key":"DIV_NAME",
						"remark_key":"DIV_NO",
						"dispMax":10,
						"prefix":false,
						"ignoreCase":true,
						"startLength":2,
						"noCookies":true,
						"params" : { SEND_KIND : SEND_KIND},
						"callBackFunc" : function(node, rec2){
							
							var valDivName = rec2 ? rec2['DIV_NAME'] : '';
							var valZipCode = rec2 ? rec2['ZIP_CODE'] : '';
							var valDivAddress = rec2 ? rec2['DIV_ADDRESS'] : '';

							//連動寄送地址(郵遞區號與地址：寫入畫面「寄送地址」兩個欄位)
							$('SEND_ZIP'+ rec['LOAN_ID'] + '_'+ rec['CUSTOM_ID'] + '_' + SN).setValue(valZipCode);
							$('SEND_ADDR'+ rec['LOAN_ID'] + '_'+ rec['CUSTOM_ID'] + '_' + SN).setValue(valDivAddress);
							
							//連動寄送地址(清空郵遞區號與地址：把值回寫「寄送地址」兩個欄位)
							rec['SEND_ZIP'] = valZipCode;
							rec['SEND_ADDR'] = valDivAddress;
							
							rec.ACCEPT_NAME = valDivName;
							rec.ACCEPT_NAME_SUGGEST = valDivName;// 暫存，供換頁時重新長suggest時回填值
						}
					}	// (選填)其他設定值們
				);
				
				if(rec.ACCEPT_NAME_SUGGEST && !needToClearInput){
					input.setValue(rec.ACCEPT_NAME_SUGGEST);
				}
			}else{
				input = new Element('input',
				{
					style: 'margin:2px',
					type: 'string',
					name: 'ACCEPT_NAME',
					id:'ACCEPT_NAME_'+SN,
					size: 50,
					maxLength: 50,
					value: needToClearInput ? '' : v,
					<%-- [20240607] 難字調整 --%>
					alt: 'ch',
					'isNotSug': 'Y'
				});
								
				input.observe('change', function (event) {
					grid.getRecordsBySerialNo(SN)[0]['ACCEPT_NAME'] = input.getValue();
				});
			}
			
			if(needToClearInput){				
				$('SEND_ZIP'+ rec['LOAN_ID'] + '_'+ rec['CUSTOM_ID'] + '_' + SN).setValue('');
				$('SEND_ADDR'+ rec['LOAN_ID'] + '_'+ rec['CUSTOM_ID'] + '_' + SN).setValue('');
				rec.SEND_ZIP = '';
				rec.SEND_ADDR = '';
				rec.ACCEPT_NAME = '';
			}
			
			input.setAttribute('SN', SN); // 交付方式切換時需取得SN
			
			return input;
		},
		clearSuggest : function(){
			//清除suggest註冊
			$$('#grid input[isnotsug=N]').each(function(elem){
				Suggest.clear(elem);
			});
		},
	    //[20211112]承辦科別下拉控制
	    doChange_CRED_DEPT : function(){
	    	if($F('CRED_DEPT') == ''){
	    		var OneROCDate = '<c:out value="${OneROCDate}" default="" escapeXml="false" />';
	    		$('STR_LOAN_DATE').setValue(OneROCDate);
	    		$('END_LOAN_DATE').setValue(OneROCDate);
	    	}
	    }
	};

	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement("DSB20900", "匯款文件", "貸款契約書交付控管作業", 1);		
			
			<cathay:LocaleDisplay sysCode="DS" dateFields="STR_LOAN_DATE END_LOAN_DATE STR_INPUT_DATE END_INPUT_DATE" var="localeDisplay" />
				
			grid = new TableUI ( {
					table:$("grid"), pageSize: 5, allSortable:true ,
					split: ["RECEIPT_NO"],
					autoCheckBox:{ type: "checkbox", text:'選取', isSelectAll: true},
					validateRecord: function (rec, sn) {//[20190927]羅馬拼音不可為半型
						var ACCEPT_NAME_RM = rec['ACCEPT_NAME_RM'];
						if (!ACCEPT_NAME_RM) {
							return true;
						}
						return !validation.hasHalfType(ACCEPT_NAME_RM);
					},
					<%-- [20240607] 難字調整 --%>
		            pageChange: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
		            },
					column:[
						{header: "貸款帳號",key: "LOAN_ID"},
						<%-- [20240607] 難字調整 --%>
						{header: "客戶姓名",key: "CUSTOM_NAME", attrs:{ style:"font-family:'EUDC'" }},
						{header: "客戶ID",key: "CUSTOM_ID"},
						{header: "身分別",key: "CUSTOM_TYPE_NM", 
							render: function(rec, v, SN){
								if(rec.CUSTOM_TYPE == '1'){
									return '<span style = "color:red">'+v+'</span>';
								}
								return v;
							}
						},
						//[20190730] 增加一個input欄位for 交付姓名(羅馬)
						//[20201028]  修改交付方式下拉選單連動給值
						{header: "交付姓名<br>(羅馬拼音)",key: "ACCEPT_NAME",
							render: function (rec, v, SN) {

								var span = new Element('span');
								var br = new Element('br');
								var inputSpan = new Element('span', {id : 'ACCEPT_NAME_SPAN_' + SN});
								var input = actions.initSuggestInTableUI(rec, v, SN);
								inputSpan.insert(input);
								
								var input1 = new Element('input',
									{
										style: 'margin:2px',
										type: 'string',
										name: 'ACCEPT_NAME_RM',
										id:'ACCEPT_NAME_RM_'+SN,
										size: 50,
										maxLength: 50,
										value:  rec['ACCEPT_NAME_RM'] || ''
									});
								
								
								//調整監聽事件以處理難字
								input.addEventListener('blur', function(event) {
									grid.getRecordsBySerialNo(SN)[0]['ACCEPT_NAME'] = input.value;
								});
								
								input1.addEventListener('blur', function(event) {
								    grid.getRecordsBySerialNo(SN)[0]['ACCEPT_NAME_RM'] = input1.value;
								});

								span.appendChild(inputSpan);
								span.appendChild(br);
								span.appendChild(input1);

								return span;
							}
						},
						//[20201028] 修改交付方式下拉選單							
						{ header: "交付方式", key: "SEND_KIND", input:{
								type: 'select',
								opts : SEND_KIND_LIST,
								action : function(element, recs){
									var oTr = element.up('tr');
									var oSugInputs = oTr.select('[name=ACCEPT_NAME] input[isNotSug="N"]');
									var isSuggest = oSugInputs.length > 0;

									var value;
									var SN;
									if(isSuggest){
										var oSugInput = oSugInputs[0];
										value = oSugInput.value;
										SN = oSugInput.getAttribute('SN');
										Suggest.clear(oSugInput);
									}else{
										var oInput = oTr.select('[name=ACCEPT_NAME] input[isNotSug="Y"]')[0];
										value = oInput.value;
										SN = oInput.getAttribute('SN');
									}
									
									var rec = recs[0];
									//需要清除 Input 欄位資料的情況：
									//(1) 變動後交付狀態為服中臨櫃，且 ACCEPT_NAME 底下的屬性 isNotSug 沒有 = N 的資料；
									//(2) 變動後交付狀態不是服中臨櫃，且 ACCEPT_NAME 底下的屬性 isNotSug 有 = N 的資料；。
									var needToClearInput = (rec.SEND_KIND == '2' && !isSuggest) || (rec.SEND_KIND != '2' && isSuggest);
									var input = actions.initSuggestInTableUI(rec, value, SN, needToClearInput);
									$('ACCEPT_NAME_SPAN_' + SN).update('');
									$('ACCEPT_NAME_SPAN_' + SN).insert(input);
								}
							}
						},
						{header: "寄送地址",key: "SEND_ADDR", attrs:{colSpan:2},
							render: function(rec, v, SN){
								var span = new Element('span');
								var input = new Element('input', 
									{
										type:'string',
										name:'SEND_ZIP',
										id: 'SEND_ZIP'+ rec['LOAN_ID'] + '_'+ rec['CUSTOM_ID'] + '_'+SN ,
										size:6,
										maxLength:6,
										value: rec['SEND_ZIP'] || ''
									});
								
								var input1 = new Element('input', 
									{
										type:'string',
										name:'SEND_ADDR',
										id: 'SEND_ADDR'+ rec['LOAN_ID'] + '_'+ rec['CUSTOM_ID'] + '_' + SN,
										size:50,
										maxLength:50,
										<%-- [20240607] 難字調整 --%>
										alt:'ch',
										value: v
									});
								input.onchange = function(event){
									if(input.value){
										if(grid.isNew){
											grid.setThisAutoCheckBox(input,true);
										}else{
											var tr = input.up('tr');
											tr.select('input[type=checkbox]')[0].click();					
										}
										grid.getRecordsBySerialNo(SN)[0]['SEND_ZIP']=input.value;
									}
								};
								
								//調整監聽事件以處理難字
								input1.addEventListener('blur', function(event) {
								    if (input1.value) {
								        if (grid.isNew) {
								            grid.setThisAutoCheckBox(input, true);
								        } else {
								            var tr = input1.closest('tr'); 
								            tr.select('input[type=checkbox]')[0].click();
								        }
								        grid.getRecordsBySerialNo(SN)[0]['SEND_ADDR'] = input1.value;
								    }
								});

								
								span.appendChild(input);
								span.appendChild(document.createTextNode("　"));
								span.appendChild(input1);
								return span;
							}
						},

												
						{header: "收執編號",key: "RECEIPT_NO",
							input:{
								type:'TEXT',
								size:10,
								genRule:function(rec , val){
									return true;
								},
								action:function( node , dataObj , textDiv, orgData , isOnChange ){
								}, actionWhenStart:true
							}
						},
						{header: "簽收條狀態",key: "SIGN_STATUS_NM"},
						<%-- [20240607] 難字調整 --%>
						{header: "作業人員",key: "INPUT_NAME", attrs:{ style:"font-family:'EUDC'" }},
						{header: "作業日期",key: "INPUT_DATE", sortRule:"Date"
							//render : function (rec , val){
								//return Date.toInputROC(val || "","/");
							//}							
						},
						{header: "交付狀態",key: "SEND_STATUS_NM"},
						{header: "二匯狀態",key: "COMP2_CLOSE_NM"},
						{header: "備註",key: "MEMO",
						   input:{
								type:'TEXT',
								size:30,
								genRule:function(rec , val){
									return true;
								},
								action:function( node , dataObj , textDiv, orgData , isOnChange ){
									/*
									if(!isOnChange){
										node.setAttribute("className" , "checkInputLength");
									}
									node.value = node.value.toUpperCase();
									node.maxLength = 11;
									dataObj[0]["APPLY_ID"] = (node.value ? node.value : "");
									*/
								}, actionWhenStart:true
							}
						}
						
					]
				});
		
			//註冊DOM物件
			//click事件
			$("btn_query").observe("click", buttons.doQuery ); //查詢
			$("btn_reSend").observe("click", buttons.doReSend ); //補件查詢
			$("btn_insert").observe("click", buttons.doInsert ); //新增
			$("btn_update").observe("click", buttons.doUpdate ); //修改
			$("btn_confirm").observe("click", buttons.doConfirm ); //收執確認
			$("btn_reject").observe("click", buttons.doReject ); //退郵
			$("btn_sendprint").observe("click", buttons.doSendPrint ); //郵寄列印
			$("btn_conprint").observe("click", buttons.doConPrint ); //通訊列印
			$("btn_signprint").observe("click", buttons.doSignPrint ); //簽收條列印
			$("btn_print").observe("click", buttons.doPrint ); //本息攤還試算列印
			$('btn_detailPrint').observe('click', buttons.doDetailPrint ); //匯款明細列印
			$('CRED_DEPT').observe('change', actions.doChange_CRED_DEPT ); //承辦科別下拉控制
	
			initValidation();	
			
			fix();

			displayMessage();	
			
			buttonAuth();

		}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		
		    <tr>
				<td class="tbYellow" width="12%">
					貸放日期
				</td>
				<td class="tbYellow2">
					<input name="STR_LOAN_DATE" id='STR_LOAN_DATE' type="text" value="${OneROCDate}" fieldName="貸放日期(起)"/>
					~
					<input name="END_LOAN_DATE" id='END_LOAN_DATE' type="text" value="${OneROCDate}" fieldName="貸放日期(迄)"/>
					<input type="hidden" id="queryType" name="queryType"   />
				</td>
				<td class="tbYellow" width="12%">
					輸入日期
				</td>
				<td class="tbYellow2">
					<input name="STR_INPUT_DATE" id='STR_INPUT_DATE' type="text" value="" fieldName="輸入日期(起)"/>
					~
					<input name="END_INPUT_DATE" id='END_INPUT_DATE' type="text" value="" fieldName="輸入日期(迄)"/>
				</td>
				<td class="tbYellow" width="10%">
					簽收條狀態
				</td>
				<td class="tbYellow2">
					<select name="SIGN_STATUS" id="SIGN_STATUS">
						<option value=''>請選擇</option>
						<c:forEach var="map" items="${SIGN_STATUS_LIST}">
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow2" align="center" rowspan="4">
					<input type="button" class="button" id="btn_query" value="查詢">
					<input type="button" class="button" id="btn_reSend" value="補件查詢">
				</td>
			</tr>
		
		    <tr>
				<td class="tbYellow" width="10%">
					承辦科別
				</td>
				<td class="tbYellow2">
					<select name="CRED_DEPT" id="CRED_DEPT">
						<option value="">全部</option> 
						<c:forEach var="map" items="${CRED_DEPT_LIST}">
							<option value='${map.key}' <c:if test="${map.key eq CRED_DEPT}">selected</c:if> >${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="10%">
					交付狀態
				</td>
				<td class="tbYellow2">
					<select name="SEND_STATUS" id="SEND_STATUS">
						<option value=''>請選擇</option>
						<c:forEach var="map" items="${SEND_STATUS_LIST}">
							<option value='${map.key}' >${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="10%">
					交付方式
				</td>
				<td class="tbYellow2">
					<select name="SEND_KIND" id="SEND_KIND">
						<option value=''>請選擇</option>
						<c:forEach var="map" items="${SEND_KIND_MAP}">
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>
		    <tr>
				<td class="tbYellow" width="10%">
					貸款帳號
				</td>
				<td class="tbYellow2">
					<input type="text" class="textBox" id="LOAN_ID" name="LOAN_ID" size="11" maxlength="10" onblur="this.value = this.value.toUpperCase()"  >
				</td>
				<td class="tbYellow" width="10%">
					客戶ID
				</td>
				<td class="tbYellow2">
					<input type="text" class="textBox" id="CUSTOM_ID" name="CUSTOM_ID" size="11" maxlength="10" onblur="this.value = this.value.toUpperCase()"  >
				</td>
				<td class="tbYellow" width="10%">
					代償二匯狀態
				</td>
				<td class="tbYellow2">
					<select name="COMP2_CLOSE" id="COMP2_CLOSE">
						<option value=''>請選擇</option>
						<c:forEach var="map" items="${COMP2_CLOSE_LIST}">
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>
		    <tr>
				<td class="tbYellow" width="10%">
					作業單位代號
				</td>
				<td class="tbYellow2" colspan="5">
					<input type="text" class="textBox" id="INPUT_DIV_NO" name="INPUT_DIV_ID" size="8" maxlength="7" onblur="this.value = this.value.toUpperCase()" value="${INPUT_DIV_NO}" >
				</td>
			</tr>
		
			
			<tr>
				<td align="center" colspan="7">
					<input type="button" class="button" id="btn_insert" value="新增">
					<input type="button" class="button" id="btn_update" value="修改">
					<input type="button" class="button" id="btn_confirm" value="收執確認">
					<input type="button" class="button" id="btn_reject" value="退郵">
					<input type="button" class="button" id="btn_sendprint" value="郵寄列印">
					<input type="button" class="button" id="btn_conprint" value="通訊列印">
					<input type="button" class="button" id="btn_signprint" value="簽收條列印">
					<input type="button" class="button" id="btn_print" value="本息攤還試算列印(簡式)">
					<input type="button" class="button" id="btn_detailPrint" value="匯款明細列印">
				</td>
			</tr>
		</table>
		<table id='grid' width="100%"></table>	
		<%-- [20201028]  修改交付方式下拉選單 --%>
		<div id="suggestTempDiv" hidden></div>
	</form>	
	
</body>
</html>