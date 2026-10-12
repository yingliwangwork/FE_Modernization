
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB30700.jsp
作者：王文進
功能：火險保險費作業。
完成：

[20240613]
難字調整
高強禾
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<%-- [20240613] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type='text/javascript'>

// 產生畫面物件
var DSB30700 = new DSB30700();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB30700.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB30700(){
	//查詢的檢核
	var valid1;
	var valid2;
	var grid1;
	var objMap;
	//前次查詢條件
	var queryCondition = {LOAN_ID : ""};
				
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0005:"btn_delete"<%--刪除--%>,
				B0099:"btn_rollback"<%--回復--%> 
		};
		
		<dz:grantButtons FUNC_ID="DSB30700" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){

	Validation.addAllThese([
			[ 'chkLOAN_ID',  '貸款帳號必須輸入', function(){ if($F('LOAN_ID') == ''){ return false; } return true; } ],
			[ 'validateLOAN_IDLength',  '貸款帳號長度不正確 需為10碼', 
			//檢核貸款帳號長度
			function(v){
				if(v!==""){
					return v.length === 10 ? true : false;
				}
				return true;
			}],
			[ 'chkEFFECT_DATE_STR',  '生效日期起必須輸入', function(){ if($F('EFFECT_DATE_STR') == '' && $F('EFFECT_DATE_END') != ''){ return false; } return true; } ],
			[ 'chkEFFECT_DATE_END',  '生效日期迄必須輸入', function(){ if($F('EFFECT_DATE_STR') != '' && $F('EFFECT_DATE_END') == ''){ return false; } return true; } ],
			[ 'chkSTR_AND_END', '生效日期起日不可大於迄日', function(){ if(diffDay($F('EFFECT_DATE_STR'),$F('EFFECT_DATE_END'), true) < 0){ return false; } return true; }],
			['chkRequired', '請輸入刪除理由，才能作業', function(v) {
						return !Validation.get('IsEmpty').test(v);
					}]
	]);

		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "chkLOAN_ID" , { id: "LOAN_ID" } );
		valid1.define( "validateLOAN_IDLength" , { id: "LOAN_ID" } );
		valid1.define( "chkEFFECT_DATE_STR" , { id: "EFFECT_DATE_STR" } );
		valid1.define( "chkEFFECT_DATE_END" , { id: "EFFECT_DATE_END" } );
		valid1.define( "chkSTR_AND_END" , { id: "EFFECT_DATE_END" } );
		
		valid2 = new Validation("form2", {useTitles:true,focusOnError:false,immediate:false});
		/*
		valid2.define( "checkTRANS_STATUS" , { id: "TRANS_STATUS" } );
		valid2.define( "checkREASON" , { id: "REASON" } );
		valid2.define( "checkMEMO" , { id: "MEMO" } );*/
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB3_0700/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {
		//查詢資料
		doQuery : function(event){
			
			$('LOAN_ID').value = $('LOAN_ID').value.toUpperCase();
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			//將畫面欄位存成record
			var sendRecord = makeRecord();	
			//將查詢條件存起來
			queryCondition = sendRecord;	
			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){	
					grid1.load(resp.rtnList);
					PageUI.resize(true);
				},
				function(resp){					
					//失敗把前次內容清掉 並把鑑價,支援人員list清掉
					grid1.load([]);
					PageUI.resize(true);
				}
			);		
		},		
		
		
		//刪除
		doDelete : function(event){	
			
			var checkdeleteList = grid1.getCheckedRecord();
			if(!checkdeleteList.length >0){
				alert("請先選取欲刪除資料，才能作業!!");
				return;
			}

			valid2.reset();
			if(!valid2.validate()){ 
				return; 
			}
			
			if(!confirm("確定要刪除該筆火險保險費資料？")){
				return;
			}

			if (checkdeleteList[0]['MM_CODE']) {
				alert('本件相關管理費用若有異動，將不再另行發送訊息通知客戶、經手人!');
			}
			
			//發送ajax
			ajaxPost( 'delete' , 
			{
				deleteRecord : Object.toJSON(objMap), //畫面勾選的records
				sendRecord : Object.toJSON(queryCondition) //上次查詢的條件		
			},
				function(resp){			
					//重查,並紀錄新的List			
					grid1.load(resp.rtnList);
					PageUI.resize(true);
				}
			);	
		},
		
		//回復
		doRollback : function(event){	
			
			var checkrollbackList = grid1.getCheckedRecord();
			if(!checkrollbackList.length >0){
				alert("請先選取欲回復資料，才能作業!!");
				return;
			}

			if (checkrollbackList[0]['MM_CODE']) {
				alert('本件相關管理費用若有異動，將不再另行發送訊息通知客戶、經手人!');
			}
			
			//發送ajax
			ajaxPost( 'rollback' , 
			{
				rollbackRecord : Object.toJSON(objMap), //畫面勾選的records
				sendRecord : Object.toJSON(queryCondition) //上次查詢的條件		
			},
				function(resp){			
					//重查,並紀錄新的List			
					grid1.load(resp.rtnList);
					PageUI.resize(true);
				}
			);	
		}
	}
	
	//將畫面A資料存成Record
	function makeRecord(){
		var sendRecord = {	
			LOAN_ID	: $('LOAN_ID').value.toUpperCase(), //貸款帳號
			EFFECT_DATE_STR	: toY2K($F('EFFECT_DATE_STR')), //生效日期起
			EFFECT_DATE_END	: toY2K($F('EFFECT_DATE_END')) //生效日期迄			
		}
		return sendRecord;	
	}
	
		/* 共用畫面設定 */
	function setViewData(rtnMap){
		objMap = rtnMap;
		$$('#grid1 td[name=DELETE_REASON] input').each(function(record){
			$(record.id).className = "textBox2";
		});
		$('DELETE_REASON_'+objMap.INDEX).className = "textBox2 chkRequired";
		grid1.resetDivHeight();  
		
	}

	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSB30700", "火險作業", "火險保險費作業", 1);
				PageUI.resize(true);

				grid1 = new TableUI ( {
					table: $("grid1"), pageSize: 10, allSortable:true,
					split: ['BORROW_NAME'],
					autoCheckBox:{ type: "radio",
						action: function (checkbox , boxStatus , records) {
							setViewData(records[0]);
						}
					},
					<%-- [20240613] 難字調整 --%>
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{header: "序號",key: "SER_NO", attrs:{rowSpan:2} ,
							render : function(rec , val){
								return 	val ? val : "";
							}
						},
						{header: "貸款帳號",key: "LOAN_ID",
							render : function(rec , val){
								return 	val ? val : "";
							}
						},						
						{header: "生效日期 ",key: "EFFECT_DATE", attrs:{rowSpan:2} ,
							render : function(rec , val){
								return val ? Date.toROC(val) : "";
							}
						},						
						{header: "費用原因",key: "EXPENSE_ITEM_NM",
							render : function(rec , val){
								return 	val ? val : "";
							}
						},						
						{header: "刪除與否",key: "DELETE_NM",
							render : function(rec , val){
								return 	val ? val : "";
							}
						},						
						<%-- [20240613] 難字調整：輸入人員、借款人姓名 --%>
						{header: "輸入人員",key: "INPUT_NAME", attrs:{rowSpan:2, style:"font-family:'EUDC'"},
							render : function(rec , val){
								return 	val ? val : "";														
							}
						},
						{header: "借款人姓名",key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" },
							render : function(rec , val){
								return 	val ? val : "";
							}
						},												
						{header: "費用金額",key: "EXPENSE_AMT",
							render : function(rec , val){
								return 	val ? CSRUtil.$fmt(val, "#,##0") : "";
							}
						},
						{header: "刪除理由",key: "DELETE_REASON",
		                	input:{
								type:'text',
								size:20,
								maxlength:50,
		                		actionWhenStart:true,
								action : function( node , dataObj , textDiv, record, isOnChange){
									if(!isOnChange){
										//設定預設值
										if(!dataObj[0]['DELETE_REASON']) {
											//node.value = "";
										}else {
											node.value = dataObj[0]['DELETE_REASON'];
										}
										node.id = 'DELETE_REASON_' + dataObj[0]['INDEX']; 
									}
									dataObj[0]["DELETE_REASON"] = (node.value ? node.value : "");
								},
	                            genRule:function(record , value){
	                                return true;
	                            }
		                	}
						}

					]
					
				});
				
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );
				$("btn_delete").observe("click", buttons.doDelete );
				$('btn_rollback').observe('click', buttons.doRollback);
				$('btn_clear').observe('click',function(event){
						$('form1').reset();
						grid1.load([]);
					}
				);
				
				
				initValidation();	
				
				fix();

				displayMessage();				
						
				buttonAuth();

			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" width="10%" align="left" >
				貸款帳號
			</td>
			<td class="tbYellow2" width = "20%">
				<input id="LOAN_ID" type="text" class="text2" size="12" maxlength="10" class="textBox" />				
			</td>
			<td class="tbYellow" width="10%" align="left" >
				生效日期
			</td>
			<td class="tbYellow2" width = "40%">
				<input name="EFFECT_DATE_STR" id='EFFECT_DATE_STR' type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${DATE_TODAY}">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('EFFECT_DATE_STR'))">
				~
				<input name="EFFECT_DATE_END" id='EFFECT_DATE_END' type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${DATE_TODAY}">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('EFFECT_DATE_END'))">
			</td>
			<td class="tbYellow2"  align = "center">
				<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
			</td>
		</tr>
		<tr>
			<td colspan = "5" align = "center">
				<input id = "btn_clear" type = "button" class = "button" value = "清除"/>
				<input id = "btn_delete" type = "button" class = "button" value = "刪除"/>
				<input id = "btn_rollback" type = "button" class = "button" value = "回復"/>
			</td>
		</tr>
	</table>
	</form>
	
	<form id="form2" name="form2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id='grid1' width="100%"></table>
	</form>
</body>
</html>