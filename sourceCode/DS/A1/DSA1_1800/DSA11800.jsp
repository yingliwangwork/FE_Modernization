<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA11800.jsp
作者：林秉宏
功能：行動歷程恢復
完成：2018/02/26
更新：
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">
<title></title>

<%--共用定義的javaScript--%>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>

<script type="text/JavaScript">

// 產生畫面物件
var DSA11800 = new DSA11800();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
Event.observe(window, 'load', DSA11800.initApp);

function DSA11800(){
	
	<%--建立 ajax request 物件--%>
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA1_1800/');
    
	var grid;
	var valid1;
	var valid2;
    
    <%--按鈕權限--%>
	function buttonAuth(){
		var authButtons = {
				B0099:"BTN_resume",//恢復歷程
				B0009:"BTN_cancel" //取消補全
		};
		<dz:grantButtons FUNC_ID="DSA11800" ignored="false"/>
	}
    
    <%--檢核--%>
	function initValidation(){	
		Validation.addAllThese([
			[ 'validateAPPLY_ID',  '受理編號長度不正確 需為11碼',
				function(v){				
					return (v.length != 11) ? false : true ;
				}
			]
		]);
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		valid1.define( "required" , [{ id : "APPLY_ID", errMsg:'請輸入受理編號!'}]);
		valid1.define( "validateAPPLY_ID" , { id: "APPLY_ID" } );
		
		valid2 = new Validation("form1", { focusOnError:true, immediate:false });
		valid2.define( "required" , [{ id : "REASON", errMsg:'請輸入異動原因!'}]);
	};
    
    var actions = {
    
    	<%--查詢--%>
		doQuery : function(){	
		
			valid2.reset();
			
			if(!valid1.validate()){ 
				return; 
			}
			
			ajaxRequest.post( 'query' , { APPLY_ID : $F('APPLY_ID') },
				function(resp){		
					var rtnMap = resp.A010Map ? resp.A010Map : {};
					$('APPLY_PROCESS_NM').innerHTML = rtnMap.APPLY_PROCESS_NM ? rtnMap.APPLY_PROCESS_NM : '';
					$('FORM_TYPE_NM').innerHTML = rtnMap.FORM_TYPE_NM ? rtnMap.FORM_TYPE_NM : '';
					$('query_APPLY_ID').setValue(rtnMap.APPLY_ID);
					grid.load(resp.rtnList || []);				
				},
				function(resp){	
					$('APPLY_PROCESS_NM').innerHTML = '';
					$('FORM_TYPE_NM').innerHTML = '';
					$('query_APPLY_ID').setValue('');
					grid.load([]);	
				}
			);
		},
		
		<%--恢復歷程--%>
		doResume : function(){	
		
			if(!$F('query_APPLY_ID')){
				alert("請先執行查詢!");
				return;
			}
			
			if($F('query_APPLY_ID') != $F('APPLY_ID')){
				alert("受理編號和查詢時不同，請重新執行查詢!");
				return;
			}
			
			valid1.reset();
			if(!valid2.validate()){ 
				return; 
			}
			
			ajaxRequest.post( 'resume' , { APPLY_ID : $F('APPLY_ID'), REASON : $F('REASON') },
				function(resp){		
					var rtnMap = resp.A010Map ? resp.A010Map : {};
					$('APPLY_PROCESS_NM').innerHTML = rtnMap.APPLY_PROCESS_NM ? rtnMap.APPLY_PROCESS_NM : '';
					$('FORM_TYPE_NM').innerHTML = rtnMap.FORM_TYPE_NM ? rtnMap.FORM_TYPE_NM : '';
					grid.load(resp.rtnList || []);				
				}
			);
		},
		
		<%--取消補全--%>
		doCancel : function(){	
		
			if(!$F('query_APPLY_ID')){
				alert("請先執行查詢!");
				return;
			}
			
			if($F('query_APPLY_ID') != $F('APPLY_ID')){
				alert("受理編號和查詢時不同，請重新執行查詢!");
				return;
			}
			
			valid1.reset();
			if(!valid2.validate()){ 
				return; 
			}
			
			ajaxRequest.post( 'cancel' , { APPLY_ID : $F('APPLY_ID'), REASON : $F('REASON') },
				function(resp){		
					var rtnMap = resp.A010Map ? resp.A010Map : {};
					$('APPLY_PROCESS_NM').innerHTML = rtnMap.APPLY_PROCESS_NM ? rtnMap.APPLY_PROCESS_NM : '';
					$('FORM_TYPE_NM').innerHTML = rtnMap.FORM_TYPE_NM ? rtnMap.FORM_TYPE_NM : '';
					grid.load(resp.rtnList || []);	
				}
			);
		}
    };
 
    return {
		
		initApp : function() {
		
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>

			PageUI.createPageWithAllBodySubElement("DSA11800", "受理作業", "行動歷程恢復");
			
			grid = new TableUI(
				{	
					table:$("grid"), pageSize:0, allSortable:true, overDiv:true,
					column:[			
						{header:"補全項目", key:"ITEM_NAME"},
						{header:"補全完成日",key:"SUPPLY_DATE", sortRule : 'date'},		
						{header:"暫存案件編號",key:"TMP_CASE_ID"},
						{header:"下補人員",key:"INPUT_NAME"},
						{header:"下補日期",key:"INPUT_DATE", sortRule : 'date'}	
					]				
				}
			);	
			
			initValidation();						
							
			<%--查詢--%>
			$('BTN_query').observe('click', actions.doQuery );
			<%--恢復歷程--%>
			$('BTN_resume').observe('click', actions.doResume );
			<%--取消補全--%>
			$('BTN_cancel').observe('click', actions.doCancel );
			
			<%--監聽: 查詢方式(值) 轉大寫--%>
			$("APPLY_ID").observe('change', function() {$("APPLY_ID").setValue($F("APPLY_ID").toUpperCase());} );
			
			buttonAuth();
					
			PageUI.resize();
			displayMessage();
		}		
	};
}

</script>
</head>
<body>
<form id="form1" name="form1">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">受理編號</td>
			<td class="tbYellow2" width="80%">
				<input id="APPLY_ID" type="text" class="textBox2" size="15" maxlength="11" value="">
				<input id="query_APPLY_ID" type="hidden"/>
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<input id="BTN_query" type="button" class="button" value="查詢">
			</td>
		</tr>
		<tr>
			<td align="center" colspan="3">
				<input id="BTN_resume" type="button" class="button" value="恢復歷程">
				<input id="BTN_cancel" type="button" class="button" value="取消補全">
			</td>
		</tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="15%">
				受理進度
			</td>
			<td class="tbYellow2" width="25%">
				<span id="APPLY_PROCESS_NM"></span>
			</td>
			<td class="tbYellow" width="15%">
				案件類型
			</td>
			<td class="tbYellow2" width="45%">
				<span id="FORM_TYPE_NM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">
				異動原因
			</td>
			<td class="tbYellow2" width="85%" colspan="3">
				<input type="text" class="textBox2 checkInputLength" size="50" maxLength="200" value="" id="REASON"> 
			</td>
		</tr>
	</table>
</form>
<table id='grid' width="100%"></table>	
</body>
</html>
