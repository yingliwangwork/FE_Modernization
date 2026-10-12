<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC30601.jsp
作者：卓達瑋
功能：銀行轉帳確認_退匯
完成：2013/05/17
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>		<%-- 匯出檔案用 --%>
<script type="text/JavaScript">

Event.observe(window, 'load', new DSC30601().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC30601(){
	var grid;
	var grid_excel;
	//檢核
	var valid1;	
	//紀錄查詢條件
	var queryMap_rc;
	
	//檢核欄位
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});
 	    Validation.addAllThese( [
			[ 'valid_credit', '',
				function( value , elem ) {
                    
					if(value && value.length!=5){ return false; }

					return true;
				}
			]
			
		]);
		valid1.define('valid_credit' , [{ id : "REJECT_YM" , errMsg:'退匯年月格式錯誤(YYYMM)!!'}] );
		valid1.define('required' , [{ id : "REJECT_YM" , errMsg:'請輸入退匯年月!!'}] );		
		valid1.define('required' , [{ id : "REJECT_GROUP" , errMsg:'請選擇退匯組別!!'}] );
		valid1.define('required' , [{ id : "REJECT_BANK" , errMsg:'請選擇退匯銀行!!'}] );
	}		
    //按鈕授權
		function buttonAuth() {
			var authButtons = { 
				B0021 : 'BTN_EXPORT'    <%--退匯件匯檔--%>
			};
			<dz:grantButtons FUNC_ID="DSC30601" />
		}
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_0601/" + actionName,
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
	var actions= {
        //將畫面寫入Map	
	    queryMap : function(){
			return  {
				'REJECT_YM' : $F('REJECT_YM'), 
				'REJECT_GROUP' : $F('REJECT_GROUP'), 
                'REJECT_BANK' : $F('REJECT_BANK') 				
			}		
	    },
	    // 數值顯示方式處理
	    numberFormat : function (value) {
			return value ? MoneyFormat(value) : '';
		}
        
	}	
	// 功能按鈕
	var button = {
			
		//退匯查詢
		doQuery: function() {	

			//檢核
			
			if(!valid1.validate()){				
				return; 
			}
			
			//紀錄查詢條件
			queryMap_rc=actions.queryMap();
			ajaxPost( 'query', {'queryMap' : Object.toJSON(queryMap_rc)}
				,function(resp){  
                    $('BTN_EXPORT').enable();
					grid.load(resp.rtnList,[{text: '退匯金額(合計)' , value:{DEDUCT_AMT:MoneyFormat(resp.TOT_DEDUCT_AMT)}}]);
					
					$('TOTAL_RESULT').innerHTML = '銀行轉帳抽件結果  退匯件數:'+ resp.TOT_COUNT +' 退匯金額: '+MoneyFormat(resp.TOT_DEDUCT_AMT)+' 元' ;
						
				}
				,function(resp){
				    $('BTN_EXPORT').disable();
					grid.load([]);	
					$('TOTAL_RESULT').innerHTML = '';
				}
			);
		},
		//扣款件匯檔
        doexport :function(){
		 	var queryMap_N=actions.queryMap();  		
		    for(key in queryMap_rc){
			   if(queryMap_rc[key]!=queryMap_N[key]){
					alert("與查詢時的資訊不同,請先查詢後再作業!!");
					return;
			    }
			}							
									
			RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSC3_0601/exprotData', {'exportMap' : Object.toJSON(queryMap_N), 'gridJSON':grid_excel.getXlsSettingJSON('退匯件匯檔')}  );
		}
		
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSC30601" , "繳款方式", "銀行轉帳確認_退匯" );
            grid = new TableUI(
				{table: $("grid"), allSortable: true, pageSize: 20,allSortable:false,		
				column:[
                    {header:"貸款帳號",key:"LOAN_ID"},				
					{header:"期數",key:"PAY_TERM"},	
					{header:"委託人ID",key:"TRUST_ID"},	
					{header:"轉帳銀行",key:"BANK_CODE"},
					{header:"轉帳帳號",key:"ACCOUNT"},	
					{header:"退匯金額",key:"DEDUCT_AMT",
					    render: function (rec,value){
							if(value ||value =="0"){ 
								return MoneyFormat(value);
							}
							return "";
						}
					
					}
				]
			});
			
			grid_excel = new TableUI(
				{table: $("grid_excel"), allSortable: true, pageSize: 20,allSortable:false,		
				column:[
				    {header:"序號",key:"SEQ_NO"},
                    {header:"貸款帳號",key:"LOAN_ID"},				
					{header:"期數",key:"PAY_TERM"},	
					{header:"委託人ID",key:"TRUST_ID"},	
					{header:"轉帳銀行",key:"BANK_CODE"},
					{header:"轉帳帳號",key:"ACCOUNT"},	
					{header:"退匯金額",key:"DEDUCT_AMT",sortRule:'number',
					    render: function (rec,value){
							if(value ||value =="0"){ 
								return MoneyFormat(value);
							}
							return "";
						}
					
					}
				]
			});
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
				
			//畫面檢核
			initValidation();
			//按鈕權限
			buttonAuth();
			// 監聽
			$("BTN_QUERY").observe('click', button.doQuery);
			$("BTN_EXPORT").observe('click', button.doexport);
	
			$('BTN_EXPORT').disable();
					
			PageUI.resize();	
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>

	<tr>
	    <input type="hidden"  id="INPUT_ID" value="${INPUT_ID}">
		<td class='tbYellow' width='15%'>
			退匯年月
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='REJECT_YM'  type="text" class= 'textBox2'   size='8' maxlength='5' value="${SYS_DATE}"/> 
		</td>
	
	
		<td class='tbYellow' width='15%'>
			退匯組別
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="REJECT_GROUP" class="textBox2">
				<option value="">請選擇</option>
				<c:forEach items="${TRANS_GROUP_List}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow' width='15%'>
			退匯銀行
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="REJECT_BANK" class="textBox2">
				<option value="">請選擇</option>
				<c:forEach items="${TRANS_BANK_List}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow2" width="10%" align="center">
			<input type="button" class="button" id="BTN_QUERY" value="退匯查詢"/>					
		</td>
	</tr>
    <tr>
	    <td class="tbYellow2" width="10%" align="center" colspan='7'>		
		    <input type="button" class="button" id="BTN_EXPORT" value="退匯件匯檔"/>			
		</td>			
	</tr>
	<tr>
	    <td class="tbYellow0" width="10%" align="center" colspan='7'>		
		    <b>退匯件查詢結果</b>
		    <span id="TOTAL_RESULT" ></span>		
		</td>			
	</tr>
    <table id='grid' width='100%'></table>
    <div style="display:none;">
    <table id='grid_excel' width='100%' ></table>
    </div>
</table>

</form>

</body>
</html>	