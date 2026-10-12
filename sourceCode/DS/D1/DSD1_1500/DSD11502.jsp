<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSD11502.jsp
功能：不良放款已繳明細查詢
作者：徐麗雲
完成：2013/05/28

[20240326]
難字調整
高強禾
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
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
<script type="text/javascript">


Event.observe(window, 'load', new DSD11502().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD11502(){
	
	var grid1;	


	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1502/" + actionName,
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
			}
		);
	}
	

		
		
	//按鈕功能	
	var buttons = {
		//上一頁
		doBack:function(){
			var LP_JSON = {
				action :'${dispatcher}/DSD1_1500/prompt',				
				AREA_CODE : '${OLD_AREA_CODE}',
				CHECK_TYPE : '${CHECK_TYPE}',
				IS_INIT : '${IS_INIT}'
				
			};					
			CSRUtil.linkTo(LP_JSON, 'form1');
		}
	};
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSD11502','催收作業','不良放款已繳件明細',1);
			
			//產生 Grid1 物件	
			grid1 = new TableUI ( 
				{ table: $('grid1'), pageSize: 20, allSortable:true, overDiv:false,
				<%-- [20240326] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column : [
					{header: '序號' , key : 'SEQ'},
					{header: '貸款編號' , key : 'LOAN_ID'},
					<%-- [20240326] 難字調整：姓名，資料是初始就load，因為prompt時有做escapeHtml，需用render產生span才會正確顯示 --%>
					{header: '姓名' , key : 'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }, render : function (rec, val) {
						if (!val && val !== 0) {//null,'',0,undefind
							return '';
						}
						return new Element('span').update(val);
					}},
					{header: '已繳期數', key:'PAY_TERM'},
					{header: '繳款別' , key : 'PAY_KIND_NM'},
					{header: '前期本金餘額' , key : 'SUMT', attrs:{align:'right'}
						,render:function(rec,val){
							return val ? CSRUtil.$fmt(val,'#,###'):'0';
						}
					},
					{header: '本金餘額' , key : 'LSUMT', attrs:{align:'right'}
						,render:function(rec,val){
							return val ? CSRUtil.$fmt(val,'#,###'):'0';
						}
					},
					{header: '應繳金額' , key : 'DUTY_PAYMT', attrs:{align:'right'}
						,render:function(rec,val){
							return val ? CSRUtil.$fmt(val,'#,###'):'0';
						}
					
					},
					{header: '下次應繳日期' , key : 'NEXT_PAYDT'
						,render:function(rec,val){
							return Date.toInputROC( val || '' ,'/');
						}
					},
					{header: '繳納是否正常' , key : 'IST'},
					{header: '收息單位' , key : 'GETINT_DEPT_NAME'},
					{header: '服務中心' , key : 'DIV_NAME'},
					{header: '區域' , key : 'CRED_DEPT_NAME'}
				]
			});
			
						
							
			var rtnList = <c:out value="${rtnList}" default="[]" escapeXml="false"/>;

			grid1.load(rtnList);
					
			$('btn_back').observe('click', buttons.doBack);//上一頁按鈕
			
			PageUI.resize();

			displayMessage();
						
		}
	}
}
</script>
</head>

<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id = "grid1" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow2" align="center">
					<input type="button" id="btn_back" class="button" value="上一頁" /> 
				</td>
			</tr>
		</table>		
</form>	
</body>
</html>