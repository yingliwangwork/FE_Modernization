
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB30600.jsp
作者：王文進
功能：火險轉帳作業。
完成：

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
var DSB30600 = new DSB30600();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB30600.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB30600(){
	//查詢的檢核
	var valid1;
	var valid2;
	var grid1;
	var grid2;
	var updateMap;
	//前次查詢條件
	var queryCondition = {BORROW_ID : ""};
				
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0004:"btn_update"<%--修改--%> 
		};
		
		<dz:grantButtons FUNC_ID="DSB30600" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){

	Validation.addAllThese([
		[ 'checkTRANS_STATUS',  '請選擇火險代扣變更，才能作業', 
			function(v,elm) {
				return !Validation.get('IsEmpty').test(v) || elm.selectedIndex > 0;
			}
		],
		[ 'checkREASON',  '請選擇變更原因，才能作業', 
			function(v,elm) {
				return !Validation.get('IsEmpty').test(v) || elm.selectedIndex > 0;
			}
		],
		[ 'checkMEMO',  '變更原因為其他，請輸入變更原因說明，才能作業', function(v,elm) {
			if(v=='' && $("REASON").value=='5'){
				return false;	
			}
			return true;
		}]
						
	]);

		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "checkROCID" , { id: "BORROW_ID" } );
		
		valid2 = new Validation("form2", {useTitles:true,focusOnError:false,immediate:false});
		valid2.define( "checkTRANS_STATUS" , { id: "TRANS_STATUS" } );
		valid2.define( "checkREASON" , { id: "REASON" } );
		valid2.define( "checkMEMO" , { id: "MEMO" } );
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB3_0600/" + actionName,
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
			
			$('BORROW_ID').value = $('BORROW_ID').value.toUpperCase();
			
			valid1.reset();
			//if(!valid1.validate()){ 
			if (!iscmpid($F('BORROW_ID')) && !validation.checkROCID($F('BORROW_ID'))) {
				alert('請輸入正確借款人ID來查詢');
				return; 
			}
			//將畫面欄位存成record
			var sendRecord = makeRecord();	
			//將查詢條件存起來
			queryCondition = sendRecord;	
			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){	
					grid1.load(resp.rtnList);
					grid2.load(resp.rtnList1);
					setViewData({});
					PageUI.resize(true);
				},
				function(resp){					
					//失敗把前次內容清掉 並把鑑價,支援人員list清掉
					grid1.load([]);
					grid2.load([]);
					setViewData({});
					PageUI.resize(true);
				}
			);		
		},		
		
		
		//修改
		doUpdate : function(event){	

			var checkupdateList = grid2.getCheckedRecord();
			if(!checkupdateList.length >0){
				alert("請先選取欲修改資料，才能作業!!");
				return;
			}

			valid2.reset();
			if(!valid2.validate()){ 
				return; 
			}

			//將畫面資料存成要派件或轉移的List
			updateMap["TRANS_STATUS"] = $('TRANS_STATUS').value;
			updateMap["REASON"] = $('REASON').value;
			updateMap["MEMO"] = $('MEMO').value;
			
			//發送ajax
			ajaxPost( 'update' , 
				{
					updateRecord : Object.toJSON(updateMap), //畫面勾選的records
					sendRecord : Object.toJSON(queryCondition) //上次查詢的條件		
				},
				function(resp){			
					//重查,並紀錄新的List			
					grid1.load(resp.rtnList ? resp.rtnList : []);
					grid2.load(resp.rtnList1 ? resp.rtnList1 : []);
					setViewData({});
					PageUI.resize(true);
				},
				function(resp){					
					//失敗把前次內容清掉 並把鑑價,支援人員list清掉
					grid1.load([]);
					grid2.load([]);
					setViewData({});
					PageUI.resize(true);
				}
			);	
		}
	}
	
	//將畫面A資料存成Record
	function makeRecord(){
		var sendRecord = {	
			BORROW_ID	: $('BORROW_ID').value.toUpperCase() //受理編號			
		}
		return sendRecord;	
	}
	
		/* 共用畫面設定 */
	function setViewData(rtnMap){
		$('APPLY_ID_VIEW').innerHTML = rtnMap.APPLY_ID ? rtnMap.APPLY_ID : '';
		$('BORROW_NAME_VIEW').innerHTML = rtnMap.BORROW_NAME ? rtnMap.BORROW_NAME : '';
		$('AGENT_ID_VIEW').innerHTML = rtnMap.AGENT_ID ? rtnMap.AGENT_ID : '';
		$('DIV_NAME_VIEW').innerHTML = rtnMap.DIV_NAME ? rtnMap.DIV_NAME : '';
		$('FIREINSU_POLNO_VIEW').innerHTML = rtnMap.FIREINSU_POLNO ? rtnMap.FIREINSU_POLNO : '';
		$('TEMP_POLNO_VIEW').innerHTML = rtnMap.TEMP_POLNO ? rtnMap.TEMP_POLNO : '';
		$('TRANS_STATUS_VIEW').innerHTML = rtnMap.TRANS_STATUS_NM ? rtnMap.TRANS_STATUS_NM : '';
		$('PAY_TYPE_VIEW').innerHTML = rtnMap.PAY_TYPE_NM ? rtnMap.PAY_TYPE_NM : '';
		$('DATE_TODAY_VIEW').innerHTML = rtnMap.APPLY_ID ? Date.toROC('<c:out value="${DATE_TODAY}"/>') : '';
		$('EMP_NM_VIEW').innerHTML = rtnMap.APPLY_ID ? '<c:out value="${EMP_NM}"/>' : '';
		$('TRANS_STATUS').value = '';
		$('REASON').value = '';
		$('MEMO').value = '';
		updateMap = rtnMap;
		valid2.reset();
		<%-- [20240613] 難字調整 --%>
		parseEUDC();
	}

	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSB30600", "火險作業", "火險轉帳作業", 1);
				PageUI.resize(true);

				grid1 = new TableUI ( {
					table: $("grid1"), pageSize: 10, allSortable:true,
					split: ['FIREINSU_POLNO'],
					<%-- [20240613] 難字調整 --%>
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{header: "原貸帳號",key: "REFER_ID", attrs:{rowSpan:2} ,
							render : function(rec , val){
								return 	val ? val : "";
							}
						},						
						{header: "續保年月 ",key: "PAYMENT_YM", attrs:{rowSpan:2} ,
							render : function(rec , val){
								return 	val ? eval(val.substring(0,val.length-3)-1911)+'/'+val.substring(val.length-2) : "";
							}
						},						
						{header: "扣款日",key: "TRANS_DATE", attrs:{rowSpan:2} ,
							render : function(rec , val){
								return val ? Date.toROC(val) : "";
							}
						},						
						{header: "貸款帳號",key: "LOAN_ID",
							render : function(rec , val){
								return 	val ? val : "";
							}
						},						
						<%-- [20240613] 難字調整：借款人姓名、輸入人員 --%>
						{header: "借款人姓名",key: "BORROW_NAME",attrs:{ style:"font-family:'EUDC'" },
							render : function(rec , val){
								return 	val ? val : "";														
							}
						},
						{header: "輸入人員",key: "INPUT_ID",attrs:{ style:"font-family:'EUDC'" },
							render : function(rec , val){
								return 	val ? val : "";														
							}
						},												
						{header: "輸入日期",key: "INPUT_DATE",
							render : function(rec , val){
								return val ? Date.toROC(val) : "0";
							}
						},
						{header: "扣款金額",key: "PAYMENT",
							render : function(rec , val){
								return 	val ? CSRUtil.$fmt(val, "#,##0") : "";
							}
						},
						{header: "扣款狀態",key: "TRANS_STATUS_NM",
							render : function(rec , val){
								return 	val ? val : "";														
							}
						},
						{header: "續保火單號碼",key: "FIREINSU_POLNO", attrs:{colSpan:2} ,
							render : function(rec , val){
								return 	val ? val : "";														
							}
						},
						<%-- [20240613] 難字調整：更新人員 --%>
						{header: "更新人員",key: "UPDATE_NAME",attrs:{ style:"font-family:'EUDC'" },
							render : function(rec , val){
								return 	val ? val : "";														
							}
						},												
						{header: "更新日期",key: "UPDATE_DATE",
							render : function(rec , val){
								return val ? Date.toROC(val) : "";
							}
						},
						{header: "扣款類別",key: "TRANS_TYPE_NM",
							render : function(rec , val){
								return 	val ? val : "";														
							}
						},
						{header: "管理費用",key: "SET_EXPENSE_NM",
							render : function(rec , val){
								return 	val ? CSRUtil.$fmt(val, "#,##0") : "";
							}
						}

					]
					
				});
				
				grid2 = new TableUI ( {
					table: $("grid2"), pageSize: 10, allSortable:true,
					autoCheckBox:{ type: "radio",
						action: function (checkbox , boxStatus , records) {
							setViewData(records[0]);
						}
					},
					column:[
						{header: "貸款帳號",key: "REFER_ID",
							render : function(rec , val){
								return 	val ? val : "";
							}
						}
					]
					
				});
				
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );		
				$("btn_update").observe("click", buttons.doUpdate );
				
				initValidation();	
				
				fix();

				displayMessage();				
						
				buttonAuth();

			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" width="20%" align="left" >
				借款人ID
			</td>
			<td class="tbYellow2" width = "50%">
				<input id="BORROW_ID" type="text" class="text2" size="12" maxlength="10" class="textBox" />				
			</td>
			<td class="tbYellow2"  align = "center">
				<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
			</td>
		</tr>
		<tr>
			<td colspan = "3" align = "center">
				<input id = "btn_update" type = "button" class = "button" value = "修改"/>
			</td>
		</tr>
	</table>
	</form>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" >
		<tr>
			<td class="tbYellow0" align="center">
				<span style="font-weight: bold;">火險代扣紀錄</span>
			</td>
		</tr>
		<tr>
			<td>
				<table id='grid1' width="100%"></table>
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" >
		<tr>
			<td class="tbYellow0" align="center">
				<span style="font-weight: bold;">火險代扣設定</span>
			</td>
		</tr>
		<tr>
			<td>
				<table id='grid2' width="100%"></table>
			</td>
		</tr>
	</table>
	<form id="form2" name="form2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id="tableA" name="tableA" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
		<tr>
			<td class="tbYellow">
				受理編號
			</td>
			<td class="tbYellow2" id="APPLY_ID_VIEW">
			</td>
			<td class="tbYellow">
				借款人
			</td>
			<%-- [20240613] 難字調整：借款人 --%>
			<td class="tbYellow2" colSpan="3" id="BORROW_NAME_VIEW" style="font-family:'EUDC'">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				經手人ID
			</td>
			<td class="tbYellow2" id="AGENT_ID_VIEW">
			</td>
			<td class="tbYellow">
				單位
			</td>
			<td class="tbYellow2" colSpan="3" id="DIV_NAME_VIEW">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				火單號碼
			</td>
			<td class="tbYellow2" id="FIREINSU_POLNO_VIEW">
			</td>
			<td class="tbYellow">
				暫保單號碼
			</td>
			<td class="tbYellow2" colSpan="3" id="TEMP_POLNO_VIEW">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				火險扣款狀態
			</td>
			<td class="tbYellow2" id="TRANS_STATUS_VIEW">
			</td>
			<td class="tbYellow">
				火險繳款方式
			</td>
			<td class="tbYellow2" colSpan="3" id="PAY_TYPE_VIEW">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				輸入日期
			</td>
			<td class="tbYellow2" id="DATE_TODAY_VIEW">
			</td>
			<td class="tbYellow">
				輸入人員
			</td>
			<%-- [20240613] 難字調整：輸入人員 --%>
			<td class="tbYellow2" colSpan="3" id="EMP_NM_VIEW" style="font-family:'EUDC'">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				火險代扣變更
			</td>
			<td class="tbYellow2">
				<select id="TRANS_STATUS">
					<option value=''>請選擇</option>
			       	<c:forEach var="map" items="${TRANS_STATUS_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>
			<td class="tbYellow">
				變更原因
			</td>
			<td class="tbYellow2">
				<select id="REASON">
					<option value=''>請選擇</option>
			       	<c:forEach var="map" items="${REASON_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>
			</td>
			<td class="tbYellow">
				變更原因說明
			</td>
			<td class="tbYellow2">
				<input type='text' size='20' maxlength='16' id="MEMO">
			</td>
		</tr>
	</table>
	</form>
</body>
</html>