<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSD20100.jsp
作者：i9100107
功能：催收轉出查詢作業
完成：2011/08/26
更新：

[20240326]
難字調整
高強禾
-->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<%-- [20240326] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<%--自行定義的javaScript--%>
<script type="text/JavaScript">
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>

Event.observe(window, 'load', initApp);


function initApp(){            
	//buttonAuth();
	//TableUI的產生        
	new UI().init();                
   
}

function buttonAuth(){
	var authButtons = {
		//B0001:'btn_query'<%--查詢--%>
	};
	<dz:grantButtons FUNC_ID="DSD20100" ignored="false"/>
}

 
//--------------------------------------------------------------------------  
<%--全域 函數 UI 與 畫面 公用 End----------------------------------------------------%>


<%--Define UI Class Start-------------------------------------------------------%>
function UI(){                
	//--------------------------------------------------------------------------          
	//UI() private variable        
	//--------------------------------------------------------------------------         
	var grid = {};        
	var validator;        
	
	//--------------------------------------------------------------------------          
	//UI() private method        
	//--------------------------------------------------------------------------          
	//***        
	
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ){	
		
		new Ajax.Request( "<%=dispatcher%>/DSD2_0100/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	    	onSuccess: successAction
		});
	}      
	
	//AJAX SuccessAction
	function successAction(XHT, resp) {
		if(CSRUtil.isSuccess(resp)){
			//訊息確認後，返回LINK_FROM頁面並依原查詢條件重新查詢並顯示資料。
			CSRUtil.linkBack();							
		}
	}
	
	//AJAX SuccessAction For Query
	function successActionForQuery(XHT, resp) {
		if(CSRUtil.isSuccess(resp)){
			grid.load(resp.rtnList || []);
		} else{
			grid.load([]);
		}
	}	
	
	//AJAX SuccessAction For Other Action
	function successActionForOthers(XHT, resp) {
		if(CSRUtil.isSuccess(resp)){
			grid.load(resp.rtnList || []);
		} 
	}	
		
		
	//查詢Function       
	var doQuery = function(){  
			if(!checkInput()){
				return;
			}
			ajaxPost('query', 
					$("form1").serialize( true ) 
					, 
					function successActionForQuery(XHT, resp) {
						if(CSRUtil.isSuccess(resp)){
							grid.load(resp.outputDataMap || []);
						} else{
							grid.load([]);
						}
					}	
			);
		
	                  
	};
	var doClear = function(){  
		$("form1").reset();
	}
	
	//檢核貸款帳號不得為空
	var checkInput = function(){
		$$('#form1 input[type="text"]').each( function(text){ text.style.backgroundColor = ''; } );	// reset input color
		validator = new Validator();
		validator.define("LOAN_ID", "", "貸款帳號不可為空", "string");
		return validator.validate();
	}
	//--------------------------------------------------------------------------        
	//以下為UI() public method,放在 return 中        
	//--------------------------------------------------------------------------          
	return{                              
		//init Function for 初始整個UI Class                
		init:function(){                                        
				
			                                                                 
				
			//產生 Grid 物件                
			grid = new TableUI(                         
				{                   				
					table: $('grid'),   //對應的table實體                   
					pageSize:10,        
					allSortable:true,
					<%-- [20240326] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[           
						{header: '轉出/轉入',key: 'BAD_ACCOUNT_NM'},
						{header: '轉出日期',key: 'OUT_DATE',
							render: function( record, value ){
								return Date.toROC(value);
							}},
						{header: '轉出時間',key: 'INPUT_TIME', 
							render: function(record,value){
                                  return value.substring(11,19) ;
                            }}, 
						{header: '轉入日期',key: 'INTO_DATE',
							render: function( record, value ){
								return Date.toROC(value);
							}},
						{header: '借款人ID',key: 'BORROW_ID',
							render: function( record, value ){
								return CSRUtil.maskHandler.getMaskID(value);
							}},
						<%-- [20240326] 難字調整 --%>
						{header: '借款人姓名',key: 'BORROW_NAME',attrs:{ style:"font-family:'EUDC'" },
							render: function( record, value ){
								return CSRUtil.maskHandler.getMaskName(value);
							}},
						{header: '收息單位',key: 'DEPT_ID'},
						{header: '收費代號',key: 'RECEIVE_ID'},
						{header: '承辦科別',key: 'CRED_DEPT_NM'},
						{header: '貸款種類',key: 'LOAN_KIND_NM'},
						{header: '本金',key: 'PRINCIPAL', attrs: {align:"right"} ,sortRule:'number',
							render:function(rec,val){ 
								return CSRUtil.$fmt( val||0, "#,###");
								}},
						{header: '利息',key: 'INTEREST', attrs: {align:"right"} ,sortRule:'number',
							render:function(rec,val){ 
								return CSRUtil.$fmt( val||0, "#,###");
								}},
						{header: '上期結餘',key: 'LAST_BALANCE', attrs: {align:"right"} ,sortRule:'number',
							render:function(rec,val){ 
								return CSRUtil.$fmt( val||0, "#,###");
								}},
						{header: '應收利息',key: 'RECEIVE_INT', attrs: {align:"right"} ,sortRule:'number',
							render:function(rec,val){ 
								return CSRUtil.$fmt( val||0, "#,###");
								}},
						{header: '計息起日',key: 'INT_BEGDT',
							render: function( record, value ){
								return Date.toROC(value);
							}},
						{header: '計息終日',key: 'INT_ENDDT',
							render: function( record, value ){
								return Date.toROC(value);
							}},
						{header: '下次應繳日',key: 'NEXT_PAYDATE',
							render: function( record, value ){
								return Date.toROC(value);
							}},
						{header: '已繳期數',key: 'PAY_TERM'},
						{header: '逾期期數',key: 'OVER_TERM'},
						{header: '催收款項',key: 'LOAN_AMT', attrs: {align:"right"} ,sortRule:'number',
							render:function(rec,val){ 
								return CSRUtil.$fmt( val||0, "#,###");
								}},
						{header: '催收款項餘額',key: 'REMAIN_AMT', attrs: {align:"right"} ,sortRule:'number',
							render:function(rec,val){ 
								return CSRUtil.$fmt( val||0, "#,###");
								}},
						{header: '提前沖轉金額',key: 'WASH_AMT', attrs: {align:"right"} ,sortRule:'number',
							render:function(rec,val){ 
								return CSRUtil.$fmt( val||0, "#,###");
								}},
						{header: '提沖件入案款前繳款金額',key: 'PAID_AMT', attrs: {align:"right"} ,sortRule:'number',
							render:function(rec,val){ 
								return CSRUtil.$fmt( val||0, "#,###");
								}},
						{header: '提前沖轉成數',key: 'WASH_RATE'},
						{header: '提沖日期',key: 'WASH_DATE',
							render: function( record, value ){
								return Date.toROC(value);
							}},
						{header: '下期利率',key: 'NEXT_RATE'},
						{header: '最近繳款利率',key: 'PAID_RATE'},
						{header: '溢折價累計金額',key: 'ADJ_BALANCE', attrs: {align:"right"} ,sortRule:'number',
							render:function(rec,val){ 
								return CSRUtil.$fmt( val||0, "#,###");
								}}
						
				
					],pageChange:function(pageNo){ 
						autoFormatToNumber();
						<%-- [20240326] 難字調整 --%>
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					}										
				}                 
			); 
			//查詢 button click event                        
			$('btn_query').observe('click',function(event){                                        
					doQuery();
				}                        
			); 
			//新增 button click event                        
			$('btn_clear').observe('click',function(event){
					doClear();			
				}                        
			);

			

		}//end init()--                        
	}//end return--        /
	//-------------------------------------------------------------------------- 
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >


