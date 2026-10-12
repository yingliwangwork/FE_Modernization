<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<!--

程式功能:AVM命中率監控
程式名稱:DSA3_4100
作者:邱建禕
完成:2021年7月1日

-->
<!DOCTYPE html>
<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<!--匯入外部Javascript 與 css-->
<meta charset="BIG5">
<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css' />
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>

<script type='text/javascript' src='${htmlBase}/CM/js/date.js'></script><!--判斷isRocDate用-->
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript'>
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSA34100().initApp);

function DSA34100(){
	<%-- TablE UI物件 --%>
	var grid;		
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_4100/');	
	var FUNC_ID = 'DSA34100';
	<%-- 驗證物件 --%>
	var valid;

	function initValidation(){
		valid = new Validation('form1', {useTitles:false});
		valid.define( 'required' , [{ id : 'QUERY_TYPE', errMsg : "請選擇查詢種類" }] );	
	}

	<%-- actions 方法  --%>
	var actions = {
		'getReqMap':function(){
			 var reqMap = {
				 QUERY_TYPE : $F('QUERY_TYPE'),
				 BDATE_BEG : $F('BDATE_BEG'),
				 BDATE_END : $F('BDATE_END'),
				 CITY_NAME  : $F('CITY_NAME'),
				 IS_HIT: $F('IS_HIT')
			 };
			 return reqMap;
		},
		'buildGrid': function(){
			var kind = event.target.value;
			if('1' == kind){
				grid = new TableUI({
					table: $("grid"),
					pageSize:10,
					column:[
						{header:"縣市別", key:'CITY_NAME'},
						{header:"監控年月", key:'INPUT_DATE', <%-- 僅顯示年月 --%>
							render: function(record,value){
								if(value){
									return value.substring(0,value.lastIndexOf('-'));
								}								
                                return  '-';
                            }
						},
						{header:"平均命中率", key:'AVG_HITRATE',
							render: function(record,value){
                                return  (value || '0') + '%';
                            }	
						},
						{header:"門檻上限", key:'AVG_HITRATE2_H', 
							render: function(record,value){
                                return  (value || '0') + '%';
                            }	
						},
						{header:"門檻下限", key:'AVG_HITRATE2_L',
							render: function(record,value){
                                return  (value || '0') + '%';
                            }		
						}
					]
				});
			}else if('2' == kind){
				grid = new TableUI({
					table: $("grid"),
					validateRecord:function( record , serial_no){ 
						if('否' == record.IS_HIT){<%--若為'否' 該列反紅 --%>
							return false; 
						}
						return true; 
					},
					pageSize:10,
					column:[
						{header:"縣市別", key:'CITY_NAME'},
						{header:"監控日期", key:'INPUT_DATE',sortRule : 'date'},
						{header:"平均命中率", key:'AVG_HITRATE',
							render: function(record,value){
                                return  (value || '0') + '%';
                            }	
						},
						{header:"是否落入", key:'IS_HIT'},
						{header:"門檻上限", key:'AVG_HITRATE2_H',
							render: function(record,value){
                                return  (value || '0') + '%';
                            }							
						},
						{header:"門檻下限", key:'AVG_HITRATE2_L',
							render: function(record,value){
                                return  (value || '0') + '%';
                            }	
						}
					]
				});
			}
		
		}
	};
	
	<%-- buttons 方法  --%>
	var buttons = {
		'doQuery' : function(){
			valid.reset();
			if( !valid.validate() ) {
	    		return;
	    	}
			ajaxRequest.post( 'query',  { reqMap : Object.toJSON(actions.getReqMap()) },
					function(resp){
						grid.load(resp.rtnList);
					},
					function(resp){
						grid.load([]);
					}
			);	
		}
		
	
	};

	return {
		
		initApp : function() {
			PageUI.createPageWithAllBodySubElement( "DSA34100", "鑑價作業", "AVM命中率監控" );
			<cathay:LocaleDisplay dateFields='BDATE_BEG BDATE_END' sysCode='DS' var='localeDisplay' />
			
			<%--註冊事件--%>
			$('btn_query').observe('click', buttons.doQuery);
			$('QUERY_TYPE').observe('change',actions.buildGrid);
			$('BDATE_BEG').setValue('${current1stDate}');
			$('BDATE_END').setValue('${today}');
				
			initValidation();
			displayMessage();		
		}	
	};	
}


</script>

<style type="text/css">
	
</style>

</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<form name='form1' id='form1' >
<table width="100%" border="0" cellpadding="0" cellspacing="1" 	class="tbBox2">
	<tr>
		<td class="tbYellow">查詢種類</td>
		<td class="tbYellow2" colspan="5"> 
			<select name="QUERY_TYPE" id="QUERY_TYPE">
				<option value=''>請選擇</option>
				<c:forEach var="map" items="${AVM_QUERY_TYPE_LIST}">
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow2" align="center" rowspan="2">
			<button type="button" id="btn_query" class="button">查詢</button>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">查詢日期</td>
		<td class="tbYellow2">
			<input name="BDATE_BEG" id="BDATE_BEG" type="text" class="textBox2" size="10" maxlength="7"> ~ 
			<input name="BDATE_END" id="BDATE_END" type="text" class="textBox2" size="10" maxlength="7">
		</td>
		<td class="tbYellow">縣市別</td>
		<td class="tbYellow2">
			<select name="CITY_NAME" id="CITY_NAME">
				<option value=''>全部</option>
				<c:forEach var="map" items="${KIND_LIST}">
					<option value="${map.value}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">是否落入</td>
		<td class="tbYellow2">
			<select name="IS_HIT" id="IS_HIT">
				<option value=''>全部</option>
				<c:forEach var="map" items="${BASIC_LIST}">
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
</table>
<table id="grid" class="grid"></table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" 	class="tbBox2">
	<tr>
		<td>註：監控門檻上下限以該城市過去一年內有使用AVM鑑價案件，計算其平均命中率之正負2倍標準差</td>
	</tr>
</table>
</form>
</body>
</html>