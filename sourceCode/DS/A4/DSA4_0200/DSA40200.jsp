<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA40200.jsp
作者：李佳興
功能：名單對照維護作業
完成：
-->
<!--
[20200709] 房貸應收帳款委外 
1. 新增 "房貸應收債權催收委外" 上傳類別

[20230222]修改件
增加選項【總經變數表】、【村里人口收入變數表】、【建照變數表】，調整【查詢】與【檔案產製】處理
郭曉慧

[20230615] 修改件
1.增加選項【AVM變數門檻】，調整【查詢】與【檔案產製】處理

[20240927] 修改件 CHROME瀏覽器難字調整
 -->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<%--[20240927]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>


<script type="text/JavaScript">
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSA40200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);



<%--以下為DSB20100() public method,放在 return 中--%>
function DSA40200(){
	
	var colMaps={
		colA:[
			{ header: "資料種類", key: "TYPE_NM" },
			{ header: "ID", key: "ID" , sortable: true},
			{ header: "序號", key: "SEQ_NO", sortable: true},
			{ header: "資料基準日", key: "BASE_DATE", sortRule:'date'},
			{ header: "備註", key: "C007_MEMO" , sortable: true},
			{ header: "有效/無效件", key: "VALID_NM", sortable: true},
			{ header: "上傳說明", key: "MEMO" , sortable: true},
			{ header: "上傳人員", key: "INPUT_NM", style:"font-family:'EUDC'"},
			{ header: "上傳日期", key: "INPUT_DATE1", sortRule:'datetime'}
		],
		colB:[
			{ header: "資料種類", key: "TYPE_NM" },
			{ header: "序號", key: "SEQ_NO", sortable: true},
			{ header: "有效/無效件", key: "VALID_NM", sortable: true},
			{ header: "上傳件數", key: "INPUT_CNT", sortable: true},
			{ header: "上傳人員", key: "INPUT_NM", style:"font-family:'EUDC'"},
			{ header: "上傳日期", key: "INPUT_DATE1", sortRule:'datetime'},
			{ header: "上傳說明", key: "MEMO" , sortable: true}
		],
		colC:[
			{ header: "資料種類", key: "TYPE_NM", sortable: true },
			{ header: "區部", key: "DIV_CODE", sortable: true },
			{ header: "單位代號", key: "AREA_CODE", sortable: true},
			{ header: "平均萬數", key: "LOAN_AMT"},
			{ header: "核貸率", key: "APPROVAL_RATE"}
		]
	}
	
	var grid;
	var valid;
	
	<%--按鈕權限--%>
	function buttonAuth(){
		var authButtons = {
			 B0066:"btn_import"<%--匯入--%>
			,B0233:"btn_produce"<%--檔案產製--%>
		};
		
		<dz:grantButtons FUNC_ID="DSA40200"/>
	}
	
	
	<%--共用Ajax--%>
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA4_0200/');
	
	<%--畫面檢核--%>
	function initValidation(){
		valid = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validate'});		
		valid.define( 'validate-selection', [ { id: 'TYPE', errMsg: '請選擇資料種類' } ] );
	}
	
	function setGridColumn(type){
		<%-- [20200709]  新增 "房貸應收債權催收委外" 上傳類別  --%>
		<%-- [20210810]  申請書-備呆明細上載-配合監理報表調整為部份自動化：新增 "備呆明細提列方法三清單" 上傳類別   BY余凱鈞--%>
		<%-- [20220608]  新增社區清單樂居維護表--%>
		<%-- [20230222]  增-總經變數表、村里人口收入變數表、建照變數表--%>
		<%-- [20230615]  增-AVM變數門檻 RPA_AVMFLD--%>
		<%-- [20240927]  難字調整 --%>
		if(type =="EVAL_PRICE_LIST" || type=="EVAL_PRICE_LIST2" || type=="MORTGAGE_RECEIVE" || type=="BAD_DEBTS3" || type=="COMM_PREDATA" 
				|| type=="LEJU_COMMUNITY" || type == 'AVMPRAM_MCE' || type == 'AVMPRAM_VLG' || type == 'AVMPRAM_BLD' || type == 'RPA_AVMFLD'){
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 20, allSortable: false, overDiv:false,
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:colMaps.colB
				}
			);
		}else if(type =="AVERAGE_SETTING"){
			grid = new TableUI(
					{	
						table:$('grid'), pageSize: 20, allSortable: false, overDiv:false,
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:colMaps.colC
					}
				);
		}else{
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 20, allSortable: false, overDiv:false,
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:colMaps.colA
				}
			);
		}
	}
	
	<%--功能按鈕--%>	
	var buttons = {		
		doQuery:function(){
			if(!valid.validate()){
				return;
			}
			var reqMap = {};			
			$('form1').select('input[type!=button]', 'select').each(function(ele){
				reqMap[ele.id] = ele.getValue();
			});
			var params = {reqMap: reqMap};
			var successAction = function(resp){
				grid.load(resp.DSC007_List);
			};
			var errorAction = function(resp){
				grid.load([]);
			};
			
			ajaxRequest.post( 'query' , {reqMap : Object.toJSON(reqMap)},successAction,errorAction);
		},

		<%--匯入--%>
		doImport:function() {
			if(!valid.validate()){
				return;
			}
			var LP_JSON = {
				action : "${dispatcher}/DSA4_0201/prompt",
				TYPE : $F('TYPE'),
				TYPE_NM : $('TYPE').options[$('TYPE').selectedIndex].getAttribute('TYPE_NM') || ''
			};
			
			<%--超連結至DSA4_0201(名單匯入畫面)--%>
			CSRUtil.linkTo(LP_JSON, 'form1');
		},
		<%--檔案產製--%>
		doProduce: function(){
			if(!valid.validate()){
				return;
			}
			var LP_JSON = {
					action : "${dispatcher}/DSA4_0202/prompt",
					TYPE : $F('TYPE'),
					TYPE_NM : $('TYPE').options[$('TYPE').selectedIndex].getAttribute('TYPE_NM') || ''
				};
			<%--[20230222]總經變數表、村里人口收入變數表、 建照變數表--%>
			<%--[20230615]AVM變數門檻 RPA_AVMFLD--%>
			if(['AVMPRAM_MCE', 'AVMPRAM_VLG', 'AVMPRAM_BLD', 'RPA_AVMFLD'].include(LP_JSON.TYPE)){
				alert(LP_JSON.TYPE_NM + '，不支援檔案產製功能');
				return;
			}
			<%--超連結至DSA4_0202--%>
			CSRUtil.linkTo(LP_JSON, 'form1');
		}
		
	};
	
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSA40200", "經手人專區", "名單對照維護作業" );
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>
			<%--產生 Grid 物件--%>
			<%--[20240927] 難字調整 --%>
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 20, allSortable: false, overDiv:false,
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "資料種類", key: "TYPE_NM" },
						{ header: "ID", key: "ID" , sortable: true},
						{ header: "序號", key: "SEQ_NO", sortable: true},
						{ header: "資料基準日", key: "BASE_DATE", sortRule:'date'},
						{ header: "備註", key: "C007_MEMO" , sortable: true},
						{ header: "有效/無效件", key: "VALID_NM", sortable: true},
						{ header: "上傳說明", key: "MEMO" , sortable: true},
						{ header: "上傳人員", key: "INPUT_NM", style:"font-family:'EUDC'"},
						{ header: "上傳日期", key: "INPUT_DATE1", sortRule:'datetime'}<%--調整時間顯示格式--%>
					]
				}
			);
			<%--按鈕權限--%>
			buttonAuth();
			<%--畫面檢核--%>
			initValidation();
			
			<%--查詢按鈕--%>
			$("btn_query").observe('click',function(event){
				buttons.doQuery();
			});
			
			<%--匯入按鈕--%>
			$("btn_import").observe('click',function(event){
				buttons.doImport();
			});
			<%--檔案產製按鈕--%>
			$('btn_produce').observe('click', buttons.doProduce);
			
			<%--若是回上頁所發送回來的，還原 form1 的輸入欄值後，執行重新查詢--%>
			if(CSRUtil.isBackLink('form1')){
				var type=$('TYPE').getValue();
				setGridColumn(type);
				buttons.doQuery();
			}
			
			<%--依據資料種類，切換不同grid columns--%>
			$('TYPE').observe('change', function(event){
				var type=event.element().getValue();
				setGridColumn(type);
				/*
				if(type =="EVAL_PRICE_LIST" || type=="EVAL_PRICE_LIST2"){
					grid = new TableUI(
						{	
							table:$('grid'), pageSize: 20, allSortable: false, overDiv:false,
							column:colMaps.colB
						}
					);
				}else{
					grid = new TableUI(
						{	
							table:$('grid'), pageSize: 20, allSortable: false, overDiv:false,
							column:colMaps.colA
						}
					);
				}
				*/
			});
			
		}<%--end initApp()--%>
	}<%--end return--%>
}<%--end DSA40200--%>


