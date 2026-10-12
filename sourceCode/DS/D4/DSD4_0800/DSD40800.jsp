<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSD4_0800.java
作者：陳思涵 
功能：清償備註修正作業
完成：2013-09-06	

[20240328]
難字調整
高強禾
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script><!-- 必要 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script><!-- 必要 -->

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script><!-- 檢核訊息的顯示 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script><!-- 目前畫面的版面設定 -->
<%-- [20240328] 難字調整 --%>
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
Event.observe(window, 'load', new DSD40800().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


function DSD40800(){

	var valid1;
	var queryLOAN_ID;

	// 按鈕權限
	var buttonAuth = function(){
		var authButtons = {
			B0003 : 'btn_insert',		<%--新增--%>	
			B0004 : 'btn_update'		<%--修改--%>		
		};
		<dz:grantButtons FUNC_ID='DSD40800' ignored="false"/>
	};

	function  initValidation(){
		Validation.addAllThese([
			[ 'check_query',  '請先查詢再執行新增作業' ,function(v,elm) {
					if(Validation.get('IsEmpty').test(queryLOAN_ID) || queryLOAN_ID != $F('LOAN_ID_input') ){
						return false;
					}else{
						return true;
					}
			}]
		]);
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
	}		



	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD4_0800/" + actionName,
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
	}//END   共用AJAX

	function showdata(rtnMap, isClear){
		$$('#table2 span').each(
			function(ele){
				var id = ele.id;
				if (isClear){
					ele.update('');
				}else{
					if(id =='INPUT_DATE'){
						ele.update(Date.toROC(rtnMap[id]) || '');
					}else{
						ele.update(rtnMap[id] || '');
					}
				}
			});
		if (isClear){
			$('NOTE').update('');	
		}else{
			$('NOTE').update(rtnMap['NOTE'] || '');	
		}
	}


	var buttons = {
		//查詢
		doQuery : function(event){
			valid1.reset();
			valid1.clear();
			valid1.define("required", { id: "LOAN_ID_input" , errMsg: "請輸入貸款帳號再執行查詢作業"} );
			
			// 檢核
			if(!valid1.validate()){ 
				return; 
			}
			
			var LOAN_ID = $F('LOAN_ID_input');
			
			ajaxPost( 'query' , { 'LOAN_ID' : LOAN_ID},
				function(resp){			
					
					var rtnMap = resp.rtnMap || {};
					
					showdata(rtnMap, false);
				},
				function(resp){
					showdata({}, false);
					$('LOAN_ID').update(LOAN_ID);
				}
			);	
			
			queryLOAN_ID = LOAN_ID;
			
		},
		
		//新增
		doInsert : function(event){
			valid1.reset();
			valid1.clear();
			valid1.define("check_query", { id: "LOAN_ID_input" } );
		
			// 檢核
			if(!valid1.validate()){ 
				return; 
			}
			
			if(!confirm("確定要執行新增作業？")){
				return;
			}
			
			var reqMap = {
				LOAN_ID : $('LOAN_ID').innerHTML,
				NOTE : $F('NOTE')
			}
			
			ajaxPost( 'insert' , { 'reqMap' : Object.toJSON(reqMap) },
				function(resp){			
					var rtnMap = resp.rtnMap || {};
					
					showdata(rtnMap, false);
										
					queryLOAN_ID = rtnMap['LOAN_ID'];
				}
			);	
		
		},
		
		//修改
		doUpdate : function(evnent){
			valid1.reset();
			valid1.clear();
			valid1.define("check_query", { id: "LOAN_ID_input" } );
		
			// 檢核
			if(!valid1.validate()){ 
				return; 
			}
			
			if(!confirm("確定要執行修改作業？")){
				return;
			}
			
			var reqMap = {
				LOAN_ID : $('LOAN_ID').innerHTML,
				NOTE : $F('NOTE')
			}
			
			ajaxPost( 'update' , { 'reqMap' : Object.toJSON(reqMap)},
				function(resp){			
					var rtnMap = resp.rtnMap || {};
					
					showdata(rtnMap, false);
										
					queryLOAN_ID = rtnMap['LOAN_ID'];
				}
			);	
		
		
		}
	};


	
	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSD40800', '清償作業', '清償備註修正');
	
			initValidation();
			buttonAuth();
			
			$('LOAN_ID_input').observe('blur', function(){
				this.value = this.value.toUpperCase();
			})
							
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_insert').observe('click', buttons.doInsert);
			$('btn_update').observe('click', buttons.doUpdate);
			
			
			PageUI.resize();			
			displayMessage();			
		}
	};
	

}

</script>
</head>
<body>

<form name="form1" id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id="table1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="15%">貸款帳號</td>
			<td class="tbYellow2">
				<input id="LOAN_ID_input" type="text" class="textBox2" size='13' maxlength='11'  />
			</td>
			<td class="tbYellow2" width="10%" align="center">
				<input id="btn_query" type="button" class="button" value="查詢"/>
			</td>
		</tr>
		<tr>
			<td colspan="3" align="center">
				<input id="btn_insert" type="button" class="button" value="新增"/>
				<input id="btn_update" type="button" class="button" value="修改"/>
			</td>
		</tr>
	</table>
</form>	
<form name="form2" id="form2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id="table2" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="15%">貸款帳號</td>
			<td class="tbYellow2" >
				<span id="LOAN_ID"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">備註</td>
			<td class="tbYellow2">
				<textarea id="NOTE" rows="5" cols="35"></textarea>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">確認人員</td>
			<td class="tbYellow2" >
				<%-- [20240328] 難字調整：確認人員 --%>
				<span id="INPUT_ID_NAME" style="font-family:'EUDC'"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">確認日期</td>
			<td class="tbYellow2"  >
				<span id="INPUT_DATE"></span>
			</td>
		</tr>
	</table>
</form>	

</body>
</html>