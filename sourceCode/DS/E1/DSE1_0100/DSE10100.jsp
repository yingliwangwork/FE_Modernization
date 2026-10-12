<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ taglib uri="/WEB-INF/tlds/cathay.tld" prefix="cathay" %>

<%--<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>--%>

<!--
程式：DSE10100.jsp
作者：i9300619
功能：法院陳報資料選取

[20240207]
難字調整
高強禾
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>法院陳報債權試算</title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
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
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe( window, 'resize', fix);
Event.observe( window, 'scroll', fix);

function initApp(){
	//buttonAuth(); //TODO ACTION_TYPE == null 時 單純依照按鈕授權處理
	displayMessage();
	buttonEnable();
	new UI().init();
	autoFormatToDate(); //把input datatype="date" 輸入值輔助輸入yyyy-mm-dd
}

/*

//按鈕授權處理
function buttonAuth(){
	var authButtons = {
			B0001:'btn_calculate' //TODO 試算 按鈕編號
	};
	<dz:grantButtons FUNC_ID="DSE10100" />
}
*/

function buttonEnable() {
	
	var ACTION_TYPE = $('ACTION_TYPE').value;
	var LINK_FROM = $('LINK_FROM').value;
	var LINK_TYPE = $('LINK_TYPE').value;

	if(ACTION_TYPE == 'U'){
	
		$('btn_query').disabled = false;
		$('btn_clear').disabled = false;
		$('btn_confirm').disabled = false;
	}
	else if(ACTION_TYPE == 'Q'){
	
		$('btn_query').disabled = false;
		$('btn_clear').disabled = false;
		$('btn_confirm').disabled = true;
		
	}else if(ACTION_TYPE == null){
	
		//TODO 
	}
	
}


