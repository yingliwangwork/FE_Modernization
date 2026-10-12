<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC21200.jsp
功能：帳務轉出核覆
作者：黃子玹
完成：2013/6/4

[20241030]修改件 CHROME瀏覽器難字調整
 -->
 
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" />

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
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>     <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>  <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>      <%-- 標準外框表格 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>    <%-- 表格用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>		    <%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC21200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC21200(){
	
		var grid;
		var valid1;
		var reqMap_rc;//查詢條件		
		var legal2;//按鈕權限紀錄	
	
		function initValidation(){		
			//查詢用檢核
			valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid1.define( "required" , { id: "EXPORT_DEPT" , errMsg:"請輸入轉出單位!!" } );			
			valid1.define( "required" , { id: "QUERY_DATE" , errMsg:"輸入查詢日期!!" } );			
			valid1.define('validate-selection' , [{ id : "AUTHORITY" , errMsg:"請選擇是否核覆"}] );			
		}
		//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSC2_1200/" + actionName,
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
		
		//按扭權限		
		function buttonAuth(){
			var authButtons = {
					B0177:'confirm' , <%--確認--%>				
					B0005:'delete' 	  <%--刪除--%>					
			};			
			<dz:grantButtons FUNC_ID="DSC21200" />
			legal2 = legal;
		}
		
		var actions ={
			getMap :function(){
			
				return {			
					EXPORT_DEPT : $F('EXPORT_DEPT'),
					QUERY_DATE :$F('QUERY_DATE'),					
					AUTHORITY :$F('AUTHORITY')
				}
		
			}
			,doQuery :function(){
				
				if(!valid1.validate()){
					return;
				}
				reqMap_rc = actions.getMap();	
				ajaxPost( 'query', {reqMap : Object.toJSON(reqMap_rc)}
				,function(resp){		
					grid.load(resp.rtnList);						
				},function(resp){
					//失敗把前次內容清掉 
					grid.load([]);			
				}
				);
			
			}			
			,doDelete :function(rec){
				var tempCondition = actions.getMap();
					for(key in tempCondition){
						if(tempCondition[key] != reqMap_rc[key]){
							alert('與查詢時條件不同，請重新查詢!');
							return;
						}				
					}					
				ajaxPost( 'delete', {reqMap : Object.toJSON(reqMap_rc), EXPORT_DEPT :  $F('EXPORT_DEPT'), EXPORT_DATE : rec.EXPORT_DATE, EXPORT_NO : rec.EXPORT_NO}
					,function(resp){
						grid.load(resp.rtnList);
					},function(resp){						
						grid.load([]);			
					}							
				);				
			}
			,doConfirm : function (rec){
				var tempCondition = actions.getMap();
					for(key in tempCondition){
						if(tempCondition[key] != reqMap_rc[key]){
							alert('與查詢時條件不同，請重新查詢!');
							return;
						}				
					}	
				if(rec.EXPORT_ID == $('USER_ID').value){
					alert("核覆者與剔除輸入者不得為同一人");
					return;
				}
				ajaxPost( 'confirm', {reqMap : Object.toJSON(reqMap_rc), EXPORT_DEPT :  $F('EXPORT_DEPT'), EXPORT_DATE : rec.EXPORT_DATE, EXPORT_NO : rec.EXPORT_NO}
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
				
				PageUI.createPageWithAllBodySubElement('DSC21200', '收息帳務', '帳務轉出核覆');
				var today = getY2KToday();
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
					{header:"轉出日期", key:"EXPORT_DATE",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}					
					},
					{header:"轉出編號",key:"EXPORT_NO"},
					{header:"轉出序號",key:"SER_NO"},
					{header:"轉出人員",key:"EXPORT_NAME", style:"font-family:'EUDC'" },
					{header:"轉出授權",key:"AUTHORITY_NM" },					
					{header:"覆核人員",key:"CONFIRM_NAME", style:"font-family:'EUDC'" },	
					{header:"帳號",key:"LOAN_ID"},
					{header:"實繳金額",key:"REAL_PAYMT",
							render : function (rec , val){					 
							         return CSRUtil.$fmt(val,"#,###") || 0
						    }					
					},
					{header:"繳款別",key:"PAY_KIND"},
					{header:"繳款期數",key:"PAY_TERM"},
					{header:"序號",key:"SEQ_NO"},
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
					{header:"轉出原因",key:"EXPORT_MEMO"},
					{header:"輸入人員",key:"INPUT_NAME", style:"font-family:'EUDC'" },
					{header:"輸入日期",key:"INPUT_DATE",
						render : function(rec ,val ){
							return Date.toROC(val)||'';
						}
					},					
					{header:"處理",key:"button",attrs:{colSpan:4},
						render : function(rec ,val ){
							var check = new Element("input" , {type : 'button' , value : '刪除' , className : 'button' ,id:'delete'} );
								check.observe("click",function(event){
									actions.doDelete(rec)
							});
							
							var check2 = new Element("input" , {type : 'button' , value : '核覆' , className : 'button',id:'confirm'} );
									check2.observe("click", function(event){
										actions.doConfirm(rec)
									});
							var span = new Element('span');
							
								
							if(rec.EXPORT_DATE==today){
							   if(rec.AUTHORITY==0){  //未核覆
							            check.enable();
										check2.enable();
								}else{
								        check.disable();
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
				$('btn_query').observe('click',actions.doQuery);				
				$('AUTHORITY').setValue('0'); //是否核覆預設未核覆	
				
					
				buttonAuth();//按鈕權限
				initValidation();			
				
				fix();					
				displayMessage();
			}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<input type="hidden" id="USER_ID" value="${USER_ID}" />
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<td class="tbYellow" width="7%">轉出單位</td>
		<td class="tbYellow2"  >
			<input id="EXPORT_DEPT"  type="text" class="textBox2" value="${DIV_NO}" size='9' maxlength='7' /></td>
		<td class="tbYellow"  width="7%">查詢日期</td>
		<td class="tbYellow2" >
			<input id="QUERY_DATE" type="text" class="textBox2 " name="QUERY_DATE" value="${SYS_DATE}"  datatype="ROCDate" size="10"  maxlength="7" />
		<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('QUERY_DATE'))">
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
			<input id="btn_query" type="button" value="查詢" class="button" > 
		</td>
	</table>
	<table id = "grid" ></table>
</form>
</body>
</html>