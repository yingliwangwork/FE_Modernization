<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB20600.jsp
作者：王文進
功能：匯款派件統計。
完成：2012/05/22
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
var DSB20600 = new DSB20600();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB20600.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB20600(){
	
	var grid;
	var grid1;
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0067:"btn_confirm"<%--派件--%>
		};
		
		<dz:grantButtons FUNC_ID="DSB20600" ignored="false"/>
	}
	
	//檢核變數
	var valid1;	
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'checkDate',  '請輸入派件日期再執行查詢',
				function(v){
					return 	$('QUERY_TYPE2').checked && v.length==0 ? false : true;
				}
			],
			[ 'checkREMIT1_DATE',  '派件日期起日大於迄日',
				function(v){
					return 	$('QUERY_TYPE2').checked && diffDay($F('REMIT_ASSIGN_DATE_STR'),$F('REMIT_ASSIGN_DATE_END'), true) < 0 ? false : true;
				}
			]
		]);
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "checkREMIT1_DATE" , { id: "REMIT_ASSIGN_DATE_STR" } );
	}    

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB2_0600/" + actionName,
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
			
			valid1.reset();
			if(!valid1.validate()){
				return;			
			}
			
			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){
					grid.load(resp.rtnList);
					grid1.load([]);					
				},
				function(resp){
					//失敗把前次內容清掉 
					grid.load([]);
					grid1.load([]);
				}
			);		
		},
		//查詢資料
		doQuery1 : function(obj){	

			var sendRecord = makeRecord();
			sendRecord.REMIT_ID = obj['REMIT_ID'];
			sendRecord.QUERY_TYPE = obj['QUERY_TYPE'];

			//發送ajax
			ajaxPost( 'query1' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){
					grid1.load(resp.rtnList);
				},
				function(resp){
					//失敗把前次內容清掉 
					grid1.load([]);
				}
			);		
		}

	};
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {'CRED_DEPT':'${CRED_DEPT}'};
		if($('QUERY_TYPE1').checked){
			sendRecord.QUERY_TYPE	= $('QUERY_TYPE1').value;//	已派件查詢
			sendRecord.REMIT_ID	= $('REMIT_ID_1').value;
		}else if($('QUERY_TYPE2').checked){
			sendRecord.QUERY_TYPE	= $('QUERY_TYPE2').value; // 已匯款件查詢
			sendRecord.REMIT_ID	= $('REMIT_ID_2').value; // 匯款人員
			sendRecord.REMIT_ASSIGN_DATE_STR	= toY2K($('REMIT_ASSIGN_DATE_STR').value); // 畫面上之派件日期(起)
			sendRecord.REMIT_ASSIGN_DATE_END	= toY2K($('REMIT_ASSIGN_DATE_END').value); // 畫面上之派件日期(迄)
		}
		return sendRecord;	
	}			
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB20600", "匯款文件", "匯款派件統計", 1);			
				grid = new TableUI ( {
						table:$("grid"), pageSize: 10, allSortable:true ,
						autoCheckBox:{ type: 'radio', text:'選取',
							action: function (checkbox , boxStatus , records) {
								buttons.doQuery1(records[0])							
							}
						},
						<%-- [20240607] 難字調整 --%>
			            pageChange: function() {
			            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
			            },
						column:[
							<%-- [20240607] 難字調整 --%>
							{header: "匯款人員",key: "REMIT_NAME", attrs:{ style:"font-family:'EUDC'" }},
							{header: "件數",key: "CNT", sortRule:'number',
								render : function (rec , val){
									return CSRUtil.$fmt(val, CSRUtil.defaultPattern);
								}							
							}
						]
					});
					
				grid1 = new TableUI ( {
						table:$("grid1"), pageSize: 10, allSortable:true ,
						<%-- [20240607] 難字調整 --%>
			            pageChange: function() {
			            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
			            },
						column:[
							{header: "受理編號",key: "APPLY_ID"},
							<%-- [20240607] 難字調整 --%>
							{header: "借款人",key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
							<%-- [20240607] 難字調整 --%>
							{header: "徵信人員",key: "CRED_NAME", attrs:{ style:"font-family:'EUDC'" }},
							{header: "送件日期",key: "SEND_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							},
							{header: "核准日期",key: "AGREE_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							},
							{header: "匯款派件日期",key: "REMIT_ASSIGN_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							},
							<%-- [20240607] 難字調整 --%>
							{header: "匯款人員",key: "REMIT_NAME", attrs:{ style:"font-family:'EUDC'" }},
							{header: "貸款種類",key: "LOAN_TYPE_NM"}
						]
					});
			
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );
				
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
				<td class="tbYellow" width="15%">
					<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE1' value=1 checked>已派件查詢
				</td>
				<td class="tbYellow" width="15%">
					匯款人員
				</td>
				<td class="tbYellow2" colspan="3">
					<%-- [20240607] 難字調整 --%>
					<select name="REMIT_ID_1" id="REMIT_ID_1" alt="ch">
						<option value=''>全部</option>
						<c:forEach var="map" items="${REMIT_LIST}">
							<option value='${map.ID}'>${map.NAME}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow2" align="center" rowspan="2">
					<input type="button" class="button" id="btn_query" value="查詢">
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">
					<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE2' value=2>已匯款件查詢
				</td>
				<td class="tbYellow" width="15%">
					匯款人員
				</td>
				<td class="tbYellow2">
					<%-- [20240607] 難字調整 --%>
					<select name="REMIT_ID_2" id="REMIT_ID_2" alt="ch">
						<option value=''>全部</option>
						<c:forEach var="map" items="${REMIT_LIST}">
							<option value='${map.ID}'>${map.NAME}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="12%">
					派件日期
				</td>
				<td class="tbYellow2">
					<input name="REMIT_ASSIGN_DATE_STR" id='REMIT_ASSIGN_DATE_STR' type="text" class="textBox2 checkDate validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${REMIT_ASSIGN_DATE_STR}">
					<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('REMIT_ASSIGN_DATE_STR'))">
					~
					<input name="REMIT_ASSIGN_DATE_END" id='REMIT_ASSIGN_DATE_END' type="text" class="textBox2 checkDate validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${REMIT_ASSIGN_DATE_END}">
					<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('REMIT_ASSIGN_DATE_END'))">
				</td>
			</tr>
		</table>
	</form>	
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow0" align="center"><B>統計資料</B></td>
		</tr>
		<tr>
			<td>
				<table id='grid' width="100%"></table>
			</td>
		</tr>
		<tr>
			<td class="tbYellow0" align="center"><B>明細資料</B></td>	
		</tr>
		<tr>
			<td>
				<table id='grid1' width="100%"></table>
			</td>
		</tr>
	</table>
</body>
</html>