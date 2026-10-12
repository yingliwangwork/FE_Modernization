<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC82100.jsp
作者：陳思涵
功能：業績資料變更
完成：2013/08/09

[20230321] 修改程式  楊青峰
難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<%-- [20230321] --%>
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

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript">

Event.observe(window, 'load', new DSC82100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC82100(){

	var valid1;
	var valid2;
	var valid3;
	var valid4;
	var valid5;
	var valid6;
	var valid7;
	var grid;
	var gridD;
	var queryRecord;
	var confirmQueryRecord = false;
	
	
	function buttonAuth(){
		var authButtons = {	
			B0054:"btn_update",
			B0224:"btn_delete",		
			B0070:"btn_confirm"			
		};
		<dz:grantButtons FUNC_ID="DSC82100" />
	}
	
	//畫面檢核
	function  initValidation(){
	
		Validation.addAllThese([

			[ 'check1',  '經手人變更請輸入貸款帳號或受理編號!', 
				function(v,elm) {				
					if((Validation.get('IsEmpty').test(v))&&(($F('APPLY_ID') == null) || ($F('APPLY_ID') == 0))){
						return false;
					}
					return true;
				}
			],
			
			[ 'checkLOAN_ID',  '貸款帳號長度不對', function(v,elm) {			
				if(v && !Validation.get('IsEmpty').test(v)){
					if(v.length!=10){
						return false;
					}	
				}
				return true;
			}],
			
			[ 'checkAPPLY_ID',  '受理編號長度不對', function(v,elm) {			
				if(!Validation.get('IsEmpty').test(v)){
					if(v.length!=11){
						return false;
					}	
				}
				return true;
			}],
			
			[ 'checkDEPT',  '請輸入業績歸屬單位,共5碼!!', function(v,elm) {
				if(!Validation.get('IsEmpty').test(v)){
					if(v.length!=5){
						return false;
					}
					return true;
				}else{
					return false;
				}
			}],
			
			[ 'checkWorkMonth',  '請輸入4或5碼正確工作月', function(v,elm) {
				if(!Validation.get('IsEmpty').test(v)){
					if((v.length==5 || v.length==4)){
						return true;
					}	
					return false;
				}else{
					return false;
				}
			}],
			
			[ 'checkLOAN_KIND',  '請輸入業績貸款種類！！', function(v,elm) {
				if(!Validation.get('IsEmpty').test(v)){
					if(v.length!=2){
						return false;
					}
					return true;
				}else{
					return false;
				}
			}],
			
			[ 'checkALWC',  '業績比例須在0-100之間!',
				function(v){				
					if(isNaN(v)||parseInt(v)>100){
						return false;
					}else{
						return true;
					}
					
				}
			]

		]);
	
	     valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
		 valid1.define("required", { id: "CHG_KIND" ,errMsg:"請選擇變更種類!"} );
		 
		 valid2 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
		 valid2.define("check1", { id: "LOAN_ID" } );
		 valid2.define("checkLOAN_ID", { id: "LOAN_ID" } );
		 valid2.define("checkAPPLY_ID", { id: "APPLY_ID" } );
		 
		 valid3 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
		 valid3.define("required", { id: "LOAN_ID" , errMsg:"業績變更需輸入貸款帳號!" } );
		 valid3.define("checkLOAN_ID", { id: "LOAN_ID" } );
		 
		 valid4 = new Validation("form2", { focusOnError:true, immediate:false , mode : 'validator'});
		 valid4.define("checkROCID" , { id: "AGENT_ID" , errMsg:"請輸入第一經手人ID"} );
		 valid4.define("checkDEPT" , { id: "BELONG_DEPT" , errMsg:"請輸入業績歸屬單位,共5碼!!"} );
		 valid4.define("required" , { id: "ALWC_RATE" , errMsg:"請輸入業績比例"} );
		 valid4.define("checkALWC" , { id: "ALWC_RATE"} );
		
		 valid5 = new Validation("form2", { focusOnError:true, immediate:false , mode : 'validator'});
		 valid5.define("checkROCID" , { id: "AGENT1_ID" , errMsg:"請輸入第二經手人ID" });
		 valid5.define("checkDEPT" , { id: "BELONG_DEPT" , errMsg:"請輸入業績歸屬單位,共5碼!!"} );
		 
		 valid6 = new Validation("form2", { focusOnError:true, immediate:false , mode : 'validator'});
		 
		 valid6.define("required", { id: "TREAT_AMT" , errMsg:"請輸入業績金額"} );
		 valid6.define("validate-integer", { id: "TREAT_AMT" , errMsg:"請輸入正確業績金額"} );
		 valid6.define("required", { id: "A_VALUE" , errMsg:"請輸入A值"} );
		 valid6.define("validate-integer", { id: "A_VALUE" , errMsg:"請輸入A值!(請輸入整數，勿輸入小數點)!" } );
		 valid6.define("checkWorkMonth", { id: "WORKYM" } );
		 valid6.define("checkLOAN_KIND", { id: "C_LOAN_KIND" } );
		 
		 valid7 = new Validation("form2", { focusOnError:true, immediate:false , mode : 'validator'});
		 valid7.define("checkROCID", { id: "AGENT_ID_C430" , errMsg:"請輸入經手人ID"} );
		 valid7.define("checkDEPT", { id: "AGENT_DEPT" , errMsg:"請輸入業績歸屬單位,共5碼!!" } );
		 valid7.define("required", { id: "FEAT_AMT" , errMsg:"請輸入業績金額"});
		 valid7.define("validate-integer", { id: "FEAT_AMT" ,errMsg:"請輸入業績金額!(請輸入整數,勿輸入小數點)" });
		 
	}
	function resetValidation(){
		valid1.reset();
		valid2.reset();
		valid3.reset();
		valid4.reset();
		valid5.reset();
		valid6.reset();
		valid7.reset();
		
	}
	
	
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_2100/" + actionName,
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
	}//END   共用AJAX
	
	var columnObj = {
		a : [				
				{header: "貸款帳號",key: "ID", attrs:{rowSpan:2}	},						
				{header: "借款人姓名",key: "BORROW_NAME_C", attrs:{rowSpan:2}},						
				{header: "變更前業績金額",key: "TREAT_AMT1", attrs:{align:'right'}, render:function(rec,val){
					return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0;
				}},						
				{header: "變更前A值",key: "A_VALUE1"},												
				{header: "變更前工作月",key: "WORKYM1"},
				{header: "變更前貸款種類",key: "C_LOAN_KIND1"},											
				{header: "輸入人員",key: "INPUT_ID"},
				{header: "備註",key: "MEMO",attrs:{rowSpan:2}},
				{header: "覆核人員",key: "CONFIRM_ID"},
				{header: "變更後業績金額",key: "TREAT_AMT2", attrs:{align:'right'}, render:function(rec,val){
					return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0;
				}},
				{header: "變更後A值",key: "A_VALUE2"},
				{header: "變更後工作月",key: "WORKYM2"},
				{header: "變更後貸款種類",key: "C_LOAN_KIND2"},	
				{header: "輸入日期",key: "INPUT_DATE",
					render : function(rec , val){
						return 	val ?  Date.toROC(val) : "";														
					}
				},
				{header: "覆核日期",key: "CONFIRM_DATE",
					render : function(rec , val){
						return 	val ?  Date.toROC(val) : "";
					}
				}],
		b: [					
				{header: "帳號",key: "ID", attrs:{rowSpan:2}},						
				{header: "借款人姓名",key: "BORROW_NAME_A", attrs:{rowSpan:2}},						
				{header: "變更前第一經手人",key: "AGENT_ID1"},
				{header: "變更前第二經手人",key: "AGENT1_ID1"},
				{header: "變更前業績比例",key: "ALWC_RATE1"},
				{header: "變更前業績歸屬單位",key: "AGENT_DEPT1"},												
				{header: "變更前業績金額",key: "TREAT_AMT1", attrs:{align:'right'}, render:function(rec,val){
					return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0;
				}},
				{header: "輸入人員",key: "INPUT_ID"},
				{header: "備註",key: "MEMO", attrs:{rowSpan:2}},
				{header: "覆核人員",key: "CONFIRM_ID"},
				{header: "變更後第一經手人",key: "AGENT_ID2"},												
				{header: "變更後第二經手人",key: "AGENT1_ID2"},
				{header: "變更後業績比例",key: "ALWC_RATE2"},
				{header: "變更後業績歸屬單位",key: "AGENT_DEPT2"},
				{header: "變更後業績金額",key: "TREAT_AMT2", attrs:{align:'right'}, render:function(rec,val){
					return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0;
				}},
				{header: "輸入日期",key: "INPUT_DATE",
					render : function(rec , val){
						return 	val ? Date.toROC(val) : "";														
					}
				},
				{header: "覆核日期",key: "CONFIRM_DATE",
					render : function(rec , val){
						return 	val ?  Date.toROC(val) : "";
					}
				}],
				
		c: [					
				{header: "貸款帳號",key: "ID", attrs:{rowSpan:2}},						
				{header: "借款人姓名",key: "BORROW_NAME_C", attrs:{rowSpan:2}},			
				{header: "變更前經手人",key: "AGENT_ID1"},
				{header: "變更前業績歸屬單位",key: "AGENT_DEPT1"},
				{header: "變更前業績金額",key: "FEAT_AMT1", attrs:{align:'right'}, render:function(rec,val){
					return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0;
				}},
				{header: "輸入人員",key: "INPUT_ID"},		
				{header: "備註",key: "MEMO", attrs:{rowSpan:2}},
				{header: "覆核人員",key: "CONFIRM_ID"},
				{header: "變更後經手人",key: "AGENT_ID2"},												
				{header: "變更後業績歸屬單位",key: "AGENT_DEPT2"},
				{header: "變更後業績金額",key: "FEAT_AMT2", attrs:{align:'right'}, render:function(rec,val){
					return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0;
				}},
				{header: "輸入日期",key: "INPUT_DATE",
					render : function(rec , val){
						return 	val ? Date.toROC(val) : "";														
					}
				},
				{header: "覆核日期",key: "CONFIRM_DATE",
					render : function(rec , val){
						return 	val ? Date.toROC(val) : "";
					}
				}],
		d: [
				{header: "貸款帳號",key: "ID", attrs:{rowSpan:2}},
				{header: "期數",key: "C440_PAY_TERM", attrs:{rowSpan:2}},
				{header: "序號",key: "C440_SEQ_NO", attrs:{rowSpan:2}},
				{header: "繳別",key: "PAY_KIND_NAME", attrs:{rowSpan:2}},
				{header: "修改前佣金金額",key: "ACHIEVE_AMT1"},
				{header: "輸入人員",key: "INPUT_ID"},		
				{header: "備註",key: "MEMO", attrs:{rowSpan:2}},
				{header: "覆核人員",key: "CONFIRM_ID"},
				{header: "修改後佣金金額",key: "ACHIEVE_AMT2"},
				{header: "輸入日期",key: "INPUT_DATE", sortRule: 'date'},
				{header: "覆核日期",key: "CONFIRM_DATE", sortRule: 'date'}]	
	};
	
	
	var buttons = {
	
		//查詢
		doQuery : function(event){
			resetValidation();
			//檢核
			if(!valid1.validate()){
				return;
			}
			
			var CHG_KIND = $F('CHG_KIND');
			
			resetValidation();
			if(CHG_KIND =='11'){//經手人變更(含比例)
				if(!valid2.validate()){
					return;
				}
			}else if(!valid3.validate()){//NOT經手人變更(含比例)
				return;
			}
			
			var reqMap = {
				LOAN_ID : $F('LOAN_ID'),
				APPLY_ID : $F('APPLY_ID'),
				CHG_KIND : $F('CHG_KIND')
			};
			
			ajaxPost('query' , { reqMap : Object.toJSON(reqMap) },
				function(resp){
				
					var rtnMap = resp.rtnMap || {};

					if(CHG_KIND =='10'){//業績核實資料變更

						$$('.trB input[type=text]', '.trC input[type=text]','.trD input[type=text]').each(
							function(ele){
							ele.value = '';
							ele.readOnly = true;
						});
						$$('.trD span').each(
								function(ele){
								ele.update('');
							});
						$$('.trA input[type=text]').each(
							function(ele){
							ele.readOnly = false;
							ele.value = rtnMap[ele.id] || '';
						});
						$('AGENT_NAME').update('');
						$('AGENT1_NAME').update('');
						
					}else if(CHG_KIND =='11'){//經手人變更(含比例)
	
						$$('.trA input[type=text]', '.trC input[type=text]').each(
							function(ele){
							ele.value = '';
							ele.readOnly = true;
						});
						$$('.trD span').each(
								function(ele){
								ele.update('');
							});
						$$('.trB input[type=text]').each(
							function(ele){
							ele.readOnly = false;
							ele.value = rtnMap[ele.id] || '';
						});
						$$('.trB span').each(
							function(ele){
							ele.update(rtnMap[ele.id] || '');
						});
					
					}else if(CHG_KIND =='12'){//業績速報資料變更
	
						$$('.trA input[type=text]', '.trB input[type=text]').each(
							function(ele){
							ele.value = '';
							ele.readOnly = true;
						});
						$$('.trD span').each(
								function(ele){
								ele.update('');
							});
						$$('.trC input[type=text]').each(
							function(ele){
							ele.readOnly = false;
							ele.value = rtnMap[ele.id] || '';
						});
						$('AGENT_NAME').update('');
						$('AGENT1_NAME').update('');
					}else if(CHG_KIND =='13'){//對保業績變更
						
						$$('.trA input[type=text]', '.trB input[type=text]').each(
							function(ele){
							ele.value = '';
							ele.readOnly = true;
						});
						var MSG = rtnMap.MSG || '';
						//無對保業績，顯示訊息不顯示清單
						if(MSG){
							$('D_MSG').update(MSG);
							gridD.hide();
						}else{
							gridD.show();
							$('D_MSG').update('');
							var list = rtnMap['list'] || [];
							gridD.load(list);
						}
						
						
					}
					$('grid').hide();
					PageUI.resize();	
					if(grid){
						grid.load([]);
					}
					queryRecord = reqMap;
					queryRecord.C_LOAN_KIND = rtnMap.C_LOAN_KIND;
				
				},function(resp){
					
					$('form2').reset();					
					$('AGENT_NAME').update('');
					$('AGENT1_NAME').update('');
					$('grid').hide();
					PageUI.resize();	
					if(grid){
						grid.load([]);
					}
				}
			);
			
		},
		
		//變更
		doUpdate : function(event){
			resetValidation();
			//檢核
			if(!queryRecord){
				alert("請先查詢！");
				return;
			}else if(!valid1.validate()){
				return;
			}
			
			resetValidation();
			var CHG_KIND = $F('CHG_KIND');
			if(CHG_KIND =='11'){
				if(!valid2.validate() || !valid4.validate()){
					return;
				}
				var ALWC_RATE = $F('ALWC_RATE');
				if(ALWC_RATE<0 || ALWC_RATE>100){
					alert("業績比例需為 0-100之間的數字，請重新輸入");
					return;
				}
				resetValidation();
				if(ALWC_RATE<100 && !valid5.validate()){
				 	return;
				}
			}else if(CHG_KIND =='13'){
				if(gridD.validCheckedOnTable()){
					alert('輸入資料有誤！修改後佣金金額僅能輸半形正整數');
					return;
				}
				var list = gridD.getCheckedRecord();
				if(list.length == 0){
					alert('請勾選要修改的資料！');
					return;
				}
				for(var i = 0 ; i < list.length; i++){
					var map = list[i];
					if(parseInt(map.ACHIEVE_AMT2,10) == 0){
						if(!confirm('佣金修改為零將會刪除該筆業績資料，請確認是否要繼續變更')){
							return;
						}
					}
				}
				
			}else {
				if(!valid3.validate()){
					return;
				}
				resetValidation();
				if(CHG_KIND =='10'){
					if(!valid6.validate()){
						return;
					}
					var C_LOAN_KIND_OLD = queryRecord.C_LOAN_KIND|| '';				
					if(C_LOAN_KIND_OLD != $F('C_LOAN_KIND') && !confirm("確定將業績種類由"+C_LOAN_KIND_OLD+ "變更為" + $F('C_LOAN_KIND'))){
						return;
					}
				}else if(CHG_KIND =='12' && !valid7.validate()){
					return;
				}
			}
			
			var reqMap = {
				LOAN_ID : $F('LOAN_ID'),
				APPLY_ID : $F('APPLY_ID'),
				CHG_KIND : $F('CHG_KIND')
			};
			
			if(CHG_KIND =='10'){
				reqMap["TREAT_AMT"]= $F('TREAT_AMT');
				reqMap["C_LOAN_KIND"]= $F('C_LOAN_KIND');
				reqMap["WORKYM"]= $F('WORKYM');
				reqMap["A_VALUE"]= $F('A_VALUE');
				reqMap["MEMO"]= $F('A_MEMO');
			}else if(CHG_KIND =='11'){
				
				<%-- 
					[20230321] 第一經手人姓名 & 第二經手人姓名 若含有難字, 則會導致 AntiXSSRequestData$InputXSSError輸入值格式有安全性的錯誤
					移除 第一經手人姓名 & 第二經手人姓名   
				--%>
				reqMap["AGENT_ID"]= $F('AGENT_ID');
				// reqMap["AGENT_NAME"]= $('AGENT_NAME').innerHTML;
				reqMap["BELONG_DEPT"]= $F('BELONG_DEPT');
				reqMap["AGENT1_ID"]= $F('AGENT1_ID');
				// reqMap["AGENT1_NAME"]= $('AGENT1_NAME').innerHTML;
				reqMap["ALWC_RATE"]= $F('ALWC_RATE');
				reqMap["MEMO"]= $F('B_MEMO');
			}else if(CHG_KIND =='13'){
				reqMap["MEMO"]= $F('D_MEMO');
				reqMap["CHECKED_LIST"] = gridD.getCheckedRecord();
			}else{
				reqMap["AGENT_ID_C430"]= $F('AGENT_ID_C430');
				reqMap["AGENT_DEPT"]= $F('AGENT_DEPT');
				reqMap["FEAT_AMT"]= $F('FEAT_AMT');
				reqMap["MEMO"]= $F('C_MEMO');
			}
			
			ajaxPost('update' , { reqMap : Object.toJSON(reqMap) },
					function(resp){
				if(CHG_KIND =='13'){
					gridD.load([]); //變更成功直接將清單清空，若要再改需重查
				}
			});
		
		},
		
		//變更記錄查詢
		doUpdateQuery : function(event){
		
			resetValidation();
			//檢核
			if(!valid1.validate()){
				return;
			}
			
			var CHG_KIND = $F('CHG_KIND');		
			//resetValidation();
			/*if(CHG_KIND =='11'  ){//經手人變更(含比例)
				if(!valid2.validate()){
					return;
				}				
			}else{//NOT經手人變更(含比例)
				if(!valid3.validate()){
					return;
				}				
			}
			*/
			var reqMap = {
				LOAN_ID : $F('LOAN_ID'),
				APPLY_ID : $F('APPLY_ID'),
				CHG_KIND : CHG_KIND,
				BEGIN_DATE : $F('BEGIN_DATE'),
				END_DATE : $F('END_DATE')
			};
						
			ajaxPost('updateQuery' , { reqMap : Object.toJSON(reqMap) },
				function(resp){
					if(CHG_KIND =='10'){
						grid = new TableUI({
							table: $('grid'),
							title:"業績核實變更紀錄",
							split: ['TREAT_AMT2'],
							column:columnObj.a});
					}else if(CHG_KIND =='11'){
						grid = new TableUI ( {
							table: $('grid'), 
							title:"經手人變更(含比例)變更紀錄",
							split: ['AGENT_ID2'],
							column:columnObj.b});
					}else if(CHG_KIND =='13'){
						grid = new TableUI ( {
							table: $('grid'), 
							title:"對保不分潤變更紀錄",
							split: ['ACHIEVE_AMT2'],
							<%-- [20230321] --%>
							afterLoad: function() {
								if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
							},
							pageChange: function() {
								if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
							},
							column:columnObj.d});
					}else{
						grid = new TableUI ( {
							table: $('grid'), 
							title:"業績速報資料變更紀錄",
							split: ['AGENT_ID2'],
							column:columnObj.c});
					}
					grid.load(resp.rtnMapList || []);
				},function(resp){
					$('form2').reset();
					$('AGENT_NAME').update('');
					$('AGENT1_NAME').update('');
					$('grid').hide();
					PageUI.resize();	
					if(grid){
						grid.load([]);
					}
				}
			);
		},
		
		//待覆核查詢
		doConfirmQuery : function(event){
		
			//檢核
			resetValidation();
			if(!valid1.validate()){
				return;
			}
			
			var CHG_KIND = $F('CHG_KIND');
			/*resetValidation();
			if(CHG_KIND =='11'){//經手人變更(含比例)
				if(!valid2.validate()){
					return;
				}
			}else {//NOT經手人變更(含比例)
				if(!valid3.validate()){
					return;
				}	
			}*/
			
			var reqMap = {
				LOAN_ID : $F('LOAN_ID'),
				APPLY_ID : $F('APPLY_ID'),
				CHG_KIND : CHG_KIND,
				BEGIN_DATE : $F('BEGIN_DATE'),
				END_DATE : $F('END_DATE'),
				TYPE : 'W'
			};
						
			ajaxPost('confirmQuery' , { reqMap : Object.toJSON(reqMap) },
				function(resp){
					if(CHG_KIND =='10'){
						grid = new TableUI({
							table: $("grid"),
							title:"待覆核--業績核實變更紀錄",
							autoCheckBox:{isSelectAll:false },
							split: ['TREAT_AMT2'],
							column:columnObj.a});
					}else if(CHG_KIND =='11'){
						grid = new TableUI ( {
							table: $("grid"), 
							title:"待覆核--經手人變更(含比例)變更紀錄",
							autoCheckBox:{isSelectAll:false },
							split: ['AGENT_ID2'],
							column:columnObj.b});
					}else if(CHG_KIND =='13'){
						grid = new TableUI ( {
							table: $('grid'), 
							title:"待覆核--對保不分潤變更紀錄",
							autoCheckBox:{isSelectAll:false },
							split: ['ACHIEVE_AMT2'],
							column:columnObj.d});
					}else{
						grid = new TableUI ( {
							table: $("grid"), 
							title:"待覆核--業績速報資料變更紀錄",
							autoCheckBox:{isSelectAll:false },
							split: ['AGENT_ID2'],
							column:columnObj.c});
					}
					grid.load(resp.rtnMapList ? resp.rtnMapList : []);
					confirmQueryRecord = true;
				},function(resp){
					$('form2').reset();
					$('AGENT_NAME').update('');
					$('AGENT1_NAME').update('');							
					$('grid').hide();
					PageUI.resize();	
					if(grid){
						grid.load([]);
					}
				}
			);
		},
		
		//覆核
		doConfirm : function(event){
			//檢核
			if(!confirmQueryRecord){
				alert("請先點選待覆核查詢!!");
				return;
			}
			var reqMapList = grid.getCheckedRecord();
			if( reqMapList.length == 0 ){
				alert("請選取待覆核紀錄");
				return;
			}
			
			ajaxPost('confirm' , { reqMapList : Object.toJSON(reqMapList) },
			function(resp){
				//alert(Object.toJSON(resp.rtnMapList));
				grid.load(resp.rtnMapList ? resp.rtnMapList : []);
				confirmQueryRecord = false;
			});
		},
		
		//刪除確認
		doDelete : function(event){
			//檢核
			if(!confirmQueryRecord){
				alert("請先點選待覆核查詢!!");
				return;
			}
			var reqMapList = grid.getCheckedRecord();
			if( reqMapList.length == 0 ){
				alert("請選取待覆核紀錄");
				return;
			}
			var CHG_KIND= $F('CHG_KIND');
			var reqMap = {
				LOAN_ID : $F('LOAN_ID'),
				APPLY_ID : $F('APPLY_ID'),
				CHG_KIND : CHG_KIND,
				BEGIN_DATE : $F('BEGIN_DATE'),
				END_DATE : $F('END_DATE'),
				TYPE : 'W'
			};
			ajaxPost('delete' , { reqMapList : Object.toJSON(reqMapList), reqMap : Object.toJSON(reqMap)},
			function(resp){
				if(CHG_KIND =='10'){
					grid = new TableUI({
						table: $("grid"),
						title:"待覆核--業績核實變更紀錄",
						autoCheckBox:{isSelectAll:false },
						split: ['TREAT_AMT2'],
						column:columnObj.a});
				}else if(CHG_KIND =='11'){
					grid = new TableUI ( {
						table: $("grid"), 
						title:"待覆核--經手人變更(含比例)變更紀錄",
						autoCheckBox:{isSelectAll:false },
						split: ['AGENT_ID2'],
						column:columnObj.b});
				}else if(CHG_KIND =='13'){
					grid = new TableUI ( {
						table: $('grid'), 
						title:"待覆核--對保不分潤變更紀錄",
						autoCheckBox:{isSelectAll:false },
						split: ['ACHIEVE_AMT2'],
						column:columnObj.d});
				}else{
					grid = new TableUI ( {
						table: $("grid"), 
						title:"待覆核--業績速報資料變更紀錄",
						autoCheckBox:{isSelectAll:false },
						split: ['AGENT_ID2'],
						column:columnObj.c});
				}
				grid.load(resp.rtnMapList ? resp.rtnMapList : []);
				confirmQueryRecord = true;
			});
		}
	};
	
	
	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC82100', '收息資料更新', '業績資料變更');
			
			initValidation();		
			
			
			$('BELONG_DEPT').observe('change', 
				function(event){					
					event.target.value = event.target.value.toUpperCase();
				}
			);
			$('AGENT_DEPT').observe('change', 
				function(event){					
					event.target.value = event.target.value.toUpperCase();
				}
			);
			gridD = new TableUI ( {
				table: $("gridD"), pageSize: 20, allSortable:false,
				autoCheckBox:{					
					isSelectAll:true
				},
				validateRecord:function( rec , sn ){ 
					var ACHIEVE_AMT2 = rec['ACHIEVE_AMT2'];
					if(ACHIEVE_AMT2 && (!Validation.get('validate-integer').test(ACHIEVE_AMT2) || ACHIEVE_AMT2 < 0)){
						return false; 
					}
					return true;
				},
				column: [
						{header: "貸款帳號",key: "LOAN_ID"},
						{header: "期數",key: "PAY_TERM"},
						{header: "序號",key: "SEQ_NO"},
						{header: "繳別",key: "PAY_KIND_NAME"},
						{header: "經手人ID",key: "AGENT_ID"},
						{header: "經手人姓名",key: "EMP_NAME"},
						{header: "業績比例",key: "ALWC_RATE"},
						{header: "修改前佣金金額",key: "ACHIEVE_AMT"},
						{header: "修改後佣金金額",key: "ACHIEVE_AMT2",
							input:{type:'NUMBER', size:15, maxlength:14}
						}	
					]		
			});
			
			$('CHG_KIND').observe('change',
				function(event){
					var CHG_KIND = $F('CHG_KIND');
					$('table_A').hide();
					$('table_B').hide();
					$('table_C').hide();
					$('table_D').hide();
					//$('table_E').hide();
					if(CHG_KIND =='10'){//業績核實資料變更
						$('table_A').show();
					}else if(CHG_KIND =='11'){//經手人變更(含比例)
						$('table_B').show();					
					}else if(CHG_KIND =='12'){//業績速報資料變更
						$('table_C').show();				
					}else if(CHG_KIND =='13'){//對保佣金不分潤變更
						$('table_D').show();
					}/*else if(CHG_KIND =='14'){//不當招攬業佣補發變更
						$('table_E').show();
					}*/
				}
			);			

			
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_update').observe('click', buttons.doUpdate);
			$('btn_updateQuery').observe('click', buttons.doUpdateQuery);
			$('btn_confirmQuery').observe('click', buttons.doConfirmQuery);
			$('btn_confirm').observe('click', buttons.doConfirm);
			$('btn_delete').observe('click', buttons.doDelete);
			
			$w('LOAN_ID APPLY_ID AGENT_ID AGENT1_ID AGENT_ID_C430').each(
				function(id){
					$(id).observe('blur', function(){
						this.value = this.value.toUpperCase();
					})
				});
			
			$('table_A').hide();
			$('table_B').hide();
			$('table_C').hide();
			$('table_D').hide();
			//$('table_E').hide();
			buttonAuth();
			PageUI.resize();			
			displayMessage();			
		}
	};

}



