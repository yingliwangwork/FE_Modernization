<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />



<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<%--[20240729]難字css  --%>
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
Event.observe(window, 'load', initApp);
Event.observe(window, 'scroll', fix);


var grid;
var validator;
var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA2_0410/');

var pattern_time = /(\d+)-(\d+)-(\d\d) (\d+):(\d+)/;	// 日期格式
var pattern_date = /(\d+)-(\d+)-(\d\d)/;	// 日期格式(date)

function initApp(){
	PageUI.createPageWithAllBodySubElement( "DSA20410" , "核貸作業" ,"聯徵記錄查詢 " ,1,'${titleNotDisplay}' == 'Y');
	validator = new Validator();
	
	displayMessage();
	
	new UI().init();
	
	<c:if test="${not empty rtnList}">
		grid.load(${rtnList});
	</c:if>	
}

//按鈕授權
//220428問題單編號 20211102-0093 BY余凱鈞
//債管反映在核心放款的Z75.Z99只能看到一周內的資料，點連結會跳出無此作業權限 
//經查若為七天內資料會導向DSA2_2200，但七天後的資料會導向DSA2_0410聯徵記錄查詢的功能，此畫面並未開給債管。
//因放企科並不同意直接開放畫面，需做查詢按鈕的角色權限卡控，才能開放畫面給債管，故需程式調整。
function buttonAuth(){
	var authButtons = {
		B0001:"btn_query" //查詢
	};		
	<dz:grantButtons FUNC_ID="DSA20410"/>
};

