<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSE11100.jsp
作者：黃子玹 
功能：法務個件查詢
完成：2013/6/13

[20240207]
難字調整
高強禾
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>        <%-- 投資共用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>	   <%-- 地址用 --%>
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
<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSE11100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSE11100(){

	var grid;
	var GAGE_ADDR;	
	var isNotNull;	
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_1100/" + actionName,
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

	var actions = {
				
		getMap : function(){
			var reqMap = {};
			isNotNull = false;			
			reqMap.LOAN_ID = $F('LOAN_ID');		
			reqMap.BORROW_ID = $F('BORROW_ID');		
			reqMap.BORROW_NAME = $F('BORROW_NAME');		
			reqMap.GAGE_ADDR = GAGE_ADDR.getINPUT_ADDR();
			if( reqMap.LOAN_ID || reqMap.BORROW_ID || reqMap.BORROW_NAME || reqMap.GAGE_ADDR){			
				isNotNull = true;
			}			
			return 	reqMap;				
		}	
		
		//現行案件查詢
		,doQuery1 : function(event) {	
			
			var reqMap = actions.getMap();		
			
			if(!isNotNull){
				alert('貸款帳號、借款人ID、借款人姓名、地址至少必須輸入其中一項!');
				return;
			}			
			
			$('QUERY_TYPE').value = '1';
			ajaxPost( 'query1',	{reqMap : Object.toJSON(reqMap)},
				function(resp){						
					grid.load(resp.rtnList);					
				},function(resp){					
					grid.load([]);			
				}					
			);		
		}
		//拍不足件查詢
		,doQuery2 : function(event) {	
				
			var reqMap = actions.getMap();		
			
			if(!isNotNull){
				alert('貸款帳號、借款人ID、借款人姓名、地址至少必須輸入其中一項!');
				return;
			}			
			$('QUERY_TYPE').value = '2';
			ajaxPost( 'query2',	{reqMap : Object.toJSON(reqMap)},
				function(resp){	
					grid.load(resp.rtnList);					
				},function(resp){					
					grid.load([]);			
				}					
			);		
		}
		//歷史案件查詢
		,doQuery3 : function(event) {	
				
			var reqMap = actions.getMap();		
			
			if(!isNotNull){
				alert('貸款帳號、借款人ID、借款人姓名、地址至少必須輸入其中一項!');
				return;
			}		
			$('QUERY_TYPE').value = '3';
			ajaxPost( 'query3',	{reqMap : Object.toJSON(reqMap)},
				function(resp){	
					grid.load(resp.rtnList);					
				},function(resp){					
					grid.load([]);			
				}					
			);		
		}
		//清空	
		,doClear :　function(event) {		
			grid.load([]);			
			form1.reset();	
			GAGE_ADDR.setINPUT_ZIPCODE("");
		}	
	};

	return{
	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSE11100" , "法務作業" , "法務個件查詢");
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: true,
                <%-- [20240207] 難字調整 --%>
                afterLoad: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
                pageChange: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
				column: [					
					{header:"貸款帳號", key:'LOAN_ID',
						render : function(rec , val){
							if(val){
								var link = new Element("a" , { href : "#" } ).update(val);
								link.observe( 'click', function (event){ 	
									var LP_JSON = {
										action :'<%=dispatcher%>/DSE1_1200/prompt',
										LOAN_ID : val
									}
									CSRUtil.linkTo(LP_JSON , 'form1');		
								});		
								return link;
							}else{
								return "";
							}				
						}
					},
					{header:"原貸帳號", key:'REFER_ID'},
					<%-- [20240207] 難字調整：借款人姓名、擔保品門牌 --%>
				    {header:"借款人姓名", key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"擔保品門牌", key:'GAGE_ADDR', attrs:{ style:"font-family:'EUDC'" }},
					{header:"法務進度", key:'LAW_PROCESS_NAME'},					
					{header:"法務進度日", key:'LAW_PROCESS_DATE',
								render : function (rec , val){
								return Date.toROC(val || '');									
							}				
					},
					<%-- [20240207] 難字調整：承辦法務 --%>
					{header:"承辦法務", key:'INPUT_NAME', attrs:{ style:"font-family:'EUDC'" }},			
					{header:"受理日", key:'INPUT_DATE',
						render : function (rec , val){
						return Date.toROC(val || '');									
						}					
					},
					{header:"退件日", key:'REJECT_DATE',
						render : function (rec , val){
						return Date.toROC(val || '');									
						}					
					}
				]	
			});
				
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			
			//產生門牌號碼下拉選單群
			GAGE_ADDR = new DSZ01000($('GAGE_ADDR'), '1');	
				
			//現行案件查詢
			$('btn_query1').observe('click', function(event){
				actions.doQuery1();
			});
			
			//拍不足件查詢
			$('btn_query2').observe('click', function(event){
				actions.doQuery2(); 
			});
			
			//歷史案件查詢
			$('btn_query3').observe('click', function(event){
				actions.doQuery3(); 
			});
			
			//清空
			$('btn_clear').observe('click', function(event){
				actions.doClear(); 
			});		
				
			//Input欄位自動轉大寫
			$('LOAN_ID').observe('change',function(){
				$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();
			});	
			$('BORROW_ID').observe('change',function(){
				$('BORROW_ID').value = $F('BORROW_ID').toUpperCase();
			});
			
			$('LOAN_ID').observe('focus',function(){	
				
				$w('BORROW_ID BORROW_NAME').each(
				function(id){
						$(id).value ='';
					}
				);
				
			});	
			
			
			$('BORROW_ID').observe('focus',function(){

				$w('LOAN_ID BORROW_NAME').each(
					function(id){
						$(id).value ='';
					}
				);
			});

			$('BORROW_NAME').observe('focus',function(){				

				$w('LOAN_ID BORROW_ID').each(
					function(id){
						$(id).value ='';
					}
				);
			});	
			
			PageUI.resize();
			displayMessage();
			
			if(CSRUtil.isBackLink('form1')){
				var QUERY_TYPE = $('QUERY_TYPE').value;
				if(QUERY_TYPE == '1'){
					actions.doQuery1();
				}else if(QUERY_TYPE == '2'){
					actions.doQuery2(); 				
				}else if(QUERY_TYPE == '3'){
					actions.doQuery3(); 
				}
			}
			
		}//end init()--
	};//end return--	
}//end DSE11100
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<input id="QUERY_TYPE"  name = "QUERY_TYPE" type="hidden" class="textBox2" />
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width= "10%" align="left">貸款帳號</td>
				<td class="tbYellow2" width ="12%">
					<input id="LOAN_ID"  name = "LOAN_ID"type="text" class="textBox2" size="12"/>
				</td>		
				<td class="tbYellow" width= "10%" align="left">債務人ID</td>
				<td class="tbYellow2"  width ="12%">
					<input id="BORROW_ID"    name = "BORROW_ID" type="text" class="textBox2" size="12"/>
				</td>
				<td class="tbYellow" width= "10%" align="left">借款人姓名</td>
				<td class="tbYellow2"  width ="12%">
					<%-- [20240207] 難字調整：借款人姓名 --%>
					<input id="BORROW_NAME"  name = "BORROW_NAME" type="text" class="textBox2" size="12" alt="ch" />
				</td>				
				<td class="tbYellow2" width = "20%" align="left" rowspan='2'>
					<input id="btn_query1" type="button" class="button" value="現行案件查詢"></br>		
					<input id="btn_query2" type="button" class="button" value="拍不足件查詢"></br>				
					<input id="btn_query3" type="button" class="button" value="歷史案件查詢"></br>
					<input id="btn_clear" type="button" class="button" value="清除"></br>	
				</td>				
			</tr>
			<tr>
				<td class="tbYellow" align="left" >門牌號碼</td>
				<td class="tbYellow2" id ="GAGE_ADDR" colspan='5'  >					
				</td>
			</tr>
	</form>
		<table id="grid" width="100%" class="grid" ></table>
</body>
</html>		