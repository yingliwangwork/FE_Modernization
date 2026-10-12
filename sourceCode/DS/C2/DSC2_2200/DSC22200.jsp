<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC22200.jsp
功能：暫收款授權
作者：溫子
完成：2013/06/
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<%-- [20241104]難字 css --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		font-weight: normal;
		font-style: normal
	}
</style>
<script type='text/javascript'>

Event.observe(window, 'load', new DSC22200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC22200(){
var grid;
var DEPT='${dept}';
var QUERY_QUERY_TYPE;
var Query_reqMap;
var legal2;//紀錄按鈕授權
	function initValidation(){	
		Validation.addAllThese([
			[ 'validateLOAN_ID_10',  '貸款帳號長度不正確 需為10碼',
				function(v){				
					return (v.length != 10) ? false : true ;
				}
			]
		]);
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define('validate-selection' , [{ id : "QUERY_TYPE" , errMsg:"請選擇查詢種類"}] );
		//valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		//valid2.define('validateLOAN_ID_10' , [{ id : "LOAN_ID" }] );
		valid3 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		valid3.define('validate-digits' , [{ id : "BALC_AMT" , errMsg:"必須為數字格式"}] );
	}
	// 按鈕權限
		function buttonAuth(){
			var authButtons = {
				B0028:'confirm',
				B0009:'cancel'		
			};
			<dz:grantButtons FUNC_ID="DSC22200"  ignored='false'/>  
			legal2=legal;
		}
//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_2200/" + actionName,
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
var buttons = {
	
	doQuery : function (){
		valid1.reset();
		if(!valid1.validate()){
			return;
		}
		if($F('BALC_AMT')&&!valid3.validate()){
			return;
		}
		Query_reqMap ={
			QUERY_TYPE : $F('QUERY_TYPE')
			,INPUT_DEPT : $F('INPUT_DEPT')
			,LOAN_ID : $F('LOAN_ID')
			,BALC_AMT :$F('BALC_AMT')
		}
		QUERY_QUERY_TYPE=$F('QUERY_TYPE');
		ajaxPost( 'query', {reqMap : Object.toJSON(Query_reqMap)}
					,function(resp){
					var rtnList=resp.rtnList;
					
					for(var i=0;i<rtnList.length;i++){
						rtnList[i]['COUNT']=i+1;
					}
						grid.load(resp.rtnList);
					},function(resp){
						grid.load([])
					}
		);
	}
	,doConfirm : function(rec){
		if(QUERY_QUERY_TYPE!=$F('QUERY_TYPE')){
			alert('查詢種類與查詢時不一樣，請重新查詢');
			return;
		}
		var reqMap ={
			DEPT : DEPT
			,BALC_NO : rec.BALC_NO
			,INPUT_ID : rec.INPUT_ID
			,AUTHED_DEPT :rec.AUTHED_DEPT
			,AUTHED_GROUP : rec.AUTHED_GROUP
			,QUERY_TYPE : QUERY_QUERY_TYPE
			,INPUT_DEPT : $F('INPUT_DEPT')
		}
		
		ajaxPost( 'confirm', {reqMap : Object.toJSON(reqMap) ,Query_reqMap:Object.toJSON(Query_reqMap)}
					,function(resp){
					var rtnList=resp.rtnList||[];
					for(var i=0;i<rtnList.length;i++){
						rtnList[i]['COUNT']=++i;
					}
						grid.load(resp.rtnList);
					}
		);
	}
	,doCancel : function(rec){
		if(QUERY_QUERY_TYPE!=$F('QUERY_TYPE')){
			alert('查詢種類與查詢時不一樣，請重新查詢');
			return;
		}
		var reqMap ={
				DEPT : DEPT
				,BALC_NO : rec.BALC_NO
				,QUERY_TYPE : QUERY_QUERY_TYPE
				,INPUT_DEPT : $F('INPUT_DEPT')
		}
		ajaxPost( 'cancel', {reqMap : Object.toJSON(reqMap) ,Query_reqMap:Object.toJSON(Query_reqMap)}
					,function(resp){
					var rtnList=resp.rtnList||[];
					for(var i=0;i<rtnList.length;i++){
						rtnList[i]['COUNT']=++i;
					}
						grid.load(resp.rtnList);
					}
		);
	}
}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC22200', '收息帳務', '暫收款授權');
								grid = new TableUI(
				{table: $("grid"), pageSize : 10, allSortable: false, overDiv:true,split: ['BALC_AMT'],
				column:[			
					{header:"筆數", key:"COUNT"},
					{header:"暫應收編號",key:"BALC_NO"},
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"期數",key:"PAY_TERM",
						render : function(rec ,val ){
								return val ? val : 0;
						}
					},
					{header:"繳別",key:"PAY_KIND_NM"},
					{header:"序號",key:"SEQ_NO",
						render : function(rec ,val ){
								return val ? val : 0;
						}
					},
					{header:"實繳日",key:"REAL_PAYDT",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					},
					{header:"繳款方式",key:"PAY_TYPE_NM"},
					{header:"票況",key:"CHECK_STATUS_NM"},
					{header:"授權組別",key:"AUTHED_GROUP",
						render : function(rec ,val ){
							 var span = new Element('span');
							 var select1 = new Element("select",{id: 'AUTH_GROUP'});
							 select1.add(new Option('',''));
							 <c:forEach var="map" items='${AUTH_GROUP_LIST}'>
								select1.add(new Option("${map.value}","${map.key}"));
							</c:forEach>
							select1.value=val;
							
							select1.observe('change', function(event){
								var tr=this.up('tr');
								dataObj = tr.getAttribute("dataObj")|| grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
								dataObj.AUTHED_GROUP=this.value;
							});	
							span.insert(select1);							
							return span;	
				
						} 
					},
					{header:"沖帳單位",key:"AUTHED_DEPT",
						render : function(rec ,val ){
							var span = new Element('span');
							var input1 = new Element("input" , {type : 'text'  , className : 'textbox2' ,id:'AUTH_DEPT' , maxlength:'7'} );
							if(DEPT == 3){
							
								input1.setAttribute('readOnly','readonly');
								input1.value='${INPUT_DEPT}';
							}else{
							
								input1.value=val;
							}
							input1.observe('change', function(event){
								var tr=this.up('tr');
								dataObj = tr.getAttribute("dataObj")|| grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
								dataObj.AUTHED_DEPT=this.value;
								
							});	
							
							span.insert(input1);
							return span;
						}
							
					},
					{header:"暫應收金額",key:"BALC_AMT",
						render : function(rec ,val ){
								return MoneyFormat(val) || '';
						}
					},
					{header:"剩餘金額",key:"REMAIN_AMT",
						render : function(rec ,val ){
								return MoneyFormat(val) || '';
						}
					},
					{header:"原因",key:"BALC_REASON_NM",attrs:{colSpan:2}, renderInCount : true},
					{header:"備註",key:"BALC_MEMO",attrs:{colSpan:2}, renderInCount : true},
					{header:"單位刪除人",key:"DELT_NAME"},
					{header:"輸入人員",key:"INPUT_NAME"},
					{header:"輸入日期",key:"INPUT_DATE",
						render : function(rec ,val ){
								return Date.toROC(val)||'';
						}
					},
					{header:"確認",key:"CONFIRM",
						render : function(rec ,val ){
						
							if(rec.SHOW_CONFIRM==true){
									var check = new Element("input" , {type : 'button' , value : '確認' , className : 'button' ,id:'confirm'} );
										check.observe("click",function(event){
										var tr=this.up('tr');
										dataObj = tr.getAttribute("dataObj")|| grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										
										buttons.doConfirm(dataObj)});//不傳rec  因為input欄位會變動  button所載入的是一開始的rec
										if(legal2.indexOf('B0028')==-1){
											check.disable();
										}
										var span = new Element('span');
										span.insert(check);
										
									 return span; 
								}else{
									return '';
								}
						}

					
					},
					{header:"取消",key:"CANCEL",
						render : function(rec ,val ){
							if(rec.SHOW_CANCEL==true){
								var check = new Element("input" , {type : 'button' , value : '取消' , className : 'button' ,id:'cancel'} );
									check.observe("click",function(event){
									var tr=this.up('tr');
									dataObj = tr.getAttribute("dataObj")|| grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									
									buttons.doCancel(dataObj)});
									if(legal2.indexOf('B0009')==-1){
										check.disable();
									}
								 var span = new Element('span');
								 span.insert(check);

								 return span;   
							}else{
								return '';
							}
						}
					}
				]
				});
				if('${INPUT_DEPT}'!='${HO_DIV_NO}'){
					$('INPUT_DEPT').readOnly=true;
				}
				buttonAuth();
				autoFormatToNumber();
				initValidation();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
			}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="12%">查詢種類</td>
			<td class="tbYellow2" width="4%">
				<select id="QUERY_TYPE">
						<!--<option value="">請選擇</option>  -->
							<c:forEach var="map" items="${QUERY_TYPE_LIST}">
									<option value="${map.key}">${map.value}</option>
							</c:forEach>
				</select> 
			</td>
			<td class="tbYellow" width="12%">單位代號</td>
			<td class="tbYellow2" width="4%">
			<input id="INPUT_DEPT" type="text" class="textBox2" value='${INPUT_DEPT}' />
			</td>
			<td class="tbYellow" width="12%">貸款帳號</td>
			<td class="tbYellow2" width="4%">
			<input id="LOAN_ID" type="text" class="textBox2" maxlength="11"  value='${LOAN_ID}' onblur="this.value = this.value.toUpperCase()" />
			</td>
			<td class="tbYellow" width="12%">金額</td>
			<td class="tbYellow2" width="4%">
			<input id="BALC_AMT" type="text" class="textBox2"/>
			</td>
			<td class="tbYellow2">
			<input id="BTN_QUERY" type="button" value="查詢" class="button"> 
		</tr>
		
	</table>
	<table id = "grid" ></table>
	
</form>
</body>
</html>