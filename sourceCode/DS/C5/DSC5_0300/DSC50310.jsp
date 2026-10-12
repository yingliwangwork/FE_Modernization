<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSC5_0310.java
作者：陳思涵 
功能：個別優惠利率明細
完成：2013-08-27
2018-06-08申請書-部分簡訊及Email通知調整：因利率個調已無再透過畫面勾選寄送利率調整通知，另有個調附約寄送功能，故停掉該mail，畫面也需拿掉該選項

[2022-09-19] 利率限制卡控優化
1. 個別優惠利率明細新增時，若低於利率下限則跳出提醒
2. 輸入時檢核員工貸款件的個別優惠加減碼限制，並提醒使用者

[20241104] 修改件 難字調整 吳志鴻
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script><!-- 必要 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script><!-- 必要 -->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script><!-- 檢核訊息的顯示 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script><!-- 目前系統常用的表格工具 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script><!-- 目前畫面的版面設定 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>

<%-- [20241104] 難字調整 --%>
<style type="text/css">
	@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
	}
</style>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSC50310().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC50310(){
	var valid1;
	var queryMap;
	
	var isEmpCase=""; //是否為員工貸款案件
	//var isTriggerLimit;//是否觸發利率限制

	function  initValidation(){
			Validation.addAllThese([
				[ 'check_loan_id',  '',
					function(v,elm) {
						if(Validation.get('IsEmpty').test(v) || v.length != 10){
							return false;
						}
						return true;
					}
				],
				[ 'check_SPEC_ADJUST',  '',
					function(v,elm) {
						var SPEC_ADJUST = $F('SPEC_ADJUST');
						if(Validation.get('IsEmpty').test(SPEC_ADJUST) || SPEC_ADJUST>100 || SPEC_ADJUST<-100 ){
							return false;
						}
						return true;
					}
				],
				[ 'check_query',  '',
					function(v,elm) {
						var QUERY_LOAN_ID = $F('QUERY_LOAN_ID');
						if(QUERY_LOAN_ID != v){
							return false;
						}
						return true;
					}
				]
			]);
			
		 	valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
			
	}
	
	function getValid(no){
		valid1.clear();
		if(no=="1"){
			valid1.define("check_loan_id", { id: "LOAN_ID" , errMsg:"請輸入正確的貸款帳號!"} );
		}else if(no=="2"){
			valid1.define("check_loan_id", { id: "QUERY_LOAN_ID", errMsg:"請先進行查詢再做新增!"} );
			valid1.define("check_loan_id", { id: "LOAN_ID" , errMsg:"請輸入正確的貸款帳號!"} );
			valid1.define("check_query", { id: "LOAN_ID" , errMsg:"貸款帳號與查詢時不同，請重新查詢!"} );
			valid1.define("required", { id: "BEGIN_DATE" ,errMsg:"請輸入正確生效日期!"} );
			valid1.define("validate-ROCDate", { id: "BEGIN_DATE" ,errMsg:"請輸入正確生效日期!"} );
			valid1.define("required", { id: "PREFER_TERM" ,errMsg:"請輸入優惠期數!"} );
			valid1.define("check_SPEC_ADJUST", { id: "SPEC_ADJUST" ,errMsg:"請輸入正確加減碼!"} );
			valid1.define("validate-email", { id: "EMAIL" } );
		}else if(no=="3"){
			valid1.define("check_loan_id", { id: "QUERY_LOAN_ID", errMsg:"請先進行查詢再做新增!"} );
			valid1.define("check_loan_id", { id: "LOAN_ID" , errMsg:"請輸入正確的貸款帳號!"} );
			valid1.define("check_query", { id: "LOAN_ID" , errMsg:"貸款帳號與查詢時不同，請重新查詢!"} );
			valid1.define("required", { id: "BEGIN_DATE" ,errMsg:"請輸入正確生效日期!"} );
			valid1.define("validate-ROCDate", { id: "BEGIN_DATE" ,errMsg:"請輸入正確生效日期!"} );
		}
	}


	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0003:"btn_update",<%--新增--%>
			B0005:"btn_delete",<%--刪除--%>
			B0070:"btn_confirm",<%--覆核--%>
			B0072:"btn_calculate"<%--試算--%>
		};
		
		<dz:grantButtons FUNC_ID="DSC50310" ignored="false"/>
	}	

	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC5_0310/" + actionName,
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

	function showdata(rtnMap){
		$$('#table1 span').each(
			function(ele){
				var id = ele.id;
				if(id == 'END_DATE' || id == 'INFORM_DATE' || id == 'INPUT_DATE'){
					ele.update(Date.toROC(rtnMap[id])|| '');
				}else if(id == 'RATE' || id == 'FINAL_RATE'){
					ele.update(gridFmtRender(rtnMap[id]));
				}else{
					ele.update(rtnMap[id] || '');
				}
		});
		
		$$('#table1 input[type=text]').each(
			function(ele){
				var id = ele.id;
				if(id == 'BEGIN_DATE'){
					ele.value = toROC(rtnMap[id]) || '';
				}else if(id == 'SPEC_ADJUST' || id == 'FIX_RATE'){
					ele.value = gridFmtRender(rtnMap[id]);
				}else {
					ele.value = rtnMap[id] || '';
				}
		});
		
		$$('#table1 input[type=hidden]').each(
			function(ele){ 
				var id = ele.id;
				if(id == 'QUERY_LOAN_ID'){
					ele.value = rtnMap['LOAN_ID'] || '';
				}else if(id != 'CHECK_DELETE'){
					ele.value = rtnMap[id] || '';
				}
		});

		$w('INSU_PREFER').each(
			function(id) {	
				if(rtnMap[id] == '1'){
					$(id).checked = true;
					$(id).value = '1';
				} else {
					$(id).checked = false;
					$(id).value = '0';
				}
			}
		);
		
		$('ADJUST_REASON').value = rtnMap['ADJUST_REASON'];
		$('IS_AUTO').value = rtnMap['IS_AUTO'];
	}
	
	
	var buttons = {
		//查詢
		doQuery : function(event){
			valid1.reset();
			getValid("1");			
			//檢核
			if(!valid1.validate()){
				return;
			}
			
			var reqMap = {
				LOAN_ID : $F('LOAN_ID'),
				BEGIN_DATE : $F('BEGIN_DATE'),
				FRATE_TERM : $F('FRATE_TERM')
			};
					
			ajaxPost('query' , { dataMap : Object.toJSON(reqMap) },
				function(resp){
					showdata( resp.rtnMap || {});	
					queryMap = reqMap;
					
					$$('#table2 span').each(
						function(ele){
							var id = ele.id;
							ele.update('');
					});
					
					if (resp.rtnMap.RATE_990801 == "1") {
						$('rate990801').style.display = "";
					} else {
						$('rate990801').style.display = "none";
					}
					
					
					
					$('IS_EXTRACT').value = resp.rtnMap.IS_EXTRACT;
					
					$('form2').style.display="none";
					
					isEmpCase = resp.isEmpCase;
				},
				function(resp){
					queryMap = {};
					$$('#table1 input[type!="button"]').each(
						function(ele){
							var id = ele.id;
							if (id != 'LOAN_ID') {
								ele.value = '';
							}
					});
					$$('#table1 span').each(
						function(ele){
							var id = ele.id;
							ele.update('');
					});
					$$('#table2 span').each(
						function(ele){
							var id = ele.id;
							ele.update('');
					});
					$('form2').style.display="none";
					$('INPUT_NAME').update('${INPUT_NAME}');
					$('BEGIN_DATE').value = toROC('${INPUT_DATE}');
					$('INPUT_DATE').update(Date.toROC('${INPUT_DATE}'));
					
					isEmpCase = "";
				}	
			);
		},
		
		//新增
		doUpdate : function(event){
			valid1.reset();
			getValid("2");		
			
			if(!queryMap){
				alert('請先進行查詢再做新增!');
				return;
			}
			
			//檢核
			if(!valid1.validate()){
				return;
			}
			
			if($('EXPENSE_AMT').value < 0){
				alert('注意!手續費用低於0!');
				return;
			}
			
			if($F('ADJUST_REASON')==5 && $F('SPEC_ADJUST')<0){
				alert('特殊加碼個別加減碼需為正值!');
				return;
			}else if($F('ADJUST_REASON')==6 && $F('SPEC_ADJUST')>=0){
				alert('特殊減碼個別加減碼需為負值!');
				return;
			}
			
			if($('FINAL_RATE').innerHTML=='0.000' || $('FINAL_RATE').innerHTML==''){  //==null OR ==0?
				if(!confirm('注意!查無近兩個月的防止清償通報資料!')){
					return;
				}
			}
			if($F('FIX_RATE')<2.5){
				if(!confirm('注意!調降後固定利率低於2.25%!')){
				return;
				}
			}
			
			
			//20160428 資產管理一科調整訊息內容  且  不檢核手續費用,一律跳出訊息
			//if ($F('EXPENSE_AMT') > 0 && $F('IS_EXTRACT') == 'Y') {
			if ($F('IS_EXTRACT') == 'Y') {
				//alert('本次期款已抽件，轉帳扣款中，若輸入費用，可能造成扣款成功卻無法入帳，僅能掛電腦暫收，實際上等於未繳，易造成糾紛及後續帳務處理之困難。除要立即開單繳費者外，請於轉帳扣款作業完畢後(確定轉帳成功或不成功後)，再行輸入費用')
				//if(!confirm('本次期款已抽件，轉帳扣款中，若輸入費用，可能造成扣款成功卻無法入帳，僅能掛電腦暫收，實際上等於未繳，易造成糾紛及後續帳務處理之困難。除要立即開單繳費者外，請於轉帳扣款作業完畢後(確定轉帳成功或不成功後)，再行輸入費用\n是否確定輸入費用？')) {
				if(!confirm('本次期款已抽件，轉帳扣款中，若變更輸入，可能造成扣款成功卻無法入帳，另易造成糾紛及後續帳務處理之困難。請確認是否輸入？')) {
					return ;
				}
			}
		
		    //[2022-09-19] 輸入時檢核員工貸款件的個別優惠加減碼限制(收息模組限制不得額外減碼)
		    if(isEmpCase=="Y" && $F('SPEC_ADJUST')<0){//員工件、利率小於0
		    	//if (confirm("員工貸款件不可額外輸入個別優惠減碼，若是特殊原因請點選「確認」繼續作業")==false){
		    		//return;
		    	//}
		    	if(!confirm("1.此為員工件貸款件，請確認利率試算是否正確。\n2.員工件原則上不可額外輸入個別優惠減碼，若是特殊需求請至利率計算>取消利率限制畫面(畫面編號DSC50800)，並依期數解除利率限制\n3.若已輸入完成，請忽略以上訊息")) {
		    		return ;
		    	}
		    }	
			
			var insuPrefer;
			
			if($('INSU_PREFER').checked){
				insuPrefer = '1';
			}else{
				insuPrefer = '0';
			}
			$('INFORM_SEND').value = '0';			
			var dataMap = {
				LOAN_ID	: $F('LOAN_ID'),
				BEGIN_DATE	: $F('BEGIN_DATE'),
				PREFER_TERM	: $F('PREFER_TERM'),
				END_DATE	: $('END_DATE').value,
				FRATE_TERM	: $F('FRATE_TERM'),
				FIX_RATE	: $F('FIX_RATE'),
				SPEC_ADJUST	: $F('SPEC_ADJUST'),
				ADJUST_REASON	: $F('ADJUST_REASON'),
				INSU_PREFER		: insuPrefer,
				IS_AUTO		: $F('IS_AUTO'),
				LOAN_KIND	: $F('LOAN_KIND'),
				PREFER_TYPE	: $F('PREFER_TYPE'),
				AREA_CODE	: $F('AREA_CODE'),
				INFORM_SEND	: $F('INFORM_SEND'),
				EMAIL	: $F('EMAIL'),
				EXPENSE_AMT : $F('EXPENSE_AMT')
			};
			
			ajaxPost('update' , { dataMap : Object.toJSON(dataMap), LOAN_ID : $F('LOAN_ID')},
				function(resp){
					showdata(resp.rtnMap || {});				
					
					//$('form2').style.display="none";
					
					$('form2').style.display="block";	
					
					var rtnMap = resp.C100Map || {}; 
					$$('#table2 span').each(
						function(ele){
							var id = ele.id;
							ele.update(rtnMap[id] || '');
					});
					
					var grid = new TableUI({
							table: $('grid'),
							column: [
									{header: "日期",key: "INT_STR_DATE",
										render : function(rec, val){
											return Date.toROC(val) || '';
									}},	
									{header: "期數",key: "RATE_TERM"},	
									{header: "是否在優惠期間",key: "IS_PREF_PERIOD_NM"},	
									{header: "計息利率",key: "RATE_VAL"},	
									{header: "指標",key: "IR_RT_IDX_NM",
										render : function(rec, val){
											return val+"("+rec['IR_RT_IDX']+")";
									}},	
									{header: "商品利率",key: "PROD_RATE"},	
									{header: "個別優惠",key: "PREF_VALUE1"},	
									{header: "保戶優惠",key: "PREF_VALUE2"},		
									{header: "利率限制",key: "LIMIT_MSG"},	
									{header: "有巢氏優惠",key: "PREF_VALUE3"},		
									{header: "災戶優惠",key: "PREF_VALUE4"},	
									{header: "專案加碼",key: "PREF_VALUE5"}
								]
							});
					grid.load(resp.rateList || []);

					
				   //[2022-09-19] 個別優惠利率明細新增時，若低於利率下限則跳出提醒
				   if(resp.isTriggerLimit=="Y"){
					  alert("此貸款帳號"+rtnMap['LOAN_ID']+"新增優惠後，已有部分期數利率低於利率限制，若希望達到預期的利率，請至利率計算>取消利率限制畫面(畫面編號DSC50800)，並依期數解除利率限制");
				   }
				   
				}
			);
		
			   
		},
		
		//覆核
		doConfirm : function(event){
			valid1.reset();
			getValid("3");				
			
			if(!queryMap){
				alert('請先進行查詢再進行覆核!');
				return;
			}
			
		    //[2022-09-19] 輸入時檢核員工貸款件的個別優惠加減碼限制(收息模組限制不得額外減碼)
		    if(isEmpCase=="Y" && $F('SPEC_ADJUST')<0){//員工件、利率小於0
		    	//if (confirm("員工貸款件不可額外輸入個別優惠減碼，若是特殊原因請點選「確認」繼續作業")==false){
		    		//return;
		    	//}
		    	if(!confirm("1.此為員工件貸款件，請確認利率試算是否正確。\n2.員工件原則上不可額外輸入個別優惠減碼，若是特殊需求請至利率計算>取消利率限制畫面(畫面編號DSC50800)，並依期數解除利率限制\n3.若已輸入完成，請忽略以上訊息")) {
		    		return ;
		    	}
		    }
			
			//檢核
			/*
			if(!valid1.validate()){
				return;
			}
			
			if($F('ADJUST_REASON')==5 && $F('SPEC_ADJUST')<0){
				alert('特殊加碼個別加減碼需為正值!');
				return;
			}else if($F('ADJUST_REASON')==6 && $F('SPEC_ADJUST')>=0){
				alert('特殊減碼個別加減碼需為負值!');
				return;
			}
			
			if($('FINAL_RATE').innerHTML=='0.000'){  //==null OR ==0?
				if(!confirm('注意!查無近兩個月的防止清償通報資料!')){
					return;
				}
			}
			if($F('FIX_RATE')<2.5){
				if(!confirm('注意!調降後固定利率低於2.25%!')){
				return;
				}
			}*/
			var insuPrefer;
			
			if($('INSU_PREFER').checked){
				insuPrefer = '1';
			}else{
				insuPrefer = '0';
			}
			$('INFORM_SEND').value = '0';
			
			var dataMap = {
				LOAN_ID	: $F('LOAN_ID'),
				BEGIN_DATE	: $F('BEGIN_DATE'),
				PREFER_TERM	: $F('PREFER_TERM'),
				END_DATE	: $('END_DATE').value,
				FRATE_TERM	: $F('FRATE_TERM'),
				FIX_RATE	: $F('FIX_RATE'),
				SPEC_ADJUST	: $F('SPEC_ADJUST'),
				ADJUST_REASON	: $F('ADJUST_REASON'),
				INSU_PREFER		: insuPrefer,
				IS_AUTO		: $F('IS_AUTO'),
				LOAN_KIND	: $F('LOAN_KIND'),
				PREFER_TYPE	: $F('PREFER_TYPE'),
				AREA_CODE	: $F('AREA_CODE'),
				INFORM_SEND	: $F('INFORM_SEND')
				//EMAIL	: $F('EMAIL')
			};
			
			ajaxPost('confirm' , { dataMap : Object.toJSON(dataMap), LOAN_ID : $F('LOAN_ID')},
				function(resp){
					showdata(resp.rtnMap || {});	
					
					$('form2').style.display="block";	
					
					var rtnMap = resp.C100Map || {}; 
					$$('#table2 span').each(
						function(ele){
							var id = ele.id;
							ele.update(rtnMap[id] || '');
					});
					
					var grid = new TableUI({
							table: $('grid'),
							column: [
									{header: "日期",key: "INT_STR_DATE",
										render : function(rec, val){
											return Date.toROC(val) || '';
									}},	
									{header: "期數",key: "RATE_TERM"},	
									{header: "是否在優惠期間",key: "IS_PREF_PERIOD_NM"},	
									{header: "計息利率",key: "RATE_VAL"},	
									{header: "指標",key: "IR_RT_IDX_NM",
										render : function(rec, val){
											return val+"("+rec['IR_RT_IDX']+")";
									}},	
									{header: "商品利率",key: "PROD_RATE"},	
									{header: "個別優惠",key: "PREF_VALUE1"},	
									{header: "保戶優惠",key: "PREF_VALUE2"},		
									{header: "利率限制",key: "LIMIT_MSG"},	
									{header: "有巢氏優惠",key: "PREF_VALUE3"},		
									{header: "災戶優惠",key: "PREF_VALUE4"},	
									{header: "專案加碼",key: "PREF_VALUE5"}
								]
							});
					grid.load(resp.rateList || []);
					
				});
		},
		
		//刪除
		doDelete : function(event){
			valid1.reset();
			getValid("3");		
			
			//檢核
			if(!valid1.validate()){
				return;
			}
			
			if($F('OP_STATUS')=='20'){  //
				if(!confirm('注意!此件為已審件,是否確認要刪除!')){
					return;
				}
			}
			
			var dataMap = {
				LOAN_ID	: $F('LOAN_ID'),
				BEGIN_DATE	: $F('BEGIN_DATE'),
				CHECK_DELETE	: $F('CHECK_DELETE'),
				OP_STATUS	: $F('OP_STATUS')
			};
			
			ajaxPost('delete' , { dataMap : Object.toJSON(dataMap) },
				function(resp){
				
					$$('#table1 input[type!="button"]').each(
						function(ele){
							var id = ele.id;
							if (id != 'LOAN_ID') {
								ele.value = '';
							}
					});
					$$('#table1 span').each(
						function(ele){
							var id = ele.id;
							ele.update('');
					});
					$$('#table2 span').each(
						function(ele){
							var id = ele.id;
							ele.update('');
					});
					$('form2').style.display="none";
					$('INPUT_NAME').update('${INPUT_NAME}');
					$('BEGIN_DATE').value = toROC('${INPUT_DATE}');
					$('INPUT_DATE').update(Date.toROC('${INPUT_DATE}'));
					
					showdata(resp.rtnMap || {});
				}
			);
		
		},
		
		//試算
		doCalculate : function(event){
			valid1.reset();
			getValid("1");		
			//檢核
			if(!valid1.validate()){
				return;
			}
			
			ajaxPost('calculate' , { LOAN_ID : $F('LOAN_ID') },
				function(resp){
					$('form2').style.display="block";	
					
					var rtnMap = resp.C100Map || {}; 
					$$('#table2 span').each(
						function(ele){
							var id = ele.id;
							ele.update(rtnMap[id] || '');
					});
					
					var grid = new TableUI({
							table: $('grid'),
							column: [
									{header: "日期",key: "INT_STR_DATE",
										render : function(rec, val){
											return Date.toROC(val) || '';
									}},	
									{header: "期數",key: "RATE_TERM"},	
									{header: "是否在優惠期間",key: "IS_PREF_PERIOD_NM"},	
									{header: "計息利率",key: "RATE_VAL"},	
									{header: "指標",key: "IR_RT_IDX_NM",
										render : function(rec, val){
											return val+"("+rec['IR_RT_IDX']+")";
									}},	
									{header: "商品利率",key: "PROD_RATE"},	
									{header: "個別優惠",key: "PREF_VALUE1"},	
									{header: "保戶優惠",key: "PREF_VALUE2"},		
									{header: "利率限制",key: "LIMIT_MSG"},	
									{header: "有巢氏優惠",key: "PREF_VALUE3"},		
									{header: "災戶優惠",key: "PREF_VALUE4"},	
									{header: "專案加碼",key: "PREF_VALUE5"}
								]
							});
					grid.load(resp.rateList || []);
					
				   //[2022-09-19] 個別優惠利率明細新增時，若低於利率下限則跳出提醒
				   if(resp.isTriggerLimit=="Y"){
					  alert("此貸款帳號"+rtnMap['LOAN_ID']+"新增優惠後，已有部分期數利率低於利率限制，若希望達到預期的利率，請至利率計算>取消利率限制畫面(畫面編號DSC50800)，並依期數解除利率限制");
				   }
				}
			);
		},
		
		//變更信箱
		doMail: function(){
			
			var parms = { 'BORROW_ID' : $F('BORROW_ID') };
			
			popupWin.popup({
				src : '<%=dispatcher%>/DSC8_1400/prompt' ,
				parameters : parms
			});
		},
		
		showQuery : function(LOAN_ID, QUERY_DATE){
			var reqMap = {
				LOAN_ID : LOAN_ID,
				QUERY_DATE : QUERY_DATE
			};
			
			ajaxPost('query' , { dataMap : Object.toJSON(reqMap) },
				function(resp){
					showdata(resp.rtnMap || {});	
					
				}	
			);
			
			queryMap = reqMap;
		},
		changeADJUST_REASON: function(){
			//2017-11-10 若優惠原因為2利率不調整 3繳息不正常 5特殊加碼 7新件貸放利率減碼控管違約金 8保戶123優惠調整 9聯貸案件，帶成無個調附約，不檢核是否需終止
			if ($('ADJUST_REASON').value == '2' || $('ADJUST_REASON').value == '3' || $('ADJUST_REASON').value == '5' || $('ADJUST_REASON').value == '7' || $('ADJUST_REASON').value == '8' || $('ADJUST_REASON').value == '9'){
				$('IS_AUTO').value = '0';
			} else {
				$('IS_AUTO').value = '1';		
			}
		}
	};
	
	//利率格式化
	var gridFmtRender = function(value) { 
		return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.####', 0) : ''; 
	};

	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC50310', '利率調整', '個別優惠利率明細');
			
			autoFormatToNumber();
			initValidation();
			buttonAuth();
			
			$('form2').style.display="none";
			
			var LOAN_ID = '${LOAN_ID}' || '';
			var QUERY_DATE = '${BEGIN_DATE}' || '';
			$('IS_AUTO').value= '1'; //預設"有"
			if(LOAN_ID){
				buttons.showQuery(LOAN_ID, QUERY_DATE);
				$('OP_STATUS').value = '${OP_STATUS}';
				
			}else{
				$('INPUT_NAME').update('${INPUT_NAME}');
				$('BEGIN_DATE').value = toROC('${INPUT_DATE}');
				$('INPUT_DATE').update(Date.toROC('${INPUT_DATE}'));
				$('OP_STATUS').value = '10';
			}	
			
			$('CHECK_DELETE').value = '${CHECK_DELETE}';
			
			$('LOAN_ID').observe('blur', function(){this.value = this.value.toUpperCase();});
			$('ADJUST_REASON').observe('change', buttons.changeADJUST_REASON); 
			
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_update').observe('click', buttons.doUpdate);
			$('btn_delete').observe('click', buttons.doDelete);
			$('btn_calculate').observe('click', buttons.doCalculate);
			$('btn_confirm').observe('click', buttons.doConfirm);
			
			$('btn_clear').observe('click', 
				function(event){
					$('form1').reset();
					$$('#table1 span').each(
						function(ele){
							var id = ele.id;
							ele.update('');
					});
					$$('#table2 span').each(
						function(ele){
							var id = ele.id;
							ele.update('');
					});
					$('form2').style.display="none";
					$('INPUT_NAME').update('${INPUT_NAME}');
					$('BEGIN_DATE').value = toROC('${INPUT_DATE}');
					$('INPUT_DATE').update(Date.toROC('${INPUT_DATE}'));
				});
			$('btn_return').observe('click', 
				function(event){
					CSRUtil.linkBack();
				});
			$("btn_chgMail").observe('click', buttons.doMail);
			
			PageUI.resize();			
			displayMessage();			
		}
	};
}

