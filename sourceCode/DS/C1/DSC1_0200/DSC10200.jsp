<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->

<%--
<%@ page import="com.cathay.common.util.trx.RespCtxUtil"%>
<%@ page import="com.cathay.ds.c1.bo.DSC1_0201_bo"%>

	HttpResponseContext resp = new HttpResponseContext(request); // 取 addOutputData
	HttpTxContext txCxt = new HttpTxContext(session);            // 取 putValue
	RespCtxUtil ctxUtil = new RespCtxUtil(resp);
		
	Map viewData = resp.getOutputData("viewData") == null ? Collections.EMPTY_MAP : (Map)resp.getOutputData("viewData");
//	DSC1_0201_bo vo = (DSC1_0201_bo)viewData.get("DSC1_0201_bo"); 
	pageContext.setAttribute("viewData", viewData);
//	pageContext.setAttribute("vo", vo);
	
	List returnList = (List) resp.getOutputData("returnList");
	pageContext.setAttribute("returnList", (returnList==null) ? new ArrayList(): returnList);
	
--%>
<%--
[20241030]修改件 CHROME瀏覽器難字調整
--%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html> 
<head>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<link href="<%=htmlBase%>/CM/js/ext/resources/css/ext-all.css" rel="stylesheet" type="text/css" />
<title></title>
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
<script type='text/javaScript' src="<%=htmlBase%>/CM/js/prototype.js"></script>
<script type='text/javaScript' src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script> 
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javaScript' src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type='text/javaScript' src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javaScript' src="<%=htmlBase%>/CM/js/date.js"></script>
<script type='text/javaScript' src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type='text/javaScript' src="<%=htmlBase%>/CM/js/HotKey.js"></script>


<script type="text/javascript">
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function initApp(){

	PageUI.createPageWithAllBodySubElement('DSC10200','收息帳務作業','EIR繳息記錄作業');

   // 游標定位
	document.form1.LOAN_ID.focus();
	
	new UI().init();
	PageUI.resize();
	// 顯示執行結果
	displayMessage();
}

