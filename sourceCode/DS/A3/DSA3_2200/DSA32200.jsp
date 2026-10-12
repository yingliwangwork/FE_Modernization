<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSA32200.jsp
作者：李俊德
功能：初估歷史紀錄查詢
完成：
[20240930]難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>
<%--[20240930]難字css  --%>
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
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSA32200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//查詢條件顯示區塊
var reqMap = {};

//--------------------------------------------------------------------------
//	以下為DSA32200() public method,放在 return 中
//--------------------------------------------------------------------------  
function DSA32200(){
	
	var grid1;

	var valid;
	
	var TOWN_Map = {};//儲存已查詢的鄉鎮
	
	var actions = {
	
		//共用ajax
		ajaxPost : function( actionName, params, successAction){	
			new Ajax.Request( "<%=dispatcher%>/DSA3_2200/" + actionName,{  
					parameters: params, 
					onSuccess: function(response){ successAction(response.responseJSON );
				}
			});
		},
		// 查詢
		doQuery : function(){

			valid.reset();
			if( !valid.validate() ) {
	    		return;
	    	}	
			
			if ($F('OTHER') == 1 || $F('OTHER') == 3){
				$('OTHER_VAL').value = $F('OTHER_VAL').toUpperCase();
			}
			
			reqMap = {};
			reqMap.BEG_DATE = $F('BEG_DATE');
			reqMap.END_DATE = $F('END_DATE');
			reqMap.AREA_NO = $F('AREA_NO');
			reqMap.GAGE_ZIP = $F('TOWN');
			reqMap.OTHER = $F('OTHER');
			reqMap.OTHER_VAL = $F('OTHER_VAL');
			actions.ajaxPost( 'query' ,  { reqMap : Object.toJSON(reqMap) } ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						grid1.load(resp.rtnList);
					} else {
						grid1.load([]);
					}
				}
			);				
		},
		//清除
		doClear:function(){
			$('form1').reset();
			$('TOWN').update().insert(new Element('option', {value: ""}).update("鄉鎮區"));
		},
		
		//取得鄉鎮區
		doGetTOWN_LIST:function(){
			var selectElement = $('TOWN');
			selectElement.update().insert(new Element('option', {value: ""}).update("鄉鎮區"));
			var val = $F('CITY') ;
			if(val == ''){
				return;
			}
			//已查詢過就不用再做查詢
			if(TOWN_Map[val]&&TOWN_Map[val].length > 0){
				var opts = TOWN_Map[val];
				if(opts){
					opts.each(function(opt){
						selectElement.insert(new Element('option', {value: opt.POSTCODE}).update(opt.TOWN_NAME));
					});
				}				
			} else {
				actions.ajaxPost('getTOWN_LIST',{CITY_NAME : val},
					function(resp){
							var opts = resp.TOWN_LIST;
							TOWN_Map[val] = opts;
							if(opts){
								opts.each(function(opt){
									selectElement.insert(new Element('option', {value: opt.POSTCODE}).update(opt.TOWN_NAME));
								});
							}
							
					}
				);
			}		
		},
		// 初估編號超連結(DSA32100)
		doLinkByPreapprNo : function(PREAPPR_NO){
			var LP_JSON = {};
			LP_JSON.action = "<%=dispatcher%>/DSA3_2100/prompt";	
			LP_JSON.PREAPPR_NO = PREAPPR_NO; //初估編號
			CSRUtil.linkTo(LP_JSON, 'form1');
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSA32200" , "鑑價作業", "初估資料查詢" );
			
			grid1 = new TableUI(
				{	
					table:$('grid1'), allSortable: false, pageSize: 10, split:["PREAPPR_ADDR"], 
					<%-- [20240930] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "初估編號", key: "PREAPPR_NO",
							render:function(record, value){
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { actions.doLinkByPreapprNo( record.PREAPPR_NO ); };
				                 	return link;
							}
						},
						{ header: "借款人姓名", key: "BORROW_NAME", attrs:{style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
						  	render: function(record, value){
								return CSRUtil.maskHandler.getMaskName(value);
						  	}
						}, 
						{ header: "經手人姓名", key: "AGENT_NM", attrs:{style:"font-family:'EUDC'"}},<%--[20240930]難字調整 --%>
						{ header: "初估貸放金額(萬)", key: "TOTAL_PRICE",
							render:function(record, value){
								return value ? CSRUtil.$fmt(value, '#,###.##') : '0';
							}
						},
						{ header: "申請日期", key: "AGENT_DATE",
							render : function(record, value){
								return value ? Date.toROC(value) : '';
							}
						},
						{ header: "案件狀態", key: "PREAPPR_PROCESS_NM"},
						{ header: "擔保品地址", key: "PREAPPR_ADDR", attrs:{ colSpan:6, style:"font-family:'EUDC'"},<%--[20240930]難字調整 --%>
							render : function(record, value){
								return value || '　';
							}
						}
					]
				}
			);

			valid = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			valid.define( "validate-ROCDate-Interval" , [{ id : "BEG_DATE"}, { id : "END_DATE"}] );
			Validation.addAllThese([
				['validOtherVal', '其他查詢值為必輸欄位', function(v , node) { 
					if($F('OTHER') != '0' && $F('OTHER_VAL') == '' ){
						return false;
					}else{
						return true;
					}
				}],
				['validTOWN', '請選擇鄉鎮區', function(v , node) { 
					if($F('CITY') != '' && $F('TOWN') == '' ){
						return false;
					}else{
						return true;
					}
				}]
			]);

			$('btn_query').observe('click', actions.doQuery ); // 查詢按鈕
			
			$('btn_clear').observe('click', actions.doClear ); // 清除按鈕
			
			$('CITY').observe('change', actions.doGetTOWN_LIST ); //「縣市別」下拉選單連動 「鄉鎮區」下拉選單
		
			autoFormatToDate();

			displayMessage();
			
			//若是回上頁所發送回來的，還原 form 的輸入欄值後，執行重新查詢
			if (CSRUtil.isBackLink('form1')){
				actions.doQuery();
			}
			
		}// end initApp()--
	}// end return--
}// end DSA32200

