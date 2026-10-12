<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA11300.jsp
功能：匯款明細查詢

[20201130]修改件  外網多筆個資遮蔽  @author 何宗霖
[20240730 修改件 難字調整
 -->
 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<%--[20240726]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/PageControllerObj.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<script language="javascript" type="text/javascript">

var valid1;
<%--[20201130]外網多筆個資遮蔽
var preTd;
var preBORROW_NAME_MASK, preDAY_TEL_MASK, preNIGHT_TEL_MASK;
--%>
var validateDate = function(){		
	if(diffDay($F('QUERY_STR_DATE'),$F('QUERY_END_DATE'), true) < 0)
		return false;
	return true;		
}

function initApp(){  
	// 顯示執行結果
	displayMessage();
	
	PageUI.createPageWithAllBodySubElement("DSA11300" , "受理作業" , "匯款明細查詢", 1);
	
	new UI().init();
	
	// 查詢
	$("btn_query").observe('click',function(event){
		buttons.doQuery();
	});
	
	
	
	valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
	
	Validation.addAllThese([
		[ 'validateDate',  '終止日期需大於起始日期，請檢查後重新輸入查詢條件', validateDate]				
	]);	 
	
	<c:if test="${not empty rtnList}">
		grid.load(${rtnList});
	</c:if>

	PageUI.resize(true);
	
	fix();
		
}
var grid = {};

//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
	
		init:function(){
		
			//產生 Grid 物件
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 20, allSortable: true,
					split: ['REMIT_DATE'],
					<%--[20240730] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						<%--[20201130]外網多筆個資遮蔽_增加切換按鈕
						{ header: "個資顯示", key: "",
							render:function(rec, val, sn){
								var button = new Element('button',{ 'type' : 'button' , 'class' : 'button' });
								button.update("點我");
								button.observe('click', function(){
									if(preTd){
										grid.setValueToTD(preTd, "BORROW_NAME_MASK", preBORROW_NAME_MASK);
										grid.setValueToTD(preTd, "DAY_TEL_MASK", preDAY_TEL_MASK);
										grid.setValueToTD(preTd, "NIGHT_TEL_MASK", preNIGHT_TEL_MASK);
									}
									preTd = this;
									preBORROW_NAME_MASK = rec['BORROW_NAME_MASK'];
									preDAY_TEL_MASK = rec['DAY_TEL_MASK'];
									preNIGHT_TEL_MASK = rec['NIGHT_TEL_MASK'];
									
									grid.setValueToTD(this, "BORROW_NAME_MASK", rec['BORROW_NAME']);
									grid.setValueToTD(this, "DAY_TEL_MASK", rec['DAY_TEL']);
									grid.setValueToTD(this, "NIGHT_TEL_MASK", rec['NIGHT_TEL']);
								});
	                			return button;
							},
							attrs:{rowSpan:2}
						},--%>
						{ header: "受理編號", key: "APPLY_ID"},
						{ header: "貸款帳號", key: "LOAN_ID"},
						<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
						<%--[20240730] 難字調整 --%>
						{ header: "借款人姓名/羅馬拼音", key: "BORROW_NAME", attrs:{style:"font-family:'EUDC'"}},
						{ header: "經手人姓名", key: "AGENT_NAME", attrs:{style:"font-family:'EUDC'"}},
						<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
						{ header: "連絡電話(日)", key: "DAY_TEL"},
						{ header: "連絡電話(夜)", key: "NIGHT_TEL"},
						{ header: "匯款金額(元)", key: "REMIT_AMT", attrs: {align:"right"} ,sortRule:'number', 
							render: function( record, value ){
		              			return CSRUtil.$fmt(value, "#,##0.##");
		            	}},
						
						{ header: "匯款日期", key: "REMIT_DATE", 
							render: function( record, value ){
		              			return value ? Date.toROC(value) : "";
		            		}
						
						},
						{ header: "利率(%)", key: "INTEREST"},
						{ header: "匯款種類", key: "REMIT_TYPE_NM"},
						{ header: "受理單位", key: "APPLY_DEPT_NM"},
						{ header: "代償單位", key: "COMP_DEPT_NM"},
						{ header: "代償行庫分行", key: "COMP_BANK"},
						<%--[20240730] 難字調整 --%>
						{ header: "前順位借款人", key: "PREVIOUS_BORROW", attrs:{style:"font-family:'EUDC'"}}						
						
					]
				}
			);
			
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){
		valid1.reset();
		
		columnToUpperCase('DEPT');
		
		if( !valid1.validate() ) {return;}
		
		var obj = {};
		obj.QUERY_STR_DATE = $F('QUERY_STR_DATE');
		obj.QUERY_END_DATE = $F('QUERY_END_DATE');
		obj.DEPT = $F('DEPT');
		
		preTd = null ;//再次查詢時清除preTd，避免顯示到上一次的暫存個資
		
		new Ajax.Request("<%=dispatcher%>/DSA1_1300/query", 
		{
			parameters:obj,
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){		
					grid.load(resp.rtnList);
				}else{										
					grid.load([]);						
				}
				fix();
			}
		});
	}
};

<%--
	轉大寫
--%>
function columnToUpperCase(columnName) {
	$(columnName).value = $(columnName).value.toUpperCase();
}

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0"
	marginheight="0" onLoad="initApp();" onResize="fix();"
	onScroll="fix();">
	
<form name="form1" id="form1" method="post" action="" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="15%" align="left">匯款日期</td>
		<td class="tbYellow2" width="30%">
			<input type="text" datatype="ROCDate" value="${QUERY_STR_DATE}" class="textBox2 required" size="10" maxlength="7" name="QUERY_STR_DATE" id="QUERY_STR_DATE" />
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('QUERY_STR_DATE'))">
			~
			<input type="text" datatype="ROCDate" value="${QUERY_END_DATE}" class="textBox2 required validateDate" size="10" maxlength="7" name="QUERY_END_DATE" id="QUERY_END_DATE" />
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('QUERY_END_DATE'))">
		</td>
		<td class="tbYellow" width="15%" align="left">受理單位</td>
		<td class="tbYellow2" width="30%">
			<input type="text" value="${DEPT}" class="textBox required" id="DEPT" name="DEPT" size="7" maxlength="5">
			<font color='red'>可輸入兩碼區部代號查詢</font>
		</td>
		<td class="tbYellow2" align="left"><input type="button" name="btn_query" id="btn_query" class="button" value="查詢" /></td>
	</tr>
</table>

<table id='grid' class="grid" style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px; display: none'></table>						
						
<br/>
<div>
	<font color='red' size='5'><b>注意：利率僅供參考，實際貸放利率以第一次繳息通知為準。</b></font>
</div>

</form>

<div id='dtlDiv'
	style="position: absolute; top: 0px; left: -2px; visibility: hidden"
	align='center'><iframe src='' name='dtlFrame' width='99%'
	height='500' id='dtlFrame'></iframe></div>

</body>
</html>