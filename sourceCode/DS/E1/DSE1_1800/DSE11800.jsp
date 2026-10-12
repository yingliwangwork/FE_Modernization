<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSE11800.jsp
功能：拍賣不足債權試算
作者：黃子玹
完成：2013/08/23
修改：林秉宏

[20240215]難字調整
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javaScript" src="${htmlBase}/CM/js/utility.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/date.js"></script>			  <%-- 日期用 --%>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>

<%--[20240215]難字css  --%>
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



Event.observe(window, 'load', new DSE11800().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11800(){
	
	var valid1;
	var valid2;
    var grid;
	var grid1;
	var LOAN_ID = '${LOAN_ID}';
	var LINK_FROM = '${LINK_FROM}';
	var qryLOAN_ID = '';
	var INPUT_DATE1;	
	var isCalculate1 = true;
    var isCalculate2 = true;
	var FILE_ID;
	var qryEND_DATE = '';

	
	
   //按鈕授權
	function buttonAuth() {
		var authButtons = { 
			B0193 : 'btn_calculate1',
			B0194 : 'btn_calculate2',
			B0003 : 'btn_insert',
			B0004 : 'btn_update',		
			B0005 : 'btn_delete',
			B0070 : 'btn_confirm',
			B0071 : 'btn_cancel'			
		};
		<dz:grantButtons FUNC_ID ="DSE11800"/>
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_1800/" + actionName,
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
			}
		);
	}
	
	//畫面檢核	
	function initValidation(){	
			
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define( "required" , { id: "LOAN_ID",errMsg : '請輸入貸款帳號!'   } );
		valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		valid2.define( "required" , { id: "AVG_RATE",errMsg : '請輸入公司加權平均利率!'   } );	
		valid2.define( "required" , { id: "BEG_DATE2",errMsg : '請輸入拍定日!'   } );	
		valid2.define( "required" , { id: "REMAIN_AMT2",errMsg : '請輸入本金餘額!'   } );
		valid2.define( "required" , { id: "UNDIS_INT2",errMsg : '請輸入未受分配利息!'   } );
		valid2.define( "required" , { id: "UNDIS_RENEGE2",errMsg : '請輸入未受分配違約金!'   } );
		valid2.define( "required" , { id: "UNDIS_FEE2",errMsg : '請輸入未受分配程序費用!'   } );	
		
	}
	
	var actions ={
	
		//查詢
		doQuery : function(isPrompt){			
			/*
			valid2.reset();	
			if(!valid1.validate()){ 
				return; 
			}*/			
			if( isPrompt != 'isPrompt'){
				
				qryLOAN_ID = $F('LOAN_ID');
				if(LINK_FROM != 'DSE1_2100'){
					$('btn_close').hide();				
				}
						
			}else{				
				qryLOAN_ID = LOAN_ID;

				if(LINK_FROM == 'DSE1_2100'){
					$('btn_close').show();				
				}
						
			}
			qryEND_DATE=$F('END_DATE');	
			qryOFFSET_TYPE=$F('OFFSET_TYPE');	
			
			ajaxPost( 'query' , {LOAN_ID : qryLOAN_ID,  END_DATE : $F('END_DATE')},
				function(resp){	
					if(resp.INPUT_DATE1){
						isCalculate1 = false;
					}
					if(resp.INPUT_DATE2){
						isCalculate2 = false;
					}
					actions.doDisplay(resp.rtnMap,resp.rtnList1,resp.LastMap1 || {},resp.rtnList2,resp.LastMap2 || {});	
					var fileList = resp.fileList || [];					
					
					if(fileList){	
						$('FILE_ID').innerHTML = '';
						for( var i=0 ; i < fileList.length ; i++ ) {
							var file = fileList[i];
							var link = new Element( "a", {id:'link_'+i ,href: "#", FILE_ID: file.FILE_ID,align:'left'}).update(file.FILE_NM).observe('click',  actions.getDownLoadFile);
							$('FILE_ID').insert(link).insert('<br>');
										
						}
					}					
					INPUT_DATE1 = resp.INPUT_DATE1 || '';
                    qryEND_DATE=$F('END_DATE');
                    qryOFFSET_TYPE=$F('OFFSET_TYPE');	
			        qryBEG_DATE1=$F('BEG_DATE1');
					qryBEG_DATE2=$F('BEG_DATE2');
					qryREMAIN_AMT1=$F('REMAIN_AMT1');
					qryREMAIN_AMT2=$F('REMAIN_AMT2');
					qryYEAR_RATE=$F('YEAR_RATE');
					qryAVG_RATE=$F('AVG_RATE');
					qryUNDIS_INT1=$F('UNDIS_INT1');
					qryUNDIS_INT2=$F('UNDIS_INT2');
					qryUNDIS_RENEGE1=$F('UNDIS_RENEGE1');
					qryUNDIS_RENEGE2=$F('UNDIS_RENEGE2');
					qryUNDIS_FEE1=$F('UNDIS_FEE1');
					qryUNDIS_FEE2=$F('UNDIS_FEE2');	
					
				},
				function(resp){	
					form.reset();	
					actions.doDisplay('',[],{},[],{});
					var link = new Element('span', {'id':'FILE_ID'});
					$('FILE_ID').innerHTML = '';
					$('LOAN_ID').value = qryLOAN_ID;
					qryEND_DATE=$F('END_DATE');
					qryOFFSET_TYPE=$F('OFFSET_TYPE');	
					qryBEG_DATE1=$F('BEG_DATE1');
					qryBEG_DATE2=$F('BEG_DATE2');
					qryREMAIN_AMT1=$F('REMAIN_AMT1');
					qryREMAIN_AMT2=$F('REMAIN_AMT2');
					qryYEAR_RATE=$F('YEAR_RATE');
					qryAVG_RATE=$F('AVG_RATE');
					qryUNDIS_INT1=$F('UNDIS_INT1');
					qryUNDIS_INT2=$F('UNDIS_INT2');
					qryUNDIS_RENEGE1=$F('UNDIS_RENEGE1');
					qryUNDIS_RENEGE2=$F('UNDIS_RENEGE2');
					qryUNDIS_FEE1=$F('UNDIS_FEE1');
					qryUNDIS_FEE2=$F('UNDIS_FEE2');	
				}
			);
		}
		,doDisplay : function(rtnMap, rtnList1, LastMap1, rtnList2, LastMap2){
			
			<%--難字寫入資料--%>
			$("BORROW_NAME_IN").setValue(rtnMap.BORROW_NAME);
			
			var LastObj1 = [ 
			{text:'', textAlign : 'center', value:{REM_RENEGE: '債權合計:' ,REM_FEE: '<div align="right">'+gridFmtRender(LastMap1.REM_FEE)+'</div>'}},			
			{text:'', textAlign : 'center', value:{BEG_DATE: '試算人員:', REAL_PAYDT: LastMap1.REAL_PAYDT ||'',  
			INT_RATE: '試算日期:', CUR_INT: (LastMap1.CUR_RENEGE ? Date.toInputROC( LastMap1.CUR_RENEGE ,"/") : ''), 
			CUR_RENEGE: '覆核人員:', CUR_FEE: LastMap1.REAL_PAYMT,
			REM_AMT: '覆核日期:', REM_INT: (LastMap1.REM_INT ? Date.toInputROC( LastMap1.REM_INT ,"/") : '')
			}}];			
			grid.load(rtnList1 || [],LastObj1);	
						
			var LastObj2 = [ 
			{text:'', textAlign : 'center', value:{REM_RENEGE: '債權合計:' ,REM_FEE: '<div align="right">'+gridFmtRender(LastMap2.REM_FEE)+'</div>'}},	
			{text:'', textAlign : 'center', value:{BEG_DATE: '試算人員:', REAL_PAYDT: LastMap2.REAL_PAYDT || '',  
			INT_RATE: '試算日期:', CUR_INT: (LastMap2.CUR_RENEGE ? Date.toInputROC( LastMap2.CUR_RENEGE ,"/") : ''), 
			CUR_RENEGE: '覆核人員:', CUR_FEE: LastMap2.REAL_PAYMT,
			REM_AMT: '覆核日期:', REM_INT: (LastMap2.REM_INT ? Date.toInputROC( LastMap2.REM_INT ,"/") : '')
			}}];			
			
			grid1.load(rtnList2 || [],LastObj2); 
			if(rtnMap){	
				$('table_A').select('input[type="text"]', 'input[type="hidden"]', 'span','select').each(function(elem){
						
					var tagName = elem.tagName;
					var oID = elem.id;
					var v = rtnMap[elem.id];
					
					if(Object.isUndefined(v)) return;
					if(tagName == 'INPUT'||tagName=='SELECT'){
						var oDatatype = elem.getAttribute('datatype');
						if('OFFSET_TYPE'==oID){
							elem.value=v;
						}if('number'==oDatatype){
							elem.setValue(v || '0');
						}else{
							elem.setValue(v || '');	
						}		
					}else{										
						elem.update(v || '');	
					}
		
				});	
			}else{
				$('table_A').select('input[type="text"]', 'input[type="hidden"]', 'span').each(function(elem){
					
					var tagName = elem.tagName;
					var oID = elem.id;
					if(tagName == 'INPUT' || tagName == 'SELECT'){				
						elem.setValue('');		
					}else{				
						elem.update('');
					}		
				});	
			}	
		}
		,storedataMap: function(){
		
			var dataMap = {};			
			$$('#table_A input[type =text]','#table_A input[type="hidden"]','#table_A span', '#table_A select').each(
				function (elem){
					var tagName = elem.tagName;
					var oID = elem.id;
					if(tagName == 'INPUT' || tagName == 'SELECT'){	
						dataMap[oID] =  $F(oID);
					}else{
						if(oID == 'FILE_ID'){return;}
						dataMap[oID] = elem.innerHTML || '';						
					}						
				}
			)
			
			<%--難字輸入置換--%>
			dataMap.BORROW_NAME = $("BORROW_NAME_IN").getValue();
			return dataMap;		
		}
		,doCalculate1 : function(){
		
			//請先查詢再做試算					
			if('' == qryLOAN_ID){
				alert('請先查詢再做試算!!');
				return;				
			}	
		
			//區塊A貸款帳號(LOAN_ID)必須與貸款帳號(LOAN_ID_H)相同，否則顯示錯誤訊息 “貸款帳號已更改，請重新查詢!!”						
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號已更改，請重新查詢!!');
				return;				
			}	
			//區塊A結算日必須等於上一次查詢條件之結算日，否則顯示錯誤訊息 “結算日已更改，請重新查詢!!”
			if($F('END_DATE') != qryEND_DATE){
				alert('結算日已更改，請重新查詢!!');
				return;
			}
			
			
			var reqMap = actions.storedataMap();		
			var List1 = grid.getAllRecords();
			
			//List1無資料是否作試算處理?
			/*
			if(!List1){
				alert('');
			}*/
			
			ajaxPost( 'calculate1' , {List1 : Object.toJSON(List1), reqMap : Object.toJSON(reqMap), LOAN_ID : $F('LOAN_ID')},
				function(resp){
					isCalculate1 = false;
					var LastMap1 = resp.LastMap1 || {};
					var LastObj1 = [ 
					{text:'', textAlign : 'center', value:{REM_RENEGE: '債權合計:' ,REM_FEE: '<div align="right">'+gridFmtRender(LastMap1.REM_FEE)+'</div>'}},			
					{text:'', textAlign : 'center', value:{INT_STR_DT: '試算人員:', REAL_PAYDT: LastMap1.REAL_PAYDT ||'',  
					INT_RATE: '試算日期:', CUR_INT: (LastMap1.CUR_RENEGE ? Date.toInputROC( LastMap1.CUR_RENEGE ,"/") : ''), 
					CUR_RENEGE: '覆核人員:', CUR_FEE: LastMap1.REAL_PAYMT,
					REM_AMT: '覆核日期:', REM_INT: (LastMap1.REM_INT ? Date.toInputROC( LastMap1.REM_INT ,"/") : '')}}];		
			
					grid.load(resp.rtnList1 || [], LastObj1);	
					qryBEG_DATE1=$F('BEG_DATE1');
					qryBEG_DATE2=$F('BEG_DATE2');
					qryREMAIN_AMT1=$F('REMAIN_AMT1');
					qryREMAIN_AMT2=$F('REMAIN_AMT2');
					qryYEAR_RATE=$F('YEAR_RATE');
					qryAVG_RATE=$F('AVG_RATE');
					qryUNDIS_INT1=$F('UNDIS_INT1');
					qryUNDIS_INT2=$F('UNDIS_INT2');
					qryUNDIS_RENEGE1=$F('UNDIS_RENEGE1');
					qryUNDIS_RENEGE2=$F('UNDIS_RENEGE2');
					qryUNDIS_FEE1=$F('UNDIS_FEE1');
					qryUNDIS_FEE2=$F('UNDIS_FEE2');	
				}
							
			);	
	
		}
		,doCalculate2 : function(){
					
			//請先查詢再做試算					
			if('' == qryLOAN_ID){
				alert('請先查詢再試算!!');
				return;				
			}	
			
			valid1.reset();			
			//區塊A貸款帳號(LOAN_ID)必須與貸款帳號(LOAN_ID_H)相同，否則顯示錯誤訊息 “貸款帳號已更改，請重新查詢!!”						
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號已更改，請重新查詢!!');
				return;
			}
			//區塊A結算日必須等於上一次查詢條件之結算日，否則顯示錯誤訊息 “結算日已更改，請重新查詢!!”
			if($F('END_DATE') != qryEND_DATE){
				alert('結算日已更改，請重新查詢!!');
				return;
			}
			
			
			//公司加權平均利率為必要欄位。
			
			if(!valid2.validate()){ 
				return; 
			}	
			var reqMap = actions.storedataMap();			
			var List2 = grid1.getAllRecords();
			
			//List2無資料是否作試算處理?
			/*
			if(!List2){
				alert('');
			}*/
			ajaxPost( 'calculate2' , {List2 : Object.toJSON(List2), reqMap : Object.toJSON(reqMap), LOAN_ID : $F('LOAN_ID')},
				function(resp){
					isCalculate2 = false;
					var LastMap2 = resp.LastMap2 || {};
					var LastObj2 = [ 
					{text:'', textAlign : 'center', value:{REM_RENEGE: '債權合計:' ,REM_FEE: '<div align="right">'+gridFmtRender(LastMap2.REM_FEE)+'</div>'}},
					{text:'', textAlign : 'center', value:{INT_STR_DT: '試算人員:', REAL_PAYDT: LastMap2.REAL_PAYDT || '',  
					INT_RATE: '試算日期:', CUR_INT: (LastMap2.CUR_RENEGE ? Date.toInputROC( LastMap2.CUR_RENEGE ,"/") : ''), 
					CUR_RENEGE: '覆核人員:', CUR_FEE: LastMap2.REAL_PAYMT,
					REM_AMT: '覆核日期:', REM_INT: (LastMap2.REM_INT ? Date.toInputROC( LastMap2.REM_INT ,"/") : '')}}];		
					
					grid1.load(resp.rtnList2 || [], LastObj2);	
					qryBEG_DATE1=$F('BEG_DATE1');
					qryBEG_DATE2=$F('BEG_DATE2');
					qryREMAIN_AMT1=$F('REMAIN_AMT1');
					qryREMAIN_AMT2=$F('REMAIN_AMT2');
					qryYEAR_RATE=$F('YEAR_RATE');
					qryAVG_RATE=$F('AVG_RATE');
					qryUNDIS_INT1=$F('UNDIS_INT1');
					qryUNDIS_INT2=$F('UNDIS_INT2');
					qryUNDIS_RENEGE1=$F('UNDIS_RENEGE1');
					qryUNDIS_RENEGE2=$F('UNDIS_RENEGE2');
					qryUNDIS_FEE1=$F('UNDIS_FEE1');
					qryUNDIS_FEE2=$F('UNDIS_FEE2');												
				}						
			);	
	
		}
		,doInsert : function(){	
		
			//區塊A貸款帳號(LOAN_ID)必須與貸款帳號(LOAN_ID_H)相同，否則顯示錯誤訊息 “貸款帳號已更改，請重新查詢!!”
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號已更改，請重新查詢!!');
				return;
			}	
		    //區塊A結算日必須等於上一次查詢條件之結算日，否則顯示錯誤訊息 “結算日已更改，請重新查詢!!”
			if($F('END_DATE') != qryEND_DATE){
				alert('結算日已更改，請重新查詢!!');
				return;
			}	
			if($F('OFFSET_TYPE') != qryOFFSET_TYPE){
				alert('抵充順序已更改，請重新查詢!!');
				return;
			}
			if($F('BEG_DATE1') != qryBEG_DATE1 || $F('BEG_DATE2') != qryBEG_DATE2){
				alert('拍定日已更改，請重新試算!!');
				return;
			}	
			if($F('REMAIN_AMT1') != qryREMAIN_AMT1 || $F('REMAIN_AMT2') != qryREMAIN_AMT2){
				alert('本金餘額已更改，請重新試算!!');
				return;
			}	
			if($F('YEAR_RATE') != qryYEAR_RATE || $F('AVG_RATE') != qryAVG_RATE){
				alert('利率已更改，請重新試算!!');
				return;
			}	
			if($F('UNDIS_INT1') != qryUNDIS_INT1 || $F('UNDIS_INT2') != qryUNDIS_INT2){
				alert('未受分配利息已更改，請重新試算!!');
				return;
			}
			if($F('UNDIS_RENEGE1') != qryUNDIS_RENEGE1 || $F('UNDIS_RENEGE2') != qryUNDIS_RENEGE2){
				alert('未受分配違約金已更改，請重新試算!!');
				return;
			}
			if($F('UNDIS_FEE1') != qryUNDIS_FEE1 || $F('UNDIS_FEE2') != qryUNDIS_FEE2){
				alert('未受分配程序費用已更改，請重新試算!!');
				return;
			}		
			
			
			
			if(!$('check1').checked && !$('check2').checked){
				alert('請勾選要新增的資料!');
				return;
			}
			
			//須先執行過債權試算或協議清償債權試算，否則顯示錯誤訊息 “請先試算再新增!!”
			if(($('check1').checked && isCalculate1) || ($('check2').checked && isCalculate2)) {
				alert('請先試算再新增!!');
				return;	
			}

			var reqMap = actions.storedataMap();		
			var List1 = grid.getAllRecords();
			var List2 = grid1.getAllRecords();	
		
			var IS_LIST1 = $('check1').checked ? '1' : '0';
			var IS_LIST2 = $('check2').checked ? '1' : '0'; 
		
			ajaxPost( 'insert' , {LOAN_ID : qryLOAN_ID, IS_LIST1 : IS_LIST1, IS_LIST2 : IS_LIST2, List1 : Object.toJSON(List1), List2 : Object.toJSON(List2), reqMap : Object.toJSON(reqMap)},
				function(resp){						
					actions.doDisplay(resp.rtnMap,resp.rtnList1,resp.LastMap1 || {},resp.rtnList2,resp.LastMap2 || {});						
				}					
			);	
		}
		,doUpdate : function(){	
		
			//區塊A貸款帳號(LOAN_ID)必須與貸款帳號(LOAN_ID_H)相同，否則顯示錯誤訊息 “貸款帳號已更改，請重新查詢!!”
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號已更改，請重新查詢!!');
				return;
			}	
			//區塊A結算日必須等於上一次查詢條件之結算日，否則顯示錯誤訊息 “結算日已更改，請重新查詢!!”
			if($F('END_DATE') != qryEND_DATE){
				alert('結算日已更改，請重新查詢!!');
				return;
			}	
			if($F('OFFSET_TYPE') != qryOFFSET_TYPE){
				alert('抵充順序已更改，請重新查詢!!');
				return;
			}
			if($F('BEG_DATE1') != qryBEG_DATE1 || $F('BEG_DATE2') != qryBEG_DATE2){
				alert('拍定日已更改，請重新試算!!');
				return;
			}	
			if($F('REMAIN_AMT1') != qryREMAIN_AMT1 || $F('REMAIN_AMT2') != qryREMAIN_AMT2){
				alert('本金餘額已更改，請重新試算!!');
				return;
			}	
			if($F('YEAR_RATE') != qryYEAR_RATE || $F('AVG_RATE') != qryAVG_RATE){
				alert('利率已更改，請重新試算!!');
				return;
			}	
			if($F('UNDIS_INT1') != qryUNDIS_INT1 || $F('UNDIS_INT2') != qryUNDIS_INT2){
				alert('未受分配利息已更改，請重新試算!!');
				return;
			}
			if($F('UNDIS_RENEGE1') != qryUNDIS_RENEGE1 || $F('UNDIS_RENEGE2') != qryUNDIS_RENEGE2){
				alert('未受分配違約金已更改，請重新試算!!');
				return;
			}
			if($F('UNDIS_FEE1') != qryUNDIS_FEE1 || $F('UNDIS_FEE2') != qryUNDIS_FEE2){
				alert('未受分配程序費用已更改，請重新試算!!');
				return;
			}	
								
			if(!$('check1').checked && !$('check2').checked){
				alert('請勾選要修改的資料!');
				return;
			}
			
			//須先執行過債權試算或協議清償債權試算，否則顯示錯誤訊息 “請先試算再修改!!”
			if(($('check1').checked && isCalculate1) || ($('check2').checked && isCalculate2)) {
				alert('請先試算再修改!!');
				return;	
			}
			
			var reqMap = actions.storedataMap();		
			var List1 = grid.getAllRecords();
			var List2 = grid1.getAllRecords();
	
			var IS_LIST1 = $('check1').checked ? '1' : '0';
			var IS_LIST2 = $('check2').checked ? '1' : '0'; 
		
			ajaxPost( 'update' , {LOAN_ID : qryLOAN_ID, IS_LIST1 : IS_LIST1, IS_LIST2 : IS_LIST2,List1 : Object.toJSON(List1), List2 : Object.toJSON(List2), reqMap : Object.toJSON(reqMap)},
				function(resp){
					actions.doDisplay(resp.rtnMap,resp.rtnList1,resp.LastMap1 || {},resp.rtnList2,resp.LastMap2 || {});	
				
				}			
			);	
		}
		,doDelete : function(){	
		
			//區塊A貸款帳號(LOAN_ID)必須與貸款帳號(LOAN_ID_H)相同，否則顯示錯誤訊息 “貸款帳號已更改，請重新查詢!!”
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號已更改，請重新查詢!!');
				return;
			}
			
			if(!$('check1').checked && !$('check2').checked){
				alert('請勾選要刪除的資料!');
				return;
			}

			var reqMap = actions.storedataMap();		
			var List1 = grid.getAllRecords();
			var List2 = grid1.getAllRecords();
	
			var IS_LIST1 = $('check1').checked ? '1' : '0';
			var IS_LIST2 = $('check2').checked ? '1' : '0'; 
		
			ajaxPost( 'delete' , {LOAN_ID : qryLOAN_ID, IS_LIST1 : IS_LIST1, IS_LIST2 : IS_LIST2, List1 : Object.toJSON(List1), List2 : Object.toJSON(List2), reqMap : Object.toJSON(reqMap)},
				function(resp){
					actions.doDisplay(resp.rtnMap,resp.rtnList1,resp.LastMap1 || {},resp.rtnList2,resp.LastMap2 || {});	
					if (IS_LIST1 = '1') {
						isCalculate1 = true;
					}
					if (IS_LIST2 = '1') {
						isCalculate2 = true;
					}
				}			
			);	
		}
		,doConfirm : function(){
			
			//區塊A貸款帳號(LOAN_ID)必須與貸款帳號(LOAN_ID_H)相同，否則顯示錯誤訊息 “貸款帳號已更改，請重新查詢!!”
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號已更改，請重新查詢!!');
				return;
			}
			
			if(!$('check1').checked && !$('check2').checked){
				alert('請勾選要覆核的資料!');
				return;
			}

			var reqMap = actions.storedataMap();		
			var List1 = grid.getAllRecords();
			var List2 = grid1.getAllRecords();
	
			var IS_LIST1 = $('check1').checked ? '1' : '0';
			var IS_LIST2 = $('check2').checked ? '1' : '0'; 
		
			ajaxPost( 'confirm' , {LOAN_ID : qryLOAN_ID, IS_LIST1 : IS_LIST1, IS_LIST2 : IS_LIST2,List1 : Object.toJSON(List1), List2 : Object.toJSON(List2), reqMap : Object.toJSON(reqMap)},
				function(resp){
					actions.doDisplay(resp.rtnMap,resp.rtnList1,resp.LastMap1 || {},resp.rtnList2,resp.LastMap2 || {});						
				}			
			);		
		}
		,doCancelconfirm : function(){
			
			//區塊A貸款帳號(LOAN_ID)必須與貸款帳號(LOAN_ID_H)相同，否則顯示錯誤訊息 “貸款帳號已更改，請重新查詢!!”
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號已更改，請重新查詢!!');
				return;
			}
			
			if(!$('check1').checked && !$('check2').checked){
				alert('請勾選要覆核的資料!');
				return;
			}

			var reqMap = actions.storedataMap();		
			var List1 = grid.getAllRecords();
			var List2 = grid1.getAllRecords();
	
			var IS_LIST1 = $('check1').checked ? '1' : '0';
			var IS_LIST2 = $('check2').checked ? '1' : '0'; 
		
			ajaxPost( 'cancelconfirm' , {LOAN_ID : qryLOAN_ID, IS_LIST1 : IS_LIST1, IS_LIST2 : IS_LIST2, List1 : Object.toJSON(List1), List2 : Object.toJSON(List2), reqMap : Object.toJSON(reqMap)},
				function(resp){
					actions.doDisplay(resp.rtnMap,resp.rtnList1,resp.LastMap1 || {},resp.rtnList2,resp.LastMap2 || {});					
				}			
			);		
		}
		,doPrint : function(event){

			//區塊A貸款帳號(LOAN_ID)必須與貸款帳號(LOAN_ID_H)相同，否則顯示錯誤訊息 “貸款帳號已更改，請重新查詢!!”			
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號已更改，請重新查詢!!');
				return;
			}		
			
			if(!$('check1').checked && !$('check2').checked){
				alert('請勾選要列印的資料!');
				return;
			}
			
			var reqMap = actions.storedataMap();		
			var List1 = grid.getAllRecords();
			var List2 = grid1.getAllRecords();
			var IS_LIST1 = $('check1').checked ? '1' : '0';
			var IS_LIST2 = $('check2').checked ? '1' : '0'; 
			
			RPTUtil.executePrintByLink('print' , {IS_LIST1 : IS_LIST1, IS_LIST2 : IS_LIST2, LOAN_ID : qryLOAN_ID, reqMap : Object.toJSON(reqMap)}, true );		
		}
		,doPrint2 : function(event){

			//區塊A貸款帳號(LOAN_ID)必須與貸款帳號(LOAN_ID_H)相同，否則顯示錯誤訊息 “貸款帳號已更改，請重新查詢!!”			
			if($F('LOAN_ID') != qryLOAN_ID){
				alert('貸款帳號已更改，請重新查詢!!');
				return;
			}		
			
			if(!$('check1').checked && !$('check2').checked){
				alert('請勾選要列印的資料!');
				return;
			}
			
			var reqMap = actions.storedataMap();		
			var List1 = grid.getAllRecords();
			var List2 = grid1.getAllRecords();
			var IS_LIST1 = $('check1').checked ? '1' : '0';
			var IS_LIST2 = $('check2').checked ? '1' : '0'; 
			
			RPTUtil.executePrintByLink('print2' , {IS_LIST1 : IS_LIST1, IS_LIST2 : IS_LIST2, LOAN_ID : qryLOAN_ID, reqMap : Object.toJSON(reqMap)}, true );		
		}
		
		//下載檔案
		,getDownLoadFile : function(event)  {			
			RPTUtil.downloadFile( '<%=dispatcher%>/DSE1_1800/downFile', {'FILE_ID':this.FILE_ID});						
		},
		//連回上一頁
		doBack: function(event){
			if(window.isPopupWin && window.popupWinBack){
			   // 呼叫callback Function(若有) 並關閉
			   window.popupWinBack(); 
			}else if(window.parent && window.parent.popupWin){
				//呼叫callback Function(若有) 並關閉
			   window.parent.popupWin.back();
			}else{
				CSRUtil.linkBack();  
			}

		},
		//影像檔
		doLink: function(event){
			popupWin.popup({									
				src : '<%=dispatcher%>/DSF0_0210/prompt' ,		
				scrolling : 'yes',	
				parameters : { 
					'LOAN_ID' : $F('LOAN_ID')	
				}  			
			});	
		}
    }
    
    // 金額格式化
	var gridFmtRender = function(value) { 
		return value || value === 0 ? CSRUtil.$fmt(value, '#,##0', 1) : ''; 
	};

	return{
	
		initApp : function(){

        	<cathay:LocaleDisplay dateFields="END_DATE BEG_DATE1 BEG_DATE2" sysCode= 'DS' var='localeDisplay' />
			PageUI.createPageWithAllBodySubElement('DSE11800','法務作業','拍賣不足債權試算',1);
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: false, overDiv: false, split: ['BEG_DATE'],
				column: [				   	
					{header:"當期債權", attrs:{ colSpan:6 }, empty:'rowSpan_down'},	
					{header:"實繳金額", key:'REAL_PAYMT', attrs:{align:'right', rowSpan:2}, sortRule : 'number'},	
					{header:"剩餘債權", attrs:{ colSpan:12 }, empty:'rowSpan_down'},
					{header:"起算日", key:'BEG_DATE', 
						render : function(rec , val){					
						    return val ? Date.toInputROC( val ,"/") : '';
						}	
					},		
					{header:"實繳日期", key:'REAL_PAYDT', 
						render : function(rec , val){					
						    return val ? Date.toInputROC( val ,"/") : '';
						}	
					},		
					{header:"利率", key:'INT_RATE', sortRule : 'number'},
					{header:"利息", key:'CUR_INT', sortRule : 'number'},
					{header:"違約金", key:'CUR_RENEGE', sortRule : 'number'},
					{header:"管理費", key:'CUR_FEE', sortRule : 'number'},
					{header:"本金", key:'REM_AMT', sortRule : 'number'},
					{header:"利息", key:'REM_INT', sortRule : 'number'},
					{header:"違約金", key:'REM_RENEGE', sortRule : 'number'},
					{header:"管理費", key:'REM_FEE', sortRule : 'number'},
					{header:"未受分配利息", key:'UNDIS_INT', sortRule : 'number'},
					{header:"未受分配違約金", key:'UNDIS_RENEGE', sortRule : 'number'},		
					{header:"計息起日", key:'INT_STR_DT', sortRule : 'date'},
					{header:"計息終日", key:'INT_END_DT', sortRule : 'date'},
					{header:"利息暫收款", key:'BALC_AMT', sortRule : 'number'},
					{header:"違約金起日", key:'REN_STR_DT', sortRule : 'date'},
					{header:"違約金迄日", key:'REN_END_DT', sortRule : 'date'},
					{header:"違約金暫收款", key:'SUM_RENEGE', sortRule : 'number'}
				]	
			});
	
			
			grid1 = new TableUI({
				table: $('grid1'), pageSize: 20, allSortable: false,overDiv:false, split: ['BEG_DATE'],             
				column: [
					{header:"當期債權", attrs:{ colSpan:6 }, empty:'rowSpan_down'},	
					{header:"實繳金額", key:'REAL_PAYMT', attrs:{align:'right', rowSpan:2}, sortRule : 'number'},	
					{header:"剩餘債權", attrs:{ colSpan:12 }, empty:'rowSpan_down'},
					{header:"起算日", key:'BEG_DATE', 
						render : function(rec , val){					
						    return val ? Date.toInputROC( val ,"/") : '';
						}	
					},								
					{header:"實繳日期", key:'REAL_PAYDT', 
						render : function(rec , val){					
						    return val ? Date.toInputROC( val ,"/") : '';
						}	
					},		
					{header:"利率", key:'INT_RATE', sortRule : 'number'},
					{header:"利息", key:'CUR_INT', sortRule : 'number'},
					{header:"違約金", key:'CUR_RENEGE', sortRule : 'number'},
					{header:"管理費", key:'CUR_FEE', sortRule : 'number'},
					{header:"本金", key:'REM_AMT', sortRule : 'number'},
					{header:"利息", key:'REM_INT', sortRule : 'number'},
					{header:"違約金", key:'REM_RENEGE', sortRule : 'number'},										
					{header:"管理費", key:'REM_FEE', sortRule : 'number'},
					{header:"未受分配利息", key:'UNDIS_INT', sortRule : 'number'},
					{header:"未受分配違約金", key:'UNDIS_RENEGE', sortRule : 'number'},		
					{header:"計息起日", key:'INT_STR_DT', sortRule : 'date'},
					{header:"計息終日", key:'INT_END_DT', sortRule : 'date'},
					{header:"利息暫收款", key:'BALC_AMT', sortRule : 'number'},
					{header:"違約金起日", key:'REN_STR_DT', sortRule : 'date'},
					{header:"違約金迄日", key:'REN_END_DT', sortRule : 'date'},
					{header:"違約金暫收款", key:'SUM_RENEGE', sortRule : 'number'}			
				]	
			});
			
			//按鈕事件監聽
			$('btn_query').observe('click', actions.doQuery);
			$('btn_calculate1').observe('click', actions.doCalculate1);//債權試算
			$('btn_calculate2').observe('click', actions.doCalculate2);//協議清償債權試算
			
			$('btn_insert').observe('click', actions.doInsert);//新增
			$('btn_update').observe('click', actions.doUpdate);//異動
			$('btn_delete').observe('click', actions.doDelete);//刪除
			$('btn_confirm').observe('click', actions.doConfirm); //覆核			
			$('btn_cancel').observe('click', actions.doCancelconfirm);//取消覆核
			$('btn_print').observe('click', actions.doPrint); //列印	
			$('btn_print2').observe('click', actions.doPrint2); //列印(簡)	
			$('btn_close').observe('click', actions.doBack); //回上一頁
			$('btn_link').observe('click', actions.doLink);//影像檔
			
			initValidation();
			buttonAuth();		
			autoFormatToNumber();		
			PageUI.resize();			
			displayMessage();	
			
			$('btn_close').hide();//初始隱藏關閉按鈕	
			if(LOAN_ID != ''){
				actions.doQuery('isPrompt');
			}

				
		}//end init()--
	};//end return--	
}//end DSE11800
</script>
</head>
<body>
<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">貸款帳號</td>		
			<td class="tbYellow2" width="10%" >
				<input id="LOAN_ID" type='text' class= 'textBox2'  size='12' maxlength='10' fieldName="貸款帳號" onblur="this.value = this.value.toUpperCase()" value="${LOAN_ID}"/>			
			</td>			
			<td class="tbYellow2" width="40%" align="left" colSpan='4'>
				<input id = "btn_query" type = "button" class = "button" value = "查詢" />
				<input id = "btn_link" type = "button" class = "button" value = "影像檔 " />			
			</td>			
		</tr>
		<tr>
			<td class="tbYellow">結算日</td>
			<td class="tbYellow2">
				<input id="END_DATE" datatype ="ROCDate" type='text' class= "textBox2" size='12' maxlength='7' fieldName="結算日" /> 
				<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('END_DATE'))" />
			</td>
			<td class="tbYellow">借款人</td>
			<td class="tbYellow2" colSpan='3'>
				<span id="BORROW_NAME" style="font-family:'EUDC'"></span><%--[20240215]難字調整 --%>
				<%--避免難字造成的XSS ATACK--%>
				<input id="BORROW_NAME_IN" type='hidden' class= 'textBox2' alt="ch"/>
			</td>	
		</tr>
		<tr>
			<td class="tbYellow">抵充順序</td>		
			<td class="tbYellow2" align="left">
				<select id="OFFSET_TYPE" fieldName = "抵充順序">		
					<c:forEach var="map" items="${OFFSET_TYPE_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>			
			</td>
			<td class="tbYellow">債權憑證影像檔</td>
			<td class="tbYellow2" colSpan='3'>	
				<span id="FILE_ID"></span>
			</td>
		</tr>
		<tr>
			<td class="tbBox3" align="center" colspan="6">
				拍賣不足債權試算
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%">案件種類</td>		
			<td class="tbYellow2" width="10%">
				<input id="CASE_KIND1" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "案件種類"/>
				<span id="CASE_KIND_NAME1"></span>
			</td>
			<td class="tbYellow" width="10%">抵充順序</td>		
			<td class="tbYellow2" width="10%"  colSpan='3'>
				<span id="OFFSET_TYPE1_NM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">拍定日</td>
			<td class="tbYellow2">
				<input id="BEG_DATE1" type='text' datatype ="ROCDate" class= 'textBox2' size='12' maxlength='7' fieldName="結算日"/> 
				<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('BEG_DATE1'))" />
			</td>	
			<td class="tbYellow">本金餘額</td>		
			<td class="tbYellow2">
				<input id="REMAIN_AMT1" type='text' class= 'textBox2' datatype='number'  size='12' maxlength='10' />
			</td>
			<td class="tbYellow">利率</td>
			<td class="tbYellow2">
				<input id="YEAR_RATE" type='text' class= 'textBox2'  size='12' maxlength='6' fieldName = "利率"/>%
			</td>
		</tr>		
		<tr>
			<td class="tbYellow" width="10%">未受分配利息</td>		
			<td class="tbYellow2" width="10%">
				<input id="UNDIS_INT1" type='text' class= 'textBox2' datatype='number'  size='12' maxlength='10' />
			</td>	
			<td class="tbYellow" width="10%">未受分配違約金</td>		
			<td class="tbYellow2" width="10%">
				<input id="UNDIS_RENEGE1" type='text' class= 'textBox2' datatype='number'  size='12' maxlength='10' />
			</td>
			<td class="tbYellow" width="10%">未受分配程序費用</td>		
			<td class="tbYellow2" width="10%">
				<input id="UNDIS_FEE1" type='text' class= 'textBox2' datatype='number'  size='12' maxlength='10' />
			</td>			
		</tr>
				<tr>
			<td class="tbBox3" align="center" colspan="6">
				協議清償債權試算
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%">案件種類</td>		
			<td class="tbYellow2" width="10%">
				<input id="CASE_KIND2" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "案件種類"/>
				<span id="CASE_KIND_NAME2"></span>
			</td>
			<td class="tbYellow" width="10%">抵充順序</td>		
			<td class="tbYellow2" width="10%"  colSpan='3'>
				<span id="OFFSET_TYPE2_NM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">拍定日</td>
			<td class="tbYellow2">
				<input id="BEG_DATE2" type='text' size='12' datatype ="ROCDate"  class= 'textBox2' maxlength='7' fieldName="結算日"/> 
				<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('BEG_DATE2'))" />
			</td>
			<td class="tbYellow">本金餘額</td>		
			<td class="tbYellow2">
				<input id="REMAIN_AMT2" type='text' class= 'textBox2' datatype='number'  size='12' maxlength='10' />
			</td>
			<td class="tbYellow">公司加權平均利率</td>
			<td class="tbYellow2">
				<input id="AVG_RATE" type='text' class= 'textBox2'  size='12' maxlength='6' fieldName = "利率"/>%
			</td>
		</tr>		
		<tr>
			<td class="tbYellow" width="10%">未受分配利息</td>		
			<td class="tbYellow2" width="10%">
				<input id="UNDIS_INT2" type='text' class= 'textBox2' datatype='number'  size='12' maxlength='10' />
			</td>	
			<td class="tbYellow" width="10%">未受分配違約金</td>		
			<td class="tbYellow2" width="10%">
				<input id="UNDIS_RENEGE2" type='text' class= 'textBox2' datatype='number'  size='12' maxlength='10' />
			</td>
			<td class="tbYellow" width="10%">未受分配程序費用</td>		
			<td class="tbYellow2" width="10%">
				<input id="UNDIS_FEE2" type='text' class= 'textBox2' datatype='number'  size='12' maxlength='10' />
			</td>			
		</tr>
	</table>
