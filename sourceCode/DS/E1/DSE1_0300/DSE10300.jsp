<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSE10300.jsp
作者：黃子玹 
功能：債信索引作業查詢
完成：2013/4/22

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
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>	   <%-- 地址用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>	   
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
Event.observe(window, 'load', new DSE10300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSE10300(){

	var grid;
	var GAGE_NUMBER;	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_0300/" + actionName,
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

	//畫面檢核
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode:'validator'});			
			valid1.define('required' , [{ id : "CREDIT_ID" ,errMsg : '身分證字號、門牌號碼至少必需輸入其中一項!' }] );
			valid1.define('required' , [{ id : "GAGE_NUMBER_INPUT_ADDR" ,errMsg : '身分證字號、門牌號碼至少必需輸入其中一項!' }] );
			
	}
	var actions = {
		
		//查詢
		doQuery : function(event) {
			
			var INPUT_ADDR = GAGE_NUMBER.getINPUT_ADDR();			
			var CREDIT_ID = $F('CREDIT_ID'); 		
					
			valid1.reset();			
			if(CREDIT_ID.length == 0 && INPUT_ADDR.length == 0){				
				if(!valid1.validate()){
					return; 
				}			
			}
			
			//將畫面上的欄位存成reqMap			
			var reqMap = {};		
			
			//設定身分證字號
			reqMap.CREDIT_ID = $F('CREDIT_ID');
			//將設定門牌號碼
			reqMap.GAGE_CITY = GAGE_NUMBER.getCITY_NAME();			
			reqMap.GAGE_TOWN = GAGE_NUMBER.getTOWN_NAME();
			reqMap.GAGE_ADDR = GAGE_NUMBER.getINPUT_ADDR();	
			reqMap.GAGE_ZIP = GAGE_NUMBER.getINPUT_ZIPCODE();				
			
			ajaxPost( 'query',	{reqMap: Object.toJSON(reqMap)},
				function(resp){			
					var rtnList = resp.rtnList;				
					grid.load(rtnList);						
				},function(resp){
					//失敗把前次內容清掉 
					grid.load([]);			
				}					
			);		
		},		
		doClear :　function(event) {			
			//清空【區塊1】
			$('CREDIT_ID').value ="";
			//將include的下拉選單初始化
			GAGE_NUMBER.setCITY_NAME("");		
		}	
	};

	return{
	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSE10300" , "法務作業" , "債信索引作業查詢");
			
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
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"原貸帳號", key:'REFER_ID',
						render : function(record , value){							
								var link = new Element('a', { 'href' : '#'}).update(value);
								link.observe('click', //監聽click事件
									function( event ) {
										//開啟新視窗(POP UP)至DSE1_0301 債信索引作業明細 	
										/*	                      
			                     		var LP_JSON={};
										LP_JSON.parameters  = {
										   'REFER_ID':record.REFER_ID,
											TableInfo : grid.getTableInfo()
						          		};
			                     		LP_JSON.src = "<%=dispatcher%>/DSE1_0301/prompt";
			                     		popupWin.popup(LP_JSON); 
			                     		*/ 	
			                     		var source = '<%=dispatcher%>/DSE1_0301/prompt'; 
										popupWin.popup({
										parameters : {  'REFER_ID':record.REFER_ID,TableInfo : grid.getTableInfo()},
										src : source,
										width:'99%', 
										height:'99%',
										left : '10',  
										top :'10'									
									});
			                     			                     			
			                      	}
			                    );							
					            return link;
						    }
					},
					<%-- [20240207] 難字調整：借款人、擔保品地址 --%>
					{header:"借款人", key:'CREDIT_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"擔保品地址", key:'GAGE_ADDR', attrs:{ style:"font-family:'EUDC'" }}		
				]	
			});
				
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			
			initValidation();
			
			// 查詢
			$('btn_query').observe('click', function(event){
				actions.doQuery();
			});
			//清除
			$('btn_clear').observe('click', function(event){
				actions.doClear(); 
			});
			
			//產生門牌號碼下拉選單群
			GAGE_NUMBER = new DSZ01000($('GAGE_NUMBER'), '1');	
		
			
			//Input欄位自動轉大寫
			$('CREDIT_ID').observe('change',function(){
				$('CREDIT_ID').value = $F('CREDIT_ID').toUpperCase();
			});	
					
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//end DSE10300
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width= "12%" align="left">身分證字號</td>
				<td class="tbYellow2" width ="48%">
					<input id="CREDIT_ID" type="text" class="textBox2"  size="12" maxlength="10" />
				</td>
				<td class="tbYellow2" width = "40%" rowspan='2' align="center" >
				<input id="btn_query" type="button" class="button" value="查詢">
				<input id="btn_clear" type="button" class="button" value="清除">
				</td>	
			</tr>	
			<tr>
				<td class="tbYellow" width="10%" align="left">門牌號碼</td>
				<td class="tbYellow2" width = "45%" id ="GAGE_NUMBER"  >					
				</td>	
			</tr>			
		</table>
	</form>
		<table id="grid" width="100%" class="grid" ></table>
</body>
</html>		