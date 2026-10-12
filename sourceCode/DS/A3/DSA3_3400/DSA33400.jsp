<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA33400.jsp
功能：覆審分派移轉
作者：蔡政均
完成：2019/12/24
[20240927] 修改件 CHROME瀏覽器難字調整
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
Event.observe(window, 'load', new DSA33400().initApp);

function DSA33400(){
	
	var valid;
    var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3400/');
	//前次查詢條件
	var queryCondition;
	 
	//畫面檢核
	function initValidation(){
		
		Validation.addAllThese([
			[ 'validateAPPLY_ID',  '受理編號長度不正確 需為11碼', 
				function(v){				
					return (v!=="" && v.length != 11) ? false : true ;   
			}],
			[ 'notEmptyThree',  '請至少輸入任一查詢條件再執行查詢', 
				function(v){
					if( Validation.get('IsEmpty').test(v) ){
						if( $('APPLY_ID').value === '' ){
							return $('APPR_DEPT').value === '' && $('APPR_GROUP').value === '' && $('APPR_PROCESS').value === '' ? false : true;
						}
					}	
				return true;
			}]
		]);		
		valid = new Validation('form1');
		valid.define( "validateAPPLY_ID" , { id: "APPLY_ID" } );
		valid.define( "notEmptyThree" , { id: 'APPR_DEPT' } );	
	};
	
	var actions = {
		getReqMap : function(){
			var record = {};
			$w('APPR_DEPT APPR_GROUP APPR_PROCESS APPLY_ID').each(function(id){
				record[id] = $F(id);
			});
			return record;
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
				tempMap["APPR_ID"] = $F('APPR_ID'); //畫面上鑑價人員
				tempMap["SUPPORT_ID"] = $F('SUPPORT_ID'); //畫面上支援人員
				tempMap["ORI_APPR_ID"] = item["ORI_APPR_ID"];
				tempMap["ORI_AGENT_ID"] = item["ORI_AGENT_ID"];
				tempMap["ORI_CAPT_ID"] = item["ORI_CAPT_ID"];
				assignList.push(tempMap);
			})
			return assignList;
		},
		getTransferList : function(list){
			var transferList = [];
			list.forEach(function(item){
				var tempMap = {};
				tempMap["LOAN_ID"] = item["LOAN_ID"]; 
				tempMap["APPLY_ID"] = item["APPLY_ID"];
				tempMap["REFER_ID"] = item["REFER_ID"];
				tempMap["REV_YM"] = item["REV_YM"];
				tempMap["REV_DEPT_CODE"] = item["REV_DEPT_CODE"];
				tempMap["REV_KIND"] = item["REV_KIND"];
				tempMap["REV_TYPE"] = item["REV_TYPE"];
				tempMap["APPR_GROUP"] = item["APPR_GROUP"];
				tempMap["APPR_ID"] = $F('APPR_ID'); //畫面上鑑價人員
				tempMap["SUPPORT_ID"] = $F('SUPPORT_ID'); //畫面上支援人員
				tempMap["ORI_APPR_ID"] = item["ORI_APPR_ID"];
				tempMap["ORI_AGENT_ID"] = item["ORI_AGENT_ID"];
				tempMap["ORI_CAPT_ID"] = item["ORI_CAPT_ID"];
				transferList.push(tempMap);
			})
			return transferList;
		}
	};
	
	function buttonAuth(){
		var authButtons = {
			B0067:"btn_assign", <%--派件 --%>
			B0097:"btn_transfer", <%--移轉 --%>
			B0021:"btn_export" <%--匯出 --%>
		};
		
		<dz:grantButtons FUNC_ID="DSA33400" ignored="false"/>	
	};
	
	var buttons = {
		//查詢
		doQuery : function(){
			valid.reset();
			if(!valid.validate()){
				return;
			}		
			queryCondition = actions.getReqMap();
			ajaxRequest.post( 
				'query' , 
				{ reqMap : Object.toJSON(queryCondition)
				},
				function(resp){	
					grid.load(resp.rtnList || []);
					appendList(resp.APPR_ID_LIST , $("APPR_ID"));
					appendList(resp.SUPPORT_ID_LIST ,$("SUPPORT_ID"));	
				}
				, function(resp){
					//失敗把前次內容清掉 並把鑑價,支援人員list清掉
					grid.load([]);
					updateList($("APPR_ID"));
					updateList($("SUPPORT_ID"));
				}
			);
	    },
		//分派
		doAssign : function(){
			if($F('APPR_ID') == ''){
				alert("請選擇鑑價人員");
				return;
			}
			var checkedRec = grid.getCheckedRecord();
			if(checkedRec.length==0){
				alert("尚未點選任何案件!!");
				return;
			}			
			ajaxRequest.post( 
				'assign' , 
				{ assignList : Object.toJSON(actions.getAssignList(checkedRec)),
				  reqMap : Object.toJSON(queryCondition)
				},
				function(resp){	
					grid.load(resp.rtnList || []);
				}
			);
	    },
		//移轉
		doTransfer : function(){
			var APPR_ID = $("APPR_ID").value;
			var SUPPORT_ID = $("SUPPORT_ID").value;	
			if((APPR_ID !=="" && SUPPORT_ID !=="") || (APPR_ID ==="" && SUPPORT_ID ==="")){
				alert("鑑價人員與支援人員請擇一輸入");
				return;
			}
			var checkedRec = grid.getCheckedRecord();
			if(checkedRec.length==0){
				alert("尚未點選任何案件!!");
				return;
			}			
			ajaxRequest.post( 
				'transfer' , 
				{ transferList : Object.toJSON(actions.getTransferList(checkedRec)),
				  reqMap : Object.toJSON(queryCondition)
				},
				function(resp){	
					grid.load(resp.rtnList || []);
				}
			);
	    },
		//匯出Excel
		doExport : function(event){
			valid.reset();
			if(!valid.validate()){
				return;
			}			
			RPTUtil.executeCreateXlsFile('${dispatcher}/DSA3_3400/export',
				{
					reqMap: Object.toJSON(actions.getReqMap()),
					gridJSON: grid.getXlsSettingJSON('覆審分派移轉作業')
				}
			);
		},	
		
		doClear : function(){
			valid.reset();
			$('form1').reset();
			grid.load([]);
		}
		
    };
	
	//將List增加到下拉選單中
	function appendList(list , target){
		//先清除
		updateList(target);	
		//加入List	
		if(list){
			for(var i = 0; i < list.length; i++){ 
				target.options.add(new Option(list[i]['NAME'], list[i]['ID'])); 
			}
		}
	}

	//將收下拉選單清除,加入請選擇 , target為要清除的dom物件
	function updateList(target){
		target.update();
		//請選擇
		target.options.add(new Option( "請選擇" , "")); 
	}

	return{
	
		initApp : function(){
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay'/>
			PageUI.createPageWithAllBodySubElement(
				'DSA33400',
				'鑑價作業',
				'覆審分派移轉'
			);
			<%-- [20240927]  難字調整 --%>
			grid = new TableUI({
                table: $("grid"),
				autoCheckBox:{
							text:'選取', 
							type:'checkBox',
							isSelectAll:true,		
					},
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},	
				column:[	
					{header:"受理編號", key:'APPLY_ID'},
					{header:"鑑價報告編號", key:'APPR_APPLY_ID'},
					{header:"分級", key:'REV_LEVEL_NM'},
					//{header:"本金餘額", key:'TOTAL_REMAIN_AMT', sortRule: 'number'},
					{header:"擔保品地址", key:'ADDR_NO', style:"font-family:'EUDC'"},
					{header:"原鑑價人員", key:'ORI_APPR_NM', style:"font-family:'EUDC'"},
					{header:"原鑑價組長", key:'ORI_CAPT_NM', style:"font-family:'EUDC'"},
					{header:"前次覆審年月", key:'PRE_REV_YM'},
					{header:"前次覆審鑑價員", key:'PRE_APPR_NM', style:"font-family:'EUDC'"},
					{header:"前次覆審總值", key:'PRE_TOTAL_PRICE', sortRule: 'number'},
					{header:"覆審年月", key:'REV_YM'},
					{header:"覆審鑑價員", key:'APPR_NM', style:"font-family:'EUDC'"},
					{header:"覆審鑑價進度", key:'APPR_PROCESS_NM'},
					{header:"派件日期", key:'APPR_ASSIGN_DATE', sortRule: 'date'}
				]
			});
			
			//按鈕事件監聽
			$('btn_query').observe('click', buttons.doQuery);//查詢
			$('btn_assign').observe('click', buttons.doAssign);//派件
			$('btn_transfer').observe('click', buttons.doTransfer);//移轉
			$('btn_clear').observe('click', buttons.doClear);//清除
			$('btn_export').observe('click', buttons.doExport);//匯出
			
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
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%" align="left" >
			鑑價科
		</td>
		<td class="tbYellow2" width="15%" >
			<select title="鑑價科" id="APPR_DEPT" name="APPR_DEPT">				
				<option value="">全部</option>
				<c:forEach items="${APPR_DEPT_LIST}" var="row">
					<option value="${row.key}"/>${row.value}</option>						
				</c:forEach>							
			</select>
		</td>	
		<td class="tbYellow" width="10%" align="left" >
			鑑價組
		</td>
		<td class="tbYellow2" width="15%" >
			<select title="鑑價組" id="APPR_GROUP" name="APPR_GROUP">				
				<option value="">全部</option>
				<c:forEach items="${APPR_GROUP_LIST}" var="row">
					<option value="${row.key}"/>${row.value}</option>						
				</c:forEach>							
			</select>
		</td>
		<td class="tbYellow" width="10%" align="left" >
			受理編號
		</td>
		<td class="tbYellow2" width="15%" >
			<input id="APPLY_ID" name="APPLY_ID" type="text" class="text2" size="12" maxlength="11" />				
		</td>
		<td class="tbYellow2" width="25%" rowspan="2" align="center">
			<button id="btn_query" type="button" class="button">查詢</button>
			<button id="btn_export" type="button" class="button">匯出</button>
			<button id="btn_clear" type="button" class="button">清除</button>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%" align="left" >
			覆審鑑價進度
		</td>
		<td class="tbYellow2" width="15%" colspan="5">
			<select title="覆審鑑價進度" id="APPR_PROCESS" name="APPR_PROCESS">				
				<option value="">全部</option>
				<c:forEach items="${APPR_PROCESS_LIST}" var="row">
					<option value="${row.key}"/>${row.value}</option>						
				</c:forEach>							
			</select>
		</td>	
	</tr>
	<tr>
		<td class="tbYellow" align="left">
			鑑價人員
		</td>
		<%--[20240927]難字 --%>
		<td class="tbYellow2">
			<select title="鑑價人員" id="APPR_ID" name="APPR_ID" alt="ch">
				<option value="">請選擇</option>
			</select>
		</td>
		<td class="tbYellow" align="left">
			支援人員
		</td>
		<td class="tbYellow2" colspan = "3">
			<select title="支援人員" id="SUPPORT_ID" name="SUPPORT_ID" alt="ch">
				<option value="">請選擇</option>
			</select>
		</td>
		<td class="tbYellow2" align="center">
			<button id="btn_assign" type="button" class="button">派件</button>
			<button id="btn_transfer" type="button" class="button">移轉</button>	
		</td>	
	</tr>
</table>
</form>
<table id="grid" class="grid"></table>
</body>
</html>