<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript"
	src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/comm.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript"
	src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
</head>

<script type="text/javascript">
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var DATA_MAP = {};
var LINK_FROM = '${LINK_FROM}';

function initApp(){

	cleanMsgBoard();
	
	displayMessage();
	
	buttonAuth();

	PageUI.createPageWithAllBodySubElement("DSA21901" , "核貸作業" , "退回錯誤歸類", 1);

	new UI().init();
	
	// 錯誤歸類按鈕
	$("btn_classify").observe('click', function(event){
			doClassify();
		}
	);
	
	// 關閉按鈕
	$("btn_close").observe('click', function(event){
			doClose();
		}
	);

	// 上一頁按鈕
	/*$("btn_back").observe('click', function(event){
			doBack();
		}
	);*/

	PageUI.resize(true);
}

function buttonAuth(){
	var authButtons = {
			B0044:"btn_link<%--影像連結--%>"
	};
	<dz:grantButtons FUNC_ID="DSA21901" ignored="false"/>
}

//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
		init:function(){
		
				['A', 'B', 'C', 'D', 'E', 'F'].each(function(e){ 
					$(e + '_CHECK').observe( "click", function( event ){ 
						var elm = event.element();
						var cond = '#' + e + ' INPUT[type=checkbox]:not([id=' + e + '_CHECK])'
						var checks = $$(cond); 
						var flag = false;
						if(elm.checked == true){
							flag = true;
						} 
	
						checks.each(function(e){e.checked = flag;});
						
					}); 
					$(e + '_SPAN').hide(); 
				});
		
				//載入送件明細表
				var A010Map = ('${A010Map}' || '[]').evalJSON();
				$('APPLY_ID_span').innerHTML = '${APPLY_ID}';
				//['BORROW_NAME', 'CRED_DEPT_NM', 'SEND_NAME'].each(
				//	function(ele){
				//		$(ele + '_span').innerHTML = A010Map[ele] || '';
				//	}
				//);
				//$('APPLY_DATE_span').innerHTML = getDateField(A010Map['APPLY_DATE']);
				//$('SEND_DATE_span').innerHTML = getDateField(A010Map['SEND_DATE']);
				var obj_A = document.getElementById('A');
				var obj_B = document.getElementById('B');
				var obj_C = document.getElementById('C');
				var obj_D = document.getElementById('D');
				var obj_E = document.getElementById('E');
				var obj_F = document.getElementById('F');
				if (${rtnItemMap}) {
					if (LINK_FROM == 'DSA2_3000') {
						auxiliary.insertDataToTable(${rtnItemMap}.A_LIST, 'A'); //載入
						auxiliary.insertDataToTable(${rtnItemMap}.B_LIST, 'B'); //載入
						obj_C.style.display = "none";
						obj_D.style.display = "none";
						obj_E.style.display = "none";
						obj_F.style.display = "none";
					} else if (LINK_FROM == 'DSA2_1014') {
						auxiliary.insertDataToTable(${rtnItemMap}.C_LIST, 'C'); //載入
						auxiliary.insertDataToTable(${rtnItemMap}.D_LIST, 'D'); //載入
						obj_A.style.display = "none";
						obj_B.style.display = "none";
						obj_E.style.display = "none";
						obj_F.style.display = "none";
					} else if (LINK_FROM == 'DSB4_0200') {
						auxiliary.insertDataToTable(${rtnItemMap}.E_LIST, 'E'); //載入
						auxiliary.insertDataToTable(${rtnItemMap}.F_LIST, 'F'); //載入
						obj_A.style.display = "none";
						obj_B.style.display = "none";
						obj_C.style.display = "none";
						obj_D.style.display = "none";
					}
					/*
					auxiliary.insertDataToTable(${rtnItemMap}.A_LIST, 'A'); //載入
					auxiliary.insertDataToTable(${rtnItemMap}.B_LIST, 'B'); //載入
					auxiliary.insertDataToTable(${rtnItemMap}.C_LIST, 'C'); //載入
					auxiliary.insertDataToTable(${rtnItemMap}.D_LIST, 'D'); //載入
					auxiliary.insertDataToTable(${rtnItemMap}.E_LIST, 'E'); //載入
					auxiliary.insertDataToTable(${rtnItemMap}.F_LIST, 'F'); //載入
					*/
				}
				
				// 若rtnMap.RETURN_ITEM = itemMap.RETURN_ITEM,則該項目預設為勾選
				var rtnlist = ('${rtnList}' || '[]').evalJSON();
				if (rtnlist){
					for(var i=0; i < rtnlist.length; i++){
						var name = rtnlist[i].RETURN_ITEM;
						var obj = document.getElementById(name);
						if(obj){
							obj.checked = true;
						}
					}
				}

			
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

function getDateField(str){
	return str ? Date.toROC(str) : " ";
}

//--------------------------------------------------------------------------	
//	錯誤歸類Function
//--------------------------------------------------------------------------
function doClassify(){

	//將勾選的項目存入DATA_MAP.RETURN_ITEM_LIST
	auxiliary.getDATA_MAP();
	
	var check_A = $$('#A input:checked[type=checkbox]');
	var check_B = $$('#B input:checked[type=checkbox]');
	var check_C = $$('#C input:checked[type=checkbox]');
	var check_D = $$('#D input:checked[type=checkbox]');
	var check_E = $$('#E input:checked[type=checkbox]');
	var check_F = $$('#F input:checked[type=checkbox]');
	var hasCheck = true;
	if (LINK_FROM == 'DSA2_3000') {
		if (check_A.length == 0 && check_B.length == 0) {
			hasCheck = false;
		}
	} else if (LINK_FROM == 'DSA2_1014') {
		if (check_C.length == 0 && check_D.length == 0) {
			hasCheck = false;
		}
	} else if (LINK_FROM == 'DSB4_0200') {
		if (check_E.length == 0 && check_F.length == 0) {
			hasCheck = false;
		}
	}
	if (!hasCheck) {
		alert("請至少勾選一種錯誤歸類!");
		return;
	}
	
  	new Ajax.Request("<%=dispatcher%>/DSA2_1901/classify", 
		{
			parameters:{
				APPLY_ID : $('APPLY_ID_span').innerHTML,
				ERROR_ITEM_List : Object.toJSON(DATA_MAP.RETURN_ITEM_LIST)
			},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					if(window['callbackHandler']){
						callbackHandler();
					}else if(parent.popupWin.callbackHandler){
						parent.popupWin.callbackHandler();
					}
					parent.popupWin.close();
				}
			}
		});
}

