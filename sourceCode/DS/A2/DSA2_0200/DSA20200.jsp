<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>

<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
[20200603] 修改件	申請書200407001741 不當招攬比對與放款支給扣回：新增頁籤「房貸與保單比對紀錄」	張憶如	2000601002365
By 蔡政均 20200619
[20240731] 修改件 難字調整
-->

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<%--[20240731]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/tabs.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/PageControllerObj.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>
<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var grid1_1;
var grid1_2;
var grid1_3;
var grid1_4;
var grid2;
var grid4;
var grid5;
var grid5_1;
var validator;
var tabs;
var grid3_1_pageObj = {};
var grid3_2_pageObj = {};

function initApp(){
	
	displayMessage();
	
	validator = new Validator();

	PageUI.createPageWithAllBodySubElement( "DSA20200" , "核貸作業" ,"貸款記錄整合查詢 " , 1,'${titleNotDisplay}' == 'Y');

	new UI().init();

	// 查詢按鈕
	$("btn_query").observe('click', function(event){
			doQuery();
		}
	);
	
	// 列印按鈕
	$("btn_print").observe('click', function(event){
			doPrint();
		}
	);
	
	PageUI.resize();
	
}

//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
	
		init:function(){
		
			//產生 Grid 物件
			//受理查詢頁籤
			//借款人資料
			// [20240731]難字調整
			grid1_1 = new TableUI(
				{	
					table:$('grid1_1'), allSortable: true, overDiv: false,
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "姓名", key: "BORROW_NAME", attrs: { width : '25%', style:"font-family:'EUDC'"} },
						{ header: "ID", key: "BORROW_ID", attrs: { width : '25%'} },
						{ header: "生日", key: "BIRTHDAY", attrs: { width : '20%'},
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "配偶/負責人", key: "COUPLE_NAME", attrs: { width : '30%', style:"font-family:'EUDC'"},
							render:function(record, value){
							 	return value + ' ' + (record.COUPLE_ID || '');
							}
						}
					]
				}
			);
			//保證人資料
			grid1_2 = new TableUI(
				{	
					table:$('grid1_2'), allSortable: true, overDiv: false,
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "姓名", key: "NAME", attrs: { width : '25%', style:"font-family:'EUDC'"} },
						{ header: "ID", key: "ID", attrs: { width : '25%'} },
						{ header: "生日", key: "BIRTHDAY", attrs: { width : '20%'},
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "婚姻狀況", key: "SPOUSE_FULL", attrs: { width : '30%'} }
					]
				}
			);
			//土地資料
			grid1_3 = new TableUI(
				{	
					table:$('grid1_3'), allSortable: true, overDiv: false,
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "地號", key: "LAND_NO1", attrs: { width : '25%'},
							render:function(record, value){
							 	return value + '-' + record.LAND_NO2;
							}
						},
						{ header: "所有權人姓名", key: "NAME", attrs: { width : '25%', style:"font-family:'EUDC'"} },
						{ header: "所有權人ID", key: "ID", attrs: { width : '30%'} },
						{ header: "移轉年月", key: "TRAN_DATE", attrs: { width : '20%'},
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						}
					]
				}
			);
			//建物資料
			grid1_4 = new TableUI(
				{	
					table:$('grid1_4'), allSortable: true, overDiv: false,
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "建號", key: "BUILD_NO1", attrs: { width : '25%'},
							render:function(record, value){
							 	return value + '-' + record.BUILD_NO2;
							}
						},
						{ header: "所有權人姓名", key: "NAME", attrs: { width : '25%', style:"font-family:'EUDC'"} },
						{ header: "所有權人ID", key: "ID", attrs: { width : '30%'} },
						{ header: "門牌號碼", key: "ADDR_NO", attrs: { width : '20%'} }
					]
				}
			);
			
			//送件記錄頁籤
			grid2 = new TableUI(
				{	
					table:$('grid2'), allSortable: true, overDiv: false,
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					split: ['SEND_DATE'],
					column:[
						{ header: "序號", key: "SERIAL_NO", attrs: { width : '4%', rowSpan : 2} },
						{ header: "受理編號", key: "APPLY_ID", attrs: { width : '9%'} },
						{ header: "借款人", key: "BORROW_NAME", attrs: { width : '8%', style:"font-family:'EUDC'"} },
						{ header: "受理進度", key: "APPLY_PROCESS_NM", attrs: { width : '8%'} },
						{ header: "影像件", key: "TOTAL_PAGE_NM", attrs: { width : '9%'},
							render:function(record, value){
								return record.TOTAL_PAGE_COLOR == 'RED' ? '<font color="red">' + value + '</font>' : value;
							}
						},
						{ header: "貸款類別", key: "LOAN_TYPE_NM", attrs: { width : '8%'},
							render:function(record, value){
								if(value && record.FAST_AGREE=='A'){value += '<BR>(快速審核)';}
								return value;
							}
						},
						{ header: "退件日期（原因）", key: "REJ_DATE", attrs: { width : '8%'},
							render:function(record, value){
								var REJ_TIME = record.REJ_TIME ? Date.toROC(record.REJ_TIME) : '';
								return REJ_TIME + '<br>' + (record.REJ_REASON || '');
							}
						},
						{ header: "同時", key: "COSEND_NOTE_NM", attrs: { width : '4%'} },
						{ header: "重覆", key: "RESEND_NOTE_NM", attrs: { width : '4%'} },
						{ header: "債信", key: "CRED_STATUS_NM", attrs: { width : '4%'} },
						{ header: "曾貸", key: "LOAN_NOTE_NM", attrs: { width : '4%'} },
						{ header: "曾保", key: "GUAR_NOTE_NM", attrs: { width : '4%'} },
						{ header: "曾退", key: "REJECT_NOTE_NM", attrs: { width : '4%'} },
						{ header: "免鑑", key: "IS_APPRAISAL_NM", attrs: { width : '4%'} },
						{ header: "備註事項", key: "BMP_MEMO", attrs: { width : '18%', rowSpan : 2},
							render:function(record, value){
							 	return value || '';
							}
						},
						{ header: "送件日期", key: "SEND_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "核准日期", key: "AGREE_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "鑑價記錄", key: "TWO_YEAR_NM",							
							render:function(record, value){
								if(record.TWO_YEAR!= null || !(record.APPR_APPLY_ID == null || record.APPR_APPLY_ID == '')){
									value = isDate(value)?Date.toROC(value):value;
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { 	linkByTWO_YEAR_NM(record.TWO_YEAR, record.APPR_APPLY_ID, record.APPLY_ID_LINK, record.APPR_APPLY_ID_LINK);};
				                 	return link;
				                 }else{
				                 	return value;
				                 }			                
							}
						},
						{ header: "包裹日期", key: "PACK_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "審查人員", key: "AUDIT_NAME", attrs: {style:"font-family:'EUDC'"} },
						{ header: "徵信人員", key: "CRED_NAME", attrs: {style:"font-family:'EUDC'"} },
						{ header: "擔保品地址", key: "GAGE_ADDR", attrs: { colSpan : 7, style:"font-family:'EUDC'"} }
					]
				}
			);
			
			//貸款記錄頁籤

			
			//投保記錄頁籤
			grid4 = new TableUI(
				{	
					table:$('grid4'), allSortable: true, overDiv: false,
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "序號", key: "SERIAL_NO", attrs: { width : '5%'} },
						{ header: "要/被保人ID", key: "ID", attrs: { width : '15%'},							
							render:function(record, value){
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { linkByID( record.ID ); };
				                 	return link;
							}
						},
						{ header: "要/被保人姓名", key: "NAME", attrs: { width : '15%', style:"font-family:'EUDC'"} },
						{ header: "合計要保人年繳保費", key: "TOTAL_SUMI", attrs: { width : '20%', align : 'right'}, 
							render: function(record, value) {
								return value ? CSRUtil.$fmt(value, '#,##0') : '0';
							}
						},
						{ header: "合計要保人可貸金額", key: "TOTAL_LNABL", attrs: { width : '20%', align : 'right'}, 
							render: function(record, value) {
								return value ? CSRUtil.$fmt(value, '#,##0') : '0';
							}
						},
						{ header: "合計要保人已貸金額", key: "TOTAL_LNRMN", attrs: { width : '20%', align : 'right'}, 
							render: function(record, value) {
								return value ? CSRUtil.$fmt(value, '#,##0') : '0';
							}
						},
						{ header: "保費資料日期", key: "QUERY_DATE", attrs: { width : '10%'}, 
							render: function(record, value) {
								if(value){
									return Date.toROC(value);
								}else{
									return '查無資料';
								}
							}
						}
					]
				}
			);

			//[20200603] 修改件
			//房貸案件資訊
			grid5 = new TableUI(
				{	
					table:$('grid5'), allSortable: true, overDiv: false,
					split: ['LOAN_ID'],
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					autoCheckBox:{
					    text:'選取', 
					        type:'radio',
					                action:function( node , boxStatus , records ){
					                	  	if(node.checked == true){
						                	  	new Ajax.Request("<%=dispatcher%>/DSA2_0200/getPolicyData", 
												{
													parameters: 'APPLY_ID=' + records[0]['APPLY_ID'],
												 	onSuccess:function(XHT, resp){
														if(CSRUtil.isSuccess(resp)){
															grid5_1.load(resp.ATList);
															PageUI.resize(true);
														}else{
															grid5_1.load([]);
															PageUI.resize(true);
														}
													}
												});
					                	  	}
					                }
					},
					column:[
						{ header: "受理編號", key: "APPLY_ID", attrs: { width : '4%'} },
						{ header: "貸款類別", key: "LOAN_TYPE_NAME", attrs: { width : '8%'} },
						{ header: "借款人", key: "BORROW_NAME", attrs: { width : '8%', style:"font-family:'EUDC'"} },
						{ header: "保戶優惠", key: "INSU_NOTE", attrs: { width : '8%'} },
						{ header: "房貸經手人一", key: "AGENT_NAME", attrs: { width : '8%', style:"font-family:'EUDC'"},
							render:function(record, value){
								if(value){
									return value + '  '+ record.AGENT_POS_CODE||'';
								}
								return '';
							}
						},
						{ header: "房貸經手人二", key: "AGENT1_NAME", attrs: { width : '8%', style:"font-family:'EUDC'"},
							render:function(record, value){
								if(value){
									return value + '  '+ record.AGENT1_POS_CODE||'';
								}
								return '';
							}
					    },
						{ header: "對保人", key: "GUARANTOR_NAME", attrs: { width : '4%', style:"font-family:'EUDC'"} },
						{ header: "不當招攬註記", key: "UNDERWRI", attrs: { width : '4%'},
							render:function(record, value){
							 	return ('1'== value) ? '◎' : '';
							}
						 },
						{ header: "貸款帳號", key: "LOAN_ID", attrs: { width : '4%'} },
						{ header: "受理進度", key: "APPLY_PROCESS_NAME", attrs: { width : '4%'} },
						{ header: "送件日", key: "SEND_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "核貸日", key: "AGREE_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "貸放日", key: "LOAN_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "契約狀況", key: "LOAN_STATUS_NAME", attrs: { width : '4%'} },
						{ header: "退件時間", key: "REJ_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "註記取消時間", key: "UNDERWRI_CANCEL_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						}
					]
				}
			);
			//[20200603] 修改件
			//新契約案件資訊
			grid5_1 = new TableUI(
				{	
					table:$('grid5_1'), allSortable: true, overDiv: false,
					split: ['AGENT_NAME_1'],
					<%--[20240731] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "序號", key: "SERIAL_NO", attrs: { width : '5%', rowSpan : 2},
							render:function(record, value, sn){
							 	return sn;
							}
						},
						{ header: "保單號碼", key: "POLICY_NO", attrs: { width : '4%'} },
						{ header: "商品名稱", key: "PROD_NAME", attrs: { width : '8%', colSpan : 2} },
						{ header: "要保人", key: "IS_ROLE_A", attrs: { width : '8%'} },
						{ header: "被保人", key: "IS_ROLE_I", attrs: { width : '8%'} },
						{ header: "實際繳費人", key: "IS_PAY_ID_ACT", attrs: { width : '8%'} },
						{ header: "追費繳費人", key: "IS_PAY_ID_ADD", attrs: { width : '8%'} },
						{ header: "投保始期", key: "ISSUE_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "受理完成日", key: "FORM_CLOSEDT",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "核定日", key: "APPROVE_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "成立日", key: "EFFECT_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "新契約經手人一", key: "AGENT_NAME_1", attrs: { width : '4%', style:"font-family:'EUDC'"} },
						{ header: "新契約經手人二", key: "AGENT_NAME_2", attrs: { width : '4%', style:"font-family:'EUDC'"} },
						{ header: "新契約經手人三", key: "AGENT_NAME_3", attrs: { width : '4%', style:"font-family:'EUDC'"} },
						{ header: "新契約經手人四", key: "AGENT_NAME_4", attrs: { width : '4%', style:"font-family:'EUDC'"} },
						{ header: "新契約經手人五", key: "AGENT_NAME_5", attrs: { width : '4%', style:"font-family:'EUDC'"} },
						{ header: "新契約經手人六", key: "AGENT_NAME_6", attrs: { width : '4%', style:"font-family:'EUDC'"} },
						{ header: "保單簽收日", key: "POLICY_SGNDT",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "契約狀態", key: "CONTRACT_STATUS", attrs: { width : '4%'} },
						{ header: "不當招攬註記", key: "UNDERWRI", attrs: { width : '4%'},
							render:function(record, value){
							 	return ('1'== value) ? '◎' : '';
							}
						  },
						{ header: "註記取消時間", key: "UNDERWRI_CANCEL_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "最後更新時間", key: "UPDATE_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						}
					]
				}
			);

			//定義 tabs
			tabs = new Tabs({		
				id:'menu',				
				tabs:[
					{id:'tab1', title:'受理查詢'},	
					{id:'tab2', title:'送件記錄'},
					{id:'tab3', title:'貸款記錄'},
					{id:'tab4', title:'投保記錄'},
					{id:'tab5', title:'房貸與保單比對紀錄'} // [20200603] 修改件
				],
				afterSwitch: function(info){		
     	  	  		if(info.to == '_tabALL'){
     	  	  			//改寫 tableUI 的divResize()給頁籤"全部"
     	  	  			window.setTimeout( "divResizeOnlyAll()" , 0) ;
     	  	  			window.setTimeout( "PageUI.resize(true)" , 0) ;
     	  	  		}
				},
        		all:{}			
			});// end of tabs define -----------------

			fix();
			//來源頁面
			if ('${LINK_FROM}' != ''){
			
				//L:貸款編號(僅供超連結使用)
				if ('${TYPE}' == 'L'){
					var selectionName = $('TYPE');
					var	option = document.createElement('option');
					option.innerText = "貸款編號";
					option.value = "L";
				 	selectionName.appendChild(option);
				}
				
				$('TYPE').value = '${TYPE}';
				$('VALUE').value = '${VALUE}';
				
				$('btn_query').disabled = true;
				doQuery();
			}
			
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

