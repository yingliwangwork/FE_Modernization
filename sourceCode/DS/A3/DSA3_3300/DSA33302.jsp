<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!--
程式：DSA33302.jsp
作者：李明翰
功能：建物列管
完成：

[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
[20241113] 問題單: 20241113101519 陳勁谷 難字處理
新增出來的地址欄位，無法輸入難字
新增後，若畫面上原有難字，則會導致轉換失效
確認的地址難字，無法正確新增進資料庫
-->
<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<!--匯入外部Javascript 與 css-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>

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
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSA33302().initApp);

function DSA33302(){

	<%-- TablE UI物件 --%>
	var grid;		
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3302/');	
	var valid;	

	var grid1;
	var selectOption;
		
	<%--列管類型的下拉選單資訊--%>
	var RestrictAreaObj = <c:out value="${RESTRICT_AREA_LIST}" escapeXml="false" default="{}" />;

	<%--畫面檢核--%>
	function initValidation(){
		valid = new Validation($('form1'));

		Validation.addAllThese([
			['validRESTRICT_AREA', '請選擇列管類型', function(v , node) { 
		    	<%--沒填寫或者選0都是錯誤--%>
		    	if(!v || v == '0'){
		    		return false;
		    	} else{
		    		return true;
		    	}
   			}],
			['validADDR_NO', '地址長度最多為60碼', function(v , node) { 
				<%--使用BLEN，判斷Big5 StringLength--%>
				if(commonTools.getChtLength(v) > 60 ){
					return false;
				}else{
					return true;
				}
			}],
			['validRESTRICT_NOTE', '列管原因長度最多為200碼', function(v , node) { 
				<%--使用BLEN，判斷Big5 StringLength--%>
				if(commonTools.getChtLength(v) > 200 ){
					return false;
				}else{
					return true;
				}
			}]
		]);
	}
	
	<%--按鈕控制--%>
	var buttons = {
		bindAction : function() {
			$('btnCreate').observe('click' , actions.create);	
			$('btnConfirm').observe('click' , actions.confirm);	
		}
	};
	
	
	var actions = {
		<%--起始畫面--%>
		initLayout : function() {
			<%--起始共用的下拉選單--%>
			selectOption = commonTools.createOptionsWithMap(new Element('select'), RestrictAreaObj);
		},
		<%--初始查詢
		[20241113] 問題單: 20241113101519 陳勁谷 難字處理 將doPrompt查詢改ajax 因初次grid.load載入難字 再送出 難字會變成問號--%>
		initQuery: function() {
			ajaxRequest.post('query', { 
				COMMUNITY_NO : '${COMMUNITY_NO}'
			},
			function(resp){ 
				if(resp.A351List){
					grid1.load(resp.A351List);
					$('UPDATE_DATE').innerHTML = "資料更新日期：" + resp.UPDATE_DATE;
				}
			});
		},
		<%--確認--%>
		confirm : function() {			
			valid.reset();
			if(!valid.validate()){
				return;
			}

			ajaxRequest.post('confirm', { 
				DATA_LIST : Object.toJSON(grid1.getAllRecords()),
				COMMUNITY_NO : '${COMMUNITY_NO}'
			},
			function(resp){ 
				if(resp.A351List){
					grid1.load(resp.A351List);
					$('UPDATE_DATE').innerHTML = "資料更新日期：" + resp.UPDATE_DATE;
				}
			});
		},						
		<%--新增--%>
		create : function() {			
			grid1.addRecords({'ADDR_NO':'', 'RESTRICT_AREA':selectOption.length > 0 ? selectOption[0].value : '', 'RESTRICT_NOTE':''});
			PageUI.resize();
		}	
	};	
		
	
	var commonTools = {
		<%--將Map資料轉為下拉選單--%>		
		createOptionsWithMap : function(selectElement, optMap){
			if(optMap){
				<%--清空選單--%>
				selectElement.length=0;
				for(var key in optMap){
					selectElement.insert(new Element('option',{value: key}).update(optMap[key]));					
				}
			}
			return selectElement;
		},	
		<%--檢核中文長度--%>		
		getChtLength : function(str){
		    if(!str){
		    	return 0;
		    }
		    if(window.charCountsByte == '2'){
		    	<%--BIG5--%>
		    	var arr = str.match(/[^\x00-\xff]/ig);
		        return arr == null ? str.length : str.length + arr.length;
		    }
		    <%--UTF8--%>
		    var m = encodeURIComponent(str).match(/%[89ABab]/g);
		   	return str.length + (m ? m.length : 0);
		}
	};
	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement(
					'DSA33302',
					'鑑價作業',
					'建物列管',
					'',
					true
				);
			grid1 = new TableUI({
			 	table: $("grid1"),
				pageSize:0, 
				afterLoad: function(Element) {
					<%--[20241113] 問題單: 20241113101519 陳勁谷 難字處理--%>
					parseEUDC();
				},
				column:[	
					{header:"地址", key:'ADDR_NO', 
						<%--[20241113] 問題單: 20241113101519 陳勁谷 難字處理--%>
						render: function(rec, val, sn) {
							var input = new Element('input', {
								'class': 'required validADDR_NO',
								'size': '60',
							}).setValue(val);
							input.setAttribute('alt','ch');
							if (rec.UPDATE_ID == 'DSA3_B040') {
								input.disabled = true;
							}
							input.observe('blur', function(event) {
								rec['ADDR_NO'] = this.value;
							});
							return input;
						}
					},					
					{header:"列管類型", key:'RESTRICT_AREA',
						render:function(rec, val, sn){
							<%--deep copy一份下拉選單--%>
							var copy = Element.clone(selectOption, true);
							if(val){
								copy.setValue(val);
							} 							
							
							copy.setAttribute('id','restrictAreaSelection_'+ sn);
							copy.setAttribute('class', 'validRESTRICT_AREA');
							   
							<%--更動以後要更動getAllRows的資料--%>
							copy.observe('change' , function(event){
								var dataObj = grid1.getRecordsBySerialNo(sn)[0];
								dataObj.RESTRICT_AREA = event.target.value;
							});			
							

							if(rec.UPDATE_ID == 'DSA3_B040'){
								copy.disable();
							}else{
								copy.enable();
							}
							return copy;
						}	
					},
					{header:"列管原因", key:'RESTRICT_NOTE', 
						input:{
							type:'TEXT', size:40, className:'required validRESTRICT_NOTE',
							genRule:function(rec,val){
								return rec.UPDATE_ID != 'DSA3_B040';
							}
						}
					},
					{header:"更新人員", key:'UPDATE_NAME', styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					{header:'編輯', key:'btn_edit',
						input:{
							type:"button" , text:"刪除", name:'editBtn',
	                        action:function(node , dataObj , value){ 	
								grid1.deleteRecords(dataObj[0]);		
							},
							genRule:function(rec,val){
								return rec.UPDATE_ID != 'DSA3_B040';
							}
						}
					}	
				]
			});
			displayMessage();		
			buttons.bindAction();
			actions.initLayout();
			<%--[20241113] 問題單: 20241113101519 陳勁谷 難字處理 將doPrompt查詢改ajax 因初次grid.load載入難字 再送出 難字會變成問號--%>
			actions.initQuery();
			
			initValidation();
			<%-- [20221215] --%>
			<c:if test="${BTN_STATUS ne '1'}">
				$$('input[type="button"]', 'button[type="button"]').each(function(btn) {
					btn.disable();
				});
			</c:if>
			PageUI.resize();
		}	
	};	
}	
	
</script>
</head>
<body>
<form name='form1' id='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
	<table id="block_A" width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
		<tr class=tbYellow0 align=middle>
			<td align="center">
				<strong>建物列管清單</strong>	
				<button id="btnCreate" name="btnCreate" type="button" class="button">新增</button>
				<button id="btnConfirm" name="btnConfirm" type="button" class="button">確認</button>
				<div id="UPDATE_DATE" datatype="ROCDate" style="float:right">資料更新日期：${UPDATE_DATE}</div>
			</td>
		</tr>
	</table>
	<table id="grid1" width="100%"></table>	
</form>
</body>
</html>