<span id="bar1"	style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible;">
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img
			src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0"
			background="<%=imageBase%>/CM/border_03.gif">
			<tr>
				<td height="4"><img src="<%=imageBase%>/CM/border_03.gif"
					width="12" height="4"></td>
			</tr>
		</table>
		<!-- InstanceBeginEditable name="title" -->
		<table width="100%" border="0" cellpadding="2" cellspacing="0"
			class="subTitle">
			<tr>
				<td width="20" height="24">
				<div align="center"><font size="-5">●</font></div>
				</td>
				<td><b>轉催收</b><br>
				</td>
				<td align="right">畫面編號：DSD20100</td>
			</tr>
		</table>
		<!-- InstanceEndEditable --></td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img
			src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img
			src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</span>
<table width="100%" height="30" border="0" cellpadding="0"
	cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>
<table width="100%" height="100%" border="0" cellpadding="0"
	cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img
			src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td width="100%" valign="top" bgcolor="#F0FBC6"><!-- InstanceBeginEditable name="content" -->
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td valign="top">
				<table width=97% border=0 align=center cellpadding="0"
					cellspacing="1" bgcolor="#003366">
					<tbody>
						<tr>
							<td class="tbBox2">
							<p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18"
								height="16">催收轉出查詢作業</p>
							</td>
						</tr>
						<tr bgcolor=#FFFFFF>
							<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="5">
								<tr>
									<td>
									<form id="form1" name="form1" method="post">	
									<table width="100%" border="0" cellpadding="0" cellspacing="1"
										class="tbBox2">
										<tr>
											<td width='20%' align="center" class="tbYellow">貸款帳號</td>
											<td width='20%' class="tbYellow2">
											<input name="LOAN_ID" type="text" class="textBox2" size="12" maxlength="11" onKeyUp="this.value=this.value.toUpperCase();" value="<c:out value="${formMap.LOAN_ID}"/>" />
											</td>
											<td width='20%' align="center" class="tbYellow">轉出/轉入</td>
							   				<td width='20%' class="tbYellow2">
												<cathay:converSelect sys="DSD" field="BAD_ACCOUNT" name="BAD_ACCOUNT"  addOptionName="請選擇" addOptionValue=""/>
							    			</td>
											<td class="tbYellow2" width="50%">
												<center>
													<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
													<input id="btn_clear" name="btn_clear" type="button" class="button" value="清除">
												</center>
											</td>
										</tr>

									</table>
									
									<table id="grid" class="grid"></table>     
									</form>							

								
									</td>
								</tr>
								
							</table>
							</td>
						</tr>
					</tbody>
				</table>
				<div align="center">
				<p><br>
				</p>
				</div>
				</td>
			</tr>
		</table>
		<!-- InstanceEndEditable --></td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img
			src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img
			src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</body>
<!-- InstanceEnd -->
</html>