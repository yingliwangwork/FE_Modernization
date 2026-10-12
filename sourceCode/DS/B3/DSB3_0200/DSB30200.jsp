<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB30200.jsp
作者：王文進
功能：火險歸檔作業。
完成：
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

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

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type='text/javascript'>

// 產生畫面物件
var DSB30200 = new DSB30200();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB30200.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB30200(){
	//查詢的檢核
	var valid1;
	var valid2;
	var grid1;
	//前次查詢條件
	var queryCondition = {APPLY_ID : ""};
	
	var GridColumns = {
		common1: [
						{header: "序號", sortable: true, key: "SEQ_NO", attrs:{rowSpan:2} ,
							render : function(rec , val){
								var alink = document.createElement("a");
								alink.href = "#";
								alink.innerHTML = val ? val : '';
								alink.onclick = function(){
				                 	var LP_JSON = {
										action:'<%=dispatcher%>/DSB3_0201/prompt',							
										LINK_FROM:'DSB30200', 
										APPLY_ID:rec.APPLY_ID, 
										SEQ_NO:rec.SEQ_NO,
										LOAN_ID:rec.LOAN_ID
									};
									CSRUtil.linkTo(LP_JSON, 'form1');
								};
								return alink;
							}
						},
						{header: "受理編號",key: "APPLY_ID",
							render : function(rec , val){
								return 	val ? val : "";
							}
						},						
						{header: "火險保費(元) ",key: "FIREINSU_PAYMENT", sortRule:'number', 
							render:function(record, value){
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'FIREINSU_PAYMENT_' + record['SEQ_NO'] + record['APPLY_ID'];
							
	                    		input1.value = value ? CSRUtil.$fmt(value, '#,##0') : '0';
	                    		input1.type = 'TEXT';
	                    		input1.size = "12";
	                    		input1.maxLength = "12";
								input1.style.textAlign = 'right',
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
								input1.onkeyup = function(){
									var val = $F(input1.id);	
									$(input1.id).value = CSRUtil.$fmt(val, '#,##0');
								}
	                    		input1.fieldName = "火險保費(元)";
	                    		div.appendChild(input1);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			//input1.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "人工批單號碼",key: "ADD_POLNO", sortable: true,
		                	input:{
								type:'TEXT',
								size:14,
								maxLength:12,
	                            genRule:function(record , value){
	                                return true;
	                            },
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){
		                        	if(!isOnChange){
										node.id = 'ADD_POLNO_' + dataObj[0]['SEQ_NO'] + dataObj[0]['APPLY_ID']; 
										//node.setAttribute("className" , "required");
									}
									node.fieldName = "人工批單號碼";
									dataObj[0]["ADD_POLNO"] = (node.value ? node.value : "");
		                    		if(dataObj[0]["FIREINSU_KIND"]=='1'){
		                    			//node.readOnly = true;
		                    		}
								}, actionWhenStart:true
		                	}
						},						
						{header: "火險年期",key: "EXPENSE_ITEM_NM", attrs:{rowSpan:2} ,
							render : function(rec , val){
								var v1 = rec.FIREINSU_YY ? rec.FIREINSU_YY : '0';
								var v2 = rec.FIREINSU_MM ? rec.FIREINSU_MM : '0';
								return 	v1+'年'+v2+'月';
							}
						},						
						{header: "出單狀況",key: "ISSUE_CODE_NM", attrs:{rowSpan:2} ,
							render : function(rec , val){
								return 	val ? val : "";
							}
						},						
						{header: "歸檔原因",key: "FILE_REASON",
		                	input:{
								type:'select',
		                		actionWhenStart:true,
								action : function( node , dataObj , textDiv, record, isOnChange){
									if(!isOnChange){
								        initFILE_REASON_LIST(node);
										//設定預設值
										if(!dataObj[0]['FILE_REASON']) {
											//node.value = "";
										}else {
											node.value = dataObj[0]['FILE_REASON'];
										}
										node.id = 'FILE_REASON_' + dataObj[0]['SEQ_NO'] + dataObj[0]['APPLY_ID'];
									}
		                    		if(dataObj[0]["FIREINSU_KIND"]=='1'){
										if(isOnChange){
											node.value = record;
										}
										//node.disabled = true;
		                    		}
									dataObj[0]["FILE_REASON"] = (node.value ? node.value : "");
								},
	                            genRule:function(record , value){
	                                return true;
	                            }
		                	}
						},
						{header: "投保公司",key: "FIREINSU_COMPANY",
							input:{
								type:'select',
		                		actionWhenStart:true,
								action : function( node , dataObj , textDiv, record, isOnChange){
									if(!isOnChange){
								        initFIREINSU_COMPANY_LIST(node);
										//設定預設值
										if(!dataObj[0]['FIREINSU_COMPANY']) {
											//node.value = "";
										}else {
											node.value = dataObj[0]['FIREINSU_COMPANY'];
										}
										node.id = 'FIREINSU_COMPANY_' + dataObj[0]['SEQ_NO'] + dataObj[0]['APPLY_ID'];
									}
		                    		if(dataObj[0]["FIREINSU_KIND"]=='1'){
										if(isOnChange){
											node.value = record;
										}
										//node.disabled = true;
		                    		}
									dataObj[0]["FIREINSU_COMPANY"] = (node.value ? node.value : "");
								},
	                            genRule:function(record , value){
	                                return true;
	                            }
		                	}
						},												
						{header: "火險保額(萬元)",key: "FIREINSU_AMT", sortRule:'number', 
							render:function(record, value){
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'FIREINSU_AMT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input1.value = value ? CSRUtil.$fmt(value/10000, '#,##0.###') : '0';
	                    		input1.type = 'TEXT';
	                    		input1.size = "12";
	                    		input1.maxLength = "11";
								input1.style.textAlign = 'right',
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
								input1.onkeyup = function(){
									var val = $F(input1.id);	
									$(input1.id).value = CSRUtil.$fmt(val, '#,##0.###');
								}
	                    		input1.fieldName = "火險保額(萬元)";
	                    		div.appendChild(input1);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			input1.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "年期變更",key: "NEW_FIREINSU", attrs:{rowSpan:2} ,
							render:function(record, value){
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'NEW_FIREINSU_YY_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input1.value = record.FIREINSU_YY ? record.FIREINSU_YY : "0";
	                    		input1.type = 'TEXT';
	                    		input1.size = "3";
	                    		input1.maxLength = "2";
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
	                    		input1.fieldName = "年期變更年";
	                    		//input1.className = 'required validate-digits';
	                    		div.appendChild(input1);
	                    		div.appendChild(document.createTextNode('年'));  
	                    		
	                    		var input2 = document.createElement('input');
	                    		input2.id = 'NEW_FIREINSU_MM_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input2.value = record.FIREINSU_MM ? record.FIREINSU_MM : "0";
	                    		input2.type = 'TEXT';
	                    		input2.size = "3";
	                    		input2.maxLength = "2";
								input2.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
	                    		input2.fieldName = "年期變更月";
	                    		//input2.className = 'required validate-digits';
	                    		div.appendChild(input2);
	                    		div.appendChild(document.createTextNode('月'));
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			input1.readOnly = true;
	                    			input2.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "變更火險起日",key: "FIREINSU_BEGDT",
							render:function(record, value){
								var unique_id = 'FIREINSU_BEGDT_' + record['SEQ_NO'] + record['APPLY_ID']; 
	                    		var div = document.createElement('div');
	                    		var input = document.createElement('input');
	                    		input.id = unique_id;
	                    		input.value = value ? Date.toInputROC(value,"") : "";
	                    		input.type = 'TEXT';
	                    		input.datatype="ROCDate";
	                    		input.size = "10";
	                    		input.maxLength = "7";
								input.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
	                    		input.fieldName = "變更火險起日";
	                    		//input.className = 'required validate-ROCDate';
	                    		div.appendChild(input);
	                    		
	                    		var img = document.createElement('img');
	                    		img.id = 'calImg_FIREINSU_BEGDT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		img.src = "<%=imageBase%>/CM/calendar.gif";
	                    		img.onclick = function(){
									if(record.FIREINSU_KIND!='1'){
	                    				getCalendarFor($('FIREINSU_BEGDT_' + record['SEQ_NO'] + record['APPLY_ID']));
	                    			}
	                    		};
	                    		div.appendChild(img);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			input.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "借款人",key: "BORROW_NAME",
							render : function(rec , val){
								var value = val ? val : "";
								<%-- [20240607] 難字調整 --%>
								var span = new Element('span',{style:"font-family:'EUDC'"}).update(value);
								return span;
							}
						},
						{header: "地震保費(元)",key: "EARTH_PAYMENT", sortRule:'number', 
							render:function(record, value){
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'EARTH_PAYMENT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input1.value = value ? CSRUtil.$fmt(value, '#,##0') : '0';
	                    		input1.type = 'TEXT';
	                    		input1.size = "12";
	                    		input1.maxLength = "12";
								input1.style.textAlign = 'right',
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
								input1.onkeyup = function(){
									var val = $F(input1.id);	
									$(input1.id).value = CSRUtil.$fmt(val, '#,##0');
								}
	                    		input1.fieldName = "地震保費(元)";
	                    		div.appendChild(input1);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			//input1.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "人工加批火險保費 ",key: "ADD_PAYMENT", sortRule:'number', 
							render:function(record, value){
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'ADD_PAYMENT_' + record['SEQ_NO'] + record['APPLY_ID'];
							
	                    		input1.value = value ? CSRUtil.$fmt(value, '#,##0') : '0';
	                    		input1.type = 'TEXT';
	                    		input1.size = "12";
	                    		input1.maxLength = "12";
								input1.style.textAlign = 'right',
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
								input1.onkeyup = function(){
									var val = $F(input1.id);	
									$(input1.id).value = CSRUtil.$fmt(val, '#,##0');
								}
	                    		input1.fieldName = "人工加批火險保費";
	                    		div.appendChild(input1);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			//input1.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "是否贈送火險",key: "INSUFREE_CODE_NM",
							render : function(rec , val){
								return 	val ? val : "";
							}
						},
						{header: "保單號碼",key: "FIREINSU_POLNO", sortable: true,
		                	input:{
								type:'TEXT',
								size:22,
								maxLength:20,
	                            genRule:function(record , value){
	                                return true;
	                            },
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){
		                        	if(!isOnChange){
										node.id = 'FIREINSU_POLNO_' + dataObj[0]['SEQ_NO'] + dataObj[0]['APPLY_ID']; 
										//node.setAttribute("className" , "required");
									}
									node.fieldName = "保單號碼";
									dataObj[0]["FIREINSU_POLNO"] = (node.value ? node.value : "");
		                    		if(dataObj[0]["FIREINSU_KIND"]=='1'){
		                    			node.readOnly = true;
		                    		}
								}, actionWhenStart:true
		                	}
						},
						{header: "地震險保額(萬元)",key: "EARTH_AMT", sortRule:'number', 
							render:function(record, value){
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'EARTH_AMT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input1.value = value ? CSRUtil.$fmt(value/10000, '#,##0.###') : '0';
	                    		input1.type = 'TEXT';
	                    		input1.size = "12";
	                    		input1.maxLength = "11";
								input1.style.textAlign = 'right',
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
								input1.onkeyup = function(){
									var val = $F(input1.id);	
									$(input1.id).value = CSRUtil.$fmt(val, '#,##0.###');
								}
	                    		input1.fieldName = "地震險保額(萬元)";
	                    		div.appendChild(input1);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			input1.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "變更火險迄日",key: "FIREINSU_ENDDT",
							render:function(record, value){
								var unique_id = 'FIREINSU_ENDDT_' + record['SEQ_NO'] + record['APPLY_ID']; 
	                    		var div = document.createElement('div');
	                    		var input = document.createElement('input');
	                    		input.id = unique_id;
	                    		input.value = value ? Date.toInputROC(value,"") : "";
	                    		input.type = 'TEXT';
	                    		input.datatype="ROCDate";
	                    		input.size = "10";
	                    		input.maxLength = "7";
								input.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
	                    		input.fieldName = "變更火險迄日";
	                    		//input.className = 'required validate-ROCDate';
	                    		div.appendChild(input);
	                    		
	                    		var img = document.createElement('img');
	                    		img.id = 'calImg_FIREINSU_ENDDT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		img.src = "<%=imageBase%>/CM/calendar.gif";
	                    		img.onclick = function(){
	                    			if(record.FIREINSU_KIND!='1'){
										getCalendarFor($('FIREINSU_ENDDT_' + record['SEQ_NO'] + record['APPLY_ID']));
	                    			}
	                    		};
	                    		div.appendChild(img);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			input.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						}

					], 
					
					common2: [
						{header: "序號",sortable: true, key: "SEQ_NO", attrs:{rowSpan:2} ,
							render : function(rec , val){
								var alink = document.createElement("a");
								alink.href = "#";
								alink.innerHTML = val ? val : '';
								alink.onclick = function(){
				                 	var LP_JSON = {
										action:'<%=dispatcher%>/DSB3_0201/prompt',							
										LINK_FROM:'DSB30200', 
										APPLY_ID:rec.APPLY_ID, 
										SEQ_NO:rec.SEQ_NO,
										LOAN_ID:rec.LOAN_ID
									};
									CSRUtil.linkTo(LP_JSON, 'form1');
								};
								return alink;
							}
						},
						{header: "受理編號",key: "APPLY_ID",
							render : function(rec , val){
								return 	val ? val : "";
							}
						},						
						{header: "火險保費(元) ",key: "FIREINSU_PAYMENT", sortRule:'number', 
							render:function(record, value){
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'FIREINSU_PAYMENT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input1.value = value ? CSRUtil.$fmt(value, '#,##0') : '0';
	                    		input1.type = 'TEXT';
	                    		input1.size = "12";
	                    		input1.maxLength = "12";
								input1.style.textAlign = 'right',
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
								input1.onkeyup = function(){
									var val = $F(input1.id);	
									$(input1.id).value = CSRUtil.$fmt(val, '#,##0');
								}
	                    		input1.fieldName = "火險保費(元)";
	                    		div.appendChild(input1);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			//input1.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},						
						{header: "火險年期",key: "EXPENSE_ITEM_NM", attrs:{rowSpan:2} ,
							render : function(rec , val){
								var v1 = rec.FIREINSU_YY ? rec.FIREINSU_YY : '0';
								var v2 = rec.FIREINSU_MM ? rec.FIREINSU_MM : '0';
								return 	v1+'年'+v2+'月';
							}
						},						
						{header: "出單狀況",key: "ISSUE_CODE_NM", attrs:{rowSpan:2} ,
							render : function(rec , val){
								return 	val ? val : "";
							}
						},						
						{header: "歸檔原因",key: "FILE_REASON",
		                	input:{
								type:'select',
		                		actionWhenStart:true,
								action : function( node , dataObj , textDiv, record, isOnChange){
									if(!isOnChange){
								        initFILE_REASON_LIST(node);
										//設定預設值
										if(!dataObj[0]['FILE_REASON']) {
											//node.value = "";
										}else {
											node.value = dataObj[0]['FILE_REASON'];
										}
										node.id = 'FILE_REASON_' + dataObj[0]['SEQ_NO'] + dataObj[0]['APPLY_ID'];
									}
		                    		if(dataObj[0]["FIREINSU_KIND"]=='1'){
										if(isOnChange){
											node.value = record;
										}
										//node.disabled = true;
		                    		}
									dataObj[0]["FILE_REASON"] = (node.value ? node.value : "");
								},
	                            genRule:function(record , value){
	                                return true;
	                            }
		                	}
						},
						{header: "投保公司",key: "FIREINSU_COMPANY",
							input:{
								type:'select',
		                		actionWhenStart:true,
								action : function( node , dataObj , textDiv, record, isOnChange){
									if(!isOnChange){
								        initFIREINSU_COMPANY_LIST(node);
										//設定預設值
										if(!dataObj[0]['FIREINSU_COMPANY']) {
											//node.value = "";
										}else {
											node.value = dataObj[0]['FIREINSU_COMPANY'];
										}
										node.id = 'FIREINSU_COMPANY_' + dataObj[0]['SEQ_NO'] + dataObj[0]['APPLY_ID'];
									}
		                    		if(dataObj[0]["FIREINSU_KIND"]=='1'){
										if(isOnChange){
											node.value = record;
										}
										//node.disabled = true;
		                    		}
									dataObj[0]["FIREINSU_COMPANY"] = (node.value ? node.value : "");
								},
	                            genRule:function(record , value){
	                                return true;
	                            }
		                	}
						},												
						{header: "火險保額(萬元)",key: "FIREINSU_AMT", sortRule:'number', 
							render:function(record, value){
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'FIREINSU_AMT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input1.value = value ? CSRUtil.$fmt(value/10000, '#,##0.###') : '0';
	                    		input1.type = 'TEXT';
	                    		input1.size = "12";
	                    		input1.maxLength = "11";
								input1.style.textAlign = 'right',
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
								input1.onkeyup = function(){
									var val = $F(input1.id);	
									$(input1.id).value = CSRUtil.$fmt(val, '#,##0.###');
								}
	                    		input1.fieldName = "火險保額(萬元)";
	                    		div.appendChild(input1);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			input1.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "近三個月出單記錄",key: "NEW_FIREINSU", attrs:{rowSpan:2} ,
							render:function(record, value){
							
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'NEW_FIREINSU_YY_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input1.value = record.FIREINSU_YY ? record.FIREINSU_YY : "0";
	                    		input1.type = 'HIDDEN';
	                    		input1.size = "3";
	                    		input1.maxLength = "2";
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
	                    		input1.fieldName = "年期變更年";
	                    		//input1.className = 'required validate-digits';
	                    		div.appendChild(input1);
	                    		//div.appendChild(document.createTextNode('年'));  
	                    		
	                    		var input2 = document.createElement('input');
	                    		input2.id = 'NEW_FIREINSU_MM_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input2.value = record.FIREINSU_MM ? record.FIREINSU_MM : "0";
	                    		input2.type = 'HIDDEN';
	                    		input2.size = "3";
	                    		input2.maxLength = "2";
								input2.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
	                    		input2.fieldName = "年期變更月";
	                    		//input2.className = 'required validate-digits';
	                    		div.appendChild(input2);
	                    		//div.appendChild(document.createTextNode('月'));
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			input1.readOnly = true;
	                    			input2.readOnly = true;
	                    		}
								
								if(value > 0) {
									div.appendChild(document.createTextNode('有'));
								} else {
									div.appendChild(document.createTextNode('無'));
								}
	                    		
	                    		return div;

							}
						},
						{header: "變更火險起日",key: "FIREINSU_BEGDT",
							render:function(record, value){
								var unique_id = 'FIREINSU_BEGDT_' + record['SEQ_NO'] + record['APPLY_ID']; 
	                    		var div = document.createElement('div');
	                    		var input = document.createElement('input');
	                    		input.id = unique_id;
	                    		input.value = value ? Date.toInputROC(value,"") : "";
	                    		input.type = 'TEXT';
	                    		input.datatype="ROCDate";
	                    		input.size = "10";
	                    		input.maxLength = "7";
								input.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
	                    		input.fieldName = "變更火險起日";
	                    		//input.className = 'required validate-ROCDate';
	                    		div.appendChild(input);
	                    		
	                    		var img = document.createElement('img');
	                    		img.id = 'calImg_FIREINSU_BEGDT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		img.src = "<%=imageBase%>/CM/calendar.gif";
	                    		img.onclick = function(){
									if(record.FIREINSU_KIND!='1'){
	                    				getCalendarFor($('FIREINSU_BEGDT_' + record['SEQ_NO'] + record['APPLY_ID']));
	                    			}
	                    		};
	                    		div.appendChild(img);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			input.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "借款人",key: "BORROW_NAME",
							render : function(rec , val){
								return 	val ? val : "";
							}
						},
						{header: "地震保費(元)",key: "EARTH_PAYMENT", sortRule:'number', 
							render:function(record, value){
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'EARTH_PAYMENT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input1.value = value ? CSRUtil.$fmt(value, '#,##0') : '0';
	                    		input1.type = 'TEXT';
	                    		input1.size = "12";
	                    		input1.maxLength = "12";
								input1.style.textAlign = 'right',
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
								input1.onkeyup = function(){
									var val = $F(input1.id);	
									$(input1.id).value = CSRUtil.$fmt(val, '#,##0');
								}
	                    		input1.fieldName = "地震保費(元)";
	                    		div.appendChild(input1);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			//input1.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "是否贈送火險",key: "INSUFREE_CODE_NM",
							render : function(rec , val){
								return 	val ? val : "";
							}
						},
						{header: "保單號碼",key: "FIREINSU_POLNO", sortable:true,
		                	input:{
								type:'TEXT',
								size:22,
								maxLength:20,
	                            genRule:function(record , value){
	                                return true;
	                            },
		                        action:function( node , dataObj , textDiv, orgData , isOnChange ){
		                        	if(!isOnChange){
										node.id = 'FIREINSU_POLNO_' + dataObj[0]['SEQ_NO'] + dataObj[0]['APPLY_ID']; 
										//node.setAttribute("className" , "required");
									}
									node.fieldName = "保單號碼";
									dataObj[0]["FIREINSU_POLNO"] = (node.value ? node.value : "");
		                    		if(dataObj[0]["FIREINSU_KIND"]=='1'){
		                    			node.readOnly = true;
		                    		}
								}, actionWhenStart:true
		                	}
						},
						{header: "地震險保額(萬元)",key: "EARTH_AMT", sortRule:'number', 
							render:function(record, value){
	                    		var div = document.createElement('div');
	                    		var input1 = document.createElement('input');
	                    		input1.id = 'EARTH_AMT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		input1.value = value ? CSRUtil.$fmt(value/10000, '#,##0.###') : '0';
	                    		input1.type = 'TEXT';
	                    		input1.size = "12";
	                    		input1.maxLength = "11";
								input1.style.textAlign = 'right',
								input1.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
								input1.onkeyup = function(){
									var val = $F(input1.id);	
									$(input1.id).value = CSRUtil.$fmt(val, '#,##0.###');
								}
	                    		input1.fieldName = "地震險保額(萬元)";
	                    		div.appendChild(input1);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			input1.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						},
						{header: "變更火險迄日",key: "FIREINSU_ENDDT",
							render:function(record, value){
								var unique_id = 'FIREINSU_ENDDT_' + record['SEQ_NO'] + record['APPLY_ID']; 
	                    		var div = document.createElement('div');
	                    		var input = document.createElement('input');
	                    		input.id = unique_id;
	                    		input.value = value ? Date.toInputROC(value,"") : "";
	                    		input.type = 'TEXT';
	                    		input.datatype="ROCDate";
	                    		input.size = "10";
	                    		input.maxLength = "7";
								input.onkeypress = function(){
									return CSRUtil.pressNumber(event.keyCode);
								};
	                    		input.fieldName = "變更火險迄日";
	                    		//input.className = 'required validate-ROCDate';
	                    		div.appendChild(input);
	                    		
	                    		var img = document.createElement('img');
	                    		img.id = 'calImg_FIREINSU_ENDDT_' + record['SEQ_NO'] + record['APPLY_ID'];
	                    		img.src = "<%=imageBase%>/CM/calendar.gif";
	                    		img.onclick = function(){
	                    			if(record.FIREINSU_KIND!='1'){
										getCalendarFor($('FIREINSU_ENDDT_' + record['SEQ_NO'] + record['APPLY_ID']));
	                    			}
	                    		};
	                    		div.appendChild(img);
	                    		
	                    		if(record.FIREINSU_KIND=='1'){
	                    			input.readOnly = true;
	                    		}
	                    		
	                    		return div;
							}
						}

					]

	}
				
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0089:"btn_file"<%--歸檔--%>,
				B0090:"btn_cancelFile"<%--取消歸檔--%>,
				B0028:"btn_confirm"<%--取消歸檔--%> ,
				B0240:"btn_expense"<%--批單火險管理費--%> 
		};
		
		<dz:grantButtons FUNC_ID="DSB30200" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){

		Validation.addAllThese([
				//[ 'chkAPPLY_ID',  '受理編號必須輸入', function(){ if($F('APPLY_ID') == ''){ return false; } return true; } ],
				[ 'checkAPPLY_ID',  '請輸入受理編號再執行查詢', 
					function(v){				
						return 	$('QUERY_TYPE1').checked && v == '' ? false : true;
					}
				],
				[ 'validateAPPLY_IDLength',  '受理編號長度不正確 需為11碼', 
					//檢核受理編號長度
					function(v){
						if($('QUERY_TYPE1').checked && v!==""){
							//return v.length === 11 ? true : false;
							if (v.length === 11 || v.length === 10) {
								return true;
							} else {
							    return false;
							}
						}
						return true;
					}
				],
				[ 'chkISSUE_CODE1', '受理編號查詢應選擇全部，才能查到所有火單資料', function(){ if($('QUERY_TYPE1').checked && $F('ISSUE_CODE') !== ''){ return false; } return true; } ],
				[ 'chkISSUE_CODE2', '整批查詢應只能選擇新件或是續保件，而非全部', function(){ if($('QUERY_TYPE2').checked && $F('ISSUE_CODE') == ''){ return false; } return true; } ],
				[ 'chkISSUE_DATE_STR',  '出單日期起必須輸入', function(){ if($('QUERY_TYPE2').checked && $F('ISSUE_DATE_STR') == ''){ return false; } return true; } ],
				[ 'chkISSUE_DATE_END',  '出單日期迄必須輸入', function(){ if($('QUERY_TYPE2').checked && $F('ISSUE_DATE_END') == ''){ return false; } return true; } ],
				[ 'chkSTR_AND_END', '出單日期起日不可大於迄日', function(){ if($('QUERY_TYPE2').checked && diffDay($F('ISSUE_DATE_STR'),$F('ISSUE_DATE_END'), true) < 0){ return false; } return true; }],
				[ 'chkType3',  '請擇一輸入出單日起迄或保單起迄', function(){ if($('QUERY_TYPE3').checked && !$F('ISSUE_DATE1_STR')  && !$F('ISSUE_DATE1_END')&& !$F('POLNO_STR')&& !$F('POLNO_END')){ return false; } return true; } ],
				[ 'chkISSUE_DATE1',  '請同時輸入歸檔確認出單日起迄', function(){ if(($('QUERY_TYPE3').checked && $F('ISSUE_DATE1_STR')&& !$F('ISSUE_DATE1_END'))|| ($('QUERY_TYPE3').checked && !$F('ISSUE_DATE1_STR')&& $F('ISSUE_DATE1_END'))){ return false; } return true; } ],
				[ 'chkPOLNO',  '請同時輸入保單起迄', function(){ if(($('QUERY_TYPE3').checked && $F('POLNO_STR')&& !$F('POLNO_END'))|| ($('QUERY_TYPE3').checked && !$F('POLNO_STR')&& $F('POLNO_END'))){ return false; } return true; } ],
				[ 'chkCRED_DEPT',  '請選擇區域', function(){ if(($('QUERY_TYPE3').checked && !$F('CRED_DEPT'))){ return false; } return true; } ],
				[ 'chkSelectISSUE_CODE2',  '請選擇出單種類 ', function(){ if(($('QUERY_TYPE3').checked && !$F('ISSUE_CODE2'))){ return false; } return true; } ],
				
		]);

		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		valid1.define( "checkAPPLY_ID" , { id: "APPLY_ID" } );
		valid1.define( "validateAPPLY_IDLength" , { id: "APPLY_ID" } );
		valid1.define( "chkISSUE_DATE_STR" , { id: "ISSUE_DATE_STR" } );
		valid1.define( "chkISSUE_DATE_END" , { id: "ISSUE_DATE_END" } );
		valid1.define( "chkSTR_AND_END" , { id: "ISSUE_DATE_END" } );
		valid1.define( "chkISSUE_CODE1" , { id: "ISSUE_CODE" } );
		valid1.define( "chkISSUE_CODE2" , { id: "ISSUE_CODE" } );
		
		valid1.define( "chkType3" , { id: "ISSUE_DATE1_STR" } );
		valid1.define( "chkType3" , { id: "ISSUE_DATE1_END" } );
		valid1.define( "chkType3" , { id: "POLNO_STR" } );
		valid1.define( "chkType3" , { id: "POLNO_END" } );
		valid1.define( "chkISSUE_DATE1" , { id: "ISSUE_DATE1_STR" } );
		valid1.define( "chkISSUE_DATE1" , { id: "ISSUE_DATE1_END" } );
		
		valid1.define( "chkPOLNO" , { id: "POLNO_STR" } );
		valid1.define( "chkPOLNO" , { id: "POLNO_END" } );
		valid1.define( "chkCRED_DEPT" , { id: "CRED_DEPT" } );
		valid1.define( "chkSelectISSUE_CODE2" , { id: "ISSUE_CODE2" } );
		valid2 = new Validation("form2", {useTitles:true,focusOnError:false,immediate:false});

		
	}

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB3_0200/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {
		//查詢資料
		doQuery : function(event){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			if(!valid1.validate()){ 
				return; 
			}
			var QUERY_TYPE;
			$$('#form1 input[type=radio]').each(function(ele){
				if($(ele).checked){
					
					QUERY_TYPE=$(ele).value
				}			
			})
			
			//保留參數管理-更新受理編號
			CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});

			//將畫面欄位存成record
			var sendRecord = makeRecord();	
			//將查詢條件存起來
			queryCondition = sendRecord;	
			//發送ajax
			ajaxPost( 'query' , {
					sendRecord : Object.toJSON(sendRecord),QUERY_TYPE:QUERY_TYPE	
				},
				function(resp){	
					if($('QUERY_TYPE2').checked&&$F('ISSUE_CODE') == "2" || $('QUERY_TYPE2').checked&&$F('ISSUE_CODE') == "6") {
						$('btn_file').enable();
						$('btn_cancelFile').enable();
						$('btn_confirm').disable();
						$('btn_expense').disable();
						buttons.doCreateGrid(GridColumns.common2);
					} else {
						if($('QUERY_TYPE3').checked){
							$('btn_file').disable();
							$('btn_cancelFile').disable();
							$('btn_confirm').enable();
							$('btn_expense').disable();
							buttons.doCreateGridForType3();
						}else{
							$('btn_file').enable();
							$('btn_cancelFile').enable();
							$('btn_confirm').disable();
							$('btn_expense').enable();
							buttons.doCreateGrid(GridColumns.common1);
						}
					}
					
					if(QUERY_TYPE=="3"){
						var sumMap=[{'text':'合計','textAlign':'center',value:resp.sumMap}];
						
						grid1.load(resp.rtnList,sumMap||[]);
					}else{
					
						grid1.load(resp.rtnList);
					}
					PageUI.resize(true);
					autoFormatToDate();  
				},
				function(resp){					
					if($('QUERY_TYPE2').checked&&$F('ISSUE_CODE') == "2" || $('QUERY_TYPE2').checked&&$F('ISSUE_CODE') == "6") {
						buttons.doCreateGrid(GridColumns.common2);
					} else {
						if($('QUERY_TYPE3').checked){
							buttons.doCreateGridForType3();
						}else{
							buttons.doCreateGrid(GridColumns.common1);
						}
					}
					$('btn_file').enable();
					$('btn_cancelFile').enable();
					$('btn_confirm').enable();
					$('btn_expense').enable();
					//失敗把前次內容清掉 並把鑑價,支援人員list清掉
					grid1.load([]);
					PageUI.resize(true);
					autoFormatToDate();  
				}
			);		
		},		
		
		
		//歸檔
		doFile : function(event){	
			
			var checkfileList = grid1.getCheckedRecord();
			if(!checkfileList.length >0){
				alert("請先勾選欲歸檔資料，才能作業!!");
				return;
			}
			
			var fileRecord = makeEditRecord();
			
			valid2.reset(); 
			if(!valid2.validate()){ 
				return; 
			}
			
			//發送ajax
			ajaxPost( 'file' , 
			{
				fileRecord : Object.toJSON(fileRecord), //畫面勾選的records
				sendRecord : Object.toJSON(queryCondition) //上次查詢的條件		
			},
				function(resp){			
					//重查,並紀錄新的List			
					grid1.load(resp.rtnList);
					PageUI.resize(true);
					autoFormatToDate();  
				}
			);
		},
		
		//取消歸檔
		doCancelFile : function(event){	
			
			var checkcancelFileList = grid1.getCheckedRecord();
			if(!checkcancelFileList.length >0){
				alert("請先勾選欲取消歸檔資料，才能作業!!");
				return;
			}
			
			var checkcancelFileRecord = makeEditRecord();
			
			valid2.reset();  
			if(!valid2.validate()){ 
				return; 
			}
			
			//發送ajax
			ajaxPost( 'cancelFile' , 
			{
				cancelFileRecord : Object.toJSON(checkcancelFileRecord), //畫面勾選的records
				sendRecord : Object.toJSON(queryCondition) //上次查詢的條件		
			},
				function(resp){			
					//重查,並紀錄新的List			
					grid1.load(resp.rtnList);
					PageUI.resize(true);
					autoFormatToDate();  
				}
			);
		},
		doConfirm: function(){
			var checkList = grid1.getCheckedRecord(['APPLY_ID','SEQ_NO','LOAN_ID']);
			if(!checkList.length >0){
				alert("請先勾選欲確認資料，才能作業!!");
				return;
			}
			var QUERY_TYPE;
			$$('#form1 input[type=radio]').each(function(ele){
				if($(ele).checked){
					
					QUERY_TYPE=$(ele).value
				}			
			})
			ajaxPost( 'confirm' , 
			{
				checkList : Object.toJSON(checkList), //畫面勾選的records
				sendRecord : Object.toJSON(queryCondition), //上次查詢的條件		
				QUERY_TYPE :QUERY_TYPE
			},
				function(resp){			
					//重查,並紀錄新的List			
					if(QUERY_TYPE=="3"){
						var sumMap=[{'text':'合計','textAlign':'center',value:resp.sumMap}];
						
						grid1.load(resp.rtnList,sumMap||[]);
					}else{
					
						grid1.load(resp.rtnList);
					}
					PageUI.resize(true);
					autoFormatToDate();  
				}
			);
		},
		//批單火險管理費
		doExpense : function(event){	
			
			var checkfileList = grid1.getCheckedRecord();
			if(!checkfileList.length >0){
				alert("請先勾選欲掛批單火險管理費資料，才能作業!!");
				return;
			}
			
			if(!confirm('非人工批單件請勿掛管理費!\n請確認輸入資料是否正確?')){
					return;			
				}
			
			var fileRecord = makeEditRecord();
			
			//發送ajax
			ajaxPost( 'expense' , 
			{
				fileRecord : Object.toJSON(fileRecord), //畫面勾選的records
				sendRecord : Object.toJSON(queryCondition) //上次查詢的條件		
			},
				function(resp){			
					//重查,並紀錄新的List			
					grid1.load(resp.rtnList);
					PageUI.resize(true);
					autoFormatToDate();  
				}
			);
		},
		//  建立 TABLEUI
		doCreateGrid: function(column) {
			var i=1;
			grid1 = new TableUI ( {
					table: $("grid1"), pageSize: 10, allSortable:false,
					split: ['BORROW_NAME'],
					autoCheckBox:{ type: "checkbox", isSelectAll:true,
						action: function (checkbox , boxStatus , records) {
							checkbox.value=records[0].SEQ_NO;
							checkbox.LOAN_ID=records[0].LOAN_ID;
							checkbox.ISSUE_CODE=records[0].ISSUE_CODE;
							checkbox.BORROW_ID=records[0].BORROW_ID;
							checkbox.INSUFREE_CODE=records[0].INSUFREE_CODE;
							checkbox.APPLY_ID=records[0].APPLY_ID;
							if(grid1.isNew){
								var inputs_td = grid1.getThisRecordTD( checkbox , ['NEW_FIREINSU','FIREINSU_BEGDT','FIREINSU_ENDDT']);
								if(inputs_td.length > 0 ){
									for(var y = 0 ; y < inputs_td.length ; y++ ){
										var td = inputs_td[y];
										for(var key in td){
											var inputs = $(td[key]).select('input').each(function(input){
												if(checkbox.checked){
													var fieldName = input.fieldName;
													if("年期變更年"==fieldName||"年期變更月"==fieldName){
														input.className='textBox2 required validate-digits';
													}else if("變更火險起日"==fieldName || "變更火險迄日"==fieldName){
														input.className='textBox2 required validate-ROCDate';
													}
												}else{
													input.className='textBox2';
												}
											});
										}		
									}
								}
							}else{
								if(checkbox.checked){		
									var tr = checkbox.up('tr');
									tr.select('input').each(function(input){
										var fieldName = input.fieldName;
										if("年期變更年"==fieldName||"年期變更月"==fieldName){
											input.className='textBox2 required validate-digits';
										}else if("變更火險起日"==fieldName){
											input.className='textBox2 required validate-ROCDate';
										}
									})	
									tr.next().select('input').each(function(input){
										var fieldName = input.fieldName;
										if("變更火險迄日"==fieldName){
											input.className='textBox2 required validate-ROCDate';
										}
									})	
								}else{
									var tr = checkbox.up('tr');
									tr.select('input').each(function(input){
										var fieldName = input.fieldName;
										if("年期變更年"==fieldName||"年期變更月"==fieldName||"變更火險起日"==fieldName){
											input.className='textBox2';
										}
									})
									tr.next().select('input').each(function(input){
										var fieldName = input.fieldName;
										if("變更火險迄日"==fieldName){
											input.className='textBox2';
										}
									})	
								}
							}
						}
					},
					column:column
					
					,pageChange:function(){
						valid2.clear();
						<%-- [20240607] 難字調整 --%>
						if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
						$$("#grid1 input[id]").each( 
							function(elem){ 
								if(elem.id.indexOf('FIREINSU_BEGDT_')>=0){		
									valid2.define( "validate-ROCDate-Interval" , [{ id :  elem.id },{ id: 'FIREINSU_ENDDT_' + elem.id.substring(elem.id.lastIndexOf('_')+1) }]);
								}
								//valid2.define( "validate-ROCDate-Interval" , [{ id :  'FIREINSU_BEGDT_' + record['SEQ_NO'] },{ id: 'FIREINSU_ENDDT_' + record['SEQ_NO'] }]); 
							}
						);
					}
					
				});
		}
		,doCreateGridForType3 : function(){
			grid1 = new TableUI ( {
				table: $("grid1"), pageSize: 10, allSortable:false,
				split: ['BORROW_NAME'],
				autoCheckBox:{ type: "checkbox", isSelectAll:true},
				<%-- [20240607] 難字調整 --%>
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
	            },
				column:[
					{header: "序號",sortable: true,key: "SEQ_NO", attrs:{rowSpan:2},
						render : function(rec , val){
							var alink = document.createElement("a");
							alink.href = "#";
							alink.innerHTML = val ? val : '';
							alink.onclick = function(){
								var LP_JSON = {
									action:'<%=dispatcher%>/DSB3_0201/prompt',							
									LINK_FROM:'DSB30200', 
									APPLY_ID:rec.APPLY_ID, 
									SEQ_NO:rec.SEQ_NO,
									LOAN_ID:rec.LOAN_ID
								};
								CSRUtil.linkTo(LP_JSON, 'form1');
							};
							return alink;
						}
					},
					{header: "受理編號",key: "APPLY_ID"},
					
					{header: "火險保費(元)",key: "FIREINSU_PAYMENT", renderInCount:true,
						render: function (rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
						}
					},
					{header: "火險年期",key: "FIREINSU_YY", attrs:{rowSpan:2},
						render : function(rec , val){
						var FIREINSU_MM=""
							if(rec.FIREINSU_MM||rec.FIREINSU_MM===0){
								FIREINSU_MM=rec.FIREINSU_MM+"月";
							}
							return 	val ? val+"年"+FIREINSU_MM: "";
						}
					},
					{header: "出單狀況",key: "ISSUE_CODE_NM", attrs:{rowSpan:2}},
					{header: "歸檔原因",key: "FILE_REASON_NM"},
					{header: "投保公司",key: "FIREINSU_COMPANY_NM"},
					{header: "火險保額(萬元)",key: "FIREINSU_AMT",
						render: function (rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
						}
					},
					{header: "年期變更",key: "", attrs:{rowSpan:2}},
					{header: "變更火險起日",key: "FIREINSU_BEGDT",
						render :function(record,value){
						    return Date.toROC( value|| '');
						}
					},
					{header: "近三個月出單記錄",key: "TIMES", attrs:{rowSpan:2},
						render :function(record,value){
						    return value>0 ? "有" : "無";
						}
					},
					<%-- [20240607] 難字調整 --%>
					{header: "借款人",key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
					{header: "地震保費(元)",key: "EARTH_PAYMENT", renderInCount:true,
						render: function (rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
						}
					},
					{header: "是否贈送火險",key: "INSUFREE_CODE_NM"},
					{header: "保單號碼",sortable: true,key: "FIREINSU_POLNO"},
					{header: "地震險保額(萬元)",key: "EARTH_AMT",
						render: function (rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
						}
					},
					{header: "變更火險迄日",key: "FIREINSU_ENDDT",
						render :function(record,value){
						    return Date.toROC( value|| '');
						}
					}

					
				]
			});
		}
	}
	
	//將畫面A資料存成Record
	function makeRecord(){
	
		var sendRecord = {}
		if($('QUERY_TYPE1').checked){
			// 受理編號
			sendRecord.APPLY_ID	= $('APPLY_ID').value.toUpperCase(); //受理編號
		}else if($('QUERY_TYPE2').checked){
			//區域
			var editList = [];
	       	<c:forEach var="CRED_DEPT" items="${CRED_DEPTS_LIST}">
			editList.push('${CRED_DEPT}');
	       	</c:forEach>
	       	
			sendRecord.ISSUE_DATE_STR = toY2K($F('ISSUE_DATE_STR')); //出單日期起
			sendRecord.ISSUE_DATE_END = toY2K($F('ISSUE_DATE_END')); //出單日期迄
			sendRecord.ISSUE_CODE = $F('ISSUE_CODE'); //出單種類
			sendRecord.CRED_DEPTS = editList;
		}else if($('QUERY_TYPE3').checked){
			var editList = [];
			editList.push($F('CRED_DEPT'));
			
			sendRecord.ISSUE_DATE1_STR = toY2K($F('ISSUE_DATE1_STR')); 
			sendRecord.ISSUE_DATE1_END = toY2K($F('ISSUE_DATE1_END')); 
			sendRecord.ISSUE_CODE2 = $F('ISSUE_CODE2');
			sendRecord.POLNO_STR = $F('POLNO_STR');			
			sendRecord.POLNO_END = $F('POLNO_END');
			sendRecord.CRED_DEPTS = editList;
		}
		return sendRecord;	
	}
	
	//將畫面資料存成要派件或轉移的List
	function makeEditRecord(){
		var editList = [];
		$$('#grid1 input:checked[type="checkbox"]').each(function(checkbox){
				
				if(checkbox.name!="autoCheckAll" && checkbox.name!="autoCheckBox_grid1_SelectAll"){ //for tableui and update tableui
				var tempMap = {};
				var str=checkbox.value;
				if(grid1.isNew){
					// for update Tableui
					checkbox = grid1.getDataObj(checkbox);
					str = checkbox.SEQ_NO;
				}
				var id=checkbox.APPLY_ID;
				
				tempMap["SEQ_NO"] = str;
				tempMap["APPLY_ID"] = id;
				tempMap["FIREINSU_PAYMENT"] = $('FIREINSU_PAYMENT_'+str+id).value.replace(/,/gi,'');
				tempMap["EARTH_PAYMENT"] = $('EARTH_PAYMENT_'+str+id).value.replace(/,/gi,'');
				tempMap["FILE_REASON"] = $('FILE_REASON_'+str+id).value;
				tempMap["FIREINSU_COMPANY"] = $('FIREINSU_COMPANY_'+str+id).value;
				tempMap["FIREINSU_POLNO"] = $('FIREINSU_POLNO_'+str+id).value;
				tempMap["FIREINSU_AMT"] = $('FIREINSU_AMT_'+str+id).value.replace(/,/gi,'');
				tempMap["EARTH_AMT"] = $('EARTH_AMT_'+str+id).value.replace(/,/gi,'');
				tempMap["FIREINSU_YY"] = $('NEW_FIREINSU_YY_'+str+id).value;
				tempMap["FIREINSU_MM"] = $('NEW_FIREINSU_MM_'+str+id).value;
				tempMap["FIREINSU_BEGDT"] = $('FIREINSU_BEGDT_'+str+id).value;
				tempMap["FIREINSU_ENDDT"] = $('FIREINSU_ENDDT_'+str+id).value;				
				tempMap["LOAN_ID"] = checkbox.LOAN_ID;
				tempMap["ISSUE_CODE"] = checkbox.ISSUE_CODE;
				tempMap["BORROW_ID"] = checkbox.BORROW_ID;
				tempMap["INSUFREE_CODE"] = checkbox.INSUFREE_CODE;
				tempMap["ADD_PAYMENT"] = $('ADD_PAYMENT_'+str+id).value.replace(/,/gi,'');
				tempMap["ADD_POLNO"] = $('ADD_POLNO_'+str+id).value;
				
				editList.push(tempMap);
			}
			
		});

		return editList;
	}
	
	//歸檔原因
	function initFILE_REASON_LIST(node) {
		var elOptNew = document.createElement('option');
		elOptNew.text =  '請選擇';
		elOptNew.value = '';
		node.add(elOptNew);
		<c:forEach var="map" items="${FILE_REASON_LIST}">
			var elOptNew = document.createElement('option');
			elOptNew.text =  '${map.value}';
			elOptNew.value = '${map.key}';
			node.add(elOptNew);
		</c:forEach>
	}
	
	//投保公司
	function initFIREINSU_COMPANY_LIST(node) {
		var elOptNew = document.createElement('option');
		elOptNew.text =  '請選擇';
		elOptNew.value = '';
		node.add(elOptNew);
		<c:forEach var="map" items="${FIREINSU_COMPANY_LIST}">
			var elOptNew = document.createElement('option');
			elOptNew.text =  '${map.value}';
			elOptNew.value = '${map.key}';
			node.add(elOptNew);
		</c:forEach>
	}

	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSB30200", "火險作業", "火險歸檔作業", 1);
				PageUI.resize(true);

				buttons.doCreateGrid(GridColumns.common1);
				
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );
				$("btn_file").observe("click", buttons.doFile );
				$('btn_cancelFile').observe('click', buttons.doCancelFile);
				$('btn_confirm').observe('click',buttons.doConfirm);
				$('btn_expense').observe('click',buttons.doExpense);
				initValidation();	
				
				fix();

				displayMessage();				
						
				buttonAuth();

				//保留參數管理-取得受理編號
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');

				var LP_JSON = CSRUtil.isBackLink('form1');
				if(LP_JSON){
					buttons.doQuery();
				}else{
					LP_JSON = CSRUtil.getLP_JSON();
					if(LP_JSON && LP_JSON.APPLY_ID){
						if(LP_JSON.APPLY_ID!=''){
							$('APPLY_ID').value = LP_JSON.APPLY_ID;
						}
						
						if(LP_JSON.ACTION_TYPE=='Q'){
							$('ISSUE_DATE_STR').value = '';
							$('ISSUE_DATE_END').value = '';
							buttons.doQuery();
						}
					}else{
						if('${param.APPLY_ID}'!=''){
							$('APPLY_ID').value = '${param.APPLY_ID}';
						}
						
						if('${param.ACTION_TYPE}'=='Q'){
							$('ISSUE_DATE_STR').value = '';
							$('ISSUE_DATE_END').value = '';
							$('ISSUE_DATE1_STR').value = '';
							$('ISSUE_DATE1_END').value = '';
							buttons.doQuery();
						}
					}
				}
			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" width="10%" align="left" >
				<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE1' value=1 checked>受理編號
			</td>
			<td class="tbYellow2" colspan="10">
				<input name="APPLY_ID" id="APPLY_ID" type="text" class="text2" size="12" maxlength="11" class="textBox" value="" />				
			</td>
			<td class="tbYellow2"  align = "center" rowspan="3">
				<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE2' value=2>出單日
			</td>
			<td class="tbYellow2" colspan='4'>
				<input name="ISSUE_DATE_STR" id='ISSUE_DATE_STR' type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${ISSUE_DATE_STR}">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('ISSUE_DATE_STR'))">
				~
				<input name="ISSUE_DATE_END" id='ISSUE_DATE_END' type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${ISSUE_DATE_END}">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('ISSUE_DATE_END'))">
			</td>
			<td class="tbYellow"  align="left" >
				區域
			</td>
			<td class="tbYellow2"  id="CRED_DEPTS">
		       	<c:forEach var="CRED_DEPT" items="${CRED_DEPT_NMS_LIST}">
					<c:out value='${CRED_DEPT}' /><br>
		       	</c:forEach>
			</td>
			<td class="tbYellow"  align="left" >
				出單種類
			</td>
			<td class="tbYellow2" >
				<select name="ISSUE_CODE" id="ISSUE_CODE">
					<option value=''>全部</option>
			       	<c:forEach var="map" items="${ISSUE_CODE_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE3' value=3>歸檔確認出單日
			</td>
			<td class="tbYellow2" colspan='2'>
				<input name="ISSUE_DATE1_STR" id='ISSUE_DATE1_STR' type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${ISSUE_DATE1_STR}">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('ISSUE_DATE1_STR'))">
				~
				<input name="ISSUE_DATE1_END" id='ISSUE_DATE1_END' type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${ISSUE_DATE1_END}">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('ISSUE_DATE1_END'))">
			</td>
			<td class="tbYellow" align="left" >保單起迄</td>
			<td class="tbYellow2">
				<input name="POLNO_STR" id="POLNO_STR" type="text" class="textBox" onblur="this.value = this.value.toUpperCase()"/>-
				<input name="POLNO_END" id="POLNO_END" type="text" class="textBox" onblur="this.value = this.value.toUpperCase()"/>				
			</td>
			<td class="tbYellow" align="left" >
				區域
			</td>
			<td class="tbYellow2" >
				<select name="CRED_DEPT" id="CRED_DEPT">
					<option value=''>請選擇</option>
			       	<c:forEach var="map" items="${CRED_DEPT_OPTLIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>
			<td class="tbYellow" align="left" >
				出單種類
			</td>
			<td class="tbYellow2" >
				<select name="ISSUE_CODE2" id="ISSUE_CODE2">
					<option value=''>請選擇</option>
			       	<c:forEach var="map" items="${ISSUE_CODE_LIST2}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan = "10" align = "center">
				<input id = "btn_file" type = "button" class = "button" value = "歸檔"/>
				<input id = "btn_cancelFile" type = "button" class = "button" value = "取消歸檔"/>
				<input id = "btn_confirm" type = "button" class = "button" value = "確認"/>
				<input id = "btn_expense" type = "button" class = "button" value = "新增批單火險管理費"/>
			</td>
		</tr>
	</table>
	</form>
	
	<form id="form2" name="form2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id='grid1' width="100%"></table>
	</form>
</body>
</html>