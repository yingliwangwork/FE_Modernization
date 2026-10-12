<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA31100.jsp
作者：王文進
功能：銀行案件查詢
完成：2012/4/3
更新：
[20240930]難字調整
-->

<html>
<head>
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
Event.observe(window, 'load', new DSA31100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31100(){
	
	var valid1;
	var column1;
	var grid = {};

	<%--
	button控制
	--%>
	<%--	
	var buttonAuth = function (){
		var authButtons = {
			B0004:"btn_query" 
		};
		<dz:grantButtons FUNC_ID="DSA31100" ignored="false"/>
	};
	--%>
	
	//查詢
	function doQuery(){
		
		$('BANK_DEPT').value = $('BANK_DEPT').value.toUpperCase();
		
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		var dataMap = {};
		dataMap.BANK_DEPT = $('BANK_DEPT').value;
		dataMap.QUERY_DATE = $('QUERY_DATE').value;
		dataMap.QUERY_DATE_BEG = $('QUERY_DATE_BEG').value;
		dataMap.QUERY_DATE_END = $('QUERY_DATE_END').value;
		dataMap.APPLY_PROCESS = $('APPLY_PROCESS').value;
				
		var params = { inputMap:Object.toJSON(dataMap) };
		//成功
		var successActionOpen = function(resp){
			rtnList = resp.rtnList ? resp.rtnList : [];	 
			grid.load(rtnList);
		};
		//成功
		var errorActionOpen = function(resp){	 
			grid.load([]);
		};
		
		ajaxPost('query',params,successActionOpen,errorActionOpen);
	}
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		beanName = 'DSA3_2400'=='${fromPublicBean}' ? '${fromPublicBean}' : 'DSA3_1100';
		actionName = 'DSA3_2400'=='${fromPublicBean}' ? 'queryByDSA3_1100' : actionName;
		new Ajax.Request( "<%=dispatcher%>/"+beanName+"/" + actionName,	
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
		
			PageUI.createPage("DSA31100" , "鑑價作業" , "銀行案件查詢");
			PageUI.loadin(["tableA","grid"] ,1);
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				[ 'chkQUERY_DATE',  '查詢日期與查詢進度，必須擇一輸入', 
					function(){ 
						$('QUERY_DATE').style.backgroundColor = "#FFFFFF";
						$('APPLY_PROCESS').style.backgroundColor = "#FFFFFF";
						if($F('QUERY_DATE') == '0' && $F('APPLY_PROCESS') == '0'){ 
							$('QUERY_DATE').style.backgroundColor = "#FFB0AF";
							$('APPLY_PROCESS').style.backgroundColor = "#FFB0AF";
							return false; 
						} 
						return true; 
					} 
				],
				[ 'chkBANK_DEPT',  '必須輸入', function(){ if($F('BANK_DEPT') == ''){ return false; } return true; } ],
				[ 'chkQUERY_DATE_BEG',  '必須輸入', function(){ if($F('QUERY_DATE_BEG') == ''){ return false; } return true; } ],
				[ 'chkQUERY_DATE_END',  '必須輸入', function(){ if($F('QUERY_DATE_END') == ''){ return false; } return true; } ],
				[ 'chkDiffDay1',  '不可大於迄日', 
					function(){ 
						return (diffDayROC( $F('QUERY_DATE_BEG') , $F('QUERY_DATE_END') ) >= 0); 
					}
				],
				[ 'chkDiffDay2',  '查詢日期區間不得超過三個月(九十天)', 
					function(){ 
						return (diffDayROC( $F('QUERY_DATE_BEG') , $F('QUERY_DATE_END') ) < 90); 
					}
				]
			]);
			
			//產生 Grid 物件                
			grid = new TableUI({
				table: $('grid'), pageSize: 10, allSortable: true,
				<%-- [20240930] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{header:'受理編號', key:'APPLY_ID',
							render:function(record, value){
									var alink = document.createElement("a");
									alink.href = "#";
									alink.innerHTML = value ? value : '';
									alink.onclick = function(){
										var form = $("form1");
						 				var url = "";
				 						if(${IS_BANK_USER}){
							 				if(record.QUERY_TYPE=='1'){
							 					//鑑價報告
							 					url = "<%=dispatcher%>/DSA3_2400/prompt";
							 				}else if(record.QUERY_TYPE=='2'){
							 					//土建融鑑價報告
							 					url = "<%=dispatcher%>/DSA3_2400/prompt";
						 					}else if(record.QUERY_TYPE=='3'){
						 						//整批分戶鑑價報告
						 						url = "<%=dispatcher%>/DSA3_2400/prompt";
						 					}
							  				popupWin.windowOpen(url,{
			                					'parameters': {APPLY_ID: record.APPLY_ID, //受理編號
			                								   CathayNo: record.APPLY_ID,
			                								   ActionType: '0'+record.QUERY_TYPE //交易種類
			                					}
			 	          					  });
				 	       				} else {
						 					if(record.QUERY_TYPE=='1'){
						 						//鑑價報告
						 						url = "<%=dispatcher%>/DSA3_0500/prompt";
						 					}else if(record.QUERY_TYPE=='2'){
							 					//土建融鑑價報告
							 					url = "<%=dispatcher%>/DSA3_0600/prompt";
							 				}else if(record.QUERY_TYPE=='3'){
							 					//整批分戶鑑價報告
							 					url = "<%=dispatcher%>/DSA3_0700/prompt";
							 				}
							  				 popupWin.windowOpen(url,{
			                					 'parameters': {APPLY_ID: record.APPLY_ID}
			 	          					  });
						 				}
						  				
						  				//window.open(url, "DSA3_1100", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
									};
									return alink;
							}
					},
					{header:'借款人姓名', key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
						render:function(record, value){
						 	return value ? value : '';
						}
					},
					{header:'受理進度', key:'APPLY_PROCESS_NM',
						render:function(record, value){
						 	return value ? value : '';
						}
					},
					{header:'送件日期', key:'SEND_DATE',
						render:function(record, value){
						 	return value ? Date.toROC(value) : '';
						}
					},
					{header:'核覆日期', key:'REPORT_DATE',
						render:function(record, value){
						 	return value ? Date.toROC(value) : '';
						}
					},
					{header:'結案日期', key:'CLOSE_DATE',
						render:function(record, value){
							return value ? Date.toROC(value) : '';
						}
					},
					{header:'鑑價人員', key:'APPR_NM', attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
						render:function(record, value){
							return value ? value : '';
						}
					},
					{header:'核覆主管', key:'BOSS_NM', attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
						render:function(record, value){
							return value ? value : '';
						}
					}
				]
			});
			
			//查詢
			$('btn_query').observe('click',function(event){
					doQuery();
				}
			);
			
			//清除
			$('btn_clear').observe('click',function(event){
					$('form1').reset();
					$('QUERY_DATE_BEG').value = '${QUERY_DATE_BEG}';
					$('QUERY_DATE_END').value = '${QUERY_DATE_END}';
					grid.load([]);
				}
			);
						
			//buttonAuth();

			displayMessage();

			$('QUERY_DATE_BEG').value = '${QUERY_DATE_BEG}';
			$('QUERY_DATE_END').value = '${QUERY_DATE_END}';
			
			if('1'!=='${CheckId}' && ${IS_BANK_USER}){
				$('BANK_DEPT').readOnly = true;
			}
		}                 
	}
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0"
	marginheight="0">
