<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSA24000.jsp
功能：匯款掃描作業
作者：陳子榮
完成：2019/3/15


[20210609] 修改件：
	申請書210510001101:為減少客訴，提升匯款效率，調整新件為實體匯款，調整相關系統作業畫面。
	(1) 新增聯繫事項-對保文件補全的項目改成下拉式選單，並新增項目
[20210617] 優化：
	增加匯款後補全項目及審核流程

[20240729] 修改件 陳勁谷 難字修改
-->

<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>

<title></title>
<!--匯入外部Javascript 與 css-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type="text/JavaScript" src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript'>

<%-- 產生畫面物件 --%>
Event.observe(window, 'load', new DSA24000().initApp);

function DSA24000(){

	<%-- Table UI物件 --%>
	var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA2_4000/');
	<%--前次查詢條件--%>
	var reQueryMap = {} ;
	var valid;	
	var confirmTimes = 0;
		
	<%--按鈕授權--%>
	function buttonAuth(){
		var authButtons = {
			B0254:"btn_Scan", 
			B0044:"btn_Acept", 
			B0028:"btn_Confirm", 
			B0003:"btn_Insert", 
			B0004:"btn_Modify", 
			B0005:"btn_Delete",
			B0017:"btn_CaptAgree",
			B0019:"btn_BossAgree",
			B0020:"btn_BossReject"			
		};		
		<dz:grantButtons FUNC_ID="DSA24000"/>
	};	
	
	var actions = {
		defineValid : function(action){
		
			valid.reset();
			valid.clear();
			
			if(action == 'D'){
				Validation.addAllThese([
					['valid-OverOneMonth', '查詢日期區間不可大於1個月!', function(){					
					var days = diffDayY2K($F('QRY_STR_DATE'), $F('QRY_END_DATE'));
					if( days &&  days >31){							
						return false;
					}						
					return true;
					}]
				]);
				valid.define('required' , [{ id : "QRY_STR_DATE" , errMsg:"請輸入正確的查詢日期"}] );
				valid.define('required' , [{ id : "QRY_END_DATE" , errMsg:"請輸入正確的查詢日期"}] );
				valid.define('validate-ROCDate-Interval' , [{ id : "QRY_STR_DATE" , errMsg :"日期區間有誤" },{ id : "QRY_END_DATE" , errMsg :"日期區間有誤"}] );
				valid.define('valid-OverOneMonth' , [{ id : "QRY_STR_DATE" }] );
				valid.define('valid-OverOneMonth' , [{ id : "QRY_END_DATE" }] );				
			}else if(action == 'A'){
				valid.define('required' , [{ id : "APPLY_ID" , errMsg:"請輸入受理編號"}] );
			}else{
				valid.define('required' , [{ id : "CONTACT_ITEM" , errMsg:"聯繫事項不可為空"}] );
			}
			
			return valid.validate();
		
		},
		getReqMap : function (){					
			var regMap = {				
				'QUERY_KIND' :     $F('QUERY_KIND'),
				'APPLY_ID'   :     $F('APPLY_ID'),
				'QRY_STR_DATE' :   $F('QRY_STR_DATE'),
				'QRY_END_DATE' :   $F('QRY_END_DATE')			
			};
			return regMap;
	    },
	    getActionsReqMap : function (){					
			var regMap = {						
				'QUERY_KIND' :     $F('QUERY_KIND'),//Ask SA
				'APPLY_ID'  :      $F('APPLY_ID'),
				'CONTACT_ITEM':    $F('CONTACT_ITEM'),
				'CONTACT_DETAIL':  actions.getCheckedCONTACT_DETAIL(),
				'NOTE'        :    $F('NOTE')			
			};			
			return regMap;
	    }, 	     
	    getCheckedCONTACT_DETAIL : function(){
			var contact_detail_comma='';
			<%-- [20210609] 新增聯繫事項-下拉選單 --%>
			if('01' == $F('CONTACT_ITEM')){
				$$('input:checked[type="checkbox"][name="CONTACT_DETAIL_checkbox"]').each(			    		
					function(ele){			
						contact_detail_comma += ',' + ele.value;
					}
				);	
			}else if('03' == $F('CONTACT_ITEM')){
				return $F('CONTACT_DETAIL_select');
			}
			return contact_detail_comma.substring(1); 
		},		
		showCONTACT_DETAIL : function(records){ 
			var detail_array=[];
			
			if(records){
				detail_array = records.split(',');
			};
			<%-- [20210609] 新增聯繫事項-下拉選單 --%>
			if('01' == $F('CONTACT_ITEM')){
				$$('input[type="checkbox"][name="CONTACT_DETAIL_checkbox"]').each(
					function(ele){										
						ele.checked =false;												
						for(var i=0; i<detail_array.length; i++){											
							if(ele.value == detail_array[i]){																											
								ele.checked =true;							
								delete detail_array[i];		
							}
						}
					}
				);	
			}else if('03' == $F('CONTACT_ITEM')){
				$('CONTACT_DETAIL_select').setValue(records);
			}
		},
		doQUERY_KIND : function ()
		{	<%--CONTACT_ITEM連動--%>
		    				
			if('00'==$('QUERY_KIND').getValue()){			
			<%--受理編號--%>
				$("QRY_STR_DATE").setValue('');
				$("QRY_END_DATE").setValue('');
				$("QRY_STR_DATE").hide();
				$("FROM_TO").update('');
				$("QRY_END_DATE").hide();
				$("APPLY_ID").show();
				
			}else if('02'==$('QUERY_KIND').getValue()){			
			<%--退件日期--%>
				$("QRY_STR_DATE").show();
				$("FROM_TO").update('~');
				$("QRY_END_DATE").show();
				$("APPLY_ID").setValue('');
				$("APPLY_ID").hide();
			}else{ 
				$("APPLY_ID").setValue('');
				$("QRY_STR_DATE").setValue('');
				$("QRY_END_DATE").setValue('');
				$("APPLY_ID").hide();
				$("QRY_STR_DATE").hide();
				$("FROM_TO").update('');
				$("QRY_END_DATE").hide();
			}	
			valid.reset();							
				
		},
		doCONTACT_ITEM : function ()
		{	<%--CONTACT_ITEM連動--%>	
			
			ajaxRequest.post(
				'contact_item',
				{ CONTACT_ITEM : $F('CONTACT_ITEM')},	
							
				function(resp){						
					
					$('CONTACT_DETAIL_SPAN').update();
					if(resp.CONTACT_ITEM_LIST){	
						
						var dataKey = Object.keys(resp.CONTACT_ITEM_LIST);
						
						if('01'==$F('CONTACT_ITEM')){
							dataKey.each(
								function(key){							
									var inputBox = new Element('input');
									inputBox.type = 'checkbox';
									inputBox.name = 'CONTACT_DETAIL_checkbox';
									inputBox.value = key;
									$('CONTACT_DETAIL_SPAN').appendChild( inputBox );
									var textNode = document.createTextNode(resp.CONTACT_ITEM_LIST[key]);
									$('CONTACT_DETAIL_SPAN').appendChild(textNode);
								}
							);
						} else {
							<%-- [20210609] 新增聯繫事項-下拉選單 --%>
							var selectBox = new Element('select');
							selectBox.id = 'CONTACT_DETAIL_select';
							selectBox.name = 'CONTACT_DETAIL_select';
							$('CONTACT_DETAIL_SPAN').appendChild( selectBox );
							dataKey.each(
								function(key){
									var option = new Element('option');
									option.value = key;
									option.innerHTML = resp.CONTACT_ITEM_LIST[key];
									selectBox.appendChild(option);
								}
							);
						}
						
						if('01'==$F('CONTACT_ITEM')){
							$("CONTACT_DETAIL_SPAN").show();
						}else if('03'==$F('CONTACT_ITEM')){
							$("CONTACT_DETAIL_SPAN").show();
						}else{
							$("CONTACT_DETAIL_SPAN").hide();
						}
					}else{						
						$("CONTACT_DETAIL_SPAN").hide();					
					}
				});
				valid.reset();				
		}	
	};	
	
	var buttons = {		
		doQuery : function (){		    		 
			<%--查詢種類不可為空--%>			
			<%--SA:預設值：受理編號, 請選擇拿掉--%>			
			if('00' == $F('QUERY_KIND')){	
				<%--查詢條件為「受理編號」--%>					
				if(!actions.defineValid('A')){
					return;
			    }				
			}else if('02' == $F('QUERY_KIND')){
				<%--查詢條件為「退件日期」--%>
				if(!actions.defineValid('D')){
					return;
			    }				
			}	
			<%--[20190322] 將【B區】清空--%>
			$('CONTACT_ITEM').setValue('');
			$('CONTACT_DETAIL_SPAN').update();
			$('NOTE').setValue('');
			grid.load([]);
				
			ajaxRequest.post(
				'query',
				{ reqMap : Object.toJSON(actions.getReqMap())},				
				function(resp){						
					grid.load(resp.rtnList||[]);
					$('BORROW_NAME').update(resp.BORROW_NAME);
					<%--確定可查詢 將查詢條件代入 方便重查--%>
					reQueryMap = actions.getReqMap();
				},
				function(resp){					
					grid.load([]);	
					$('BORROW_NAME').update('');
					reQueryMap = {} ;							
		 	 });
		},	
		
		doInsert :function (){
			<%--必須先用「受理編號」查詢成功--%>			
			if(!reQueryMap.APPLY_ID){
				alert('必須先用「受理編號」查詢成功');
				return;
			}
			
			if('00' != $F('QUERY_KIND')){					
				alert('請先用「受理編號」進行查詢');
				return;		
			}
			
			if(reQueryMap.APPLY_ID != $F('APPLY_ID')){
				alert('查詢條件有異動，請重新查詢');
				return;
			}				
			
			<%--聯繫事項不可為空--%>
			if(!actions.defineValid('')){
					return;
			}	
			confirmTimes = 0;			
			ajaxRequest.post(
				'insert',
				{ reqMap : Object.toJSON(actions.getActionsReqMap())},				
				function(resp){
					<%--[20190322] 用confirm訊息--%>
					if(resp.errAlert){
					//確認ok , 繼續執行
						if(!confirm(resp.tempErrMsg)){							
							return;
						}
						confirmTimes++;						
						ajaxRequest.post( 'insert' , 
							{	reqMap : Object.toJSON(actions.getActionsReqMap()), confirm_Times :confirmTimes},
							function(resp2){								
								grid.load(resp2.rtnList||[]);
								$('BORROW_NAME').update(resp2.BORROW_NAME);	
	    					});
					}else{						
						grid.load(resp.rtnList||[]);
						$('BORROW_NAME').update(resp.BORROW_NAME);	
					
					}
										
					
				}
			);

		},
			
		doDelete : function (){	
		    <%--畫面程序檢核--%>		    
		    <%--需選取欲刪除的聯繫事項--%>
			var checkedRecords = grid.getCheckedRecord();	
			if(checkedRecords.length == 0){	
				alert('請選取欲刪除的資料');
				return;
			};			
			ajaxRequest.post(
				'delete',
				{ A196Map : Object.toJSON(checkedRecords[0]), reqMap : Object.toJSON(actions.getActionsReqMap())},				
				function(resp){						
					grid.load(resp.rtnList||[]);
			});			
		},	
		
		doModify : function (){		
			<%--畫面程序檢核--%>
			var checkedRecords = grid.getCheckedRecord();				
			if(checkedRecords.length == 0)
			{	alert('請選取欲修改的資料');
				return;
			};			
			<%--聯繫事項不可為空--%>
			if(!actions.defineValid('')){
				return;
			}		
			confirmTimes = 0;			
			ajaxRequest.post(
				'modify',
				{ A196Map : Object.toJSON(checkedRecords[0]), reqMap : Object.toJSON(actions.getActionsReqMap())},				
				function(resp){	
					<%--[20190322] 用confirm訊息--%>					
					if(resp.errAlert){
					//確認ok , 繼續執行
						if(!confirm(resp.tempErrMsg)){							
							return;
						}
						confirmTimes++;						
						ajaxRequest.post( 'modify' , 
							{ A196Map : Object.toJSON(checkedRecords[0]), reqMap : Object.toJSON(actions.getActionsReqMap()), confirm_Times :confirmTimes},
							function(resp2){								
								grid.load(resp2.rtnList||[]);
								$('BORROW_NAME').update(resp2.BORROW_NAME);	
	    					});
					}else{						
						grid.load(resp.rtnList||[]);
						$('BORROW_NAME').update(resp.BORROW_NAME);	
					
					}
					
				});
		},	
		
		doConfirm : function (){		
			<%--畫面程序檢核--%>		
			var checkedRecords = grid.getCheckedRecord();	
			if(checkedRecords.length == 0){	
				alert('請選取欲修改的資料');
				return;
			};					
			ajaxRequest.post(
				'confirm',
				{ A196Map : Object.toJSON(checkedRecords[0]), reqMap : Object.toJSON(actions.getActionsReqMap())},				
				function(resp){						
					grid.load(resp.rtnList||[]);
				});
		},
		doScan : function (){					
			<%--畫面程序檢核--%>
			<%--必須先用「受理編號」查詢成功--%>			
			if(!reQueryMap.APPLY_ID){
				alert('必須先用「受理編號」查詢成功');
				return;
			}
			if('00' != $F('QUERY_KIND')){					
				alert('請先用「受理編號」進行查詢');
				return;		
			}
			if(reQueryMap.APPLY_ID != $F('APPLY_ID') ){
				alert('查詢條件有異動，請重新查詢');
				return;
			}
														
			ajaxRequest.post(
				'scan',
				{ reqMap : Object.toJSON(actions.getActionsReqMap())},				
				function(resp){	
					if(resp.VSID){						
						<%--已掃描過，開啟popupwin DSA0_0201 (放款影像編輯)--%>
						<%--影像替換模式--%>						
						popupWin.windowOpen('/AVWeb/servlet/HttpDispatcher/AVB1_0201/prompt',{
				     	'parameters': {'APPLY_NO': resp.IMG_CASE_ID, 'LINK_FROM' : 'DSA24000'
				     	}, 'fullScreen': false, 'attributes': {'resizable': 'yes'},	'windowName': 'DSA24000'
			        	});
					}else{						
						<%--未掃描過，傳至AVB1_0200 (放款影像進件)--%>
						popupWin.windowOpen('/AVWeb/servlet/HttpDispatcher/AVB1_0200/prompt',{
							'parameters': {'LINK_FROM' : 'DSA24000'},
							'fullScreen': false, 'attributes': {'resizable': 'yes'}, 'windowName': 'DSA24000'
						});						
					}
				});
		},
		doAcept : function (){		
			<%--畫面程序檢核--%>
			<%--必須先用「受理編號」查詢成功--%>													
			if(!reQueryMap.APPLY_ID){
				alert('必須先用「受理編號」查詢成功');
				return;
			}
			if('00' != $F('QUERY_KIND')){					
				alert('請先用「受理編號」進行查詢');
				return;		
			}
			if(reQueryMap.APPLY_ID != $F('APPLY_ID')){
				alert('查詢條件有異動，請重新查詢');
				return;
			}
												
			<%--開啟影像元件DSA0_0201 (放款影像編輯)--%>
			popupWin.windowOpen('/AVWeb/servlet/HttpDispatcher/AVB1_0201/prompt',{
				'parameters': {'APPLY_NO': $F('APPLY_ID'), 'LINK_FROM' : 'DSA24000' },
				'fullScreen': false, 'attributes': {'resizable': 'yes'}, 'windowName': 'DSA24000'
            });
		},
		doCaptAgree : function (){		
			<%--畫面程序檢核--%>		
			var checkedRecords = grid.getCheckedRecord();	
			if(checkedRecords.length == 0){	
				alert('請選取欲同意的資料');
				return;
			};					
			ajaxRequest.post(
				'captAgree',
				{ A196Map : Object.toJSON(checkedRecords[0]), reqMap : Object.toJSON(actions.getActionsReqMap())},				
				function(resp){						
					grid.load(resp.rtnList||[]);
				});
		},
		doBossAgree : function (){		
			<%--畫面程序檢核--%>		
			var checkedRecords = grid.getCheckedRecord();	
			if(checkedRecords.length == 0){	
				alert('請選取欲同意的資料');
				return;
			};					
			ajaxRequest.post(
				'bossAgree',
				{ A196Map : Object.toJSON(checkedRecords[0]), reqMap : Object.toJSON(actions.getActionsReqMap())},				
				function(resp){						
					grid.load(resp.rtnList||[]);
				});
		},
		doBossReject : function (){		
			<%--畫面程序檢核--%>		
			var checkedRecords = grid.getCheckedRecord();	
			if(checkedRecords.length == 0){	
				alert('請選取欲退回的資料');
				return;
			};					
			ajaxRequest.post(
				'bossReject',
				{ A196Map : Object.toJSON(checkedRecords[0]), reqMap : Object.toJSON(actions.getActionsReqMap())},				
				function(resp){						
					grid.load(resp.rtnList||[]);
				});
		}
				
	};
		
	return {	
		initApp : function() {
			
			<cathay:LocaleDisplay sysCode='DS' dateFields='QRY_STR_DATE QRY_END_DATE' var='localeDisplay' />			
			PageUI.createPageWithAllBodySubElement('DSA24000', '核貸作業', '匯款掃描作業');			

			buttonAuth();
			valid = new Validation($('form1'), {useTitles:false, mode: "validate" });
						
			<%--設定 TableUI--%>
			grid = new TableUI({
			 	table: $('grid'),
				pageSize : 10,
				autoCheckBox:{type:'radio', text:'選擇', 
					action:function( node , boxStatus , records ){
						
						if (boxStatus) {
							$('CONTACT_ITEM').setValue(records[0].CONTACT_ITEM);
	                        ajaxRequest.setSynchronous(true);
	                        actions.doCONTACT_ITEM();
	                        ajaxRequest.setSynchronous(false);
	                        $('NOTE').setValue(records[0].NOTE);
	                        <%--如果選擇匯款影像補掃，則打開組長同意、主管同意和主管退回的按鈕，否則關閉--%>
	                        if('10' == records[0].CONTACT_ITEM){
	                        	$('btn_CaptAgree').enable();
	                        	$('btn_BossAgree').enable();
	                        	$('btn_BossReject').enable();
	                        }else{
	                        	$('btn_CaptAgree').disable();
	                        	$('btn_BossAgree').disable();
	                        	$('btn_BossReject').disable();
	                        	if('01'== records[0].CONTACT_ITEM){	
		                        	actions.showCONTACT_DETAIL(records[0].CONTACT_DETAIL);
		                        }else if('03'== records[0].CONTACT_ITEM){
		                        	actions.showCONTACT_DETAIL(records[0].CONTACT_DETAIL);
		                        }
	                        }
						}
                    },
                    genRule:function(record , value){
                    	if(record.CHANGE_TYPE == 'A'){//新增掃描(DP)
                    		return false;
                    	}
                    	return true;
                    }
				},
				column:[					
					{	header:'序號', 
						render: function(rec, val, sn, dataKey){
							return sn;
						}
					},
					{	header: '受理編號', key: 'APPLY_ID'},					
					<%--[20240729] 修改件 陳勁谷 難字修改 --%>
					{	header: '借款人', key: 'BORROW_NAME', attrs: {style:"font-family:'EUDC'"}},					
					{	header:"異動日期", key:"UPDATE_DATE", sortRule : 'datetime' },					
					<%--[20240729] 修改件 陳勁谷 難字修改 --%>
					{	header: '異動人員', key: 'UPDATE_NAME', attrs: {style:"font-family:'EUDC'"}},
					{	header: '異動種類', key: 'CHANGE_TYPE_NM'},
					{	header: '聯繫事項(備註)', key: 'CONTACT_ITEM',
							render:function(rec,val){
								return nullToChangeValue(rec.CONTACT_ITEM_NM,'') 
								+ ((rec.CONTACT_DETAIL) ? " : " + nullToChangeValue(rec.CONTACT_DETAIL_CN,'') : "") 
								+ ((rec.NOTE) ? " 、 "+nullToChangeValue(rec.NOTE,'') : ""  ); 
							} 
					},
					{	header: '退件日', key: 'RJT_DATE', sortRule : 'date' }
										
				]
			});					
			
			$("btn_Query").observe('click', buttons.doQuery);
			
			$("btn_Insert").observe('click', buttons.doInsert);		
			$("btn_Delete").observe('click', buttons.doDelete);
			$("btn_Modify").observe('click', buttons.doModify);
			$("btn_Confirm").observe('click', buttons.doConfirm);
			$("btn_CaptAgree").observe('click', buttons.doCaptAgree);
			$("btn_BossAgree").observe('click', buttons.doBossAgree);
			$("btn_BossReject").observe('click', buttons.doBossReject);
			
			<%--匯款影像掃描--%>
			$("btn_Scan").observe('click', buttons.doScan);
			<%--受理影像掃描--%>
			$("btn_Acept").observe('click', buttons.doAcept);
			<%--QUERY_KIND連動--%>
			$('QUERY_KIND').observe('change',actions.doQUERY_KIND); 
			<%--CONTACT_ITEM連動--%>
			$('CONTACT_ITEM').observe('change',actions.doCONTACT_ITEM);
			<%--CONTACT_ITEM 轉大寫--%>
			$('APPLY_ID').observe('blur', function(event){
				$('APPLY_ID').setValue($F('APPLY_ID').toUpperCase());
				$('APPLY_ID').setValue($F('APPLY_ID').trim());
			});	
				
			<%--初始時hidden--%>
			$("QRY_STR_DATE").hide();
			$("QRY_END_DATE").hide();
			$("CONTACT_DETAIL_SPAN").hide();	
			
			//接值有值，執行初始查詢
			if('${APPLY_ID}' && '${APPLY_ID}'!=''){
				$('APPLY_ID').setValue($F('APPLY_ID').toUpperCase());
				buttons.doQuery();
			}		
													 
			PageUI.resize();			
			displayMessage();		
		}	
	};	
}	
</script>

