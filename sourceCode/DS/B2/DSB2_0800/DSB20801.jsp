
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB20801.jsp
作者：張智翔
功能：設定控管統計明細作業。
完成：2012/05/25
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>


<script type='text/javascript'>

// 產生畫面物件
var DSB20801 = new DSB20801();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB20801.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB20801(){
	//檢核變數宣告
	var reqMap = <c:out value = '${reqMap}' default = '{} ' escapeXml = 'false'/>
	
	var grid;	

	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSB2_0801/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {	
		//回上一頁
		doBack : function(event){			
			CSRUtil.linkBack();		
		}		
	};
	
	//查詢
	var actions ={
		doQuery : function(){
			ajaxPost( 'query' , {reqMap :Object.toJSON(reqMap)}	,
				function(resp){						
					grid.load(resp.rtnList);					
				},
				function(resp){	
					//失敗把前次內容清掉 
					grid.load([]);			
				}
			);			
		
		
		}	
	}
	
	
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB20801", "匯款文件", "設定控管統計明細作業" );			
				grid = new TableUI ( {
						table: $("grid"), pageSize: 10, allSortable:true , title : '統計明細',
								
						column: [
							{header: "服務中心",key: "DIV_NAME"},
							{header: "流水序號",key: "SEQ_NO"},
							{header: "申請日期",key: "APPLY_DATE",
								render : function(rec ,val ){
									return Date.toInputROC(val || '' , '/');
								
								}
							},
							{header: "核印日期",key: "CHECK_DATE",
								render : function(rec ,val ){
									return Date.toInputROC(val || '' , '/');
								
								}
							},
							{header: "領用日期",key: "CHANGE_DATE",
								render : function(rec ,val ){
									return Date.toInputROC(val || '' , '/');
								
								}
							},
							{header: "領用人員",key: "CHANGE_NAME"},
							{header: "受理編號",key: "APPLY_ID"},
							{header: "行銷專員",key: "KEEPER_NAME"},
							{header: "特約代書",key: "SCRIVENER_NAME"}
						]
					});	
				
					
				
				//註冊DOM物件
				//click事件
				$("btn_back").observe("click", buttons.doBack);	
				
				
				fix();

				displayMessage();			
				
				actions.doQuery();
			}
	};	
};

</script>
</head>
<body>	
	<table id='grid' width="100%"></table>		
	<div align ="center">
		<tr>
			<td>
				<input id = "btn_back" type = "button" class = "button" value = "回上一頁"/>		
			</td>
		</tr>
	</div>
</body>
</html>