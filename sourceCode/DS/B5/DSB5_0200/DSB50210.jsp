<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB50210.jsp
作者：王文進
功能：匯款派件統計。
完成：2012/05/22

[20240613]
難字調整
高強禾
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<%-- [20240613] 難字調整 --%>
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

// 產生畫面物件
var DSB50210 = new DSB50210();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB50210.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB50210(){
	
	var grid;

		//按鈕權限
	function buttonAuth(){
		var authButtons = {
			
		};
		
		<dz:grantButtons FUNC_ID="DSB50210" ignored="false"/>
	}


	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB5_0210/" + actionName,
			{  
				parameters: params, 
				onSuccess:function(response){
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){	
						if(successFunction){
							successFunction(resp);
						}
					}else{
						if(errorFunction){
							errorFunction(resp);
						}
					}
				}			
			});
	}	
	
	//buttons對應的event function
	var buttons = {	
		
		//查詢資料
		doQuery : function(event){	
			
			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){
					grid.load(resp.rtnList);				
				},
				function(resp){
					//失敗把前次內容清掉 
					grid.load([]);
				}
			);		
		}

	};
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {};
		sendRecord.ACNT_NO	= '${ACNT_NO}';//結帳序號
		sendRecord.ACNT_DATE = '${ACNT_DATE}';//結帳日期
		sendRecord.CRED_DEPT = '${CRED_DEPT}';//結帳單位
		sendRecord.REMIT_KIND = '${REMIT_KIND}';//匯款方式
		sendRecord.ACNT_STR_DATE = '${ACNT_STR_DATE}';//結帳日期(起)
		sendRecord.ACNT_END_DATE = '${ACNT_END_DATE}';//結帳日期(迄)
		sendRecord.IS_BORROW_NEW = '${IS_BORROW_NEW}';//是否為借新還舊
		return sendRecord;
	}
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB50210", "匯款作業", "新放結帳明細", 1);			
					
				grid = new TableUI ( {
						table:$("grid"), pageSize: 10, allSortable:true ,
						split: ['LOAN_ID'],
						<%-- [20240613] 難字調整 --%>
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							//[20201022]新增暫收編號
							{header: "受理編號 / 暫收編號",key: "APPLY_ID",
								render : function (rec , val){
									return (val || '') + ' / ' + (rec.BALC_NO || '');
								}							
							},
							{header: "匯款種類",key: "REMIT_TYPE_NM",
								render : function (rec , val){
									return val ? val : '';
								}							
							},
							{header: "匯款帳號",key: "REMIT_ACCOUNT_NM", attrs:{ rowSpan:2 },
								render : function (rec , val){
									return val ? val : '';
								}							
							},
							<%-- [20240613] 難字調整：匯款戶名 --%>
							{header: "匯款戶名",key: "ACCOUNT_NAME", attrs:{ rowSpan:2, style:"font-family:'EUDC'" },
								render : function (rec , val){
									return val ? val : '';
								}							
							},
							{header: "代償單位",key: "COMP_DIV_NM", attrs:{ rowSpan:2 },
								render : function (rec , val){
									return val ? val : '';
								}							
							},
							{header: "貸款帳號",key: "LOAN_ID",
								render : function (rec , val){
									return val ? '<font color=green>'+val+'</font>' : '';
								}							
							},
							{header: "匯款金額",key: "REMIT_AMT",
								render : function (rec , val){
									return val ? CSRUtil.$fmt(val, CSRUtil.defaultPattern) : '0';
								}							
							}
						]
					});	
				
				fix();

				displayMessage();	
				
				buttonAuth();
				
				$("DEPT_BANK_VIEW").innerHTML = '${DEPT_BANK}' ? '${DEPT_BANK}' : '0';
				$("ACNT_NO_VIEW").innerHTML = '${ACNT_NO}' ? '${ACNT_NO}' : '';
				$("ACNT_DATE_VIEW").innerHTML = '${ACNT_DATE}' ? Date.toInputROC('${ACNT_DATE}' || "","/") : '';
				$("ACNT_CNT_VIEW").innerHTML = '${ACNT_CNT}' ? CSRUtil.$fmt('${ACNT_CNT}', CSRUtil.defaultPattern) + '件' : '0' + '件';
				$("ACNT_AMT_VIEW").innerHTML = '${ACNT_AMT}' ? CSRUtil.$fmt('${ACNT_AMT}', CSRUtil.defaultPattern) + '元' : '0' + '元';
				
				buttons.doQuery()
				
				// 回上頁按鈕
				$("btn_back").observe('click', function(event){
						CSRUtil.linkBack();
					}
				);

			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="10%">匯款行庫</td>
				<td class="tbYellow2" width="20%" id="DEPT_BANK_VIEW"></td>
				<td class="tbYellow" width="10%">結帳序號</td>
				<td class="tbYellow2" width="5%" id="ACNT_NO_VIEW"></td>
				<td class="tbYellow" width="10%">結帳日期</td>
				<td class="tbYellow2" width="10%" id="ACNT_DATE_VIEW"></td>
				<td class="tbYellow" width="10%">結帳件數</td>
				<td class="tbYellow2" width="5%" align="right"><font color=red id="ACNT_CNT_VIEW"></font></td>
				<td class="tbYellow" width="10%">結帳金額</td>
				<td class="tbYellow2" width="10%" align="right"><font color=red id="ACNT_AMT_VIEW"></font></td>
			</tr>
		</table>
	</form>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow">
				<table id='grid' width="100%"></table>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="center">
				<input type="button" id="btn_back" value="回上頁" class="button">
			</td>
		</tr>
	</table>
</body>
</html>