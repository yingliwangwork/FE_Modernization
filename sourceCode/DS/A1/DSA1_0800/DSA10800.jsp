<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA10800.jsp
作者：i9100606
功能：謄本查詢確認
完成：2011/09/26
更新：
-->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<%--[20240722]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<%--自行定義的javaScript--%>
<script type="text/JavaScript">
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function initApp(){

	cleanMsgBoard();

	buttonAuth();

	PageUI.createPage("DSA10800" , "受理作業" ,"謄本查詢確認");
    PageUI.loadin(["form1","grid"] ,1);

	//TableUI的產生        
	new UI().init();
	
	PageUI.resize(true);                
   
}

<%--
	button控制
--%>
function buttonAuth(){
	var authButtons = {
		B0003:"btn_insert",//新增   			
		B0008:["btn_reject","btn_reject2"],//退回
		B0023:"btn_cancels_takes",//取消取件
		B0030:"btn_image",//所有權狀影像
		B0031:"btn_submit",//送出
		B0080:"btn_confirm",//到謄本確認
		B0067:"btn_transfer"//派件
	};
	<dz:grantButtons FUNC_ID="DSA10800" ignored="false"/> 	
}

//--------------------------------------------------------------------------
// 超連結
//--------------------------------------------------------------------------
var hyperlinks = {
	// popUp
	popup:function(conf, callbackFun){
		popupWin.callbackHandler = callbackFun;
		popupWin.popup(conf);
	}
};

<%--
	轉大寫
--%>
function columnToUpperCase(columnName) {
	if(isNotEmpty($F(columnName))) {
		$(columnName).value = $(columnName).value.toUpperCase();
	}
}

<%--
	辨別是不是null或undefined	
--%>
function isNotEmpty(value) {
	if(value == null || typeof(value) == 'undefined') {
		return false;
	}else {
		return true;
	}
}

//--------------------------------------------------------------------------  
<%--全域 函數 UI 與 畫面 公用 End----------------------------------------------------%>