//--------------------------------------------------------------------------	
//	查詢Function
//--------------------------------------------------------------------------
function doQuery(){

	$('VALUE').value = $F('VALUE').toUpperCase();
	
	var validator = checkInput(); //查詢條件檢核
	if(!validator.validate()){		
		return false;
	}

  	new Ajax.Request("<%=dispatcher%>/DSA2_0200/query", 
		{
			parameters: Form.serialize("form1"),
		 	onSuccess:function(XHT, resp){
		 		if(tabs && tabs.select){
		 			tabs.select('tab1');
		 		}
				if(CSRUtil.isSuccess(resp)){
					grid1_1.load(resp.A010List);
					grid1_2.load(resp.A020_List);
					grid1_3.load(resp.A040_List);
					grid1_4.load(resp.A050_List);
					PageUI.resize(true);
					//繼續取得其他明細的資料
					doAfterQuery();
				} else {
					grid1_1.load([]);
					grid1_2.load([]);
					grid1_3.load([]);
					grid1_4.load([]);
					
					grid2.load([]);
					grid3_1_LoadData([],[]);
					grid3_2_LoadData([]);
					grid4.load([]);
					grid5.load([]);
					grid5_1.load([]);
					PageUI.resize(true);
				}
			}
		});
}

//--------------------------------------------------------------------------	
//	列印Function
//--------------------------------------------------------------------------
function doPrint(){
		$('VALUE').value = $F('VALUE').toUpperCase();
	
		var validator = checkInput(); //查詢條件檢核
		if(!validator.validate()){		
			return false;
		}
		
		var queryData = {
			TYPE: $('TYPE').value,
			VALUE: $('VALUE').value
		};

		var url = "<%=dispatcher%>/DSA2_0200/prompt2?queryData=" + Object.toJSON(queryData);	
		window.open(url,"DSA2_0201", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");		
}

//--------------------------------------------------------------------------	
//	查詢明細Function
//--------------------------------------------------------------------------
function doAfterQuery(){
	
	grid2.load([]);
	grid3_1_LoadData([],[]);
	grid3_2_LoadData([]);
	grid4.load([]);

	grid5.load([]);
	grid5_1.load([]);
  	new Ajax.Request("<%=dispatcher%>/DSA2_0200/afterQuery", 
		{
			parameters: Form.serialize("form1"),
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					grid2.load(resp.APPLY_List);
					grid3_1_LoadData(resp.HEADER_Map , resp.BORROW_LOAN_List);
					grid3_2_LoadData(resp.GUAR_LOAN_List);
					grid4.load(resp.POLICY_Map);
					//[20200603] 修改件 載入房貸與保單比對紀錄
					grid5.load(resp.HouseLoanList);
				} else {
					//grid2.load([]);
					//grid3_1_LoadData([],[]);
					//grid3_2_LoadData([]);
					//grid4.load([]);
				}
				//PageUI.resize(true);
			}
		});
}