</script>
</head>
<body>

<form name="form1" id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id="table1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbBox2" colspan="4" align="center">
				<input id="btn_query" type="button" class="button" value="查詢"/>
				<input id="btn_update" type="button" class="button" value="新增"/>
				<input id="btn_delete" type="button" class="button" value="刪除"/>
				<input id="btn_calculate" type="button" class="button" value="試算"/>
				<input id="btn_confirm" type="button" class="button" value="覆核"/>
				<input id="btn_clear" type="button" class="button" value="清除"/>
				<input id="btn_return" type="button" class="button" value="上一頁"/>
				
				
				<input id="AREA_CODE" type="hidden"/>
				<input id="QUERY_LOAN_ID" type="hidden"/>
				<input id="LOAN_KIND" type="hidden"/>
				<input id="PREFER_TYPE" type="hidden"/>
				<input id="CHECK_DELETE" type="hidden"/>
				<input id="OP_STATUS" type="hidden"/>
				<input id="INFORM_SEND" type="hidden"/>
				
				<input id="IS_EXTRACT" type="hidden"/>
				
				
			</td>
		</tr>
		<tr>	
			<td class="tbYellow">貸款帳號</td>
			<td class="tbYellow2"  >
				<input id="LOAN_ID" type="text" class="textBox2" size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()" />
			</td>
			<td class="tbYellow">借款人姓名</td>
			<td class="tbYellow2"  >
				<span id="BORROW_NAME" style="font-family:'EUDC'"></span>  <%-- [20241104] 難字調整: 借款人姓名 --%>
				<input id="BORROW_ID" type="hidden"></input>
			</td>
		</tr>
		<tr>	
			<td class="tbYellow">生效日期</td>
			<td class="tbYellow2"  >
				<input id="BEGIN_DATE" type="text" class="textBox2" size="12" maxlength="10" datatype ="ROCDate" value="${SYS_DATE}"/>
				<img src="/DSWeb/images/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('BEGIN_DATE'))">
			</td>
			<td class="tbYellow">總優惠期數</td>
			<td class="tbYellow2"  >
				<input id="PREFER_TERM" type="text" class="textBox2" size='5' maxlength='3' datatype="number" />
			</td>
		</tr>
		<tr>	
			<td class="tbYellow">終止日期</td>
			<td class="tbYellow2"  >
				<span id="END_DATE"></span>
			</td>
			<td class="tbYellow">個別優惠</td>
			<td class="tbYellow2">
				前<input id="FRATE_TERM" type="text" class="textBox2" size='5' maxlength='3' datatype="number" value="1" />期，
				固定利率<input id="FIX_RATE" type="text" class="textBox2" size='9' maxlength='7' datatype="number"/>%，其他期間，
				加碼減<input id="SPEC_ADJUST" type="text" class="textBox2" size='9' maxlength='7' datatype="number"/>%
				
				<div id="rate990801" style="overflow:auto; display:none;">
					<font color='red'><br><b>配合央行政策，各項房貸商品搭配優惠專案後之利率，以1.84%為下限</b></font>
				</div>
				
			</td>
		</tr>
		<tr>	
			<td class="tbYellow">優惠原因</td>
			<td class="tbYellow2"  >
				<select id="ADJUST_REASON">
			       	<c:forEach var="map" items="${ADJUST_REASON_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>
			<td class="tbYellow">保戶優惠</td>
			<td class="tbYellow2"  >
				<input id="INSU_PREFER" type="checkbox"/>
			</td>
		</tr>
		<tr>	
			<td class="tbYellow">展業區部</td>
			<td class="tbYellow2"  >
				<!--  <input id="AREA_CODE_NM" type="text" />-->
				<span id="AREA_CODE_NM"></span>
			</td>
			<td class="tbYellow">檢附個調附約</td>
			<td class="tbYellow2"  >
				<select id="IS_AUTO">
			       	<c:forEach var="map" items="${AUTO_KIND_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>
		</tr>
		<tr>	
			<td class="tbYellow">手續費用</td>
			<td class="tbYellow2"  >
			<input id="EXPENSE_AMT" type="text" class="textBox2" size="7" maxlength="6"  datatype="number" value="0" />	
			</td>
			<td class="tbYellow">電子信箱</td>
			<td class="tbYellow2"  >
				<input id="EMAIL" type="text" class="textBox2" readOnly />
				<input id="btn_chgMail" type="button" class="button" value="變更信箱"/>
			</td>
		</tr>
		<tr>	
			<td class="tbYellow">清償通報日</td>
			<td class="tbYellow2"  >
				<span id="INFORM_DATE"></span>
			</td>
			<td class="tbYellow">通報處理利率</td>
			<td class="tbYellow2"  >
				<span id="FINAL_RATE"></span>%
			</td>
		</tr>
		<tr>	
			<td class="tbYellow">通報處理狀況</td>
			<td class="tbYellow2"  >
				<span id="PROCESS_STATUS_NM"></span>
			</td>
			<td class="tbYellow">下期利率</td>
			<td class="tbYellow2"  >
				<span id="RATE"></span>%
			</td>
		</tr>
		<tr>	
			<td class="tbYellow">案件編號</td>
			<td class="tbYellow2"  >
				<span id="REGISTER_NO"></span>
			</td>
			<td class="tbYellow">作業日期及人員</td>
			<td class="tbYellow2"  >
				<span id="INPUT_DATE"></span>&nbsp;<span id="INPUT_NAME" style="font-family:'EUDC'"></span>  <%-- [20241104] 難字調整: 作業日期及人員 --%>
			</td>
		</tr>
	</table>
