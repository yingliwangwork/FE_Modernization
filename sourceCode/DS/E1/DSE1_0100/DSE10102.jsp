<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%--<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>--%>

<!--
程式：DSE10102.jsp
作者：i9300619
功能：法院陳報債權試算
2018-07-20 wxlin 舊系統功能轉換
0723與債權管理科張人傑確認後，移除清償試算本金、利息、延滯息、違約金欄位
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>法院陳報債權試算</title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>

<script type="text/JavaScript">
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe( window, 'resize', fix);
Event.observe( window, 'scroll', fix);

function initApp(){
	//TODO buttonAuth(); //TODO ACTION_TYPE == null 時 單純依照按鈕授權處理
	var actionType = '${ACTION_TYPE}';
	if (actionType != 'U') {
		$('btn_print').disable();
	}
	displayMessage();
	
	new UI().init();
}

//按鈕授權處理
<%-- TODO function buttonAuth(){
	var authButtons = {
			B0001:'btn_calculate' //TODO 試算 按鈕編號
	};
	<dz:grantButtons FUNC_ID="DSE10102" />
}--%>

<!-- Define UI Class Start-------------------------------------------------------
function UI(){

	//--------------------------------------------------------------------------  
	//UI() private variable
	//-------------------------------------------------------------------------- 
	var grid1;
	var grid2;
	var grid3;
	var grid4;
	var grid5;
	var grid6;

	var rtnList;
	var grid4List;
	var grid5List;
	var grid5TotalList;
	var grid6List;
	var grid6TotalList;
	
	var grid5totalEXPENSE_AMT = 0;
	var grid6totalEXPENSE_AMT = 0;
	
	//var validator;
	//--------------------------------------------------------------------------  
	//UI() private method
	//--------------------------------------------------------------------------  
    //***
    //所有ajax doAction
    //***
	var doAction = {
		//列印
		print:function(){
		
			//20190828 申請書-190814001213:若放款案件之清償控管欄位為【法務控管】時，法院陳報債權作業時，按下【列印】按鈕時，跳出提示訊息
			var warnMsg = '';
			var obj_rtnList = rtnList.evalJSON();
			for(var i=0;i<obj_rtnList.size();i++){
				var rtnMap = obj_rtnList[i];
				if('1'==rtnMap.PAYOFF_LIMIT){
					if(warnMsg.length>0){
						warnMsg = warnMsg+'、';
					}
					warnMsg = warnMsg + rtnMap.LOAN_ID;
				}
			}
			if(warnMsg.length>0){
				if(!confirm('貸款帳號：'+warnMsg+'，有法務控管，請與控管單位確認!')){
					return;
				}
			}
			
			
			new Ajax.Request(
				"<%=dispatcher%>/DSE1_0102/print", 
				{
					parameters:{'rtnList':rtnList,  
						'grid4List':grid4List,
						'grid5List':Object.toJSON(grid5List),
						'grid5totalEXPENSE_AMT':grid5totalEXPENSE_AMT,
						'grid6List':Object.toJSON(grid6List),
						'grid6totalEXPENSE_AMT':grid6totalEXPENSE_AMT,
						'TOTAL_AMT1':'${formaMap.TOTAL_AMT1}',
						'COURT_NM':'${COURT_NM}',   //法院名稱，來源：初始.接值
						'CASE_NO':'${CASE_NO}',     //案號，來源：初始.接值
						'BRANCH':'${BRANCH}',         //股別，來源：初始.接值
						'sumOWE':'${formaMap.sumOWE}',
						'sumBalcAmt':'${formaMap.sumBalcAmt}'
					},
					onSuccess: function(XHT, resp){
						if(CSRUtil.isSuccess(resp)){
							RPTUtil.executePrintByResponse(resp, true);
						}
					}
				}
			);
		}
	};
	
	//--------------------------------------------------------------------------			
	//以下為UI() public method,放在 return 中
	//--------------------------------------------------------------------------  
	return{
	
		//init Function for 初始整個UI Class
		init:function(){
			
			//產生 grid1 物件
			grid1 = new TableUI( {
				table: $('grid1'),
				pageSize: 10,
				pageChange: function() {
					//取出grid1中 本金餘額欄位
					var tdObjs = $('grid1').select('TD[name="NEW_PRINCIPAL"]');
					
					for( var i = 0 ; i < tdObjs.length ; i++ ){
						//取得該欄變換底色
						tdObjs[i].style.backgroundColor = 'yellow';
						tdObjs[i].style.fontWeight = 'bold';
					}
				},
				column:[
					{ key: 'SER_NO', header: '', sortable:false},
					{ key: 'LOAN_ID', header: '貸款帳號'},
					{ key: 'NEW_PRINCIPAL', header: '本金餘額', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					}
				]
        	} );
			// end of grid1
			
			//產生 grid2 物件
			grid2 = new TableUI( {
				table: $('grid2'),
				pageSize: 10,
				pageChange: function() {
					//取出grid1中 本金餘額欄位
					var tdObjs = $('grid2').select('TD[name="INTAMT"]');
					
					for( var i = 0 ; i < tdObjs.length ; i++ ){
						//取得該欄變換底色
						tdObjs[i].style.backgroundColor = 'yellow';
						tdObjs[i].style.fontWeight = 'bold';
					}
				},
				column:[
					{ key: 'SER_NO', header: '', sortable:false},
					{ key: 'LOAN_ID', header: '貸款帳號'},
					{ key: 'NEW_PRINCIPAL', header: '計息本金', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					},
					{ key: 'RATE', header: '利率', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					},
					{ key: 'INT_BEGDT', header: '計算起日'},
					{ key: 'INT_ENDDT', header: '計算迄日'},
					{ key: 'INTDT', header: '天數', sortRule:'number', attrs:{align : "right"}},
					{ key: 'INTAMT', header: '利息', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					}
				]
        	} );
			// end of grid2
			
			//產生 grid3 物件
			grid3 = new TableUI( {
				table: $('grid3'),
				pageSize: 10,
				pageChange: function() {
					//取出grid1中 本金餘額欄位
					var tdObjs = $('grid3').select('TD[name="CAL_AMT1"]');
					
					for( var i = 0 ; i < tdObjs.length ; i++ ){
						//取得該欄變換底色
						tdObjs[i].style.backgroundColor = 'yellow';
						tdObjs[i].style.fontWeight = 'bold';
					}
				},
				column:[
					{ key: 'SER_NO', header: '', sortable:false},
					{ key: 'LOAN_ID', header: '貸款帳號'},
					{ key: 'NEW_PRINCIPAL', header: '計息本金', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					},
					{ key: 'CAL_RATE1', header: '利率', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					},
					{ key: 'CAL_BEGDT1', header: '計算起日'},
					{ key: 'CAL_ENDDT1', header: '計算迄日'},
					{ key: 'CAL_DT1', header: '天數', sortRule:'number', attrs:{align : "right"}},
					{ key: 'CAL_AMT1', header: '違約金一', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					}
				]
        	} );
			// end of grid3
			
			//產生 grid4 物件
			grid4 = new TableUI( {
				table: $('grid4'),
				pageSize: 10,
				pageChange: function() {
					//取出grid1中 本金餘額欄位
					var tdObjs = $('grid4').select('TD[name="CAL_AMT2"]');
					
					for( var i = 0 ; i < tdObjs.length ; i++ ){
						//取得該欄變換底色
						tdObjs[i].style.backgroundColor = 'yellow';
						tdObjs[i].style.fontWeight = 'bold';
					}
				},
				column:[
					{ key: 'GRID4_SER_NO', header: '', sortable:false},
					{ key: 'LOAN_ID', header: '貸款帳號'},
					{ key: 'NEW_PRINCIPAL', header: '計息本金', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					},
					{ key: 'CAL_RATE2', header: '利率', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					},
					{ key: 'CAL_BEGDT2', header: '計算起日'},
					{ key: 'CAL_ENDDT2', header: '計算迄日'},
					{ key: 'CAL_DT2', header: '天數', sortRule:'number', attrs:{align : "right"}},
					{ key: 'CAL_AMT2', header: '違約金二', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					}
				]
        	} );
			// end of grid4
			
			//產生 grid5物件
			grid5 = new TableUI( {
				table: $('grid5'),
				pageSize: 15,
				column:[
					{ key: 'GRID5_SER_NO', header: '', sortable:false},
					{ key: 'EXPENSE_NAME', header: '管理費用項目'},
					{ key: 'EFFECT_DATE', header: '發生日'},
					{ key: 'EXPENSE_AMT', header: '費用', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					},
					{ key: 'GRID5_SER_NO_2', header: '', sortable:false},
					{ key: 'EXPENSE_NAME_2', header: '管理費用項目'},
					{ key: 'EFFECT_DATE_2', header: '發生日'},
					{ key: 'EXPENSE_AMT_2', header: '費用', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}, renderInCount:true
					}
				]
        	} );
			// end of grid5
			
			//產生 grid6物件
			grid6 = new TableUI( {
				table: $('grid6'),
				pageSize: 15,
				column:[
					{ key: 'GRID5_SER_NO', header: '', sortable:false},
					{ key: 'EXPENSE_NAME', header: '管理費用項目'},
					{ key: 'EFFECT_DATE', header: '發生日'},
					{ key: 'EXPENSE_AMT', header: '費用', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					},
					{ key: 'GRID5_SER_NO_2', header: '', sortable:false},
					{ key: 'EXPENSE_NAME_2', header: '管理費用項目'},
					{ key: 'EFFECT_DATE_2', header: '發生日'},
					{ key: 'EXPENSE_AMT_2', header: '費用', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}, renderInCount:true
					}
				]
        	} );
			// end of grid6
			
			//-------------------------------------------------------------------------- 
			// 試算按鈕
			$('btn_print').observe('click',function(event){ 
				doAction.print(); 
			});
			// 上一頁按鈕
			$('btn_back').observe('click',function(event){
				CSRUtil.linkBack();
			});

			//load grid1 data
			rtnList = ( '${rtnList}' || '[]');
			grid1.load(rtnList.evalJSON());

			//load grid2 data
			grid2.load(rtnList.evalJSON());

			//load grid3 data
			grid3.load(rtnList.evalJSON());
			
			grid4List = ( '${grid4List}' || '[]');
			grid4.load(grid4List.evalJSON());
			
			//load grid5 data
			grid5List = <c:out value="${grid5List}" default="[]" escapeXml="false" />;
			grid5TotalList = <c:out value="${grid5TotalList}" default="[]" escapeXml="false" />;
			if(grid5List.length > 0) {
				grid5.load(grid5List, grid5TotalList);
			} else {
				grid5.load([]);
			}
			if (grid5TotalList != []) {
				$$('#grid5 td[colSpan=7]').each(function(td){
					td.align = 'right';
					var nextTD = td.next();
					nextTD.align = 'right';
				});
				
				if(grid5TotalList[0] && grid5TotalList[0]['value'] && grid5TotalList[0]['value']['EXPENSE_AMT_2']) {
					grid5totalEXPENSE_AMT = grid5TotalList[0]['value']['EXPENSE_AMT_2'];
				}
			}
			
			//load grid6 data
			grid6List = <c:out value="${grid6List}" default="[]" escapeXml="false" />;
			grid6TotalList = <c:out value="${grid6TotalList}" default="[]" escapeXml="false" />;
			if(grid6List.length > 0) {
				grid6.load(grid6List, grid6TotalList);
			} else {
				grid6.load([]);
			}
			if (grid6TotalList != []) {
				$$('#grid6 td[colSpan=7]').each(function(td){
					td.align = 'right';
					var nextTD = td.next();
					nextTD.align = 'right';
				});
				
				if(grid6TotalList[0] && grid6TotalList[0]['value'] && grid6TotalList[0]['value']['EXPENSE_AMT_2']) {
					grid6totalEXPENSE_AMT = grid6TotalList[0]['value']['EXPENSE_AMT_2'];
				}
			}
		}//end init()--
		
	}//end return--
	//-------------------------------------------------------------------------- 
}
<!--Define UI Class End-------------------------------------------------------->