function grid3_1_LoadData(HEADER_Map, BORROW_LOAN_List) {

	var dataTable1 = $('grid3_1');
	var le = dataTable1.rows.length;
	for( i = le ; i > 0 ; i--){
		dataTable1.deleteRow(0);
	}

	if (HEADER_Map && HEADER_Map.BORROW_HEADER1){
		var BORROW_HEADER1_AND_NEGO =  HEADER_Map.BORROW_HEADER1 + '<font color=red>' + HEADER_Map.BORROW_HEADER2 + '</font>' + HEADER_Map.BORROW_HEADER3 + '<br><font color=red>' + HEADER_Map.BORROW_NEGO + '</font>';	
	} else {
		var BORROW_HEADER1_AND_NEGO = '';
	}
	
	var insertString1 = "<tr><td class='tbYellow0' colSpan='11'><b>" + BORROW_HEADER1_AND_NEGO + "</b></td></tr>";
	insertString1 += "<tr align='center' class='tbBlue'>";
	insertString1 += "<td width='5%' rowSpan='3'><b>序號</b></td>";
	insertString1 += "<td width='15%'><b>原貸帳號</b></td>";
	insertString1 += "<td width='15%'><b>借款人(關係)</b></td>";
	insertString1 += "<td width='45%' colSpan='6'><b>擔保品地址</b></td>";
	insertString1 += "<td width='10%'><b>餘額總計</b></td>";
	insertString1 += "<td width='10%'><b>平均利率</b></td>";
	insertString1 += "</tr>";
	insertString1 += "<tr align='center' class='tbBlue'>";
	insertString1 += "<td rowspan='2'><b>貸款帳號</b></td>";
	insertString1 += "<td rowspan='2'><b>貸款餘額</b></td>";
	insertString1 += "<td><b>繳息狀況</b></td>";
	insertString1 += "<td><b>貸放日</b></td>";
	insertString1 += "<td><b>滿期日</b></td>";
	insertString1 += "<td><b>貸款種類</b></td>";
	insertString1 += "<td><b>貸款優惠種類</b></td>";
	insertString1 += "<td><b>契約狀況</b></td>";
	insertString1 += "<td><b>清償領取（備註）</b></td>";
	insertString1 += "<td><b>裁定費用</b></td>";
	insertString1 += "</tr>";
	insertString1 += "<tr align='center' class='tbBlue'>";
	insertString1 += "<td><b>當期利率</b></td>";
	insertString1 += "<td><b>保戶優惠</b></td>";
	insertString1 += "<td><b>個別優惠</b></td>";
	insertString1 += "<td><b>貸放1年內</b></td>";
	insertString1 += "<td><b>央行受限</b></td>";
	insertString1 += "<td><b>政府優惠</b></td>";
	insertString1 += "<td><b>近一年管理費</b></td>";
	insertString1 += "<td><b>違約金</b></td>";
	insertString1 += "</tr>";
		
	dataTable1.insert({	bottom:insertString1 });
	
	// 借款人貸款資料：逐筆顯示BORROW_LOAN_List
	for(var mover=0; mover < BORROW_LOAN_List.length ; mover++) {

		var BR_LOAN_Map = BORROW_LOAN_List[mover];

		// 若BR_LOAN_Map.CASE_SEQ_NO = 1時，表示為原貸件，先寫一筆頭表，再寫明細
		if (BR_LOAN_Map.CASE_SEQ_NO == '1'){
			insertString1 = "<tr ID='ROWID1' align='center' style='display: none' class='tbYellow2'>";
			insertString1 += "<td width='5%'>第 " + getField(BR_LOAN_Map.CASE_NO) + " 筆</td>";
			insertString1 += "<td width='15%'>" + getField(BR_LOAN_Map.REFER_ID) + "</td>";
			insertString1 += "<td width='15%'>" + getField(BR_LOAN_Map.RELATED_NAME) + "</td>";
			insertString1 += "<td width='45%' colSpan='6'>" + getField(BR_LOAN_Map.GAGE_ADDR) + "</td>";
			insertString1 += "<td width='10%'>" + getMoneyField(BR_LOAN_Map.SUM_REMAIN_AMT) + "</td>";
			insertString1 += "<td width='10%'>" + getField(BR_LOAN_Map.AVG_RATE) + "</td>";
			insertString1 += "</tr>";
			dataTable1.insert({	bottom:insertString1 });
		}
		
		//借款人貸款明細資料
		insertString1 = "<tr ID='ROWID1' align='center' style='display: none' class='tbBlue3'>";
		insertString1 += "<td rowSpan='2'>" + getField(BR_LOAN_Map.CASE_SEQ_NO) + "</td>";
		insertString1 += "<td rowSpan='2'>" + '<a href="#" onClick="linkByLOAN_ID(\''+getField(BR_LOAN_Map.LOAN_ID)+'\')">' + getField(BR_LOAN_Map.LOAN_ID) + "</a></td>";
		insertString1 += "<td rowSpan='2'>" + getMoneyField(BR_LOAN_Map.AMT) + "</td>";
		
		if (BR_LOAN_Map.STATUS_COLOR == 'RED'){
			insertString1 += "<td><font color='red'>" + getField(BR_LOAN_Map.STATUS_NM) + "</font></td>";
		} else {
			insertString1 += "<td>" + getField(BR_LOAN_Map.STATUS_NM) + "</td>";
		}
		insertString1 += "<td>" + getDateField(BR_LOAN_Map.LOAN_DATE) + "</td>";
		insertString1 += "<td>" + getDateField(BR_LOAN_Map.END_DATE) + "</td>";
		insertString1 += "<td>" + getField(BR_LOAN_Map.LOAN_KIND_NM) + "</td>";
		insertString1 += "<td>" + getField(BR_LOAN_Map.PREFER_TYPE_NM) + "</td>";
		insertString1 += "<td>" + getField(BR_LOAN_Map.LOAN_STATUS_NM) + "</td>";
		insertString1 += "<td>" + getField(BR_LOAN_Map.PAYOFF_LIMIT_NM) + "</td>";
		
		var EFFECT_DATE = BR_LOAN_Map.EFFECT_DATE;
		if (BR_LOAN_Map.EXPENSE_COLOR == 'RED'){
			insertString1 += "<td><font color='red'>";
			if(EFFECT_DATE){
				insertString1 += '<a href="#" onClick="linkByEXPENSE(\''+getField(BR_LOAN_Map.LOAN_ID)+'\', \'' + getField(BR_LOAN_Map.EFFECT_DATE) + '\')">';
				insertString1 += getDateOrNotField(BR_LOAN_Map.EXPENSE);
				insertString1 += "</a>";
			}else{
				insertString1 += getDateOrNotField(BR_LOAN_Map.EXPENSE);				
			}
			insertString1 += "</font></td>";
			
		} else {
			insertString1 += "<td>";
			if(EFFECT_DATE){
				insertString1 += '<a href="#" onClick="linkByEXPENSE(\''+getField(BR_LOAN_Map.LOAN_ID)+'\', \'' + getField(BR_LOAN_Map.EFFECT_DATE) + '\')">';
				insertString1 += getDateOrNotField(BR_LOAN_Map.EXPENSE);
				insertString1 += "</a>";
			}else{
				insertString1 += getDateOrNotField(BR_LOAN_Map.EXPENSE);
			}
			insertString1 += "</td>";			
		}
		insertString1 += "</tr>";

		//
		insertString1 += "<tr ID='ROWID1' align='center' style='display: none' class='tbBlue3'>";
		insertString1 += "<td>" + getField(BR_LOAN_Map.NRATE) + "</td>";
		insertString1 += "<td>" + getField(BR_LOAN_Map.INSU_NOTE) + "</td>";
		insertString1 += "<td>" + getField(BR_LOAN_Map.PREFER_NOTE) + "</td>";
		insertString1 += "<td>" + getField(BR_LOAN_Map.YEAR_NOTE) + "</td>";
		insertString1 += "<td>" + getField(BR_LOAN_Map.GOV_LIMIT) + "</td>";
		insertString1 += "<td>" + getField(BR_LOAN_Map.GOV_NOTE) + "</td>";
		insertString1 += "<td>" + getMoneyField(BR_LOAN_Map.EXPENSE_AMT) + "</td>";
		insertString1 += "<td>" + getMoneyField(BR_LOAN_Map.RENEGE) + "</td>";
		insertString1 += "</tr>";
		//
		dataTable1.insert({	bottom:insertString1 });

	}
	
	var insertString1 = "<tr class='tbBlue2'>" ;
	insertString1 = insertString1 + "<td colspan='11'>";
	insertString1 = insertString1 + "<b>";
	insertString1 = insertString1 + "<div align='right'>";
	insertString1 = insertString1 + "<span class='text10'>";
	insertString1 = insertString1 + "<a href='javascript:gotoFirstPage(grid3_1_pageObj);fix();' title='第一頁' ><img border='0' src='<%=imageBase%>/CM/previous2.gif' width='20' height='15'></a>";
	insertString1 = insertString1 + "<a href='javascript:gotoPrevPage(grid3_1_pageObj);fix();' title='上一頁' ><img border='0' src='<%=imageBase%>/CM/previous1.gif' width='20' height='15'></a>";
	insertString1 = insertString1 + "<a href='javascript:gotoNextPage(grid3_1_pageObj);fix();' title='下一頁' ><img border='0' src='<%=imageBase%>/CM/next1.gif' width='20' height='15'></a>";
	insertString1 = insertString1 + "<a href='javascript:gotoLastPage(grid3_1_pageObj);fix();' title='最末頁' ><img border='0' src='<%=imageBase%>/CM/next2.gif' width='20' height='15'></a>";
	insertString1 = insertString1 + "</span>";
	//insertString1 = insertString1 + "<span id='pageControlerBoard1' style='width:100px' >&nbsp;</span>";
	insertString1 = insertString1 + "</div>";
	insertString1 = insertString1 + "</b>";
	insertString1 = insertString1 + "</td>";
	insertString1 = insertString1 + "</tr>";
	dataTable1.insert({	bottom:insertString1 });

	//第一個參數是javaScript中的Form的物件
	//第二個參數是每一頁要顯示的資料筆數
	//第三個參數是每一行資料中的id名稱<TR ID="row">
	//第四個參數是要顯示分頁資訊的id名稱<td id="pageControlerBoard">&nbsp;</td>
	if($('ROWID1')){
		page(grid3_1_pageObj, document.form2, 20, "ROWID1", "pageControlerBoard1", 1);
	}
}

