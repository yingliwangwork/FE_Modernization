<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA10900.jsp
作者：i9100606
功能：同一關係人確認資料
完成：2011/09/16
更新：
[20250207]問題單:20250206091850
該頁面之全選選項無法取到次頁的資料，故點選確認按鈕時會失敗，驗測時請確保隔頁資料能全部"確認"
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
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

var valid1;
var grid = {};
var grid1 = {};

function initApp(){

	cleanMsgBoard();

	buttonAuth();
	valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
	Validation.addAllThese([
		[ 'chkAPPLY_ID',  '請輸入受理編號!', function(){ if($('QUERY_TYPE_0').checked && $F('APPLY_ID') === ""){ return false; } $('APPLY_ID').value=$F('APPLY_ID').toUpperCase(); return true; } ] ,
		[ 'validateAPPLY_ID',  '請輸入正確受理編號!', function(){ if($('QUERY_TYPE_0').checked && $F('APPLY_ID').length != 11){ return false; } $('APPLY_ID').value=$F('APPLY_ID').toUpperCase(); return true; } ] ,
		[ 'validateCUST_ID',  '請輸入歸戶ID!', function(){ if($('QUERY_TYPE_1').checked && $F('CUST_ID') === ""){ return false; } $('CUST_ID').value=$F('CUST_ID').toUpperCase(); return true; } ] ,
		[ 'validateNAME',  '請輸入全型字!', function(v){
				
				if($('isQuery').value != 'Y' && validation.hasHalfType(v)) {
					return false;
				} 
				return true; 
			}
		] ,
		[ 'validateRequired',  '不可空白', function(v){
				if($('isQuery').value != 'Y' && v==''){
					return false;
				}
				return true;
			}
		] ,
		['validateSelection', '請選擇', function(v,elm){
				if($('isQuery').value != 'Y'){
					return !Validation.get('IsEmpty').test(v) || elm.selectedIndex > 0;
				}
				return true;
			}
		],
		/*[ 'validateUsableID',  '請輸入正確ID', function(v){ 
			if($('QUERY_TYPE_1').checked){ 
				if(v.length == 8){ 
					//return iscmpid(v) 
					return validation.checkUniSN(v);
				}else{
					//return (/^[A-Z]\d{9}$/).test(v)	;
					return idCheck1(v);
				} 
			} 
			return true; } ],*/
		[ 'chkUsableID',  '請輸入正確ID', function(v){
			if($('isQuery').value != 'Y'){
				if(v.length == 8){ 
					return validation.checkUniSN(v); 
				}else{ 
					return idCheck1(v); 
				}
			}  return true; 
		} ] 

	]);
	
	PageUI.createPage("DSA10900" , "受理作業" , "同一關係人確認資料");
	PageUI.loadin(["tableA","grid","tableB","grid1","tableC"] ,1);
	//PageUI.createPageWithAllBodySubElement("DSA10900" , "受理作業" , "同一關係人確認資料", 1,'${titleNotDisplay}' == 'Y');
	
	//TableUI的產生        
	new UI().init();        

	PageUI.resize(true);
   
}

<%--
	button控制
--%>
function buttonAuth(){
	var authButtons = {
		B0001:"btn_query",
		B0003:"btn_insert",   			
		B0004:"btn_update",
		B0005:"btn_delete",
		B0028:"btn_confirm"
	};
	<dz:grantButtons FUNC_ID="DSA10900" ignored="true"/> 	
}

function checkAll(){
	var chk = $('CHECK_ALL').checked;
	$$('#grid input[type="radio"]').each(function(checkbox){
		if(chk && checkbox.value=='0'){
			checkbox.checked = true;
			checkbox.click();
		}else if(!chk && checkbox.value=='1'){
			checkbox.click();
			checkbox.checked = false;
			//確認 button click event                        
			$('btn_confirm').disabled=true;
			
		}
	});
	<%--[20250207]修正選項無法取到次頁的資料--%>
	var records = grid.getAllRecords();
	records.each(function(rec){
		rec.isSelect = chk;
	});
};

//--------------------------------------------------------------------------  
<%--全域 函數 UI 與 畫面 公用 End----------------------------------------------------%>

