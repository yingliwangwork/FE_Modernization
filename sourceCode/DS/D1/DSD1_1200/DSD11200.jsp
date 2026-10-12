<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSD11200.jsp
功能：員工催收件查詢
作者：余凱鈞
完成：2013/07/15

[20240327]難字
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
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
Event.observe(window, 'load', new DSD11200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSD11200(){
var grid;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1200/" + actionName, {  
			parameters : params, 
			onSuccess : function(response){
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
	
	//POP UP 開啟新視窗
  	function doPopup( page , parms ) {
		popupWin.popup({
			src : '<%=dispatcher%>/DSD1_1800/prompt' ,
			parameters : parms ,
			scrolling : 'yes',
			width:'99%', 
			height:'99%',
			left : '10',  
			top :'10',
			cb : function(obj){			
				buttons.doQuery();
			}
		});
  	}
	
		
	var buttons={
		doQuery : function(){
		
			var reqMap={
				RULE1 : $F('RULE1') , 
				RULE2 : $F('RULE2')
			}
			ajaxPost( 'query', {reqMap : Object.toJSON(reqMap)}
						,function(resp){
							var rtnList=resp.rtnList;
							grid.load(rtnList);	
						},function(resp){
							grid.load([]);
						}
			);
		}
	
	}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSD11200', '逾繳催收', '員工催收件查詢');
								grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: true, overDiv:true,
				
				<%-- [20240327]難字 --%>
	            afterLoad: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
	            },
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
	            },	
				
				column:[			
					{header:"催繳<br>次數<br>", key:"CNT"},
					{header:"相關<br>案件<br>", key:"REL_CASE"},
					{header:"移送<br>法務<br>", key:"LOAN_STATUS"},
					{header:"信保<br>貸款<br>", key:"CRED_GUAR"},
					{header:"921<br>案件<br>", key:"VICTIM_KIND_NM"},
					{header:"前置協商<br>", key:"NEGO_ID",
						render : function (rec , val){
							return (rec.NEGO_ID || '') + (rec.NEGO_STATUS_NM || '');												
						}	
					},
					{header:"約定繳款<br>日", key:"DUE_DATE",
						render : function (rec , val){
							return Date.toROC(val || "");
						}		
					},
					{header:"契約狀態", key:"LOAN_STATUS_NM"},
					{header:"帳號", key:"LOAN_ID",
						render:function(rec,val){							
							if(val){
								//以LOAN_ID超連結開啟新視窗(POP UP)DSD11800，催收明細作業
								//var link = new Element( 'a' , { 'href' : "#" } ).update(val);
								//var parms = { 
								//	'LOAN_ID' : val				
								//}; 		
								//link.observe('click', function(){doPopup( "DSD1_1800" , parms )});
								//return link;
								
								//超連結至 ”DSD01800” 催收明細作業畫面。
								var link = new Element( 'a' , { href : "#" } ).update(val);	
								link.observe( 'click', function (event){ 
                               		var url = "<%=dispatcher%>/DSD1_1800/prompt?LOAN_ID="+val+"&INPUT_TYPE=2";									
									window.open(url, "DSD1_1200", "top=250, left=250, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=900, height=600");
								});										
								return link; 
							}	
							return '';
							
						}
					},
					{header:"姓名", key:"BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},<%-- [20240327]難字 --%>
					{header:"繳款方式<br>", key:"PAY_TYPE_NM"},
					{header:"收息單位<br>", key:"DEPT_ID"},
					{header:"已繳期數<br>", key:"PAY_TERM"},
					{header:"本金餘額<br>", key:"REMAIN_AMT",
						render: function (rec,val){
							return CSRUtil.$fmt(val, '#,###', 0) || '';
						}				
					},	
					{header:"上次實繳<br>日", key:"REAL_PAYDT",
						render : function (rec , val){
							return Date.toROC(val || "");
						}								
					},
					{header:"下次應繳<br>日", key:"NEXT_PAYDATE",
						render : function (rec , val){
							return Date.toROC(val || "");
						}							
					},
					{header:"聯絡電話<br>(日)", key:"DAY_TEL_AREA",
						render : function (rec , val){
							return (rec.DAY_TEL_AREA || '') +"-"+ (rec.DAY_TEL_NUM || '')+"#"+(rec.DAY_TEL_EXT || '');							
						}
					},	
					{header:"聯絡電話<br>(夜)", key:"NIGHT_TEL_AREA",
						render : function (rec , val){
							return (rec.NIGHT_TEL_AREA || '') +"-"+ (rec.NIGHT_TEL_NUM || '')+" #"+(rec.NIGHT_TEL_EXT || '');												
						}	
					},								
					{header:"經手人", key:"AGENT_NAME", attrs:{ style:"font-family:'EUDC'" }},	<%-- [20240327]難字 --%>
					{header:"經手人<br>單位", key:"AGENT_DIV_NM"},
					{header:"經手人<br>行動電話<br>", key:"AGENT_MOBILE"},
					{header:"擔保品地址", key:"GAGE_ADDR", attrs:{ style:"font-family:'EUDC'" }}<%-- [20240327]難字 --%>					
				
				]
				});
				
				$('BTN_QUERY').observe('click',buttons.doQuery);

				
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
			<td class="tbYellow2" width="10%">
				<select id="RULE1">
				　<option value="0">全部</option>
				　<option value="1" Selected>有效件</option>
				  <option value="2">無效件</option>
				</select>
				<select id="RULE2">
				　<option value="0">全部</option>
				　<option value="1" Selected>在職</option>
				  <option value="2">不在職</option>
				</select>
			</td>
			<td class="tbYellow2" width="60%" >
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >
			</td>
		</tr>
	  </table>
	<table id = "grid" ></table>
	<div class="tbYellow2 tbBox2">
		<font color="blue">&nbsp; 一、作業規定</font>
				<br>&nbsp; &nbsp; 1. 各種貸款規定請參照放款作業手冊及發文規定。
				<br>&nbsp; &nbsp; 2. 本作業可供總公司、各區催收人員查詢該單位<font color="green">（上個月以前六個月以內）</font>之員工催收件
				<br>&nbsp; &nbsp; 3. 本作業之報表列印請至【<font color="blue">扣薪不足明細</font>】列印。
				<br>
	</div>
</form>
</body>
</html>