<!-- Define UI Class Start-------------------------------------------------------
function UI(){
	var theRtnList;
	//--------------------------------------------------------------------------  
	//UI() private variable
	//-------------------------------------------------------------------------- 
	var grid;
	var gridPrint;
	var validator = new Validator();
	//--------------------------------------------------------------------------  
	//UI() private method
	//--------------------------------------------------------------------------  
    //***

	var doAction = {
	
		query:function(){
			//結算日輸入檢核
			validator.clear();
			
			if( !checkAtleastOneInput() ) {
				alert('原貸帳號、身分證字號、姓名至少需輸入一個欄位');	
				return;
			}

			//原貸帳號 & 身分證字號 轉大寫
			var REFER_IDObj = $('REFER_ID');
			if (REFER_IDObj.value) {
				REFER_IDObj.value = REFER_IDObj.value.toUpperCase();
			}
			var BORROW_IDObj = $('BORROW_ID');
			if (BORROW_IDObj.value) {
				BORROW_IDObj.value = BORROW_IDObj.value.toUpperCase();
			}
			
			var info = {
				REFER_ID : $F('REFER_ID'),
				BORROW_ID : $F('BORROW_ID'),
				BORROW_NAME : $F('BORROW_NAME')
			};
			
			ajaxPost('query', { info:Object.toJSON(info) }, successAction );
		}

		,clear:function(){
			$("form").reset();
		}
		
		,confirm:function(){
			
			
			//結算日輸入檢核
			validator.clear();
			validator.define('SALE_DATE', '結算日', '不能為空值或格式錯誤', 'DATE_INPUT');
			
			validator.define('COURT','法院','請選擇法院', 'select');
			validator.define('CASE_NO','案號','請輸入案號', 'string');
			validator.define('BRANCH','股別','請輸入股別', 'string');
			if (!validator.validate()) {
				return false;
			}
			
  			var selectedBox = grid.getCheckedRecord();
			if(selectedBox.length == 0 ){
				alert('請至少勾選一筆資料');
				return false;
			}
			var LP_JSON = {
				action:'<%=dispatcher%>/DSE1_0101/prompt',
				ACTION_TYPE:'U', //作業種類
				LINK_TYPE:'IN', //連結種類
				LINK_FROM:'DSE10100', //來源頁面
				SALE_DATE:$F('SALE_DATE'), //結算日
				chkList:Object.toJSON(selectedBox),
				COURT_NM: $('COURT').options[$('COURT').selectedIndex ].text,  //法院名稱
				CASE_NO:$F('CASE_NO'),      //案號
				BRANCH:$F('BRANCH'),        //股別
				COURT:$F('COURT')           //法院
			};

			// form 的 input 欄位，會被封裝成 LP_JSON.BQ_ARG
			CSRUtil.linkTo(LP_JSON, 'form');
		}		
		
	};
	
	// 檢核輸入
	function checkAtleastOneInput() {
	
		if(!validateNull($F('REFER_ID')) && !validateNull($F('BORROW_ID')) && !validateNull($F('BORROW_NAME'))) {		
			return false;
		} else {
			return true;
		}
		
	}

	//去除頭尾空白值，檢查是否為空
	function validateNull( params ) {
		var temp = params.trim();
		
		if(!validateString(temp)) {
			return false;
		}else{
			return true;
		}
	}
	
	function ajaxPost( actionName, params, successAction ) {
		new Ajax.Request( '<%=dispatcher%>/DSE1_0100/' + actionName,
	    	{
		    	parameters: params,
		    	onSuccess: successAction
	    	}
	    );
	}
		
	
	function successAction(XHT, resp) {
		if(CSRUtil.isSuccess(resp)) {
			
			theRtnList = resp.rtnList;
			grid.load( theRtnList ? theRtnList : [] );
			gridPrint.load( resp.printList||[] );
		} 
	}
	
	//--------------------------------------------------------------------------			
	//以下為UI() public method,放在 return 中
	//--------------------------------------------------------------------------  
	return{
	
		//init Function for 初始整個UI Class
		init:function(){
			<cathay:LocaleDisplay sysCode="DS"  var="localeDisplay"/>
			
			//產生 grid1 物件
			grid = new TableUI( {
				table: $('grid'),
				pageSize: 10,
				autoCheckBox:{ isSelectAll:true ,genRule:function(record , value){ 
                                      return record.LOAN_STATUS < 10 ? true : false;
                                   }},
                <%-- [20240207] 難字調整 --%>
                afterLoad: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
                pageChange: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
				column:[
					{ key: 'STATUS_NAME', header: '契約效力'},
					{ key: 'LOAN_ID', header: '貸款帳號',
						render:function(rec, val){
							if(rec.LOAN_STATUS>=10){
								var link = new Element('a', { 'href' : '#' ,'title' : '連結至拍賣不足債權試算'}).update(val);
								link.observe('click', function(){
									CSRUtil.linkTo({
										action : "<%=dispatcher%>/DSE1_1800/prompt",
										LOAN_ID : rec.LOAN_ID
									} , 'form');
								});
								return link;
							}
							return val;
					}},
					{ key: 'REFER_ID', header: '原貸帳號',
						render:function(rec, val){
							var link = new Element('a', { 'href' : '#' ,'title' : '連結至陳報債權作業'}).update(val);
							link.observe('click', function(){
								CSRUtil.linkTo({
									action : "<%=dispatcher%>/DSE1_0500/prompt",
									REFER_ID : rec.REFER_ID
								} , 'form');
							});
							return link;
					}},
					<%-- [20240207] 難字調整：借款人、擔保品地址 --%>
					{ key: 'BORROW_NAME', header: '借款人', attrs:{ style:"font-family:'EUDC'" }},
					{ key: 'GAGE_ADDR', header: '擔保品地址', attrs:{ style:"font-family:'EUDC'" }}
				]
        	} );
			
			gridPrint = new TableUI( {
				table: $('gridPrint'),
				pageSize: 10,
                <%-- [20240207] 難字調整 --%>
                afterLoad: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
                pageChange: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
				column:[
					{ key: 'FILE_NM', header: '檔案名稱',
						render: function(record , value){
							var link = document.createElement('a') ;
							link.href = '#' ;
							link.onclick = function(){
								RPTUtil.downloadFile( '${dispatcher}/DSE1_0100/download', {'FILE_ID':record.FILE_ID});	
							} ;
							link.innerHTML = value ;

							return link ;
						}
					}
					,{ key: 'INSERT_DATE', header: '列印日期', sortRule:'datetime'}
					<%-- [20240207] 難字調整：借款人、擔保品地址 --%>
					,{ key: 'INSERT_NAME', header: '列印人員', attrs:{ style:"font-family:'EUDC'" }}
				]
        	} );

			//-------------------------------------------------------------------------- 
			$('btn_query').observe('click',function(event){ 
				doAction.query(); 
			});
			$('btn_clear').observe('click',function(event){ 
				doAction.clear(); 
			});
			$('btn_confirm').observe('click',function(event){ 
				doAction.confirm(); 
			});
			
			//若是回上頁所發送回來的，還原 form 的輸入欄值後，執行重新查詢
			var LP_JSON = CSRUtil.isBackLink('form');
			if(LP_JSON){
				doAction.query();
			}
			
		}//end init()--
		
	}//end return--
	//-------------------------------------------------------------------------- 
}
<!--Define UI Class End-------------------------------------------------------->