// 申請請按我超連結
function doLink() {
	
	var LP_JSON = {};
	LP_JSON.action = "<%=dispatcher%>/DSA3_2100/prompt";
	
	CSRUtil.linkTo(LP_JSON, 'form1');
	
}
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form name="form1" id="form1" method="post">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td class="tbYellow">申請日期</td>
				<td class="tbYellow2">
					<input name="BEG_DATE" id="BEG_DATE" datatype="ROCDate" type="text" class="textBox2 validate-ROCDate required" fieldName="申請日期起日" size="10" maxlength="7" value="${BEG_DATE}"> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('BEG_DATE'))">
					~ 
					<input name="END_DATE" id="END_DATE" datatype="ROCDate" type="text" class="textBox2 validate-ROCDate required" fieldName="申請日期迄日" size="10" maxlength="7" value="${END_DATE}"> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('END_DATE'))">
				</td>
				<td class="tbYellow">區部代號</td>
				<td class="tbYellow2">
					<select name="AREA_NO" id="AREA_NO" fieldName="區部代號">
						<c:forEach var="map" items="${AREA_LIST}">
							<option value="${map.VALUE}" >${map.VALUE_NAME}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow2" align="center" rowspan="2">
				    <input type="button" id="btn_query" value="查詢" class="button">
				    <input type="button" id="btn_clear" value="清除" class="button">
				</td>
			</tr>
			<tr>
				<td class="tbYellow">擔保品座落區域</td>
				<td class="tbYellow2">
					<select name="CITY" id="CITY" fieldName="縣市別">
						<option value="">縣市別</option>
						<c:forEach var="map" items="${CITY_LIST}">
							<option value="${map.CITY_NAME}" >${map.CITY_NAME}</option>
						</c:forEach>
					</select>
					<select name="TOWN" id="TOWN" fieldName="鄉鎮區" class="textBox2 validTOWN">
						<option value="">鄉鎮區</option>
					</select>
				</td>
				<td class="tbYellow">其他查詢</td>
				<td class="tbYellow2">
					<select name="OTHER" id="OTHER" fieldName="其他查詢選項">
						<c:forEach var="map" items="${OTHER_LIST}">
							<option value="${map.key}" >${map.value}</option>
						</c:forEach>
					</select>
					<input name="OTHER_VAL" id='OTHER_VAL' type="text" class="textBox2 validOtherVal" size="12" maxlength="20" value="">
				</td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td align="center">
					<a href="#" onClick="doLink()">申請請按我</a>
				</td>
			</tr>
		</table>
		<table id='grid1' width="100%"></table>
	</form>
</body>
</html>
