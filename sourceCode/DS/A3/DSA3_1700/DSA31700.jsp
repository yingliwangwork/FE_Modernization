<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA31700.jsp
作者：王文進
功能：鑑價請款QC
完成：2012/4/10
更新：
-->

<html>
<head></head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<!--  <script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/calendar.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/date.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/Validator.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/validation.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/utility.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>

<%--自行定義的javaScript--%>
<script type="text/JavaScript">
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA31700().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31700(){
	
	var valid1;
	var column1;
	var grid = {};
	var grid1 = {};
	var grid2 = {};
	var grid3 = {};
	var sumAMOUNT = '0';
	var conCHECK_YM = '';
	var conAPPR_TYPE='';
	var conREQ_SRC='';
	var conACTION_TYPE='';
	var btnCon = false;
	
	var colMaps={
			colA:[
				{header:'序號', key:'SER_NO',
					render:function(record, value){
						return value ? value : '';
					}
				},
				{header:'受理編號', key:'APPLY_ID',
					render:function(record, value){
					 	return value ? value : '';
					}
				},
				{header:'結案日期', key:'CLOSE_DATE',
					render:function(record, value){
					 	return value ? Date.toROC(value) : '';
					}
				},
				{ header: '送件日', key: 'SEND_DATE'
					, render: function(record, value) {
						return value ? Date.toROC(value) : '';
					}
				},
				{ header: '建築型態', key: 'USE_FOR_NM' },
				{ header: '室內照拍攝', key: 'NOPIC_REASON_NM' },
				{ header: '鑑估總額(萬)', key: 'TOTAL_PRICE'
					, render: function(record, value) {
						return value ? CSRUtil.$fmt(value, '#,##0.###') : '0';
					}
				},
				{ header: '總戶數', key: 'TOTAL_FAMILY_CNT'
					, render: function(record, value) {
						return value ? CSRUtil.$fmt(value, '#,##0') : '0';
					}
				},
				{header:'請款金額', key:'AMOUNT', sortRule:'number', 
                	input:{
						type:'TEXT',
						size:12,
						maxlength:11,
                        genRule:function(record , value){
                            return true;
                        },
                        action:function( node , dataObj , textDiv, orgData , isOnChange ){
                        	if(!isOnChange){
								node.id = 'AMOUNT_' + dataObj[0]["SER_NO"]; 
								node.APPLY_ID = dataObj[0]["APPLY_ID"]; 
								node.value = CSRUtil.$fmt(node.value, '#,##0.###'); 
								node.datatype = 'number';
							}
						}, actionWhenStart:true
                	}
				},
				{header:'修改', key:'',
					render:function(record, value){
						var unique_id = record.APPLY_ID + '_' + record.SER_NO; 
                		var div = document.createElement('div');
                		var input = document.createElement('input');
                		input.id = unique_id;
                		input.value = '異動';
                		input.type = 'button';
                		input.className = 'button';
                		input.onclick = function(){
                			doUpdate(record.APPLY_ID,$("AMOUNT_"+record.SER_NO).value);
                		};
                		div.appendChild(input);
                		
                		return div;
					}
				}
			],
			colB:[
				{header:'序號', key:'SER_NO',
					render:function(record, value){
						return value ? value : '';
					}
				},
				{ header: "流水號", key: "UID" },
				{ header: "發送請求時間", key: "REQ_TIME" },
				{ header: "請求服務來源", key: "REQ_SRC" },
				{ header: "請求服務_細項", key: "SUBREQ_SRC" },
				{ header: "請求服務單位", key: "DIV_NO"},
				{ header: "請求服務人員", key: "QRY_ID"},
				{ header: "使用情境", key: "ACTION_TYPE"},
				{ header: "城市名稱", key: "CITY_NAME"},
				{ header: "行政區", key: "TOWN"},
				{ header: "門牌號碼", key: "ADDR"},
				{ header: "社區名稱", key: "COMMUNITY_NM"},
				{ header: "單價區間_鑑估最低價", key: "MIN_PRICE"},
				{ header: "單價區間_鑑估最高價", key: "MAX_PRICE"},
				{ header: "承作區域", key: "AREA_CODE"},
				{ header: "回應時間", key: "RESP_TIME"},
				{ header: "回應狀態", key: "RESP_STATUS"}
			],
			colC:[ //擔保品分行及後續API
				{header:'序號', key:'SER_NO',
					render:function(record, value){
						return value ? value : '';
					}
				},
				{ header: "流水號", key: "UID" },
				{ header: "發送請求時間", key: "REQ_TIME" },
				{ header: "請求服務來源", key: "REQ_SRC" },
				{ header: "請求服務_細項", key: "SUBREQ_SRC" },
				{ header: "請求服務單位", key: "DIV_NO"},
				{ header: "請求服務人員", key: "QRY_ID"},
				{ header: "使用情境", key: "ACTION_TYPE"},
				{ header: "回應時間", key: "RESP_TIME"},
				{ header: "回應狀態", key: "RESP_STATUS"},
				{ header: "請求參數JSON", key: "REQ_JSON"},
				{ header: "回應參數JSON", key: "RESP_JSON"}		
			]
		}
	

	<%--
	button控制
	--%>
	var authButtons = {
		B0021:"btn_export<%--匯出excel--%>",
		B0111:[]<%--異動--%>,
		B0110:"btn_confirm<%--QC確認--%>"
	};
	var buttonAuth = function (){
		<dz:grantButtons FUNC_ID="DSA31700" ignored="false"/>
		$("btn_confirm").disabled = btnCon;
		$$('#grid input[type="button"]').each(function(button){
			button.disabled = btnCon;
		});
	};
	
	//成功
	var successActionOpen = function(resp){
		rtnList = resp.rtnList ? resp.rtnList : [];
		sumTotalList = resp.sumTotalList ? resp.sumTotalList : [];
		MSG = resp.MSG ? resp.MSG : '';
		if(''!=MSG){
			$("btn_confirm").disabled = true;
		}else{
			$("btn_confirm").disabled = false;
		}
		btnCon = $("btn_confirm").disabled;
		
		authButtons.B0111 = [];
		for(var i = 0 ; i < rtnList.length ; i++){  
			var obj = rtnList[i];
			authButtons.B0111.push(obj.APPLY_ID + '_' + obj.SER_NO);
		};
		if($('APPR_TYPE').getValue()=="1"){
			grid.load(rtnList,sumTotalList);	
		}else if($('APPR_TYPE').getValue()=="2"){
			grid2.load(rtnList,sumTotalList);
		}else if($('APPR_TYPE').getValue()=="3"){
			grid3.load(rtnList,sumTotalList);
		}
		

		buttonAuth();

		sumAMOUNT = resp.sumAMOUNT ? resp.sumAMOUNT : '0';
		autoFormatToNumber();
	};
	//失敗
	var errorActionOpen = function(resp){
		grid.load([]);
		grid2.load([]);
		grid3.load([]);
		$("btn_confirm").disabled = true;
		autoFormatToNumber();
	};
	
	//查詢
	function doQuery(){
		
		if($('APPR_TYPE').getValue()=="1"){
			if($('APPLY_ID').value==""){
				alert("請輸入受理編號");
				return;
			}
		}
		$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
		
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		var checkYM=$('CHECK_YM').value;;
		if(checkYM==""){
			alert("鑑價年月不可空白");
			return;
		}
		var dataMap = {};
		dataMap.CHECK_YM = checkYM;
		dataMap.APPR_TYPE= $('APPR_TYPE').getValue();
		dataMap.REQ_SRC= $('REQ_SRC').getValue();
		dataMap.APPLY_ID= $('APPLY_ID').getValue();
		conCHECK_YM = $('CHECK_YM').value;
		conAPPR_TYPE = $('APPR_TYPE').getValue();
		conREQ_SRC = $('REQ_SRC').getValue();
		dataMap.ACTION_TYPE= conACTION_TYPE;
				
		var params = { inputMap:Object.toJSON(dataMap) };
		
		ajaxPost('query',params,successActionOpen,errorActionOpen);
	}
	
	//--------------------------------------------------------------------------	
	//	匯出 excel Function
	//--------------------------------------------------------------------------
	function doExportXls(){
		
		$('APPLY_ID').value = ""; //清空
	
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		if($('APPR_TYPE').getValue()=="1"){
			//$('gridJSON').value = grid1.getXlsSettingJSON('鑑價請款QC');	
			var exportParams = {
					gridJSON : grid1.getXlsSettingJSON("鑑價請款QC"),
					isExport : "Y",
					CHECK_YM : $('CHECK_YM').getValue(),
					APPR_TYPE: $('APPR_TYPE').getValue()
				}
			
			//RPTUtil.executeCreateXlsFile('${dispatcher}/DSA3_1700/exportXls', Form.serialize("form1"));	
			RPTUtil.executeCreateXlsFile('${dispatcher}/DSA3_1700/exportXls', exportParams);
		}else if($('APPR_TYPE').getValue()=="2"){
			$('gridJSON').value = grid2.getXlsSettingJSON('AVM鑑價請款QC');
			var exportParams = {
					gridJSON : grid2.getXlsSettingJSON("AVM鑑價請款QC"),
					isExport : "Y",
					CHECK_YM : $('CHECK_YM').getValue(),
					APPR_TYPE: $('APPR_TYPE').getValue(),
					REQ_SRC: $('REQ_SRC').getValue(),
					ACTION_TYPE : conACTION_TYPE
				}
				
				RPTUtil.executeCreateCsvFile('${dispatcher}/DSA3_1700/exportXls', exportParams );
		}else if($('APPR_TYPE').getValue()=="3"){ 
			$('gridJSON').value = grid2.getXlsSettingJSON('擔保品附近分行QC');
			var exportParams = {
					gridJSON : grid2.getXlsSettingJSON("擔保品附近分行QC"),
					isExport : "Y",
					CHECK_YM : $('CHECK_YM').getValue(),
					APPR_TYPE: $('APPR_TYPE').getValue(),
					REQ_SRC: $('REQ_SRC').getValue(),
					ACTION_TYPE : conACTION_TYPE
				}
				
				RPTUtil.executeCreateCsvFile('${dispatcher}/DSA3_1700/exportXls', exportParams );
		}
		//alert("$('gridJSON'):"+$('gridJSON').getValue());
		//return;
			
	}
	
	//--------------------------------------------------------------------------	
	//	QC確認按鈕 Function
	//--------------------------------------------------------------------------
	function doConfirm(){
		
		$('APPLY_ID').value = ""; //清空
	
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		var APPR_TYPE=$('APPR_TYPE').getValue();
		if(APPR_TYPE=="2"||APPR_TYPE=="3"){
			if(conCHECK_YM!=$('CHECK_YM').value){
				alert("欲作業的鑑價年月"+$('CHECK_YM').value+"與原先查詢的鑑價年月"+conCHECK_YM+"不同,無法作業!");
				return;
			}
			
			if(conAPPR_TYPE!=$('APPR_TYPE').getValue()){
				alert("欲作業的鑑價種類"+$('APPR_TYPE').value+"與原先查詢的鑑價種類"+conAPPR_TYPE+"不同,無法作業!");
				return;
			}
			
			if(conREQ_SRC!=$('REQ_SRC').getValue()){
				alert("欲作業的請求服務來源"+$('REQ_SRC').value+"與原先查詢的來源"+conREQ_SRC+"不同,無法作業!");
				return;
			}
		}
		
		var hasNoneData=true;
		if(APPR_TYPE=="1"){
			/*if (grid.getAllRecords().length >0 ){
				hasNoneData=false;		
			}*/
			hasNoneData=false;
		}else if(APPR_TYPE=="2"){
			if (grid2.getAllRecords().length >0 ){
				hasNoneData=false;		
			}
		}else if(APPR_TYPE=="3"){
			if (grid3.getAllRecords().length >0 ){
				hasNoneData=false;		
			}
		}
		if (hasNoneData){
			alert("需有資料方可進行QC確認作業");
			return;			
		}
		
		/*var dataMap = {};
		dataMap.CHECK_YM = $('CHECK_YM').value;
		dataMap.AMOUNT = sumAMOUNT;
		dataMap.APPR_TYPE =$('APPR_TYPE').getValue();
		dataMap.REQ_SRC =$('REQ_SRC').getValue();
		
		if(APPR_TYPE=="1"){
			var allRec  = grid.getAllRecords();
		}else if(APPR_TYPE=="2"){
			var allRec  = grid2.getAllRecords();
		}*/
				
		//var params = { inputMap:Object.toJSON(dataMap),inputList:Object.toJSON(allRec) };
		
		//ajaxPost('confirm',params,successActionOpen,null);
		
		if(APPR_TYPE=="1"){
			
			var dataMap1 = {};
			dataMap1.CHECK_YM = $('CHECK_YM').value;
			dataMap1.APPR_TYPE =$('APPR_TYPE').getValue();
			
			var params1 = { inputMap:Object.toJSON(dataMap1) };
			
			new Ajax.Request( "${dispatcher}/DSA3_1700/confirmCheck",
		    	{ 	
			    	parameters: params1, 	    	
			        onSuccess: function(XHT,resp){
						if(CSRUtil.isSuccess(resp)){
							
							var confirmCheckMSG = resp.confirmCheckMSG;
							if(confirmCheckMSG){
								confirmCheckMSG = confirmCheckMSG.replace(/\\r|\\n|\\r\\n/g, "\n");
							}
							if(!confirm(confirmCheckMSG)){
								return false;
							}
							
							var dataMap2 = {};
							dataMap2.CHECK_YM = $('CHECK_YM').value;
							dataMap2.APPR_TYPE =$('APPR_TYPE').getValue();
							dataMap2.AMOUNT = resp.sumAMOUNT;
							
							var params2 = { inputMap:Object.toJSON(dataMap2) };
							
							ajaxPost('confirm',params2,successActionOpen,null);
						}
			        }}
				);
		}else if(APPR_TYPE=="2"){
			
			var dataMap = {};
			dataMap.CHECK_YM = $('CHECK_YM').value;
			dataMap.AMOUNT = sumAMOUNT;
			dataMap.APPR_TYPE =$('APPR_TYPE').getValue();
			dataMap.REQ_SRC =$('REQ_SRC').getValue();
			dataMap.ACTION_TYPE = conACTION_TYPE;
			
			var params = { inputMap:Object.toJSON(dataMap) };
			
			ajaxPost('confirm',params,successActionOpen,null);
		}else if(APPR_TYPE=="3"){
			
			var dataMap = {};
			dataMap.CHECK_YM = $('CHECK_YM').value;
			dataMap.AMOUNT = sumAMOUNT;
			dataMap.APPR_TYPE =$('APPR_TYPE').getValue();
			dataMap.REQ_SRC =$('REQ_SRC').getValue();
			dataMap.ACTION_TYPE = conACTION_TYPE;
			
			var params = { inputMap:Object.toJSON(dataMap) };
			
			ajaxPost('confirm',params,successActionOpen,null);
		}
	}
	
	//--------------------------------------------------------------------------	
	//	異動按鈕 Function
	//--------------------------------------------------------------------------
	function doUpdate(v1, v2){
		
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		if(conCHECK_YM!=$('CHECK_YM').value){
			alert("欲作業的鑑價年月"+$('CHECK_YM').value+"與原先查詢的鑑價年月"+conCHECK_YM+"不同,無法作業!");
			return;
		}
		
		if(conAPPR_TYPE!=$('APPR_TYPE').value){
			alert("欲作業的鑑價種類"+$('APPR_TYPE').value+"與原先查詢的鑑價種類"+conAPPR_TYPE+"不同,無法作業!");
			return;
		}
		
		if(conREQ_SRC!=$('REQ_SRC').value){
			alert("欲作業的請求服務來源"+$('REQ_SRC').value+"與原先查詢的來源"+conREQ_SRC+"不同,無法作業!");
			return;
		}
		
		if(v2=='' || parseInt(v2.replace(/,/gi,'')) < 0){
			alert("請輸入大於零之有效整數");
			return;
		}
		
		if (grid.getAllRecords().length ==0 ){
			alert("需有資料方可進行異動作業");
			return;			
		}
		
		var allRec  = grid.getAllRecords();
		var insertRec = [];
		var insRec = {'APPLY_ID':v1,'AMOUNT':v2.replace(/,/gi,'')};
		insertRec[0] = insRec;
		
		var dataMap = {};
		dataMap.CHECK_YM = $('CHECK_YM').value;
		dataMap.AMOUNT = sumAMOUNT;
				
		var params = { inputMap:Object.toJSON(dataMap),inputList:Object.toJSON(insertRec) };
		
		ajaxPost('update',params,successActionOpen,null);
	
	}
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "${dispatcher}/DSA3_1700/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}

	function APPR_TYPE_Changed( APPR_TYPE ){
		$('grid').hide();
		$('grid2').hide();
		$('grid3').hide();
		grid.load([]);
		grid2.load([]);
		grid3.load([]);
		//alert("APPR_TYPE:"+APPR_TYPE);
		if(APPR_TYPE=="1"){
			$('grid').show();
			$('APPLY_ID').enable();
		}
		if(APPR_TYPE=="2"){
			$('grid2').show();
			$('APPLY_ID').value = ""; //清空
			$('APPLY_ID').disable();
			conACTION_TYPE='1';
		}
		if(APPR_TYPE=="3"){ //擔保品分行
			$('grid3').show();
			$('APPLY_ID').value = ""; //清空
			$('APPLY_ID').disable();
			conACTION_TYPE='2';
		}
	}
	
	return {
		'initApp' : function() {
			PageUI.createPage("DSA31700" , "鑑價作業" , "鑑價請款QC");
			PageUI.loadin(["tableA","grid","grid2","grid3"] ,1);
			
			Validation.addAllThese([	
				[ 'validateAPPLY_ID',  '受理編號長度不正確 需為11碼', 
					function(v){				
						return (v!=="" && v.length != 11) ? false : true ;   
					} 
				]
			]);
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			valid1.define( "validateAPPLY_ID" , { id: "APPLY_ID" } );
			
			//產生 Grid 物件                
			grid = new TableUI({
				table: $('grid'), pageSize: 100, allSortable: true,
				column:colMaps.colA	 <%----%>
				,pageChange:function(pageNO){
					buttonAuth();
					autoFormatToNumber();
				}
			});
			
			//產生   物件   匯出excel檔的欄位              
			grid1 = new TableUI({
				table: $('grid1'), pageSize: 500, allSortable: true,
				column:[
					{ header:'序號', key:'SER_NO' },
					{ header:'受理編號', key:'APPLY_ID' },
					{ header:'結案日期', key:'CLOSE_DATE' },
					{ header: '送件日', key: 'SEND_DATE' },
					{ header: '建築型態', key: 'USE_FOR_NM' },
					{ header: '室內照拍攝', key: 'NOPIC_REASON_NM' },
					{ header: '鑑估總額(萬)', key: 'TOTAL_PRICE', sortRule:'number' },
					{ header: '總戶數', key: 'TOTAL_FAMILY_CNT', sortRule:'number' },
					{ header:'請款金額', key:'AMOUNT', sortRule:'number' }
				]<%----%>
			});
			
			//產生 Grid 物件       for AVM數據使用         
			grid2 = new TableUI({
				table: $('grid2'), pageSize: 100, allSortable: true,
				column:colMaps.colB	 <%----%>
			});
			//產生 Grid 物件       for 擔保品分行       
			grid3 = new TableUI({
				table: $('grid3'), pageSize: 100, allSortable: true,
				column:colMaps.colC	 <%----%>
			});
			$('grid').hide();
			$('grid2').hide();
			$('grid3').hide();
			if($('APPR_TYPE').getValue() == "1") {
				$('grid').show();
				$('APPLY_ID').enable();
			}else if($('APPR_TYPE').getValue() == "2") {
				$('grid2').show();
				$('APPLY_ID').value = ""; //清空
				$('APPLY_ID').disable();
			}else{
				$('grid').show();
				$('APPLY_ID').enable();
			}
			
			// 查詢
			$('btn_query').observe('click',function(event) { doQuery(); } );
			// 匯出excel按鈕
			$("btn_export").observe('click', function(event) { doExportXls(); } );
			// QC確認按鈕
			$("btn_confirm").observe('click', function(event) { doConfirm(); } );
			
			//鑑價種類選擇事件
			$('APPR_TYPE').observe('change', function(event){
				APPR_TYPE_Changed( event.target.value );
			});
			
			buttonAuth();

			displayMessage();

			$('CHECK_YM').value = '${CHECK_YM}';
			
			btnCon = $("btn_confirm").disabled;
		}                 
	}
}

