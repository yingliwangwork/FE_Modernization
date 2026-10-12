<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC81000.jsp
作者：張憶如 
功能：單位異動處理
完成：2013/9/2
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>

<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC81000().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC81000(){
	
	var grid;
	var valid1;
	
	//畫面檢核
	function initValidation(){
		valid1 = new Validation("form", { focusOnError:true, immediate:false, mode:'validator'});		
	}
	function validDefine1(){
		valid1.reset();
		valid1.clear();
		valid1.define('required' , [{ id : "OLD_CLCNO" , errMsg:'請輸入原收費代號'}]);
	}
	function validDefine2(){	
		valid1.reset();
		valid1.clear();
		valid1.define('required' , [{ id : "OLD_CLCNO" , errMsg:'請輸入原收費代號'}]);
		valid1.define('required' , [{ id : "NEW_CLCNO" , errMsg:'新收費代號不得為空'}]);
		valid1.define('required' , [{ id : "NEW_CLCDV" , errMsg:'新單位代號不得為空'}]);
	}
	function validDefine3(){
		valid1.reset();
		valid1.clear();
		valid1.define('required' , [{ id : "CHG_DATE" , errMsg:'請輸入異動日期'}]);
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_1000/" + actionName,
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
			validDefine1();
			//檢核欄位
			if(!valid1.validate()){					
				return;			
			}
			//發送ajax
			ajaxPost( 'query', {OLD_CLCNO: $F('OLD_CLCNO')},
				function(resp){	
					var rtnMap = resp.rtnMap || [];
					$$('#table_A input').each(function(ele){
						ele.value = rtnMap[ele.id]||'';
					})
					$('OLD_CLCNO_O').value = $F('OLD_CLCNO');
					//$('CHG_DATE').value = rtnMap['INPUT_DATE'] ? Date.toROC(rtnMap['INPUT_DATE']).replace(/\//g, "") : "";
					grid.load([]);
					$('btn_update').enable();
					$('btn_delete').enable();
				},
				function(resp){
					grid.load([]);
					$('btn_update').disable();
					$('btn_delete').disable();
				}
			);				
		},
		doInsert : function(){
			validDefine2();
			//檢核欄位
			if(!valid1.validate()){					
				return;			
			}
			var DATA_MAP = {
				OLD_CLCNO : $F('OLD_CLCNO'),
				NEW_CLCNO : $F('NEW_CLCNO'),
				NEW_CLCDV : $F('NEW_CLCDV'),
				INPUT_ID : $F('INPUT_ID'),
				INPUT_DATE : $F('INPUT_DATE'),
				OLD_CLCNO_O : $F('OLD_CLCNO_O')
			};
			
			//發送ajax
			ajaxPost( 'insert', {DATA_MAP : Object.toJSON(DATA_MAP)},
				function(resp){	
					$('OLD_CLCNO').value = '';
					$('NEW_CLCNO').value = '';
					$('NEW_CLCDV').value = '';
				}
			);				
		},
		doUpdate : function(){
			validDefine2();
			//檢核欄位
			if(!valid1.validate()){					
				return;			
			}
			var DATA_MAP = {
				OLD_CLCNO : $F('OLD_CLCNO'),
				NEW_CLCNO : $F('NEW_CLCNO'),
				NEW_CLCDV : $F('NEW_CLCDV'),
				INPUT_ID : $F('INPUT_ID'),
				INPUT_DATE : $F('INPUT_DATE'),
				OLD_CLCNO_O : $F('OLD_CLCNO_O')
			};
			//發送ajax
			ajaxPost( 'update', {DATA_MAP : Object.toJSON(DATA_MAP)},
				function(resp){	
					$('OLD_CLCNO').value = '';
					$('NEW_CLCNO').value = '';
					$('NEW_CLCDV').value = '';
				}
			);				
		},
		doDelete : function(){
			//確認是否執行刪除
			if(!confirm('確定要刪除該筆資料？')){
				return;
			}
			var DATA_MAP = {
				OLD_CLCNO : $F('OLD_CLCNO'),
				NEW_CLCNO : $F('NEW_CLCNO'),
				NEW_CLCDV : $F('NEW_CLCDV'),
				INPUT_ID : $F('INPUT_ID'),
				INPUT_DATE : $F('INPUT_DATE'),
				OLD_CLCNO_O : $F('OLD_CLCNO_O')
			};
			//發送ajax
			ajaxPost( 'delete', {DATA_MAP : Object.toJSON(DATA_MAP)},
				function(resp){	
					actions.doClear();
				}
			);				
		},
		doChgQuery : function(){
			validDefine3();
			//檢核欄位
			if(!valid1.validate()){					
				return;			
			}
			
			//發送ajax
			ajaxPost( 'chgQuery', {CHG_DATE : $F('CHG_DATE'), INPUT_ID : $F('INPUT_ID')},
				function(resp){	
					grid.load(resp.rtnList || []);
					$('btn_confirm').enable();
				},
				function(resp){
					grid.load([]);
					$('btn_confirm').disable();
				}
			);				
		},
		doConfirm : function(){
			validDefine3();
			//檢核欄位
			if(!valid1.validate()){					
				return;			
			}
			
			var DATA_LIST = grid.getAllRecords();
			if(DATA_LIST.length == 0){
				alert("請先執行異動明細查詢");
				return;
			}
			//確定要異動
			if(!confirm('確定要異動？')){
				return;
			}
			
			//發送ajax
			ajaxPost( 'confirm', {DATA_LIST : Object.toJSON(DATA_LIST)},
				function(resp){	
					grid.load([]);
				}
			);				
		},
		doClear : function(){
			$('OLD_CLCNO').value = '';
			$('NEW_CLCNO').value = '';
			$('NEW_CLCDV').value = '';
			$('btn_update').disable();
			$('btn_delete').disable();
		}
	}
	
	
	return{
		initApp:function(){	
			PageUI.createPage( "DSC81000" , "變更作業" , "單位異動處理");
			PageUI.loadin(['form', 'grid'], 1);
			initValidation(); //檢核欄位
			grid = new TableUI(
				{
					table: $('grid'), allSortable:false, pageSize : 10, title:"異動明細結果",
					column: [
						{header:"舊收費代號", key:'OLD_CLCNO'},
						{header:"新收費代號", key:'NEW_CLCNO'},
						{header:"新收息單位", key:'NEW_CLCDV'},
						{header:"輸入人員", key:'INPUT_ID'},			
						{header:"輸入日期", key:'INPUT_DATE'}
					]
				}
			);

			
			//按鈕動作
			// 查詢
			$('btn_query').observe('click', actions.doQuery);
			//新增
			$('btn_insert').observe('click', actions.doInsert);
			//修正
			$('btn_update').observe('click', actions.doUpdate);
			//刪除
			$('btn_delete').observe('click', actions.doDelete);
			//清空
			$('btn_clear').observe('click', actions.doClear);
			//異動查詢
			$('btn_chgQuery').observe('click', actions.doChgQuery);
			//異動確認
			$('btn_confirm').observe('click', actions.doConfirm);
			
			displayMessage();
			PageUI.resize();
			
		}//end init()--
	};//end return--	
}//end DSC81000
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow2"align="center" colspan="6">
					<input id="btn_query" class="button" type="button" value="查詢">
					<input id="btn_insert" class="button" type="button" value="新增">
					<input id="btn_update" class="button" type="button" value="修正" disabled>
					<input id="btn_delete" class="button" type="button" value="刪除" disabled>
					<input id="btn_clear" class="button" type="button" value="清空">
				</td>
			</tr>
		</table>
		<table id="table_A"width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>	
				<td class="tbYellow">原收費代號</td>			
				<td class="tbYellow2">
					<input id="OLD_CLCNO" class = "textBox2" maxlength="7"/>
				</td>
				<td class="tbYellow">新收費代號</td>			
				<td class="tbYellow2">
					<input id="NEW_CLCNO" class = "textBox2" maxlength="7"/>
				</td>
				<td class="tbYellow">新單位代號</td>			
				<td class="tbYellow2">
					<input id="NEW_CLCDV" class = "textBox2" maxlength="7"/>
				</td>
				<input id="INPUT_ID" type="hidden"/>
				<input id="INPUT_DATE" type="hidden"/>
				<input id="OLD_CLCNO_O" type="hidden"/>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow">異動明細日期</td>			
				<td class="tbYellow2" colspan="5">
					<input id="CHG_DATE" name="CHG_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="10" maxlength="9" fieldName="異動明細日期" value="${INPUT_DATE}"/>
					<input id="btn_chgQuery" class="button" type="button" value="異動明細">
					<input id="btn_confirm" class="button" type="button" value="異動確認" disabled>
				</td>
			</tr>
		</table>
		<table id="grid" width="100%" class="grid"></table>
	</form>
</body>
</html>