-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<center>
<!-- Bolck_1_Start 表單的開頭 功能名稱 畫面編號-->
<span id="bar1" style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible">
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
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
				<td><b>法務件</b></td>
				<td>
				<div align="right">畫面編號：DSE10100</div>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</span> <!-- Bolck_1_ End--> <!-- Bolck_2_Start 空白區塊 版面跳行-->
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>

			<input id="ACTION_TYPE" type="hidden" value="<c:out value="${ACTION_TYPE}"/>"  />
			<input id="LINK_FROM" type="hidden" value="<c:out value="${LINK_FROM}"/>" />
			<input id="LINK_TYPE" type="hidden" value="<c:out value="${LINK_TYPE}"/>" />

<!-- Bolck_2_End--> <!-- Bolck_3_Start 表單主功能區塊-->
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="top">
						<table width=97% border=0 align=center cellpadding="5" cellspacing="1" bgcolor="#003366">
							<tbody>
								<tr>
									<td class="tbBox2"><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">法院陳報債權試算</td>
								</tr>
								<!-- Bolck_4_Start 輸入區塊-->
								<tr bgcolor=#FFFFFF>
									<td>
										<form name="form" id="form" method="post">
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
												<tr>
													<td class="tbYellow" colspan="6">法院陳報債權試算</td>
												</tr>
												<tr>
												    <td width='10%' class="tbYellow2">原貸帳號</td>
												    <td width='20%' class="tbYellow2" colspan="3">
												    	<input id="REFER_ID" name="REFER_ID" type="text" class="textBox2" size="12" maxlength="10" value="${REFER_ID}" />
												    </td>
												    <td width='20%' class="tbYellow2" rowspan="2" align="center" >
														<input type="button" name="btn_query" id="btn_query" value="查詢" class="button">
														<input type="button" name="btn_clear" id="btn_clear" value="清除" class="button">
												    </td>
												</tr>
												<tr>  
													<td width='10%' class="tbYellow2">身分證字號</td>
													<td width='20%' class="tbYellow2" >
													   	<input id="BORROW_ID" name="BORROW_ID" type="text" class="textBox2" size="12" maxlength="10"  />
													</td>
													<td width='10%' class="tbYellow2">姓名</td>
													<td width='20%' class="tbYellow2">
													    <%-- [20240207] 難字調整：姓名 --%>
													    <input id="BORROW_NAME" name="BORROW_NAME" type="text" class="textBox2" size="12" maxlength="10" alt="ch" />
													</td>
												</tr>
											</table>
											<!-- Query Result (Grid Table) -->
											<table id="grid" class="grid"></table>
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table2">
												<tr>
													<td>
														結算日&nbsp;&nbsp;
														<input id="SALE_DATE" id="SALE_DATE" type="text" datatype="date" size="10" maxlength="10">
														<img id="SALE_DATE_IMG" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor(SALE_DATE)">
														&nbsp;&nbsp;
														法院
														<select id="COURT" id="COURT">
															<option value="">請選擇</option>
															<c:forEach items="${COURT_Map}" var="map">
																<option value="<c:out value="${map.key}"/>"><c:out value="${map.value}" /></option>
															</c:forEach>
														</select>
														&nbsp;&nbsp;
														案號
														<input id="CASE_NO" type="text" class="textBox2" size="70" />
														&nbsp;&nbsp;
														股別
														<input id="BRANCH" type="text" class="textBox2" size="30" />
														<br>
														<input type="button" name="btn_confirm" id="btn_confirm" value="選取確認" class="button">
													</td>
												</tr>
											</table>
											<table id="gridPrint" class="grid"></table>
										</form>
									</td>
								</tr>
								<!--Bolck_4_End-->
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
<!-- Bolck_3_End-->
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
</center>
</body>
</html>