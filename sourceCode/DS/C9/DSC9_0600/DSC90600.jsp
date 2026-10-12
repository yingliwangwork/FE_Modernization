<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC90600.jsp
作者：陳昊
功能：理財型屆期派件作業
完成：2013/03/26
2018-10-16申請書-理財展期屆期派件調整：消金審查三科(桃竹)裁撤，新增改派承辦科別功能

[20230324]
難字調整
高強禾
-->

<html> 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/javascript" src="<%=htmlBase%>/CM/js/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>

<%-- [20230324] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>

<script type="text/javascript">

// 產生畫面物件
var DSC90600 = new DSC90600();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, "load", DSC90600.initApp);
Event.observe(window, "resize", fix);
Event.observe(window, "scroll", fix);

function DSC90600(){

	var grid;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC9_0600/" + actionName,
		{  
			parameters: params, 
			onSuccess:function(response){
				var resp = response.responseJSON
				if(CSRUtil.isSuccess(resp)){	
					if(successFunction){
						successFunction(resp);
					}
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			}			
		});
	}
	
	//按鈕授權
	function buttonAuth(){
		var authButtons = {
			B0067:"btn_send"
		};
		<dz:grantButtons FUNC_ID="DSC90600"/>
	};	
	
	//儲存畫面
	function storeMap(){
		var reqMap={
			CRED_DEPT:$('CRED_DEPT').value,
			END_DATE:$('END_DATE').value,
			ASSIGN_ID:$F('Q_RLDS2')||$F('Q_RLDS4')||'',
			SORT_KEY: $F('SORT_KEY')
		};
		return reqMap;
	}
	
	//連動選單
	function setMenu(resp){
		var RLDS2_LIST=resp.RLDS2_LIST;
		var RLDS4_LIST=resp.RLDS4_LIST;
		$('Q_RLDS2').length=1;
		$('Q_RLDS4').length=1;
		if(RLDS2_LIST){
			for(var i=0;i<RLDS2_LIST.length;i++){
				$('Q_RLDS2').add(new Option(RLDS2_LIST[i]['NAME'],RLDS2_LIST[i]['ID']));
			}
		}
		if(RLDS4_LIST){
			for(var i=0;i<RLDS4_LIST.length;i++){
				$('Q_RLDS4').add(new Option(RLDS4_LIST[i]['NAME'],RLDS4_LIST[i]['ID']));
			}
		}
	}
	
	//連動選單
	function setMenu2(resp){
		var RLDS2_LIST=resp.RLDS2_LIST;
		var RLDS4_LIST=resp.RLDS4_LIST;
		$('N_RLDS2').length=1;
		$('N_RLDS4').length=1;
		if(RLDS2_LIST){
			for(var i=0;i<RLDS2_LIST.length;i++){
				$('N_RLDS2').add(new Option(RLDS2_LIST[i]['NAME'],RLDS2_LIST[i]['ID']));
			}
		}
		if(RLDS4_LIST){
			for(var i=0;i<RLDS4_LIST.length;i++){
				$('N_RLDS4').add(new Option(RLDS4_LIST[i]['NAME'],RLDS4_LIST[i]['ID']));
			}
		}
	}
	
	//數字欄位格式
	function formatValue(val){
		var pattern='#,###.############';
		return val ? CSRUtil.$fmt(val,pattern):'0';
	}
	
	var buttons = {
		//查詢
		doQuery:function(event){
			ajaxPost("query",{reqMap:Object.toJSON(storeMap())},
				function(resp){
					grid.load(resp.rtnList||[]);
				},
				function(resp){
					grid.load([]);
				}
			);
		},
		//下拉選單連動
		doMenu:function(event){
			ajaxPost("menu",{CRED_DEPT:$F('CRED_DEPT')},
				function(resp){
					setMenu(resp);
				}
			);
		},
		//下拉選單連動
		doMenu2:function(event){
			ajaxPost("menu",{CRED_DEPT:$F('NEW_CRED_DEPT')},
				function(resp){
					setMenu2(resp);
				}
			);
		},		
		//派件
		doSend:function(event){
			var rec=grid.getCheckedRecord();
			if(rec.length == 0){
				alert("請先勾選欲派件資料，才能作業");
				return ;
			}
			if(!$F('N_RLDS2')&&!$F('N_RLDS4')){
				alert("請先選取新處理人員，才能作業");
				return ;
			}
			if(${IS_RLDS4}&&$F('N_RLDS2')){
				if(!confirm("是否將案件派給審查科人員")){
					return;
				}
			}
			ajaxPost("send",{
					chkList:Object.toJSON(rec),
					reqMap:Object.toJSON(storeMap()),
					NEW_CRED_DEPT:$F('NEW_CRED_DEPT'),
					ASSIGN_ID:$F('N_RLDS2')||$F('N_RLDS4')||''
				},function(resp){
					grid.load(resp.rtnList||[]);
				}
			);
		}
	};
	
	return {
		initApp : function() {			
			PageUI.createPageWithAllBodySubElement(
				"DSC90600",
				"理財型房貸",
				"理財型屆期派件作業"
			);
			
			grid = new TableUI({
				table:$('grid'),pageSize:20,allSortable:false,
				autoCheckBox:{
					isSelectAll: true,
					withoutGroup: true,
					genRule:function(rec,val){
						return rec.ROW_TYPE=='1'?true:false;
					},
					disableRule:function(rec,val){
						if(rec.TYPE=='1'&& ${IS_RLDS2}){
							return false;
						} else if(rec.TYPE=='0'&& ${IS_RLDS4}){
							return false;
						} else {
							return true;
						}
					}

				},
				<%-- [20230324] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{header:"貸款帳號", key:'LOAN_ID',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val: rec.C100_LOAN_ID;
						}
					},
					<%-- [20230324] 難字調整 --%>
					{header:"借款人姓名", key:'BORROW_NAME',attrs:{style:"font-family:'EUDC'"}},
					{header:"使用狀態/契約狀況", key:'MM_STATUS_NM',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:rec.LOAN_STATUS_NM;
						}
					},
					{header:"原貸帳號", key:'REFER_ID', groupKey:["REFER_ID"]},
					{header:"擔借款總餘額", key:'REMAIN_AMT',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? formatValue(val):'';
						}
					},
					{header:"理財型額度", key:'MM_AMT',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? formatValue(val):'';
						}
					},
					{header:"動用金額", key:'C104_REMAIN_AMT',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? formatValue(val):'';
						}
					},
					{header:"本金餘額", key:'TYPE_NM',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val : formatValue(rec.C100_REMAIN_AMT);
						}
					},
					{header:"到期日", key:'END_DATE',
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? Date.toROC(val||'') : Date.toROC(rec.C100_END_DATE||'');
						}
					},
					<%-- [20230324] 難字調整 --%>
					{header:"處理人員", key:'ASSIGN_NAME',attrs:{style:"font-family:'EUDC'"},
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					},
					<%-- [20230324] 難字調整 --%>
					{header:"經手人/收展員", key:'AGENT_NAME',attrs:{style:"font-family:'EUDC'"},
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val:'';
						}
					}
				]
			});
			
			buttonAuth();
			
			$("btn_query").observe('click', buttons.doQuery);
			$("btn_send").observe('click', buttons.doSend);
			
			$('CRED_DEPT').observe('change',function(event){
				buttons.doMenu();
			});
			$('NEW_CRED_DEPT').observe('change',function(event){
				buttons.doMenu2();
			});
			
			$('Q_RLDS2').observe('change',function(event){
				if($F('Q_RLDS2')){
					$('Q_RLDS4').value="";
				}
			});
			$('Q_RLDS4').observe('change',function(event){
				if($F('Q_RLDS4')){
					$('Q_RLDS2').value="";
				}
			});
			$('N_RLDS2').observe('change',function(event){
				if($F('N_RLDS2')){
					$('N_RLDS4').value="";
				}
			});
			$('N_RLDS4').observe('change',function(event){
				if($F('N_RLDS4')){
					$('N_RLDS2').value="";
				}
			});
			PageUI.resize();
			displayMessage();
		}
	};	
};

