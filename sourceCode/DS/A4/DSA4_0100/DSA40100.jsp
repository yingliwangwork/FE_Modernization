<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA40100.jsp
作者：王文進
功能：放款精英報名系統
完成：2012/02/01
[20240930] 修改件 CHROME瀏覽器難字調整
-->
<html>
<head>
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<%--[20240930]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI_Beta.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA40100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA40100(){
	
	var grid = null;
	var valid1;
	
	var buttonAuth = function (){
		var authButtons = {
				B0001:"btn_query"<%--查詢--%> ,
				B0135:"btn_delquery"<%--查詢刪除紀錄--%>
		};
		<dz:grantButtons FUNC_ID="DSA40100" ignored="false"/>
	}
	
	var gridColumn = {
		//初始
		<%-- [20240930]  難字調整 --%>
		byPrompt:function(isQueryByTEA_ID){
			var arrayColumn = 
			[
				{header:'區部', key:'MKT_DEPT_NM',
					render:function(record, value){
						return value ? value : "";
					}
				},
				{header:'單位', key:'DIV_NM',
					render:function(record, value){
						return value ? value : "";
					}
				},
				{header:'放款精英', key:'TEA_NM', style:"font-family:'EUDC'",
					render:function(record, value){
						return value ? value : "";
					}
				},
				{header:'被培育者姓名', key:'STU_NM', style:"font-family:'EUDC'",
					render:function(record, value){
						return value ? value : "";
					}
				},
				{header:'狀態', key:'STATUS',
					render:function(record, value){
						return value ? value : "";
					}
				},
				{header:'業績計算起日', key:'START_DATE',
					render:function(record, value){
						return value? Date.toROC(value) : "";
					}
				},
				{header:'業績計算迄日', key:'END_DATE',
					render:function(record, value){
						return value? Date.toROC(value) : "";
					}
				},
				{header:'報名日期', key:'INPUT_DATE',
					render:function(record, value){
						return value? Date.toROC(value) : "";
					}
				},
				{header:'確認日期', key:'CONFIRM_DATE',
					render:function(record, value){
						var hasBTN = false;
						var div = document.createElement('div');
						if(!isQueryByTEA_ID && '${userID}'==record.STU_ID && !record.CONFIRM_DATE){
            				var input_button = document.createElement("input");
							input_button.type = 'button';
							input_button.className="button"; 
							input_button.value = '確認';
                    		div.appendChild(input_button);
                    		input_button.onclick = function( event ) { doConfirm( record ) };
                    		hasBTN = true;
                    	}
						if(isQueryByTEA_ID|| ( '${userID}'==record.TEA_ID && !record.CONFIRM_DATE)){
            				var input_button = document.createElement("input");
            				input_button.className="button"; 
							input_button.type = 'button';
							input_button.value = '刪除';
                    		div.appendChild(input_button);
                    		input_button.onclick = function( event ) { doDelete( record ) };
                    		hasBTN = true;
                    	}
						if(hasBTN){
							return div; 
						}else{
							return value? Date.toROC(value) : "";
						}
					}
				}
			];
			return arrayColumn;
		},
		
		//查詢
		byQuery:function(){
			return gridColumn.byPrompt(true);
		},
		
		//查詢刪除紀錄
		ByDelQuery:function(){
			<%-- [20240930]  難字調整 --%>
			var arrayColumn = 
			[
				{header:'放款精英', key:'TEA_NM', style:"font-family:'EUDC'",
					render:function(record, value){
						return value ? value : "";
					}
				},
				{header:'被培育者姓名', key:'STU_NM', style:"font-family:'EUDC'",
					render:function(record, value){
						return value ? value : "";
					}
				},
				{header:'刪除日期', key:'INPUT_TIME',
					render:function(record, value){
						return value? Date.toROC(value) : "";
					}
				},
				{header:'刪除人員', key:'INPUT_NM', style:"font-family:'EUDC'",
					render:function(record, value){
						return value ? value : "";
					}
				}
	
			];
			return arrayColumn;
		}
	};
	
	//輸入
	function doInsert(){
		$('TEA_ID').value = $('TEA_ID').value.toUpperCase();
		$('STU_ID').value = $('STU_ID').value.toUpperCase();
		
		valid1.reset();
		validItemChange('doInsert');
		if(!valid1.validate()){	
			return;
		}
		
		var dataMap = {};
		dataMap.TEA_ID = $F('TEA_ID');
		dataMap.STU_ID = $F('STU_ID');
				
		var params = { inputMap:Object.toJSON(dataMap) };
		//成功
		var successActionOpen = function(resp){
			newGridTableByColumn(gridColumn.byPrompt());
			var rtnList = resp.rtnList ? resp.rtnList:[];
			grid.load(rtnList);
		};

		ajaxPost('doInsert',params,successActionOpen,null);
	}
	
	//確認
	function doConfirm(record){
		
		var dataMap = {};
		dataMap.TEA_ID = record.TEA_ID;
		dataMap.STU_ID = record.STU_ID;
		dataMap.START_DATE = record.START_DATE;
		dataMap.END_DATE = record.END_DATE;
		dataMap.INPUT_DATE = record.INPUT_DATE;

		var params = { inputMap:Object.toJSON(dataMap)};
		//成功
		var successActionOpen = function(resp){
			var rtnList = resp.rtnList ? resp.rtnList:[];
			grid.load(rtnList);
		};
		ajaxPost('doConfirm',params,successActionOpen,null);
		
	}
	
	//查詢
	function doQuery(){
		$('TEA_ID').value = $('TEA_ID').value.toUpperCase();
		$('STU_ID').value = $('STU_ID').value.toUpperCase();
		
		valid1.reset();
		validItemChange('doQuery');
		if(!valid1.validate()){	
			return;
		}
		
		var dataMap = {};
		dataMap.TEA_ID = $F('TEA_ID');
		dataMap.STU_ID = $F('STU_ID');
				
		var params = { inputMap:Object.toJSON(dataMap) };
		//成功
		var successActionOpen = function(resp){
			var rtnList = resp.rtnList ? resp.rtnList:[];
			grid.load(rtnList);
		};
		newGridTableByColumn(gridColumn.byQuery());
		ajaxPost('doQuery',params,successActionOpen,null);
	}
	
	//刪除
	function doDelete(record){
		
		var dataMap = {};
		dataMap.TEA_ID = record.TEA_ID;
		dataMap.STU_ID = record.STU_ID;
		dataMap.START_DATE = record.START_DATE;
		dataMap.END_DATE = record.END_DATE;
		dataMap.INPUT_DATE = record.INPUT_DATE;
		

		var params = { checkMap:Object.toJSON(dataMap)};
		//成功
		var successActionOpen = function(resp){
			var rtnList = resp.rtnList ? resp.rtnList:[];
			grid.load(rtnList);
		};
		ajaxPost('doDelete',params,successActionOpen,null);
		
	}
	
	//查詢刪除紀錄
	function doDelQuery(){
		$('TEA_ID').value = $('TEA_ID').value.toUpperCase();
		$('STU_ID').value = $('STU_ID').value.toUpperCase();
		
		valid1.reset();
		validItemChange('doDelQuery');
		if(!valid1.validate()){	
			return;
		}
		
		var dataMap = {};
		dataMap.TEA_ID = $F('TEA_ID');
		dataMap.STU_ID = $F('STU_ID');
				
		var params = { inputMap:Object.toJSON(dataMap) };
		//成功
		var successActionOpen = function(resp){
			var rtnList = resp.rtnList ? resp.rtnList:[];
			grid.load(rtnList);
		};

		newGridTableByColumn(gridColumn.ByDelQuery());
		ajaxPost('doDelQuery',params,successActionOpen,null);
	}
	
	function newGridTableByColumn(grigColumn){
		<%-- [20240930]  難字調整 --%>
		grid = new TableUI({
			table: $('grid'), pageSize: 10, allSortable: false,
			afterLoad: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},
			pageChange: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},	
			column:grigColumn
		});		
	}
	
	//變更檢核項目
	function validItemChange(act){
		if(act=='doInsert'){		
			commonTools.appendVaildName($('TEA_ID'),'checkROCID');//加入 放款精英ID 檢核
			commonTools.appendVaildName($('STU_ID'),'checkROCID');//加入 被培育者 ID 檢核
		}else if( act=='doDelQuery'){
			if ($('TEA_ID').value.length!=0){
			commonTools.appendVaildName($('TEA_ID'),'checkROCID');//加入 放款精英ID 檢核
			}else{
			commonTools.removeVaildName($('TEA_ID'),'checkROCID');//刪除 放款精英ID 檢核
			}
			if($('STU_ID').value.length!=0){
			commonTools.appendVaildName($('STU_ID'),'checkROCID');//加入 被培育者 ID 檢核
			}else{
			commonTools.removeVaildName($('STU_ID'),'checkROCID');//刪除 被培育者 ID 檢核
			}
		
		}else{
			commonTools.removeVaildName($('STU_ID'),'checkROCID');//移除 被培育者 ID 檢核
		}
	}
	
	var commonTools = {	
		//增加檢核項目
		appendVaildName:function(ele,vaildName){
			var className = ele.className;
			return ele.className = className.indexOf(vaildName)==-1 ? className + (" "+vaildName):className;
		},
		
		//移除檢核項目
		removeVaildName:function(ele,deleteName){
			var className = ele.className;
			return ele.className = className.replace(deleteName,'').trim();
		}
	};
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA4_0100/" + actionName,
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
		
			PageUI.createPageWithAllBodySubElement("DSA40100" , "經手人專區" , "放款精英報名系統" , 2 , false);
			
			newGridTableByColumn(gridColumn.byPrompt());
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			
			//輸入
			$('btn_insert').observe('click',function(event){
					doInsert();
				}
			);
			
			//查詢
			$('btn_query').observe('click',function(event){
					doQuery();
				}
			);
			
			//查詢刪除紀錄
			$('btn_delquery').observe('click',function(event){
					doDelQuery();
				}
			);
			buttonAuth();
			fix();
			displayMessage();
			
			if('${rtnList}'!=''){
				grid.load(${rtnList});
			}
			
			if('${TEA_ID}'==''){
				//若TEA_ID = “”，輸入按鈕disable
				$('btn_insert').disabled = true;
			}

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<span>
		