// 只能輸入數字
function numberOnly(){
	return (event.keyCode > 47 && event.keyCode < 58 );
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<form id="form1" name="form1" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
		<tr>
			<td class="tbYellow" width="15%">
				鑑價種類
			</td>
			<td class="tbYellow2" width="15%">
				<select id="APPR_TYPE" name="APPR_TYPE">
					<c:forEach items="${APPR_TYPE_LIST}" var="item">
						<option value="${item.key}" />${item.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" width="15%">
				鑑價年月
			</td>
			<td class="tbYellow2" width="15%">
				<input type="hidden" name="gridJSON" id="gridJSON" value="">
				<input type="text" class="textBox required" fieldName="鑑價年月" id="CHECK_YM" name="CHECK_YM" size="5" maxlength="5" onkeypress="return numberOnly()">
			</td>
			<td class="tbYellow2" align="center" rowspan="2" width="20%">
				<input id="btn_query" type="button" class="button" value="查詢">
				<input id="btn_export" type="button" class="button"value="匯出">
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">
				估價服務對象
			</td>
			<td class="tbYellow2" width="15%">
				<select id="REQ_SRC" name="REQ_SRC">
					<c:forEach items="${REQ_SRC_LIST}" var="item">
						<option value="${item.key}" />${item.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" width="15%">
				受理編號
			</td>
			<td class="tbYellow2" width="15%">
				<input id="APPLY_ID" name="APPLY_ID" type="text" class="text2" size="12" maxlength="11" />				
			</td>
		</tr>
		<tr>
			<td colspan="5" align="center">
				<input id="btn_confirm" type="button" class="button"value="QC確認" >
			</td>
		</tr>
	</table>
	<div><table id="grid" class="grid"></table></div>
	<div><table id="grid2" class="grid"></table></div>
	<div><table id="grid3" class="grid"></table></div>
	
	</form>
	
	<div id="btn_agree_div" style="display:none">  
	<table id="grid1" class="grid"></table>
	</div>

</body>
<!-- InstanceEnd -->
</html>