<%--Define UI Class Start-------------------------------------------------------%>
function UI(){                
	//--------------------------------------------------------------------------          
	//UI() private variable        
	//--------------------------------------------------------------------------         
	var grid = {};        
	var validator;        
	var prod;
	var lastRow;
	var checkboxControl = false;
	var index = 0;
	var record_MAX_SEQ_NO = 0; 
	var FORM_TYPE;
	//--------------------------------------------------------------------------          
	//UI() private method        
	//--------------------------------------------------------------------------          
	//***        
	
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA1_0800/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	    	onSuccess: successAction
		});
	}      
	
	//AJAX SuccessAction For Query
	function successActionForQuery(XHT, resp) {
		if(CSRUtil.isSuccess(resp)){
			index = 0;
			$('OLD_APPLY_ID').value=$('APPLY_ID').value;
			$('REFER_ID').value = resp.REFER_ID||'';
			$('OLD_REFER_ID').value=$('REFER_ID').value;
			grid.load(resp.rtnList || [] , null, null , [0 , "0"]);
		} else{
			$('OLD_APPLY_ID').value=$('APPLY_ID').value;
			$('REFER_ID').value = resp.REFER_ID||'';
			$('OLD_REFER_ID').value=$('REFER_ID').value;
			grid.load([]);
		}
		if('Y'==resp.btn_dis){
			alert(resp.btn_dis_msg);
			//新增 button click event                        
			$('btn_insert').disabled=true;
			//退回服務中心                       
			$('btn_reject').disabled=true;
			//電子補全通知
			$('btn_reject2').disabled=true;
			//取消取件 button click event                        
			$('btn_cancels_takes').disabled=true;
			//確認 button click event                        
			$('btn_confirm').disabled=true;
			//所有權狀影像 button click event                        
			//$('btn_image').disabled=true;
			//送出 button click event                        
			$('btn_submit').disabled=true;			
			//案件移轉 button click event
			//[2022-01-14]問題單20220114-0047：因第二次改派後轉派時，影像系統清除鎖件人員時有可能沒有清除成功，導致案件卡住
			//與俊成確認後，案件轉派不卡控需原鎖件人員才可執行
			//$('btn_transfer').disabled=true;
		}else{
			//新增 button click event                        
			$('btn_insert').disabled=false;
			//退回服務中心                       
			$('btn_reject').disabled=false;
			//電子補全通知
			$('btn_reject2').disabled=false;
			//取消取件 button click event                        
			$('btn_cancels_takes').disabled=false;
			//確認 button click event                        
			$('btn_confirm').disabled=false;
			//所有權狀影像 button click event                        
			$('btn_image').disabled=false;
			//送出 button click event                        
			$('btn_submit').disabled=false;	
			//案件移轉 button click event          
			//[2022-01-14]問題單20220114-0047：因第二次改派後轉派時，影像系統清除鎖件人員時有可能沒有清除成功，導致案件卡住
			//與俊成確認後，案件轉派不卡控需原鎖件人員才可執行
			//$('btn_transfer').disabled=false;	
		}
		grid.resetDivHeight();
		PageUI.resize(true);		
	}		
		
	//查詢Function       
	var doQuery = function(){
		var msg = "";
		
		if($('APPLY_ID').value==''){
			msg = '\n 請輸入受理編號!';	
		}else if($('APPLY_ID').value.length!=11) {
			msg = '\n 輸入受理編號有誤！';
		}
		
		if($('REFER_ID').value!='' && $('REFER_ID').value.length!=10){
			msg = '\n 輸入前貸款帳號有誤！';
		}
		if(msg!=""){
			alert(msg);
			return;
		}
		
		/*if($F('OLD_APPLY_ID') && $F('OLD_APPLY_ID')!='' && $F('APPLY_ID') != $F('OLD_APPLY_ID')){
			$('REFER_ID').setValue('');
		}*/
		ajaxPost('query', 
				{ 
					'info' : Object.toJSON( $("form1").serialize( true )) 
				},
				successActionForQuery
		);

	};

	var doSubmit = function(){
		
		var insertRec = [];
		var checkedRecords = grid.getCheckedRecord();
		var checkCount = checkedRecords.size();

		//[2022-01-14]問題單20220114-0047：畫面中所有按鈕，卡控執行前都需要先進行案件「查詢」，由系統確認登入人員為鎖件人員才能執行。
		if($('OLD_APPLY_ID').value==''){
			alert('請先查詢再做送出!');
			return;
		}
		
		if($('OLD_APPLY_ID').value!='' && $('OLD_APPLY_ID').value!=$('APPLY_ID').value){
			alert('\n 欲作業的'+$('APPLY_ID').value+'與原先查詢的'+$('OLD_APPLY_ID').value+'不同,請重新查詢!');
			return;
		}
		
		if($('OLD_REFER_ID').value!='' && $('OLD_REFER_ID').value!=$('REFER_ID').value){
			alert('\n 欲作業的原貸款帳號'+$('REFER_ID').value+'與原先查詢的'+$('OLD_REFER_ID').value+'不同,請重新查詢!');
			return;
		}
		
		if(checkCount==0){
			alert('\n 請選取要送出查詢的資料!');
			return;
		}
		
		var msg = "";
		
		var cont = 0;
		var maxSEQ_NO = record_MAX_SEQ_NO;
		
		//取records
		$A(checkedRecords).each(function( rec ){
			var RADIO0_0 = rec.inputs.CHOICE_C.checked;
 			var RADIO0_1 = rec.inputs.CHOICE_F.checked;
 			var CITY_NAME = rec.inputs.CITY_NAME.value;
 			var LOCATION1 = rec.inputs.LOCATION1.value;
 			var LOCATION2 = rec.inputs.LOCATION2.value;
 			var LOCATION3 = rec.inputs.LOCATION3.value;
 			var NO = rec.inputs.NO.value;
 			var OWNER_CHECK = rec.inputs.OWNER_CHECK.checked;
 			var OWNER_ID = rec.inputs.OWNER_ID.value.toUpperCase();
 			var OWNER_NAME = rec.inputs.OWNER_NAME.value;
 			var ADDR_NO = rec.inputs.ADDR_NO.value;
 			var SEQ_NO = rec.inputs.SEQ_NO.value;
 			
 			if(SEQ_NO==''){
 				maxSEQ_NO++;
 				SEQ_NO = maxSEQ_NO;
 			//}else if(SEQ_NO>maxSEQ_NO){
 			//	maxSEQ_NO = SEQ_NO;
 			}
 			if(NO=='' && ADDR_NO==''){
 				msg += '\n 地(建)號與門牌號碼請擇一輸入!';
 				return;
 			}
 			if(ADDR_NO!=''){
 				cont++;
 			}
 			
 			if(OWNER_ID.length>0){
     			if(OWNER_ID.length==8 && !validation.checkUniSN(OWNER_ID)){
     				msg += '\n 1須為8碼法人統一編號格式或10碼自然人統一編號格式!';
     				return;
     			}else if(OWNER_ID.length==10 && !idCheck1(OWNER_ID)){
     				msg += '\n 2須為8碼法人統一編號格式或10碼自然人統一編號格式!';
     				return;
     			}else if(OWNER_ID.length!=10 && OWNER_ID.length!=8){
     				msg += '\n 3須為8碼法人統一編號格式或10碼自然人統一編號格式!';
     				return;
     			}
 			}
 			if(OWNER_ID.length==0 && !OWNER_CHECK){
 				msg += '\n 請確認要查詢的謄本為個人或是全部!';
 				return;
 			}
 			
 			if(NO!=''){
 				if(CITY_NAME=='' || LOCATION1=='' || LOCATION2==''){
     				msg += '\n 若有輸入地(建)號，則縣市、鄉鎮市區、段名';
     				if(!OWNER_CHECK && LOCATION3==''){
     					msg += '、小段名';
     				}
     				msg += '為必輸欄位!';
     				return;
 				}
 				
 				if(NO.length!=8 || isNaN('0'+NO+'0')){
     				msg += '\n 地(建)號格式輸入錯誤!';
     				return;
 				}
 			}
 			
 			var record = {};
 			record.APPLY_ID = $("APPLY_ID").value;
 			record.SEQ_NO = SEQ_NO;
 			if(RADIO0_0){
 				record.TYPE = "C";
 				record.NO1 = NO.substring(0,4);
 				record.NO2 = NO.substring(4);
 			}
 			if(RADIO0_1){
 				record.TYPE = "F";
 				record.NO1 = NO.substring(0,5);
 				record.NO2 = NO.substring(5);
 			}
 			record.CITY_NAME = CITY_NAME;
 			record.LOCATION1 = LOCATION1;
 			record.LOCATION2 = LOCATION2;
 			record.LOCATION3 = LOCATION3;
 			record.ADDR_NO = ADDR_NO;
 			record.OWNER_ID = OWNER_ID;
 			record.OWNER_NAME = OWNER_NAME;
 			record.OWNER_CHECK = OWNER_CHECK;
			insertRec.push(record);
 		});
		
		if(cont>0){
			msg += '\n 門牌查詢建號僅能單筆送出查詢!';
		}
		
		if(msg!=""){
			alert(msg);
			return;
		}
		
		if(confirm('請確認是否送出'+insertRec.length+'筆查詢?')){
			ajaxPost('submit', 
					{ 
						'jsonData' : Object.toJSON(insertRec), 
						'info' : Object.toJSON( $("form1").serialize( true )) 
					}, 
					successActionForQuery
			);
		}
		
	}
	
	var doImage = function(){

		popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
			'parameters': {'APPLY_ID': $F('APPLY_ID')},
			'fullScreen': false,
			'attributes': {'resizable': 'yes'}
		});
	}
	
	var doConfirm = function(){
		
		var insertRec = grid.getCheckedRecord();
		
		var msg = "";
		
		if($('OLD_APPLY_ID').value==''){
			msg = '請先查詢再做確認';
		}
		
		if($('OLD_APPLY_ID').value!='' && $('OLD_APPLY_ID').value!=$('APPLY_ID').value){
			msg += '\n 欲作業的'+$('APPLY_ID').value+'與原先查詢的'+$('OLD_APPLY_ID').value+'不同,請重新查詢!';	
		}
		
		if(msg!=""){
			alert(msg);
			return;
		}
		
		ajaxPost('confirm', 
				{ 
					'jsonData' : Object.toJSON(insertRec), 
					'info' : Object.toJSON( $("form1").serialize( true )) 
				}, 
				successActionForQuery
		);
	}
	
	var doInsert = function (){
		var allRec  = grid.getAllRecords();
		var index = allRec.length-1;
		var rec = allRec[index];
		
		var CITY_NAME = rec ? ( rec.inputs.CITY_NAME.value || '' ).trim() : '';
		var LOCATION1 = rec ? ( rec.inputs.LOCATION1.value || '' ).trim() : '';
		var LOCATION2 = rec ? ( rec.inputs.LOCATION2.value || '' ).trim() : '';
		var LOCATION3 = rec ? ( rec.inputs.LOCATION3.value || '' ).trim() : '';
		var NO = rec ? (rec.inputs.NO.value || '').trim() : '';
		var OWNER_ID = rec ? (rec.inputs.OWNER_ID.value.toUpperCase() || '').trim() : '';;
 		var OWNER_NAME = rec ? (rec.inputs.OWNER_NAME.value || '').trim() : '';;
 		var ADDR_NO = rec ? (rec.inputs.ADDR_NO.value || '').trim() : '';;
		
		grid.addRecords([{"NO":NO, "OWNER_ID":OWNER_ID, "OWNER_NAME":OWNER_NAME, "ADDR_NO":ADDR_NO,"APPLY_ID":$("APPLY_ID").value,"TYPE":"C","SEND_STATUS":"0","OWNER_CHECK":"0","CITY_NAME":CITY_NAME,"LOCATION1":LOCATION1,"LOCATION2":LOCATION2,"LOCATION3":LOCATION3}]);

		grid.resetDivHeight();
		PageUI.resize(true);
	};	
	
	var doReject = function (){
		//[2022-01-14]問題單20220114-0047：畫面中所有按鈕，卡控執行前都需要先進行案件「查詢」，由系統確認登入人員為鎖件人員才能執行。
		if($('OLD_APPLY_ID').value==''){
			alert('請先進行查詢');
			return;
		}
	
		if($('OLD_APPLY_ID').value!='' && $('OLD_APPLY_ID').value!=$('APPLY_ID').value){			
			alert('欲作業的'+$('APPLY_ID').value+'與原先查詢的'+$('OLD_APPLY_ID').value+'不同,請重新查詢!');
			return;
		}
		
		//var insertRec = grid.getCheckedRecord();	
		
		//if(!confirm('確定要將此件退件回服務中心?')){
		//	return ;
		//}
			
		popupWin.popup({									
				src : '${dispatcher}/DSA1_0803/prompt' ,
				scrolling : 'yes',	
				parameters : { 
					APPLY_ID: $F('APPLY_ID'),	
					KIND  	: '1', 	//退回服務中心
					SOURCE  : 'DSA1_0800'								
				},  	
				cb : function(obj){						
					//doQuery();
				}
			});		
			
		/*
		var conf = {};
		var url = "<%=dispatcher%>" + "/DSA1_0800/link1";
		conf.src = url;
		conf.width = document.body.scrollWidth*0.5;
		conf.height = document.body.scrollHeight*0.5;
		
		var oEvent = window.event ? window.event : e;
		conf.left = document.body.scrollLeft + oEvent.clientX - conf.width/2;
		conf.top = document.body.scrollTop + oEvent.clientY + 15;
		conf.scrolling = 'no';
		conf.isAdjWin = 'yes';
	      
		conf.parameters = Object.toJSON({"width":conf.width, "height":conf.height});
		var callbackFun = function(objs){
			if(objs){
				ajaxPost('reject', 
						{ 
							'jsonData' : Object.toJSON(insertRec), 
							'info' : Object.toJSON( $("form1").serialize( true )),
							'RETURN_REASON':objs 
						}, 
						successActionForQuery
				);
			}
		};
		hyperlinks.popup(conf, callbackFun);*/

	};	
	
	var doReject2 = function (){
		//[2022-01-14]問題單20220114-0047：畫面中所有按鈕，卡控執行前都需要先進行案件「查詢」，由系統確認登入人員為鎖件人員才能執行。
		if($('OLD_APPLY_ID').value==''){
			alert('請先進行查詢');
			return;
		}
			
		if($('OLD_APPLY_ID').value!='' && $('OLD_APPLY_ID').value!=$('APPLY_ID').value){			
			alert('欲作業的'+$('APPLY_ID').value+'與原先查詢的'+$('OLD_APPLY_ID').value+'不同,請重新查詢!');
			return;
		}
		
		popupWin.popup({									
				src : '${dispatcher}/DSA1_0803/prompt' ,
				scrolling : 'yes',	
				parameters : { 
					APPLY_ID: $F('APPLY_ID'),	
					KIND  	: '2', 	//電子補全通知
					SOURCE  : 'DSA1_0800'								
				},  	
				cb : function(obj){							
					
				}
			});						
	};	
	
	//取消取件Function
	var doCancelsTakes = function(){
		
		var msg = "";
		
		//[2022-01-14]問題單20220114-0047：畫面中所有按鈕，卡控執行前都需要先進行案件「查詢」，由系統確認登入人員為鎖件人員才能執行。
		if($('OLD_APPLY_ID').value==''){
			msg = '請先進行查詢';
		}
		
		if($('OLD_APPLY_ID').value!='' && $('OLD_APPLY_ID').value!=$('APPLY_ID').value){
			msg += '\n 欲作業的'+$('APPLY_ID').value+'與原先查詢的'+$('OLD_APPLY_ID').value+'不同,請重新查詢!';	
		}
		
		if(msg!=""){
			alert(msg);
			return;
		}
		
		var insertRec = grid.getCheckedRecord();

		ajaxPost('cancelsTakes', 
				{ 
					'jsonData' : Object.toJSON(insertRec), 
					'info' : Object.toJSON( $("form1").serialize( true )) 
				}, 
				successActionForQuery
		);
	};

	
	var doTransfer = function(){
		//[2022-01-14]問題單20220114-0047：畫面中所有按鈕，卡控執行前都需要先進行案件「查詢」，由系統確認登入人員為鎖件人員才能執行。
		if($('OLD_APPLY_ID').value==''){
			alert('請先進行查詢');
			return;
		}
		
		popupWin.popup({									
			src : '${dispatcher}/DSA1_0804/prompt' ,
			scrolling : 'yes',	
			parameters : { 
				APPLY_ID: $F('APPLY_ID'),	
							
			}
		});	
		
	}
	//--------------------------------------------------------------------------        
	//以下為UI() public method,放在 return 中        
	//--------------------------------------------------------------------------          
	return{                              
		//init Function for 初始整個UI Class                
		init:function(){                                        
				
			//產生 Grid 物件                
			grid = new TableUI(                         
				{                   				
					table: $('grid'),   //對應的table實體
					pageSize: 0,                   				
					allSortable:false,
					split: ['TEST1'],
					overDiv:false,
					autoCheckBox:{ 
						type:'checkbox',
						text:'選取',
						attrs:{width:"6%"} , 
						valueKey:'SEND_STATUS',
						disableRule:function(rec){
							return (rec.SEND_STATUS != 0 && rec.SEND_STATUS != '');
						}
					},
					beforeLoad:function(){
						$$('#grid table').each(  function(table){
							var line = 0;
							$(table).select('tr').each( function(tr){
								if(line === 0){
									$(tr).down('th').setAttribute("rowSpan" , "1");
								}else{
									$(tr).hide();
								}
								line++;	
							});		
						});
						
					},
					<%-- [20240723] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[  
						{header: '土地<br>建物',key: '',empty:"rowSpan_down"
	  	                },    
						{header: '縣市<br>鄉鎮市區',key: 'CUST_ID',empty:"rowSpan_down"
						},
						{header: '段名<br>小段名',key: 'CUST_NAME',empty:"rowSpan_down"
						},
						{header: '地(建)號',key: 'NO',empty:"rowSpan_down"
						}, 
						{header: '所有權人', attrs:{colSpan:2}, empty:"rowSpan_down"
						},
						{header: '門牌號碼', key: 'ADDR_NO',empty:"rowSpan_down"
						},
						{header: '送件狀態', key: 'SEND_STATUS_NM',empty:"rowSpan_down"
						},
						{header: '作業人員', key: 'CONFIRM_NM', empty:"rowSpan_down"
						},
						{header: '', key: 'TEST1',
	  	                 	render: function(record,value){
	  	                 		record.inputs = {};
	  	                 		
	                    		div = document.createElement('div');
	                    		////////////////////////
	            				var input_radio = document.createElement("input");
								input_radio.type = 'radio';
								input_radio.name = 'CHOICE_'+index;
								input_radio.id = 'CHOICE0_'+index;
								input_radio.value = 'C';
								
								record.inputs.CHOICE_C = input_radio;
								
	                    		div.appendChild(input_radio);
		                		input_radio.checked = record.TYPE=='C'?true:false;
		                		if(record.SEND_STATUS!='0'){
		                			input_radio.disabled='disabled';
		                		}
		                		
								textNode = document.createTextNode('土地');
	                    		div.appendChild(textNode);
	                    		
	                    		input_br = document.createElement("br");
	                    		div.appendChild(input_br);
	                    		////////////////////////
	            				var input_radio1 = document.createElement("input");
								input_radio1.type = 'radio';
								input_radio1.name = 'CHOICE_'+index;
								input_radio1.id = 'CHOICE1_'+index;
								input_radio1.value = 'F';
	                    		div.appendChild(input_radio1);
	                    		
	                    		record.inputs.CHOICE_F = input_radio1;
	                    		
								input_radio1.checked = record.TYPE=='F'?true:false;
		                		if(record.SEND_STATUS!='0'){
		                			input_radio1.disabled='disabled';
		                		}
								textNode = document.createTextNode('建物');
	                    		div.appendChild(textNode);
	                    		
	                    		return div;
			                	//return input_radio;
	  	                 	}
						},
						{header: '', key: 'TEST2',
							render: function(record,value){
	                    		div = document.createElement('div');
	                    		////////////////////////
	            				input_text = document.createElement("input");
								input_text.type = 'text';
								input_text.name = 'CITY_NAME';
								input_text.id = 'CITY_NAME';
								input_text.value = record.CITY_NAME?record.CITY_NAME:'';
								input_text.size=10;
								input_text.alt="ch";<%--[20240722]難字調整 --%>
								record.inputs.CITY_NAME = input_text;
								
	                    		div.appendChild(input_text);
		                		if(record.SEND_STATUS!='0'){
		                			input_text.disabled='disabled';
		                		}
		                		
	                    		input_br = document.createElement("br");
	                    		div.appendChild(input_br);
	                    		
	            				input_text = document.createElement("input");
								input_text.type = 'text';
								input_text.name = 'LOCATION1';
								input_text.id = 'LOCATION1';
								input_text.value = record.LOCATION1?record.LOCATION1:'';
								input_text.size=10;
								input_text.alt="ch";<%--[20240722]難字調整 --%>
								record.inputs.LOCATION1 = input_text;
								
	                    		div.appendChild(input_text);
		                		if(record.SEND_STATUS!='0'){
		                			input_text.disabled='disabled';
		                		}
	                    		return div;
	  	                 	}
						},
						{header: '', key: 'TEST3',
							render: function(record,value){
	                    		div = document.createElement('div');
	                    		////////////////////////
	            				input_text = document.createElement("input");
								input_text.type = 'text';
								input_text.name = 'LOCATION2';
								input_text.id = 'LOCATION2';
								input_text.value = record.LOCATION2?record.LOCATION2:'';
								input_text.size=10;
								input_text.alt="ch";<%--[20240722]難字調整 --%>
								record.inputs.LOCATION2 = input_text;
								
	                    		div.appendChild(input_text);
		                		if(record.SEND_STATUS!='0'){
		                			input_text.disabled='disabled';
		                		}
	                    		
	                    		input_br = document.createElement("br");
	                    		div.appendChild(input_br);
	                    		
	            				input_text = document.createElement("input");
								input_text.type = 'text';
								input_text.name = 'LOCATION3';
								input_text.id = 'LOCATION3';
								input_text.value = record.LOCATION3?record.LOCATION3:'';
								input_text.size=10;
								input_text.alt="ch";<%--[20240722]難字調整 --%>
								record.inputs.LOCATION3 = input_text;
								
	                    		div.appendChild(input_text);
		                		if(record.SEND_STATUS!='0'){
		                			input_text.disabled='disabled';
		                		}
	                    		
	                    		return div;
	  	                 	}
						},
						{header: '', key: 'TEST4',
							render: function(record,value){
	                    		div = document.createElement('div');
	                    		////////////////////////
	            				input_text = document.createElement("input");
								input_text.type = 'text';
								input_text.name = 'NO';
								input_text.id = 'NO';
								input_text.value = record.NO?record.NO:'';
								input_text.size=8;
								input_text.maxLength=8;
								
								record.inputs.NO = input_text;
								
	                    		div.appendChild(input_text);
	                    		Event.observe( input_text , 'blur', function(event){
	                    			node = Element.up( event.target , 'tr' );
	                    			tds = node.getElementsByTagName('TD');
	                    			v0 = record.inputs.NO.value;
									if(v0.indexOf('-')>=0){
										v0 = record.inputs.NO.value||'';
										v1 = v0.substring(0,v0.indexOf('-'))||'';
										v2 = v0.substring(v0.indexOf('-')+1)||'';
										ln1 = v1.length;
										ln2 = v2.length;
										ln3 = 4;
										ln4 = 4;
										if((ln1+ln2)<8){
											if(record.inputs.CHOICE_F.checked){
												ln3 = 5;
												ln4 = 3;
											}
											for (i=ln1; i<ln3; i++) {
												if((v1.length+v2.length)>=8){
													break;
												}
												v1 = '0' + v1;
											}
											for (i=ln2; i<ln3; i++) {
												if((v1.length+v2.length)>=8){
													break;
												}
												v2 = '0' + v2;
											}
										}
										record.inputs.NO.value = v1+v2;
									}else{
										v0 = record.inputs.NO.value||'';
										v1 = v0;
										v2 = '';
										ln1 = v1.length;
										ln2 = v2.length;
										ln3 = 4;
										ln4 = 4;
										if((ln1+ln2)<8){
											if(record.inputs.CHOICE_F.checked){
												ln3 = 5;
												ln4 = 3;
											}
											for (i=ln1; i<ln3; i++) {
												if((v1.length+v2.length)>=8){
													break;
												}
												v1 = '0' + v1;
											}
											for (i=ln2; i<ln4; i++) {
												if((v1.length+v2.length)>=8){
													break;
												}
												v2 = '0' + v2;
											}
											record.inputs.NO.value = v1+v2;
										}
										
									}
								} );
		                		if(record.SEND_STATUS!='0'){
		                			input_text.disabled='disabled';
		                		}
	                    		return div;
	  	                 	}
						},
						{header: '', key: 'TEST5',
							render: function(record,value){
	                    		div = document.createElement('div');
	                    		////////////////////////
	            				input_text = document.createElement("input");
								input_text.type = 'checkbox';
								input_text.name = 'OWNER_CHECK_'+index;
								input_text.id = 'OWNER_CHECK_'+index;
								input_text.value = record.OWNER_CHECK?record.OWNER_CHECK:'';
								input_text.size=10;
								
								record.inputs.OWNER_CHECK = input_text;
								
	                    		div.appendChild(input_text);
	                    		input_text.checked = record.OWNER_CHECK=='1'?true:false;
	                    		Event.observe( input_text , 'click', function(event){
	                    			if(this.checked && confirm('勾選全部請確認是否刪除所有權人資料?') ){
										record.inputs.OWNER_ID.value = '';
										record.inputs.OWNER_NAME.value = '';
									}else{
										this.checked = false;
									}
								} );
		                		if(record.SEND_STATUS!='0'){
		                			input_text.disabled='disabled';
		                		}
	                    		textNode = document.createTextNode('全部');
	                    		div.appendChild(textNode);
	                    		return div;
	  	                 	}
						},
						{header: 'empty', key: 'TEST6',
							render: function(record,value){
	                    		div = document.createElement('div');
	                    		////////////////////////
	            				input_text = document.createElement("input");
								input_text.type = 'text';
								input_text.name = 'OWNER_ID_'+index;
								input_text.id = 'OWNER_ID_'+index;
								input_text.value = record.OWNER_ID?record.OWNER_ID:'';
								input_text.size=10;
								
								record.inputs.OWNER_ID = input_text;
								
	                    		div.appendChild(input_text);
		                		if(record.SEND_STATUS!='0'){
		                			input_text.disabled='disabled';
		                		}
	                    		
	                    		input_br = document.createElement("br");
	                    		div.appendChild(input_br);
	                    		
	            				input_text = document.createElement("input");
								input_text.type = 'text';
								input_text.name = 'OWNER_NAME_'+index;
								input_text.id = 'OWNER_NAME_'+index;
								input_text.value = record.OWNER_NAME?record.OWNER_NAME:'';
								input_text.size=10;
								input_text.alt="ch";<%--[20240722]難字調整 --%>
								record.inputs.OWNER_NAME = input_text;
								
	                    		div.appendChild(input_text);
		                		if(record.SEND_STATUS!='0'){
		                			input_text.disabled='disabled';
		                		}
	                    		
	                    		return div;
	  	                 	}
						},
						{header: 'empty', key: 'TEST7',
							render: function(record,value){
	                    		div = document.createElement('div');
	                    		////////////////////////
	            				input_text = document.createElement("input");
								input_text.type = 'text';
								input_text.name = 'ADDR_NO';
								input_text.id = 'ADDR_NO';
								input_text.value = record.ADDR_NO?record.ADDR_NO:'';
								input_text.size=10;
								
								record.inputs.ADDR_NO = input_text;
								
	                    		div.appendChild(input_text);
		                		if(record.SEND_STATUS!='0'){
		                			input_text.disabled='disabled';
		                		}
		                		
		                		if(record.SEQ_NO && record.SEQ_NO>record_MAX_SEQ_NO){
		                		   record_MAX_SEQ_NO = record.SEQ_NO;
		                		}
	                    		
	            				input_text = document.createElement("input");
								input_text.type = 'hidden';
								input_text.name = 'SEQ_NO';
								input_text.id = 'SEQ_NO';
								input_text.value = record.SEQ_NO?record.SEQ_NO:'';
								input_text.size=10;
								
								record.inputs.SEQ_NO = input_text;
								
	                    		div.appendChild(input_text);
	                    		
	            				input_text = document.createElement("input");
								input_text.type = 'hidden';
								input_text.name = 'SEND_STATUS';
								input_text.id = 'SEND_STATUS';
								input_text.value = record.SEND_STATUS?record.SEND_STATUS:'';
								input_text.size=10;
								
								record.inputs.SEND_STATUS = input_text;
								
	                    		div.appendChild(input_text);
	                    		
	                    		return div;
	  	                 	}
						},
						{header: 'empty', key: 'TEST8',
							render:function(record,value){
							 	return record.SEND_STATUS_NM?record.SEND_STATUS_NM:'';
							}
						},
						{header: 'empty', key: 'TEST9', attrs:{style:"font-family:'EUDC'"}<%--[20240722]難字調整 --%>,
							render:function(record,value){
								index++;
							 	return record.CONFIRM_NM?record.CONFIRM_NM:'';
							}
						}
					]									
				}                 
			);
			
			if(!grid.isNew){
				$('grid').down('thead').down('th').setAttribute("rowSpan" , "1");
				$('grid').down('thead').select('tr')[1].hide();
			}else{
				$$('#grid table').each(  function(table){
					var line = 0;
					$(table).select('tr').each( function(tr){
						if(line === 0){
							$(tr).down('th').setAttribute("rowSpan" , "1");
						}else{
							$(tr).hide();
						}
						line++;	
					});		
				});
			}
			
			
			//查詢 button click event                        
			$('btn_query').observe('click',function(event){
					columnToUpperCase('APPLY_ID');
					doQuery();					
				}                        
			); 
			//新增 button click event                        
			$('btn_insert').observe('click',function(event){                                        
					columnToUpperCase('APPLY_ID');
					doInsert(); 
				}                        
			);
			//退回 button click event                        
			$('btn_reject').observe('click',function(event){                                        
					columnToUpperCase('APPLY_ID');
					doReject(); 
				}                        
			);
			//退回 button click event                        
			$('btn_reject2').observe('click',function(event){                                        
					columnToUpperCase('APPLY_ID');
					doReject2(); 
				}                        
			);
			//取消取件 button click event                        
			$('btn_cancels_takes').observe('click',function(event){                                        
					columnToUpperCase('APPLY_ID');
					doCancelsTakes(); 
				}                        
			);
			//確認 button click event                        
			$('btn_confirm').observe('click',function(event){                                        
					columnToUpperCase('APPLY_ID');
					doConfirm(); 
				}                        
			);
			//所有權狀影像 button click event                        
			$('btn_image').observe('click',function(event){                                        
					columnToUpperCase('APPLY_ID');
					doImage(); 
				}                        
			);
			//送出 button click event                        
			$('btn_submit').observe('click',function(event){                                        
					columnToUpperCase('APPLY_ID');
					doSubmit(); 
				}                        
			);
			
			//案件移轉 button click event                        
			$('btn_transfer').observe('click',function(event){                                        
					columnToUpperCase('APPLY_ID');
					doTransfer(); 
				}                        
			);

			if ('${APPLY_ID}' != "") {//接值
				$('APPLY_ID').value = '${APPLY_ID}';
				$('REFER_ID').value = '${REFER_ID}';
			} else { 
				//保留參數管理-取得受理編號
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
				$('REFER_ID').value = CSRUtil.keepParamsManager.get('REFER_ID');
			}			
			if($('APPLY_ID').value){
				doQuery();
			}
			//避免因查詢下一件時未將上一件的前貸款帳號清除，造成上一件的前貸款帳號在送出時被寫進此受理案件的a010，造成日後自動歸檔錯誤，故在受理編號異動時清除前貸款帳號
			$('APPLY_ID').observe('change', function(){
				$('REFER_ID').setValue('');
			});

		}//end init()--                        
	}//end return--        /
	//-------------------------------------------------------------------------- 
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >


									<form id="form1" name="form1" method="post">	
									<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="areaA">
										<tr>
											<td class="tbYellow" width="10%" align="center">
												受理編號
											</td>
											<td class="tbYellow2">
												<input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2" size="15" maxlength="11" value="">
												<input type="hidden" id="OLD_APPLY_ID" name="OLD_APPLY_ID" value=""/>
											</td>
											<td class="tbYellow" width="10%" align="center">
												前貸款帳號
											</td>
											<td class="tbYellow2">
												<input id="REFER_ID" name="REFER_ID" type="text" class="textBox2" size="15" maxlength="10" value="">
												<input type="hidden" id="OLD_REFER_ID" name="OLD_REFER_ID" value=""/>
											</td>
											<td class="tbYellow2" align="left">
												<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
												<input id="btn_image" name="btn_image" type="button" class="button" value="所有權狀影像">
											</td>
										</tr>
										<tr>
											<td width="100%" align="center" colspan="5" class="tbYellow2">
												<input id="btn_insert" name="btn_insert" type="button" class="button" value="新增"> 
												<input id="btn_submit" name="btn_submit" type="button" class="button" value="送出"> 
												<input id="btn_cancels_takes" name="btn_cancels_takes" type="button" class="button" value="取消取件">
												<input id="btn_confirm" name="btn_confirm" type="button" class="button" value="到謄本確認">
												<input id="btn_reject" name="btn_reject" type="button" class="button" value="退回服務中心"> 
												<input id="btn_reject2" name="btn_reject" type="button" class="button" value="電子補全通知">
												<input id="btn_transfer" name="btn_transfer" type="button" class="button" value="案件轉移">
											</td>
										</tr>
									</table>
									</form>
									
									<table id="grid" class="grid"></table>
									
									

</body>
<!-- InstanceEnd -->
</html>
