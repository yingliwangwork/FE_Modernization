<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSD11501.jsp
功能：不良放款件明細
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>
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


Event.observe(window, 'load', new DSD11501().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD11501(){
	
	var grid1;	


	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1501/" + actionName,
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
		
			PageUI.createPageWithAllBodySubElement('DSD11501','催收作業','不良放款件明細',1);
			
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
					{header: '貸款編號', key:'LOAN_ID'
						,render :function(rec,val){									
							var link = new Element('a',{ href : "#"}).update(val);
								link.observe('click',function(event){						
									var url = "<%=dispatcher%>/DSD1_1800/prompt?LOAN_ID="+val+"&INPUT_TYPE=2";									
									window.open(url, "DSD1_1501", "top=250, left=250, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=900, height=600");	
								});
								return link;
						}
					},
					<%-- [20240326] 難字調整：借款人，資料是初始就load，因為prompt時有做escapeHtml，需用render產生span才會正確顯示 --%>
					{header: '借款人' , key : 'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }, render : function (rec, val) {
						if (!val && val !== 0) {//null,'',0,undefind
							return '';
						}
						return new Element('span').update(val);
					}},
					{header: '借款餘額' , key : 'REMAIN_AMT', attrs:{align:'right'}
						,render:function(rec,val){
							return val ? CSRUtil.$fmt(val,'#,###'):'0';
						}
					},
					{header: '下次應繳日' , key : 'NEXT_PAYDATE'
						,render:function(rec,val){
							return Date.toInputROC( val || '' ,'/');
						}
					},
					{header:"簡訊寄送狀態", key:'SEND_STATUS'},
					//{header: '招攬單位' , key : 'AGENT_DEPT_NAME'},
					{header: '收息單位' , key : 'GETINT_DEPT_NAME'},
					{header: '近半年遲繳次數' , key : 'DELAY_TIMES'},
					{header: '餘額放款率（％）' , key : 'REMAIN_AMT_RATE'},
					{header: '服務中心' , key : 'DIV_NAMES'},
					{header: '已繳期數' , key : 'PAY_TERM'},
					{header: '逾期期數' , key : 'OVER_TERM'}/*,
					{header: '徵信人員' , key : 'CRED_ID_NAME'}*/
					
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