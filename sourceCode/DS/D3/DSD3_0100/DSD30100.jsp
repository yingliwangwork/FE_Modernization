<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSD30100.jsp
功能：防止清償通報輸入
作者：黃子玹
完成：2013/09/10

[20200211] 修改件 2020/02/15 防止清償通報輸入查詢權限調整   李明諭  By 蔡政均

[20240326]
難字調整
高強禾
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>   <%-- 標準外框表格 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
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
Event.observe(window, 'load', new DSD30100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD30100(){
	var rtnMap;
	var qryLOAN_ID ='';
	var rtnMap = {};
	var CHECK_DEPT = '${CHECK_DEPT}';

	function initValidation(){		
		
		Validation.addAllThese([
			[ 'validateLOAN_ID',  '請輸入正確的貸款帳號!',
				function(v){  
					if(!Validation.get('IsEmpty').test(v)){return v.length == 10 && (/^[a-zA-Z0-9]+$/.test(v));}
					else{return true};
				}
			]
			,['checkCaseType', '請點選案件類型', function(v, ele, info) {
					var name  = ele.getAttribute('name');
					var isChecked  = false;
					$$('input[type=radio][name=radioCaseType]').each(
						function(obj){
							if(obj.checked){
								isChecked = true;
							}
						}
					);
					return isChecked;
				}
			]
		]);
		//查詢用檢核
		valid1 = new Validation("table_A", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define('validateLOAN_ID' , [{ id : "LOAN_ID" , errMsg:"請輸入正確的貸款帳號!"}] );
		//於畫面輸入貸款帳號後，需勾選為清償件或申請利率調降，才能查詢資料。(需求原因：清償件與利調件顯示的聯絡窗口規則不一樣。)
		valid1.define('checkCaseType' , [{ id : "radioCaseType0", errMsg:"請選擇案件類型-清償件" }] );
		valid1.define('checkCaseType' , [{ id : "radioCaseType2", errMsg:"請選擇案件類型-申請利率調降" }] );
		
		valid2 = new Validation("table_B", { focusOnError:true, immediate:false , mode : 'validator'});
		valid2.define('checkCaseType' , [{ id : "radioCaseType0", errMsg:"請選擇案件類型-清償件" }] );
		valid2.define('checkCaseType' , [{ id : "radioCaseType2", errMsg:"請選擇案件類型-申請利率調降" }] );
		
	}
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0003:"btn_insert",<%--新增--%>
			B0004:"btn_update"<%--修改--%>
			//B0219:"print_custdata",<%--自動個調附約--%> 
			//B0220:"print_custdata1"<%--一年個調附約--%> 		 				
		};	
		<dz:grantButtons FUNC_ID="DSD30100"/>
	};
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD3_0100/" + actionName,
			{  
			parameters: params, 
			onSuccess:function(response){
				var resp = response.responseJSON
				if(CSRUtil.isSuccess(resp)){	
					if(successFunction){
						successFunction(resp);
					}
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			}			
		});
	}
	
	
	/*
	function setView(resp){
		rtnMap = resp.rtnMap || {};				
						
		$('table_B').select('span').each(function(elem){
					
			var oID = elem.id;					
			var v = rtnMap[oID];						
			if(oID == 'LAST_ADJUST' || oID == 'INPUT_DATE'){
			
				elem.update(Date.toROC(v) || '');
			
			}else if(oID == 'REMAIN_AMT'){		
			
				elem.update(CSRUtil.$fmt(v,'#,###') || 0);
				
			}else if(oID == 'BORROW_NAME'){	
				elem.update((v || '')+' &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+(resp.vipMsg || ''));	
			}else if(oID == 'BORROW_ID'){
				elem.update(v ? CSRUtil.maskHandler.getMaskID(v) : '');
			}else{
				elem.update(v);
			}	
		});
		//$('LOAN_KIND_1').update(rtnMap['LOAN_KIND']);
		//$('PREFER_TYPE_1').update(rtnMap['PREFER_TYPE']);
		//$('VIP_GRADE_1').update(rtnMap['VIP_GRADE']);
		
		$('table_B').select('input[type="hidden"]').each(function(elem){							
			elem.setValue(rtnMap[elem.id] || '');
		});	
		//$('table_B').select('input[type=checkbox]').each(function(elem){			
		//	elem.checked = false;								
		//});
		//$w('REASON1 REASON2 REASON3 REASON4 REASON5').each(function(ele){
		//	if(rtnMap[ele]=='1'){
		//		$(ele).checked=true;
		//	}
		//});
		$w('REASON1 REASON2 REASON3 REASON4 REASON5 REASON7 REASON6').each(
		function(id) {
			if (resp.rtnMap['REASON'] == $(id).value) {
				$(id).checked = true;										
			} else {
				$(id).checked = false; 
			}				
		});
		//$w('SOURCE1 SOURCE2 SOURCE3 SOURCE4').each(function(ele){
		//	if(rtnMap[ele]=='1'){
		//		$(ele).checked=true;
		//	}
		//});
		//$('INPUT_TEL').value=rtnMap['INPUT_TEL']||'';
		//$('INPUT_NOTE').value=rtnMap['INPUT_NOTE']||'';
		//$('PRINT_CONTROL').value = (resp.PRINT_CONTROL || '');					
		//$('INPUT_NAME').update('${INPUT_NAME}');
		//$('INPUT_DATE').update(Date.toROC('${INPUT_DATE}'));
	}
	*/
	var actions ={
		
		doQuery : function(){
			
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			qryLOAN_ID = $F('LOAN_ID');
			var qryCASE_TYPE = $$('input:checked[type=radio][name=radioCaseType]')[0].getValue();//案件類型
			ajaxPost( 'query', {LOAN_ID : qryLOAN_ID, CASE_TYPE : qryCASE_TYPE}
					,function(resp){
						rtnMap = resp.rtnMap;
						//setView(resp);
						
						var CONTROL_CODE =  resp.CONTROL_CODE;
						var isInternal =  resp.isInternal;
						if (CONTROL_CODE && qryCASE_TYPE != '2'){
						   $('CONTROL_CODE').value = CONTROL_CODE;
							var MSG;
							if(CONTROL_CODE == "ERR"){
							    MSG ="本件有「特殊管控」注意事項。"
							    if(isInternal == 'N'){
							    	MSG = MSG +"\r\n詳細內容請洽"+resp.CONTROL_DEPT_GROUP_NM+"。";
							    }
							    MSG += "\r\n若要查詢特殊件控管變更紀錄請按『確定』鍵?";
							}else if(CONTROL_CODE){
								MSG ="本件有「特殊提醒」注意事項。"
								if(isInternal == 'N'){
									MSG = MSG +"\r\n詳細內容請洽"+resp.CONTROL_DEPT_GROUP_NM+"。";
								}	
								MSG += "\r\n若要查詢特殊件控管變更紀錄請按『確定』鍵?";
							}
							if( confirm(MSG)){
								   actions.linkTo_DSC8_3100(resp.BORROW_ID,"3-9");
					        }
						}
						actions.showData();
						<%-- showFlag = 'N' 不顯示欄位 [20200211] 修改件   2020/02/15 防止清償通報輸入查詢權限調整   李明諭  By 蔡政均--%>
						if(resp.showFlag == "N"){
							$('LAST_RATE').hide();
							$('NEXT_RATE').hide();
							$('CUSTOM_TEL').setValue("");
							$('CUSTOM_TEL').setAttribute("placeholder", "個資遮蔽");
							$('PROC_INFO').hide();
						} else {
							$('CUSTOM_TEL').removeAttribute("placeholder");
						}
					},function(resp){							
						actions.doClear();						
					}
			);	
		}
		 ,linkTo_DSC8_3100 :function(BORROW_ID,CONTROL_SOURCE){
	       
	        popupWin.popup({
				src: '<%=dispatcher%>/DSC8_3100/prompt',
				scrolling : 'yes',
				parameters: { 
					LOAN_ID : BORROW_ID,
					CONTROL_TYPE : 'U',
					CONTROL_SOURCE : CONTROL_SOURCE
				}, 
				width: 600, 
				height: 350,
				cb : function(obj){
				}
			});
		  }  
		
		,doClear : function(){
			$('table_B').select('span').each(function(elem){		
				elem.update('');					
			});
			$('table_B').select('input[type="hidden"]').each(function(elem){			
				elem.setValue('');
			});
			$('table_B').select('input[type=checkbox]').each(function(elem){			
				elem.checked = false;								
			});	
			$('table_B').select('input[type=text]').each(function(elem){			
				elem.setValue('');								
			});	
			qryLOAN_ID = '';
		}	
		,doInsert : function(){
			valid1.reset();
			
			var qryCASE_TYPE = $$('input:checked[type=radio][name=radioCaseType]')[0].getValue();//案件類型
			
			//檢核查詢貸款帳號(HID_LOAN_ID)不得為空白，否則顯示錯誤訊息:‘請先查詢再進行新增!’。*/		
			if(qryLOAN_ID == ''){
				alert('請先查詢再進行新增!');
				return;			
			}
			//貸款帳號若與查詢時不同(LOAN_ID <> HID_LOAN_ID)
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號與原先查詢條件不同，無法作業!');
				return;
			}
			
			//非清償件(申請利率調降件)要維持卡控以下檢核規則，清償件則不卡控
			if(qryCASE_TYPE == '2'){
				//檢查是否有進行中的案件
				
			}else{
			
				if($F('CONTROL_CODE') == "ERR"){
		    		alert("本件為特殊控管件,無法進行新增!!");
			    	return;
			    }
				
						
				var PAY_DELAY = $F('PAY_DELAY');			
				if(PAY_DELAY == '1' && CHECK_DEPT =='0'){				
					alert('繳息異常件不得通報輸入!');
					return;
				}
				if(PAY_DELAY == '1' && CHECK_DEPT =='1'){			
					if(!confirm('本件為繳息異常件，確定輸入防止清償通報?')){
						return;					
					}
				}
				if($F('IS_INPUT3') == '1'){
					if(!confirm('最近2個月重複申請，確定輸入防止清償通報?')){
						return;					
					}
				}
				var IS_INPUT = $F('IS_INPUT');			
				if(IS_INPUT == '1'&& CHECK_DEPT =='0'){
					alert('近10個月內已有輸入紀錄，特殊件請與資產管理科連繫處理!');
					return;	
				}
				
				if(IS_INPUT == '1'&& CHECK_DEPT =='1'){
					if(!confirm('近10個月內已有輸入紀錄，確定輸入防止清償通報?')){
						return;					
					}
				}
	
				var IS_INPUT2 = $F('IS_INPUT2');
				if(IS_INPUT == '0'&& IS_INPUT2 =='1' && CHECK_DEPT =='0'){
					alert('近3個月內已有輸入紀錄，特殊件請與資產管理科連繫處理!');
					return;	
				}
				if(IS_INPUT == '0'&& IS_INPUT2 =='1' && CHECK_DEPT =='1'){
					if(!confirm('近3個月內已有輸入紀錄，確定輸入防止清償通報?')){
						return;					
					}
				}
				var LOAN_KIND = $F('LOAN_KIND') || '';
				//若貸款種類代碼為”973”或”320”或”321”或”322”或”323”且角色判斷不為總公司或五大行政中心(CHECK_DEPT = ”0”)
				if((LOAN_KIND == '973' || LOAN_KIND == '310' || LOAN_KIND == '320' || LOAN_KIND == '321' || LOAN_KIND == '322' || LOAN_KIND == '323' 
				   || LOAN_KIND == '324' || LOAN_KIND == '330' || LOAN_KIND == '340' || LOAN_KIND == '350') && CHECK_DEPT =='0'){
					alert('此件為員工件、政府優惠貸款件!!無需輸入通報系統。');						
					return;
				}
				if($F('PREFER_TYPE') == '35'){
					alert('搭配貸不適用個別優惠利率調整作業。');
					return;			
				}
				if($F('PREFER_TYPE') == '56'){
					alert('此件為築巢優利貸!!無需輸入通報系統。');
					return;			
				}
			}
			
			
			if(!valid2.validate()){
				return;
			}
			//若「清償原因」皆未勾選，否則顯示錯誤訊息:‘請選擇清償原因!’。
			var isradio = false;
			$$("input[name=radio]").each(
				function(elem){					
					if(elem.checked){
						isradio = true;
						//break;
					}			
				}	
			);
			if(isradio == false){
				alert('請選擇清償原因!');
				return;
			}
			
			//若「受理來源」皆未勾選，否則顯示錯誤訊息:‘請選擇受理來源!’。*/
			/*
			var isCheck2 = false;
			$$("input[name=check2]").each(
				function(elem){				
					if(elem.checked){
						isCheck2 = true;
						//break;
					}			
				}	
			);
			if(isCheck2 == false){
				alert('請選擇受理來源!');
				return;
			}
			*/
			
			var dataMap = {};			
			$('table_B').select('input[type="text"]').each(function(elem){				
				dataMap[elem.id]  = elem.getValue();							
			});	
			$('table_B').select('input[type=checkbox]').each(function(elem){			
				dataMap[elem.id] = (elem.checked) ? '1' : '0';										
			});
			
			var REASON = '';
			$$('#form1 input[type=radio]:checked').each(
				function(text){
					dataMap['REASON'] = text.value;
				}
			);
			
			$$('#form1 select').each(
				function(text){
					var id = text.id;
					dataMap[id] = text.value || '';
				}
			);
			
			var qryCASE_TYPE = $$('input:checked[type=radio][name=radioCaseType]')[0].getValue();//案件類型
			ajaxPost( 'insert', {dataMap : Object.toJSON(dataMap), LOAN_ID : qryLOAN_ID, CASE_TYPE : qryCASE_TYPE}
					,function(resp){
						rtnMap = resp.rtnMap;
						actions.showData();
						//setView(resp);
					},function(resp){
						actions.doClear();	
					}
			);	
		}	
		,doUpdate : function(){
			valid1.reset();
			
			//檢核查詢貸款帳號(HID_LOAN_ID)不得為空白，否則顯示錯誤訊息:‘請先查詢再進行新增!’。*/		
			if(qryLOAN_ID == ''){
				alert('請先查詢再進行修改!');
				return;
			}
			//貸款帳號若與查詢時不同(LOAN_ID <> HID_LOAN_ID)
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號與原先查詢條件不同，無法作業!');
				return;
			}
					
			if(!valid2.validate()){
				return;
			}
			//若「清償原因」皆未勾選，否則顯示錯誤訊息:‘請選擇清償原因!’。
			var isradio = false;
			$$("input[name=radio]").each(
				function(elem){					
					if(elem.checked){
						isradio = true;
						//break;
					}			
				}	
			);
			if(isradio == false){
				alert('請選擇清償原因!');
				return;
			}
			
			var dataMap = {};			
			$('table_B').select('input[type="text"]').each(function(elem){				
				dataMap[elem.id]  = elem.getValue();
				
			});	
			$('table_B').select('input[type=checkbox]').each(function(elem){			
				dataMap[elem.id] = (elem.checked) ? '1' : '0';										
			});
			
			var REASON = '';
			$$('#form1 input[type=radio]:checked').each(
				function(text){
					dataMap['REASON'] = text.value;
				}
			);
			
			$$('#form1 select').each(
				function(text){
					var id = text.id;
					dataMap[id] = text.value || '';
				}
			);
			var qryCASE_TYPE = $$('input:checked[type=radio][name=radioCaseType]')[0].getValue();//案件類型
			ajaxPost( 'update', {dataMap : Object.toJSON(dataMap), LOAN_ID : qryLOAN_ID, CASE_TYPE : qryCASE_TYPE}
					,function(resp){
						rtnMap = resp.rtnMap;
						actions.showData();
						//setView(resp);
					},function(resp){
						actions.doClear();	
					}
			);	
		}
		,getPrintMap: function(){
		
			var dataMap = {};			
			dataMap['LOAN_ID'] = $F('LOAN_ID') || '';//【區塊A】的貸款帳號
			dataMap['BORROW_ID'] = rtnMap['BORROW_ID']||'';//【區塊B】借款人ID
			dataMap['BORROW_NAME'] = rtnMap['BORROW_NAME']|| ''; //【區塊B】借款人姓名
			return dataMap;		
		}	
		,doPrint: function(event){	
			
			if(qryLOAN_ID == ''){
				alert('請先查詢再進行列印自動個調附約!');
				return;			
			}
			//貸款帳號若與查詢時不同(LOAN_ID <> HID_LOAN_ID)
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號與原先查詢條件不同，無法作業!');
				return;
			}
			/*	
			if($F('PRINT_CONTROL') =='1'){
				alert('貸放未滿三年案件，不能自動調降!');
				return;
			}else if($F('PRINT_CONTROL') =='2'){
				alert('餘額超過兩千萬房貸客戶，不能自動調降!');		
				return;
			}
			*/

			var PrintMap = actions.getPrintMap();		
			RPTUtil.executePrintByLink ( "<%=dispatcher%>/DSD3_0100/print" ,  {PrintMap: Object.toJSON(PrintMap)}, true );	
		}
		,doPrint1: function(event){

			if(qryLOAN_ID == ''){
				alert('請先查詢再進行列印一年個調附約!');
				return;			
			}
			//貸款帳號若與查詢時不同(LOAN_ID <> HID_LOAN_ID)
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號與原先查詢條件不同，無法作業!');
				return;
			}
			var PrintMap = actions.getPrintMap();	
			RPTUtil.executePrintByLink ( "<%=dispatcher%>/DSD3_0100/print1" ,  {PrintMap: Object.toJSON(PrintMap)}, true );	
		}
		,doClearBox1: function(event){
			var ele = Event.element(event);
			var tempid=ele.id
			 if(ele.checked){
				$$('#form1 input[name=check1]').each(function(elet){
				var id=elet.id;
					if(tempid!=id){
						elet.checked=false;
					}
				})
			 }
		}
		,showData : function(){  //顯示資料
			$$('#table_B input[type = "text"]','#table_B input[type = "checkbox"]','#table_B textarea','#table_B select','#table_B span').each(
				function(dom){
					var tagName = dom.tagName;
					var id = dom.id;
					var datatype = dom.getAttribute('datatype');
					
					if(tagName == 'INPUT'){
						var type = dom.type;
					
						if(type == 'checkbox'){	
							
							if(rtnMap[id]== '1'){
								dom.checked = true;							
							}else{
								dom.checked = false;	
							}
						}else{
							if(datatype == 'ROCdate'){
								dom.value = toROC(rtnMap[id] )|| '';		
							}else{
								dom.setValue(rtnMap[id] || '');		
							}
						}
					}else if (tagName =='SELECT'||tagName =='TEXTAREA'){	
						dom.value = rtnMap[id] || '';						
					}else if (tagName =='SPAN'){						
						if(datatype == 'ROCdate'){
							//dom.update( Date.toInputROC(rtnMap[id] || "","/"));   
							//dom.update( rtnMap[id]== ''? rtnMap[id] :Date.toInputROC(rtnMap[id] || "","/"));
							dom.update(localeDisplay.formatDate(rtnMap[id]||''));
						}else if(datatype == 'number'){		
							dom.update(localeDisplay.formatNumber(rtnMap[id]||''));
							//dom.update( rtnMap[id] ? CSRUtil.$fmt(rtnMap[id],"#,###") : 0 );		
						}else{
							dom.update(rtnMap[id]||'');
						}					
					}	
					
				}
			);
			
			if('2' == $$('input:checked[type=radio][name=radioCaseType]')[0].getValue()){
				$('PROC_TITLE').update('資管科聯絡窗口');
				$('PROC_INFO').update(rtnMap['PROC_INFO']||'');
			}else{
				$('PROC_TITLE').update('');
				$('PROC_INFO').update('');
			}
			
			$w('REASON1 REASON2 REASON3 REASON4 REASON5 REASON7 REASON6').each(
			function(id) {
				if (rtnMap['REASON'] == $(id).value) {
					$(id).checked = true;										
				} else {
					$(id).checked = false; 
				}				
			});
			
			$('table_B').select('input[type="hidden"]').each(function(elem){							
				elem.setValue(rtnMap[elem.id] || '');
			});
		}	
	}
	
	return {
	
		initApp : function(){
			PageUI.createPageWithAllBodySubElement('DSD30100', '防止清償通報', '防止清償通報輸入');
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"
						numberFields = "RATE RATE_CORP  TRANS_AMT LOAN_AMT "/>
			
			initValidation();
			$('btn_query').observe('click',actions.doQuery);
			$('btn_insert').observe('click',actions.doInsert);
			$('btn_update').observe('click',actions.doUpdate);
			//$('print_custdata').observe('click',actions.doPrint); //2017-09-04申請書-利率調整作業 刪除「一年個調附約」及「五年個調附約」
			//$('print_custdata1').observe('click',actions.doPrint1);
			$$('#form1 input[name=check1]').each(function(ele){
				var id=ele.id;
				$(id).observe('click',actions.doClearBox1);
				
			})
			buttonAuth();
			
			if('${LOAN_ID}' && '${LINK_FROM}' == 'DSH0_1900'){
				$('LOAN_ID').value = '${LOAN_ID}';					
				actions.doQuery();				
			}
			fix();				
			displayMessage();
		}//end init()--
	};//end return--	
}//end DSD30100
</script>
</head>
<body>
<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
    <input id="CONTROL_CODE" name="CONTROL_CODE" type="hidden" value="">
	<table id = "table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<!--  <input id="PRINT_CONTROL" name="PRINT_CONTROL" value='${PRINT_CONTROL}' type="hidden"/>-->
		<tr>
			<td class="tbYellow" width="10%">貸款帳號</td>
			<td class="tbYellow2" >
				<input id="LOAN_ID"  type="text" class="textBox2 required" onblur="this.value = this.value.toUpperCase()"  value='${LOAN_ID}'  size='12' maxlength='10' fieldName = "貸款帳號"/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%">案件類型</td>
			<td class="tbYellow2" >
				<input type="radio" name="radioCaseType" id="radioCaseType2" value="2">清償件</input>
				<input type="radio" name="radioCaseType" id="radioCaseType0" value="0">申請利率調降</input>
			</td>
		</tr>
		<tr>
			<td colspan='3' align='center' class="tbYellow2">
				<input id="btn_query" type="button" value="查詢" class="button" >	
				<input id="btn_insert" type="button" value="新增" class="button" >		
				<input id="btn_update" type="button" value="修改" class="button" >
				<!--<input id="print_custdata" type="button" value="五年個調附約" class="button" >-->				
				<!--<input id="print_custdata1" type="button" value="一年個調附約" class="button" >-->	
			</td>
		</tr>
	</table>
	<table id = "table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%" >借款人姓名</td>
			<td class="tbYellow2" width="40%">
				<%-- [20240326] 難字調整：借款人姓名 --%>
				<span id='BORROW_NAME' style="font-family:'EUDC'"></span>
			</td>
			<td class="tbYellow" width="10%" >區域</td>
			<td class="tbYellow2">
				<span id='CRED_DEPT_NAME'></span>
			</td>
		</tr>
		<tr>			
			<td class="tbYellow" width="10%" >上期利率</td>
			<td class="tbYellow2">
				<span id='LAST_RATE' datatype="number"></span> %
			</td>
			<td class="tbYellow" width="10%" >下期利率</td>
			<td class="tbYellow2">
				<span id='NEXT_RATE' datatype="number"></span> %
			</td>
		</tr>		
		<tr>
			<td class="tbYellow" rowspan="7">
				清償原因
			</td>
			<td class="tbYellow2" colspan="3">
				<input type="radio" id="REASON1" name="radio" value="1">1.利率因素:轉貸
				<input id="TRANS_BANK1" type="text" class="textBox2" size="12"/>行庫，利率
				<input id="TRANS_AGENT1" type="hidden" class="textBox2" size="12"/><!--分行，利率-->
				<input id="RATE" type="text" class="textBox2" size="6" datatype="number"/>％<!--(本公司-->
				<input id="RATE_CORP" type="hidden" class="textBox2" size="6" datatype="number"/><!--％)-->
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">
				<input type="radio" id="REASON2" name="radio" value="2">2.貸限因素:轉貸
				<input id="TRANS_BANK2" type="text" class="textBox2" size="12"/>行庫，金額
				<input id="TRANS_AGENT2" type="hidden" class="textBox2" size="12"/><!--分行，金額-->
				<input id="TRANS_AMT" type="text" class="textBox2" size="6" datatype="number"/>萬<!--(本公司-->
				<input id="LOAN_AMT" type="hidden" class="textBox2" size="6" datatype="number"/><!--萬)-->
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">
				<input type="radio" id="REASON3" name="radio" value="3">3.服務或與銀行往來因素-客戶反應事實
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">
				<input type="radio" id="REASON4" name="radio" value="4">4.出售<!--－買方姓名 -->
				<input id="BUY_NAME" type="hidden" class="textBox2" size="15"/><!--電話-->
				<input id="BUY_TEL" type="hidden" class="textBox2" size="12"/><!--<br>&nbsp;&emsp;&emsp;&emsp;&emsp;【代書姓名-->
				<input id="LAW_NAME" type="hidden" class="textBox2" size="15"/><!--電話-->
				<input id="LAW_TEL" type="hidden" class="textBox2" size="12"/><!--】-->
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">
				<input type="radio" id="REASON5" name="radio" value="5">5.有閒錢<!--－【1】 -->
				<input type="hidden" id="ITEM1" name="check1"><!--支票 【2】-->
				<input type="hidden" id="ITEM2" name="check1"><!--現金 【3】-->
				<input type="hidden" id="ITEM3" name="check1"><!--匯款<br>&nbsp;&nbsp;&nbsp;&nbsp;閒錢來源：-->
				<input id="SUPPLY" type="hidden" class="textBox2" size="60"/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">
				<input type="radio" id="REASON7" name="radio" value="7">6.申請(定+分)展延未准 
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">
				<input type="radio" id="REASON6" name="radio" value="6">7.其他【1】 
				<select id="CHOICE6">			
					<option value="">請選擇</option>	
					<c:forEach items="${CHOICE6_LIST}" var="row">
						<option value="${row.key}" />
							${row.value}
						</option>	
					</c:forEach>				
				</select><br>&nbsp;&emsp;&emsp;&emsp;&emsp;【2】其他原因：
				<input id="OTHER" type="text" class="textBox2" size="60"/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" >受理來源</td>
			<td class="tbYellow2">
				<span id='SOURCE_NM'></span>
			</td>		
			<td class="tbYellow" width="10%" >受理進度</td>
			<td class="tbYellow2">
				<span id='PROCESS_MAPPING'></span>
			</td>	
		</tr>
		<tr>
			<td class="tbYellow" width="10%" >通報人員</td>
			<td class="tbYellow2">
				<%-- [20240326] 難字調整：通報人員 --%>
				<span id='INPUT_NAME' style="font-family:'EUDC'"></span>
			</td>
			<td class="tbYellow" width="10%" >通報日期</td>
			<td class="tbYellow2" >
				<span id='INPUT_DATE' datatype="ROCdate"></span>
				<span id='INPUT_TIME' datatype="text"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%" >變更人員</td>
			<td class="tbYellow2">
				<%-- [20240326] 難字調整：變更人員 --%>
				<span id='UPDATE_NAME' style="font-family:'EUDC'"></span>
			</td>		
			<td class="tbYellow" width="10%" >變更日期</td>
			<td class="tbYellow2">
				<span id='UPDATE_DATE' datatype="ROCdate"></span>
			</td>	
		</tr>
		<tr>			
			<td class="tbYellow" width="10%" >客戶手機</td>
			<td class="tbYellow2">
				<input id="CUSTOM_TEL" type="text" class="textBox2 required"size="20" maxlength="20" fieldName = "客戶手機"/>
			</td>
			<td class="tbYellow" width="10%" >
				<span id='PROC_TITLE'>資管科聯絡窗口</span>
			</td>
			<td class="tbYellow2">
				<%-- [20240326] 難字調整：資管科聯絡窗口 --%>
				<span id='PROC_INFO' style="font-family:'EUDC'"></span>
			</td>
		</tr>
		<tr>			
			<td class="tbYellow" width="10%" >輸入備註</td>
			<td class="tbYellow2" colspan='3'>
				<!-- <textarea id="INPUT_NOTE" rows='2' cols='80' /></textarea> -->
				<input id="INPUT_NOTE" type="text" class= 'textBox2'  size='100' maxlength='100'/><!--2018/11/6 林孟平處理問題單號20181105-0097-->
			</td>
		</tr>
		
		<input id="PAY_DELAY" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "繳息異常"/>
		<input id="IS_INPUT" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "案件檢核碼"/>
		<input id="IS_INPUT2" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "案件檢核碼2"/>
		<input id="IS_INPUT3" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "案件檢核碼3"/>
		<input id="LOAN_KIND" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "貸款種類代碼"/>
		<input id="PREFER_TYPE" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "優惠種類代碼"/>
		<!--  <input id="PRINT_CONTROL" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "列印控制"/>-->
		<tr class=tbYellow0 align=middle>
			<td align=middle colspan="4">
				<strong>最近一次通報</strong>
			</td>
		</tr>
		<tr>			
			<td class="tbYellow" width="10%" >通報日期</td>
			<td class="tbYellow2">
				<span id='H_INPUT_DATE'></span>
			</td>
			<td class="tbYellow" width="10%" >通報來源</td>
			<td class="tbYellow2">
				<span id='H_SOURCE_NM'></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="4"><font color="red">
				操作說明：<br>
				※請先輸入貸款帳號及勾選清償件或申請利率調降後查詢再新增。<br> 
          		※清償原因為必輸欄位。<br>
				※手機號碼必要輸入欄位，請確認客戶手機是否正確客戶可收到核准訊息通知，若無手機號碼，請填入家裡聯絡電話。
           </font>	
           </td>
		</tr>
	</table>

</form>
</body>
</html>