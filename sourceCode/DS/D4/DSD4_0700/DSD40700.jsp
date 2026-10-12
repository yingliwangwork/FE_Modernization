<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!--
程式：DSD4_0700.java
作者：陳思涵 
功能：清償案件查詢作業
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
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src="<%=htmlBase%>/CM/js/prototype.js"></script><!-- 必要 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script><!-- 必要 -->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script><!-- 檢核訊息的顯示 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script><!-- 目前畫面的版面設定 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script><!-- 目前系統常用的表格工具 -->
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
Event.observe(window, 'load', new DSD40700().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD40700(){
	var grid;
	var valid1;
	function  initValidation(){
			Validation.addAllThese([
				[ 'check1',  '貸款帳號.借款人ID.借款人姓名請至少輸入一欄再執行查詢作業',function(v,elm) {
						if(Validation.get('IsEmpty').test(v) && Validation.get('IsEmpty').test($F('BORROW_ID'))&&Validation.get('IsEmpty').test($F('BORROW_NAME'))){
							return false;
						}else{
							return true;
						}
				}],
				[ 'check2',  '承辦科別.貸款帳號.借款人ID.借款人姓名請至少輸入一欄再執行查詢作業',function(v,elm) {
						if(Validation.get('IsEmpty').test(v) && Validation.get('IsEmpty').test($F('LOAN_ID')) && Validation.get('IsEmpty').test($F('BORROW_ID'))&&Validation.get('IsEmpty').test($F('BORROW_NAME'))){
							return false;
						}else{
							return true;
						}
				}],
				[ 'chkLength', '貸款帳號長度需為10碼!', function( v ) { return chkLength($F('LOAN_ID'));}],
				[ 'chkLength2', '借款人ID長度需為10碼!', function( v ) { return chkLength($F('BORROW_ID'));}]
			]);
		 	valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
	}	
	
	// 檢核帳號長度
	var chkLength = function (ID) 
	{		
		var chk = true;
		if(ID && ID.length != 10) {
			chk = false; 
		}
		return chk; 	
	};
		
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD4_0700/" + actionName,
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
	
	function valid(CRED_DEPT){
		valid1.reset();
		valid1.clear();
		
		if(CRED_DEPT){
			valid1.define("check1", { id: "LOAN_ID" } );
		}else{
			valid1.define("check2", { id: "CRED_DEPT_LIST" } );
		}
		
		valid1.define( "chkLength" , [{ id : "LOAN_ID" } ] );
		valid1.define( "chkLength2" , [{ id : "BORROW_ID" } ] );
	}
	
	var buttons = {
		//查詢
		doQuery : function(event){
						
			valid($F('CRED_DEPT_LIST'));
			if(!valid1.validate()){
				return;
			}
					
			var reqMap = {
				CRED_DEPT : $F('CRED_DEPT_LIST'),
				LOAN_ID : $F('LOAN_ID'),
				BORROW_ID : $F('BORROW_ID'),
				BORROW_NAME : $F('BORROW_NAME')
			};
			
			ajaxPost('query' , { reqMap : Object.toJSON(reqMap) },
				function(resp){
					
					grid.load(resp.rtnList || []);
				},function(){
					grid.load();
				}
			);
		}
	};
	
	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSD40700', '清償作業', '清償案件查詢');
	
			initValidation();
	
			$w('LOAN_ID BORROW_ID').each(
				function(id){
					$(id).observe('blur', function(){
						this.value = this.value.toUpperCase();
					})
				});
				
			$('btn_query').observe('click', buttons.doQuery);
			
			grid = new TableUI({
				table: $('grid'),
            	pageSize: 10, 
            	<%-- [20240328] 難字調整 --%>
            	afterLoad: function() {
            		if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
            	},
            	pageChange: function() {
            		if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
            	},
				column:[					
					{header: "貸款帳號",key: "LOAN_ID"},						
					{header: "借款人ID",key: "BORROW_ID",
						render : function (rec , val){
							return CSRUtil.maskHandler.getMaskID(val);
					}},							
					<%-- [20240328] 難字調整：姓名 --%>
					{header: "姓名",key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},		
					{header: "契約狀況",key: "LOAN_STATUS_NM",
						render : function (rec , val){
							if (rec.LOAN_STATUS == '13' || rec.LOAN_STATUS == '14'){
								//13 清償有暫收 
								//14 清償有未兌票
								//以紅字顯示
								return "<font color='red'>" + val + "</font>";
							}else{
								return val;
							}
					}},						
					{header: "通訊處清償處理",key: "A", render: function(rec , val){
							var link = new Element('a', { href : "#"}).update("附件一");
							link.observe('click',function(event){
								CSRUtil.linkTo({
									action : "<%=dispatcher%>/DSD4_0100/prompt",
									LOAN_ID : rec.LOAN_ID,
									ACTION_TYPE : "Q"
								}, 'form1');
							});
							return link;	
					}},
					{header: "清償件受理審核",key: "B", render: function(rec , val){
							var link = new Element('a', { href : "#"}).update("附件二");
							link.observe('click',function(event){
								CSRUtil.linkTo({
									action : "<%=dispatcher%>/DSD4_0110/prompt",
									LOAN_ID : rec.LOAN_ID,
									ACTION_TYPE : "Q"
								}, 'form1');
							});
							return link;	
					}},
					{header: "清償證明預覽",key: "C", render: function(rec , val){
							var link = new Element('a', { href : "#"}).update("附件三");
							link.observe('click',function(event){
								CSRUtil.linkTo({
									action : "<%=dispatcher%>/DSD4_0120/prompt",
									LOAN_ID : rec.LOAN_ID	
								}, 'form1');
							});
						return link;	
					}}
					]
				});			
	
	
			PageUI.resize();			
			displayMessage();
			
			if(CSRUtil.isBackLink('form1')){    
				buttons.doQuery();  
			}	
		}
	};
			

}

</script>
</head>
<body>
<form name="form1" id="form1" style="PADDING: 0px; MARGIN: 0px;">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow">承辦科別</td>
			<td class="tbYellow2"  >
				<select id="CRED_DEPT_LIST" name="CRED_DEPT_LIST">
						<option value="">請選擇</option>
			       	<c:forEach var="map" items="${CRED_DEPT_LIST}">
						<option value="${map.key}">${map.value}</option>
			       	</c:forEach>
				</select>			
			</td>
			<td class="tbYellow">貸款帳號</td>
			<td class="tbYellow2"  >
				<input id="LOAN_ID" name="LOAN_ID" type="text" class="textBox2" size='12' maxlength='10'  />
			</td>
			<td class="tbYellow">借款人ID</td>
			<td class="tbYellow2"  >
				<input id="BORROW_ID" name="BORROW_ID" type="text" class="textBox2" size='12' maxlength='10'  />
			</td>
			<td class="tbYellow">借款人姓名</td>
			<td class="tbYellow2"  >
				<%-- [20240328] 難字調整：借款人姓名 --%>
				<input id="BORROW_NAME" name="BORROW_NAME" type="text" class="textBox2" size="12" alt="ch" />
			</td>
			
			<td class="tbYellow2" width='8%' align='center'>
				<input id="btn_query" type="button" class="button" value="查詢"/>
			</td>
		</tr>
	</table>
	<table id="grid" class="grid"></table>
</form>	
</body>
</html>