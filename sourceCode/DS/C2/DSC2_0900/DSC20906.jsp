<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC20906.jsp
作者：張憶如 
功能：總帳帳務查詢-謄本明細表查詢   
完成：2013/9/14
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>

<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC20906().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC20906(){
	
	var grid;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_0906/" + actionName,
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
	
	var actions = {		
		//初始查詢		
		doQuery : function(){
			
			//發送ajax
			ajaxPost( 'query', {ACNT_DATE: $F('ACNT_DATE'), ACNT_GROUP: '${ACNT_GROUP}', QUERY_TYPE: '${QUERY_TYPE}'},
				function(resp){	
					var TOTobj = [{ text: '合計' , value:{'PAYMENT_AMT':resp.PAYMENT_AMT || 0}}];
			
					$('TITLE_NAME').update(resp.TITLE_NAME);
					$('ACNT_DATE_F').update(Date.toROC($F('ACNT_DATE')));
					grid.load(resp.rtnList || [], TOTobj || []);
				}
			);				
		}
	}
	
	
	return{
		initApp:function(){	
		PageUI.createPageWithAllBodySubElement( "DSC20906" , "收息帳務", "總公司帳務明細表" );
			grid =  new TableUI({
				table: $("grid"), allSortable:false, pageSize: 20,overDiv:false,
				column:[					
					{header: "筆數" , key:'ROW_NO' },
					{header: "受理編號" , key:'APPLY_ID' },
					{header: "單據序號" , key:'RECEIPT_SERNO' },
					{header: "轉出金額" , key:'PAYMENT_AMT',renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "收據狀態" , key:'PAYMENT_STATUS_NM' },
					{header: "轉出單位" , key:'INPUT_DEPT'},
					{header: "轉出人員" , key:'INPUT_ID'},
					{header: "轉出日期" , key:'INPUT_DATE', 
						render : function(rec, val){
							return Date.toROC(val);
						}
					},
					{header: "結帳序號" , key:'ACNT_NO'},
					{header: "轉新件編號" , key:'NEW_APPLY_ID' },
					{header: "轉出收據狀態" , key:'RECEIPT_STATUS_NM' }
				]
			});
			
			actions.doQuery();
			// 回上一頁
			$('btn_back').observe('click', function(event){
				CSRUtil.linkBack();
			});
			displayMessage();
			PageUI.resize();
			
		}//end init()--
	};//end return--	
}//end DSC20906
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<input id="ACNT_DATE" name = "ACNT_DATE" value= "${ACNT_DATE}" type="hidden"/>
			
			<tr>
				<th class="tbYellow0" align="center" colspan="2"><span id = "TITLE_NAME"></span></th>
			</tr>
			<tr>
				<td class="tbYellow" width="20%">帳務日期</td>
				<td class="tbYellow2" width="80%"><span id = "ACNT_DATE_F"></span></td>
			</tr>
			
		</table>
		<table id="grid"></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow1" align="center" colspan="2"><input id="btn_back" type="button" class="button" value="回上一頁"/></td>
			</tr>
		</table>
	</form>
</body>
</html>