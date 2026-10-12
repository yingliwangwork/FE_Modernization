<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource"/>

<!--
[20201130]修改件  外網多筆個資遮蔽  @author 何宗霖
[20201225]問題單20201225093456 修改匯出報表問題以及表格位置問題 何宗霖
[2021-04-09] 配合申請書-放款相關核心畫面個資遮蔽， 移除「點我」後呈現該列明碼文字
 -->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script src="<%=htmlBase%>/CM/js/date.js"></script>
<script src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script src="<%=htmlBase%>/CM/js/utility.js"></script>
<script src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/PageControllerObj.js"></script>
</head>
<%--[20240722]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" ><!--

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var ppcIE = function(){
	if( navigator.appName == "Microsoft Internet Explorer" )
		return true;
	if(navigator.appName == 'Netscape')
		return new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})").exec(navigator.userAgent);
	return false;
};
var grid;
var grid1_pageObj = {};
var validator;

function initApp(){

	cleanMsgBoard();
	
	displayMessage();
	
	buttonAuth();
	
	validator = new Validator();

	PageUI.createPageWithAllBodySubElement("DSA11000" , "受理作業" , "單位受理查詢");

	new UI().init();

	// 查詢按鈕
	$("btn_query").observe('click', function(event){
			doQuery();
		}
	);
	
	// 清除按鈕
	$("btn_clear").observe('click', function(event){
			validator.clear();
			$('form1').reset();
		}
	);

	// 匯出excel按鈕
	$("btn_export").observe('click', function(event){
			doExportXls();
		}
	);
	
	// 日期欄處理
	autoFormatToDate();
	
	var LP_JSON = CSRUtil.isBackLink('form1');
	if(LP_JSON){
		var BQ_ARG = LP_JSON.BQ_ARG || {};
		doQuery();
	}
	else{
		<c:if test="${not empty LP_JSON}">
			$('LP_JSON').value = '<c:out value="${LP_JSON}" default="" escapeXml="false" />';
		</c:if>
		<c:if test="${IS_BACK == 'Y'}">
			var LP_JSON2 = ($('LP_JSON').value).evalJSON();
			var BQ_ARG = LP_JSON2.BQ_ARG || {};
			$('DIVNO').value = BQ_ARG.DIVNO;
			$('BEGIN_DATE').value = BQ_ARG.BEGIN_DATE;
			$('END_DATE').value = BQ_ARG.END_DATE;
			$('APPLY_PROCESS').value = BQ_ARG.APPLY_PROCESS;
			$('QUERY_KIND').value = BQ_ARG.QUERY_KIND;
			$('QUERY_COND').value = BQ_ARG.QUERY_COND;
			doQuery();
		</c:if>
	}

		
	PageUI.resize(true);
	
	fix();
}

