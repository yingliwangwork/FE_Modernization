<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA60200.jsp
功能：覆審派件作業
作者：蔡政均
完成：2020/01/15
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
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSA60200().initApp);

function DSA60200(){
	
	var valid;
	var valid2;
    var grid1,grid2;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA6_0200/');
	//前次查詢條件
	var queryCondition;
	 
	//畫面檢核
	function initValidation(){
		
		Validation.addAllThese([	
			[ 'validateLOAN_ID',  '貸款帳號長度不正確 需為10碼', 
				function(v){				
					return (v!=="" && v.length != 10) ? false : true ;   
				} 
			]
		]);
			
		valid = new Validation('form1');
		valid.define( "validateLOAN_ID" , { id: "LOAN_ID" } );
		valid.define( "required" , { id: "REV_YM", errMsg : "覆審年月不可為空"} );

		valid2 = new Validation('form1');
		valid2.define( "required" , { id: "NEW_REV_ID", errMsg : "請選擇覆審作業指派人員"} );
		valid2.define( "required" , { id: "REV_DEPT_CODE", errMsg : "請選擇覆審科別"} );
	};
	
	var actions = {
		getReqMap : function(){
			var record = {};
			$w('REV_DEPT_CODE REV_TYPE REV_ID').each(function(id){
				record[id] = $F(id);
			});
			record['LOAN_ID'] = $('LOAN_ID').value;
			record['REV_YM'] = $('REV_YM').value; //民國年月
			return record;
		},
		getRevIdList : function(){
		$('REV_ID').length = 1;
		$('NEW_REV_ID').length = 1;
			ajaxRequest.post( 
				'getRevIdList' , 
				{ REV_DEPT_CODE : $F('REV_DEPT_CODE')},
				function(resp){	
					var revIdList = resp.revIdList;
					//新增選項
					revIdList.forEach(function(text){
						$('REV_ID').options.add(new Option(text.NAME,text.ID));
						$('NEW_REV_ID').options.add(new Option(text.NAME,text.ID));
					})
				}
			);			
		},
		getAssignList : function(list){
			var assignList = [];
			list.forEach(function(item){
				var tempMap = {};
				tempMap["LOAN_ID"] = item["LOAN_ID"]; 
				tempMap["APPLY_ID"] = item["APPLY_ID"];
				tempMap["REFER_ID"] = item["REFER_ID"];
				tempMap["REV_YM"] = item["REV_YM"];
				tempMap["REV_DEPT_CODE"] = item["REV_DEPT_CODE"];
				tempMap["REV_KIND"] = item["REV_KIND"];
				tempMap["REV_TYPE"] = item["REV_TYPE"];
				tempMap["NEW_REV_ID"] = $F('NEW_REV_ID'); //畫面上覆審作業指派
				tempMap["NEW_REV_DEPT_CODE"] = $F('REV_DEPT_CODE'); //畫面上覆審科別
				tempMap["CRED_ID"] = item["CRED_ID"];
				tempMap["INPUT_ID"] = item["INPUT_ID"];
				tempMap["LEADER_ID"] = item["LEADER_ID"];
				tempMap["AUDIT_ID"] = item["AUDIT_ID"];
				assignList.push(tempMap);
			})
			return assignList;
		},
		getColumns: function(type){
			<%-- [20240930]  難字調整 --%>
			if('2'==type){
				var cols = [	
					{ header: "貸款帳號", key:'LOAN_ID' },
					{ header: "受理編號", key:'APPLY_ID' },
					{ header: "原貸帳號", key:'REFER_ID' },
					{ header: "鑑價報告編號", key:'APPR_APPLY_ID' },
					{ header: "案件種類", key:'REV_KIND_NM' },
					{ header: "覆審類別", key:'REV_TYPE_NM' },
					{ header: "分級", key:'REV_LEVEL_NM' },
					{ header: "借款人", key:'BORROW_NAME', style:"font-family:'EUDC'" },
					{ header: "統一編號", key:'BORROW_ID' },
					{ header: "原徵信人員", key:'CRED_NM', style:"font-family:'EUDC'" },
					{ header: "覆審科別", key:'REV_DEPT_CODE_NM' },
					{ header: "覆審人員", key:'REV_NM', style:"font-family:'EUDC'" },
					{ header: "派件日期", key:'ASSIGN_DATE', sortRule: 'date' },
					{ header: "覆審進度", key:'REV_PROCESS_NM' },
					{ header: "謄本進度", key:'ELAND_PROCESS_NM' }
				];
				return cols;
			} else {
				var cols = [	
					{ header: "貸款帳號", key:'LOAN_ID' },
					{ header: "受理編號", key:'APPLY_ID' },
					{ header: "原貸帳號", key:'REFER_ID' },
					{ header: "案件種類", key:'REV_KIND_NM' },
					{ header: "覆審類別", key:'REV_TYPE_NM' },
					{ header: "借款人", key:'BORROW_NAME', style:"font-family:'EUDC'" },
					{ header: "統一編號", key:'BORROW_ID' },
					{ header: "原徵信人員", key:'CRED_NM', style:"font-family:'EUDC'" },
					{ header: "覆審科別", key:'REV_DEPT_CODE_NM' },
					{ header: "覆審人員", key:'REV_NM', style:"font-family:'EUDC'" },
					{ header: "派件日期", key:'ASSIGN_DATE', sortRule: 'date' },
					{ header: "覆審進度", key:'REV_PROCESS_NM' }
				];
				return cols;
			}
		},
		gridCtrl: function(resp){
			if(resp && resp.rtnList1){
				grid1.show();
				grid1.load(resp.rtnList1 || []);
			}else{
				grid1.hide();
				grid1.load([]);
			}
			if(resp && resp.rtnList2){
				grid2.show();
				grid2.load(resp.rtnList2 || []);
			}else{
				grid2.hide();
				grid2.load([]);
			}
		}
	};
	
	function buttonAuth(){
		var authButtons = {
			B0067:"btn_assign" <%--派件 --%>
		};
		<dz:grantButtons FUNC_ID="DSA60200" ignored="false"/>	
	};
	
	var buttons = {
		//查詢
		doQuery : function(){
			$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();
			valid.reset();
			valid2.reset();
			if(!valid.validate()){
				return;
			}		
			queryCondition = actions.getReqMap();
			ajaxRequest.post( 
				'query' , 
				{ reqMap : Object.toJSON(queryCondition)},
				function(resp){	
					actions.gridCtrl(resp);
				},
				function(resp){
					actions.gridCtrl();
				}
			);
	    },
		//派件
		doAssign : function(){
			valid.reset();
			valid2.reset();
			if(!valid2.validate()){
				return;
			}
			var checkedRec1 = grid1.getCheckedRecord();
			var checkedRec2 = grid2.getCheckedRecord();
			if(checkedRec1.length==0 && checkedRec2.length==0){
				alert("尚未點選任何案件!!");
				return;
			}			
			ajaxRequest.post( 
				'assign' , 
				{ assignList1 : Object.toJSON(actions.getAssignList(checkedRec1)),
				  assignList2 : Object.toJSON(actions.getAssignList(checkedRec2)),
				  reqMap : Object.toJSON(queryCondition)},
				function(resp){	
					actions.gridCtrl(resp);
				}
			);
	    },
		//清除
		doClear : function(event){
			//將 鑑價人員 支援人員 ,清空
			updateList($("NEW_REV_ID"));
			$('form1').reset();		
		}
    };

	//將收下拉選單清除,加入請選擇,target為要清除的dom物件
	function updateList(target){
		target.update();
		//請選擇
		target.options.add(new Option( "請選擇" , "")); 
	}

	return{
	
		initApp : function(){
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' dateymFields="REV_YM"/>
			PageUI.createPageWithAllBodySubElement(
				'DSA60200',
				'覆審作業',
				'覆審派件作業'
			);
			<%-- [20240930]  難字調整 --%>
			grid1 = new TableUI({
                table: $("grid1"),
				autoCheckBox:{
					text:'選取',
					type:'checkBox',
					isSelectAll:true
				},
                title: "一般覆審",
                pageSize: 8, 
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column: actions.getColumns()
			});
			grid2 = new TableUI({
                table: $("grid2"),
				autoCheckBox:{
					text:'選取',
					type:'checkBox',
					isSelectAll:true
				},
                title: "重要覆審",
                pageSize: 8,
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column:actions.getColumns("2")
			});
			
			actions.gridCtrl();
			
			//按鈕事件監聽
			$('btn_query').observe('click', buttons.doQuery); //查詢
			$('btn_clear').observe('click', buttons.doClear); //清除
			$('btn_assign').observe('click', buttons.doAssign); //派件
			$('REV_DEPT_CODE').observe('change', actions.getRevIdList); //取得覆審人員下拉選單
			
			buttonAuth();
			initValidation();
			displayMessage();			
		}	
		
	};
}
</script>
</head>
<body>
<form name='form1' id='form1'>
<table id="table_A" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">覆審科別</td>
		<td class="tbYellow2" width="15%">
			<select title="覆審科別" id="REV_DEPT_CODE" name="REV_DEPT_CODE" class="textBox2">
				<option value="">全部</option>
				<c:forEach items="${REV_DEPT_CODE_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
		</td>	
		<td class="tbYellow" width="10%">覆審類別</td>
		<td class="tbYellow2" width="15%">
			<select title="覆審類別" id="REV_TYPE" name="REV_TYPE" class="textBox2">
				<option value="">全部</option>
				<c:forEach items="${REV_TYPE_LIST}" var="item">
					<option value="${item.key}" />${item.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width="10%">貸款帳號</td>
		<td class="tbYellow2" width="15%">
			<input id="LOAN_ID" name="LOAN_ID" type='text' class='textBox2' size="12" maxlength="10"/>
		</td>
		<td class="tbYellow2" width="25%" align="center" rowSpan="2">
			<button id="btn_query" type="button" class="button">查詢</button>
			<button id="btn_clear" type="button" class="button">清除</button>
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">覆審人員</td>
		<td class="tbYellow2">
			<%-- [20240930]  難字調整 --%>
			<select title="覆審人員" id="REV_ID" name="REV_ID" class="textBox2" alt="ch">
				<option value="">全部</option>
				<c:forEach items="${REV_ID_LIST}" var="item">
					<option value="${item.ID}" />${item.NAME}</option>
				</c:forEach>				
			</select>
		</td>	
		<td class="tbYellow">覆審年月<font color="red">※例：11010</font></td>
		<td class="tbYellow2" colspan="3">
			<input id="REV_YM" name="REV_YM" type='text' class='textBox2' size="8" maxlength="5"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">覆審作業指派</td>
		<td class="tbYellow2" colSpan="5">
			<%-- [20241001]  難字調整 --%>
			<select title="覆審作業指派" id="NEW_REV_ID" name="NEW_REV_ID" class="textBox2" alt="ch">
				<option value="">請選擇</option>
				<c:forEach items="${NEW_REV_ID_LIST}" var="item">
					<option value="${item.ID}" />${item.NAME}</option>
				</c:forEach>				
			</select>
		</td>
		<td class="tbYellow2" align="center">
			<button id="btn_assign" type="button" class="button">派件</button>
		</td>	
	</tr>
</table>
<table id="grid1" class="grid"></table>
<table id="grid2" class="grid"></table>
</form>
</body>
</html>