function grid3_2_LoadData(GUAR_LOAN_List_All) {

	var dataTable2 = $('grid3_2');
	var le = dataTable2.rows.length;
	for( i = le ; i > 0 ; i--){
		dataTable2.deleteRow(0);
	}
	
	for(var mover1=0; mover1 < GUAR_LOAN_List_All.length ; mover1++) {
		var GUAR_LOAN_List = GUAR_LOAN_List_All[mover1].GUAR_LOAN_List;
		var HEADER_Map = GUAR_LOAN_List_All[mover1].HEADER_Map;
		if (HEADER_Map && HEADER_Map.GUAR_HEADER1){
			var GUAR_HEADER1_AND_NEGO =  HEADER_Map.GUAR_HEADER1 + '<font color=red>' + HEADER_Map.GUAR_HEADER2 + '</font>' + HEADER_Map.GUAR_HEADER3 + '<br><font color=red>' + HEADER_Map.GUAR_NEGO + '</font>';	
		} else {
			var GUAR_HEADER1_AND_NEGO = '';
		}
	
		var insertString2 = "<tr><td class='tbYellow0' colSpan='11'><b>" + GUAR_HEADER1_AND_NEGO + "</b></td></tr>";
		insertString2 += "<tr align='center' class='tbBlue'>";
		insertString2 += "<td width='5%' rowSpan='3'><b>序號</b></td>";
		insertString2 += "<td width='15%'><b>原貸帳號</b></td>";
		insertString2 += "<td width='15%'><b>借款人(關係)</b></td>";
		insertString2 += "<td width='45%' colSpan='6'><b>擔保品地址</b></td>";
		insertString2 += "<td width='10%'><b>餘額總計</b></td>";
		insertString2 += "<td width='10%'><b>平均利率</b></td>";
		insertString2 += "</tr>";
		insertString2 += "<tr align='center' class='tbBlue'>";
		insertString2 += "<td rowspan='2'><b>貸款帳號</b></td>";
		insertString2 += "<td rowspan='2'><b>貸款餘額</b></td>";
		insertString2 += "<td><b>繳息狀況</b></td>";
		insertString2 += "<td><b>貸放日</b></td>";
		insertString2 += "<td><b>滿期日</b></td>";
		insertString2 += "<td><b>貸款種類</b></td>";
		insertString2 += "<td><b>貸款優惠種類</b></td>";
		insertString2 += "<td><b>契約狀況</b></td>";
		insertString2 += "<td><b>清償領取（備註）</b></td>";
		insertString2 += "<td><b>裁定費用</b></td>";
		insertString2 += "</tr>";
		insertString2 += "<tr align='center' class='tbBlue'>";
		insertString2 += "<td><b>當期利率</b></td>";
		insertString2 += "<td><b>保戶優惠</b></td>";
		insertString2 += "<td><b>個別優惠</b></td>";
		insertString2 += "<td><b>貸放1年內</b></td>";
		insertString2 += "<td><b>央行受限</b></td>";
		insertString2 += "<td><b>政府優惠</b></td>";
		insertString2 += "<td><b>近一年管理費</b></td>";
		insertString2 += "<td><b>違約金</b></td>";
		insertString2 += "</tr>";
			
		dataTable2.insert({	bottom:insertString2 });
	
		// 保證人貸款資料：逐筆顯示GUAR_LOAN_List
		for(var mover2=0; mover2 < GUAR_LOAN_List.length ; mover2++) {
	
			var GU_LOAN_Map = GUAR_LOAN_List[mover2];
	
			// 若GU_LOAN_Map.CASE_SEQ_NO = 1時，表示為原貸件，先寫一筆頭表，再寫明細
			if (GU_LOAN_Map.CASE_SEQ_NO == '1'){
				//insertString2 = "<tr ID='ROWID2' align='center' style='display: none' class='tbYellow2'>";
				insertString2 = "<tr align='center' class='tbYellow2'>";
				insertString2 += "<td width='5%'>第 " + getField(GU_LOAN_Map.CASE_NO) + " 筆</td>";
				insertString2 += "<td width='15%'>" + getField(GU_LOAN_Map.REFER_ID) + "</td>";
				insertString2 += "<td width='15%'>" + getField(GU_LOAN_Map.RELATED_NAME) + "</td>";
				insertString2 += "<td width='45%' colSpan='6'>" + getField(GU_LOAN_Map.GAGE_ADDR) + "</td>";
				insertString2 += "<td width='10%'>" + getMoneyField(GU_LOAN_Map.SUM_REMAIN_AMT) + "</td>";
				insertString2 += "<td width='10%'>" + getField(GU_LOAN_Map.AVG_RATE) + "</td>";
				insertString2 += "</tr>";
				dataTable2.insert({	bottom:insertString2 });
			}
			
			//借款人貸款明細資料
			//insertString2 = "<tr ID='ROWID2' align='center' style='display: none' class='tbBlue3'>";
			insertString2 = "<tr align='center' class='tbBlue3'>";
			insertString2 += "<td rowspan='2'>" + getField(GU_LOAN_Map.CASE_SEQ_NO) + "</td>";
			insertString2 += "<td rowspan='2'>" + '<a href="#" onClick="linkByLOAN_ID(\''+getField(GU_LOAN_Map.LOAN_ID)+'\')">' + getField(GU_LOAN_Map.LOAN_ID) + "</a></td>";
			insertString2 += "<td rowspan='2'>" + getMoneyField(GU_LOAN_Map.AMT) + "</td>";
	
			if (GU_LOAN_Map.STATUS_COLOR == 'RED'){
				insertString2 += "<td><font color='red'>" + getField(GU_LOAN_Map.STATUS_NM) + "</font></td>";
			} else {
				insertString2 += "<td>" + getField(GU_LOAN_Map.STATUS_NM) + "</td>";
			}
			insertString2 += "<td>" + getDateField(GU_LOAN_Map.LOAN_DATE) + "</td>";
			insertString2 += "<td>" + getDateField(GU_LOAN_Map.END_DATE) + "</td>";
			insertString2 += "<td>" + getField(GU_LOAN_Map.LOAN_KIND_NM) + "</td>";
			insertString2 += "<td>" + getField(GU_LOAN_Map.PREFER_TYPE_NM) + "</td>";
			insertString2 += "<td>" + getField(GU_LOAN_Map.LOAN_STATUS_NM) + "</td>";
			insertString2 += "<td>" + getField(GU_LOAN_Map.PAYOFF_LIMIT_NM) + "</td>";
	
			var EFFECT_DATE = GU_LOAN_Map.EFFECT_DATE;
			if (GU_LOAN_Map.EXPENSE_COLOR == 'RED'){
				insertString2 += "<td><font color='red'>";
				if(EFFECT_DATE){
					insertString2 += '<a href="#" onClick="linkByEXPENSE(\''+getField(GU_LOAN_Map.LOAN_ID)+'\', \'' + getField(GU_LOAN_Map.EFFECT_DATE) + '\')">';
					insertString2 += getDateOrNotField(GU_LOAN_Map.EXPENSE);
					insertString2 += "</a>";
				}else{
					insertString2 += getDateOrNotField(GU_LOAN_Map.EXPENSE);
				}
				insertString2 += "</font></td>";
			} else {
				insertString2 += "<td>";
				if(EFFECT_DATE){
					insertString2 += '<a href="#" onClick="linkByEXPENSE(\''+getField(GU_LOAN_Map.LOAN_ID)+'\', \'' + getField(GU_LOAN_Map.EFFECT_DATE) + '\')">';
					insertString2 += getDateOrNotField(GU_LOAN_Map.EXPENSE);
					insertString2 += "</a>";
				}else{
					insertString2 += getDateOrNotField(GU_LOAN_Map.EXPENSE);
				}
				insertString2 += "</td>";
			}
			insertString2 += "</tr>";
			
			//
			insertString2 += "<tr align='center' class='tbBlue3'>";
			insertString2 += "<td>" + getField(GU_LOAN_Map.NRATE) + "</td>";
			insertString2 += "<td>" + getField(GU_LOAN_Map.INSU_NOTE) + "</td>";
			insertString2 += "<td>" + getField(GU_LOAN_Map.PREFER_NOTE) + "</td>";
			insertString2 += "<td>" + getField(GU_LOAN_Map.YEAR_NOTE) + "</td>";
			insertString2 += "<td>" + getField(GU_LOAN_Map.GOV_LIMIT) + "</td>";
			insertString2 += "<td>" + getField(GU_LOAN_Map.GOV_NOTE) + "</td>";
			insertString2 += "<td>" + getMoneyField(GU_LOAN_Map.EXPENSE_AMT) + "</td>";
			insertString2 += "<td>" + getMoneyField(GU_LOAN_Map.RENEGE) + "</td>";
			insertString2 += "</tr>";
			//
			
			dataTable2.insert({	bottom:insertString2 });
		}
		
		var insertString2 = "<tr class='tbBlue2'>" ;
		insertString2 = insertString2 + "<td colspan='11'>";
		//insertString2 = insertString2 + "<b>";
		//insertString2 = insertString2 + "<div align='right'>";
		//insertString2 = insertString2 + "<span class='text10'>";
		//insertString2 = insertString2 + "<a href='javascript:gotoFirstPage(grid3_2_pageObj);fix();' title='第一頁' ><img border='0' src='<%=imageBase%>/CM/previous2.gif' width='20' height='15'></a>";
		//insertString2 = insertString2 + "<a href='javascript:gotoPrevPage(grid3_2_pageObj);fix();' title='上一頁' ><img border='0' src='<%=imageBase%>/CM/previous1.gif' width='20' height='15'></a>";
		//insertString2 = insertString2 + "<a href='javascript:gotoNextPage(grid3_2_pageObj);fix();' title='下一頁' ><img border='0' src='<%=imageBase%>/CM/next1.gif' width='20' height='15'></a>";
		//insertString2 = insertString2 + "<a href='javascript:gotoLastPage(grid3_2_pageObj);fix();' title='最末頁' ><img border='0' src='<%=imageBase%>/CM/next2.gif' width='20' height='15'></a>";
		//insertString2 = insertString2 + "</span>";
		//insertString2 = insertString2 + "<span id='pageControlerBoard2' style='width:100px' >&nbsp;</span>";
		//insertString2 = insertString2 + "</div>";
		//insertString2 = insertString2 + "</b>";
		insertString2 = insertString2 + "</td>";
		insertString2 = insertString2 + "</tr>";
		dataTable2.insert({	bottom:insertString2 });
	
		//第一個參數是javaScript中的Form的物件
		//第二個參數是每一頁要顯示的資料筆數
		//第三個參數是每一行資料中的id名稱<TR ID="row">
		//第四個參數是要顯示分頁資訊的id名稱<td id="pageControlerBoard">&nbsp;</td>
		//if($('ROWID2')){
		//	page(grid3_2_pageObj, document.form2, 20, "ROWID2", "pageControlerBoard2", 1);
		//}
	}
	dataTable2.show();
}

