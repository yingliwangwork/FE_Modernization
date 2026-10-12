<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSD11700.jsp
功能：催收個件查詢
作者：溫子
完成：2013/06/

[20240326]
難字調整
高強禾
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<%-- [20240326] 難字調整 --%>
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
Event.observe(window, 'load', new DSD11700().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSD11700(){
var grid;

//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1700/" + actionName,
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
		doQuery :function(){
		if(!$F('LOAN_ID')&&!$F('BORROW_ID')&&!$F('BORROW_NAME')){
			alert("請至少輸入一項查詢條件");
			return;
		}
			var getMap={
				LOAN_ID : $F('LOAN_ID'),
				BORROW_ID : $F('BORROW_ID'),
				BORROW_NAME : $F('BORROW_NAME'),
				QUERY_H : $F('QUERY_H')
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
				
				PageUI.createPageWithAllBodySubElement('DSD11700', '催收作業', '催收個件查詢');
								grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true,			
				<%-- [20240326] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[			
					{header:"921案件", key:"VICTIM_KIND_NM"},
					{header:"前置協商",key:"NEGO_STATUS_NM"},
					{header:"移送法務",key:"LOAN_STATUS"},
					{header:"貸款帳號",key:"LOAN_ID",
						render : function(rec ,val ){
								var link = new Element("a" , { href : "#" } ).update(val);
									link.observe( 'click', function (event){ 																			
											
									
									
									var LP_JSON = {
										action :'<%=dispatcher%>/DSD1_1800/prompt',
										   'LOAN_ID':rec.LOAN_ID, //貸款帳號		
										   'INPUT_TYPE':'2' //2逾期催收								   
									}
									CSRUtil.linkTo(LP_JSON , 'form');      
										
								});
							return link;
						}
					},
					<%-- [20240326] 難字調整：姓名 --%>
					{header:"姓名",key:"BORROW_NAME",attrs:{ style:"font-family:'EUDC'" },
						render : function(rec,val){
							return val ? CSRUtil.maskHandler.getMaskName(val) : '';						
						}
					},
					{header:"ID",key:"BORROW_ID"},
					{header:"收費代號",key:"RECEIVE_ID"},
					<%-- [20240326] 難字調整：經手人姓名 --%>
					{header:"經手人姓名",key:"AGENT_NAME",attrs:{ style:"font-family:'EUDC'"}},
					{header:"經手人電話",key:"AGENT_MOBILE"},
					{header:"經手人單位",key:"AGENT_DIV_NM"}
					
				]
				});
				$('BTN_QUERY').observe('click',buttons.doQuery);
				
				$('LOAN_ID').observe('focus',function(){		
				
					$w('BORROW_ID BORROW_NAME').each(
					function(id){
							$(id).value ='';
						}
					);
				
				});	
				
				$('BORROW_ID').observe('focus',function(){
	
					$w('LOAN_ID BORROW_NAME').each(
						function(id){
							$(id).value ='';
						}
					);
				});

				$('BORROW_NAME').observe('focus',function(){				

					$w('LOAN_ID BORROW_ID').each(
						function(id){
							$(id).value ='';
						}
					);
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
			<td class="tbYellow" width="5%">貸款帳號</td>
			<td class="tbYellow2" width="5%">
				<input id="LOAN_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()"  size="12" maxlength="10" />
			</td>
			<td class="tbYellow" width="5%">借款人ID</td>
			<td class="tbYellow2" width="5%">
				<input id="BORROW_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()"  size="12" maxlength="10"/>
			</td>
			<td class="tbYellow" width="6%">借款人姓名</td>
			<td class="tbYellow2" width="5%">
				<%-- [20240326] 難字調整：借款人姓名 --%>
				<input id="BORROW_NAME" type="text" class="textBox2" size="10" alt="ch" />
			</td>
			<td class="tbYellow2" width="10%">
				<input id="QUERY_H" type="checkbox" value='1'  />是否查詢歷史催收紀錄
			</td>
			<td class="tbYellow2" width="4%">
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
			</td>
		</tr>
	</table>
	<table id = "grid" ></table>
	<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
				<tr>
					<td class="tbYellow2">
					<font color="blue">一、作業規定</font>
					<br>&nbsp; 1. 各種貸款規定請參照放款作業手冊及發文規定。
					<br>&nbsp; 2. 本作業可供查詢該<font color="blue">貸款帳號、借款人ID、借款人姓名</font>查詢借款人已進入
					<font color="red">催收階段（即超過一個月以上,六個月以內之正常繳息件）</font>之貸放件。
					<br>&nbsp; 3. 並且提供以借款人<font color="red">個人角度</font>來進行催繳之相關處理程序
					<font color="blue">（ex:新增、異動催收記錄、催收地址電話等列印催繳函、存證信函等相關作業）</font>，
					以節省催收處理時間。
					<br><br>
					<font color="blue">二、操作方式</font>
					<br>&nbsp; 1. 本作業提供<font color="blue">貸款帳號、借款人ID、借款人姓名</font>三種查詢方式，使用者僅需則一輸入查詢。
					<br>&nbsp; 2.查詢出相關記錄後，可將滑鼠點選欲催收的<font color="red">帳號</font>，即可新增、修改該催收記錄。
					</td>
				</tr>		
		</table>	
</form>
</body>
</html>