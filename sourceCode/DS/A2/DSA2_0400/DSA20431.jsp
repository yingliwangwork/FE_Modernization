<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--
程式：DSA20431.jsp
作者：蘇敬友
功能：公務機關授權書作業
完成：

[20210819]問題單號：20210819093447
1.修正畫面顯示
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="BIG5"/>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css" />

<title>公務機關授權書作業</title>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type="text/javascript">

Event.observe(window, 'load', new DSA20431().initApp);
function DSA20431(){
	
	var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA2_0431/');	
	var apply_ID = "${APPLY_ID}";
	
	var buttons = {
		<%--確認&回上一頁--%>
		doDelete : function(){
			ajaxRequest.post( 
				'delete' ,
				{ APPLY_ID : apply_ID},
				function(resp){		<%-- success action -do here  --%>	
					var data = grid.getCheckedRecord();
					if(data.length){
						window.	popupWinBack(data);
					}else{
						window.popupWinBack();	
					}
				}
			);	
		}
	};

	return{
		initApp:function(){
				 
				PageUI.createPageWithAllBodySubElement( 
						"DSA20431", 
						"公務機關授權書作業",
						"公務機關授權書作業"
				);
				
				grid = new TableUI({
					table:$('grid'), 
					allSortable : false,
					pageSize:10, 
					whenDataNull : "--",
					autoCheckBox:{
						text:'選取',
						type:'radio',
						valueKey:'DOC_NAME',
						returnValue:['DOC_NAME', 'AV_FILE_NAME'],
						action:function(node, boxStatus, records){ 
							<%-- 檢核選取狀態避免資料出現問題 --%>
							if(boxStatus){
								<%-- 公務機關授權書預覽 --%>
								ajaxRequest.post(
									'preview',
									{ reqMap : Object.toJSON(records[0]) },
									function(resp){		<%-- success action -do here  --%>		
										var filePath = resp.filePath;
										$('showTif').src='${dispatcher}/DSA2_0432/prompt?filePath=' + filePath;
									},
									function(resp){  <%-- failure action -do here --%>		
									}
								);
							}else{
								$('showTif').src="";
							}
                        }
					},
					column:[
							{ header:"文件名稱",  key:"DOC_NAME"}
					]
				});
			$('doBack').observe('click', buttons.doDelete);
			$('doConfirm').observe('click', buttons.doDelete);
			var DOC_LIST = <c:out value="${DOC_LIST}" default="[]" escapeXml="false"/>;
			grid.load(DOC_LIST);
			displayMessage();
		}
	};
}
</script>
</head>
<body>
<form name="form1" id="form1">
	<table width="100%">
		<tr>
			<td class="tbYellow" width="495px" height="175px" style="vertical-align: top">
				<table id="grid" class="grid" name="grid"></table>	
			</td>
			<td class="tbYellow2" height="700px" width="800px"> 
				<iframe id="showTif" src="" height="700px" width="800px"></iframe>
			</td>
		</tr>
		<tr>
			<td align="center" class="tbYellow" colspan="2">
				<button type="button" class="button" id="doConfirm">確認</button>
				<button type="button" class="button" id="doBack">回上一頁</button>
			</td>
		</tr>
	</table>
</form>
</body>
</html>