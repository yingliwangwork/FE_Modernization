<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA30100.jsp
作者：王文進
功能：鑑價進度查詢
完成：2012/3/16
更新：

[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
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
Event.observe(window, 'load', new DSA30100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA30100(){
	
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
		<dz:grantButtons FUNC_ID="DSA30100" ignored="false"/>
	};
	--%>
	
	//查詢
	function doQuery(){
		$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
		
		valid1.reset();
		if(!valid1.validate()){	
			return;
		}
		
		var dataMap = {};
		if($('APPR_RADIO_1').checked){
			dataMap.APPR_RADIO = $('APPR_RADIO_1').value;
			dataMap.APPR_DEPT = $('APPR_DEPT').value;
			dataMap.APPR_GROUP = $('APPR_GROUP').value;
			dataMap.APPR_ID = $('APPR_ID').value;		
		}else{
			dataMap.APPR_RADIO = $('APPR_RADIO_3').value;
			dataMap.APPLY_ID = $('APPLY_ID').value;
		}
		dataMap.APPLY_PROCESS = $('APPLY_PROCESS').value;
		dataMap.DATE_KIND = $('DATE_KIND').value;
		dataMap.EQU_SIGN = $('EQU_SIGN').value;
		dataMap.Q_DATE = $('Q_DATE').value;
				
		var params = { inputMap:Object.toJSON(dataMap) };
		
		// 真分頁功能處理
		grid.load( "<%=dispatcher%>/DSA3_0100/query", params);
			
		/*	//TODO 
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
		*/
	}
	
	//取得鑑價人員
	function doGetAPPR_ID_LIST(){
		
		if(''==$('APPR_GROUP').value){
			return;
		}
		
		var dataMap = {};
		dataMap.APPR_GROUP = $('APPR_GROUP').value;
				
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
	
	//鑑價影像檔             
	function doGetFile(rec){
				
		var params = { inputMap:Object.toJSON(rec)};
		//成功
		//var successActionOpen = function(resp){
		//	if(resp.apprPath && resp.apprPath!=''){
		//		var theAction = resp.apprPath;
		//		window.open(theAction);
		//	}else{
		//		alert('取得鑑價影像檔失敗');
		//	}
		//};
		var successActionOpen = function(resp){
			if(resp.isExternal && resp.isApprExternalAuth) { //高級主管由外網登入開啟影像
				RPTUtil.download({'downloadFileName': resp.apprFileNM,	'downloadFileFullPath': resp.apprPath});
			} else {
				window.open(resp.apprPath);
			}
		};
		
		ajaxPost('getFile',params,successActionOpen,null);
	}
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA3_0100/" + actionName,
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
		
			PageUI.createPage("DSA30100" , "鑑價作業" , "鑑價進度查詢");
			PageUI.loadin(["tableA","grid"] ,1);
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				[ 'chkAPPLY_ID',  '請輸入受理編號!', function(){ if($('APPR_RADIO_3').checked && $F('APPLY_ID') === ""){ return false; } $('APPLY_ID').value=$F('APPLY_ID').toUpperCase(); return true; } ] ,
				[ 'validateAPPLY_ID',  '請輸入正確受理編號!', function(){ if($('APPR_RADIO_3').checked && $F('APPLY_ID').length != 11){ return false; } $('APPLY_ID').value=$F('APPLY_ID').toUpperCase(); return true; } ],
				[ 'chkAPPR_DEPT',  '鑑價科、鑑價組與鑑價人員需擇一輸入', function(){ if($('APPR_RADIO_1').checked && $F('APPR_DEPT') == '' && $F('APPR_GROUP') == '' && $F('APPR_ID') == ''){ return false; } return true; } ],
				[ 'chkDATE_KIND',  '日期必須輸入', function(){ if($F('EQU_SIGN') != '' && $F('Q_DATE') == ''){ return false; } return true; } ],
				[ 'chkAPPLY_PROCESS',  '無室內照日期查詢功能僅能查詢銀行件且進度超過鑑價未核覆', function(){ if($F('DATE_KIND') == '3' && $F('EQU_SIGN') == '=' && $F('Q_DATE') == '' && $F('APPLY_PROCESS') != '40' && $F('APPLY_PROCESS') != '45' && $F('APPLY_PROCESS') != '50' && $F('APPLY_PROCESS') != '51'){ return false; } return true; } ],
				[ 'chkRequired',  '鑑價科radio、受理編號radio需擇一輸入', function(){ if(!$('APPR_RADIO_1').checked && !$('APPR_RADIO_3').checked){ return false; } $('APPLY_ID').value=$F('APPLY_ID').toUpperCase(); return true; } ] 
			]);
			
			//產生 Grid 物件                
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 10, allSortable: true,
					isLoadByFatch : true,//真分頁每批數量設定 
					column:[
						{ header: "受理編號", key: "APPLY_ID",
							render:function(record, value){
								//CSRUtil.keepParamsManager.put({'APPLY_ID': record.APPLY_ID });
								var alink = document.createElement("a");
								alink.href = "#";
								alink.innerHTML = record.APPLY_ID;
								alink.onclick = function(){
									var form = $("form1");
									var url;
					 				if (record.APPLY_ID.substring(3,5)=='@A' || record.APPLY_ID.substring(3,5)=='@I' || record.APPLY_ID.substring(3,5)=='@J') {
						 				url = "<%=dispatcher%>/DSA3_0600/prompt?OP=1&APPLY_ID="+record.APPLY_ID;
					 				} else if (record.APPLY_ID.substring(3,5)=='@B' || record.APPLY_ID.substring(3,5)=='@U' || record.APPLY_ID.substring(3,5)=='@V') {
						 				url = "<%=dispatcher%>/DSA3_0700/prompt?OP=1&APPLY_ID="+record.APPLY_ID;
					 				} else {
						 				url = "<%=dispatcher%>/DSA3_0500/prompt?OP=1&APPLY_ID="+record.APPLY_ID;
					 				}
					 				window.location = url;
								};
								return alink;
							}
						},
						{ header: "照片", key: "CHECK_IMAGE_NM",
							render:function(record, value){
								if(record.CHECK_IMAGE != '' && record.CHECK_IMAGE != null){
									var alink = document.createElement("a");
									alink.href = "#";
									alink.innerHTML = '<img id="calImg" src="<%=imageBase%>/DS/pic1.gif" style="cursor:hand">';
									alink.onclick = function(){
										doGetFile(record);
									};
									return alink;
								}else{
									return value;
								}
							}
						},
						/*{ header: "借款人", key: "BORROW_NAME",
							render:function(record, value){
							 	return value ? value : '';
							}
						},*/
						{ header: "受理進度", key: "APPLY_PROCESS_NM",
							render:function(record, value){
							 	return value ? value : '';
							}
						},
						{ header: "派件日期", key: "ASSIGN_DATE",
							render:function(record, value){
							    var REASSIGN_DATE = record.REASSIGN_DATE;
							 	return REASSIGN_DATE ? Date.toROC(REASSIGN_DATE) : (value ? Date.toROC(value) : '');
							}
						},
						{ header: "優先", key: "ELITE_AGENT",
							 render:function(record,value){
								if(value){
									value = '<font color="red">' + value + '</font>';
								}
							 	return value;
							}
						},
						{ header: "組別", key: "APPR_GROUP_NM",
							render:function(record, value){
							 	return value ? value : '';
							}
						},
						{ header: "鑑價人員", key: "APPR_NM", styles:{'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6--%>
							render:function(record, value){
								//[ 智能流程後續優化20211221 ] 智能件顯示
								if(record.IS_AUTOAPPR =='2'){
									return '智能件';
								}
							 	return value ? value : '';
							}
						},
						{ header: "地址", key: "ADDR_NO", styles:{'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6--%>
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
					$('APPR_RADIO_1').click();
					$('APPLY_ID').value = '${param.APPLY_ID}';
				}
			);
			
			//radio
			$('APPR_RADIO_1').observe('click',function(event){
					//鑑價科、鑑價組、鑑價人員下拉選單enable
					$('APPR_DEPT').disabled=false;
					$('APPR_GROUP').disabled=false;
					$('APPR_ID').disabled=false;
					$('APPLY_ID').disabled=true;
				}
			);
			
			//radio
			$('APPR_RADIO_3').observe('click',function(event){
					//審查科下拉選單enable
					$('APPR_DEPT').disabled=true;
					$('APPR_GROUP').disabled=true;
					$('APPR_ID').disabled=true;
					$('APPLY_ID').disabled=false;
				}
			);

			//取得「鑑價人員」下拉選單			
			$('APPR_GROUP').observe('change',function(event){
					doGetAPPR_ID_LIST();
				}
			);
						
			//buttonAuth();

			displayMessage();
			
			$('APPR_RADIO_1').click();
			
			$('Q_DATE').value = getToday();
			
			if('${APPR_ID}'!=''){
				$('APPR_ID').value = '${APPR_ID}';
			}
			
			$('APPLY_PROCESS').value = '0';
			
			$('DATE_KIND').value = '2';

			$('EQU_SIGN').value = '<=';

			if('${param.APPLY_ID}'!=''){
				$('APPLY_ID').value = '${param.APPLY_ID}';
				doQuery();
			}
		}                 
	}

}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<form id="form1" name="form1" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
		<tr>
			<td class="tbYellow">
		      	<input type="radio" name="APPR_RADIO" id="APPR_RADIO_1" value="1" class="chkRequired">
		    </td>
		    <td class="tbYellow" width="10%">
				鑑價科
			</td>
			<td class="tbYellow2" width="10%">
				<select name="APPR_DEPT" id="APPR_DEPT" class="chkAPPR_DEPT">
					<option value=''>全部</option>
					<c:forEach var="map" items="${APPR_DEPT_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" width="7%">
				鑑價組
			</td>
			<td class="tbYellow2" width="22%">
				<select name="APPR_GROUP" id="APPR_GROUP" class="chkAPPR_DEPT">
					<option value=''>全部</option>
					<c:forEach var="map" items="${APPR_GROUP_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" width="11%">
				鑑價人員
			</td>
			<td class="tbYellow2" width="10%">
				<%---[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				<select name="APPR_ID" id="APPR_ID" alt="ch">
					<option value=''>全部</option>
					<c:forEach var="map" items="${APPR_ID_LIST}">
						<option value="${map.ID}">${map.NAME}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" align="center" rowspan="4" >
				<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
				<input id="btn_clear" name="btn_clear" type="button" class="button" value="清除">
			</td>
		</tr>
		
		<tr>
			<td class="tbYellow">
		      	<input type="radio" name="APPR_RADIO" id="APPR_RADIO_3" value="3" class="chkRequired">
		    </td>
			<td class="tbYellow" width="10%">
				受理編號
			</td>
			<td class="tbYellow2"  colspan="5">
				<input type="text" class="textBox chkAPPLY_ID validateAPPLY_ID" id="APPLY_ID" name="APPLY_ID" size="11" maxlength="11">
			</td>
		</tr>
		<tr>
			<td class="tbYellow" colspan="2">
				受理進度
			</td>
			<td class="tbYellow2" colspan="5">
				<select name="APPLY_PROCESS" id="APPLY_PROCESS" class="chkAPPLY_PROCESS">
					<option value=''>全部</option>
					<option value='0'>處理中</option>
					<c:forEach var="map" items="${APPLY_PROCESS_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>

				<select name="DATE_KIND" id="DATE_KIND">
					<c:forEach var="map" items="${DATE_KIND_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>

				<select name="EQU_SIGN" id="EQU_SIGN">
					<c:forEach var="map" items="${EQU_SIGN_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
				<input id="Q_DATE" name="Q_DATE" type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('Q_DATE'))">
			</td>
		</tr>
	</table>
	
	<table id="grid" class="grid"></table>
	
	</form>

</body>
<!-- InstanceEnd -->
</html>
