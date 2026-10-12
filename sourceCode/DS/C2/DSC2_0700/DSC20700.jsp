<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC20700.jsp
作者：卓達瑋
功能：單位帳務明細查詢
完成：2013/05/07

[20241030]修改件 CHROME瀏覽器難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<%--[20241030]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript">

Event.observe(window, 'load', new DSC20700().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC20700(){
	var grid;
	var grid1;
	var grid2;
	var grid3;
	var grid4;
    
	//檢核
	var valid1;	

	//檢核欄位
	function initValidation(){
		Validation.addAllThese([
			['validINPUT', '請輸入結帳人員或結帳單位！', function(v , node) { 
				if(!$F('INPUT_ID') && !$F('INPUT_DEPT')){
					return false;
				}
				return true;
			}],
			['validINPUT_ID', '結帳人員格式有誤', function(v , node) { 
				if(v){
					return validation.checkROCID( v );
				}
				return true;
			}],
			['validINPUT_DEPT', '結帳單位格式有誤', function(v , node) { 
				if(v){
					return (/^[a-zA-Z0-9]+$/.test(v));
				}
				return true;
			}],
			['validACNT_NO', '結帳序號格式有誤', function(v , node) { 
				if(v){
					return (/^[0-9]+$/.test(v));
				}
				return true;
			}]
		]);
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});
 	    valid1.define('required' , [{ id : "INPUT_DATE" , errMsg:'請輸入日期查詢!!'}] );
 	    valid1.define('validINPUT' , [{ id : "INPUT_ID" , errMsg:'請輸入結帳人員或結帳單位！'}] );
 	    valid1.define('validINPUT_ID' , [{ id : "INPUT_ID" , errMsg:'結帳人員格式有誤'}] );
 	    valid1.define('validINPUT_DEPT' , [{ id : "INPUT_DEPT" , errMsg:'結帳單位格式有誤'}] );
 	    valid1.define('validACNT_NO' , [{ id : "ACNT_NO" , errMsg:'結帳序號格式有誤'}] );
	}	
	<%-- [20241030] 難字調整 --%>
    var gridList=[
			    [					
					{header:"筆數",key:"COUNT_NO"},
                    {header:"帳號",key:"LOAN_ID",
					    render:function(rec , val){ 							
							if(val){
								if(rec.ACNT_DATE ==null){
								//超連結至DSC2_0600(單位帳務剔除)畫面，供使用者進行帳務剔除
								var link = new Element( 'a' , { href : "#" } ).update(val);	
								link.observe( 'click', function (event){ 
									var LP_JSON = {
										action :'<%=dispatcher%>/DSC2_0600/prompt',	 	
										LOAN_ID : rec.LOAN_ID ,//貸款帳號
										PAY_TERM : rec.PAY_TERM ,//繳款別
										PAY_KIND : rec.PAY_KIND ,//繳款期數
										SEQ_NO : rec.SEQ_NO //序號
									}			
									CSRUtil.linkTo(LP_JSON , 'form1');
								});										
								return link;
                                }
								return val;
							}
							return '';
						}
					
					
					},	
					{header:"繳款別",key:"PAY_KIND_NM"},
					{header:"繳款期數",key:"PAY_TERM"},
					{header:"計息起日",key:"INT_BEGDT",
					    render : function (rec , val){
									return Date.toROC(val || "");									
						}
					},
					{header:"計息迄日",key:"INT_ENDDT",
					    render : function (rec , val){
									return Date.toROC(val || "");									
						}
					},
					{header:"應繳日",key:"DUTY_PAYDT",
					    render : function (rec , val){
									return Date.toROC(val || "");									
						}
					},
					{header:"延滯天",key:"DELAY_DAY"},
					{header:"利率",key:"RATE"},
                    {header:"上期本金",key:"LAST_PRINCIPAL",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"輸入人員",key:"INPUT_NM", style:"font-family:'EUDC'"},
					{header:"收息方式",key:"PAY_TYPE_NM"},
                    {header:"上期結餘",key:"LAST_BALANCE",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"實繳金額",key:"REAL_PAYMT",
					    render: function (record,value){
							return value ? MoneyFormat(value) :"";
						}
					},
                    {header:"本金",key:"PRINCIPAL",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
                    {header:"利息",key:"INTEREST",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"應利",key:"RETAIN_INT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"延滯息",key:"DELAY_INT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"違約金",key:"RENEGE",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"代扣稅款",key:"TAX",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"管理費",key:"LAWSUIT_FEE",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"票據表示",key:"CHECK_STATUS_NM"},
					{header:"本期結餘",key:"THIS_BALANCE"},
					{header:"收費代號",key:"GETINT_CODE"}	
				],
				[					
					{header:"筆數",key:"COUNT_NO"},
					{header:"行庫代號",key:"BANK_CODE"},
                    {header:"票據號碼",key:"CHECK_NO"},
                    {header:"貸款帳號",key:"LOAN_ID",
					    render:function(rec , val){ 							
							if(val){
								if(rec.ACNT_DATE){
								//超連結至DSC2_0600(單位帳務剔除)畫面，供使用者進行帳務剔除
								var link = new Element( 'a' , { href : "#" } ).update(val);	
								link.observe( 'click', function (event){ 
									var LP_JSON = {
										action :'<%=dispatcher%>/DSC2_0600/prompt',	 	
										LOAN_ID : rec.LOAN_ID ,//貸款帳號
										PAY_TERM : rec.PAY_TERM ,//繳款別
										PAY_KIND : rec.PAY_KIND ,//繳款期數
										SEQ_NO : rec.SEQ_NO //序號
									}			
									CSRUtil.linkTo(LP_JSON , 'form1');
								});										
								return link;
                                }
								return val;
							}
							return '';
						}
					
					
					},	
					{header:"繳款期數",key:"PAY_TERM"},
					{header:"繳款別",key:"PAY_KIND_NM"},
					{header:"收息方式",key:"PAY_TYPE_NM"},
					{header:"開票人帳號",key:"CHECK_ACCNO"},
					{header:"序號",key:"SEQ_NO"},
					{header:"票據日期",key:"CHECK_DATE",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},
                    {header:"票面金額",key:"CHECK_AMT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
                    {header:"繳票金額",key:"TICKET_AMT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"繳現金額",key:"CASH_AMT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"託收行庫",key:"AGENT_BANK"},
					{header:"收費代號",key:"GETINT_CODE"},
					{header:"票據組號",key:"CHECK_GROUP"}	
				],
			    [					
					{header:"筆數",key:"COUNT_NO",attrs:{rowSpan:2}},
					{header:"暫應收編號",key:"BALC_NO"},
                    {header:"貸款帳號",key:"LOAN_ID",
					    render:function(rec , val){ 							
							if(val){
								if(rec.ACNT_DATE ==null){
								//超連結至DSC2_0600(單位帳務剔除)畫面，供使用者進行帳務剔除
								var link = new Element( 'a' , { href : "#" } ).update(val);	
								link.observe( 'click', function (event){ 
									var LP_JSON = {
										action :'<%=dispatcher%>/DSC2_0600/prompt',	 	
										LOAN_ID : rec.LOAN_ID ,//貸款帳號
										PAY_TERM : rec.PAY_TERM ,//繳款別
										PAY_KIND : rec.PAY_KIND ,//繳款期數
										SEQ_NO : rec.SEQ_NO //序號
									}			
									CSRUtil.linkTo(LP_JSON , 'form1');
								});										
								return link;
                                }
								return val;
							}
							return '';
						}

					},	
					{header:"繳款期數",key:"PAY_TERM"},
					{header:"繳款別",key:"PAY_KIND_NM"},
					{header:"收息方式",key:"PAY_TYPE_NM"},
					{header:"暫應收原因",key:"BALC_REASON"},
                    {header:"原暫收金額",key:"BALC_AMT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
                    {header:"剩餘金額",key:"REMAIN_AMT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"部入序號",key:"SEQ_NO"},
					{header:"實繳日",key:"REAL_PAYDT",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},
					{header:"票據狀態",key:"CHECK_STATUS_NM"},
					{header:"暫應收備註",key:"BALC_MEMO"}	
				],
			    [					
					{header:"筆數",key:"COUNT_NO"},
					{header:"暫應收編號",key:"BALC_NO"},
                    {header:"沖帳貸款帳號",key:"LOAN_ID",
					    render:function(rec , val){ 							
							if(val){
								if(rec.ACNT_DATE ==null){
								//超連結至DSC2_0600(單位帳務剔除)畫面，供使用者進行帳務剔除
								var link = new Element( 'a' , { href : "#" } ).update(val);	
								link.observe( 'click', function (event){ 
									var LP_JSON = {
										action :'<%=dispatcher%>/DSC2_0600/prompt',	 	
										LOAN_ID : rec.LOAN_ID ,//貸款帳號
										PAY_TERM : rec.PAY_TERM ,//繳款別
										PAY_KIND : rec.PAY_KIND ,//繳款期數
										SEQ_NO : rec.SEQ_NO //序號
									}			
									CSRUtil.linkTo(LP_JSON , 'form1');
								});										
								return link;
                                }
								return val;
							}
							return '';
						}
					
					},	
					{header:"沖帳繳款期數",key:"PAY_TERM"},
					{header:"沖帳繳款別",key:"PAY_KIND_NM"},
					{header:"暫應收原因",key:"BALC_REASON"},
					{header:"收息方式",key:"PAY_TYPE_NM"},
                    {header:"沖帳前剩餘金額",key:"REMAIN_AMT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
                    {header:"沖帳金額",key:"WASH_AMT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},
					{header:"沖帳部入序號",key:"SEQ_NO"},
					{header:"沖帳方式",key:"WASH_TYPE_NM"},
					{header:"暫應收備註",key:"BALC_MEMO"}	
				],
				[					
					{header:"筆數",key:"COUNT_NO"},
					{header:"受理編號",key:"APPLY_ID"},
                    {header:"單據序號",key:"RECEIPT_SERNO"},
                    {header:"繳款金額",key:"PAYMENT_AMT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},					
					{header:"輸入單位",key:"INPUT_DEPT"},
					{header:"輸入人員",key:"INPUT_NM", style:"font-family:'EUDC'"},
					{header:"輸入日期",key:"INPUT_DATE",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},
					{header:"結帳序號",key:"ACNT_NO"},
					{header:"轉新件編號",key:"NEW_APPLY_ID"},
					{header:"轉出收據狀態",key:"RECEIPT_STATUS"}	
				],
				[					
					{header:"筆數",key:"COUNT_NO"},
					{header:"處理序號",key:"PROC_SER_NO"},
                    {header:"流水序號",key:"SER_NO"},
                    {header:"專款金額",key:"AMT",
					    render: function (record,value){
							return value ? MoneyFormat(value) : "";
						}
					},					
					{header:"專款單位",key:"DIV_NO"},
					{header:"輸入單位",key:"INPUT_DEPT"},
					{header:"輸入人員",key:"INPUT_NM", style:"font-family:'EUDC'"},
					{header:"輸入日期",key:"INPUT_DATE",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},
					{header:"結帳序號",key:"ACNT_NO"},
					{header:"摘要",key:"MEMO"}
				]
			
			
			
			
	]
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_0700/" + actionName,
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
	    queryMap : function(){
			return  {
				'QUERY_TYPE' : $F('QUERY_TYPE'), 
				'INPUT_ID' : $F('INPUT_ID'), 
				'INPUT_DEPT' : $F('INPUT_DEPT'),
                'INPUT_DATE' : $F('INPUT_DATE'),
                'ACNT_STATUS' : $F('ACNT_STATUS'),
                'ACNT_NO' : $F('ACNT_NO')
			}		
	    },
		//table UI 共同方法
		gridtable : function(i,s){
			<%-- [20241030] 難字調整 --%>
		    grid = new TableUI(
				 {table: $("grid"), allSortable: true, pageSize: 20,split:s,
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
			column:gridList[i]});
		},
		//table UI for 現金
		gridcash : function(){
		    grid = new TableUI(
				 {table: $("grid"), allSortable: true, pageSize: 20,split:["RATE","RETAIN_INT"],			
			column:gridList[0]});
			
			if(!grid1){
				grid1 = new TableUI(
					 {table: $("grid1"), allSortable: true, pageSize: 20,split:["BALC_AMT"], title:"人工暫收",			
				column:gridList[2]});
			}
			
			if(!grid2){
				grid2 = new TableUI(
					 {table: $("grid2"), allSortable: true, pageSize: 20,split:["BALC_AMT"], title:"人工應收",			
				column:gridList[2]});
			}
			
			if(!grid3){
				grid3 = new TableUI(
					 {table: $("grid3"), allSortable: true, pageSize: 20,split:["PAY_TYPE_NM"],	title:"沖人工暫收",		
				column:gridList[3]});
			}
			
			if(!grid4){
				grid4 = new TableUI(
					 {table: $("grid4"), allSortable: true, pageSize: 20,split:["PAY_TYPE_NM"], title:"沖人工應收",			
				column:gridList[3]});
			}
		}
	}	
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {	
		    
			//檢核
			if(!valid1.validate()){				
				return; 
			}
			

			if(diffDayROC($F('INPUT_DATE'),$F('SYS_DATE'))>60){
			   alert('帳務明細只供查詢近二個月之資料！');
			   return;

			}
			
			//var splitList=["LAST_BALANCE","SEQ_NO","BALC_AMT","PAY_TYPE_NM","",""];
            //條件式給table UI
            if($F('QUERY_TYPE')=='1'){
				actions.gridcash();	
			}else if($F('QUERY_TYPE')=='0'||$F('QUERY_TYPE')=='3'||$F('QUERY_TYPE')=='4'
			||$F('QUERY_TYPE')=='5'||$F('QUERY_TYPE')=='6'||$F('QUERY_TYPE')=='14'){
			    actions.gridtable(0,["RATE","RETAIN_INT"]);	
			}else if($F('QUERY_TYPE')=='2'){
			    actions.gridtable(1,["SEQ_NO"]);
			}else if($F('QUERY_TYPE')=='7'||$F('QUERY_TYPE')=='8'){
			    actions.gridtable(2,["BALC_AMT"]);
			}else if($F('QUERY_TYPE')=='9'||$F('QUERY_TYPE')=='10'){
			    actions.gridtable(3,["PAY_TYPE_NM"]);
			}else if($F('QUERY_TYPE')=='11'||$F('QUERY_TYPE')=='12'||$F('QUERY_TYPE')=='136'||$F('QUERY_TYPE')=='137'){
			    actions.gridtable(4,[""]);
			}else if($F('QUERY_TYPE')=='135'){
			    actions.gridtable(5,[""]);
			}

			ajaxPost( 'query', {'reqMap' :Object.toJSON(actions.queryMap())}
				,function(resp){	
					if ($F('QUERY_TYPE')=='1') {
						var LastObj = [ {text:'合計', textAlign : 'center', value:resp.totalMap}];
						var LastObj1 = [ {text:'合計', textAlign : 'center', value:resp.totalMap1}];
						var LastObj2 = [ {text:'合計', textAlign : 'center', value:resp.totalMap2}];
						var LastObj3 = [ {text:'合計', textAlign : 'center', value:resp.totalMap3}];
						var LastObj4 = [ {text:'合計', textAlign : 'center', value:resp.totalMap4}];
						grid.load(resp.rtnList || [],LastObj || {});
						if(grid.isNew){
							if(grid1){grid1.show();}
			                if(grid2){grid2.show();}
			                if(grid3){grid3.show();}
			                if(grid4){grid4.show();}
						}else{
							$('grid1').up('div').show();
							$('grid2').up('div').show();
							$('grid3').up('div').show();
							$('grid4').up('div').show();
						}
						grid1.load(resp.rtnList1 || [],LastObj1 || {});
						grid2.load(resp.rtnList2 || [],LastObj2 || {});
						grid3.load(resp.rtnList3 || [],LastObj3 || {});
						grid4.load(resp.rtnList4 || [],LastObj4 || {});	
					} else {				
						var LastObj = [ {text:'合計', textAlign : 'center', value:resp.totalMap}];
				    	grid.load(resp.rtnList || [],LastObj || {});
				    	if(grid.isNew){
				    		if(grid1){grid1.hide();}
			                if(grid2){grid2.hide();}
			                if(grid3){grid3.hide();}
			                if(grid4){grid4.hide();}
				    	}else{
		                    if(grid1){$('grid1').up('div').hide();}
		                    if(grid2){$('grid2').up('div').hide();}
		                    if(grid3){$('grid3').up('div').hide();}
		                    if(grid4){$('grid4').up('div').hide();}
		                }
					}
				}
				,function(resp){
                    grid.load([]);
                    if ($F('QUERY_TYPE')=='1') {
                    	if(grid.isNew){
				    		if(grid1){grid1.show();}
			                if(grid2){grid2.show();}
			                if(grid3){grid3.show();}
			                if(grid4){grid4.show();}
				    	}else{
		                    if(grid1){$('grid1').up('div').show();}
		                    if(grid2){$('grid2').up('div').show();}
		                    if(grid3){$('grid3').up('div').show();}
		                    if(grid4){$('grid4').up('div').show();}
		                }
                    } else {
                    	if(grid.isNew){
				    		if(grid1){grid1.hide();}
			                if(grid2){grid2.hide();}
			                if(grid3){grid3.hide();}
			                if(grid4){grid4.hide();}
				    	}else{
		                    if(grid1){$('grid1').up('div').hide();}
		                    if(grid2){$('grid2').up('div').hide();}
		                    if(grid3){$('grid3').up('div').hide();}
		                    if(grid4){$('grid4').up('div').hide();}
		                }
                    }
				}
			);
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSC20700" , "收息帳務", "單位帳務明細查詢" );
		
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
				
			//畫面檢核
			initValidation();
			// 監聽
			$("BTN_QUERY").observe('click', button.doQuery);
			
            //Input欄位自動轉大寫
			$('INPUT_ID').observe('change',function(){
				$('INPUT_ID').value = $F('INPUT_ID').toUpperCase();
			});	
			$('INPUT_DEPT').observe('change',function(){
				$('INPUT_DEPT').value = $F('INPUT_DEPT').toUpperCase();
			});	
			
			PageUI.resize();	
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <input type="hidden" id="SYS_DATE" value="${INPUT_DATE}" />
	<tr>

		<td class='tbYellow' width='15%'>
			查詢種類
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="QUERY_TYPE" class="textBox2">
				<c:forEach items="${QUERY_TYPE_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow' width='15%'>
			結帳人員
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='INPUT_ID' type='text' class= 'textBox2'   size='12' maxlength='10' value=""/> 
		</td>
		<td class='tbYellow' width='15%'>
			結帳單位
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='INPUT_DEPT' type='text' class= 'textBox2'   size='9' maxlength='7' value="${INPUT_DEPT}"/> 
		</td>
	    <td class='tbYellow2' width='5%' rowspan='2' align="center">
			<input type="button" class="button" id="BTN_QUERY" value="查詢"<%-- 查詢 --%> />	
		</td>
	    
	
	</tr>
	<tr>
		<td class='tbYellow' width='15%'>
			輸入日期
		</td>
		<td class='tbYellow2' width='10%'>
			<input id="INPUT_DATE" datatype="ROCDate" type="text" class="textBox2 "  size="10" maxlength="7" value="${INPUT_DATE}"/>
			<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('INPUT_DATE'))">
		</td>
		<td class='tbYellow' width='15%'>
			結帳狀況
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="ACNT_STATUS" class="textBox2">
				<c:forEach items="${ACNT_STATUS_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow' width='15%'>
			結帳序號
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='ACNT_NO' type='text' class= 'textBox2'   size='4' maxlength='2' value=""/> 
		</td>
    </tr>
</table>
    <table id='grid' width='100%'></table>
	<table id='grid1' width='100%'></table>
	<table id='grid2' width='100%'></table>
	<table id='grid3' width='100%'></table>
	<table id='grid4' width='100%'></table>
</form>
</body>
</html>	