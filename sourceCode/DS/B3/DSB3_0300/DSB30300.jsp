
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB30300.jsp
作者：王文進
功能：火險退件輸入作業。
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
var DSB30300 = new DSB30300();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB30300.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB30300(){
	//查詢的檢核
	var valid1;
	var grid;		
	//前次查詢條件
	var queryCondition = {APPLY_ID : ""};
				
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0068:"btn_reject"<%--退件--%> 
		};
		
		<dz:grantButtons FUNC_ID="DSB30300" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([	
		[ 'validateAPPLY_ID',  '受理編號長度不正確 需為11碼', 
			function(v){				
				return (v.length != 11 && v.length != 10 ) ? false : true ;   
			} ]
		]);
		//查詢用檢核
		valid1 = new Validation("form1", {mode:'validator', useTitles:true, focusOnError:false, immediate:false});	
		valid1.define( "validateAPPLY_ID" , { id: "APPLY_ID" } );		
	}
	
	function initList(node) {
       <c:forEach var="map" items="${REJECT_REASON_LIST}">
			var elOptNew = document.createElement('option');
			elOptNew.text =  '${map.value}';
			elOptNew.value = '${map.key}';
			node.add(elOptNew);
       </c:forEach>
	}
	
	function initList1(node) {
       <c:forEach var="map" items="${FIREINSU_COMPANY_LIST}">
			var elOptNew = document.createElement('option');
			elOptNew.text =  '${map.value}';
			elOptNew.value = '${map.key}';
			node.add(elOptNew);
       </c:forEach>
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB3_0300/" + actionName,
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
		
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
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
					grid.load(resp.rtnList);					
				},
				function(resp){					
					//失敗把前次內容清掉 並把鑑價,支援人員list清掉
					grid.load([]);				
				}
			);		
		},		
		
		
		//退件
		doReject : function(event){	
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			
			var checkrejectList = grid.getCheckedRecord();
			if(!checkrejectList.length >0){
				alert("請先勾選欲退件資料，才能作業!!");
				return;
			}
			
			//將條件Map存起來
			var rejectRecord = makeEditRecord(checkrejectList); 
			//發送ajax
			ajaxPost( 'reject' , 
			{
				rejectRecord : Object.toJSON(rejectRecord), //畫面勾選的records
				sendRecord : Object.toJSON(queryCondition) //上次查詢的條件		
			},
				function(resp){			
					//重查,並紀錄新的List			
					grid.load(resp.rtnList);					
				}
			);	
		}
	}
	
	//將畫面資料存成要派件或轉移的List
	function makeEditRecord(list){
		var editList = [];
		for(var i = 0 ; i < list.length ; i++){
			var tempMap = {};
			tempMap["APPLY_ID"] = list[i]["APPLY_ID"];
			tempMap["SEQ_NO"] = list[i]["SEQ_NO"];
			tempMap["LOAN_ID"] = list[i]["LOAN_ID"];
			tempMap["FIREINSU_COMPANY"] = list[i]["FIREINSU_COMPANY"];
			tempMap["REJECT_REASON"] = list[i]["REJECT_REASON"];
			tempMap["REJECT_MEMO"] = list[i]["REJECT_MEMO"];
			editList.push(tempMap);
		}
		return editList;
	}
	
	//將畫面A資料存成Record
	function makeRecord(){
		var sendRecord = {	
			APPLY_ID	: $('APPLY_ID').value //受理編號			
		}
		return sendRecord;	
	}

	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSB30300", "火險作業", "火險退件輸入作業", 0);

				grid = new TableUI ( {
					table: $("grid"), pageSize: 10, allSortable:true,
					autoCheckBox:{					
						isSelectAll:true
					},
					<%-- [20240613] 難字調整 --%>
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{header: "序號",key: "SEQ_NO",
							render : function(rec , val){
								var alink = document.createElement("a");
								alink.href = "#";
								alink.innerHTML = val ? val : '';
								alink.onclick = function(){
				                 	var LP_JSON = {
										action:'<%=dispatcher%>/DSB3_0201/prompt',							
										LINK_FROM:'DSB30300', 
										APPLY_ID:rec.APPLY_ID, 
										SEQ_NO:rec.SEQ_NO,
										LOAN_ID:rec.LOAN_ID
									};
									CSRUtil.linkTo(LP_JSON, 'form1');
								};
								return alink;
							}
						},						
						<%-- [20240613] 難字調整：借款人 --%>
						{header: "借款人 ",key: "BORROW_NAME",attrs:{ style:"font-family:'EUDC'" },
							render : function(rec , val){
								return 	val ? val : "";														
							}
						},						
						{header: "總保費(元)",key: "PAYMENT", sortRule:'number',
							render : function(rec , val){
								var v0 = val ? val : "0";;
								return CSRUtil.$fmt(v0, "#,##0");  													
							}
						},						
						{header: "火險年期",key: "FIREINSU_YY",
							render : function(rec , val){
								var v1 = rec.FIREINSU_YY ? rec.FIREINSU_YY : "";
								var v2 = rec.FIREINSU_MM ? rec.FIREINSU_MM : "";
								return 	v1+'年'+v2+'月';														
							}
						},						
						{header: "出單狀況",key: "ISSUE_CODE_NM",
							render : function(rec , val){
								return 	val ? val : "";														
							}
						},												
						{header: "退件原因",key: "REJECT_REASON",
		                	input:{
								type:'select',
		                		actionWhenStart:true,
								action : function( node , dataObj , textDiv, record,isOnChange){
									if(!isOnChange){
										
										var elOptNew = document.createElement('option');
										elOptNew.text = '請選擇';
										elOptNew.value = '';
									    var elOptOld = node.options[0];  
									    node.add(elOptNew, 0);
								        initList(node);
										//設定預設值
										if(!dataObj[0]['REJECT_REASON']) {
											//node.value = "";
										}else {
											node.value = dataObj[0]['REJECT_REASON'];
										}
									}
									dataObj[0]["REJECT_REASON"] = (node.value ? node.value : "");
								},
	                            genRule:function(record , value){
	                                return true;
	                            }
		                	}
						},
						{ header: "原因說明", key: "REJECT_MEMO",
							input:{
								type:'TEXT', size:26, maxlength:70,
								genRule:function(record, value){
									return true;
								},									
								action:function( node , dataObj , textDiv, orgData , isOnChange ){
									if(!isOnChange){
										node.setAttribute("className" , "checkInputLength");
										node.setAttribute("fieldName" , "原因說明");
									}
								}, actionWhenStart:true
							}
						},
						{header: "轉投保公司",key: "FIREINSU_COMPANY",
		                	input:{
								type:'select',
		                		actionWhenStart:true,
								action : function( node , dataObj , textDiv, record,isOnChange){
									if(!isOnChange){
										
										var elOptNew = document.createElement('option');
										elOptNew.text = '請選擇';
										elOptNew.value = '';
									    var elOptOld = node.options[0];  
									    node.add(elOptNew, 0);
								        initList1(node);
										//設定預設值
										if(!dataObj[0]['FIREINSU_COMPANY']) {
											//node.value = "";
										}else {
											node.value = dataObj[0]['FIREINSU_COMPANY'];
										}
									}
									dataObj[0]["FIREINSU_COMPANY"] = (node.value ? node.value : "");
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
				$("btn_reject").observe("click", buttons.doReject );
				
				initValidation();	
				
				fix();

				displayMessage();				
						
				buttonAuth();
				
				var LP_JSON = CSRUtil.isBackLink('form1');
				if(LP_JSON){
					$('APPLY_ID').value = LP_JSON.APPLY_ID;
					buttons.doQuery();
				}
			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" width="20%" align="left" >
				受理編號
			</td>
			<td class="tbYellow2" width = "50%">
				<input id="APPLY_ID" type="text" class="text2" size="12" maxlength="11" class="textBox" />				
			</td>
			<td class="tbYellow2"  align = "center">
				<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
			</td>
		</tr>
		<tr>
			<td colspan = "3" align = "center">
				<input id = "btn_reject" type = "button" class = "button" value = "退件"/>
			</td>
		</tr>
		</table>
		<table id='grid' width="100%"></table>		
	</form>	
</body>
</html>