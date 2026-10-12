<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA21601.jsp
作者：i9100621
功能：特殊案件統計明細
完成：2011/10/17
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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<%--自行定義的javaScript--%>
<script type="text/JavaScript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var validator;
var pattern_2 = "#,###.##";	// 金額格式(小數2位)
function initApp(){

	PageUI.createPage("DSA21601" , "核貸作業" ,"特殊案件統計明細");
    PageUI.loadin(["tableA","grid"] ,1);

	cleanMsgBoard();
	displayMessage();

	//TableUI的產生        
	new UI().init();   
	
	PageUI.resize(true);  
}

function UI(){                

	var grid;        
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA2_1601/" + actionName,
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
       	
    //初始tableUI   	
	function initTableUI(rtnList){
		
		grid = new TableUI( {
				table: $('grid'), pageSize: 10,
				column:[
					{ key: 'LOAN_ID', header: '貸款編號/受理編號'},
					{ key: 'BORROW_NAME', header: '借款人'},
					{ key: 'SPEC_KIND_NM', header: '案件類別'},
					{ key: 'SPEC_PROCESS_NM', header: '進度'},
					{ key: 'ASSIGN_DATE', header: '派件日期', 
						render: function(record, value) {
							return Date.toROC(value);
						}
					},			
					{ key: 'CONFIRM_DATE', header: '覆核/退件日期', 
						render: function(record, value) {
							var SPEC_PROCESS = record.SPEC_PROCESS;
							var dateValue = '';
							if('2' == SPEC_PROCESS){
								dateValue = record.CONFIRM_DATE;//覆核日期
								
							}else if('3' == SPEC_PROCESS){
								dateValue = record.REJECT_DATE;//退件日期
							}
							
							return Date.toROC(dateValue);
						}
					},
					{ key: 'CRED_NAME', header: '承辦人員'},
					{ key: 'CONFIRM_NAME', header: '覆核人員'},
					{ key: 'CONVERT_CNT', header: '換算件數',  
						render: function(record, value) {
							return CSRUtil.$fmt(value, pattern_2);
						}
					}		
				]
	       	} );

	    if(rtnList){
	    	grid.load(rtnList.evalJSON());
	    }	
	}
	
	//查詢
	function doQuery(){
	
		if(!checkInput()){
			return;
		}
	
		//儲存目前查詢條件

		var	BQ_ARG = setBQ_ARG();

		var params = { info:Object.toJSON(BQ_ARG)};
		
		//成功
		var successAction = function(resp){
			grid.load(resp.rtnList.evalJSON());
		};
		
		//失敗
		var errorAction = function(resp){
			grid.load([]);
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
			initTableUI('${rtnList}');
			validator = new Validator();     
			
			//查詢                    
			$('btn_query').observe('click',function(event){                                        
					doQuery();		
				}                        
			);
			
			//承辦科別]連動   
			$('CRED_DEPT').observe('change',function(event){                                        
					doGetCRED_IDMap();					
				}                        
			); 
			
			if('${LINK_FROM}'){
				$("btn_back").disabled  = false;
				//回上頁
				$("btn_back").observe('click',function(event){
						CSRUtil.linkBack();
				});	
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
					                                <option value="${map.key}" <c:if test="${map.key eq SPEC_PROCESS}">selected</c:if>>${map.value}</option>
					                              </c:forEach>
					                            </select>
											</td>
											<td class="tbYellow" rowspan="2" align="center" width="10%">
												<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
												<input id="btn_back" name="btn_back" type="button" class="button" value="回上頁" disabled>
											</td>											
											
										</tr>
										<tr>										
											<td class="tbYellow">承辦科別</td>
											<td class="tbYellow2">
												<select class="textBox2" name="CRED_DEPT" id="CRED_DEPT">
					                              	<option value="">全部</option>											
					                              <c:forEach var="map" items="${CRED_DEPT_List}">
					                                <option value="${map.key}"  <c:if test="${map.key eq CRED_DEPT}">selected</c:if>>${map.value}</option>
					                              </c:forEach>
					                            </select>
											</td>
											<td class="tbYellow">徵信/作業人員</td>
											<td class="tbYellow2">
												<select class="textBox2" name="CRED_ID" id="CRED_ID">
													<option value="">全部</option>
					                              <c:forEach var="map" items="${CRED_ID_LIST}">
					                                <option value="${map.CRED_ID}" <c:if test="${map.CRED_ID eq CRED_ID}">selected</c:if>>${map.CRED_NAME}</option>
					                              </c:forEach>													
												</select>
											</td>
										</tr>
									</table>
								</form>
									<table id="grid" class="grid"></table>
									
									
							
</body>
<!-- InstanceEnd -->
</html>