function getField(str){
	return str ? str : " ";
}

function getDateField(str){
	return str ? Date.toROC(str) : " ";
}

function getDateOrNotField(str){
	if (str){
		return isDate(str) ? Date.toROC(str) : str;
	} else {
		return " ";
	}
}

function getMoneyField(str){
	return str ? CSRUtil.$fmt(str, "#,##0") : "0";
}
	
//--------------------------------------------------------------------------	
//	畫面 C 區鑑價記錄超連結Function
//--------------------------------------------------------------------------
function linkByTWO_YEAR_NM(TWO_YEAR, APPR_APPLY_ID, APPLY_ID_LINK, APPR_APPLY_ID_LINK) {

	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>" + "/DSA3_0500/prompt";
	LP_JSON.SYS = '';

	if (TWO_YEAR != null || !APPR_APPLY_ID || APPR_APPLY_ID == ''){
		LP_JSON.APPLY_ID = APPLY_ID_LINK;
	} else {
		LP_JSON.APPLY_ID = APPR_APPLY_ID_LINK;
	}

	CSRUtil.linkTo(LP_JSON, 'form1');	
}

//--------------------------------------------------------------------------	
//	畫面 D-1 區、D-2 區貸款帳號超連結Function
//--------------------------------------------------------------------------
function linkByLOAN_ID(LOAN_ID_LINK) {
	// 原C0500102 客戶資料查詢
	//var url = '${linkToDPURL}' + "?checkPerm=C602&SYS=DS&__UserID__=" + '${UserID}' + "&LOAN_ID=" + LOAN_ID_LINK;	
	var LP_JSON = {
		action : "<%=dispatcher%>" + "/DSH0_0300/prompt",
		LOAN_ID : LOAN_ID_LINK,
		BORROW_ID : '',
		BORROW_NAME : '',
		REFER_ID : '',
		LINK_FROM : "DSA2_0200"
	};
	CSRUtil.linkTo(LP_JSON, 'form2');
	//window.open(url,"DSA2_0200");		
}

