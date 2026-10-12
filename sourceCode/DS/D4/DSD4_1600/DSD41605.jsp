<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<%--
程式：DSD41605.jsp
功能：補發附件查詢
作者：吳誌倫
完成：2021-07-30

[20230410][20230407171935]
將【影像查詢】功能獨立到menu tree(開放外網)，並將【影像上傳】、【電子補發申請書】併入【影像查詢】
高強禾

[20240328]
難字調整
高強禾
--%>
 
<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
<!--匯入外部Javascript 與 css-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ImageUtil.js'></script>	
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<%-- [20240328] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type='text/javascript'>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSD41605().initApp);

function DSD41605(){

	<%-- [20230410] 移除未使用變數 --%>

	<%-- [20230410] --%>
	var grid1;
	var grid2;

	<%-- TablE UI物件 --%>	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1605/');

	<%-- [20230410] --%>
	var authButtons = {
		B0159 : [],	<%--檢視--%>
		B0077 : [] <%--刪除--%>						
	};
	
	<%-- [20230410] --%>
	var buttonAuth = function() {
		<%-- TODO 尚未設定暫時註解 --%>
		<%-- <dz:grantButtons FUNC_ID="DSD41605"/> --%>
	}

	<%-- [20230410] --%>
	var actions = {
		getReqMap : function() {
			var reqMap = {
				'REFER_ID' : '<c:out value="${REFER_ID}" />',
				'APPLY_DATE' : '<c:out value="${APPLY_DATE}" />'
			}
	        return reqMap;
		},
		authBeforeLoad : function(D40130List, D41603List) {
			
			authButtons.B0159 = [];
			authButtons.B0077 = [];
			
			var rtnList1 = D40130List || [];
			if (rtnList1.length == 0) {
				grid1.hide();
				grid1.load([]);
			} else {
				grid1.show();
				grid1.load(rtnList1);
			}

			grid2.load(D41603List || []);
		},
		authAgain1 : function() {
			$$('#grid1 button[type=button]').each(function(obj) {
				if (obj.innerHTML == '檢視') {
					authButtons.B0159.push(obj.id);
				}
			});
			buttonAuth();
		},
		authAgain2 : function() {
			$$('#grid2 button[type=button]').each(function(obj) {
				if (obj.innerHTML == '檢視') {
					authButtons.B0159.push(obj.id);
				} else if (obj.innerHTML == '刪除') {
					authButtons.B0077.push(obj.id);
				}
			});
			buttonAuth();
		}
	}
	
	var buttons = {
		<%-- [20230410] 移除goToDownload --%>
		<%-- [20230410] 檢視 --%>
		doView : function(FILE_ID, REMARK) {
			ajaxRequest.post('view', {FILE_ID : FILE_ID, REMARK : REMARK},
				function(resp) {

					var fileDetail = resp.fileDetail;
					var fileName = fileDetail[0];
					var filePath = fileDetail[1];
					
					if (resp.isPDF == 'Y') {
						RPTUtil.downloadFile('${dispatcher}/DSD4_1605/download', { 'fileName': fileName, 'filePath': filePath});
					} else {
						$('imageName').update(fileName);
						var IMAGE = new Element('DIV', { width:'100%',id:'image',name:'PIC'});
						$('imageTd').insert(IMAGE);

						if (filePath) {
							ImageUtil.showImage({
								imagePath : filePath,
								showImageDivId : 'image',
								imageWidth : '700px',
								imageHeight : '100%'
							});
						}
					}
				});
		},
		<%-- [20230410] 刪除 --%>
		doDelete : function(FILE_ID, ORG_FILE_NM) {
			if(!confirm('確認刪除【'+ORG_FILE_NM+'】?')){
				return;
			}
			
			ajaxRequest.post('delete', {FILE_ID : FILE_ID, reqMap : Object.toJSON(actions.getReqMap())},
				function(resp) {

					actions.authBeforeLoad(resp.D40130List, resp.D41603List);

					buttons.doClear();
				});
		},
		<%-- [20230410] 清空 --%>
		doClear : function() {
			$('imageName').update('');
			$('imageTd').update('');
		}
	};
	
	return {
		initApp : function() {			
			
			<%-- [20230410] --%>
			PageUI.createPageWithAllBodySubElement('DSD41605','清償作業','簽收附件查詢');
			
			<%-- [20230410] --%>
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' dateFields="APPLY_DATE" />
			
			<%-- [20230410] 增加"申請補發附件"清單 --%>
			grid1 = new TableUI({
				table : $("grid1"),
				pageSize : 10,
				title : "申請補發附件",
				pageChange : actions.authAgain1,
				afterLoad : actions.authAgain1,
				column : [
					{header: '補發申請日', key: 'REMARK', sortRule: 'date'},
					{header: '檔案類型', key: 'FILE_KIND_NM', attrs:{align:'left'}},
					{header : '檔案序號', key : 'FILE_ID'},
					{header : '檔名', key : 'ORG_FILE_NM', attrs:{align:'left'}},
					{header : '檢視', render : function(rec, val, sn) {

						var button = new Element('button', {'id':'btn_grid1View' + sn, 'type':'button', 'class':'button' }).update("檢視");
						button.observe('click', function() {
							buttons.doView(rec['FILE_ID'], rec['ORG_FILE_NM']);
						});

						if ('${AUTH_TYPE}' != '1') {
							button.disable();
						}
						return button;
					}}
				]
			});
			
			<%-- [20230410] 增加"簽收附件"清單 --%>
			grid2 = new TableUI({
				table : $("grid2"),
				pageSize : 10,
				title : "簽收附件",
				pageChange : actions.authAgain2,
				afterLoad : actions.authAgain2,
				column : [
					{header : "塗銷申請日", key : 'REMARK',sortRule:'date'},
					{header: "檔案類型", key: 'FILE_KIND_NM', attrs:{align:'left'}},
					{header : "檔案序號", key : 'FILE_ID'},
					{header : "檔名", key : 'ORG_FILE_NM', attrs:{align:'left'}},
					{header : "檢視", render : function(rec, val, sn) {
						if (rec['showView'] == 'Y') {

							var button = new Element('button', {'id':'btn_grid2View' + sn, 'type':'button', 'class':'button' }).update("檢視");
							button.observe('click', function() {
								buttons.doView(rec['FILE_ID'], rec['ORG_FILE_NM']);
							});

							if ('${AUTH_TYPE}' != '1') {
								button.disable();
							}
							return button;
						}
						return '';
					}},
					{header : "刪除", render : function(rec, val, sn) {
						if (rec['showDelete'] == 'Y') {
							
							var button = new Element('button', {'id':'btn_grid2Del' + sn, 'type':'button', 'class':'button' }).update("刪除");
							button.observe('click', function() {
								buttons.doDelete(rec['FILE_ID'],rec['ORG_FILE_NM']);
							});

							if ('${AUTH_TYPE}' != '1') {
								button.disable();
							}
							return button;
						}
						return '';
					}}
				]
			});

			<%-- [20230410] --%>
			var D40130List = <c:out value="${D40130List}" default="[]" escapeXml="false" />;
			var D41603List = <c:out value="${D41603List}" default="[]" escapeXml="false" />

			actions.authBeforeLoad(D40130List, D41603List);

			<%-- [20230410] --%>
			$('btn_clear').observe('click', buttons.doClear);

			displayMessage();
		}
	};	
}	

