<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC80800.jsp
作者：張智翔
功能：921 災戶建檔。
完成：2013-08-22

[20230317] 修改程式  楊青峰
難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%-- 匯入外部Javascript 與 css --%>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<%-- [20230317] --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
	         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	      font-weight: normal;
	      font-style: normal
	}
</style>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>

<script type='text/javascript'>

// 產生畫面物件
var DSC80800 = new DSC80800();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSC80800.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC80800(){
	var grid;

	var rtnMap = {};
	
	var is_query ='';
	
	var VICTIM_KIN_Q = '';
	
	var LOAN_ID = '';
	
	//檢核
	var valid1;		
	var valid2;
	var valid3;	
	
	function buttonAuth(){
		var authButtons = {
				B0003:"btn_insert",<%--新增--%> 			
				B0005:"btn_delete"<%--刪除--%> 			
		};
	
		<dz:grantButtons FUNC_ID="DSC80800" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){	
		
		Validation.addAllThese([
			[ 'checkLOAN_ID',  '欲變更的貸款帳號與原先查詢的不同,無法作業', 
				function(v){					
					if(v != rtnMap.LOAN_ID){
						return false;					
					}
					return true;
				}
			],
			[ 'requiredNEW_NXPDT7',  '不可空白', 
				function(v){				
					if($F('VICTIM_KIN_Q') == '7'){						
						return !Validation.get('IsEmpty').test(v);					
					}else{
						return true;
					}
				}
			] 	
			
		]);
		//查詢用檢核			
		valid1 = new Validation("form", {useTitles:true,focusOnError:false,immediate:false});			
		valid1.define( "required" , { id: "LOAN_ID_Q"  } );	
		valid1.define( "required" , { id: "VICTIM_KIN_Q"  } );	
		
		valid2 = new Validation("form", {useTitles:true,focusOnError:false,immediate:false});
		valid2.define( "checkLOAN_ID" , { id: "LOAN_ID_Q"  } );	
		valid2.define( "requiredNEW_NXPDT7" , { id: "NEW_NXPDT7"  } );		

		valid3 = new Validation("form", {useTitles:true,focusOnError:false,immediate:false});
		valid3.define( "checkLOAN_ID" , { id: "LOAN_ID_Q"  } );		
		
	}	
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0800/" + actionName,
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
	
	
	
	//按鈕功能
	var buttons = {	
		
		//查詢
		doQuery : function(){	
			
			valid3.reset();
			valid2.reset();
			if(!valid1.validate()){
				return;
			}	
			
			VICTIM_KIN_Q = $('VICTIM_KIN_Q').value ;
			//發送ajax
			ajaxPost( 'query' , {LOAN_ID_Q : $('LOAN_ID_Q').value ,VICTIM_KIN_Q :  VICTIM_KIN_Q},
				function(resp){	
					is_query = 'Y';					
					rtnMap = resp.rtnMap;					
					actions.clearAndHideDiv( rtnMap.VICTIM_KIND);
					actions.showData(rtnMap);				
					
					
				},
				function(resp){	
					is_query = 'N';	
					actions.clearAndHideDiv('');
					rtnMap = {};
				}
			);				
		},
		
		//新增
		doInsert : function(){	
			if(is_query != 'Y'){
				alert('請先查詢再進行新增!!!');
				return;			
			}
			if($F('VICTIM_KIN_Q')!=VICTIM_KIN_Q){
				alert('災戶種類與原先查詢不同，請先重查新增');
				return ;
			}
			valid1.reset();
			valid3.reset();
			if(!valid2.validate()){
				return;
			}	
			
			actions.getAllData();
			//資料處理
			actions.processData();			
			//發送ajax
			ajaxPost( 'insert' , { rtnMap : Object.toJSON(rtnMap) , VICTIM_KIN_Q : VICTIM_KIN_Q , LOAN_ID_Q : rtnMap.LOAN_ID},
				function(resp){						
					rtnMap = resp.rtnMap;					
					actions.clearAndHideDiv( rtnMap.VICTIM_KIND);
					actions.showData(rtnMap);	
				}
			);			
		},
		
		//刪除
		doDelete: function(){
			if(is_query != 'Y'){
				alert('請先查詢再進行刪除!!!');
				return;			
			}	
			
			valid1.reset();
			valid2.reset();
			if(!valid3.validate()){
				return;
			}	
			
			if(!confirm('確定要刪除？')){
				return;
			}
			
				//發送ajax
			ajaxPost( 'delete' , { rtnMap : Object.toJSON(rtnMap) , VICTIM_KIN_Q : VICTIM_KIN_Q , LOAN_ID_Q : rtnMap.LOAN_ID},
				function(resp){	
					rtnMap = resp.rtnMap;				
					actions.clearAndHideDiv( rtnMap.VICTIM_KIND);
					actions.showData(rtnMap);	
				}
			);		
		
		}
		
		
		
	}

	//各種共用方法
	var actions = {
		
		clearAndHideDiv : function(VICTIM_KIND){
			//將B區清空
			$$('#tableB span').each(
				function(elem){
					elem.update('');	
				}			
			);
		
			//將所有欄位清空
			$$('#alltable input[type = "text"]' , '#alltable span').each(
				function(elem){
					var tagName = elem.tagName;				
					if(tagName == 'INPUT'){
						elem.value = '';					
					}else if(tagName == 'SPAN'){
						elem.update('');					
					}
				
				}			
			);
			
			//Hide所有table
			actions.hideAllTable();			
	
			//依照功能打開
			if(VICTIM_KIND!='6'){
				$('tableC').show();
			}
			if(VICTIM_KIND== '3' || VICTIM_KIND =='4'){
				$('tableD').show();				
			}else if(VICTIM_KIND== '5'){
				$('tableE').show();
			}else if(VICTIM_KIND== '6'){
				$('tableF').show();
			}else if(VICTIM_KIND== '7'){
				$('tableG').show();
			}
			if(VICTIM_KIND== 'A'||VICTIM_KIND== 'B'||VICTIM_KIND== 'C'){
				$('PNL_SPRNO').disabled = true;
				$('INT_SETNO').disabled = true;
				$('INT_SPRNO').disabled = true;
				$('VICTIM_ADJUST').disabled = true;
			}else{
				$('PNL_SPRNO').disabled = false;
				$('INT_SETNO').disabled = false;
				$('INT_SPRNO').disabled = false;
				$('VICTIM_ADJUST').disabled = false;
				$('PNL_SPRNO').value = '';
			}	
		},
		
		//隱藏所有table
		hideAllTable : function(){
			$$('#alltable table').each(
				function(elem){
					elem.hide();
				}			
			);		
			
			PageUI.resize();
		
		},
		//顯示資料
		showData : function(rtnMap){
			
			for (key in rtnMap){
				
				var dom = $(key);
				if(dom){
					var tagName = dom.tagName;
					var datatype = dom.getAttribute('datatype');
				
					if(tagName == 'INPUT'){
						if(datatype == 'ROCdate'){
							dom.value = toROC(rtnMap[key] )|| '';		
						}else if(datatype == 'number'){
							dom.value = MoneyFormat(rtnMap[key]);		
						}else{
							dom.value = rtnMap[key] || '';		
						}
					}else if (tagName =='SPAN'){						
						if(datatype == 'ROCdate'){
							dom.update( toROC(rtnMap[key] )|| '');		
						}else if(datatype == 'number'){
							dom.update( MoneyFormat(rtnMap[key]) || '');		
						}else{
							dom.update(rtnMap[key]||'');
						}
					
					}
					var FIX_PERIOD = (rtnMap.FIX_PERIOD || rtnMap.FIX_PERIOD === 0) ? rtnMap.FIX_PERIOD : '';
					var SPR_PERIOD = (rtnMap.SPR_PERIOD || rtnMap.SPR_PERIOD === 0) ? rtnMap.SPR_PERIOD : '';
					$('SPR_PERIOD_SPR_PERIOD').update(SPR_PERIOD + ' 、 ' + FIX_PERIOD);
					$('PAID_TIMES_VALID_TIMES').update((rtnMap.PAID_TIMES ||'')+ ' 、 ' +  (rtnMap.VALID_TIMES||''));
				}			
			}			
			
			$('VICTIM_KIN_Q').value=rtnMap.VICTIM_KIND;
		},
		
		//取得畫面資料
		getAllData : function(){
			
			$$('#alltable input[type="text"]').each(
				function(elem){						
					rtnMap[elem.id] = elem.getValue();
				}			
			);
			//rtnMap['VICTIM_KIND'] = $('VICTIM_KIN_Q').getValue();
		},
		
		//資料處理
		processData : function(){		
			var VICTIM_KIND = rtnMap.VICTIM_KIND;				
			var PAID_TIMES = rtnMap.PAID_TIMES;
			rtnMap.REC_AMT1 = '';
			rtnMap.REC_AMT2 = '';
			rtnMap.REC_OVER = '';
			if(VICTIM_KIND == '7'){ //災戶承受無展延				
				rtnMap.PNL_SPRNO = 0;
				rtnMap.INT_SPRNO = 0;
				rtnMap.NEW_NXPDT = toY2K(rtnMap.NEW_NXPDT7) ||''; 
				
				var END_DATE = toY2K(rtnMap.END_DATE);
				var DUTY_DAY = toY2K(rtnMap.DUTY_DAY);
				var NEXT_PAYDT = toY2K(rtnMap.NEXT_PAYDT);
				var NEW_NXPDT  = toY2K(rtnMap.NEW_NXPDT);
				//滿期日加五年	
				var dtCheck1 = getDutyDay(END_DATE,DUTY_DAY,60);				
				 //下次應繳日加二十年
				
				var dtCheck2 = getDutyDay(NEXT_PAYDT,DUTY_DAY,240);
				
				if (diffDay(dtCheck2, dtCheck1) > 0) {
					rtnMap.REC_ENDDT = dtCheck2;					         
				} else {
					rtnMap.REC_ENDDT = dtCheck1;				
				}
				
				rtnMap.REC_AMT1 = rtnMap.REC_AMT17 ||'';
				rtnMap.REC_AMT2 = rtnMap.REC_AMT27 ||'';
				rtnMap.REC_OVER = rtnMap.REC_OVER7 ||'';
				rtnMap.REC_REMAIN1 = 0;
				rtnMap.REC_REMAIN2 = 0;
				rtnMap.OWE_TERM = rtnMap.OWE_TERM7 ||'';
				rtnMap.OWE_INT = rtnMap.OWE_INT7 ||'';
				rtnMap.OWE_REMINT = rtnMap.OWE_INT ||'';
				rtnMap.OLD_SPRAMT = rtnMap.OLD_SPRAMT7 ||'';
				rtnMap.OLD_FIXAMT = rtnMap.OLD_FIXAMT7 ||'';
				rtnMap.INT_REMNO = rtnMap.INT_SETNO ||'';					
			
				var i = 0;
				var strNewDate; //推經過幾期之後為新的應繳日
				do {
					i++;
					strNewDate = getDutyDay( NEXT_PAYDT , DUTY_DAY ,i) ;					
				} while (diffDay(strNewDate, NEW_NXPDT) > 0 || i > 360);				
				rtnMap.NEW_TERM =  PAID_TIMES + i;
				//95-02-23承受件的利息攤繳日設為新下次應繳日
				//rtnMap.INT_SPRDT = NEW_NXPDT;
				rtnMap.INT_SPRDT = strNewDate;
				rtnMap.NEW_NXPDT = strNewDate;
			}else{
				var PNL_EXTDT = toY2K(rtnMap.PNL_EXTDT);
				var PNL_SPRNO = rtnMap.PNL_SPRNO || 0;
				rtnMap.OLD_ENDDT = toY2K(rtnMap.OLD_ENDDT);
				if(PNL_SPRNO > 0){
					rtnMap.PNL_SPRDT = getDutyDay(PNL_EXTDT, PNL_EXTDT.substring(8), parseInt(PNL_SPRNO));			
				
				}
				var INT_SPRNO = rtnMap.INT_SPRNO || 0;
				var INT_EXTDT = toY2K(rtnMap.INT_EXTDT);	
				
				if(INT_SPRNO > 0){				
					rtnMap.INT_SPRDT = getDutyDay(INT_EXTDT, INT_EXTDT.substring(8), parseInt(INT_SPRNO));				
				}	
				if(VICTIM_KIND == '3'){		
                    rtnMap.REC_AMT1 = rtnMap.REC_AMT13 ||'';
					rtnMap.REC_AMT2 = rtnMap.REC_AMT23 ||'';				
					rtnMap.VICTIM_ADJUST = 0;//只有全倒半倒承受有災戶減碼
					rtnMap.REC_REMAIN1 = 0;
					rtnMap.REC_REMAIN2 = 0;
				
				}else if(VICTIM_KIND == '4'){		
					rtnMap.REC_AMT1 = rtnMap.REC_AMT13 ||'';
					rtnMap.REC_AMT2 = rtnMap.REC_AMT23 ||'';
					rtnMap.VICTIM_ADJUST = 0;//只有全倒半倒承受有災戶減碼
					rtnMap.REC_REMAIN1 = 0;
					rtnMap.REC_REMAIN2 = 0;
				}else if(VICTIM_KIND == '5'){		
					rtnMap.REC_AMT1 = rtnMap.REC_AMT15 ||'';
					rtnMap.VICTIM_ADJUST = 0;//只有全倒半倒承受有災戶減碼
					rtnMap.INT_SETNO = 36;//修繕利息分攤期數預設為３６期(三年)
					rtnMap.INT_REMNO = 36;//修繕利息分攤期數預設為３６期(三年)
					rtnMap.REC_REMAIN1 = 0;
					rtnMap.REC_REMAIN2 = 0;
				}else if(VICTIM_KIND == '6'){	
					rtnMap.REC_AMT1 = rtnMap.REC_AMT16 ||'';
					rtnMap.REC_AMT2 = rtnMap.REC_AMT16 ||'';
					rtnMap.VICTIM_ADJUST = 0;//只有全倒半倒承受有災戶減碼
					rtnMap.INT_SETNO = 36;//修繕利息分攤期數預設為３６期(三年)
					rtnMap.INT_REMNO = 36;//修繕利息分攤期數預設為３６期(三年)
					rtnMap.REC_REMAIN1 = rtnMap.REC_AMT1 ||'';
					rtnMap.REC_REMAIN2 = rtnMap.REC_AMT2 ||'';
				}
			
				rtnMap.INT_SPRDT =toY2K(rtnMap.INT_SPRDT)||'';
			} 
			rtnMap.INT_REMNO = rtnMap.INT_SETNO || '';
			rtnMap.PNL_SPRDT =toY2K(rtnMap.PNL_SPRDT)||'';
		}	
	}
	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSC80800", "收息資料更新", "災戶建檔作業" );				
		
				
				//click事件
				$('btn_query').observe( 'click', buttons.doQuery);
				$('btn_insert').observe( 'click', buttons.doInsert);			
				$('btn_delete').observe( 'click', buttons.doDelete);		
				
				
				fix();

				displayMessage();
				
				initValidation();	
			
				actions.hideAllTable();
				
				autoFormatToNumber();
				
				buttonAuth();
				
				PageUI.resize();
			}
	};
};