<form id="form1" name="form1" method="post">

<table width="100%" border="0" cellpadding="0" cellspacing="1"
	class="tbBox2" id="tableA">
	<tr>
		<td class="tbYellow" width="8%">分行代號</td>
		<td class="tbYellow2" colspan="5" width="4%"><input type="text"
			class="textBox chkBANK_DEPT" fieldName="分行代號" id="BANK_DEPT"
			name="BANK_DEPT" size="4" maxlength="3" value="${BankDept}">
		</td>
		<td class="tbYellow" width="8%">查詢日期</td>
		<td class="tbYellow2" width="36%"><select name="QUERY_DATE"
			id="QUERY_DATE" class="chkQUERY_DATE">
			<c:forEach var="map" items="${QUERY_DATE_LIST}">
				<option value="${map.key}">${map.value}</option>
			</c:forEach>
		</select> <input name="QUERY_DATE_BEG" id='QUERY_DATE_BEG' type="text"
			class="textBox2 validate-ROCDate chkQUERY_DATE_BEG chkDiffDay1"
			size="8" maxlength="7" datatype="ROCDate" value=""
			fieldName="查詢日期起日"> <img id="calImg"
			src="<%=imageBase%>/CM/calendar.gif" alt="Date"
			onclick="getCalendarFor($('QUERY_DATE_BEG'))"> ~ <input
			name="QUERY_DATE_END" id='QUERY_DATE_END' type="text"
			class="textBox2 validate-ROCDate chkQUERY_DATE_END chkDiffDay2"
			size="8" maxlength="7" datatype="ROCDate" value=""
			fieldName="查詢日期迄日"> <img id="calImg"
			src="<%=imageBase%>/CM/calendar.gif" alt="Date"
			onclick="getCalendarFor($('QUERY_DATE_END'))"></td>
		<td class="tbYellow" width="8%">查詢進度</td>
		<td class="tbYellow2" width="16%"><select name="APPLY_PROCESS"
			id="APPLY_PROCESS" fieldName="查詢進度">
			<c:forEach var="map" items="${APPLY_PROCESS_LIST}">
				<option value="${map.key}">${map.value}</option>
			</c:forEach>
		</select></td>
		<td class="tbYellow" width="16%"><input id="btn_query"
			name="btn_query" type="button" class="button" value="查詢"> <input
			id="btn_clear" name="btn_clear" type="button" class="button"
			value="清除"></td>
	</tr>
</table>

<table id="grid" class="grid"></table>
</form>
</body>
<!-- InstanceEnd -->
</html>
