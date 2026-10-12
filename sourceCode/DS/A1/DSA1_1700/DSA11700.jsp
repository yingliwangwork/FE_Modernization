<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource"/>

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

<style>
div.tableParent{
	border:0px;
}
table.tableGrid {
    margin: 0px;
    padding: 0px;
    padding-top: 0px;
    border:0px;
}
table.tableGrid td {
    margin: 0px;
    padding: 0px;
    padding-top: 0px;
    border:0px;
    text-align:left;
}

table.tableGrid th {
    margin: 0px;
    padding: 0px;
    padding-top: 0px;
    border:0px;
}

table.tableGrid thead{
	display: none;
}
</style>
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
</head>

<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
var grid;
var grid0;
var grid1;
var grid2;
var grid3;

function initApp(){

	//PageUI.createPage("DSA11700" , "受理作業" , "受理資料修正");
	//PageUI.loadin(["grid"] ,0);
	PageUI.createPageWithAllBodySubElement("DSA11700" , "受理作業" , "受理資料修正", 0, '${param.titleNotDisplay}' == 'Y');
	
	if('${param.titleNotDisplay}' == 'Y'){
		$('btn_back').hide();
	}

	cleanMsgBoard();
	
	displayMessage();

	new UI().init();

	if( CSRUtil.isBackLink('form1') ){
		doQuery();
	}else{
		doQuery();
	}
	
	PageUI.resize(true);

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
					table:$('grid'), pageSize:0, allSortable: false,overDiv:false,
					column:[
						{ header: "受理編號", key: "APPLY_ID",
							render:function(record, value){
							  		if("無"==value){
							  			return value;
							  		}
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value+'　'+record.BORROW_NAME+'　'+record.BORROW_ID;
				                 	link.style="font-family:'EUDC'"; <%--[20240722]難字調整 --%>
				                	link.onclick = function( event ) { linkDSA1_0100( record.APPLY_ID ); };
				                 	return link;
							}
						}
					]
				}
			);
			
			//產生 Grid 物件
			grid0 = new TableUI(
				{	
					table:$('grid0'), pageSize:0, allSortable: false,overDiv:false,
					column:[
						{ header: "個人(或法人)姓名", key: "NAME",
							render:function(record, value){
							  		if("無"==value){
							  			return value;
							  		}
							  		NAME = record.NAME?record.NAME:"";
							  		CNAME = record.CNAME?record.CNAME:"";
							  		showNAME = CNAME==""?NAME:CNAME;
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = showNAME+'　'+record.ID;
				                 	link.style="font-family:'EUDC'"; <%--[20240722]難字調整 --%>
				                 	if(record.CNAME){
				                 		link.onclick = function( event ) { linkDSA1_0300( record.APPLY_ID,record.ID ); };
				                 	}else if(record.NAME){
				                		link.onclick = function( event ) { linkDSA1_0200( record.APPLY_ID,record.ID,"0","1" ); };

				                	}
				                 	return link;
							}
						}
					]
				}
			);
		
			//產生 Grid 物件
			grid1 = new TableUI(
				{	
					table:$('grid1'), pageSize:0, allSortable: false,overDiv:false,
					column:[
						{ header: "保證人姓名", key: "NAME",
							render:function(record, value){
							  		if("無"==value){
							  			return value;
							  		}
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value+'　'+record.ID+'　'+record.GUAR_RELATION_NM+'　'+(record.BIRTHDAY?Date.toROC(record.BIRTHDAY):'');
				                 	link.style="font-family:'EUDC'"; <%--[20240722]難字調整 --%>
				                	link.onclick = function( event ) { linkDSA1_0250( record.APPLY_ID,record.ID,"1",record.RELATION ); };
				                 	return link;
							}
						}
					]
				}
			);
			
			//產生 Grid 物件
			grid2 = new TableUI(
				{	
					table:$('grid2'), pageSize:0, allSortable: false,overDiv:false,
					column:[
						{ header: "地號", key: "LAND_NO1",
							render:function(record, value){
							  		if("無"==value){
							  			return value;
							  		}
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = record.LAND_NO1+"-"+record.LAND_NO2+'　'+record.NAME+'　'+(record.TRAN_DATE?Date.toROC(record.TRAN_DATE):'')+'　'+record.ID;
				                 	link.style="font-family:'EUDC'"; <%--[20240722]難字調整 --%>
				                	link.onclick = function( event ) { linkDSA1_0400(record.APPLY_ID,record.ID,record.LAND_NO1,record.LAND_NO2,record.LAND_NO1,record.TRAN_DATE); };
				                 	return link;
							}
						}
					]
				}
			);
			
			//產生 Grid 物件
			grid3 = new TableUI(
				{	
					table:$('grid3'), pageSize:0, allSortable: false,overDiv:false,
					column:[
						{ header: "建號", key: "BUILD_NO1",
							render:function(record, value){
							  		if("無"==value){
							  			return value;
							  		}
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = record.BUILD_NO1+"-"+record.BUILD_NO2+'　'+record.ADDR_NO;
				                 	link.style="font-family:'EUDC'"; <%--[20240722]難字調整 --%>
				                	link.onclick = function( event ) { linkDSA1_0500(record.APPLY_ID,record.BUILD_NO1,record.BUILD_NO2); };
				                 	return link;
							}
						}
					]
				}
			);
			
			//查詢 button click event                        
			$('btn_back').observe('click',function(event){   
					var ie_ver = false;
					/*@cc_on  ie_ver = (document.documentMode||( document.compatMode == "CSS1Compat" ? "XMLHttpRequest" in window ? @_jscript_version*10-50 : 6 : 5) ); if( ie_ver < 8 ){ loadByQuircks=true; } @*/
					if(ie_ver !== false ){
						linkBack();
					}else{
						if(history.length){
							history.back();
						}
					}
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
	var obj = {};
	obj.APPLY_ID = '${APPLY_ID}';	
  	new Ajax.Request("<%=dispatcher%>/DSA1_1700/query", 
		{
			parameters:obj,
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					//保留參數管理-更新受理編號
					CSRUtil.keepParamsManager.put({'APPLY_ID': '${APPLY_ID}'});
					A010vo = resp.aDTDSA010?resp.aDTDSA010:{"APPLY_ID":"無"};
					A020vo = {"NAME":"無"};
					A030vo = resp.aDTDSA030?resp.aDTDSA030:{"NAME":"無"};
					A040vo = {"LAND_NO1":"無","LAND_NO2":"","NAME":"無"};
					A050vo = {"BUILD_NO1":"無"};
					grid.load([A010vo]);
					if("1"==A010vo.COPR_CODE && resp.aDTDSA030){
						grid0.load([A030vo]);
					}else if("0"==A010vo.COPR_CODE && resp.rtnMap && resp.rtnMap.BORROWER){
						grid0.load([resp.rtnMap.BORROWER]);
					}else{
						grid0.load([A030vo]);
					}
					if(resp.rtnMap && resp.rtnMap.GUARANTEE){
						if(resp.rtnMap.GUARANTEE!=''){
							grid1.load(resp.rtnMap.GUARANTEE);
						}else{
							grid1.load([A020vo]);
						}
					}else{
						grid1.load([A020vo]);
					}
					grid2.load(resp.A040List?resp.A040List:[A040vo]);
					grid3.load(resp.A050List?resp.A050List:[A050vo]);
				}else{
					A010vo = {"APPLY_ID":"無"};
					A020vo = {"NAME":"無"};
					A030vo = {"NAME":"無"};
					A040vo = {"LAND_NO1":"無"};
					A050vo = {"BUILD_NO1":"無"};
					grid.load([A010vo]);
					grid0.load([A020vo]);
					grid1.load([A030vo]);
					grid2.load([A040vo]);
					grid3.load([A050vo]);
				}
				/* $("grid").down("thead").select('tr')[0].hide();
				$("grid0").down("thead").select('tr')[0].hide();
				$("grid1").down("thead").select('tr')[0].hide();
				$("grid2").down("thead").select('tr')[0].hide();
				$("grid3").down("thead").select('tr')[0].hide();
				*/
			}
		});
}

