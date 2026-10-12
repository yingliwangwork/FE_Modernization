<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA60500.jsp
功能：一般重要覆審明細表
作者：巫國慧
完成：2020/02/18
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" />
<!--匯入外部Javascript 與 css-->
<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSA60500().initApp);

function DSA60500(){
	
    var gridB,gridC
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA6_0500/');
	 
	var actions = {
		<%-- 取得查詢條件 --%>
		getQueryMap : function(){
			return {
				'INST_LEVEL':$F('INST_LEVEL'), <%-- 批示層級 --%>
				'INST_TYPE':$F('INST_TYPE'), <%-- 批示種類 --%>
				'REV_DEPT_CODE':$F('REV_DEPT_CODE'), <%-- 覆審科別 --%>
				'REV_YM':'${REV_YM}', <%-- 覆審月份 --%>
				'REV_TYPE':$F('REV_TYPE'), <%-- 覆審類別 --%>
				'REV_KIND':$F('REV_KIND') <%-- 案件種類 --%>
			};
		},
		<%-- 根據REV_TYPE顯示B區或是C區 --%>
		chooseAreaByRevType : function(rtnList){
			if('0'==$F('REV_TYPE')){
				$('divB').show();
				gridB.load(rtnList || []);
				$('divC').hide();
				gridC.load([]);
			}else{
				$('divC').show();
				gridC.load(rtnList || []);
				$('divB').hide();
				gridB.load([]);
			}
		},
		<%-- 根據REV_TYPE選擇資料(action => all:取得全部資料, checked:取得勾選資料) --%>
		chooseFieldByRevType : function(action){
			var tempGrid = ('0'==$F('REV_TYPE')) ? gridB : gridC;
			var tempRecord = ('all'==action) ? tempGrid.getAllRecords() : tempGrid.getCheckedRecord();
			return tempRecord;
		}
	};
	
	var buttons = {
		<%-- 全部同意 --%>
		doAllAgree : function(){
			var record = actions.chooseFieldByRevType('all');
			if(record.length==0){
				alert('目前無待審案件');
				return;
			}
			ajaxRequest.post(
				'allAgree', {'queryMap':Object.toJSON(actions.getQueryMap()), 'reqList':Object.toJSON(record)},
				function(resp){	
					actions.chooseAreaByRevType(resp.rtnList || []); <%-- 根據REV_TYPE顯示B區或是C區 --%>
				}
			);
		},
		<%-- 退回 --%>
		doReject : function(){
			var record = actions.chooseFieldByRevType('checked');
			if(record.length==0){
				alert('請勾選案件');
				return;
			}
			ajaxRequest.post(
				'reject', {'queryMap':Object.toJSON(actions.getQueryMap()), 'reqList':Object.toJSON(record)},
				function(resp){	
					actions.chooseAreaByRevType(resp.rtnList || []); <%-- 根據REV_TYPE顯示B區或是C區 --%>
				}
			);
		},
		<%-- 回待審件 --%>
		doBack : function(){
			CSRUtil.linkBack("<%=dispatcher%>/DSA2_1010/prompt?INST_LEVEL=${INST_LEVEL}&CRED_DEPT=${CRED_DEPT}");
		}
    };

	return{
		initApp : function(){
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay'/>
			PageUI.createPageWithAllBodySubElement(
				"DSA60500",
				"覆審作業",
				"${displayName}"
			);
			gridB = new TableUI({
                table: $("grid1"),
				autoCheckBox:{
						text:'選取', 
						type:'checkBox',
						isSelectAll:true
				},
				column:[	
					{header:"貸款帳號", key:'LOAN_ID',
						render:function(record, value){
							CSRUtil.keepParamsManager.put({'LOAN_ID': record.LOAN_ID });
							var alink = document.createElement("a");
							alink.href = "#";
							alink.innerHTML = record.LOAN_ID;
							alink.onclick = function(){
								var url = "<%=dispatcher%>/DSA6_0300/prompt";
				 				popupWin.windowOpen( url ,{
					        		'parameters': {'LOAN_ID' : record.LOAN_ID, 'REV_YM' : record.REV_YM},
					        		'windowName': 'DSA60300' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
					    		});
							};
							return alink;
						}	
					},
					{header:"借款人", key:'BORROW_NAME'},
					{header:"統一編號", key:'BORROW_ID'},
					{header:"擔保品地址", key:'GAGE_ADDR', attrs:{align:'left'}},
					{header:"覆審結果", key:'REV_RESULT_NAME'},
					{header:"說明", key:'REV_DESC', attrs:{align:'left'}}
				]
			});
			gridC = new TableUI({
                table: $("grid2"),
                split: ['REMAIN_AMT'],
                autoCheckBox:{
						text:'選取', 
						type:'checkBox',
						isSelectAll:true
				},
				column:[	
					{header:"原貸帳號", key:'REFER_ID',
						render:function(record, value){
							CSRUtil.keepParamsManager.put({'REFER_ID': record.REFER_ID });
							var alink = document.createElement("a");
							alink.href = "#";
							alink.innerHTML = record.REFER_ID;
							alink.onclick = function(){
								var url = "<%=dispatcher%>/DSA6_0400/prompt";
				 				popupWin.windowOpen( url ,{
					        		'parameters': {'REFER_ID' : record.REFER_ID, 'REV_YM' : record.REV_YM},
					        		'windowName': 'DSA60400' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
					    		});
							};
							return alink;
						}	
					},
					{header:"借款人", key:'BORROW_NAME', attrs:{rowSpan:2}},
					{header:"統一編號", key:'BORROW_ID', attrs:{rowSpan:2}},
					{header:"擔保品地址", key:'GAGE_ADDR', attrs:{colSpan:6, align:'left'}},
					{header:"覆審結果", key:'REV_RESULT_NAME', attrs:{rowSpan:2}},
					{header:"說明", key:'REV_DESC', attrs:{rowSpan:2, align:'left'}},
					{header:"本金餘額", key:'REMAIN_AMT', sortRule: 'number'},
					{header:"重估市價", key:'TOTAL_PRICE', sortRule: 'number'},
					{header:"覆審放款率", key:'REV_GA_RATE',
						render:function(record, value, i){
							if(!value && value!='0'){
								return '';
							}
							return localeDisplay.formatNumber(value, 0, false)+'%'; <%-- 最多顯示小數點後兩位 --%>
						}
					},
					{header:"市價比", key:'REALVALUE_RATE',
						render:function(record, value, i){
							if(!value && value!='0'){
								return '';
							}
							return localeDisplay.formatNumber(value, 0, false)+'%'; <%-- 最多顯示小數點後兩位 --%>
						}
					},
					{header:"繳息正常", key:'FINISH_KIND_INT_NM'},
					{header:"債權確保", key:'FINISH_KIND_DEB_NM'}
				]
			});
			
			<%-- 按鈕事件監聽 --%>
			$('btn_allAgree').observe('click', buttons.doAllAgree); <%-- 全部同意 --%>
			$('btn_reject').observe('click', buttons.doReject); <%-- 退回 --%>
			$('btn_back').observe('click', buttons.doBack); <%-- 回待審件 --%>
			
			var rtnList = <c:out value='${rtnList}' escapeXml='false' default='[]'/>
			actions.chooseAreaByRevType(rtnList); <%-- 根據REV_TYPE顯示B區或是C區 --%>
			
			displayMessage();
		}	
		
	};
}
</script>
</head>
<body>
<form name='form1' id='form1'>
<input id='INST_LEVEL' name='INST_LEVEL' type='hidden' value='${INST_LEVEL}'/> <%-- 批示層級 --%>
<input id='INST_TYPE' name='INST_TYPE' type='hidden' value='${INST_TYPE}'/> <%-- 批示種類 --%>
<input id='REV_DEPT_CODE' name='REV_DEPT_CODE' type='hidden' value='${REV_DEPT_CODE}'/> <%-- 覆審科別 --%>
<input id='REV_TYPE' name='REV_TYPE' type='hidden' value='${REV_TYPE}'/> <%-- 覆審類別 --%>
<input id='REV_KIND' name='REV_KIND' type='hidden' value='${REV_KIND}'/> <%-- 案件種類 --%>
<%-- A區 --%>
<table width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">覆審科別</td>
		<td class="tbYellow2" width="15%">${REV_DEPT_CODE_NAME}</td>
		<td class="tbYellow" width="10%">覆審年月</td>
		<td class="tbYellow2" width="65%" colSpan="2">${REV_YM}</td>
	</tr>
	<tr>
		<td align='center' colSpan="4"> 
			<button id="btn_allAgree" type="button" class="button">全部同意</button>
			<button id="btn_reject" type="button" class="button">退回</button>
		</td>
		<td align='right' width="10%">
			<button id="btn_back" type="button" class="button">回待審件</button>
		</td>
	</tr>
</table>
<%-- B區 --%>
<div id='divB'>
	<table id="grid1" class="grid"></table>
</div>
<%-- C區 --%>
<div id='divC'>
	<table id="grid2" class="grid"></table>
</div>
</form>
</body>
</html>