<%--Define UI Class Start-------------------------------------------------------%>
function UI(){                
	//--------------------------------------------------------------------------          
	//UI() private variable        
	//--------------------------------------------------------------------------             
	var validator;        
	var prod;
	var lastRow;
	var checkboxControl = false;
	var index = 0;
	
	//--------------------------------------------------------------------------          
	//UI() private method        
	//--------------------------------------------------------------------------          
	//***        
	
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA1_0900/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	    	onSuccess: successAction
		});
	}      
	
	//AJAX SuccessAction For Query

	function successActionForQuery(XHT, resp) {
		if(CSRUtil.isSuccess(resp)){
			if($('QUERY_TYPE_1').checked){
				$('grid').hide();
			}else{
				$('grid').show();
			}
			//index = 0;
			
			$('qryAPPLY_ID').value=$('APPLY_ID').value;
			
			initTables();
			
			grid.load(resp.unChkRList || []);
			grid1.load(resp.chkRList || []);
			$("lawINFO").innerHTML=resp.lawINFO?resp.lawINFO:"";			
			actionDisable('2');
			$$('#grid1 input[type="radio"]').each(function(checkbox){
				if($('QUERY_TYPE_1').checked){
					checkbox.disabled = false;
				}else{
					checkbox.disabled = true;
				}
			});
			$('isQuery').value = '';
			grid.resetDivHeight();
			grid1.resetDivHeight();
			parseEUDC();<%--[20240723]難字調整--%>
		} else{
			if($F('isQuery')==='Y'){
				grid.load([]);
				grid1.load([]);
				if($('QUERY_TYPE_1').checked){
					grid1.addRecords([{}]);
				}
				$("lawINFO").innerHTML = '';
			}
			grid.resetDivHeight();
			grid1.resetDivHeight();
		}
		PageUI.resize(true);
	}		
	function actionDisable(data_type) {

			if('0'==data_type){
				//新增 button click event                        
				$('btn_insert').disabled=true;
				//刪除 button click event                        
				$('btn_delete').disabled=true;
				//修改 button click event                        
				$('btn_update').disabled=true;
				//確認 button click event                        
				$('btn_confirm').disabled=false;
				var allRec  = grid1.getAllRecords();
				if(allRec.length>0){
					grid1.load(allRec);
					$$('#grid1 input[type="radio"]').each(function(checkbox){
						if($('QUERY_TYPE_1').checked){
							checkbox.disabled = false;
						}else{
							checkbox.disabled = true;
						}
					});
				}
				grid.resetDivHeight();
				grid1.resetDivHeight();
			}else if('1'==data_type){
				//新增 button click event                        
				$('btn_insert').disabled=false;
				//刪除 button click event                        
				$('btn_delete').disabled=false;
				//修改 button click event                        
				$('btn_update').disabled=false;
				//確認 button click event                        
				$('btn_confirm').disabled=true;
				var allRec  = grid.getAllRecords();
				if(allRec.length>0){
					//grid.load(allRec);
				}
			}else if('3'==data_type){
				//新增 button click event                        
				$('btn_insert').disabled=false;
				//刪除 button click event                        
				$('btn_delete').disabled=true;
				//修改 button click event                        
				$('btn_update').disabled=true;
				//確認 button click event                        
				$('btn_confirm').disabled=true;	
			}else {
				//新增 button click event                        
				$('btn_insert').disabled=true;
				//刪除 button click event                        
				$('btn_delete').disabled=true;
				//修改 button click event                        
				$('btn_update').disabled=true;
				//確認 button click event                        
				$('btn_confirm').disabled=true;	
			}
		
	}
	
	//查詢Function       
	var doQuery = function(){
		$('isQuery').value = 'Y';
		if($F('CUST_ID') && !validation.checkUniSN($F('CUST_ID')) && !idCheck1($F('CUST_ID')) &&!confirm('輸入ID不符合身份證字號/統編規則，確認用此ID查詢？')){
			return;
		}
		
		modifyClassName();
		
		valid1.reset();
		
		if(!valid1.validate()){
			grid.resetDivHeight();	
			return;
		}
		ajaxPost('query', 
				{
					'info' : Object.toJSON( $("form1").serialize( true )) 
				}, 
				successActionForQuery
		);

	};
	
	var doImage = function(){
		var msg='';
		if($('APPLY_ID').value==''){
			msg = '\n 請輸入受理編號!';	
		}else if($('APPLY_ID').value.length!=11) {
			msg = '\n 輸入受理編號有誤！';
		}
		if(msg!=""){
			alert(msg);
			return;
		}
		popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
			'parameters': {'APPLY_ID': $F('APPLY_ID')},
			'fullScreen': false,
			'attributes': {'resizable': 'yes'}
		});
	}
	
	var doConfirm = function(){
		var msg = "";
		modifyClassName();
		if($('APPLY_ID').value==''){
			msg = '\n 請輸入受理編號!';	
		}else if($('APPLY_ID').value.length!=11) {
			msg = '\n 輸入受理編號有誤！';
		}
		
		valid1.reset();
		if(!valid1.validate()){
			grid.resetDivHeight();	
			return;
		}
		
		
		if(msg!=""){
			alert(msg);
			return;
		}
		
		if($('qryAPPLY_ID').value!=$('APPLY_ID').value){
			msg = '\n 欲作業的受理編號:'+$('APPLY_ID').value+'與原先查詢的受理編號:'+$('APPLY_ID').value+'不同，無法作業!';	
		}
		
		
		if(msg!=""){
			alert(msg);
			return;
		}
		
		var allRec  = grid.getAllRecords();
		var insertRec = [];
		var ind = 0;
		for(var i = 0; i < allRec.length; i++){
			var isSelect = allRec[i].isSelect;		
		
			if(typeof isSelect != 'boolean'){	
				continue;
			}
			/*
			if(!$('CHOICE0_'+i).checked && !$('CHOICE1_'+i).checked){
				continue;
			}*/
			var record = allRec[i];
			/*
			msg = checkValue(record);
			if(msg!=""){
				alert(msg);
				return;
			}
			*/
			
			
			if(isSelect){
				record.CHOICE = '0';
			}else{
				record.CHOICE = '1';
			}
			
			if(record.RELATION_ID){
				record.RELATION_ID = record.RELATION_ID.toUpperCase();
			}
			<%-- [20240722]難字欄位取值 CUST_NAME RELATION_NAME [20250207]改在tableUI input綁blur event設值--%> 			
			insertRec[ind] = record;
			ind++;
		}
		
		if(ind==0){
			alert("請選擇確認資料");
			return;
		}
		
		if (ind != allRec.length){
			alert("請完成全部資料確認!!");
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
	
	/*新增*/
	var doInsert = function (){
		modifyClassName();
		var insertRec = grid1.getCheckedRecord();
		
		if(insertRec==''){
			return alert('請選擇新增資料');
		}

		var record = insertRec[0];
		if(record.RELATION_ID){
			record.RELATION_ID = record.RELATION_ID.toUpperCase();
		}
		<%-- [20240722]難字欄位取值 CUST_NAME RELATION_NAME [20250207]改在tableUI input綁blur event設值--%> 
		var msg=''; //= checkValue(record);
		if($('CUST_ID').value==''){
			msg = '\n 請輸入歸戶ID!';	
		}

		if(msg!=""){
			alert(msg);
			return;
		}

		valid1.reset();
		if(!valid1.validate()){
			return;
		}

		ajaxPost('insert', 
				{ 
					'jsonData' : Object.toJSON([record]), 
					'info' : Object.toJSON( $("form1").serialize( true )) 
				}, 
				successActionForQuery
		
		);
	};	
	
	/*修改*/
	var doUpdate = function (){
		modifyClassName();
		var insertRec = grid1.getCheckedRecord();
		
		if(insertRec==''){
			return alert('請選擇修改資料');
		}
		var record = insertRec[0];
		if(record.RELATION_ID){
			record.RELATION_ID = record.RELATION_ID.toUpperCase();
		}
		<%-- [20240722]難字欄位取值 CUST_NAME RELATION_NAME [20250207]改在tableUI input綁blur event設值--%> 
		var msg = '';//checkValue(record);
		
		if($('CUST_ID').value==''){
				msg = '\n 請輸入歸戶ID!';	
		}
		
		if(msg!=""){
			alert(msg);
			return;
		}
		
		valid1.reset();
		if(!valid1.validate()){
			return;
		}		

		ajaxPost('update', 
				{ 
					'jsonData' : Object.toJSON([record]), 
					'info' : Object.toJSON( $("form1").serialize( true )) 
				}, 
				successActionForQuery
		);
		
	};	
	
	//刪除Function
	var doDelete = function(){		
		modifyClassName();
		var insertRec = grid1.getCheckedRecord();
		
		if(insertRec==''){
			return alert('請選擇刪除資料');
		}
		
		var record = insertRec[0];
		if(record.RELATION_ID){
			record.RELATION_ID = record.RELATION_ID.toUpperCase();
		}
		

		if(confirm('確定刪除?')){ 
			ajaxPost('delete', 
					{ 
						'jsonData' : Object.toJSON([record]), 
						'info' : Object.toJSON( $("form1").serialize( true )) 
					}, 
					successActionForQuery
			);
		}		
	};
	
	function modifyClassName(){		
		if($F('isQuery')=='Y'){
			//textBox validateCUST_ID validateUsableID
			$('CUST_ID').className='text2 validateCUST_ID';
		}else{
			$('CUST_ID').className='text2 validateCUST_ID';
		}
	}
	/*
	var checkValue = function(record){
		var msg = '';
		if(!record.CUST_NAME || record.CUST_NAME==''){
			msg += '\n 請輸入歸戶姓名';
		}
		if(!record.RELATION_ID || record.RELATION_ID==''){
			msg += '\n 請輸入關係人ID';
		}
		if(!record.RELATION_NAME || record.RELATION_NAME==''){
			msg += '\n 請輸入關係人姓名';
		}
		if(!record.RELATION_KD || record.RELATION_KD==''){
			msg += '\n 請選擇關係種類';
		}
		if(!record.RELATION_CODE || record.RELATION_CODE==''){
			msg += '\n 請選擇關係代號';
		}
		if(!record.ROLE_CODE || record.ROLE_CODE==''){
			msg += '\n 請選擇稱謂/職位';
		}

		return msg;
	};
	*/
	function replaceSlash(node, template){
		
        var tempMap = new Hash();
		for(var i = 0 ; i < template.length ; i = i + 1  ){
			tempMap.set(template[i],true);
		}
                       
        var TR = node;                            
        var tds = []; 
		do{
			tds = TR.getElementsByTagName('TD');
			for(var i = 0 ; i < tds.length ; i = i + 1  ){
				
				if(tds[i].childNodes && tds[i].childNodes.length > 0 && tds[i].childNodes[0].name == 'inputData'){
					if( tempMap.get(tds[i].name) ){
						var input = tds[i].getElementsByTagName("input");											
						input[0].value = input[0].value.replace(/[/]/gi,'');
					}
				}
			}
			TR = TR.nextSibling;
		}while( TR && TR.split );
	}
	
	function initTables(){
	
		//產生 Grid 物件                
			grid = new TableUI(                         
				{                   				
					table: $('grid'),   //對應的table實體                   				
					allSortable:false,	
					<%-- [20240722] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						<%--[20250207]如全選，換頁也要勾選--%>
						var chk = $('CHECK_ALL').checked;
						$$('#grid input[type="radio"]').each(function(checkbox){
							if(chk && checkbox.value=='0'){
								checkbox.checked = true;
								checkbox.click();
							}
						});
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[  
						{header: '全選<input type="checkbox" name="CHECK_ALL" id="CHECK_ALL"/>',key: '',
	  	                 	render: function(record,value, sn){	  
	                    		var div = document.createElement('div');
	                    		////////////////////////
	            				var input_radio = document.createElement("input");
								input_radio.type = 'radio';
								input_radio.name = 'CHOICE_'+index;
								input_radio.id = 'CHOICE0_'+index;
								input_radio.value = '0';
		                		//input_radio.checked = true;
								Event.observe( input_radio , 'click', function(event){		
									record.isSelect = true;
									actionDisable('0');
									if(input_radio.value=='0'){
										// node一開始是點選的cell，因為record會存在TR中，所以node要向上取到TR                             		                            
										var node = Element.up( event.target , 'tr' );
										tds = node.getElementsByTagName('TD');

										if(tds[2].childNodes[0].style.display=='none'){
											return;
										}

			                            //將該TR有設定input的欄位顯示/隱藏
			                            //node -整列TR obj, array-包含要換的key值
			                            grid.exchangeAutoInput( node, ['CUST_NAME','RELATION_ID','RELATION_NAME','RELATION_KD','RELATION_CODE','ROLE_CODE']);	
			                            
			                            replaceSlash(node, ['CUST_NAME','RELATION_ID','RELATION_NAME']);
			                            valid1.reset();
			                            
			                            grid.resetDivHeight();
		                            }
								});
								
								var textNode = document.createTextNode('是');
	                    		div.appendChild(textNode);
	                    		div.appendChild(input_radio);
	                    		////////////////////////
	            				var input_radio1 = document.createElement("input");
								input_radio1.type = 'radio';
								input_radio1.name = 'CHOICE_'+index;
								input_radio1.id = 'CHOICE1_'+index;
								input_radio1.value = '1';
		                		//input_radio1.checked = false;
								Event.observe( input_radio1 , 'click', function(event){
									record.isSelect = false;
									actionDisable('0');
									if(input_radio1.value=='1'){
										// node一開始是點選的cell，因為record會存在TR中，所以node要向上取到TR                             		                            
										var node = Element.up( event.target , 'tr' );
										tds = node.getElementsByTagName('TD');

										if(tds[2].childNodes[0].style.display==''){
											return;
										}
		                            	<%-- [20240722]難字調整--%>
		                            	record.CUST_NAME = $('grid').select("[name='autoInput_CUST_NAME_"+sn+"']")[0].getValue();
		                            	record.RELATION_NAME = $('grid').select("[name='autoInput_RELATION_NAME_"+sn+"']")[0].getValue();
	                                	$('CUST_NAME_'+sn).update(record.CUST_NAME || '');
	                                	$('RELATION_NAME_'+sn).update(record.RELATION_NAME || '');
	                                	parseEUDC();
			                            
			                            //將該TR有設定input的欄位顯示/隱藏
			                            //node -整列TR obj, array-包含要換的key值
			                            grid.exchangeAutoInput( node, ['CUST_NAME','RELATION_ID','RELATION_NAME','RELATION_KD','RELATION_CODE','ROLE_CODE']);	
			                            
			                            replaceSlash(node, ['CUST_NAME','RELATION_ID','RELATION_NAME']);
			                            
			                            valid1.reset();
			                            
			                            grid.resetDivHeight();
		                            }
								});
								textNode = document.createTextNode('否');
	                    		div.appendChild(textNode);
	                    		div.appendChild(input_radio1);
								index++;						
								
								var isSelect = record.isSelect ;
								if(isSelect){
									input_radio.checked=true;
								}else{
									if(typeof isSelect == 'boolean'){
										input_radio1.checked=true;
									}
									
								}
	                    		return div;
			                	//return input_radio;
	  	                 	}
	  	                },    
						{header: '歸戶ID',key: 'CUST_ID'
						},
						{header: '歸戶姓名',key: 'CUST_NAME',
		                	input:{
								type:'TEXT',
								size:12,
								maxlength:30,
	                            genRule:function(record , value){	
									var isSelect = record.isSelect;
	                                return !!isSelect;
	                            },
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 
		                        	if(!isOnChange){
										node.id = node.name +'_'+index; 	
										node.setAttribute("className" , "validateRequired validateNAME");
										node.setAttribute("alt" , "ch"); <%--[20240722]難字調整--%>
										<%--[20250207]修正難字不觸發action--%>
										node.observe('blur', function(){
				                			var val = this.value;
				                			dataObj[0].CUST_NAME = val;
				                		});	
									}				
								}, actionWhenStart:true
		                	},
		                	render:function(rec,val, sn){
							 	var span = new Element('span', {id:'CUST_NAME_'+sn, style: "font-family:'EUDC'"}).update(val);	<%--[20240722]難字調整 --%>
							 	return span;
							}
						},
						{header: '歸戶姓名(舊)',key: 'OLD_CUST_NAME',
							render:function(rec,val){
							 	if(!val){ return ""; }
							 	<%--[20240722]難字調整 --%>
							 	var span = new Element('span', {style: "font-family:'EUDC'"}).update(val);	
							 	if(rec.OLD_CUST_NAME != rec.CUST_NAME){	
							 		span.style.color = "red";
							 	}
							 	return span;
							}
						}, 
						{header: '關係人ID',key: 'RELATION_ID',
		                	input:{
								type:'TEXT',
								size:12,
								maxlength:10,
	                            genRule:function(record , value){
	                                var isSelect = record.isSelect;
	                                return !!isSelect;
	                            },
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 			                        	
									if(!isOnChange){ 			                        	
										node.id = node.name +'_'+index; 	
										node.setAttribute("className" , "validateRequired chkUsableID");
									}				
								}, actionWhenStart:true
		                	}
						},
						{header: '關係人姓名', key: 'RELATION_NAME', 
		                	input:{
								type:'TEXT',
								size:12,
								maxlength:30,
	                            genRule:function(record , value){
	                                var isSelect = record.isSelect;
	                                return !!isSelect;
	                            },
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){
		                        	if(!isOnChange){ 			                        	
										node.id = node.name +'_'+index; 	
										node.setAttribute("className" , "validateRequired validateNAME");
										node.setAttribute("alt" , "ch"); <%--[20240722]難字調整--%>
										<%--[20250207]修正難字不觸發action--%>
										node.observe('blur', function(){
				                			var val = this.value;
				                			dataObj[0].RELATION_NAME = val;
				                		});	
									}				
								}, actionWhenStart:true
		                	},
		                	render:function(rec,val,sn){
							 	var span = new Element('span', {id:'RELATION_NAME_'+sn, style: "font-family:'EUDC'"}).update(val);	<%--[20240722]難字調整 --%>
							 	return span;
							}
						},
						{header: '關係人姓名(舊)', key: 'OLD_RELATION_NAME', 
							render:function(rec,val){
							 	if(!val){ return ""; }
							 	<%--[20240722]難字調整 --%>
							 	var span = new Element('span', {style: "font-family:'EUDC'"}).update(val);								 	
							 	if(rec.OLD_RELATION_NAME != rec.RELATION_NAME){
							 		span.style.color = "red";
							 	}
							 	return span;
							}
						},
						{header: '關係種類', key: 'RELATION_KD',
							render:function(rec,val){
							 	if(!rec.RELATION_KD_NM){ return ""; }
							 	return rec.RELATION_KD_NM;
							},
							input:{
								type:"select" ,
								opts:{"":"請選譯" <c:forEach  var="item" items="${RelationKDList}">,"${item.key}":"${item.value}"</c:forEach > },								
								genRule:function(rows , value){
									var isSelect = rows.isSelect;
	                                return !!isSelect;
								},
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 	
									var NM = node.options[node.selectedIndex].text;									
									$(textDiv).update( NM );							
									if(!isOnChange){ 			                        	
										node.id = node.name +'_'+index; 	
										node.setAttribute("className" , "validateSelection");
									}				
								}, actionWhenStart:true
							}
						},
						{header: '關係種類(舊)', key: 'OLD_RELATION_KD_NM',
							render:function(rec,val){
							 	if(!val){ return ""; }
							 	if(rec.OLD_RELATION_KD_NM != rec.RELATION_KD_NM){
							 		return "<font color='red'>"+val+"</font>";
							 	}
							 	return val;
							}
						},
						{header: '關係代號', key: 'RELATION_CODE',
							render:function(rec,val){
							 	if(!rec.RELATION_CODE_NM){ return ""; }
							 	return rec.RELATION_CODE_NM;
							},
							input:{
								type:"select" ,
								opts:{"":"請選譯" <c:forEach  var="item" items="${RelationCodeList}">,"${item.key}":"${item.value}"</c:forEach > },								
								genRule:function(rows , value){
									var isSelect = rows.isSelect;
	                                return !!isSelect;
								},
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 		
									var NM = node.options[node.selectedIndex].text;									
									$(textDiv).update( NM );
									if(!isOnChange){ 			                        	
										node.id = node.name +'_'+index;
										node.setAttribute("className" , "validateSelection");
									}				
								}, actionWhenStart:true
							}
						},
						{header: '關係代號(舊)', key: 'OLD_RELATION_CODE_NM',
							render:function(rec,val){
							 	if(!val){ return ""; }
							 	if(rec.OLD_RELATION_CODE_NM != rec.RELATION_CODE_NM){
							 		return "<font color='red'>"+val+"</font>";
							 	}
							 	return val;
							}
						},
						{header: '稱謂/職位', key: 'ROLE_CODE',
							render:function(rec,val){
							 	if(!rec.ROLE_CODE_NM){ return ""; }
							 	return rec.ROLE_CODE_NM;
							}, 
							input:{
								type:"select" ,
								opts:{"":"請選譯" <c:forEach  var="item" items="${RoleCodeList}">,"${item.key}":"${item.value}"</c:forEach > },								
								genRule:function(rows , value){
									var isSelect = rows.isSelect;
	                                return !!isSelect;
								},
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){
									var NM = node.options[node.selectedIndex].text;									
									$(textDiv).update( NM );
									if(!isOnChange){ 
										node.id = node.name +'_'+index;	
										node.setAttribute("className" , "validateSelection");
									}				
								}, actionWhenStart:true
							}
						},
						{header: '稱謂/職位(舊)', key: 'OLD_ROLE_CODE_NM',
							render:function(rec,val){
							 	if(!val){ return ""; }
							 	if(rec.OLD_ROLE_CODE_NM != rec.ROLE_CODE_NM){
							 		return "<font color='red'>"+val+"</font>";
							 	}
							 	return val;
							}
						}
					]						
				}                 
			);
			
			grid1 = new TableUI(                         
				{                   				
					table: $('grid1'),   //對應的table實體                   				
					allSortable:false,
					<%-- [20240722] 難字調整 --%>
					afterLoad: function() {
						lastRow = '';
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						lastRow = '';
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					autoCheckBox:{ type:'radio',text:'選取',attrs:{width:"6%"},
						action: function (checkbox , boxStatus , records) {							
							//把上一次的input欄位隱藏
							index = 0;	
							if(lastRow){								
								 grid1.exchangeAutoInput( lastRow, ['RELATION_ID','RELATION_NAME','CUST_NAME','RELATION_CODE','RELATION_KD','ROLE_CODE']);								 	
							}
						
							var node = checkbox;
                            // node一開始是點選的cell，因為record會存在TR中，所以node要向上取到TR                             
                            while( node.tagName != 'TR' ) { 
                                node = node.parentNode;
                            }
							<%-- [20240722]難字調整--%>
                            if(!boxStatus){
                            	var sn = node.getAttribute('sn');
                            	records[0].CUST_NAME = $('grid1').select("[name='autoInput_CUST_NAME_"+sn+"']")[0].getValue();
                            	records[0].RELATION_NAME = $('grid1').select("[name='autoInput_RELATION_NAME_"+sn+"']")[0].getValue();
                            	$('CUST_NAME_'+sn).update(records[0].CUST_NAME || '');
                            	$('RELATION_NAME_'+sn).update(records[0].RELATION_NAME || '');
                            	parseEUDC();
                            }  
                                
                            //將該TR有設定input的欄位顯示/隱藏
                            //node -整列TR obj, array-包含要換的key值
                            grid1.exchangeAutoInput( node, ['RELATION_ID','RELATION_NAME','CUST_NAME','RELATION_CODE','RELATION_KD','ROLE_CODE']);	
                            
                            replaceSlash(node, ['RELATION_ID','RELATION_NAME','CUST_NAME']);
                            
                            lastRow = node;		
                            
                            //btnsControl();
                            //若已確認資料中，沒有歸戶ID＝＝>此筆資料為最後一筆，用來新增資料使用，將修改、刪除按鈕disabled                            	
                            if(records[0].CUST_ID){
                            	actionDisable('1');
                            }else{
                            	actionDisable('3');
                            }                          
                            
                            grid1.resetDivHeight();
						}
					},
					column:[           
						{header: '關係人ID',key: 'RELATION_ID',
							render:function(rec,val){
							 	if(!val){ return ""; }
							 	return val;
							},
		                	input:{
								type:'TEXT',
								size:12,
								maxlength:10,														
	                            genRule:function(record , value){
	                                return false;
	                            },
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 			                        	
									if(!isOnChange){ 	
										index = index + 1;		                        	
										node.id = node.name +'_'+index; 	
										node.setAttribute("className" , "validateRequired chkUsableID");
									}				
								}, actionWhenStart:true
		                	}
		                	
						},
						{header: '關係人姓名', key: 'RELATION_NAME',
		                	input:{
								type:'TEXT',
								size:12,
								maxlength:30,
	                            genRule:function(record , value){
	                                return false;
	                            },
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 	
									if(!isOnChange){ 											       
										node.id = node.name +'_'+index; 	
										node.setAttribute("className" , "validateRequired validateNAME");
										node.setAttribute("alt" , "ch"); <%--[20240722]難字調整--%>
										<%--[20250207]修正難字不觸發action--%>
										node.observe('blur', function(){
				                			var val = this.value;
				                			dataObj[0].RELATION_NAME = val;
				                		});	
									}				
								}, actionWhenStart:true
		                	},
		                	render:function(rec,val,sn){
							 	var span = new Element('span', {id:'RELATION_NAME_'+sn, style: "font-family:'EUDC'"}).update(val);	<%--[20240722]難字調整 --%>
							 	return span;
							}
						},
						{header: '歸戶姓名',key: 'CUST_NAME',
		                	input:{
								type:'TEXT',
								size:12,
								maxlength:30,
	                            genRule:function(record , value){
	                                return false;
	                            },
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){
									if(!isOnChange){ 											       
										node.id = node.name +'_'+index; 	
										node.setAttribute("className" , "validateRequired validateNAME");
										node.setAttribute("alt", "ch"); <%-- [20240722]難字調整--%>
										<%--[20250207]修正難字不觸發action--%>
										node.observe('blur', function(){
				                			var val = this.value;
				                			dataObj[0].CUST_NAME = val;
				                		});	
									}			
								}, actionWhenStart:true
		                	},
		                	render:function(rec,val,sn){
							 	var span = new Element('span', {id:'CUST_NAME_'+sn, style: "font-family:'EUDC'"}).update(val);	<%--[20240722]難字調整 --%>
							 	return span;
							}
						},
						{header: '關係種類', key: 'RELATION_KD', 
							render:function(rec,val){
							 	if(!rec.RELATION_KD_NM){ return ""; }
							 	return rec.RELATION_KD_NM;
							},
							input:{
								type:"select" ,
								opts:{"":"請選譯" <c:forEach  var="item" items="${RelationKDList}">,"${item.key}":"${item.value}"</c:forEach > },								
								genRule:function(rows , value){
									return false;
								},
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 	
									if(!isOnChange){ 											       
										node.id = node.name +'_'+index; 	
										node.setAttribute("className" , "validateSelection");			
									}			
								}, actionWhenStart:true
							}
						},
						{header: '關係代號', key: 'RELATION_CODE',
							render:function(rec,val){
							 	if(!rec.RELATION_CODE_NM){ return ""; }
							 	return rec.RELATION_CODE_NM;
							},
							input:{
								type:"select" ,
								opts:{"":"請選譯" <c:forEach  var="item" items="${RelationCodeList}">,"${item.key}":"${item.value}"</c:forEach > },								
								genRule:function(rows , value){
									return false;
								},
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 	
									if(!isOnChange){ 											       
										node.id = node.name +'_'+index; 	
										node.setAttribute("className" , "validateSelection");			
									}											
								}, actionWhenStart:true
							}
						},
						{header: '稱謂/職位', key: 'ROLE_CODE',
							render:function(rec,val){
							 	if(!rec.ROLE_CODE_NM){ return ""; }
							 	return rec.ROLE_CODE_NM;
							}, 
							input:{
								type:"select" ,
								opts:{"":"請選譯" <c:forEach  var="item" items="${RoleCodeList}">,"${item.key}":"${item.value}"</c:forEach > },								
								genRule:function(rows , value){
									return false;
								},
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 	
									if(!isOnChange){ 											       
										node.id = node.name +'_'+index; 	
										node.setAttribute("className" , "validateSelection");			
									}			
								}, actionWhenStart:true
							}
						},
						{header: '貸款餘額', key: 'LOAN_RST_AMT'
						},
						{header: '輸入人員', key: 'INPUT_NM', attrs:{style:"font-family:'EUDC'"}<%-- [20240722]難字調整--%>
						},
						{header: '輸入日期', key: 'INPUT_DATE',
							render:function(rec,val){
							 	if(!val){ return ""; }
							 	return Date.toROC(val).substring(0,10);
							}
						}
					]										
				}                 
			); 
	
			//全選 button click event    
			if($('CHECK_ALL')){                    
				$('CHECK_ALL').observe('click',function(event){
						checkAll();
						valid1.reset();
						window.setTimeout("grid.resetDivHeight()" , 100);
					}                        
				);
			}
	}
	
	//--------------------------------------------------------------------------        
	//以下為UI() public method,放在 return 中        
	//--------------------------------------------------------------------------          
	return{                              
		//init Function for 初始整個UI Class                
		init:function(){                                        
				
			initTables();
			
			//查詢 button click event                        
			$('btn_query').observe('click',function(event){
					$('CHECK_ALL').checked=false;
					$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
					$('CUST_ID').value = $('CUST_ID').value.toUpperCase();
					doQuery();					
				}                        
			); 
			//新增 button click event                        
			$('btn_insert').observe('click',function(event){
					$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
					$('CUST_ID').value = $('CUST_ID').value.toUpperCase();
					doInsert(); 
					grid1.resetDivHeight();
				}                        
			);
			//刪除 button click event                        
			$('btn_delete').observe('click',function(event){
					$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
					$('CUST_ID').value = $('CUST_ID').value.toUpperCase();
					doDelete();
					grid1.resetDivHeight();
				}                        
			);
			//修改 button click event                        
			$('btn_update').observe('click',function(event){
					$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
					$('CUST_ID').value = $('CUST_ID').value.toUpperCase();
					doUpdate();
					grid1.resetDivHeight();
				}                        
			);
			//確認 button click event                        
			$('btn_confirm').observe('click',function(event){
					$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
					$('CUST_ID').value = $('CUST_ID').value.toUpperCase();
					doConfirm();
					grid.resetDivHeight();
				}                        
			);
			//影像連結 button click event                        
			$('btn_image').observe('click',function(event){
					$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
					$('CUST_ID').value = $('CUST_ID').value.toUpperCase();
					doImage(); 
				}                        
			);
			
			
			
			<c:if test="${not empty APPLY_ID}">
				$("APPLY_ID").value = "<c:out value='${APPLY_ID}'/>";
				$("qryAPPLY_ID").value = "<c:out value='${qryAPPLY_ID}'/>";
				
				$("QUERY_TYPE_0").checked = true;
				doQuery();
			</c:if>
			<c:if test="${not empty CUST_ID}">
				$("CUST_ID").value = "<c:out value='${CUST_ID}'/>";
				$("QUERY_TYPE_1").checked = true;
				doQuery();
			</c:if>

		}//end init()--                        
	}//end return--        /
	//-------------------------------------------------------------------------- 
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
<form id="form1" name="form1" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
	<tr>
		<td class="tbYellow" width="10%" align="center">
			<input type="radio" name="QUERY_TYPE" id="QUERY_TYPE_0" value="0" checked>
		</td>
		<td class="tbYellow" width="10%" align="center">
			受理編號
		</td>
		<td class="tbYellow2" colspan="3">
			<input type="text" class="textBox chkAPPLY_ID validateAPPLY_ID" id="APPLY_ID" name="APPLY_ID" size="11" maxlength="11">
			<input type="hidden" id="qryAPPLY_ID" name="qryAPPLY_ID" value="" />
			<input type="hidden" id="isQuery" name="isQuery" value="" />
		</td>											
		<td class="tbYellow2" align="left" rowspan="2" width="10%">
			<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
			<input id="btn_image" name="btn_image" type="button" class="button" value="影像連結">
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" align="center">
			<input type="radio" name="QUERY_TYPE" id="QUERY_TYPE_1" value="1">
		</td>
		<td class="tbYellow" width="10%" align="center">
			歸戶ID
		</td>
		<td class="tbYellow2" colspan="3">
			<input type="text" class="textBox" id="CUST_ID" name="CUST_ID" size="15" maxlength="10">
		</td>
	</tr>
	<tr>
		<td width="100%" align="center" colspan="6" >
			<input id="btn_confirm" name="btn_confirm" type="button" class="button" value="確認"> 
		</td>
	</tr>
</table>

<table id="grid" class="grid"></table>
									
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbbox2" id="tableB">										
	<tr class="tbblue" align="center">
    	<td width="20%" height="56" colspan="2" align="center" class="tbBlue3">&nbsp;</td>
        <td width="80%" height="56" colspan="5" align="center" class="tbBlue3"><div align="left" id="lawINFO">&nbsp;</div></td>
    </tr>
</table>
<table id="grid1" class="grid"></table>

<div class="tbBox2" align="center"  id="tableC">
	<input id="btn_insert" name="btn_insert" type="button" class="button" value="新增"> 
	<input id="btn_update" name="btn_update" type="button" class="button" value="修改"> 
	<input id="btn_delete" name="btn_delete" type="button" class="button" value="刪除">
</div>
</form>

</body>
<!-- InstanceEnd -->
</html>