</script>
</head>
<body>


<form name="form1" id="from1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >
	
	<table id="table1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">貸款帳號</td>
			<td class="tbYellow2"  width="13%">
				<input id="LOAN_ID" type="text" class="textBox2" size='12' maxlength='10'  />
			</td>
			<td class="tbYellow" width="10%">受理編號</td>
			<td class="tbYellow2"  width="12%">
				<input id="APPLY_ID" type="text" class="textBox2" size='13' maxlength='11'  />
			</td>
			<td class="tbYellow" width="10%">變更種類</td>
			<td class="tbYellow2"  width="10%">
				
				<select id="CHG_KIND">
					<option value=''>請選擇</option>
			       	<c:forEach var="map" items="${CHG_KIND_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" width="35%" rowspan="2" align="center">
				<input id="btn_query" type="button" class="button" value="查詢"/>
				<input id="btn_update" type="button" class="button" value="變更"/>	
				<input id="btn_updateQuery" type="button" class="button" value="變更紀錄查詢"/>
				<BR>
				<input id="btn_confirmQuery" type="button" class="button" value="待覆核查詢"/>	
				<input id="btn_confirm" type="button" class="button" value="覆核"/>
				<input id="btn_delete" type="button" class="button" value="刪除確認"/>	
				</BR>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%">開始日期</td>
			<td class="tbYellow2"  width="13%">
				<input id="BEGIN_DATE" type="text" class="textBox2 validate-ROCDate" size='12' maxlength='10' datatype ='ROCDate' value='${SYS_DATE}' />
				<img src="/DSWeb/images/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('BEGIN_DATE'))">
			</td>
			<td class="tbYellow" width="10%">結束日期</td>
			<td class="tbYellow2"  width="12%" colspan="3">
				<input id="END_DATE" type="text" class="textBox2 validate-ROCDate" size='12' maxlength='10' datatype ='ROCDate' value='${SYS_DATE}' />
				<img src="/DSWeb/images/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('END_DATE'))">
			</td>
		</tr>
	</table>
