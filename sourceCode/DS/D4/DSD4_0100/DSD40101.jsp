<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSD40101.jsp
功能：清償附件分頁畫面
作者：陳子榮 
完成：2019/4/18
-->

<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>

<title></title>
<!--匯入外部Javascript 與 css-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/tabs.js"></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript'>

<%-- 產生畫面物件 --%>
Event.observe(window, 'load', new DSD40101().initApp);

function DSD40101(){
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_0101/');
	var valid1;
	
	function CreateTabs(Tab_List){
	
		var srcs = {};
		var tabArray = [];			
		
		for(var i=0;i<Tab_List.length;i++){
			var FUNC_ID = Tab_List[i].FUNC_ID;
			var LOAN_ID = Tab_List[i].LOAN_ID;
			var TITLE = Tab_List[i].TITLE;
			var ACTION_TYPE = Tab_List[i].ACTION_TYPE;
			srcs[FUNC_ID]="${dispatcher}/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?LOAN_ID="+LOAN_ID+"&ACTION_TYPE="+ACTION_TYPE+"&titleNotDisplay=Y";
			tabArray.push({'id': FUNC_ID, 'title': TITLE});
			
		}	
		
		var tabs = new Tabs({
			id:'tabsMenu',
			tabs:tabArray,	
			beforeSwitchShowCover: true,	
			beforeSwitch: function(info){
				var f = $(info.to);						
				var targetURL = srcs[info.to];					
				f.src = targetURL;
				var high = document.body.clientHeight;
				$$('#contents iframe').each(function(elem){
					elem.height = high;
				});
			}
		});
	}	
	
	function initValidation(){
		Validation.addAllThese([
			[ 'validateLOAN_ID',  '受理編號有誤，請檢查後重新輸入!', 
				function(v){ 
					<%--貸款帳號至多11碼英數字--%>
					return v.length <= 11 && (/^[a-zA-Z0-9@]+$/.test(v)); 
				} 
			]
	    ]);
		valid1 = new Validation('form1', {focusOnError:true, immediate:false , mode: 'validator'});
		valid1.define('required', {id: 'LOAN_ID', errMsg: '請輸入正確貸款帳號!'});
		valid1.define('validateLOAN_ID', {id: 'LOAN_ID', errMsg: '貸款帳號至多11碼英數字'});
	}
	
	var actions = {
		
		getReqMap : function (){					
			var regMap = {				
				'LOAN_ID'   :     $F('LOAN_ID')			
			};
			return regMap;
	    }
	};
		
	
	var buttons = {		
		doQuery : function (){	
			
			valid1.reset();
			if(!valid1.validate()){				
				return;			
			}	
			
			ajaxRequest.post(
				'query',
				{ reqMap : Object.toJSON(actions.getReqMap())},				
				function(resp){						
					var Tab_List = resp.Tab_List||[];
			        CreateTabs(Tab_List);					
					
				}
			);
		},
		doBack : function (){		    		 
			if(window.isPopupWin && window.popupWinBack){
            	window.popupWinBack();
            }else if(window.parent && window.parent.popupWin){
            	window.parent.popupWin.back();
            }else{
				CSRUtil.linkBack(); 
            }
		}
				
	};
		
	return {	
		initApp : function() {			
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' />			
			PageUI.createPageWithAllBodySubElement('DSD40101', '清償作業', '清償附件');			
							
			initValidation();	
			$("btn_Query").observe('click', buttons.doQuery);
			$("btn_Back").observe('click', buttons.doBack);			
				
			<c:if test='${not empty LOAN_ID}'>
			//接值有值，執行初始查詢
			buttons.doQuery();
			</c:if>
											
			displayMessage();		
		}	
	};	
}	
</script>

</head>
<body>
<form name='form1' id='form1'>
	<%-- query form--%>
	<table id="mainTable" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td width="10%" class="tbYellow">貸款帳號</td>
			<td class="tbYellow2" colspan="2">
				<input id="LOAN_ID" name="LOAN_ID" type="text" class="textBox2" title="貸款帳號" size="14" maxlength="11" value="${LOAN_ID}" />				
			</td>
			<td class="tbYellow2" >		
				<button type="button" id="btn_Query" class="button">查詢</button>
				<button type="button" id="btn_Back" class="button">上一頁</button>
				
			</td>
		</tr>
	</table>
	<div id="tabsMenu" style="width:100%"></div>		
	<div id="contents" class="tab">
			<iframe id="DSD40100" frameborder="0" scrolling="yes" border="0" style="display:none;width:100%" ></iframe>
			<iframe id="DSD40110" frameborder="0" scrolling="yes" border="0" style="display:none;width:100%" ></iframe>
			<iframe id="DSD40120" frameborder="0" scrolling="yes" border="0" style="display:none;width:100%" ></iframe>
	</div>
</form>
</body>
</html>