//--------------------------------------------------------------------------	
//	畫面 D-1 區、D-2 區裁定費用超連結Function
//--------------------------------------------------------------------------
function linkByEXPENSE(LOAN_ID_LINK, EFFECT_DATE) {
	if (EFFECT_DATE){
		// 原C0500131管理費用查詢
		//var url = '${linkToDPURL}' + "?checkPerm=E005&SYS=DS&__UserID__=" + '${UserID}' + "&LOAN_ID=" + LOAN_ID_LINK;	
		var LP_JSON = {
			action : "<%=dispatcher%>" + "/DSH0_0400/prompt",
			LOAN_ID : LOAN_ID_LINK,
			LINK_FROM : "DSA2_0200"
		};
		CSRUtil.linkTo(LP_JSON, 'form2');
		//window.open(url,"DSA2_0200");
	}	
}

//--------------------------------------------------------------------------	
//	畫面 E 區要/被保人ID 超連結Function
//--------------------------------------------------------------------------
function linkByID(ID_LINK) {

	//原C0500400 ID查詢保單
	//var url = '${linkToDPURL}' + "?checkPerm=C614&SYS=DS&__UserID__=" + '${UserID}' + "&PERSON_ID=" + ID_LINK;	
	var LP_JSON = {
		action : "<%=dispatcher%>" + "/DSH0_1400/prompt",
		PERSON_ID : ID_LINK,
		LINK_FROM : "DSA2_0200"
	};
	CSRUtil.linkTo(LP_JSON, 'form2');
	//window.open(url,"DSA2_0200");
}