function buttonAuth(){
	var authButtons = {
			//B0001:"btn_query<%--查詢--%>",
			B0021:"btn_export<%--匯出excel--%>"
	};
	<dz:grantButtons FUNC_ID="DSA11000" ignored="false"/>
}

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
					<%-- [20240722] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					split: ['SEND_DATE'],
					column:[
						{ header: "受理編號", key: "APPLY_ID",
							render:function(record, value){
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { linkByApplyID( value ); };
				                 	return link;
							}
						},
						{ header: "借款人", key: "BORROW_NAME_MASK", attrs:{style:"font-family:'EUDC'"},<%-- [20240722]難字調整--%>
							render:function(rec, val){	
							//超連結至DSC8_3100
							if(rec.CONTROL_CODE){
								if(rec.LINKTODSC83100 == 'Y') {
							
									var link = new Element('a', { href : '#' });
									link.update( val+"<font color='red'>("+rec.CONTROL_CODE+")</font>" );	
										link.observe('click', 
											function(){ linkTo_DSC8_3100(rec.BORROW_ID,rec.CONTROL_SOURCE);	
										});
									return link;
								}else{
									return val+"<font color='red'>("+rec.CONTROL_CODE+")</font>";
								}
							}
							return val;
							}
						 },
						{ header: "<font color='red'>受理進度</font>", key: "APPLY_PROCESS_NM",
							render:function(record, value){
		
									var Process = record.APPLY_PROCESS;
									if  ('70' == Process || '80' == Process || '90' == Process){ 
							  			var link = document.createElement( "a" );
				                 		link.href = "#";
				                 		link.innerHTML = '<font color="red">' + value + '</font>';
				                		link.onclick = function( event ) { linkByApplyProcess( record.APPLY_ID, record.APPLY_PROCESS ); };
				                 		return link;
				                 	} else {
				                 		return value;
				                 	}
							}
						},
						{ header: "經手人員", key: "AGENT_NAME", attrs:{style:"font-family:'EUDC'"}<%-- [20240722]難字調整--%>},
						{ header: "受理日期", key: "APPLY_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
						{ header: "承辦科別", key: "CRED_DEPT_NM"},
						{ header: "輸入人員", key: "INPUT_NAME", attrs:{style:"font-family:'EUDC'"}<%-- [20240722]難字調整--%>},
						{ header: "是否需核貸前補全", key: "SUPPLY", 
							render:function(record, value){
									if (value != ''){
										var link = document.createElement( "a" );
					                 	link.href = "#";
					                 	link.innerHTML = '<font color="red">需核貸前補全</font>';
					                	link.onclick = function( event ) { linkBySUPPLY( record.APPLY_ID ); };
					                	return link;
									} else {
										return " ";
									}
							}						
						},
						{ header: "承辦人員", key: "CRED_NAME", attrs:{style:"font-family:'EUDC'"}<%-- [20240722]難字調整--%>},
						{ header: "匯款人員", key: "REMIT_NAME", attrs:{style:"font-family:'EUDC'"}<%-- [20240722]難字調整--%>},
						{ header: "送件日期", key: "SEND_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
						{ header: "鑑價覆核", key: "REPORT_DATE",
							render:function(record,val){
								if("Y"==record.REPORT_DATE_LINK){
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = val ? Date.toROC(val) : "";
				                	link.onclick = function( event ) { linkByReportDate( record.APPLY_ID ); };
				                 	return link;
				                }else{
							 		return val ? Date.toROC(val) : "";
							 	}
							}
						},
						{ header: "簽件日期", key: "SCRIBE_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
						{ header: "核貸日期", key: "AGREE_DATE",
							render:function(record, value){
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value ? Date.toROC(value) : "";
				                	link.onclick = function( event ) { linkByAgreeDate( record.APPLY_ID ); };
				                 	return link;
							}
						},
						{ header: "對保日期", key: "GUARANTOR_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
						{ header: "一匯日期", key: "REMIT1_DATE",
							render:function(record, value){
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value ? Date.toROC(value) : "";
				                	link.onclick = function( event ) { linkByRemit1Date( record.APPLY_ID ); };
				                 	return link;
							}
						},
						{ header: "借款金額(萬)", key: "LOAN_AMT"},
						{ header: "核貸金額(萬)", key: "AGREE_AMT",
							render:function(record, value){

									// 進度為核貸後才顯示金額
									var APPLY_PROCESS = record.APPLY_PROCESS || 0;
									if (APPLY_PROCESS > 60 && APPLY_PROCESS < 99){
					                	return '<font color="red">'+value+'</font>';
									} else {
										return " ";
									}
							}
						},
						{ header: "承辦人員電話", key: "CRED_TEL"},
						{ header: "匯款人員電話", key: "REMIT_TEL"}
					]
				}
			);
			
		}//end init()--
		
		
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

//--------------------------------------------------------------------------	
//	查詢Function
//--------------------------------------------------------------------------
function doQuery(){

	var validator = checkInput(); //查詢條件檢核
	
	columnToUpperCase('DIVNO');
	columnToUpperCase('QUERY_COND');
	
	if(!validator.validate()){		
		return false;
	}
	
	var obj = {};
	obj.DIVNO = $F('DIVNO');
	obj.BEGIN_DATE = $F('BEGIN_DATE');
	obj.END_DATE = $F('END_DATE');
	obj.APPLY_PROCESS = $F('APPLY_PROCESS');
	obj.QUERY_KIND = $F('QUERY_KIND');
	obj.QUERY_COND = $F('QUERY_COND');
		
  	new Ajax.Request("<%=dispatcher%>/DSA1_1000/query", 
		{
			parameters:obj,
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
				
			    	var CONTROL_CODE =  resp.linkCONTROL_CODE;
					var LINKTODSC83100 =  resp.LINKTODSC83100;
				    
					grid.load(resp.rtnList);
					if (CONTROL_CODE){
				   
						var MSG;
						if(CONTROL_CODE == "ERR"){
						    MSG ="本件有「特殊管控」注意事項。";
						}else if(CONTROL_CODE){
							MSG ="本件有「特殊提醒」注意事項。";
						}
						if("Y" == LINKTODSC83100){
						    MSG += "\r\n若要查詢特殊件控管變更紀錄請按『確定』鍵?";
							if( confirm(MSG)){
								   linkTo_DSC8_3100(resp.linkBORROW_ID,"ALL");
					        }
				        }else{
				         	MSG += "\r\n詳細內容請洽"+resp.linkCONTROL_DEPT_GROUP_NM;
				        	alert(MSG);
				        }
					}
				}else{
					if(resp.DNFE){
						grid.load([]);
					}						
				}
				fix();
			}
		});
}