//UI function 定義
function UI() {
	
	var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC1_0200/');	
	
	//-------------------------------------------------------------------	
	//送出form
	function doQuery(queryObj) {
		//if(queryObj){
		//	if(queryObj.LOAN_ID){
		//		$('LOAN_ID').value=queryObj.LOAN_ID;
		//	}
		//	if(queryObj.LATEST_PAY_TERM){
		//		$('LATEST_PAY_TERM').value=queryObj.LATEST_PAY_TERM;
		//	}
		//}
	
		//var frm = document.form1;
		validator = new Validator();
	    validator.define("LOAN_ID","貸款帳號","請輸入必要資料","string",10,10);
	    validator.define("LATEST_PAY_TERM","最新期數","需為數值","num", 1, 999);
	    
	    if(!validator.validate()){
	        return false;
	    }
	    
		new Ajax.Request(
			'<%=dispatcher%>/DSC1_0200/query',
			{	method:'post',
				parameters: {'LOAN_ID': $F('LOAN_ID'), 'LATEST_PAY_TERM': $F('LATEST_PAY_TERM')},
				onSuccess: function( transport ) {
					var json = transport.responseText.evalJSON();				
					if(CSRUtil.isSuccess(json)){
						var vo = json.viewData;
						$('BORROW_ID').innerHTML=!vo.BORROW_ID?"":vo.BORROW_ID;
						$('BORROW_NAME').innerHTML=!vo.BORROW_NAME?"":vo.BORROW_NAME;
						$('REFER_ID').innerHTML=!vo.REFER_ID?"":vo.REFER_ID;
						$('MAX_PAY_TERM').setValue(vo.MAX_PAY_TERM || 0);
						grid.load(json.returnList);
					}else{
						$('BORROW_ID').innerHTML="";
						$('BORROW_NAME').innerHTML="";
						$('REFER_ID').innerHTML="";
						$('MAX_PAY_TERM').setValue(0);
						grid.load([]);
					}
	
	            }
			}
		);
	}

	//-------------------------------------------------------------------	
	
	return {
			
		init: function(){ 
		
			grid = new TableUI({
				table: $('grid'), allSortable: true, overDiv:{divHeight:500, tableWidth:4000},
				split: ['PRE_CNT'],
				column: [
					{header:'期數', key:'PAY_TERM', attrs:{ align: "center"},
						render: function(record, val){
							var url = "<%=dispatcher%>/DSC1_0200/detail?LOAN_ID="+record.LOAN_ID+"&PAY_TERM="+record.PAY_TERM+"&PAY_KIND="+record.PAY_KIND+"&SEQ_NO="+record.SEQ_NO+"&OPTIONS=CURRENT"+"&LATEST_PAY_TERM=" + $F('LATEST_PAY_TERM') + "&MAX_PAY_TERM=" + $F('MAX_PAY_TERM');
							popupWin.callbackHandler=doQuery;
							return popupWin.createFullPopupLink( val, url );
						}
					},
					{header:'繳款別', key:'PAY_KIND_NM', attrs:{ align: "center"},
						render : function(rec ,val ){
							if(rec.LOAN_STATUS=='33'){
								return "<span style = 'font-weight:bold'>" +"協商還款"+"</span>";
							}else{
							return rec.PAY_KIND_NM;
							}
						}
					},
					{header:'序號', key:'SEQ_NO', attrs:{ align: "right"},
						render: function(record, val){
							return val;
						}
					},
					{header:'繳款前本金餘額', key:'LAST_PRINCIPAL', attrs:{ align: "right"},
						render: function(record, val){
							return CSRUtil.$fmt(val, '#,##0');
						}
					},
					{header:'應繳日期', key:'DUTY_PAYDT', attrs:{ align: "center"},
						render: function(record, val){
							return Date.toROC(val);
						}
					},
					{header:'實繳日期', key:'REAL_PAYDT', attrs:{ align: "center"},
						render: function(record, val){
							return Date.toROC(val);
						}
					},
					{header:'適用年利率', key:'RATE', attrs:{ align: "right"},
						render: function(record, val){
							return CSRUtil.$fmt(val, '#,##0');
						}
					},
					{header:'本金', key:'PRINCIPAL', attrs:{ align: "right"},
						render: function(record, val){
							return CSRUtil.$fmt(val, '#,##0');
						}
					},
					{header:'利息', key:'INTEREST', attrs:{ align: "right"},
						render: function(record, val){
							return CSRUtil.$fmt(val, '#,##0');
						}
					},
					{header:'延滯息', key:'DELAY_INT', attrs:{ align: "right"},
						render: function(record, val){
							return CSRUtil.$fmt(val, '#,##0');
						}
					},
					{header:'違約金', key:'RENEGE', attrs:{ align: "right"},
						render: function(record, val){
							return CSRUtil.$fmt(val, '#,##0');
						}
					},
					{header:'管理費', key:'LAWSUIT_FEE', attrs:{ align: "right"},
						render: function(record, val){
							return CSRUtil.$fmt(val, '#,##0');
						}
					},
					{header:'票據表示', key:'CHECK_STATUS_NM', attrs:{ align: "center"}},
					{header:'繳款方式', key:'PAY_TYPE_NM', attrs:{ align: "center"}}
				]
			
			});// end of nuew TableUI
			
			//---------------------------------------------------------------
			//查詢按鈕
			$('btn_query').observe('click', doQuery);
			
			if($('LOAN_ID').value!=""){
				doQuery();
			}
			
		}// end of init function
	
	}// end of return
	
}//	end UI() Function
//--------------------------------------------------------------------------  

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="initApp();">
<%--
<span id="bar1"
	style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible;">
<table width="100%" height="30" border="0" cellpadding="0"
	cellspacing="0">
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
				<td>收息帳務作業</td>
				<td align="right">畫面編號：DSC10200</td>
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
--%>
<%--
<table width="100%" height="30" border="0" cellpadding="0"
	cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>