</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
	<form name="form1" id="form1" method="post" action="">
	<table id="table_A" name="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="5%">資料種類</td>
				<td class="tbYellow2" width="15%">
					<select name="TYPE" id="TYPE" class="textBox2 ">
						<option value="" TYPE_NM = "">請選擇</option>
						<c:forEach var="map" items="${TYPE_LIST}">
							<option value="${map.KEY}" TYPE_NM = "${map.VALUE}">${map.VALUE}</option>
						</c:forEach>
					</select><br><font color =red>匯入、檔案產製前請先選取</font>
				</td>
				<td class="tbYellow" width="5%">ID</td>
				<td class="tbYellow2" width="10%">
					<input type="text" class="textBox2 checkInputLength" size="12" maxlength="10" name="ID" id="ID" onblur="this.value = this.value.toUpperCase()">
				</td>
				<td class="tbYellow" width="8%">上傳說明/備註</td>
				<td class="tbYellow2" width="15%">
					<input type="text" class="textBox2 " size="20" maxlength="50" name="MEMO" id="MEMO">
				</td>
				<td class="tbYellow" width="5%">狀態</td>
				<td class="tbYellow2" width="12%">
					<select name="VALID" id="VALID" class="textBox2">
						<option value="">全部</option>
						<c:forEach var="map" items="${VALID_LIST}">
							<option value="${map.key}" <c:if test="${'1' eq map.key}">selected</c:if>>${map.value}</option>
						</c:forEach>
					</select><br><font color =red>有效:最新上傳</font>
				</td>
				
				<td class="tbYellow2" width="15%" align="center">
					<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">						
					<input id="btn_import" name="btn_import" type="button" class="button" value="匯入">					
					<input id="btn_produce" name="btn_produce" type="button" class="button" value="檔案產製">
				</td>
			</tr>
	</table>
	</form>
	<table id="grid" class="grid"></table>
</body>
</html>