</form>
<form name="form2" id="form2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id='table_A' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr class="trA">
			<td colspan="4" align="center" class="tbBox3">業績核實資料變更查詢結果</td>
		</tr>
		<tr class="trA">
			<td class="tbYellow" width="15%"  >業績核實金額</td>
			<td class="tbYellow2" width="18%" >
				<input id="TREAT_AMT" type="text" class="textBox2" size='12' maxlength='11' />
			</td>
			<td class="tbYellow" width="15%" >工作月</td>
			<td class="tbYellow2">
				<input id="WORKYM" type="text" class="textBox2" size='7' maxlength='5'  />
			</td>
		</tr>
		<tr class="trA">
			<td class="tbYellow" >業績貸款種類</td>
			<td class="tbYellow2"  >
				<input id="C_LOAN_KIND" type="text" class="textBox2" size='4' maxlength='2'  />
			</td>
			<td class="tbYellow">A值</td>
			<td class="tbYellow2" >
				<input id="A_VALUE" type="text" class="textBox2"  size='7' maxlength='5'/>
			</td>
		</tr>
		<tr class="trA">
			<td class="tbYellow" >備註</td>
			<td class="tbYellow2" colspan="3" >
				<input id="A_MEMO" type="text" class="textBox2"  size='60' maxlength='50'/>
			</td>
		</tr>
	</table>
	<table id='table_B' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr class="trB">
			<td colspan="6" align="center" class="tbBox3">經手人變更(含比例)查詢結果</td>
		</tr>
		<tr class="trB">
			<td class="tbYellow" width="15%" >第一經手人ID</td>
			<td class="tbYellow2" width="15%" >
				<input id="AGENT_ID" type="text" class="textBox2" size='12' maxlength='10'  />
			</td>
			<td class="tbYellow" width="15%">第一經手人姓名</td>
			<td class="tbYellow2" width="15%">
				<span id="AGENT_NAME" style="font-family: 'EUDC'"></span> <%-- [20230321] --%>
			</td>
			<td class="tbYellow" width="15%">業績歸屬單位</td>
			<td class="tbYellow2" width="15%">
				<input id="BELONG_DEPT" type="text" class="textBox2" size='7' maxlength='5'  />
			</td>
		</tr>
		<tr class="trB">
			<td class="tbYellow">第二經手人ID </td>
			<td class="tbYellow2">
				<input id="AGENT1_ID" type="text" class="textBox2" size='12' maxlength='10'  />
			</td>
			<td class="tbYellow" >第二經手人姓名</td>
			<td class="tbYellow2" >
				<span id="AGENT1_NAME" style="font-family: 'EUDC'"></span> <%-- [20230321] --%>
			</td>
			<td class="tbYellow" width="15%" >第一經手人業績比例</td>
			<td class="tbYellow2"  >
				<input id="ALWC_RATE" type="text" class="textBox2" size='5' maxlength='3'  />
			</td>
		</tr>
		<tr class="trB">
			<td class="tbYellow" >備註</td>
			<td class="tbYellow2"  colspan="5">
				<input id="B_MEMO" type="text" class="textBox2" size='60' maxlength='50' alt="ch" /> <%-- [20230321] --%>
			</td>
		</tr>
	</table>
	<table id='table_C' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr class="trC">
			<td colspan="6" align="center" class="tbBox3">業績速報資料變更查詢結果</td>
		</tr>
		<tr class="trC">
			<td class="tbYellow" width="15%" >經手人ID</td>
			<td class="tbYellow2" width="15%"  >
				<input id="AGENT_ID_C430" type="text" class="textBox2" size='12' maxlength='10'  />
			</td>
			<td class="tbYellow" width="15%">業績歸屬單位</td>
			<td class="tbYellow2"  width="15%">
				<input id="AGENT_DEPT" type="text" class="textBox2" size='7' maxlength='5'  />
			</td>
			<td class="tbYellow" width="15%">業績金額</td>
			<td class="tbYellow2"  width="15%">
				<input id="FEAT_AMT" type="text" class="textBox2" size='12' maxlength='11' />
			</td>
		</tr>
		<tr class="trC">
			<td class="tbYellow" >備註</td>
			<td class="tbYellow2" colspan="5">
				<input id="C_MEMO" type="text" class="textBox2"  size='60' maxlength='50'  />
			</td>
		</tr>
	</table>
	<table id='table_D' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr class="trD">
			<td colspan="6" align="center" class="tbBox3">對保佣金不分潤變更查詢結果</td>
		</tr>
		<tr class="trD">
			<td colspan="6" align="center" class="tbYellow">
				<font color="red"><span id='D_MSG'></span></font>
				<table id='gridD' width="100%" class="grid"></table>
			</td>
		</tr>
		<tr class="trD">
			<td class="tbYellow" >備註</td>
			<td class="tbYellow2"  colspan="5">
				<input id="D_MEMO" type="text" class="textBox2" size='60' maxlength='50'  />
			</td>
		</tr>
	</table>
<%--<div id = 'table_E'>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr class="trE">
				<td colspan="6" align="center" class="tbBox3">不當招攬業佣補發變更查詢結果</td>
			</tr>		
			<tr class="trE">
				<td class="tbYellow" >備註</td>
				<td class="tbYellow2"  colspan="5">
					<input id="E_MEMO" type="text" class="textBox2" size='60' maxlength='50'  />
				</td>
			</tr>
		</table>
		<table id='gridE_1' width="100%" class="grid"></table>
		<table id='gridE_2' width="100%" class="grid"></table>
	</div> --%>	
</form>
<table id='grid' width="100%" class="grid"></table>
</body>
</html>