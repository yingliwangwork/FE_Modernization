<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA33600.jsp
功能：覆審件覆核作業
作者：陳彥勳
完成：2020/2/6
[20240930] 修改件 CHROME瀏覽器難字調整
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" />
<!--匯入外部Javascript 與 css-->
<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
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
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSA33600().initApp);

function DSA33600(){

	var valid;
    var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3600/');
	var isQuerySucess;<%--是否執行過查詢並有資料--%>
	var queryMap;<%--重查使用的查詢條件--%>
	var enterLock;
	 
	<%--畫面檢核--%>
	function initValidation(){
		Validation.addAllThese([		
			[ 'validateChooseAPPR_DeptGroup',  '鑑價科與鑑價組請擇一輸入', 
			//鑑價科與鑑價組其中兩個只能擇一輸入
			function(){				
				var APPR_DEPT = $("APPR_DEPT").value;
				var APPR_GROUP = $("APPR_GROUP").value;		
				if( (APPR_DEPT !=="" && APPR_GROUP !=="") || (APPR_DEPT ==="" && APPR_GROUP ==="")){					
					return false;
				}else{
					return true;
				}
			}]
		]);	
		valid = new Validation('form1');
		valid.define( "validateChooseAPPR_DeptGroup" , { id: "APPR_DEPT" } );
		valid.define( "required" , [ { id: "REV_YM", errMsg : "請輸入覆審年月"} ] );
	};
	
	var actions = {
		getReqMap : function(){
			var record = {};
			$w('APPR_DEPT APPR_GROUP APPR_PROCESS REV_YM').each(function(id){
				if(id == 'REV_YM'){ //民國年月用$F(ID)取值會變西元年月
					record[id] = $(id).value;
				}else{
					record[id] = $F(id);
				}
			});
			queryMap = record;
			return record;
		},
		recoverTableA: function(){
			$w('APPR_DEPT APPR_GROUP APPR_PROCESS REV_YM').each(function(id){
				if(id == 'REV_YM'){
					$(id).value = queryMap.REV_YM;
				}else{
					$(id).setValue(queryMap[id]);
				}
			});
		},
		<%-- 建立超連結 --%>
		doBuildLink : function(linkTo, value, tempOP, inputName, i){
			var link = new Element('a',{'href':'javascript:void(0);',inputName:value, 'linkTo':linkTo, 'tempOP':tempOP, 'id':inputName+i}).update(value);
			link.observe('click', function(){
				popupWin.windowOpen( '${dispatcher}/'+this.getAttribute('linkTo')+'/prompt' ,
				{
					'parameters': {'APPLY_ID': value, 'OP': tempOP},
					'fullScreen': false,
					'attributes': {'resizable': 'yes'}
				});
			});
			return link;
		},
	};
	
	function buttonAuth(){
		var authButtons = {
			B0118:"btn_confirm", <%--科主管覆核 --%>
			B0071:"btn_cancelConfirm", <%--取消結案 --%>
			B0119:"btn_reject" <%--主管退回 --%>
		};
		<dz:grantButtons FUNC_ID="DSA33600" />	
	};
	
	var buttons = {
		<%--查詢--%>
		doQuery : function(){
			valid.reset();
			if(!valid.validate()){
				return;
			}		
			ajaxRequest.post( 
				'query' , 
				{ 
					reqMap : Object.toJSON(actions.getReqMap())
				},
				function(resp){
					isQuerySucess = true;
					grid.load(resp.rtnList || []);
					enterLock = false;
				},
				function(resp){
					isQuerySucess = false;
					grid.load([]);
					enterLock = false;
				}
			);
	    },
		<%--科主管覆核--%>
		doConfirm : function(){
			if(grid.getAllRecords().length == 0){
				alert("請先執行查詢");  
				return;
			}
			var checkedRec = grid.getCheckedRecord();
			if(checkedRec.length==0){
				alert("請先選取要科主管覆核的資料");
				return;
			}			
			ajaxRequest.post( 
				'confirm' , 
				{ 
					reqMap : Object.toJSON(queryMap),
					chkList : Object.toJSON(checkedRec)
				},
				function(resp){
					var rtnList = resp.rtnList || [];
					grid.load(rtnList);
					isQuerySucess = rtnList.length > 0;
					actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
					enterLock = false;
				},
				function(resp){
					enterLock = false;
				}
			);
	    },
		<%--主管退回--%>
		doReject : function(){
			if(grid.getAllRecords().length == 0){
				alert("請先執行查詢");  
				return;
			}
			var checkedRec = grid.getCheckedRecord();
			if(checkedRec.length==0){
				alert("請先選取要主管退回的資料");
				return;
			}
			ajaxRequest.post( 
				'reject' , 
				{
				  	reqMap : Object.toJSON(queryMap),
				  	chkList : Object.toJSON(checkedRec)
				},
				function(resp){
					var rtnList = resp.rtnList || [];
					grid.load(rtnList);
					isQuerySucess = rtnList.length > 0;
					actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
					enterLock = false;
				},
				function(resp){
					enterLock = false;
				}
			);
	    },
		<%--取消結案--%>
		doCancelConfirm : function(){
			if(grid.getAllRecords().length == 0){
				alert("請先執行查詢");  
				return;
			}
			var checkedRec = grid.getCheckedRecord();
			if(checkedRec.length==0){
				alert("請先選取要取消結案的資料");
				return;
			}
			if (checkedRec.length > 1) {
				alert('請選取單筆資料作取消結案');
				return;
			}
			ajaxRequest.post( 
				'cancelConfirm' , 
				{ 
				  	reqMap : Object.toJSON(queryMap),
				  	chkMap : Object.toJSON(checkedRec[0])
				},
				function(resp){	
					var rtnList = resp.rtnList || [];
					grid.load(rtnList);
					isQuerySucess = rtnList.length > 0;
					actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
					enterLock = false;
				},
				function(resp){
					enterLock = false;
				}
			);
	    },
		<%--匯出Excel--%>
		doExport : function(){
			if (!isQuerySucess) {
				alert('請先執行查詢');
				return;
			}		
			RPTUtil.executeCreateXlsFile('${dispatcher}/DSA3_3600/export',
				{
					allRecords: Object.toJSON(grid.getAllRecords()),
					gridJSON: grid.getXlsSettingJSON('覆審案件覆核作業')
				}
			);
			enterLock = false;
		},		
		doClear : function(){
			valid.reset();
			$('form1').reset();
			grid.load([]);
			isQuerySucess = false;
			enterLock = false;
		}
		
    };

	return{
		initApp : function(){
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' dateymFields='REV_YM'/>
			PageUI.createPageWithAllBodySubElement(
				'DSA33600',
				'鑑價作業',
				'覆審案件覆核'
			);
			<%-- [20240930]  難字調整 --%>
			grid = new TableUI({
                table: $("grid"),
                split: ['APPR_APPLY_ID'],
				autoCheckBox:{
					text:'選取', 
					type:'checkBox',
					isSelectAll:true
				},
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},					
				column: [
					{header:'受理編號', key:'APPLY_ID'},
					{header:'擔保品地址', key:'ADDR_NO', style:"font-family:'EUDC'", attrs:{rowSpan:2}},
					{header:'原鑑估日期', key:'ORI_APPR_DATE'},
					{header:'前次覆審年月', key:'PRE_REV_YM'},
					{header:'覆審年月', key:'REV_YM'},
					{header:'覆審鑑價員', key:'APPR_NM', style:"font-family:'EUDC'"},
					{header:'是否減損', key:'IS_LOSS_NM'},
					{header:'分級', key:'REV_LEVEL_NM'},
					{header:'鑑價報告編號', key:'APPR_APPLY_ID'
						,render:function(record, value, i){
							if(!value && value!='0'){
								return '';
							}
							var link;
							if (value.substring(3,5)=='@A' || value.substring(3,5)=='@I' || value.substring(3,5)=='@J') {
								link = actions.doBuildLink('DSA3_0600', value, '', 'APPLY_ID', i); <%-- 連結'土建融鑑價報告' --%>
			 				} else if (value.substring(3,5)=='@B' || value.substring(3,5)=='@U' || value.substring(3,5)=='@V') {
			 					link = actions.doBuildLink('DSA3_0700', value, '', 'APPLY_ID', i); <%-- 連結'整批件鑑價報告' --%>
			 				} else {
			 					link = actions.doBuildLink('DSA3_0500', value, '', 'APPLY_ID', i); <%-- 連結'一般件鑑價報告' --%>
			 				}
							return link;
						}
					},
					{header:'原鑑估總值', key:'ORI_TOTAL_PRICE', sortRule: 'number'},
					{header:'前次覆審總值', key:'PRE_TOTAL_PRICE', sortRule: 'number'},
					{header:'覆審總值', key:'TOTAL_PRICE', sortRule: 'number'},
					{header:'覆核組長', key:'APPR_CAPT_NM', style:"font-family:'EUDC'"},
					{header:'減損報告編號', key:'LOSS_RPT_NO'
						,render:function(record, value, i){
							var link = !value ? '' : actions.doBuildLink('DSA3_0500', value, '', 'LOSS_RPT_NO', i); <%-- 連結'一般件鑑價報告' --%>;
							return link;
						}
					},
					{header:"覆審鑑價進度", key:'APPR_PROCESS_NM'}
				]
			});
			
			<%--按鈕事件監聽--%>
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_confirm').observe('click', buttons.doConfirm);
			$('btn_cancelConfirm').observe('click', buttons.doCancelConfirm);
			$('btn_reject').observe('click', buttons.doReject);
			$('btn_clear').observe('click', buttons.doClear);
			$('btn_export').observe('click', buttons.doExport);
			$('REV_YM').observe('keydown', function(event) {
				enterLock = true;
				if (event.keyCode == 13) {
					buttons.doQuery();
				}
			});
			<%--防止form中只有一個input時，在input物件中按下enter會自動form submit情況--%>
			document.onkeydown = function(event) {
				if (enterLock) {
					if (!event) {
						<%--針對ie瀏覽器--%>
						if (window.event.keyCode == 13) {
							return false; 
						}
					} else {
						<%--針對遵循w3c標準的瀏覽器，如Firefox--%>
						if (event.keyCode == 13) {
							return false;
						}
					}
				}
			};
			buttonAuth();
			initValidation();
			displayMessage();
		}
	};
}
</script>
</head>
<body>
<form name='form1' id='form1' method="post">
	<table id="table_A" width="100%" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">鑑價科</td>
			<td class="tbYellow2" width="15%">
				<select title="鑑價科" id="APPR_DEPT" name="APPR_DEPT" class="textBox2">
					<option value="">全部</option>
					<c:forEach items="${APPR_DEPT_LIST}" var="item">
					<option value="${item.key}" <c:if test="${item.key eq APPR_DEPT}">selected</c:if>>${item.value}</option>
					</c:forEach>
				</select>
			<td class="tbYellow" width="10%">鑑價組</td>
			<td class="tbYellow2" width="40%">
				<select title="鑑價組" id="APPR_GROUP" name="APPR_GROUP" class="textBox2">
					<option value="">全部</option>
					<c:forEach items="${APPR_GROUP_LIST}" var="item">
					<option value="${item.key}">${item.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow2" width="25%" rowspan="2" align="center">
				<button id="btn_query" type="button" class="button">查詢</button>
				<button id="btn_export" type="button" class="button">匯出</button>
				<button id="btn_clear" type="button" class="button">清除</button>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">覆審鑑價進度</td>
			<td class="tbYellow2">
				<select title="覆審鑑價進度" id="APPR_PROCESS" name="APPR_PROCESS" class="textBox2">
					<option value="">全部</option>
					<c:forEach items="${APPR_PROCESS_LIST}" var="item">
					<option value="${item.key}">${item.value}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow">覆審年月<font color="red">※例：11010</font></td>
			<td class="tbYellow2">
				<input type='text' title="覆審年月" id="REV_YM" name="REV_YM" class="textBox2"/>
				<input type='hidden'/>
			</td>
		</tr>
		<tr>
			<td colspan='5' align='center'>
				<button type='button' class='button' id='btn_confirm' name='btn_confirm'>科主管覆核</button>
				<button type='button' class='button' id='btn_reject' name='btn_reject'>主管退回</button>
				<button type='button' class='button' id='btn_cancelConfirm' name='btn_cancelConfirm'>取消結案</button>
			</td>
		</tr>
	</table>
	<table id="grid" class="grid"></table>
</form>
</body>
</html>