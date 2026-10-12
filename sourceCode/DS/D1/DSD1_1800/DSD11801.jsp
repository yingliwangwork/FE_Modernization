<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSD11801.jsp
作者：黃子玹 
功能：催收明細作業-首頁
完成：2013/7/31

[20240322]難字
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>		  <%-- 月曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			  <%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>

<%-- [20240322]難字 --%>
<style type="text/css">
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSD11801().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSD11801(){

	var LOAN_ID = '${LOAN_ID}';
	var grid;
	var grid1;	
	var valid1;
	var rtnListD020;
	
	//畫面檢核
	function initValidation(){
	
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode:'validator'});			
		//valid1.define('required' , [{ id : "SEQ_NO" ,errMsg : '起迄序號不可空白!' }] );
		valid1.define('validate-number' , [{ id : "SEQ_NO" , errMsg:'序號須為數字'}]);			
		
		valid1.define( "validate-ROCDate" , [{ id : "INPUT_DATE_S" , errMsg:"催繳日期起日須符合民國年月日格式!" } ] );
		
		valid1.define( "validate-ROCDate" , [{ id : "INPUT_DATE_E" , errMsg:"催繳日期迄日須符合民國年月日格式!" } ] );
		
		valid1.define( "validate-ROCDate-Interval" , [{ id : "INPUT_DATE_S" , errMsg :"催繳日期迄日需大於催繳日期起日!" },{ id : "INPUT_DATE_E" , errMsg :"催繳日期迄日需大於催繳日期起日!"}] );
 	    
	
	}


	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1801/" + actionName,
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
	
	//按扭權限
	function buttonAuth(){
		var authButtons = {				
            B0174:"btn_print"				
		};
	
		<dz:grantButtons FUNC_ID="DSD11801" />
	}

	var actions = {			
		
		//查詢
		doQuery : function(isPrompt) {	
		
			
			var SEQ_NO;
			if( isPrompt != 'isPrompt'){
				valid1.reset();
				if(!valid1.validate()){
					return;
				}
				SEQ_NO = $F('SEQ_NO');			
	
			}else{
				SEQ_NO = '';
				$('SEQ_NO').value='';
					
			}
			ajaxPost( 'query',{LOAN_ID:LOAN_ID,SEQ_NO : SEQ_NO,INPUT_DATE_S :$F('INPUT_DATE_S'),INPUT_DATE_E :$F('INPUT_DATE_E')},
				function(resp){	
					rtnListD020 = resp.rtnListD020 || [];				
					grid.load(rtnListD020);
					grid1.load(resp.rtnListD030 || []);
					
				},function(resp){					
					rtnListD020=[];
					grid.load([]);
					grid1.load([]);	
				}					
			);		
		}
		//列印
		,doPrint : function(event) {
			
			if(!rtnListD020){
				alert('需做過查詢才能列印!');
				return;
			}				
			ajaxPost('print', {LOAN_ID : LOAN_ID},
				function(resp){				
					RPTUtil.executePrintByResponse(resp, true);			
				}		
			);	
		}

		
	};

	return{
	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSD11801" , "催收件" , "催收明細作業-首頁",1,true);
			
			grid = new TableUI({
				table: $('grid'), pageSize: 10, allSortable: true, overDiv:false,
				
				<%-- [20240322]難字 --%>
	            afterLoad: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
	            },
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
	            },
	
				column: [	
					{header:"序號", key:'SEQ_NO'},			
			        {header:"約定繳款日", key:'DUE_DATE',
						render : function (rec , val){
							return Date.toROC(val || '');									
						}			
					},			
					{header:"催收人員", key:'INPUT_ID', attrs:{ style:"font-family:'EUDC'" },<%-- [20240322]難字 --%>
							render : function (rec , val){				
								return rec.INPUT_NM || '';
						    }						
					},									
					{header:"催收日期", key:'INPUT_DATE',
						render : function (rec , val){
							return Date.toROC(val || '');									
						}
					},
					{header:"催收情況-備註", key:'STATUS_NM', attrs: {align:"left"}, styles:{'width':'800px'},
						render : function (rec , val){
							return (val+" - "+rec.NOTE);
						}
					}		

				]	
			});
			
			grid1 = new TableUI({
				table: $('grid1'), pageSize: 20, allSortable: true, overDiv:false,		

				column: [	
					{header:"催收地址", key:'URGE_ADDR', attrs:{ style:"font-family:'EUDC'" }},<%-- [20240322]難字 --%>			
			        {header:"催收電話", key:'URGE_TEL'},	
			        {header:"備註", key:'NOTE'},			
					{header:"擔保品現況", key:'GUARANTEE'},										
					{header:"查看人員職稱", key:'CHECK_LEV_NM'},
					{header:"查看人員", key:'CHECK_NAME', attrs:{ style:"font-family:'EUDC'" }}	<%-- [20240322]難字 --%>				
				]	
			});
				
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			
				
			$('btn_query').observe('click', function(event){
				actions.doQuery(); 
			});
			
			$('btn_print').observe('click', function(event){
				actions.doPrint(); 
			});
			
			if(LOAN_ID != ''){
				actions.doQuery('isPrompt');				
			}
			buttonAuth();
			initValidation();
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//end DSD11801
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width= "15%" align="left">催繳日期</td>
				<td class="tbYellow2" width ="35%">
					<input id="INPUT_DATE_S" type="text" class="textBox2" size="8" maxlength="7" datatype="ROCDate">
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('INPUT_DATE_S'))">
					~
					<input id="INPUT_DATE_E" type="text" class="textBox2" size="8" maxlength="7" datatype="ROCDate">
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('INPUT_DATE_E'))">			
				</td>						
				<td class="tbYellow" width= "15%" align="left">起始序號</td>
				<td class="tbYellow2" width ="35%">
					<input id="SEQ_NO"  type="text" class="textBox2" size="8" maxlength="6"/>查詢起始序號後30筆
				</td>						
			</tr>
			<tr>
				<td  width="100%" colspan="4" align="center">					
					<input id="btn_query" type="button" class="button" value='查詢'/>
					<input id="btn_print" type="button" class="button" value='列印'/>		
				</td>
			</tr>			
		</table>
	</form>
	<table id="grid"><tr><td>&nbsp;</td></tr></table>
	<table id="grid1"><tr><td>&nbsp;</td></tr></table>
</body>
</html>		