//--------------------------------------------------------------------------	
//	檢核Function
//--------------------------------------------------------------------------
function checkInput() {
	validator.clear();
	validator = new Validator();
	validator.errHandler = new AlertHandler();

	validator.define('VALUE', '查詢條件', '請輸入查詢條件', function(value){
		return $F('VALUE').trim() != "";
	});

	return validator;
}

var divResizeOnlyAll = function(){
	return;
	var bodyw = document.body.clientWidth;
	var bodyh = document.body.clientHeight;
	//if( !(Math.abs(bodyw-orgWinWidth)>10 || Math.abs(bodyh-orgWinHeight)>10 )){ return; }
	
	orgWinHeight = bodyh ;
	orgWinWidth = bodyw ;

	var innerbw = (bodyw-25)*0.98;
	$$('div.over_div').each(function(d){
		if(d.divWidth > 1){
			d.setStyle({'width': d.divWidth});
		}else if(d.divWidth < 0){
			d.setStyle({'width': innerbw+d.divWidth});
		}else{
			d.setStyle({'width': innerbw*d.divWidth});
		}
		if(typeof(d.resetDivHeight) == 'function' ){
			d.resetDivHeight();
		}
	});
}

//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >

<!-- Block_3_Start 表單主功能區塊-->
<form name="form1" id="form1" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >	
		<!-- Block_4_Start 輸入區塊-->
		<tr>
			<td class="tbYellow" width="20%">查詢條件</td>
			<td class="tbYellow2" width="30%">
				<select name="TYPE" id="TYPE">
					<c:forEach var="map" items="${TYPE_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
				&nbsp;
				<input type="text" class="textBox" id="VALUE" name="VALUE" size="15" maxlength="11">
			</td>
			<td class="tbYellow2" align="left" width="50%">
				<input type="button" id="btn_query" value="查詢" class="button">
				<input type="button" id="btn_print" value="列印" class="button">
			</td>
		</tr>
		<!-- Block_4_End 輸入區塊-->
