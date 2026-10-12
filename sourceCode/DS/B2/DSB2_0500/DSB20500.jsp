<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB20500.jsp
作者：王文進
功能：匯款派件作業。
完成：2012/05/18
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<%-- [20240607] 難字調整 --%>
<style type="text/css"> 
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>

<script type='text/javascript'>

// 產生畫面物件
var DSB20500 = new DSB20500();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB20500.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB20500(){
	
	var grid;
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0067:"btn_send"<%--派件--%>
		};
		
		<dz:grantButtons FUNC_ID="DSB20500" ignored="false"/>
	}
	
	//檢核變數
	var valid1;	
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'checkAPPLY_ID',  '請輸入受理編號再執行查詢', 
				function(v){				
					return 	$('QUERY_TYPE1').checked && v == '' ? false : true;
				}
			],
			[ 'validateAPPLY_IDLength',  '受理編號長度不正確 需為11碼', 
				//檢核受理編號長度
				function(v){
					if($('QUERY_TYPE1').checked && v!==""){
						return v.length === 11 ? true : false;
					}
					return true;
				}
			]
		]);
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "checkAPPLY_ID" , { id: "APPLY_ID" } );
		valid1.define( "validateAPPLY_IDLength" , { id: "APPLY_ID" } );
	}    

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB2_0500/" + actionName,
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
		
		    if($('QUERY_TYPE1').checked){
				$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			}
			
			valid1.reset();
			if(!valid1.validate()){
				return;			
			}
			
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
		},
		
		//確認
		doSend : function(event){	
			
			var checkRecords = grid.getCheckedRecord();
			if(!checkRecords.length >0){
				alert("請先勾選欲派件資料，才能作業");
				return;
			}
			
			var sendRecord = makeRecord();
			sendRecord.REMIT_ID	= $('REMIT_ID').value;
			sendRecord.SUPPORT_REMIT_ID	= $('SUPPORT_REMIT_ID').value;

			//發送ajax
			ajaxPost( 'send' , { sendRecord : Object.toJSON(sendRecord) ,checkRecords : Object.toJSON(checkRecords) },
				function(resp){
					grid.load(resp.rtnList);	
				}
			);		
		}

	};
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {}
		if($('QUERY_TYPE1').checked){
			// 受理編號
			sendRecord.QUERY_TYPE	= $('QUERY_TYPE1').value;
			sendRecord.APPLY_ID	= $('APPLY_ID').value;
		}else if($('QUERY_TYPE2').checked){
			sendRecord.QUERY_TYPE	= $('QUERY_TYPE2').value; // 查詢單位
			sendRecord.REMIT_STATUS	= $('REMIT_STATUS').value; // 派件狀態
			sendRecord.CRED_ID	= $('CRED_ID').value; // 徵信人員
		}
		return sendRecord;	
	}			
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB20500", "匯款文件", "匯款派件作業", 1);			
				grid = new TableUI ( {
						table:$("grid"), pageSize: 10, allSortable:true ,
						split: ["APPLY_PROCESS_NM"],
						autoCheckBox:{ type: "checkbox", text:'選取', isSelectAll: true },
						<%-- [20240607] 難字調整 --%>
			            pageChange: function() {
			            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
			            },
						column:[
							{header: "受理編號",key: "APPLY_ID"},
							<%-- [20240607] 難字調整 --%>
							{header: "借款人",key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
							{header: "貸款種類",key: "LOAN_TYPE_NM"},
							{header: "送件日期",key: "SEND_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							},
							<%-- [20240607] 難字調整 --%>
							{header: "徵信人員",key: "CRED_NAME", attrs:{rowSpan:2}, attrs:{ style:"font-family:'EUDC'" }},
							<%-- [20240607] 難字調整 --%>
							{header: "匯款人員",key: "REMIT_NAME", attrs:{ style:"font-family:'EUDC'" }},
							{header: "受理進度",key: "APPLY_PROCESS_NM"},
							{header: "擔保品地址",key: "GAGE_ADDR", attrs:{colSpan:2}},
							{header: "核准日期",key: "AGREE_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							}
						]
					});
			
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );
				$("btn_send").observe("click", buttons.doSend );
				
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
				<td class="tbYellow" width="10%">
					<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE2' value=2 checked>徵信人員
				</td>
				<td class="tbYellow2">
					<%-- [20240607] 難字調整 --%>
					<select name="CRED_ID" id="CRED_ID" alt="ch">
						<option value=''>全部</option>
						<c:forEach var="map" items="${CRED_LIST}">
							<option value='${map.ID}'>${map.NAME}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="10%">
					派件狀態
				</td>
				<td class="tbYellow2">
					<select name="REMIT_STATUS" id="REMIT_STATUS">
						<option value=''>全部</option>
						<c:forEach var="map" items="${REMIT_STATUS_LIST}">
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow2" align="center" rowspan="2">
					<input type="button" class="button" id="btn_query" value="查詢">
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%">
					<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE1' value=1>受理編號
				</td>
				<td class="tbYellow2" colspan="3">
					<input type="text" class="textBox2" size="15" maxlength="11" id="APPLY_ID" value="">
				</td>
			</tr>
			<tr>
				<td align="center" colspan="7">
					<input type="button" class="button" id="btn_send" value="派件">
				</td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="10%">
					新匯款人員
				</td>
				<td class="tbYellow2" align="left">
					<%-- [20240607] 難字調整 --%>
					<select name="REMIT_ID" id="REMIT_ID" alt="ch">
						<option value=''></option>
						<c:forEach var="map" items="${REMIT_LIST}">
							<option value='${map.ID}'>${map.NAME}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="10%">
					WORKCELL匯款支援人員
				</td>
				<td class="tbYellow2" align="left">
					<%-- [20240607] 難字調整 --%>
					<select name="SUPPORT_REMIT_ID" id="SUPPORT_REMIT_ID" alt="ch">
						<option value=''></option>
						<c:forEach var="map" items="${SUPPORT_REMIT_LIST}">
							<option value='${map.ID}'>${map.NAME}</option>
						</c:forEach>
					</select>
				</td>
			</tr>
		</table>
	</form>	
	<table id='grid' width="100%"></table>	
</body>
</html>