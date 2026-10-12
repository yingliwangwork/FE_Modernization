<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSD10700.jsp
作者：黃子玹 
功能：扣薪不足明細
完成：2013/5/3

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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
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
Event.observe(window, 'load', new DSD10700().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSD10700(){
		
	var grid;
	var rtnList;
	
	function buttonAuth(){
		var authButtons = {	
			B0174:"btn_print"		
		};
		<dz:grantButtons FUNC_ID="DSD10700" />
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_0700/" + actionName,
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
			
		//查詢
		doQuery : function(event) {
			var DEPT_ID =  $F('DEPT_ID');
			
			
			
			ajaxPost( 'query',	{DEPT_ID: $F('DEPT_ID')},
				function(resp){			
					rtnList = resp.rtnList;			
					grid.load(rtnList);						
				},function(resp){
					//失敗把前次內容清掉 
					grid.load([]);			
				}					
			);		
		},
		//列印
		doPrint : function(event) {
			if(!rtnList || rtnList.length == 0){
				alert('需做過查詢才能列印!');
				return;
			}
			RPTUtil.executePrintByLink('print' , {DEPT_ID: $F('DEPT_ID')}, true );			
		}		
		
	};
	
	
	return{
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSD10700" , "催收件" , "扣薪不足明細");
			
				grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: true,
				<%-- [20240322]難字 --%>
	            afterLoad: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
	            },
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
	            },
				column: [
				    {header:"收息單位", key:'GETINT_DEPT'},
					{header:"帳號", key:'LOAN_ID'},
					{header:"姓名", key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},<%-- [20240322]難字 --%>				
					{header:"已繳期數", key:'PAY_TERM'},
					{header:"下次應繳日", key:'NEXT_PAYDATE',
						render : function (rec , val){
									return Date.toROC(val || "");									
						}
					},
					{header:"寬限到期日", key:'GRACE_DATE',
						render : function (rec , val){
									return Date.toROC(val || "");									
							}					
					}		
				]	
			});

			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			
			
			// 查詢
			$('btn_query').observe('click', function(event){
				actions.doQuery();
			});
			//列印
			$('btn_print').observe('click', function(event){
				actions.doPrint();
			});
			
			//Input欄位自動轉大寫
			$('DEPT_ID').observe('change',function(){
				$('DEPT_ID').value = $F('DEPT_ID').toUpperCase();
			});
			buttonAuth();		
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//end DSD10700
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>				
				<td class="tbYellow" width= "8%" align="left">單位代號</td>
				<td class="tbYellow2" width ="8%">
					<input id="DEPT_ID" type="text" class="textBox2"  size="12" maxlength="10" />
				</td>				
				<td class="tbYellow2" width = "80%" align="left" >
				<input id="btn_query" type="button" class="button" value="查詢">
				<input id="btn_print" type="button" class="button" value="列印">
				</td>	
			</tr>		
		</table>		
	</form>	
		<table id="grid" width="100%" class="grid" ></table>
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
				<tr>
					<td class="tbYellow2">
					<font color="blue">一、作業規定</font>
					<br>&nbsp; 1. 各種貸款規定請參照放款作業手冊及發文規定。
					<br>&nbsp; 2. 本作業可供查詢該<font color="blue">收息單位</font>的扣薪不足未繳件。
					<br><br>
					<font color="blue">二、操作方式</font>
					<br>&nbsp; 1. 於<font color="red">收息單位</font>欄位輸入欲查詢之單位代號，再按<font color="blue">查詢</font>即可。
					</td>
				</tr>		
		</table>	
</body>
</html>