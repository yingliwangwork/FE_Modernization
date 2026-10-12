<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<%-- 
程式功能    公寓資料維護作業
程式名稱    DSA3_3700
作業方式    ONLINE
公寓資料維護作業畫面: 
(1)	查詢作業-依指定條件查出所有公寓資料案件。
(2)	修改作業-將畫面勾選的資料進行資料更新。
(3)	呈核作業-將畫面勾選的資料進行呈核。
(4)	覆核作業-將畫面勾選的資料進行覆核。
(5)	退回作業-將畫面勾選的資料進行退回。
(6)	刪除作業-將畫面勾選的資料進行刪除。

@author 何宇倫
@since 2022-07-25
[20240930]難字調整
[20250213]問題單:20250212142432
調整初始可以接受傳值，將縣市、區域、生活圈、年度，帶入初始畫面執行查詢
--%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<!--匯入外部Javascript 與 css-->
<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>

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
<script type="text/JavaScript">
Event.observe(window, 'load', new DSA33700().initApp);

function DSA33700(){

	var valid;
	
    var grid;
    
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3700/');
	
	var queryMap;<%--重查使用的查詢條件--%>
	
	<%--畫面檢核--%>
	function initValidation(){
		valid = new Validation('table_A');
		valid.define( "required" , [ { id: "CITY", errMsg : "請輸入縣市別及行政區"} ] );
		valid.define( "required" , [ { id: "TOWN", errMsg : "請輸入縣市別及行政區"} ] );
	};
	
	var actions = {
		<%-- 取得 A 區資訊 --%>
		getReqMap : function(){
			var reqMap = {};
			$w('CITY TOWN SUBMKT_ID VERSION STATUS PRICE_STATUS').each(function(id){
				reqMap[id] = $F(id);
			});
			return reqMap;
		},
		
		<%-- 取得行政區下拉選單 --%>
		getTownList : function(){
			var TOWN = $('TOWN');
			TOWN.length = 0; //清除行政區下拉選單
			$('SUBMKT_ID').length = 0; //清除次分區下拉選單
			var reqMap = {
				'CITY' : $F('CITY')
			};
			ajaxRequest.post('getTownList', reqMap,
 				function(resp) {
					var rtnList = resp.TOWN_LIST || [];
					rtnList.each(function(obj) {
						TOWN.add(new Option(obj.TOWN_NAME, obj.TOWN_NAME));
					});
					
					actions.getSubmktList();
 				}
 			);
		},
		
		<%-- 取得次分區下拉選單 --%>
		getSubmktList : function(){
			var SUBMKT_ID = $('SUBMKT_ID');
			SUBMKT_ID.length = 0; //清除次分區下拉選單
			var reqMap = {
				'CITY' : $F('CITY'),
				'TOWN' : $F('TOWN')
			};
			ajaxRequest.post('getSubmktList', reqMap,
 				function(resp) {
					var rtnList = resp.SUBMKT_LIST || [];
					SUBMKT_ID.add(new Option('全部', ''));
					rtnList.each(function(obj) {
						SUBMKT_ID.add(new Option(obj.NAME, obj.SUBMKT_ID));
					});
 				}
 			);
		},
		
		<%-- 回復查詢時的 A 區狀態 --%>
		recoverTableA: function(){
			$w('CITY VERSION STATUS PRICE_STATUS').each(function(id){
				$(id).setValue(queryMap[id]);
			});
			ajaxRequest.setSynchronous(true)
			actions.getTownList();
			$('TOWN').setValue(queryMap['TOWN']);
			actions.getSubmktList();
			$('SUBMKT_ID').setValue(queryMap['SUBMKT_ID']);
			ajaxRequest.setSynchronous(false);
		},
		
		<%-- 確認勾選資料是否皆為新資料 --%>
		chkIsAllNewData : function(checkedRec){
			var chk_is_all_new_data = true;
//			checkedRec.each(function(obj,idx) {
//				if("0" == obj.NEW_DATA){
//					chk_is_all_new_data = false;
//				}
//			});
			return chk_is_all_new_data;
		}
	};
	
	function buttonAuth(){
		var authButtons = {
			B0004:"btn_edit", <%-- 修改 --%>
			B0073:"btn_confirm", <%-- 呈核 --%>
			B0070:"btn_captainConfirm", <%-- 覆核 --%>
			B0008:"btn_reject" <%-- 退回 --%>
		};
		<dz:grantButtons FUNC_ID="DSA33700" />	
	};
	
	var buttons = {
		<%--查詢--%>
		doQuery : function(){
			var reqMap = actions.getReqMap();
			queryMap = reqMap;
			ajaxRequest.post( 
				'query' , 
				{ 
					reqMap : Object.toJSON(reqMap)
				},
				function(resp){
					grid.load(resp.rtnList || []);
				},
				function(resp){
					grid.load([]);
				}
			);
	    },
	    
	    <%--修改--%>
	    doEdit : function(){
	    	if(!grid.hasRecords()){
				alert("請先執行查詢");  
				return;
			}
	    	var checkedRec = grid.getCheckedRecord();
			if(checkedRec.length==0){
				alert("請先勾選案件");
				return;
			}
			var chk_is_all_new_data = actions.chkIsAllNewData(checkedRec);
			if(!chk_is_all_new_data){
				alert("勾選資料中，有舊資料，不能進行修改，請檢查後再執行");
				return;
			}
			ajaxRequest.post( 
					'edit' , 
					{ 
						reqMap : Object.toJSON(queryMap),
						chkList : Object.toJSON(checkedRec)
					},
					function(resp){
						grid.load(resp.rtnList || []);
						actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
					},
					function(resp){
						actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
					}
				);
	    },
	    
		<%--呈核--%>
		doConfirm : function(){
			if(!grid.hasRecords()){
				alert("請先執行查詢");  
				return;
			}
			var checkedRec = grid.getCheckedRecord();
			if(checkedRec.length==0){
				alert("請先勾選案件");
				return;
			}		
			var chk_is_all_new_data = actions.chkIsAllNewData(checkedRec);
			if(!chk_is_all_new_data){
				alert("勾選資料中，有舊資料，不能進行呈核，請檢查後再執行");
				return;
			}
			ajaxRequest.post( 
				'confirm' , 
				{ 
					reqMap : Object.toJSON(queryMap),
					chkList : Object.toJSON(checkedRec)
				},
				function(resp){
					grid.load(resp.rtnList || []);
					actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
				},
				function(resp){
					actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
				}
			);
	    },
	    
	    <%--覆核--%>
	    doCaptainConfirm : function(){
			if(!grid.hasRecords()){
				alert("請先執行查詢");  
				return;
			}
			var checkedRec = grid.getCheckedRecord();
			if(checkedRec.length==0){
				alert("請先勾選案件");
				return;
			}
			var chk_is_all_new_data = actions.chkIsAllNewData(checkedRec);
			if(!chk_is_all_new_data){
				alert("勾選資料中，有舊資料，不能進行覆核，請檢查後再執行");
				return;
			}
			ajaxRequest.post( 
				'captainConfirm' , 
				{
				  	reqMap : Object.toJSON(queryMap),
				  	chkList : Object.toJSON(checkedRec)
				},
				function(resp){
					grid.load(resp.rtnList || []);
					actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
				},
				function(resp){
					actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
				}
			);
	    },
	    
		<%--退回--%>
		doReject : function(){
			if(!grid.hasRecords()){
				alert("請先執行查詢");  
				return;
			}
			var checkedRec = grid.getCheckedRecord();
			if(checkedRec.length==0){
				alert("請先勾選案件");
				return;
			}
			ajaxRequest.post( 
				'reject' , 
				{
				  	reqMap : Object.toJSON(queryMap),
				  	chkList : Object.toJSON(checkedRec)
				},
				function(resp){
					grid.load(resp.rtnList || []);
					actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
				},
				function(resp){
					actions.recoverTableA();<%--將A區資料復原為查詢時的狀態--%>
				}
			);
	    }
		
    };

	return{
		initApp : function(){
			
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay'/>
			
			PageUI.createPageWithAllBodySubElement(
				'DSA33700',
				'鑑價作業',
				'公寓資料維護作業'
			);
			
			grid = new TableUI({
                table: $("grid"),
				autoCheckBox:{
					text:'選取', 
					type:'checkBox',
					isSelectAll:true
				},				
				<%-- [20240930] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: [
					{header:'生活圈編號', key:'SUBMKT_ID'},
					{header:'生活圈年份', key:'VERSION'},
					{header:'生活圈名稱', key:'NAME'},
					{header:'生活圈狀態', key:'STATUS_NAME'},
					{header:'異動面積<br>(平方公里)', key:'DIF_AREA'},
					{header:'公寓編號', key:'APART_NO'},
					{header:'公寓價格(萬元/坪)', render : function(rec, val, sn){
						
						if('0' != rec.PRICE_STATUS && '1' != rec.PRICE_STATUS){
							return localeDisplay.formatNumber(rec.PRICE_LOW) + ' ~ ' + localeDisplay.formatNumber(rec.PRICE_HIGH);
						}
						
						var div = new Element('div');
						var input1 = new Element('input', {className : 'textBox2', type : "text"});
						var input2 = new Element('input', {className : 'textBox2', type : "text"});
						
						input1.observe('change', function(){rec.PRICE_LOW = $F(input1)});
						input2.observe('change', function(){rec.PRICE_HIGH = $F(input2)});
						
						localeDisplay.registerToAmount(input1);
						localeDisplay.registerToAmount(input2);
						
						input1.setValue(rec.PRICE_LOW);
						input2.setValue(rec.PRICE_HIGH);
						
						div.insert(input1).insert(' ~ ').insert(input2);
						
						return div;
					}},
					{header:'價格狀態', key:'PRICE_STATUS_NAME'},
					{header:'編輯日期', key:'EDIT_DATE', sortRule : 'date'},
					{header:'輸入人員', key:'INPUT_NAME', attrs:{style:"font-family:'EUDC'"}},<%--[20240930]難字調整 --%>
					{header:'覆核人員', key:'CONFIRM_NAME', attrs:{style:"font-family:'EUDC'"}},<%--[20240930]難字調整 --%>
					<%-- [20220812] 問題單號 20220809160446 新增欄位”區域特性”、”公寓價格說明”--%>
					{header:'區域特性', key:'FEATURE',
						input: { 
							type: "textArea", 
							rows:3, 
							cols:50, 
							shortTextLength:8, 
							easyEdit: function(rec, val){
								return !('0' != rec.PRICE_STATUS && '1' != rec.PRICE_STATUS && val == '');
							},
							clickText: true,
							disableRule : function(rec, val){
								return '0' != rec.PRICE_STATUS && '1' != rec.PRICE_STATUS;
							}
						}
					},
					{header:'公寓價格說明', key:'MEMO',
						input: { 
							type: "textArea", 
							rows:3, 
							cols:50, 
							shortTextLength:8, 
							easyEdit: function(rec, val){
								return !('0' != rec.PRICE_STATUS && '1' != rec.PRICE_STATUS && val == '');
							},
							clickText: true,
							disableRule : function(rec, val){
								return '0' != rec.PRICE_STATUS && '1' != rec.PRICE_STATUS;
							}
						}
					}
				]
			});
			
			<%--按鈕事件監聽--%>
			$('btn_edit').observe('click', buttons.doEdit);
			$('btn_confirm').observe('click', buttons.doConfirm);
			$('btn_captainConfirm').observe('click', buttons.doCaptainConfirm);
			$('btn_reject').observe('click', buttons.doReject);
			$('btn_query').observe('click', buttons.doQuery);
			
			<%--下拉選單連動--%>
			$('CITY').observe('change', actions.getTownList);
			$('TOWN').observe('change', actions.getSubmktList);
			
			
			buttonAuth();
			
			initValidation();
			
			displayMessage();
			<%--[20250213]若有傳入 SUBMKT_ID SUBMKT_NAME VERSION CITY  TOWN參數，畫面帶入預設值，執行查詢--%>
			<c:if test="${not empty SUBMKT_ID}">
			buttons.doQuery();
			</c:if>
		}
	};
}
</script>
</head>
<body>
	<form name='form1' id='form1' method="post">
		<table id="table_A" width="100%" class="tbBox2">
			<tr>
				<td class="tbYellow" width="10%">縣市別</td>
				<td class="tbYellow2" width="16%"><select title="縣市別" id="CITY"
					name="CITY" class="textBox2">
						<c:forEach items="${CITY_LIST}" var="item">
							<option value="${item.CITY_NAME}" <c:if test='${CITY eq item.CITY_NAME}'>selected</c:if>>${item.CITY_NAME}</option>
						</c:forEach>
				</select> <select title="行政區" id="TOWN" name="TOWN" class="textBox2">
						<c:forEach items="${TOWN_LIST}" var="item">
							<option value="${item.TOWN_NAME}" <c:if test='${TOWN eq item.TOWN_NAME}'>selected</c:if>>${item.TOWN_NAME}</option>
						</c:forEach>
				</select>
				<td class="tbYellow" width="10%">生活圈</td>
				<td class="tbYellow2" width="8%"><select title="生活圈"
					id="SUBMKT_ID" name="SUBMKT_ID" class="textBox2">
						<option value="">全部</option>
						<c:forEach items="${SUBMKT_LIST}" var="item">
							<option value="${item.SUBMKT_ID}" <c:if test='${SUBMKT_ID eq item.SUBMKT_ID}'>selected</c:if>>${item.NAME}</option>
						</c:forEach>
				</select></td>
				<td class="tbYellow" width="10%">生活圈年度</td>
				<td class="tbYellow2" width="8%"><select title="生活圈年度"
					id="VERSION" name="VERSION" class="textBox2">
						<option value="">全部</option>
						<c:forEach items="${yearList}" var="item">
							<option value="${item.key}" <c:if test='${VERSION eq item.key}'>selected</c:if>>${item.value}</option>
						</c:forEach>
				</select></td>
				<td class="tbYellow" width="10%">生活圈狀態</td>
				<td class="tbYellow2" width="8%"><select title="生活圈狀態"
					id="STATUS" name="STATUS" class="textBox2">
						<option value="">全部</option>
						<c:forEach items="${STATUS_LIST}" var="item">
							<option value="${item.key}">${item.value}</option>
						</c:forEach>
				</select></td>
				<td class="tbYellow" width="10%">價格狀態</td>
				<td class="tbYellow2" width="10%"><select title="價格狀態"
					id="PRICE_STATUS" name="PRICE_STATUS" class="textBox2">
						<option value="">全部</option>
						<c:forEach items="${PRICE_STATUS_LIST}" var="item">
							<option value="${item.key}">${item.value}</option>
						</c:forEach>
				</select></td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan='10' width="100%"
					style="text-align: center;">
					<button id="btn_query" type="button" class="button">查詢</button>
				</td>
			</tr>
		</table>
		<table id="grid" class="grid"></table>
		<div width="100%" style="text-align: center;">
			<button type='button' class='button' id='btn_edit'>修改</button>
			<button type='button' class='button' id='btn_confirm'>呈核</button>
			<button type='button' class='button' id='btn_captainConfirm'>覆核</button>
			<button type='button' class='button' id='btn_reject'>退回</button>
		</div>

	</form>
</body>
</html>