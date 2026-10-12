<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC90700.jsp
作者：楊鈞傑
功能：理財型屆期未處理作業
完成：2013/04/18
2018-10-16申請書-理財展期屆期派件調整：消金審查三科(桃竹)裁撤，作業科人員更名為資管科人員。

[20230324]
難字調整
高強禾
[20240612]修改件 [申請書: 24051555111]理財型還款清償與帳務作業優化
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>		<%-- 匯出PDF用--%>

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
var DSC90700 = new DSC90700();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, "load", DSC90700.initApp);
Event.observe(window, "resize", fix);
Event.observe(window, "scroll", fix);

function DSC90700(){

	var grid;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC9_0700/" + actionName,
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
	
	//儲存畫面
	function storeMap(){
		var reqMap={
			CRED_DEPT:$('CRED_DEPT').value,
			END_DATE:$('END_DATE').value,
			ASSIGN_ID:$F('Q_RLDS2')||$F('Q_RLDS4')||'',
			USE_STATUS:$('USE_STATUS').value,
			SORT_KEY: $F('SORT_KEY'),
			LOAN_ID: $F('LOAN_ID'),
			BORROW_ID: $F('BORROW_ID')
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
	
	//數字欄位格式
	function formatValue(val){
		return (val || val === 0) ? CSRUtil.$fmt(val,'#,##0.##########'):'';
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
		
		//列印(到期通知書)
		doPrintEXP : function(LOAN_ID,END_DATE,CRED_DEPT,ASSIGN_ID,MM_STATUS){
			
			ajaxPost("printEXP",{LOAN_ID: LOAN_ID , END_DATE : END_DATE , CRED_DEPT : CRED_DEPT , ASSIGN_ID : ASSIGN_ID , MM_STATUS : MM_STATUS},
				function(resp){
					var tempErrMsg = resp.tempErrMsg;	
					if(tempErrMsg){	
						//確認ok , 繼續執行
						if(!confirm('貸款帳號:'+ LOAN_ID +','+tempErrMsg)){
							return;
						}
					}
					RPTUtil.executePrintByLink ( "<%=dispatcher%>/DSC9_0710/prompt" , { LOAN_ID: LOAN_ID , END_DATE : END_DATE}, true );
				}
			);
		},
		
		//列印(換約申請書)
		doPrintCHG : function(LOAN_ID,END_DATE,CRED_DEPT,ASSIGN_ID,MM_STATUS){
			
			ajaxPost("printCHG",{LOAN_ID: LOAN_ID , END_DATE : END_DATE , CRED_DEPT : CRED_DEPT , ASSIGN_ID : ASSIGN_ID , MM_STATUS : MM_STATUS},
				function(resp){
					var tempErrMsg = resp.tempErrMsg;	
					if(tempErrMsg){	
						//確認ok , 繼續執行
						if(!confirm('貸款帳號:'+ LOAN_ID +','+tempErrMsg)){
							return;
						}
					}
					RPTUtil.executePrintByLink ( "<%=dispatcher%>/DSC9_0720/prompt" , { LOAN_ID: LOAN_ID , END_DATE : END_DATE}, true );
				}
			);
		}
	};
	
	return {
		initApp : function() {			
			PageUI.createPageWithAllBodySubElement(
				"DSC90700",
				"理財型房貸",
				"理財型屆期報表作業"
			);
			
			grid = new TableUI({
				table:$('grid'),pageSize:20,allSortable:false,
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
					},
					{header:"同意續約通知書列印日期", key:'EXP_PRINT_DATE',
						render:function(rec,val){
							var print = new Element("input" , {type : 'button' , value : '列印' , className : 'button'} );
							print.observe("click", function(event){
									buttons.doPrintEXP(rec.LOAN_ID,rec.END_DATE,rec.CRED_DEPT,rec.ASSIGN_ID,rec.MM_STATUS);          
							});
							var span = new Element('span');
							if (rec.ROW_TYPE=='1'){
								if (val){
									span.insert(Date.toROC(val||'')).insert(print);
									return span;
								} else {
									return span.insert(print);
								}
							} else {
								return '';
							}
						}
					},
					{header:"不同意續約通知書列印日期", key:'CHG_PRINT_DATE',
						render:function(rec,val){
							var print = new Element("input" , {type : 'button' , value : '列印' , className : 'button'} );
							print.observe("click", function(event){
									buttons.doPrintCHG(rec.LOAN_ID,rec.END_DATE,rec.CRED_DEPT,rec.ASSIGN_ID,rec.MM_STATUS);          
							});
							var span = new Element('span');
							if (rec.ROW_TYPE=='1'){
								if (val){
									span.insert(Date.toROC(val||'')).insert(print);
									return span;
								}else{
									return span.insert(print);
								}
							} else {
								return '';
							}
						}
					}
				]
			});
			
			//查詢
			$("btn_query").observe('click', buttons.doQuery);
			
			//承辦科別下拉選單連動
			$('CRED_DEPT').observe('change',function(event){
				buttons.doMenu();
			});
			
			/*
				處理人員-審查科人員及處理人員-作業科人員：
				當有一個選取不為全部另一個要自動跳回全部
			*/
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
			<%--[20240612]貸款帳號、借款人ID轉大寫--%>
			$w('LOAN_ID BORROW_ID').each(function(id){
           		$(id).observe('change', function(){
           			$(this).setValue(toUpperCase($F(this)));
           		});
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
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbYellow">承辦科別</td>
		<td class="tbYellow2">
			<select id="CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach var="map" items="${CRED_DEPT_LIST}" >
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">貸款帳號</td>
		<td class="tbYellow2">
			<input id="LOAN_ID" name="LOAN_ID" type="text" class="textBox2" maxlength="11" />
		</td>
		<td class="tbYellow">借款人ID</td>
		<td class="tbYellow2">
			<input id="BORROW_ID" name="BORROW_ID" type="text" class="textBox2" maxlength="10" />
		</td>
		<td class="tbYellow">到期月份</td>
		<td class="tbYellow2" colspan="3">
			<select id="END_DATE" class="textBox2">
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
		<td class="tbYellow">處理人員</td>
		<td class="tbYellow2" colspan="5">
			審查科人員：
			<%-- [20230324] 難字調整 --%>
			<select id="Q_RLDS2" class="textBox2" alt="ch">
				<option value="">全部　</option>
			</select>
			資管科人員：
			<%-- [20230324] 難字調整 --%>
			<select id="Q_RLDS4" class="textBox2" alt="ch"> 
				<option value="">全部　</option>
			</select>
		</td>
		<td class="tbYellow">使用狀況</td>
		<td class="tbYellow2">
			<select id="USE_STATUS" class="textBox2">
				<option value="">全部</option>
				<c:forEach var="map" items="${USE_STATUS_LIST}" >
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">
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

</table>
</form>
<table id="grid" width="100%"></table>	
</body>
</html>