<!------------------------ A區--------------------->	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<form id="form1" name="form1" method="post">
				<tr>
					<td class="tbYellow" width="12%">
						放款精英ID
					</td>
					<td class="tbYellow2">
						<input id="TEA_ID" name="TEA_ID" type="text" class="textBox2 checkROCID " size="15" maxlength="10" fieldName="放款精英ID" value="${TEA_ID}" >
						<input id="btn_query" name="btn_query" type="button" class="button" value="查詢" >
						<input id="btn_delquery" name="btn_delquery" type="button" class="button" value="查詢刪除紀錄" >
					</td>
					<td class="tbYellow" width="12%">
						被培育者 ID
					</td>
					<td class="tbYellow2">
						<input id="STU_ID" name="STU_ID" type="text" class="textBox2 checkROCID "  size="15" maxlength="10" fieldName="被培育者 ID" value="">
						<input id="btn_insert" name="btn_insert" type="button" class="button" value="輸入" >
					</td>
				</tr>
			</form>
			</table>									
<!------------------------ B區--------------------->											
			<table id="grid" class="grid" width="100%"></table>	
			<DIV>
			<font color=red><b>1. 輸入被培育者ID後即無法更改，請確認後再輸入!!</font><br>
			<font color=red><b>2. 被培育者確認報名後才會正式參予競賽(務必請被培育者上報名系統進行確認)</font><br>
3.最多同時培育兩名<br>
4.(102年1工~報名日期)新件件數≧3件不得為被培育者<br>
5.放款精英與被培育者需為同一單位</DIV>			

</span>

</body>
<!-- InstanceEnd -->
</html>