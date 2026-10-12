<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSB40500.jsp
作者：簡睿甫
功能：匯款結案作業
完成：

[20221228] 修改件: [申請書:220725005491]新增本金彈性還還款方式
		         作者:林均儕

[20240613]
難字調整
高強禾		         
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>
<%-- [20240613] 難字調整 --%>
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

Event.observe(window, 'load', new DSB40500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB40500(){
	var grid;
	var Creddept = '<c:out value="${Creddept}" default="" escapeXml="false" />';
	
	var A010Map = <c:out value="${A010Map}" default="[]" escapeXml="false" />;
	var OLD_APPLY_ID;

	//--------------------------------------------------------------------------	
	//按鈕授權
	//--------------------------------------------------------------------------	
	function buttonAuth() {
		var authButtons = { 
			B0112:'BTN_0112'<%-- 未匯金額取消 --%>,
			B0113:'BTN_0113'<%-- 未匯金額取消回復 --%>,
			B0114:'BTN_0114'<%-- 匯款結案 --%>,
			B0115:'BTN_0115'<%-- 匯款結案回復 --%>,
			B0241:'BTN_0241'<%-- 中長期動撥結案 --%>,
			B0242:'BTN_0242'<%-- 中長期動撥結案回復 --%>
			
		};
		<dz:grantButtons FUNC_ID="DSB40500" ignored="false"/>
	}
	
	//-----------------------------------------------------
	//IM AJAX 國內共用
	//-----------------------------------------------------
	function ajaxPostIM( actionName, params, successAction, errorFunction ){
		new Ajax.Request(
			"<%=dispatcher%>/DSB4_0500/" + actionName, 
			{ parameters : params ,
			  onSuccess : function (response) {
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){      
					successAction(resp);
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			 }
		});
	}	
	
	// 按鈕控制
	var button = {
		// 查詢
		doQuery: function() {
		
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.queryChecked();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			ajaxPostIM( 'query' ,  {APPLY_ID: $F('APPLY_ID'), Creddept: Creddept}, action.returnDataHandler,
				function(resp){			
					grid.load([]); 
				}				
			);
		}, 
		
		// 未匯金額取消
		doCancel:　function() {
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.exceptQueryChecked();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			<%-- [20221228] [申請書:220725005491]新增本金彈性還還款方式 ，尚未上版，先註解--%>
			if(A010Map.IS_FLEX == "Y") {
				alert("本件因匯款金額調整，請依規定重新檢視每月約定還款金額，並請聯繫客戶說明!");
			}
			
			
			ajaxPostIM( 'cancel' ,  {MapA: Object.toJSON(A010Map), APPLY_ID: $F('APPLY_ID'), Creddept: Creddept}, action.returnDataHandler);
			
		}, 
		
		// 未匯金額取消回復
		doRecover1:　function() {
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.exceptQueryChecked();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			<%-- [20221228] [申請書:220725005491]新增本金彈性還還款方式，尚未上版，先註解--%>
			if(A010Map.IS_FLEX == "Y") {
				alert("請注意，本件因匯款金額調整，請依規定重新檢視每月約定還款金額，並請聯繫客戶說明!");
			}
			 
			
			ajaxPostIM( 'recover1' ,  {MapA: Object.toJSON(A010Map), APPLY_ID: $F('APPLY_ID'), Creddept: Creddept}, action.returnDataHandler);
		}, 
		
		// 匯款結案
		doClose:　function() {
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.exceptQueryChecked();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			ajaxPostIM( 'close' ,  {MapA: Object.toJSON(A010Map), APPLY_ID: $F('APPLY_ID'), Creddept: Creddept}, action.returnDataHandler);
		}, 
		
		// 匯款結案回復
		doRecover2:　function() {
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.exceptQueryChecked();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			ajaxPostIM( 'recover2' ,  {MapA: Object.toJSON(A010Map), APPLY_ID: $F('APPLY_ID'), Creddept: Creddept}, action.returnDataHandler);
		},
		
		// 中長期動撥結案
		doMultiClose:　function() {
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.exceptQueryChecked();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			ajaxPostIM( 'multiclose' ,  {MapA: Object.toJSON(A010Map), APPLY_ID: $F('APPLY_ID'), Creddept: Creddept}, action.returnDataHandler);
		}, 
		
		// 中長期動撥結案回復
		doMultiCloseRecover:　function() {
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.exceptQueryChecked();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			ajaxPostIM( 'multicloserecover' ,  {MapA: Object.toJSON(A010Map), APPLY_ID: $F('APPLY_ID'), Creddept: Creddept}, action.returnDataHandler);
		}
	};
	
	// 行為
	var action = {
		// 填入B 區塊資料
		doFillupBlockB: function() {

		},
		
		// AJAX 成功行為
		returnDataHandler: function(resp) {
			A010Map = resp.A010Map;
			if(A010Map) {
				OLD_APPLY_ID = A010Map['OLD_APPLY_ID'];
				
				// 借款人ID	  借款人姓名  貸款帳號 代償二匯狀態    受理進度   火險單是否歸檔
				$w('BORROW_ID BORROW_NAME LOAN_ID CLOSE_TYPE APPLY_PROCESS_NM FILE_FIREINSU').each(function(td) {
					$(td).update(A010Map[td]);
				});
				
				//  擬准金額  已匯金額   未匯金額       金額格式
				$w('AGREE_AMT REMIT_TAMT REMIT_BALANCE').each(function(td) {
					$(td).update(action.formatValue("", A010Map[td]));
				});
			}
			
			grid.load(resp.rtnList || []);
		},

		// 數字欄位格式
		pattern : '#,###.###', 
		
		// 數字欄位處理(三位一撇)
		formatValue : function(record, value) {
			if(Object.isNumber(value)) {
				return value ? CSRUtil.$fmt(value, action.pattern) : '0';
			} else {
				return value ?  value : '0';
			}
		}
	};
	
	// 檢核
	var validates = {
		initValidation : function() {
			// 欄位檢核
			validates.valid = new Validation("form", { mode:'validator'} );	
			Validation.addAllThese( [
				// 輸入欄位長度及資料型態檢核
				['length-check', '欄位長度有誤',
					function( v,ele,info ) {
						if( v && v.length != ele.maxLength) {
							return false
						}
						return true;
					}
				],
				
				// 受理編號與原先查詢的資料不同，無法作業!
				['different-from-original', '受理編號與原先查詢的資料不同，無法作業!',
					function( v,ele,info ) {
						if(v != OLD_APPLY_ID) {
							return false;
						}
						return true;
					}
				]/*,
				
				// 若匯款種類選擇代償一匯(=21),則檢核必須輸入代償戶姓名，且要為全形字，若無，則跳出警示訊息:"代償一匯須輸入代償戶姓名(全形)!"
				// 若匯款種類非代償一匯(!=21),則檢核匯款戶名與借款人姓名是否相符，若無，則跳出警示訊息:"本件匯款戶名與借款人姓名不相符，請確認是否新增匯款資料!"
				['remitTypeis21', '本件匯款戶名與借款人姓名不相符，請確認是否新增匯款資料!',
					function( v,ele,info ) {
						return false;
					}
				]*/
			] );
		},
		
		// 查詢檢核
		queryChecked: function(){
			validates.valid.define('required', {id:'APPLY_ID', errMsg:"請輸入受理編號查詢!!"});
			validates.valid.define('length-check', {id:'APPLY_ID'});
		}, 
		
		// 查詢之外的 檢核
		exceptQueryChecked: function() {
			validates.valid.define('different-from-original', {id:'APPLY_ID'});
		},
		
		// 檢核清除
		clear: function() {
			// 清空檢核標記
			validates.valid.reset();
			// 清空檢核設定
			validates.valid.clear();
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSB40500" , "匯款作業", "匯款結案作業" );
			
			grid = new TableUI(
				{table: $("grid"), allSortable: true, pageSize: 10, whenDataNull:'', title: "己處理之匯款",
				<%-- [20240613] 難字調整 --%>
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{header:"匯款種類",key:"REMIT_TYPE_NM"},
					{header:"帳號",key:"REMIT_ACCOUNT"},
					<%-- [20240613] 難字調整：戶名 --%>	
					{header:"戶名",key:"ACCOUNT_NAME",attrs:{ style:"font-family:'EUDC'" }},
					{header:"匯款金額",key:"REMIT_AMT",
						render: action.formatValue
					},
					{header:"匯款日期",key:"REMIT_DATE",
						render: function(record, value) {
							return Date.toInputROC(value, '/');
						}
					},
					{header:"處理進度",key:"REMIT_PROC_NM"}
				]
			});
			
			// 檢核初始化
			validates.initValidation();
			
			// 監聽: 查詢
			$("BTN_0001").observe('click', button.doQuery );
			
			// 監聽: 未匯金額取消
			$("BTN_0112").observe('click', button.doCancel );
			
			// 監聽: 未匯金額取消回復
			$("BTN_0113").observe('click', button.doRecover1 );
			
			// 監聽: 匯款結案
			$("BTN_0114").observe('click', button.doClose );
			
			// 監聽: 匯款結案回復
			$("BTN_0115").observe('click', button.doRecover2 );
			
			// 監聽: 中長期動撥結案
			$("BTN_0241").observe('click', button.doMultiClose );
			
			// 監聽: 中長期動撥結案回復
			$("BTN_0242").observe('click', button.doMultiCloseRecover );
			
			
			// 監聽: 受理編號轉大寫
			$("APPLY_ID").observe('change', function() {$("APPLY_ID").value = $F("APPLY_ID").toUpperCase();} );	
			PageUI.resize();
			buttonAuth();
			displayMessage();
		}// end initApp()--
	}// end return--
}// end DSB40500
</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form">
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
		<tbody>
			<tr>
				<td class="tbYellow" width="15%" >
					受理編號
				</td>
				<td  class="tbYellow2" width="60%" >
					<input id="APPLY_ID" name="APPLY_ID" type="text" size="11" maxlength="11" >
				</td>
				<td class="tbYellow2" align="center" >
					<input id="BTN_0001" type="button" value='查詢' class="button"> 
				</td>
			</tr>
			<tr>
				<td colspan="3"  align="center" >
					<input id="BTN_0112" type="button" value='未匯金額取消' class="button"> 
					<input id="BTN_0113" type="button" value='未匯金額取消回復' class="button"> 
					<input id="BTN_0114" type="button" value='匯款結案' class="button"> 
					<input id="BTN_0115" type="button" value='匯款結案回復' class="button"> 
					<input id="BTN_0241" type="button" value='中長期動撥結案' class="button"> 
					<input id="BTN_0242" type="button" value='中長期動撥結案回復' class="button"> 
				</td>
			</tr>
		</tbody>	
	</table>
	</form>
		<table id='block_B' width="100%" class="tbBox2" >
		<tbody>
			<tr>
				<td colspan='6' class="tbYellow0" align='center' vlign='center' >
					貸款資料
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >借款人ID</td>
				<td id="BORROW_ID" class="tbYellow2">
				
				</td>
				<td class="tbYellow" width="15%" >借款人姓名</td>
				<%-- [20240613] 難字調整：借款人姓名 --%>
				<td id="BORROW_NAME" class="tbYellow2" style="font-family:'EUDC'">
				
				</td>
				<td class="tbYellow" width="15%" >貸款帳號</td>
				<td id="LOAN_ID" class="tbYellow2">
				
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >擬准金額</td>
				<td class="tbYellow2">
					<span id="AGREE_AMT" ></span>萬元
				</td>
				<td class="tbYellow" width="15%" >已匯金額</td>
				<td class="tbYellow2">
					<span id="REMIT_TAMT" ></span>元
				</td>
				<td class="tbYellow" width="15%" >未匯金額</td>
				<td class="tbYellow2">
					<span id="REMIT_BALANCE" ></span>元
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >代償二匯狀態</td>
				<td  class="tbYellow2">
					<span id="CLOSE_TYPE" style="color:red;"></span>
				</td>
				<td class="tbYellow" width="15%" >受理進度</td>
				<td id="APPLY_PROCESS_NM" class="tbYellow2">
				
				</td>
				<td class="tbYellow" width="15%" >火險單是否歸檔</td>
				<td id="FILE_FIREINSU" class="tbYellow2">
				
				</td>
			</tr>
		</tbody>	
	</table>	
	<table id='grid'></table>
</body>
</html>	