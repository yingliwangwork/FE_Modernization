<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSD10501.jsp
作者：黃子玹 
功能：本月已催收件數統計
完成：2013/07/04
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSD10501().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSD10501(){

	
	var DEPT_ID = '${DEPT_ID}';
	var DIV_NO = '${DIV_NO}';
	var DIV_KIND = '${DIV_KIND}';
		
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_0501/" + actionName,
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
	
	var actions = {
			
		//查詢
		doQuery : function(event) {		
			
			ajaxPost( 'query',	{DEPT_ID : DEPT_ID,DIV_NO : DIV_NO, DIV_KIND : DIV_KIND},
				function(resp){			
					var rtnMap = resp.rtnMap || '';
					$$('#showData span').each(
						function (elem){					
								elem.innerHTML = rtnMap[elem.id] || 0;							
						}	
					
					)		
									
				}				
			);		
		}
	};
	
	
	return{
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSD10501" , "催收件" , "本月已催收件數統計");
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
					
			actions.doQuery();
						
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//end DSD10501
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<div id ="showData">
		<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" align="center">	
			<tr>				
				<td class="tbYellow" width= "15%" align="center" rowSpan="2">單位名稱</td>
				<td class="tbYellow2" width ="10%" rowSpan="2"  align="center">
						<span id="DIV_NAME"></span>
				</td>
				<td class="tbYellow" width= "15%" align="center">目前催收件數</td>
				<td class="tbYellow2" width ="20%"  align="center">
						<span id="DAY_URGE_CNT"></span>
				</td>	
			</tr>	
			<tr>
				<td class="tbYellow" width= "15%" align="center">當日催收件數</td>
				<td class="tbYellow2" width ="20%"  align="center">
						<span id="DD020CNT"></span>
				</td>			
			</tr>
			<tr>
				<td class="tbYellow" width= "15%" align="center">當月總催收件數</td>
				<td class="tbYellow2" width ="20%"  align="center">
						<span id="MONTH_URGE_CNT"></span>
				</td>	
				<td class="tbYellow" width= "15%" align="center">當月總催理次數</td>
				<td class="tbYellow2" width ="20%"  align="center">
						<span id="MD020CNT"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "15%" align="center" rowSpan="9">目前件狀況明細</td>
				<td class="tbYellow" width= "15%" align="center" colSpan="2">當月催理0次件</td>
				<td class="tbYellow2" width ="20%"  align="center">
						<span id="MD020CNT_0"></span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" width= "15%" align="center" colSpan="2">當月催理1次件</td>
				<td class="tbYellow2" width ="20%"  align="center">
						<span id="MD020CNT_1"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="center" colSpan="2">當月催理2次件</td>
				<td class="tbYellow2" align="center">
						<span id="MD020CNT_2"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow"  align="center" colSpan="2">當月催理3次件</td>
				<td class="tbYellow2" align="center" >
						<span id="MD020CNT_3"></span>
				</td>
			</tr>
						<tr>
				<td class="tbYellow"  align="center" colSpan="2">當月催理4次件</td>
				<td class="tbYellow2" align="center">
						<span id="MD020CNT_4"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow"  align="center" colSpan="2">當月催理5次件</td>
				<td class="tbYellow2" align="center">
						<span id="MD020CNT_5"></span>
				</td>
			</tr>	
			<tr>
				<td class="tbYellow"  align="center" colSpan="2">當月催理6次件</td>
				<td class="tbYellow2" align="center">
						<span id="MD020CNT_6"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="center" colSpan="2">當月催理7次件</td>
				<td class="tbYellow2" align="center">
						<span id="MD020CNT_7"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow"  align="center" colSpan="2">當月催理8次件</td>
				<td class="tbYellow2" align="center">
						<span id="MD020CNT_8"></span>
				</td>
			</tr>
		</table>
		</div>	
	</form>		
</body>
</html>