<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC50500.jsp
功能：新件利率QC 
作者：溫子?
完成：2013/05
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>		<%-- 匯出檔案用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<%--[20241101]難字css  --%>
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
Event.observe(window, 'load', new DSC50500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC50500(){
var grid;
var reqMap_rc;//查詢條件
	function initValidation(){		
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});	
		valid1.define( "required" , { id: "LOAN_DATES" , errMsg:"貸放日期起不得為空" } );
		valid1.define( "required" , { id: "LOAN_DATEE" , errMsg:"貸放日期迄不得為空" } );
		valid1.define('validate-selection' , [{ id : "CRED_DEPT" , errMsg:"請選擇區域"}] );
		valid1.define( "validate-ROCDate-Interval" , [{ id : "LOAN_DATES" , errMsg :"貸放日期迄日需大於貸放起始日期，請檢查後重新輸入查詢條件!" },{ id : "LOAN_DATEE" , errMsg :"貸放日期迄日需大於貸放起始日期，請檢查後重新輸入查詢條件!"}] );
		
	}
	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSC5_0500/" + actionName,
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

		var buttons={
			getMap : function(){
				return {			
					CRED_DEPT : $F('CRED_DEPT'),
					LOAN_DATES :$F('LOAN_DATES'),
					LOAN_DATEE : $F('LOAN_DATEE')
				}	
			
			}
			,doQuery : function (){
			
				if(!valid1.validate()){
					return;
				}
				if(diffDay($F('LOAN_DATES'),$F('LOAN_DATEE'))>15){
					alert("起訖日不得超過15日!");
					return;
				}
			
				reqMap_rc=buttons.getMap();	
				ajaxPost( 'query', {reqMap : Object.toJSON(reqMap_rc)}
				,function(resp){
					grid.load(resp.rtnList);
				}
			);
			
			}
			,doExport : function (){
				if( grid.getAllRecords().length == 0 ){
					alert('請先查詢再匯出');
					return;
				};
				
				
				//匯出時，查詢條件 與頁面條件是否相等
				var tempCondition = buttons.getMap();
				for(key in tempCondition){
					if(tempCondition[key] != reqMap_rc[key]){
						alert('與查詢時條件不同，請重新查詢');
						return;
					}				
				}
				
					var exportParams = {
					querycondition : Object.toJSON(reqMap_rc),
					gridJSON : grid.getXlsSettingJSON("新件授信條件QC"),
					isExport : "Y"
				}
				
				RPTUtil.executeCreateXlsFile("<%=dispatcher%>/DSC5_0500/export", exportParams );
				}
		
		}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC50500', '利率計算', '新件授信條件QC');
				
				grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true,			
				<%--[20241101] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[			
					{header:"序號", key:"SER_NO"},
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"借款人ID",key:"BORROW_ID"},
					{header:"借款人姓名",key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"}},
					{header:"優惠種類",key:"PREFER_TYPE_NM"},
					{header:"地區",key:"AREA_CODE_NM"},
					{header:"客戶等級",key:"VIP_GRADE_NM"},
					{header:"表定利率",key:"INTEREST_C"},
					{header:"擬准利率",key:"INTEREST"},
					{header:"實際貸放利率(第一期)",key:"RATE"},
					{header:"個案加減碼",key:"SPEC_RATE"},
					{header:"保戶123",key:"INSU_NOTE_NM"},
					{header:"提前清償違約金",key:"RENEGE"}
					
				]
				});
				initValidation();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$("BTN_EXPORT").observe('click', buttons.doExport);
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
			}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
	<td class="tbYellow" width="15%" >區域</td>
			<td class="tbYellow2" width="15%" >
				<select id="CRED_DEPT">
						<option value="">請選擇</option>
							<c:forEach var="map" items="${CRED_DEPT_List}">
									<option value="${map.key}">${map.value}</option>
							</c:forEach>
				</select> 
	</td>
	<td class="tbYellow" width="10%" >貸放日期</td>
	<td class="tbYellow2" >
		<input id="LOAN_DATES" type="text" class="textBox2 " name="LOAN_DATES" value="${LastWorkDate}"  datatype="ROCDate" maxlength="7"/>
		<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('LOAN_DATES'))">～
		<input id="LOAN_DATEE" type="text" class="textBox2 " name="LOAN_DATEE" value="${LastWorkDate}"  datatype="ROCDate" maxlength="7"/>
		<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('LOAN_DATEE'))">
		<td class="tbYellow2" width="10%" rowspan="2">
			<input id="BTN_QUERY" type="button" value="查詢" class="button"> 
			<input id="BTN_EXPORT" type="button" value="匯出" class="button"> 
		</td>
	</td>
	</tr>
</table>
<table id = "grid" >
	
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
	    <td class='tbYellow'　width='10%'colspan='9'>
			一、僅提供查詢符合以下條件案件</font><br>
 	        （１）授信條件(利率及提前清償違約金)與商品表定條件不同之貸放案件。<br>
            （２）尚未繳交第一期期款案件。<br>   			
		</td>

	</tr>
</table>
</form>
</body>
</html>