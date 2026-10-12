<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB50200.jsp
作者：王文進
功能：新放結帳明細。
完成：2012/05/22
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

<script type='text/javascript'>

// 產生畫面物件
var DSB50200 = new DSB50200();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB50200.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB50200(){
	
	var grid;
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			
		};
		
		<dz:grantButtons FUNC_ID="DSB50200" ignored="false"/>
	}
	
	//檢核變數
	var valid1;	
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'checkDate',  '請輸入結帳日期查詢!',
				function(v){
					return 	v.length==0 ? false : true;
				}
			],
			[ 'checkACNT_DATE',  '終止日期需大於起始日期，請檢查後重新輸入查詢條件!',
				function(v){
					return 	diffDay($F('ACNT_STR_DATE'),$F('ACNT_END_DATE'), true) < 0 ? false : true;
				}
			],
			[ 'checkArea',  '查詢區間不得超過三個月!',
				function(v){
					return 	diffDay($F('ACNT_STR_DATE'),$F('ACNT_END_DATE'), true) > 90 ? false : true;
				}
			]
		]);
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "checkACNT_DATE" , { id: "ACNT_STR_DATE" } );
		valid1.define( "checkArea" , { id: "ACNT_STR_DATE" } );
	}    

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB5_0200/" + actionName,
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
					grid.load(rtnList, sumTotalList);
				},
				function(resp){
					//失敗把前次內容清掉 
					grid.load([], []);
				}
			);		
		}

	};
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {};
		sendRecord.CRED_DEPT	= $('CRED_DEPT').value; // 結帳單位
		sendRecord.ACNT_STR_DATE	= toY2K($('ACNT_STR_DATE').value); // 畫面上之結帳日期(起)
		sendRecord.ACNT_END_DATE	= toY2K($('ACNT_END_DATE').value); // 畫面上之結帳日期(迄)
		return sendRecord;	
	}			
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB50200", "匯款作業", "新放結帳明細", 1);			
					
				grid = new TableUI ( {
						table:$("grid"), pageSize: 20, allSortable:true ,
						column:[
							{header: "結帳序號",key: "ACNT_NO",
								render : function (rec , val){
									var alink = document.createElement("a");
									alink.href = "#";
									alink.innerHTML = val ? val : '';
									alink.onclick = function(){
										var LP_JSON = {
											action:'<%=dispatcher%>/DSB5_0210/prompt',							
											LINK_FROM:'DSB50200', 
											ACNT_NO:rec.ACNT_NO, 
											ACNT_DATE:rec.ACNT_DATE,
											ACNT_CNT:rec.ACNT_CNT,
											ACNT_AMT:rec.ACNT_AMT,
											CRED_DEPT:rec.CRED_DEPT,
											IS_BORROW_NEW:rec.IS_BORROW_NEW,		
											REMIT_KIND:rec.REMIT_KIND,											
											ACNT_STR_DATE:toY2K($('ACNT_STR_DATE').value),
											ACNT_END_DATE:toY2K($('ACNT_END_DATE').value)
										};
										CSRUtil.linkTo(LP_JSON, 'form1');
									};
									return alink;
								}							
							},
							{header: "匯款科別",key: "CRED_DEPT_NM"},
							{header: "匯款覆核日期",key: "ACNT_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							},
							{header: "匯款種類",key: "REMIT_KIND_NM"},
							{header: "結帳件數",key: "ACNT_CNT",
								render : function (rec , val){
									return val ? CSRUtil.$fmt(val, CSRUtil.defaultPattern)+'件' : '0';
								}							
							},
							{header: "結帳金額",key: "ACNT_AMT",
								render : function (rec , val){
									return val ? CSRUtil.$fmt(val, CSRUtil.defaultPattern)+'元' : '0';
								}							
							}
						]
					});
			
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );
				
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
				<td class="tbYellow" width="12%">
					匯款日期
				</td>
				<td class="tbYellow2">
					<input name="ACNT_STR_DATE" id='ACNT_STR_DATE' type="text" class="textBox2 checkDate validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${ACNT_STR_DATE}">
					<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('ACNT_STR_DATE'))">
					~
					<input name="ACNT_END_DATE" id='ACNT_END_DATE' type="text" class="textBox2 checkDate validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${ACNT_END_DATE}">
					<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('ACNT_END_DATE'))">
				</td>
				<td class="tbYellow2">
					<input type="button" class="button" id="btn_query" value="查詢">
				</td>
			</tr>
		</table>
	</form>	
	<table id='grid' width="100%"></table>
	<font color="red"><b>※匯款單位：107/11/27以後，係以匯款單位歸屬；107/11/26以前，係以案件承辦科別歸屬</b></font>
</body>
</html>