<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSD41606.jsp
功能：清償文件補全項目
作者：巫國慧
完成：2021/08/05
-->	
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible"> 

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
  
<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
 
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/InputUtility.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type='text/javascript'>
Event.observe(window, 'load', new DSD41606().initApp);

function DSD41606() {

	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1606/');
	var valid1;
	var APPLY_DATE = '${APPLY_DATE}';
	var allDisable = ('${LINK_FROM}' != 'DSD41400' || 'N' != '${READONLY}');

	//按鈕授權
	function buttonAuth(){
		var authButtons = {
			B0028: 'btn_confirm'//確認
		};		

		<dz:grantButtons FUNC_ID="DSD41606"/>
	};
	
	<%-- 檢核 --%>
	function initValidation(){
		valid1 = new Validation('form1', {focusOnError:true, immediate:false , mode: 'validate'});
		valid1.define('required', {id:'MEND_NOTE'});
	}

	var actions = {
		//依照代碼設定，顯示應附文件種類
		showColumn : function(){
			var table = $('grid');
			
			var FILE_KINDS_MAP = <c:out value='${FILE_KINDS_MAP}' escapeXml='false' default='{}'/>;
			Object.keys(FILE_KINDS_MAP).forEach(function(keyStr){
				var keyMapObj = JSON.parse(keyStr);
				var keyMap = Object.keys(keyMapObj);
				var RECEIVE_ROLE = keyMap[0];
				
				//領取人角色-全選
				var oneRow = new Element('tr');
				var td_checkbox = new Element('td', {'style':'text-align:center'});
				var input_checkboxAll = new Element('input', {'class':'input', 'type':'checkbox', 
					'id':'MEND_ALL_'+RECEIVE_ROLE, 'name':'BLOCK_CHECK', 'vfor':'MEND_TXT_'+RECEIVE_ROLE, 'RECEIVE_ROLE':RECEIVE_ROLE});
				oneRow.insert(td_checkbox.insert('選取  ').insert(input_checkboxAll));
				//領取人角色
				var td = new Element('td');
				var span = new Element('span').update(keyMapObj[RECEIVE_ROLE]);
				oneRow.insert(td.insert(span));
				table.insert(oneRow);
				
				var FILE_KINDS = FILE_KINDS_MAP[keyStr];
				Object.keys(FILE_KINDS).forEach(function(FILE_KIND){
					var FILE_KIND_NM = FILE_KINDS[FILE_KIND];
					
					//應附文件-checkbox
					var oneRow = new Element('tr');
					var td_checkbox = new Element('td', {'class':'tbYellow2','style':'text-align:center'});
					var input_checkbox = new Element('input', {'class':'input', 'type':'checkbox', 
						'id':'MEND_ITEM_'+RECEIVE_ROLE+'_'+FILE_KIND, 'name':'MEND_TXT_'+RECEIVE_ROLE, 
						'value':RECEIVE_ROLE+'_'+FILE_KIND});
					oneRow.insert(td_checkbox.insert(input_checkbox));
					//應附文件
					var td = new Element('td', {'class':'tbYellow2'});
					var span = new Element('span').update(FILE_KIND_NM);
					oneRow.insert(td.insert(span));
					table.insert(oneRow);
				});
			});
			
		} ,
		<%-- 塞值 --%>
		putData : function(){
			$('REFER_ID_show').update('${REFER_ID}');
			$('APPLY_DATE_show').update(localeDisplay.formatDate('${APPLY_DATE}'));
			
			//全部清除
			$$("#form1 input[type='checkbox']").each(function(elm){
				elm.checked = false;
			});
            //[問題單:20230802-0175] 電子簽收檢核上線後優化:若enter斷行，畫面有BUG
			var MEND_ITEMs = <c:out value='${MEND_ITEMs}' escapeXml='false' default='[]'/>;
			MEND_ITEMs.forEach(function(MEND_ITEM){
				var elm = $('MEND_ITEM_'+MEND_ITEM);
				if(elm){
					elm.checked = true;
				}
			});
			
			actions.mendTxtAllCheck();
		}
		<%-- 取畫面上的值 --%>
		,getReqMap : function(){
			var MEND_TXTOT_ARR = ['MEND_TXTAOT', 'MEND_TXTBOT', 'MEND_TXTCOT', 'MEND_TXTDOT', 'MEND_TXTEOT']
			var reqMap = {
				'REFER_ID':'${REFER_ID}',
				'APPLY_DATE':'${APPLY_DATE}',
				'SIGN_STATUS':'${SIGN_STATUS}',
				'CASE_STATUS':'${CASE_STATUS}'
			};

			var MEND_ITEM = '';
			$$("#form1 input[type='checkbox']").each(function(elm){
				var id = elm.id;
				var isChecked = elm.checked;
				if(elm.name != 'BLOCK_CHECK' && isChecked){ <%-- 區塊子項目勾選框  --%>
					MEND_ITEM += elm.getValue()+','; <%-- 塞入每區塊子項目的值  --%>
				}
			});		
			reqMap.MEND_ITEM = MEND_ITEM.substr(0,MEND_ITEM.length-1);
			
			reqMap.MEND_NOTE = $F('MEND_NOTE'); <%-- 塞入補全說明資料 --%>
			return reqMap;
		}
		<%-- 區塊子選項全選 --%>
		,blockCheckAll : function(){
			var isCheckAll = this.checked;  
			var vfor = this.getAttribute("vfor");
			$$("#form1 input[name='"+vfor+"']").each(function(elm){ <%-- 區塊裡的所有子選項 --%>
				elm.checked = isCheckAll;
			});
		}
		<%-- 區塊全選框勾選或取消勾選(子選項全部勾選時，全選框自動勾選) --%>
		,mendTxtAllCheck : function(name){
			if(name){
				$$("input[vfor='"+name+"']").each(function(elm){
					elm.checked = actions.getBlockIsCheckAll(name);
				});
			}else{
				$$("input[name='BLOCK_CHECK']").each(function(checkAllelm){
					checkAllelm.checked = actions.getBlockIsCheckAll(checkAllelm.getAttribute('vfor'));
				});
			}
		}
		<%-- 區塊子選項是否都有勾選 --%>
		,getBlockIsCheckAll : function(name){
			var isAllCheck = true;
			$$("#form1 input[name='"+name+"']").each(function(elm){
				if(!elm.checked){
					isAllCheck = false;
					return;
				}
			});
			return isAllCheck;
		}
		<%-- 回上一頁 --%>
		,goBack : function (){
			if(window.isPopupWin && window.popupWinBack){
				window.popupWinBack();
			}else if(window.parent && window.parent.popupWin){
				window.parent.popupWin.back();
			}else{
				CSRUtil.linkBack(); 
			}	
		}
	}
	
	var buttons = {		
		doConfirm : function(){	 
			valid1.reset();
			if(!valid1.validate()){
				return;			
			}
			
			var isGoBack = false;
			ajaxRequest.setSynchronous(true);
			ajaxRequest.post('confirm', {'reqMap':Object.toJSON(actions.getReqMap())},
				function(resp){	
					alert("下補全完成");
					isGoBack = true;
				}
			);
			ajaxRequest.setSynchronous(false);
			
			if(isGoBack){ <%-- 不直接在ajax成功回傳後執行，避免出現emptyFunction錯誤 --%>
				actions.goBack(); <%-- 回上一頁 --%>
			}
		}
	};
	
    return{   
	    initApp : function(){	
	    	<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>  
		    PageUI.createPageWithAllBodySubElement("DSD41606","清償作業","清償文件補全項目");
		    InputUtility.lengthLimit.add("MEND_NOTE", 200, true, "中文或全型算2個字，已輸入{enter}字，尚可輸入{left}字。");
		    
		    actions.showColumn();
		    
		    <%-- 綁定按鈕 --%>
		    $('btn_confirm').observe('click', buttons.doConfirm); <%-- 確認 --%>
		    
		    $('form1').select('input','textarea','button').each(function(elm){
		    	var isCheckbox = (elm.type == 'checkbox'); <%-- 是否為勾選欄位 --%>
		    	var name = elm.name;
				if(isCheckbox && (name=='BLOCK_CHECK')){ <%-- 是區塊全選框時進入 --%>
					elm.observe('click', actions.blockCheckAll); <%-- 區塊全選框綁定相對應區塊裡的所有子選項勾選 --%>
					actions.mendTxtAllCheck(elm.getAttribute('vfor'));  <%-- 初始時掃描所有區塊的子項目決定是否勾選該區塊的全選框 --%>
				}else if(isCheckbox){ <%-- 子項目勾選框時進入  --%>
					elm.observe('click', function(){
						actions.mendTxtAllCheck(name); <%-- 掃描相同區塊的所有子項目決定是否勾選該區塊的全選框  --%>
					}); 
				}
				
				if(allDisable){ <%-- 非DSD41400頁面進入時 --%>
					elm.disable(); <%-- disable所有欄位 --%>
		    	}
			});

		    actions.putData(); <%-- 初始塞值 --%>

			buttonAuth();
		    displayMessage();
		    initValidation();
	   }
   };
}

</script>
</head>

<body>
<form name="form1" id="form1" method="post">
<table class='tableGrid' width="100%">
	<tr>
		<td class="tbYellow">原貸帳號</span></td>
		<td class="tbYellow2"><span id="REFER_ID_show"></td>
		<td class="tbYellow">塗銷申請日</span></td>
		<td class="tbYellow2"><span id="APPLY_DATE_show"></span></td>
	</tr>
</table>
<table class='tableGrid' width="100%" id="grid"></table>
<table class='tableGrid' width="100%">
	<tr>							
		<td class="tbYellow">
			補全說明
		</td>
		<td class="tbYellow2" colspan="2">
			<textarea id="MEND_NOTE" rows="5" cols="35">${MEND_NOTE}</textarea>	<br>
			<span style="color:red;">補全說明請輸入，如果無特別要說明，也請輸入無。</span>
		</td>		
	</tr>
	<tr>							
		<td class="tbYellow" align="center" colspan="3">
			<button type="button" class="button" id="btn_confirm">確認</button>			
		</td>			
	</tr>
</table>
</form>
</body>
</html>