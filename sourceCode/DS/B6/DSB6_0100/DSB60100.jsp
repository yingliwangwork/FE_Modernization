<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB60100.jsp
作者：王文進
功能：一般查詢試算。
完成：2012/05/30
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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>

<script type='text/javascript'>

// 產生畫面物件
var DSB60100 = new DSB60100();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB60100.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB60100(){
	
	var defaultRecs = [{},{},{},{},{}];
	var grid;
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			
		};
		
		<dz:grantButtons FUNC_ID="DSB60100" ignored="false"/>
	}
	
	//檢核變數
	var valid1;	
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'checkDate',  '請輸入切轉日期!',
				function(v){
					return 	v.length==0 ? false : true;
				}
			],
			//[ 'checkTURN_DATE',  '切轉日期要大於等於當天!',
			//	function(v){
			//		return 	diffDayROC($F('TURN_DATE'),'${TURN_DATE}') > 0 ? false : true;
			//	}
			//],
			[ 'checkAPPLY_ID',  '請輸入正確受理編號!',
				function(v){
					return 	v.length!=0 && v.length!=11 ? false : true;
				}
			],
			[ 'checkLOAN_ID',  '請輸入正確貸款帳號!',
				function(v){
					return 	v.length!=0 && v.length!=10 ? false : true;
				}
			]
		]);
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
	}    

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB6_0100/" + actionName,
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
		
		//試算資料
		doLinkToDSB60200 : function(event){	
			
			valid1.reset();
			if(!valid1.validate()){
				return;			
			}
			
			var tmpList = grid.getAllRecords(['APPLY_ID']);
			var APPLY_LIST = [];
			for(var i=0;i<tmpList.length;i++){
				var map = tmpList[i];
				var APPLY_ID = map.APPLY_ID ? map.APPLY_ID.replace(/\s/g,"") : '';
				if(APPLY_ID){
					APPLY_LIST.push(map);
				}
			}

			if(APPLY_LIST.length==0){
				return alert("請輸入新件受理編號!");
			}
			
			var tmpList2 = grid.getAllRecords(['LOAN_ID']);
			var LOAN_LIST = [];
			var isMm = false;
			for(var i=0;i<tmpList2.length;i++){
				var map = tmpList2[i];
				var LOAN_ID = map.LOAN_ID ? map.LOAN_ID.replace(/\s/g,"") : '';
				if(LOAN_ID){
					map.LOAN_ID = LOAN_ID;
					LOAN_LIST.push(map);
					if(LOAN_ID.substring(9,10) == 'X' && diffDayROC($F('TURN_DATE'),'${TURN_DATE}') != 0){
						isMm = true;
					}
				}
			}
			
			if (isMm) {
				return alert("舊件貸款帳號有設定理財型帳號，切轉日期僅能設定當日");
			}
			if(LOAN_LIST.length==0){
				return alert("請輸入舊件貸款帳號!");
			}
			
			var LP_JSON = {
				action: '<%=dispatcher%>/DSB6_0200/prompt', // URL
				TURN_DATE:toY2K($('TURN_DATE').value),
				APPLY_LIST:APPLY_LIST,
				LOAN_LIST:LOAN_LIST
			};	
						
			CSRUtil.linkTo(LP_JSON, 'form1');
	
		},
		
		//新增一筆資料
		doInsertRow : function(event){	
			defaultRecs.push({});
			grid.load(defaultRecs);
			PageUI.resize(true);
		}

	};
	
	return {

			initApp : function() {		
				//PageUI.createPageWithAllBodySubElement("DSB60100", "借新還舊", "一般查詢試算", 1);
				PageUI.createPage("DSB60100", "借新還舊", "一般查詢試算");
				PageUI.loadin(["tableA","grid","tableB"] ,1);
					
				grid = new TableUI ( {
						table:$("grid"), allSortable:true , pageSize: 10, overDiv:false,
						column:[
							{header: "新件受理編號",key: "APPLY_ID",
								input:{
									type:'TEXT',
									size:13,
									maxLength:11,
									genRule:function(rec , val){
										return true;
									},
									action:function( node , dataObj , textDiv, orgData , isOnChange ){
										if(!isOnChange){
											node.id = 'APPLY_ID'; 
											node.maxLength = 11; 
											node.setAttribute("className" , "checkInputLength checkAPPLY_ID");
										}
										node.value = node.value.toUpperCase();
										dataObj[0]["APPLY_ID"] = (node.value ? node.value : "");
									}, actionWhenStart:true
								}							
							},
							{header: "舊件貸款帳號",key: "LOAN_ID",
								input:{
									type:'TEXT',
									size:12,
									maxLength:10,
									genRule:function(rec , val){
										return true;
									},
									action:function( node , dataObj , textDiv, orgData , isOnChange ){
										if(!isOnChange){
											node.id = 'LOAN_ID'; 
											node.maxLength = 10; 
											node.setAttribute("className" , "checkInputLength checkLOAN_ID");
										}
										node.value = node.value.toUpperCase();
										dataObj[0]["LOAN_ID"] = (node.value ? node.value : "");
									}, actionWhenStart:true
								}							
							}
						]
					});
			
				//註冊DOM物件
				//click事件
				$("btn_linkToDSB60200").observe("click", buttons.doLinkToDSB60200 );
				$("btn_insert").observe("click", buttons.doInsertRow );
				
				initValidation();	
				
				fix();

				displayMessage();	
				
				buttonAuth();
				
				var LP_JSON = CSRUtil.isBackLink('form1');
				if(LP_JSON){
					var APPLY_LIST = LP_JSON.APPLY_LIST ? LP_JSON.APPLY_LIST : [];
					var LOAN_LIST = LP_JSON.LOAN_LIST ? LP_JSON.LOAN_LIST : [];
					var size = 5;
					if(APPLY_LIST.size()>LOAN_LIST.size()){
						if(APPLY_LIST.size()>size){
							size = APPLY_LIST.size();
						}
					}else{
						if(LOAN_LIST.size()>size){
							size = LOAN_LIST.size();
						}					
					}
					defaultRecs = [];
					for(i=0 ; i < size ; i++){
						var APPLY_ID = APPLY_LIST[i] && APPLY_LIST[i].APPLY_ID ? APPLY_LIST[i].APPLY_ID : '';
						var LOAN_ID = LOAN_LIST[i] && LOAN_LIST[i].LOAN_ID ? LOAN_LIST[i].LOAN_ID : '';
						defaultRecs.push({'APPLY_ID':APPLY_ID,'LOAN_ID':LOAN_ID});
					}
				}
				
				grid.load(defaultRecs);

			}
	};	
};

</script>
</head>
<body>	
<form id="form1" name="form1">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='tableA'>
		<tr>
			<td class="tbYellow" width="12%">
				切轉日期
			</td>
			<td class="tbYellow2">
				<input name="TURN_DATE" id='TURN_DATE' type="text" class="textBox2 checkDate checkTURN_DATE validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${TURN_DATE}">
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('TURN_DATE'))">
			</td>
			<td class="tbYellow2">
				<input type="button" class="button" id="btn_linkToDSB60200" value="試算">
			</td>
		</tr>
	</table>
	<table id='grid' width="100%"></table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='tableB'>
		<tr>
			<td class="tbYellow2" align="center">
				<input type="button" class="button" value="新增一欄" id="btn_insert">
			</td>
		</tr>
	</table>
</form>
</body>
</html>