</form>
<form name="form2" id="form2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id="table2" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
		<tr class="tbBlue"><td colspan="8">試算結果</td></tr>
		<tr>
			<td class="tbYellow" width="12.5%">姓名</td>
			<td class="tbYellow2" width="12.5%"><span id="BORROW_NAME"></span></td>
			<td class="tbYellow" width="12.5%">優惠種類</td>
			<td class="tbYellow2" width="12.5%"><span id="PREFER_TYPE_NM"></span></td>
			<td class="tbYellow" width="12.5%">貸款種類</td>
			<td class="tbYellow2" width="12.5%"><span id="LOAN_KIND_NM"></span></td>
			<td class="tbYellow" width="12.5%">地區代號</td>
			<td class="tbYellow2" width="12.5%"><span id="AREA_CODE_NM"></span></td>
		</tr>
		<tr>
			<td class="tbYellow" >每月應繳日</td>
			<td class="tbYellow2" ><span id="DUTY_DAY"></span></td>
			<td class="tbYellow" >金雞獨利繳息正常優惠</td>
			<td class="tbYellow2" ><span id="GROUP_NOTE2"></span></td>
			<td class="tbYellow" >有巢氏商品/利率減碼</td>
			<td class="tbYellow2" colspan="3" ><span id="GROUP_NOTE3"></span></td>
		</tr>
	</table>
	<table id="grid" class="grid"></table>
</form>
</body>
</html>