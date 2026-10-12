<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC80601.jsp
作者：溫子恒
功能：保戶優惠審核
完成：2013/9/
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<fmt:setBundle basename="TextResource" />
<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<!--alert訊息-->

<script type="text/javascript">
//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC80601().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC80601(){
var grid;
	// 按鈕權限
	var buttonAuth = function(){
		var authButtons = {
			B0028 : 'BTN_CONFIRM',
			B0005 : 'BTN_DELETE'
		};
		<dz:grantButtons FUNC_ID='DSC80601'/>
	};
// 共用AJAX
	var ajaxPost = function (actionName, params, successAction, errorAction)
	{	
		new Ajax.Request( '<%=dispatcher%>/DSC8_0601/' + actionName,
		{  
			parameters: params, 
			onSuccess: function(response)
			{
				var resp = response.responseJSON
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
						successAction(resp);
					}
				}else{
					if(errorAction){
						errorAction(resp);
					}
				}
			}
		});
	};
	var buttons = {
	
		doQuery : function(){
			
			ajaxPost( 'query' , { 'USER_DEPT' : $F('USER_DEPT') },
				function(resp){
					grid.load(resp.rtnList);
				},function(resp){
					grid.load([]);
				}
			);
		
		}
		,doConfirm : function(){
			var datas=grid.getCheckedRecord();
			if(datas.length==0){
				alert("請至少選取一筆資料");
			  return;
			}
			
			for(var i=0 ;i<datas.length;i++){
				if($F('USER_ID')==datas[i]['INPUT_ID']){
					alert("審核人員與輸入變更人員不可為同一人!!");
					return;
				}
			}
			ajaxPost( 'confirm' , { 'USER_DEPT' : $F('USER_DEPT') ,DATA_LIST: Object.toJSON(datas)},
				function(resp){
					grid.load(resp.rtnList);
				}
			);
		}
		,doDelete : function(){
			var datas=grid.getCheckedRecord();
			if(datas.length==0){
				alert("請至少選取一筆資料");
				return;
			}
			if(!confirm("確定要刪除？")){
				return;
			}
			ajaxPost( 'delete' , { 'USER_DEPT' : $F('USER_DEPT') ,DATA_LIST: Object.toJSON(datas)},
				function(resp){
					grid.load(resp.rtnList);
				}
			);
		}
		,doBack : function(){
			CSRUtil.linkBack();
		}
	}
return {

	initApp : function(){
	
		PageUI.createPageWithAllBodySubElement('DSC80601', '變更作業', '保戶優惠審核');
		grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true,			
				autoCheckBox:{
						text:'選取',
						type:'checkbox'
					},
				column:[
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"變更種類",key:"INSU_NOTE2_NM"},
					{header:"保戶123等級",key:"INSU_PRANK2_NM"}
				]
				});
		buttonAuth();
		
		//先把畫面區塊都調整到位再顯示訊息
		$('BTN_CONFIRM').observe('click',buttons.doConfirm);
		$('BTN_DELETE').observe('click',buttons.doDelete);
		$('BTN_BACK').observe('click',buttons.doBack)
		buttons.doQuery();
		fix();	
		//初始頁面alert訊息用	
		displayMessage();
		
	}
}	
}
</script>
</head>
<body>
<form  id='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
	<tr>
			<input id="USER_DEPT" type="hidden" value='${USER_DEPT}'>
			<input id="USER_ID" type="hidden" value='${USER_ID}'>
		<td class="tbYellow2" width="30%" align="center">
			<input id="BTN_CONFIRM" type="button" value="審核確認" class="button"> 
			<input id="BTN_DELETE" type="button" value="刪除確認" class="button"> 
			<input id="BTN_BACK" type="button" value="上一頁" class="button"> 
		</td>
	</tr>
	</table>
	<table id = "grid" ></table>
</form>
</body>
</html>