//--------------------------------------------------------------------------	
//	DSA1_0100(借款申請輸入)畫面
//--------------------------------------------------------------------------
function linkDSA1_0100(APPLY_ID) {
	
	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>/DSA1_0100/prompt?titleNotDisplay=Y";	
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.parameters = {"APPLY_ID":APPLY_ID};
	LP_JSON.BACK_TRX = 'DSA1_1700';			// 回這頁
	LP_JSON.BACK_ACTION = 'query';			// 回來要先做的事
	
	CSRUtil.linkTo(LP_JSON, 'form1');


}

//--------------------------------------------------------------------------	
//	DSA1_0200(借款資料輸入)畫面或DSA1_0300(法人資料輸入)畫面
//--------------------------------------------------------------------------
function linkDSA1_0200(APPLY_ID, ID, TYPE, RELATION) {

	var LP_JSON = {};
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.ID = ID; 
	LP_JSON.TYPE = TYPE;
	LP_JSON.RELATION = RELATION;
	// 法人件(COPR_CODE = ‘0’)
 	// 連結至DSA1_0200(借款資料輸入)畫面
	LP_JSON.action = "<%=dispatcher%>/DSA1_0200/prompt?titleNotDisplay=Y";
	LP_JSON.parameters = {"APPLY_ID":APPLY_ID,"ID":ID,"TYPE":TYPE,"RELATION":RELATION};
	LP_JSON.BACK_TRX = 'DSA1_1700';			// 回這頁
	LP_JSON.BACK_ACTION = 'query';			// 回來要先做的事
	
	CSRUtil.linkTo(LP_JSON, 'form1');

}

