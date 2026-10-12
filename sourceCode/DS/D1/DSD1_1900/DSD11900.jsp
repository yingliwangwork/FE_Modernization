<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSD11900.jsp
功能：催收通知列印
作者：卓達瑋
完成：2013/09/

[20180824] 修改件:  
1.input 欄位不設type='DATE'
2.input 欄位增加name = theID+'_input'

[20230823] 修改件:
1. 新增送出製作郵簡
2. 新增取消製作郵簡功能

[20240326]
難字調整
高強禾
 --> 

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
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
<script type="text/javascript">


Event.observe(window, 'load', new DSD11900().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD11900(){
    var LOAN_ID='${LOAN_ID}';
    var grid; 
	var reqMap_rc;
    var PRINTTYPE='${PRINT_TYPE}';
    var  valid1;
	var  valid2;
	var  valid3;
	var  valid4;
	var tempMap={};
	<%--[20231004100043][20231005]確認日期和列印日期的預設起始日和結束日--%>
	var DEFAULT_STR_DT = '<c:out value="${DEFAULT_STR_DT}" />';
	var DEFAULT_END_DT = '<c:out value="${DEFAULT_END_DT}" />';
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1900/" + actionName,
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
			}
		);
	}
		//檢核欄位
	function initValidation(){
				//檢核
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});				
	    valid1.define( "validate-ROCDate-Interval" , [{ id : "INPUT_B" , errMsg :"確認日期迄日需大於確認日期起日，請檢查後重新輸入查詢條件!" },{ id : "INPUT_E" , errMsg :"確認日期迄日需大於確認日期起日，請檢查後重新輸入查詢條件!"}] );
 	    valid1.define('required' , [{ id : "INPUT_B" , errMsg:'請輸入確認日期(起日)!'}] );
		valid1.define('required' , [{ id : "INPUT_E" , errMsg:'請輸入確認日期(迄日)!'}] );
        valid2= new Validation("form1", { focusOnError:true, immediate:false});	
		valid2.define( "validate-ROCDate-Interval" , [{ id : "PRINT_B" , errMsg :"列印日期迄日需大於列印日期起日，請檢查後重新輸入查詢條件!" },{ id : "PRINT_E" , errMsg :"列印日期迄日需大於列印日期起日，請檢查後重新輸入查詢條件!"}] );
 	    valid2.define('required' , [{ id : "PRINT_B" , errMsg:'請輸入列印日期(起日)!'}] );
		valid2.define('required' , [{ id : "PRINT_E" , errMsg:'請輸入列印日期(迄日)!'}] );
		
		Validation.addAllThese([
			[ 'Checkupdate', '請擇一輸入', 
				function(v,elem){ 
				    var tr = elem.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var checks = $(elem).up('tr').select("input[type=checkbox]:checked")[0];
					if(checks){
					    if(!(dataObj['ARRIVAL_DATE'] || dataObj['MEMO']) ){
							return false;
						}
						return true;
					}
					return true;
					
				}
			],
			[ 'NEW-ROCDate', '請輸入正確的民國年格式', 
				function(v,elem){ 
					var checks = $(elem).up('tr').select("input[type=checkbox]:checked")[0];
                    if(checks){
					    if( !Validation.get('IsEmpty').test(v) ){
							return isROCdate(v,false);
						}
						return true;
					}
					return true;
					
				}
			]
			
		]);
		valid3= new Validation("grid", { focusOnError:true, immediate:false});	
		valid4= new Validation("blockC", { focusOnError:true, immediate:false});	
		valid4.define('required' , [{ id : "PRINT_POS" , errMsg:'請輸入列印起始位置!'}] );
		valid4.define('required' , [{ id : "PRINT_NUM" , errMsg:'請輸入列印張數!'}] );
	}		
    // 按鈕權限
	var buttonAuth = function(){
		var authButtons = {
			B0201 : 'BTN_CANCEL',		<%--取消確認--%>	
			B0174 : 'BTN_PRINT',		<%--列印--%>		
			B0202 : 'BTN_PRINTADDR',	<%--列印地址標籤--%>	
			B0203 : 'BTN_PRINTREC',		<%--列印掛號執據--%>	
			B0111 : 'BTN_UPDATE',		<%--異動--%>	
		};
		<dz:grantButtons FUNC_ID='${FUNC_ID}'/>
	};
	
	
	//各種action
	var actions = {
		
		getReqMap :function(){
		    
			var reqMap = {};
			$$('#tableA input[type=radio][name=PRINT_TYPE]:checked').each(
				function(text){
					reqMap['PRINT_TYPE'] = text.value;
				}
			);
			$$('#tableA input[type=radio][name=IS_PRINT]:checked').each(
				function(text){
					reqMap['IS_PRINT'] = text.value;
				}
			);
			if($('INPUT_DATE').checked){
			    reqMap['INPUT_B'] = toY2K($F('INPUT_B'));
				reqMap['INPUT_E'] = toY2K($F('INPUT_E'));
				
			}
			if($('PRINT_DATE').checked){
			    reqMap['PRINT_B'] = toY2K($F('PRINT_B'));
				reqMap['PRINT_E'] = toY2K($F('PRINT_E'));
				
			}
			reqMap['LOAN_ID'] = $F('LOAN_ID');
			reqMap['REFER_ID'] = $F('REFER_ID');
			reqMap['RECEIVE_NAME'] = $F('RECEIVE_NAME');
			reqMap['COPY_NAME'] = $F('COPY_NAME');
			reqMap['INPUT_NAME'] = $F('INPUT_NAME');
			if(reqMap['PRINT_TYPE']=='1'){
		    reqMap['PRINT_TYPE_NM'] = "存證信函";
		    }else{
			reqMap['PRINT_TYPE_NM'] = "催收通知";
			}
     		return reqMap;
		    
		},
		<%-- [20230823] 新增功能 --%>
		toggleBtn : function() {
			if('2' == PRINTTYPE) {
				// 2催收通知才可用
				$('BTN_SEND').enable();
				$('BTN_CANCEL_SEND').enable();
			} else {
				$('BTN_SEND').disable();
				$('BTN_CANCEL_SEND').disable();
			}
		}
		
	}; 
		
		
	//按鈕功能	
	var buttons = {
		
		//初始查詢
		<%--[20231004100043][20231005]修改查詢檢核--%>
		doQuery : function(){		
            
			reqMap_rc = actions.getReqMap();
			//alert(Object.toJSON(reqMap_rc));

			valid1.reset();
			valid2.reset();	
			valid3.reset();	
			valid4.reset();	
			
			if(!reqMap_rc.PRINT_TYPE || !reqMap_rc.IS_PRINT){
			    alert("列印種類和列印狀態為必輸欄位");
				return;
			}
            
			//若無選擇日期種類，則原貸帳號、貸款帳號、收件人ID、副本收件人ID至少需輸入一項
			if($('INPUT_DATE').checked==false &&$('PRINT_DATE').checked==false){

				if(!($F('RECEIVE_NAME')||$F('COPY_NAME')||$F('LOAN_ID')||$F('REFER_ID')||$F('INPUT_NAME'))){
					alert("請至少輸入一項查詢條件");
					return; 
			    } 
			}
			// 列印狀態選擇未列印，則不得選取列印日期起迄and列印日期年月
			if(reqMap_rc.IS_PRINT == "0"){
				<%--[20231004100043][20231005]若列印狀態選未列印，則確認日期起訖必填--%>
				if(!valid1.validate()){
					return; 
				}
				if($('PRINT_DATE').checked==true){
					alert("未列印資料無列印日期");
					return; 
			    } 
			}
			<%--[20231004100043][20231005]若列印狀態選已列印，則列印日期起訖必填--%>
			if(reqMap_rc.IS_PRINT == "1"){
				if(!valid2.validate()){
					return; 
				}
			}
			if($('INPUT_DATE').checked==true){
				if(!valid1.validate()){
				return; 
			    } 
			}
			if($('PRINT_DATE').checked==true){
				if(!valid2.validate()){
				return; 
			    } 
			}
			
			ajaxPost( 'query' , { reqMap : Object.toJSON(reqMap_rc)},
				function(resp){						
                    var rtnList=resp.rtnList||'';
					grid.load(rtnList)
				},
				function(resp){
				    grid.load([]);
			    }
			);
		},
		//異動
		doUpdate : function(){	
   
            var checkedList=grid.getCheckedRecord();
			if(checkedList.length==0){
				alert("至少需選擇一筆資料");
				return;
			}
			if(!valid3.validate()){
				return; 
			} 

			ajaxPost( 'update' , { reqMap : Object.toJSON(actions.getReqMap()),'checkedList': Object.toJSON(checkedList)},
				function(resp){						
                    var rtnList=resp.rtnList||'';
					grid.load(rtnList)
				},
				function(resp){
				    
			    }
			);
		},
		//取消確認
		doCancel : function(){	
   
            var checkedList=grid.getCheckedRecord();
			if(checkedList.length==0){
				alert("至少需選擇一筆資料");
				return;
			}
			//提示確認訊息
			if(!confirm('確定要取消確認? 取消確認後資料將刪除!!')){
				return;
			}
			ajaxPost( 'cancel' , { reqMap : Object.toJSON(actions.getReqMap()),'checkedList': Object.toJSON(checkedList)},
				function(resp){						
                    var rtnList=resp.rtnList||'';
					grid.load(rtnList)
				}
			);
		},
		// 列印
		doPrint: function() {
		    var checkedList=grid.getCheckedRecord();
            if(checkedList.length==0){
				alert("至少需選擇一筆資料");
				return;
			}
			ajaxPost( 'print' , { 'checkedList': Object.toJSON(checkedList),reqMap : Object.toJSON(actions.getReqMap())},
				function(resp){
                    var rtnList=resp.rtnList||'';
					grid.load(rtnList);				
					//RPTUtil.executePrintByResponse(resp, true);	
					//因應報表浮水印控管，需設白名單之報表要有引用到浮水印模組
					RPTUtil.download(resp, true);		
				}
			);	
			
			//RPTUtil.executePrintByLink('print' , {	'checkedList': Object.toJSON(checkedList)}, true );	
			
		},
		// 列印地址標籤
		doPrintAddr: function() {
		    var checkedList=grid.getCheckedRecord();
            if(checkedList.length==0){
				alert("至少需選擇一筆資料");
				return;
			}
			valid4.reset();
			if(!valid4.validate()){
				return; 
			} 
			
			//RPTUtil.executePrintByLink('printAddr' , {	'checkedList': Object.toJSON(checkedList),'PRINT_POS':$F('PRINT_POS'),'PRINT_NUM':$F('PRINT_NUM')}, true );	
			
			//因應報表浮水印控管，需設白名單之報表要有引用到浮水印模組
			RPTUtil.downloadFile("${dispatcher}/DSD1_1900/printAddr" , {	'checkedList': Object.toJSON(checkedList),'PRINT_POS':$F('PRINT_POS'),'PRINT_NUM':$F('PRINT_NUM')}, true );	
			
		},
		// 列印掛號執據
		doPrintReceipt: function() {
		    var checkedList=grid.getCheckedRecord();
            if(checkedList.length==0){
				alert("至少需選擇一筆資料");
				return;
			}
			//RPTUtil.executePrintByLink('printReceipt' , {	'checkedList': Object.toJSON(checkedList)}, true );	
			
			//因應報表浮水印控管，需設白名單之報表要有引用到浮水印模組
			RPTUtil.downloadFile("${dispatcher}/DSD1_1900/printReceipt" , {	'checkedList': Object.toJSON(checkedList)}, true );	
		},
		//匯出
		doExport : function(event){			
			
			if( grid.getAllRecords().length == 0 ){
				alert('請先查詢再匯出');
				return;
			};

			//當前條件
			var reqMap = actions.getReqMap(); //執行queryMap
			// 必須先做過查詢 且畫面上的查詢條件須與[查詢]時一致，否則顯示錯誤訊息
			for(key in reqMap ){
				if(reqMap[key] != reqMap_rc[key]){
					alert('查詢時期條件不同，請重新查詢');
					return;
				}			
			}
			
			var exportParams = {
				CONDITION : Object.toJSON(reqMap),
				gridJSON : grid.getXlsSettingJSON("催收通知紀錄_"+reqMap.PRINT_TYPE_NM),
				isExport : "Y"
			}
			
			RPTUtil.executeCreateCsvFile("<%=dispatcher%>/DSD1_1900/export", exportParams );
		},
		
		<%-- [20230823] 新增功能: 送出製作郵簡 --%>
		doSend : function() {
			var checkedList = grid.getCheckedRecord();
			if(checkedList.length == 0){
				alert("至少需選擇一筆資料");
				return;
			}
			if(!valid3.validate()){
				return; 
			} 
			
			ajaxPost( 'send' , { reqMap : Object.toJSON(actions.getReqMap()), 'checkedList': Object.toJSON(checkedList) },
				function(resp){						
                    var rtnList=resp.rtnList||'';
					grid.load(rtnList);
				},
				function(resp){
					grid.clear();
				}
			);
			
		},
		
		<%-- [20230823] 新增功能: 取消製作郵簡 --%>
		doCancelSend : function() {
			var checkedList = grid.getCheckedRecord();
			if(checkedList.length == 0){
				alert("至少需選擇一筆資料");
				return;
			}
			if(!valid3.validate()){
				return; 
			} 
			
			ajaxPost( 'cancelSend' , { reqMap : Object.toJSON(actions.getReqMap()), 'checkedList': Object.toJSON(checkedList) },
				function(resp){						
                    var rtnList=resp.rtnList||'';
					grid.load(rtnList)
				},
				function(resp){
					grid.clear();
				}
			);
			
		}
		
	
	};

	return{
	
		initApp : function(){
			tempMap[''] = "";
			<c:forEach var="map" items="${MEMO_LIST}">
				tempMap["${map.key}"]="${map.value}";
			</c:forEach>
			
			PageUI.createPageWithAllBodySubElement('DSD11900','催收作業','存證信函/催收通知列印');
			
			//產生 Grid 物件	
			grid = new TableUI({
				table: $('grid'), pageSize: 10, allSortable: true,	
				
				autoCheckBox:{
					text:'選取',
                    isSelectAll :true,					
					type:'checkbox'
				},
				<%-- [20240326] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: [
				    {header:"貸款帳號", key:'LOAN_ID'}, 
				    {header:"原貸帳號", key:'REFER_ID'},
					{header:"序號", key:'SEQ_NO'},
					{header:"寄送情形", key:'MEMO',
					    input:{
						    type:'select',
							opts:tempMap
						}	
					},
					
					{header:"送達日期", key:'ARRIVAL_DATE',
					    render :function(record,value){
						    var theID = "ARRIVAL_DATE"+record.SEQ_NO;
							var td = new Element('td');
							//[20180824] 不設type='DATE', 增加name = theID+'_input'
							var input = new Element('input', {className : 'textBox2 Checkupdate NEW-ROCDate', id:theID, name:theID+'_input', datatype:'ROCdate', size:'10', maxlength:'9' ,fieldName : '送達日期' });
						    input.value = Date.toInputROC( value || '' ,'');
						    input.observe('change' , function(event){
							var tr = this.up('tr');
							var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
							dataObj["ARRIVAL_DATE"] = toY2K(event.target.value||'');
							});
							var clan =   new Element('img', { src : '<%=imageBase%>/CM/calendar.gif' , alt : 'Date'});			
				
							clan.observe('click' , function(event){					
								getCalendarFor(input);
							});
							td.insert(input).insert(clan);
							return td;	
					    }
					},
					{header:"最近實繳日", key:'REAL_PAYDT',
					    render :function(record,value){
						    return Date.toROC( value|| '');
						}
					},
					<%-- [20240326] 難字調整：收件人 --%>
					{header:"收件人", key:'RECEIVE_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"收件人種類", key:'RECEIVE_KIND_NM'},
					<%-- [20240326] 難字調整：副本收件人 --%>
					{header:"副本收件人", key:'COPY_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"承辦科別", key:'CRED_DEPT_NM'},
					<%-- [20240326] 難字調整：確認人員 --%>
					{header:"確認人員", key:'INPUT_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"確認日期", key:'INPUT_DATE',
					    render :function(record,value){
						    return Date.toROC( value|| '');
						}
					},
					<%-- [20240326] 難字調整：列印人員 --%>
					{header:"列印人員", key:'PRINT_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"列印日期", key:'PRINT_DATE',
					    render :function(record,value){
						    return Date.toROC( value|| '');
						}
					},
					<%-- [20240326] 難字調整：送出人員 --%>
					{header:"送出人員", key:'SEND_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"送出日期", key:'SEND_TIME',
					    render :function(record,value){
						    return Date.toROC( value|| '');
						}
					},
					<%-- [20240326] 難字調整：最後異動人員 --%>
				    {header:"最後異動人員", key:'LST_PROC_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"最後異動日期", key:'LST_PROC_DATE',
					    render :function(record,value){
						    return Date.toROC( value|| '');
						}
					}
				]	
			});	
            initValidation();
			buttonAuth();
			// 查詢
		    $('BTN_QUERY').observe('click', buttons.doQuery);
			$('BTN_PRINTADDR').observe('click', buttons.doPrintAddr);
			$('BTN_PRINTREC').observe('click', buttons.doPrintReceipt);
			$('BTN_PRINT').observe('click', buttons.doPrint);  
			$('BTN_UPDATE').observe('click', buttons.doUpdate);  
			$('BTN_CANCEL').observe('click', buttons.doCancel);  
			$('BTN_EXPORT').observe('click', buttons.doExport);  
			$('BTN_SEND').observe('click', buttons.doSend); <%-- [20330823] 新增功能 --%>
			$('BTN_CANCEL_SEND').observe('click', buttons.doCancelSend); <%-- [20330823] 新增功能 --%>
			
			//查詢條件連動(日期方面)
            $('INPUT_DATE').observe('click',  function(event){
            	$('INPUT_B').setValue(DEFAULT_STR_DT);<%-- [20231004100043][20231005] 新增預設值為當月1號 --%>
				$('INPUT_E').setValue(DEFAULT_END_DT);<%-- [20231004100043][20231005] 新增預設值為今天 --%>
				$('PRINT_B').setValue("");
				$('PRINT_E').setValue("");
			});	
            $('PRINT_DATE').observe('click',  function(event){	
				$('INPUT_B').setValue("");
				$('INPUT_E').setValue("");
				$('PRINT_B').setValue(DEFAULT_STR_DT);<%-- [20231004100043][20231005] 新增預設值為當月1號 --%>
				$('PRINT_E').setValue(DEFAULT_END_DT);<%-- [20231004100043][20231005] 新增預設值為當天 --%>
			});	
			//查詢條件連動(查詢種類)
			$('REFER_ID').observe('keyup',  function(event){	
				$('REFER_ID').value = $F('REFER_ID').toUpperCase();

			});	
			$('REFER_ID').observe('focus',  function(event){	
				$('LOAN_ID').setValue("");
				$('RECEIVE_NAME').setValue("");
				$('COPY_NAME').setValue("");
				$('INPUT_NAME').setValue("");
			});	
			$('LOAN_ID').observe('keyup',  function(event){	
				$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();

			});	
			$('LOAN_ID').observe('focus',  function(event){	
				$('REFER_ID').setValue("");
				$('RECEIVE_NAME').setValue("");
				$('COPY_NAME').setValue("");
				$('INPUT_NAME').setValue("");
			});	
			$('RECEIVE_NAME').observe('focus',  function(event){	
				$('LOAN_ID').setValue("");
				$('REFER_ID').setValue("");
				$('COPY_NAME').setValue("");
				$('INPUT_NAME').setValue("");
			});	
			$('COPY_NAME').observe('focus',  function(event){	
				$('LOAN_ID').setValue("");
				$('RECEIVE_NAME').setValue("");
				$('REFER_ID').setValue("");
				$('INPUT_NAME').setValue("");
			});	
			$('INPUT_NAME').observe('focus',  function(event){	
				$('LOAN_ID').setValue("");
				$('REFER_ID').setValue("");
				$('COPY_NAME').setValue("");
				$('RECEIVE_NAME').setValue("");
			});	
			
			//列印種類(if 列印種類= ‘催收通知’ then副本收件人姓名 disable)
			if(PRINTTYPE=='1'){
				$('1').checked=true;  //列印種類:存證信函
				$('INPUT_DATE').checked = true;  //日期種類:確認日期起迄
				$('0').checked=true;  //列印狀態:未列印
			}else if(PRINTTYPE=='2'){
			    $('2').checked=true;
				$('COPY_NAME').disable();
				$('COPY_NAME').setValue("");
			} 
			
			
			<%-- [20230823] 依條件使按鈕enabled --%>
			actions.toggleBtn();
			
			/*
			$('2').observe('click',  function(event){	
				$('COPY_NAME').disable();
				$('COPY_NAME').setValue("");
			});	
			$('1').observe('click',  function(event){	
				$('COPY_NAME').enable();
			});
			*/
			PageUI.resize();

			displayMessage();				
		}
	}
}
</script>
</head>
<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id='tableA' name='tableA' width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
		<tr>
			<td class='tbYellow'>
				列印種類
			</td>
			<td class='tbYellow2' >
				<c:forEach items="${PRINT_TYPE_LIST}" var="item">
				<span style="display:inline-block" field="LIST">
					<input id="${item.key}" name="PRINT_TYPE" type="radio" value="${item.key}" disabled>${item.value}
				</span>
			    </c:forEach>	
			</td>
			<td class='tbYellow' >
				列印狀態
			</td>
			<td class='tbYellow2' >
				<c:forEach items="${PRINT_LIST}" var="item">
				<span style="display:inline-block" field="LIST">
					<input id="${item.key}" name="IS_PRINT" type="radio" value="${item.key}">${item.value}
				</span>
			    </c:forEach>	
			</td>
            <td class="tbYellow2" rowspan="2" align="center" width='10%'>
			 <input id="BTN_QUERY" type="button" class="button" value='查詢' /> 
			 <input id="BTN_EXPORT" type="button" class="button" value='匯出' /> 
		    </td>
		</tr>
		<tr>
		    <td class='tbYellow' width="8%">
		   	    日期種類
			</td>
			<td class='tbYellow2' width="20%" colspan='3'> 
				<input id="INPUT_DATE" name="DATE_STATUS" type="radio">確認日期起迄
				<input id="INPUT_B" datatype="ROCDate" type="text" class="textBox2 "  size="10" maxlength="7" value="${DEFAULT_STR_DT}"/>
			    <img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('INPUT_B'))">
				~
				<input id="INPUT_E" datatype="ROCDate" type="text" class="textBox2 "  size="10" maxlength="7" value="${DEFAULT_END_DT}"/>
			    <img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('INPUT_E'))">
				<br>
				<input id="PRINT_DATE" name="DATE_STATUS" type="radio" >處理日期起迄
				<input id="PRINT_B" datatype="ROCDate" type="text" class="textBox2 "  size="10" maxlength="7" value=""/>
			    <img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('PRINT_B'))">
				~
				<input id="PRINT_E" datatype="ROCDate" type="text" class="textBox2 "  size="10" maxlength="7" value=""/>
			    <img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('PRINT_E'))">
			</td>
		</tr>
		<tr>
		    <td class='tbYellow'>
				查詢種類
			</td>
		    <td class='tbYellow2' colspan='4'>
			    確認人員
			    <%-- [20240326] 難字調整：確認人員 --%>
				<input id="INPUT_NAME" type="text" class="textBox2 "  size="7" maxlength="5" value="${USER_EMPNAME}" alt="ch" />
			    原貸帳號
				<input id="REFER_ID" type="text" class="textBox2 "  size="12" maxlength="10" value=""/>
			    貸款帳號
				<input id="LOAN_ID" type="text" class="textBox2 "  size="12" maxlength="10" value=""/>
				收件人姓名
				<%-- [20240326] 難字調整：收件人姓名 --%>
				<input id="RECEIVE_NAME" type="text" class="textBox2 "  size="7" maxlength="5" value="" alt="ch" />
				副本收件人姓名
				<%-- [20240326] 難字調整：副本收件人姓名 --%>
				<input id="COPY_NAME" type="text" class="textBox2 "  size="7" maxlength="5" value="" alt="ch" />
				
			
			</td>
		
		
		</tr>
		
		
		<tr>
		    <td width="8%" colspan='5' align="center" >
		   	    <input id="BTN_CANCEL" type="button" class="button" value='取消確認' /> 
			    <input id="BTN_PRINT" type="button" class="button" value='列印' /> 
			    <input id="BTN_PRINTADDR" type="button" class="button" value='列印地址標籤' /> 
	     		<input id="BTN_PRINTREC" type="button" class="button" value='列印掛號執據' /> 
				<input id="BTN_UPDATE" type="button" class="button" value='異動' /> 
				<input id="BTN_SEND" type="button" class="button" value='送出製作郵簡' /> <%-- [20230823] 新增按鈕 --%>
				<input id="BTN_CANCEL_SEND" type="button" class="button" value='取消送出製作郵簡' /> <%-- [20230823] 新增按鈕 --%>
			</td>
		     
		</tr>
    </table>
	<table id = "grid" ></table>
	<table id='blockC' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td class="tbYellow" width="10%">列印起始位置：</td>
				<td class="tbYellow2" width="23%">
					<input id="PRINT_POS" type="text" class="textBox2" size="15" value="1" onkeypress="return numberOnly()" fieldName="列印起始位置">
				</td>
				<td class="tbYellow" width="10%">列印張數：</td>
				<td class="tbYellow2" width="23%">
					<input id="PRINT_NUM" type="text" class="textBox2" size="15" value="1" onkeypress="return numberOnly()" fieldName="列印張數">
				</td>
				<td class="tbYellow2" rowspan="3" align="center">
					<table width="82%" cellpadding="0" cellspacing="1" class="tbBox2">
						<tr align="center">
							<td class="tbYellow2" colspan="3">列印編號位置圖：</td>
						</tr>
						<tr class="tbYellow" align="center"><td>1</td><td>2</td></tr>
						<tr class="tbYellow" align="center"><td>3</td><td>4</td></tr>
						<tr class="tbYellow" align="center"><td>5</td><td>6</td></tr>
						<tr class="tbYellow" align="center"><td>7</td><td>8</td></tr>
						<tr class="tbYellow" align="center"><td>9</td><td>10</td></tr>
						<tr class="tbYellow" align="center"><td>11</td><td>12</td></tr>
						<tr class="tbYellow" align="center"><td>13</td><td>14</td></tr>
						<tr class="tbYellow" align="center"><td>15</td><td>16</td></tr>
						<tr class="tbYellow" align="center"><td>17</td><td>18</td></tr>
						<tr class="tbYellow" align="center"><td>19</td><td>20</td></tr>
						<tr class="tbYellow" align="center"><td>21</td><td>22</td></tr>
						<tr class="tbYellow" align="center"><td>23</td><td>24</td></tr>
						<tr class="tbYellow" align="center"><td>25</td><td>26</td></tr>
					</table>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="4"> 
					<font color="blue">&nbsp; 一、注意事項</font>
							<br>&nbsp; &nbsp; 1. 當<font color="red">列印地址標籤</font>時，請將列印設定中的【<font color="blue">頁面縮放</font>】，改成【<font color="red">無</font>】。
                            <br>
							<br>
							<br>
							<br>
							<br>
							<br>
				</td>
				
				
				
			</tr>			
	</table>
	
</form>	
</body>
</html>