</table>
</form>
<div>
	<div id="menu"></div>

	<div id="tab1">
		<div class="tbBox2"><b>受理查詢</b></div>
		<div class="tbYellow0" align="center">借款人資料</div>
		<div><table class="grid" id="grid1_1" ></table></div>
		<div class="tbYellow0" align="center">保證人資料</div>
		<div><table class="grid" id="grid1_2" ></table></div>
		<div class="tbYellow0" align="center">土地資料</div>
		<div><table class="grid" id="grid1_3" ></table></div>
		<div class="tbYellow0" align="center">建物資料</div>
		<div><table class="grid" id="grid1_4" ></table></div>
	</div>
	
	<div id="tab2">
		<div class="tbBox2"><b>送件記錄</b></div>
		<table class="grid" id="grid2" ></table>
	</div>
	
	<div id="tab3">
		<form name="form2" id="form2" method="post">
			<table border=0 width="100%" cellpadding="0" cellspacing="1" class="tableGrid">
				<tr>
					<td class="tbBox2"><b>貸款記錄</b></td>
				</tr>
				<tr>
					<td>
						<table id="grid3_1" name="grid3_1" width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
							<tr>
								<td class="tbYellow0" colSpan="11"><b>※借款人</b></td>
							</tr>
							<tr align="center" class="tbBlue">
								<td width="5%" rowSpan="3"><b>序號</b></td>
								<td width="15%"><b>原貸帳號</b></td>
								<td width="15%"><b>借款人(關係)</b></td>
								<td width="45%" colSpan="6"><b>擔保品地址</b></td>
								<td width="10%"><b>餘額總計</b></td>
								<td width="10%"><b>平均利率</b></td>
							</tr>
							<tr align="center" class="tbBlue">
								<td rowspan="2"><b>貸款帳號</b></td>
								<td rowspan="2"><b>貸款餘額</b></td>
								<td><b>繳息狀況</b></td>
								<td><b>貸放日</b></td>
								<td><b>滿期日</b></td>
								<td><b>貸款類別</b></td>
								<td><b>貸款優惠種類</b></td>
								<td><b>契約狀況</b></td>
								<td><b>清償領取（備註）</b></td>
								<td><b>裁定費用</b></td>
							</tr>
							<tr align="center" class="tbBlue">
								<td><b>當期利率</b></td>
								<td><b>保戶優惠</b></td>
								<td><b>個別優惠</b></td>
								<td><b>貸放1年內</b></td>
								<td><b>央行受限</b></td>
								<td><b>政府優惠</b></td>
								<td><b>近一年管理費</b></td>
								<td><b>違約金</b></td>
							</tr>
						</table>
						<table id="grid3_2" name="grid3_2" width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" style="display:none">
							<tr>
								<td class="tbYellow0" colSpan="11"><b>※保證人</b></td>
							</tr>
							<tr align="center" class="tbBlue">
								<td width="5%" rowSpan="3"><b>序號</b></td>
								<td width="15%"><b>原貸帳號</b></td>
								<td width="15%"><b>借款人(關係)</b></td>
								<td width="45%" colSpan="6"><b>擔保品地址</b></td>
								<td width="10%"><b>餘額總計</b></td>
								<td width="10%"><b>平均利率</b></td>
							</tr>
							<tr align="center" class="tbBlue">
								<td rowspan="2"><b>貸款帳號</b></td>
								<td rowspan="2"><b>貸款餘額</b></td>
								<td><b>繳息狀況</b></td>
								<td><b>貸放日</b></td>
								<td><b>滿期日</b></td>
								<td><b>貸款類別</b></td>
								<td><b>貸款優惠種類</b></td>
								<td><b>契約狀況</b></td>
								<td><b>清償領取（備註）</b></td>
								<td><b>裁定費用</b></td>
							</tr>
							<tr align="center" class="tbBlue">
								<td><b>當期利率</b></td>
								<td><b>保戶優惠</b></td>
								<td><b>個別優惠</b></td>
								<td><b>貸放1年內</b></td>
								<td><b>央行受限</b></td>
								<td><b>政府優惠</b></td>
								<td><b>近一年管理費</b></td>
								<td><b>違約金</b></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</form>
	</div>

	<div id="tab4">
		<div class="tbBox2"><b>投保記錄</b></div>
		<table class="grid" id="grid4" ></table>
	</div>

	<%-- [20200603] 修改件 張憶如 2000601002365 --%>
	<div id="tab5">
		<div class="tbBox2"><b>房貸與保單比對紀錄</b></div>
		<div class="tbYellow0" align="center">房貸案件資訊</div>
		<table class="grid" id="grid5" ></table>
		<div class="tbYellow0" align="center">新契約案件資訊</div>
		<div><table class="grid" id="grid5_1" ></table></div>
	</div>
	
</div>

<!-- Block_3_End 表單主功能區塊-->
</body>
</html>