</form>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
	<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>	
			<td class="tbYellow1" colspan="8" align="center">			
				<input id = "btn_calculate1" type = "button" class = "button" value = "債權試算" />				
				<input id = "btn_calculate2" type = "button" class = "button" value = "協議清償債權試算" />	
				<input id = "btn_insert" type = "button" class = "button" value = "新增" />		
				<input id = "btn_update" type = "button" class = "button" value = "修改" />				
				<input id = "btn_delete" type = "button" class = "button" value = "刪除" />	
				<input id = "btn_confirm" type = "button" class = "button" value = "覆核" />			
				<input id = "btn_cancel" type = "button" class = "button" value = "取消覆核" />
				<input id = "btn_print" type = "button" class = "button" value = "列印" />
				<input id = "btn_print2" type = "button" class = "button" value = "列印(簡)" />
				<input id = "btn_close" type = "button" class = "button" value = "關閉" />
			</td>
		</tr>
	</table>

	<table  width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow0"  align="center" colSpan="4">
				<input id="check1" type="CHECKBOX" name="List1_check"/>
				<span style="font-weight: bold;">拍賣不足債權試算</span>				
			</td>
		</tr>
	</table>	
	<table id = "grid" class="grid" width="100%" ></table>
	<table  width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow0"  align="center" colSpan="4">
				<input id="check2" type="CHECKBOX" name="List2_check"/>
				<span style="font-weight: bold;">協議清償債權試算</span>			
			</td>
		</tr>
	</table>	
	<table id = "grid1" class="grid" width="100%"  ></table>
</form>
</body>
</html>