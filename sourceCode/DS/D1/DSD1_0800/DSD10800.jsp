<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>


<!--
程式：DSD10800.jsp
功能：單筆移送法務查詢
作者：卓達瑋
完成：2013/08/28

[20240327]難字
 --> 

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->

<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>

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

<script type="text/javascript">


Event.observe(window, 'load', new DSD10800().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD10800(){
	
    var grid;
	
	function buttonAuth(){
		var authButtons = {	
			B0174:"btn_print"		
		};
		<dz:grantButtons FUNC_ID="DSD10800" />
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_0800/" + actionName,
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
		//初始查詢
		doQuery : function(){		
            var DEPT_ID_value=$F('DEPT_ID');
		    if(DEPT_ID_value.length!=3&&DEPT_ID_value.length!=5){
			    alert("請輸入3或5碼的單位代號");
				return;
			}
			
		   
			ajaxPost( 'query' , { DEPT_ID : $F('DEPT_ID')},
				function(resp){						
				    grid.load(resp.rtnList||'');
					$('BTN_PRINT').enable();
				},
				function(resp){
					grid.load('');
					$('BTN_PRINT').disable();
				}
			);
		},
		//列印
		doPrint: function() {
		    var detail=grid.getAllRecords();
            RPTUtil.executePrintByLink('print' , {	'DEPT_ID': $F('DEPT_ID'),'detail':Object.toJSON(detail)}, true );	
			
		}
	};
	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSD10800','催收作業','催收款項查詢');
			
			//產生 Grid 物件	
			grid = new TableUI({
				table: $('grid'), pageSize: 15, allSortable: true,
				
				<%-- [20240327]難字 --%>
	            afterLoad: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
	            },
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
	            },
				
				column: [
				    {header:"貸款帳號", key:'LOAN_ID'},
					{header:"契約狀態", key:'LOAN_STATUS_NM'},
					{header:"貸款種類", key:'LOAN_KIND_NM'},
					{header:"收費代號", key:'RECEIVE_ID'},
					{header:"姓名", key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},<%-- [20240327]難字 --%>
					{header:"ID", key:'BORROW_ID'},
					{header:"已繳期數", key:'PAY_TERM'},
				    {header:"逾期期數", key:'OVER_TERM'},
					{header:"上次已繳日", key:'PRE_PAYDATE',
					    render :function(record,value){
						    return Date.toROC( value|| '');
						}
					},
					
					{header:"催收款項", key:'LOAN_AMT',
					    render :function(record,value){
						    return (value||value===0) ? CSRUtil.$fmt(value,"#,###") : '';
						}
					},
				    {header:"聯絡電話(日)", key:'DAY_TEL_AREA'
					    ,render : function(record, value){
							var DAY_TEL_AREA=record.DAY_TEL_AREA||'';
							var DAY_TEL_NUM=record.DAY_TEL_NUM||'';
							var DAY_TEL_EXT=record.DAY_TEL_EXT||'';
						    if(DAY_TEL_AREA){
						       	return "("+DAY_TEL_AREA +")-"+DAY_TEL_NUM +(DAY_TEL_EXT?"#":"")+DAY_TEL_EXT;
						    }else{
						        return DAY_TEL_NUM +(DAY_TEL_EXT?"#":"")+DAY_TEL_EXT; 
							}							
						}
					},
					{header:"聯絡電話(夜)", key:'NIGHT_TEL_AREA'
					    ,render : function(record, value){
							var NIGHT_TEL_AREA=record.NIGHT_TEL_AREA||'';
							var NIGHT_TEL_NUM=record.NIGHT_TEL_NUM||'';
							var NIGHT_TEL_EXT=record.NIGHT_TEL_EXT||'';
							if(NIGHT_TEL_AREA){
							     
						       	return "("+NIGHT_TEL_AREA +")-"+NIGHT_TEL_NUM +(NIGHT_TEL_EXT?"#":"")+NIGHT_TEL_EXT;
						    }else{
						        return NIGHT_TEL_NUM +(NIGHT_TEL_EXT?"#":"")+NIGHT_TEL_EXT; 
							}							
						}
					}
				]	
			});	
			//按鈕事件監聽
			$('BTN_QUERY').observe('click',buttons.doQuery); 
            $('BTN_PRINT').observe('click',buttons.doPrint); 

            $('BTN_PRINT').disable();
			PageUI.resize();
			displayMessage();
						
		}
	}
}
</script>
</head>

<body>
    <table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width="8%" align="left">收息單位</td>
				<td class="tbYellow2"  >
					<input id="DEPT_ID" type="text" size='7' maxlength="5" onKeyUp="this.value=this.value.toUpperCase();" />
				</td>
			    <td class="tbYellow2" width="15%">    
					<input type="button" class="button" id="BTN_QUERY" value="查詢"/>	
					<input type="button" class="button" id="BTN_PRINT" value="列印"/>	
			    </td>
			</tr>
			
		</table>


	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		
		<table id="grid" width="100%" class="grid" ></table>
	    <table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
		    <tr>
			    <td class="tbYellow2">    
			        <font color="blue"><b>一、作業規定</b></font><br>   
			        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.各種貸款規定請參照放款作業手冊及發文規定。<br>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.本作業可供催收人員查詢<font color="red">超過六個月以上</font>的未繳件。<br>			
					<font color="blue"><b>二、操作方式</b></font><br>  
				    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.於<font color="red">收息單位</font>欄位輸入欲查詢之單位代號，再按<font color="blue">查詢</font>即可。
			</tr>
        </table>
	</form>	
</body>
</html>