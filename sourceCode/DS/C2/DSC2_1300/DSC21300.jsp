<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC21300.jsp
功能：帳務剔除核覆
作者：溫子?
完成：2013/05/21

[20241030]修改件 CHROME瀏覽器難字調整
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
<%--[20241030]難字css  --%>
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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC21300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC21300(){
var grid;
var reqMap_rc;//查詢條件
	function initValidation(){		
			//查詢用檢核
			valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid1.define( "required" , { id: "DELT_DEPT" , errMsg:"請輸入查詢單位!!" } );			
			valid1.define( "required" , { id: "QUERY_DATE_STR" , errMsg:"請輸入查詢起日!!" } );
			valid1.define('validate-selection' , [{ id : "AUTHORITY" , errMsg:"請選擇是否核覆"}] );
			
			
		}
		//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSC2_1300/" + actionName,
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
		var buttons ={
			getMap :function(){
			
				return {			
					DELT_DEPT : $F('DELT_DEPT'),
					QUERY_DATE_STR :$F('QUERY_DATE_STR'),
					QUERY_DATE_END : $F('QUERY_DATE_END'),
					AUTHORITY :$F('AUTHORITY')
				}
		
			}
			,doQuery :function(){
				
				if(!valid1.validate()){
					return;
				}
				reqMap_rc=buttons.getMap();	
				ajaxPost( 'query', {reqMap : Object.toJSON(reqMap_rc)}
					,function(resp){
						grid.load(resp.rtnList);
					},
					function(resp){
						grid.load([]);
					}
				);
			
			}
			,doCancel :function(rec){
				var tempCondition = buttons.getMap();
					for(key in tempCondition){
						if(tempCondition[key] != reqMap_rc[key]){
							alert('與查詢時條件不同，請重新查詢');
							return;
						}				
					}
				var Map2={
					DELT_DEPT : $F('DELT_DEPT'),
					DELT_DATE : rec.DELT_DATE,
					DELT_NO : rec.DELT_NO,
					PAY_KIND : rec.PAY_KIND,
					LOAN_ID : rec.LOAN_ID,
					PAY_TERM : rec.PAY_TERM,
					PAY_KIND : rec.PAY_KIND,
					SEQ_NO : rec.SEQ_NO
				};
				ajaxPost( 'cancel', {reqMap : Object.toJSON(reqMap_rc),Map2:Object.toJSON(Map2)}
					,function(resp){
						grid.load(resp.rtnList);
					});
				
			}
			,doConfirm : function (rec){
				var tempCondition = buttons.getMap();
					for(key in tempCondition){
						if(tempCondition[key] != reqMap_rc[key]){
							alert('與查詢時條件不同，請重新查詢');
							return;
						}				
					}
				var Map1={
					DELT_DEPT : $F('DELT_DEPT'),
					DELT_DATE : rec.DELT_DATE,
					DELT_NO : rec.DELT_NO,
					PAY_TYPE : rec.PAY_TYPE,
					RECEIPT_SERNO : rec.RECEIPT_SERNO,
					USER_TRN_SERNO : rec.USER_TRN_SERNO,
					DELT_ID : rec.DELT_ID,
					DELT_NAME : rec.DELT_NAME,
					LOAN_ID : rec.LOAN_ID,
					PAY_TERM : rec.PAY_TERM,
					PAY_KIND : rec.PAY_KIND,
					SEQ_NO : rec.SEQ_NO
				};
				ajaxPost( 'confirm', {reqMap : Object.toJSON(reqMap_rc),Map1:Object.toJSON(Map1)}
					,function(resp){
						grid.load(resp.rtnList);
					});
				
			}
		}
	return {
		initApp : function() {
				PageUI.createPageWithAllBodySubElement('DSC21300', '收息帳務', '帳務剔除核覆');
				var today=getY2KToday();
				<%-- [20241030] 難字調整 --%>
				grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true,	split: ['INT_BEGDT'],
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},	
				column:[			
					{header:"剔除日期", key:"DELT_DATE",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					
					},
					{header:"剔除編號",key:"DELT_NO"},
					{header:"剔除序號",key:"SER_NO"},
					{header:"剔除人員",key:"DELT_NAME"},
					{header:"剔除授權",key:"AUTHORITY_NM", style:"font-family:'EUDC'"},
					{header:"帳號",key:"LOAN_ID"},
					{header:"繳款別",key:"PAY_KIND"},
					{header:"繳款期數",key:"PAY_TERM"},
					{header:"序號",key:"SEQ_NO"},
					{header:"輸入人員",key:"INPUT_NAME", style:"font-family:'EUDC'"},
					
					{header:"計息起日",key:"INT_BEGDT",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					},
					{header:"計息終日",key:"INT_ENDDT",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					},
					{header:"票據狀態",key:"CHECK_STATUS_NM"},
					{header:"票據種類",key:"CHECK_TYPE"},
					{header:"實繳金額",key:"REAL_PAYMT"},
					{header:"輸入日期",key:"INPUT_DATE",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					},
					{header:"剔除種類",key:"DELT_KIND"},
					{header:"剔除說明",key:"DELT_MEMO"},
					{header:"剔除姓名",key:"DELT_KIND"},
					{header:"處理",key:"button",
						render : function(rec ,val ){
							var check = new Element("input" , {type : 'button' , value : '取消' , className : 'button' ,id:'cancel'} );
								check.observe("click",function(event){buttons.doCancel(rec)});
						
							var check2 = new Element("input" , {type : 'button' , value : '核覆' , className : 'button',id:'confirm'} );
									check2.observe("click", function(event){buttons.doConfirm(rec)});
							 var span = new Element('span');
							 if(rec.AUTHORITY==0){//未核覆
								if(rec.SER_NO==1){
									check.enable();
								}else{
									check.disable();
								}
								 if(rec.DELT_DATE==today){
									check2.enable();
								 }else{
									check2.disable();
								 }
							 }else{
							     check.disable();
							     check2.disable();
							 }
							 span.insert(check).insert(check2);

							 return span;  
						}					
					}
					
				]
				});

				$('AUTHORITY').value=0;
				initValidation();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('DELT_DEPT').observe('change' , function(event){
					event.target.value = event.target.value.toUpperCase();
				
				});

				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
				if($F('linkFrom') == 'AMI01000'){  
				      
					buttons.doQuery();  
				}
			}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<input type="hidden" id="linkFrom" name="linkFrom" value="${linkFrom}"/>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<td class="tbYellow" width="7%">查詢單位</td>
		<td class="tbYellow2"  >
			<input id="DELT_DEPT"  type="text" class="textBox2" value="${DIV_NO}" size="9" maxlength="7"/></td>
		<td class="tbYellow"  width="7%">查詢起日</td>
		<td class="tbYellow2" >
			<input id="QUERY_DATE_STR" type="text" class="textBox2 " name="QUERY_DATE_STR" value="${SYS_DATE}"  datatype="ROCDate" maxlength="7" size = "10"/>
		<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('QUERY_DATE_STR'))">
		</td>
		<td class="tbYellow"  width="7%">查詢終日</td>
		<td class="tbYellow2" >
			<input id="QUERY_DATE_END" type="text" class="textBox2 " name="QUERY_DATE_END" value="${SYS_DATE}"  datatype="ROCDate" maxlength="7" size = "10"/>
		<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('QUERY_DATE_END'))">
		</td>
		<td class="tbYellow" >是否核覆</td>
		<td class="tbYellow2" width="15%" >
				<select id="AUTHORITY">
						<option value="">請選擇</option>
							<c:forEach var="map" items="${AUTHORITY_LIST}">
									<option value="${map.key}">${map.value}</option>
							</c:forEach>
				</select> 
		</td>
		<td class="tbYellow2" align="center">
			<input id="BTN_QUERY" type="button" value="查詢" class="button" > 
		</td>
	</table>

	<table id = "grid" ></table>
</form>
</body>
</html>