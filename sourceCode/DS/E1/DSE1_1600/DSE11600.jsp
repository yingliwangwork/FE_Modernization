<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSE11600.jsp
作者：余凱鈞
功能：呆帳轉銷作業
完成：2013/7/19

[20240215]難字調整
 -->	

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script> 			<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>   <%-- 匯出EXCEL用 --%>

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
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSE11600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSE11600(){

	var grid;
	var rtnList;
	var inputList;
	var status; //匯出狀態
	var Total_Map;
	var TOTobj;
    function buttonAuth(){
		var authButtons = {	
			B0185:"btn_submit",
            B0186:"btn_badWriteOff",
            B0187:"btn_cancelSubmit"				
		};
		<dz:grantButtons FUNC_ID="DSE11600" />
	}
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_1600/" + actionName,
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
	
	var action= {
		//將畫面寫入Map	
		queryMap : function(){
			return  {
				'LOAN_ID' : $F('LOAN_ID'),
				'BAD_DATE' : $F('BAD_DATE'),			
				WRITEOFF_STATUS : status
			}		
		}
	}

	var buttons = {
		doSubmitQuery0 : function(){
		
			ajaxPost( 'submitQuery0', {WRITEOFF_STATUS: "0"}
				,function(resp){
					rtnList=resp.rtnList;
					Total_Map=resp.Total_Map?resp.Total_Map:{};
					for(var i = 0 ;  i < rtnList.size() ; i++ ){
						rtnList[i]['SER_NO'] = i + 1;
					}
					TOTobj = [ {text:'合計', textAlign : 'center', value:{CREDIT_AMT: Total_Map.CREDIT_AMT, BAD_AMT: Total_Map.BAD_AMT} }];
					grid.load(rtnList, TOTobj);
				},function(resp){
					grid.load([]);
				}
			);
			
			$('btn_submit').enable();
			$('btn_badWriteOff').disable();
			$('btn_cancelSubmit').disable();
			$('btn_export').enable();	

			status = "0";
		},
		doSubmitQuery1 : function(){
		
			ajaxPost( 'submitQuery1', {WRITEOFF_STATUS: "1"}
				,function(resp){
					rtnList=resp.rtnList;
					Total_Map=resp.Total_Map?resp.Total_Map:{};
					for(var i = 0 ;  i < rtnList.size() ; i++ ){
						rtnList[i]['SER_NO'] = i + 1;
					}
					TOTobj = [ {text:'合計', textAlign : 'center', value:{CREDIT_AMT: Total_Map.CREDIT_AMT, BAD_AMT: Total_Map.BAD_AMT} }];
					grid.load(rtnList, TOTobj);
				},function(resp){
					grid.load([]);
				}
			);
			
			$('btn_submit').disable();
			$('btn_badWriteOff').enable();
			$('btn_cancelSubmit').enable();
			$('btn_export').enable();	

			status = "1";			
		},
		
		doBadQuery : function(){
			if(!$F('LOAN_ID') && !$F('BAD_DATE')){
				alert("請輸入貸款帳號或轉呆日期來查詢!!");
				return;
			}
			
			var reqMap = {
				LOAN_ID : $F('LOAN_ID'),
				BAD_DATE : $F('BAD_DATE'),
				WRITEOFF_STATUS : "2"			
			}
			ajaxPost( 'badQuery', {reqMap : Object.toJSON(reqMap)}
				,function(resp){
					rtnList=resp.rtnList;
					Total_Map=resp.Total_Map?resp.Total_Map:{};
					for(var i = 0 ;  i < rtnList.size() ; i++ ){
						rtnList[i]['SER_NO'] = i + 1;
					}
					TOTobj = [ {text:'合計', textAlign : 'center', value:{CREDIT_AMT: Total_Map.CREDIT_AMT, BAD_AMT: Total_Map.BAD_AMT} }];
					grid.load(rtnList, TOTobj);
				},function(resp){
					grid.load([]);
				}
			);

			$('btn_submit').disable();
			$('btn_badWriteOff').disable();
			$('btn_cancelSubmit').disable();	
			$('btn_export').enable();
			
			status = "2";
		},	

		doSubmit : function(){

			var checkedRecord = grid.getCheckedRecord(['LOAN_ID','SOURCE_FILE','SALE_DATE','OPERATION_KIND','BARGAIN_DATE']);
			
			//檢查是否至少選取一筆資料
			if(checkedRecord.length==0){
				alert("請至少選取一筆資料");
				return;
			}		
			//提示確認訊息
			if(!confirm('已確認提呆資料無誤?')){
				return;
			}
			
			ajaxPost( 'submit', {inputList : Object.toJSON(checkedRecord)}
				,function(resp){
					rtnList=resp.rtnList;
					Total_Map=resp.Total_Map?resp.Total_Map:{};
					for(var i = 0 ;  i < rtnList.size() ; i++ ){
						rtnList[i]['SER_NO'] = i + 1;
					}
					TOTobj = [ {text:'合計', textAlign : 'center', value:{CREDIT_AMT: Total_Map.CREDIT_AMT, BAD_AMT: Total_Map.BAD_AMT} }];
					grid.load(rtnList, TOTobj);
				}
				,function(resp){
					grid.load([]);
			});
			
			$('btn_submit').disable();
			$('btn_badWriteOff').enable();
			$('btn_cancelSubmit').enable();	
			$('btn_export').enable();
			
			status = "1";		
		},
		doBadWriteOff : function(){

			var checkedRecord = grid.getCheckedRecord(['LOAN_ID','SOURCE_FILE','SALE_DATE','OPERATION_KIND','BARGAIN_DATE']);
			
			//檢查是否至少選取一筆資料
			if(checkedRecord.length==0){
				alert("請至少選取一筆資料");
				return;
			}		
			//提示確認訊息
			if(!confirm('已確認轉呆資料無誤?')){
				return;
			}
			
			ajaxPost( 'badWriteOff', {inputList : Object.toJSON(checkedRecord) }
				,function(resp){
					rtnList=resp.rtnList;
					Total_Map=resp.Total_Map?resp.Total_Map:{};
					for(var i = 0 ;  i < rtnList.size() ; i++ ){
						rtnList[i]['SER_NO'] = i + 1;
					}
					TOTobj = [ {text:'合計', textAlign : 'center', value:{CREDIT_AMT: Total_Map.CREDIT_AMT, BAD_AMT: Total_Map.BAD_AMT} }];
					grid.load(rtnList, TOTobj);
				}
				,function(resp){
					grid.load([]);
			});
			
			$('btn_submit').disable();
			$('btn_badWriteOff').disable();
			$('btn_cancelSubmit').disable();
			$('btn_export').enable();	

			status = "2";		
		},
		doCancelSubmit : function(){

			var checkedRecord = grid.getCheckedRecord(['LOAN_ID','SOURCE_FILE','SALE_DATE','OPERATION_KIND','BARGAIN_DATE']);
			
			//檢查是否至少選取一筆資料
			if(checkedRecord.length==0){
				alert("請至少選取一筆資料");
				return;
			}		
			//提示確認訊息
			if(!confirm('確定要取消提保?')){
				return;
			}
			
			ajaxPost( 'cancelSubmit', {inputList : Object.toJSON(checkedRecord) }
				,function(resp){
					rtnList=resp.rtnList;
					Total_Map=resp.Total_Map?resp.Total_Map:{};
					for(var i = 0 ;  i < rtnList.size() ; i++ ){
						rtnList[i]['SER_NO'] = i + 1;
					}
					TOTobj = [ {text:'合計', textAlign : 'center', value:{CREDIT_AMT: Total_Map.CREDIT_AMT, BAD_AMT: Total_Map.BAD_AMT} }];
					grid.load(rtnList, TOTobj);
				}
				,function(resp){
					grid.load([]);
			});
			
			$('btn_submit').enable();
			$('btn_badWriteOff').disable();
			$('btn_cancelSubmit').disable();	
			$('btn_export').enable();
			
			status = "0";					
		},
		doExport : function(){
			//當前條件
			var exportMap = action.queryMap(); //執行queryMap
			var exportParams = {
				CONDITION : Object.toJSON(exportMap),
				gridJSON : grid.getXlsSettingJSON("呆帳轉銷作業")
			}
			
			RPTUtil.executeCreateXlsFile("<%=dispatcher%>/DSE1_1600/export", exportParams );		
		}
		
	};

	return{
	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSE11600" , "法務作業" , "呆帳轉銷作業");
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: true, autoCheckBox:{isSelectAll:true },	
				<%-- [20240215] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: [
					{header:"序號", key:'SER_NO'},
					{header:"貸款帳號", key:'LOAN_ID'},
				    {header:"案款入帳日", key:'ACNT_DATE',
						render : function (rec , val){
							return Date.toROC(val || '');									
						}	
					},
					{header:"姓名", key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
				    {header:"上次已繳日", key:'LAST_PAYDT',
						render : function (rec , val){
							return Date.toROC(val || '');									
						}	
					},
					{header:"貸放日期", key:'LOAN_DATE',
						render : function (rec , val){
							return Date.toROC(val || '');									
						}
					},
					{header:"本金餘額", key:'CREDIT_AMT',
						renderInCount: true, 
						render:function( record, val ) {																		
							return CSRUtil.$fmt(val, '#,###');
						}					
					},					
					{header:"催收款-不足額", key:'BAD_AMT',
						renderInCount: true, 
						render:function( record, val ) {																		
							return CSRUtil.$fmt(val, '#,###');
						}	
					},
					{header:"不足種類", key:'BAD_KIND'},
					{header:"提呆日期", key:'SUBMIT_DATE',
						render : function (rec , val){
						return Date.toROC(val || '');									
						}					
					},
					{header:"轉呆日期", key:'WRITEOFF_DATE',
						render : function (rec , val){
						return Date.toROC(val || '');									
						}					
					}
				]	
			});
					
			$('BAD_DATE').value = getToday(); //轉呆日期查詢欄位預帶當日
			
			$('btn_submit').disable();
			$('btn_badWriteOff').disable();
			$('btn_cancelSubmit').disable();
			$('btn_export').disable();			
			
			$('btn_submitQuery0').observe('click',buttons.doSubmitQuery0);
			$('btn_submitQuery1').observe('click',buttons.doSubmitQuery1);
			$('btn_badQuery').observe('click',buttons.doBadQuery);
			$('btn_submit').observe('click',buttons.doSubmit);
			$('btn_badWriteOff').observe('click',buttons.doBadWriteOff);
			$('btn_cancelSubmit').observe('click',buttons.doCancelSubmit);
			$('btn_export').observe('click',buttons.doExport);
			buttonAuth();
			fix();
			displayMessage();			
		}
	};	
}
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<input type="hidden" name="gridJSON" id="gridJSON" value="">	 <%-- 匯出內容 --%>
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width= "8%" align="left">貸款帳號</td>
				<td class="tbYellow2" width ="10%">
					<input id="LOAN_ID"  type="text" class="textBox2" size="12" onblur="this.value = this.value.toUpperCase()"/>
				</td>
				<td class="tbYellow" width="8%" align="left" >轉呆日期</td>
				<td class="tbYellow2" >
					<input id="BAD_DATE" datatype="ROCdate" type="text" class="textBox2 " size="8" maxlength="7" />
					<img src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('BAD_DATE'))" /></td>						
				<td class="tbYellow2" width = "60%" >
				<input id="btn_submitQuery0" type="button" class="button" value="待提呆件查詢">
				<input id="btn_submitQuery1" type="button" class="button" value="已提呆件查詢">
				<input id="btn_badQuery" type="button" class="button" value="已轉呆件查詢">
				<input id="btn_export" type="button" class="button" value="匯出">
				</td>	
			</tr>
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tbBox2">		
			<tr>
				<td  width="100%" colspan="9" align="center">					
					<input id="btn_submit" type="button" class="button" value='提呆' />
					<input id="btn_badWriteOff" type="button" class="button" value='轉呆' />
					<input id="btn_cancelSubmit" type="button" class="button" value='取消提呆' />
				</td>
			</tr>
		</table>

	</form>
		<table id="grid" width="100%" class="grid" ></table>
</body>
</html>		