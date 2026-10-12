<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSD10300.jsp
作者：i9300615
功能：DSD1_0300 每日約定繳款催收件通知
完成：
更新：

[20240322]難字
-->


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>

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

<script type="text/javascript" type="text/JavaScript">

//Event.observe(window, 'load', initApp);

var grid;

<!-- Define UI Class Start----------------------------------------------------- -->
function UI(){

	//--------------------------------------------------------------------------  
	//UI() private variable
	//-------------------------------------------------------------------------- 	
	var valid1;
	
	//------------------------------------------------------------------------
	//查詢
	function query(){
	
		valid1.reset();
		if( !valid1.validate() ) {return;}

	
		ajaxPost('query', Form.serialize("form1"), successAction, errorAction);
	}

	
	//--------------------------------------------------------------------------	
	function successAction(resp) {
		if(CSRUtil.isSuccess(resp)){		
			grid.load( (resp.rtnList) ? resp.rtnList : [], resp.sumList);					
		}
	}
		
	function errorAction() {
		grid.load([]);					
	}

	
	var nextchecktype = "${nextchecktype}";
	
	var validateDate = function(){		
		if($F('STAT_DATE'))
			return isROCdate($F('STAT_DATE'));		
	}
	
	//--------------------------------------------------------------------------
	//以下為UI() public method,放在 return 中
	//--------------------------------------------------------------------------  
	return{
	
		//init Function for 初始整個UI Class
		init:function(){
			

			Validation.addAllThese([
				[ 'validateDate',  '請輸入正確民國年格式', validateDate]				
			]);	
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false}); 
			
			
			displayMessage();
			
			var index = 0;
			
			//產生 Grid 物件
			grid = new TableUI(	{
            table: $("grid"), pageSize: 10, allSortable:true, split: ['MONTH_URGE_CNT'],
            <%-- [20240322]難字 --%>
            afterLoad: function() {
            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
            },
            pageChange: function() {
            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
            },
			column:[
			{header: "催繳次數", key:"TIMES", attrs: {align:"right"} ,sortRule:'number', 
				render: function( record, value ){				
              		return CSRUtil.$fmt(value, "#,##0");
            	}
            },
            {header: "約定繳款日", key:"DUE_DATE" , 
				render: function( record, value ){
              		return Date.toROC(value);
            	}
            },
            {header: "帳號", key:"LOAN_ID" },
            {header: "姓名", key:"BORROW_NAME", attrs:{ style:"font-family:'EUDC'" } },<%-- [20240322]難字 --%>
            {header: "下次應繳日", key:"NEXT_PAYDATE" , 
				render: function( record, value ){
              		return Date.toROC(value);
            	}
            },
            {header: "本金餘額", key:"TOT_AMT", attrs: {align:"right"} ,sortRule:'number', 
				render: function( record, value ){				
              		return CSRUtil.$fmt(value, "#,##0.00");
            	}
            },
            {header: "服務中心一", key:"DIV_NM1" },
            {header: "服務中心二", key:"DIV_NM2" },
            {header: "區域", key:"DIV_NM0" }
	
			]
			});
			
			// end of grid
			

			//查詢
	 		$('btn_QUERY').observe('click', function(event){
	 			query();
	 		});	
	 		
			<c:if test="${not empty rtnList}">
				grid.load(${rtnList}, ${sumList});			
			</c:if>
						
	 		
		}//end init()--
		
	}//end return--
	//-------------------------------------------------------------------------- 
	
}
<!--Define UI Class End-------------------------------------------------------->


<!--全域 函數 UI 與 畫面 公用 Start-------------------------------------------------->
//--------------------------------------------------------------------------  
//共用ajaxpost function
function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSD1_0300/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){
			if(CSRUtil.isSuccess(resp)){
				if(successAction){
	 				successAction(resp);
	 			}
			}else if(errorAction){
	 			errorAction();
	 		}
        }}
	);
}	


//-------------------------------------------------------------------------- 
<!--全域 函數 UI 與 畫面 公用 End---------------------------------------------------->
</script>

</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onload="new UI().init()" onResize='fix()' onScroll="fix()">

<!--此網頁自建使用的JavaScript 放下面 -->

<center><!-- Bolck_1_Start 表單的開頭 功能名稱 畫面編號--> 
<span id="bar1" style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible">
<table width="100%" height="30" border="0" cellpadding="0" 	cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
			<tr>
				<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
			<tr>
				<td width="20" height="24">
				<div align="center"><font size="-5">●</font></div>
				</td>
				<td><b>逾繳催收</b></td>
				<td>
				<div align="right">畫面編號：DSD10300</div>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</span> <!-- Bolck_1_ End--> <!-- Bolck_2_Start 空白區塊 版面跳行-->

<table width="100%" height="30" border="0" cellpadding="0" 	cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>

<!-- Bolck_2_End--> <!-- Bolck_3_Start 表單主功能區塊-->
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
		    <img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td valign="top">
				<table width=97% border=0 align=center cellpadding="5" cellspacing="1" bgcolor="#003366">
					<tbody>
						<tr>
							<td class="tbBox2" colspan="5">每日約定繳款催收件通知</td>							
						</tr>
						<tr bgcolor=#FFFFFF>
						  <td>
							<form name="form1" id="form1" method="post" action="">								
								
								<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
								<tr>
									<td class="tbYellow" width="10%" nowrap>查詢日期</td>										
						            <td class="tbYellow2" width="30%" nowrap>
							           	<input name="STAT_DATE" id="STAT_DATE" datatype="ROCDate" type="text" class="textBox2 required validateDate" size="12" maxlength="7" value="${STAT_DATE}" >
							           	<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('STAT_DATE'))"> 							           
							        </td>
									
									<td class="tbYellow2" rowspan='2' width="10%" align="center" nowrap>
									    <input name="btn_QUERY"	id="btn_QUERY" type="button" value="查詢" class="button">

   									</td>
								</tr>								
							   </table>
							   
							   <table class="grid" id="grid" width=100% border="1" cellpadding="0" cellspacing="0" class="tbBox2" bordercolorlight="#C7E49C" bordercolordark="#C7E49C" >
							   </table>

							   
							</form>
							  
							  </td>
						</tr>
					</tbody>
				</table>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
<!-- Bolck_3_End--></center>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
</BODY>
</HTML>