<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA31500.jsp
作者：王文進
功能：鑑價進度查詢
完成：2012/3/16
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
Event.observe(window, 'load', new DSA31500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31500(){
	
	var valid1;
	var grid = {};

	<%--
	button控制
	--%>
	<%--	
	var buttonAuth = function (){
		var authButtons = {
			B0004:"btn_query" 
		};
		<dz:grantButtons FUNC_ID="DSA31500" ignored="false"/>
	};
	--%>
	
	//查詢
	function doQuery(){
		
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		var dataMap = {};
		dataMap.APPR_DEPT = $('APPR_DEPT').value;
		dataMap.APPR_ID = $('APPR_ID').value;
		dataMap.APPR_TYPE = $('APPR_TYPE').value;
		dataMap.DATE_BEG = $('DATE_BEG').value;
		dataMap.DATE_END = $('DATE_END').value;
				
		var params = { inputMap:Object.toJSON(dataMap) };
		//成功
		var successActionOpen = function(resp){
			var rtnList = resp.rtnList ? resp.rtnList:[];
			grid.load(rtnList);
		};
		//失敗
		var errorActionOpen = function(resp){
			grid.load([]);
		};
		ajaxPost('query',params,successActionOpen,errorActionOpen);
	}
	
	//取得鑑價人員
	function doGetAPPR_ID_LIST(){
		
		if(''==$('APPR_DEPT').value){
			$('APPR_ID').length = 1;
			return;
		}
		
		var dataMap = {};
		dataMap.APPR_DEPT = $('APPR_DEPT').value;
				
		var params = { inputMap:Object.toJSON(dataMap) };
		//成功
		var successActionOpen = function(resp){
			var optionList = resp.APPR_ID_LIST ? resp.APPR_ID_LIST:[];
			$('APPR_ID').length = 1;
			for(var i = 0; i < optionList.length; i++){
				$('APPR_ID').options.add(new Option(optionList[i]['NAME'], optionList[i]['ID']));
			}
		};
		ajaxPost('getAPPR_ID_LIST',params,successActionOpen,null);
	}
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA3_1500/" + actionName,
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
		
			PageUI.createPage("DSA31500" , "鑑價作業" , "鑑價影像追蹤");
			PageUI.loadin(["tableA","grid"] ,1);
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				[ 'chkAPPR_DEPT',  '鑑價科與鑑價人員需擇一輸入', 
					function(){ 
						$('APPR_ID').style.backgroundColor = "#FFFFFF";
						$('APPR_DEPT').style.backgroundColor = "#FFFFFF";
						if($F('APPR_DEPT') == '' && $F('APPR_ID') == ''){ 
							$('APPR_ID').style.backgroundColor = "#FFB0AF";
							$('APPR_DEPT').style.backgroundColor = "#FFB0AF";
							return false; 
						} 
						return true; 
					} 
				],
				[ 'chkDATE_END',  '必須輸入', function(){ if($F('DATE_END') == ''){ return false; } return true; } ],
				[ 'chkDATE_BEG',  '必須輸入', function(){ if($F('DATE_BEG') == ''){ return false; } return true; } ] 
			]);
			
			//產生 Grid 物件                
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 10, allSortable: true,
					<%-- [20240930] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "鑑價組", key: "APPR_GROUP_NM",
							render:function(record, value){
							 	return value ? value : '';
							}
						},
						{ header: "覆核日", key: "FIRST_BOSS_DATE",
							render:function(record, value){
							 	return value ? Date.toROC(value) : '';
							}
						},
						{ header: "受理編號", key: "APPLY_ID",
							render:function(record, value){
							 	return value ? value : '';
							}
						},
						{ header: "受理進度", key: "APPLY_PROCESS_NM",
							render:function(record, value){
								return value ? value : '';
							}
						},
						{ header: "室內照拍攝說名", key: "NOPIC_REASON_NM",
							render:function(record, value){
								return value ? value : '';
							}
						},
						{ header: "鑑價人員", key: "APPR_NM", attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
							render:function(record, value){
							 	return value ? value : '';
							}
						},
						{ header: "徵信人員", key: "CRED_NM", attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
							render:function(record, value){
							 	return value ? value : '';
							}
						}
					]
				}
			);
			
			//查詢
			$('btn_query').observe('click',function(event){
					doQuery();
				}
			);
			
			//清除
			$('btn_clear').observe('click',function(event){
					$('form1').reset();
					$('DATE_BEG').value = '${DATE_BEG}';
					$('DATE_END').value = '${DATE_END}';
					grid.load([]);
				}
			);

			//取得「鑑價人員」下拉選單			
			$('APPR_DEPT').observe('change',function(event){
					doGetAPPR_ID_LIST();
				}
			);
						
			//buttonAuth();

			displayMessage();
			
			$('DATE_BEG').value = '${DATE_BEG}';
			$('DATE_END').value = '${DATE_END}';
		}                 
	}

}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<form id="form1" name="form1" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
		<tr>
		    <td class="tbYellow" width="10%">
					鑑價科
			</td>
			<td class="tbYellow2" width="20%">
				<select name="APPR_DEPT" id="APPR_DEPT" class="chkAPPR_DEPT">
					<option value=''>全部</option>
					<c:forEach var="map" items="${APPR_DEPT_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" width="10%">
				鑑價人員
			</td>
			<td class="tbYellow2" width="20%">
				<select name="APPR_ID" id="APPR_ID" alt="ch"><%--[20240930]難字調整 --%>
					<option value=''>全部</option>
					<c:forEach var="map" items="${APPR_ID_LIST}">
						<option value="${map.ID}">${map.NAME}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" width="10%">
				案件類別
			</td>
			<td class="tbYellow2" width="20%">
				<select name="APPR_TYPE" id="APPR_TYPE">
					<c:forEach var="map" items="${APPR_TYPE_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="center" rowspan="2" width="10%">
				<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
				<input id="btn_clear" name="btn_clear" type="button" class="button" value="清除">
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width ="10%">覆核日期</td>
			<td class="tbYellow2" colspan="5" width ="80%">
				<input name="DATE_BEG" id='DATE_BEG' type="text" class="textBox2 validate-ROCDate chkDATE_BEG" size="10" maxlength="7" value="" datatype="ROCDate" fieldName="覆核日期起">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('DATE_BEG'))">
				~
				<input name="DATE_END" id='DATE_END' type="text" class="textBox2 validate-ROCDate chkDATE_END" size="10" maxlength="7" value="" datatype="ROCDate" fieldName="覆核日期迄">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('DATE_END'))">  
			</td>
		</tr>
	</table>
	
	<table id="grid" class="grid"></table>
	
	</form>

</body>
<!-- InstanceEnd -->
</html>