-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<center>
<!-- Bolck_1_Start 表單的開頭 功能名稱 畫面編號-->
<span id="bar1" style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible">
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
			<tr>
				<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
			<tr>
				<td width="20" height="24">
				<div align="center"><font size="-5">●</font></div>
				</td>
				<td><b>法務件</b></td>
				<td>
				<div align="right">畫面編號：DSE10102</div>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</span> <!-- Bolck_1_ End--> <!-- Bolck_2_Start 空白區塊 版面跳行-->
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>

<!-- Bolck_2_End--> <!-- Bolck_3_Start 表單主功能區塊-->
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="top">
						<table width=97% border=0 align=center cellpadding="5" cellspacing="1" bgcolor="#003366">
							<tbody>
								<tr>
									<td class="tbBox2"><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">法院陳報債權試算</td>
								</tr>
								<!-- Bolck_4_Start 輸入區塊-->
								<tr bgcolor=#FFFFFF>
									<td>
										<form name="form1" id="form1" method="post">
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
												<tr>
													<td class="tbYellow">法院陳報債權試算</td>
												</tr>
												<tr>
													<td class="tbYellow2">(一)本金</td>
												</tr>
											</table>
											<!-- Query Result (Grid Table) -->
											<table id="grid1" class="grid"></table>
											<div style="height:20px"><p>&nbsp;</p></div>
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table2">
												<tr>
													<td class="tbYellow2">(二)利息</td>
												</tr>
											</table>
											<table id="grid2" class="grid"></table>
											<div style="height:20px"><p>&nbsp;</p></div>
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table3">
												<tr>
													<td class="tbYellow2">(三)違約金一</td>
												</tr>
											</table>
											<table id="grid3" class="grid"></table>
											<div style="height:20px"><p>&nbsp;</p></div>
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table4">
												<tr>
													<td class="tbYellow2">(四)違約金二</td>
												</tr>
											</table>
											<table id="grid4" class="grid"></table>
											<div style="height:20px"><p>&nbsp;</p></div>
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table5">
												<tr>
													<td class="tbYellow2">(五)管理費用&nbsp;-&nbsp;執行費用</td>
												</tr>
											</table>
											<table id="grid5" class="grid"></table>
											<div style="height:20px"><p>&nbsp;</p></div>
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table5-1">
												<tr>
													<td class="tbYellow2">(六)管理費用&nbsp;-&nbsp;取得執名費用</td>
												</tr>
											</table>
											<table id="grid6" class="grid"></table>
											<div style="height:20px"><p>&nbsp;</p></div>
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table6">
												<tr>
													<td class="tbYellow2" colspan="3">(七)合計</td>
												</tr>
												<tr class="tbBlue" align="center">
													<td width="33%">試算金額合計</td>
													<td width="33%">清償試算合計</td>
													<td width="34%">差額</td>
												</tr>
												<tr class="tbYellow2" align="right">
													<td><cathay:formatNumber type="number" value="${formaMap.TOTAL_AMT1}" pattern="#,###" /></td>
													<td><cathay:formatNumber type="number" value="${formaMap.TOTAL_AMT2}" pattern="#,###" /></td>
													<td><cathay:formatNumber type="number" value="${formaMap.DIFFER_AMT}" pattern="#,###" /></td>
												</tr>
											</table>
											<div style="height:30px">
												<p align="right">
													<input type="button" name="btn_print" id="btn_print" value="列印" class="button">
													<input type="button" name="btn_back" id="btn_back" value="上一頁" class="button">
												</p>
											</div>
										</form>
									</td>
								</tr>
								<!--Bolck_4_End-->
							</tbody>
						</table>
					</td>
				</tr>
			</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
<!-- Bolck_3_End-->
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
</center>
</body>
</html>