//--------------------------------------------------------------------------	
//	匯出 excel Function
//--------------------------------------------------------------------------
function doExportXls(){

	if(!validator.validate()){
		return;
	}
	
	$('gridJSON').value = grid.getXlsSettingJSON('受理進度明細表');

	RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSA1_1000/exportXls', Form.serialize("form1"));

}

//--------------------------------------------------------------------------	
//	受理編號超連結至DSA1_1700(受理資料修正)畫面
//--------------------------------------------------------------------------
function linkByApplyID(APPLY_ID) {
	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>/DSA1_1700/prompt";	
	LP_JSON.APPLY_ID = APPLY_ID;
	
	// 加上顯示欄位的保留值
	LP_JSON.BQ_ARG = {};
	LP_JSON.BQ_ARG.DIVNO = $F('DIVNO');
	LP_JSON.BQ_ARG.BEGIN_DATE = $F('BEGIN_DATE');
	LP_JSON.BQ_ARG.END_DATE = $F('END_DATE');
	LP_JSON.BQ_ARG.APPLY_PROCESS = $F('APPLY_PROCESS');
	LP_JSON.BQ_ARG.QUERY_KIND = $F('QUERY_KIND');
	LP_JSON.BQ_ARG.QUERY_COND = $F('QUERY_COND');
	LP_JSON.BACK_TRX = 'DSA1_1000';
	LP_JSON.BACK_ACTION = 'prompt';
	
	linkTo(LP_JSON, 'form1');
}

//--------------------------------------------------------------------------	
//	受理進度超連結
//--------------------------------------------------------------------------
function linkByApplyProcess(APPLY_ID, APPLY_PROCESS) {

	if  ('70' == APPLY_PROCESS){ 
		
		// 受理進度:70.核貸
	 	// 超連結至DSA1_1400(核准明細查詢)畫面
		var url = "<%=dispatcher%>" + "/DSA1_1400/prompt";
		
	} else if('80' == APPLY_PROCESS || '90' == APPLY_PROCESS) {
	
		// 受理進度:80.代償一匯,90.匯款完畢
		// 超連結至DSA1_1300(匯款明細查詢)畫面
		var url = "<%=dispatcher%>" + "/DSA1_1300/prompt";
	}
	
	var LP_JSON = {};
	LP_JSON.action = url;	
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.SYS = '';
	
	// 加上顯示欄位的保留值
	LP_JSON.BQ_ARG = {};
	LP_JSON.BQ_ARG.DIVNO = $F('DIVNO');
	LP_JSON.BQ_ARG.BEGIN_DATE = $F('BEGIN_DATE');
	LP_JSON.BQ_ARG.END_DATE = $F('END_DATE');
	LP_JSON.BQ_ARG.APPLY_PROCESS = $F('APPLY_PROCESS');
	LP_JSON.BQ_ARG.QUERY_KIND = $F('QUERY_KIND');
	LP_JSON.BQ_ARG.QUERY_COND = $F('QUERY_COND');
	
	linkTo(LP_JSON, 'form1');	
}

//--------------------------------------------------------------------------	
//	是否需核貸前補全超連結至DSA1_1100(房貸補全查詢)畫面
//--------------------------------------------------------------------------
function linkBySUPPLY(APPLY_ID) {
	
	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>" + "/DSA1_1100/prompt";
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.SYS = '';
	
	// 加上顯示欄位的保留值
	LP_JSON.BQ_ARG = {};
	LP_JSON.BQ_ARG.DIVNO = $F('DIVNO');
	LP_JSON.BQ_ARG.BEGIN_DATE = $F('BEGIN_DATE');
	LP_JSON.BQ_ARG.END_DATE = $F('END_DATE');
	LP_JSON.BQ_ARG.APPLY_PROCESS = $F('APPLY_PROCESS');
	LP_JSON.BQ_ARG.QUERY_KIND = $F('QUERY_KIND');
	LP_JSON.BQ_ARG.QUERY_COND = $F('QUERY_COND');
	
	linkTo(LP_JSON, 'form1');	
}