</script>
</head>
<body>		
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					貸款帳號
				</td>
				<td class="tbYellow2" >
					<input id="LOAN_ID_Q"  name = "LOAN_ID_Q" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" fieldName = "貸款帳號" size = "11" maxlength = "10"/>
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					災戶種類
				</td>
				<td class="tbYellow2" >
					<select name="VICTIM_KIN_Q" id="VICTIM_KIN_Q" class="textBox2" fieldName = "災戶種類">						
						<c:forEach items="${VICTIM_KIND_List}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>							
				</td>				
				<td class="tbYellow2" align = "center">
					<input id = "btn_query" type = "button" class = "button" value = "查詢"   />	
					<input id = "btn_insert" type = "button" class = "button" value = "新增"   />	
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"   />	
				</td>	
			</tr>
		</table>
		<table id = "tableB" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0"  align="center"  colspan ="8">
					<b>貸款帳號資料</b>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					借款人ID
				</td>
				<td class="tbYellow2" >
					<span id = "BORROW_ID">	</span>	
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					姓　名
				</td>
				<td class="tbYellow2" >
					<span id = "BORROW_NAME" style="font-family: 'EUDC'">	</span> <%-- [20230317] --%>	
				</td>	
				<td class="tbYellow" width="12%" align="left" >
					貸款種類
				</td>
				<td class="tbYellow2" width = "10%">
					<span id = "LOAN_KIND_NM">	</span>	
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					優惠種類
				</td>
				<td class="tbYellow2" >
					<span id = "PREFER_TYPE_NM">	</span>			
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					貸放日期
				</td>
				<td class="tbYellow2" >
					<span id = "LOAN_DATE" datatype = "ROCdate">	</span>	
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					滿期日期
				</td>
				<td class="tbYellow2" >
					<span id = "END_DATE" datatype = "ROCdate">	</span>			
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					下應繳日
				</td>
				<td class="tbYellow2" >
					<span id = "NEXT_PAYDT" datatype = "ROCdate">	</span>	
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					優惠起日
				</td>
				<td class="tbYellow2" >
					<span id = "PREFER_BEGDT" datatype = "ROCdate">	</span>			
				</td>	
			</tr>
				<tr>
				<td class="tbYellow" width="10%" align="left" >
					契約狀況
				</td>
				<td class="tbYellow2" >
					<span id = "LOAN_STATUS_NM">	</span>	
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					分-定期數
				</td>
				<td class="tbYellow2" >
					<span id = "SPR_PERIOD_SPR_PERIOD" datatype = "number" >	</span>			
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					已繳-有效期數
				</td>
				<td class="tbYellow2" >
					<span id = "PAID_TIMES_VALID_TIMES" datatype = "number" >	</span>	
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					輸入人員
				</td>
				<td class="tbYellow2" >
					<span id = "INPUT_NAME" style="font-family: 'EUDC'">	</span>	<%-- [20230317] --%>		
				</td>	
			</tr>
			</tr>
				<tr>
				<td class="tbYellow" width="10%" align="left" >
					貸款金額
				</td>
				<td class="tbYellow2" >
					<span id = "LOAN_AMT" datatype = "number" >	</span>	
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					分期餘額
				</td>
				<td class="tbYellow2" >
					<span id = "SPR_AMT" datatype = "number" >	</span>			
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					定期餘額
				</td>
				<td class="tbYellow2" >
					<span id = "FIX_AMT" datatype = "number" >	</span>	
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					輸入日期
				</td>
				<td class="tbYellow2" >
					<span id = "INPUT_DATE"  datatype = "ROCdate">	</span>			
				</td>	
			</tr>
		</table>
		<div id ="alltable">
		<table id = "tableC" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0"  align="center"  colspan ="8">
					<b>災戶設定</b>
				</td>
			</tr>
			</tr>
				<tr>
				<td class="tbYellow" width="18%" align="left" >
					利息分攤、剩餘期數
				</td>
				<td class="tbYellow2" >
					<input id="INT_SETNO"  name = "INT_SETNO" type="text" class="textBox2"  datatype = "number"  fieldName = "利息分攤" size = "5"/>
					<input id="INT_REMNO"  name = "INT_REMNO" type="text" class="textBox2"  datatype = "number"  fieldName = "剩餘期數" size = "5" disabled />
				</td>	
				<td class="tbYellow" width="12%" align="left" >
					減碼利率
				</td>
				<td class="tbYellow2" >
					<input id="VICTIM_ADJUST" name = "VICTIM_ADJUST" type="text" class="textBox2" size = "5"  datatype = "number"  fieldName = "減碼利率" />%
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					原到期日
				</td>
				<td class="tbYellow2" >
					<input id="OLD_ENDDT"  name = "OLD_ENDDT" datatype="ROCdate" type="text" class="textBox2" size = "8" maxlength = "7" fieldName = "原到期日" disabled />
				</td>					
			</tr>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					本金展延起日
				</td>
				<td class="tbYellow2" >
					<input id="PNL_EXTDT"  name = "PNL_EXTDT" datatype="ROCdate" type="text" class="textBox2" size = "8" maxlength = "7" fieldName = "本金展延起日" disabled />
					
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					攤還期數-起日
				</td>
				<td class="tbYellow2" >
					<input id="PNL_SPRNO"  name = "PNL_SPRNO" type="text" class="textBox2" size = "4" datatype = "number"  fieldName = "攤還期數" />
					<input id="PNL_SPRDT"  name = "PNL_SPRDT" datatype="ROCdate" type="text" class="textBox2" size = "8" maxlength = "7" fieldName = "起日" disabled/>
					
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					
				</td>
				<td class="tbYellow2" >
					
				</td>					
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					利息展延起日
				</td>
				<td class="tbYellow2" >
					<input id="INT_EXTDT"  name = "INT_EXTDT" datatype="ROCdate" type="text" class="textBox2" size = "8" maxlength = "7" fieldName = "利息展延起日" disabled />
				
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					攤還期數-起日
				</td>
				<td class="tbYellow2" >
					<input id="INT_SPRNO"  name = "INT_SPRNO" type="text" class="textBox2" size = "4" datatype = "number"  fieldName = "攤還期數" />
					<input id="INT_SPRDT"  name = "INT_SPRDT" datatype="ROCdate" type="text" class="textBox2" size = "8" maxlength = 7 fieldName = "起日" disabled />
				
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					
				</td>
				<td class="tbYellow2" >
					
				</td>					
			</tr>
		</table>
		<table id = "tableD" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0"  align="center"  colspan ="8">
					<b>補貼額度分布</b>
				</td>
			</tr>			
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					１５０萬含以下
				</td>
				<td class="tbYellow2" >
					<input id="REC_AMT13"  name = "REC_AMT13" type="text" class="textBox2"  datatype = "number"  fieldName = "１５０萬含以下" size = "11"/>
					
				</td>	
				<td class="tbYellow"  align="left" >
					客戶免息，政府補貼郵匯利率＋１％
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					１５０－３５０萬
				</td>
				<td class="tbYellow2" >
					<input id="REC_AMT23"  name = "REC_AMT23" type="text" class="textBox2"  datatype = "number"  fieldName = "１５０－３５０萬" size = "11"/>					
				</td>	
				<td class="tbYellow" align="left" >
					客付３％，政府補貼郵匯利率－３％
				</td>				
			</tr>
		</table>
		<table id = "tableE" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0"  align="center"  colspan ="8">
					<b>補貼額度分布</b>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					１５０萬含以下
				</td>
				<td class="tbYellow2" >
					<input id="REC_AMT15"  name = "REC_AMT15" type="text" class="textBox2"  datatype = "number"  fieldName = "１５０萬含以下" size = "11"/>					
				</td>	
				<td class="tbYellow" align="left" >
					客付３％，政府補貼郵匯利率－３％
				</td>				
			</tr>
		</table>
		<table id = "tableF" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0"  align="center"  colspan ="8">
					<b>補貼額度分布</b>
				</td>
			</tr>			
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					１５０萬含以下
				</td>
				<td class="tbYellow2" >
					<input id="REC_AMT16"  name = "REC_AMT16" type="text" class="textBox2"  datatype = "number"  fieldName = "１５０萬含以下" size = "11"/>
					
				</td>	
				<td class="tbYellow"  align="left" >
					客戶原利率－郵匯利率（政府補貼）
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					１５０－３５０萬
				</td>
				<td class="tbYellow2" >
					<input id="REC_AMT26"  name = "REC_AMT26" type="text" class="textBox2"  datatype = "number"  fieldName = "１５０－３５０萬" size = "11"/>					
				</td>	
				<td class="tbYellow" align="left" >
					客戶原利率－（郵匯利率－３％）
				</td>				
			</tr>
		</table>
		
		<table id = "tableG" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0"  align="center"  colspan ="8">
					<b>待補利息</b>
				</td>
			</tr>		
			<tr>
				<td class="tbYellow" width="18%" align="left" >
					變更前未結清期數
				</td>
				<td class="tbYellow2" >
					<input id="OWE_TERM7"  name = "OWE_TERM7" type="text" class="textBox2"  datatype = "number"  fieldName = "變更前未結清期數" size = "10"/>					
				</td>	
				<td class="tbYellow" width="12%" align="left" >
					欠繳利息
				</td>
				<td class="tbYellow2" >
					<input id="OWE_INT7"  name = "OWE_INT7" type="text" class="textBox2" size = "10"  datatype = "number"  fieldName = "欠繳利息" />
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					承受補貼終止日
				</td>
				<td class="tbYellow2" >
				<input id="REC_ENDDT7"  name = "REC_ENDDT7" type="text" class="textBox2" size = "10"fieldName = "承受補貼終止日" datatype="ROCdate"  disabled />
				</td>					
			</tr>			
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					承受前分期餘額
				</td>
				<td class="tbYellow2" >
					<input id="OLD_SPRAMT7"  name = "OLD_SPRAMT7 " type="text" class="textBox2"  datatype = "number"  fieldName = "承受前分期餘額" size = "10" disabled />					
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					承受前定期餘額
				</td>
				<td class="tbYellow2" >
					<input id="OLD_FIXAMT7"  name = "OLD_FIXAMT7" type="text" class="textBox2"  datatype = "number"  size = "10"fieldName = "承受前定期餘額" disabled />
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					超出３５０萬部分
				</td>
				<td class="tbYellow2" >
					<input id="REC_OVER7"  name = "REC_OVER7" type="text" class="textBox2" size = "10" datatype = "number"  fieldName = "超出３５０萬部分"  />
				</td>					
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					新下次應繳日
				</td>
				<td class="tbYellow2" >
					<input id="NEW_NXPDT7"  name = "NEW_NXPDT7" type="text" class="textBox2 validate-ROCDate" size = "8" datatype = "ROCdate" fieldName = "新下次應繳日"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('NEW_NXPDT7'))" /></td>	
				</td>
				<td class="tbYellow" width="10%" align="left" >
					
				</td>
				<td class="tbYellow2" >
					
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					
				</td>
				<td class="tbYellow2" >
					
				</td>	
			</tr>	
			<tr>
				<td class="tbYellow0"  align="center"  colspan ="8">
					<b>補貼額度分布</b>
				</td>
			</tr>			
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					２００萬含以下
				</td>
				<td class="tbYellow2" >
					<input id="REC_AMT17"  name = "REC_AMT17" type="text" class="textBox2"  datatype = "number"  fieldName = "２００萬含以下" size = "11"/>
					
				</td>	
				<td class="tbYellow"  align="left" colspan = "4">
					客戶原利率－（郵匯利率－３％）					
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					２００－３５０萬
				</td>
				<td class="tbYellow2" >
					<input id="REC_AMT27"  name = "REC_AMT27" type="text" class="textBox2"  datatype = "number"  fieldName = "２００－３５０萬" size = "11"/>					
				</td>	
				<td class="tbYellow" align="left" colspan = "4">
				客戶原利率－郵匯利率（政府補貼）
				</td>				
			</tr>
		</table>
		</div>
	</form>	
</body>
</html>