<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB50400.jsp
作者：王文進
功能：退匯明細查詢。
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
var DSB50400 = new DSB50400();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB50400.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB50400(){
	
	var grid;
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			
		};
		
		<dz:grantButtons FUNC_ID="DSB50400" ignored="false"/>
	}
	
	//檢核變數
	var valid1;	
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'checkDate',  '請輸入退匯日期查詢!',
				function(v){
					return 	v.length==0 ? false : true;
				}
			]
		]);
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "checkACNT_DATE" , { id: "FAIL_DATE" } );
	}    

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB5_0400/" + actionName,
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
					rtnList = resp.rtnList ? resp.rtnList : [];
					sumTotalList = resp.sumTotalList ? resp.sumTotalList : [];
					grid.load(rtnList,sumTotalList);
					$("DEPT_BANK").innerHTML = resp.DEPT_BANK ? resp.DEPT_BANK : '';
				},
				function(resp){
					//失敗把前次內容清掉 
					grid.load([],[]);
				}
			);		
		},
		
		// 列印
		doPrint: function() {
			var records = grid.getAllRecords();
			
			var sendRecord = makeRecord();
			
			window.open("", "DSB5_0401", "top=50, left=50,  toolbar=no, resizable=yes, location=0, status=0, scrollbars=1, titlebar=0, width=800, height=600");
			
			var url = "<%=dispatcher%>/DSB5_0401/prompt";			
			var form = $('form1');
			form.target='DSB5_0401';
			form.action=url;
			$('queryData').value = Object.toJSON(sendRecord);		
			form.submit();
		}

	};
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {};
		sendRecord.CRED_DEPT	= $('CRED_DEPT').value; // 結帳單位
		sendRecord.FAIL_DATE	= toY2K($('FAIL_DATE').value); // 畫面上之退匯日期(起)
		sendRecord.REMIT_KIND   = $('REMIT_KIND').value; // 結帳單位
		return sendRecord;	
	}			
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB50400", "匯款作業", "退匯明細查詢", 1);			
					
				grid = new TableUI ( {
						table:$("grid"), pageSize: 20, allSortable:true , split:["RTNRMT_RESN_NAME"],
						<%-- [20240613] 難字調整 --%>
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{header: "受理編號",key: "APPLY_ID", attrs:{rowSpan:2}, 
								render : function (rec , val){
									return val ? val: '';
								}							
							},
							{header: "匯款金額",key: "REMIT_AMT", attrs:{rowSpan:2, align:'right'},
								render : function (rec , val){
									return val ? CSRUtil.$fmt(val, CSRUtil.defaultPattern) : '0';
								}							
							},
							{header: "匯款帳號/行庫",key: "ACNT",
								render : function (rec , val){
									return val ? val: '';
								}							
							},
							<%-- [20240613] 難字調整：匯款戶名 --%>
							{header: "匯款戶名",key: "ACCOUNT_NAME",attrs:{ style:"font-family:'EUDC'" },
								render : function (rec , val){
									return val ? val: '';
								}							
							},
							{header: "匯款種類",key: "REMIT_TYPE_NM", attrs:{rowSpan:2}, 
								render : function (rec , val){
									return val ? val: '';
								}							
							},
							{header: "結帳種類",key: "FAIL_TYPE_NM", attrs:{rowSpan:2}, 
								render : function (rec , val){
									return val ? val: '';
								}							
							},
							{header: "結帳序號",key: "ACNT_FAIL_NO", attrs:{rowSpan:2}, 
								render : function (rec , val){
									return val ? val: '';
								}							
							},
							{header: "匯款方式",key: "REMIT_KIND_NM", attrs:{rowSpan:2}, 
								render : function (rec , val){
									return val ? val: '';
								}							
							},
							<%-- [20240613] 難字調整：輸入人員 --%>
							{header: "輸入人員",key: "FAIL_INPUT_NM",attrs:{ style:"font-family:'EUDC'" },
								render : function (rec , val){
									return val ? val: '';
								}							
							},
							{header: "輸入日期",key: "FAIL_INPUT_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							},
							{header: "退匯原因",key: "RTNRMT_RESN_NAME", attrs:{colSpan:2}, 
								render : function (rec , val){
									return val ? val: '';
								}							
							},
							<%-- [20240613] 難字調整：結帳人員 --%>
							{header: "結帳人員",key: "ACNT_FAIL_NM",attrs:{ style:"font-family:'EUDC'" },
								render : function (rec , val){
									return val ? val: '';
								}							
							},
							{header: "結帳日期",key: "ACNT_FAIL_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							}
						]
					});
			
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );
				
				// 監聽: 列印
				$("BTN_0005").observe('click', buttons.doPrint );
				
				initValidation();	
				
				fix();

				displayMessage();	
				
				buttonAuth();
				
				$("CRED_DEPT").value = '${CRED_DEPT}';
				
				var LP_JSON = CSRUtil.isBackLink('form1');
				if(LP_JSON){
					buttons.doQuery();
				}

			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="12%">
					退匯日期
				</td>
				<td class="tbYellow2">
					<input type="hidden" id="queryData" name="queryData" value="">
					<input name="FAIL_DATE" id='FAIL_DATE' type="text" class="textBox2 checkDate validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="">
					<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('FAIL_DATE'))">
				</td>
				<td class="tbYellow" width="15%">
					匯款單位
				</td>
				<td class="tbYellow2">
					<select name="CRED_DEPT" id="CRED_DEPT">
						<c:if test="${CRED_DEPT_ALL eq true}">
							<option value="">全部</option> 
						</c:if>
						<c:forEach var="map" items="${CRED_DEPT_LIST}">
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="15%">
					匯款方式
				</td>
				<td class="tbYellow2">
					<select name="REMIT_KIND" id="REMIT_KIND">
						<option value="">全部</option>
						<c:forEach var="map" items="${REMIT_KIND_LIST}">
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow2">
					<input type="button" class="button" id="btn_query" value="查詢">
					<input id="BTN_0005" type="button" value='列印' class="button">
				</td>
			</tr>
		</table>
	</form>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td class="tbYellow0" align="left"><B>匯款行庫:</B><B id="DEPT_BANK"></B>&nbsp;</td>								
		</tr>
		<tr>
			<td>
				<table id='grid' width="100%"></table>
			</td>
		</tr>
	</table>
	<font color="red"><b>※匯款單位：107/11/27以後，係以匯款單位歸屬；107/11/26以前，係以案件承辦科別歸屬</b></font>
</body>
</html>