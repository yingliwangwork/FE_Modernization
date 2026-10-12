<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC20900.jsp
作者：張憶如 
功能：總帳帳務查詢 
完成：2013/9/14
240614資訊部門內部專用申請書:240611006875自提優化：放款相關帳務查詢畫面移除線上出帳按鈕 BY余凱鈞

[20241030]修改件 CHROME瀏覽器難字調整
 -->

<html>
<head>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script> 		<%-- 日曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>

<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC20900().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC20900(){
	
	var grid;
	var valid;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_0900/" + actionName,
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
			}
		);
	}	
	function initValidation(){		
			//查詢用檢核
			valid = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid.define('required' , [{ id : "ACNT_DATE" , errMsg:"結帳日期有誤請再次確認！"}] );
			valid.define('validate-ROCDate' , [{ id : "ACNT_DATE" , errMsg:"結帳日期有誤請再次確認！"}] );
			valid.define('required' , [{ id : "ACNT_GROUP" , errMsg:"結帳組別有誤請再次確認！"}] );
			
	}
	
	var buttons = {		
		//查詢		
		doQuery : function(){
			if(!valid.validate()){					
				return;			
			}
			//發送ajax
			ajaxPost( 'query', {ACNT_DATE: toY2K($F('ACNT_DATE')), ACNT_GROUP: $F('ACNT_GROUP')},
				function(resp){	
					buttons.displayData(resp);
					$('IS_BALANCE').value = resp.IS_BALANCE;
				},function(resp){
					grid.load();
					$('IS_BALANCE').value = 'N';
				}
			);							
		},
		displayData : function(resp){
			var rtnList = resp.rtnList || [];
			var TOTobj = [{ text: '合計' , value:resp.totalMap || {}}];
			$('EMP_NAME').update(resp.EMP_NAME);
			grid.load(rtnList, TOTobj);
		}
	}
	
	
	return{
		initApp:function(){	
		PageUI.createPageWithAllBodySubElement( "DSC20900" , "收息帳務", "總帳帳務查詢" );
			initValidation();
			grid =  new TableUI({
				table: $("grid"), allSortable:false, pageSize: 20,overDiv:false, split:['SEQ_NO'],
				column:[					
					{header:"項目", key:'ACNT_NAME', attrs:{align:'left'}, 
						render : function(rec , val){			
								var link = new Element('a', { 'href' : '#'}).update(val);
								link.observe('click', function(){
										var LP_JSON;
										var url;
										var QUERY_TYPE;
										var DB_CR;
										
										if("票據" == val){
											url = 'DSC2_0901';
											QUERY_TYPE = '1';
											DB_CR = 'DR';
											
										}else if("其他應收款" == val){
											url = 'DSC2_0902';
											QUERY_TYPE = '4';
											DB_CR = 'DR';
										}else if("人工應收款" == val){
											url = 'DSC2_0902';
											QUERY_TYPE = '6';
											DB_CR = 'DR';
										}else if("ATM手續費" == val){
											url = 'DSC2_0902';
											QUERY_TYPE = '80';
											DB_CR = 'DR';
										}else if("其他暫收" == val){
											url = 'DSC2_0902';
											QUERY_TYPE = '15';
											DB_CR = 'CR';
										}else if("人工暫收" == val){
											url = 'DSC2_0902';
											QUERY_TYPE = '17';
											DB_CR = 'CR';
										}else if("沖其他暫收" == val){
											url = 'DSC2_0903';
											QUERY_TYPE = '3';
											DB_CR = 'DR';
										}else if("沖人工暫收款" == val){
											url = 'DSC2_0903';
											QUERY_TYPE = '5';
											DB_CR = 'DR';
										}else if("沖其他應收" == val){
											url = 'DSC2_0903';
											QUERY_TYPE = '16';
											DB_CR = 'CR';
										}else if("沖人工應收" == val){
											url = 'DSC2_0903';
											QUERY_TYPE = '18';
											DB_CR = 'CR';
										}else if("專款借支放款金額" == val){
											url = 'DSC2_0904';
											QUERY_TYPE = '135';
											DB_CR = 'DR';
										}else if("轉出電子謄本費用" == val){
											url = 'DSC2_0905';
											QUERY_TYPE = '121';
											DB_CR = 'DR';
										}else if("轉出信用查詢費用" == val){
											url = 'DSC2_0905';
											QUERY_TYPE = '123';
											DB_CR = 'DR';
										}else if("電子謄本費用" == val){
											url = 'DSC2_0906';
											QUERY_TYPE = '122';
											DB_CR = 'DR';
										}else if("信用查詢費" == val){
											url = 'DSC2_0906';
											QUERY_TYPE = '124';
											DB_CR = 'DR';
										}else if("預付稅款" == val){
											url = 'DSC2_0907';
											QUERY_TYPE = '2';
											DB_CR = 'DR';
										}else if("擔保貸款" == val){
											url = 'DSC2_0907';
											QUERY_TYPE = '7';
											DB_CR = 'CR';
										}else if("擔保貸款--無自用" == val){
											url = 'DSC2_0907';
											QUERY_TYPE = '10';
											DB_CR = 'CR';
										}else if("利息收入" == val){
											url = 'DSC2_0907';
											QUERY_TYPE = '13';
											DB_CR = 'CR';
										}else if("應收利息" == val){
											url = 'DSC2_0907';
											QUERY_TYPE = '14';
											DB_CR = 'CR';
										}else if("管理費用-法律事務費" == val || "管理費用" == val){
											url = 'DSC2_0907';
											QUERY_TYPE = '19';
											DB_CR = 'CR';
										}else if("現金" == val || "銀行存款" == val || "銀行存款-劃撥特戶" == val || "銀行存款-劃撥專戶" == val){
											url = 'DSC2_0908';
											QUERY_TYPE = '20';
											DB_CR = 'DR';
										}
										var LP_JSON = {
											action : '<%=dispatcher%>/'+url+'/prompt/?SINGLE="FALSE"',
											QUERY_TYPE : QUERY_TYPE,
											ACNT_GROUP  : $('ACNT_GROUP').value,
											ACNT_DATE  : toY2K($F('ACNT_DATE')),
											DB_CR : DB_CR						
										}
										CSRUtil.linkTo(LP_JSON, 'form');
									});						
								return link;
						}},
					{header:"借方件數", key:'DEBT_CNT', renderInCount:true,
						render : function (rec , val){	
							
							return '<div align="right">' + ((val || val===0) ? val : '') + '</div>';
							
						}
					},
					{header:"借方金額", key:'DEBT_AMT', renderInCount:true,
						render : function (rec , val){
							
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
							
						}
					},					
					{header:"貸方件數", key:'CREDIT_CNT',renderInCount:true,
						render : function (rec , val){					 
							
							return '<div align="right">' + ((val || val===0) ? val : '') + '</div>';
							
						}
					},
					{header:"貸方金額", key:'CREDIT_AMT', renderInCount:true,
						render : function (rec , val){					 
							
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
							
						}
					}				
					
				]
			});
			// 查詢
			$('btn_query').observe('click', buttons.doQuery);
			//接上一頁回來的欄位資訊
			var LP_JSON = CSRUtil.isBackLink('form');				
			if(LP_JSON){
				buttons.doQuery();						
			}
			displayMessage();
			PageUI.resize();
			
		}//end init()--
	};//end return--	
}//end DSC20900
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<input type="hidden" id="IS_BALANCE" value="N" />
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="20%">結帳日期</td>
				<td class="tbYellow2" width="20%">
					<input id="ACNT_DATE" name="ACNT_DATE" value="${ACNT_DATE}"datatype="ROCdate" type="text" class="textBox2" size="10" maxlength="9" fieldName = "清算日期"/>
					<img class="img" src="<%=imageBase%>/CM/calendar.gif" id="ACNT_DATE_M" alt="Date" onclick="getCalendarFor($('ACNT_DATE'))"/>
				</td>
				<td class="tbYellow" width="20%">結帳組別</td>
				<td class="tbYellow2" width="20%">
					<select id="ACNT_GROUP" name="ACNT_GROUP">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${ACNT_GROUP1_LIST}">
								<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select> 
				</td>
				<td class="tbYellow2" width="20%" align="center">
					<input id="btn_query" type="button" class="button" value="查詢"/>
				</td>
			</tr>
		</table>
		<table id="grid"></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="25%">結帳人員</td>
				<td class="tbYellow2" width="25%"><span id="EMP_NAME" style="font-family:'EUDC'"></span></td><%-- [20241030] 難字調整 --%>
				<td class="tbYellow2" width="25%"></td>
				<td class="tbYellow2" width="25%"></td>
			</tr>
		</table>
	</form>
</body>
</html>