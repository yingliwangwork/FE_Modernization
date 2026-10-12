<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC80600.jsp
作者：張智翔
功能：優惠同意變更。
完成：2013-09-23

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


<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>

<script type='text/javascript'>

// 產生畫面物件
var DSC80600 = new DSC80600();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSC80600.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC80600(){	

	var LOAN_ID = '';
	
	var is_query = false;
	//檢核
	var valid1;		
	var valid2;	
	var rtnMap = {};
	
	function buttonAuth(){
	var authButtons = {
			B0004:"btn_change"<%--變更--%> 			
	};
	
	<dz:grantButtons FUNC_ID="DSC80600" ignored="false"/>
}
	
	//畫面檢核
	function initValidation(){		
		//查詢用檢核			
		valid1 = new Validation("form", {useTitles:true,focusOnError:false,immediate:false});
		valid2 = new Validation("form", {useTitles:true,focusOnError:false,immediate:false});
		Validation.addAllThese([
			[ 'checkLOAN_ID',  '欲變更的貸款帳號與原先查詢的不同,無法作業', 
				function(v){					
					if(v != rtnMap.LOAN_ID){
						return false;					
					}
					return true;
				}
			] 
			
		]);
		valid1.define( "required" , { id: "LOAN_ID_Q"  } );	
		valid2.define( "checkLOAN_ID" , { id: "LOAN_ID_Q"  } );	
		valid2.define( "required" , { id: "INSU_NOTE2" , errMsg:"輸入新優惠同意!!" } );			
		
	}	
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0600/" + actionName,
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
			valid2.reset();
			if(!valid1.validate()){
				return;
			}	
			
			LOAN_ID = $('LOAN_ID_Q').value;
			//發送ajax
			ajaxPost( 'query' , { LOAN_ID_Q : LOAN_ID },
				function(resp){	
					rtnMap = resp.rtnMap;
					is_query = true;
					actions.showData();
					
					$('INSU_NOTE2').value = '';
					$('BUILD_USE2').value = '1';
				},
				function(resp){	
					is_query = false;
					rtnMap = {};
					actions.clearAll();
				}
			);				
		},
		
		//變更
		doChange : function(){
			if(!is_query){
				alert('請先查詢再進行變更!!!');
				return;			
			}	
			valid1.reset();
			if(!valid2.validate()){
				return;
			}	
			if(!confirm('確定要變更此貸款帳號之同意優惠？')){
				return;
			}
			
			rtnMap.INSU_NOTE2 = $('INSU_NOTE2').value;
			rtnMap.BUILD_USE2 = $('BUILD_USE2').value;
			
			//發送ajax
			ajaxPost( 'change' , { rtnMap : Object.toJSON(rtnMap) , LOAN_ID_Q : LOAN_ID },
				function(resp){	
					rtnMap = resp.rtnMap;					
					actions.showData();
					
					$('INSU_NOTE2').value = '';
					$('BUILD_USE2').value = '1';
				}			
			
			);			
		},
		
		//保戶優惠審核
		doProfit : function(){
			
			var LP_JSON = {
				action :'<%=dispatcher%>/DSC8_0601/prompt',
				'USER_DEPT': '${USER_DEPT}'
				}
			CSRUtil.linkTo(LP_JSON , 'form');				
		}
	}
	
	var actions = {
		//顯示資料
		showData : function(){
			for (key in rtnMap){				
				var dom = $(key);
				
				if(dom){
				
					var tagName = dom.tagName;
					var datatype = dom.getAttribute('datatype');
				
					if(tagName == 'INPUT' || tagName == 'SELECT' ){
						if(datatype == 'ROCdate'){
							dom.value = toROC(rtnMap[key] )|| '';		
						}else if(datatype == 'number'){
							dom.value = MoneyFormat(rtnMap[key]);		
						}else{
							dom.value = rtnMap[key] || '';		
						}
					}else if (tagName =='SPAN'){						
						if(datatype == 'ROCdate'){
							dom.update( Date.toInputROC(rtnMap[key] || "","."));   		
						}else if(datatype == 'number'){							
							dom.update( MoneyFormat(rtnMap[key]) || '');		
						}else{
							dom.update(rtnMap[key]||'');
						}					
					}
				
					$('BORROW_ID_NAME').update((rtnMap.BORROW_ID||'') + '  '+ (rtnMap.BORROW_NAME||''));
					$('BEGIN_DATE1_INSU_PRANK1').update( Date.toInputROC(rtnMap['BEGIN_DATE1'] || "",".") + '  '+  (rtnMap.INSU_PRANK1||'')+'級');
					$('BEGIN_DATE2').value = Date.toInputROC(rtnMap['NEXT_PAYDT'] || "",".");
				}			
			}	
		
		},
		
		clearAll : function(){
			//將所有欄位清空
			$$('#alltable input[type = "text"]' , '#alltable span').each(
				function(elem){
					var tagName = elem.tagName;				
					if(tagName == 'INPUT'){
						elem.value = '';					
					}else if(tagName == 'SPAN'){
						elem.update('');					
					}
					
					$('INSU_NOTE2').value = '';
					$('BUILD_USE2').value = '1';
					$('INSU_PRANK2').value = '0';				
				}			
			);
		
		
		
		}
	
	
	
	
	
	
	
	
	
	}
	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSC80600", "收息資料更新", "優惠同意變更" );					
		
				//click事件
				$('btn_query').observe( 'click', buttons.doQuery);
				$('btn_change').observe( 'click', buttons.doChange);
				$('btn_profit').observe( 'click', buttons.doProfit);
				
				$('LOAN_ID_Q').observe('change' , 				
					function(event){
						event.target.value = event.target.value.toUpperCase();					
					}
				);
				$('BUILD_USE2').value = '1'; //預設為住宅
				
				fix();

				displayMessage();
				
				initValidation();			
			
				buttonAuth();
				
				if(CSRUtil.isBackLink('form') && $('LOAN_ID_Q').value){    
					buttons.doQuery();  
				}
				
			}
	};
};

