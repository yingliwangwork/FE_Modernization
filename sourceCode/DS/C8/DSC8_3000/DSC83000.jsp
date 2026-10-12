<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<!--
程式：DSC83000.jsp
功能：特殊件控管作業
作者：吳學建
完成：2013/08/

[20230324] 難字修改

[20230525] 問題單號20230524083637
1.難字CSS補上URL
2.受理控管方式，下方6個控管原因，補上alt="ch"，顯示難字
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<style type="text/css"><%-- [20230324]難字修改 --%><%--[20230525][20230524083637]補上URL設定--%>
	@font-face{
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"), 
			 url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		font-weight:normal;
		font-style:normal
	}	
</style>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC83000().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
var c105List;
function DSC83000(){
	// 按鈕權限
	var buttonAuth = function(){
		var authButtons = {
			B0004 : 'btn_update',		<%--變更--%>	
			B0054 : 'btn_updateAll'		<%--整批變更--%>	
		};
		<dz:grantButtons FUNC_ID='DSC83000'/>
	};
	function initValidation(){		
			//查詢用檢核
			//valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			//valid1.define('required' , [{ id : "LOAN_ID" , errMsg:"請輸入貸款帳號"}] );				
			valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid1.define('checkROCID' , [{ id : "BORROW_ID" , errMsg:"請輸入正確身份證字號"}] );
						
			valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid2.define('required' , [{ id : "PAYOFF_REASON1" , errMsg:"請輸入變更原因"}] );
			//valid2.define('validate-selection' , [{ id : "NEW_PAYOFF_LIMIT" , errMsg:"請選擇新個控代碼"}] );
			
			valid3 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid3.define('required' , [{ id : "PAYOFF_REASON2" , errMsg:"請輸入變更原因"}] );
			
			valid4 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid4.define('required' , [{ id : "PAYOFF_REASON3" , errMsg:"請輸入變更原因"}] );	
	}
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_3000/" + actionName,
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
	
	<%-- [20231127] --%>
	var auxiliary = {
		<%--CoverPage(鎖定畫面)--%>
		createCoverPage:function(){
			cover = CSRUtil.createCoverPage('_frontCover');
			cover.show();
		},
		<%--CoverPage(開放畫面)--%>
		closeCoverPage: function(){
			cover.hide();
		}
	}
	
	var buttons={
	
		doQuery : function(){
		
		    if(!$F('LOAN_ID') && !$F('APPLY_ID') && !$F('BORROW_ID')){
				alert('貸款帳號、受理編號及身份證字號,至少要輸入一項!!');
				return;
			}
		
			if($F('BORROW_ID') && !valid1.validate()){
				return;
			}
	
			var reqMap={
						LOAN_ID : $F('LOAN_ID'),
						APPLY_ID : $F('APPLY_ID'),
						BORROW_ID : $F('BORROW_ID')
					};
			
			ajaxPost( 'query', {reqMap : Object.toJSON(reqMap)}
						,function(resp){
	
							buttons.clear(0);
							var userMap=resp.userMap;
							$('TBORROW_ID').value=userMap['BORROW_ID'];
							$('TBORROW_NAME').value=userMap['BORROW_NAME'];
							$('BORROW_ID_OLD').value =userMap['BORROW_ID'];
							
							if('Y' == userMap['NOTLOANUSER']){
								alert('經查本件借款人尚無紀錄，請先鍵入特殊控管資料');
							}
							c105List=resp.c105List;
							for(var i=0; i< c105List.length ; i++){
								var CONTROL_SOURCE =  c105List[i].CONTROL_SOURCE;
								if(CONTROL_SOURCE == '1'){
								    $('END_CONTROL_1').checked = true;
								    $('CONTROL_REASON_1').value = c105List[i].CONTROL_REASON
								}else if(CONTROL_SOURCE == '2'){
								    $('END_CONTROL_5').checked = true;
								    $('CONTROL_REASON_2').value = c105List[i].CONTROL_REASON
								}else if(CONTROL_SOURCE == '3'){
								  	$('END_CONTROL_9').checked = true;
								  	$('CONTROL_REASON_3').value = c105List[i].CONTROL_REASON
								}else if(CONTROL_SOURCE == '7'){
									$('END_CONTROL_3').checked = true;
									$('CONTROL_REASON_7').value = c105List[i].CONTROL_REASON
								}else if(CONTROL_SOURCE == '8'){
									$('END_CONTROL_7').checked = true;
									$('CONTROL_REASON_8').value = c105List[i].CONTROL_REASON
								}else if(CONTROL_SOURCE == '9'){
									$('END_CONTROL_B').checked = true;
									$('CONTROL_REASON_9').value = c105List[i].CONTROL_REASON
								}
							}
							
							//var CONTROL_CODE =  resp.CONTROL_CODE;
						    //if( confirm("本件有「特殊提醒」注意事項。\r\n詳細內容請洽OO單位。\r\n確定：進入特殊件控管變更紀錄。\r\n取消：離開")){
							//   buttons.linkTo_DSC8_3100(userMap['BORROW_ID'],"ALL");
			                //}
						},function(resp){
							$('BORROW_ID_OLD').value ='';
							var key1 = $F('LOAN_ID');
							var key2 = $F('APPLY_ID');
							var key3 = $F('BORROW_ID');
							
							form.reset();
							
							$('LOAN_ID').value = key1;
							$('APPLY_ID').value = key2;
							$('BORROW_ID').value = key3;	
						}
				);
		},
		doUpdate : function(){
			
			valid1.reset();
			if(!$F('BORROW_ID_OLD')){
				alert("請先查詢後再做變更");
				return;
			}
			
			var i = 0;
			$$('#form input[type="radio"]').each(
				function(checkbox){
					if(checkbox.checked == true){
					    i = i + 1;    
					}
				}
			);
			
			if(i == 0){
				alert("至少要有一項變更");
				return;
			}
			
			var reqMap1={};
			if($('END_CONTROL_1').checked){
			     reqMap1.CONTROL_SOURCE = '1';
			     reqMap1.END_CONTROL = '0';
			     if(!$F('CONTROL_REASON_1')){
						alert("請輸入控管原因");
						return;
				 }
			     reqMap1.CONTROL_REASON = $F('CONTROL_REASON_1');
			}else if($('END_CONTROL_2').checked){
			     reqMap1.CONTROL_SOURCE = '1';
				 reqMap1.END_CONTROL = '1';
				 if(!$F('CONTROL_REASON_1')){
						alert("請輸入控管原因");
						return;
				 }
				 reqMap1.CONTROL_REASON = $F('CONTROL_REASON_1');
			}else if($('END_CONTROL_3').checked){
			     reqMap1.CONTROL_SOURCE = '7';
			     reqMap1.END_CONTROL = '0';
			     if(!$F('CONTROL_REASON_7')){
						alert("請輸入控管原因");
						return;
				 }
			     reqMap1.CONTROL_REASON = $F('CONTROL_REASON_7');
			}else if($('END_CONTROL_4').checked){
			     reqMap1.CONTROL_SOURCE = '7';
			     reqMap1.END_CONTROL = '1';
			     if(!$F('CONTROL_REASON_7')){
						alert("請輸入控管原因");
						return;
				 }
			     reqMap1.CONTROL_REASON = $F('CONTROL_REASON_7');
			}
			var reqMap2={};
			if($('END_CONTROL_5').checked){
			     reqMap2.CONTROL_SOURCE = '2';
			     reqMap2.END_CONTROL = '0';
			     if(!$F('CONTROL_REASON_2')){
						alert("請輸入控管原因");
						return;
				 }
			     reqMap2.CONTROL_REASON = $F('CONTROL_REASON_2');
			}else if($('END_CONTROL_6').checked){
			     reqMap2.CONTROL_SOURCE = '2';
			     reqMap2.END_CONTROL = '1';
			     if(!$F('CONTROL_REASON_2')){
						alert("請輸入控管原因");
						return;
				 }
			     reqMap2.CONTROL_REASON = $F('CONTROL_REASON_2');
			}else if($('END_CONTROL_7').checked){
			     reqMap2.CONTROL_SOURCE = '8';
			     reqMap2.END_CONTROL = '0';
			     if(!$F('CONTROL_REASON_8')){
						alert("請輸入控管原因");
						return;
				 }
			     reqMap2.CONTROL_REASON = $F('CONTROL_REASON_8');
			}else if($('END_CONTROL_8').checked){
			     reqMap2.CONTROL_SOURCE = '8';
			     reqMap2.END_CONTROL = '1';
			     if(!$F('CONTROL_REASON_8')){
						alert("請輸入控管原因");
						return;
				 }
			     reqMap2.CONTROL_REASON = $F('CONTROL_REASON_8');
			}
			var reqMap3={};
			if($('END_CONTROL_9').checked){
			    reqMap3.CONTROL_SOURCE = '3';
			    reqMap3.END_CONTROL = '0';
			    if(!$F('CONTROL_REASON_3')){
					alert("請輸入控管原因");
					return;
				}
			    reqMap3.CONTROL_REASON = $F('CONTROL_REASON_3');
			}else if($('END_CONTROL_A').checked){
			    reqMap3.CONTROL_SOURCE = '3';
			    reqMap3.END_CONTROL = '1';
			    if(!$F('CONTROL_REASON_3')){
					alert("請輸入控管原因");
					return;
				}
			    reqMap3.CONTROL_REASON = $F('CONTROL_REASON_3');
			}else if($('END_CONTROL_B').checked){
			    reqMap3.CONTROL_SOURCE = '9';
			    reqMap3.END_CONTROL = '0';
			    if(!$F('CONTROL_REASON_9')){
					alert("請輸入控管原因");
					return;
				}
			    reqMap3.CONTROL_REASON = $F('CONTROL_REASON_9');
			}else if($('END_CONTROL_C').checked){
			    reqMap3.CONTROL_SOURCE = '9';
			    reqMap3.END_CONTROL = '1';
			    if(!$F('CONTROL_REASON_9')){
					alert("請輸入控管原因");
					return;
				}
			    reqMap3.CONTROL_REASON = $F('CONTROL_REASON_9');
			}
	
			reqMap={};
			reqMap.reqMap1 = reqMap1;
			reqMap.reqMap2 = reqMap2;
			reqMap.reqMap3 = reqMap3;
	
			ajaxPost( 'update', {c105List : Object.toJSON(c105List),reqMap : Object.toJSON(reqMap),BORROW_ID : $F('BORROW_ID_OLD')}
						,function(resp){
						    buttons.clear(0);
							var userMap=resp.userMap;
							$('TBORROW_ID').value=userMap['BORROW_ID'];
							$('TBORROW_NAME').value=userMap['BORROW_NAME'];
							$('BORROW_ID_OLD').value =userMap['BORROW_ID'];
							c105List=resp.c105List;
							for(var i=0; i< c105List.length ; i++){
								var CONTROL_SOURCE =  c105List[i].CONTROL_SOURCE;
								if(CONTROL_SOURCE == '1'){
								    $('END_CONTROL_1').checked = true;
								    $('CONTROL_REASON_1').value = c105List[i].CONTROL_REASON
								}else if(CONTROL_SOURCE == '2'){
								    $('END_CONTROL_5').checked = true;
								    $('CONTROL_REASON_2').value = c105List[i].CONTROL_REASON
								}else if(CONTROL_SOURCE == '3'){
								  	$('END_CONTROL_9').checked = true;
								  	$('CONTROL_REASON_3').value = c105List[i].CONTROL_REASON
								}else if(CONTROL_SOURCE == '7'){
									$('END_CONTROL_3').checked = true;
									$('CONTROL_REASON_7').value = c105List[i].CONTROL_REASON
								}else if(CONTROL_SOURCE == '8'){
									$('END_CONTROL_7').checked = true;
									$('CONTROL_REASON_8').value = c105List[i].CONTROL_REASON
								}else if(CONTROL_SOURCE == '9'){
									$('END_CONTROL_B').checked = true;
									$('CONTROL_REASON_9').value = c105List[i].CONTROL_REASON
								}
							}
						}
				);	     
		},
		// [20231127] 整批變更 
		doUpdateAll : function(){
			
			valid1.reset();
			//檢核「檔案」是否有選取
			if(!$F('UPLOAD_FILE')) {
				alert('請先選擇上傳資料再執行!');
				return;
			}
			
			var i = 0;
			$$('#form input[type="radio"]').each(
				function(checkbox){
					if(checkbox.checked == true){
					    i = i + 1;    
					}
				}
			);
			
			if(i == 0){
				alert("至少要有一項變更");
				return;
			}

			if($('END_CONTROL_1').checked){
				$('END_CONTROL_UPLOAD_1').value = '0';
				$('CONTROL_SOURCE_UPLOAD_1').value = '1';
			    if(!$F('CONTROL_REASON_1')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_1').value = $F('CONTROL_REASON_1');
			}else if($('END_CONTROL_2').checked){
				$('END_CONTROL_UPLOAD_1').value = '1';
				$('CONTROL_SOURCE_UPLOAD_1').value = '1';
			    if(!$F('CONTROL_REASON_1')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_1').value = $F('CONTROL_REASON_1');
			}else if($('END_CONTROL_3').checked){
				$('END_CONTROL_UPLOAD_1').value = '0';
				$('CONTROL_SOURCE_UPLOAD_1').value = '7';
			    if(!$F('CONTROL_REASON_7')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_1').value = $F('CONTROL_REASON_7');
			}else if($('END_CONTROL_4').checked){
				$('END_CONTROL_UPLOAD_1').value = '1';
				$('CONTROL_SOURCE_UPLOAD_1').value = '7';
			    if(!$F('CONTROL_REASON_7')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_1').value = $F('CONTROL_REASON_7');
			}else{
				$('END_CONTROL_UPLOAD_1').value = '';
				$('CONTROL_SOURCE_UPLOAD_1').value = '';
				$('CONTROL_REASON_UPLOAD_1').value = '';
			}
			
			if($('END_CONTROL_5').checked){
				$('END_CONTROL_UPLOAD_2').value = '0';
				$('CONTROL_SOURCE_UPLOAD_2').value = '2';
			    if(!$F('CONTROL_REASON_2')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_2').value = $F('CONTROL_REASON_2');
			}else if($('END_CONTROL_6').checked){
				$('END_CONTROL_UPLOAD_2').value = '1';
				$('CONTROL_SOURCE_UPLOAD_2').value = '2';
			    if(!$F('CONTROL_REASON_2')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_2').value = $F('CONTROL_REASON_2');
			}else if($('END_CONTROL_7').checked){
				$('END_CONTROL_UPLOAD_2').value = '0';
				$('CONTROL_SOURCE_UPLOAD_2').value = '8';
			    if(!$F('CONTROL_REASON_8')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_2').value = $F('CONTROL_REASON_8');
			}else if($('END_CONTROL_8').checked){
				$('END_CONTROL_UPLOAD_2').value = '1';
				$('CONTROL_SOURCE_UPLOAD_2').value = '8';
			    if(!$F('CONTROL_REASON_8')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_2').value = $F('CONTROL_REASON_8');
			}else{
				$('END_CONTROL_UPLOAD_2').value = '';
				$('CONTROL_SOURCE_UPLOAD_2').value = '';
				$('CONTROL_REASON_UPLOAD_2').value = '';
			}
			
			if($('END_CONTROL_9').checked){
				$('END_CONTROL_UPLOAD_3').value = '0';
				$('CONTROL_SOURCE_UPLOAD_3').value = '3';
			    if(!$F('CONTROL_REASON_3')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_3').value = $F('CONTROL_REASON_3');
			}else if($('END_CONTROL_A').checked){
				$('END_CONTROL_UPLOAD_3').value = '1';
				$('CONTROL_SOURCE_UPLOAD_3').value = '3';
			    if(!$F('CONTROL_REASON_3')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_3').value = $F('CONTROL_REASON_3');
			}else if($('END_CONTROL_B').checked){
				$('END_CONTROL_UPLOAD_3').value = '0';
				$('CONTROL_SOURCE_UPLOAD_3').value = '9';
			    if(!$F('CONTROL_REASON_9')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_3').value = $F('CONTROL_REASON_9');
			}else if($('END_CONTROL_C').checked){
				$('END_CONTROL_UPLOAD_3').value = '1';
				$('CONTROL_SOURCE_UPLOAD_3').value = '9';
			    if(!$F('CONTROL_REASON_9')){
					alert("請輸入控管原因");
					return;
				}
			    $('CONTROL_REASON_UPLOAD_3').value = $F('CONTROL_REASON_9');
			}else{
				$('END_CONTROL_UPLOAD_3').value = '';
				$('CONTROL_SOURCE_UPLOAD_3').value = '';
				$('CONTROL_REASON_UPLOAD_3').value = '';
			}
	
			auxiliary.createCoverPage();
			$('form').action = '${dispatcher}/DSC8_3000/updateAll';
			$('form').submit();     
		},
		// [20231127] 匯入結束 
		importEnd : function(event){
		
			auxiliary.closeCoverPage();
			var ele_filedata = window.importFrame.document.getElementById("filedata");
			if(ele_filedata){
				var obj = ele_filedata.innerHTML.evalJSON();
				var Msg = obj.ErrMsg.msgDesc.replace('\\n','');      
			}
			
			if(CSRUtil.isSuccess(obj)) {
				form.reset();
			    $('import').update(new Element( "input", { id:"UPLOAD_FILE", name:"UPLOAD_FILE", type:"file", 'class': "textBox2", size:"50"}));	
			}
			
			if(Msg != null && Msg != ""){
				alert(obj.ErrMsg.msgDesc.replace("\\n",""));
			}
		},
		// [20231127]清除	
		doClear :　function(event) {				
			form.reset();	
		},	
		// 清除畫面欄位
		clear : function(type){
	        c105List={};
	
			$$('#form input[type="text"]').each(
				function(text){
					// 執行清除
					if(type == "1"){
						text.value = "";
					}else if(text.id != "LOAN_ID" && text.id != "APPLY_ID" &&  text.id != "BORROW_ID" ){
						text.value = "";
					}
				}
			);
				
			$$('#form input[type="radio"]').each(
				function(checkbox){
					//checkbox.disabled = false;
					checkbox.checked = false;
				}
			);
		},
		linkTo_DSC8_3100 : function(BORROW_ID,CONTROL_SOURCE){	
			
			popupWin.popup({
				src: '<%=dispatcher%>/DSC8_3100/prompt',scrolling : 'yes',
				parameters: { 
					LOAN_ID : BORROW_ID,
					CONTROL_TYPE : 'U',
					CONTROL_SOURCE : CONTROL_SOURCE
				}, 
				width: 600, 
				height: 350,
				cb : function(obj){}
			});
			
		}
			
	}

	return {
		
		initApp : function(){
			PageUI.createPageWithAllBodySubElement('DSC83000', '變更作業', '特殊件控管作業');
			
			initValidation();
			$('btn_query').observe('click',buttons.doQuery);
			$('btn_update').observe('click',buttons.doUpdate);
			// [20231127] 整批變更
			$('btn_clear').observe('click',buttons.doClear);
			$('btn_updateAll').observe('click',buttons.doUpdateAll);
			$('importFrame').observe('load', buttons.importEnd);
			//$('PAYOFF_LIMIT').disable();
			$('LOAN_ID').observe('change', function(event){
				$('APPLY_ID').value='';
				$('BORROW_ID').value='';
			});
			$('APPLY_ID').observe('change', function(event){
				$('LOAN_ID').value='';
				$('BORROW_ID').value='';
			});
			$('BORROW_ID').observe('change', function(event){
				$('LOAN_ID').value='';
				$('APPLY_ID').value='';
			});

			buttonAuth();
			//先把畫面區塊都調整到位再顯示訊息
			fix();	
			//初始頁面alert訊息用	
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" method="post" target="importFrame" enctype="multipart/form-data">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">貸款帳號</td>
			<td class="tbYellow2" width="15%">
				<input id="LOAN_ID"  type="text" class="textBox2 " onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10" value =""/>
			</td>
			<td class="tbYellow" width="10%">受理編號</td>
			<td class="tbYellow2" width="15%">
				<input id="APPLY_ID"  type="text" class="textBox2 " onblur="this.value = this.value.toUpperCase()" size="12" maxlength="11"/>
			</td>
			<td class="tbYellow" width="10%">身份證字號</td>
			<td class="tbYellow2" width="15%">
				<input id="BORROW_ID"  type="text" class="textBox2 " onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
				<input id="BORROW_ID_OLD" type="hidden">
			</td>
			<td class="tbYellow2" >
				<input id="btn_query" type="button" value="查詢" class="button" >	
				<input id="btn_clear" type="button" value="清除" class="button" >
			</td>
		</tr>
		<%-- [20231127] 新增整批變更功能 --%>
		<tr>
			<td class="tbYellow" width="10%">檔案</td>
			<td class="tbYellow2" colspan="6">
				<span id="import"><input type="file" class="textBox2" id="UPLOAD_FILE" name="UPLOAD_FILE" size='50' ></span>
				<input id="CONTROL_SOURCE_UPLOAD_1" name="CONTROL_SOURCE_UPLOAD_1" type="hidden">
				<input id="CONTROL_SOURCE_UPLOAD_2" name="CONTROL_SOURCE_UPLOAD_2" type="hidden">
				<input id="CONTROL_SOURCE_UPLOAD_3" name="CONTROL_SOURCE_UPLOAD_3" type="hidden">
				<input id="END_CONTROL_UPLOAD_1" name="END_CONTROL_UPLOAD_1" type="hidden">
				<input id="END_CONTROL_UPLOAD_2" name="END_CONTROL_UPLOAD_2" type="hidden">
				<input id="END_CONTROL_UPLOAD_3" name="END_CONTROL_UPLOAD_3" type="hidden">
				<input id="CONTROL_REASON_UPLOAD_1" name="CONTROL_REASON_UPLOAD_1" type="hidden">
				<input id="CONTROL_REASON_UPLOAD_2" name="CONTROL_REASON_UPLOAD_2" type="hidden">
				<input id="CONTROL_REASON_UPLOAD_3" name="CONTROL_REASON_UPLOAD_3" type="hidden">
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td width="100%" colspan="7" align="center">	
				<input id="btn_update" type="button" value="變更" class="button" >				
				<input id="btn_updateAll" type="button" value="整批變更" class="button" >
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
		<tr>
			<td class="tbBox3" align="center">特殊件控管作業</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">借款人姓名</td>
			<td class="tbYellow2">
				<input id="TBORROW_ID"  size="12" type="text" class="textBox2" disabled/>
				<input id="TBORROW_NAME"  size="26" type="text" class="textBox2" alt='ch' readonly="readonly" disabled/><%-- [20230324]難字修改 --%>
			</td>
		</tr>
	</table>	
    <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
		<tr>
			<td class="tbYellow" width="20%" align='center' >受理控管方式</td>
			<td class="tbYellow" width="10%" align='center' >是否生效</td>
			<td class="tbYellow"  align='center' >控管原因</td>
		</tr>
		<tr>			
			<td class="tbYellow2" width="15%" align='center' >受理控管</td>
			<td class="tbYellow2" width="10%" align='center'>
			  	<input type="radio" name="END_CONTROL1" id="END_CONTROL_1" value="0" />是
			  	<input type="radio" name="END_CONTROL1" id="END_CONTROL_2" value="1" />否
			</td>
			<td class="tbYellow2" >
				<input id="CONTROL_REASON_1"  type="text" class="textBox2 " alt="ch" size="80" maxlength="140"/><%--[20230525][20230524083637]補上alt="ch"，顯示難字--%>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2"  align='center'>受理提醒</td>
			<td class="tbYellow2" align='center'>
			  	<input type="radio" name="END_CONTROL1" id="END_CONTROL_3" value="0" />是
			  	<input type="radio" name="END_CONTROL1" id="END_CONTROL_4" value="1" />否
			</td>
			<td class="tbYellow2" >
				<input id="CONTROL_REASON_7"  type="text" class="textBox2 " alt="ch" size="80" maxlength="140"/><%--[20230525][20230524083637]補上alt="ch"，顯示難字--%>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">&nbsp</td>
		</tr>
		<tr>				
			<td class="tbYellow2" width="15%" align='center'>審查簽件控管</td>
			<td class="tbYellow2" width="10%" align='center'>
			  	<input type="radio" name="END_CONTROL2" id="END_CONTROL_5" value="0" />是
			  	<input type="radio" name="END_CONTROL2" id="END_CONTROL_6" value="1" />否
			</td>			
			<td class="tbYellow2" >
				<input id="CONTROL_REASON_2"  type="text" class="textBox2 " alt="ch" size="80" maxlength="140"/><%--[20230525][20230524083637]補上alt="ch"，顯示難字--%>
			</td>		
		</tr>		
		<tr>
			<td class="tbYellow2"  align='center'>審查簽件提醒</td>
			<td class="tbYellow2" align='center'>
			  	<input type="radio" name="END_CONTROL2" id="END_CONTROL_7" value="0" />是
			  	<input type="radio" name="END_CONTROL2" id="END_CONTROL_8" value="1" />否
			</td>
			<td class="tbYellow2" >
				<input id="CONTROL_REASON_8"  type="text" class="textBox2 " alt="ch" size="80" maxlength="140"/><%--[20230525][20230524083637]補上alt="ch"，顯示難字--%>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="3">&nbsp</td>
		</tr>
		<tr>			
			<td class="tbYellow2" width="15%" align='center'>貸後變更控管<br>(變更年期、利率個調)</td>
			<td class="tbYellow2" width="10%" align='center'>
			  	<input type="radio" name="END_CONTROL3" id="END_CONTROL_9" value="0" />是
			  	<input type="radio" name="END_CONTROL3" id="END_CONTROL_A" value="1" />否
			</td>
			<td class="tbYellow2" >
				<input id="CONTROL_REASON_3"  type="text" class="textBox2 " alt="ch" size="80" maxlength="140"/><%--[20230525][20230524083637]補上alt="ch"，顯示難字--%>
			</td>			
		</tr>
		<tr>
			<td class="tbYellow2"  align='center'>貸後作業提醒</td>
			<td class="tbYellow2" align='center'>
			  	<input type="radio" name="END_CONTROL3" id="END_CONTROL_B" value="0" />是
			 	<input type="radio" name="END_CONTROL3" id="END_CONTROL_C" value="1" />否
			</td>
			<td class="tbYellow2" >
				<input id="CONTROL_REASON_9"  type="text" class="textBox2 " alt="ch" size="80" maxlength="140"/><%--[20230525][20230524083637]補上alt="ch"，顯示難字--%>
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
		<tr>
			<td class="tbYellow"  colspan='3' >
			    &nbsp; (1)	作業說明：
			<br>&nbsp; A.點選各類控管選項，相關業務作業將無法執行。
			<br>&nbsp; B.點選各類提醒選項，進行相關業務時會顯示提示訊息。
			<br>&nbsp; (2)	操作說明：
			<br>&nbsp; A.案件一經設控，各項業務將無法進行，須由原設控單位解除。
			</td>
		</tr>
	</table>
</form>
<iframe id="importFrame" style="display:none;" name="importFrame" width="0" height="0"></iframe><%-- 匯入檔案時，模擬Ajax的效果 --%>
</body>
</html>