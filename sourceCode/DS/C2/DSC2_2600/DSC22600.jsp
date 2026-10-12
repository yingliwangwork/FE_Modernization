<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC22600.jsp
作者：卓達瑋
功能：清償剔帳查詢
完成：2013/04/18

[20241030]修改件 CHROME瀏覽器難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<%--[20241030]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>    <%-- 月曆專用 --%> 
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>		<%-- 匯出檔案用 --%>
<script type="text/JavaScript">

Event.observe(window, 'load', new DSC22600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC22600(){
	var grid;		
	
	//檢核
	var valid1;		
	var valid2;
	//紀錄查詢時條件
	var reqMap_rc;
	//檢核欄位
	function initValidation(){
		Validation.addAllThese( [
			[ 'validateDELT_DEPT',  '單位代號有誤，請檢查後重新輸入!', 
				function(v){ 
					if(v){
						<%--單位代號7碼英數字--%>
						return v.length == 7 && (/^[a-zA-Z0-9]+$/.test(v)); 
					}
					return true;					
				} 
			]
		] );
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});				
	    valid1.define( "validate-ROCDate-Interval" , [{ id : "DELT_DATE_STR" , errMsg :"剔帳迄日需大於剔帳起始日期，請檢查後重新輸入查詢條件!" },{ id : "DELT_DATE_END" , errMsg :"剔帳迄日需大於剔帳起始日期，請檢查後重新輸入查詢條件!"}] );
 	    valid1.define('required' , [{ id : "DELT_DATE_STR" , errMsg:'請輸入剔帳日期(起日)!'}] );
		valid1.define('required' , [{ id : "DELT_DATE_END" , errMsg:'請輸入剔帳日期(迄日)!'}] );
        valid2= new Validation("form1", { focusOnError:true, immediate:false});	
		valid2.define( "validate-ROCDate-Interval" , [{ id : "DELT_DATE_STR" , errMsg :"剔帳迄日需大於剔帳起始日期，請檢查後重新輸入查詢條件!" },{ id : "DELT_DATE_END" , errMsg :"剔帳迄日需大於剔帳起始日期，請檢查後重新輸入查詢條件!"}] );
		valid2.define('validateDELT_DEPT' , [{ id : "DELT_DEPT"}] );
	}		

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_2600/" + actionName,
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
	};
    //將畫面寫入Map	
	function queryMap(){
		return  {
			'DELT_DEPT' : $F('DELT_DEPT'), 
			'DELT_DATE_STR' : $F('DELT_DATE_STR'), 
			'DELT_DATE_END' : $F('DELT_DATE_END') 
		}		
	};
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {	
		
			//檢核
            if(!$F('DELT_DEPT')&&!$F('DELT_DATE_STR')&!$F('DELT_DATE_END')){
			    alert('請輸入剔帳日期或單位代號！');
				return;
			}
			if(!$F('DELT_DEPT')&&!valid1.validate()){
				return; 
			}
		
			if($F('DELT_DEPT')&&$F('DELT_DATE_STR')){
				if(!$F('DELT_DATE_END')){
				    alert('請輸入剔帳日期(迄日)！');
				    return;
				}
			}
			if($F('DELT_DEPT')&&$F('DELT_DATE_END')){
				if(!$F('DELT_DATE_STR')){
				    alert('請輸入剔帳日期(起日)！');
				    return;
				}
			}
		    if($F('DELT_DEPT')){
				if(!valid2.validate()){
				return; 
			    } 
			}
            reqMap_rc=queryMap();			
			ajaxPost( 'query', {'reqMap' :Object.toJSON(reqMap_rc)}
				,function(resp){
					grid.load(resp.rtnList || []);
				}
				,function(resp){
					//如果失敗,把前一次的內容清掉
					grid.load([]);
				}
			);
		},
		//匯出
		doExport : function(event){			
			
			if( grid.getAllRecords().length == 0 ){
				alert('請先查詢再匯出');
				return;
			};

			//當前條件
			var reqMap = queryMap(); //執行queryMap
			// 必須先做過查詢 且畫面上的查詢條件須與[查詢]時一致，否則顯示錯誤訊息
			for(key in reqMap ){
				if(reqMap[key] != reqMap_rc[key]){
					alert('查詢時期條件不同，請重新查詢');
					return;
				}			
			}
			
			var exportParams = {
				CONDITION : Object.toJSON(reqMap),
				gridJSON : grid.getXlsSettingJSON("清償剔帳查詢"),
				isExport : "Y"
			}
			
			RPTUtil.executeCreateCsvFile("<%=dispatcher%>/DSC2_2600/export", exportParams );
		}
		
		
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSC22600" , "帳務", "清償剔帳查詢" );
			<%-- [20241030] 難字調整 --%>
			grid = new TableUI(
				{table: $("grid"), allSortable: true, pageSize: 20,allSortable:false,
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[					
					{header:"筆數",key:"COUNT_NO"},	
					{header:"剔除日期",key:"DELT_DATE",
					    render : function (rec , val){
									return Date.toROC(val || "");									
							}
					},
					{header:"單位代號",key:"DELT_DEPT"},
					{header:"單位名稱",key:"DIV_NAME"},
                    {header:"繳別",key:"PAY_KIND_NM"},
					{header:"剔除人員",key:"DELT_NAME", style:"font-family:'EUDC'"},
                    {header:"覆核人員",key:"CONFIRM_NAME", style:"font-family:'EUDC'"},
					{header:"貸款帳號",key:"LOAN_ID"},
                    {header:"姓名",key:"BORROW_NAME", style:"font-family:'EUDC'"},
					{header:"實繳金額",key:"REAL_PAYMT", sortRule:'number',
					    render: function (record,value){
							if( value != null && value != "" ){
								return MoneyFormat(value);
							}
							return 0;
						}
					
					},
					{header:"單據序號",key:"RECEIPT_SERNO"},
					{header:"剔除種類",key:"DELT_KIND_NM"},
                    {header:"剔除說明",key:"DELT_MEMO"}
				]
			});
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
				
			//畫面日期檢核
			initValidation();
		
			// 監聽: 查詢
			$("BTN_QUERY").observe('click', button.doQuery);
			$("BTN_EXPORT").observe('click', button.doExport);
						
			PageUI.resize();	
			displayMessage();
		}
	}
}
</script>
</head>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
	<tr>
		<td class='tbYellow' width='5%'>
			單位代號
		</td>
		<td class='tbYellow2' width='15%'>
			<input id='DELT_DEPT' type='text' class= 'textBox2'   size='8' maxlength='7' value="${DELT_DEPT}"/> 
		</td>
		<td class="tbYellow2" rowspan="2" width="10%" align="center">
			<input type="button" class="button" id="BTN_QUERY" value="查詢"<%-- 查詢 --%> />	
		    <input type="button" class="button" id="BTN_EXPORT" value="匯出"<%-- 清除 --%> />					
		</td>

	</tr>
	<tr>
		<td class='tbYellow' width='5%'>
			剔帳日期
		</td>
		<td class='tbYellow2' width='15%'>
			<input id="DELT_DATE_STR" datatype="ROCDate" type="text" class="textBox2 "  size="10" maxlength="7" value="${SYS_DATE}"/>
			<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('DELT_DATE_STR'))">
				~
			<input id="DELT_DATE_END" datatype="ROCDate" type="text" class="textBox2 " size="10" maxlength="7"  value="${SYS_DATE}"/>
			<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('DELT_DATE_END'))">
		</td>
	</tr>
	<table id='grid' width='100%'></table>
</table>




</form>
</body>
</html>	