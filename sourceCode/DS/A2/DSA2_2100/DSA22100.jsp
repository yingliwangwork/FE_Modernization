<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA22100.jsp
作者：i9100607
功能：物價指數查詢作業
完成：2011/10/11
更新：

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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<%--自行定義的javaScript--%>
<script type="text/JavaScript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function initApp(){

	PageUI.createPage("DSA22100" , "核貸作業" , "物價指數查詢作業");
	PageUI.loadin(["tableA","grid"] , 1);
	
	cleanMsgBoard();

	buttonAuth();

	//TableUI的產生        
	new UI().init();    

	PageUI.resize(true);             
   
}

<%-- button控制 --%>
function buttonAuth(){
	var authButtons = {
	//	B0001:"btn_query",//查詢
		B0007:"btn_agree" ,//同意
		B0066:"btn_import"//匯入
	};
	<dz:grantButtons FUNC_ID="DSA22100" /> 	
}

function UI(){                
   
	var grid;        
	var BQ_ARG={};//查詢條件 	
	var validator = new Validator();
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA2_2100/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction();
		 		}
	        }}
		);
	}      
	
	function initTableUI(){
		grid = new TableUI( {
			table: $('grid'), pageSize: 12, 
			column:[	
				{ key: 'INDEX_STS_NM', header: '狀態'},
				{ key: 'YYMM', header: '年月'},
				{ key: 'INDEX', header: '物價指數(%)',attrs:{align:'right'},
					render:function(record,value){
						return CSRUtil.$fmt(value,'#,##0.000') ;
					}
				},
				<%--[20240729] 修改件 陳勁谷 難字修改 --%>
				{ key: 'INPUT_NAME', header: '作業人員', attrs: {style:"font-family:'EUDC'"}},
				{ key: 'INPUT_DATE', header: '作業時間'},
				<%--[20240729] 修改件 陳勁谷 難字修改 --%>
				{ key: 'APRV_NAME', header: '覆核人員', attrs: {style:"font-family:'EUDC'"}},
				{ key: 'APRV_DATE', header: '覆核時間'}
			]
       	} );	
	}
	
	//查詢
	function doQuery(isBackQuery){	
		
		if(!checkInput()){
			return;
		}
				
		//儲存目前查詢條件
		if(!isBackQuery){
			BQ_ARG = setBQ_ARG();
		}
	
		var params = { info:Object.toJSON(BQ_ARG) };
		var successAction = function(resp){
			grid.load(resp.rtnList);			
			btnAgreeSTS() ;
		};
		var errorAction = function(resp){
			grid.load([]);
			btnAgreeSTS() ;
		};
		ajaxPost( 'query', params, successAction, errorAction);	
	}
	
	//同意
	function doAgree(isBackQuery){	
	
		var params = { info:Object.toJSON(BQ_ARG) };
		var successAction = function(resp){
			grid.load(resp.rtnList || []);
			btnAgreeSTS() ;
		};
		ajaxPost( 'agree', params, successAction);
	}
	
	//超連結
	function doLink(){
		BQ_ARG.isBack = 'Y';
		var LP_JSON = {
			BQ_ARG:BQ_ARG,
			action:'${dispatcher}/DSA2_2101/prompt'
		};
		CSRUtil.linkTo(LP_JSON, 'form1');		
	}
	
	//儲存目前查詢值
	function setBQ_ARG(){
		var ARG={};
		ARG.INDEX_YYMMS = $F('INDEX_YYMMS');
		ARG.INDEX_YYMME = $F('INDEX_YYMME');
		ARG.INDEX_STS = $F('INDEX_STS');
		return ARG;
	}	
	
	function btnAgreeSTS(){
		if ( $F('INDEX_STS') == '10' && grid.getAllRecords().length !=0 ){
			$('btn_agree').enable() ;
		}else{
			$('btn_agree').disable() ;
		}
		
	}
	
	//--------------------------------------------------------------------------	
	//	檢核Function
	//--------------------------------------------------------------------------
	function checkInput() {
		validator.clear();
		validator = new Validator();
		validator.errHandler = new AlertHandler();
	
	
		var dateS = $F('INDEX_YYMMS') + '01' ;
		var dateE = $F('INDEX_YYMME') + '01' ;
		var isROCS = true ;
		var isROCE = true ;
		
		if ($F('INDEX_YYMMS') != '' && !isROCdate(dateS) ){
			validator.define('INDEX_YYMMS','物價指數年月(起)','必須輸入正確年月格式', 'STRING','-1','-1');
			isROCS = false ;
		}
		if ($F('INDEX_YYMME') != '' && !isROCdate(dateE)){
			validator.define('INDEX_YYMME','物價指數年月(迄)','必須輸入正確年月格式', 'STRING','-1','-1');
			isROCS = false ;
		}
		if (isROCS && isROCS && diffDay(dateS,dateE) <0){
			validator.define('INDEX_YYMME','物價指數年月(迄)','物價年月(起)需小於等於物價年月(迄)', 'STRING','-1','-1');
		}
		
		return validator.validate();
	}
      
	return{                              
              
		init:function(){                                        
			initTableUI();
			
			//查詢                    
			$('btn_query').observe('click',function(event){                                        
					doQuery(false);					
				}                        
			);
			
			//清除                  
			$('btn_clear').observe('click',function(event){                                        
					form1.reset();	
					grid.load([]) ;	
					btnAgreeSTS() ;									
				}                        
			);
			
			//匯入             
			$('btn_import').observe('click',function(event){                                        
					doLink() ;			
				}                        
			);
						
			//同意         
			$('btn_agree').observe('click',function(event){                                        
					doAgree() ;				
				}                        
			);
			$('btn_agree').disabled = true ;
			
			//狀態
			$('INDEX_STS').observe('change',function(event){                                        
					if ($F('INDEX_STS') == '10'){
						$('INDEX_YYMMS').value = '' ;
						$('INDEX_YYMME').value = '' ;						
						
						$('INDEX_YYMMS').disabled = true ;
						$('INDEX_YYMME').disabled = true ;
					}else{						
						$('INDEX_YYMMS').disabled = false ;
						$('INDEX_YYMME').disabled = false ;
					}				
				}                        
			);
			
		   var LP_JSON = CSRUtil.isBackLink('form1');

		   if(LP_JSON){
		   		BQ_ARG = LP_JSON.BQ_ARG;
				doQuery(true);		
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
						<td class="tbYellow" width="15%">物價指數年月</td>
						<td class="tbYellow2" width="25%">
							<input type="text" value="" class="textBox2" size="8" maxlength="5" name="INDEX_YYMMS" id="INDEX_YYMMS" disabled/>
							~
							<input type="text" value="" class="textBox2" size="8" maxlength="5" name="INDEX_YYMME" id="INDEX_YYMME" disabled/>
						</td>
						<td class="tbYellow" width="15%">狀態</td>
						<td class="tbYellow2" width="25%">
							<select class="textBox2" name="INDEX_STS" id="INDEX_STS">
								<c:forEach var="item" items="${STS_List}">
									<option value="${item.key}">${item.value}</option>
								</c:forEach>
							</select>
						</td>
						<td class="tbYellow" align="center"  width="20%">
							<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
						</td>
					</tr>
					<tr>
						<td align="center" colspan="5">
							<input id="btn_clear" name="btn_clear" type="button" class="button" value="清除">
							<input id="btn_import" name="btn_import" type="button" class="button" value="匯入">
							<input id="btn_agree" name="btn_agree" type="button" class="button" value="同意" >															
						</td>
					</tr>														
				</table>
				<table id="grid" class="grid"></table>	
			</form>


</body>
<!-- InstanceEnd -->
</html>
