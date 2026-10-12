 <%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource"/>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script src="<%=htmlBase%>/CM/js/date.js"></script>
<script src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script src="<%=htmlBase%>/CM/js/utility.js"></script>
<script src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>
<%--[20240722]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var grid;

function initApp(){

	cleanMsgBoard();
	
	displayMessage();
	
	PageUI.createPageWithAllBodySubElement("DSA10602" , "受理作業" , "組長強迫送件", 1);
	PageUI.resize(true);
	
	var LP_JSON = <c:out value="${param.LP_JSON}" default="''" escapeXml="false" />;
	if(LP_JSON){
		$('APPLY_ID').value = LP_JSON.APPLY_ID;
	}
	query();
	new UI().init();
}


//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
	
		init:function(){

				grid = new TableUI( 
					{
						table: $("grid"),  
						overDiv:false,
						pageSize: 10,	
						column:[
								{header: '受理編號',sortable: true, key:'APPLY_ID', attrs:{style:"font-family:'EUDC'"}<%--[20240723]難字調整 --%>,
									render:function(obj,val){										
											return val + "<BR>" + obj.BORROW_NAME;
									}
			                	},
								{header: '案件進度',sortable: true, key:'STATUS',
								//IF  rtnMap.isLock == false ,顯示超連結
									render:function(obj,val){
									if (obj.isLock == false){
											var value = obj.APPLY_ID +  '_' + obj.queueName + '_' + obj.wobNum ; 
											var link = new Element('a', { href : '#' });
											link.update( '待強迫送件'+ obj.LockUser  );	
											link.observe('click', 
												function(){ doPopupLink(value);	
											});
											return link;
										} else {
											return "待強迫送件" +obj.LockUser;
										}
									}
								},
								{header: '承辦科別',sortable: true, key:'CRED_DEPT_NM',
									render:function(rec,val){
									 	return val ? val : "";
									}
								},
								{header: '指派日期',sortable: true, key:'F_EnqueueTime',
									render:function(rec,val){
									 	return val ? Date.toROC(val) : "";
									}
								},
								{header: '進件日期',sortable: true, key:'F_StartTime',
									render:function(rec,val){
									 	return val ? Date.toROC(val) : "";
									}
								},
								{header: '相關資訊',sortable: true, key:'MSG',
									render:function(rec,val){
									 	return val ? val : "";
									}
								}
						]
					}
				);
			
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

<%--
3.	受理編號超連結
3.1	超連結(window open) 至DSA1_0603
3.2	傳入參數：
APPLY_ID = 點選相對應的APPLY_ID
wobNum = 點選相對應的wobNum
queueName =點選相對應的queueName
--%>
function doPopupLink(para){

	var APPLY_ID = para.split('_')[0];
	var queueName = para.split('_')[1];
	var wobNum = para.split('_')[2];
	
	var LP_JSON = {
				action: '<%=dispatcher%>/DSA1_0603/prompt?APPLY_ID=' + APPLY_ID + '&queueName=' + queueName + '&wobNum =' + wobNum, // URL
				ACTION_SOURCE:'I'
				};	
				
	CSRUtil.linkTo(LP_JSON, 'form1');
}


<%--
	查詢作業
	IF USER_RL 不包含  ‘RLDS203’ 
	丟錯誤訊息  此作業只允許放款徵信組長作業!!
--%>
function query() {
	
  	new Ajax.Request("<%=dispatcher%>/DSA1_0602/doQuery", 
	{
			parameters:{"APPLY_ID":$F('APPLY_ID')},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					grid.load(resp.returnList);
				}else{
					grid.load([]);
				}
			}
	});

}


//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<form name="form1" id="form1" method="post"><input name="LP_JSON" id="LP_JSON" type="hidden" value="">
		<input type="hidden" name="INPUT_ID" id="INPUT_ID" value="">
        <input type="hidden" id="IS_BACK" name="IS_BACK" value="N"/>
		<input type="hidden" id="LP_JSON" name="LP_JSON" />
	<tr>
		<td width = "10%" class="tbYellow">受理編號</td>
		<td width = "14%" class="tbYellow2" >
                        <input type="text" class="textBox" id="APPLY_ID" name="APPLY_ID">
                        <SPAN ID = "APPLY_ID"></SPAN>
		</td>
		<td class="tbYellow2" align="left">
			<input id="btnQuery" name="btnQuery" onClick="query()" type="button" class="button" value="查詢"> 
		</td>	
	</tr>
	</form>
</table>

<table id='grid' class="grid"></table>

	</body>
</html>