//--------------------------------------------------------------------------	
//	DSA1_0250(保證人資料輸入)畫面
//--------------------------------------------------------------------------
function linkDSA1_0250(APPLY_ID, ID, TYPE, RELATION) {
	
	var LP_JSON = {};
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.ID = ID;
	LP_JSON.TYPE = TYPE;
	LP_JSON.RELATION = RELATION;
	// 非法人件(COPR_CODE = ‘1’)
	// 連結至DSA1_0250(保證人資料輸入)畫面
	LP_JSON.action = "<%=dispatcher%>/DSA1_0250/prompt?titleNotDisplay=Y";
	LP_JSON.parameters = {"APPLY_ID":APPLY_ID,"ID":ID,"TYPE":TYPE,"RELATION":RELATION};
	LP_JSON.BACK_TRX = 'DSA1_1700';			// 回這頁
	LP_JSON.BACK_ACTION = 'query';			// 回來要先做的事
	
	CSRUtil.linkTo(LP_JSON, 'form1');
	
}

//--------------------------------------------------------------------------	
//	DSA1_0300(法人資料輸入)畫面
//--------------------------------------------------------------------------
function linkDSA1_0300(APPLY_ID, ID) {

	var LP_JSON = {};
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.ID = ID;
	// 非法人件(COPR_CODE = ‘1’)
	// 連結至DSA1_0300(法人資料輸入)畫面
	LP_JSON.action = "<%=dispatcher%>/DSA1_0300/prompt?titleNotDisplay=Y";
	LP_JSON.parameters = {"APPLY_ID":APPLY_ID,"ID":ID};
	LP_JSON.BACK_TRX = 'DSA1_1700';			// 回這頁
	LP_JSON.BACK_ACTION = 'query';			// 回來要先做的事
	
	CSRUtil.linkTo(LP_JSON, 'form1');

}

//--------------------------------------------------------------------------	
//	DSA1_0400(土地謄本輸入)畫面
//--------------------------------------------------------------------------
function linkDSA1_0400(APPLY_ID,ID,LAND_NO1,LAND_NO2,LAND_NO1,TRAN_DATE) {
	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>/DSA1_0400/prompt?titleNotDisplay=Y";	
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.ID = ID;
	LP_JSON.LAND_NO1 = LAND_NO1;
	LP_JSON.LAND_NO2 = LAND_NO2;
	LP_JSON.TRAN_DATE = TRAN_DATE;
	LP_JSON.parameters = {"APPLY_ID":APPLY_ID,"ID":ID,"LAND_NO1":LAND_NO1,"LAND_NO2":LAND_NO2,"TRAN_DATE":TRAN_DATE};
	LP_JSON.BACK_TRX = 'DSA1_1700';			// 回這頁
	LP_JSON.BACK_ACTION = 'query';			// 回來要先做的事

	CSRUtil.linkTo(LP_JSON, 'form1');

}

