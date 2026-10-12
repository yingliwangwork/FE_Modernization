<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%-- 
程式：DSA12000.jsp
作者：簡辰宇
功能：文初檢核表分頁畫面
完成：2023/09/05
更新：
--%>
<html>
<head>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css" />

<title></title>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/tabs.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>

<script type="text/JavaScript">

Event.observe(window, 'load', new DSA12000().initApp);

function DSA12000(){
	
	var tabObj = {};
	var valid1;
	
	<%--建立 ajax request 物件--%>
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA1_2000/');
	
	<%-- 畫面檢核 --%>
	var valid = new Validation('form1', {focusOnError:true, immediate:false, mode : 'validate'});
	valid.define( 'required', [ {id:'APPLY_ID', errMsg:'受理編號不可為空'} ] );
	    
	function initValidation(){		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode:'validate'});
		valid1.define( 'required', [ {id:'APPLY_ID', errMsg:'受理編號不可為空'} ] );	
	};
	
	function createTabs(Tab_List, applyId){
		var srcs = {};
		var tabArray = [];

		for(var i=0;i<Tab_List.length;i++){
			var FUNC_ID = Tab_List[i].FUNC_ID;
			var APPLY_ID = Tab_List[i].APPLY_ID;
			
			srcs[FUNC_ID]="${dispatcher}/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?APPLY_ID="+APPLY_ID+"&LINK_FROM=DSA12000";
			
			<%-- 增加查詢參數 --%>
			if(FUNC_ID == 'DSA20200'){
				srcs[FUNC_ID] = srcs[FUNC_ID]+'&TYPE=A&VALUE='+APPLY_ID ;
			}
			
			tabArray.push({'id': FUNC_ID, 'title': Tab_List[i].TITLE});

		}
		
		<%-- 產生 tabs --%>
		tabObj.tabs = new Tabs({

			<%-- 欲產生 tab 的 div container --%>
			id:'tabsMenu',

			<%-- 定義 tab 的 title，及點選時搭配 show/hide 的 elemnt id --%>
			tabs:tabArray,
			beforeSwitch: function(info){
				
				<%-- 在第一次顯示該 iframe 時，才載入 src --%>
				var f = $(info.to);			
				var targetURL = srcs[info.to];
				var oriSRC = f.src;

				if(oriSRC && oriSRC.indexOf(targetURL) > 0) {
					return;
				}
				
				if(f.src.blank() || f.src != targetURL){
					f.src = targetURL;
				}
				
			},
			beforeSwitchShowCover: true
		});

	}

	<%-- 功能按鈕 --%>
	var buttons = {
		<%-- 查詢 --%>
		doQuery:function(){
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			
			if ($F('APPLY_ID').length != 11) {
				alert("受理編號長度不對，須為11碼")
				return; 
			}

			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			var applyId = $F('APPLY_ID');
			var queryData = {
				APPLY_ID: applyId
			};
				
			$$('IFRAME.contents_iframe').each(function(elem){
				elem.src = '';
			});
				
			if(tabObj.tabs){         		
				tabObj.tabs.removeAll();
				tabObj.tabs = null;
			}
			

			<%-- 保留參數管理-更新受理編號 --%>
			CSRUtil.keepParamsManager.put({'APPLY_ID': $F('APPLY_ID') });


			<%-- doQuery API --%>
			ajaxRequest.post('doQuery', {
				APPLY_ID: $F('APPLY_ID')}, function(resp){
					createTabs(resp.Tab_List, applyId);	
				}
			);
			
			
		}
	}

	
	return {
		initApp: function() {
			
			<%-- 頁面渲染 --%>
			PageUI.createPageWithAllBodySubElement("DSA12000", "文初檢核表", "文初檢核表");
			
			<%-- 查詢 --%>
			$("btn_query").observe('click', buttons.doQuery); 
			
			initValidation();
			displayMessage();
		}
	};

}

</script>
</head>
<body>
	<form id="form1">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td>						
					<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
						<tr>
							<td width="20%" class="tbYellow">受理編號</td>
							<td class="tbYellow2" ><input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2 required" size="15" maxlength="11" value="" ></td>
							<td class="tbYellow2" align="center" width="12%">
								<button id="btn_query" name="btn_query" type="button" class="button">查詢</button>
							</td>
						</tr>		
					</table>
					
					<%-- 查詢結果  --%>
					<div id="tabsMenu" style="width:100%"></div>
					<div id="contents" class="tab">
						<iframe id="DSA12001" class="contents_iframe" width="100%" style="border:0px; display:none" scrolling="no"></iframe>
						<iframe id="DSA10400" class="contents_iframe" width="100%" style="border:0px; display:none" scrolling="no"></iframe>
						<iframe id="DSA10500" class="contents_iframe" width="100%" style="border:0px; display:none" scrolling="no"></iframe>
						<iframe id="DSA10100" class="contents_iframe" width="100%" style="border:0px; display:none" scrolling="no"></iframe>
						<iframe id="DSA10200" class="contents_iframe" width="100%" style="border:0px; display:none" scrolling="no"></iframe>
						<iframe id="DSA10250" class="contents_iframe" width="100%" style="border:0px; display:none" scrolling="no"></iframe>
						<iframe id="DSA10900" class="contents_iframe" width="100%" style="border:0px; display:none" scrolling="no"></iframe>
						<iframe id="DSA20200" class="contents_iframe" width="100%" style="border:0px; display:none" scrolling="no"></iframe>
						<iframe id="DSA20600" class="contents_iframe" width="100%" style="border:0px; display:none" scrolling="no"></iframe>
						<iframe id="DSA21000" class="contents_iframe" width="100%" style="border:0px; display:none" scrolling="no"></iframe>
					</div>
		
				</td>
			</tr>
		</table>
	</form>
</body>
</html>