<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>

<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!--
程式：DSA21000.jsp
功能：簽件作業

[20230509]問題單號20230508134214
1.新增判斷:債信評等頁面離開畫面，根據條件跳出提示訊息
 -->

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ui/tabs.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>

<script type="text/JavaScript">
<!--

if(!window.fix){ var fix;}
if( !Object.isUndefined(fix) && Object.isFunction(fix) ){
	fix = fix.wrap(function(){

		//調整外部的高度大小，固定下來，讓上下的 scroll 不生效
		var h = document.body.clientHeight;

		var mainBlock = $('mainBlock');

		// 取得頁籤的高度
		var tabsMenuHeight = 0;
		var tabsMenu = $('tabsMenu');
		if(tabsMenu){ tabsMenuHeight = tabsMenu.getHeight(); }

		// 將畫面高度 - 頁籤所佔之高度
		h -= tabsMenuHeight;

		// 當作業畫面高度未異動時，則不進行調整
		var keepClientHeight = mainBlock.readAttribute('keepClientHeight');
		if(keepClientHeight===h){
			return;
		}

		mainBlock.writeAttribute('keepClientHeight', h);

		mainBlock.setStyle({'height':(h - $('bar1').getHeight() + tabsMenuHeight ) + 'px'});

		//調整高度
		h = h  - 100;

		$$('#contents iframe').each(function(it){
			it.height = h;
		});
	});
}

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var DSA21000 = {};
var chkDSA20902Flag = false;<%--[20230509][20230508134214]新增判斷:模型回饋是否有異動--%>
function initApp(){

	new UI().init();
	fix();
	$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
	$('APPLY_ID').focus();

}

function UI(){
	return {
		init:function() {
			displayMessage();

			// 查詢
			$("btn_query").observe('click',function(event){
				buttons.doQuery();
			});

			DSA21000.valid = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});						
		}
	};
}


function createTabs(Tab_List, applyId){

	var srcs = {};
	var tabArray = [];

	for(var i=0;i<Tab_List.length;i++){
		var FUNC_ID = Tab_List[i].FUNC_ID;
		var APPLY_ID = Tab_List[i].APPLY_ID;
		var PERSON_ID = Tab_List[i].PERSON_ID;
		var CASE_TYPE = Tab_List[i].CASE_TYPE;
		
		srcs[FUNC_ID]="<%=dispatcher%>/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?APPLY_ID="+APPLY_ID+"&LINK_FROM=DSA21000&titleNotDisplay=Y";
		//增加查詢參數
		if(FUNC_ID == 'DSA20200'){
			srcs[FUNC_ID] = srcs[FUNC_ID]+'&TYPE=A&VALUE='+APPLY_ID ;
		}
		if(FUNC_ID == 'DSH01400'){
			srcs[FUNC_ID] = srcs[FUNC_ID]+'&PERSON_ID='+PERSON_ID ;
		}
		if(FUNC_ID == 'DSA21002'){
			srcs[FUNC_ID] = srcs[FUNC_ID]+'&CASE_TYPE='+CASE_TYPE ;
		}
		tabArray.push({'id': FUNC_ID, 'title': Tab_List[i].TITLE});
		/*
		var childTab = $(FUNC_ID);
		if(childTab && childTab.tagName == 'IFRAME'){
			childTab.src = '';
		}
		*/
	}
	
	//產生 tabs
	DSA21000.tabs = new Tabs({

		//欲產生 tab 的 div container
		id:'tabsMenu',

		//定義 tab 的 title，及點選時搭配 show/hide 的 elemnt id
		tabs:tabArray,
		beforeSwitch: function(info){
			//在第一次顯示該 iframe 時，才載入 src
			var f = $(info.to);			
			var targetURL = srcs[info.to];
			var oriSRC = f.src;
			
			if(info.to=='DSA21006'||info.to=='DSA21007'){
				f.src = targetURL;
			}
			
			<%--[20230509][20230508134214]若DSA20902頁面D區模型回饋有異動尚未修改，離開畫面跳提示訊息:模型回饋尚未修改，請確認是否已完成!，選擇確認離開畫面，取消留在原畫面繼續操作--%>
			if(info.from === 'DSA20902' && info.to !== 'DSA20902'){
				var iframe = window.frames['DSA20902'];
				var iframeObj = iframe.contentDocument || iframe.document;
				var iframeEle = iframeObj.getElementById("updateStatus_DSA20902");
				chkDSA20902Flag = iframeEle != null ? ($F(iframeEle) === 'Y') : false;
				if(chkDSA20902Flag){
					if(!confirm("模型回饋尚未修改，請確認是否已完成!")){
						$('tabMenuItem-tabsMenu-DSA20902').click();
					}else{
						chkDSA20902Flag = false;
					}
				}
			}
						
			<%--[20230509][20230508134214]若債信評等頁面(DSA20902)模型回饋尚未修改時，不需重新查詢，留在原畫面--%>
			if(info.to === 'DSA20902' && chkDSA20902Flag){
				return;
			}

			<%--[20180328] 問題單20180327115719 頁籤轉換時不需重新查詢  --%>
			<%--[20230509][20230508134214]每次進入債信評等頁面(DSA20902)須重新查詢--%>
			if(oriSRC && oriSRC.indexOf(targetURL) > 0 && info.to !== 'DSA20902') {
				return;
			}
			
			if(f.src.blank() || f.src != targetURL){
				f.src = targetURL;
			}
			
		},
		beforeSwitchShowCover: true
	});

	fix();

}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){
		
		DSA21000.valid.reset();
	
		if( !DSA21000.valid.validate() ) {
			return;
		}

		$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
		var applyId = $F('APPLY_ID');
		var queryData = {
			APPLY_ID: applyId
		};
			
		
		var actionName = "query"; 
		var params = {APPLY_ID: $F('APPLY_ID')};
		
		$$('IFRAME.contents_iframe').each(function(elem){
			elem.src = '';
		});
			
		if(DSA21000.tabs){         		
				DSA21000.tabs.removeAll();
				DSA21000.tabs = null;
		}
		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $F('APPLY_ID') });
		$('CONTROL_CODE').value = '';
		DSA21000.ajaxPost(actionName, params, function(resp){			
			var Tab_List = resp.Tab_List;
			createTabs(Tab_List, applyId);	
			
			var CONTROL_CODE =  resp.CONTROL_CODE;
			var isInternal =  resp.isInternal;
			if (CONTROL_CODE){
			   $('CONTROL_CODE').value = CONTROL_CODE;
				var MSG;
				if(CONTROL_CODE == "ERR"){
				    MSG ="本件有「特殊管控」注意事項。"
				    if(isInternal == 'N'){
				    	MSG = MSG +"\r\n詳細內容請洽"+resp.CONTROL_DEPT_GROUP_NM+"。";
				    }
				    MSG += "\r\n若要查詢特殊件控管變更紀錄請按『確定』鍵?";
				}else if(CONTROL_CODE){
					MSG ="本件有「特殊提醒」注意事項。"
					if(isInternal == 'N'){
						MSG = MSG +"\r\n詳細內容請洽"+resp.CONTROL_DEPT_GROUP_NM+"。";
					}	
					MSG += "\r\n若要查詢特殊件控管變更紀錄請按『確定』鍵?";
				}
				if( confirm(MSG)){
					   buttons.linkTo_DSC8_3100(resp.BORROW_ID,"2-8");
		        }
			}
			
		});
	},
	linkTo_DSC8_3100:function(BORROW_ID,CONTROL_SOURCE){	
			
		popupWin.popup({
			src: '<%=dispatcher%>/DSC8_3100/prompt',scrolling : 'yes',
			parameters: { 
				LOAN_ID : BORROW_ID,
				CONTROL_TYPE : 'U',
				CONTROL_SOURCE : CONTROL_SOURCE
			}, 
			width: 600, 
			height: 350,
			cb : function(obj){}
		});
		
	}
};


