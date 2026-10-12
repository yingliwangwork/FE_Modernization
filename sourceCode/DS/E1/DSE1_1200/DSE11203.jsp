<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSE1_1203.jsp
功能：取得執名
作者：徐麗雲
完成：2013/06/06

[20240207]
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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<%-- [20240207] 難字調整 --%>
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


Event.observe(window, 'load', new DSE11203().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11203(){
	
	var grid;
	var LOAN_ID;

	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSE1_1203/');
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		ajaxRequest.post( actionName, params, successFunction , errorFunction);
	
	}		
	
	
	//各種action
	var actions = {
		//取得超連結
		getLink : function(func_id,val){			
			var link = new Element('a', { href : '#' });
			link.update(val);
			var LP_JSON = {	action :'${dispatcher}/' + func_id +'/prompt',
						LOAN_ID : $F('LOAN_ID')
						};
			link.onclick = function() {
				CSRUtil.linkTo(LP_JSON, 'form1');
			};
			
			return link;
		},
		
		//初始查詢
		doQuery : function(){
			
			//發送ajax
			ajaxPost( 'query' , {	LOAN_ID : $('LOAN_ID').value},
				function(resp){							
					grid.load(resp.rtnList);					
				},
				function(resp){							
					grid.load([]);					
				}					
			);			
		}
		
	};	
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSE11203','法務作業','取得執行名義',1,true);
			
			//產生 Grid 物件	
			grid = new TableUI ( 
			{   table: $('grid'), allSortable:false, overDiv:false,
                <%-- [20240207] 難字調整 --%>
				afterLoad: function() {
            		if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
            	pageChange: function() {
            		if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
            	},
				column : [
					{header: '種類' , key : 'KIND_NAME'
						,render:function(rec,val){
							if(val=='支付命令'){
								return actions.getLink('DSE1_1212',val);
							}else if(val=='拍賣抵押物裁定'){
								return actions.getLink('DSE1_1210',val);
							}else if(val=='實體訴訟'){
								return actions.getLink('DSE1_1211',val);
							}else if(val=='確認訴訟費用'){
								return actions.getLink('DSE1_1213',val);
							}else if(val=='債權憑證'){
								return actions.getLink('DSE1_1214',val);
							}
							return '';
						}
					},
					{header: '聲請日期' , key : 'APPLY_DATE'
						,render:function(rec,val){
							return val ? Date.toInputROC(val,'/') : '';
						}
					},
					{header: '確定/換發日期', key : 'CERTAIN_DATE'
						,render:function(rec,val){
							return val ? Date.toInputROC(val,'/') : '';
						}
					},
					<%-- [20240207] 難字調整：相對人 --%>
					{header: '相對人' , key : 'OPPOSITE_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header: '法院' , key : 'COURT_CODE_NM'},
					{header: '案號' , key : 'CASE_NO'}
				]
			});

			CSRUtil.isBackLink('form1')  
			
			if('${LOAN_ID}'){
				$('LOAN_ID').value = '${LOAN_ID}';			
			}			
			
			ajaxRequest.closeSuccMsg();
			actions.doQuery();			
		
			PageUI.resize();

			displayMessage();
						
		}
	}
}
</script>
</head>

<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<input id="LOAN_ID" name="LOAN_ID" type ="hidden" />
		<table id = "grid" ></table>
</form>	
</body>
</html>