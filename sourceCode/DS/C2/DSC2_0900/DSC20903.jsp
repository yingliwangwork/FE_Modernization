<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC20903.jsp
作者：張憶如 
功能：總帳帳務查詢-沖暫應收明細表查詢 
完成：2013/9/11
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
Event.observe(window, 'load', new DSC20903().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC20903(){
	
	var grid;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_0903/" + actionName,
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
			ajaxPost( 'query', {ACNT_DATE: $F('ACNT_DATE'), ACNT_GROUP: $F('ACNT_GROUP'), QUERY_TYPE: $F('QUERY_TYPE')},
				function(resp){	
					var rtnList = resp.rtnList || [];
					var TITLE_NAME = resp.TITLE_NAME;
					var totalMap = resp.totalMap;
					var TOTobj = [{ text: '合計' , value:{'WASH_AMT':totalMap['WASH_AMT'] || 0,'REMAIN_AMT':totalMap['REMAIN_AMT'] || 0}}];
			
					$('TITLE_NAME').update(TITLE_NAME);
					$('ACNT_DATE_F').update(Date.toROC($F('ACNT_DATE')));
					grid.load(rtnList, TOTobj || []);
				}
			);				
		}
	}
	
	
	return{
		initApp:function(){	
		PageUI.createPageWithAllBodySubElement( "DSC20903" , "收息帳務", "總公司帳務明細表" );
			grid =  new TableUI({
				table: $("grid"), allSortable:false, pageSize: 20,overDiv:false, split:['REMAIN_AMT'],
				column:[					
					{header: "筆數" , key:'ROW_NO', attrs:{rowSpan:2} },
					{header: "暫應收編號" , key:'BALC_NO' },
					{header: "沖帳貸款帳號" , key:'LOAN_ID' },
					{header: "沖帳繳款期數" , key:'PAY_TERM' },
					{header: "沖帳繳款別" , key:'PAY_KIND_NM' },
					{header: "暫應收原因" , key:'BALC_REASON_NM'},
					{header: "入帳單位" , key:'INPUT_DEPT_NM', attrs:{rowSpan:2}},
					{header: "沖帳前剩餘金額" , key:'REMAIN_AMT',renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					},
					{header: "沖帳金額" , key:'WASH_AMT',renderInCount: true, 
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					},
					{header: "沖帳部入序號" , key:'SEQ_NO' },
					{header: "沖帳方式" , key:'WASH_TYPE_NM' },
					{header: "暫應收備註" , key:'BALC_MEMO' }
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
}//end DSC20903
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<input id="ACNT_DATE" name = "ACNT_DATE" value= "${ACNT_DATE}" type="hidden"/>
			<input id="ACNT_GROUP" name = "ACNT_GROUP" value= "${ACNT_GROUP}" type="hidden"/>
			<input id="QUERY_TYPE" name = "QUERY_TYPE" value= "${QUERY_TYPE}" type="hidden"/>
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