//--------------------------------------------------------------------------	
//	鑑價報告日期超連結至DSA3_0500(一般鑑價報告)畫面
//--------------------------------------------------------------------------
function linkByReportDate(APPLY_ID) {
	
	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>" + "/DSA3_0500/prompt";
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.SYS = '';
	
	// 加上顯示欄位的保留值
	LP_JSON.BQ_ARG = {};
	LP_JSON.BQ_ARG.DIVNO = $F('DIVNO');
	LP_JSON.BQ_ARG.BEGIN_DATE = $F('BEGIN_DATE');
	LP_JSON.BQ_ARG.END_DATE = $F('END_DATE');
	LP_JSON.BQ_ARG.APPLY_PROCESS = $F('APPLY_PROCESS');
	LP_JSON.BQ_ARG.QUERY_KIND = $F('QUERY_KIND');
	LP_JSON.BQ_ARG.QUERY_COND = $F('QUERY_COND');
	
	linkTo(LP_JSON, 'form1');	
}

//--------------------------------------------------------------------------	
//	核貸日期超連結至DSA1_1400(核准明細查詢)畫面
//--------------------------------------------------------------------------
function linkByAgreeDate(APPLY_ID) {
	
	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>" + "/DSA1_1400/prompt";
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.SYS = '';
	
	// 加上顯示欄位的保留值
	LP_JSON.BQ_ARG = {};
	LP_JSON.BQ_ARG.DIVNO = $F('DIVNO');
	LP_JSON.BQ_ARG.BEGIN_DATE = $F('BEGIN_DATE');
	LP_JSON.BQ_ARG.END_DATE = $F('END_DATE');
	LP_JSON.BQ_ARG.APPLY_PROCESS = $F('APPLY_PROCESS');
	LP_JSON.BQ_ARG.QUERY_KIND = $F('QUERY_KIND');
	LP_JSON.BQ_ARG.QUERY_COND = $F('QUERY_COND');
	
	linkTo(LP_JSON, 'form1');	
}

//--------------------------------------------------------------------------	
//	一匯日期超連結至DSA1_1300(匯款明細查詢)畫面
//--------------------------------------------------------------------------
function linkByRemit1Date(APPLY_ID) {		
	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>" + "/DSA1_1300/prompt";
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.SYS = '';
	
	// 加上顯示欄位的保留值
	LP_JSON.BQ_ARG = {};
	LP_JSON.BQ_ARG.DIVNO = $F('DIVNO');
	LP_JSON.BQ_ARG.BEGIN_DATE = $F('BEGIN_DATE');
	LP_JSON.BQ_ARG.END_DATE = $F('END_DATE');
	LP_JSON.BQ_ARG.APPLY_PROCESS = $F('APPLY_PROCESS');
	LP_JSON.BQ_ARG.QUERY_KIND = $F('QUERY_KIND');
	LP_JSON.BQ_ARG.QUERY_COND = $F('QUERY_COND');
	
	linkTo(LP_JSON, 'form1');	
}

//--------------------------------------------------------------------------	
//	特殊控管超連結至DSC8_3100畫面
//--------------------------------------------------------------------------
function linkTo_DSC8_3100(BORROW_ID,CONTROL_SOURCE){
	  
       popupWin.popup({
		src: '<%=dispatcher%>/DSC8_3100/prompt',scrolling : 'yes',
		parameters: { 
			LOAN_ID : BORROW_ID,
			CONTROL_TYPE : 'U',
			CONTROL_SOURCE : CONTROL_SOURCE
		}, 
		width: 600, 
		height: 350,
		cb : function(obj){}
	});
}
//--------------------------------------------------------------------------	
//	受理編號超連結至DSC8_3100(受理資料修正)畫面
//--------------------------------------------------------------------------
function linkTo_DSC8_3100_2(BORROW_ID,CONTROL_SOURCE) {
	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>/DSC8_3100/prompt";	
	LP_JSON.LOAN_ID = BORROW_ID;
	LP_JSON.CONTROL_TYPE = 'U';
	LP_JSON.CONTROL_SOURCE = CONTROL_SOURCE;
	
	// 加上顯示欄位的保留值
	LP_JSON.BQ_ARG = {};
	LP_JSON.BQ_ARG.DIVNO = $F('DIVNO');
	LP_JSON.BQ_ARG.BEGIN_DATE = $F('BEGIN_DATE');
	LP_JSON.BQ_ARG.END_DATE = $F('END_DATE');
	LP_JSON.BQ_ARG.APPLY_PROCESS = $F('APPLY_PROCESS');
	LP_JSON.BQ_ARG.QUERY_KIND = $F('QUERY_KIND');
	LP_JSON.BQ_ARG.QUERY_COND = $F('QUERY_COND');
	LP_JSON.BACK_TRX = 'DSA1_1000';
	LP_JSON.BACK_ACTION = 'prompt';
	
	linkTo(LP_JSON, 'form1');
}

  

