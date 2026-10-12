<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC33200.jsp
作者：卓達瑋
功能：ATM異常入帳
完成：2013/05/07
調整：2018-03-12申請書-轉帳扣款收息作業風險檢核：異常入帳在輸入時（掛人工暫收）檢核洗錢防制是否為制裁名單，若是試算分配則由DSC31617檢核
2019-01-10:申請書(180927000795):ATM異常入帳畫面調整 : 新增全選並連動計算合計
[20241104] 修改件 難字調整 吳志鴻
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
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

Event.observe(window, 'load', new DSC33200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC33200(){
	var tempMap={};
	var grid;
	var grid2;
	var grid3;
	//檢核
	var valid1;	
	var valid2;	
	//紀錄實際金額
	var REAL_PAYMT_rc;
	//檢核欄位
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});				
 	    valid1.define('validate-ROCDate' , [{ id : "TRANS_DATE" , errMsg:'請輸入有效日期格式!!'}] );
		valid1.define('required' , [{ id : "TRANS_STATUS" , errMsg:'請選擇狀態!!'}] );
		valid2 = new Validation("form2", { focusOnError:true, immediate:false});		
		Validation.addAllThese( [
			[ 'PAY_AMT_Required', '請輸入數值格式',
				function( v , elem ) {
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
                    if(checks){
					    return Validation.get('IsEmpty').test(v) || /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(v);
					}
					return true;
				}
			]
		]);
	
	}		

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_3200/" + actionName,
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
	};
	var actions= {
        //將畫面寫入Map	
	    billMap : function(){
			return  {
				'REAL_PAYMT' : REAL_PAYMT_rc, 
                'BillList' : $F('SEQ_NO') 				
			}		
	    },
		//POP UP 開啟新視窗
	  	doPopup : function ( parms ) {				
			var LINK_TO = parms.LINK_TO;
	  		if('AIL0_1300'==LINK_TO){
				//190211 禹含(內部申請書190212000817)：AIL01300初始查詢條件檢核調整(需傳入查詢區間)
	  			parms.QUERY_START_DATE = parms.CURRENT_DATE;
	  			parms.QUERY_END_DATE = parms.CURRENT_DATE;
	  			
				popupWin.popup({
					'src': '/AIWeb/servlet/HttpDispatcher/AIL0_1300/query',
					'parameters' :  {
						'dataObj' : Object.toJSON(parms)  //配合壽五科 洗錢防制檢核紀錄覆核及盡職/加強審查連結調整=>導頁參數調整
					}
				});
			}else if('AIL1_1000'==LINK_TO){//180917:申請書(180828001571):新增可疑交易檢核
				popupWin.popup({
					'src': '/AIWeb/servlet/HttpDispatcher/AIL1_1000/query',
					'parameters' :  {
						'QUR_ID': parms.QUERY_ID,//客戶ID/繳款人ID 
						'QUR_DATE_STR':parms.CURRENT_DATE,
						'QUR_DATE_END':parms.CURRENT_DATE,
						'COUNT':'0',
						'PAGE':'0',
						'TotalPage':'0'
					}
				});
			}
	  	},
	  	doCalTotal : function( node , boxStatus , records){
			var PAYOFF_LIMIT=records[0].PAYOFF_LIMIT;
			var LOAN_ID=records[0].LOAN_ID;
			if(PAYOFF_LIMIT==1){
			    alert(LOAN_ID+"--屬法務之清償控管");
			}else if(PAYOFF_LIMIT==2){
			    alert(LOAN_ID+"--屬催收之清償控管");
			}else if(PAYOFF_LIMIT==3){
			    alert(LOAN_ID+"--屬放款之清償控管");
			}
			
			var chkList = grid3.getCheckedRecord();
			var allList = grid3.getAllRecords();
			
			ajaxPost( 'total', {'chkList':Object.toJSON(chkList),'allList':Object.toJSON(allList)},
				function(resp){
					grid3.load(resp.allList || [], resp.totalList || [], null, ["Y"]);
				}
			);	
		    
		}
	}	
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {	
		    if(!valid1.validate()){				
				return; 
			}
			var queryMap={
			    TRANS_DATE: $F('TRANS_DATE'),
				TRANS_STATUS: $F('TRANS_STATUS')
			}
			if ($F('TRANS_STATUS') != '2'){
				grid2.load([]);
				$('grid2').hide();
				$('table_a').hide();
				grid3.load([]);
				$('grid3').hide();
				$('table_b').hide();			
				
				ajaxPost( 'query', {'reqMap' :Object.toJSON(queryMap)}
					,function(resp){
						 grid.load(resp.dataList);
					}
					,function(resp){
						 grid.load([]);
					}
				);
			} else {
				//異常入帳金額分配畫面
				var actionUrl=actionUrl='<%=dispatcher%>/DSC3_1600/prompt';	
				
				var LP_JSON = {
					action :actionUrl,
					LINK_FROM : "DSC3_3200", //原始連結畫面
					SPEC   : '1',
					PAY_TYPE: 'E'
				}	
				CSRUtil.linkTo(LP_JSON , 'form1');	
			}
		},
		//輸入
		doEnter: function(data) {	
			if(!valid1.validate()){				
				return; 
			}
			var queryMap={
			    TRANS_DATE: $F('TRANS_DATE'),
				TRANS_STATUS: $F('TRANS_STATUS')
			}
			//傳入繳款相關資訊
			var PAY_INFO ={};
			PAY_INFO = {
				RELATION : [{
					BORROW_ID : data.BORROW_ID,
					BORROW_NAME : data.BORROW_NAME,
					PAY_RELATION : "O",
					OTHER_RELATION: "",
					PAY_REASON : ""
				}],			
				PAY_ID : data['PAY_ID'],
				COPR_CODE : '0', //無從判斷，預設給0個人
				PAY_NAME : data['PAY_NAME'], 
				noWrite : 'Y' //無繳款人資訊，不需寫入繳款服務單 //2019-01-28：申請書 181128001539 - 繳款服務單新增檢核
			};			
			ajaxPost( 'enter', {'accessData' :Object.toJSON(data), 'reqMap' :Object.toJSON(queryMap),PAY_INFO : Object.toJSON(PAY_INFO)}
				,function(resp){
					if(resp.ERR_MSG){ //若有檢核出制裁名單，需連結至洗錢防制檢核紀錄填寫紀錄後才能掛人工暫收
						alert(resp.ERR_MSG);
						var parms = {//180917:申請書(180828001571):新增可疑交易檢核 
							'LINK_TO' : resp.LINK_TO,
							'QUERY_ID' : resp.QUERY_ID,
							'CURRENT_DATE' : resp.CURRENT_DATE
						}; 		
						actions.doPopup( parms );	
					} else {			
						grid.load(resp.dataList || []);
					}				
				}
				
			);
		},
    	//選取確認
		doConfirm: function(record) {	
			REAL_PAYMT_rc=record.DEDUCT_AMT;
			ajaxPost( 'confirm', {'confirmData' :Object.toJSON(record),'PAY_DATE':$F('TRANS_DATE'),'LOAN_ID':record.LOAN_ID}
				,function(resp){
			        grid2.load(resp.loanList, null, null, ["Y"]);
					if('Y' == resp.hasC320){
						alert("同一貸款帳號已做過異常入帳，請確認")
					}
				}
				,function(resp){
                     grid2.load([]);
				}
				
			);
			//畫面區塊顯示控制
			$('grid2').show();
			$('table_a').show();
			$('grid3').hide();
			$('table_b').hide();
		},
		//異常入帳試算
		docalculate: function() {	
		    if(!valid2.validate()){				
				return; 
			}
			var calculatedata =grid2.getCheckedRecord();	
			var qryData=grid2.getAllRecords();
			if(calculatedata.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}
			ajaxPost( 'calculate', {'calculatedata' :Object.toJSON(calculatedata),'allList':Object.toJSON(qryData)}
				,function(resp){
					//grid3.load(resp.calList);
					grid3.load(resp.calList || [], resp.totalList || [], null, ["Y"]);
				}
				,function(resp){
                     grid3.load([]);
				}
				
			);
			//畫面區塊顯示控制
			$('grid3').show();
			$('table_b').show();
		},
		//金額分配
		doAssign: function(){
		   
			var PayList =grid.getCheckedRecord();	
			if(PayList.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}
			
			var PayAllList =grid.getAllRecords();	
			
			var recs = grid3.getAllRecords();
				if(recs.length==0){
					alert("請先進行試算!")
					return;
				}
			
			var BillList = grid3.getCheckedRecord();	
				if(BillList.length==0){
					alert("請於試算清單中至少勾選一筆資料!");
					return;
				}
			//異常入帳金額分配畫面
			var actionUrl='<%=dispatcher%>/DSC3_1617/prompt';	
			
					
			ajaxPost(  
				'assign' ,
				{'BillListStr': Object.toJSON(BillList),'PayListStr':Object.toJSON(PayList),'PAY_TYPE':'E','ISTIC':'E','PayAllList':Object.toJSON(PayAllList)},
				function(resp){	
					var BillListStr=resp.BillListStr;
					var PayListStr=resp.PayListStr;
					var billMap={
						'ISTIC' :'E',
						'BillListStr' : BillListStr,
						'PayListStr':PayListStr,
						'PAY_TYPE': 'E',
						'TRANS_DATE':$F('TRANS_DATE'),
						'TRANS_STATUS':$F('TRANS_STATUS')
					}
					var displayMap={
						ListB:Object.toJSON(grid.getAllRecords())
					}
					var LP_JSON = {
						action :actionUrl,
						LINK_TYPE : "IN",   //連結型態 = IN:內部
						LINK_FROM : "DSC3_3200", //原始連結畫面
						billMap   : billMap,
						displayMap: displayMap
					}									
					CSRUtil.linkTo(LP_JSON , 'form1');	
				},
				function(resp){
					//grid2.load([]);
					//$('table_D').hide();
				}
			);
		}
	};
	
	return {
		initApp : function() {
		    <c:forEach var="map" items="${NEW_PAY_KIND_MAP}">
				tempMap["${map.key}"]="${map.value}";
			</c:forEach>
			PageUI.createPageWithAllBodySubElement( "DSC33200" , "繳款方式", "ATM異常入帳" );
            grid = new TableUI(
				{table: $("grid"), allSortable: false, overDiv:false,
				autoCheckBox:{
				    text:'選取',
					type:'radio',
					action:function(node, boxStatus, records ){
						if(!boxStatus) return;//檢核box狀態，避免連續點選，造成載入資料有問題
						button.doConfirm(records[0]);
					},
					genRule:function(record,value){
					    return  record.ACNT_CODE != '1';
					    //return  record.ATM_STATUS != "00";
					}
				
				},				
				column:[
                    {header:"貸款帳號",key:"LOAN_ID"},				
					{header:"借款人ID<br>借款人姓名",key:"BORROW_ID", attrs:{style:"font-family:'EUDC'"}, <%-- [20241104] 難字調整: 借款人姓名 --%>
					    render: function(record, value) {
                            var BORROW_NAME = record.BORROW_NAME;
	   					    if(value){
							   return "<span class = 'textRed'>"+value +'<br>'+(BORROW_NAME || '')+"</span>";
						    }
                            return "<span class = 'textRed'>"+(BORROW_NAME || '')+"</span>"; 
                        }
					},	
                    {header:"繳款人",key:"PAYEE",attrs:{style:"font-family:'EUDC'"}},	<%-- [20241104] 難字調整: 繳款人 --%>					
					{header:"實繳金額",key:"DEDUCT_AMT",
					    render: function (rec,value){
							if(value ||value ==="0"){ 
								return MoneyFormat(value);
							}
							return "";
						}
					
					},	
					{header:"主辦銀行<br>發卡銀行",key:"HOST_BRANCH",
					    render: function(record, value) {
                            var CREDIT_BANK = record.CREDIT_BANK;
	   					    if(value){
							   return "<span class = 'textRed'>"+value +'<br>'+(CREDIT_BANK || '')+"</span>";
						    }
                            return "<span class = 'textRed'>"+(CREDIT_BANK || '')+"</span>"; 
                        }
					},
					{header:"卡號",key:"MEMO2_ACCOUNT_OUT",
					    render:function(rec,val){							
							if(val){
								//開啟新視窗(POP UP)DSC33201，查詢卡號交易明細歷史紀錄
								var link = new Element( 'a' , { href : "#" } ).update(val);
								link.observe('click', function(){
									popupWin.popup({									
										src : '<%=dispatcher%>/DSC3_3201/prompt' ,		
											scrolling : 'yes',	
											parameters : { 
												ACCOUNT : val	
											}  			
									});	
								});
								return link;
							}	
							return '';
						}
					     
					},	
					{header:"交易序號",key:"SEQ_NO"},
					
					{header:"手續費",key:"HANDLE_FEE",
					    render: function (rec,value){
							if(value ||value ==="0"){ 
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"日間連絡電話",key:"DAY_TEL_AREA",
						render: function (rec,value){
							if(value && rec.DAY_TEL_NUM && rec.DAY_TEL_EXT){
								return '(' + value + ')' + rec.DAY_TEL_NUM + ' #' + rec.DAY_TEL_EXT ;
							} else if (value && rec.DAY_TEL_NUM){
								return '(' + value + ')' + rec.DAY_TEL_NUM;
							} else if (rec.DAY_TEL_NUM && rec.DAY_TEL_EXT) {
								return rec.DAY_TEL_NUM + ' #' + rec.DAY_TEL_EXT;
							} else if (rec.DAY_TEL_NUM) {
								return rec.DAY_TEL_NUM;
							}							
							return "" ;
						}},
					{header:"夜間連絡電話",key:"NIGHT_TEL_AREA",
						render: function (rec,value){
							if(value && rec.NIGHT_TEL_NUM && rec.NIGHT_TEL_NUM != null && rec.NIGHT_TEL_EXT && rec.NIGHT_TEL_EXT != null){
								return '(' + value + ')' + rec.NIGHT_TEL_NUM + ' #' + rec.NIGHT_TEL_EXT ;
							} else if (value && rec.NIGHT_TEL_NUM && rec.NIGHT_TEL_NUM != null){
								return '(' + value + ')' + rec.NIGHT_TEL_NUM;
							} else if (rec.NIGHT_TEL_NUM && rec.NIGHT_TEL_EXT) {
								return rec.NIGHT_TEL_NUM + ' #' + rec.NIGHT_TEL_EXT;
							} else if (rec.NIGHT_TEL_NUM) {
								return rec.NIGHT_TEL_NUM;
							}
							return "" ;
						}},
					{header:"批次入帳狀態",key:"ATM_CSTATUS"
						,render :function(rec,val){
							if("25" == rec.ATM_STATUS) {
								var link = new Element('a',{ href : "#"}).update(val);
									link.observe('click',function(event){						
										var url = "/AIWeb/servlet/HttpDispatcher/AIL0_1300/prompt";												
										window.open(url, "DSC3_3100", "top=250, left=250, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=900, height=600");	
									});
								return link;
							}
							return val;
						}					
					},
					{header:"入帳控制",key:"ACNT_CSTATUS"},
					{header:"人工暫收",key:"BALC_MEMO",
						input:{type:'TEXT', size:20, maxlength:30}								
					},                      
					{header: "",key: "upd",sortable:false,
						input:{type:'button', text:'輸入',
							genRule:function(record , value){
								return record.ACNT_CODE == '1' ? false : true; 
							},
                            action:function( node , dataObj , textDiv, isOnChange ){ 
								button.doEnter(dataObj[0]);
							}			
						}
					}						
				]
			});
			grid2 = new TableUI(
				{table: $("grid2"), allSortable: false, pageSize: 20,
				autoCheckBox:{
				    text:'選取',
					type:'checkbox',
					valueKey: 'preCheck',
					action:function( node , boxStatus , records ){ 				
						var PAYOFF_LIMIT=records[0].PAYOFF_LIMIT;
						var LOAN_ID=records[0].LOAN_ID;
						if(PAYOFF_LIMIT==1){
						    alert(LOAN_ID+"--屬法務之清償控管");
						}else if(PAYOFF_LIMIT==2){
						    alert(LOAN_ID+"--屬催收之清償控管");
						}else if(PAYOFF_LIMIT==3){
						    alert(LOAN_ID+"--屬放款之清償控管");
						}
					    
					}
				},				
				column:[
                    {header:"序號",key:"SEQ_NO"},
                    {header:"借款人ID",key:"BORROW_ID"},
                    {header:"借款人姓名",key:"BORROW_NAME",attrs:{style:"font-family:'EUDC'"}},	  <%-- [20241104] 難字調整: 借款人姓名 --%>
                    {header:"貸款帳號",key:"LOAN_ID"},					
					{header:"繳款種類",key:"PAY_KIND",
					    input:{
						    type:'select',
							opts:tempMap
						}					
					},	
					{header:"轉帳日",key:"PAY_DATE",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},
					{header:"部入金額或新繳款日或暫收款金額",key:"PAY_AMT",input:{ className : 'PAY_AMT_Required' ,type:'number'}
					    ,render : function (rec , val){
							return CSRUtil.$fmt(val||0,"#,##0.###");;									
						}
					},			
					{header:"擔保品地址",key:"GAGE_ADDR", input:{
						type:'text',size:50,
						action:function( node , dataObj , textDiv, orgData , isOnChange ){		                        	
							node.setAttribute("alt" , "ch"); <%--[20241107]難字調整--%>
													
						}, actionWhenStart:true
					}}
				]
			});
			grid3 = new TableUI(
				{table: $("grid3"), allSortable: false, pageSize: 20,
				autoCheckBox:{
				    text:'選取',
					type:'checkbox',
					valueKey: 'preCheck',
					isSelectAll:actions.doCalTotal,	//190110:新增全選 //190110:調整全選也會連動合計
					action: actions.doCalTotal 
				},				
				column:[
                    {header:"貸款帳號",key:"LOAN_ID"},
                    {header:"期數",key:"PAY_TERM"},
                    {header:"應繳日",key:"NEXT_PAYDT",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},	
                    {header:"實繳日",key:"PAY_DATE",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},					
					{header:"應繳金額",key:"DUTY_PAYMT",renderInCount:true,
					    render: function (rec,value){
							if(value ||value ===0){ 
								return MoneyFormat(value);
							}
							return "";
						}
					},	
					{header:"適用利率",key:"RATE_VAL",renderInCount:true,
					    render: function (rec,value){
							if(value ||value ===0){ 
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"應攤本金",key:"PRINCIPAL",renderInCount:true,
					    render: function (rec,value){
							if(value ||value ===0){ 
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"利息",key:"INTEREST"/*,
					    render: function (rec,value){
							if(value ||value ===0){ 
								return MoneyFormat(value);
							}
							return "";
						}*/
						,renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								//利息欄位=rec.INTEREST+rec.RETAIN_INT
								val=val+rec.RETAIN_INT||0;
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}
					},
					{header:"逾期息",key:"DELAY_INT",renderInCount:true,
					    render: function (rec,value){
							if(value ||value ===0){ 
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"違約金",key:"RENEGE",renderInCount:true,
					    render: function (rec,value){
							if(value ||value ===0){ 
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"管理費",key:"LAWSUIT_FEE",renderInCount:true,
					    render: function (rec,value){
							if(value ||value ===0){ 
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"上期結餘",key:"LAST_BALANCE",renderInCount:true,
					    render: function (rec,value){
							if(value ||value ===0){ 
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"代扣稅款",key:"TAX",renderInCount:true,
					    render: function (rec,value){
							if(value||value ===0){ 
								return MoneyFormat(value);
							}
							return "";
						}
					}	
				]
			});
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			//畫面檢核
			initValidation();
			// 監聽
			$("BTN_QUERY").observe('click', button.doQuery);
            //$("BTN_CONFIRM").observe('click', button.doConfirm);
			$("BTN_CAL").observe('click', button.docalculate);
			$("BTN_ASSIGN").observe('click', button.doAssign);
			
			var LP_JSON = CSRUtil.isBackLink('form1');
			
			if(LP_JSON){	//由其他頁面，回上一頁
				var displayMap=LP_JSON.displayMap;
				var ListB=displayMap.ListB.evalJSON()||[];
				var billMap=LP_JSON.billMap;	
				//載入查詢條件
				$('TRANS_DATE').value=billMap.TRANS_DATE;
				$('TRANS_STATUS').value=billMap.TRANS_STATUS;
				//載入查詢結果
				grid.load(ListB);
			}
			
			//畫面區塊顯示控制
			$('grid2').hide();			
			$('table_a').hide();
			$('grid3').hide();
			$('table_b').hide();
			
			//按鈕權限		
			PageUI.resize();	
			displayMessage();
		}
	}
}
</script>
</head>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
	<tr>
		<td class='tbYellow' width='5%'>
			扣款日期
		</td>
		<td class='tbYellow2' width='5%'>
			<input id='TRANS_DATE' type='text' class= 'textBox2'   size='10' maxlength='7' value="${TRANS_DATE}"/> 
		</td>
		<td class="tbYellow2" width="50%"  rowspan="2" >
			<input type="button" class="button" id="BTN_QUERY" value="查詢"/>				
		</td>

	</tr>
	<tr>
		<td class='tbYellow' width='15%'>
			狀態
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="TRANS_STATUS" class="textBox2" >
				<c:forEach items="${TRANS_STATUS_List}" var="map" >							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
</table>


<table id='grid' width="100%"></table>
</form>
<form name="form2" id="form2"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >	

<!-- 
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tr>
		<td class="tbYellow2" width="50%">
			<input type="button" class="button" id="BTN_CONFIRM" value="選取確認"/>				
		</td>

	</tr>
	
</table>
-->
<table id='grid2' width="100%"></table>
<table id="table_a" width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tr>
		<td class="tbYellow2" width="50%">
			<input type="button" class="button" id="BTN_CAL" value="異常入帳試算"/>				
		</td>

	</tr>
	
</table>

<table id='grid3' width="100%"></table>
<table id="table_b" width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tr>
		<td class="tbYellow2" width="50%">
			<input type="button" class="button" id="BTN_ASSIGN" value="金額分配"/>				
		</td>

	</tr>
	
</table>
</form>

</body>
</html>