<table width="100%" height="100%" border="0" cellpadding="0"
	cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
			<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
		
		<table width="97%" border="0" align="center" cellpadding="0"
			cellspacing="1" bgcolor="#003366">
			<tr><!-- InstanceBeginEditable name="title2" -->
				<td class="tbBox2">
					<p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16" />EIR繳息記錄作業</p>
				</td>
			</tr>
			<tr bgcolor="#FFFFFF">
				<td><!-- InstanceBeginEditable name="content" --> 
				--%>
				<table width="100%" border="0" cellspacing="0" cellpadding="5">
					<tr>
						<td>
						<form name="form1" id="form1" method="post" action="">
						
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
							<tr>
								<td class="tbYellow" width="15%" align="left">貸款帳號</td>
								<td class="tbYellow2" width="15%">
									<input type="text" name="LOAN_ID" id="LOAN_ID" class='textBox2' size='13' maxLength='10' value="<c:out value="${viewData.LOAN_ID}"/>"/>
								</td>
								<td class="tbYellow" width="15%" align="left">期數</td>
								<td class="tbYellow2" width="15%">
									<input type="text" name="LATEST_PAY_TERM" id="LATEST_PAY_TERM" class='textBox2' size='4' maxLength='3' value="<c:out value="${viewData.LATEST_PAY_TERM}"/>"/>&nbsp;期
								</td>
								<td class="tbYellow2" width="40%" align="left">
									<input type="hidden" name="MAX_PAY_TERM" id="MAX_PAY_TERM" value="0" />
									<input type="button" name="btn_query" class="button" id="btn_query" value="查詢" />
								</td>
							</tr>
						</table>
						
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
							<tr>
                            	<td class="tbYellow" width="15%" align="left">身分證字號</td> 
                                <td class="tbYellow2" width="15%" align="left" id="BORROW_ID"></td>
                                <td class="tbYellow" width="15%" align="left">姓名</td>
                                <td class="tbYellow2" width="15%" align="left"><span id="BORROW_NAME" style="font-family:'EUDC'"></span></td><%-- [20241030] 難字調整 --%>
                                <td class="tbYellow" width="15%" align="left">原貸帳號</td>
                                <td class="tbYellow2" width="25%" align="left" id="REFER_ID"></td>                   
                            </tr>  
						</table>
						

						
						<%-- 
						<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
							<tr>
                            	<td class="tbBlue" align="center" >期數</td>
                                <td class="tbBlue" align="center" >繳款別</td>
                                <td class="tbBlue" align="center" >序號</td>
                                <td class="tbBlue" align="center" >繳款前本金餘額</td> 
                                <td class="tbBlue" align="center" >應繳日期</td>
                                <td class="tbBlue" align="center" >實繳日期</td>
                                <td class="tbBlue" align="center" >適用年利率</td>
                                <td class="tbBlue" align="center" >本金</td>
                                <td class="tbBlue" align="center" >利息</td>
                                <td class="tbBlue" align="center" >延滯息</td>
                                <td class="tbBlue" align="center" >違約金</td>
                                <td class="tbBlue" align="center" >管理費</td>
                                <td class="tbBlue" align="center" >票據表示</td>
                                <td class="tbBlue" align="center" >繳款方式</td>
                            </tr>  
                            <c:forEach var="resultVo" items="${returnList}" varStatus="status">
                            	<cathay:even><tr id='ROWID' class='tbYellow2'></cathay:even> 
								<cathay:odd><tr id='ROWID' class='tbBlue3'></cathay:odd>
									<td align="center" id="PAY_TERM"><a href="#" onClick="doLink('<c:out value="${resultVo.LOAN_ID}"/>','<c:out value="${resultVo.PAY_TERM}" />','<c:out value="${resultVo.PAY_KIND}" />','<c:out value="${resultVo.SEQ_NO}" />','<c:out value="${resultVo.TMP_TABLE}" />','<c:out value="${resultVo.BORROW_ID}" />','<c:out value="${viewData.BORROW_NAME}" />');"><c:out value="${resultVo.PAY_TERM}"/></a></td>
									<td align="center" id="PAY_KIND"><cathay:conver sys="DSC" field="PAY_KIND" value="${resultVo.PAY_KIND}"/></td> 
									<td align="right" id="SEQ_NO"><c:out value="${resultVo.SEQ_NO}"/></td>
									<td align="right" id="LAST_PRINCIPAL"><cathay:formatNumber type="number" pattern=",##0" value="${resultVo.LAST_PRINCIPAL}" /></td>
									<td align="center" id="DUTY_PAYDT"><cathay:calendar type="ROC" value="${resultVo.DUTY_PAYDT}"  /></td>
									<td align="center" id="REAL_PAYDT"><cathay:calendar type="ROC" value="${resultVo.REAL_PAYDT}"  /></td>
									<td align="right" id="RATE"><c:out value="${resultVo.RATE}"/></td>
									<td align="right" id="PRINCIPAL"><cathay:formatNumber type="number" pattern=",##0" value="${resultVo.PRINCIPAL}" /></td>
									<td align="right" id="INTEREST"><cathay:formatNumber type="number" pattern=",##0" value="${resultVo.INTEREST}" /></td>
									<td align="right" id="DELAY_INT"><c:out value="${resultVo.DELAY_INT}"/></td>
									<td align="right" id="RENEGE"><c:out value="${resultVo.RENEGE}"/></td>
									<td align="right" id="LAWSUIT_FEE"><c:out value="${resultVo.LAWSUIT_FEE}"/></td>
									<td align="center" id="CHECK_STATUS"><cathay:conver sys="DSC" field="CHECK_STATUS" value="${resultVo.CHECK_STATUS}"/></td>
									<td align="center" id="PAY_TYPE"><cathay:conver sys="DSC" field="PAY_TYPE" value="${resultVo.PAY_TYPE}"/></td>
								</tr>
                            </c:forEach>
						</table>
						<br/>
						--%>
						</form>
						
						<!-- Query Result (Grid Table) -->
						<table border=0 width="100%" cellpadding="0" cellspacing="1" class="tbBox2" id="grid">
						</table>
						
						</td>
					</tr>
				</table>
						<%--
				<!-- InstanceEndEditable --></td>
			</tr>
		</table>

		<!-- InstanceEndEditable --></td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img
			src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img
			src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table> --%>

<div id='dtlDiv'
	style="position: absolute; top: 0px; left: -2px; visibility: hidden"
	align='center'><iframe src='' name='dtlFrame' width='99%'
	height='500' id='dtlFrame'></iframe></div>
</body>
</html>