//判斷瀏覽器
var ie_ver = false;
	/*@cc_on  ie_ver = (document.documentMode||( document.compatMode == "CSS1Compat" ? "XMLHttpRequest" in window ? @_jscript_version*10-50 : 6 : 5) ); if( ie_ver < 8 ){ loadByQuircks=true; } @*/
function linkTo(LP_JSON){
	if(ie_ver !== false){
	    CSRUtil.linkTo(LP_JSON, 'form1');
	}else{
		//導頁
		var url=LP_JSON.action;
				
		var form_to = new Element('form', {'action': url, 'type': 'post', 'style':'display:none;'});
		
		for( var param in LP_JSON){ 
			var content = LP_JSON[param];
			form_to.insert(new Element('input', {name:param, value:content}));
		}
		LP_JSON.RQ_SENDER = window.location.pathname;
		top.LP_JSON = Object.toJSON(LP_JSON);
		document.body.appendChild(form_to);
		form_to.submit();
	}
}

//--------------------------------------------------------------------------	
//	檢核Function
//--------------------------------------------------------------------------
function checkInput() {
	validator.clear();
	validator = new Validator();
	validator.errHandler = new AlertHandler();

	if($F('DIVNO').trim() == "" && $F('QUERY_KIND') == '0'){
		validator.define('DIVNO','受理單位','請輸入單位代號查詢!', 'string', '-1', '-1');
	}
	
	if ($F('QUERY_KIND') == '0' || $F('QUERY_KIND') == '5'){
	
		if($F('BEGIN_DATE').trim() == ""){
			validator.define('BEGIN_DATE','受理日期(起)','受理日期(起)不得為空', 'string', '-1', '-1');
		}
		
		if($F('END_DATE').trim() == ""){
			validator.define('END_DATE','受理日期(迄)','受理日期(迄)不得為空', 'string', '-1', '-1');
		}
	}

	if($F('BEGIN_DATE').trim() != ""){
		validator.define('BEGIN_DATE','受理日期(起)','受理日期(起)格式有誤', 'isROCdate');
	}
	
	if($F('END_DATE').trim() != ""){
		validator.define('END_DATE','受理日期(迄)','受理日期(迄)格式有誤', 'isROCdate');
	}

	if($F('BEGIN_DATE').trim() != "" && $F('END_DATE').trim() != ""){
		if (isROCdate($F('BEGIN_DATE'),true) && isROCdate($F('END_DATE'),true)){
			if(diffDaysROC($F('BEGIN_DATE'), $F('END_DATE')) < 0) {
				validator.define('END_DATE','受理日期(迄)','終止日期需大於起始日期，請檢查後重新輸入查詢條件!', 'string', '-1', '-1');
			}
		}
	}
	
	
	if($F('QUERY_KIND') == '0'){
		if (isROCdate($F('BEGIN_DATE'),true) && isROCdate($F('END_DATE'),true)){
			if (diffDaysROC($F('BEGIN_DATE'), $F('END_DATE')) > 90) {
				validator.define('END_DATE','受理日期(迄)','查詢期間僅限三個月!', 'string', '-1', '-1');
			}
		}
	}
	
	// 判斷「其他查詢(種類)」
	if($F('QUERY_KIND') != "0"){
		if($F('QUERY_COND').trim() == ""){
			validator.define('QUERY_COND','其他查詢','請輸入其他查詢條件!', 'string', '-1', '-1');
		}
		if($F('QUERY_KIND') == "1"){
			validator.define('QUERY_COND','其他查詢','請輸入正確受理編號!', 'string', '11', '11');
		}
		if($F('QUERY_KIND') == "2" && $F('QUERY_COND').trim() != "" && !idCheck1($F('QUERY_COND').toUpperCase()) && !iscmpid($F('QUERY_COND').toUpperCase()) ){
			validator.define('QUERY_COND','其他查詢','借款人ID有誤，請檢查後重新輸入!', 'string', '-1', '-1');
		}
		if($F('QUERY_KIND') == "4" && $F('QUERY_COND').trim() != "" && !idCheck1($F('QUERY_COND').toUpperCase()) ){
			validator.define('QUERY_COND','其他查詢','經手人ID號有誤，請檢查後重新輸入!', 'string', '-1', '-1');
		}		
	}
	
	
	return validator;
}