function doClose(){
	if(window['callbackHandler']){
		callbackHandler();
	}else if(parent.popupWin.callbackHandler){
		parent.popupWin.callbackHandler();
	}
	parent.popupWin.close();
}

//--------------------------------------------------------------------------	
//	回上頁Function
//--------------------------------------------------------------------------
function doBack(){
	CSRUtil.linkBack();
}

var auxiliary = {    
	
	// 產生tr
	createTR:function(table, position){
		var tr = table.insertRow(position);
		return tr;
	},
	// 產生td
	createTD:function(tr, position, className, colspan){
		var td = tr.insertCell(position);
		td.className = className;
		if(colspan){
			td.colSpan = colspan;
		}
		return td;
	},
	
	// 產生input物件
	createInput:function(config){
		var input = document.createElement("input");
		//input.id = config.id ? config.id : "";
		input.id = config.value ? config.value : "";
		//input.name = config.value ? config.value : "";
		input.name = config.id ? config.id : "";
		input.className = config.className ? config.className : "";
		input.type = config.type ? config.type : "";
		input.value = config.value ? config.value : "";
		input.onclick = config.clickAction ? config.clickAction : "";

		return input;
	},

    getcheckBoxValue : function(){
    	var cbs = $$('.cb');
    	var values = [];
    	if(cbs.length){
    		cbs.each(function(e){ if(e.checked) values.push(e.value); });	
    	}
    	return values;
    },
    
    getDATA_MAP : function(){
    	DATA_MAP.RETURN_ITEM_LIST = auxiliary.getcheckBoxValue();
    },
    
    insertDataToTable: function(dataList, tableName){
    	if(dataList){
					$(tableName + '_SPAN').show();
					var table = $(tableName);
					var length = dataList.length;
					var len = length % 4;
					var tr;
					for(var i=0; i<length; i++){
						if((i+1)%4==1){
							tr = auxiliary.createTR(table, table.rows.length);
						}
						// radio
						var td = auxiliary.createTD(tr, i%4, "tbBlue2");
						td.width = "25%";
						
						var cb = auxiliary.createInput({id:tableName, className:'cb', type: 'checkbox', value:dataList[i].RETURN_ITEM, clickAction:
							function(){
								if(this.checked){
									var cond = '#' + this.name + ' INPUT[type=checkbox]:not([id=' + this.name + '_CHECK])'
									var checks = $$(cond);
									var flag = true;
									checks.each(
										function(e){
											if(!e.checked){
												flag = false;
												return;
											}
										}
									);
									$(this.name+'_CHECK').checked = flag;
								}else{
									$(this.name+'_CHECK').checked = false;
								} 
							}
						});
						td.appendChild(cb);	
						td.appendChild(document.createTextNode(dataList[i].ITEM_NAME));
					}
					
					//補欄位
					if(len){
						while(4-len){
							var td = auxiliary.createTD(tr, len, "tbBlue2");
							td.width = "25%";
							len++;	
						}
					}
					
					var cond = '#' + tableName + ' INPUT[type=checkbox]:not([id=' + tableName + '_CHECK])'
					var checks = $$(cond); 
					var flag = true;
					checks.each(function(e){
					 	if(!e.checked){
					 		flag = false;
					 		return;
					 	}
					});
						
					if(flag){
						$(tableName+'_CHECK').checked = true;
					}
		}
    }
}
//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0"
	marginheight="0">
