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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>

<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var grid;
var authList = [];
var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA2_2200/');

function initApp(){

	PageUI.createPageWithAllBodySubElement("DSA22200" , "核貸作業" , "聯徵系統連結", 1, '${titleNotDisplay}' == 'Y');

	cleanMsgBoard();
	displayMessage();
	if(msgs[0][0] == "未輸入條件，請重新作業") {
		// 初始有錯誤
		return;
	}
	
	defineTable();
	
	<%--
		1.5	畫面顯示：
		1.5.1	若回傳聯徵系統連結資訊authList沒有一筆資料時，則警示訊息『無聯徵系統作業權限』
		1.5.2	若回傳聯徵系統連結資訊authList只有一筆資料時，畫面直接連結至authList[0]. finalString
		1.5.3	若聯徵系統連結資訊authList有兩筆資料以上時，將資料顯示在區塊1
	--%>
	authList = <c:out value="${authList}" default="[]" escapeXml="false" />;
	
	if(authList.length == 0) {
		alert("無聯徵系統作業權限");
	}else if(authList.length == 1) {
	    var url = authList[0].finalString;
		if("${LINK_FROM}" != "") {
			location.href = url;
		}else {
			window.open(url);
		}
		//建立聯徵查詢存取軌跡紀錄上線後優化
		var targetRow = authList[0];
	    var chkMap = {};
	    chkMap.TXID = targetRow["TXID"];
		chkMap.MSGID = targetRow["MSGID"];
		chkMap.QDATE = targetRow["QDATE"];
		chkMap.QUERYKEY1 = targetRow["QUERYKEY1"];
		chkMap.CASE_ID = "${CASE_ID}";
		chkMap.NAME = targetRow["NAME"];
		ajaxRequest.post('insertJCIC_ALL', { reqMap : Object.toJSON(chkMap) }, 
				function(resp) {}
			);
	}else {
		grid.load(authList);
	}
	
	PageUI.resize(true);
}

<%--
	定義table
--%>
function defineTable() {
		
		<%--
			欄位名稱	NAME	資料來源	說明
			選取			radio box，點選時超連結
			承辦科別	DEPT_NAME	authList [i]. DEPT_NAME	
			聯徵系統權限	AUTH_TYPE_NM	authList [i]. AUTH_TYPE_NM	
			聯徵系統超連結	JCIC_LINK	authList [i]. finalString	
		--%>			
		
		grid = new TableUI({
			table: $('grid'), pageSize: 10, allSortable: false,
		                autoCheckBox:{ isSelectAll :true,type: 'radio'
							,action: function (checkbox , boxStatus , records) {
								var targetRow = records[0];
							    var url = targetRow["finalString"];
							    var chkMap = {};
							    chkMap.TXID = targetRow["TXID"];
								chkMap.MSGID = targetRow["MSGID"];
								chkMap.QDATE = targetRow["QDATE"];
								chkMap.QUERYKEY1 = targetRow["QUERYKEY1"];
								chkMap.CASE_ID = "${CASE_ID}";
								chkMap.NAME = targetRow["NAME"];
								
								if("${LINK_FROM}" != "") {
									location.href = url;
									ajaxRequest.post('insertJCIC_ALL', { reqMap : Object.toJSON(chkMap) }, 
											function(resp) {}
										);
								}else {
									window.open(url);
								}
							}
		                },
			column:[
				{header:'承辦科別', key:'DEPT_NAME',
					render:function(record, value){
						return isNotEmpty(value) ? value : "";
					}
				},
				{header:'聯徵系統權限', key:'AUTH_TYPE_NM',
					render:function(record, value){
						return isNotEmpty(value) ? value : "";
					}
				}
			]
		});
}

<%--
	辨別是不是null或undefined	
--%>
function isNotEmpty(value) {
	if(value == null || typeof(value) == 'undefined') {
		return false;
	}else {
		return true;
	}
}


//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
	<table id="grid" class="grid" width="100%"></table>
</body>
</html>