</script>
</head>
<body>		
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<input type="hidden" id="IS_RLDS2" value="${IS_RLDS2}">
<input type="hidden" id="IS_RLDS4" value="${IS_RLDS4}">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbYellow" width="15%">
			承辦科別
		</td>
		<td class="tbYellow2">
			<select name="CRED_DEPT" id="CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach var="map" items="${CRED_DEPT_LIST}" >
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width="15%">
			到期月份
		</td>
		<td class="tbYellow2">
			<select name="END_DATE" id="END_DATE" class="textBox2">
				<c:forEach var="map" items="${END_DATE_LIST}" >
					<option value = "${map.END_DATE}" > ${map.END_DATE}</option>
				</c:forEach>
			</select>
		</td>
		<td align="center" class="tbYellow2" width="10%" rowspan="2">
			<input id="btn_query" type="button" class="button" value="查詢"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			處理人員
		</td>
		<td class="tbYellow2">
			審查科人員：
			<%-- [20230324] 難字調整 --%>
			<select name="Q_RLDS2" id="Q_RLDS2" class="textBox2" alt="ch" <c:if test="${!IS_RLDS2 && !IS_RLDS4}">disabled="true"</c:if>>
				<option value="">全部　</option>
			</select>
			資管科人員：
			<%-- [20230324] 難字調整 --%>
			<select name="Q_RLDS4" id="Q_RLDS4" class="textBox2" alt="ch" <c:if test="${!IS_RLDS4}">disabled="true"</c:if>>
				<option value="">全部　</option>
			</select>
		</td>
		<td class="tbYellow" width="15%">
			排序方式
		</td>
		<td class="tbYellow2">
			<select id="SORT_KEY" class="textBox2">
				<c:forEach items="${SORT_KEY_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td align="center" colspan="5">
			<input id="btn_send" type="button" class="button" value="派件"/>
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='15%'>
			新承辦科別
		</td>
		<td class='tbYellow2' width='30%'>
			<select id="NEW_CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach items="${CRED_DEPT_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">
			新處理人員
		</td>
		<td class="tbYellow2" colspan="2">
			審查科人員：
			<%-- [20230324] 難字調整 --%>
			<select name="N_RLDS2" id="N_RLDS2" class="textBox2" alt="ch" <c:if test="${!IS_RLDS2 && !IS_RLDS4}">disabled="true"</c:if>>
				<option value="">全部　</option>
			</select>
			資管科人員：
			<%-- [20230324] 難字調整 --%>
			<select name="N_RLDS4" id="N_RLDS4" class="textBox2" alt="ch" <c:if test="${!IS_RLDS4}">disabled="true"</c:if>>
				<option value="">全部　</option>
			</select>
		</td>
	</tr>
</table>
</form>
<table id="grid" width="100%"></table>	
</body>
</html>