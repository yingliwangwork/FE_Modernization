<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSC82900.jsp
功能：提前沖轉查詢
作者：溫子?
完成：2013/06/

[20230209] 
	新增債權人欄位做下拉式選單
	
[20230321] 修改程式  楊青峰
難字調整
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

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
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src='<%=htmlBase%>/CM/js/date.js'></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type="text/javascript" src='<%=htmlBase%>/CM/js/calendar.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/LocaleDisplay.js"></script>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC82900().initApp);

function DSC82900(){
var BALC_REASON_LIST = [];
var DEBTOR_MAP;
var DEBTOR_LIST;
var rtnList;
var grid;
var gridA;
var gridB;
var valid;
//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_2900/" + actionName,
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
	
function chkDate(){
	var tmpList = gridA.validCheckedOnTable();
	var errorObj = gridA.getCheckedErrorRecords();
       var ErrMsg='';
       var len = errorObj.length;
       if(len>0){
               for(var i =0 ; i<len ; i++ ){
                       var dataobj = errorObj[i];
                       ErrMsg = ErrMsg + "第" + dataobj['_tableuiSerialNumber'] + "筆,實繳日不可為空且須為日期格式!\n";
                       ErrMsg=ErrMsg+"\n\r";

               }
               alert(ErrMsg);
               return false;
       }
	
	return true;

}

<%-- [20230214] 欄位呈現時先抓DTDSC140上的欄位，前面加掛"現在_"，如果欄位為空值就不呈現--%>
function initDEBTOR_LIST(DEBTOR_ID, DEBTOR_NAME, node) {
		var elOptSel = document.createElement('option');
		elOptSel.text = '請選擇';
		elOptSel.value = '';
		node.add(elOptSel);
		
		//231017問題單號-20230912-0073暫收變更債務人選單調整 BY余凱鈞
		//存到資料庫的債務人，不管選擇借款人或是保證人，都會呈現【現在】的字眼，無法一目了然債務人身分
		//=>改成以借款人、保證人或繼承人_XXX呈現
		/*if (DEBTOR_ID) {
			var elOptNow = document.createElement('option');
			elOptNow.text = '現在_' + DEBTOR_NAME;
			elOptNow.value = DEBTOR_ID;
			node.add(elOptNow);
		}*/
		
		var ind=0;
		for(var index=0; index < DEBTOR_LIST.length; index++) {
			var targetMap = DEBTOR_LIST[index];
			var elOptNew = document.createElement('option');
			elOptNew.text =  targetMap['DEBTOR_NAME'];
			elOptNew.value = targetMap['DEBTOR_ID'];
			node.add(elOptNew);
			if (DEBTOR_ID && DEBTOR_ID == targetMap['DEBTOR_ID']) {
				ind = index + 1;
			}
		}
		
		if (DEBTOR_ID && ind>0) {
			node.options[ind].selected = true;
		}
	}

var buttons={

	doQuery : function(type){
		if(type=='I'){
			ajaxPost( 'query', {type:'I'}
						,function(resp){
							grid.load(resp.rtnList);
						},function(resp){
							grid.load([]);
			});
		}else {
			
			
			if($F('BALC_NO_Q')!=''&&($F('BALC_NO_Q').substring(0,2)!='CB' && $F('BALC_NO_Q').substring(0,2)!='CA')){
				alert("請輸入暫收資料(CB或CA)編號，謝謝!!");
				return;
			}
			var reqMap={
				BALC_NO : $F('BALC_NO_Q'),
				LOAN_ID : $F('LOAN_ID_Q')
			}
			ajaxPost( 'query', {reqMap : Object.toJSON(reqMap)}
						,function(resp){
							<%-- [20230209] 新增債務人下拉式選單 --%>
							DEBTOR_LIST = resp.DEBTOR_LIST ? resp.DEBTOR_LIST : [];
							rtnList = resp.rtnList;
							gridA = new TableUI(
							{table: $("gridA"),title:"變更原因備註",pageSize : 10, allSortable: false, overDiv:true,
							validateRecordCheckedOnly:true,
							autoCheckBox:{
								text:'選取', 
								type:'checkbox',
								isSelectAll:true },
								afterLoad: function() {
									if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
								},
								pageChange: function() {
									if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
								},
							validateRecord:function(rec,sn){
								var val = rec.REAL_PAYDT;
								if(!val || val == ""){
									return false;
								}
								if(!isDate(val)){ return false; }
								return true; 
							},
							column:[			
								{header:"暫應收編號", key:"BALC_NO"},
								{header:"暫收原因",key:"BALC_REASON",
									input:{
										type:'select',
										actionWhenStart:true,
										opts:BALC_REASON_LIST,
										action : function( node , dataObj , textDiv, record, isOnChange){
											if(isOnChange){ <%-- [20230209] 如果暫收原因選其它，債務人下拉連動預設有"請選擇"，別的選項皆預設"借款人"。 --%>
												var DEBTOR_NODEID =  dataObj[0]["BALC_NO"] + '_DEBTOR_ID';	
												var DEBTOR_ID = dataObj[0]['DEBTOR_ID']
												if(!DEBTOR_ID){
													if(node.value == 99) {
														$(DEBTOR_NODEID).options[0].selected = true;
													} else {
														$(DEBTOR_NODEID).options[1].selected = true;
													}
													$(DEBTOR_NODEID).simulate('change');
												}
											}
										} 
									}
								},
								{header:"債務人",key:"DEBTOR_ID",
									input:{
										type:'select',
										attrs: {'alt': 'ch'}, <%-- [20230321] --%>
										actionWhenStart:true,
										action : function( node , dataObj , textDiv, record, isOnChange){
											if(!isOnChange) {
												var DEBTOR_ID = dataObj[0]['DEBTOR_ID']
												var DEBTOR_NAME = dataObj[0]['DEBTOR_NAME']
												initDEBTOR_LIST(DEBTOR_ID, DEBTOR_NAME, node); 
												node.id = dataObj[0]["BALC_NO"] + '_DEBTOR_ID';
											}
											dataObj[0]["DEBTOR_ID"] = node.getValue() || '';
											var tempText = node.options[node.selectedIndex].text;
											if (tempText != '請選擇' && tempText != '') {
												dataObj[0]["DEBTOR_NAME"] = tempText.split('_')[1]; <%-- [20230214] 進資料庫只留姓名去除前贅字--%>
											} else {
												dataObj[0]["DEBTOR_NAME"] = '';
											}
										} 		
									},render:function( record , value){
										return value ? value : '';
									}
								},
								{header:"暫應收備註",key:"BALC_MEMO", render: function(rec, val, sn) {
									
									var input = new Element('input', {class:'textBox2', type:'text', name:'BALC_MEMO', id:'BALC_MEMO', maxlength: '50', alt: 'ch'});
									input.setValue(val);
									
									input.observe('blur', function(event) {
										rec['BALC_MEMO'] = $(event.target).getValue();
									});
									return input;
								}},
								{header:"實繳日",key:"REAL_PAYDT",sortRule:'rocdate', input:{
										type:"rocdate" 
									}}]
							});

							gridA.load(rtnList||[]);
							gridB.load(rtnList||[]);
							
							$('BTN_UPDATE').enable();
							$('BTN_CHANGE').enable();
						},function(resp){
							gridA.load([]);
							gridB.load([]);
							
							$('BTN_UPDATE').disable();
							$('BTN_CHANGE').disable();
			});
		}
	}
	,doUpdate : function(){

		var selectedList = gridA.getCheckedRecord(['BALC_NO','LOAN_ID','BALC_REASON','BALC_MEMO','REAL_PAYDT','DEBTOR_ID','DEBTOR_NAME']);<%-- [20230209] 新增 DEBTOR_ID DEBTOR_NAME --%>
		if(selectedList.length === 0){
			alert('請選擇欲變更資料!');
			return;
		}
		
		if(!chkDate()){
			return;
		}
		
		//用暫應收編號查詢時,只可能為一筆,須與查詢的編號相同
		if($F('BALC_NO_Q') && selectedList[0].BALC_NO!=$F('BALC_NO_Q')){
			alert('欲變更的編號與查詢的編號不同，請重新查詢，謝謝!!');
			return;
		}
		
		for(var i=0 ; i<selectedList.length;i++){
			var selectedMap = selectedList[i];
			if(!selectedMap.LOAN_ID && (selectedMap.BALC_NO.substirng(0,2)!='CB' && selectedMap.BALC_NO.substirng(0,2)!='CA')){
				alert('請輸入暫收資料(CB或CA)編號[暫收編號:'+selectedMap.BALC_NO+']，謝謝!!');
				return;
			}
		}
		
		ajaxPost( 'update', {reqList : Object.toJSON(selectedList)}
					,function(resp){
						grid.load(resp.rtnList);
						gridA.load([]);
						gridB.load([]);
					});
	}
	,doChange : function(){
	
		var selectedList = gridB.getCheckedRecord(['BALC_NO','LOAN_ID','NEW_LOAN_ID','MEMO']);
		if(selectedList.length === 0){
			alert('請選擇欲變更資料!');
			return;
		}
		
		//用暫應收編號查詢時,只可能為一筆,須與查詢的編號相同
		if($F('BALC_NO_Q') && selectedList[0].BALC_NO!=$F('BALC_NO_Q')){
			alert('欲變更的編號與查詢的編號不同，請重新查詢，謝謝!!');
			return;
		}
		
		for(var i=0 ; i<selectedList.length;i++){
			var selectedMap = selectedList[i];
			if(!selectedMap.NEW_LOAN_ID){
				alert('暫收編號:'+selectedMap.BALC_NO+',請輸入變更後貸款帳號，謝謝!!');
				return;
			}
		}
		
		ajaxPost( 'change', {reqList : Object.toJSON(selectedList)}
					,function(resp){
						grid.load(resp.rtnList);
						gridA.load([]);
						gridB.load([]);
					});

	}
	,doDelete : function(){
		var checkedRecord = grid.getCheckedRecord();
			if(checkedRecord.length==0){
				alert("請選取一筆資料");
				return;
			}
			if(!confirm('該筆變更紀錄將會全部刪除，請確認是否繼續?')){
				return;
			}
			ajaxPost( 'delete', {dataList:Object.toJSON(checkedRecord)}
				,function(resp){
					grid.load(resp.rtnList);		
				});
	}
	,doConfirm : function(){
		var checkedRecord = grid.getCheckedRecord();
			if(checkedRecord.length==0){
				alert("請選取一筆資料");
				return;
			}
			
			ajaxPost( 'confirm', {dataList:Object.toJSON(checkedRecord)}
				,function(resp){
					grid.load(resp.rtnList);		
				});
	}
}

	return {
		initApp : function() {
				 <cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>
				PageUI.createPageWithAllBodySubElement('DSC82900', '變更作業', '暫收備註原因變更');
				valid = new Validation("form", {useTitles:true,focusOnError:false,immediate:false});
				
				
				BALC_REASON_LIST.push({key:"", value:'請選擇'});
				<c:forEach var="map" items="${BALC_REASON_LIST}">
					BALC_REASON_LIST.push({key:"${map.key}", value:'${map.value}'});
				</c:forEach>
				
				grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true,	title:'貸款帳號變更待審清單',
					<%-- [20230321] --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					autoCheckBox:{
							text:'選取', 
							type:'checkbox',
							isSelectAll:true 
				},
				column:[			
					{header:"暫應收編號", key:"BALC_NO"},
					{header:"變更前貸款帳號",key:"LOAN_ID"},
					{header:"變更後貸款帳號",key:"LOAN_ID2"},
					{header:"變更帳號備註",key:"MEMO"},
					{header:"變更前實繳日",key:"REAL_PAYDT1"},
					{header:"變更後實繳日",key:"REAL_PAYDT2"},
					{header:"異動人員",key:"INPUT_NM"},
					{header:"異動日期",key:"INPUT_DATE",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					}	
				]
				});
				<%-- [20230214] 初始化空殼畫面及無資料使用 --%>
				gridA = new TableUI(
				{table: $("gridA"),title:"變更原因備註",pageSize : 10, allSortable: false, overDiv:true,
					autoCheckBox:{
							text:'選取', 
							type:'checkbox',
							isSelectAll:true 
				},
				column:[			
					{header:"暫應收編號", key:"BALC_NO"},
					{header:"暫收原因",key:"BALC_REASON"},
					{header:"債務人",key:"DEBTOR_ID"},
					{header:"暫應收備註",key:"BALC_MEMO"},
					{header:"實繳日",key:"REAL_PAYDT"}	
				]
				});
				
				gridB = new TableUI(
				{table: $("gridB"),title:"變更帳號",pageSize : 10, allSortable: false, overDiv:true,
				autoCheckBox:{
					text:'選取', 
					type:'checkbox',
					isSelectAll:true },
					<%-- [20230523] --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
				column:[			
					{header:"暫應收編號", key:"BALC_NO"},
					{header:"變更前貸款帳號", key:"LOAN_ID"},
					{header:"變更後貸款帳號",key:"NEW_LOAN_ID", input:{
                                type:'TEXT' , size:13 ,maxlength:10 ,action:function( node , dataObj , textDiv, orgData ) {
                                	node.setValue(node.value.toUpperCase()||node.value);
									dataObj = dataObj[0];
									dataObj.NEW_LOAN_ID = node.value.toUpperCase();									
                                }}},
					{header:"備註", key:"MEMO", render: function(rec, val, sn) {
						var input = new Element('input', {class:'textBox2', type:'text', name:'MEMO', id:'MEMO', maxlength: '50', alt: 'ch'});
						input.setValue(val);
						
						input.observe('blur', function(event) {
							rec['MEMO'] = $(event.target).getValue();
						});
						return input;
					}}
                     ]
				});

				buttons.doQuery('I');
				$('BTN_UPDATE').disable();
				$('BTN_CHANGE').disable();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('BTN_UPDATE').observe('click',buttons.doUpdate);
				$('BTN_CHANGE').observe('click',buttons.doChange);
				$('BTN_DELETE').observe('click',buttons.doDelete);
				$('BTN_CONFIRM').observe('click',buttons.doConfirm);
				
				
				
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
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="4%">暫應收編號</td>
			<td class="tbYellow2" width="3%">
				<input id="BALC_NO_Q" type="text" class="textBox2" size="14" maxlength="12" onblur="this.value = this.value.toUpperCase()"  />
			</td>
			<td class="tbYellow" width="4%">貸款帳號</td>
			<td class="tbYellow2" width="3%">
				<input id="LOAN_ID_Q" type="text" class="textBox2" size="13" maxlength="10" onblur="this.value = this.value.toUpperCase()"/>
			</td>
			<td class="tbYellow2" width="10%" colspan='4'>
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >
				<input id="BTN_UPDATE" type="button" value="變更原因/備註/實繳日/債務人" class="button" ><br>	
				<input id="BTN_CHANGE" type="button" value="變更帳號" class="button" >	
				<input id="BTN_CONFIRM" type="button" value="覆核" class="button" >	
				<input id="BTN_DELETE" type="button" value="刪除" class="button" >	
			</td>
		</tr>
	</table>
	<table id = "gridA" ></table>
	<table id = "gridB" ></table>
	<table id = "grid" ></table>
</form>
</body>
</html>