<form name="form1" id="form1" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="1"
	class="tbBox2">

	<input
		name="LP_JSON" id="LP_JSON" type="hidden" value="">
	<tr align="center" class="tbYellow0">
		<td colspan="3" class="textBold">送件明細表</td>
	</tr>
	<tr align="center" class="tbYellow0">
		<td width="22%" valign="middle" align="center" class="tbBlue"
			colspan="2">受理編號</td>
		<td width="23%" valign="middle" align="center" class="tbBlue">注意事項</td>
	</tr>
	<tr align="center" class="tbYellow0">
		<td width="22%" class="tbBlue2" colspan="2"><span
			id="APPLY_ID_span"></span></td>
		<!--
				<td class="tbBlue2"><span id="BORROW_NAME_span"></span></td>
				<td class="tbBlue2"><span id="CRED_DEPT_NM_span"></span></td>
				<td class="tbBlue2"><span id="APPLY_DATE_span"></span></td>
				<td class="tbBlue2"><span id="SEND_NAME_span"></span></td>
				<td class="tbBlue2"><span id="SEND_DATE_span"></span></td>-->
		<td class="tbBlue2"><span id="button_span"> <input
			type="button" id="btn_classify" value="錯誤歸類" class="button">
		<!--<input type="button" id="btn_back" value="上一頁" class="button">-->
		<input type="button" id="btn_close" value="關閉" class="button">
		</span></td>
	</tr>

</table>
<table id="A" width="100%" border="0" cellpadding="0" cellspacing="1"
	class="tbBox2">
	<tr align="center" class="tbYellow0">
		<td colspan="4" class="textBold">文件初審<span ID="A_SPAN"><INPUT
			id="A_CHECK" type="checkbox">全選</span></td>
	</tr>
</table>
<table id="B" width="100%" border="0" cellpadding="0" cellspacing="1"
	class="tbBox2">
	<tr align="center" class="tbYellow0">
		<td colspan="4" class="textBold">文件初審系統作業<span ID="B_SPAN"><INPUT
			id="B_CHECK" type="checkbox">全選</span></td>
	</tr>
</table>
<table id="C" width="100%" border="0" cellpadding="0" cellspacing="1"
	class="tbBox2">
	<tr align="center" class="tbYellow0">
		<td colspan="4" class="textBold">文件覆審<span ID="C_SPAN"><INPUT
			id="C_CHECK" type="checkbox">全選</span></td>
	</tr>
</table>
<table id="D" width="100%" border="0" cellpadding="0" cellspacing="1"
	class="tbBox2">
	<tr align="center" class="tbYellow0">
		<td colspan="4" class="textBold">文件覆審系統作業<span ID="D_SPAN"><INPUT
			id="D_CHECK" type="checkbox">全選</span></td>
	</tr>
</table>
<table id="E" width="100%" border="0" cellpadding="0" cellspacing="1"
	class="tbBox2">
	<tr align="center" class="tbYellow0">
		<td colspan="4" class="textBold">撥款初審<span ID="E_SPAN"><INPUT
			id="E_CHECK" type="checkbox">全選</span></td>
	</tr>
</table>
<table id="F" width="100%" border="0" cellpadding="0" cellspacing="1"
	class="tbBox2">
	<tr align="center" class="tbYellow0">
		<td colspan="4" class="textBold">撥款初審系統作業<span ID="F_SPAN"><INPUT
			id="F_CHECK" type="checkbox">全選</span></td>
	</tr>
</table>
</form>
</body>
</html>