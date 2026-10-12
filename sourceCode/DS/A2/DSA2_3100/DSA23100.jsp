<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%> 

<!--
程式：DSA23100.jsp
功能：lean專案待辦清單
作者：溫子?
完成：2014/

[20190319] 修改件 :
           1.查詢調整UNION DTDSA195(由匯款掃描寫入的資料)，並調整排序
           2.若進度已核貸，而且有匯款影像編號資料，取件時需檢核是否已有掃描紀錄
           3.調整顯示欄位，增加「掃描人員」、「掃描日期」、「聯繫事項」、「聯繫事項異動日期」
           4.審查完成待辦池調整為只查詢受理進度為「核貸」(APPLY_PROCESS=70)的案件
           5.若受理進度為匯款完畢，取件時更新特派件檔(DTDSA195)的徵信人員id、姓名、派件日期
		   
[20240729] 修改件 陳勁谷 難字修改
 -->
 
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/tabs.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>

<script type='text/javascript'>
Event.observe(window, 'load', new DSA23100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSA23100(){
var grid1;
var grid2;
var grid3;
var valid;
	// 建立 ajax request 物件    
	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSA2_3100/');
	//初始化tab
	function initTabs(resp){
		var showTabs = [];
		//var CNT1=resp.CNT1||'0';
		//var CNT2=resp.CNT2||'0';
		//var CNT3=resp.CNT3||'0';
		showTabs.push({id:'tab1', title:'待處理(New case)'});
		showTabs.push({id:'tab2', title:'正處理(WIP)'});
		showTabs.push({id:'tab3', title:'文件審查完成'});
		tabs = new Tabs({		
				id:'menu',				
				tabs:showTabs,
				afterSwitch: function(info){
						if(info.from){
							if(info.to == 'tab1'){
								actions.doQuery('1');
							}else if(info.to == 'tab2'){
								actions.doQuery('2');
							}else{
								actions.doQuery('3');
							}
						}
	     	  	  		PageUI.resize(true);
					}
			});
		/*$('tabMenuItem-menu-tab1').observe('click',function(){
			actions.doQuery('1');
		});
		$('tabMenuItem-menu-tab2').observe('click',function(){
			actions.doQuery('2');
		});
		$('tabMenuItem-menu-tab3').observe('click',function(){
			actions.doQuery('3');
		});*/
	}
	
	function initValidation(){	
		Validation.addAllThese([
			[ 'validateAPPLY_ID_11',  '受理編號長度不正確 需為11碼',
				function(v){				
					return (v && v.length != 11) ? false : true ;
				}
			]		
		]);
		//查詢用檢核
		valid = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
		valid.define('validateAPPLY_ID_11' , [{ id : "APPLY_ID" }] );
		valid.define('validate-ROCDate-Interval' , [{ id : "QUERY_DATE_STA" },{ id : "QUERY_DATE_END" }] );
	}
	
	function initQueryDate(){
		var DEAL_KIND = $('DEAL_KIND').value;
		if(DEAL_KIND == '3'){
			$('QUERY_DATE').insert('核貸日');
		}else{
			$('QUERY_DATE').insert('送件日');
		}
	}
	
	function getMap(QUERY_TYPE, isReloadAll){
		var reqMap = {
		    'DEPT' : $('DEPT').value,
			'APPLY_ID' : $('APPLY_ID').value,
			'QUERY_DATE_STA' : $('QUERY_DATE_STA').value,
			'QUERY_DATE_END' : $('QUERY_DATE_END').value,
			'APPLY_PROCESS' : $('APPLY_PROCESS').value,
			'QUERY_TYPE' : QUERY_TYPE,
			'IS_RELOAD_ALL' : isReloadAll?"Y":"N"
		}
		
		return reqMap;
	}
	
	var actions ={
	
		doQuery : function(QUERY_TYPE, isReloadAll){
			valid.reset();
			if(!valid.validate()){
				return;
			}
	
			ajaxRequest.post('query', {'DEAL_KIND': $F('DEAL_KIND'), 'reqMap':Object.toJSON(getMap(QUERY_TYPE, isReloadAll)) }        
			, function(resp){
		    	
				  grid1.load(resp.rtnList1||[]);
				  grid2.load(resp.rtnList2||[]);
				  grid3.load(resp.rtnList3||[]);
				  if(isReloadAll){
					  initTabs(resp);
				  }
				  PageUI.resize(true);
				
			},function(resp){
				initTabs(resp);
			});       
			
		}
		,doAssign : function(record){
			var reqMap={
				DEAL_KIND :$F('DEAL_KIND'),
				APPLY_ID :record.APPLY_ID,
				CRED_DEPT :record.CRED_DEPT,
				OP_STATUS :record.OP_STATUS,
				SUPPORT_CD :record.SUPPORT_CD,
				SEND_DATE :record.SEND_DATE,
				DOC_DEPT :record.DOC_DEPT,
				REMIT_DEPT :record.REMIT_DEPT,
				APPLY_PROCESS :record.APPLY_PROCESS,
				A004_SCAN_DATE :record.A004_SCAN_DATE,
				SOURCE    :record.SOURCE ,
				FORM_TYPE :record.FORM_TYPE,
				A195_SEQ_NO :record.A195_SEQ_NO
			}
			
			ajaxRequest.post('assign', {'reqMap': Object.toJSON(reqMap),'QueryMap':Object.toJSON(getMap('1', true))}        
			, function(resp){
				
			      grid1.load(resp.rtnList1||[]);
				  grid2.load(resp.rtnList2||[]);
				  grid3.load(resp.rtnList3||[]);
				  initTabs(resp);
				  PageUI.resize(true);
				
				
			},function(resp){
				initTabs(resp);
			});       
			
		}
	}
	return {
		initApp : function(){
			PageUI.createPageWithAllBodySubElement('DSA23100', '核貸作業', 'WORKCELL待辦清單');		
			grid1 = new TableUI({
					table: $("grid1"),
					pageSize: 10,
					//overDiv:false,
					column:[
						{header: "受理編號",key: "APPLY_ID",
							render: function( record, value ) { 
								if( $F('DEAL_KIND') == '1'){ //文件初審待辦清單改代碼控制開啟線上取件
									if ($F('ASSIGN_LINK') == 'Y') {
										if (record.SUPPORT_CD == 'Y'){
			                			    return value; 								
										} 
										//產生超連結
										var link = new Element('a', {href:'#'}).update(value);
										link.observe('click', function(event){ 																			
											actions.doAssign(record);
										});
										return link;
									} 
									return value; 	
								} else {
									if (record.SUPPORT_CD == 'Y'){
		                			    return value; 								
									} 
									//[20210623] 欣儒：理財型/分次動撥，應當日有掃描才可取件
									if ("A195"==record.SOURCE && "Y"!=record.SCAN_DATE_TODAY){
										return value; 	
									}
									//產生超連結
									var link = new Element('a', {href:'#'}).update(value);
									link.observe('click', function(event){ 																			
										actions.doAssign(record);
									});
									return link;
								}
						  	}
						},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "客戶",key: "BORROW_NAME", attrs: {style:"font-family:'EUDC'"}},
						<c:if test="${DEAL_KIND == '2' }">
							{header: "補全狀態",key: "SUPPLY_STATUS_NM"},
						</c:if>
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "客群",key: "VIP_GRADE_NAME"},<%--20210602 調整新件為實體匯款，調整相關系統作業畫面。--%>							
						</c:if>
						{header: "金額",key: "LOAN_AMT",
							render : function(record, value){
								return (value||value===0) ? CSRUtil.$fmt(value,"#,###") : 0 ; 
							}
						},
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "受理日",key: "APPLY_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "送件日",key: "SEND_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "包裹日",key: "PACK_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '3'}">
							{header: "核貸日",key: "AGREE_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '1'}">
							{header: "初審取件日",key: "DOC_STR_DATE"},
						</c:if>
						<c:if test="${DEAL_KIND == '3' }">
							{header: "作業初審取件日",key: "REMIT_STR_DATE",
								render : function(record,value){
									return ("A195"==record.SOURCE)?Date.toROC( value|| ''):value;
								}},
						</c:if>		
						<c:if test="${DEAL_KIND == '2'}">
							{header: "覆審取件日",key: "LST_DOC_STR_DATE"},
						</c:if>						
						{header: "承辦科別",key: "CRED_DEPT_NAME"},
						{header: "案件單位",key: "W_CRED_DEPT_NAME"},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "文件初審",key: "DOC_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "文件覆審",key: "LST_DOC_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "作業初審",key: "REMIT_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "房貸專員",key: "CRED_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%---20210602 調整新件為實體匯款，調整相關系統作業畫面。--%>
						{header: "貸款類別",key: "LOAN_TYPE_NAME"},
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "受理進度",key: "APPLY_PROCESS_NM"},
						</c:if>						
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
					    	{header: "照會電話",key: "A161_CODE"},
						</c:if>
						<%-- 20190319 --%>
						<c:if test="${DEAL_KIND == '3' }">
							<%--[20240729] 修改件 陳勁谷 難字修改 --%>
							{header: "掃描人員",key: "A004_SCAN_NAME", attrs: {style:"font-family:'EUDC'"}},
							{header: "掃描日期",key: "A004_SCAN_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}},
							{header: "聯繫事項",key: "A196_CHANGE_TYPE" ,
								render: function( record, value ) { 
									//產生超連結
									if(value){
										var link = new Element('a', {href:'#'}).update(value);
										var link_name;																   
										link.observe('click', function(event){ 					
										var LP_JSON={
											APPLY_ID:record.APPLY_ID,
											action:'${dispatcher}/DSA2_4000/prompt',
											LINK_FROM : 'DSA2_3100'
										}
										CSRUtil.linkTo(LP_JSON , 'form1');
										});
									}							
									return link ; 
								}
							},
							{header: "聯繫事項-異動時間",key: "A196_UPDATE_DATE",
								render : function(record,value){
									value = (value||'').split('.')[0];
									return Date.toROC(value|| '');
								}},
						</c:if>							
						{header: "狀態",key: "OP_STATUS_NAME"}
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
					    	,{header: "備註事項",key: "Comment"}
						</c:if>								
					] 
				});
				grid2 = new TableUI({
					table: $("grid2"),
					pageSize: 10,
					//overDiv:false,					
					column:[
						{header: "受理編號",key: "APPLY_ID",
							render: function( record, value ) { 
                				//產生超連結
								var link = new Element('a', {href:'#'}).update(value);
								var link_name;
								if( $F('DEAL_KIND') == '3'){								   
								   link.observe('click', function(event){ 					
									var LP_JSON={
										INPUT_VALUE:record.APPLY_ID,
										action:'${dispatcher}/DSB2_0100/prompt', <%-- 20190319 --%>
										LINK_FROM : 'DSA2_3100'
									}
									CSRUtil.linkTo(LP_JSON , 'form1');
									});
								}else{								   
								   link.observe('click', function(event){ 					
									var LP_JSON={
										APPLY_ID:record.APPLY_ID,
										action:'${dispatcher}/DSA1_0100/prompt',
										LINK_FROM : 'DSA2_3100'
									}
									CSRUtil.linkTo(LP_JSON , 'form1');
									});
								}								
								return link ; 
                			}
						},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "客戶",key: "BORROW_NAME", attrs: {style:"font-family:'EUDC'"}},
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "補全狀態",key: "SUPPLY_STATUS_NM"},
						</c:if>
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "客群",key: "VIP_GRADE_NAME"},<%--20210602 調整新件為實體匯款，調整相關系統作業畫面。--%>								
						</c:if>
						{header: "金額",key: "LOAN_AMT",
							render : function(record, value){
								return (value||value===0) ? CSRUtil.$fmt(value,"#,###") : 0 ; 
							}
						},
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "受理日",key: "APPLY_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "送件日",key: "SEND_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "包裹日",key: "PACK_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '3'}">
							{header: "核貸日",key: "AGREE_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '1'}">
							{header: "初審取件日",key: "DOC_STR_DATE"},
						</c:if>
						<c:if test="${DEAL_KIND == '3' }">
							{header: "作業初審取件日",key: "REMIT_STR_DATE",
								render : function(record,value){
									return ("A195"==record.SOURCE)?Date.toROC( value|| ''):value;
								}},
						</c:if>		
						<c:if test="${DEAL_KIND == '2'}">
							{header: "覆審取件日",key: "LST_DOC_STR_DATE"},
						</c:if>			
						{header: "承辦科別",key: "CRED_DEPT_NAME"},
						{header: "案件單位",key: "W_CRED_DEPT_NAME"},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "文件初審",key: "DOC_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "文件覆審",key: "LST_DOC_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "作業初審",key: "REMIT_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "房貸專員",key: "CRED_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%--20210602 調整新件為實體匯款，調整相關系統作業畫面--%>
						{header: "貸款類別",key: "LOAN_TYPE_NAME"},
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "受理進度",key: "APPLY_PROCESS_NM"},
						</c:if>
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
					    	{header: "照會電話",key: "A161_CODE"},
						</c:if>
						<%-- 20190319 --%>
						<c:if test="${DEAL_KIND == '3' }">
							<%--[20240729] 修改件 陳勁谷 難字修改 --%>
							{header: "掃描人員",key: "A004_SCAN_NAME", attrs: {style:"font-family:'EUDC'"}},
							{header: "掃描日期",key: "A004_SCAN_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}},
							{header: "聯繫事項",key: "A196_CHANGE_TYPE" ,
								render: function( record, value ) { 
									//產生超連結
									if(value){
										var link = new Element('a', {href:'#'}).update(value);
										var link_name;																   
										link.observe('click', function(event){ 					
										var LP_JSON={
											APPLY_ID:record.APPLY_ID,
											action:'${dispatcher}/DSA2_4000/prompt',
											LINK_FROM : 'DSA2_3100'
										}
										CSRUtil.linkTo(LP_JSON , 'form1');
										});
									}							
									return link ; 
								}
							},						
							{header: "聯繫事項-異動時間",key: "A196_UPDATE_DATE",
								render : function(record,value){
									value = (value||'').split('.')[0];
									return Date.toROC(value|| '');
								}},
						</c:if>
						{header: "狀態",key: "OP_STATUS_NAME"}
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
					    	,{header: "備註事項",key: "Comment"}
						</c:if>						
						
					] 
				});
				grid3 = new TableUI({
					table: $("grid3"),
					pageSize: 10, 
					//overDiv:false,
					column:[
						{header: "受理編號",key: "APPLY_ID"},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "客戶",key: "BORROW_NAME", attrs: {style:"font-family:'EUDC'"}},
						<c:if test="${DEAL_KIND == '1'}">
							{header: "補全狀態",key: "SUPPLY_STATUS_NM"},
						</c:if>
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "客群",key: "VIP_GRADE_NAME"},<%--20210602 調整新件為實體匯款，調整相關系統作業畫面。--%>	
						</c:if>
						{header: "金額",key: "LOAN_AMT",
							render : function(record, value){
								return (value||value===0) ? CSRUtil.$fmt(value,"#,###") : 0 ; 
							}
						},
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "受理日",key: "APPLY_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "包裹日",key: "PACK_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '3'}">
							{header: "核貸日",key: "AGREE_DATE",
								render : function(record,value){
									return Date.toROC( value|| '');
								}
							},
						</c:if>
						<c:if test="${DEAL_KIND == '1'}">
							{header: "初審取件日",key: "DOC_STR_DATE"},
						</c:if>
						<c:if test="${DEAL_KIND == '3' }">
							{header: "作業初審取件日",key: "REMIT_STR_DATE"},
						</c:if>		
						<c:if test="${DEAL_KIND == '2'}">
							{header: "覆審取件日",key: "LST_DOC_STR_DATE"},
						</c:if>			
						{header: "承辦科別",key: "CRED_DEPT_NAME"},
						{header: "案件單位",key: "W_CRED_DEPT_NAME"},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "文件初審",key: "DOC_NAME", attrs: {style:"font-family:'EUDC'"}}, 
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "文件覆審",key: "LST_DOC_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "作業初審",key: "REMIT_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header: "房貸專員",key: "CRED_NAME", attrs: {style:"font-family:'EUDC'"}},
						<%--20210602 調整新件為實體匯款，調整相關系統作業畫面。--%>
						{header: "貸款類別",key: "LOAN_TYPE_NAME"},					
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
							{header: "受理進度",key: "APPLY_PROCESS_NM"},
						</c:if>
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
					    	{header: "照會電話",key: "A161_CODE"},
						</c:if>
						{header: "狀態",key: "OP_STATUS_NAME"}
						<c:if test="${DEAL_KIND == '1' || DEAL_KIND == '2' }">
					    	,{header: "備註事項",key: "Comment"}
						</c:if>		
					] 
				});
				
				initValidation();
				
				$('BTN_QUERY').observe('click',function(){
					actions.doQuery('1', true);
				});
				
				autoCreateDate();
				autoFormatToDate();

				initQueryDate();
				initTabs('');
				
				displayMessage();
		}
	
	}
}
</script> 
</head>
<body>
<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">


	<input type="hidden" name="DEAL_KIND" id="DEAL_KIND" value="${DEAL_KIND}">
	<input type="hidden" name="ASSIGN_LINK" id="ASSIGN_LINK" value="${ASSIGN_LINK}">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
		<tr>
			<td class="tbYellow" width="10%">案件單位</td>
				<td class="tbYellow2" width='10%'>
					<select class="textBox2" name="DEPT" id="DEPT">
						<option value="">全部</option>		
						<c:forEach var="map" items="${DEPT_LIST}">
							<option value="${map.key}" <c:if test="${Dept eq map.key}"><c:out value=" selected"/></c:if>>${map.value}</option>
						</c:forEach>
					</select>
			</td>
			<td class="tbYellow" width='10%'>受理編號</td>
			<td class="tbYellow2" width='10%'>
				<input id="APPLY_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxLength='11'/>
			</td>
			<td class="tbYellow" width='10%' id='QUERY_DATE'></td>
			<td class="tbYellow2" width='20%'>
				<input id="QUERY_DATE_STA" name="QUERY_DATE_STA" type="text" datatype="ROCdate" class="textBox validate-ROCDate">~
				<input id="QUERY_DATE_END" name="QUERY_DATE_END" type="text" datatype="ROCdate" class="textBox validate-ROCDate">
			</td>
			<td class="tbYellow" width="10%">受理進度</td>
			<td class="tbYellow2" width="20%">
				<select class="textBox2" name="APPLY_PROCESS" id="APPLY_PROCESS">
					<option value="">全部</option>
					<c:forEach var="map" items="${APPLY_PROCESS_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>			
			<td class="tbYellow2" width='10%' align='center'>
				<input id="BTN_QUERY" type="button" class="button" value="查詢" />	
			</td>
		</tr>
	</table>
	<div id="menu" style="width:100%"></div>
	<div id="tab1">
		<table id='grid1' class="grid"></table>	
	</div>	
	<div id="tab2">
		<table id='grid2' class="grid"></table>		
	</div>
	<div id="tab3">
		<table id='grid3' class="grid"></table>	
	</div>

</form>
</body>
</html>