//--------------------------------------------------------------------------	
//	DSA1_0500(建物謄本輸入)畫面
//--------------------------------------------------------------------------
function linkDSA1_0500(APPLY_ID,BUILD_NO1,BUILD_NO2) {
	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>/DSA1_0500/prompt?titleNotDisplay=Y";	
	LP_JSON.APPLY_ID = APPLY_ID;
	LP_JSON.BUILD_NO1 = BUILD_NO1;
	LP_JSON.BUILD_NO2 = BUILD_NO2;
	LP_JSON.parameters = {"APPLY_ID":APPLY_ID,"BUILD_NO1":BUILD_NO1,"BUILD_NO2":BUILD_NO2};
	LP_JSON.BACK_TRX = 'DSA1_1700';			// 回這頁
	LP_JSON.BACK_ACTION = 'query';			// 回來要先做的事

	CSRUtil.linkTo(LP_JSON, 'form1');

}

function linkBack() {
	if(Object.keys(CSRUtil.getLP_JSON()).length!=0){
		CSRUtil.linkBack();
	}else{
		var LP_JSONObj = $('LP_JSON').value;
		if (LP_JSONObj) {
			//var LP_JSON = LP_JSONObj.evalJSON(); //轉為LP_JSON陣列物件
			var LP_JSON = [];
			LP_JSON.push(LP_JSONObj.evalJSON());
			if (LP_JSON.length <= 0) {
				alert('無法取得回上頁資訊!');
				return;
			}
			var backLP_JSON = LP_JSON[LP_JSON.length - 1]; //取最後一個LP_JSON物件
			// 取得回前一頁的LP_JSON中BACK_TRX & BACK_ACTION
			$('form1').action = '<%=dispatcher%>/' +  backLP_JSON.BACK_TRX + '/' + backLP_JSON.BACK_ACTION;
			$('IS_BACK').value = 'Y'; //必須設定IS_BACK 為Y
			submitOnce($('btn_back'));
		}
	}	
}

//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >

											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
											<form name="form1" id="form1" method="post">
												<input name="LP_JSON" id="LP_JSON" type="hidden" value="<c:out value='${LP_JSON}'/>">
												<input id="IS_BACK" name="IS_BACK" type="hidden" value="<c:out value='${IS_BACK}'/>">
												<input name="APPLY_ID" id="APPLY_ID" type="hidden" value="${APPLY_ID}">
												<tr class="tbYellow">
													<td width="10%">
														借款申請書
													</td>
													<td style="padding:0px;">
														<table id='grid' class="grid1"></table>
													</td>
												</tr>
												<tr class="tbYellow">
													<td width="10%">
														借款人資料
													</td>
													<td style="padding:0px;">
														<table id='grid0' class="grid1"></table>
													</td>
												</tr>
												<tr class="tbYellow">
													<td width="10%">
														保證人資料
													</td>
													<td style="padding:0px;">
														<table id='grid1' class="grid1"></table>
													</td>
												</tr>
												<tr class="tbYellow">
													<td width="10%">
														土地資料
													</td>
													<td style="padding:0px;">
														<table id='grid2' class="grid1"></table>
													</td>
												</tr>
												<tr class="tbYellow">
													<td width="10%">
														建物資料
													</td>
													<td style="padding:0px;">
														<table id='grid3' class="grid1"></table>
													</td>
												</tr>
												<tr>
													<td colspan="2" align="center">
														<input id="btn_back" name="btn_back" type="button" class="button" value="回上一頁">
													</td>
												</tr>
											</form>
											</table>
</body>
</html>
