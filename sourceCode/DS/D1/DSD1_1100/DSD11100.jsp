<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSD11100.jsp
功能：提前沖轉查詢
作者：溫子
完成：2013/06/

[20240327]難字
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
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>

<%-- [20240327]難字 --%>
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
Event.observe(window, 'load', new DSD11100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSD11100(){

var LOAN_ID='${LOAN_ID}';
var valid1;

var grid;

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1100/" + actionName,
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
	function initValidation(){		
			//查詢用檢核
			valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid1.define('validate-selection' , [{ id : "CHECK_DATE" , errMsg:"請選擇沖轉日期"}] );
			
		}
	var buttons ={
		doQuery :function(){
		/*
			valid1.reset();
			if(!valid1.validate()){
					return;
				}
			*/	
			
			if($F('LOAN_ID').length != 0 && $F('LOAN_ID').length != 10){
				alert("請輸入正確貸款帳號");
				return;
			}
			//if 「沖轉日期」、「貸款帳號」若皆為空白
			if($F('CHECK_DATE') == "" && $F('LOAN_ID').length != 10){
				alert("沖轉日期、貸款帳號，須擇一選擇");
				return;
			}

			var getMap = {
				CHECK_DATE : $F('CHECK_DATE'),
				LOAN_ID : $F('LOAN_ID')
			};
			ajaxPost( 'query', {reqMap : Object.toJSON(getMap)}
					,function(resp){
						grid.load(resp.rtnList);
					},function(resp){
							grid.load([]);
						}
				);
		}
	
	}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSD11100', '逾繳催收', '提前沖轉查詢');
								grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true,	
					
				<%-- [20240327]難字 --%>
	            afterLoad: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
	            },
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
	            },	
				
				
				column:[			
					{header:"貸款帳號", key:"LOAN_ID"},
					{header:"轉出日期",key:"OUT_DATE",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					
					},
					{header:"姓名",key:"BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},<%-- [20240327]難字 --%>
					{header:"ID",key:"BORROW_ID"},
					{header:"催收款項",key:"LOAN_AMT",
						render: function (rec,val){
							return MoneyFormat(val) || '';
						}
					},
					{header:"轉銷呆帳",key:"WASH_AMT",
						render: function (rec,val){
							return MoneyFormat(val) || '';
						}
					},
					{header:"沖轉日期",key:"CHECK_DATE",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					}
					
				]
				});


				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('CHECK_DATE').selectedIndex='';
				initValidation();
				
				$('LOAN_ID').observe('keyup',  function(event){	
				$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();
				});	
			
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
			<td class="tbYellow" width="10%">沖轉日期</td>
			<td class="tbYellow2" width="10%">
				<select id="CHECK_DATE">
						<option value="">請選擇</option>
							<c:forEach var="map" items="${CHECK_DATE_List}">
									<option value="${map.CHECK_DATE}">${map.CHECK_DATE}</option>
							</c:forEach>
				</select> 
			</td>
			<td class="tbYellow" width="10%">貸款帳號</td>
			<td class="tbYellow2" width="10%">
				<input id="LOAN_ID" type="text" class="textBox2"  size="12" maxlength="10" value=""/>
			
			<td class="tbYellow2" >
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
			</td>
		</tr>
	</table>
	<table id = "grid" ></table>
</form>
</body>
</html>