//--------------------------------------------------------------------------
// 共用－Ajax
//--------------------------------------------------------------------------
DSA21000.ajaxPost = function( actionName, params, successAction, errorAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSA2_1000/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){          	
         	if(DSA21000.tabs){         		
				DSA21000.tabs.removeAll();
				DSA21000.tabs = null;
			}			
			if(CSRUtil.isSuccess(resp)){
				if(successAction){
	 				successAction(resp);
	 			}
			}
        }}
	);
}

//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<center>
<span id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility: visible;" > 
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr> 
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
   	 	<td valign="top" bgcolor="#F0FBC6">
   	 	<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
	        <tr>
	          	<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
	        </tr>
	  	</table>
		<!-- InstanceBeginEditable name="title" -->
		<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
	  		<tr> 
	          	<td width="20" height="24" align="center"><font size="-5">●</font></td>
	          	<td>核貸作業</td>
	          	<td align="right">畫面編號：DSA21000</td>
	        </tr>
		</table>
      	<!-- InstanceEndEditable -->
      	</td>
    	<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
   	 	<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  	</tr>
</table>
</span> 
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
  	<tr> 
    	<td>&nbsp;</td>
  	</tr>
</table>
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0" id="mainBlock">
  	<tr> 
	    <td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="16"></td>
	    <td width="100%" valign="top" bgcolor="#F0FBC6"><!-- InstanceBeginEditable name="content" -->
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td valign="top">
				<table width="97%" border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
					<tr> 
						<td class="tbBox2">
							<img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">
							簽件作業分頁畫面
						</td>
					</tr>
					<form name="form1" id="form1" method="post" action="">
					
					<input id="CONTROL_CODE" name="CONTROL_CODE" type="hidden" value="">
					<tr bgcolor=#FFFFFF>
						<td>						
							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
								<tr>
									<td width="20%" class="tbYellow">受理編號</td>
									<td class="tbYellow2" ><input id="APPLY_ID" name="APPLY_ID" type="text" fieldName="受理編號" class="textBox2 required" size="15" maxlength="11" value="" ></td>
									<td class="tbYellow2" align="center" width="12%"><input id="btn_query" name="btn_query" type="button" class="button" value="查詢"></td>
								</tr></form>
																
							</table>
							<!----------------------------------- 查詢結果 begin---------------------------------->
							<div id="tabsMenu" style="width:100%"></div>
							<div id="contents" class="tab">
								<iframe id="DSA21001" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA21002" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA21003" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA21009" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA21005" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA20200" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA20901" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA20902" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA20600" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA21006" class="contents_iframe" width="100%" border="0" style="display:none"></iframe>
								<iframe id="DSA30500" class="contents_iframe" width="100%" border="0" style="display:none"></iframe>
								<iframe id="DSA21007" class="contents_iframe" width="100%" border="0" style="display:none"></iframe>
								<iframe id="DSA20410" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA10900" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA20800" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA20701" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA20500" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSA20301" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
								<iframe id="DSH01400" class="contents_iframe" width="100%" border="0" style="display:none" scrolling="no"></iframe>
							</div>
							<!----------------------------------- 查詢結果 end---------------------------------->

						</td>
					</tr>
				</table>
				</td>
			</tr>
		</table>
    	</td>
    	<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="16"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  	</tr>
</table>
</center>














</body>
</html>