<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSE10701.jsp
功能：管理費用作業
作者：徐麗雲
完成：2013/06/27

[20240207]
難字調整
高強禾
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<%-- [20240207] 難字調整 --%>
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


Event.observe(window, 'load', new DSE10701().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE10701(){
	
	var valid1;
	var valid2;
	var valid3;
	var valid4;
	var grid;	
	var grid1;
	var LOAN_ID = '${LOAN_ID}';
	var REFER_ID = '${REFER_ID}';
	<%-- [20240207] 移除var BORROW_NAME = '${BORROW_NAME}' --%>
	var EXPENSE_KIND_LIST = '${EXPENSE_KIND_LIST}';
	
	//按鈕授權
	function buttonAuth() {
		var authButtons = { 
			B0003 : 'btn_insert' ,
			B0004 : 'btn_update',
			B0005 : 'btn_delete'		
		};
		<dz:grantButtons FUNC_ID ="DSE10701"/>
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_0701/" + actionName,
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
	
	//檢核	
	function initValidation(){

		Validation.addAllThese([
			[ 'EXPENSE_KIND_required',  '請輸入分類!',
				function(v,elem){					
					if($F('LAW_STAGE') != '00'){					
						return v;
					}else{						
						return true;
					}
				}
			],
			[ 'chkEXPENSE_AMT',  '請輸入大於零之數值',
				function(v,elem){
					if(v==0){
						return false;
					}
					return  Validation.get('validate-digits').test(v);				
				}
			]
		]);
		
		valid1 = new Validation("table_A", { focusOnError:true, immediate:false, mode : 'validator'});
		valid1.define( "EXPENSE_KIND_required" , { id: "EXPENSE_KIND"  } );//分類	
		valid1.define( "chkEXPENSE_AMT" , { id: "EXPENSE_AMT"  } );	
		
		
		valid2 = new Validation("table_A", { focusOnError:true, immediate:false, mode : 'validator'});
		valid2.define( "required" , { id: "DELETE_REASON"  } );//刪除理由
		
		valid3 = new Validation("table_A", { focusOnError:true, immediate:false, mode : 'validator'});
		valid3.define( "EXPENSE_KIND_required" , { id: "EXPENSE_KIND"  } );//分類	
		valid3.define( "chkEXPENSE_AMT" , { id: "EXPENSE_AMT"  } );	
		valid3.define( "validate-selection" , { id: "LAW_STAGE"  } );	
		
		valid4 = new Validation("table_A", { focusOnError:true, immediate:false, mode : 'validator'});
		valid4.define( "required" , { id: "MEMO"  } );//備註
	}
	
	//各種action
	var actions = {
		//畫面A區資料存成inputMap
		storeInputMap : function(operation,oriRecord){
			var tmpMap = {};
			<%-- [20240207] 增加BORROW_NAME --%>
			$w('LOAN_ID LAW_STAGE EXPENSE_ITEM EXPENSE_KIND DELETE_REASON BORROW_ID MEMO BORROW_NAME').each(
				function(id){						
					tmpMap[id] = $(id).value;
				}			
			);
			tmpMap.REFER_ID = $('REFER_ID').innerHTML;
			<%-- [20240207] 移除$('BORROW_NAME').innerHTML --%>
			tmpMap.EFFECT_DATE = toY2K($F('EFFECT_DATE'));
			tmpMap.EXPENSE_AMT = $('EXPENSE_AMT').getValue();
			if(operation != 'I'){
				tmpMap.SER_NO = oriRecord.SER_NO;
				tmpMap.oEFFECT_DATE = oriRecord.EFFECT_DATE;
				tmpMap.oEXPENSE_ITEM = oriRecord.EXPENSE_ITEM;
				tmpMap.oLAW_STAGE = oriRecord.LAW_STAGE;
			}
			if ("00" == tmpMap['LAW_STAGE']){
				tmpMap['LAW_STAGE'] = '';
			}
			return tmpMap;		
		},
		//畫面初始
		initTable : function(rtnList,deleteList){
			
			$w('LOAN_ID EFFECT_DATE EXPENSE_ITEM EXPENSE_KIND EXPENSE_AMT DELETE_REASON MEMO').each(
				function(id){						
					$(id).value = '';
				}			
			);		
			$('REFER_ID').innerHTML = REFER_ID;
			<%-- [20240207] 改用$F('BORROW_NAME')取值 --%>
			var BORROW_NAME = $F('BORROW_NAME');
			<%-- [20240207] $('BORROW_NAME').innerHTML改為$('BORROW_NAME').setValue --%>
			$('BORROW_NAME').setValue(BORROW_NAME ? CSRUtil.maskHandler.getMaskName(BORROW_NAME) : '');
			$('LOAN_ID').enable();
			grid.load(rtnList || []);
			grid1.load(deleteList || []);
			//20190927問題單編號 20190927-0107  
			//畫面進入時未預設費用原因的值，導致未連動產生對應費用項目，而是全部費用項目都列出來選，致使資管科選到錯的費用項目。
			$('LAW_STAGE').value = "00";			
			actions.getEXPENSE_ITEM_LIST();
		
		},
		//將B區資料檢視在A區
		showData : function(record){
			valid3.reset();
			<%-- [20240207] 增加BORROW_NAME --%>
			$w('LOAN_ID EXPENSE_ITEM EXPENSE_KIND DELETE_REASON MEMO MM_CODE BORROW_NAME').each(
				function(id){
					$(id).value = record[id] || '';
				}			
			);
			//20190927問題單編號 20190927-0107  
			//畫面進入時未預設費用原因的值，導致未連動產生對應費用項目，而是全部費用項目都列出來選，致使資管科選到錯的費用項目。
			$('LAW_STAGE').value = record['LAW_STAGE'] || "00";
			if($F('LAW_STAGE')){				
				actions.getEXPENSE_ITEM_LIST(record['EXPENSE_ITEM']);
			}else{
				$('EXPENSE_ITEM').length=0;
				$('EXPENSE_ITEM').add(new Option("",""));
				<c:forEach var="map" items="${EXPENSE_ITEM_LIST}">
					$('EXPENSE_ITEM').add(new Option("${map.value}", "${map.key}"));
				</c:forEach>
				$('EXPENSE_ITEM').value=record['EXPENSE_ITEM']
			}
			
			$('REFER_ID').innerHTML = record.REFER_ID;
			<%-- [20240207] 移除$('BORROW_NAME').innerHTML --%>
			$('EFFECT_DATE').value = Date.toInputROC( record.EFFECT_DATE || '' ,'');
			$('EXPENSE_AMT').value = record.EXPENSE_AMT ? CSRUtil.$fmt(record.EXPENSE_AMT,'#,###') : '0';
			$('LOAN_ID').disable();
		
		},
		//費用原因選單連動
		getEXPENSE_ITEM_LIST : function(recEXPENSE_ITEM){
			ajaxPost( 'getEXPENSE_ITEM_LIST' , { LAW_STAGE : $F('LAW_STAGE')},
				function(resp){	
					var EXPENSE_ITEM_LIST = resp.EXPENSE_ITEM_LIST || [];
					$('EXPENSE_ITEM').length=0;
					//$('EXPENSE_ITEM').update();
					if(EXPENSE_ITEM_LIST.length != 0){
						for (key in EXPENSE_ITEM_LIST){
							$('EXPENSE_ITEM').add(new Option(EXPENSE_ITEM_LIST[key], key));
						}
					}
					$('EXPENSE_ITEM').value=recEXPENSE_ITEM;
					actions.getEXPENSE_KIND();
					
				}
			);
		},
		//費用項目選單連動
		getEXPENSE_KIND : function(){
			
			if ($F('EXPENSE_ITEM') == "54" || $F('EXPENSE_ITEM') == "55" || $F('EXPENSE_ITEM') == "56" || $F('EXPENSE_ITEM') == "59"){
			    $('EFFECT_DATE').value = '${ROC_DATE}';
			}
			
			
			ajaxPost( 'getEXPENSE_KIND' , { LAW_STAGE : $F('LAW_STAGE'), EXPENSE_ITEM : $F('EXPENSE_ITEM') },
				function(resp){		
					
					$('EXPENSE_KIND').value = resp.EXPENSE_KIND;
				}
			);
		},
		//取得理財型判別碼
		getMM_CODE : function(){
			ajaxPost( 'getMM_CODE' , { LOAN_ID : $F('LOAN_ID')},
				function(resp){	
					$('MM_CODE').value = resp.MM_CODE || '';
				}
			);
		}
	};	
		
	//按鈕功能	
	var buttons = {
		//回上頁
		doBack : function(){
			CSRUtil.linkBack();
		},
		//初始查詢
		doQuery : function(){
			ajaxPost( 'query' , { REFER_ID : REFER_ID,LOAN_ID : LOAN_ID},
				function(resp){
					
				
						actions.initTable(resp.rtnList,resp.deleteList);
						if(REFER_ID){
							$('table_A').show();
							var LOAN_ID_LIST = resp.LOAN_ID_LIST || [];									
							LOAN_ID_LIST.each(
								function(data) {
									$('LOAN_ID').add(new Option(data, data));
								}
							);
						}else{
							$('table_A').hide();
						}
				},
				function(resp){				
					grid.load([]);
					grid1.load([]);
					$('table_A').hide();
				}
			);
		},
		//新增
		doInsert : function(){
		
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			
			if ($F('EXPENSE_ITEM') == '30') {
			
				valid4.reset();			
				if(!valid4.validate()){
					return;
				}
				if(!confirm('回復火險管理費請至火險作業>火險保險費作業。\n新增火險管理費請於備註欄位輸入保單號碼或批單號碼。\n批單件請輸入批單號碼。\n請確認輸入資料是否正確?')){
					return;			
				}

			}
			
			if ($('MM_CODE').value = '1') {
				if ($F('EXPENSE_ITEM') == '30' || $F('EXPENSE_ITEM') == '28') {
					alert('本件相關管理費用若有異動，將不再另行發送訊息通知客戶、經手人!');
				}
			}
			
			var inputMap = actions.storeInputMap('I','');
			//alert(REFER_ID);
			ajaxPost( 'insertQry' , { LOAN_ID : $F('LOAN_ID') },
			
								
					function(resp){	
						
						if (resp.TrnasExtract  == "Y"){
						   if(!confirm('本次期款已抽件，轉帳扣款中，若輸入費用，可能造成扣款成功卻無法入帳，僅能掛電腦暫收，實際上等於未繳，易造成糾紛及後續帳務處理之困難。除要立即開單繳費者外，請於轉帳扣款作業完畢後(確定轉帳成功或不成功後)，再行輸入費用\n是否確定輸入費用？')) {
								return ;
							}else{
								
								ajaxPost( 'insert' , { REFER_ID : REFER_ID, LOAN_ID : LOAN_ID, inputMap : Object.toJSON(inputMap)},
									function(resp){	
																    
										actions.initTable(resp.rtnList,resp.deleteList);
										
									}
								);
							}
						
						}else{
						
						
						  
							ajaxPost( 'insert' , { REFER_ID : REFER_ID, LOAN_ID : LOAN_ID, inputMap : Object.toJSON(inputMap)},
								
								function(resp){	
									
									actions.initTable(resp.rtnList,resp.deleteList);
									
								}
							);										
						}
					}
				);		
		},
		//修改
		doUpdate : function(action){
			
			var tmpList = grid.getCheckedRecord();			
			if( tmpList.length == 0 ){
				alert('請先選擇欲修改之資料!');
				return;			
			}
			
			valid3.reset();			
			if(!valid3.validate()){
				return;
			}
			
			if ($F('EXPENSE_ITEM') == '30') {
			
			    valid4.reset();			
				if(!valid4.validate()){
					return;
				}
				if(!confirm('回復火險管理費請至火險作業>火險保險費作業。\n火險管理費請於備註欄位輸入保單號碼或批單號碼。\n批單件請輸入批單號碼。\n請確認輸入資料是否正確?')){
					return;			
				}
			}
			
			if ($('MM_CODE').value = '1') {
				if ($F('EXPENSE_ITEM') == '30' || $F('EXPENSE_ITEM') == '28') {
					alert('本件相關管理費用若有異動，將不再另行發送訊息通知客戶、經手人!');
				}
			}
			
			var inputMap = actions.storeInputMap('U',tmpList[0]);
			
			//發送ajax
			ajaxPost( 'update' , {REFER_ID : REFER_ID, LOAN_ID : LOAN_ID,inputMap : Object.toJSON(inputMap)},
				function(resp){
					actions.initTable(resp.rtnList,resp.deleteList);
				}				
			);		
		},	
		//刪除
		doDelete : function(action){
		
			var tmpList = grid.getCheckedRecord();			
			if( tmpList.length == 0 ){
				alert('請先選擇欲刪除之資料!');
				return;			
			}
			
			valid2.reset();
			if(!valid2.validate()){
				return;
			}
			
			if(!confirm('該筆紀錄將會刪除，請確認是否繼續?')){
				return;			
			}
			
			if ($('MM_CODE').value = '1') {
				if ($F('EXPENSE_ITEM') == '30' || $F('EXPENSE_ITEM') == '28') {
					alert('本件相關管理費用若有異動，將不再另行發送訊息通知客戶、經手人!');
				}
			}
			
			var inputMap = actions.storeInputMap('D',tmpList[0]);
			
			//發送ajax
			ajaxPost( 'delete' , {REFER_ID : REFER_ID ,LOAN_ID : LOAN_ID, inputMap : Object.toJSON(inputMap)},
				function(resp){	
					actions.initTable(resp.rtnList,resp.deleteList);
				}				
			);	
		}
		
	};
	

	return{
	
		initApp : function(){
		
			
			PageUI.createPageWithAllBodySubElement('DSE10701','法務件','管理費用作業',1);
			$('table_A').hide();
			
			//產生 Grid 物件	
			grid = new TableUI ( 
				{ table: $('grid'), pageSize: 20, allSortable:true, overDiv:false,
				  autoCheckBox :{
						type :'radio',
						action: function(checkbox , boxStatus , records) {
							//將B區選取資料顯示於畫面A區
							actions.showData(records[0]);
						}
						,genRule:function(record , value){ 						
							return record.RADIO_DISPLAY == '0' ? true : false;//0:顯示 1:不顯示
						}	
				 },
	            <%-- [20240207] 難字調整 --%>
	            afterLoad: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	            },
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	            },
				column : [
					{header: '貸款帳號' , key : 'LOAN_ID'},
					{header: '原貸帳號' , key : 'REFER_ID'},
					<%-- [20240207] 難字調整：借款人 --%>
					{header: '借款人' , key : 'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" },
						render : function(rec,val){
							return val ? CSRUtil.maskHandler.getMaskName(val) : '';						
						}					
					},
					{header: '生效日期' , key : 'EFFECT_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}				
					},
					{header: '項目序號' , key : 'SER_NO'},
					{header: '費用原因' , key : 'LAW_STAGE_NM'},
					{header: '費用項目' , key : 'EXPENSE_ITEM_NM'},
					{header: '分類' , key : 'EXPENSE_KIND_NM'},
					{header: '費用金額' , key : 'EXPENSE_AMT'
						,render:function(record,value){
							return value ? CSRUtil.$fmt(value,'#,###') : '0';
						}
					},
					{header: '沖銷與否' , key : 'ACCOUNT_STATUS_NM'},
					{header: '沖銷日期' , key : 'PAY_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}					
					},
					<%-- [20240207] 難字調整：輸入人員 --%>
					{header: '輸入人員' , key : 'INPUT_NM', attrs:{ style:"font-family:'EUDC'" }},
					{header: '輸入日期' , key : 'INPUT_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					}
				]
			});	
			
			//產生 Grid1 物件	
			grid1 = new TableUI ( 
				{ table: $('grid1'), pageSize: 20, allSortable:true, overDiv:false,
		        <%-- [20240207] 難字調整 --%>
	            afterLoad: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	            },
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	            },
				column : [
					{header: '貸款帳號' , key : 'LOAN_ID'},
					{header: '原貸帳號' , key : 'REFER_ID'},
					<%-- [20240207] 難字調整：借款人 --%>
					{header: '借款人' , key : 'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }
						,render : function(rec,val){
							return val ? CSRUtil.maskHandler.getMaskName(val) : '';						
						}
					
					},
					{header: '生效日期' , key : 'EFFECT_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}					
					},
					{header: '項目序號' , key : 'SER_NO'},
					{header: '費用原因' , key : 'LAW_STAGE_NM'},
					{header: '費用項目' , key : 'EXPENSE_ITEM_NM'},
					{header: '分類' , key : 'EXPENSE_KIND_NM'},
					{header: '費用金額' , key : 'EXPENSE_AMT'
						,render : function(record, value){
							return value ? CSRUtil.$fmt(value,'#,###') : '0';
						}
					},
					{header: '刪除理由' , key : 'DELETE_REASON'},
					<%-- [20240207] 難字調整：輸入人員 --%>
					{header: '輸入人員' , key : 'INPUT_NM', attrs:{ style:"font-family:'EUDC'" }},
					{header: '輸入日期' , key : 'INPUT_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}						
					},
					<%-- [20240207] 難字調整：刪除人員 --%>
					{header: '刪除人員' , key : 'DELETE_NM', attrs:{ style:"font-family:'EUDC'" }},
					{header: '刪除日期' , key : 'DELETE_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}						
					}
				]
			});				
							
			//按鈕事件監聽
			$('btn_insert').observe('click', buttons.doInsert);
			$('btn_update').observe('click', buttons.doUpdate);
			$('btn_delete').observe('click', buttons.doDelete);
			$("btn_back").observe('click',buttons.doBack);		
			$("LAW_STAGE").observe('change',actions.getEXPENSE_ITEM_LIST);
			$("EXPENSE_ITEM").observe('change',actions.getEXPENSE_KIND);
			$("LOAN_ID").observe('change',actions.getMM_CODE);
			
			initValidation();
			
			buttons.doQuery();//初始查詢
			
			autoFormatToNumber();
			
			buttonAuth();
			
			PageUI.resize();

			displayMessage();
			
			
						
		}
	}
}
</script>
</head>

