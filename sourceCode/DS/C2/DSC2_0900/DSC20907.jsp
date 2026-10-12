<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC20907.jsp
作者：張憶如 
功能：總帳帳務查詢-貸款明細表查詢    
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
Event.observe(window, 'load', new DSC20907().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC20907(){
	
	var grid;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_0907/" + actionName,
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
					var TOTobj = [{ text: '合計' , value:resp.totalMap}];
			
					$('TITLE_NAME').update(resp.TITLE_NAME);
					$('ACNT_DATE_F').update(Date.toROC($F('ACNT_DATE')));
					grid.load(resp.rtnList || [], TOTobj || []);
				}
			);				
		}
	}
	
	
	return{
		initApp:function(){	
		PageUI.createPageWithAllBodySubElement( "DSC20907" , "收息帳務", "總公司帳務明細表" );
			grid =  new TableUI({
				table: $("grid"), allSortable:false, pageSize: 20,overDiv:false,split:['space'], 
				column:[					
					{header: "序號" , key:'ROW_NO' },
					{header: "帳號" , key:'LOAN_ID' },
					{header: "繳款別" , key:'PAY_KIND_NM' },
					{header: "繳款期數" , key:'PAY_TERM'},
					{header: "貸款種類" , key:'LOAN_KIND_NM' },
					{header: "計息起日" , key:'INT_BEGDT', 
						render : function(rec, val){
							return Date.toROC(val);
						}
					},
					{header: "計息迄日" , key:'INT_ENDDT', 
						render : function(rec, val){
							return Date.toROC(val);
						}
					},
					{header: "應繳日" , key:'DUTY_PAYDT', 
						render : function(rec, val){
							return Date.toROC(val);
						}
					},
					{header: "延滯天" , key:'DELAY_DAY'},
					{header: "利率" , key:'RATE', attrs:{align:'right'}},
					{header: "上期本金" , key:'LAST_PRINCIPAL',renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "入帳單位" , key:'INPUT_DEPT_NM' },
					{header:'', key:'space', empty:'rowSpan_up'
					
					},
					{header: "上期結餘" , key:'LAST_BALANCE' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "本期結餘" , key:'THIS_BALANCE' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "實繳金額" , key:'REAL_PAYMT' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "本金" , key:'PRINCIPAL' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "利息" , key:'INTEREST' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "災戶攤繳" , key:'VICTIM_INT' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "應利" , key:'RETAIN_INT' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "延滯息" , key:'DELAY_INT' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "違約金" , key:'RENEGE' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "代扣稅款" , key:'TAX' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 },
					{header: "管理費" , key:'LAWSUIT_FEE' ,renderInCount: true,
						render : function (rec , val){					 
							return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
						}
					 }
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
}//end DSC20907
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