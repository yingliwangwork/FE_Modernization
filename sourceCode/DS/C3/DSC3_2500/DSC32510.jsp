<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC32510.jsp
作者：余凱鈞
功能：沖預繳-輸入確認作業
完成：2013/09/12
 -->	

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC32510().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC32510(){
	var grid;
	var grid2;
	
	//按鈕授權
	function buttonAuth(){
		var authButtons = {		
			B0210:"btn_CONFIRM",
			B0211:"btn_ACCOUNT",
			B0212:"btn_FORCE",
			B0213:"btn_INTEMP"
		};
		<dz:grantButtons FUNC_ID="DSC32510" />
	}
			
	var buttons = {	
		doConfirm : function(){ //沖預繳確認
		//超連結至DSC3_2501(沖預繳作業入帳結果)畫面，供使用者進行沖預繳正常件入帳
		
			var LP_JSON = {	
					action : '<%=dispatcher%>/DSC3_2501/prompt',
					'Action' : 'CONFIRM',
					washList : Object.toJSON(grid.getAllRecords()) //調整傳出參數
				};
			CSRUtil.linkTo(LP_JSON , 'form1');	
		},
		doAccount : function(){ //所有異常件借款人資料
		//超連結至DSC3_2502(沖預繳作業異常件帳戶資料)畫面，供使用者查詢異常件之帳戶明細資料
		
			var LP_JSON = {	
					action : '<%=dispatcher%>/DSC3_2502/prompt',
					rtnList2 : grid2.getAllRecords()
				};			
			CSRUtil.linkTo(LP_JSON , 'form1');	
		},
		doForce : function(){ //強迫入帳
		//超連結至DSC3_2501(沖預繳作業入帳結果)畫面，供使用者進行沖預繳異常件入帳
		
			var checkedRecord = grid2.getCheckedRecord();
			//檢核是否勾選一筆資料
			if(checkedRecord.length==0){
				alert("請至少選取一筆資料，再進行異常件入帳!");
				return;
			}
			
			var LP_JSON = {	
					action : '<%=dispatcher%>/DSC3_2501/prompt',
					'Action' : 'FORCE',
					washList : checkedRecord
				};				
			CSRUtil.linkTo(LP_JSON , 'form1');	
		},
		doIntemp : function(){ //入電腦暫收款
		//超連結至DSC3_2501(沖預繳作業入帳結果)畫面，供使用者進行沖預繳異常件入帳
		
			var checkedRecord = grid2.getCheckedRecord();
			//檢核是否勾選一筆資料
			if(checkedRecord.length==0){
				alert("請至少選取一筆資料，再進行異常件入帳!");
				return;
			}
		
			var LP_JSON = {	
				action : '<%=dispatcher%>/DSC3_2501/prompt',
				'Action' : 'INTEMP',
				washList : checkedRecord
			};			
			CSRUtil.linkTo(LP_JSON , 'form1');	
		},
		linkToC32503 : function(rec){
		//超連結至DSC3_2503(沖預繳應繳金額明細)畫面，供使用者查詢異常件之應繳金額明細
		
			var LP_JSON = {	
				action : "<%=dispatcher%>/DSC3_2503/prompt"	,		
				'LOAN_ID' : rec.LOAN_ID, //貸款帳號
				'REAL_PAYDT' : rec.REAL_PAYDT //實繳日期
			};   		
			CSRUtil.linkTo(LP_JSON , "form1");		
		}		
	};

	return{	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSC32510" , "核心放款" , "沖預繳 輸入確認作業" ,1);
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: false,	
				column: [
					{header:"序號", key:'seqNO'},
				    {header:"貸款帳號", key:'LOAN_ID'},
					{header:"應繳期數", key:'PAY_TERM'},
					{header:"應繳日期", key:'TAKE_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"應繳金額", key:'TAKE_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"沖帳後本期結餘", key:'WASH_TEMP', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"預繳期數", key:'PREPAY_TERM'},
					{header:"實繳日期", key:'REAL_PAYDT',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"實繳金額", key:'REAL_PAYMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}}							
				]	
			});
			
			grid2 = new TableUI({
				table: $('grid2'), pageSize: 20, allSortable: false,
				autoCheckBox:{
					text:'選取', 
					type:'checkbox'
				},					
				column: [
					{header:"序號", key:'seqNO'},
				    {header:"異常原因", key:'PROC_STATUS'},
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"應繳期數", key:'PAY_TERM'},
					{header:"應繳日期", key:'TAKE_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"應繳金額", key:'TAKE_AMT', attrs: {align:"right"},
						render: function( rec, val ){										   					              		
							var link = document.createElement( "a" );
							link.href = "#";
							link.innerHTML =  (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ;
							link.onclick = function( event ) { 
								buttons.linkToC32503(rec);		                	
							};
							return link;	
					}},
					{header:"沖帳後本期結餘", key:'WASH_TEMP', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"預繳期數", key:'PREPAY_TERM'},
					{header:"實繳日期", key:'REAL_PAYDT',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"實繳金額", key:'REAL_PAYMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}}							
				]	
			});
			
			buttonAuth();

			var rtnList1;
			<c:choose>
				<c:when test='${not empty rtnList1}'>
				   rtnList1 = ${rtnList1};
				</c:when>
				<c:otherwise>
				   rtnList1 = [];
				</c:otherwise>
			</c:choose>

			if (rtnList1.size()==0){
				$('btn_CONFIRM').disable();
			} else {
				for(var i = 0 ;  i < rtnList1.size() ; i++ ){
						rtnList1[i]['seqNO'] = i + 1;
				}
				grid.load(rtnList1);
			}
					
			var rtnList2;					
			<c:choose>
				<c:when test='${not empty rtnList2}'>
				   var rtnList2 = ${rtnList2};
				</c:when>
				<c:otherwise>
				   rtnList2 = [];
				</c:otherwise>
			</c:choose>

			if (rtnList2.size()==0){
				$('btn_ACCOUNT').disable();
				$('btn_FORCE').disable();
				$('btn_INTEMP').disable();
			} else {
				for(var i = 0 ;  i < rtnList2.size() ; i++ ){
						rtnList2[i]['seqNO'] = i + 1;
				}
				grid2.load(rtnList2);
			}					

			$('btn_CONFIRM').observe('click',buttons.doConfirm);
			$('btn_ACCOUNT').observe('click',buttons.doAccount);
			$('btn_FORCE').observe('click',buttons.doForce);
			$('btn_INTEMP').observe('click',buttons.doIntemp);
		
			PageUI.resize();
			displayMessage();						
		}
	};	
}
</script>
</head>
<body>
<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
		<div class="tbYellow0 tbBox2"><B>正常件</B></div>		
		<table id="grid" width="100%" class="grid" ></table>
		<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>	
				<td class="tbYellow2" >
					<input id="btn_CONFIRM" type="button" class="button" value="沖預繳確認">
				</td>
			</tr>			
		</table>
		<div class="tbYellow0 tbBox2"><B>異常件</B>
			<font color="blue"><B>(異常原因：01繳次不對 03契約狀態正常 04金額不足)</B></font>
		</div>
		<table id="grid2" width="100%" class="grid" ></table>
		<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>	
				<td class="tbYellow2" >
					<input id="btn_ACCOUNT" type="button" class="button" value="所有異常件借款人資料">
					<input id="btn_FORCE" type="button" class="button" value="強迫入帳">
					<input id="btn_INTEMP" type="button" class="button" value="入電腦暫收款">
				</td>
			</tr>			
		</table>
</form>
</body>
</html>		