<body>
<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
        
		<table id ="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					貸款帳號
				</td>
				<td class="tbYellow2" width="10%">
					<select id="LOAN_ID" class="textBox2 validate-selection" fieldName = "貸款帳號">
						<option value="">請選擇</option>
					</select>	
					<input type="HIDDEN" ID="MM_CODE" NAME="MM_CODE" >	
				</td>
				<td class="tbYellow" width="10%" align="left" >
					原貸帳號
				</td>
				<td class="tbYellow2" width="10%">
					<span id="REFER_ID"></span>
				</td>
				<td class="tbYellow" width="10%" align="left" >
					借款人
				</td>
				<td class="tbYellow2" width="10%">
					<%-- [20240207] 難字調整：借款人，因為會取得文字，所以span改為input，並改為EL設定預設值 --%>
					<input type="text" id="BORROW_NAME" name="BORROW_NAME" alt="ch" class="textDisable" value="${BORROW_NAME}" readonly />
				</td>
				<input type="hidden" id="BORROW_ID" value="${BORROW_ID}"/>
				<td class="tbYellow" width="10%" align="left" >
					生效日期
				</td>
				<td class="tbYellow2" >
					<input id="EFFECT_DATE" datatype="ROCdate" type="text" class="textBox2 required validate-ROCDate" size="10" maxlength="9" fieldName = "生效日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('EFFECT_DATE'))" />
				</td>		
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					費用原因
				</td>
				<td class="tbYellow2" width="10%">
					<select id="LAW_STAGE" class="textBox2 " fieldName = "費用原因">
						<c:forEach items="${LAW_STAGE_LIST}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>
				<td class="tbYellow" width="10%" align="left" >
					費用項目
				</td>
				<td class="tbYellow2" width="10%">
					<select id="EXPENSE_ITEM" class="textBox2 validate-selection" fieldName = "費用項目">
						<c:forEach items="${EXPENSE_ITEM_LIST}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>
				<td class="tbYellow" width="10%" align="left" >
					分類
				</td>
				<td class="tbYellow2" width="10%">
					<select id="EXPENSE_KIND" class="textBox2" fieldName = "分類">
						<c:forEach items="${EXPENSE_KIND_LIST}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>				
				<td class="tbYellow" width="10%" align="left" >
					費用金額
				</td>
				<td class="tbYellow2">
					<input id="EXPENSE_AMT"  type="text" datatype="number" pattern="#,###" class="textBox2 " fieldName = "費用金額"/>
				</td>				
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					備註
				</td>
				<td class="tbYellow2" colspan="7">
					<input id="MEMO"  type="text" class="textBox2" size="100" maxlength="100" fieldName = "備註"/>
					火險管理費請於備註欄位輸入保單號碼或批單號碼
				</td>			
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					刪除理由
				</td>
				<td class="tbYellow2" colspan="7">
					<input id="DELETE_REASON"  type="text" class="textBox2" size="100" maxlength="100" fieldName = "刪除理由"/>
				</td>				
			</tr>
			<tr>
				<td class="tbBox2" colspan="8" align="center">
					<input id = "btn_insert" type = "button" class = "button" value = "新增"/>						
					<input id = "btn_update" type = "button" class = "button" value = "修改"/>						
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"/>	
					<input id = "btn_back" type = "button" class = "button" value = "上一頁"/>	
				</td>				
			</tr>		
		</table>		
	
		<table id = "grid" ></table>	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0"  align="center">
					<span style="font-weight: bold;">刪除紀錄</span>				
				</td>
			</tr>
		</table>	
		<table id = "grid1" ></table>
</form>	
</body>
</html>