</script>
</head>
<body>		
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width="13%" align="left" >
					貸款帳號
				</td>
				<td class="tbYellow2" width = "20%">
					<input id="LOAN_ID_Q"  name = "LOAN_ID_Q" type="text" class="textBox2" fieldName = "貸款帳號" size = "12" maxlength = "10"/>
				</td>			
				<td class="tbYellow2" align = "left" colspan = "4">
					<input id = "btn_query" type = "button" class = "button" value = "查詢"   />	
					<input id = "btn_change" type = "button" class = "button" value = "變更"   />	
					<input id = "btn_profit" type = "button" class = "button" value = "保戶優惠審核"   />		
				</td>	
			</tr>
			<tbody id = "alltable">
			<tr>
				<td class="tbYellow" align="left" >
					借款人
				</td>
				<td class="tbYellow2" colspan = "5">
					<span id = "BORROW_ID_NAME" style="font-family: 'EUDC'"></span> <%-- [20230317] --%>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					契約狀態
				</td>
				<td class="tbYellow2" >
					<span id = "LOAN_STATUS_NM"></span>
				</td>	
				<td class="tbYellow" width="13%" align="left" >
					貸放日期
				</td>
				<td class="tbYellow2" width = "20%">
					<span id = "LOAN_DATE" datatype = "ROCdate"></span>
				</td>	
				<td class="tbYellow" width="14%" align="left" >
					貸款餘額
				</td>
				<td class="tbYellow2" width = "20%">
					<span id = "LOAN_AMT" datatype = 'number'></span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					貸款種類
				</td>
				<td class="tbYellow2" >
					<span id = "LOAN_KIND_NM"></span>
				</td>	
				<td class="tbYellow" align="left" >
					優惠種類
				</td>
				<td class="tbYellow2" >
					<span id = "PREFER_TYPE_NM"></span>
				</td>	
				<td class="tbYellow" align="left" >
					扣薪狀態
				</td>
				<td class="tbYellow2" >
					<span id = "SALARY_STATUS_NM"></span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					原優惠同意
				</td>
				<td class="tbYellow2" >
					<span id = "INSU_NOTE1_NM"></span>
				</td>	
				<td class="tbYellow" align="left" >
					原建物用途
				</td>
				<td class="tbYellow2" >
					<span id = "BUILD_USE1_NM"></span>
				</td>	
				<td class="tbYellow" align="left" >
					原保優起日等級
				</td>
				<td class="tbYellow2" >
					<span id = "BEGIN_DATE1_INSU_PRANK1"></span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow0" colspan = "6">
					 &nbsp
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" >
					新優惠同意
				</td>
				<td class="tbYellow2" >
					<select name="INSU_NOTE2" id="INSU_NOTE2" class="textBox2" fieldName = "新優惠同意">
						<option value="">請選擇</option>
						<c:forEach items="${INSU_NOTE_List}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>	
				<td class="tbYellow" align="left" >
					新建物用途
				</td>
				<td class="tbYellow2" >
					<select name="BUILD_USE2" id="BUILD_USE2" class="textBox2" fieldName = "新建物用途">
						
						<c:forEach items="${BUILD_USE_List}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>	
				<td class="tbYellow" align="left" >
					新保優起日等級
				</td>
				<td class="tbYellow2" >
					<input id="BEGIN_DATE2"  name = "BEGIN_DATE2" type="text" class="textBox2" fieldName = "新保優起日" size = "10" readOnly />
					<input id="INSU_PRANK2"  name = "INSU_PRANK2" type="text" class="textBox2" fieldName = "新保優等級" size = "2" readOnly value = "0" />
				</td>	
			</tr>
			</tbody>
		</table>		
	</form>	
</body>
</html>