<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSA30310.jsp
作者：陳怡樺
功能：智能件案件分派移轉作業。
完成：2021-06-15

[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
-->

<html> 
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--匯入外部Javascript 與 css-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>	
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>

<style type="text/css">
@font-face {
font-family: 'EUDC';
  src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
       url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
 font-weight: normal;
 font-style: normal
}
</style>

<script type='text/javascript'>

<%--產生畫面物件--%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp--%>
Event.observe(window, 'load', new DSA30310().initApp);

function DSA30310(){
	<%--查詢的檢核--%>
	var valid1;
	<%--派件的檢核--%>
	var valid2;
	var grid;		
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_0310/');	
	<%--前次查詢條件--%>
	var queryCondition = {APPR_DEPT : "" , APPR_GROUP :"" , APPLY_PROCESS : "", RPA_STATUS : "", APPLY_ID : ""};			
	<%--按鈕權限--%>
	function buttonAuth(){
		var authButtons = {
				B0021:"btn_export"<%--匯出--%>,
				B0067:"btn_assign"<%--派件--%>,
				B0097:"btn_transfer"<%--移轉--%>,
				B0256:"btn_smart"<%--智能派件--%>
		};
		
		<dz:grantButtons FUNC_ID="DSA30310" ignored="false"/>
	}
	<%--畫面檢核--%>
	function initValidation(){
	
		Validation.addAllThese([	
		[ 'validateAPPLY_ID',  '受理編號長度不正確 需為11碼', 
			function(v){				
				return (v!=="" && v.length != 11) ? false : true ;   
			} ],		
		[ 'validateChooseCFM_ID',  '覆核人員與支援人員請擇一輸入', 
			<%--當CFM_ID為空值,其中兩個只能擇一輸入--%>
			function(){				
				var CFM_ID = $("CFM_ID").getValue();
				var SUPPORT_ID = $("SUPPORT_ID").getValue();		
				if( (CFM_ID !=="" && SUPPORT_ID !=="") || (CFM_ID ==="" && SUPPORT_ID ==="")){					
					return false;
				}else{
					return true;
				}
			}]
		]);
		<%--查詢用檢核--%>
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "validateAPPLY_ID" , { id: "APPLY_ID" } );
				
		<%--派件,移轉用檢核--%>
		valid2 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid2.define( "validateChooseCFM_ID" , { id: "CFM_ID" } );	
		valid2.define( "validateChooseCFM_ID" , { id: "SUPPORT_ID" } );	
	}	
	
	var actions = {
		<%--將畫面A資料存成Record--%>
		makeRecord : function(){
			var sendRecord = {
				APPR_DEPT	: $('APPR_DEPT').getValue() ,<%--鑑價科--%>
				APPR_GROUP	: $('APPR_GROUP').getValue() ,<%--鑑價組--%>
				APPLY_PROCESS	: $('APPLY_PROCESS').getValue() ,<%--受理進度--%>
				USE_SECT_UPD_STATUS : $('USE_SECT_UPD_STATUS').getValue() ,<%--RPA分區更新--%>
				APPLY_ID	: $('APPLY_ID').getValue() <%--受理編號--%>			
			}
			return sendRecord;	
		},
		<%--將List增加到下拉選單中--%>
		appendList : function(list , target){
			<%--先清除--%>
			actions.updateList(target);	
			<%--加入List--%>	
			if(list){
				for(var i = 0; i < list.length; i++){ 
					target.options.add(new Option(list[i]['NAME'], list[i]['ID'])); 
				}
			}
			<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			parseEUDC();
		},
		<%--將收下拉選單清除,加入請選擇 , target為要清除的dom物件--%>
		updateList : function(target){
			target.update();
			target.options.add(new Option( "請選擇" , "")); 
		},
		<%--將畫面資料存成要派件或轉移的List--%>
		makeEditRecord : function(list){
			var editList = [];
			for(var i = 0 ; i < list.length ; i++){
				var tempMap = {};
				tempMap["APPLY_ID"] = list[i]["APPLY_ID"];      <%--受理編號--%>
				tempMap["CFM_ID"] = $("CFM_ID").getValue() ;         <%--覆核人員--%>
				tempMap["SUPPORT_ID"] = $("SUPPORT_ID").getValue()  ;<%--支援人員--%>
				editList.push(tempMap);
			}
			return editList;
		}
	};
	var buttons = {
		<%--查詢--%>
		doQuery : function(event){
			
			$('APPLY_ID').setValue($F('APPLY_ID').toUpperCase());
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			<%--將畫面欄位存成record--%>
			var sendRecord = actions.makeRecord();	
			<%--將查詢條件存起來--%>
			queryCondition = sendRecord;	
			<%--發送ajax--%>
			ajaxRequest.post( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){	
					grid.load(resp.rtnList);
					actions.appendList(resp.CFM_ID_LIST , $("CFM_ID"));
					actions.appendList(resp.SUPPORT_ID_LIST ,$("SUPPORT_ID"));					
				},
				function(resp){					
					<%--失敗把前次內容清掉 並把鑑價,支援人員list清掉--%>
					grid.load([]);				
					actions.updateList($("CFM_ID"));
					actions.updateList($("SUPPORT_ID"));
				}
			);		
			
		},	
		<%--匯出Excel--%>
		doExport : function(event){
			
			$('APPLY_ID').setValue($F('APPLY_ID').toUpperCase());
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}	
			$('gridJSON').value = grid.getXlsSettingJSON('案件分派移轉作業');
			RPTUtil.executeCreateXlsFile('${dispatcher}/DSA3_0310/export', Form.serialize("form1"));
			
		},
		<%--派件--%>
		doAssign : function(event){
			
			valid2.reset();
			var checkAssignList = grid.getCheckedRecord();
			if(checkAssignList.length == 0){
				alert("尚未點選任何案件!!");
				return;
			}
			<%--頁面 檢核--%>
			if(!valid2.validate()){ 
				return; 
			}	
			
			<%--將條件Map存起來--%>
			var assignRecord = actions.makeEditRecord(checkAssignList); 
			ajaxRequest.post( 'assign' , 
				{
					assignRecord : Object.toJSON(assignRecord), <%--畫面勾選的records--%>
					sendRecord : Object.toJSON(queryCondition) <%--上次查詢的條件--%>		
				},
				function(resp){			
					<%--重查,並紀錄新的List--%>			
					grid.load(resp.rtnList);					
				}
			);	
		},
		<%--移轉--%>
		doTransfer : function(event){
			
			valid2.reset();
			var checkTransferList = grid.getCheckedRecord();
			if(checkTransferList.length == 0){
				alert("尚未點選任何案件!!");
				return;
			}
			<%--頁面 檢核--%>
			if(!valid2.validate()){ 
				return; 
			}
			
			<%--將條件Map存起來--%>
			var transferRecord = actions.makeEditRecord(checkTransferList); 
			<%--發送ajax--%>
			ajaxRequest.post( 'transfer' , 
				{
					transferRecord : Object.toJSON(transferRecord), <%--畫面勾選的records--%>
					sendRecord : Object.toJSON(queryCondition) <%--上次查詢的條件--%>
				},
				function(resp){			
					<%--重查,並紀錄新的List--%>			
					grid.load(resp.rtnList);					
				}
			);	
		},
		<%--清除畫面 回到初始狀況--%>
		doClear : function(event){
			<%--將 覆核人員 支援人員 ,清空--%>
			actions.updateList($("CFM_ID"));
			actions.updateList($("SUPPORT_ID"));
			$('form1').reset();		
		}
	};
	return {

			initApp : function() {
				<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' />
				PageUI.createPageWithAllBodySubElement(
					'DSA30310',
					'智能件分派移轉作業',
					'智能件分派移轉作業'
				);
					
				grid = new TableUI ( {
					table: $("grid"), pageSize: 20, allSortable:true,
					autoCheckBox:{					
						isSelectAll:true
					},
					column:[
						{header: "受理編號",key: "APPLY_ID",
							render:function(record, value){
								CSRUtil.keepParamsManager.put({'APPLY_ID': record.APPLY_ID });
								var alink = new Element("a", { 'href' : "javascript:void(0);"}).update(record.APPLY_ID);
								alink.observe('click', function(){
									var url = "${dispatcher}/DSA3_0200/prompt";
					 				popupWin.windowOpen( url ,{
						        		parameters: {APPLY_ID : record.APPLY_ID},
										windowName : record.APPLY_ID.replace('@', "")
						    		});
								});
								return alink;
							}
						},		
						{header: "收件日期",key: "RECEIVE_DATE",sortRule:'date'},
						{header: "擔保品地址",key: "GAGE_ADDR1", attrs:{align:'left'}, styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						{header: "案名",key: "CASE_NAME"},
						{header: "社區外觀照日期",key: "UPDATE_PIC_DATE",sortRule:'date'},
						{header: "前件外觀照日期",key: "APPR_PIC_DATE",sortRule:'date'},
						{header: "受理進度",key: "APPLY_PROCESS_NM"},
						{header: "智能流程進度",key: "IS_AUTOAPPR"},
						{header: "是否免拍",key: "IS_PHOTO"},
						{header: "RPA分區更新",key: "USE_SECT_UPD_STATUS_NM"},
						{header: "土地面積(坪)",key: "A040_LAND_SPACE",
							render : function(rec , val){
								return val ? CSRUtil.$fmt(val, '#,###.###') :'';
							}
						},
						{header: "建物面積(坪)",key: "A050_BUILD_SPACE",
							render : function(rec , val){
								return val ? CSRUtil.$fmt(val, '#,###.###') :'';
							}
						},
						{header: "鑑價組",key: "APPR_GROUP_NM"},													
						{header: "覆核人員",key: "CFM_NM", styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						{header: "派件日期",key: "ASSIGN_DATE",sortRule:'date'},
						{header: "社區建築型態",key: "A350_USE_FOR_NM"},
						{header: "前件建築型態",key: "USE_FOR_NM"}
					]
					
				});
					
					
				$("btn_query").observe("click", buttons.doQuery );<%--查詢--%>
				$("btn_export").observe("click", buttons.doExport );<%--匯出--%>
				$("btn_assign").observe("click", buttons.doAssign );<%--派件--%>	
				$("btn_transfer").observe("click", buttons.doTransfer );<%--移轉--%>
				$("btn_clear").observe("click", buttons.doClear );<%--清除--%>	
					
				initValidation();	
				
				displayMessage();	
				<%--buttonAuth();--%>
						
			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<input type="hidden" name="gridJSON" id="gridJSON" value="">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" width="7%" align="left" >
				鑑價科
			</td>
			<td class="tbYellow2" width="9%" >
				<select id="APPR_DEPT" name="APPR_DEPT">				
						<option value="">全部</option>
					<c:forEach items="${APPR_DEPT_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>	
			<td class="tbYellow" width="7%" align="left" >
				鑑價組
			</td>
			<td class="tbYellow2" width="9%" >
				<select id="APPR_GROUP" name="APPR_GROUP">				
						<option value="">全部</option>
					<c:forEach items="${APPR_GROUP_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>	
			<td class="tbYellow" width="7%" align="left" >
				受理編號
			</td>
			<td class="tbYellow2" width="9%" >
				<input id="APPLY_ID" name="APPLY_ID" type="text" class="text2" size="12" maxlength="11" />				
			</td>
			<td class="tbYellow2"  align = "center" rowspan = "2" width="20%" >
				<button id = "btn_query" type = "button" class = "button" >查詢</button>
				<button id = "btn_export" type = "button" class = "button">匯出</button>
				<button id = "btn_clear" type = "button" class = "button">清除</button>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="7%" align="left" >
				受理進度
			</td>
			<td class="tbYellow2" width="9%" >
				<select id="APPLY_PROCESS" name="APPLY_PROCESS">				
					<c:forEach items="${APPLY_PROCESS_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>
			<td class="tbYellow" width="7%" align="left" >
				RPA分區更新
			</td>
			<td class="tbYellow2" width="9%" colspan = "3">
				<select id="USE_SECT_UPD_STATUS" name="USE_SECT_UPD_STATUS">
						<option value="">全部</option>
					<c:forEach items="${USE_SECT_UPD_STATUS_Map}" var="row">
						<option value="${row.key}"/>${row.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="8%" align="left" >
				覆核人員
			</td>
			<td class="tbYellow2">
				<select  id="CFM_ID" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<option value="">請選擇</option>
				</select>
			</td>	
			<td class="tbYellow" width="8%" align="left" >
				支援人員
			</td>
			<td class="tbYellow2" colspan = "3">
				<select  id="SUPPORT_ID" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<option value="">請選擇</option>
				</select>
			</td>
			<td class="tbYellow2" colspan = "1" align = "center">
				<button id = "btn_assign" type = "button" class = "button">派件</button>
				<button id = "btn_transfer" type = "button" class = "button">移轉</button>
			</td>
		</tr>
		</table>
	</form>	
	<table id='grid' width="100%"></table>		
		
</body>
</html>