</head>
<body>
<form name='form1' id='form1'>
	<%-- query form--%>
	<table id="mainTable" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow">查詢種類</td>
			<td class="tbYellow2" colspan="2">
				
				<select name="TYPE" id="QUERY_KIND" title="查詢種類">					
					<c:forEach var="map" items="${QUERY_KIND_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
				<input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2" size="15" value="${APPLY_ID}" maxlength="11"/>
				<input id="QRY_STR_DATE" name="QRY_STR_DATE" type="text" class="textBox">				
				<span id="FROM_TO"></span>
				<input id="QRY_END_DATE" name="QRY_END_DATE" type="text" class="textBox">

			</td>
			<td class="tbYellow2" >		
				<button type="button" id="btn_Query" class="button">查詢</button>
				<button type="button" id="btn_Scan" class="button">匯款影像掃描</button>
				<button type="button" id="btn_Acept" class="button">受理影像掃描</button>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width= "10%">借款人姓名</td>
			<td class="tbYellow2" colspan="3">
				<%--[20240729] 修改件 陳勁谷 難字修改 --%>
				<span id="BORROW_NAME" style="font-family:'EUDC'"></span>
			</td>			 
		</tr>
		<tr>
			<td colspan="4" align="center">				
				<button type="button" id="btn_Insert" class="button">新增</button>
				<button type="button" id="btn_Modify" class="button">修改</button>
				<button type="button" id="btn_Delete" class="button">刪除</button>				
				<button type="button" id="btn_Confirm" class="button">確認</button>				
				<button type="button" id="btn_CaptAgree" class="button">組長同意</button>				
				<button type="button" id="btn_BossAgree" class="button">科主管同意</button>				
				<button type="button" id="btn_BossReject" class="button">科主管退回</button>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">聯繫事項</td>
			<td class="tbYellow2" width= "40%">
				<select name="TYPE" id="CONTACT_ITEM">
					<option value="">請選擇</option>
					<c:forEach var="map" items="${CONTACT_ITEM_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
				<span id="CONTACT_DETAIL_SPAN">
						
				</span>				
			</td>	
			<td class="tbYellow">備註</td>
			<td class="tbYellow2" >
				<input id="NOTE" name="NOTE" type="text" class="textBox2" size="70" maxlength="100"  />
			</td>			 		 
		</tr>
	</table>
	
	
	
</form>
	<%--query result--%>
	<table id="grid" class="grid"></table>	
</body>
</html>