function diffDaysROC(strRoc1,strRoc2)
{
	var intRoc1=0;
	var intRoc2=0;
	var int11=0;
	var int12=0;
	var int21=0;
	var int22=0;
	int11=(strRoc1.length>6 ? 3:2);
	int12=(strRoc1.length>6 ? 5:4);
	strRoc1 = (parseInt(strRoc1.substr(0,int11))+1911) + "/" + strRoc1.substr(int11,2) + "/" + strRoc1.substr(int12,2);
	int21=(strRoc2.length>6 ? 3:2);
	int22=(strRoc2.length>6 ? 5:4);
	strRoc2 = (parseInt(strRoc2.substr(0,int21))+1911) + "/" + strRoc2.substr(int21,2) + "/" + strRoc2.substr(int22,2);
	intRoc1=Date.parse(strRoc1);
	intRoc2=Date.parse(strRoc2);
	return ((intRoc2-intRoc1)/86400000);
}

<%--
	轉大寫
--%>
function columnToUpperCase(columnName) {
	$(columnName).value = $(columnName).value.toUpperCase();
}

//
--></script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 

	<form name="form1" id="form1" method="post"  style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px; '>
	<input name="LP_JSON" id="LP_JSON" type="hidden" value="">
	<input name="IS_BACK" id="IS_BACK" type="hidden" >
	<input type="hidden" name="gridJSON" id="gridJSON" value="">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="20%">
		受理單位<br>
		<font color='red' size=2>可輸入兩碼區部代號查詢</font>
		</td>
		<td class="tbYellow2" width="10%">
			<input type="text" value="${DIVNO}" class="textBox" id="DIVNO" name="DIVNO" size="5" maxlength="5">
		</td>
		<td class="tbYellow" width="10%">受理日期</td>
		<td class="tbYellow2" width="29%">
			<input type="text" datatype="ROCDate" value="${SYS_DATE}" class="textBox2" size="10" maxlength="7" name="BEGIN_DATE" id="BEGIN_DATE" />
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('BEGIN_DATE'))">
			~
			<input type="text" datatype="ROCDate" value="${SYS_DATE}" class="textBox2" size="10" maxlength="7" name="END_DATE" id="END_DATE" />
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('END_DATE'))">
		</td>
		<td class="tbYellow" width="5%">進度</td>
		<td class="tbYellow2" width="18%">
			<select class="textBox2" name="APPLY_PROCESS" id="APPLY_PROCESS">
                          <option value="00">全部</option>
                          <c:forEach var="map" items="${APPLY_PROCESS_LIST}">
                            <option value="${map.key}">${map.value}</option>
                          </c:forEach>
                        </select>
		</td>
		<td class="tbYellow2" width="8%" rowSpan="2" align="center">
			<input type="button" id="btn_query" value="查詢" class="button">
		</td>
	</tr>
	<tr>
		<td class="tbYellow">其他查詢</td>
		<td class="tbYellow2" colspan="5">
			<select class="textBox2" name="QUERY_KIND" id="QUERY_KIND">
                          <option value="0">全部</option>
                          <c:forEach var="map" items="${OTHER_QUERY_LIST}">
                          	<option value="${map.key}">${map.value}</option>
                          </c:forEach>
             </select>
              <input type="text" value="" class="textBox" id="QUERY_COND" name="QUERY_COND" size="12">
		</td>	
	</tr>
	<tr>
		<td colspan="7" align="center">
			<input type="button" id="btn_export" value="匯出 excel" class="button">
			<input type="button" id="btn_clear" value="清除" class="button">
		</td>
	</tr>	
	
</table>

</form>
<form name="form2" id="form2" method="post" style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px; '>
<table id='grid' class="grid"></table>
</form>

</body>
</html>
