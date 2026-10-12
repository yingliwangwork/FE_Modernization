<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA21600.jsp
作者：i9100621
功能：特殊案件統計
完成：2011/10/17

[20221229] 修改程式   楊青峰
新增本金彈性還還款方式

[20240729] 修改件 陳勁谷 難字修改
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<%--自行定義的javaScript--%>
<script type="text/JavaScript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var validator;
var pattern_0 = "#,###";	// 金額格式(無小數)
var pattern_2 = "#,###.##";	// 金額格式(小數2位)
function initApp(){

	PageUI.createPage("DSA21600" , "核貸作業" ,"特殊案件統計");
    PageUI.loadin(["tableA","grid","tableB"] ,1);

	cleanMsgBoard();
	displayMessage();

	//TableUI的產生        
	new UI().init();
	
	PageUI.resize(true);
}

function UI(){                

	var grid;        
	var BQ_ARG={};//查詢條件 	
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA2_1600/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
		 		PageUI.resize(true);
	        }}
		);
	}      
	
	var columnTableUI = 
		[	
			{ key: 'CRED_DEPT_NM', header: '承辦科別<br>' },//徵信科,徵信人員 輪流顯示
			{ key: 'ASSIGN_CNT', header: '件數<br>(合計)<br>',renderInCount:true,   
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},		
			{ key: 'CON_CNT', header: '換算件數<br>(合計)<br>', renderInCount:true,  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_2);
						}
					},		
			{ key: 'CNT_01', header: '清償<br>重估<br>', renderInCount:true,  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},		
			{ key: 'CNT_02', header: '變更<br>年期<br>', renderInCount:true,  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},		
			{ key: 'CNT_03', header: '部份<br>塗銷<br>', renderInCount:true,  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},		
			{ key: 'CNT_04', header: '開立<br>拋棄證明<br>',renderInCount:true,   
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},		
			{ key: 'CNT_05', header: '土地<br>徵收<br>', renderInCount:true,  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},		
			{ key: 'CNT_06', header: '火險<br>理賠<br>', renderInCount:true,  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},		
			{ key: 'CNT_07', header: '更換<br>保證人<br>', renderInCount:true,  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},		
			{ key: 'CNT_08', header: '理財型<br>動撥<br>', renderInCount:true,  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},		
			{ key: 'CNT_09', header: '理財型<br>變更<br>', renderInCount:true,  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},		
			{ key: 'CNT_99', header: '其他<br>', renderInCount:true,  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					},
			{ key: 'CNT_15', header: '本金彈性還<br>金額變更', renderInCount:true, <%-- [20221229] 新增本金彈性還還款方式 --%>
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_0);
						}
					}
		];
       	
    //初始tableUI   	
	function initTableUI(QUERY_TYPE , rtnList, sumMap){

		if(QUERY_TYPE == '1'){//顯示徵信人員欄位
			columnTableUI[0].key = 'CRED_NAME';
			columnTableUI[0].header = '承辦人員';
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			columnTableUI[0].attrs = {'style': "font-family:'EUDC'"};
			columnTableUI[0].render = function(record, value){
				if(value){
					var link = document.createElement('a');
					link.href = '#';
					link.innerHTML = value;
					link.onclick = function(){
						doLinkDSA2_1601(record.CRED_DEPT, record.CRED_ID);
					};
					value = link;								
				}
				return value;
			};
			
		}else if(QUERY_TYPE == '0'){//顯示徵信科欄位
			columnTableUI[0].key = 'CRED_DEPT_NM';
			columnTableUI[0].header = '承辦科別';
			columnTableUI[0].render = function(record, value){
				if(value){
					var link = document.createElement('a');
					link.href = '#';
					link.innerHTML = value;
					link.onclick = function(){
						reQueryByDept(record.CRED_DEPT);
					};
					value = link;								
				}
				return value;
			};			
		}
		
		grid = new TableUI( {
				table: $('grid'), allSortable: true,overDiv:false,
				column : columnTableUI
	       	} );

	    if(rtnList){
	    	var totObj = [{'text':'合計','textAlign':'center','value':sumMap.evalJSON()}];
	    	grid.load(rtnList.evalJSON(),totObj);
	    }	
	}
	
	//查詢
	function doQuery(isBackQuery , isNeedSelect){
	
		if(!checkInput()){
			return;
		}
	
		//儲存目前查詢條件
		if(!isBackQuery){
			BQ_ARG = setBQ_ARG();
		}
		
		var params = { info:Object.toJSON(BQ_ARG), isNeedSelect : isNeedSelect ? 'Y':'N'};
		
		//成功
		var successAction = function(resp){
			//if為連結回來,重產生[徵信人員]下拉清單
			if(resp.CRED_ID_LIST){
				createCRED_ID_Select(resp.CRED_ID_LIST);				
			}
			if(isBackQuery){
				$('CRED_ID').value = BQ_ARG.CRED_ID;
			}
			initTableUI(resp.QUERY_TYPE, resp.rtnList , resp.sumMap);
		};
		
		//失敗
		var errorAction = function(resp){
			initTableUI(resp.QUERY_TYPE ||'');
			//if為連結回來,重產生[徵信人員]下拉清單
			if(resp.CRED_ID_LIST){
				createCRED_ID_Select(resp.CRED_ID_LIST);				
			}
			if(isBackQuery){
				$('CRED_ID').value = BQ_ARG.CRED_ID;
			}
		};

		ajaxPost( 'query', params, successAction, errorAction);	
	}
	
	//	檢核Function
	function checkInput() {
		validator.clear();
		validator.errHandler = new AlertHandler();
		
		var isROCs = isROCdate($F('ASSIGN_DATES'));
		var isROCe = isROCdate($F('ASSIGN_DATEE'));
		if($F('ASSIGN_DATES') && !isROCs){
			validator.define('ASSIGN_DATES','派件期間(起)日','日期格式有誤', 'isROCdate');
		}
		
		if($F('ASSIGN_DATEE') && !isROCe){
			validator.define('ASSIGN_DATEE','派件期間(迄)日','日期格式有誤', 'isROCdate');
		}				

		if(isROCs && isROCe && diffDay($F('ASSIGN_DATES'),$F('ASSIGN_DATEE')) <0){
			validator.define('ASSIGN_DATEE','派件期間(迄)日','需大於等於派件期間(起)日', 'STRING','-1','-1');
		}

		return validator.validate();
	}	

	//[承辦科別]連動[徵信人員]
	function doGetCRED_IDMap(){
		$('CRED_ID').options.length = 1;
		var CRED_DEPT = $F('CRED_DEPT');
		if(!CRED_DEPT){
			return;
		}
		
		ajaxPost('getCRED_IDList',{'CRED_DEPT':CRED_DEPT}, 
			function(resp){
				createCRED_ID_Select(resp.CRED_ID_LIST);	
			}
		);
	}
	
	//建立[徵信人員]選單
	function createCRED_ID_Select(optList){
	 	for(var i=0; i<optList.length; i++) {
			var oOption = document.createElement("option");
			oOption.text = optList[i].CRED_NAME;
			oOption.value = optList[i].CRED_ID;
			$('CRED_ID').options.add(oOption);			
		}			
	}
	
	//徵信部門超連結
	function reQueryByDept(CRED_DEPT){
		$('CRED_DEPT').value  = CRED_DEPT;
		$('CRED_ID').options.length = 1;
		doQuery(false,true);
	
	}
	
	///徵信人員超連結
	function doLinkDSA2_1601(CRED_DEPT, CRED_ID){
		BQ_ARG.isBack = 'Y';
		var LP_JSON = {
			ASSIGN_DATES:BQ_ARG.ASSIGN_DATES,
			ASSIGN_DATEE:BQ_ARG.ASSIGN_DATEE,
			SPEC_PROCESS:BQ_ARG.SPEC_PROCESS,
			CRED_DEPT:CRED_DEPT,
			CRED_ID:CRED_ID,
			LINK_FROM:'DSA21601',
			BQ_ARG:BQ_ARG,
			action:'${dispatcher}/DSA2_1601/prompt'
		};
		CSRUtil.linkTo(LP_JSON, 'form1');		
	}
	
	//儲存目前查詢值
	function setBQ_ARG(){
		var ARG={};
		ARG.SPEC_PROCESS = $F('SPEC_PROCESS');
		ARG.CRED_DEPT = $F('CRED_DEPT');
		ARG.CRED_ID = $F('CRED_ID');
		
		if($F('ASSIGN_DATES')){
			ARG.ASSIGN_DATES = toY2K($F('ASSIGN_DATES'));
		}else{
			ARG.ASSIGN_DATES = '';			
		}

		if($F('ASSIGN_DATEE')){
			ARG.ASSIGN_DATEE = toY2K($F('ASSIGN_DATEE'));
		}else{
			ARG.ASSIGN_DATEE = '';			
		}
		return ARG;
	}
      
	return{                              
              
		init:function(){                                        
			initTableUI('${QUERY_TYPE}','${rtnList}','${sumMap}');
			validator = new Validator();     
			
			//查詢                    
			$('btn_query').observe('click',function(event){                                        
					doQuery(false,false);					
				}                        
			);
			
			//承辦科別]連動   
			$('CRED_DEPT').observe('change',function(event){                                        
					doGetCRED_IDMap();					
				}                        
			); 
			
		   var LP_JSON = CSRUtil.isBackLink('form1');

		   if(LP_JSON){
		   		$('ASSIGN_DATES').value  = Date.toInputROC($F('ASSIGN_DATES'));
		   		$('ASSIGN_DATEE').value  = Date.toInputROC($F('ASSIGN_DATEE'));
		   		BQ_ARG = LP_JSON.BQ_ARG;
				doQuery(true,true);
		   }
		}                 
	}
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >

								<form id="form1" name="form1" method="post">
									<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
										<tr>
											<td class="tbYellow" width="15%">派件期間</td>
											<td class="tbYellow2" width="30%">
												<input type="text" datatype="ROCDate" value="<cathay:calendar type="ROC" isInput="true" value="${ASSIGN_DATES}" />" class="textBox2" size="10" maxlength="7" name="ASSIGN_DATES" id="ASSIGN_DATES" />
												<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('ASSIGN_DATES'))">
												~
												<input type="text" datatype="ROCDate" value="<cathay:calendar type="ROC" isInput="true" value="${ASSIGN_DATEE}" />" class="textBox2" size="10" maxlength="7" name="ASSIGN_DATEE" id="ASSIGN_DATEE" />
												<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('ASSIGN_DATEE'))">
											</td>										
											<td class="tbYellow" width="15%">作業進度</td>
											<td class="tbYellow2" width="30%">
												<select class="textBox2" name="SPEC_PROCESS" id="SPEC_PROCESS">
					                              <option value="">全部</option>													
					                              <c:forEach var="map" items="${SPEC_PROCESS_List}">
					                                <option value="${map.key}">${map.value}</option>
					                              </c:forEach>
					                            </select>
											</td>
											<td class="tbYellow" rowspan="2" align="center" width="10%"><input id="btn_query" name="btn_query" type="button" class="button" value="查詢"></td>											
										</tr>
										<tr>										
											<td class="tbYellow">承辦科別</td>
											<td class="tbYellow2">
												<select class="textBox2" name="CRED_DEPT" id="CRED_DEPT">
					                              	<option value="">全部</option>											
					                              <c:forEach var="map" items="${CRED_DEPT_List}">
					                                <option value="${map.key}">${map.value}</option>
					                              </c:forEach>
					                            </select>
											</td>
											<td class="tbYellow">徵信/作業人員</td>
											<td class="tbYellow2">
												<%--[20240729] 修改件 陳勁谷 難字修改 --%>
												<select class="textBox2" name="CRED_ID" id="CRED_ID" alt="ch">
													<option value="">全部</option>
					                              <c:forEach var="map" items="${CRED_ID_LIST}">
					                                <option value="${map.CRED_ID}">${map.CRED_NAME}</option>
					                              </c:forEach>													
												</select>
											</td>
										</tr>
									</table>
								</form>
									<table id="grid" class="grid"></table>
									<br><p align=left id="tableB" style="background: #ffffff"><FONT SIZE=2 COLOR=#000066>〔註一〕件數換算標準：清償重估：0.3　　變更年期：0.3　　部份塗銷：0.4　　開立拋棄證明：0.1　　
									<br>　　　　　　　　　　　土地徵收：0.4　　火險理賠：0.2　　更換保證人：0.3　理財型動撥：0.1<br>　　　　　　　　　　　理財型變更：0.1　其它：0.2　　　　本金彈性還金額變更：0</FONT> <%-- [20221229] 新增文字 --%>
						
</body>
<!-- InstanceEnd -->
</html>
