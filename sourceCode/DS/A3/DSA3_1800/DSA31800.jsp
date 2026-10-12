<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA31800.jsp
作者：王文進
功能：鑑價薪津QC
完成：2012/4/6
更新：
[20240930]難字調整
-->

<html>
<head></head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<%--[20240930]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<%--自行定義的javaScript--%>
<script type="text/JavaScript">
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA31800().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31800(){
	
	var valid1;
	var column1;
	var grid = {};
	var sumSALARY = '0';
	var conCHECK_YM = '';
	var conCHECK_YM = '';

	<%--
	button控制
	--%>
	var buttonAuth = function (){
		var authButtons = {
			B0021:"btn_export<%--匯出excel--%>",
			B0110:"btn_confirm<%--QC確認--%>"
		};
		<dz:grantButtons FUNC_ID="DSA31800" ignored="false"/>
	};
	
	//查詢
	function doQuery(){
		
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		var dataMap = {};
		dataMap.CHECK_YM = $('CHECK_YM').value;
		conCHECK_YM = $('CHECK_YM').value;
				
		var params = { inputMap:Object.toJSON(dataMap) };
		//成功
		var successActionOpen = function(resp){
			rtnList = resp.rtnList ? resp.rtnList : [];
			sumTotalList = resp.sumTotalList ? resp.sumTotalList : [];	 
			grid.load(rtnList,sumTotalList);
			MSG = resp.MSG ? resp.MSG : '';
			if(''!=MSG){
				$("btn_confirm").disabled = true;
			}else{
				$("btn_confirm").disabled = false;
			}
			sumSALARY = resp.sumSALARY ? resp.sumSALARY : '0';
		};
		//失敗
		var errorActionOpen = function(resp){	 
			grid.load([]);
		};
		
		ajaxPost('query',params,successActionOpen,errorActionOpen);
	}
	
	//--------------------------------------------------------------------------	
	//	匯出 excel Function
	//--------------------------------------------------------------------------
	function doExportXls(){
	
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		$('gridJSON').value = grid.getXlsSettingJSON('鑑價薪津QC');
	
		RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSA3_1800/exportXls', Form.serialize("form1"));
	
	}
	
	//--------------------------------------------------------------------------	
	//	QC確認按鈕 Function
	//--------------------------------------------------------------------------
	function doConfirm(){
	
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		if(conCHECK_YM!=$('CHECK_YM').value){
			alert("欲作業的鑑價年月"+$('CHECK_YM').value+"與原先查詢的鑑價年月"+conCHECK_YM+"不同,無法作業!");
			return;
		}
		
		if (grid.getAllRecords().length ==0 ){
			alert("需有資料方可進行QC確認作業");
			return;			
		}
		
		var allRec  = grid.getAllRecords();
		//var allRec  = grid.getAllRecords(['APPR_ID','SALARY']);
		
		var dataMap = {};
		dataMap.CHECK_YM = $('CHECK_YM').value;
		dataMap.CHECK_CNT = allRec.length;
		dataMap.SALARY = sumSALARY;
				
		var params = { inputMap:Object.toJSON(dataMap),allRec:Object.toJSON(allRec) };
		//成功
		var successActionOpen = function(resp){
			rtnList = resp.rtnList ? resp.rtnList : [];
			sumTotalList = resp.sumTotalList ? resp.sumTotalList : [];	 
			grid.load(rtnList,sumTotalList);
			MSG = resp.MSG ? resp.MSG : '';
			if(''!=MSG){
				//alert(MSG);
				$("btn_confirm").disabled = true;
			}else{
				$("btn_confirm").disabled = false;
			}
		};
		//失敗
		var errorActionOpen = function(resp){	 
			grid.load([]);
		};
		
		ajaxPost('confirm',params,successActionOpen,errorActionOpen);
	
	}
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA3_1800/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}

	return{                              
		initApp:function(){
		
			PageUI.createPage("DSA31800" , "鑑價作業" , "鑑價薪津QC");
			PageUI.loadin(["tableA","grid"] ,1);
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			
			//產生 Grid 物件                
			grid = new TableUI({
				table: $('grid'), pageSize: 500, allSortable: true,
				<%-- [20240930] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{header:'序號', key:'SER_NO',
							render:function(record, value){
								return value ? value : '';
							}
					},
					{header:'鑑價人員', key:'APPR_NM', attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
						render:function(record, value){
						 	return value ? value : '';
						}
					},
					{header:'核薪年月', key:'WORK_YM',
						render:function(record, value){
						 	return value ? value.substring(0,value.length-2)+'/'+value.substring(value.length-2): '';
						}
					},
					{header:'派件件數', key:'APPLY_COUNT', sortRule:'number',
						render:function(record, value){
						 	return value ? value : '';
						}
					},
					{header:'鑑價件數', key:'APPR_COUNT', sortRule:'number', 
						render:function(record, value){
						 	return value ? value : '';
						}
					},
					{header:'鑑價薪津', key:'SALARY', sortRule:'number',
						render:function(record, value){
							return value ? CSRUtil.$fmt(value, '#,##0') : '0';
						}
					}
				]
			});
			
			//查詢
			$('btn_query').observe('click',function(event){
					doQuery();
				}
			);
			
			// 匯出excel按鈕
			$("btn_export").observe('click', function(event){
					doExportXls();
				}
			);
			
			// QC確認按鈕
			$("btn_confirm").observe('click', function(event){
					doConfirm();
				}
			);
						
			buttonAuth();

			displayMessage();

			$('CHECK_YM').value = '${CHECK_YM}';
			
			if('${isContain}' == 'N'){
				$('btn_query').disabled = true;
				$('btn_export').disabled = true;
				$('btn_confirm').disabled = true;
			}else{
				$('btn_query').disabled = false;
				$('btn_export').disabled = false;
				$('btn_confirm').disabled = false;
			
			}
			

		}                 
	}
}

// 只能輸入數字
function numberOnly(){
	return (event.keyCode > 47 && event.keyCode < 58 );
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<form id="form1" name="form1" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
		<tr>
			<td class="tbYellow" width ="30%">
				鑑價年月
			</td>
			<td class="tbYellow2" width ="30%">
				<input type="hidden" name="gridJSON" id="gridJSON" value="">
				<input type="text" class="textBox required" fieldName="鑑價年月" id="CHECK_YM" name="CHECK_YM" size="5" maxlength="5" onkeypress="return numberOnly()">
			</td>
			<td class="tbYellow2" width ="40%">
				<input id="btn_query" type="button" class="button" value="查詢">
				<input id="btn_export" type="button" class="button"value="匯出 " >
			</td>
		</tr>
		<tr>
			<td colspan="3" align="center">
				<input id="btn_confirm" type="button" class="button"value="QC確認" >
			</td>
		</tr>
	</table>
	
	<table id="grid" class="grid"></table>
	
	</form>

</body>
<!-- InstanceEnd -->
</html>