function UI(){
	return {
		init:function() {
			displayMessage();

			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 20, allSortable: true,overDiv:false,
					<%-- [20240729] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column : [
						{header:'查詢日期<br/>', key:'QDATE'},
						{header:'被查詢者<br/>', key:'QUERYKEY1', attrs:{style:"font-family:'EUDC'"}, <%-- [20240729]難字調整 --%>
							render:function(record, value){						
								var TXID_SHOW = record.TXID_SHOW;
								if("T50" == TXID_SHOW || "T51" == TXID_SHOW || "T52" == TXID_SHOW){
									return record.QUERY_ID+record.QUERY_NAME+'<br/>'+"(借款人)";
								}else{
									return record.QUERYKEY1+record.NAME+'<br/>'+record.TYPE_NM;
								}
							}
						},
						{header:'查詢項目<br/>', key:'TXID_SHOW' ,
							render: function( record, value ){										   					              		
		              			if(record.HYPER_AUTH == true){
			              			var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = record.TXID_SHOW;
				                	link.onclick = function( event ) { 
				                		buttons.linkTo2200(record);		                	
				                	};
				                 	return link;	
			                 	}
			                 	else{
			                 		return value;
			                 	}
		            		}
		            	},
						{header:'使用者<br/>', key:'USRNAME', attrs:{style:"font-family:'EUDC'"} }, <%-- [20240729]難字調整 --%>
						{header:'是否送<br/>聯徵', key:'TOJCIC' },
						{header:'處理狀態<br/>', key:'PROCESS_NM' },
						{header:'是否強迫<br/>送聯徵', key:'FORCE2JCIC'},
						{header:'GFS分數<br/>', key:'SCORE_NM'},
						{header:'近半年進件<br/>百分位點', key:'HY_SCORE'},
						{header:'近一年進件<br/>百分位點', key:'OY_SCORE'}
					]
				}
			);
			
			buttonAuth();
			// 查詢
			$("btn_query").observe('click',function(event){
				buttons.doQuery();
			});
			
			
			$w('APPLY_ID').each( 
				function(key){
					$(key).observe('blur', function(event){
						event.target.value = event.target.value ? event.target.value.toUpperCase() : "";
					});
				}
			);
			
			if ('${APPLY_ID}' != "") {
				$('APPLY_ID').value = '${APPLY_ID}';
			} else { 
				//保留參數管理-取得受理編號
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			}			
			if($('APPLY_ID').value){
				buttons.doQuery();
			}

		}
	};
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){
		
		var queryData = {
			APPLY_ID: $('APPLY_ID').value
		};
		
		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});

		var actionName = "query"; 
		var params = {APPLY_ID: $F('APPLY_ID')};
		ajaxPost(actionName, params);
	},
	linkTo2200:function(record){
		//@ 2018/09/28 王文進 調整查詢聯徵歷史資料來源
		var toDay = addDate(getY2KToday(),0,0,-7);
		var qDate = toY2K(record.QDATE);
		//alert(toDay);
		//alert(qDate);
		//alert(diffDay(qDate, toDay) < 0 );
		var chkMap = {};  
		chkMap.TXID = record.TXID;
		chkMap.MSGID = record.MSGID;
		chkMap.QDATE = record.QDATE;
		chkMap.QUERYKEY1 = record.QUERYKEY1;
		chkMap.QUERYKEY2 = record.QUERYKEY2;
		chkMap.ISPRINT = record.ISPRINT;
		chkMap.CRED_DEPT = record.CRED_DEPT;		
		//[申請書:24120444624]建立聯徵查詢存取軌跡紀錄:多傳入受理編號or貸款帳號
		chkMap.CASE_ID = $('APPLY_ID').value;
		if(record.TXID == 'HT50' || record.TXID == 'HT51' || record.TXID == 'HT52'){
			chkMap.NAME = record.QUERY_NAME;
		}else{
			chkMap.NAME = record.NAME;
		}
		<%--[20241213][申請書:24120444624]建立聯徵查詢存取軌跡紀錄--%>
		<%--if(record.TXID == 'HT50' || record.TXID == 'HT51' || record.TXID == 'HT52'){
			chkMap.CASE_ID = record.CASE_ID;
		}else if(!record.APPLY_ID){
			chkMap.CASE_ID = record.LOAN_ID;
		}-%>
		<%--ajaxRequest.post('insertJCIC_HIST', { reqMap : Object.toJSON(chkMap) }, 
			function(resp) {}
		);--%>
		
		var url = "<%=dispatcher%>/DSA2_2200/prompt?chkList="+Object.toJSON([chkMap])+"&LINK_FROM=DSA20410";
		if(diffDay(qDate, toDay) >= 0){
			url = "<%=dispatcher%>/DSA2_0410/queryDetail?chkList="+Object.toJSON([chkMap])+"&LINK_FROM=DSA20410";
		}
		//alert(url);
		window.open(url, "DSA2_0410", "top=50, left=50, toolbar=yes, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}
};


//--------------------------------------------------------------------------
// 共用－Ajax
//--------------------------------------------------------------------------
function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSA2_0410/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){
			if(CSRUtil.isSuccess(resp)){
				if(successAction){
	 				successAction(resp);
	 			}else{
			  		grid.load(resp.rtnList);
			  	}
			}else if(actionName == "query"){
			  	grid.load([]);
			}else if(errorAction){
				errorAction(resp);
			}			
        }}
	);
}

//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

	<form name="form1" id="form1" method="post" action="">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		
			<input type="hidden" name="QDATE" id="QDATE" value="${QDATE}">
			<input type="hidden" name="TXID" id="TXID" value="${TXID}">
			<input type="hidden" name="QUERYKEY1" id="QUERYKEY1" value="${QUERYKEY1}">
			<tr>
				<td class="tbYellow" width="15%">
					受理編號
				</td>
				<td class="tbYellow2" width="85%">
					<input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2" size="15" maxlength="11" value="${APPLY_ID}">
					<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
				</td>
			</tr>
		
		</table>
	</form>									
	<table id="grid" class="grid" width="100%"></table>
    <table width="100%">
    <tr>
        <td class="tbYellow">※財稅資料係為課稅目的蒐集，僅供金融徵信案件之參考，若有資料內容疑問時，應向資料主管機關洽詢。
        </td>
    </tr>
    </table>
</body>
</html>