</script>
</head>
<body>
<form name="form1" id="form1">
	<table id='table1' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	    <tr>
            <td class="tbYellow">原貸帳號</td>
            <td class="tbYellow2"><c:out value="${REFER_ID}" /></td><%-- [20230410] 改用c:out取值 --%>
            <td class="tbYellow">借款人姓名</td>
            <%-- [20240328] 難字調整：借款人姓名，加上style並改為EL寫法 --%>
            <td class="tbYellow2" style="font-family:'EUDC'">${BORROW_NAME}</td><%-- [問題單:20230802-0175] 電子簽收檢核上線後優化 --%>
            <td class="tbYellow">申請日期</td>
            <td class="tbYellow2"><c:out value="${APPLY_DATE_ROC}" /></td><%-- [20230410] 改用c:out取值 --%>
        </tr>
    </table>
    <%-- [20230410] 申請補發附件 --%>
    <table id="grid1">
    </table>
    <%-- [20230410] 簽收附件 --%>
    <table id="grid2">
    </table>
	<table id="table2" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<%-- [20230410] 增加清空按鈕 --%>
		<tr>
			<td style="text-align:center;">
				<button type="button" id="btn_clear" class="button">清空</button>
			</td>
		</tr>
		<tr>
			<td width="100%" bgcolor="white" id="imageName"></td>
		</tr>
		<tr>
			<td width="100%" bgcolor="white" align="center" id="imageTd"></td>
		</tr>
	</table>
</form>
</body>
</html>