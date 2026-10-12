<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%--<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>--%>

<!--
程式：DSE10101.jsp
作者：i9300619
功能：法院陳報資料選取
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>法院陳報債權試算</title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>

<script type="text/JavaScript">
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe( window, 'resize', fix);
Event.observe( window, 'scroll', fix);

function initApp(){
	//TODO buttonAuth(); //TODO ACTION_TYPE == null 時 單純依照按鈕授權處理
	displayMessage();
	
	new UI().init();
	//ACTION_TYPE判斷必須在UI().init()之後, 因為hidden 值在init()內設定
	var actionType = $F('ACTION_TYPE');
	if (actionType != 'U') {
		$('btn_calculate').disable();
	}
}

//按鈕授權處理
<%-- TODO function buttonAuth(){
	var authButtons = {
			B0001:'btn_calculate' //TODO 試算 按鈕編號
	};
	<dz:grantButtons FUNC_ID="DSE10101" />
}--%>

<!-- Define UI Class Start-------------------------------------------------------
function UI(){

	//--------------------------------------------------------------------------  
	//UI() private variable
	//-------------------------------------------------------------------------- 
	var grid1;
	var grid2;
	var grid3;
	
	//var checkedCountEXP_KIND1 = 0; // 執行費用
	//var checkedCountEXP_KIND2 = 0; // 取得執名費用
	
	var EXP_List1;
	var EXP_List2;
	//var validator;
	//--------------------------------------------------------------------------  
	//UI() private method
	//--------------------------------------------------------------------------  
    //***
    //所有ajax doAction
    //***
	var doAction = {
		//初始查詢
		query:function(){
			new Ajax.Request(
				"<%=dispatcher%>/DSE1_0101/query", 
				{
					parameters:{SALE_DATE:$F('SALE_DATE'), 
						chkList: $F('chkList')
					},
					onSuccess: function(XHT, resp){
						if(CSRUtil.isSuccess(resp)){
							//load grid1 data
							grid1.load(resp.rtnList || []);
							
							//load grid2 data
							EXP_List1 = resp.EXP_List1 || [];
							if(EXP_List1.length > 0) {
								for(var i = 0; i < EXP_List1.length; i++) {
									EXP_List1[i].index = i;
								}
							}
							grid2.load(EXP_List1);
							
							//load grid3 data
							EXP_List2 = resp.EXP_List2 || [];
							if(EXP_List2.length > 0) {
								for(var i = 0; i < EXP_List2.length; i++) {
									EXP_List2[i].index = i;
								}
							}
							grid3.load(EXP_List2);
						} else {
							grid1.load([]);
						
							//load grid2 data
							grid2.load([]);
							
							//load grid3 data
							grid3.load([]);
						}
					}
				}
			);
		},
		//試算
		calculate:function(){

			//grid1 資料輸入檢核
			var errArray = vaildRecords();
			var ErrMsg='';
			var len = errArray.length;
			if(len>0){
				for(var i =0 ; i<len ; i++ ){
					var dataobj = errArray[i]['dataObj'];
					ErrMsg = ErrMsg + "貸款帳號:" + dataobj['LOAN_ID'] + "\n";
					var validHash = errArray[i]['validHash'];
					validHash.each(function(map){
						ErrMsg=ErrMsg+map.value+"\n\r";
					});
					ErrMsg=ErrMsg+"\n\r";
				}
				alert(ErrMsg);
				return false;
			}
			
			var selectedGrid1Records = grid1.getAllRecords();
			
			//超連結至DSE10102 (法院陳報債權試算)畫面，供使用者進行試算作業
			var selectedGrid2Records = grid2.getCheckedRecord();
			var selectedGrid3Records = grid3.getCheckedRecord();
			
			var LP_JSON = {
				action:'<%=dispatcher%>/DSE1_0102/prompt',
				ACTION_TYPE:'U', //作業種類
				LINK_TYPE:'IN', //連結種類
				LINK_FROM:'DSE10101', //來源頁面
				sendList:Object.toJSON(selectedGrid1Records), //勾選的區塊1資料
				sendList1:Object.toJSON(selectedGrid2Records), //勾選的區塊2資料
				sendList2:Object.toJSON(selectedGrid3Records), //勾選的區塊3資料
				SALE_DATE:$F('SALE_DATE'), //給DSE1_0102回傳用
				chkList:$F('chkList'), //給DSE1_0102回傳用
				COURT_NM:'${COURT_NM}',   //法院名稱，來源：初始.接值
				CASE_NO:'${CASE_NO}',     //案號，來源：初始.接值
                BRANCH:'${BRANCH}'         //股別，來源：初始.接值
			};

			CSRUtil.linkTo(LP_JSON, 'form1');
		}/*,
		
		// 取得 Grid2 的勾選List
		getGrid2CheckedRecord: function() {
			if(rtnList2) {
				var checkedArray = [];
				var newRtnList2 = [];
				
					$$('#grid2 input[name=EXP_KIND1]').each(function(input) {
						if(input.checked == true && input.index >= 0 ) {
							checkedArray.push(input.index);
						}
					});
					
					for(var j = 0 ; j < rtnList2.length; j++) {
						var sendMap2 = rtnList2[j];
						if(checkedArray.indexOf(sendMap2.index) >= 0) {
							sendMap2.EXP_KIND = "1"; //管理費種類=執行費用("1")
							newRtnList2.push(sendMap2);
						}
					}
					
				checkedArray = [];
					$$('#grid2 input[name=EXP_KIND2]').each(function(input) {
						if(input.checked == true && input.index >= 0 ) {
							checkedArray.push(input.index);
						}
					});
					
					for(var j = 0 ; j < rtnList2.length; j++) {
						var sendMap2 = rtnList2[j];
						if(checkedArray.indexOf(sendMap2.index) >= 0) {
							sendMap2.EXP_KIND = "2"  //管理費種類=取得執名費用("2")
							newRtnList2.push(sendMap2);
						}
					}
				
				
				return newRtnList2;
			}
		}*/
	};
	
	//檢核grid1
	function vaildRecords(){
		var TRs = $('grid1').down('tbody').select('tr');
		var Objs = [];
		if(TRs.length > 0){
			for(var i = 0 ; i < TRs.length ; i = i + 1 ){
				var tr = TRs[i];
				var valid = getValidRecord(tr);
				if( valid ){ Objs.push(valid); }
						
			}
		}
		return Objs; 
	}
	
	//--------------------------------------------------------------------------			
	//以下為UI() public method,放在 return 中
	//--------------------------------------------------------------------------  
	return{
	
		//init Function for 初始整個UI Class
		init:function(){
			
			//validator = new Validator();
			
			//產生 grid1 物件
			grid1 = new TableUI( {
				table: $('grid1'),
				pageSize: 10,pageChange:vaildRecords,
				column:[
					{ key: 'LOAN_ID', header: '貸款帳號'},
					{ key: 'NEW_PRINCIPAL', header: '本金餘額', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					},
					{ key: 'BALC_AMT', header: '暫收款', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					},
					{ key: 'RATE', header: '利率',
						input:{
							type:'NUMBER', size:10, width:10,
							action:function( node , dataObj , textDiv, orgData ) {
								var result = setValidRecord( node , dataObj , validateNum(node.value) , '利率請輸入數值');
								if (result) {
									alert(result);
								}
							}
						}
					},
					{ key: 'INT_BEGDT', header: '起息日',
						input:{
							//日曆圖檔使用的路徑，只要放前段就好
							type:'Date', imgBase: '<%=imageBase%>/',
							action:function( node , dataObj , textDiv, orgData ) {
								var result = setValidRecord( node , dataObj , validateDateInput(node.value) , '起息日請輸入正確日期');
								if (result) {
									alert(result);
								}
							}
						}
					},
					{ key: 'SAL_DT', header: '結算日'}
				]
        	} );
			// end of grid1
			
			//產生 grid2 物件
			grid2 = new TableUI( {
				table: $('grid2'),
				pageSize: 10,
				autoCheckBox:{isSelectAll: true},
				column:[
					{ key: 'LOAN_ID', header: '貸款帳號'},
					{ key: 'EXPENSE_NAME', header: '管理費用項目'},
					{ key: 'EFFECT_DATE', header: '發生日'},
					{ key: 'EXPENSE_AMT', header: '費用', sortRule:'number', attrs:{align : "right"},
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
				autoCheckBox:{isSelectAll: true},
				column:[
					{ key: 'LOAN_ID', header: '貸款帳號'},
					{ key: 'EXPENSE_NAME', header: '管理費用項目'},
					{ key: 'EFFECT_DATE', header: '發生日'},
					{ key: 'EXPENSE_AMT', header: '費用', sortRule:'number', attrs:{align : "right"},
						render:function(record,value){
							return CSRUtil.$fmt(value, '#,###');
						}
					}
				]
        	} );
			// end of grid3
						
			//-------------------------------------------------------------------------- 
			// 試算按鈕
			$('btn_calculate').observe('click',function(event){ 
				doAction.calculate(); 
			});
			// 上一頁按鈕
			$('btn_back').observe('click',function(event){
				CSRUtil.linkBack();
			});
			
			//還原 form1 的hidden值後，執行查詢
			if (!CSRUtil.isBackLink('form1')) {
				$('ACTION_TYPE').value = '${ACTION_TYPE}';
				$('SALE_DATE').value = '${SALE_DATE}';
				$('chkList').value = '${chkList}';
			}
			doAction.query();
			
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
				<div align="right">畫面編號：DSE10101</div>
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
											<input type="hidden" id="ACTION_TYPE" name="ACTION_TYPE" />
											<input type="hidden" id="SALE_DATE" name="SALE_DATE" />
											<input type="hidden" id="chkList" name="chkList" />
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
												<tr>
													<td class="tbYellow">法院陳報債權試算</td>
												</tr>
												<tr>
													<td class="tbYellow2" align="right" colspan="4">
														<input type="button" name="btn_calculate" id="btn_calculate" value="試算" class="button">
														<input type="button" name="btn_back" id="btn_back" value="上一頁" class="button">
													</td>
												</tr>
												<tr>
													<td class="tbYellow2">本金、利息、違約金</td>
												</tr>
											</table>
											<!-- Query Result (Grid Table) -->
											<table id="grid1" class="grid"></table>
											<div style="height:20px"><p>&nbsp;</p></div>
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table2">
												<tr>
													<td class="tbYellow2">管理費用 - 執行費用</td>
												</tr>
											</table>
											<table id="grid2" class="grid"></table>
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table3">
												<tr>
													<td class="tbYellow2">管理費用 -  取得執名費用</td>
												</tr>
											</table>
											<table id="grid3" class="grid"></table>
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