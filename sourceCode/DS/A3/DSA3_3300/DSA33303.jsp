<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!--
程式：DSA33303.jsp
作者：李明翰
功能：土地資料
完成：
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

<script type='text/javascript'>
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSA33303().initApp);

function DSA33303(){

	<%-- TablE UI物件 --%>
	var grid;		
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3303/');	
	var valid;	

	var grid1;
	var selectOption;

	<%--列管類型的下拉選單資訊--%>
	var UseAreaObj = <c:out value="${USE_AREA_LIST}" escapeXml="false" default="{}" />;
	
	
	<%--畫面檢核--%>
	function initValidation(){
		valid = new Validation($('form1'));
		
		Validation.addAllThese([
		    ['validUSE_AREA1', '請選擇使用分區', function(v , node) { 
		    	<%--沒填寫或者選0都是錯誤--%>
		    	if(!v || v == '0'){
		    		return false;
		    	} else{
		    		return true;
		    	}
   			}],
			['validUSE_AREA2', '使用註記長度最多為50碼', function(v , node) { 
				<%--判斷Big5 StringLength--%>
				return actions.checkLength(v, 50);
			}],
			['validLOCATION2', '段名長度最多為10碼', function(v , node) { 
				<%--判斷Big5 StringLength--%>
				return actions.checkLength(v, 10);
			}],
			['validLOCATION3', '小段名長度最多為10碼', function(v , node) { 
				<%--判斷Big5 StringLength--%>
				return actions.checkLength(v, 10);
			}],
			['validLAND_NO1', '地號1長度最多為4碼', function(v , node) { 
				<%--判斷Big5 StringLength--%>
				return actions.checkLength(v, 4);
			}],
			['validLAND_NO2', '地號2長度最多為4碼', function(v , node) { 
				<%--判斷Big5 StringLength--%>
				return actions.checkLength(v, 4);
			}]
		]);
	}
	
	var actions = {
		<%--起始畫面--%>
		initLayout : function() {
			selectOption = commonTools.createOptionsWithMap(new Element('select'), UseAreaObj);
			$('btnCreate').observe('click' , actions.create);	
			$('btnConfirm').observe('click' , actions.confirm);	
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
				if(resp.A352List){
					grid1.load(resp.A352List);
					$('UPDATE_DATE').innerHTML = "資料更新日期：" + resp.UPDATE_DATE;
				}
			});
		},						
		<%--新增--%>
		create : function() {			
			grid1.addRecords({'USE_AREA1':selectOption.length > 0 ? selectOption[0].value : ''
								, 'USE_AREA2':'', 'LOCATION2':'', 'LOCATION3':'', 'LAND_NO1':'', 'LAND_NO2':''});
			PageUI.resize();
		},	
		checkLength : function(str, maxLength) {
			if(commonTools.getChtLength(str) > maxLength){
				return false;
			}
			return true;
		}
	};	
		
	var commonTools = {
		<%--將Map資料轉為下拉選單--%>		
		createOptionsWithMap : function(selectElement, optMap){
			if(optMap){
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
					'DSA33303',
					'鑑價作業',
					'土地資料',
					'',
					true
				);
			grid1 = new TableUI({
			 	table: $("grid1"),
				pageSize:0, 
				column:[	
					{header:"使用分區", key:'USE_AREA1',
						render:function(rec, val, sn){
							<%--deep copy一份下拉選單--%>
							var copy = Element.clone(selectOption, true);
							if(val){
								copy.setValue(val);
							} 

							copy.setAttribute('id', 'restrictAreaSelection_'+ sn);
							copy.setAttribute('class', 'validUSE_AREA1');
							
							<%--更動以後要更動getAllRows的資料--%>
							copy.observe('change' , function(event){
								var dataObj = grid1.getRecordsBySerialNo(sn)[0];
								dataObj.USE_AREA1 = event.target.value;
							});							
							return copy;
						}	
					},
					{header:"使用註記", key:'USE_AREA2', input:{type:'TEXT', 'className':'validUSE_AREA2', 'size':'52'}},						
					{header:"段名", key:'LOCATION2', input:{type:'TEXT', 'className':'required validLOCATION2', 'size':'12'}},					
					{header:"小段名", key:'LOCATION3', input:{type:'TEXT', 'className':'validLOCATION3', 'size':'12'}},						
					{header:"地號1", key:'LAND_NO1', input:{type:'TEXT', 'className':'required validLAND_NO1', 'size':'6'}},					
					{header:"地號2", key:'LAND_NO2', input:{type:'TEXT', 'className':'required validLAND_NO2', 'size':'6'}},						
					{header:"編輯", key:'btn_edit',
						input:{
							type:'button' ,
							text:"刪除",
							name:'editBtn',
	                        action:function( node , dataObj , value){ 	
								grid1.deleteRecords(dataObj[0]);		
							}
						}
					}	
				]
			});			
			
			
			
			displayMessage();		
			actions.initLayout();
			initValidation();
			<%--init時要顯示的資料list--%>
			grid1.load(<c:out value="${A352List}" escapeXml="false" default="[]" />);
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
		<tr class=tbYellow0 align="center">
			<td>
				<strong>土地資料清單</strong>	
				<button id="btnCreate" name="btnCreate" type="button" class="button">新增</button>
				<button id="btnConfirm" name="btnCreate" type="button" class="button">確認</button>
				<div id="UPDATE_DATE" datatype="ROCDate" style="float:right">資料更新日期：${UPDATE_DATE}</div>
			</td>
		</tr>		
	</table>
	<table id="grid1"></table>	
</form>
</body>
</html>